#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR035                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: EXTRACAO CARRO EXTRA MOTIVOS                               #
#                  - CARRO EXTRA PAGOS                                        #
#                  - CARRO EXTRA ATENDIDOS                                    #
# ........................................................................... #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 08/05/2015                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_path    char(100),
        m_path_b  char(100),
        m_path_txt char(100),
        m_path_b_txt char(100),
        m_mes_int smallint,
        m_tmpcrs  datetime year to second

 define mr_datmservico record
    atddat            like datmservico.atddat
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
   ,atdsrvorg         like datmservico.atdsrvorg
   ,ciaempcod         like datmservico.ciaempcod
 end record

 define mr_datmavisrent record
    slccctcod          like datmavisrent.slccctcod 
   ,slcmat             like datmavisrent.slcmat   
   ,slcemp             like datmavisrent.slcemp
 end record

 define mr_datrvcllocrsrcmp  record
    rsrprvdiaqtd       like datrvcllocrsrcmp.rsrprvdiaqtd 
   ,rsrutidiaqtd       like datrvcllocrsrcmp.rsrutidiaqtd   
   ,rsrdialimqtd       like datrvcllocrsrcmp.rsrdialimqtd
   ,locprgflg          like datrvcllocrsrcmp.locprgflg
 end record

 define mr_datkitarsrcaomtv record
    itarsrcaomtvcod    like datkitarsrcaomtv.itarsrcaomtvcod
   ,itarsrcaomtvdes    like datkitarsrcaomtv.itarsrcaomtvdes
 end record

 define mr_isskfunc record
    funnom             like isskfunc.funnom
 end record

 define mr_dbsmopg record
     socopgnum         like dbsmopg.socopgnum
    ,succod            like dbsmopg.succod 
    ,socfatpgtdat      like dbsmopg.socfatpgtdat
 end record 
 
 define mr_datmatd6523 record
     succod            like datmatd6523.succod 
 end record
   
 main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr035_busca_path()

    call bdbsr035_prepare()

    call cts40g03_exibe_info("I","BDBSR035")

    set isolation to dirty read
    
    call bdbsr035_carroExtraPagos()

    call bdbsr035_carroExtraAtendidos()
    
    call bdbsr035_envia_email()
    
    call cts40g03_exibe_info("F","BDBSR035")

 end main

#------------------------------#
 function bdbsr035_busca_path()
#------------------------------#

     define l_dataarq char(8)
     define l_data    date
     
     let l_data = today
     display "l_data: ", l_data
     let l_dataarq = extend(l_data, year to year),
                     extend(l_data, month to month),
                     extend(l_data, day to day)
     display "l_dataarq: ", l_dataarq

    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr035.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if
    
    let m_path_txt = m_path clipped, "/BDBSR035_", l_dataarq, ".txt"
    let m_path_b_txt = m_path clipped, "/BDBSR035B_", l_dataarq, ".txt"
    
    let m_path_b = m_path clipped, "/BDBSR035B", l_dataarq, ".xls"
    let m_path   = m_path clipped, "/BDBSR035", l_dataarq, ".xls"
    
 end function

#---------------------------#
 function bdbsr035_prepare()
