###########################################################################
# Nome do Modulo: ctc91m23                                                #
#                                                                         #
# Correcao de apolice inconsistente                              Jan/2011 #
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

   define a_ctc91m23 record
       itaaplnum       like datmitaapl.itaaplnum
      ,itaaplitmnum    like datmitaaplitm.itaaplitmnum
      ,aplseqnum       like datmitaapl.aplseqnum
      ,itaciacod       like datmitaapl.itaciacod
      ,itaramcod       like datmitaapl.itaramcod
      ,segcgccpfnum    like datmitaapl.segcgccpfnum
      ,segcgcordnum    like datmitaapl.segcgcordnum
      ,segcgccpfdig    like datmitaapl.segcgccpfdig
      ,itaprdcod       like datmitaapl.itaprdcod
      ,itaprddes       like datkitaprd.itaprddes
      ,itasgrplncod    like datmitaaplitm.itasgrplncod
      ,itasgrplndes    like datkitasgrpln.itasgrplndes
      ,itaasisrvcod    like datmitaaplitm.itaasisrvcod
      ,itaasisrvdes    like datkitaasisrv.itaasisrvdes
      ,rsrcaogrtcod    like datmitaaplitm.rsrcaogrtcod
      ,itarsrcaogrtdes like datkitarsrcaogar.itarsrcaogrtdes
      ,itarsrcaosrvcod like datmitaaplitm.itarsrcaosrvcod
      ,itarsrcaosrvdes like datkitarsrcaosrv.itarsrcaosrvdes
      ,itaempasicod    like datmitaaplitm.itaempasicod
      ,itaempasides    like datkitaempasi.itaempasides
      ,itacliscocod    like datmitaapl.itacliscocod
      ,itacliscodes    like datkitaclisco.itacliscodes
      ,itaclisgmcod    like datmitaaplitm.itaclisgmcod
      ,itaclisgmdes    like datkitaclisgm.itaclisgmdes
      ,ubbcod          like datmitaaplitm.ubbcod
      ,vcltipdesubb    like datkubbvcltip.vcltipdes
      ,itavclcrgtipcod like datmitaaplitm.itavclcrgtipcod
      ,itavclcrgtipdes like datkitavclcrgtip.itavclcrgtipdes
      ,vcltipcod       like datmitaaplitm.vcltipcod
      ,vcltipdes       like datkitavcltip.vcltipdes
      ,vndcnlcod       like datmitaapl.vndcnlcod
      ,vndcnldes       like datkitavndcnl.vndcnldes
      ,frtmdlcod       like datmitaapl.frtmdlcod
      ,frtmdldes       like datkitafrtmdl.frtmdldes
      ,itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod
      ,itaaplcanmtvdes like datkitaaplcanmtv.itaaplcanmtvdes
   end record


