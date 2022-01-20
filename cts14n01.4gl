###############################################################################
# Nome do Modulo: CTS14N01                                           Ruiz     #
# Menu de Reguladores                                                Jun/2002 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/06/2002  PSI 130257    Ruiz        Permitir a manutencao nos reguladores #
#                                       de RE.                                #
#-----------------------------------------------------------------------------#

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts14n01()
#-----------------------------------------------------------

   open window w_cts14n01 at 04,02 with 20 rows, 78 columns

   display "---------------------------------------------------------------",
           "-----cts14n01--" at 03,01

   menu "REGULADORES_RE"

     #command key ("G") "reGuladores_Re"
     #                  "Manutencao nos Reguladores - Ramos Elementares"
     #   menu "Opcoes"

              #before menu
              #     if g_issk.funmat = 601566 then
              #        display "** g_issk.acsnivcod = ", g_issk.acsnivcod
              #        let g_issk.acsnivcod = 7
              #     end if

               command "Ativar" "Ativar Regulador"
                    if g_issk.acsnivcod >= 8 then
                       call osrea212()
                    else
                       error "Acesso nao permitido, procure seu coordenador"
                    end if

               command "Desativar" "Desativar Regulador"
                    if g_issk.acsnivcod >= 8 then
                       call osrea216()
                    else
                       error "Acesso nao permitido, procure seu coordenador"
                    end if

               command "Consultar" "Consultar Reguladores"
                       call osrec216()

              #command key (interrupt,"E") "Encerra" "Fim de Servico"
              #        exit menu
        #end menu

      command key (interrupt,"E") "Encerra"
                                  "Fim de Servico"
         exit menu
   end menu

   close window w_cts14n01

end function  ###  cts14n01
