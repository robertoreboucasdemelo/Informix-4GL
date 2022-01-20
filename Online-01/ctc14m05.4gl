############################################################################
# Menu de Modulo: ctc14m05                                        Gilberto #
#                                                                  Marcelo #
# Manutencao no Relacionamento Assunto/Matricula                  Mar/1998 #
############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc14m05(param)
#---------------------------------------------------------------

 define param        record
    c24astcod        like datkassunto.c24astcod,
    c24astagpdes     like datkastagp.c24astagpdes,
    c24astdes        like datkassunto.c24astdes,
    sissgl           char(10)
 end record

 define a_ctc14m05   array[200] of record
    empcod           like datrastfun.empcod,
    funmat           like datrastfun.funmat,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl
 end record

 define ws           record
    empcod           like datrastfun.empcod,
    funmat           like datrastfun.funmat,
    operacao         char(1),
    assunto          char(80)
 end record

 define arr_aux      smallint
 define scr_aux      smallint


 initialize a_ctc14m05  to null
 initialize ws.*        to null
 let arr_aux  =  1

 open window w_ctc14m05 at 6,2 with form "ctc14m05"
      attribute(form line first, comment line last - 2)

 let ws.assunto = param.c24astagpdes clipped, " ", param.c24astdes

 display by name param.c24astcod    attribute(reverse)
 display ws.assunto  to  c24astdes  attribute(reverse)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"


 declare c_ctc14m05  cursor for
    select empcod,
           funmat
      from datrastfun
     where c24astcod  =  param.c24astcod

 foreach c_ctc14m05 into  a_ctc14m05[arr_aux].empcod,
                          a_ctc14m05[arr_aux].funmat

    select funnom, dptsgl
      into a_ctc14m05[arr_aux].funnom,  a_ctc14m05[arr_aux].dptsgl
      from isskfunc
     where empcod = a_ctc14m05[arr_aux].empcod
       and funmat = a_ctc14m05[arr_aux].funmat

    let arr_aux = arr_aux + 1
    if arr_aux  >  200   then
       error " Limite excedido, assunto c/ mais de 200 matriculas!"
       exit foreach
    end if
 end foreach


 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc14m05  without defaults from  s_ctc14m05.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.empcod   =  a_ctc14m05[arr_aux].empcod
             let ws.funmat   =  a_ctc14m05[arr_aux].funmat
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc14m05[arr_aux]  to null
          display a_ctc14m05[arr_aux].*  to  s_ctc14m05[scr_aux].*

       before field empcod
          display a_ctc14m05[arr_aux].empcod   to
                  s_ctc14m05[scr_aux].empcod   attribute (reverse)

       after field empcod
          display a_ctc14m05[arr_aux].empcod   to
                  s_ctc14m05[scr_aux].empcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc14m05[arr_aux].empcod   is null   then
            #error " Empresa do funcionario deve ser informada!"
             call cto00m01("S") returning
                    a_ctc14m05[arr_aux].empcod,
                    a_ctc14m05[arr_aux].funmat,
                    a_ctc14m05[arr_aux].funnom      
             next field empcod
          end if

          select empcod
            from gabkemp
           where empcod = a_ctc14m05[arr_aux].empcod

          if sqlca.sqlcode  =  notfound   then
             error " Empresa nao cadastrada!"
             next field empcod
          end if

          if ws.operacao = "a"  then
             if ws.empcod <> a_ctc14m05[arr_aux].empcod    then
                error " Empresa do funcionario nao deve ser alterada!"
                next field empcod
             end if
          end if

       before field funmat
          display a_ctc14m05[arr_aux].funmat  to
                  s_ctc14m05[scr_aux].funmat attribute (reverse)

       after field funmat
          display a_ctc14m05[arr_aux].funmat to
                  s_ctc14m05[scr_aux].funmat

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field empcod
          end if

          if a_ctc14m05[arr_aux].funmat   is null   then
             call cto00m01("S") returning
                    a_ctc14m05[arr_aux].empcod,
                    a_ctc14m05[arr_aux].funmat,
                    a_ctc14m05[arr_aux].funnom      
             next field funmat
          end if

          if ws.operacao = "a"  then
             if ws.funmat <> a_ctc14m05[arr_aux].funmat    then
                error " Matricula do funcionario nao deve ser alterada!"
                next field funmat
             end if
          end if

          select funnom, dptsgl
            into a_ctc14m05[arr_aux].funnom,  a_ctc14m05[arr_aux].dptsgl
            from isskfunc
           where empcod = a_ctc14m05[arr_aux].empcod
             and funmat = a_ctc14m05[arr_aux].funmat

          if sqlca.sqlcode  =  notfound   then
             error " Matricula nao cadastrada no sistema de seguranca!"
             next field funmat
          end if

          display a_ctc14m05[arr_aux].funnom  to s_ctc14m05[scr_aux].funnom
          display a_ctc14m05[arr_aux].dptsgl  to s_ctc14m05[scr_aux].dptsgl

          if param.sissgl = 'Cad_ct24h' then

             select funmat from datkfun
              where empcod = a_ctc14m05[arr_aux].empcod
                and funmat = a_ctc14m05[arr_aux].funmat

             if sqlca.sqlcode  =  notfound   then
                error " Matricula nao cadastrada com permissao de liberacao!"
                next field funmat
             end if

          end if

          if ws.operacao  =  "i"   then
             select funmat
               from datrastfun
              where c24astcod = param.c24astcod
                and empcod    = a_ctc14m05[arr_aux].empcod
                and funmat    = a_ctc14m05[arr_aux].funmat

             if sqlca.sqlcode  =  0   then
                error " Matricula ja' cadastrada para este codigo de assunto!"
                next field funmat
             end if
          end if

      on key (interrupt)
          exit input

       before delete
          let ws.operacao = "d"
          if a_ctc14m05[arr_aux].empcod  is null   then
             continue input
          else
             if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                exit input
             end if

             begin work
                delete from datrastfun
                 where c24astcod  =  param.c24astcod
                   and empcod     =  a_ctc14m05[arr_aux].empcod
                   and funmat     =  a_ctc14m05[arr_aux].funmat
             commit work

             initialize a_ctc14m05[arr_aux].* to null
             display    a_ctc14m05[scr_aux].* to s_ctc14m05[scr_aux].*
          end if

       after row
          begin work
             case ws.operacao
               when "i"
                   insert into datrastfun ( empcod,
                                            funmat,
                                            c24astcod )
                               values     ( a_ctc14m05[arr_aux].empcod,
                                            a_ctc14m05[arr_aux].funmat,
                                            param.c24astcod )
             end case
          commit work

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc14m05

 close window w_ctc14m05

end function   ###-- ctc14m05