#========================================================================
function ctc91m23_prepare()
#========================================================================
   define l_sql char(2000)

   let l_sql = "SELECT APL.itaaplnum,ITM.itaaplitmnum,APL.aplseqnum,APL.itaciacod ",
               "      ,APL.itaramcod,APL.segcgccpfnum,APL.segcgcordnum,APL.segcgccpfdig ",
               "      ,APL.itaprdcod,ITM.itasgrplncod,ITM.itaasisrvcod,ITM.rsrcaogrtcod ",
               "      ,ITM.itarsrcaosrvcod,ITM.itaempasicod,ITM.itavclcrgtipcod,APL.itacliscocod ",
               "      ,ITM.itaclisgmcod,ITM.ubbcod,ITM.itaaplcanmtvcod,ITM.vcltipcod ",
               "      ,APL.vndcnlcod,APL.frtmdlcod ",
               "FROM datmitaapl APL ",
               "INNER JOIN datmitaaplitm ITM ",
               "   ON APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.itaaplnum = ITM.itaaplnum ",
               "  AND APL.aplseqnum = ITM.aplseqnum ",
               "WHERE ITM.itaciacod = ? ",
               "AND   ITM.itaramcod = ? ",
               "AND   ITM.itaaplnum = ? ",
               "AND   ITM.aplseqnum = ? ",
               "AND   ITM.itaaplitmnum = ? "
   prepare p_ctc91m23_001 from l_sql
   declare c_ctc91m23_001 cursor for p_ctc91m23_001

   let l_sql = "UPDATE datmitaapl ",
               "SET  segcgccpfnum    = ? ",
               "    ,segcgcordnum    = ? ",
               "    ,segcgccpfdig    = ? ",
               "    ,itaprdcod       = ? ",
               "    ,itacliscocod    = ? ",
               "    ,vndcnlcod       = ? ",
               "    ,frtmdlcod       = ? ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_ctc91m23_002 from l_sql

   let l_sql = "UPDATE datmitaaplitm ",
               "SET  itavclcrgtipcod = ? ",
               "    ,itaaplitmnum    = ? ",
               "    ,itasgrplncod    = ? ",
               "    ,itaasisrvcod    = ? ",
               "    ,rsrcaogrtcod    = ? ",
               "    ,itarsrcaosrvcod = ? ",
               "    ,itaempasicod    = ? ",
               "    ,itaclisgmcod    = ? ",
               "    ,ubbcod          = ? ",
               "    ,itaaplcanmtvcod = ? ",
               "    ,vcltipcod       = ? ",
               "WHERE itaciacod    = ? ",
               "AND   itaramcod    = ? ",
               "AND   itaaplnum    = ? ",
               "AND   aplseqnum    = ? ",
               "AND   itaaplitmnum = ? "
   prepare p_ctc91m23_003 from l_sql

   let l_sql = "SELECT itaprddes    ",
               "FROM datkitaprd     ",
               "WHERE itaprdcod = ? "
   prepare p_ctc91m23_004 from l_sql
   declare c_ctc91m23_004 cursor for p_ctc91m23_004

   let l_sql = "SELECT itasgrplndes    ",
               "FROM datkitasgrpln     ",
               "WHERE itasgrplncod = ? "
   prepare p_ctc91m23_005 from l_sql
   declare c_ctc91m23_005 cursor for p_ctc91m23_005

   let l_sql = "SELECT itaasisrvdes    ",
               "FROM datkitaasisrv     ",
               "WHERE itaasisrvcod = ? "
   prepare p_ctc91m23_006 from l_sql
   declare c_ctc91m23_006 cursor for p_ctc91m23_006

   let l_sql = "SELECT itarsrcaosrvdes    ",
               "FROM datkitarsrcaosrv     ",
               "WHERE itarsrcaosrvcod = ? "
   prepare p_ctc91m23_007 from l_sql
   declare c_ctc91m23_007 cursor for p_ctc91m23_007

   let l_sql = "SELECT itaempasides    ",
               "FROM datkitaempasi     ",
               "WHERE itaempasicod = ? "
   prepare p_ctc91m23_008 from l_sql
   declare c_ctc91m23_008 cursor for p_ctc91m23_008

   let l_sql = "SELECT itavclcrgtipcod    ",
               "FROM datkitavclcrgtip     ",
               "WHERE itavclcrgtipdes = ? "
   prepare p_ctc91m23_010 from l_sql
   declare c_ctc91m23_010 cursor for p_ctc91m23_010

   let l_sql = "SELECT itavclcrgtipdes    ",
               "FROM datkitavclcrgtip     ",
               "WHERE itavclcrgtipcod = ? "
   prepare p_ctc91m23_011 from l_sql
   declare c_ctc91m23_011 cursor for p_ctc91m23_011

   let l_sql = "SELECT itacliscodes    ",
               "FROM datkitaclisco     ",
               "WHERE itacliscocod = ? "
   prepare p_ctc91m23_013 from l_sql
   declare c_ctc91m23_013 cursor for p_ctc91m23_013

   let l_sql = "SELECT itacliscocod    ",
               "FROM datkitaclisco     ",
               "WHERE itacliscodes = ? "
   prepare p_ctc91m23_014 from l_sql
   declare c_ctc91m23_014 cursor for p_ctc91m23_014

   let l_sql = "SELECT itaaplcanmtvdes    ",
               "FROM datkitaaplcanmtv     ",
               "WHERE itaaplcanmtvcod = ? "
   prepare p_ctc91m23_015 from l_sql
   declare c_ctc91m23_015 cursor for p_ctc91m23_015

   let l_sql = "SELECT itarsrcaogrtdes    ",
               "FROM datkitarsrcaogar     ",
               "WHERE rsrcaogrtcod = ? "
   prepare p_ctc91m23_016 from l_sql
   declare c_ctc91m23_016 cursor for p_ctc91m23_016

   let l_sql = "SELECT rsrcaogrtcod, itarsrcaogrtdes    ",
               "FROM datkitarsrcaogar     ",
               "WHERE itarsrcaogrtcod = ? "
   prepare p_ctc91m23_017 from l_sql
   declare c_ctc91m23_017 cursor for p_ctc91m23_017

   let l_sql = "SELECT vcltipdes    ",
               "FROM datkubbvcltip  ",
               "WHERE ubbcod = ?    "
   prepare p_ctc91m23_018 from l_sql
   declare c_ctc91m23_018 cursor for p_ctc91m23_018

   let l_sql = "SELECT itaclisgmcod, itaclisgmdes    ",
               "FROM datkitaclisgm     ",
               "WHERE itasgmcod = ? "
   prepare p_ctc91m23_019 from l_sql
   declare c_ctc91m23_019 cursor for p_ctc91m23_019

   let l_sql = "SELECT itaclisgmdes    ",
               "FROM datkitaclisgm     ",
               "WHERE itaclisgmcod = ? "
   prepare p_ctc91m23_020 from l_sql
   declare c_ctc91m23_020 cursor for p_ctc91m23_020

   let l_sql = "SELECT APL.itaaplnum,APL.aplseqnum,APL.itaciacod ",
               "      ,APL.itaramcod,APL.segcgccpfnum,APL.segcgcordnum,APL.segcgccpfdig ",
               "      ,APL.itaprdcod,APL.itacliscocod,APL.vndcnlcod,APL.frtmdlcod ",
               "FROM datmitaapl APL ",
               "WHERE APL.itaciacod = ? ",
               "AND   APL.itaramcod = ? ",
               "AND   APL.itaaplnum = ? ",
               "AND   APL.aplseqnum = ? "
   prepare p_ctc91m23_021 from l_sql
   declare c_ctc91m23_021 cursor for p_ctc91m23_021

   let l_sql = "SELECT FIRST 1 itaaplcanmtvcod ",
               "FROM datmitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_ctc91m23_022 from l_sql
   declare c_ctc91m23_022 cursor for p_ctc91m23_022

   let l_sql = "UPDATE datmitaaplitm ",
               "SET  itaaplcanmtvcod = ? ",
               "WHERE itaciacod    = ? ",
               "AND   itaramcod    = ? ",
               "AND   itaaplnum    = ? ",
               "AND   aplseqnum    = ? "
   prepare p_ctc91m23_023 from l_sql

   let l_sql = "UPDATE datmitaaplitm ",
               "SET  itaaplcanmtvcod = ? ",
               "WHERE itaciacod    = ? ",
               "AND   itaramcod    = ? ",
               "AND   itaaplnum    = ? ",
               "AND   aplseqnum    = ? ",
               "AND   itaaplitmnum = ? "
   prepare p_ctc91m23_024 from l_sql

   let l_sql = "SELECT frtmdldes    ",
               "FROM datkitafrtmdl     ",
               "WHERE frtmdlcod = ? "
   prepare p_ctc91m23_025 from l_sql
   declare c_ctc91m23_025 cursor for p_ctc91m23_025

   let l_sql = "SELECT vndcnldes    ",
               "FROM datkitavndcnl     ",
               "WHERE vndcnlcod = ? "
   prepare p_ctc91m23_026 from l_sql
   declare c_ctc91m23_026 cursor for p_ctc91m23_026

   let l_sql = "SELECT vcltipdes    ",
               "FROM datkitavcltip     ",
               "WHERE vcltipcod = ? "
   prepare p_ctc91m23_027 from l_sql
   declare c_ctc91m23_027 cursor for p_ctc91m23_027

