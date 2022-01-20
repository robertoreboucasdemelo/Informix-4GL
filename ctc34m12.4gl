#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M12                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE DISPLAY DO VEICULO.              #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 24/02/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc34m12_prep smallint

  define mr_display record
         dpycod       like dpakdpy.dpycod,
         dpydes       like dpakdpy.dpydes,
         caddat       like dpakdpy.caddat,
         cademp       like dpakdpy.cademp,
         cadmat       like dpakdpy.cadmat,
         funnom_cad   like isskfunc.funnom,
         funnom_atl   like isskfunc.funnom,
         atldat       like dpakdpy.atldat,
         atlemp       like dpakdpy.atlemp,
         atlmat       like dpakdpy.atlmat,
         cadusrtip    like dpakdpy.cadusrtip,
         atlusrtip    like dpakdpy.atlusrtip
  end record

#-------------------------#
function ctc34m12_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select dpycod, ",
                     " dpydes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip ",
                " from dpakdpy ",
               " where dpycod = ? "

  prepare pctc34m12001 from l_sql
  declare cctc34m12001 cursor for pctc34m12001

  let l_sql = " insert ",
                " into dpakdpy ",
                    " (dpycod, ",
                     " dpydes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip) ",
              " values(?, ?, today, ?, ?, null, null, null, ?, null) "

  prepare pctc34m12002 from l_sql

  let l_sql = " update ",
                     " dpakdpy set(dpydes, ",
                                 " atldat, ",
                                 " atlemp, ",
                                 " atlmat, ",
                                 " atlusrtip) = (?, today, ?, ?, ?) ",
                           " where dpycod = ? "

  prepare pctc34m12003 from l_sql

  let l_sql = " delete ",
                " from dpakdpy ",
               " where dpycod = ? "

  prepare pctc34m12004 from l_sql

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? ",
                 " and usrtip = ? "

  prepare pctc34m12005 from l_sql
  declare cctc34m12005 cursor for pctc34m12005

  let l_sql = " select min(dpycod) ",
                " from dpakdpy ",
               " where dpycod > ? "

  prepare pctc34m12006 from l_sql
  declare cctc34m12006 cursor for pctc34m12006

  let l_sql = " select max(dpycod) ",
                " from dpakdpy ",
               " where dpycod < ? "

  prepare pctc34m12007 from l_sql
  declare cctc34m12007 cursor for pctc34m12007

  let l_sql = " select max(dpycod) ",
                " from dpakdpy "

  prepare pctc34m12008 from l_sql
  declare cctc34m12008 cursor for pctc34m12008

  let m_ctc34m12_prep = true

end function

#-----------------#
function ctc34m12()
#-----------------#

  if m_ctc34m12_prep is null or
     m_ctc34m12_prep <> true then
     call ctc34m12_prepare()
  end if

  initialize mr_display to null

  call ctc34m12_menu()

end function

#-------------------------#
function ctc34m12_display()
#-------------------------#

  display by name mr_display.dpycod,
                  mr_display.dpydes,
                  mr_display.caddat,
                  mr_display.funnom_cad,
                  mr_display.funnom_atl,
                  mr_display.atldat

end function

