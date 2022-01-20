###########################################################################
# Nome do Modulo: ctc25m01                                       Marcus   #
#                                                                         #
# Cadastro de telas para alertas e procedimentos                 Abr/2002 #
###########################################################################

 database porto

 define ws1         record
   atlfunnom        like isskfunc.funnom
 end record    

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc25m01()
#------------------------------------------------------------

 define ctc25m01      record
    telcod            like datktel.telcod,
    telnom            like datktel.telnom,
    teldsc            like datktel.teldsc,
    atldat            like datktel.atldat,
    atlusrtip         like datktel.atlusrtip,
    atlmat            like datktel.atlmat,
    atlemp            like datktel.atlemp
 end record

 let int_flag = false
 initialize ctc25m01.*  to null

 open window ctc25m01 at 04,02 with form "ctc25m01"

 menu "TELAS"

 before menu
#     hide option all
#     show option "Seleciona", "Proxima", "Anterior", "Modifica", "Inclui"
      show option "Remove", "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa tela para procedimento conforme criterios"
          call ctc25m01_seleciona()  returning ctc25m01.*
          if ctc25m01.telcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma tela selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo tela para procedimento"
          message ""
          call ctc25m01_proximo(ctc25m01.telcod)
               returning ctc25m01.*

 command key ("A") "Anterior"
                   "Mostra tela para procedimento"
          message ""
          if ctc25m01.telcod is not null then
             call ctc25m01_anterior(ctc25m01.telcod)
                  returning ctc25m01.*
          else
             error " Nao ha' nenhuma tela nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica tela para procedimento"
          message ""
          if ctc25m01.telcod  is not null then
             call ctc25m01_modifica(ctc25m01.telcod, ctc25m01.*)
                  returning ctc25m01.*
             next option "Seleciona"
          else
             error " Nenhum tela selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui tela para procedimento"
          message ""
          call ctc25m01_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove tela para procedimento"
          message ""
          if ctc25m01.telcod  is not null then
             call ctc25m01_remove(ctc25m01.telcod)
             next option "Seleciona"
          else
             error " Nenhuma tela selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc25m01

 end function  ###  ctc25m01


#------------------------------------------------------------
 function ctc25m01_seleciona()
#------------------------------------------------------------

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record          

 let int_flag = false
 initialize ctc25m01.*  to null
 display by name ctc25m01.telcod thru ctc25m01.atldat
 display by name ws1.atlfunnom

 input by name ctc25m01.telcod

    before field telcod
        display by name ctc25m01.telcod attribute (reverse)

    after field telcod
        display by name ctc25m01.telcod

        if ctc25m01.telcod is null  then
           select min(telcod)
             into ctc25m01.telcod
             from datktel

           if ctc25m01.telcod is null  then
              error " Nao existe nenhuma tela cadastrada!"
              exit input
           end if
        end if

        select telcod
          from datktel
         where telcod = ctc25m01.telcod

        if sqlca.sqlcode = notfound  then
           error " Tela nao cadastrada!"
           next field telcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc25m01.*   to null
    display by name ctc25m01.telcod thru ctc25m01.atldat
    display by name ws1.atlfunnom
    error " Operacao cancelada!"
    return ctc25m01.*
 end if

 call ctc25m01_ler(ctc25m01.telcod)
     returning ctc25m01.*
     

 if ctc25m01.telcod  is not null   then
    display by name ctc25m01.telcod thru ctc25m01.atldat
    display by name ws1.atlfunnom
 else
    error " Campo nao cadastrado!"
    initialize ctc25m01.*    to null
 end if

 return ctc25m01.*

 end function  ###  ctc25m01_seleciona


#------------------------------------------------------------
 function ctc25m01_proximo(param)
#------------------------------------------------------------

 define param         record
    telcod      like datktel.telcod
 end record

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       


 let int_flag = false
 initialize ctc25m01.*   to null

 if param.telcod  is null   then
    let param.telcod = " "
 end if

 select min(datktel.telcod)
   into ctc25m01.telcod
   from datktel
  where telcod  >  param.telcod

 if ctc25m01.telcod is not null  then

    call ctc25m01_ler(ctc25m01.telcod)
         returning ctc25m01.*

    if ctc25m01.telcod is not null  then
       display by name ctc25m01.telcod thru ctc25m01.atldat
       display by name ws1.atlfunnom
    else
       error " Nao ha' nenhuma tela nesta direcao!"
       initialize ctc25m01.*    to null
    end if
 else
    error " Nao ha' nenhuma tela nesta direcao!"
    initialize ctc25m01.*    to null
 end if

 return ctc25m01.*

 end function  ###  ctc25m01_proximo


