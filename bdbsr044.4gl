#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR044                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: RELATORIO DE BOTOES DOS VEICULOS                           #
# ........................................................................... #
# DESENVOLVIMENTO: RAFAEL MOREIRA GOMES                                       #
# LIBERACAO......: Novembro/2015                                              #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

   define mr_datmmdtmvt record
      mdtmvttipcod   like datmmdtmvt.mdtmvttipcod 
     ,mdtmvtseq      like datmmdtmvt.mdtmvtseq    
     ,mdttrxnum      like datmmdtmvt.mdttrxnum
     ,atdsrvnum      like datmmdtmvt.atdsrvnum
     ,atdsrvano      like datmmdtmvt.atdsrvano   
     ,caddat         like datmmdtmvt.caddat       
     ,cadhor         like datmmdtmvt.cadhor       
     ,mdtcod         like datmmdtmvt.mdtcod       
     ,mdtcodant      like datmmdtmvt.mdtcod 
     ,lclltt         like datmmdtmvt.lclltt       
     ,lcllgt         like datmmdtmvt.lcllgt 
     ,lcllttant      like datmmdtmvt.lclltt       
     ,lcllgtant      like datmmdtmvt.lcllgt 
     ,mdtmvtstt      like datmmdtmvt.mdtmvtstt    
     ,funmat         like datmmdtmvt.funmat 
     ,mdtbotprgseq   like datmmdtmvt.mdtbotprgseq
     ,flag           char(1)
   end record
   
   define mr_datkveiculo record
      atdvclsgl      like datkveiculo.atdvclsgl
   end record
   
   define mr_mdtmvttipdes record
      mdtmvttipdes   like iddkdominio.cpodes
   end record
   
   define mr_mdtmvtsttdes record
      mdtmvtsttdes   like iddkdominio.cpodes
   end record
   
   define mr_datmservico record
      atdsrvnum    like datmservico.atdsrvnum
     ,atdsrvano    like datmservico.atdsrvano
     ,srrcoddig    like datksrr.srrcoddig
     ,srrnom       like datksrr.srrnom
     ,pstcoddig    like dpaksocor.pstcoddig
     ,nomgrr       like dpaksocor.nomgrr
   end record
   
   define m_path        char(100)     
   define m_data        datetime year to month


main
   
   call fun_dba_abre_banco("CT24HS")   
   
   call bdbsr044_path()
   
   call bdbsr044_prepare()
   
   call cts40g03_exibe_info("I","bdbsr044")
   
   set isolation to dirty read

   whenever error continue
   call bdbsr044()        
   whenever error stop
   
   call bdbsr044_envia_email()
   
   call cts40g03_exibe_info("F","bdbsr044")
    
end main

#-----------------------#
function bdbsr044_path()
#-----------------------#

    #INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    #CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr044.log"
    
    call startlog(m_path)
    
    #CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if
    
    let m_path = m_path clipped, "/bdbsr044.txt"

#-----------#    
end function
#-----------#

