#############################################################################
# Nome do Modulo: CTS21G00                                         Marcus   #
#                                                                           #
# Rotinas para calculo automatico de previsao GPS                  Abr/2001 #
#############################################################################

database porto

#------------------------------------------------------------------------------
function cts21g00_calc_prev_coord(param)
#------------------------------------------------------------------------------

define param      record
 lttsrr		  dec(8,6),
 lgtsrr           dec(9,6),
 lttsrv           dec(8,6),
 lgtsrv           dec(9,6),
 atdhorpvt        interval hour(2) to minute
end record

define previsao   interval hour(2) to minute
define distancia  dec(16,8)


	let	previsao  =  null
	let	distancia  =  null

call cts18g00(param.lttsrr, param.lgtsrr, param.lttsrv, param.lgtsrv)
               returning distancia

call cts21g00_calc_prev(distancia, param.atdhorpvt)
               returning previsao

return previsao

end function

#------------------------------------------------------------------------------
function cts21g00_calc_prev(param)
#------------------------------------------------------------------------------

define param      record
 distancia        dec(16,8),
 atdhorpvt        interval hour(2) to minute
end record

define ws         record
 margem_seg_tmp   dec(4,2),
 margem_seg       interval hour(2) to minute,
 sub_tempo        interval hour(2) to minute,
 sub_tempo_tmp    dec(4,2),
 previsao         interval hour(2) to minute
end record

define d_cts21g00  record
 tempo_acn         interval hour(2) to minute,
 vlc_media         dec(5,2),
 div_margem        int
end record



	initialize  ws.*  to  null

	initialize  d_cts21g00.*  to  null

 initialize ws.* to NULL

 let d_cts21g00.tempo_acn = "00:05"
 let d_cts21g00.vlc_media = 25
 let d_cts21g00.div_margem = 2

 let param.distancia = param.distancia * 1.25


 let ws.sub_tempo_tmp = param.distancia / d_cts21g00.vlc_media

 let ws.margem_seg_tmp = (param.distancia /d_cts21g00.div_margem)/100


call cts21g00_calc_hora(ws.margem_seg_tmp)
     returning ws.margem_seg

 call cts21g00_calc_hora(ws.sub_tempo_tmp)
      returning ws.sub_tempo


let ws.previsao = (ws.sub_tempo + ws.margem_seg + d_cts21g00.tempo_acn)

#display "Calculada : ", ws.previsao , " - CT : ", param.atdhorpvt
 if ws.previsao > param.atdhorpvt then
      return param.atdhorpvt
 else
    return ws.previsao
 end if

end function

#------------------------------------------------------------------------------
function cts21g00_calc_rest(param)
#------------------------------------------------------------------------------

 define param    record
  distancia      dec(16,8),
  tempo_deco     interval hour(2) to minute
 end record

 define ws         record
 margem_seg_tmp   dec(4,2),
 margem_seg       interval hour(2) to minute,
 sub_tempo        interval hour(2) to minute,
 sub_tempo_tmp    dec(4,2),
 previsao         interval hour(2) to minute
end record

define d_cts21g00  record
 tempo_acn         interval hour(2) to minute,
 vlc_media         dec(5,2),
 div_margem        int
end record



	initialize  ws.*  to  null

	initialize  d_cts21g00.*  to  null

 initialize ws.* to NULL

 let d_cts21g00.tempo_acn = "00:05"
 let d_cts21g00.vlc_media = 25
 let d_cts21g00.div_margem = 2

 let param.distancia = param.distancia * 1.25
#display param.distancia

 let ws.sub_tempo_tmp = param.distancia / d_cts21g00.vlc_media
#display ws.sub_tempo_tmp

  call cts21g00_calc_hora(ws.sub_tempo_tmp)
      returning ws.sub_tempo

  let ws.previsao = ws.sub_tempo


 if param.tempo_deco < d_cts21g00.tempo_acn then
    let ws.margem_seg_tmp = (param.distancia /d_cts21g00.div_margem)/100

    call cts21g00_calc_hora(ws.margem_seg_tmp)
         returning ws.margem_seg

    let ws.previsao = ws.previsao + ws.margem_seg
 end if

 return ws.previsao

end function

#-------------------------------------------------------------------------------
function cts21g00_calc_hora(param)
#-------------------------------------------------------------------------------

 define param dec(4,2)

 define ws1    record
  hora         int,
  minutos      int,
  hora_str     char(2),
  minutos_str  char(2),
  tempo_str    char(5),
  tempo        interval hour(2) to minute
 end record



	initialize  ws1.*  to  null

 initialize ws1.* to NULL

 let ws1. tempo_str = "00:00"
 let ws1.hora    = param
 let ws1.minutos = (param - ws1.hora) * 100

 if ws1.minutos > 60 then
    let ws1.hora = ws1.hora + 1
    let ws1.minutos = ws1.minutos - 60
 end if

 let ws1.hora_str = F_FUNDIGIT_INTTOSTR(ws1.hora,02)
 let ws1.minutos_str = F_FUNDIGIT_INTTOSTR(ws1.minutos,02)

 let ws1.tempo_str[1,2] = ws1.hora_str
 let ws1.tempo_str[4,5] = ws1.minutos_str

 let ws1.tempo = ws1.tempo_str

 return ws1.tempo

end function

