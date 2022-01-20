###########################################################################
# Nome do Modulo: CTB15M00                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Cadastro de Fases de analise                                   Nov/1999 #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctb15m00()
#-----------------------------------------------------------

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb15m00.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctb15m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctb15m00 at 4,2 with form "ctb15m00"

 menu "FASE DE ANALISE"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "aUtorizacoes", "Remove"
     end if
     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa fase de analise conforme criterios"
          call ctb15m00_seleciona()  returning d_ctb15m00.*
          if d_ctb15m00.c24fsecod    is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma fase de analise selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima fase de analise selecionada"
          message ""
          call ctb15m00_proximo(d_ctb15m00.c24fsecod)
               returning d_ctb15m00.*

 command key ("A") "Anterior"
                   "Mostra fase de analise anterior selecionada"
          message ""
          if d_ctb15m00.c24fsecod is not null then
             call ctb15m00_anterior(d_ctb15m00.c24fsecod)
                  returning d_ctb15m00.*
          else
             error " Nenhuma fase de analise nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica fase de analise corrente selecionada"
          message ""
          if d_ctb15m00.c24fsecod  is not null then
             call ctb15m00_modifica(d_ctb15m00.c24fsecod, d_ctb15m00.*)
                  returning d_ctb15m00.*
             next option "Seleciona"
          else
             error " Nenhuma fase de analise selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui fase de analise"
          message ""
          call ctb15m00_inclui()
          next option "Seleciona"

 command key ("U") "aUtorizacoes"
                   "Matriculas autorizadas para manutencao de fases"
          message ""
          if d_ctb15m00.c24fsecod  is not null then
             call ctb15m01(d_ctb15m00.c24fsecod)
             next option "Seleciona"
          else
             error " Nenhuma fase de analise selecionada!"
             next option "Seleciona"
          end if

 command key ("R") "Remove"
                   "Remove fase de analise corrente selecionada"
            message ""
            if d_ctb15m00.c24fsecod  is not null   then
               call ctb15m00_remove(d_ctb15m00.*)
                    returning d_ctb15m00.*
               next option "Seleciona"
            else
               error " Nenhuma fase de analise selecionada!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb15m00

 end function  # ctb15m00


#------------------------------------------------------------
 function ctb15m00_seleciona()
#------------------------------------------------------------

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb15m00.*  to null
 display by name d_ctb15m00.*

 input by name d_ctb15m00.c24fsecod

    before field c24fsecod
        display by name d_ctb15m00.c24fsecod attribute (reverse)

        if d_ctb15m00.c24fsecod is null then
           let d_ctb15m00.c24fsecod = 0
        end if

    after  field c24fsecod
        display by name d_ctb15m00.c24fsecod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb15m00.*   to null
    display by name d_ctb15m00.*
    error " Operacao cancelada!"
    clear form
    return d_ctb15m00.*
 end if

 if d_ctb15m00.c24fsecod = 0 then
    select min(c24fsecod)
      into d_ctb15m00.c24fsecod
      from datkfse
     where datkfse.c24fsecod > d_ctb15m00.c24fsecod
 end if

 call ctb15m00_ler(d_ctb15m00.c24fsecod)
      returning d_ctb15m00.*

 if d_ctb15m00.c24fsecod  is not null   then
    display by name  d_ctb15m00.*
   else
    error " Fase de analise nao cadastrada!"
    initialize d_ctb15m00.*    to null
 end if

 return d_ctb15m00.*

 end function  # ctb15m00_seleciona


#------------------------------------------------------------
 function ctb15m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24fsecod         like datkfse.c24fsecod
 end record

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb15m00.*   to null

 if param.c24fsecod  is null   then
    let param.c24fsecod = 0
 end if

 select min(datkfse.c24fsecod)
   into d_ctb15m00.c24fsecod
   from datkfse
  where datkfse.c24fsecod  >  param.c24fsecod

 if d_ctb15m00.c24fsecod  is not null   then

    call ctb15m00_ler(d_ctb15m00.c24fsecod)
         returning d_ctb15m00.*

    if d_ctb15m00.c24fsecod  is not null   then
       display by name d_ctb15m00.*
    else
       error " Nao ha' fase de analise nesta direcao!"
       initialize d_ctb15m00.*    to null
    end if
 else
    error " Nao ha' fase de analise nesta direcao!"
    initialize d_ctb15m00.*    to null
 end if

 return d_ctb15m00.*

 end function    # ctb15m00_proximo


#------------------------------------------------------------
 function ctb15m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24fsecod         like datkfse.c24fsecod
 end record

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb15m00.*  to null

 if param.c24fsecod  is null   then
    let param.c24fsecod = 0
 end if

 select max(datkfse.c24fsecod)
   into d_ctb15m00.c24fsecod
   from datkfse
  where datkfse.c24fsecod  <  param.c24fsecod

 if d_ctb15m00.c24fsecod  is not null   then

    call ctb15m00_ler(d_ctb15m00.c24fsecod)
         returning d_ctb15m00.*

    if d_ctb15m00.c24fsecod  is not null   then
       display by name  d_ctb15m00.*
    else
       error " Nao ha' fase de analise nesta direcao!"
       initialize d_ctb15m00.*    to null
    end if
 else
    error " Nao ha' fase de analise nesta direcao!"
    initialize d_ctb15m00.*    to null
 end if

 return d_ctb15m00.*

 end function    # ctb15m00_anterior


