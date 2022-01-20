#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr128                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: 249530                                                     #
#                  MELHORIAS NO CONTROLE DE SOCORRISTAS                       #
#                     Solicitação de crachás                                  #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: 30/10/2009                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 05/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#

database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"
  
  define mr_bdbsr128      record
         srrcoddig        like datmcrhsol.srrcoddig,  # Código do Socorrista
         srrnom           like datksrr.srrnom,        # Nome do Socorrista
         nomrazsoc        like dpaksocor.nomrazsoc,   # Nome do Prestador
         pstcoddig        like datrsrrpst.pstcoddig,  # Codigo do Prestador 
         avstip           char (50),                  # Tipo da solicitação - 1)Porto/Azul ou 2)Porto
         soldat           like datmcrhsol.soldat,     # data da solicitação
         envsoltip        like datmcrhsol.envsoltip,  # Tipo da solicitação - 1)Porto/Azul ou 2)Porto
         solcntnum        like datmcrhsol.solcntnum,  # numero de sequencia da solicitacao de crachá
         rlzsoltip        like datmcrhsol.rlzsoltip   # Meio pelo qual a solicitação foi realizada
  end record 
  
  define m_data_ini       date,
         m_data_fim       date,
         l_data_atual     date,
         l_hora_atual     datetime hour to minute,
         m_mes_int        smallint,
         m_mes_nom        char(10)
         
  define m_path     char(1000)
  define m_path_txt char(1000) #--> RELTXT
  define m_lidos    integer
  define m_solicp   integer                          # Quantidade de crachas Porto
  define m_solicpa  integer                          # Quantidade de crachas Porto/Azul
  define m_solica   integer                          # Quantidade de crachas Azul
  define m_solici   integer                          # Quantidade de crachas Itau
  define m_solicpia integer                          # Quantidade de crachas Porto/Itau/Azul
  define m_solicia  integer                          # Quantidade de crachas Itau/Azul  
  define m_solicpi  integer                          # Quantidade de crachas Porto/Itau
  define l_erro_envio  integer
  
main
        
        initialize mr_bdbsr128.*,
                   m_path,
                   m_path_txt, #--> RELTXT
                   m_lidos,
                   m_data_ini,
                   m_data_fim,
                   l_data_atual,
                   l_hora_atual,
                   m_solicp,                    
                   m_solicpa,
                   m_solica  to null
         
         # ---> OBTER A DATA E HORA DO BANCO
         call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual



         # Calculo do mes para execução ou recebido como parametro 
         #caso não seja executado no ultima dia do mes
         let m_data_ini = arg_val(1)
         let m_data_fim = arg_val(2)
         
         
         # PARAMETRIZADO PARA EXECUÇÃO NO ULTIMO DIA DO MES
          if m_data_ini is null or m_data_fim is null then
              let m_data_ini = l_data_atual - day(today) + 1 
              let m_data_fim = m_data_ini + 1 units month - 1 units day
          end if    
         
    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(m_data_ini)


        call fun_dba_abre_banco("CT24HS")
        call bdbsr128_busca_path()
        call cts40g03_exibe_info("I","BDBSR128")

        call bdbsr128_prepare()
        call bdbsr128_crachas()
        display "Data inicial: ",m_data_ini
        display "Data final..: ",m_data_fim
        display " "
        display "QTD.REGISTROS LIDOS...........: ", m_lidos        using "<<<<<<<<&"
        display "QTD.CRACHAS PORTO.............: ", m_solicp       using "<<<<<<<<&"
        display "QTD.CRACHAS PORTO/AZUL........: ", m_solicpa      using "<<<<<<<<&"
        display "QTD.CRACHAS AZUL..............: ", m_solica       using "<<<<<<<<&"
        display "QTD.CRACHAS ITAU..............: ", m_solici       using "<<<<<<<<&"
        display "QTD.CRACHAS PORTO/ITAU........: ", m_solicpi      using "<<<<<<<<&"
        display "QTD.CRACHAS ITAU/AZUL.........: ", m_solicia      using "<<<<<<<<&"
        display "QTD.CRACHAS PORTO/ITAU/AZUL...: ", m_solicpia     using "<<<<<<<<&"
        display " "

        call cts40g03_exibe_info("F","BDBSR128")

end main  


#---------------------------#
 function bdbsr128_prepare()
