#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr024                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: PSI-2013-25834/EV                                          #
#                  RELATORIO DIARIO DE MOVIMENTOS CONTABEIS DO PORTO SOCORRO  #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: 16/04/2014                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

define m_prepare smallint

define mr_bdbsr024 record 
   atdsrvnum     like dbsmatdpovhst.atdsrvnum,   
   atdsrvano     like dbsmatdpovhst.atdsrvano,
   evntipcod     like dbsmatdpovhst.evntipcod,
   ciaempcod     like datmservico.ciaempcod ,  
   atdsrvorg     like datmservico.atdsrvorg ,
   atddat        like datmservico.atddat    ,
   socfatpgtdat  like dbsmopg.socfatpgtdat  ,
   socopgnum     like dbsmopg.socopgnum     ,
   succod        like datrservapol.succod   ,      
   ramcod        like datrservapol.ramcod   ,      
   aplnumdig     like datrservapol.aplnumdig,   
   itmnumdig     like datrservapol.itmnumdig,   
   edsnumref     like datrservapol.edsnumref,   
   prporg        like datrligprp.prporg     ,
   prpnumdig     like datrligprp.prpnumdig  ,
   c24astcod     like datmligacao.c24astcod ,  
   lignum        like datmligacao.lignum    ,  
   regiclhrrdat  like dbsmatdpovhst.regiclhrrdat,    
   ctbpezcod     like dbsmatdpovhst.ctbpezcod,
   srvvlr        like dbsmatdpovhst.srvvlr,
   srvpovevncod  like dbskctbevnpam.srvpovevncod,
   srvajsevncod  like dbskctbevnpam.srvajsevncod,
   srvbxaevncod  like dbskctbevnpam.srvbxaevncod,
   srvpgtevncod  like dbskctbevnpam.srvpgtevncod,
   srvatdctecod  like dbskctbevnpam.srvatdctecod, 
   srvatdctedes  char(300),
   cctcod        like dbsmatdpovhst.cctcod,
   cnldat        like datmservico.cnldat   ,
   socopgitmvlr  decimal(15,2),
   datacontabil  like datmservico.atddat
 end record 
   
define m_data      char(10)
define m_log       char(100)
define m_count     smallint


define m_path char(100)
define m_path2 char(100)




#============================================    
main
#============================================   

 call fun_dba_abre_banco("CT24HS")
 
 set isolation to dirty read    
 
 initialize  mr_bdbsr024.* to null
 let m_data     = null
 
 let m_data = arg_val(1)
     
 if m_data is null or
    m_data = " "  then
    let m_data =  today
 else
    if m_data is null then
       display "*** ERRO NO PARAMETRO: DATA INVALIDA ! ***"
       exit program(1)
    end if
 end if
 
 call f_path("DBS", "LOG") returning m_log
 
 if m_log is null then
     let m_log = "./bdbsr024.log"
 else
     let m_log = m_log clipped, "/bdbsr024.log"
 end if
 
 call startlog (m_log)
 display "m_log: ",m_log clipped
 display "m_data: ",m_data          
  
 let m_path = f_path("DBS", "RELATO")

    if m_path is null then
       let m_path = "."
    end if
    
 let m_path = m_path clipped, "/bdbsr024.xls"
 
 display "m_path: ",m_path clipped
 call bdbsr024_prepare()
 
 call bdbsr024()
 
 call bdbsr024_email_provisi(m_path,"Relatorio Contabilizacao: ")
  
end main


#============================================
function bdbsr024_prepare()
#============================================

