###########################################################################
# Nome do Modulo: ctg14                                          Ruiz     #
#                                                                Akio     #
# Menu de Pendencias                                             Mai/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 30/10/2000  AS 22214     Ruiz         Chamar funcao abre banco          #
#-------------------------------------------------------------------------#
###########################################################################               
#                                                                         #
#                    * * * Alteracoes * * *                               #
#                                                                         #
# Data        Autor Fabrica  Origem     Alteracao                         #
# ----------  -------------- ---------  -------------------------------   #
# 28/01/2004  ivone meta     PSI172308  Acrescentar chamda a tela         #
#                            OSF31216   de pendencia de Estudo            #
# 20/07/2008  Amilton,Meta   PSI223689  Substituir a chamada da função    #
#                                       opacc154 para função interna      #    
#                                       cty02g02                          #                                        
#-------------------------------------------------------------------------#
 
 globals "/homedsa/projetos/geral/globals/glcte.4gl"
 define  w_log     char(60)  

 main

   define x_data  date


   call fun_dba_abre_banco("CT24HS")
   
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg14.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   
   
   #inicio psi172308  ivone
   whenever error continue 
   select sitename                                               
   into g_hostname                                                    
   from dual                                                        
   whenever error stop                                     
  if sqlca.sqlcode <> 0 then                                           
       display 'Erro SELECT Dual', sqlca.sqlcode, '/',sqlca.sqlerrd[2] 
       display 'ctg14 () '                                          
       exit program(1)
   end if    
   #fim psi172308  ivone                                        
   
   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last - 1,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 02,02 with 22 rows,78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24 HS"  at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 01,20
   display x_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "--------ctg14--" at 03,01
	
   menu "PENDENCIAS"

      before menu
#        hide option all

#        if get_niv_mod(g_issk.prgsgl,"cte02m00")  then   ## NIVEL 6
#           if g_issk.acsnivcod >= g_issk.acsnivatl  then
#              show option "Pendencias"
#           end if
#        end if
#        show option "Encerra"
#
      command key ("A") "Pendencias"
                        "Acompanhamento das Pendencias"
                                    
         #inicio psi172308  ivone
         if g_issk.sissgl = "Pnd_cor24h" then
            call cte02m00()
         end if
         if g_issk.sissgl = "Pnd_Estudo" then
            # Ini Psi 223689                             
              call cty02g02_oaaca154()
            # Fim Psi 223689  
            
            #call oaaca154()
         end if   
         #fim psi172308  ivone 
      command key (interrupt,E) "Encerra" "Fim de servico"
         exit menu

   end menu

   close window win_cab
   close window win_menu

 end main

#----------------------------------------------------------
 function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function

function fantas()
    error "Funcao nao implementada"
end function
