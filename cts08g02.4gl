###############################################################################
# Nome do Modulo: CTS08G02                                           Marcelo  #
#                                                                    Gilberto #
# Janela para exibicao/confirmacao de mensagem                       Nov/1997 #
#-----------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                    #
#                                                                             #


 database porto

#-----------------------------------------------------------------------------
 function cts08g02(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g02   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g02.*  to  null

 initialize  ws.*  to  null

 open window w_cts08g02 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g02.cabtxt = "CONFIRME"
    when "A"  let  d_cts08g02.cabtxt = "A T E N C A O"
 end case

 let d_cts08g02.cabtxt = cts08g01_center(d_cts08g02.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g02.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts08g02 at 18,32 with 02 rows, 25 columns
    menu ""
       command key ("R", interrupt) "RESERVAR"
          let ws.confirma = "R"
          exit menu

       command key ("E")            "EMITIR"
          let ws.confirma = "E"
          exit menu
    end menu
    close window m_cts08g02
 end if

 let int_flag = false
 close window w_cts08g02

 return ws.confirma

end function  ###  cts08g02
