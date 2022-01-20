#############################################################################
# Nome do Modulo: BDBSR094                                         Wagner   #
#                                                                           #
# Relacao de pagamentos - Carro Extra                              Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 01/08/2006 Cristiane Silva    PAS18392  Alterar valor de limite de 5000 para#
#					   20000			      #
#-----------------------------------------------------------------------------#
# 26/07/2006 Cristiane Silva    PSI197858 Descontos da OP.                    #
#-----------------------------------------------------------------------------#
# 20/12/2006 Priscila Staingel  PSI205206 separar OP´s por empresa            #
# 11/11/2008 Ligia Mattge       PSI 232700 Eliminar paginas de totais         #
#                                          desnecessarias                     #
###############################################################################

 database porto

 define ws_traco       char (132)
 define ws_data        char (010)
 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd
 define m_path         char(100)
 define m_limite       like dbsmopg.socfattotvlr # PSI185035
 #define m_vlr_lim      like dbsmopg.socfattotvlr # PSI 185035

 define m_pathrel01 char(100)
 define m_pathrel02 char(100)

 define m_prep_sql  smallint   #PSI 205206

 main

    call fun_dba_abre_banco("CT24HS")

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr094.log"

    call startlog(m_path)
    # PSI 185035 - Final

    call bdbsr094()
 end main

#--------------------------------------------------------------------
 function bdbsr094_prepare()
#--------------------------------------------------------------------
 define l_sql char (500)

 let l_sql = "select pgtdstdes    ",
              "  from fpgkpgtdst   ",
              " where pgtdstcod = ?"

 prepare sel_pgtdst from l_sql
 declare c_pgtdst cursor for sel_pgtdst

 #PSI197858 - inicio
 let l_sql = "select sum(dscvlr) from dbsropgdsc where socopgnum = ?"
 prepare pbdbsr094003 from l_sql
 declare cbdbsr094003 cursor for pbdbsr094003
 #PSI197858 - fim
  
 #PSI 205206
 let l_sql = "select b.ciaempcod "
            ," from dbsmopgitm a, datmservico b "
            ," where a.socopgnum = ? "
            ,"   and a.atdsrvnum = b.atdsrvnum "
            ,"   and a.atdsrvano = b.atdsrvano "
 prepare pbdbsr094004 from l_sql
 declare cbdbsr094004 cursor for pbdbsr094004  
  
 let m_prep_sql = true 
  
end function

#--------------------------------------------------------------------
 function bdbsr094()
