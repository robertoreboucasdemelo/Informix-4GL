###############################################################################
# Nome do Modulo: CTS08G01                                           Marcelo  #
#                                                                    Gilberto #
# Janela para exibicao/confirmacao de mensagem                       Nov/1997 #
#-----------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 15/06/2005 Julianna,META     PSi189790  Forcar a confirmacao da pergunta se #
#                                         param.conflg = F                    #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function cts08g01(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g01.*  to  null

 initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts08g01 at 18,32 with 02 rows, 20 columns

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
    close window m_cts08g01
 else
   if param.conflg = 'N' or
      param.conflg is null then
      message " (F17)Abandona"
      input by name d_cts08g01.confirma without defaults
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
      else
         if  param.conflg = 'I' then
            open window m_cts08g01 at 18,32 with 02 rows, 20 columns
            menu ""
               command key ("N", interrupt) "NAO"
                  error " Confirmacao cancelada!"
                  let ws.confirma = "N"
                  exit menu
               command key ("S")            "SIM"
                  let ws.confirma = "S"
                  exit menu
            end menu
            close window m_cts08g01
         end if
      end if
   end if
 end if

 let int_flag = false
 close window w_cts08g01

 return ws.confirma

end function  ###  cts08g01

#-----------------------------------------------------------------------------
 function cts08g01_6l(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    linha5           char (40),
    linha6           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g01, ws to  null

 open window w_cts08g01b at 10,19 with form "cts08g01b"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)
 let param.linha5 = cts08g01_center(param.linha5)
 let param.linha6 = cts08g01_center(param.linha6)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha6

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts08g01b at 19,32 with 02 rows, 20 columns
    menu ""
       command key ("N", interrupt) "NAO"
          error " Confirmacao cancelada!"
          exit menu

       command key ("S")            "SIM"
          let ws.confirma = "S"
          exit menu
    end menu
    close window m_cts08g01b
 else
    message " (F17)Abandona"
    input by name d_cts08g01.confirma without defaults
       after field confirma
          next field confirma

       on key (interrupt, control-c)
          exit input
    end input
 end if

 let int_flag = false
 close window w_cts08g01b

 return ws.confirma

end function  ###  cts08g01_6l

#-----------------------------------------------------------------------------
 function cts08g01_8l(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    linha5           char (40),
    linha6           char (40),
    linha7           char (40),
    linha8           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record



        initialize  d_cts08g01.*  to  null

        initialize  ws.*  to  null

 open window w_cts08g01c at 09,19 with form "cts08g01c"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)
 let param.linha5 = cts08g01_center(param.linha5)
 let param.linha6 = cts08g01_center(param.linha6)
 let param.linha7 = cts08g01_center(param.linha7)
 let param.linha8 = cts08g01_center(param.linha8)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha8

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts08g01c at 20,32 with 02 rows, 20 columns
    menu ""
       command key ("N", interrupt) "NAO"
          error " Confirmacao cancelada!"
          exit menu

       command key ("S")            "SIM"
          let ws.confirma = "S"
          exit menu
    end menu
    close window m_cts08g01c
 else
    message " (F17)Abandona"
    input by name d_cts08g01.confirma without defaults
       after field confirma
          next field confirma

       on key (interrupt, control-c)
          exit input
    end input
 end if

 let int_flag = false
 close window w_cts08g01c

 return ws.confirma

end function  ###  cts08g01_8l