#---------------------------#
    define l_sql char(1000)
    define l_data_inicio, l_data_fim date
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    let l_data_atual = arg_val(1)
    
    # ---> OBTER A DATA E HORA DO BANCO
    if l_data_atual is null then
       call cts40g03_data_hora_banco(2)
            returning l_data_atual,
                      l_hora_atual
    end if                
    display "l_data_atual: ",l_data_atual
    
    # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
    if  month(l_data_atual) = 01 then
        let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
        let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)

    else
        #let l_data_inicio = mdy(month(l_data_atual),01,year(l_data_atual))
        let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
        let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
        #let l_data_fim = l_data_atual
    end if
    display "l_data_inicio: ",l_data_inicio 
    display "l_data_fim: ",l_data_fim
    
    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(l_data_inicio)
    
    # ---> OBTEM DADOS PARA O RELATORIO
    let l_sql = " select srv.atddat                    "
               ,"       ,srv.atdsrvnum                 "
               ,"       ,srv.atdsrvano                 "
               ,"       ,srv.ciaempcod                 "
               ,"       ,opg.socopgnum                 "   
               ,"       ,opg.socfatpgtdat              "   
               ,"       ,opg.succod                    "   
               ,"   from datmservico srv               "
               ,"       ,dbsmopg opg		               "
               ,"       ,dbsmopgitm itm                "
               ,"  where srv.atdsrvnum = itm.atdsrvnum "
               ,"    and srv.atdsrvano = itm.atdsrvano "
               ,"    and itm.socopgnum = opg.socopgnum "
               ,"    and opg.socfatpgtdat between'", l_data_inicio, "' and '", l_data_fim, "'"
               ,"    and srv.ciaempcod = 84            "
               ,"    and srv.atdsrvorg = 8             "
               ,"    and opg.socopgsitcod = 7          "
    prepare pbdbsr035001 from l_sql            
    declare cbdbsr035001 cursor for pbdbsr035001   
    
    let l_sql = " select srv.atddat                   "
               ,"       ,srv.atdsrvnum                "
               ,"       ,srv.atdsrvano                "
               ,"       ,srv.ciaempcod                "
               ,"   from datmservico srv              "
               ,"  where srv.atddat between'", l_data_inicio, "' and '", l_data_fim, "'"
               ,"    and srv.ciaempcod = 84           "
               ,"    and srv.atdsrvorg = 8            " 
   prepare pbdbsr035001b from l_sql            
   declare cbdbsr035001b cursor for pbdbsr035001b  
   
    let l_sql = " select slcmat         "
               ,"       ,slcemp         "
               ,"       ,slccctcod      "
               ,"   from datmavisrent   "
               ,"  where atdsrvnum = ?  "
               ,"    and atdsrvano = ?  "
    prepare pbdbsr035002 from l_sql            
    declare cbdbsr035002 cursor for pbdbsr035002 
   
    let l_sql = " select funnom             "
               ,"   from isskfunc           "
               ,"  where funmat = ?         "
               ,"    and empcod = ?         "
               ,"    and rhmfunsitcod = 'A' "
    prepare pbdbsr035003 from l_sql            
    declare cbdbsr035003 cursor for pbdbsr035003 
   
    let l_sql = " select mtv.itarsrcaomtvcod                        "
               ,"       ,mtv.itarsrcaomtvdes                        "
               ,"       ,cpm.rsrprvdiaqtd                           "
               ,"       ,cpm.rsrutidiaqtd                           "
               ,"       ,cpm.rsrdialimqtd                           "
               ,"       ,cpm.locprgflg                              "
               ,"   from datkitarsrcaomtv mtv                       "
               ,"       ,datrvcllocrsrcmp cpm                       "
               ,"  where cpm.itarsrcaomtvcod = mtv.itarsrcaomtvcod  "
               ,"   and cpm.atdsrvnum = ?                           "
               ,"   and cpm.atdsrvano = ?                           "
    prepare pbdbsr035004 from l_sql            
    declare cbdbsr035004 cursor for pbdbsr035004 
    
    let l_sql = " select atd.succod              "
               ,"   from datmatd6523 atd         "
               ,"       ,datmligacao lig         "
               ,"       ,datratdlig rel          "
               ,"  where lig.lignum = rel.lignum "
               ,"    and rel.atdnum = atd.atdnum "
               ,"    and lig.atdsrvnum = ?       "
               ,"    and lig.atdsrvano = ?       "
    prepare pbdbsr035004b from l_sql            
    declare cbdbsr035004b cursor for pbdbsr035004b
   
    let l_sql = " select mtv.itarsrcaomtvcod                        "
               ,"       ,mtv.itarsrcaomtvdes                        "
               ,"       ,cpm.rsrprvdiaqtd                           "
               ,"       ,cpm.rsrutidiaqtd                           "
               ,"       ,cpm.rsrdialimqtd                           "
               ,"       ,cpm.locprgflg                              "
               ,"   from datkitarsrcaomtv mtv                       "
               ,"       ,datrvcllocrsrcmp cpm                       "
               ,"  where cpm.itarsrcaomtvcod = mtv.itarsrcaomtvcod  "
               ,"   and cpm.atdsrvnum = ?                           "
               ,"   and cpm.atdsrvano = ?                           "
    prepare pbdbsr035005 from l_sql            
    declare cbdbsr035005 cursor for pbdbsr035005  

