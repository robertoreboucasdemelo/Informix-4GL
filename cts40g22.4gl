#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: cts40g22                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  INSERE A ETAPA NUM SERVICO AUTO OU RE.                     #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 11/08/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 06/03/2008 Sergio Burini       218545 Incluir função padrao p/ inclusao     #
#                                       de etapas (cts10g04_insere_etapa()    #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts40g22_prep smallint

#-------------------------#
function cts40g22_prepare()
#-------------------------#

  define l_sql char(300)

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_sql           = null
  let m_cts40g22_prep = null

  let l_sql = " select max(atdsrvseq) ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g22_001 from l_sql
  declare c_cts40g22_001 cursor for p_cts40g22_001

  let l_sql = " insert into datmsrvacp (atdsrvnum, ",
                                      " atdsrvano, ",
                                      " atdsrvseq, ",
                                      " atdetpcod, ",
                                      " atdetpdat, ",
                                      " atdetphor, ",
                                      " empcod, ",
                                      " funmat, ",
                                      " pstcoddig, ",
                                      " srrcoddig, ",
                                      " socvclcod, ",
                                      " c24nomctt) ",
                               " values(?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cts40g22_002 from l_sql

  let m_cts40g22_prep = true

end function

#------------------------------------------#
function cts40g22_insere_etapa(lr_parametro)
#------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig
  end record

  define l_atdsrvseq  like datmsrvacp.atdsrvseq,
         l_funmat     like datmsrvacp.funmat,
         l_empcod     like datmsrvacp.empcod,
         l_retorno    integer,
         l_dataatu    date,
         l_msg_erro   char(80),
         l_horaatu    datetime hour to minute

  if m_cts40g22_prep is null or
     m_cts40g22_prep <> true then
     call cts40g22_prepare()
  end if

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_atdsrvseq = null
  let l_retorno   = null
  let l_dataatu   = null
  let l_horaatu   = null
  let l_msg_erro  = null
  let l_funmat    = g_issk.funmat
  let l_empcod    = g_issk.empcod
  if l_empcod is null or l_empcod = 0 or
     l_funmat is null or l_funmat = 0 then
     let l_empcod = 1
     let l_funmat = 999999
  end if

  # -> BUSCA A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_dataatu,
                 l_horaatu

  # -> BUSCA A MAIOR SEQUENCIA DO SERVICO
  open c_cts40g22_001 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts40g22_001 into l_atdsrvseq
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg_erro = "Erro SELECT c_cts40g22_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_retorno  = sqlca.sqlcode
        return l_retorno
     end if
  end if

  close c_cts40g22_001

  if l_atdsrvseq is null then
     let l_atdsrvseq = 0
  end if

  let l_atdsrvseq = l_atdsrvseq + 1

  # -> INSERE OS VALORES NA DATMSRVACP
  # 218545 - Burini
  #call cts10g04_insere_etapa(lr_parametro.atdsrvnum,
  #                           lr_parametro.atdsrvano,
  #                           lr_parametro.atdetpcod,
  #                           lr_parametro.pstcoddig,
  #                           lr_parametro.c24nomctt,
  #                           lr_parametro.socvclcod,
  #                           lr_parametro.srrcoddig)
  #     returning l_retorno

  whenever error continue
  execute p_cts40g22_002 using lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano,
                             l_atdsrvseq,
                             lr_parametro.atdetpcod,
                             l_dataatu,
                             l_horaatu,
                             l_empcod,
                             l_funmat,
                             lr_parametro.pstcoddig,
                             lr_parametro.srrcoddig,
                             lr_parametro.socvclcod,
                             lr_parametro.c24nomctt
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg_erro = "Erro INSERT p_cts40g22_002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg_erro)

     let l_retorno = sqlca.sqlcode
  else

     call cts00g07_apos_grvetapa(lr_parametro.atdsrvnum,
                                 lr_parametro.atdsrvano,
                                 l_atdsrvseq,1)

     call cts10g04_alt_etapa(lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano,
                             lr_parametro.atdetpcod)
          returning l_retorno
  end if

  return l_retorno

end function
