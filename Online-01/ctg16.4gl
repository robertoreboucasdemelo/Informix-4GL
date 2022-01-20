#############################################################################
# Nome do Modulo: CTG16                                                Ruiz #
# Menu de Atendimento aos atendentes - Apoio                       Out/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual     #
###############################################################################

globals "/homedsa/projetos/geral/globals/glcte.4gl"

define  w_log     char(60)  

MAIN

   define ws        record
          data      date,
          ret       integer,
          sissgl    like ibpmsistprog.sissgl,
          param     char(100),
          comando   char(900),
          acsnivcod like issmnivnovo.acsnivcod
   end record

   call fun_dba_abre_banco ("CT24HS")

   initialize ws to null
   initialize g_c24paxnum to null


   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg16.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   select sitename into g_hostname from dual

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

   let ws.data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display ws.data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "--------ctg16--" at 03,01

   menu "OPCOES"

   before menu
          hide option all
         #if get_niv_mod(g_issk.prgsgl,"cte01m00") then
         #   if g_issk.acsnivcod >= g_issk.acsnivcns then
         #      show option "Atd_corretor"
         #   end if
         #end if
          show option "Apoio_cor24h"
          show option "Apoio_ct24h"
          show option "Libera_Atd"
          show option "Encerra"

      command key ("O") "Apoio_cOr24h"
                        "Atendimento aos atendentes-corretor"
         select acsnivcod 
            into ws.acsnivcod 
            from issmnivnovo
           where usrcod = g_issk.usrcod
             and empcod = g_issk.empcod
             and sissgl = "Atd_ct24h"
 
        initialize g_atdcor to null
        let ws.param[1,5]  =  "Apoio"
        let ws.sissgl =  "Atd_cor24"
        let ws.comando = ""
             ,g_issk.succod     , " "    #-> Sucursal
             ,g_issk.funmat     , " "    #-> Matricula do funcionario
         ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
             ,g_issk.dptsgl     , " "    #-> Sigla do departamento
             ,g_issk.dpttip     , " "    #-> Tipo do departamento
             ,g_issk.dptcod     , " "    #-> Codigo do departamento
             ,g_issk.sissgl     , " "    #-> Sigla sistema
             ,ws.acsnivcod      , " "    #-> Nivel de acesso
             ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
             ,g_issk.usrtip     , " "    #-> Tipo de usuario
             ,g_issk.empcod     , " "    #-> Codigo da empresa
             ,g_issk.iptcod     , " "
             ,g_issk.usrcod     , " "    #-> Codigo do usuario
             ,g_issk.maqsgl     , " "    #-> Sigla da maquina
             ,"'",ws.param      , "'"
        if g_hostname <> "u07" then
           call roda_prog("ctg12c",ws.comando,1) # e necessario estar cadastrado
                returning ws.ret                   # na tabela ibpkprog.
        else
           call roda_prog("ctg12",ws.comando,1) # e necessario estar cadastrado
                returning ws.ret                   # na tabela ibpkprog.
        end if
        if ws.ret = -1 then
           error "Sistema nao disponivel no momento"
           sleep 2
        end if

      command key ("T") "Apoio_cT24h"
                        "Atendimento aos atendentes-ct24h"
         select acsnivcod 
            into ws.acsnivcod 
            from issmnivnovo
           where usrcod = g_issk.usrcod
             and empcod = g_issk.empcod
             and sissgl = "Atd_ct24h"
 
         let ws.param[1,5]  =  "Apoio"
         let ws.sissgl  = "ctg2"         
         let ws.comando = ""
              ,g_issk.succod     , " "    #-> Sucursal
              ,g_issk.funmat     , " "    #-> Matricula do funcionario
          ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
              ,g_issk.dptsgl     , " "    #-> Sigla do departamento
              ,g_issk.dpttip     , " "    #-> Tipo do departamento
              ,g_issk.dptcod     , " "    #-> Codigo do departamento
              ,g_issk.sissgl     , " "    #-> Sigla sistema
              ,ws.acsnivcod      , " "    #-> Nivel de acesso
              ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
              ,g_issk.usrtip     , " "    #-> Tipo de usuario
              ,g_issk.empcod     , " "    #-> Codigo da empresa
              ,g_issk.iptcod     , " "
              ,g_issk.usrcod     , " "    #-> Codigo do usuario
              ,g_issk.maqsgl     , " "    #-> Sigla da maquina
              ,"'",ws.param      , "'"

         if g_issk.funmat = 601566 then
            display "* ws.comando - ", ws.comando
         end if
         call roda_prog("ctg2" ,ws.comando,1) # e necessario estar cadastrado
              returning ws.ret                   # na tabela ibpkprog.
         if ws.ret = -1 then
            error "Sistema nao disponivel no momento"
            sleep 2
         end if
 
      command key ("L") "Libera_Atd"            
                        "Libera Atendimentos-ct24h"
         call cta02m16()

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
