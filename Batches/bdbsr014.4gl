#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR014.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2012-35222/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  ETAPAS DE ACIONAMENTO                                     #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 24/01/2013                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 25/09/2013  Celso Issamu    130918851     Inserção de Matricula da Etapa   #
# -------------------------------------------------------------------------- #
# 30/10/2014  Franzon Biz                   Inclusao campos no relatorio     #
#----------------------------------------------------------------------------#

database porto


define mr_bdbsr014 record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,envtipcod like datmsrvacp.envtipcod
   ,envtipdes like iddkdominio.cpodes
   ,atdetpcod like datmsrvacp.atdetpcod
   ,atdetpdes like datketapa.atdetpdes
   ,atdsrvseq like datmsrvacp.atdsrvseq
   ,pstcoddig like datmsrvacp.pstcoddig
   ,srrcoddig like datmsrvacp.srrcoddig
   ,atdetpdat like datmsrvacp.atdetpdat
   ,atdetphor like datmsrvacp.atdetphor
   ,acnnaomtv like datmservico.acnnaomtv
   ,nomgrr    like dpaksocor.nomgrr
   ,atdvclsgl like datkveiculo.atdvclsgl
   ,empcod    like datmsrvacp.empcod
   ,funmat    like datmservico.funmat
   ,acn_auto  char(1)
   ,socvclcod like datmsrvacp.socvclcod
   ,atdsrvorg like datmservico.atdsrvorg  #PAS - central
   ,ufdcod    like datmlcl.ufdcod         #PAS - central
   ,cidnom    like datmlcl.cidnom         #PAS - central

end record

define ma_iddkdominio array[20] of record
    cpocod like iddkdominio.cpocod
   ,cpodes like iddkdominio.cpodes
end record

define ma_datketapa array[100] of record
    atdetpcod like datketapa.atdetpcod
   ,atdetpdes like datketapa.atdetpdes
end record

define m_path         char (500)
      ,m_path_txt     char (500)
      ,m_data         date
      ,m_data_inicio  date
      ,m_data_fim     date
      ,m_hora         datetime hour to minute
      ,m_current      datetime hour to second

main

   initialize m_path
             ,m_path_txt
             ,mr_bdbsr014.* to null

   call fun_dba_abre_banco("CT24HS")
   call cts40g03_exibe_info("I","BDBSR014")

   let m_current = current
   #display "iniciei às: ", m_current

   let m_data = arg_val(1)

   # ---> OBTER A DATA E HORA DO BANCO
   if m_data is null then
      call cts40g03_data_hora_banco(2)
      returning m_data,
                m_hora
   end if

   let m_data_fim = m_data - 8 units day
   let m_data_inicio = m_data - 14 units day

   display "------------------------------------------------------------"
   display "Buscando Serviços de: ", m_data_inicio, " até: ", m_data_fim
   display "------------------------------------------------------------"

   set isolation to dirty read
   call bdbsr014_prepare()
   call bdbsr014_path()
   call bdbsr014()
   call cts40g03_exibe_info("F","BDBSR014")
   #let m_current = current
   #display "terminei às: ", m_current

end main


