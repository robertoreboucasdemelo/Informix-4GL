###########################################################################
# Nome do Modulo: ctc34m04                                        Marcelo #
#                                                                Gilberto #
# Cadastro de equipamentos para veiculos de assistencia          Ago/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc34m04()
#------------------------------------------------------------

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m04.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc34m04") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m04 at 4,2 with form "ctc34m04"

 menu "EQUIPAMENTOS"

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
                   "Pesquisa equipamento conforme criterios"
          call ctc34m04_seleciona()  returning d_ctc34m04.*
          if d_ctc34m04.soceqpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum equipamento selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo equipamento selecionado"
          message ""
          call ctc34m04_proximo(d_ctc34m04.soceqpcod)
               returning d_ctc34m04.*

 command key ("A") "Anterior"
                   "Mostra equipamento anterior selecionado"
          message ""
          if d_ctc34m04.soceqpcod is not null then
             call ctc34m04_anterior(d_ctc34m04.soceqpcod)
                  returning d_ctc34m04.*
          else
             error " Nenhum equipamento nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica equipamento corrente selecionado"
          message ""
          if d_ctc34m04.soceqpcod  is not null then
             call ctc34m04_modifica(d_ctc34m04.soceqpcod, d_ctc34m04.*)
                  returning d_ctc34m04.*
             next option "Seleciona"
          else
             error " Nenhum equipamento selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui equipamento"
          message ""
          call ctc34m04_inclui()
          next option "Seleciona"

   command "Remove" "Remove equipamento corrente selecionado"
            message ""
            if d_ctc34m04.soceqpcod  is not null   then
               call ctc34m04_remove(d_ctc34m04.*)
                    returning d_ctc34m04.*
               next option "Seleciona"
            else
               error " Nenhum equipamento selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc34m04

 end function  # ctc34m04


#------------------------------------------------------------
 function ctc34m04_seleciona()
#------------------------------------------------------------

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m04.*  to null
 display by name d_ctc34m04.*

 input by name d_ctc34m04.soceqpcod

    before field soceqpcod
        display by name d_ctc34m04.soceqpcod attribute (reverse)

    after  field soceqpcod
        display by name d_ctc34m04.soceqpcod

        select soceqpcod
          from datkvcleqp
         where datkvcleqp.soceqpcod = d_ctc34m04.soceqpcod

        if sqlca.sqlcode  =  notfound   then
           error " Equipamento nao cadastrado!"
           next field soceqpcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m04.*   to null
    display by name d_ctc34m04.*
    error " Operacao cancelada!"
    return d_ctc34m04.*
 end if

 call ctc34m04_ler(d_ctc34m04.soceqpcod)
      returning d_ctc34m04.*

 if d_ctc34m04.soceqpcod  is not null   then
    display by name  d_ctc34m04.*
 else
    error " Equipamento nao cadastrado!"
    initialize d_ctc34m04.*    to null
 end if

 return d_ctc34m04.*

 end function  # ctc34m04_seleciona


#------------------------------------------------------------
 function ctc34m04_proximo(param)
#------------------------------------------------------------

 define param         record
    soceqpcod         like datkvcleqp.soceqpcod
 end record

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m04.*   to null

 if param.soceqpcod  is null   then
    let param.soceqpcod = 0
 end if

 select min(datkvcleqp.soceqpcod)
   into d_ctc34m04.soceqpcod
   from datkvcleqp
  where datkvcleqp.soceqpcod  >  param.soceqpcod

 if d_ctc34m04.soceqpcod  is not null   then

    call ctc34m04_ler(d_ctc34m04.soceqpcod)
         returning d_ctc34m04.*

    if d_ctc34m04.soceqpcod  is not null   then
       display by name d_ctc34m04.*
    else
       error " Nao ha' equipamento nesta direcao!"
       initialize d_ctc34m04.*    to null
    end if
 else
    error " Nao ha' equipamento nesta direcao!"
    initialize d_ctc34m04.*    to null
 end if

 return d_ctc34m04.*

 end function    # ctc34m04_proximo


#------------------------------------------------------------
 function ctc34m04_anterior(param)
#------------------------------------------------------------

 define param         record
    soceqpcod         like datkvcleqp.soceqpcod
 end record

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m04.*  to null

 if param.soceqpcod  is null   then
    let param.soceqpcod = 0
 end if

 select max(datkvcleqp.soceqpcod)
   into d_ctc34m04.soceqpcod
   from datkvcleqp
  where datkvcleqp.soceqpcod  <  param.soceqpcod

 if d_ctc34m04.soceqpcod  is not null   then

    call ctc34m04_ler(d_ctc34m04.soceqpcod)
         returning d_ctc34m04.*

    if d_ctc34m04.soceqpcod  is not null   then
       display by name  d_ctc34m04.*
    else
       error " Nao ha' equipamento nesta direcao!"
       initialize d_ctc34m04.*    to null
    end if
 else
    error " Nao ha' equipamento nesta direcao!"
    initialize d_ctc34m04.*    to null
 end if

 return d_ctc34m04.*

 end function    # ctc34m04_anterior


