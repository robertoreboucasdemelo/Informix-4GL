#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty00g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter informacoes do corretor                              #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 19/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#---------------------------#
 function cty00g00_prepare()
#---------------------------#

  define l_sql char(200)
  let l_sql = "select b.cornom ",
              "  from gcaksusep a, gcakcorr b ",
              " where a.corsus = ? ",
              "   and a.corsuspcp = b.corsuspcp "
  prepare pcty00g00001  from l_sql
  declare ccty00g00001  cursor for pcty00g00001

  let l_sql = " select suslnhqtd from gcaksusep ",
              "  where corsus = ? "
  prepare pcty00g00002  from l_sql
  declare ccty00g00002  cursor for pcty00g00002

  let m_prep_sql = true

end function

#----------------------------------------#
 function cty00g00_nome_corretor(lr_parm)
#----------------------------------------#
 define lr_parm        record
        corsus         like gcaksusep.corsus
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        cornom         like gcakcorr.cornom
 end record

 define l_msg          char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty00g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.corsus is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if

 open ccty00g00001  using lr_parm.*
 whenever error continue
 fetch ccty00g00001 into  lr_retorno.cornom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Corretor nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccty00g00001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em gcaksusep,gcakcorr"
       call errorlog(l_msg)
       let l_msg = " cty00g00_nome_corretor() / ",lr_parm.corsus
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty00g00001
 return lr_retorno.*
end function
#----------------------------------------#
 function cty00g00_org_cor(lr_parm)
#----------------------------------------#
 define lr_parm        record
        corsus         like gcaksusep.corsus
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        suslnhqtd      like gcaksusep.suslnhqtd
 end record

 define l_msg          char(60)
 if m_prep_sql is null or m_prep_sql <> true then
    call cty00g00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.corsus is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if

 open ccty00g00002  using lr_parm.corsus

 whenever error continue

 fetch ccty00g00002 into  lr_retorno.suslnhqtd

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Corretor nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " cty00g00_dados_cor() / ",lr_parm.corsus
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccty00g00002
 return lr_retorno.*
end function
