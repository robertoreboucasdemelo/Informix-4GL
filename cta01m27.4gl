#############################################################################
# Nome do Modulo: cta01m27                                         Marcelo  #
#                                                                  Gilberto #
# Pesquisa apolice por licenca - Garantia estendida (ramo 16)      Out/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/06/1999  Pdm #23185   Gilberto     Pesquisar somente documentos emiti- #
#                                       dos (status 19,66,88)               #
# 22/04/2003  PSI.168920   Aguinaldo Costa   Resolucao 86
#############################################################################


database porto

#------------------------------------------------------------------------------
 function cta01m27(param)
#------------------------------------------------------------------------------

 define param    record
    vcllicnum    like rgrmgrevcl.vcllicnum
 end record

 define a_cta01m27 array[100] of record
    succod       like rsamseguro.succod,
    aplnumdig    like rsamseguro.aplnumdig,
    viginc       like rsdmdocto.viginc,
    vigfnl       like rsdmdocto.vigfnl,
    segnom       like gsakseg.segnom,
    ramcod       like rsamseguro.ramcod
 end record

 define ws       record
    ramcod       like rsamseguro.ramcod,
    succod       like rsamseguro.succod,
    aplnumdig    like rsamseguro.aplnumdig,
    segnumdig    like rsdmdocto.segnumdig,
    sgrorg       like rsdmdocto.sgrorg,
    sgrnumdig    like rsdmdocto.sgrnumdig
 end record

 define arr_aux  integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cta01m27[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*        to null
 initialize a_cta01m27  to null
 let int_flag = false
 let arr_aux  = 1

 message " Aguarde, pesquisando..." attribute (reverse)

 declare c_cta01m27_001  cursor for
   select rsdmdocto.sgrorg,
          rsdmdocto.sgrnumdig,
          rsdmdocto.segnumdig
    from  rgrmgrevcl, rsdmdocto
    where rgrmgrevcl.vcllicnum  =  param.vcllicnum       and
          rsdmdocto.prporg      =  rgrmgrevcl.prporg     and
          rsdmdocto.prpnumdig   =  rgrmgrevcl.prpnumdig  and
          rsdmdocto.prpstt     in  (19,65,66,88)

 foreach c_cta01m27_001  into  ws.sgrorg,
                           ws.sgrnumdig,
                           ws.segnumdig

   select ramcod, succod, aplnumdig
     into a_cta01m27[arr_aux].ramcod,
          a_cta01m27[arr_aux].succod,
          a_cta01m27[arr_aux].aplnumdig
     from rsamseguro
    where sgrorg     =  ws.sgrorg      and
          sgrnumdig  =  ws.sgrnumdig

   if sqlca.sqlcode  =  100   or
      (a_cta01m27[arr_aux].ramcod <> 16   and
       a_cta01m27[arr_aux].ramcod <> 524) then
      continue foreach
   end if

   select viginc, vigfnl
     into a_cta01m27[arr_aux].viginc,
          a_cta01m27[arr_aux].vigfnl
     from rsdmdocto
    where sgrorg     =  ws.sgrorg      and
          sgrnumdig  =  ws.sgrnumdig   and
          dctnumseq  =  1

   if sqlca.sqlcode  =  100   then
      continue foreach
   end if

   select segnom
     into a_cta01m27[arr_aux].segnom
     from gsakseg
    where gsakseg.segnumdig  =  ws.segnumdig

   if sqlca.sqlcode  =  100   then
      continue foreach
   end if

   let arr_aux = arr_aux + 1
   if arr_aux  >  100   then
      error " Limite excedido, existem mais de 100 veiculos c/ essa licenca!"
      exit foreach
   end if

 end foreach

 initialize ws.*  to null
 message " "

 if arr_aux > 2  then
    open window w_cta01m27 at 09,02 with form "cta01m27"
         attribute(form line first)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_cta01m27 to s_cta01m27.*
      on key (F8)
         let arr_aux      = arr_curr()
         let ws.succod    = a_cta01m27[arr_aux].succod
         let ws.aplnumdig = a_cta01m27[arr_aux].aplnumdig
         let ws.ramcod    = a_cta01m27[arr_aux].ramcod
         exit display

      on key (interrupt)
         let int_flag = false
         initialize ws.*  to null
         exit display
    end display

    close window w_cta01m27
 else
    if arr_aux = 2  then
       let ws.succod    = a_cta01m27[arr_aux-1].succod
       let ws.aplnumdig = a_cta01m27[arr_aux-1].aplnumdig
       let ws.ramcod    = a_cta01m27[arr_aux-1].ramcod
    end if
 end if

 let int_flag = false

 return ws.succod, ws.aplnumdig, ws.ramcod

end function     #-- cta01m27
