#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: CTC44M08                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: DESBLOQUEIO DE SOCORRISTAS SEM SEGURO DE VIDA              #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: 22/06/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto 

globals "/homedsa/projetos/geral/globals/glct.4gl"  
  
 define ma_socorrista array[5000] of record
        aux              char(01),                       # Auxiliar para o input e controle na tela     
        srrcoddig        like datrsrrpst.srrcoddig,      # Código do Socorrista     
        srrabvnom        like datksrr.srrabvnom,         # Nome de Guerra do Socorrista
        pstcoddig        like datrsrrpst.pstcoddig,      # Codigo do Prestador
        nomgrr           like dpaksocor.nomgrr,          # Nome de guerra do Prestador
        srrblqdat        like datmsegsemsrrblq.srrblqdat # Data do bloqueio do socorrista 
         
 end record

 define mr_aux record
     dbqobs  char(200)
 end record

 define m_arr_curr smallint,
        m_scr_curr smallint

#---------------------------#
 function ctc44m08_prepare()
#---------------------------#

     define l_sql char(5000)

     
     let l_sql = "select srrcoddig,       ",
                 "       srrblqdat        ",
                 "  from datmsegsemsrrblq ",
                 " where blqflg = 'B'     "

     prepare pctc44m08_01 from l_sql
     declare cctc44m08_01 cursor for pctc44m08_01 
     
     
     let l_sql = "select pstcoddig   ",
                 " from datrsrrpst   ",
                 "where srrcoddig = ?",
                 "  and viginc <= ?  ",
                 "  and vigfnl >= ?  "

     prepare pctc44m08_02 from l_sql
     declare cctc44m08_02 cursor for pctc44m08_02
     
     
     let l_sql = "select srrabvnom   ",
                 "  from datksrr     ",
                 "where srrcoddig = ?"
                 
     prepare pctc44m08_03 from l_sql
     declare cctc44m08_03 cursor for pctc44m08_03
     
     let l_sql = "select nomgrr      ",
                 " from dpaksocor    ",
                 "where pstcoddig = ?"

     prepare pctc44m08_04 from l_sql
     declare cctc44m08_04 cursor for pctc44m08_04

     
     let l_sql = "update datksrr      ", 
                 "   set srrstt = 1   ", 
                 " where srrcoddig = ?"  
     prepare pctc44m08_05 from l_sql    
     
     let l_sql = "update datmsegsemsrrblq      ",   
                 "   set (blqflg,dsbfunmat,    ", #dsbfunmat - funcionario que desbloqueou
                 "         srrdsbdat,blqobs) = ",  
                 "       ('D',?,?,?)           ",  
                 "  where srrcoddig = ?        "                
     prepare pctc44m08_06 from l_sql        
     
     
 end function

#-------------------#
 function ctc44m08()
