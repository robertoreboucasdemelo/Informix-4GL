###############################################################################
# Nome do Modulo: BDBSR020                                        Marcelo     #
#                                                                 Gilberto    #
# Baixa de adiantamentos a prestadores - Porto Socorro            Nov/1997    #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
# 27/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 21/08/2006 Cristiane Silva   PSI197858  Descontos da OP. Enviar por e-mail  #
#					  o relatorio.			      #
#-----------------------------------------------------------------------------#
# 26/12/2006 Priscila Staingel  PSI205206 separar OP´s por empresa            #
###############################################################################

database porto

define ws_traco     char(145)
define ws_data      char(010)
define ws_cctcod    like igbrrelcct.cctcod
define ws_relviaqtd like igbrrelcct.relviaqtd
define m_path       char(100)

main

   call fun_dba_abre_banco("CT24HS")


   # PSI 185035 - Inicio
   let m_path = f_path("DBS","LOG")
   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped,"/bdbsr020.log"
   call startlog(m_path)
   # PSI 185035 - Final

   call bdbsr020()
end main

#--------------------------------------------------------------------
 function bdbsr020()
#--------------------------------------------------------------------
 define d_bdbsr020    record
    socopgnum         like dbsmopg.socopgnum,
    pstcoddig         like dbsmopg.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    cgccpf            char (20),
    socfatpgtdat      like dbsmopg.socfatpgtdat,
    socfattotvlr      like dbsmopg.socfattotvlr,
    ciaempcodOP       like datmservico.ciaempcod    #PSI 205206
 end record

 define ws            record
    sql               char (500),
    cgccpfnum         like dbsmopg.cgccpfnum,
    cgcord            like dbsmopg.cgcord,
    cgccpfdig         like dbsmopg.cgccpfdig,
    soctip            like dbsmopg.soctip,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02	      char(60),
    dsctipcod	      like dbsropgdsc.dsctipcod,
    dscvlr	      like dbsropgdsc.dscvlr,
    dscvlrobs	      like dbsropgdsc.dscvlrobs,
    retorno	      smallint,
    descop	      like dbsmopg.socopgdscvlr
 end record

 define l_assunto char(100)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize d_bdbsr020.*  to null
 initialize ws.*          to null

 let ws_traco  = "------------------------------------------------------------------------------------------------------------------------------------------------"

#---------------------------------------------------------------
# Define data parametro
#---------------------------------------------------------------
 let ws_data = arg_val(1)

 if ws_data is null  or
    ws_data =  "  "  then
    call ctr07g00_data() returning ws_data
 else
    if length(ws_data) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program(1)
    end if
 end if

#--------------------------------------------------------------------
# Definicao dos comandos SQL
#--------------------------------------------------------------------
 let ws.sql = "select nomrazsoc     ",
              "  from dpaksocor     ",
              " where pstcoddig = ? "
 prepare select_dpaksocor from ws.sql
 declare c_dpaksocor cursor for select_dpaksocor

 let ws.sql = "select socopgfavnom  ",
              "  from dbsmopgfav    ",
              " where socopgnum = ? "
 prepare select_dbsmopgfav from ws.sql
 declare c_dbsmopgfav cursor for select_dbsmopgfav

#PSI197858 - inicio
 let ws.sql = "select dsctipcod, dscvlr, dscvlrobs from dbsropgdsc ",
              " where socopgnum = ? ",
              " and dsctipcod is not null ",
              " and dsctipcod > 0 "
 prepare select_desconto from ws.sql
 declare c_desconto cursor for select_desconto

 let ws.sql = " Select sum(dscvlr) from dbsropgdsc ",
 		" where socopgnum = ? "
 prepare select_soma from ws.sql
 declare c_soma cursor for select_soma

 let ws.sql = " select socopgdscvlr from dbsmopg where socopgnum= ? "
 prepare select_descop from ws.sql
 declare c_descop cursor for select_descop
#PSI197858 - fim

 #PSI 205206 - buscar empresa dos servicos da OP
 let ws.sql = "select b.ciaempcod "
            ," from dbsmopgitm a, datmservico b "
            ," where a.socopgnum = ? "
            ,"   and a.atdsrvnum = b.atdsrvnum "
            ,"   and a.atdsrvano = b.atdsrvano "
 prepare select_empOP from ws.sql
 declare c_empOP cursor for select_empOP

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS02001"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS02001.xls"



 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS02001")
      returning  ws_cctcod,
		 ws_relviaqtd


