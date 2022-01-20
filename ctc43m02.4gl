###########################################################################
# Nome do Modulo: ctc43m02                                        Marcelo #
#                                                                Gilberto #
# Manutencao no cadastro de programacao de botoes dos MDTs       Jul/1999 #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------------
 function ctc43m02(param)
#---------------------------------------------------------------------

 define param         record
    operacao          char(01),
    mdtprgcod         like datrmdtbotprg.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtprgstt         like datkmdtprg.mdtprgstt,
    atldat            like datkmdtprg.atldat,
    funnom            like isskfunc.funnom
  end record

 define a_ctc43m02    array[50] of record
    mdtbotcod         like datrmdtbotprg.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotprgseq      like datrmdtbotprg.mdtbotprgseq,
    mdtbotprgsisflg   like datrmdtbotprg.mdtbotprgsisflg,
    mdtbotprgdigflg   like datrmdtbotprg.mdtbotprgdigflg,
    mdtbotvldflg      char (01)
 end record

 define ws            record
    mdtbotcod         like datrmdtbotprg.mdtbotcod,
    operacao          char (01),
    count             dec  (2,0),
    confirma          char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer


 initialize a_ctc43m02  to null
 initialize ws.*        to null
 let arr_aux = 1

 declare c_ctc43m02 cursor for
    select datrmdtbotprg.mdtbotcod,
           datkmdtbot.mdtbottxt,
           datrmdtbotprg.mdtbotprgseq,
           datrmdtbotprg.mdtbotprgsisflg,
           datrmdtbotprg.mdtbotprgdigflg
      from datrmdtbotprg, datkmdtbot
     where datrmdtbotprg.mdtprgcod  =  param.mdtprgcod
       and datkmdtbot.mdtbotcod     =  datrmdtbotprg.mdtbotcod
  order by datrmdtbotprg.mdtbotprgseq

 foreach c_ctc43m02 into a_ctc43m02[arr_aux].mdtbotcod,
                         a_ctc43m02[arr_aux].mdtbottxt,
                         a_ctc43m02[arr_aux].mdtbotprgseq,
                         a_ctc43m02[arr_aux].mdtbotprgsisflg,
                         a_ctc43m02[arr_aux].mdtbotprgdigflg

    let a_ctc43m02[arr_aux].mdtbotvldflg  =  "N"

    declare c_datkmdtbotval  cursor for
       select mdtbotvalcod
         from datkmdtbotval
        where datkmdtbotval.mdtprgcod  =  param.mdtprgcod
          and datkmdtbotval.mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod

    open  c_datkmdtbotval
    fetch c_datkmdtbotval
    if sqlca.sqlcode  =  0   then
       let a_ctc43m02[arr_aux].mdtbotvldflg  =  "S"
    end if
    close c_datkmdtbotval

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, programacao com mais de 50 botoes!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)

 open window w_ctc43m02 at 06,2 with form "ctc43m02"
      attribute(form line first, comment line last - 1)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F8)Validacao"

 display by name param.mdtprgcod
 display by name param.mdtprgdes
 display by name param.mdtprgstt
 display by name param.atldat
 display by name param.funnom

  while true
     let int_flag = false

     input array a_ctc43m02 without defaults from s_ctc43m02.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
              if arr_aux <= arr_count()  then
                 let ws.operacao   =  "a"
                 let ws.mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod
              end if

           before insert
              let ws.operacao = "i"
              initialize a_ctc43m02[arr_aux].*  to null
              display a_ctc43m02[arr_aux].* to s_ctc43m02[scr_aux].*

              let a_ctc43m02[arr_aux].mdtbotvldflg  =  "N"
              display by name a_ctc43m02[arr_aux].mdtbotvldflg

           before field mdtbotcod
              display a_ctc43m02[arr_aux].mdtbotcod to
                      s_ctc43m02[scr_aux].mdtbotcod attribute (reverse)

           after field mdtbotcod
              display a_ctc43m02[arr_aux].mdtbotcod to
                      s_ctc43m02[scr_aux].mdtbotcod

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field mdtbotcod
              end if

              if a_ctc43m02[arr_aux].mdtbotcod   is null    then
                 error " Codigo do botao deve ser informado!"
                 call ctc43m04()  returning a_ctc43m02[arr_aux].mdtbotcod
                 next field mdtbotcod
              end if

              if ws.operacao                    =  "a"             and
                 a_ctc43m02[arr_aux].mdtbotcod  <>  ws.mdtbotcod   then
                 error " Codigo do botao nao deve ser alterado!"
                 next field mdtbotcod
              end if

             initialize a_ctc43m02[arr_aux].mdtbottxt  to null

              select mdtbottxt
                into a_ctc43m02[arr_aux].mdtbottxt
                from datkmdtbot
               where datkmdtbot.mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod

              if sqlca.sqlcode  =  notfound   then
                 error " Botao nao cadastrado!"
                 call ctc43m04()  returning a_ctc43m02[arr_aux].mdtbotcod
                 next field mdtbotcod
              end if

              display a_ctc43m02[arr_aux].mdtbottxt  to
                      s_ctc43m02[scr_aux].mdtbottxt

              #------------------------------------------------------------
              # Verifica se botao ja' foi cadastrado
              #------------------------------------------------------------
              if ws.operacao  =  "i"   then
                 select mdtprgcod
                   from datrmdtbotprg
                  where mdtprgcod  =  param.mdtprgcod
                    and mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod

                 if sqlca.sqlcode  =  0   then
                    error " Botao ja' cadastrado!"
                    next field mdtbotcod
                 end if
              end if

           before field mdtbotprgseq
              display a_ctc43m02[arr_aux].mdtbotprgseq to
                      s_ctc43m02[scr_aux].mdtbotprgseq attribute (reverse)

           after field mdtbotprgseq
              display a_ctc43m02[arr_aux].mdtbotprgseq to
                      s_ctc43m02[scr_aux].mdtbotprgseq

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field mdtbotcod
              end if

              if a_ctc43m02[arr_aux].mdtbotprgseq   is null    then
                 error " Numero sequencia deve ser informado!"
                 next field mdtbotprgseq
              end if

              if a_ctc43m02[arr_aux].mdtbotprgseq   =  0    then
                 error " Numero sequencia nao deve ser zero!"
                 next field mdtbotprgseq
              end if

              #------------------------------------------------------------
              # Verifica se existe botao ja' cadastrado c/ essa sequencia
              #------------------------------------------------------------
              initialize ws.mdtbotcod  to null

              select mdtbotcod
                into ws.mdtbotcod
                from datrmdtbotprg
               where mdtprgcod     =  param.mdtprgcod
                 and mdtbotprgseq  =  a_ctc43m02[arr_aux].mdtbotprgseq

              if sqlca.sqlcode  =  0   then
                 if ws.operacao  =  "i"   then
                    error " Numero sequencia ja' cadastrada em outro botao!"
                    next field mdtbotprgseq
                 else
                    if a_ctc43m02[arr_aux].mdtbotcod  <>  ws.mdtbotcod   then
                       error " Numero sequencia ja' cadastrada em outro botao!"
                       next field mdtbotprgseq
                    end if
                 end if
              end if

           before field mdtbotprgsisflg
              display a_ctc43m02[arr_aux].mdtbotprgsisflg to
                      s_ctc43m02[scr_aux].mdtbotprgsisflg attribute (reverse)

           after field mdtbotprgsisflg
              display a_ctc43m02[arr_aux].mdtbotprgsisflg to
                      s_ctc43m02[scr_aux].mdtbotprgsisflg

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field mdtbotprgseq
              end if

              if (a_ctc43m02[arr_aux].mdtbotprgsisflg  is null)  or
                 (a_ctc43m02[arr_aux].mdtbotprgsisflg  <>  "S"   and
                  a_ctc43m02[arr_aux].mdtbotprgsisflg  <>  "N")  then
                 error " Recebe tratamento pelo sistema: (S)im ou (N)ao!"
                 next field mdtbotprgsisflg
              end if

              if a_ctc43m02[arr_aux].mdtbotprgsisflg  =  "N"   then
                 let a_ctc43m02[arr_aux].mdtbotprgdigflg  =  "N"
                 display a_ctc43m02[arr_aux].mdtbotprgdigflg to
                         s_ctc43m02[scr_aux].mdtbotprgdigflg
              end if

           before field mdtbotprgdigflg
              display a_ctc43m02[arr_aux].mdtbotprgdigflg to
                      s_ctc43m02[scr_aux].mdtbotprgdigflg attribute (reverse)

           after field mdtbotprgdigflg
              display a_ctc43m02[arr_aux].mdtbotprgdigflg to
                      s_ctc43m02[scr_aux].mdtbotprgdigflg

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("down")  or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field mdtbotprgsisflg
              end if

              if (a_ctc43m02[arr_aux].mdtbotprgdigflg  is null)  or
                 (a_ctc43m02[arr_aux].mdtbotprgdigflg  <>  "S"   and
                  a_ctc43m02[arr_aux].mdtbotprgdigflg  <>  "N")  then
                 error " Digita dados apos pressionado: (S)im ou (N)ao!"
                 next field mdtbotprgdigflg
              end if

              if a_ctc43m02[arr_aux].mdtbotprgsisflg  =  "N"   and
                 a_ctc43m02[arr_aux].mdtbotprgdigflg  =  "S"   then
                 error " Botao nao tratado pelo sistema nao permite digitacao!"
                 next field mdtbotprgdigflg
              end if

           on key (interrupt)
              exit input

           on key (f8)
              if ws.operacao  <>  "a"   then
                 error " Validacao apenas com botao ja' incluido!"
                 continue input
              else
                 let arr_aux  =  arr_curr()
                 call ctc43m03( "S",
                                param.mdtprgcod,
                                a_ctc43m02[arr_aux].mdtbotcod )
                      returning a_ctc43m02[arr_aux].mdtbotvldflg

                 display by name a_ctc43m02[arr_aux].mdtbotvldflg
              end if

           before delete
              let ws.operacao = "d"
              if a_ctc43m02[arr_aux].mdtbotcod  is null   then
                 continue input
              end if

              let  ws.confirma  =  "N"
              call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                   returning ws.confirma

              if ws.confirma  =  "N"   then
                 display a_ctc43m02[arr_aux].* to s_ctc43m02[scr_aux].*
                 exit input
              end if

              let ws.count  =  0
              select count(*)
                into ws.count
                from datrmdtbotprg
               where mdtprgcod  =  param.mdtprgcod

              if ws.count  =  1   then
                 error " Programacao deve ser removida!"
                 exit input
              end if

              begin work
                 delete from datrmdtbotprg
                  where mdtprgcod  =  param.mdtprgcod
                    and mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod

                 delete from datkmdtbotval
                  where mdtprgcod  =  param.mdtprgcod
                    and mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod
              commit work

              initialize a_ctc43m02[arr_aux].*  to null
              display a_ctc43m02[arr_aux].*     to s_ctc43m02[scr_aux].*

           after row

              case ws.operacao
                 when "i"
                    begin work

                    if param.operacao = "i"   then  #--> qdo inclui programacao
                       initialize param.operacao  to null
                       call ctc43m02_prog(param.*)  returning param.mdtprgcod
                       if param.mdtprgcod  is null   then
                          exit input
                       end if
                    end if

                    insert into datrmdtbotprg
                                ( mdtprgcod,
                                  mdtbotcod,
                                  mdtbotprgseq,
                                  mdtbotprgsisflg,
                                  mdtbotprgdigflg )
                           values
                                ( param.mdtprgcod,
                                  a_ctc43m02[arr_aux].mdtbotcod,
                                  a_ctc43m02[arr_aux].mdtbotprgseq,
                                  a_ctc43m02[arr_aux].mdtbotprgsisflg,
                                  a_ctc43m02[arr_aux].mdtbotprgdigflg )
                    commit work

                 when "a"
                    begin work

                    update datrmdtbotprg  set
                                       ( mdtbotprgseq,
                                         mdtbotprgsisflg,
                                         mdtbotprgdigflg )
                                    =
                                       ( a_ctc43m02[arr_aux].mdtbotprgseq,
                                         a_ctc43m02[arr_aux].mdtbotprgsisflg,
                                         a_ctc43m02[arr_aux].mdtbotprgdigflg )
                     where mdtprgcod  =  param.mdtprgcod
                       and mdtbotcod  =  a_ctc43m02[arr_aux].mdtbotcod

                    commit work
              end case

              let ws.operacao = " "
     end input

     if int_flag    then
        exit while
     end if

 end while

 let int_flag = false
 close c_ctc43m02
 close window w_ctc43m02

