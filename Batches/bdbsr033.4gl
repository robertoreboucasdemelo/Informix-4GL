#############################################################################
# Nome do Modulo: BDBSR033                                         Marcelo  #
#                                                                  Gilberto #
# Relacao de servicos atendidos/pagos por convenio do P.Socorro    Dez/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao contabilizar servicos atendidos #
#                                       como particular (srvprlflg = "S")   #
#---------------------------------------------------------------------------#
# 08/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados  #
#                                       atraves do guia postal.             #
#---------------------------------------------------------------------------#
# 05/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 28/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 14/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
# --------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#---------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################


 database porto

 define wsgtraco       char(132)
 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd
 define m_path         char(100)
 
 main
    
    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")      
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr033.log"

    call startlog(m_path)
    call bdbsr033()
    
 end main

#---------------------------------------------------------------
 function bdbsr033()
#---------------------------------------------------------------

 define d_bdbsr033   record
    ligcvntip        like datmligacao.ligcvntip  ,
    nom              like datmservico.nom        ,
    vcldes           like datmservico.vcldes     ,
    vclanomdl        like datmservico.vclanomdl  ,
    vcllicnum        like datmservico.vcllicnum  ,
    atddfttxt        like datmservico.atddfttxt  ,
    asitipabvdes     like datkasitip.asitipabvdes,
    pgtdat           char (05)                   ,
    atddat           char (05)                   ,
    atdhor           like datmservico.atdhor     ,
    atdsrvnum        like datmservico.atdsrvnum  ,
    atdsrvano        like datmservico.atdsrvano  ,
    lgdtxt           char (60)                   ,
    cidnom           char (20)                   ,
    ufdcod           like datmlcl.ufdcod         ,
    atdcstvlr        like datmservico.atdcstvlr  ,
    atdsrvorg        like datmservico.atdsrvorg
 end record

 define w_bdbsr033   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod
 end record

 define ws           record
    lignum           like datrligsrv.lignum    ,
    pgtdat           char (10)                 ,
    atddat           char (10)                 ,
    atdprscod        like datmservico.atdprscod,
    asitipcod        like datmservico.asitipcod,
    atdfnlflg        like datmservico.atdfnlflg,
    srvprlflg        like datmservico.srvprlflg,
    data_aux         char (10)                 ,
    data_de          date                      ,
    data_ate         date                      ,
    dirfisnom        like ibpkdirlog.dirfisnom ,
    pathrel01        char (60)                 ,
    pathrel02        char (60)                 ,
    privez           smallint                  ,
    sqlcode          integer                   ,
    atdetpcod        like datmsrvacp.atdetpcod
 end record

 define sql_select   char(300)

#---------------------------------------------------------------
# Inicializacao das Variaveis
#---------------------------------------------------------------

 initialize d_bdbsr033.*  to null
 initialize w_bdbsr033.*  to null
 initialize ws.*          to null

 let ws.privez = true

 let wsgtraco  = "------------------------------------------------------------------------------------------------------------------------------------"

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------

 let sql_select = "select ligcvntip  ",
                  "  from datmligacao",
                  " where lignum = ? "

 prepare sel_ligacao  from sql_select
 declare c_ligacao  cursor for sel_ligacao

 let sql_select = "select * from iddkdominio     ",
                  " where cponom = 'cvnnum'      ",
                  "   and cpocod = ? "

 prepare sel_convenio from sql_select
 declare c_convenio cursor for sel_convenio

 let sql_select = "select cpodes from iddkdominio",
                  " where cponom = 'ligcvntip'   ",
                  "   and cpocod = ? "

 prepare sel_lig_conv from sql_select
 declare c_lig_conv cursor for sel_lig_conv

 let sql_select = "select asitipabvdes ",
                  "  from datkasitip   ",
                  " where asitipcod = ?"

 prepare sel_assist  from sql_select
 declare c_assist  cursor for sel_assist

 let sql_select = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"

 prepare sel_datmsrvacp from sql_select
 declare c_datmsrvacp cursor for sel_datmsrvacp


