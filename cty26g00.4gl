#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cty26g00                                                   #
# Objetivo.......: Funcoes Ct24h Auto                                         #
# Analista Resp. : Junior (FORNAX)                                            #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: Junior (FORNAX)                                            #
# Liberacao      :   /  /                                                     #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 10/09/2012 Fornax-Hamilton PSI-2012-16039 - EV - Criacao de novas funcoes   #
#                                                  cty26g00_srv_segu()        #
#                                                  cty26g00_ims_veic()        #
#-----------------------------------------------------------------------------#
database porto
#--------------------------------------------------------#
function cty26g00_prep()
#--------------------------------------------------------#
   define l_sql    char(500)

   let l_sql = 'select imsvlr from abbmcasco '
              ,'where succod  = ? '
              ,'and aplnumdig = ? '
              ,'and itmnumdig = ? '
              ,'and dctnumseq = ? '
   prepare p_cty26g00_01 from l_sql
   declare c_cty26g00_01 cursor for p_cty26g00_01

   let l_sql = 'select segnumdig from abbmdoc '
              ,'where succod  = ? '
              ,'and aplnumdig = ? '
              ,'and itmnumdig = ? '
              ,'and dctnumseq = ? '
   prepare p_cty26g00_02 from l_sql
   declare c_cty26g00_02 cursor for p_cty26g00_02

   let l_sql = 'select pestip from gsakseg '
              ,'where segnumdig  = ? '
   prepare p_cty26g00_03 from l_sql
   declare c_cty26g00_03 cursor for p_cty26g00_03

end function

#--------------------------------------------------------#
function cty26g00_srv_auto(lr_param)
#--------------------------------------------------------#

define lr_param record
  ramcod     like  datrservapol.ramcod,
  succod     like  abbmveic.succod    ,
  aplnumdig  like  abbmveic.aplnumdig ,
  itmnumdig  like  abbmveic.itmnumdig ,
  astcod     like  datkassunto.c24astcod,
  asitipcod  like  datmservico.asitipcod
end record

define lr_retorno record
  erro         char(40),
  clscod       like datrsrvcls.clscod,
  data_calculo date    ,
  flag_endosso char(01)
end record

define l_flagbloqueio char(01)
      ,l_flag_endosso char(01)
      ,l_qtde_at_ap   integer
      ,l_qtde_at_pr   integer
      ,l_resultado    char(10)
      ,l_mensagem     char(40)
      ,l_prporgpcp    like abamdoc.prporgpcp
      ,l_prpnumpcp    like abamdoc.prpnumpcp
      ,l_qtd_atendimento integer
      ,l_qtd_limite_util integer
      ,l_saldo           integer


  initialize lr_retorno.* to null

  let l_flagbloqueio = "N"
  let l_qtd_atendimento = 0
  let l_qtd_limite_util = 0
  let l_saldo      = 0
  let l_qtde_at_ap = 0
  let l_qtde_at_pr = 0


  call cty26g01_clausula(lr_param.succod   ,
		                     lr_param.aplnumdig,
		                     lr_param.itmnumdig)
    returning lr_retorno.erro        ,
	            lr_retorno.clscod      ,
	            lr_retorno.data_calculo,
	            lr_retorno.flag_endosso

    if ((lr_retorno.clscod <> '044'  and
	      lr_retorno.clscod <> "44R"   and
	      lr_retorno.clscod <> '048'   and
	      lr_retorno.clscod <> "48R") or lr_retorno.clscod is null) and
	     (lr_param.asitipcod <> 1  and
	      lr_param.asitipcod <> 3  and
	      lr_param.asitipcod <> 4) then

       return l_flagbloqueio

    end if

    if lr_retorno.clscod = '044' or
       lr_retorno.clscod = '048' then
       return l_flagbloqueio
    end if

  call cty26g01_qtd_servico(lr_param.ramcod
                           ,lr_param.succod
                           ,lr_param.aplnumdig
                           ,lr_param.itmnumdig
			                     ,l_prporgpcp
			                     ,l_prpnumpcp
			                     ,lr_retorno.data_calculo
			                     ,lr_param.astcod, ""
                           ,lr_param.asitipcod)
  returning l_qtde_at_ap

    # Obter proposta original atraves da apolice

    if l_flag_endosso = "N" then
       call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
	     returning l_resultado,l_mensagem,l_prporgpcp,l_prpnumpcp

	     if l_resultado <> 1 then
	        return l_flagbloqueio
	     end if

	     let l_qtde_at_pr = cty26g01_qtd_servico("",
		   				                                "",
		   			                                  "",
		   				                                "",
		   			                                  l_prporgpcp,
		   				                                l_prpnumpcp,
		   				                                lr_retorno.data_calculo,
		   				                                lr_param.astcod, "",
		   				                                lr_param.asitipcod)

    end if

    let l_qtd_atendimento = l_qtde_at_ap + l_qtde_at_pr
    let l_qtd_limite_util = 3
    let l_saldo = l_qtd_limite_util - l_qtd_atendimento
    if l_saldo = 0   then
       let l_flagbloqueio = "S"
    end if
    return l_flagbloqueio

