#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR134.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2011-09700/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  "RELATORIO PET"                                           #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 26/07/2011                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 05/06/2015  RCP, Fornax     RELTXT        Criar versao .txt dos relatorios #
# -------------------------------------------------------------------------- #

database porto

define  m_bdbsr134_path  char(100),
        m_bdbsr134_path2 char(100),
        m_bdbsr134_path_txt  char(100), #--> RELTXT
        m_bdbsr134_path2_txt char(100), #--> RELTXT
        m_data_inicio    date,
        m_data_fim       date,
        m_data           date,
        m_hora           datetime hour to minute


define mr_bdbsr134   record
       succod       like  datrservapol.succod   ,
       ramcod       like  datrservapol.ramcod   ,
       aplnumdig    like  datrservapol.aplnumdig,
       itmnumdig    like  datrservapol.itmnumdig,
       edsnumref    like  datrservapol.edsnumref,
       atdsrvnum    like  datmservico.atdsrvnum ,
       atdsrvano    like  datmservico.atdsrvano ,
       c24astcod    like  datmligacao.c24astcod ,
       c24solnom    like  datmservico.c24solnom ,
       atddat       like  datmservico.atddat    ,
       atdhor       like  datmservico.atdhor    ,
       pgtdat       like  datmservico.pgtdat    ,
       atdcstvlr    like  datmservico.atdcstvlr ,
       c24txtseq    like  datmservhist.c24txtseq,
       c24srvdsc    like  datmservhist.c24srvdsc
end record

define ma_bdbsr134  array[30] of record
       c24txtseq    like  datmservhist.c24txtseq,
       c24srvdsc    like  datmservhist.c24srvdsc
end record

main

   initialize mr_bdbsr134.*,
              m_data,
              m_data_inicio,
              m_data_fim,
              m_hora,       
              m_bdbsr134_path,
              m_bdbsr134_path2,
              m_bdbsr134_path_txt,         #--> RELTXT
              m_bdbsr134_path2_txt to null #--> RELTXT

   let m_data = arg_val(1)
    
   display "m_data: ",m_data 
    
   # ---> OBTER A DATA E HORA DO BANCO
   if m_data is null then
      call cts40g03_data_hora_banco(2)
      returning m_data,
                m_hora

      let m_data_fim = mdy(month(m_data),01,year(m_data)) - 1 units day
      let m_data_inicio = mdy(month(m_data_fim),01,year(m_data_fim))
   else
      let m_data_inicio = mdy(month(m_data),01,year(m_data))
      let m_data_fim = mdy(month(m_data),01,year(m_data)) + 1 units month - 1 units day
   end if     
   
   call fun_dba_abre_banco("CT24HS")
   call cts40g03_exibe_info("I","BDBSR134")
   call bdbsr134_busca_path()
   call bdbsr134_prepare()
   display ""
   set isolation to dirty read
   call bdbsr134()
   call cts40g03_exibe_info("F","BDBSR134")

end main

