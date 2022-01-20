#############################################################################
# Nome do Modulo: BDBSR019                                         Marcelo  #
#                                                                  Gilberto #
# Relacao de pagamentos - Porto Socorro                            Nov/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/03/1999  PSI 7885-9   Gilberto     Imprimir tambem o valor do INSS.    #
#---------------------------------------------------------------------------#
# 10/11/1999  PSI 9710-1   Wagner       Alterar Order by emissao relatorio. #
#---------------------------------------------------------------------------#
# 09/03/2000  PSI 10181-8  Wagner       Destacar cooperativas no relatorio. #
#---------------------------------------------------------------------------#
# 15/02/2001  PSI 10631-3  Wagner       Adaptar leitura para tratamento das #
#                                       OP's do carro-extra ver OBS: #WWW   #
#---------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
#############################################################################
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 23/01/2004  ivone meta     PSI182133 calcular e imprimir impostos de      #
#                            OSF 30449 PIS,COFINS,CSLL                      #
# ---------- --------------- ---------- ----------------------------------- #
# 26/06/2004 Bruno, Meta      PSI185035 Padronizar o processamento Batch    #
#                             OSF036870 do Porto Socorro.                   #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 26/07/2006 Cristiane Silva    PSI197858 Descontos da OP.                    #
#-----------------------------------------------------------------------------#
# 15/12/2006 Priscila Staingel  PSI205206 Separar relat�rio por empresa       #
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
 define m_prep_sql     smallint                     #psi182133 ivone
 define m_path         char(100)
 #define m_path2	       char(100)
 define m_vlr_lim      like dbsmopg.socfattotvlr # PSI 185035

 define m_pathrel01 char(100)
 define m_pathrel02 char(100)


 main

    call fun_dba_abre_banco("CT24HS")

    #PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr019.log"

    call startlog(m_path)
    # PSI 185035 - Final

    call bdbsr019()

 end main


#inicio psi182133 ivone
#--------------------------------------------------------------------
 function bdbsr019_prepara()
#--------------------------------------------------------------------
 define l_sql    char(200)

 let l_sql = "select socirfvlr, socissvlr, insretvlr, pisretvlr,cofretvlr, cslretvlr ",
             "  from dbsmopgtrb where socopgnum = ? "
 prepare pbdbsr019001  from l_sql
 declare cbdbsr019001 cursor for pbdbsr019001

 let l_sql = "select pgtdstdes    ",
              "  from fpgkpgtdst   ",
              " where pgtdstcod = ?"
 prepare sel_pgtdst from l_sql
 declare c_pgtdst cursor for sel_pgtdst

 let l_sql = "select atdsrvnum,   ",
              "       atdsrvano    ",
              "  from dbsmopgitm   ",
              " where socopgnum = ?"
 prepare sel_opgitm from l_sql
 declare c_opgitm cursor for sel_opgitm

 let l_sql = "select ramcod,      ",
              "       succod,      ",
              "       aplnumdig,   ",
              "       itmnumdig    ",
              "  from datrservapol ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?"
 prepare sel_servapol from l_sql
 declare c_servapol cursor for sel_servapol

 let l_sql = "select corsus         ",
              "  from abamcor        ",
              " where succod    = ?  ",
              "   and aplnumdig = ?  ",
              "   and corlidflg = 'S'"
 prepare sel_abamcor from l_sql
 declare c_abamcor cursor for sel_abamcor

 let l_sql = " select cornom               ",
              "   from gcaksusep , gcakcorr ",
              "  where gcaksusep.corsus = ? ",
              "    and gcakcorr.corsuspcp = gcaksusep.corsuspcp "
 prepare sel_gcakcorr from l_sql
 declare c_gcakcorr cursor for sel_gcakcorr

 let l_sql = "select prscootipcod ",
              "  from dpaksocor   ",
              " where pstcoddig = ?"
 prepare sel_dpaksocor from l_sql
 declare c_dpaksocor cursor for sel_dpaksocor

 let l_sql = "select cpodes ",
              "  from iddkdominio   ",
              " where cponom = 'prscootipcod' ",
              "   and cpocod = ? "
 prepare sel_iddkdominio from l_sql
 declare c_iddkdominio cursor for sel_iddkdominio

 # PSI 185035 - Inicio
 let l_sql = "select grlinf ",
              "  from datkgeral ",
              " where grlchv = 'PSOVLRLIMRELAUT' "
 prepare pbdbsr019002 from l_sql
 declare cbdbsr019002 cursor for pbdbsr019002
 # PSI 185035 - Final

 #PSI197858 - inicio
 let l_sql = "select sum(dscvlr) from dbsropgdsc where socopgnum = ?"
 prepare pbdbsr019003 from l_sql
 declare cbdbsr019003 cursor for pbdbsr019003
 #PSI197858 - fim

 #PSI 205206
 let l_sql = "select b.ciaempcod "
            ," from dbsmopgitm a, datmservico b "
            ," where a.socopgnum = ? "
            ,"   and a.atdsrvnum = b.atdsrvnum "
            ,"   and a.atdsrvano = b.atdsrvano "
 prepare pbdbsr019004 from l_sql
 declare cbdbsr019004 cursor for pbdbsr019004

 let m_prep_sql = true

end function
#fim psi182133 ivone

#--------------------------------------------------------------------
 function bdbsr019()
