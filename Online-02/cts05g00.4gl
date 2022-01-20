#############################################################################
# Nome do Modulo: CTS05G00                                         Marcelo  #
#                                                                  Gilberto #
# Monta cabecalho padrao dos laudos de servico para ramo AUTOMOVEL Jun/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 17/11/1998  PSI 6467-0   Gilberto     Retornar o codigo do veiculo para o #
#                                       cabecalho dos laudos.               #
#---------------------------------------------------------------------------#
# 04/12/1998  PSI 6478-5   Gilberto     Montar cabecalho para laudos do     #
#                                       ramo 16 (Garantia Estendida).       #
#---------------------------------------------------------------------------#
# 26/04/1999               Gilberto     Alterar SET LOCK MODE para que o    #
#                                       sistema nao pare durante reorgs.    #
#---------------------------------------------------------------------------#
# 18/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de telefone do  #
#                                       segurado, que nao eram exibidos.    #
#---------------------------------------------------------------------------#
# 30/06/2000  Correio      Akio         Pegar ultima situacao da apolice RE #
#---------------------------------------------------------------------------#
# 05/09/2002  CT 237756    Raji         Pegar ultima situacao da apol. AUTO #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 09/01/2006  CT 386731    Lucas Scheid Troca das variaveis locais g_funapol#
#                                       .succod e g_funapol.aplnumdig por   #
#                                       param.succod e param.aplnumdig na   #
#                                       busca do numero do endosso.         #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


#----------------------------------------------------------------------------
 function cts05g00(param)
#----------------------------------------------------------------------------

 define param        record
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig
 end record

 define d_cts05g00   record
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
    vclcordes        char (12)
 end record

 define ws           record
    segnumdig        like abbmdoc.segnumdig,
    dctnumseq        like abbmveic.dctnumseq,
    vsttip           like abbmveic.vsttip,
    vstnumdig        like abbmveic.vstnumdig,
    vclcorcod        like datmservico.vclcorcod,
    vclchsnum        like rgrmgrevcl.vclchsnum,
    sgrorg           like rsamseguro.sgrorg,
    sgrnumdig        like rsamseguro.sgrnumdig,
    prporg           like rsdmdocto.prporg,
    prpnumdig        like rsdmdocto.prpnumdig,
    edsnumref        like abamdoc.edsnumref
 end record



        initialize  d_cts05g00.*  to  null

        initialize  ws.*  to  null

 initialize d_cts05g00.*  to null
 initialize ws.*          to null

#---------------------------------------------------------------
# Nome do convenio
#---------------------------------------------------------------
 ## variavel inicializada em ctq00m01.4gl (APOIO)

 if g_documento.ligcvntip is null then
    let g_documento.ligcvntip = 0
 end if

 select cpodes
   into d_cts05g00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 if param.succod    is null  or
    param.ramcod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return d_cts05g00.*
 end if

 if param.ramcod = 31     or
    param.ramcod = 531  then
    call f_funapol_ultima_situacao
         (param.succod, param.aplnumdig, param.itmnumdig)
         returning g_funapol.*

    if g_funapol.dctnumseq is null  then
       select min(dctnumseq)
         into g_funapol.dctnumseq
         from abbmdoc
        where succod    = param.succod
          and aplnumdig = param.aplnumdig
          and itmnumdig = param.itmnumdig
    end if

    #--------------------------------------------------------------------------
    # Numero do endosso
    #--------------------------------------------------------------------------

    # --> CT 386731
    select edsnumdig
      into ws.edsnumref
      from abamdoc
     where abamdoc.succod    = param.succod    and
           abamdoc.aplnumdig = param.aplnumdig and
           abamdoc.dctnumseq = g_funapol.dctnumseq

    # --> CT 386731
    #select edsnumdig
    #  into ws.edsnumref
    #  from abamdoc
    # where abamdoc.succod    =  g_documento.succod      and
    #       abamdoc.aplnumdig =  g_documento.aplnumdig   and
    #       abamdoc.dctnumseq =  g_funapol.dctnumseq

    if sqlca.sqlcode = notfound  then
       let ws.edsnumref = 0
    end if

    #--------------------------------------------------------------------------
    # Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
    #--------------------------------------------------------------------------
    if g_funapol.resultado = "O"  then
       call f_funapol_auto(param.succod   , param.aplnumdig,
                           param.itmnumdig, ws.edsnumref)
                 returning g_funapol.*
    end if

    select segnumdig
      into ws.segnumdig
      from abbmdoc
     where succod    = param.succod    and
           aplnumdig = param.aplnumdig and
           itmnumdig = param.itmnumdig and
           dctnumseq = g_funapol.dctnumseq

    select corsus
      into d_cts05g00.corsus
      from abamcor
     where succod    = param.succod      and
           aplnumdig = param.aplnumdig   and
           corlidflg = "S"

