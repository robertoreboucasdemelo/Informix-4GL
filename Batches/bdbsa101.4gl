#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : PORTO SOCORRO                                               #
# Modulo         : bdbsa101                                                    #
#                  Batch de provisionamento de servicos realizados no dia      #
#                  anterior                                                    #
# Analista Resp. : Carlos Zyon                                                 #
#..............................................................................#
# Desenvolvimento: Fabrica de Software, JUNIOR                                 #
# OSF            : 35050                                                       #
# PSI            : 182516                                                      #
# Liberacao      :                                                             #
#..............................................................................#
#                           * * *  ALTERACOES  * * *                           #
# PSI       Autor            PSI     Alteracao                                 #
# --------  ---------------  ------- ------------------------------------------#
# 06/12/2004  Mariana,Meta   188220  Retirar consistencia de pessoa fisica      #
# 10/09/2005  JUNIOR (Meta)          Melhorias incluida funcao fun_dba_abre_banco
# 20/09/2007  Ligia Mattge   211982  Desprezar servicos da Portoseg (40)        #
# 10/07/2009  Fabio Costa    198404  Incluido flag servico provisionavel       #
# 18/12/2009  Fabio Costa    198404  Provisionar servico pela data acionamento #
#------------------------------------------------------------------------------#
# 08/08/2014  Brunno Silva   CT:14087053/ Acrescimo do comando                 #
#                            14084249     set lock mode to wait 60             #
# 12/11/2014 Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada  #
#                                          Camada Contabil"                    #
################################################################################
database porto

define m_bdbsa101   record
       atdsrvorg       like datmservico.atdsrvorg,
       atdsrvnum       like datmservico.atdsrvnum,
       atdsrvano       like datmservico.atdsrvano,
       pgtdat          like datmservico.pgtdat   ,
       srvprlflg       like datmservico.srvprlflg,
       atdprscod       like datmservico.atdprscod,
       cnldat          like datmservico.cnldat   ,
       atdfnlhor       like datmservico.atdfnlhor,
       atdfnlflg       like datmservico.atdfnlflg,
       atdetpcod       like datmsrvacp.atdetpcod ,
       pestip          like dpaksocor.pestip     ,
       pstcoddig       like datkveiculo.pstcoddig,
       canpgtcod       dec(1,0)                  ,
       difcanhor       datetime hour to minute   ,
       ciaempcod       like datmservico.ciaempcod,
       atddat          like datmservico.atddat
end record


   define mr_retorno record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(10000),                               
    srvdcrcod    like datkdcrorg.srvdcrcod,            
    bemcod       like datkdcrorg.bemcod   ,            
    atoflg       like datkdcrorg.atoflg   ,            
    itaasstipcod like datkassunto.itaasstipcod,        
    carteira     smallint,                                
    ctbramcod    like rsatdifctbramcvs.ctbramcod,     
    ctbmdlcod    like rsatdifctbramcvs.ctbmdlcod,     
    clscod       like rsatdifctbramcvs.clscod,   
    pgoclsflg    like dbskctbevnpam.pgoclsflg, 
    c24astagp    like datkassunto.c24astagp,          
    succod       like datrservapol.succod    ,        
    ramcod       like datrservapol.ramcod    ,        
    modalidade   like rsamseguro.rmemdlcod   ,        
    aplnumdig    like datrservapol.aplnumdig ,        
    itmnumdig    like datrservapol.itmnumdig ,        
    edsnumref    like datrservapol.edsnumref ,                 
    prporg       like datrligprp.prporg      ,                 
    prpnumdig    like datrligprp.prpnumdig   ,                 
    corsus       like abamcor.corsus         ,                 
    srvvlr       like dbsmatdpovhst.srvvlr   ,
    ctbevnpamcod like dbskctbevnpam.ctbevnpamcod, 
    srvpovevncod like dbskctbevnpam.srvpovevncod, 
    srvajsevncod like dbskctbevnpam.srvajsevncod, 
    srvbxaevncod like dbskctbevnpam.srvbxaevncod,
    srvpgtevncod like dbskctbevnpam.srvpgtevncod,
    c24astcod    like datkassunto.c24astcod     ,
    c24astdes    like datkassunto.c24astdes     ,
    avialgmtv    like datmavisrent.avialgmtv    
                      
 end record                                                    
                                                               
define m_ctt record
       prc     integer,
       prv     integer,
       errprv  integer,
       antprv  integer,
       srvdsp  integer
end record

