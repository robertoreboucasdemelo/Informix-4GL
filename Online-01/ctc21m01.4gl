###########################################################################
# Nome do Modulo: ctc21m01                                       Marcelo  #
#                                                                Gilberto #
# Cadastro de campos de parametro para procedimentos             Jun/1999 #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------
 function ctc21m01()
#-------------------------------------------------------------

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc21m01.*  to null

 open window ctc21m01 at 04,02 with form "ctc21m01"

 menu "CAMPOS"

 before menu
      hide option all
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui"
      show option "Remove", "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa campo para procedimento conforme criterios"
          call ctc21m01_seleciona()  returning ctc21m01.*
          if ctc21m01.prtcpointcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum campo selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo campo para procedimento"
          message ""
          call ctc21m01_proximo(ctc21m01.prtcpointcod)
               returning ctc21m01.*

 command key ("A") "Anterior"
                   "Mostra campo para procedimento"
          message ""
          if ctc21m01.prtcpointcod is not null then
             call ctc21m01_anterior(ctc21m01.prtcpointcod)
                  returning ctc21m01.*
          else
             error " Nao ha' nenhum campo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica campo para procedimento"
          message ""
          if ctc21m01.prtcpointcod  is not null then
             call ctc21m01_modifica(ctc21m01.prtcpointcod, ctc21m01.*)
                  returning ctc21m01.*
             next option "Seleciona"
          else
             error " Nenhum campo selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui campo para procedimento"
          message ""
          call ctc21m01_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove campo para procedimento"
          message ""
          if ctc21m01.prtcpointcod  is not null then
             call ctc21m01_remove(ctc21m01.prtcpointcod)
             next option "Seleciona"
          else
             error " Nenhum campo selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc21m01

 end function  ###  ctc21m01


#------------------------------------------------------------
 function ctc21m01_seleciona()
#------------------------------------------------------------

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc21m01.*  to null
 display by name ctc21m01.*

 input by name ctc21m01.prtcpointcod

    before field prtcpointcod
        display by name ctc21m01.prtcpointcod attribute (reverse)

    after  field prtcpointcod
        display by name ctc21m01.prtcpointcod

        if ctc21m01.prtcpointcod is null  then
           select min(prtcpointcod)
             into ctc21m01.prtcpointcod
             from dattprt

           if ctc21m01.prtcpointcod is null  then
              error " Nao existe nenhum campo cadastrado!"
              exit input
           end if
        end if

        select prtcpointcod
          from dattprt
         where prtcpointcod = ctc21m01.prtcpointcod

        if sqlca.sqlcode = notfound  then
           error " Campo nao cadastrado!"
           next field prtcpointcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc21m01.*   to null
    display by name ctc21m01.*
    error " Operacao cancelada!"
    return ctc21m01.*
 end if

 call ctc21m01_ler(ctc21m01.prtcpointcod)
      returning ctc21m01.*

 if ctc21m01.prtcpointcod  is not null   then
    display by name  ctc21m01.*
 else
    error " Campo nao cadastrado!"
    initialize ctc21m01.*    to null
 end if

 return ctc21m01.*

 end function  ###  ctc21m01_seleciona


#------------------------------------------------------------
 function ctc21m01_proximo(param)
#------------------------------------------------------------

 define param         record
    prtcpointcod      like dattprt.prtcpointcod
 end record

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc21m01.*   to null

 if param.prtcpointcod  is null   then
    let param.prtcpointcod = " "
 end if

 select min(dattprt.prtcpointcod)
   into ctc21m01.prtcpointcod
   from dattprt
  where prtcpointcod  >  param.prtcpointcod

 if ctc21m01.prtcpointcod is not null  then

    call ctc21m01_ler(ctc21m01.prtcpointcod)
         returning ctc21m01.*

    if ctc21m01.prtcpointcod is not null  then
       display by name ctc21m01.*
    else
       error " Nao ha' nenhum campo nesta direcao!"
       initialize ctc21m01.*    to null
    end if
 else
    error " Nao ha' nenhum campo nesta direcao!"
    initialize ctc21m01.*    to null
 end if

 return ctc21m01.*

 end function  ###  ctc21m01_proximo


#------------------------------------------------------------
 function ctc21m01_anterior(param)
