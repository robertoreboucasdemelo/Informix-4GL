#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        :                                              #
#  Modulo         : CTX32G00.4gl                                 #
#                   Regulador de servicos para fila MQ		 #
#  Analista Resp. : Raji                                         #
#  PSI            :                                              #
#................................................................#
#  Desenvolvimento: Andre Oliveira     		                 #
#  Liberacao      : 	                                         #
#................................................................#
##################################################################
# Alteracoes:                                                    #
#                                                                #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                #
#----------------------------------------------------------------#
# 16/03/2016             Eliane K, Fornax Regulacao Agenda Nova  #
#----------------------------------------------------------------#
##################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_agendaw      smallint

#----------------------------------------------------------------#
# Funcao que gera um xml de agenda de disponibilidade para       #
# o portal de segurado.						 #
#----------------------------------------------------------------#
function ctx32g00_ListarAgenda(l_cidnom,l_uf,l_socntzdes, l_atdsrvnum, l_atdsrvano)
#----------------------------------------------------------------#
	 define l_ctx32g00   record
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

   define l_lista_horarios   char (30000)    ###  16/03/2016 - Fornax
	 define l_ret          smallint
	 define l_mensagem     smallint
   define l_num_reg      int
	 define m_data         char(15)
	 define m_hora         char(10)
	 define m_srvhordat    char(150)
	 define i              smallint
	 define j              smallint
	 define l_tamanho      int
	 define l_posicao      int
	 define l_rsrchv       char(25) # Chave de reserva

   define l_cidnom     char (50)
		     ,l_uf         char(2)
		     ,l_socntzdes  like datksocntz.socntzdes
		     ,l_xmlRetorno char(32000)
		     ,l_doc_handle integer
		     ,l_temp       date
		     ,l_sql        char(10000)
		     ,l_atdsrvnum  like datmservico.atdsrvnum
		     ,l_atdsrvano  like datmservico.atdsrvano
		     ,l_etpcod     like datmservico.atdetpcod
		     ,l_asitipcod  like datmservico.asitipcod
		     ,l_ciaempcod  like datmservico.ciaempcod
         ,l_endindtpo  like datmlcl.c24lclpdrcod
         ,l_endltt     like datmlcl.lclltt
         ,l_endlgt     like datmlcl.lcllgt
         ,l_espcod     like datmsrvre.espcod
         ,l_natureza   like datmsrvre.socntzcod
         ,l_dtfmagen   char(10)
         ,l_dtrsagen   char(10)
         ,l_dtlimagen  date
         ,l_datefor    date

   initialize ws.* to null
   initialize l_ctx32g00.* to null
   initialize l_xmlRetorno,  l_etpcod,    l_ciaempcod, l_asitipcod, l_endindtpo,
              l_num_reg,     l_endltt,    l_endlgt,    l_espcod,    l_natureza,
              l_dtfmagen,    l_dtlimagen, l_dtrsagen, l_datefor to null
   initialize l_sql, m_data, m_hora, m_srvhordat to null
   initialize i, l_posicao to null

   let m_agendaw = false

   select grlinf into m_agendaw
   from datkgeral
   where grlchv = 'PSOAGENDAWATIVA'

