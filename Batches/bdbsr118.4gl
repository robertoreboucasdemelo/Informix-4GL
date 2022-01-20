#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR118.4GL                                              #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........:                                                           #
# OBJETIVO.......: RELATORIO DE INDEXAÇÃO POR USUARIO.                       #
#............................................................................#
# DESENVOLVIMENTO: SERGIO BURINI                                             #
# LIBERACAO......: 07/10/2008                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 02/03/2010 Adriano Santos   PSI 252891    Inclusao do padrao idx 4 e 5     #
# -------------------------------------------------------------------------- #

database porto

    define mr_relat record
                        funmat like datmsrvidxhst.funmat,
                        cidnom like datmsrvidxhst.cidnom,
                        ufdcod like datmsrvidxhst.ufdcod,
                        empcod like datmsrvidxhst.empcod
                    end record

    define m_srvidx       integer,
           m_srvidxgrl    integer,
           m_srvnaoidx    integer,
           m_srvnaoidxgrl integer,
           m_tiprel       char(50),
           m_datini       date,
           m_datfim       date,
           m_path         char(1000),
	   m_path2        char(1000),
           m_funmat       like datmsrvidxhst.funmat,
           m_empcod       like isskfunc.empcod

main

    # VERIFICA SE A EXTRAÇÃO É SEMANAL OU MENSAL
    let m_tiprel = upshift(arg_val(1))

    if  m_tiprel = "SEMANAL" then
        # PERIODO DE UMA SEMANA
        let m_datfim = today - 1 units day
        let m_datini = today - 7 units day
    else
        if  m_tiprel = "MENSAL" then
            # PERIODO DE UM MES
            let m_datfim = today - 1 units day
            let m_datini = today - 1 units month
        else
            if  m_tiprel = "SEMESTRAL" then
                let m_datfim = today - 1 units day  
                let m_datini = today - 6 units month
            else
                display "PARAMETROS INVALIDOS"
                exit program
            end if
        end if
    end if

    call fun_dba_abre_banco("CT24HS")
    call bdbsr118_busca_path()
    call cts40g03_exibe_info("I","BDBSR118")
    call bdbsr118_prepare()
    call bdbsr118()
    call cts40g03_exibe_info("F","BDBSR118")

end main

#---------------------------#
 function bdbsr118_prepare()
#---------------------------#

    define l_sql char(5000)

    # BUSCA TODOS OS OPERADORES QUE ABRIRAM CHAMADO NO PERIODO
    let l_sql = "select distinct idx.funmat, ",
                               " idx.cidnom, ",
                               " idx.ufdcod, ",
                               " fun.empcod  ",
                 " from datmsrvidxhst idx, ",
                      " isskfunc      fun, ",
                      " datkmpacid    cid ",
                " where idx.atddat between ? and ? ",
                  " and idx.srvidxseq    = 1 ",
                  " and idx.funmat       = fun.funmat ",
                  " and idx.empcod       = fun.empcod ",
                  " and fun.dptsgl       in ('ct24hs','ctazul') ",
                  " and cid.cidnom       = idx.cidnom ",
                  " and cid.ufdcod       = idx.ufdcod ",
                  " and cid.mpacrglgdflg = 1 ",
                " order by 1,2,3"

    prepare pbdbsr118_01 from l_sql
    declare cbdbsr118_01 cursor for pbdbsr118_01

    # CONTABILIZA SERVIÇOS QUE FORAM ABERTO E INDEXADOS NO PERIODO
    let l_sql = "select count(*) ",
                 " from datmsrvidxhst hst, ",
                      " datkmpacid    cid ",
                " where hst.funmat        = ? ",
                  " and hst.atddat  between ? and ? ",
                  " and hst.empcod        = ? ",
                  " and hst.srvidxseq     = 1 ",
                  " and hst.c24lclpdrcod  in (3,4,5) ",
                  " and hst.cidnom        = ? ",
                  " and hst.ufdcod        = ? ",
                  " and cid.cidnom        = hst.cidnom ",
                  " and cid.ufdcod        = hst.ufdcod ",
                  " and cid.mpacrglgdflg  = 1"

    prepare pbdbsr118_02 from l_sql
    declare cbdbsr118_02 cursor for pbdbsr118_02

    # CONTABILIZA SERVIÇOS QUE NAO FORAM ABERTO E INDEXADOS NO PERIODO
    let l_sql = "select count(*) ",
                 " from datmsrvidxhst hst, ",
                      " datkmpacid    cid ",
                " where hst.funmat        = ? ",
                  " and hst.atddat  between ? and ? ",
                  " and hst.empcod        = ? ",
                  " and hst.srvidxseq     = 1 ",
                  " and hst.c24lclpdrcod  not in (3,4,5) ", # PSI 252891
                  " and hst.cidnom        = ? ",
                  " and hst.ufdcod        = ? ",
                  " and cid.cidnom        = hst.cidnom ",
                  " and cid.ufdcod        = hst.ufdcod ",
                  " and cid.mpacrglgdflg  = 1 "

    prepare pbdbsr118_03 from l_sql             
    declare cbdbsr118_03 cursor for pbdbsr118_03

    # BUSCA NOME FO FUNCIONARIO
    let l_sql = "select funnom ",
 	         " from isskfunc ",
 	        " where funmat = ? ",
 	          " and empcod = ? "
 
    prepare pbdbsr118_04 from l_sql             
    declare cbdbsr118_04 cursor for pbdbsr118_04 

 end function

