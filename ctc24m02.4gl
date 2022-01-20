###############################################################################
# Nome do Modulo: CTC24M02                                           Marcelo  #
#                                                                    Gilberto #
# Exibe pop-up para selecao do convenio                              Mar/1996 #
#-----------------------------------------------------------------------------#
# CT-176303
# Leandro(FSW)- 04/03/2004 Alteracao no tamanho array a_ctc24m02 de 50 para 60#
###############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc24m02()
#-----------------------------------------------------------

   define a_ctc24m02 array[60] of record
          cpodes     like datkdominio.cpodes,
          cpocod     like datkdominio.cpocod
   end    record

   define ret_cvnnum like datktopcvn.cvnnum

   define arr_aux    integer

   open window ctc24m02 at 08,12 with form "ctc24m02"
                        attribute(form line 1, border)

   let int_flag = false
   initialize  a_ctc24m02   to null
   initialize  ret_cvnnum   to null

   declare c_ctc24m02    cursor for
     select  cpocod, cpodes
       from  datkdominio
       where cponom = "ligcvntip"

   let arr_aux  = 1

   foreach c_ctc24m02 into a_ctc24m02[arr_aux].cpocod,
                           a_ctc24m02[arr_aux].cpodes

      let arr_aux = arr_aux + 1
      if arr_aux  >  60   then
         error "Limite excedido, tabela de convenios com mais de 50 itens!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctc24m02 to s_ctc24m02.*

      on key (interrupt,control-c)
         initialize a_ctc24m02   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ret_cvnnum = a_ctc24m02[arr_aux].cpocod
         exit display

   end display

   let int_flag = false
   close window  ctc24m02
   close c_ctc24m02

   return ret_cvnnum

end function  #  ctc24m02
