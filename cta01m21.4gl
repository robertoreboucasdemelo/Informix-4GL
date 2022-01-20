###############################################################################
# Nome do Modulo: CTA01M21                                            Marcelo #
#                                                                       Pedro #
# Consulta todos os locais apolice de RE                             Mar/1995 #
###############################################################################

database porto

#globals  "/homedsa/fontes/ct24h/producao/glct.4gl"
 globals "/homedsa/projetos/geral/globals/glct.4gl" 
#-------------------------------------------------------------------------------
function cta01m21(par_prporg,    par_prpnumdig,      par_sgrorg,
                  par_sgrnumdig, par_rmemdlcod,      par_viginc,  
                  par_vigfnl   )
#-------------------------------------------------------------------------------

  define par_prporg          like rsdmdocto.prporg
  define par_prpnumdig       like rsdmdocto.prpnumdig
  define par_sgrorg          like rsdmdocto.sgrorg
  define par_sgrnumdig       like rsdmdocto.sgrnumdig
  define par_rmemdlcod       like rsamseguro.rmemdlcod
  define par_viginc          like rsdmdocto.viginc
  define par_vigfnl          like rsdmdocto.vigfnl

  define aux_dctnumseq  like rsdmdocto.dctnumseq
  define aux_prporg     like rsdmdocto.prporg
  define aux_prpnumdig  like rsdmdocto.prpnumdig

  define a_cta01m21     array[100]  of record
     local              char(70)                ,
     locdes             char(5)                 ,
     lclnumseq          like rsdmlocal.lclnumseq
  end record

 define ws     record
    endlgdtip           like rlaklocal.endlgdtip,
    endlgdnom           like rlaklocal.endlgdnom,
    endnum              like rlaklocal.endnum   ,
    ufdcod              like rlaklocal.ufdcod   ,
    endcmp              like rlaklocal.endcmp   ,
    endbrr              like rlaklocal.endbrr   ,
    endcid              like rlaklocal.endcid   ,
    endcep              like rlaklocal.endcep   ,
    lclnumseq           like rsdmlocal.lclnumseq,
    lclrsccod           like rsdmlocal.lclrsccod,
    segnumdig           like gsakseg.segnumdig
 end record

 define arr_aux   integer

 define sql_comando  char (900)

 define	w_pf1	integer

 define tra_endlgdnom like trakaceite.segendlgd
 define tra_endcid    like trakaceite.segcidnom
 define tra_ufdcod    like trakaceite.segufdcod

	let	aux_dctnumseq  =  null
	let	aux_prporg  =  null
	let	aux_prpnumdig  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cta01m21[w_pf1].*  to  null
	end	for


 open window w_cta01m21 at 7,2 with form "cta01m21"
      attribute(form line first)

 initialize a_cta01m21    to null
 initialize ws.*          to null
 initialize tra_endlgdnom, tra_endcid, tra_ufdcod to null

 if g_documento.aplnumdig is null or
    g_documento.aplnumdig = 0 then
    let sql_comando = "select segnumdig, segendlgd, segcidnom, segufdcod ",
                      "  from trakaceite ",
                      " where prporg = ",g_documento.prporg,
                      "   and prpnumdig = ",g_documento.prpnumdig
 else
    let sql_comando = "select segnumdig, segendlgd, segcidnom, segufdcod ",
                      "  from trakaceite ",
                      " where succod = ",g_documento.succod,
                      "   and aplnumdig = ",g_documento.aplnumdig
 end if
 prepare s_trakaceite from sql_comando
 declare c_trakaceite cursor for s_trakaceite

 open c_trakaceite
 fetch c_trakaceite   into ws.segnumdig
 
 if status <> notfound then

    if ws.segnumdig is null or ws.segnumdig = 0 then
       if g_documento.aplnumdig is null or
          g_documento.aplnumdig = 0 then
          select max(segnumdig) into ws.segnumdig
            from rsdmdocto
           where sgrorg = g_documento.prporg
             and sgrnumdig =  g_documento.prpnumdig
       else
          select max(b.segnumdig) into ws.segnumdig
            from rsamseguro a, rsdmdocto b
           where a.succod = g_documento.succod
             and a.ramcod = g_documento.ramcod
             and a.aplnumdig = g_documento.aplnumdig
             and b.sgrorg = a.sgrorg
             and b.sgrnumdig = a.sgrnumdig
       end if

    end if

    if ws.segnumdig is null or ws.segnumdig = 0 then
       let ws.endlgdnom = tra_endlgdnom
       let ws.endcid    = tra_endcid
       let ws.ufdcod    = tra_ufdcod
    else
       select endlgdtip, endlgd, endnum, endufd,
              endcmp   , endbrr, endcid, endcep
         into ws.endlgdtip, ws.endlgdnom, ws.endnum, ws.ufdcod,
              ws.endcmp   , ws.endbrr   , ws.endcid, ws.endcep
         from gsakend
        where segnumdig = ws.segnumdig
          and endfld = "1"
    end if
     
    call frama185_end (ws.endlgdtip, ws.endlgdnom, ws.endnum, ws.ufdcod,
                       ws.endcmp   , ws.endbrr   , ws.endcid, ws.endcep)
         returning a_cta01m21[1].local

    let a_cta01m21[1].lclnumseq = 1
    let a_cta01m21[1].locdes    = "Local"

    let arr_aux = 2
 else
    select dctnumseq
      into aux_dctnumseq
      from rsdmdocto
     where prporg    = par_prporg    and
           prpnumdig = par_prpnumdig

    select max(dctnumseq) into aux_dctnumseq
      from rsdmdocto
     where sgrorg    =  par_sgrorg    and
           sgrnumdig =  par_sgrnumdig and
           dctnumseq <= aux_dctnumseq and
           prporg    <> 58

    select prporg, prpnumdig
      into aux_prporg,aux_prpnumdig
      from rsdmdocto
     where sgrorg    = par_sgrorg    and
           sgrnumdig = par_sgrnumdig and
           dctnumseq = aux_dctnumseq

    #------------------------------------------------------------
    # PROCURA ENDERECOS (LOCAIS)
    #------------------------------------------------------------
    declare  c_cta01m21  cursor for
       select lclrsccod, lclnumseq
         from rsdmlocal
        where prporg    = aux_prporg    and
              prpnumdig = aux_prpnumdig

    let arr_aux = 1

    foreach  c_cta01m21  into  ws.lclrsccod,
                               ws.lclnumseq

       declare  c_cta01m212  cursor for
          select endlgdtip, endlgdnom, endnum,
                 ufdcod   , endcmp   , endbrr,
                 endcid   , endcep
            from rlaklocal
            where lclrsccod = ws.lclrsccod

       foreach  c_cta01m212 into  ws.endlgdtip,
                                  ws.endlgdnom,
                                  ws.endnum   ,
                                  ws.ufdcod   ,
                                  ws.endcmp   ,
                                  ws.endbrr   ,
                                  ws.endcid   ,
                                  ws.endcep

          let a_cta01m21[arr_aux].lclnumseq = ws.lclnumseq
          let a_cta01m21[arr_aux].locdes    = "Local"

          call frama185_end (ws.endlgdtip, ws.endlgdnom, ws.endnum, ws.ufdcod,
                             ws.endcmp   , ws.endbrr   , ws.endcid, ws.endcep)
               returning a_cta01m21[arr_aux].local

          let arr_aux = arr_aux + 1
          if arr_aux  >  100   then
             error "Limite excedido, apolice c/ mais de 100 locais"
             exit foreach
          end if

       end foreach

    end foreach

 end if

 if arr_aux  =  1   then
    error "Apolice sem local cadastrado"
 end if

 call set_count(arr_aux-1)
 #message " (F17)Abandona, (F8)Coberturas, (F9)Franquias"
 message " (F17)Abandona, (F8)Cob/Frq "                   #PSI200140

 display array  a_cta01m21  to  s_cta01m21.*

    on key (interrupt)
       exit display

    on key (f8)      #------ mostra coberturas do local -----#
       let arr_aux = arr_curr()
       #call cta01m22(par_prporg   , par_prpnumdig, par_sgrorg  ,
       #              par_sgrnumdig, par_rmemdlcod,
       #              a_cta01m21[arr_aux].lclnumseq,
       #              par_viginc , par_vigfnl)

       #PSI200140 - Automatizacao Laudo Sinistro RE
       # chamar funcao RE para exibir todas as coberturas/naturezas da apolice

       #criar tabela temporaria
       call fsrec770_cria_temp()

       #chamar funcao RE para exibir cobertura/natureza
       call fsrec770_sel_cobnat("N",  g_documento.succod, g_documento.ramcod,
                                 g_documento.aplnumdig)

       #dropa tabela temporaria
       call fsrec770_drop_temp()


    #on key (f9)      #------ mostra franquias do local -----#
       #let arr_aux = arr_curr()
       ##call cta01m24(par_prporg   , par_prpnumdig, par_sgrorg  ,
       ##              par_sgrnumdig, a_cta01m21[arr_aux].lclnumseq,
       ##              par_viginc   , par_vigfnl, par_rmemdlcod)

       #call framc024(par_prporg   , par_prpnumdig, par_sgrorg  ,
       #             par_sgrnumdig, a_cta01m21[arr_aux].lclnumseq,
       #             par_viginc   , par_vigfnl, g_documento.ramcod,
       #	     par_rmemdlcod)

 end display

 close window w_cta01m21
 let int_flag = false

end function     ####  cta01m21
