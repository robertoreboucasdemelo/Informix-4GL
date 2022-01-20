#############################################################################
# Nome de Modulo: CTC81M00                                 Cristiane Silva  #
#                                                                           #
# Descontos das ordens de pagamento                                Jul/2006 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

define am_ctc81m00  array[50] of record
         navega 	char(01),
         dsctipcod    	smallint,
         dsctipdes    	char(20),
         dscvlr    	decimal(15,5),
         dscvlrobs      char(25)
end record

define m_totdsc  decimal(15,5)
define situacao smallint
define m_contador smallint

define m_vlr_des_sap   decimal(15,5) #Robson R.O.
define m_vlrexcedido   decimal(15,2) #Robson R.O.


#--------------#
function ctc81m00(parametro)
#--------------#
define parametro record
	socopgnum like dbsropgdsc.socopgnum
end record

define ws record
	situacao like dbsmopg.socopgsitcod
end record

define l_sucesso     smallint

  let l_sucesso = true

 options
    prompt line last,
    insert key f1,
    delete key control-j

if m_prep_sql is null or m_prep_sql <> true then
	call ctc81m00_prepare()
end if

  #Robson R.O. Limitar o valor de desconto da OP - Inicio 
   display "parametro.socopgnum: ",parametro.socopgnum
   call ctc81m00c (parametro.socopgnum)
   returning m_vlr_des_sap
   
   display "Vlr Desc. SAP: ",m_vlr_des_sap
   
  #Robson R.O. Limitar o valor de desconto da OP - frim 


  open window w_ctc81m00 at 9,2 with form "ctc81m00"
     attributes(form line 1, border)

  call ctc81m00_carrega_array(parametro.*)

  call ctc81m00_entra_dados(parametro.socopgnum)

  let int_flag = false

options
delete key f2

close window w_ctc81m00

end function

#----------------------#
function ctc81m00_prepare()
#----------------------#

  define l_sql char(300)

  let m_prep_sql = false

  create temp table array_tmp (dsctipcod       smallint,
                               dsctipdes       char(20),
                               dscvlr          decimal(15,5)) with no log

  let l_sql = " select opgdsc.dscvlr, opgdsc.dscvlrobs ",
  		" from dbsropgdsc opgdsc, dbsktipdsc dsc ",
		" where opgdsc.dsctipcod = dsc.dsctipcod ",
		" and opgdsc.socopgnum = ? ",
		" and opgdsc.dsctipcod = ? "
  prepare pctc81m00001 from l_sql
  declare cctc81m00001 cursor for pctc81m00001

  let l_sql = " select dsctipcod, dsctipdes, 0 ",
  		" from dbsktipdsc ",
		" where dsctipsit = 'A' ",
		"order by dsctipcod "
  prepare pctc81m00002 from l_sql
  declare cctc81m00002 cursor for pctc81m00002

  let l_sql = " insert into dbsropgdsc(socopgnum, dsctipcod, dscvlr, caddat, cademp, ",
              " cadusrtip, cadmat, atldat, atlemp, atlusrtip, atlmat, dscvlrobs) ",
              " values (?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare pctc81m00003 from l_sql


  let l_sql = " update dbsropgdsc set (dscvlr, atldat, atlemp, atlusrtip, atlmat, dscvlrobs) ",
  	      " = (?,?,?,?,?,?) where socopgnum = ? and dsctipcod = ? "
  prepare pctc81m00004 from l_sql


  let l_sql = " delete from dbsropgdsc where socopgnum = ? and dsctipcod = ? "
  prepare pctc81m00005 from l_sql

  let l_sql = "select sum(dscvlr) from dbsropgdsc where socopgnum = ? "
  prepare pctc81m00006 from l_sql
  declare cctc81m00006 cursor for pctc81m00006

  let l_sql = " select socfattotvlr from dbsmopg where socopgnum = ? "
  prepare pctc81m00007 from l_sql
  declare cctc81m00007 cursor for pctc81m00007

  let l_sql = " select socopgsitcod from dbsmopg where socopgnum = ? "
  prepare pctc81m00008 from l_sql
  declare cctc81m00008 cursor for pctc81m00008

  let l_sql = " select dsctipcod from dbsropgdsc where socopgnum = ? "
  prepare pctc81m00009 from l_sql
  declare cctc81m00009 cursor for pctc81m00009