#--------------------------------------------------------------------

 define d_bdbsr019    record    socpgtopccod      like dbsmopgfav.socpgtopccod,
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

 #inicio psi182133 ivone
 define l_pisretvlr   like dbsmopgtrb.pisretvlr
       ,l_cofretvlr   like dbsmopgtrb.cofretvlr
       ,l_cslretvlr   like dbsmopgtrb.cslretvlr
       ,l_assunto char(60)
       ,l_assunto2 char(60)
 #fim psi182133 ivone

 define ws            record
    #socopgsitcod      like dbsmopg.socopgsitcod,
    pstcoddig         like dbsmopg.pstcoddig,
    segnumdig         like dbsmopg.segnumdig,
    corsus            like dbsmopg.corsus,
    bcoctatip         like dbsmopgfav.bcoctatip,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    #sql               char (500),
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    pathrel02         char (60),
    prscootipcod      like dpaksocor.prscootipcod,
    msgcoop           char (09),
    #soctip            like dbsmopg.soctip,
    socfatitmqtd      like dbsmopg.socfatitmqtd,
    #PSI197858 - inicio
    vl_desconto	      like dbsropgdsc.dscvlr,
    #PSI197858 - fim
    #data	      date,
    retorno 	      smallint,
    ciaempcodOP       like datmservico.ciaempcod    #PSI 205206
 end record

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize d_bdbsr019.*  to null
 initialize ws.*          to null

 let ws_traco  = "-------------------------------------------------------------------------------------------------------------------------------------"

 #inicio psi182133 ivone
 if m_prep_sql is null or m_prep_sql <> true then
    call bdbsr019_prepara()
 end if
 #fim psi182133 ivone


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

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS01901"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS01902" 
 #PSI197858 - inicio
 let m_pathrel01 = ws.dirfisnom clipped, "/RDBS01901.xls" 
 let m_pathrel02 = ws.dirfisnom clipped, "/RDBS01902.xls" 
 #PSI197858 - fim

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS01901")
      returning  ws_cctcod01,
                 ws_relviaqtd01

 call fgerc010("RDBS01902")
      returning  ws_cctcod02,
                 ws_relviaqtd02

