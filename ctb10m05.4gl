###############################################################################
# Nome do Modulo: CTB10M05                                            Marcelo #
#                                                                    Gilberto #
# Mostra todos as tarifas do Porto Socorro                           Nov/1996 #
###############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
function ctb10m05()
#--------------------------------------------------------------

  define a_ctb10m05 array[30] of record
     soctrfdes   like dbsktarifasocorro.soctrfdes,
     soctrfcod   like dbsktarifasocorro.soctrfcod
  end record

  define arr_aux      integer
  define scr_aux      integer

  open window w_ctb10m05 at 10,29 with form "ctb10m05"
       attribute(form line first, border)

  declare c_ctb10m05 cursor for
     select soctrfdes,
            soctrfcod
       from dbsktarifasocorro
      where soctrfcod  >  0
      order by soctrfdes

  initialize a_ctb10m05  to null
  let arr_aux = 1

  foreach c_ctb10m05 into a_ctb10m05[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de tarifas com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctb10m05 to s_ctb10m05.*
      on key (interrupt,control-c)
        initialize a_ctb10m05   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctb10m05
  close c_ctb10m05
  let int_flag = false

  return a_ctb10m05[arr_aux].soctrfcod

end function  #  ctb10m05

