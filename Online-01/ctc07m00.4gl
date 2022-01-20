############################################################################
# Nome do Modulo: CTC07M00                                           Pedro #
#                                                                          #
# Manutencao no Cadastro de Guincho X Prestador                   Set/1994 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc07m00( k_ctc07m00 )
#----------------------------------------------------------------

 define arr_aux smallint
 define scr_aux smallint
 define operacao_aux char(1)

 define k_ctc07m00 record
    pstcoddig like dpatguincho.pstcoddig,
    nomgrr    like dpaksocor.nomgrr
 end record

 define a_ctc07m00 array[100] of record
    gchtip like dpatguincho.gchtip,
    gchdes like dpckguincho.gchdes,
    gchqtd like dpatguincho.gchqtd
 end record

 options comment line last - 2

 open window ctc07m00 at 06,02 with form "ctc07m00"
      attribute(form line first)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 display by name k_ctc07m00.*

 declare c_ctc07m00 cursor for
    select dpatguincho.gchtip,
           dpckguincho.gchdes,
           dpatguincho.gchqtd
      from dpatguincho, dpckguincho
     where dpatguincho.pstcoddig = k_ctc07m00.pstcoddig  and
           dpckguincho.gchtip    = dpatguincho.gchtip
     order by dpatguincho.gchtip

    let int_flag = false

    while not int_flag
       let arr_aux = 1
       foreach c_ctc07m00 into a_ctc07m00[arr_aux].*
          let arr_aux = arr_aux + 1
          if arr_aux > 100 then
             error " Limite de manutencao excedido(100), AVISE A INFORMATICA!"
             sleep 5
             exit program
          end if
       end foreach

       call set_count(arr_aux-1)

       input array a_ctc07m00 without defaults from s_ctc07m00.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count() then
             begin work
                let operacao_aux = "a"
	        display a_ctc07m00[arr_aux].*  to  s_ctc07m00[scr_aux].*
                next field gchqtd
          end if

       before insert
          let operacao_aux = "i"
          initialize
             a_ctc07m00[arr_aux].gchtip,
             a_ctc07m00[arr_aux].gchdes,
             a_ctc07m00[arr_aux].gchqtd
          like
             dpatguincho.gchtip,
             dpckguincho.gchdes,
             dpatguincho.gchqtd

          display a_ctc07m00[arr_aux].* to s_ctc07m00[scr_aux].*

       before field gchtip
          if operacao_aux = "a" then
 	    next field gchqtd
           end if
          display a_ctc07m00[arr_aux].gchtip    to
 	         s_ctc07m00[scr_aux].gchtip attribute (reverse)

       after field gchtip
          display a_ctc07m00[arr_aux].gchtip    to
                  s_ctc07m00[scr_aux].gchtip

          #---------------------------------------------------------
          # Verifica existencia da linha a incluir
          #---------------------------------------------------------
          select *
            from dpatguincho
           where pstcoddig = k_ctc07m00.pstcoddig       and
                 gchtip    = a_ctc07m00[arr_aux].gchtip

          if status <> notfound then
             error " Tipo de guincho ja' cadastrado p/ este prestador !"
             next field gchtip
          end if

          #---------------------------------------------------------
          # Verificacao de integridade da chave fkdpckguincho
          #---------------------------------------------------------
          select gchdes
            into a_ctc07m00[arr_aux].gchdes
            from dpckguincho
           where gchtip = a_ctc07m00[arr_aux].gchtip

          if status = notfound then
             error " Nao existe correspondente em guincho, selecione!"

             call ctn01c02() returning  a_ctc07m00[arr_aux].gchtip,
                                        a_ctc07m00[arr_aux].gchdes
             if a_ctc07m00[arr_aux].gchtip   is null   then
                 error " Tipo do guincho e' item obrigatorio!"
             end if
             next field gchtip
          end if

          display a_ctc07m00[arr_aux].gchtip    to
                  s_ctc07m00[scr_aux].gchtip
          display a_ctc07m00[arr_aux].gchdes    to
                  s_ctc07m00[scr_aux].gchdes

       before field gchqtd
          display a_ctc07m00[arr_aux].gchqtd to s_ctc07m00[scr_aux].gchqtd
                                                attribute (reverse)

       after field gchqtd
          display a_ctc07m00[arr_aux].gchqtd to s_ctc07m00[scr_aux].gchqtd

          if a_ctc07m00[arr_aux].gchqtd  is null   then
             error " Informe a quantidade!"
             next field gchqtd
          end if

       on key (interrupt)
          exit input

       before delete
          if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
             exit input
          end if

          if not delete_dpatguincho (k_ctc07m00.pstcoddig,
                                     a_ctc07m00[arr_aux].gchtip ) then
 	    error " Remocao nao permitida, existe correspondente!"
             sleep 3
 	    let int_flag = false
             exit input
          end if

          if operacao_aux = "a" then
 	    commit work
             let operacao_aux = " "
          end if

 	 initialize a_ctc07m00[arr_aux].* to null
          let operacao_aux = "d"

 	 display a_ctc07m00[arr_aux].*    to s_ctc07m00[scr_aux].*

       after row
          if a_ctc07m00[arr_aux].gchtip is null then
             let operacao_aux = " "
             error " Tipo de guincho nao selecionado!"
             continue input
          end if

          case operacao_aux

 	 when "a"
             update dpatguincho set
 	           gchqtd    = a_ctc07m00[arr_aux].gchqtd
             where
                    pstcoddig = k_ctc07m00.pstcoddig       and
                    gchtip    = a_ctc07m00[arr_aux].gchtip

             commit work

          when "i"
             insert into dpatguincho ( pstcoddig,
 	                               gchtip,
 	                               gchqtd )
                              values
                                     ( k_ctc07m00.pstcoddig,
                                       a_ctc07m00[arr_aux].gchtip,
                                       a_ctc07m00[arr_aux].gchqtd )

          end case
          let operacao_aux = " "
       end input

       if operacao_aux = "a" then
          rollback work
       end if
  end while

 let int_flag = false

 close window ctc07m00
 options comment line last

end function  #  ctc07m00
