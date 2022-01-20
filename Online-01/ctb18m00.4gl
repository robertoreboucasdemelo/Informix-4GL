###########################################################################
# Nome do Modulo: CTB18M00                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de Cronogramas dos prestadores                        dez/1999 #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------
 function ctb18m00()
#-------------------------------------------------------------

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb18m00.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctb18m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctb18m00 at 4,2 with form "ctb18m00"

 menu "CRONOGRAMA"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Datas", "Remove"
     end if
     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa cronograma conforme criterios"
          call ctb18m00_seleciona()  returning d_ctb18m00.*
          if d_ctb18m00.crnpgtcod    is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum cronograma selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo cronograma selecionado"
          message ""
          call ctb18m00_proximo(d_ctb18m00.crnpgtcod)
               returning d_ctb18m00.*

 command key ("A") "Anterior"
                   "Mostra cronograma anterior selecionado"
          message ""
          if d_ctb18m00.crnpgtcod is not null then
             call ctb18m00_anterior(d_ctb18m00.crnpgtcod)
                  returning d_ctb18m00.*
          else
             error " Nenhum cronograma nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica cronograma corrente selecionado"
          message ""
          if d_ctb18m00.crnpgtcod  is not null then
             call ctb18m00_modifica(d_ctb18m00.crnpgtcod, d_ctb18m00.*)
                  returning d_ctb18m00.*
             next option "Seleciona"
          else
             error " Nenhum cronograma selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui cronograma"
          message ""
          call ctb18m00_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove cronograma corrente selecionado"
            message ""
            if d_ctb18m00.crnpgtcod  is not null   then
               call ctb18m00_remove(d_ctb18m00.*)
                    returning d_ctb18m00.*
               next option "Seleciona"
            else
               error " Nenhum cronograma selecionado!"
               next option "Seleciona"
            end if

 command key ("D") "Datas"
                   "Datas de entrega do movimento para pagamento"
          message ""
          if d_ctb18m00.crnpgtcod  is not null then
             call ctb18m01(d_ctb18m00.crnpgtcod)
             next option "Seleciona"
          else
             error " Nenhum cronograma selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb18m00

 end function  # ctb18m00


#------------------------------------------------------------
 function ctb18m00_seleciona()
#------------------------------------------------------------

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb18m00.*  to null
 display by name d_ctb18m00.*

 input by name d_ctb18m00.crnpgtcod

    before field crnpgtcod
        display by name d_ctb18m00.crnpgtcod attribute (reverse)

        if d_ctb18m00.crnpgtcod is null then
           let d_ctb18m00.crnpgtcod = 0
        end if

    after  field crnpgtcod
        display by name d_ctb18m00.crnpgtcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb18m00.*   to null
    display by name d_ctb18m00.*
    error " Operacao cancelada!"
    clear form
    return d_ctb18m00.*
 end if

 if d_ctb18m00.crnpgtcod = 0 then
    select min(crnpgtcod)
      into d_ctb18m00.crnpgtcod
      from dbsmcrnpgt
     where dbsmcrnpgt.crnpgtcod > d_ctb18m00.crnpgtcod
 end if

 call ctb18m00_ler(d_ctb18m00.crnpgtcod)
      returning d_ctb18m00.*

 if d_ctb18m00.crnpgtcod  is not null   then
    display by name  d_ctb18m00.*
   else
    error " Cronograma nao cadastrado!"
    initialize d_ctb18m00.*    to null
 end if

 return d_ctb18m00.*

 end function  # ctb18m00_seleciona


#------------------------------------------------------------
 function ctb18m00_proximo(param)
#------------------------------------------------------------

 define param         record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod
 end record

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb18m00.*   to null

 if param.crnpgtcod  is null   then
    let param.crnpgtcod = 0
 end if

 select min(dbsmcrnpgt.crnpgtcod)
   into d_ctb18m00.crnpgtcod
   from dbsmcrnpgt
  where dbsmcrnpgt.crnpgtcod  >  param.crnpgtcod

 if d_ctb18m00.crnpgtcod  is not null   then
    call ctb18m00_ler(d_ctb18m00.crnpgtcod)
         returning d_ctb18m00.*

    if d_ctb18m00.crnpgtcod  is not null   then
       display by name d_ctb18m00.*
    else
       error " Nao ha' cronograma nesta direcao!"
       initialize d_ctb18m00.*    to null
    end if
 else
    error " Nao ha' cronograma nesta direcao!"
    initialize d_ctb18m00.*    to null
 end if

 return d_ctb18m00.*

 end function    # ctb18m00_proximo


