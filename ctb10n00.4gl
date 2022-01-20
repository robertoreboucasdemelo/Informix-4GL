################################################################################
# Nome do Modulo: CTB10N00                                       Gilberto      #
#                                                                 Marcelo      #
# Menu de cadastros - Porto Socorro                              Jan/1997      #
##########################################################################     #
# Alteracao: Fabrica, Mariana         OSF31682                   28/01/04      #
#  Objetivo: Identificacao e quantificacao das recusas de servicos             #
#            (modulo ctc70m00)                                                 #
#------------------------------------------------------------------------------#
#..............................................................................#
#                                                                              #
#                             * * * Alteracoes * * *                           #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- ------------------------------------ #
# 06/07/2004 Bruno Gama, Meta  PSI185035  Incluir no Menu CADASTROS a opcao    #
#                              OSF036870  'e-mail_reL'(ctb26m00).              #
#..............................................................................#
# 06/10/2004 Mariana,Meta      psi187801  Incluir chamada do modulo ctb27m00   #
#                                         no menu                              #
#------------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------------
 function ctb10n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctb10n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb10n00--" at 03,01

   menu "CADASTROS"

      before menu
             hide option all
             if get_niv_mod(g_issk.prgsgl,"ctb10n01") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "Tabelas"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc00m02") then
                if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 6
                   show option "Prestadores"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc06m00") then   ## NIVEL 8
                if g_issk.acsnivcod  = g_issk.acsnivcns or
                   g_issk.acsnivcod >= g_issk.acsnivatl then
                   show option "Servicos"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc02m00") then
                if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 8
                   show option "Guinchos"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc28m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Regioes"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb14m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "eVentos"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb15m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Fases"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb18m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Cronograma"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc80m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Descontos"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctb19m00") then   ## NIVEL 6
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "e-Mail_UF"
                end if
             end if
             if get_niv_mod(g_issk.prgsgl,"ctc70m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "mOt_recusa"
                end if
             end if
             # PSI 185035 - Inicio
             if get_niv_mod(g_issk.prgsgl,"ctb26m00") then   ## NIVEL 8
                if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "e-mail_reL"
                end if
             end if
             
             #if get_niv_mod(g_issk.prgsgl,"ctc41n00") then  
             #   if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Gps"                                     
             #   end if                                      
             #end if  
             
             #if get_niv_mod(g_issk.prgsgl,"ctc41n00") then  
             #   if g_issk.acsnivcod >= g_issk.acsnivcns then
                   show option "Bonificacao"                                     
             #   end if                                      
             #end if              
             
             
             
                                                    
             
             
             # PSI 185035 - Final

             show option "meNsagens"

             show option "Encerra"

      command key ("T") "Tabelas"
                        "Manutencao das tabelas de valores/custos"
        call ctb10n01()

      command key ("P") "Prestadores"
                        "Manutencao do cadastro de prestadores"
        call ctc00m02()

      command key ("S") "Servicos"
                        "Manutencao do cadastro de tipos de servico"
        call ctc06m00()

      command key ("G") "Guinchos"
                        "Manutencao do cadastro de tipos de guincho"
        call ctc02m00()

      command key ("R") "Regioes"
                        "Manutencao do cadastro de regioes/faixas de cep"
        call ctc28m00()

      command key ("V") "eVentos"
                        "Manutencao do cadastro de eventos de analise dos servicos"
        call ctb14m00()

      command key ("F") "Fases"
                        "Manutencao do cadastro de fases dos servicos analisados"
        call ctb15m00()

      command key ("C") "Cronograma"
                        "Manutencao do cronograma de entrega dos prestadores"
        call ctb18m00()

      command key ("D") "Descontos"
                        "Manutencao dos tipos de descontos"
        call ctc80m00()

      command key ("M") "e-Mail_UF"
                        "Manutencao do Endereco e-mail por Sigla Estado"
        call ctb19m00()

      command key ("O") "mOt_recusa"
                        "Manutencao do Cadastro de Motivos de Recusa"
        call ctc70m00()

      # PSI 185035 - Inicio
      command key ("L") "e-mail_reL"
                        "Manutencao de e-mail dos relatorios"
        call ctb26m00()
      # PSI 185035 - Final
      
      # PSI 229784 - Bonificação de Prestadores - BURINI
      command key('B') "Bonificacao"
              "Manutencao dos Cadastraos referentes ao GPS"
        call ctc20m00()
      ##################################################      

      command key('1') "Gps"
              "Manutencao dos Cadastraos referentes ao GPS"
        call ctc41n00()      
        
      command key ("N") "meNsagens" "Manutencao de mensagens para prestadores "
         call ctb27m00()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb10n00

   let int_flag = false

end function   #---- ctb10n00
