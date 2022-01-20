database porto

#-----------------------------------------#
 function ctx29g00_verific_dv(l_ligdctnum)
#-----------------------------------------#
    define l_ligdctnum like datrligsemapl.ligdctnum,
           l_numero    integer,
           l_length    smallint,
           l_docnum    char(10),
           l_erro      smallint,
           l_mensagem  char(60),
           l_ind       smallint,
           l_dig       smallint,
           l_dv        smallint

    initialize l_numero,
               l_docnum,
               l_dv to null

    let l_docnum = l_ligdctnum
    let l_length  = length(l_docnum)
    if  l_length > 2 then
        let l_numero = l_docnum[1,l_length - 2]

        call ctx29g00_cal(l_numero)
             returning l_dv
        let l_numero = l_numero * 10
        let l_numero = l_numero + l_dv
        call ctx29g00_cal(l_numero)
             returning l_dv
        let l_numero = l_numero * 10
        let l_numero = l_numero + l_dv

        if  l_numero <> l_ligdctnum then
            let l_erro     = 1
            let l_mensagem = "Numero de contrato invalido"
        else
            let l_erro     = 0
            let l_mensagem = "Digito valido"
        end if
    else
        let l_erro     = 2
        let l_mensagem = 'Quantidade de numeros insufuciente para calcudo do digito.'
    end if

    return l_erro,
           l_mensagem


 end function

#----------------------------#
 function ctx29g00_cal(l_num)
#----------------------------#

     define l_num    integer,
            l_fator  smallint,
            l_aux    integer,
            l_ind    smallint,
            l_length smallint,
            l_aux2   char(10),
            l_aux3   smallint

     let l_aux   = 0
     let l_fator = 2
     let l_aux3  = 0

     let l_aux2 = l_num

     let l_length = length(l_aux2)

     for l_ind = l_length to 1 step -1

         let l_aux3 = l_aux2[l_ind]

         let l_aux3 = l_aux3 * l_fator

         let l_aux = l_aux + l_aux3

         let l_fator = l_fator + 1
     end for
     let l_aux =  l_aux mod 11
     let l_aux =  11 - l_aux
     if  l_aux = 10 or l_aux = 11 then
         let l_aux = 0
     end if

     if  l_aux < 0 then
         let l_aux = l_aux * -1
     end if

     return l_aux
 end function
