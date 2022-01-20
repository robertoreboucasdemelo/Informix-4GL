###########################################################################
# Nome do Modulo: CTB10M07                                        Marcelo #
#                                                                Gilberto #
# Manutencao no cadastro de grupos tarifarios (grupos)           Dez/1996 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
function ctb10m07()
#------------------------------------------------------------

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctb10m07") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctb10m07.*   to  null
   initialize k_ctb10m07.* to  null

   open window ctb10m07 at 4,2 with form "ctb10m07"

   menu "GRUPOS"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Remove", "Inclui"
          end if

          show option "Encerra"

   command "Seleciona" "Seleciona grupo tarifario conforme criterios"
            call seleciona_ctb10m07(k_ctb10m07.*)
                 returning k_ctb10m07.*, ctb10m07.*
            if k_ctb10m07.socgtfcod is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhum grupo selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo grupo tarifario selecionado"
            message ""
            if k_ctb10m07.socgtfcod is not null then
               call proximo_ctb10m07(k_ctb10m07.*)
                    returning k_ctb10m07.*, ctb10m07.*
            else
               error " Nenhum grupo nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra grupo tarifario anterior selecionado"
            message ""
            if k_ctb10m07.socgtfcod is not null then
               call anterior_ctb10m07(k_ctb10m07.*)
                    returning k_ctb10m07.*, ctb10m07.*
            else
               error " Nenhum grupo nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica grupo tarifario corrente selecionado"
            message ""
            if k_ctb10m07.socgtfcod is not null then
               call modifica_ctb10m07(k_ctb10m07.*, ctb10m07.*)
                    returning k_ctb10m07.*
               initialize ctb10m07.*   to  null
               initialize k_ctb10m07.* to  null
               next option "Seleciona"
            else
               error " Nenhum grupo selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove grupo corrente tarifario selecionado"
            message ""
            if k_ctb10m07.socgtfcod is not null then
               call remove_ctb10m07(k_ctb10m07.*)  returning k_ctb10m07.*
               next option "Seleciona"
            else
               error " Nenhum grupo selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui grupo tarifario"
            message ""
            call inclui_ctb10m07()
            initialize ctb10m07.*   to  null
            initialize k_ctb10m07.* to  null

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb10m07

end function  ###  ctb10m07

#------------------------------------------------------------
function seleciona_ctb10m07(k_ctb10m07)
#------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   clear form
   let int_flag = false
   initialize ctb10m07.*  to null

   input by name k_ctb10m07.socgtfcod  without defaults

      before field socgtfcod
          display by name k_ctb10m07.socgtfcod attribute (reverse)

          if k_ctb10m07.socgtfcod is null then
             let k_ctb10m07.socgtfcod = 0
          end if

      after  field socgtfcod
          display by name k_ctb10m07.socgtfcod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb10m07.*   to null
      initialize k_ctb10m07.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m07.*, ctb10m07.*
   end if

   if k_ctb10m07.socgtfcod  =  0 then
      select min (dbskgtf.socgtfcod)
        into k_ctb10m07.socgtfcod
        from dbskgtf
       where dbskgtf.socgtfcod > k_ctb10m07.socgtfcod
   end if

   call ler_ctb10m07(k_ctb10m07.*)  returning ctb10m07.*

   if ctb10m07.socgtfcod  is not null  then
      display by name  ctb10m07.*
      call display_ctb10m07(k_ctb10m07.socgtfcod)
   else
      error " Grupo nao cadastrado!"
      initialize ctb10m07.*    to null
      initialize k_ctb10m07.*  to null
   end if

   return k_ctb10m07.*, ctb10m07.*

end function  ###  selecion_ctb10m07

#------------------------------------------------------------
function proximo_ctb10m07(k_ctb10m07)
#------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   initialize ctb10m07.*   to null

   select min (dbskgtf.socgtfcod)
     into ctb10m07.socgtfcod
     from dbskgtf
    where dbskgtf.socgtfcod > k_ctb10m07.socgtfcod

   if  ctb10m07.socgtfcod  is not null  then
       let k_ctb10m07.socgtfcod = ctb10m07.socgtfcod
       call ler_ctb10m07(k_ctb10m07.*)  returning ctb10m07.*

       if ctb10m07.socgtfcod  is not null  then
          display by name  ctb10m07.*
          call display_ctb10m07(k_ctb10m07.socgtfcod)
       else
          error " Grupo nao cadastrado!"
          initialize ctb10m07.*    to null
          initialize k_ctb10m07.*  to null
       end if
   else
      error " Nao ha' mais grupo nesta direcao!"
      initialize ctb10m07.*    to null
      initialize k_ctb10m07.*  to null
   end if

   return k_ctb10m07.*, ctb10m07.*

end function  ###  proximo_ctb10m07

