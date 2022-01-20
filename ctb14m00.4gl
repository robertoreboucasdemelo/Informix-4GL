############################################################################
# Nome do Modulo: CTB14M00                                        Marcelo  #
#                                                                Gilberto  #
#                                                                  Wagner  #
# Cadastro de Eventos de analise                                 Nov/1999  #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 21/03/2001  PSI 12768-0  Wagner       Incluir a manutencao do campo      #
#                                       codigo do assunto.                 #
#--------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto #
#                                      como sendo o agrupamento, buscar cod#
#                                      agrupamento.                        #
#--------------------------------------------------------------------------#
############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctb14m00()
#------------------------------------------------------------

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb14m00.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctb14m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctb14m00 at 4,2 with form "ctb14m00"

 menu "EVENTOS DE ANALISE"

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
                   "Pesquisa eventos de analise conforme criterios"
          call ctb14m00_seleciona()  returning d_ctb14m00.*
          if d_ctb14m00.c24evtcod    is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum evento de analise selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo evento de analise selecionado"
          message ""
          call ctb14m00_proximo(d_ctb14m00.c24evtcod)
               returning d_ctb14m00.*

 command key ("A") "Anterior"
                   "Mostra evento de analise anterior selecionado"
          message ""
          if d_ctb14m00.c24evtcod is not null then
             call ctb14m00_anterior(d_ctb14m00.c24evtcod)
                  returning d_ctb14m00.*
          else
             error " Nenhum evento de analise nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica evento de analise corrente selecionado"
          message ""
          if d_ctb14m00.c24evtcod  is not null then
             call ctb14m00_modifica(d_ctb14m00.c24evtcod, d_ctb14m00.*)
                  returning d_ctb14m00.*
             next option "Seleciona"
          else
             error " Nenhum evento de analise selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui evento de analise"
          message ""
          call ctb14m00_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove evento de analise corrente selecionado"
            message ""
            if d_ctb14m00.c24evtcod  is not null   then
               call ctb14m00_remove(d_ctb14m00.*)
                    returning d_ctb14m00.*
               next option "Seleciona"
            else
               error " Nenhum evento de analise selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb14m00

 end function  # ctb14m00


#------------------------------------------------------------
 function ctb14m00_seleciona()
#------------------------------------------------------------

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb14m00.*  to null
 display by name d_ctb14m00.*

 input by name d_ctb14m00.c24evtcod

    before field c24evtcod
        display by name d_ctb14m00.c24evtcod attribute (reverse)

        if d_ctb14m00.c24evtcod is null then
           let d_ctb14m00.c24evtcod = 0
        end if

    after  field c24evtcod
        display by name d_ctb14m00.c24evtcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb14m00.*   to null
    display by name d_ctb14m00.*
    error " Operacao cancelada!"
    clear form
    return d_ctb14m00.*
 end if

 if d_ctb14m00.c24evtcod = 0 then
    select min(c24evtcod)
      into d_ctb14m00.c24evtcod
      from datkevt
     where datkevt.c24evtcod > d_ctb14m00.c24evtcod
 end if

 call ctb14m00_ler(d_ctb14m00.c24evtcod)
      returning d_ctb14m00.*

 if d_ctb14m00.c24evtcod  is not null   then
    display by name  d_ctb14m00.*
   else
    error " Evento de analise nao cadastrado!"
    initialize d_ctb14m00.*    to null
 end if

 return d_ctb14m00.*

 end function  # ctb14m00_seleciona


#------------------------------------------------------------
 function ctb14m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24evtcod         like datkevt.c24evtcod
 end record

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
 initialize d_ctb14m00.*   to null

 if param.c24evtcod  is null   then
    let param.c24evtcod = 0
 end if

 select min(datkevt.c24evtcod)
   into d_ctb14m00.c24evtcod
   from datkevt
  where datkevt.c24evtcod  >  param.c24evtcod

 if d_ctb14m00.c24evtcod  is not null   then
    call ctb14m00_ler(d_ctb14m00.c24evtcod)
         returning d_ctb14m00.*

    if d_ctb14m00.c24evtcod  is not null   then
       display by name d_ctb14m00.*
    else
       error " Nao ha' evento de analise nesta direcao!"
       initialize d_ctb14m00.*    to null
    end if
 else
    error " Nao ha' evento de analise nesta direcao!"
    initialize d_ctb14m00.*    to null
 end if

 return d_ctb14m00.*

 end function    # ctb14m00_proximo


