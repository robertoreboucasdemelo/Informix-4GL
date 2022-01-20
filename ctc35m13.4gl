###############################################################################
# Nome do Modulo: CTC35M13                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Mostra todos os Locais de vistoria                                 Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc35m13()
#---------------------------------------------------------------

  define a_ctc35m13    array[30] of record
     socvstlclnom      like datkvstlcl.socvstlclnom,
     socvstlclcod      like datkvstlcl.socvstlclcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctc35m13 at 10,29 with form "ctc35m13"
       attribute(form line first, border)

  declare c_ctc35m13 cursor for
     select socvstlclnom,
            socvstlclcod
       from datkvstlcl
      where socvstlclcod  >  0
        and socvstlclsit  = "A"
      order by socvstlclnom

  initialize a_ctc35m13  to null
  let arr_aux = 1

  foreach c_ctc35m13 into a_ctc35m13[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de Locais de vistoria com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctc35m13 to s_ctc35m13.*
      on key (interrupt,control-c)
        initialize a_ctc35m13   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctc35m13
  close c_ctc35m13
  let int_flag = false

  return a_ctc35m13[arr_aux].socvstlclcod

end function  #  ctc35m13

