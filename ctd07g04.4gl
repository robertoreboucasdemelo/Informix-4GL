#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd07g04                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmsrvre            #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 08/02/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- --------------     ---------- -----------------------------------#
# 18/09/2007 Luiz Alberto, Meta PSI211982 Inclsao da funcao                   #
#                                         ctd07g04_insere_srvre               #
#-----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo     PSI219444 tratar na tabela datmsrvre os novos #
#                                         campos (lclnumseq / rmerscseq)      #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctd07g04_prep smallint

#---------------------------#
function ctd07g04_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select atdorgsrvnum, socntzcod  ",
                    "   from datmsrvre                ",
                    "  where atdsrvnum = ?            ",
                    "    and atdsrvano = ?            "
   prepare pctd07g04001 from l_sql_stmt
   declare cctd07g04001 cursor for pctd07g04001

   let l_sql_stmt = " insert into datmsrvre (atdsrvnum ",
                                         " ,atdsrvano ",
                                         " ,lclrsccod ",
                                         " ,orrdat ",
                                         " ,orrhor ",
                                         " ,sinntzcod ",
                                         " ,socntzcod ",
                                         " ,atdsrvretflg ",
                                         " ,atdorgsrvnum ",
                                         " ,atdorgsrvano ",
                                         " ,srvretmtvcod ",
                                         " ,sinvstnum ",
                                         " ,sinvstano ",
                                         " ,retprsmsmflg ",
                                         " ,lclnumseq ",
                                         " ,rmerscseq) ",
                                 " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare pctd07g04002 from l_sql_stmt

   let m_ctd07g04_prep = true

end function

#------- Identifica se o servico eh de retorno -------------------------------#
function ctd07g04_srv_ret(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)
         ,l_atdorgsrvnum     like datmsrvre.atdorgsrvnum
         ,l_socntzcod        like datmsrvre.socntzcod

   if m_ctd07g04_prep is null or
      m_ctd07g04_prep <> true then
      call ctd07g04_prepare()
   end if

   let l_resultado = 1
   initialize l_mensagem     to null
   initialize l_atdorgsrvnum to null
   initialize l_socntzcod    to null

   open cctd07g04001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd07g04001 into l_atdorgsrvnum, l_socntzcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados do servico nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em cctd07g04001: ", sqlca.sqlcode
      end if
   else
      if l_atdorgsrvnum is null then
        let l_resultado = 2
        let l_mensagem = "Servico nao e de retorno"
      end if
   end if

   close cctd07g04001

   return l_resultado, l_mensagem

end function

#----------Insere os dados de servicos de RE ----------#
function ctd07g04_insere_srvre(lr_param)
#------------------------------------------------------#

   define lr_param         record
          atdsrvnum        like datmsrvre.atdsrvnum
         ,atdsrvano        like datmsrvre.atdsrvano
         ,lclrsccod        like datmsrvre.lclrsccod
         ,orrdat           like datmsrvre.orrdat
         ,orrhor           like datmsrvre.orrhor
         ,sinntzcod        like datmsrvre.sinntzcod
         ,socntzcod        like datmsrvre.socntzcod
         ,atdsrvretflg     like datmsrvre.atdsrvretflg
         ,atdorgsrvnum     like datmsrvre.atdorgsrvnum
         ,atdorgsrvano     like datmsrvre.atdorgsrvano
         ,srvretmtvcod     like datmsrvre.srvretmtvcod
         ,sinvstnum        like datmsrvre.sinvstnum
         ,sinvstano        like datmsrvre.sinvstano
         ,retprsmsmflg     like datmsrvre.retprsmsmflg
         ,lclnumseq        like datmsrvre.lclnumseq
         ,rmerscseq        like datmsrvre.rmerscseq
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   if m_ctd07g04_prep is null or
      m_ctd07g04_prep <> true then
      call ctd07g04_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   whenever error continue
   execute pctd07g04002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.lclrsccod
                          ,lr_param.orrdat
                          ,lr_param.orrhor
                          ,lr_param.sinntzcod
                          ,lr_param.socntzcod
                          ,lr_param.atdsrvretflg
                          ,lr_param.atdorgsrvnum
                          ,lr_param.atdorgsrvano
                          ,lr_param.srvretmtvcod
                          ,lr_param.sinvstnum
                          ,lr_param.sinvstano
                          ,lr_param.retprsmsmflg
                          ,lr_param.lclnumseq
                          ,lr_param.rmerscseq
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem = "Erro " , sqlca.sqlcode, " na inclusao do servico RE"
   end if

   return l_resultado, l_mensagem

end function

#------- Seleciona dados de datmsrvre  ---------------------------------------#
function ctd07g04_sel_re(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)
         ,l_socntzcod        like datmsrvre.socntzcod
         ,l_atdorgsrvnum     like datmsrvre.atdorgsrvnum

   if m_ctd07g04_prep is null or
      m_ctd07g04_prep <> true then
      call ctd07g04_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null
   let l_socntzcod = null
   let l_atdorgsrvnum = null

   open cctd07g04001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd07g04001 into l_atdorgsrvnum, l_socntzcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados da selecao do servico nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao em cctd07g04001: ", sqlca.sqlcode
      end if
   end if

   close cctd07g04001

   if lr_param.nivel_retorno = 1 then
      return l_resultado, l_mensagem, l_socntzcod
   end if

end function