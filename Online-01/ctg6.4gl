#############################################################################
# Nome do Modulo: CTG6                                             Marcelo  #
#                                                                  Gilberto #
# Menu de Carro Extra                                              Set/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Alterar a mensagem do menu SALDO de #
#                                       forma a contemplar todas clausulas  #
#                                       de Carro Extra (26 e 80).           #
#---------------------------------------------------------------------------#
# 30/10/2000  AS 22241     Ruiz         Chamar a funcao abre banco          #
#---------------------------------------------------------------------------#
# 15/05/2001  PSI 13168-7  Wagner       Mudanca na chamada do pagto C.Extra #
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual     #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
define  w_log    char(60)  

MAIN

   define x_opcao char(10)
   define x_data  date

   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dbs_ctg6.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------


   select sitename into g_hostname from  dual
                            
   defer interrupt
   set lock mode to wait

   options
      accept  key  F40 ,
      prompt  line last,
      comment line last,
      message line last

   whenever error continue

   open window WIN_CAB at 02,02 with 22 rows, 78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24 HS"  at  01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" at 01,20
   display x_data           at  01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "---------ctg6--" at 03,01

   menu "CARRO EXTRA"

      before menu
         hide option all
              show option "Cadastros"
              show option "Pagamentos"
              show option "Saldo"
              show option "Encerra"

      command key ("C") "Cadastros"  "Manutencao dos cadastros do Carro Extra"
         call ctc30n00()

      command key ("P") "Pagamentos" "Pagamento das locacoes"
         call ctb02n00()

      command key ("S") "Saldo"      "Consulta saldo de diarias de Carro Extra"
         call ctn16c00()

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
