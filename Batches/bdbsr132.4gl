#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR132.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2011-09700/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  RELATORIO QRV2                                            #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 26/07/2011                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #

database porto

define  m_path         char(100),
        m_path_txt     char(100),
        m_data_inicio  date,
        m_data_fim     date,
        m_data         date,
        m_hora         datetime hour to minute


define mr_bdbsr132   record                      
       mdtmvtseq       like datmmdtmvt.mdtmvtseq   ,
       caddat          like datmmdtmvt.caddat      ,
       cadhor          like datmmdtmvt.cadhor      ,
       mdtcod          like datmmdtmvt.mdtcod      ,
       mdtbotprgseq    like datmmdtmvt.mdtbotprgseq,
       ufdcod          like datmmdtmvt.ufdcod      ,
       cidnom          like datmmdtmvt.cidnom      ,
       brrnom          like datmmdtmvt.brrnom      ,
       atdsrvnum       like datmmdtmvt.atdsrvnum   ,
       atdsrvano       like datmmdtmvt.atdsrvano          
end record                                     

main

   initialize mr_bdbsr132.*,
              m_data,
              m_data_inicio,
              m_data_fim,
              m_hora        to null
   
   
   let m_data = arg_val(1)
         
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
   call cts40g03_exibe_info("I","BDBSR132")
   call bdbsr132_busca_path()
   display ""
   set isolation to dirty read
   call bdbsr132()
   call cts40g03_exibe_info("F","BDBSR132")

end main


#----------------------
function bdbsr132()
#----------------------
   
   define l_mdtbotprgseq char (100),
          l_sql          char(1000)
   
   let l_mdtbotprgseq = bdbsr132_dominio('mdtbotprgseq') 
   
   let l_sql =  "select mdtmvtseq,                               ",            
                "       caddat,                                  ",            
                "       cadhor,                                  ",            
                "       mdtcod,                                  ",            
                "       mdtbotprgseq,                            ",            
                "       ufdcod,                                  ",            
                "       cidnom,                                  ",            
                "       brrnom,                                  ",            
                "       atdsrvnum,                               ",            
                "       atdsrvano                                ",            
                "  from datmmdtmvt                               ",            
                " where mdtmvttipcod = 2                         ",            
                "   and mdtbotprgseq in(",l_mdtbotprgseq,") ",                    
                "   and caddat between '",m_data_inicio,"' and '",m_data_fim ,"'", 
                " order by mdtmvtseq,caddat,cadhor,mdtcod        "           
        prepare pbdbsr132_01 from l_sql
        declare cbdbsr132_01 cursor for pbdbsr132_01
   
   
   start report bdbsr132_relatorio to m_path
   start report bdbsr132_relatorio_txt to m_path_txt

      open cbdbsr132_01
      
      foreach cbdbsr132_01 into mr_bdbsr132.mdtmvtseq   ,
                                mr_bdbsr132.caddat      ,
                                mr_bdbsr132.cadhor      ,
                                mr_bdbsr132.mdtcod      ,
                                mr_bdbsr132.mdtbotprgseq,
                                mr_bdbsr132.ufdcod      ,
                                mr_bdbsr132.cidnom      ,
                                mr_bdbsr132.brrnom      ,
                                mr_bdbsr132.atdsrvnum   ,
                                mr_bdbsr132.atdsrvano   
         
        
         output to report bdbsr132_relatorio()   
         output to report bdbsr132_relatorio_txt()                                                
                                                                                                                
         initialize mr_bdbsr132.* to null                          
                                                                   
      end foreach                                                  
                                                                   
      close cbdbsr132_01                                           

   
   finish report bdbsr132_relatorio
   finish report bdbsr132_relatorio_txt
   
   call bdbsr132_envia_email(m_data_inicio, m_data_fim)

end function


