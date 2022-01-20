############################################################################
# Menu de Modulo: CTC28M00                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao no Cadastro de Regioes                               Mai/1996 #
############################################################################

database porto

#---------------------------------------------------------------
 function ctc28m00()
#---------------------------------------------------------------

define a_ctc28m00   array[100] of record
   atdregcod        like datkatdreg.atdregcod,
   atdregdes        like datkatdreg.atdregdes
end record

define ws           record
   operacao         char(01)                 ,
   atdregcod        like datkatdreg.atdregcod,
   atdregdes        like datkatdreg.atdregdes
end record

define arr_aux      smallint
define scr_aux      smallint

  open window w_ctc28m00 at 06,02 with form "ctc28m00"
       attribute(form line first)

  declare c_ctc28m00 cursor for
     select atdregcod,
            atdregdes
       from datkatdreg
      order by atdregcod

  let arr_aux = 1
  initialize a_ctc28m00  to null
  initialize ws.*        to null

  foreach c_ctc28m00 into a_ctc28m00[arr_aux].*
     let arr_aux = arr_aux + 1
     if arr_aux > 100 then
        error "Limite excedido, tabela de regioes com mais de 300 itens."
        exit foreach
     end if
  end foreach
  call set_count(arr_aux-1)

  options
    comment line last - 2

  message " (F17)Abandona, (F8)Seleciona, (F1)Inclui, (F2)Exclui"

   while true
      let int_flag = false

      input array a_ctc28m00 without defaults from s_ctc28m00.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
                  let ws.atdregdes = a_ctc28m00[arr_aux].atdregdes
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctc28m00[arr_aux].atdregdes  to null

               display a_ctc28m00[arr_aux].atdregdes to
                       s_ctc28m00[scr_aux].atdregdes

            before field atdregdes
               display a_ctc28m00[arr_aux].atdregdes to
                       s_ctc28m00[scr_aux].atdregdes attribute (reverse)

            after field atdregdes
               display a_ctc28m00[arr_aux].atdregdes to
                       s_ctc28m00[scr_aux].atdregdes


               if fgl_lastkey() = fgl_keyval("down")   then
                  if a_ctc28m00[arr_aux + 1].atdregdes  is null   then
                     error "Nao existem linhas nesta direcao!"
                     next field atdregdes
                  end if
               end if

               if a_ctc28m00[arr_aux].atdregdes is null  then
                  error " Descricao da regiao deve ser informada !!"
                  next field atdregdes
               end if

            on key (interrupt)
               exit input

            on key (F8)
               if a_ctc28m00[arr_aux].atdregcod is null then
                  error "Nao e' possivel selecionar regiao invalida!"
               else
                  call ctc28m01(a_ctc28m00[arr_aux].atdregcod)
               end if

            before delete
               let ws.operacao = "d"

               if a_ctc28m00[arr_aux].atdregdes  is null   then
                  continue input
               else
                  if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                     exit input
                  end if

                  begin work
                     delete from datkatdreg
                           where atdregcod = a_ctc28m00[arr_aux].atdregcod

                     if sqlca.sqlcode <> 0    then
                        error "Erro (",sqlca.sqlcode,") na exclusao da regiao!"
                        rollback work
                     end if

                     delete from datkfxareg
                           where atdregcod = a_ctc28m00[arr_aux].atdregcod

                     if sqlca.sqlcode <> 0    then
                        error "Erro (",sqlca.sqlcode,") na exclusao das faixas!"
                        rollback work
                     end if
                  commit work

                  initialize a_ctc28m00[arr_aux].* to null
                  display a_ctc28m00[arr_aux].*    to s_ctc28m00[scr_aux].*
               end if

            after row
               case ws.operacao
                  when "i"
                     begin work
                     select max(atdregcod) into ws.atdregcod
                       from datkatdreg

                     if ws.atdregcod  is null   then
                        let ws.atdregcod = 0
                     end if
                     let ws.atdregcod = ws.atdregcod + 1

                     insert into datkatdreg ( atdregcod ,
                                              atdregdes )
                            values          ( ws.atdregcod,
                                              a_ctc28m00[arr_aux].atdregdes)
                     commit work
                     let a_ctc28m00[arr_aux].atdregcod = ws.atdregcod
                     display a_ctc28m00[arr_aux].atdregcod
                          to s_ctc28m00[scr_aux].atdregcod

                     if a_ctc28m00[arr_aux].atdregcod is null then
                        error "Nao e' possivel selecionar regiao invalida!"
                     else
                        call ctc28m01(a_ctc28m00[arr_aux].atdregcod)
                     end if

                  when "a"
                     update datkatdreg set (atdregdes)
                                       =   (a_ctc28m00[arr_aux].atdregdes)
                      where atdregcod  =    a_ctc28m00[arr_aux].atdregcod
               end case

               let ws.operacao = " "
      end input

      if int_flag     then
         exit while
      end if

   end while

   options
      comment line last

   close window w_ctc28m00
   let int_flag = false

end function  #--- ctc28m00
