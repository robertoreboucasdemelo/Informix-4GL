#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Central 24h                                                #
# Modulo.........: cts10g09                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 189790                                                     #
#                  Modulo para registrar os dados do prestador.               #
# ........................................................................... #
# Desenvolvimento: Vinicius, Meta                                             #
# Liberacao......: 11/04/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_prepare smallint

#-------------------------#
function cts10g09_prepare()
#-------------------------#

 define l_sql    char(500)

 let l_sql = 'update datmservico '
            ,'   set socvclcod = ?, '
            ,'       srrcoddig = ?, '
            ,'       srrltt    = ?, '
            ,'       srrlgt    = ? '
            ,' where atdsrvnum = ? '
            ,'   and atdsrvano = ? '
 prepare p_cts10g09_001 from l_sql

 let l_sql = 'update datmservico '
            ,'   set socvclcod = ?, '
            ,'       srrcoddig = ?, '
            ,'       srrltt    = ?, '
            ,'       srrlgt    = ?, '
            ,'       atdprvdat = ? '
            ,' where atdsrvnum = ? '
            ,'   and atdsrvano = ? '
 prepare p_cts10g09_002 from l_sql

 let l_sql = " update datmservico set ",
                        " (atdprscod, ",
                         " socvclcod, ",
                         " srrcoddig, ",
                         " c24nomctt, ",
                         " atdcstvlr, ",
                         " atdfnlflg, ",
                         " atdprvdat) = ",
                        " (?,?,?,?,?,?,?) ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "

 prepare p_cts10g09_003 from l_sql

 let l_sql = " update datmservico set ",
                        " (atdprscod, ",
                         " socvclcod, ",
                         " srrcoddig, ",
                         " c24nomctt, ",
                         " atdfnlhor, ",
                         " c24opemat, ",
                         " cnldat, ",
                         " atdcstvlr, ",
                         " atdprvdat, ",
                         " atdfnlflg) = ",
                        " (?,?,?,?,?,?,?,?,?,?) ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "

 prepare p_cts10g09_004 from l_sql

 let l_sql = " update datmservico set ",
                         " (atdprscod, ",
                          " atdvclsgl, ",
                          " socvclcod, ",
                          " srrcoddig, ",
                          " c24nomctt, ",
                          " atdcstvlr, ",
                          " atdfnlflg, ",
                          " atdfnlhor, ",
                          " cnldat, ",
                          " atdprvdat) = ",
                         " (?,?,?,?,?,?,?,null,null,null) ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "

  prepare p_cts10g09_005 from l_sql

let l_sql = " update datmservico set ",
                       " (atdprscod, ",
                        " atdvclsgl, ",
                        " socvclcod, ",
                        " srrcoddig, ",
                        " c24nomctt, ",
                        " atdprvdat, ",
                        " atdcstvlr, ",
                        " atdfnlflg) = ",
                       " (?,?,?,?,?,?,?,?) ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

 prepare p_cts10g09_006 from l_sql

 let l_sql = " update datmservico set atdlibdat = ?, ",
                                    " atdlibhor = ?  ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "
 prepare p_cts10g09_007 from l_sql

 let l_sql = " update datmservico set atdfnlflg = ? ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "
 prepare p_cts10g09_008 from l_sql

 let m_prepare = true

end function

#---------------------------------------------#
function cts10g09_registrar_prestador(lr_param)
#---------------------------------------------#

 define lr_param       record
        nivel_retorno  smallint
       ,atdsrvnum      like datmservico.atdsrvnum
       ,atdsrvano      like datmservico.atdsrvano
       ,socvclcod      like datmservico.socvclcod
       ,srrcoddig      like datmservico.srrcoddig
       ,srrltt         like datmservico.srrltt
       ,srrlgt         like datmservico.srrlgt
       ,atdprvdat      like datmservico.atdprvdat
 end record

 define l_resultado    smallint
       ,l_mensagem     char(60)

 let l_resultado = 1
 let l_mensagem = null

 if lr_param.nivel_retorno is null or
    lr_param.atdsrvnum is null or
    lr_param.atdsrvano is null then
    let l_mensagem = "Dados do servico nao podem ser nulos"
    let l_resultado = 2
    return l_resultado, l_mensagem
 end if

 if lr_param.nivel_retorno > 2 then
    let l_mensagem = "Nivel de retorno incorreto"
    let l_resultado = 2
    return l_resultado, l_mensagem
 end if

 if m_prepare is null or
    m_prepare <> true then
    call cts10g09_prepare()
 end if

 if lr_param.nivel_retorno = 1 then
    whenever error continue
    execute p_cts10g09_001 using lr_param.socvclcod, lr_param.srrcoddig,
                               lr_param.srrltt,    lr_param.srrlgt,
                               lr_param.atdsrvnum, lr_param.atdsrvano
    whenever error stop

    if sqlca.sqlcode <> 0 then
       let l_resultado = 2
       let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datmdervico'
    end if
 else
    whenever error continue
    execute p_cts10g09_002 using lr_param.socvclcod, lr_param.srrcoddig,
                               lr_param.srrltt,    lr_param.srrlgt,
                               lr_param.atdprvdat, lr_param.atdsrvnum,
                               lr_param.atdsrvano
    whenever error stop

    if sqlca.sqlcode <> 0 then
       let l_resultado = 2
       let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datmdervico'
    end if
 end if

 #call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,lr_param.atdsrvano)

 return l_resultado, l_mensagem

