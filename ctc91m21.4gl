###########################################################################
# Nome do Modulo: ctc91m21                                                #
#                                                                         #
# Correcao do arquivo original de carga para reprocessar         Jan/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"


   define a_ctc91m21 record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
      ,itaaplnum           like datmdetitaasiarq.itaaplnum
      ,itaaplitmnum        like datmdetitaasiarq.itaaplitmnum
      ,itaciacod           like datmdetitaasiarq.itaciacod
      ,itaciades           like datkitacia.itaciades
      ,itaramcod           like datmdetitaasiarq.itaramcod
      ,itaramdes           like datkitaram.itaramdes
      ,itaprdcod           like datmdetitaasiarq.itaprdcod
      ,itaprddes           like datkitaprd.itaprddes
      ,itasgrplncod        like datkitasgrpln.itasgrplncod
      ,itasgrplndes        like datmdetitaasiarq.plndes
      ,itaasisrvcod        like datmdetitaasiarq.itaasisrvcod
      ,itaasisrvdes        like datkitaasisrv.itaasisrvdes
      ,rsrcaogrtcod        like datkitarsrcaogar.rsrcaogrtcod
      ,rsrcaogrtdes        like datkitarsrcaogar.itarsrcaogrtdes
      ,rsrcaogrtcoditau    like datmdetitaasiarq.rsrcaogrtcod
      ,itarsrcaosrvcod     like datmdetitaasiarq.itarsrcaosrvcod
      ,itarsrcaosrvdes     like datkitarsrcaosrv.itarsrcaosrvdes
      ,itaempasicod        like datmdetitaasiarq.itaempasicod
      ,itaempasides        like datkitaempasi.itaempasides
      ,itacliscocod        like datkitaclisco.itacliscocod
      ,itacliscodes        like datmdetitaasiarq.itacliscocod
      ,itaclisgmcod        like datkitaclisgm.itaclisgmcod
      ,itaclisgmdes        like datkitaclisgm.itaclisgmdes
      ,itasgmcod           like datmdetitaasiarq.itaclisgmcod
      ,ubbcod              like datmdetitaasiarq.ubbcod
      ,vcltipdesubb        like datkubbvcltip.vcltipdes
      ,itavclcrgtipcod     like datkitavclcrgtip.itavclcrgtipcod
      ,itavclcrgtipdes     like datmdetitaasiarq.itavclcrgtipcod
      ,vndcnlcod           like datkitavndcnl.vndcnlcod
      ,vndcnldes           like datmdetitaasiarq.vndcnldes
      ,vcltipcod           like datkitavcltip.vcltipcod
      ,vcltipdes           like datmdetitaasiarq.vcltipnom
      ,frtmdlcod           like datkitafrtmdl.frtmdlcod
      ,frtmdldes           like datmdetitaasiarq.frtmdlnom
   end record


