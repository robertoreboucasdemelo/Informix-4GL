#############################################################################
# Nome do Modulo: CTC16M02                                         Raji     #
#                                                                           #
# Cadastro grupo de naturezas de socorro                           Jul/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/09/2006  PSI 202290   Priscila    Remover verificacao nivel de acesso  #
#############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc16m02()
#------------------------------------------------------------

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define l_socntzcod   like datksocntz.socntzcod,
        l_socntzdes   like datksocntz.socntzdes

 let l_socntzcod = 0
 let l_socntzdes = 0

 let int_flag = false
 initialize ctc16m02.*  to null

 open window ctc16m02 at 04,02 with form "ctc16m02"


 menu "GRUPO_NTZ"

 before menu
      #PSI 202290
      #hide option all
      #if get_niv_mod(g_issk.prgsgl,"ctc16m02")  then
      #   if g_issk.acsnivcod >= g_issk.acsnivcns  then  ### NIVEL 3
            show option "Seleciona", "Proximo", "Anterior"
      #   end if
      #   if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 6
            show option "Modifica", "Inclui"
      #   end if
      #   if g_issk.acsnivcod >= 8                 then  ### NIVEL 8
            show option "Remove", "empXass"
      #   end if
      #end if
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa grupo de natureza conforme criterios"
          call ctc16m02_seleciona()  returning ctc16m02.*
          if ctc16m02.socntzgrpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum grupo de natureza selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo grupo de natureza selecionado"
          message ""
          call ctc16m02_proximo(ctc16m02.socntzgrpcod)
               returning ctc16m02.*

 command key ("A") "Anterior"
                   "Mostra grupo de natureza anterior selecionado"
          message ""
          if ctc16m02.socntzgrpcod is not null then
             call ctc16m02_anterior(ctc16m02.socntzgrpcod)
                  returning ctc16m02.*
          else
             error " Nenhum grupo de natureza nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica grupo de natureza selecionado"
          message ""
          if ctc16m02.socntzgrpcod  is not null then
             call ctc16m02_modifica(ctc16m02.socntzgrpcod, ctc16m02.*)
                  returning ctc16m02.*
             next option "Seleciona"
          else
             error " Nenhum grupo de natureza selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui grupo de natureza"
          message ""
          call ctc16m02_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove grupo de natureza"
          message ""
          if ctc16m02.socntzgrpcod  is not null then
             call ctc16m02_remove(ctc16m02.socntzgrpcod)
             next option "Seleciona"
          else
             error " Nenhum grupo de natureza selecionado!"
             next option "Seleciona"
          end if

 command key ("X") "EmpXass"
                   "GrupoXnaturezas"
          message ""
         call ctc66m00(ctc16m02.socntzgrpcod, ctc16m02.socntzgrpdes)

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc16m02

 end function  ###  ctc16m02

#------------------------------------------------------------
 function ctc16m02_seleciona()
#------------------------------------------------------------

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc16m02.*  to null
 display by name ctc16m02.*

 input by name ctc16m02.socntzgrpcod

    before field socntzgrpcod
        display by name ctc16m02.socntzgrpcod attribute (reverse)

    after  field socntzgrpcod
        display by name ctc16m02.socntzgrpcod

        if ctc16m02.socntzgrpcod is null  then
           select min(socntzgrpcod)
             into ctc16m02.socntzgrpcod
             from datksocntzgrp

           if ctc16m02.socntzgrpcod is null  then
              error " Nao existe nenhum grupo de natureza cadastrado!"
              exit input
           end if
        end if

        select socntzgrpcod
          from datksocntzgrp
         where socntzgrpcod = ctc16m02.socntzgrpcod

        if sqlca.sqlcode = notfound  then
           error " Grupo de natureza nao cadastrado!"
           next field socntzgrpcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc16m02.*   to null
    display by name ctc16m02.*
    error " Operacao cancelada!"
    return ctc16m02.*
 end if

 call ctc16m02_ler(ctc16m02.socntzgrpcod)
      returning ctc16m02.*

 if ctc16m02.socntzgrpcod  is not null   then
    display by name  ctc16m02.*
 else
    error " Grupo de Natureza nao cadastrado!"
    initialize ctc16m02.*    to null
 end if

 return ctc16m02.*

 end function  ###  ctc16m02_seleciona