end function

#===============================================#
function cts10g09_alt_dados_servico(lr_parametro)
#===============================================#

  define lr_parametro           record
         atdetptipcod           like datketapa.atdetptipcod,
         atdetptipcod_anterior  like datketapa.atdetptipcod,
         atdsrvnum              like datmservico.atdsrvnum,
         atdsrvano              like datmservico.atdsrvano,
         atdprscod              like datmservico.atdprscod,
         socvclcod              like datmservico.socvclcod,
         srrcoddig              like datmservico.srrcoddig,
         c24nomctt              like datmservico.c24nomctt,
         atdcstvlr              like datmservico.atdcstvlr,
         atdfnlflg              like datmservico.atdfnlflg,
         atdprvdat              like datmservico.atdprvdat,
         horaatu                like datmservico.atdfnlhor,
         funmat                 like datmservico.funmat,
         dataatu                like datmservico.cnldat,
         atdvclsgl              like datmservico.atdvclsgl,
         atdsrvnum_original     like datmservico.atdsrvnum,
         atdsrvano_original     like datmservico.atdsrvano,
         atdetpcod              like datketapa.atdetpcod
  end record

  define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
  end record

  if m_prepare is null or
     m_prepare <> true then
     call cts10g09_prepare()
  end if

  initialize lr_retorno.*  to  null

  #=================================================================#
  # NAO HA ALTERACAO DE ETAPA OU ALTERACAO POR ETAPA DO MESMO GRUPO #
  #=================================================================#
  if lr_parametro.atdetptipcod = lr_parametro.atdetptipcod_anterior then

     call cts40g12_problema(lr_parametro.atdsrvnum,
                            lr_parametro.atdsrvano,
                            lr_parametro.atdfnlflg,
                            "cts10g09.4gl",
                            "cts10g09_alt_dados_servico()",
                            "pcts10g09016",
                            lr_parametro.funmat,
                            "A")

     whenever error continue
     execute p_cts10g09_003 using lr_parametro.atdprscod,
                                lr_parametro.socvclcod,
                                lr_parametro.srrcoddig,
                                lr_parametro.c24nomctt,
                                lr_parametro.atdcstvlr,
                                lr_parametro.atdfnlflg,
                                lr_parametro.atdprvdat,
                                lr_parametro.atdsrvnum,
                                lr_parametro.atdsrvano
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na atualizacao de datmservico"
        return lr_retorno.*
     end if

     call cts40g12_problema(lr_parametro.atdsrvnum,
                            lr_parametro.atdsrvano,
                            lr_parametro.atdfnlflg,
                            "cts10g09.4gl",
                            "cts10g09_alt_dados_servico()",
                            "pcts10g09016",
                            lr_parametro.funmat,
                            "D")

  else
     #=========================================#
     # ALTERACAO DE ETAPA DEVIDO A ACIONAMENTO #
     #=========================================#
     if lr_parametro.atdetptipcod_anterior < lr_parametro.atdetptipcod then

        call cts40g12_problema(lr_parametro.atdsrvnum,
                               lr_parametro.atdsrvano,
                               lr_parametro.atdfnlflg,
                               "cts10g09.4gl",
                               "cts10g09_alt_dados_servico()",
                               "pcts10g09017",
                               lr_parametro.funmat,
                               "A")

        whenever error continue
        execute p_cts10g09_004 using lr_parametro.atdprscod,
                                   lr_parametro.socvclcod,
                                   lr_parametro.srrcoddig,
                                   lr_parametro.c24nomctt,
                                   lr_parametro.horaatu,
                                   lr_parametro.funmat,
                                   lr_parametro.dataatu,
                                   lr_parametro.atdcstvlr,
                                   lr_parametro.atdprvdat,
                                   lr_parametro.atdfnlflg,
                                   lr_parametro.atdsrvnum,
                                   lr_parametro.atdsrvano
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na atualizacao de datmservico"
           return lr_retorno.*
        end if

        call cts40g12_problema(lr_parametro.atdsrvnum,
                               lr_parametro.atdsrvano,
                               lr_parametro.atdfnlflg,
                               "cts10g09.4gl",
                               "cts10g09_alt_dados_servico()",
                               "pcts10g09017",
                               lr_parametro.funmat,
                               "D")
     else
        #==========================================================#
        # ALTERACAO DE ETAPA DEVIDO A RE-LIBERACAO (DESCONCLUINDO) #
        #==========================================================#
        if lr_parametro.atdetptipcod = 1 then

           call cts40g12_problema(lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano,
                                  lr_parametro.atdfnlflg,
                                  "cts10g09.4gl",
                                  "cts10g09_alt_dados_servico()",
                                  "pcts10g09018",
                                  lr_parametro.funmat,
                                  "A")

           whenever error continue
           execute p_cts10g09_005 using lr_parametro.atdprscod,
                                      lr_parametro.atdvclsgl,
                                      lr_parametro.socvclcod,
                                      lr_parametro.srrcoddig,
                                      lr_parametro.c24nomctt,
                                      lr_parametro.atdcstvlr,
                                      lr_parametro.atdfnlflg,
                                      lr_parametro.atdsrvnum,
                                      lr_parametro.atdsrvano
           whenever error stop
           if sqlca.sqlcode <> 0 then
              let lr_retorno.resultado = 2
              let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na atualizacao de datmservico"
              return lr_retorno.*
           end if

           call cts40g12_problema(lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano,
                                  lr_parametro.atdfnlflg,
                                  "cts10g09.4gl",
                                  "cts10g09_alt_dados_servico()",
                                  "pcts10g09018",
                                  lr_parametro.funmat,
                                  "D")
        else

           call cts40g12_problema(lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano,
                                  lr_parametro.atdfnlflg,
                                  "cts10g09.4gl",
                                  "cts10g09_alt_dados_servico()",
                                  "pcts10g09019",
                                  lr_parametro.funmat,
                                  "A")

           whenever error continue
           execute p_cts10g09_006 using lr_parametro.atdprscod,
                                      lr_parametro.atdvclsgl,
                                      lr_parametro.socvclcod,
                                      lr_parametro.srrcoddig,
                                      lr_parametro.c24nomctt,
                                      lr_parametro.atdprvdat,
                                      lr_parametro.atdcstvlr,
                                      lr_parametro.atdfnlflg,
                                      lr_parametro.atdsrvnum,
                                      lr_parametro.atdsrvano
           whenever error stop
           if sqlca.sqlcode <> 0 then
              let lr_retorno.resultado = 2
              let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na atualizacao de datmservico"
              return lr_retorno.*
           end if

           call cts40g12_problema(lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano,
                                  lr_parametro.atdfnlflg,
                                  "cts10g09.4gl",
                                  "cts10g09_alt_dados_servico()",
                                  "pcts10g09019",
                                  lr_parametro.funmat,
                                  "D")
        end if
     end if
  end if

  if lr_parametro.atdsrvnum_original is not null and
     (lr_parametro.atdetpcod = 3 or lr_parametro.atdetpcod = 5 or lr_parametro.atdetpcod = 1) then

     call cts29g00_remover_multiplo(lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano)
          returning lr_retorno.*

     if lr_retorno.resultado = 3 then
        let lr_retorno.resultado = 2
        return lr_retorno.*
     end if
  end if

  let lr_retorno.resultado = 1
  let lr_retorno.mensagem  = null

  #call cts00g07_apos_grvlaudo(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)

  return lr_retorno.*

