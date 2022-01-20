#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        :                                              #
#  Modulo         : cty05g09.4gl                                 #
#                   Regulador de servicos para fila MQ		       #
#  Analista Resp. : Raji                                         #
#  PSI            :                                              #
#................................................................#
#  Desenvolvimento: Andre Oliveira     		                       #
#  Liberacao      : 	                                           #
#................................................................#
globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_cty05g09_prep smallint
#----------------------------------------------------------------#
# Funcao que gera um xml de agenda de disponibilidade para       #
# o portal de segurado.						 #
#----------------------------------------------------------------#

function cty05g09_prepare()

define l_sql char(1000)

let l_sql = " select atdprscod, socvclcod, srrcoddig ",
            " from datmservico ",
            " where atdsrvnum = ? ",
            " and atdsrvano = ? "
prepare pcty05g09003 from l_sql                                  
declare ccty05g09003 cursor for pcty05g09003     

let l_sql = "select atdprscod, socvclcod, srrcoddig  ",
            "from datmservico ",
            "where atdsrvnum = ? ",
            "and atdsrvano = ? "
prepare pcty05g09004 from l_sql
declare ccty05g09004 cursor for pcty05g09004

let l_sql = "select atdsrvnum, atdsrvano,socvclcod, srrcoddig,",
            " atddatprg, atdhorprg ",
            " from datmservico ",
            " where atdetpcod not in (5,6) ",
            " and (atddatprg >= ?  ",
            " and  atdhorprg >  ?) ",
            " and (atddatprg <= ?  ",
            " and  atdhorprg <  ?) "
prepare pcty05g09005 from l_sql                         
declare ccty05g09005 cursor for pcty05g09005

let l_sql = "select atdprscod, socvclcod, srrcoddig,atddat,atdhor ",        
            "  from datmservico  ",                           
            " where atdsrvnum = ? ",
            "   and atdsrvano = ? "            
prepare pcty05g09006 from l_sql                         
declare ccty05g09006 cursor for pcty05g09006

let l_sql = "select atdsrvnum, atdsrvano, ",
            " socvclcod, srrcoddig, ",
            " atddatprg, atdhorprg ",
            " from datmservico ",
            " where atdetpcod not in (5,6) ",
            " and socvclcod = ? ",
            " and atdprscod = ? ",
            " and atddatprg > ? "            
prepare pcty05g09007 from l_sql
declare ccty05g09007 cursor for pcty05g09007










let m_cty05g09_prep = true

end function 

function cty05g09_ListarAgenda(l_cidnom,l_uf,l_socntzdes, l_atdsrvnum, l_atdsrvano)
#----------------------------------------------------------------#
	 define l_cty05g09   record
	    cidnom           like glakcid.cidnom,
	    ufdcod           like glakcid.ufdcod,
	    atdsrvorg        like datmsrvrgl.atdsrvorg,
	    srvrglcod        like datmsrvrgl.srvrglcod,
	    rgldat           like datmsrvrgl.rgldat,
	    rglhor           char(5)
	 end record

	 define ws record
	    cotqtd           like datmsrvrgl.cotqtd,
	    utlqtd           like datmsrvrgl.utlqtd,
	    cont             smallint,
	    srvrglcod        like datmsrvrgl.srvrglcod,
	    cidcod           like glakcid.cidcod,
	    cidsedcod        like glakcid.cidcod,
	    horstr           char(5),
	    hora             like datmsrvrgl.rglhor,
	    socntrzgrpcod    like datksocntzgrp.socntzgrpcod,
	    agdhor           like datmsrvrgl.rglhor,
	    agddat           like datmsrvrgl.rgldat,
	    popup            char(6000),
	    seldes           char(20),
	    selnum           smallint,
	    rgldatmax        like datmsrvrgl.rgldat,
	    datymd           datetime year to day,
	    dathor           datetime year to minute,
	    strdathor        char(20)
	 end record

	 define l_ret smallint
	 define l_mensagem smallint
     
	define l_cidnom char (50),
		  l_uf char(2),
		  l_socntzdes like datksocntz.socntzdes,
		  l_xmlRetorno char(32000),
		  l_doc_handle integer,
		  l_temp date,
		  l_atdsrvnum like datmservico.atdsrvnum,
		  l_atdsrvano like datmservico.atdsrvano,
		  l_etpcod    like datmservico.atdetpcod,
		  l_valido    smallint,
		  l_existe    smallint
	
	
	
	initialize ws.* to null
	initialize l_cty05g09.* to null
	let l_xmlRetorno = null
	let l_valido = true
	initialize l_etpcod to null
	
  if l_atdsrvano is null and
          l_atdsrvnum is null then
          
     	if l_cidnom is null or l_uf is null then
     		call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",1,"Cidade e(ou) UF nulos")
     		returning l_xmlRetorno
     		
     		return l_xmlRetorno
     	end if
     
     	if l_socntzdes is null then
     		call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",2,"Servico nulo")
     		returning l_xmlRetorno
     		
     		return l_xmlRetorno
     	end if

#----- carregando l-cty05g09 ------------------#
     	let l_cty05g09.cidnom = l_cidnom
     	let l_cty05g09.ufdcod = l_uf
     	
          select socntzgrpcod into l_cty05g09.srvrglcod
     	    from datksocntzgrp where socntzgrpdes = l_socntzdes
     	
		  if sqlca.sqlcode = notfound then
     	  call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",3,"Servico nao encontrado")
       	  returning l_xmlRetorno
     		
     	  return l_xmlRetorno
     	end if
	     
	else
     
           select socntzcod
	         into l_cty05g09.srvrglcod
	         from datmsrvre
	         where atdsrvnum = l_atdsrvnum 
              and   atdsrvano = l_atdsrvano 
	     
	         select socntzgrpcod 
              into l_cty05g09.srvrglcod
	    	    from datksocntz 
              where socntzcod = l_cty05g09.srvrglcod
          
            select cidnom, ufdcod
            into l_cty05g09.cidnom,
                 l_cty05g09.ufdcod
            from datmlcl
            where atdsrvano = l_atdsrvano
              and atdsrvnum = l_atdsrvnum
              
             select atdetpcod
               into l_etpcod
               from datmservico
               where atdsrvnum = l_atdsrvnum
                and  atdsrvano = l_atdsrvano
               	
	end if
	
	let l_cty05g09.atdsrvorg = 9
	
	if not cty05g09_cria_temp() then      
      display  "Erro na Criacao da Tabela Temporaria!"
  end if  
  
  call cty05g09_prep_temp()
  					
	let ws.srvrglcod = l_cty05g09.srvrglcod

	call cts40g03_data_hora_banco(2)
	returning l_cty05g09.rgldat,  l_cty05g09.rglhor
	
	let l_temp = null
#-------------------------------------------------------------#


#-----------  Obtendo Codigo de Cidade e Cidade-Sede  --------#
	call cty10g00_obter_cidcod(l_cty05g09.cidnom, l_cty05g09.ufdcod)
      			returning l_ret, l_mensagem, ws.cidcod

      	call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      			returning l_ret, l_mensagem, ws.cidsedcod
