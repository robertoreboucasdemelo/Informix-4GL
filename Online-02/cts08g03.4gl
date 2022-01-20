###############################################################################
# Nome do Modulo: CTS08G03                                           Marcelo  #
#                                                                    Gilberto #
# Janela para exibicao/confirmacao de mensagem c/sleep               Nov/1997 #
#-----------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function cts08g03(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    tempo            smallint
 end record

 define d_cts08g03   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 define l_hr1, l_hr2 datetime hour to second

 initialize  d_cts08g03.*  to  null
 let l_hr1 = null
 let l_hr2 = null

 initialize  ws.*  to  null

 open window w_cts08g03 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g03.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g03.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g03.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g03.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g03.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g03.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g03.cabtxt = cts08g01_center(d_cts08g03.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g03.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts08g03 at 18,32 with 02 rows, 20 columns

    if g_documento.atdsrvorg = 9 then
       menu ""
          command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu

          command key ("N", interrupt) "NAO"
             error " Confirmacao cancelada!"
             exit menu
       end menu
    else
       menu ""
          command key ("N", interrupt) "NAO"
             error " Confirmacao cancelada!"
             exit menu
          command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu
       end menu
    end if
    close window m_cts08g03
 else
   if param.conflg = 'N' or
      param.conflg is null then
      message " (F17)Abandona"
      input by name d_cts08g03.confirma without defaults
         after field confirma
            next field confirma

         on key (interrupt, control-c)
            exit input
      end input
   else
      if param.conflg = 'F' then
         while true
            prompt 'CONFIRMA S/N? ' for char ws.confirma

            let ws.confirma = upshift(ws.confirma)
            if ws.confirma = 'S' or ws.confirma = 'N' then
               exit while
            end if

         end while

      end if
   end if
 end if

 let l_hr1 = current
 let l_hr2 = l_hr1 + param.tempo units second
 while l_hr1 < l_hr2
       let l_hr1 = current
 end while
#ligia

 let int_flag = false
 close window w_cts08g03

 return ws.confirma

end function  ###  cts08g03