define l_sql char(30000)

  let l_sql  =  null
  
  let l_sql = "select atdsrvnum,    ",                                            
                     "atdsrvano,    ",
                     "srvvlr   ,    ", 
                     "evntipcod,    ",
                     "cctcod,       ",
                     "ctbpezcod,    ",
                     "regiclhrrdat  ",                                        
              "from  dbsmatdpovhst  ",                                           
              "where date(regiclhrrdat) = ? ",
              "order by atdsrvnum,atdsrvano"
                
  prepare pbdbsr024_001 from l_sql
  declare cbdbsr024_001 cursor for pbdbsr024_001  
  
 
   let l_sql = "select a.c24astcod,a.lignum ", 
               " from datmligacao a ", 
               " where a.lignum = (select min(b.lignum)    ", 
                                   " from datmligacao b    ", 
                                   "where b.atdsrvnum = ?  ", 
                                   "  and b.atdsrvano = ? )"                                                
   prepare pbdbsr024_002 from l_sql               
   declare cbdbsr024_002 cursor for pbdbsr024_002
   
   
   
   let l_sql = "select succod,     ",   
               "       ramcod,     ",   
               "       aplnumdig,  ",   
               "       itmnumdig,  ",   
               "       edsnumref   ",   
               "from datrservapol  ",   
               "where atdsrvnum = ?",   
               "  and atdsrvano = ?"  
               
   prepare pbdbsr024_003 from l_sql              
   declare cbdbsr024_003 cursor for pbdbsr024_003
   
   
   let l_sql = "select prporg,   ",
               "       prpnumdig ",
               " from datrligprp ",
               " where lignum = ? "
               
    prepare pbdbsr024_004 from l_sql              
    declare cbdbsr024_004 cursor for pbdbsr024_004
                                                      
    let l_sql = "select ciaempcod,atdsrvorg,atddat,cnldat",
                "  from datmservico",
                " where atdsrvnum = ?",
                "   and atdsrvano = ?"
     prepare pbdbsr024_005 from l_sql              
     declare cbdbsr024_005 cursor for pbdbsr024_005  
     
     
     let l_sql = "select srvpovevncod,",
                "        srvajsevncod,",
                "        srvbxaevncod,",
                "        srvpgtevncod,",
                "        srvatdctecod ",
                "  from dbskctbevnpam ",
                " where ctbevnpamcod = ?"
     prepare pbdbsr024_006 from l_sql              
     declare cbdbsr024_006 cursor for pbdbsr024_006 
     
     
     let l_sql = "select b.socfatpgtdat, b.socopgnum, a.socopgitmvlr ",
                "  from dbsmopgitm a, dbsmopg b",
                " where b.socopgnum = a.socopgnum",
                "   and a.atdsrvnum = ?",
                "   and a.atdsrvano = ?"
     prepare pbdbsr024_007 from l_sql              
     declare cbdbsr024_007 cursor for pbdbsr024_007  
     
      
     let l_sql = "select srvvlr   , ", 
                         "evntipcod,",
                         "cctcod    ",                                        
              "from  dbsmatdpovhst  ",                                           
              "where atdsrvnum = ?",
              "  and atdsrvano = ?",
              "order by regiclhrrdat"
                
  prepare pbdbsr024_009 from l_sql
  declare cbdbsr024_009 cursor for pbdbsr024_009
     
      
let m_prepare = true
   
end function

#============================================
function bdbsr024()
#============================================

define l_valorprv decimal(12,10)       
define l_valorajs decimal(12,10)    
define l_valorbxa decimal(12,10)    
define l_valorpgt decimal(12,10)    
 
