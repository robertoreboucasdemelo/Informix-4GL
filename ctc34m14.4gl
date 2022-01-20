#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M14                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE SITUACAO DE VISTORIA DO VEICULO. #
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

  define m_ctc34m14_prep smallint

  define mr_sitvistoria record
         vstsitcod      like dpaksitvst.vstsitcod,
         vstsitdes      like dpaksitvst.vstsitdes,
         caddat         like dpaksitvst.caddat,
         cademp         like dpaksitvst.cademp,
         cadmat         like dpaksitvst.cadmat,
         funnom_cad     like isskfunc.funnom,
         funnom_atl     like isskfunc.funnom,
         atldat         like dpaksitvst.atldat,
         atlemp         like dpaksitvst.atlemp,
         atlmat         like dpaksitvst.atlmat,
         cadusrtip      like dpaksitvst.cadusrtip,
         atlusrtip      like dpaksitvst.atlusrtip,
         blqvclflg      like dpaksitvst.blqvclflg
  end record

#-------------------------#
function ctc34m14_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select vstsitcod, ",
                     " vstsitdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip, ",
                     " blqvclflg ",
                " from dpaksitvst ",
               " where vstsitcod = ? "

  prepare pctc34m14001 from l_sql
  declare cctc34m14001 cursor for pctc34m14001

  let l_sql = " insert ",
                " into dpaksitvst ",
                    " (vstsitcod, ",
                     " vstsitdes, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " cadusrtip, ",
                     " atlusrtip, ",
                     " blqvclflg) ",
              " values(?, ?, today, ?, ?, null, null, null, ?, null, ?) "

  prepare pctc34m14002 from l_sql

  let l_sql = " update ",
                     " dpaksitvst set(vstsitdes, ",
                                    " atldat, ",
                                    " atlemp, ",
                                    " atlmat, ",
                                    " atlusrtip, ",
                                    " blqvclflg) = (?, today, ?, ?, ?, ?) ",
                              " where vstsitcod = ? "

  prepare pctc34m14003 from l_sql

  let l_sql = " delete ",
                " from dpaksitvst ",
               " where vstsitcod = ? "

  prepare pctc34m14004 from l_sql

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? ",
                 " and usrtip = ? "

  prepare pctc34m14005 from l_sql
  declare cctc34m14005 cursor for pctc34m14005

  let l_sql = " select min(vstsitcod) ",
                " from dpaksitvst ",
               " where vstsitcod > ? "

  prepare pctc34m14006 from l_sql
  declare cctc34m14006 cursor for pctc34m14006

  let l_sql = " select max(vstsitcod) ",
                " from dpaksitvst ",
               " where vstsitcod < ? "

  prepare pctc34m14007 from l_sql
  declare cctc34m14007 cursor for pctc34m14007

  let l_sql = " select max(vstsitcod) ",
                " from dpaksitvst "

  prepare pctc34m14008 from l_sql
  declare cctc34m14008 cursor for pctc34m14008

  let m_ctc34m14_prep = true

end function

#-----------------#
function ctc34m14()
#-----------------#

  if m_ctc34m14_prep is null or
     m_ctc34m14_prep <> true then
     call ctc34m14_prepare()
  end if

  initialize mr_sitvistoria to null

  call ctc34m14_menu()

end function

#-------------------------#
function ctc34m14_display()
#-------------------------#

  display by name mr_sitvistoria.vstsitcod,
                  mr_sitvistoria.vstsitdes,
                  mr_sitvistoria.caddat,
                  mr_sitvistoria.funnom_cad,
                  mr_sitvistoria.funnom_atl,
                  mr_sitvistoria.atldat,
                  mr_sitvistoria.blqvclflg

end function

