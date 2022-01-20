###########################################################################
# Nome do Modulo: CTC35M04                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de verificacao de itens para vistoria                 Dez/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"


#------------------------------------------------------------
 function ctc35m04()
#------------------------------------------------------------

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m04.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc35m04") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc35m04 at 4,2 with form "ctc35m04"

 menu "VERIFICACOES DO ITEM"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
     end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa registro de verificacao conforme criterios"
          call ctc35m04_seleciona()  returning d_ctc35m04.*
          if d_ctc35m04.socvstitmvercod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum registro de verificacao selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo registro de verificacao selecionado"
          message ""
          call ctc35m04_proximo(d_ctc35m04.socvstitmvercod)
               returning d_ctc35m04.*

 command key ("A") "Anterior"
                   "Mostra registro de verificacao anterior selecionado"
          message ""
          if d_ctc35m04.socvstitmvercod is not null then
             call ctc35m04_anterior(d_ctc35m04.socvstitmvercod)
                  returning d_ctc35m04.*
          else
             error " Nenhum registro de verificacao nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica registro de verificacao corrente selecionado"
          message ""
          if d_ctc35m04.socvstitmvercod  is not null then
             call ctc35m04_modifica(d_ctc35m04.socvstitmvercod, d_ctc35m04.*)
                  returning d_ctc35m04.*
             next option "Seleciona"
          else
             error " Nenhum registro de verificacao selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui registro de verificacao"
          message ""
          call ctc35m04_inclui()
          next option "Seleciona"

   command "Remove" "Remove registro de verificacao corrente selecionado"
            message ""
            if d_ctc35m04.socvstitmvercod  is not null   then
               call ctc35m04_remove(d_ctc35m04.*)
                    returning d_ctc35m04.*
               next option "Seleciona"
            else
               error " Nenhum registro de verificacao selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc35m04

 end function  # ctc35m04


#------------------------------------------------------------
 function ctc35m04_seleciona()
#------------------------------------------------------------

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m04.*  to null
 display by name d_ctc35m04.*

 input by name d_ctc35m04.socvstitmvercod

    before field socvstitmvercod
        display by name d_ctc35m04.socvstitmvercod attribute (reverse)

        if d_ctc35m04.socvstitmvercod is null then
           let d_ctc35m04.socvstitmvercod = 0
        end if

    after  field socvstitmvercod
        display by name d_ctc35m04.socvstitmvercod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m04.*   to null
    display by name d_ctc35m04.*
    error " Operacao cancelada!"
    clear form
    return d_ctc35m04.*
 end if

 if d_ctc35m04.socvstitmvercod = 0 then
    select min(socvstitmvercod)
      into d_ctc35m04.socvstitmvercod
      from datkvstitmver
     where datkvstitmver.socvstitmvercod > d_ctc35m04.socvstitmvercod
 end if

 call ctc35m04_ler(d_ctc35m04.socvstitmvercod)
      returning d_ctc35m04.*

 if d_ctc35m04.socvstitmvercod  is not null   then
    display by name  d_ctc35m04.*
   else
    error " Registro de verificacao nao cadastrado!"
    initialize d_ctc35m04.*    to null
 end if

 return d_ctc35m04.*

 end function  # ctc35m04_seleciona


#------------------------------------------------------------
 function ctc35m04_proximo(param)
#------------------------------------------------------------

 define param         record
    socvstitmvercod   like datkvstitmver.socvstitmvercod
 end record

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m04.*   to null

 if param.socvstitmvercod  is null   then
    let param.socvstitmvercod = 0
 end if

 select min(datkvstitmver.socvstitmvercod)
   into d_ctc35m04.socvstitmvercod
   from datkvstitmver
  where datkvstitmver.socvstitmvercod  >  param.socvstitmvercod

 if d_ctc35m04.socvstitmvercod  is not null   then

    call ctc35m04_ler(d_ctc35m04.socvstitmvercod)
         returning d_ctc35m04.*

    if d_ctc35m04.socvstitmvercod  is not null   then
       display by name d_ctc35m04.*
    else
       error " Nao ha' registro de verificacao nesta direcao!"
       initialize d_ctc35m04.*    to null
    end if
 else
    error " Nao ha' registro de verificacao nesta direcao!"
    initialize d_ctc35m04.*    to null
 end if

 return d_ctc35m04.*

 end function    # ctc35m04_proximo


