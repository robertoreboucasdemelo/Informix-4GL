#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR500                                                   #
# ANALISTA RESP..: CRISTIANE SILVA                                            #
# PSI/OSF........: 207209                                                     #
#                  TRIBUTACAO SERVICOS PORTO SOCORRO - AZUL SEGUROS           #
# ........................................................................... #
# DESENVOLVIMENTO: CRISTIANE SILVA                                            #
# LIBERACAO......: 21/06/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"

	define mr_relat record
			    ciaempcod    like datmservico.ciaempcod,
			    empcod       like dbsmopg.empcod,
			    empnom       like gabkemp.empnom,
			    socfatpgtda  like dbsmopg.socfatpgtdat,
			    socfatentda  like dbsmopg.socfatentdat,
			    socemsnfsda  like dbsmopg.socemsnfsdat,
			    pstcoddig    like dpaksocor.pstcoddig,
			    nomrazsoc    like dpaksocor.nomrazsoc,
			    insinccod    like cgpkprestn.insinccod,
			    prstip       like cgpkprestn.prstip,
			    prstipdes    like cgckprest.prstipdes,
			    pestip       like dbsmopg.pestip,
			    cgccpfnum    like dpaksocor.cgccpfnum,
			    cgcord       like dpaksocor.cgcord,
			    cgccpfdig    like dpaksocor.cgccpfdig,
			    cgccpfnumcmp char(40),
			    socopgnum  	 like dbsmopg.socopgnum,
			    socfattotvl  decimal(8,2),
			    soctrbbasvl  decimal(8,2),
			    socirfvlr    decimal(8,2),
			    socissvlr    decimal(8,2),
			    insretvlr    decimal(8,2),
			    pisretvlr    decimal(8,2),
			    cofretvlr    decimal(8,2),
			    cslretvlr    decimal(8,2),
			    soctottrb    decimal(8,2), #Total de tributos
			    soctotliq    decimal(8,2)  #Total Liquido
			end record

	define m_path     char(1000),
	       m_path2    char(1000),
	       m_lidos    integer,
	       l_data1    char(10),
	       l_data2    char(10),
	       l_data3    char(10),
	       m_data_ini date,
               m_data_fim date,
               l_data_atual date,
               l_hora_atual datetime hour to minute,
               m_mes_int smallint


main

	initialize mr_relat.*,
	           m_path,
	           m_path2,
	           m_lidos,
	           m_data_ini,
	           m_data_fim,
	           l_data_atual,
                   l_hora_atual  to null

	 # ---> OBTER A DATA E HORA DO BANCO
         call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual


         #if  month(l_data_atual) = 01 then
        	#let m_data_ini = mdy(12,01,year(l_data_atual) - 1)
        	#let m_data_fim    = mdy(12,31,year(l_data_atual) - 1)
    	 #else
        	##let m_data_ini = mdy(month(l_data_atual),01,year(l_data_atual))
        	#let m_data_ini = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
        	#let m_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
        	##let m_data_fim = l_data_atual
         #end if

         # PARAMETRIZADO PARA EXECUÇÃO NO ULTIMO DIA DO MES
         let m_data_fim =  l_data_atual
         let m_data_ini = ((l_data_atual + 1 units day) - 1 units month)- 10 units year

    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(m_data_ini)


	call fun_dba_abre_banco("CT24HS")
	call bdbsr500_busca_path()
	call cts40g03_exibe_info("I","BDBSR500")

    	call bdbsr500_prepare()

    	call bdbsr500_busca_dados()

    	display " "
    	display "QTD.REGISTROS LIDOS......: ", m_lidos       using "<<<<<<<<&"
    	display " "

   	call cts40g03_exibe_info("F","BDBSR500")

end main

#---------------------------#
 function bdbsr500_prepare()
