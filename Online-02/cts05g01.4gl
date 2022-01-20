#############################################################################
# Nome do Modulo: CTS05G01                                         Marcelo  #
#                                                                  Gilberto #
# Cabecalho padrao dos laudos de servico para RAMOS ELEMENTARES    Abr/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA       SOLICITACAO  RESPONSAVEL    DESCRICAO                          #
#---------------------------------------------------------------------------#
# 20/08/1999 PSI 5593-1   Gilberto       Retirar os campos DDD e telefone   #
#                                        do cabecalho.                      #
#---------------------------------------------------------------------------#
# 21/07/2008              Carla Rampazzo Nao mostrar error/display/ quando  #
#                                        qdo for chamado pelo Portal do     #
#                                        Segurado                           #
#############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------------------
 function cts05g01(param)
#----------------------------------------------------------------------------

 define param        record
    succod           like rsamseguro.succod  ,
    ramcod           like rsamseguro.ramcod  ,
    aplnumdig        like rsamseguro.aplnumdig
 end record

 define d_cts05g01   record
    segnom           like gsakseg.segnom    ,
    cornom           like gcakcorr.cornom   ,
    corsus           like gcaksusep.corsus  ,
    cvnnom           char (20)              ,
    viginc           like rsdmdocto.viginc  ,
    vigfnl           like rsdmdocto.vigfnl
 end record

 define ws           record
    segnumdig        like abbmdoc.segnumdig   ,
    sgrorg           like rsamseguro.sgrorg   ,
    sgrnumdig        like rsamseguro.sgrnumdig
 end record

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------



	initialize  d_cts05g01.*  to  null

	initialize  ws.*  to  null

 initialize d_cts05g01.*  to null
 initialize ws.*          to null

 if param.succod    is null  or
    param.ramcod    is null  or
    param.aplnumdig is null  then
    return d_cts05g01.*
 end if

#---------------------------------------------------------------
# Nome do convenio
#---------------------------------------------------------------

 select cpodes
   into d_cts05g01.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 select sgrorg, sgrnumdig
   into ws.sgrorg, ws.sgrnumdig
   from rsamseguro
  where succod    =  param.succod     and
        ramcod    =  param.ramcod     and
        aplnumdig =  param.aplnumdig

 if sqlca.sqlcode  < 0   then
    if g_origem is null  or
       g_origem =  "IFX" then
       error "Erro (", sqlca.sqlcode, ") na localizacao da apolice! AVISE A INFORMATICA!"
    end if
    return d_cts05g01.*
 end if

#---------------------------------------------------------------
# Dados de vigencia da apolice - Sempre do dctnumseq = 1
#---------------------------------------------------------------

 select viginc, vigfnl
   into d_cts05g01.viginc,
        d_cts05g01.vigfnl
   from rsdmdocto
  where sgrorg    = ws.sgrorg     and
        sgrnumdig = ws.sgrnumdig  and
        dctnumseq = 1

 if sqlca.sqlcode  < 0   then
    if g_origem is null  or
       g_origem =  "IFX" then
       error " Erro (", sqlca.sqlcode, ") na leitura do documento! AVISE A INFORMATICA!"
    end if
    return d_cts05g01.*
 end if

#---------------------------------------------------------------
# Dados do segurado - ultima situacao
#---------------------------------------------------------------

 select segnumdig
   into ws.segnumdig
   from rsdmdocto
        where sgrorg    = ws.sgrorg
          and sgrnumdig = ws.sgrnumdig
          and dctnumseq = (select max(dctnumseq)
                             from rsdmdocto
                            where sgrorg     = ws.sgrorg     and
                                  sgrnumdig  = ws.sgrnumdig  and
                                 ( prpstt     in (19,65,66,88) and
                                   edsstt     <> "C"         or
                                   dctnumseq = 1               ))


 if sqlca.sqlcode  < 0   then
    if g_origem is null  or
       g_origem =  "IFX" then
       error " Erro (", sqlca.sqlcode, ") na leitura do documento! AVISE A INFORMATICA!"
    end if
    return d_cts05g01.*
 else
    select segnom
      into d_cts05g01.segnom
      from gsakseg
     where segnumdig  =  ws.segnumdig
 end if

#---------------------------------------------------------------
# Dados do corretor
#---------------------------------------------------------------

 select corsus
   into d_cts05g01.corsus
   from rsampcorre
  where sgrorg    = ws.sgrorg      and
        sgrnumdig = ws.sgrnumdig   and
        corlidflg = "S"

 if sqlca.sqlcode  < 0   then
    if g_origem is null  or
       g_origem =  "IFX" then
       error "Erro (", sqlca.sqlcode, ") na localizacao do corretor. AVISE A INFORMATICA!"
     end if
    return d_cts05g01.*
 else
    select cornom
      into d_cts05g01.cornom
      from gcaksusep, gcakcorr
     where gcaksusep.corsus   = d_cts05g01.corsus    and
           gcakcorr.corsuspcp = gcaksusep.corsuspcp
 end if

 return d_cts05g01.*

end function  ###  cts05g01
