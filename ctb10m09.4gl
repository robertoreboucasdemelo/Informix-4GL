###############################################################################
# Nome do Modulo: CTB10M09                                            Marcelo #
#                                                                    Gilberto #
# Mostra todos os grupos tarifarios do Porto Socorro                 Dez/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctb10m09()
#---------------------------------------------------------------

  define a_ctb10m09 array[30] of record
     socgtfdes   like dbskgtf.socgtfdes,
     socgtfcod   like dbskgtf.socgtfcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctb10m09 at 10,29 with form "ctb10m09"
       attribute(form line first, border)

  declare c_ctb10m09 cursor for
     select socgtfdes,
            socgtfcod
       from dbskgtf
      where socgtfcod  >  0
        and socgtfstt <> "C"
      order by socgtfdes

  initialize a_ctb10m09  to null
  let arr_aux = 1

  foreach c_ctb10m09 into a_ctb10m09[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de grupo tarifario com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctb10m09 to s_ctb10m09.*
      on key (interrupt,control-c)
        initialize a_ctb10m09   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctb10m09
  close c_ctb10m09
  let int_flag = false

  return a_ctb10m09[arr_aux].socgtfcod

end function  #  ctb10m09

