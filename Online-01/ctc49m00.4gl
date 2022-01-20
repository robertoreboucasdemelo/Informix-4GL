###########################################################################
# Nome do Modulo: ctc49m00                                           RAJI #
#                                                                         #
# Cadastro de codigos de Agrupamento de Prolemas                 Nov/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glcte.4gl"

#------------------------------------------------------------
 function ctc49m00()
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 #if not get_niv_mod(g_issk.prgsgl, "ctc49m00") then
 #   error "Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize ctc49m00.*  to null

 open window ctc49m00 at 04,02 with form "ctc49m00"


 menu "GRP.PROBLEMAS"

  before menu
          hide option all
          show option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Inclui"
          end if
          show option "Encerra"

  command key ("S") "Seleciona"
                   "Pesquisa grupo de problema conforme criterios"
          call ctc49m00_seleciona()  returning param.*
          if param.c24pbmgrpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum grupo de problema selecionado!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                   "Mostra proximo grupo de problema selecionado"
          message ""
          call ctc49m00_proximo(param.*)
               returning param.*

  command key ("A") "Anterior"
                   "Mostra grupo de problema anterior selecionado"
          message ""
          if param.c24pbmgrpcod    is not null then
             call ctc49m00_anterior(param.c24pbmgrpcod   )
                  returning param.*
          else
             error " Nenhum grupo de problema nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                   "Modifica grupo de problema corrente selecionado"
          message ""
          if param.c24pbmgrpcod     is not null then
             call ctc49m00_modifica(param.*)
                  returning param.*
             next option "Seleciona"
          else
             error " Nenhum grupo de problema selecionado!"
             next option "Seleciona"
          end if

  command key ("I") "Inclui"
                   "Inclui grupo de problema"
          message ""
          call ctc49m00_inclui()
          next option "Seleciona"

  command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc49m00

 end function  # ctc49m00


#------------------------------------------------------------
 function ctc49m00_seleciona()
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 define ws_atdsrvorg like datksrvtip.atdsrvorg


 let int_flag = false
 initialize ctc49m00.*  to null
 initialize param.*     to null
 display by name ctc49m00.c24pbmgrpcod
 display by name ctc49m00.c24pbmgrpdes
 display by name ctc49m00.atdsrvorg
 display by name ctc49m00.srvtipabvdes
 display by name ctc49m00.c24pbmgrpstt
 display by name ctc49m00.c24pbmgrpsttdes
 display by name ctc49m00.caddat
 display by name ctc49m00.cadfunnom
 display by name ctc49m00.atldat
 display by name ctc49m00.funnom

 input by name ctc49m00.c24pbmgrpcod

    before field c24pbmgrpcod
        display by name ctc49m00.c24pbmgrpcod attribute (reverse)

    after  field c24pbmgrpcod
        display by name ctc49m00.c24pbmgrpcod

        if ctc49m00.c24pbmgrpcod  is null  or
           ctc49m00.c24pbmgrpcod  =  0     then
           #call cto00m03() returning ctc49m00.atdsrvorg,
           #                          ctc49m00.srvtipabvdes
           if ctc49m00.atdsrvorg  is null  then
              error " Codigo do grupo de problema deve ser informado!"
              next field c24pbmgrpcod
           else
               #call cto00m04(ctc49m00.atdsrvorg,"")
               #                returning ctc49m00.c24pbmgrpcod,
               #                          ctc49m00.c24pbmgrpdes
               if ctc49m00.c24pbmgrpcod is null  then
                  error " Codigo do grupo de problema deve ser informado!"
                  next field c24pbmgrpcod
               end if
           end if
        end if
        display by name ctc49m00.c24pbmgrpcod
        display by name ctc49m00.c24pbmgrpdes

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc49m00.*   to null
    display by name ctc49m00.c24pbmgrpcod
    display by name ctc49m00.c24pbmgrpdes
    display by name ctc49m00.atdsrvorg
    display by name ctc49m00.srvtipabvdes
    display by name ctc49m00.c24pbmgrpstt
    display by name ctc49m00.c24pbmgrpsttdes
    display by name ctc49m00.caddat
    display by name ctc49m00.cadfunnom
    display by name ctc49m00.atldat
    display by name ctc49m00.funnom
    error " Operacao cancelada!"
    return param.*
 end if

 call ctc49m00_ler(ctc49m00.c24pbmgrpcod)
      returning ctc49m00.*

 if ctc49m00.c24pbmgrpcod  is not null   then
    display by name ctc49m00.c24pbmgrpcod
    display by name ctc49m00.c24pbmgrpdes
    display by name ctc49m00.atdsrvorg
    display by name ctc49m00.srvtipabvdes
    display by name ctc49m00.c24pbmgrpstt
    display by name ctc49m00.c24pbmgrpsttdes
    display by name ctc49m00.caddat
    display by name ctc49m00.cadfunnom
    display by name ctc49m00.atldat
    display by name ctc49m00.funnom
 else
    error " grupo de problema nao cadastrado!"
    initialize ctc49m00.*    to null
 end if

 let param.c24pbmgrpcod = ctc49m00.c24pbmgrpcod
 return param.*

 end function  # ctc49m00_seleciona