end function

#--------------------------------------------------------#
function cty26g00_srv_pass(l_param)
#--------------------------------------------------------#

define l_param record
  ramcod     like  datrservapol.ramcod,
  succod     like  abbmveic.succod    ,
  aplnumdig  like  abbmveic.aplnumdig ,
  itmnumdig  like  abbmveic.itmnumdig ,
  c24astcod  like  datmligacao.c24astcod,
  asitipcod  like  datmservico.asitipcod,
  asimvtcod  smallint
end record


define l_cod_erro      char(40),
       l_clscod        like datrsrvcls.clscod,
       l_data_calculo  date    ,
       l_qtde          integer,
       l_flag_endosso  char(01),
       l_confirna      char(01)


initialize l_cod_erro,
	   l_clscod,
	   l_data_calculo,
	   l_flag_endosso to null

  let l_qtde = 0

  call cty26g01_clausula(l_param.succod   ,
		                     l_param.aplnumdig,
		                     l_param.itmnumdig)
  returning l_cod_erro    ,
	          l_clscod      ,
	          l_data_calculo,
	          l_flag_endosso

  if l_data_calculo <= "31/05/2012" then
      return "N", l_clscod
  end if

  if (l_clscod <> '044' and
      l_clscod <> '44R' and
      l_clscod <> '048' and
      l_clscod <> '48R') or l_clscod is null then
     return "N", l_clscod
  end if

 #----------------------------------------------------- Clausula 044 -------#
  if l_clscod = '044' then
     #-------------------------------------#
     # Remocao Hospitalar                  #
     #-------------------------------------#
     if l_param.asitipcod = 11 then
        call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
      	returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Retorno a domicilio e Cont. viagem  #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
        (l_param.asimvtcod = 1 or
         l_param.asimvtcod = 2) then
        call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Recuperacao de veiculo              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 3 then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL CLASSE ECONOMICA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Envio de Familiar                   #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 12 then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA, IDA E VOLTA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #--------------------------------------#
     # Transporte Taxi, Aviao, Onibus       #
     # Transporte em caso de roubo ou furto #
     #--------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         (l_param.asimvtcod = 11 or
          l_param.asimvtcod = 13) then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Translado de corpos                 #
     # Obito e outros                      #
     #-------------------------------------#
     if  l_param.asitipcod = 12 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 7)  then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Hospedagem                          #
     # Aguarda conserto e outros           #
     #-------------------------------------#
     if  l_param.asitipcod = 13 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 5)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
	       returning l_confirna
         return "N", l_clscod
     end if

     if l_param.asitipcod = 5 and l_param.asimvtcod = 14 then
        if l_param.c24astcod <> "S93"  then
            call cty26g01_qtd_servico_mtv(l_param.ramcod
                                         ,l_param.succod
                                         ,l_param.aplnumdig
                                         ,l_param.itmnumdig
			                                   ,'' ,''
			                                   ,l_data_calculo
			                                   ,l_param.c24astcod
                                         ,l_param.asitipcod
                                         ,l_param.asimvtcod)
           returning l_qtde

            if l_qtde > 0 then
               return "S", l_clscod
	          end if
	       end if

        call cts08g01("A","N",
		      "Este transporte deve ser realizado",
		      "apenas dentro do municipio de",
		      "residencia e limitado a 50 km","")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, veiculo particular #
     # Motorista Profissional              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
	       returning l_confirna
         return "N", l_clscod
     end if

  end if

 #----------------------------------------------------- Clausula 044R ------#
  if l_clscod = '44R' then
     #-------------------------------------#
     # Remocao Hospitalar                  #
     #-------------------------------------#
     if l_param.asitipcod = 11 then
        call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS", " ATE R$ 5.000,00 POR EVENTO","")
	      returning l_confirna
        return "N", l_clscod
     end if

     #--------------------------------------#
     # Transporte Taxi, Aviao, Onibus       #
     # Transporte em caso de roubo ou furto #
     #--------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         (l_param.asimvtcod = 11 or
          l_param.asimvtcod = 13) then
         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Retorno a domicilio e Cont. viagem  #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
        (l_param.asimvtcod = 1 or
         l_param.asimvtcod = 2) then
        call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 2.000,00","")
       	returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Recuperacao de veiculo              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 3 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "VALOR DE UMA PASSAGEM AEREA","NACIONAL CLASSE ECONOMICA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Envio de Familiar                   #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 12 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "VALOR DE UMA PASSAGEM","AEREA NACIONAL CLASSE ECONOMICA, IDA E VOLTA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #--------------------------------------#
     # Transporte Taxi, Aviao, Onibus       #
     # Transporte em caso de roubo ou furto #
     #--------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 13 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 200,00","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Translado de corpos                 #
     # Obito e outros                      #
     #-------------------------------------#
     if  l_param.asitipcod = 12 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 7)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "ATE R$ 3.000,00","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Hospedagem                          #
     # Aguarda conserto e outros           #
     #-------------------------------------#
     if  l_param.asitipcod = 13 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 5)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, veiculo particular #
     # Motorista Profissional              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS:", " ATE R$ 2.000,00","")
	       returning l_confirna
         return "N", l_clscod
     end if
  end if

 #----------------------------------------------------- Clausula 048 -------#
  if l_clscod = '048' then
     #-------------------------------------#
     # Remocao Hospitalar                  #
     #-------------------------------------#
     if l_param.asitipcod = 11 then
        call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO,", " ATE R$ 2.500,00 POR EVENTO","")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Envio de Familiar                   #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 12 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "VALOR DE UMA PASSAGEM","AEREA NACIONAL CLASSE ECONOMICA, IDA E VOLTA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Translado de corpos                 #
     # Obito e outros                      #
     #-------------------------------------#
     if  l_param.asitipcod = 12 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 7)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "ATE R$ 1.500,00","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Retorno a domicilio e Cont. viagem  #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
        (l_param.asimvtcod = 1 or
         l_param.asimvtcod = 2) then
        call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO,  ", " COM LIMITE TOTAL DAS DESPESAS: ","ATE R$ 1.000,00 POR EVENTO")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Hospedagem                          #
     # Aguarda conserto e outros           #
     #-------------------------------------#
     if  l_param.asitipcod = 13 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 5)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Recuperacao de veiculo              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 3 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "VALOR DE UMA PASSAGEM AEREA","NACIONAL CLASSE ECONOMICA.")
	       returning l_confirna
         return "N", l_clscod
     end if
  end if

 #----------------------------------------------------- Clausula 48R -------#
  if l_clscod = '48R' then
     #-------------------------------------#
     # Remocao Hospitalar                  #
     #-------------------------------------#
     if l_param.asitipcod = 11 then
        call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS:", " ATE R$ 2.500,00 ","")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Envio de Familiar                   #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 12 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ",  "VALOR DE UMA PASSAGEM","AEREA NACIONAL CLASSE ECONOMICA, IDA E VOLTA.")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Translado de corpos                 #
     # Obito e outros                      #
     #-------------------------------------#
     if  l_param.asitipcod = 12 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 7)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "ATE R$ 1.500,00","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Retorno a domicilio e Cont. viagem  #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
        (l_param.asimvtcod = 1 or
         l_param.asimvtcod = 2) then
        call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 1.000,00 ","")
	      returning l_confirna
        return "N", l_clscod
     end if

     #-------------------------------------#
     # Hospedagem                          #
     # Aguarda conserto e outros           #
     #-------------------------------------#
     if  l_param.asitipcod = 13 and
         (l_param.asimvtcod = 4  or
         l_param.asimvtcod = 5)  then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
	       returning l_confirna
         return "N", l_clscod
     end if

     #-------------------------------------#
     # Transporte Taxi, Aviao, Onibus      #
     # Recuperacao de veiculo              #
     #-------------------------------------#
     if (l_param.asitipcod = 10 or
         l_param.asitipcod = 5  or
         l_param.asitipcod = 16) and
         l_param.asimvtcod = 3 then
         call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS: ", "VALOR DE UMA PASSAGEM AEREA"," NACIONAL CLASSE ECONOMICA.")
	       returning l_confirna
         return "N", l_clscod
     end if
  end if

  return "N", l_clscod

