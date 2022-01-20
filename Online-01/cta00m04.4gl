###############################################################################
# Nome do Modulo: CTA00M04                                           Marcelo  #
#                                                                             #
# Pesquisa Apolice por Chassi                                        NOV/1994 #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
function cta00m04(par_vclchsfnl)
#------------------------------------------------------------------------------

 define par_vclchsfnl like abbmveic.vclchsfnl

 define parametros record
  succod    like abbmveic.succod   ,
  ramcod    like gtakram.ramcod    ,
  aplnumdig like abbmveic.aplnumdig,
  itmnumdig like abbmveic.itmnumdig  
 end record

 define cta00m04 array[500] of record
  marca      char(1),
  succod    like abbmveic.succod   ,
  ramcod    like gtakram.ramcod    ,
  aplnumdig like abbmveic.aplnumdig,
  itmnumdig like abbmveic.itmnumdig,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl   ,
  segnom    like gsakseg.segnom
 end record

 define d_abbmveic record
  succod    like abbmveic.succod,
  aplnumdig like abbmveic.aplnumdig,
  itmnumdig like abbmveic.itmnumdig,
  dctnumseq like abbmveic.dctnumseq
 end record

 define d_abamapol record
  etpnumdig like abamapol.etpnumdig,
  aplstt    like abamapol.aplstt   ,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl
 end record
 
 define cta00m04_aux array[200] of record 
  tipdoc      char(30)
 end record

 define d_gsakseg  record
  segnom    like gsakseg.segnom
 end record
 
 define ws  record
  dtresol86 date,
  emsdat    like abamdoc.emsdat
 end record

 define arr_aux integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  cta00m04[w_pf1].*  to  null
		initialize  cta00m04_aux[w_pf1].*  to  null
	end	for

	initialize  parametros.*  to  null

	initialize  d_abbmveic.*  to  null

	initialize  d_abamapol.*  to  null

	initialize  d_gsakseg.*  to  null
	initialize  ws.*         to  null

 initialize g_dctoarray  to null
 initialize parametros.* to null

 let int_flag = false
 let g_index  = 0
 let arr_aux  = 0

 message " Aguarde, pesquisando..." attribute (reverse)

 select grlinf[01,10] into ws.dtresol86
   from datkgeral
   where grlchv='ct24resolucao86'
 declare c_vclchsfnl cursor for
   select abbmveic.succod,
          abbmveic.aplnumdig,
          abbmveic.itmnumdig,
          abbmveic.dctnumseq
    from  abbmveic
    where abbmveic.vclchsfnl = par_vclchsfnl

 foreach c_vclchsfnl into   d_abbmveic.*
   let arr_aux = arr_aux + 1

   if arr_aux > 500 then
      let arr_aux = 500

      error "Existem mais de 500 veiculos com o mesmo chassi!"
   end if

   call F_FUNAPOL_ULTIMA_SITUACAO
          (d_abbmveic.succod,d_abbmveic.aplnumdig,d_abbmveic.itmnumdig)
           returning g_funapol.*

   if g_funapol.resultado = "O"   then
      let cta00m04[arr_aux].itmnumdig = d_abbmveic.itmnumdig

      select etpnumdig,
             aplstt   ,
             viginc   ,
             vigfnl
       into  d_abamapol.*
       from  abamapol
       where abamapol.succod    = d_abbmveic.succod    and
             abamapol.aplnumdig = d_abbmveic.aplnumdig

      let cta00m04[arr_aux].succod    = d_abbmveic.succod
      let cta00m04[arr_aux].aplnumdig = d_abbmveic.aplnumdig
      let cta00m04[arr_aux].itmnumdig = d_abbmveic.itmnumdig
      let cta00m04[arr_aux].viginc    = d_abamapol.viginc
      let cta00m04[arr_aux].vigfnl    = d_abamapol.vigfnl
      let cta00m04_aux[arr_aux].tipdoc = 'APOLICE'  
       
      select emsdat into ws.emsdat
           from abamdoc
          where succod    = d_abbmveic.succod
            and aplnumdig = d_abbmveic.aplnumdig
            and edsnumdig = 0
      if ws.emsdat >= ws.dtresol86 then
         let cta00m04[arr_aux].ramcod = 531
      else
         let cta00m04[arr_aux].ramcod = 31
      end if
      select segnom
        into d_gsakseg.*
        from gsakseg
       where gsakseg.segnumdig        = d_abamapol.etpnumdig

      let cta00m04[arr_aux].segnom    = d_gsakseg.segnom
   end if

 end foreach

 if arr_aux > 1 then    
    open window cta00m04 at 09,02 with form "cta00m02" attribute(form line 1,message line last - 1)
           

    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux)

    #display array cta00m04 to s_cta00m02.*
    input array cta00m04 without defaults from s_cta00m02.*
     
       before field marca
          
           let arr_aux = arr_curr()
           display by name cta00m04_aux[arr_aux].tipdoc attribute (reverse)
             
       after  field marca

	       if fgl_lastkey() = fgl_keyval("left")  or
	          fgl_lastkey() = fgl_keyval("up")    then
	          else
	             if cta00m04_aux[arr_aux+1].tipdoc is null or
	                cta00m04_aux[arr_aux+1].tipdoc < 0     then
	                error " There are no more rows in the direction ",
	                      "you are going "
	                next field marca
	             end if
	       end if  
	          
      on key (F8)
         let arr_aux              = arr_curr()
         let parametros.succod    = cta00m04[arr_aux].succod
         let parametros.ramcod    = cta00m04[arr_aux].ramcod
         let parametros.aplnumdig = cta00m04[arr_aux].aplnumdig
         let parametros.itmnumdig = cta00m04[arr_aux].itmnumdig         
         exit input

      on key (interrupt)
         let int_flag = false
         initialize parametros.* to null
         exit input
    end input

    close window cta00m04
 else
    if arr_aux <> 0 then
       let parametros.succod    = cta00m04[arr_aux].succod
       let parametros.ramcod    = cta00m04[arr_aux].ramcod
       let parametros.aplnumdig = cta00m04[arr_aux].aplnumdig
       let parametros.itmnumdig = cta00m04[arr_aux].itmnumdig       
    end if
 end if

 return parametros.*

 let int_flag = false

end function #---- fim cta00m04
