###########################################################################
# Nome do Modulo: ctc15m05                                       Marcelo  #
#                                                                Gilberto #
# Cadastro de motivos para assistencia                           Mar/1999 #
###########################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc15m05()
#------------------------------------------------------------

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m05.*  to null

 open window ctc15m05 at 04,02 with form "ctc15m05"


 menu "MOTIVOS"

 before menu
      hide option all
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui"
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa motivo para assistencia conforme criterios"
          call ctc15m05_seleciona()  returning ctc15m05.*
          if ctc15m05.asimtvcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum motivo selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo motivo para assistencia"
          message ""
          call ctc15m05_proximo(ctc15m05.asimtvcod)
               returning ctc15m05.*

 command key ("A") "Anterior"
                   "Mostra motivo para assistencia anterior"
          message ""
          if ctc15m05.asimtvcod is not null then
             call ctc15m05_anterior(ctc15m05.asimtvcod)
                  returning ctc15m05.*
          else
             error " Nao ha' nenhum motivo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica motivo para assistencia selecionado"
          message ""
          if ctc15m05.asimtvcod  is not null then
             call ctc15m05_modifica(ctc15m05.asimtvcod, ctc15m05.*)
                  returning ctc15m05.*
             next option "Seleciona"
          else
             error " Nenhum motivo selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui motivo para assistencia"
          message ""
          call ctc15m05_inclui()
          next option "Seleciona"

#command key ("R") "Remove"
#                  "Remove motivo para assistencia"
#         message ""
#         if ctc15m05.asimtvcod  is not null then
#            call ctc15m05_remove(ctc15m05.asimtvcod)
#            next option "Seleciona"
#         else
#            error " Nenhum motivo selecionado!"
#            next option "Seleciona"
#         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc15m05

 end function  ###  ctc15m05

#------------------------------------------------------------
 function ctc15m05_seleciona()
#------------------------------------------------------------

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m05.*  to null
 display by name ctc15m05.*

 input by name ctc15m05.asimtvcod

    before field asimtvcod
        display by name ctc15m05.asimtvcod attribute (reverse)

    after  field asimtvcod
        display by name ctc15m05.asimtvcod

        if ctc15m05.asimtvcod is null  then
           select min(asimtvcod)
             into ctc15m05.asimtvcod
             from datkasimtv

           if ctc15m05.asimtvcod is null  then
              error " Nao existe nenhum motivo cadastrado!"
              exit input
           end if
        end if

        select asimtvcod
          from datkasimtv
         where asimtvcod = ctc15m05.asimtvcod

        if sqlca.sqlcode = notfound  then
           error " Motivo nao cadastrado!"
           next field asimtvcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc15m05.*   to null
    display by name ctc15m05.*
    error " Operacao cancelada!"
    return ctc15m05.*
 end if

 call ctc15m05_ler(ctc15m05.asimtvcod)
      returning ctc15m05.*

 if ctc15m05.asimtvcod  is not null   then
    display by name  ctc15m05.*
 else
    error " Motivo nao cadastrado!"
    initialize ctc15m05.*    to null
 end if

 return ctc15m05.*

 end function  ###  ctc15m05_seleciona

#------------------------------------------------------------
 function ctc15m05_proximo(param)
#------------------------------------------------------------

 define param         record
    asimtvcod         like datkasimtv.asimtvcod
 end record

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m05.*   to null

 if param.asimtvcod  is null   then
    let param.asimtvcod = " "
 end if

 select min(datkasimtv.asimtvcod)
   into ctc15m05.asimtvcod
   from datkasimtv
  where asimtvcod  >  param.asimtvcod

 if ctc15m05.asimtvcod is not null  then

    call ctc15m05_ler(ctc15m05.asimtvcod)
         returning ctc15m05.*

    if ctc15m05.asimtvcod is not null  then
       display by name ctc15m05.*
    else
       error " Nao ha' nenhum motivo nesta direcao!"
       initialize ctc15m05.*    to null
    end if
 else
    error " Nao ha' nenhum motivo nesta direcao!"
    initialize ctc15m05.*    to null
 end if

 return ctc15m05.*

 end function  ###  ctc15m05_proximo