end function

#--------------------------------------------------------#
function cty26g00_srv_segu(lr_param)
#--------------------------------------------------------#

   #--> PSI-2012-16039/EV - Criacao da funcao
   #-----------------------------------------

   define lr_param record
	  ramcod     like  gtakram.ramcod     ,
	  succod     like  abbmveic.succod    ,
	  aplnumdig  like  abbmveic.aplnumdig ,
	  itmnumdig  like  abbmveic.itmnumdig ,
    c24astcod  like  datmligacao.c24astcod
   end record

   define lr_retorno record
          errocod    smallint, #(0 = OK  ou  1 = Ocorreu Erro)
          clscod     char(03),
          clcdat     date    ,
          edsflg     char(01)  #(tipos 1 ou 2 ou 3/63 = "S", caso contrario = "N")
   end record
   define lr_retorno2 record
          errocod     smallint,
          clscod      char(03),
          clcdat      date    ,
          edsflg      char(01)
   end record

   define l_limite     char(01)
   define l_qtd_limite smallint
   define l_qtd_servicos_utilizados smallint
   initialize lr_retorno2.* to null

   call cty26g01_clausula(lr_param.succod   ,
                          lr_param.aplnumdig,
                          lr_param.itmnumdig)
      returning lr_retorno.errocod,
                lr_retorno.clscod ,
                lr_retorno.clcdat ,
                lr_retorno.edsflg

   if lr_retorno.clscod <> '044' and
      lr_retorno.clscod <> '44R' then
      let l_limite = 'N'
      if cty26g00_valida_limite(lr_param.c24astcod,
      	                        lr_retorno.clscod ) then
      	 let l_limite = 'S'
      end if
   else
      #-----------------------------------------------------------
      # Obter a Data de Calculo
      #-----------------------------------------------------------
      call faemc144_clausula(lr_param.succod     ,
                             lr_param.aplnumdig  ,
                             lr_param.itmnumdig)
                   returning lr_retorno2.errocod ,
                             lr_retorno2.clscod  ,
                             lr_retorno2.clcdat  ,
                             lr_retorno2.edsflg
      if cty26g00_valida_limite(lr_param.c24astcod,
      	                        lr_retorno2.clscod) then
      	 let l_limite = 'S'
      	 return l_limite
      end if
      if lr_param.c24astcod = 'S40' and
         lr_retorno.clscod  = '044' then
         let l_qtd_limite = 2
      end if

      if lr_param.c24astcod = 'S40' and
         lr_retorno.clscod  = '44R' then
         let l_qtd_limite = 1
      end if

      #--> Obter a qtd de servigos que ja foram utilizados
      #---------------------------------------------------
      call cta02m15_qtd_servico(lr_param.ramcod   ,
                                lr_param.succod   ,
                                lr_param.aplnumdig,
                                lr_param.itmnumdig,
                                ""                , ##prporgpcp
                                ""                , ##prpnumpcp
                                lr_retorno.clcdat ,
                                lr_param.c24astcod,
                                '' )
         returning l_qtd_servicos_utilizados

      if l_qtd_servicos_utilizados >= l_qtd_limite then
         let l_limite = 'S'
      else
         let l_limite = 'N'
      end if
   end if

   return l_limite