#---------------------------
function bdbsr134_prepare()
#---------------------------

   define l_sql char(1000)

   #Por data de atendimento
   let l_sql =  "select c.succod,       ",
                "       c.ramcod,       ",
                "       c.aplnumdig,    ",
                "       c.itmnumdig,    ",
                "       c.edsnumref,    ",
                "       a.atdsrvnum,    ",
                "       a.atdsrvano,    ",
                "       b.c24astcod,    ",
                "       a.c24solnom,    ",
                "       a.atddat,       ",
                "       a.atdhor,       ",
                "       a.pgtdat,       ",
                "       a.atdcstvlr     ",
                "  from datmservico a,  ",
                "       datmligacao b,  ",
                "       datrservapol c  ",
                " where a.atdsrvnum = b.atdsrvnum ",
                "   and a.atdsrvano = b.atdsrvano ",
                "   and a.atdsrvnum = c.atdsrvnum ",
                "   and a.atdsrvano = c.atdsrvano ",
                "   and b.c24astcod in ('PE2','PE1') ",
                "   and a.atddat between ? and ? ",
                " order by c.succod,c.ramcod,c.aplnumdig, ",
                "          c.itmnumdig,c.edsnumref,       ",
                "          a.atddat,a.atdhor"

   prepare pbdbsr134_01 from l_sql
   declare cbdbsr134_01 cursor for pbdbsr134_01

   let l_sql = " select c24txtseq,    ",
               "        c24srvdsc     ",
               " from   datmservhist  ",
               " where  atdsrvnum = ? ",
               " and    atdsrvano = ? "

   prepare pbdbsr134_02 from l_sql
   declare cbdbsr134_02 cursor for pbdbsr134_02

   # por data de pagamento
   let l_sql =  "select c.succod,      ",
                "       c.ramcod,      ",
                "       c.aplnumdig,   ",
                "       c.itmnumdig,   ",
                "       c.edsnumref,   ",
                "       a.atdsrvnum,   ",
                "       a.atdsrvano,   ",
                "       b.c24astcod,   ",
                "       a.c24solnom,   ",
                "       a.atddat,      ",
                "       a.atdhor,      ",
                "       a.pgtdat,      ",
                "       a.atdcstvlr    ",
                "  from datmservico a, ",
                "       datmligacao b, ",
                "       datrservapol c ",
                " where a.atdsrvnum = b.atdsrvnum ",
                "   and a.atdsrvano = b.atdsrvano ",
                "   and a.atdsrvnum = c.atdsrvnum ",
                "   and a.atdsrvano = c.atdsrvano ",
                "   and b.c24astcod in ('PE2','PE1') ",
                "   and a.pgtdat between ? and ?",
                " order by c.succod,c.ramcod,c.aplnumdig, ",
                "          c.itmnumdig,c.edsnumref,       ",
                "          a.atddat,a.atdhor"

        prepare pbdbsr134_03 from l_sql
        declare cbdbsr134_03 cursor for pbdbsr134_03

end function

