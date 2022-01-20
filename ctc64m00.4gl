###########################################################################
# Nome do Modulo: ctc64m00                                       Ligia    #
#                                                                         #
# Cadastro de clausulas da Azul Seguros na datkgeral             Nov/2006 #
###########################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc64m00()
#------------------------------------------------------------

 define a_ctc64m00    array[200] of record
    codigo            char(03),
    descricao         char(30)
 end record

 define arr_aux       smallint
 define scr_aux       smallint
 define l_grlchv      like datkgeral.grlchv
 define l_grlinf      like datkgeral.grlinf

 let int_flag = false
 let l_grlchv = null
 let l_grlinf = null

 initialize a_ctc64m00 to null

 open window ctc64m00 at 06,02 with form "ctc64m00"
      attribute (form line first)

 declare c_datkgeral cursor for
    select grlchv[10,12], grlinf
      from datkgeral
     where grlchv[1,9] = "CLS.AZUL."
     order by 2

 let arr_aux = 1

 foreach c_datkgeral into a_ctc64m00[arr_aux].codigo,
                          a_ctc64m00[arr_aux].descricao

    let arr_aux = arr_aux + 1

    if arr_aux > 100  then
       error " Limite excedido! Foram encontrados mais de 100 dominios!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 input array a_ctc64m00 without defaults from s_ctc64m00.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before field codigo
             display a_ctc64m00[arr_aux].codigo to s_ctc64m00[scr_aux].codigo
                     attribute(reverse) 
   
       after field codigo
             display a_ctc64m00[arr_aux].codigo to s_ctc64m00[scr_aux].codigo

             if a_ctc64m00[arr_aux].codigo is null then
                error " Informe o codigo da clausula"
                next field codigo
             end if

        before field descricao
               display a_ctc64m00[arr_aux].descricao to 
                       s_ctc64m00[scr_aux].descricao attribute(reverse)

        after field descricao
              display a_ctc64m00[arr_aux].descricao to 
                      s_ctc64m00[scr_aux].descricao

              if a_ctc64m00[arr_aux].descricao is null then
                 error " Informe a descricao da clausula"
                 next field descricao
              end if

        after row

             if a_ctc64m00[arr_aux].codigo is not null and
                a_ctc64m00[arr_aux].descricao is not null then

                let l_grlchv = "CLS.AZUL.", a_ctc64m00[arr_aux].codigo

                begin work

                call cts40g23_busca_chv(l_grlchv)
                     returning l_grlinf
   
                if l_grlinf is null then
                   call cts40g23_insere_chv
                        (l_grlchv, a_ctc64m00[arr_aux].descricao, 
                         g_issk.empcod, g_issk.funmat)
   
                else
                   update datkgeral set grlinf = a_ctc64m00[arr_aux].descricao,
                                        atldat = today,
                                        atlhor = current,
                                        atlemp = g_issk.empcod,
                                        atlmat = g_issk.funmat
                          where grlchv = l_grlchv
                end if
   
                if sqlca.sqlcode <> 0  then
                   rollback work
                   error " Erro (", sqlca.sqlcode, ")"
                else
                   commit work
                end if
             end if
   
        before delete
             let arr_aux = arr_curr()
             let l_grlchv = "CLS.AZUL.", a_ctc64m00[arr_aux].codigo

             begin work
             call cts40g23_apaga_chv(l_grlchv)
             initialize a_ctc64m00[arr_aux].* to null
             commit work

        on key (interrupt, control-c)
           let int_flag = true
           exit input

 end input

 let int_flag = false
 close window ctc64m00

end function