define m_atddat   date
define m_cont   smallint
define m_saida    char(120)
define m_log      char(20)
define m_path     char(100)
define m_path2    char(100)
define m_path3    char(100)
define m_path4    char(200)

#--------------------------------------------------------------------------#
main

    call fun_dba_abre_banco("CT24HS")
    
    set isolation to dirty read
    
    let m_atddat = arg_val(1)
    let m_cont   = arg_val(2)
    
    display "m_atddat: ",m_atddat
    display "m_cont  : ",m_cont  

    call f_path("DBS", "LOG") returning m_log

    if m_log is null then
        let m_log = "./bdbsa101.log"
    else
        let m_log = m_log clipped, "/bdbsa101.log"
    end if

    call startlog (m_log)

    let m_path = f_path("DBS", "RELATO")

    if m_path is null then
       let m_path = "."
    end if
    
    let m_path2 = m_path clipped, "/BDBSA101_erro.txt"
    
    let m_path3 = m_path clipped, "/BDBSA101.xls"
    
    let m_path4 = m_path clipped, "/BDBSA101_erro.xls"
    
    let m_path = m_path clipped, "/BDBSA101.txt"
    
    initialize m_bdbsa101.*, m_ctt.* to null
    
    start report bdbsa101_resumo to m_path
    
    start report bdbsa101_resumo_contabil to m_path2
    
    start report bdbsa101_resumo_Eventos to m_path3
    
    start report bdbsa101_resumo_SemEventos to m_path4
    
    let m_ctt.prc    = 0
    let m_ctt.prv    = 0
    let m_ctt.errprv = 0
    let m_ctt.antprv = 0
    let m_ctt.srvdsp = 0
    
    display "------------------------------------------------------------" 
    display "INICIO - BDBSA101(provisionamento de servicos)"             
    display "------------------------------------------------------------" 
    
    set lock mode to wait 60 #CT: 14084249 e 14087053
    
    call bdbsa101()
    
    display "------------------------------------------------------------"
    display " RESUMO - BDBSA101(provisionamento de servicos):"
    display " Servicos processados..............: ", m_ctt.prc    using "####&&"
    display " Servicos provisionamento OK.......: ", m_ctt.prv    using "####&&"
    display " Servicos provisionamento com erro.: ", m_ctt.errprv using "####&&" 
    display " Servicos ja provisionados.........: ", m_ctt.antprv using "####&&"
    display " Servicos desprezados..............: ", m_ctt.srvdsp using "####&&" 
    display "------------------------------------------------------------"
    
    let m_saida = "------------------------------------------------------------"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " RESUMO - BDBSA101(provisionamento de servicos):"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " Servicos processados..............: ", m_ctt.prc     using "####&&"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " Servicos provisionamento OK.......: ",m_ctt.prv      using "####&&"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " Servicos provisionamento com erro.: ", m_ctt.errprv  using "####&&"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " Servicos ja provisionados.........: ", m_ctt.antprv  using "####&&"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = " Servicos desprezados..............: ",m_ctt.srvdsp   using "####&&"
    output to report bdbsa101_resumo(m_saida clipped)
    let m_saida = "------------------------------------------------------------"        
    output to report bdbsa101_resumo(m_saida clipped)
    
     finish report bdbsa101_resumo
     
     finish report bdbsa101_resumo_contabil
     
     finish report bdbsa101_resumo_Eventos
     
     finish report bdbsa101_resumo_SemEventos
     
    #call bdbsa101_email_provisi(m_path3,"Servicos Provisionados para o dia: ")
    
    call bdbsa101_email_contabil(m_path,"Resumo do Provisionamento para o dia: ")
    
    call bdbsa101_email_provisi(m_path4,"Servicos nao Provisionados para o dia: ")  
    
    call bdbsa101_email_contabil(m_path2,"Erro de parametrizacao para o dia: ")
   