#------------------------------------------------------------
 function ctc25m01_anterior(param)
#------------------------------------------------------------

 define param         record
    telcod      like datktel.telcod
 end record

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       

 let int_flag = false
 initialize ctc25m01.*  to null

 if param.telcod  is null   then
    let param.telcod = " "
 end if

 select max(datktel.telcod)
   into ctc25m01.telcod
   from datktel
  where telcod  <  param.telcod

 if ctc25m01.telcod  is not null   then
    call ctc25m01_ler(ctc25m01.telcod)
         returning ctc25m01.*

    if ctc25m01.telcod  is not null   then
       display by name ctc25m01.telcod thru ctc25m01.atldat
       display by name ws1.atlfunnom
    else
       error " Nao ha' nenhuma tela nesta direcao!"
       initialize ctc25m01.*    to null
    end if
 else
    error " Nao ha' nenhuma tela nesta direcao!"
    initialize ctc25m01.*    to null
 end if

 return ctc25m01.*

 end function  ###  ctc25m01_anterior


#------------------------------------------------------------
 function ctc25m01_modifica(param, ctc25m01)
#------------------------------------------------------------

 define param         record
    telcod      like datktel.telcod
 end record

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       

 call ctc25m01_input("a", ctc25m01.*) returning ctc25m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc25m01.*  to null
    display by name ctc25m01.telcod thru ctc25m01.atldat
    display by name ws1.atlfunnom
    error " Operacao cancelada!"
    return ctc25m01.*
 end if

 whenever error continue

 let ctc25m01.atldat = today

 update datktel set  ( telnom,
                       teldsc,
                       atldat,
                       atlusrtip,
                       atlemp,
                       atlmat )
                  =  ( ctc25m01.telnom,
                       ctc25m01.teldsc,
                       ctc25m01.atldat,
                       g_issk.usrtip,
                       g_issk.empcod,
                       g_issk.funmat )
               where telcod  =  ctc25m01.telcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao da tela para procedimento!"
    initialize ctc25m01.*   to null
    return ctc25m01.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc25m01.*  to null
 display by name ctc25m01.telcod thru ctc25m01.atldat
 display by name ws1.atlfunnom
 message ""
 return ctc25m01.*

 end function  ###  ctc25m01_modifica


#------------------------------------------------------------
 function ctc25m01_inclui()
#------------------------------------------------------------

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       

 define prompt_key    char (01)

 initialize ctc25m01.*   to null
 display by name ctc25m01.telcod thru ctc25m01.atldat
 display by name ws1.atlfunnom

 call ctc25m01_input("i", ctc25m01.*) returning ctc25m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc25m01.*  to null
    display by name ctc25m01.telcod thru ctc25m01.atldat
    display by name ws1.atlfunnom
    error " Operacao cancelada!"
    return
 end if

 let ctc25m01.atldat = today

 whenever error continue

 select max(telcod)
   into ctc25m01.telcod
   from datktel
  where telcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo da tela!"
    return
 end if

 if ctc25m01.telcod is null  then
    let ctc25m01.telcod = 0
 end if

 let ctc25m01.telcod = ctc25m01.telcod + 1

 insert into datktel ( telcod,
                       telnom,
                       teldsc,
                       atldat,
                       atlusrtip,
                       atlmat,
                       atlemp )
              values ( ctc25m01.telcod,
                       ctc25m01.telnom,
                       ctc25m01.teldsc,
                       ctc25m01.atldat,
                       g_issk.usrtip,
                       g_issk.funmat,
                       g_issk.empcod )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao da tela para procedimento!"
    return
 end if

 whenever error stop

 call ctc25m01_func(g_issk.empcod, g_issk.funmat, g_issk.usrtip)
      returning ws1.atlfunnom

 display by name ctc25m01.telcod thru ctc25m01.atldat
 display by name ws1.atlfunnom

 display by name ctc25m01.telcod attribute (reverse)
 error " Inclusao efetuada com sucesso!"
 prompt "" for char prompt_key

 initialize ctc25m01.*  to null
 display by name ctc25m01.telcod thru ctc25m01.atldat
 display by name ws1.atlfunnom

 end function  ###  ctc25m01_inclui