#---------------------------#

	define l_sql   char(5000)

	create temp table t_temp (pstcoddig decimal(6,0) not null) with no log
	create unique index idx_bdbsr500 on t_temp (pstcoddig)

	let l_sql =  " select distinct srv.ciaempcod, ",
	                    " opg.empcod, ",
                            " opg.socfatpgtdat, ",
                            " opg.socfatentdat, ",
                            " opg.socemsnfsdat, ",
                            " socor.pstcoddig, ",
                            " socor.nomrazsoc, ",
                            " opg.pestip, ",
                            " socor.cgccpfnum || '/' || socor.cgcord || '-' || socor.cgccpfdig, ",
                            " socor.cgccpfnum, ",
                            " socor.cgcord, ",
                            " socor.cgccpfdig, ",
                            " opg.socopgnum, ",
                            " opg.socfattotvlr, ",
                            " trb.soctrbbasvlr, ",
                            " trb.socirfvlr, ",
                            " trb.socissvlr, ",
                            " trb.insretvlr, ",
                            " trb.pisretvlr, ",
                            " trb.cofretvlr, ",
                            " trb.cslretvlr, ",
                            " (trb.socirfvlr+ ",
                     		" trb.socissvlr+ ",
                     		" trb.insretvlr+ ",
                     		" trb.pisretvlr+ ",
                     		" trb.cofretvlr+ ",
                     		" trb.cslretvlr), ",
                           " opg.socfattotvlr -(trb.socirfvlr+ ",
                     			      " trb.socissvlr+ ",
                     			      " trb.insretvlr+ ",
                     			      " trb.pisretvlr+ ",
                     			      " trb.cofretvlr+ ",
                     			      " trb.cslretvlr) ",
                      " from   dbsmopg opg, ",
                           "    dpaksocor socor, ",
                           "    dbsmopgtrb trb, ",
                     	   "    dbsmopgitm itm, ",
                     	   "    datmservico srv ",
                     " where opg.socfatpgtdat between ? and ? ",
                       " and opg.socopgsitcod = 7 ",
                       " and opg.soctip = 1 ",
                       " and opg.pstcoddig = socor.pstcoddig ",
                       " and opg.socopgnum = trb.socopgnum ",
                       " and itm.socopgnum = opg.socopgnum ",
                       " and srv.atdsrvnum = itm.atdsrvnum ",
                       " and srv.atdsrvano = itm.atdsrvano ",
                       " and srv.ciaempcod = 35 ",
                       " and (trb.socissvlr > 0 ",
                        " or trb.insretvlr > 0 ",
                        " or trb.pisretvlr > 0 ",
                        " or trb.cofretvlr > 0 ",
                        " or trb.cslretvlr > 0)",
                     " order by 6,3 "



 	prepare pbdbsr500_01 from l_sql
	declare cbdbsr500_01 cursor for pbdbsr500_01

	let l_sql = " select prestn.insinccod, ",
                           " prestn.prstip, ",
                           " prest.prstipdes ",
                      " from CGPKPRESTN prestn, ",
                           " CGCKPREST prest ",
                     " where prestn.prstip    = prest.prstip ",
                       " and prestn.cgccpfnum = ? ",
                       " and prestn.cgcord    = ? ",
                       " and prestn.empcod    = ? "


 	prepare pbdbsr500_02 from l_sql
	declare cbdbsr500_02 cursor for pbdbsr500_02

	let l_sql = " select cgccpfnum || '-' ||cgccpfdig ",
                      " from    dbsmopg ",
                     " where socopgnum = ? "

 	prepare pbdbsr500_03 from l_sql
	declare cbdbsr500_03 cursor for pbdbsr500_03

	let l_sql = " select empsgl ",
                      " from    gabkemp ",
                     " where empcod = ? "

 	prepare pbdbsr500_04 from l_sql
	declare cbdbsr500_04 cursor for pbdbsr500_04

	let l_sql =  " select distinct srv.ciaempcod, ",
			    " opg.empcod, ",
                            " opg.socfatpgtdat, ",
                            " opg.socfatentdat, ",
                            " opg.socemsnfsdat, ",
                            " socor.pstcoddig, ",
                            " socor.nomrazsoc, ",
                            " opg.pestip, ",
                            " socor.cgccpfnum || '/' || socor.cgcord || '-' || socor.cgccpfdig, ",
                            " socor.cgccpfnum, ",
                            " socor.cgcord, ",
                            " socor.cgccpfdig, ",
                            " opg.socopgnum, ",
                            " opg.socfattotvlr, ",
                            " trb.soctrbbasvlr, ",
                            " trb.socirfvlr, ",
                            " trb.socissvlr, ",
                            " trb.insretvlr, ",
                            " trb.pisretvlr, ",
                            " trb.cofretvlr, ",
                            " trb.cslretvlr, ",
                            " (trb.socirfvlr+ ",
                     		" trb.socissvlr+ ",
                     		" trb.insretvlr+ ",
                     		" trb.pisretvlr+ ",
                     		" trb.cofretvlr+ ",
                     		" trb.cslretvlr), ",
                           " opg.socfattotvlr -(trb.socirfvlr+ ",
                     			      " trb.socissvlr+ ",
                     			      " trb.insretvlr+ ",
                     			      " trb.pisretvlr+ ",
                     			      " trb.cofretvlr+ ",
                     			      " trb.cslretvlr) ",
                      " from    dbsmopg opg, ",
                           "    dpaksocor socor, ",
                     " outer    dbsmopgtrb trb, ",
                     	   "    dbsmopgitm itm, ",
                     	   "    datmservico srv, ",
                     	   " t_temp tmp",
                     " where opg.socfatpgtdat between ? and ? ",
                       " and opg.socopgsitcod = 7 ",
                       " and opg.soctip = 1 ",
                       " and opg.pstcoddig = socor.pstcoddig ",
                       " and opg.socopgnum = trb.socopgnum ",
                       " and itm.socopgnum = opg.socopgnum ",
                       " and srv.atdsrvnum = itm.atdsrvnum ",
                       " and srv.atdsrvano = itm.atdsrvano ",
                       " and opg.pstcoddig = tmp.pstcoddig "



 	prepare pbdbsr500_05 from l_sql
	declare cbdbsr500_05 cursor for pbdbsr500_05

	let l_sql = "insert into t_temp values (?)"

 	prepare pbdbsr500_06 from l_sql
 end function

