#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: BDBSA070                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 214566 - Gestao de Frota e Servicos                        #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 22/12/2008                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 09/02/2009 Sergio Burini              Rotinas Criticas                      #
#                                                                             #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca               #
#-----------------------------------------------------------------------------#

database porto

  define m_prcstt      like dpamcrtpcs.prcstt,
         m_tmpexp      datetime year to second,
         m_tmpchar     char(19),
         m_hora        char(02),
         m_mod         smallint,
         m_bol         smallint
         

main

  define l_path char(100)

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsa070.log"

  call startlog(l_path)

  call fun_dba_abre_banco("CT24HS")

  # --CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read

  # --TEMPO PARA VERIFICAR SE O REGISTRO ESTA ALOCADO
  set lock mode to wait 20

  # --PREPARA OS COMANDOS SQL
  call bdbsa070_prepare()

  let  m_tmpexp = current
  let  m_bol    = false

  while true

        call ctx28g00("bdbsa070", fgl_getenv("SERVIDOR"), m_tmpexp)
             returning m_tmpexp, m_prcstt
             
        #comentado em 04/10/2013 Por Jorge Modena
        #Agora mesmo com o AW ligado informix deverá enviar mensagem de complemento        
        if  m_prcstt = 'A' then        
            #if ctx34g00_ver_acionamentoWEB(2) then        
            #   display "AcionamentoWeb Ativo."            
            #else
               call bdbsa070()                        
            #end if 
        end if
        
        sleep 60

        let m_tmpchar = m_tmpexp
        let m_hora    = m_tmpchar[12,14]
        let m_mod     = m_hora mod 2

        if m_bol  = true and m_mod = 0 then
            display ""
            display "Termino para restart do programa bdbsa070: ", m_tmpexp
            display ""
            exit program
        else
            if m_mod = 1 then
                let m_bol = true
            end if
        end if

  end while

end main

#----------------------------#
function bdbsa070_prepare()
#----------------------------#

  define l_sql char(6000)

  #let l_sql = " select b.atdsrvnum, ",
  #            "        a.socvclcod, ",
  #            "        a.socvcllcltip, ",
  #            "        a.lclltt, ",
  #            "        a.lcllgt, ",
  #            "        a.atldat, ",
  #            "        a.atlhor ",
  #            "   from datmfrtpos a, dattfrotalocal b",
  #            "  where a.socvcllcltip = 1 ",
  #            "    and a.socvclcod = b.socvclcod ",
  #            "    and b.c24atvcod = 'REC' ",
  #            "  order by a.atldat, a.atlhor "
  #
  #prepare pbdbsa070001 from l_sql
  #declare cbdbsa070001 cursor with hold for pbdbsa070001
  #
  #let l_sql = " select lclltt, ",
  #            "        lcllgt, ",
  #            "        ufdcod  ",
  #            "   from datmfrtpos ",
  #            "  where socvclcod = ? ",
  #            "    and socvcllcltip = 2 "
  #
  #prepare pbdbsa070002 from l_sql
  #declare cbdbsa070002 cursor with hold for pbdbsa070002
  #
  #let l_sql = " update datmfrtpos set ocratldst = ? ",
  #            "  where socvclcod = ? ",
  #            "    and socvcllcltip = 1 "
  #
  #prepare pbdbsa070003 from l_sql
  
  
  
  
   
   # Busca o valor de parametro                     
   let l_sql = " select grlinf       ",           
               "   from datkgeral    ",           
               "  where grlchv = ?   "            
                                                 
   prepare pbdbsa070005 from l_sql                
   declare cbdbsa070005 cursor for pbdbsa070005
   
   #busca se serviço possui REC
   let l_sql = " select 1                ",  
               "  from datmmdtmvt        ",
               "  where atdsrvnum = ?    ",
               "    and atdsrvano = ?    ",
               "    and mdtmvttipcod = 2 ",
               "    and mdtbotprgseq = 1 "
   
   prepare pbdbsa070006 from l_sql                
   declare cbdbsa070006 cursor for pbdbsa070006                                          

   
   # Busca origens conforme empresa
   let l_sql = " select cpocod     ",
               "       ,cpodes     ",                   
              " from iddkdominio   ",       
             " where cponom = ?    "
             
          
   prepare pbdbsa070007 from l_sql                
   declare cbdbsa070007 cursor for pbdbsa070007 
   
   
                                                  
   # Busca data de corte conforme empresa               
   let l_sql = " select cpodes     ",             
              " from iddkdominio   ",             
             " where cponom = ?    ",             
             "  and  cpocod = ?    "              
                                                  
    prepare pbdbsa070008 from l_sql               
    declare cbdbsa070008 cursor for pbdbsa070008  
    
    
    let l_sql = "select 1 ",
                  " from dbsmenvmsgsms ",
                 " where smsenvcod = ? "

     prepare pbdbsa070010 from l_sql
     declare cbdbsa070010 cursor for pbdbsa070010
   
 
         
