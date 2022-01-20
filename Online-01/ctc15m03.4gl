#############################################################################
# Nome do Modulo: ctc15m03                                         Marcelo  #
#                                                                  Gilberto #
# Cadastro de etapas                                               Ago/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 30/06/1999  PSI 7547-7   Gilberto     Inclusao do campo de pendencia no   #
#                                       radio e aviso para confirmar a mo-  #
#                                       dificacao de etapas utilizadas em   #
#                                       programas como codigo fixo.         #
#############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------
 function ctc15m03()
#-------------------------------------------------------------

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m03.*  to null

 open window ctc15m03 at 04,02 with form "ctc15m03"


 menu "ETAPAS"

 before menu
      hide option all
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui"
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa etapa de acompanhamento de servicos conforme criterios"
          call ctc15m03_seleciona()  returning ctc15m03.*
          if ctc15m03.atdetpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma etapa selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima etapa de acompanhamento de servicos"
          message ""
          call ctc15m03_proximo(ctc15m03.atdetpcod)
               returning ctc15m03.*

 command key ("A") "Anterior"
                   "Mostra etapa de acompanhamento de servicos anterior"
          message ""
          if ctc15m03.atdetpcod is not null then
             call ctc15m03_anterior(ctc15m03.atdetpcod)
                  returning ctc15m03.*
          else
             error " Nao ha' nenhuma etapa nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica etapa de acompanhamento de servicos selecionada"
          message ""
          if ctc15m03.atdetpcod  is not null then
             call ctc15m03_modifica(ctc15m03.atdetpcod, ctc15m03.*)
                  returning ctc15m03.*
             next option "Seleciona"
          else
             error " Nenhuma etapa selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui etapa de acompanhamento de servicos"
          message ""
          call ctc15m03_inclui()
          next option "Seleciona"

#command key ("R") "Remove"
#                  "Remove etapa de acompanhamento de servicos"
#         message ""
#         if ctc15m03.atdetpcod  is not null then
#            call ctc15m03_remove(ctc15m03.atdetpcod)
#            next option "Seleciona"
#         else
#            error " Nenhuma etapa selecionada!"
#            next option "Seleciona"
#         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc15m03

 end function  ###  ctc15m03

#------------------------------------------------------------
 function ctc15m03_seleciona()
#------------------------------------------------------------

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m03.*  to null
 display by name ctc15m03.*

 input by name ctc15m03.atdetpcod

    before field atdetpcod
        display by name ctc15m03.atdetpcod attribute (reverse)

    after  field atdetpcod
        display by name ctc15m03.atdetpcod

        if ctc15m03.atdetpcod is null  then
           select min(atdetpcod)
             into ctc15m03.atdetpcod
             from datketapa

           if ctc15m03.atdetpcod is null  then
              error " Nao existe nenhuma etapa cadastrada!"
              exit input
           end if
        end if

        select atdetpcod
          from datketapa
         where atdetpcod = ctc15m03.atdetpcod

        if sqlca.sqlcode = notfound  then
           error " Etapa nao cadastrada!"
           next field atdetpcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc15m03.*   to null
    display by name ctc15m03.*
    error " Operacao cancelada!"
    return ctc15m03.*
 end if

 call ctc15m03_ler(ctc15m03.atdetpcod)
      returning ctc15m03.*

 if ctc15m03.atdetpcod  is not null   then
    display by name  ctc15m03.*
 else
    error " Etapa nao cadastrada!"
    initialize ctc15m03.*    to null
 end if

 return ctc15m03.*

 end function  ###  ctc15m03_seleciona

#------------------------------------------------------------
 function ctc15m03_proximo(param)
#------------------------------------------------------------

 define param         record
    atdetpcod         like datketapa.atdetpcod
 end record

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m03.*   to null

 if param.atdetpcod  is null   then
    let param.atdetpcod = " "
 end if

 select min(datketapa.atdetpcod)
   into ctc15m03.atdetpcod
   from datketapa
  where atdetpcod  >  param.atdetpcod

 if ctc15m03.atdetpcod is not null  then

    call ctc15m03_ler(ctc15m03.atdetpcod)
         returning ctc15m03.*

    if ctc15m03.atdetpcod is not null  then
       display by name ctc15m03.*
    else
       error " Nao ha' nenhuma etapa nesta direcao!"
       initialize ctc15m03.*    to null
    end if
 else
    error " Nao ha' nenhuma etapa nesta direcao!"
    initialize ctc15m03.*    to null
 end if

 return ctc15m03.*

 end function  ###  ctc15m03_proximo

#------------------------------------------------------------
 function ctc15m03_anterior(param)
#------------------------------------------------------------

 define param         record
    atdetpcod         like datketapa.atdetpcod
 end record

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc15m03.*  to null

 if param.atdetpcod  is null   then
    let param.atdetpcod = " "
 end if

 select max(datketapa.atdetpcod)
   into ctc15m03.atdetpcod
   from datketapa
  where atdetpcod  <  param.atdetpcod

 if ctc15m03.atdetpcod  is not null   then
    call ctc15m03_ler(ctc15m03.atdetpcod)
         returning ctc15m03.*

    if ctc15m03.atdetpcod  is not null   then
       display by name ctc15m03.*
    else
       error " Nao ha' nenhuma etapa nesta direcao!"
       initialize ctc15m03.*    to null
    end if
 else
    error " Nao ha' nenhuma etapa nesta direcao!"
    initialize ctc15m03.*    to null
 end if

 return ctc15m03.*

 end function  ###  ctc15m03_anterior

