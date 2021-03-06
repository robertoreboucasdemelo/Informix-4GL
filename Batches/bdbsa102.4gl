#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
# ............................................................................ #
# Sistema        : PORTO SOCORRO                                               #
# Modulo         : bdbsa102                                                    #
#                  Batch de cancelamento de provisionamento para servi�os ana- #
#                  lisados e marcados como cancelados no dia anterior.         #
# Analista Resp. : Carlos Zyon                                                 #
#..............................................................................#
# Desenvolvimento: Fabrica de Software, JUNIOR                                 #
# OSF            : 35050                                                       #
# PSI            : 182516                                                      #
# Liberacao      :                                                             #
#..............................................................................#
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ -------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias  ncluida funcao fun_dba_abre_banco.  #
# 10/07/2009  Fabio Costa  198404  Tratar servico provisionavel                #
# 12/11/2014 Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada  #
#                                          Camada Contabil"                    #
###############################################################################
database porto

define m_bdbsa102   record
    atdsrvnum       like datmsrvanlhst.atdsrvnum,
    atdsrvano       like datmsrvanlhst.atdsrvano
end record

   define mr_retorno record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(1000),                               
    ctbevnpamcod like dbskctbevnpam.ctbevnpamcod,
    srvpovevncod like dbskctbevnpam.srvpovevncod,
    srvajsevncod like dbskctbevnpam.srvajsevncod,
    srvbxaevncod like dbskctbevnpam.srvbxaevncod,
    empcod       like dbskctbevnpam.empcod      ,
    pcpsgrramcod like dbskctbevnpam.pcpsgrramcod,
    pcpsgrmdlcod like dbskctbevnpam.pcpsgrmdlcod,
    ctbsgrramcod like dbskctbevnpam.ctbsgrramcod,
    ctbsgrmdlcod like dbskctbevnpam.ctbsgrmdlcod,
    pgoclsflg    like dbskctbevnpam.pgoclsflg   ,
    srvdcrcod    like dbskctbevnpam.srvdcrcod   ,
    itaasstipcod like dbskctbevnpam.itaasstipcod,
    bemcod       like dbskctbevnpam.bemcod      ,
    srvatdctecod like dbskctbevnpam.srvatdctecod,
    c24astagp    like dbskctbevnpam.c24astagp   , 
    atopamflg    like dbskctbevnpam.atopamflg   ,
    srvvlr       like dbsmatdpovhst.srvvlr      ,
    succod       like datrservapol.succod       , 
    ramcod       like datrservapol.ramcod       , 
    modalidade   like rsamseguro.rmemdlcod      , 
    aplnumdig    like datrservapol.aplnumdig    , 
    itmnumdig    like datrservapol.itmnumdig    , 
    edsnumref    like datrservapol.edsnumref    , 
    prporg       like datrligprp.prporg         , 
    prpnumdig    like datrligprp.prpnumdig      , 
    corsus       like abamcor.corsus            ,
    descclscod   char(100)          
 end record  

define m_sequencia  like datmsrvanlhst.srvanlhstseq
define m_saida      char(200)
define m_atddat     date
define m_ult_seq    like datmsrvanlhst.srvanlhstseq
define m_log        char(200)
define m_path	      char(100)
define l_path	      char(100)
define m_path2      char(100)
define m_path3      char(100)

define l_totopg smallint, l_toterr smallint   

#--------------------------------------------------------------------------#
main

    call fun_dba_abre_banco("CT24HS")
    call f_path("DBS", "LOG") returning m_saida

    if m_saida is null then
        let m_log = "bdbsa102.log"
    else
        let m_log = m_saida clipped, "/bdbsa102.log"
    end if

    call startlog (m_log)
    
    let m_path = f_path("DBS", "RELATO")         
      if m_path is null then                      
        let m_path = "."                         
      end if                                      
    
    let m_path2 = m_path clipped, "/BDBSA102_erro.txt"
    
    let m_path3 = m_path clipped, "/BDBSA102.xls"
    
     let m_path = m_path clipped, "/BDBSA102.txt"
    
    
    
    initialize m_bdbsa102.* to null
    
    initialize mr_retorno.* to null
    
    start report bdbsa102_resumo to m_path
    
    start report bdbsa102_resumo_contabil to m_path2
    
    start report bdbsa102_resumo_excel to m_path3

    call bdbsa102()
    
    
    finish report bdbsa102_resumo
     
    finish report bdbsa102_resumo_contabil
     
    finish report bdbsa102_resumo_excel
     
    #call bdbsa102_email_provisi(m_path3,"Excel do Cancelamento da Provisao para o dia: ")
    
    call bdbsa102_email_contabil(m_path,"Resumo do Cancelamento da Provisao para o dia: ")
    
    
    call bdbsa102_email_contabil(m_path2,"Erro de baixa para o dia: ")
    
    
     display "------------------------------------------------------------"
     display " RESUMO:  "
     display " OPs processados.: ", l_totopg using "######&&"
     display " OPs desprezados.: ", l_toterr using "######&&"
     display "------------------------------------------------------------"
    
    