#------------------------------------------------------------
 function ctc49m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize ctc49m00.*   to null

#if param.c24pbmgrpcod  is null  then
#   let param.c24pbmgrpcod = 0
#end if

 select min(datkpbmgrp.c24pbmgrpcod)
   into ctc49m00.c24pbmgrpcod
   from datkpbmgrp
  where datkpbmgrp.c24pbmgrpcod > param.c24pbmgrpcod

 if ctc49m00.c24pbmgrpcod  is not null   then
    let param.c24pbmgrpcod = ctc49m00.c24pbmgrpcod
    call ctc49m00_ler(ctc49m00.c24pbmgrpcod)
         returning ctc49m00.*

    if ctc49m00.c24pbmgrpcod  is not null   then
       display by name ctc49m00.c24pbmgrpcod
       display by name ctc49m00.c24pbmgrpdes
       display by name ctc49m00.atdsrvorg
       display by name ctc49m00.srvtipabvdes
       display by name ctc49m00.c24pbmgrpstt
       display by name ctc49m00.c24pbmgrpsttdes
       display by name ctc49m00.caddat
       display by name ctc49m00.cadfunnom
       display by name ctc49m00.atldat
       display by name ctc49m00.funnom
    else
       error " Nao ha' grupo de problema nesta direcao!"
     # initialize ctc49m00.*    to null
    end if
 else
    error " Nao ha' grupo de problema nesta direcao!"
#   initialize ctc49m00.*    to null
 end if

 return param.*

 end function    # ctc49m00_proximo


#------------------------------------------------------------
 function ctc49m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize ctc49m00.*  to null

#if param.c24pbmgrpcod  is null  then
#   let param.c24pbmgrpcod = 0
#end if

 select max(datkpbmgrp.c24pbmgrpcod)
   into ctc49m00.c24pbmgrpcod
   from datkpbmgrp
  where datkpbmgrp.c24pbmgrpcod     < param.c24pbmgrpcod

 if ctc49m00.c24pbmgrpcod  is not null   then
    let param.c24pbmgrpcod = ctc49m00.c24pbmgrpcod
    call ctc49m00_ler(ctc49m00.c24pbmgrpcod)
         returning ctc49m00.*

    if ctc49m00.c24pbmgrpcod  is not null   then
       display by name ctc49m00.c24pbmgrpcod
       display by name ctc49m00.c24pbmgrpdes
       display by name ctc49m00.atdsrvorg
       display by name ctc49m00.srvtipabvdes
       display by name ctc49m00.c24pbmgrpstt
       display by name ctc49m00.c24pbmgrpsttdes
       display by name ctc49m00.caddat
       display by name ctc49m00.cadfunnom
       display by name ctc49m00.atldat
       display by name ctc49m00.funnom
    else
       error " Nao ha' grupo de problema nesta direcao!"
#      initialize ctc49m00.*    to null
    end if
 else
    error " Nao ha' grupo de problema nesta direcao!"
#   initialize ctc49m00.*    to null
 end if

 return param.*

 end function    # ctc49m00_anterior