#--------------------------------------------------------------------
# Verifica as ordens de pagamento que foram concedidos adiantamentos
#--------------------------------------------------------------------
 declare  c_bdbsr020  cursor for

select opg.socopgnum,
           opg.pstcoddig,
           opg.cgccpfnum,
           opg.cgcord,
           opg.cgccpfdig,
           opg.socfatpgtdat,
           opg.socfattotvlr,
           opg.soctip
      from dbsmopg opg
     where opg.socfatpgtdat  =  ws_data
       and opg.socopgsitcod  =  7

 start report  rep_acerto  to  ws.pathrel01

 start report  rep_acertoxls  to  ws.pathrel02

 foreach c_bdbsr020  into  d_bdbsr020.socopgnum,
                           d_bdbsr020.pstcoddig,
                           ws.cgccpfnum,
                           ws.cgcord,
                           ws.cgccpfdig,
                           d_bdbsr020.socfatpgtdat,
                           d_bdbsr020.socfattotvlr,
                           ws.soctip

     if ws.cgcord is not null  then
        let d_bdbsr020.cgccpf = ws.cgccpfnum using "############", "/", ws.cgcord using "&&&&"
     else
        let d_bdbsr020.cgccpf = ws.cgccpfnum using "#################"
     end if

     let d_bdbsr020.cgccpf = d_bdbsr020.cgccpf clipped, "-", ws.cgccpfdig using "&&"

     #--------------------------------------------------------------------
     # Razao social do prestador
     #--------------------------------------------------------------------
     if ws.soctip = 2 then  #carro-extra
        initialize d_bdbsr020.nomrazsoc to null
     else
        open  c_dpaksocor  using d_bdbsr020.pstcoddig
        fetch c_dpaksocor  into  d_bdbsr020.nomrazsoc
        close c_dpaksocor
     end if

     #--------------------------------------------------------------------
     # Favorecido da ordem de pagamento
     #--------------------------------------------------------------------
     open  c_dbsmopgfav using d_bdbsr020.socopgnum
     fetch c_dbsmopgfav into  d_bdbsr020.socopgfavnom
     close c_dbsmopgfav

     #PSI197858 - inicio
     let ws.dsctipcod = null

     open c_desconto using d_bdbsr020.socopgnum
     foreach c_desconto into ws.dsctipcod, ws.dscvlr, ws.dscvlrobs
     end foreach
     close c_desconto
     #PSI197858 - fim

     if ws.dsctipcod is null or ws.dsctipcod = 0 or ws.dsctipcod = notfound then

	     open c_descop using d_bdbsr020.socopgnum
	     fetch c_descop into ws.descop
	     close c_descop


	     if ws.descop is null or ws.descop = 0.00 then
     		initialize d_bdbsr020.* to null
     		initialize ws.dsctipcod to null
     		initialize ws.dscvlr to null
     		initialize ws.dscvlrobs to null
     		continue foreach
     	     end if
     end if

     #PSI 205206 - verificar se OP é Porto ou Azul
     # estou buscando apenas o 1º item da OP, pq todos os itens da OP
     # devem ter a mesma empresa
     open c_empOP using d_bdbsr020.socopgnum
     foreach c_empOP into d_bdbsr020.ciaempcodOP
     end foreach
     close c_empOP

     if ws.dsctipcod is null or ws.dsctipcod = 0 then
	if ws.dscvlr is null or ws.dscvlr = 0.00 then
           if ws.descop is not null and ws.descop > 0.00 then
              output to report rep_acerto(d_bdbsr020.*, ws.cgccpfnum,
                                          ws.cgcord, ws.cgccpfdig,
                   	                  ws.dsctipcod, ws.descop, ws.dscvlrobs)
           end if
	end if
     else
	if ws.dscvlr is not null and ws.dscvlr > 0.00 then
           output to report rep_acerto(d_bdbsr020.*, ws.cgccpfnum,
                                       ws.cgcord, ws.cgccpfdig,
                                       ws.dsctipcod, ws.dscvlr, ws.dscvlrobs)
        end if
     end if
     #PSI197858 - inicio
     output to report rep_acertoxls(d_bdbsr020.*, ws.cgccpfnum,
                           ws.cgcord, ws.cgccpfdig,
                           ws.dsctipcod, ws.dscvlr, ws.dscvlrobs)
     #PSI197858 - fim
 end foreach

 finish report  rep_acerto
 #PSI197858 - inicio
 finish report rep_acertoxls

 let l_assunto = "Baixa de Adiantamentos a Prestadores - Porto Socorro  em ", ws_data
 call ctx22g00_envia_email("BDBSR020", l_assunto, ws.pathrel02)
 returning ws.retorno
 if ws.retorno <> 0 then
 	error "Erro no envio de email"
 else
 	error "Envio com sucesso"
 end if