#--------------------------------------------------------------------
# Le todas as ordens de pagamento a serem pagas na data
#--------------------------------------------------------------------

 declare c_bdbsr019  cursor for
   select dbsmopgfav.socpgtopccod,
          dbsmopg.socopgnum,
          dbsmopgfav.socopgfavnom,
          dbsmopg.pstcoddig,
          dbsmopg.segnumdig,
          dbsmopg.corsus,
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
    where dbsmopg.socfatpgtdat = ws_data and
          dbsmopg.socopgsitcod = 7       and   #PSI 205206
          dbsmopg.soctip = 1             and   #PSI 205206
          dbsmopgfav.socopgnum = dbsmopg.socopgnum

 #inicia relatorios
 #------------------------------------------------------
 start report rep_relacao  to  ws.pathrel01
 start report rep_relacaoxls to m_pathrel01   #PSI 197858
 
 #relatorio recibo tb gerado qdo tipo de pgto � cheque
 start report rep_recibo   to  ws.pathrel02
 start report rep_reciboxls to m_pathrel02    #PSI 197858

 foreach c_bdbsr019  into  d_bdbsr019.socpgtopccod,
                           d_bdbsr019.socopgnum,
                           d_bdbsr019.socopgfavnom,
                           ws.pstcoddig,
                           ws.segnumdig,
                           ws.corsus,
                           d_bdbsr019.socopgvlr,
                           d_bdbsr019.socopgdscvlr,
                           d_bdbsr019.pgtdstcod,
                           d_bdbsr019.bcocod,
                           d_bdbsr019.bcoagnnum,
                           d_bdbsr019.bcoctanum,
                           d_bdbsr019.bcoctadig,
                           ws.bcoctatip,
                           #ws.socopgsitcod,
                           #ws.soctip,
                           ws.socfatitmqtd

     #PSI 205206 - inclusao dessas validacoes no where do select
     #if ws.socopgsitcod = 7  then  ###  OP ja' emitida
     #else
     #   continue foreach
     #end if
     #
     #if ws.soctip <> 1 then
     #   continue foreach
     #end if

     if ws.bcoctatip = 1  then
        initialize d_bdbsr019.bcoctades to null
     else
        let d_bdbsr019.bcoctades = "POUP"
     end if

     #PSI197858 - inicio
     open cbdbsr019003 using d_bdbsr019.socopgnum
     fetch cbdbsr019003 into ws.vl_desconto

     if ws.vl_desconto is not null and ws.vl_desconto > 0.00 then
     	let d_bdbsr019.socopgdscvlr = ws.vl_desconto
     end if

     close cbdbsr019003
     #PSI197858 - fim

     initialize d_bdbsr019.corsus,
                d_bdbsr019.cornom,
                d_bdbsr019.ramcod,
                d_bdbsr019.succod,
                d_bdbsr019.aplnumdig,
                d_bdbsr019.itmnumdig,
                ws.atdsrvnum,
                ws.atdsrvano,
                ws.prscootipcod,
                ws.msgcoop            to null

     if ws.pstcoddig is not null  then
        let d_bdbsr019.socopgfavtip = "PRESTADOR"
        let d_bdbsr019.pgttiptxt    = "PAGAMENTO POR PRESTACAO SERVICOS - PORTO SOCORRO"
        #-------------------------------------
        # Verifica se prestador e' cooperativa
        #-------------------------------------
        open  c_dpaksocor using  ws.pstcoddig
        fetch c_dpaksocor into   ws.prscootipcod
        close c_dpaksocor
        if ws.prscootipcod is not null then
           open  c_iddkdominio using  ws.prscootipcod
           fetch c_iddkdominio into   ws.msgcoop
           close c_iddkdominio
           let ws.msgcoop = "COOP.",ws.msgcoop[1,4]
        end if
     else
        #------------------------------------------------------------------
        # Busca numero do servico
        #------------------------------------------------------------------
        open  c_opgitm  using  d_bdbsr019.socopgnum
        fetch c_opgitm  into   ws.atdsrvnum,
                               ws.atdsrvano
        close c_opgitm

        #------------------------------------------------------------------
        # Busca numero da apolice do servico
        #------------------------------------------------------------------
        open  c_servapol  using  ws.atdsrvnum,
                                 ws.atdsrvano
        fetch c_servapol  into   d_bdbsr019.ramcod,
                                 d_bdbsr019.succod,
                                 d_bdbsr019.aplnumdig,
                                 d_bdbsr019.itmnumdig

        if sqlca.sqlcode <> notfound  then
           #---------------------------------------------------------------
           # Busca informacoes sobre corretor da apolice
           #---------------------------------------------------------------
           open  c_abamcor  using  d_bdbsr019.succod,
                                   d_bdbsr019.aplnumdig
           fetch c_abamcor  into   d_bdbsr019.corsus
           close c_abamcor

           open  c_gcakcorr using  d_bdbsr019.corsus
           fetch c_gcakcorr into   d_bdbsr019.cornom
           close c_gcakcorr

        end if
        close c_servapol

        #-----------------------------------------------------------------
        # Verifica tipo de reembolso
        #-----------------------------------------------------------------
        if ws.segnumdig is not null  then
           let d_bdbsr019.socopgfavtip = "SEGURADO"
           let d_bdbsr019.pgttiptxt    = "REEMBOLSO A SEGURADO - PORTO SOCORRO"
        else
           let d_bdbsr019.socopgfavtip = "CORRETOR"
           let d_bdbsr019.pgttiptxt    = "REEMBOLSO A CORRETOR - PORTO SOCORRO"
        end if
     end if

     #PSI 205206 - verificar se OP � Porto ou Azul
     # estou buscando apenas o 1� item da OP, pq todos os itens da OP
     # devem ter a mesma empresa
     open cbdbsr019004 using d_bdbsr019.socopgnum
     foreach cbdbsr019004 into ws.ciaempcodOP
     end foreach
     close cbdbsr019004

     initialize d_bdbsr019.socirfvlr,
                d_bdbsr019.socissvlr,
                d_bdbsr019.insretvlr to null

     #inicio psi182133 ivone

     let l_pisretvlr = null
     let l_cofretvlr = null
     let l_cslretvlr = null

     open  cbdbsr019001  using  d_bdbsr019.socopgnum
     whenever error continue
     fetch cbdbsr019001  into   d_bdbsr019.socirfvlr,
                                d_bdbsr019.socissvlr,
                                d_bdbsr019.insretvlr,
                                l_pisretvlr,
                                l_cofretvlr,
                                l_cslretvlr
     whenever error stop
     if sqlca.sqlcode <> 0  then
        if sqlca.sqlcode <> notfound  then
           display "Erro Select dbsmopgtrb ",sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
           display "bdbsr019() chave : ", d_bdbsr019.socopgnum
           exit program(1)
        end if
     end if

     #fim psi182133 ivone

     let d_bdbsr019.pgtdstdes = "*** NAO CADASTRADO ***"

     if d_bdbsr019.pgtdstcod is not null  then
        open  c_pgtdst  using  d_bdbsr019.pgtdstcod
        fetch c_pgtdst  into   d_bdbsr019.pgtdstdes
        close c_pgtdst
     end if

     let d_bdbsr019.socchqvlr = d_bdbsr019.socopgvlr

     if d_bdbsr019.socissvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - d_bdbsr019.socissvlr
     end if

     if d_bdbsr019.socirfvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - d_bdbsr019.socirfvlr
     end if

     if d_bdbsr019.insretvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - d_bdbsr019.insretvlr
     end if

     if d_bdbsr019.socopgdscvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - d_bdbsr019.socopgdscvlr
     end if
     #inicio psi182133 ivone
     if l_pisretvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - l_pisretvlr
     end if

     if l_cofretvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - l_cofretvlr
     end if

     if l_cslretvlr is not null  then
        let d_bdbsr019.socchqvlr = d_bdbsr019.socchqvlr - l_cslretvlr
     end if
     #fim psi182133 ivone

     # PSI 185035 - Inicio
     let m_vlr_lim = null
     open cbdbsr019002
     whenever error continue
     fetch cbdbsr019002 into m_vlr_lim
     whenever error stop
     if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          display 'Erro de SQL cbdbsr019002 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          exit program(1)
       else
          let m_vlr_lim = null
       end if
     end if

     if m_vlr_lim is null or
        m_vlr_lim <= 0 then
        #PSI197858 - inicio
        #Mudar de 5000 para 20000 o valor limite
        #let m_vlr_lim = 5000
        let m_vlr_lim = 20000
     else
        let m_vlr_lim = m_vlr_lim / 100
     end if
     #PSI197858 - fim

     if d_bdbsr019.socchqvlr > m_vlr_lim  then
        let d_bdbsr019.socvlrcod = 1
     else
        let d_bdbsr019.socvlrcod = 2
     end if
     # PSI 185035 - Final
 
     #PSI 205206
     #output to report rep_relacao(d_bdbsr019.socpgtopccod thru d_bdbsr019.socvlrcod, ws.msgcoop, ws.socfatitmqtd)
     output to report rep_relacao(ws.ciaempcodOP, 
                                  d_bdbsr019.socpgtopccod thru d_bdbsr019.socvlrcod, 
                                  ws.msgcoop, ws.socfatitmqtd)
     
     #output to report rep_relacaoxls(d_bdbsr019.socpgtopccod thru d_bdbsr019.socvlrcod, ws.msgcoop, ws.socfatitmqtd)
     output to report rep_relacaoxls(ws.ciaempcodOP,
                                     d_bdbsr019.socpgtopccod thru d_bdbsr019.socvlrcod, 
                                     ws.msgcoop, ws.socfatitmqtd)
     
     if d_bdbsr019.socpgtopccod = 2  then
        output to report rep_recibo
                        (1, ws.ciaempcodOP,    #PSI 205206
                            d_bdbsr019.socopgnum thru d_bdbsr019.pgtdstdes,
                            d_bdbsr019.socopgdscvlr thru d_bdbsr019.itmnumdig,
                            l_pisretvlr,l_cofretvlr,l_cslretvlr)     #psi182133 ivone
        #PSI197858 - inicio
	output to report rep_reciboxls
			(1, ws.ciaempcodOP,     #PSI 205206
			    d_bdbsr019.socopgnum thru d_bdbsr019.pgtdstdes,
                            d_bdbsr019.socopgdscvlr thru d_bdbsr019.itmnumdig,
                            l_pisretvlr,l_cofretvlr,l_cslretvlr)
        #PSI197858 - fim
        output to report rep_recibo
                        (2, ws.ciaempcodOP,      #PSI 205206
                            d_bdbsr019.socopgnum thru d_bdbsr019.pgtdstdes,
                            d_bdbsr019.socopgdscvlr thru d_bdbsr019.itmnumdig,
                            l_pisretvlr,l_cofretvlr,l_cslretvlr)     #psi182133 ivone

     end if

 end foreach

 finish report rep_recibo
 finish report rep_relacao
 #PSI197858 - inicio
 finish report rep_reciboxls
 finish report rep_relacaoxls
 #PSI197858 - fim


 let l_assunto = "Impressos da Relacao de Pagamentos RDBS01901 - Porto Socorro em ", ws_data
 call ctx22g00_envia_email("BDBSR019", l_assunto, ws.pathrel01)
     returning ws.retorno
 if ws.retorno <> 0 then
    display "Erro no envio de email"
 else
    display "Envio com sucesso"
 end if

 let l_assunto2 = "Recibo de Pagamentos RDBS01902 - Porto Socorro em ", ws_data
 call ctx22g00_envia_email("BDBSR019", l_assunto2, m_pathrel02)
     returning ws.retorno
 if ws.retorno <> 0 then
    display "Erro no envio de email"
 else
    display "Envio com sucesso"
 end if

 #PSI197858 - fim