#-------------------#

     define l_ind      smallint,
            l_vst      smallint,
            l_count    smallint,
            l_rodape   char(50),
            l_rodape2   char(100)            

     
  
     call ctc44m08_prepare()

     open window w_ctc44m08 at 6,2 with form 'ctc44m08'
       attribute(form line 1, border)
     initialize ma_socorrista to null
     while true
         initialize ma_socorrista to null
         let l_ind = 1
         clear form
         

         error 'Buscando Socorristas.'
         
         #--------------------------------------------|
         # BUSCA TODOS OS SOCORRISTAS BLOQUEADOS      |
         #--------------------------------------------| 
         whenever error continue
         open cctc44m08_01
         fetch cctc44m08_01 into ma_socorrista[l_ind].srrcoddig,
                                 ma_socorrista[l_ind].srrblqdat
         if sqlca.sqlcode = 0 and sqlca.sqlcode <> notfound  then                        
            whenever error continue
            foreach cctc44m08_01 into ma_socorrista[l_ind].srrcoddig,
                                      ma_socorrista[l_ind].srrblqdat
                  
                  #--------------------------------------------|  
                  # BUSCA O PRESTADOR DA VIGENCIA DO BLOQUEIO  |  
                  #--------------------------------------------|  
                  whenever error continue
                     open cctc44m08_02 using ma_socorrista[l_ind].srrcoddig,
                                             ma_socorrista[l_ind].srrblqdat,
                                             ma_socorrista[l_ind].srrblqdat         
                     fetch cctc44m08_02 into ma_socorrista[l_ind].pstcoddig 
                  whenever error stop
                  
                  #-------------------------------------------------|  
                  # BUSCA O NOME ABREVIADO DO SOCORRISTA BLOQUEADO  |  
                  #-------------------------------------------------|
                  whenever error continue
                     open cctc44m08_03 using ma_socorrista[l_ind].srrcoddig         
                     fetch cctc44m08_03 into ma_socorrista[l_ind].srrabvnom 
                  whenever error stop
                  
                  #---------------------------------------|  
                  # BUSCA O NOME DE GUERRA DO PRESTADOR   |  
                  #---------------------------------------|
                  whenever error continue
                     open cctc44m08_04 using ma_socorrista[l_ind].pstcoddig         
                     fetch cctc44m08_04 into ma_socorrista[l_ind].nomgrr 
                  whenever error stop
               
                 #---------------------------------------------|  
                 # SOMA MAIS UM NO NUMERO DE LINHAS DO ARRAY   |  
                 #---------------------------------------------|
                    
                    let l_ind = l_ind + 1
              end foreach
            whenever error stop
         else
            error "Nao existem Socorristas bloqueados."
            sleep 2
            exit while   
         end if      
         
         #-----------------------------|  
         # NUMERO DE LINHAS DO ARRAY   |  
         #-----------------------------|                   
         call set_count(l_ind - 1)                        
           error ""                       
          
         #-----------------------|  
         # EXIBE DADOS NA TELA   |  
         #-----------------------|                         
         input array ma_socorrista without defaults from s_socorrista.*                        
                                    
            before row
               let m_arr_curr = arr_curr()
               let m_scr_curr = scr_line()
               let l_rodape = "F8 - Desbloquear"                         
               display l_rodape to rodape
               let ma_socorrista[m_arr_curr].aux = ">"  
               display ma_socorrista[m_arr_curr].* to
                       s_socorrista[m_scr_curr].* attribute (reverse)
                                    
            after row
               let m_arr_curr = arr_curr()
               let m_scr_curr = scr_line() 
               let ma_socorrista[m_arr_curr].aux = ""
               display ma_socorrista[m_arr_curr].* to
                       s_socorrista[m_scr_curr].*
            
                
            
            #----------------------------|
            # DESBLOQUEIA O SOCORRISTA   |
            #----------------------------|    
            on key (f8)
              call ctx00m00_texto_padrao("","")
                   returning mr_aux.dbqobs            
              if  mr_aux.dbqobs is not null and
                  mr_aux.dbqobs <> " " then
                  if  not ctc44m08_atualiza() then
                      error "Erro ao desbloquear Socorrista!"     
                      sleep 2              
                  end if
                  exit input
              else
                 error "Motivo do desbloqueio obrigatorio! "
                 sleep 2
              end if
         end input
         
         if  int_flag then 
             exit while    
         end if            

     end while
         
     close window w_ctc44m08

 end function

#----------------------------#
 function ctc44m08_atualiza()
#----------------------------#

     define lr_retorno record
         cod_erro  integer,
         msg_erro  char(250),
         stt smallint ,
         msg char(50)
     end record

     define l_titulo   char(050),
            l_mensagem char(500),
            l_data     date  

     let l_data = today
     #-------------------------------------|
     # ATUALIZA A SITUACAO DO SOCORRISTA   |
     #-------------------------------------|
     whenever error continue
        execute pctc44m08_05 using ma_socorrista[m_arr_curr].srrcoddig
        if sqlca.sqlcode <> 0 then
           display 'Problema na atualização da tabela (1): ', sqlca.sqlcode
           return false
        end if
     whenever error stop
     
     #----------------------------------------|            
     # ATUALIZA O DESBLOQUEIO DO SOCORRISTA   |
     #----------------------------------------|
     whenever error continue
        execute pctc44m08_06 using g_issk.funmat,
                                   l_data,
                                   mr_aux.dbqobs,
                                   ma_socorrista[m_arr_curr].srrcoddig 
        if sqlca.sqlcode <> 0 then
           display 'Problema na atualização da tabela (2): ', sqlca.sqlcode
           return false
        end if                                                            
     whenever error stop
     
     let l_mensagem = 'O socorrista ',ma_socorrista[m_arr_curr].srrcoddig using '<<<<&', 
                      ' foi desbloqueado por: ',g_issk.funmat,'. '      
                      
     call ctd18g01_grava_hist(ma_socorrista[m_arr_curr].srrcoddig ,
                              l_mensagem,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              'F')               
     returning lr_retorno.stt               
              ,lr_retorno.msg
     
     if lr_retorno.stt <> 1 then
        display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
        display "Mensagem: ",lr_retorno.msg                       
        error "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
        sleep 2
     end if           
     
     
     
     let l_mensagem = 'Motivo: ', mr_aux.dbqobs clipped,'.'      
                      
     call ctd18g01_grava_hist(ma_socorrista[m_arr_curr].srrcoddig ,
                              l_mensagem,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              'F')               
     returning lr_retorno.stt               
              ,lr_retorno.msg
     
     if lr_retorno.stt <> 1 then
        display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
        display "Mensagem: ",lr_retorno.msg                       
        error "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
        sleep 2
     end if 
     
     
   return true
end function    
