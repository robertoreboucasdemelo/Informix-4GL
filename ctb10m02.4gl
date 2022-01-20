#-------------------------------------------------------------------------#
# Nome do Modulo: CTB10M02                                        Marcelo #
#                                                                Gilberto #
# Manutencao no cadastro de vigencias de tarifas                 Nov/1996 #
#-------------------------------------------------------------------------#
#                               ALTERACOES                                #
# Fabrica de Software - Teresinha Silva  - 22/10/2003 - OSF 25143         #
# Objetivo : Aumentar o tamanho do array de 50 para 500 posicoes          #
#-------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
function ctb10m02()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record

   define k_ctb10m02          record
          soctrfvignum        like dbsmvigtrfsocorro.soctrfvignum
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctb10m02") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctb10m02.*   to  null
   initialize k_ctb10m02.* to  null

   open window ctb10m02 at 4,2 with form "ctb10m02"

   menu "VIGENCIAS"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior", "pesQuisa"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Remove", "Inclui", "pesQuisa"
          end if

          show option "Encerra"

   command "Seleciona" "Seleciona vigencia conforme criterios"
            call seleciona_ctb10m02(k_ctb10m02.*)
                 returning k_ctb10m02.*, ctb10m02.*
            if k_ctb10m02.soctrfvignum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma vigencia selecionada!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima vigencia selecionada"
            message ""
            if k_ctb10m02.soctrfvignum is not null then
               call proximo_ctb10m02(k_ctb10m02.*)
                    returning k_ctb10m02.*, ctb10m02.*
            else
               error " Nenhuma vigencia nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra vigencia anterior selecionada"
            message ""
            if k_ctb10m02.soctrfvignum is not null then
               call anterior_ctb10m02(k_ctb10m02.*)
                    returning k_ctb10m02.*, ctb10m02.*
            else
               error " Nenhuma vigencia nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica vigencia corrente selecionada"
            message ""
            if k_ctb10m02.soctrfvignum is not null then
               call modifica_ctb10m02(k_ctb10m02.*, ctb10m02.*)
                    returning k_ctb10m02.*
               initialize ctb10m02.*   to  null
               initialize k_ctb10m02.* to  null
               next option "Seleciona"
            else
               error " Nenhuma vigencia selecionada!"
               next option "Seleciona"
            end if

   command "Remove" "Remove vigencia corrente selecionada"
            message ""
            if k_ctb10m02.soctrfvignum is not null then
               call remove_ctb10m02(k_ctb10m02.*)  returning k_ctb10m02.*
               next option "Seleciona"
            else
               error " Nenhuma vigencia selecionada!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui vigencia"
            message ""
            call inclui_ctb10m02()
            initialize ctb10m02.*   to  null
            initialize k_ctb10m02.* to  null

   command key ("Q") "pesQuisa" "Pesquisa vigencias"
            message ""
            call ctb10m04()  returning k_ctb10m02.soctrfvignum
            if k_ctb10m02.soctrfvignum   is not null   then
               message " Selecione e tecle ENTER "  attribute(reverse)
               next option "Seleciona"
            else
               message ""
            end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb10m02

end function  # ctb10m02


#------------------------------------------------------------
function seleciona_ctb10m02(k_ctb10m02)
#------------------------------------------------------------

   define k_ctb10m02          record
          soctrfvignum        like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   clear form
   let int_flag = false
   initialize ctb10m02.*  to null

   input by name k_ctb10m02.soctrfvignum  without defaults

      before field soctrfvignum
          display by name k_ctb10m02.soctrfvignum attribute (reverse)

          if k_ctb10m02.soctrfvignum is null then
             let k_ctb10m02.soctrfvignum = 0
          end if

      after  field soctrfvignum
          display by name k_ctb10m02.soctrfvignum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb10m02.*   to null
      initialize k_ctb10m02.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m02.*, ctb10m02.*
   end if

   if k_ctb10m02.soctrfvignum  =  0 then
      select min (dbsmvigtrfsocorro.soctrfvignum)
        into k_ctb10m02.soctrfvignum
        from dbsmvigtrfsocorro
       where dbsmvigtrfsocorro.soctrfvignum > k_ctb10m02.soctrfvignum
   end if

   call ler_ctb10m02(k_ctb10m02.*)  returning ctb10m02.*

   if ctb10m02.soctrfvignum  is not null  then
      display by name  ctb10m02.*
      call display_ctb10m02(k_ctb10m02.soctrfvignum)
   else
      error " Vigencia nao cadastrada!"
      initialize ctb10m02.*    to null
      initialize k_ctb10m02.*  to null
   end if

   return k_ctb10m02.*, ctb10m02.*