#----------------------
function bdbsr134()
#----------------------

   define l_mdtbotprgseq char(100),
          l_sql          char(1000),
          l_indice       smallint

   for l_indice = 0 to 30 step 1
      initialize ma_bdbsr134[l_indice].* to null
   end for

   #Relatorio por data de atendimento
   start report bdbsr134_relatorio to m_bdbsr134_path
   start report bdbsr134_relatorio_txt to m_bdbsr134_path_txt #--> RELTXT

      #whenever error continue
      display "m_data_inicio: ",m_data_inicio
      display "m_data_fim   : ",m_data_fim   
            
      open cbdbsr134_01 using m_data_inicio,
                              m_data_fim

      foreach cbdbsr134_01 into mr_bdbsr134.succod    ,
                                mr_bdbsr134.ramcod    ,
                                mr_bdbsr134.aplnumdig ,
                                mr_bdbsr134.itmnumdig ,
                                mr_bdbsr134.edsnumref ,
                                mr_bdbsr134.atdsrvnum ,
                                mr_bdbsr134.atdsrvano ,
                                mr_bdbsr134.c24astcod ,
                                mr_bdbsr134.c24solnom ,
                                mr_bdbsr134.atddat    ,
                                mr_bdbsr134.atdhor    ,
                                mr_bdbsr134.pgtdat    ,
                                mr_bdbsr134.atdcstvlr ,
                                mr_bdbsr134.c24txtseq ,
                                mr_bdbsr134.c24srvdsc

         display "Servico: ", mr_bdbsr134.atdsrvnum,"-",mr_bdbsr134.atdsrvano
         
         open cbdbsr134_02 using mr_bdbsr134.atdsrvnum ,
                                 mr_bdbsr134.atdsrvano
             let l_indice = 0
             foreach cbdbsr134_02 into ma_bdbsr134[l_indice].c24txtseq,
                                       ma_bdbsr134[l_indice].c24srvdsc
                let l_indice = l_indice + 1
             end foreach

         output to report bdbsr134_relatorio()
         output to report bdbsr134_relatorio_txt() #--> RELTXT

         initialize mr_bdbsr134.*, ma_bdbsr134 to null

      end foreach

      #whenever error stop
   
   finish report bdbsr134_relatorio
   finish report bdbsr134_relatorio_txt #--> RELTXT
   
   display "antes m_bdbsr134_path: ",m_bdbsr134_path 
   display "antes  m_bdbsr134_path2: ",m_bdbsr134_path2
   
   if m_bdbsr134_path is null then
      call bdbsr134_busca_path()
   end if
   
   if m_bdbsr134_path = ' ' then
       call bdbsr134_busca_path()
   end if 
   
   if m_bdbsr134_path2 is null then
       call bdbsr134_busca_path()
   end if
   
   if m_bdbsr134_path2 = ' ' then
       call bdbsr134_busca_path()
   end if 
   
   display "depois m_bdbsr134_path: ",m_bdbsr134_path 
   display "depois m_bdbsr134_path2: ",m_bdbsr134_path2 
   
   call bdbsr134_envia_email(m_data_inicio, m_data_fim, 1,m_bdbsr134_path)
   
   initialize mr_bdbsr134.*, ma_bdbsr134 to null
   
   #Relatorio por data de pagamento
   display "depois email m_bdbsr134_path: ",m_bdbsr134_path 
   display "depois email m_bdbsr134_path2: ",m_bdbsr134_path2 
    
   start report bdbsr134_relatorio to m_bdbsr134_path2
   start report bdbsr134_relatorio_txt to m_bdbsr134_path2_txt #--RELTXT

      #whenever error continue

      open cbdbsr134_03 using m_data_inicio,
                              m_data_fim

      foreach cbdbsr134_03 into mr_bdbsr134.succod    ,
                                mr_bdbsr134.ramcod    ,
                                mr_bdbsr134.aplnumdig ,
                                mr_bdbsr134.itmnumdig ,
                                mr_bdbsr134.edsnumref ,
                                mr_bdbsr134.atdsrvnum ,
                                mr_bdbsr134.atdsrvano ,
                                mr_bdbsr134.c24astcod ,
                                mr_bdbsr134.c24solnom ,
                                mr_bdbsr134.atddat    ,
                                mr_bdbsr134.atdhor    ,
                                mr_bdbsr134.pgtdat    ,
                                mr_bdbsr134.atdcstvlr ,
                                mr_bdbsr134.c24txtseq ,
                                mr_bdbsr134.c24srvdsc

         display "Servico Pagamento: ", mr_bdbsr134.atdsrvnum,"-",mr_bdbsr134.atdsrvano
         
         open cbdbsr134_02 using mr_bdbsr134.atdsrvnum ,
                                 mr_bdbsr134.atdsrvano
             let l_indice = 0
             foreach cbdbsr134_02 into ma_bdbsr134[l_indice].c24txtseq,
                                       ma_bdbsr134[l_indice].c24srvdsc
                
                let l_indice = l_indice + 1
             end foreach

         output to report bdbsr134_relatorio()
         output to report bdbsr134_relatorio_txt() #--> RELTXT

         initialize mr_bdbsr134.*, ma_bdbsr134 to null

      end foreach

      #whenever error stop

   finish report bdbsr134_relatorio
   finish report bdbsr134_relatorio_txt #--> RELTXT
    
   display "antes m_bdbsr134_path: ",m_bdbsr134_path 
   display "antes  m_bdbsr134_path2: ",m_bdbsr134_path2
   
    call bdbsr134_busca_path()
   
     call bdbsr134_envia_email(m_data_inicio, m_data_fim, 2,m_bdbsr134_path2)
   
    
    
end function

