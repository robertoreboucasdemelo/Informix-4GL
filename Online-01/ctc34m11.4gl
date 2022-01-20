#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M11                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE BACKLIGHT DO VEICULO.            #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 22/02/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc34m11_prep smallint

  define mr_backlight record
         bckcod       like dpakbck.bckcod,
         bckdes       like dpakbck.bckdes,
         caddat       like dpakbck.caddat,
         cademp       like dpakbck.cademp,
         cadmat       like dpakbck.cadmat,
         funnom_cad   like isskfunc.funnom,
         funnom_atl   like isskfunc.funnom,
         atldat       like dpakbck.atldat,
         atlemp       like dpakbck.atlemp,
         atlmat       like dpakbck.atlmat,
         cadusrtip    like dpakbck.cadusrtip,
         atlusrtip    like dpakbck.atlusrtip
  end record

#-------------------------#
function ctc34m11_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select bckcod, ",
                     " bckdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip ",
                " from dpakbck ",
               " where bckcod = ? "

  prepare pctc34m11001 from l_sql
  declare cctc34m11001 cursor for pctc34m11001

  let l_sql = " insert ",
                " into dpakbck ",
                    " (bckcod, ",
                     " bckdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip) ",
              " values(?, ?, today, ?, ?, null, null, null, ?, null) "

  prepare pctc34m11002 from l_sql

  let l_sql = " update ",
                     " dpakbck set(bckdes, ",
                                 " atldat, ",
                                 " atlemp, ",
                                 " atlmat, ",
                                 " atlusrtip) = (?, today, ?, ?, ?) ",
                           " where bckcod = ? "

  prepare pctc34m11003 from l_sql

  let l_sql = " delete ",
                " from dpakbck ",
               " where bckcod = ? "

  prepare pctc34m11004 from l_sql

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? ",
                 " and usrtip = ? "

  prepare pctc34m11005 from l_sql
  declare cctc34m11005 cursor for pctc34m11005

  let l_sql = " select min(bckcod) ",
                " from dpakbck ",
               " where bckcod > ? "

  prepare pctc34m11006 from l_sql
  declare cctc34m11006 cursor for pctc34m11006

  let l_sql = " select max(bckcod) ",
                " from dpakbck ",
               " where bckcod < ? "

  prepare pctc34m11007 from l_sql
  declare cctc34m11007 cursor for pctc34m11007

  let l_sql = " select max(bckcod) ",
                " from dpakbck "

  prepare pctc34m11008 from l_sql
  declare cctc34m11008 cursor for pctc34m11008

  let m_ctc34m11_prep = true

end function

#-----------------#
function ctc34m11()
#-----------------#

  if m_ctc34m11_prep is null or
     m_ctc34m11_prep <> true then
     call ctc34m11_prepare()
  end if

  initialize mr_backlight to null

  call ctc34m11_menu()

end function

#-------------------------#
function ctc34m11_display()
#-------------------------#

  display by name mr_backlight.bckcod,
                  mr_backlight.bckdes,
                  mr_backlight.caddat,
                  mr_backlight.funnom_cad,
                  mr_backlight.funnom_atl,
                  mr_backlight.atldat

end function