end function  # seleciona


#------------------------------------------------------------
function proximo_ctb10m02(k_ctb10m02)
#------------------------------------------------------------

   define k_ctb10m02          record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   initialize ctb10m02.*   to null

   select min (dbsmvigtrfsocorro.soctrfvignum)
     into ctb10m02.soctrfvignum
     from dbsmvigtrfsocorro
    where dbsmvigtrfsocorro.soctrfvignum > k_ctb10m02.soctrfvignum

   if  ctb10m02.soctrfvignum  is not null  then
       let k_ctb10m02.soctrfvignum = ctb10m02.soctrfvignum
       call ler_ctb10m02(k_ctb10m02.*)  returning ctb10m02.*

       if ctb10m02.soctrfvignum  is not null  then
          display by name  ctb10m02.*
          call display_ctb10m02(k_ctb10m02.soctrfvignum)
       else
          error " Vigencia nao cadastrada!"
          initialize ctb10m02.*    to null
          initialize k_ctb10m02.*  to null
       end if
   else
      error " Nao ha' mais vigencia nesta direcao!"
      initialize ctb10m02.*    to null
      initialize k_ctb10m02.*  to null
   end if

   return k_ctb10m02.*, ctb10m02.*

end function    # proximo_ctb10m02


#------------------------------------------------------------
function anterior_ctb10m02(k_ctb10m02)
#------------------------------------------------------------

   define  k_ctb10m02 record
           soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   initialize ctb10m02.*   to null

   select max(dbsmvigtrfsocorro.soctrfvignum)
     into ctb10m02.soctrfvignum
     from dbsmvigtrfsocorro
    where dbsmvigtrfsocorro.soctrfvignum < k_ctb10m02.soctrfvignum

   if  ctb10m02.soctrfvignum  is not  null  then
       let k_ctb10m02.soctrfvignum = ctb10m02.soctrfvignum
       call ler_ctb10m02(k_ctb10m02.*)  returning ctb10m02.*

       if ctb10m02.soctrfvignum  is not null  then
          display by name  ctb10m02.*
          call display_ctb10m02(k_ctb10m02.soctrfvignum)
       else
          error " Vigencia nao cadastrada!"
          initialize ctb10m02.*    to null
          initialize k_ctb10m02.*  to null
       end if
   else
      error " Nao ha' mais vigencia nesta direcao!"
      initialize ctb10m02.*    to null
      initialize k_ctb10m02.*  to null
   end if

   return k_ctb10m02.*, ctb10m02.*

end function    # anterior_ctb10m02