end function  ###  bdbsr019

#---------------------------------------------------------------------------
 report rep_relacao(r_bdbsr019)
#---------------------------------------------------------------------------

 define r_bdbsr019    record
    ciaempcod         like datmservico.ciaempcod,    #PSI 205206
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

 define a_bdbsr019    array[03] of record
    arr_total         array[04] of record
       socpgtopc      char (25),
       socopgqtd      smallint ,
       socchqvlr      like dbsmopg.socfattotvlr
    end record
 end record

 define arr_aux       smallint
 define arr_tip       smallint
 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

 define ws            record
    totflg            smallint,
    fimflg            smallint
    #asterisco         char (03),
    #data	      date,
    #desconto          decimal(15,5)
 end record

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr019.ciaempcod,  #PSI 205206
             r_bdbsr019.socvlrcod,
             r_bdbsr019.socpgtopccod,
             r_bdbsr019.pgtdstdes,
             r_bdbsr019.socopgnum

   format
      page header
           if pageno  =  1   then

              #se 1� pagina - carrega op�ao em suas devidas posicoes
              for arr_tip = 1 to 3
                 let a_bdbsr019[arr_tip].arr_total[01].socpgtopc = "DEPOSITO EM CONTA"
                 let a_bdbsr019[arr_tip].arr_total[02].socpgtopc = "CHEQUE"
                 let a_bdbsr019[arr_tip].arr_total[03].socpgtopc = "BOLETO BANCARIO"

                 case arr_tip
                    when 1
                       let a_bdbsr019[arr_tip].arr_total[04].socpgtopc = "TOTAL ACIMA DO LIMITE"
                    when 2
                       let a_bdbsr019[arr_tip].arr_total[04].socpgtopc = "TOTAL DENTRO DO LIMITE"
                    when 3
                       let a_bdbsr019[arr_tip].arr_total[04].socpgtopc = "TOTAL GERAL"
                 end case

                #zera valores
                 for arr_aux = 1 to 4
                    let a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd = 0
                    let a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
                 end for
              end for

              let ws.totflg = false
              let ws.fimflg = false

              print "OUTPUT JOBNAME=DBS01901 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELACAO DE PAGAMENTOS - PORTO SOCORRO"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
              print ascii(12)

           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           call cty14g00_empresa(1, r_bdbsr019.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print column 040, "EMPRESA: ", l_nomeEmp,   #PSI 205206
                 column 100, "RDBS019-01",
                 column 114, "PAGINA : ", pageno using "##,###,##&"
           print column 114, "DATA   : ", today
           print column 032, "RELACAO DE PAGAMENTOS - PORTO SOCORRO EM ", ws_data,
                 column 114, "HORA   :   ", time
           skip 2 lines

           let arr_tip = r_bdbsr019.socvlrcod
           let arr_aux = r_bdbsr019.socpgtopccod

           #se � uma p�gina normal
           #if ws.totflg = false  then
              print column 001, "TIPO PAGAMENTO: ", a_bdbsr019[arr_tip].arr_total[arr_aux].socpgtopc;
              if r_bdbsr019.socvlrcod = 1  then
                 print column 102, "ACIMA DO LIMITE ($",m_vlr_lim using '<<<,<<&.&&',")"
              else
                 print column 102, "DENTRO DO LIMITE ($",m_vlr_lim using '<<<,<<&.&&',")"
              end if

              print column 001, ws_traco

              print column 001, "ORDEM PAGTO",
                    column 014, "FAVORECIDO",
                    column 065, "TIPO FAV.",
                    column 076, "QTD. VL.LIQUIDO";

              if r_bdbsr019.socpgtopccod = 2  then
                 print column 098, "DESTINO"
              else
                 print column 098, "BANCO",
                       column 104, "AGENC.",
                       column 111, "CONTA",
                       column 127, "TIPO"
              end if
           #else #se � uma pagina de fechamento
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

#     #PSI 205206 - quebrar p�gina qdo mudar empresa
#    before group of r_bdbsr019.ciaempcod
#         skip to top of page

#     after group of r_bdbsr019.ciaempcod
#          #quando finalizar uma empresa imprime total geral
#          #exibe pagina de fechamento
#          let ws.totflg = true
#          skip to top of page
#          
#          for arr_aux = 1 to 4
#             if arr_aux = 4  then
#                skip 1 line
#                print column 001, ws_traco
#             end if
#             #imprime tipo de opcao (DEPOSITO/CHEQUE/BOLETO)                                 
#             # e a qtde de OP�s (somada a cada linha) e o valor acumulado
#             # para a empresa
#             print column 020, a_bdbsr019[3].arr_total[arr_aux].socpgtopc,
#                   column 050, a_bdbsr019[3].arr_total[arr_aux].socopgqtd  using "###,##&",
#                   column 086, a_bdbsr019[3].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&";
#             skip 1 line
#          end for          
#       
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
#             # e a qtde de OP�s (somada a cada linha) e o valor acumulado
#             # para a empresa       
#             print column 020, a_bdbsr019[arr_tip].arr_total[04].socpgtopc,
#                   column 050, a_bdbsr019[arr_tip].arr_total[04].socopgqtd  using "###,##&",
#                   column 086, a_bdbsr019[arr_tip].arr_total[04].socchqvlr  using "###,###,##&.&&"
#          end for
#      
#          print column 001, ws_traco           
#          
#          #zerar variaveis para n�o acumular com a proxima empresa

#         for arr_tip = 1 to 3
#             for arr_aux = 1 to 4
#                let a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd = 0
#                let a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
#             end for            
#         end for

#     before group of r_bdbsr019.socvlrcod
#          skip to top of page

#     after  group of r_bdbsr019.socvlrcod
#          let ws.totflg = true
#          skip to top of page

#          for arr_aux = 1 to 4
#             if arr_aux = 4  then
#                skip 1 line
#                print column 001, ws_traco
#             end if
#             #imprime tipo de opcao (DEPOSITO/CHEQUE/BOLETO)
#             # e a qtde de OP�s (somada a cada linha) para o tipo (maior ou menor que limite)
#             print column 020, a_bdbsr019[arr_tip].arr_total[arr_aux].socpgtopc,
#                   column 050, a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd  using "###,##&";

#             #select sum(dscvlr) into ws.desconto
#             #from dbsropgdsc
#             #where socopgnum = r_bdbsr019.socopgnum

#              if ws.desconto is not null and ws.desconto > 0.00 then
#              		let a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr = a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr - ws.desconto
#              end if
#               #imprime o valor total das OP�s
#           	print column 086, a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&";

#	skip 1 line
#          end for

#          print column 001, ws_traco

#          #acumula no total geral
#          for arr_aux = 1 to 4
#             let a_bdbsr019[03].arr_total[arr_aux].socopgqtd =
#                 a_bdbsr019[03].arr_total[arr_aux].socopgqtd +
#                 a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd

#             let a_bdbsr019[03].arr_total[arr_aux].socchqvlr =
#                 a_bdbsr019[03].arr_total[arr_aux].socchqvlr +
#                 a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr
#          end for

} ## PSI 232700 - ligia 11/11/2008 - inibir

      before group of r_bdbsr019.socpgtopccod
           skip to top of page

      after  group of r_bdbsr019.socpgtopccod
           skip 1 lines
           print column 001, ws_traco
           print column 001, "TOTAL DE ORDENS DE PAGAMENTO: ",
                 column 030, a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd    using "###,##&",
                 column 077, a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr    using "###,###,##&.&&"
           print column 001, ws_traco

           let a_bdbsr019[arr_tip].arr_total[04].socopgqtd =
               a_bdbsr019[arr_tip].arr_total[04].socopgqtd +
               a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd

           let a_bdbsr019[arr_tip].arr_total[04].socchqvlr =
               a_bdbsr019[arr_tip].arr_total[04].socchqvlr +
               a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr

