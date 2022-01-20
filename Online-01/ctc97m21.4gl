###########################################################################
# Nome do Modulo: ctc97m21                                                #
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


   define a_ctc97m21 record
       itaasiarqvrsnum     like datmresitaarqdet.vrscod                       
      ,itaasiarqlnhnum     like datmresitaarqdet.linnum                       
      ,itaaplnum           like datmresitaarqdet.aplnum                       
      ,itaaplitmnum        like datmresitaarqdet.aplitmnum                   
      ,itaciacod           like datmresitaarqdet.ciacod                       
      ,itaciades           like datkitacia.itaciades                          
      ,itaramcod           like datmresitaarqdet.ramcod                      
      ,itaramdes           like datkitaram.itaramdes                         
      ,itaprdcod           like datmresitaarqdet.prdcod                       
      ,itaprddes           like datkresitaprd.prddes                         
      ,itasgrplncod        like datmresitaarqdet.plncod
      ,itasgrplndes        like datkresitapln.plndes
      ,itaasisrvcod        like datmresitaarqdet.srvcod
      ,itaasisrvdes        like datkresitasrv.srvdes            
      ,itaclisgmcod        like datmresitaarqdet.sgmtipcod
      ,itaclisgmdes        like datkresitaclisgm.sgmdes
      ,itasgmcod           like datmresitaarqdet.sgmtipcod     
   end record


#========================================================================
function ctc97m21_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT vrscod ",
               "      ,linnum ",
               "      ,aplnum ",
               "      ,aplitmnum ",
               "      ,ciacod ",
               "      ,ramcod ",
               "      ,prdcod ",
               "      ,plncod ",
               "      ,srvcod ",                                             
               "      ,sgmtipcod ",               
               "FROM datmresitaarqdet ",
               "WHERE vrscod = ? ",
               "AND   linnum = ? "
   prepare pctc97m21001 from l_sql
   declare cctc97m21001 cursor for pctc97m21001


   let l_sql = "UPDATE datmresitaarqdet    ",
               "SET    ciacod       = ? ",
               "      ,ramcod       = ? ",
               "      ,prdcod       = ? ",
               "      ,plncod          = ? ",
               "      ,srvcod    = ? ",                              
               "      ,sgmtipcod    = ? ",               
               "WHERE vrscod = ?  ",
               "AND   linnum = ?  "
   prepare pctc97m21002 from l_sql

   let l_sql = "SELECT itaciades    ",
               "FROM datkitacia     ",
               "WHERE itaciacod = ? "
   prepare pctc97m21003 from l_sql
   declare cctc97m21003 cursor for pctc97m21003

   let l_sql = "SELECT prddes    ",
               "FROM datkresitaprd     ",
               "WHERE prdcod = ? "
   prepare pctc97m21004 from l_sql
   declare cctc97m21004 cursor for pctc97m21004

   let l_sql = " SELECT plndes      ",
               " FROM datkresitapln ",
               " WHERE plncod = ?   ",
               " and prdcod = ?     "
   prepare pctc97m21005 from l_sql
   declare cctc97m21005 cursor for pctc97m21005

   #let l_sql = "SELECT plncod    ",
   #            "FROM datkitasgrpln     ",
   #            "WHERE UPPER(itasgrplndes) = ? "
   #prepare pctc97m21005b from l_sql
   #declare cctc97m21005b cursor for pctc97m21005b

   let l_sql = "SELECT srvdes      ",
               "FROM datkresitasrv ",
               "WHERE itaasitipflg = ? "
   prepare pctc97m21006 from l_sql
   declare cctc97m21006 cursor for pctc97m21006

   #let l_sql = "SELECT srvdes ",
   #            "FROM datkitarsrcaosrv     ",
   #            "WHERE itarsrcaosrvcod = ? "
   #prepare pctc97m21007 from l_sql
   #declare cctc97m21007 cursor for pctc97m21007

   let l_sql = "SELECT itaempasides    ",
               "FROM datkitaempasi     ",
               "WHERE itaempasicod = ? "
   prepare pctc97m21008 from l_sql
   declare cctc97m21008 cursor for pctc97m21008

   let l_sql = "SELECT itaramdes    ",
               "FROM datkitaram     ",
               "WHERE itaramcod = ? "
   prepare pctc97m21015 from l_sql
   declare cctc97m21015 cursor for pctc97m21015      

   let l_sql = "SELECT sgmdes             ",
               "FROM datkresitaclisgm     ",
               "WHERE sgmasttipflg = ? "
   prepare pctc97m21019 from l_sql
   declare cctc97m21019 cursor for pctc97m21019

   let l_sql = " SELECT sgmcod, sgmdes    ",
               " FROM datkresitaclisgm     ",
               " WHERE sgmasttipflg = ? "
   prepare pctc97m21020 from l_sql
   declare cctc97m21020 cursor for pctc97m21020