#------------------------------------------------------------
 function ctc49m00_modifica(param)
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 call ctc49m00_ler(param.c24pbmgrpcod)
      returning ctc49m00.*
 if ctc49m00.c24pbmgrpcod is null then
    error " Registro nao localizado "
    return param.*
 end if

 call ctc49m00_input("a", param.*,ctc49m00.*)
                returning param.*, ctc49m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc49m00.*  to null
    display by name ctc49m00.c24pbmgrpcod
    display by name ctc49m00.c24pbmgrpdes
    display by name ctc49m00.atdsrvorg
    display by name ctc49m00.srvtipabvdes
    display by name ctc49m00.c24pbmgrpstt
    display by name ctc49m00.c24pbmgrpsttdes
    display by name ctc49m00.caddat
    display by name ctc49m00.cadfunnom
    display by name ctc49m00.atldat
    display by name ctc49m00.funnom
    error " Operacao cancelada!"
    return param.*
 end if

 whenever error continue

 let ctc49m00.atldat = today

 begin work
    update datkpbmgrp     set  ( c24pbmgrpdes,
                              atdsrvorg,
                              c24pbmgrpstt,
                              atldat,
                              atlmat,
                              atlemp,
                              atlusrtip )
                        =   ( ctc49m00.c24pbmgrpdes,
                              ctc49m00.atdsrvorg,
                              ctc49m00.c24pbmgrpstt,
                              ctc49m00.atldat,
                              ctc49m00.atlmat,
                              ctc49m00.atlemp,
                              ctc49m00.atlusrtip )
           where datkpbmgrp.c24pbmgrpcod  =  param.c24pbmgrpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do grupo de problema!"
       rollback work
       initialize ctc49m00.*   to null
       initialize param.*      to null
       return param.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize ctc49m00.*  to null
 display by name ctc49m00.c24pbmgrpcod
 display by name ctc49m00.c24pbmgrpdes
 display by name ctc49m00.atdsrvorg
 display by name ctc49m00.srvtipabvdes
 display by name ctc49m00.c24pbmgrpstt
 display by name ctc49m00.c24pbmgrpsttdes
 display by name ctc49m00.caddat
 display by name ctc49m00.cadfunnom
 display by name ctc49m00.atldat
 display by name ctc49m00.funnom
 message ""
 return param.*

 end function   #  ctc49m00_modifica


#------------------------------------------------------------
 function ctc49m00_inclui()
#------------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)

 initialize ctc49m00.*, param.*   to null

 display by name ctc49m00.c24pbmgrpcod
 display by name ctc49m00.c24pbmgrpdes
 display by name ctc49m00.atdsrvorg
 display by name ctc49m00.srvtipabvdes
 display by name ctc49m00.c24pbmgrpstt
 display by name ctc49m00.c24pbmgrpsttdes
 display by name ctc49m00.caddat
 display by name ctc49m00.cadfunnom
 display by name ctc49m00.atldat
 display by name ctc49m00.funnom

 call ctc49m00_input("i", param.*, ctc49m00.*)
                 returning param.*, ctc49m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc49m00.*  to null
    display by name ctc49m00.c24pbmgrpcod
    display by name ctc49m00.c24pbmgrpdes
    display by name ctc49m00.atdsrvorg
    display by name ctc49m00.srvtipabvdes
    display by name ctc49m00.c24pbmgrpstt
    display by name ctc49m00.c24pbmgrpsttdes
    display by name ctc49m00.caddat
    display by name ctc49m00.cadfunnom
    display by name ctc49m00.atldat
    display by name ctc49m00.funnom
    error " Operacao cancelada!"
    return
 end if

 let ctc49m00.atldat = today
 let ctc49m00.caddat = today


 whenever error continue

 begin work
    insert into datkpbmgrp   ( c24pbmgrpcod,
                              c24pbmgrpdes,
                              atdsrvorg,
                              c24pbmgrpstt,
                              caddat,
                              cademp,
                              cadmat,
                              cadusrtip,
                              atldat,
                              atlemp,
                              atlmat,
                              atlusrtip )
                  values
                            ( ctc49m00.c24pbmgrpcod,
                              ctc49m00.c24pbmgrpdes,
                              ctc49m00.atdsrvorg,
                              ctc49m00.c24pbmgrpstt,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              g_issk.usrtip,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              g_issk.usrtip)

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do grupo de problema!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc49m00_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc49m00.cadfunnom

 call ctc49m00_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc49m00.funnom

 display by name ctc49m00.c24pbmgrpcod
 display by name ctc49m00.c24pbmgrpdes
 display by name ctc49m00.atdsrvorg
 display by name ctc49m00.srvtipabvdes
 display by name ctc49m00.c24pbmgrpstt
 display by name ctc49m00.c24pbmgrpsttdes
 display by name ctc49m00.caddat
 display by name ctc49m00.cadfunnom
 display by name ctc49m00.atldat
 display by name ctc49m00.funnom

 display by name ctc49m00.c24pbmgrpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc49m00.*  to null
 display by name ctc49m00.c24pbmgrpcod
 display by name ctc49m00.c24pbmgrpdes
 display by name ctc49m00.atdsrvorg
 display by name ctc49m00.srvtipabvdes
 display by name ctc49m00.c24pbmgrpstt
 display by name ctc49m00.c24pbmgrpsttdes
 display by name ctc49m00.caddat
 display by name ctc49m00.cadfunnom
 display by name ctc49m00.atldat
 display by name ctc49m00.funnom

 end function   #  ctc49m00_inclui


