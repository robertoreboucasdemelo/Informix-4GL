###############################################################################
# Nome do Modulo: CTS14M05                                              Pedro #
#                                                                     Marcelo #
# Mostra todos os sinistros registrados na apolice                   Ago/1995 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts14m05(par_succod, par_ramcod, par_aplnumdig,
                   par_itmnumdig, par_sindat)
#------------------------------------------------------------

define par_succod    like datmvstsin.succod
define par_ramcod    like datmvstsin.ramcod
define par_aplnumdig like datmvstsin.aplnumdig
define par_itmnumdig like datmvstsin.itmnumdig
define par_sindat    like datmvstsin.sindat

define a_cts14m05 array[20] of record
   sinvstnum         like ssamsin.sinvstnum,
   sinvstano         like ssamsin.sinvstano,
   orrdat            like ssamsin.orrdat
end record

define ws            record
   sinvstnum         like ssamsin.sinvstnum,
   sinvstano         like ssamsin.sinvstano,
   orrdat            like ssamsin.orrdat   ,
   dtini             like ssamsin.orrdat   ,
   dtfim             like ssamsin.orrdat   ,
   comando1          char(200),
   comando2          char(140)
end record

define arr_aux       integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cts14m05[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

initialize ws.*        to null
initialize a_cts14m05  to null
let int_flag = false
let arr_aux  = 1

let ws.dtini = par_sindat - 5 units day
let ws.dtfim = par_sindat + 5 units day

#--------------------------------------------------
# CONSULTA OS SINISTROS AVISADOS PARA APOLICE/ITEM
#--------------------------------------------------
let ws.comando2 = " from ssamsin ",
                  " where ",
                  " ssamsin.succod     = ?  and ",
                  " ssamsin.ramcod     = ?  and ",
                  " ssamsin.aplnumdig  = ?  and ",
                  " ssamsin.itmnumdig  = ?  "

let ws.comando1= "select sinvstnum, sinvstano, orrdat ", ws.comando2  clipped

prepare p_cts14m05_001 from ws.comando1
declare c_cts14m05_001 cursor for p_cts14m05_001

open c_cts14m05_001 using par_succod, par_ramcod, par_aplnumdig, par_itmnumdig

foreach  c_cts14m05_001  into  ws.sinvstnum,
                           ws.sinvstano,
                           ws.orrdat

   if ws.orrdat < ws.dtini   or
      ws.orrdat > ws.dtfim   then
      continue foreach
   end if

   let a_cts14m05[arr_aux].sinvstnum =  ws.sinvstnum
   let a_cts14m05[arr_aux].sinvstano =  ws.sinvstano
   let a_cts14m05[arr_aux].orrdat    =  ws.orrdat

   let arr_aux = arr_aux + 1

   if arr_aux > 20  then
      error "Limite excedido, apolice/item c/ mais de 20 sinistros!"
      exit foreach
   end if
end foreach

if arr_aux > 1  then
   open window w_cts14m05 at  12,48 with form "cts14m05"
               attribute(form line first, border)

   error " Ja' foi avisado sinistro em menos de 5 dias para este documento!"
   message " (F17)Abandona"
   call set_count(arr_aux-1)

   display array  a_cts14m05 to s_cts14m05.*
      on key(interrupt)
         initialize a_cts14m05 to null
         exit display

   end display
   close window  w_cts14m05
end if

close c_cts14m05_001
let int_flag = false

end function  #  cts14m05
