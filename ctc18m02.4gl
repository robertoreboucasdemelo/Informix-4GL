#############################################################################
# Nome do Modulo: CTC18M02                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Manutencao periodo de vigencia de bloqueio das lojas locadoras   Jan/1999 #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#--------------------------------------------------------------
 function ctc18m02(param)
#--------------------------------------------------------------

 define param        record
    lcvcod           like datkavislocal.lcvcod,
    aviestcod        like datkavislocal.aviestcod
 end record

 define d_ctc18m02   record
    viginc           like datklcvsit.viginc,
    vigfnl           like datklcvsit.vigfnl
 end record

 define ws           record
    viginc           like datklcvsit.viginc,
    vigfnl           like datklcvsit.vigfnl
 end record

 initialize d_ctc18m02.*  to null
 initialize ws.*          to null

 open window w_ctc18m02 at 11,17 with form "ctc18m02"
             attribute (form line 1, border)

 message " (F17)Abandona"

 select viginc, vigfnl
   into d_ctc18m02.viginc, d_ctc18m02.vigfnl
   from datklcvsit
  where lcvcod     = param.lcvcod
    and aviestcod  = param.aviestcod

 if sqlca.sqlcode <> 0 then
    initialize d_ctc18m02.*  to null
 end if

 if d_ctc18m02.viginc = 0 then
    initialize d_ctc18m02.*  to null
 end if

 let ws.* = d_ctc18m02.*

 display by name d_ctc18m02.*

 input by name d_ctc18m02.viginc ,
               d_ctc18m02.vigfnl without defaults

    before field viginc
       if ws.viginc is not null and
          ( ws.viginc <= today  and ws.vigfnl >= today ) then
          error " Bloqueio desta loja esta vigente !"
          next field vigfnl
       end if
       display by name d_ctc18m02.viginc    attribute (reverse)

    after  field viginc
       display by name d_ctc18m02.viginc

       if d_ctc18m02.viginc is null then
         error " Data inicio obrigatorio!"
         next field viginc
       end if
       if d_ctc18m02.viginc < today then
         error " Data inicio somente a partir de hoje !"
         next field viginc
       end if

    before field vigfnl
       display by name d_ctc18m02.vigfnl    attribute (reverse)

    after  field vigfnl
       display by name d_ctc18m02.vigfnl

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field viginc
       end if

       if d_ctc18m02.vigfnl is null then
         error " Data termino obrigatorio!"
         next field vigfnl
       end if
       if d_ctc18m02.vigfnl < d_ctc18m02.viginc then
         error " Data termino menor data inicio!"
         next field vigfnl
       end if

    on key (interrupt)
       if d_ctc18m02.viginc is null then
          error " Data inicio obrigatorio!"
          next field viginc
       end if
       if d_ctc18m02.vigfnl is null then
          error " Data termino obrigatorio!"
          next field vigfnl
       end if

       exit input

 end input

 if int_flag  then
    let d_ctc18m02.* = ws.*
 end if

 message ""
 clear form
 let int_flag = false
 close window w_ctc18m02

 return  d_ctc18m02.*

end function  ###  ctc18m02
