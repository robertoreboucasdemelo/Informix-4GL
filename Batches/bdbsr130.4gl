#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr130                                                   #
# ANALISTA RESP..: RAJI                                                       #
# PSI/OSF........: 249912                                                     #
#                  AVISO DE ABERTURA ACIONAMENTO E PAGAMENTO DE SRV EMP 40/43 #
#                  CARTAO                                                     #
# ........................................................................... #
# DESENVOLVIMENTO: RAJI                                                       #
# LIBERACAO......: 09/06/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 17/11/2011 Celso Yamahaki  CT-22033/IN inclusao de leitura suja             #
#-----------------------------------------------------------------------------#

database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"
  globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"

  define m_data           date,
         m_data_atual     date,
         m_hora_atual     datetime hour to minute,
         m_path           char(200),
         m_path1          char(200),
         m_path2          char(200),
         m_path3          char(200),
        #m_path4          char(200),
        #m_path5          char(200),
        #m_path6          char(200),
         m_status         integer
         
main     
         
       initialize m_path,
                  m_path1,
                  m_path2,
                  m_path3,
                  m_data,
                  m_data_atual,
                  m_hora_atual  to null
         
       call fun_dba_abre_banco("CT24HS")

       #Calculo do mes para execução ou recebido como parametro
       #caso não seja executado no ultima dia do mes
       let m_data_atual = arg_val(1)

       if m_data_atual is null or m_data_atual = " " then
           # ---> OBTER A DATA E HORA DO BANCO
           call cts40g03_data_hora_banco(2)
           returning m_data_atual,
                     m_hora_atual

           let m_data = m_data_atual - 1 units day
       else 
           let m_data = m_data_atual  # PARAMETRO
       end if

       display "Processamento do dia: ", m_data

       call bdbsr130_busca_path()

       call cts40g03_exibe_info("I","bdbsr130")

       set isolation to dirty read

       call bdbsr130_prepare()

       call bdbsr130()
       
       call bdbsr130_envia_mail()

       call cts40g03_exibe_info("F","bdbsr130")

end main


#---------------------------#
 function bdbsr130_prepare()
#---------------------------#

        define l_sql   char(5000)

        # Busca servicos abertos na data de processamento
        let l_sql = "select lig.c24astcod, ",
                          " srv.atdsrvorg, ",
                          " srv.atdsrvnum, ",
                          " srv.atdsrvano, ",
                          " srv.atddat, ",
                          " srv.atdhor, ",
                          " srv.atddatprg, ",
                          " srv.atdhorprg, ",
                          " nom, ",
                          " cpf.cgccpfnum, ",
                          " cpf.cgcord, ",
                          " cpf.cgccpfdig, ",
                          " brrnom, ",
                          " cidnom, ",
                          " ufdcod, ",
                          " pbm.c24pbmcod, ",
                          " srv.atddfttxt, ",
                          " srv.asitipcod, ",
                          " asi.asitipabvdes, ",
                          " re.socntzcod ",
                     " from datmligacao lig, ",
                          " datmservico srv, ",
                          " datmlcl lcl, ",
                          " datrsrvpbm pbm, ",
                          " outer datrligcgccpf cpf, ",
                          " outer datkasitip asi, ",
                          " outer datmsrvre re ",
                    " where srv.atddat = ?		 ",
                      " and srv.ciaempcod in (40,43) ",
                      " and lig.lignum = (select min(ligsrv.lignum) ",
                                          " from datmligacao ligsrv ",
                                         " where ligsrv.atdsrvnum = srv.atdsrvnum ",
                                           " and ligsrv.atdsrvano = srv.atdsrvano) ",
                      " and cpf.lignum = lig.lignum    ",
                      " and lcl.atdsrvnum = srv.atdsrvnum ",
                      " and lcl.atdsrvano = srv.atdsrvano ",
                      " and lcl.c24endtip = 1 ",
                      " and asi.asitipcod = srv.asitipcod ",
                      " and re.atdsrvnum = srv.atdsrvnum ",
                      " and re.atdsrvano = srv.atdsrvano ",
                      " and pbm.atdsrvnum = srv.atdsrvnum ",
                      " and pbm.atdsrvano = srv.atdsrvano ",
                      " and pbm.c24pbmseq = 1 "
        prepare pbdbsr130_01 from l_sql
        declare cbdbsr130_01 cursor for pbdbsr130_01

        # Busca servicos acionados na data de processamento
        let l_sql = "select lig.c24astcod, ",
                          " srv.atdsrvorg, ",
                          " srv.atdsrvnum, ",
                          " srv.atdsrvano, ",
                          " srv.atddat, ",
                          " srv.atdhor, ",
                          " srv.atddatprg, ",
                          " srv.atdhorprg, ",
                          " nom, ",
                          " cpf.cgccpfnum, ",
                          " cpf.cgcord, ",
                          " cpf.cgccpfdig, ",
                          " brrnom, ",
                          " cidnom, ",
                          " ufdcod, ",
                          " pbm.c24pbmcod, ",
                          " srv.atddfttxt, ",
                          " srv.asitipcod, ",
                          " asi.asitipabvdes, ",
                          " re.socntzcod, ",
                          " acp.atdetpdat, ",
                          " acp.atdetphor, ",
                          " acp.atdetpcod, ",
                          " acp.pstcoddig, ",
                          " acp.socvclcod, ",
                          " acp.srrcoddig ",
                     " from datmsrvacp acp, ",
                          " datmligacao lig, ",
                          " datmservico srv, ",
                          " datmlcl lcl, ",
                          " datrsrvpbm pbm, ",
                          " outer datrligcgccpf cpf, ",
                          " outer datkasitip asi, ",
                          " outer datmsrvre re ",
                    " where acp.atdetpdat = ? ",
                      " and acp.atdetpcod >= 3 ",
                      " and acp.atdsrvseq = ( select max(maxseq.atdsrvseq) ",
                                              " from datmsrvacp maxseq ",
                                             " where maxseq.atdsrvano = acp.atdsrvano ",
                                               " and maxseq.atdsrvnum = acp.atdsrvnum ) ",
                      " and srv.atdsrvano = acp.atdsrvano ",
                      " and srv.atdsrvnum = acp.atdsrvnum ",
                      " and srv.ciaempcod in (40,43) ",
                      " and lig.lignum = (select min(ligsrv.lignum) ",
                                          " from datmligacao ligsrv ",
                                         " where ligsrv.atdsrvnum = srv.atdsrvnum ",
                                           " and ligsrv.atdsrvano = srv.atdsrvano) ",
                      " and cpf.lignum = lig.lignum ",
                      " and lcl.atdsrvnum = srv.atdsrvnum ",
                      " and lcl.atdsrvano = srv.atdsrvano ",
                      " and lcl.c24endtip = 1 ",
                      " and asi.asitipcod = srv.asitipcod ",
                      " and re.atdsrvnum = srv.atdsrvnum ",
                      " and re.atdsrvano = srv.atdsrvano ",
                      " and pbm.atdsrvnum = srv.atdsrvnum ",
                      " and pbm.atdsrvano = srv.atdsrvano ",
                      " and pbm.c24pbmseq = 1 "
        prepare pbdbsr130_02 from l_sql
        declare cbdbsr130_02 cursor for pbdbsr130_02

        # Busca servicos pagos na data de processamento
        let l_sql = "select lig.c24astcod, ",
                          " srv.atdsrvorg, ",
                          " srv.atdsrvnum, ",
                          " srv.atdsrvano, ",
                          " srv.atddat, ",
                          " srv.atdhor, ",
                          " srv.atddatprg, ",
                          " srv.atdhorprg, ",
                          " nom, ",
                          " cpf.cgccpfnum, ",
                          " cpf.cgcord, ",
                          " cpf.cgccpfdig, ",
                          " brrnom, ",
                          " cidnom, ",
                          " ufdcod, ",
                          " pbm.c24pbmcod, ",
                          " srv.atddfttxt, ",
                          " srv.asitipcod, ",
                          " asi.asitipabvdes, ",
                          " re.socntzcod, ",
                          " opg.pstcoddig, ",
                          " opg.socfatpgtdat, ",
                          " opg.socopgnum ",
                     " from dbsmopg opg, ",
                          " dbsmopgitm opgitm, ",
                          " datmligacao lig, ",
                          " datmservico srv, ",
                          " datmlcl lcl, ",
                          " datrsrvpbm pbm, ",
                          " outer datrligcgccpf cpf, ",
                          " outer datkasitip asi, ",
                          " outer datmsrvre re ",
                    " where opg.socfatpgtdat = ? ",
                      " and opg.socopgsitcod = 7 ",
                      " and opgitm.socopgnum = opg.socopgnum ",
                      " and srv.atdsrvnum = opgitm.atdsrvnum ",
                      " and srv.atdsrvano = opgitm.atdsrvano ",
                      " and srv.ciaempcod in (40,43) ",
                      " and lig.lignum = (select min(ligsrv.lignum) ",
                                          " from datmligacao ligsrv ",
                                         " where ligsrv.atdsrvnum = srv.atdsrvnum ",
                                           " and ligsrv.atdsrvano = srv.atdsrvano) ",
                      " and cpf.lignum = lig.lignum ",
                      " and lcl.atdsrvnum = srv.atdsrvnum ",
                      " and lcl.atdsrvano = srv.atdsrvano ",
                      " and lcl.c24endtip = 1 ",
                      " and asi.asitipcod = srv.asitipcod ",
                      " and re.atdsrvnum = srv.atdsrvnum ",
                      " and re.atdsrvano = srv.atdsrvano ",
                      " and pbm.atdsrvnum = srv.atdsrvnum ",
                      " and pbm.atdsrvano = srv.atdsrvano ",
                      " and pbm.c24pbmseq = 1 "
        prepare pbdbsr130_03 from l_sql
        declare cbdbsr130_03 cursor for pbdbsr130_03


        # Obtem decricao da natureza
        let l_sql = "select c24astdes from datkassunto where c24astcod = ?"
        prepare pbdbsr130_04 from l_sql
        declare cbdbsr130_04 cursor for pbdbsr130_04

        # Obtem decricao da natureza
        let l_sql = "select socntzdes from datksocntz where socntzcod = ?"
        prepare pbdbsr130_05 from l_sql
        declare cbdbsr130_05 cursor for pbdbsr130_05

        # Obtem decricao da etapa
        let l_sql = "select atdetpdes from datketapa where atdetpcod = ?"
        prepare pbdbsr130_06 from l_sql
        declare cbdbsr130_06 cursor for pbdbsr130_06

        # Obtem nome de gerra do prestador
        let l_sql = "select nomgrr from dpaksocor where pstcoddig = ?"
        prepare pbdbsr130_07 from l_sql
        declare cbdbsr130_07 cursor for pbdbsr130_07

        # Obtem sigla de veiculo
        let l_sql = "select atdvclsgl from datkveiculo where socvclcod = ?"
        prepare pbdbsr130_08 from l_sql
        declare cbdbsr130_08 cursor for pbdbsr130_08

        # Obtem nome do socorrista
        let l_sql = "select srrabvnom from datksrr where srrcoddig = ?"
        prepare pbdbsr130_09 from l_sql
        declare cbdbsr130_09 cursor for pbdbsr130_09
        
        # Obtem valores adicionais do pagamento do servico
        let l_sql = "select sum(socopgitmcst) from dbsmopgcst where dbsmopgcst.socopgnum = ? and dbsmopgcst.socopgitmnum = ? "
        prepare pbdbsr130_10 from l_sql
        declare cbdbsr130_10 cursor for pbdbsr130_10
        