#========================================================================
function ctc91m21_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT itaasiarqvrsnum ",
               "      ,itaasiarqlnhnum ",
               "      ,itaaplnum ",
               "      ,itaaplitmnum ",
               "      ,itaciacod ",
               "      ,itaramcod ",
               "      ,itaprdcod ",
               "      ,plndes ",
               "      ,itaasisrvcod ",
               "      ,rsrcaogrtcod ",
               "      ,itarsrcaosrvcod ",
               "      ,itaempasicod ",
               "      ,itavclcrgtipcod ",
               "      ,UPPER(itacliscocod) ",
               "      ,itaclisgmcod ",
               "      ,ubbcod ",
               "      ,vndcnldes ",
               "      ,vcltipnom ",
               "      ,frtmdlnom ",
               "FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   itaasiarqlnhnum = ? "
   prepare pctc91m21001 from l_sql
   declare cctc91m21001 cursor for pctc91m21001


   let l_sql = "UPDATE datmdetitaasiarq    ",
               "SET    itaciacod       = ? ",
               "      ,itaramcod       = ? ",
               "      ,itaprdcod       = ? ",
               "      ,plndes          = ? ",
               "      ,itaasisrvcod    = ? ",
               "      ,rsrcaogrtcod    = ? ",
               "      ,itarsrcaosrvcod = ? ",
               "      ,itaempasicod    = ? ",
               "      ,itavclcrgtipcod = ? ",
               "      ,itacliscocod    = ? ",
               "      ,itaclisgmcod    = ? ",
               "      ,ubbcod          = ? ",
               "      ,vndcnldes       = ? ",
               "      ,vcltipnom       = ? ",
               "      ,frtmdlnom       = ? ",
               "WHERE itaasiarqvrsnum = ?  ",
               "AND   itaasiarqlnhnum = ?  "
   prepare pctc91m21002 from l_sql

   let l_sql = "SELECT itaciades    ",
               "FROM datkitacia     ",
               "WHERE itaciacod = ? "
   prepare pctc91m21003 from l_sql
   declare cctc91m21003 cursor for pctc91m21003

   let l_sql = "SELECT itaprddes    ",
               "FROM datkitaprd     ",
               "WHERE itaprdcod = ? "
   prepare pctc91m21004 from l_sql
   declare cctc91m21004 cursor for pctc91m21004

   let l_sql = "SELECT itasgrplndes    ",
               "FROM datkitasgrpln     ",
               "WHERE itasgrplncod = ? "
   prepare pctc91m21005 from l_sql
   declare cctc91m21005 cursor for pctc91m21005

   let l_sql = "SELECT itasgrplncod    ",
               "FROM datkitasgrpln     ",
               "WHERE UPPER(itasgrplndes) = ? "
   prepare pctc91m21005b from l_sql
   declare cctc91m21005b cursor for pctc91m21005b

   let l_sql = "SELECT itaasisrvdes    ",
               "FROM datkitaasisrv     ",
               "WHERE itaasisrvcod = ? "
   prepare pctc91m21006 from l_sql
   declare cctc91m21006 cursor for pctc91m21006

   let l_sql = "SELECT itarsrcaosrvdes    ",
               "FROM datkitarsrcaosrv     ",
               "WHERE itarsrcaosrvcod = ? "
   prepare pctc91m21007 from l_sql
   declare cctc91m21007 cursor for pctc91m21007

   let l_sql = "SELECT itaempasides    ",
               "FROM datkitaempasi     ",
               "WHERE itaempasicod = ? "
   prepare pctc91m21008 from l_sql
   declare cctc91m21008 cursor for pctc91m21008

   let l_sql = "SELECT itavclcrgtipcod    ",
               "FROM datkitavclcrgtip     ",
               "WHERE UPPER(itavclcrgtipdes) = ? "
   prepare pctc91m21010 from l_sql
   declare cctc91m21010 cursor for pctc91m21010

   let l_sql = "SELECT itavclcrgtipdes    ",
               "FROM datkitavclcrgtip     ",
               "WHERE itavclcrgtipcod = ? "
   prepare pctc91m21011 from l_sql
   declare cctc91m21011 cursor for pctc91m21011

   let l_sql = "SELECT itacliscodes    ",
               "FROM datkitaclisco     ",
               "WHERE itacliscocod = ? "
   prepare pctc91m21013 from l_sql
   declare cctc91m21013 cursor for pctc91m21013

   let l_sql = "SELECT itacliscocod    ",
               "FROM datkitaclisco     ",
               "WHERE UPPER(itacliscodes) = ? "
   prepare pctc91m21014 from l_sql
   declare cctc91m21014 cursor for pctc91m21014

   let l_sql = "SELECT itaramdes    ",
               "FROM datkitaram     ",
               "WHERE itaramcod = ? "
   prepare pctc91m21015 from l_sql
   declare cctc91m21015 cursor for pctc91m21015

   let l_sql = "SELECT itarsrcaogrtcod, itarsrcaogrtdes    ",
               "FROM datkitarsrcaogar     ",
               "WHERE rsrcaogrtcod = ? "
   prepare pctc91m21016 from l_sql
   declare cctc91m21016 cursor for pctc91m21016

   let l_sql = "SELECT rsrcaogrtcod, itarsrcaogrtdes    ",
               "FROM datkitarsrcaogar     ",
               "WHERE itarsrcaogrtcod = ? "
   prepare pctc91m21017 from l_sql
   declare cctc91m21017 cursor for pctc91m21017

   let l_sql = "SELECT vcltipdes    ",
               "FROM datkubbvcltip  ",
               "WHERE ubbcod = ?    "
   prepare pctc91m21018 from l_sql
   declare cctc91m21018 cursor for pctc91m21018

   let l_sql = "SELECT itaclisgmcod, itaclisgmdes    ",
               "FROM datkitaclisgm     ",
               "WHERE itasgmcod = ? "
   prepare pctc91m21019 from l_sql
   declare cctc91m21019 cursor for pctc91m21019

   let l_sql = "SELECT itasgmcod, itaclisgmdes    ",
               "FROM datkitaclisgm     ",
               "WHERE itaclisgmcod = ? "
   prepare pctc91m21020 from l_sql
   declare cctc91m21020 cursor for pctc91m21020

   let l_sql = "SELECT frtmdlcod    ",
               "FROM datkitafrtmdl     ",
               "WHERE UPPER(frtmdldes) = ? "
   prepare pctc91m21021 from l_sql
   declare cctc91m21021 cursor for pctc91m21021

   let l_sql = "SELECT vndcnlcod    ",
               "FROM datkitavndcnl     ",
               "WHERE UPPER(vndcnldes) = ? "
   prepare pctc91m21022 from l_sql
   declare cctc91m21022 cursor for pctc91m21022

   let l_sql = "SELECT vcltipcod    ",
               "FROM datkitavcltip     ",
               "WHERE UPPER(vcltipdes) = ? "
   prepare pctc91m21023 from l_sql
   declare cctc91m21023 cursor for pctc91m21023

   let l_sql = "SELECT UPPER(frtmdldes) ",
               "FROM datkitafrtmdl  ",
               "WHERE frtmdlcod = ? "
   prepare pctc91m21024 from l_sql
   declare cctc91m21024 cursor for pctc91m21024

   let l_sql = "SELECT UPPER(vndcnldes) ",
               "FROM datkitavndcnl      ",
               "WHERE vndcnlcod = ? "
   prepare pctc91m21025 from l_sql
   declare cctc91m21025 cursor for pctc91m21025

   let l_sql = "SELECT UPPER(vcltipdes) ",
               "FROM datkitavcltip     ",
               "WHERE vcltipcod = ? "
   prepare pctc91m21026 from l_sql
   declare cctc91m21026 cursor for pctc91m21026

#========================================================================
end function # Fim da funcao ctc91m21_prepare
#========================================================================

