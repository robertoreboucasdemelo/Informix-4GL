#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Central 24h                                                     #
# Modulo...: cts58g00                                                        #
# Objetivo.: Processo de alteracao do endereco de ocorrencia ou destino      #
#            de um servico                                                   #
# Analista.: Ligia Mattge                                                    #
# PSI      :                                                                 #
# Liberacao: 09/2011                                                         #
#............................................................................#
# Observacoes                                                                #
# Alteracoes                                                                 #
#----------------------------------------------------------------------------#
database porto

globals '/homedsa/projetos/geral/globals/glct.4gl'

#----------------------------------------------------------------
function cts58g00(l_servico, l_ocorrencia, l_destino)
#----------------------------------------------------------------

define l_servico     record
       atdsrvnum   like datmservico.atdsrvnum,
       atdsrvano   like datmservico.atdsrvano,
       atdsrvorg   like datmservico.atdsrvorg,
       assunto     like datkassunto.c24astcod,
       asitipcod   like datmservico.asitipcod,
       prslocflg   like datmservico.prslocflg,
       frmflg      char(1),
       vclcoddig   like datmservico.vclcoddig,
       camflg      char(1),
       val_oco     smallint, #0-não valida end.ocorrencia, 1-Valida end.ocorrencia
       val_dst     smallint  #0-não valida end.destino, 1-Valida end.destino
  end record

  define l_ocorrencia record
         lclidttxt     like datmlcl.lclidttxt      ,
         lgdtip        like datmlcl.lgdtip         ,
         lgdnom        like datmlcl.lgdnom         ,
         lgdnum        like datmlcl.lgdnum         ,
         lclbrrnom     like datmlcl.lclbrrnom      , # sub-bairro, vem da roteirizacao
         brrnom        like datmlcl.brrnom         ,
         cidnom        like datmlcl.cidnom         ,
         ufdcod        like datmlcl.ufdcod         ,
         lclrefptotxt  like datmlcl.lclrefptotxt   ,
         endzon        like datmlcl.endzon         ,
         lgdcep        like datmlcl.lgdcep         ,
         lgdcepcmp     like datmlcl.lgdcepcmp      ,   
         lclltt        like datmlcl.lclltt         ,   # NN
         lcllgt        like datmlcl.lcllgt         ,   # NN
         dddcod        like datmlcl.dddcod         ,
         lcltelnum     like datmlcl.lcltelnum      ,
         lclcttnom     like datmlcl.lclcttnom      ,
         c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
         ofnnumdig     decimal(6,0)                ,
         emeviacod     like datmemeviadpt.emeviacod
  end record
     
  define l_destino record
         lclidttxt     like datmlcl.lclidttxt      ,
         lgdtip        like datmlcl.lgdtip         ,
         lgdnom        like datmlcl.lgdnom         ,
         lgdnum        like datmlcl.lgdnum         ,
         lclbrrnom     like datmlcl.lclbrrnom      ,  # sub-bairro, vem da roteirizacao
         brrnom        like datmlcl.brrnom         ,
         cidnom        like datmlcl.cidnom         ,
         ufdcod        like datmlcl.ufdcod         ,
         lclrefptotxt  like datmlcl.lclrefptotxt   ,
         endzon        like datmlcl.endzon         ,
         lgdcep        like datmlcl.lgdcep         ,
         lgdcepcmp     like datmlcl.lgdcepcmp      ,
         lclltt        like datmlcl.lclltt         ,   # NN
         lcllgt        like datmlcl.lcllgt         ,   # NN
         dddcod        like datmlcl.dddcod         ,
         lcltelnum     like datmlcl.lcltelnum      ,
         lclcttnom     like datmlcl.lclcttnom      ,
         c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
         ofnnumdig     decimal(6,0)                ,
         emeviacod     like datmemeviadpt.emeviacod
  end record
 
  define l_ctx25g01  record
           ufdcod       like datkmpacid.ufdcod ,
           cidnom       like datkmpacid.cidnom ,
           brrnom       like datkmpabrr.brrnom ,
           lgdnom       like datkmpalgd.lgdnom ,
           lgdtip       like datkmpalgd.lgdtip ,
           numero       integer                ,
           status_ret   smallint
  end record
  
  define l_cts58g00    record
         atdhorpvt   like datmservico.atdhorpvt ,
         cidcod      like gcakfilial.cidcod     ,
         cidsedcod   like datrcidsed.cidsedcod  ,
         atdprvtmp   like datracncid.atdprvtmp  ,
         sqlcode     integer                    ,
         errmsg      char(80)
  end record

  define l_cts40g00 record
         resultado     smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acess
         mensagem      char(100),
         acnlmttmp     like datkatmacnprt.acnlmttmp,
         acntntlmtqtd  like datkatmacnprt.acntntlmtqtd,
         netacnflg     like datkatmacnprt.netacnflg,
         atmacnprtcod  like datkatmacnprt.atmacnprtcod
  end record
  
  define l_rota    char(80),
         l_errmsg  char(120),
         l_tmp     char(80),
         l_atdfnlflg like datmservico.atdfnlflg
    