#  let l_sql = " select dsctipcod from dbsropgdsc where socopgnum = ? and dsctipcod <> 4 "
#  prepare pctc81m00010 from l_sql
#  declare cctc81m00010 cursor for pctc81m00010

  let l_sql = " delete from dbsropgdsc where socopgnum = ? and dsctipcod <> 4 "
  prepare pctc81m00011 from l_sql

let m_prep_sql = true

end function

#---------------------------------
function ctc81m00_carrega_array(param)
#---------------------------------
define param record
	socopgnum like dbsmopg.socopgnum
end record

define ws record
	valor like dbsropgdsc.dscvlr,
	situacao smallint,
	dscvlrobs  like dbsropgdsc.dscvlrobs
end record

 define l_operacao      char(01),
         l_arr           smallint,
         l_scr           smallint,
         l_codigo        smallint,
         l_resposta      char(01),
         l_situacao_ant  char(01),
         l_dscvlr_ant    decimal(15,5),
         l_dscvlr	 decimal(15,5),
	 l_datac	 date,
	 l_datal	 date,
	 l_total         decimal(15,5),
	 l_valorop       decimal(15,5)

let l_arr           = null
let l_situacao_ant  = null
let l_dscvlr_ant = null
let l_scr           = null
let l_resposta      = null
let l_datac = today
let l_datal = today
let l_total = 0.00
let l_valorop = 0.00

  let int_flag = false

  let l_operacao = " "

initialize am_ctc81m00 to null

let m_contador = 1

open cctc81m00002
foreach cctc81m00002 into am_ctc81m00[m_contador].dsctipcod,
			  am_ctc81m00[m_contador].dsctipdes
whenever error continue
	open cctc81m00001 using param.socopgnum, am_ctc81m00[m_contador].dsctipcod
	fetch cctc81m00001 into ws.valor, ws.dscvlrobs
whenever error stop
	if sqlca.sqlcode = notfound then
		let ws.valor = 0.00
		let ws.dscvlrobs = ""
	else
		if sqlca.sqlcode <> 0 then
			error "Erro ao selecionar cctc81m00001" sleep 2
			let ws.valor = 0.00
			let ws.dscvlrobs = ""
		end if
	end if

	let am_ctc81m00[m_contador].dscvlr = ws.valor
	let am_ctc81m00[m_contador].dscvlrobs = ws.dscvlrobs
	close cctc81m00001

let m_contador = m_contador + 1

if m_contador = 51 then
	error "O limite de 50 registros foi ultrapassado" sleep 2
	exit foreach
end if

end foreach

let m_contador = m_contador - 1

close cctc81m00002

whenever error continue
	open cctc81m00006 using param.socopgnum
	fetch cctc81m00006 into m_totdsc
whenever error stop
	if sqlca.sqlcode <> 0 then
		if sqlca.sqlcode = notfound then
			let m_totdsc = 0.00
		else
			error 'Erro ao selecionar valor total', sqlca.sqlcode
		end if
	end if

display m_totdsc to totdsc

close cctc81m00006

end function

#--------------------------#
function ctc81m00_entra_dados(param)
#--------------------------#

define param record
	socopgnum like dbsmopg.socopgnum
end record

define ws record
	situacao like dbsmopg.socopgsitcod,
	dsctipcod like dbsropgdsc.dsctipcod,
	desconto like dbsropgdsc.dscvlr,
	tipo     smallint
end record

  define l_operacao      char(01),
         l_arr           smallint,
         l_scr           smallint,
         l_count         smallint,
         l_codigo        smallint,
         l_resposta      char(01),
         l_resposta2	 char(01),
         l_situacao_ant  char(01),
         l_dscvlr_ant    decimal(15,5),
         l_dscvlr	 decimal(15,5),
	 l_datac	 date,
	 l_datal	 date,
	 l_total         decimal(15,5),
	 l_valorop       decimal(15,5),
	 l_dscvlr_bkp    like dbsropgdsc.dscvlr