#------------------------------------------------------------
 function ctc16m02_proximo(param)
#------------------------------------------------------------

 define param         record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod
 end record

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc16m02.*   to null

 if param.socntzgrpcod  is null   then
    let param.socntzgrpcod = " "
 end if

 select min(datksocntzgrp.socntzgrpcod)
   into ctc16m02.socntzgrpcod
   from datksocntzgrp
  where socntzgrpcod  >  param.socntzgrpcod

 if ctc16m02.socntzgrpcod is not null  then

    call ctc16m02_ler(ctc16m02.socntzgrpcod)
         returning ctc16m02.*

    if ctc16m02.socntzgrpcod is not null  then
       display by name ctc16m02.*
    else
       error " Nao ha' nenhum grupo de natureza nesta direcao!"
       initialize ctc16m02.*    to null
    end if
 else
    error " Nao ha' nenhum grupo de natureza nesta direcao!"
    initialize ctc16m02.*    to null
 end if

 return ctc16m02.*

 end function  ###  ctc16m02_proximo

#------------------------------------------------------------
 function ctc16m02_anterior(param)
#------------------------------------------------------------

 define param         record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod
 end record

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc16m02.*  to null

 if param.socntzgrpcod  is null   then
    let param.socntzgrpcod = " "
 end if

 select max(datksocntzgrp.socntzgrpcod)
   into ctc16m02.socntzgrpcod
   from datksocntzgrp
  where socntzgrpcod  <  param.socntzgrpcod

 if ctc16m02.socntzgrpcod  is not null   then
    call ctc16m02_ler(ctc16m02.socntzgrpcod)
         returning ctc16m02.*

    if ctc16m02.socntzgrpcod  is not null   then
       display by name ctc16m02.*
    else
       error " Nao ha' nenhum grupo de natureza nesta direcao!"
       initialize ctc16m02.*    to null
    end if
 else
    error " Nao ha' nenhum grupo de natureza nesta direcao!"
    initialize ctc16m02.*    to null
 end if

 return ctc16m02.*

 end function  ###  ctc16m02_anterior

#------------------------------------------------------------
 function ctc16m02_modifica(param, ctc16m02)
#------------------------------------------------------------

 define param         record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod
 end record

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 call ctc16m02_input("a", ctc16m02.*) returning ctc16m02.*

 if int_flag  then
    let int_flag = false
    initialize ctc16m02.*  to null
    display by name ctc16m02.*
    error " Operacao cancelada!"
    return ctc16m02.*
 end if

 whenever error continue

 let ctc16m02.atldat = today

 update datksocntzgrp set  ( socntzgrpdes,
                          atldat,
                          atlemp,
                          atlusrtip,
                          atlmat )
                     =  ( ctc16m02.socntzgrpdes,
                          ctc16m02.atldat,
                          g_issk.empcod,
                          g_issk.usrtip,
                          g_issk.funmat )
                 where socntzgrpcod  =  ctc16m02.socntzgrpcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do grupo de natureza!"
    initialize ctc16m02.*   to null
    return ctc16m02.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc16m02.*  to null
 display by name ctc16m02.*
 message ""
 return ctc16m02.*

 end function  ###  ctc16m02_modifica

#------------------------------------------------------------
 function ctc16m02_inclui()