#------------------------------------------------------------
 function ctb14m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24evtcod         like datkevt.c24evtcod
 end record

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
 initialize d_ctb14m00.*  to null

 if param.c24evtcod  is null   then
    let param.c24evtcod = 0
 end if

 select max(datkevt.c24evtcod)
   into d_ctb14m00.c24evtcod
   from datkevt
  where datkevt.c24evtcod  <  param.c24evtcod

 if d_ctb14m00.c24evtcod  is not null   then

    call ctb14m00_ler(d_ctb14m00.c24evtcod)
         returning d_ctb14m00.*

    if d_ctb14m00.c24evtcod  is not null   then
       display by name  d_ctb14m00.*
    else
       error " Nao ha' evento de analise nesta direcao!"
       initialize d_ctb14m00.*    to null
    end if
 else
    error " Nao ha' evento de analise nesta direcao!"
    initialize d_ctb14m00.*    to null
 end if

 return d_ctb14m00.*

 end function    # ctb14m00_anterior


#------------------------------------------------------------
 function ctb14m00_modifica(param, d_ctb14m00)
#------------------------------------------------------------

 define param         record
    c24evtcod         like datkevt.c24evtcod
 end record

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    c24evtdes         char(150)
 end record


 call ctb14m00_input("a", d_ctb14m00.*) returning d_ctb14m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb14m00.*  to null
    display by name d_ctb14m00.*
    error " Operacao cancelada!"
    return d_ctb14m00.*
 end if

 whenever error continue

 let ws.c24evtdes      = d_ctb14m00.c24evtdes1,
                         d_ctb14m00.c24evtdes2,
                         d_ctb14m00.c24evtdes3
 let d_ctb14m00.atldat = today

 begin work
    update datkevt set  ( c24evtdes,
                          c24evtrdzdes,
                          c24fsecod,
                          c24astcod,
                          c24evtstt,
                          atldat,
                          atlemp,
                          atlmat )
                     =  ( ws.c24evtdes,
                          d_ctb14m00.c24evtrdzdes,
                          d_ctb14m00.c24fsecod,
                          d_ctb14m00.c24astcod,
                          d_ctb14m00.c24evtstt,
                          d_ctb14m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )
       where datkevt.c24evtcod  =  d_ctb14m00.c24evtcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do evento de analise!"
       rollback work
       initialize d_ctb14m00.*   to null
       return d_ctb14m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb14m00.*  to null
 display by name d_ctb14m00.*
 message ""
 return d_ctb14m00.*

 end function   #  ctb14m00_modifica


#------------------------------------------------------------
 function ctb14m00_inclui()