#------------------------------------------------------------
 function ctb18m00_anterior(param)
#------------------------------------------------------------

 define param         record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod
 end record

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
 initialize d_ctb18m00.*  to null

 if param.crnpgtcod  is null   then
    let param.crnpgtcod = 0
 end if

 select max(dbsmcrnpgt.crnpgtcod)
   into d_ctb18m00.crnpgtcod
   from dbsmcrnpgt
  where dbsmcrnpgt.crnpgtcod  <  param.crnpgtcod

 if d_ctb18m00.crnpgtcod  is not null   then

    call ctb18m00_ler(d_ctb18m00.crnpgtcod)
         returning d_ctb18m00.*

    if d_ctb18m00.crnpgtcod  is not null   then
       display by name  d_ctb18m00.*
    else
       error " Nao ha' cronograma nesta direcao!"
       initialize d_ctb18m00.*    to null
    end if
 else
    error " Nao ha' cronograma nesta direcao!"
    initialize d_ctb18m00.*    to null
 end if

 return d_ctb18m00.*

 end function    # ctb18m00_anterior


#------------------------------------------------------------
 function ctb18m00_modifica(param, d_ctb18m00)
#------------------------------------------------------------

 define param         record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod
 end record

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctb18m00_input("a", d_ctb18m00.*) returning d_ctb18m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb18m00.*  to null
    display by name d_ctb18m00.*
    error " Operacao cancelada!"
    return d_ctb18m00.*
 end if

 whenever error continue

 let d_ctb18m00.atldat = today

 begin work
    update dbsmcrnpgt set  ( crnpgtdes,
                             crnpgtstt,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctb18m00.crnpgtdes,
                             d_ctb18m00.crnpgtstt,
                             d_ctb18m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
       where dbsmcrnpgt.crnpgtcod  =  d_ctb18m00.crnpgtcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do cronograma!"
       rollback work
       initialize d_ctb18m00.*   to null
       return d_ctb18m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb18m00.*  to null
 display by name d_ctb18m00.*
 message ""
 return d_ctb18m00.*

 end function   #  ctb18m00_modifica


#------------------------------------------------------------
 function ctb18m00_inclui()
#------------------------------------------------------------

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws           record
    confirma          char(01)
 end record


 initialize d_ctb18m00.*   to null
 display by name d_ctb18m00.*

 call ctb18m00_input("i", d_ctb18m00.*) returning d_ctb18m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb18m00.*  to null
    display by name d_ctb18m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctb18m00.atldat = today
 let d_ctb18m00.caddat = today

 select  max(crnpgtcod)
   into  d_ctb18m00.crnpgtcod
   from  dbsmcrnpgt
  where  dbsmcrnpgt.crnpgtcod > 0

 if d_ctb18m00.crnpgtcod is null   then
    let d_ctb18m00.crnpgtcod = 0
 end if
 let d_ctb18m00.crnpgtcod = d_ctb18m00.crnpgtcod + 1


 whenever error continue

 begin work
    insert into dbsmcrnpgt ( crnpgtcod,
                             crnpgtdes,
                             crnpgtstt,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values   ( d_ctb18m00.crnpgtcod,
                             d_ctb18m00.crnpgtdes,
                             d_ctb18m00.crnpgtstt,
                             d_ctb18m00.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctb18m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do cronograma!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctb18m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb18m00.cadfunnom

 call ctb18m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb18m00.funnom

 display by name  d_ctb18m00.*

 display by name d_ctb18m00.crnpgtcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.confirma

 initialize d_ctb18m00.*  to null
 display by name d_ctb18m00.*

 end function   #  ctb18m00_inclui


#--------------------------------------------------------------------
 function ctb18m00_input(param, d_ctb18m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctb18m00.crnpgtdes,
               d_ctb18m00.crnpgtstt  without defaults

    before field crnpgtdes
           display by name d_ctb18m00.crnpgtdes attribute (reverse)

    after  field crnpgtdes
           display by name d_ctb18m00.crnpgtdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  crnpgtdes
           end if

           if d_ctb18m00.crnpgtdes  is null   then
              error " Descricao do cronograma  deve ser informada!"
              next field crnpgtdes
           end if

    before field crnpgtstt
           if param.operacao  =  "i"   then
              let d_ctb18m00.crnpgtstt = "A"
           end if
           display by name d_ctb18m00.crnpgtstt attribute (reverse)

    after  field crnpgtstt
           display by name d_ctb18m00.crnpgtstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field crnpgtdes
           end if

           if d_ctb18m00.crnpgtstt  is null   or
             (d_ctb18m00.crnpgtstt  <> "A"    and
              d_ctb18m00.crnpgtstt  <> "C")   then
              error " Situacao do cronograma deve ser: (A)tivo ou (C)ancelado!"
              next field crnpgtstt
           end if

           if param.operacao        = "i"   and
              d_ctb18m00.crnpgtstt  = "C"   then
              error " Nao se deve incluir cronograma com situacao (C)ancelado!"
              next field crnpgtstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctb18m00.*  to null
 end if

 return d_ctb18m00.*

 end function   # ctb18m00_input


#--------------------------------------------------------------------
 function ctb18m00_remove(d_ctb18m00)
#--------------------------------------------------------------------

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o cronograma"
            clear form
            initialize d_ctb18m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui cronograma"
            call ctb18m00_ler(d_ctb18m00.crnpgtcod) returning d_ctb18m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb18m00.* to null
               error " Cronograma nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from dpaksocor
                where dpaksocor.crnpgtcod = d_ctb18m00.crnpgtcod

               if ws.count > 0 then
                  error " Cronograma esta relacionado com prestador, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from dbsmcrnpgt
                   where dbsmcrnpgt.crnpgtcod = d_ctb18m00.crnpgtcod

                  if sqlca.sqlcode <> 0   then
                     rollback work
                     initialize d_ctb18m00.* to null
                     error " Erro (",sqlca.sqlcode,") na exclusao do cronograma!"
                  else
                     delete from dbsmcrnpgtetg
                      where dbsmcrnpgtetg.crnpgtcod = d_ctb18m00.crnpgtcod

                     if sqlca.sqlcode <> 0   then
                        rollback work
                        initialize d_ctb18m00.* to null
                        error " Erro (",sqlca.sqlcode,") na exclusao do cronograma!"
                     else
                        commit work
                        initialize d_ctb18m00.* to null
                        error   " Cronograma excluido!"
                        message ""
                        clear form
                     end if
                  end if
            end if
            exit menu
 end menu

 return d_ctb18m00.*

end function    # ctb18m00_remove


#---------------------------------------------------------
 function ctb18m00_ler(param)
#---------------------------------------------------------

 define param         record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod
 end record

 define d_ctb18m00    record
    crnpgtcod         like dbsmcrnpgt.crnpgtcod,
    crnpgtdes         like dbsmcrnpgt.crnpgtdes,
    crnpgtstt         like dbsmcrnpgt.crnpgtstt,
    caddat            like dbsmcrnpgt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dbsmcrnpgt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctb18m00.*   to null
 initialize ws.*           to null

 select  crnpgtcod,
         crnpgtdes,
         crnpgtstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctb18m00.crnpgtcod,
         d_ctb18m00.crnpgtdes,
         d_ctb18m00.crnpgtstt,
         d_ctb18m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctb18m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  dbsmcrnpgt
  where  dbsmcrnpgt.crnpgtcod = param.crnpgtcod

 if sqlca.sqlcode = notfound   then
    error " Cronograma nao cadastrado!"
    initialize d_ctb18m00.*    to null
    return d_ctb18m00.*
 else
    call ctb18m00_func(ws.cademp, ws.cadmat)
         returning d_ctb18m00.cadfunnom

    call ctb18m00_func(ws.atlemp, ws.atlmat)
         returning d_ctb18m00.funnom
 end if

 return d_ctb18m00.*

 end function   # ctb18m00_ler


#---------------------------------------------------------
 function ctb18m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctb18m00_func