#------------------------------------------------------------
 function ctc15m03_modifica(param, ctc15m03)
#------------------------------------------------------------

 define param         record
    atdetpcod         like datketapa.atdetpcod
 end record

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    confirma          char (01)
 end record

 if param.atdetpcod <= 6  then
    call cts08g01("A","S","CODIGO DE ETAPA UTILIZADO","INTERNAMENTE NO SISTEMA!","","CONTINUA MODIFICACAO?") returning ws.confirma
    if ws.confirma = "N"  then
       let int_flag = false
       initialize ctc15m03.*  to null
       display by name ctc15m03.*
       error " Operacao cancelada!"
       return ctc15m03.*
    end if
 end if

 call ctc15m03_input("a", ctc15m03.*) returning ctc15m03.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m03.*  to null
    display by name ctc15m03.*
    error " Operacao cancelada!"
    return ctc15m03.*
 end if

 whenever error continue

 let ctc15m03.atldat = today

 update datketapa set  ( atdetpdes,
                         atdetptipcod,
                         atdetppndflg,
                         atdetpstt,
                         atldat,
                         atlemp,
                         atlmat )
                    =  ( ctc15m03.atdetpdes,
                         ctc15m03.atdetptipcod,
                         ctc15m03.atdetppndflg,
                         ctc15m03.atdetpstt,
                         ctc15m03.atldat,
                         g_issk.empcod,
                         g_issk.funmat )
                 where atdetpcod  =  ctc15m03.atdetpcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao da etapa de acompanhamento de servicos!"
    initialize ctc15m03.*   to null
    return ctc15m03.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc15m03.*  to null
 display by name ctc15m03.*
 message ""
 return ctc15m03.*

 end function  ###  ctc15m03_modifica

#------------------------------------------------------------
 function ctc15m03_inclui()
#------------------------------------------------------------

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 initialize ctc15m03.*   to null
 display by name ctc15m03.*

 call ctc15m03_input("i", ctc15m03.*) returning ctc15m03.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m03.*  to null
    display by name ctc15m03.*
    error " Operacao cancelada!"
    return
 end if

 let ctc15m03.atldat = today
 let ctc15m03.caddat = today

 whenever error continue

 select max(atdetpcod)
   into ctc15m03.atdetpcod
   from datketapa
  where atdetpcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo da etapa!"
    return
 end if

 if ctc15m03.atdetpcod is null  then
    let ctc15m03.atdetpcod = 0
 end if

 let ctc15m03.atdetpcod = ctc15m03.atdetpcod + 1

 let ctc15m03.cademp    = g_issk.empcod
 let ctc15m03.cadmat    = g_issk.funmat

 let ctc15m03.atlemp    = g_issk.empcod
 let ctc15m03.atlmat    = g_issk.funmat

 insert into datketapa ( atdetpcod,
                         atdetpdes,
                         atdetptipcod,
                         atdetppndflg,
                         atdetpstt,
                         caddat,
                         cademp,
                         cadmat,
                         atldat,
                         atlemp,
                         atlmat )
                values ( ctc15m03.atdetpcod,
                         ctc15m03.atdetpdes,
                         ctc15m03.atdetptipcod,
                         ctc15m03.atdetppndflg,
                         ctc15m03.atdetpstt,
                         ctc15m03.caddat,
                         ctc15m03.cademp,
                         ctc15m03.cadmat,
                         ctc15m03.atldat,
                         ctc15m03.atlemp,
                         ctc15m03.atlmat)

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento de servicos!"
    return
 end if

 whenever error stop

 call ctc15m03_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m03.cadfunnom

 call ctc15m03_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m03.atlfunnom

 display by name ctc15m03.*

 display by name ctc15m03.atdetpcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc15m03.*  to null
 display by name ctc15m03.*

 end function  ###  ctc15m03_inclui

#------------------------------------------------------------
 function ctc15m03_remove(param)
#------------------------------------------------------------

 define param         record
    atdetpcod         like datketapa.atdetpcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao da etapa de acompanhamento de servicos"
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui etapa de acompanhamento de servicos"
       whenever error continue

       delete from datketapa
        where atdetpcod = param.atdetpcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao da etapa!"
       else
          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc15m03_remove

