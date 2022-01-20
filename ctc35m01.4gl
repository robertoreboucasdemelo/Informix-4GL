###########################################################################
# Nome do Modulo: CTC35M01                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de Tipos de Laudo para vistoria                       Dez/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc35m01()
#------------------------------------------------------------

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m01.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc35m01") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc35m01 at 4,2 with form "ctc35m01"

 menu "TIPOS DE LAUDO"

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
                   "Pesquisa tipo de laudo conforme criterios"
          call ctc35m01_seleciona()  returning d_ctc35m01.*
          if d_ctc35m01.socvstlautipcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum tipo de laudo selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo tipo de laudo selecionado"
          message ""
          call ctc35m01_proximo(d_ctc35m01.socvstlautipcod)
               returning d_ctc35m01.*

 command key ("A") "Anterior"
                   "Mostra tipo de laudo anterior selecionado"
          message ""
          if d_ctc35m01.socvstlautipcod is not null then
             call ctc35m01_anterior(d_ctc35m01.socvstlautipcod)
                  returning d_ctc35m01.*
          else
             error " Nenhum tipo de laudo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica tipo de laudo corrente selecionado"
          message ""
          if d_ctc35m01.socvstlautipcod  is not null then
             call ctc35m01_modifica(d_ctc35m01.socvstlautipcod, d_ctc35m01.*)
                  returning d_ctc35m01.*
             next option "Seleciona"
          else
             error " Nenhum tipo de laudo selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui tipo de laudo"
          message ""
          call ctc35m01_inclui()
          next option "Seleciona"

   command "Remove" "Remove tipo de laudo corrente selecionado"
            message ""
            if d_ctc35m01.socvstlautipcod  is not null   then
               call ctc35m01_remove(d_ctc35m01.*)
                    returning d_ctc35m01.*
               next option "Seleciona"
            else
               error " Nenhum tipo de laudo selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc35m01

 end function  # ctc35m01


#------------------------------------------------------------
 function ctc35m01_seleciona()
#------------------------------------------------------------

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m01.*  to null
 display by name d_ctc35m01.*

 input by name d_ctc35m01.socvstlautipcod

    before field socvstlautipcod
        display by name d_ctc35m01.socvstlautipcod attribute (reverse)

        if d_ctc35m01.socvstlautipcod is null then
           let d_ctc35m01.socvstlautipcod = 0
        end if

    after  field socvstlautipcod
        display by name d_ctc35m01.socvstlautipcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m01.*   to null
    display by name d_ctc35m01.*
    error " Operacao cancelada!"
    clear form
    return d_ctc35m01.*
 end if

 if d_ctc35m01.socvstlautipcod = 0 then
     select min (socvstlautipcod)
       into d_ctc35m01.socvstlautipcod
       from datkvstlautip
      where datkvstlautip.socvstlautipcod > d_ctc35m01.socvstlautipcod
 end if

 call ctc35m01_ler(d_ctc35m01.socvstlautipcod)
      returning d_ctc35m01.*

 if d_ctc35m01.socvstlautipcod  is not null   then
    display by name  d_ctc35m01.*
   else
    error " Tipo de laudo nao cadastrado!"
    initialize d_ctc35m01.*    to null
 end if

 return d_ctc35m01.*

 end function  # ctc35m01_seleciona


#------------------------------------------------------------
 function ctc35m01_proximo(param)
#------------------------------------------------------------

 define param         record
    socvstlautipcod   like datkvstlautip.socvstlautipcod
 end record

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m01.*   to null

 if param.socvstlautipcod  is null   then
    let param.socvstlautipcod = 0
 end if

 select min(datkvstlautip.socvstlautipcod)
   into d_ctc35m01.socvstlautipcod
   from datkvstlautip
  where datkvstlautip.socvstlautipcod  >  param.socvstlautipcod

 if d_ctc35m01.socvstlautipcod  is not null   then

    call ctc35m01_ler(d_ctc35m01.socvstlautipcod)
         returning d_ctc35m01.*

    if d_ctc35m01.socvstlautipcod  is not null   then
       display by name d_ctc35m01.*
    else
       error " Nao ha' tipo de laudo nesta direcao!"
       initialize d_ctc35m01.*    to null
    end if
 else
    error " Nao ha' tipo de laudo nesta direcao!"
    initialize d_ctc35m01.*    to null
 end if

 return d_ctc35m01.*

 end function    # ctc35m01_proximo