#-------------------#
 function bdbsr118()
#-------------------#

    initialize mr_relat.*, m_funmat, m_empcod to null
    
    let m_srvidxgrl    = 0
    let m_srvnaoidxgrl = 0
    let m_srvidx       = 0
    let m_srvnaoidx    = 0

    set isolation to dirty read
    
    open cbdbsr118_01 using m_datini,
                            m_datfim

    start report bdbsr118_rel  to m_path
    start report bdbsr118_rel2 to m_path2

    foreach cbdbsr118_01 into mr_relat.funmat,
                              mr_relat.cidnom,
                              mr_relat.ufdcod,
                              mr_relat.empcod

        if  (m_funmat is null or m_funmat = " ") and 
            (m_empcod is null or m_empcod = " ") then
            let m_funmat = mr_relat.funmat
            let m_empcod = mr_relat.empcod
        else
            if (mr_relat.funmat <> m_funmat) or
               (mr_relat.empcod <> m_empcod) then
                # SEMPRE QUE HÁ TROCA DE USUARIO ENVIA CONTABILIZACAO PARA O RELAORIO GERAL
                output to report bdbsr118_rel2()
                let m_srvidxgrl    = 0
                let m_srvnaoidxgrl = 0
                let m_funmat = mr_relat.funmat
                let m_empcod = mr_relat.empcod
            end if
        end if

        let m_srvidx = 0
        let m_srvnaoidx = 0

        open cbdbsr118_02 using mr_relat.funmat,
                                m_datini,
                                m_datfim,
                                mr_relat.empcod,
                                mr_relat.cidnom,
                                mr_relat.ufdcod
        fetch cbdbsr118_02 into m_srvidx

        let m_srvidxgrl = m_srvidxgrl + m_srvidx

        open cbdbsr118_03 using mr_relat.funmat,
                                m_datini,
                                m_datfim,
                                mr_relat.empcod,
                                mr_relat.cidnom,
                                mr_relat.ufdcod
        fetch cbdbsr118_03 into m_srvnaoidx        

        let m_srvnaoidxgrl = m_srvnaoidxgrl + m_srvnaoidx

        output to report bdbsr118_rel()

    end foreach
    
    output to report bdbsr118_rel2() 

    finish report bdbsr118_rel
    finish report bdbsr118_rel2
    
    call bdbsr118_envia_email()

end function

#-------------------------------#
 function bdbsr118_envia_email()
#-------------------------------#

     define l_assunto     char(100),
     	    l_erro_envio  integer,
      	    l_comando     char(200),
      	    l_anexo       char(1000)
     
     # INICIALIZACAO DAS VARIAVEIS
     
     let l_comando    = null
     let l_erro_envio = null
     let l_assunto    = "RELATÓRIO ", m_tiprel clipped, " DE SERVIÇOS INDEXADOS POR OPERADORES."
     
     # COMPACTA O ARQUIVO DO RELATORIO
     let l_comando = "gzip -f ", m_path
     run l_comando
     
     let l_comando = "gzip -f ", m_path2
     run l_comando
     
     let m_path  = m_path clipped, ".gz"
     let m_path2 = m_path2 clipped, ".gz"
     
     let l_anexo =  m_path clipped, ',', m_path2
     
     let l_erro_envio = ctx22g00_envia_email("BDBSR118", l_assunto, l_anexo)
     
     if l_erro_envio <> 0 then
     	if l_erro_envio <> 99 then
     		display "Erro ao enviar email(ctx22g00) - ", l_anexo
     	else
     		display "Nao existe email cadastrado para o modulo - BDBSR118"
     	end if
     end if

 end function