#------------------------------------------------------------
 function ctc25m01_remove(param)
#------------------------------------------------------------

 define param         record
    telcod      like datktel.telcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao da tela para procedimento"
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui tela para procedimento"
       ---> Nilo
       declare c_datktelprc  cursor for
          select *
            from datktelprc
           where datktelprc.telcod  =  param.telcod

       open  c_datktelprc
       fetch c_datktelprc

       if sqlca.sqlcode  =  notfound   then
          whenever error continue

          delete
            from datktel
           where telcod = param.telcod

          whenever error stop

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na remocao do tela!"
          else
             error " Exclusao efetuada com sucesso!"
             clear form
          end if
       else
          error " Tela nao deve ser excluida. Existe procedimento cadastrado para esta tela!"
       end if

       exit menu
 end menu

 return

 end function  ###  ctc25m01_remove


#--------------------------------------------------------------------
 function ctc25m01_input(param, ctc25m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       

 define ws            record
    telcod      like datktel.telcod
 end record


 initialize ws.*  to null
 let int_flag = false

 input by name ctc25m01.telnom,
               ctc25m01.teldsc  without defaults

    before field telnom
           display by name ctc25m01.telnom attribute (reverse)

    after  field telnom
           display by name ctc25m01.telnom
---> Nilo
           if ctc25m01.telnom[1,2] <> "ct" and
              ctc25m01.telnom[1,8] <> "apoledsz" then
              error "Apenas telas da Central/Porto Socorro/Apoledsz"
              next field telnom
           end if

           if ctc25m01.telnom is null  then
              error " Nome da tela deve ser informada!"
              next field telnom
           end if

           if param.operacao = "i" then
              select telcod
                into ws.telcod
                from datktel
               where datktel.telnom  =  ctc25m01.telnom

              if sqlca.sqlcode  <>  notfound   then
                 error " Ja' existe tela cadastrada com esse nome --> ",
                       ws.telcod  using "#&&&&"
                 next field telnom
              end if
           end if

    before field teldsc
           display by name ctc25m01.teldsc attribute (reverse)

    after  field teldsc
           display by name ctc25m01.teldsc

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field telnom
           end if

           if ctc25m01.teldsc is null  then
              error " Descricao da tela deve ser informada!"
              next field teldsc
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc25m01.*  to null
 end if

 return ctc25m01.*

 end function  ###  ctc25m01_input


#---------------------------------------------------------
 function ctc25m01_ler(param)
#---------------------------------------------------------

 define param         record
    telcod      like datktel.telcod
 end record

 define ctc25m01      record
   telcod             like datktel.telcod,
   telnom             like datktel.telnom,
   teldsc             like datktel.teldsc,
   atldat             like datktel.atldat,
   atlusrtip          like datktel.atlusrtip,
   atlmat             like datktel.atlmat,
   atlemp             like datktel.atlemp
 end record       

 define ws            record
    altemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    atlusrtip         like isskfunc.usrtip
 end record


 initialize ctc25m01.*   to null
 initialize ws.*         to null

 select telcod,
        telnom,
        teldsc,
        atldat,
        atlemp,
        atlmat,
        atlusrtip
   into ctc25m01.telcod,
        ctc25m01.telnom,
        ctc25m01.teldsc,
        ctc25m01.atldat,
        ws.altemp,
        ws.atlmat,
        ws.atlusrtip
   from datktel
  where telcod = param.telcod

 if sqlca.sqlcode = notfound  then
    error " Tela nao cadastrada!"
    initialize ctc25m01.*    to null
    return ctc25m01.*
 else

    call ctc25m01_func(ws.altemp, ws.atlmat, ws.atlusrtip)
         returning ws1.atlfunnom
 end if

 return ctc25m01.*

 end function  ###  ctc25m01_ler


#---------------------------------------------------------
 function ctc25m01_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat,
    atlusrtip         like isskfunc.usrtip
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
    and usrtip = param.atlusrtip

 return ws.funnom

 end function  ###  ctc25m01_func
