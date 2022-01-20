#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema        : Porto Socorro                                               #
# Modulo         : cts00g08                                                    #
#                  Consulta Prestador (e Socorrista) do contrato PSS           #
# Analista Resp. : Adriano Souza Santos                                        #
# PSI            : 242853 - INTEGRACAO CT24H X PSS                             #
#------------------------------------------------------------------------------#
#                         * * *  ALTERACOES  * * *                             #
# Data       Analista Resp/Autor Fabrica PSI/Alteracao                         #
#------------------------------------------------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
# Consulta Prestador (e Socorrista) do contrato PSS
#------------------------------------------------------------
function cts00g08(lr_param)

  define lr_param record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano
  end record

  define lr_retorno          record
          resultado          smallint
         ,mensagem           char(100)
         ,psscntcod          like datrcntlig.psscntcod
  end record

  define lr_pss01g00   record
           resultado     smallint
          ,mensagem      char(200)
          ,pstcoddig     like datmsrvacp.pstcoddig
          ,srrcoddig     like datmsrvacp.srrcoddig
  end record

  define lr_acn_pst_pss   record
           mensagem     char(80)
          ,retorno      smallint
  end record

  define lr_cts26g00 record
      resultado  smallint
     ,mensagem   char(100)
     ,socntzcod  like datmsrvre.socntzcod
     ,espcod     like datmsrvre.espcod
  end record

  define l_resultado       smallint,
         l_mensagem        char(100),
         l_null            smallint,
         l_atdetpcod       like datmsrvacp.atdetpcod

  let l_resultado = 0
  let l_mensagem  = null
  let l_null      = null
  let l_atdetpcod = null

  initialize lr_cts26g00,
             lr_pss01g00,
             lr_retorno to null

  #Obter contrato do PSS
  call cts00g08_consulta_pst_soc(lr_param.atdsrvnum,
                                 lr_param.atdsrvano)
       returning lr_retorno.resultado
                ,lr_retorno.mensagem
                ,lr_retorno.psscntcod

  #Obter codigo da natureza do servico
  call cts26g00_obter_natureza(lr_param.atdsrvnum,lr_param.atdsrvano)
       returning lr_cts26g00.resultado
                ,lr_cts26g00.mensagem
                ,lr_cts26g00.socntzcod
                ,lr_cts26g00.espcod

  if lr_retorno.resultado = 0 then
      if lr_cts26g00.resultado = 1 then

          #Obter prestado (e socorrista) do contrato PSS
          call pss02g00_consulta_pst_soc(lr_retorno.psscntcod,
                                         lr_cts26g00.socntzcod)
               returning lr_pss01g00.resultado
                        ,lr_pss01g00.mensagem
                        ,lr_pss01g00.pstcoddig
                        ,lr_pss01g00.srrcoddig

          if lr_pss01g00.pstcoddig is not null then

              call cts10g04_ultima_etapa(lr_param.atdsrvnum, lr_param.atdsrvano)
                   returning l_atdetpcod

              if l_atdetpcod = 1 then
                  #Aciona para o prestador do contrato PSS
                  call cts00g08_acn_pst_pss(lr_param.atdsrvnum,
                                            lr_param.atdsrvano,
                                            lr_pss01g00.pstcoddig)
                       returning lr_acn_pst_pss.mensagem,
                                 lr_acn_pst_pss.retorno
                  if lr_acn_pst_pss.retorno <> 1 then
                      let l_resultado = 1
                      let l_mensagem  = lr_acn_pst_pss.mensagem
                  end if
                  ##Atualiza do prestador na ultima etapa LIBERADO
                  #call cts10g04_atl_prestador(lr_param.atdsrvnum,
                  #                            lr_param.atdsrvano,
                  #                            lr_pss01g00.pstcoddig)
                  #     returning lr_cts10g04.mensagem,
                  #               lr_cts10g04.retorno
                  #if lr_cts10g04.retorno <> 1 then
                  #    let l_resultado = 1
                  #    let l_mensagem  = lr_cts10g04.mensagem
                  #end if
              end if
          else
              if lr_pss01g00.resultado = 3 then
                  let l_resultado = 1
                  let l_mensagem  = lr_pss01g00.mensagem
              end if
          end if
      else
          if lr_cts26g00.resultado = 3 then
              let l_resultado = 1
              let l_mensagem  = lr_cts26g00.mensagem
          end if
      end if
  else
      if lr_retorno.resultado = 2 then
          let l_resultado = 1
          let l_mensagem  = lr_retorno.mensagem
      end if
  end if

  return l_resultado,
         l_mensagem