end function
#-----------------------------#
 function bdbsr130_busca_path()
#-----------------------------#

        define l_datarq char(08)

        let l_datarq = extend(m_data, year to year),
                       extend(m_data, month to month),
                       extend(m_data, day to day)

        let m_path = null
        let m_path = f_path("DBS","LOG")
        if  m_path is null then
           let m_path = "."
        end if

        let m_path = m_path clipped,"/bdbsr130.log"
        call startlog(m_path)

        let m_path1 = f_path("DBS", "RELATO")
        if  m_path1 is null then
           let m_path1 = "."
        end if   
        
        let m_path2 = m_path1
        let m_path3 = m_path1
       #let m_path4 = m_path1
       #let m_path5 = m_path1
       #let m_path6 = m_path1
        
        let m_path1 = m_path1  clipped, "/RDBS130_ATENDIDOS", l_datarq, ".xls"
        let m_path2 = m_path2  clipped, "/RDBS130_ACIONADOS", l_datarq, ".xls"
        let m_path3 = m_path3  clipped, "/RDBS130_PAGOS", l_datarq, ".xls"
       #let m_path4 = m_path4  clipped, "/BDBSR130_ATENDIDOS_", l_datarq, ".txt"
       #let m_path5 = m_path5  clipped, "/BDBSR130_ACIONADOS_", l_datarq, ".txt"
       #let m_path6 = m_path6  clipped, "/BDBSR130_PAGOS_", l_datarq, ".txt"
        

 end function

function bdbsr130_envia_mail()

     define lr_mail record
             rem     char(50)
            ,des     char(10000)
            ,ccp     char(10000)
            ,cco     char(10000)
            ,ass     char(500)
            ,msg     char(32000)
            ,idr     char(20)
            ,tip     char(4)
     end record
     
      define lr_anexo record
           anexo1    char (300)
          ,anexo2    char (300)
          ,anexo3    char (300)
     end record
     
     define   lr_mail_erro   smallint
     define   cmd            char(500)
     define   l_destino      char(1500)
     define   l_sql1        char(1500)
     
     initialize lr_mail.*, lr_anexo.* to null

     let l_sql1 = " select relpamtxt  "
                  ,"   from igbmparam  "
                  ,"  where relsgl = ? "
     prepare pbdbsr130011 from l_sql1
     declare cbdbsr125011 cursor for pbdbsr130011
 

     let lr_mail.ass = "Servicos Cartao e PSS ", m_data
     
     let cmd = "gzip -f ", m_path1
     run cmd
     let m_path1 = m_path1 clipped, ".gz"
     let lr_anexo.anexo1 = m_path1
     
     let cmd = "gzip -f ", m_path2
     run cmd    
     let m_path2 = m_path2 clipped, ".gz"
     let lr_anexo.anexo2 = m_path2
     
     let cmd = "gzip -f ", m_path3
     run cmd    
     let m_path3 = m_path3 clipped, ".gz"
     let lr_anexo.anexo3 = m_path3
      
     let lr_mail.rem = 'portosocorro@portoseguro.com.br'  
     let lr_mail.msg = 'BDBSR130' clipped
     let lr_mail.idr = 'P0603000' 
     let lr_mail.tip = 'text'
         
     open cbdbsr125011 using lr_mail.msg
     foreach cbdbsr125011 into l_destino  
     
        if lr_mail.des is null then
           let lr_mail.des = l_destino
        else
           let lr_mail.des = lr_mail.des clipped,',',l_destino
        end if
        
     end foreach
              
     let lr_mail_erro = ctx22g00_envia_email_anexos(lr_mail.*, lr_anexo.*)
     
     if  lr_mail_erro <> 0 then                             
         if  lr_mail_erro <> 99 then
             display "Erro ao enviar email(ctx22g00) - ", lr_mail_erro
         else
             display "Nao existe email cadastrado para o modulo - BDBSR130"
         end if
     end if
 
end function




#---------------------------------#
 function bdbsr130()
#---------------------------------#


define l_erro_envio  integer,
       pestip        char(1)
       
define lr_bdbsr130_proc record
   c24astcod    like datmligacao.c24astcod   ,
   atdsrvorg    like datmservico.atdsrvorg   ,
   atdsrvnum    like datmservico.atdsrvnum   ,
   atdsrvano    like datmservico.atdsrvano   ,
   atddat       like datmservico.atddat      ,
   atdhor       like datmservico.atdhor      ,
   atddatprg    like datmservico.atddatprg   ,
   atdhorprg    like datmservico.atdhorprg   ,
   nom          like datmservico.nom         ,
   cgccpfnum    like datrligcgccpf.cgccpfnum ,
   cgcord       like datrligcgccpf.cgcord    ,
   cgccpfdig    like datrligcgccpf.cgccpfdig ,
   brrnom       like datmlcl.brrnom          ,
   cidnom       like datmlcl.cidnom          ,
   ufdcod       like datmlcl.ufdcod          ,
   c24pbmcod    like datrsrvpbm.c24pbmcod    ,
   atddfttxt    like datmservico.atddfttxt   ,
   asitipcod    like datmservico.asitipcod   ,
   asitipabvdes like datkasitip.asitipabvdes ,
   socntzcod    like datmsrvre.socntzcod     ,
   socntzdes    like datksocntz.socntzdes    ,
   atdetpdat    like datmsrvacp.atdetpdat    ,
   atdetphor    like datmsrvacp.atdetphor    ,
   atdetpcod    like datmsrvacp.atdetpcod    ,
   pstcoddig    like datmsrvacp.pstcoddig    ,
   socvclcod    like datmsrvacp.socvclcod    ,
   srrcoddig    like datmsrvacp.srrcoddig    ,
   socfatpgtdat like dbsmopg.socfatpgtdat    ,
   socopgnum    like dbsmopg.socopgnum       ,
   socopgitmnum like dbsmopgitm.socopgitmnum ,
   socopgitmvlr like dbsmopgitm.socopgitmvlr ,
   socopgitmcst like dbsmopgitm.socopgitmvlr ,
   srvvlradc    like dbsmopgitm.socopgitmvlr ,
   c24astdes    like datkassunto.c24astdes   ,
   atdetpdes    like datketapa.atdetpdes     ,
   nomgrr       like dpaksocor.nomgrr        ,
   atdvclsgl    like datkveiculo.atdvclsgl   ,
   srrabvnom    like datksrr.srrabvnom       ,
   pestip       char(1)                      ,
   pesnom       like gsakpes.pesnom          ,
   pesnum       like gsakpes.pesnum          ,
   cliufdcod    like datmlcl.ufdcod          ,
   clicidnom    like datmlcl.cidnom          ,
   clibrrnom    like datmlcl.brrnom          ,
   clilgdtip    like datmlcl.lgdtip          ,
   clilgdnom    like datmlcl.lgdnom          ,
   clilgdnum    like datmlcl.lgdnum          ,
   clilgdcep    like datmlcl.lgdcep          ,
   clilgdcepcmp like datmlcl.lgdcepcmp       ,
   cliendcmp    like datmlcl.endcmp 