#------------------------------------------------------------
 function ctc15m05_anterior(param)
#------------------------------------------------------------

 define param         record
    asimtvcod         like datkasimtv.asimtvcod
 end record

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m05.*  to null

 if param.asimtvcod  is null   then
    let param.asimtvcod = " "
 end if

 select max(datkasimtv.asimtvcod)
   into ctc15m05.asimtvcod
   from datkasimtv
  where asimtvcod  <  param.asimtvcod

 if ctc15m05.asimtvcod  is not null   then
    call ctc15m05_ler(ctc15m05.asimtvcod)
         returning ctc15m05.*

    if ctc15m05.asimtvcod  is not null   then
       display by name ctc15m05.*
    else
       error " Nao ha' nenhum motivo nesta direcao!"
       initialize ctc15m05.*    to null
    end if
 else
    error " Nao ha' nenhum motivo nesta direcao!"
    initialize ctc15m05.*    to null
 end if

 return ctc15m05.*

 end function  ###  ctc15m05_anterior

#------------------------------------------------------------
 function ctc15m05_modifica(param, ctc15m05)
#------------------------------------------------------------

 define param         record
    asimtvcod         like datkasimtv.asimtvcod
 end record

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 call ctc15m05_input("a", ctc15m05.*) returning ctc15m05.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m05.*  to null
    display by name ctc15m05.*
    error " Operacao cancelada!"
    return ctc15m05.*
 end if

 whenever error continue

 let ctc15m05.atldat = today

 update datkasimtv set  ( asimtvdes,
                         asimtvsit,
                         atldat,
                         atlemp,
                         atlmat )
                    =  ( ctc15m05.asimtvdes,
                         ctc15m05.asimtvsit,
                         ctc15m05.atldat,
                         g_issk.empcod,
                         g_issk.funmat )
                 where asimtvcod  =  ctc15m05.asimtvcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do motivo para assistencia!"
    initialize ctc15m05.*   to null
    return ctc15m05.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc15m05.*  to null
 display by name ctc15m05.*
 message ""
 return ctc15m05.*

 end function  ###  ctc15m05_modifica

#------------------------------------------------------------
 function ctc15m05_inclui()
#------------------------------------------------------------

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 initialize ctc15m05.*   to null
 display by name ctc15m05.*

 call ctc15m05_input("i", ctc15m05.*) returning ctc15m05.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m05.*  to null
    display by name ctc15m05.*
    error " Operacao cancelada!"
    return
 end if

 let ctc15m05.atldat = today
 let ctc15m05.caddat = today

 whenever error continue

 select max(asimtvcod)
   into ctc15m05.asimtvcod
   from datkasimtv
  where asimtvcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo do motivo!"
    return
 end if

 if ctc15m05.asimtvcod is null  then
    let ctc15m05.asimtvcod = 0
 end if

 let ctc15m05.asimtvcod = ctc15m05.asimtvcod + 1

 let ctc15m05.cademp    = g_issk.empcod
 let ctc15m05.cadmat    = g_issk.funmat

 let ctc15m05.atlemp    = g_issk.empcod
 let ctc15m05.atlmat    = g_issk.funmat

 insert into datkasimtv ( asimtvcod,
                         asimtvdes,
                         asimtvsit,
                         caddat,
                         cademp,
                         cadmat,
                         atldat,
                         atlemp,
                         atlmat )
                values ( ctc15m05.asimtvcod,
                         ctc15m05.asimtvdes,
                         ctc15m05.asimtvsit,
                         ctc15m05.caddat,
                         ctc15m05.cademp,
                         ctc15m05.cadmat,
                         ctc15m05.atldat,
                         ctc15m05.atlemp,
                         ctc15m05.atlmat)

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do motivo para assistencia!"
    return
 end if

 whenever error stop

 call ctc15m05_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m05.cadfunnom

 call ctc15m05_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m05.atlfunnom

 display by name ctc15m05.*

 display by name ctc15m05.asimtvcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc15m05.*  to null
 display by name ctc15m05.*

 end function  ###  ctc15m05_inclui

