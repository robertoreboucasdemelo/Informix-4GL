############################################################################
# Menu de Modulo: CTC13M00                                           Pedro #
#                                                                  Marcelo #
# Manutencao do Cadastro de lista-OESP X Servicos                 Jan/1994 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
function ctc13m00(k_ctc13m00)
#----------------------------------------------------------------

   define k_ctc13m00 record
          emplstcod  like dparservlista.emplstcod,
          empnom     like dpaklista.empnom
   end record

   define a_ctc13m00 array[50] of record
      pstsrvtip like dparservlista.pstsrvtip,
      pstsrvdes like dpckserv.pstsrvdes
   end record

   define arr_aux      smallint
   define scr_aux      smallint
   define operacao_aux char(1)
   define ws_count     smallint

   define wspstsrvtip like dparservlista.pstsrvtip

   open window w_ctc13m00 at 6,2 with form "ctc13m00"
        attribute (form line first)

   display k_ctc13m00.emplstcod  to  emplstcod
   display k_ctc13m00.empnom     to  empnom

   declare c_ctc13m00 cursor for
      select
         dparservlista.pstsrvtip,
         dpckserv.pstsrvdes
      from dparservlista, dpckserv
      where
         dparservlista.emplstcod = k_ctc13m00.emplstcod and
         dpckserv.pstsrvtip      = dparservlista.pstsrvtip
      order by
	 dparservlista.pstsrvtip

   while true
      let int_flag = false

      let arr_aux = 1
      initialize a_ctc13m00  to null

      foreach c_ctc13m00 into a_ctc13m00[arr_aux].*
         let arr_aux = arr_aux + 1
         if arr_aux > 50 then
            error "Limite de consulta (50) excedido!"
            exit foreach
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc13m00 without defaults from s_ctc13m00.*

         before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let operacao_aux = "a"
                  let wspstsrvtip = a_ctc13m00[arr_aux].pstsrvtip
               end if

         before insert
            let operacao_aux = "i"
            initialize
               a_ctc13m00[arr_aux].pstsrvtip,
               a_ctc13m00[arr_aux].pstsrvdes  to null

            display a_ctc13m00[arr_aux].pstsrvtip  to
                    s_ctc13m00[scr_aux].pstsrvtip
            display a_ctc13m00[arr_aux].pstsrvdes  to
                    s_ctc13m00[scr_aux].pstsrvdes

         before field pstsrvtip
            display a_ctc13m00[arr_aux].pstsrvtip to
                    s_ctc13m00[scr_aux].pstsrvtip attribute (reverse)

         after field pstsrvtip
            display a_ctc13m00[arr_aux].pstsrvtip to
                    s_ctc13m00[scr_aux].pstsrvtip

            if a_ctc13m00[arr_aux].pstsrvtip is null or
               a_ctc13m00[arr_aux].pstsrvtip = " "   then
               error "Codigo do servico nao informado!"
               call ctn06c03() returning a_ctc13m00[arr_aux].pstsrvtip,
                                         a_ctc13m00[arr_aux].pstsrvdes

               if a_ctc13m00[arr_aux].pstsrvtip is null or
                  a_ctc13m00[arr_aux].pstsrvtip =  " "  then
                  error "Tipo de servico e obrigatorio!"
                  next field pstsrvtip
               end if
            else
               select pstsrvdes
                 into a_ctc13m00[arr_aux].pstsrvdes
                 from dpckserv
                where pstsrvtip  =  a_ctc13m00[arr_aux].pstsrvtip

               if status = notfound then
                  error "Tipo de servico nao cadastrado!"

                  call ctn06c03() returning a_ctc13m00[arr_aux].pstsrvtip,
                                            a_ctc13m00[arr_aux].pstsrvdes

                  if a_ctc13m00[arr_aux].pstsrvtip is null or
                     a_ctc13m00[arr_aux].pstsrvtip =  " "  then
                     error "Tipo de servico e obrigatorio!"
                     next field pstsrvtip
                  end if
               end if
            end if

            display a_ctc13m00[arr_aux].pstsrvdes to
                    s_ctc13m00[scr_aux].pstsrvdes

            if operacao_aux = "a"  then
               if wspstsrvtip  <> a_ctc13m00[arr_aux].pstsrvtip  then
                  error "Nao pode alterar codigo do servico!"
                  next field pstsrvtip
               end if
            end if

            #------------------------------------------
            # Verifica existencia do assunto a incluir
            #------------------------------------------
            if operacao_aux = "i"  then
               select *
                  from
                     dparservlista
                  where
                     emplstcod = k_ctc13m00.emplstcod           and
                     pstsrvtip = a_ctc13m00[arr_aux].pstsrvtip

               if status <> notfound then
                  error " Codigo de servico ja' cadastrado!"
                  next field pstsrvtip
               end if
            end if

         on key (interrupt)
            exit input

         before delete
            let operacao_aux = "d"
            if a_ctc13m00[arr_aux].pstsrvtip  is null   then
               continue input
            else
               if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                  exit input
               end if

               let ws_count = 0
               select count(*)
                 into ws_count
                 from dparservlista
                where emplstcod = k_ctc13m00.emplstcod

               if ws_count = 1   then
                  error "Empresa deve possuir no minimo um servico cadastrado !"
                  exit input
               end if

               begin work
               delete from  dparservlista
                      where emplstcod = k_ctc13m00.emplstcod          and
                            pstsrvtip = a_ctc13m00[arr_aux].pstsrvtip
               commit work

               initialize a_ctc13m00[arr_aux].* to null
               display a_ctc13m00[arr_aux].* to s_ctc13m00[scr_aux].*
            end if

         after row
            begin work
            case operacao_aux
               when "i"
                  insert into dparservlista (emplstcod,
                                             pstsrvtip
                                            )
                                      values
                                            (
                                             k_ctc13m00.emplstcod,
                                             a_ctc13m00[arr_aux].pstsrvtip
                                            )
            end case

            commit work

            let operacao_aux = " "

          end input

    if int_flag  then
       clear form
       exit while
    end if

end while

let int_flag = false

close c_ctc13m00

close window w_ctc13m00

end function