end function

#--------------------------------------------------------#
function cty26g00_srv_caca(lr_parametro)
#--------------------------------------------------------#

define lr_parametro  record
  ramcod     like  datrservapol.ramcod,
  succod     like  abbmveic.succod    ,
  aplnumdig  like  abbmveic.aplnumdig ,
  itmnumdig  like  abbmveic.itmnumdig ,
  astcod     like  datkassunto.c24astcod,
  bnfnum     like  datrligsau.bnfnum  ,
  crtsaunum  like  datksegsau.crtsaunum,
  socntzcod  like  datmsrvre.socntzcod,
  saldo      integer
end record

define l_retorno   record
  errocod      smallint
 ,clscod       char(03)
 ,clcdat       date
 ,edsflg       char(01)
end record

define lr_retorno record
     result     char (1)              ,
     dctnumseq  like abbmdoc.dctnumseq,
     vclsitatu  like abbmitem.vclsitatu,
     autsitatu  like abbmitem.autsitatu,
     dmtsitatu  like abbmitem.dmtsitatu,
     dpssitatu  like abbmitem.dpssitatu,
     appsitatu  like abbmitem.appsitatu,
     vidsitatu  like abbmitem.vidsitatu
end record

define l_qtd_limite  integer
      ,l_qtd_srvs    integer
      ,l_qtd_srvs_p  integer
      ,l_clscod      char(03)
      ,l_saldo_s     integer
      ,l_flag_limite char(01)
      ,l_resultado   smallint
      ,l_condicao    smallint
      ,l_mensagem    char(70)
      ,l_prporgpcp    like abamdoc.prporgpcp
      ,l_prpnumpcp    like abamdoc.prpnumpcp
      ,lr_autimsvlr    like abbmcasco.imsvlr

   let  l_qtd_srvs = 0
   let  l_qtd_srvs_p = 0
   let  l_qtd_limite = 999
   let  l_flag_limite = "N"
   let  l_saldo_s = lr_parametro.saldo

   call cty26g01_clausula(lr_parametro.succod
			 ,lr_parametro.aplnumdig
			 ,lr_parametro.itmnumdig)
   returning l_retorno.errocod
			      ,l_retorno.clscod
			      ,l_retorno.clcdat
			      ,l_retorno.edsflg

  if (l_retorno.clscod <> "044" and
      l_retorno.clscod <> "44R" and
      l_retorno.clscod <> "048" and
      l_retorno.clscod <> "48R") or l_retorno.clscod is null then
      return l_flag_limite, l_saldo_s, l_qtd_limite,
	     (l_qtd_srvs+l_qtd_srvs_p) ,0
  end if

  if l_retorno.clscod = "044" then
     if lr_parametro.astcod = "S60" then
        if lr_parametro.socntzcod = 207 or #Mudanca Imobiliario
           lr_parametro.socntzcod = 273 or
	         lr_parametro.socntzcod = 274 then
           let l_qtd_limite =  1
        else
           let lr_parametro.socntzcod = "" #pra considerar todas
        end if
     end if

	   if lr_parametro.astcod = "S54" then
        let l_qtd_limite = 6
        call cty26g01_qtd_servico_s54(lr_parametro.ramcod
		                                ,lr_parametro.succod
		                                ,lr_parametro.aplnumdig
		                                ,lr_parametro.itmnumdig
                                     ,""
		                                ,""
		                                ,l_retorno.clcdat
		                                ,lr_parametro.astcod )
        returning  l_qtd_srvs

        let l_saldo_s = l_qtd_limite - l_qtd_srvs
        if l_saldo_s <= 0 then
	           let l_flag_limite = "S"
	      end if

        return l_flag_limite, l_saldo_s, l_qtd_limite,
	             (l_qtd_srvs+l_qtd_srvs_p),1

    end if

	 if lr_parametro.astcod = "S41" or
	    lr_parametro.astcod = "S42" then
            let l_qtd_limite = 2
   end if

	 if lr_parametro.astcod = "HDK" or
	    lr_parametro.astcod = "S66" or
	    lr_parametro.astcod = "S67" then

	    if lr_parametro.socntzcod = 206 then ##Conectividade
	       let l_qtd_limite = 2
      else
	       let lr_parametro.socntzcod = "" #pra considerar todas
	       if lr_parametro.astcod = "S66" then
	          let l_qtd_limite = 2
         else
	          let l_qtd_limite = 1
         end if
     end if

     let  l_saldo_s = l_qtd_limite

   end if
  end if

  if l_retorno.clscod = "44R" then
     if lr_parametro.astcod = "S60" then
        if lr_parametro.socntzcod = 207 or #Mudanca Imobiliario
           lr_parametro.socntzcod = 273 or
	         lr_parametro.socntzcod = 274 then
           let l_qtd_limite =  1
        else
           let l_qtd_limite = 3
           let lr_parametro.socntzcod = "" #pra considerar todas
        end if
     else
        let l_qtd_limite = 3  ## p/assunto S63
     end if

	   if lr_parametro.astcod = "S41" or
	      lr_parametro.astcod = "S42" then
              let l_qtd_limite = 2
     end if

	   if lr_parametro.astcod = "S54" then
           let l_qtd_limite = 1
           call cty26g01_qtd_servico_s54(lr_parametro.ramcod
				                                ,lr_parametro.succod
				                                ,lr_parametro.aplnumdig
				                                ,lr_parametro.itmnumdig
                                        ,""
				                                ,""
				                                ,l_retorno.clcdat
				                                ,lr_parametro.astcod )
           returning  l_qtd_srvs

           let l_saldo_s = l_qtd_limite - l_qtd_srvs
           if l_saldo_s <= 0 then
	           let l_flag_limite = "S"
	         end if

           return l_flag_limite, l_saldo_s, l_qtd_limite,
		              (l_qtd_srvs+l_qtd_srvs_p),1

       end if

	     if lr_parametro.astcod = "HDK" or
	        lr_parametro.astcod = "S66" or
	        lr_parametro.astcod = "S67" then

	        let lr_parametro.socntzcod = "" #pra considerar todas
	        if lr_parametro.astcod = "S66" then
	           let l_qtd_limite = 2
          else
	           let l_qtd_limite = 1
          end if

          let  l_saldo_s = l_qtd_limite
       end if

  end if

  if l_retorno.clscod = "048"  or l_retorno.clscod = "48R"  then

     let l_qtd_limite = 0

     if lr_parametro.astcod = "RET" then
        let l_flag_limite = "N"
        return l_flag_limite, l_saldo_s, l_qtd_limite,
              (l_qtd_srvs+l_qtd_srvs_p),1
     end if
	   if lr_parametro.astcod = "S60" or lr_parametro.astcod = "S63" then
           call cty26g00_dados_segurado(lr_parametro.succod   ,
			                                  lr_parametro.aplnumdig,
			                                  lr_parametro.itmnumdig)
           returning l_condicao

           if l_condicao = true then
              let l_qtd_limite = 1
	         else
	            let l_flag_limite = "S"
	            return l_flag_limite, l_saldo_s, l_qtd_limite,
		                 (l_qtd_srvs+l_qtd_srvs_p),1
	         end if
	    end if

	    if lr_parametro.astcod = "HDK" or
	       lr_parametro.astcod = "S66" or
	       lr_parametro.astcod = "S67" then

	       #if lr_parametro.socntzcod is null then
	          let l_qtd_limite = 2
                  let  l_saldo_s = l_qtd_limite
                  let lr_parametro.socntzcod = null
               #end if
      end if

	    if lr_parametro.astcod = "S54" then
	       let l_qtd_limite = 1

               call cty26g01_qtd_servico_s54(lr_parametro.ramcod
	    			                                ,lr_parametro.succod
	    			                                ,lr_parametro.aplnumdig
	    			                                ,lr_parametro.itmnumdig
                                            ,""
	    			                                ,""
	    			                                ,l_retorno.clcdat
	    			                                ,lr_parametro.astcod )
               returning  l_qtd_srvs

               let l_saldo_s = l_qtd_limite - l_qtd_srvs
               if l_saldo_s <= 0 then
	                let l_flag_limite = "S"
	             end if

               return l_flag_limite, l_saldo_s, l_qtd_limite,
	    	              (l_qtd_srvs+l_qtd_srvs_p),1

      end if

  end if

  call cty26g01_qtd_servicos_caca(lr_parametro.ramcod
			                            ,lr_parametro.succod
			                            ,lr_parametro.aplnumdig
			                            ,lr_parametro.itmnumdig
                                  ,""
			                            ,""
			                            ,l_retorno.clcdat
			                            ,lr_parametro.astcod
			                            ,lr_parametro.bnfnum
                                 ,lr_parametro.socntzcod)
  returning l_qtd_srvs

  if l_retorno.edsflg = "N" then
     call cty05g00_prp_apolice(lr_parametro.succod,lr_parametro.aplnumdig, 0)
         returning l_resultado,l_mensagem,l_prporgpcp,l_prpnumpcp

     if l_resultado <> 1 then
        return l_flag_limite, l_saldo_s, l_qtd_limite, (l_qtd_srvs+l_qtd_srvs_p),1
	   end if

     call cty26g01_qtd_servicos_caca(""
		                                ,""
		                                ,""
		                                ,""
                                    ,l_prporgpcp
		                                ,l_prpnumpcp
		                                ,l_retorno.clcdat
		                                ,lr_parametro.astcod
		                                ,lr_parametro.bnfnum
                                    ,lr_parametro.socntzcod)
    returning l_qtd_srvs_p

  end if

  let l_saldo_s = l_qtd_limite - (l_qtd_srvs + l_qtd_srvs_p)
  if l_saldo_s <= 0 then
	  let l_flag_limite = "S"
  end if

  return l_flag_limite, l_saldo_s, l_qtd_limite, (l_qtd_srvs+l_qtd_srvs_p),1