#========================================================================
end function # Fim da funcao ctc91m23_prepare
#========================================================================

#========================================================================
function ctc91m23_input(lr_param)
#========================================================================

   define lr_param record
      itaciacod     like datmitaaplitm.itaciacod
     ,itaramcod     like datmitaaplitm.itaramcod
     ,itaaplnum     like datmitaaplitm.itaaplnum
     ,aplseqnum     like datmitaaplitm.aplseqnum
     ,itaaplitmnum  like datmitaaplitm.itaaplitmnum
     ,operacao      char(1)
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

   let int_flag = false

   open window w_ctc91m23 at 4,2 with form 'ctc91m23'
      attribute(form line first, message line first +19 ,comment line first +18, border)
      #attribute(form line first, message line last,comment line last - 1, border)


   while true

      call ctc91m23_prepare()

      message "        (F8)Atualizar Dados              (F17)Volta"

      call ctc91m23_limpa_campos()

      initialize lr_retorno.* to null
      call ctc91m23_preenche_dados_tela(lr_param.*) returning lr_retorno.*

      if lr_retorno.erro = 1 then
         error lr_retorno.msg
         sleep 2
         exit while
      end if


      call ctc91m23_preenche_produto()
      call ctc91m23_preenche_plano()
      call ctc91m23_preenche_servico_assist()
      call ctc91m23_preenche_serv_carro_reserva()
      call ctc91m23_preenche_assist_empresa()
      call ctc91m23_preenche_tipo_carga_cod()
      call ctc91m23_preenche_segmento_porcod()
      call ctc91m23_preenche_score_cod()
      call ctc91m23_preenche_garantia_cod()
      call ctc91m23_preenche_ubb()
      call ctc91m23_preenche_motivo_cancelamento()
      call ctc91m23_preenche_canal_cod()
      call ctc91m23_preenche_veiculo_cod()
      call ctc91m23_preenche_frota_cod()

      input by name a_ctc91m23.* without defaults

        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = true
            exit input

        #--------------------
         before field itaprdcod
        #--------------------
            if lr_param.operacao = "C" then
               next field itaaplcanmtvcod
            end if
            display a_ctc91m23.itaprdcod to
               s_ctc91m23.itaprdcod attribute(reverse)

        #--------------------
         after field itaprdcod
        #--------------------
            call ctc91m23_preenche_produto()
            if a_ctc91m23.itaprdcod = " " or
               a_ctc91m23.itaprdcod = 9999 or
               a_ctc91m23.itaprddes is null or
               a_ctc91m23.itaprddes = " " then
               call cto00m10_popup(3) returning a_ctc91m23.itaprdcod,
                                                a_ctc91m23.itaprddes
               call ctc91m23_preenche_produto()
            end if
            display a_ctc91m23.itaprdcod to
               s_ctc91m23.itaprdcod attribute(normal)

        #--------------------
         before field itasgrplncod
        #--------------------
            display a_ctc91m23.itasgrplncod to
               s_ctc91m23.itasgrplncod attribute(reverse)

        #--------------------
         after field itasgrplncod
        #--------------------
            call ctc91m23_preenche_plano()
            if a_ctc91m23.itasgrplncod = " " or
               a_ctc91m23.itasgrplncod = 9999 or
               a_ctc91m23.itasgrplndes is null or
               a_ctc91m23.itasgrplndes = " " then
               call cto00m10_popup(5) returning a_ctc91m23.itasgrplncod,
                                                a_ctc91m23.itasgrplndes
               call ctc91m23_preenche_plano()
            end if
            display a_ctc91m23.itasgrplncod to
               s_ctc91m23.itasgrplncod attribute(normal)

        #--------------------
         before field itaempasicod
        #--------------------
            display a_ctc91m23.itaempasicod to
               s_ctc91m23.itaempasicod attribute(reverse)

        #--------------------
         after field itaempasicod
        #--------------------
            call ctc91m23_preenche_assist_empresa()
            if a_ctc91m23.itaempasicod = " " or
               a_ctc91m23.itaempasicod = 9999 or
               a_ctc91m23.itaempasides is null or
               a_ctc91m23.itaempasides = " " then
               call cto00m10_popup(2) returning a_ctc91m23.itaempasicod,
                                                a_ctc91m23.itaempasides
               call ctc91m23_preenche_assist_empresa()
            end if
            display a_ctc91m23.itaempasicod to
               s_ctc91m23.itaempasicod attribute(normal)

        #--------------------
         before field itaasisrvcod
        #--------------------
            display a_ctc91m23.itaasisrvcod to
               s_ctc91m23.itaasisrvcod attribute(reverse)

        #--------------------
         after field itaasisrvcod
        #--------------------
            call ctc91m23_preenche_servico_assist()
            if a_ctc91m23.itaasisrvcod = " " or
               a_ctc91m23.itaasisrvcod = 9999 or
               a_ctc91m23.itaasisrvdes is null or
               a_ctc91m23.itaasisrvdes = " " then
               call cto00m10_popup(6) returning a_ctc91m23.itaasisrvcod,
                                                a_ctc91m23.itaasisrvdes
               call ctc91m23_preenche_servico_assist()
            end if
            display a_ctc91m23.itaasisrvcod to
               s_ctc91m23.itaasisrvcod attribute(normal)

        #--------------------
         before field rsrcaogrtcod
        #--------------------
            display a_ctc91m23.rsrcaogrtcod to
               s_ctc91m23.rsrcaogrtcod attribute(reverse)

        #--------------------
         after field rsrcaogrtcod
        #--------------------
            call ctc91m23_preenche_garantia_cod()
            if a_ctc91m23.rsrcaogrtcod = " " or
               a_ctc91m23.rsrcaogrtcod = 9999 or
               a_ctc91m23.itarsrcaogrtdes is null or
               a_ctc91m23.itarsrcaogrtdes = " " then
               call cto00m10_popup(11) returning a_ctc91m23.rsrcaogrtcod,
                                                a_ctc91m23.itarsrcaogrtdes
               call ctc91m23_preenche_garantia_cod()
            end if

            display a_ctc91m23.rsrcaogrtcod to
               s_ctc91m23.rsrcaogrtcod attribute(normal)

        #--------------------
         before field itavclcrgtipcod
        #--------------------
            display a_ctc91m23.itavclcrgtipcod to
               s_ctc91m23.itavclcrgtipcod attribute(reverse)

        #--------------------
         after field itavclcrgtipcod
        #--------------------
            call ctc91m23_preenche_tipo_carga_cod()
            if a_ctc91m23.itavclcrgtipcod = " " or
               a_ctc91m23.itavclcrgtipdes is null or
               a_ctc91m23.itavclcrgtipdes = " " then
               call cto00m10_popup(9) returning a_ctc91m23.itavclcrgtipcod,
                                                a_ctc91m23.itavclcrgtipdes
               call ctc91m23_preenche_tipo_carga_cod()
            end if
            display a_ctc91m23.itavclcrgtipcod to
               s_ctc91m23.itavclcrgtipcod attribute(normal)

        #--------------------
         before field itacliscocod
        #--------------------
            display a_ctc91m23.itacliscocod to
               s_ctc91m23.itacliscocod attribute(reverse)

        #--------------------
         after field itacliscocod
        #--------------------
            call ctc91m23_preenche_score_cod()
            if a_ctc91m23.itacliscocod = " " or
               a_ctc91m23.itacliscocod = 9999 or
               a_ctc91m23.itacliscodes is null or
               a_ctc91m23.itacliscodes = " " then
               call cto00m10_popup(8) returning a_ctc91m23.itacliscocod,
                                                a_ctc91m23.itacliscodes
               call ctc91m23_preenche_score_cod()
            end if
            display a_ctc91m23.itacliscocod to
               s_ctc91m23.itacliscocod attribute(normal)

        #--------------------
         before field itarsrcaosrvcod
        #--------------------
            display a_ctc91m23.itarsrcaosrvcod to
               s_ctc91m23.itarsrcaosrvcod attribute(reverse)

        #--------------------
         after field itarsrcaosrvcod
        #--------------------
            call ctc91m23_preenche_serv_carro_reserva()
            if a_ctc91m23.itarsrcaosrvcod = " " or
               a_ctc91m23.itarsrcaosrvcod = 9999 or
               a_ctc91m23.itarsrcaosrvdes is null or
               a_ctc91m23.itarsrcaosrvdes = " " then
               call cto00m10_popup(4) returning a_ctc91m23.itarsrcaosrvcod,
                                                a_ctc91m23.itarsrcaosrvdes
               call ctc91m23_preenche_serv_carro_reserva()
            end if
            display a_ctc91m23.itarsrcaosrvcod to
               s_ctc91m23.itarsrcaosrvcod attribute(normal)

        #--------------------
         before field itaclisgmcod
        #--------------------

            display a_ctc91m23.itaclisgmcod to
               s_ctc91m23.itaclisgmcod attribute(reverse)

        #--------------------
         after field itaclisgmcod
        #--------------------
            call ctc91m23_preenche_segmento_porcod()
            if a_ctc91m23.itaclisgmcod = " " or
               a_ctc91m23.itaclisgmcod = 9999 or
               a_ctc91m23.itaclisgmdes is null or
               a_ctc91m23.itaclisgmdes = " " then
               call cto00m10_popup(7) returning a_ctc91m23.itaclisgmcod,
                                                a_ctc91m23.itaclisgmdes
               call ctc91m23_preenche_segmento_porcod()
            end if
            display a_ctc91m23.itaclisgmcod to
               s_ctc91m23.itaclisgmcod attribute(normal)

        #--------------------
         before field ubbcod
        #--------------------
            if lr_param.operacao = "C" then
               next field itaaplcanmtvcod
            end if
            display a_ctc91m23.ubbcod to
               s_ctc91m23.ubbcod attribute(reverse)

        #--------------------
         after field ubbcod
        #--------------------
            call ctc91m23_preenche_ubb()
            if a_ctc91m23.ubbcod = " " or
               a_ctc91m23.ubbcod = 9999 or
               a_ctc91m23.vcltipdesubb is null or
               a_ctc91m23.vcltipdesubb = " " then
               call cto00m10_popup(15) returning a_ctc91m23.ubbcod,
                                                a_ctc91m23.vcltipdesubb
               call ctc91m23_preenche_ubb()
            end if
            display a_ctc91m23.ubbcod to
               s_ctc91m23.ubbcod attribute(normal)


        #--------------------
         before field vcltipcod
        #--------------------
            if lr_param.operacao = "C" then
               next field itaaplcanmtvcod
            end if
            display a_ctc91m23.vcltipcod to
               s_ctc91m23.vcltipcod attribute(reverse)

        #--------------------
         after field vcltipcod
        #--------------------
            call ctc91m23_preenche_veiculo_cod()
            if a_ctc91m23.vcltipcod = " " or
               a_ctc91m23.vcltipcod = 9999 or
               a_ctc91m23.vcltipdes is null or
               a_ctc91m23.vcltipdes = " " then
               call cto00m10_popup(20) returning a_ctc91m23.vcltipcod,
                                                a_ctc91m23.vcltipdes
               call ctc91m23_preenche_veiculo_cod()
            end if
            display a_ctc91m23.vcltipcod to
               s_ctc91m23.vcltipcod attribute(normal)

        #--------------------
         before field vndcnlcod
        #--------------------
            if lr_param.operacao = "C" then
               next field itaaplcanmtvcod
            end if
            display a_ctc91m23.vndcnlcod to
               s_ctc91m23.vndcnlcod attribute(reverse)

        #--------------------
         after field vndcnlcod
        #--------------------
            call ctc91m23_preenche_canal_cod()
            if a_ctc91m23.vndcnlcod = " " or
               a_ctc91m23.vndcnlcod = 9999 or
               a_ctc91m23.vndcnldes is null or
               a_ctc91m23.vndcnldes = " " then
               call cto00m10_popup(19) returning a_ctc91m23.vndcnlcod,
                                                a_ctc91m23.vndcnldes
               call ctc91m23_preenche_canal_cod()
            end if
            display a_ctc91m23.vndcnlcod to
               s_ctc91m23.vndcnlcod attribute(normal)

        #--------------------
         before field frtmdlcod
        #--------------------
            if lr_param.operacao = "C" then
               next field itaaplcanmtvcod
            end if
            display a_ctc91m23.frtmdlcod to
               s_ctc91m23.frtmdlcod attribute(reverse)

        #--------------------
         after field frtmdlcod
        #--------------------
            call ctc91m23_preenche_frota_cod()
            if a_ctc91m23.frtmdlcod = " " or
               a_ctc91m23.frtmdlcod = 9999 or
               a_ctc91m23.frtmdldes is null or
               a_ctc91m23.frtmdldes = " " then
               call cto00m10_popup(18) returning a_ctc91m23.frtmdlcod,
                                                a_ctc91m23.frtmdldes
               call ctc91m23_preenche_frota_cod()
            end if
            display a_ctc91m23.frtmdlcod to
               s_ctc91m23.frtmdlcod attribute(normal)
            next field itaprdcod


        #--------------------
         before field itaaplcanmtvcod
        #--------------------
            if lr_param.operacao = "I" then
               next field itaprdcod
            end if
            display a_ctc91m23.itaaplcanmtvcod to
               s_ctc91m23.itaaplcanmtvcod attribute(reverse)

        #--------------------
         after field itaaplcanmtvcod
        #--------------------
            call ctc91m23_preenche_motivo_cancelamento()
            if a_ctc91m23.itaaplcanmtvcod = " " or
               a_ctc91m23.itaaplcanmtvcod = 9999 or
               a_ctc91m23.itaaplcanmtvdes is null or
               a_ctc91m23.itaaplcanmtvdes = " " then
               call cto00m10_popup(12) returning a_ctc91m23.itaaplcanmtvcod,
                                                 a_ctc91m23.itaaplcanmtvdes
               call ctc91m23_preenche_motivo_cancelamento()
            end if
            display a_ctc91m23.itaaplcanmtvcod to
               s_ctc91m23.itaaplcanmtvcod attribute(normal)
            next field itaaplcanmtvcod



        #--------------------
         on key (F8)
        #--------------------
            initialize lr_retorno.* to null

            if lr_param.operacao = "I" then
               if #a_ctc91m23.segcgccpfnum    is null or a_ctc91m23.segcgccpfnum    = " " or
                  #a_ctc91m23.segcgcordnum    is null or a_ctc91m23.segcgcordnum    = " " or
                  #a_ctc91m23.segcgccpfdig    is null or a_ctc91m23.segcgccpfdig    = " " or
                  a_ctc91m23.itaprdcod       is null or a_ctc91m23.itaprdcod       = " " or
                  a_ctc91m23.itasgrplncod    is null or a_ctc91m23.itasgrplncod    = " " or
                  a_ctc91m23.itaasisrvcod    is null or a_ctc91m23.itaasisrvcod    = " " or
                  a_ctc91m23.rsrcaogrtcod    is null or a_ctc91m23.rsrcaogrtcod    = " " or
                  a_ctc91m23.itarsrcaosrvcod is null or a_ctc91m23.itarsrcaosrvcod = " " or
                  a_ctc91m23.itaempasicod    is null or a_ctc91m23.itaempasicod    = " " or
                  a_ctc91m23.itacliscocod    is null or a_ctc91m23.itacliscocod    = " " or
                  a_ctc91m23.itaclisgmcod    is null or a_ctc91m23.itaclisgmcod    = " " or
                  a_ctc91m23.ubbcod          is null or a_ctc91m23.ubbcod          = " " or
                  a_ctc91m23.vcltipcod       is null or a_ctc91m23.vcltipcod       = " " or
                  a_ctc91m23.vndcnlcod       is null or a_ctc91m23.vndcnlcod       = " " or
                  a_ctc91m23.frtmdlcod       is null or a_ctc91m23.frtmdlcod       = " " then

                  error "Atualizacao cancelada. Todos os campos devem ser preenchidos."
                  display by name a_ctc91m23.* attribute(normal)
                  next field itaprdcod
               end if

               call ctc91m23_atualiza_inclusao() returning lr_retorno.*
            end if

            if lr_param.operacao = "C" then
               if a_ctc91m23.itaaplcanmtvcod is null or a_ctc91m23.itaaplcanmtvcod = " " then
                  error "Atualizacao cancelada. O motivo de cancelamento deve ser preenchido."
                  display by name a_ctc91m23.* attribute(normal)
                  next field itaaplcanmtvcod
               end if

               call ctc91m23_atualiza_cancelamento() returning lr_retorno.*
            end if

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

   close window w_ctc91m23