#ligia 02/12/08
         for arr_tip = 1 to 3
             for arr_aux = 1 to 4
                let a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd = 0
                let a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr = 0.00
             end for            
         end for

      on every row
#          if r_bdbsr019.socchqvlr > 5000.00  then
#             let ws.asterisco = "[*]"
#          else
#             initialize ws.asterisco to null
#          end if

           print column 002, r_bdbsr019.socopgnum    using "######&&&&"    ,
                 column 014, r_bdbsr019.socopgfavnom[1,40]                 ,
                 column 055, r_bdbsr019.msgcoop                            ,
                 column 065, r_bdbsr019.socopgfavtip                       ,
                 column 076, r_bdbsr019.socfatitmqtd using "####"          ,
                 column 081, r_bdbsr019.socchqvlr    using "###,##&.&&"    ;
#                column 093, ws.asterisco                                  ;

           if r_bdbsr019.socpgtopccod = 2  then
              print column 098, r_bdbsr019.pgtdstcod using "&&&", " - ",
                                r_bdbsr019.pgtdstdes
           else
              print column 098, r_bdbsr019.bcocod    using "&&&&"          ,
                    column 104, r_bdbsr019.bcoagnnum using "&&&&&"         ,
                    column 111, r_bdbsr019.bcoctanum using "&&&&&&&&&&&&"  ,
                           "-", r_bdbsr019.bcoctadig                       ,
                    column 127, r_bdbsr019.bcoctades
           end if

           #acumula quantidade de OP�s e valor
           let a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd =
               a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd + 1

           let a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr =
               a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr + r_bdbsr019.socchqvlr

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
      #PSI 205206 - movido para o after group da empresa, pois devo exibir totais por empresa
      #     let r_bdbsr019.socvlrcod = 3
      #     let ws.totflg = true
      #     skip to top of page
      #
      #     for arr_aux = 1 to 4
      #        if arr_aux = 4  then
      #           skip 1 line
      #           print column 001, ws_traco
      #        end if
      #        print column 020, a_bdbsr019[arr_tip].arr_total[arr_aux].socpgtopc,
      #              column 050, a_bdbsr019[arr_tip].arr_total[arr_aux].socopgqtd  using "###,##&",
      #              column 086, a_bdbsr019[arr_tip].arr_total[arr_aux].socchqvlr  using "###,###,##&.&&"
      #     end for
      #
      #     print column 001, ws_traco
      #
      #     let ws.totflg = true
      #     skip to top of page
      #
      #     for arr_tip = 1 to 3
      #        if arr_tip = 3  then
      #           skip 1 line
      #           print column 001, ws_traco
      #        end if
      #
      #        print column 020, a_bdbsr019[arr_tip].arr_total[04].socpgtopc,
      #              column 050, a_bdbsr019[arr_tip].arr_total[04].socopgqtd  using "###,##&",
      #              column 086, a_bdbsr019[arr_tip].arr_total[04].socchqvlr  using "###,###,##&.&&"
      #
      #     end for
      #
      #     print column 001, ws_traco


