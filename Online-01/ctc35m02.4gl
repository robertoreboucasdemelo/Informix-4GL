###########################################################################
# Nome do Modulo: CTC35M02                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de Grupo de itens para vistoria                       Dez/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc35m02()
#------------------------------------------------------------

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m02.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc35m02") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc35m02 at 4,2 with form "ctc35m02"

 menu "GRUPO DE ITENS"

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
                   "Pesquisa grupo de itens conforme criterios"
          call ctc35m02_seleciona()  returning d_ctc35m02.*
          if d_ctc35m02.socvstitmgrpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum grupo de itens selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo grupo de itens selecionado"
          message ""
          call ctc35m02_proximo(d_ctc35m02.socvstitmgrpcod)
               returning d_ctc35m02.*

 command key ("A") "Anterior"
                   "Mostra grupo de itens anterior selecionado"
          message ""
          if d_ctc35m02.socvstitmgrpcod is not null then
             call ctc35m02_anterior(d_ctc35m02.socvstitmgrpcod)
                  returning d_ctc35m02.*
          else
             error " Nenhum grupo de itens nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica grupo de itens corrente selecionado"
          message ""
          if d_ctc35m02.socvstitmgrpcod  is not null then
             call ctc35m02_modifica(d_ctc35m02.socvstitmgrpcod, d_ctc35m02.*)
                  returning d_ctc35m02.*
             next option "Seleciona"
          else
             error " Nenhum grupo de itens selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui grupo de itens"
          message ""
          call ctc35m02_inclui()
          next option "Seleciona"

   command "Remove" "Remove grupo de itens corrente selecionado"
            message ""
            if d_ctc35m02.socvstitmgrpcod  is not null   then
               call ctc35m02_remove(d_ctc35m02.*)
                    returning d_ctc35m02.*
               next option "Seleciona"
            else
               error " Nenhum grupo de itens selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc35m02

 end function  # ctc35m02


#------------------------------------------------------------
 function ctc35m02_seleciona()
#------------------------------------------------------------

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m02.*  to null
 display by name d_ctc35m02.*

 input by name d_ctc35m02.socvstitmgrpcod

    before field socvstitmgrpcod
        display by name d_ctc35m02.socvstitmgrpcod attribute (reverse)

        if d_ctc35m02.socvstitmgrpcod is null then
           let d_ctc35m02.socvstitmgrpcod = 0
        end if

    after  field socvstitmgrpcod
        display by name d_ctc35m02.socvstitmgrpcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m02.*   to null
    display by name d_ctc35m02.*
    error " Operacao cancelada!"
    clear form
    return d_ctc35m02.*
 end if

 if d_ctc35m02.socvstitmgrpcod = 0  then
    select min(socvstitmgrpcod)
      into d_ctc35m02.socvstitmgrpcod
      from datkvstitmgrp
     where datkvstitmgrp.socvstitmgrpcod > d_ctc35m02.socvstitmgrpcod
 end if

 call ctc35m02_ler(d_ctc35m02.socvstitmgrpcod)
      returning d_ctc35m02.*

 if d_ctc35m02.socvstitmgrpcod  is not null   then
    display by name  d_ctc35m02.*
   else
    error " Grupo de itens nao cadastrado!"
    initialize d_ctc35m02.*    to null
 end if

 return d_ctc35m02.*

 end function  # ctc35m02_seleciona


#------------------------------------------------------------
 function ctc35m02_proximo(param)
#------------------------------------------------------------

 define param         record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod
 end record

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m02.*   to null

 if param.socvstitmgrpcod  is null   then
    let param.socvstitmgrpcod = 0
 end if

 select min(datkvstitmgrp.socvstitmgrpcod)
   into d_ctc35m02.socvstitmgrpcod
   from datkvstitmgrp
  where datkvstitmgrp.socvstitmgrpcod  >  param.socvstitmgrpcod

 if d_ctc35m02.socvstitmgrpcod  is not null   then

    call ctc35m02_ler(d_ctc35m02.socvstitmgrpcod)
         returning d_ctc35m02.*

    if d_ctc35m02.socvstitmgrpcod  is not null   then
       display by name d_ctc35m02.*
    else
       error " Nao ha' grupo de itens nesta direcao!"
       initialize d_ctc35m02.*    to null
    end if
 else
    error " Nao ha' grupo de itens nesta direcao!"
    initialize d_ctc35m02.*    to null
 end if

 return d_ctc35m02.*

 end function    # ctc35m02_proximo


