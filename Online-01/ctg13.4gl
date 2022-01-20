#############################################################################
# Nome do Modulo: CTG13                                                Ruiz #
#                                                                      Akio #
# Menu de Consulta                                                 Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 23/08/2000   Ruiz        Raji         inclusao do cadastro de programas   #
#---------------------------------------------------------------------------#
# 30/10/2000   AS 22214    Ruiz         Chama funcao abre banco             #
#---------------------------------------------------------------------------#
#...........................................................................#
#                                                                           #
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem     Alteracao                           #
# ----------  -------------- ---------- ------------------------------------#
# 22/09/2003  Alexson, Meta  PSI 173282 Verificar se o nivel de acesso eh   #
#                            OSF 26.573 >= 8, se sim exibir no menu a opcao #
#                                       PROGRAMAS.                          #
#---------------------------------------------------------------------------#
# 11/08/2006  Priscila       PSI202290  Parametrizar menu Cad_cor24h        #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glcte.4gl"


define  w_log    char(60)

MAIN

   define w_data    date
   define w_ret     integer

   initialize g_c24paxnum to null

   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg13.log"


   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------


   select unique sitename into g_hostname from  dual
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
           "--------ctg13--" at 03,01

   menu "OPCOES"

   before menu
         #PSI 202290 - verificar nivel de acesso do modulo para o programa
         # e comparar com o nievl de acesso do usuario, caso seja maior ou
         # igual, permitir usuario de executar o item de menu

          hide option all

         #display "prgsgl ", g_issk.prgsgl
         #display "acsnivcod ", g_issk.acsnivcod

         if get_niv_mod(g_issk.prgsgl,"cte00m01") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Agrupamento"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"cte00m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "assunTo"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"cte00m03") then     #g_issk.acsnivcod >= 8
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Programas"
            end if
         end if

          show option "Encerra"
          show option "Cad_compl_corr"
          show option "CRM"

      command key ("A") "Agrupamento"
                        "Cadastro de Agrupamento"
         call cte00m01()

      command key ("T") "assunTo"
                        "Cadastro de Assuntos"
         call cte00m00()

      command key ("P") "Programas"
                        "Cadastra Programas "
         call cte00m03()

      command key ("C") "Cad_compl_corr"
                        "Cadastro Complementar de Corretores"
         call ctc84m00()
      command key ("R") "CRM"
                        "CRM_Informix "
         call cte05m00_menu()

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