#-------------------------------#
 function bdbsr118_busca_path()
#-------------------------------#

     let m_path  = null
     let m_path2 = null
     let m_path  = f_path("DBS","RELATO")

     if  m_path is null then
        let m_path = "."
     end if

     let m_path2 = m_path

     let m_path  = m_path clipped,"/BDBSR118.xls"
     let m_path2 = m_path2 clipped,"/BDBSR118_2.xls"

 end function

#---------------------#
 report bdbsr118_rel()
#---------------------#

    define l_nom    like isskfunc.funnom,
           l_perc   decimal(4,1),
           l_count3 integer

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 04

    format
        first page header

 	    initialize l_nom,
                       l_count3 to null

 	    print "RELATORIO DE SERVIÇOS INDEXADOS POR OPERADORES. PERIODO ", m_datini, " A ", m_datfim
            skip 1 line

            print "MATRICULA",              ASCII(09),
                  "ATENDENTE",              ASCII(09),
                  "CIDADE",                 ASCII(09),
                  "UF",                     ASCII(09),
                  "PERC. SRV IDX.",         ASCII(09),
                  "SRV IDX ABERTURA",       ASCII(09),
                  "SRV NAO IDX ABERTURA",   ASCII(09),
                  "TOTAL DE SRVs"

        on every row

 	    let l_perc   = 0
 	    let l_count3 = 0

 	    open cbdbsr118_04 using mr_relat.funmat,
 	                            mr_relat.empcod
 	    fetch cbdbsr118_04 into l_nom

            let l_count3 = m_srvidx + m_srvnaoidx

            if  m_srvnaoidx <> 0 then
 	        let l_perc = (m_srvidx*100)/l_count3
 	    else
 	        let l_perc = 100
 	    end if

 	    print mr_relat.funmat,         ASCII(09),
 	          l_nom           clipped, ASCII(09),
 	          mr_relat.cidnom clipped, ASCII(09),
 	          mr_relat.ufdcod clipped, ASCII(09),
 	          l_perc, "%",             ASCII(09),
 	          m_srvidx,                ASCII(09),
 	          m_srvnaoidx,             ASCII(09),
 	          l_count3

 end report

#----------------------#
 report bdbsr118_rel2()
#----------------------#

    define l_nom    like isskfunc.funnom,
           l_perc   decimal(4,1),
           l_count3 integer

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 04

    format
        first page header

 	    initialize l_nom,
                       l_count3 to null

 	    print "RELATORIO GERAL DE SERVIÇOS INDEXADOS POR OPERADORES. PERIODO ", m_datini, " A ", m_datfim
            skip 1 line

            print "MATRICULA",              ASCII(09),
                  "ATENDENTE",              ASCII(09),
                  "PERC. SRV IDX.",         ASCII(09),
                  "SRV IDX ABERTURA",       ASCII(09),
                  "SRV NAO IDX ABERTURA",   ASCII(09),
                  "TOTAL DE SRVs"
                  
        on every row

 	    let l_perc   = 0
 	    let l_count3 = 0

 	    open cbdbsr118_04 using m_funmat,
 	                            m_empcod
 	    fetch cbdbsr118_04 into l_nom

            let l_count3  = m_srvnaoidxgrl + m_srvidxgrl

            if  m_srvnaoidxgrl <> 0 then
 	        let l_perc = (m_srvidxgrl*100)/l_count3
 	    else
 	        let l_perc = 100
 	    end if
 	    
 	    print m_funmat,                ASCII(09),
 	          l_nom           clipped, ASCII(09),
 	          l_perc, "%",             ASCII(09),
 	          m_srvidxgrl,             ASCII(09),
 	          m_srvnaoidxgrl,          ASCII(09),
 	          l_count3
 	          
 end report 