#------------------------------------------------------------
 function ctc35m02_anterior(param)
#------------------------------------------------------------

 define param         record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod
 end record

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m02.*  to null

 if param.socvstitmgrpcod  is null   then
    let param.socvstitmgrpcod = 0
 end if

 select max(datkvstitmgrp.socvstitmgrpcod)
   into d_ctc35m02.socvstitmgrpcod
   from datkvstitmgrp
  where datkvstitmgrp.socvstitmgrpcod  <  param.socvstitmgrpcod

 if d_ctc35m02.socvstitmgrpcod  is not null   then

    call ctc35m02_ler(d_ctc35m02.socvstitmgrpcod)
         returning d_ctc35m02.*

    if d_ctc35m02.socvstitmgrpcod  is not null   then
       display by name  d_ctc35m02.*
    else
       error " Nao ha' grupo de itens nesta direcao!"
       initialize d_ctc35m02.*    to null
    end if
 else
    error " Nao ha' grupo de itens nesta direcao!"
    initialize d_ctc35m02.*    to null
 end if

 return d_ctc35m02.*

 end function    # ctc35m02_anterior


#------------------------------------------------------------
 function ctc35m02_modifica(param, d_ctc35m02)
#------------------------------------------------------------

 define param         record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod
 end record

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc35m02_input("a", d_ctc35m02.*) returning d_ctc35m02.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m02.*  to null
    display by name d_ctc35m02.*
    error " Operacao cancelada!"
    return d_ctc35m02.*
 end if

 whenever error continue

 let d_ctc35m02.atldat = today

 begin work
    update datkvstitmgrp set  ( socvstitmgrpdes,
                                socvstitmgrpsit,
                                atldat,
                                atlemp,
                                atlmat )
                           =  ( d_ctc35m02.socvstitmgrpdes,
                                d_ctc35m02.socvstitmgrpsit,
                                d_ctc35m02.atldat,
                                g_issk.empcod,
                                g_issk.funmat )
           where datkvstitmgrp.socvstitmgrpcod  =  d_ctc35m02.socvstitmgrpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do grupo de itens!"
       rollback work
       initialize d_ctc35m02.*   to null
       return d_ctc35m02.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc35m02.*  to null
 display by name d_ctc35m02.*
 message ""
 return d_ctc35m02.*

 end function   #  ctc35m02_modifica


#------------------------------------------------------------
 function ctc35m02_inclui()
