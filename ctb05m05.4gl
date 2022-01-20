###############################################################################
# Nome do Modulo: CTB05M05                                           Wagner   #
#                                                                             #
# Exibe as ordens de pagto. encontradas para uma O.S.                Mar/2002 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb05m05(param)
#-----------------------------------------------------------

 define param      record
    atdsrvnum      like dbsmopgitm.atdsrvnum,
    atdsrvano      like dbsmopgitm.atdsrvano
 end record

 define ws         record
    socopgsitcod   like dbsmopg.socopgsitcod
 end record

 define arr_aux    smallint

 define a_ctb05m05 array[10] of record
    socopgnum      like dbsmopg.socopgnum,
    socopgsitdes   char (15),
    socfatentdat   like dbsmopg.socfatentdat
 end record

 initialize a_ctb05m05 to null
 initialize ws.*       to null

 let arr_aux = 1

 declare c_ctb05m05 cursor for
    select dbsmopg.socopgnum,
           dbsmopg.socopgsitcod,
           dbsmopg.socfatentdat
      from dbsmopgitm, dbsmopg
     where dbsmopgitm.atdsrvnum = param.atdsrvnum  and
           dbsmopgitm.atdsrvano = param.atdsrvano  and
           dbsmopgitm.socopgnum = dbsmopg.socopgnum

 foreach c_ctb05m05 into a_ctb05m05[arr_aux].socopgnum,
                         ws.socopgsitcod,
                         a_ctb05m05[arr_aux].socfatentdat

    let a_ctb05m05[arr_aux].socopgsitdes = "**NAO PREVISTA**"

    select cpodes
      into a_ctb05m05[arr_aux].socopgsitdes
      from iddkdominio
     where cponom = 'socopgsitcod'  and
           cpocod = ws.socopgsitcod

    let arr_aux = arr_aux + 1

    if arr_aux  >  10   then
       error "Limite excedido. Existem mais de 10 ordens de pagamento para O.S. informada!"
       exit foreach
    end if
 end foreach

 if arr_aux = 1  then
    error " O.S. nao consta em nenhuma ordem de pagamento!"
 else
    if arr_aux = 2  then
       let arr_aux = 1
    else
       open window ctb05m05 at 08,12 with form "ctb05m05"
                            attribute(form line 1, border)

       message " (F17)Abandona, (F8)Seleciona"

       call set_count(arr_aux - 1)

       display array a_ctb05m05 to s_ctb05m05.*

          on key (interrupt,control-c)
             initialize a_ctb05m05   to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             exit display

       end display

       close window  ctb05m05

       if int_flag  then
          error " Nenhuma ordem de pagamento foi selecionada!"
          let int_flag = false
       end if
    end if
 end if

 return a_ctb05m05[arr_aux].socopgnum

end function  ###  ctb05m05