#========================================================================
end function # Fim da funcao ctc97m21_prepare
#========================================================================

#========================================================================
function ctc97m21_input(lr_param)
#========================================================================

   define lr_param record
       itaasiarqvrsnum     like datmresitaarqdet.vrscod
      ,itaasiarqlnhnum     like datmresitaarqdet.linnum
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

   open window w_ctc97m21 at 6,2 with form 'ctc97m21'
      #attribute(form line first, message line first +19 ,comment line first +18, border)
      attribute(form line first, message line last,comment line last - 1, border)


   while true

      call ctc97m21_prepare()

      message "                     (F8)Atualizar Dados (F17)Volta"

      call ctc97m21_limpa_campos()
      call ctc97m21_preenche_dados_tela(lr_param.*)

      call ctc97m21_preenche_companhia()
      call ctc97m21_preenche_ramo()
      call ctc97m21_preenche_produto()
      call ctc97m21_preenche_plano()
      call ctc97m21_preenche_servico_assist()
      call ctc97m21_preenche_segmento_itacod()      

      input by name a_ctc97m21.* without defaults

        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = true
            exit input

        #--------------------
         before field itaciacod
        #--------------------
            display a_ctc97m21.itaciacod to
               s_ctc97m21.itaciacod attribute(reverse)

        #--------------------
         after field itaciacod
        #--------------------
        
            display a_ctc97m21.itaciacod to s_ctc97m21.itaciacod attribute(normal)       
        
            call ctc97m21_preenche_companhia()
            if a_ctc97m21.itaciacod = " " or
               a_ctc97m21.itaciades is null or
               a_ctc97m21.itaciades = " " then
               call cto00m10_popup(1) returning a_ctc97m21.itaciacod,
                                                a_ctc97m21.itaciades
               call ctc97m21_preenche_companhia()
            end if
            display a_ctc97m21.itaciacod to
               s_ctc97m21.itaciacod attribute(normal)

        #--------------------
         before field itaramcod
        #--------------------
            display a_ctc97m21.itaramcod to
               s_ctc97m21.itaramcod attribute(reverse)

        #--------------------
         after field itaramcod
        #--------------------
            
            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field itaciacod 
            end if
            
            display a_ctc97m21.itaramcod to s_ctc97m21.itaramcod attribute(normal)  
                     
            call ctc97m21_preenche_ramo()
            if a_ctc97m21.itaramcod = " " or
               a_ctc97m21.itaramdes is null or
               a_ctc97m21.itaramdes = " " then
               call cto00m10_popup(10) returning a_ctc97m21.itaramcod,
                                                 a_ctc97m21.itaramdes
               call ctc97m21_preenche_ramo()
            end if
            display a_ctc97m21.itaramcod to
               s_ctc97m21.itaramcod attribute(normal)

        #--------------------
         before field itaprdcod
        #--------------------
            display a_ctc97m21.itaprdcod to
               s_ctc97m21.itaprdcod attribute(reverse)

        #--------------------
         after field itaprdcod
        #--------------------
            
            display a_ctc97m21.itaprdcod to s_ctc97m21.itaprdcod attribute(normal)
            
            if fgl_lastkey() = fgl_keyval("up")   or    
               fgl_lastkey() = fgl_keyval("left") then  
               next field itaramcod                     
            end if                                      
                                  
            
            call ctc97m21_preenche_produto()
            if a_ctc97m21.itaprdcod = " " or
               a_ctc97m21.itaprddes is null or
               a_ctc97m21.itaprddes = " " then
               call cto00m10_popup(24) returning a_ctc97m21.itaprdcod,
                                                 a_ctc97m21.itaprddes
               call ctc97m21_preenche_produto()
            end if
            display a_ctc97m21.itaprdcod to
               s_ctc97m21.itaprdcod attribute(normal)

        #--------------------
         before field itasgrplncod
        #--------------------
            display a_ctc97m21.itasgrplncod to
               s_ctc97m21.itasgrplncod attribute(reverse)

        #--------------------
         after field itasgrplncod
        #--------------------
             
            display a_ctc97m21.itasgrplncod to s_ctc97m21.itasgrplncod attribute(normal)
            
            if fgl_lastkey() = fgl_keyval("up")   or     
               fgl_lastkey() = fgl_keyval("left") then   
               next field itaprdcod                      
            end if        
                                           
            call ctc97m21_preenche_plano()
            if a_ctc97m21.itasgrplncod = " " or
               a_ctc97m21.itasgrplndes is null or
               a_ctc97m21.itasgrplndes = " " then
               
               call cto00m10_popup_1(1,a_ctc97m21.itaprdcod) 
               returning a_ctc97m21.itasgrplncod,
                         a_ctc97m21.itasgrplndes
              
               call ctc97m21_preenche_plano()
            end if
            display a_ctc97m21.itasgrplncod to
               s_ctc97m21.itasgrplncod attribute(normal)       

        #--------------------
         before field itaasisrvcod
        #--------------------
            display a_ctc97m21.itaasisrvcod to
               s_ctc97m21.itaasisrvcod attribute(reverse)

        #--------------------
         after field itaasisrvcod
        #--------------------
            
            display a_ctc97m21.itaasisrvcod to s_ctc97m21.itaasisrvcod attribute(normal) 
            
            if fgl_lastkey() = fgl_keyval("up")   or    
               fgl_lastkey() = fgl_keyval("left") then  
               next field itasgrplncod                     
            end if  
    
            call ctc97m21_preenche_servico_assist()
            if a_ctc97m21.itaasisrvcod = " " or
               a_ctc97m21.itaasisrvdes is null or
               a_ctc97m21.itaasisrvdes = " " then
               	
               call cto00m10_popup(21) returning a_ctc97m21.itaasisrvcod,
                                                 a_ctc97m21.itaasisrvdes                            
               call ctc97m21_preenche_servico_assist()
            end if
            display a_ctc97m21.itaasisrvcod to
               s_ctc97m21.itaasisrvcod attribute(normal)

        #--------------------
         before field itaclisgmcod
        #--------------------

            display a_ctc97m21.itaclisgmcod to
               s_ctc97m21.itaclisgmcod attribute(reverse)

        #--------------------
         after field itaclisgmcod
        #-------------------- 
        
            display a_ctc97m21.itaclisgmcod to s_ctc97m21.itaclisgmcod attribute(normal)          
            
            
            if fgl_lastkey() = fgl_keyval("up")   or     
               fgl_lastkey() = fgl_keyval("left") then   
               next field itaasisrvcod                   
            end if    
            
            call ctc97m21_preenche_segmento_itacod()
            if a_ctc97m21.itaclisgmcod = " " or
               a_ctc97m21.itaclisgmdes is null or
               a_ctc97m21.itaclisgmdes = " " then
               call cto00m10_popup(28) returning a_ctc97m21.itaclisgmcod,
                                                 a_ctc97m21.itaclisgmdes
                
               call ctc97m21_preenche_segmento_itacod()
            end if
            display a_ctc97m21.itaclisgmcod to
                    s_ctc97m21.itaclisgmcod attribute(normal)
            next field itaciacod
        


        #--------------------
         on key (F8)
        #--------------------
            if a_ctc97m21.itaciacod        is null or a_ctc97m21.itaciacod        = " " or
               a_ctc97m21.itaramcod        is null or a_ctc97m21.itaramcod        = " " or
               a_ctc97m21.itaprdcod        is null or a_ctc97m21.itaprdcod        = " " or
               a_ctc97m21.itasgrplndes     is null or a_ctc97m21.itasgrplndes     = " " or
               a_ctc97m21.itaasisrvcod     is null or a_ctc97m21.itaasisrvcod     = " " or
               a_ctc97m21.itaclisgmcod     is null or a_ctc97m21.itaclisgmcod     = " " then


               error "Atualizacao cancelada. Todos os campos devem ser preenchidos."
               display by name a_ctc97m21.* attribute(normal)
               next field itaciacod
            end if

            call ctc97m21_atualiza_movimento()
               returning lr_retorno.*
            if lr_retorno.erro = 0 then
               error "Atualizado com sucesso..."
               sleep 2
               let int_flag = true
               exit input
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

   close window w_ctc97m21