end  function

#-----------------------------------#
 function bdbsr035_carroExtraPagos()
#-----------------------------------#

   initialize mr_datmservico.*
             ,mr_datmavisrent.*
             ,mr_isskfunc.*
             ,mr_dbsmopg.*
              to null

   start report bdbsr035_relatorio to m_path
   start report bdbsr035_relatorio_txt to m_path_txt

   let m_tmpcrs = current
   open cbdbsr035001
   let m_tmpcrs = current
   display "foreach cbdbsr035001 : ", m_tmpcrs

   foreach cbdbsr035001 into  mr_datmservico.atddat
                             ,mr_datmservico.atdsrvnum
                             ,mr_datmservico.atdsrvano
                             ,mr_datmservico.ciaempcod
                             ,mr_dbsmopg.socopgnum
                             ,mr_dbsmopg.socfatpgtdat
                             ,mr_dbsmopg.succod
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035001 ', sqlca.sqlcode 
         end if  
                        
      let m_tmpcrs = current
      
      open cbdbsr035002 using  mr_datmservico.atdsrvnum   
                              ,mr_datmservico.atdsrvano
      fetch cbdbsr035002 into  mr_datmavisrent.slcmat  
                              ,mr_datmavisrent.slcemp  
                              ,mr_datmavisrent.slccctcod    
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035002 ', sqlca.sqlcode 
         end if  
      close cbdbsr035002
      
      let m_tmpcrs = current
      
      open cbdbsr035003 using  mr_datmavisrent.slcmat  
                              ,mr_datmavisrent.slcemp 
      fetch cbdbsr035003 into  mr_isskfunc.funnom  
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035003 ', sqlca.sqlcode , '/',
		                 mr_datmavisrent.slcmat, '/', mr_datmavisrent.slcemp
         end if        
      close cbdbsr035003
      
      let m_tmpcrs = current
      
      open cbdbsr035004 using  mr_datmservico.atdsrvnum   
                              ,mr_datmservico.atdsrvano
      fetch cbdbsr035004 into  mr_datkitarsrcaomtv.itarsrcaomtvcod
                              ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                              ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                              ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                              ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                              ,mr_datrvcllocrsrcmp.locprgflg      
           if sqlca.sqlcode <> 0 then
              display 'Erro cbdbsr035004 ', sqlca.sqlcode 
           end if        
      close cbdbsr035004
      
      output to report bdbsr035_relatorio(mr_datmservico.atddat       		
                                         ,mr_datmservico.atdsrvnum    		
                                         ,mr_datmservico.atdsrvano    		
                                         ,mr_datmservico.ciaempcod    		
                                         ,mr_dbsmopg.socopgnum    		
                                         ,mr_dbsmopg.socfatpgtdat 		
                                         ,mr_dbsmopg.succod       		
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvcod
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                                         ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                                         ,mr_datrvcllocrsrcmp.locprgflg      
                                         ,mr_datmavisrent.slccctcod          
                                         ,mr_datmavisrent.slcmat             
                                         ,mr_isskfunc.funnom)
                                         
      output to report bdbsr035_relatorio_txt(mr_datmservico.atddat       		
                                         ,mr_datmservico.atdsrvnum    		
                                         ,mr_datmservico.atdsrvano    		
                                         ,mr_datmservico.ciaempcod    		
                                         ,mr_dbsmopg.socopgnum    		
                                         ,mr_dbsmopg.socfatpgtdat 		
                                         ,mr_dbsmopg.succod       		
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvcod
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                                         ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                                         ,mr_datrvcllocrsrcmp.locprgflg      
                                         ,mr_datmavisrent.slccctcod          
                                         ,mr_datmavisrent.slcmat             
                                         ,mr_isskfunc.funnom)
                                          
      initialize mr_datmservico.*
                ,mr_datmavisrent.* 
                ,mr_isskfunc.*  
                ,mr_dbsmopg.*
                 to null                 
                                          
   end foreach                            
                                          
   finish report bdbsr035_relatorio       
   finish report bdbsr035_relatorio_txt 
                                          
 end function                             
                                          