#---------------------------------------------------------------
#  Define o periodo mensal
#---------------------------------------------------------------

 let ws.data_aux = arg_val(1)

 if ws.data_aux is null       or
    ws.data_aux =  "  "       then
    let ws.data_aux = today
 else
#   if ws.data_aux >= today      or
    if length(ws.data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_ate = ws.data_aux
 let ws.data_ate = ws.data_ate - 1 units day

 let ws.data_aux = ws.data_ate
 let ws.data_aux = "01","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_de  = ws.data_aux

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                     # Marcio Meta - PSI185035
      returning ws.dirfisnom
      
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
                                                                  
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS03301"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS03302"            # Marcio Meta - PSI185035

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS03301")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS03302")                                       # Marcio Meta - PSI185035
      returning  ws_cctcod02,
		 ws_relviaqtd02

#---------------------------------------------------------------
# Definicao do cursor de servicos atendidos no periodo
#---------------------------------------------------------------

 declare c_bdbsr033_atend   cursor for
    select nom      , vcldes   , vclanomdl,
           vcllicnum, atddfttxt, asitipcod,
           atddat   , atdhor   , atdsrvnum,
           atdsrvano, atdprscod, atdcstvlr,
           atdfnlflg, srvprlflg, atdsrvorg
      from datmservico
     where atddat  between  ws.data_de and ws.data_ate   and
           atdsrvorg <> 10

 start report  rep_atend  to ws.pathrel01

 foreach c_bdbsr033_atend  into  d_bdbsr033.nom      ,
                                 d_bdbsr033.vcldes   ,
                                 d_bdbsr033.vclanomdl,
                                 d_bdbsr033.vcllicnum,
                                 d_bdbsr033.atddfttxt,
                                 ws.asitipcod        ,
                                 ws.atddat           ,
                                 d_bdbsr033.atdhor   ,
                                 d_bdbsr033.atdsrvnum,
                                 d_bdbsr033.atdsrvano,
                                 ws.atdprscod        ,
                                 d_bdbsr033.atdcstvlr,
                                 ws.atdfnlflg        ,
                                 ws.srvprlflg        ,
                                 d_bdbsr033.atdsrvorg

    if ws.srvprlflg = "S"  then
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    #if ws.atdfnlflg = "E"  then
    #   continue foreach
    #else
    #   if ws.atdfnlflg = "L"       and
    #      ws.atdprscod is not null then
    #      continue foreach
    #   end if
    #end if
    open  c_datmsrvacp using d_bdbsr033.atdsrvnum, d_bdbsr033.atdsrvano,
                             d_bdbsr033.atdsrvnum, d_bdbsr033.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod =  6      then      #  elimina etapa excluida
       continue foreach
      else
       if ws.atdetpcod =  5        and  #  elimina etapa cancelada c/prest
          ws.atdprscod is not null then
          continue foreach
       end if
    end if

#---------------------------------------------------------------
# Obtencao do convenio da ligacao
#---------------------------------------------------------------

    let ws.lignum = cts20g00_servico(d_bdbsr033.atdsrvnum, d_bdbsr033.atdsrvano)

    open  c_ligacao  using ws.lignum
    fetch c_ligacao  into  d_bdbsr033.ligcvntip
    close c_ligacao

