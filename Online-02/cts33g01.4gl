#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24H                                                #
# MODULO.........: CTS33G01                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  REGISTRAR POSICAO DA FROTA                                 #
# ........................................................................... #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts33g01_prep smallint

#-------------------------#
function cts33g01_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = " update dattfrotalocal set ",
                    " (atdvclpriflg, cttdat, ctthor, c24atvcod, atdsrvnum, atdsrvano) = ",
                    " (?,?,?,?,?,?) " ,
               " where socvclcod = ? "

  prepare p_cts33g01_001 from l_sql

  let l_sql = " update datmfrtpos set ",
                    " (ufdcod, cidnom, brrnom, endzon, lclltt, lcllgt) = ",
                    " (?,?,?,?,?,?) ",
               " where socvclcod = ? ",
                 " and socvcllcltip in (2,3) "

  prepare p_cts33g01_002 from l_sql

  let l_sql = " update datmfrtpos set ",
                    " (ufdcod, cidnom, brrnom, endzon, lclltt, lcllgt) = ",
                    " (?,?,?,?,?,?) ",
               " where socvclcod = ? ",
                 " and socvcllcltip = ? "

  prepare p_cts33g01_003 from l_sql

  let l_sql = " update datmservico set ",
                    " (atdprscod, socvclcod, srrcoddig, c24nomctt, atdfnlhor, ",
                     " c24opemat, cnldat, atdcstvlr, srrltt, srrlgt, atdprvdat, ",
                     " atdfnlflg, acntntqtd, acnsttflg, acnnaomtv) =  ",
                    " (?,?,?,?,?,?,?,?,?,?,?,'S',?,'S',null) ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts33g01_004 from l_sql

  let m_cts33g01_prep = true

end function

#-----------------------------------------------#
function cts33g01_alt_dados_automat(lr_parametro)
#-----------------------------------------------#

  define lr_parametro record
         atdprscod    like datmservico.atdprscod,
         socvclcod    like datmservico.socvclcod,
         srrcoddig    like datmservico.srrcoddig,
         c24nomctt    like datmservico.c24nomctt,
         c24opemat    like datmservico.c24opemat,
         atdcstvlr    like datmservico.atdcstvlr,
         srrltt       like datmservico.srrltt,
         srrlgt       like datmservico.srrlgt,
         atdprvdat    like datmservico.atdprvdat,
         acntntqtd    like datmservico.acntntqtd,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_msg_erro   char(300),
         l_data_atual date,
         l_hora_atual datetime hour to minute,
         l_retorno integer

  if m_cts33g01_prep is null or
     m_cts33g01_prep <> true then
     call cts33g01_prepare()
  end if

  let l_msg_erro   = null
  let l_data_atual = null
  let l_hora_atual = null
  let l_retorno    = 0

   # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)

       returning l_data_atual, l_hora_atual

  whenever error continue
  execute p_cts33g01_004 using lr_parametro.atdprscod,
                             lr_parametro.socvclcod,
                             lr_parametro.srrcoddig,
                             lr_parametro.c24nomctt,
                             l_hora_atual,
                             lr_parametro.c24opemat,
                             l_data_atual,
                             lr_parametro.atdcstvlr,
                             lr_parametro.srrltt,
                             lr_parametro.srrlgt,
                             lr_parametro.atdprvdat,
                             lr_parametro.acntntqtd,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop

  if sqlca.sqlcode  <>  0   then
     let l_retorno = sqlca.sqlcode
     let l_msg_erro = "Erro UPDATE p_cts33g01_004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg_erro)

     let l_msg_erro = "cts33g01_alt_dados_automat() / ", lr_parametro.atdprscod clipped, "/",
                                                        lr_parametro.socvclcod  clipped, "/",
                                                        lr_parametro.srrcoddig  clipped, "/",
                                                        lr_parametro.c24nomctt  clipped, "/",
                                                        l_hora_atual            clipped, "/",
                                                        lr_parametro.c24opemat  clipped, "/",
                                                        l_data_atual            clipped, "/",
                                                        lr_parametro.atdcstvlr  clipped, "/",
                                                        lr_parametro.srrltt     clipped, "/",
                                                        lr_parametro.srrlgt     clipped, "/",
                                                        lr_parametro.atdprvdat  clipped, "/",
                                                        lr_parametro.acntntqtd  clipped, "/",
                                                        lr_parametro.atdsrvnum  clipped, "/",
                                                        lr_parametro.atdsrvano
     call errorlog(l_msg_erro)
  else
    call cts00g07_apos_grvlaudo(lr_parametro.atdsrvnum,lr_parametro.atdsrvano)
    let l_retorno = 0
  end if

  return l_retorno

end function