#---------------------------------------# 
 function bdbsr035_carroExtraAtendidos()  
#---------------------------------------#

   initialize mr_datmservico.*
             ,mr_datmavisrent.* 
             ,mr_isskfunc.*
             ,mr_datmatd6523.*
              to null
   
   start report bdbsr035_relatorio to m_path_b
   start report bdbsr035_relatorio_txt to m_path_b_txt

   let m_tmpcrs = current
   open cbdbsr035001b
   let m_tmpcrs = current
   display "foreach cbdbsr035001b : ", m_tmpcrs

   foreach cbdbsr035001b into  mr_datmservico.atddat   
                              ,mr_datmservico.atdsrvnum
                              ,mr_datmservico.atdsrvano     
                              ,mr_datmservico.ciaempcod
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035001 ', sqlca.sqlcode 
         end if  
                        
      let m_tmpcrs = current
      
      open cbdbsr035002 using  mr_datmservico.atdsrvnum   
                              ,mr_datmservico.atdsrvano
      fetch cbdbsr035002 into  mr_datmavisrent.slcmat  
                              ,mr_datmavisrent.slcemp  
                              ,mr_datmavisrent.slccctcod    
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035002 ', sqlca.sqlcode 
         end if  
      close cbdbsr035002
      
      let m_tmpcrs = current
      
      open cbdbsr035003 using  mr_datmavisrent.slcmat  
                              ,mr_datmavisrent.slcemp 
      fetch cbdbsr035003 into  mr_isskfunc.funnom  
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035003 ', sqlca.sqlcode , '/',
		                 mr_datmavisrent.slcmat, '/', mr_datmavisrent.slcemp
         end if        
      close cbdbsr035003
      
      let m_tmpcrs = current
      
      open cbdbsr035004b using  mr_datmservico.atdsrvnum   
                               ,mr_datmservico.atdsrvano
      fetch cbdbsr035004b into  mr_datmatd6523.succod  
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035004 ', sqlca.sqlcode 
         end if        
      close cbdbsr035004
      
      let m_tmpcrs = current
      
      open cbdbsr035005 using  mr_datmservico.atdsrvnum   
                              ,mr_datmservico.atdsrvano
      fetch cbdbsr035005 into  mr_datkitarsrcaomtv.itarsrcaomtvcod
                              ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                              ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                              ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                              ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                              ,mr_datrvcllocrsrcmp.locprgflg      
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr035004 ', sqlca.sqlcode 
         end if        
      close cbdbsr035005

      output to report bdbsr035_relatorio(mr_datmservico.atddat       		
                                         ,mr_datmservico.atdsrvnum    		
                                         ,mr_datmservico.atdsrvano    		
                                         ,mr_datmservico.ciaempcod    		
                                         ,""    		
                                         ,"" 		
                                         ,mr_datmatd6523.succod       		
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvcod
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                                         ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                                         ,mr_datrvcllocrsrcmp.locprgflg      
                                         ,mr_datmavisrent.slccctcod          
                                         ,mr_datmavisrent.slcmat             
                                         ,mr_isskfunc.funnom)
                                         
      output to report bdbsr035_relatorio_txt(mr_datmservico.atddat       		
                                         ,mr_datmservico.atdsrvnum    		
                                         ,mr_datmservico.atdsrvano    		
                                         ,mr_datmservico.ciaempcod    		
                                         ,""    		
                                         ,"" 		
                                         ,mr_datmatd6523.succod       		
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvcod
                                         ,mr_datkitarsrcaomtv.itarsrcaomtvdes
                                         ,mr_datrvcllocrsrcmp.rsrprvdiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrutidiaqtd   
                                         ,mr_datrvcllocrsrcmp.rsrdialimqtd   
                                         ,mr_datrvcllocrsrcmp.locprgflg      
                                         ,mr_datmavisrent.slccctcod          
                                         ,mr_datmavisrent.slcmat             
                                         ,mr_isskfunc.funnom)
 
      initialize mr_datmservico.*
                ,mr_datmavisrent.* 
                ,mr_isskfunc.*
                ,mr_datmatd6523.*
                 to null
                   
   end foreach  
   
   finish report bdbsr035_relatorio                                          
   finish report bdbsr035_relatorio_txt
   
 end function