#========================================================================
end function # Fim da funcao ctc91m23_input_array()
#========================================================================

#========================================================================
function ctc91m23_preenche_dados_tela(lr_param)
#========================================================================
   define lr_param record
      itaciacod     like datmitaaplitm.itaciacod
     ,itaramcod     like datmitaaplitm.itaramcod
     ,itaaplnum     like datmitaaplitm.itaaplnum
     ,aplseqnum     like datmitaaplitm.aplseqnum
     ,itaaplitmnum  like datmitaaplitm.itaaplitmnum
     ,operacao      char(1)
   end record

   define lr_retorno record
      erro  smallint
     ,msg   char(70)
   end record

   initialize lr_retorno.* to null

   let lr_retorno.erro = 0

   if lr_param.itaciacod is null or
      lr_param.itaramcod is null or
      lr_param.itaaplnum is null or
      lr_param.aplseqnum is null then

      let lr_retorno.erro = 1
      let lr_retorno.msg  = "Erro ao recuperar dados da apolice. (1)"
      return lr_retorno.*
   end if


   if lr_param.itaaplitmnum is null then  # Para os casos de cancelamento

      whenever error continue
      open c_ctc91m23_021 using lr_param.itaciacod
                               ,lr_param.itaramcod
                               ,lr_param.itaaplnum
                               ,lr_param.aplseqnum
      fetch c_ctc91m23_021 into  a_ctc91m23.itaaplnum
                                ,a_ctc91m23.aplseqnum
                                ,a_ctc91m23.itaciacod
                                ,a_ctc91m23.itaramcod
                                ,a_ctc91m23.segcgccpfnum
                                ,a_ctc91m23.segcgcordnum
                                ,a_ctc91m23.segcgccpfdig
                                ,a_ctc91m23.itaprdcod
                                ,a_ctc91m23.itacliscocod
                                ,a_ctc91m23.vndcnlcod
                                ,a_ctc91m23.frtmdlcod
      whenever error stop
      close c_ctc91m23_021

      whenever error continue
      open c_ctc91m23_022 using lr_param.itaciacod
                               ,lr_param.itaramcod
                               ,lr_param.itaaplnum
                               ,lr_param.aplseqnum
      fetch c_ctc91m23_022 into a_ctc91m23.itaaplcanmtvcod
      whenever error stop
      close c_ctc91m23_022

   else

      whenever error continue
      open c_ctc91m23_001 using lr_param.itaciacod
                               ,lr_param.itaramcod
                               ,lr_param.itaaplnum
                               ,lr_param.aplseqnum
                               ,lr_param.itaaplitmnum
      fetch c_ctc91m23_001 into  a_ctc91m23.itaaplnum
                                ,a_ctc91m23.itaaplitmnum
                                ,a_ctc91m23.aplseqnum
                                ,a_ctc91m23.itaciacod
                                ,a_ctc91m23.itaramcod
                                ,a_ctc91m23.segcgccpfnum
                                ,a_ctc91m23.segcgcordnum
                                ,a_ctc91m23.segcgccpfdig
                                ,a_ctc91m23.itaprdcod
                                ,a_ctc91m23.itasgrplncod
                                ,a_ctc91m23.itaasisrvcod
                                ,a_ctc91m23.rsrcaogrtcod
                                ,a_ctc91m23.itarsrcaosrvcod
                                ,a_ctc91m23.itaempasicod
                                ,a_ctc91m23.itavclcrgtipcod
                                ,a_ctc91m23.itacliscocod
                                ,a_ctc91m23.itaclisgmcod
                                ,a_ctc91m23.ubbcod
                                ,a_ctc91m23.itaaplcanmtvcod
                                ,a_ctc91m23.vcltipcod
                                ,a_ctc91m23.vndcnlcod
                                ,a_ctc91m23.frtmdlcod
      whenever error stop
      close c_ctc91m23_001

   end if


   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na recuperacao dos dados da apolice."
   end if

   return lr_retorno.*