#--------------------------------------------------------------------
 function ctc15m03_input(param, ctc15m03)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false

 input by name ctc15m03.atdetpdes   ,
               ctc15m03.atdetptipcod,
               ctc15m03.atdetppndflg,
               ctc15m03.atdetpstt     without defaults

    before field atdetpdes
           display by name ctc15m03.atdetpdes attribute (reverse)

    after  field atdetpdes
           display by name ctc15m03.atdetpdes

           if ctc15m03.atdetpdes is null  then
              error " Descricao da etapa deve ser informada!"
              next field atdetpdes
           end if

    before field atdetptipcod
           display by name ctc15m03.atdetptipcod attribute (reverse)

    after  field atdetptipcod
           display by name ctc15m03.atdetptipcod

           if ctc15m03.atdetptipcod is null  then
              error " Tipo da etapa deve ser informado!"
              next field atdetptipcod
           else
              select cpodes
                into ctc15m03.atdetptipdes
                from iddkdominio
               where cponom = "atdetptipcod"  and
                     cpocod = ctc15m03.atdetptipcod

              if sqlca.sqlcode = notfound  then
                 error " Tipo da etapa invalido!"
                 next field atdetptipcod
              else
                 display by name ctc15m03.atdetptipdes
              end if
           end if

    before field atdetppndflg
           display by name ctc15m03.atdetppndflg attribute (reverse)

    after  field atdetppndflg
           display by name ctc15m03.atdetppndflg

           if fgl_lastkey() <> fgl_keyval ("up")    and
              fgl_lastkey() <> fgl_keyval ("left")  then
              if ctc15m03.atdetppndflg is null  then
                 error " Etapa de pendencia deve ser informada!"
                 next field atdetppndflg
              else
                 if ctc15m03.atdetppndflg <> "S"  and
                    ctc15m03.atdetppndflg <> "N"  then
                    error " Etapa de pendencia deve ser (S)im ou (N)ao!"
                    next field atdetppndflg
                 end if
              end if
           end if

    before field atdetpstt
           if param.operacao = "i"  then
              let ctc15m03.atdetpstt    = "A"
              let ctc15m03.atdetpsttdes = "ATIVO"
              exit input
           else
              display by name ctc15m03.atdetpstt attribute (reverse)
           end if

    after  field atdetpstt
           display by name ctc15m03.atdetpstt

           if fgl_lastkey() <> fgl_keyval ("up")    and
              fgl_lastkey() <> fgl_keyval ("left")  then
              if ctc15m03.atdetpstt is null  then
                 error " Situacao deve ser informada!"
                 next field atdetpstt
              else
                 if ctc15m03.atdetpstt = "A"  then
                    let ctc15m03.atdetpsttdes = "ATIVO"
                 else
                    if ctc15m03.atdetpstt = "C"  then
                       let ctc15m03.atdetpsttdes = "CANCELADO"
                    else
                       error " Situacao deve ser (A)tivo ou (C)ancelado!"
                       next field atdetpstt
                    end if
                 end if
              end if
           end if

           display by name ctc15m03.atdetpsttdes

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc15m03.*  to null
 end if

 return ctc15m03.*

 end function  ###  ctc15m03_input

#---------------------------------------------------------
 function ctc15m03_ler(param)
#---------------------------------------------------------

 define param         record
    atdetpcod         like datketapa.atdetpcod
 end record

 define ctc15m03      record
    atdetpcod         like datketapa.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetptipdes      char (15),
    atdetppndflg      like datketapa.atdetppndflg,
    atdetpstt         like datketapa.atdetpstt,
    atdetpsttdes      char (10),
    caddat            like datketapa.caddat,
    cademp            like datketapa.cademp,
    cadmat            like datketapa.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datketapa.atldat,
    atlemp            like datketapa.atlemp,
    atlmat            like datketapa.atlmat,
    atlfunnom         like isskfunc.funnom
 end record

 initialize ctc15m03.*   to null

 select atdetpcod,
        atdetpdes,
        atdetptipcod,
        atdetppndflg,
        atdetpstt,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat
   into ctc15m03.atdetpcod,
        ctc15m03.atdetpdes,
        ctc15m03.atdetptipcod,
        ctc15m03.atdetppndflg,
        ctc15m03.atdetpstt,
        ctc15m03.caddat,
        ctc15m03.cademp,
        ctc15m03.cadmat,
        ctc15m03.atldat,
        ctc15m03.atlemp,
        ctc15m03.atlmat
   from datketapa
  where atdetpcod = param.atdetpcod

 if sqlca.sqlcode = notfound  then
    error " Etapa nao cadastrada!"
    initialize ctc15m03.*    to null
    return ctc15m03.*
 else
    select cpodes
      into ctc15m03.atdetptipdes
      from iddkdominio
     where cponom = "atdetptipcod"  and
           cpocod = ctc15m03.atdetptipcod

    call ctc15m03_func(ctc15m03.cademp, ctc15m03.cadmat)
         returning ctc15m03.cadfunnom

    call ctc15m03_func(ctc15m03.atlemp, ctc15m03.atlmat)
         returning ctc15m03.atlfunnom

    if ctc15m03.atdetpstt = "A"  then
       let ctc15m03.atdetpsttdes = "ATIVO"
    else
       let ctc15m03.atdetpsttdes = "CANCELADO"
    end if

 end if

 return ctc15m03.*

 end function  ###  ctc15m03_ler

#---------------------------------------------------------
 function ctc15m03_func(param)
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

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

 end function  ###  ctc15m03_func
