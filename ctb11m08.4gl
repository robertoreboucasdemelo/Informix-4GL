###############################################################################
# Nome do Modulo: CTB11M08                                           Gilberto #
#                                                                    Marcelo  #
# Informa valor total do servico (informado na relacao)              Dez/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb11m08()
#-----------------------------------------------------------

 define d_ctb11m08     record
    socopgitmvlr       like dbsmopgitm.socopgitmvlr
 end record

 let int_flag  =  false
 let d_ctb11m08.socopgitmvlr = 0.00

 open window ctb11m08 at 12,37 with form "ctb11m08"
             attribute (border, form line 1)

 input by name d_ctb11m08.*  without defaults

   before field socopgitmvlr
      display by name d_ctb11m08.socopgitmvlr    attribute (reverse)

   after field socopgitmvlr
      display by name d_ctb11m08.socopgitmvlr

      if d_ctb11m08.socopgitmvlr   is null   or
         d_ctb11m08.socopgitmvlr   = 0       then
         error " Valor total do servico deve ser informado!"
         next field socopgitmvlr
      end if

   on key (interrupt)
      let d_ctb11m08.socopgitmvlr = 0.00
      exit input

 end input

let int_flag = false
close window ctb11m08

return d_ctb11m08.socopgitmvlr

end function  ###  ctb11m08
