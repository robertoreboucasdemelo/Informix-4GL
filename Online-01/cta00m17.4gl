#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m17.4gl                                               #
# Analista Resp : Carlos Ruiz                                                #
#                 Funcao para chamar programas ac_propostas                  #
#............................................................................#
# Prototipo      : Amilton, Meta                                             #
# Liberacao      :                                                           #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#

#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'


#-----------------------------------#
 function cta00m17_chama_prog(lr_param)
#-----------------------------------#

   define lr_param  record
          prog         char(11),                     # Nome do programa 4gc
          prgsol       char(11),                     # Programa Solicitante
          chvdatk      char(15),                     # Chave da datkgeral
          prporg       like papmhist.prporg,         # Origem da proposta
          prpnumdig    like papmhist.prpnumdig       # Numero da proposta
   end record

   define l_resultado     smallint
          ,l_arg_val_fixos char(300)
          ,l_funmat char(6)
          ,l_horlig char(8)
          ,l_prog   char(10)

   let l_resultado     = null
   let l_funmat        = null
   let l_horlig        = null
   let l_prog          = null
   let l_arg_val_fixos = null
   let l_funmat = lr_param.chvdatk [1,6]
   let l_horlig = lr_param.chvdatk [7,14]
   let l_arg_val_fixos =
    "' ", g_issk.succod         using "<<<<<<<&",     "'  ",
    " '", g_issk.funmat         using "<<<<<<<&",     " ' ",
    "' ", g_issk.funnom         clipped,              "  '",
    " '", g_issk.dptsgl         clipped,              " ' ",
    " '", g_issk.dpttip         clipped,              " ' ",
    " '", g_issk.dptcod         using "<<<<<<&",      " ' ",
    " '", g_issk.sissgl         clipped,              " ' ",
    " '  ", g_issk.acsnivcod    using "<<<<<&",       " ' ",
    " '"  , "opacm140",                             " '",
    " '", g_issk.usrtip         clipped,              " ' ",
    " '", g_issk.empcod         using "<<<<<<<<&",    " ' ",
    " '", g_issk.iptcod         using "<<<<<<<<&",    " ' ",
    " '", g_issk.usrcod         clipped,              " ' ",
    " '", g_issk.maqsgl         clipped,              " ' ",
    " '", lr_param.prgsol       clipped,              " ' ",
    " '", l_funmat              clipped,              " ' ",
    " '", l_horlig              clipped,              " ' ",
    " '", lr_param.prporg       clipped,              " ' ",
    " '", lr_param.prpnumdig    clipped,              " ' "
   call roda_prog(lr_param.prog, l_arg_val_fixos, 1)
        returning l_resultado
   return l_resultado


end function
