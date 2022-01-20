#############################################################################
# Nome do Modulo: CTC18M03                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Consulta situacao da loja locadora                               Jan/1999 #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#--------------------------------------------------------------
 function ctc18m03(param)
#--------------------------------------------------------------

 define param        record
    lcvcod           like datkavislocal.lcvcod,
    aviestcod        like datkavislocal.aviestcod
 end record

 define d_ctc18m03   record
    vclalglojstt     like  datkavislocal.vclalglojstt,
    lojsttdes        char(12),
    viginc           like  datklcvsit.viginc,
    vigfnl           like  datklcvsit.vigfnl,
    atldat           like  datklcvsit.atldat,
    atlemp           like  datklcvsit.atlemp,
    atlmat           like  datklcvsit.atlmat,
    atlnom           char(20)
 end record

 define ws           record
    resp             char(1)
 end record

 initialize d_ctc18m03.*  to null
 initialize ws.*          to null

 open window w_ctc18m03 at 11,17 with form "ctc18m03"
             attribute (form line 1, border)

 select vclalglojstt
   into d_ctc18m03.vclalglojstt
   from datkavislocal
  where lcvcod     = param.lcvcod
    and aviestcod  = param.aviestcod

 case d_ctc18m03.vclalglojstt
    when  1   let d_ctc18m03.lojsttdes = "ATIVA"
    when  2   let d_ctc18m03.lojsttdes = "BLOQUEADA"
    when  3   let d_ctc18m03.lojsttdes = "CANCELADA"
    when  4   let d_ctc18m03.lojsttdes = "DESATIVADA"
 end case

 select viginc, vigfnl, atldat, atlemp, atlmat
   into d_ctc18m03.viginc, d_ctc18m03.vigfnl,
        d_ctc18m03.atldat, d_ctc18m03.atlemp,
        d_ctc18m03.atlmat
   from datklcvsit
  where lcvcod     = param.lcvcod
    and aviestcod  = param.aviestcod

 if sqlca.sqlcode = 0  then
    select funnom
      into d_ctc18m03.atlnom
      from isskfunc
     where isskfunc.empcod = d_ctc18m03.atlemp
       and isskfunc.funmat = d_ctc18m03.atlmat
 end if

 if d_ctc18m03.viginc = 0 then
    initialize d_ctc18m03.viginc to null
    initialize d_ctc18m03.vigfnl to null
 end if

 display by name d_ctc18m03.*

 prompt "(F17)Abandona" for ws.resp

 message ""
 clear form
 let int_flag = false
 close window w_ctc18m03

end function  ###  ctc18m03