#------------------------------------------------------------
 function ctc35m04_anterior(param)
#------------------------------------------------------------

 define param         record
    socvstitmvercod   like datkvstitmver.socvstitmvercod
 end record

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m04.*  to null

 if param.socvstitmvercod  is null   then
    let param.socvstitmvercod = 0
 end if

 select max(datkvstitmver.socvstitmvercod)
   into d_ctc35m04.socvstitmvercod
   from datkvstitmver
  where datkvstitmver.socvstitmvercod  <  param.socvstitmvercod

 if d_ctc35m04.socvstitmvercod  is not null   then

    call ctc35m04_ler(d_ctc35m04.socvstitmvercod)
         returning d_ctc35m04.*

    if d_ctc35m04.socvstitmvercod  is not null   then
       display by name  d_ctc35m04.*
    else
       error " Nao ha' registro de verificacao nesta direcao!"
       initialize d_ctc35m04.*    to null
    end if
 else
    error " Nao ha' registro de verificacao nesta direcao!"
    initialize d_ctc35m04.*    to null
 end if

 return d_ctc35m04.*

 end function    # ctc35m04_anterior


#------------------------------------------------------------
 function ctc35m04_modifica(param, d_ctc35m04)
#------------------------------------------------------------

 define param         record
    socvstitmvercod   like datkvstitmver.socvstitmvercod
 end record

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc35m04_input("a", d_ctc35m04.*) returning d_ctc35m04.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m04.*  to null
    display by name d_ctc35m04.*
    error " Operacao cancelada!"
    return d_ctc35m04.*
 end if

 whenever error continue

 let d_ctc35m04.atldat = today

 begin work
    update datkvstitmver set  ( socvstitmverdes,
                                socvstitmversit,
                                atldat,
                                atlemp,
                                atlmat )
                           =  ( d_ctc35m04.socvstitmverdes,
                                d_ctc35m04.socvstitmversit,
                                d_ctc35m04.atldat,
                                g_issk.empcod,
                                g_issk.funmat )
           where datkvstitmver.socvstitmvercod  =  d_ctc35m04.socvstitmvercod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do registro de verificacao!"
       rollback work
       initialize d_ctc35m04.*   to null
       return d_ctc35m04.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc35m04.*  to null
 display by name d_ctc35m04.*
 message ""
 return d_ctc35m04.*

 end function   #  ctc35m04_modifica


#------------------------------------------------------------
 function ctc35m04_inclui()
