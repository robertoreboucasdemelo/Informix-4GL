#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G08                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MOD. RESP. POR VERIFICAR SE EXISTE OUTROS SERVICOS SOLICI- #
#                  TADOS NO PRAZO DE 24/48H PARA O MESMO SEGURADO.            #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 14/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 25/09/06   Ligia Mattge    PSI 202720 Implementando grupo/cartao saude        #
# 28/01/09   Adriano Santos  PSI235849 Considerar serviço SINISTRO RE         #
#-----------------------------------------------------------------------------#

database porto

#-------------------------------------------#
function cts40g08_obter_srv_48h(lr_parametro)
#-------------------------------------------#

  define lr_parametro        record
         atdsrvorg           like datmservico.atdsrvorg, # PSI 235849 Adriano Santos 28/01/2009 
         atdsrvnum           like datmservico.atdsrvnum,
         atdsrvano           like datmservico.atdsrvano,
         lclltt              like datmfrtpos.lclltt,
         lcllgt              like datmfrtpos.lcllgt,
         atdhorprg           like datmservico.atdhorprg,
         cidnom              like datmlcl.cidnom,
         ufdcod              like datmlcl.ufdcod,
         tipo_cons           char(03)
  end record

  define lr_cts40g11         record
         cod_motivo          smallint,
         msg_motivo          char(40),
         socvclcod           like datmsrvacp.socvclcod,
         pstcoddig           like datmsrvacp.pstcoddig,
         srrcoddig           like datmsrvacp.srrcoddig,
         distancia           decimal(8,4),
         lclltt              like datmfrtpos.lclltt,
         lcllgt              like datmfrtpos.lcllgt
  end record

  define l_aplnumdig         like datrservapol.aplnumdig,
         l_succod            like datrservapol.succod,
         l_ramcod            like datrservapol.ramcod,
         l_itmnumdig         like datrservapol.itmnumdig,
         l_atdsrvnum         like datmservico.atdsrvnum,
         l_atdsrvano         like datmservico.atdsrvano,
         l_atdprscod         like datmservico.srrcoddig,
         l_atdetpcod         like datmsrvacp.atdsrvseq,
         l_socntzdes         like datksocntz.socntzdes,
         l_socntzgrpcod      like datksocntz.socntzgrpcod,
         l_orig_socntzgrpcod like datksocntz.socntzgrpcod,
         l_orig_socntzcod    like datmsrvre.socntzcod,
         l_orig_espcod       like datmsrvre.espcod,
         l_resultado         smallint,
         l_existe            smallint,
         l_data_atual        date,
         l_data_ant          date,
         l_hora_atual        datetime hour to minute,
         l_mensagem          char(80),
         l_crtsaunum         like datrligsau.crtnum,
         l_sql               char(400)

  # --INICIALIZACAO DAS VARIAVEIS

  initialize lr_cts40g11 to null

  let l_sql               = null
  let l_aplnumdig         = null
  let l_succod            = null
  let l_ramcod            = null
  let l_itmnumdig         = null
  let l_resultado         = 0
  let l_mensagem          = null
  let l_data_atual        = null
  let l_data_ant          = null
  let l_hora_atual        = null
  let l_atdsrvnum         = null
  let l_atdsrvano         = null
  let l_atdetpcod         = null
  let l_atdprscod         = null
  let l_socntzdes         = null
  let l_orig_socntzgrpcod = null
  let l_socntzgrpcod      = null
  let l_orig_socntzcod    = null
  let l_orig_espcod       = null
  let l_existe            = false
  let l_crtsaunum         = null

  ### PSI 202720
  call cts20g10_cartao(1,
                       lr_parametro.atdsrvnum,
                       lr_parametro.atdsrvano)

       returning l_resultado,
                 l_mensagem,
                 l_crtsaunum

  if l_resultado <> 1 then
     if l_resultado <> 2 then
        display "Erro: ", l_resultado
        display l_mensagem
     end if
  end if

  if l_crtsaunum is null then
     # --BUSCA A APOLICE DO SERVICO
     call cts20g13_obter_apolice(lr_parametro.atdsrvnum,
                                 lr_parametro.atdsrvano)
          returning l_resultado,
                    l_mensagem,
                    l_aplnumdig,
                    l_succod,
                    l_ramcod,
                    l_itmnumdig

     if l_resultado <> 1 then
        display "Resultado: ", l_resultado
        display "Servico: ", lr_parametro.atdsrvnum, "/",
                             lr_parametro.atdsrvnum
        display l_mensagem
     end if
  else
     let l_resultado = 1
  end if

  if l_resultado = 1 then
     # --BUSCAR A DATA E HORA DO BANCO
     call cts40g03_data_hora_banco(2)
           returning l_data_atual,
                     l_hora_atual

     # --SUBTRAI DOIS DIAS DA DATA ATUAL
     let l_data_ant = (l_data_atual -2 units day)

     ### PSI 202720
     if l_crtsaunum is not null then
        let l_sql = " select b.atdprscod, ",
                           " b.atdsrvnum, ",
                           " b.atdsrvano ",
                      " from datrsrvsau a, ",
                           " datmservico b ",
                     " where a.crtnum = ? and ",
                           " b.atdsrvnum = a.atdsrvnum and ",
                           " b.atdsrvano = a.atdsrvano and ",
                           " b.atddat between  ?  and  ? and ",
                           " b.atdsrvorg = ",lr_parametro.atdsrvorg, # PSI 235849 Adriano Santos 28/01/2009
                     " order by 2 desc "

     else
        let l_sql = " select b.atdprscod, ",
                           " b.atdsrvnum, ",
                           " b.atdsrvano ",
                      " from datrservapol a, ",
                           " datmservico b ",
                     " where a.ramcod = ? and ",
                           " a.succod = ? and ",
                           " a.aplnumdig = ? and ",
                           " a.itmnumdig = ? and ",
                           " b.atdsrvnum = a.atdsrvnum and ",
                           " b.atdsrvano = a.atdsrvano and ",
                           " b.atddat between  ?  and  ? and ",
                           " b.atdsrvorg = ",lr_parametro.atdsrvorg, # PSI 235849 Adriano Santos 28/01/2009
                     " order by 2 desc "
     end if

     prepare pcts40g08003 from l_sql
     declare ccts40g08003 cursor for pcts40g08003

     # --VERIFICA SE EXISTE SERVICOS PARA O MESMO SEGURADO NUM PRAZO DE 48 HORAS

     if l_crtsaunum is not null then
        open ccts40g08003 using l_crtsaunum,
                                l_data_ant,
                                l_data_atual
     else
        open ccts40g08003 using l_ramcod,
                                l_succod,
                                l_aplnumdig,
                                l_itmnumdig,
                                l_data_ant,
                                l_data_atual
     end if

     foreach ccts40g08003 into l_atdprscod,
                               l_atdsrvnum,
                               l_atdsrvano

        # --BUSCA A ULTIMA ETAPA DO SERVICO
        call cts20g15_obter_ult_etapa(l_atdsrvnum,
                                      l_atdsrvano)
             returning l_resultado,
                       l_mensagem,
                       l_atdetpcod

        if l_resultado <> 0 then
           if l_resultado <> 1 then
              display l_mensagem
              let l_resultado = 2
              exit foreach
           end if
        end if

        # --VERIFICA A ETAPA DO SERVICO
        if l_atdetpcod = 3 then

           # --O SERVICO ESTA ACIONADO

           # --OBTER COD. DA NATUREZA E O COD.
           # --DA ESPECIALIDADE DO SRV. ENCONTRADO (datmsrvre)
           call cts40g01_obter_codnat_codesp(l_atdsrvnum,
                                             l_atdsrvano)
                returning l_resultado,
                          l_mensagem,
                          l_orig_socntzcod,
                          l_orig_espcod

           if l_resultado <> 0 then
              display l_mensagem
              if l_resultado <> 1 then
                 display "Erro: ", l_mensagem
              end if
           end if

           # --OBTER O GRUPO DA NATUREZA DO SERVICO ENCONTRADO
           call ctc16m03_inf_natureza(l_orig_socntzcod,
                                      "A")
                returning l_resultado,
                          l_mensagem,
                          l_socntzdes,
                          l_orig_socntzgrpcod

           if l_resultado <> 1 then
              display "l_orig_socntzcod: ", l_orig_socntzcod
              display "Resultado: ", l_resultado
              display "Mensagem: ", l_mensagem
           end if

           # --OBTER COD. DA NATUREZA E O COD. DA ESPECIALIDADE
           # --DO SRV. LIDO (datmsrvre)
           call cts40g01_obter_codnat_codesp(lr_parametro.atdsrvnum,
                                             lr_parametro.atdsrvano)

                returning l_resultado,
                          l_mensagem,
                          l_orig_socntzcod,
                          l_orig_espcod

           if l_resultado <> 0 then
              display l_mensagem
              if l_resultado <> 1 then
                 display "Erro: ", l_mensagem
              end if
           end if

           # --OBTER O GRUPO DA NATUREZA DO SERVICO LIDO
           call ctc16m03_inf_natureza(l_orig_socntzcod,
                                      "A")
                returning l_resultado,
                          l_mensagem,
                          l_socntzdes,
                          l_socntzgrpcod

           if l_resultado <> 1 then
              display "l_orig_socntzcod: ", l_orig_socntzcod
              display "Resultado: ", l_resultado
              display "Mensagem: ", l_mensagem
           end if

           exit foreach

        end if

     end foreach

     close ccts40g08003

     # --COMPARA O GRUPO DO SERVICO ORIGINAL COM O GRUPO DO SERVICO ENCONTRADO.
     if l_socntzgrpcod = l_orig_socntzgrpcod then

        if lr_parametro.tipo_cons = "GPS" then

           # --CHAMAR FUNCAO PARA TRATAR VEICULO
           call cts40g11_verifica_veic(l_atdsrvnum,
                                       l_atdsrvano,
                                       lr_parametro.atdsrvnum,
                                       lr_parametro.atdsrvano,
                                       lr_parametro.atdhorprg,
                                       lr_parametro.cidnom,
                                       lr_parametro.ufdcod,
                                       l_orig_espcod,
                                       l_orig_socntzcod,
                                       lr_parametro.lclltt,
                                       lr_parametro.lcllgt)

                returning lr_cts40g11.cod_motivo,
                          lr_cts40g11.msg_motivo,
                          lr_cts40g11.socvclcod,
                          lr_cts40g11.pstcoddig,
                          lr_cts40g11.srrcoddig,
                          lr_cts40g11.distancia,
                          lr_cts40g11.lclltt,
                          lr_cts40g11.lcllgt

        else
           let l_resultado = 0
           let l_existe    = true
        end if
     else
        let l_existe = false
        initialize lr_cts40g11 to null
     end if

  end if

  if lr_parametro.tipo_cons = "GPS" then
     # --CONSULTA PARA GPS
     return lr_cts40g11.cod_motivo,
            lr_cts40g11.msg_motivo,
            lr_cts40g11.socvclcod,
            lr_cts40g11.pstcoddig,
            lr_cts40g11.srrcoddig,
            lr_cts40g11.distancia,
            lr_cts40g11.lclltt,
            lr_cts40g11.lcllgt

  else
     # --CONSULTA PARA INTERNET
     let l_resultado = 0 # TEMPORARIO ATE IDENTIFICAR O PROBLEMA
     return l_resultado, l_existe, l_atdprscod
  end if

end function