#========================================================================
end function # Fim da funcao ctc91m23_preenche_dados_tela()
#========================================================================

#========================================================================
function ctc91m23_preenche_produto()
#========================================================================
   let a_ctc91m23.itaprddes = null
   whenever error continue
   open c_ctc91m23_004 using a_ctc91m23.itaprdcod
   fetch c_ctc91m23_004 into a_ctc91m23.itaprddes
   whenever error stop
   close c_ctc91m23_004
   display by name a_ctc91m23.itaprddes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_produto()
#========================================================================

#========================================================================
function ctc91m23_preenche_plano()
#========================================================================
   let a_ctc91m23.itasgrplndes = null
   whenever error continue
   open c_ctc91m23_005 using a_ctc91m23.itasgrplncod
   fetch c_ctc91m23_005 into a_ctc91m23.itasgrplndes
   whenever error stop
   close c_ctc91m23_005
   display by name a_ctc91m23.itasgrplndes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_plano()
#========================================================================

#========================================================================
function ctc91m23_preenche_servico_assist()
#========================================================================
   let a_ctc91m23.itaasisrvdes = null
   whenever error continue
   open c_ctc91m23_006 using a_ctc91m23.itaasisrvcod
   fetch c_ctc91m23_006 into a_ctc91m23.itaasisrvdes
   whenever error stop
   close c_ctc91m23_006
   display by name a_ctc91m23.itaasisrvdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_servico_assist()