end main
#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
#------------   P R E P A R A N D O   C U R S O R E S  --------------------#
#--------------------------------------------------------------------------#
function bdbsa101_seleciona_sql()

    define l_cmd char(900)
    
    let l_cmd = " select s.atdsrvorg, s.atdsrvnum, s.atdsrvano, s.pgtdat    ",
                "      , s.srvprlflg, s.atdprscod, s.cnldat   , s.atdfnlhor ",
                "      , s.atdfnlflg, a.atdetpcod , s.ciaempcod, s.atddat ",
                " from datmservico s, datmsrvacp a ",
                " where s.atdsrvnum = a.atdsrvnum  ",
                "   and s.atdsrvano = a.atdsrvano  ",
                "   and a.atdetpdat = ?            ",               -- data do acionamento
                "   and s.atdsrvorg in (1,2,3,4,5,6,7,8,9,17,18)", 
                "   and s.ciaempcod in (1,43)                   ",  -- so empresa 1 provisiona servico
                "   and a.atdetpcod is not null                 ",
                "   and a.atdetpcod in (3, 4, 5, 10)            ",
                "   and a.atdsrvseq = (select max(b.atdsrvseq)  ",
                "                      from datmsrvacp b        ",
                "                      where b.atdsrvnum = a.atdsrvnum ",
                "                        and b.atdsrvano = a.atdsrvano)",
                " order by s.ciaempcod, s.atddat "
    prepare pbdbsa101001 from l_cmd
    declare cbdbsa101001 cursor with hold for pbdbsa101001
    
    
    ## Verifica se o prestador e pessoa juridica //
    let l_cmd = " select pestip "
               ,"   from dpaksocor  "
               ," where pstcoddig = ? "

    prepare pbdbsa101003 from l_cmd
    declare cbdbsa101003 cursor with hold for pbdbsa101003

    ## Verifica se o prestador e acionado pelo radio //
    let l_cmd = " select pstcoddig "
               ,"   from datkveiculo  "
               ," where pstcoddig = ?  "
               ,"   and socctrposflg = 'S'  "
               ,"   and socoprsitcod in(1,2) "

    prepare pbdbsa101004 from l_cmd
    declare cbdbsa101004 cursor with hold for pbdbsa101004

    ## Recupera o motivo da locacao //
    let l_cmd = " select avialgmtv "
               ,"   from datmavisrent "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "

    prepare pbdbsa101005 from l_cmd
    declare cbdbsa101005 cursor with hold for pbdbsa101005

    ## Verifica se e um RET //
    let l_cmd = " select c24astcod "
               ,"   from datmligacao  "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               ,"   and lignum <> 0   "

    prepare pbdbsa101006 from l_cmd
    declare cbdbsa101006 cursor with hold for pbdbsa101006
       
end function
#--------------------------------------------------------------------------#

