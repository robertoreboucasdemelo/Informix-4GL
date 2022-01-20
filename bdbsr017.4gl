#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ...........................................................................  #
# SISTEMA........: PORTO SOCORRO                                               #
# MODULO.........: BDBSR017                                                    #
# ANALISTA RESP..: JORGE MODENA                                                #
# PSI/OSF........: RELATORIOS DE LIBERACAO AUTOMATICA DE ACERTO DE VALOR       #
#                  				                                                     #
# ...........................................................................  #
# DESENVOLVIMENTO: UESLEI OLIVEIRA                                             #
# LIBERACAO......: 22/11/2012                                                  #
# ...........................................................................  #
#                                                                              #
#                           * * * ALTERACOES * * *                             #
#                                                                              #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                              #
# --------   --------------  ---------- -------------------------------------  #
#									                                                             #
# 03/02/2016 ElianeK,Fornax               Retirada da var global g_ismqconn    #
#------------------------------------------------------------------------------#
#									                                                             #
#------------------------------------------------------------------------------#

database porto

define m_path   char(1000)

define mr_acerto       record
       cnldat          like datmservico.cnldat         ,  # Data ultimo acionamento
       atdfnlhor       like datmservico.atdfnlhor      ,  # Hora ultimo acionamento
       atdsrvnum       like datmservico.atdsrvnum      ,  # Numero do servico
       atdsrvano       like datmservico.atdsrvano      ,  # Ano do servico
       atdsrvorg       like datmservico.atdsrvorg      ,  # Origem do servico
       srvtipdes       like datksrvtip.srvtipdes       ,  # Descricao tipo servico - Origem
       asitipcod       like datkasitip.asitipcod       ,  # Assistencia do servico (quando houver)
       asitipdes       like datkasitip.asitipdes       ,  # Descricao tipo assistencia
       fnlvlr          like dbsmsrvacr.fnlvlr          ,  # Valor total do servico (saida + adicionais)
       prsinfdstcidnom like dbsmsrvacr.prsinfdstcidnom ,  # Cidade de destino informada no Portal
       prsinfdstestsgl like dbsmsrvacr.prsinfdstestsgl ,  # UF de destino informada no Portal
       socntzcod       like datksocntz.socntzcod       ,  # Natureza do serviço
       socntzdes       like datksocntz.socntzdes       ,  # Descricao da Natureza
       pstcoddig       like dpaksocor.pstcoddig        ,  # Codigo do prestador
       nomrazsoc       like dpaksocor.nomrazsoc        ,  # Nome fantasia do prestador
       tlrapcper       like dbsmrtrclcpam.tlrapcper    ,  # Percentual aplicacao tolerancia
       tlrqlmnum       like dbsmrtrclcpam.tlrqlmnum    ,  # Numero quilometragem tolerancia
       apvqlmnum       like dbsmrtrclcpam.apvqlmnum    ,  # Numero quilometragem aprovacao
       soccstcod       like dbsmsrvcst.soccstcod       ,  # Codigo custo porto socorro
       socadccstvlr    like dbsmsrvcst.socadccstvlr    ,  # Valor custo adicional
       socadccstqtd    like dbsmsrvcst.socadccstqtd    ,  # Quantidade custo adicional
       autokadat       like dbsmsrvacr.autokadat       ,  # Data aprovação automática
       autokahor       like dbsmsrvacr.autokahor          #
end record

define m_qtdPercurso   decimal(10,2) 		        # Quantidade de km percurso oficial
define m_qtdKExcedente decimal(10,2) 		        # Quantidade de km excedente cobrados
define m_vlrKExcedente decimal(10,2) 		        # Quantidade de km excedente cobrados
define m_cpodes        like datkdominio.cpodes          # Descricao
define m_contador      smallint
define m_cont          smallint
define m_codigosAdicionais char(40)
define m_valorKm       decimal(10,2)
define m_tlrqlmnum     like dbsmrtrclc.tlrqlmnum        # Quantidade de KM tolerancia

