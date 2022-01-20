#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctg18                                                      #
# ANALISTA RESP..: Ligia Maria Mattge                                         #
# PSI/OSF........:                                                            #
#                  Modulo main para espelho da apolice                        #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 30/05/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/10/2008 Carla Rampazzo  PSI 230650 Receber no arg_val(29) o campo atdnum #
#-----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  PSI 219444 Receber no arg_val(30) lclnumseq (RE) #
#                                       Receber no arg_val(31) rmerscseq (RE) #
#-----------------------------------------------------------------------------#
# 07/10/2010 Patricia W.     PSI260479  Se o atendimento for via proposta (sem#
#                                       apolice emitida, abre Espelho da Pro- #
#                                       posta.                                #
#-----------------------------------------------------------------------------#
# 28/01/2016 Alberto         CT         Sem permissão no banco                #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define w_log   char(60)

main


   define l_data       date
   define l_resultado  smallint,
          l_mensagem   char(60),
          l_doc_handle integer,
          l_grupo      decimal(1,0) # like gtakram.ramgrpcod



   let l_resultado    = null
   let l_mensagem     = null
   let l_doc_handle   = null
   let l_grupo        = null


   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg18.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------



   select unique sitename into g_hostname from dual   # PSI 175552

   defer interrupt
   set isolation to dirty read
   set lock mode to wait 10

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   initialize g_documento.* to null
   initialize g_ppt.* to null

   whenever error continue

   call p_reg_logo()
   call get_param()



   let g_documento.ramcod       = arg_val(15)
   let g_documento.succod       = arg_val(16)
   let g_documento.aplnumdig    = arg_val(17)
   let g_documento.itmnumdig    = arg_val(18)
   let g_documento.edsnumref    = arg_val(19)
   let g_documento.ligcvntip    = arg_val(20)
   let g_documento.prporg       = arg_val(21)
   let g_documento.prpnumdig    = arg_val(22)
   let g_documento.solnom       = arg_val(23)
   let g_documento.ciaempcod    = arg_val(24)
   let l_grupo                  = arg_val(25)
   let g_documento.c24soltipcod = arg_val(26)
   let g_documento.corsus       = arg_val(27)
   let g_monitor.horaini        = arg_val(28)
   let g_documento.atdnum       = arg_val(29)
   let g_documento.lclnumseq    = arg_val(30) --> Utilizado p/ Clausulas do RE
   let g_documento.rmerscseq    = arg_val(31) --> Utilizado p/ Clausulas do RE
   let g_documento.itaciacod    = arg_val(32)

   open window win_cab at 02,02 with 22 rows, 78 columns
        attribute (border)

   let l_data = today
   display "CENTRAL 24 HS" at 01,01

   if g_documento.ciaempcod = 1 then
      display "P O R T O   S E G U R O  -  S E G U R O S" at 01,20
   else
      if  g_documento.ciaempcod = 84 then
          display "        I T A U  -  S E G U R O S        " AT 1,20 attribute(reverse)
      else
          display "        A Z U L  -  S E G U R O S        " AT 1,20
      end if
   end if

   display l_data       at 01,69

   if g_documento.ciaempcod = 1 then ## Apolice Auto
      if l_grupo = 1 then ## Auto
         if ((g_documento.aplnumdig is null or g_documento.aplnumdig = 0) and
            ((g_documento.prporg is not null and g_documento.prporg <> 0 ) and
             (g_documento.prpnumdig is not null and g_documento.prpnumdig <> 0))) then
             # quando o atendimento eh feito via proposta (sem apolice emitida)
            call cta01m18(g_documento.prporg,g_documento.prpnumdig)
                 returning l_resultado, l_mensagem
         else
             # quando o atendimento eh feito para segurado que ja tem apolice emitida
            call cta01m00()
         end if
      else
          call cta01m20() ## RE
      end if
   else
      if g_documento.ciaempcod = 35 then ## Apolice Azul
         call cts42g00_doc_handle(g_documento.succod,
                                  g_documento.ramcod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  g_documento.edsnumref)
              returning l_resultado, l_mensagem, l_doc_handle
         call cta01m03(l_doc_handle)
      else
         if g_documento.ciaempcod = 84 then ## Apolice Itau
	    if g_documento.ramcod = 14 then
               call cta21m00()
	    else
               call cta16m00()
            end if
         end if
      end if
   end if

   close window win_cab

end main
