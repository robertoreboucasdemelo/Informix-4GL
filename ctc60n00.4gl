###########################################################################
# Nome do Modulo: CTC60N00                                       WAGNER   #
#                                                                         #
# Menu de cadastros - Porto Socorro                              Jan/2003 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------------
 function ctc60n00()
#--------------------------------------------------------------------------

   let int_flag = false

   open window w_ctc60n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc60n00--" at 03,01

   menu "CADASTROS"

      before menu
             hide option all
#WWW         if get_niv_mod(g_issk.prgsgl,"ctc60m01") then
#WWW            if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 6
                   show option "Prestadores"
#WWW            end if
#WWW         end if
#WWW         if get_niv_mod(g_issk.prgsgl,"ctc60m02") then
#WWW            if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 6
                   show option "Viaturas"
#WWW            end if
#WWW         end if
#WWW         if get_niv_mod(g_issk.prgsgl,"ctc60m03") then
#WWW            if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 7
                   show option "Socorristas"
#WWW            end if
#WWW         end if
             show option "Encerra"

      command key ("P") "Prestadores"
                        "Manutencao do cadastro de prestadores"
        call ctc60M01()

      command key ("V") "Viaturas"
                        "Manutencao do cadastro de viaturas"
        call ctc60M02()

      command key ("S") "Socorristas"
                        "Manutencao do cadastro de socorristas"
        call ctc60M03()

      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc60n00

   let int_flag = false

end function   #---- ctc60n00