#-------------------------------------------------------------#
  if l_etpcod = 1 or l_etpcod is null then
	    # calcula hora/data inicial para consulta (+2h)
	    let ws.datymd    = l_cty05g09.rgldat
	    let ws.strdathor = ws.datymd, " ", l_cty05g09.rglhor
	    let ws.dathor    = ws.strdathor

    
          if l_cty05g09.atdsrvorg = 9 then
               let ws.dathor    = ws.dathor + 3 units hour
          else
     	         let ws.dathor    = ws.dathor + 2 units hour
          end if
	else
        let ws.datymd    = l_cty05g09.rgldat + 1 units day
	      let ws.strdathor = ws.datymd, " 12:00" 
	      let ws.dathor    = ws.strdathor
  end if  
      
      
	 let ws.strdathor = ws.dathor
	 let ws.datymd    = ws.strdathor[1,10]
	 let l_cty05g09.rgldat = ws.datymd
	 let l_cty05g09.rglhor = ws.strdathor[12,17]

	 # calcula limite de 7 dias para agendamento	 	 	 	 	 
	 let ws.rgldatmax =  l_cty05g09.rgldat + 7 units day

	 # Calcula hora cheia
	 let ws.horstr = l_cty05g09.rglhor[1,2], ":00"
	 let ws.hora   = ws.horstr


   display "ws.cidsedcod         = ",ws.cidsedcod        
   display "l_cty05g09.atdsrvorg = ",l_cty05g09.atdsrvorg
   display "l_cty05g09.rgldat    = ",l_cty05g09.rgldat   
   display "l_cty05g09.rgldat    = ",l_cty05g09.rgldat   
   display "ws.srvrglcod         = ",ws.srvrglcod        
   display "ws.hora              = ",ws.hora             
   display "ws.rgldatmax         = ",ws.rgldatmax        
	 
	 declare c_cty05g09 cursor for
	    select rgldat, rglhor
	      from datmsrvrgl
	     where cidcod = ws.cidsedcod
	       and atdsrvorg = l_cty05g09.atdsrvorg
	       and srvrglcod = ws.srvrglcod
	       and (rgldat > l_cty05g09.rgldat
	        	or (rgldat = l_cty05g09.rgldat
	        	and rglhor >= ws.hora))
	       and rgldat < ws.rgldatmax
	       and cotqtd > utlqtd
	    order by rgldat, rglhor

      
	 foreach c_cty05g09 into ws.agddat,
	                         ws.agdhor

    
     call cty05g09_ins_agenda(ws.agddat,
                              ws.agdhor)                                 													
		
		
			
	 end foreach
	 
	 display "cty05g09_verifica_prestador " 
	 call cty05g09_verifica_prestador(l_atdsrvnum, 
			                              l_atdsrvano)
			     returning l_valido			     	 								
			
			#if l_valido = true then 
			#   continue foreach 
			#end if         
			
			
    call cty05g09_verifica_agenda_disponivel(l_valido)
         returning l_xmlRetorno,l_existe
         
             


			
			
			
						
			#if (ws.agddat <> l_temp or l_temp is null) then				
			#	if (l_temp is not null) then
			#		let l_xmlRetorno = l_xmlRetorno clipped, '</HORARIOS></DATA>'
			#	else
			#	    let l_xmlRetorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
			#				   	'<RESPONSE>',
			#					'<SERVICO>LISTAR_AGENDA_DISPONIVEL</SERVICO>',
			#					'<AGENDA>'
			#	end if
			#	
			#	let l_xmlRetorno = l_xmlRetorno clipped, '<DATA><DIA>', ws.agddat ,'</DIA>',
			#						 '<HORARIOS>',
			#						 '<HORA>', ws.agdhor ,'</HORA>'
			#	let l_temp = ws.agddat
			#else
			#  
			#  	let l_xmlRetorno = l_xmlRetorno clipped,'<HORA>', ws.agdhor ,'</HORA>'
			#
			#end if
	 
	 if l_existe = false  then	 	 
	  	call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",9999,"Nao existe agenda disponivel")
		returning l_xmlRetorno
 	 	
   else
      
 	 	let l_xmlRetorno = l_xmlRetorno clipped,'</HORARIOS></DATA></AGENDA></RESPONSE>'

   end if


 	 return l_xmlRetorno

 end function
 
 
#----------------------------------------------------------------#
# Funcao que gera um xml de confirmacao de disponibilidade	 #
# imediata ao portal de segurado.				 #
#----------------------------------------------------------------#
function cty05g09_DiponibilidadeImediata(  mr_servicos,
			      		   l_logtip,
			      		   l_lognom,
			      		   l_lognum,
			      		   l_logbai,
			      		   l_cidnom,
			      		   l_uf)
#----------------------------------------------------------------#

	define mr_servicos  record          #---> Array de servicos
        	socntzcod   like datmsrvre.socntzcod,
        	espcod      like datmsrvre.espcod,
        	socntzcod_1 like datmsrvre.socntzcod,
        	espcod_1    like datmsrvre.espcod,
        	socntzcod_2 like datmsrvre.socntzcod,
        	espcod_2    like datmsrvre.espcod,
        	socntzcod_3 like datmsrvre.socntzcod,
        	espcod_3    like datmsrvre.espcod,
        	socntzcod_4 like datmsrvre.socntzcod,
        	espcod_4    like datmsrvre.espcod,
        	socntzcod_5 like datmsrvre.socntzcod,
        	espcod_5    like datmsrvre.espcod,
        	socntzcod_6 like datmsrvre.socntzcod,
        	espcod_6    like datmsrvre.espcod,
        	socntzcod_7 like datmsrvre.socntzcod,
        	espcod_7    like datmsrvre.espcod,
        	socntzcod_8 like datmsrvre.socntzcod,
        	espcod_8    like datmsrvre.espcod,
        	socntzcod_9 like datmsrvre.socntzcod,
        	espcod_9    like datmsrvre.espcod,
        	socntzcod_10 like datmsrvre.socntzcod,
        	espcod_10    like datmsrvre.espcod
	end record
	
	define l_geocodigo record
	       cidcod like datkmpacid.mpacidcod,
	       cidnom like datkmpacid.cidnom,
	       ufdcod like datkmpacid.ufdcod,
	       brrcod like datkmpabrr.mpabrrcod,
	       brrnom like datkmpabrr.brrnom,
	       logcod like datkmpalgd.mpalgdcod,
	       logtip like datkmpalgd.lgdtip,
	       lognom like datkmpalgd.lgdnom,
	       lognum integer,
	       lcllgt like datkmpalgdsgm.lcllgt,
	       lclltt like datkmpalgdsgm.lclltt
	end record
	
	define l_conf_imd    	char(3),
	       l_logtip		char(10),
	       l_lognom		char(50),
	       l_lognum		integer,
	       l_logbai		char(50),
	       l_cidnom 	char (50),
	       l_uf 		char(2),
	       l_dat 		datetime year to day,
	       l_hor 		datetime hour to minute,		  
	       l_xmlRetorno 	char(32000),
	       l_c24lclpdrcod 	char(1)
	     
	initialize l_geocodigo.* to null
	let l_xmlRetorno = null

display 'disponibilidade imediata'
display 'l_cidnom: ' ,l_cidnom
display 'l_uf    : ' ,l_uf
 
    if l_cidnom is null 
	 or l_cidnom = "" 
	 or l_uf is null 
	 or l_uf = "" then
    	
    	call ctf00m06_xmlerro("DISPONIBILIDADE_IMEDIATA",1,"Cidade e(ou) UF Nulo!")
    	returning l_xmlRetorno
    	
    	return l_xmlRetorno
    	
   end if
   
   if mr_servicos.socntzcod is null then
   	 
   	 call ctf00m06_xmlerro("DISPONIBILIDADE_IMEDIATA",2,"Sem Servico")
    	 returning l_xmlRetorno
    	
    	 return l_xmlRetorno	
    	 
    end if
    
    if length(l_cidnom clipped) > 0 then
    	  let l_geocodigo.cidnom = l_cidnom
    end if
    
    if length(l_uf clipped) > 0 then
    	  let l_geocodigo.ufdcod = l_uf
    end if
    
    if length(l_logbai clipped) > 0  then
    	  let l_geocodigo.brrnom = l_logbai
    end if
    
    if length(l_lognom clipped) > 0  then
    	  let l_geocodigo.lognom = l_lognom
    end if
    
    if length(l_lognum clipped) > 0  then
    	  let l_geocodigo.lognum = l_lognum
    end if
    
    if length(l_logtip clipped) > 0  then
    	  let l_geocodigo.logtip = l_logtip
    end if
    
    let l_dat = current
    let l_hor = current
    
	select mpacidcod 
		into l_geocodigo.cidcod
		from datkmpacid
		where cidnom = l_geocodigo.cidnom
		and  ufdcod = l_geocodigo.ufdcod

	select mpabrrcod
		into l_geocodigo.brrcod
		from datkmpabrr
		where mpacidcod = l_geocodigo.cidcod
		and brrnom = l_geocodigo.brrnom

	select mpalgdcod
		into l_geocodigo.logcod
		from datkmpalgd
		where lgdnom = l_geocodigo.lognom
		and   lgdtip = l_geocodigo.logtip
		and	  mpacidcod = l_geocodigo.cidcod	

	call cty05g09_geocodificar_endereco(l_geocodigo.*)
		returning l_geocodigo.*
		