#---------------------------------------------------------------
# Dados do veiculo
#---------------------------------------------------------------

    select vclcoddig,
           vclanomdl,
           vcllicnum,
           vclchsinc,
           vclchsfnl,
           vstnumdig,
           vsttip
      into d_cts05g00.vclcoddig,
           d_cts05g00.vclanomdl,
           d_cts05g00.vcllicnum,
           d_cts05g00.vclchsinc,
           d_cts05g00.vclchsfnl,
           ws.vstnumdig        ,
           ws.vsttip
      from abbmveic
     where succod    = param.succod       and
           aplnumdig = param.aplnumdig    and
           itmnumdig = param.itmnumdig    and
           dctnumseq = g_funapol.vclsitatu

    if sqlca.sqlcode = notfound  then
       select vclcoddig,
              vclanomdl,
              vcllicnum,
              vclchsinc,
              vclchsfnl,
              vstnumdig,
              vsttip
         into d_cts05g00.vclcoddig,
              d_cts05g00.vclanomdl,
              d_cts05g00.vcllicnum,
              d_cts05g00.vclchsinc,
              d_cts05g00.vclchsfnl,
              ws.vstnumdig        ,
              ws.vsttip
         from abbmveic
        where succod    = param.succod       and
              aplnumdig = param.aplnumdig    and
              itmnumdig = param.itmnumdig    and
              dctnumseq = (select max(dctnumseq)
                             from abbmveic
                            where succod    = param.succod       and
                                  aplnumdig = param.aplnumdig    and
                                  itmnumdig = param.itmnumdig)
    end if

#---------------------------------------------------------------
# Cor do veiculo
#---------------------------------------------------------------

    initialize ws.vclcorcod  to null

    whenever error continue
    set lock mode to not wait

    if ws.vsttip  =  "V"         and      ### VISTORIA PREVIA
       ws.vstnumdig is not null  then

       select vclcorcod
         into ws.vclcorcod
         from avlmveic
        where vstnumdig = ws.vstnumdig

    end if

    if ws.vsttip  =  "C"         and      ### COBERTURA PROVISORIA
       ws.vstnumdig is not null  then

       select vclcorcod
         into ws.vclcorcod
         from avbmveic
        where cbpnum = ws.vstnumdig

    end if

    whenever error stop
    set lock mode to wait
 end if

 if param.ramcod <> 31    and
    param.ramcod <> 531  then
    select sgrorg, sgrnumdig
      into ws.sgrorg,
           ws.sgrnumdig
      from rsamseguro
     where succod    = param.succod     and
           ramcod    = param.ramcod     and
           aplnumdig = param.aplnumdig

    if sqlca.sqlcode = 0  then
       select prporg   ,
              prpnumdig,
              segnumdig
         into ws.prporg   ,
              ws.prpnumdig,
              ws.segnumdig
         from rsdmdocto
        where sgrorg    = ws.sgrorg     and
              sgrnumdig = ws.sgrnumdig  and
              dctnumseq = (select max(dctnumseq)
                             from rsdmdocto
                            where sgrorg     = ws.sgrorg     and
                                  sgrnumdig  = ws.sgrnumdig  and
                                 ( prpstt     in (19,65,66,88) and
                                   edsstt     <> "C"         or
                                   dctnumseq = 1               ))

       select corsus
         into d_cts05g00.corsus
         from rsampcorre
        where sgrorg    = ws.sgrorg     and
              sgrnumdig = ws.sgrnumdig  and
              corlidflg = "S"
    end if

    if param.ramcod = 16    or
       param.ramcod = 524 then
       select vclcoddig, vcllicnum,
              vclchsnum, vclanomdl
         into d_cts05g00.vclcoddig,
              d_cts05g00.vcllicnum,
              ws.vclchsnum,
              d_cts05g00.vclanomdl
         from rgrmgrevcl
        where prporg    = ws.prporg     and
              prpnumdig = ws.prpnumdig  and
              itmseq    = 1

       let d_cts05g00.vclchsinc = ws.vclchsnum[01,12]
       let d_cts05g00.vclchsfnl = ws.vclchsnum[13,20]
    end if
 end if

 if ws.vclcorcod is not null  then
    select cpodes
      into d_cts05g00.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = ws.vclcorcod
 end if

#---------------------------------------------------------------
# Dados do segurado
#---------------------------------------------------------------

 if ws.segnumdig is not null  then
    select segnom
      into d_cts05g00.segnom
      from gsakseg
     where segnumdig  =  ws.segnumdig
 end if

#---------------------------------------------------------------
# Dados do corretor
#---------------------------------------------------------------

 if d_cts05g00.corsus is not null  then
    select cornom
      into d_cts05g00.cornom
      from gcaksusep, gcakcorr
     where gcaksusep.corsus   = d_cts05g00.corsus    and
           gcakcorr.corsuspcp = gcaksusep.corsuspcp
 end if

 if d_cts05g00.vclcoddig is not null  then
    call cts15g00(d_cts05g00.vclcoddig)
        returning d_cts05g00.vcldes
 end if

 return d_cts05g00.*

end function  ###  cts05g00