end function

#--------------------------------------------------------#
function cty26g00_ims_veic(lr_param)
#--------------------------------------------------------#

   #--> PSI-2012-16039/EV - Criacao da funcao
   #-----------------------------------------
   define lr_param record
	  succod     like  abbmveic.succod    ,
	  aplnumdig  like  abbmveic.aplnumdig ,
	  itmnumdig  like  abbmveic.itmnumdig
   end record
   define l_dctnumseq integer
   define l_autimsvlr like abbmcasco.imsvlr

   define lr_retorno record
          result     char (1)              ,
          dctnumseq  like abbmdoc.dctnumseq,
          vclsitatu  like abbmitem.vclsitatu,
          autsitatu  like abbmitem.autsitatu,
          dmtsitatu  like abbmitem.dmtsitatu,
          dpssitatu  like abbmitem.dpssitatu,
          appsitatu  like abbmitem.appsitatu,
          vidsitatu  like abbmitem.vidsitatu
   end record

   initialize lr_retorno.* to null

   #--> Buscando a ultima situacao valida da apolice
   #------------------------------------------------
   call F_FUNAPOL_ULTIMA_SITUACAO(lr_param.succod   ,
				  lr_param.aplnumdig,
				  lr_param.itmnumdig)
      returning lr_retorno.*

   call cty26g00_prep()

   #--> Buscando o valor da importancia segurada do veiculo
   #-------------------------------------------------------
   whenever error continue
   open c_cty26g00_01 using lr_param.succod
                           ,lr_param.aplnumdig
                           ,lr_param.itmnumdig
                           ,lr_retorno.dctnumseq
   fetch c_cty26g00_01 into l_autimsvlr
   whenever error stop


   if l_autimsvlr is null then
      let l_autimsvlr = 0
   end if

   return l_autimsvlr