#------------------------------------------------------------
function modifica_ctb10m02(k_ctb10m02, ctb10m02)
#------------------------------------------------------------
# Modifica vigencias na tabela
#

   define  k_ctb10m02         record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   call input_ctb10m02("a", k_ctb10m02.* , ctb10m02.*) returning ctb10m02.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m02.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m02.*
   end if

   begin work
      update dbsmvigtrfsocorro set  (soctrfvigincdat,
                                     soctrfvigfnldat,
                                     soctrfcod,
                                     atldat,
                                     funmat
                                    )
                               =    (ctb10m02.soctrfvigincdat,
                                     ctb10m02.soctrfvigfnldat,
                                     ctb10m02.soctrfcod,
                                     today,
                                     g_issk.funmat
                                    )
             where dbsmvigtrfsocorro.soctrfvignum  =  k_ctb10m02.soctrfvignum
   commit work

   if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao da vigencia!"
      rollback work
      initialize ctb10m02.*   to null
      initialize k_ctb10m02.* to null
      return k_ctb10m02.*
   end if

   call ctb10m03("a", ctb10m02.soctrfvignum   , ctb10m02.soctrfvigincdat,
                      ctb10m02.soctrfvigfnldat, ctb10m02.caddat         ,
                      ctb10m02.cadfunnom      , ctb10m02.atldat         ,
                      ctb10m02.funnom         , ctb10m02.soctrfcod      ,
                      ctb10m02.soctrfdes)
   clear form
   message ""
   return k_ctb10m02.*

end function


#--------------------------------------------------------------------
function remove_ctb10m02(k_ctb10m02)
#--------------------------------------------------------------------

   define  k_ctb10m02         record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui vigencia"
              clear form
              initialize ctb10m02.*   to null
              initialize k_ctb10m02.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui vigencia"
              call ler_ctb10m02(k_ctb10m02.*) returning ctb10m02.*

              if sqlca.sqlcode = notfound         and
                 ctb10m02.soctrfvignum  is null   then
                 initialize ctb10m02.*   to null
                 initialize k_ctb10m02.* to null
                 error "Vigencia nao localizada!"
              else

                 # REMOVE APENAS TARIFAS NAO VIGENTES
                 #-----------------------------------
                 if ctb10m02.soctrfvigincdat is null    or
                    ctb10m02.soctrfvigincdat <= today   then
                    error " Tarifa em vigencia nao pode ser removida!"
                    exit menu
                 end if

                 begin work
                    delete from dbsmvigtrfsocorro
                     where soctrfvignum = k_ctb10m02.soctrfvignum

                    delete from dbstgtfcst
                     where soctrfvignum = k_ctb10m02.soctrfvignum
                 commit work

                 if sqlca.sqlcode <>  0  then
                    error " Erro na remocao da vigencia!"
                    rollback work
                 else
                    error  " Vigencia removida!"
                 end if

                 initialize ctb10m02.*   to null
                 initialize k_ctb10m02.* to null
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctb10m02.*

end function    # remove_ctb10m02


#------------------------------------------------------------
function inclui_ctb10m02()
#------------------------------------------------------------
# Inclui vigencias na tabela
#

   define k_ctb10m02  record
           soctrfvignum     like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record


   clear form
   initialize ctb10m02.*   to null
   initialize k_ctb10m02.* to null

   call input_ctb10m02("i",k_ctb10m02.*, ctb10m02.*) returning ctb10m02.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m02.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   call ctb10m03("i", ctb10m02.soctrfvignum   , ctb10m02.soctrfvigincdat,
                      ctb10m02.soctrfvigfnldat, ctb10m02.caddat         ,
                      ctb10m02.cadfunnom      , ctb10m02.atldat         ,
                      ctb10m02.funnom         , ctb10m02.soctrfcod      ,
                      ctb10m02.soctrfdes)
   clear form
   message ""

end function