#PSI197858 - fim

end function  ###  bdbsr020

#---------------------------------------------------------------------------
 report rep_acerto(r_bdbsr020)
#---------------------------------------------------------------------------

 define r_bdbsr020    record
    socopgnum         like dbsmopg.socopgnum,
    pstcoddig         like dbsmopg.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    cgccpf            char (20),
    socfatpgtdat      like dbsmopg.socfatpgtdat,
    socfattotvlr      like dbsmopg.socfattotvlr,
    ciaempcodOP       like datmservico.ciaempcod,    #PSI 205206
    cgccpfnum         like dbsmopg.cgccpfnum,
    cgcord            like dbsmopg.cgcord,
    cgccpfdig         like dbsmopg.cgccpfdig,
    dsctipcod	      like dbsropgdsc.dsctipcod,
    dscvlr	      decimal(15,5),
    dscvlrobs	      like dbsropgdsc.dscvlrobs
 end record

 define ws            record
    fimflg            smallint,
    descricao	      like dbsktipdsc.dsctipdes,
    soma	      decimal(08,02),
    adiantamento      char(25)
 end record

 define l_ret       smallint,
        l_mensagem  char(50),
        l_nomeEmp   like gabkemp.empsgl

   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr020.ciaempcodOP,     #PSI 205206
             r_bdbsr020.socfatpgtdat,
             r_bdbsr020.socopgnum


   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS02001 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - BAIXAS DE ADIANTAMENTOS A PRESTADORES"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)

              let ws.fimflg = false
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           #PSI 205206 - imprimir o nome da empresa na primeira linha de cada pagina
           call cty14g00_empresa(1, r_bdbsr020.ciaempcodOP)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print column 050, "EMPRESA: ", l_nomeEmp,   #PSI 205206
                 column 113, "RDBS020-01",
                 column 127, "PAGINA: ", pageno using "##,###,###"
           print column 127, "DATA  : ", today
           print column 029, "BAIXA DE ADIANTAMENTOS A PRESTADORES - PORTO SOCORRO  EM ", ws_data,
                 column 127, "HORA  :   ", time
           skip 2 lines

           print column 001, ws_traco

           print column 001, "ORDEM PAGTO",
                 column 014, "CODIGO",
                 column 022, "FAVORECIDO / PRESTADOR",
                 column 077, "CGC/CPF",
                 column 086, "DATA PAGTO",
