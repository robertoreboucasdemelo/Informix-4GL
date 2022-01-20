#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd07g00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmservico          #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 15/01/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 19/09/2007 Luiz Alberto, Meta PSI211982 Inclusao das funcoes                #
#                                        ctd07g00_alt_agend, ctd07g00_alt_srv #
# 20/07/2009 Fabio Costa  PSI 198404  Inclusao das funcoes                    #
#                                     ctd07g00_upd_srv_pgtdat e               #
#                                     ctd07g00_upd_srv_opg                    #
# 15/01/2010 Fabio Costa  PSI 246174  Funcao ctd07g00_upd_acndat              #
#-----------------------------------------------------------------------------#
database porto

define m_ctd07g00_prep smallint

#---------------------------#
function ptd07g00_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = "update datmservico set atdhorpvt = ? ",
                                         " ,atddatprg = ? ",
                                         " ,atdhorprg = ? ",
                                         " ,atdpvtretflg = ? ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? "

   prepare pctd07g00001 from l_sql_stmt

   let l_sql_stmt = "update datmservico set nom = ? ",
                                         " ,atdlibflg = ? ",
                                         " ,prslocflg = ? ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? "

   prepare pctd07g00002 from l_sql_stmt

   let l_sql_stmt = "select atddatprg, ",
                          " atdhorprg, ",
                          " atdsrvorg ",
                     " from datmservico ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "

   prepare pctd07g00003 from l_sql_stmt
   declare cctd07g00003 cursor for pctd07g00003

   let l_sql_stmt = "select atdlibhor, ",
                          " atdlibdat ",
                      " from datmservico ",
                     " where atdsrvnum = ? ",
                       " and atdsrvano = ? "

   prepare pctd07g00004 from l_sql_stmt
   declare cctd07g00004 cursor for pctd07g00004

   let l_sql_stmt = " update datmservico set pgtdat    = ? ",
                                         " , atdcstvlr = ? ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "
   prepare pctd07g00005 from l_sql_stmt

   let l_sql_stmt = " update datmservico set pgtdat = ? ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "
   prepare pctd07g00006 from l_sql_stmt

   let l_sql_stmt = " update datmservico set srvprsacnhordat = ? ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "
   prepare pctd07g00007 from l_sql_stmt

   let l_sql_stmt = " update datmservico set atdfnlflg = ? ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "
   prepare pctd07g00008 from l_sql_stmt

   let m_ctd07g00_prep = true

end function

#------Altera os dados do agendamento do servico--------#
function ctd07g00_alt_agend(lr_param)
#-------------------------------------------------------#

   define lr_param         record
          atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
         ,atdhorpvt        like datmservico.atdhorpvt
         ,atddatprg        like datmservico.atddatprg
         ,atdhorprg        like datmservico.atdhorprg
         ,atdpvtretflg     like datmservico.atdpvtretflg
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true then
      call ptd07g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   whenever error continue
   execute pctd07g00001 using lr_param.atdhorpvt
                             ,lr_param.atddatprg
                             ,lr_param.atdhorprg
                             ,lr_param.atdpvtretflg
                             ,lr_param.atdsrvnum
                             ,lr_param.atdsrvano
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem = "Erro na atualizacao do agendamento"
   end if

   return l_resultado, l_mensagem

end function

#------Altera alguns dados do servico--------#
function ctd07g00_alt_srv(lr_param)
#--------------------------------------------#

   define lr_param         record
          atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
         ,nom              like datmservico.nom
         ,atdlibflg        like datmservico.atdlibflg
         ,prslocflg        like datmservico.prslocflg
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true then
      call ptd07g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   whenever error continue
   execute pctd07g00002 using lr_param.nom
                             ,lr_param.atdlibflg
                             ,lr_param.prslocflg
                             ,lr_param.atdsrvnum
                             ,lr_param.atdsrvano
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem = "Erro na atualizacao do agendamento"
   end if

   return l_resultado, l_mensagem

end function