#--------------------------------------------------------------------
 function ctc49m00_input(ws_operacao,param,ctc49m00)
#--------------------------------------------------------------------

 define ws_operacao   char (1)

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    cont              integer
 end record


 let int_flag = false
 let ws.cont  = 0

 if ws_operacao   = "i"  then
    select max(c24pbmgrpcod)
         into ws.cont
         from datkpbmgrp
    if  ws.cont  is null then
        let ws.cont =  1
    else
        let ws.cont = ws.cont + 1
    end if
 end if

 input by name
               ctc49m00.c24pbmgrpcod,
               ctc49m00.c24pbmgrpdes,
               ctc49m00.atdsrvorg,
               ctc49m00.c24pbmgrpstt  without defaults

    before field c24pbmgrpcod
            if ws_operacao  =  "a"   then
               next field  c24pbmgrpdes
            end if
            let ctc49m00.c24pbmgrpcod = ws.cont
            display by name ctc49m00.c24pbmgrpcod # attribute (reverse)
            next field  c24pbmgrpdes

    after  field c24pbmgrpcod
           display by name ctc49m00.c24pbmgrpcod

           if ctc49m00.c24pbmgrpcod  is null   then
              error " Codigo do grupo de problema deve ser informado!"
              next field c24pbmgrpcod
           end if

           select c24pbmgrpcod
             from datkpbmgrp
            where c24pbmgrpcod = ctc49m00.c24pbmgrpcod

           if sqlca.sqlcode  =  0   then
              error " Codigo de grupo de problema ja' cadastrado!"
              next field c24pbmgrpcod
           end if

    before field c24pbmgrpdes
           display by name ctc49m00.c24pbmgrpdes #attribute (reverse)

    after  field c24pbmgrpdes
           display by name ctc49m00.c24pbmgrpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ws_operacao  =  "i"   then
                 next field  c24pbmgrpcod
              else
                 next field  c24pbmgrpdes
              end if
           end if

           if ctc49m00.c24pbmgrpdes  is null   then
              error " Descricao do grupo de problema deve ser informado!"
              next field c24pbmgrpdes
           end if

       before field atdsrvorg
          display by name ctc49m00.atdsrvorg # attribute(reverse)

       after  field atdsrvorg
          display by name ctc49m00.atdsrvorg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24pbmgrpdes
          end if
          if ctc49m00.atdsrvorg is null  then
             error " Codigo da Origem do Servico deve ser informado!"
             next field atdsrvorg
          end if
          select srvtipabvdes
                into ctc49m00.srvtipabvdes
                from datksrvtip
                where atdsrvorg = ctc49m00.atdsrvorg

          if sqlca.sqlcode = notfound then
             error " Codigo da Origem do Servico nao cadastrado"
             next field atdsrvorg
          end if

          if ctc49m00.atdsrvorg <> 1  and
             ctc49m00.atdsrvorg <> 6  and
             ctc49m00.atdsrvorg <> 9  and
             ctc49m00.atdsrvorg <> 13 then
             error " Codigo da Origem do Servico nao disponivel para cadastro"
             next field atdsrvorg
          end if

          display by name ctc49m00.atdsrvorg
          display by name ctc49m00.srvtipabvdes

       after  field c24pbmgrpstt
          display by name ctc49m00.c24pbmgrpstt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24pbmgrpstt
          end if
          if ctc49m00.c24pbmgrpcod is null   then
             error " Situacao do problema deve ser informado!"
             next field c24pbmgrpstt
          end if
          if ctc49m00.c24pbmgrpstt <> 'C' and
             ctc49m00.c24pbmgrpstt <> 'A' then
             error " Informe (A/C) para situacao do problema!"
             next field c24pbmgrpstt
          end if

          if ctc49m00.c24pbmgrpstt = 'C' then
             let ctc49m00.c24pbmgrpsttdes = 'Cancelado'
          else
             let ctc49m00.c24pbmgrpsttdes = 'Ativo'
          end if

          display by name ctc49m00.c24pbmgrpstt
          display by name ctc49m00.c24pbmgrpsttdes

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize param.*, ctc49m00.*  to null
 end if

 return param.*, ctc49m00.*

 end function   # ctc49m00_input