#------------------------------------------------------------
 function ctc15m05_remove(param)
#------------------------------------------------------------

 define param         record
    asimtvcod         like datkasimtv.asimtvcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do motivo para assistencia"
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui motivo para assistencia"
       whenever error continue

       delete from datkasimtv
        where asimtvcod = param.asimtvcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao do motivo!"
       else
          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc15m05_remove

#--------------------------------------------------------------------
 function ctc15m05_input(param, ctc15m05)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false

 input by name ctc15m05.asimtvdes   ,
               ctc15m05.asimtvsit     without defaults

    before field asimtvdes
           display by name ctc15m05.asimtvdes attribute (reverse)

    after  field asimtvdes
           display by name ctc15m05.asimtvdes

           if ctc15m05.asimtvdes is null  then
              error " Descricao do motivo deve ser informado!"
              next field asimtvdes
           end if

    before field asimtvsit
           if param.operacao = "i"  then
              let ctc15m05.asimtvsit    = "A"
              let ctc15m05.asimtvsitdes = "ATIVO"
              exit input
           else
              display by name ctc15m05.asimtvsit attribute (reverse)
           end if

    after  field asimtvsit
           display by name ctc15m05.asimtvsit

           if fgl_lastkey() <> fgl_keyval ("up")    and
              fgl_lastkey() <> fgl_keyval ("left")  then
              if ctc15m05.asimtvsit is null  then
                 error " Situacao deve ser informada!"
                 next field asimtvsit
              else
                 if ctc15m05.asimtvsit = "A"  then
                    let ctc15m05.asimtvsitdes = "ATIVO"
                 else
                    if ctc15m05.asimtvsit = "C"  then
                       let ctc15m05.asimtvsitdes = "CANCELADO"
                    else
                       error " Situacao deve ser (A)tivo ou (C)ancelado!"
                       next field asimtvsit
                    end if
                 end if
              end if
           end if

           display by name ctc15m05.asimtvsitdes

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc15m05.*  to null
 end if

 return ctc15m05.*

 end function  ###  ctc15m05_input

#---------------------------------------------------------
 function ctc15m05_ler(param)
#---------------------------------------------------------

 define param         record
    asimtvcod         like datkasimtv.asimtvcod
 end record

 define ctc15m05      record
    asimtvcod         like datkasimtv.asimtvcod,
    asimtvdes         like datkasimtv.asimtvdes,
    asimtvsit         like datkasimtv.asimtvsit,
    asimtvsitdes      char (10),
    caddat            like datkasimtv.caddat,
    cademp            like datkasimtv.cademp,
    cadmat            like datkasimtv.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasimtv.atldat,
    atlemp            like datkasimtv.atlemp,
    atlmat            like datkasimtv.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 initialize ctc15m05.*   to null

 select asimtvcod,
        asimtvdes,
        asimtvsit,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat
   into ctc15m05.asimtvcod,
        ctc15m05.asimtvdes,
        ctc15m05.asimtvsit,
        ctc15m05.caddat,
        ctc15m05.cademp,
        ctc15m05.cadmat,
        ctc15m05.atldat,
        ctc15m05.atlemp,
        ctc15m05.atlmat
   from datkasimtv
  where asimtvcod = param.asimtvcod

 if sqlca.sqlcode = notfound  then
    error " Motivo nao cadastrado!"
    initialize ctc15m05.*    to null
    return ctc15m05.*
 else
    call ctc15m05_func(ctc15m05.cademp, ctc15m05.cadmat)
         returning ctc15m05.cadfunnom

    call ctc15m05_func(ctc15m05.atlemp, ctc15m05.atlmat)
         returning ctc15m05.atlfunnom

    if ctc15m05.asimtvsit = "A"  then
       let ctc15m05.asimtvsitdes = "ATIVO"
    else
       let ctc15m05.asimtvsitdes = "CANCELADO"
    end if

 end if

 return ctc15m05.*

 end function  ###  ctc15m05_ler

#---------------------------------------------------------
 function ctc15m05_func(param)
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
  where funmat = param.funmat
   and  empcod = param.empcod 
   
 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

 end function  ###  ctc15m05_func