end record

# Atendimento abertos na data
display "Inicio Atendidos"
start report rep_bdbsr130_atendidos to m_path1
#start report rep_bdbsr130_atendidos_txt to m_path4

open cbdbsr130_01  using m_data
foreach cbdbsr130_01 into lr_bdbsr130_proc.c24astcod   ,
                          lr_bdbsr130_proc.atdsrvorg   ,
                          lr_bdbsr130_proc.atdsrvnum   ,
                          lr_bdbsr130_proc.atdsrvano   ,
                          lr_bdbsr130_proc.atddat      ,
                          lr_bdbsr130_proc.atdhor      ,
                          lr_bdbsr130_proc.atddatprg   ,
                          lr_bdbsr130_proc.atdhorprg   ,
                          lr_bdbsr130_proc.nom         ,
                          lr_bdbsr130_proc.cgccpfnum   ,
                          lr_bdbsr130_proc.cgcord      ,
                          lr_bdbsr130_proc.cgccpfdig   ,
                          lr_bdbsr130_proc.brrnom      ,
                          lr_bdbsr130_proc.cidnom      ,
                          lr_bdbsr130_proc.ufdcod      ,
                          lr_bdbsr130_proc.c24pbmcod   ,
                          lr_bdbsr130_proc.atddfttxt   ,
                          lr_bdbsr130_proc.asitipcod   ,
                          lr_bdbsr130_proc.asitipabvdes,
                          lr_bdbsr130_proc.socntzcod

    initialize lr_bdbsr130_proc.c24astdes to null
    # Busca descricao do assunto do servico
    open cbdbsr130_04 using lr_bdbsr130_proc.c24astcod
    fetch cbdbsr130_04 into lr_bdbsr130_proc.c24astdes
    close cbdbsr130_04

    initialize lr_bdbsr130_proc.socntzdes to null
    # Busca descricao da natureza do servico
    open cbdbsr130_05 using lr_bdbsr130_proc.socntzcod
    fetch cbdbsr130_05 into lr_bdbsr130_proc.socntzdes
    close cbdbsr130_05

    # Obtem informações do proponente
    if lr_bdbsr130_proc.cgcord = 0 then
    	let pestip = "F"
    else
    	let pestip = "J"
    end if
    call osgtf550_pesquisa_pesnum(pestip
                                 ,lr_bdbsr130_proc.cgccpfnum
                                 ,""         # pesnom
                                 ,""         # corsus
                                 ,""         # unfprdcod (Cartao Visa)
                                 ,""         # viginc
                                 ,""         # vigfnl 
                                 ,"")        # vigente
         returning m_status
    let lr_bdbsr130_proc.pesnom       = g_a_cliente[1].pesnom
    
    call osgtf550_pesquisa_pesnum_endereco(g_a_cliente[1].pesnum)
         returning m_status    
         
    let lr_bdbsr130_proc.pesnum       = g_a_cliente[1].pesnum      

    let lr_bdbsr130_proc.cliufdcod    = g_r_endereco.endufd   
    let lr_bdbsr130_proc.clicidnom    = g_r_endereco.endcid
    let lr_bdbsr130_proc.clibrrnom    = g_r_endereco.endbrr 
    let lr_bdbsr130_proc.clilgdtip    = g_r_endereco.endlgdtip
    let lr_bdbsr130_proc.clilgdnom    = g_r_endereco.endlgd
    let lr_bdbsr130_proc.clilgdnum    = g_r_endereco.endnum
    let lr_bdbsr130_proc.clilgdcep    = g_r_endereco.endcep
    let lr_bdbsr130_proc.clilgdcepcmp = g_r_endereco.endcepcmp
    let lr_bdbsr130_proc.cliendcmp    = g_r_endereco.endcmp


    output to report rep_bdbsr130_atendidos(lr_bdbsr130_proc.pesnum      ,
                                            lr_bdbsr130_proc.c24astcod   ,
                                            lr_bdbsr130_proc.atdsrvorg   ,
                                            lr_bdbsr130_proc.atdsrvnum   ,
                                            lr_bdbsr130_proc.atdsrvano   ,
                                            lr_bdbsr130_proc.atddat      ,
                                            lr_bdbsr130_proc.atdhor      ,
                                            lr_bdbsr130_proc.atddatprg   ,
                                            lr_bdbsr130_proc.atdhorprg   ,
                                            lr_bdbsr130_proc.nom         ,
                                            lr_bdbsr130_proc.cgccpfnum   ,
                                            lr_bdbsr130_proc.cgcord      ,
                                            lr_bdbsr130_proc.cgccpfdig   ,
                                            lr_bdbsr130_proc.brrnom      ,
                                            lr_bdbsr130_proc.cidnom      ,
                                            lr_bdbsr130_proc.ufdcod      ,
                                            lr_bdbsr130_proc.c24pbmcod   ,
                                            lr_bdbsr130_proc.atddfttxt   ,
                                            lr_bdbsr130_proc.asitipcod   ,
                                            lr_bdbsr130_proc.asitipabvdes,
                                            lr_bdbsr130_proc.socntzcod   ,
                                            lr_bdbsr130_proc.socntzdes   ,
                                            lr_bdbsr130_proc.c24astdes   ,
                                            lr_bdbsr130_proc.pesnom      ,
                                            lr_bdbsr130_proc.cliufdcod   ,
                                            lr_bdbsr130_proc.clicidnom   ,
                                            lr_bdbsr130_proc.clibrrnom   ,
                                            lr_bdbsr130_proc.clilgdtip   ,
                                            lr_bdbsr130_proc.clilgdnom   ,
                                            lr_bdbsr130_proc.clilgdnum   ,
                                            lr_bdbsr130_proc.clilgdcep   ,
                                            lr_bdbsr130_proc.clilgdcepcmp,
                                            lr_bdbsr130_proc.cliendcmp   )
                                            
   #output to report rep_bdbsr130_atendidos_txt(lr_bdbsr130_proc.pesnum  ,
   #                                        lr_bdbsr130_proc.c24astcod   ,
   #                                        lr_bdbsr130_proc.atdsrvorg   ,
   #                                        lr_bdbsr130_proc.atdsrvnum   ,
   #                                        lr_bdbsr130_proc.atdsrvano   ,
   #                                        lr_bdbsr130_proc.atddat      ,
   #                                        lr_bdbsr130_proc.atdhor      ,
   #                                        lr_bdbsr130_proc.atddatprg   ,
   #                                        lr_bdbsr130_proc.atdhorprg   ,
   #                                        lr_bdbsr130_proc.nom         ,
   #                                        lr_bdbsr130_proc.cgccpfnum   ,
   #                                        lr_bdbsr130_proc.cgcord      ,
   #                                        lr_bdbsr130_proc.cgccpfdig   ,
   #                                        lr_bdbsr130_proc.brrnom      ,
   #                                        lr_bdbsr130_proc.cidnom      ,
   #                                        lr_bdbsr130_proc.ufdcod      ,
   #                                        lr_bdbsr130_proc.c24pbmcod   ,
   #                                        lr_bdbsr130_proc.atddfttxt   ,
   #                                        lr_bdbsr130_proc.asitipcod   ,
   #                                        lr_bdbsr130_proc.asitipabvdes,
   #                                        lr_bdbsr130_proc.socntzcod   ,
   #                                        lr_bdbsr130_proc.socntzdes   ,
   #                                        lr_bdbsr130_proc.c24astdes   ,
   #                                        lr_bdbsr130_proc.pesnom      ,
   #                                        lr_bdbsr130_proc.cliufdcod   ,
   #                                        lr_bdbsr130_proc.clicidnom   ,
   #                                        lr_bdbsr130_proc.clibrrnom   ,
   #                                        lr_bdbsr130_proc.clilgdtip   ,
   #                                        lr_bdbsr130_proc.clilgdnom   ,
   #                                        lr_bdbsr130_proc.clilgdnum   ,
   #                                        lr_bdbsr130_proc.clilgdcep   ,
   #                                         lr_bdbsr130_proc.clilgdcepcmp,       
   #                                         lr_bdbsr130_proc.cliendcmp   )       
                                            
end foreach                                 
                                            
finish report rep_bdbsr130_atendidos      
#finish report rep_bdbsr130_atendidos_txt  
display "Termino Atendidos"
                                            
# Atendimento acionados na data             
start report rep_bdbsr130_acionados to m_path2
#start report rep_bdbsr130_acionados_txt to m_path5

