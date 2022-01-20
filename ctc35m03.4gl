###########################################################################
# Nome do Modulo: CTC35M03                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de itens para vistoria                                Dez/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc35m03()
#------------------------------------------------------------

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m03.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc35m03") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc35m03 at 4,2 with form "ctc35m03"

 menu "ITENS VISTORIA"

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
                   "Pesquisa item conforme criterios"
          call ctc35m03_seleciona()  returning d_ctc35m03.*
          if d_ctc35m03.socvstitmcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum item selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo item selecionado"
          message ""
          call ctc35m03_proximo(d_ctc35m03.socvstitmcod)
               returning d_ctc35m03.*

 command key ("A") "Anterior"
                   "Mostra item anterior selecionado"
          message ""
          if d_ctc35m03.socvstitmcod is not null then
             call ctc35m03_anterior(d_ctc35m03.socvstitmcod)
                  returning d_ctc35m03.*
          else
             error " Nenhum item nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica item corrente selecionado"
          message ""
          if d_ctc35m03.socvstitmcod  is not null then
             call ctc35m03_modifica(d_ctc35m03.socvstitmcod, d_ctc35m03.*)
                  returning d_ctc35m03.*
             next option "Seleciona"
          else
             error " Nenhum item selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui item"
          message ""
          call ctc35m03_inclui()
          next option "Seleciona"

   command "Remove" "Remove item corrente selecionado"
            message ""
            if d_ctc35m03.socvstitmcod  is not null   then
               call ctc35m03_remove(d_ctc35m03.*)
                    returning d_ctc35m03.*
               next option "Seleciona"
            else
               error " Nenhum item selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc35m03

 end function  # ctc35m03


#------------------------------------------------------------
 function ctc35m03_seleciona()
#------------------------------------------------------------

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m03.*  to null
 display by name d_ctc35m03.*

 input by name d_ctc35m03.socvstitmcod

    before field socvstitmcod
        display by name d_ctc35m03.socvstitmcod attribute (reverse)

        if d_ctc35m03.socvstitmcod  is null then
           let d_ctc35m03.socvstitmcod = 0
        end if

    after  field socvstitmcod
        display by name d_ctc35m03.socvstitmcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m03.*   to null
    display by name d_ctc35m03.*
    error " Operacao cancelada!"
    clear form
    return d_ctc35m03.*
 end if

 if d_ctc35m03.socvstitmcod  = 0  then
    select min(socvstitmcod)
      into d_ctc35m03.socvstitmcod
      from datkvstitm
     where datkvstitm.socvstitmcod > d_ctc35m03.socvstitmcod
 end if

 call ctc35m03_ler(d_ctc35m03.socvstitmcod)
      returning d_ctc35m03.*

 if d_ctc35m03.socvstitmcod  is not null   then
    display by name  d_ctc35m03.*
   else
    error " Item nao cadastrado!"
    initialize d_ctc35m03.*    to null
 end if

 return d_ctc35m03.*

 end function  # ctc35m03_seleciona


#------------------------------------------------------------
 function ctc35m03_proximo(param)
#------------------------------------------------------------

 define param         record
    socvstitmcod      like datkvstitm.socvstitmcod
 end record

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m03.*   to null

 if param.socvstitmcod  is null   then
    let param.socvstitmcod = 0
 end if

 select min(datkvstitm.socvstitmcod)
   into d_ctc35m03.socvstitmcod
   from datkvstitm
  where datkvstitm.socvstitmcod  >  param.socvstitmcod

 if d_ctc35m03.socvstitmcod  is not null   then

    call ctc35m03_ler(d_ctc35m03.socvstitmcod)
         returning d_ctc35m03.*

    if d_ctc35m03.socvstitmcod  is not null   then
       display by name d_ctc35m03.*
    else
       error " Nao ha' item nesta direcao!"
       initialize d_ctc35m03.*    to null
    end if
 else
    error " Nao ha' item nesta direcao!"
    initialize d_ctc35m03.*    to null
 end if

 return d_ctc35m03.*

 end function    # ctc35m03_proximo


#------------------------------------------------------------
 function ctc35m03_anterior(param)
#------------------------------------------------------------

 define param         record
    socvstitmcod      like datkvstitm.socvstitmcod
 end record

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m03.*  to null

 if param.socvstitmcod  is null   then
    let param.socvstitmcod = 0
 end if

 select max(datkvstitm.socvstitmcod)
   into d_ctc35m03.socvstitmcod
   from datkvstitm
  where datkvstitm.socvstitmcod  <  param.socvstitmcod

 if d_ctc35m03.socvstitmcod  is not null   then

    call ctc35m03_ler(d_ctc35m03.socvstitmcod)
         returning d_ctc35m03.*

    if d_ctc35m03.socvstitmcod  is not null   then
       display by name  d_ctc35m03.*
    else
       error " Nao ha' item nesta direcao!"
       initialize d_ctc35m03.*    to null
    end if
 else
    error " Nao ha' item nesta direcao!"
    initialize d_ctc35m03.*    to null
 end if

 return d_ctc35m03.*

 end function    # ctc35m03_anterior


#------------------------------------------------------------
 function ctc35m03_modifica(param, d_ctc35m03)