#------------------------------------------------
function bdbsr014_prepare()
#------------------------------------------------

   define l_query char(1500)

   # Query principal - Todos os Serviços do período
   let l_query = 'select srv.atdsrvnum, srv.atdsrvano,   '
                ,'       acp.envtipcod, acp.atdetpcod,   '
                ,'       acp.atdsrvseq, acp.pstcoddig,   '
                ,'       acp.srrcoddig, srv.acnnaomtv,   '
                ,'       acp.atdetpdat, acp.atdetphor,   '
                ,'       acp.socvclcod, acp.empcod, acp.funmat, ' #130918851
                ,'       srv.atdsrvorg '
                ,'  from datmservico srv, datmsrvacp acp '
                ,' where srv.atdsrvnum = acp.atdsrvnum   '
                ,'   and srv.atdsrvano = acp.atdsrvano   '
                ,'   and srv.atdsrvorg in (1,2,3,4,5,6,7,8,9,13)'
                ,'   and srv.atddat between ? and ?      '
   prepare p_bdbsr014_01 from l_query
   declare c_bdbsr014_01 cursor for p_bdbsr014_01

   # Query para localizar a descricao dos campos
   let l_query = 'select cpocod, cpodes      '
                ,'  from iddkdominio         '
                ," where cponom ='envtipcod' "
   prepare p_bdbsr014_02 from l_query
   declare c_bdbsr014_02 cursor for p_bdbsr014_02

   # Query para localizar dados do prestador
   let l_query = 'select nomgrr       '
                ,'  from dpaksocor    '
                ,' where pstcoddig = ?'
   prepare p_bdbsr014_03 from l_query
   declare c_bdbsr014_03 cursor for p_bdbsr014_03

   # Query para localizar dados do veículo
   let l_query = 'select atdvclsgl    '
                ,'  from datkveiculo  '
                ,' where socvclcod = ?'
   prepare p_bdbsr014_04 from l_query
   declare c_bdbsr014_04 cursor for p_bdbsr014_04

   # Query para as descricoes das etapas
   let l_query = 'select atdetpcod, atdetpdes '
                ,'  from datketapa            '
                ," where atdetpstt = 'A'      "
   prepare p_bdbsr014_05 from l_query
   declare c_bdbsr014_05 cursor for p_bdbsr014_05

   # Query para localizar uf e cidade
   let l_query = 'select ufdcod, cidnom '
                ,'  from datmlcl            '
                ," where atdsrvnum =  ?       "
                ,"   and atdsrvano =  ?       "
   prepare p_bdbsr014_06 from l_query
   declare c_bdbsr014_06 cursor for p_bdbsr014_06

end function

#------------------------------------------------
function bdbsr014()
#------------------------------------------------

   call bdbsr014_carga_array()

   open c_bdbsr014_01 using m_data_inicio
                           ,m_data_fim

   start report r_bdbsr014 to m_path
   start report r_bdbsr014_txt to m_path_txt

   foreach c_bdbsr014_01 into mr_bdbsr014.atdsrvnum, mr_bdbsr014.atdsrvano
                             ,mr_bdbsr014.envtipcod, mr_bdbsr014.atdetpcod
                             ,mr_bdbsr014.atdsrvseq, mr_bdbsr014.pstcoddig
                             ,mr_bdbsr014.srrcoddig, mr_bdbsr014.acnnaomtv
                             ,mr_bdbsr014.atdetpdat, mr_bdbsr014.atdetphor
                             ,mr_bdbsr014.socvclcod
                             ,mr_bdbsr014.empcod   , mr_bdbsr014.funmat #130918851
                             ,mr_bdbsr014.atdsrvorg  #PAS - central

      #Verifica se foi acionamento automático
      if mr_bdbsr014.funmat = 999999  and
         mr_bdbsr014.acnnaomtv is null then
         let mr_bdbsr014.acn_auto = "S"
      else
         let mr_bdbsr014.acn_auto = "N"
      end if

      call bdbsr014_etapa(mr_bdbsr014.atdetpcod)
         returning mr_bdbsr014.atdetpdes

      if mr_bdbsr014.envtipcod is not null then
         call bdbsr014_dominio(mr_bdbsr014.envtipcod)
            returning mr_bdbsr014.envtipdes
      end if

      if mr_bdbsr014.pstcoddig is not null then
         open c_bdbsr014_03 using mr_bdbsr014.pstcoddig
         fetch c_bdbsr014_03 into mr_bdbsr014.nomgrr
         close c_bdbsr014_03
      end if

      if mr_bdbsr014.socvclcod is not null then
         open c_bdbsr014_04 using mr_bdbsr014.socvclcod
         fetch c_bdbsr014_04 into mr_bdbsr014.atdvclsgl
      end if

      open c_bdbsr014_06 using mr_bdbsr014.atdsrvnum
                              ,mr_bdbsr014.atdsrvano

      fetch c_bdbsr014_06 into mr_bdbsr014.ufdcod
                              ,mr_bdbsr014.cidnom

      close c_bdbsr014_06
      output to report r_bdbsr014()
      output to report r_bdbsr014_txt()
      initialize mr_bdbsr014.* to null

   end foreach
   finish report r_bdbsr014
   finish report r_bdbsr014_txt
   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue
   call bdbsr014_mail()
   whenever error stop