open cbdbsr130_02 using m_data
foreach cbdbsr130_02 into lr_bdbsr130_proc.c24astcod   ,
                          lr_bdbsr130_proc.atdsrvorg   ,
                          lr_bdbsr130_proc.atdsrvnum   ,
                          lr_bdbsr130_proc.atdsrvano   ,
                          lr_bdbsr130_proc.atddat      ,
                          lr_bdbsr130_proc.atdhor      ,
                          lr_bdbsr130_proc.atddatprg   ,
                          lr_bdbsr130_proc.atdhorprg   ,
                          lr_bdbsr130_proc.nom         ,
                          lr_bdbsr130_proc.cgccpfnum   ,
                          lr_bdbsr130_proc.cgcord      ,
                          lr_bdbsr130_proc.cgccpfdig   ,
                          lr_bdbsr130_proc.brrnom      ,
                          lr_bdbsr130_proc.cidnom      ,
                          lr_bdbsr130_proc.ufdcod      ,
                          lr_bdbsr130_proc.c24pbmcod   ,
                          lr_bdbsr130_proc.atddfttxt   ,
                          lr_bdbsr130_proc.asitipcod   ,
                          lr_bdbsr130_proc.asitipabvdes,
                          lr_bdbsr130_proc.socntzcod   ,
                          lr_bdbsr130_proc.atdetpdat   ,
                          lr_bdbsr130_proc.atdetphor   ,
                          lr_bdbsr130_proc.atdetpcod   ,
                          lr_bdbsr130_proc.pstcoddig   ,
                          lr_bdbsr130_proc.socvclcod   ,
                          lr_bdbsr130_proc.srrcoddig


    initialize lr_bdbsr130_proc.c24astdes to null
    # Busca descricao do assunto do servico
    open cbdbsr130_04 using lr_bdbsr130_proc.c24astcod
    fetch cbdbsr130_04 into lr_bdbsr130_proc.c24astdes
    close cbdbsr130_04

    initialize lr_bdbsr130_proc.socntzdes to null
    # Busca descricao da natureza do servico
    open cbdbsr130_05 using lr_bdbsr130_proc.socntzcod
    fetch cbdbsr130_05 into lr_bdbsr130_proc.socntzdes
    close cbdbsr130_05

    initialize lr_bdbsr130_proc.atdetpdes to null
    # Busca descricao da etapa do servico
    open cbdbsr130_06 using lr_bdbsr130_proc.atdetpcod
    fetch cbdbsr130_06 into lr_bdbsr130_proc.atdetpdes
    close cbdbsr130_06

    initialize lr_bdbsr130_proc.nomgrr to null
    # Busca nome de gerra do prestador do servico
    open cbdbsr130_07 using lr_bdbsr130_proc.pstcoddig
    fetch cbdbsr130_07 into lr_bdbsr130_proc.nomgrr
    close cbdbsr130_07

    initialize lr_bdbsr130_proc.atdvclsgl to null
    # Busca sigla do veiculo que atendeu o servico
    open cbdbsr130_08 using lr_bdbsr130_proc.socvclcod
    fetch cbdbsr130_08 into lr_bdbsr130_proc.atdvclsgl
    close cbdbsr130_08

    initialize lr_bdbsr130_proc.srrabvnom to null
    # Busca nome do socorrista que atendeu o servico
    open cbdbsr130_09 using lr_bdbsr130_proc.srrcoddig
    fetch cbdbsr130_09 into lr_bdbsr130_proc.srrabvnom
    close cbdbsr130_09

    # Obtem informações do proponente
    if lr_bdbsr130_proc.cgcord = 0 then
    	let pestip = "F"
    else
    	let pestip = "J"
    end if
    call osgtf550_pesquisa_pesnum(pestip
                                 ,lr_bdbsr130_proc.cgccpfnum
                                 ,""         # pesnom
                                 ,""         # corsus
                                 ,""         # unfprdcod (Cartao Visa)
                                 ,""         # viginc
                                 ,""         # vigfnl 
                                 ,"")        # vigente
         returning m_status
    let lr_bdbsr130_proc.pesnom       = g_a_cliente[1].pesnom
    
    call osgtf550_pesquisa_pesnum_endereco(g_a_cliente[1].pesnum)
         returning m_status    
         
    let lr_bdbsr130_proc.pesnum       = g_a_cliente[1].pesnum    

    let lr_bdbsr130_proc.cliufdcod    = g_r_endereco.endufd   
    let lr_bdbsr130_proc.clicidnom    = g_r_endereco.endcid
    let lr_bdbsr130_proc.clibrrnom    = g_r_endereco.endbrr 
    let lr_bdbsr130_proc.clilgdtip    = g_r_endereco.endlgdtip
    let lr_bdbsr130_proc.clilgdnom    = g_r_endereco.endlgd
    let lr_bdbsr130_proc.clilgdnum    = g_r_endereco.endnum
    let lr_bdbsr130_proc.clilgdcep    = g_r_endereco.endcep
    let lr_bdbsr130_proc.clilgdcepcmp = g_r_endereco.endcepcmp
    let lr_bdbsr130_proc.cliendcmp    = g_r_endereco.endcmp

    output to report rep_bdbsr130_acionados(lr_bdbsr130_proc.pesnum      ,
                                            lr_bdbsr130_proc.c24astcod   ,
                                            lr_bdbsr130_proc.atdsrvorg   ,
                                            lr_bdbsr130_proc.atdsrvnum   ,
                                            lr_bdbsr130_proc.atdsrvano   ,
                                            lr_bdbsr130_proc.atddat      ,
                                            lr_bdbsr130_proc.atdhor      ,
                                            lr_bdbsr130_proc.atddatprg   ,
                                            lr_bdbsr130_proc.atdhorprg   ,
                                            lr_bdbsr130_proc.nom         ,
                                            lr_bdbsr130_proc.cgccpfnum   ,
                                            lr_bdbsr130_proc.cgcord      ,
                                            lr_bdbsr130_proc.cgccpfdig   ,
                                            lr_bdbsr130_proc.brrnom      ,
                                            lr_bdbsr130_proc.cidnom      ,
                                            lr_bdbsr130_proc.ufdcod      ,
                                            lr_bdbsr130_proc.c24pbmcod   ,
                                            lr_bdbsr130_proc.atddfttxt   ,
                                            lr_bdbsr130_proc.asitipcod   ,
                                            lr_bdbsr130_proc.asitipabvdes,
                                            lr_bdbsr130_proc.socntzcod   ,
                                            lr_bdbsr130_proc.socntzdes   ,
                                            lr_bdbsr130_proc.c24astdes   ,
                                            lr_bdbsr130_proc.pesnom      ,
                                            lr_bdbsr130_proc.cliufdcod   ,
                                            lr_bdbsr130_proc.clicidnom   ,
                                            lr_bdbsr130_proc.clibrrnom   ,
                                            lr_bdbsr130_proc.clilgdtip   ,
                                            lr_bdbsr130_proc.clilgdnom   ,
                                            lr_bdbsr130_proc.clilgdnum   ,
                                            lr_bdbsr130_proc.clilgdcep   ,
                                            lr_bdbsr130_proc.clilgdcepcmp,
                                            lr_bdbsr130_proc.cliendcmp   ,                                            lr_bdbsr130_proc.atdetpdat   ,
                                            lr_bdbsr130_proc.atdetphor   ,
                                            lr_bdbsr130_proc.atdetpcod   ,
                                            lr_bdbsr130_proc.atdetpdes   ,
                                            lr_bdbsr130_proc.pstcoddig   ,
                                            lr_bdbsr130_proc.nomgrr      ,
                                            lr_bdbsr130_proc.socvclcod   ,
                                            lr_bdbsr130_proc.atdvclsgl   ,
                                            lr_bdbsr130_proc.srrcoddig   ,
                                            lr_bdbsr130_proc.srrabvnom   )
                                            
   #output to report rep_bdbsr130_acionados_txt(lr_bdbsr130_proc.pesnum  ,
   #                                        lr_bdbsr130_proc.c24astcod   ,
   #                                        lr_bdbsr130_proc.atdsrvorg   ,
   #                                        lr_bdbsr130_proc.atdsrvnum   ,
   #                                        lr_bdbsr130_proc.atdsrvano   ,
   #                                        lr_bdbsr130_proc.atddat      ,
   #                                        lr_bdbsr130_proc.atdhor      ,
   #                                        lr_bdbsr130_proc.atddatprg   ,
   #                                        lr_bdbsr130_proc.atdhorprg   ,
   #                                        lr_bdbsr130_proc.nom         ,
   #                                        lr_bdbsr130_proc.cgccpfnum   ,
   #                                        lr_bdbsr130_proc.cgcord      ,
   #                                        lr_bdbsr130_proc.cgccpfdig   ,
   #                                        lr_bdbsr130_proc.brrnom      ,
   #                                        lr_bdbsr130_proc.cidnom      ,
   #                                        lr_bdbsr130_proc.ufdcod      ,
   #                                        lr_bdbsr130_proc.c24pbmcod   ,
   #                                        lr_bdbsr130_proc.atddfttxt   ,
   #                                        lr_bdbsr130_proc.asitipcod   ,
   #                                        lr_bdbsr130_proc.asitipabvdes,
   #                                        lr_bdbsr130_proc.socntzcod   ,
   #                                        lr_bdbsr130_proc.socntzdes   ,
   #                                        lr_bdbsr130_proc.c24astdes   ,
   #                                        lr_bdbsr130_proc.pesnom      ,
   #                                        lr_bdbsr130_proc.cliufdcod   ,
   #                                        lr_bdbsr130_proc.clicidnom   ,
   #                                        lr_bdbsr130_proc.clibrrnom   ,
   #                                        lr_bdbsr130_proc.clilgdtip   ,
   #                                        lr_bdbsr130_proc.clilgdnom   ,
   #                                        lr_bdbsr130_proc.clilgdnum   ,
   #                                        lr_bdbsr130_proc.clilgdcep   ,
   #                                        lr_bdbsr130_proc.clilgdcepcmp,
   #                                        lr_bdbsr130_proc.cliendcmp   ,                                            lr_bdbsr130_proc.atdetpdat   ,
   #                                        lr_bdbsr130_proc.atdetphor   ,
   #                                        lr_bdbsr130_proc.atdetpcod   ,
   #                                        lr_bdbsr130_proc.atdetpdes   ,
   #                                        lr_bdbsr130_proc.pstcoddig   ,
   #                                        lr_bdbsr130_proc.nomgrr      ,
   #                                        lr_bdbsr130_proc.socvclcod   ,
   #                                        lr_bdbsr130_proc.atdvclsgl   ,
   #                                        lr_bdbsr130_proc.srrcoddig   ,
   #                                        lr_bdbsr130_proc.srrabvnom   )