#--------------------------------------------------------------------
function input_ctb10m02(operacao_aux, k_ctb10m02, ctb10m02)
#--------------------------------------------------------------------
   define operacao_aux        char(01)

   define  k_ctb10m02         record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record

   define  ws                 record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           socatuvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           socprxviginc       like dbsmvigtrfsocorro.soctrfvigincdat,
           socvigfnl          like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfsitcod       like dbsktarifasocorro.soctrfsitcod
   end record


   let int_flag = false
   initialize  ws.*   to null

   let ws.socatuvignum = 0
   if ctb10m02.soctrfvignum  is not null    then
      let ws.socatuvignum = ctb10m02.soctrfvignum
   end if

   input by name ctb10m02.soctrfvignum,
                 ctb10m02.soctrfcod,
                 ctb10m02.soctrfvigincdat,
                 ctb10m02.soctrfvigfnldat   without defaults

   before field soctrfvignum
          if operacao_aux = "a"   then
             if ctb10m02.soctrfvigincdat  <=  today   then   ## ja'
                next field soctrfvigfnldat                   ## vigente
             end if                                          ## nao modifica
          end if
          next field soctrfcod
          display by name ctb10m02.soctrfvignum    attribute (reverse)

   after field soctrfvignum
          display by name ctb10m02.soctrfvignum

   before field soctrfcod
          display by name ctb10m02.soctrfcod attribute (reverse)

   after field soctrfcod
          display by name ctb10m02.soctrfcod

          if ctb10m02.soctrfcod  is null   then
             error " Codigo da tarifa deve ser informado!"
             call ctb10m05()  returning ctb10m02.soctrfcod
             next field soctrfcod
          end if

          select soctrfdes, soctrfsitcod
            into ctb10m02.soctrfdes, ws.soctrfsitcod
            from dbsktarifasocorro
           where dbsktarifasocorro.soctrfcod = ctb10m02.soctrfcod

          if sqlca.sqlcode = notfound   then
             error " Tarifa nao cadastrada!"
             call ctb10m05()  returning ctb10m02.soctrfcod
             next field soctrfcod
          else
             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura do cad. tarifas"
                next field soctrfcod
             else
                display by name ctb10m02.soctrfdes
             end if
          end if

          if ws.soctrfsitcod <> "A"    then
             error " Tarifa informada nao esta' ativa!"
             next field soctrfcod
          end if

          if operacao_aux = "i"   then
             select * from dbsmvigtrfsocorro
              where soctrfcod       = ctb10m02.soctrfcod    and
                    soctrfvigincdat > today

             if sqlca.sqlcode = 0   then
                error " Ja' existe vigencia aberta p/ tarifa informada!"
                next field soctrfcod
             end if
          end if

   before field soctrfvigincdat
          display by name ctb10m02.soctrfvigincdat  attribute(reverse)

   after field soctrfvigincdat
          display by name ctb10m02.soctrfvigincdat

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field soctrfcod
          end if

          # BUSCA ULTIMA VIGENCIA DA TARIFA
          #--------------------------------
          initialize  ws.socprxviginc   to null
          select max(soctrfvigfnldat)
            into ws.socprxviginc
            from dbsmvigtrfsocorro
           where soctrfcod    =  ctb10m02.soctrfcod   and
                 soctrfvignum <> ws.socatuvignum

          if ws.socprxviginc  is not null   then
             let ws.socprxviginc = ws.socprxviginc + 1 units day
          else
             let ws.socprxviginc = today + 1 units day
          end if

          if ctb10m02.soctrfvigincdat  is null   then
             if ws.socprxviginc  is not null   then
                let ctb10m02.soctrfvigincdat = ws.socprxviginc
                error " Proxima vigencia inicial p/ tarifa informada, tecle ENTER"
                next field soctrfvigincdat
             else
                error " Vigencia inicial deve ser informada!"
                next field soctrfvigincdat
             end if
          end if

          if ctb10m02.soctrfvigincdat  <  today  then
             error " Vigencia inicial nao deve ser menor que hoje!"
             next field soctrfvigincdat
          end if

          initialize ws.soctrfvignum   to null
          select soctrfvignum
            into ws.soctrfvignum
            from dbsmvigtrfsocorro
           where dbsmvigtrfsocorro.soctrfcod = ctb10m02.soctrfcod   and
                 ctb10m02.soctrfvigincdat
                 between  soctrfvigincdat and soctrfvigfnldat       and
                 dbsmvigtrfsocorro.soctrfvignum <> ws.socatuvignum

          if sqlca.sqlcode  =  0   then
             error " Vigencia inicial ja' compreendida em outra vigencia!"
             next field soctrfvigincdat
          end if

          if ctb10m02.soctrfvigincdat < ws.socprxviginc    then
             error " Vig. inicial nao deve ser menor a ultima vig. final!"
             next field soctrfvigincdat
          end if

          if ctb10m02.soctrfvigincdat > ws.socprxviginc    then
             error " Entre duas vigencias nao devem existir dias vagos!"
             next field soctrfvigincdat
          end if

   before field soctrfvigfnldat
          display by name ctb10m02.soctrfvigfnldat attribute (reverse)

   after field soctrfvigfnldat
          display by name ctb10m02.soctrfvigfnldat

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if operacao_aux = "a"                    and
                ctb10m02.soctrfvigincdat  <=  today   then
                error " Tarifa em vigencia nao deve ser alterada!"
                next field soctrfvigfnldat
             else
                next field soctrfvigincdat
             end if
          end if

          if ctb10m02.soctrfvigfnldat  is null   then
             error " Vigencia final deve ser informada!"
             next field soctrfvigfnldat
          end if

          if ctb10m02.soctrfvigfnldat  <  today  then
             error " Vigencia final nao deve ser menor que hoje!"
             next field soctrfvigfnldat
          end if

          if ctb10m02.soctrfvigfnldat  <=  ctb10m02.soctrfvigincdat  then
             error " Vig. final nao deve ser menor ou igual a Vig. inicial!"
             next field soctrfvigfnldat
          end if

          select * from  dbsmvigtrfsocorro
           where dbsmvigtrfsocorro.soctrfcod = ctb10m02.soctrfcod   and
                 ctb10m02.soctrfvigfnldat
                 between  soctrfvigincdat and soctrfvigfnldat       and
                 dbsmvigtrfsocorro.soctrfvignum <> ws.socatuvignum

          if sqlca.sqlcode = 0    then
             error " Vigencia final ja' compreendida em outra vigencia!"
             next field soctrfvigfnldat
          end if


          # NO MOMENTO DO FECHAMENTO DA VIGENCIA, ENTRE VIGENCIA FINAL(ATUAL)
          # E A PROXIMA VIGENCIA INICIAL NAO DEVEM EXISTIR DIAS VAGOS
          #-----------------------------------------------------------
          select soctrfvigincdat
            into ws.socvigfnl
            from dbsmvigtrfsocorro
           where dbsmvigtrfsocorro.soctrfcod  =  ctb10m02.soctrfcod         and
                 dbsmvigtrfsocorro.soctrfvigincdat > ctb10m02.soctrfvigincdat

          if ws.socvigfnl   is not null   then
             let ws.socvigfnl = ws.socvigfnl - 1 units day
             if ctb10m02.soctrfvigfnldat <> ws.socvigfnl   then
                error " Entre vig final e inicio da proxima vig existem dias vagos!"
                next field soctrfvigfnldat
             end if
          end if

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctb10m02.*  to null
      return ctb10m02.*
   end if

   return ctb10m02.*

