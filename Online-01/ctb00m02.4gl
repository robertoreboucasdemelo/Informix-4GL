###############################################################################
# Nome do Modulo: CTB00M02                                           Marcelo  #
#                                                                    Gilberto #
# Exibe pop-up para selecao do item de pagto.                        Set/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb00m02()
#-----------------------------------------------------------

 define a_ctb00m02 array[50] of record
    c24pgtitmdes   like dblkpagitem.c24pgtitmdes,
    c24pgtitmcod   like dblkpagitem.c24pgtitmcod
 end record

 define retorno    record
    c24pgtitmcod   like dblkpagitem.c24pgtitmcod
 end record

 define arr_aux    smallint

   open window ctb00m02 at 08,25 with form "ctb00m02"
                        attribute(form line 1, border)

   let int_flag = false
   initialize a_ctb00m02           to null
   initialize retorno.c24pgtitmcod to null

   declare c_ctb00m02 cursor for
     select c24pgtitmcod, c24pgtitmdes
       from dblkpagitem
      order by c24pgtitmdes

   let arr_aux  = 1

   foreach c_ctb00m02 into a_ctb00m02[arr_aux].c24pgtitmcod,
                           a_ctb00m02[arr_aux].c24pgtitmdes

      let arr_aux = arr_aux + 1
      if arr_aux  >  50   then
         error "Limite excedido, tabela de pagamento com mais de 30 itens!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctb00m02 to s_ctb00m02.*

      on key (interrupt,control-c)
         initialize a_ctb00m02   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let retorno.c24pgtitmcod = a_ctb00m02[arr_aux].c24pgtitmcod
         exit display

   end display

   let int_flag = false
   close window  ctb00m02

   return retorno.c24pgtitmcod

end function  #  ctb00m02
