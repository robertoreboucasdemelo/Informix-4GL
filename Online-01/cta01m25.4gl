###############################################################################
# Nome do Modulo: cta01m25                                           Marcelo  #
#                                                                    Gilberto #
# Consulta importancias seguradas de apolices de R.E.                Set/1997 #
# ----------------------------------------------------------------------------#  
#                  * * *  A L T E R A C O E S  * * *                          #  
#                                                                             #  
# Data       Autor Fabrica         PSI    Alteracoes                          #  
# ---------- --------------------- ------ ------------------------------------#  
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #  
#-----------------------------------------------------------------------------#  

globals "/homedsa/projetos/geral/globals/glct.4gl"
                          
                                                                               
#------------------------------------------------------------------------------
 function cta01m25(param)
#------------------------------------------------------------------------------

 define param      record
    ramcod         like rsamseguro.ramcod,
    prporg         like rsdmlocal.prporg,
    prpnumdig      like rsdmlocal.prpnumdig,
    rmemdlcod      like rsamseguro.rmemdlcod,
    sgrorg         like rsdmdocto.sgrorg,
    sgrnumdig      like rsdmdocto.sgrnumdig,
    dctnumseq      like rsdmdocto.dctnumseq
 end record

 define d_cta01m25 record
    imsdifvlr      like rsimsitcbt.imsdifvlr,
    parliqvlr      like rspmparc.parliqvlr,
    prmtotvlr      like rspmparc.parliqvlr
 end record

 define ws         record
    pergunta       char (01),
    cstaplvlr      like rspmparc.cstaplvlr,
    cstapladc      like rspmparc.cstapladc,
    adcfrcvlr      like rspmparc.adcfrcvlr,
    iofvlr         like rspmparc.iofvlr
 end record


	initialize  d_cta01m25.*  to  null

	initialize  ws.*  to  null

 initialize d_cta01m25.*  to null
 initialize ws.*          to null
 let int_flag = false


 open window cta01m25 at 10,21 with form "cta01m25"
      attribute(form line first, border)

 #-------------------------------------------------------------
 # Calcula importancia segurada, premio liquido total
 #-------------------------------------------------------------
 ##whenever error continue

 call F_CALC_IMS_PRM(param.prporg   , param.prpnumdig, param.sgrorg   ,
                     param.sgrnumdig, param.ramcod   , param.rmemdlcod,
                     param.dctnumseq)

      returning  d_cta01m25.imsdifvlr, d_cta01m25.parliqvlr,
                 ws.cstaplvlr , ws.cstapladc , ws.adcfrcvlr,
                 ws.iofvlr

 let d_cta01m25.prmtotvlr = d_cta01m25.parliqvlr + ws.adcfrcvlr +
                            ws.cstaplvlr + ws.cstapladc + ws.iofvlr

 ##whenever error stop

 display by name d_cta01m25.*

 prompt " (F17)Abandona" for char ws.pergunta

 close window cta01m25
 let int_flag = false

end function  ###  cta01m25
