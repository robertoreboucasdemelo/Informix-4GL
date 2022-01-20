############################################################################  #
# Nome do Modulo: CTG12                                                Akio   #
#                                                                      Ruiz   #
# Menu de Atendimento                                              Abr/2000   #
############################################################################  #
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#---------------------------------------------------------------------------  #
# 10/08/2000  psi 97047    Arnaldo      incluir lista de ramais no menu       #
#---------------------------------------------------------------------------  #
# 30/10/2000  AS 22214     Ruiz         Chamar funcao abre banco              #
#---------------------------------------------------------------------------  #
# 29/11/2000  PSI 115452   Raji         incluir ura fax no menu               #
# 13/12/2002  PSI 156280   Fabiana      Incluir menu e-mail                   #
#---------------------------------------------------------------------------  #
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual e   #
#                                         incluida funcao fun_dba_abre_banco. #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a    #
#                                         global                              #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glcte.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

define   w_log     char(60) 

MAIN

   define ws        record
          data      date,
          ret       integer,
          param     char(100)
   end record

   call fun_dba_abre_banco("CT24HS")    

   initialize ws to null
   initialize g_c24paxnum to null

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg12.log"
   
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
   ---------------------------------- Ruiz
   let ws.param = arg_val(15)
   if ws.param[1,5] = "Apoio" then
      let g_atdcor.apoio = "S"
      call cte01m00()
      exit program(-1)
   end if
   ---------------------------------- Ruiz
   display "---------------------------------------------------------------",
           "--------ctg12--" at 03,01

   menu "OPCOES"

   before menu
          hide option all
         #if get_niv_mod(g_issk.prgsgl,"cte01m00") then
         #   if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Atd_corretor"
         #   end if
         #end if
          show option "e-Mail"
          show option "Ramais"
          show option "Ura_Fax"
          show option "Encerra"

      command key ("A") "Atd_corretor"
                        "Atendimento ao corretor"
         call cte01m00()

      command key ("M") "e-Mail"
                  "Consulta de E-mails enviados"
         call figrc072_setTratarIsolamento() -- > psi 223689
         call oaema028()         
      command key ("U") "Ura_Fax"
                        "Transmissoes de fax vi ura orcamento"
         call cte03m00()


      command key ("R") "Ramais"
                        "Lista Ramais da Porto Seguro"
         call chama_prog("Ramais","p_lrm","") returning ws.ret
         if ws.ret = -1  then
            error " Sistema nao disponivel no momento!"
         end if

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


	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function
