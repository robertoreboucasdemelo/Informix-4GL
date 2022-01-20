#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : cty01g00                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Obter informacoes do sinistro.                             #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 19/07/2004                                                #
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
function cty01g00_prepare()
#--------------------------#
 define l_sql char(400)
 let l_sql = ' select succod '
                  ,' ,aplnumdig '
                  ,' ,itmnumdig '
              ,' from ssamavs '
             ,' where sinavsano = ? '
               ,' and sinavsnum = ? '
 prepare pcty01g00001 from l_sql
 declare ccty01g00001 cursor for pcty01g00001
 let l_sql = ' select succod '
                  ,' ,aplnumdig '
                  ,' ,itmnumdig '
                  ,' ,edsnumref '
              ,' from ssamsin '
             ,' where ramcod = ? '
               ,' and sinano = ? '
               ,' and sinnum = ? '
 prepare pcty01g00002 from l_sql
 declare ccty01g00002 cursor for pcty01g00002

 let l_sql = ' select vclcoddig '
                  ,' ,sinbemdes '
                  ,' ,vclanomdl '
                  ,' ,vcllicnum '
                  ,' ,bnfnom '
              ,' from ssamterc '
             ,' where ramcod = ? '
               ,' and sinano = ? '
               ,' and sinnum = ? '
 prepare pcty01g00003 from l_sql
 declare ccty01g00003 cursor for pcty01g00003
 let l_sql = ' select ramcod, sinnum, sinano ',
             ' from ssamsin ',
             ' where succod    = ? ',
               ' and aplnumdig = ? ',
               ' and itmnumdig = ? ',
               ' and orrdat    = ? '
 prepare pcty01g00004 from l_sql
 declare ccty01g00004 cursor for pcty01g00004
 let m_prep_sql = true
end function
#--------------------------------------------------------#
function cty01g00_apolice_aviso(l_sinavsnum, l_sinavsano)
#--------------------------------------------------------#
 define l_sinavsnum like ssamavs.sinavsnum
       ,l_sinavsano like ssamavs.sinavsano
       ,l_erro      char(80)
 define lr_retorno  record
        resultado   smallint
       ,mensagem    char(40)
       ,succod      like ssamavs.succod
       ,aplnumdig   like ssamavs.aplnumdig
       ,itmnumdig   like ssamavs.itmnumdig
 end record
 initialize lr_retorno.* to null

 if l_sinavsnum is null or
    l_sinavsano is null then
    let lr_retorno.mensagem = 'Sinistro nao deve ser nulo'
    let lr_retorno.resultado = 3
    return lr_retorno.*
 end if
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty01g00_prepare()
 end if
 open ccty01g00001 using l_sinavsano
                        ,l_sinavsnum
 whenever error continue
 fetch ccty01g00001 into lr_retorno.succod
                        ,lr_retorno.aplnumdig
                        ,lr_retorno.itmnumdig
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.mensagem = "Apolice nao encontrada"
       let lr_retorno.resultado = 2
    else
       let l_erro = ' Erro no SELECT ccty01g00001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = ' Funcao cty01g00_apolice_aviso() ', l_sinavsano, '/', l_sinavsnum
       call errorlog(l_erro)
       let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em ssamavs'
       let lr_retorno.resultado = 3
    end if
 else
    let lr_retorno.resultado = 1
 end if
 return lr_retorno.*
