###############################################################################
# Nome do Modulo: CTN33C00                                                    #
#                                                                   Almeida   #
# Mostra todos Ramos                                                Maio/1998 #
###############################################################################
#                            MANUTENCOES                                      #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 # 
#-----------------------------------------------------------------------------#
# 30/04/2008 Norton Nery-Meta    psi221112  Mudanca no nome da tabela         #
#                                           gtakram.                          #
#-----------------------------------------------------------------------------#
database porto

#-----------------------------------------------------------
 function ctn33c00()
#-----------------------------------------------------------

 define r_gtakram record like gtakram.*

 define a_ctn33c00 array[100] of record
     ramcod    like gtakram.ramcod,
     ramnom    like gtakram.ramnom
 end record

 define arr_aux    smallint
 define sql        char (100)


 open window ctn33c00 at 10,10 with form "ctn33c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn33c00   to null

 declare c_ctn33c00    cursor for
    select ramcod,ramnom
      from gtakram
      where empcod = 1
    order by ramcod

 let arr_aux  = 1

 foreach c_ctn33c00 into a_ctn33c00[arr_aux].ramcod,
                         a_ctn33c00[arr_aux].ramnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  100   then
       error " Limite excedido, tabela de ramursais com mais de 100!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn33c00 to s_ctn33c00.*

    on key (interrupt,control-c)
       initialize a_ctn33c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn33c00
 let int_flag = false

 return a_ctn33c00[arr_aux].ramcod

end function  ###  ctn33c00