#-------------------------#
function bdbsr044_prepare()
#-------------------------#

   define l_sql char(2500)
   define l_data_inicio, l_data_fim date
   define l_data_atual date,
          l_hora_atual datetime hour to minute
   
   let l_data_atual = arg_val(1)
    
   #OBTER A DATA E HORA DO BANCO
   if l_data_atual is null then
      call cts40g03_data_hora_banco(2)
           returning l_data_atual,
                     l_hora_atual
   end if                
     
   #DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
   if  month(l_data_atual) = 01 then
       let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
       let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)
   else
       let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
       let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
   end if
   
   display "Perioro de Processamento: ", l_data_inicio, " a ", l_data_fim   
   
   let l_sql = "   select vcl.atdvclsgl            "
              ,"         ,mdt.mdtmvtseq            "
              ,"         ,mdt.mdttrxnum            "
              ,"         ,mdt.atdsrvnum            "
              ,"         ,mdt.atdsrvano            "
              ,"         ,mdt.caddat               "
              ,"         ,mdt.cadhor               "
              ,"         ,mdt.mdtcod               "
              ,"         ,mdt.lclltt               "
              ,"         ,mdt.lcllgt               "
              ,"         ,mdt.mdtmvttipcod         "
              ,"         ,mdt.mdtmvtstt            "
              ,"         ,mdt.funmat               "
              ,"         ,mdt.mdtbotprgseq         "
              ,"     from datkveiculo vcl          "
              ,"         ,datmmdtmvt  mdt          "
              ,"    where mdt.mdtcod = vcl.mdtcod  "
              ,"      and mdt.caddat between '", l_data_inicio, "' and '", l_data_fim, "'" 
              ,"      and mdt.mdtmvttipcod = 2     "
              ," order by mdt.caddat               "
              ,"         ,mdt.cadhor               "
              ,"         ,vcl.atdvclsgl            "
              ,"         ,mdt.mdtmvtseq            "
   prepare p_dados01 from l_sql            
   declare c_dados01 cursor for p_dados01  
                 
                 
   let l_sql = "  select cpodes                   "
              ,"    from iddkdominio              "
              ,"   where cponom = 'mdtmvttipcod'  "
              ,"     and cpocod = ?               "
   prepare p_dados02 from l_sql            
   declare c_dados02 cursor for p_dados02  
                     
   let l_sql = "  select cpodes                   "
              ,"    from iddkdominio              "
              ,"   where cponom = 'mdtmvtstt'     "
              ,"     and cpocod = ?               "
   prepare p_dados03 from l_sql            
   declare c_dados03 cursor for p_dados03  
   
   let l_sql = "  select mdtbottxt                                       "
              ,"   from datkmdt, datrmdtbotprg, datkmdtbot               "
              ,"  where datkmdt.mdtcod = ?                               "
              ,"    and datrmdtbotprg.mdtprgcod  = datkmdt.mdtprgcod     "
              ,"    and datrmdtbotprg.mdtbotprgseq = ?                   "
              ,"    and datkmdtbot.mdtbotcod = datrmdtbotprg.mdtbotcod   "
   prepare p_dados04 from l_sql            
   declare c_dados04 cursor for p_dados04  
   
   let l_sql = " select atdsrvnum, atdsrvano    "
              ,"   from datmmdtmvt              "
              ,"  where mdtmvtseq = ?           "
   prepare p_dados05 from l_sql            
   declare c_dados05 cursor for p_dados05  
   
   let l_sql = " select srrcoddig       "
              ,"   from datmservico     "
              ,"  where atdsrvnum = ?   "
              ,"    and atdsrvano = ?   "
   prepare p_dados06 from l_sql            
   declare c_dados06 cursor for p_dados06 
   
   let l_sql = " select srrnom        "
              ,"   from datksrr       "
              ,"  where srrcoddig = ? "
   prepare p_dados07 from l_sql            
   declare c_dados07 cursor for p_dados07  
   
   let l_sql = " select dpa.pstcoddig, dpa.nomgrr     "
              ,"   from datmservico srv               "
              ,"       ,dpaksocor dpa                 "
              ,"  where dpa.pstcoddig = srv.atdprscod "
              ,"    and atdsrvano = ?                 "
              ,"    and atdsrvnum = ?                 "
   prepare p_dados08 from l_sql            
   declare c_dados08 cursor for p_dados08  

#-----------#
end function
#-----------#

#------------------#
function bdbsr044()
#------------------#

   initialize mr_datmmdtmvt.*
             ,mr_datkveiculo.* 
             ,mr_mdtmvttipdes.*
             ,mr_mdtmvtsttdes.*
             ,mr_datmservico.*
                               to null
   
   start report relatorio to m_path

   open c_dados01
   foreach c_dados01 into  mr_datkveiculo.atdvclsgl   
                          ,mr_datmmdtmvt.mdtmvtseq     
                          ,mr_datmmdtmvt.mdttrxnum
                          ,mr_datmmdtmvt.atdsrvnum
                          ,mr_datmmdtmvt.atdsrvano
                          ,mr_datmmdtmvt.caddat      
                          ,mr_datmmdtmvt.cadhor      
                          ,mr_datmmdtmvt.mdtcod      
                          ,mr_datmmdtmvt.lclltt      
                          ,mr_datmmdtmvt.lcllgt      
                          ,mr_datmmdtmvt.mdtmvttipcod
                          ,mr_datmmdtmvt.mdtmvtstt        
                          ,mr_datmmdtmvt.funmat 
                          ,mr_datmmdtmvt.mdtbotprgseq
                          
      if sqlca.sqlcode <> 0 then
         display 'Erro c_dados01 ', sqlca.sqlcode 
      end if  
      
      if mr_datmmdtmvt.mdtbotprgseq is not null then
         open c_dados04 using  mr_datmmdtmvt.mdtcod
                              ,mr_datmmdtmvt.mdtbotprgseq                            
         fetch c_dados04 into  mr_mdtmvttipdes.mdtmvttipdes 

            if sqlca.sqlcode <> 0 then
               display 'Erro c_dados04 ', sqlca.sqlcode, 'Servico: ', 
                        mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
            end if  
         close c_dados04
      else                        
         open c_dados02 using  mr_datmmdtmvt.mdtbotprgseq
         fetch c_dados02 into  mr_mdtmvttipdes.mdtmvttipdes
            if sqlca.sqlcode <> 0 then
               display 'Erro c_dados02 ', sqlca.sqlcode, 'Servico: ', 
                        mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
            end if  
         close c_dados02
      end if
      
      open c_dados03 using  mr_datmmdtmvt.mdtmvtstt  
      fetch c_dados03 into  mr_mdtmvtsttdes.mdtmvtsttdes
         if sqlca.sqlcode <> 0 then
            display 'Erro c_dados03 ', sqlca.sqlcode, 'Servico: ', 
                     mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
         end if  
      close c_dados03
      
      let mr_datmmdtmvt.mdtcodant =  mr_datmmdtmvt.mdtcod
      let mr_datmmdtmvt.lcllttant =  mr_datmmdtmvt.lclltt 
      let mr_datmmdtmvt.lcllgtant =  mr_datmmdtmvt.lcllgt 

      if  mr_datmmdtmvt.funmat is not null then
          let mr_datmmdtmvt.flag = 'M'
      else
          let mr_datmmdtmvt.flag = 'S'
      end if
      
      open c_dados05 using  mr_datmmdtmvt.mdtmvtseq
      fetch c_dados05 into  mr_datmservico.atdsrvnum
                           ,mr_datmservico.atdsrvano
         if sqlca.sqlcode <> 0 then
            display 'Erro c_dados05 ', sqlca.sqlcode, 'Servico: ', 
                     mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
         end if  
      close c_dados05
      
      open c_dados06 using  mr_datmservico.atdsrvnum
                           ,mr_datmservico.atdsrvano
      fetch c_dados06 into  mr_datmservico.srrcoddig
         if sqlca.sqlcode <> 0 then
            display 'Erro c_dados06 ', sqlca.sqlcode, 'Servico: ', 
                     mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
         end if  
      close c_dados06
      
      open c_dados07 using  mr_datmservico.srrcoddig
      fetch c_dados07 into  mr_datmservico.srrnom
         if sqlca.sqlcode <> 0 then
            display 'Erro c_dados07 ', sqlca.sqlcode, 'Servico: ', 
                     mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
         end if  
      close c_dados07
      
      open c_dados08 using  mr_datmservico.atdsrvano
                           ,mr_datmservico.atdsrvnum
      fetch c_dados08 into  mr_datmservico.pstcoddig
                           ,mr_datmservico.nomgrr
         if sqlca.sqlcode <> 0 then
            display 'Erro c_dados08 ', sqlca.sqlcode, 'Servico: ', 
                     mr_datmmdtmvt.atdsrvnum, '/',mr_datmmdtmvt.atdsrvano  
         end if  
      close c_dados08
      
      output to report relatorio() 

      initialize mr_mdtmvttipdes.*
                ,mr_mdtmvtsttdes.*
                ,mr_datmservico.*   to null
                      
   end foreach  
   
   finish report relatorio