#========================================================================
function ctc91m21_input(lr_param)
#========================================================================

   define lr_param record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
   end record

   define lr_retorno record
       erro  smallint
     ,msg   char(70)
   end record

   define l_index       smallint
   define arr_aux       smallint
   define scr_aux       smallint
   define l_prox_arr    smallint
   define l_erro        smallint

   initialize lr_retorno.* to null

   let int_flag = false

   open window w_ctc91m21 at 4,2 with form 'ctc91m21'
      attribute(form line first, message line first +19 ,comment line first +18, border)
      #attribute(form line first, message line last,comment line last - 1, border)


   while true

      call ctc91m21_prepare()

      message "        (F5)Atualizar Dados              (F17)Volta"

      call ctc91m21_limpa_campos()
      call ctc91m21_preenche_dados_tela(lr_param.*)

      call ctc91m21_preenche_companhia()
      call ctc91m21_preenche_ramo()
      call ctc91m21_preenche_produto()
      call ctc91m21_preenche_plano_cod()
      call ctc91m21_preenche_servico_assist()
      call ctc91m21_preenche_serv_carro_reserva()
      call ctc91m21_preenche_assist_empresa()
      call ctc91m21_preenche_tipo_carga_des()
      call ctc91m21_preenche_segmento_itacod()
      call ctc91m21_preenche_score_des()
      call ctc91m21_preenche_garantia_itau()
      call ctc91m21_preenche_ubb()
      call ctc91m21_preenche_frota_des()
      call ctc91m21_preenche_canal_des()
      call ctc91m21_preenche_veiculo_des()

      input by name a_ctc91m21.* without defaults

        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = true
            exit input

        #--------------------
         before field itaciacod
        #--------------------
            display a_ctc91m21.itaciacod to
               s_ctc91m21.itaciacod attribute(reverse)

        #--------------------
         after field itaciacod
        #--------------------
            call ctc91m21_preenche_companhia()
            if a_ctc91m21.itaciacod = " " or
               a_ctc91m21.itaciades is null or
               a_ctc91m21.itaciades = " " then
               call cto00m10_popup(1) returning a_ctc91m21.itaciacod,
                                                a_ctc91m21.itaciades
               call ctc91m21_preenche_companhia()
            end if
            display a_ctc91m21.itaciacod to
               s_ctc91m21.itaciacod attribute(normal)

        #--------------------
         before field itaramcod
        #--------------------
            display a_ctc91m21.itaramcod to
               s_ctc91m21.itaramcod attribute(reverse)

        #--------------------
         after field itaramcod
        #--------------------
            call ctc91m21_preenche_ramo()
            if a_ctc91m21.itaramcod = " " or
               a_ctc91m21.itaramdes is null or
               a_ctc91m21.itaramdes = " " then
               call cto00m10_popup(10) returning a_ctc91m21.itaramcod,
                                                 a_ctc91m21.itaramdes
               call ctc91m21_preenche_ramo()
            end if
            display a_ctc91m21.itaramcod to
               s_ctc91m21.itaramcod attribute(normal)

        #--------------------
         before field itaprdcod
        #--------------------
            display a_ctc91m21.itaprdcod to
               s_ctc91m21.itaprdcod attribute(reverse)

        #--------------------
         after field itaprdcod
        #--------------------
            call ctc91m21_preenche_produto()
            if a_ctc91m21.itaprdcod = " " or
               a_ctc91m21.itaprddes is null or
               a_ctc91m21.itaprddes = " " then
               call cto00m10_popup(3) returning a_ctc91m21.itaprdcod,
                                                 a_ctc91m21.itaprddes
               call ctc91m21_preenche_produto()
            end if
            display a_ctc91m21.itaprdcod to
               s_ctc91m21.itaprdcod attribute(normal)

        #--------------------
         before field itasgrplncod
        #--------------------
            display a_ctc91m21.itasgrplncod to
               s_ctc91m21.itasgrplncod attribute(reverse)

        #--------------------
         after field itasgrplncod
        #--------------------
            call ctc91m21_preenche_plano()
            if a_ctc91m21.itasgrplncod = " " or
               a_ctc91m21.itasgrplndes is null or
               a_ctc91m21.itasgrplndes = " " then
               call cto00m10_popup(5) returning a_ctc91m21.itasgrplncod,
                                                a_ctc91m21.itasgrplndes
               call ctc91m21_preenche_plano()
            end if
            display a_ctc91m21.itasgrplncod to
               s_ctc91m21.itasgrplncod attribute(normal)

        #--------------------
         before field itaempasicod
        #--------------------
            display a_ctc91m21.itaempasicod to
               s_ctc91m21.itaempasicod attribute(reverse)

        #--------------------
         after field itaempasicod
        #--------------------
            call ctc91m21_preenche_assist_empresa()
            if a_ctc91m21.itaempasicod = " " or
               a_ctc91m21.itaempasides is null or
               a_ctc91m21.itaempasides = " " then
               call cto00m10_popup(2) returning a_ctc91m21.itaempasicod,
                                                a_ctc91m21.itaempasides
               call ctc91m21_preenche_assist_empresa()
            end if
            display a_ctc91m21.itaempasicod to
               s_ctc91m21.itaempasicod attribute(normal)

        #--------------------
         before field itaasisrvcod
        #--------------------
            display a_ctc91m21.itaasisrvcod to
               s_ctc91m21.itaasisrvcod attribute(reverse)

        #--------------------
         after field itaasisrvcod
        #--------------------
            call ctc91m21_preenche_servico_assist()
            if a_ctc91m21.itaasisrvcod = " " or
               a_ctc91m21.itaasisrvdes is null or
               a_ctc91m21.itaasisrvdes = " " then
               call cto00m10_popup(6) returning a_ctc91m21.itaasisrvcod,
                                                a_ctc91m21.itaasisrvdes
               call ctc91m21_preenche_servico_assist()
            end if
            display a_ctc91m21.itaasisrvcod to
               s_ctc91m21.itaasisrvcod attribute(normal)

        #--------------------
         before field rsrcaogrtcod
        #--------------------
            display a_ctc91m21.rsrcaogrtcod to
               s_ctc91m21.rsrcaogrtcod attribute(reverse)

        #--------------------
         after field rsrcaogrtcod
        #--------------------
            call ctc91m21_preenche_garantia_cod()
            if a_ctc91m21.rsrcaogrtcod = " " or
               a_ctc91m21.rsrcaogrtdes is null or
               a_ctc91m21.rsrcaogrtdes = " " then
               call cto00m10_popup(11) returning a_ctc91m21.rsrcaogrtcod,
                                                a_ctc91m21.rsrcaogrtdes
               call ctc91m21_preenche_garantia_cod()
            end if
            display a_ctc91m21.rsrcaogrtcod to
               s_ctc91m21.rsrcaogrtcod attribute(normal)

        #--------------------
         before field itavclcrgtipcod
        #--------------------
            display a_ctc91m21.itavclcrgtipcod to
               s_ctc91m21.itavclcrgtipcod attribute(reverse)

        #--------------------
         after field itavclcrgtipcod
        #--------------------
            call ctc91m21_preenche_tipo_carga_cod()
            if a_ctc91m21.itavclcrgtipcod = " " or
               a_ctc91m21.itavclcrgtipdes is null or
               a_ctc91m21.itavclcrgtipdes = " " then
               call cto00m10_popup(9) returning a_ctc91m21.itavclcrgtipcod,
                                                a_ctc91m21.itavclcrgtipdes
               call ctc91m21_preenche_tipo_carga_cod()
            end if
            display a_ctc91m21.itavclcrgtipcod to
               s_ctc91m21.itavclcrgtipcod attribute(normal)

        #--------------------
         before field itacliscocod
        #--------------------
            display a_ctc91m21.itacliscocod to
               s_ctc91m21.itacliscocod attribute(reverse)

        #--------------------
         after field itacliscocod
        #--------------------
            call ctc91m21_preenche_score_cod()
            if a_ctc91m21.itacliscocod = " " or
               a_ctc91m21.itacliscodes is null or
               a_ctc91m21.itacliscodes = " " then
               call cto00m10_popup(8) returning a_ctc91m21.itacliscocod,
                                                a_ctc91m21.itacliscodes
               call ctc91m21_preenche_score_cod()
            end if
            display a_ctc91m21.itacliscocod to
               s_ctc91m21.itacliscocod attribute(normal)

        #--------------------
         before field itarsrcaosrvcod
        #--------------------
            display a_ctc91m21.itarsrcaosrvcod to
               s_ctc91m21.itarsrcaosrvcod attribute(reverse)

        #--------------------
         after field itarsrcaosrvcod
        #--------------------
            call ctc91m21_preenche_serv_carro_reserva()
            if a_ctc91m21.itarsrcaosrvcod = " " or
               a_ctc91m21.itarsrcaosrvdes is null or
               a_ctc91m21.itarsrcaosrvdes = " " then
               call cto00m10_popup(4) returning a_ctc91m21.itarsrcaosrvcod,
                                                a_ctc91m21.itarsrcaosrvdes
               call ctc91m21_preenche_serv_carro_reserva()
            end if
            display a_ctc91m21.itarsrcaosrvcod to
               s_ctc91m21.itarsrcaosrvcod attribute(normal)

        #--------------------
         before field itaclisgmcod
        #--------------------

            display a_ctc91m21.itaclisgmcod to
               s_ctc91m21.itaclisgmcod attribute(reverse)

        #--------------------
         after field itaclisgmcod
        #--------------------
            call ctc91m21_preenche_segmento_porcod()
            if a_ctc91m21.itaclisgmcod = " " or
               a_ctc91m21.itaclisgmdes is null or
               a_ctc91m21.itaclisgmdes = " " then
               call cto00m10_popup(7) returning a_ctc91m21.itaclisgmcod,
                                                a_ctc91m21.itaclisgmdes
               call ctc91m21_preenche_segmento_porcod()
            end if
            display a_ctc91m21.itaclisgmcod to
               s_ctc91m21.itaclisgmcod attribute(normal)

        #--------------------
         before field ubbcod
        #--------------------
            display a_ctc91m21.ubbcod to
               s_ctc91m21.ubbcod attribute(reverse)

        #--------------------
         after field ubbcod
        #--------------------
            call ctc91m21_preenche_ubb()
            if a_ctc91m21.ubbcod = " " or
               a_ctc91m21.vcltipdesubb is null or
               a_ctc91m21.vcltipdesubb = " " then
               call cto00m10_popup(15) returning a_ctc91m21.ubbcod,
                                                a_ctc91m21.vcltipdesubb
               call ctc91m21_preenche_ubb()
            end if
            display a_ctc91m21.ubbcod to
               s_ctc91m21.ubbcod attribute(normal)


        #--------------------
         before field vndcnlcod
        #--------------------
            display a_ctc91m21.vndcnlcod to
               s_ctc91m21.vndcnlcod attribute(reverse)

        #--------------------
         after field vndcnlcod
        #--------------------
            call ctc91m21_preenche_canal_cod()
            if a_ctc91m21.vndcnlcod = " " or
               a_ctc91m21.vndcnldes is null or
               a_ctc91m21.vndcnldes = " " then
               call cto00m10_popup(19) returning a_ctc91m21.vndcnlcod,
                                                 a_ctc91m21.vndcnldes
               call ctc91m21_preenche_canal_cod()
            end if
            display a_ctc91m21.vndcnlcod to
               s_ctc91m21.vndcnlcod attribute(normal)

        #--------------------
         before field vcltipcod
        #--------------------
            display a_ctc91m21.vcltipcod to
               s_ctc91m21.vcltipcod attribute(reverse)

        #--------------------
         after field vcltipcod
        #--------------------
            call ctc91m21_preenche_veiculo_cod()
            if a_ctc91m21.vcltipcod = " " or
               a_ctc91m21.vcltipdes is null or
               a_ctc91m21.vcltipdes = " " then
               call cto00m10_popup(20) returning a_ctc91m21.vcltipcod,
                                                 a_ctc91m21.vcltipdes
               call ctc91m21_preenche_veiculo_cod()
            end if
            display a_ctc91m21.vcltipcod to
               s_ctc91m21.vcltipcod attribute(normal)


        #--------------------
         before field frtmdlcod
        #--------------------
            display a_ctc91m21.frtmdlcod to
               s_ctc91m21.frtmdlcod attribute(reverse)

        #--------------------
         after field frtmdlcod
        #--------------------
            call ctc91m21_preenche_frota_cod()
            if a_ctc91m21.frtmdlcod = " " or
               a_ctc91m21.frtmdldes is null or
               a_ctc91m21.frtmdldes = " " then
               call cto00m10_popup(18) returning a_ctc91m21.frtmdlcod,
                                                 a_ctc91m21.frtmdldes
               call ctc91m21_preenche_frota_cod()
            end if
            display a_ctc91m21.frtmdlcod to
               s_ctc91m21.frtmdlcod attribute(normal)
            next field itaciacod




        #--------------------
         on key (F5)
        #--------------------
            if a_ctc91m21.itaciacod        is null or a_ctc91m21.itaciacod        = " " or
               a_ctc91m21.itaramcod        is null or a_ctc91m21.itaramcod        = " " or
               a_ctc91m21.itaprdcod        is null or a_ctc91m21.itaprdcod        = " " or
               a_ctc91m21.itasgrplndes     is null or a_ctc91m21.itasgrplndes     = " " or
               a_ctc91m21.itaasisrvcod     is null or a_ctc91m21.itaasisrvcod     = " " or
               a_ctc91m21.rsrcaogrtcod     is null or a_ctc91m21.rsrcaogrtcod     = " " or
               a_ctc91m21.itarsrcaosrvcod  is null or a_ctc91m21.itarsrcaosrvcod  = " " or
               a_ctc91m21.itaempasicod     is null or a_ctc91m21.itaempasicod     = " " or
               a_ctc91m21.itavclcrgtipdes  is null or a_ctc91m21.itavclcrgtipdes  = " " or
               a_ctc91m21.itacliscodes     is null or a_ctc91m21.itacliscodes     = " " or
               a_ctc91m21.itaclisgmcod     is null or a_ctc91m21.itaclisgmcod     = " " or
               a_ctc91m21.ubbcod           is null or a_ctc91m21.ubbcod           = " " or
               a_ctc91m21.vndcnldes        is null or a_ctc91m21.vndcnldes        = " " or
               a_ctc91m21.vcltipdes        is null or a_ctc91m21.vcltipdes        = " " or
               a_ctc91m21.frtmdldes        is null or a_ctc91m21.frtmdldes        = " " then

               #display "a_ctc91m21.itaciacod      : ", a_ctc91m21.itaciacod
               #display "a_ctc91m21.itaramcod      : ", a_ctc91m21.itaramcod
               #display "a_ctc91m21.itaprdcod      : ", a_ctc91m21.itaprdcod
               #display "a_ctc91m21.itasgrplncod   : ", a_ctc91m21.itasgrplncod
               #display "a_ctc91m21.itaasisrvcod   : ", a_ctc91m21.itaasisrvcod
               #display "a_ctc91m21.rsrcaogrtcod   : ", a_ctc91m21.rsrcaogrtcod
               #display "a_ctc91m21.itarsrcaosrvcod: ", a_ctc91m21.itarsrcaosrvcod
               #display "a_ctc91m21.itaempasicod   : ", a_ctc91m21.itaempasicod
               #display "a_ctc91m21.itavclcrgtipdes: ", a_ctc91m21.itavclcrgtipdes
               #display "a_ctc91m21.itacliscodes   : ", a_ctc91m21.itacliscodes
               #display "a_ctc91m21.itaclisgmcod   : ", a_ctc91m21.itaclisgmcod
               #display "a_ctc91m21.ubbcod         : ", a_ctc91m21.ubbcod
               #display "a_ctc91m21.vndcnldes      : ", a_ctc91m21.vndcnldes
               #display "a_ctc91m21.vcltipdes      : ", a_ctc91m21.vcltipdes
               #display "a_ctc91m21.frtmdldes      : ", a_ctc91m21.frtmdldes

               error "Atualizacao cancelada. Todos os campos devem ser preenchidos."
               display by name a_ctc91m21.* attribute(normal)
               next field itaciacod
            end if

            call ctc91m21_atualiza_movimento() returning lr_retorno.*
            if lr_retorno.erro = 0 then
               error "Atualizado com sucesso..."
               #sleep 2
            else
               error lr_retorno.msg
               sleep 2
               let int_flag = false
               exit input
            end if


      end input

      if int_flag then
         let int_flag = false
         exit while
      end if

   end while

   let int_flag = false

   close window w_ctc91m21

