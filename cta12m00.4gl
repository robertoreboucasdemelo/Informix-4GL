#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta12m00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter/atualizar informacoes na datkgeral                   #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 19/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 02/07/2008  Amilton, Meta     Psi 223689 Incluir função de alteração na    #
#                                          Datkgeral                         #
#----------------------------------------------------------------------------#

database porto

define m_prep_cta12m00   smallint

#---------------------------#
 function cta12m00_prepare()
#---------------------------#

  define l_sql        char(200)
  let l_sql = "select grlinf from datkgeral ",
              " where grlchv = ? "
  prepare pcta12m00001  from l_sql
  declare ccta12m00001  cursor for pcta12m00001

  let l_sql = "insert into datkgeral ",
              "(grlchv,grlinf,atldat,atlhor,atlemp,atlmat) ",
              " values (?,?,?,?,?,?) "
  prepare pcta12m00002  from l_sql

  let l_sql = "delete from datkgeral ",
              " where grlchv = ? "
  prepare pcta12m00003  from l_sql
  let l_sql = "update datkgeral set grlinf = ? ",
              " where grlchv = ? "
  prepare pcta12m00004  from l_sql
  let m_prep_cta12m00 = true

end function

#----------------------------------------------#
 function cta12m00_seleciona_datkgeral(lr_parm)
#----------------------------------------------#

 define lr_parm        record
        grlchv         like datkgeral.grlchv
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        grlinf         like datkgeral.grlinf
 end record

 define l_msg          char(60)
 if m_prep_cta12m00 is null or m_prep_cta12m00 <> true then
    call cta12m00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.grlchv is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if

 open ccta12m00001  using lr_parm.*
 whenever error continue
 fetch ccta12m00001 into  lr_retorno.grlinf
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Chave nao encontrada na datkgeral"
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccta12m00001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em datkgeral"
       call errorlog(l_msg)
       let l_msg = " cta12m00_seleciona_datkgeral() / ",lr_parm.grlchv
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccta12m00001
 return lr_retorno.*
end function

#-------------------------------------------#
 function cta12m00_inclui_datkgeral(lr_parm)
#-------------------------------------------#

 define lr_parm        record
        grlchv         like datkgeral.grlchv,
        grlinf         like datkgeral.grlinf,
        atldat         like datkgeral.atldat,
        atlhor         like datkgeral.atlhor,
        atlemp         like datkgeral.atlemp,
        atlmat         like datkgeral.atlmat
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60)
 end record

 define l_msg          char(60)
 if m_prep_cta12m00 is null or m_prep_cta12m00 <> true then
    call cta12m00_prepare()
 end if

 initialize lr_retorno.* to null

 let l_msg = "Chv:",  lr_parm.grlchv clipped
           , " Inf:", lr_parm.grlinf
           , " Dat:", lr_parm.atldat
           , " Hor:", lr_parm.atlhor
           , " Emp:", lr_parm.atlemp
           , " Mat:", lr_parm.atlmat

 call errorlog(l_msg clipped)

 if lr_parm.grlchv is null or
    lr_parm.grlinf is null or
    lr_parm.atldat is null or
    lr_parm.atlhor is null or
    lr_parm.atlemp is null or
    lr_parm.atlmat is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametros nulos"
    return lr_retorno.*
 end if
 whenever error continue
 execute pcta12m00002 using lr_parm.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_retorno.erro = 3
    let l_msg = " Erro de INSERT - pcta12m00002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
    let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " na inclusao datkgeral"
    call errorlog(l_msg)
    let l_msg = " cta12m00_inclui_datkgeral() / ",lr_parm.grlchv
    call errorlog(l_msg)
 else
    let lr_retorno.erro = 1
 end if
 return lr_retorno.*
end function

#-------------------------------------------#
 function cta12m00_remove_datkgeral(lr_parm)
#-------------------------------------------#

 define lr_parm        record
        grlchv         like datkgeral.grlchv
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60)
 end record

 define l_msg          char(60)
 if m_prep_cta12m00 is null or m_prep_cta12m00 <> true then
    call cta12m00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.grlchv is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if

 whenever error continue
 execute pcta12m00003 using lr_parm.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_retorno.erro = 3
    let l_msg = " Erro de DELETE - pcta12m00003 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
    let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " na remocao de datkgeral"
    call errorlog(l_msg)
    let l_msg = " cta12m00_remove_datkgeral() / ",lr_parm.grlchv
    call errorlog(l_msg)
 else
    let lr_retorno.erro = 1
 end if
 return lr_retorno.*
end function

#------------------------------------------
function cta12m00_altera_datkgeral(lr_parm)
#------------------------------------------

 define lr_parm        record
        grlinf         like datkgeral.grlinf,
        grlchv         like datkgeral.grlchv
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60)
 end record

 define l_msg          char(60)
 if m_prep_cta12m00 is null or m_prep_cta12m00 <> true then
    call cta12m00_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.grlchv is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if
 whenever error continue
 execute pcta12m00004 using lr_parm.grlinf,lr_parm.grlchv
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_retorno.erro = 3
    let l_msg = " Erro de UPDATE - pcta12m00004 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
    let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " na alteracao de datkgeral"
    call errorlog(l_msg)
    let l_msg = " cta12m00_altera_datkgeral() / ",lr_parm.grlchv
    call errorlog(l_msg)
 else
   if sqlca.sqlcode = notfound then
     let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " na alteracao de datkgeral"
     let lr_retorno.erro = 2
     return lr_retorno.*
   else
      let lr_retorno.erro = 1
   end if
 end if
 return lr_retorno.*

end function

