###############################################################################
# Nome do Modulo: CTC35M09                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Mostra todos os Tipos de laudo                                     Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc35m09()
#---------------------------------------------------------------

  define a_ctc35m09    array[30] of record
     socvstlautipdes   like datkvstlautip.socvstlautipdes,
     socvstlautipcod   like datkvstlautip.socvstlautipcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctc35m09 at 10,29 with form "ctc35m09"
       attribute(form line first, border)

  declare c_ctc35m09 cursor for
     select socvstlautipdes,
            socvstlautipcod
       from datkvstlautip
      where socvstlautipcod  >  0
        and socvstlautipsit  = "A"
      order by socvstlautipdes

  initialize a_ctc35m09  to null
  let arr_aux = 1

  foreach c_ctc35m09 into a_ctc35m09[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de Tipos de laudo com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctc35m09 to s_ctc35m09.*
      on key (interrupt,control-c)
        initialize a_ctc35m09   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctc35m09
  close c_ctc35m09
  let int_flag = false

  return a_ctc35m09[arr_aux].socvstlautipcod

end function  #  ctc35m09

