###############################################################################
# Nome do Modulo: ctc25m00                                           Marcus   #
#                                                                             #
# Tela de Seleccao de telas cadastradas para procedimentos           Abr/2002 #
###############################################################################

 database porto

 #------------------------------------------------------------------------
  function ctc25m04()
 #------------------------------------------------------------------------

 define d_ctc25m04      record
        telcod          like datktel.telcod,
        telnom          like datktel.telnom,
        teldsc          like datktel.teldsc,
        atldat          like datktel.atldat,
        atlusrtip       like datktel.atlusrtip,
        attemp          like datktel.atlemp,
        atlmat          like datktel.atlmat
 end record

 define a_ctc25m04      array[100] of record
        telnom          like datktel.telnom,
        teldsc          like datktel.teldsc,
        telcod          like datktel.telcod
 end record

 define arr_aux         smallint
 define scr_aux         smallint


 initialize a_ctc25m04  to null
 initialize d_ctc25m04  to null

 let arr_aux  =  1
 let scr_aux  =  1

 open window w_ctc25m04 at 8,12 with form "ctc25m04"
      attribute(border,form line 1)

 message " (F17)Abandona, (F8)Seleciona"

 declare c_datktel cursor with hold for
    select telcod,
           telnom,
           teldsc
      from datktel

 foreach c_datktel into a_ctc25m04[arr_aux].telcod,
                        a_ctc25m04[arr_aux].telnom,
                        a_ctc25m04[arr_aux].teldsc

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
       error " Limite excedido. Existem mais de 100 campos cadastrados!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 display  array a_ctc25m04 to s_ctc25m04.*

    on key (F8)
       let arr_aux = arr_curr()
       exit display

    on key (interrupt)
       initialize a_ctc25m04 to null
       exit display

 end display

 close window w_ctc25m04

 return a_ctc25m04[arr_aux].telcod,
        a_ctc25m04[arr_aux].telnom,
        a_ctc25m04[arr_aux].teldsc

 end function   ###--- ctc25m04
