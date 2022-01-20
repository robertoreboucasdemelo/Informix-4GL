###############################################################################
# Nome do Modulo: BDATA050                                                    #
# Analista: Patricia Egri Wissinievski                                        #
# Data criação: 28/04/2009                                                    #
#                                                                             #
# Objetivo: Carga do arquivo de bloqueio de ligações - PROCON                 #
#                                                                             #
# PSI - 239976 - Lei Nao Perturbe                                             #
#                                                                             #
###############################################################################
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 16/04/2012 Silvia,Meta  PSI 2012-07408  Projeto Anatel-Aumento DDD/Telefone #
#-----------------------------------------------------------------------------#

database porto

define m_path_arq char(80),
       m_path_log char(80),
       m_mensagem char(150)


main
   
   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read


   # Path do LOG
   let m_path_log = f_path("DAT", "LOG")

      
   if m_path_log is null then 
      let m_path_log = 'bdata050.log'
   else
      let m_path_log = m_path_log clipped, '/bdata050.log'
   end if 


   # Path do Arquivo de entrada
   let m_path_arq = 'arquivoblq.txt'

   call startlog(m_path_log)
   
   call ERRORLOG("------------------------------------------------");
   call ERRORLOG("Inicio execucao BDATA050 ");
   
   call bdata050()

   call ERRORLOG("Termino execucao BDATA050 OK! ");
   call ERRORLOG("------------------------------------------------");

end main

#----------------------------------------------------------------------------
 function bdata050()   