end function
   
#-----------------#
function bdbsa070()
#-----------------#
   
  define l_bdbsa070   record
         atdsrvnum    like datmservico.atdsrvnum,          
         atdsrvano    like datmservico.atdsrvano,
         socvclcod    like datmservico.socvclcod,
         atdsrvorg    like datmservico.atdsrvorg,
         ciaempcod    like datmservico.ciaempcod, 
         atddat       like datmservico.atddat
  end record
  
  define lr_cts29g00 record
         atdsrvnum    like datratdmltsrv.atdsrvnum,
         atdsrvano    like datratdmltsrv.atdsrvano,
         resultado    smallint,
         mensagem     char(100)
     end record

  define l_contingencia   smallint,
         l_agora          datetime hour to second,        
         l_data_atual     date,
         l_hora_atual     datetime hour to minute,       
         l_hora           datetime hour to minute,
         l_contador       smallint,
         l_lidos          smallint, 
         l_envtipcod      like datmsrvacp.envtipcod  
         
         
  define l_srvcbnhor       like datmservico.srvcbnhor,
         l_grlchv          char(15),
         l_atdsrvorg       like datmservico.atdsrvorg,
         l_dataini         datetime year to day,
         l_datafim         datetime year to day,
         l_horaini         datetime hour to minute,     
         l_horafim         datetime hour to minute,            
         l_qtdminexbini    smallint,
         l_qtdminexbfim    smallint, 
         l_datahoraini     datetime year to minute,         
         l_datahorafim     datetime year to minute, 
         l_erroflg         char(01), 
         l_ciaempcod       like datmservico.ciaempcod,
         l_origens         char(50),
         l_sql             char(6000),
         l_dominio         char(12),
         l_data            char(10),
         l_datacorte       datetime year to day,
         l_dia             char(02),
         l_mes             char(02),
         l_ano             char(04),
         l_status          smallint,
         l_codigoerro      smallint,
         l_msgerro         char(100),
         l_codigosms       like dbsmenvmsgsms.smsenvcod,
         l_tipomsg         smallint,
         l_tipoacionamento char(10),
         l_hora_atu        datetime hour to minute,
         l_atdetpdat       like datmsrvacp.atdetpdat,
         l_atdetphor       like datmsrvacp.atdetphor,
         l_espera          interval hour(06) to second,
         l_tempo_limite    interval hour(06) to second,
         l_regra_envio     char(100)

  initialize l_bdbsa070.* to null
  initialize lr_cts29g00.* to null
  let l_contingencia = null
  let l_data_atual  =  null
  let l_hora_atual  =  null
  let l_hora        =  null 
  let l_contador    =  0
  let l_lidos       =  0  
  let l_srvcbnhor    = null
  let l_grlchv       = null
  let l_atdsrvorg    = null
  let l_dataini      = null
  let l_datafim      = null
  let l_horaini      = null
  let l_horafim      = null
  let l_qtdminexbini = null
  let l_qtdminexbfim = null 
  let l_erroflg      = null 
  let l_ciaempcod    = null
  let l_origens      = null
  let l_sql          = null
  let l_dia          = null
  let l_mes          = null
  let l_ano          = null
  let l_status       = null
  let l_codigoerro   = null
  let l_msgerro      = null
  let l_tipomsg      = null
  let l_tipoacionamento = null
  let l_regra_envio = null
  
  call cta00m08_ver_contingencia(4) returning l_contingencia
  
  if l_contingencia then
     let l_agora = current
     display l_agora, " Contingencia Ativa/Carga ainda nao realizada"
  end if

  #if ctx34g00_ver_acionamentoWEB(2) then
  #   display "AcionamentoWeb Ativo."
  #   exit program 0
  #end if

  # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual 

  display "INICIO PROCESSAMENTO Data/Hora Atual: ", l_data_atual," ",l_hora_atual
  display ""
  
  #busca quantidade de minutos para inicio e fim para calcula periodo com base data/hora combinada com cliente
  let l_grlchv = "PSOEXBINIMINQTD"
         
  whenever error continue
     open cbdbsa070005 using l_grlchv     
      fetch cbdbsa070005 into l_qtdminexbini
      
      if sqlca.sqlcode <> 0 then
         let l_qtdminexbini = 30
      end if           
      
     close cbdbsa070005
  whenever error stop     
  
  
  #verifica fim 
  let l_grlchv = "PSOEXBFIMMINQTD"             
                                         
  whenever error continue                      
     open cbdbsa070005 using l_grlchv          
      fetch cbdbsa070005 into l_qtdminexbfim   
                                               
      if sqlca.sqlcode <> 0 then               
         let l_qtdminexbfim = 120               
      end if                                   
                                               
     close cbdbsa070005                       
  whenever error stop  
  
  
  let l_horaini     = current - l_qtdminexbini units minute
  let l_horafim     = current + l_qtdminexbfim units minute
  let l_dataini     = current - l_qtdminexbini units minute    
  let l_datafim      = current + l_qtdminexbfim units minute 
  let l_datahoraini = current - l_qtdminexbini units minute    
  let l_datahorafim = current + l_qtdminexbfim units minute  
   
  let l_grlchv = "EMPORGCTLSEG"        
  open cbdbsa070007 using l_grlchv
  
  let l_agora = current      
  display "INICIO SMS COMPLEMENTO GPS: ", l_agora         
  
  foreach cbdbsa070007 into l_ciaempcod, l_origens
                            
     let l_contador    =  0
     let l_lidos       =  0  
     let l_agora = current
     let l_origens = l_origens clipped
     let l_dominio = "DTACRTMSGCMP"
     let l_datacorte = null
     
     
     display "   Empresa/Origens: ", l_ciaempcod using "<#", '/', l_origens
     
     
     #verifica se existe data de corte cadastrada para empresa 
     
     whenever error continue 
     open cbdbsa070008 using l_dominio, l_ciaempcod
     fetch cbdbsa070008 into l_data
     if sqlca.sqlcode = 0 then     
        let l_dia       = l_data[1,2]
        let l_mes       = l_data[4,5]
        let l_ano       = l_data[7,10]          
        let l_datacorte = mdy(l_mes,l_dia,l_ano)     
     end if
     close cbdbsa070008 
     whenever error stop                         
         
     #montando consulta 
     let l_sql =  " SELECT srv.atdsrvnum, ",
               "        srv.atdsrvano, ",
               "        srv.socvclcod, ",
               "        srv.atdsrvorg, ",
               "        srv.ciaempcod, ",
               "        srv.atddat     ",
               "   FROM datmservico srv",
               "    INNER JOIN datmsrvacp acp", 
               "       ON (acp.atdsrvnum = srv.atdsrvnum ",
               "      AND acp.atdsrvano = srv.atdsrvano",
               "      AND acp.atdsrvseq = srv.atdsrvseq)",
               "     WHERE atddatprg IS NOT NULL",
               "       AND atdhorprg IS NOT NULL",
               "       AND acp.envtipcod = 1",
               "       AND ((atddatprg = ? AND atdhorprg >= ?)", #data e hora inicial
               "        OR (atddatprg > ?))",  #data inicial
               "       AND ((atddatprg = ? AND atdhorprg <= ? )", #data e hora final 
               "        OR (atddatprg < ?))", #data final
               "        AND ciaempcod in (",l_ciaempcod,")",
               "        AND atdsrvorg in (",l_origens,")",
               "        AND NOT EXISTS (SELECT msgsrv.mdtmsgnum",
               "                         FROM datmmdtsrv msgsrv",
               "                        INNER JOIN datmmdtmsg msg",
               "                                ON (msg.mdtmsgnum = msgsrv.mdtmsgnum AND mdtmsgorgcod = 2)",
               "                             WHERE msgsrv.atdsrvnum = srv.atdsrvnum",
               "                               AND msgsrv.atdsrvano = srv.atdsrvano)",              
               "   UNION",
               "    SELECT srv.atdsrvnum,",
               "           srv.atdsrvano,",
               "           srv.socvclcod,",
               "           srv.atdsrvorg,",
               "           srv.ciaempcod,", 
               "           srv.atddat    ",             
               "      FROM datmservico srv",
               "      INNER JOIN datmsrvacp acp", 
               "         ON (acp.atdsrvnum = srv.atdsrvnum", 
               "        AND acp.atdsrvano = srv.atdsrvano ",
               "        AND acp.atdsrvseq = srv.atdsrvseq)",
               "     WHERE atdlibdat IS NOT NULL",
               "       AND atdlibhor IS NOT NULL",
               "       AND acp.envtipcod = 1",                    
               "       AND ((atdlibdat = DATE(CURRENT - 360 UNITS MINUTE)", ##data de liberacao 
               "       AND atdlibhor >= (CURRENT - 360 UNITS MINUTE)) ",    ##hora liberacao
               "        OR (atdlibdat > DATE(CURRENT - 360 UNITS MINUTE)))",
               "       AND ((atdlibdat = DATE(CURRENT) and atdlibhor <= (CURRENT + 360 UNITS MINUTE))",
               "        OR (atdlibdat < DATE(current)))",
               "       AND srvcbnhor between ? and ?", #data/hora inicial e final
               "        AND ciaempcod in (",l_ciaempcod,")",
               "        AND atdsrvorg in (",l_origens,")",
               "       AND NOT EXISTS (SELECT msgsrv.mdtmsgnum",
               "                         FROM datmmdtsrv msgsrv",
               "                         INNER JOIN datmmdtmsg msg", 
               "                            ON (msg.mdtmsgnum = msgsrv.mdtmsgnum AND mdtmsgorgcod = 2)",
               "                        WHERE msgsrv.atdsrvnum = srv.atdsrvnum",
               "                          AND msgsrv.atdsrvano = srv.atdsrvano)"
               
  
   prepare pbdbsa070004 from l_sql                               
   declare cbdbsa070004 cursor with hold for pbdbsa070004       
  

   open cbdbsa070004 using l_dataini, l_horaini,
                           l_dataini, 
                           l_datafim, l_horafim,
                           l_datafim, l_datahoraini,
                           l_datahorafim
                           
   #quando for criado indice para campo srvcbnhor na datmservico , rever select                        
   foreach cbdbsa070004 into l_bdbsa070.atdsrvnum,
                             l_bdbsa070.atdsrvano,
                             l_bdbsa070.socvclcod,
                             l_bdbsa070.atdsrvorg,
                             l_bdbsa070.ciaempcod, 
                             l_bdbsa070.atddat
                             
      
      let l_lidos = l_lidos + 1
            
      #display "l_bdbsa070.atdsrvnum",l_bdbsa070.atdsrvnum
      #display "l_bdbsa070.atdsrvano",l_bdbsa070.atdsrvano
      #display "l_bdbsa070.socvclcod",l_bdbsa070.socvclcod
      #display "l_bdbsa070.atdsrvorg",l_bdbsa070.atdsrvorg
      #display "l_bdbsa070.ciaempcod",l_bdbsa070.ciaempcod  
      
      if l_datacorte is null or l_bdbsa070.atddat >= l_datacorte then
         ##verifica se servico é multiplo , se for só envia complemento para serviço original
         if l_bdbsa070.atdsrvorg = 9 or l_bdbsa070.atdsrvorg = 13 then
            call cts29g00_consistir_multiplo(l_bdbsa070.atdsrvnum, l_bdbsa070.atdsrvano)
                        returning lr_cts29g00.resultado,
                                  lr_cts29g00.mensagem,
                                  lr_cts29g00.atdsrvnum,
                                  lr_cts29g00.atdsrvano
                                  
                                  
             
            if  lr_cts29g00.resultado = 1 then 
                #servico é multiplo 
                continue foreach
            end if
         end if
         
         #verifica se serviço já teve REC
         
         open cbdbsa070006 using l_bdbsa070.atdsrvnum, l_bdbsa070.atdsrvano
         
         fetch cbdbsa070006 
         
         if sqlca.sqlcode = 0 then               
            call cts00g02_env_msg_cmp(2
                                     ,l_bdbsa070.atdsrvnum 
                                     ,l_bdbsa070.atdsrvano
                                     ,""
                                     ,l_bdbsa070.socvclcod)
            returning l_erroflg
            
            close cbdbsa070006       
            
            if l_erroflg != 'S' then 
               let l_contador = l_contador + 1
            end if
         else
            close cbdbsa070006        
            continue foreach             
         end if
      else 
         continue foreach 
      end if
      
      
      
   end foreach  
    
   display "      Total servicos lidos    : ", l_lidos     
   display "      Total mensagens enviadas: ", l_contador  
   
   
  end foreach
  
  let l_agora = current   
  
  display "FIM SMS COMPLEMENTO GPS: ", l_agora     
  display ""
  
  display "INICIO SMS CLIENTE PORTAL,VOZ e FAX: ", l_agora
  
  #verifica tipos de acionamento que devem enviar SMS cliente
  let l_grlchv = "PSOTIPACNSMS"
      
  whenever error continue
     open cbdbsa070005 using l_grlchv     
      fetch cbdbsa070005 into l_tipoacionamento
      
      if sqlca.sqlcode <> 0 then
         display "NAO HA TIPO DE ACIONAMENTO CADASTRADO PARA ENVIO DE SMS"
         return
      end if    
      
     close cbdbsa070005
  whenever error stop 
  
  let l_tipoacionamento = l_tipoacionamento   clipped 
  display "   Tipos de Acionamento: ",  l_tipoacionamento   

  let l_grlchv = "EMPORGCTLSEG"        
  open cbdbsa070007 using l_grlchv
  
  
  foreach cbdbsa070007 into l_ciaempcod, l_origens
                            
     let l_contador    =  0
     let l_lidos       =  0  
     let l_agora = current
     let l_origens = l_origens clipped
     let l_dominio = "DTACRTMSGCMP"
     let l_datacorte = null
     
     
     display "   Empresa/Origens: ", l_ciaempcod using "<#", '/', l_origens
     
     
     #verifica se existe data de corte cadastrada para empresa 
     
     whenever error continue 
     open cbdbsa070008 using l_dominio, l_ciaempcod
     fetch cbdbsa070008 into l_data
     if sqlca.sqlcode = 0 then     
        let l_dia       = l_data[1,2]
        let l_mes       = l_data[4,5]
        let l_ano       = l_data[7,10]          
        let l_datacorte = mdy(l_mes,l_dia,l_ano)     
     end if
     close cbdbsa070008 
     whenever error stop                               
         
     #montando consulta 
     let l_sql =  " SELECT srv.atdsrvnum, ",
               "        srv.atdsrvano, ",
               "        srv.socvclcod, ",
               "        srv.atdsrvorg, ",
               "        srv.ciaempcod, ",
               "        srv.atddat,    ",
               "        acp.envtipcod, ",
               "        acp.atdetpdat, ",
               "        acp.atdetphor ",
               "   FROM datmservico srv",
               "    INNER JOIN datmsrvacp acp", 
               "       ON (acp.atdsrvnum = srv.atdsrvnum ",
               "      AND acp.atdsrvano = srv.atdsrvano",
               "      AND acp.atdsrvseq = srv.atdsrvseq)",
               "     WHERE acp.envtipcod in (",l_tipoacionamento,")",
               "       AND acp.atdetpcod in (3,4)",
               "       AND (srvcbnhor >= (current - 120 units minute) AND srvcbnhor <= (current + 120 units minute))", #data inicial e final
               "       AND ciaempcod in (",l_ciaempcod,")",
               "       AND atdsrvorg in (",l_origens,")"
   prepare pbdbsa070009 from l_sql                               
   declare cbdbsa070009 cursor with hold for pbdbsa070009       
  

   #Obtem tempo parametriado maximo para enviar o SMS
   let l_grlchv = "PSOTEMPOMAXSMS"
   let l_tempo_limite = null
   whenever error continue
   open cbdbsa070005 using l_grlchv     
   fetch cbdbsa070005 into l_tempo_limite
   close cbdbsa070005
   whenever error stop 

   if l_tempo_limite is null then   
   	  let l_tempo_limite = "00:05:00"  # --> TEMPO LIMITE PARA VERIFICACAO
   end if

   open cbdbsa070009 

   foreach cbdbsa070009 into l_bdbsa070.atdsrvnum,
                             l_bdbsa070.atdsrvano,
                             l_bdbsa070.socvclcod,
                             l_bdbsa070.atdsrvorg,
                             l_bdbsa070.ciaempcod, 
                             l_bdbsa070.atddat,
                             l_envtipcod,  
                             l_atdetpdat,
                             l_atdetphor
      
      let l_lidos = l_lidos + 1
      let l_regra_envio = ""
      
        #verifica se tipo de acionamento eh 1 - GPS
        #Regra alterada no Projeto M18 para envio de mensagem apenas se tipo de acionamento for GPS 
        #if l_envtipcod <> 1 then
        #   display "l_envtipcod = 1 continue foreach"
        #   continue foreach   
        #end if         

      #Tipo acionamento = GPS
      if l_envtipcod = 1 then

         #se o tempo q ja passou for menor que tempo parametrizado
         let l_espera = ctx01g07_espera(l_atdetpdat, l_atdetphor)
         if l_espera < l_tempo_limite then
            continue foreach
         end if
         
         let l_regra_envio = '      Envio de SMS de acionamento GPS apos tempo ', l_espera, ' para o servico ', l_bdbsa070.atdsrvnum using '#######','-',l_bdbsa070.atdsrvano using '##'
      end if
      
      if l_datacorte is null or l_bdbsa070.atddat >= l_datacorte then
         ##verifica se já existe SMS enviado para cliente
         if l_bdbsa070.atdsrvorg = 9 or l_bdbsa070.atdsrvorg = 13 then
            let l_codigosms = "R", l_bdbsa070.atdsrvnum using "<<<<<<<<&",
                                     l_bdbsa070.atdsrvano using "<&"
         else
            let l_codigosms = "S", l_bdbsa070.atdsrvnum using "<<<<<<<<&",
                                     l_bdbsa070.atdsrvano using "<&"
         end if
      
         whenever error continue
         open cbdbsa070010 using l_codigosms
         fetch cbdbsa070010 into l_status
         whenever error stop
         
         ## verifica se SMS já foi enviado e não envia novamente
         if  sqlca.sqlcode = 0 then
             continue foreach            
         else
             if sqlca.sqlcode <> 100 then               
                let l_msgerro = 'Erro ', sqlca.sqlcode,' no cursor cbdbsa070010 Codigo Mensagem ', l_codigosms
                display l_msgerro
                continue foreach   
             end if
         end if
         
         close cbdbsa070010       
      
         ##verifica se servico é multiplo , se for só envia SMS para serviço original
         if l_bdbsa070.atdsrvorg = 9 or l_bdbsa070.atdsrvorg = 13 then
            ##seta tipo de mensagem SMS RE
            let l_tipomsg = 2
         
            call cts29g00_consistir_multiplo(l_bdbsa070.atdsrvnum, l_bdbsa070.atdsrvano)
                        returning lr_cts29g00.resultado,
                                  lr_cts29g00.mensagem,
                                  lr_cts29g00.atdsrvnum,
                                  lr_cts29g00.atdsrvano                               
                                  
             
            if  lr_cts29g00.resultado = 1 then 
                #servico é multiplo 
                continue foreach
            end if 
         else 
            ##seta tipo de mensagem SMS AUTO
            let l_tipomsg = 3
         end if
         
         ##envia msg SMS para cliente
         call ctb85g02_envia_msg(l_tipomsg,                  
                                 l_bdbsa070.atdsrvnum,   
                                 l_bdbsa070.atdsrvano)   
                 returning l_codigoerro,          
                           l_msgerro         
         display l_msgerro         
         
         if l_codigoerro = 0 then 
            let l_contador = l_contador + 1
            if l_regra_envio is not null and l_regra_envio <> " " then
            	display l_regra_envio clipped
            end if
         end if         
      else 
         continue foreach 
      end if
      
      
      
   end foreach
      
   display "      Total servicos lidos    : ", l_lidos     
   display "      Total mensagens enviadas: ", l_contador  
   
   
  end foreach
  
  let l_agora = current
  display "FIM SMS CLIENTE PORTAL,VOZ e FAX: ", l_agora  
  display ""
  
  # --BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual
                 
  display "FIM PROCESSAMENTO Data/Hora Atual: ", l_data_atual," ",l_hora_atual
  display "----------------------------------------------------"
  display ""
  
