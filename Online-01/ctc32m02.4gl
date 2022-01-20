############################################################################
# Menu de Modulo: ctc32m02                                        Gilberto #
#                                                                  Marcelo #
# Manutencao no Relacionamento Bloqueio/Matriculas                Abr/1998 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc32m02(param)
#----------------------------------------------------------------

 define param        record
    blqnum           like datkblq.blqnum,
    vigfnl           like datkblq.vigfnl
 end record

 define a_ctc32m02   array[30] of record
    empcod           like datrfunblqlib.empcod,
    funmat           like datrfunblqlib.funmat,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl
 end record

 define ws           record
    empcod           like datrfunblqlib.empcod,
    funmat           like datrfunblqlib.funmat,
    operacao         char(01),
    cont             dec(2,0)
 end record

 define arr_aux      integer
 define scr_aux      integer


 initialize a_ctc32m02  to null
 initialize ws.*        to null
 let arr_aux  =  1

 open window w_ctc32m02 at 6,2 with form "ctc32m02"
      attribute(form line first, comment line last - 2)

 display by name param.blqnum   attribute(reverse)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"


 declare c_ctc32m02  cursor for
    select empcod,
           funmat
      from datrfunblqlib
     where blqnum = param.blqnum

 foreach c_ctc32m02 into  a_ctc32m02[arr_aux].empcod,
                          a_ctc32m02[arr_aux].funmat

    select funnom, dptsgl
      into a_ctc32m02[arr_aux].funnom,  a_ctc32m02[arr_aux].dptsgl
      from isskfunc
     where empcod = a_ctc32m02[arr_aux].empcod
       and funmat = a_ctc32m02[arr_aux].funmat

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, bloqueio com mais de 30 matriculas!"
       exit foreach
    end if
 end foreach


 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc32m02  without defaults from  s_ctc32m02.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.empcod   =  a_ctc32m02[arr_aux].empcod
             let ws.funmat   =  a_ctc32m02[arr_aux].funmat
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc32m02[arr_aux]  to null
          display a_ctc32m02[arr_aux].*  to  s_ctc32m02[scr_aux].*

       before field empcod
          display a_ctc32m02[arr_aux].empcod   to
                  s_ctc32m02[scr_aux].empcod   attribute (reverse)

       after field empcod
          display a_ctc32m02[arr_aux].empcod   to
                  s_ctc32m02[scr_aux].empcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc32m02[arr_aux].empcod   is null   then
             error " Empresa do funcionario deve ser informada!"
             next field empcod
          end if

          select empcod
            from gabkemp
           where empcod = a_ctc32m02[arr_aux].empcod

          if sqlca.sqlcode  =  notfound   then
             error " Empresa nao cadastrada!"
             next field empcod
          end if

          if ws.operacao = "a"  then
             if ws.empcod <> a_ctc32m02[arr_aux].empcod    then
                error " Empresa do funcionario nao deve ser alterada!"
                next field empcod
             end if
          end if

       before field funmat
          display a_ctc32m02[arr_aux].funmat  to
                  s_ctc32m02[scr_aux].funmat attribute (reverse)

       after field funmat
          display a_ctc32m02[arr_aux].funmat to
                  s_ctc32m02[scr_aux].funmat

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field empcod
          end if

          if a_ctc32m02[arr_aux].funmat  is null   then
             error " Matricula do funcionario deve ser informada!"
             next field funmat
          end if

          if ws.operacao = "a"  then
             if ws.funmat <> a_ctc32m02[arr_aux].funmat    then
                error " Matricula do funcionario nao deve ser alterada!"
                next field funmat
             end if
          end if

          select funnom, dptsgl
            into a_ctc32m02[arr_aux].funnom,  a_ctc32m02[arr_aux].dptsgl
            from isskfunc
           where empcod = a_ctc32m02[arr_aux].empcod
             and funmat = a_ctc32m02[arr_aux].funmat

          if sqlca.sqlcode  =  notfound   then
             error " Matricula nao cadastrada no sistema de seguranca!"
             next field funmat
          end if

          display a_ctc32m02[arr_aux].funnom  to s_ctc32m02[scr_aux].funnom
          display a_ctc32m02[arr_aux].dptsgl  to s_ctc32m02[scr_aux].dptsgl

          select funmat
            from datkfun
           where empcod = a_ctc32m02[arr_aux].empcod
             and funmat = a_ctc32m02[arr_aux].funmat

          if sqlca.sqlcode  =  notfound   then
             error " Matricula nao cadastrada com permissao de liberacao!"
             next field funmat
          end if

          if ws.operacao  =  "i"   then
             select funmat
               from datrfunblqlib
              where blqnum = param.blqnum
                and empcod = a_ctc32m02[arr_aux].empcod
                and funmat = a_ctc32m02[arr_aux].funmat

             if sqlca.sqlcode  =  0   then
                error " Matricula ja' cadastrada para este bloqueio!"
                next field funmat
             end if
          end if

      on key (interrupt)
          let ws.cont = 0
          select count(*)
            into ws.cont
            from datrfunblqlib
           where blqnum = param.blqnum

          if ws.cont  =  0   then
             error " Deve ser cadastrada uma matricula p/ liberar o bloqueio!"
          else
             exit input
          end if

       before delete
          if param.vigfnl  >=  today   then
             let ws.operacao = "d"
             if a_ctc32m02[arr_aux].empcod  is null   then
                continue input
             else
                if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                   exit input
                end if

                begin work
                   delete from datrfunblqlib
                    where blqnum = param.blqnum
                      and empcod = a_ctc32m02[arr_aux].empcod
                      and funmat = a_ctc32m02[arr_aux].funmat
                commit work

                initialize a_ctc32m02[arr_aux].* to null
                display    a_ctc32m02[scr_aux].* to s_ctc32m02[scr_aux].*
             end if
          end if

       after row
          if param.vigfnl  >=  today   then
             begin work
                case ws.operacao
                  when "i"
                      insert into datrfunblqlib ( empcod,
                                                  funmat,
                                                  blqnum,
                                                  caddat,
                                                  cademp,
                                                  cadmat )
                                     values     ( a_ctc32m02[arr_aux].empcod,
                                                  a_ctc32m02[arr_aux].funmat,
                                                  param.blqnum,
                                                  today,
                                                  g_issk.empcod,
                                                  g_issk.funmat )
                end case
             commit work
          end if

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc32m02

 close window w_ctc32m02

end function   ###-- ctc32m02
