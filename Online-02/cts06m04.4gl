###############################################################################
# Nome do Modulo: CTS06M04                                              Pedro #
#                                                                     Marcelo #
# Autorizacao de Marcacao de Vistoria Com Limite Excedido            Fev/1995 #
###############################################################################


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
function cts06m04()
#------------------------------------------------------------
   define d_cts06m04    record
      atdatznom         like datmvistoria.atdatznom
   end record




	initialize  d_cts06m04.*  to  null

open window w_cts06m04 at  11,19 with form "cts06m04"
            attribute(border, form line 1)

initialize d_cts06m04.*   to null

input by name d_cts06m04.*

   before field atdatznom
      display by name d_cts06m04.atdatznom attribute (reverse)

   after field atdatznom
      display by name d_cts06m04.atdatznom

      if d_cts06m04.atdatznom  is null   then
         error " Informe o nome de quem autorizou a vistoria!"
         next field atdatznom
      end if

   on key (interrupt)
      exit input

   on key (F8)   #------ vistorias programadas ------#
      call cts06m03(today, g_issk.succod)

end input

let int_flag = false
close window  w_cts06m04
return d_cts06m04.atdatznom

end function  #  cts06m04

