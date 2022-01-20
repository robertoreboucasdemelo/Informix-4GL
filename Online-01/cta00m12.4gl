###############################################################################
# Nome do Modulo: CTA00M12                                           Pedro    #
#                                                                    Marcelo  #
# Mostra Todos Itens da Apolice (AUTO)                               Dez/1994 #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
function cta00m12()
#------------------------------------------------------------------------------

 define t_cta00m12 array[500] of record
  lixo      char (01)              ,
  itmnumdig like abbmitem.itmnumdig,
  vcldes    char (25)              ,
  vclchs    like abbmveic.vclchsfnl
 end record

 define bd_abbmitem record
  itmnumdig like abbmitem.itmnumdig,
  itmsttatu like abbmitem.itmsttatu
 end record

 define bd_abbmdoc record
  itmnumdig like abbmdoc.itmnumdig,
  dctnumseq like abbmdoc.dctnumseq
 end record

 define bd_abamdoc record
  edsnumdig like abamdoc.edsnumdig
 end record

 define bd_abbmveic record
  vclcoddig like abbmveic.vclcoddig,
  vclchsfnl like abbmveic.vclchsfnl
 end record

 define bd_agbkveic record
  vclmrccod like agbkveic.vclmrccod,
  vcltipcod like agbkveic.vcltipcod,
  vclmdlnom like agbkveic.vclmdlnom
 end record

 define bd_agbkmarca record
  vclmrcnom like agbkmarca.vclmrcnom
 end record

 define bd_agbktip record
  vcltipnom like agbktip.vcltipnom
 end record

 define arr_aux integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  t_cta00m12[w_pf1].*  to  null
	end	for

	initialize  bd_abbmitem.*  to  null

	initialize  bd_abbmdoc.*  to  null

	initialize  bd_abamdoc.*  to  null

	initialize  bd_abbmveic.*  to  null

	initialize  bd_agbkveic.*  to  null

	initialize  bd_agbkmarca.*  to  null

	initialize  bd_agbktip.*  to  null

 let arr_aux = 0
 let int_flag = false

 open window cta00m12 at 09,28 with form "cta00m12"
             attribute(border, form line first)

 declare c_cta00m12_001 cursor for
 select itmnumdig,
	max(dctnumseq)
  from  abbmdoc
 where  abbmdoc.succod    = g_dctoarray[g_index].succod    and
        abbmdoc.aplnumdig = g_dctoarray[g_index].aplnumdig
 group  by 1
 order  by 1

