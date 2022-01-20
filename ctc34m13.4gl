#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M13                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE PROBLEMA DE VISTORIA DO VEICULO. #
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

  define m_ctc34m13_prep smallint

  define mr_provistoria record
         vstpbmcod      like dpakpbmvst.vstpbmcod,
         vstpbmdes      like dpakpbmvst.vstpbmdes,
         caddat         like dpakpbmvst.caddat,
         cademp         like dpakpbmvst.cademp,
         cadmat         like dpakpbmvst.cadmat,
         funnom_cad     like isskfunc.funnom,
         funnom_atl     like isskfunc.funnom,
         atldat         like dpakpbmvst.atldat,
         atlemp         like dpakpbmvst.atlemp,
         atlmat         like dpakpbmvst.atlmat,
         cadusrtip      like dpakpbmvst.cadusrtip,
         atlusrtip      like dpakpbmvst.atlusrtip
  end record

#-------------------------#
function ctc34m13_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select vstpbmcod, ",
                     " vstpbmdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip ",
                " from dpakpbmvst ",
               " where vstpbmcod = ? "

  prepare pctc34m13001 from l_sql
  declare cctc34m13001 cursor for pctc34m13001

  let l_sql = " insert ",
                " into dpakpbmvst ",
                    " (vstpbmcod, ",
                     " vstpbmdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip) ",
              " values(?, ?, today, ?, ?, null, null, null, ?, null) "

  prepare pctc34m13002 from l_sql

  let l_sql = " update ",
                     " dpakpbmvst set(vstpbmdes, ",
                                 " atldat, ",
                                 " atlemp, ",
                                 " atlmat, ",
                                 " atlusrtip) = (?, today, ?, ?, ?) ",
                           " where vstpbmcod = ? "

  prepare pctc34m13003 from l_sql

  let l_sql = " delete ",
                " from dpakpbmvst ",
               " where vstpbmcod = ? "

  prepare pctc34m13004 from l_sql

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? ",
                 " and usrtip = ? "

  prepare pctc34m13005 from l_sql
  declare cctc34m13005 cursor for pctc34m13005

  let l_sql = " select min(vstpbmcod) ",
                " from dpakpbmvst ",
               " where vstpbmcod > ? "

  prepare pctc34m13006 from l_sql
  declare cctc34m13006 cursor for pctc34m13006

  let l_sql = " select max(vstpbmcod) ",
                " from dpakpbmvst ",
               " where vstpbmcod < ? "

  prepare pctc34m13007 from l_sql
  declare cctc34m13007 cursor for pctc34m13007

  let l_sql = " select max(vstpbmcod) ",
                " from dpakpbmvst "

  prepare pctc34m13008 from l_sql
  declare cctc34m13008 cursor for pctc34m13008

  let m_ctc34m13_prep = true

end function

#-----------------#
function ctc34m13()
#-----------------#

  if m_ctc34m13_prep is null or
     m_ctc34m13_prep <> true then
     call ctc34m13_prepare()
  end if

  initialize mr_provistoria to null

  call ctc34m13_menu()

end function

#-------------------------#
function ctc34m13_display()
#-------------------------#

  display by name mr_provistoria.vstpbmcod,
                  mr_provistoria.vstpbmdes,
                  mr_provistoria.caddat,
                  mr_provistoria.funnom_cad,
                  mr_provistoria.funnom_atl,
                  mr_provistoria.atldat

end function

