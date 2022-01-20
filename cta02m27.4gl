###############################################################################
# Nome do Modulo: cta02m27                                                    #
#                                                                             #
# Mostrar a os avisos de sinistros feitos na Web                              #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#-----------------------------------------------------------------------------#
 database porto

#-----------------------------------------------------------
 function cta02m27(lr_param)                        #PSI183431 - robson
#-----------------------------------------------------------

 define lr_param record
       sinavsnum         like ssamsin.sinnum,
       sinavsano         like ssamsin.sinano
 end record
 define sin_web array[10] of record
             sinavsdat like sanmavs.sinavsdat,
             vcllicnum like sanmavs.vcllicnum,
             ramcod    like sanmavs.ramcod,
             succod    like sanmsin.succod,
             aplnumdig like sanmsin.aplnumdig,
             itmnumdig like sanmsin.itmnumdig,
             prporg    like sanmrefdct.sinavsdctorgcod,
             prpnumdig like sanmrefdct.sinavsdctnum,
             origem    char(3)
 end record
 define lr_retorno record
       succod    like datrligapol.succod   ,
       aplnumdig like datrligapol.aplnumdig,
       itmnumdig like datrligapol.itmnumdig,
       prporg    like datrligprp.prporg,
       prpnumdig like datrligprp.prpnumdig
 end record

 define arr_aux    integer
       ,w_pf1      integer
       ,l_erro     integer
       ,l_msg      char(300)


 let arr_aux  = null
 let l_erro   = null
 let l_msg    = null
 initialize lr_retorno.* to null

 for	w_pf1  =  1  to  10
	initialize  sin_web[w_pf1].*  to  null
 end	for
  call ssata100_consulta_aviso_geral_numero_aviso(lr_param.sinavsnum,
                                                  lr_param.sinavsano)
    returning l_erro,l_msg,
              sin_web[1].*, sin_web[2].*,
              sin_web[3].*, sin_web[4].*,
              sin_web[5].*, sin_web[6].*,
              sin_web[7].*, sin_web[8].*,
              sin_web[9].*, sin_web[10].*
    if sin_web[2].sinavsdat is null then
            if sin_web[1].aplnumdig is not null then
               let lr_retorno.succod    = sin_web[1].succod
               let lr_retorno.aplnumdig = sin_web[1].aplnumdig
               let lr_retorno.itmnumdig = sin_web[1].itmnumdig
            else
               let lr_retorno.prporg     = sin_web[1].prporg
               let lr_retorno.prpnumdig  = sin_web[1].prpnumdig
            end if
    else
        open window cta02m27 at 2,2 with form "cta02m27"
                             attribute(form line 1, border)
        display "CENTRAL 24 HS" at 01,01
        display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
        #display w_data       at 01,69
        let int_flag = false
        message "(F8)Seleciona, (F17)Abandona"
        display array sin_web to s_cta02m27.*
           on key (interrupt,control-c,f17)
              exit display
           on key (F8)
              let arr_aux = arr_curr()
              let lr_retorno.succod    = sin_web[arr_aux].succod
              let lr_retorno.aplnumdig = sin_web[arr_aux].aplnumdig
              let lr_retorno.itmnumdig = sin_web[arr_aux].itmnumdig
              let lr_retorno.prporg    = sin_web[arr_aux].prporg
              let lr_retorno.prpnumdig = sin_web[arr_aux].prpnumdig
              exit display
        end display
        close window  cta02m27
        let int_flag = false
    end if

 return lr_retorno.*

end function  #  cta02m27