{  select itmnumdig,
         dctnumseq
   from  abbmdoc
   where abbmdoc.succod    = g_dctoarray[g_index].succod    and
         abbmdoc.aplnumdig = g_dctoarray[g_index].aplnumdig  --and
--         abbmdoc.dctnumseq = g_dctoarray[g_index].dctnumseq
}

 foreach c_cta00m12_001 into bd_abbmdoc.*

  let arr_aux = arr_aux + 1

  if arr_aux > 500 then
     let arr_aux = 500
     error "Documento com mais de 500 itens!"
     exit foreach
  end if

  select itmnumdig,
         itmsttatu
   into  bd_abbmitem.*
   from  abbmitem
   where abbmitem.succod    = g_dctoarray[g_index].succod    and
         abbmitem.aplnumdig = g_dctoarray[g_index].aplnumdig and
         abbmitem.itmnumdig = bd_abbmdoc.itmnumdig

  let t_cta00m12[arr_aux].itmnumdig = bd_abbmitem.itmnumdig

  select edsnumdig
   into  bd_abamdoc.*
   from  abamdoc
   where abamdoc.succod    = g_dctoarray[g_index].succod    and
         abamdoc.aplnumdig = g_dctoarray[g_index].aplnumdig and
      ## abamdoc.dctnumseq = g_dctoarray[g_index].dctnumseq
         abamdoc.dctnumseq = bd_abbmdoc.dctnumseq

  call F_FUNAPOL_AUTO(g_dctoarray[g_index].succod   ,
                      g_dctoarray[g_index].aplnumdig,
                      bd_abbmitem.itmnumdig         ,
                      bd_abamdoc.edsnumdig)
   returning g_funapol.*

 #call F_FUNAPOL_ULTIMA_SITUACAO(g_dctoarray[g_index].succod,
 #                               g_dctoarray[g_index].aplnumdig,
 #                               bd_abbmitem.itmnumdig)
 # returning g_funapol.*

  let g_dctoarray[g_index].dctnumseq = g_funapol.dctnumseq

  select vclcoddig,
         vclchsfnl
   into  bd_abbmveic.*
   from  abbmveic
   where abbmveic.succod    = g_dctoarray[g_index].succod    and
         abbmveic.aplnumdig = g_dctoarray[g_index].aplnumdig and
         abbmveic.itmnumdig = bd_abbmitem.itmnumdig          and
         abbmveic.dctnumseq = g_funapol.vclsitatu

  if status <> notfound then
     select vclmrccod,
            vcltipcod,
            vclmdlnom
      into  bd_agbkveic.*
      from  agbkveic
      where agbkveic.vclcoddig = bd_abbmveic.vclcoddig

     select vclmrcnom
      into  bd_agbkmarca.*
      from  agbkmarca
      where agbkmarca.vclmrccod = bd_agbkveic.vclmrccod

     select vcltipnom
      into  bd_agbktip.*
      from  agbktip
      where agbktip.vclmrccod = bd_agbkveic.vclmrccod and
            agbktip.vcltipcod = bd_agbkveic.vcltipcod

     let t_cta00m12[arr_aux].vcldes    = bd_agbkmarca.vclmrcnom clipped," ",
                                         bd_agbktip.vcltipnom   clipped," ",
                                         bd_agbkveic.vclmdlnom
     let t_cta00m12[arr_aux].vclchs    = bd_abbmveic.vclchsfnl
  end if

  if bd_abbmitem.itmsttatu <> "A" then
     let t_cta00m12[arr_aux].vcldes = "CANCELADO"
     let t_cta00m12[arr_aux].vclchs = "        "
  end if

  if int_flag then
     error "Operacao cancelada!"
     close window cta00m12
     let int_flag = false
     return
  end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"

 call set_count(arr_aux)

 display array t_cta00m12 to s_cta00m12.*
  on key (interrupt)
   exit display

  on key(F8)
   let arr_aux = arr_curr()
   let g_dctoarray[g_index].itmnumdig = t_cta00m12[arr_aux].itmnumdig

#  call F_FUNAPOL_ULTIMA_SITUACAO(g_dctoarray[g_index].succod,
#                                 g_dctoarray[g_index].aplnumdig,
#                                 g_dctoarray[g_index].itmnumdig)
#   returning g_funapol.*
#
#  select edsnumdig
#   into  bd_abamdoc.*
#   from  abamdoc
#   where abamdoc.succod    = g_dctoarray[g_index].succod    and
#         abamdoc.aplnumdig = g_dctoarray[g_index].aplnumdig and
#         abamdoc.dctnumseq = g_funapol.dctnumseq

   select edsnumdig
    into  bd_abamdoc.*
    from  abamdoc
    where abamdoc.succod    = g_dctoarray[g_index].succod    and
          abamdoc.aplnumdig = g_dctoarray[g_index].aplnumdig and
          abamdoc.dctnumseq = g_dctoarray[g_index].dctnumseq

   let g_documento.succod    = g_dctoarray[g_index].succod
   let g_documento.aplnumdig = g_dctoarray[g_index].aplnumdig
   let g_documento.itmnumdig = t_cta00m12[arr_aux].itmnumdig
   let g_documento.edsnumref = bd_abamdoc.edsnumdig
   initialize g_funapol.* to null
   exit display
 end display

 if int_flag then
    let g_dctoarray[g_index].itmnumdig = 0
    initialize g_funapol   to null
 end if

 close window cta00m12

 let int_flag = false

end function #---- fim cta00m12