#------------------------------------------------------------
 function ctb15m00_modifica(param, d_ctb15m00)
#------------------------------------------------------------

 define param         record
    c24fsecod         like datkfse.c24fsecod
 end record

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctb15m00_input("a", d_ctb15m00.*) returning d_ctb15m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb15m00.*  to null
    display by name d_ctb15m00.*
    error " Operacao cancelada!"
    return d_ctb15m00.*
 end if

 whenever error continue

 let d_ctb15m00.atldat = today

 begin work
    update datkfse set  ( c24fsedes,
                          atldat,
                          atlemp,
                          atlmat )
                     =  ( d_ctb15m00.c24fsedes,
                          d_ctb15m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )
      where datkfse.c24fsecod  =  d_ctb15m00.c24fsecod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do fase de analise!"
       rollback work
       initialize d_ctb15m00.*   to null
       return d_ctb15m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb15m00.*  to null
 display by name d_ctb15m00.*
 message ""
 return d_ctb15m00.*

 end function   #  ctb15m00_modifica


#------------------------------------------------------------
 function ctb15m00_inclui()
#------------------------------------------------------------

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws           record
    resp              char(01)
 end record


 initialize d_ctb15m00.*   to null
 display by name d_ctb15m00.*

 call ctb15m00_input("i", d_ctb15m00.*) returning d_ctb15m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb15m00.*  to null
    display by name d_ctb15m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctb15m00.atldat = today
 let d_ctb15m00.caddat = today

 declare c_ctb15m00m  cursor with hold  for
  select  max(c24fsecod)
    from  datkfse
   where  datkfse.c24fsecod > 0

 foreach c_ctb15m00m  into  d_ctb15m00.c24fsecod
    exit foreach
 end foreach

 if d_ctb15m00.c24fsecod is null   then
    let d_ctb15m00.c24fsecod = 0
 end if
 let d_ctb15m00.c24fsecod = d_ctb15m00.c24fsecod + 1


 whenever error continue

 begin work
    insert into datkfse ( c24fsecod,
                          c24fsedes,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat )
               values   ( d_ctb15m00.c24fsecod,
                          d_ctb15m00.c24fsedes,
                          d_ctb15m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          d_ctb15m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )

   if sqlca.sqlcode <>  0   then
      error " Erro (",sqlca.sqlcode,") na Inclusao da fase de analise!"
      rollback work
      return
   end if

 commit work

 whenever error stop

 call ctb15m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb15m00.cadfunnom

 call ctb15m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb15m00.funnom

 display by name  d_ctb15m00.*

 display by name d_ctb15m00.c24fsecod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.resp

 initialize d_ctb15m00.*  to null
 display by name d_ctb15m00.*

 end function   #  ctb15m00_inclui


#--------------------------------------------------------------------
 function ctb15m00_input(param, d_ctb15m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    c24fsecod         like datkfse.c24fsecod
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctb15m00.c24fsedes  without defaults

    before field c24fsedes
           display by name d_ctb15m00.c24fsedes attribute (reverse)

    after  field c24fsedes
           display by name d_ctb15m00.c24fsedes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24fsedes
           end if

           if d_ctb15m00.c24fsedes  is null   then
              error " c24fsedes da fase deve ser informada!"
              next field c24fsedes
           end if


    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctb15m00.*  to null
 end if

 return d_ctb15m00.*

 end function   # ctb15m00_input


#--------------------------------------------------------------------
 function ctb15m00_remove(d_ctb15m00)
#--------------------------------------------------------------------

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui fase de analise"
            clear form
            initialize d_ctb15m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui fase de analise"
            call ctb15m00_ler(d_ctb15m00.c24fsecod) returning d_ctb15m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb15m00.* to null
               error " Fase de analise nao localizada!"
             else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datkevt
                where datkevt.c24fsecod = d_ctb15m00.c24fsecod

               if ws.count > 0 then
                  error " Fase possui evento(s) cadastrado(s), portanto nao deve ser removida!"
                  exit menu
               end if

               begin work
                  delete from datkfse
                   where datkfse.c24fsecod = d_ctb15m00.c24fsecod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctb15m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao da fase de analise!"
               else
                  initialize d_ctb15m00.* to null
                  error   " Fase de analise excluida!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctb15m00.*

end function    # ctb15m00_remove


#---------------------------------------------------------
 function ctb15m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24fsecod         like datkfse.c24fsecod
 end record

 define d_ctb15m00    record
    c24fsecod         like datkfse.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    caddat            like datkfse.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfse.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctb15m00.*   to null
 initialize ws.*           to null

 select  c24fsecod,
         c24fsedes,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctb15m00.c24fsecod,
         d_ctb15m00.c24fsedes,
         d_ctb15m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctb15m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkfse
  where  datkfse.c24fsecod = param.c24fsecod

 if sqlca.sqlcode = notfound   then
    error " Fase de analise nao cadastrada!"
    initialize d_ctb15m00.*    to null
    return d_ctb15m00.*
 else
    call ctb15m00_func(ws.cademp, ws.cadmat)
         returning d_ctb15m00.cadfunnom

    call ctb15m00_func(ws.atlemp, ws.atlmat)
         returning d_ctb15m00.funnom
 end if

 return d_ctb15m00.*

 end function   # ctb15m00_ler


#---------------------------------------------------------
 function ctb15m00_func(param)
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

 end function   # ctb15m00_func