end function   ###--  ctc43m02


#---------------------------------------------------------------
 function ctc43m02_prog(param)
#---------------------------------------------------------------
 define param        record
   operacao          char(01),
   mdtprgcod         like datrmdtbotprg.mdtprgcod,
   mdtprgdes         like datkmdtprg.mdtprgdes,
   mdtprgstt         like datkmdtprg.mdtprgstt,
   atldat            like datkmdtprg.atldat,
   funnom            like isskfunc.funnom
 end record

 define ws_resp      char(01)


 declare c_ctc43m02m  cursor with hold  for
   select max(mdtprgcod)
     from datrmdtbotprg
    where datrmdtbotprg.mdtprgcod  >  0

 foreach c_ctc43m02m into  param.mdtprgcod
     exit foreach
 end foreach

 if param.mdtprgcod  is null   then
    let param.mdtprgcod  =  0
 end if
 let param.mdtprgcod  =  param.mdtprgcod + 1

 insert into datkmdtprg ( mdtprgcod,
                          mdtprgdes,
                          mdtprgstt,
                          atldat,
                          atlemp,
                          atlmat )
                 values ( param.mdtprgcod,
                          param.mdtprgdes,
                          param.mdtprgstt,
                          today,
                          g_issk.empcod,
                          g_issk.funmat )

 if sqlca.sqlcode <>  0  then
    error " Erro (",sqlca.sqlcode,") na Inclusao da programacao!"
    rollback work
    initialize param.mdtprgcod  to null
    return param.mdtprgcod
 else
    display param.mdtprgcod  to  mdtprgcod  attribute (reverse)
    error " Verifique o codigo do registro e tecle ENTER!"
    prompt "" for char ws_resp
 end if

  return param.mdtprgcod

end function  ###--  ctc43m02_prog
