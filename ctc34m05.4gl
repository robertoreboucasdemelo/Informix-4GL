###########################################################################
# Nome do Modulo: ctc34m05                                        Marcelo #
#                                                                Gilberto #
# Cadastro de fabricantes de equipamentos para veiculos          Ago/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc34m05()
#------------------------------------------------------------

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m05.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc34m05") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m05 at 4,2 with form "ctc34m05"

 menu "FABRICANTES"

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
                   "Pesquisa fabricante conforme criterios"
          call ctc34m05_seleciona()  returning d_ctc34m05.*
          if d_ctc34m05.eqpfabcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum fabricante selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo fabricante selecionado"
          message ""
          call ctc34m05_proximo(d_ctc34m05.eqpfabcod)
               returning d_ctc34m05.*

 command key ("A") "Anterior"
                   "Mostra fabricante anterior selecionado"
          message ""
          if d_ctc34m05.eqpfabcod is not null then
             call ctc34m05_anterior(d_ctc34m05.eqpfabcod)
                  returning d_ctc34m05.*
          else
             error " Nenhum fabricante nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica fabricante corrente selecionado"
          message ""
          if d_ctc34m05.eqpfabcod  is not null then
             call ctc34m05_modifica(d_ctc34m05.eqpfabcod, d_ctc34m05.*)
                  returning d_ctc34m05.*
             next option "Seleciona"
          else
             error " Nenhum fabricante selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui fabricante"
          message ""
          call ctc34m05_inclui()
          next option "Seleciona"

   command "Remove" "Remove fabricante corrente selecionado"
            message ""
            if d_ctc34m05.eqpfabcod  is not null   then
               call ctc34m05_remove(d_ctc34m05.*)
                    returning d_ctc34m05.*
               next option "Seleciona"
            else
               error " Nenhum fabricante selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc34m05

 end function  # ctc34m05


#------------------------------------------------------------
 function ctc34m05_seleciona()
#------------------------------------------------------------

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m05.*  to null
 display by name d_ctc34m05.*

 input by name d_ctc34m05.eqpfabcod

    before field eqpfabcod
        display by name d_ctc34m05.eqpfabcod attribute (reverse)

    after  field eqpfabcod
        display by name d_ctc34m05.eqpfabcod

        select eqpfabcod
          from datkeqpfab
         where datkeqpfab.eqpfabcod = d_ctc34m05.eqpfabcod

        if sqlca.sqlcode  =  notfound   then
           error " Fabricante nao cadastrado!"
           next field eqpfabcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m05.*   to null
    display by name d_ctc34m05.*
    error " Operacao cancelada!"
    return d_ctc34m05.*
 end if

 call ctc34m05_ler(d_ctc34m05.eqpfabcod)
      returning d_ctc34m05.*

 if d_ctc34m05.eqpfabcod  is not null   then
    display by name  d_ctc34m05.*
 else
    error " Fabricante nao cadastrado!"
    initialize d_ctc34m05.*    to null
 end if

 return d_ctc34m05.*

 end function  # ctc34m05_seleciona


#------------------------------------------------------------
 function ctc34m05_proximo(param)
#------------------------------------------------------------

 define param         record
    eqpfabcod         like datkeqpfab.eqpfabcod
 end record

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m05.*   to null

 if param.eqpfabcod  is null   then
    let param.eqpfabcod = 0
 end if

 select min(datkeqpfab.eqpfabcod)
   into d_ctc34m05.eqpfabcod
   from datkeqpfab
  where datkeqpfab.eqpfabcod  >  param.eqpfabcod

 if d_ctc34m05.eqpfabcod  is not null   then

    call ctc34m05_ler(d_ctc34m05.eqpfabcod)
         returning d_ctc34m05.*

    if d_ctc34m05.eqpfabcod  is not null   then
       display by name d_ctc34m05.*
    else
       error " Nao ha' fabricante nesta direcao!"
       initialize d_ctc34m05.*    to null
    end if
 else
    error " Nao ha' fabricante nesta direcao!"
    initialize d_ctc34m05.*    to null
 end if

 return d_ctc34m05.*

 end function    # ctc34m05_proximo


#------------------------------------------------------------
 function ctc34m05_anterior(param)