#---------------------------------------------------------------
# Verifica se o convenio tem apolices na compania
#---------------------------------------------------------------

    open  c_convenio using d_bdbsr033.ligcvntip
    fetch c_convenio

    if sqlca.sqlcode = 0  then
       continue foreach
    end if

    close c_convenio

    call ctx04g00_local_prepare(d_bdbsr033.atdsrvnum,
                                d_bdbsr033.atdsrvano,
                                1, ws.privez)
                      returning w_bdbsr033.lclidttxt,
                                w_bdbsr033.lgdtip,
                                w_bdbsr033.lgdnom,
                                w_bdbsr033.lgdnum,
                                w_bdbsr033.lclbrrnom,
                                w_bdbsr033.brrnom,
                                w_bdbsr033.cidnom,
                                w_bdbsr033.ufdcod,
                                w_bdbsr033.lclrefptotxt,
                                w_bdbsr033.endzon,
                                w_bdbsr033.lgdcep,
                                w_bdbsr033.lgdcepcmp,
                                w_bdbsr033.dddcod,
                                w_bdbsr033.lcltelnum,
                                w_bdbsr033.lclcttnom,
                                w_bdbsr033.c24lclpdrcod,
                                ws.sqlcode

    if ws.sqlcode <> 0  then
       display " Erro (", ws.sqlcode using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
       exit program (1)
    end if

    if ws.privez = true  then
       let ws.privez = false
    end if

    let d_bdbsr033.lgdtxt = w_bdbsr033.lgdtip clipped, " ",
                            w_bdbsr033.lgdnom clipped, " ",
                            w_bdbsr033.lgdnum using "<<<<#"
    let d_bdbsr033.cidnom = w_bdbsr033.cidnom
    let d_bdbsr033.ufdcod = w_bdbsr033.ufdcod

    let d_bdbsr033.atddat = ws.atddat[1,5]

    let d_bdbsr033.asitipabvdes = "N/CADAST"

    open  c_assist using ws.asitipcod
    fetch c_assist into  d_bdbsr033.asitipabvdes
    close c_assist

    output to report rep_atend(ws.data_de, ws.data_ate, d_bdbsr033.*)

 end foreach

 finish report  rep_atend

 declare c_bdbsr033_pagos   cursor for
    select nom      , vcldes   , vclanomdl,
           vcllicnum, atddfttxt, asitipcod,
           pgtdat   , atddat   , atdhor   ,
           atdsrvnum, atdsrvano, atdcstvlr,
           atdfnlflg, atdsrvorg
      from datmservico
     where pgtdat   between  ws.data_de and ws.data_ate

 start report  rep_pagos  to  ws.pathrel02

 foreach c_bdbsr033_pagos  into  d_bdbsr033.nom      ,
                                 d_bdbsr033.vcldes   ,
                                 d_bdbsr033.vclanomdl,
                                 d_bdbsr033.vcllicnum,
                                 d_bdbsr033.atddfttxt,
                                 ws.asitipcod        ,
                                 ws.pgtdat           ,
                                 ws.atddat           ,
                                 d_bdbsr033.atdhor   ,
                                 d_bdbsr033.atdsrvnum,
                                 d_bdbsr033.atdsrvano,
                                 d_bdbsr033.atdcstvlr,
                                 ws.atdfnlflg        ,
                                 d_bdbsr033.atdsrvorg

#---------------------------------------------------------------
# Obtencao do convenio da ligacao
#---------------------------------------------------------------

    let ws.lignum = cts20g00_servico(d_bdbsr033.atdsrvnum, d_bdbsr033.atdsrvano)

    open  c_ligacao  using ws.lignum
    fetch c_ligacao  into  d_bdbsr033.ligcvntip
    close c_ligacao