#---------------------------#

        define l_sql   char(5000)

        create temp table t_temp (pstcoddig decimal(6,0) not null) with no log
        create unique index idx_bdbsr128 on t_temp (pstcoddig)
        
        # Para solicitacao de crachás neste mês
        
        let l_sql ="select  srrcoddig, ",
                           "soldat, ",
                           "solcntnum, ",
                           "envsoltip, ",
                           "pstcoddig, ",
                           "rlzsoltip ",
                     "from datmcrhsol ",
                     "where date(soldat) between ? and ?"         
                    

        prepare pbdbsr128_01 from l_sql
        declare cbdbsr128_01 cursor for pbdbsr128_01
        
        let l_sql= "select k.nomrazsoc ",
                     "from dpaksocor k  ",
                     "where k.pstcoddig = ? "
                       
        prepare pbdbsr128_02 from l_sql
        declare cbdbsr128_02 cursor for pbdbsr128_02 
        
        let l_sql= "select s.srrnom ",
                     "from datksrr s  ",
                     "where s.srrcoddig = ? "
                       
        prepare pbdbsr128_03 from l_sql
        declare cbdbsr128_03 cursor for pbdbsr128_03 
        
 end function
#-----------------------------#
 function bdbsr128_busca_path()
#-----------------------------#

        define l_dataarq char(8)
        define l_data    date
        
        let l_data = today
        display "l_data: ", l_data
        let l_dataarq = extend(l_data, year to year),
                        extend(l_data, month to month),
                        extend(l_data, day to day)
        display "l_dataarq: ", l_dataarq

        let m_path = null
        let m_path = f_path("DBS","LOG")
        if  m_path is null then
           let m_path = "."
        end if

        # ---> Cria o relatorio (Solicitações de Crachá dos Socorristas)
        
        let m_path = m_path clipped,"/bdbsr128.log"
        call startlog(m_path)

        let m_path = f_path("DBS", "RELATO")
        
         if  m_path is null then
           let m_path = "."
         end if

         let m_path_txt = m_path clipped, "/bdbsr1281_", l_dataarq, ".txt"  
         let m_path     = m_path clipped, "/bdbsr1281.xls"
 end function
 
#---------------------------------#
 function bdbsr128_crachas()
#---------------------------------#

let m_mes_int = month(today+ 1 units day)

# Esse report será o relatório enviado para os e-mail's cadastrados no CTC44m00 
start report rep_bdbsr128_1 to m_path
start report rep_bdbsr128_1_txt to m_path_txt #--> RELTXT

whenever error continue
   open cbdbsr128_01 using m_data_ini,
                           m_data_fim                  
   let m_lidos    = 0
   let m_solicp   = 0 
   let m_solicpa  = 0
   let m_solica   = 0
   let m_solici   = 0              
   let m_solicpia = 0                   
   let m_solicia  = 0                        
   let m_solicpi  = 0 
   
   # Solicitações de crachás                       
   foreach cbdbsr128_01 into mr_bdbsr128.srrcoddig,
                             mr_bdbsr128.soldat,
                             mr_bdbsr128.solcntnum, 
                             mr_bdbsr128.envsoltip,
                             mr_bdbsr128.pstcoddig,
                             mr_bdbsr128.rlzsoltip 
             case sqlca.sqlcode
   
                   when notfound
                       let l_erro_envio = 100    #  Notfound
                       display "Nao encontrei nenhum registro"
                       output to report rep_bdbsr128_1()
   
                   when 0 
                        whenever error continue
                              select cpodes into mr_bdbsr128.avstip
                                from iddkdominio
                               where cponom = "soltip"
                                 and cpocod = mr_bdbsr128.envsoltip
                        whenever error stop
                        if(sqlca.sqlcode <> 0)then
                                 display "Erro ao buscar o tipo de solicitacao, mas seu codigo eh: ",mr_bdbsr128.envsoltip
                                 let mr_bdbsr128.avstip = mr_bdbsr128.envsoltip
                        end if
                        
                        # realiza contagem por tipo de solicitacao de cracha           
                        if(mr_bdbsr128.avstip == "Porto/Azul") then
                                    let m_solicpa  = m_solicpa  + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Porto")then
                                    let m_solicp = m_solicp + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Azul")then
                                    let m_solica = m_solica + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Itau")then
                                    let m_solici = m_solici + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Porto/Itau")then
                                    let m_solicpi = m_solicpi + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Itau/Azul")then
                                    let m_solicia = m_solicia + 1
                        end if
                        
                        if(mr_bdbsr128.avstip == "Porto/Itau/Azul")then
                                    let m_solicpia = m_solicpia + 1
                        end if   
                        
                        
                        whenever error continue
                        
                          open cbdbsr128_02 using mr_bdbsr128.pstcoddig 
                          
                          fetch  cbdbsr128_02 into mr_bdbsr128.nomrazsoc
                          
                          open cbdbsr128_03 using mr_bdbsr128.srrcoddig
                                                  
                          fetch  cbdbsr128_03 into mr_bdbsr128.srrnom                         
                                                   
                          output to report rep_bdbsr128_1()
                          output to report rep_bdbsr128_1_txt() #--> RELTXT
                          close cbdbsr128_03
                          close cbdbsr128_02
                        whenever error stop  
            end case
       let m_lidos =  m_solicpa + m_solicp + m_solica + m_solici + m_solicpi + m_solicia + m_solicpia
   end foreach
   if(m_lidos = 0)then
        start report rep_bdbsr128_2 to m_path
        output to report rep_bdbsr128_2()
        finish report rep_bdbsr128_2
   end if 
