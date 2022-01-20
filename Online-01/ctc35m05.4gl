###########################################################################
# Nome do Modulo: CTC35M05                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Manutencao no cadastro de Laudos de vistoria                   Dez/1998 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#------------------------------------------------------------
function ctc35m05()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   define k_ctc35m05          record
          socvstlaunum        like datmvstlau.socvstlaunum
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctc35m05") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctc35m05.*   to  null
   initialize k_ctc35m05.* to  null

   open window ctc35m05 at 4,2 with form "ctc35m05"

   menu "MONTA_LAUDOS"

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

   command "Seleciona" "Seleciona laudo conforme criterios"
            call ctc35m05_seleciona(k_ctc35m05.*)
                 returning k_ctc35m05.*, ctc35m05.*
            if k_ctc35m05.socvstlaunum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma laudo selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo laudo selecionado"
            message ""
            if k_ctc35m05.socvstlaunum is not null then
               call ctc35m05_proximo(k_ctc35m05.*)
                    returning k_ctc35m05.*, ctc35m05.*
            else
               error " Nenhum laudo nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra laudo anterior selecionado"
            message ""
            if k_ctc35m05.socvstlaunum is not null then
               call ctc35m05_anterior(k_ctc35m05.*)
                    returning k_ctc35m05.*, ctc35m05.*
            else
               error " Nenhum laudo nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica laudo corrente selecionado"
            message ""
            if k_ctc35m05.socvstlaunum is not null then
               call ctc35m05_modifica(k_ctc35m05.*, ctc35m05.*)
                    returning k_ctc35m05.*
               initialize ctc35m05.*   to  null
               initialize k_ctc35m05.* to  null
               next option "Seleciona"
            else
               error " Nenhum laudo selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove laudo corrente selecionado"
            message ""
            if k_ctc35m05.socvstlaunum is not null then
               call ctc35m05_remove(k_ctc35m05.*)  returning k_ctc35m05.*
               next option "Seleciona"
            else
               error " Nenhum laudo selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui laudo"
            message ""
            call ctc35m05_inclui()
            initialize ctc35m05.*   to  null
            initialize k_ctc35m05.* to  null

   command key ("Q") "pesQuisa" "Pesquisa laudo"
            message ""
            call ctc35m07()  returning k_ctc35m05.socvstlaunum
            if k_ctc35m05.socvstlaunum   is not null   then
               message " Selecione e tecle ENTER "  attribute(reverse)
               next option "Seleciona"
            else
               message ""
            end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc35m05

end function  # ctc35m05


#------------------------------------------------------------
function ctc35m05_seleciona(k_ctc35m05)
#------------------------------------------------------------

   define k_ctc35m05          record
          socvstlaunum        like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   clear form
   let int_flag = false
   initialize ctc35m05.*  to null

   input by name k_ctc35m05.socvstlaunum  without defaults

      before field socvstlaunum
          display by name k_ctc35m05.socvstlaunum attribute (reverse)

          if k_ctc35m05.socvstlaunum is null then
             let k_ctc35m05.socvstlaunum = 0
          end if

      after  field socvstlaunum
          display by name k_ctc35m05.socvstlaunum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc35m05.*   to null
      initialize k_ctc35m05.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc35m05.*, ctc35m05.*
   end if

   if k_ctc35m05.socvstlaunum  =  0 then
      select min (datmvstlau.socvstlaunum)
        into k_ctc35m05.socvstlaunum
        from datmvstlau
       where datmvstlau.socvstlaunum > k_ctc35m05.socvstlaunum
   end if

   call ctc35m05_ler(k_ctc35m05.*)  returning ctc35m05.*

   if ctc35m05.socvstlaunum  is not null  then
      display by name  ctc35m05.socvstlaunum thru ctc35m05.cadfunnom
      call ctc35m05_display(k_ctc35m05.socvstlaunum)
   else
      error " Laudo nao cadastrado!"
      initialize ctc35m05.*    to null
      initialize k_ctc35m05.*  to null
   end if

   return k_ctc35m05.*, ctc35m05.*

end function  # ctc35m05_seleciona


