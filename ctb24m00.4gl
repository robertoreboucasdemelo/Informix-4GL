###########################################################################
# Nome do Modulo: CTB24M00                                         Wagner #
#                                                                         #
# Cadastro de Motivos de retorno                                 Set/2002 #
###########################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctb24m00()
#------------------------------------------------------------

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb24m00.*  to null

# if not get_niv_mod(g_issk.prgsgl, "ctb24m00") then
#   error " Modulo sem nivel de consulta e atualizacao!"
#   return
#end if

 open window ctb24m00 at 4,2 with form "ctb24m00"

 menu "RETORNO" 

  before menu
     hide option all
#    if g_issk.acsnivcod >= g_issk.acsnivcns  then
#       show option "Seleciona", "Proximo", "Anterior"
#    end if
#    if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
#    end if
     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa motivo retorno conforme criterios"
          call ctb24m00_seleciona()  returning d_ctb24m00.*
          if d_ctb24m00.srvretmtvcod    is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum motivo retorno selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo motivo retorno selecionado"
          message ""
          if d_ctb24m00.srvretmtvcod is not null then
             call ctb24m00_proximo(d_ctb24m00.srvretmtvcod)
                         returning d_ctb24m00.*
          else
             error " Nenhum motivo retorno nesta direcao!"
             next option "Seleciona"
          end if

 command key ("A") "Anterior"
                   "Mostra motivo retorno anterior selecionado"
          message ""
          if d_ctb24m00.srvretmtvcod is not null then
             call ctb24m00_anterior(d_ctb24m00.srvretmtvcod)
                  returning d_ctb24m00.*
          else
             error " Nenhum motivo retorno nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica motivo retorno corrente selecionado"
          message ""
          if d_ctb24m00.srvretmtvcod  is not null then
             call ctb24m00_modifica(d_ctb24m00.srvretmtvcod, d_ctb24m00.*)
                  returning d_ctb24m00.*
             next option "Seleciona"
          else
             error " Nenhum motivo retorno selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui motivo retorno"
          message ""
          call ctb24m00_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove motivo retorno corrente selecionado"
            message ""
            if d_ctb24m00.srvretmtvcod  is not null   then
               call ctb24m00_remove(d_ctb24m00.*)
                    returning d_ctb24m00.*
               next option "Seleciona"
            else
               error " Nenhum motivo retorno selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb24m00

 end function  # ctb24m00


#------------------------------------------------------------
 function ctb24m00_seleciona()
#------------------------------------------------------------

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb24m00.*  to null
 display by name d_ctb24m00.*

 input by name d_ctb24m00.srvretmtvcod

    before field srvretmtvcod
        display by name d_ctb24m00.srvretmtvcod attribute (reverse)

        if d_ctb24m00.srvretmtvcod is null then
           let d_ctb24m00.srvretmtvcod = 0
        end if

    after  field srvretmtvcod
        display by name d_ctb24m00.srvretmtvcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb24m00.*   to null
    display by name d_ctb24m00.*
    error " Operacao cancelada!"
    clear form
    return d_ctb24m00.*
 end if

 if d_ctb24m00.srvretmtvcod = 0 then
    select min(srvretmtvcod)
      into d_ctb24m00.srvretmtvcod
      from datksrvret
     where datksrvret.srvretmtvcod > d_ctb24m00.srvretmtvcod
 end if

 call ctb24m00_ler(d_ctb24m00.srvretmtvcod)
      returning d_ctb24m00.*

 if d_ctb24m00.srvretmtvcod  is not null   then
    display by name  d_ctb24m00.*
   else
    error " Motivo nao cadastrado!"
    initialize d_ctb24m00.*    to null
 end if

 return d_ctb24m00.*

 end function  # ctb24m00_seleciona


#------------------------------------------------------------
 function ctb24m00_proximo(param)
#------------------------------------------------------------

 define param         record
    srvretmtvcod      like datksrvret.srvretmtvcod
 end record

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctb24m00.*   to null

 if param.srvretmtvcod  is null   then
    let param.srvretmtvcod = 0
 end if

 select min(datksrvret.srvretmtvcod)
   into d_ctb24m00.srvretmtvcod
   from datksrvret
  where datksrvret.srvretmtvcod  >  param.srvretmtvcod

 if d_ctb24m00.srvretmtvcod  is not null   then
    call ctb24m00_ler(d_ctb24m00.srvretmtvcod)
         returning d_ctb24m00.*

    if d_ctb24m00.srvretmtvcod  is not null   then
       display by name d_ctb24m00.*
    else
       error " Nao ha' motivo retorno nesta direcao!"
       initialize d_ctb24m00.*    to null
    end if
 else
    error " Nao ha' motivo retorno nesta direcao!"
    initialize d_ctb24m00.*    to null
 end if

 return d_ctb24m00.*

 end function    # ctb24m00_proximo


