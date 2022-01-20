#############################################################################
# Nome do Modulo: ctg9                                             Gilberto #
#                                                                   Marcelo #
# Menu de Vistoria Previa                                          Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 30/09/1998  Arnaldo      Gilberto     Liberar opcao MOTO para Rio Janeiro #
#---------------------------------------------------------------------------#
# 27/04/2000  PSI-9125-0   Akio         Adaptacao do modulo para chamadas   #
#                                       externas                            #
#---------------------------------------------------------------------------#
# 14/09/2000  AS           Ruiz         liberar opcao MOTO para todos os    #
#                                       departamentos.                      #
#---------------------------------------------------------------------------#
# 30/10/2000  AS 22214     Ruiz         Chamar funcao abre banco            #
#---------------------------------------------------------------------------#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 01/07/2003  Julianna, Meta PSI174688 Inclusao da chamada da funcao        #
#                                      cts06m10 no menu                     #
#---------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado de systables para dual     #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define   w_log    char(60)

MAIN

   define x_opcao char(10)
   define x_data  date
   define w_ret   integer
   define w_param    record
          pgmcaller  char(10),  # Pos 01 - 10
          var1       char(10),  # Pos 11 - 20
          var2       char(05),  # Pos 21 - 25
          var3       char(05)   # Pos 26 - 30
   end record

   call fun_dba_abre_banco("CT24HS")

   initialize g_c24paxnum to null

   ## Flexvision
   initialize g_monitor.dataini   to null ## dataini   date,
   initialize g_monitor.horaini   to null ## horaini   datetime hour to fraction,
   initialize g_monitor.horafnl   to null ## horafnl   datetime hour to fraction,
   initialize g_monitor.intervalo to null ## intervalo datetime hour to fraction

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg9.log"

   call startlog(w_log)
   #------------------------------------------
   # Abre banco (teste OU producao)
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

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display x_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()

   display "---------------------------------------------------------------",
           "---------ctg9--" at 03,01


   call get_param()

   let w_param.pgmcaller = g_issparam[01,10]
   let w_param.var1      = g_issparam[11,20]
   let w_param.var2      = g_issparam[21,25]
   let w_param.var3      = g_issparam[26,30]
   if  w_param.pgmcaller = "ctg12"  then
     #-------------------------------------------------------------------------
     # Chamada externa do atendimento ao corretor
     #-------------------------------------------------------------------------
       if  w_param.var3 = "I"  then
         #---------------------------------------------------------------------
         # Para inclusao, salta o menu 1 e abre o menu 2 com opcoes :
         #   Seleciona / Inclui / Copia / Encerra
         #---------------------------------------------------------------------
           if  get_niv_mod(g_issk.prgsgl,"cts06m00")  then
               if  g_issk.acsnivcod >= g_issk.acsnivcns then
                   call cts06m00( "I", "",
                                  w_param.var1,
                                  w_param.var2     )
               end if
           end if
       else
         #---------------------------------------------------------------------
         # Para alteracao, abre o menu 1 com opcoes :
         #   Marcacao / Localiza / Encerra
         # Para opcao Marcacao, abre o menu 2 com opcoes :
         #   Seleciona / Modifica / Cancela / Encerra
         #---------------------------------------------------------------------
           menu "VIST_PREVIA"
           before menu
              hide option all
              if  get_niv_mod(g_issk.prgsgl,"cts06m00") then
                  if  g_issk.acsnivcod >= g_issk.acsnivcns then
                      show option "Marcacao"
                  end if
              end if

              if  get_niv_mod(g_issk.prgsgl,"cts06m02") then
                  if  g_issk.acsnivcod >= g_issk.acsnivcns then
                      show option "Localiza"
                  end if
              end if
              show option "Encerra"

              command key ("M") "Marcacao"
                                "Marcacao de vistoria previa domiciliar"
                 call cts06m00( "A", "",
                                w_param.var1,
                                w_param.var2     )

              command key ("L") "Localiza"
                                "Localiza vistoria previa domiciliar"
                 call cts06m02( "A",
                                w_param.var1,
                                w_param.var2 )
              command key (interrupt,E) "Encerra"
                                        "Fim de Servico"
                 exit menu

           end menu
       end if
   else

      menu "VIST_PREVIA"

      before menu
          hide option all
          if g_issk.prgsgl = "ctg9T" then
             let g_issk.prgsgl = "ctg9"
          end if
          if get_niv_mod(g_issk.prgsgl,"cts06m00") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Marcacao"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts06m02") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Localiza"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts06m03") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Programadas"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts06m06") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Autorizadas"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts06m09") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
               #if g_issk.dptsgl  = "sisace"         or
               #   g_issk.dptsgl  = "vstria"         or
               #   g_issk.dptsgl  = "mcruze"         or
               #   g_issk.dptsgl  = "riojan"         or
               #   g_issk.dptsgl  = "rjaneu"         or
               #   g_issk.dptsgl  = "desenv"         then
                   show option "moTo"
               #end if
             end if
          end if

          #psi174688
          if get_niv_mod(g_issk.prgsgl,"cts06m10") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
               #if g_issk.dptsgl  = "sisace"         or
               #   g_issk.dptsgl  = "vstria"         or
               #   g_issk.dptsgl  = "mcruze"         or
               #   g_issk.dptsgl  = "riojan"         or
               #   g_issk.dptsgl  = "rjaneu"         or
               #   g_issk.dptsgl  = "desenv"         then
                   show option "moto_GPS"
               #end if
             end if
          end if
          # fim psi174688

          if get_niv_mod(g_issk.prgsgl,"avlta150") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "vp_Frust"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts06m05") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "imPrime"
             end if
          end if

          show option "Encerra"

      command key ("M") "Marcacao"
                        "Marcacao de vistoria previa domiciliar"
         call cts06m00("N","","","")

      command key ("L") "Localiza"
                        "Localiza vistoria previa domiciliar"
         call cts06m02("N","","")

      command key ("P") "Programadas"
                        "Quantidade de vistorias previas domiciliares marcadas"
         call cts06m03("","")

      command key ("A") "Autorizadas"
                        "Manutencao da quantidade de vistorias previas diarias"
         call cts06m06()

      command key ("T") "moTo"
                        "Vistoria previa a ser realizada por moto"
         initialize g_documento.*  to null
         call cts06m09()
         initialize g_documento.*  to null

       # psi174688
      command key ("G") "moto_GPS"
                        "Vistoria Previa a ser realiada por GPS"
            call cts06m10()
       # fim psi174688

      command key ("F") "vp_Frust"
                        "Digitacao vistoria previa frustada"
         initialize w_ret          to null

         call chama_prog("Vpr_ct24h", "avlta150", "")  returning w_ret

         if w_ret = -1  then
            error " Sistema nao disponivel no momento!"
         end if

      command key ("R") "impRime"
                        "Imprime laudos de vistoria previa domiciliar"
           call cts06m05("")

      command key (interrupt,E) "Encerra"
                                "Fim de Servico"
         exit menu
      end menu

   end if
   close window win_cab
   close window win_menu

   exit program(0)

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

end function  ###  p_reg_logo