#------------------------------------------------------------
function ctc35m05_proximo(k_ctc35m05)
#------------------------------------------------------------

   define k_ctc35m05          record
           socvstlaunum       like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   initialize ctc35m05.*   to null

   select min (datmvstlau.socvstlaunum)
     into ctc35m05.socvstlaunum
     from datmvstlau
    where datmvstlau.socvstlaunum > k_ctc35m05.socvstlaunum

   if  ctc35m05.socvstlaunum  is not null  then
       let k_ctc35m05.socvstlaunum = ctc35m05.socvstlaunum
       call ctc35m05_ler(k_ctc35m05.*)  returning ctc35m05.*

       if ctc35m05.socvstlaunum  is not null  then
          display by name  ctc35m05.socvstlaunum thru ctc35m05.cadfunnom
          call ctc35m05_display(k_ctc35m05.socvstlaunum)
       else
          error " Laudo nao cadastrado!"
          initialize ctc35m05.*    to null
          initialize k_ctc35m05.*  to null
       end if
   else
      error " Nao ha' mais laudo nesta direcao!"
      initialize ctc35m05.*    to null
      initialize k_ctc35m05.*  to null
   end if

   return k_ctc35m05.*, ctc35m05.*

end function    # ctc35m05_proximo


#------------------------------------------------------------
function ctc35m05_anterior(k_ctc35m05)
#------------------------------------------------------------

   define  k_ctc35m05 record
           socvstlaunum     like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   initialize ctc35m05.*   to null

   select max(datmvstlau.socvstlaunum)
     into ctc35m05.socvstlaunum
     from datmvstlau
    where datmvstlau.socvstlaunum < k_ctc35m05.socvstlaunum

   if  ctc35m05.socvstlaunum  is not  null  then
       let k_ctc35m05.socvstlaunum = ctc35m05.socvstlaunum
       call ctc35m05_ler(k_ctc35m05.*)  returning ctc35m05.*

       if ctc35m05.socvstlaunum  is not null  then
          display by name  ctc35m05.socvstlaunum thru ctc35m05.cadfunnom
          call ctc35m05_display(k_ctc35m05.socvstlaunum)
       else
          error " Laudo nao cadastrado!"
          initialize ctc35m05.*    to null
          initialize k_ctc35m05.*  to null
       end if
   else
      error " Nao ha' mais laudo nesta direcao!"
      initialize ctc35m05.*    to null
      initialize k_ctc35m05.*  to null
   end if

   return k_ctc35m05.*, ctc35m05.*

end function    # ctc35m05_anterior


#------------------------------------------------------------
function ctc35m05_modifica(k_ctc35m05, ctc35m05)
#------------------------------------------------------------
# Modifica laudo na tabela
#

   define  k_ctc35m05         record
           socvstlaunum       like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   call ctc35m05_input("a", k_ctc35m05.* , ctc35m05.*) returning ctc35m05.*

   if int_flag  then
      let int_flag = false
      initialize ctc35m05.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctc35m05.*
   end if

   begin work
      update datmvstlau set  (viginc,
                              vigfnl,
                              socvstlautipcod)
                          =
                             (ctc35m05.viginc,
                              ctc35m05.vigfnl,
                              ctc35m05.socvstlautipcod)
       where datmvstlau.socvstlaunum  =  k_ctc35m05.socvstlaunum
   commit work

   if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao do laudo!"
      rollback work
      initialize ctc35m05.*   to null
      initialize k_ctc35m05.* to null
      return k_ctc35m05.*
   end if

   if ctc35m05.viginc > today then  # ainda nao vigente pode modificar
      call ctc35m06("a", ctc35m05.socvstlaunum   , ctc35m05.socvstlautipcod,
                         ctc35m05.socvstlautipdes, ctc35m05.viginc,
                         ctc35m05.vigfnl         , ctc35m05.caddat,
                         ctc35m05.cadfunnom      , ctc35m05.cademp,
                         ctc35m05.cadmat         )

     else
      error " Alteracao efetuada com sucesso!"
   end if

   clear form
   message ""
   return k_ctc35m05.*

end function  # ctc35m05_modifica


