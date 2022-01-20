############################################################################
# Menu de Modulo: CTC14M06                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Manutencao do texto livre para pager                            Jun/1999 #
############################################################################

 database porto


#---------------------------------------------------------------
 function ctc14m06(param)
#---------------------------------------------------------------

 define param      record
    c24astpgrtxt   char(200)
 end record

 define a_ctc14m06 array[4] of record
    texto          char(50)
 end record

 define ws         record
    confirma       char(1)
 end record

 define arr_aux    smallint
 define scr_aux    smallint


 let a_ctc14m06[1].texto = param.c24astpgrtxt[001,050]
 let a_ctc14m06[2].texto = param.c24astpgrtxt[051,100]
 let a_ctc14m06[3].texto = param.c24astpgrtxt[101,150]
 let a_ctc14m06[4].texto = param.c24astpgrtxt[151,200]

 open window w_ctc14m06 at  11,14 with form "ctc14m06"
            attribute(border,form line first)

 while true

    let int_flag = false
    let arr_aux = 5
    call set_count(arr_aux - 1)

    input array a_ctc14m06 without defaults from s_ctc14m06.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before field texto
          display a_ctc14m06[arr_aux].texto to
                  s_ctc14m06[scr_aux].texto attribute (reverse)

       after field texto
          display a_ctc14m06[arr_aux].texto to
                  s_ctc14m06[scr_aux].texto

       on key (control-c)
          let int_flag = true
          exit input

       after row
          if arr_aux = 4 then
             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                continue input
              else
                exit input
             end if
          end if

    end input

    if int_flag = false then
       call cts08g01("C","S","","DIGITACAO DO TEXTO ADICIONAL OK?","","")
            returning ws.confirma

       if ws.confirma = "S"  then
          let param.c24astpgrtxt = a_ctc14m06[1].texto, a_ctc14m06[2].texto,
                                   a_ctc14m06[3].texto, a_ctc14m06[4].texto
          exit while
       end if
      else
       exit while
    end if

 end while

 let int_flag = false

 close window w_ctc14m06

 return param.c24astpgrtxt

end function  ###  ctc14m06

