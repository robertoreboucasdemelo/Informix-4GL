#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G11                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MOD. RESP. POR ANALISES ESPECIFICAS DE UM DETER. VEICULO.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 30/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g11_prep smallint

#-------------------------#
function cts40g11_prepare()
#-------------------------#

  define l_sql char(400)

  let l_sql = " select c24atvcod ",
                " from dattfrotalocal ",
               " where socvclcod = ? "

  prepare pcts40g11001 from l_sql
  declare ccts40g11001 cursor for pcts40g11001

  let l_sql = " select socvclcod, ",
                     " pstcoddig, ",
                     " srrcoddig ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = ( select max(atdsrvseq) ",
                                     " from datmsrvacp ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? ) "

  prepare pcts40g11002 from l_sql
  declare ccts40g11002 cursor for pcts40g11002

  let l_sql = " select vcllicnum ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pcts40g11003 from l_sql
  declare ccts40g11003 cursor for pcts40g11003

  let l_sql = " select lclltt, ",
                     " lcllgt ",
                " from datmfrtpos ",
               " where socvclcod = ? ",
                 " and socvcllcltip = '1' "

  prepare pcts40g11004 from l_sql
  declare ccts40g11004 cursor for pcts40g11004

  let m_cts40g11_prep = true

end function

#-------------------------------------------#
function cts40g11_verifica_veic(lr_parametro)
#-------------------------------------------#

  define lr_parametro   record
         atdsrvnum_velh like datmservico.atdsrvnum,
         atdsrvano_velh like datmservico.atdsrvano,
         atdsrvnum_novo like datmservico.atdsrvnum,
         atdsrvano_novo like datmservico.atdsrvano,
         atdhorprg      like datmservico.atdhorprg,
         cidnom         like datmlcl.cidnom,
         ufdcod         like datmlcl.ufdcod,
         espcod         like datmsrvre.espcod,
         socntzcod      like datmsrvre.socntzcod,
         lclltt         like datmfrtpos.lclltt,
         lcllgt         like datmfrtpos.lcllgt
  end record

  define l_c24atvcod    like dattfrotalocal.c24atvcod,
         l_socvclcod    like datmsrvacp.socvclcod,
         l_vcllicnum    like datkveiculo.vcllicnum,
         l_msg_erro     char(100),
         l_resultado    smallint,
         l_mensagem     char(100),
         l_cidcod       like glakcid.cidcod,
         l_rodizio      smallint,
         l_pstcoddig    like datmsrvacp.pstcoddig,
         l_srrcoddig    like datmsrvacp.srrcoddig,
         l_cod_motivo   smallint,
         l_msg_motivo   char(40),
         l_distancia    decimal(8,4),
         l_lclltt       like datmfrtpos.lclltt,
         l_lcllgt       like datmfrtpos.lcllgt

  if m_cts40g11_prep is null or
     m_cts40g11_prep <> true then
     call cts40g11_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS

  let l_lclltt     = null
  let l_lcllgt     = null
  let l_c24atvcod  = null
  let l_socvclcod  = null
  let l_msg_erro   = null
  let l_resultado  = null
  let l_cod_motivo = null
  let l_mensagem   = null
  let l_rodizio    = null
  let l_cidcod     = null
  let l_pstcoddig  = null
  let l_srrcoddig  = null
  let l_distancia  = null
  let l_vcllicnum  = null
  let l_cod_motivo = null
  let l_msg_motivo = null

  # --BUSCA O CODIGO DO VEICULO
  open ccts40g11002 using lr_parametro.atdsrvnum_velh,
                          lr_parametro.atdsrvano_velh,
                          lr_parametro.atdsrvnum_velh,
                          lr_parametro.atdsrvano_velh

  whenever error continue
  fetch ccts40g11002 into l_socvclcod,
                          l_pstcoddig,
                          l_srrcoddig
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg_erro = "Erro SELECT ccts40g11002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts40g11002

  # --BUSCA A PLACA DO VEICULO
  open ccts40g11003 using l_socvclcod

  whenever error continue
  fetch ccts40g11003 into l_vcllicnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg_erro = "Erro SELECT ccts40g11003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts40g11003

  # --OBTER O CODIGO DA CIDADE
  call cty10g00_obter_cidcod(lr_parametro.cidnom,
                             lr_parametro.ufdcod)

       returning l_resultado,
                 l_mensagem,
                 l_cidcod

  if l_resultado <> 0 then
     if l_resultado <> 1 then
        call errorlog(l_mensagem)
     end if
  end if

  # --BUSCA A POSICAO DO VEICULO
  open ccts40g11004 using l_socvclcod

  whenever error continue
  fetch ccts40g11004 into l_lclltt, l_lcllgt
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg_erro = "Erro SELECT ccts40g11004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts40g11004

  # --CALCULA A DISTANCIA ENTRE O LOCAL DO SERVICO E O LOCAL DO VEICULO
  let l_distancia = cts18g00(lr_parametro.lclltt, lr_parametro.lcllgt, l_lclltt, l_lcllgt)

  # --VERIFICA SE O VEICULO ESTA EM RODIZIO
  call cts40g05_verifica_rodizio(l_cidcod,
                                 l_vcllicnum,
                                 l_distancia,
                                 lr_parametro.atdhorprg)

       returning l_resultado,
                 l_rodizio

  if not l_rodizio then

     # --VEICULO NAO ESTA EM RODIZIO

     # --VERIFICA SE ATENDE AS NATUREZAS DO SERVICO
     let l_cod_motivo = cts40g05_verifica_naturezas(l_srrcoddig,
                                                    lr_parametro.atdsrvnum_novo,
                                                    lr_parametro.atdsrvano_novo,
                                                    lr_parametro.espcod,
                                                    lr_parametro.socntzcod)

     if l_cod_motivo <> 0 then

        let l_socvclcod = null
        let l_pstcoddig = null
        let l_srrcoddig = null

        case l_cod_motivo

           when 1
              let l_msg_motivo = "TECNICO ACIONADO EM 24/48H NAO ADEQUADO."

           when 2
              let l_msg_motivo = "TECNICO ACIONADO EM 24/48H NAO ESPECIAL."

           when 5
              let l_msg_motivo = "TECN. ACION. 24/48H N ESPE. P/SRV. MULT."

           when 6
              let l_msg_motivo = "TECN. ACION. 24/48H N ADEQ. P/SRV. MULT."

        end case

     end if

  else

     # --VEICULO EM RODIZIO
     let l_socvclcod  = null
     let l_pstcoddig  = null
     let l_srrcoddig  = null
     let l_distancia  = null
     let l_lclltt     = null
     let l_lcllgt     = null
     let l_cod_motivo = 30
     let l_msg_motivo = "TECNICO ACIONADO 24/48H EM RODIZIO."

  end if

  # --BUSCA A SITUACAO DO VEICULO
  open ccts40g11001 using l_socvclcod

  whenever error continue
  fetch ccts40g11001 into l_c24atvcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg_erro = "Erro SELECT ccts40g11001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
     end if
  end if

  close ccts40g11001

  # --VERIFICA SE O VEICULO ESTA DISPONIVEL
  if l_c24atvcod <> "QRV" then
     # --VEICULO NAO DISPONIVEL
     let l_socvclcod  = null
     let l_pstcoddig  = null
     let l_srrcoddig  = null
     let l_distancia  = null
     let l_lclltt     = null
     let l_lcllgt     = null
     let l_cod_motivo = 20
     let l_msg_motivo = "TECNICO ACIONADO EM 24/48H INDISPONIVEL"
  end if

  return l_cod_motivo,
         l_msg_motivo,
         l_socvclcod,
         l_pstcoddig,
         l_srrcoddig,
         l_distancia,
         l_lclltt,
         l_lcllgt

end function