#------------------------------------------------------------
 function ctb24m00_anterior(param)
#------------------------------------------------------------

 define param         record
    srvretmtvcod      like datksrvret.srvretmtvcod
 end record

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
 initialize d_ctb24m00.*  to null

 if param.srvretmtvcod  is null   then
    let param.srvretmtvcod = 0
 end if

 select max(datksrvret.srvretmtvcod)
   into d_ctb24m00.srvretmtvcod
   from datksrvret
  where datksrvret.srvretmtvcod  <  param.srvretmtvcod

 if d_ctb24m00.srvretmtvcod  is not null   then

    call ctb24m00_ler(d_ctb24m00.srvretmtvcod)
         returning d_ctb24m00.*

    if d_ctb24m00.srvretmtvcod  is not null   then
       display by name  d_ctb24m00.*
    else
       error " Nao ha' motivo retorno nesta direcao!"
       initialize d_ctb24m00.*    to null
    end if
 else
    error " Nao ha' motivo retorno nesta direcao!"
    initialize d_ctb24m00.*    to null
 end if

 return d_ctb24m00.*

 end function    # ctb24m00_anterior


#------------------------------------------------------------
 function ctb24m00_modifica(param, d_ctb24m00)
#------------------------------------------------------------

 define param         record
    srvretmtvcod      like datksrvret.srvretmtvcod
 end record

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctb24m00_input("a", d_ctb24m00.*) returning d_ctb24m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb24m00.*  to null
    display by name d_ctb24m00.*
    error " Operacao cancelada!"
    return d_ctb24m00.*
 end if

 whenever error continue

 let d_ctb24m00.atldat = today

 begin work
    update datksrvret set  ( srvretmtvdes,
                             atldat,
                             atlemp,
                             atlmat,
                             atlusrtip )
                        =  ( d_ctb24m00.srvretmtvdes,
                             d_ctb24m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat,
                             g_issk.usrtip )
       where datksrvret.srvretmtvcod  =  d_ctb24m00.srvretmtvcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do motivo retorno!"
       rollback work
       initialize d_ctb24m00.*   to null
       return d_ctb24m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb24m00.*  to null
 display by name d_ctb24m00.*
 message ""
 return d_ctb24m00.*

 end function   #  ctb24m00_modifica


#------------------------------------------------------------
 function ctb24m00_inclui()
#------------------------------------------------------------

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws           record
    confirma          char(01)
 end record


 initialize d_ctb24m00.*   to null
 display by name d_ctb24m00.*

 call ctb24m00_input("i", d_ctb24m00.*) returning d_ctb24m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb24m00.*  to null
    display by name d_ctb24m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctb24m00.atldat = today
 let d_ctb24m00.caddat = today

 select  max(srvretmtvcod)
   into  d_ctb24m00.srvretmtvcod
   from  datksrvret
  where  datksrvret.srvretmtvcod > 0

 if d_ctb24m00.srvretmtvcod is null   then
    let d_ctb24m00.srvretmtvcod = 0
 end if
 let d_ctb24m00.srvretmtvcod = d_ctb24m00.srvretmtvcod + 1


 whenever error continue

 begin work
    insert into datksrvret ( srvretmtvcod,
                             srvretmtvdes,
                             caddat,
                             cademp,
                             cadmat,
                             cadusrtip,
                             atldat,
                             atlemp,
                             atlmat,  
                             atlusrtip )
                  values   ( d_ctb24m00.srvretmtvcod,
                             d_ctb24m00.srvretmtvdes,
                             d_ctb24m00.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             g_issk.usrtip,  
                             d_ctb24m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat, 
                             g_issk.usrtip )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do motivo retorno!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctb24m00_func(g_issk.empcod, g_issk.funmat, g_issk.usrtip )
      returning d_ctb24m00.cadfunnom

 call ctb24m00_func(g_issk.empcod, g_issk.funmat, g_issk.usrtip )
      returning d_ctb24m00.funnom

 display by name  d_ctb24m00.*

 display by name d_ctb24m00.srvretmtvcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.confirma

 initialize d_ctb24m00.*  to null
 display by name d_ctb24m00.*

 end function   #  ctb24m00_inclui


