#############################################################################
# Nome do Modulo: CTG15                                                Raji #
# Menu de Consulta                                                 Out/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                        #
#                                                                           #
# Data       Autor Fabrica         PSI    Alteracoes                        #
# ---------- --------------------- ------ ----------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual e #
#############################################################################

globals "/homedsa/projetos/geral/globals/glcte.4gl"
define  w_log    char(60)   

MAIN

   define w_data    date
   define w_ret     integer

   call fun_dba_abre_banco("CT24HS")

   initialize g_c24paxnum to null

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg15.log"


   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   select sitename into g_hostname from  dual
                        
   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last - 1,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "--------ctg15--" at 03,01

   menu "OPCOES"

   before menu
          hide option all
       # #if get_niv_mod(g_issk.prgsgl,"cte00m01") then
       # #   if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Cons_atdcor"
                show option "Cons_atdseg"
                show option "c_Operacoes"
       # #   end if
       # #end if

          show option "Encerra"

      command key ("C") "Cons_atdcor"
                        "Consulta generica de atendimento Corretor"
         call cte00m02()

      command key ("S") "Cons_atdseg"
                        "Consulta generica de atendimento Segurado"
         call ctn50c00()

      command key ("O") "c_Operacoes"
                        "Consulta generica de atendimento Central de Operacaoes"
         call ctn54c00()

      command key (interrupt,E) "Encerra" "Fim de servico"
         exit menu
   end menu

   close window win_cab
   close window win_menu

END MAIN

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