#-----------------------------#
 function bdbsr500_busca_path()
#-----------------------------#

  	let m_path = null
        let m_path2 = null
  	let m_path = f_path("DBS","LOG")

  	if  m_path is null then
   	   let m_path = "."
 	end if

  	let m_path2 = m_path

  	## ---> Cria o primeiro relatorio (Todos os tributos)
 	let m_path = m_path clipped,"/bdbsr500.log"
  	call startlog(m_path)

  	let m_path = f_path("DBS", "RELATO")

 	 if  m_path is null then
   	   let m_path = "."
 	 end if

 	 let m_path = m_path clipped, "/bdbsr5001.xls"

 	# # ---> Cria o segundo relatorio (Somente tributados)
 	 let m_path2 = m_path2 clipped,"/bdbsr5002.log"
 	 call startlog(m_path2)

 	 let m_path2 = f_path("DBS", "RELATO")

 	 if  m_path2 is null then
  	    let m_path2 = "."
 	 end if
        let m_path2 = m_path2 clipped, "/bdbsr5002.xls"

 end function


#------------------------------#
 function bdbsr500_busca_dados()
#------------------------------#


	 display "data ", m_data_ini

	open cbdbsr500_01 using m_data_ini,
	                        m_data_fim
	fetch cbdbsr500_01 into mr_relat.ciaempcod,
				mr_relat.empcod,
	                        mr_relat.socfatpgtda,
	                        mr_relat.socfatentda,
	                        mr_relat.socemsnfsda,
	                        mr_relat.pstcoddig,
	                        mr_relat.nomrazsoc,
	                        mr_relat.pestip,
	                        mr_relat.cgccpfnumcmp,
	                        mr_relat.cgccpfnum,
	                        mr_relat.cgcord,
	                        mr_relat.cgccpfdig,
	                        mr_relat.socopgnum,
	                        mr_relat.socfattotvl,
	                        mr_relat.soctrbbasvl,
	                        mr_relat.socirfvlr,
	                        mr_relat.socissvlr,
	                        mr_relat.insretvlr,
	                        mr_relat.pisretvlr,
	                        mr_relat.cofretvlr,
	                        mr_relat.cslretvlr,
	                        mr_relat.soctottrb,
	                        mr_relat.soctotliq

	case sqlca.sqlcode

		when notfound
	    	     error 'Argumentos de pesquisa nao encontrado.'

	    	when 0

	    	     start report rep_bdbsr500_1 to m_path
	    	     start report rep_bdbsr500_2 to m_path2

	    	     let m_lidos = 0

	    	     foreach cbdbsr500_01 into   mr_relat.ciaempcod,
						 mr_relat.empcod,
	    	                                 mr_relat.socfatpgtda,
	    	                                 mr_relat.socfatentda,
	    	                                 mr_relat.socemsnfsda,
	    	                                 mr_relat.pstcoddig,
	    	                                 mr_relat.nomrazsoc,
	    	                                 mr_relat.pestip,
	    	                                 mr_relat.cgccpfnumcmp,
	    	                                 mr_relat.cgccpfnum,
	                                         mr_relat.cgcord,
	                                         mr_relat.cgccpfdig,
	    	                                 mr_relat.socopgnum,
	    	                                 mr_relat.socfattotvl,
	    	                                 mr_relat.soctrbbasvl,
	    	                                 mr_relat.socirfvlr,
	    	                                 mr_relat.socissvlr,
	    	                                 mr_relat.insretvlr,
	    	                                 mr_relat.pisretvlr,
	    	                                 mr_relat.cofretvlr,
	    	                                 mr_relat.cslretvlr,
	    	                                 mr_relat.soctottrb,
	    	                                 mr_relat.soctotliq


	    	         whenever error continue
	    	         execute pbdbsr500_06 using mr_relat.pstcoddig

	    	         whenever error stop



	    	         if  sqlca.sqlcode <> 0 and sqlca.sqlcode <> -239 then
	    	             error 'Problema na carga de temporaria: ', sqlca.sqlcode
	    	             exit program
	    	         end if

	    	         let m_lidos = m_lidos + 1

	    	         call bdbsr500_validacoes()

	    	         output to report rep_bdbsr500_1()

	    	     end foreach

                     open cbdbsr500_05 using m_data_ini,
	    	                             m_data_fim

	    	     fetch cbdbsr500_05 into mr_relat.ciaempcod,
					     mr_relat.empcod,
	    	                             mr_relat.socfatpgtda,
	    	                             mr_relat.socfatentda,
	    	                             mr_relat.socemsnfsda,
	    	                             mr_relat.pstcoddig,
	    	                             mr_relat.nomrazsoc,
	    	                             mr_relat.pestip,
	    	                             mr_relat.cgccpfnumcmp,
	    	                             mr_relat.cgccpfnum,
	                                     mr_relat.cgcord,
	                                     mr_relat.cgccpfdig,
	    	                             mr_relat.socopgnum,
	    	                             mr_relat.socfattotvl,
	    	                             mr_relat.soctrbbasvl,
	    	                             mr_relat.socirfvlr,
	    	                             mr_relat.socissvlr,
	    	                             mr_relat.insretvlr,
	    	                             mr_relat.pisretvlr,
	    	                             mr_relat.cofretvlr,
	    	                             mr_relat.cslretvlr,
	    	                             mr_relat.soctottrb,
	    	                             mr_relat.soctotliq

	    	     if  sqlca.sqlcode = 0 then

	    	         foreach cbdbsr500_05 into mr_relat.ciaempcod,
	    	                         	   mr_relat.empcod,
	    	                         	   mr_relat.socfatpgtda,
	    	                         	   mr_relat.socfatentda,
	    	                         	   mr_relat.socemsnfsda,
	    	                         	   mr_relat.pstcoddig,
	    	                         	   mr_relat.nomrazsoc,
	    	                         	   mr_relat.pestip,
	    	                         	   mr_relat.cgccpfnumcmp,
	    	                         	   mr_relat.cgccpfnum,
	                                           mr_relat.cgcord,
	                                           mr_relat.cgccpfdig,
  	    	                         	   mr_relat.socopgnum,
	    	                         	   mr_relat.socfattotvl,
	    	                         	   mr_relat.soctrbbasvl,
	    	                         	   mr_relat.socirfvlr,
	    	                         	   mr_relat.socissvlr,
	    	                         	   mr_relat.insretvlr,
	    	                         	   mr_relat.pisretvlr,
	    	                         	   mr_relat.cofretvlr,
	    	                         	   mr_relat.cslretvlr,
	    	                         	   mr_relat.soctottrb,
	    	                         	   mr_relat.soctotliq

	    	      		call bdbsr500_validacoes()

	    	      		output to report rep_bdbsr500_2()

	    	         end foreach
	    	     end if

	    	     finish report rep_bdbsr500_1
	    	     finish report rep_bdbsr500_2

	    	     call bdbsr500_envia_email()

	    	otherwise
	    	     error 'ERRO: ', sqlca.sqlcode
	end case

 end function