end function #--> cty26g00_ims_veic()
#------------------------------------------------------------------------------#

function cty26g00_dados_segurado(lr_param)

   define lr_param record
          succod     like  abbmveic.succod    ,
          aplnumdig  like  abbmveic.aplnumdig ,
          itmnumdig  like  abbmveic.itmnumdig
   end record

   define lr_retorno record
          result     char (1)              ,
          dctnumseq  like abbmdoc.dctnumseq,
          vclsitatu  like abbmitem.vclsitatu,
          autsitatu  like abbmitem.autsitatu,
          dmtsitatu  like abbmitem.dmtsitatu,
          dpssitatu  like abbmitem.dpssitatu,
          appsitatu  like abbmitem.appsitatu,
          vidsitatu  like abbmitem.vidsitatu
   end record

   define l_autimsvlr like abbmcasco.imsvlr
   define l_segnumdig like gsakseg.segnumdig
   define l_pestip    like gsakseg.pestip
   define l_condicao  smallint

   initialize lr_retorno.* to null
   let l_autimsvlr = 0
   let l_segnumdig = null
   let l_pestip    = null

   call cty26g00_prep()

   call cty26g00_ims_veic(lr_param.*)
	 returning l_autimsvlr

   #--> Buscando a ultima situacao valida da apolice
   #------------------------------------------------
   call F_FUNAPOL_ULTIMA_SITUACAO(lr_param.succod   ,
				  lr_param.aplnumdig,
				  lr_param.itmnumdig)
        returning lr_retorno.*

   whenever error continue
   open c_cty26g00_02 using lr_param.*, lr_retorno.dctnumseq
   fetch c_cty26g00_02 into l_segnumdig

   open c_cty26g00_03 using l_segnumdig
   fetch c_cty26g00_03 into l_pestip
   whenever error stop

   let l_condicao = false
   if l_pestip = "F" and l_autimsvlr > 0 then
      let l_condicao = true
   end if
   return l_condicao