#------------------------------------------------------------

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws           record
    c24evtdes         char(150),
    resp              char(01)
 end record


 initialize d_ctb14m00.*   to null
 display by name d_ctb14m00.*

 call ctb14m00_input("i", d_ctb14m00.*) returning d_ctb14m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb14m00.*  to null
    display by name d_ctb14m00.*
    error " Operacao cancelada!"
    return
 end if

 let ws.c24evtdes      = d_ctb14m00.c24evtdes1,
                         d_ctb14m00.c24evtdes2,
                         d_ctb14m00.c24evtdes3
 let d_ctb14m00.atldat = today
 let d_ctb14m00.caddat = today

 declare c_ctb14m00m  cursor with hold  for
  select  max(c24evtcod)
    from  datkevt
   where  datkevt.c24evtcod > 0

 foreach c_ctb14m00m  into  d_ctb14m00.c24evtcod
     exit foreach
 end foreach

 if d_ctb14m00.c24evtcod is null   then
    let d_ctb14m00.c24evtcod = 0
 end if
 let d_ctb14m00.c24evtcod = d_ctb14m00.c24evtcod + 1


 whenever error continue

 begin work
    insert into datkevt ( c24evtcod,
                          c24evtdes,
                          c24evtrdzdes,
                          c24fsecod,
                          c24astcod,
                          c24evtstt,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat )
               values   ( d_ctb14m00.c24evtcod,
                          ws.c24evtdes,
                          d_ctb14m00.c24evtrdzdes,
                          d_ctb14m00.c24fsecod,
                          d_ctb14m00.c24astcod,
                          d_ctb14m00.c24evtstt,
                          d_ctb14m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          d_ctb14m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do evento de analise!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctb14m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb14m00.cadfunnom

 call ctb14m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb14m00.funnom

 display by name  d_ctb14m00.*

 display by name d_ctb14m00.c24evtcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.resp

 initialize d_ctb14m00.*  to null
 display by name d_ctb14m00.*

 end function   #  ctb14m00_inclui


#--------------------------------------------------------------------
 function ctb14m00_input(param, d_ctb14m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    c24evtcod         like datkevt.c24evtcod,
    c24astagp         like datkassunto.c24astagp      ##psi230650
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctb14m00.c24evtdes1,
               d_ctb14m00.c24evtdes2,
               d_ctb14m00.c24evtdes3,
               d_ctb14m00.c24evtrdzdes,
               d_ctb14m00.c24fsecod,
               d_ctb14m00.c24astcod,
               d_ctb14m00.c24evtstt  without defaults

    before field c24evtdes1
           display by name d_ctb14m00.c24evtdes1 attribute (reverse)

    after  field c24evtdes1
           display by name d_ctb14m00.c24evtdes1

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24evtdes1
           end if

           if d_ctb14m00.c24evtdes1  is null   then
              error " Descricao do evento deve ser informada!"
              next field c24evtdes1
           end if

    before field c24evtdes2
           display by name d_ctb14m00.c24evtdes2 attribute (reverse)

    after  field c24evtdes2
           display by name d_ctb14m00.c24evtdes2

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24evtdes1
           end if

    before field c24evtdes3
           display by name d_ctb14m00.c24evtdes3 attribute (reverse)

    after  field c24evtdes3
           display by name d_ctb14m00.c24evtdes3

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24evtdes2
           end if

    before field c24evtrdzdes
           display by name d_ctb14m00.c24evtrdzdes attribute (reverse)

    after  field c24evtrdzdes
           display by name d_ctb14m00.c24evtrdzdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24evtdes3
           end if

           if d_ctb14m00.c24evtrdzdes  is null   then
              error " Descricao resumida do evento deve ser informada!"
              next field c24evtrdzdes
           end if

    before field c24fsecod
           display by name d_ctb14m00.c24fsecod attribute (reverse)

    after  field c24fsecod
           display by name d_ctb14m00.c24fsecod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field c24evtrdzdes
           end if

           if d_ctb14m00.c24fsecod  is null   then
              error " Codigo da fase do evento deve ser informada!"
              call ctb15m02() returning d_ctb14m00.c24fsecod
              next field c24fsecod
           end if

           select c24fsedes
             into d_ctb14m00.c24fsedes
             from datkfse
            where c24fsecod = d_ctb14m00.c24fsecod

           if sqlca.sqlcode <> 0 then
              error " Codigo da fase nao cadastrado !"
              next field c24fsecod
           end if

           display by name d_ctb14m00.c24fsedes

    before field c24astcod
           display by name d_ctb14m00.c24astcod attribute (reverse)

    after  field c24astcod
           display by name d_ctb14m00.c24astcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field c24fsecod
           end if

           if d_ctb14m00.c24astcod  is null   then
              initialize  d_ctb14m00.c24astdes to null
           else
              #PSI 230650
              #Buscar agrupamento do assunto
              select c24astagp into ws.c24astagp
                 from datkassunto
                 where c24astcod = d_ctb14m00.c24astcod
              #if d_ctb14m00.c24astcod[1,1] <> "W" then
              if ws.c24astagp <> "W" then
                 error " Codigo da reclamacao deve ser 'W..' !"
                 next field c24astcod
              else
                 select c24astdes
                   into d_ctb14m00.c24astdes
                   from datkassunto
                  where c24astcod = d_ctb14m00.c24astcod

                 if sqlca.sqlcode <> 0 then
                    error " Codigo da reclamacao nao cadastrado !"
                    next field c24astcod
                 end if

                 select c24evtcod
                   into ws.c24evtcod
                   from datkevt
                  where c24evtcod <> d_ctb14m00.c24evtcod
                    and c24astcod =  d_ctb14m00.c24astcod

                 if sqlca.sqlcode = 0 then
                    error " Codigo da reclamacao ja' esta relacionado com o evento ",ws.c24evtcod," !"
                    next field c24astcod
                 end if
              end if
           end if

           display by name d_ctb14m00.c24astdes

    before field c24evtstt
           if param.operacao  =  "i"   then
              let d_ctb14m00.c24evtstt = "A"
           end if
           display by name d_ctb14m00.c24evtstt attribute (reverse)

    after  field c24evtstt
           display by name d_ctb14m00.c24evtstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24astcod
           end if

           if d_ctb14m00.c24evtstt  is null   or
             (d_ctb14m00.c24evtstt  <> "A"    and
              d_ctb14m00.c24evtstt  <> "C")   then
              error " Situacao do evento de analise deve ser: (A)tivo ou (C)ancelado!"
              next field c24evtstt
           end if

           if param.operacao        = "i"   and
              d_ctb14m00.c24evtstt  = "C"   then
              error " Nao deve ser incluido evento de analise com situacao (C)ancelado!"
              next field c24evtstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctb14m00.*  to null
 end if

 return d_ctb14m00.*

 end function   # ctb14m00_input


#--------------------------------------------------------------------
 function ctb14m00_remove(d_ctb14m00)
#--------------------------------------------------------------------

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o evento de analise"
            clear form
            initialize d_ctb14m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui evento de analise"
            call ctb14m00_ler(d_ctb14m00.c24evtcod) returning d_ctb14m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb14m00.* to null
               error " Evento de analise nao localizado!"
             else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datmsrvanlhst
                where datmsrvanlhst.c24evtcod = d_ctb14m00.c24evtcod

               if ws.count > 0 then
                  error " Evento possui historico(s) cadastrado(s), portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkevt
                   where datkevt.c24evtcod = d_ctb14m00.c24evtcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctb14m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exclusao do evento de analise!"
               else
                  initialize d_ctb14m00.* to null
                  error   " Evento de analise excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctb14m00.*

end function    # ctb14m00_remove


#---------------------------------------------------------
 function ctb14m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24evtcod         like datkevt.c24evtcod
 end record

 define d_ctb14m00    record
    c24evtcod         like datkevt.c24evtcod,
    c24evtdes1        char(50),
    c24evtdes2        char(50),
    c24evtdes3        char(50),
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datkevt.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24astcod         like datkevt.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24evtstt         like datkevt.c24evtstt,
    caddat            like datkevt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkevt.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    c24evtdes         char(150),
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctb14m00.*   to null
 initialize ws.*           to null

 select  c24evtcod,
         c24evtdes,
         c24evtrdzdes,
         c24fsecod,
         c24astcod,
         c24evtstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctb14m00.c24evtcod,
         ws.c24evtdes,
         d_ctb14m00.c24evtrdzdes,
         d_ctb14m00.c24fsecod,
         d_ctb14m00.c24astcod,
         d_ctb14m00.c24evtstt,
         d_ctb14m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctb14m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkevt
  where  datkevt.c24evtcod = param.c24evtcod

 if sqlca.sqlcode = notfound   then
    error " Evento de analise nao cadastrado!"
    initialize d_ctb14m00.*    to null
    return d_ctb14m00.*
 end if

 select c24fsedes
   into d_ctb14m00.c24fsedes
   from datkfse
  where datkfse.c24fsecod = d_ctb14m00.c24fsecod

 select c24astdes
   into d_ctb14m00.c24astdes
   from datkassunto
  where datkassunto.c24astcod = d_ctb14m00.c24astcod

 call ctb14m00_func(ws.cademp, ws.cadmat)
      returning d_ctb14m00.cadfunnom

 call ctb14m00_func(ws.atlemp, ws.atlmat)
      returning d_ctb14m00.funnom


 let d_ctb14m00.c24evtdes1 = ws.c24evtdes[001,050]
 let d_ctb14m00.c24evtdes2 = ws.c24evtdes[051,100]
 let d_ctb14m00.c24evtdes3 = ws.c24evtdes[101,150]

 return d_ctb14m00.*

 end function   # ctb14m00_ler


#---------------------------------------------------------
 function ctb14m00_func(param)
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

 end function   # ctb14m00_func