end function   # input_ctb10m02


#---------------------------------------------------------
function ler_ctb10m02(k_ctb10m02)
#---------------------------------------------------------

   define  k_ctb10m02         record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum
   end record

   define  ctb10m02           record
           soctrfvignum       like dbsmvigtrfsocorro.soctrfvignum ,
           soctrfcod          like dbsmvigtrfsocorro.soctrfcod      ,
           soctrfdes          like dbsktarifasocorro.soctrfdes      ,
           soctrfvigincdat    like dbsmvigtrfsocorro.soctrfvigincdat,
           soctrfvigfnldat    like dbsmvigtrfsocorro.soctrfvigfnldat,
           caddat             like dbsmvigtrfsocorro.caddat         ,
           cadfunnom          like isskfunc.funnom                  ,
           atldat             like dbsmvigtrfsocorro.atldat         ,
           funnom             like isskfunc.funnom
   end record

   define  ws                 record
           funmat             like isskfunc.funmat,
           cadfunmat          like isskfunc.funmat
   end record
   
   define l_sql char(200)

   initialize ctb10m02.*   to null
   initialize ws.*         to null

   select soctrfvignum,
          soctrfvigincdat,
          soctrfvigfnldat,
          soctrfcod,
          caddat,
          cadfunmat,
          atldat,
          funmat
     into ctb10m02.soctrfvignum,
          ctb10m02.soctrfvigincdat,
          ctb10m02.soctrfvigfnldat,
          ctb10m02.soctrfcod,
          ctb10m02.caddat,
          ws.cadfunmat,
          ctb10m02.atldat,
          ws.funmat
     from dbsmvigtrfsocorro
    where dbsmvigtrfsocorro.soctrfvignum = k_ctb10m02.soctrfvignum

   if sqlca.sqlcode = 0   then
      let l_sql = " select first 1 funnom ",
                  " from isskfunc " ,
                  " where isskfunc.funmat = ? "
      prepare p_ctb10m0201 from l_sql
      declare cctb10m0201 cursor with hold for p_ctb10m0201
      
      open cctb10m0201 using ws.funmat
      fetch cctb10m0201 into ctb10m02.cadfunnom   
      
      let ctb10m02.funnom = ctb10m02.cadfunnom
    
      select soctrfdes
        into ctb10m02.soctrfdes
        from dbsktarifasocorro
       where dbsktarifasocorro.soctrfcod = ctb10m02.soctrfcod
   else
      error " Vigencia nao encontrada!"
      initialize ctb10m02.*    to null
      initialize k_ctb10m02.*  to null
   end if

   return ctb10m02.*