whenever error stop   
finish report rep_bdbsr128_1
finish report rep_bdbsr128_1_txt #--> RELTXT

 let l_erro_envio = ctx22g00_envia_email("BDBSR128", "Solicitacao de crachas", m_path)
 if  l_erro_envio <> 0 then
          display "Erro no envio do email no ctx22g00: ",
                  l_erro_envio using "<<<<<<&", " - "
 else
          display "E-mail enviado com sucesso"
 end if                 
end function

#-----------------------#
 report rep_bdbsr128_1()
#-----------------------#

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "COD QRA",                          ASCII(09),
                      "NOME SOCORRISTA",                  ASCII(09),
                      "COD DO PRESTADOR",                 ASCII(09),
                      "NOME DO PRESTADOR",                ASCII(09),
                      "TIPO DA SOLICITACAO",              ASCII(09),
                      "DATA DA SOLICITACAO",              ASCII(09),
                      "NUMERO DA SOLICITACAO",            ASCII(09),
                      "SOLICITACAO REALIZADA VIA",        ASCII(09) 
            
            on every row  
                
                
                print mr_bdbsr128.srrcoddig       clipped,ASCII(09);
                print mr_bdbsr128.srrnom          clipped,ASCII(09);
                print mr_bdbsr128.pstcoddig,      ASCII(09);
                print mr_bdbsr128.nomrazsoc       clipped,ASCII(09);
                print mr_bdbsr128.avstip,         ASCII(09);
                print mr_bdbsr128.soldat,         ASCII(09);
                print mr_bdbsr128.solcntnum,      ASCII(09);
                print mr_bdbsr128.rlzsoltip       clipped,ASCII(09)
                

            on last row
                print " "
                print "Quantidade da crachas Pedidos.........: ",m_lidos
                print "Quantidade da crachas Porto/Azul......: ",m_solicpa
                print "Quantidade da crachas Porto...........: ",m_solicp
                print "Quantidade da crachas Azul............: ",m_solica    
                print "Quantidade da crachas Itau............: ",m_solici    
                print "Quantidade da crachas Porto/Itau......: ",m_solicpi    
                print "Quantidade da crachas Itau/Azul.......: ",m_solicia   
                print "Quantidade da crachas Porto/Itau/Azul.: ",m_solicpia    
                    
               
end report 

#---------------------------------------#
 report rep_bdbsr128_1_txt() #--> RELTXT
#---------------------------------------#

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row  
                
                print mr_bdbsr128.srrcoddig       clipped,ASCII(09);
                print mr_bdbsr128.srrnom          clipped,ASCII(09);
                print mr_bdbsr128.pstcoddig,      ASCII(09);
                print mr_bdbsr128.nomrazsoc       clipped,ASCII(09);
                print mr_bdbsr128.avstip,         ASCII(09);
                print mr_bdbsr128.soldat,         ASCII(09);
                print mr_bdbsr128.solcntnum,      ASCII(09);
                print mr_bdbsr128.rlzsoltip       clipped
                
end report 

#-----------------------#
 report rep_bdbsr128_2()
#-----------------------#

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "COD QRA",                          ASCII(09),
                      "NOME SOCORRISTA",                  ASCII(09),
                      "COD DO PRESTADOR",                 ASCII(09),
                      "NOME DO PRESTADOR",                ASCII(09),
                      "TIPO DA SOLICITACAO",              ASCII(09),
                      "DATA DA SOLICITACAO",              ASCII(09),
                      "NUMERO DA SOLICITACAO",            ASCII(09),
                      "SOLICITACAO REALIZADA VIA",        ASCII(09) 
            
            on every row  
                
                
                print "Nao existe solicitacao de crachas no mes : ",m_mes_int, ASCII(09)
                

            on last row
                print " "
                print "Quantidade da crachas Pedidos.........: ",m_lidos
                print "Quantidade da crachas Porto/Azul......: ",m_solicpa
                print "Quantidade da crachas Porto...........: ",m_solicp
                print "Quantidade da crachas Azul............: ",m_solica 
                print "Quantidade da crachas Itau............: ",m_solici    
                print "Quantidade da crachas Porto/Itau......: ",m_solicpi    
                print "Quantidade da crachas Itau/Azul.......: ",m_solicia   
                print "Quantidade da crachas Porto/Itau/Azul.: ",m_solicpia       
               
end report 
