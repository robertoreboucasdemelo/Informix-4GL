###############################################################################
# Nome do Modulo: CTC24M02                                              Raji  #
#                                                                             #
# Exibe pop-up para selecao da modalidade                            Fev/2002 #
###############################################################################
#                       MANUTENCOES
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#------------------------------------------------------------------------------

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc56m05(param)
#-----------------------------------------------------------
   define param record
      ramcod     like datkclstxt.ramcod
   end record

   define a_ctc56m05 array[200] of record
      rmemdlnom     like gtakmodal.rmemdlnom,
      rmemdlcod     like gtakmodal.rmemdlcod
   end    record

   define ret_rmemdlcod like datkclstxt.rmemdlcod

   define arr_aux    integer


	define	w_pf1	integer

	let	ret_rmemdlcod  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctc56m05[w_pf1].*  to  null
	end	for

   open window ctc56m05 at 08,12 with form "ctc56m05"
                        attribute(form line 1, border)

   let int_flag = false
   initialize  a_ctc56m05   to null
   initialize  ret_rmemdlcod   to null

   declare c_ctc56m05    cursor for
   select rmemdlcod, rmemdlnom
     from gtakmodal
    where ramcod = param.ramcod
      and empcod = 1

   let arr_aux  = 1

   foreach c_ctc56m05 into a_ctc56m05[arr_aux].rmemdlcod,
                           a_ctc56m05[arr_aux].rmemdlnom

      let arr_aux = arr_aux + 1
      if arr_aux  >  200   then
         error "Limite excedido, tabela modalidade com mais de 200 itens!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc56m05 to s_ctc56m05.*

      on key (interrupt,control-c)
         initialize a_ctc56m05   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ret_rmemdlcod = a_ctc56m05[arr_aux].rmemdlcod
         exit display

   end display

   let int_flag = false
   close window  ctc56m05
   close c_ctc56m05

   return ret_rmemdlcod

end function  #  ctc56m05