#----------------------------------------------------------------
function bdbsa101()
#----------------------------------------------------------------
  define ls_sqlcode    integer

  define l_ctbcrtcod   like ctgrcrtram_new.ctbcrtcod
  
  define lr_erro_prv record
     regiclhrrdat  like dbsmatdpovhst.regiclhrrdat,    
     ctbpezcod     like dbsmatdpovhst.ctbpezcod,
     err           smallint,          
     msgerr        char(300),
     srvvlr        like dbsmatdpovhst.srvvlr
  end record 
  
  define lr_par record
         evento          char(06),
         empresa         char(50),
         dt_movto        date    ,
         chave_primaria  char(50),
         op              char(50),
         apolice         char(50),
         sucursal        char(50),
         projeto         char(50),
         dt_chamado      date    ,
         fvrcod          char(50),
         fvrnom          char(50),
         nfnum           char(50),
         corsus          char(50),
         cctnum          char(50),
         modalidade      char(50),
         ramo            char(50),
         opgvlr          char(50),
         dt_vencto       date    ,
         dt_ocorrencia   date
  end record
  
  define l_cctcod       like dbscadtippgt.cctcod  
  define l_succod       like dbscadtippgt.succod
  
  call bdbsa101_seleciona_sql()
  
  ##  Verifica data recebida como parametro  ##
  if m_atddat is null or
     m_atddat = " "   then
      let m_atddat = today - 1
  else
     if m_atddat > today then
         display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
         #call errorlog("*** ERRO NO PARAMETRO: DATA INVALIDA! ***")
        return
     end if
  end if
  
  
  open cbdbsa101001  using m_atddat
  foreach cbdbsa101001 into m_bdbsa101.atdsrvorg,
                            m_bdbsa101.atdsrvnum,
                            m_bdbsa101.atdsrvano,
                            m_bdbsa101.pgtdat   ,
                            m_bdbsa101.srvprlflg,
                            m_bdbsa101.atdprscod,
                            m_bdbsa101.cnldat   ,
                            m_bdbsa101.atdfnlhor,
                            m_bdbsa101.atdfnlflg,
                            m_bdbsa101.atdetpcod,
                            m_bdbsa101.ciaempcod,
                            m_bdbsa101.atddat
     
     display "#-----------------------------------------------------------------------------#"
     display "Processando o Servico: ",m_bdbsa101.atdsrvorg,'/',m_bdbsa101.atdsrvnum,'-',m_bdbsa101.atdsrvano

     let m_ctt.prc = m_ctt.prc + 1  -- processados
     
     ###  // Se for carro-extra, trata diferente //
     if m_bdbsa101.atdsrvorg = 8 then

         call bdbsa101_trsrvce()

     else

         ### // Verifica se tem data de pagamento //
         if m_bdbsa101.pgtdat is not null then
             let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " tem data de pagamento, despresado."
             display "m_saida: ",m_saida
             #output to report bdbsa101_resumo(m_saida clipped)
             initialize m_bdbsa101.* to null
             let m_ctt.srvdsp = m_ctt.srvdsp + 1
             continue foreach
         end if

         ###  // Verifica se o servico e particular (Pago pelo cliente) //
         if m_bdbsa101.srvprlflg = "S" then
             let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " e particular, despresado."
             display "m_saida: ",m_saida
             #output to report bdbsa101_resumo(m_saida clipped)
             initialize m_bdbsa101.* to null
             let m_ctt.srvdsp = m_ctt.srvdsp + 1
             continue foreach
         end if

         ###  // Verifica se o servico esta sem prestador //
         if m_bdbsa101.atdprscod is null and m_bdbsa101.atdetpcod <> 5 then
             let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " n�o tem prestador, despresado."
             display "m_saida: ",m_saida
             #output to report bdbsa101_resumo(m_saida clipped)
             initialize m_bdbsa101.* to null
             let m_ctt.srvdsp = m_ctt.srvdsp + 1
             continue foreach
         end if

         ### // Verifica se o prestador e pessoa juridica //
         open cbdbsa101003 using m_bdbsa101.atdprscod
         fetch cbdbsa101003 into m_bdbsa101.pestip

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode < 0 then
                display "ERRO DE ACESSO cbdbsa101003, sqlcode = ", sqlca.sqlcode
                #call errorlog("ERRO DE ACESSO cbdbsa101003 ***")
                let m_ctt.srvdsp = m_ctt.srvdsp + 1
                continue foreach
            end if
         end if
         
         if m_bdbsa101.pestip is null and m_bdbsa101.atdprscod is not null then
            let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " com prestador sem tipo pessoa, despresado."
            display "m_saida: ",m_saida
            #output to report bdbsa101_resumo(m_saida clipped)
            initialize m_bdbsa101.* to null
            let m_ctt.srvdsp = m_ctt.srvdsp + 1
            continue foreach
         end if

         ### // Trata RE e Auto //
         if m_bdbsa101.atdsrvorg = 9 then
             call bdbsa101_trsrvre()
         else
             call bdbsa101_trsrvauto()
         end if

     end if ### // m_bdbsa101.atdsrvorg = 8 //

     ###  // Verifica se desprezou o servico //
     if m_bdbsa101.atdsrvnum is null then
         let m_ctt.srvdsp = m_ctt.srvdsp + 1
         continue foreach
     end if
     
     
     ## // Verifica se ja foi provisionado //
     call ctb00g16_selsrvprv(m_bdbsa101.atdsrvnum, m_bdbsa101.atdsrvano)
                   returning lr_erro_prv.err   ,          
                             lr_erro_prv.msgerr,          
                             lr_erro_prv.ctbpezcod,   
                             lr_erro_prv.regiclhrrdat,
                             lr_erro_prv.srvvlr
                             
     display "lr_erro_prv.err           :", lr_erro_prv.err         
     display "lr_erro_prv.msgerr        :", lr_erro_prv.msgerr clipped      
     display "lr_erro_prv.ctbpezcod     :", lr_erro_prv.ctbpezcod   
     display "lr_erro_prv.regiclhrrdat  :", lr_erro_prv.regiclhrrdat
     display "lr_erro_prv.srvvlr        :", lr_erro_prv.srvvlr
                   
     display "Verifica se o servi�o ja foi provisionado: ", lr_erro_prv.err
     # se ja existe, continua
     if lr_erro_prv.err = 0 then
         let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " ja provisionado, despresado."
         display "m_saida: ",m_saida
         
         #output to report bdbsa101_resumo(m_saida clipped)
         
         #initialize m_bdbsa101.* to null
         #initialize mr_retorno.* to null
         
         let m_ctt.antprv = m_ctt.antprv + 1
         
         #continue foreach
     else
        ## // Chama a interface de provisionamento //
        call ctb00g16_incprvdsp(m_bdbsa101.atdsrvnum,
                                m_bdbsa101.atdsrvano,1)
                      returning mr_retorno.srvdcrcod   , 
                                mr_retorno.bemcod      , 
                                mr_retorno.atoflg      , 
                                mr_retorno.itaasstipcod, 
                                mr_retorno.c24astagp   , 
                                mr_retorno.c24astcod   , 
                                mr_retorno.c24astdes   , 
                                mr_retorno.carteira    , 
                                mr_retorno.ctbramcod   , 
                                mr_retorno.ctbmdlcod   , 
                                mr_retorno.clscod      , 
                                mr_retorno.pgoclsflg   , 
                                mr_retorno.ctbevnpamcod, 
                                mr_retorno.srvpovevncod, 
                                mr_retorno.srvajsevncod, 
                                mr_retorno.srvbxaevncod,
                                mr_retorno.srvpgtevncod,
                                mr_retorno.succod      , 
                                mr_retorno.ramcod      , 
                                mr_retorno.modalidade  , 
                                mr_retorno.aplnumdig   , 
                                mr_retorno.itmnumdig   , 
                                mr_retorno.edsnumref   , 
                                mr_retorno.prporg      , 
                                mr_retorno.prpnumdig   , 
                                mr_retorno.msgerro     , 
                                mr_retorno.srvvlr      , 
                                mr_retorno.avialgmtv   , 
                                mr_retorno.corsus   
                                
     display "mr_retorno.srvdcrcod           :", mr_retorno.srvdcrcod       
     display "mr_retorno.bemcod       :", mr_retorno.bemcod
     display "mr_retorno.atoflg    :", mr_retorno.atoflg
     display "mr_retorno.itaasstipcod  :", mr_retorno.itaasstipcod
     display "mr_retorno.carteira         :", mr_retorno.carteira 
     display "mr_retorno.ctbramcod         :", mr_retorno.ctbramcod
     display "mr_retorno.ctbmdlcod         :", mr_retorno.ctbmdlcod
     display "mr_retorno.ctbevnpamcod         :", mr_retorno.ctbevnpamcod
     display "mr_retorno.srvpovevncod         :", mr_retorno.srvpovevncod
     display "mr_retorno.srvajsevncod         :", mr_retorno.srvajsevncod
     display "mr_retorno.srvbxaevncod         :", mr_retorno.srvbxaevncod
     display "mr_retorno.srvpgtevncod         :", mr_retorno.srvpgtevncod
     display "mr_retorno.modalidade         :", mr_retorno.modalidade
                                
                                     
        display "mr_retorno.msgerro: ",mr_retorno.msgerro clipped
        display "mr_retorno.clscod: ", mr_retorno.clscod
        
         if mr_retorno.clscod is not null and    
            mr_retorno.clscod <> " " then   
         else                               
            let mr_retorno.clscod = "100"   
         end if                 
         
        display "mr_retorno.clscod: ", mr_retorno.clscod            
        display "mr_retorno.srvvlr: ", mr_retorno.srvvlr  
        
        if mr_retorno.msgerro is not null then
            let m_ctt.errprv = m_ctt.errprv + 1
            output to report bdbsa101_resumo_contabil(mr_retorno.msgerro)
             
            output to report bdbsa101_resumo_SemEventos()
             
            #initialize m_bdbsa101.* to null 
            #initialize mr_retorno.* to null
            #
            #continue foreach
        else     
           if mr_retorno.srvvlr > 0 then
              display "Evento: ",mr_retorno.srvpovevncod
              
              call ctb00g16_envio_contabil(mr_retorno.srvpovevncod,   
                                           m_bdbsa101.ciaempcod   ,   
                                           mr_retorno.succod      ,   
                                           mr_retorno.ctbramcod   , # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                           mr_retorno.ctbmdlcod   , # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                           mr_retorno.aplnumdig   ,   
                                           mr_retorno.itmnumdig   ,   
                                           mr_retorno.edsnumref   ,   
                                           mr_retorno.prporg      ,   
                                           mr_retorno.prpnumdig   ,   
                                           mr_retorno.corsus      ,   
                                           mr_retorno.srvvlr      ,   
                                           m_bdbsa101.atdsrvnum   ,   
                                           m_bdbsa101.atdsrvano   ,   
                                           0                      ,
                                           mr_retorno.carteira    ,
                                           m_bdbsa101.atddat)
              let m_ctt.prv = m_ctt.prv + 1 
              output to report bdbsa101_resumo_Eventos() 
           else
              let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " com valor 0."
               display "m_saida: ",m_saida
               output to report bdbsa101_resumo(m_saida clipped)
               initialize m_bdbsa101.* to null
               let m_ctt.srvdsp = m_ctt.srvdsp + 1
               #continue foreach
           end if
        end if
        
     end if
     
     ## Provisionamento antigo
     call ctb00g03_selprvdsp(m_bdbsa101.atdsrvnum, m_bdbsa101.atdsrvano)
                   returning ls_sqlcode
     
     # se ja existe, continua
     if ls_sqlcode = 0 then
         display "Servi�o ", m_bdbsa101.atdsrvnum, " ja provisionado, despresado."
         initialize m_bdbsa101.* to null 
         initialize mr_retorno.* to null
         continue foreach
     end if
     
     ### // Chama a interface de provisionamento //
     call ctb00g03_incprvdsp(m_bdbsa101.atdsrvnum,
                             m_bdbsa101.atdsrvano)
                   returning ls_sqlcode, lr_par.*
     
     if ls_sqlcode <> 0 then
         display 'OCORREU UM ERRO NO ACESSO ctb00g03_incprvdsp, sql = ',ls_sqlcode
         #call errorlog('OCORREU UM ERRO NO ACESSO ctb00g03_incprvdsp')
         continue foreach
     end if
     
     initialize m_bdbsa101.* to null 
     initialize mr_retorno.* to null

  end foreach

  close cbdbsa101001

