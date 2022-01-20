#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G10                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MOD. RESPONSAVEL POR VERIFICAR SE O SERVICO E DE RETORNO.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 18/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 03/07/2007 Burini          Isabel     Buscar o ultimo prestador da ultima   #
#                                       sequencia de retorno, ao inves de     #
#                                       buscar o prestador da origem          #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g10_prep smallint

#-------------------------#
function cts40g10_prepare()
#-------------------------#

  define l_sql char(1000)

  let l_sql = " select atdorgsrvnum, ",
                     " atdorgsrvano ",
                " from datmsrvre ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts40g10001 from l_sql
  declare ccts40g10001 cursor for pcts40g10001

   #Seleciona o ultimo registro de servico
   #relacionado ao servico original
   let l_sql =
        "select acp.atdsrvnum,",
              " acp.atdsrvano,",
              " acp.pstcoddig,",
              " acp.srrcoddig,",
              " acp.socvclcod",
         " from datmsrvre re, datmsrvacp acp",
        " where re.atdorgsrvnum = ?",
          " and re.atdorgsrvano = ?",
          " and acp.atdsrvnum = re.atdsrvnum",
          " and acp.atdsrvano = re.atdsrvano",
          " and acp.atdetpcod in (3,10)",
          " and atdsrvseq = (select max(atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)",
        " order by acp.atdsrvano desc, acp.atdsrvnum desc"
  
  prepare pcts40g10002 from l_sql
  declare ccts40g10002 cursor for pcts40g10002

  let m_cts40g10_prep = true

end function

#----------------------------------------------#
function cts40g10_verifica_retorno(lr_parametro)
#----------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_atdorgsrvnum like datmsrvre.atdorgsrvnum,
         l_atdorgsrvano like datmsrvre.atdorgsrvano,
         l_resultado    smallint,
         l_online       smallint,
         l_mensagem     char(80),
         l_msg_erro     char(100)
         
   define ws record
       atdantsrvnum like dbsmopgitm.atdsrvnum, #numero servico anterior
       atdantsrvano like dbsmopgitm.atdsrvano, #ano servico anterior
       pstcoddig    like datmsrvacp.pstcoddig,
       srrcoddig    like datmsrvacp.srrcoddig,
       socvclcod    like datmsrvacp.socvclcod
   end record         
   
  if m_cts40g10_prep is null or
     m_cts40g10_prep <> true then
     call cts40g10_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  let l_atdorgsrvnum = null
  let l_atdorgsrvano = null
  let l_online       = null
  let l_mensagem     = null
  let l_msg_erro     = null
  let l_resultado    = 0
 
  initialize ws.* to null

  call cts10g04_busca_prest_ant(lr_parametro.atdsrvnum,
                                lr_parametro.atdsrvano)
       returning ws.pstcoddig,
                 ws.srrcoddig,
                 ws.socvclcod
  
  if  ws.pstcoddig is not null and ws.pstcoddig <> " " then
      # --VERIFICA SE O PRESTADOR ESTA ONLINE
      if fissc101_prestador_sessao_ativa(ws.pstcoddig, "PSRONLINE") then
         let l_online = true
      else
         let l_online = false
      end if
  else
      let l_mensagem  = 'Nenhum prestador selecionado'
      let l_resultado = 1
  end if     
  
  return l_resultado,
         l_mensagem,
         ws.pstcoddig,
         l_online

end function
