############################################################################
# Menu de Modulo: ctc32m01                                        Gilberto #
#                                                                  Marcelo #
# Manutencao no Relacionamento Bloqueio/Assunto                   Abr/1998 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc32m01(param)
#----------------------------------------------------------------

 define param        record
    blqnum           like datkblq.blqnum,
    vigfnl           like datkblq.vigfnl,
    ramcod           like datkblq.ramcod
 end record

 define a_ctc32m01   array[30] of record
    c24astcod        like datrastblq.c24astcod,
    c24astdes        char(72),
    astblqsit        like datrastblq.astblqsit
 end record

 define ws           record
    c24astcod        like datrastblq.c24astcod,
    operacao         char(1),
    confirma         smallint,
    c24aststt        like datkassunto.c24aststt,
    astrgrcod        like datrclassassunto.astrgrcod,
    contrgr          integer,
    ramcod           like datkblq.ramcod,
    astrgrflg        char(01)
 end record

 define arr_aux      integer
 define scr_aux      integer


 initialize a_ctc32m01  to null
 initialize ws.*        to null
 let arr_aux  =  1

 open window w_ctc32m01 at 6,2 with form "ctc32m01"
      attribute(form line first, comment line last - 2)

 display by name param.blqnum    attribute(reverse)

 message " (F17)Abandona, (F1)Inclui"


 declare c_ctc32m01  cursor for
    select c24astcod,
           astblqsit
      from datrastblq
     where blqnum = param.blqnum

 foreach c_ctc32m01 into  a_ctc32m01[arr_aux].c24astcod,
                          a_ctc32m01[arr_aux].astblqsit

    call c24geral8(a_ctc32m01[arr_aux].c24astcod)
         returning a_ctc32m01[arr_aux].c24astdes

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, bloqueio com mais de 30 assuntos!"
       exit foreach
    end if
 end foreach


 call set_count(arr_aux-1)
 options delete key f40

 while true

    let int_flag = false

    input array a_ctc32m01  without defaults from  s_ctc32m01.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.c24astcod   =  a_ctc32m01[arr_aux].c24astcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc32m01[arr_aux]  to null
          display a_ctc32m01[arr_aux].*  to  s_ctc32m01[scr_aux].*

       before field c24astcod
          display a_ctc32m01[arr_aux].c24astcod   to
                  s_ctc32m01[scr_aux].c24astcod   attribute (reverse)

       after field c24astcod
          display a_ctc32m01[arr_aux].c24astcod   to
                  s_ctc32m01[scr_aux].c24astcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc32m01[arr_aux].c24astcod   is null   then
             error " Codigo do assunto deve ser informado!"
             next field c24astcod
          end if

          select c24aststt
            into ws.c24aststt
            from datkassunto
           where c24astcod = a_ctc32m01[arr_aux].c24astcod

          if sqlca.sqlcode  =  notfound   then
             error " Assunto nao cadastrado!"
             next field c24astcod
          end if

          call c24geral8(a_ctc32m01[arr_aux].c24astcod)
               returning a_ctc32m01[arr_aux].c24astdes

          display a_ctc32m01[arr_aux].c24astdes   to
                  s_ctc32m01[scr_aux].c24astdes

          if ws.c24aststt  <>  "A"   then
             error " Assunto cancelado!"
             next field c24astcod
          end if

          initialize ws.astrgrcod  to null
          if param.ramcod  is not null   then
             select astrgrcod
               into ws.astrgrcod
               from datrclassassunto
              where c24astcod = a_ctc32m01[arr_aux].c24astcod
                and ramcod    = param.ramcod

             if ws.astrgrcod  =  2   then
               error " Assunto nao e' permitido p/ o ramo da chave do bloqueio!"
                next field c24astcod
             end if

             declare c_ctc32m01rgr  cursor for
                select ramcod
                  from datrclassassunto
                 where c24astcod = a_ctc32m01[arr_aux].c24astcod
                   and astrgrcod = 1

             let ws.astrgrflg = "s"
             foreach c_ctc32m01rgr  into  ws.ramcod

                if ws.ramcod  =  param.ramcod   then
                   let ws.astrgrflg = "s"
                   exit foreach
                end if
                let ws.astrgrflg = "n"

             end foreach

             if ws.astrgrflg  =  "n"   then
               error " Assunto nao e' permitido p/ o ramo da chave do bloqueio!"
               next field c24astcod
             end if

          end if

          if ws.operacao  =  "i"   then
             select c24astcod
               from datrastblq
              where blqnum    = param.blqnum
                and c24astcod = a_ctc32m01[arr_aux].c24astcod

             if sqlca.sqlcode  =  0   then
                error " Codigo de assunto ja' cadastrado para este bloqueio!"
                next field c24astcod
             end if
          end if

          if ws.operacao = "a"  then
             if ws.c24astcod <> a_ctc32m01[arr_aux].c24astcod    then
                error " Codigo do assunto nao deve ser alterado!"
                next field c24astcod
             end if
          end if

       before field astblqsit
          display a_ctc32m01[arr_aux].astblqsit  to
                  s_ctc32m01[scr_aux].astblqsit attribute (reverse)

       after field astblqsit
          display a_ctc32m01[arr_aux].astblqsit to
                  s_ctc32m01[scr_aux].astblqsit

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24astcod
          end if

          if ((a_ctc32m01[arr_aux].astblqsit  is null)    or
              (a_ctc32m01[arr_aux].astblqsit  <>  "A"     and
               a_ctc32m01[arr_aux].astblqsit  <>  "C"))   then
             error " Situacao: (A)tivo, (C)ancelado!"
             next field astblqsit
          end if

      on key (interrupt)
          exit input

       after row
          if param.vigfnl  >=  today   then
             begin work
                case ws.operacao
                  when "i"
                      insert into datrastblq ( blqnum,
                                               c24astcod,
                                               astblqsit,
                                               caddat,
                                               cademp,
                                               cadmat,
                                               atldat,
                                               atlemp,
                                               atlmat )
                                  values     ( param.blqnum,
                                               a_ctc32m01[arr_aux].c24astcod,
                                               a_ctc32m01[arr_aux].astblqsit,
                                               today,
                                               g_issk.empcod,
                                               g_issk.funmat,
                                               today,
                                               g_issk.empcod,
                                               g_issk.funmat )

                  when "a"
                      update datrastblq  set  ( astblqsit,
                                                atldat,
                                                atlemp,
                                                atlmat )
                                          =   ( a_ctc32m01[arr_aux].astblqsit,
                                                today,
                                                g_issk.empcod,
                                                g_issk.funmat )
                             where blqnum    = param.blqnum
                               and c24astcod = a_ctc32m01[arr_aux].c24astcod

                end case
             commit work
          end if

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 options delete key f2
 let int_flag = false
 close c_ctc32m01

 close window w_ctc32m01

end function   ###-- ctc32m01
