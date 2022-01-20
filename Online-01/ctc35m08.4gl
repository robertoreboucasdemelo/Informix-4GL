###########################################################################
# Nome do Modulo: CTC35M08                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de Locais de vistoria veiculos auto socorro           Dez/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc35m08()
#------------------------------------------------------------

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m08.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc35m08") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc35m08 at 4,2 with form "ctc35m08"

 menu "LOCAIS DE VISTORIA"

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
                   "Pesquisa local de vistoria conforme criterios"
          call ctc35m08_seleciona()  returning d_ctc35m08.*
          if d_ctc35m08.socvstlclcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum local de vistoria selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo local de vistoria selecionado"
          message ""
          call ctc35m08_proximo(d_ctc35m08.socvstlclcod)
               returning d_ctc35m08.*

 command key ("A") "Anterior"
                   "Mostra local de vistoria anterior selecionado"
          message ""
          if d_ctc35m08.socvstlclcod is not null then
             call ctc35m08_anterior(d_ctc35m08.socvstlclcod)
                  returning d_ctc35m08.*
          else
             error " Nenhum local de vistoria nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica local de vistoria corrente selecionado"
          message ""
          if d_ctc35m08.socvstlclcod  is not null then
             call ctc35m08_modifica(d_ctc35m08.socvstlclcod, d_ctc35m08.*)
                  returning d_ctc35m08.*
             next option "Seleciona"
          else
             error " Nenhum local de vistoria selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui local de vistoria"
          message ""
          call ctc35m08_inclui()
          next option "Seleciona"

   command "Remove" "Remove local de vistoria corrente selecionado"
            message ""
            if d_ctc35m08.socvstlclcod  is not null   then
               call ctc35m08_remove(d_ctc35m08.*)
                    returning d_ctc35m08.*
               next option "Seleciona"
            else
               error " Nenhum local de vistoria selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc35m08

 end function  # ctc35m08


#------------------------------------------------------------
 function ctc35m08_seleciona()
#------------------------------------------------------------

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m08.*  to null
 display by name d_ctc35m08.*

 input by name d_ctc35m08.socvstlclcod

    before field socvstlclcod
        display by name d_ctc35m08.socvstlclcod attribute (reverse)

        if d_ctc35m08.socvstlclcod is null then
           let d_ctc35m08.socvstlclcod = 0
        end if

    after  field socvstlclcod
        display by name d_ctc35m08.socvstlclcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m08.*   to null
    display by name d_ctc35m08.*
    error " Operacao cancelada!"
    clear form
    return d_ctc35m08.*
 end if

 if d_ctc35m08.socvstlclcod = 0 then
    select min(socvstlclcod)
      into d_ctc35m08.socvstlclcod
          from datkvstlcl
         where datkvstlcl.socvstlclcod > d_ctc35m08.socvstlclcod
 end if

 call ctc35m08_ler(d_ctc35m08.socvstlclcod)
      returning d_ctc35m08.*

 if d_ctc35m08.socvstlclcod  is not null   then
    display by name  d_ctc35m08.*
   else
    error " Local de vistoria nao cadastrado!"
    initialize d_ctc35m08.*    to null
 end if

 return d_ctc35m08.*

 end function  # ctc35m08_seleciona


#------------------------------------------------------------
 function ctc35m08_proximo(param)
#------------------------------------------------------------

 define param         record
    socvstlclcod      like datkvstlcl.socvstlclcod
 end record

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m08.*   to null

 if param.socvstlclcod  is null   then
    let param.socvstlclcod = 0
 end if

 select min(datkvstlcl.socvstlclcod)
   into d_ctc35m08.socvstlclcod
   from datkvstlcl
  where datkvstlcl.socvstlclcod  >  param.socvstlclcod

 if d_ctc35m08.socvstlclcod  is not null   then

    call ctc35m08_ler(d_ctc35m08.socvstlclcod)
         returning d_ctc35m08.*

    if d_ctc35m08.socvstlclcod  is not null   then
       display by name d_ctc35m08.*
    else
       error " Nao ha' local de vistoria nesta direcao!"
       initialize d_ctc35m08.*    to null
    end if
 else
    error " Nao ha' local de vistoria nesta direcao!"
    initialize d_ctc35m08.*    to null
 end if

 return d_ctc35m08.*

 end function    # ctc35m08_proximo