#-----------#
end function
#-----------#

#-------------------------------#
 function bdbsr044_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   
   let m_data = today

   # ---> ENVIA RELATORIO SOCORRISTAS
   let l_assunto = "Relatorio de Botoes do Veiculo - ", m_data, " - bdbsr044"

   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("bdbsr044", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - bdbsr044"
       end if
   end if

#-----------#
end function
#-----------#

#-----------------#
report relatorio()
#-----------------#

  output
     left   margin 00
     right  margin 00
     top    margin 00
     bottom margin 00
     page   length 02

  format

     first page header
     
        print "Dt_Trans" 					                  , ASCII(09), 
              "Veiculo"                             , ASCII(09),
              "Codigo_Prestador"                    , ASCII(09),
              "Nome_Guerra"                         , ASCII(09),
              "Codigo_Socorrista"                   , ASCII(09),
              "Nome_Socorrista"                     , ASCII(09),
              "Seq_Movto"                           , ASCII(09),  
              "T_MDT"                               , ASCII(09),
              "Hora"                                , ASCII(09),
              "Mdt"                                 , ASCII(09),
              "Seq_Botao"                           , ASCII(09),
              "Botao_Tp_Movto"                      , ASCII(09),
              "Situacao"                            , ASCII(09),
              "Servico"                             , ASCII(09),
              "Ano"                                 , ASCII(09),
              "M/S"                                 , ASCII(09),
              "Latitude"                            , ASCII(09),
              "Longitude"                           , ASCII(09),
              "Funcionario"                         , ASCII(09)
           
           
     on every row
     
        print mr_datmmdtmvt.caddat                  , ASCII(09),
              mr_datkveiculo.atdvclsgl              , ASCII(09),
              mr_datmservico.pstcoddig              , ASCII(09),
              mr_datmservico.nomgrr                 , ASCII(09),
              mr_datmservico.srrcoddig              , ASCII(09),
              mr_datmservico.srrnom                 , ASCII(09),
              mr_datmmdtmvt.mdtmvtseq               , ASCII(09),
              mr_datmmdtmvt.mdttrxnum               , ASCII(09),
              mr_datmmdtmvt.cadhor                  , ASCII(09),
              mr_datmmdtmvt.mdtcod                  , ASCII(09), 
              mr_datmmdtmvt.mdtbotprgseq            , ASCII(09),
              mr_mdtmvttipdes.mdtmvttipdes clipped  , ASCII(09),
              mr_mdtmvtsttdes.mdtmvtsttdes clipped  , ASCII(09),
              mr_datmmdtmvt.atdsrvnum               , ASCII(09),
              mr_datmmdtmvt.atdsrvano               , ASCII(09),
              mr_datmmdtmvt.flag                    , ASCII(09),
              mr_datmmdtmvt.lclltt                  , ASCII(09),
              mr_datmmdtmvt.lcllgt                  , ASCII(09),
              mr_datmmdtmvt.funmat                  , ASCII(09) 

#---------#  
end report
#---------#