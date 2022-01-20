###############################################################################
# Nome do Modulo: cta02m26.4gl                                                #
#                                                                             #
# Mostrar a os avisos de sinistros feitos na Web                              #
#                                                                             #
###############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                      * * * * * Altecacoes * * * * *                         #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------  #
###############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"


 define w_arr        integer

#-----------------------------------------------------------------------
 function cta02m26(lr_param)
#-----------------------------------------------------------------------

 define lr_param record
        atdsrvnum   like sanmsin.sinnum,
        atdsrvano   like sanmsin.sinano,
        succod      like sanmsin.succod,
        aplnumdig   like sanmsin.aplnumdig,
        itmnumdig   like sanmsin.itmnumdig,
        prporg      like sanmrefdct.sinavsdctorgcod,
        prpnumdig   like sanmrefdct.sinavsdctnum,
        c24astcod   like datkassunto.c24astcod
 end record

 define sin array[10] of record
        numero_aviso like sanmavs.sinavsnum
 end record

 define l_i     integer
       ,l_erro  integer
       ,l_msg   char(300)
       ,l_cabtxt  char(70)


 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------

  let l_i = 1

  for l_i = 1 to 10
      initialize sin[l_i].* to null
  end for


  call ssata100_consulta_avisoweb_central24h_f8(lr_param.atdsrvnum,
                                                lr_param.atdsrvano,
                                                lr_param.succod,
                                                lr_param.aplnumdig,
                                                lr_param.itmnumdig,
                                                lr_param.prporg,
                                                lr_param.prpnumdig,
                                                lr_param.c24astcod)
                        returning l_erro, l_msg,
                               sin[1].numero_aviso, sin[2].numero_aviso,
                               sin[3].numero_aviso, sin[4].numero_aviso,
                               sin[5].numero_aviso, sin[6].numero_aviso,
                               sin[7].numero_aviso, sin[8].numero_aviso,
                               sin[9].numero_aviso, sin[10].numero_aviso





   if l_erro = 0 then
      open window w_cta02m26 at 8,6 with form "cta02m26"
          attribute (border,form line 1, message line last)
      let l_cabtxt = "O AVISO DESTE DOCUMENTO ESTA NA WEB, CONSULTE: XXX XXXXXX XXXX - WEB"
      display  l_cabtxt  to  cabtxt
      message " (F17)Abandona"

      display array sin to s_cta02m26.*


        on key (interrupt)
           exit display
      end display
      let int_flag = false
      close window w_cta02m26
   else
       if l_erro <> 100 then
          return  l_erro
       else
          return l_erro
       end if
   end if

return l_erro

end function
