#==============================================================================#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cts10g06                                                     #
# Analista Resp : Ligia Mattge                                                 #
# PSI           : 186.414                                                      #
# OSF           : 37.940                                                       #
#                 Obter Origem do Servico                                      #
# .............................................................................#
# Desenvolvimento : James R. Moreira, Meta                                     #
# Liberacao       : 21/07/2004                                                 #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 21/12/2004 Daniel, Meta      PSI187887  Inclusao da funcoes  cts10g06_dados  #
#                                         _servicos e cts10g06_assunto_servico #
#                                         Inibicao da funcao cts10g06_origem   #
#                                                                              #
# 03/03/2005 Adriano, Meta     PSI190772  Inclusao e tratamento de parametro   #
#                                         nivel_retorno na funcao              #
#                                         cts10g06_dados_servicos              #
#                                                                              #
# 08/04/2005 Vinicius, Meta    PSI189790  Implementar nivel de retorno = 4     #
# ---------- ----------------- ---------- -------------------------------------#
# 16/02/2006 Alinne, Meta      PSI196878  Implementar de nivel de retorno 5 e 6#
#------------------------------------------------------------------------------#
# 08/11/2006 Ligia Mattge      PSI202363  Implementar de nivel de retorno 9    #
# 17/11/2006 Ligia Mattge      PSI 205206 ciaempcod                            #
#------------------------------------------------------------------------------#
# 29/09/2007 Luiz Alberto,Meta PSI21198   Implementar nivel de retorno 12 e 13 #
# 30/06/2008 Ligia Mattge      PSI198404  Implementar nivel de retorno 20      #
# 28/01/2009 Adriano Santos    PSI235849  Implementar nivel de retorno 19      #
#------------------------------------------------------------------------------#

database porto

define m_prep_sql  smallint

#--------------------------#
function cts10g06_prepare()
#--------------------------#

  define l_sql char(400)

  let l_sql = ' select atdsrvorg '
                   ,' ,atddat '
                   ,' ,atdprscod '
                   ,' ,atddfttxt '
                   ,' ,atdfnlflg '
                   ,' ,atdhor    '
                   ,' ,nom       '
                   ,' ,atdhorpvt '
                   ,' ,asitipcod '
                   ,' ,atdprvdat '
                   ,' ,c24opemat '
                   ,' ,atdlibhor '
                   ,' ,atdlibdat '
                   ,' ,atddatprg '
                   ,' ,atdhorprg '
                   ,' ,ciaempcod '
                   ,' ,acnnaomtv '
                   ,' ,c24solnom '
                   ,' ,atdlibflg '
                   ,' ,prslocflg '
                   ,' ,atdpvtretflg '
                   ,' ,empcod '
                   ,' ,funmat '
                   ,' ,usrtip '
                   ,' ,srvprsacnhordat '
                   ,' ,vclcoddig '
               ,' from datmservico '
              ,' where atdsrvnum = ? '
                ,' and atdsrvano = ? '

  prepare p_cts10g06_001  from l_sql
  declare c_cts10g06_001  cursor for p_cts10g06_001

  let l_sql = " select c24astcod, ",
                     " c24funmat, ",
                     " c24empcod ",
                " from datmligacao ",
               " where lignum = ? "

  prepare p_cts10g06_002  from l_sql
  declare c_cts10g06_002  cursor for p_cts10g06_002

  let m_prep_sql = true

end function