define mr_percurso     array [10] of record
       cldpcutipcod    like dbsmrtrpcu.cldpcutipcod     # Codigo tipo percurso calculado
       ,pcuseqnum      like dbsmrtrpcu.pcuseqnum        # Numero da sequencia do percurso
       ,inicidnom      like dbsmrtrpcu.inicidnom        # Nome da cidade inicio
       ,fimcidnom      like dbsmrtrpcu.fimcidnom        # Nome da cidade fim
       ,pcuqlmnum      like dbsmrtrpcu.pcuqlmnum        # Numero quilometragem percurso
       ,tlrqlmnum      like dbsmrtrclc.tlrqlmnum        # Numero quilometragem tolerancia
end record

define mr_custos       record
       soccstcod       like dbsmsrvcst.soccstcod        # Codigo custo socorrista
      ,socadccstvlr    like dbsmsrvcst.socadccstvlr     # Valor custo
      ,socadccstqtd    like dbsmsrvcst.socadccstqtd     # Quantidade custo adicionado
end record

main

   initialize mr_acerto
             ,mr_custos
             ,mr_percurso[10].*
             ,mr_acerto
             ,m_qtdPercurso
             ,m_qtdKExcedente
             ,m_vlrKExcedente
             ,m_cpodes
             ,m_contador
             ,m_cont
             ,m_codigosAdicionais
             ,m_valorKm
             ,m_path to null

   set isolation to dirty read

   call fun_dba_abre_banco("CT24HS")

   call cts40g03_exibe_info("I", "BDBSR017")

   call bdbsr017_prepare()

   display " LIBERACAO AUTOMATICA DE ACERTO DE VALOR : "

   call bdbsr017()

   call cts40g03_exibe_info("F", "BDBSR017")

end main

#------------------------#
 function bdbsr017_prepare()