#------------------------------------------------------------

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc35m02.*   to null
 display by name d_ctc35m02.*

 call ctc35m02_input("i", d_ctc35m02.*) returning d_ctc35m02.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m02.*  to null
    display by name d_ctc35m02.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc35m02.atldat = today
 let d_ctc35m02.caddat = today


 declare c_ctc35m02m  cursor with hold  for
         select  max(socvstitmgrpcod)
           from  datkvstitmgrp
          where  datkvstitmgrp.socvstitmgrpcod > 0

 foreach c_ctc35m02m  into  d_ctc35m02.socvstitmgrpcod
     exit foreach
 end foreach

 if d_ctc35m02.socvstitmgrpcod is null   then
    let d_ctc35m02.socvstitmgrpcod = 0
 end if
 let d_ctc35m02.socvstitmgrpcod = d_ctc35m02.socvstitmgrpcod + 1


 whenever error continue

 begin work
    insert into datkvstitmgrp ( socvstitmgrpcod,
                                socvstitmgrpdes,
                                socvstitmgrpsit,
                                caddat,
                                cademp,
                                cadmat,
                                atldat,
                                atlemp,
                                atlmat )
                     values
                              ( d_ctc35m02.socvstitmgrpcod,
                                d_ctc35m02.socvstitmgrpdes,
                                d_ctc35m02.socvstitmgrpsit,
                                d_ctc35m02.caddat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc35m02.atldat,
                                g_issk.empcod,
                                g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do grupo de itens!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc35m02_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m02.cadfunnom

 call ctc35m02_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m02.funnom

 display by name  d_ctc35m02.*

 display by name d_ctc35m02.socvstitmgrpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc35m02.*  to null
 display by name d_ctc35m02.*

 end function   #  ctc35m02_inclui


#--------------------------------------------------------------------
 function ctc35m02_input(param, d_ctc35m02)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc35m02.socvstitmgrpdes,
               d_ctc35m02.socvstitmgrpsit  without defaults

    before field socvstitmgrpdes
           display by name d_ctc35m02.socvstitmgrpdes attribute (reverse)

    after  field socvstitmgrpdes
           display by name d_ctc35m02.socvstitmgrpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstitmgrpdes
           end if

           if d_ctc35m02.socvstitmgrpdes  is null   then
              error " Descricao do grupo de itens deve ser informado!"
              next field socvstitmgrpdes
           end if

    before field socvstitmgrpsit
           if param.operacao  =  "i"   then
              let d_ctc35m02.socvstitmgrpsit = "A"
           end if
           display by name d_ctc35m02.socvstitmgrpsit attribute (reverse)

    after  field socvstitmgrpsit
           display by name d_ctc35m02.socvstitmgrpsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstitmgrpdes
           end if

           if d_ctc35m02.socvstitmgrpsit  is null   or
             (d_ctc35m02.socvstitmgrpsit  <> "A"    and
              d_ctc35m02.socvstitmgrpsit  <> "C")   then
              error " Situacao do grupo de itens deve ser: (A)tivo ou (C)ancelado!"
              next field socvstitmgrpsit
           end if

           if param.operacao        = "i"   and
              d_ctc35m02.socvstitmgrpsit  = "C"   then
              error " Nao deve ser incluido grupo de itens com situacao (C)ancelado!"
              next field socvstitmgrpsit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc35m02.*  to null
 end if

 return d_ctc35m02.*

 end function   # ctc35m02_input


#--------------------------------------------------------------------
 function ctc35m02_remove(d_ctc35m02)
#--------------------------------------------------------------------

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
     count            integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o grupo"
            clear form
            initialize d_ctc35m02.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui grupo de itens"
            call ctc35m02_ler(d_ctc35m02.socvstitmgrpcod) returning d_ctc35m02.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc35m02.* to null
               error " Grupo de itens nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datrvstitmver
                where datrvstitmver.socvstitmgrpcod = d_ctc35m02.socvstitmgrpcod
                if ws.count > 0 then
                   error " Grupo itens possui verificacao cadastrado(s), portanto nao deve ser removido!"
                   exit menu
                end if

               begin work
                  delete from datkvstitmgrp
                   where datkvstitmgrp.socvstitmgrpcod = d_ctc35m02.socvstitmgrpcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc35m02.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do grupo de itens!"
               else
                  initialize d_ctc35m02.* to null
                  error   " Grupo de itens excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc35m02.*

end function    # ctc35m02_remove


#---------------------------------------------------------
 function ctc35m02_ler(param)
#---------------------------------------------------------

 define param         record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod
 end record

 define d_ctc35m02    record
    socvstitmgrpcod   like datkvstitmgrp.socvstitmgrpcod,
    socvstitmgrpdes   like datkvstitmgrp.socvstitmgrpdes,
    socvstitmgrpsit   like datkvstitmgrp.socvstitmgrpsit,
    caddat            like datkvstitmgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitmgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc35m02.*   to null
 initialize ws.*           to null

 select  socvstitmgrpcod,
         socvstitmgrpdes,
         socvstitmgrpsit,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc35m02.socvstitmgrpcod,
         d_ctc35m02.socvstitmgrpdes,
         d_ctc35m02.socvstitmgrpsit,
         d_ctc35m02.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc35m02.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvstitmgrp
  where  datkvstitmgrp.socvstitmgrpcod = param.socvstitmgrpcod

 if sqlca.sqlcode = notfound   then
    error " Grupo de itens nao cadastrado!"
    initialize d_ctc35m02.*    to null
    return d_ctc35m02.*
 else
    call ctc35m02_func(ws.cademp, ws.cadmat)
         returning d_ctc35m02.cadfunnom

    call ctc35m02_func(ws.atlemp, ws.atlmat)
         returning d_ctc35m02.funnom
 end if

 return d_ctc35m02.*

 end function   # ctc35m02_ler


#---------------------------------------------------------
 function ctc35m02_func(param)
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

 end function   # ctc35m02_func