let l_arr           = null
let l_count         = null
let l_situacao_ant  = null
let l_dscvlr_ant = null
let l_scr           = null
let l_resposta      = null
let l_datac = today
let l_datal = today
let l_total = 0.00
let l_valorop = 0.00
let l_resposta2 = 'N'
let ws.tipo = 0
let ws.desconto = 0.00

  let int_flag = false

  let l_operacao = " "

  while true

     call ctc81m00_carrega_array(param.*)
call set_count(m_contador)

     input array am_ctc81m00 without defaults from s_ctc81m00.*

        before row
           let l_arr   = arr_curr()
           let l_scr   = scr_line()
           let l_count = arr_count()

        before field navega
           if l_operacao = "I" then
              next field dscvlr
           end if

        after field navega
           if fgl_lastkey() = 2014 then
              let l_operacao = "I"
              next field dscvlr
           else
              if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctc81m00[l_arr + 1].dscvlr is null then
                    next field navega
                 else
                    continue input
                 end if
              end if

              if fgl_lastkey() = 2005 or    ## f3
                 fgl_lastkey() = 2006 then  ## f4
                 let l_operacao = "A"
                 next field dscvlr
              end if

              if fgl_lastkey() = fgl_keyval('up') then
                 continue input
              else
                 next field navega
              end if


           end if

        before field dscvlr

           let l_dscvlr_bkp = am_ctc81m00[l_arr].dscvlr
           
           display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr attribute(reverse)

	   open cctc81m00008 using param.socopgnum
	   fetch cctc81m00008 into ws.situacao
	   close cctc81m00008

	   if ws.situacao = 7 then
	   	error 'Dados apenas para visualizacao. Verifique situacao da OP.'
	   	let l_operacao = ""
	   	exit input
	   else
	   	if l_operacao = "A" then
	      		if am_ctc81m00[l_arr].dscvlr = 0.00 then
	      			error 'Alteracao nao permitida para registro inexistente'
	      			let l_operacao = ""
	      			next field navega
	      		else
              			display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr
              		end if
           	end if

	   	if l_operacao = "I" then
	        	if am_ctc81m00[l_arr].dscvlr <> 0 then
	        		error 'Inclusao nao permitida para registro ja existente'
	        		let l_operacao = ""
	        		next field navega
	        	else
	   			display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr
	   		end if
	   	end if
	 end if

        after field dscvlr
           
    	   #Valida os valores de descontos a OP.
	   if  not ctc81m00_calc_limit_op(param.socopgnum, l_count) then
	       #error 'Valor ultrapassou o valor da OP.'
	        #Robson R.O. Inicio 
	           error "Valor limite para desconto: ",m_vlr_des_sap using "<<<<<<<<<&.&&"
	        #Robson R.O.  fim 
	        
	        let am_ctc81m00[l_arr].dscvlr = l_dscvlr_bkp  
	        next field dscvlr 
	   end if           
           
           display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field dscvlrobs
           end if

           if fgl_lastkey() = fgl_keyval('left') then
	   	next field navega
	   end if

	   if l_operacao = "A" then
	   	if am_ctc81m00[l_arr].dscvlr = 0.00 then
	   		error 'Registro nao pode ser alterado para zero. Informe o valor.'
	   		next field dscvlr
	   	end if
	   end if

	   if l_operacao = "I" then
	   	if am_ctc81m00[l_arr].dscvlr = 0.00 then
	   		error 'Registro nao pode ser incluido com valor zero. Informe o valor.'
	   		next field dscvlr
	   	end if
	   end if
	   next field dscvlrobs

       before field dscvlrobs
       		display am_ctc81m00[l_arr].dscvlrobs to s_ctc81m00[l_scr].dscvlrobs

       after field dscvlrobs
       		display am_ctc81m00[l_arr].dscvlrobs to s_ctc81m00[l_scr].dscvlrobs

           while true

              if l_operacao = "I" then
              		prompt 'Confirma inclusao do registro? (S/N)' for l_resposta
              else
              	 if l_operacao = "A" then
                 	prompt 'Confirma alteracao do registro? (S/N)' for l_resposta
              	 else
              	 	if l_operacao = "E" then
              	 		prompt 'Confirma exclusao do registro? (S/N)' for l_resposta
              	 	end if
              	 end if
              end if

              let l_resposta = upshift(l_resposta)

              if l_resposta = 'S' or l_resposta = 'N' or int_flag then
                 exit while
              end if
           end while

           if int_flag then
              let int_flag = true
              let l_resposta = "N"
              let l_resposta2 = "N"
           end if
           
           if  l_resposta = 'N' then
               let am_ctc81m00[l_arr].dscvlr = l_dscvlr_bkp
               display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr
           end if   

           display 'L_OPERACAO: ', l_operacao

           display 'L_RESPOSTA: ', l_resposta           
           if l_resposta = "S" then
              if l_operacao = "I" then
               		begin work
              			if ctc81m00_executa_operacao("I",
		        	param.socopgnum,
                		am_ctc81m00[l_arr].dsctipcod,
                        	am_ctc81m00[l_arr].dscvlr,
                        	l_datac,
                        	g_issk.empcod,
                        	g_issk.usrtip,
                        	g_issk.funmat,
                        	l_datal,
                        	g_issk.empcod,
                        	g_issk.usrtip,
                        	g_issk.funmat,
                        	am_ctc81m00[l_arr].dscvlrobs) then
                    			display 'ENTROU IF INCLUIR'
                    			
                    			error "Registro incluido com sucesso" sleep 2
                    			open cctc81m00006 using param.socopgnum
	    				fetch cctc81m00006 into l_total
	    				let m_totdsc = l_total
                                        
					display m_totdsc to totdsc
	        			close cctc81m00006

					open cctc81m00007 using param.socopgnum
	        			fetch cctc81m00007 into l_valorop
                                        
                                        #Robson R.O. 
                                        let l_valorop = m_vlr_des_sap
                                        
                                        
                                        display 'm_totdsc: ', m_totdsc
                                        display 'l_valorop: ', l_valorop
                                        
        	    			if m_totdsc > l_valorop then
		                		display 'ENTROU ROLLBACK'            					
            					error "Total de descontos nao pode ser superior ao valor da OP" sleep 1
            					rollback work
            					close cctc81m00007
						let am_ctc81m00[l_arr].dscvlr = 0.00
						let am_ctc81m00[l_arr].dscvlrobs = ""
						let l_operacao = ""
						next field navega
            					open cctc81m00006 using param.socopgnum
	       					fetch cctc81m00006 into l_total
		        			let m_totdsc = l_total
						display m_totdsc to totdsc
		                		close cctc81m00006
            				else
		                		display 'ENTROU COMMIT'	            				
	            				commit work
	            				close cctc81m00007
	            				call ctc81m00_carrega_array(param.*)
        	    			end if
       				else
       		    			display 'SETOU FLAG FALSO 1'
       		    			rollback work
       		    			let int_flag = true
       					exit input
       				end if
				
				#BURINI#display 'L_RESPOSTA2: ', l_resposta2
				#BURINI#if l_resposta2 = "S" then
				#BURINI#	execute pctc81m00011 using param.socopgnum
				#BURINI#	begin work
              			#BURINI#	display 'ENTROU CHAMDA INCLUIR 2'
              			#BURINI#	
              			#BURINI#	if ctc81m00_executa_operacao("I",
		        	#BURINI#	param.socopgnum,
                		#BURINI#	am_ctc81m00[l_arr].dsctipcod,
                        	#BURINI#	am_ctc81m00[l_arr].dscvlr,
                        	#BURINI#	l_datac,
                        	#BURINI#	g_issk.empcod,
                        	#BURINI#	g_issk.usrtip,
                        	#BURINI#	g_issk.funmat,
                        	#BURINI#	l_datal,
                        	#BURINI#	g_issk.empcod,
                        	#BURINI#	g_issk.usrtip,
                        	#BURINI#	g_issk.funmat,
                        	#BURINI#	am_ctc81m00[l_arr].dscvlrobs) then
                    		#BURINI#		#error "Registro incluido com sucesso" sleep 2
                    		#BURINI#		let ws.desconto = 0.00
                    		#BURINI#		open cctc81m00006 using param.socopgnum
		    		#BURINI#		fetch cctc81m00006 into l_total
		    		#BURINI#		let m_totdsc = l_total
                                #BURINI#
				#BURINI#		display m_totdsc to totdsc
		        	#BURINI#		close cctc81m00006
                                #BURINI#
				#BURINI#		open cctc81m00007 using param.socopgnum
		        	#BURINI#		fetch cctc81m00007 into l_valorop
                                #BURINI#
                                #BURINI#                display 'm_totdsc 2 : ', m_totdsc
                                #BURINI#                display 'l_valorop 2 : ', l_valorop	        	    			
	        	    	#BURINI#		
	        	    	#BURINI#		if m_totdsc > l_valorop then
	            		#BURINI#			error "Total de descontos nao pode ser superior ao valor da OP" sleep 1
	            		#BURINI#			rollback work
	            		#BURINI#			display 'ROLLBACK 2'
	            		#BURINI#			
	            		#BURINI#			close cctc81m00007
				#BURINI#			let am_ctc81m00[l_arr].dscvlr = 0.00
				#BURINI#			let am_ctc81m00[l_arr].dscvlrobs = ""
				#BURINI#			let l_operacao = ""
				#BURINI#			next field navega
	            		#BURINI#			open cctc81m00006 using param.socopgnum
		       		#BURINI#			fetch cctc81m00006 into l_total
			        #BURINI#			let m_totdsc = l_total
				#BURINI#			display m_totdsc to totdsc
			        #BURINI#        		close cctc81m00006
	            		#BURINI#		else
		            	#BURINI#			display 'COMMIT 2'
		            	#BURINI#			commit work
		            	#BURINI#			close cctc81m00007
		            	#BURINI#			call ctc81m00_carrega_array(param.*)
	        	    	#BURINI#		end if
	        	    	#BURINI#		call ctc81m00_carrega_array(param.*)
	            		#BURINI#	else
	            		#BURINI#		display 'SETOU FLAG FALSA 2'
	            		#BURINI#		let int_flag = true
                    		#BURINI#		exit input
	            		#BURINI#	end if
	            		#BURINI#else
	            		#BURINI#	display 'NAO EFETUADA!'
	            		#BURINI#	error "Inclusao nao efetuada"
	            		#BURINI#	let l_operacao = ""
	            		#BURINI#	next field navega
	            		#BURINI#end if
            	call ctc81m00_carrega_array(param.*)
	else
	     if l_operacao = "A" then
              	begin work
                	if ctc81m00_executa_operacao("A",
                 	param.socopgnum,
                        am_ctc81m00[l_arr].dsctipcod,
                        am_ctc81m00[l_arr].dscvlr,
                        l_datac,
                        g_issk.empcod,
                        g_issk.usrtip,
                        g_issk.funmat,
                        l_datal,
                        g_issk.empcod,
                        g_issk.usrtip,
                        g_issk.funmat,
                        am_ctc81m00[l_arr].dscvlrobs) then
                    		error "Registro alterado com sucesso" sleep 2
                    		open cctc81m00006 using param.socopgnum
		    		fetch cctc81m00006 into l_total
		    		let m_totdsc = l_total

		            	display m_totdsc to totdsc
		            	close cctc81m00006

				open cctc81m00007 using param.socopgnum
	            		fetch cctc81m00007 into l_valorop
	            		
	            		#Robson R.O. 
	            		let l_valorop = m_vlr_des_sap

	            		if m_totdsc > l_valorop then
	            			error "Total de descontos nao pode ser superior ao valor da OP" sleep 1
	            			rollback work
	            			close cctc81m00007
	            			open cctc81m00006 using param.socopgnum
		        		fetch cctc81m00006 into l_total
		        		let m_totdsc = l_total

				        display m_totdsc to totdsc
		                	close cctc81m00006
	        	    	else
	            			commit work
	            			close cctc81m00007
	            		end if
	            		call ctc81m00_carrega_array(param.*)
                 	else
                    		let int_flag = true
                    		exit input
			end if
	     else
        	let int_flag = true
        	exit input
             end if
        end if
       end if


	display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr
        display am_ctc81m00[l_arr].dscvlrobs to s_ctc81m00[l_scr].dscvlrobs

        let l_operacao = " "

        next field navega

	on key(f2)
		while true
			open cctc81m00008 using param.socopgnum
			fetch cctc81m00008 into ws.situacao
			close cctc81m00008

			if ws.situacao = 7 then
				error "Dados somente para visualizacao. Verifique situacao da OP."
				exit input
			else
				prompt 'Confirma exclusao? (S/N)' for l_resposta
				let l_resposta = upshift(l_resposta)

				if l_resposta = "S" or l_resposta = "N" or int_flag then
                			exit while
             			else
                			error "Digite (S)SIM ou (N)NAO"
             			end if
             		end if
	        end while

	        if int_flag then
             		let l_resposta = "N"
             		let int_flag = false
          	end if

         	if upshift(l_resposta) = "S" then
		  	if ctc81m00_executa_operacao("E",
		  				param.socopgnum,
                                           	am_ctc81m00[l_arr].dsctipcod,
                                           	am_ctc81m00[l_arr].dscvlr,
                                           	l_datac,
                                           	g_issk.empcod,
                                           	g_issk.usrtip,
                                           	g_issk.funmat,
                                           	l_datal,
                                           	g_issk.empcod,
                                           	g_issk.usrtip,
                                           	g_issk.funmat,
                                           	am_ctc81m00[l_arr].dscvlrobs) then
                  		error "Registro excluido com sucesso" sleep 2
                  		let am_ctc81m00[l_arr].dscvlr = 0.00
                  		let am_ctc81m00[l_arr].dscvlrobs = ""
                  		display am_ctc81m00[l_arr].dscvlr to s_ctc81m00[l_scr].dscvlr
                  		display am_ctc81m00[l_arr].dscvlrobs to s_ctc81m00[l_scr].dscvlrobs

                  		open cctc81m00006 using param.socopgnum
		                fetch cctc81m00006 into l_total
		    		let m_totdsc = l_total

	            		display m_totdsc to totdsc
	            		call ctc81m00_carrega_array(param.*)

                  	else
                  		let int_flag = true
                    		exit input
                  	end if
                else
             		error "Delecao cancelada !" sleep 1
          	end if

		open cctc81m00006 using param.socopgnum
		fetch cctc81m00006 into l_total
		let m_totdsc = l_total

	        display m_totdsc to totdsc



       on key(f6)
          if l_operacao = "I" or
             l_operacao = "A" then
             error "F6 nao pode ser teclada neste momento "
          else
             let l_operacao = "A"
             let l_dscvlr_ant = am_ctc81m00[l_arr].dscvlr
             next field dscvlr
          end if

