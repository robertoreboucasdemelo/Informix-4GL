###############################################################################a
# Sistema  : CTS      - Central 24 Horas                            JUNHO/2008 #
# Programa :                                                                   #
# Modulo   : ctf00m03 - Cancelamento de Servicos                               #
# Analista : Carla Rampazzo                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
#                           * * * Comentarios * * *                            #
#                                                                              #
# Este modulo foi retirado do pgm cts17m00 para que o mesmo seja utilizado tan #
# to pelo informix quanto pelo Portal do Segurado.                             #
# O controle da chamada eh feito pela variavel global g_origem onde:           #
# "WEB"= Portal ou "IFX" ou null = Informix                                    #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"


define mr_retorno           record
       coderro              smallint
      ,deserro              char(1000)
      ,xml                  char(5000)
end record


#----------------------------------------------------------------------------
function ctf00m03(param)
#----------------------------------------------------------------------------


   define param                record
          atdsrvnum            like datmservico.atdsrvnum
         ,atdsrvano            like datmservico.atdsrvano
         ,atdfnlflg            like datmservico.atdfnlflg
   end record

   define al_cts29g00          array[10] of record
          atdmltsrvnum         like datratdmltsrv.atdmltsrvnum
         ,atdmltsrvano         like datratdmltsrv.atdmltsrvano
         ,webntzdes            like datksocntz.webntzdes
         ,espdes               like dbskesp.espdes
         ,atddfttxt            like datmservico.atddfttxt
   end record

   define l_atdsrvnum_original like datmservico.atdsrvnum
         ,l_atdsrvano_original like datmservico.atdsrvano
         ,l_servico            like datmservico.atdsrvnum
         ,l_ano                like datmservico.atdsrvano
         ,l_contador           smallint
         ,l_resultado          smallint
         ,l_mensagem           char(50)
         ,l_confirma           char(1)
         ,l_lignum             like datmligacao.lignum
         ,l_srvnum             like datmservico.atdsrvnum
         ,l_srvano             like datmservico.atdsrvano
         ,l_sqlcode            integer
         ,l_msg                char(50)
         ,l_tabname            like systables.tabname
         ,l_data               date
         ,l_hora2              datetime hour to minute
         ,l_sql                char(500)

   let l_atdsrvnum_original = null
   let l_atdsrvano_original = null
   let l_resultado          = null
   let l_mensagem           = null
   let l_confirma           = null
   let l_contador           = null
   let l_servico            = null
   let l_ano                = null
   let l_lignum             = null
   let l_srvnum             = null
   let l_srvano             = null
   let l_sqlcode            = null
   let l_msg                = null
   let l_tabname            = null
   let l_sql                = null


   initialize al_cts29g00, mr_retorno.*  to null

   let l_sql = 'update datmservico '
               ,'  set atdfnlflg = ? '
               ,'     ,acnsttflg = ? '
               ,'     ,acntntqtd = ? '
               ,'where atdsrvnum = ? '
               ,'  and atdsrvano = ? '
   prepare p_ctf00m03_001  from l_sql

   let mr_retorno.coderro = 0  ---> Quando efetuou o Cancelamento

   ---> Valida Parametro
   if g_origem = "WEB" then

      if param.atdsrvnum is null or
         param.atdsrvnum =  0    or
         param.atdsrvano is null or
         param.atdsrvano =  0    or
         param.atdfnlflg is null or
         param.atdfnlflg =  " "  then

         let mr_retorno.coderro = 1
         let mr_retorno.deserro = "Parametros de entrada invalidos -->"
                                 ,"Numero Servico: " , param.atdsrvnum
                                 ,"Ano Servico: "    , param.atdsrvano
                                 ,"Flag Servico: "   , param.atdfnlflg


         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                ,mr_retorno.coderro
                                ,mr_retorno.deserro)
              returning mr_retorno.xml

         return mr_retorno.xml
      end if
   end if

   --->Obter Servino Original se o Servico vindo do parametro for Multiplo
   call cts29g00_consistir_multiplo(param.atdsrvnum, param.atdsrvano)
        returning l_resultado,
                  l_mensagem,
                  l_atdsrvnum_original,
                  l_atdsrvano_original

   --->Erro de acesso a banco
   if g_origem is null   or
      g_origem =  "IFX"  then

      if l_resultado = 3 then
         error l_mensagem
         return
      end if
   else
      if l_resultado = 3 then
         let mr_retorno.coderro = 2
         let mr_retorno.deserro = l_mensagem

         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                ,mr_retorno.coderro
                                ,mr_retorno.deserro)
              returning mr_retorno.xml

         return mr_retorno.xml
      end if
   end if


   --->Servico eh o multiplo, obter o servico original
   if l_atdsrvnum_original is not null then
      let l_servico = l_atdsrvnum_original
      let l_ano     = l_atdsrvano_original
   else
      ---> servico eh o original
      let l_servico = param.atdsrvnum
      let l_ano     = param.atdsrvano
   end if

   --->Obter os Servicos Multiplos do Original
   call cts29g00_obter_multiplo (1, l_servico, l_ano)
        returning l_resultado     , l_mensagem
                , al_cts29g00[1].*, al_cts29g00[2].*
                , al_cts29g00[3].*, al_cts29g00[4].*
                , al_cts29g00[5].*, al_cts29g00[6].*
                , al_cts29g00[7].*, al_cts29g00[8].*
                , al_cts29g00[9].*, al_cts29g00[10].*


   --->Erro de acesso a banco
   if g_origem is null   or
      g_origem =  "IFX"  then

      if l_resultado = 3 then
         error l_mensagem
         return
      end if
   else

      if l_resultado = 3 then
         let mr_retorno.coderro = 3
         let mr_retorno.deserro = l_mensagem

         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                ,mr_retorno.coderro
                                ,mr_retorno.deserro)
              returning mr_retorno.xml

         return mr_retorno.xml
      end if
   end if


   if l_resultado = 2 then
      --->Nao temos Servicos Multiplos para o Servico do parametro
      initialize al_cts29g00 to null
   end if


   if l_resultado = 1 then    --->  tem multiplos

      if g_origem is null   or
         g_origem =  "IFX"  then

         call cts08g01("A","F","", "EXISTEM LAUDOS MULTIPLOS, CONFIRME",
                       "O CANCELAMENTO DE TODOS ","")
              returning l_confirma
      else
         ---> Para o portal sempre serao cancelados todos os Servicos
         let l_confirma = "S"

      end if


      ---> nao confirmou o cancelamento do original, manter o srv do parametro
      if l_confirma = "N" and l_atdsrvnum_original is not null then
         let l_servico = param.atdsrvnum
         let l_ano     = param.atdsrvano
      end if
   end if


   if param.atdfnlflg = "A" or param.atdfnlflg = "N" then

      begin work

      execute p_ctf00m03_001 using 'S'
			       , 'N'
                               , "0"
                               , l_servico
                               , l_ano

      #call cts00g07_apos_grvlaudo(l_servico,l_ano)

      --->gravar etapa do serviço
      call cts10g04_insere_etapa (l_servico
                                 ,l_ano
                                 ,5        ---> 5 = etapa de cancelamento
                                 ,""
                                 ,""
                                 ,""
                                 ,"" )
                       returning l_resultado

      if l_resultado <> 0  then
         if g_origem is null   or
            g_origem =  "IFX"  then
            error "Erro na inclusao da etapa de acompanhamento p/ cancelamento"

	 else
            let mr_retorno.coderro = 4
            let mr_retorno.deserro = "Erro na inclusao da etapa de "
                                    ,"acompanhamento p/ cancelamento"

            call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                   ,mr_retorno.coderro
                                   ,mr_retorno.deserro)
                 returning mr_retorno.xml
	 end if
         rollback work
      else

         ---> para quando nao tem multiplos, ja abater a cota
         if al_cts29g00[1].atdmltsrvnum is null then


            --->abater cota cadastrada
            call ctc59m03_regulador(l_servico, l_ano)
                 returning l_resultado


            if l_resultado <> 0  then
               if g_origem is null   or
                  g_origem =  "IFX"  then
                  error " Erro (", l_resultado, ")na cota. AVISE A INFORMATICA!"

	       else
                  let mr_retorno.coderro = 5
                  let mr_retorno.deserro = " Erro (", l_resultado, ")na cota. "
                                          ," AVISE A INFORMATICA!"


                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml
	       end if
               rollback work
            else
               commit work
            end if
            
            ---> Gera a Ligacao de cancelamento para o Servico Original
            if g_origem = "WEB" then

               begin work


               call cts10g03_numeracao( 1, "" )
                    returning l_lignum
                             ,l_srvnum
                             ,l_srvano
                             ,l_sqlcode
                             ,l_msg
               if l_sqlcode = 0  then
                  commit work
               else
                  let mr_retorno.coderro = 6
                  let mr_retorno.deserro = l_mensagem

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml

                  rollback work
               end if

               begin work
               call cts40g03_data_hora_banco(2) returning l_data, l_hora2
               call cts10g00_ligacao(l_lignum,
                                     l_data,
                                     l_hora2,
                                     g_documento.c24soltipcod,
                                     g_documento.solnom,
                                     "CAN",
                                     g_issk.funmat,
                                     g_documento.ligcvntip,
                                     g_c24paxnum,
                                     l_servico,
                                     l_ano,
                                     "","","","",
                                     g_documento.succod,
                                     g_documento.ramcod,
                                     g_documento.aplnumdig,
                                     g_documento.itmnumdig,
                                     g_documento.edsnumref,
                                     "","","","",
                                     "","","","",
                                     "","","","")
                           returning l_tabname,
                                     l_sqlcode
               if l_sqlcode  <>  0  then
                  let mr_retorno.coderro = 7
                  let mr_retorno.deserro = " Erro (", l_sqlcode, ") na gravacao"
	                                  ," da tabela ", l_tabname clipped
                                          ,". AVISE A INFORMATICA!"

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml

                  rollback work
               else
                  commit work
               end if
            end if

            if g_origem is null   or
               g_origem =  "IFX"  then
               return
            else
               let mr_retorno.xml =
               "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
               ,"<SERVICO>CANCELAR_SERVICO</SERVICO>"
               ,"<CANCELADO>SIM</CANCELADO>"
               ,"</RESPONSE>"

               return mr_retorno.xml
            end if
         end if


         if l_confirma = "S" then

            ---> atualiza os multiplos
            for l_contador = 1 to 10

                if al_cts29g00[l_contador].atdmltsrvnum is not null then

                   execute p_ctf00m03_001 using 'S', 'N',  "0"
                                           ,al_cts29g00[l_contador].atdmltsrvnum
                                           ,al_cts29g00[l_contador].atdmltsrvano

                   --->gravar etapa do serviço
                   call cts10g04_insere_etapa
                        (al_cts29g00[l_contador].atdmltsrvnum
                        ,al_cts29g00[l_contador].atdmltsrvano
                        ,5        ---> 5 = etapa de cancelamento
                        ,""
                        ,""
                        ,""
                        ,"" )
                        returning l_resultado
                   if l_resultado <> 0  then
                      if g_origem is null   or
                         g_origem =  "IFX"  then
                         error " Erro na inclusao da etapa de cancelamento"
		      else

                         let mr_retorno.coderro = 8
                         let mr_retorno.deserro = " Erro na inclusao da etapa"
                                                 ," de cancelamento"

                         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                                ,mr_retorno.coderro
                                                ,mr_retorno.deserro)
                              returning mr_retorno.xml
                      end if
                      exit for
                   end if
                else
                   exit for
                end if
            end for
            if l_resultado <> 0 then
               rollback work

               if g_origem is null   or
                  g_origem =  "IFX"  then
                  return
               else
                  let mr_retorno.coderro = 9
                  let mr_retorno.deserro = " Erro na inclusao da etapa"
                                          ," de cancelamento"

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml

                  return mr_retorno.xml
               end if
            end if

            --->abater cota cadastrada
            call ctc59m03_regulador(l_servico, l_ano)
                 returning l_resultado
            if l_resultado <> 0  then
               if g_origem is null   or
                  g_origem =  "IFX"  then
                  error " Erro (", l_resultado, ")na cota. AVISE A INFORMATICA!"
	       else

                  let mr_retorno.coderro = 10
                  let mr_retorno.deserro = " Erro (", l_resultado, ")na cota."
                                          ," AVISE A INFORMATICA!"


                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml

	       end if
               rollback work
            else
               commit work
            end if

         else ---> desvincular o servico da estrutura dos multiplos

            call cts29g00_remover_multiplo(l_servico, l_ano)
                 returning l_resultado, l_mensagem


            if l_resultado = 3 then
               rollback work

               if g_origem is null   or
                  g_origem =  "IFX"  then
                  error l_mensagem
                  return
               else

                  let mr_retorno.coderro = 11
                  let mr_retorno.deserro = l_mensagem

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml

                  return mr_retorno.xml
               end if
            end if

            commit work
         end if
      end if
   end if
   # War Room
   call cts00g07_apos_grvlaudo(l_servico,l_ano)

   ---> Gera a Ligacao de cancelamento para o Servico Original quando
   ---> Houver ocorrencia de Multiplos
   if g_origem = "WEB" then

      begin work

      call cts10g03_numeracao( 1, "" )
           returning l_lignum
                    ,l_srvnum
                    ,l_srvano
                    ,l_sqlcode
                    ,l_msg
      if l_sqlcode = 0  then
         commit work
      else
         let mr_retorno.coderro = 12
         let mr_retorno.deserro = l_mensagem

         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                ,mr_retorno.coderro
                                ,mr_retorno.deserro)
              returning mr_retorno.xml

         rollback work
      end if


      begin work

      call cts40g03_data_hora_banco(2) returning l_data, l_hora2

      call cts10g00_ligacao(l_lignum,
                            l_data,
                            l_hora2,
                            g_documento.c24soltipcod,
                            g_documento.solnom,
                            "CAN",
                            g_issk.funmat,
                            g_documento.ligcvntip,
                            g_c24paxnum,
                            l_servico,
                            l_ano,
                            "","","","",
                            g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.edsnumref,
                            "","","","",
                            "","","","",
                            "","","","")
                  returning l_tabname,
                            l_sqlcode

      if l_sqlcode  <>  0  then

         let mr_retorno.coderro = 13
         let mr_retorno.deserro = " Erro (", l_sqlcode, ") na gravacao"
                                 ," da tabela ", l_tabname clipped
                                 ,". AVISE A INFORMATICA!"

         call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                ,mr_retorno.coderro
                                ,mr_retorno.deserro)
              returning mr_retorno.xml

         rollback work
      else
         commit work
      end if
   end if


   ---> Gravar 1 ligacao de CAN para cada multiplo
   if l_confirma = "S" then

      ---> atualiza os multiplos
      for l_contador = 1 to 10

         if al_cts29g00[l_contador].atdmltsrvnum is not null then


            {if param.atdsrvnum = al_cts29g00[l_contador].atdmltsrvnum then
               let al_cts29g00[l_contador].atdmltsrvnum =
                   l_atdsrvnum_original
               let al_cts29g00[l_contador].atdmltsrvano =
                   l_atdsrvano_original
            end if}

            begin work

            call cts10g03_numeracao( 1, "" )
                 returning l_lignum
                          ,l_srvnum
                          ,l_srvano
                          ,l_sqlcode
                          ,l_msg

            if l_sqlcode = 0  then
               commit work
            else
               if g_origem is null   or
                  g_origem =  "IFX"  then

                  let l_msg = "CTS16M01 - ", l_msg
                  call ctx13g00(l_sqlcode,"DATKGERAL", l_msg)
                  prompt "" for char l_msg

               else
                  let mr_retorno.coderro = 14
                  let mr_retorno.deserro = l_mensagem

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml
               end if

               rollback work
               exit for
            end if

            begin work

            call cts40g03_data_hora_banco(2) returning l_data, l_hora2

            call cts10g00_ligacao(l_lignum,
                                  l_data,
                                  l_hora2,
                                  g_documento.c24soltipcod,
                                  g_documento.solnom,
                                  "CAN",
                                  g_issk.funmat,
                                  g_documento.ligcvntip,
                                  g_c24paxnum,
                                  al_cts29g00[l_contador].atdmltsrvnum,
                                  al_cts29g00[l_contador].atdmltsrvano,
                                  "","","","",
                                  g_documento.succod,
                                  g_documento.ramcod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  g_documento.edsnumref,
                                  "","","","",
                                  "","","","",
                                  "","","","")
                        returning l_tabname,
                                  l_sqlcode

            if l_sqlcode  <>  0  then

               if g_origem is null   or
                  g_origem =  "IFX"  then
                  error " Erro (", l_sqlcode, ") na gravacao da",
                        " tabela ",l_tabname clipped,". AVISE A INFORMATICA!"
                  prompt "" for char l_tabname
               else
                  let mr_retorno.coderro = 15
                  let mr_retorno.deserro =" Erro (",l_sqlcode,") na gravacao"
                                         ," da tabela ", l_tabname clipped
                                         ,". AVISE A INFORMATICA!"

                  call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,mr_retorno.coderro
                                         ,mr_retorno.deserro)
                       returning mr_retorno.xml
               end if

               rollback work
               exit for
            else
               commit work
            end if
          end if
      end for

   else ---> desvincular o servico da estrutura dos multiplos
      call cts29g00_remover_multiplo(l_servico, l_ano)
           returning l_resultado
                   , l_mensagem


      if l_resultado = 3 then
         if g_origem is null   or
            g_origem =  "IFX"  then
            error l_mensagem
            return
         else

            let mr_retorno.coderro = 16
            let mr_retorno.deserro = l_mensagem

            call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                   ,mr_retorno.coderro
                                   ,mr_retorno.deserro)
                 returning mr_retorno.xml

            return mr_retorno.xml
         end if
      end if
   end if


   if g_origem = "WEB" then
      let mr_retorno.xml =
       "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
       ,"<SERVICO>CANCELAR_SERVICO</SERVICO>"
       ,"<CANCELADO>SIM</CANCELADO>"
       ,"</RESPONSE>"

      return mr_retorno.xml
   end if

end function
