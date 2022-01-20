###############################################################################
# Nome do Modulo: ctc34m10                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Consulta Vistorias nao realizadas                                  Dez/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc34m10(param)
#-----------------------------------------------------------

 define param       record
    socvclcod       like datkveiculo.socvclcod,
    socvstdiaqtd    like datkveiculo.socvstdiaqtd
 end record

 define a_ctc34m10 array[20] of record
    socvstdat        like datmsocvst.socvstdat,
    socvstnum        like datmsocvst.socvstnum,
    socvsttip        like datmsocvst.socvsttip,
    socvsttip_des    char(11),
    socvstsit        like datmsocvst.socvstsit,
    socvstsit_des    char(20),
    socvstdat_new    like datmsocvst.socvstdat
 end record

 define ws          record
    confirma        char(1)
 end record

 define ws_ponteiro smallint
 define arr_aux     smallint
 define scr_aux     smallint

 initialize a_ctc34m10      to null
 initialize ws.*            to null
 let arr_aux = 1

 open window ctc34m10 at 10,12 with form "ctc34m10"
             attribute (form line first,border)

 message " Aguarde, pesquisando..."  attribute(reverse)

 declare c_ctc34m10  cursor for
  select datmsocvst.socvstdat,
         datmsocvst.socvstnum,
         datmsocvst.socvsttip,
         datmsocvst.socvstsit
    from datmsocvst
   where datmsocvst.socvclcod  = param.socvclcod
     and datmsocvst.socvstsit in (1,2)
     and datmsocvst.socvstdat >= today
   order by datmsocvst.socvstdat

   foreach  c_ctc34m10  into  a_ctc34m10[arr_aux].socvstdat,
                              a_ctc34m10[arr_aux].socvstnum,
                              a_ctc34m10[arr_aux].socvsttip,
                              a_ctc34m10[arr_aux].socvstsit

    if a_ctc34m10[arr_aux].socvsttip = 1 then
       call ctc35m15(param.socvclcod, param.socvstdiaqtd)
            returning a_ctc34m10[arr_aux].socvstdat_new
       let ws_ponteiro  = arr_aux
    end if

    # MONTA DESCRICAO TIPO
      select cpodes
        into a_ctc34m10[arr_aux].socvsttip_des
        from iddkdominio
       where cponom = "socvsttip"
         and cpocod = a_ctc34m10[arr_aux].socvsttip

      if sqlca.sqlcode <> 0 then
         let a_ctc34m10[arr_aux].socvsttip_des = "NAO EXISTE"
      end if

    # MONTA DESCRICAO SITUACAO
      select cpodes
        into a_ctc34m10[arr_aux].socvstsit_des
        from iddkdominio
       where cponom = "socvstsit"
         and cpocod = a_ctc34m10[arr_aux].socvstsit

      if sqlca.sqlcode <> 0 then
         let a_ctc34m10[arr_aux].socvstsit_des = "NAO EXISTE"
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 20 then
         error "Limite excedido. Pesquisa com mais de 20 vistorias!"
         exit foreach
      end if

   end foreach

   if arr_aux  > 1   then

      call set_count(arr_aux-1)

      message " (F17)Abandona"

      display array  a_ctc34m10 to s_ctc34m10.*
        on key(interrupt)
           exit display

      end display

      message " "


      if ws_ponteiro is not null then
         call cts08g01("C","S","","ATUALIZA NOVA DATA PARA VISTORIA","","")
              returning ws.confirma
       else
        let ws.confirma = "N"
        let ws_ponteiro = 1
        initialize a_ctc34m10      to null
      end if
    else
      error "Nao existe Vistoria para este veiculo!"
      initialize a_ctc34m10 to null
      let ws.confirma = "N"
      let ws_ponteiro = 1
      initialize a_ctc34m10      to null
   end if

let int_flag = false
close window ctc34m10

return ws.confirma,
       a_ctc34m10[ws_ponteiro].socvstnum,
       a_ctc34m10[ws_ponteiro].socvstdat_new

end function  #  ctc34m1