#-------------------------------#
 function bdbsr035_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_mes_extenso char(010),
          l_erro_envio  integer

   case m_mes_int
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio Carro Extra Motivos (PAGOS) - ", l_mes_extenso clipped, " - BDBSR035"

   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue
    
   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   #let l_anexo = m_path clipped, ",", m_path_b clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR035", l_assunto, m_path)
   
   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR035"
       end if
   end if

   let l_assunto    = "Relatorio Carro Extra Motivos (ATENDIDOS) - ", l_mes_extenso clipped, " - BDBSR035B"

   let l_comando = "gzip -f ", m_path_b
   run l_comando
   let m_path_b = m_path_b clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR035B", l_assunto, m_path_b)
   
   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path_b clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR035B"
       end if
   end if

   whenever error stop

end function

#---------------------------------------#
 report bdbsr035_relatorio(lr_parametro)
#---------------------------------------#

   define lr_parametro    record
          atddat          like datmservico.atddat       		
        , atdsrvnum       like datmservico.atdsrvnum    		
        , atdsrvano       like datmservico.atdsrvano    		
        , ciaempcod       like datmservico.ciaempcod    		
        , socopgnum       like dbsmopg.socopgnum    		
        , socfatpgtdat    like dbsmopg.socfatpgtdat 		
        , succod          like dbsmopg.succod       		
        , itarsrcaomtvcod like datkitarsrcaomtv.itarsrcaomtvcod
        , itarsrcaomtvdes like datkitarsrcaomtv.itarsrcaomtvdes
        , rsrprvdiaqtd    like datrvcllocrsrcmp.rsrprvdiaqtd   
        , rsrutidiaqtd    like datrvcllocrsrcmp.rsrutidiaqtd   
        , rsrdialimqtd    like datrvcllocrsrcmp.rsrdialimqtd   
        , locprgflg       like datrvcllocrsrcmp.locprgflg      
        , slccctcod       like datmavisrent.slccctcod          
        , slcmat          like datmavisrent.slcmat             
        , funnom          like isskfunc.funnom
   end    record                
   
   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
     
             print "DATA ATENDIMENTO",         ASCII(09),
                   "SERVICO",                  ASCII(09),
                   "ANO",                      ASCII(09),
                   "EMPRESA",                  ASCII(09);
                                      
                   if lr_parametro.socopgnum is not null then
                      print "OP",              ASCII(09),
                            "DATA PAGAMENTO",  ASCII(09);
                   end if 
                   
             print "SUCURSAL",                 ASCII(09),
                   "CODIGO MOTIVO",            ASCII(09),
                   "DESCRICAO MOTIVO",         ASCII(09),
                   "DIAS PREVISTOS RESERVA",   ASCII(09),
                   "DIAS UTILIZADOS RESERVA",  ASCII(09),
                   "LIMITE DIAS RESERVA",      ASCII(09),
                   "PRORROGACAO",              ASCII(09),
                   "CODIGO CENTRO CUSTO",      ASCII(09),
                   "MATRICULA SOLICITANTE",    ASCII(09),
                   "NOME FUNCIONARIO",         ASCII(09) 

  on every row

  print lr_parametro.atddat,                   ASCII(09), 
        lr_parametro.atdsrvnum,                ASCII(09),  
        lr_parametro.atdsrvano,                ASCII(09),     
        lr_parametro.ciaempcod,                ASCII(09);
        
        if lr_parametro.socopgnum is not null then
            print lr_parametro.socopgnum,      ASCII(09),
                  lr_parametro.socfatpgtdat,   ASCII(09);
        end if 
                        
  print lr_parametro.succod,                   ASCII(09), 
        lr_parametro.itarsrcaomtvcod,          ASCII(09),
        lr_parametro.itarsrcaomtvdes,          ASCII(09),
        lr_parametro.rsrprvdiaqtd,             ASCII(09),
        lr_parametro.rsrutidiaqtd,             ASCII(09),
        lr_parametro.rsrdialimqtd,             ASCII(09),
        lr_parametro.locprgflg,                ASCII(09),  
        lr_parametro.slccctcod,                ASCII(09),
        lr_parametro.slcmat,                   ASCII(09),
        lr_parametro.funnom,                   ASCII(09)
        
 end report

