###############################################################################
# Nome do Modulo: CTC14M02                                           Pedro    #
#                                                                    Marcelo  #
# Mostra acao a ser tomada pelo sistema de acordo c/ assunto         Jun/1995 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc14m02()
#-----------------------------------------------------------

 define a_ctc14m02 array[50] of record
    prgdes     like iddkdominio.cpodes,
    prgcod     like datkassunto.prgcod
 end record

 define arr_aux    smallint

 open window ctc14m02 at 10,40 with form "ctc14m02"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_ctc14m02  to null

 let arr_aux = 1

 declare c_ctc14m02 cursor for
    select cpocod, cpodes
      from iddkdominio
     where cponom = "prgcod"

 foreach c_ctc14m02  into  a_ctc14m02[arr_aux].prgcod,
                           a_ctc14m02[arr_aux].prgdes
    let arr_aux = arr_aux + 1
 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux - 1)

 display array a_ctc14m02 to s_ctc14m02.*

    on key (interrupt,control-c)
       initialize a_ctc14m02   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

   end display

   close window  ctc14m02

   return a_ctc14m02[arr_aux].prgcod,
          a_ctc14m02[arr_aux].prgdes

end function  ###  ctc14m02
