###########################################################################
# Nome do Modulo: ctc91m22                                                #
#                                                                         #
# Correcao do arquivo original de carga para reprocessar         Jan/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define a_ctc91m22 record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum  
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum  
      ,itaaplnum           like datmdetitaasiarq.itaaplnum        
      ,itaaplitmnum        like datmdetitaasiarq.itaaplitmnum     
      ,itaciacod           like datmdetitaasiarq.itaciacod        
      ,itaciades           like datkitacia.itaciades
      ,itaramcod           like datmdetitaasiarq.itaramcod        
      ,itaramdes           like datkitaram.itaramdes
      ,itaaplcanmtvcod     like datmdetitaasiarq.itaaplcanmtvcod  
      ,itaaplcanmtvdes     like datkitaaplcanmtv.itaaplcanmtvdes                
   end record


#========================================================================
function ctc91m22_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT itaasiarqvrsnum ", 
               "      ,itaasiarqlnhnum ",
               "      ,itaaplnum ",
               "      ,itaaplitmnum ",
               "      ,itaciacod ",
               "      ,itaramcod ",
               "      ,itaaplcanmtvcod ",
               "FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   itaasiarqlnhnum = ? "
   prepare pctc91m22001 from l_sql
   declare cctc91m22001 cursor for pctc91m22001

   let l_sql = "UPDATE datmdetitaasiarq    ",
               "SET    itaciacod       = ? ",
               "      ,itaramcod       = ? ",
               "      ,itaaplcanmtvcod = ? ",
               "WHERE itaasiarqvrsnum = ?  ",
               "AND   itaasiarqlnhnum = ?  "
   prepare pctc91m22002 from l_sql
   
   let l_sql = "SELECT itaciades    ",
               "FROM datkitacia     ",
               "WHERE itaciacod = ? "
   prepare pctc91m22003 from l_sql
   declare cctc91m22003 cursor for pctc91m22003

   let l_sql = "SELECT itaaplcanmtvdes    ",
               "FROM datkitaaplcanmtv     ",
               "WHERE itaaplcanmtvcod = ? "
   prepare pctc91m22009 from l_sql
   declare cctc91m22009 cursor for pctc91m22009

   let l_sql = "SELECT itaramdes    ",
               "FROM datkitaram     ",
               "WHERE itaramcod = ? "
   prepare pctc91m22015 from l_sql
   declare cctc91m22015 cursor for pctc91m22015
                   
#========================================================================
end function # Fim da funcao ctc91m22_prepare
#========================================================================

#========================================================================
function ctc91m22_input(lr_param)
#========================================================================

   define lr_param record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
   end record

   define lr_retorno record
       erro  smallint
     ,msg   char(70)
   end record

   define l_index       smallint
   define arr_aux       smallint
   define scr_aux       smallint
   define l_prox_arr    smallint
   define l_erro        smallint

   initialize lr_retorno.* to null
   
   let int_flag = false
   
   open window w_ctc91m22 at 4,2 with form 'ctc91m22'
      attribute(form line first, message line first +19 ,comment line first +18, border)
      #attribute(form line first, message line last,comment line last - 1, border)


   while true
      
      call ctc91m22_prepare()
      
      message "        (F5)Atualizar Dados              (F17)Volta"
      
      call ctc91m22_limpa_campos()
      call ctc91m22_preenche_dados_tela(lr_param.*)
      
      call ctc91m22_preenche_companhia()
      call ctc91m22_preenche_ramo()
      call ctc91m22_preenche_motivo_cancelamento()
     
      input by name a_ctc91m22.* without defaults

        #--------------------
         on key (interrupt, control-c)
        #--------------------              
            let int_flag = true
            exit input

        #--------------------            
         before field itaciacod
        #--------------------
            display a_ctc91m22.itaciacod to 
               s_ctc91m22.itaciacod attribute(reverse)
            
        #--------------------            
         after field itaciacod
        #--------------------
            call ctc91m22_preenche_companhia()
            if a_ctc91m22.itaciacod = " " or
               a_ctc91m22.itaciades is null or
               a_ctc91m22.itaciades = " " then
               call cto00m10_popup(1) returning a_ctc91m22.itaciacod,
                                                a_ctc91m22.itaciades
               call ctc91m22_preenche_companhia()
            end if        
            display a_ctc91m22.itaciacod to 
               s_ctc91m22.itaciacod attribute(normal)
               
        #--------------------            
         before field itaramcod
        #--------------------
            display a_ctc91m22.itaramcod to 
               s_ctc91m22.itaramcod attribute(reverse)
            
        #--------------------            
         after field itaramcod
        #--------------------
            call ctc91m22_preenche_ramo()
            if a_ctc91m22.itaramcod = " " or
               a_ctc91m22.itaramdes is null or
               a_ctc91m22.itaramdes = " " then
               call cto00m10_popup(10) returning a_ctc91m22.itaramcod,
                                                 a_ctc91m22.itaramdes
               call ctc91m22_preenche_ramo()
            end if        
            display a_ctc91m22.itaramcod to 
               s_ctc91m22.itaramcod attribute(normal)
               
        #--------------------            
         before field itaaplcanmtvcod
        #--------------------
            display a_ctc91m22.itaaplcanmtvcod to 
               s_ctc91m22.itaaplcanmtvcod attribute(reverse)
            
        #--------------------            
         after field itaaplcanmtvcod
        #--------------------
            call ctc91m22_preenche_motivo_cancelamento()
            if a_ctc91m22.itaaplcanmtvcod = " " or
               a_ctc91m22.itaaplcanmtvdes is null or
               a_ctc91m22.itaaplcanmtvdes = " " then
               call cto00m10_popup(12) returning a_ctc91m22.itaaplcanmtvcod,
                                                 a_ctc91m22.itaaplcanmtvdes
               call ctc91m22_preenche_motivo_cancelamento()
            end if           
            display a_ctc91m22.itaaplcanmtvcod to 
               s_ctc91m22.itaaplcanmtvcod attribute(normal)
            next field itaciacod

        #--------------------            
         on key (F5)
        #--------------------
            if a_ctc91m22.itaciacod        is null or a_ctc91m22.itaciacod        = " " or
               a_ctc91m22.itaramcod        is null or a_ctc91m22.itaramcod        = " " or
               a_ctc91m22.itaaplcanmtvcod  is null or a_ctc91m22.itaaplcanmtvcod  = " " then
            
               error "Atualizacao cancelada. Todos os campos devem ser preenchidos."
               display by name a_ctc91m22.* attribute(normal)
               next field itaciacod
            end if    
                    
            call ctc91m22_atualiza_movimento() returning lr_retorno.*
            if lr_retorno.erro = 0 then
               error "Atualizado com sucesso..."
               #sleep 2
            else
               error lr_retorno.msg
               sleep 2
               let int_flag = false
               exit input
            end if
               

      end input
      
      if int_flag then
         let int_flag = false
         exit while
      end if

   end while

   let int_flag = false

   close window w_ctc91m22
   