define lr_erro record         
        err    smallint,  # Codigo 2 quer dizer que devemos realizar a provisao do servico         
        msgerr char(1000)          
     end record 
 
    
   start report bdbsr024_relat to m_path  
   
   # busca os servicos na tabela da bdbsr024idade
  whenever error continue
   open cbdbsr024_001 using m_data
   
   foreach cbdbsr024_001 into mr_bdbsr024.atdsrvnum,
                              mr_bdbsr024.atdsrvano,
                              mr_bdbsr024.srvvlr   ,
                              mr_bdbsr024.evntipcod,  
                              mr_bdbsr024.cctcod   ,
                              mr_bdbsr024.ctbpezcod,
                              mr_bdbsr024.regiclhrrdat  
                              
      display "Processando o servico: ",mr_bdbsr024.atdsrvnum, "-",mr_bdbsr024.atdsrvano
      
      # busca o assunto do servico
      open cbdbsr024_002 using  mr_bdbsr024.atdsrvnum,
                                mr_bdbsr024.atdsrvano
      fetch cbdbsr024_002 into mr_bdbsr024.c24astcod,
                               mr_bdbsr024.lignum
                     
      close cbdbsr024_002 
      
      
      # busca a apolice do servico
      open cbdbsr024_003 using  mr_bdbsr024.atdsrvnum,
                                mr_bdbsr024.atdsrvano
                                       
      fetch cbdbsr024_003 into mr_bdbsr024.succod   ,
                               mr_bdbsr024.ramcod   ,          
                               mr_bdbsr024.aplnumdig,
                               mr_bdbsr024.itmnumdig,
                               mr_bdbsr024.edsnumref 
                               
      close cbdbsr024_003 
      
      
      # busca a proposta do servico
      open cbdbsr024_004 using mr_bdbsr024.lignum
            
      fetch cbdbsr024_004 into mr_bdbsr024.prporg,   
                               mr_bdbsr024.prpnumdig
               
      close cbdbsr024_004                                
      
      
      # busca empresa e origem do servico
      let m_count = 1
      while true
         open cbdbsr024_005 using  mr_bdbsr024.atdsrvnum,
                                   mr_bdbsr024.atdsrvano
                                          
         fetch cbdbsr024_005 into mr_bdbsr024.ciaempcod,   
                                  mr_bdbsr024.atdsrvorg,
                                  mr_bdbsr024.atddat,
                                  mr_bdbsr024.cnldat
         if sqlca.sqlcode <> 0 then
             if m_count < 11 then
                sleep 1  
                close cbdbsr024_005
                let m_count = m_count + 1
                continue while
             else
                close cbdbsr024_005 
                exit while 
             end if 
         else
            close cbdbsr024_005 
            exit while
         end if                          
      end while
      
      # busca dados de pagamento
      open cbdbsr024_007 using  mr_bdbsr024.atdsrvnum,
                                mr_bdbsr024.atdsrvano
                                       
      fetch cbdbsr024_007 into mr_bdbsr024.socfatpgtdat,
                               mr_bdbsr024.socopgnum,
                               mr_bdbsr024.socopgitmvlr                               
      close cbdbsr024_007 
     
      
      # busca eventos
      open cbdbsr024_006 using  mr_bdbsr024.ctbpezcod
                                       
      fetch cbdbsr024_006 into mr_bdbsr024.srvpovevncod,
                               mr_bdbsr024.srvajsevncod,
                               mr_bdbsr024.srvbxaevncod,
                               mr_bdbsr024.srvpgtevncod,
                               mr_bdbsr024.srvatdctecod 
                               
      close cbdbsr024_006
      
      case mr_bdbsr024.srvatdctecod
        when 1  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PELA APOLICE "
        when 2  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PELA PROPOSTA"
        when 3  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PELO CENTRO DE CUSTO COM APOLICE"
        when 4  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PELO CENTRO DE CUSTO SEM APOLICE"
        when 5  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PELA CONTIGENCIA SEM CARGA"
        when 6  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO SEM DOCUMENTO"
        when 7  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA AUTOMOVEL "
        when 8  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA RESIDENCIA"
        when 9  let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA PASSAGEIRO"
        when 10 let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO POR CORTESIA RESSARSIVEL(COR/FUNC) "
        when 11 let mr_bdbsr024.srvatdctedes = "SERVICO ATENDIDO PSS(SERVICO AVULSO - EMP.43 )"
      end case
      
      output to report bdbsr024_relat()
      
      initialize  mr_bdbsr024.* to null     
          
   end foreach
  whenever error stop 
  
finish report bdbsr024_relat



end function