end function


#------------------------------------------------
function bdbsr014_etapa(l_param)
#------------------------------------------------

   define l_param record
       atdetpcod   like datmsrvacp.atdetpcod
   end record

   define lr_retorno record
       atdetpdes   like iddkdominio.cpodes
   end record

   define l_i smallint

   initialize lr_retorno.* to null

   for l_i = 1 to 100

      if ma_datketapa[l_i].atdetpcod is null then
         let lr_retorno.atdetpdes = "N CADASTRADO"
         exit for
      end if

      if l_param.atdetpcod = ma_datketapa[l_i].atdetpcod then
         let lr_retorno.atdetpdes = ma_datketapa[l_i].atdetpdes
         exit for
      end if

   end for

   return lr_retorno.atdetpdes

end function

#------------------------------------------------
function bdbsr014_dominio(l_param)
#------------------------------------------------

   define l_param record
       cpocod   like iddkdominio.cpocod
   end record

   define lr_retorno record
       cpodes   like iddkdominio.cpodes
   end record

   define l_i smallint

   initialize lr_retorno.* to null


   for l_i = 1 to 20

      if ma_iddkdominio[l_i].cpocod is null then
         let lr_retorno.cpodes = "N CADASTRADO"
         exit for
      end if

      if l_param.cpocod = ma_iddkdominio[l_i].cpocod then
         let lr_retorno.cpodes = ma_iddkdominio[l_i].cpodes
         exit for
      end if

   end for

   return lr_retorno.cpodes

end function

#------------------------------------------------
function bdbsr014_mail()
#------------------------------------------------


   define l_assunto     char(100),
          l_erro_envio  integer,
          l_comando     char(200),
          l_path        char(200)

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null

   let l_assunto    = "Relatório de Etapa de Acionamento - Semana: "
                     ,m_data_inicio, ' - ',m_data_fim

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path

   run l_comando
   let m_path = m_path clipped, ".gz"
  
   let l_erro_envio = ctx22g00_envia_email("BDBSR014", l_assunto, m_path)

   #if l_erro_envio <> 0 then
   #   if l_erro_envio <> 99 then
   #      display "Erro ao enviar email(ctx22g00) - ", l_path
   #   else
   #      display "Nao existe email cadastrado para o modulo - BDBSR014"
   #   end if
   #end if
end function

#------------------------------------------------
function bdbsr014_carga_array()
#------------------------------------------------
   define l_i smallint

   open c_bdbsr014_02
   let l_i = 1
   foreach c_bdbsr014_02 into ma_iddkdominio[l_i].cpocod
                             ,ma_iddkdominio[l_i].cpodes
      let l_i = l_i + 1
   end foreach

   open c_bdbsr014_05

   let l_i = 1
   foreach c_bdbsr014_05 into ma_datketapa[l_i].atdetpcod
                             ,ma_datketapa[l_i].atdetpdes
      let l_i = l_i + 1
   end foreach

end function

#------------------------------------------------
function bdbsr014_path()
#------------------------------------------------

    define l_data     date
    define l_dataarq  char(8)

    let l_data = today
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)   
                    
   # ---> INICIALIZACAO DAS VARIAVEIS
   let m_path = null

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
   let m_path = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped, "/BDBSR014.log"
   call startlog(m_path)

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   let m_path = f_path("DBS", "RELATO")

   if m_path is null then
      let m_path = "."
   end if
   #Descomentar a linha abaixo para execução eventual
   #let m_path = '/asheeve'
   
   let m_path_txt = m_path clipped
   let m_path = m_path clipped, "/BDBSR014.csv"
   let m_path_txt = m_path_txt clipped, "/BDBSR014_", l_dataarq, ".txt"  


