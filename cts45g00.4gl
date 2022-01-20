#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24H                                                #
# Modulo.........: cts45g05                               04/2007             #
# Analista Resp..: Fernando Varani                                            #
# PSI/OSF........:                                                            #
#                  Modulo para retornar limite de cobertura e diárias         #
#                   Serviço de Assistencia ao Passageiro                      #
# ........................................................................... #


globals  "/homedsa/projetos/geral/globals/glct.4gl"



function cts45g00_limites_cob(param)
    define l_clscod char (03)
    define l_sem_uso char (01)
    define l_resultado smallint
    define l_mensagem char(50)
    define l_maxcstvlr like datmservico.atdcstvlr
    define l_limite_diaria smallint

    define param record
        retorno smallint,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        succod like datrligapol.succod,
        aplnumdig like datrligapol.aplnumdig,
        itmnumdig like datrligapol.itmnumdig,
        asitipcod like datmservico.asitipcod,
        ramcod like datrservapol.ramcod,
        asimtvcod like datkasimtv.asimtvcod,
        ligcvntip like datmligacao.ligcvntip,
        hpddiapvsqtd like datmhosped.hpddiapvsqtd --limite diaria
     end record

     let l_sem_uso = null
     let l_resultado = null
     let l_mensagem = null
     let l_clscod = null
     let l_maxcstvlr = null
     let l_limite_diaria = null


 if (param.atdsrvnum is null and param.aplnumdig is null) then
    error "PARAMETROS NULOS - NUMERO DE SERVICO E APOLICE"
    case param.retorno
          when 1
               return 0
          when 2
               return 0,0
    end case
 end if

 if (param.atdsrvnum is not null and param.atdsrvano is not null) then
            call ctd07g02_busca_apolice_servico(2,param.atdsrvnum,param.atdsrvano)
            returning l_resultado,
                l_mensagem,
                param.succod,
                param.ramcod,
                param.aplnumdig,
                param.itmnumdig


 end if

 if param.aplnumdig is null or
    param.aplnumdig = 0     then
    case param.retorno
          when 1
               return 0
          when 2
               return 0,0
    end case
 end if

 call f_funapol_ultima_situacao(param.succod,param.aplnumdig,param.itmnumdig)
     returning g_funapol.*

 call cty05g00_assist_passag(1,param.succod,param.aplnumdig,param.itmnumdig,g_funapol.dctnumseq)
     returning l_clscod

  -- falta obter o valor de acordo com a clausula
 if param.retorno = 1 or param.retorno = 2 then
   if param.asimtvcod = 3  then # recuperacao veiculo
      if param.ramcod = 78    or   # transporte
        (param.ramcod = 171   or   # transporte
         param.ramcod = 195)  then # Garantia Estendida
         let l_maxcstvlr = 250.00
       else
         let l_maxcstvlr = 0.00
       end if
   else
         case param.asitipcod
              when 5  let l_maxcstvlr =  500.00     # taxi
                      if param.ligcvntip <> 64 then
                         if l_clscod = '035'     and
                           (param.asimtvcod = 1  or
                            param.asimtvcod = 2) then
                            let l_maxcstvlr = 1500.00
                          else
                            let l_maxcstvlr = 1000.00      # taxi

                             if l_clscod = '046' or
                                l_clscod = '46R' or
                                l_clscod = '047' or
                                l_clscod = '47R' then
                                if param.asimtvcod = 11 then
                                  let l_maxcstvlr = 200.00
                                else
                                  let l_maxcstvlr = 2000.00
                                end if
                             end if
                             if l_clscod = '033' or l_clscod = '33R' then
                                let l_maxcstvlr = 2000.00
                             end if

                             if (param.ramcod = 78    or   # transp.
                                (param.ramcod = 171   or   # transporte
                                 param.ramcod = 195)) then # Garantia Estendida
                                 let l_maxcstvlr = 500.00
                             end if
                           end if
                      end if
                                { if (param.ramcod = 78   or   # transp.
                                     param.ramcod = 171)  and  # transp.
                                    param.asimtvcod = 3 then # recup. de
                                    let l_maxcstvlr   = 250.00   # veiculo
                                 end if}
              when 10 let l_maxcstvlr =  500.00       # aviao
                     if param.ligcvntip <> 64 then
                        let l_maxcstvlr = 1000.00          # aviao
                        if l_clscod = '033' or l_clscod = '33R' then
                           let l_maxcstvlr = 2000.00
                        end if
                        if l_clscod = '046' or
                           l_clscod = '46R' or
                           l_clscod = '47R' then
                           let l_maxcstvlr = 2000.00
                        end if
                        if l_clscod = '047' then
                        	  let l_maxcstvlr = 200.00
                        end if
                        if (param.ramcod = 78    or   # transp.
                           (param.ramcod = 171   or   # transporte
                            param.ramcod = 195)) then # Garantia Estendida
                            let l_maxcstvlr = 500.00
                        end if
                     end if
                                 {if (param.ramcod = 78    or  # transp.
                                     param.ramcod = 171)  and # transp.
                                     param.asimtvcod = 3 then # recup.  de
                                    let l_maxcstvlr   = 250.00   # veiculo
                                 end if}
              when 11 let l_maxcstvlr = 2500.00 -- Remoção Hospitalar
		                 if l_clscod = '046' or
			                  l_clscod = '46R' or
			                  l_clscod = '047' or
			                  l_clscod = '47R' then
			                     let l_maxcstvlr = 5000.00
                     end if
                     if param.ramcod = 78   or   # transporte
                       (param.ramcod = 171  or   # transporte
                        param.ramcod = 195) then # Garantia Estendida
                        let l_maxcstvlr = 1000.00
                     end if

                     if l_clscod = '033' or l_clscod = '33R' then --varani
                        let l_maxcstvlr = 5000.00
                     end if

              when 12 let l_maxcstvlr = 1500.00 --  Traslado de Corpos
	             if l_clscod = '046' or
                       	l_clscod = '46R' or
		        l_clscod = '047' or
		        l_clscod = '47R' then
                        let l_maxcstvlr = 3000.00
                     end if
                     if l_clscod = '033' or l_clscod = '33R' then  --varani
                         let l_maxcstvlr = 3000.00
                     end if

              when 13
                     if (l_clscod = '033' or l_clscod = '33R') then
                        let l_maxcstvlr = 400.00
                        if param.hpddiapvsqtd < 7 then
                            let l_limite_diaria = param.hpddiapvsqtd
                        else
                            let l_limite_diaria = 7
                        end if
                     else
                        let l_maxcstvlr = 200.00
                        if l_clscod = '046' or
                           l_clscod = '46R' or
                           l_clscod = '047' or
                           l_clscod = '47R' then
                           let l_maxcstvlr = 400.00
                        end if
                        if param.hpddiapvsqtd < 7 then
                            let l_limite_diaria = param.hpddiapvsqtd
                        else
                            let l_limite_diaria = 7
                        end if
                     end if

              when 16 let l_maxcstvlr =  500.00 -- Transporte Rodoviario
                       if param.ligcvntip <> 64 then
                          let l_maxcstvlr =  800.00
                          if l_clscod = '033' or l_clscod = '33R' then --varani
                             let l_maxcstvlr = 2000.00
                          end if
                          if l_clscod = '046' or
                             l_clscod = '46R' or
                             l_clscod = '047' or
                             l_clscod = '47R' then
                             let l_maxcstvlr = 2000.00
                          end if
                       end if
         end case
   end if
 end if

 case param.retorno
       when 1
          if (param.asimtvcod = 4 and param.hpddiapvsqtd > 7 )    then   ##  Outras Situacoes  --linha 2753 cts11m00
             let l_maxcstvlr = -1
                        { call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                         returning ws.confirma}
         end if
       return l_maxcstvlr
       when 2
          if param.hpddiapvsqtd <= 7 then
             let l_maxcstvlr = -2
          end if
       return l_maxcstvlr
             ,l_limite_diaria
 end case


end function
