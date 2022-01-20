###########################################################################
# Nome do Modulo: ctc15m00                                       Marcelo  #
#                                                                Gilberto #
# Cadastro de tipos de servicos                                  Abr/1998 #
###########################################################################
# 14/06/2000  PSI 10865-0  Ruiz         Troca do campo atdtip p/ atdsrvorg#
#-------------------------------------------------------------------------#
# 22/06/2001  Arnaldo      Ruiz         Gravar atdtip="X" para evitar     #
#                                       queda de tela.                    #
#-------------------------------------------------------------------------#
 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc15m00()
#------------------------------------------------------------

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record

 let int_flag = false
 initialize ctc15m00.*  to null

 open window ctc15m00 at 04,02 with form "ctc15m00"


 menu "TIPOS SERVICOS"

 before menu
      hide option all
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui",
                  "assistenCias", "eTapas" , "Limites"
     #if g_issk.dptsgl = "desenv"  then
     #   show option "Inclui"
     #end if
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa tipo de servico conforme criterios"
          call ctc15m00_seleciona()  returning ctc15m00.*
          if ctc15m00.atdsrvorg  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum tipo de servico selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo tipo de servico"
          message ""
          call ctc15m00_proximo(ctc15m00.atdsrvorg)
               returning ctc15m00.*

 command key ("A") "Anterior"
                   "Mostra tipo de servico anterior"
          message ""
          if ctc15m00.atdsrvorg is not null then
             call ctc15m00_anterior(ctc15m00.atdsrvorg)
                  returning ctc15m00.*
          else
             error " Nenhum tipo de servico nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica tipo de servico selecionado"
          message ""
          if ctc15m00.atdsrvorg  is not null then
             call ctc15m00_modifica(ctc15m00.atdsrvorg, ctc15m00.*)
                  returning ctc15m00.*
             next option "Seleciona"
          else
             error " Nenhum tipo de servico selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui tipo de servico"
          message ""
          call ctc15m00_inclui()
          next option "Seleciona"

 command key ("C") "assistenCias"
                   "Assistencias oferecidas ao tipo de servico"
          message ""
          if ctc15m00.atdsrvorg  is not null then
             call ctc15m02(ctc15m00.atdsrvorg)
             next option "Seleciona"
          else
             error " Nenhum tipo de servico selecionado!"
             next option "Seleciona"
          end if

 command key ("T") "eTapas"
                   "Etapas para acompanhamento do tipo de servico"
          message ""
          if ctc15m00.atdsrvorg  is not null then
             call ctc15m04(ctc15m00.atdsrvorg)
             next option "Seleciona"
          else
             error " Nenhum tipo de servico selecionado!"
             next option "Seleciona"
          end if

#command key ("R") "Remove"
#                  "Remove tipo de servico"
#         message ""
#         if ctc15m00.atdsrvorg  is not null then
#            call ctc15m00_remove(ctc15m00.atdsrvorg)
#            next option "Seleciona"
#         else
#            error " Nenhum tipo de servico selecionado!"
#            next option "Seleciona"
#         end if
 command key ("L") "Limites"           "Manutencao de Limites para assistencia"
         message ""
          if ctc15m00.atdsrvorg  is not null then
             call ctc15m07(ctc15m00.atdsrvorg)
             next option "Seleciona"
          else
             error " Nenhum tipo de servico selecionado!"
             next option "Seleciona"
          end if
       
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc15m00

 end function  ###  ctc15m00

#------------------------------------------------------------
 function ctc15m00_seleciona()
#------------------------------------------------------------

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record


 let int_flag = false
 initialize ctc15m00.*  to null
 display by name ctc15m00.*

 input by name ctc15m00.atdsrvorg

    before field atdsrvorg
        display by name ctc15m00.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name ctc15m00.atdsrvorg

        if ctc15m00.atdsrvorg is null  then
           select min(atdsrvorg)
             into ctc15m00.atdsrvorg
             from datksrvtip

           if ctc15m00.atdsrvorg is null  then
              error " Nao existe nenhum tipo de servico cadastrado!"
              exit input
           end if
        end if

        select atdsrvorg
          from datksrvtip
         where atdsrvorg = ctc15m00.atdsrvorg

        if sqlca.sqlcode = notfound  then
           error " Tipo de servico nao cadastrado!"
           next field atdsrvorg
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc15m00.*   to null
    display by name ctc15m00.*
    error " Operacao cancelada!"
    return ctc15m00.*
 end if

 call ctc15m00_ler(ctc15m00.atdsrvorg)
      returning ctc15m00.*

 if ctc15m00.atdsrvorg  is not null   then
    display by name  ctc15m00.*
 else
    error " Tipo de servico nao cadastrado!"
    initialize ctc15m00.*    to null
 end if

 return ctc15m00.*

 end function  ###  ctc15m00_seleciona

