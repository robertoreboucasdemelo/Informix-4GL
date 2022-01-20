###############################################################################
# Nome do Modulo: CTB02M07                                           Wagner   #
#                                                                             #
# Exibe pop-up para selecao do item adicionais/exd. carro-extra      Out/2000 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb02m07(param)
#-----------------------------------------------------------

 define param      record
    soctip         like dbskcustosocorro.soctip,
    valor          dec (15,5)
 end record

 define a_ctb02m07 array[50] of record
    soccstdes      like dbskcustosocorro.soccstdes,
    soccstcod      like dbskcustosocorro.soccstcod
 end record

 define ws_soccstcod like dbskcustosocorro.soccstcod
 define arr_aux      smallint

   open window ctb02m07 at 08,25 with form "ctb02m07"
                        attribute(form line 1, border)

   display by name param.valor

   let int_flag = false
   initialize a_ctb02m07  to null

   declare c_ctb02m07 cursor for
     select soccstdes, soccstcod
       from dbskcustosocorro
      where soctip = param.soctip     #  Carro-extra
      order by soccstdes

   let arr_aux  = 1

   foreach c_ctb02m07 into a_ctb02m07[arr_aux].soccstdes,
                           a_ctb02m07[arr_aux].soccstcod

      let arr_aux = arr_aux + 1
      if arr_aux  >  50   then
         error "Limite excedido, tabela de excedentes com mais de 50 itens!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   initialize ws_soccstcod to null

   display array a_ctb02m07 to s_ctb02m07.*

      on key (interrupt,control-c)
         initialize a_ctb02m07   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ws_soccstcod  = a_ctb02m07[arr_aux].soccstcod
         exit display

   end display

   if ws_soccstcod is null then
      let ws_soccstcod = 0
   end if

   let int_flag = false
   close window  ctb02m07
   return ws_soccstcod

end function  #  ctb02m07