#========================================================================

#========================================================================
function ctc91m23_preenche_serv_carro_reserva()
#========================================================================
   let a_ctc91m23.itarsrcaosrvdes = null
   whenever error continue
   open c_ctc91m23_007 using a_ctc91m23.itarsrcaosrvcod
   fetch c_ctc91m23_007 into a_ctc91m23.itarsrcaosrvdes
   whenever error stop
   close c_ctc91m23_007
   display by name a_ctc91m23.itarsrcaosrvdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_serv_carro_reserva()
#========================================================================

#========================================================================
function ctc91m23_preenche_assist_empresa()
#========================================================================
   let a_ctc91m23.itaempasides = null
   whenever error continue
   open c_ctc91m23_008 using a_ctc91m23.itaempasicod
   fetch c_ctc91m23_008 into a_ctc91m23.itaempasides
   whenever error stop
   close c_ctc91m23_008
   display by name a_ctc91m23.itaempasides

#========================================================================
end function # Fim da funcao ctc91m23_preenche_assist_empresa()
#========================================================================

#========================================================================
function ctc91m23_preenche_tipo_carga_cod()
#========================================================================
   let a_ctc91m23.itavclcrgtipdes = null
   whenever error continue
   open c_ctc91m23_011 using a_ctc91m23.itavclcrgtipcod
   fetch c_ctc91m23_011 into a_ctc91m23.itavclcrgtipdes
   whenever error stop
   close c_ctc91m23_011
   display by name a_ctc91m23.itavclcrgtipdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_tipo_carga_cod()
