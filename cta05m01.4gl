###############################################################################
# Nome do Modulo: CTA05M01                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up para exibir todos os codigos de situacao para reclamacoes   Jul/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cta05m01()
#-----------------------------------------------------------

 define a_cta05m01 array[10] of record
    cpocod    like iddkdominio.cpocod,
    cpodes    like iddkdominio.cpodes
 end record

 define arr_aux    smallint

 open window cta05m01 at 10,53 with form "cta05m01"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_cta05m01  to null

 declare c_cta05m01    cursor for
    select cpocod, cpodes
      from iddkdominio
     where cponom = "c24rclsitcod"

 let arr_aux = 1

 foreach c_cta05m01 into a_cta05m01[arr_aux].cpocod,
                         a_cta05m01[arr_aux].cpodes

    if a_cta05m01[arr_aux].cpocod >= 1  and
       a_cta05m01[arr_aux].cpocod <= 4  then
       continue foreach
    end if

    let arr_aux = arr_aux + 1
    if arr_aux  >  10   then
       error " Limite excedido. Existem mais de 10 status cadastrados!"
       exit foreach
    end if
 end foreach

 if arr_aux = 1  then
    error " Nao existe codigo de situacao cadastrado! AVISE A INFORMATICA!"
 else
    message "(F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_cta05m01 to s_cta05m01.*

       on key (interrupt,control-c)
          initialize a_cta05m01  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          exit display

    end display
 end if

 close window  cta05m01
 let int_flag = false
 return a_cta05m01[arr_aux].cpocod

end function  ###  cta05m01
