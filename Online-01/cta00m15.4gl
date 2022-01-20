#############################################################################
# Nome do Modulo: cta00m15                                         Marcelo  #
#                                                                  Gilberto #
# Localizacao de documento (R.E.) por proposta                     Dez/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################


database porto

#---------------------------------------------------------------
 function cta00m15(param)
#---------------------------------------------------------------

 define param         record
    prporg            like rsdmdocto.prporg,
    prpnumdig         like rsdmdocto.prpnumdig
 end record

 define ws            record
    succod            like rsamseguro.succod,
    ramcod            like rsamseguro.ramcod,
    aplnumdig         like rsamseguro.aplnumdig,
    sgrorg            like rsdmdocto.sgrorg,
    sgrnumdig         like rsdmdocto.sgrnumdig,
    prpstt            like rsdmdocto.prpstt
 end record



	initialize  ws.*  to  null

 initialize ws.* to null

 select sgrorg, sgrnumdig, prpstt
   into ws.sgrorg,
        ws.sgrnumdig,
        ws.prpstt
   from rsdmdocto
  where prporg    = param.prporg
    and prpnumdig = param.prpnumdig

 if sqlca.sqlcode = notfound   then
    error " Proposta nao cadastrada!"
    return ws.succod, ws.ramcod, ws.aplnumdig
 end if

 if ws.prpstt <> 19  and  -- Emitida
    ws.prpstt <> 65  and  -- Emitida, pedente de vinculacao titulo capitalizacao
    ws.prpstt <> 66  and  -- Emitida, pedente de interface com Comissoes
    ws.prpstt <> 88  then -- Emitida, pendente de impressao de front de apolice

    error " Apolice nao esta' com situacao emitida!"
    return ws.succod, ws.ramcod, ws.aplnumdig
 end if

 select succod,
        ramcod,
        aplnumdig
   into ws.succod,
        ws.ramcod,
        ws.aplnumdig
   from rsamseguro
  where sgrorg    = ws.sgrorg      and
        sgrnumdig = ws.sgrnumdig

 if sqlca.sqlcode = notfound  then
    error " Proposta nao cadastrada!"
    return ws.succod, ws.ramcod, ws.aplnumdig
 end if

 return ws.succod, ws.ramcod, ws.aplnumdig

end function  ###  cta00m15