#========================================================================

#========================================================================
function ctc91m23_preenche_segmento_porcod()
#========================================================================
   let a_ctc91m23.itaclisgmdes = null
   whenever error continue
   open c_ctc91m23_020 using a_ctc91m23.itaclisgmcod
   fetch c_ctc91m23_020 into a_ctc91m23.itaclisgmdes
   whenever error stop
   close c_ctc91m23_020
   display by name a_ctc91m23.itaclisgmdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_segmento_porcod()
#========================================================================

#========================================================================
function ctc91m23_preenche_score_cod()
#========================================================================
   let a_ctc91m23.itacliscodes = null
   whenever error continue
   open c_ctc91m23_013 using a_ctc91m23.itacliscocod
   fetch c_ctc91m23_013 into a_ctc91m23.itacliscodes
   whenever error stop
   close c_ctc91m23_013
   display by name a_ctc91m23.itacliscodes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_score_cod()
#========================================================================

#========================================================================
function ctc91m23_preenche_garantia_cod()
#========================================================================
   let a_ctc91m23.itarsrcaogrtdes = null
   whenever error continue
   open c_ctc91m23_016 using a_ctc91m23.rsrcaogrtcod
   fetch c_ctc91m23_016 into a_ctc91m23.itarsrcaogrtdes
   whenever error stop
   close c_ctc91m23_016
   display by name a_ctc91m23.itarsrcaogrtdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_garantia_cod()
#========================================================================

#========================================================================
function ctc91m23_preenche_ubb()
#========================================================================
   let a_ctc91m23.vcltipdesubb = null
   whenever error continue
   open c_ctc91m23_018 using a_ctc91m23.ubbcod
   fetch c_ctc91m23_018 into a_ctc91m23.vcltipdesubb
   whenever error stop
   close c_ctc91m23_018
   display by name a_ctc91m23.vcltipdesubb

#========================================================================
end function # Fim da funcao ctc91m23_preenche_ubb()
#========================================================================

#========================================================================
function ctc91m23_preenche_motivo_cancelamento()
#========================================================================
   let a_ctc91m23.itaaplcanmtvdes = null
   whenever error continue
   open c_ctc91m23_015 using a_ctc91m23.itaaplcanmtvcod
   fetch c_ctc91m23_015 into a_ctc91m23.itaaplcanmtvdes
   whenever error stop
   close c_ctc91m23_015
   display by name a_ctc91m23.itaaplcanmtvdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_motivo_cancelamento()
