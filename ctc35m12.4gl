###############################################################################
# Nome do Modulo: CTC35M12                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Mostra todas as verificacoes de itens                              Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc35m12()
#---------------------------------------------------------------

  define a_ctc35m12    array[30] of record
     socvstitmverdes      like datkvstitmver.socvstitmverdes,
     socvstitmvercod      like datkvstitmver.socvstitmvercod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctc35m12 at 10,29 with form "ctc35m12"
       attribute(form line first, border)

  declare c_ctc35m12 cursor for
     select socvstitmverdes,
            socvstitmvercod
       from datkvstitmver
      where socvstitmvercod  >  0
        and socvstitmversit  = "A"
      order by socvstitmverdes

  initialize a_ctc35m12  to null
  let arr_aux = 1

  foreach c_ctc35m12 into a_ctc35m12[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de Verificacao de Itens com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctc35m12 to s_ctc35m12.*
      on key (interrupt,control-c)
        initialize a_ctc35m12   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctc35m12
  close c_ctc35m12
  let int_flag = false

  return a_ctc35m12[arr_aux].socvstitmvercod

end function  #  ctc35m12

