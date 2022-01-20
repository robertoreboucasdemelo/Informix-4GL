###########################################################################
# Nome do Modulo: ctc34m07                                        Marcelo #
#                                                                Gilberto #
# Cadastro de grupos de distribuicao (posicao da frota)          Ago/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc34m07()
#------------------------------------------------------------

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m07.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc34m07") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m07 at 4,2 with form "ctc34m07"

 menu "DISTRIBUICAO"

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
                   "Pesquisa grupo de distribuicao conforme criterios"
          call ctc34m07_seleciona()  returning d_ctc34m07.*
          if d_ctc34m07.vcldtbgrpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum grupo de distribuicao selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo grupo de distribuicao selecionado"
          message ""
          call ctc34m07_proximo(d_ctc34m07.vcldtbgrpcod)
               returning d_ctc34m07.*

 command key ("A") "Anterior"
                   "Mostra grupo de distribuicao anterior selecionado"
          message ""
          if d_ctc34m07.vcldtbgrpcod is not null then
             call ctc34m07_anterior(d_ctc34m07.vcldtbgrpcod)
                  returning d_ctc34m07.*
          else
             error " Nenhum grupo de distribuicao nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica grupo de distribuicao corrente selecionado"
          message ""
          if d_ctc34m07.vcldtbgrpcod  is not null then
             call ctc34m07_modifica(d_ctc34m07.vcldtbgrpcod, d_ctc34m07.*)
                  returning d_ctc34m07.*
             next option "Seleciona"
          else
             error " Nenhum grupo de distribuicao selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui grupo de distribuicao"
          message ""
          call ctc34m07_inclui()
          next option "Seleciona"

   command "Remove" "Remove grupo de distribuicao corrente selecionado"
            message ""
            if d_ctc34m07.vcldtbgrpcod  is not null   then
               call ctc34m07_remove(d_ctc34m07.*)  returning d_ctc34m07.*
               next option "Seleciona"
            else
               error " Nenhum grupo de distribuicao selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc34m07

 end function  # ctc34m07


#------------------------------------------------------------
 function ctc34m07_seleciona()
#------------------------------------------------------------

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m07.*  to null
 display by name d_ctc34m07.*

 input by name d_ctc34m07.vcldtbgrpcod

    before field vcldtbgrpcod
        display by name d_ctc34m07.vcldtbgrpcod attribute (reverse)

    after  field vcldtbgrpcod
        display by name d_ctc34m07.vcldtbgrpcod

        select vcldtbgrpcod
          from datkvcldtbgrp
         where datkvcldtbgrp.vcldtbgrpcod = d_ctc34m07.vcldtbgrpcod

        if sqlca.sqlcode  =  notfound   then
           error " Grupo de distribuicao nao cadastrado!"
           next field vcldtbgrpcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m07.*   to null
    display by name d_ctc34m07.*
    error " Operacao cancelada!"
    return d_ctc34m07.*
 end if

 call ctc34m07_ler(d_ctc34m07.vcldtbgrpcod)
      returning d_ctc34m07.*

 if d_ctc34m07.vcldtbgrpcod  is not null   then
    display by name  d_ctc34m07.*
 else
    error " Grupo de distribuicao nao cadastrado!"
    initialize d_ctc34m07.*    to null
 end if

 return d_ctc34m07.*

 end function  # ctc34m07_seleciona


#------------------------------------------------------------
 function ctc34m07_proximo(param)
#------------------------------------------------------------

 define param         record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m07.*   to null

 if param.vcldtbgrpcod  is null   then
    let param.vcldtbgrpcod = 0
 end if

 select min(datkvcldtbgrp.vcldtbgrpcod)
   into d_ctc34m07.vcldtbgrpcod
   from datkvcldtbgrp
  where datkvcldtbgrp.vcldtbgrpcod  >  param.vcldtbgrpcod

 if d_ctc34m07.vcldtbgrpcod  is not null   then

    call ctc34m07_ler(d_ctc34m07.vcldtbgrpcod)
         returning d_ctc34m07.*

    if d_ctc34m07.vcldtbgrpcod  is not null   then
       display by name d_ctc34m07.*
    else
       error " Nao ha' grupo de distribuicao nesta direcao!"
       initialize d_ctc34m07.*    to null
    end if
 else
    error " Nao ha' grupo de distribuicao nesta direcao!"
    initialize d_ctc34m07.*    to null
 end if

 return d_ctc34m07.*

 end function    # ctc34m07_proximo


