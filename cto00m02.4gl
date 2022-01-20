###############################################################################
# Nome do Modulo: CTO00M02                                           Ruiz     #
#                                                                    Akio     #
# Mostra acao a ser tomada pelo sistema de acordo c/ assunto         Abr/2000 #
###############################################################################

database porto

#-----------------#
function cto00m02()
#-----------------#

 define a_cto00m02 array[100] of record
        prgextdes  like dackprgext.prgextdes,
        prgextcod  like dackprgext.prgextcod
 end record

 define arr_aux    smallint

 open window cto00m02 at 10,40 with form "cto00m02"
    attribute(form line 1, border)

 let int_flag = false

 initialize a_cto00m02 to null

 let arr_aux = 1

 declare c_cto00m02 cursor for
 select prgextdes,prgextcod
   from dackprgext
  order by prgextdes

 foreach c_cto00m02  into  a_cto00m02[arr_aux].prgextdes, a_cto00m02[arr_aux].prgextcod

    let arr_aux = arr_aux + 1

 end foreach

 message "  (F17)Abandona, (F8)Seleciona"

 call set_count(arr_aux - 1)

 display array a_cto00m02 to s_cto00m02.*

    on key (interrupt,control-c)
       initialize a_cto00m02   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

  end display

  close window  cto00m02

  let int_flag = false

  return a_cto00m02[arr_aux].prgextcod, a_cto00m02[arr_aux].prgextdes

end function  ###  cto00m02