#--------------------------------------------------------------------
function ctc35m05_remove(k_ctc35m05)
#--------------------------------------------------------------------

   define  k_ctc35m05         record
           socvstlaunum       like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui laudo"
              clear form
              initialize ctc35m05.*   to null
              initialize k_ctc35m05.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui laudo"
              call ctc35m05_ler(k_ctc35m05.*) returning ctc35m05.*

              if sqlca.sqlcode = notfound         and
                 ctc35m05.socvstlaunum  is null   then
                 initialize ctc35m05.*   to null
                 initialize k_ctc35m05.* to null
                 error "Laudo nao localizado!"
              else

                 # REMOVE APENAS LAUDOS NAO VIGENTES
                 #----------------------------------
                 if ctc35m05.viginc is null    or
                    ctc35m05.viginc <= today   then
                    error " Laudo em vigencia nao pode ser removido!"
                    exit menu
                 end if

                 begin work
                    delete from datmvstlau
                     where socvstlaunum = k_ctc35m05.socvstlaunum

                    delete from datrvstitmver
                     where socvstlaunum = k_ctc35m05.socvstlaunum
                 commit work

                 if sqlca.sqlcode <>  0  then
                    error " Erro na remocao do laudo!"
                    rollback work
                 else
                    error  " Laudo removido!"
                 end if

                 initialize ctc35m05.*   to null
                 initialize k_ctc35m05.* to null
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc35m05.*

end function    # ctc35m05_remove


#------------------------------------------------------------
function ctc35m05_inclui()
#------------------------------------------------------------
# Inclui laudo na tabela
#

   define k_ctc35m05  record
           socvstlaunum     like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   clear form
   initialize ctc35m05.*   to null
   initialize k_ctc35m05.* to null

   call ctc35m05_input("i",k_ctc35m05.*, ctc35m05.*) returning ctc35m05.*

   if int_flag  then
      let int_flag = false
      initialize ctc35m05.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   call ctc35m06("i", ctc35m05.socvstlaunum   , ctc35m05.socvstlautipcod,
                      ctc35m05.socvstlautipdes, ctc35m05.viginc,
                      ctc35m05.vigfnl         , ctc35m05.caddat,
                      ctc35m05.cadfunnom      , ctc35m05.cademp,
                      ctc35m05.cadmat         )

   clear form
   message ""

end function  # ctc35m05_inclui