#--------------------------------------------------------------------

 define d_bdbsr094    record
    socpgtopccod      like dbsmopgfav.socpgtopccod,
    socopgnum         like dbsmopg.socopgnum,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    socopgfavtip      char (10),
    socopgvlr         like dbsmopg.socfattotvlr,
    socchqvlr         like dbsmopg.socfattotvlr,
    pgtdstcod         like dbsmopg.pgtdstcod,
    pgtdstdes         like fpgkpgtdst.pgtdstdes,
    bcocod            like dbsmopgfav.bcocod,
    bcoagnnum         like dbsmopgfav.bcoagnnum,
    bcoctanum         like dbsmopgfav.bcoctanum,
    bcoctadig         like dbsmopgfav.bcoctadig,
    bcoctades         char (04),
    socvlrcod         smallint,  ###  Quebra de valores acima de $5000,00
    socopgdscvlr      like dbsmopg.socopgdscvlr,
    socirfvlr         like dbsmopgtrb.socirfvlr,
    socissvlr         like dbsmopgtrb.socissvlr,
    insretvlr         like dbsmopgtrb.insretvlr,
    pgttiptxt         char (50),
    corsus            like abamcor.corsus,
    cornom            like gcakcorr.cornom,
    ramcod            like datrservapol.ramcod,
    succod            like datrservapol.succod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig
 end record

 define ws            record
    #socopgsitcod      like dbsmopg.socopgsitcod,
    pstcoddig         like dbsmopg.pstcoddig,
    segnumdig         like dbsmopg.segnumdig,
    #corsus            like dbsmopg.corsus,
    bcoctatip         like dbsmopgfav.bcoctatip,
    #atdsrvnum         like datmservico.atdsrvnum,
    #atdsrvano         like datmservico.atdsrvano,
    #sql               char (500),
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60),
    #prscootipcod      like dpaksocor.prscootipcod,
    msgcoop           char (09),
    #soctip            like dbsmopg.soctip,
    socfatitmqtd      like dbsmopg.socfatitmqtd,
    #PSI197858 - inicio
    vl_desconto	      like dbsropgdsc.dscvlr,
    #PSI197858 - fim
    #data	      date,
    retorno 	      smallint,
    ciaempcodOP       like datmservico.ciaempcod      #PSI 205206
 end record

 define l_limite      like dbsmopg.socfattotvlr # PSI185035
 #define l_pisretvlr   like dbsmopgtrb.pisretvlr
 #define l_cofretvlr   like dbsmopgtrb.cofretvlr
 #define l_cslretvlr   like dbsmopgtrb.cslretvlr
 define l_assunto char(60)
 define l_assunto2 char(60)

 #--------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------
 initialize d_bdbsr094.*  to null
 initialize ws.*          to null

 let ws_traco  = "-------------------------------------------------------------------------------------------------------------------------------------"

 if m_prep_sql is null or m_prep_sql <> true then
    call bdbsr094_prepare()
 end if

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


 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS09401"

 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS09402"
 #PSI197858 - inicio
 let m_pathrel01 = ws.dirfisnom clipped, "/RDBS09401.xls"
 let m_pathrel02 = ws.dirfisnom clipped, "/RDBS09402.xls"
 #PSI197858 - fim

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS09401")
      returning  ws_cctcod01, ws_relviaqtd01

 call fgerc010("RDBS09402")
      returning  ws_cctcod02, ws_relviaqtd02

 #--------------------------------------------------------------------
 # Le todas as ordens de pagamento a serem pagas na data
 #--------------------------------------------------------------------

 # PSI 185035 - Inicio
 whenever error continue
 select grlinf into l_limite
 from datkgeral
 where grlchv = "PSOVLRLIMRELCXT"
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       display "Erro de SQL na tabela DATKGERAL !!"
       exit program(1)
    else
       let l_limite = null   
    end if
 end if

 if l_limite is null or
    l_limite <= 0 then
    #PAS18392 - inicio
    #let l_limite = 5000
    let l_limite = 20000
    #PAS18392 - fim
 else
    let l_limite = l_limite / 100
 end if

 let m_limite  = l_limite

 # PSI 185035 - Final
 set isolation to dirty read
 declare c_bdbsr094  cursor for
   select dbsmopgfav.socpgtopccod,
          dbsmopg.socopgnum,
          dbsmopgfav.socopgfavnom,
          dbsmopg.pstcoddig,
          dbsmopg.segnumdig,
          dbsmopg.socfattotvlr,
          dbsmopg.socopgdscvlr,
          dbsmopg.pgtdstcod,
          dbsmopgfav.bcocod,
          dbsmopgfav.bcoagnnum,
          dbsmopgfav.bcoctanum,
          dbsmopgfav.bcoctadig,
          dbsmopgfav.bcoctatip,
          #dbsmopg.socopgsitcod,
          #dbsmopg.soctip,
          dbsmopg.socfatitmqtd
     from dbsmopg, dbsmopgfav
    where dbsmopg.socfatpgtdat = ws_data       and
          dbsmopgfav.socopgnum = dbsmopg.socopgnum and
          dbsmopg.socopgsitcod = 7 and   #OP emitida       #PSI 205206
          dbsmopg.soctip = 2             #OP carro extra   #PSI 205206


 start report  rep_relacao  to  ws.pathrel01
 start report  rep_recibo   to  ws.pathrel02

 #PSI197858 - inicio
 start report rep_relacaoxls to m_pathrel01
 start report rep_reciboxls to m_pathrel02
 #PSI197858 - fim

 foreach c_bdbsr094  into  d_bdbsr094.socpgtopccod,
                           d_bdbsr094.socopgnum,
                           d_bdbsr094.socopgfavnom,
                           ws.pstcoddig,
                           ws.segnumdig,
                           d_bdbsr094.socopgvlr,
                           d_bdbsr094.socopgdscvlr,
                           d_bdbsr094.pgtdstcod,
                           d_bdbsr094.bcocod,
                           d_bdbsr094.bcoagnnum,
                           d_bdbsr094.bcoctanum,
                           d_bdbsr094.bcoctadig,
                           ws.bcoctatip,
                           #ws.socopgsitcod,
                           #ws.soctip,
                           ws.socfatitmqtd

     #PSI 205206 - inclusao validacoes na clausula where 
     #if ws.socopgsitcod = 7  then  ###  OP ja' emitida
     #else
     #   continue foreach
     #end if
     #
     #if ws.soctip <> 2 then        ### Nao e' carro extra
     #   continue foreach
     #end if

     if ws.bcoctatip = 1  then
        initialize d_bdbsr094.bcoctades to null
     else
        let d_bdbsr094.bcoctades = "POUP"
     end if

     #PSI197858 - inicio
     #busca valor desconto
     open cbdbsr094003 using d_bdbsr094.socopgnum
     fetch cbdbsr094003 into ws.vl_desconto

     if ws.vl_desconto is not null and ws.vl_desconto > 0.00 then
     	let d_bdbsr094.socopgdscvlr = ws.vl_desconto
     end if

     close cbdbsr094003
     #PSI197858 - fim

     #PSI 205206 - verificar se OP é Porto ou Azul
     # estou buscando apenas o 1º item da OP, pq todos os itens da OP
     # devem ter a mesma empresa
     open cbdbsr094004 using d_bdbsr094.socopgnum
     foreach cbdbsr094004 into ws.ciaempcodOP
     end foreach
     close cbdbsr094004

     let d_bdbsr094.pgtdstdes = "*** NAO CADASTRADO ***"
     if d_bdbsr094.pgtdstcod is not null  then
        open  c_pgtdst  using  d_bdbsr094.pgtdstcod
        fetch c_pgtdst  into   d_bdbsr094.pgtdstdes
        close c_pgtdst
     end if

     let d_bdbsr094.socchqvlr = d_bdbsr094.socopgvlr

     if d_bdbsr094.socopgdscvlr is not null  then
        let d_bdbsr094.socchqvlr = d_bdbsr094.socchqvlr - d_bdbsr094.socopgdscvlr
     end if

     if d_bdbsr094.socchqvlr > m_limite  then # PSI 185035
        let d_bdbsr094.socvlrcod = 1
     else
        let d_bdbsr094.socvlrcod = 2
     end if

     if d_bdbsr094.socpgtopccod = 2  then
        let d_bdbsr094.socopgfavtip = "SEGURADO"
        let d_bdbsr094.pgttiptxt    = "REEMBOLSO A SEGURADO - PORTO SOCORRO"
     else
        let d_bdbsr094.socopgfavtip = "LOCADORA"
        let d_bdbsr094.pgttiptxt    = "PAGAMENTO A LOCADORA - PORTO SOCORRO"
     end if

     #output to report rep_relacao(d_bdbsr094.socpgtopccod thru d_bdbsr094.socvlrcod, ws.socfatitmqtd)
     #PSI197858 - inicio
     #output to report rep_relacaoxls(d_bdbsr094.socpgtopccod thru d_bdbsr094.socvlrcod, ws.msgcoop, ws.socfatitmqtd)
     #PSI197858 - fim
     
     #PSI 205206 - inclusao da empresa
     output to report rep_relacao(ws.ciaempcodOP, 
                                  d_bdbsr094.socpgtopccod thru d_bdbsr094.socvlrcod, 
                                  ws.socfatitmqtd)
     output to report rep_relacaoxls(ws.ciaempcodOP, 
                                     d_bdbsr094.socpgtopccod thru d_bdbsr094.socvlrcod, 
                                     ws.msgcoop, ws.socfatitmqtd)
     
     if d_bdbsr094.socpgtopccod = 2  then
        output to report rep_recibo
                        (1, ws.ciaempcodOP,    #PSI 205206
                            d_bdbsr094.socopgnum thru d_bdbsr094.pgtdstdes,
                            d_bdbsr094.socopgdscvlr thru d_bdbsr094.itmnumdig)
        #PSI197858 - inicio
	output to report rep_reciboxls
			 (1, ws.ciaempcodOP,   #PSI 205206
			    d_bdbsr094.socopgnum thru d_bdbsr094.pgtdstdes,
                            d_bdbsr094.socopgdscvlr thru d_bdbsr094.itmnumdig)
        #PSI197858 - fim
        output to report rep_recibo
                        (2, ws.ciaempcodOP,    #PSI 205206
                            d_bdbsr094.socopgnum thru d_bdbsr094.pgtdstdes,
                            d_bdbsr094.socopgdscvlr thru d_bdbsr094.itmnumdig)
     end if


 end foreach

 finish report rep_recibo
 finish report rep_relacao
 #PSI197858 - inicio
 finish report rep_reciboxls
 finish report rep_relacaoxls
 #PSI197858 - fim

 let l_assunto = "Impressos da Relacao de Pagamentos RDBS09401 - Carro Extra em ", ws_data
 call ctx22g00_envia_email("BDBSR094", l_assunto, ws.pathrel01)
      returning ws.retorno

 if ws.retorno <> 0 then
    display "Erro no envio de email"
 else
    display "Envio com sucesso"
 end if