display 'l_geocodigo.*: ' ,l_geocodigo.cidnom ,'/' ,l_geocodigo.ufdcod

	if l_geocodigo.logcod is not null or
	   l_geocodigo.brrcod is not null   then
		let l_c24lclpdrcod = 3
	else
		let l_c24lclpdrcod = 1
	end if
    
	
	        
	call cty05g09_imdsrvflg(l_geocodigo.lclltt,
	 		        l_geocodigo.lcllgt,
	 		        "9",
	 		        l_geocodigo.cidnom,
	 		        l_geocodigo.ufdcod,
	 		        l_dat,
	 		        l_hor,
	 		        l_c24lclpdrcod,
	 		        mr_servicos.*,
	 		        l_geocodigo.lclltt,
	 		        l_geocodigo.lognom,
	 		        l_geocodigo.lognum,
	 		        l_geocodigo.brrnom,
	 		        l_geocodigo.cidnom,
	   		        l_geocodigo.ufdcod,
				   ""
	       		   )
	       			  
      returning l_conf_imd    
                              
      if l_conf_imd = true then
         let l_conf_imd = "SIM"
      else                    
         let l_conf_imd = "NAO"
      end if                  
      
   
      
      #--- Montando xml de retorno--#
      let l_xmlRetorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
		   	'<RESPONSE>',
			   '<SERVICO>DISPONIBILIDADE_IMEDIATA</SERVICO>', 
			   '<DISPONIVEL>',l_conf_imd,'</DISPONIVEL>',
   			'</RESPONSE>'

 	 return l_xmlRetorno

end function


#--------- Verifica servico imediato-----#
function cty05g09_imdsrvflg(lr_param, mr_servicos, c_local)

    define c_local record
   	lclltt	like datmlcl.lclltt,
        lgdnom	like datmlcl.lgdnom,
        lgdnum	like datmlcl.lgdnum,
        brrnom	like datmlcl.brrnom,
        cidnom	like datmlcl.cidnom,
        ufdcod	like datmlcl.ufdcod,
        lgdcep	like datmlcl.lgdcep
   end record
   
   define mr_servicos  record          #---> Array de servicos
	socntzcod   like datmsrvre.socntzcod,
	espcod      like datmsrvre.espcod,
	socntzcod_1 like datmsrvre.socntzcod,
	espcod_1    like datmsrvre.espcod,
	socntzcod_2 like datmsrvre.socntzcod,
	espcod_2    like datmsrvre.espcod,
	socntzcod_3 like datmsrvre.socntzcod,
	espcod_3    like datmsrvre.espcod,
	socntzcod_4 like datmsrvre.socntzcod,
	espcod_4    like datmsrvre.espcod,
	socntzcod_5 like datmsrvre.socntzcod,
	espcod_5    like datmsrvre.espcod,
	socntzcod_6 like datmsrvre.socntzcod,
	espcod_6    like datmsrvre.espcod,
	socntzcod_7 like datmsrvre.socntzcod,
	espcod_7    like datmsrvre.espcod,
	socntzcod_8 like datmsrvre.socntzcod,
	espcod_8    like datmsrvre.espcod,
	socntzcod_9 like datmsrvre.socntzcod,
	espcod_9    like datmsrvre.espcod,
	socntzcod_10 like datmsrvre.socntzcod,
	espcod_10    like datmsrvre.espcod
   end record
   
   define lr_param     record
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          atdsrvorg    like datmservico.atdsrvorg,
          cidnom       like datmlcl.cidnom,
          ufdcod       like datmlcl.ufdcod,
          data         like datmservico.atddatprg,
          hora         like datmservico.atdhorprg,
          c24lclpdrcod like datmlcl.c24lclpdrcod
   end record

   define m_parametros  record
           resultado    smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
           mensagem     char(100),
           acnlmttmp    like datkatmacnprt.acnlmttmp,
           acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
           netacnflg    like datkatmacnprt.netacnflg,
           atmacnprtcod like datkatmacnprt.atmacnprtcod
   end record

   define lr_ret          record
          imdsrvflg       char(1),
          veiculo_aciona  like datkveiculo.socvclcod,
          cota_disponivel char(1),
          atddatprg       like datmservico.atddatprg,
          atdhorprg       like datmservico.atdhorprg,
          mpacidcod       like datkmpacid.mpacidcod
   end record

   define l_resultado     smallint,
          l_mensagem      char(40),
          l_gpsacngrpcod  like datkmpacid.gpsacngrpcod,
          l_pergunta      char(1),
          l_conf_imd      char(1),
          l_dat		datetime year to day,
          l_hora	datetime hour to minute,
	  l_hor		char(5)
	  

   initialize  lr_ret.* to null

   let l_resultado     = null
   let l_mensagem      = null
   let l_gpsacngrpcod  = null
   let l_pergunta      = null
   let l_conf_imd      = "N"
   
   let l_dat = current
   let l_hora = current
   let l_hor = l_hora
   let l_hor = l_hor[1,2],":00"
   
   
   let lr_ret.atddatprg = lr_param.data
   let lr_ret.atdhorprg = lr_param.hora
   
   initialize  m_parametros.* to null
   call cts40g00_obter_parametro(lr_param.atdsrvorg)
        returning m_parametros.*
 
   #verificar se cidade e' atendida por GPS
   let l_gpsacngrpcod     = null
   

display 'lr_param.cidnom: ' ,          lr_param.cidnom
display 'lr_param.ufdcod: ' ,          lr_param.ufdcod
display 'm_parametros.atmacnprtcod' ,m_parametros.atmacnprtcod


      
   call cts41g03_tipo_acion_cidade(lr_param.cidnom,
                                   lr_param.ufdcod,
                                   m_parametros.atmacnprtcod,
                                   lr_param.atdsrvorg)
        returning l_resultado, l_mensagem, l_gpsacngrpcod, lr_ret.mpacidcod
    
    Display "cty05g09 ANDRE"
    Display "l_resultado", l_resultado
    Display "l_gpsacngrpcod", l_gpsacngrpcod
 
    if l_gpsacngrpcod > 0 then
      call cts51g00_cria_temp()
      returning l_resultado
  
      
      call cts51g00_cidade_com_GPS(lr_param.lclltt, 
					lr_param.lcllgt,
					lr_ret.mpacidcod, 
					lr_param.atdsrvorg,
					mr_servicos.socntzcod, 
					mr_servicos.espcod,
					lr_param.data, 
					lr_param.hora,
					m_parametros.atmacnprtcod,
					m_parametros.acnlmttmp,
					lr_param.c24lclpdrcod,
					"",
					"",
					"",
					"",
					"",
					"",
					"",
					"",
					mr_servicos.*,
					1,
					l_resultado,
					l_hor,
					lr_param.data,
					mr_servicos.socntzcod,
					c_local.*
                                   )
           returning l_pergunta, lr_ret.veiculo_aciona,
                     lr_ret.cota_disponivel
       display "l_pergunta", l_pergunta
	display "lr_ret.cota_disponivel", lr_ret.cota_disponivel
 	display "lr_ret.veiculo_aciona", lr_ret.veiculo_aciona
   
   else
	   
	   call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
	                                   mr_servicos.socntzcod, lr_param.data,
	                                   lr_param.hora)
	           returning l_pergunta, lr_ret.cota_disponivel
   end if

   ##let lr_ret.imdsrvflg = 'N'

   ## cidade c/GPS, sem QRV, mas com cota disponivel, deve-ser perguntar
   if l_gpsacngrpcod > 0 and 
      lr_ret.veiculo_aciona is null and
      lr_ret.cota_disponivel = true then

         let lr_ret.imdsrvflg = 'S'
         let lr_ret.atddatprg = null
         let lr_ret.atdhorprg = null

   end if
	
   if lr_ret.veiculo_aciona is not null then
   	let lr_ret.cota_disponivel = true
   end if
	
   return lr_ret.cota_disponivel
   

