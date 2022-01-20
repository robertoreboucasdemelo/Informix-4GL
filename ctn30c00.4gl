###############################################################################
# Nome do Modulo: CTN30C00                                                    #
#                                                                   Almeida   #
# Mostra todos os Grupos                                            Maio/1998 #
###############################################################################

database porto
#main
# call ctn30c00()
#end main

#-----------------------------------------------------------
 function ctn30c00()
#-----------------------------------------------------------

 define a_ctn30c00 array[100] of record
    c24astagp      like datkastagp.c24astagp,
    c24astagpdes   like datkastagp.c24astagpdes
 end record

 define arr_aux    smallint

 define sql        char (100)

 open window ctn30c00 at 10,15 with form "ctn30c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn30c00   to null

 declare c_ctn30c00    cursor for
    select c24astagp,c24astagpdes
      from datkastagp
    where c24astagpsit = "A"
    order by c24astagp


 let arr_aux  = 1

 foreach c_ctn30c00 into a_ctn30c00[arr_aux].c24astagp,
                         a_ctn30c00[arr_aux].c24astagpdes

    let arr_aux = arr_aux + 1
    if arr_aux  >  100   then
       error " Limite excedido, tabela de grupos com mais de 100 itens!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn30c00 to s_ctn30c00.*

    on key (interrupt,control-c)
       initialize a_ctn30c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn30c00
 let int_flag = false

 return a_ctn30c00[arr_aux].c24astagp

end function  ###  ctn30c00