#========================================================================
end function # Fim da funcao ctc91m21_input_array()
#========================================================================

#========================================================================
function ctc91m21_preenche_dados_tela(lr_param)
#========================================================================
   define lr_param record
       itaasiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,itaasiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
   end record


   whenever error continue
   open cctc91m21001 using lr_param.*
   fetch cctc91m21001 into  a_ctc91m21.itaasiarqvrsnum
                           ,a_ctc91m21.itaasiarqlnhnum
                           ,a_ctc91m21.itaaplnum
                           ,a_ctc91m21.itaaplitmnum
                           ,a_ctc91m21.itaciacod
                           ,a_ctc91m21.itaramcod
                           ,a_ctc91m21.itaprdcod
                           ,a_ctc91m21.itasgrplndes
                           ,a_ctc91m21.itaasisrvcod
                           ,a_ctc91m21.rsrcaogrtcoditau
                           ,a_ctc91m21.itarsrcaosrvcod
                           ,a_ctc91m21.itaempasicod
                           ,a_ctc91m21.itavclcrgtipdes
                           ,a_ctc91m21.itacliscodes
                           ,a_ctc91m21.itasgmcod
                           ,a_ctc91m21.ubbcod
                           ,a_ctc91m21.vndcnldes
                           ,a_ctc91m21.vcltipdes
                           ,a_ctc91m21.frtmdldes
   whenever error stop
   close cctc91m21001

   if a_ctc91m21.ubbcod is null or
      a_ctc91m21.ubbcod = " " then
      let a_ctc91m21.ubbcod = 0
   end if

   call cty22g02_retira_acentos(a_ctc91m21.itasgrplndes)
   returning a_ctc91m21.itasgrplndes
   let a_ctc91m21.itasgrplndes = upshift(a_ctc91m21.itasgrplndes)

   call cty22g02_retira_acentos(a_ctc91m21.itavclcrgtipdes)
   returning a_ctc91m21.itavclcrgtipdes
   let a_ctc91m21.itavclcrgtipdes = upshift(a_ctc91m21.itavclcrgtipdes)

   call cty22g02_retira_acentos(a_ctc91m21.itacliscodes)
   returning a_ctc91m21.itacliscodes
   let a_ctc91m21.itacliscodes = upshift(a_ctc91m21.itacliscodes)

   call cty22g02_retira_acentos(a_ctc91m21.vndcnldes)
   returning a_ctc91m21.vndcnldes
   let a_ctc91m21.vndcnldes = upshift(a_ctc91m21.vndcnldes)

   call cty22g02_retira_acentos(a_ctc91m21.vcltipdes)
   returning a_ctc91m21.vcltipdes
   let a_ctc91m21.vcltipdes = upshift(a_ctc91m21.vcltipdes)

   call cty22g02_retira_acentos(a_ctc91m21.frtmdldes)
   returning a_ctc91m21.frtmdldes
   let a_ctc91m21.frtmdldes = upshift(a_ctc91m21.frtmdldes)