#--------------------------------------------------------------------
 function ctb24m00_input(param, d_ctb24m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    srvretmtvcod      like datksrvret.srvretmtvcod
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctb24m00.srvretmtvdes  without defaults

    before field srvretmtvdes
           display by name d_ctb24m00.srvretmtvdes attribute (reverse)

    after  field srvretmtvdes
           display by name d_ctb24m00.srvretmtvdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srvretmtvdes
           end if

           if d_ctb24m00.srvretmtvdes  is null   then
              error " Descricao do motivo retorno  deve ser informada!"
              next field srvretmtvdes
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctb24m00.*  to null
 end if

 return d_ctb24m00.*

 end function   # ctb24m00_input


#--------------------------------------------------------------------
 function ctb24m00_remove(d_ctb24m00)
#--------------------------------------------------------------------

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    count             integer
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o motivo retorno"
            clear form
            initialize d_ctb24m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui motivo retorno"
            call ctb24m00_ler(d_ctb24m00.srvretmtvcod) returning d_ctb24m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb24m00.* to null
               error " Motivo nao localizado!"
            else

               let ws.count = 0
               select count(*)
                 into ws.count
                 from datmsrvre
                where srvretmtvcod = d_ctb24m00.srvretmtvcod

               if ws.count > 0 then
                  error " Motivo de retorno vinculado a servico, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datksrvret
                   where datksrvret.srvretmtvcod = d_ctb24m00.srvretmtvcod

                  if sqlca.sqlcode <> 0   then
                     rollback work
                     initialize d_ctb24m00.* to null
                     error " Erro (",sqlca.sqlcode,") na exclusao do motivo retorno!"
                  else
                     delete from datksrvretetg
                      where datksrvretetg.srvretmtvcod = d_ctb24m00.srvretmtvcod

                     if sqlca.sqlcode <> 0   then
                        rollback work
                        initialize d_ctb24m00.* to null
                        error " Erro (",sqlca.sqlcode,") na exclusao do motivo retorno!"
                     else
                        commit work
                        initialize d_ctb24m00.* to null
                        error   " Motivo excluido!"
                        message ""
                        clear form
                     end if
                  end if
            end if
            exit menu
 end menu

 return d_ctb24m00.*

end function    # ctb24m00_remove


#---------------------------------------------------------
 function ctb24m00_ler(param)
#---------------------------------------------------------

 define param         record
    srvretmtvcod      like datksrvret.srvretmtvcod
 end record

 define d_ctb24m00    record
    srvretmtvcod      like datksrvret.srvretmtvcod,
    srvretmtvdes      like datksrvret.srvretmtvdes,
    caddat            like datksrvret.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrvret.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    atlusrtip         like isskfunc.usrtip,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cadusrtip         like isskfunc.usrtip,
    cont              integer
 end record


 initialize d_ctb24m00.*   to null
 initialize ws.*           to null

 select  srvretmtvcod,
         srvretmtvdes,
         caddat,
         cademp,
         cadmat,
         cadusrtip,
         atldat,
         atlemp,
         atlmat, 
         atlusrtip
   into  d_ctb24m00.srvretmtvcod,
         d_ctb24m00.srvretmtvdes,
         d_ctb24m00.caddat,
         ws.cademp,
         ws.cadmat,
         ws.cadusrtip,
         d_ctb24m00.atldat,
         ws.atlemp,
         ws.atlmat,
         ws.atlusrtip
   from  datksrvret
  where  datksrvret.srvretmtvcod = param.srvretmtvcod

 if sqlca.sqlcode = notfound   then
    error " Motivo nao cadastrado!"
    initialize d_ctb24m00.*    to null
    return d_ctb24m00.*
 else
    call ctb24m00_func(ws.cademp, ws.cadmat, ws.cadusrtip)
         returning d_ctb24m00.cadfunnom

    call ctb24m00_func(ws.atlemp, ws.atlmat, ws.atlusrtip)
         returning d_ctb24m00.funnom
 end if

 return d_ctb24m00.*

 end function   # ctb24m00_ler


#---------------------------------------------------------
 function ctb24m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat, 
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

 end function   # ctb24m00_func