#----------------------------------------#
function ctd07g00_alt_hora_acn(lr_param)
#----------------------------------------#

   define lr_param         record
                              atdsrvnum        like datmservico.atdsrvnum,
                              atdsrvano        like datmservico.atdsrvano
                           end record

   define lr_ctd07g00      record
                              atddat    like datmservico.atddatprg,
                              atdhor    like datmservico.atdhorprg,
                              atdsrvorg like datmservico.atdsrvorg
                           end record

   define l_resultado    smallint,
          l_mensagem     char(30),
          l_acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
          l_netacnflg    like datkatmacnprt.netacnflg,
          l_atmacnprtcod like datkatmacnprt.atmacnprtcod,
          l_prg          smallint,
          l_tmpacn       interval hour to minute,
          l_tmpacn2      datetime hour to minute,
          l_datstr       char(20),
          l_data         datetime year to second,
          l_erro         integer,
          l_msg          char(20),
          l_aux          char(10)

   initialize lr_ctd07g00 to null
   let l_prg = true
   let l_tmpacn = null

   call ptd07g00_prepare()

   open cctd07g00003 using lr_param.atdsrvnum,
                           lr_param.atdsrvano
   fetch cctd07g00003 into lr_ctd07g00.atddat,
                           lr_ctd07g00.atdhor,
                           lr_ctd07g00.atdsrvorg

   if  lr_ctd07g00.atdhor is null or
       lr_ctd07g00.atdhor = " " then
       let lr_ctd07g00.atdhor = "00:00"
   end if


   if  lr_ctd07g00.atddat is null or lr_ctd07g00.atddat = " " then

       open cctd07g00004 using lr_param.atdsrvnum,
                               lr_param.atdsrvano
       fetch cctd07g00004 into lr_ctd07g00.atdhor,
                               lr_ctd07g00.atddat

       let l_prg = false

   end if

   let l_datstr = year(lr_ctd07g00.atddat)  using "&&&&"  , "-",
                  month(lr_ctd07g00.atddat) using "&&"    , "-",
                  day(lr_ctd07g00.atddat)   using "&&"    , " ",
                  extend(lr_ctd07g00.atdhor, hour to hour)     clipped, ":",
                  extend(lr_ctd07g00.atdhor, minute to minute) clipped, ":00"

   let l_data = l_datstr

   if  l_prg then

       call cts47g00_verif_tmp(lr_param.atdsrvnum,
                               lr_param.atdsrvano,
                               "ACIONA")
            returning l_tmpacn,
                      l_erro,
                      l_msg

       let l_data = l_data - l_tmpacn

   end if

 whenever error continue
   update datmservico
      set srvprsacnhordat = l_data
    where atdsrvnum = lr_param.atdsrvnum
      and atdsrvano = lr_param.atdsrvano
 whenever error stop

end function

# Update de dados do pagamento no servico
#----------------------------------------------------------------
function ctd07g00_upd_srv_opg(lr_param)
#----------------------------------------------------------------

   define lr_param record
          pgtdat     like datmservico.pgtdat
         ,atdcstvlr  like datmservico.atdcstvlr
         ,atdsrvnum  like datmservico.atdsrvnum
         ,atdsrvano  like datmservico.atdsrvano
   end record
   
   define lr_erro record
      codigo   smallint,
      mensagem char(200)
   end record

   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true
      then
      call ptd07g00_prepare()
   end if

   whenever error continue
   execute pctd07g00005 using lr_param.pgtdat
                            , lr_param.atdcstvlr
                            , lr_param.atdsrvnum
                            , lr_param.atdsrvano
   let lr_erro.codigo   = sqlca.sqlcode
   let lr_erro.mensagem = sqlca.sqlerrd[3]
   whenever error stop
   ### REMOVIDO PARA NAO ENVIAR O SERVICO PARA O ACIONAMENTOWEB
   #if lr_erro.codigo = 0 then
   #   call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,lr_param.atdsrvano)
   #end if 

   return lr_erro.codigo, lr_erro.mensagem clipped

end function

#----------------------------------------------------------------
function ctd07g00_upd_srv_pgtdat(lr_param)
#----------------------------------------------------------------

   define lr_param record
          pgtdat     like datmservico.pgtdat
         ,atdsrvnum  like datmservico.atdsrvnum
         ,atdsrvano  like datmservico.atdsrvano
   end record

   define lr_erro record
      codigo   smallint,
      mensagem char(200)
   end record   
   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true
      then
      call ptd07g00_prepare()
   end if

   whenever error continue
   execute pctd07g00006 using lr_param.pgtdat
                            , lr_param.atdsrvnum
                            , lr_param.atdsrvano
   let lr_erro.codigo   = sqlca.sqlcode
   let lr_erro.mensagem = sqlca.sqlerrd[3]
   whenever error stop
   if lr_erro.codigo = 0 then
      call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,lr_param.atdsrvano)
   end if 

   return lr_erro.codigo, lr_erro.mensagem clipped

end function

#----------------------------------------------------------------
function ctd07g00_upd_acndat(lr_param)
#----------------------------------------------------------------

   define lr_param record
          srvprsacnhordat  like datmservico.srvprsacnhordat,
          atdsrvnum        like datmservico.atdsrvnum      ,
          atdsrvano        like datmservico.atdsrvano
   end record
   
   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true
      then
      call ptd07g00_prepare()
   end if
   
   whenever error continue
   execute pctd07g00007 using lr_param.srvprsacnhordat
                            , lr_param.atdsrvnum
                            , lr_param.atdsrvano
   whenever error stop

   return sqlca.sqlcode, sqlca.sqlerrd[3]

end function

#----------------------------------------------------------------
function ctd07g00_upd_atdfnlflg(lr_param)
#----------------------------------------------------------------

   define lr_param record
          atdsrvnum        like datmservico.atdsrvnum,
          atdsrvano        like datmservico.atdsrvano,
          atdfnlflg        like datmservico.atdfnlflg 
   end record
   
   if m_ctd07g00_prep is null or
      m_ctd07g00_prep <> true
      then
      call ptd07g00_prepare()
   end if
   
   whenever error continue
   execute pctd07g00008 using lr_param.atdfnlflg
                            , lr_param.atdsrvnum
                            , lr_param.atdsrvano
   whenever error stop

   return sqlca.sqlcode

end function