#------------------------------------------------------------
 function ctc35m08_anterior(param)
#------------------------------------------------------------

 define param         record
    socvstlclcod      like datkvstlcl.socvstlclcod
 end record

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m08.*  to null

 if param.socvstlclcod  is null   then
    let param.socvstlclcod = 0
 end if

 select max(datkvstlcl.socvstlclcod)
   into d_ctc35m08.socvstlclcod
   from datkvstlcl
  where datkvstlcl.socvstlclcod  <  param.socvstlclcod

 if d_ctc35m08.socvstlclcod  is not null   then

    call ctc35m08_ler(d_ctc35m08.socvstlclcod)
         returning d_ctc35m08.*

    if d_ctc35m08.socvstlclcod  is not null   then
       display by name  d_ctc35m08.*
    else
       error " Nao ha' local de vistoria nesta direcao!"
       initialize d_ctc35m08.*    to null
    end if
 else
    error " Nao ha' local de vistoria nesta direcao!"
    initialize d_ctc35m08.*    to null
 end if

 return d_ctc35m08.*

 end function    # ctc35m08_anterior


#------------------------------------------------------------
 function ctc35m08_modifica(param, d_ctc35m08)
#------------------------------------------------------------

 define param         record
    socvstlclcod      like datkvstlcl.socvstlclcod
 end record

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc35m08_input("a", d_ctc35m08.*) returning d_ctc35m08.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m08.*  to null
    display by name d_ctc35m08.*
    error " Operacao cancelada!"
    return d_ctc35m08.*
 end if

 whenever error continue

 let d_ctc35m08.atldat = today

 begin work
    update datkvstlcl set  ( socvstlclnom,
                             socvstlclrsnom,
                             socvstlclsit,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc35m08.socvstlclnom,
                             d_ctc35m08.socvstlclrsnom,
                             d_ctc35m08.socvstlclsit,
                             d_ctc35m08.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkvstlcl.socvstlclcod  =  d_ctc35m08.socvstlclcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do local de vistoria!"
       rollback work
       initialize d_ctc35m08.*   to null
       return d_ctc35m08.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc35m08.*  to null
 display by name d_ctc35m08.*
 message ""
 return d_ctc35m08.*

 end function   #  ctc35m08_modifica


#------------------------------------------------------------
 function ctc35m08_inclui()
#------------------------------------------------------------

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp      char(01)


 initialize d_ctc35m08.*   to null
 display by name d_ctc35m08.*

 call ctc35m08_input("i", d_ctc35m08.*) returning d_ctc35m08.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m08.*  to null
    display by name d_ctc35m08.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc35m08.atldat = today
 let d_ctc35m08.caddat = today


 declare c_ctc35m08m  cursor with hold  for
         select  max(socvstlclcod)
           from  datkvstlcl
          where  datkvstlcl.socvstlclcod > 0

 foreach c_ctc35m08m  into  d_ctc35m08.socvstlclcod
     exit foreach
 end foreach

 if d_ctc35m08.socvstlclcod is null   then
    let d_ctc35m08.socvstlclcod = 0
 end if
 let d_ctc35m08.socvstlclcod = d_ctc35m08.socvstlclcod + 1


 whenever error continue

 begin work
    insert into datkvstlcl ( socvstlclcod,
                             socvstlclnom,
                             socvstlclrsnom,
                             socvstlclsit,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc35m08.socvstlclcod,
                             d_ctc35m08.socvstlclnom,
                             d_ctc35m08.socvstlclrsnom,
                             d_ctc35m08.socvstlclsit,
                             d_ctc35m08.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc35m08.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do local de vistoria!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc35m08_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m08.cadfunnom

 call ctc35m08_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m08.funnom

 display by name  d_ctc35m08.*

 display by name d_ctc35m08.socvstlclcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc35m08.*  to null
 display by name d_ctc35m08.*

 end function   #  ctc35m08_inclui


#--------------------------------------------------------------------
 function ctc35m08_input(param, d_ctc35m08)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc35m08.socvstlclnom,
               d_ctc35m08.socvstlclrsnom,
               d_ctc35m08.socvstlclsit  without defaults

    before field socvstlclnom
           display by name d_ctc35m08.socvstlclnom attribute (reverse)

    after  field socvstlclnom
           display by name d_ctc35m08.socvstlclnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstlclnom
           end if

           if d_ctc35m08.socvstlclnom  is null   then
              error " Nome do local de vistoria deve ser informado!"
              next field socvstlclnom
           end if

    before field socvstlclrsnom
           display by name d_ctc35m08.socvstlclrsnom attribute (reverse)

    after  field socvstlclrsnom
           display by name d_ctc35m08.socvstlclrsnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstlclnom
           end if

           if d_ctc35m08.socvstlclrsnom  is null   then
              error " Nome do responsavel deve ser informado!"
              next field socvstlclrsnom
           end if

           initialize ws.socvstlclcod  to null
           initialize ws.socvstlclnom  to null

    before field socvstlclsit
           if param.operacao  =  "i"   then
              let d_ctc35m08.socvstlclsit = "A"
           end if
           display by name d_ctc35m08.socvstlclsit attribute (reverse)

    after  field socvstlclsit
           display by name d_ctc35m08.socvstlclsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstlclrsnom
           end if

           if d_ctc35m08.socvstlclsit  is null   or
             (d_ctc35m08.socvstlclsit  <> "A"    and
              d_ctc35m08.socvstlclsit  <> "C")   then
              error " Situacao do local de vistoria deve ser: (A)tivo ou (C)ancelado!"
              next field socvstlclsit
           end if

           if param.operacao        = "i"   and
              d_ctc35m08.socvstlclsit  = "C"   then
              error " Nao deve ser incluido local de vistoria com situacao (C)ancelado!"
              next field socvstlclsit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc35m08.*  to null
 end if

 return d_ctc35m08.*

 end function   # ctc35m08_input


#--------------------------------------------------------------------
 function ctc35m08_remove(d_ctc35m08)
#--------------------------------------------------------------------

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o local de vistoria"
            clear form
            initialize d_ctc35m08.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui local de vistoria"
            call ctc35m08_ler(d_ctc35m08.socvstlclcod) returning d_ctc35m08.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc35m08.* to null
               error " Local de vistoria nao localizado!"
             else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datkveiculo
                where datkveiculo.socvstlclcod = d_ctc35m08.socvstlclcod

               if ws.count > 0 then
                  error " Local possui veiculo(s) cadastrado(s), portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkvstlcl
                   where datkvstlcl.socvstlclcod = d_ctc35m08.socvstlclcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc35m08.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do local de vistoria!"
               else
                  initialize d_ctc35m08.* to null
                  error   " Local de vistoria excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc35m08.*

end function    # ctc35m08_remove


#---------------------------------------------------------
 function ctc35m08_ler(param)
#---------------------------------------------------------

 define param         record
    socvstlclcod      like datkvstlcl.socvstlclcod
 end record

 define d_ctc35m08    record
    socvstlclcod      like datkvstlcl.socvstlclcod,
    socvstlclnom      like datkvstlcl.socvstlclnom,
    socvstlclrsnom    like datkvstlcl.socvstlclrsnom,
    socvstlclsit      like datkvstlcl.socvstlclsit,
    caddat            like datkvstlcl.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlcl.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc35m08.*   to null
 initialize ws.*           to null

 select  socvstlclcod,
         socvstlclnom,
         socvstlclrsnom,
         socvstlclsit,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc35m08.socvstlclcod,
         d_ctc35m08.socvstlclnom,
         d_ctc35m08.socvstlclrsnom,
         d_ctc35m08.socvstlclsit,
         d_ctc35m08.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc35m08.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvstlcl
  where  datkvstlcl.socvstlclcod = param.socvstlclcod

 if sqlca.sqlcode = notfound   then
    error " Local de vistoria nao cadastrado!"
    initialize d_ctc35m08.*    to null
    return d_ctc35m08.*
 else
    call ctc35m08_func(ws.cademp, ws.cadmat)
         returning d_ctc35m08.cadfunnom

    call ctc35m08_func(ws.atlemp, ws.atlmat)
         returning d_ctc35m08.funnom
 end if

 return d_ctc35m08.*

 end function   # ctc35m08_ler


#---------------------------------------------------------
 function ctc35m08_func(param)
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

 end function   # ctc35m08_func