end function

#---------------------------------------------#
function cts10g09_alt_hora_lib(lr_parametro)
#---------------------------------------------#
  define lr_parametro   record
         atdsrvnum      like datmservico.atdsrvnum,
         atdsrvano      like datmservico.atdsrvano,
         data           like datmservico.atdlibdat,
         hora           like datmservico.atdlibhor
         end record

  define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
  end record

  initialize lr_retorno.* to null

  if m_prepare is null or
     m_prepare <> true then
     call cts10g09_prepare()
  end if

  whenever error continue
  execute p_cts10g09_007 using lr_parametro.data, lr_parametro.hora,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let lr_retorno.resultado = 2
     let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode,
                                " na atualizacao de datmservico"
  else
     let lr_retorno.resultado = 1
  end if

  return lr_retorno.*

end function

#---------------------------------------------#
function cts10g09_finaliza_srv(lr_parametro)
#---------------------------------------------#
  define lr_parametro   record
         atdsrvnum      like datmservico.atdsrvnum,
         atdsrvano      like datmservico.atdsrvano,
         atdfnlflg      like datmservico.atdfnlflg
         end record

  define lr_retorno             record
         resultado              smallint,
         mensagem               char(100)
  end record

  initialize lr_retorno.* to null

  if m_prepare is null or
     m_prepare <> true then
     call cts10g09_prepare()
  end if

  whenever error continue
  execute p_cts10g09_008 using lr_parametro.atdfnlflg,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let lr_retorno.resultado = 2
     let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode,
                                " na finalizacao de datmservico"
  else
     let lr_retorno.resultado = 1
  end if

  return lr_retorno.*

end function