#----------------------#
function ctc34m12_menu()
#----------------------#

  define l_salva_cod    like dpakdpy.dpycod,
         l_resposta char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_salva_cod  =  null
        let     l_resposta  =  null

  let l_salva_cod = null
  let l_resposta  = null

  initialize mr_display to null

  open window w_ctc34m12 at 4,2 with form "ctc34m12"

  menu "DISPLAY"

     command key("S") "Selecionar" "Seleciona um display"

             initialize mr_display to null

             call ctc34m12_display()

             call ctc34m12_entra_dados("S")

             if mr_display.dpycod is not null then
                call ctc34m12_operacao("S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona o display anterior ao selecionado"

             if mr_display.dpycod is null then
                error "Selecione um display"
                next option "Selecionar"
             else
                let l_salva_cod = mr_display.dpycod

                open cctc34m12007 using mr_display.dpycod
                fetch cctc34m12007 into mr_display.dpycod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m12007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m12_menu() / ", mr_display.dpycod sleep 3
                end if

                close cctc34m12007

                if mr_display.dpycod is not null then
                   call ctc34m12_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_display.dpycod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona o proximo display em relacao ao selecionado"

             if mr_display.dpycod is null then
                error "Selecione um display"
                next option "Selecionar"
             else

                let l_salva_cod = mr_display.dpycod

                open cctc34m12006 using mr_display.dpycod
                whenever error continue
                fetch cctc34m12006 into mr_display.dpycod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m12006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m12_menu() / ", mr_display.dpycod sleep 3
                end if

                close cctc34m12006

                if mr_display.dpycod is not null then
                   call ctc34m12_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_display.dpycod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("I") "Incluir" "Inclui um novo display"

             initialize mr_display to null
             clear form

             call ctc34m12_entra_dados("I")

             if mr_display.dpycod is not null then
                call ctc34m12_operacao("I")
                call ctc34m12_operacao("S")
             else
                clear form
                error "Inclusao cancelada"
             end if

     command key("M") "Modificar" "Modifica o display selecionado"

             if mr_display.dpycod is null then
                error "Selecione um display"
                next option "Selecionar"
             else
               let l_salva_cod = mr_display.dpycod

               call ctc34m12_entra_dados("M")

               if mr_display.dpycod is not null then
                  call ctc34m12_operacao("M")
               else
                  let mr_display.dpycod = l_salva_cod
                  error "Modificacao cancelada"
               end if

               call ctc34m12_operacao("S")

            end if

     command key("X") "eXcluir" "Exclui o display selecionado"

             if mr_display.dpycod is not null then

                let l_resposta = "E"

                while l_resposta <> "S" and
                      l_resposta <> "N"

                   prompt "Deseja excluir o display selecionado ?" for l_resposta
                   let l_resposta = upshift(l_resposta)

                   if l_resposta is null or
                      l_resposta = " " then
                      let l_resposta = "E"
                   end if

                end while

                if l_resposta = "S" then
                   call ctc34m12_operacao("X")
                   next option "Selecionar"
                end if

             else
                error "Selecione um display"
                next option "Selecionar"
             end if


     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m12

  let int_flag = false

end function

#--------------------------------------------#
function ctc34m12_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01)



  input mr_display.dpycod,
        mr_display.dpydes without defaults from dpycod, dpydes

     before field dpycod

        if l_tipo_operacao = "M" then # ---> MODIFICAR
           next field dpydes
        end if

        if l_tipo_operacao = "I" then # ---> INCLUIR
           let mr_display.dpycod = ctc34m12_max_codigo()
           display by name mr_display.dpycod
           next field dpydes
        end if

        display by name mr_display.dpycod attribute(reverse)

     after field dpycod
        display by name mr_display.dpycod

        if  mr_display.dpycod is null then
            error "Informe o codigo do display"
            next field dpycod
        end if

        if l_tipo_operacao = "S" then # ---> SELECIONAR
           exit input
        end if

     before field dpydes
        display by name mr_display.dpydes attribute(reverse)

     after field dpydes
        display by name mr_display.dpydes

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field dpydes
        end if

        if mr_display.dpydes is null or
           mr_display.dpydes = " " then
           error "Informe a descricao do display"
           next field dpydes
        end if

     on key(f17, control-c, interrupt)
        initialize mr_display to null
        exit input

  end input

end function

