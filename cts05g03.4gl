#############################################################################
# Nome do Modulo: CTS05G03                                         Ruiz     #
# Monta cabecalho padrao dos laudos de servico para VIST.PREVIA    Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------------------
 function cts05g03(param)
#----------------------------------------------------------------------------

 define param        record
    vstnumdig        like avlmlaudo.vstnumdig
 end record

 define d_cts05g03   record
    segnom           like gsakseg.segnom       ,
    corsus           like datmservico.corsus   ,
    cornom           like datmservico.cornom   ,
    cvnnom           char (20)                 ,
    vclcoddig        like datmservico.vclcoddig,
    vcldes           like datmservico.vcldes   ,
    vclanomdl        like datmservico.vclanomdl,
    vcllicnum        like datmservico.vcllicnum,
    vclchsinc        like abbmveic.vclchsinc   ,
    vclchsfnl        like abbmveic.vclchsfnl   ,
    vclcordes        char (12)                 ,
    cgccpfnum        like avlmlaudo.cgccpfnum  ,
    cgcord           like avlmlaudo.cgcord     ,
    cgccpfdig        like avlmlaudo.cgccpfdig

 end record

 define ws           record
    pcacttnum        like eccmpti.pcapticod,
    pcaprpnum        like epcmproposta.pcaprpnum,
    vclcorcod        like datmservico.vclcorcod,
    pcactacod        like eccmpti.pcactacod,
    pcaclicod        like eccmcta.pcaclicod
 end record



	initialize  d_cts05g03.*  to  null

	initialize  ws.*  to  null

 initialize d_cts05g03.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Nome do convenio
#---------------------------------------------------------------

 select cpodes
   into d_cts05g03.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 if param.vstnumdig is null then
    return d_cts05g03.*
 end if

#-----------------------------------------------------------------
# Dados do Segurado
#-----------------------------------------------------------------

 select cgccpfnum,
        cgcord,
        cgccpfdig,
        segnom,
        corsus
   into d_cts05g03.cgccpfnum,
        d_cts05g03.cgcord   ,
        d_cts05g03.cgccpfdig,
        d_cts05g03.segnom,
        d_cts05g03.corsus
   from avlmlaudo
  where vstnumdig = param.vstnumdig

#---------------------------------------------------------------
# Dados do veiculo
#---------------------------------------------------------------

 select vclcoddig,
        vclanomdl,
        vcllicnum,
        vclchsinc,
        vclchsfnl,
        vclcorcod
   into d_cts05g03.vclcoddig,
        d_cts05g03.vclanomdl,
        d_cts05g03.vcllicnum,
        d_cts05g03.vclchsinc,
        d_cts05g03.vclchsfnl,
        ws.vclcorcod
   from avlmveic
  where vstnumdig = param.vstnumdig

 if d_cts05g03.vclcoddig is not null  then
    call cts15g00(d_cts05g03.vclcoddig)
        returning d_cts05g03.vcldes
 end if

#---------------------------------------------------------------
# Cor do veiculo
#---------------------------------------------------------------

 if ws.vclcorcod is not null  then
    select cpodes
      into d_cts05g03.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = ws.vclcorcod
 end if

#---------------------------------------------------------------
# Dados do corretor
#---------------------------------------------------------------

 if d_cts05g03.corsus is not null  then
    select cornom
      into d_cts05g03.cornom
      from gcaksusep, gcakcorr
     where gcaksusep.corsus   = d_cts05g03.corsus    and
           gcakcorr.corsuspcp = gcaksusep.corsuspcp
 end if

 return d_cts05g03.*

end function  ###  cts05g03
