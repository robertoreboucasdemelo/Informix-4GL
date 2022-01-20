###########################################################################
# Nome do Modulo: ctc47m00                                       Gilberto #
#                                                                Wagner A #
# Cadastro de tipos de solicitante                               Jan/2000 #
###########################################################################
#------------------------------------------------------------------------------#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor  Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- -------------------------------------#
# 21/10/2004 Daniel Meta       PSI188514  Incluir no input o campo c24ligtipcod#
#                                         chamar funcao para retornar a descri #
#                                         cao tipo de ligacao, exibir na tela  #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
 
#------------------------------------------------------------
 function ctc47m00()
#------------------------------------------------------------

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao      char(10) 
 end record

 let int_flag = false
 initialize ctc47m00.*  to null

 open window ctc47m00 at 04,02 with form "ctc47m00"


 menu "TIPOS SOLICITANTE"

 before menu
      hide option all
      show option "Seleciona", "Proximo", "Anterior", "Inclui", "Modifica"
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa tipo de solicitante conforme criterios"
          call ctc47m00_seleciona()  returning ctc47m00.*
          if ctc47m00.c24soltipcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum tipo de solicitante selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo tipo de solicitante"
          message ""
          call ctc47m00_proximo(ctc47m00.c24soltipcod)
               returning ctc47m00.*

 command key ("A") "Anterior"
                   "Mostra tipo de solicitante anterior"
          message ""
          if ctc47m00.c24soltipcod is not null then
             call ctc47m00_anterior(ctc47m00.c24soltipcod)
                  returning ctc47m00.*
          else
             error " Nenhum tipo de solicitante nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica tipo de solicitante selecionado"
          message ""
          if ctc47m00.c24soltipcod  is not null then
             call ctc47m00_modifica(ctc47m00.c24soltipcod, ctc47m00.*)
                  returning ctc47m00.*
             next option "Seleciona"
          else
             error " Nenhum tipo de solicitante selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui tipo de solicitante"
          message ""
          call ctc47m00_inclui()
          next option "Seleciona"

#command key ("R") "Remove"
#                  "Remove tipo de solicitante"
#         message ""
#         if ctc47m00.c24soltipcod  is not null then
#            call ctc47m00_remove(ctc47m00.c24soltipcod)
#            next option "Seleciona"
#         else
#            error " Nenhum tipo de solicitante selecionado!"
#            next option "Seleciona"
#         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc47m00

 end function  ###  ctc47m00

#------------------------------------------------------------
 function ctc47m00_seleciona()
#------------------------------------------------------------

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao       char(10)
 end record


 let int_flag = false
 initialize ctc47m00.*  to null
 display by name ctc47m00.*

 input by name ctc47m00.c24soltipcod

    before field c24soltipcod
        display by name ctc47m00.c24soltipcod attribute (reverse)

    after  field c24soltipcod
        display by name ctc47m00.c24soltipcod

        if ctc47m00.c24soltipcod is null  then
           select min(c24soltipcod)
             into ctc47m00.c24soltipcod
             from datksoltip

           if ctc47m00.c24soltipcod is null  then
              error " Nao existe nenhum tipo de solicitante cadastrado!"
              exit input
           end if
        end if

        select c24soltipcod
          from datksoltip
         where c24soltipcod = ctc47m00.c24soltipcod

        if sqlca.sqlcode = notfound  then
           error " Tipo de solicitante nao cadastrado!"
           next field c24soltipcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc47m00.*   to null
    display by name ctc47m00.*
    error " Operacao cancelada!"
    return ctc47m00.*
 end if

 call ctc47m00_ler(ctc47m00.c24soltipcod)
      returning ctc47m00.*

 if ctc47m00.c24soltipcod  is not null   then
    display by name  ctc47m00.*
 else
    error " Tipo de solicitante nao cadastrado!"
    initialize ctc47m00.*    to null
 end if

 return ctc47m00.*

 end function  ###  ctc47m00_seleciona

#------------------------------------------------------------
 function ctc47m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao      char(10)
 end record


 let int_flag = false
 initialize ctc47m00.*   to null

 if param.c24soltipcod  is null   then
    let param.c24soltipcod = " "
 end if

 select min(datksoltip.c24soltipcod)
   into ctc47m00.c24soltipcod
   from datksoltip
  where c24soltipcod  >  param.c24soltipcod

 if ctc47m00.c24soltipcod is not null  then

    call ctc47m00_ler(ctc47m00.c24soltipcod)
         returning ctc47m00.*

    if ctc47m00.c24soltipcod is not null  then
       display by name ctc47m00.*
    else
       error " Nao ha' nenhum tipo de solicitante nesta direcao!"
       initialize ctc47m00.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de solicitante nesta direcao!"
    initialize ctc47m00.*    to null
 end if

 return ctc47m00.*

 end function  ###  ctc47m00_proximo

