###############################################################################
# Nome do Modulo: ctc35m15                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Calculo dia vistoria                                               Dez/1998 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc35m15(param)
#-----------------------------------------------------------

 define param       record
    socvclcod       like datmsocvst.socvclcod,
    socvstdiaqtd    like datkveiculo.socvstdiaqtd
 end record

 define ws          record
    dia             smallint,
    diasem          dec(3,0),
    conta           dec(3,0),
    dtvist          date,
    dtcalc          date
 end record

 select max(datmsocvst.socvstdat)
   into ws.dtvist
   from datmsocvst
  where datmsocvst.socvstnum > 0                 # Nro. Vistoria
    and datmsocvst.socvclcod = param.socvclcod   # Codigo veiculo
    and datmsocvst.socvstsit = 5                 # Vistoria realizada

  if ws.dtvist is not null then
     if ( ws.dtvist + param.socvstdiaqtd ) < today then
        let ws.dtvist = today - param.socvstdiaqtd + 1
     end if
     for ws.dia = 0 to 365
        let ws.dtcalc = ws.dtvist + param.socvstdiaqtd + ws.dia
        let ws.diasem = weekday(ws.dtcalc)
        case ws.diasem
          when 0  #--> Nesta data o dia da semana e' domingo!
                  continue for
          when 1  #--> Nesta data o dia da semana e' segunda-feira
                  continue for
          when 6  #--> Nesta data o dia da semana e' sabado!
                  continue for
          otherwise
               if dias_uteis(ws.dtcalc, 0, "", "S", "S") <> ws.dtcalc then
                  #--> Nesta data o dia e' feriado!
                  continue for
                 else
                  let ws.conta = 0
                  select count(*)
                    into ws.conta
                    from datmsocvst
                   where socvstdat  = ws.dtcalc
                     and socvstsit  in (1,2)

                  if ws.conta >=2 then
                     #--> 2 (dois) e' o limite maximo de vistorias por dia
                     continue for
                    else
                     exit for
                  end if
               end if
        end case
     end for
     if ws.dia >= 365 then
        let ws.dtcalc = ws.dtvist
     end if
    else
     let ws.dtcalc = ws.dtvist
  end if

 return ws.dtcalc

end function  #  ctc35m15