end report  ###  rep_relacao

#---------------------------------------------------------------------------
 report rep_recibo(r_bdbsr019)
#---------------------------------------------------------------------------

 define r_bdbsr019    record
    numvia            smallint,
    ciaempcod         like datmservico.ciaempcod,    #PSI 205206
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
    itmnumdig         like datrservapol.itmnumdig,
    pisretvlr         like dbsmopgtrb.pisretvlr,      #psi182133 ivone
    cofretvlr         like dbsmopgtrb.cofretvlr,      #psi182133 ivone
    cslretvlr         like dbsmopgtrb.cslretvlr      #psi182133 ivone
 end record
 
 define l_nomeEmp     like gabkemp.empsgl,    #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

 define font_index    char (01)

   output
      left   margin  000
      right  margin  065
      top    margin  000
      bottom margin  000
      page   length  050

   order by  r_bdbsr019.ciaempcod  #PSI 205206

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS01902 FORMNAME=BRANCO"
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
           call cty14g00_empresa(1, r_bdbsr019.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp
           print column 040, "EMPRESA: ", l_nomeEmp   #PSI 205206

      before group of r_bdbsr019.ciaempcod    #PSI 205206
           skip to top of page

      on every row
           skip to top of page

           print column 000, FONT_INDEX;
           if r_bdbsr019.numvia = 1  then
              print column 001, "1a. VIA - SEGURADORA"
           else
              print column 001, "2a. VIA - FAVORECIDO"
           end if
           skip 3 lines

           print column 000, FONT_INDEX;
           print column 001, "DATA PAGTO....: ", ws_data
           print column 000, FONT_INDEX;
           print column 001, "ORDEM PAGTO...: ", r_bdbsr019.socopgnum  using "<<<<<<<<<<"
           skip 2 lines

           print column 000, FONT_INDEX;
           print column 001, "FAVORECIDO....: ",
                 r_bdbsr019.socopgfavtip  clipped, " - ",
                 r_bdbsr019.socopgfavnom

           print column 000, FONT_INDEX;
           print column 001, "TIPO PAGAMENTO: ", r_bdbsr019.pgttiptxt clipped
           skip 1 line

           #----------------------------------------------------------------
           # Nos casos de reembolso, imprime apolice e corretor
           #----------------------------------------------------------------
           if r_bdbsr019.aplnumdig  is not null    then
              print column 000, FONT_INDEX;
              print column 001, "APOLICE.......: ",
                    r_bdbsr019.ramcod     using  "&&&&",       "/",
                    r_bdbsr019.succod     using  "&&",         "/",
                    r_bdbsr019.aplnumdig  using  "<<<<<<<< <", "/",
                    r_bdbsr019.itmnumdig  using  "<<<<<< <"

              print column 000, FONT_INDEX;
              print column 001, "CORRETOR......: ",
                    r_bdbsr019.corsus       clipped, " - ",
                    r_bdbsr019.cornom
              skip 1 line
           end if

           skip 1 line

           print column 000, FONT_INDEX;
           print column 001, "VALOR BRUTO...: ", r_bdbsr019.socopgvlr     using "***,***,**&.&&"

           print column 000, FONT_INDEX;
           print column 001, "I.S.S.........: ";
           if r_bdbsr019.socissvlr is null  then
              print "**************"
           else
              print r_bdbsr019.socissvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "IMPOSTO RENDA.: ";
           if r_bdbsr019.socirfvlr is null  then
              print "**************"
           else
              print r_bdbsr019.socirfvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "I.N.S.S. .....: ";
           if r_bdbsr019.insretvlr is null  then
              print "**************"
           else
              print r_bdbsr019.insretvlr     using "***,***,**&.&&"
           end if
           #inicio psi182133  ivone
           print column 000, FONT_INDEX;
           print column 001, "P.I.S. .......: ";
           if r_bdbsr019.pisretvlr is null  then
              print "**************"
           else
              print r_bdbsr019.pisretvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "C.O.F.I.N.S ..: ";
           if r_bdbsr019.cofretvlr is null  then
              print "**************"
           else
              print r_bdbsr019.cofretvlr     using "***,***,**&.&&"
           end if

           print column 000, FONT_INDEX;
           print column 001, "C.S.L.L. .....: ";
           if r_bdbsr019.cslretvlr is null  then
              print "**************"
           else
              print r_bdbsr019.cslretvlr     using "***,***,**&.&&"
           end if

           #fim psi182133  ivone
           if r_bdbsr019.socopgdscvlr is not null  and
              r_bdbsr019.socopgdscvlr <> 0.00      then
              print column 000, FONT_INDEX;
              print column 001, "DESC.ADIANTAM.: ", r_bdbsr019.socopgdscvlr  using "***,***,**&.&&"
           end if
           skip 1 line

           print column 000, FONT_INDEX;
           print column 001, "VALOR CHEQUE..: ", r_bdbsr019.socchqvlr     using "***,***,**&.&&"
           skip 1 line
           print column 000, FONT_INDEX;
           print column 001, "DESTINO CHEQUE: ", r_bdbsr019.pgtdstcod     using "&&&", " - ", r_bdbsr019.pgtdstdes

      on last row
           print "$FIMREL$"

end report  ###  rep_recibo



#---------------------------------------------------------------------------
 report rep_relacaoxls(r_bdbsr019)
#---------------------------------------------------------------------------

define r_bdbsr019    record
    ciaempcod         like datmservico.ciaempcod,    #PSI 205206
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

  define a_bdbsr019    array[03] of record
    arr_total         array[04] of record
       socpgtopc      char (25),
       socopgqtd      smallint ,
       socchqvlr      like dbsmopg.socfattotvlr
    end record
 end record

 define arr_aux       smallint
 define arr_tip       smallint
 define l_nomeEmp     like gabkemp.empsgl,          #PSI 205206
        l_ret         smallint,
        l_mensagem    char(50)

 define ws            record
    totflg            smallint,
    fimflg            smallint,
    #asterisco         char (03),
    #data	      date,
    desconto	      decimal(08,02)
 end record

 define l_opcao char(30)


 output
      left   margin  00
      right  margin  00
      top    margin  00
      bottom margin  00
      page   length  02

  order by  r_bdbsr019.ciaempcod,    #PSI 205206
            r_bdbsr019.socopgnum

   format
      #PSI 205206 - vai exibir a cada quebra de grupo por empresa
      #first page header
      #  print "TIPO PAGAMENTO: ", 		ASCII(09);
      #  print "CONSISTE VALOR ", 		ASCII(09);
      #  print   "ORDEM PAGTO",		ASCII(09),
      #  	"FAVORECIDO",		ASCII(09),
      #          "TIPO FAV.",		ASCII(09),
      #          "QTD. ",		ASCII(09),
      #          "VL.LIQUIDO",		ASCII(09),
      #          "DESCONTOS",		ASCII(09);
      #  	print "DESTINO", ASCII(09);
      #  	print 	"BANCO",ASCII(09),
      #          "AGENC.", 	ASCII(09),
      #          "CONTA",	ASCII(09),
      #          "TIPO", 	ASCII(09);
      #  skip 1 line
        
      #PSI 205206 - quebrar p�gina qdo mudar empresa
      before group of r_bdbsr019.ciaempcod
           #skip 2 lines	
           skip to top of page
           
           #busca nome da empresa
           call cty14g00_empresa(1, r_bdbsr019.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp           
           print "EMPRESA: ", l_nomeEmp           
           
           print "TIPO PAGAMENTO: ", ASCII(09);    
           print "CONSISTE VALOR ",  ASCII(09);    
           print "ORDEM PAGTO",	     ASCII(09),            
           	 "FAVORECIDO",	     ASCII(09),            
                 "TIPO FAV.",	     ASCII(09),            
                 "QTD. ",	     ASCII(09),            
                 "VL.LIQUIDO",       ASCII(09),            
                 "DESCONTOS",	     ASCII(09);            
           	print "DESTINO", ASCII(09);                   
           	print "BANCO",   ASCII(09),                    
                      "AGENC.",  ASCII(09),                    
                      "CONTA",	 ASCII(09),                    
                      "TIPO", 	 ASCII(09);                    
           skip 1 line          
        
      on every row
        let l_opcao = " "
      	if r_bdbsr019.socpgtopccod = 1  then
        	let l_opcao = "DEPOSITO EM CONTA"
	else
		if r_bdbsr019.socpgtopccod = 2  then
			let l_opcao = "CHEQUE"
		else
			if r_bdbsr019.socpgtopccod = 3  then
				let l_opcao = "BOLETO BANCARIO"
			end if
		end if
	end if
	print 	l_opcao, 					ASCII(09);

        if r_bdbsr019.socvlrcod = 1  then
        	print "ACIMA DO LIMITE ", "$ ",m_vlr_lim using '<<<,<<&.&&', ASCII(09);
        else
        	print "DENTRO DO LIMITE ", "$ ",m_vlr_lim using '<<<,<<&.&&', ASCII(09);
        end if
      	print   r_bdbsr019.socopgnum    using "######&&&&"    ,	ASCII(09),
                r_bdbsr019.socopgfavnom[1,40]                 ,	ASCII(09),
                r_bdbsr019.socopgfavtip                       ,	ASCII(09),
                r_bdbsr019.socfatitmqtd using "####"          ,	ASCII(09),
                r_bdbsr019.socchqvlr    using "###,##&.&&"    ,	ASCII(09);

                select sum(dscvlr) into ws.desconto
                from dbsropgdsc
                where socopgnum = r_bdbsr019.socopgnum

                print ws.desconto using "###,##&.&&"	      , ASCII(09);

        if r_bdbsr019.socpgtopccod = 2  then
        	print r_bdbsr019.pgtdstcod using "&&&", " - ", r_bdbsr019.pgtdstdes, ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
        	print " ", ASCII(09);
	else
        	print 	" ", ASCII(09),
        		r_bdbsr019.bcocod    using "&&&&"          , 				ASCII(09),
                    	r_bdbsr019.bcoagnnum using "&&&&&"         , 				ASCII(09),
                    	r_bdbsr019.bcoctanum using "&&&&&&&&&&&&"  , "-", r_bdbsr019.bcoctadig, ASCII(09),
                    	r_bdbsr019.bcoctades,							ASCII(09);
	end if
	skip 1 line

	
end report

#---------------------------------------------------------------------------
 report rep_reciboxls(r_bdbsr019)
#---------------------------------------------------------------------------

 define r_bdbsr019    record
    numvia            smallint,
    ciaempcod         like datmservico.ciaempcod,     #PSI 205206
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
    itmnumdig         like datrservapol.itmnumdig,
    pisretvlr         like dbsmopgtrb.pisretvlr,
    cofretvlr         like dbsmopgtrb.cofretvlr,
    cslretvlr         like dbsmopgtrb.cslretvlr
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

   order by  r_bdbsr019.ciaempcod    #PSI 205206

   format
      #PSI 205206 - vai exibir a cada quebra de grupo por empresa
      #first page header
      #          print 	"DATA PAGTO....:", ASCII(09),
      # 		"ORDEM PAGTO...: ", ASCII(09),
      #			"FAVORECIDO....: ", ASCII(09),
      # 		"TIPO PAGAMENTO: ", ASCII(09);
      #          if r_bdbsr019.aplnumdig  is not null    then
      #        		print   "APOLICE.......: ", ASCII(09),
      #			"CORRETOR......: ", ASCII(09);
      #          end if
      #          print "VALOR BRUTO...: ", ASCII(09);
      #          print "I.S.S.........: ", ASCII(09);
      #          print "IMPOSTO RENDA.: ", ASCII(09);
      #          print "I.N.S.S. .....: ", ASCII(09);
      #          print "P.I.S. .......: ", ASCII(09);
      #          print "C.O.F.I.N.S ..: ", ASCII(09);
      #          print "C.S.L.L. .....: ", ASCII(09);
      #          if r_bdbsr019.socopgdscvlr is not null  and
      #             r_bdbsr019.socopgdscvlr <> 0.00      then
      #             print "DESC.ADIANTAM.: ", ASCII(09);
      #     	end if
      #          print "VALOR CHEQUE..: ", ASCII(09);
      #          print "DESTINO CHEQUE: ", ASCII(09);
      #
      #     	skip 1 line
        
      #PSI 205206 - quebrar p�gina qdo mudar empresa
      before group of r_bdbsr019.ciaempcod
           skip to top of page
           
           #busca nome da empresa
           call cty14g00_empresa(1, r_bdbsr019.ciaempcod)
                returning l_ret,
                          l_mensagem,
                          l_nomeEmp           
           print "EMPRESA: ", l_nomeEmp           
           	
           print "DATA PAGTO....:", ASCII(09),
                 "ORDEM PAGTO...: ", ASCII(09),
                 "FAVORECIDO....: ", ASCII(09),
                 "TIPO PAGAMENTO: ", ASCII(09);
           if r_bdbsr019.aplnumdig  is not null    then
              print   "APOLICE.......: ", ASCII(09),
                      "CORRETOR......: ", ASCII(09);
           end if
           print "VALOR BRUTO...: ", ASCII(09);
           print "I.S.S.........: ", ASCII(09);
           print "IMPOSTO RENDA.: ", ASCII(09);
           print "I.N.S.S. .....: ", ASCII(09);
           print "P.I.S. .......: ", ASCII(09);
           print "C.O.F.I.N.S ..: ", ASCII(09);
           print "C.S.L.L. .....: ", ASCII(09);
           if r_bdbsr019.socopgdscvlr is not null  and
              r_bdbsr019.socopgdscvlr <> 0.00      then
              print "DESC.ADIANTAM.: ", ASCII(09);
           end if
           print "VALOR CHEQUE..: ", ASCII(09);
           print "DESTINO CHEQUE: ", ASCII(09);
 
           skip 1 line           	
           	
      on every row
      	        print ws_data, ASCII(09),
                      r_bdbsr019.socopgnum  using "<<<<<<<<<<", ASCII(09),
                      r_bdbsr019.socopgfavtip  clipped, " - ", r_bdbsr019.socopgfavnom, ASCII(09),
           	      r_bdbsr019.pgttiptxt clipped, ASCII(09);
		if r_bdbsr019.aplnumdig  is not null    then
			print 	r_bdbsr019.ramcod     using  "&&&&", "/",
			r_bdbsr019.succod     using  "&&",         "/",
			r_bdbsr019.aplnumdig  using  "<<<<<<<< <", "/",
			r_bdbsr019.itmnumdig  using  "<<<<<< <", ASCII(09);
			print r_bdbsr019.corsus clipped, " - ",r_bdbsr019.cornom, ASCII(09);
		end if
                print r_bdbsr019.socopgvlr using "***,***,**&.&&", ASCII(09);
           	if r_bdbsr019.socissvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.socissvlr using "***,***,**&.&&", ASCII(09);
           	end if
                if r_bdbsr019.socirfvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.socirfvlr using "***,***,**&.&&", ASCII(09);
           	end if
           	if r_bdbsr019.insretvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.insretvlr using "***,***,**&.&&", ASCII(09);
           	end if
                if r_bdbsr019.pisretvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.pisretvlr using "***,***,**&.&&", ASCII(09);
           	end if
		if r_bdbsr019.cofretvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.cofretvlr using "***,***,**&.&&", ASCII(09);
           	end if
           	if r_bdbsr019.cslretvlr is null  then
              		print "**************", ASCII(09);
           	else
              		print r_bdbsr019.cslretvlr using "***,***,**&.&&", ASCII(09);
           	end if
           	if r_bdbsr019.socopgdscvlr is not null  and
              	r_bdbsr019.socopgdscvlr <> 0.00      then
              		print r_bdbsr019.socopgdscvlr  using "***,***,**&.&&", ASCII(09);
           	end if
           	print r_bdbsr019.socchqvlr using "***,***,**&.&&", ASCII(09);
              	print r_bdbsr019.pgtdstcod using "&&&", " - ", r_bdbsr019.pgtdstdes, ASCII(09);
		skip 1 line
end report