### Verifica quando nao existe servico
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

        #-----carregando l-ctx32g00 ------------------#
        let l_ctx32g00.cidnom = l_cidnom
        let l_ctx32g00.ufdcod = l_uf

        select socntzgrpcod
          into l_ctx32g00.srvrglcod
     	    from datksocntzgrp
        where socntzgrpdes = l_socntzdes

		    if sqlca.sqlcode = notfound then
           display "l_ctx32g00.srvrglcod notfound"
     	     call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",3,"Servico nao encontrado")
       	        returning l_xmlRetorno
     	     return l_xmlRetorno
        end if
  
	      if sqlca.sqlcode = notfound then
           display "c_ctx32g00_001 notfound"
	         call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",3,"Servico nao encontrado")
	              returning l_xmlRetorno
           return l_xmlRetorno
        end if

	      # 17/03/2016 - informacoes para AgendaW ativa para bdatm002
        let l_endindtpo = 0
	      let l_endltt    = 0
	      let l_endlgt    = 0
	      let l_ciaempcod = 1  # Porto
        let l_espcod    = 0
        let l_asitipcod = 0

	   else  ### Verifica quando existe servico

        select socntzcod
	        into l_ctx32g00.srvrglcod
	        from datmsrvre
	       where atdsrvnum = l_atdsrvnum
           and atdsrvano = l_atdsrvano

	      select socntzgrpcod
          into l_ctx32g00.srvrglcod
	    	  from datksocntz
         where socntzcod = l_ctx32g00.srvrglcod

        if l_ctx32g00.srvrglcod = 1 then  # LINHA BRANCA
        	 let l_socntzdes = "LINHA BRANCA"
        else
        	 let l_socntzdes = "PLANO BASICO"
        end if
        
        select cidnom, ufdcod, c24lclpdrcod, lclltt, lcllgt
          into l_ctx32g00.cidnom,
               l_ctx32g00.ufdcod,
				       l_endindtpo,
               l_endltt,
               l_endlgt
          from datmlcl
         where atdsrvano = l_atdsrvano
           and atdsrvnum = l_atdsrvnum

        select atdetpcod, ciaempcod, asitipcod
          into l_etpcod, l_ciaempcod, l_asitipcod
          from datmservico
         where atdsrvnum = l_atdsrvnum
           and atdsrvano = l_atdsrvano

		    select espcod into l_espcod
          from datmsrvre
         where atdsrvnum = l_atdsrvnum
           and atdsrvano = l_atdsrvano

     end if

   if l_socntzdes = "LINHA BRANCA" then
   	  let l_natureza = 12 # GELADEIRA
   else
   		let l_natureza = 1 # HIDRAULICA
   end if

  ### Consulta agenda
  let l_ctx32g00.atdsrvorg = 9 #display VERIFICAR SE SEMPRE EH 9

  ### Dados para AgeendaW nao ativa
  let ws.srvrglcod = l_ctx32g00.srvrglcod

  call cts40g03_data_hora_banco(2)
       returning l_ctx32g00.rgldat, l_ctx32g00.rglhor

  let l_temp = null
  #-------------------------------------------------------------#
  #-----------  Obtendo Codigo de Cidade e Cidade-Sede  --------#
  call cty10g00_obter_cidcod(l_ctx32g00.cidnom, l_ctx32g00.ufdcod)
       returning l_ret, l_mensagem, ws.cidcod

  call ctd01g00_obter_cidsedcod(1, ws.cidcod)
       returning l_ret, l_mensagem, ws.cidsedcod

  #-------------------------------------------------------------#
  if l_etpcod = 1 or l_etpcod is null then
     # calcula hora/data inicial para consulta (+2h)
	   let ws.datymd    = l_ctx32g00.rgldat
	   let ws.strdathor = ws.datymd, " ", l_ctx32g00.rglhor
	   let ws.dathor    = ws.strdathor

     if l_ctx32g00.atdsrvorg = 9 then
        let ws.dathor    = ws.dathor + 3 units hour
     else
        let ws.dathor    = ws.dathor + 2 units hour
     end if
  else
      let ws.datymd    = l_ctx32g00.rgldat + 1 units day
	    let ws.strdathor = ws.datymd, " 6:00"
	    let ws.dathor    = ws.strdathor
  end if

  let ws.strdathor = ws.dathor
  let ws.datymd    = ws.strdathor[1,10]
  let l_ctx32g00.rgldat = ws.datymd
  let l_ctx32g00.rglhor = ws.strdathor[12,17]

  # calcula limite de 7 dias para agendamento
  let ws.rgldatmax =  l_ctx32g00.rgldat + 8 units day

  # Calcula hora cheia
  let ws.horstr = l_ctx32g00.rglhor[1,2], ":00"
  let ws.hora   = ws.horstr

  ### Obtem agenda
  if m_agendaw = false then   # regulacao antiga   ##00

   	 declare c_ctx32g00 cursor for
      select rgldat, rglhor
        from datmsrvrgl
	     where cidcod = ws.cidsedcod
	       and atdsrvorg = l_ctx32g00.atdsrvorg
	       and srvrglcod = ws.srvrglcod
	       and (rgldat > l_ctx32g00.rgldat
              or (rgldat = l_ctx32g00.rgldat
              and rglhor >= ws.hora))
	       and rgldat < ws.rgldatmax
	       and cotqtd > utlqtd
	    order by rgldat, rglhor

     foreach c_ctx32g00 into ws.agddat, ws.agdhor

        if (ws.agddat <> l_temp or l_temp is null) then

            if (l_temp is not null) then
		  			   let l_xmlRetorno = l_xmlRetorno clipped, '</HORARIOS></DATA>'
		  		  else
		  		     let l_xmlRetorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
		  					                	'<RESPONSE>',
		  						                '<SERVICO>LISTAR_AGENDA_DISPONIVEL</SERVICO>',
		  						                '<AGENDA>'
		  		 end if

           let l_xmlRetorno = l_xmlRetorno clipped, '<DATA><DIA>', ws.agddat ,'</DIA>',
		  			         				 '<HORARIOS>',
           									 '<HORA>', ws.agdhor ,'</HORA>'
		  		 let l_temp = ws.agddat
       else
		  	  	let l_xmlRetorno = l_xmlRetorno clipped,'<HORA>', ws.agdhor ,'</HORA>'
       end if

	   end foreach

	   if l_temp is null then
 	      call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",9999,"Nao existe agenda disponivel")
		         returning l_xmlRetorno
     else
        let l_xmlRetorno = l_xmlRetorno clipped,'</HORARIOS></DATA></AGENDA></RESPONSE>'
     end if

  else  # Regulacao Nova   ##00

     call cts02m08_obtem_agenda("",
                                l_ctx32g00.cidnom,
                                l_ctx32g00.ufdcod,
                                "",
                                "",
                                "",
                                "N",
                                l_endindtpo,
                                l_endltt,
                                l_endlgt,
                                l_ciaempcod,
                                l_ctx32g00.atdsrvorg,
                                l_asitipcod,
                                l_natureza,
                                l_espcod)
          returning l_num_reg, l_lista_horarios, l_rsrchv

     if l_num_reg > 0 then    #01
        let l_xmlRetorno = '<?xml version="1.0" encoding="ISO-8859-1" ?>',
                           '<RESPONSE>',
                           '<SERVICO>LISTAR_AGENDA_DISPONIVEL</SERVICO>',
                           '<AGENDA>'
	      let i = 1
	      let l_posicao = 0
        let l_dtlimagen = today
        let l_dtlimagen = l_dtlimagen + 90 units day
        let l_dtfmagen =  extend(l_dtlimagen, year to year), '-',
                          extend(l_dtlimagen, month to month), '-',
                          extend(l_dtlimagen, day to day)

        while i <= l_num_reg

		       let l_posicao = l_posicao + 1
		       let j = 1
		       let l_tamanho = length(l_lista_horarios) - 1
		       let m_srvhordat = null
		           while l_posicao <= l_tamanho
                   if l_lista_horarios[l_posicao, l_posicao] <> '|' then
                      let m_srvhordat[j] = l_lista_horarios[l_posicao, l_posicao]
                   else
			                exit  while
		               end if
                   let l_posicao = l_posicao + 1
		               let j = j+ 1
               end while
         	 let m_data = m_srvhordat[1,10]
           let m_hora = m_srvhordat[12,16]

           let l_dtrsagen = m_srvhordat
           if l_dtrsagen = l_dtfmagen then
               exit while
           end if

          if  l_datefor <> m_data then
               let l_xmlRetorno = l_xmlRetorno clipped, '</HORARIOS></DATA>'
            end if

           if l_datefor is null or l_datefor <> m_data then
              let l_xmlRetorno = l_xmlRetorno clipped, '<DATA><DIA>', m_data clipped,'</DIA>', '<HORARIOS>'
           end if

           let l_xmlRetorno = l_xmlRetorno clipped,
				                      '<HORA>', m_hora clipped,'</HORA>'

           let l_datefor = m_data

           let i = i+1

	      end while

        let l_xmlRetorno = l_xmlRetorno clipped,'</HORARIOS></DATA></AGENDA></RESPONSE>'

     else
        call ctf00m06_xmlerro("LISTAR_AGENDA_DISPONIVEL",9999,"Nao existe agenda disponivel")
             returning l_xmlRetorno
     end if   #01

  end if   ## 00

  return l_xmlRetorno clipped