#------------------------#

        define m_sql char(10000)

        let m_sql = " select datmservico.atdsrvnum,",
			   " datmservico.atdsrvano,",
			   " datmservico.atdsrvorg,",
			   " datmservico.asitipcod,",
			   " datmservico.cnldat   ,",
			   " datmservico.atdfnlhor,",
			   " datmsrvre.socntzcod,",
			   " dbsmsrvacr.fnlvlr,",
			   " dbsmsrvacr.prsinfdstcidnom,",
			   " dbsmsrvacr.prsinfdstestsgl,",
			   " dbsmrtrclcpam.tlrqlmnum,",
        		   " dbsmrtrclcpam.apvqlmnum,",
        		   " dbsmrtrclcpam.tlrapcper,",
        		   " dbsmsrvcst.soccstcod,",
                           " dbsmsrvcst.socadccstvlr,",
		           " dbsmsrvcst.socadccstqtd,",
		           " dpaksocor.pstcoddig,",
		           " dpaksocor.nomrazsoc, ",
		           "dbsmsrvacr.autokadat, ",
		            "dbsmsrvacr.autokahor ",
			" from dbsmsrvacr,",
			     " datmservico,",
			     " outer datmsrvre,",
			     " dbsmrtrclcpam,",
			     " dbsmsrvcst, ",
			     " dpaksocor ",
		      " where prsokaflg = 'S'",
			" and anlokaflg = 'S'",
			" and autokaflg = 'S'",
			" and datmservico.atdsrvnum = dbsmsrvacr.atdsrvnum",
			" and datmservico.atdsrvano = dbsmsrvacr.atdsrvano",
			" and datmsrvre.atdsrvnum = datmservico.atdsrvnum",
			" and datmsrvre.atdsrvano = datmservico.atdsrvano",
			" and dbsmrtrclcpam.atdsrvnum = datmservico.atdsrvnum",
			" and dbsmrtrclcpam.atdsrvano = datmservico.atdsrvano",
			" and dbsmsrvcst.atdsrvnum=datmservico.atdsrvnum",
			" and dbsmsrvcst.atdsrvano=datmservico.atdsrvano",
			" and dbsmsrvcst.soccstcod in (3,11)",
			" and dbsmsrvcst.socadccstvlr <> 0",
			" and dpaksocor.pstcoddig = dbsmsrvacr.pstcoddig",
			" and dbsmsrvacr.autokadat = today - 1 units day" #relatorio extrai informações do dia anterior

        prepare prelat_01 from m_sql
        declare crelat_01 cursor for prelat_01

        let m_sql = " select sum(cast(dbsmrtrpcu.pcuqlmnum as decimal(10,2))) as qtdPercurso",
      		       " from dbsmrtrclc,dbsmrtrpcu",
		     " where  dbsmrtrclc.atdsrvnum = ?",
		        " and dbsmrtrclc.atdsrvano = ?",
		        " and dbsmrtrpcu.atdsrvnum = dbsmrtrclc.atdsrvnum",
			" and dbsmrtrpcu.atdsrvano = dbsmrtrclc.atdsrvano",
			" and dbsmrtrpcu.cldpcutipcod = dbsmrtrclc.cldpcutipcod",
			" and dbsmrtrclc.ofcpcuflg = 'S'"

        prepare prelat_02 from m_sql
        declare crelat_02 cursor for prelat_02

        let m_sql = "select cpodes ",
                    " from iddkdominio",
                   " where cponom = 'rotcaltip'",
                    "   and cpocod = ?"

        prepare prelat_03 from m_sql
        declare crelat_03 cursor for prelat_03

        let m_sql = "select  dbsmrtrpcu.cldpcutipcod,",
		    	    " dbsmrtrpcu.pcuseqnum,",
		    	    " dbsmrtrpcu.inicidnom,",
		    	    " dbsmrtrpcu.fimcidnom,",
		    	    " dbsmrtrpcu.pcuqlmnum,",
		    	    " dbsmrtrclc.tlrqlmnum",
		       " from dbsmrtrclc,dbsmrtrpcu",
		      " where dbsmrtrclc.ofcpcuflg = 'S'",
		      	" and dbsmrtrclc.atdsrvnum = ? and dbsmrtrclc.atdsrvano = ?",
		      	" and dbsmrtrpcu.atdsrvnum = dbsmrtrclc.atdsrvnum",
			" and dbsmrtrpcu.atdsrvano = dbsmrtrclc.atdsrvano",
		        " and dbsmrtrpcu.cldpcutipcod = dbsmrtrclc.cldpcutipcod"

         prepare prelat_04 from m_sql
         declare crelat_04 cursor for prelat_04

    	 let m_sql = "select soccstcod,",
    	 	           " socadccstvlr,",
    	 	           " socadccstqtd ",
    	 	      " from dbsmsrvcst ",
    	 	     " where atdsrvnum=? ",
    	 	     "   and atdsrvano=?",
    	 	     "   and socadccstvlr <> 0"

    	 prepare prelat_05 from m_sql
         declare crelat_05 cursor for prelat_05


         let m_sql = "select tlrqlmnum",
    	 	      " from dbsmrtrclc ",
    	 	     " where atdsrvnum=? ",
    	 	     "   and atdsrvano=?",
    	 	     "   and ofcpcuflg = 'S'"

    	 prepare prelat_06 from m_sql
         declare crelat_06 cursor for prelat_06

 end function

#################################################################################
#-----------------------------------------#
 function bdbsr017()