#------------------------------#
 function bdbsr500_validacoes()
#------------------------------#

	define l_aux char(10)

	initialize l_aux to  null

	if  mr_relat.cgcord is null or
	    mr_relat.cgcord = ' ' then
	    let mr_relat.cgcord = 0
	end if

	open cbdbsr500_02 using mr_relat.cgccpfnum,
	                        mr_relat.cgcord,
	                        mr_relat.empcod
	fetch cbdbsr500_02 into mr_relat.insinccod,
	                        mr_relat.prstip,
	                        mr_relat.prstipdes

	let l_data1 = extend(mr_relat.socfatpgtda, year to year ),'-',
	              extend(mr_relat.socfatpgtda, month to month),'-',
	              extend(mr_relat.socfatpgtda, day to day)

	let l_data2 = extend(mr_relat.socfatentda, year to year),'-',
	              extend(mr_relat.socfatentda, month to month),'-',
	              extend(mr_relat.socfatentda, day to day)

	let l_data3 = extend(mr_relat.socemsnfsda, year to year),'-',
	              extend(mr_relat.socemsnfsda, month to month),'-',
	              extend(mr_relat.socemsnfsda, day to day)

	if  mr_relat.pestip = 'F' then

	    open cbdbsr500_03 using mr_relat.socopgnum
	    fetch cbdbsr500_03 into mr_relat.cgccpfnumcmp

	end if

	open cbdbsr500_04 using mr_relat.ciaempcod
	fetch cbdbsr500_04 into mr_relat.empnom

	if  mr_relat.soctrbbasvl is null or
	    mr_relat.soctrbbasvl = ' ' then
	    let mr_relat.soctrbbasvl = 0
	end if

	if  mr_relat.socirfvlr is null or
	    mr_relat.socirfvlr = ' ' then
	    let mr_relat.socirfvlr = 0
	end if

	if  mr_relat.soctottrb is null or
	    mr_relat.soctottrb = ' ' then
	    let mr_relat.soctottrb = 0
	end if


	if  mr_relat.soctotliq is null or
	    mr_relat.soctotliq = ' ' then
	    let mr_relat.soctotliq = mr_relat.socfattotvl
	end if

	if  mr_relat.socissvlr is null or
	    mr_relat.socissvlr = ' ' then
	    let mr_relat.socissvlr = 0
	end if

	if  mr_relat.insretvlr is null or
	    mr_relat.insretvlr = ' ' then
	    let mr_relat.insretvlr = 0
	end if

	if  mr_relat.pisretvlr is null or
	    mr_relat.pisretvlr = ' ' then
	    let mr_relat.pisretvlr = 0
	end if

	if  mr_relat.cofretvlr is null or
	    mr_relat.cofretvlr = ' ' then
	    let mr_relat.cofretvlr = 0
	end if

	if  mr_relat.cslretvlr is null or
	    mr_relat.cslretvlr = ' ' then
	    let mr_relat.cslretvlr = 0
	end if

 end function