end main
#--------------------------------------------------------------------------#

#--------------------------------------------------------------------------#
#------------   P R E P A R A N D O   C U R S O R E S  --------------------#
#--------------------------------------------------------------------------#
function bdbsa102_seleciona_sql()
#--------------------------------------------------------------------------#

    define l_cmd char(800)

    ### // Seleciona servi�os analisados e n�o pagos na data //
    let l_cmd = " select srvanlhstseq, atdsrvnum, atdsrvano "
               ,"   from datmsrvanlhst "
               ,"  where caddat = ? "
               ,"    and c24fsecod = 3 "   ## // Analisado e n�o pago //

    prepare pbdbsa102001 from l_cmd
    declare cbdbsa102001 cursor with hold for pbdbsa102001

    ### // Verifica se � a �ltima sequencia //
    let l_cmd = " select max(srvanlhstseq) "
               ,"   from datmsrvanlhst "
               ,"  where atdsrvnum = ? "
               ,"    and atdsrvano = ? " ## // Analisado e n�o pago //

    prepare pbdbsa102002 from l_cmd
    declare cbdbsa102002 cursor with hold for pbdbsa102002

    ### // Seleciona os dados da baixa //
    let l_cmd = " select opgvlr "
               ,"   from ctimsocprv "
               ,"  where atdsrvnum = ? "
               ,"    and atdsrvano = ? "
               ,"    and prvmvttip = 4 "   ### // Baixa //

    prepare pbdbsa102003 from l_cmd
    declare cbdbsa102003 cursor for pbdbsa102003

    let l_cmd = " select socopgnum from dbsmopg "
    		         ," where socopgsitcod = 8 "
    		         ," and atldat = ? "
    prepare pbdbsa102004 from l_cmd
    declare cbdbsa102004 cursor for pbdbsa102004

    let l_cmd = " select atdsrvnum, atdsrvano "
    		         ," from dbsmopgitm "
    		         ," where socopgnum = ? "
    prepare pbdbsa102005 from l_cmd
    declare cbdbsa102005 cursor for pbdbsa102005


