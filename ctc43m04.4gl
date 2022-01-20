###############################################################################
# Nome do Modulo: ctc43m04                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up para escolha de botoes dos MDTs                             Jul/1999 #
###############################################################################

 database porto

#-----------------------------------------------------------
 function ctc43m04()
#-----------------------------------------------------------

 define a_ctc43m04   array[50] of record
   mdtbottxt         like datkmdtbot.mdtbottxt,
   mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define ws           record
    mdtbotcod        like datkmdtbot.mdtbotcod
 end record

 define arr_aux      smallint


 initialize ws.*        to null
 initialize a_ctc43m04  to null
 let int_flag = false
 let arr_aux  = 1

 declare c_ctc43m04 cursor for
   select mdtbottxt,
          mdtbotcod
     from datkmdtbot
    where datkmdtbot.mdtbotstt  =  "A"

 foreach c_ctc43m04 into a_ctc43m04[arr_aux].mdtbottxt,
                         a_ctc43m04[arr_aux].mdtbotcod

    let arr_aux = arr_aux + 1

    if arr_aux > 50  then
       error " Limite excedido. Existem mais de 50 botoes cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctc43m04 at 09,25 with form "ctc43m04"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctc43m04 to s_ctc43m04.*

       on key (interrupt,control-c)
          initialize a_ctc43m04    to null
          initialize ws.mdtbotcod  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.mdtbotcod  =  a_ctc43m04[arr_aux].mdtbotcod
          exit display

    end display

    let int_flag = false
    close window ctc43m04
 else
    initialize ws.mdtbotcod to null
    error " Nao existem botoes cadastrados!"
 end if

 return ws.mdtbotcod

end function    ###-- ctc43m04
