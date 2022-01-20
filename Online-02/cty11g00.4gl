#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty11g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter informacoes da tabela igbkgeral e                    #
#                 obter informacoes da tabela igfkferiado                    #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 21/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 25/02/2005 Robson Carmo,Meta PSI190772  Obter informacoes da iddkdominio   #
# 18/11/2010 Robert Lima       CT 02086   Alterado o errorlog para display   #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#---------------------------#
function cty11g00_prepare()
#---------------------------#

 define l_sql        char(200)

 let l_sql = " select grlinf from igbkgeral "
             ," where mducod = ? "
               ," and grlchv matches ? "
 prepare p_cty11g00_001 from l_sql
 declare c_cty11g00_001 cursor for p_cty11g00_001

 let l_sql = " select ferdia "
              ," from igfkferiado "
             ," where ferdia >= ? "
               ," and ferdia <= ? "
             ," order by ferdia "

 prepare p_cty11g00_002 from l_sql
 declare c_cty11g00_002 cursor for p_cty11g00_002

 let l_sql = ' select cpodes '
              ,' from iddkdominio '
             ,' where cponom = ? '
              ,'  and cpocod = ? '
 prepare p_cty11g00_003 from l_sql
 declare c_cty11g00_003 cursor for p_cty11g00_003

 let m_prep_sql = true

end function

#------------------------------------#
function cty11g00_igbkgeral(lr_parm)
#------------------------------------#
 define lr_parm record
    mducod like igbkgeral.mducod
   ,grlchv like igbkgeral.grlchv
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,grlinf    like igbkgeral.grlinf
 end record

 define l_msg char(100)

 if m_prep_sql is null or m_prep_sql <> true then
    call cty11g00_prepare()
 end if

 initialize lr_retorno.* to null
 let l_msg = null

 if lr_parm.mducod is null or
    lr_parm.grlchv is null then
    let lr_retorno.resultado = 3
    let l_msg = "Parametros nulos - cty11g00_igbkgeral"
    let lr_retorno.mensagem = "Parametros nulos - cty11g00_igbkgeral()"
    display l_msg
    return lr_retorno.*
 end if

 open c_cty11g00_001 using lr_parm.*
 whenever error continue
    fetch c_cty11g00_001 into lr_retorno.grlinf
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.resultado = 2
       let l_msg = "Informacao nao encontrado "
       let lr_retorno.mensagem = "Informacao nao encontrado "
    else
       let lr_retorno.resultado = 3
       let l_msg = "Erro SELECT - c_cty11g00_001 ",sqlca.sqlcode,"/", sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em igbkgeral"
       display l_msg
       let l_msg = " cty11g00_igbkgeral() / ",lr_parm.mducod, "/"
                                             ,lr_parm.grlchv
       display l_msg
    end if
 else
    let lr_retorno.resultado = 1
 end if
 close c_cty11g00_001

 return lr_retorno.*

end function

#--------------------------------------------#
 function cty11g00_feriados(l_dtini, l_dtfim)
#--------------------------------------------#
 define l_dtini date
       ,l_dtfim date
       ,l_i     smallint
       ,l_msg char(60)

 define al_fer    array[5] of record
        ferdia    date
       ,diasemana char(13)
 end record

 initialize al_fer to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty11g00_prepare()
 end if

 if l_dtini is null or
    l_dtfim is null then
    if l_dtini is null then
       let l_msg = 'Data inicial nao pode ser nula'
       display l_msg
    else
       let l_msg = 'Data final nao pode ser nula'
       display l_msg
    end if
    let l_i = 0
 else

    let l_i = 1

    open c_cty11g00_002 using l_dtini, l_dtfim

    foreach c_cty11g00_002 into al_fer[l_i].ferdia

       case weekday(al_fer[l_i].ferdia)
           when 0
              let al_fer[l_i].diasemana = 'DOMINGO'
           when 1
              let al_fer[l_i].diasemana = 'SEGUNDA-FEIRA'
           when 2
              let al_fer[l_i].diasemana = 'TERCA-FEIRA'
           when 3
              let al_fer[l_i].diasemana = 'QUARTA-FEIRA'
           when 4
              let al_fer[l_i].diasemana = 'QUINTA-FEIRA'
           when 5
              let al_fer[l_i].diasemana = 'SEXTA-FEIRA'
           when 6
              let al_fer[l_i].diasemana = 'SABADO'
       end case

       let l_i = l_i + 1

       if l_i > 5 then
          exit foreach
       end if

    end foreach

    let l_i = l_i - 1
 end if

 return l_i,
        al_fer[1].*,
        al_fer[2].*,
        al_fer[3].*,
        al_fer[4].*,
        al_fer[5].*

end function

#-------------------------------------#
function cty11g00_iddkdominio(lr_param)
#-------------------------------------#
 define lr_param record
    cponom like iddkdominio.cponom
   ,cpocod like iddkdominio.cpocod
 end record

 define lr_retorno record
        erro     smallint
       ,mensagem char(100)
       ,cpodes   like iddkdominio.cpodes
 end record

 define l_log char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty11g00_prepare()
 end if

 let l_log = null
 initialize lr_retorno to null

 open c_cty11g00_003 using lr_param.cponom
                        ,lr_param.cpocod

 whenever error continue
    fetch c_cty11g00_003 into lr_retorno.cpodes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = 'Dominio nao encontrado '
    else
       let lr_retorno.erro = 3
       let l_log = ' Erro de SELECT - c_cty11g00_003 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       let lr_retorno.mensagem = ' ERRO ',sqlca.sqlcode, ' em iddkdominio '
       display l_log
       let l_log = ' cty11g00_iddkdominio() / ', lr_param.cponom, '/'
                                               , lr_param.cpocod
       display l_log
    end if
 else
    let lr_retorno.erro = 1
 end if
 close c_cty11g00_003

 return lr_retorno.*

end function