#------------------------------------------------------------

 define param         record
    prtcpointcod      like dattprt.prtcpointcod
 end record

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 let int_flag = false
 initialize ctc21m01.*  to null

 if param.prtcpointcod  is null   then
    let param.prtcpointcod = " "
 end if

 select max(dattprt.prtcpointcod)
   into ctc21m01.prtcpointcod
   from dattprt
  where prtcpointcod  <  param.prtcpointcod

 if ctc21m01.prtcpointcod  is not null   then
    call ctc21m01_ler(ctc21m01.prtcpointcod)
         returning ctc21m01.*

    if ctc21m01.prtcpointcod  is not null   then
       display by name ctc21m01.*
    else
       error " Nao ha' nenhum campo nesta direcao!"
       initialize ctc21m01.*    to null
    end if
 else
    error " Nao ha' nenhum campo nesta direcao!"
    initialize ctc21m01.*    to null
 end if

 return ctc21m01.*

 end function  ###  ctc21m01_anterior


#------------------------------------------------------------
 function ctc21m01_modifica(param, ctc21m01)
#------------------------------------------------------------

 define param         record
    prtcpointcod      like dattprt.prtcpointcod
 end record

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 call ctc21m01_input("a", ctc21m01.*) returning ctc21m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc21m01.*  to null
    display by name ctc21m01.*
    error " Operacao cancelada!"
    return ctc21m01.*
 end if

 whenever error continue

 let ctc21m01.atldat = today

 update dattprt set  ( prtcponom,
                       prtcpodes,
                       prtcpointnom,
                       atldat,
                       altemp,
                       atlmat )
                  =  ( ctc21m01.prtcponom,
                       ctc21m01.prtcpodes,
                       ctc21m01.prtcpointnom,
                       ctc21m01.atldat,
                       g_issk.empcod,
                       g_issk.funmat )
               where prtcpointcod  =  ctc21m01.prtcpointcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do campo para procedimento!"
    initialize ctc21m01.*   to null
    return ctc21m01.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc21m01.*  to null
 display by name ctc21m01.*
 message ""
 return ctc21m01.*

 end function  ###  ctc21m01_modifica


#------------------------------------------------------------
 function ctc21m01_inclui()
#------------------------------------------------------------

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define prompt_key    char (01)

 initialize ctc21m01.*   to null
 display by name ctc21m01.*

 call ctc21m01_input("i", ctc21m01.*) returning ctc21m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc21m01.*  to null
    display by name ctc21m01.*
    error " Operacao cancelada!"
    return
 end if

 let ctc21m01.atldat = today

 whenever error continue

 select max(prtcpointcod)
   into ctc21m01.prtcpointcod
   from dattprt
  where prtcpointcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo do campo!"
    return
 end if

 if ctc21m01.prtcpointcod is null  then
    let ctc21m01.prtcpointcod = 0
 end if

 let ctc21m01.prtcpointcod = ctc21m01.prtcpointcod + 1

 insert into dattprt ( prtcpointcod,
                       prtcponom,
                       prtcpodes,
                       prtcpointnom,
                       atldat,
                       altemp,
                       atlmat )
              values ( ctc21m01.prtcpointcod,
                       ctc21m01.prtcponom,
                       ctc21m01.prtcpodes,
                       ctc21m01.prtcpointnom,
                       ctc21m01.atldat,
                       g_issk.empcod,
                       g_issk.funmat )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do campo para procedimento!"
    return
 end if

 whenever error stop

 call ctc21m01_func(g_issk.empcod, g_issk.funmat)
      returning ctc21m01.atlfunnom

 display by name ctc21m01.*

 display by name ctc21m01.prtcpointcod attribute (reverse)
 error " Inclusao efetuada com sucesso!"
 prompt "" for char prompt_key

 initialize ctc21m01.*  to null
 display by name ctc21m01.*

 end function  ###  ctc21m01_inclui


#------------------------------------------------------------
 function ctc21m01_remove(param)