#------------------------------------------------------------

 define param         record
    eqpfabcod         like datkeqpfab.eqpfabcod
 end record

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m05.*  to null

 if param.eqpfabcod  is null   then
    let param.eqpfabcod = 0
 end if

 select max(datkeqpfab.eqpfabcod)
   into d_ctc34m05.eqpfabcod
   from datkeqpfab
  where datkeqpfab.eqpfabcod  <  param.eqpfabcod

 if d_ctc34m05.eqpfabcod  is not null   then

    call ctc34m05_ler(d_ctc34m05.eqpfabcod)
         returning d_ctc34m05.*

    if d_ctc34m05.eqpfabcod  is not null   then
       display by name  d_ctc34m05.*
    else
       error " Nao ha' fabricante nesta direcao!"
       initialize d_ctc34m05.*    to null
    end if
 else
    error " Nao ha' fabricante nesta direcao!"
    initialize d_ctc34m05.*    to null
 end if

 return d_ctc34m05.*

 end function    # ctc34m05_anterior


#------------------------------------------------------------
 function ctc34m05_modifica(param, d_ctc34m05)
#------------------------------------------------------------

 define param         record
    eqpfabcod         like datkeqpfab.eqpfabcod
 end record

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc34m05_input("a", d_ctc34m05.*) returning d_ctc34m05.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m05.*  to null
    display by name d_ctc34m05.*
    error " Operacao cancelada!"
    return d_ctc34m05.*
 end if

 whenever error continue

 let d_ctc34m05.atldat = today

 begin work
    update datkeqpfab set  ( eqpfabnom,
                             eqpfababv,
                             eqpfabstt,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc34m05.eqpfabnom,
                             d_ctc34m05.eqpfababv,
                             d_ctc34m05.eqpfabstt,
                             d_ctc34m05.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkeqpfab.eqpfabcod  =  d_ctc34m05.eqpfabcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do fabricante!"
       rollback work
       initialize d_ctc34m05.*   to null
       return d_ctc34m05.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc34m05.*  to null
 display by name d_ctc34m05.*
 message ""
 return d_ctc34m05.*

 end function   #  ctc34m05_modifica


#------------------------------------------------------------
 function ctc34m05_inclui()
#------------------------------------------------------------

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc34m05.*   to null
 display by name d_ctc34m05.*

 call ctc34m05_input("i", d_ctc34m05.*) returning d_ctc34m05.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m05.*  to null
    display by name d_ctc34m05.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc34m05.atldat = today
 let d_ctc34m05.caddat = today


 declare c_ctc34m05m  cursor with hold  for
         select  max(eqpfabcod)
           from  datkeqpfab
          where  datkeqpfab.eqpfabcod > 0

 foreach c_ctc34m05m  into  d_ctc34m05.eqpfabcod
     exit foreach
 end foreach

 if d_ctc34m05.eqpfabcod is null   then
    let d_ctc34m05.eqpfabcod = 0
 end if
 let d_ctc34m05.eqpfabcod = d_ctc34m05.eqpfabcod + 1


 whenever error continue

 begin work
    insert into datkeqpfab ( eqpfabcod,
                             eqpfabnom,
                             eqpfababv,
                             eqpfabstt,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc34m05.eqpfabcod,
                             d_ctc34m05.eqpfabnom,
                             d_ctc34m05.eqpfababv,
                             d_ctc34m05.eqpfabstt,
                             d_ctc34m05.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc34m05.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do fabricante!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc34m05_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m05.cadfunnom

 call ctc34m05_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m05.funnom

 display by name  d_ctc34m05.*

 display by name d_ctc34m05.eqpfabcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc34m05.*  to null
 display by name d_ctc34m05.*

 end function   #  ctc34m05_inclui


#--------------------------------------------------------------------
 function ctc34m05_input(param, d_ctc34m05)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc34m05.eqpfabnom,
               d_ctc34m05.eqpfababv,
               d_ctc34m05.eqpfabstt  without defaults

    before field eqpfabnom
           display by name d_ctc34m05.eqpfabnom attribute (reverse)

    after  field eqpfabnom
           display by name d_ctc34m05.eqpfabnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  eqpfabnom
           end if

           if d_ctc34m05.eqpfabnom  is null   then
              error " Nome do fabricante deve ser informado!"
              next field eqpfabnom
           end if

    before field eqpfababv
           display by name d_ctc34m05.eqpfababv attribute (reverse)

    after  field eqpfababv
           display by name d_ctc34m05.eqpfababv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  eqpfabnom
           end if

           if d_ctc34m05.eqpfababv  is null   then
              error " Abreviacao p/ nome do fabricante deve ser informado!"
              next field eqpfababv
           end if

           let ws.contpos = length(d_ctc34m05.eqpfababv)
           if ws.contpos  <  3   then
              error " Abreviacao deve possuir no minimo 3 caracteres!"
              next field eqpfababv
           end if

           initialize ws.eqpfabcod  to null
           initialize ws.eqpfabnom  to null

           select eqpfabcod, eqpfabnom
             into ws.eqpfabcod, ws.eqpfabnom
             from datkeqpfab
            where datkeqpfab.eqpfababv = d_ctc34m05.eqpfababv

           if sqlca.sqlcode  =  0   then
              if param.operacao  =  "i"   then
                 error " Abreviacao ja' cadastrada! --> ",
                       ws.eqpfabcod, "-", ws.eqpfabnom
                 next field eqpfababv
              else
                 if d_ctc34m05.eqpfabcod  <>  ws.eqpfabcod   then
                    error " Abreviacao ja' cadastrada! --> ",
                          ws.eqpfabcod, "-", ws.eqpfabnom
                    next field eqpfababv
                 end if
              end if
           end if

    before field eqpfabstt
           if param.operacao  =  "i"   then
              let d_ctc34m05.eqpfabstt = "A"
           end if
           display by name d_ctc34m05.eqpfabstt attribute (reverse)

    after  field eqpfabstt
           display by name d_ctc34m05.eqpfabstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  eqpfababv
           end if

           if d_ctc34m05.eqpfabstt  is null   or
             (d_ctc34m05.eqpfabstt  <> "A"    and
              d_ctc34m05.eqpfabstt  <> "C")   then
              error " Situacao do fabricante deve ser: (A)tivo ou (C)ancelado!"
              next field eqpfabstt
           end if

           if param.operacao        = "i"   and
              d_ctc34m05.eqpfabstt  = "C"   then
              error " Nao deve ser incluido fabricante com situacao (C)ancelado!"
              next field eqpfabstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc34m05.*  to null
 end if

 return d_ctc34m05.*

 end function   # ctc34m05_input


#--------------------------------------------------------------------
 function ctc34m05_remove(d_ctc34m05)
#--------------------------------------------------------------------

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    eqpfabcod         like datkeqpfab.eqpfabcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o fabricante"
            clear form
            initialize d_ctc34m05.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui fabricante"
            call ctc34m05_ler(d_ctc34m05.eqpfabcod) returning d_ctc34m05.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc34m05.* to null
               error " Fabricante nao localizado!"
            else

               initialize ws.eqpfabcod  to null

               select max (datreqpvcl.eqpfabcod)
                 into ws.eqpfabcod
                 from datreqpvcl
                where datreqpvcl.eqpfabcod = d_ctc34m05.eqpfabcod

               if ws.eqpfabcod  is not null   and
                  ws.eqpfabcod  > 0           then
                  error " Fabricante possui equipamentos cadastrados, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkeqpfab
                   where datkeqpfab.eqpfabcod = d_ctc34m05.eqpfabcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc34m05.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do fabricante!"
               else
                  initialize d_ctc34m05.* to null
                  error   " Fabricante excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc34m05.*

end function    # ctc34m05_remove


#---------------------------------------------------------
 function ctc34m05_ler(param)
#---------------------------------------------------------

 define param         record
    eqpfabcod         like datkeqpfab.eqpfabcod
 end record

 define d_ctc34m05    record
    eqpfabcod         like datkeqpfab.eqpfabcod,
    eqpfabnom         like datkeqpfab.eqpfabnom,
    eqpfababv         like datkeqpfab.eqpfababv,
    eqpfabstt         like datkeqpfab.eqpfabstt,
    caddat            like datkeqpfab.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkeqpfab.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc34m05.*   to null
 initialize ws.*           to null

 select  eqpfabcod,
         eqpfabnom,
         eqpfababv,
         eqpfabstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc34m05.eqpfabcod,
         d_ctc34m05.eqpfabnom,
         d_ctc34m05.eqpfababv,
         d_ctc34m05.eqpfabstt,
         d_ctc34m05.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc34m05.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkeqpfab
  where  datkeqpfab.eqpfabcod = param.eqpfabcod

 if sqlca.sqlcode = notfound   then
    error " Fabricante nao cadastrado!"
    initialize d_ctc34m05.*    to null
    return d_ctc34m05.*
 else
    call ctc34m05_func(ws.cademp, ws.cadmat)
         returning d_ctc34m05.cadfunnom

    call ctc34m05_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m05.funnom
 end if

 return d_ctc34m05.*

 end function   # ctc34m05_ler


#---------------------------------------------------------
 function ctc34m05_func(param)
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

 end function   # ctc34m05_func