#-------------------------------------#
report bdbsr134_relatorio()
#-------------------------------------#

  define l_indice smallint,
         l_valor  char(15)

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header


        print "SUCURSAL",       ASCII(09), # 1
              "RAMO",           ASCII(09), # 2
              "APOLICE",        ASCII(09), # 3
              "ITEM",           ASCII(09), # 4
              "ENDOSSO" ,       ASCII(09), # 5
              "SERVICO",        ASCII(09), # 6
              "ANO",            ASCII(09), # 7
              "ASSUNTO",        ASCII(09), # 8
              "SOLICITANTE",    ASCII(09), # 9
              "DATA",           ASCII(09), # 10
              "HORA",           ASCII(09), # 11
              "DATA_PAGAMENTO", ASCII(09), # 12
              "CUSTO",          ASCII(09), # 13
              #"SEQUENCIA",     ASCII(09), # 14
              "DESCRICAO"                  # 15
  on every row


     print mr_bdbsr134.succod    , ASCII(09);  # 1
     print mr_bdbsr134.ramcod    , ASCII(09);  # 2
     print mr_bdbsr134.aplnumdig , ASCII(09);  # 3
     print mr_bdbsr134.itmnumdig , ASCII(09);  # 4
     print mr_bdbsr134.edsnumref , ASCII(09);  # 5
     print mr_bdbsr134.atdsrvnum , ASCII(09);  # 6
     print mr_bdbsr134.atdsrvano , ASCII(09);  # 7
     print mr_bdbsr134.c24astcod , ASCII(09);  # 8
     print mr_bdbsr134.c24solnom , ASCII(09);  # 9
     print mr_bdbsr134.atddat    , ASCII(09);  # 10
     print mr_bdbsr134.atdhor    , ASCII(09);  # 11
     print mr_bdbsr134.pgtdat    , ASCII(09);  # 12

     call bdbsr134_troca_ponto(mr_bdbsr134.atdcstvlr)
        returning l_valor

     print l_valor  clipped, ASCII(09);  # 13
     #print ASCII(09);
     for l_indice = 0 to 30 step 1
        if ma_bdbsr134[l_indice].c24txtseq is not null then
           if ma_bdbsr134[l_indice].c24srvdsc is not null then
              print ma_bdbsr134[l_indice].c24txtseq using "<<<"clipped , "-",
                    ma_bdbsr134[l_indice].c24srvdsc, ";";
           end if
        else
           print ""
           exit for
        end if
     end for

end report

#------------------------------------------#
report bdbsr134_relatorio_txt() #--> RELTXT
#------------------------------------------#

  define l_indice smallint,
         l_valor  char(15)

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

  on every row

     print mr_bdbsr134.succod    , ASCII(09);  # 1
     print mr_bdbsr134.ramcod    , ASCII(09);  # 2
     print mr_bdbsr134.aplnumdig , ASCII(09);  # 3
     print mr_bdbsr134.itmnumdig , ASCII(09);  # 4
     print mr_bdbsr134.edsnumref , ASCII(09);  # 5
     print mr_bdbsr134.atdsrvnum , ASCII(09);  # 6
     print mr_bdbsr134.atdsrvano , ASCII(09);  # 7
     print mr_bdbsr134.c24astcod , ASCII(09);  # 8
     print mr_bdbsr134.c24solnom , ASCII(09);  # 9
     print mr_bdbsr134.atddat    , ASCII(09);  # 10
     print mr_bdbsr134.atdhor    , ASCII(09);  # 11
     print mr_bdbsr134.pgtdat    , ASCII(09);  # 12

     call bdbsr134_troca_ponto(mr_bdbsr134.atdcstvlr)
        returning l_valor

     print l_valor  clipped, ASCII(09);  # 13
     #print ASCII(09);
     for l_indice = 0 to 30 step 1
        if ma_bdbsr134[l_indice].c24txtseq is not null then
           if ma_bdbsr134[l_indice].c24srvdsc is not null then
              print ma_bdbsr134[l_indice].c24txtseq using "<<<"clipped , "-",
                    ma_bdbsr134[l_indice].c24srvdsc, ";";
           end if
        else
           print ""
           exit for
        end if
     end for

end report