#------------------------------------------------------------
 function ctc34m07_anterior(param)
#------------------------------------------------------------

 define param         record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m07.*  to null

 if param.vcldtbgrpcod  is null   then
    let param.vcldtbgrpcod = 0
 end if

 select max(datkvcldtbgrp.vcldtbgrpcod)
   into d_ctc34m07.vcldtbgrpcod
   from datkvcldtbgrp
  where datkvcldtbgrp.vcldtbgrpcod  <  param.vcldtbgrpcod

 if d_ctc34m07.vcldtbgrpcod  is not null   then

    call ctc34m07_ler(d_ctc34m07.vcldtbgrpcod)
         returning d_ctc34m07.*

    if d_ctc34m07.vcldtbgrpcod  is not null   then
       display by name  d_ctc34m07.*
    else
       error " Nao ha' grupo de distribuicao nesta direcao!"
       initialize d_ctc34m07.*    to null
    end if
 else
    error " Nao ha' grupo de distribuicao nesta direcao!"
    initialize d_ctc34m07.*    to null
 end if

 return d_ctc34m07.*

 end function    # ctc34m07_anterior


#------------------------------------------------------------
 function ctc34m07_modifica(param, d_ctc34m07)
#------------------------------------------------------------

 define param         record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc34m07_input("a", d_ctc34m07.*) returning d_ctc34m07.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m07.*  to null
    display by name d_ctc34m07.*
    error " Operacao cancelada!"
    return d_ctc34m07.*
 end if

 whenever error continue

 let d_ctc34m07.atldat = today

 begin work
    update datkvcldtbgrp set  ( vcldtbgrpdes,
                                vcldtbgrpstt,
                                atldat,
                                atlemp,
                                atlmat )
                           =  ( d_ctc34m07.vcldtbgrpdes,
                                d_ctc34m07.vcldtbgrpstt,
                                d_ctc34m07.atldat,
                                g_issk.empcod,
                                g_issk.funmat )
              where datkvcldtbgrp.vcldtbgrpcod  =  d_ctc34m07.vcldtbgrpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do grupo de distribuicao!"
       rollback work
       initialize d_ctc34m07.*   to null
       return d_ctc34m07.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc34m07.*  to null
 display by name d_ctc34m07.*
 message ""
 return d_ctc34m07.*

 end function   #  ctc34m07_modifica


#------------------------------------------------------------
 function ctc34m07_inclui()