end function


#----------------------------------------------------------------#
# Funcao que gera um xml de confirmacao de disponibilidade	 #
# imediata ao portal de segurado.				 #
#----------------------------------------------------------------#
function ctx32g00_DiponibilidadeImediata(  mr_servicos,
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
	initialize l_conf_imd to null

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

	call ctx32g00_geocodificar_endereco(l_geocodigo.*)
		returning l_geocodigo.*

	if l_geocodigo.logcod is not null or
	   l_geocodigo.brrcod is not null   then
		let l_c24lclpdrcod = 3
	else
		let l_c24lclpdrcod = 1
	end if


	call ctx32g00_imdsrvflg(l_geocodigo.lclltt,
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
function ctx32g00_imdsrvflg(lr_param, mr_servicos, c_local)

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
	        l_hor		char(5),
	        l_ctx34g02_validaservicoimediato  char(11)


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
   let  m_agendaw = false

   select grlinf into m_agendaw
   from datkgeral
   where grlchv = 'PSOAGENDAWATIVA' 
   
   let lr_ret.atddatprg = lr_param.data
   let lr_ret.atdhorprg = lr_param.hora

   initialize  m_parametros.* to null
   
   if ctx34g00_NovoAcionamento() and m_agendaw then  # AcionamentoWeb Ativo
   
      #obter codigo da cidade
      call cty10g00_obter_cidcod(lr_param.cidnom, lr_param.ufdcod)
           returning l_resultado, l_mensagem, lr_ret.mpacidcod

      # Verifica a possibilidade de acionamento imediato do servico no AcionamentoWeb
      call ctx34g02_validaservicoimediato(lr_param.cidnom,
                                          lr_param.ufdcod,
                                          lr_ret.mpacidcod,
                                          lr_param.lclltt,
                                          lr_param.lcllgt,
                                          lr_param.c24lclpdrcod,
                                          g_documento.ciaempcod,
                                          lr_param.atdsrvorg,
                                          mr_servicos.socntzcod,
                                          0, # ESPECILIDADE da NATUREZA
                                          0,                   # NAO UTILIZADO Codigo Assistencia
                                          0,                   # NAO UTILIZADO Codigo do Veiculo
                                          0)                   # NAO UTILIZADO Valor de IS do Veiculo
           returning l_ctx34g02_validaservicoimediato
      if l_ctx34g02_validaservicoimediato = 'SIM' then
          let lr_ret.cota_disponivel = true
      else
          let lr_ret.cota_disponivel = false
      end if

   else # AcionamentoWeb desligado
      
      call cts40g00_obter_parametro(lr_param.atdsrvorg)
           returning m_parametros.*
      
      #verificar se cidade e' atendida por GPS
      let l_gpsacngrpcod     = null
      
      call cts41g03_tipo_acion_cidade(lr_param.cidnom,
                                      lr_param.ufdcod,
                                      m_parametros.atmacnprtcod,
                                      lr_param.atdsrvorg)
           returning l_resultado, l_mensagem, l_gpsacngrpcod, lr_ret.mpacidcod
      
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
      else
      
	      call cts51g00_cidade_sem_GPS(lr_ret.mpacidcod, lr_param.atdsrvorg,
	                                      mr_servicos.socntzcod, lr_param.data,
	                                      lr_param.hora)
	              returning l_pergunta, lr_ret.cota_disponivel
      end if
   end if
   
   ##let lr_ret.imdsrvflg = 'N'

   # PSI-2013-00440PR nao utilizado no agendamento AW
   if m_agendaw = false
      then
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

   end if
   
   return lr_ret.cota_disponivel


end function

#---------------------------------
# Recupera coordenadas do endereco
#---------------------------------
function ctx32g00_geocodificar_endereco(l_geocodigo)

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
function ctx32g00_alteracao(param)
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

	prepare ctx32g00001 from l_sql
	declare cctx32g00001 cursor for ctx32g00001

	open cctx32g00001 using param.atdsrvnum, param.atdsrvano
	whenever error continue
	  	fetch cctx32g00001 into ws.atdfnlflg,
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
function ctx32g00_retorno(param)

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

	prepare ctx32g00002 from l_sql
	declare cctx32g00002 cursor for ctx32g00002

	open cctx32g00002 using param.atdsrvnum, param.atdsrvano
	whenever error continue
	  	fetch cctx32g00002 into ws.atdfnlflg,
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
function ctx32g00_regulador(param)
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
	
	define l_rsrchv     char(25) # Chave de reserva
        ,l_natureza   like datmsrvre.socntzcod
	      ,l_asitipcod  like datmservico.asitipcod
        ,l_ciaempcod  like datmservico.ciaempcod
        ,l_endindtpo  like datmlcl.c24lclpdrcod
        ,l_endltt     like datmlcl.lclltt
        ,l_endlgt     like datmlcl.lcllgt
        ,l_espcod     like datmsrvre.espcod
        ,l_data_char  char(10)  # Data (texto)
        ,l_srvhordat  char(19)  # Data e hora do servico
        ,l_num_reg    int
        ,l_lista_horarios   char (30000)
        ,l_agncotdatant date
        ,l_agncothorant datetime hour to second

	initialize ws.* to null
	let l_mensagem = null
	let l_mensagemCod = null
	let l_ret = null
	let l_cotflg = null
	let ws.atdsrvorg = 9

  let m_agendaw = false

  select grlinf into m_agendaw
  from datkgeral
  where grlchv = 'PSOAGENDAWATIVA'

	select socntzgrpcod into ws.srvrglcod
   	  from datksocntz where socntzcod = (select socntzcod from datmsrvre
  					    where atdsrvnum = param.atdsrvnum
					      and atdsrvano = param.atdsrvano)

  if ws.srvrglcod = 1 then #LINHA BRANCA
     let l_natureza = 12 # GELADEIRA
  else
  	 let l_natureza = 1 # HIDRAULICA
  end if
   
	select cidnom, ufdcod
	into ws.cidnom, ws.ufdcod
	from datmlcl
	where atdsrvnum = param.atdsrvnum
	  and atdsrvano = param.atdsrvano

  if m_agendaw = false then   # regulacao antiga   ##00


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
	else
		
	      # 17/03/2016 - informacoes para AgendaW ativa para bdatm002
        let l_endindtpo = 0
	      let l_endltt    = 0
	      let l_endlgt    = 0
	      let l_ciaempcod = 1  # Porto
        let l_espcod    = 0
        let l_asitipcod = 0
        let l_data_char = param.novaData

        let l_srvhordat = l_data_char[7,10] clipped
                                           ,"-" clipped
                                           ,l_data_char[4,5] clipped
                                           ,"-" clipped
                                           ,l_data_char[1,2] clipped
                                           ,"T" clipped
                                           ,param.novaHora clipped
                                           ,":00" clipped
                                           
     call cts02m08_obtem_agenda(l_srvhordat,
                                ws.cidnom,
                                ws.ufdcod,
                                "",
                                "",
                                "",
                                "N",
                                l_endindtpo,
                                l_endltt,
                                l_endlgt,
                                l_ciaempcod,
                                9, # atdsrvorg
                                l_asitipcod,
                                l_natureza,
                                l_espcod)
          returning l_num_reg, l_lista_horarios, l_rsrchv

     if l_num_reg = 1 then
     	
       call ctd41g00_baixar_agenda(l_rsrchv
                                 , param.atdsrvano
                                 , param.atdsrvnum)
            returning l_mensagemCod, l_mensagem

       # so libera a anterior se baixou a nova
       if l_mensagemCod = 0
          then
          call cts02m08_upd_cota(l_rsrchv, "", g_documento.atdsrvnum
                               , g_documento.atdsrvano)

          initialize l_agncotdatant, l_agncothorant to null
	        select atddatprg, atdhorprg
	        into l_agncotdatant, l_agncothorant
	        from datmservico
	        where atdsrvnum = param.atdsrvnum
	          and atdsrvano = param.atdsrvano
	          and atddatprg is not null
	  
          if l_agncotdatant is not null then
             call ctd41g00_liberar_agenda(g_documento.atdsrvano
                                         ,g_documento.atdsrvnum
                                         ,l_agncotdatant
                                         ,l_agncothorant)
          end if
          
       end if
    end if
  end if 

	return l_mensagemCod, l_mensagem

end function

function ctx32g00_buscaCoordenadas(l_logtip,
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

	call ctx32g00_geocodificar_endereco(l_geocodigo.*)
		returning l_geocodigo.*

	if l_geocodigo.logcod is not null or
	   l_geocodigo.brrcod is not null   then
		let l_c24lclpdrcod = 3
	else
		let l_c24lclpdrcod = 1
	end if

     return l_geocodigo.lcllgt, l_geocodigo.lclltt, l_c24lclpdrcod

end function