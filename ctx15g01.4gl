############################################################################################################
# Nome do Modulo: ctx15g01                                         															 	Sergio   #
#                                                                  																Burini   #
# Validação do Calculo de Adiconal Noturno                         																Abr/2008 #
#																																																					 #			
#----------------------------------------------------------------------------------------------------------#
# Alteração: Nova atribuição do adicional noturno 																				Josiane Almeida  #
#							utilizar a data e hora combinada com o cliente para cálculo do adicional     			  Fev/2014 #
############################################################################################################

database porto

#-----------------------------#
 function ctx15g01_prepare()
#-----------------------------#

     define l_sql char(1000)

    #let l_sql = "select atdetpdat, ",
    #                  " atdetphor, ",
    #                  " pstcoddig ",
    #             " from datmsrvacp ",
    #            " where atdsrvnum = ? ",
    #              " and atdsrvano = ? ",
    #              " and atdetpcod in (3,4,10) ",
    #              " and atdsrvseq = (select max(atdsrvseq) ",
    #                                   " from datmsrvacp ",
    #                                  " where atdsrvnum = ? ",
    #                                    " and atdsrvano = ?) "
    
    let l_sql = "select srvcbnhor,       ",
    									"	atdprscod        ",
    							"	from datmservico     ",
    						"	where atdsrvnum = ?    ",
    							" and atdsrvano = ?		 "

     prepare pctx15g0101 from l_sql
     declare cctx15g0101 cursor for pctx15g0101

     let l_sql = " select qldgracod ",
                   " from dpaksocor ",
                  " where pstcoddig = ? "

     prepare pctx15g0102 from l_sql
     declare cctx15g0102 cursor for pctx15g0102

     let l_sql = " select atdsrvorg ",
                   " from datmservico ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

     prepare pctx15g0103 from l_sql
     declare cctx15g0103 cursor for pctx15g0103

     let l_sql = " select 1 ",
                   " from igfkferiado ",
                  " where ferdia = ? ",
                    " and fertip = 'N' "

     prepare pctx15g0104 from l_sql
     declare cctx15g0104 cursor for pctx15g0104

     let l_sql = "select grlinf ",
                  " from datkgeral ",
                 " where grlchv = ? "

     prepare pctx15g0105 from l_sql
     declare cctx15g0105 cursor for pctx15g0105

 end function

#--------------------------------------#
 function ctx15g01_verif_adic(l_srvnum,
                              l_srvano)
#--------------------------------------#

     define l_srvnum       like datmservico.atdsrvnum,
            l_srvano       like datmservico.atdsrvano,
            l_atdetpdat    like datmsrvacp.atdetpdat,
            l_atdetphor    like datmsrvacp.atdetphor,
            l_pstcoddig    like datmsrvacp.pstcoddig,
            l_qldgracod    like dpaksocor.qldgracod,
            l_atdsrvorg    like datmservico.atdsrvorg,
            l_status       integer,
            l_day          integer,
            l_tmpini       datetime hour to minute,
            l_tmpfim       datetime hour to minute,
            l_tmpacn       datetime hour to minute,
            l_param        like datkgeral.grlchv,
            l_aux          smallint,
            l_auxdate			 like datmservico.srvcbnhor

     initialize l_atdetpdat,
                l_atdetphor,
                l_status,
                l_day,
                l_pstcoddig,
                l_tmpini,
                l_tmpfim,
                l_tmpacn,
                l_auxdate to null

     call ctx15g01_prepare()

     # BUSCA DATA E HORA COMBINADA COM O CLIENTE 
     open cctx15g0101 using l_srvnum,   
                       			l_srvano  
			                                   
		 fetch cctx15g0101 into l_auxdate,			                      
			                      l_pstcoddig 
		
		                       
		 let l_atdetpdat = extend(l_auxdate, year to day) 
		 let l_atdetphor = extend(l_auxdate, hour to second)
		 
		  display "l_auxdate: ", l_auxdate
			                                   
		 open cctx15g0102 using l_pstcoddig  
		 fetch cctx15g0102 into l_qldgracod 


     # VERIFICA SE O DIA DO SERVICO É UM FERIADO
     open cctx15g0104 using l_atdetpdat
     fetch cctx15g0104 into l_status

     # BUSCA O DIA DA SEMANA. 0 - DOMINGO ... 6 - SABADO
     let l_day = weekday(l_atdetpdat)

     open cctx15g0103 using l_srvnum,
                            l_srvano
     fetch cctx15g0103 into l_atdsrvorg

     let l_tmpini = '00:00'
     let l_tmpfim = '00:00'
      
     if  l_atdsrvorg = 9 or l_atdsrvorg = 13 then

         # SERVICO RE
         let l_param = "PSOADCHRINIRE"

         open cctx15g0105 using l_param
         fetch cctx15g0105 into l_aux
         
         let l_tmpini = l_tmpini + l_aux units hour

         if  sqlca.sqlcode <> 0 then
             display "Parametro ", l_param clipped, " nao encontrado."
             return false
         end if

         let l_param = "PSOADCHRFIMRE"

         open cctx15g0105 using l_param
         fetch cctx15g0105 into l_aux
         
         let l_tmpfim = l_tmpfim + l_aux units hour 

         if  sqlca.sqlcode <> 0 then
             display "Parametro ", l_param clipped, " nao encontrado."
             return false
         end if
     else

         # SERVICO AUTO
         let l_param = "PSOADCHRINIAUTO"

         open cctx15g0105 using l_param
         fetch cctx15g0105 into l_aux
         
         let l_tmpini = l_tmpini + l_aux units hour 

         if  sqlca.sqlcode <> 0 then
             display "Parametro ", l_param clipped, " nao encontrado."
             return false
         end if

         let l_param = "PSOADCHRFIMAUTO"

         open cctx15g0105 using l_param
         fetch cctx15g0105 into l_aux
         
         let l_tmpfim = l_tmpfim + l_aux units hour 

         if  sqlca.sqlcode <> 0 then
             display "Parametro ", l_param clipped, " nao encontrado."
             return false
         end if
     end if

     # SE O PRESTADOR FOR PADRAO (QLDGRACOD = 1) E HORARIO DO ACIONAMENTO
     # É SUPERIOR AS 19 HORAS E INFERIOR AS 06:00 OU O DIA DO ACIONAMENTO
     # É UM FERIADO OU DOMINGO.

     let l_tmpacn = l_atdetphor
		 
		 display "l_tmpacn: ", l_tmpacn 
		        ," - l_tmpini: ", l_tmpini
		        ," - l_tmpfim: ", l_tmpfim
		 
     if   ((l_tmpacn >= l_tmpini or l_tmpacn <= l_tmpfim) or
          l_status = 1 or l_day = 0) and l_qldgracod = 1  then

          return true
     end if

     return false

 end function