#==============================================================
end function # Fim da funcao ctc91m21_preenche_dados_tela()
#==============================================================

#========================================================================
function ctc91m21_preenche_companhia()
#========================================================================
   let a_ctc91m21.itaciades = null
   whenever error continue
   open cctc91m21003 using a_ctc91m21.itaciacod
   fetch cctc91m21003 into a_ctc91m21.itaciades
   whenever error stop
   close cctc91m21003
   display by name a_ctc91m21.itaciades

#========================================================================
end function # Fim da funcao ctc91m21_preenche_companhia()
#========================================================================


#========================================================================
function ctc91m21_preenche_produto()
#========================================================================
   let a_ctc91m21.itaprddes = null
   whenever error continue
   open cctc91m21004 using a_ctc91m21.itaprdcod
   fetch cctc91m21004 into a_ctc91m21.itaprddes
   whenever error stop
   close cctc91m21004
   display by name a_ctc91m21.itaprddes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_produto()
#========================================================================

#========================================================================
function ctc91m21_preenche_plano()
#========================================================================
   let a_ctc91m21.itasgrplndes = null
   whenever error continue
   open cctc91m21005 using a_ctc91m21.itasgrplncod
   fetch cctc91m21005 into a_ctc91m21.itasgrplndes
   whenever error stop
   close cctc91m21005
   display by name a_ctc91m21.itasgrplndes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_plano()