#========================================================================
end function # Fim da funcao ctc97m21_input_array()
#========================================================================

#========================================================================
function ctc97m21_preenche_dados_tela(lr_param)
#========================================================================
   define lr_param record
       itaasiarqvrsnum     like datmresitaarqdet.vrscod
      ,itaasiarqlnhnum     like datmresitaarqdet.linnum
   end record


   whenever error continue
   open cctc97m21001 using lr_param.*
   fetch cctc97m21001 into  a_ctc97m21.itaasiarqvrsnum
                           ,a_ctc97m21.itaasiarqlnhnum
                           ,a_ctc97m21.itaaplnum
                           ,a_ctc97m21.itaaplitmnum
                           ,a_ctc97m21.itaciacod
                           ,a_ctc97m21.itaramcod
                           ,a_ctc97m21.itaprdcod
                           ,a_ctc97m21.itasgrplncod
                           ,a_ctc97m21.itaasisrvcod                           
                           ,a_ctc97m21.itaclisgmcod                           
   whenever error stop
   close cctc97m21001 
   
   

   call cty22g02_retira_acentos(a_ctc97m21.itasgrplndes)
   returning a_ctc97m21.itasgrplndes
   let a_ctc97m21.itasgrplndes = upshift(a_ctc97m21.itasgrplndes)   