#------------------------------------------------------------
 function ctc34m04_modifica(param, d_ctc34m04)
#------------------------------------------------------------

 define param         record
    soceqpcod         like datkvcleqp.soceqpcod
 end record

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc34m04_input("a", d_ctc34m04.*) returning d_ctc34m04.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m04.*  to null
    display by name d_ctc34m04.*
    error " Operacao cancelada!"
    return d_ctc34m04.*
 end if

 whenever error continue

 let d_ctc34m04.atldat = today

 begin work
    update datkvcleqp set  ( soceqpdes,
                             soceqpabv,
                             soceqpfabobrflg,
                             soceqpstt,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc34m04.soceqpdes,
                             d_ctc34m04.soceqpabv,
                             d_ctc34m04.soceqpfabobrflg,
                             d_ctc34m04.soceqpstt,
                             d_ctc34m04.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkvcleqp.soceqpcod  =  d_ctc34m04.soceqpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do equipamento!"
       rollback work
       initialize d_ctc34m04.*   to null
       return d_ctc34m04.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc34m04.*  to null
 display by name d_ctc34m04.*
 message ""
 return d_ctc34m04.*

 end function   #  ctc34m04_modifica


#------------------------------------------------------------
 function ctc34m04_inclui()
#------------------------------------------------------------

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc34m04.*   to null
 display by name d_ctc34m04.*

 call ctc34m04_input("i", d_ctc34m04.*) returning d_ctc34m04.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m04.*  to null
    display by name d_ctc34m04.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc34m04.atldat = today
 let d_ctc34m04.caddat = today


 declare c_ctc34m04m  cursor with hold  for
         select  max(soceqpcod)
           from  datkvcleqp
          where  datkvcleqp.soceqpcod > 0

 foreach c_ctc34m04m  into  d_ctc34m04.soceqpcod
     exit foreach
 end foreach

 if d_ctc34m04.soceqpcod is null   then
    let d_ctc34m04.soceqpcod = 0
 end if
 let d_ctc34m04.soceqpcod = d_ctc34m04.soceqpcod + 1


 whenever error continue

 begin work
    insert into datkvcleqp ( soceqpcod,
                             soceqpdes,
                             soceqpabv,
                             soceqpfabobrflg,
                             soceqpstt,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc34m04.soceqpcod,
                             d_ctc34m04.soceqpdes,
                             d_ctc34m04.soceqpabv,
                             d_ctc34m04.soceqpfabobrflg,
                             d_ctc34m04.soceqpstt,
                             d_ctc34m04.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc34m04.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do equipamento!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc34m04_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m04.cadfunnom

 call ctc34m04_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m04.funnom

 display by name  d_ctc34m04.*

 display by name d_ctc34m04.soceqpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc34m04.*  to null
 display by name d_ctc34m04.*

 end function   #  ctc34m04_inclui


#--------------------------------------------------------------------
 function ctc34m04_input(param, d_ctc34m04)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    contpos           dec(2,0),
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    eqpfabstt         like datkeqpfab.eqpfabstt
 end record


 let int_flag = false
 initialize ws.*   to null

 input by name d_ctc34m04.soceqpdes,
               d_ctc34m04.soceqpabv,
               d_ctc34m04.soceqpfabobrflg,
               d_ctc34m04.soceqpstt  without defaults

    before field soceqpdes
           display by name d_ctc34m04.soceqpdes attribute (reverse)

    after  field soceqpdes
           display by name d_ctc34m04.soceqpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  soceqpdes
           end if

           if d_ctc34m04.soceqpdes  is null   then
              error " Descricao do equipamento deve ser informado!"
              next field soceqpdes
           end if

    before field soceqpabv
           display by name d_ctc34m04.soceqpabv attribute (reverse)

    after  field soceqpabv
           display by name d_ctc34m04.soceqpabv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  soceqpdes
           end if

           if d_ctc34m04.soceqpabv  is null   then
              error " Abreviacao p/ descricao do equipamento deve ser informado!"
              next field soceqpabv
           end if

           let ws.contpos = length(d_ctc34m04.soceqpabv)
           if ws.contpos  <  3   then
              error " Abreviacao deve possuir no minimo 3 caracteres!"
              next field soceqpabv
           end if

           initialize ws.soceqpcod  to null
           initialize ws.soceqpdes  to null

           select soceqpcod, soceqpdes
             into ws.soceqpcod, ws.soceqpdes
             from datkvcleqp
            where datkvcleqp.soceqpabv = d_ctc34m04.soceqpabv

           if sqlca.sqlcode  =  0   then
              if param.operacao  =  "i"   then
                 error " Abreviacao ja' cadastrada! --> ",
                       ws.soceqpcod, "-", ws.soceqpdes
                 next field soceqpabv
              else
                 if d_ctc34m04.soceqpcod  <>  ws.soceqpcod   then
                    error " Abreviacao ja' cadastrada! --> ",
                          ws.soceqpcod, "-", ws.soceqpdes
                    next field soceqpabv
                 end if
              end if
           end if

    before field soceqpfabobrflg
           display by name d_ctc34m04.soceqpfabobrflg attribute (reverse)

    after  field soceqpfabobrflg
           display by name d_ctc34m04.soceqpfabobrflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  soceqpabv
           end if

           if d_ctc34m04.soceqpfabobrflg   is null   or
              (d_ctc34m04.soceqpfabobrflg  <> "S"    and
               d_ctc34m04.soceqpfabobrflg  <> "N")   then
              error " Fabricante obrigatorio deve ser: (S)im ou (N)ao!"
              next field soceqpfabobrflg
           end if

    before field soceqpstt
           if param.operacao  =  "i"   then
              let d_ctc34m04.soceqpstt = "A"
           end if
           display by name d_ctc34m04.soceqpstt attribute (reverse)

    after  field soceqpstt
           display by name d_ctc34m04.soceqpstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  soceqpfabobrflg
           end if

           if d_ctc34m04.soceqpstt  is null   or
             (d_ctc34m04.soceqpstt  <> "A"    and
              d_ctc34m04.soceqpstt  <> "C")   then
              error " Situacao do equipamento deve ser: (A)tivo ou (C)ancelado!"
              next field soceqpstt
           end if

           if param.operacao        = "i"   and
              d_ctc34m04.soceqpstt  = "C"   then
              error " Nao deve ser incluido equipamento com situacao (C)ancelado!"
              next field soceqpstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc34m04.*  to null
 end if

 return d_ctc34m04.*

 end function   # ctc34m04_input


#--------------------------------------------------------------------
 function ctc34m04_remove(d_ctc34m04)
#--------------------------------------------------------------------

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socvclcod         like datreqpvcl.socvclcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o equipamento"
            clear form
            initialize d_ctc34m04.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui equipamento"
            call ctc34m04_ler(d_ctc34m04.soceqpcod) returning d_ctc34m04.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc34m04.* to null
               error " Equipamento nao localizado!"
            else

               initialize ws.socvclcod  to null

               select max(datreqpvcl.socvclcod)
                 into ws.socvclcod
                 from datreqpvcl
                where datreqpvcl.soceqpcod = d_ctc34m04.soceqpcod

               if ws.socvclcod  is not null   and
                  ws.socvclcod  > 0           then
                  error " Existe veiculo c/ este equipamento cadastrado, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkvcleqp
                   where datkvcleqp.soceqpcod = d_ctc34m04.soceqpcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc34m04.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do equipamento!"
               else
                  initialize d_ctc34m04.* to null
                  error   " Equipamento excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc34m04.*

end function    # ctc34m04_remove


#---------------------------------------------------------
 function ctc34m04_ler(param)
#---------------------------------------------------------

 define param         record
    soceqpcod         like datkvcleqp.soceqpcod
 end record

 define d_ctc34m04    record
    soceqpcod         like datkvcleqp.soceqpcod,
    soceqpdes         like datkvcleqp.soceqpdes,
    soceqpabv         like datkvcleqp.soceqpabv,
    soceqpfabobrflg   like datkvcleqp.soceqpfabobrflg,
    soceqpstt         like datkvcleqp.soceqpstt,
    caddat            like datkvcleqp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcleqp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc34m04.*   to null
 initialize ws.*           to null

 select  soceqpcod,
         soceqpdes,
         soceqpabv,
         soceqpfabobrflg,
         soceqpstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc34m04.soceqpcod,
         d_ctc34m04.soceqpdes,
         d_ctc34m04.soceqpabv,
         d_ctc34m04.soceqpfabobrflg,
         d_ctc34m04.soceqpstt,
         d_ctc34m04.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc34m04.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvcleqp
  where  datkvcleqp.soceqpcod = param.soceqpcod

 if sqlca.sqlcode = notfound   then
    error " Equipamento nao cadastrado!"
    initialize d_ctc34m04.*    to null
    return d_ctc34m04.*
 else

    call ctc34m04_func(ws.cademp, ws.cadmat)
         returning d_ctc34m04.cadfunnom

    call ctc34m04_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m04.funnom
 end if

 return d_ctc34m04.*

 end function   # ctc34m04_ler


#---------------------------------------------------------
 function ctc34m04_func(param)
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

 end function   # ctc34m04_func