#------------------------------------------------------------

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 initialize ctc16m02.*   to null
 display by name ctc16m02.*

 call ctc16m02_input("i", ctc16m02.*) returning ctc16m02.*

 if int_flag  then
    let int_flag = false
    initialize ctc16m02.*  to null
    display by name ctc16m02.*
    error " Operacao cancelada!"
    return
 end if

 let ctc16m02.atldat = today
 let ctc16m02.caddat = today

 whenever error continue

 select max(socntzgrpcod)
   into ctc16m02.socntzgrpcod
   from datksocntzgrp

 if ctc16m02.socntzgrpcod is null  then
    let ctc16m02.socntzgrpcod = 0
 end if

 let ctc16m02.socntzgrpcod = ctc16m02.socntzgrpcod + 1

 insert into datksocntzgrp ( socntzgrpcod,
                          socntzgrpdes,
                          caddat,
                          cademp,
                          cadusrtip,
                          cadmat,
                          atldat,
                          atlemp,
                          atlusrtip,
                          atlmat )
                 values ( ctc16m02.socntzgrpcod,
                          ctc16m02.socntzgrpdes,
                          ctc16m02.caddat,
                          g_issk.empcod,
                          g_issk.usrtip,
                          g_issk.funmat,
                          ctc16m02.atldat,
                          g_issk.empcod,
                          g_issk.usrtip,
                          g_issk.funmat )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do grupo de natureza!"
    return
 end if

 whenever error stop

 call ctc16m02_func(g_issk.empcod, g_issk.usrtip, g_issk.funmat)
      returning ctc16m02.cadfunnom

 call ctc16m02_func(g_issk.empcod, g_issk.usrtip, g_issk.funmat)
      returning ctc16m02.atlfunnom

 display by name ctc16m02.*

 display by name ctc16m02.socntzgrpcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc16m02.*  to null
 display by name ctc16m02.*

 end function  ###  ctc16m02_inclui

#------------------------------------------------------------
 function ctc16m02_remove(param)
#------------------------------------------------------------

 define param         record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do grupo de natureza."
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui grupo de natureza"
       whenever error continue

       delete from datksocntzgrp
        where socntzgrpcod = param.socntzgrpcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao do grupo de natureza!"
       else
          delete from datrsocntzgrpsrvre
           where socntzgrpcod = param.socntzgrpcod

          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc16m02_remove

#--------------------------------------------------------------------
 function ctc16m02_input(param, ctc16m02)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false

 input by name ctc16m02.socntzgrpdes without defaults

    before field socntzgrpdes
           display by name ctc16m02.socntzgrpdes attribute (reverse)

    after  field socntzgrpdes
           display by name ctc16m02.socntzgrpdes

           if ctc16m02.socntzgrpdes is null  then
              error " Descricao da grupo de natureza deve ser informado!"
              next field socntzgrpdes
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc16m02.*  to null
 end if

 return ctc16m02.*

 end function  ###  ctc16m02_input

#---------------------------------------------------------
 function ctc16m02_ler(param)
#---------------------------------------------------------

 define param         record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod
 end record

 define ctc16m02      record
    socntzgrpcod      like datksocntzgrp.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    caddat            like datksocntzgrp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntzgrp.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlusrtip         like isskfunc.usrtip,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadusrtip         like isskfunc.usrtip,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc16m02.*   to null
 initialize ws.*         to null

 select socntzgrpcod,
        socntzgrpdes,
        caddat,
        cademp,
        cadusrtip,
        cadmat,
        atldat,
        atlemp,
        atlusrtip,
        atlmat
   into ctc16m02.socntzgrpcod,
        ctc16m02.socntzgrpdes,
        ctc16m02.caddat,
        ws.cademp,
        ws.cadusrtip,
        ws.cadmat,
        ctc16m02.atldat,
        ws.atlemp,
        ws.atlusrtip,
        ws.atlmat
   from datksocntzgrp
  where socntzgrpcod = param.socntzgrpcod

 if sqlca.sqlcode = notfound  then
    error " Grupo de natureza nao cadastrado!"
    initialize ctc16m02.*    to null
    return ctc16m02.*
 else
    call ctc16m02_func(ws.cademp, ws.cadusrtip, ws.cadmat)
         returning ctc16m02.cadfunnom

    call ctc16m02_func(ws.atlemp, ws.atlusrtip, ws.atlmat)
         returning ctc16m02.atlfunnom
 end if

 return ctc16m02.*

 end function  ###  ctc16m02_ler

#---------------------------------------------------------
 function ctc16m02_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where funmat = param.funmat
    and empcod = param.empcod
    and usrtip = param.usrtip

 return ws.funnom

 end function  ###  ctc16m02_func