#==============================================================
end function # Fim da funcao ctc97m21_preenche_dados_tela()
#==============================================================

#========================================================================
function ctc97m21_preenche_companhia()
#========================================================================
   
define lr_retorno record                                        
    itaciacod  like datkitacia.itaciacod                                           
end record                                                      
                                                                
   initialize lr_retorno.* to null                                 
                                                                                                                                      
   let lr_retorno.itaciacod = a_ctc97m21.itaciacod               
                   
     
   let a_ctc97m21.itaciades = null
   whenever error continue
   open cctc97m21003 using lr_retorno.itaciacod
   fetch cctc97m21003 into a_ctc97m21.itaciades
   whenever error stop
   close cctc97m21003
   display by name a_ctc97m21.itaciades

#========================================================================
end function # Fim da funcao ctc97m21_preenche_companhia()
#========================================================================


#========================================================================
function ctc97m21_preenche_produto()
#========================================================================
   
   define lr_retorno record                              
       prdcod  like datkresitaprd.prdcod              
   end record                                            
                                                         
   initialize lr_retorno.* to null                    
                                                      
   let lr_retorno.prdcod = a_ctc97m21.itaprdcod   
     
   let a_ctc97m21.itaprddes = null
   whenever error continue
   open cctc97m21004 using lr_retorno.prdcod
   fetch cctc97m21004 into a_ctc97m21.itaprddes
   whenever error stop
   close cctc97m21004
   display by name a_ctc97m21.itaprddes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_produto()
#========================================================================