#------------------------------------------------------------

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc34m07.*   to null
 display by name d_ctc34m07.*

 call ctc34m07_input("i", d_ctc34m07.*) returning d_ctc34m07.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m07.*  to null
    display by name d_ctc34m07.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc34m07.atldat = today
 let d_ctc34m07.caddat = today


 declare c_ctc34m07m  cursor with hold  for
         select  max(vcldtbgrpcod)
           from  datkvcldtbgrp
          where  datkvcldtbgrp.vcldtbgrpcod > 0

 foreach c_ctc34m07m  into  d_ctc34m07.vcldtbgrpcod
     exit foreach
 end foreach

 if d_ctc34m07.vcldtbgrpcod is null   then
    let d_ctc34m07.vcldtbgrpcod = 0
 end if
 let d_ctc34m07.vcldtbgrpcod = d_ctc34m07.vcldtbgrpcod + 1


 whenever error continue

 begin work
    insert into datkvcldtbgrp ( vcldtbgrpcod,
                                vcldtbgrpdes,
                                vcldtbgrpstt,
                                caddat,
                                cademp,
                                cadmat,
                                atldat,
                                atlemp,
                                atlmat )
                  values
                              ( d_ctc34m07.vcldtbgrpcod,
                                d_ctc34m07.vcldtbgrpdes,
                                d_ctc34m07.vcldtbgrpstt,
                                d_ctc34m07.caddat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc34m07.atldat,
                                g_issk.empcod,
                                g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do grupo de distribuicao!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc34m07_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m07.cadfunnom

 call ctc34m07_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m07.funnom

 display by name  d_ctc34m07.*

 display by name d_ctc34m07.vcldtbgrpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc34m07.*  to null
 display by name d_ctc34m07.*

 end function   #  ctc34m07_inclui


#--------------------------------------------------------------------
 function ctc34m07_input(param, d_ctc34m07)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false

 input by name d_ctc34m07.vcldtbgrpdes,
               d_ctc34m07.vcldtbgrpstt  without defaults

    before field vcldtbgrpdes
           display by name d_ctc34m07.vcldtbgrpdes attribute (reverse)

    after  field vcldtbgrpdes
           display by name d_ctc34m07.vcldtbgrpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vcldtbgrpdes
           end if

           if d_ctc34m07.vcldtbgrpdes  is null   then
              error " Nome do grupo de distribuicao deve ser informado!"
              next field vcldtbgrpdes
           end if

    before field vcldtbgrpstt
           if param.operacao  =  "i"   then
              let d_ctc34m07.vcldtbgrpstt = "A"
           end if
           display by name d_ctc34m07.vcldtbgrpstt attribute (reverse)

    after  field vcldtbgrpstt
           display by name d_ctc34m07.vcldtbgrpstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vcldtbgrpdes
           end if

           if d_ctc34m07.vcldtbgrpstt  is null   or
             (d_ctc34m07.vcldtbgrpstt  <> "A"    and
              d_ctc34m07.vcldtbgrpstt  <> "C")   then
              error " Situacao do grupo de distribuicao deve ser: (A)tivo ou (C)ancelado!"
              next field vcldtbgrpstt
           end if

           if param.operacao        = "i"   and
              d_ctc34m07.vcldtbgrpstt  = "C"   then
              error " Nao deve ser incluido grupo de distribuicao com situacao (C)ancelado!"
              next field vcldtbgrpstt
           end if

           if d_ctc34m07.vcldtbgrpstt  =  "C"   then
              declare c_dattfrotalocal  cursor for
                 select socvclcod
                   from dattfrotalocal
                  where dattfrotalocal.vcldtbgrpcod  =  d_ctc34m07.vcldtbgrpcod

              open  c_dattfrotalocal
              fetch c_dattfrotalocal

              if sqlca.sqlcode  =  0   then
                 error " Existem veiculos cadastrados com este grupo!"
                 next field vcldtbgrpstt
              end if
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc34m07.*  to null
 end if

 return d_ctc34m07.*

 end function   # ctc34m07_input


#--------------------------------------------------------------------
 function ctc34m07_remove(d_ctc34m07)
#--------------------------------------------------------------------

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socvclcod         like datreqpvcl.socvclcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o grupo de distribuicao"
            clear form
            initialize d_ctc34m07.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui grupo de distribuicao"
            call ctc34m07_ler(d_ctc34m07.vcldtbgrpcod) returning d_ctc34m07.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc34m07.* to null
               error " Grupo de distribuicao nao localizado!"
            else

               initialize ws.socvclcod  to null

               select max (dattfrotalocal.socvclcod)
                 into ws.socvclcod
                 from dattfrotalocal
                where dattfrotalocal.vcldtbgrpcod = d_ctc34m07.vcldtbgrpcod

               if ws.socvclcod  is not null   and
                  ws.socvclcod  > 0           then
                  error " Grupo distribuicao possui veiculos cadastrados, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkvcldtbgrp
                   where datkvcldtbgrp.vcldtbgrpcod = d_ctc34m07.vcldtbgrpcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc34m07.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do grupo de distribuicao!"
               else
                  initialize d_ctc34m07.* to null
                  error   " Grupo de distribuicao excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc34m07.*

end function    # ctc34m07_remove


#---------------------------------------------------------
 function ctc34m07_ler(param)
#---------------------------------------------------------

 define param         record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define d_ctc34m07    record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpstt      like datkvcldtbgrp.vcldtbgrpstt,
    caddat            like datkvcldtbgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvcldtbgrp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctc34m07.*   to null
 initialize ws.*           to null

 select  vcldtbgrpcod,
         vcldtbgrpdes,
         vcldtbgrpstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc34m07.vcldtbgrpcod,
         d_ctc34m07.vcldtbgrpdes,
         d_ctc34m07.vcldtbgrpstt,
         d_ctc34m07.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc34m07.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvcldtbgrp
  where  datkvcldtbgrp.vcldtbgrpcod = param.vcldtbgrpcod

 if sqlca.sqlcode = notfound   then
    error " Grupo de distribuicao nao cadastrado!"
    initialize d_ctc34m07.*    to null
    return d_ctc34m07.*
 else
    call ctc34m07_func(ws.cademp, ws.cadmat)
         returning d_ctc34m07.cadfunnom

    call ctc34m07_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m07.funnom
 end if

 return d_ctc34m07.*

 end function   # ctc34m07_ler


#---------------------------------------------------------
 function ctc34m07_func(param)
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

 end function   # ctc34m07_func