#---------------------------------------#
 report bdbsr035_relatorio_txt(lr_parametro)
#---------------------------------------#

   define lr_parametro    record
          atddat          like datmservico.atddat       		
        , atdsrvnum       like datmservico.atdsrvnum    		
        , atdsrvano       like datmservico.atdsrvano    		
        , ciaempcod       like datmservico.ciaempcod    		
        , socopgnum       like dbsmopg.socopgnum    		
        , socfatpgtdat    like dbsmopg.socfatpgtdat 		
        , succod          like dbsmopg.succod       		
        , itarsrcaomtvcod like datkitarsrcaomtv.itarsrcaomtvcod
        , itarsrcaomtvdes like datkitarsrcaomtv.itarsrcaomtvdes
        , rsrprvdiaqtd    like datrvcllocrsrcmp.rsrprvdiaqtd   
        , rsrutidiaqtd    like datrvcllocrsrcmp.rsrutidiaqtd   
        , rsrdialimqtd    like datrvcllocrsrcmp.rsrdialimqtd   
        , locprgflg       like datrvcllocrsrcmp.locprgflg      
        , slccctcod       like datmavisrent.slccctcod          
        , slcmat          like datmavisrent.slcmat             
        , funnom          like isskfunc.funnom
   end    record                
   
   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       
  on every row

  print lr_parametro.atddat,                   ASCII(09), 
        lr_parametro.atdsrvnum,                ASCII(09),  
        lr_parametro.atdsrvano,                ASCII(09),     
        lr_parametro.ciaempcod,                ASCII(09);
        
        if lr_parametro.socopgnum is not null then
            print lr_parametro.socopgnum,      ASCII(09),
                  lr_parametro.socfatpgtdat,   ASCII(09);
        end if 
                        
  print lr_parametro.succod,                   ASCII(09), 
        lr_parametro.itarsrcaomtvcod,          ASCII(09),
        lr_parametro.itarsrcaomtvdes,          ASCII(09),
        lr_parametro.rsrprvdiaqtd,             ASCII(09),
        lr_parametro.rsrutidiaqtd,             ASCII(09),
        lr_parametro.rsrdialimqtd,             ASCII(09),
        lr_parametro.locprgflg,                ASCII(09),  
        lr_parametro.slccctcod,                ASCII(09),
        lr_parametro.slcmat,                   ASCII(09),
        lr_parametro.funnom 
        
 end report