#------------------------------------------------------------
 function ctc35m01_anterior(param)
#------------------------------------------------------------

 define param         record
    socvstlautipcod   like datkvstlautip.socvstlautipcod
 end record

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc35m01.*  to null

 if param.socvstlautipcod  is null   then
    let param.socvstlautipcod = 0
 end if

 select max(datkvstlautip.socvstlautipcod)
   into d_ctc35m01.socvstlautipcod
   from datkvstlautip
  where datkvstlautip.socvstlautipcod  <  param.socvstlautipcod

 if d_ctc35m01.socvstlautipcod  is not null   then

    call ctc35m01_ler(d_ctc35m01.socvstlautipcod)
         returning d_ctc35m01.*

    if d_ctc35m01.socvstlautipcod  is not null   then
       display by name  d_ctc35m01.*
    else
       error " Nao ha' tipo de laudo nesta direcao!"
       initialize d_ctc35m01.*    to null
    end if
 else
    error " Nao ha' tipo de laudo nesta direcao!"
    initialize d_ctc35m01.*    to null
 end if

 return d_ctc35m01.*

 end function    # ctc35m01_anterior


#------------------------------------------------------------
 function ctc35m01_modifica(param, d_ctc35m01)
#------------------------------------------------------------

 define param         record
    socvstlautipcod   like datkvstlautip.socvstlautipcod
 end record

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc35m01_input("a", d_ctc35m01.*) returning d_ctc35m01.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m01.*  to null
    display by name d_ctc35m01.*
    error " Operacao cancelada!"
    return d_ctc35m01.*
 end if

 whenever error continue

 let d_ctc35m01.atldat = today

 begin work
    update datkvstlautip set  ( socvstlautipdes,
                                socvstlautipsit,
                                atldat,
                                atlemp,
                                atlmat )
                           =  ( d_ctc35m01.socvstlautipdes,
                                d_ctc35m01.socvstlautipsit,
                                d_ctc35m01.atldat,
                                g_issk.empcod,
                                g_issk.funmat )
           where datkvstlautip.socvstlautipcod  =  d_ctc35m01.socvstlautipcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do tipo de laudo!"
       rollback work
       initialize d_ctc35m01.*   to null
       return d_ctc35m01.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc35m01.*  to null
 display by name d_ctc35m01.*
 message ""
 return d_ctc35m01.*

 end function   #  ctc35m01_modifica


#------------------------------------------------------------
 function ctc35m01_inclui()