end function

#-------------------------------------#
report r_bdbsr014()
#-------------------------------------#

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "SERVICO"          ,'|',
              "ANO"              ,'|',
              "COD_TP_ENV"       ,'|',
              "DESC_TP_ENV"      ,'|',
              "SEQ_ETAPA"        ,'|',
              "DATA_ETAPA"       ,'|',
              "HORA_ETAPA"       ,'|',
              "COD_ETAPA"        ,'|',
              "DESC_ETAPA"       ,'|',
              "ACN_AUTO(S/N)"    ,'|',
              "MOVITO_NAO_ACN"   ,'|',
              "CDO_PRESTADOR"    ,'|',
              "NOME_GUERRA"      ,'|',
              "COD_VEICULO"      ,'|',
              "SIGLA_VEICULO"    ,'|',
              "COD_SOCORRISTA"   ,'|',
              "EMPRESA_FUN"      ,'|', #130918851
              "MATRICULA"        ,'|', #PAS - central
              "ORIGEM"           ,'|', #PAS - central    
              "UF OCORRENCIA"    ,'|', #PAS - central
              "CIDADE OCORRENCIA"      #PAS - central 

  on every row

     print mr_bdbsr014.atdsrvnum          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdsrvano          ,'|';#,ASCII(09);
     print mr_bdbsr014.envtipcod          ,'|';#,ASCII(09);
     print mr_bdbsr014.envtipdes clipped  ,'|';#,ASCII(09);
     print mr_bdbsr014.atdsrvseq          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdetpdat          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdetphor          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdetpcod          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdetpdes clipped  ,'|';#,ASCII(09);
     print mr_bdbsr014.acn_auto           ,'|';#,ASCII(09);
     print mr_bdbsr014.acnnaomtv clipped  ,'|';#,ASCII(09);
     print mr_bdbsr014.pstcoddig          ,'|';#,ASCII(09);
     print mr_bdbsr014.nomgrr    clipped  ,'|';#,ASCII(09);
     print mr_bdbsr014.socvclcod          ,'|';#,ASCII(09);
     print mr_bdbsr014.atdvclsgl          ,'|';#,ASCII(09);
     print mr_bdbsr014.srrcoddig          ,'|';
     print mr_bdbsr014.empcod             ,'|';#130918851 
     print mr_bdbsr014.funmat             ,'|';
     print mr_bdbsr014.atdsrvorg          ,'|'; # PAS - central
     print mr_bdbsr014.ufdcod             ,'|'; # PAS - central
     print mr_bdbsr014.cidnom                   # PAS - central

end report

#-------------------------------------#
report r_bdbsr014_txt()
#-------------------------------------#

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

   on every row
                                                                               
     print mr_bdbsr014.atdsrvnum          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdsrvano          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.envtipcod          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.envtipdes clipped  ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdsrvseq          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdetpdat          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdetphor          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdetpcod          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdetpdes clipped  ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.acn_auto           ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.acnnaomtv clipped  ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.pstcoddig          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.nomgrr    clipped  ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.socvclcod          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.atdvclsgl          ,ASCII(09),#,ASCII(09);            
           mr_bdbsr014.srrcoddig          ,ASCII(09),                        
           mr_bdbsr014.empcod             ,ASCII(09),#130918851              
           mr_bdbsr014.funmat             ,ASCII(09),                        
           mr_bdbsr014.atdsrvorg          ,ASCII(09), # PAS - central        
           mr_bdbsr014.ufdcod             ,ASCII(09), # PAS - central        
           mr_bdbsr014.cidnom             ,ASCII(09); # PAS - central    
     print today                                                             
           
end report
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