end function   # ler_ctb10m02


#---------------------------------------------------------------
 function display_ctb10m02(par2_soctrfvignum)
#---------------------------------------------------------------
   define par2_soctrfvignum like dbsmvigtrfsocorro.soctrfvignum

   define a_ctb10m02 array[500] of record
          socgtfcod      like dbstgtfcst.socgtfcod,
          socgtfdes      like dbskgtf.socgtfdes,
          soccstcod      like dbstgtfcst.soccstcod,
          soccstdes      like dbskcustosocorro.soccstdes,
          socgtfcstvlr   like dbstgtfcst.socgtfcstvlr
   end record

   define ws2            record
          soccstexbseq   like dbskcustosocorro.soccstexbseq
   end record

   define arr_aux        integer


   initialize a_ctb10m02  to null
   initialize ws2.*       to null
   let arr_aux = 1

   declare c_ctb10m02 cursor for
      select dbstgtfcst.socgtfcod,
             dbskgtf.socgtfdes,
             dbstgtfcst.soccstcod,
             dbskcustosocorro.soccstdes,
             dbstgtfcst.socgtfcstvlr,
             dbskcustosocorro.soccstexbseq
       from dbstgtfcst, dbskgtf, dbskcustosocorro
      where dbstgtfcst.soctrfvignum    = par2_soctrfvignum      and
            dbskgtf.socgtfcod          = dbstgtfcst.socgtfcod   and
            dbskcustosocorro.soccstcod = dbstgtfcst.soccstcod
     order by dbstgtfcst.socgtfcod,
              dbskcustosocorro.soccstexbseq

   foreach c_ctb10m02 into a_ctb10m02[arr_aux].socgtfcod,
                           a_ctb10m02[arr_aux].socgtfdes,
                           a_ctb10m02[arr_aux].soccstcod,
                           a_ctb10m02[arr_aux].soccstdes,
                           a_ctb10m02[arr_aux].socgtfcstvlr,
                           ws2.soccstexbseq

      let arr_aux = arr_aux + 1
      if arr_aux > 500 then
         error " Limite excedido, vigencia com mais de 500 grupos/custos"
         exit foreach
      end if
   end foreach

   call set_count(arr_aux-1)
   message " (F17)Abandona"

   display array  a_ctb10m02 to s_ctb10m02.*
      on key(interrupt)
         let int_flag = false
         exit display
   end display
   message ""

end function  #  display_ctb10m02