end function

#---------------------------------
# Recupera coordenadas do endereco
#---------------------------------
function cty05g09_geocodificar_endereco(l_geocodigo)
    
    define l_select     char(1500)
    
    define l_geocodigo record
    	cidcod like datkmpacid.mpacidcod,
    	cidnom like datkmpacid.cidnom,
    	ufdcod like datkmpacid.ufdcod,
	brrcod like datkmpabrr.mpabrrcod,
	brrnom like datkmpabrr.brrnom,
	logcod like datkmpalgd.mpalgdcod,
	logtip like datkmpalgd.lgdtip,
	lognom like datkmpalgd.lgdnom,
	lognum integer,
    	lcllgt like datkmpalgdsgm.lcllgt,
    	lclltt like datkmpalgdsgm.lclltt
    end record
    
    #------ pesquisa de ltt e lgt ------#
    if l_geocodigo.cidcod is not null then
	     if l_geocodigo.logcod is not null then
		    let l_select = "SELECT datkmpalgdsgm.lcllgt, ",
   		    		  "datkmpalgdsgm.lclltt ",
				  "from datkmpalgdsgm ",
				  "where datkmpalgdsgm.mpacidcod = ? ",
				  "and datkmpalgdsgm.mpalgdcod = ?"
	  		
			if l_geocodigo.lognum is not null then
			   let l_select = l_select clipped, 
	             	  " and datkmpalgdsgm.mpalgdincnum <= ? ",
                      " and datkmpalgdsgm.mpalgdfnlnum >= ? "
                      
   				   prepare p_geo1 from l_select
				   declare c_geo1 cursor for p_geo1
	      		   
			        open c_geo1 using l_geocodigo.cidcod,
                            		 	  l_geocodigo.logcod,
                            		 	  l_geocodigo.lognum,
                            		 	  l_geocodigo.lognum
        
 				   fetch c_geo1 into l_geocodigo.lcllgt,
                        	    		       l_geocodigo.lclltt
             		else
               
	              	   let l_select = l_select clipped, 
			    	   " and datkmpalgdsgm.mpalgdsgmseq = 1 "  

				   prepare p_geo2 from l_select
				   declare c_geo2 cursor for p_geo2
	      		   
			        open c_geo2 using l_geocodigo.cidcod,
			        	   	 l_geocodigo.logcod
        
 				   fetch c_geo2 into l_geocodigo.lcllgt,
                        	    		       l_geocodigo.lclltt
   
                    end if  
                
		else
		
			if l_geocodigo.brrcod is not null then
		 	   let l_select = "select datkmpabrr.lcllgt, ",
    	  		   		 "datkmpabrr.lclltt ",
    	  		   		 "from datkmpabrr ",
    	  		   		 "where datkmpabrr.mpacidcod = ? ",
    	  		   		 "and datkmpabrr.mpabrrcod = ? "
			   
				   prepare p_geo3 from l_select
				   declare c_geo3 cursor for p_geo3
	      		   
			        open c_geo3 using l_geocodigo.cidcod,
                            		 	  l_geocodigo.brrcod
        
 				   fetch c_geo3 into l_geocodigo.lcllgt,
                        	    		       l_geocodigo.lclltt
   
			 else
   		 	   let l_select = "SELECT datkmpacid.lcllgt, ",
   	 	    		  	"datkmpacid.lclltt ",
 		      			"from datkmpacid ",
				     	"where datkmpacid.mpacidcod = ? "
 					     
			   prepare p_geo4 from l_select
			   declare c_geo4 cursor for p_geo4
      		   
		        open c_geo4 using l_geocodigo.cidcod
                           		 	  
 			   fetch c_geo4 into l_geocodigo.lcllgt,
                       	    		       l_geocodigo.lclltt
                       	    		                		 	  
			end if
	 	end if
    	else
    	   	 return l_geocodigo.*
    	end if
   
   
    return l_geocodigo.*
end function


#----Verifica disponibilidade para alteracao---------------------#
function cty05g09_alteracao(param)
	define param record
		atdsrvnum like datmservico.atdsrvnum,
		atdsrvano like datmservico.atdsrvano
	end record
	
	define l_ret record
		flag smallint,
		retcod integer,
		retmsg char(80)
	end record
	
	define ws record
		atdfnlflg like datmservico.atdfnlflg, 
		atdetpcod like datmservico.atdetpcod,
		srvprsacnhordat like datmservico.srvprsacnhordat
	end record
	
	define l_altflg smallint
	define l_c24opmat like  datmservico.c24opemat
	define l_sql char(300)
	
	
	initialize l_ret.* to null
	initialize ws.* to null
	let l_altflg = null
	let l_c24opmat= null
	let l_sql= null
	
	call cts40g18_srv_em_uso(param.*)
		returning l_altflg, l_c24opmat
	
	
	let l_sql = " select 	atdfnlflg, ",
		   "    	atdetpcod, ",
		   "		srvprsacnhordat ",
                   "    from 	datmservico ",
                   "   where 	atdsrvnum = ? ",
                   " 	 and 	atdsrvano = ? "

	prepare cty05g09001 from l_sql
	declare ccty05g09001 cursor for cty05g09001
	
	open ccty05g09001 using param.atdsrvnum, param.atdsrvano
	whenever error continue
	  	fetch ccty05g09001 into ws.atdfnlflg,
	  				ws.atdetpcod,
	  				ws.srvprsacnhordat
	whenever error stop
	
	if ( l_altflg = false ) then 
		if( ws.atdfnlflg <> "S"  and
		    	(ws.atdetpcod <3 or 
			ws.atdetpcod >5) and
			ws.srvprsacnhordat > current) then
			let l_ret.flag = true
			let l_ret.retcod = 0
			let l_ret.retmsg = "OK"
		else
			let l_ret.flag = false
			let l_ret.retcod = 1
			let l_ret.retmsg = "Servico ja acionado"
		end if
	else
		let l_ret.flag = false
		let l_ret.retcod = 2
		let l_ret.retmsg = "Servico esta sendo alterado"
	end if
	
	return l_ret.*
	
end function


