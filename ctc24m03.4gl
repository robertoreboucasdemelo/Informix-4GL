#############################################################################
# Nome do Modulo: CTC24M03                                         Marcelo  #
#                                                                  Gilberto #
# Exibe pop-up para selecao do topico                              Mar/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 12/05/1999  Silmara      Gilberto     Limite do array ampliado de 30 para #
#                                       50 ocorrencias.                     #
#############################################################################

database porto

#-----------------------------------------------------------
 function ctc24m03(par_cvnnum)
#-----------------------------------------------------------

   define a_ctc24m03    array[50] of record
          cvntopnom     like datktopcvn.cvntopnom,
          cvntopcod     like datktopcvn.cvntopcod
   end    record

   define par_cvnnum    like datktopcvn.cvnnum
   define ret_cvntopcod like datktopcvn.cvnnum
   define ret_status    char(01)

   define arr_aux       smallint

   open window ctc24m03 at 08,12 with form "ctc24m03"
                        attribute(form line 1, border)

   let int_flag = false
   initialize  a_ctc24m03      to null
   initialize  ret_cvntopcod   to null
   initialize  ret_status      to null

   declare c_ctc24m03    cursor for
     select  cvntopcod, cvntopnom
       from  datktopcvn
       where cvnnum = par_cvnnum
       order by cvntopnom

   let arr_aux  = 1

   foreach c_ctc24m03 into a_ctc24m03[arr_aux].cvntopcod,
                           a_ctc24m03[arr_aux].cvntopnom

      let arr_aux = arr_aux + 1
      if arr_aux  >  50   then
         error "Limite excedido, tabela de convenios com mais de 50 itens!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc24m03 to s_ctc24m03.*

      on key (interrupt,control-c)
         initialize a_ctc24m03   to null
         let ret_status = 'X'
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ret_cvntopcod = a_ctc24m03[arr_aux].cvntopcod
         exit display

   end display

   let int_flag = false
   close window  ctc24m03

   return ret_cvntopcod, ret_status

end function  ###  ctc24m03