#-------------------------------#
function bdbsr500_valor(l_valor)
#-------------------------------#

  define l_valor     decimal(12,2),
         l_retorno   char(10),
         l_ix1       smallint

  if l_valor is null then
     let l_valor = 0
  end if

  let l_retorno = l_valor using "###,##&.&&"

  for l_ix1 = 1 to 10
      if l_retorno[l_ix1] = "." then
         let l_retorno[l_ix1] = ","
      else
         if l_retorno[l_ix1] = "," then
            let l_retorno[l_ix1] = "."
         end if
      end if
  end for

  return l_retorno

end function

#-------------------------------#
 function bdbsr500_envia_email()
#-------------------------------#

	define 	l_assunto     char(100),
		l_erro_envio  integer,
         	l_comando     char(200),
         	l_anexo       char(1000)

  	# ---> INICIALIZACAO DAS VARIAVEIS

  	let l_comando    = null
	let l_erro_envio = null
  	let l_assunto    = "Relatório OPs pagas no periodo de ", m_data_ini ," à ", m_data_fim ,"."

  	# ---> COMPACTA O ARQUIVO DO RELATORIO
  	let l_comando = "gzip -f ", m_path
  	run l_comando

  	# ---> COMPACTA O ARQUIVO DO RELATORIO
  	let l_comando = "gzip -f ", m_path2
  	run l_comando

  	let m_path  = m_path clipped, ".gz"
  	let m_path2 = m_path2 clipped, ".gz"

  	let l_anexo =  m_path clipped, ',', m_path2

  	let l_erro_envio = ctx22g00_envia_email("BDBSR500", l_assunto, l_anexo)

  	if l_erro_envio <> 0 then
     		if l_erro_envio <> 99 then
        		display "Erro ao enviar email(ctx22g00) - ", l_anexo
     		else
        		display "Nao existe email cadastrado para o modulo - BDBSR107"
     		end if
  	end if

 end function

