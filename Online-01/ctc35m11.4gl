###############################################################################
# Nome do Modulo: CTC35M11                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Mostra todos os Itens de vistoria                                  Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc35m11()
#---------------------------------------------------------------

  define a_ctc35m11    array[200] of record
     socvstitmdes      like datkvstitm.socvstitmdes,
     socvstitmcod      like datkvstitm.socvstitmcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctc35m11 at 10,29 with form "ctc35m11"
       attribute(form line first, border)

  declare c_ctc35m11 cursor for
     select socvstitmdes,
            socvstitmcod
       from datkvstitm
      where socvstitmcod  >  0
        and socvstitmsit  = "A"
      order by socvstitmdes

  initialize a_ctc35m11  to null
  let arr_aux = 1

  foreach c_ctc35m11 into a_ctc35m11[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 200 then
        error " Limite excedido, tabela de Itens de vistoria com mais de 200 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctc35m11 to s_ctc35m11.*
      on key (interrupt,control-c)
        initialize a_ctc35m11   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctc35m11
  close c_ctc35m11
  let int_flag = false

  return a_ctc35m11[arr_aux].socvstitmcod

end function  #  ctc35m11

