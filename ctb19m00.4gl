###########################################################################
# Nome do Modulo: CTB19M00                                         Wagner #
#                                                                         #
# Cadastro de e-mail por UF                                      Mai/2000 #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------
 function ctb19m00()
#-------------------------------------------------------------

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 let int_flag = false
 initialize d_ctb19m00.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctb19m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctb19m00 at 4,2 with form "ctb19m00"

 menu "E-MAIL UF"

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
                   "Pesquisa UF conforme criterios"
          call ctb19m00_seleciona()  returning d_ctb19m00.*
          if d_ctb19m00.ufdcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma UF selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima UF selecionada"
          message ""
          if d_ctb19m00.ufdcod is not null then
             call ctb19m00_proximo(d_ctb19m00.ufdcod,
                                   d_ctb19m00.sucmaiseq)
                  returning d_ctb19m00.*
          else
             error " Nenhuma UF nesta direcao!"
             next option "Seleciona"
          end if

 command key ("A") "Anterior"
                   "Mostra UF anterior selecionada"
          message ""
          if d_ctb19m00.ufdcod is not null then
             call ctb19m00_anterior(d_ctb19m00.ufdcod,
                                    d_ctb19m00.sucmaiseq)
                  returning d_ctb19m00.*
          else
             error " Nenhuma UF nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica UF corrente selecionada"
          message ""
          if d_ctb19m00.ufdcod  is not null then
             call ctb19m00_modifica(d_ctb19m00.ufdcod, d_ctb19m00.*)
                  returning d_ctb19m00.*
             next option "Seleciona"
          else
             error " Nenhuma UF selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui E-Mail na UF"
          message ""
          call ctb19m00_inclui()
          next option "Seleciona"

   command "Remove" "Remove E-mail da UF corrente selecionada"
            message ""
            if d_ctb19m00.ufdcod  is not null   then
               call ctb19m00_remove(d_ctb19m00.*)
                    returning d_ctb19m00.*
               next option "Seleciona"
            else
               error " Nenhum E-mail selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb19m00

 end function  # ctb19m00


#------------------------------------------------------------
 function ctb19m00_seleciona()
#------------------------------------------------------------

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 let int_flag = false
 initialize d_ctb19m00.*  to null
 display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 input by name d_ctb19m00.ufdcod

    before field ufdcod
        display by name d_ctb19m00.ufdcod attribute (reverse)

    after  field ufdcod
        display by name d_ctb19m00.ufdcod

        if d_ctb19m00.ufdcod is not null then
           call ctb19m00_uf(d_ctb19m00.ufdcod)
                  returning d_ctb19m00.ufdnom

           if sqlca.sqlcode = notfound then
              error " Sigla da UF nao existe!"
              next field ufdcod
           end if
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb19m00.*   to null
    display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
    error " Operacao cancelada!"
    clear form
    return d_ctb19m00.*
 end if

 if d_ctb19m00.ufdcod is null then
     select min(ufdcod)
       into d_ctb19m00.ufdcod
       from datmsucmai
 end if

 select min(sucmaiseq)
   into d_ctb19m00.sucmaiseq
   from datmsucmai
  where ufdcod = d_ctb19m00.ufdcod

 call ctb19m00_ler(d_ctb19m00.ufdcod, d_ctb19m00.sucmaiseq)
         returning d_ctb19m00.*

 if d_ctb19m00.ufdcod  is not null   then
    display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
   else
    error " Sigla da UF nao existe!"
    initialize d_ctb19m00.*    to null
 end if

 return d_ctb19m00.*

 end function  # ctb19m00_seleciona


#------------------------------------------------------------
 function ctb19m00_proximo(param)
#------------------------------------------------------------

 define param         record
    ufdcod            like datmsucmai.ufdcod,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define ws            record
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 let int_flag = false
 initialize d_ctb19m00.*  to null
 initialize ws.*          to null

 select min(datmsucmai.sucmaiseq)
   into ws.sucmaiseq
   from datmsucmai
  where datmsucmai.ufdcod    = param.ufdcod
    and datmsucmai.sucmaiseq > param.sucmaiseq

  if sqlca.sqlcode = notfound  or
     ws.sucmaiseq is null      then
     select min(datmsucmai.ufdcod)
       into d_ctb19m00.ufdcod
       from datmsucmai
      where datmsucmai.ufdcod     > param.ufdcod
        and datmsucmai.sucmaiseq <> 0

     if sqlca.sqlcode = notfound  or
        d_ctb19m00.ufdcod is null then
        error " Nao ha' mais e-mail por UF nesta direcao!"
        initialize d_ctb19m00.*    to null
        display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
        return d_ctb19m00.*
     end if

     select min(datmsucmai.sucmaiseq)
       into ws.sucmaiseq
       from datmsucmai
      where datmsucmai.ufdcod    = d_ctb19m00.ufdcod
        and datmsucmai.sucmaiseq <> 0

  else
      let d_ctb19m00.ufdcod    = param.ufdcod
  end if

  let d_ctb19m00.sucmaiseq = ws.sucmaiseq

  call ctb19m00_ler(d_ctb19m00.ufdcod,
                    d_ctb19m00.sucmaiseq)
          returning d_ctb19m00.*

  display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 return d_ctb19m00.*

 end function    # ctb19m00_proximo