#========================================================================

#========================================================================
function ctc91m21_preenche_plano_cod()
#========================================================================
   let a_ctc91m21.itasgrplncod = null
   whenever error continue
   open cctc91m21005b using a_ctc91m21.itasgrplndes
   fetch cctc91m21005b into a_ctc91m21.itasgrplncod
   whenever error stop
   close cctc91m21005b
   display by name a_ctc91m21.itasgrplncod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_plano_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_frota_des()
#========================================================================
   let a_ctc91m21.frtmdlcod = null
   whenever error continue
   open cctc91m21021 using a_ctc91m21.frtmdldes
   fetch cctc91m21021 into a_ctc91m21.frtmdlcod
   whenever error stop
   close cctc91m21021
   display by name a_ctc91m21.frtmdlcod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_frota_des()
#========================================================================

#========================================================================
function ctc91m21_preenche_canal_des()
#========================================================================
   let a_ctc91m21.vndcnlcod = null
   whenever error continue
   open cctc91m21022 using a_ctc91m21.vndcnldes
   fetch cctc91m21022 into a_ctc91m21.vndcnlcod
   whenever error stop
   close cctc91m21022
   display by name a_ctc91m21.vndcnlcod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_canal_des()
#========================================================================

#========================================================================
function ctc91m21_preenche_veiculo_des()
#========================================================================
   let a_ctc91m21.vcltipcod = null
   whenever error continue
   open cctc91m21023 using a_ctc91m21.vcltipdes
   fetch cctc91m21023 into a_ctc91m21.vcltipcod
   whenever error stop
   close cctc91m21023
   display by name a_ctc91m21.vcltipcod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_veiculo_des()
