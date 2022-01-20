###########################################################################
# Nome do Modulo: CTC15N00                                       Marcelo  #
#                                                                Gilberto #
# Menu de Cadastros - Tipos de servico/assistencia               Jul/1998 #
###########################################################################
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ---------------------------------- #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc15n00()
#---------------------------------------------------------------

   let int_flag = false

   open window w_ctc15n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc15n00--" at 03,01

   menu "CADASTROS"

   before menu
      #PSI 202290
      #if g_issk.funmat <> 601566 then
      #hide option all

      #if get_niv_mod(g_issk.prgsgl,"ctc15m00")  then
      #   if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 8
      #      show option "tipos_Servico"
      #   end if
      #end if

      #if get_niv_mod(g_issk.prgsgl,"ctc15m01")  then
      #   if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 8
      #      show option "tipos_Assistencia"
      #   end if
      #end if

      #if get_niv_mod(g_issk.prgsgl,"ctc15m03")  then
      #   if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 8
      #      show option "eTapas"
      #   end if
      #end if

#     if get_niv_mod(g_issk.prgsgl,"ctc15m05")  then
#        if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 8
      #      show option "Motivos"
#        end if
#     end if
      #else
         show option all
         show option "tipos_Servico", "tipos_Assistencia",
                      "eTapas", "Motivos"
      #end if
     
      show option "Encerra"

      command key ("S") "tipos_Servico"     "Manutencao de tipos de servicos"
        call ctc15m00()

      command key ("A") "tipos_Assistencia" "Manutencao de tipos de assistencias"
        call ctc15m01()

      command key ("T") "eTapas"            "Manutencao de etapas de acompanhamento"
        call ctc15m03()

      command key ("M") "Motivos"           "Manutencao de motivos para assistencia"
        call ctc15m05()

      command key (interrupt,E) "Encerra"   "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc15n00

   let int_flag = false

end function  ###  ctc15n00
