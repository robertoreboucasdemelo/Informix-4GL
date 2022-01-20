###############################################################################
# Nome do Modulo: CTC29M01                                           Marcelo  #
#                                                                    Gilberto #
# Mostra todos os relatorios disponiveis para solicitacao            Mai/1996 #
###############################################################################

database porto

#------------------------------------------------------------
 function ctc29m01()
#------------------------------------------------------------

   define a_ctc29m01 array[30] of record
          relsgl     like dgbkrel.relsgl,
          reldes     like dgbkrel.reldes
   end    record

   define arr_aux    smallint

   open window ctc29m01 at 10,23 with form "ctc29m01"
                        attribute(form line 1, border)

   let int_flag = false
   initialize  a_ctc29m01   to null

   declare c_ctc29m01    cursor for
     select relsgl, reldes
       from dgbkrel
      order by relsgl

   let arr_aux  = 1

   foreach c_ctc29m01 into a_ctc29m01[arr_aux].relsgl,
                           a_ctc29m01[arr_aux].reldes

      let arr_aux = arr_aux + 1
      if arr_aux  >  30   then
         error "Limite excedido, existem mais de 30 relatorios disponiveis!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc29m01 to s_ctc29m01.*

      on key (interrupt,control-c)
         initialize a_ctc29m01   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display

   end display

   close window  ctc29m01

   let int_flag = false
   return a_ctc29m01[arr_aux].relsgl

end function  #  ctc29m01