#-----------------------------------------#
function cts10g06_dados_servicos(lr_param)
#-----------------------------------------#

 define lr_param     record
    nivel_retorno    smallint
   ,atdsrvnum        like datmservico.atdsrvnum
   ,atdsrvano        like datmservico.atdsrvano
 end record

 define l_resultado        smallint
       ,l_mensagem         char(60)

 define lr_retorno record
        atdsrvorg    like datmservico.atdsrvorg
       ,atddat       like datmservico.atddat
       ,atdprscod    like datmservico.atdprscod
       ,atddfttxt    like datmservico.atddfttxt
       ,atdfnlflg    like datmservico.atdfnlflg
       ,atdhor       like datmservico.atdhor
       ,nom          like datmservico.nom
       ,atdhorpvt    like datmservico.atdhorpvt
       ,asitipcod    like datmservico.asitipcod
       ,atdprvdat    like datmservico.atdprvdat
       ,c24opemat    like datmservico.c24opemat
       ,atdlibhor    like datmservico.atdlibhor
       ,atdlibdat    like datmservico.atdlibdat
       ,atddatprg    like datmservico.atddatprg
       ,atdhorprg    like datmservico.atdhorprg
       ,ciaempcod    like datmservico.ciaempcod
       ,acnnaomtv    like datmservico.acnnaomtv
       ,c24solnom    like datmservico.c24solnom
       ,atdlibflg    like datmservico.atdlibflg
       ,prslocflg    like datmservico.prslocflg
       ,atdpvtretflg like datmservico.atdpvtretflg
       ,empcod       like datmservico.empcod
       ,funmat       like datmservico.funmat
       ,usrtip       like datmservico.usrtip
       ,srvprsacnhordat   like datmservico.srvprsacnhordat
       ,vclcoddig    like datmservico.vclcoddig
 end record

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts10g06_prepare()
 end if

 initialize lr_retorno to null

 let l_resultado = 1
 let l_mensagem = null

 if lr_param.nivel_retorno is null or
    lr_param.atdsrvnum is null or
    lr_param.atdsrvano is null then
    let l_resultado = 3
    let l_mensagem = "Dados do servico nao podem ser nulos"
    case lr_param.nivel_retorno
       when 1
         let lr_retorno.atdsrvorg = null
         let lr_retorno.atddat    = null
         return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atddat
       when 2
         let lr_retorno.atdsrvorg = null
         let lr_retorno.atdprscod = null
         return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atdprscod
       when 3
         let lr_retorno.atddfttxt = null
         return l_resultado, l_mensagem, lr_retorno.atddfttxt
       when 4
         let lr_retorno.atdfnlflg = null
         return l_resultado, l_mensagem, lr_retorno.atdfnlflg
       when 5
          let lr_retorno.atdsrvorg = null
          let lr_retorno.atddat    = null
          let lr_retorno.atdhor    = null
          let lr_retorno.nom       = null
          let lr_retorno.atdfnlflg = null
          return l_resultado, l_mensagem, lr_retorno.atdsrvorg
               , lr_retorno.atddat, lr_retorno.atdhor
                ,lr_retorno.nom, lr_retorno.atdfnlflg
       when 6
          let lr_retorno.atdhorpvt = null
          let lr_retorno.atdsrvorg = null
          let lr_retorno.asitipcod = null
          return l_resultado, l_mensagem, lr_retorno.atdhorpvt
               , lr_retorno.atdsrvorg, lr_retorno.asitipcod
       when 12
          let lr_retorno.c24solnom = null
          let lr_retorno.nom       = null
          let lr_retorno.asitipcod = null
          let lr_retorno.atdlibflg = null
          let lr_retorno.prslocflg = null
       when 13
          let lr_retorno.atdfnlflg    = null
          let lr_retorno.atdhorpvt    = null
          let lr_retorno.atddatprg    = null
          let lr_retorno.atdhorprg    = null
          let lr_retorno.atdpvtretflg = null
       when 14
          let lr_retorno.atddat       = null
          let lr_retorno.atdhor       = null
          let lr_retorno.empcod       = null
          let lr_retorno.funmat       = null
          let lr_retorno.usrtip       = null
          let lr_retorno.atdlibdat    = null
          let lr_retorno.atdlibhor    = null
       when 19
          let lr_retorno.atdlibhor       = null
          let lr_retorno.atddatprg       = null
          let lr_retorno.acnnaomtv       = null
          let lr_retorno.srvprsacnhordat = null
          let lr_retorno.atdlibdat       = null
          let lr_retorno.atdhorprg       = null
          let lr_retorno.atdfnlflg       = null
          let lr_retorno.atdsrvorg       = null
          return l_resultado, l_mensagem,
                 lr_retorno.atdlibhor, lr_retorno.atdlibdat,
                 lr_retorno.atddatprg, lr_retorno.atdhorprg,
                 lr_retorno.acnnaomtv, lr_retorno.atdfnlflg,
                 lr_retorno.srvprsacnhordat, lr_retorno.atdsrvorg
    end case
 end if

 open c_cts10g06_001 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch c_cts10g06_001 into lr_retorno.*
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let l_resultado = 2
       let l_mensagem = "Dados do servico nao encontrado"
    else
       let l_resultado = 3
       let l_mensagem = " Erro de SELECT - c_cts10g06_001 ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]
       call errorlog(l_mensagem)
       let l_mensagem = " cts10g06_dados_servicos() / ",lr_param.atdsrvnum, " / "
                                                       ,lr_param.atdsrvano
       call errorlog(l_mensagem)
       let l_mensagem = "Erro ", sqlca.sqlcode, " em datmservico"
    end if
 end if
 case lr_param.nivel_retorno
   when 1
      return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atddat
   when 2
      return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atdprscod
   when 3
      return l_resultado, l_mensagem, lr_retorno.atddfttxt
   when 4
      return l_resultado, l_mensagem, lr_retorno.atdfnlflg
   when 5
      return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atddat
            , lr_retorno.atdhor
            ,lr_retorno.nom, lr_retorno.atdfnlflg
   when 6
      return l_resultado, l_mensagem, lr_retorno.atdhorpvt, lr_retorno.atdsrvorg
           , lr_retorno.asitipcod
   when 7
      return l_resultado, l_mensagem, lr_retorno.atdprvdat
   when 8
      return l_resultado, l_mensagem, lr_retorno.c24opemat
   when 9
      return l_resultado, l_mensagem,
             lr_retorno.atdlibhor, lr_retorno.atdlibdat,
             lr_retorno.atddatprg, lr_retorno.atdhorprg,
             lr_retorno.acnnaomtv, lr_retorno.atdfnlflg
   when 10
      return l_resultado, l_mensagem, lr_retorno.ciaempcod
   when 11
      return l_resultado, l_mensagem, lr_retorno.atdhorpvt, lr_retorno.atdsrvorg
           , lr_retorno.asitipcod, lr_retorno.ciaempcod
   when 12
      return l_resultado, l_mensagem, lr_retorno.c24solnom, lr_retorno.nom
           , lr_retorno.asitipcod, lr_retorno.atdlibflg, lr_retorno.prslocflg
   when 13
      return l_resultado, l_mensagem, lr_retorno.atdfnlflg, lr_retorno.atdhorpvt
            ,lr_retorno.atddatprg, lr_retorno.atdhorprg, lr_retorno.atdpvtretflg
   when 14
      return l_resultado
            ,l_mensagem
            ,lr_retorno.atddat
            ,lr_retorno.atdhor
            ,lr_retorno.empcod
            ,lr_retorno.funmat
            ,lr_retorno.usrtip
            ,lr_retorno.atdlibdat
            ,lr_retorno.atdlibhor
   when 15
      return l_resultado, l_mensagem, lr_retorno.atdlibhor,
             lr_retorno.atdhorprg, lr_retorno.atdprvdat
   when 16
      return l_resultado, l_mensagem,
             lr_retorno.atdlibhor, lr_retorno.atdlibdat,
             lr_retorno.atddatprg, lr_retorno.atdhorprg,
             lr_retorno.acnnaomtv, lr_retorno.atdfnlflg,
             lr_retorno.srvprsacnhordat
   when 17
      return l_resultado, l_mensagem, lr_retorno.vclcoddig
   when 18
      return lr_retorno.srvprsacnhordat, lr_retorno.atdlibhor, lr_retorno.atdlibdat
   when 19 # PSI 235849 Adriano Santos 28/01/2009
      return l_resultado, l_mensagem,
             lr_retorno.atdlibhor, lr_retorno.atdlibdat,
             lr_retorno.atddatprg, lr_retorno.atdhorprg,
             lr_retorno.acnnaomtv, lr_retorno.atdfnlflg,
             lr_retorno.srvprsacnhordat, lr_retorno.atdsrvorg
   when 20
      return l_resultado, l_mensagem, lr_retorno.atdsrvorg, lr_retorno.atddat,
             lr_retorno.ciaempcod
 end case