#-----------------------------------------#
function ctc34m12_operacao(l_tipo_operacao)
#-----------------------------------------#

  define l_tipo_operacao char(01)

  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "I" INCLUIR
   "M" MODIFICAR
   "X" EXCLUIR}



  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m12001 using mr_display.dpycod
        whenever error continue
        fetch cctc34m12001 into mr_display.dpycod,
                                mr_display.dpydes,
                                mr_display.caddat,
                                mr_display.cademp,
                                mr_display.cadmat,
                                mr_display.atldat,
                                mr_display.atlemp,
                                mr_display.atlmat,
                                mr_display.cadusrtip,
                                mr_display.atlusrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhum display encontrado para o codigo informado"
              initialize mr_display to null
           else
              error "Erro SELECT cctc34m12001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m12_operacao() / ", mr_display.dpycod sleep 3
           end if
        else

           # --> BUSCA O NOME DO FUNCIONARIO QUE CADASTROU
           let mr_display.funnom_cad = ctc34m12_nome_funcio(mr_display.cademp,
                                                              mr_display.cadmat,
                                                              mr_display.cadusrtip)

           # --> BUSCA O NOME DO FUNCIONARIO QUE ATUALIZOU
           let mr_display.funnom_atl = ctc34m12_nome_funcio(mr_display.atlemp,
                                                              mr_display.atlmat,
                                                              mr_display.atlusrtip)
        end if

        close cctc34m12001

        call ctc34m12_display()

     when("I") # ---> INCLUIR

        whenever error continue
        execute pctc34m12002 using mr_display.dpycod,
                                   mr_display.dpydes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = -268 then
              error "Inclusao cancelada, codigo ja existe. Selecione novamente a opcao 'Incluir'" sleep 4
              initialize mr_display to null
           else
              error "Erro INSERT pctc34m12002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m12_operacao() / ", mr_display.dpycod, "/",
                                              mr_display.dpydes, "/",
                                              g_issk.empcod, "/",
                                              g_issk.funmat, "/",
                                              g_issk.empcod, "/",
                                              g_issk.usrtip sleep 3

           end if
        else
           error "Display incluido com sucesso"
        end if

     when("M") # ---> MODIFICAR

        whenever error continue
        execute pctc34m12003 using mr_display.dpydes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip,
                                   mr_display.dpycod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m12003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m12_operacao() / ", mr_display.dpydes, "/",
                                           g_issk.empcod,       "/",
                                           g_issk.funmat,       "/",
                                           g_issk.usrtip,       "/",
                                           mr_display.dpycod sleep 3
        else
           error "Display modificado com sucesso"
        end if

     when("X") # ---> EXCLUIR

        whenever error continue
        execute pctc34m12004 using mr_display.dpycod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc34m12004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m12_operacao() / ", mr_display.dpycod sleep 3
        else
           error "Display excluido com sucesso"
           initialize mr_display to null
           clear form
        end if

  end case

end function

#-----------------------------------------#
function ctc34m12_nome_funcio(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         empcod       like isskfunc.empcod,
         funmat       like isskfunc.funmat,
         usrtip       like isskfunc.usrtip
  end record

  define l_funnom like isskfunc.funnom


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_funnom  =  null

  let l_funnom = null

  open cctc34m12005 using lr_parametro.empcod,
                          lr_parametro.funmat,
                          lr_parametro.usrtip
  whenever error continue
  fetch cctc34m12005 into l_funnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_funnom = null
     if sqlca.sqlcode <> notfound then
        error "Erro SELECT cctc34m12005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m12_nome_funcio() / ", lr_parametro.empcod, "/",
                                           lr_parametro.funmat, "/",
                                           lr_parametro.usrtip  sleep 3
     end if
  end if

  close cctc34m12005

  return l_funnom

end function

#----------------------------#
function ctc34m12_max_codigo()
#----------------------------#

  define l_max_codigo smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_max_codigo  =  null

  let l_max_codigo = null

  # ---> BUSCA O ULTIMO CODIGO CADASTRADO
  open cctc34m12008
  whenever error continue
  fetch cctc34m12008 into l_max_codigo
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro SELECT MAX cctc34m12008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "ctc34m12_max_codigo() " sleep 3
  end if

  close cctc34m12008

  if l_max_codigo is null then
     let l_max_codigo = 0
  end if

  let l_max_codigo = l_max_codigo + 1

  return l_max_codigo

end function
