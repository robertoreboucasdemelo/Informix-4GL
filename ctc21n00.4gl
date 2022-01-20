###########################################################################
# Nome do Modulo: CTC21N00                                                #
#                                                                 Almeida #
# Menu de Cadastros - Procedimentos                              Mai/1998 #
###########################################################################
#                                                                         #
#                       * * * Alteracoes * * *                            #
#                                                                         #
# Data        Autor Fabrica  Origem      Alteracao                        #
# ----------  -------------- ---------  --------------------------------  #
# 24/10/2003  Meta, Bruno    PSI175269   Substituir condicoes do IF.      #
#                            OSF25780                                     #
# ........................................................................#
#                                                                         #
#                    * * * Alteracoes * * *                               #
#                                                                         #
# Data       Autor Fabrica   Origem        Alteracao                      #
# ---------- --------------  ----------    -------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao              #
#                                          "fun_dba_abre_banco" e troca   #
#                                           da "systables" por "dual"     #
#-------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#main
#
#  defer interrupt
#
#  set lock mode to wait
#  options
#     prompt line  last,
#     comment line last,
#     message line last
#
#  call get_param()
#
#  whenever error stop
#
#  call ctc21n00()
#end main

#---------------------------------------------------------------
 function ctc21n00(param)
#---------------------------------------------------------------

   define param    record
     escolha       dec(1,0)
   end record



   case param.escolha
      when 0
           open window w_ctc21n00 at 04,02 with 20 rows,78 columns

           display "---------------------------------------------------------------",
                   "-----ctc21n00--" at 03,01

           menu "PROCEDIMENTOS"

             before menu

		MESSAGE "" # By Robi
              command key ("C") "Campos"      "Manutencao de procedimentos"
                call ctc21n00(1)

              command key ("T") "Telas"        "Manutencao de campos dos procedimentos"
                call ctc21n00(2)

              command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
                exit menu
           end menu

           close window w_ctc21n00

           let int_flag = false
      when 1
           menu "PROCEDIMENTOS"

             before menu

		MESSAGE "" # By Robi
              command key ("C") "Cadastro"      "Manutencao de procedimentos"
                call ctc21m00()

              command key ("P") "camPos"        "Manutencao de campos dos procedimentos"
                call ctc21m01()

              command key ("T") "consulTa"     "Consulta procedimentos"
                call ctc21m02()

              command key ("S") "Simula"       "Simulacao de atendimento"
                call ctc21m03()

              command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
                exit menu
           end menu

          #close window w_ctc21n00

           let int_flag = false

      when 2

           ## PSI 175269 - Inicio

           #PSI 202290
           #if g_issk.acsnivcod < g_issk.acsnivatl then
           #    error "Acesso nao permitido"
           #else
              menu "PROCEDIMENTOS"

                 before menu

                 if g_issk.dptsgl <> "ct24hs" and
                    g_issk.dptsgl <> "dsvatd" and
                    g_issk.dptsgl <> "tlprod" and
                    g_issk.dptsgl <> "desenv" then
                    hide option "Telas"
                 end if

           ## PSI 175269 - Final

		MESSAGE "" # By Robi
                 command key ("C") "Cadastro"      "Manutencao de procedimentos"
                   call ctc25m00()

                 command key ("T") "Telas"        "Manutencao das telas com procedimentos"
                   call ctc25m01()

                 command key ("L") "consuLta"     "Consulta das telas com procedimentos"
                   call ctc25m02()

                 command key ("S") "Simula"       "Simulacao de atendimento"
                  error "Em desenvolvimento"
                  #call ctc25m03()

                 command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
                   exit menu
              end menu
          #end if
          #close window w_ctc21n00

           let int_flag = false
     end case

 end function  ###  ctc21n00