#                 column 101, "VALOR PAGTO",
		column 124,  "OBS";
	   skip 1 lines
	        print column 001, ws_traco;
           skip 2 lines

     #PSI 205206 - quebrar página qdo mudar empresa
     before group of r_bdbsr020.ciaempcodOP
           skip to top of page

     after  group of r_bdbsr020.socopgnum
           open c_soma using r_bdbsr020.socopgnum
           fetch c_soma into ws.soma
           close c_soma

	   if ws.soma is null or ws.soma = 0 then
	   	let ws.soma = 0.00
	   end if

	   if r_bdbsr020.dsctipcod is not null and r_bdbsr020.dsctipcod > 0.00 then
           	open c_desconto using r_bdbsr020.socopgnum
           	foreach c_desconto into r_bdbsr020.dsctipcod, r_bdbsr020.dscvlr, r_bdbsr020.dscvlrobs

		let ws.adiantamento = null

		if r_bdbsr020.dscvlrobs is not null then
			let ws.adiantamento = r_bdbsr020.dscvlrobs
		else
			let ws.adiantamento = "..............."
		end if

		if ws.adiantamento is null or ws.adiantamento = "" then
			let ws.adiantamento = "..............."
		end if

           	select dsctipdes into ws.descricao
           	from dbsktipdsc
           	where dsctipcod = r_bdbsr020.dsctipcod

     	        print column 002, "DESCONTO........:", ws.descricao;
     	        print column 020, "VALOR DESCONTO..:", r_bdbsr020.dscvlr using "---,---,--&.&&";
	        print column 124, ws.adiantamento ;

                skip 1 line
	   	end foreach
	   	close c_desconto
	end if



	   print column 001, ws_traco;
	   skip 1 line
           print column 005, "VALOR BRUTO.....:", r_bdbsr020.socfattotvlr using "---,---,--&.&&";
           if ws.soma is not null and ws.soma > 0.00 then
	   	print column 053, "TOTAL DE DESCONTOS....:", ws.soma using "---,---,--&.&&";
	      	print column 095, "VALOR TOTAL DA OP....:", r_bdbsr020.socfattotvlr - ws.soma using "---,---,--&.&&";
	   else
	   	print column 053, "TOTAL DE DESCONTOS....:", r_bdbsr020.dscvlr using "---,---,--&.&&";
	   	print column 095, "VALOR TOTAL DA OP....:", r_bdbsr020.socfattotvlr - r_bdbsr020.dscvlr using "---,---,--&.&&";
	   end if
#	   skip 1 line
#	   print column 001, ws_traco;

	   skip 3 lines
      on every row
           print column 002, r_bdbsr020.socopgnum    using "&&&&&&&&&&"    ,
                 column 014, r_bdbsr020.pstcoddig    using "&&&&&&"        ,
                 column 022, r_bdbsr020.socopgfavnom                       ,
                 column 064, r_bdbsr020.cgccpf                             ,
                 column 086, r_bdbsr020.socfatpgtdat using "yyyy-mm-dd"    ;
#                 column 098, r_bdbsr020.socfattotvlr using "---,---,--&.&&";

		skip 1 line

      page trailer
           print column 007, "------------------------------------------",
                 column 053, "------------------------------------------",
                 column 098, "------------------------------------------"
           print column 007, "      PORTO SOCORRO  (DATA/ASSINATURA)    ",
                 column 053, "        FINANCEIRO (DATA/ASSINATURA)      ",
                 column 098, "      CONTABILIDADE  (DATA/ASSINATURA)    "

           if ws.fimflg = true  then
              print "$FIMREL$"
           else
              skip 1 line
           end if

      on last row
           let ws.fimflg = true

end report  ###  rep_acerto


#---------------------------------------------------------------------------
 report rep_acertoxls(r_bdbsr020)