#---------------------------------------------------------------
# Verifica se o convenio tem apolices na compania
#---------------------------------------------------------------

    open  c_convenio using d_bdbsr033.ligcvntip
    fetch c_convenio

    if sqlca.sqlcode = 0  then
       continue foreach
    end if

    close c_convenio

    call ctx04g00_local_prepare(d_bdbsr033.atdsrvnum,
                                d_bdbsr033.atdsrvano,
                                1, ws.privez)
                      returning w_bdbsr033.lclidttxt,
                                w_bdbsr033.lgdtip,
                                w_bdbsr033.lgdnom,
                                w_bdbsr033.lgdnum,
                                w_bdbsr033.lclbrrnom,
                                w_bdbsr033.brrnom,
                                w_bdbsr033.cidnom,
                                w_bdbsr033.ufdcod,
                                w_bdbsr033.lclrefptotxt,
                                w_bdbsr033.endzon,
                                w_bdbsr033.lgdcep,
                                w_bdbsr033.lgdcepcmp,
                                w_bdbsr033.dddcod,
                                w_bdbsr033.lcltelnum,
                                w_bdbsr033.lclcttnom,
                                w_bdbsr033.c24lclpdrcod,
                                ws.sqlcode

    if ws.sqlcode <> 0  then
       display " Erro (", ws.sqlcode using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
       exit program (1)
    end if

    if ws.privez = true  then
       let ws.privez = false
    end if

    let d_bdbsr033.lgdtxt = w_bdbsr033.lgdtip clipped, " ",
                            w_bdbsr033.lgdnom clipped, " ",
                            w_bdbsr033.lgdnum using "<<<<#"
    let d_bdbsr033.cidnom = w_bdbsr033.cidnom
    let d_bdbsr033.ufdcod = w_bdbsr033.ufdcod
    let d_bdbsr033.atddat = ws.atddat[1,5]
    let d_bdbsr033.pgtdat = ws.pgtdat[1,5]

    let d_bdbsr033.asitipabvdes = "N/CADAST"

    open  c_assist using ws.asitipcod
    fetch c_assist into  d_bdbsr033.asitipabvdes
    close c_assist

    output to report rep_pagos(ws.data_de, ws.data_ate, d_bdbsr033.*)

 end foreach

 finish report  rep_pagos

end function   ###  bdbsr033

#---------------------------------------------------------------------------
 report rep_atend(ws_data_de, ws_data_ate, r_bdbsr033)
#---------------------------------------------------------------------------

 define ws_data_de   date ,
        ws_data_ate  date

 define r_bdbsr033    record
    ligcvntip         like datmligacao.ligcvntip  ,
    nom               like datmservico.nom        ,
    vcldes            like datmservico.vcldes     ,
    vclanomdl         like datmservico.vclanomdl  ,
    vcllicnum         like datmservico.vcllicnum  ,
    atddfttxt         like datmservico.atddfttxt  ,
    asitipabvdes      like datkasitip.asitipabvdes,
    pgtdat            char (05)                   ,
    atddat            char (05)                   ,
    atdhor            like datmservico.atdhor     ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    lgdtxt            char (60)                   ,
    cidnom            char (20)                   ,
    ufdcod            like datmlcl.ufdcod         ,
    atdcstvlr         like datmservico.atdcstvlr  ,
    atdsrvorg         like datmservico.atdsrvorg
 end record

 define ws            record
    qtdsrv            decimal (06,00),
    ligcvndes         char (25)
 end record

 output
    left   margin  000
    right  margin  132
    top    margin  000
    bottom margin  000
    page   length  066

 order by  r_bdbsr033.ligcvntip ,
           r_bdbsr033.vcllicnum ,
           r_bdbsr033.atddat    ,
           r_bdbsr033.atdhor

 format
    page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03301 FORMNAME=BRANCO"        # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS ATENDIDOS POR CONVENIO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
            print ascii(12)
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         let ws.ligcvndes = "*** NAO CADASTRADO ***"

         open  c_lig_conv using r_bdbsr033.ligcvntip
         fetch c_lig_conv into  ws.ligcvndes
         close c_lig_conv

         print column 100, "RDBS033-01",
               column 114, "PAGINA : "  , pageno using "##,###,#&&"
         print column 039, "PORTO SOCORRO - SERVICOS ATENDIDOS",
               column 114, "DATA   : "  , today
         print column 039, "PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 114, "HORA   :   ", time
         skip 2 lines
         print column 001, "CONVENIO: " , r_bdbsr033.ligcvntip using "&&",
                                  " - " , ws.ligcvndes
         skip 1 lines
         print column 001, wsgtraco

         print column 001, "CLIENTE"    ,
               column 043, "VEICULO"    ,
               column 085, "ANO"        ,
               column 092, "PLACA"      ,
               column 102, "PROBLEMA"

         print column 001, "TIPO SOC."  ,
               column 012, "DATA"       ,
               column 020, "HORA"       ,
               column 028, "SERVICO"    ,
               column 043, "ENDERECO"   ,
               column 106, "CIDADE"     ,
               column 129, "UF"

         print column 001, wsgtraco
         skip 1 line

    before group of r_bdbsr033.ligcvntip
         let ws.qtdsrv = 0

         let ws.ligcvndes = "*** NAO CADASTRADO ***"

         open  c_lig_conv using r_bdbsr033.ligcvntip
         fetch c_lig_conv into  ws.ligcvndes
         close c_lig_conv

         skip to top of page

    after  group of r_bdbsr033.ligcvntip
         skip 2 lines
         need 3 lines
         print column 001, wsgtraco
         print column 001, "TOTAL DE ATENDIMENTOS: ", ws.qtdsrv using "<<<,<<&"
         print column 001, wsgtraco

    on every row
         need 3 lines
         print column 001, r_bdbsr033.nom      ,
               column 043, r_bdbsr033.vcldes   ,
               column 085, r_bdbsr033.vclanomdl,
               column 092, r_bdbsr033.vcllicnum,
               column 102, r_bdbsr033.atddfttxt

         print column 001, r_bdbsr033.asitipabvdes,
               column 012, r_bdbsr033.atddat   ,
               column 020, r_bdbsr033.atdhor   ,
               column 028, r_bdbsr033.atdsrvorg  using "&&",      "/",
                           r_bdbsr033.atdsrvnum  using "&&&&&&&", "-",
                           r_bdbsr033.atdsrvano  using "&&",
               column 043, r_bdbsr033.lgdtxt   ,
               column 106, r_bdbsr033.cidnom   ,
               column 129, r_bdbsr033.ufdcod
         skip 1 line

         let ws.qtdsrv = ws.qtdsrv + 1

    on last row
         print "$FIMREL$"