#========================================================================
function ctc97m21_preenche_plano()
#========================================================================
   
   define lr_retorno record
       plncod  like datkresitapln.plncod,
       prdcod  like datkresitapln.prdcod
   end record
   
   initialize lr_retorno.* to null 
   
   let a_ctc97m21.itasgrplndes = null
   
   let lr_retorno.plncod =   a_ctc97m21.itasgrplncod    
   let lr_retorno.prdcod =   a_ctc97m21.itaprdcod       
   
   whenever error continue
   
   open cctc97m21005 using lr_retorno.plncod,
                           lr_retorno.prdcod
   fetch cctc97m21005 into a_ctc97m21.itasgrplndes
   whenever error stop
   
   
   close cctc97m21005
   display by name a_ctc97m21.itasgrplndes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_plano()
#========================================================================




#========================================================================
function ctc97m21_preenche_servico_assist()
#========================================================================
   
   
   
   let a_ctc97m21.itaasisrvdes = null
   whenever error continue
   open cctc97m21006 using a_ctc97m21.itaasisrvcod 
   fetch cctc97m21006 into a_ctc97m21.itaasisrvdes
   whenever error stop
   close cctc97m21006
   display by name a_ctc97m21.itaasisrvdes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_servico_assist()
#========================================================================

#========================================================================
function ctc97m21_preenche_segmento_itacod()
#======================================================================== 
   
   
   let a_ctc97m21.itaclisgmdes = null
   whenever error continue
   open cctc97m21019 using a_ctc97m21.itaclisgmcod   
   fetch cctc97m21019 into a_ctc97m21.itaclisgmdes
   whenever error stop
   close cctc97m21019
   
   display by name a_ctc97m21.itaclisgmcod     
   display by name a_ctc97m21.itaclisgmdes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_segmento_itacod()
#========================================================================

#========================================================================
function ctc97m21_preenche_segmento_porcod()
#========================================================================
   let a_ctc97m21.itaclisgmdes = null
   let a_ctc97m21.itasgmcod = null
   whenever error continue  
   open cctc97m21020 using a_ctc97m21.itaclisgmcod
   fetch cctc97m21020 into a_ctc97m21.itasgmcod, a_ctc97m21.itaclisgmdes
   whenever error stop
   close cctc97m21020
     
   display by name a_ctc97m21.itasgmcod
   display by name a_ctc97m21.itaclisgmdes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_segmento_porcod()
#========================================================================

#========================================================================
function ctc97m21_preenche_ramo()
#========================================================================
   
   define lr_retorno record                       
       itaramcod  like datkitaram.itaramcod          
   end record                                     
                                                  
   initialize lr_retorno.* to null                
                                                  
   let lr_retorno.itaramcod = a_ctc97m21.itaramcod   
   
   let a_ctc97m21.itaramdes = null
   whenever error continue
   open cctc97m21015 using lr_retorno.itaramcod
   fetch cctc97m21015 into a_ctc97m21.itaramdes
   whenever error stop
   close cctc97m21015
   display by name a_ctc97m21.itaramdes

#========================================================================
end function # Fim da funcao ctc97m21_preenche_ramo()
#========================================================================

#========================================================================
function ctc97m21_limpa_campos()
#========================================================================
   initialize a_ctc97m21.* to null
   display 'LIMPA CAMPOS'
   display by name a_ctc97m21.*
#========================================================================
end function # Fim da funcao ctc97m21_limpa_campos()
#========================================================================

#========================================================================
function ctc97m21_atualiza_movimento()
#========================================================================
   define lr_retorno record
       erro  smallint
      ,msg   char(70)
   end record

   initialize lr_retorno.* to null

   whenever error continue
   execute pctc97m21002 using a_ctc97m21.itaciacod
                             ,a_ctc97m21.itaramcod
                             ,a_ctc97m21.itaprdcod
                             ,a_ctc97m21.itasgrplncod
                             ,a_ctc97m21.itaasisrvcod                                                          
                             ,a_ctc97m21.itaclisgmcod                            
                             ,a_ctc97m21.itaasiarqvrsnum
                             ,a_ctc97m21.itaasiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do MOVIMENTO. Tabela: <datmresitaarqdet>."
   else
      let lr_retorno.erro = 0
   end if

   return lr_retorno.*
#========================================================================
end function # Fim da funcao ctc97m21_atualiza_dados()
#========================================================================