#------------------------------------------------------------

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc35m04.*   to null
 display by name d_ctc35m04.*

 call ctc35m04_input("i", d_ctc35m04.*) returning d_ctc35m04.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m04.*  to null
    display by name d_ctc35m04.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc35m04.atldat = today
 let d_ctc35m04.caddat = today


 declare c_ctc35m04m  cursor with hold  for
         select  max(socvstitmvercod)
           from  datkvstitmver
          where  datkvstitmver.socvstitmvercod > 0

 foreach c_ctc35m04m  into  d_ctc35m04.socvstitmvercod
     exit foreach
 end foreach

 if d_ctc35m04.socvstitmvercod is null   then
    let d_ctc35m04.socvstitmvercod = 0
 end if
 let d_ctc35m04.socvstitmvercod = d_ctc35m04.socvstitmvercod + 1


 whenever error continue

 begin work
    insert into datkvstitmver ( socvstitmvercod,
                                socvstitmverdes,
                                socvstitmversit,
                                caddat,
                                cademp,
                                cadmat,
                                atldat,
                                atlemp,
                                atlmat )
                     values
                              ( d_ctc35m04.socvstitmvercod,
                                d_ctc35m04.socvstitmverdes,
                                d_ctc35m04.socvstitmversit,
                                d_ctc35m04.caddat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc35m04.atldat,
                                g_issk.empcod,
                                g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do registro de verificacao!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc35m04_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m04.cadfunnom

 call ctc35m04_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m04.funnom

 display by name  d_ctc35m04.*

 display by name d_ctc35m04.socvstitmvercod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc35m04.*  to null
 display by name d_ctc35m04.*

 end function   #  ctc35m04_inclui


#--------------------------------------------------------------------
 function ctc35m04_input(param, d_ctc35m04)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc35m04.socvstitmverdes,
               d_ctc35m04.socvstitmversit  without defaults

    before field socvstitmverdes
           display by name d_ctc35m04.socvstitmverdes attribute (reverse)

    after  field socvstitmverdes
           display by name d_ctc35m04.socvstitmverdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstitmverdes
           end if

           if d_ctc35m04.socvstitmverdes  is null   then
              error " Descricao do registro de verificacao deve ser informada!"
              next field socvstitmverdes
           end if

    before field socvstitmversit
           if param.operacao  =  "i"   then
              let d_ctc35m04.socvstitmversit = "A"
           end if
           display by name d_ctc35m04.socvstitmversit attribute (reverse)

    after  field socvstitmversit
           display by name d_ctc35m04.socvstitmversit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstitmverdes
           end if

           if d_ctc35m04.socvstitmversit  is null   or
             (d_ctc35m04.socvstitmversit  <> "A"    and
              d_ctc35m04.socvstitmversit  <> "C")   then
              error " Situacao do registro de verificacao deve ser: (A)tivo ou (C)ancelado!"
              next field socvstitmversit
           end if

           if param.operacao        = "i"   and
              d_ctc35m04.socvstitmversit  = "C"   then
              error " Nao deve ser incluido registro de verificacao com situacao (C)ancelado!"
              next field socvstitmversit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc35m04.*  to null
 end if

 return d_ctc35m04.*

 end function   # ctc35m04_input


#--------------------------------------------------------------------
 function ctc35m04_remove(d_ctc35m04)
#--------------------------------------------------------------------

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o registro de verificacao"
            clear form
            initialize d_ctc35m04.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui registro de verificacao"
            call ctc35m04_ler(d_ctc35m04.socvstitmvercod) returning d_ctc35m04.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc35m04.* to null
               error " Registro de verificacao nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datrvstitmver
                where datrvstitmver.socvstitmvercod = d_ctc35m04.socvstitmvercod
                if ws.count > 0 then
                   error " Registro cadastrado na verificacao do item, portanto nao deve ser removido!"
                   exit menu
                end if

               begin work
                  delete from datkvstitmver
                   where datkvstitmver.socvstitmvercod = d_ctc35m04.socvstitmvercod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc35m04.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do registro de verificacao!"
               else
                  initialize d_ctc35m04.* to null
                  error   " Registro de verificacao excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc35m04.*

end function    # ctc35m04_remove


#---------------------------------------------------------
 function ctc35m04_ler(param)
#---------------------------------------------------------

 define param         record
    socvstitmvercod   like datkvstitmver.socvstitmvercod
 end record

 define d_ctc35m04    record
    socvstitmvercod   like datkvstitmver.socvstitmvercod,
    socvstitmverdes   like datkvstitmver.socvstitmverdes,
    socvstitmversit   like datkvstitmver.socvstitmversit,
    caddat            like datkvstitmver.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmver.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc35m04.*   to null
 initialize ws.*           to null

 select  socvstitmvercod,
         socvstitmverdes,
         socvstitmversit,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc35m04.socvstitmvercod,
         d_ctc35m04.socvstitmverdes,
         d_ctc35m04.socvstitmversit,
         d_ctc35m04.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc35m04.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvstitmver
  where  datkvstitmver.socvstitmvercod = param.socvstitmvercod

 if sqlca.sqlcode = notfound   then
    error " Registro de verificacao nao cadastrado!"
    initialize d_ctc35m04.*    to null
    return d_ctc35m04.*
 else
    call ctc35m04_func(ws.cademp, ws.cadmat)
         returning d_ctc35m04.cadfunnom

    call ctc35m04_func(ws.atlemp, ws.atlmat)
         returning d_ctc35m04.funnom
 end if

 return d_ctc35m04.*

 end function   # ctc35m04_ler


#---------------------------------------------------------
 function ctc35m04_func(param)
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

 end function   # ctc35m04_func