#------------------------------------------------------------

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc35m01.*   to null
 display by name d_ctc35m01.*

 call ctc35m01_input("i", d_ctc35m01.*) returning d_ctc35m01.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc35m01.*  to null
    display by name d_ctc35m01.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc35m01.atldat = today
 let d_ctc35m01.caddat = today


 declare c_ctc35m01m  cursor with hold  for
         select  max(socvstlautipcod)
           from  datkvstlautip
          where  datkvstlautip.socvstlautipcod > 0

 foreach c_ctc35m01m  into  d_ctc35m01.socvstlautipcod
     exit foreach
 end foreach

 if d_ctc35m01.socvstlautipcod is null   then
    let d_ctc35m01.socvstlautipcod = 0
 end if
 let d_ctc35m01.socvstlautipcod = d_ctc35m01.socvstlautipcod + 1


 whenever error continue

 begin work
    insert into datkvstlautip ( socvstlautipcod,
                                socvstlautipdes,
                                socvstlautipsit,
                                caddat,
                                cademp,
                                cadmat,
                                atldat,
                                atlemp,
                                atlmat )
                     values
                              ( d_ctc35m01.socvstlautipcod,
                                d_ctc35m01.socvstlautipdes,
                                d_ctc35m01.socvstlautipsit,
                                d_ctc35m01.caddat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc35m01.atldat,
                                g_issk.empcod,
                                g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do tipo de laudo!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc35m01_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m01.cadfunnom

 call ctc35m01_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc35m01.funnom

 display by name  d_ctc35m01.*

 display by name d_ctc35m01.socvstlautipcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc35m01.*  to null
 display by name d_ctc35m01.*

 end function   #  ctc35m01_inclui


#--------------------------------------------------------------------
 function ctc35m01_input(param, d_ctc35m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc35m01.socvstlautipdes,
               d_ctc35m01.socvstlautipsit  without defaults

    before field socvstlautipdes
           display by name d_ctc35m01.socvstlautipdes attribute (reverse)

    after  field socvstlautipdes
           display by name d_ctc35m01.socvstlautipdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socvstlautipdes
           end if

           if d_ctc35m01.socvstlautipdes  is null   then
              error " Descricao do tipo de laudo deve ser informado!"
              next field socvstlautipdes
           end if

    before field socvstlautipsit
           if param.operacao  =  "i"   then
              let d_ctc35m01.socvstlautipsit = "A"
           end if
           display by name d_ctc35m01.socvstlautipsit attribute (reverse)

    after  field socvstlautipsit
           display by name d_ctc35m01.socvstlautipsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstlautipdes
           end if

           if d_ctc35m01.socvstlautipsit  is null   or
             (d_ctc35m01.socvstlautipsit  <> "A"    and
              d_ctc35m01.socvstlautipsit  <> "C")   then
              error " Situacao do tipo de laudo deve ser: (A)tivo ou (C)ancelado!"
              next field socvstlautipsit
           end if

           if param.operacao        = "i"   and
              d_ctc35m01.socvstlautipsit  = "C"   then
              error " Nao deve ser incluido tipo de laudo com situacao (C)ancelado!"
              next field socvstlautipsit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc35m01.*  to null
 end if

 return d_ctc35m01.*

 end function   # ctc35m01_input


#--------------------------------------------------------------------
 function ctc35m01_remove(d_ctc35m01)
#--------------------------------------------------------------------

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
     count            integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o laudo"
            clear form
            initialize d_ctc35m01.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui tipo de laudo"
            call ctc35m01_ler(d_ctc35m01.socvstlautipcod) returning d_ctc35m01.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc35m01.* to null
               error " Tipo de laudo nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datmsocvst
                where datmsocvst.socvstlautipcod = d_ctc35m01.socvstlautipcod

                if ws.count  > 0 then
                   error " Tipo de laudo possui vistoria(s), portanto nao deve ser removido!"
                   exit menu
                end if

               begin work
                  delete from datkvstlautip
                   where datkvstlautip.socvstlautipcod = d_ctc35m01.socvstlautipcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc35m01.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do tipo de laudo!"
               else
                  initialize d_ctc35m01.* to null
                  error   " Tipo de laudo excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc35m01.*

end function    # ctc35m01_remove


#---------------------------------------------------------
 function ctc35m01_ler(param)
#---------------------------------------------------------

 define param         record
    socvstlautipcod   like datkvstlautip.socvstlautipcod
 end record

 define d_ctc35m01    record
    socvstlautipcod   like datkvstlautip.socvstlautipcod,
    socvstlautipdes   like datkvstlautip.socvstlautipdes,
    socvstlautipsit   like datkvstlautip.socvstlautipsit,
    caddat            like datkvstlautip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvstlautip.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc35m01.*   to null
 initialize ws.*           to null

 select  socvstlautipcod,
         socvstlautipdes,
         socvstlautipsit,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc35m01.socvstlautipcod,
         d_ctc35m01.socvstlautipdes,
         d_ctc35m01.socvstlautipsit,
         d_ctc35m01.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc35m01.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvstlautip
  where  datkvstlautip.socvstlautipcod = param.socvstlautipcod

 if sqlca.sqlcode = notfound   then
    error " Tipo de laudo nao cadastrado!"
    initialize d_ctc35m01.*    to null
    return d_ctc35m01.*
 else
    call ctc35m01_func(ws.cademp, ws.cadmat)
         returning d_ctc35m01.cadfunnom

    call ctc35m01_func(ws.atlemp, ws.atlmat)
         returning d_ctc35m01.funnom
 end if

 return d_ctc35m01.*

 end function   # ctc35m01_ler


#---------------------------------------------------------
 function ctc35m01_func(param)
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

 end function   # ctc35m01_func