#----------------------------------------------------------------------------
   define l_count int
   
   define r_bloqueio record
          telefone char(10), 
          datsol   date,     
          stat     char(12),      
          datvig   date
   end record

   define l_sql char(800)
   define l_linha char(60)
   define l_ddd like datmtelligblq.dddnum,       ## int, - Anatel
          l_telefone char(14),                   ## int, - Anatel
          l_status int,
          l_letra char(1),
          l_data date,
          l_year char(4),
          l_day char(2),
          l_month char(2),
          l_importados int,
          l_comando char (150),
          l_erro int, 
          l_for int,
          l_nomearq char(19),
          l_erros int


   define l_linhas integer
   
   
   let m_mensagem = "Criando tabelas temporarias.." 
   call ERRORLOG(m_mensagem);

   create temp table t_arquivos(nomearquivo char(19)) 
   
   create temp table t_load_datmtelligblq(telefone char(14), ## char(10), Anatel
                                          datsol   date,
                                          stat     char(12),
                                          datvig   date)
   
  
   let l_sql = " select * ",
                 " from t_load_datmtelligblq for update"
   prepare pbdata050001 from l_sql
   declare cbdata050001 cursor with hold for pbdata050001 


   let l_sql = " insert into datmtelligblq ",
               " (telnum, dddnum, clisoldat, clisolstt, viginc, incdat) ",
               "   values ",
               " (?, ?, ?, ?, ?, today)"
   prepare pbdata050002 from l_sql

   let l_sql = " select count(*) from datmtelligblq ",
               " where dddnum = ? ",
               "   and telnum = ? ",
               "   and clisolstt = ?",
               "   and clisoldat = ?"
   prepare pbdata050003 from l_sql
   declare cbdata050003 cursor for pbdata050003  
   
   let l_sql = " select * from t_arquivos "
   prepare pbdata050004 from l_sql
   declare cbdata050004 cursor with hold for pbdata050004  


   # acessa pasta de entrada dos arquivos

   let l_comando = "cd /adat/entra_bloq" 

   run l_comando 
      returning l_erro

   if l_erro <> 0 then
      call  errorlog("Não foi possivel acessar a pasta de importacao!")  
      return
   end if

   # pega todos os arquivos com extensão CSV e csv
   let l_comando = "ls *.[C,c]* > temp.txt" 

   run l_comando 
      returning l_erro

   if l_erro = 0 then
      whenever error continue

      load from 'temp.txt' insert into t_arquivos

      whenever error stop

      if sqlca.sqlcode <> 0 then
        let m_mensagem = '(ERRO ' , sqlca.sqlcode ,
                       ') - ERRO NA IMPORTACAO DA LISTA PARA TABELA TEMPORARIA! '
        call ERRORLOG(m_mensagem);
        return
      end if
  
   else
      call  errorlog("Nenhum arquivo localizado para importação!")  
      return
   end if

    
   open cbdata050004 
   foreach cbdata050004 into l_nomearq
       let l_nomearq = l_nomearq clipped
       
       #remove cabecalho e rodape dos arquivos CSV
       let l_comando = "sed '/ Numero/d;/ Fundacao/d;/ Bloqueio/d;/ Arquivo/d;/#/d;/END OF FILE/d' ",
                       l_nomearq," > arquivoblq.txt"      
       let l_comando = l_comando clipped
       
       run l_comando
         returning l_erro
         
       if l_erro = 0 then
            let m_mensagem = "Leitura arquivo ", l_nomearq
            call ERRORLOG(m_mensagem);
            
               whenever error continue

               delete from t_load_datmtelligblq

               whenever error stop
               if sqlca.sqlcode <> 0 then
                 let m_mensagem = '(ERRO ' , sqlca.sqlcode ,') - ERRO NA REMOCAO DOS DADOS DA TABELA! '
                 call ERRORLOG(m_mensagem);
                 continue foreach
               end if

               whenever error continue

               load from m_path_arq delimiter ';' insert into t_load_datmtelligblq
            
               whenever error stop
            
               if sqlca.sqlcode <> 0 then
                 let m_mensagem = '(ERRO ' , sqlca.sqlcode ,') - ERRO NA ABERTURA DO ARQUIVO DE IMPORTACAO! '
                 call ERRORLOG(m_mensagem);
                 continue foreach
               end if
            
               select count(*) into l_linhas
                 from t_load_datmtelligblq
            
               let m_mensagem = l_linhas using "&&&&&", " linhas lidas."
               call ERRORLOG(m_mensagem);
             
       else 
          let m_mensagem = "Arquivo ", l_nomearq, " nao foi renomeado!!!!"
          call errorlog (m_mensagem)
          continue foreach #pega o proximo
       end if 
       
      
      let l_importados = 0
      
      open cbdata050001
      foreach cbdata050001 into r_bloqueio.*
                 
         let l_ddd = r_bloqueio.telefone[1,4] ## [1,2] - Anatel
         let l_telefone = r_bloqueio.telefone[5,14] ## [3,10] - Anatel
      
         if upshift(r_bloqueio.stat) = 'BLOQUEADO' then
            let l_status = 1
         else
            let l_status = 0
         end if
         
         let l_count = 0
         
         open cbdata050003 using l_ddd, 
                                 l_telefone, 
                                 l_status, 
                                 r_bloqueio.datsol
                                 
            fetch cbdata050003 into l_count 
         close cbdata050003
      
         # se nao encontrou nenhum registro na base com a chave, insere      
         if l_count = 0 then
            display 'REG NOVO (',l_nomearq clipped,'): ',  l_telefone using "##&&&&&&&&",            
                                                     l_ddd using "###&",   
                                                     r_bloqueio.datsol,     
                                                     l_status using "&&&&",
                                                     r_bloqueio.datvig clipped      

            begin work
      
            whenever error continue
            
            execute pbdata050002 using l_telefone,
                                       l_ddd,
                                       r_bloqueio.datsol,
                                       l_status,
                                       r_bloqueio.datvig
      
            whenever error stop   
      
            if sqlca.sqlcode <> 0 then
               let m_mensagem = '(ERRO ' , sqlca.sqlcode,
                                ') - ERRO NA IMPORTAÇÃO DAS INFORMAÇÕES (1)'
               call ERRORLOG(m_mensagem);

               let m_mensagem = '***** REG ERRO: ' , 
                                l_telefone, ' ',        
                                l_ddd, ' ',
                                r_bloqueio.datsol, ' ',
                                l_status, ' ',
                                r_bloqueio.datvig, ' ', 'IMPORTADOS: ', l_importados  
               call ERRORLOG(m_mensagem);
               
               rollback work
            else    
               commit work

               let l_importados = l_importados + 1
            end if
         else   
            display 'REG EXISTE (',l_nomearq clipped,'): ',  l_telefone using "##&&&&&&&&&&&&",   # Anatel ) + 4 & ) 
                                                     l_ddd using "###&",                 
                                                     r_bloqueio.datsol,     
                                                     l_status using "&&&&",
                                                     r_bloqueio.datvig clipped      
         end if
          
      end foreach

      let m_mensagem = 'Arquivo ', l_nomearq, ':', l_importados ,' Novos Registros Importados'
      call ERRORLOG(m_mensagem);

      let l_comando = 'mv ', l_nomearq , ' /adat/hist_blq'
      run l_comando
         returning l_erro

      if l_erro = 0 then
         let m_mensagem = "Arquivo ", l_nomearq, " movido para historico."
         let l_comando = "rm arquivoblq.txt"
         run l_comando
      else   
         let m_mensagem = "Problemas em mover o arquivo ", l_nomearq, " para historico."
      end if   
      call errorlog(m_mensagem)
      
   end foreach
     
end function