end function
#----------------------------------------------------------------------#
function bdbsa102()
#----------------------------------------------------------------------#

  define ws_sqlcode   integer
  define ws_opgvlr    like ctimsocprv.opgvlr
  define ws record
         socopgnum  like dbsmopg.socopgnum,
         atdsrvnum like dbsmopgitm.atdsrvnum,
         atdsrvano  like dbsmopgitm.atdsrvano
  end record

  define lr_par  record
         evento          char(06),
         empresa         char(50),
         dt_movto        date,
         chave_primaria  char(50),
         op              char(50),
         apolice         char(50),
         sucursal        char(50),
         projeto         char(50),
         dt_chamado      date,
         fvrcod          char(50),
         fvrnom          char(50),
         nfnum           char(50),
         corsus          char(50),
         cctnum          char(50),
         modalidade      char(50),
         ramo            char(50),
         opgvlr          char(50),
         dt_vencto       date,
         dt_ocorrencia   date
  end record

  define lr_par2 record
         evento          char(06),
         empresa         char(50),
         dt_movto        date,
         chave_primaria  char(50),
         op              char(50),
         apolice         char(50),
         sucursal        char(50),
         projeto         char(50),
         dt_chamado      date,
         fvrcod          char(50),
         fvrnom          char(50),
         nfnum           char(50),
         corsus          char(50),
         cctnum          char(50),
         modalidade      char(50),
         ramo            char(50),
         opgvlr          char(50),
         dt_vencto       date,
         dt_ocorrencia   date
  end record
  
  
  
  display 'Inicio cancelamento de provisionamento:'
  
  let m_atddat = arg_val(1)
  let l_totopg = 0
  let l_toterr = 0
  
  ### // Utiliza data recebida, sen�o utiliza dia anterior //
  call bdbsa102_seleciona_sql()
  if m_atddat is null or
     m_atddat = " "   then
      let m_atddat = today - 1
  else
      if m_atddat > today then
          display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
          call errorlog("*** ERRO NO PARAMETRO: DATA INVALIDA! ***")
          return
      end if
  end if

  #start report bdbsr102_baixa_relatorio to m_path
  open cbdbsa102001   using m_atddat
  foreach cbdbsa102001 into m_sequencia,
                            m_bdbsa102.atdsrvnum,
                            m_bdbsa102.atdsrvano

     ### // Verifica se � a �ltima sequencia //
     open cbdbsa102002 using m_bdbsa102.atdsrvnum,
                             m_bdbsa102.atdsrvano
     fetch cbdbsa102002 into m_ult_seq

     if m_sequencia <> m_ult_seq then
         initialize m_bdbsa102.* to null
         continue foreach
     end if

     
     ### // Chama a interface de provisionamento //   
     
     call ctb00g16_bxaprvdsp (m_bdbsa102.atdsrvnum,
                              m_bdbsa102.atdsrvano)
                   returning mr_retorno.erro        ,
                             mr_retorno.msgerro     ,
                             mr_retorno.ctbevnpamcod,
                             mr_retorno.srvpovevncod,
                             mr_retorno.srvajsevncod,
                             mr_retorno.srvbxaevncod, 
                             mr_retorno.empcod      , 
                             mr_retorno.pcpsgrramcod, 
                             mr_retorno.pcpsgrmdlcod, 
                             mr_retorno.ctbsgrramcod, 
                             mr_retorno.ctbsgrmdlcod, 
                             mr_retorno.pgoclsflg   , 
                             mr_retorno.srvdcrcod   ,
                             mr_retorno.itaasstipcod,
                             mr_retorno.bemcod      ,
                             mr_retorno.srvatdctecod,
                             mr_retorno.c24astagp   ,
                             mr_retorno.atopamflg   , 
                             mr_retorno.srvvlr       
                                         
     if mr_retorno.msgerro is not null then
         output to report bdbsa102_resumo_contabil(mr_retorno.msgerro clipped)
         #continue foreach
     else
     
          
        call cts00g09_apolice(m_bdbsa102.atdsrvnum, 
                              m_bdbsa102.atdsrvano,
                              4, # tipo de retorno
                              mr_retorno.empcod,
                              0) # tipo da OP - Como nao tem coloca zero
          returning mr_retorno.succod,    
                    mr_retorno.ramcod,    
                    mr_retorno.modalidade,
                    mr_retorno.aplnumdig, 
                    mr_retorno.itmnumdig, 
                    mr_retorno.edsnumref, 
                    mr_retorno.prporg,    
                    mr_retorno.prpnumdig,
                    mr_retorno.corsus
          
        display "Evento: ",mr_retorno.srvbxaevncod
        if mr_retorno.srvvlr < 0 then  
          let mr_retorno.srvvlr = mr_retorno.srvvlr *(-1)
        end if 
                        
        call ctb00g16_envio_contabil(mr_retorno.srvbxaevncod,   
                                     mr_retorno.empcod      ,   
                                     mr_retorno.succod      ,   
                                     mr_retorno.ctbsgrramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                     mr_retorno.ctbsgrmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                     mr_retorno.aplnumdig   ,                                        
                                     mr_retorno.itmnumdig   ,   
                                     mr_retorno.edsnumref   ,   
                                     mr_retorno.prporg      ,   
                                     mr_retorno.prpnumdig   ,   
                                     mr_retorno.corsus      ,   
                                     mr_retorno.srvvlr      ,   
                                     m_bdbsa102.atdsrvnum   ,   
                                     m_bdbsa102.atdsrvano   ,   
                                     0                      ,
                                     mr_retorno.srvatdctecod,
                                     m_atddat)
        output to report bdbsa102_resumo_excel()  
     end if
     
                 
     
      ###Baixa antiga //
     open cbdbsa102003 using m_bdbsa102.atdsrvnum,
                             m_bdbsa102.atdsrvano
     fetch cbdbsa102003 into ws_opgvlr

     ### // Se j� foi baixado, continua //
     if sqlca.sqlcode = 0 then
         initialize m_bdbsa102.* to null
         continue foreach
     end if

     ### // Chama a interface de provisionamento //
     call ctb00g03_bxaprvdsp(m_bdbsa102.atdsrvnum,
                             m_bdbsa102.atdsrvano)
                   returning ws_sqlcode, lr_par.*
                   
     if ws_sqlcode != 0
        then
        display "* Erro ", ws_sqlcode, " em ctb00g03_bxaprvdsp: ",
                m_bdbsa102.atdsrvnum, m_bdbsa102.atdsrvano
        call errorlog("*** ERRO NA FUNCAO ctb00g03_bxaprvdsp ***")
        exit foreach
     end if
     
     
     initialize m_bdbsa102.* to null  
     initialize mr_retorno.* to null  
     
  end foreach
  
  #finish report bdbsr102_baixa_relatorio  
  