#---------------------------------------------------------
 function ctc49m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24pbmgrpcod         like datkpbmgrp.c24pbmgrpcod
 end record

 define ctc49m00      record
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    c24pbmgrpstt      like datkpbmgrp.c24pbmgrpstt,
    c24pbmgrpsttdes   char(15),
    caddat            like datkpbmgrp.caddat,
    cadmat            like datkpbmgrp.cadmat,
    cademp            like datkpbmgrp.cademp,
    cadusrtip         like datkpbmgrp.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbmgrp.atldat,
    atlmat            like datkpbmgrp.atlmat,
    atlemp            smallint, #like datkpbmgrp.atlemp,
    atlusrtip         like datkpbmgrp.atlusrtip,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat,
    atdsrvorg      like datkpbmgrp.atdsrvorg
 end record

 initialize ctc49m00.*   to null
 initialize ws.*         to null

 select  c24pbmgrpcod,
         c24pbmgrpdes,
         atdsrvorg,
         c24pbmgrpstt,
         caddat,
         cadmat,
         cademp,
         cadusrtip,
         atldat ,
         atlmat,
         atlemp,
         atlusrtip
   into  ctc49m00.c24pbmgrpcod,
         ctc49m00.c24pbmgrpdes,
         ctc49m00.atdsrvorg,
         ctc49m00.c24pbmgrpstt,
         ctc49m00.caddat,
         ctc49m00.cadmat,
         ctc49m00.cademp,
         ctc49m00.cadusrtip,
         ctc49m00.atldat,
         ctc49m00.atlmat,
         ctc49m00.atlemp,
         ctc49m00.atlusrtip
   from  datkpbmgrp
 where  c24pbmgrpcod = param.c24pbmgrpcod

 if sqlca.sqlcode = notfound   then
    error " Codigo de grupo de problema nao cadastrado!"
    initialize ctc49m00.*    to null
    return ctc49m00.*
 else
    call ctc49m00_func(ctc49m00.cadmat,
                       ctc49m00.cademp,
                       ctc49m00.cadusrtip)
         returning ctc49m00.cadfunnom

    call ctc49m00_func(ctc49m00.atlmat,
                       ctc49m00.atlemp,
                       ctc49m00.atlusrtip)
         returning ctc49m00.funnom

    select srvtipabvdes
        into ctc49m00.srvtipabvdes
        from datksrvtip
        where atdsrvorg = ctc49m00.atdsrvorg

    if ctc49m00.c24pbmgrpstt = 'C' then
       let ctc49m00.c24pbmgrpsttdes = 'Cancelado'
    else
       let ctc49m00.c24pbmgrpsttdes = 'Ativo'
    end if
 end if

 return ctc49m00.*

 end function   # ctc49m00_ler


#---------------------------------------------------------
 function ctc49m00_func(param)
#---------------------------------------------------------

   define param         record
      funmat            like isskfunc.funmat,
      empcod            like isskfunc.empcod,
      usrtip            like isskfunc.usrtip
   end record

   define ws            record
      funnom            like isskfunc.funnom
   end record

   initialize ws.*    to null

   select funnom
     into ws.funnom
     from isskfunc
    where isskfunc.funmat = param.funmat
      and isskfunc.empcod = param.empcod
      and isskfunc.usrtip = param.usrtip

   return ws.funnom

 end function   # ctc49m00_func