#---Verifica a possibilidade de Retorno--------------------------#
function cty05g09_retorno(param)
	
	define param record
		atdsrvnum like datmservico.atdsrvnum,
		atdsrvano like datmservico.atdsrvano
	end record
	
	define l_ret record
		garantia smallint,
		complemento smallint,
		retcod integer,
		retmsg char(80)
	end record
	
	define ws record
		atdfnlflg like datmservico.atdfnlflg, 
		atdetpcod like datmservico.atdetpcod,
		srvprsacnhordat like datmservico.srvprsacnhordat
	end record
	
	define l_dat datetime year to second
	define l_sql char(300)
	
	initialize l_ret.* to null
	initialize ws.* to null
	let l_dat = current
	
	
	let l_sql = " select atdfnlflg, ",
		   "         atdetpcod, ",
		   "	     srvprsacnhordat ",
                   "    from datmservico ",
                   "   where atdsrvnum = ? ",
                   " 	 and atdsrvano = ? "                                                   
                   
	prepare cty05g09002 from l_sql
	declare ccty05g09002 cursor for cty05g09002
	
	open ccty05g09002 using param.atdsrvnum, param.atdsrvano
	whenever error continue
	  	fetch ccty05g09002 into ws.atdfnlflg,
	  				ws.atdetpcod,
	  				ws.srvprsacnhordat
	whenever error stop
	 
	if((ws.atdfnlflg = "S" or 
         ws.atdfnlflg = "A") and 
	    ws.atdetpcod >=3 and 
	    ws.atdetpcod <=5) then
		if((ws.srvprsacnhordat + 90 units day) > current) then
		   if((ws.srvprsacnhordat + 30 units day) > current) then
               let l_ret.complemento = true
             else
               let l_ret.complemento = false
             end if
             
               let l_ret.garantia = true
			let l_ret.retcod = 0
			let l_ret.retmsg = "OK"
		else
			let l_ret.garantia = false
			let l_ret.complemento = false
			let l_ret.retcod = 1
			let l_ret.retmsg = "Servico fora do tempo de garantia"
		end if
	else
		let l_ret.garantia = false
		let l_ret.complemento = false
		let l_ret.retcod = 2
		let l_ret.retmsg = "Servico Cancelado ou nao Concluido"
	end if
	
	return l_ret.*

end function

#----------------------------------------------------
function cty05g09_regulador(param)
#----------------------------------------------------
	define param record
		atdsrvnum like datmservico.atdsrvnum,
		atdsrvano like datmservico.atdsrvano,
		novaData date,
		novaHora datetime hour to minute
	end record
	
	define ws record
	    cotqtd           like datmsrvrgl.cotqtd,
	    utlqtd           like datmsrvrgl.utlqtd,
	    srvrglcod        like datmsrvrgl.srvrglcod,
	    atdsrvorg	     like datmsrvrgl.atdsrvorg,
	    cidcod           like glakcid.cidcod,
	    cidsedcod        like glakcid.cidcod,
	    cidnom	     like glakcid.cidnom,
	    ufdcod	     like glakcid.ufdcod
	 end record
	
	
	define l_cotflg smallint
	define l_ret smallint
	define l_mensagemCod smallint
	define l_mensagem char(100)
	  
	initialize ws.* to null
	let l_mensagem = null 
	let l_mensagemCod = null
	let l_ret = null
	let l_cotflg = null
	let ws.atdsrvorg = 9
		
	select socntzgrpcod into ws.srvrglcod
   	  from datksocntz where socntzcod = (select socntzcod from datmsrvre
  					    where atdsrvnum = param.atdsrvnum
					      and atdsrvano = param.atdsrvano)
	
	
	select cidnom, ufdcod
	into ws.cidnom, ws.ufdcod
	from datmlcl
	where atdsrvnum = param.atdsrvnum
	  and atdsrvano = param.atdsrvano	
	
	
	
	#-----------  Obtendo Codigo de Cidade e Cidade-Sede  --------#
	call cty10g00_obter_cidcod(ws.cidnom, ws.ufdcod)
      			returning l_ret, l_mensagemCod, ws.cidcod

      	call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      			returning l_ret, l_mensagemCod, ws.cidsedcod
	#-------------------------------------------------------------# 
		
	
	select cotqtd, utlqtd
	  into ws.cotqtd, ws.utlqtd
	  from datmsrvrgl
	 where cidcod = ws.cidsedcod
	   and atdsrvorg = ws.atdsrvorg
	   and srvrglcod = ws.srvrglcod
	   and rgldat = param.novaData
	   and rglhor = param.novaHora
	
	
	if (ws.cotqtd > ws.utlqtd) then	
		update datmsrvrgl set
			utlqtd = utlqtd + 1
		where cidcod = ws.cidsedcod
		  and atdsrvorg = ws.atdsrvorg
		  and srvrglcod = ws.srvrglcod
		  and rgldat = param.novaData
		  and rglhor = param.novaHora
		  
		call ctc59m03_regulador(param.atdsrvnum, param.atdsrvano)
		returning l_ret
		
		if l_ret <> 0 then
			update datmsrvrgl set
			utlqtd = utlqtd - 1
			where cidcod = ws.cidsedcod
			  and atdsrvorg = ws.atdsrvorg
			  and srvrglcod = ws.srvrglcod
			  and rgldat = param.novaData
			  and rglhor = param.novaHora
			  
		 	let l_mensagemCod = 2 
		 	let l_mensagem = "Nao e possivel alterar a data e(ou) hora"
		 else
		 	let l_mensagemCod = 1 
		 	let l_mensagem = "OK"
		end if
	else
		let l_mensagemCod = 3 
		let l_mensagem = "Nao ha cota disponivel"
	end if
	
	return l_mensagemCod, l_mensagem
	
end function

function cty05g09_buscaCoordenadas(l_logtip,
		      		   l_lognom,
		      		   l_lognum,
		      		   l_logbai,
		      		   l_cidnom,
		      		   l_uf)

	define l_geocodigo record
		cidcod like datkmpacid.mpacidcod,
		cidnom like datkmpacid.cidnom,
		ufdcod like datkmpacid.ufdcod,
		brrcod like datkmpabrr.mpabrrcod,
		brrnom like datkmpabrr.brrnom,
		logcod like datkmpalgd.mpalgdcod,
		logtip like datkmpalgd.lgdtip,
		lognom like datkmpalgd.lgdnom,
		lognum integer,
		lcllgt like datkmpalgdsgm.lcllgt,
		lclltt like datkmpalgdsgm.lclltt
	end record
	
	define l_logtip		char(10),
	       l_lognom		char(50),
	       l_lognum		integer,
	       l_logbai		char(50),
	       l_cidnom 	char (50),
	       l_uf 		char(2),
	       l_c24lclpdrcod 	char(1),
	       l_lcllgt	like	datkmpalgdsgm.lcllgt,
	       l_lclltt	like	datkmpalgdsgm.lclltt
	

	let l_lcllgt = null
	let l_lclltt = null
	let l_c24lclpdrcod = null
	initialize l_geocodigo.* to null
	
	
	#if l_cidnom clipped <> "" then
		let l_geocodigo.cidnom = l_cidnom clipped
	#end if
	
	#if l_uf clipped <> ""  then
		let l_geocodigo.ufdcod = l_uf clipped
	#end if
	
	#if l_logbai clipped <> ""  then
		let l_geocodigo.brrnom = l_logbai clipped
	#end if
	
	#if l_lognom clipped <> ""  then
		let l_geocodigo.lognom = l_lognom clipped
	#end if
	
	#if l_lognum clipped <> ""  then
		let l_geocodigo.lognum = l_lognum clipped
	#end if
	
	#if l_logtip clipped <> ""  then
		let l_geocodigo.logtip = l_logtip clipped
	#end if

	select mpacidcod 
		into l_geocodigo.cidcod
		from datkmpacid
		where cidnom = l_geocodigo.cidnom
		and  ufdcod = l_geocodigo.ufdcod
	
	select mpabrrcod
		into l_geocodigo.brrcod
		from datkmpabrr
		where mpacidcod = l_geocodigo.cidcod
		and brrnom = l_geocodigo.brrnom
	
	select mpalgdcod                                        
		into l_geocodigo.logcod                         
		from datkmpalgd                                 
		where lgdnom = l_geocodigo.lognom               
		and   lgdtip = l_geocodigo.logtip               
		and	  mpacidcod = l_geocodigo.cidcod	
	
	call cty05g09_geocodificar_endereco(l_geocodigo.*)
		returning l_geocodigo.*

	if l_geocodigo.logcod is not null or
	   l_geocodigo.brrcod is not null   then
		let l_c24lclpdrcod = 3
	else
		let l_c24lclpdrcod = 1
	end if
          
     return l_geocodigo.lcllgt, l_geocodigo.lclltt, l_c24lclpdrcod
     