end function

#----------------------------------------------------------------
function bdbsa101_trsrvauto()
#----------------------------------------------------------------

  ### Somente etapas 4=Acionado/Final e 5=Cancelado //
  if m_bdbsa101.atdetpcod <> 4 and
     m_bdbsa101.atdetpcod <> 5 then
      let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " etapa ",m_bdbsa101.atdetpcod,", despresado."
     display "ERRO: ",m_saida clipped
     #output to report bdbsa101_resumo(m_saida clipped)
     initialize m_bdbsa101.* to null
      return
  end if

  ### Se etapa 5=Cancelado verifica o flag de pagamento //
  if m_bdbsa101.atdetpcod = 5 then

      open cbdbsa101004 using m_bdbsa101.atdprscod
      fetch cbdbsa101004 into m_bdbsa101.pstcoddig
      if m_bdbsa101.pstcoddig is null then
          initialize m_bdbsa101.* to null
          return
      end if

      ###  Verifica o codigo de cancelamento de pagamento //
      call ctb00g00(m_bdbsa101.atdsrvnum,
                    m_bdbsa101.atdsrvano,
                    m_bdbsa101.cnldat   ,
                    m_bdbsa101.atdfnlhor)
          returning m_bdbsa101.canpgtcod,
                    m_bdbsa101.difcanhor

      if m_bdbsa101.canpgtcod <> 1 and
         m_bdbsa101.canpgtcod <> 2 and
         m_bdbsa101.canpgtcod <> 4 and
         m_bdbsa101.canpgtcod <> 5 then
          initialize m_bdbsa101.* to null
      end if

  end if ## // m_bdbsa101.atdetpcod = 5 //