#------------------------------------------------------------
 function ctc47m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao      char(10)
 end record


 let int_flag = false
 initialize ctc47m00.*  to null

 if param.c24soltipcod  is null   then
    let param.c24soltipcod = " "
 end if

 select max(datksoltip.c24soltipcod)
   into ctc47m00.c24soltipcod
   from datksoltip
  where c24soltipcod  <  param.c24soltipcod

 if ctc47m00.c24soltipcod  is not null   then
    call ctc47m00_ler(ctc47m00.c24soltipcod)
         returning ctc47m00.*

    if ctc47m00.c24soltipcod  is not null   then
       display by name ctc47m00.*
    else
       error " Nao ha' nenhum tipo de solicitante nesta direcao!"
       initialize ctc47m00.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de solicitante nesta direcao!"
    initialize ctc47m00.*    to null
 end if

 return ctc47m00.*

 end function  ###  ctc47m00_anterior

#------------------------------------------------------------
 function ctc47m00_modifica(param, ctc47m00)
#------------------------------------------------------------

 define param         record
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao       char(10)
 end record

 define s_ctc47m00    record
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    c24ligtipcod      like datksoltip.c24ligtipcod
 end record

 let s_ctc47m00.c24soltipdes = ctc47m00.c24soltipdes
 let s_ctc47m00.c24soltipord = ctc47m00.c24soltipord
 let s_ctc47m00.c24ligtipcod = ctc47m00.c24ligtipcod

 call ctc47m00_input("a", ctc47m00.*) returning ctc47m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc47m00.*  to null
    display by name ctc47m00.*
    error " Operacao cancelada!"
    return ctc47m00.*
 end if

 if s_ctc47m00.c24soltipdes = ctc47m00.c24soltipdes  and
    s_ctc47m00.c24soltipord = ctc47m00.c24soltipord  and
    s_ctc47m00.c24ligtipcod = ctc47m00.c24ligtipcod  then
    error " Nenhuma alteracao foi realizada!"
    initialize ctc47m00.*  to null
    display by name ctc47m00.*
    return ctc47m00.*
 end if

 whenever error continue

 let ctc47m00.atldat = today

 update datksoltip set  ( c24soltipdes,
                          c24soltipord,
                          atldat,
                          atlemp,
                          atlmat,
                          c24ligtipcod )
                     =  ( ctc47m00.c24soltipdes,
                          ctc47m00.c24soltipord,
                          ctc47m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat,
                          ctc47m00.c24ligtipcod )
                 where c24soltipcod  =  ctc47m00.c24soltipcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do tipo de solicitante!"
    initialize ctc47m00.*   to null
    return ctc47m00.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc47m00.*  to null
 display by name ctc47m00.*
 message ""
 return ctc47m00.*

 end function  ###  ctc47m00_modifica

#------------------------------------------------------------
 function ctc47m00_inclui()
#------------------------------------------------------------

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao       char(10)
 end record

 define prompt_key    char (01)

 initialize ctc47m00.*   to null
 display by name ctc47m00.*

 call ctc47m00_input("i", ctc47m00.*) returning ctc47m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc47m00.*  to null
    display by name ctc47m00.*
    error " Operacao cancelada!"
    return
 end if

 let ctc47m00.atldat = today
 let ctc47m00.caddat = today

 whenever error continue

 select max(c24soltipcod)
   into ctc47m00.c24soltipcod
   from datksoltip
  where c24soltipcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo do tipo de solicitante!"
    return
 end if

 if ctc47m00.c24soltipcod is null  then
    let ctc47m00.c24soltipcod = 0
 end if

 let ctc47m00.c24soltipcod = ctc47m00.c24soltipcod + 1

 insert into datksoltip ( c24soltipcod,
                          c24soltipdes,
                          c24soltipord,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat,
                          c24ligtipcod )
                 values ( ctc47m00.c24soltipcod,
                          ctc47m00.c24soltipdes,
                          ctc47m00.c24soltipord,
                          ctc47m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          ctc47m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat,
                          ctc47m00.c24ligtipcod )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do tipo de solicitante!"
    return
 end if

 whenever error stop

 call ctc47m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc47m00.cadfunnom

 call ctc47m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc47m00.atlfunnom

 display by name ctc47m00.*

 display by name ctc47m00.c24soltipcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc47m00.*  to null
 display by name ctc47m00.*

 end function  ###  ctc47m00_inclui

#------------------------------------------------------------
 function ctc47m00_remove(param)
