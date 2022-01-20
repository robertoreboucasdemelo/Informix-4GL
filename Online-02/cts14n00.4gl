#############################################################################
# Nome do Modulo: CTS14N00                                         Pedro    #
#                                                                  Marcelo  #
# Menu de de Sinistro                                              Jun/1995 #
#############################################################################
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 22/07/2004  Meta, Robson      PSI183431  Altera a chamada de cta00m00()   #
#                               OSF036439  para cta00mm05_controle()        #
#---------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl' # PSI183431 - Robson

define m_prep smallint  

function cts14n00_prepare()

  define l_sql char(300)
  
  let l_sql = "select c24aststt ", 
              "from datkassunto ",
              "where c24astcod in ('V10','V11')" 
  prepare pcts14n000001 from l_sql                          
  declare ccts14n000001 cursor for pcts14n000001

  let m_prep = true

end function 

#-----------------------------------------------------------
 function cts14n00()
#-----------------------------------------------------------
   define lr_aux record                               #PSI183431 - Robson - inicio
           apoio      char(01)
          ,empcodatd  like isskfunc.empcod
          ,funmatatd  like isskfunc.funmat
          ,usrtipatd    like issmnivnovo.usrtip
   end record
   
   define l_flag smallint
   define l_vistoria smallint
   define l_c24aststt like datkassunto.c24aststt

   define l_sqlcode, l_sqlerrd integer

   initialize lr_aux to null                          #PSI183431 - Robson - fim

   let l_sqlcode = 0
   let l_sqlerrd = 0

   open window w_cts14n00 at 04,02 with 20 rows, 78 columns

   display "---------------------------------------------------------------",
           "-----cts14n00--" at 03,01

   menu "SINISTRO"

    #-------------------------------------------------------------------------
    # Alterado por Gilberto em 25/02/97, conforme PSI 2484-8 (Neusa-Sinistro)
    #-------------------------------------------------------------------------
      before menu
         if g_issk.dptsgl    = "cmpnas"  and
            g_issk.acsnivcod = 3         then
            hide option "vistoria_Re"
            hide option "Aviso_auto"
         end if
         
         # Alterado na unificacao dos assuntos
         if m_prep = false or
            m_prep = " " then 
            call cts14n00_prepare()
         end if    
         
         let l_vistoria = true 
         whenever error continue 
         open ccts14n000001  
         foreach ccts14n000001 into l_c24aststt
           if l_c24aststt = "C" then 
              let l_vistoria = false 
           end if    
         end foreach
         
                  
         if l_vistoria = false then 
            hide option "Marcacao"
            hide option "vistoria_auto"
            hide option "Aviso_auto"
         end if    
            
         
         
    #-----------------------------------------------------------------------

      command key ("M") "Marcacao"
                        "Marcacao de Vistoria e Aviso"
         #call cta00m00()
         call cta00m05_controle(lr_aux.*,g_c24paxnum) # --- PSI 183431 - Robson
              returning l_flag

      command key ("V") "Vistoria_auto"
                        "Localiza Vistoria Sinistro - Automovel"
         call cts14m02("")

      command key ("R") "vistoria_Re"
                        "Localiza Vistoria Sinistro - Ramos Elementares"
         call cts21m05("")

      command key ("A") "Aviso_auto"
                        "Localiza Aviso de Sinistro Parcial - Automovel"
         call cts18m02("")

      command key (interrupt,"E") "Encerra"
                                  "Fim de Servico"
         exit menu
   end menu

   close window w_cts14n00

   return l_sqlcode, l_sqlerrd

end function  ###  cts14n00