#----------------------#
function ctc34m11_menu()
#----------------------#

  define l_salva_cod    like dpakbck.bckcod,
         l_resposta     char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_salva_cod  =  null
        let     l_resposta  =  null

  let l_salva_cod = null
  let l_resposta  = null

  initialize mr_backlight to null

  open window w_ctc34m11 at 4,2 with form "ctc34m11"

  menu "BACKLIGHT"

     command key("S") "Selecionar" "Seleciona um backlight"

             initialize mr_backlight to null

             call ctc34m11_display()

             call ctc34m11_entra_dados("S")

             if mr_backlight.bckcod is not null then
                call ctc34m11_operacao("S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona o backlight anterior ao selecionado"

             if mr_backlight.bckcod is null then
                error "Selecione um backlight"
                next option "Selecionar"
             else
                let l_salva_cod = mr_backlight.bckcod

                open cctc34m11007 using mr_backlight.bckcod
                fetch cctc34m11007 into mr_backlight.bckcod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m11007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m11_menu() / ", mr_backlight.bckcod sleep 3
                end if

                close cctc34m11007

                if mr_backlight.bckcod is not null then
                   call ctc34m11_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_backlight.bckcod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona o proximo backlight em relacao ao selecionado"

             if mr_backlight.bckcod is null then
                error "Selecione um backlight"
                next option "Selecionar"
             else

                let l_salva_cod = mr_backlight.bckcod

                open cctc34m11006 using mr_backlight.bckcod
                whenever error continue
                fetch cctc34m11006 into mr_backlight.bckcod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m11006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m11_menu() / ", mr_backlight.bckcod sleep 3
                end if

                close cctc34m11006

                if mr_backlight.bckcod is not null then
                   call ctc34m11_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_backlight.bckcod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("I") "Incluir" "Inclui um novo backlight"

             initialize mr_backlight to null
             clear form

             call ctc34m11_entra_dados("I")

             if mr_backlight.bckcod is not null then
                call ctc34m11_operacao("I")

                if mr_backlight.bckcod is not null then
                   call ctc34m11_operacao("S")
                end if

             else
                clear form
                error "Inclusao cancelada"
             end if

     command key("M") "Modificar" "Modifica o backlight selecionado"

             if mr_backlight.bckcod is null then
                error "Selecione um backlight"
                next option "Selecionar"
             else
               let l_salva_cod = mr_backlight.bckcod

               call ctc34m11_entra_dados("M")

               if mr_backlight.bckcod is not null then
                  call ctc34m11_operacao("M")
               else
                  let mr_backlight.bckcod = l_salva_cod
                  error "Modificacao cancelada"
               end if

               call ctc34m11_operacao("S")

            end if

     command key("X") "eXcluir" "Exclui o backlight selecionado"

             if mr_backlight.bckcod is not null then

                let l_resposta = "E"

                while l_resposta <> "S" and
                      l_resposta <> "N"

                   prompt "Deseja excluir o backlight selecionado ?" for l_resposta
                   let l_resposta = upshift(l_resposta)

                   if l_resposta is null or
                      l_resposta = " " then
                      let l_resposta = "E"
                   end if

                end while

                if l_resposta = "S" then
                   call ctc34m11_operacao("X")
                   next option "Selecionar"
                end if

             else
                error "Selecione um backlight"
                next option "Selecionar"
             end if


     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m11

  let int_flag = false

end function

#----------------------------#
function ctc34m11_max_codigo()
#----------------------------#

  define l_max_codigo smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_max_codigo  =  null

  let l_max_codigo = null

  # ---> BUSCA O ULTIMO CODIGO CADASTRADO
  open cctc34m11008
  whenever error continue
  fetch cctc34m11008 into l_max_codigo
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro SELECT MAX cctc34m11008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "ctc34m11_max_codigo() " sleep 3
  end if

  close cctc34m11008

  if l_max_codigo is null then
     let l_max_codigo = 0
  end if

  let l_max_codigo = l_max_codigo + 1

  return l_max_codigo

end function

#--------------------------------------------#
function ctc34m11_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01)



  input mr_backlight.bckcod,
        mr_backlight.bckdes without defaults from bckcod, bckdes

     before field bckcod

        if l_tipo_operacao = "M" then # ---> MODIFICAR
           next field bckdes
        end if

        if l_tipo_operacao = "I" then # ---> INCLUIR
           let mr_backlight.bckcod = ctc34m11_max_codigo()
           display by name mr_backlight.bckcod
           next field bckdes
        end if

        display by name mr_backlight.bckcod attribute(reverse)

     after field bckcod
        display by name mr_backlight.bckcod

        if  mr_backlight.bckcod is null then
            error "Informe o codigo do backlight"
            next field bckcod
        end if

        if l_tipo_operacao = "S" then # ---> SELECIONAR
           exit input
        end if

     before field bckdes
        display by name mr_backlight.bckdes attribute(reverse)

     after field bckdes
        display by name mr_backlight.bckdes

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field bckdes
        end if

        if mr_backlight.bckdes is null or
           mr_backlight.bckdes = " " then
           error "Informe a descricao do backlight"
           next field bckdes
        end if

     on key(f17, control-c, interrupt)
        initialize mr_backlight to null
        exit input

  end input

