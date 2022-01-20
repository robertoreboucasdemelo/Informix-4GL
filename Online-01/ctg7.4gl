###########################################################################
# Nome do Modulo: CTG7                                           Gilberto #
#                                                                 Marcelo #
# Menu do Porto Socorro                                          Jan/1997 #
###########################################################################
###########################################################################
# NIVEIS DE ACESSO: 1 - Consultas                                         #
#                   3 - Digitacao                                         #
#                   5 - Efetua pagamentos                                 #
#                   6 - Alteracao de cadastro(prestadores)                #
#                   8 - Dono do sistema                                   #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 30/10/2000  AS 22214     Ruiz         Chamar funcao abre banco          #
#-------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual     #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2007 Luciano, Meta         211982 Inclusao da chamada funcao figrc012 #
#                                         Nova opcao menu: atd_carTao         #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/figrc012.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"
define  w_log    char(60)
define x_opcao char(10)
define x_data  date

MAIN

   call fun_dba_abre_banco("CT24HS")


   ## Flexvision
   initialize g_monitor.dataini   to null ## dataini   date,
   initialize g_monitor.horaini   to null ## horaini   datetime hour to fraction,
   initialize g_monitor.horafnl   to null ## horafnl   datetime hour to fraction,
   initialize g_monitor.intervalo to null ## intervalo datetime hour to fraction

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dbs_ctg7.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   if not figrc012_sitename("ctg7","","") then
      display "ERRO NO ACESSO SITENAME DA DUAL!"
      exit program(1)
   end if

   let g_hostname = g_outFigrc012.siteNameDB clipped

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let x_data = today
   display "PORTO SOCORRO"  at 1,1
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display x_data       at 1,69

   open window WIN_MENU at 4,2 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "---------ctg7--" at 3,1

   menu "PORTO SOCORRO"

   {before menu
          hide option all
               show option "Cadastros"
               show option "Pagamentos-PS"
               show option "Pagamentos-Bonif"
               show option "Analise"
               show option "Pagamentos-RE"
               show option "Analise-Web-PS"
               show option "Analise-Web-RE"
               show option "atd_carTao"
               show option "Encerra"}

      command key ("C") "Cadastros"
                        "Manutencao dos cadastros"
         call ctb10n00()

      command key ("P") "Pagamentos-PS"
                        "Manutencao dos pagamentos do P.Socorro"
         initialize g_documento.* to null
         call ctb11n00()

      command key ("A") "Analise"
                        "Manutencao da analise dos servicos"
         call ctb16n00()

      command key ("R") "Pagamentos-RE"
                        "Manutencao dos pagamentos de RE"
         call ctb04n00()

      command key ("S") "Analise-Web-PS"
                        "Analise dos servicos Internet PS"
         call ctb25m00("AUTO", "S")

      command key ("B") "Pagamentos-BF"
                        "Manutencao dos pagamentos das Bonificacoes de Prestadores"
         call ctc20m00()

      command key ("W") "Analise-Web-RE"
                        "Analise dos servicos Internet RE"
         call ctb25m00("RE", "S")

      command key ("T") "atd_carTao" "Atendimento aos clientes da Portoseg"
         initialize g_ppt.* to null
         initialize g_documento.* to null
         let g_documento.ciaempcod = 40
         call ctg7_portoseg()

      command key ("L") "ReLatorios" "Extracao de Relatorios"
         call ctb31n00()

      command key (interrupt,E) "Encerra"
                        "Fim de servico"
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

function fantas()
    error "Funcao nao implementada"
end function

function ctg7_portoseg()

   menu "PORTOSEG"
      command key ("A") "Acompanhamento"
                        "Acompanhamento dos servicos da Portoseg"
              call cts40m00_servicos(g_documento.ciaempcod)

      command key ("C") "Consulta" "Consulta dos servicos da Portoseg"
              call cts42m00()

      command key (interrupt,E) "Encerra" "Volta ao menu anterior"
         exit menu
   end menu

end function