#-----------------------------------------#

 call bdbsr017_busca_path("ACR")

 open crelat_01

 start report relat_lib_aut to m_path

 foreach crelat_01 into mr_acerto.atdsrvnum,
		       mr_acerto.atdsrvano,
		       mr_acerto.atdsrvorg,
		       mr_acerto.asitipcod,
		       mr_acerto.cnldat,
		       mr_acerto.atdfnlhor,
		       mr_acerto.socntzcod,
		       mr_acerto.fnlvlr,
		       mr_acerto.prsinfdstcidnom,
		       mr_acerto.prsinfdstestsgl,
		       mr_acerto.tlrqlmnum,
 		       mr_acerto.apvqlmnum,
 		       mr_acerto.tlrapcper,
 		       mr_acerto.soccstcod,
                       mr_acerto.socadccstvlr,
	               mr_acerto.socadccstqtd,
	               mr_acerto.pstcoddig,
	               mr_acerto.nomrazsoc,
	               mr_acerto.autokadat,
	               mr_acerto.autokahor

   output to report relat_lib_aut()
   initialize mr_acerto.* to null

  end foreach

  finish report relat_lib_aut

  call relat_envia_mail("ACR", m_path)

 end function

#---------------------#
report relat_lib_aut()
#---------------------#

 output
     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    07

 format

    first page header

        print column 45,"RELATORIO DE LIBERACOES AUTOMATICAS ACERTO DE VALOR."

        print "DATA APROVACAO AUTOMATICA"       , ascii(09),
              "HORA APROVACAO AUTOMATICA"       , ascii(09),
              "DATA/HORA ACIONAMENTO"           , ascii(09),
              "NUMERO SERVICO"                  , ascii(09),
              "QTDE DE KM PERCURSO OFICIAL"     , ascii(09),
              "PERCURSO OFICIAL + TOLERANCIA"   , ascii(09),
              "QTDE KM EXCEDENTES COBRADOS"     , ascii(09),
              "CODIGO ORIGEM"                   , ascii(09),
              "ORIGEM DO SERVICO"               , ascii(09),
              "TIPO DE PERCURSO OFICIAL"        , ascii(09),
              "CODIGO PRESTADOR"                , ascii(09),
              "NOME FANTASIA"                   , ascii(09),
              "CIDADE PONTO A"                  , ascii(09),
              "CIDADE PONTO B"                  , ascii(09),
              "CIDADE PONTO C"                  , ascii(09),
              "CIDADE PONTO D"                  , ascii(09),
              "CIDADE DESTINO INF. PORTAL"      , ascii(09),
              "UF DESTINO INFORMADO PORTAL"     , ascii(09),
              "ASSISTENCIA"                     , ascii(09),
              "NATUREZA DO SERVICO"             , ascii(09),
              "VALOR DO KM"                     , ascii(09),#falta
              "VALOR TOTAL(SAIDA + ADICIONAIS)" , ascii(09),
              "CODIGO DOS ADICIONAIS COBRADOS"  , ascii(09),
              "QTDE DE KM TOLERANCIA APLICADA"  , ascii(09),
              "TOLERANCIA APLICADA"             , ascii(09),
              "LIMITADOR DE KM PARA LIBERACAO"
    on every row

        #print column 001
        # mr_acerto.autokadat # Data/hora do acionamento
        if mr_acerto.autokadat is not null and  mr_acerto.autokadat <> " " then
            print mr_acerto.autokadat clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

          # mr_acerto.autokahor # Data/hora do acionamento
        if mr_acerto.autokahor is not null and  mr_acerto.autokahor <> " " then
            print mr_acerto.autokahor clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        # mr_acerto.srvprsacnhordat # Data/hora do acionamento
        if mr_acerto.cnldat is not null and  mr_acerto.cnldat <> " " then
            print mr_acerto.cnldat clipped, " ", mr_acerto.atdfnlhor clipped,  ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        # mr_acerto.atdsrvnum / mr_acerto.atdsrvano      # Numero do servico
        if mr_acerto.atdsrvnum is not null and mr_acerto.atdsrvnum <> " " then
            print mr_acerto.atdsrvnum clipped, "/", mr_acerto.atdsrvano  clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        #Verificando a quantidade de Km percorrido no percurso oficial
        open crelat_02 using mr_acerto.atdsrvnum,
        		     mr_acerto.atdsrvano

        whenever error continue
             fetch crelat_02 into m_qtdPercurso
        whenever error stop

        if m_qtdPercurso is not null and  m_qtdPercurso <> " " then
            print m_qtdPercurso clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped,ascii(09);
        end if

        initialize m_tlrqlmnum to null
        open crelat_06 using mr_acerto.atdsrvnum,
        		     mr_acerto.atdsrvano

        whenever error continue
             fetch crelat_06 into m_tlrqlmnum
        whenever error stop

         #mr_acerto.m_tlrqlmnum    # Quantidade km tolerancia
        if  m_tlrqlmnum is not null and m_tlrqlmnum  <> " " then
            let m_qtdPercurso = m_qtdPercurso + m_tlrqlmnum
            print m_qtdPercurso clipped, ascii(09);
        else
            print m_qtdPercurso clipped, ASCII(09);
        end if

        #mr_acerto.socadccstqtd    # Quantidade custo adicional
        if  mr_acerto.socadccstqtd is not null and mr_acerto.socadccstqtd  <> " " then
            print mr_acerto.socadccstqtd clipped, ascii(09);
        else
            print '0' clipped, ASCII(09);
        end if

          #mr_acerto.atdsrvorg    # Codigo Origem
        if  mr_acerto.atdsrvorg is not null and mr_acerto.atdsrvorg  <> " " then
            print mr_acerto.atdsrvorg clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ASCII(09);
        end if

        #ORIGEM
        whenever error continue
            select srvtipdes
              into mr_acerto.srvtipdes
              from datksrvtip
             where datksrvtip.atdsrvorg = mr_acerto.atdsrvorg
        whenever error stop

        if mr_acerto.srvtipdes is not null and  mr_acerto.srvtipdes <> " " then
            print mr_acerto.srvtipdes clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped,ascii(09);
        end if

	#Tipo Percurso Oficial
        open crelat_04 using mr_acerto.atdsrvnum,
        		     mr_acerto.atdsrvano

        let m_contador = 1
        whenever error continue
             foreach crelat_04 into mr_percurso[m_contador].cldpcutipcod,
	     	                    mr_percurso[m_contador].pcuseqnum,
			    	    mr_percurso[m_contador].inicidnom,
			    	    mr_percurso[m_contador].fimcidnom,
			    	    mr_percurso[m_contador].pcuqlmnum,
			    	    mr_percurso[m_contador].tlrqlmnum

                     if m_contador > 10 then
                        display "* * * QUANTIDADE DE PERCURSOS MAIOR QUE O ARRAY"
                        display " ABRIR CHAMADO PARA SISTEMAS ARAGUAIA * * *"
                        exit program(1)
                     else
                        let m_contador = m_contador + 1
                     end if

	     end foreach
        whenever error stop

        let m_contador = m_contador - 1

        # Tipo percurso oficial

        whenever error continue
             open crelat_03 using mr_percurso[1].cldpcutipcod
             fetch crelat_03 into m_cpodes
        whenever error stop

        if m_cpodes is not null and m_cpodes <> " " then
           print m_cpodes  clipped, ascii(09);
        else
           print 'NAO CADASTRADO' clipped , ascii(09);
        end if

        # Codigo Prestador
        if mr_acerto.pstcoddig is not null and mr_acerto.pstcoddig <> " " then
            print mr_acerto.pstcoddig  clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if
        # Nome razao social
        if mr_acerto.nomrazsoc is not null and mr_acerto.nomrazsoc <> " " then
           print mr_acerto.nomrazsoc  clipped, ascii(09);
        else
           print 'NAO CADASTRADO' clipped, ascii(09);
        end if


        if m_contador > 0 then

            #informando cidade
            #Cidade A
            if mr_percurso[1].inicidnom is not null and mr_percurso[1].inicidnom <> " " then
 	       print mr_percurso[1].inicidnom  clipped, ascii(09);
            else
	       print 'NAO CADASTRADO' clipped, ascii(09);
            end if

	    #Cidade B
            if mr_percurso[2].inicidnom is not null and mr_percurso[2].inicidnom <> " " then
                print mr_percurso[2].inicidnom  clipped, ascii(09);
            else
                 print 'NAO CADASTRADO' clipped, ascii(09);
            end if

            if m_contador <= 2 then
                #Cidade C
                print 'NAO CADASTRADO' clipped, ascii(09);
            else
                if mr_percurso[2].fimcidnom is not null and mr_percurso[2].fimcidnom <> " " then
                   print mr_percurso[2].fimcidnom  clipped, ascii(09);
                else
                   print 'NAO CADASTRADO' clipped, ascii(09);
                end if
            end if

            display "m_contador: ",m_contador
            display "mr_percurso[m_contador].fimcidnom: " , mr_percurso[m_contador].fimcidnom

            #Cidade D
            if mr_percurso[m_contador].fimcidnom is not null and mr_percurso[m_contador].fimcidnom <> " " then
                print mr_percurso[m_contador].fimcidnom  clipped, ascii(09);
            else
	        print 'NAO CADASTRADO' , ascii(09);
            end if
        else
            print 'NAO CADASTRADO' , ascii(09);
            print 'NAO CADASTRADO' , ascii(09);
            print 'NAO CADASTRADO' , ascii(09);
            print 'NAO CADASTRADO' , ascii(09);
        end if

        #mr_acerto.prsinfdstcidnom # Cidade de destino informada no Portal
        if mr_acerto.prsinfdstcidnom is not null and mr_acerto.prsinfdstcidnom <> " " then
            print mr_acerto.prsinfdstcidnom  clipped, ascii(09);
        else
           print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        #mr_acerto.prsinfdstestsgl # UF de destino informada no Portal
        if mr_acerto.prsinfdstestsgl is not null and mr_acerto.prsinfdstestsgl <> " " then
            print mr_acerto.prsinfdstestsgl  clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        #ASSISTENCIA
        if mr_acerto.asitipcod is not null and  mr_acerto.asitipcod <> " " then
            whenever error continue

            select asitipdes
              into mr_acerto.asitipdes
              from datkasitip
             where datkasitip.asitipcod = mr_acerto.asitipcod

            whenever error stop

            if mr_acerto.asitipdes is not null and  mr_acerto.asitipdes <> " " then
                print mr_acerto.asitipdes  clipped, ascii(09);
            else
                print 'NAO CADASTRADO' clipped, ascii(09);
            end if
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        #Natureza
        if mr_acerto.socntzcod is not null and  mr_acerto.socntzcod <> " " then
            whenever error continue

            select socntzdes
              into mr_acerto.socntzdes
              from datksocntz
             where datksocntz.socntzcod = mr_acerto.socntzcod

            whenever error stop

            if mr_acerto.socntzdes is not null and  mr_acerto.socntzdes <> " " then
                print mr_acerto.socntzdes  clipped, ascii(09);
            else
                print 'NAO CADASTRADO' clipped, ascii(09);
            end if
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        # Codigos dos adicionais
        open crelat_05 using mr_acerto.atdsrvnum,
        	      mr_acerto.atdsrvano

        whenever error continue
            let m_cont = 1
            foreach crelat_05 into mr_custos.soccstcod,
            		            mr_custos.socadccstvlr,
                                   mr_custos.socadccstqtd

            	 if mr_custos.soccstcod == 3 then
            	     let m_qtdKExcedente = mr_custos.socadccstqtd
            	     let m_vlrKExcedente = mr_custos.socadccstvlr
            	 end if

            	 if m_cont > 1 then
        	     let m_codigosAdicionais = m_codigosAdicionais + ';' + mr_custos.soccstcod using "&"
                 else
                    let m_codigosAdicionais = mr_custos.soccstcod clipped
                 end if

                let m_cont = m_cont + 1
            end foreach
        whenever error stop

        #VALOR KM --Ueslei
        if mr_acerto.atdsrvorg == 9 or mr_acerto.atdsrvorg == 13 then
        {Quando RE o valor sempre serah 0.7}
            let m_valorKm = 0.7
            print m_valorKm using "#,###,###,##&.&&" clipped, ascii(09);
        else
            if mr_acerto.atdsrvorg is not null and mr_acerto.atdsrvorg <> " " then
               let m_valorKm = m_vlrKExcedente / m_qtdKExcedente
               print m_valorKm using "#,###,###,##&.&&" clipped, ascii(09);
            else
               print 'NAO CADASTRADO' clipped, ascii(09);
            end if
        end if
        #FIM VALOR KM

        #VALOR TOTAL ADICIONAL
        if mr_acerto.fnlvlr is not null and mr_acerto.fnlvlr <> " " then
           print mr_acerto.fnlvlr using "#,###,###,##&.&&" clipped, ascii(09);
        else
            print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        if m_codigosAdicionais is not null and m_codigosAdicionais <> " " then
           print m_codigosAdicionais  clipped, ascii(09);
        else
           print ' ' clipped, ascii(09);
        end if

        if mr_acerto.tlrqlmnum is not null and mr_acerto.tlrqlmnum <> " " then
           print mr_acerto.tlrqlmnum  clipped, ascii(09);
        else
           print 'NAO CADASTRADO ' clipped, ascii(09);
        end if

        #Percentual aplicacao tolerancia
        if mr_acerto.tlrapcper is not null and mr_acerto.tlrapcper <> " " then
           print  mr_acerto.tlrapcper clipped, ascii(09);
        else
           print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        # Limite para aprovacao
         if mr_acerto.apvqlmnum is not null and  mr_acerto.apvqlmnum <> " " then
           print   mr_acerto.apvqlmnum clipped, ascii(09);
        else
           print 'NAO CADASTRADO' clipped, ascii(09);
        end if

        initialize mr_custos
                  ,mr_percurso[10].*
                  ,mr_acerto
                  ,m_qtdPercurso
                  ,m_qtdKExcedente
                  ,m_cpodes
                  ,m_contador
                  ,m_cont
                  ,m_valorkm
                  ,m_qtdKExcedente
                  ,m_codigosAdicionais to null

        skip 1 line
 end report

