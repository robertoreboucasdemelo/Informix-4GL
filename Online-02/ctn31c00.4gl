###############################################################################
# Nome do Modulo: CTN31C00                                                    #
#                                                                   Almeida   #
# Mostra todos os Assuntos                                          Maio/1998 #
###############################################################################

database porto
#main
# call ctn31c00()
#end main

#-----------------------------------------------------------
 function ctn31c00()
#-----------------------------------------------------------

 define r_datkassunto record like datkassunto.*

 define a_ctn31c00 array[200] of record
    c24astcod      like datkassunto.c24astcod,
    c24astdes      like datkassunto.c24astdes
 end record

 define arr_aux    smallint

 define sql        char (100)

 open window ctn31c00 at 10,14 with form "ctn31c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn31c00   to null

 declare c_ctn31c00    cursor for
    select c24astcod,c24astdes
      from datkassunto
      where c24aststt = "A"
    order by c24astcod

 let arr_aux  = 1

 foreach c_ctn31c00 into a_ctn31c00[arr_aux].c24astcod,
                         a_ctn31c00[arr_aux].c24astdes

    let arr_aux = arr_aux + 1
    if arr_aux  >  200   then
       error " Limite excedido, tabela de assuntos com mais de 200 itens!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn31c00 to s_ctn31c00.*

    on key (interrupt,control-c)
       initialize a_ctn31c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn31c00
 let int_flag = false

 return a_ctn31c00[arr_aux].c24astcod

end function  ###  ctn31c00
