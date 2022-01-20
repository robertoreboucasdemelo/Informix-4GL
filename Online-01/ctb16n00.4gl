###########################################################################
# Nome do Modulo: CTB16N00                                       Gilberto #
#                                                                 Marcelo #
#                                                                 Wagner  #
# Menu de analise servicos - Porto Socorro                       Dez/1999 #
###########################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------------
 function ctb16n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb16n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb16n00--" at 03,01

   menu "ANALISE/BLOQUEIOS"

      before menu
             hide option all
             if get_niv_mod(g_issk.prgsgl,"ctb17m00") then   ## NIVEL 6
                if g_issk.acsnivcod >= g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "Consulta"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb16m00") then   ## NIVEL 6
                if g_issk.acsnivcod >= g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "bloqueio_Srv"
                end if
             end if
      #      if get_niv_mod(g_issk.prgsgl,"ctb23m00") then   ## NIVEL 6
      #         if g_issk.acsnivcod >= g_issk.acsnivcns or
      #            g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "bloqueio_Qra"
      #         end if
      #      end if
             show option "Encerra"

      command key ("C") "Consulta"
                        "Consulta historico dos servicos em analise"
        call ctb17m00()

      command key ("S") "bloqueio_Srv"
                        "Manutencao/Bloqueio dos servicos"
        call ctb16m00()

      command key ("Q") "bloqueio_Qra"
                        "Manutencao/Bloqueio motoristas-QRA" 
        call ctb23m00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb16n00

   let int_flag = false

end function   #---- ctb16n00