end function
#---------------------------------------------------------------#
function cty01g00_apolice_sinistro(l_ramcod, l_sinnum, l_sinano)
#---------------------------------------------------------------#
 define l_ramcod   like ssamsin.ramcod
       ,l_sinnum   like ssamsin.sinnum
       ,l_sinano   like ssamsin.sinano
       ,l_erro     char(80)
 define lr_retorno record
        resultado  smallint
       ,mensagem   char(40)
       ,succod     like ssamsin.succod
       ,aplnumdig  like ssamsin.aplnumdig
       ,itmnumdig  like ssamsin.itmnumdig
       ,edsnumref  like ssamsin.edsnumref
 end record
 initialize lr_retorno.* to null
 if l_ramcod is null or
    l_sinnum is null or
    l_sinano is null then
    let lr_retorno.mensagem = ' Sinistro nao deve ser nulo '
    let lr_retorno.resultado = 3
    return lr_retorno.*
 end if
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty01g00_prepare()
 end if
 open ccty01g00002 using l_ramcod
                        ,l_sinano
                        ,l_sinnum
 whenever error continue
 fetch ccty01g00002 into lr_retorno.succod
                        ,lr_retorno.aplnumdig
                        ,lr_retorno.itmnumdig
                        ,lr_retorno.edsnumref
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.mensagem = "Apolice nao encontrada"
       let lr_retorno.resultado = 2
    else
       let l_erro = ' Erro no SELECT ccty01g00002 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = ' Funcao cty01g00_apolice_sinistro() ', l_ramcod, '/'
                                                          , l_sinano, '/'
                                                          , l_sinnum
       call errorlog(l_erro)
       let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em ssamsin'
       let lr_retorno.resultado = 3
    end if
 else
    let lr_retorno.resultado = 1
 end if
 return lr_retorno.*
end function

#---------------------------------------------------------------#
function cty01g00_terceiro(l_ramcod, l_sinano, l_sinnum)
#---------------------------------------------------------------#
 define l_ramcod   like ssamsin.ramcod
       ,l_sinano   like ssamsin.sinano
       ,l_sinnum   like ssamsin.sinnum
       ,l_erro     char(80)
 define lr_retorno record
        resultado  smallint
       ,mensagem   char(40)
       ,vclcoddig  like ssamterc.vclcoddig
       ,sinbemdes  like ssamterc.sinbemdes
       ,vclanomdl  like ssamterc.vclanomdl
       ,vcllicnum  like ssamterc.vcllicnum
       ,bnfnom     like ssamterc.bnfnom
 end record
 initialize lr_retorno.* to null
 if l_ramcod is null or
    l_sinnum is null or
    l_sinano is null then
    let lr_retorno.mensagem = 'Sinistro nao deve ser nulo '
    let lr_retorno.resultado = 3
    return lr_retorno.*
 end if
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty01g00_prepare()
 end if
 open ccty01g00003 using l_ramcod
                        ,l_sinano
                        ,l_sinnum
 whenever error continue
 fetch ccty01g00003 into lr_retorno.vclcoddig
                        ,lr_retorno.sinbemdes
                        ,lr_retorno.vclanomdl
                        ,lr_retorno.vcllicnum
                        ,lr_retorno.bnfnom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.mensagem = "Aviso nao encontrado"
       let lr_retorno.resultado = 2
    else
       let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em ssamsin'
       let lr_retorno.resultado = 3
    end if
 else
    let lr_retorno.resultado = 1
 end if
 close ccty01g00003
 return lr_retorno.*
end function

#--------------------------------------------------------#
function cty01g00_sinistro_apl(lr_param)
#--------------------------------------------------------#
  define lr_param    record
         succod      like ssamsin.succod
        ,aplnumdig   like ssamsin.aplnumdig
        ,itmnumdig   like ssamsin.itmnumdig
        ,orrdat      like ssamsin.orrdat
  end record
  define lr_retorno  record
         resultado   smallint
        ,mensagem    char(40)
        ,ramcod      like ssamsin.ramcod
        ,sinnum      like ssamsin.sinnum
        ,sinano      like ssamsin.sinano
  end record
  initialize lr_retorno.* to null
  if m_prep_sql is null or
     m_prep_sql <> true then
     call cty01g00_prepare()
  end if
  whenever error continue
  open ccty01g00004 using lr_param.*
  fetch ccty01g00004 into lr_retorno.ramcod, lr_retorno.sinnum, lr_retorno.sinano
  whenever error stop
  let lr_retorno.resultado = sqlca.sqlcode
  close ccty01g00004
  if lr_retorno.resultado != 0
     then
     if lr_retorno.resultado = 100
        then
        let lr_retorno.mensagem = "Sinistro nao encontrado"
     else
        let lr_retorno.mensagem = 'Erro ao obter dados do SINISTRO: ',
                                  lr_retorno.resultado
     end if
  end if
  return lr_retorno.*
end function