end function

#--------------------------------#
function cts10g06_assunto_servico(lr_param)
#--------------------------------#

 define lr_param     record
    atdsrvnum        like datmservico.atdsrvnum
   ,atdsrvano        like datmservico.atdsrvano
 end record

 define lr_retorno   record
        resultado    smallint,
        mensagem     char(60),
        c24astcod    like datmligacao.c24astcod,
        c24funmat    like datmligacao.c24funmat,
        c24empcod    like datmligacao.c24empcod
 end record

 define l_lignum       like datmligacao.lignum


 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts10g06_prepare()
 end if

 let lr_retorno.resultado = 1
 let lr_retorno.mensagem = ""
 let lr_retorno.c24astcod = ""
 let l_lignum = ""

 if lr_param.atdsrvnum is null  or
    lr_param.atdsrvano is null then
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem = "Dados da ligacao nao podem ser nulos"
 else

    let l_lignum = cts20g00_servico(lr_param.atdsrvnum,lr_param.atdsrvano)

    if l_lignum is not null then

       open c_cts10g06_002 using l_lignum

       whenever error continue
       fetch c_cts10g06_002 into lr_retorno.c24astcod,
                               lr_retorno.c24funmat,
                               lr_retorno.c24empcod
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let lr_retorno.resultado = 2
             let lr_retorno.mensagem = "Ligacao nao encontrada"
          else
             let lr_retorno.resultado = 3
             let lr_retorno.mensagem = " Erro SELECT - c_cts10g06_002 ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]
             call errorlog(lr_retorno.mensagem)
             let lr_retorno.mensagem = " cts10g06 / cts10g06_assunto_servico() / ",lr_param.atdsrvnum, " / "
                                                                       ,lr_param.atdsrvano
             call errorlog(lr_retorno.mensagem)
             let lr_retorno.mensagem = "Erro ", sqlca.sqlcode, " em datmligacao"
          end if
       end if
    else
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem = "Ligacao nao encontrada"
    end if
 end if

 return lr_retorno.*

