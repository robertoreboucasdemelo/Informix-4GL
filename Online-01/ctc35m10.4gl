###############################################################################
# Nome do Modulo: CTC35M10                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Mostra todos os Grupos de itens                                    Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc35m10()
#---------------------------------------------------------------

  define a_ctc35m10    array[30] of record
     socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
     socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctc35m10 at 10,29 with form "ctc35m10"
       attribute(form line first, border)

  declare c_ctc35m10 cursor for
     select socvstitmgrpdes,
            socvstitmgrpcod
       from datkvstitmgrp
      where socvstitmgrpcod  >  0
        and socvstitmgrpsit  = "A"
      order by socvstitmgrpdes

  initialize a_ctc35m10  to null
  let arr_aux = 1

  foreach c_ctc35m10 into a_ctc35m10[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de Grupos com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctc35m10 to s_ctc35m10.*
      on key (interrupt,control-c)
        initialize a_ctc35m10   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctc35m10
  close c_ctc35m10
  let int_flag = false

  return a_ctc35m10[arr_aux].socvstitmgrpcod

end function  #  ctc35m10