end foreach

finish report rep_bdbsr130_acionados
#finish report rep_bdbsr130_acionados_txt
display "Termino Atendidos"

# Atendimento pagos na data
start report rep_bdbsr130_pagos to m_path3
#start report rep_bdbsr130_pagos_txt to m_path6

open cbdbsr130_03 using m_data
foreach cbdbsr130_03 into lr_bdbsr130_proc.c24astcod   ,
                          lr_bdbsr130_proc.atdsrvorg   ,
                          lr_bdbsr130_proc.atdsrvnum   ,
                          lr_bdbsr130_proc.atdsrvano   ,
                          lr_bdbsr130_proc.atddat      ,
                          lr_bdbsr130_proc.atdhor      ,
                          lr_bdbsr130_proc.atddatprg   ,
                          lr_bdbsr130_proc.atdhorprg   ,
                          lr_bdbsr130_proc.nom         ,
                          lr_bdbsr130_proc.cgccpfnum   ,
                          lr_bdbsr130_proc.cgcord      ,
                          lr_bdbsr130_proc.cgccpfdig   ,
                          lr_bdbsr130_proc.brrnom      ,
                          lr_bdbsr130_proc.cidnom      ,
                          lr_bdbsr130_proc.ufdcod      ,
                          lr_bdbsr130_proc.c24pbmcod   ,
                          lr_bdbsr130_proc.atddfttxt   ,
                          lr_bdbsr130_proc.asitipcod   ,
                          lr_bdbsr130_proc.asitipabvdes,
                          lr_bdbsr130_proc.socntzcod   ,
                          lr_bdbsr130_proc.pstcoddig   ,
                          lr_bdbsr130_proc.socfatpgtdat,
                          lr_bdbsr130_proc.socopgnum   ,
                          lr_bdbsr130_proc.socopgitmnum,
                          lr_bdbsr130_proc.socopgitmvlr

    initialize lr_bdbsr130_proc.c24astdes to null
    # Busca descricao do assunto do servico
    open cbdbsr130_04 using lr_bdbsr130_proc.c24astcod
    fetch cbdbsr130_04 into lr_bdbsr130_proc.c24astdes
    close cbdbsr130_04

    initialize lr_bdbsr130_proc.socntzdes to null
    # Busca descricao da natureza do servico
    open cbdbsr130_05 using lr_bdbsr130_proc.socntzcod
    fetch cbdbsr130_05 into lr_bdbsr130_proc.socntzdes
    close cbdbsr130_05

    initialize lr_bdbsr130_proc.nomgrr to null
    # Busca nome de gerra do prestador do servico
    open cbdbsr130_07 using lr_bdbsr130_proc.pstcoddig
    fetch cbdbsr130_07 into lr_bdbsr130_proc.nomgrr
    close cbdbsr130_07

    initialize lr_bdbsr130_proc.srvvlradc to null
    # Busca valor pago para o servico
    open cbdbsr130_10 using lr_bdbsr130_proc.socopgnum,
                            lr_bdbsr130_proc.socopgitmnum
    fetch cbdbsr130_10 into lr_bdbsr130_proc.srvvlradc
    close cbdbsr130_10

    # Obtem informações do proponente
    if lr_bdbsr130_proc.cgcord = 0 then
    	let pestip = "F"
    else
    	let pestip = "J"
    end if
    call osgtf550_pesquisa_pesnum(pestip
                                 ,lr_bdbsr130_proc.cgccpfnum
                                 ,""         # pesnom
                                 ,""         # corsus
                                 ,""         # unfprdcod (Cartao Visa)
                                 ,""         # viginc
                                 ,""         # vigfnl 
                                 ,"")        # vigente
         returning m_status
    let lr_bdbsr130_proc.pesnom       = g_a_cliente[1].pesnom
    
    call osgtf550_pesquisa_pesnum_endereco(g_a_cliente[1].pesnum)
         returning m_status    
         
    let lr_bdbsr130_proc.pesnum       = g_a_cliente[1].pesnum    

    let lr_bdbsr130_proc.cliufdcod    = g_r_endereco.endufd   
    let lr_bdbsr130_proc.clicidnom    = g_r_endereco.endcid
    let lr_bdbsr130_proc.clibrrnom    = g_r_endereco.endbrr 
    let lr_bdbsr130_proc.clilgdtip    = g_r_endereco.endlgdtip
    let lr_bdbsr130_proc.clilgdnom    = g_r_endereco.endlgd
    let lr_bdbsr130_proc.clilgdnum    = g_r_endereco.endnum
    let lr_bdbsr130_proc.clilgdcep    = g_r_endereco.endcep
    let lr_bdbsr130_proc.clilgdcepcmp = g_r_endereco.endcepcmp
    let lr_bdbsr130_proc.cliendcmp    = g_r_endereco.endcmp

    output to report rep_bdbsr130_pagos(lr_bdbsr130_proc.pesnum          ,
                                            lr_bdbsr130_proc.c24astcod   ,
                                            lr_bdbsr130_proc.atdsrvorg   ,
                                            lr_bdbsr130_proc.atdsrvnum   ,
                                            lr_bdbsr130_proc.atdsrvano   ,
                                            lr_bdbsr130_proc.atddat      ,
                                            lr_bdbsr130_proc.atdhor      ,
                                            lr_bdbsr130_proc.atddatprg   ,
                                            lr_bdbsr130_proc.atdhorprg   ,
                                            lr_bdbsr130_proc.nom         ,
                                            lr_bdbsr130_proc.cgccpfnum   ,
                                            lr_bdbsr130_proc.cgcord      ,
                                            lr_bdbsr130_proc.cgccpfdig   ,
                                            lr_bdbsr130_proc.brrnom      ,
                                            lr_bdbsr130_proc.cidnom      ,
                                            lr_bdbsr130_proc.ufdcod      ,
                                            lr_bdbsr130_proc.c24pbmcod   ,
                                            lr_bdbsr130_proc.atddfttxt   ,
                                            lr_bdbsr130_proc.asitipcod   ,
                                            lr_bdbsr130_proc.asitipabvdes,
                                            lr_bdbsr130_proc.socntzcod   ,
                                            lr_bdbsr130_proc.socntzdes   ,
                                            lr_bdbsr130_proc.c24astdes   ,
                                            lr_bdbsr130_proc.pesnom      ,
                                            lr_bdbsr130_proc.cliufdcod   ,
                                            lr_bdbsr130_proc.clicidnom   ,
                                            lr_bdbsr130_proc.clibrrnom   ,
                                            lr_bdbsr130_proc.clilgdtip   ,
                                            lr_bdbsr130_proc.clilgdnom   ,
                                            lr_bdbsr130_proc.clilgdnum   ,
                                            lr_bdbsr130_proc.clilgdcep   ,
                                            lr_bdbsr130_proc.clilgdcepcmp,
                                            lr_bdbsr130_proc.cliendcmp   ,                                            lr_bdbsr130_proc.pstcoddig   ,
                                            lr_bdbsr130_proc.nomgrr      ,
                                            lr_bdbsr130_proc.socfatpgtdat,
                                            lr_bdbsr130_proc.socopgnum   ,
                                            lr_bdbsr130_proc.socopgitmnum,
                                            lr_bdbsr130_proc.socopgitmvlr,
                                            lr_bdbsr130_proc.srvvlradc)
                                            
   #output to report rep_bdbsr130_pagos_txt(lr_bdbsr130_proc.pesnum      ,
   #                                        lr_bdbsr130_proc.c24astcod   ,
   #                                        lr_bdbsr130_proc.atdsrvorg   ,
   #                                        lr_bdbsr130_proc.atdsrvnum   ,
   #                                        lr_bdbsr130_proc.atdsrvano   ,
   #                                        lr_bdbsr130_proc.atddat      ,
   #                                        lr_bdbsr130_proc.atdhor      ,
   #                                        lr_bdbsr130_proc.atddatprg   ,
   #                                        lr_bdbsr130_proc.atdhorprg   ,
   #                                        lr_bdbsr130_proc.nom         ,
   #                                        lr_bdbsr130_proc.cgccpfnum   ,
   #                                        lr_bdbsr130_proc.cgcord      ,
   #                                        lr_bdbsr130_proc.cgccpfdig   ,
   #                                        lr_bdbsr130_proc.brrnom      ,
   #                                        lr_bdbsr130_proc.cidnom      ,
   #                                        lr_bdbsr130_proc.ufdcod      ,
   #                                        lr_bdbsr130_proc.c24pbmcod   ,
   #                                        lr_bdbsr130_proc.atddfttxt   ,
   #                                        lr_bdbsr130_proc.asitipcod   ,
   #                                        lr_bdbsr130_proc.asitipabvdes,
   #                                        lr_bdbsr130_proc.socntzcod   ,
   #                                        lr_bdbsr130_proc.socntzdes   ,
   #                                        lr_bdbsr130_proc.c24astdes   ,
   #                                        lr_bdbsr130_proc.pesnom      ,
   #                                        lr_bdbsr130_proc.cliufdcod   ,
   #                                        lr_bdbsr130_proc.clicidnom   ,
   #                                        lr_bdbsr130_proc.clibrrnom   ,
   #                                        lr_bdbsr130_proc.clilgdtip   ,
   #                                        lr_bdbsr130_proc.clilgdnom   ,
   #                                        lr_bdbsr130_proc.clilgdnum   ,
   #                                        lr_bdbsr130_proc.clilgdcep   ,
   #                                        lr_bdbsr130_proc.clilgdcepcmp,
   #                                        lr_bdbsr130_proc.cliendcmp   ,                                            lr_bdbsr130_proc.pstcoddig   ,
   #                                        lr_bdbsr130_proc.nomgrr      ,
   #                                        lr_bdbsr130_proc.socfatpgtdat,
   #                                        lr_bdbsr130_proc.socopgnum   ,
   #                                        lr_bdbsr130_proc.socopgitmnum,
   #                                        lr_bdbsr130_proc.socopgitmvlr,
   #                                        lr_bdbsr130_proc.srvvlradc)