end function

#--------------------------------------------------------------------------#
function bdbsa101_trsrvce()
#--------------------------------------------------------------------------#

  define l_avialgmtv  like datmavisrent.avialgmtv

  ### Somente etapa 4=Acionado/Final //
  if m_bdbsa101.atdetpcod <> 4 then
      display "Etapa do servico: ",m_bdbsa101.atdetpcod 
      initialize m_bdbsa101.* to null
      return
  end if

  ### Somente servicos finalizados //
  if m_bdbsa101.atdfnlflg <> "S" then
      display "Servico finalizado: ",m_bdbsa101.atdfnlflg
      initialize m_bdbsa101.* to null
      return
  end if

  ### Recupera o motivo da locacao //
  open cbdbsa101005 using m_bdbsa101.atdsrvnum,
                          m_bdbsa101.atdsrvano
  fetch cbdbsa101005 into l_avialgmtv

  ### Verifica se nao e motivo 5=Particular //
  if l_avialgmtv = 5 then
      let m_saida = "Motivo da Locacao: ",l_avialgmtv," que nao sera provisionado para o servico: ",m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano
      display "ERRO: ",m_saida
      #output to report bdbsa101_resumo(m_saida clipped)
      initialize m_bdbsa101.* to null
      return
  end if

end function