#----------------------#
function ctc34m14_menu()
#----------------------#

  define l_salva_cod    like dpaksitvst.vstsitcod,
         l_resposta char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_salva_cod  =  null
        let     l_resposta  =  null

  let l_salva_cod = null
  let l_resposta  = null

  initialize mr_sitvistoria to null

  open window w_ctc34m14 at 4,2 with form "ctc34m14"

  menu "SITUACAO VISTORIA"

     command key("S") "Selecionar" "Seleciona uma situacao de vistoria"

             initialize mr_sitvistoria to null

             call ctc34m14_display()

             call ctc34m14_entra_dados("S")

             if mr_sitvistoria.vstsitcod is not null then
                call ctc34m14_operacao("S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona a situacao de vistoria anterior a selecionada"

             if mr_sitvistoria.vstsitcod is null then
                error "Selecione uma situacao de vistoria"
                next option "Selecionar"
             else
                let l_salva_cod = mr_sitvistoria.vstsitcod

                open cctc34m14007 using mr_sitvistoria.vstsitcod
                fetch cctc34m14007 into mr_sitvistoria.vstsitcod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m14007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m14_menu() / ", mr_sitvistoria.vstsitcod sleep 3
                end if

                close cctc34m14007

                if mr_sitvistoria.vstsitcod is not null then
                   call ctc34m14_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_sitvistoria.vstsitcod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona a proxima situacao de vistoria em relacao a selecionada"

             if mr_sitvistoria.vstsitcod is null then
                error "Selecione uma situacao de vistoria"
                next option "Selecionar"
             else

                let l_salva_cod = mr_sitvistoria.vstsitcod

                open cctc34m14006 using mr_sitvistoria.vstsitcod
                whenever error continue
                fetch cctc34m14006 into mr_sitvistoria.vstsitcod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m14006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m14_menu() / ", mr_sitvistoria.vstsitcod sleep 3
                end if

                close cctc34m14006

                if mr_sitvistoria.vstsitcod is not null then
                   call ctc34m14_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_sitvistoria.vstsitcod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("I") "Incluir" "Inclui uma nova situacao de vistoria"

             initialize mr_sitvistoria to null
             clear form

             call ctc34m14_entra_dados("I")

             if mr_sitvistoria.vstsitcod is not null then
                call ctc34m14_operacao("I")
                call ctc34m14_operacao("S")
             else
                clear form
                error "Inclusao cancelada"
             end if

     command key("M") "Modificar" "Modifica a situacao de vistoria selecionada"

             if mr_sitvistoria.vstsitcod is null then
                error "Selecione uma situacao de vistoria"
                next option "Selecionar"
             else
               let l_salva_cod = mr_sitvistoria.vstsitcod

               call ctc34m14_entra_dados("M")

               if mr_sitvistoria.vstsitcod is not null then
                  call ctc34m14_operacao("M")
               else
                  let mr_sitvistoria.vstsitcod = l_salva_cod
                  error "Modificacao cancelada"
               end if

               call ctc34m14_operacao("S")

            end if

     command key("X") "eXcluir" "Exclui a situacao de vistoria selecionada"

             if mr_sitvistoria.vstsitcod is not null then

                let l_resposta = "E"

                while l_resposta <> "S" and
                      l_resposta <> "N"

                   prompt "Deseja excluir a situacao de vistoria selecionada ?" for l_resposta
                   let l_resposta = upshift(l_resposta)

                   if l_resposta is null or
                      l_resposta = " " then
                      let l_resposta = "E"
                   end if

                end while

                if l_resposta = "S" then
                   call ctc34m14_operacao("X")
                   next option "Selecionar"
                end if

             else
                error "Selecione uma situacao de vistoria"
                next option "Selecionar"
             end if


     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m14

  let int_flag = false

end function

#--------------------------------------------#
function ctc34m14_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01)



  input mr_sitvistoria.vstsitcod,
        mr_sitvistoria.vstsitdes,
        mr_sitvistoria.blqvclflg without defaults from vstsitcod,
                                                       vstsitdes,
                                                       blqvclflg
     before field vstsitcod

        if l_tipo_operacao = "M" then # ---> MODIFICAR
           next field vstsitdes
        end if

        if l_tipo_operacao = "I" then # ---> INCLUIR
           let mr_sitvistoria.vstsitcod = ctc34m14_max_codigo()
           display by name mr_sitvistoria.vstsitcod
           next field vstsitdes
        end if

        display by name mr_sitvistoria.vstsitcod attribute(reverse)

     after field vstsitcod
        display by name mr_sitvistoria.vstsitcod

        if  mr_sitvistoria.vstsitcod is null then
            error "Informe o codigo da situacao de vistoria"
            next field vstsitcod
        end if

        if l_tipo_operacao = "S" then # ---> SELECIONAR
           exit input
        end if

     before field vstsitdes
        display by name mr_sitvistoria.vstsitdes attribute(reverse)

     after field vstsitdes
        display by name mr_sitvistoria.vstsitdes

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field vstsitdes
        end if

        if mr_sitvistoria.vstsitdes is null or
           mr_sitvistoria.vstsitdes = " " then
           error "Informe a descricao da situacao de vistoria"
           next field vstsitdes
        end if

     before field blqvclflg
        display by name mr_sitvistoria.blqvclflg attribute(reverse)

     after field blqvclflg
        display by name mr_sitvistoria.blqvclflg

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field vstsitdes
        end if

        if mr_sitvistoria.blqvclflg is null or
           mr_sitvistoria.blqvclflg = " " then
           error "Informe se esta Situacao de Vistoria bloqueia o veiculo"
           next field blqvclflg
        end if

        if mr_sitvistoria.blqvclflg <> "S" and
           mr_sitvistoria.blqvclflg <> "N" then
           error "Informe (S)im  ou (N)ao"
           next field blqvclflg
        end if

     on key(f17, control-c, interrupt)
        initialize mr_sitvistoria to null
        exit input

  end input

end function