#========================================================================

#========================================================================
function ctc91m21_preenche_frota_cod()
#========================================================================
   let a_ctc91m21.frtmdldes = null
   whenever error continue
   open cctc91m21024 using a_ctc91m21.frtmdlcod
   fetch cctc91m21024 into a_ctc91m21.frtmdldes
   whenever error stop
   close cctc91m21024
   display by name a_ctc91m21.frtmdldes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_frota_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_canal_cod()
#========================================================================
   let a_ctc91m21.vndcnldes = null
   whenever error continue
   open cctc91m21025 using a_ctc91m21.vndcnlcod
   fetch cctc91m21025 into a_ctc91m21.vndcnldes
   whenever error stop
   close cctc91m21025
   display by name a_ctc91m21.vndcnldes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_canal_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_veiculo_cod()
#========================================================================
   let a_ctc91m21.vcltipdes = null
   whenever error continue
   open cctc91m21026 using a_ctc91m21.vcltipcod
   fetch cctc91m21026 into a_ctc91m21.vcltipdes
   whenever error stop
   close cctc91m21026
   display by name a_ctc91m21.vcltipdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_veiculo_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_servico_assist()
#========================================================================
   let a_ctc91m21.itaasisrvdes = null
   whenever error continue
   open cctc91m21006 using a_ctc91m21.itaasisrvcod
   fetch cctc91m21006 into a_ctc91m21.itaasisrvdes
   whenever error stop
   close cctc91m21006
   display by name a_ctc91m21.itaasisrvdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_servico_assist()
#========================================================================

#========================================================================
function ctc91m21_preenche_serv_carro_reserva()
#========================================================================
   let a_ctc91m21.itarsrcaosrvdes = null
   whenever error continue
   open cctc91m21007 using a_ctc91m21.itarsrcaosrvcod
   fetch cctc91m21007 into a_ctc91m21.itarsrcaosrvdes
   whenever error stop
   close cctc91m21007
   display by name a_ctc91m21.itarsrcaosrvdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_serv_carro_reserva()
#========================================================================

#========================================================================
function ctc91m21_preenche_assist_empresa()
#========================================================================
   let a_ctc91m21.itaempasides = null
   whenever error continue
   open cctc91m21008 using a_ctc91m21.itaempasicod
   fetch cctc91m21008 into a_ctc91m21.itaempasides
   whenever error stop
   close cctc91m21008
   display by name a_ctc91m21.itaempasides

#========================================================================
end function # Fim da funcao ctc91m21_preenche_assist_empresa()
#========================================================================

#========================================================================
function ctc91m21_preenche_tipo_carga_des()
#========================================================================
   let a_ctc91m21.itavclcrgtipcod = null
   whenever error continue
   open cctc91m21010 using a_ctc91m21.itavclcrgtipdes
   fetch cctc91m21010 into a_ctc91m21.itavclcrgtipcod
   whenever error stop
   close cctc91m21010
   display by name a_ctc91m21.itavclcrgtipcod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_tipo_carga_des()
#========================================================================

#========================================================================
function ctc91m21_preenche_tipo_carga_cod()
#========================================================================
   let a_ctc91m21.itavclcrgtipdes = null
   whenever error continue
   open cctc91m21011 using a_ctc91m21.itavclcrgtipcod
   fetch cctc91m21011 into a_ctc91m21.itavclcrgtipdes
   whenever error stop
   close cctc91m21011
   display by name a_ctc91m21.itavclcrgtipdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_tipo_carga_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_segmento_itacod()
#========================================================================
   let a_ctc91m21.itaclisgmdes = null
   let a_ctc91m21.itaclisgmcod = null
   whenever error continue
   open cctc91m21019 using a_ctc91m21.itasgmcod
   fetch cctc91m21019 into a_ctc91m21.itaclisgmcod, a_ctc91m21.itaclisgmdes
   whenever error stop
   close cctc91m21019
   display by name a_ctc91m21.itaclisgmcod
   display by name a_ctc91m21.itaclisgmdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_segmento_itacod()