end function

#--------------------------------------------------------------------------
report bdbsa102_resumo(l_linha)
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
report bdbsa102_resumo_excel()
#--------------------------------------------------------------------------

output
    page length    99
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format
    
     first page header  
             
       print "NUMERO DO SERVICO     ", ASCII(9),   
             "ANO DO SERVICO        ", ASCII(9),   
             "EMPRESA               ", ASCII(9),
             "DECORRENCIA           ", ASCII(9),   
             "BEM ATENDIDO          ", ASCII(9),  
             "PARA QUEM PREST SRV   ", ASCII(9),
             "GRUPO DE ASSUNTO      ", ASCII(9), 
             "SEQUENCIA             ", ASCII(9),
             "CARTEIRA              ", ASCII(9),
             "RAMO PRINCIPAL        ", ASCII(9),
             "MODALIDADE PRINCIPAL  ", ASCII(9),
             "RAMO CONTABIL         ", ASCII(9),
             "MODALIDADE CONTABIL   ", ASCII(9),
             "CLAUSULA PAGA?        ", ASCII(9),
             "STATUS PARAMETRIZACAO ", ASCII(9),  
             "VALOR BAIXA           ", ASCII(9),
             "EVENTO PROVISAO       ", ASCII(9),
             "EVENTO AJUSTE         ", ASCII(9),
             "EVENTO BAIXA          ", ASCII(9)   
             
  on every row    
                                                         
       print m_bdbsa102.atdsrvnum    , ASCII(9);
       print m_bdbsa102.atdsrvano    , ASCII(9);
       print mr_retorno.empcod       , ASCII(9);
       print mr_retorno.srvdcrcod    , ASCII(9);
       print mr_retorno.bemcod       , ASCII(9);
       print mr_retorno.itaasstipcod , ASCII(9);
       print mr_retorno.c24astagp    , ASCII(9);
       print mr_retorno.ctbevnpamcod , ASCII(9);
       print mr_retorno.srvatdctecod , ASCII(9);
       print mr_retorno.pcpsgrramcod , ASCII(9);
       print mr_retorno.pcpsgrmdlcod , ASCII(9);
       print mr_retorno.ctbsgrramcod , ASCII(9);
       print mr_retorno.ctbsgrmdlcod , ASCII(9);
       print mr_retorno.pgoclsflg    , ASCII(9);
       print mr_retorno.atopamflg    , ASCII(9);
       print mr_retorno.srvvlr       , ASCII(9);
       print mr_retorno.srvpovevncod , ASCII(9);
       print mr_retorno.srvajsevncod , ASCII(9);
       print mr_retorno.srvbxaevncod , ASCII(9)
       
       
       
 end report 


#--------------------------------------------------------------------------
report bdbsa102_resumo_contabil(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(1000)

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

#=============================================================================
function bdbsa102_email_provisi(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(100)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
     # COMPACTA O ARQUIVO DO RELATORIO
        let l_comando = "gzip -f ", param.path
        run l_comando

        let param.path = param.path  clipped, ".gz "
     
    let param.descricao = param.descricao clipped, m_atddat 
    let l_retorno = ctx22g00_envia_email("BDBSA102", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsa102 "
       end if
    end if    
 whenever error stop 

end function 



#=============================================================================
function bdbsa102_email_contabil(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(100)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
    let param.descricao = param.descricao clipped, m_atddat 
    let l_retorno = ctx22g00_envia_email("BDBSA102", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsa102 "
       end if
    end if    
 whenever error stop 

end function