#------------------------------------------------------------

 define param         record
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do tipo de solicitante."
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui tipo de solicitante"
       whenever error continue

       delete from datksoltip
        where c24soltipcod = param.c24soltipcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao do tipo de solicitante!"
       else
          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc47m00_remove

#--------------------------------------------------------------------
 function ctc47m00_input(param, ctc47m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao      char(10)
 end record

 define ws            record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes
 end record
 
 let int_flag = false

 initialize ws.*  to null

 input by name ctc47m00.c24soltipdes,
               ctc47m00.c24soltipord,   
               ctc47m00.c24ligtipcod   without defaults

    before field c24soltipdes
           if param.operacao = "a"  then
              display by name ctc47m00.c24soltipcod
           end if

           display by name ctc47m00.c24soltipdes attribute (reverse)

    after  field c24soltipdes
           display by name ctc47m00.c24soltipdes

           if ctc47m00.c24soltipdes is null  then
              error " Descricao do tipo de solicitante deve ser informada!"
              next field c24soltipdes
           end if

    before field c24soltipord
           display by name ctc47m00.c24soltipord attribute (reverse)

    after  field c24soltipord
           display by name ctc47m00.c24soltipord

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field c24soltipdes
           end if

           if ctc47m00.c24soltipord is null  or
              ctc47m00.c24soltipord =  0     then
              select max(c24soltipord)
                into ctc47m00.c24soltipord
                from datksoltip

              let ctc47m00.c24soltipord = ctc47m00.c24soltipord + 1
           else
              declare c_ctc47m00 cursor with hold for
                 select c24soltipcod, c24soltipdes
                   into ws.c24soltipcod,
                        ws.c24soltipdes
                   from datksoltip
                  where c24soltipord = ctc47m00.c24soltipord

              foreach c_ctc47m00 into ws.c24soltipcod,
                                      ws.c24soltipdes
                 if ctc47m00.c24soltipcod = ws.c24soltipcod  then
                    continue foreach
                 else
                    error " Ordem de exibicao ja' utilizada em ", ws.c24soltipcod using "<&", " - ", ws.c24soltipdes clipped, "! "
                    next field c24soltipord
                 end if
              end foreach
           end if

           display by name ctc47m00.c24soltipord

    before field c24ligtipcod

       display by name ctc47m00.c24ligtipcod attribute (reverse)

    after  field c24ligtipcod

       display by name ctc47m00.c24ligtipcod

       let ctc47m00.descligacao =  f_fungeral_dominio('c24ligtipcod', ctc47m00.c24ligtipcod)
     
       if ctc47m00.descligacao is null then   ---> PSI - 224030
          error " Tipos validos: (1) Normal (2) 333PORTO (3) Ident.Solicitante"
          next field c24ligtipcod
       end if

       display ctc47m00.descligacao to descligacao
          
    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc47m00.*  to null
 end if

 return ctc47m00.*

 end function  ###  ctc47m00_input

#---------------------------------------------------------
 function ctc47m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 define ctc47m00      record
    c24soltipcod      like datksoltip.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    c24soltipord      like datksoltip.c24soltipord,
    caddat            like datksoltip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksoltip.atldat,
    atlfunnom         like isskfunc.funnom,
    c24ligtipcod      like datksoltip.c24ligtipcod,
    descligacao      char(10)
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc47m00.*   to null
 initialize ws.*         to null

 select c24soltipcod,
        c24soltipdes,
        c24soltipord,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat,
        c24ligtipcod
   into ctc47m00.c24soltipcod,
        ctc47m00.c24soltipdes,
        ctc47m00.c24soltipord,
        ctc47m00.caddat,
        ws.cademp,
        ws.cadmat,
        ctc47m00.atldat,
        ws.atlemp,
        ws.atlmat,
        ctc47m00.c24ligtipcod
   from datksoltip
  where c24soltipcod = param.c24soltipcod

  if sqlca.sqlcode = notfound  then
       error " Tipo de solicitante nao cadastrado!"
       initialize ctc47m00.*    to null
       return ctc47m00.*               
  else 
    call ctc47m00_func(ws.cademp, ws.cadmat)
         returning ctc47m00.cadfunnom

    call ctc47m00_func(ws.atlemp, ws.atlmat)
         returning ctc47m00.atlfunnom
         
    let ctc47m00.descligacao =  f_fungeral_dominio('c24ligtipcod', ctc47m00.c24ligtipcod)
         
  end if

 return ctc47m00.*

 end function  ###  ctc47m00_ler

#---------------------------------------------------------
 function ctc47m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 whenever error continue
 select funnom
   into ws.funnom
   from isskfunc
  where funmat = param.funmat
    and empcod = param.empcod
 whenever error stop

 return ws.funnom

 end function  ###  ctc47m00_func