#-------------------------------#
function cts33g01_posfrota(param)
#-------------------------------#

  define param         record
         socvclcod     like dattfrotalocal.socvclcod,
         atdvclpriflg  like dattfrotalocal.atdvclpriflg,
         ufdcod_1      like datmfrtpos.ufdcod,
         cidnom_1      like datmfrtpos.cidnom,
         brrnom_1      like datmfrtpos.brrnom,
         endzon_1      like datmfrtpos.endzon,
         lclltt_1      like datmfrtpos.lclltt,
         lcllgt_1      like datmfrtpos.lcllgt,
         ufdcod_2      like datmfrtpos.ufdcod,
         cidnom_2      like datmfrtpos.cidnom,
         brrnom_2      like datmfrtpos.brrnom,
         endzon_2      like datmfrtpos.endzon,
         lclltt_2      like datmfrtpos.lclltt,
         lcllgt_2      like datmfrtpos.lcllgt,
         cttdat        like dattfrotalocal.cttdat,
         ctthor        like dattfrotalocal.ctthor,
         c24atvcod     like dattfrotalocal.c24atvcod,
         atdsrvnum     like dattfrotalocal.atdsrvnum,
         atdsrvano     like dattfrotalocal.atdsrvano
  end record

  define l_nulo         char(01),
         l_socvcllcltip like datmfrtpos.socvcllcltip,
         l_msg_erro     char(300)

  if m_cts33g01_prep is null or
     m_cts33g01_prep <> true then
     call cts33g01_prepare()
  end if

  let l_msg_erro = null

  whenever error continue
  execute p_cts33g01_001 using param.atdvclpriflg,
                             param.cttdat,
                             param.ctthor,
                             param.c24atvcod,
                             param.atdsrvnum,
                             param.atdsrvano,
                             param.socvclcod
  whenever error stop

  if sqlca.sqlcode  <>  0   then
     let l_msg_erro = "Erro UPDATE p_cts33g01_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg_erro)

     let l_msg_erro = "cts33g01_posfrota() / ", param.atdvclpriflg clipped, "/",
                                                param.cttdat       clipped, "/",
                                                param.ctthor       clipped, "/",
                                                param.c24atvcod    clipped, "/",
                                                param.atdsrvnum    clipped, "/",
                                                param.atdsrvano    clipped, "/",
                                                param.socvclcod
     call errorlog(l_msg_erro)
     return sqlca.sqlcode
  end if

  if param.atdvclpriflg = "S" then

     let l_nulo = null

     whenever error continue
     execute p_cts33g01_002 using l_nulo,
                                l_nulo,
                                l_nulo,
                                l_nulo,
                                l_nulo,
                                l_nulo,
                                param.socvclcod
     whenever error stop

     if sqlca.sqlcode  <>  0   then
        let l_msg_erro = "Erro UPDATE p_cts33g01_002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "cts33g01_posfrota() / ", param.socvclcod
        call errorlog(l_msg_erro)
        return sqlca.sqlcode
     end if

  end if

  if param.atdvclpriflg  =  "N"   then

     let l_socvcllcltip = 2  #--> Posicao QTH

     whenever error continue
     execute p_cts33g01_003 using param.ufdcod_1,
                                param.cidnom_1,
                                param.brrnom_1,
                                param.endzon_1,
                                param.lclltt_1,
                                param.lcllgt_1,
                                param.socvclcod,
                                l_socvcllcltip
     whenever error stop

     if sqlca.sqlcode  <>  0   then
        let l_msg_erro = "Erro UPDATE p_cts33g01_003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "cts33g01_posfrota() / ", param.ufdcod_1 clipped, "/",
                                                   param.cidnom_1 clipped, "/",
                                                   param.brrnom_1 clipped, "/",
                                                   param.endzon_1 clipped, "/",
                                                   param.lclltt_1 clipped, "/",
                                                   param.lcllgt_1 clipped, "/",
                                                   param.socvclcod clipped, "/",
                                                   l_socvcllcltip
        call errorlog(l_msg_erro)
        return sqlca.sqlcode
     end if

     let l_socvcllcltip = 3 #--> Posicao QTI

     whenever error continue
     execute p_cts33g01_003 using param.ufdcod_2,
                                param.cidnom_2,
                                param.brrnom_2,
                                param.endzon_2,
                                param.lclltt_2,
                                param.lcllgt_2,
                                param.socvclcod,
                                l_socvcllcltip
     whenever error stop

     if sqlca.sqlcode  <>  0   then
        let l_msg_erro = "Erro UPDATE p_cts33g01_003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "cts33g01_posfrota() / ", param.ufdcod_2 clipped, "/",
                                                   param.cidnom_2 clipped, "/",
                                                   param.brrnom_2 clipped, "/",
                                                   param.endzon_2 clipped, "/",
                                                   param.lclltt_2 clipped, "/",
                                                   param.lcllgt_2 clipped, "/",
                                                   param.socvclcod clipped, "/",
                                                   l_socvcllcltip
        call errorlog(l_msg_erro)
     end if

  end if

  return sqlca.sqlcode

end function
