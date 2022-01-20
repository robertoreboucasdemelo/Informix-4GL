#############################################################################
# Nome do Modulo: CTS05G02                                         Marcelo  #
#                                                                  Gilberto #
# Monta cabecalho padrao dos laudos de servico para PORTO CARD     Dez/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#############################################################################

 database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------------------
 function cts05g02(param)
#----------------------------------------------------------------------------

 define param        record
    pcacarnum        like eccmpti.pcapticod,
    pcaprpitm        like epcmitem.pcaprpitm
 end record

 define d_cts05g02   record
    pcacttnom        like eccmcli.pcaclinom,
    corsus           like datmservico.corsus    ,
    cornom           like datmservico.cornom    ,
    cvnnom           char (20)                  ,
    vclcoddig        like datmservico.vclcoddig ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    vclchsinc        like abbmveic.vclchsinc    ,
    vclchsfnl        like abbmveic.vclchsfnl    ,
    vclcordes        char (12)
 end record

 define ws           record
    pcacttnum        like eccmpti.pcapticod,
    pcaprpnum        like epcmproposta.pcaprpnum,
    vclcorcod        like datmservico.vclcorcod,
    pcactacod        like eccmpti.pcactacod,
    pcaclicod        like eccmcta.pcaclicod
 end record



	initialize  d_cts05g02.*  to  null

	initialize  ws.*  to  null

 initialize d_cts05g02.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Nome do convenio
#---------------------------------------------------------------

 select cpodes
   into d_cts05g02.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 if param.pcacarnum is null then
    return d_cts05g02.*
 end if

select pcapticod
  into ws.pcacttnum
  from eccmpti
 where pcapticod  = param.pcacarnum

 if sqlca.sqlcode = notfound  then
    error " Cartao titular nao cadastrado. AVISE A INFORMATICA!"
    initialize d_cts05g02.*  to null
    return d_cts05g02.*
 end if

 select pcactacod
   into ws.pcactacod
   from eccmpti
  where pcapticod = ws.pcacttnum

 select pcaclicod
   into ws.pcaclicod
   from eccmcta
  where pcactacod = ws.pcactacod

 select pcaclinom, corsus
   into d_cts05g02.pcacttnom,
        d_cts05g02.corsus
   from eccmcli
  where pcaclicod = ws.pcaclicod

 if sqlca.sqlcode = notfound  then
    error " Contrato nao encontrado. AVISE A INFORMATICA!"
    initialize d_cts05g02.*  to null
    return d_cts05g02.*
 end if

 call cpcgeral9(ws.pcacttnum) returning ws.pcaprpnum
 if ws.pcaprpnum is null  then
    error " Numero/digito da proposta invalido! AVISE A INFORMATICA!"
    initialize d_cts05g02.*  to null
    return d_cts05g02.*
 end if

#---------------------------------------------------------------
# Dados do veiculo
#---------------------------------------------------------------

 select vclcoddig,
        vclanomdl,
        vcllicnum,
        vclcorcod
   into d_cts05g02.vclcoddig,
        d_cts05g02.vclanomdl,
        d_cts05g02.vcllicnum,
        ws.vclcorcod
   from epcmitem
  where pcaprpnum = ws.pcaprpnum

 if d_cts05g02.vclcoddig is not null  then
    call cts15g00(d_cts05g02.vclcoddig)
        returning d_cts05g02.vcldes
 end if

#---------------------------------------------------------------
# Cor do veiculo
#---------------------------------------------------------------

 if ws.vclcorcod is not null  then
    select cpodes
      into d_cts05g02.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = ws.vclcorcod
 end if

#---------------------------------------------------------------
# Dados do corretor
#---------------------------------------------------------------

 if d_cts05g02.corsus is not null  then
    select cornom
      into d_cts05g02.cornom
      from gcaksusep, gcakcorr
     where gcaksusep.corsus   = d_cts05g02.corsus    and
           gcakcorr.corsuspcp = gcaksusep.corsuspcp
 end if

 return d_cts05g02.*

end function  ###  cts05g02