end foreach

finish report rep_bdbsr130_pagos
#finish report rep_bdbsr130_pagos_txt
display "Termino Atendidos"

end function

#---------------------------------------#
 report rep_bdbsr130_atendidos(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp 
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define l_cont         smallint
   define l_cont_aux     smallint
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    07

   format

       first page header

           print "CODIGO_CLIENTE",           ASCII(09),
                 "ASSUNTO_CODIGO",           ASCII(09),
                 "ASSUNTO_DESCRICAO",        ASCII(09),
                 "SERVICO_ORIGEM",           ASCII(09),
                 "SERVICO_NUMERO",           ASCII(09),
                 "ATENDIMENTO_DATA",         ASCII(09),
                 "ATENDIMENTO_HORA",         ASCII(09),
                 "PROGRAMACAO_DATA",         ASCII(09),
                 "PROGRAMACAO_HORA",         ASCII(09),
                 "SOLICITANTE_NOME",         ASCII(09),
                 "PROPONENTE_CPF/CGC",       ASCII(09),
                 "PROPONENTE_NOME",          ASCII(09),
                 "PROPONENTE_UF",            ASCII(09),
                 "PROPONENTE_CIDADE",        ASCII(09),
                 "PROPONENTE_BAIRRO",        ASCII(09),
                 "PROPONENTE_LOGADOURO",     ASCII(09),
                 "PROPONENTE_CEP",           ASCII(09),
                 "OCORRENCIA_BAIRRO",        ASCII(09),
                 "OCORRENCIA_CIDADE",        ASCII(09),
                 "OCORRENCIA_UF",            ASCII(09),
                 "PROBLEMA_CODIGO",          ASCII(09),
                 "PROBLEMA_DESCRICAO",       ASCII(09),
                 "ASSISTENCIA_CODIGO",       ASCII(09),
                 "ASSISTENCIA_DESCRICAO",    ASCII(09),
                 "NATUREZA_CODIGO",          ASCII(09),
                 "NATUREZA_DESCRICAO",       ASCII(09)

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0   
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##      
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
           ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if   
              
         

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);
       
        if lr_report.cgcord > 0 then # CGC
           print lr_report.cgccpfnum    using "&&&&&&&&&"
                ,lr_report.cgcord       using "&&&&"
                ,lr_report.cgccpfdig    using "&&", ASCII(09);
        else
          print lr_report.cgccpfnum    using "&&&&&&&&&" 
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        end if

           print lr_report.pesnom                ,ASCII(09);
           print lr_report.cliufdcod             ,ASCII(09);
           print lr_report.clicidnom clipped     ,ASCII(09);
           print lr_report.clibrrnom clipped     ,ASCII(09);
           print lr_report.clilgdtip clipped, " ",
                 lr_report.clilgdnom clipped, ", ",
                 lr_report.clilgdnum using "<<<<<&", " ",
                 lr_report.cliendcmp             ,ASCII(09);
           print lr_report.clilgdcep using "&&&&&", "-",
                 lr_report.clilgdcepcmp using "&&&" ,ASCII(09);

           print lr_report.brrnom clipped        ,ASCII(09);
           print lr_report.cidnom clipped        ,ASCII(09);
           print lr_report.ufdcod clipped        ,ASCII(09);
           print lr_report.c24pbmcod             ,ASCII(09);
           print lr_report.atddfttxt clipped     ,ASCII(09);
           print lr_report.asitipcod             ,ASCII(09);
           print lr_report.asitipabvdes clipped  ,ASCII(09);
           print lr_report.socntzcod             ,ASCII(09);
           print lr_report.socntzdes clipped     ,ASCII(09)

end report


#---------------------------------------#
 report rep_bdbsr130_acionados(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp          ,
      atdetpdat    like datmsrvacp.atdetpdat    ,
      atdetphor    like datmsrvacp.atdetphor    ,
      atdetpcod    like datketapa.atdetpcod     ,
      atdetpdes    like datketapa.atdetpdes     ,
      pstcoddig    like dpaksocor.pstcoddig     ,
      nomgrr       like dpaksocor.nomgrr        ,
      socvclcod    like datkveiculo.socvclcod   ,
      atdvclsgl    like datkveiculo.atdvclsgl   ,
      srrcoddig    like datksrr.srrcoddig       ,
      srrabvnom    like datksrr.srrabvnom
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define l_cont         integer
   define l_cont_aux     integer
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
  
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    07

   format

       first page header

           print "CODIGO_CLIENTE",           ASCII(09),
                 "ASSUNTO_CODIGO",           ASCII(09),
                 "ASSUNTO_DESCRICAO",        ASCII(09),
                 "SERVICO_ORIGEM",           ASCII(09),
                 "SERVICO_NUMERO",           ASCII(09),
                 "ATENDIMENTO_DATA",         ASCII(09),
                 "ATENDIMENTO_HORA",         ASCII(09),
                 "PROGRAMACAO_DATA",         ASCII(09),
                 "PROGRAMACAO_HORA",         ASCII(09),
                 "SOLICITANTE_NOME",         ASCII(09),
                 "PROPONENTE_CPF/CGC",       ASCII(09),
                 "PROPONENTE_NOME",          ASCII(09),
                 "PROPONENTE_UF",            ASCII(09),
                 "PROPONENTE_CIDADE",        ASCII(09),
                 "PROPONENTE_BAIRRO",        ASCII(09),
                 "PROPONENTE_LOGADOURO",     ASCII(09),
                 "PROPONENTE_CEP",           ASCII(09),
                 "OCORRENCIA_BAIRRO",        ASCII(09),
                 "OCORRENCIA_CIDADE",        ASCII(09),
                 "OCORRENCIA_UF",            ASCII(09),
                 "PROBLEMA_CODIGO",          ASCII(09),
                 "PROBLEMA_DESCRICAO",       ASCII(09),
                 "ASSISTENCIA_CODIGO",       ASCII(09),
                 "ASSISTENCIA_DESCRICAO",    ASCII(09),
                 "NATUREZA_CODIGO",          ASCII(09),
                 "NATUREZA_DESCRICAO",       ASCII(09),
                 "ETAPA_DATA",               ASCII(09),
                 "ETAPA_HORA",               ASCII(09),
                 "ETAPA_CODIGO",             ASCII(09),
                 "ETAPA_DESCRICAO",          ASCII(09),
                 "PRESTADOR_CODIGO",         ASCII(09),
                 "PRESTADOR_NOME",           ASCII(09),
                 "VEICULO_CODIGO",           ASCII(09),
                 "VEICULO_SIGLA",            ASCII(09),
                 "SOCORRISTA_CODIGO",        ASCII(09),
                 "SOCORRISTA_NOME",          ASCII(09)

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0   
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
          ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if           
           

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);

           if lr_report.cgcord > 0 then # CGC
              print lr_report.cgccpfnum    using "&&&&&&&&&/"
                   ,lr_report.cgcord       using "&&&&", "-"
                   ,lr_report.cgccpfdig    using "&&", ASCII(09);
           else
              print lr_report.cgccpfnum    using "&&&&&&&&&", "-"
                   ,lr_report.cgccpfdig    using "&&", ASCII(09);
           end if

           print lr_report.pesnom                ,ASCII(09);
           print lr_report.cliufdcod             ,ASCII(09);
           print lr_report.clicidnom clipped     ,ASCII(09);
           print lr_report.clibrrnom clipped     ,ASCII(09);
           print lr_report.clilgdtip clipped, " ",
                 lr_report.clilgdnom clipped, ", ",
                 lr_report.clilgdnum using "<<<<<&", " ",
                 lr_report.cliendcmp             ,ASCII(09);
           print lr_report.clilgdcep using "&&&&&", "-",
                 lr_report.clilgdcepcmp using "&&&" ,ASCII(09);

           print lr_report.brrnom clipped        ,ASCII(09);
           print lr_report.cidnom clipped        ,ASCII(09);
           print lr_report.ufdcod clipped        ,ASCII(09);
           print lr_report.c24pbmcod             ,ASCII(09);
           print lr_report.atddfttxt clipped     ,ASCII(09);
           print lr_report.asitipcod             ,ASCII(09);
           print lr_report.asitipabvdes clipped  ,ASCII(09);
           print lr_report.socntzcod             ,ASCII(09);
           print lr_report.socntzdes clipped     ,ASCII(09);
           print lr_report.atdetpdat             ,ASCII(09);
           print lr_report.atdetphor             ,ASCII(09);
           print lr_report.atdetpcod             ,ASCII(09);
           print lr_report.atdetpdes clipped     ,ASCII(09);
           print lr_report.pstcoddig             ,ASCII(09);
           print lr_report.nomgrr    clipped     ,ASCII(09);
           print lr_report.socvclcod             ,ASCII(09);
           print lr_report.atdvclsgl clipped     ,ASCII(09);
           print lr_report.srrcoddig             ,ASCII(09);
           print lr_report.srrabvnom clipped     ,ASCII(09)