end report    ### rep_atend

#---------------------------------------------------------------------------
 report rep_pagos(ws_data_de, ws_data_ate, r_bdbsr033)
#---------------------------------------------------------------------------

 define ws_data_de   date ,
        ws_data_ate  date

 define r_bdbsr033    record
    ligcvntip         like datmligacao.ligcvntip  ,
    nom               like datmservico.nom        ,
    vcldes            like datmservico.vcldes     ,
    vclanomdl         like datmservico.vclanomdl  ,
    vcllicnum         like datmservico.vcllicnum  ,
    atddfttxt         like datmservico.atddfttxt  ,
    asitipabvdes      like datkasitip.asitipabvdes,
    pgtdat            char (05)                   ,
    atddat            char (05)                   ,
    atdhor            like datmservico.atdhor     ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    lgdtxt            char (60)                   ,
    cidnom            char (20)                   ,
    ufdcod            like datmlcl.ufdcod         ,
    atdcstvlr         like datmservico.atdcstvlr  ,
    atdsrvorg         like datmservico.atdsrvorg
 end record

 define ws            record
    qtdsrv            decimal (06,00)           ,
    totvlr            like datmservico.atdcstvlr,
    medvlr            like datmservico.atdcstvlr,
    maxvlr            like datmservico.atdcstvlr,
    minvlr            like datmservico.atdcstvlr,
    ligcvndes         char (25)
 end record

 output
    left   margin  000
    right  margin  132
    top    margin  000
    bottom margin  000
    page   length  066

 order by  r_bdbsr033.ligcvntip ,
           r_bdbsr033.pgtdat    ,
           r_bdbsr033.atddat    ,
           r_bdbsr033.atdhor

 format
    page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03302 FORMNAME=BRANCO"        # Marcio Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - SERVICOS PAGOS POR CONVENIO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         let ws.ligcvndes = "*** NAO CADASTRADO ***"

         open  c_lig_conv using r_bdbsr033.ligcvntip
         fetch c_lig_conv into  ws.ligcvndes
         close c_lig_conv

         print column 100, "RDBS033-02",
               column 114, "PAGINA : "  , pageno using "##,###,#&&"
         print column 041, "PORTO SOCORRO - SERVICOS PAGOS",
               column 114, "DATA   : "  , today
         print column 039, "PERIODO DE ", ws_data_de, " A ", ws_data_ate,
               column 114, "HORA   :   ", time
         skip 2 lines
         print column 001, "CONVENIO: " , r_bdbsr033.ligcvntip using "&&",
                                  " - " , ws.ligcvndes
         skip 1 lines
         print column 001, wsgtraco

         print column 001, "PAGTO."     ,
               column 008, "CLIENTE"    ,
               column 051, "VEICULO"    ,
               column 095, "ANO"        ,
               column 102, "PLACA"

         print column 001, "ATEND."     ,
               column 008, "PROBLEMA"   ,
               column 028, "TIPO SOC."  ,
               column 040, "SERVICO"    ,
               column 052, "CIDADE"     ,
               column 074, "UF"         ,
               column 088, "CUSTO"

         print column 001, wsgtraco
         skip 1 line

    before group of r_bdbsr033.ligcvntip

         let ws.qtdsrv = 0
         let ws.totvlr = 0.00
         let ws.medvlr = 0.00
         let ws.maxvlr = 0.00
         initialize ws.minvlr to null

         let ws.ligcvndes = "*** NAO CADASTRADO ***"

         open  c_lig_conv using r_bdbsr033.ligcvntip
         fetch c_lig_conv into  ws.ligcvndes
         close c_lig_conv

         skip to top of page

    after  group of r_bdbsr033.ligcvntip
         skip 2 lines
         need 7 lines
         print column 001, wsgtraco
         print column 001, "TOTAL DE ATENDIMENTOS:          ", ws.qtdsrv using "###,##&"
         print column 001, "VALOR TOTAL..........: ", ws.totvlr using "#,###,###,##&.&&"
         let ws.medvlr = ws.totvlr / ws.qtdsrv
         print column 001, "VALOR MEDIO..........: ", ws.medvlr using "#,###,###,##&.&&"
         print column 001, "MAIOR VALOR..........: ", ws.maxvlr using "#,###,###,##&.&&"
         print column 001, "MENOR VALOR..........: ", ws.minvlr using "#,###,###,##&.&&"
         print column 001, wsgtraco

    on every row
         need 3 lines
         print column 001, r_bdbsr033.pgtdat   ,
               column 008, r_bdbsr033.nom      ,
               column 051, r_bdbsr033.vcldes   ,
               column 095, r_bdbsr033.vclanomdl,
               column 102, r_bdbsr033.vcllicnum

         print column 001, r_bdbsr033.atddat   ,
               column 008, r_bdbsr033.atddfttxt,
               column 028, r_bdbsr033.asitipabvdes,
               column 037, r_bdbsr033.atdsrvorg  using "&&", "/",
                           r_bdbsr033.atdsrvnum  using "&&&&&&&", "-",
                           r_bdbsr033.atdsrvano  using "&&",
               column 052, r_bdbsr033.cidnom   ,
               column 074, r_bdbsr033.ufdcod   ,
               column 077, r_bdbsr033.atdcstvlr  using "#,###,###,##&.&&"
         skip 1 line

         if ws.minvlr is null  then
            let ws.minvlr = r_bdbsr033.atdcstvlr
         else
            if r_bdbsr033.atdcstvlr < ws.minvlr  then
               let ws.minvlr = r_bdbsr033.atdcstvlr
            end if
         end if

         if r_bdbsr033.atdcstvlr > ws.maxvlr  then
            let ws.maxvlr = r_bdbsr033.atdcstvlr
         end if

         let ws.qtdsrv = ws.qtdsrv + 1
         let ws.totvlr = ws.totvlr + r_bdbsr033.atdcstvlr

    on last row
         print "$FIMREL$"

end report   ### rep_pagos