end function
     
function cty05g09_verifica_prestador(lr_param)
    
    define lr_param record                
           atdsrvnum like datmservico.atdsrvnum,
           atdsrvano like datmservico.atdsrvano
    end record    
    
    define lr_hora record 
       agddat    like datmsrvrgl.rgldat, 
       agdhor    like datmsrvrgl.rglhor
    end record            
    
    define lr_agd_p  record
           min_atddatprg        like datmservico.atddatprg,
           min_atdhorprg        like datmservico.atdhorprg,
           max_atddatprg        like datmservico.atddatprg,
           max_atdhorprg        like datmservico.atdhorprg
    end record
    
    define ws           record
        atdprscod        like datmservico.atdprscod,
        socvclcod        like datmservico.socvclcod,
        srrcoddig        like datmservico.srrcoddig,
        atddat           like datmservico.atddat,
        atdhor           like datmservico.atdhor
    end record

    define lr_ret       record
        atdsrvnum        like datmservico.atdsrvnum,
        atdsrvano        like datmservico.atdsrvano,
        atdprscod        like datmservico.atdprscod,
        socvclcod        like datmservico.socvclcod,
        srrcoddig        like datmservico.srrcoddig,
        atddatprg        like datmservico.atddatprg,
        atdhorprg        like datmservico.atdhorprg
    end record
        
    define l_retorno           smallint,
           l_contador          smallint,          
           l_salva_agddat_min  like datmsrvrgl.rgldat,
           l_salva_agdhor_min  like datmsrvrgl.rglhor,
           l_salva_agddat_max  like datmsrvrgl.rgldat,
           l_salva_agdhor_max  like datmsrvrgl.rglhor,           
           l_index             integer,
           l_intervalo         integer           
    
    let l_retorno = false 
    let l_contador = null         
    let l_salva_agddat_min = null
    let l_salva_agdhor_min = null
    let l_salva_agddat_max = null
    let l_salva_agdhor_max = null
    let l_index = 0 
    let l_intervalo = 4
    
    initialize lr_agd_p.* to null
        
    if m_cty05g09_prep is null or
       m_cty05g09_prep <> true then
     call cty05g09_prepare()
   end if  
        
    
    open ccty05g09006 using lr_param.atdsrvnum,
                            lr_param.atdsrvano
    whenever error continue 
    fetch ccty05g09006  into ws.atdprscod, 
                             ws.socvclcod, 
                             ws.srrcoddig,
                             ws.atddat,                            
                             ws.atdhor                             
                             
    whenever error stop
    
    display "ws.atdprscod = ",ws.atdprscod
    display "ws.socvclcod = ",ws.socvclcod
    display "ws.srrcoddig = ",ws.srrcoddig
                
    open ccty05g09007 using ws.socvclcod,     
                            ws.atdprscod,
                            ws.atddat
    whenever error continue 
    foreach  ccty05g09007 into lr_ret.atdsrvnum
                              ,lr_ret.atdsrvano
                              ,lr_ret.socvclcod
                              ,lr_ret.srrcoddig
                              ,lr_ret.atddatprg
                              ,lr_ret.atdhorprg
                                      
        let l_salva_agddat_min = lr_ret.atddatprg  
        let l_salva_agdhor_min = lr_ret.atdhorprg 
        let l_salva_agddat_max = lr_ret.atddatprg          
        let l_salva_agdhor_max = lr_ret.atdhorprg          
        
        
         
        let l_retorno = true
        display "lr_ret.atdsrvnum = ",lr_ret.atdsrvnum
        display "lr_ret.atdsrvano = ",lr_ret.atdsrvano
        display "lr_ret.atddatprg = ",lr_ret.atddatprg
        display "lr_ret.atdhorprg = ",lr_ret.atdhorprg                                        
           
           call cty05g09_ins_prestador(lr_ret.atdsrvnum
                                      ,lr_ret.atdsrvano
                                      ,ws.atdprscod
                                      ,lr_ret.socvclcod
                                      ,lr_ret.srrcoddig
                                      ,lr_ret.atddatprg
                                      ,lr_ret.atdhorprg)
                                                                 
            for l_index = 1 to l_intervalo                                                          
                 
                 let lr_ret.atdhorprg = l_salva_agdhor_min - 30 units minute
                 
                 
                 call cty05g09_ins_prestador(lr_ret.atdsrvnum
                                      ,lr_ret.atdsrvano
                                      ,ws.atdprscod
                                      ,lr_ret.socvclcod
                                      ,lr_ret.srrcoddig
                                      ,lr_ret.atddatprg
                                      ,lr_ret.atdhorprg) 
                 
                 let l_salva_agdhor_min = lr_ret.atdhorprg
                                      
                                                      
            end for                                                   
                          
            for l_index = 1 to l_intervalo                                                          
               let lr_ret.atdhorprg = l_salva_agdhor_max + 30 units minute
            
               call cty05g09_ins_prestador(lr_ret.atdsrvnum
                                          ,lr_ret.atdsrvano
                                          ,ws.atdprscod
                                          ,lr_ret.socvclcod
                                          ,lr_ret.srrcoddig
                                          ,lr_ret.atddatprg
                                          ,lr_ret.atdhorprg)                                      
               let l_salva_agdhor_max = lr_ret.atdhorprg                                          
                                          
            end for                                                                          
    end foreach

   return l_retorno
   
   
end function      

#--------------------------------------------------------------
 function cty05g09_verifica_retorno(p_cty05g09)