#--------------------------------------------------------------------
function ctc35m05_input(operacao_aux, k_ctc35m05, ctc35m05)
#--------------------------------------------------------------------
   define operacao_aux        char(01)

   define  k_ctc35m05         record
           socvstlaunum       like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   define  ws                 record
           socvstlaunum       like datmvstlau.socvstlaunum ,
           socatuvignum       like datmvstlau.socvstlaunum ,
           socprxviginc       like datmvstlau.viginc,
           socvigfnl          like datmvstlau.viginc,
           socvstlautipsit    like datkvstlautip.socvstlautipsit
   end record

   let int_flag = false
   initialize  ws.*   to null

   let ws.socatuvignum = 0
   if ctc35m05.socvstlaunum  is not null    then
      let ws.socatuvignum = ctc35m05.socvstlaunum
   end if

   input by name ctc35m05.socvstlaunum,
                 ctc35m05.socvstlautipcod,
                 ctc35m05.viginc,
                 ctc35m05.vigfnl   without defaults

   before field socvstlaunum
          if operacao_aux = "a"   then
             if ctc35m05.viginc  <=  today   then   ## ja'
                next field vigfnl                   ## vigente
             end if                                 ## nao modifica
          end if
          next field socvstlautipcod
          display by name ctc35m05.socvstlaunum    attribute (reverse)

   after field socvstlaunum
          display by name ctc35m05.socvstlaunum

   before field socvstlautipcod
          display by name ctc35m05.socvstlautipcod attribute (reverse)

   after field socvstlautipcod
          display by name ctc35m05.socvstlautipcod

          if ctc35m05.socvstlautipcod  is null   then
             error " Codigo do tipo de laudo deve ser informado!"
             call ctc35m09()  returning ctc35m05.socvstlautipcod
             next field socvstlautipcod
          end if

          select socvstlautipdes, socvstlautipsit
            into ctc35m05.socvstlautipdes, ws.socvstlautipsit
            from datkvstlautip
           where datkvstlautip.socvstlautipcod = ctc35m05.socvstlautipcod

          if sqlca.sqlcode = notfound   then
             error " Tipo de laudo nao cadastrado!"
             call ctc35m09()  returning ctc35m05.socvstlautipcod
             next field socvstlautipcod
          else
             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura do cad.Tipo de laudo"
                next field socvstlautipcod
             else
                display by name ctc35m05.socvstlautipdes
             end if
          end if

          if ws.socvstlautipsit <> "A"    then
             error " Tipo de laudo informado nao esta' ativo!"
             next field socvstlautipcod
          end if

          if operacao_aux = "i"   then
             select * from datmvstlau
              where socvstlautipcod  = ctc35m05.socvstlautipcod
                and viginc           > today

             if sqlca.sqlcode = 0   then
                error " Ja' existe LAUDO vigente para este TIPO DE LAUDO informado!"
                next field socvstlautipcod
             end if
          end if

   before field viginc
          display by name ctc35m05.viginc  attribute(reverse)

   after field viginc
          display by name ctc35m05.viginc

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field socvstlautipcod
          end if

          # BUSCA ULTIMA VIGENCIA DO TIPO DE LAUDO
          #---------------------------------------
          initialize  ws.socprxviginc   to null
          select max(vigfnl)
            into ws.socprxviginc
            from datmvstlau
           where socvstlautipcod  =  ctc35m05.socvstlautipcod
             and socvstlaunum     <> ws.socatuvignum

          if ws.socprxviginc  is not null   then
             let ws.socprxviginc = ws.socprxviginc + 1 units day
          else
             let ws.socprxviginc = today + 1 units day
          end if

          if ctc35m05.viginc  is null   then
             if ws.socprxviginc  is not null   then
                let ctc35m05.viginc = ws.socprxviginc
                error " Proxima vigencia inicial p/ tipo de laudo informado, tecle ENTER"
                next field viginc
             else
                error " Vigencia inicial deve ser informada!"
                next field viginc
             end if
          end if

          if ctc35m05.viginc  <  today  then
             error " Vigencia inicial nao deve ser menor que hoje!"
             next field viginc
          end if

          initialize ws.socvstlaunum   to null
          select socvstlaunum
            into ws.socvstlaunum
            from datmvstlau
           where datmvstlau.socvstlautipcod = ctc35m05.socvstlautipcod
             and ctc35m05.viginc between    viginc and vigfnl
             and datmvstlau.socvstlaunum    <> ws.socatuvignum

          if sqlca.sqlcode  =  0   then
             error " Vigencia inicial ja' compreendida em outra vigencia!"
             next field viginc
          end if

          if ctc35m05.viginc < ws.socprxviginc    then
             error " Vigencia inicial nao deve ser menor que a ultima vigencia final!"
             next field viginc
          end if

          if ctc35m05.viginc > ws.socprxviginc    then
             error " Entre duas vigencias nao devem existir dias vagos!"
             next field viginc
          end if

   before field vigfnl
          display by name ctc35m05.vigfnl attribute (reverse)

   after field vigfnl
          display by name ctc35m05.vigfnl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if operacao_aux = "a"                    and
                ctc35m05.viginc  <=  today   then
                error " Laudo em vigencia nao deve ser alterado!"
                next field vigfnl
             else
                next field viginc
             end if
          end if

          if ctc35m05.vigfnl  is null   then
             error " Vigencia final deve ser informada!"
             next field vigfnl
          end if

          if ctc35m05.vigfnl  <  today  then
             error " Vigencia final nao deve ser menor que hoje!"
             next field vigfnl
          end if

          if ctc35m05.vigfnl  <=  ctc35m05.viginc  then
             error " Vig. final nao deve ser menor ou igual a Vig. inicial!"
             next field vigfnl
          end if

          select * from  datmvstlau
           where datmvstlau.socvstlautipcod =  ctc35m05.socvstlautipcod
             and ctc35m05.vigfnl between       viginc and vigfnl
             and datmvstlau.socvstlaunum    <> ws.socatuvignum

          if sqlca.sqlcode = 0    then
             error " Vigencia final ja' compreendida em outra vigencia!"
             next field vigfnl
          end if


          # NO MOMENTO DO FECHAMENTO DA VIGENCIA, ENTRE VIGENCIA FINAL(ATUAL)
          # E A PROXIMA VIGENCIA INICIAL NAO DEVEM EXISTIR DIAS VAGOS
          #-----------------------------------------------------------
          select viginc
            into ws.socvigfnl
            from datmvstlau
           where datmvstlau.socvstlautipcod  = ctc35m05.socvstlautipcod
             and datmvstlau.viginc           > ctc35m05.viginc

          if ws.socvigfnl   is not null   then
             let ws.socvigfnl = ws.socvigfnl - 1 units day
             if ctc35m05.vigfnl <> ws.socvigfnl   then
                error " Entre vig final e inicio da proxima vig existem dias vagos!"
                next field vigfnl
             end if
          end if

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc35m05.*  to null
      return ctc35m05.*
   end if

   return ctc35m05.*

end function   # ctc35m05_input