#------------------------------------------------------------
 function ctb19m00_anterior(param)
#------------------------------------------------------------

 define param         record
    ufdcod            like datmsucmai.ufdcod,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define ws            record
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 let int_flag = false
 initialize d_ctb19m00.*  to null
 initialize ws.*          to null

 select max(datmsucmai.sucmaiseq)
   into ws.sucmaiseq
   from datmsucmai
  where datmsucmai.ufdcod    = param.ufdcod
    and datmsucmai.sucmaiseq < param.sucmaiseq

  if sqlca.sqlcode = notfound  or
     ws.sucmaiseq is null      then
     select max(datmsucmai.ufdcod)
       into d_ctb19m00.ufdcod
       from datmsucmai
      where datmsucmai.ufdcod    < param.ufdcod
        and datmsucmai.sucmaiseq <> 0

     if sqlca.sqlcode = notfound  or
        d_ctb19m00.ufdcod is null then
        error " Nao ha' mais e-mail por UF nesta direcao!"
        initialize d_ctb19m00.*    to null
        display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
        return d_ctb19m00.*
     end if

     select max(datmsucmai.sucmaiseq)
       into ws.sucmaiseq
       from datmsucmai
      where datmsucmai.ufdcod   = d_ctb19m00.ufdcod
      and datmsucmai.sucmaiseq <> 0

  else
     let d_ctb19m00.ufdcod    = param.ufdcod
  end if

  let d_ctb19m00.sucmaiseq = ws.sucmaiseq

  call ctb19m00_ler(d_ctb19m00.ufdcod,
                    d_ctb19m00.sucmaiseq)
          returning d_ctb19m00.*

  display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 return d_ctb19m00.*

 end function    # ctb19m00_anterior


#------------------------------------------------------------
 function ctb19m00_modifica(param, d_ctb19m00)