end function

##--------------------------------#
#function cts10g06_origem(lr_parm)
##--------------------------------#
#
# define lr_parm        record
#        atdsrvnum      like datmservico.atdsrvnum,
#        atdsrvano      like datmservico.atdsrvano
# end record
#
# define lr_retorno record
#       atdsrvorg  like datmservico.atdsrvorg
#      ,atddat     like datmservico.atddat
#      ,atdprscod  like datmservico.atdprscod
#      ,atddfttxt  like datmservico.atddfttxt
# end record
#
# define l_erro           smallint,
#        l_mensagem       char(70)
# #
# define l_msg            char(70)
#
# if m_prep_sql is null or m_prep_sql <> true then
#    call cts10g06_prepare()
# end if
#
# initialize lr_retorno to null
# let l_erro = null
# let l_mensagem = null
#
# if lr_parm.atdsrvnum is null or
#    lr_parm.atdsrvano is null then
#    let l_erro = 3
#    let l_mensagem = "Parametro nulo"
#    return l_erro, l_mensagem, lr_retorno.atdsrvorg
# end if
#
# open c_cts10g06_001  using lr_parm.atdsrvnum
#                         ,lr_parm.atdsrvano
# whenever error continue
# fetch c_cts10g06_001 into  lr_retorno.*
# whenever error stop
# if sqlca.sqlcode <> 0 then
#    if sqlca.sqlcode = notfound then
#       let l_erro = 2
#       let l_mensagem = "Ordem do servico nao encontrada "
#    else
#       let l_erro = 3
#       let l_msg = " Erro de SELECT - c_cts10g06_001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
#       let l_mensagem = "Erro <", sqlca.sqlcode, "> na consulta datmservico "
#       call errorlog(l_msg)
#       let l_msg = " cts10g06_origem() / ",lr_parm.atdsrvnum,"/",lr_parm.atdsrvano
#       call errorlog(l_msg)
#    end if
# else
#    let l_erro = 1
# end if
# close c_cts10g06_001
#
# return l_erro, l_mensagem, lr_retorno.atdsrvorg
#
#end function