#------------------------------------------------------------
 function ctc15m00_proximo(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg            like datksrvtip.atdsrvorg
 end record

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record


 let int_flag = false
 initialize ctc15m00.*   to null

 if param.atdsrvorg  is null   then
    let param.atdsrvorg = " "
 end if

 select min(datksrvtip.atdsrvorg)
   into ctc15m00.atdsrvorg
   from datksrvtip
  where atdsrvorg  >  param.atdsrvorg

 if ctc15m00.atdsrvorg is not null  then

    call ctc15m00_ler(ctc15m00.atdsrvorg)
         returning ctc15m00.*

    if ctc15m00.atdsrvorg is not null  then
       display by name ctc15m00.*
    else
       error " Nao ha' nenhum tipo de servico nesta direcao!"
       initialize ctc15m00.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de servico nesta direcao!"
    initialize ctc15m00.*    to null
 end if

 return ctc15m00.*

 end function  ###  ctc15m00_proximo

#------------------------------------------------------------
 function ctc15m00_anterior(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg            like datksrvtip.atdsrvorg
 end record

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record


 let int_flag = false
 initialize ctc15m00.*  to null

 if param.atdsrvorg  is null   then
    let param.atdsrvorg = " "
 end if

 select max(datksrvtip.atdsrvorg)
   into ctc15m00.atdsrvorg
   from datksrvtip
  where atdsrvorg  <  param.atdsrvorg

 if ctc15m00.atdsrvorg  is not null   then
    call ctc15m00_ler(ctc15m00.atdsrvorg)
         returning ctc15m00.*

    if ctc15m00.atdsrvorg  is not null   then
       display by name ctc15m00.*
    else
       error " Nao ha' nenhum tipo de servico nesta direcao!"
       initialize ctc15m00.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de servico nesta direcao!"
    initialize ctc15m00.*    to null
 end if

 return ctc15m00.*

 end function  ###  ctc15m00_anterior

#------------------------------------------------------------
 function ctc15m00_modifica(param, ctc15m00)
#------------------------------------------------------------

 define param         record
    atdsrvorg            like datksrvtip.atdsrvorg
 end record

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record


 call ctc15m00_input("a", ctc15m00.*) returning ctc15m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m00.*  to null
    display by name ctc15m00.*
    error " Operacao cancelada!"
    return ctc15m00.*
 end if

 whenever error continue

 let ctc15m00.atldat = today

 update datksrvtip set  ( srvtipabvdes,
                          srvtipdes,
                          atldat,
                          atlemp,
                          atlmat )
                     =  ( ctc15m00.srvtipabvdes,
                          ctc15m00.srvtipdes,
                          ctc15m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )
                 where atdsrvorg  =  ctc15m00.atdsrvorg

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do tipo de servico!"
    initialize ctc15m00.*   to null
    return ctc15m00.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize ctc15m00.*  to null
 display by name ctc15m00.*
 message ""
 return ctc15m00.*

 end function  ###  ctc15m00_modifica

#------------------------------------------------------------
 function ctc15m00_inclui()
#------------------------------------------------------------

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record

 define prompt_key    char (01)

 initialize ctc15m00.*   to null
 display by name ctc15m00.*

 call ctc15m00_input("i", ctc15m00.*) returning ctc15m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m00.*  to null
    display by name ctc15m00.*
    error " Operacao cancelada!"
    return
 end if

 let ctc15m00.atldat = today
 let ctc15m00.caddat = today

 whenever error continue

 insert into datksrvtip ( atdsrvorg,
                          srvtipabvdes,
                          srvtipdes,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat,
                          atdtip,
                          agdlimqtd )
                 values ( ctc15m00.atdsrvorg,
                          ctc15m00.srvtipabvdes,
                          ctc15m00.srvtipdes,
                          ctc15m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          ctc15m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat,
                          "C",
                          0 )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do tipo de servico!"
    return
 end if

 whenever error stop

 call ctc15m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m00.cadfunnom

 call ctc15m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc15m00.atlfunnom

 display by name ctc15m00.*

 display by name ctc15m00.atdsrvorg attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc15m00.*  to null
 display by name ctc15m00.*

 end function  ###  ctc15m00_inclui

#------------------------------------------------------------
 function ctc15m00_remove(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg            like datksrvtip.atdsrvorg
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do tipo de servico."
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui tipo de servico"
       whenever error continue

       delete from datksrvtip
        where atdsrvorg = param.atdsrvorg

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao do tipo de servico!"
       else
          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc15m00_remove

#--------------------------------------------------------------------
 function ctc15m00_input(param, ctc15m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record

 define ws            record
        seq           smallint
 end record


 let int_flag = false
 let ws.seq   = 0

 if param.operacao = "i"  then
    select max(atdsrvorg)
        into ws.seq
        from datksrvtip
    if  ws.seq  = 0  then
        let ws.seq = 1
    else
        let ws.seq = ws.seq + 1
    end if
 end if

 input by name ctc15m00.atdsrvorg   ,
               ctc15m00.srvtipabvdes,
               ctc15m00.srvtipdes      without defaults

    before field atdsrvorg
           if param.operacao = "a"  then
              next field srvtipabvdes
           end if
           let ctc15m00.atdsrvorg = ws.seq
           display by name ctc15m00.atdsrvorg    attribute (reverse)
           next field srvtipabvdes

    after  field atdsrvorg
           display by name ctc15m00.atdsrvorg

           select atdsrvorg
             from datksrvtip
            where atdsrvorg = ctc15m00.atdsrvorg

           if sqlca.sqlcode = 0  then
              error " Origem do servico ja' cadastrado!"
              next field atdsrvorg
           end if

    before field srvtipabvdes
           display by name ctc15m00.srvtipabvdes attribute (reverse)

    after  field srvtipabvdes
           display by name ctc15m00.srvtipabvdes

           if ctc15m00.srvtipabvdes is null  then
              error " Descricao abreviada deve ser informada!"
              next field srvtipabvdes
           end if

    before field srvtipdes
           display by name ctc15m00.srvtipdes attribute (reverse)

    after  field srvtipdes
           display by name ctc15m00.srvtipdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srvtipabvdes
           end if

           if ctc15m00.srvtipdes is null  then
              error " Descricao completa deve ser informada!"
              next field srvtipdes
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc15m00.*  to null
 end if

 return ctc15m00.*

 end function  ###  ctc15m00_input

#---------------------------------------------------------
 function ctc15m00_ler(param)
#---------------------------------------------------------

 define param         record
    atdsrvorg            like datksrvtip.atdsrvorg
 end record

 define ctc15m00      record
    atdsrvorg            like datksrvtip.atdsrvorg,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    srvtipdes         like datksrvtip.srvtipdes,
    caddat            like datksrvtip.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvtip.atldat,
    atlfunnom         like isskfunc.funnom ,
    obs               char (60)
 end record

 define ws            record
    asiqtd            smallint            ,
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc15m00.*   to null
 initialize ws.*         to null

 select atdsrvorg,
        srvtipabvdes,
        srvtipdes,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat
   into ctc15m00.atdsrvorg,
        ctc15m00.srvtipabvdes,
        ctc15m00.srvtipdes,
        ctc15m00.caddat,
        ws.cademp,
        ws.cadmat,
        ctc15m00.atldat,
        ws.atlemp,
        ws.atlmat
   from datksrvtip
  where atdsrvorg = param.atdsrvorg

 if sqlca.sqlcode = notfound  then
    error " Tipo de servico nao cadastrado!"
    initialize ctc15m00.*    to null
    return ctc15m00.*
 else
    call ctc15m00_func(ws.cademp, ws.cadmat)
         returning ctc15m00.cadfunnom

    call ctc15m00_func(ws.atlemp, ws.atlmat)
         returning ctc15m00.atlfunnom
 end if

 select count(*)
   into ws.asiqtd
   from datrasitipsrv
  where atdsrvorg = param.atdsrvorg

 if ws.asiqtd > 0  then
    let ctc15m00.obs =  "EXISTE(M) ", ws.asiqtd using "<<<,<<<", " TIPO(S) DE ASSISTENCIA PARA ESTE TIPO DE SERVICO"
 else
    let ctc15m00.obs =  "NAO EXISTE TIPO DE ASSISTENCIA PARA ESTE TIPO DE SERVICO"
 end if

 return ctc15m00.*

 end function  ###  ctc15m00_ler

#---------------------------------------------------------
 function ctc15m00_func(param)
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
  and   empcod = param.empcod
 return ws.funnom

 end function  ###  ctc15m00_func