#-------------------------------------#
report bdbsr132_relatorio()
#-------------------------------------#

            
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header
			

        print "CODIGO_SEQUENCIA_MDT", ASCII(09),  # 1
              "DATA",                 ASCII(09),  # 2
              "HORA",                 ASCII(09),  # 3
              "CODIGO_MDT",           ASCII(09),  # 4
              "BOTAO" ,               ASCII(09),  # 5
              "UF",                   ASCII(09),  # 6
              "CIDADE",               ASCII(09),  # 7
              "BAIRRO",               ASCII(09),  # 8
              "NUMERO_DO_SERVICO",    ASCII(09),  # 9
              "ANO_DO_SERVICO"                    # 10
                                          
         
  on every row

     
     print mr_bdbsr132.mdtmvtseq   , ASCII(09);  # 1 
     print mr_bdbsr132.caddat      , ASCII(09);  # 2 
     print mr_bdbsr132.cadhor      , ASCII(09);  # 3 
     print mr_bdbsr132.mdtcod      , ASCII(09);  # 4 
     print mr_bdbsr132.mdtbotprgseq, ASCII(09);  # 5 
     print mr_bdbsr132.ufdcod      , ASCII(09);  # 6 
     print mr_bdbsr132.cidnom      , ASCII(09);  # 7 
     print mr_bdbsr132.brrnom      , ASCII(09);  # 8 
     print mr_bdbsr132.atdsrvnum   , ASCII(09);  # 9 
     print mr_bdbsr132.atdsrvano                 # 10
            
end report



function bdbsr132_calcula_datafim(l_data)

   define l_data date
   
   let l_data = l_data + 1 units month - 1 units day
   
   return l_data


end function


function bdbsr132_busca_path()

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
   let m_path = m_path clipped, "/BDBSR132.log" 
   call startlog(m_path)
   
   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   let m_path = f_path("DBS", "RELATO")
   
   if m_path is null then
      let m_path = "."
   end if

   let m_path_txt = m_path clipped, "/BDBSR132_", l_dataarq, ".txt"   
   let m_path     = m_path clipped, "/BDBSR132.xls"
   
end function


#-----------------------------------------#
function bdbsr132_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200)

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Relatorio QRV2  - ",
                     
                     " do mes: ",
                     month(lr_parametro.data_inicial),
                     "/",year(lr_parametro.data_inicial)

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando
  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR132", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR132"
     end if
  end if

end function

#Funcao que retorna todos os dominios concatenados separados por ','
#---------------------------------
function bdbsr132_dominio(l_cponom)
#---------------------------------
   
         
   define l_cponom     like iddkdominio.cponom,
          l_cponom_aux like iddkdominio.cponom,
          l_retorno char(500),
          l_qtd     smallint,
          l_cont    smallint
   
   initialize l_cponom_aux, l_retorno to null
   
   select count(cpodes)
   into   l_qtd
   from   iddkdominio
   where  cponom = l_cponom
   
   
   let l_cont = 0
   declare cdominio cursor for
      
      select cpodes
      from   iddkdominio
      where  cponom = l_cponom
      
      foreach cdominio into l_cponom_aux  
         
         let l_cont = l_cont + 1         
         if l_qtd = 1 then
            let l_retorno = l_retorno clipped, l_cponom_aux clipped
            return l_retorno clipped
         else
            if l_cont = 1 then
               let l_retorno = l_retorno clipped, l_cponom_aux clipped
            else
               let l_retorno = l_retorno clipped, ',', l_cponom_aux clipped
            end if
         end if
         
         initialize l_cponom_aux to null
      
         
      end foreach
   
   return l_retorno clipped


end function

#-------------------------------------#
report bdbsr132_relatorio_txt()
#-------------------------------------#

            
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

     on every row

     
     print mr_bdbsr132.mdtmvtseq   , ASCII(09);  # 1 
     print mr_bdbsr132.caddat      , ASCII(09);  # 2 
     print mr_bdbsr132.cadhor      , ASCII(09);  # 3 
     print mr_bdbsr132.mdtcod      , ASCII(09);  # 4 
     print mr_bdbsr132.mdtbotprgseq, ASCII(09);  # 5 
     print mr_bdbsr132.ufdcod      , ASCII(09);  # 6 
     print mr_bdbsr132.cidnom      , ASCII(09);  # 7 
     print mr_bdbsr132.brrnom      , ASCII(09);  # 8 
     print mr_bdbsr132.atdsrvnum   , ASCII(09);  # 9 
     print mr_bdbsr132.atdsrvano                 # 10
            
end report