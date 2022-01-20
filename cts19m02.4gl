###############################################################################
# Nome do Modulo: CTS19M02                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Nr.ddd/telefone do segurado para envio Carglass                    Dez/1999 #
###############################################################################

 database porto

#--------------------------------------------------------------
 function cts19m02(param)
#--------------------------------------------------------------

 define param        record
    segdddcod        like gsakend.dddcod,
    segteltxt        like gsakend.teltxt,
    tipo             char(01)
 end record
 define d_cts19m02   record
    segdddcod        like gsakend.dddcod,
    segteltxt        like gsakend.teltxt
 end record

 define ws           record
    confirma         char (01)
 end record



	initialize  d_cts19m02.*  to  null

	initialize  ws.*  to  null

 initialize d_cts19m02.* to null
 initialize ws.*         to null

 if param.tipo = "C" then
    let d_cts19m02.segdddcod = param.segdddcod
    let d_cts19m02.segteltxt = param.segteltxt
 end if

 let int_flag = false

 open window w_cts19m02 at 10,22 with form "cts19m02"
      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 display by name d_cts19m02.*

 while true

    input by name d_cts19m02.segdddcod,
                  d_cts19m02.segteltxt  without defaults

       before field segdddcod
          if param.tipo = "C" then
             prompt "(F17)Abandona " for char ws.confirma
             exit input
          end if
          display by name d_cts19m02.segdddcod attribute (reverse)

       after  field segdddcod
          display by name d_cts19m02.segdddcod

          if d_cts19m02.segdddcod is null  then
             error " Codigo do DDD deve ser informado!"
             next field segdddcod
          end if

       before field segteltxt
          display by name d_cts19m02.segteltxt  attribute (reverse)

       after  field segteltxt
          display by name d_cts19m02.segteltxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field segdddcod
          end if

          if d_cts19m02.segteltxt is null  then
             error " Numero do telefone deve ser informado!"
             next field segteltxt
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       if d_cts19m02.segdddcod is null     or
          d_cts19m02.segteltxt is null     then
          error "Codigo DDD ou Nr.telefone nao informado!"
       else
          exit while
       end if
    else
       if param.tipo  is null then
          call cts08g01("C","S","","DDD/TELEFONE DO SEGURADO ESTAO CORRETOS ?",
                                    "","")
                returning ws.confirma
          if ws.confirma = "S"  then
             exit while
          end if
       else
          exit while
       end if
    end if
 end while

 close window w_cts19m02

 let int_flag = false

 return d_cts19m02.segdddcod, d_cts19m02.segteltxt

end function  ###  cts19m02
