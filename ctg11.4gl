###########################################################################
# Nome do Modulo: ctg11                                          Marcelo  #
#                                                                Gilberto #
# Menu de Contingencia                                           Dez/1999 #
###########################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual e   #
#                                         incluida funcao fun_dba_abre_banco. #
###############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"
 define  w_log    char(60)  

 main

   define x_data  date
   define ws   record
      pergunta char (01),
      mstnum   like htlmmst.mstnum        ,
      errcod   smallint                   ,
      sqlcod   integer                    ,
      ustcod   like htlrust.ustcod        ,
      msgtxt   char (200)                 ,
      pgrnum   integer                     
   end record

   call fun_dba_abre_banco("CT24HS") 

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg11.log"
   
   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   
   select sitename into g_hostname from  dual

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 02,02 with 22 rows,78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24 HS"  at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 01,20
   display x_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "--------ctg11--" at 03,01

   menu "CONTINGENCIA"

      before menu
         hide option all

     #   if get_niv_mod(g_issk.prgsgl,"cts00m13")  then   ## NIVEL 2
     #      if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #         show option "Frota"
     #      end if
     #   end if
     #   if g_issk.dptsgl  =  "desenv" then
     #      show option "Beleza" 
     #      show option "Teste Pager"
     #   end if
         show option "conTingencia" 
         show option "Carga F10" 
         show option "Encerra"

     #command key ("F") "Frota"
     #                  "Posicao da frota"
 #   #   call cts00m13()

     #command key ("B") "Beleza"
     #                  "Beleza Beleza"
     #   call oadta950()

     #command key ("T") "Teste Pager"
     #                  "Testar envio de Pager"
     #   prompt "Digite o numero do pager " for ws.pgrnum
     #   select ustcod
     #         into ws.ustcod
     #         from htlrust
     #        where pgrnum = ws.pgrnum
     #   if sqlca.sqlcode <> 0 then
     #      error "** pager nao encontrado ", ws.pgrnum
     #   else
     #      let ws.msgtxt = "testando o envio, ligar p/ Ruiz r-5289. ",
     #                      current hour to minute," maq.=",g_issk.maqsgl
     #      call fptla025_usuario(ws.ustcod,
     #                            "TESTE DE ENVIO DE PAGER",
     #                            ws.msgtxt,
     #                            601566   ,
     #                            1        ,     
     #                            false,       ###  Nao controla transacoes
     #                            "O",         ###  Online
     #                            "M",         ###  Mailtrim
     #                            "",          ###  Data Transmissao
     #                            "",          ###  Hora Transmissao
     #                            g_issk.maqsgl)  ###  Maquina de aplicacao
     #                  returning ws.errcod,
     #                            ws.sqlcod,
     #                            ws.mstnum
     #      if ws.errcod >= 5  then
     #         display "Erro no envio Teletrim n.o ",ws.pgrnum,"/",ws.ustcod
     #         display "errcod = ", ws.errcod
     #         display "sqlcod = ", ws.sqlcod
     #         display "mstnum = ", ws.mstnum
     #      else   
     #         display "mensagem enviada ", ws.pgrnum,"/",ws.ustcod
     #         display "numero da mensagem ",ws.mstnum
     #      end if
     #      prompt "Digite qq tecla " for char ws.pergunta
     #   end if

      command key ("T") "conTingencia"
                        "Carga da Contingencia"
         call cts35m00() 
         
      command key ("F") "Carga F10"            
                        "Carga do Furto e Roubo"       
         call cts35m05(0)                          
     
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