#------------------------------------------------------------

 define param         record
    ufdcod            like datmsucmai.ufdcod
 end record

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 call ctb19m00_input("a", d_ctb19m00.*) returning d_ctb19m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb19m00.*  to null
    display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
    error " Operacao cancelada!"
    return d_ctb19m00.*
 end if

 whenever error continue

 let d_ctb19m00.atldat = today

 begin work
    update datmsucmai set  ( maides,
                             sucmaistt,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctb19m00.maides,
                             d_ctb19m00.sucmaistt,
                             d_ctb19m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
      where datmsucmai.ufdcod     =  d_ctb19m00.ufdcod
        and datmsucmai.sucmaiseq  =  d_ctb19m00.sucmaiseq

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do e-mail!"
       rollback work
       initialize d_ctb19m00.*   to null
       return d_ctb19m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb19m00.*  to null
 display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
 message ""
 return d_ctb19m00.*

 end function   #  ctb19m00_modifica


#------------------------------------------------------------
 function ctb19m00_inclui()
#------------------------------------------------------------

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define  ws_resp       char(01)


 initialize d_ctb19m00.*   to null
 display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 call ctb19m00_input("i", d_ctb19m00.*) returning d_ctb19m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb19m00.*  to null
    display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom
    error " Operacao cancelada!"
    return
 end if

 let d_ctb19m00.atldat = today
 let d_ctb19m00.caddat = today

 select  max(sucmaiseq)
   into  d_ctb19m00.sucmaiseq
   from  datmsucmai
  where  datmsucmai.ufdcod  = d_ctb19m00.ufdcod

 if d_ctb19m00.sucmaiseq is null   then
    let d_ctb19m00.sucmaiseq = 0
 end if
 let d_ctb19m00.sucmaiseq = d_ctb19m00.sucmaiseq + 1

 whenever error continue

 begin work
    insert into datmsucmai ( ufdcod,
                             sucmaiseq,
                             maides,
                             sucmaistt,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                    values ( d_ctb19m00.ufdcod,
                             d_ctb19m00.sucmaiseq,
                             d_ctb19m00.maides,
                             d_ctb19m00.sucmaistt,
                             d_ctb19m00.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctb19m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do e-mail!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctb19m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb19m00.cadfunnom

 call ctb19m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctb19m00.funnom

 display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctb19m00.*  to null
 display by name d_ctb19m00.ufdcod thru d_ctb19m00.funnom

 end function   #  ctb19m00_inclui


#--------------------------------------------------------------------
 function ctb19m00_input(param, d_ctb19m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define arr_aux       smallint

 let int_flag = false

 input by name d_ctb19m00.ufdcod,
               d_ctb19m00.maides,
               d_ctb19m00.sucmaistt  without defaults

    before field ufdcod
           if param.operacao  =  "a"   then
              next field maides
           end if
           display by name d_ctb19m00.ufdcod attribute (reverse)

    after  field ufdcod
           display by name d_ctb19m00.ufdcod

           call ctb19m00_uf(d_ctb19m00.ufdcod)
                  returning d_ctb19m00.ufdnom

           if sqlca.sqlcode = notfound then
              error " Sigla da UF nao existe!"
              next field ufdcod
           end if

           display by name d_ctb19m00.ufdnom

    before field maides
           display by name d_ctb19m00.maides attribute (reverse)

    after  field maides
           display by name d_ctb19m00.maides

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ufdcod
           end if

           if d_ctb19m00.maides  is null   then
              error " Endereco e-mail deve ser informado!"
              if param.operacao  =  "i"   then
                 next field maides
              end if
           end if

           for arr_aux = 2 to 50
               if d_ctb19m00.maides[arr_aux,arr_aux +2]   = "   " then
                  exit for
               end if
               if d_ctb19m00.maides[arr_aux,arr_aux]      <> " " and
                  d_ctb19m00.maides[arr_aux -1,arr_aux -1] = " " then
                  error " Erro no formato do e-mail, substitua (  ) por (,)!"
                  next field maides
               end if
           end for

    before field sucmaistt
           if param.operacao  =  "i"   then
              let d_ctb19m00.sucmaistt = "A"
           end if
           display by name d_ctb19m00.sucmaistt attribute (reverse)

    after  field sucmaistt
           display by name d_ctb19m00.sucmaistt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field maides
           end if

           if d_ctb19m00.sucmaistt  is null   or
             (d_ctb19m00.sucmaistt  <> "A"    and
              d_ctb19m00.sucmaistt  <> "C")   then
              error " Situacao do e-mail deve ser: (A)tivo ou (C)ancelado!"
              next field sucmaistt
           end if

           if param.operacao        = "i"   and
              d_ctb19m00.sucmaistt  = "C"   then
              error " Nao deve ser incluso e-mail com situacao (C)ancelado!"
              next field sucmaistt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctb19m00.*  to null
 end if

 return d_ctb19m00.*

 end function   # ctb19m00_input


#--------------------------------------------------------------------
 function ctb19m00_remove(d_ctb19m00)
#--------------------------------------------------------------------

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o e_mail"
            clear form
            initialize d_ctb19m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui e-mail"
            call ctb19m00_ler(d_ctb19m00.ufdcod,
                              d_ctb19m00.sucmaiseq)
                    returning d_ctb19m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb19m00.* to null
               error " E-mail nao localizado!"
            else
               begin work
                  delete from datmsucmai
                   where datmsucmai.ufdcod    = d_ctb19m00.ufdcod
                     and datmsucmai.sucmaiseq = d_ctb19m00.sucmaiseq
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctb19m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exclusao do e-mail!"
               else
                  initialize d_ctb19m00.* to null
                  error   " E-mail excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctb19m00.*

end function    # ctb19m00_remove


#---------------------------------------------------------
 function ctb19m00_ler(param)
#---------------------------------------------------------

 define param         record
    ufdcod            like datmsucmai.ufdcod,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record

 define d_ctb19m00    record
    ufdcod            like datmsucmai.ufdcod,
    ufdnom            like glakest.ufdnom,
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    caddat            like datmsucmai.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsucmai.atldat,
    funnom            like isskfunc.funnom,
    sucmaiseq         like datmsucmai.sucmaiseq
 end record


 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    cont              integer
 end record


 initialize d_ctb19m00.*   to null
 initialize ws.*           to null

 select  ufdcod,
         sucmaiseq,
         maides,
         sucmaistt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctb19m00.ufdcod,
         d_ctb19m00.sucmaiseq,
         d_ctb19m00.maides,
         d_ctb19m00.sucmaistt,
         d_ctb19m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctb19m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  datmsucmai
  where  datmsucmai.ufdcod    = param.ufdcod
    and  datmsucmai.sucmaiseq = param.sucmaiseq

 if sqlca.sqlcode = notfound   then
    error " Unidade Federativa nao cadastrada!"
    initialize d_ctb19m00.*    to null
    return d_ctb19m00.*
 else
    call ctb19m00_uf(d_ctb19m00.ufdcod)
         returning d_ctb19m00.ufdnom

    call ctb19m00_func(ws.cademp, ws.cadmat)
         returning d_ctb19m00.cadfunnom

    call ctb19m00_func(ws.atlemp, ws.atlmat)
         returning d_ctb19m00.funnom
 end if

 return d_ctb19m00.*

 end function   # ctb19m00_ler


#---------------------------------------------------------
 function ctb19m00_uf(param)
#---------------------------------------------------------

 define param         record
    ufdcod            like datmsucmai.ufdcod
 end record

 define ws            record
    ufdnom            like glakest.ufdnom
 end record

 select ufdnom
   into ws.ufdnom
   from glakest
  where ufdcod = param.ufdcod

 if sqlca.sqlcode = notfound then
    initialize ws.* to null
 end if

 return ws.ufdnom

 end function  # ctb19m00_uf

#---------------------------------------------------------
 function ctb19m00_func(param)
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

 end function   # ctb19m00_func