#---------------------------------------------------------
function ctc35m05_ler(k_ctc35m05)
#---------------------------------------------------------

   define  k_ctc35m05         record
           socvstlaunum       like datmvstlau.socvstlaunum
   end record

   define  ctc35m05           record
           socvstlaunum       like datmvstlau.socvstlaunum,
           socvstlautipcod    like datmvstlau.socvstlautipcod,
           socvstlautipdes    like datkvstlautip.socvstlautipdes,
           viginc             like datmvstlau.viginc,
           vigfnl             like datmvstlau.vigfnl,
           caddat             like datmvstlau.caddat,
           cadfunnom          like isskfunc.funnom,
           cademp             like datmvstlau.cademp,
           cadmat             like datmvstlau.cadmat
   end record

   initialize ctc35m05.*   to null

   select socvstlaunum         , socvstlautipcod,
          viginc               , vigfnl,
          caddat               , cademp,
          cadmat
     into ctc35m05.socvstlaunum, ctc35m05.socvstlautipcod,
          ctc35m05.viginc      , ctc35m05.vigfnl,
          ctc35m05.caddat      , ctc35m05.cademp,
          ctc35m05.cadmat
     from datmvstlau
    where datmvstlau.socvstlaunum = k_ctc35m05.socvstlaunum

   if sqlca.sqlcode = 0   then
      select funnom
        into ctc35m05.cadfunnom
        from isskfunc
       where isskfunc.funmat = ctc35m05.cadmat

      select socvstlautipdes
        into ctc35m05.socvstlautipdes
        from datkvstlautip
       where datkvstlautip.socvstlautipcod = ctc35m05.socvstlautipcod
   else
      error " Laudo nao encontrado!"
      initialize ctc35m05.*    to null
      initialize k_ctc35m05.*  to null
   end if

   return ctc35m05.*

end function   # ctc35m05_ler


#---------------------------------------------------------------
  function ctc35m05_display(par2_socvstlaunum)
#---------------------------------------------------------------
  define par2_socvstlaunum like datmvstlau.socvstlaunum

  define a_ctc35m05  array[250] of record
     socvstitmgrpcod like datrvstitmver.socvstitmgrpcod,
     socvstitmgrpdes like datkvstitmgrp.socvstitmgrpdes,
     socvstitmcod    like datrvstitmver.socvstitmcod,
     socvstitmdes    like datkvstitm.socvstitmdes,
     socvstitmvercod like datrvstitmver.socvstitmvercod,
     socvstitmverdes like datkvstitmver.socvstitmverdes,
     socvstitmrevflg like datrvstitmver.socvstitmrevflg
  end record

  define arr_aux        integer

  initialize a_ctc35m05  to null
  let arr_aux = 1

  declare c_ctc35m05 cursor for
     select datrvstitmver.socvstitmgrpcod,
            datkvstitmgrp.socvstitmgrpdes,
            datrvstitmver.socvstitmcod,
            datkvstitm.socvstitmdes,
            datrvstitmver.socvstitmvercod,
            datkvstitmver.socvstitmverdes,
            datrvstitmver.socvstitmrevflg
       from datrvstitmver, datkvstitmgrp, datkvstitm, datkvstitmver
      where datrvstitmver.socvstlaunum    = par2_socvstlaunum
        and datkvstitmgrp.socvstitmgrpcod = datrvstitmver.socvstitmgrpcod
        and datkvstitm.socvstitmcod       = datrvstitmver.socvstitmcod
        and datkvstitmver.socvstitmvercod = datrvstitmver.socvstitmvercod
   order by datrvstitmver.socvstitmgrpcod,
            datrvstitmver.socvstitmcod,
            datrvstitmver.socvstitmvercod

   foreach c_ctc35m05 into a_ctc35m05[arr_aux].socvstitmgrpcod,
                           a_ctc35m05[arr_aux].socvstitmgrpdes,
                           a_ctc35m05[arr_aux].socvstitmcod,
                           a_ctc35m05[arr_aux].socvstitmdes,
                           a_ctc35m05[arr_aux].socvstitmvercod,
                           a_ctc35m05[arr_aux].socvstitmverdes,
                           a_ctc35m05[arr_aux].socvstitmrevflg

     let arr_aux = arr_aux + 1
     if arr_aux > 250 then
        error " Limite excedido, laudo com mais de 250 grupos/itens"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)
  message " (F17)Abandona"

  display array  a_ctc35m05 to s_ctc35m05.*
     on key(interrupt)
        let int_flag = false
        exit display
  end display
  message ""

end function  #  ctc35m05_display


