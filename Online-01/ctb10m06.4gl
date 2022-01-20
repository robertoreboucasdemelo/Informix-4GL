###############################################################################
# Nome do Modulo: CTB10M06                                            Marcelo #
#                                                                    Gilberto #
# Mostra todos os custos do Porto Socorro                            Nov/1996 #
###############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
function ctb10m06()
#--------------------------------------------------------------

  define a_ctb10m06 array[30] of record
     soccstdes   like dbskcustosocorro.soccstdes,
     soccstcod   like dbskcustosocorro.soccstcod
  end record

  define arr_aux      integer
  define scr_aux      integer


  open window w_ctb10m06 at 10,29 with form "ctb10m06"
       attribute(form line first, border)

  declare c_ctb10m06 cursor for
     select soccstdes,
            soccstcod
       from dbskcustosocorro
      where soccstcod  >  0
      order by soccstdes

  initialize a_ctb10m06  to null
  let arr_aux = 1

  foreach c_ctb10m06 into a_ctb10m06[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 30 then
        error " Limite excedido, tabela de custos com mais de 30 itens"
        exit foreach
     end if
  end foreach

  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux-1)

  display array a_ctb10m06 to s_ctb10m06.*
      on key (interrupt,control-c)
        initialize a_ctb10m06   to null
        exit display

     on key (F8)
        let arr_aux = arr_curr()
        exit display
  end display

  close window  w_ctb10m06
  close c_ctb10m06
  let int_flag = false

  return a_ctb10m06[arr_aux].soccstcod

end function  #  ctb10m06