end function
#--------------------------------------------------------#
function cty26g00_srv_lei_seca(lr_parametro)
#--------------------------------------------------------#
define lr_parametro  record
  ramcod     like  datrservapol.ramcod,
  succod     like  abbmveic.succod    ,
  aplnumdig  like  abbmveic.aplnumdig ,
  itmnumdig  like  abbmveic.itmnumdig ,
  astcod     like  datkassunto.c24astcod,
  bnfnum     like  datrligsau.bnfnum  ,
  crtsaunum  like  datksegsau.crtsaunum,
  socntzcod  like  datmsrvre.socntzcod,
  saldo      integer
end record
define l_retorno   record
  errocod      smallint
 ,clscod       char(03)
 ,clcdat       date
 ,edsflg       char(01)
end record
define lr_retorno record
     result     char (1)              ,
     dctnumseq  like abbmdoc.dctnumseq,
     vclsitatu  like abbmitem.vclsitatu,
     autsitatu  like abbmitem.autsitatu,
     dmtsitatu  like abbmitem.dmtsitatu,
     dpssitatu  like abbmitem.dpssitatu,
     appsitatu  like abbmitem.appsitatu,
     vidsitatu  like abbmitem.vidsitatu
end record
define l_qtd_limite  integer
      ,l_qtd_srvs    integer
      ,l_qtd_srvs_p  integer
      ,l_clscod      char(03)
      ,l_saldo_s     integer
      ,l_flag_limite char(01)
      ,l_resultado   smallint
      ,l_condicao    smallint
      ,l_mensagem    char(70)
      ,l_prporgpcp    like abamdoc.prporgpcp
      ,l_prpnumpcp    like abamdoc.prpnumpcp
      ,lr_autimsvlr    like abbmcasco.imsvlr
   let  l_qtd_srvs = 0
   let  l_qtd_srvs_p = 0
   let  l_qtd_limite = 999
   let  l_flag_limite = "N"
   let  l_saldo_s = lr_parametro.saldo
   call faemc144_clausula(lr_parametro.succod,
                           lr_parametro.aplnumdig,
                           lr_parametro.itmnumdig)
                 returning l_retorno.errocod,
                           l_retorno.clscod,
                           l_retorno.clcdat,
                           l_retorno.edsflg
  if (l_retorno.clscod = "044" and
      l_retorno.clscod = "44R" and
      l_retorno.clscod = "048" and
      l_retorno.clscod = "48R") or l_retorno.clscod is null then
      return l_flag_limite, l_saldo_s, l_qtd_limite,
	     (l_qtd_srvs+l_qtd_srvs_p) ,0
  end if
	if lr_parametro.astcod = "S54" and
	  (l_retorno.clscod = "047"    or
	   l_retorno.clscod = "033")   then
           let l_qtd_limite = 6
           call cty26g01_qtd_servico_s54(lr_parametro.ramcod
				                                ,lr_parametro.succod
				                                ,lr_parametro.aplnumdig
				                                ,lr_parametro.itmnumdig
                                        ,""
				                                ,""
				                                ,l_retorno.clcdat
				                                ,lr_parametro.astcod )
          returning  l_qtd_srvs
          let l_saldo_s = l_qtd_limite - l_qtd_srvs
          if l_saldo_s <= 0 then
	           let l_flag_limite = "S"
	        end if
          return l_flag_limite, l_saldo_s, l_qtd_limite,
	    	        (l_qtd_srvs+l_qtd_srvs_p),1
  end if
	if lr_parametro.astcod = "S54" and
	     (l_retorno.clscod = "034"  or
	      l_retorno.clscod = "035"  or
	      l_retorno.clscod = "33R"  or
	      l_retorno.clscod = "47R"  ) then
           let l_qtd_limite = 1
           call cty26g01_qtd_servico_s54(lr_parametro.ramcod
				                                ,lr_parametro.succod
				                                ,lr_parametro.aplnumdig
				                                ,lr_parametro.itmnumdig
                                        ,""
				                                ,""
				                                ,l_retorno.clcdat
				                                ,lr_parametro.astcod )
          returning  l_qtd_srvs
          let l_saldo_s = l_qtd_limite - l_qtd_srvs
          if l_saldo_s <= 0 then
	           let l_flag_limite = "S"
	        end if
          return l_flag_limite, l_saldo_s, l_qtd_limite,
		             (l_qtd_srvs+l_qtd_srvs_p),1
  end if
end function
#----------------------------------------------#
 function cty26g00_valida_limite(lr_param)
#----------------------------------------------#
define lr_param record
	c24astcod  like  datmligacao.c24astcod ,
	clscod     like abbmclaus.clscod
end record
  if lr_param.c24astcod = "S40" then
  	 if lr_param.clscod = "034" or
  	 	  lr_param.clscod = "035" or
  	 	  lr_param.clscod = "048" then
  	       return true
  	 else
  	 	     return false
     end if
  else
  	 return false
  end if
end function