end function

##funcionalidade comentada em 15/07/2013 por Jorge Modena
##processo automatico não é utilizado atualmente, para atendimento do 
##projeto Mecanismo de Seguranca foi aproveitado o batch
##-----------------#
#function bdbsa070()
##-----------------#
#
#  define l_bdbsa070   record
#         atdsrvnum    char(07),
#         socvclcod    like datmfrtpos.socvclcod,
#         socvcllcltip like datmfrtpos.socvcllcltip,
#         lclltt       like datmfrtpos.lclltt,
#         lcllgt       like datmfrtpos.lcllgt,
#         atldat       like datmfrtpos.atldat,
#         atlhor       like datmfrtpos.atlhor
#         end record
#
#  define l_contingencia   smallint,
#         l_agora          datetime hour to second,
#         l_roter_ativa    smallint,
#         l_data_atual     date,
#         l_hora_atual     datetime hour to minute,
#         l_lclltt_srv     like datmfrtpos.lclltt,
#         l_lcllgt_srv     like datmfrtpos.lcllgt,
#         l_ufdcod         like datmfrtpos.ufdcod,
#         l_roter_xml_veic char(32000),
#         l_hora           datetime hour to minute,
#         l_contador       smallint,
#         l_lidos          smallint,
#         l_desp_dt        smallint,
#         l_desp_hr        smallint,
#         l_desp_nu        smallint,
#         l_desp_di        smallint,
#         l_distancia      decimal(8,4),
#         l_tempo_total    decimal(6,1),
#         l_modulo         smallint
#
#  initialize l_bdbsa070.* to null
#  let l_contingencia = null
#  let l_data_atual  =  null
#  let l_hora_atual  =  null
#  let l_hora        =  null
#  let l_distancia   =  null
#  let l_tempo_total =  null
#  let l_contador    =  0
#  let l_lidos       =  0
#  let l_desp_dt     =  0
#  let l_desp_hr     =  0
#  let l_desp_nu     =  0
#  let l_desp_di     =  0
#  let l_roter_ativa =  null
#
#  call cta00m08_ver_contingencia(4) returning l_contingencia
#
#  if l_contingencia then
#     let l_agora = current
#     display l_agora, " Contingencia Ativa/Carga ainda nao realizada"
#  end if
#
#  if ctx34g00_ver_acionamentoWEB(2) then
#     display "AcionamentoWeb Ativo."
#     exit program 0
#  end if
#
#  # --BUSCAR A DATA E HORA DO BANCO
#  call cts40g03_data_hora_banco(2)
#       returning l_data_atual,
#                 l_hora_atual
#
#  let l_hora = l_hora_atual - 1 units minute
#
#  display "Data/Hora Atual: ", l_data_atual," ",l_hora
#
#  open cbdbsa070001
#  foreach cbdbsa070001 into l_bdbsa070.atdsrvnum,
#                            l_bdbsa070.socvclcod,
#                            l_bdbsa070.socvcllcltip,
#                            l_bdbsa070.lclltt,
#                            l_bdbsa070.lcllgt,
#                            l_bdbsa070.atldat,
#                            l_bdbsa070.atlhor
#
#     if l_bdbsa070.atldat <> l_data_atual then
#        let l_desp_dt = l_desp_dt + 1
#        continue foreach
#     end if
#
#     if l_bdbsa070.atlhor < l_hora then
#        let l_desp_hr = l_desp_hr + 1
#        continue foreach
#     end if
#
#     if l_bdbsa070.lclltt is null or l_bdbsa070.lcllgt is null then
#        let l_desp_nu = l_desp_nu + 1
#        continue foreach
#     end if
#
#     let l_ufdcod     = null
#     let l_lclltt_srv = null
#     let l_lcllgt_srv = null
#
#     open cbdbsa070002 using l_bdbsa070.socvclcod
#     fetch cbdbsa070002 into l_lclltt_srv, l_lcllgt_srv, l_ufdcod
#     close cbdbsa070002
#
#     if l_lclltt_srv is null or l_lcllgt_srv is null then
#        let l_desp_nu = l_desp_nu + 1
#        continue foreach
#     end if
#
#     display ''
#     display 'l_bdbsa070.atdsrvnum = ', l_bdbsa070.atdsrvnum
#     display 'l_bdbsa070.socvclcod = ', l_bdbsa070.socvclcod
#
#     #-------------------------------------
#     # VERIFICA SE A ROTERIZACAO ESTA ATIVA
#     #-------------------------------------
#     let l_roter_ativa = ctx25g05_rota_ativa()
#
#     if l_ufdcod <> "RJ" and
#        l_ufdcod <> "SP" and
#        l_ufdcod <> "PR" then
#        let l_roter_ativa = false
#     end if
#
#     if l_roter_ativa then
#
#        let l_contador = 1
#
#        # -> MONTA O XML DE REQUEST
#        let l_roter_xml_veic =  '<VEICULOS>',
#                                '<VEICULO>',
#                                '<ID>', l_contador using "<<<<&", '</ID>',
#                                   '<COORDENADAS>',
#                                      '<TIPO>WGS84</TIPO>',
#                                      '<X>',
#                                      l_bdbsa070.lcllgt,
#                                      '</X>',
#                                      '<Y>',
#                                      l_bdbsa070.lclltt,
#                                      '</Y>',
#                                   '</COORDENADAS>',
#                                '</VEICULO> </VEICULOS>'
#
#        display 'l_lclltt_srv          = ', l_lclltt_srv
#        display 'l_lcllgt_srv          = ', l_lcllgt_srv
#        display 'l_bdbsa070.lclltt     = ', l_bdbsa070.lclltt
#        display 'l_bdbsa070.lcllgt     = ', l_bdbsa070.lcllgt
#
#        call ctx25g06(l_lclltt_srv, l_lcllgt_srv, l_roter_xml_veic)
#            returning l_contador,
#                      l_distancia,
#                      l_tempo_total
#
#        let l_modulo = l_lidos mod 2 # Roteriza 2 servicos a cada segundo
#        if l_modulo = 0 then
#            sleep 1
#        end if
#
#     else
#        call cts18g00(l_lclltt_srv, l_lcllgt_srv,
#                      l_bdbsa070.lclltt, l_bdbsa070.lcllgt)
#             returning l_distancia
#     end if
#
#     if l_distancia is null or l_distancia = 0  then
#        let l_agora = current
#        display l_agora, " Erro - nao calculou a distancia ",
#                l_bdbsa070.socvclcod
#        let l_desp_di = l_desp_di + 1
#        continue foreach
#     end if
#
#     #whenever error continue
#     display 'l_distancia = ', l_distancia
#
#     let l_lidos = l_lidos + 1
#
#     begin work
#
#     execute pbdbsa070003 using l_distancia,
#                                l_bdbsa070.socvclcod
#
#     if sqlca.sqlcode <> 0 then
#        rollback work
#        let l_agora = current
#        display l_agora, " Erro na atualizacao da distancia pendente ",
#               sqlca.sqlcode
#     else
#        commit work
#     end if
#
#  end foreach
#
#  let l_agora = current
#  display l_agora, " ----- TOTAIS PROCESSADOS ----- " , l_agora
#  display "Total veiculos lidos                    : ", l_lidos
#  display "Total veiculos desprezados por data     : ", l_desp_dt
#  display "Total veiculos desprezados por hora     : ", l_desp_hr
#  display "Total veiculos desprezados por nulo     : ", l_desp_nu
#  display "Total veiculos desprezados por distancia: ", l_desp_di
#
#end function