#---------------------------------------------------------------------------

 define r_bdbsr020    record
    socopgnum         like dbsmopg.socopgnum,
    pstcoddig         like dbsmopg.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    cgccpf            char (20),
    socfatpgtdat      like dbsmopg.socfatpgtdat,
    socfattotvlr      like dbsmopg.socfattotvlr,
    ciaempcodOP       like datmservico.ciaempcod,    #PSI 205206
    cgccpfnum         like dbsmopg.cgccpfnum,
    cgcord            like dbsmopg.cgcord,
    cgccpfdig         like dbsmopg.cgccpfdig,
    dsctipcod	      like dbsropgdsc.dsctipcod,
    dscvlr	      like dbsropgdsc.dscvlr,
    dscvlrobs	      like dbsropgdsc.dscvlrobs
 end record

 define ws            record
    fimflg            smallint,
    descricao	      like dbsktipdsc.dsctipdes,
    soma	      decimal(08,02),
    adiantamento      char(25)
 end record

 define l_ret       smallint,
        l_mensagem  char(50),
        l_nomeEmp   like gabkemp.empsgl

   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr020.ciaempcodOP,     #PSI 205206
             r_bdbsr020.socopgnum


   format
      #PSI 205206 - vai exibir a cada quebra de grupo por empresa
      #first page header
      #      print "ORDEM PAGTO",				ASCII(09),
      #            "CODIGO",					ASCII(09),
      #            "FAVORECIDO / PRESTADOR",			ASCII(09),
      #            "CGC/CPF",				ASCII(09),
      #            "DATA PAGTO",				ASCII(09),
      #            "VALOR PAGTO",				ASCII(09),
      #            "DESCONTO",		 		ASCII(09),
      #            "VALOR DESCONTO",				ASCII(09),
      #            "VALOR TOTAL DA OP",			ASCII(09),
      #            "TOTAL DE DESCONTOS",			ASCII(09),
      #            "No.ADIANTAMENTO",			ASCII(09);
      #      skip 1 line
	            
      #PSI 205206 - quebrar página qdo mudar empresa	            
      before group of r_bdbsr020.ciaempcodOP    
           skip to top of page

           #busca nome da empresa
           call cty14g00_empresa(1, r_bdbsr020.ciaempcodOP)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print "EMPRESA: ", l_nomeEmp     
	   print "ORDEM PAGTO",			ASCII(09),
                 "CODIGO",			ASCII(09),
                 "FAVORECIDO / PRESTADOR",	ASCII(09),
                 "CGC/CPF",			ASCII(09),
                 "DATA PAGTO",			ASCII(09),
                 "VALOR PAGTO",			ASCII(09),
                 "DESCONTO",		 	ASCII(09),
     	         "VALOR DESCONTO",		ASCII(09),
     	         "VALOR TOTAL DA OP",		ASCII(09),
     	         "TOTAL DE DESCONTOS",		ASCII(09),
	         "No.ADIANTAMENTO",		ASCII(09);
	   skip 1 line            
            	            
	            
      on every row

		open c_soma using r_bdbsr020.socopgnum
           	fetch c_soma into ws.soma
           	close c_soma

	   	if ws.soma is null or ws.soma = 0 then
	   		let ws.soma = 0.00
	   		print r_bdbsr020.socopgnum    using "&&&&&&&&&&",	ASCII(09),
                 	r_bdbsr020.pstcoddig    using "&&&&&&"        	,	ASCII(09),
                 	r_bdbsr020.socopgfavnom                       	,	ASCII(09),
                 	r_bdbsr020.cgccpf                             	,	ASCII(09),
                 	r_bdbsr020.socfatpgtdat  using "yyyy-mm-dd"    	,	ASCII(09),
                 	r_bdbsr020.socfattotvlr 		       	,	ASCII(09),
           		" "						, 	ASCII(09),
           		" "						, 	ASCII(09),
           		r_bdbsr020.socfattotvlr - ws.soma		,	ASCII(09),
           		ws.soma						,	ASCII(09),
           		"..............."				,	ASCII(09);

           		skip 1 line
	   	else
           		open c_desconto using r_bdbsr020.socopgnum
           		foreach c_desconto into r_bdbsr020.dsctipcod, r_bdbsr020.dscvlr, r_bdbsr020.dscvlrobs
				let ws.adiantamento = null

				if r_bdbsr020.dscvlrobs is not null then
					let ws.adiantamento = r_bdbsr020.dscvlrobs
				else
					let ws.adiantamento = "..............."
				end if

				if ws.adiantamento is null or ws.adiantamento = "" then
					let ws.adiantamento = "..............."
				end if

           			select dsctipdes into ws.descricao
           			from dbsktipdsc
           			where dsctipcod = r_bdbsr020.dsctipcod

				print r_bdbsr020.socopgnum    using "&&&&&&&&&&",	ASCII(09),
                 		r_bdbsr020.pstcoddig    using "&&&&&&"        	,	ASCII(09),
                 		r_bdbsr020.socopgfavnom                       	,	ASCII(09),
                 		r_bdbsr020.cgccpf                             	,	ASCII(09),
                 		r_bdbsr020.socfatpgtdat using "yyyy-mm-dd"	,	ASCII(09),
                 		r_bdbsr020.socfattotvlr 		       	,	ASCII(09),
           			ws.descricao					, 	ASCII(09),
           			r_bdbsr020.dscvlr				, 	ASCII(09),
           			r_bdbsr020.socfattotvlr - ws.soma		,	ASCII(09),
           			ws.soma						,	ASCII(09),
           			ws.adiantamento					,	ASCII(09);

			skip 1 line
 			end foreach
			close c_desconto
		end if
		skip 1 line

end report  ###  rep_acertoxls
