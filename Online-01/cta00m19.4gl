#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m19.4gl                                               #
# Analista Resp : Roberto Melo                                               #
#                 Funcao para chamar programa auto_aceitacao                 #
#............................................................................#
# Prototipo      : Amilton, Meta                                             #
# Liberacao      : 25/09/2008                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#

#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'


#-----------------------------------#
 function cta00m19_chama_prog(lr_param)
#-----------------------------------#

   define lr_param  record
          prog          char(11),                     # Nome do programa 4gc
          prgsol        char(11),                     # Programa Solicitante
          chvdatk       char(15),                     # Chave da datkgeral
          tipacao       char(01),
          aacdptatdcod  like aacmatd.aacdptatdcod,
          aacatdnum     like aacmatd.aacatdnum,
          aacatdano     like aacmatd.aacatdano,
          aacatdasscod  like aacmatd.aacatdasscod,
          tipcns        char(01),         
          saida         smallint,
          prporgpcp     like apametd.prporgpcp, 
          prpnumpcp     like apametd.prpnumpcp,     
          succod        like abamdoc.succod,
          aplnumdig     like abamdoc.aplnumdig          
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
    "' ", g_issk.succod                using "<<<<<<<&",     "'  ",
    " '", g_issk.funmat                using "<<<<<<<&",     " ' ",
    "' ", g_issk.funnom                clipped,              "  '",
    " '", g_issk.dptsgl                clipped,              " ' ",
    " '", g_issk.dpttip                clipped,              " ' ",
    " '", g_issk.dptcod                using "<<<<<<&",      " ' ",
    " '", g_issk.sissgl                clipped,              " ' ",
    " '  ", g_issk.acsnivcod           using "<<<<<&",       " ' ",
    " '"  , "oaacm200",                                    " '",
    " '", g_issk.usrtip                clipped,              " ' ",
    " '", g_issk.empcod                using "<<<<<<<<&",    " ' ",
    " '", g_issk.iptcod                using "<<<<<<<<&",    " ' ",
    " '", g_issk.usrcod                clipped,              " ' ",
    " '", g_issk.maqsgl                clipped,              " ' ",   
    " '", lr_param.prgsol              clipped,              " ' ",
    " '", l_funmat                     clipped,              " ' ",
    " '", l_horlig                     clipped,              " ' ",
    " '", lr_param.tipacao             clipped,              " ' ",
    " '", lr_param.aacdptatdcod        clipped,              " ' ",
    " '", lr_param.aacatdnum           clipped,              " ' ",
    " '", lr_param.aacatdano           clipped,              " ' ",
    " '", lr_param.aacatdasscod        clipped,              " ' ",
    " '", lr_param.tipcns              clipped,              " ' ",
    " '", lr_param.saida               clipped,              " ' ",
    " '", lr_param.prporgpcp           clipped,              " ' ",
    " '", lr_param.prpnumpcp           clipped,              " ' ",
    " '", lr_param.succod              clipped,              " ' ",
    " '", lr_param.aplnumdig           clipped,              " ' "
    
   
   call roda_prog(lr_param.prog, l_arg_val_fixos, 1)
        returning l_resultado
   return l_resultado


end function