#--------------------[ inverte o SIM e o NAO ]--------------------------------
 function cts08g01_inverte(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record



        initialize  d_cts08g01.*  to  null

        initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "S"

 if param.conflg = "S"  then
    open window m_cts08g01 at 18,32 with 02 rows, 20 columns
    menu ""
       command key ("S")            "SIM"
          exit menu

       command key ("N", interrupt) "NAO"
          let ws.confirma = "N"
          error " Confirmacao cancelada!"
          exit menu
    end menu
    close window m_cts08g01
 else
    message " (F17)Abandona"
    input by name d_cts08g01.confirma without defaults
       after field confirma
          next field confirma

       on key (interrupt, control-c)
          exit input
    end input
 end if

 let int_flag = false
 close window w_cts08g01

 return ws.confirma


 end function
#-----------------------------------------------------------------------------
 function cts08g01_center(param)
#-----------------------------------------------------------------------------

 define param        record
    lintxt           char (40)
 end record

 define i            smallint
 define tamanho      dec (2,0)


        let     i  =  null
        let     tamanho  =  null

 let tamanho = (40 - length(param.lintxt))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function  ###  cts08g01_center

#-----------------------------------------------------------------------------
 function cts08g01_opcao_funcao(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    tp_funcao        integer
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record
 define hist_cts08g01 record
     hist1             like datmservhist.c24srvdsc ,
     hist2             like datmservhist.c24srvdsc ,
     hist3             like datmservhist.c24srvdsc ,
     hist4             like datmservhist.c24srvdsc ,
     hist5             like datmservhist.c24srvdsc
  end record
 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g01.*  to  null
 initialize  hist_cts08g01.* to null

 initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "N"
      case param.tp_funcao
          when 1
               message " (F17)Abandona       (F5)Vantagens"
          when 2
               message " (F17)Abandona       (F6)Historico"
          otherwise
               message " (F17)Abandona"
      end case
      input by name d_cts08g01.confirma without defaults
         after field confirma
            next field confirma

         on key (interrupt, control-c)
            exit input
      on key (F5)
         case param.tp_funcao
             when 1
                call cty05g04_vantagens()
         end case
       on key (F6)
          case param.tp_funcao
             when 2
                call cts10m02(hist_cts08g01.*) returning hist_cts08g01.*
                exit input
          end case
      end input

 let int_flag = false
 close window w_cts08g01

 case param.tp_funcao
    when 1
       return ws.confirma
    when 2
       return ws.confirma,hist_cts08g01.*
    otherwise
        return ws.confirma
 end case

end function  ###  cts08g01

#-----------------------------------------------------------------------------
 function cts08g01_reclamacao(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g01.*  to  null

 initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4
 let ws.confirma = null
 if param.conflg = "S"  then
    open window m_cts08g01 at 18,32 with 02 rows, 20 columns
       menu ""
          command key ("S") "SIM"
             let ws.confirma = "S"
             exit menu

          command key ("N") "NAO"
             let ws.confirma = "N"
             exit menu
          command key (interrupt, control-c)
            exit menu
       end menu
    close window m_cts08g01
 else
   if param.conflg = 'N' or
      param.conflg is null then
      message " (F17)Abandona"
      input by name d_cts08g01.confirma without defaults
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
      else
         if  param.conflg = 'I' then
            open window m_cts08g01 at 18,32 with 02 rows, 20 columns
            menu ""
               command key ("N", interrupt) "NAO"
                  error " Confirmacao cancelada!"
                  let ws.confirma = "N"
                  exit menu
               command key ("S")            "SIM"
                  let ws.confirma = "S"
                  exit menu
            end menu
            close window m_cts08g01
         end if
      end if
   end if
 end if

 let int_flag = false
 close window w_cts08g01

 return ws.confirma

end function  ###  cts08g01

#-----------------------------------------------------------------------------
 function cts08g01_confirma(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cts08g01.*  to  null

 initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4
 let ws.confirma = null
 if param.conflg = 'F' then
    while true
       prompt '              CONFIRMA S/N?   ' for char ws.confirma

       let ws.confirma = upshift(ws.confirma)
       if ws.confirma = 'S' or ws.confirma = 'N' then
          exit while
       end if

    end while
 end if


 let int_flag = false
 close window w_cts08g01

 return ws.confirma

end function  ###  cts08g01

#-----------------------------------------------------------------------------
 function cts08g01_6l_confirma(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho                       
    conflg           char (01),  ###  Flag Confirmacao                        
    linha1           char (40),                                               
    linha2           char (40),                                               
    linha3           char (40),                                               
    linha4           char (40),                                               
    linha5           char (40),                                               
    linha6           char (40)                                                
 end record                                                                   
                                                                              
 define d_cts08g01   record                                                   
    cabtxt           char (40),                                               
    confirma         char (01)                                                
 end record                                                                   
                                                                              
 define ws           record                                                   
    confirma         char (01)                                                
 end record                                                                   
                                                                              
 initialize  d_cts08g01, ws to  null                                          
                                                                              
 open window w_cts08g01b at 10,19 with form "cts08g01b"                       
           attribute(border, form line first, message line last - 1)          
                                                                              
 case param.cabtip                                                            
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"                             
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"                  
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"                 
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"                   
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"                        
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"                 
 end case                                                                     
                                                                              
 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)                   
                                                                              
 let param.linha1 = cts08g01_center(param.linha1)                             
 let param.linha2 = cts08g01_center(param.linha2)                             
 let param.linha3 = cts08g01_center(param.linha3)                             
 let param.linha4 = cts08g01_center(param.linha4)                             
 let param.linha5 = cts08g01_center(param.linha5)                             
 let param.linha6 = cts08g01_center(param.linha6)                             
                                                                              
 display by name d_cts08g01.cabtxt  attribute (reverse)                       
 display by name param.linha1 thru param.linha6                               
                                                                              
 let ws.confirma = null                                                      
                                                                              
 if param.conflg = 'F' then                                              
    while true                                                           
       prompt '               CONFIRMA S/N?   ' for char ws.confirma               
                                                                         
       let ws.confirma = upshift(ws.confirma)                            
       if ws.confirma = 'S' or ws.confirma = 'N' then                    
          exit while                                                     
       end if                                                            
                                                                         
    end while                                                            
 end if                                                                   
                                                                              
 let int_flag = false                                                         
 close window w_cts08g01b                                                     
                                                                              
 return ws.confirma                                                           
                                                                              
end function  ###  cts08g01_6l    



#--------------------[ inverte o SIM e o NAO E resposta obrigat�ria ]--------------------------------
 function cts08g01_respostaobrigatoria(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts08g01   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

        initialize  d_cts08g01.*  to  null

        initialize  ws.*  to  null

 open window w_cts08g01 at 11,19 with form "cts08g01"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts08g01.cabtxt = "CONFIRME"
    when "I"  let  d_cts08g01.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts08g01.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts08g01.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts08g01.cabtxt = "A T E N C A O"
    when "U"  let  d_cts08g01.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts08g01.cabtxt = cts08g01_center(d_cts08g01.cabtxt)

 let param.linha1 = cts08g01_center(param.linha1)
 let param.linha2 = cts08g01_center(param.linha2)
 let param.linha3 = cts08g01_center(param.linha3)
 let param.linha4 = cts08g01_center(param.linha4)

 display by name d_cts08g01.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 let ws.confirma = "S"

 if param.conflg = "S"  then
    open window m_cts08g01 at 18,32 with 02 rows, 20 columns
    menu ""
       command key ("S")            "SIM"          
          exit menu

       command key ("N") "NAO"
          let ws.confirma = "N"          
          exit menu
       command key (interrupt)
          error " Por favor escolher uma op��o!"          
    end menu  
     
    
    close window m_cts08g01
 else
    message " (F17)Abandona"
    input by name d_cts08g01.confirma without defaults
       after field confirma
          next field confirma

       on key (interrupt, control-c)
          exit input
    end input
 end if

 let int_flag = false
 close window w_cts08g01

 return ws.confirma


 end function
                             