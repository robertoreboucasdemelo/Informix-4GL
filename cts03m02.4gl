###############################################################################
# Nome do Modulo: CTS03M02                                           Marcelo  #
#                                                                    Gilberto #
# Informacoes sobre tipo do guincho e local                          Mai/1997 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#-----------------------------------------------------------
 function cts03m02(d_cts03m02)
#-----------------------------------------------------------

 define d_cts03m02    record
    atdvcltip         like datmservico.atdvcltip
 end record

 define ws            record
    atdvcltip         like datmservico.atdvcltip,
    atdvcldsc         char (15)
 end record



	initialize  ws.*  to  null

 initialize ws.* to null

 if d_cts03m02.atdvcltip = 2  then
    let ws.atdvcldsc = "Guincho Pequeno"
 else
    let d_cts03m02.atdvcltip = 1
    let ws.atdvcldsc = "Indiferente"
 end if

 open window cts03m02 at 11,26 with form "cts03m02"
                      attribute(border,form line 1)

 let int_flag = false

 display by name d_cts03m02.atdvcltip, ws.atdvcldsc

 input by name d_cts03m02.atdvcltip without defaults

   before field atdvcltip
      display by name d_cts03m02.atdvcltip  attribute (reverse)

   after  field atdvcltip
      display by name d_cts03m02.atdvcltip

      case d_cts03m02.atdvcltip
         when 1    let ws.atdvcldsc = "Indiferente"
         when 2    let ws.atdvcldsc = "Guincho Pequeno"
         otherwise error "Tipo de guincho invalido!"
                   next field atdvcltip
      end case

      display by name ws.atdvcldsc

   on key (interrupt)
      initialize d_cts03m02.atdvcltip to null
      exit input

 end input

 if int_flag then
    let int_flag = false
 end if

 close window cts03m02

 return d_cts03m02.atdvcltip

end function # cts03m02