#========================================================================

#========================================================================
function ctc91m21_preenche_segmento_porcod()
#========================================================================
   let a_ctc91m21.itaclisgmdes = null
   let a_ctc91m21.itasgmcod = null
   whenever error continue
   open cctc91m21020 using a_ctc91m21.itaclisgmcod
   fetch cctc91m21020 into a_ctc91m21.itasgmcod, a_ctc91m21.itaclisgmdes
   whenever error stop
   close cctc91m21020
   display by name a_ctc91m21.itasgmcod
   display by name a_ctc91m21.itaclisgmdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_segmento_porcod()
#========================================================================

#========================================================================
function ctc91m21_preenche_score_cod()
#========================================================================
   let a_ctc91m21.itacliscodes = null
   whenever error continue
   open cctc91m21013 using a_ctc91m21.itacliscocod
   fetch cctc91m21013 into a_ctc91m21.itacliscodes
   whenever error stop
   close cctc91m21013
   display by name a_ctc91m21.itacliscodes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_score_des()
#========================================================================

#========================================================================
function ctc91m21_preenche_score_des()
#========================================================================
   let a_ctc91m21.itacliscocod = null
   whenever error continue
   open cctc91m21014 using a_ctc91m21.itacliscodes
   fetch cctc91m21014 into a_ctc91m21.itacliscocod
   whenever error stop
   close cctc91m21014
   display by name a_ctc91m21.itacliscocod

#========================================================================
end function # Fim da funcao ctc91m21_preenche_score_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_ramo()
#========================================================================
   let a_ctc91m21.itaramdes = null
   whenever error continue
   open cctc91m21015 using a_ctc91m21.itaramcod
   fetch cctc91m21015 into a_ctc91m21.itaramdes
   whenever error stop
   close cctc91m21015
   display by name a_ctc91m21.itaramdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_ramo()
#========================================================================

#========================================================================
function ctc91m21_preenche_garantia_cod()
#========================================================================
   let a_ctc91m21.rsrcaogrtcoditau = null
   let a_ctc91m21.rsrcaogrtdes = null
   whenever error continue
   open cctc91m21016 using a_ctc91m21.rsrcaogrtcod
   fetch cctc91m21016 into a_ctc91m21.rsrcaogrtcoditau, a_ctc91m21.rsrcaogrtdes
   whenever error stop
   close cctc91m21016
   display by name a_ctc91m21.rsrcaogrtcoditau, a_ctc91m21.rsrcaogrtdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_garantia_cod()
#========================================================================

#========================================================================
function ctc91m21_preenche_garantia_itau()
#========================================================================
   let a_ctc91m21.rsrcaogrtcod = null
   let a_ctc91m21.rsrcaogrtdes = null
   whenever error continue
   open cctc91m21017 using a_ctc91m21.rsrcaogrtcoditau
   fetch cctc91m21017 into a_ctc91m21.rsrcaogrtcod, a_ctc91m21.rsrcaogrtdes
   whenever error stop
   close cctc91m21017
   display by name a_ctc91m21.rsrcaogrtcod, a_ctc91m21.rsrcaogrtdes

#========================================================================
end function # Fim da funcao ctc91m21_preenche_garantia_itau()
#========================================================================

#========================================================================
function ctc91m21_preenche_ubb()
#========================================================================
   let a_ctc91m21.vcltipdesubb = null
   whenever error continue
   open cctc91m21018 using a_ctc91m21.ubbcod
   fetch cctc91m21018 into a_ctc91m21.vcltipdesubb
   whenever error stop
   close cctc91m21018
   display by name a_ctc91m21.vcltipdesubb

#========================================================================
end function # Fim da funcao ctc91m21_preenche_ubb()
#========================================================================


#========================================================================
function ctc91m21_limpa_campos()
#========================================================================
   initialize a_ctc91m21.* to null
   display by name a_ctc91m21.*
#========================================================================
end function # Fim da funcao ctc91m21_limpa_campos()
#========================================================================



#========================================================================
function ctc91m21_atualiza_movimento()
#========================================================================
   define lr_retorno record
       erro  smallint
      ,msg   char(70)
   end record

   initialize lr_retorno.* to null

   whenever error continue
   execute pctc91m21002 using a_ctc91m21.itaciacod
                             ,a_ctc91m21.itaramcod
                             ,a_ctc91m21.itaprdcod
                             ,a_ctc91m21.itasgrplndes
                             ,a_ctc91m21.itaasisrvcod
                             ,a_ctc91m21.rsrcaogrtcoditau
                             ,a_ctc91m21.itarsrcaosrvcod
                             ,a_ctc91m21.itaempasicod
                             ,a_ctc91m21.itavclcrgtipdes
                             ,a_ctc91m21.itacliscodes
                             ,a_ctc91m21.itasgmcod
                             ,a_ctc91m21.ubbcod
                             ,a_ctc91m21.vndcnldes
                             ,a_ctc91m21.vcltipdes
                             ,a_ctc91m21.frtmdldes
                             ,a_ctc91m21.itaasiarqvrsnum
                             ,a_ctc91m21.itaasiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do MOVIMENTO. Tabela: <datmdetitaasiarq>."
   else
      let lr_retorno.erro = 0
   end if

   return lr_retorno.*
#========================================================================
end function # Fim da funcao ctc91m21_atualiza_dados()
#========================================================================