{ #Solicitado pelo Luis em 09/12/08 - psi 232700
 #PSI197858 - inicio
 let l_assunto = "Relacao de Pagamentos RDBS09401 - Carro Extra em ", ws_data
 call ctx22g00_envia_email("BDBSR094", l_assunto, m_pathrel01)
      returning ws.retorno
 if ws.retorno <> 0 then
    display "Erro no envio de email"
 else
    display "Envio com sucesso"
 end if

 let l_assunto2 = "Recibo de Pagamentos RDBS09401 - Carro Extra em ", ws_data
 call ctx22g00_envia_email("BDBSR094", l_assunto2, m_pathrel02)
      returning ws.retorno

 if ws.retorno <> 0 then
    display "Erro no envio de email"
 else
    display "Envio com sucesso"
 end if
} #ligia
 #PSI197858 - fim

end function  ###  bdbsr094

#---------------------------------------------------------------------------
 report rep_relacao(r_bdbsr094)
#---------------------------------------------------------------------------

 define r_bdbsr094    record
    ciaempcod         like datmservico.ciaempcod,      #PSI 205206
    socpgtopccod      like dbsmopgfav.socpgtopccod,
    socopgnum         like dbsmopg.socopgnum,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    socopgfavtip      char (10),
    socopgvlr         like dbsmopg.socfattotvlr,
    socchqvlr         like dbsmopg.socfattotvlr,
    pgtdstcod         like dbsmopg.pgtdstcod,
    pgtdstdes         like fpgkpgtdst.pgtdstdes,
    bcocod            like dbsmopgfav.bcocod,
    bcoagnnum         like dbsmopgfav.bcoagnnum,
    bcoctanum         like dbsmopgfav.bcoctanum,
    bcoctadig         like dbsmopgfav.bcoctadig,
    bcoctades         char (04),
    socvlrcod         smallint,   ###  Quebra de valores acima de $5000,00
    socfatitmqtd      like dbsmopg.socfatitmqtd
 end record

 define a_bdbsr094    array[03] of record
    arr_total         array[04] of record
       socpgtopc      char (25),
       socopgqtd      smallint ,
       socchqvlr      like dbsmopg.socfattotvlr
    end record
 end record

 define arr_aux       smallint
 define arr_tip       smallint

 define ws            record
    totflg            smallint,
    fimflg            smallint,
    #asterisco         char (03),
    desconto          decimal(15,5)
 end record

 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr094.ciaempcod,
             r_bdbsr094.socvlrcod,
             r_bdbsr094.socpgtopccod,
             r_bdbsr094.pgtdstdes,
 #           r_bdbsr094.bcocod,
 #           r_bdbsr094.bcoagnnum,
             r_bdbsr094.socopgnum

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS09401 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELACAO DE PAGAMENTOS - CARRO EXTRA"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
              print ascii(12)

              for arr_tip = 1 to 3
                 let a_bdbsr094[arr_tip].arr_total[01].socpgtopc = "DEPOSITO EM CONTA"
                 let a_bdbsr094[arr_tip].arr_total[02].socpgtopc = "CHEQUE"
                 let a_bdbsr094[arr_tip].arr_total[03].socpgtopc = "BOLETO BANCARIO"

                 case arr_tip
                    when 1
                       let a_bdbsr094[arr_tip].arr_total[04].socpgtopc = "TOTAL ACIMA DO LIMITE"
                    when 2
                       let a_bdbsr094[arr_tip].arr_total[04].socpgtopc = "TOTAL DENTRO DO LIMITE"
                    when 3
                       let a_bdbsr094[arr_tip].arr_total[04].socpgtopc = "TOTAL GERAL"
                 end case

                 for arr_aux = 1 to 4
                    let a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd = 0
                    let a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
                 end for
              end for

              let ws.totflg = false
              let ws.fimflg = false
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           #PSI 205206 - imprimir o nome da empresa na primeira linha de cada pagina
           call cty14g00_empresa(1, r_bdbsr094.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print column 040, "EMPRESA: ", l_nomeEmp,   #PSI 205206
                 column 100, "RDBS094-01",
                 column 114, "PAGINA : ", pageno using "##,###,##&"
           print column 114, "DATA   : ", today
           print column 032, "RELACAO DE PAGAMENTOS - CARRO EXTRA EM ", ws_data,
                 column 114, "HORA   :   ", time
           skip 2 lines

           let arr_tip = r_bdbsr094.socvlrcod
           let arr_aux = r_bdbsr094.socpgtopccod

           #se é pagina normal
           #if ws.totflg = false  then
              print column 001, "TIPO PAGAMENTO: ", a_bdbsr094[arr_tip].arr_total[arr_aux].socpgtopc;
              if r_bdbsr094.socvlrcod = 1  then
                 print column 102, "ACIMA DO LIMITE ($",m_limite using '<<<,<<&.&&',")"
              else
                 print column 102, "DENTRO DO LIMITE ($",m_limite using '<<<,<<&.&&',")"
              end if

              print column 001, ws_traco

              print column 001, "ORDEM PAGTO",
                    column 014, "FAVORECIDO",
                    column 065, "TIPO FAV.",
                    column 076, "QTD. VL.LIQUIDO";

              if r_bdbsr094.socpgtopccod = 2  then
                 print column 098, "DESTINO"
              else
                 print column 098, "BANCO",
                       column 104, "AGENC.",
                       column 111, "CONTA",
                       column 127, "TIPO"
              end if
           #else #se é pagina de fechamento
           #   print column 001, "TOTAL GERAL"
           #   print column 001, ws_traco
#
#              print column 020, "TIPO PAGAMENTO",
#                    column 051, "QUANT.",
#                    column 089, "VALOR TOTAL"
#
#              let ws.totflg = false
#           end if

           print column 001, ws_traco
           skip 2 lines

{ ## PSI 232700 - ligia 11/11/2008 - inibir

#     #PSI 205206 - quebrar página qdo mudar empresa
#     before group of r_bdbsr094.ciaempcod
#          skip to top of page

#     after group of r_bdbsr094.ciaempcod
#          #quando finalizar uma empresa imprime total geral
#          #exibe pagina de fechamento
#          let ws.totflg = true
#          skip to top of page

#          for arr_aux = 1 to 4
#             if arr_aux = 4  then
#                skip 1 line
#                print column 001, ws_traco
#             end if
#             #imprime tipo de opcao (DEPOSITO/CHEQUE/BOLETO)
#             # a qtde de OP´s e o valor acumulado da empresa
#             print column 020, a_bdbsr094[3].arr_total[arr_aux].socpgtopc,
#                   column 050, a_bdbsr094[3].arr_total[arr_aux].socopgqtd  using "###,##&",
#                   column 086, a_bdbsr094[3].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&";
#             skip 1 line
#          end for   
#          print column 001, ws_traco
#          
#          #exibe pagina de fechamento
#          let ws.totflg = true
#          skip to top of page
#          
#          for arr_tip = 1 to 3
#             if arr_tip = 3  then
#                skip 1 line
#                print column 001, ws_traco
#             end if
#             #imprime tipo de opcao (ACIMA ou DENTRO LIMITE/ TOTAL GERAL)
#             # e a qtde de OP´s (somada a cada linha) e o valor acumulado
#             # para a empresa
#             print column 020, a_bdbsr094[arr_tip].arr_total[04].socpgtopc,
#                   column 050, a_bdbsr094[arr_tip].arr_total[04].socopgqtd  using "###,##&",
#                   column 086, a_bdbsr094[arr_tip].arr_total[04].socchqvlr  using "###,###,##&.&&"
#          end for
#          print column 001, ws_traco

#          #zerar variaveis para não acumular com a proxima empresa
#          for arr_tip = 1 to 3
#              for arr_aux = 1 to 4
#                 let a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd = 0
#                 let a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
#              end for
#          end for           

#     before group of r_bdbsr094.socvlrcod
#          skip to top of page

#     after  group of r_bdbsr094.socvlrcod
#          let ws.totflg = true
#          skip to top of page

#          for arr_aux = 1 to 4
#             if arr_aux = 4  then
#                skip 1 line
#                print column 001, ws_traco
#             end if

#             print column 020, a_bdbsr094[arr_tip].arr_total[arr_aux].socpgtopc,
#                   column 050, a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd  using "###,##&";
#             #PSI 205206 - Correcao! estava subtraindo o desconto no resumo de totais da OP
#             #select sum(dscvlr) into ws.desconto
#             #from dbsropgdsc
#             #where socopgnum = r_bdbsr094.socopgnum
#             #
#             #if ws.desconto is not null and ws.desconto > 0.00 then
#             #		let a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr = a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr - ws.desconto
#             #end if
#             print column 086, a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&";

#          end for

#          print column 001, ws_traco

#          #acumula tipos de valores em total
#          for arr_aux = 1 to 4
#             let a_bdbsr094[03].arr_total[arr_aux].socopgqtd =
#                 a_bdbsr094[03].arr_total[arr_aux].socopgqtd +
#                 a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd

#             let a_bdbsr094[03].arr_total[arr_aux].socchqvlr =
#                 a_bdbsr094[03].arr_total[arr_aux].socchqvlr +
#                 a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr

#          end for
} ## PSI 232700 - ligia 11/11/2008 - inibir

     before group of r_bdbsr094.socpgtopccod
          skip to top of page

      after  group of r_bdbsr094.socpgtopccod

           skip 1 lines
           print column 001, ws_traco
           print column 001, "TOTAL DE ORDENS DE PAGAMENTO: ",
                 column 030, a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd    using "###,##&",
                 column 077, a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr    using "###,###,##&.&&"
           print column 001, ws_traco

           let a_bdbsr094[arr_tip].arr_total[04].socopgqtd =
               a_bdbsr094[arr_tip].arr_total[04].socopgqtd +
               a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd

           let a_bdbsr094[arr_tip].arr_total[04].socchqvlr =
               a_bdbsr094[arr_tip].arr_total[04].socchqvlr +
               a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr

#ligia 02/12/08
          #zerar variaveis para não acumular com a proxima empresa
          for arr_tip = 1 to 3
              for arr_aux = 1 to 4
                 let a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd = 0
                 let a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
              end for
          end for           

      on every row
#          if r_bdbsr094.socchqvlr > 5000.00  then
#             let ws.asterisco = "[*]"
#          else
#             initialize ws.asterisco to null
#          end if

           print column 002, r_bdbsr094.socopgnum    using "######&&&&"    ,
                 column 014, r_bdbsr094.socopgfavnom[1,40]                 ,
                 column 065, r_bdbsr094.socopgfavtip                       ,
                 column 076, r_bdbsr094.socfatitmqtd using "####"          ,
                 column 081, r_bdbsr094.socchqvlr    using "###,##&.&&"    ;
#                column 093, ws.asterisco                                  ;

           if r_bdbsr094.socpgtopccod = 2  then
              print column 098, r_bdbsr094.pgtdstcod using "&&&", " - ",
                                r_bdbsr094.pgtdstdes
           else
              print column 098, r_bdbsr094.bcocod    using "&&&&"          ,
                    column 104, r_bdbsr094.bcoagnnum using "&&&&&"         ,
                    column 111, r_bdbsr094.bcoctanum using "&&&&&&&&&&&&"  ,
                           "-", r_bdbsr094.bcoctadig                       ,
                    column 127, r_bdbsr094.bcoctades
           end if

           let a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd =
               a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd + 1

           let a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr =
               a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr + r_bdbsr094.socchqvlr

      page trailer
           skip 6 lines
           print column 001, "------------------------------------------",
                 column 046, "------------------------------------------",
                 column 091, "------------------------------------------"
           print column 001, "      PORTO SOCORRO  (DATA/ASSINATURA)    ",
                 column 046, "        DIRETORIA (DATA/ASSINATURA)       ",
                 column 091, "        FINANCEIRO (DATA/ASSINATURA)      "

           if ws.fimflg = true  then
              print "$FIMREL$"
           else
              print ""
           end if


      on last row
           let ws.fimflg = true
           #PSI 205206 - movido para o after group ciaempcod, pois deve-se
           # agrupar e exibir totais por empresa
           #let r_bdbsr094.socvlrcod = 3
           #let ws.totflg = true
           #skip to top of page
           #
           #for arr_aux = 1 to 4
           #   if arr_aux = 4  then
           #      skip 1 line
           #      print column 001, ws_traco
           #   end if
           #
           #   print column 020, a_bdbsr094[arr_tip].arr_total[arr_aux].socpgtopc,
           #         column 050, a_bdbsr094[arr_tip].arr_total[arr_aux].socopgqtd  using "###,##&",
           #         column 086, a_bdbsr094[arr_tip].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&"
           #
           #end for
           #
           #print column 001, ws_traco
           #
           #let ws.totflg = true
           #skip to top of page
           #
           #for arr_tip = 1 to 3
           #   if arr_tip = 3  then
           #      skip 1 line
           #      print column 001, ws_traco
           #   end if
           #
           #   print column 020, a_bdbsr094[arr_tip].arr_total[04].socpgtopc,
           #         column 050, a_bdbsr094[arr_tip].arr_total[04].socopgqtd  using "###,##&",
           #         column 086, a_bdbsr094[arr_tip].arr_total[04].socchqvlr  using "###,###,##&.&&"
           #
           #end for
           #
           #print column 001, ws_traco

end report  ###  rep_relacao

#---------------------------------------------------------------------------
 report rep_recibo(r_bdbsr094)
#---------------------------------------------------------------------------

 define r_bdbsr094    record
    numvia            smallint,
    ciaempcod         like datmservico.ciaempcod,      #PSI 205206
    socopgnum         like dbsmopg.socopgnum,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    socopgfavtip      char (10),
    socopgvlr         like dbsmopg.socfattotvlr,
    socchqvlr         like dbsmopg.socfattotvlr,
    pgtdstcod         like dbsmopg.pgtdstcod,
    pgtdstdes         like fpgkpgtdst.pgtdstdes,
    socopgdscvlr      like dbsmopg.socopgdscvlr,
    socirfvlr         like dbsmopgtrb.socirfvlr,
    socissvlr         like dbsmopgtrb.socissvlr,
    insretvlr         like dbsmopgtrb.insretvlr,
    pgttiptxt         char (50),
    corsus            like abamcor.corsus,
    cornom            like gcakcorr.cornom,
    ramcod            like datrservapol.ramcod,
    succod            like datrservapol.succod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig
 end record

 define FONT_INDEX    char (01)

 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

   output
      left   margin  000
      right  margin  065
      top    margin  000
      bottom margin  000
      page   length  050

   order by  r_bdbsr094.ciaempcod  #PSI 205206

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS09402 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RECIBO DE PAGAMENTO POR CHEQUE"
              print "$DJDE$ JDL=XJ6570, JDE=XD6570, FORMS=XF6570, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
              print ascii(12)
              let FONT_INDEX = "1"
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if
           #PSI 205206 - imprimir o nome da empresa na primeira linha de cada pagina
           call cty14g00_empresa(1, r_bdbsr094.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print column 040, "EMPRESA: ", l_nomeEmp   #PSI 205206

      before group of r_bdbsr094.ciaempcod    #PSI 205206
           skip to top of page

      on every row
           skip to top of page

           print column 000, FONT_INDEX;
           if r_bdbsr094.numvia = 1  then
              print column 001, "1a. VIA - SEGURADORA"
           else
              print column 001, "2a. VIA - FAVORECIDO"
           end if
           skip 3 lines

           print column 000, FONT_INDEX;
           print column 001, "DATA PAGTO....: ", ws_data
           print column 000, FONT_INDEX;
           print column 001, "ORDEM PAGTO...: ", r_bdbsr094.socopgnum  using "<<<<<<<<<<"
           skip 2 lines

           print column 000, FONT_INDEX;
           print column 001, "FAVORECIDO....: ",
                 r_bdbsr094.socopgfavtip  clipped, " - ",
                 r_bdbsr094.socopgfavnom

           print column 000, FONT_INDEX;
           print column 001, "TIPO PAGAMENTO: ", r_bdbsr094.pgttiptxt clipped
           skip 1 line

           #----------------------------------------------------------------
           # Nos casos de reembolso, imprime apolice e corretor
           #----------------------------------------------------------------
           if r_bdbsr094.aplnumdig  is not null    then
              print column 000, FONT_INDEX;
              print column 001, "APOLICE.......: ",
                    r_bdbsr094.ramcod     using  "&&&&",       "/",
                    r_bdbsr094.succod     using  "&&",         "/",
                    r_bdbsr094.aplnumdig  using  "<<<<<<<< <", "/",
                    r_bdbsr094.itmnumdig  using  "<<<<<< <"

              print column 000, FONT_INDEX;
              print column 001, "CORRETOR......: ",
                    r_bdbsr094.corsus       clipped, " - ",
                    r_bdbsr094.cornom
              skip 1 line
           end if

           skip 1 line

           print column 000, FONT_INDEX;
           print column 001, "VALOR BRUTO...: ", r_bdbsr094.socopgvlr     using "***,***,**&.&&"

           print column 000, FONT_INDEX;
           print column 001, "I.S.S.........: ";
           if r_bdbsr094.socissvlr is null  then
              print "**************"
           else
              print r_bdbsr094.socissvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "IMPOSTO RENDA.: ";
           if r_bdbsr094.socirfvlr is null  then
              print "**************"
           else
              print r_bdbsr094.socirfvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "I.N.S.S. .....: ";
           if r_bdbsr094.insretvlr is null  then
              print "**************"
           else
              print r_bdbsr094.insretvlr     using "***,***,**&.&&"
           end if

           if r_bdbsr094.socopgdscvlr is not null  and
              r_bdbsr094.socopgdscvlr <> 0.00      then
              print column 000, FONT_INDEX;
              print column 001, "DESC.ADIANTAM.: ", r_bdbsr094.socopgdscvlr  using "***,***,**&.&&"
           end if
           skip 1 line

           print column 000, FONT_INDEX;
           print column 001, "VALOR CHEQUE..: ", r_bdbsr094.socchqvlr     using "***,***,**&.&&"
           skip 1 line
           print column 000, FONT_INDEX;
           print column 001, "DESTINO CHEQUE: ", r_bdbsr094.pgtdstcod     using "&&&", " - ", r_bdbsr094.pgtdstdes

      on last row
           print "$FIMREL$"

end report  ###  rep_recibo

#---------------------------------------------------------------------------
 report rep_relacaoxls(r_bdbsr094)
#---------------------------------------------------------------------------

define r_bdbsr094    record
    ciaempcod         like datmservico.ciaempcod,      #PSI 205206
    socpgtopccod      like dbsmopgfav.socpgtopccod,
    socopgnum         like dbsmopg.socopgnum,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    socopgfavtip      char (10),
    socopgvlr         like dbsmopg.socfattotvlr,
    socchqvlr         like dbsmopg.socfattotvlr,
    pgtdstcod         like dbsmopg.pgtdstcod,
    pgtdstdes         like fpgkpgtdst.pgtdstdes,
    bcocod            like dbsmopgfav.bcocod,
    bcoagnnum         like dbsmopgfav.bcoagnnum,
    bcoctanum         like dbsmopgfav.bcoctanum,
    bcoctadig         like dbsmopgfav.bcoctadig,
    bcoctades         char (04),
    socvlrcod         smallint,  ###  Quebra de valores acima de $5000,00
    msgcoop           char (09),
    socfatitmqtd      like dbsmopg.socfatitmqtd
 end record

  define a_bdbsr094    array[03] of record
    arr_total         array[04] of record
       socpgtopc      char (25),
       socopgqtd      smallint ,
       socchqvlr      like dbsmopg.socfattotvlr
    end record
 end record

 define arr_aux       smallint
 define arr_tip       smallint

 define ws            record
    totflg            smallint,
    fimflg            smallint,
    #asterisco        char (03),
    #data	      date,
    desconto	      decimal(08,02)
 end record

define l_opcao char(30)

 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

 output
      left   margin  00
      right  margin  00
      top    margin  00
      bottom margin  00
      page   length  02

  order by  r_bdbsr094.ciaempcod,
            r_bdbsr094.socopgnum

   format
      #PSI 205206 - vai exibir a cada quebra de grupo por empresa
      #first page header
      #  print "TIPO PAGAMENTO: ", 		ASCII(09);
      #  print "CONSISTE VALOR ", 		ASCII(09);
      #  print "ORDEM PAGTO",		ASCII(09),
      #        "FAVORECIDO",		ASCII(09),
      #        "TIPO FAV.",		ASCII(09),
      #        "QTD. ",		ASCII(09),
      #        "VL.LIQUIDO",		ASCII(09),
      #        "DESCONTOS",		ASCII(09);
      #  print "DESTINO", ASCII(09);
      #  print "BANCO",ASCII(09),
      #        "AGENC.", 	ASCII(09),
      #        "CONTA",	ASCII(09),
      #        "TIPO", 	ASCII(09);
      #  skip 1 line
      
      #PSI 205206 - quebrar página qdo mudar empresa
      before group of r_bdbsr094.ciaempcod
           skip to top of page

           #busca nome da empresa
           call cty14g00_empresa(1, r_bdbsr094.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print "EMPRESA: ", l_nomeEmp      
           
           print "TIPO PAGAMENTO: ", 		ASCII(09);
           print "CONSISTE VALOR ", 		ASCII(09);
           print "ORDEM PAGTO",		ASCII(09),
                 "FAVORECIDO",		ASCII(09),
                 "TIPO FAV.",		ASCII(09),
                 "QTD. ",		ASCII(09),
                 "VL.LIQUIDO",		ASCII(09),
                 "DESCONTOS",		ASCII(09);
           print "DESTINO", ASCII(09);
           print "BANCO",ASCII(09),
                 "AGENC.", 	ASCII(09),
                 "CONTA",	ASCII(09),
                 "TIPO", 	ASCII(09);
           skip 1 line           
      
      on every row
        let l_opcao = " "
      	if r_bdbsr094.socpgtopccod = 1  then
        	let l_opcao = "DEPOSITO EM CONTA"
	else
		if r_bdbsr094.socpgtopccod = 2  then
			let l_opcao = "CHEQUE"
		else
			if r_bdbsr094.socpgtopccod = 3  then
				let l_opcao = "BOLETO BANCARIO"
			end if
		end if
	end if
	print 	l_opcao, 					ASCII(09);

        if r_bdbsr094.socvlrcod = 1  then
        	print "ACIMA DO LIMITE ", "$ ",m_limite using '<<<,<<&.&&', ASCII(09);
        else
        	print "DENTRO DO LIMITE ", "$ ",m_limite using '<<<,<<&.&&', ASCII(09);
        end if
      	print   r_bdbsr094.socopgnum    using "######&&&&"    ,	ASCII(09),
                r_bdbsr094.socopgfavnom[1,40]                 ,	ASCII(09),
                r_bdbsr094.socopgfavtip                       ,	ASCII(09),
                r_bdbsr094.socfatitmqtd using "####"          ,	ASCII(09),
                r_bdbsr094.socchqvlr    using "###,##&.&&"    ,	ASCII(09);

 		select sum(dscvlr) into ws.desconto
                from dbsropgdsc
                where socopgnum = r_bdbsr094.socopgnum

                print ws.desconto using "###,##&.&&"	      , ASCII(09);


        if r_bdbsr094.socpgtopccod = 2  then
        	print r_bdbsr094.pgtdstcod using "&&&", " - ", r_bdbsr094.pgtdstdes, ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
	else
        	print 	" ", ASCII(09),
        		r_bdbsr094.bcocod    using "&&&&"          , 				ASCII(09),
                    	r_bdbsr094.bcoagnnum using "&&&&&"         , 				ASCII(09),
                    	r_bdbsr094.bcoctanum using "&&&&&&&&&&&&"  , "-", r_bdbsr094.bcoctadig, ASCII(09),
                    	r_bdbsr094.bcoctades,							ASCII(09);
	end if
	skip 1 line
	
end report

#---------------------------------------------------------------------------
 report rep_reciboxls(r_bdbsr094)
#---------------------------------------------------------------------------

 define r_bdbsr094    record
    numvia            smallint,
    ciaempcod         like datmservico.ciaempcod,      #PSI 205206
    socopgnum         like dbsmopg.socopgnum,
    socopgfavnom      like dbsmopgfav.socopgfavnom,
    socopgfavtip      char (10),
    socopgvlr         like dbsmopg.socfattotvlr,
    socchqvlr         like dbsmopg.socfattotvlr,
    pgtdstcod         like dbsmopg.pgtdstcod,
    pgtdstdes         like fpgkpgtdst.pgtdstdes,
    socopgdscvlr      like dbsmopg.socopgdscvlr,
    socirfvlr         like dbsmopgtrb.socirfvlr,
    socissvlr         like dbsmopgtrb.socissvlr,
    insretvlr         like dbsmopgtrb.insretvlr,
    pgttiptxt         char (50),
    corsus            like abamcor.corsus,
    cornom            like gcakcorr.cornom,
    ramcod            like datrservapol.ramcod,
    succod            like datrservapol.succod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig
 end record

 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

   output
      left   margin  000
      right  margin  065
      top    margin  000
      bottom margin  000
      page   length  050

   order by  r_bdbsr094.ciaempcod    #PSI 205206

   format
      #PSI 205206 - vai exibir a cada quebra de grupo por empresa
      #first page header
      #      print "DATA PAGTO....:", ASCII(09),
      #            "ORDEM PAGTO...: ", ASCII(09),
      #	          "FAVORECIDO....: ", ASCII(09),
      #	          "TIPO PAGAMENTO: ", ASCII(09);
      #      if r_bdbsr094.aplnumdig  is not null    then
      #         print  "APOLICE.......: ", ASCII(09),
      #                "CORRETOR......: ", ASCII(09);
      #      end if
      #      print "VALOR BRUTO...: ", ASCII(09);
      #      print "I.S.S.........: ", ASCII(09);
      #      print "IMPOSTO RENDA.: ", ASCII(09);
      #      print "I.N.S.S. .....: ", ASCII(09);
      #      if r_bdbsr094.socopgdscvlr is not null  and
      #         r_bdbsr094.socopgdscvlr <> 0.00      then
      #         print "DESC.ADIANTAM.: ", ASCII(09);
      #      end if
      #      print "VALOR CHEQUE..: ", ASCII(09);
      #      print "DESTINO CHEQUE: ", ASCII(09);
      #      skip 1 line
      
      #PSI 205206 - quebrar página qdo mudar empresa
      before group of r_bdbsr094.ciaempcod
           skip to top of page

           #busca nome da empresa
           call cty14g00_empresa(1, r_bdbsr094.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print "EMPRESA: ", l_nomeEmp
           print "DATA PAGTO....:", ASCII(09),
                 "ORDEM PAGTO...: ", ASCII(09),
     	          "FAVORECIDO....: ", ASCII(09),
     	          "TIPO PAGAMENTO: ", ASCII(09);
           if r_bdbsr094.aplnumdig  is not null    then
              print  "APOLICE.......: ", ASCII(09),
                     "CORRETOR......: ", ASCII(09);
           end if
           print "VALOR BRUTO...: ", ASCII(09);
           print "I.S.S.........: ", ASCII(09);
           print "IMPOSTO RENDA.: ", ASCII(09);
           print "I.N.S.S. .....: ", ASCII(09);
           if r_bdbsr094.socopgdscvlr is not null  and
              r_bdbsr094.socopgdscvlr <> 0.00      then
              print "DESC.ADIANTAM.: ", ASCII(09);
           end if
           print "VALOR CHEQUE..: ", ASCII(09);
           print "DESTINO CHEQUE: ", ASCII(09);
           skip 1 line           
           
      
      on every row
      	        print ws_data, ASCII(09),
                      r_bdbsr094.socopgnum  using "<<<<<<<<<<", ASCII(09),
                      r_bdbsr094.socopgfavtip  clipped, " - ", r_bdbsr094.socopgfavnom, ASCII(09),
           	      r_bdbsr094.pgttiptxt clipped, ASCII(09);
		if r_bdbsr094.aplnumdig  is not null    then
			print 	r_bdbsr094.ramcod     using  "&&&&", "/",
			r_bdbsr094.succod     using  "&&",         "/",
			r_bdbsr094.aplnumdig  using  "<<<<<<<< <", "/",
			r_bdbsr094.itmnumdig  using  "<<<<<< <", ASCII(09);
			print r_bdbsr094.corsus clipped, " - ",r_bdbsr094.cornom, ASCII(09);
		end if
                print r_bdbsr094.socopgvlr using "***,***,**&.&&", ASCII(09);
           	if r_bdbsr094.socissvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr094.socissvlr using "***,***,**&.&&", ASCII(09);
           	end if
                if r_bdbsr094.socirfvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr094.socirfvlr using "***,***,**&.&&", ASCII(09);
           	end if
           	if r_bdbsr094.insretvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr094.insretvlr using "***,***,**&.&&", ASCII(09);
           	end if
           	if r_bdbsr094.socopgdscvlr is not null  and
              	r_bdbsr094.socopgdscvlr <> 0.00      then
              		print r_bdbsr094.socopgdscvlr  using "***,***,**&.&&", ASCII(09);
           	end if
           	print r_bdbsr094.socchqvlr using "***,***,**&.&&", ASCII(09);
              	print r_bdbsr094.pgtdstcod using "&&&", " - ", r_bdbsr094.pgtdstdes, ASCII(09);
		skip 1 line
end report