#----------------------#
function ctc34m13_menu()
#----------------------#

  define l_salva_cod    like dpakpbmvst.vstpbmcod,
         l_resposta char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_salva_cod  =  null
        let     l_resposta  =  null

  let l_salva_cod = null
  let l_resposta  = null

  initialize mr_provistoria to null

  open window w_ctc34m13 at 4,2 with form "ctc34m13"

  menu "PROBLEMA VISTORIA"

     command key("S") "Selecionar" "Seleciona um problema de vistoria"

             initialize mr_provistoria to null

             call ctc34m13_display()

             call ctc34m13_entra_dados("S")

             if mr_provistoria.vstpbmcod is not null then
                call ctc34m13_operacao("S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona o problema de vistoria anterior ao selecionado"

             if mr_provistoria.vstpbmcod is null then
                error "Selecione um problema de vistoria"
                next option "Selecionar"
             else
                let l_salva_cod = mr_provistoria.vstpbmcod

                open cctc34m13007 using mr_provistoria.vstpbmcod
                fetch cctc34m13007 into mr_provistoria.vstpbmcod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m13007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m13_menu() / ", mr_provistoria.vstpbmcod sleep 3
                end if

                close cctc34m13007

                if mr_provistoria.vstpbmcod is not null then
                   call ctc34m13_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_provistoria.vstpbmcod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona o proximo problema de vistoria em relacao ao selecionado"

             if mr_provistoria.vstpbmcod is null then
                error "Selecione um problema de vistoria"
                next option "Selecionar"
             else

                let l_salva_cod = mr_provistoria.vstpbmcod

                open cctc34m13006 using mr_provistoria.vstpbmcod
                whenever error continue
                fetch cctc34m13006 into mr_provistoria.vstpbmcod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m13006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m13_menu() / ", mr_provistoria.vstpbmcod sleep 3
                end if

                close cctc34m13006

                if mr_provistoria.vstpbmcod is not null then
                   call ctc34m13_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_provistoria.vstpbmcod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("I") "Incluir" "Inclui um novo problema de vistoria"

             initialize mr_provistoria to null
             clear form

             call ctc34m13_entra_dados("I")

             if mr_provistoria.vstpbmcod is not null then
                call ctc34m13_operacao("I")
                call ctc34m13_operacao("S")
             else
                clear form
                error "Inclusao cancelada"
             end if

     command key("M") "Modificar" "Modifica o problema de vistoria selecionado"

             if mr_provistoria.vstpbmcod is null then
                error "Selecione um problema de vistoria"
                next option "Selecionar"
             else
               let l_salva_cod = mr_provistoria.vstpbmcod

               call ctc34m13_entra_dados("M")

               if mr_provistoria.vstpbmcod is not null then
                  call ctc34m13_operacao("M")
               else
                  let mr_provistoria.vstpbmcod = l_salva_cod
                  error "Modificacao cancelada"
               end if

               call ctc34m13_operacao("S")

            end if

     command key("X") "eXcluir" "Exclui o problema de vistoria selecionado"

             if mr_provistoria.vstpbmcod is not null then

                let l_resposta = "E"

                while l_resposta <> "S" and
                      l_resposta <> "N"

                   prompt "Deseja excluir o problema de vistoria selecionado ?" for l_resposta
                   let l_resposta = upshift(l_resposta)

                   if l_resposta is null or
                      l_resposta = " " then
                      let l_resposta = "E"
                   end if

                end while

                if l_resposta = "S" then
                   call ctc34m13_operacao("X")
                   next option "Selecionar"
                end if

             else
                error "Selecione um problema de vistoria"
                next option "Selecionar"
             end if


     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m13

  let int_flag = false

end function

#--------------------------------------------#
function ctc34m13_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01)



  input mr_provistoria.vstpbmcod,
        mr_provistoria.vstpbmdes without defaults from vstpbmcod, vstpbmdes

     before field vstpbmcod

        if l_tipo_operacao = "M" then # ---> MODIFICAR
           next field vstpbmdes
        end if

        if l_tipo_operacao = "I" then # ---> INCLUIR
           let mr_provistoria.vstpbmcod = ctc34m13_max_codigo()
           display by name mr_provistoria.vstpbmcod
           next field vstpbmdes
        end if

        display by name mr_provistoria.vstpbmcod attribute(reverse)

     after field vstpbmcod
        display by name mr_provistoria.vstpbmcod

        if  mr_provistoria.vstpbmcod is null then
            error "Informe o codigo do problema de vistoria"
            next field vstpbmcod
        end if

        if l_tipo_operacao = "S" then # ---> SELECIONAR
           exit input
        end if

     before field vstpbmdes
        display by name mr_provistoria.vstpbmdes attribute(reverse)

     after field vstpbmdes
        display by name mr_provistoria.vstpbmdes

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field vstpbmdes
        end if

        if mr_provistoria.vstpbmdes is null or
           mr_provistoria.vstpbmdes = " " then
           error "Informe a descricao do problema de vistoria"
           next field vstpbmdes
        end if

     on key(f17, control-c, interrupt)
        initialize mr_provistoria to null
        exit input

  end input

end function

