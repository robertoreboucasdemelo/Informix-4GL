############################################################################
# Menu de Modulo: ctc32m03                                        Gilberto #
#                                                                  Marcelo #
# Manutencao do Cadastro de Observacoes do Bloqueio               Abr/1998 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc32m03(param)
#----------------------------------------------------------------

 define param        record
    blqnum           like datkblq.blqnum,
    vigfnl           like datkblq.vigfnl
 end record

 define a_ctc32m03   array[30] of record
    blqobstxt        like datmblqobs.blqobstxt,
    blqobsseq        like datmblqobs.blqobsseq
 end record

 define ws           record
    operacao         char(01)
 end record

 define arr_aux      smallint
 define scr_aux      smallint


 initialize a_ctc32m03  to null
 initialize ws.*        to null
 let arr_aux  =  1

 open window w_ctc32m03 at 6,2 with form "ctc32m03"
      attribute(form line first, comment line last - 2)

 display by name param.blqnum    attribute(reverse)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"


 declare c_ctc32m03  cursor for
    select blqobstxt,
           blqobsseq
      from datmblqobs
     where blqnum = param.blqnum

 foreach c_ctc32m03 into  a_ctc32m03[arr_aux].blqobstxt,
                          a_ctc32m03[arr_aux].blqobsseq

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, observacao com mais de 30 linhas!"
       exit foreach
    end if
 end foreach


 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc32m03  without defaults from  s_ctc32m03.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc32m03[arr_aux]  to null
          display a_ctc32m03[arr_aux].*  to  s_ctc32m03[scr_aux].*

       before field blqobstxt
          display a_ctc32m03[arr_aux].blqobstxt   to
                  s_ctc32m03[scr_aux].blqobstxt   attribute (reverse)

       after field blqobstxt
          display a_ctc32m03[arr_aux].blqobstxt   to
                  s_ctc32m03[scr_aux].blqobstxt

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc32m03[arr_aux].blqobstxt   is null   then
             error " Nao deve haver linhas sem conteudo!"
             next field blqobstxt
          end if

      on key (interrupt)
          exit input

       before delete
          if param.vigfnl  >=  today   then
             let ws.operacao = "d"
             if a_ctc32m03[arr_aux].blqobsseq  is null   then
                continue input
             else
                if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                   exit input
                end if

                begin work
                   delete from datmblqobs
                    where blqnum    = param.blqnum
                      and blqobsseq = a_ctc32m03[arr_aux].blqobsseq
                commit work

                initialize a_ctc32m03[arr_aux].* to null
                display    a_ctc32m03[scr_aux].* to s_ctc32m03[scr_aux].*
             end if
          end if

       after row
          if param.vigfnl  >=  today   then
             begin work
                case ws.operacao
                  when "i"
                      declare c_ctc32m03m  cursor with hold  for
                         select max(blqobsseq)
                           from datmblqobs
                          where datmblqobs.blqnum = param.blqnum

                      foreach c_ctc32m03m  into  a_ctc32m03[arr_aux].blqobsseq
                         exit foreach
                      end foreach

                      if a_ctc32m03[arr_aux].blqobsseq   is null   then
                         let a_ctc32m03[arr_aux].blqobsseq = 0
                      end if
                      let a_ctc32m03[arr_aux].blqobsseq =
                          a_ctc32m03[arr_aux].blqobsseq + 1

                      insert into datmblqobs ( blqnum,
                                               blqobstxt,
                                               blqobsseq,
                                               caddat,
                                               cademp,
                                               cadmat )
                                  values     ( param.blqnum,
                                               a_ctc32m03[arr_aux].blqobstxt,
                                               a_ctc32m03[arr_aux].blqobsseq,
                                               today,
                                               g_issk.empcod,
                                               g_issk.funmat )

                  when "a"
                      update datmblqobs  set  ( blqobstxt,
                                                caddat,
                                                cademp,
                                                cadmat )
                                          =   ( a_ctc32m03[arr_aux].blqobstxt,
                                                today,
                                                g_issk.empcod,
                                                g_issk.funmat )
                             where blqnum    = param.blqnum
                               and blqobsseq = a_ctc32m03[arr_aux].blqobsseq

                end case
             commit work

             display a_ctc32m03[arr_aux].blqobsseq to
                     s_ctc32m03[scr_aux].blqobsseq
          end if

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc32m03

 close window w_ctc32m03

end function   ###-- ctc32m03