#        before field totdsc
#		display am_ctc81m00[l_arr].totdsc to s_ctc81m00[l_scr].totdsc

#	after field totdsc
#		display am_ctc81m00[l_arr].totdsc to s_ctc81m00[l_scr].totdsc

       on key (control-c, f17, interrupt)
          initialize am_ctc81m00[l_arr].* to null
          let int_flag = true
          let m_contador = 0
          exit input


     end input

     if int_flag then
        exit while
    end if

  end while

end function

#---------------------------------------#
function ctc81m00_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint
  for l_cont = l_arr to 49
     if am_ctc81m00[l_arr].dsctipcod is not null then
        let am_ctc81m00[l_cont].* = am_ctc81m00[l_cont + 1].*
     else
        initialize am_ctc81m00[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 8
     display am_ctc81m00[l_arr].dsctipcod    to s_ctc81m00[l_cont].dsctipcod
     display am_ctc81m00[l_arr].dsctipdes    to s_ctc81m00[l_cont].dsctipdes
     display am_ctc81m00[l_arr].dscvlr    to s_ctc81m00[l_cont].dscvlr
     let l_arr = l_arr + 1
  end for

end function

#-------------------------------------------#
function ctc81m00_executa_operacao(lr_parametro)
#-------------------------------------------#

  define lr_parametro  record
         tipo_operacao char(01),
         socopgnum     decimal(5,2),
         dsctipcod        smallint,
         dscvlr		  decimal(15,5),
         dt_cadastro	  date,
         cademp		  smallint,
         cadusrtip	  char(01),
         cadmat		  decimal(5,2),
         dt_alteracao     date,
         atlemp		  smallint,
         atlusrtip        char(01),
         atlmat           decimal(5,2),
         dscvlrobs	  char(25)

  end record

  define l_sucesso     smallint
  define l_dsctipcod      smallint

  let l_sucesso = true

  case lr_parametro.tipo_operacao

     when "A" # --ALTERACAO

        whenever error continue
        execute pctc81m00004 using lr_parametro.dscvlr,
        			lr_parametro.dt_alteracao,
                                g_issk.empcod,
                                g_issk.usrtip,
                                g_issk.funmat,
                                lr_parametro.dscvlrobs,
                                lr_parametro.socopgnum,
                                lr_parametro.dsctipcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc81m00004 ", sqlca.sqlcode sleep 3
           let l_sucesso = false
           display 'ERRO UPDATE: ', sqlca.sqlcode
           display 'L_SUCESSO : ', l_sucesso
        end if

     when "I" # --INCLUSAO

        whenever error continue
           execute pctc81m00003 using lr_parametro.socopgnum,
                                   lr_parametro.dsctipcod,
                                   lr_parametro.dscvlr,
                                   lr_parametro.dt_cadastro,
                                   g_issk.empcod,
                                   g_issk.usrtip,
                                   g_issk.funmat,
                                   lr_parametro.dt_alteracao,
                                   g_issk.empcod,
                                   g_issk.usrtip,
                                   g_issk.funmat,
                                   lr_parametro.dscvlrobs
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro INSERT pctc81m00003 ", sqlca.sqlcode sleep 3
           let l_sucesso = false
           display 'ERRO INSERT: ', sqlca.sqlcode
           display 'L_SUCESSO : ', l_sucesso
        end if

     when "E" # --EXCLUSAO

        whenever error continue
           execute pctc81m00005 using lr_parametro.socopgnum,
                                   lr_parametro.dsctipcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc81m00005 ", sqlca.sqlcode sleep 3
           let l_sucesso = false
           display 'ERRO DELETE: ', sqlca.sqlcode
           display 'L_SUCESSO : ', l_sucesso           
        end if


  end case

  return l_sucesso

end function

#-------------------------------------------#
 function ctc81m00_calc_limit_op(l_socopgnum, l_count)
#-------------------------------------------#

    define l_ind2          smallint,
           l_ind           smallint,
           l_count         smallint,
           l_val_desc      like dbsmopg.socfattotvlr,
           l_socfattotvlr  like dbsmopg.socfattotvlr,
           l_socopgnum     like dbsmopg.socopgnum
           
           
    let l_ind      = 0
    let l_ind2     = 0
    let l_val_desc = 0
    
    #Calcula o valor de todos os descontos
    for l_ind = 1 to l_count
        let l_val_desc = l_val_desc + am_ctc81m00[l_ind].dscvlr
    end for
    
    open cctc81m00007 using l_socopgnum
    fetch cctc81m00007 into l_socfattotvlr
    
    #Robson R.O.                 
    let l_socfattotvlr = m_vlr_des_sap
    
    display 'TOTAL: ', l_socfattotvlr
    display 'DESCONTOS: ', l_val_desc
    
    if  l_socfattotvlr < l_val_desc then
       
       let m_vlrexcedido = l_val_desc - l_socfattotvlr
    
        return false
    else
        return true
    end if

 end function                                                              