#################################################################################

#----------------------------------------#
 function relat_envia_mail(m_tip, m_path)
#----------------------------------------#
        define  m_assunto     char(0100),
                m_erro_envio  integer,
                m_comando     char(0200),
                m_anexo       char(1000),
                m_tip         char(0003),
                m_path        char(1000)

        # ---> INICIALIZACAO DAS VARIAVEIS
        let m_comando    = null
        let m_erro_envio = null

        case m_tip
             when "ACR"
                  let m_assunto = "Relatorio de Liberacoes Automaticas Acerto de Valor"
        end case

        # COMPACTA O ARQUIVO DO RELATORIO
        let m_comando = "gzip -f ", m_path
        run m_comando

        let m_path = m_path  clipped, ".gz "

        # ENVIA E-MAIL
        let m_erro_envio = ctx22g00_envia_email("BDBSR017", m_assunto, m_path)

        if  m_erro_envio <> 0 then
            if  m_erro_envio <> 99 then
                display "Erro ao enviar email(BDBSR017) - ", m_erro_envio
            else
                display "Nao existe email cadastrado para o modulo - BDBSR017"
            end if
        end if

 end function

#-----------------------------------#
 function bdbsr017_busca_path(m_tip)
#-----------------------------------#

     define m_tip   char(0003)

     let m_path = null

     let m_path = f_path("DBS","RELATO")

     if  m_path is null then
         let m_path = "."
     end if

     case m_tip
          when "ACR"
               let m_path = m_path clipped, "/BDBSR017Temp.xls"
     end case

 end function

#################################################################################