#------------------------------------------------------------

 define param         record
    prtcpointcod      like dattprt.prtcpointcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do campo para procedimento"
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui campo para procedimento"
       declare c_datmprtprc  cursor for
          select *
            from datmprtprc
           where datmprtprc.prtcpointcod  =  param.prtcpointcod

       open  c_datmprtprc
       fetch c_datmprtprc

       if sqlca.sqlcode  =  notfound   then
          whenever error continue

          delete
            from dattprt
           where prtcpointcod = param.prtcpointcod

          whenever error stop

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na remocao do campo!"
          else
             error " Exclusao efetuada com sucesso!"
             clear form
          end if
       else
          error " Campo nao deve ser excluido. Existe procedimento cadastrado com este campo!"
       end if

       exit menu
 end menu

 return

 end function  ###  ctc21m01_remove


#--------------------------------------------------------------------
 function ctc21m01_input(param, ctc21m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    prtcpointcod      like dattprt.prtcpointcod
 end record


 initialize ws.*  to null
 let int_flag = false

 input by name ctc21m01.prtcponom,
               ctc21m01.prtcpodes,
               ctc21m01.prtcpointnom  without defaults

    before field prtcponom
           display by name ctc21m01.prtcponom attribute (reverse)

    after  field prtcponom
           display by name ctc21m01.prtcponom

           if ctc21m01.prtcponom is null  then
              error " Nome do campo deve ser informado!"
              next field prtcponom
           end if

           select prtcpointcod
             into ws.prtcpointcod
             from dattprt
            where dattprt.prtcponom  =  ctc21m01.prtcponom

           if sqlca.sqlcode  <>  notfound   then
              error " Ja' existe campo cadastrado com esse nome --> ",
                    ws.prtcpointcod  using "#&&&&"
              next field prtcponom
           end if

    before field prtcpodes
           display by name ctc21m01.prtcpodes attribute (reverse)

    after  field prtcpodes
           display by name ctc21m01.prtcpodes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field prtcponom
           end if

           if ctc21m01.prtcpodes is null  then
              error " Descricao do campo deve ser informado!"
              next field prtcpodes
           end if

    before field prtcpointnom
              display by name ctc21m01.prtcpointnom  attribute (reverse)

    after  field prtcpointnom
           display by name ctc21m01.prtcpointnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field prtcpodes
           end if

           if ctc21m01.prtcpointnom  is null  then
              error " Nome do campo na base de dados deve ser informado!"
              next field prtcpointnom
           else
              select prtcpointcod
                into ws.prtcpointcod
                from dattprt
               where dattprt.prtcpointnom  =  ctc21m01.prtcpointnom

              if sqlca.sqlcode  <>  notfound   then
                 error " Ja' existe campo cadastrado com esse nome interno --> "
                       ,ws.prtcpointcod  using "#&&&&"
                 next field prtcpointnom
              end if

           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc21m01.*  to null
 end if

 return ctc21m01.*

 end function  ###  ctc21m01_input


#---------------------------------------------------------
 function ctc21m01_ler(param)
#---------------------------------------------------------

 define param         record
    prtcpointcod      like dattprt.prtcpointcod
 end record

 define ctc21m01      record
    prtcpointcod      like dattprt.prtcpointcod,
    prtcponom         like dattprt.prtcponom,
    prtcpodes         like dattprt.prtcpodes,
    prtcpointnom      like dattprt.prtcpointnom,
    atldat            like dattprt.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    altemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat
 end record


 initialize ctc21m01.*   to null
 initialize ws.*         to null

 select prtcpointcod,
        prtcponom,
        prtcpodes,
        prtcpointnom,
        atldat,
        altemp,
        atlmat
   into ctc21m01.prtcpointcod,
        ctc21m01.prtcponom,
        ctc21m01.prtcpodes,
        ctc21m01.prtcpointnom,
        ctc21m01.atldat,
        ws.altemp,
        ws.atlmat
   from dattprt
  where prtcpointcod = param.prtcpointcod

 if sqlca.sqlcode = notfound  then
    error " Campo nao cadastrado!"
    initialize ctc21m01.*    to null
    return ctc21m01.*
 else

    call ctc21m01_func(ws.altemp, ws.atlmat)
         returning ctc21m01.atlfunnom
 end if

 return ctc21m01.*

 end function  ###  ctc21m01_ler


#---------------------------------------------------------
 function ctc21m01_func(param)
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

 return ws.funnom

 end function  ###  ctc21m01_func