end report


#---------------------------------------#
 report rep_bdbsr130_pagos(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp          ,
      pstcoddig    like dpaksocor.pstcoddig     ,
      nomgrr       like dpaksocor.nomgrr        ,
      socfatpgtdat like dbsmopg.socfatpgtdat    ,
      socopgnum    like dbsmopg.socopgnum       ,
      socopgitmnum like dbsmopgitm.socopgitmnum ,
      socopgitmvlr like dbsmopgitm.socopgitmvlr ,
      srvvlradc    like dbsmopgitm.socopgitmvlr
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define srvvlr  like dbsmopgitm.socopgitmvlr
   
   define l_cont         integer
   define l_cont_aux     integer
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
   
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    07

   format

       first page header

           print "CODIGO_CLIENTE",           ASCII(09),
                 "ASSUNTO_CODIGO",           ASCII(09),
                 "ASSUNTO_DESCRICAO",        ASCII(09),
                 "SERVICO_ORIGEM",           ASCII(09),
                 "SERVICO_NUMERO",           ASCII(09),
                 "ATENDIMENTO_DATA",         ASCII(09),
                 "ATENDIMENTO_HORA",         ASCII(09),
                 "PROGRAMACAO_DATA",         ASCII(09),
                 "PROGRAMACAO_HORA",         ASCII(09),
                 "SOLICITANTE_NOME",         ASCII(09),
                 "PROPONENTE_CPF/CGC",       ASCII(09),
                 "PROPONENTE_NOME",          ASCII(09),
                 "PROPONENTE_UF",            ASCII(09),
                 "PROPONENTE_CIDADE",        ASCII(09),
                 "PROPONENTE_BAIRRO",        ASCII(09),
                 "PROPONENTE_LOGADOURO",     ASCII(09),
                 "PROPONENTE_CEP",           ASCII(09),
                 "OCORRENCIA_BAIRRO",        ASCII(09),
                 "OCORRENCIA_CIDADE",        ASCII(09),
                 "OCORRENCIA_UF",            ASCII(09),
                 "PROBLEMA_CODIGO",          ASCII(09),
                 "PROBLEMA_DESCRICAO",       ASCII(09),
                 "ASSISTENCIA_CODIGO",       ASCII(09),
                 "ASSISTENCIA_DESCRICAO",    ASCII(09),
                 "NATUREZA_CODIGO",          ASCII(09),
                 "NATUREZA_DESCRICAO",       ASCII(09),
                 "PRESTADOR_CODIGO",         ASCII(09),
                 "PRESTADOR_NOME",           ASCII(09),
                 "PAGAMENTO_DATA",           ASCII(09),
                 "PAGAMENTO_VALOR",          ASCII(09),
                 "OP_NUMERO",                ASCII(09),
                 "OP_ITEM",                  ASCII(09)

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
           ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if             
      

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);
        if lr_report.cgcord > 0 then # CGC
          print lr_report.cgccpfnum    using "&&&&&&&&&"
               ,lr_report.cgcord       using "&&&&"
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        else
          print lr_report.cgccpfnum    using "&&&&&&&&&"
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        end if
       print lr_report.pesnom                ,ASCII(09);
       print lr_report.cliufdcod             ,ASCII(09);
       print lr_report.clicidnom clipped     ,ASCII(09);
       print lr_report.clibrrnom clipped     ,ASCII(09);
       print lr_report.clilgdtip clipped, " ",
             lr_report.clilgdnom clipped, ", ",
             lr_report.clilgdnum using "<<<<<&", " ",
             lr_report.cliendcmp             ,ASCII(09);
       print lr_report.clilgdcep using "&&&&&",
             lr_report.clilgdcepcmp using "&&&" ,ASCII(09);
       print lr_report.brrnom clipped        ,ASCII(09);
       print lr_report.cidnom clipped        ,ASCII(09);
       print lr_report.ufdcod clipped        ,ASCII(09);
       print lr_report.c24pbmcod             ,ASCII(09);
       print lr_report.atddfttxt clipped     ,ASCII(09);
       print lr_report.asitipcod             ,ASCII(09);
       print lr_report.asitipabvdes clipped  ,ASCII(09);
       print lr_report.socntzcod             ,ASCII(09);
       print lr_report.socntzdes clipped     ,ASCII(09);
       print lr_report.pstcoddig             ,ASCII(09);
       print lr_report.nomgrr    clipped     ,ASCII(09);
       print lr_report.socfatpgtdat          ,ASCII(09);
        if lr_report.socopgitmvlr is null then
          let lr_report.socopgitmvlr = 0
       end if
       
       if lr_report.srvvlradc is null then
          let lr_report.srvvlradc = 0
       end if
       
       let srvvlr = lr_report.socopgitmvlr + lr_report.srvvlradc
       print srvvlr                          ,ASCII(09);
       print lr_report.socopgnum             ,ASCII(09);
       print lr_report.socopgitmnum          ,ASCII(09)
         

end report

#---------------------------------------#
 report rep_bdbsr130_atendidos_txt(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp 
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define l_cont         smallint
   define l_cont_aux     smallint
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    01

   format

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0   
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##      
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
           ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if   
              
         

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);
       
        if lr_report.cgcord > 0 then # CGC
           print lr_report.cgccpfnum    using "&&&&&&&&&"
                ,lr_report.cgcord       using "&&&&"
                ,lr_report.cgccpfdig    using "&&", ASCII(09);
        else
          print lr_report.cgccpfnum    using "&&&&&&&&&" 
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        end if

           print lr_report.pesnom                ,ASCII(09);
           print lr_report.cliufdcod             ,ASCII(09);
           print lr_report.clicidnom clipped     ,ASCII(09);
           print lr_report.clibrrnom clipped     ,ASCII(09);
           print lr_report.clilgdtip clipped, " ",
                 lr_report.clilgdnom clipped, ", ",
                 lr_report.clilgdnum using "<<<<<&", " ",
                 lr_report.cliendcmp             ,ASCII(09);
           print lr_report.clilgdcep using "&&&&&", "-",
                 lr_report.clilgdcepcmp using "&&&" ,ASCII(09);

           print lr_report.brrnom clipped        ,ASCII(09);
           print lr_report.cidnom clipped        ,ASCII(09);
           print lr_report.ufdcod clipped        ,ASCII(09);
           print lr_report.c24pbmcod             ,ASCII(09);
           print lr_report.atddfttxt clipped     ,ASCII(09);
           print lr_report.asitipcod             ,ASCII(09);
           print lr_report.asitipabvdes clipped  ,ASCII(09);
           print lr_report.socntzcod             ,ASCII(09);
           print lr_report.socntzdes clipped 

end report


