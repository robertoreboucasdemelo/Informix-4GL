###########################################################################
# Nome do Modulo: CTG4                                              Pedro #
#                                                                 Marcelo #
# Menu de Laudos de Servicos                                     Mai/1995 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 30/10/2000  AS 22241     Ruiz         Chamada da funcao abre banco.     #
#-------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual     #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
define  w_log   char(60)  

MAIN

   define x_opcao char(10)
   define x_data  date

   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg4.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------


   select sitename into g_hostname from  dual
                            
   defer interrupt
   set lock mode to wait

   options
      prompt line  last,
      comment line last,
      message line last

   whenever error continue

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24hs"  at 1,1
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display x_data       at 1,69

   open window WIN_MENU at 4,2 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "---------ctg4--" at 3,1

   menu "LAUDOS"

   before menu
          hide option all
          if get_niv_mod(g_issk.prgsgl,"ctg4") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Servicos", "Aviso_furto"
             end if
          end if

          show option "Encerra"

      command key ("S") "Servicos"
                        "Laudos de Sinistro Auto/R.E, DAF, Porto Socorro Auto/R.E, Replace e RPT"
        call cts20m00()

      command key ("A") "Aviso_furto"
                        "Laudos de aviso de furto/roubo total"
        call cts20m02()

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

function fantas()
    error "Funcao nao implementada"
end function
