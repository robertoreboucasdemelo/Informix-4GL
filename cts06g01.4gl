

    ---> MODULO DESATIVADO - UTILIZAR FUNCOES DO MODULO framo240 - RE  <---


#############################################################################
# Nome do Modulo: CTS06G01                                         Marcelo  #
#                                                                  Gilberto #
# Funcoes genericas - Enderecos RAMOS ELEMENTARES                  Abr/1998 #
#############################################################################

database porto

#----------------------------------------------------------------------------
 function cts06g01_endereco(param)
#----------------------------------------------------------------------------

 define param        record
    lclrsccod        like rlaklocal.lclrsccod
 end record

 define d_cts06g01   record
    endlgdtip        like rlaklocal.endlgdtip,
    endlgdnom        like rlaklocal.endlgdnom,
    endnum           like rlaklocal.endnum   ,
    endcmp           like rlaklocal.endcmp   ,
    endbrr           like rlaklocal.endbrr   ,
    endcid           like rlaklocal.endcid   ,
    ufdcod           like rlaklocal.ufdcod   ,
    endcep           like rlaklocal.endcep   ,
    endcepcmp        like rlaklocal.endcepcmp
 end record



	initialize  d_cts06g01.*  to  null

 initialize d_cts06g01.*    to null

 select endlgdtip,
        endlgdnom,
        endnum   ,
        endcmp   ,
        endbrr   ,
        endcid   ,
        ufdcod   ,
        endcep   ,
        endcepcmp
   into d_cts06g01.endlgdtip ,
        d_cts06g01.endlgdnom ,
        d_cts06g01.endnum    ,
        d_cts06g01.endcmp    ,
        d_cts06g01.endbrr    ,
        d_cts06g01.endcid    ,
        d_cts06g01.ufdcod    ,
        d_cts06g01.endcep    ,
        d_cts06g01.endcepcmp
   from rlaklocal
  where lclrsccod = param.lclrsccod

  if sqlca.sqlcode <> 0  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do local de risco. AVISE A INFORMATICA !"
  end if

 return d_cts06g01.*

end function  ###  cts06g01_endereco

#---------------------------------------------------------------
 function cts06g01_local(param)
#---------------------------------------------------------------

 define param      record
    succod         like rsamseguro.succod   ,
    ramcod         like rsamseguro.ramcod   ,
    aplnumdig      like rsamseguro.aplnumdig,
    lclrsccod      like rsdmlocal.lclrsccod
 end record

 define ws         record
    sgrorg         like rsdmdocto.sgrorg    ,
    sgrnumdig      like rsdmdocto.sgrnumdig ,
    prporg         like rsdmdocto.prporg    ,
    prpnumdig      like rsdmdocto.prpnumdig ,
    lclrsccod      like rsdmlocal.lclrsccod
 end record



	initialize  ws.*  to  null

 initialize ws.*          to null

 select sgrorg   , sgrnumdig
   into ws.sgrorg, ws.sgrnumdig
   from rsamseguro
  where succod    = param.succod    and
        ramcod    = param.ramcod    and
        aplnumdig = param.aplnumdig

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na verificacao do local de risco. AVISE A INFORMATICA!"
    return false
 end if

#------------------------------------------------------------
# Obtem origem do seguro
#------------------------------------------------------------

 select prporg   , prpnumdig
   into ws.prporg, ws.prpnumdig
   from rsdmdocto
  where sgrorg    = ws.sgrorg     and
        sgrnumdig = ws.sgrnumdig  and
        dctnumseq = (select max(dctnumseq)
                       from rsdmdocto
                      where sgrorg    = ws.sgrorg     and
                            sgrnumdig = ws.sgrnumdig  and
                            prpstt in (19,65,66,88)      and
                            prporg   <> 58 )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na verificacao do local de risco. AVISE A INFORMATICA!"
    return false
 end if

#------------------------------------------------------------
# Verifica os locais de risco encontrados
#------------------------------------------------------------

 declare  c_rsdmlocal  cursor for
   select lclrsccod
     from rsdmlocal
    where prporg    = ws.prporg    and
          prpnumdig = ws.prpnumdig

 foreach c_rsdmlocal into ws.lclrsccod

    if ws.lclrsccod = param.lclrsccod  then
       return true
       exit foreach
    end if

 end foreach

 return false

end function  ###  cts06g01_local