#-----------------------------------
function bdbsr134_troca_ponto(param)
#-----------------------------------
   define param record
     valor like datmservico.atdcstvlr
   end record

   define l_char char(15),
          l_i    smallint

   let l_char = param.valor

   for l_i = 1 to 15 step 1

     if l_char[l_i] = "." then
        let l_char[l_i] = ","
     end if

   end for

   return l_char

end function

#------------------------------------------
function bdbsr134_calcula_datafim(l_data)
#------------------------------------------
   define l_data date

   let l_data = l_data + 1 units month - 1 units day

   return l_data

end function

#-----------------------------
function bdbsr134_busca_path()
#-----------------------------

   define l_dataarq char(8)
   define l_data    date
   
   let l_data = today
   display "l_data: ", l_data
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)
   display "l_dataarq: ", l_dataarq


   # ---> INICIALIZACAO DAS VARIAVEIS
   let m_bdbsr134_path = null
   
   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
   let m_bdbsr134_path = f_path("DBS","LOG")
   
   let m_bdbsr134_path2 = f_path("DBS","LOG")
   
   if m_bdbsr134_path is null then
      let m_bdbsr134_path = "."
   end if
   
   if m_bdbsr134_path2 is null then
      let m_bdbsr134_path2 = "."
   end if
   
   let m_bdbsr134_path = m_bdbsr134_path clipped, "/BDBSR134_Atendimento.log"
   call startlog(m_bdbsr134_path)
   
   let m_bdbsr134_path2 = m_bdbsr134_path2 clipped, "/BDBSR134_Pagamento.log"
   call startlog(m_bdbsr134_path2)
   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   
   let m_bdbsr134_path = f_path("DBS", "RELATO")
   
   let m_bdbsr134_path2 = f_path("DBS", "RELATO")
   
   
   #let  m_bdbsr134_path2 = "/asheeve"
   #let  m_bdbsr134_path = "/asheeve"
   
   if m_bdbsr134_path is null then
      let m_bdbsr134_path = "."
   end if
   
   if m_bdbsr134_path2 is null then
      let m_bdbsr134_path2 = "."
   end if

   let m_bdbsr134_path_txt = m_bdbsr134_path clipped, "/BDBSR134_Atendimento_", l_dataarq, ".txt" 
   let m_bdbsr134_path     = m_bdbsr134_path clipped, "/BDBSR134_Atendimento.xls"

   let m_bdbsr134_path2_txt = m_bdbsr134_path2 clipped, "/BDBSR134_Pagamento_", l_dataarq, ".txt" 
   let m_bdbsr134_path2     = m_bdbsr134_path2 clipped, "/BDBSR134_Pagamento.xls"
   
   display "m_bdbsr134_path: ",m_bdbsr134_path 
   display "m_bdbsr134_path2: ",m_bdbsr134_path2
  
end function


#-----------------------------------------#
function bdbsr134_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date,
         tipo         smallint,
         path         char(100)
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200),
         l_tipo        char(15)

  # ---> INICIALIZACAO DAS VARIAVEIS
  if lr_parametro.tipo = 1 then
    let l_tipo = 'Atendimento'
  else
    let l_tipo = 'Pagamento'
  end if

  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Relatorio PET Filtro por data de ",
                     l_tipo clipped,
                     " do mes: ",
                     month(lr_parametro.data_inicial),
                     "/", year(lr_parametro.data_inicial)

  display "lr_parametro.path: ",lr_parametro.path
  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -c ", lr_parametro.path clipped," > ",lr_parametro.path clipped, ".gz"
  
  display "l_comando: ",l_comando
  
  run l_comando
  let lr_parametro.path = lr_parametro.path clipped, ".gz"
  
  display "lr_parametro.path2qw: ",lr_parametro.path
  
  let l_erro_envio = ctx22g00_envia_email("BDBSR134", l_assunto, lr_parametro.path)
  
  display "l_erro_envio: ",l_erro_envio
  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", lr_parametro.path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR134"
     end if
  end if

end function
