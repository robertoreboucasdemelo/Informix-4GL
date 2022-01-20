###########################################################################
# Nome do Modulo: cta01m50                                       Marcelo  #
#                                                                Gilberto #
# Espelho do Cartao                                              Jan/1996 #
# ----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
#---------------------------------------------------------------
 function  cta01m50()
#---------------------------------------------------------------

define a_cta01m50 array [05] of record
       veiculo      char(40),
       cor          char(12),
       vclanomdl    like abbmveic.vclanomdl,
       vcllicnum    like abbmveic.vcllicnum,
       tpcar        char(3)
end record

define d_cta01m50   record
       cartao       dec(16,0)                  ,
       fone         char(20)                   ,
       cidade       char(50)                   ,
       situacao     char(11)                   ,
       pcablqdes    char(16)                   ,
       pcaclcvct    like egckciclo.pcaclcvct   ,
       pcaclinom    like eccmcli.pcaclinom     ,
       pcaclicgccpf like eccmcli.pcaclicgccpf  ,
       validade     char(10)                   ,
       pcactaabrdat like eccmcta.pcactaabrdat
 end record

define ws           record
       pergunta     char(80)                   ,
       resp         char(01)                   ,
       pcacttvld    char(07)                   ,
       mesvld       dec(2,0)                   ,
       anovld       dec(4,0)                   ,
       pcaprpsit    like epcmproposta.pcaprpsit,
       pcablqcod    like eccmpti.pcaptiblqcod  ,
       pcaprpnum    like epcmproposta.pcaprpnum,
       pcaincdat    like epcmproposta.pcaincdat,
       pcaretdat    like epcmproposta.pcaretdat,
       pcacarstt    like eccmpti.pcaptistt     ,
       pcacttcid    like eccmcli.pcacliendcid  ,
       pcacttuf     like eccmcli.pcacliendufd  ,
       pcactttel    like eccmcli.pcaclirsdtel  ,
       pcactacod    like eccmcta.pcactacod     ,
       pcaclicod    like eccmcta.pcaclicod     ,
       pcacarclc    like eccmcta.pcactaclodia  ,
       pcaprpitm    like epcmitem.pcaprpitm    ,
       pcavcltip    like epcmitem.pcavcltip    ,
       vcllicnum    like epcmitem.vcllicnum    ,
       vclanomdl    like epcmitem.vclanomdl    ,
       vclcoddig    like agbkveic.vclcoddig    ,
       vclcorcod    like iddkdominio.cpocod
 end record

define arr_aux       integer
define scr_aux       integer



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  5
		initialize  a_cta01m50[w_pf1].*  to  null
	end	for

	initialize  d_cta01m50.*  to  null

	initialize  ws.*  to  null

open window cta01m50 at  4,2 with form "cta01m50"
            attribute(form line 1)

initialize  a_cta01m50      to null
initialize  ws.*            to null
initialize  d_cta01m50.*    to null
let arr_aux = 1

select b.pcactacod   , a.pcaptistt   ,
       b.pcactaclodia, a.pcaptiblqcod ,
       a.pcaptivaldat
  into ws.pcactacod, ws.pcacarstt,
       ws.pcacarclc, ws.pcablqcod,
       d_cta01m50.validade
  from eccmpti a , eccmcta b
 where a.pcapticod  = g_documento.pcacarnum           and
       a.pcactacod  = b.pcactacod  #      and
   #   a.pcaptitip  = "1"

if status = notfound   then
   error " Cartao titular nao cadastrado, AVISE INFORMATICA"
      sleep 4
      exit program
end if

let d_cta01m50.cartao = g_documento.pcacarnum

case  ws.pcacarstt
      when  "A"
         let d_cta01m50.situacao =  " ATIVO"
      when  "B"
         let d_cta01m50.situacao =  " BLOQUEADO"
      when  "C"
         let d_cta01m50.situacao = " CANCELADO"
      otherwise
         let d_cta01m50.situacao = " NAO PREVISTO"
end case
if ws.pcablqcod  is not null   then
   call cpcgeral8(ws.pcablqcod) returning d_cta01m50.pcablqdes
end if