#-----------------------------------------#
function ctc34m14_operacao(l_tipo_operacao)
#-----------------------------------------#

  define l_tipo_operacao char(01)

  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "I" INCLUIR
   "M" MODIFICAR
   "X" EXCLUIR}



  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m14001 using mr_sitvistoria.vstsitcod
        whenever error continue
        fetch cctc34m14001 into mr_sitvistoria.vstsitcod,
                                mr_sitvistoria.vstsitdes,
                                mr_sitvistoria.caddat,
                                mr_sitvistoria.cademp,
                                mr_sitvistoria.cadmat,
                                mr_sitvistoria.atldat,
                                mr_sitvistoria.atlemp,
                                mr_sitvistoria.atlmat,
                                mr_sitvistoria.cadusrtip,
                                mr_sitvistoria.atlusrtip,
                                mr_sitvistoria.blqvclflg

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhuma situacao de vistoria encontrada para o codigo informado"
              initialize mr_sitvistoria to null
           else
              error "Erro SELECT cctc34m14001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m14_operacao() / ", mr_sitvistoria.vstsitcod sleep 3
           end if
        else

           # --> BUSCA O NOME DO FUNCIONARIO QUE CADASTROU
           let mr_sitvistoria.funnom_cad = ctc34m14_nome_funcio(mr_sitvistoria.cademp,
                                                              mr_sitvistoria.cadmat,
                                                              mr_sitvistoria.cadusrtip)

           # --> BUSCA O NOME DO FUNCIONARIO QUE ATUALIZOU
           let mr_sitvistoria.funnom_atl = ctc34m14_nome_funcio(mr_sitvistoria.atlemp,
                                                              mr_sitvistoria.atlmat,
                                                              mr_sitvistoria.atlusrtip)
        end if

        close cctc34m14001

        call ctc34m14_display()

     when("I") # ---> INCLUIR

        whenever error continue
        execute pctc34m14002 using mr_sitvistoria.vstsitcod,
                                   mr_sitvistoria.vstsitdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip,
                                   mr_sitvistoria.blqvclflg

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = -268 then
             error "Inclusao cancelada, codigo ja existe. Selecione novamente a opcao 'Incluir'" sleep 4
             initialize mr_sitvistoria to null
           else
             error "Erro INSERT pctc34m14002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
             error "ctc34m14_operacao() / ", mr_sitvistoria.vstsitcod, "/",
                                             mr_sitvistoria.vstsitdes, "/",
                                             g_issk.empcod, "/",
                                             g_issk.funmat, "/",
                                             g_issk.empcod, "/",
                                             g_issk.usrtip sleep 3
           end if
        else
           error "Situacao de Vistoria incluida com sucesso"
        end if

     when("M") # ---> MODIFICAR

        whenever error continue
        execute pctc34m14003 using mr_sitvistoria.vstsitdes,
                                   g_issk.empcod,
                                   g_issk.funmat,
                                   g_issk.usrtip,
                                   mr_sitvistoria.blqvclflg,
                                   mr_sitvistoria.vstsitcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m14003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m14_operacao() / ", mr_sitvistoria.vstsitdes, "/",
                                           g_issk.empcod,       "/",
                                           g_issk.funmat,       "/",
                                           g_issk.usrtip,       "/",
                                           mr_sitvistoria.vstsitcod sleep 3
        else
           error "Situacao de Vistoria modificada com sucesso"
        end if

     when("X") # ---> EXCLUIR

        whenever error continue
        execute pctc34m14004 using mr_sitvistoria.vstsitcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc34m14004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m14_operacao() / ", mr_sitvistoria.vstsitcod sleep 3
        else
           error "Situacao de Vistoria excluida com sucesso"
           initialize mr_sitvistoria to null
           clear form
        end if

  end case

end function

#-----------------------------------------#
function ctc34m14_nome_funcio(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         empcod       like isskfunc.empcod,
         funmat       like isskfunc.funmat,
         usrtip       like isskfunc.usrtip
  end record

  define l_funnom like isskfunc.funnom


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_funnom  =  null

  if m_ctc34m14_prep is null or
     m_ctc34m14_prep <> true then
     call ctc34m14_prepare()
  end if

  let l_funnom = null

  open cctc34m14005 using lr_parametro.empcod,
                          lr_parametro.funmat,
                          lr_parametro.usrtip
  whenever error continue
  fetch cctc34m14005 into l_funnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_funnom = null
     if sqlca.sqlcode <> notfound then
        error "Erro SELECT cctc34m14005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m14_nome_funcio() / ", lr_parametro.empcod, "/",
                                           lr_parametro.funmat, "/",
                                           lr_parametro.usrtip  sleep 3
     end if
  end if

  close cctc34m14005

  return l_funnom

end function

#----------------------------#
function ctc34m14_max_codigo()
#----------------------------#

  define l_max_codigo smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_max_codigo  =  null

  let l_max_codigo = null

  # ---> BUSCA O ULTIMO CODIGO CADASTRADO
  open cctc34m14008
  whenever error continue
  fetch cctc34m14008 into l_max_codigo
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro SELECT MAX cctc34m14008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "ctc34m14_max_codigo() " sleep 3
  end if

  close cctc34m14008

  if l_max_codigo is null then
     let l_max_codigo = 0
  end if

  let l_max_codigo = l_max_codigo + 1

  return l_max_codigo

end function
