###########################################################################
# Nome do Modulo: ctc43m03                                        Marcelo #
#                                                                Gilberto #
# Manutencao no cadastro de validacao dos botoes                 Jul/1999 #
###########################################################################

 database porto

#--------------------------------------------------------------------
 function ctc43m03(param)
#--------------------------------------------------------------------

 define param         record
    atuflg            char (01),
    mdtprgcod         like datkmdtbotval.mdtprgcod,
    mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define a_ctc43m03    array[50] of record
    mdtbotvalcod      like datkmdtbotval.mdtbotvalcod,
    mdtbottxt         like datkmdtbot.mdtbottxt
 end record

 define ws            record
    mdtbotvalcod      like datkmdtbotval.mdtbotvalcod,
    operacao          char (01),
    confirma          char (01),
    mdtbotvldflg      char (01)
 end record

 define arr_aux       smallint
 define scr_aux       smallint


 initialize a_ctc43m03  to null
 initialize ws.*        to null
 let arr_aux = 1
 let scr_aux = 1

 declare c_ctc43m03 cursor for
    select datkmdtbotval.mdtbotvalcod,
           datkmdtbot.mdtbottxt
      from datkmdtbotval, datkmdtbot
     where datkmdtbotval.mdtprgcod  =  param.mdtprgcod
       and datkmdtbotval.mdtbotcod  =  param.mdtbotcod
       and datkmdtbot.mdtbotcod     =  datkmdtbotval.mdtbotvalcod
  order by datkmdtbotval.mdtbotvalcod

 foreach c_ctc43m03 into a_ctc43m03[arr_aux].mdtbotvalcod,
                         a_ctc43m03[arr_aux].mdtbottxt

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, botao com mais de 50 validacoes!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 open window w_ctc43m03 at 13,46 with form "ctc43m03"
      attribute(form line first, border, comment line last - 1)

 if param.atuflg   =  "S"   then
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 else
    message " (F17)Abandona"

    display array a_ctc43m03 to s_ctc43m03.*

       on key (interrupt,control-c)
          initialize a_ctc43m03  to null
          exit display

    end display
 end if


 while true

    if param.atuflg  =  "N"   then
       exit while
    end if

    let int_flag = false

    input array a_ctc43m03 without defaults from s_ctc43m03.*
       before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            if arr_aux <= arr_count()  then
                let ws.operacao      =  "a"
                let ws.mdtbotvalcod  =  a_ctc43m03[arr_aux].mdtbotvalcod
             end if

          before insert
             let ws.operacao = "i"
             initialize a_ctc43m03[arr_aux].*  to null
             display a_ctc43m03[arr_aux].*     to s_ctc43m03[scr_aux].*

          before field mdtbotvalcod
             display a_ctc43m03[arr_aux].mdtbotvalcod to
                     s_ctc43m03[scr_aux].mdtbotvalcod attribute (reverse)

          after field mdtbotvalcod
             display a_ctc43m03[arr_aux].mdtbotvalcod to
                     s_ctc43m03[scr_aux].mdtbotvalcod

             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field mdtbotvalcod
             end if

             if a_ctc43m03[arr_aux].mdtbotvalcod   is null    then
                error " Codigo do botao para validacao deve ser informado!"
                call ctc43m04()  returning a_ctc43m03[arr_aux].mdtbotvalcod
                next field mdtbotvalcod
             end if

            if a_ctc43m03[arr_aux].mdtbotvalcod  =  param.mdtbotcod   then
                error " Botao para validacao nao deve ser igual ao botao!"
                next field mdtbotvalcod
             end if

             if ws.operacao                       =  "a"             and
                a_ctc43m03[arr_aux].mdtbotvalcod  <>  ws.mdtbotvalcod   then
                error " Codigo do botao para validacao nao deve ser alterado!"
                next field mdtbotvalcod
             end if

            initialize a_ctc43m03[arr_aux].mdtbottxt  to null

             select mdtbottxt
               into a_ctc43m03[arr_aux].mdtbottxt
               from datkmdtbot
               where datkmdtbot.mdtbotcod  =  a_ctc43m03[arr_aux].mdtbotvalcod

             if sqlca.sqlcode  =  notfound   then
                error " Botao para validacao nao cadastrado!"
                call ctc43m04()  returning a_ctc43m03[arr_aux].mdtbotvalcod
                next field mdtbotvalcod
             end if

             display a_ctc43m03[arr_aux].mdtbottxt  to
                     s_ctc43m03[scr_aux].mdtbottxt

             #------------------------------------------------------------
             # Verifica se botao ja' foi cadastrado
             #------------------------------------------------------------
             if ws.operacao  =  "i"   then
                select mdtprgcod
                  from datkmdtbotval
                 where mdtprgcod     =  param.mdtprgcod
                   and mdtbotcod     =  param.mdtbotcod
                   and mdtbotvalcod  =  a_ctc43m03[arr_aux].mdtbotvalcod

                if sqlca.sqlcode  =  0   then
                  error " Botao para validacao ja' cadastrado!"
                   next field mdtbotvalcod
                end if
             end if

          on key (interrupt)
             exit input

          before delete
             let ws.operacao = "d"
             if a_ctc43m03[arr_aux].mdtbotvalcod  is null   then
                continue input
             end if

             let  ws.confirma  =  "N"
             call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                  returning ws.confirma

             if ws.confirma  =  "N"   then
                display a_ctc43m03[arr_aux].* to s_ctc43m03[scr_aux].*
                exit input
             end if

             begin work
                delete from datkmdtbotval
                 where mdtprgcod     =  param.mdtprgcod
                   and mdtbotcod     =  param.mdtbotcod
                    and mdtbotvalcod =  a_ctc43m03[arr_aux].mdtbotvalcod
             commit work

             initialize a_ctc43m03[arr_aux].*  to null
             display a_ctc43m03[arr_aux].*     to s_ctc43m03[scr_aux].*

          after row

             case ws.operacao
                when "i"
                    insert into datkmdtbotval
                               ( mdtprgcod,
                                 mdtbotcod,
                                 mdtbotvalcod)
                        values ( param.mdtprgcod,
                                 param.mdtbotcod,
                                 a_ctc43m03[arr_aux].mdtbotvalcod)

                    display a_ctc43m03[arr_aux].* to s_ctc43m03[scr_aux].*
             end case

             let ws.operacao = " "

    end input

    if int_flag    then
       exit while
    end if

 end while

#----------------------------------------------------------------
# Verifica se existe validacao cadastrada
#----------------------------------------------------------------
 let ws.mdtbotvldflg  =  "N"

 declare c_datkmdtbotval  cursor for
    select mdtbotvalcod
      from datkmdtbotval
     where datkmdtbotval.mdtprgcod  =  param.mdtprgcod
       and datkmdtbotval.mdtbotcod  =  param.mdtbotcod

 open  c_datkmdtbotval
 fetch c_datkmdtbotval
 if sqlca.sqlcode  =  0   then
    let ws.mdtbotvldflg  =  "S"
 end if
 close c_datkmdtbotval

 let int_flag = false
 close c_ctc43m03
 close window w_ctc43m03

 return ws.mdtbotvldflg

end function  ###  ctc43m03