#-----------------------#
 report rep_bdbsr500_1()
#-----------------------#

	output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

	format

	    first page header

	        print "RELATORIO DE TRIBUTOS  - SOMENTE OPS PAGAS - AZUL SEGUROS"

	        print ""

	        print "EMPRESA",         	ASCII(09),
	              "NOME EMPRESA",    	ASCII(09),
	              "DT. PAGAMENTO",   	ASCII(09),
	              "DT. PROTOCOLO",   	ASCII(09),
	              "DT. NOTA",        	ASCII(09),
	              "COD. PRESTADOR",  	ASCII(09),
	              "NOME PRESTAFDOR", 	ASCII(09),
	              "NIT/PIS",  		ASCII(09),
	              "COD. ATIVIDADE",		ASCII(09),
	              "TIPO PESSOA",		ASCII(09),
	              "CNPJ",			ASCII(09),
	              "NR. OP.",		ASCII(09),
	              "VLR. PAGO",		ASCII(09),
	              "VALOR BASE",		ASCII(09),
	              "IR",			ASCII(09),
	              "ISS",			ASCII(09),
	              "INSS",			ASCII(09),
	              "PIS",			ASCII(09),
	              "COFINS",			ASCII(09),
	              "CSLL",			ASCII(09),
	              "TOTAL TRIBUTOS",		ASCII(09),
	              "TOTAL LIQUIDO"

	    on every row

	        print mr_relat.ciaempcod,        ASCII(09),
	              mr_relat.empnom,           ASCII(09),
	              l_data1,                   ASCII(09),
	              l_data2,                   ASCII(09),
	              l_data3,                   ASCII(09),
	              mr_relat.pstcoddig,        ASCII(09),
	              mr_relat.nomrazsoc,        ASCII(09),
	              mr_relat.insinccod,        ASCII(09),
	              mr_relat.prstipdes,        ASCII(09),
	              mr_relat.pestip,           ASCII(09),
	              mr_relat.cgccpfnumcmp,     ASCII(09),
	              mr_relat.socopgnum,        ASCII(09),
			 #mr_relat.socfattotvl using "---------&,&&", ASCII(09),
			 #mr_relat.soctrbbasvl using "---------&,&&", ASCII(09),
			 #mr_relat.socirfvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.socissvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.insretvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.pisretvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.cofretvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.cslretvlr  using "---------&,&&", ASCII(09),
			 #mr_relat.soctottrb  using "---------&,&&", ASCII(09),
			 #mr_relat.soctotliq  using "---------&,&&"
		    bdbsr500_valor(mr_relat.socfattotvl) , ASCII(09),
		    bdbsr500_valor(mr_relat.soctrbbasvl) , ASCII(09),
		    bdbsr500_valor(mr_relat.socirfvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.socissvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.insretvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.pisretvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.cofretvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.cslretvlr), ASCII(09),
		    bdbsr500_valor(mr_relat.soctottrb), ASCII(09),
		    bdbsr500_valor(mr_relat.soctotliq)


 end report

