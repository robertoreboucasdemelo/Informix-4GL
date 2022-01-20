#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTD34G00                                                   #
# ANALISTA RESP..: Sergio Burini                                              #
# PSI/OSF........: PSI-2013-00435/EV - ROTEIRO MANUAL DE SERVIÇOS             #
#                  MODULO RESPONSA. PELA ATUAL. HORA COMBINADA COM O CLIENTE  #
# ........................................................................... #
# DESENVOLVIMENTO: Sergio Burini                                              #
# LIBERACAO......: 24/01/2012                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# ........................................................................... #

 database porto
 
#-------------------------------------#
 function ctd34g00_atl_horacomb(param)
#-------------------------------------#

     define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         opcao     char(01)
     end record
     
     define lr_aux record
         atddatprg    like datmservico.atddatprg,
         atdhorprg    like datmservico.atdhorprg,
         atdlibdat    like datmservico.atdlibdat,
         atdlibhor    like datmservico.atdlibhor,
         atdhorpvt    like datmservico.atdhorpvt,
         dathorcomchr char(20),               
         dathorcom    datetime year to minute
     end record
     
     define l_hor     char(02),
            l_min     char(02),
            l_err     smallint,
            l_msg     char(100)
     
     initialize lr_aux.*, 
                l_hor, 
                l_min to null
     
     # CASO SERVIÇO RECEBIDO SEJA NULO, RETORNA ERRO
     if  param.atdsrvnum is null or param.atdsrvnum = " " and 
         param.atdsrvano is null or param.atdsrvano = " " then 
         let l_err = 1
         let l_msg = "Serviço nulo" 
         return l_err, l_msg
     end if     
     
     # BUSCA DADOS PARA CALCULO DA HORA COMBINADA
     whenever error continue
       select atddatprg,
              atdhorprg,
              atdlibdat,
              atdlibhor,
              atdhorpvt
         into lr_aux.atddatprg,
              lr_aux.atdhorprg,
              lr_aux.atdlibdat,
              lr_aux.atdlibhor,
              lr_aux.atdhorpvt
         from datmservico
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
     whenever error stop
     
     if  sqlca.sqlcode <> 0 then 
	 let l_err = sqlca.sqlcode
         let l_msg = 'servico nao encontrado.'
	 return l_err, l_msg
     end if 
     
     ################################################################################################
     #                                  CALCULO DA HORA COMBINADA                                   #
     # SERVIÇO PROGRAMADO.................... HORA COMBINADA = HORA PROGRAMADA                      #
     # SERVIÇO IMEDIATO COM PREVISÃO......... HORA COMBINADA = HORA LIBERAÇÃO DO SERVIÇO + PREVISAO #
     # SERVIÇO IMEDIATO SEM PREVISÃO......... HORA COMBINADA = HORA LIBERAÇÃO DO SERVIÇO            #    
     ################################################################################################
     
     #----------------- CALCULANDO A HORA COMBINADA COM O CLIENTE -----------------#
     if (lr_aux.atddatprg is not null and  lr_aux.atddatprg <> ' ') and
        (lr_aux.atdhorprg is not null and  lr_aux.atdhorprg <> ' ') then
         # SE A HORA DO SERVIÇO FOR PROGRAMADO, A HORA COMBINADA SERÁ A MESMA DA PROGRAMADA
         let lr_aux.dathorcomchr = extend(lr_aux.atddatprg,year to day)," ", lr_aux.atdhorprg
     else
         let lr_aux.dathorcomchr = extend(lr_aux.atdlibdat,year to day)," ", lr_aux.atdlibhor
     
         # ADICIONA A PREVISÃO APENAS SE ELA NAO FOR NULA
         if  lr_aux.atdhorpvt is not null and lr_aux.atdhorpvt <> ' ' then
     
             # TRANSFORMA O CHAR PARA DATETIME YEAR TO SECOND
             let lr_aux.dathorcom = lr_aux.dathorcomchr
     
             # ADICIONA A HORA DA PREVISÃO
             let l_hor = extend(lr_aux.atdhorpvt, hour to hour)
             let l_min = extend(lr_aux.atdhorpvt, minute to minute)
             let lr_aux.dathorcom = lr_aux.dathorcom + l_min units minute
             let lr_aux.dathorcom = lr_aux.dathorcom + l_hor units hour
             let lr_aux.dathorcomchr = lr_aux.dathorcom
     
         end if
     end if
     
     let lr_aux.dathorcom = lr_aux.dathorcomchr
     
     # ATUALIZA O SERVIÇO APENAS SE A OPÇÃO ESTIVER COMO "A" - ATUALIZAR
     if  param.opcao = 'A' then
         whenever error continue
         update datmservico
            set srvcbnhor = lr_aux.dathorcom
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano    
         whenever error stop
         
         if  sqlca.sqlerrd[3] = 1 then
             let l_err = 0 
             let l_msg = "Atualização realizada com sucesso"
             return l_err, l_msg
         else
             let l_err = 2 
             let l_msg = "Não foi possivel realizar a atualizacao"
             return l_err, l_msg         
         end if
     else
         # CASO O SERVIÇO NÃO SEJA ATUALIZADO RETORNA A HORA COMBINADA
         let l_err = 0
         let l_msg = lr_aux.dathorcom     
     end if

 end function