#------------------------------------------------------------

 define param         record
    socvstitmcod      like datkvstitm.socvstitmcod
 end record

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc35m03_input("a", d_ctc35m03.*) returning d_ctc35m03.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m03.*  to null
    display by name d_ctc35m03.*
    error " Operacao cancelada!"
    return d_ctc35m03.*
 end if

 whenever error continue

 let d_ctc35m03.atldat = today

 begin work
    update datkvstitm set  ( socvstitmdes,
                             socvstitmsit,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc35m03.socvstitmdes,
                             d_ctc35m03.socvstitmsit,
                             d_ctc35m03.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkvstitm.socvstitmcod  =  d_ctc35m03.socvstitmcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do item!"
       rollback work
       initialize d_ctc35m03.*   to null
       return d_ctc35m03.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc35m03.*  to null
 display by name d_ctc35m03.*
 message ""
 return d_ctc35m03.*

 end function   #  ctc35m03_modifica


#------------------------------------------------------------
 function ctc35m03_inclui()
#------------------------------------------------------------

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc35m03.*   to null
 display by name d_ctc35m03.*

 call ctc35m03_input("i", d_ctc35m03.*) returning d_ctc35m03.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m03.*  to null
    display by name d_ctc35m03.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc35m03.atldat = today
 let d_ctc35m03.caddat = today


 declare c_ctc35m03m  cursor with hold  for
         select  max(socvstitmcod)
           from  datkvstitm
          where  datkvstitm.socvstitmcod > 0

 foreach c_ctc35m03m  into  d_ctc35m03.socvstitmcod
     exit foreach
 end foreach

 if d_ctc35m03.socvstitmcod is null   then
    let d_ctc35m03.socvstitmcod = 0
 end if
 let d_ctc35m03.socvstitmcod = d_ctc35m03.socvstitmcod + 1


 whenever error continue

 begin work
    insert into datkvstitm ( socvstitmcod,
                             socvstitmdes,
                             socvstitmsit,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc35m03.socvstitmcod,
                             d_ctc35m03.socvstitmdes,
                             d_ctc35m03.socvstitmsit,
                             d_ctc35m03.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc35m03.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do item!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc35m03_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m03.cadfunnom

 call ctc35m03_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m03.funnom

 display by name  d_ctc35m03.*

 display by name d_ctc35m03.socvstitmcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc35m03.*  to null
 display by name d_ctc35m03.*

 end function   #  ctc35m03_inclui


#--------------------------------------------------------------------
 function ctc35m03_input(param, d_ctc35m03)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc35m03.socvstitmdes,
               d_ctc35m03.socvstitmsit  without defaults

    before field socvstitmdes
           display by name d_ctc35m03.socvstitmdes attribute (reverse)

    after  field socvstitmdes
           display by name d_ctc35m03.socvstitmdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstitmdes
           end if

           if d_ctc35m03.socvstitmdes  is null   then
              error " Descricao do item deve ser informada!"
              next field socvstitmdes
           end if

    before field socvstitmsit
           if param.operacao  =  "i"   then
              let d_ctc35m03.socvstitmsit = "A"
           end if
           display by name d_ctc35m03.socvstitmsit attribute (reverse)

    after  field socvstitmsit
           display by name d_ctc35m03.socvstitmsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstitmdes
           end if

           if d_ctc35m03.socvstitmsit  is null   or
             (d_ctc35m03.socvstitmsit  <> "A"    and
              d_ctc35m03.socvstitmsit  <> "C")   then
              error " Situacao do item deve ser: (A)tivo ou (C)ancelado!"
              next field socvstitmsit
           end if

           if param.operacao        = "i"   and
              d_ctc35m03.socvstitmsit  = "C"   then
              error " Nao deve ser incluido item com situacao (C)ancelado!"
              next field socvstitmsit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc35m03.*  to null
 end if

 return d_ctc35m03.*

 end function   # ctc35m03_input


#--------------------------------------------------------------------
 function ctc35m03_remove(d_ctc35m03)
#--------------------------------------------------------------------

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o item"
            clear form
            initialize d_ctc35m03.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui item"
            call ctc35m03_ler(d_ctc35m03.socvstitmcod) returning d_ctc35m03.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc35m03.* to null
               error " Item nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datrvstitmver
                where datrvstitmver.socvstitmcod = d_ctc35m03.socvstitmcod

                if ws.count > 0 then
                   error " Item possui registros na verificacao, portanto nao deve ser removido!"
                   exit menu
                end if

               begin work
                  delete from datkvstitm
                   where datkvstitm.socvstitmcod = d_ctc35m03.socvstitmcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc35m03.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do item!"
               else
                  initialize d_ctc35m03.* to null
                  error   " Item excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc35m03.*

end function    # ctc35m03_remove


#---------------------------------------------------------
 function ctc35m03_ler(param)
#---------------------------------------------------------

 define param         record
    socvstitmcod      like datkvstitm.socvstitmcod
 end record

 define d_ctc35m03    record
    socvstitmcod      like datkvstitm.socvstitmcod,
    socvstitmdes      like datkvstitm.socvstitmdes,
    socvstitmsit      like datkvstitm.socvstitmsit,
    caddat            like datkvstitm.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstitm.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc35m03.*   to null
 initialize ws.*           to null

 select  socvstitmcod,
         socvstitmdes,
         socvstitmsit,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc35m03.socvstitmcod,
         d_ctc35m03.socvstitmdes,
         d_ctc35m03.socvstitmsit,
         d_ctc35m03.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc35m03.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvstitm
  where  datkvstitm.socvstitmcod = param.socvstitmcod

 if sqlca.sqlcode = notfound   then
    error " Item nao cadastrado!"
    initialize d_ctc35m03.*    to null
    return d_ctc35m03.*
 else
    call ctc35m03_func(ws.cademp, ws.cadmat)
         returning d_ctc35m03.cadfunnom

    call ctc35m03_func(ws.atlemp, ws.atlmat)
         returning d_ctc35m03.funnom
 end if

 return d_ctc35m03.*

 end function   # ctc35m03_ler


#---------------------------------------------------------
 function ctc35m03_func(param)
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

 end function   # ctc35m03_func