#-----------------------#
 report rep_bdbsr500_2()
#-----------------------#

	output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

	format

	    first page header

	        print "RELATORIO DE TRIBUTOS - OPS PRESTADORES TRIBUTADOS"

	        print ""

	        print "EMPRESA",         	ASCII(09),
	              "NOME EMPRESA",    	ASCII(09),
	              "DT. PAGAMENTO",   	ASCII(09),
	              "DT. PROTOCOLO",   	ASCII(09),
	              "DT. NOTA",        	ASCII(09),
	              "COD. PRESTADOR",  	ASCII(09),
	              "NOME PRESTAFDOR", 	ASCII(09),
	              "NIT/PIS",  		ASCII(09),
	              "COD. ATIVIDADE",		ASCII(09),
	              "TIPO PESSOA",		ASCII(09),
	              "CNPJ",			ASCII(09),
	              "NR. OP.",		ASCII(09),
	              "VLR. PAGO",		ASCII(09),
	              "VALOR BASE",		ASCII(09),
	              "IR",			ASCII(09),
	              "ISS",			ASCII(09),
	              "INSS",			ASCII(09),
	              "PIS",			ASCII(09),
	              "COFINS",			ASCII(09),
	              "CSLL",			ASCII(09),
	              "TOTAL TRIBUTOS",		ASCII(09),
	              "TOTAL LIQUIDO"

	    on every row

	        print mr_relat.ciaempcod,    ASCII(09),
	              mr_relat.empnom,       ASCII(09),
	              l_data1,               ASCII(09),
	              l_data2,               ASCII(09),
	              l_data3,               ASCII(09),
	              mr_relat.pstcoddig,    ASCII(09),
	              mr_relat.nomrazsoc,    ASCII(09),
	              mr_relat.insinccod,    ASCII(09),
	              mr_relat.prstipdes,    ASCII(09),
	              mr_relat.pestip,       ASCII(09),
	              mr_relat.cgccpfnumcmp, ASCII(09),
	              mr_relat.socopgnum,    ASCII(09),
			#mr_relat.socfattotvl  using "---------&,&&", ASCII(09),
			#mr_relat.soctrbbasvl  using "---------&,&&", ASCII(09),
			#mr_relat.socirfvlr    using "---------&,&&", ASCII(09),
			#mr_relat.socissvlr    using "---------&,&&", ASCII(09),
			#mr_relat.insretvlr    using "---------&,&&", ASCII(09),
			#mr_relat.pisretvlr    using "---------&,&&", ASCII(09),
			#mr_relat.cofretvlr    using "---------&,&&", ASCII(09),
			#mr_relat.cslretvlr    using "---------&,&&", ASCII(09),
			#mr_relat.soctottrb    using "---------&,&&", ASCII(09),
			#mr_relat.soctotliq    using "---------&,&&"

			bdbsr500_valor(mr_relat.socfattotvl)  , ASCII(09),
			bdbsr500_valor(mr_relat.soctrbbasvl)  , ASCII(09),
			bdbsr500_valor(mr_relat.socirfvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.socissvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.insretvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.pisretvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.cofretvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.cslretvlr)    , ASCII(09),
			bdbsr500_valor(mr_relat.soctottrb)    , ASCII(09),
			bdbsr500_valor(mr_relat.soctotliq)
        end report
