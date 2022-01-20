###############################################################################
# Nome do Modulo: CTB15M01                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Matriculas autorizadas a mudanca de fase                           Nov/1999 #
###############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"


#---------------------------------------------------------------
 function ctb15m01(param)
#---------------------------------------------------------------

 define param        record
    c24fsecod        like datkfseatz.c24fsecod
 end record

 define a_ctb15m01   array[50] of record
    empcod           like datkfseatz.empcod,
    funmat           like datkfseatz.funmat,
    funnom           like isskfunc.funnom
 end record

 define ws           record
    funmat           like datkfseatz.funmat,
    c24fsedes        like datkfse.c24fsedes,
    confirma         char (01),
    operacao         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define x            smallint


 initialize a_ctb15m01  to null
 initialize ws.*        to null
 let arr_aux = 1

 open window ctb15m01 at 10,22 with form "ctb15m01"
             attribute (form line 1, border, comment line last - 1)

 select c24fsedes
   into ws.c24fsedes
   from datkfse
  where c24fsecod = param.c24fsecod

 display by name param.c24fsecod, ws.c24fsedes

 declare c_ctb15m01 cursor for
  select datkfseatz.empcod, datkfseatz.funmat
    from datkfseatz
   where datkfseatz.c24fsecod  = param.c24fsecod

 foreach c_ctb15m01 into a_ctb15m01[arr_aux].empcod,
                         a_ctb15m01[arr_aux].funmat

    call ctb15m00_func(a_ctb15m01[arr_aux].empcod, a_ctb15m01[arr_aux].funmat)
         returning a_ctb15m01[arr_aux].funnom

    let arr_aux = arr_aux + 1
    if arr_aux > 50 then
       error " Limite excedido, fase com mais de 50 autorizacoes"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 options comment line last - 1

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 while true

    let int_flag = false

    input array a_ctb15m01 without defaults from s_ctb15m01.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
          else
             let ws.operacao = "i"
             initialize a_ctb15m01[arr_aux].*  to null
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctb15m01[arr_aux].*  to null
          display a_ctb15m01[arr_aux].* to s_ctb15m01[scr_aux].*

       before field empcod
          display a_ctb15m01[arr_aux].empcod to
                  s_ctb15m01[scr_aux].empcod attribute (reverse)

       after  field empcod
          display a_ctb15m01[arr_aux].empcod to
                  s_ctb15m01[scr_aux].empcod

          if fgl_lastkey() <> fgl_keyval ("up")     and
             fgl_lastkey() <> fgl_keyval ("left")   then
             if a_ctb15m01[arr_aux].empcod is null then
                error " Codigo da empresa deve ser informado!"
                next field empcod
             end if
          end if

       before field funmat
          display a_ctb15m01[arr_aux].funmat to
                  s_ctb15m01[scr_aux].funmat attribute (reverse)
          let ws.funmat = a_ctb15m01[arr_aux].funmat

       after  field funmat
          display a_ctb15m01[arr_aux].funmat to
                  s_ctb15m01[scr_aux].funmat

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field empcod
          end if

          if a_ctb15m01[arr_aux].funmat is null then
             if ws.operacao = "a"  then
                error " Numero matricula nao pode ser alterado!"
                let a_ctb15m01[arr_aux].funmat = ws.funmat
                next field funmat
             else
                error " Codigo da matricula deve ser informado!"
                next field funmat
             end if
          end if

          if ws.operacao =  "a"                          and
             ws.funmat   <>  a_ctb15m01[arr_aux].funmat  then
             error " Numero matricula nao pode ser alterado!"
             let a_ctb15m01[arr_aux].funmat = ws.funmat
             next field funmat
          end if

          initialize a_ctb15m01[arr_aux].funnom to null
          call ctb15m00_func(a_ctb15m01[arr_aux].empcod,
                             a_ctb15m01[arr_aux].funmat)
                   returning a_ctb15m01[arr_aux].funnom

          if a_ctb15m01[arr_aux].funnom is null then
             error " Esta matricula nao existe no cadastro!"
             next field funmat
          end if

          display a_ctb15m01[arr_aux].funnom  to
                  s_ctb15m01[scr_aux].funnom

          for x = 1 to 50
              if arr_aux <> x                                       and
                 a_ctb15m01[arr_aux].funmat = a_ctb15m01[x].funmat  then
                 error " Matricula ja' autorizada para esta fase!!"
                 next field funmat
              end if
          end for


       before delete
          let ws.operacao = "d"
          if a_ctb15m01[arr_aux].funmat  is not null  then
             display a_ctb15m01[arr_aux].empcod to
                     s_ctb15m01[scr_aux].empcod
             display a_ctb15m01[arr_aux].funmat to
                     s_ctb15m01[scr_aux].funmat
             while true
                call cts08g01("C","S","","CONFIRA EXCLUSAO MATRICULA ?","","")
                     returning ws.confirma
                if ws.confirma = "S"  then
                   delete from datkfseatz
                    where c24fsecod   = param.c24fsecod
                      and empcod      = a_ctb15m01[arr_aux].empcod
                      and funmat      = a_ctb15m01[arr_aux].funmat

                   if sqlca.sqlcode <> 0 then
                      error " Erro (", sqlca.sqlcode, ") na exclusao desta autorizacao favor verificar!"
                   else
                      initialize a_ctb15m01[arr_aux].* to null
                      display a_ctb15m01[arr_aux].* to s_ctb15m01[scr_aux].*
                   end if
                   exit while
                else
                   if ws.confirma = "N" then
                      exit input
                   end if
                end if
             end while
          end if


       after row
          if a_ctb15m01[arr_aux].funmat  is not null  then
             case ws.operacao
                when "i"
                  insert into datkfseatz (c24fsecod,
                                          empcod,
                                          funmat,
                                          atldat,
                                          atlemp,
                                          atlmat    )
                                  values (param.c24fsecod,
                                          a_ctb15m01[arr_aux].empcod,
                                          a_ctb15m01[arr_aux].funmat,
                                          today,
                                          g_issk.empcod,
                                          g_issk.funmat)

                  if sqlca.sqlcode <> 0 then
                     error " Erro (", sqlca.sqlcode, ") na inclusao desta autorizacao favor verificar!"
                  end if

             end case
          end if
          let ws.operacao = " "

       on key (interrupt)
          exit input

    end input

    if int_flag    then
       exit while
    end if

 end while

 close window ctb15m01

 let int_flag = false

end function  #  ctb15m01