#--------------------------------------------------------------
 define p_cty05g09   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdorgsrvnum     like datmservico.atdsrvnum,
    atdorgsrvano     like datmservico.atdsrvano,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        like datmservico.atdhorprg,
    tipo             smallint  # Tipo 1 Busca recursiva aumentando o intervalo
 end record                    # Tipo 2 Busca uma unica vez

 define ws           record
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig
 end record

 define lr_ret       record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        like datmservico.atdhorprg
 end record

 define lr_org       record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdprscod        like datmservico.atdprscod,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig
 end record

 define lr_agd_p  record
    min_atddatprg        like datmservico.atddatprg,
    min_atdhorprg        like datmservico.atdhorprg,
    max_atddatprg        like datmservico.atddatprg,
    max_atdhorprg        like datmservico.atdhorprg
 end record

 define lr_agd_c  record
    min_atddatprg        like datmservico.atddatprg,
    min_atdhorprg        like datmservico.atdhorprg,
    max_atddatprg        like datmservico.atddatprg,
    max_atdhorprg        like datmservico.atdhorprg
 end record

 define l_ret            smallint,
        l_contador       smallint,
        l_status         smallint,
        l_primeiro       smallint,
        l_intervalo      smallint,
        l_resultado      smallint,
        l_mensagem       char(60),
        l_min_data       datetime year to second,
        l_max_data       datetime year to second,
        l_data           datetime year to second,
        l_data_2         datetime year to second,
        l_data_char      char(19),
        l_atual_data     like datmservico.atddatprg,
        l_atual_hora     like datmservico.atdhorprg

 initialize ws, lr_ret, lr_org, l_ret, lr_agd_p, lr_agd_c to null

 let l_ret = false
 let l_status = 0
 let l_contador = 0
 let l_primeiro = true

 call cta12m00_seleciona_datkgeral("PSOTMPCONRET") # Parametro de tempo do controle de retorno
            returning  l_resultado
                      ,l_mensagem
                      ,l_intervalo

 if l_resultado <> 1 or   # Caso nao exista parametro ou com valor zero
    l_intervalo <= 0 then

    return l_contador
          ,lr_agd_p.min_atddatprg
          ,lr_agd_p.min_atdhorprg
          ,lr_agd_p.max_atddatprg
          ,lr_agd_p.max_atdhorprg
 end if

 let l_data_char = p_cty05g09.atddatprg
 let l_data_char = l_data_char[7,10],'-', l_data_char[4,5], '-', l_data_char[1,2]
                 , ' ', p_cty05g09.atdhorprg, ':00'
 let l_data = l_data_char
 let l_data_2 = l_data

 let l_min_data = l_data - l_intervalo units hour # Intervalo de controle com duas horas antes
 let l_max_data = l_data + l_intervalo units hour # duas horas depois de atendimento ja agendados

 let l_data_char = l_min_data
 let lr_agd_p.min_atdhorprg = l_data_char[12,16]
 let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
 let lr_agd_p.min_atddatprg = l_data_char

 let l_data_char = l_max_data
 let lr_agd_p.max_atdhorprg = l_data_char[12,16]
 let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
 let lr_agd_p.max_atddatprg = l_data_char

 if p_cty05g09.atdorgsrvnum is not null and
    p_cty05g09.atdorgsrvano is not null then

    # Busca o prestador do servico original
    select atdprscod, socvclcod, srrcoddig
      into ws.atdprscod, ws.socvclcod, ws.srrcoddig
      from datmservico
     where atdsrvnum = p_cty05g09.atdorgsrvnum
       and atdsrvano = p_cty05g09.atdorgsrvano

    # Foreach de atendimentos dentro do intervalo
    declare c_cty05g09_015 cursor for
    select atdsrvnum, atdsrvano,
           socvclcod, srrcoddig,
           atddatprg, atdhorprg
      from datmservico
     where atdetpcod not in (5,6) # 5 - CANCELADO, 6 - EXCLUIDO
       #and not (atdsrvnum = p_cty05g09.atdsrvnum
       #and  atdsrvano = p_cty05g09.atdsrvano)
       and (atddatprg >= lr_agd_p.min_atddatprg
       and  atdhorprg >  lr_agd_p.min_atdhorprg)
       and (atddatprg <= lr_agd_p.max_atddatprg
       and  atdhorprg <  lr_agd_p.max_atdhorprg)
    ## and atdprscod = ws.atdprscod

    foreach c_cty05g09_015 into lr_ret.atdsrvnum
                          ,lr_ret.atdsrvano
                          ,lr_ret.socvclcod
                          ,lr_ret.srrcoddig
                          ,lr_ret.atddatprg
                          ,lr_ret.atdhorprg

        if p_cty05g09.atdsrvnum = lr_ret.atdsrvnum and
           p_cty05g09.atdsrvano = lr_ret.atdsrvano then
            continue foreach
        end if

        select 1
          into l_status
          from datmservico
         where atdsrvnum  = lr_ret.atdsrvnum
           and atdsrvano  = lr_ret.atdsrvano
           and socvclcod = ws.socvclcod
          #or  srrcoddig = ws.srrcoddig

        if sqlca.sqlcode = 100 then
            select atdorgsrvnum, atdorgsrvano
              into lr_org.atdsrvnum, lr_org.atdsrvano
              from datmsrvre
             where atdsrvnum  = lr_ret.atdsrvnum
               and atdsrvano  = lr_ret.atdsrvano
               and retprsmsmflg = 'S'
               and atdorgsrvnum is not null
               and atdorgsrvano is not null

            if sqlca.sqlcode = 0 then
                select 1
                  into l_status
                  from datmservico
                 where atdsrvnum  = lr_org.atdsrvnum
                   and atdsrvano  = lr_org.atdsrvano
                   and socvclcod = ws.socvclcod
                  #or  srrcoddig = ws.srrcoddig
                if sqlca.sqlcode = 100 then
                    continue foreach
                end if
            else
                continue foreach
            end if
        end if

        if l_contador = 0 then
           let l_data_char = l_data_2
           let lr_agd_p.min_atdhorprg = l_data_char[12,16]
           let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
           let lr_agd_p.min_atddatprg = l_data_char

           let lr_agd_p.max_atdhorprg = lr_agd_p.min_atdhorprg
           let lr_agd_p.max_atddatprg = lr_agd_p.min_atddatprg
        end if

        let l_contador = l_contador + 1
        let l_data_char = lr_ret.atddatprg
        let l_data_char = l_data_char[7,10],'-', l_data_char[4,5], '-', l_data_char[1,2]
                        , ' ', lr_ret.atdhorprg, ':00'

        let l_data = l_data_char
        let l_min_data = l_data - l_intervalo units hour
        let l_max_data = l_data + l_intervalo units hour

        let l_data_char = l_min_data
        let lr_agd_c.min_atdhorprg = l_data_char[12,16]
        let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
        let lr_agd_c.min_atddatprg = l_data_char

        let l_data_char = l_max_data
        let lr_agd_c.max_atdhorprg = l_data_char[12,16]
        let l_data_char = l_data_char[9,10],'/', l_data_char[6,7], '/', l_data_char[1,4]
        let lr_agd_c.max_atddatprg = l_data_char

        if lr_agd_c.min_atddatprg <= lr_agd_p.min_atddatprg and
           lr_agd_c.min_atdhorprg <  lr_agd_p.min_atdhorprg then
           let lr_agd_p.min_atddatprg = lr_agd_c.min_atddatprg
           let lr_agd_p.min_atdhorprg = lr_agd_c.min_atdhorprg
        end if
        if lr_agd_c.max_atddatprg >= lr_agd_p.max_atddatprg and
           lr_agd_c.max_atdhorprg >  lr_agd_p.max_atdhorprg then
           let lr_agd_p.max_atddatprg = lr_agd_c.max_atddatprg
           let lr_agd_p.max_atdhorprg = lr_agd_c.max_atdhorprg
        end if

    end foreach

    if p_cty05g09.tipo = 1 and
       l_contador > 0 then

       let l_atual_data = today
       let l_atual_hora = current

       while true
           let l_status = 0
           call cty05g09_verifica_retorno(p_cty05g09.atdsrvnum
                                         ,p_cty05g09.atdsrvano
                                         ,p_cty05g09.atdorgsrvnum
                                         ,p_cty05g09.atdorgsrvano
                                         ,lr_agd_p.min_atddatprg
                                         ,lr_agd_p.min_atdhorprg
                                         ,2)
               returning l_status
                        ,lr_agd_c.min_atddatprg
                        ,lr_agd_c.min_atdhorprg
                        ,lr_agd_c.max_atddatprg
                        ,lr_agd_c.max_atdhorprg
           if l_status > 0 then
               if lr_agd_c.min_atddatprg <= l_atual_data and  # Limite minimo de busca ate hora atual
                  lr_agd_c.min_atdhorprg <  l_atual_hora then
                   exit while
               end if
               if lr_agd_c.min_atddatprg <= lr_agd_p.min_atddatprg and
                  lr_agd_c.min_atdhorprg <  lr_agd_p.min_atdhorprg then
                  let lr_agd_p.min_atddatprg = lr_agd_c.min_atddatprg
                  let lr_agd_p.min_atdhorprg = lr_agd_c.min_atdhorprg
               end if
           else
              exit while
           end if
       end while
       while true
          let l_status = 0
          call cty05g09_verifica_retorno(p_cty05g09.atdsrvnum
                                        ,p_cty05g09.atdsrvano
                                        ,p_cty05g09.atdorgsrvnum
                                        ,p_cty05g09.atdorgsrvano
                                        ,lr_agd_p.max_atddatprg
                                        ,lr_agd_p.max_atdhorprg
                                        ,2)
              returning l_status
                       ,lr_agd_c.min_atddatprg
                       ,lr_agd_c.min_atdhorprg
                       ,lr_agd_c.max_atddatprg
                       ,lr_agd_c.max_atdhorprg
          if l_status > 0 then
             if lr_agd_c.max_atddatprg >= lr_agd_p.max_atddatprg and
                lr_agd_c.max_atdhorprg >  lr_agd_p.max_atdhorprg then
                let lr_agd_p.max_atddatprg = lr_agd_c.max_atddatprg
                let lr_agd_p.max_atdhorprg = lr_agd_c.max_atdhorprg
             end if
          else
              exit while
          end if
       end while
    end if
 end if

 return l_contador
       ,lr_agd_p.min_atddatprg
       ,lr_agd_p.min_atdhorprg
       ,lr_agd_p.max_atddatprg
       ,lr_agd_p.max_atdhorprg