#========================================================================

#========================================================================
function ctc91m23_preenche_frota_cod()
#========================================================================
   let a_ctc91m23.frtmdldes = null
   whenever error continue
   open c_ctc91m23_025 using a_ctc91m23.frtmdlcod
   fetch c_ctc91m23_025 into a_ctc91m23.frtmdldes
   whenever error stop
   close c_ctc91m23_025
   display by name a_ctc91m23.frtmdldes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_frota_cod()
#========================================================================

#========================================================================
function ctc91m23_preenche_canal_cod()
#========================================================================
   let a_ctc91m23.vndcnldes = null
   whenever error continue
   open c_ctc91m23_026 using a_ctc91m23.vndcnlcod
   fetch c_ctc91m23_026 into a_ctc91m23.vndcnldes
   whenever error stop
   close c_ctc91m23_026
   display by name a_ctc91m23.vndcnldes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_canal_cod()
#========================================================================

#========================================================================
function ctc91m23_preenche_veiculo_cod()
#========================================================================
   let a_ctc91m23.vcltipdes = null
   whenever error continue
   open c_ctc91m23_027 using a_ctc91m23.vcltipcod
   fetch c_ctc91m23_027 into a_ctc91m23.vcltipdes
   whenever error stop
   close c_ctc91m23_027
   display by name a_ctc91m23.vcltipdes

#========================================================================
end function # Fim da funcao ctc91m23_preenche_veiculo_cod()
#========================================================================



#========================================================================
function ctc91m23_limpa_campos()
#========================================================================
   initialize a_ctc91m23.* to null
   display by name a_ctc91m23.*
#========================================================================
end function # Fim da funcao ctc91m23_limpa_campos()
#========================================================================



#========================================================================
function ctc91m23_atualiza_inclusao()
#========================================================================
   define lr_retorno record
       erro  smallint
      ,msg   char(70)
   end record

   initialize lr_retorno.* to null

   # Grava dados na apolice
   whenever error continue
   execute p_ctc91m23_002 using a_ctc91m23.segcgccpfnum
                               ,a_ctc91m23.segcgcordnum
                               ,a_ctc91m23.segcgccpfdig
                               ,a_ctc91m23.itaprdcod
                               ,a_ctc91m23.itacliscocod
                               ,a_ctc91m23.vndcnlcod
                               ,a_ctc91m23.frtmdlcod
                               ,a_ctc91m23.itaciacod
                               ,a_ctc91m23.itaramcod
                               ,a_ctc91m23.itaaplnum
                               ,a_ctc91m23.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao da APOLICE. <datmitaapl>."
      return lr_retorno.*
   end if

   # Grava dados no item da apolice
   execute p_ctc91m23_003 using a_ctc91m23.itavclcrgtipcod
                               ,a_ctc91m23.itaaplitmnum
                               ,a_ctc91m23.itasgrplncod
                               ,a_ctc91m23.itaasisrvcod
                               ,a_ctc91m23.rsrcaogrtcod
                               ,a_ctc91m23.itarsrcaosrvcod
                               ,a_ctc91m23.itaempasicod
                               ,a_ctc91m23.itaclisgmcod
                               ,a_ctc91m23.ubbcod
                               ,a_ctc91m23.itaaplcanmtvcod
                               ,a_ctc91m23.vcltipcod
                               ,a_ctc91m23.itaciacod
                               ,a_ctc91m23.itaramcod
                               ,a_ctc91m23.itaaplnum
                               ,a_ctc91m23.aplseqnum
                               ,a_ctc91m23.itaaplitmnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.erro = 1
      let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do ITEM. (1) <datmitaaplitm>."
      return lr_retorno.*
   end if

   let lr_retorno.erro = 0

   return lr_retorno.*

#========================================================================
end function # Fim da funcao ctc91m23_atualiza_inclusao()
#========================================================================



#========================================================================
function ctc91m23_atualiza_cancelamento()
#========================================================================
   define lr_retorno record
       erro  smallint
      ,msg   char(70)
   end record

   initialize lr_retorno.* to null

   # Cancelamento de apenas um item
   if a_ctc91m23.itaaplitmnum is not null then

      # Grava dados no item da apolice
      execute p_ctc91m23_024 using a_ctc91m23.itaaplcanmtvcod
                                  ,a_ctc91m23.itaciacod
                                  ,a_ctc91m23.itaramcod
                                  ,a_ctc91m23.itaaplnum
                                  ,a_ctc91m23.aplseqnum
                                  ,a_ctc91m23.itaaplitmnum
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.erro = 1
         let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do ITEM. (2) <datmitaaplitm>."
         return lr_retorno.*
      end if

   # Cancelamento de varios itens
   else
      # Grava dados no item da apolice
      execute p_ctc91m23_023 using a_ctc91m23.itaaplcanmtvcod
                                  ,a_ctc91m23.itaciacod
                                  ,a_ctc91m23.itaramcod
                                  ,a_ctc91m23.itaaplnum
                                  ,a_ctc91m23.aplseqnum
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.erro = 1
         let lr_retorno.msg = "Erro (", sqlca.sqlcode clipped, ") na atualizacao do ITEM. (2) <datmitaaplitm>."
         return lr_retorno.*
      end if

   end if


   let lr_retorno.erro = 0

   return lr_retorno.*

#========================================================================
end function # Fim da funcao ctc91m23_atualiza_cancelamento()
#========================================================================