#------------------------------------------------------------
function anterior_ctb10m07(k_ctb10m07)
#------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   initialize ctb10m07.*   to null

   select max(dbskgtf.socgtfcod)
     into ctb10m07.socgtfcod
     from dbskgtf
    where dbskgtf.socgtfcod < k_ctb10m07.socgtfcod

   if  ctb10m07.socgtfcod  is not  null  then
       let k_ctb10m07.socgtfcod = ctb10m07.socgtfcod
       call ler_ctb10m07(k_ctb10m07.*)  returning ctb10m07.*

       if ctb10m07.socgtfcod  is not null  then
          display by name  ctb10m07.*
          call display_ctb10m07(k_ctb10m07.socgtfcod)
       else
          error " Grupo nao cadastrado!"
          initialize ctb10m07.*    to null
          initialize k_ctb10m07.*  to null
       end if
   else
      error " Nao ha' mais grupo nesta direcao!"
      initialize ctb10m07.*    to null
      initialize k_ctb10m07.*  to null
   end if

   return k_ctb10m07.*, ctb10m07.*

end function  ###  anterior_ctb10m07

#------------------------------------------------------------
function modifica_ctb10m07(k_ctb10m07, ctb10m07)
#------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   call input_ctb10m07("a", k_ctb10m07.* , ctb10m07.*) returning ctb10m07.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m07.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m07.*
   end if

   update dbskgtf set  (socgtfstt,
                        socgtfdes,
                        atldat,
                        funmat)
                   =   (ctb10m07.socgtfstt,
                        ctb10m07.socgtfdes,
                        today,
                        g_issk.funmat )
    where socgtfcod  =  k_ctb10m07.socgtfcod

   if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao do grupo!"
      initialize ctb10m07.*   to null
      initialize k_ctb10m07.* to null
      return k_ctb10m07.*
   end if

   call ctb10m08("a", ctb10m07.socgtfcod, ctb10m07.socgtfdes,
                      ctb10m07.caddat   , ctb10m07.cadfunnom,
                      ctb10m07.atldat   , ctb10m07.funnom,
                      ctb10m07.socgtfstt)
   clear form
   message ""
   return k_ctb10m07.*

end function  ###  modifica_ctb10m07

#--------------------------------------------------------------------
function remove_ctb10m07(k_ctb10m07)
#--------------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record

   define ws                  record
          soctrfvignum        like dbsmvigtrfsocorro.soctrfvignum
   end record

   initialize ws.*   to null

   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui grupo tarifario"
              clear form
              initialize ctb10m07.*   to null
              initialize k_ctb10m07.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui grupo tarifario"
              call ler_ctb10m07(k_ctb10m07.*) returning ctb10m07.*

              if sqlca.sqlcode = notfound       and
                 ctb10m07.socgtfcod  is null    then
                 initialize ctb10m07.*   to null
                 initialize k_ctb10m07.* to null
                 error "Grupo nao localizado!"
              else
                 # REMOVE APENAS GRUPOS QUE NAO POSSUAM VIGENCIA
                 #----------------------------------------------
                 declare c_ctb10m07d  cursor for
                    select soctrfvignum
                      from dbstgtfcst
                     where dbstgtfcst.soctrfvignum > 0                    and
                           dbstgtfcst.socgtfcod    = ctb10m07.socgtfcod

                 foreach c_ctb10m07d  into  ws.soctrfvignum
                    exit foreach
                 end foreach

                 if ws.soctrfvignum  is not null   then
                    error " Grupo utilizado na vigencia --> ", ws.soctrfvignum
                    exit menu
                 end if

                 begin work
                    delete from dbskgtf
                     where socgtfcod = k_ctb10m07.socgtfcod

                    delete from dbsrvclgtf
                     where socgtfcod = k_ctb10m07.socgtfcod
                 commit work

                 if sqlca.sqlcode <>  0  then
                    error " Erro (",sqlca.sqlcode,") na remocao do grupo tarifario!"
                    rollback work
                 else
                    error  " Grupo tarifario removido!"
                 end if

                 initialize ctb10m07.*   to null
                 initialize k_ctb10m07.* to null
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctb10m07.*

end function  ###  remove_ctb10m07

#------------------------------------------------------------
function inclui_ctb10m07()
#------------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   clear form
   initialize ctb10m07.*   to null
   initialize k_ctb10m07.* to null

   call input_ctb10m07("i",k_ctb10m07.*, ctb10m07.*) returning ctb10m07.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m07.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   call ctb10m08("i", ctb10m07.socgtfcod, ctb10m07.socgtfdes,
                      ctb10m07.caddat   , ctb10m07.cadfunnom,
                      ctb10m07.atldat   , ctb10m07.funnom,
                      ctb10m07.socgtfstt)

   clear form
   message ""

end function  ###  inclui_ctb10m07