#----------------------------------------------------------------
  # revisa enderecos ocorrencia e destino, faz geocode reverso quando nao houver,
  # grava locais de ocorrencia e destino

  initialize l_ctx25g01.*, l_cts58g00.*, l_cts40g00.* to null
  
  let l_errmsg = null
  let l_rota = null
  let l_cts58g00.sqlcode = 0
  
  if l_servico.val_oco = true then 

	  let l_ocorrencia.lgdtip = upshift(l_ocorrencia.lgdtip)
	  let l_ocorrencia.lgdnom = upshift(l_ocorrencia.lgdnom)
	  let l_ocorrencia.brrnom = upshift(l_ocorrencia.brrnom)
	  let l_ocorrencia.cidnom = upshift(l_ocorrencia.cidnom)
	  let l_ocorrencia.ufdcod = upshift(l_ocorrencia.ufdcod)

	  let l_rota = 'Ocorrencia roteirizada pelo FRONT-END'

	  # verifica existencia da cidade/UF enviado pelo front-end
	  if l_ocorrencia.lgdnom is not null and
	     l_ocorrencia.lgdnum is not null and
	     l_ocorrencia.cidnom is not null and
	     l_ocorrencia.ufdcod is not null
	     then
	     call cts55g00_ver_cidufd(l_ocorrencia.cidnom, l_ocorrencia.ufdcod)
		  returning l_ocorrencia.cidnom, l_ocorrencia.ufdcod

	     display 'cts55g00_ver_cidufd: ', l_ocorrencia.cidnom clipped, ' / ', l_ocorrencia.ufdcod
	  end if

	  # se nao houver endereco, busca no Informix
	  if l_ocorrencia.lgdnom is null or
	     l_ocorrencia.lgdnum is null or
	     l_ocorrencia.cidnom is null or
	     l_ocorrencia.ufdcod is null
	     then
	     whenever error continue
	     call ctn44c02_endereco(l_ocorrencia.lclltt, l_ocorrencia.lcllgt)
		  returning l_ocorrencia.ufdcod,
			    l_ocorrencia.cidnom,
			    l_ocorrencia.lgdtip,
			    l_ocorrencia.lgdnom,
			    l_ocorrencia.brrnom,
			    l_ocorrencia.lgdnum
	     whenever error stop
	     let l_rota = 'Ocorrencia roteirizada pelo INFORMIX'
	  end if

	  # se nao houver endereco, busca no CRGISJAVA01R
	  if l_ocorrencia.lgdnom is null or
	     l_ocorrencia.lgdnum is null or
	     l_ocorrencia.cidnom is null or
	     l_ocorrencia.ufdcod is null
	     then
	     whenever error continue
	     if ctx25g05_rota_ativa()
		then
		call ctx25g01_endereco(l_ocorrencia.lclltt, l_ocorrencia.lcllgt, '1')
		     returning l_ctx25g01.status_ret,
			       l_ocorrencia.ufdcod,
			       l_ocorrencia.cidnom,
			       l_ocorrencia.lgdtip,
			       l_ocorrencia.lgdnom,
			       l_ocorrencia.brrnom,
			       l_ocorrencia.lgdnum
	     end if
	     whenever error stop
	     let l_rota = 'Ocorrencia roteirizada pelo CRGISJAVA01R'
	  end if

	  display l_rota clipped

	  # se nao houver dados suficientes para o local de ocorrencia, aborta
	  if l_ocorrencia.lgdnom is null or
	     l_ocorrencia.lgdnum is null or
	     l_ocorrencia.cidnom is null or
	     l_ocorrencia.ufdcod is null
	     then
	     let l_errmsg = 'Erro 01: Dados para atualizacao do local ocorrencia nao localizados'

	     let l_cts58g00.sqlcode = 999

	     display l_errmsg clipped
	     display 'l_ocorrencia.lgdip: ', l_ocorrencia.lgdtip
	     display 'l_ocorrencia.lgdnom: ', l_ocorrencia.lgdnom clipped
	     display 'l_ocorrencia.lgdnum: ', l_ocorrencia.lgdnum
	     display 'l_ocorrencia.brrnom: ', l_ocorrencia.brrnom
	     display 'l_ocorrencia.cidnom: ', l_ocorrencia.cidnom
	     display 'l_ocorrencia.ufdcod: ', l_ocorrencia.ufdcod

	     return l_cts58g00.sqlcode, l_errmsg
	  else
	     # local sem bairro definido, nao achou no front-end nem no CRGISJAVA01R
	     if l_ocorrencia.brrnom is null
		then
		let l_ocorrencia.brrnom = 'NAO LOCALIZADO'
	     end if
	  end if

	  begin work

	  # atualiza o local de ocorrencia
	  whenever error continue
	  call cts06g07_local("M"                      ,
			      l_servico.atdsrvnum     ,
			      l_servico.atdsrvano     ,
			      1                        ,
			      l_ocorrencia.lclidttxt   ,
			      l_ocorrencia.lgdtip      ,
			      l_ocorrencia.lgdnom      ,
			      l_ocorrencia.lgdnum      ,
			      l_ocorrencia.lclbrrnom   ,
			      l_ocorrencia.brrnom      ,
			      l_ocorrencia.cidnom      ,
			      l_ocorrencia.ufdcod      ,
			      l_ocorrencia.lclrefptotxt,
			      l_ocorrencia.endzon      ,
			      l_ocorrencia.lgdcep      ,
			      l_ocorrencia.lgdcepcmp   ,
			      l_ocorrencia.lclltt      ,
			      l_ocorrencia.lcllgt      ,
			      l_ocorrencia.dddcod      ,
			      l_ocorrencia.lcltelnum   ,
			      l_ocorrencia.lclcttnom   ,
			      l_ocorrencia.c24lclpdrcod,
			      l_ocorrencia.ofnnumdig   ,
			      l_ocorrencia.emeviacod   ,
			      '', '', '')
		    returning l_cts58g00.sqlcode
	  whenever error stop

	  display 'cts06g07_local(1): ', l_cts58g00.sqlcode

	  if l_cts58g00.sqlcode != 0
	     then
	     let l_errmsg = 'Erro 02: SQL ', l_cts58g00.sqlcode, ' | Tabela datmlcl(1)'
	     rollback work
	     display l_errmsg clipped
	     return l_cts58g00.sqlcode, l_errmsg
	  end if

          commit work
  
  end if

  if l_servico.val_dst = true then

	  # atualiza o local de destino 

	     let l_destino.lgdtip = upshift(l_destino.lgdtip)
	     let l_destino.lgdnom = upshift(l_destino.lgdnom)
	     let l_destino.brrnom = upshift(l_destino.brrnom)
	     let l_destino.cidnom = upshift(l_destino.cidnom)
	     let l_destino.ufdcod = upshift(l_destino.ufdcod)

	     if l_destino.lgdnom is not null and
		l_destino.lgdnum is not null and
		l_destino.cidnom is not null and
		l_destino.ufdcod is not null
		then
		call cts55g00_ver_cidufd(l_destino.cidnom, l_destino.ufdcod)
		     returning l_destino.cidnom, l_destino.ufdcod

		let l_errmsg = 'Destino roteirizado pelo FRONT-END'
	     end if

	     if l_destino.lgdnom is null or
		l_destino.lgdnum is null or
		l_destino.cidnom is null or
		l_destino.ufdcod is null 
		then
		whenever error continue
		call ctn44c02_endereco(l_destino.lclltt, l_destino.lcllgt)
		     returning l_destino.ufdcod,
			       l_destino.cidnom,
			       l_destino.lgdtip,
			       l_destino.lgdnom,
			       l_destino.brrnom,
			       l_destino.lgdnum
		whenever error stop
		let l_errmsg = 'Destino roteirizado pelo INFORMIX'
	     end if

	     if l_destino.lgdnom is null or
		l_destino.lgdnum is null or
		l_destino.cidnom is null or
		l_destino.ufdcod is null   
		then
		whenever error continue
		if ctx25g05_rota_ativa()
		   then
		   call ctx25g01_endereco(l_destino.lclltt, l_destino.lcllgt, '1')
			returning l_ctx25g01.status_ret,
				  l_destino.ufdcod,
				  l_destino.cidnom,
				  l_destino.lgdtip,
				  l_destino.lgdnom,
				  l_destino.brrnom,
				  l_destino.lgdnum

	        end if
		whenever error stop
		let l_errmsg = 'Destino roteirizado pelo CRGISJAVA01R'
	     end if

	     display l_errmsg clipped

	     # se nao houver dados suficientes para o local de destino, aborta
	     if l_destino.lgdnom is null or
		l_destino.lgdnum is null or
		l_destino.cidnom is null or
		l_destino.ufdcod is null
		then
		let l_errmsg = 'Erro 03: Dados para atualizacao do local destino nao localizados'
		let l_cts58g00.sqlcode = 999

		display l_errmsg clipped
		display 'l_destino.lgdtip: ', l_destino.lgdtip
		display 'l_destino.lgdnom: ', l_destino.lgdnom
		display 'l_destino.lgdnum: ', l_destino.lgdnum
		display 'l_destino.brrnom: ', l_destino.brrnom
		display 'l_destino.cidnom: ', l_destino.cidnom
		display 'l_destino.ufdcod: ', l_destino.ufdcod

		return l_cts58g00.sqlcode, l_errmsg
	     else
		# local sem bairro definido, nao achou no front-end nem no CRGISJAVA01R
		if l_destino.brrnom is null
		   then
		   let l_destino.brrnom = 'NAO LOCALIZADO'
		end if
	     end if

             begin work

	     # atualiza o local de destino
	     whenever error continue
	     call cts06g07_local("M"                   ,
				 l_servico.atdsrvnum  ,
				 l_servico.atdsrvano  ,
				 2                     ,
				 l_destino.lclidttxt   ,
				 l_destino.lgdtip      ,
				 l_destino.lgdnom      ,
				 l_destino.lgdnum      ,
				 l_destino.lclbrrnom   ,
				 l_destino.brrnom      ,
				 l_destino.cidnom      ,
				 l_destino.ufdcod      ,
				 l_destino.lclrefptotxt,
				 l_destino.endzon      ,
				 l_destino.lgdcep      ,
				 l_destino.lgdcepcmp   ,
				 l_destino.lclltt      ,
				 l_destino.lcllgt      ,
				 l_destino.dddcod      ,
				 l_destino.lcltelnum   ,
				 l_destino.lclcttnom   ,
				 l_destino.c24lclpdrcod,
				 l_destino.ofnnumdig   ,
				 l_destino.emeviacod   ,
				 '', '', '')
		       returning l_cts58g00.sqlcode
	     whenever error stop

	     display 'cts06g07_local(2): ', l_cts58g00.sqlcode

	     if l_cts58g00.sqlcode != 0
		then
		let l_errmsg = 'Erro 04: SQL ', l_cts58g00.sqlcode, ' | Tabela datmlcl(2)'
		rollback work
		display l_errmsg clipped
		return l_cts58g00.sqlcode, l_errmsg
	     end if

             commit work
  
  end if
   
  if l_servico.val_oco = true then
  
	  #----------------------------------------------------------------
	  # verifica se servico e internet ou gps e se esta ativo

	  whenever error continue
	  if cts34g00_acion_auto(l_servico.atdsrvorg , l_ocorrencia.cidnom ,
				 l_ocorrencia.ufdcod )
	     then
	     # funcao cts34g00_acion_auto verificou que parametrizacao para origem
	     # do servico esta ok
	     # chamar funcao para validar regras gerais se um servico sera acionado
	     # automaticamente ou nao e atualizar datmservico

	     if cts40g12_regras_aciona_auto(l_servico.atdsrvorg ,
					    l_servico.assunto ,
					    l_servico.asitipcod ,
					    l_ocorrencia.lclltt ,
					    l_ocorrencia.lcllgt ,
					    l_servico.prslocflg ,
					    l_servico.frmflg    ,
					    l_servico.atdsrvnum,
					    l_servico.atdsrvano,
					    " "                 ,
					    l_servico.vclcoddig ,
					    l_servico.camflg)
		then
		let l_atdfnlflg = 'A'
	     else
		let l_atdfnlflg = 'N'
	     end if
	  end if
	  whenever error stop

	  display 'cts40g12_regras_aciona_auto: ', l_atdfnlflg

	  #----------------------------------------------------------------
	  # previsao de atendimento
	  whenever error continue
	  call cts40g00_obter_parametro(l_servico.atdsrvorg)
	       returning l_cts40g00.resultado,
			 l_cts40g00.mensagem,
			 l_cts40g00.acnlmttmp,
			 l_cts40g00.acntntlmtqtd,
			 l_cts40g00.netacnflg,
			 l_cts40g00.atmacnprtcod
	  whenever error stop

	  display 'cts40g00_obter_parametro: ', l_cts40g00.atmacnprtcod

	  whenever error continue
	  call cty10g00_obter_cidcod(l_ocorrencia.cidnom,
				     l_ocorrencia.ufdcod)
	       returning l_cts58g00.sqlcode, 
			 l_cts58g00.errmsg,
			 l_cts58g00.cidcod
	  whenever error stop

	  display 'cty10g00_obter_cidcod: ', l_cts58g00.sqlcode, ' ', l_cts58g00.cidcod

	  whenever error continue
	  if l_cts40g00.atmacnprtcod is not null and 
	     l_cts40g00.atmacnprtcod != 0 and
	     l_cts58g00.cidcod is not null and
	     l_cts58g00.cidcod != 0
	     then
	     call ctd01g00_obter_cidsedcod(1, l_cts58g00.cidcod)
		  returning l_cts58g00.sqlcode,
			    l_cts58g00.errmsg,
			    l_cts58g00.cidsedcod

	     display 'ctd01g00_obter_cidsedcod: ', l_cts58g00.sqlcode, " | ",
		     l_cts58g00.errmsg clipped, l_cts58g00.cidsedcod

	     if l_cts58g00.cidsedcod is not null
		then
		call cts32g00_dados_cid_ac(1, l_cts40g00.atmacnprtcod,
					   l_cts58g00.cidsedcod)
		     returning l_cts58g00.sqlcode,
			       l_cts58g00.errmsg,
			       l_cts58g00.atdprvtmp

		display 'cts32g00_dados_cid_ac: ', l_cts58g00.sqlcode, " | ",
			l_cts58g00.errmsg clipped, l_cts58g00.atdprvtmp

		if l_cts58g00.atdprvtmp is not null
		   then
		   let l_tmp = l_cts58g00.atdprvtmp
		   let l_cts58g00.atdhorpvt = l_tmp
		   initialize l_tmp to null
		   let l_tmp = 'Regra previsao: buscou do cadastro ', l_cts58g00.atdhorpvt
		   display l_tmp
		else
		   # definido com o cliente 18/01/10, 30 min para cidades grande
		   # Sao Paulo e 60 min para as demais cidades
		   if l_cts58g00.cidsedcod = 9668
		      then
		      let l_cts58g00.atdhorpvt = '00:30'
		      let l_tmp = 'Regra previsao: cidade sede SP 30 min'
		      display l_tmp
		   else
		      let l_cts58g00.atdhorpvt = '00:60'
		      let l_tmp = 'Regra previsao: cidade sede fora SP 60 min'
		      display l_tmp
		   end if
		end if
	     else
		let l_cts58g00.atdhorpvt = '00:60'
		let l_tmp = 'Regra previsao: sem cidade sede 60 min'
		display l_tmp
	     end if
	  else
	     let l_cts58g00.atdhorpvt = '00:60'
	     let l_tmp = 'Regra previsao: sem cidade sede e sem cadastro 60 min'
	     display l_tmp
	  end if

	  display 'l_cts58g00.atdhorpvt: ', l_cts58g00.atdhorpvt

	  update datmservico set atdhorpvt = l_cts58g00.atdhorpvt
		 where atdsrvnum = l_servico.atdsrvnum
		   and atdsrvano = l_servico.atdsrvano

	  let l_cts58g00.sqlcode = sqlca.sqlcode

	  if l_cts58g00.sqlcode != 0
	       then
	       let l_errmsg = 'Erro 05: SQL ', l_cts58g00.sqlcode, ' | Tabela datmlcl(1)'
	       display l_errmsg clipped
	       return l_cts58g00.sqlcode, l_errmsg
	  end if

  end if
   
  return l_cts58g00.sqlcode, l_errmsg
  
end function