#-------------------------------------#
report bdbsr024_relat()
#-------------------------------------#

   output                  
                         
      left   margin    00  
      right  margin    00  
      top    margin    00  
      bottom margin    00  
      page   length    100  
                           
   format                             
                       
       first page header  
       
       print "NUMERO                    ", ASCII(9),
             "ANO                       ", ASCII(9),
             "ORIGEM                    ", ASCII(9),
             "EMPRESA                   ", ASCII(9),
             "ORDEM DE PAGAMENTO        ", ASCII(9),
             "SUCURSAL                  ", ASCII(9),
             "RAMO                      ", ASCII(9),
             "APOLICE                   ", ASCII(9),
             "ITEM                      ", ASCII(9),
             "ENDOSSO                   ", ASCII(9),
             "ORIGEM PROPOSTA           ", ASCII(9),
             "NUMERO PROPOSTA           ", ASCII(9),
             "CODIGO CARTEIRA           ", ASCII(9),
             "DESCRICAO CARTEIRA        ", ASCII(9),
             "VALOR DO SERVICO          ", ASCII(9),
             "VALOR PAGAMENTO           ", ASCII(9),
             "CODIGO PARAMETRIZACAO     ", ASCII(9),
             "TIPO DE ENVIO             ", ASCII(9),
             "EVENTO ENVIADO            ", ASCII(9),
             "DATA DO SERVICO           ", ASCII(9),
             "DATA ENVIO SERVICO        ", ASCII(9),
             "DATA CONTABIL             ", ASCII(9),
             "CENTRO DE CUSTO           ", ASCII(9)
       
       on every row 
          print mr_bdbsr024.atdsrvnum    , ASCII(9);        
          print mr_bdbsr024.atdsrvano    , ASCII(9);        
          print mr_bdbsr024.atdsrvorg    , ASCII(9);        
          print mr_bdbsr024.ciaempcod    , ASCII(9);
          print mr_bdbsr024.socopgnum    , ASCII(9);
          print mr_bdbsr024.succod       , ASCII(9);        
          print mr_bdbsr024.ramcod       , ASCII(9);        
          print mr_bdbsr024.aplnumdig    , ASCII(9);        
          print mr_bdbsr024.itmnumdig    , ASCII(9);        
          print mr_bdbsr024.edsnumref    , ASCII(9);        
          print mr_bdbsr024.prporg       , ASCII(9);        
          print mr_bdbsr024.prpnumdig    , ASCII(9);        
          print mr_bdbsr024.srvatdctecod , ASCII(9);        
          print mr_bdbsr024.srvatdctedes , ASCII(9);        
          print mr_bdbsr024.srvvlr       , ASCII(9);
          display "socopgitmvlr: ",mr_bdbsr024.socopgitmvlr 
          print mr_bdbsr024.socopgitmvlr , ASCII(9);         
          print mr_bdbsr024.ctbpezcod    , ASCII(9);
          
          case mr_bdbsr024.evntipcod
             when 1
                print "PROVISÃO"               , ASCII(9);
                print mr_bdbsr024.srvpovevncod , ASCII(9);  
                print mr_bdbsr024.atddat       , ASCII(9);
             when 2 
                print "AJUSTE"                 , ASCII(9);               
                print mr_bdbsr024.srvajsevncod , ASCII(9); 
                print mr_bdbsr024.socfatpgtdat , ASCII(9);
             when 4
                print "CANCELAMENTO"           , ASCII(9);               
                print mr_bdbsr024.srvbxaevncod , ASCII(9);
                print mr_bdbsr024.cnldat       , ASCII(9);
             when 5
                print "PAGAMENTO"              , ASCII(9);               
                print mr_bdbsr024.srvpgtevncod , ASCII(9);
                print mr_bdbsr024.socfatpgtdat , ASCII(9);
             otherwise
                print "NAO CADASTRADO"         , ASCII(9);               
                print "0"                      , ASCII(9);
                print "NAO CADASTRADO"         , ASCII(9);
          end case
          
          let mr_bdbsr024.datacontabil = ctb00g16_datacompetencia()
          
          print mr_bdbsr024.regiclhrrdat , ASCII(9); 
          print mr_bdbsr024.datacontabil , ASCII(9); 
          print mr_bdbsr024.cctcod       , ASCII(9)

end report


#=============================================================================
function bdbsr024_email_provisi(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
     # COMPACTA O ARQUIVO DO RELATORIO
        let l_comando = "gzip -f ", param.path
        run l_comando

        let param.path = param.path  clipped, ".gz "
     
    let param.descricao = param.descricao clipped, m_data
    let l_retorno = ctx22g00_envia_email("BDBSA101", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsa101 "
       end if
    end if    
 whenever error stop 

end function 