end function

#-----------------------------------------#
function ctc34m11_operacao(l_tipo_operacao)
#-----------------------------------------#

  define l_tipo_operacao char(01)

  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "I" INCLUIR
   "M" MODIFICAR
   "X" EXCLUIR}



  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m11001 using mr_backlight.bckcod
        whenever error continue
        fetch cctc34m11001 into mr_backlight.bckcod,
                                mr_backlight.bckdes,
                                mr_backlight.caddat,
                                mr_backlight.cademp,
                                mr_backlight.cadmat,
                                mr_backlight.atldat,
                                mr_backlight.atlemp,
                                mr_backlight.atlmat,
                                mr_backlight.cadusrtip,
                                mr_backlight.atlusrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhum backlight encontrado para o codigo informado"
              initialize mr_backlight to null
           else
              error "Erro SELECT cctc34m11001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m11_operacao() / ", mr_backlight.bckcod sleep 3
           end if
        else

           # --> BUSCA O NOME DO FUNCIONARIO QUE CADASTROU
           let mr_backlight.funnom_cad = ctc34m11_nome_funcio(mr_backlight.cademp,
                                                              mr_backlight.cadmat,
                                                              mr_backlight.cadusrtip)

           # --> BUSCA O NOME DO FUNCIONARIO QUE ATUALIZOU
           let mr_backlight.funnom_atl = ctc34m11_nome_funcio(mr_backlight.atlemp,
                                                              mr_backlight.atlmat,
                                                              mr_backlight.atlusrtip)
        end if

        close cctc34m11001

        call ctc34m11_display()

     when("I") # ---> INCLUIR

        whenever error continue
        execute pctc34m11002 using mr_backlight.bckcod,
                                   mr_backlight.bckdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then

           if sqlca.sqlcode = -268 then
              error "Inclusao cancelada, codigo ja existe. Selecione novamente a opcao 'Incluir'" sleep 4
              initialize mr_backlight to null
           else
              error "Erro INSERT pctc34m11002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m11_operacao() / ", mr_backlight.bckcod, "/",
                                              mr_backlight.bckdes, "/",
                                              g_issk.empcod, "/",
                                              g_issk.funmat, "/",
                                              g_issk.empcod, "/",
                                              g_issk.usrtip sleep 3
           end if

        else
           error "Backlight incluido com sucesso"
        end if

     when("M") # ---> MODIFICAR

        whenever error continue
        execute pctc34m11003 using mr_backlight.bckdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip,
                                   mr_backlight.bckcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m11003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m11_operacao() / ", mr_backlight.bckdes, "/",
                                           g_issk.empcod,       "/",
                                           g_issk.funmat,       "/",
                                           g_issk.usrtip,       "/",
                                           mr_backlight.bckcod sleep 3
        else
           error "Backlight modificado com sucesso"
        end if

     when("X") # ---> EXCLUIR

        whenever error continue
        execute pctc34m11004 using mr_backlight.bckcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc34m11004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m11_operacao() / ", mr_backlight.bckcod sleep 3
        else
           error "Backlight excluido com sucesso"
           initialize mr_backlight to null
           clear form
        end if

  end case

end function

#-----------------------------------------#
function ctc34m11_nome_funcio(lr_parametro)
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

  open cctc34m11005 using lr_parametro.empcod,
                          lr_parametro.funmat,
                          lr_parametro.usrtip
  whenever error continue
  fetch cctc34m11005 into l_funnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_funnom = null
     if sqlca.sqlcode <> notfound then
        error "Erro SELECT cctc34m11005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m11_nome_funcio() / ", lr_parametro.empcod, "/",
                                           lr_parametro.funmat, "/",
                                           lr_parametro.usrtip  sleep 3
     end if
  end if

  close cctc34m11005

  return l_funnom

end function
