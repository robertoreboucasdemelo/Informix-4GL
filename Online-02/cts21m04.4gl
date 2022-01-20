

  ---> MODULO DESATIVADO - UTILIZAR FUNCOES DO MODULO framc215 - RE  <---


#############################################################################
# Nome do Modulo: CTS21M04                                         Marcelo  #
#                                                                  Gilberto #
# Pop-up - Locais de risco para apolices Ramos Elementares         Nov/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  Probl.Ident  Gilberto     Corrigir ultimo retorno que nao re- #
#                                       tornava duas variaveis.             #
#############################################################################


 database porto

#-----------------------------------------------------
 function cts21m04(param)
#-----------------------------------------------------

 define param       record
    succod          like rsamseguro.succod   ,
    ramcod          like rsamseguro.ramcod   ,
    aplnumdig       like rsamseguro.aplnumdig
 end record

 define ws          record
    sgrorg          like rsdmdocto.sgrorg,
    sgrnumdig       like rsdmdocto.sgrnumdig,
    prporg          like rsdmdocto.prporg,
    prpnumdig       like rsdmdocto.prpnumdig,
    endcmp          like rlaklocal.endcmp,
    lclstt          like rsdmlocal.lclstt
 end record

 define a_cts21m04  array[100]  of record
    lgdtxt          char (45),
    brrnom          like datmlcl.brrnom,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    lgdcep          like datmlcl.lgdcep,
    lgdcepcmp       like datmlcl.lgdcepcmp,
    lclrsccod       like rsdmlocal.lclrsccod,
    locdes          char(5),
    lclnumseq       like rsdmlocal.lclnumseq,
    lgdtip          like datmlcl.lgdtip,
    lgdnom          like datmlcl.lgdnom,
    lgdnum          like datmlcl.lgdnum
 end record

 define arr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to 100 
		initialize  a_cts21m04[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_cts21m04  to null
 initialize ws.*        to null

 let arr_aux = 1

 select sgrorg   , sgrnumdig
   into ws.sgrorg, ws.sgrnumdig
   from rsamseguro
  where succod    = param.succod
    and ramcod    = param.ramcod
    and aplnumdig = param.aplnumdig

 if sqlca.sqlcode <> 0  then
    error "Erro (", sqlca.sqlcode, ") na localizacao do seguro. AVISE A INFORMATICA!"
    return a_cts21m04[arr_aux].lclrsccod,
           a_cts21m04[arr_aux].lgdtip   ,
           a_cts21m04[arr_aux].lgdnom   ,
           a_cts21m04[arr_aux].lgdnum   ,
           a_cts21m04[arr_aux].brrnom   ,
           a_cts21m04[arr_aux].cidnom   ,
           a_cts21m04[arr_aux].ufdcod   ,
           a_cts21m04[arr_aux].lgdcep   ,
           a_cts21m04[arr_aux].lgdcepcmp
 end if

 select prporg   , prpnumdig
   into ws.prporg, ws.prpnumdig
   from rsdmdocto
  where sgrorg    = ws.sgrorg
    and sgrnumdig = ws.sgrnumdig
    and dctnumseq = (select max(dctnumseq)
                       from rsdmdocto
                      where sgrorg    = ws.sgrorg
                        and sgrnumdig = ws.sgrnumdig
                        and prpstt   in (19,65,66,88)
                        and prporg   <> 58 )

 if sqlca.sqlcode <> 0  then
    error "Erro (", sqlca.sqlcode, ") na localizacao do documento. AVISE A INFORMATICA!"
    return a_cts21m04[arr_aux].lclrsccod,
           a_cts21m04[arr_aux].lgdtip   ,
           a_cts21m04[arr_aux].lgdnom   ,
           a_cts21m04[arr_aux].lgdnum   ,
           a_cts21m04[arr_aux].brrnom   ,
           a_cts21m04[arr_aux].cidnom   ,
           a_cts21m04[arr_aux].ufdcod   ,
           a_cts21m04[arr_aux].lgdcep   ,
           a_cts21m04[arr_aux].lgdcepcmp
 end if

 declare c_cts21m04  cursor for
    select lclrsccod, lclnumseq, lclstt
      from rsdmlocal
     where prporg    = ws.prporg
       and prpnumdig = ws.prpnumdig

 foreach  c_cts21m04  into a_cts21m04[arr_aux].lclrsccod,
                           a_cts21m04[arr_aux].lclnumseq,
                           ws.lclstt
     if ws.lclstt <> "A"  then  # considerar os locais ativos
        continue foreach        # Terezinha, 13/01/03.
     end if
     let a_cts21m04[arr_aux].locdes = "Local"
     select endlgdtip ,
            endlgdnom ,
            endnum    ,
            endcmp    ,
            endbrr    ,
            endcid    ,
            ufdcod    ,
            endcep    ,
            endcepcmp
       into a_cts21m04[arr_aux].lgdtip ,
            a_cts21m04[arr_aux].lgdnom ,
            a_cts21m04[arr_aux].lgdnum,
            ws.endcmp,
            a_cts21m04[arr_aux].brrnom,
            a_cts21m04[arr_aux].cidnom,
            a_cts21m04[arr_aux].ufdcod,
            a_cts21m04[arr_aux].lgdcep,
            a_cts21m04[arr_aux].lgdcepcmp
       from rlaklocal
      where lclrsccod = a_cts21m04[arr_aux].lclrsccod

     if sqlca.sqlcode = notfound  then
        continue foreach
     end if

     call frama185_end (a_cts21m04[arr_aux].lgdtip,
                        a_cts21m04[arr_aux].lgdnom,
                        a_cts21m04[arr_aux].lgdnum,
                        ws.endcmp,
                        "", "", "", "")
           returning a_cts21m04[arr_aux].lgdtxt

     let arr_aux = arr_aux + 1
     if arr_aux > 100  then
        error " Limite excedido. Apolice com mais de 100 locais de risco!"
        exit foreach
     end if
 end foreach

 if arr_aux > 1  then
    open window w_cts21m04 at 08,08 with form "cts21m04"
                           attribute(form line first, border)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(arr_aux-1)
     let int_flag = false

     display array a_cts21m04  to  s_cts21m04.*
        on key (interrupt)
           initialize a_cts21m04[arr_aux].* to null
           exit display

        on key (F8)
           let arr_aux = arr_curr()
           exit display
     end display

     close window w_cts21m04
 else
    error " Nao foi encontrado nenhum local de risco!"
 end if

 return a_cts21m04[arr_aux].lclrsccod,
        a_cts21m04[arr_aux].lgdtip   ,
        a_cts21m04[arr_aux].lgdnom   ,
        a_cts21m04[arr_aux].lgdnum   ,
        a_cts21m04[arr_aux].brrnom   ,
        a_cts21m04[arr_aux].cidnom   ,
        a_cts21m04[arr_aux].ufdcod   ,
        a_cts21m04[arr_aux].lgdcep   ,
        a_cts21m04[arr_aux].lgdcepcmp

end function  ###  cts21m04