select pcaclinom   , pcaclicgccpf, pcacliendcid,
       pcacliendufd, pcaclirsdtel,
       pcactaabrdat, a.pcaclicod, pcaprpnum
  into d_cta01m50.pcaclinom, d_cta01m50.pcaclicgccpf,
       ws.pcacttcid,         ws.pcacttuf         ,
       ws.pcactttel        , d_cta01m50.pcactaabrdat,
       ws.pcaclicod        , ws.pcaprpnum
  from eccmcli a, eccmcta b
 where b.pcactacod            = ws.pcactacod
   and a.pcaclicod            = b.pcaclicod

if status = notfound   then
   error "Contrato nao encontrado, AVISE INFORMATICA !!"
   sleep 4
   return
end if

let d_cta01m50.cidade =  ws.pcacttcid  clipped, " - ", ws.pcacttuf
let d_cta01m50.fone   =  ws.pcactttel


###  --------- DATA FATURA/VENCTO ----------- ###

select pcaclcvct
  into d_cta01m50.pcaclcvct
  from egckciclo
 where pcacarclc = ws.pcacarclc            and
       today     between viginc and vigfnl

###  --------- VEICULOS DO CARTAO ----------- ###

declare c_cta01m50_001  cursor for
    select vclcoddig, vcllicnum, vclcorcod,
           vclanomdl, pcavcltip
     into  ws.vclcoddig, ws.vcllicnum, ws.vclcorcod,
           ws.vclanomdl, ws.pcavcltip
     from  epcmitem a, epcmproposta b
     where a.pcaprpnum = ws.pcaprpnum and
           a.pcaprpnum = b.pcaprpnum

foreach c_cta01m50_001  into  ws.vclcoddig, ws.vcllicnum,
                             ws.vclcorcod, ws.vclanomdl,
                             ws.pcavcltip

   call cpcgeral7(ws.vclcoddig)  returning a_cta01m50[arr_aux].veiculo

   let a_cta01m50[arr_aux].vcllicnum  = ws.vcllicnum
   let a_cta01m50[arr_aux].vclanomdl  = ws.vclanomdl

   if ws.pcavcltip  =  "T"   then
      let a_cta01m50[arr_aux].tpcar  =  "Tit"
   else
      let a_cta01m50[arr_aux].tpcar  =  "Adi"
   end if

   select   cpodes
     into  a_cta01m50[arr_aux].cor
     from  iddkdominio
     where cponom = "vclcorcod"   and
           cpocod = ws.vclcorcod
   if status = notfound    then
      let a_cta01m50[arr_aux].cor = "N/CADAST"
   end if

   #let g_central24h.pcapticod = g_documento.pcacarnum
   #let g_central24h.pcaclinom = d_cta01m50.pcaclinom
   #let g_central24h.modelo    = a_cta01m50[arr_aux].veiculo
   #let g_central24h.cor       = a_cta01m50[arr_aux].cor
   #let g_central24h.ano       = ws.vclanomdl
   #let g_central24h.placa     = ws.vcllicnum

   let arr_aux = arr_aux + 1
   if arr_aux > 5    then
      error "Tabela de veiculos com mais de 5 ocorrencias !!"
      exit foreach
   end if


end foreach

for  arr_aux = 1  to  5
     display a_cta01m50[arr_aux].veiculo   to s_cta01m50[arr_aux].veiculo
     display a_cta01m50[arr_aux].cor       to s_cta01m50[arr_aux].cor
     display a_cta01m50[arr_aux].vclanomdl to s_cta01m50[arr_aux].vclanomdl
     display a_cta01m50[arr_aux].vcllicnum to s_cta01m50[arr_aux].vcllicnum
     display a_cta01m50[arr_aux].tpcar     to s_cta01m50[arr_aux].tpcar
end for

display by name d_cta01m50.*
if d_cta01m50.pcablqdes  is not null   then
   display by name d_cta01m50.pcablqdes  attribute(reverse)
end if

let int_flag = false

while true
   let ws.pergunta = "Funcoes : (F17)Abandona, (A)dicionais"
   prompt ws.pergunta  for  char ws.resp

   if  int_flag then
       exit while
   end if
   if ws.resp  =  "a"   or
      ws.resp  =  "A"   then
      call cta01m57()
   else
      error "Funcao Invalida !"
   end if

   let int_flag  = false
   let ws.resp = " "

end while

let int_flag = false
close  window cta01m50

end function  #  cta01m50