#--------------------------------------------------------------------------#
function bdbsa101_trsrvre()
#--------------------------------------------------------------------------#

  define l_c24astcod_ret  like datmligacao.c24astcod

  ### Somente etapas 3=Acionado/Acomp e 10=Retorno //
  if m_bdbsa101.atdetpcod <>  3 and
     m_bdbsa101.atdetpcod <> 10 then
     let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " etapa ",m_bdbsa101.atdetpcod,", despresado."
     display "ERRO: ",m_saida clipped
     #output to report bdbsa101_resumo(m_saida clipped)
     initialize m_bdbsa101.* to null
     return
  end if

  open cbdbsa101006 using m_bdbsa101.atdsrvnum,
                          m_bdbsa101.atdsrvano
  fetch cbdbsa101006 into l_c24astcod_ret

  if l_c24astcod_ret = "RET" then
     let m_saida = "Servi�o ", m_bdbsa101.atdsrvnum,"-",m_bdbsa101.atdsrvano, " retorno, despresado."
     display "ERRO: ",m_saida clipped
     #output to report bdbsa101_resumo(m_saida clipped)
     initialize m_bdbsa101.* to null
     return
  end if

end function

#--------------------------------------------------------------------------
report bdbsa101_resumo(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(120)

output
     left margin     0
     bottom margin   0
     top margin      0
     right margin    0
     page length    60

  format
     on every row
        print column 1, l_linha clipped
                                                                      
 end report 
 
 
#--------------------------------------------------------------------------
report bdbsa101_resumo_Eventos()
#--------------------------------------------------------------------------

output
    page length    99
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format
    
     first page header  
             
       print "EMPRESA             ", ASCII(9),
             "RAMO PRINCIPAL      ", ASCII(9),
             "MODALIDADE PRINCIPAL", ASCII(9),
             "RAMO CONTABIL       ", ASCII(9),
             "MODALIDADE CONTABIL ", ASCII(9),
             "CLAUSULA            ", ASCII(9),
             "CLAUSULA PAGA?      ", ASCII(9),
             "DECORRENCIA         ", ASCII(9),   
             "PARA QUEM PREST SRV ", ASCII(9),
             "BEM ATENDIDO        ", ASCII(9),  
             "CARTEIRA            ", ASCII(9),
             "GRUPO DE ASSUNTO    ", ASCII(9), 
             "ASSUNTO             ", ASCII(9), 
             "EVENTO PROVISAO     ", ASCII(9),
             "EVENTO AJUSTE       ", ASCII(9),
             "EVENTO CANCELAMENTO ", ASCII(9),
             "EVENTO PAGAMENTO    ", ASCII(9), 
             "NUMERO DO SERVICO   ", ASCII(9),   
             "ANO DO SERVICO      ", ASCII(9),   
             "ORIGEM DO SERVICO   ", ASCII(9),    
             "MOTIVO              ", ASCII(9),
             "SUCURSAL            ", ASCII(9),
             "APOLICE             ", ASCII(9),  
             "PROPOSTA            ", ASCII(9),         
             "VALOR               ", ASCII(9)
               
             
  on every row    
       
       print m_bdbsa101.ciaempcod    , ASCII(9);
       print mr_retorno.ramcod       , ASCII(9);
       print mr_retorno.modalidade   , ASCII(9);
       print mr_retorno.ctbramcod    , ASCII(9);
       print mr_retorno.ctbmdlcod    , ASCII(9);
       print mr_retorno.clscod       , ASCII(9);
       print mr_retorno.pgoclsflg    , ASCII(9);
       print mr_retorno.srvdcrcod    , ASCII(9);   
       print mr_retorno.itaasstipcod , ASCII(9);   
       print mr_retorno.bemcod       , ASCII(9);   
       print mr_retorno.carteira     , ASCII(9);   
       print mr_retorno.c24astagp    , ASCII(9);   
       print mr_retorno.c24astcod," - ",mr_retorno.c24astdes, ASCII(9);  
       print mr_retorno.srvpovevncod , ASCII(9);
       print mr_retorno.srvajsevncod , ASCII(9);      
       print mr_retorno.srvbxaevncod , ASCII(9);
       print mr_retorno.srvpgtevncod , ASCII(9);
       print m_bdbsa101.atdsrvnum    , ASCII(9); 
       print m_bdbsa101.atdsrvano    , ASCII(9); 
       print m_bdbsa101.atdsrvorg    , ASCII(9); 
       print mr_retorno.avialgmtv    , ASCII(9);
       print mr_retorno.succod       , ASCII(9);
       print mr_retorno.aplnumdig    , ASCII(9);
       print mr_retorno.prporg,"/",mr_retorno.prpnumdig  , ASCII(9);
       print mr_retorno.srvvlr       , ASCII(9)
       
       
 end report 
 
 
 
#--------------------------------------------------------------------------
report bdbsa101_resumo_SemEventos()
#--------------------------------------------------------------------------

output
    page length    99
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format
    
     first page header  
             
       print "EMPRESA             ", ASCII(9),
             "RAMO PRINCIPAL      ", ASCII(9),
             "MODALIDADE PRINCIPAL", ASCII(9),
             "RAMO CONTABIL       ", ASCII(9),
             "MODALIDADE CONTABIL ", ASCII(9),
             "CLAUSULA            ", ASCII(9),
             "CLAUSULA PAGA?      ", ASCII(9),
             "DECORRENCIA         ", ASCII(9),   
             "PARA QUEM PREST SRV ", ASCII(9),
             "BEM ATENDIDO        ", ASCII(9),  
             "CARTEIRA            ", ASCII(9),
             "GRUPO DE ASSUNTO    ", ASCII(9), 
             "ASSUNTO             ", ASCII(9), 
             "EVENTO PROVISAO     ", ASCII(9),
             "EVENTO AJUSTE       ", ASCII(9),
             "EVENTO CANCELAMENTO ", ASCII(9),
             "EVENTO PAGAMENTO    ", ASCII(9), 
             "NUMERO DO SERVICO   ", ASCII(9),   
             "ANO DO SERVICO      ", ASCII(9),   
             "ORIGEM DO SERVICO   ", ASCII(9),    
             "MOTIVO              ", ASCII(9),
             "SUCURSAL            ", ASCII(9),
             "APOLICE             ", ASCII(9),  
             "PROPOSTA            ", ASCII(9),         
             "VALOR               ", ASCII(9)
               
             
  on every row    
       
       print m_bdbsa101.ciaempcod    , ASCII(9);
       print mr_retorno.ramcod       , ASCII(9);
       print mr_retorno.modalidade   , ASCII(9);
       print mr_retorno.ctbramcod    , ASCII(9);
       print mr_retorno.ctbmdlcod    , ASCII(9);
       print mr_retorno.clscod       , ASCII(9);
       print mr_retorno.pgoclsflg    , ASCII(9);
       print mr_retorno.srvdcrcod    , ASCII(9);   
       print mr_retorno.itaasstipcod , ASCII(9);   
       print mr_retorno.bemcod       , ASCII(9);   
       print mr_retorno.carteira     , ASCII(9);   
       print mr_retorno.c24astagp    , ASCII(9);   
       print mr_retorno.c24astcod," - ",mr_retorno.c24astdes, ASCII(9);  
       print mr_retorno.srvpovevncod , ASCII(9);
       print mr_retorno.srvajsevncod , ASCII(9);      
       print mr_retorno.srvbxaevncod , ASCII(9);
       print mr_retorno.srvpgtevncod , ASCII(9);
       print m_bdbsa101.atdsrvnum    , ASCII(9); 
       print m_bdbsa101.atdsrvano    , ASCII(9); 
       print m_bdbsa101.atdsrvorg    , ASCII(9); 
       print mr_retorno.avialgmtv    , ASCII(9);
       print mr_retorno.succod       , ASCII(9);
       print mr_retorno.aplnumdig    , ASCII(9);
       print mr_retorno.prporg,"/",mr_retorno.prpnumdig  , ASCII(9);
       print mr_retorno.srvvlr       , ASCII(9)
       
       
 end report 


#--------------------------------------------------------------------------
report bdbsa101_resumo_contabil(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(10000)

 output
     left margin     0
     bottom margin   0
     top margin      0
     right margin    0
     page length     60

  format
     on every row
        print column 1, l_linha clipped

end report

#=============================================================================
function bdbsa101_email_provisi(param)
#=============================================================================
 
 define param record
    path        char(200),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
     # COMPACTA O ARQUIVO DO RELATORIO
        let l_comando = "gzip -f ", param.path
        run l_comando
        
        let param.path = param.path  clipped, ".gz "
     
    let param.descricao = param.descricao clipped, m_atddat 
    let l_retorno = ctx22g00_envia_email("BDBSA101", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro(",l_retorno using "<<<<<<<<<<<<<",") de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsa101 "
       end if
    end if    
 whenever error stop 

end function 



#=============================================================================
function bdbsa101_email_contabil(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
    let param.descricao = param.descricao clipped, m_atddat 
    let l_retorno = ctx22g00_envia_email("BDBSA101", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro(",l_retorno using "<<<<<<<<<<<<<",") de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsa101 "
       end if
    end if    
 whenever error stop 

end function