end function  #  cty05g09_verifica_retorno

#------------------------------------------------------------------------------
function cty05g09_cria_temp()
#------------------------------------------------------------------------------

 call cty05g09_drop_temp()

 whenever error continue
      create temp table cty05g09_temp_agenda(data       date         ,                              
                                             hora       datetime hour to minute     
                                             ) with no log
  whenever error stop

  if sqlca.sqlcode <> 0  then

	 display "1523 - sqlca.sqlcode = ",sqlca.sqlcode
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cty05g09_drop_temp()
	  end if

	 return false

  end if
  
  whenever error continue
      create temp table cty05g09_temp_prestador(atdprscod  decimal(6,0),
                                                socvclcod  decimal(6,0),
                                                srrcoddig  decimal(8,0),
                                                data       date         ,                              
                                                hora       datetime hour to minute     
                                                ) with no log
  whenever error stop

  display "1546 - sqlca.sqlcode = ",sqlca.sqlcode
  if sqlca.sqlcode <> 0  then

	 display "1546 - sqlca.sqlcode = ",sqlca.sqlcode
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        display "1646"
	        call cty05g09_drop_temp()
	  end if

	 return false

  end if
      
  return true

end function

#------------------------------------------------------------------------------
function cty05g09_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cty05g09_temp_agenda
        drop table cty05g09_temp_prestador        
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cty05g09_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into cty05g09_temp_agenda'
	     , ' values(?,?)'
    prepare p_cty05g09_008 from w_ins
    
    let w_ins = 'insert into cty05g09_temp_prestador'
	     , ' values(?,?,?,?,?)'
    prepare p_cty05g09_009 from w_ins
                        
end function

#------------------------------------------------------------------------------
function cty05g09_ins_agenda(lr_param)
#------------------------------------------------------------------------------

   define lr_param record                       
          agddat    like datmsrvrgl.rgldat, 
          agdhor    like datmsrvrgl.rglhor
   
   end record        

   call cty05g09_prep_temp()
   
   
   
   whenever error continue
   execute p_cty05g09_008 using lr_param.agddat,
                                lr_param.agdhor                          
   whenever error stop                          
       
end function

#------------------------------------------------------------------------------
function cty05g09_ins_prestador(lr_param)
#------------------------------------------------------------------------------

   define lr_param record   
          atdsrvnum like datmservico.atdsrvnum,
          atdsrvano like datmservico.atdsrvano,           
          atdprscod like datmservico.atdprscod,
          socvclcod like datmservico.socvclcod,
          srrcoddig like datmservico.srrcoddig,           
          agddat    like datmsrvrgl.rgldat, 
          agdhor    like datmsrvrgl.rglhor
   
   end record        

   whenever error continue
   execute p_cty05g09_009 using lr_param.atdprscod,
                                lr_param.socvclcod,
                                lr_param.srrcoddig,                               
                                lr_param.agddat,
                                lr_param.agdhor                          
   whenever error stop                          
   
   display "sqlca.sqlcode = ",sqlca.sqlcode
   
       
end function

function cty05g09_verifica_agenda_disponivel(lr_param)


   define lr_param record 
          valido smallint 
   end record 

   define lr_agenda record             
          agddat    like datmsrvrgl.rgldat, 
          agdhor    like datmsrvrgl.rglhor   
   end record
   
   define lr_prestador record             
          agddat    like datmsrvrgl.rgldat, 
          agdhor    like datmsrvrgl.rglhor   
   end record
      
   define l_xmlRetorno char(32000),
          l_existe smallint,
          lr_agenda_salva_agddat like datmsrvrgl.rgldat
   
   initialize lr_agenda.* to null 
   let l_xmlRetorno = null 
   let l_existe = false 
   let  lr_agenda_salva_agddat = null 
   
    declare ccty05g09010 cursor for 
     select data,hora
     from cty05g09_temp_agenda 
     
    
    declare ccty05g09011 cursor for 
     select data,hora               
     from cty05g09_temp_prestador
     
    open ccty05g09011                          
    foreach ccty05g09011 into lr_prestador.agddat,
                              lr_prestador.agdhor
                                    
        display "lr_prestador.agddat = ",lr_prestador.agddat
        display "lr_prestador.agdhor = ",lr_prestador.agdhor      
        
    end foreach 
   
    declare ccty05g09012 cursor for  
     select data,hora                
     from cty05g09_temp_agenda a
     where not exists ( 
     select * from 
     cty05g09_temp_prestador b 
     where 
     a.data = b.data and 
     a.hora = b.hora)
     
     open ccty05g09012                          
     foreach ccty05g09012 into lr_prestador.agddat,
                               lr_prestador.agdhor
                                     
         display "lr_merge.agddat = ",lr_prestador.agddat
         display "lr_merge.agdhor = ",lr_prestador.agdhor      
         
     end foreach     
    
    let l_xmlRetorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
			       				   	 '<RESPONSE>',
							         	 '<SERVICO>LISTAR_AGENDA_DISPONIVEL</SERVICO>',
								         '<AGENDA>'
    
    open ccty05g09012                         
    foreach ccty05g09012 into lr_agenda.agddat,
                              lr_agenda.agdhor                                                             
    
      display "lr_agenda.agddat = ",lr_agenda.agddat
      display "lr_agenda.agdhor = ",lr_agenda.agdhor
      
      let l_existe = true 
                                                                                    
      if lr_agenda.agddat <>  lr_agenda_salva_agddat or 
          lr_agenda_salva_agddat is null then                                                                
      
          if lr_agenda_salva_agddat is not null then           
             let l_xmlRetorno = l_xmlRetorno clipped, '</HORARIOS></DATA>'
          end if    

          let l_xmlRetorno = l_xmlRetorno clipped, 
                               '<DATA>',
					  		    	         '<DIA>', lr_agenda.agddat ,'</DIA>',
			       				    		   '<HORARIOS>',
					  	    			      '<HORA>', lr_agenda.agdhor ,'</HORA>'							    			      						    			   						
					  	    			      
					  	    			      
            let lr_agenda_salva_agddat = lr_agenda.agddat
      else 
          let l_xmlRetorno = l_xmlRetorno clipped, 
                   		      '<HORA>', lr_agenda.agdhor ,'</HORA>'
                    
      end if           
      
    end foreach  
    
    #display "l_xmlRetorno = ",l_xmlRetorno clipped 
      
return l_xmlRetorno,l_existe

end function 

     