#---------------------------------------#
 report rep_bdbsr130_acionados_txt(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp          ,
      atdetpdat    like datmsrvacp.atdetpdat    ,
      atdetphor    like datmsrvacp.atdetphor    ,
      atdetpcod    like datketapa.atdetpcod     ,
      atdetpdes    like datketapa.atdetpdes     ,
      pstcoddig    like dpaksocor.pstcoddig     ,
      nomgrr       like dpaksocor.nomgrr        ,
      socvclcod    like datkveiculo.socvclcod   ,
      atdvclsgl    like datkveiculo.atdvclsgl   ,
      srrcoddig    like datksrr.srrcoddig       ,
      srrabvnom    like datksrr.srrabvnom
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define l_cont         integer
   define l_cont_aux     integer
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
  
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    07

   format

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0   
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
          ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if           
           

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);

           if lr_report.cgcord > 0 then # CGC
              print lr_report.cgccpfnum    using "&&&&&&&&&/"
                   ,lr_report.cgcord       using "&&&&", "-"
                   ,lr_report.cgccpfdig    using "&&", ASCII(09);
           else
              print lr_report.cgccpfnum    using "&&&&&&&&&", "-"
                   ,lr_report.cgccpfdig    using "&&", ASCII(09);
           end if

           print lr_report.pesnom                ,ASCII(09);
           print lr_report.cliufdcod             ,ASCII(09);
           print lr_report.clicidnom clipped     ,ASCII(09);
           print lr_report.clibrrnom clipped     ,ASCII(09);
           print lr_report.clilgdtip clipped, " ",
                 lr_report.clilgdnom clipped, ", ",
                 lr_report.clilgdnum using "<<<<<&", " ",
                 lr_report.cliendcmp             ,ASCII(09);
           print lr_report.clilgdcep using "&&&&&", "-",
                 lr_report.clilgdcepcmp using "&&&" ,ASCII(09);

           print lr_report.brrnom clipped        ,ASCII(09);
           print lr_report.cidnom clipped        ,ASCII(09);
           print lr_report.ufdcod clipped        ,ASCII(09);
           print lr_report.c24pbmcod             ,ASCII(09);
           print lr_report.atddfttxt clipped     ,ASCII(09);
           print lr_report.asitipcod             ,ASCII(09);
           print lr_report.asitipabvdes clipped  ,ASCII(09);
           print lr_report.socntzcod             ,ASCII(09);
           print lr_report.socntzdes clipped     ,ASCII(09);
           print lr_report.atdetpdat             ,ASCII(09);
           print lr_report.atdetphor             ,ASCII(09);
           print lr_report.atdetpcod             ,ASCII(09);
           print lr_report.atdetpdes clipped     ,ASCII(09);
           print lr_report.pstcoddig             ,ASCII(09);
           print lr_report.nomgrr    clipped     ,ASCII(09);
           print lr_report.socvclcod             ,ASCII(09);
           print lr_report.atdvclsgl clipped     ,ASCII(09);
           print lr_report.srrcoddig             ,ASCII(09);
           print lr_report.srrabvnom clipped

end report


#---------------------------------------#
 report rep_bdbsr130_pagos_txt(lr_report)
#---------------------------------------#

   define lr_report     record
      pesnum       like gsakpes.pesnum          ,
      c24astcod    like datmligacao.c24astcod   ,
      atdsrvorg    like datmservico.atdsrvorg   ,
      atdsrvnum    like datmservico.atdsrvnum   ,
      atdsrvano    like datmservico.atdsrvano   ,
      atddat       like datmservico.atddat      ,
      atdhor       like datmservico.atdhor      ,
      atddatprg    like datmservico.atddatprg   ,
      atdhorprg    like datmservico.atdhorprg   ,
      nom          like datmservico.nom         ,
      cgccpfnum    like datrligcgccpf.cgccpfnum ,
      cgcord       like datrligcgccpf.cgcord    ,
      cgccpfdig    like datrligcgccpf.cgccpfdig ,
      brrnom       like datmlcl.brrnom          ,
      cidnom       like datmlcl.cidnom          ,
      ufdcod       like datmlcl.ufdcod          ,
      c24pbmcod    like datrsrvpbm.c24pbmcod    ,
      atddfttxt    like datmservico.atddfttxt   ,
      asitipcod    like datmservico.asitipcod   ,
      asitipabvdes like datkasitip.asitipabvdes ,
      socntzcod    like datmsrvre.socntzcod     ,
      socntzdes    like datksocntz.socntzdes    ,
      c24astdes    like datkassunto.c24astdes   ,
      pesnom       like gsakpes.pesnom          ,
      cliufdcod    like datmlcl.ufdcod          ,
      clicidnom    like datmlcl.cidnom          ,
      clibrrnom    like datmlcl.brrnom          ,
      clilgdtip    like datmlcl.lgdtip          ,
      clilgdnom    like datmlcl.lgdnom          ,
      clilgdnum    like datmlcl.lgdnum          ,
      clilgdcep    like datmlcl.lgdcep          ,
      clilgdcepcmp like datmlcl.lgdcepcmp       ,
      cliendcmp    like datmlcl.endcmp          ,
      pstcoddig    like dpaksocor.pstcoddig     ,
      nomgrr       like dpaksocor.nomgrr        ,
      socfatpgtdat like dbsmopg.socfatpgtdat    ,
      socopgnum    like dbsmopg.socopgnum       ,
      socopgitmnum like dbsmopgitm.socopgitmnum ,
      socopgitmvlr like dbsmopgitm.socopgitmvlr ,
      srvvlradc    like dbsmopgitm.socopgitmvlr
   end record

   define lr_cty08g00     record
          erro           smallint,
          mensagem       char(60),
          funnom         like isskfunc.funnom
   end record
   
   define srvvlr  like dbsmopgitm.socopgitmvlr
   
   define l_cont         integer
   define l_cont_aux     integer
   define l_pesnum       char(09)
   define l_pesnum_aux   char(09)
   define i              smallint
   
   
   output
       left   margin    00
       right  margin    00
       top    margin    00
       bottom margin    00
       page   length    07

   format

       on every row
       
       let l_cont = 0
       let l_cont_aux = 0
       let l_pesnum = ""
       let l_pesnum_aux = ""
       
       ##-- adaptação para integrar Porto Socorro ao sistema Sênior --##
       ##-- alteração 29-10-2010 Jorge Modena --##
       ##-- conta quantidade de posições que PESNUM possui --##
       
       let l_pesnum = lr_report.pesnum
    
       let l_cont =  length(l_pesnum)

       ##--  verifica se PESNUM tem 9 digitos e adiciona 0 a direita --##
    
       if (l_cont <> 9) then
        
           ##-- variavel recebe diferenca para saber qts numeros devem ser adicionados--## 
           let l_cont_aux = 9 - l_cont
          
           
           ##-- atribui o numero 1 na primeira posição --##
           let l_pesnum_aux[1] = 1
           
           ##-- atribui zero no restante das posições --##           
           for i = 2 to l_cont_aux               
               let l_pesnum_aux[i] = 0           
           end for
           
           ##-- completa pesnum com digitos do pesnum recebido na funcao
           
           for i = 1 to l_cont       
               let l_pesnum_aux[l_cont_aux + i] =  l_pesnum[i]
           end for
       
       end if             
      

       print l_pesnum_aux           ,ASCII(09);
       print lr_report.c24astcod    ,ASCII(09);
       print lr_report.c24astdes    ,ASCII(09);
       print lr_report.atdsrvorg    ,ASCII(09);
       print lr_report.atdsrvnum using "#######", "-",
             lr_report.atdsrvano using "##", ASCII(09);
       print lr_report.atddat       ,ASCII(09);
       print lr_report.atdhor       ,ASCII(09);
       print lr_report.atddatprg    ,ASCII(09);
       print lr_report.atdhorprg    ,ASCII(09);
       print lr_report.nom          ,ASCII(09);
        if lr_report.cgcord > 0 then # CGC
          print lr_report.cgccpfnum    using "&&&&&&&&&"
               ,lr_report.cgcord       using "&&&&"
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        else
          print lr_report.cgccpfnum    using "&&&&&&&&&"
               ,lr_report.cgccpfdig    using "&&", ASCII(09);
        end if
       print lr_report.pesnom                ,ASCII(09);
       print lr_report.cliufdcod             ,ASCII(09);
       print lr_report.clicidnom clipped     ,ASCII(09);
       print lr_report.clibrrnom clipped     ,ASCII(09);
       print lr_report.clilgdtip clipped, " ",
             lr_report.clilgdnom clipped, ", ",
             lr_report.clilgdnum using "<<<<<&", " ",
             lr_report.cliendcmp             ,ASCII(09);
       print lr_report.clilgdcep using "&&&&&",
             lr_report.clilgdcepcmp using "&&&" ,ASCII(09);
       print lr_report.brrnom clipped        ,ASCII(09);
       print lr_report.cidnom clipped        ,ASCII(09);
       print lr_report.ufdcod clipped        ,ASCII(09);
       print lr_report.c24pbmcod             ,ASCII(09);
       print lr_report.atddfttxt clipped     ,ASCII(09);
       print lr_report.asitipcod             ,ASCII(09);
       print lr_report.asitipabvdes clipped  ,ASCII(09);
       print lr_report.socntzcod             ,ASCII(09);
       print lr_report.socntzdes clipped     ,ASCII(09);
       print lr_report.pstcoddig             ,ASCII(09);
       print lr_report.nomgrr    clipped     ,ASCII(09);
       print lr_report.socfatpgtdat          ,ASCII(09);
        if lr_report.socopgitmvlr is null then
          let lr_report.socopgitmvlr = 0
       end if
       
       if lr_report.srvvlradc is null then
          let lr_report.srvvlradc = 0
       end if
       
       let srvvlr = lr_report.socopgitmvlr + lr_report.srvvlradc
       print srvvlr                          ,ASCII(09);
       print lr_report.socopgnum             ,ASCII(09);
       print lr_report.socopgitmnum
         

end report