#-----------------------------------------#
function ctc34m13_operacao(l_tipo_operacao)
#-----------------------------------------#

  define l_tipo_operacao char(01)

  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "I" INCLUIR
   "M" MODIFICAR
   "X" EXCLUIR}



  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m13001 using mr_provistoria.vstpbmcod
        whenever error continue
        fetch cctc34m13001 into mr_provistoria.vstpbmcod,
                                mr_provistoria.vstpbmdes,
                                mr_provistoria.caddat,
                                mr_provistoria.cademp,
                                mr_provistoria.cadmat,
                                mr_provistoria.atldat,
                                mr_provistoria.atlemp,
                                mr_provistoria.atlmat,
                                mr_provistoria.cadusrtip,
                                mr_provistoria.atlusrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhum problema de vistoria encontrado para o codigo informado"
              initialize mr_provistoria to null
           else
              error "Erro SELECT cctc34m13001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m13_operacao() / ", mr_provistoria.vstpbmcod sleep 3
           end if
        else

           # --> BUSCA O NOME DO FUNCIONARIO QUE CADASTROU
           let mr_provistoria.funnom_cad = ctc34m13_nome_funcio(mr_provistoria.cademp,
                                                              mr_provistoria.cadmat,
                                                              mr_provistoria.cadusrtip)

           # --> BUSCA O NOME DO FUNCIONARIO QUE ATUALIZOU
           let mr_provistoria.funnom_atl = ctc34m13_nome_funcio(mr_provistoria.atlemp,
                                                              mr_provistoria.atlmat,
                                                              mr_provistoria.atlusrtip)
        end if

        close cctc34m13001

        call ctc34m13_display()

     when("I") # ---> INCLUIR

        whenever error continue
        execute pctc34m13002 using mr_provistoria.vstpbmcod,
                                   mr_provistoria.vstpbmdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = -268 then
             error "Inclusao cancelada, codigo ja existe. Selecione novamente a opcao 'Incluir'" sleep 4
             initialize mr_provistoria to null
           else
             error "Erro INSERT pctc34m13002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
             error "ctc34m13_operacao() / ", mr_provistoria.vstpbmcod, "/",
                                             mr_provistoria.vstpbmdes, "/",
                                             g_issk.empcod, "/",
                                             g_issk.funmat, "/",
                                             g_issk.empcod, "/",
                                             g_issk.usrtip sleep 3
           end if
        else
           error "Problema de Vistoria incluido com sucesso"
        end if

     when("M") # ---> MODIFICAR

        whenever error continue
        execute pctc34m13003 using mr_provistoria.vstpbmdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip,
                                   mr_provistoria.vstpbmcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m13003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m13_operacao() / ", mr_provistoria.vstpbmdes, "/",
                                           g_issk.empcod,       "/",
                                           g_issk.funmat,       "/",
                                           g_issk.usrtip,       "/",
                                           mr_provistoria.vstpbmcod sleep 3
        else
           error "Problema de Vistoria modificado com sucesso"
        end if

     when("X") # ---> EXCLUIR

        whenever error continue
        execute pctc34m13004 using mr_provistoria.vstpbmcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc34m13004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m13_operacao() / ", mr_provistoria.vstpbmcod sleep 3
        else
           error "Problema de vistoria excluido com sucesso"
           initialize mr_provistoria to null
           clear form
        end if

  end case

end function

#-----------------------------------------#
function ctc34m13_nome_funcio(lr_parametro)
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

  open cctc34m13005 using lr_parametro.empcod,
                          lr_parametro.funmat,
                          lr_parametro.usrtip
  whenever error continue
  fetch cctc34m13005 into l_funnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_funnom = null
     if sqlca.sqlcode <> notfound then
        error "Erro SELECT cctc34m13005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m13_nome_funcio() / ", lr_parametro.empcod, "/",
                                           lr_parametro.funmat, "/",
                                           lr_parametro.usrtip  sleep 3
     end if
  end if

  close cctc34m13005

  return l_funnom

end function

#----------------------------#
function ctc34m13_max_codigo()
#----------------------------#

  define l_max_codigo smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_max_codigo  =  null

  let l_max_codigo = null

  # ---> BUSCA O ULTIMO CODIGO CADASTRADO
  open cctc34m13008
  whenever error continue
  fetch cctc34m13008 into l_max_codigo
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro SELECT MAX cctc34m13008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "ctc34m13_max_codigo() " sleep 3
  end if

  close cctc34m13008

  if l_max_codigo is null then
     let l_max_codigo = 0
  end if

  let l_max_codigo = l_max_codigo + 1

  return l_max_codigo

end function