#--------------------------------------------------------------------
function input_ctb10m07(operacao_aux, k_ctb10m07, ctb10m07)
#--------------------------------------------------------------------
   define operacao_aux        char(01)

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record


   let int_flag = false

   input by name ctb10m07.socgtfcod,
                 ctb10m07.socgtfdes,
                 ctb10m07.socgtfstt   without defaults

   before field socgtfcod
          next field socgtfdes
          display by name ctb10m07.socgtfcod    attribute (reverse)

   after field socgtfcod
          display by name ctb10m07.socgtfcod

   before field socgtfdes
          display by name ctb10m07.socgtfdes    attribute (reverse)

   after field socgtfdes
          display by name ctb10m07.socgtfdes

          if ctb10m07.socgtfdes   is null    then
             error " Descricao do grupo deve ser informada!"
             next field socgtfdes
          end if

   before field socgtfstt
          if operacao_aux = "i"   then
             let ctb10m07.socgtfstt = "A"
             exit input
          else
             display by name ctb10m07.socgtfstt attribute (reverse)
          end if

   after field socgtfstt
          display by name ctb10m07.socgtfstt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field socgtfdes
          end if

          if ((ctb10m07.socgtfstt  is null)  or
              (ctb10m07.socgtfstt  <> "A"    and
               ctb10m07.socgtfstt  <> "C"))  then
             error " Situacao do grupo deve ser: (A)tiva, (C)ancelada!"
             next field socgtfstt
          end if

          if operacao_aux       = "i"   and
             ctb10m07.socgtfstt = "C"   then
             error " Nao deve ser incluido grupo com situacao cancelada!"
             next field socgtfstt
          end if

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctb10m07.*  to null
      return ctb10m07.*
   end if

   return ctb10m07.*

end function  ###  input_ctb10m07

#---------------------------------------------------------
function ler_ctb10m07(k_ctb10m07)
#---------------------------------------------------------

   define k_ctb10m07          record
          socgtfcod           like dbskgtf.socgtfcod
   end record

   define  ctb10m07           record
           socgtfcod          like dbskgtf.socgtfcod,
           socgtfdes          like dbskgtf.socgtfdes,
           socgtfstt          like dbskgtf.socgtfstt,
           caddat             like dbskgtf.caddat,
           cadfunnom          like isskfunc.funnom,
           atldat             like dbskgtf.atldat,
           funnom             like isskfunc.funnom
   end record

   define  ws                 record
           funmat             like isskfunc.funmat,
           cadmat             like isskfunc.funmat
   end record


   initialize ctb10m07.*   to null
   initialize ws.*         to null

   select socgtfcod,
          socgtfdes,
          socgtfstt,
          caddat,
          cadmat,
          atldat,
          funmat
     into ctb10m07.socgtfcod,
          ctb10m07.socgtfdes,
          ctb10m07.socgtfstt,
          ctb10m07.caddat,
          ws.cadmat,
          ctb10m07.atldat,
          ws.funmat
     from dbskgtf
    where dbskgtf.socgtfcod = k_ctb10m07.socgtfcod

   if sqlca.sqlcode = 0   then
      select funnom
        into ctb10m07.cadfunnom
        from isskfunc
       where isskfunc.funmat = ws.cadmat

      select funnom
        into ctb10m07.funnom
        from isskfunc
       where isskfunc.funmat = ws.funmat
   else
      error " Grupo nao encontrado!"
      initialize ctb10m07.*    to null
      initialize k_ctb10m07.*  to null
   end if

   return ctb10m07.*

end function  ###  ler_ctb10m07

#---------------------------------------------------------------
 function display_ctb10m07(par_socgtfcod)
#---------------------------------------------------------------
   define par_socgtfcod like dbskgtf.socgtfcod

   define a_ctb10m07 array[3000] of record
          vclcoddig      like dbsrvclgtf.vclcoddig,
          vcldes         char(60)
   end record

   define ws             record
          comando        char(400),
          ctgtrfdes      like agekcateg.ctgtrfdes
   end record

   define arr_aux        smallint


   initialize a_ctb10m07  to null
   initialize ws.*        to null
   let arr_aux = 1

   let ws.comando = " select ctgtrfdes ",
                      " from agekcateg ",
                     " where tabnum = (select max(tabnum) ",
                                       " from agekcateg ",
                                      " where ramcod = 531 ",
                                        " and ctgtrfcod = ?) ",
                       " and ramcod = 531 ",
                       " and ctgtrfcod = ? "
   prepare comando_aux3  from  ws.comando
   declare c_aux3  cursor for  comando_aux3

   error " Aguarde, pesquisando..."   attribute(reverse)

   declare c_ctb10m07 cursor for
      select vclcoddig
       from dbsrvclgtf
      where socgtfcod = par_socgtfcod

   foreach c_ctb10m07 into a_ctb10m07[arr_aux].vclcoddig

      initialize a_ctb10m07[arr_aux].vcldes to null

      open  c_aux3  using a_ctb10m07[arr_aux].vclcoddig,
                          a_ctb10m07[arr_aux].vclcoddig
      fetch c_aux3  into  ws.ctgtrfdes

      if sqlca.sqlcode <> 0   then
         error " Erro (",sqlca.sqlcode,") na leitura da categoria tarifaria!"
         sleep 5
         continue foreach
      end if

      let a_ctb10m07[arr_aux].vcldes = ws.ctgtrfdes clipped

      let arr_aux = arr_aux + 1

   end foreach

   error ""
   call set_count(arr_aux-1)
   message " (F17)Abandona"

   display array  a_ctb10m07 to s_ctb10m07.*
      on key(interrupt)
         let int_flag = false
         exit display
   end display
   message ""

end function  ###  display_ctb10m07