end function # cts00g08

#----------------------------------------------------------------------------#
function cts00g08_consulta_pst_soc(lr_param)
#----------------------------------------------------------------------------#

 define lr_param            record
        atdsrvnum   like datmligacao.atdsrvnum
       ,atdsrvano   like datmligacao.atdsrvano
 end record


 define lr_retorno          record
         resultado          integer
        ,mensagem           char(100)
        ,psscntcod          like datrcntlig.psscntcod
 end record

 initialize lr_retorno.* to null

 let lr_retorno.resultado = 0
 ##-- encontrar contrato que solicitou servico --##

 whenever error continue

 select b.psscntcod
 into lr_retorno.psscntcod
 from datmligacao a, datrcntlig b
 where a.lignum = b.lignum
   and a.atdsrvnum = lr_param.atdsrvnum
   and a.atdsrvano = lr_param.atdsrvano

 whenever error stop

 if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "NAO FOI ENCONTRADO O CONTRATO PARA O SERVICO INFORMADO."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em cts00g08_consulta_pst_soc"
     end if
     return lr_retorno.*
  end if

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.psscntcod

end function # cts00g08_consulta_pst_soc

#-----------------------------------------------------#
function cts00g08_acn_pst_pss(lr_param)
#-----------------------------------------------------#

   define lr_param record
       atdsrvnum  like datmservico.atdsrvnum,
       atdsrvano  like datmservico.atdsrvano,
       pstcoddig  like datmsrvacp.pstcoddig
   end record

   define am_multiplos array[10] of record
         atdmltsrvnum   like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano   like datratdmltsrv.atdmltsrvano,
         socntzdes      like datksocntz.socntzdes,
         espdes         like dbskesp.espdes,
         atddfttxt      like datmservico.atddfttxt
   end record

   define l_resultado    integer,
          l_mensagem     char(100),
          l_ok           smallint,
          l_msg_erro     char(80)

   define l_aux  smallint
   define l_funmat like isskfunc.funmat
   define l_empcod like isskfunc.empcod
   define l_atdorgsrvnum like datmsrvre.atdorgsrvnum
   define l_atdorgsrvano like datmsrvre.atdorgsrvano
   define l_atdetpcod like datmsrvacp.atdetpcod
   initialize am_multiplos to null
   let l_resultado = null
   let l_mensagem = null
   let l_ok = true
   let l_aux = 0
   let l_msg_erro = null
   let l_atdorgsrvnum = null
   let l_atdorgsrvano = null
   let l_atdetpcod = 3

   ##buscar laudos multiplos
   #call cts29g00_obter_multiplo(2,
   #                             lr_param.atdsrvnum,
   #                             lr_param.atdsrvano)
   #     returning l_resultado,
   #               l_mensagem,
   #               am_multiplos[1].*,
   #               am_multiplos[2].*,
   #               am_multiplos[3].*,
   #               am_multiplos[4].*,
   #               am_multiplos[5].*,
   #               am_multiplos[6].*,
   #               am_multiplos[7].*,
   #               am_multiplos[8].*,
   #               am_multiplos[9].*,
   #               am_multiplos[10].*

   let l_funmat      = g_issk.funmat
   let l_empcod      = g_issk.empcod
   # Assume matricula do ACN AUTOMATICO para acionar automaticamente pelo laudo
   let g_issk.funmat = 999999
   let g_issk.empcod = 1
   while true
       #chamar cts33g01 para servico original
       let l_resultado = cts33g01_alt_dados_automat(lr_param.pstcoddig,
                                                    "",
                                                    "",
                                                    "",
                                                    g_issk.funmat,
                                                    "", #atdcstvlr,
                                                    "",
                                                    "",
                                                    "",
                                                    1, ##"",  #acntntqtd #ligia
                                                    lr_param.atdsrvnum,
                                                    lr_param.atdsrvano)
       if l_resultado <> 0 then
          let l_ok = false
          let l_msg_erro = "Erro (",l_resultado,")na cts33g01_alt_dados_automat SRV"
          exit while
       end if

       #para cada laudo multiplo, chamar cts33g01 para laudos multiplos
       # estou passando nulo em atdcstvlr, pois qdo gero o servico gravo nulo
       # -- campo nao utilizado
       #for l_aux = 1 to 10
       #   if am_multiplos[l_aux].atdmltsrvnum is not null then
       #     let l_resultado = cts33g01_alt_dados_automat(lr_param.pstcoddig,
       #                                                  "",
       #                                                  "",
       #                                                  "",
       #                                                  g_issk.funmat,
       #                                                  "", #atdcstvlr
       #                                                  "",
       #                                                  "",
       #                                                  "",
       #                                                  1, ##"",  #acntntqtd
       #                                                  am_multiplos[l_aux].atdmltsrvnum,
       #                                                  am_multiplos[l_aux].atdmltsrvano)
       #      if l_resultado <> 0 then
       #         let l_ok = false
       #         let l_msg_erro = "Erro (",l_resultado,")na cts33g01_alt_dados_automat"
       #         exit for
       #      end if
       #   else
       #      # --NAO POSSUI SERVICOS MULTIPLOS
       #      exit for
       #
       #end for
       #
       #if l_ok = false then
       #   exit while
       #end if
       select atdorgsrvnum,
              atdorgsrvano
         into l_atdorgsrvnum,
              l_atdorgsrvano
         from datmsrvre
        where atdsrvnum = lr_param.atdsrvnum
          and atdsrvano = lr_param.atdsrvano
       if l_atdorgsrvnum is not null or
          l_atdorgsrvano is not null then
          let l_atdetpcod = 10
       end if
       # --INSERIR ETAPA
       let l_resultado = cts40g22_insere_etapa(lr_param.atdsrvnum,
                                               lr_param.atdsrvano,
                                               l_atdetpcod,
                                               lr_param.pstcoddig,
                                               "",
                                               "",
                                               "")

       if l_resultado <> 0 then
          let l_msg_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
          let l_ok = false
          exit while
       end if
       call cts10g04_atualiza_dados(lr_param.atdsrvnum,
                                    lr_param.atdsrvano,
                                    "",
                                    1)
            returning l_mensagem,
                      l_resultado
       if l_resultado <> 1 then
          let l_msg_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
          let l_ok = false
          exit while
       end if

       ## --INSERIR A ETAPA PARA OS SERVICOS MULTIPLOS
       #for l_aux = 1 to 10
       #   if am_multiplos[l_aux].atdmltsrvnum is not null then
       #      # --REGISTRAR PRESTADOR PARA CADA SERVICO MULTIPLO
       #      let l_resultado = cts40g22_insere_etapa(am_multiplos[l_aux].atdmltsrvnum,
       #                                              am_multiplos[l_aux].atdmltsrvano,
       #                                              3,
       #                                              lr_param.pstcoddig,
       #                                              "",
       #                                              "",
       #                                              "")
       #      if l_resultado <> 0 then
       #         let l_msg_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts40g22_insere_etapa()"
       #         let l_ok = false
       #         exit for
       #      end if
       #      call cts10g04_atualiza_dados(am_multiplos[l_aux].atdmltsrvnum,
       #                                   am_multiplos[l_aux].atdmltsrvano,
       #                                   "",
       #                                   1)
       #           returning l_mensagem,
       #                     l_resultado
       #       if l_resultado <> 1 then
       #          let l_msg_erro = "Erro: (", l_resultado, ") ao chamar a funcao cts10g04_atualiza_dados()"
       #          display l_mensagem
       #          let l_ok = false
       #          exit for
       #       end if
       #   else
       #      # --NAO POSSUI SERVICOS MULTIPLOS
       #      exit for
       #   end if
       #end for
       #if l_ok = false then
       #   exit while
       #end if

       if l_resultado <> 0 then
         let l_ok = false
         exit while
       end if
       exit while

   end while

   let g_issk.funmat = l_funmat
   let g_issk.empcod = l_empcod
   return l_ok,
          l_msg_erro

end function