#========================================================================
end function # Fim da funcao ctc91m22_input_array()
#========================================================================

#========================================================================
function ctc91m22_preenche_dados_tela(lr_param)
#========================================================================
   define lr_param record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
   end record


   whenever error continue
   open cctc91m22001 using lr_param.*
   fetch cctc91m22001 into  a_ctc91m22.itaasiarqvrsnum
                           ,a_ctc91m22.itaasiarqlnhnum
                           ,a_ctc91m22.itaaplnum
                           ,a_ctc91m22.itaaplitmnum
                           ,a_ctc91m22.itaciacod
                           ,a_ctc91m22.itaramcod
                           ,a_ctc91m22.itaaplcanmtvcod
   whenever error stop
   close cctc91m22001
   

#========================================================================
end function # Fim da funcao ctc91m22_preenche_dados_tela()
#========================================================================

#========================================================================
function ctc91m22_preenche_companhia()
#========================================================================
   let a_ctc91m22.itaciades = null
   whenever error continue
   open cctc91m22003 using a_ctc91m22.itaciacod
   fetch cctc91m22003 into a_ctc91m22.itaciades
   whenever error stop
   close cctc91m22003
   display by name a_ctc91m22.itaciades

#========================================================================
end function # Fim da funcao ctc91m22_preenche_companhia()
#========================================================================

#========================================================================
function ctc91m22_preenche_motivo_cancelamento()
#========================================================================
   let a_ctc91m22.itaaplcanmtvdes = null
   whenever error continue
   open cctc91m22009 using a_ctc91m22.itaaplcanmtvcod
   fetch cctc91m22009 into a_ctc91m22.itaaplcanmtvdes
   whenever error stop
   close cctc91m22009
   display by name a_ctc91m22.itaaplcanmtvdes

#========================================================================
end function # Fim da funcao ctc91m22_preenche_motivo_cancelamento()
#========================================================================

#========================================================================
function ctc91m22_preenche_ramo()
#========================================================================
   let a_ctc91m22.itaramdes = null
   whenever error continue
   open cctc91m22015 using a_ctc91m22.itaramcod
   fetch cctc91m22015 into a_ctc91m22.itaramdes
   whenever error stop
   close cctc91m22015
   display by name a_ctc91m22.itaramdes

#========================================================================
end function # Fim da funcao ctc91m22_preenche_ramo()
#========================================================================

#========================================================================
function ctc91m22_limpa_campos()
#========================================================================
   initialize a_ctc91m22.* to null
   display by name a_ctc91m22.*
#========================================================================
end function # Fim da funcao ctc91m22_limpa_campos()
#========================================================================

#========================================================================
function ctc91m22_atualiza_movimento()
#========================================================================
   define lr_retorno record
       erro  smallint
      ,msg   char(70)
   end record
   
   initialize lr_retorno.* to null

   whenever error continue 
   execute pctc91m22002 using a_ctc91m22.itaciacod      
                             ,a_ctc91m22.itaramcod      
                             ,a_ctc91m22.itaaplcanmtvcod
                             ,a_ctc91m22.itaasiarqvrsnum
                             ,a_ctc91m22.itaasiarqlnhnum
   whenever error stop 

   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do MOVIMENTO. Tabela: <datmdetitaasiarq>."
   else
      let lr_retorno.erro = 0
   end if
   
   return lr_retorno.*
#========================================================================
end function # Fim da funcao ctc91m22_atualiza_dados()
#========================================================================
