###########################################################################
# Nome do Modulo: CTB10N01                                       Gilberto #
#                                                                 Marcelo #
# Menu de cadastros de valores/custos                            Jan/1997 #
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------------
 function ctb10n01()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb10n01 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb10n01--" at 03,01

   menu "TABELAS"

      before menu
             hide option all
             if get_niv_mod(g_issk.prgsgl,"ctc11m00") then   ## NIVEL 8
                if g_issk.acsnivcod <= g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "custos_Frt"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb10m00") then
                if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 8
                   show option "Tarifas"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb10m01") then   ## NIVEL 8
                if g_issk.acsnivcod  = g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "custos_Prs"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb10m07") then
                if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 8
                   show option "Grupos"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb10m02") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Vigencias"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb10m01") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "custos_Re"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb73m00") then   #=> PSI.188603
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Indic_perf"
                end if
             end if
             #if get_niv_mod(g_issk.prgsgl,"ctb10m11") then  
             #   if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Alcada"
             #   end if
             #end if

             show option "Encerra"

      command key ("F") "custos_Frt"
                        "Manutencao do custo dos servicos da frota"
        call ctc11m00()

      command key ("T") "Tarifas"
                        "Manutencao do cadastro de tarifas"
        call ctb10m00()

      command key ("P") "custos_Prs"
                        "Manutencao do custo dos servicos dos prestadores"
        call ctb10m01()

      command key ("G") "Grupos"
                        "Manutencao do cadastro de grupos tarifarios"
        call ctb10m07()

      command key ("V") "Vigencias"
                        "Manutencao do cadastro das tabelas vigentes"
        call ctb10m02()

      command key ("R") "custos_Re"
                        "Manutencao do custo dos servicos de Residencia - RE"
        call ctb10m10()

      command key ("I") "Indic_perf" #=> PSI.188603
                        "Manutencao dos indicadores de performance"
        call ctb73m00()

      command key ("A") "Alcada" 
                        "Parametros da liberacao de servicos por Alcada"

        call ctb10m11()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb10n01

   let int_flag = false

 end function   #---- ctb10n01
