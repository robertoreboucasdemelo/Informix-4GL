#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M15                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE PADRAO/VISTORIA DO VEICULO.      #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 01/03/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc34m15_prep smallint,
         m_contador      smallint

  define mr_padrao       record
         socvclcod       like datkveiculo.socvclcod,
         bckcod          like datkveiculo.bckcod,
         bckdes          like dpakbck.bckdes,
         dpycod          like datkveiculo.dpycod,
         dpydes          like dpakdpy.dpydes,
         pstcoddig       like datkveiculo.pstcoddig,
         nomgrr          like dpaksocor.nomgrr
  end record

  define am_vistoria     array[50] of record
         navega          char(01),
         vstsitdat       like dpakvst.vstsitdat,
         vstsitcod       like dpakvst.vstsitcod,
         vstsitdes       char(25),
         vstpbmcod       like dpakvst.vstpbmcod,
         vstpbmdes       char(25),
         revdat          like dpakvst.revdat,
         caddat          like dpakvst.caddat,
         cadmat          like dpakvst.cadmat,
         nome_inclusao   char(20),
         atldat          like dpakvst.atldat,
         atlmat          like dpakvst.cadmat,
         nome_alteracao  char(20)
  end record

#-------------------------#
function ctc34m15_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select bckdes ",
                " from dpakbck ",
               " where bckcod = ? "

  prepare pctc34m15001 from l_sql
  declare cctc34m15001 cursor for pctc34m15001

  let l_sql = " select dpydes ",
                " from dpakdpy ",
               " where dpycod = ? "

  prepare pctc34m15002 from l_sql
  declare cctc34m15002 cursor for pctc34m15002

  let l_sql = " select socvclcod, ",
                     " pstcoddig, ",
                     " bckcod, ",
                     " dpycod ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pctc34m15003 from l_sql
  declare cctc34m15003 cursor for pctc34m15003

  let l_sql = " select min(socvclcod) ",
                " from datkveiculo ",
               " where socvclcod > ? "

 prepare pctc34m15004 from l_sql
 declare cctc34m15004 cursor for pctc34m15004

  let l_sql = " select max(socvclcod) ",
                " from datkveiculo ",
               " where socvclcod < ? "

  prepare pctc34m15005 from l_sql
  declare cctc34m15005 cursor for pctc34m15005

  let l_sql = " select nomgrr ",
                " from dpaksocor ",
               " where pstcoddig = ? "

  prepare pctc34m15006 from l_sql
  declare cctc34m15006 cursor for pctc34m15006

  let l_sql = " update ",
                     " datkveiculo ",
                 " set(bckcod, ",
                     " dpycod) = (?, ?) ",
               " where socvclcod = ? "

  prepare pctc34m15007 from l_sql

  let l_sql = " select vstsitcod, ",
                     " vstsitdat, ",
                     " revdat, ",
                     " vstpbmcod, ",
                     " atldat, ",
                     " atlmat, ",
                     " caddat, ",
                     " cadmat, ",
                     " cademp, ",
                     " atlemp, ",
                     " cadusrtip, ",
                     " atlusrtip ",
                " from dpakvst ",
               " where socvclcod = ? ",
               " order by vstsitdat desc "

  prepare pctc34m15008 from l_sql
  declare cctc34m15008 cursor for pctc34m15008

  let l_sql = " select vstpbmdes ",
                " from dpakpbmvst ",
               " where vstpbmcod = ? "

  prepare pctc34m15009 from l_sql
  declare cctc34m15009 cursor for pctc34m15009

  let l_sql = " select vstsitdes ",
                " from dpaksitvst ",
               " where vstsitcod = ? "

  prepare pctc34m15010 from l_sql
  declare cctc34m15010 cursor for pctc34m15010

  let l_sql = " insert ",
                " into dpakvst ",
                    " (vstsitcod, ",
                     " vstsitdat, ",
                     " socvclcod, ",
                     " revdat, ",
                     " vstpbmcod, ",
                     " atldat, ",
                     " atlmat, ",
                     " caddat, ",
                     " cadmat, ",
                     " cademp, ",
                     " atlemp, ",
                     " cadusrtip, ",
                     " atlusrtip) ",
             " values (?, ?, ?, ?, ?, null, null, ",
                     " today, ?, ?, null, ?, null) "

  prepare pctc34m15011 from l_sql

  let l_sql = " update dpakvst ",
                " set (revdat, ",
                     " vstpbmcod, ",
                     " atldat, ",
                     " atlmat, ",
                     " caddat, ",
                     " cadmat, ",
                     " cademp, ",
                     " atlemp, ",
                     " cadusrtip, ",
                     " atlusrtip) = (?, ?, today, ?, ?, ?, ?, ?, ?, ?) ",
               " where vstsitcod = ? ",
                 " and vstsitdat = ? ",
                 " and socvclcod = ? "

  prepare pctc34m15012 from l_sql

  let l_sql = " delete ",
                " from dpakvst ",
               " where vstsitcod = ? ",
                 " and vstsitdat = ? ",
                 " and socvclcod = ? "

  prepare pctc34m15013 from l_sql

  let l_sql = " select cademp, ",
                     " cadusrtip ",
                " from dpakvst ",
               " where vstsitcod = ? ",
                 " and vstsitdat = ? ",
                 " and socvclcod = ? "

  prepare pctc34m15014 from l_sql
  declare cctc34m15014 cursor for pctc34m15014

  let l_sql = " select blqvclflg ",
                " from dpaksitvst ",
               " where vstsitcod = ? "

  prepare pctc34m15015 from l_sql
  declare cctc34m15015 cursor for pctc34m15015

  let l_sql = " update datkveiculo ",
                " set (socoprsitcod) = (2) ",
               " where socvclcod = ? "

  prepare pctc34m15016 from l_sql

  let l_sql = " select socoprsitcod ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pctc34m15017 from l_sql
  declare cctc34m15017 cursor for pctc34m15017

  let l_sql = " select 1 ",
                " from dpakvst ",
               " where vstsitdat = ? ",
                 " and socvclcod = ? "

  prepare pctc34m15018 from l_sql
  declare cctc34m15018 cursor for pctc34m15018

  let l_sql = " update datkvclsit ",
                " set (socvclsitdes) = (?) ",
               " where socvclcod = ? "

  prepare pctc34m15019 from l_sql

  let m_ctc34m15_prep = true

end function

#----------------------------#
function ctc34m15(l_socvclcod)
#----------------------------#

  define l_socvclcod like datkveiculo.socvclcod

  options
     insert key f1,
     delete key control-y

  if m_ctc34m15_prep is null or
     m_ctc34m15_prep <> true then
     call ctc34m15_prepare()
  end if

  initialize mr_padrao to null

  let mr_padrao.socvclcod = l_socvclcod

  call ctc34m15_menu()

  options
     delete key f2

end function

#------------------------------------------#
function ctc34m15_deleta_linha(l_arr, l_scr)
#------------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_cont  =  null

  for l_cont = l_arr to 49
     if am_vistoria[l_arr].vstsitdat is not null then
        let am_vistoria[l_cont].* = am_vistoria[l_cont + 1].*
     else
        initialize am_vistoria[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 1
     display am_vistoria[l_arr].vstsitdat      to s_ctc34m15[l_cont].vstsitdat
     display am_vistoria[l_arr].vstsitcod      to s_ctc34m15[l_cont].vstsitcod
     display am_vistoria[l_arr].vstsitdes      to s_ctc34m15[l_cont].vstsitdes
     display am_vistoria[l_arr].vstpbmcod      to s_ctc34m15[l_cont].vstpbmcod
     display am_vistoria[l_arr].vstpbmdes      to s_ctc34m15[l_cont].vstpbmdes
     display am_vistoria[l_arr].revdat         to s_ctc34m15[l_cont].revdat
     display am_vistoria[l_arr].caddat         to s_ctc34m15[l_cont].caddat
     display am_vistoria[l_arr].cadmat         to s_ctc34m15[l_cont].cadmat
     display am_vistoria[l_arr].nome_inclusao  to s_ctc34m15[l_cont].nome_inclusao
     display am_vistoria[l_arr].atldat         to s_ctc34m15[l_cont].atldat
     display am_vistoria[l_arr].atlmat         to s_ctc34m15[l_cont].atlmat
     display am_vistoria[l_arr].nome_alteracao to s_ctc34m15[l_cont].nome_alteracao
     let l_arr = l_arr + 1
  end for

end function

#----------------------#
function ctc34m15_menu()
#----------------------#

  define l_salva_cod like datkveiculo.socvclcod,
         l_resposta  char(01)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_salva_cod = null
  let l_resposta  = null

  open window w_ctc34m15 at 4,2 with form "ctc34m15"

  call ctc34m15_operacao("S")

  menu "PADRAO"

     command key("S") "Selecionar" "Seleciona o padrao do veiculo"

             initialize mr_padrao, am_vistoria to null

             call ctc34m15_display()

             call ctc34m15_entra_dados("S")

             if mr_padrao.socvclcod is not null then
                call ctc34m15_operacao("S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona o padrao do veiculo anterior"

             if mr_padrao.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                let l_salva_cod = mr_padrao.socvclcod

                open cctc34m15005 using mr_padrao.socvclcod
                fetch cctc34m15005 into mr_padrao.socvclcod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m15005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m15_menu() / ", mr_padrao.socvclcod sleep 3
                end if

                close cctc34m15005

                if mr_padrao.socvclcod is not null then
                   call ctc34m15_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_padrao.socvclcod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona o padrao do proximo veiculo"

             if mr_padrao.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                let l_salva_cod = mr_padrao.socvclcod

                open cctc34m15004 using mr_padrao.socvclcod
                whenever error continue
                fetch cctc34m15004 into mr_padrao.socvclcod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m15004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m15_menu() / ", mr_padrao.socvclcod sleep 3
                end if

                close cctc34m15004

                if mr_padrao.socvclcod is not null then
                   call ctc34m15_operacao("S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_padrao.socvclcod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("M") "Modificar" "Modifica o padrao do veiulo selecionado"

             if mr_padrao.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                let l_salva_cod = mr_padrao.socvclcod

                call ctc34m15_entra_dados("M")

                if mr_padrao.socvclcod is not null then
                   call ctc34m15_operacao("M")
                   call ctc34m15_entra_dados_array()
                else
                   let mr_padrao.socvclcod = l_salva_cod
                   error "Modificacao cancelada"
                end if

                call ctc34m15_operacao("S")

             end if

     command key("X") "Excluir" "Exclui o padrao do veiculo selecionado"

             if mr_padrao.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else

                if mr_padrao.bckcod is null and
                   mr_padrao.dpycod is null then
                   error "Nao existe um padrao cadastrado para este veiculo"
                   next option "Modificar"
                else
                   let l_resposta = "E"

                   while l_resposta <> "S" and
                         l_resposta <> "N"

                      prompt "Deseja excluir o padrao do veiculo selecionado ?" for l_resposta
                      let l_resposta = upshift(l_resposta)

                      if l_resposta is null or
                         l_resposta = " " then
                         let l_resposta = "E"
                      end if

                   end while

                   if l_resposta = "S" then
                      let mr_padrao.bckcod = null
                      let mr_padrao.dpycod = null
                      let mr_padrao.bckdes = null
                      let mr_padrao.dpydes = null

                      call ctc34m15_operacao("M")

                      call ctc34m15_display()

                   end if

                end if

             end if

     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m15

  let int_flag = false

end function

#-------------------------------------------#
function ctc34m15_pesq_vstpbmdes(l_vstpbmcod)
#-------------------------------------------#

  define l_vstpbmcod like dpakpbmvst.vstpbmcod,
         l_vstpbmdes like dpakpbmvst.vstpbmdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vstpbmdes  =  null

  let l_vstpbmdes = null

  if m_ctc34m15_prep is null or
     m_ctc34m15_prep <> true then
     call ctc34m15_prepare()
  end if

  open cctc34m15009 using l_vstpbmcod
  whenever error continue
  fetch cctc34m15009 into l_vstpbmdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_vstpbmdes = null
     else
        error "Erro SELECT cctc34m15009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m15_pesq_vstpbmdes() / ", l_vstpbmcod  sleep 3
     end if
  end if

  close cctc34m15009

  return l_vstpbmdes

end function

#-------------------------------------------#
function ctc34m15_pesq_vstsitdes(l_vstsitcod)
#-------------------------------------------#

  define l_vstsitcod like dpaksitvst.vstsitcod,
         l_vstsitdes like dpaksitvst.vstsitdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vstsitdes  =  null

  let l_vstsitdes = null

  open cctc34m15010 using l_vstsitcod
  whenever error continue
  fetch cctc34m15010 into l_vstsitdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_vstsitdes = null
     else
        error "Erro SELECT cctc34m15010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m15_pesq_vstsitdes() / ", l_vstsitcod  sleep 3
     end if
  end if

  close cctc34m15010

  return l_vstsitdes

end function

#-------------------------------------#
function ctc34m15_pesq_bckdes(l_bckcod)
#-------------------------------------#

  define l_bckcod like dpakbck.bckcod,
         l_bckdes like dpakbck.bckdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_bckdes  =  null

  let l_bckdes = null

  open cctc34m15001 using l_bckcod
  whenever error continue
  fetch cctc34m15001 into l_bckdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_bckdes = null
     else
        error "Erro SELECT cctc34m15001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m15_pesq_bckdes() / ", l_bckcod  sleep 3
     end if
  end if

  close cctc34m15001

  return l_bckdes

end function

#-------------------------------------#
function ctc34m15_pesq_dpydes(l_dpycod)
#-------------------------------------#

  define l_dpycod like dpakdpy.dpycod,
         l_dpydes like dpakdpy.dpydes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_dpydes  =  null

  let l_dpydes = null

  open cctc34m15002 using l_dpycod
  whenever error continue
  fetch cctc34m15002 into l_dpydes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_dpydes = null
     else
        error "Erro SELECT cctc34m15002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m15_pesq_dpydes() / ", l_dpycod sleep 3
     end if
  end if

  close cctc34m15002

  return l_dpydes

end function

#-----------------------------#
function ctc34m15_carga_array()
#-----------------------------#

  define lr_vistoria record
         cademp      like dpakvst.cademp,
         atlemp      like dpakvst.atlemp,
         cadusrtip   like dpakvst.cadusrtip,
         atlusrtip   like dpakvst.atlusrtip
  end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_vistoria.*  to  null

  initialize am_vistoria, lr_vistoria to null

  let m_contador = 1

  open cctc34m15008 using mr_padrao.socvclcod

  foreach cctc34m15008 into am_vistoria[m_contador].vstsitcod,
                            am_vistoria[m_contador].vstsitdat,
                            am_vistoria[m_contador].revdat,
                            am_vistoria[m_contador].vstpbmcod,
                            am_vistoria[m_contador].atldat,
                            am_vistoria[m_contador].atlmat,
                            am_vistoria[m_contador].caddat,
                            am_vistoria[m_contador].cadmat,
                            lr_vistoria.cademp,
                            lr_vistoria.atlemp,
                            lr_vistoria.cadusrtip,
                            lr_vistoria.atlusrtip

     # --> BUSCA DESCRICAO DO PROBLEMA DA VISTORIA
     let am_vistoria[m_contador].vstpbmdes =
         ctc34m15_pesq_vstpbmdes(am_vistoria[m_contador].vstpbmcod)

     # --> BUSCA DESCRICAO DA SITUACAO DA VISTORIA
     let am_vistoria[m_contador].vstsitdes =
         ctc34m15_pesq_vstsitdes(am_vistoria[m_contador].vstsitcod)

     # --> BUSCA O NOME DO RESPONSAVEL PELA INCLUSAO
     let am_vistoria[m_contador].nome_inclusao =
         ctc34m14_nome_funcio(lr_vistoria.cademp,
                              am_vistoria[m_contador].cadmat,
                              lr_vistoria.cadusrtip)

     # --> BUSCA O NOME DO RESPONSAVEL PELA ALTERACAO
     let am_vistoria[m_contador].nome_alteracao =
         ctc34m14_nome_funcio(lr_vistoria.atlemp,
                              am_vistoria[m_contador].atlmat,
                              lr_vistoria.atlusrtip)

     let m_contador = m_contador + 1

     if m_contador > 50 then
        error "O limite de 100 vistorias foi ultrapassado. AVISE A INFORMATICA !" sleep 4
        exit foreach
     end if

     initialize lr_vistoria to null

  end foreach

  close cctc34m15008

  let m_contador = m_contador - 1

end function

#----------------------------------------#
function ctc34m15_pesq_nomgrr(l_pstcoddig)
#----------------------------------------#

  define l_pstcoddig like datkveiculo.pstcoddig,
         l_nomgrr    like dpaksocor.nomgrr


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_nomgrr  =  null

  if m_ctc34m15_prep is null or
     m_ctc34m15_prep <> true then
     call ctc34m15_prepare()
  end if

  let l_nomgrr = null

  open cctc34m15006 using l_pstcoddig
  whenever error continue
  fetch cctc34m15006 into l_nomgrr
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_nomgrr = null
     else
        error "Erro SELECT cctc34m15006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ctc34m15_pesq_nomgrr() / ", l_pstcoddig sleep 3
     end if
  end if

  close cctc34m15006

  return l_nomgrr

end function

#-----------------------------------#
function ctc34m15_entra_dados_array()
#-----------------------------------#

  define l_operacao      char(01),
         l_sql           char(70),
         l_arr           smallint,
         l_scr           smallint,
         l_retorno       smallint,
         l_resposta      char(01),
         l_atualizando   smallint,
         l_cademp        like dpakvst.cademp,
         l_cadusrtip     like dpakvst.cadusrtip,
         l_blqvclflg     like dpaksitvst.blqvclflg,
         l_socoprsitcod  like datkveiculo.socoprsitcod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_operacao  =  null
        let     l_sql  =  null
        let     l_arr  =  null
        let     l_scr  =  null
        let     l_retorno  =  null
        let     l_resposta  =  null
        let     l_atualizando  =  null
        let     l_cademp  =  null
        let     l_cadusrtip  =  null
        let     l_blqvclflg  =  null
        let     l_socoprsitcod  =  null

  while true

  let l_arr           = null
  let l_socoprsitcod  = null
  let l_scr           = null
  let l_retorno       = null
  let l_resposta      = null
  let l_sql           = null
  let l_cademp        = null
  let l_cadusrtip     = null
  let l_blqvclflg     = null
  let l_operacao      = " "
  let int_flag        = false
  let l_atualizando   = false

  call ctc34m15_carga_array()

  call set_count(m_contador)

  input array am_vistoria without defaults from s_ctc34m15.*

     before row
        let l_arr = arr_curr()
        let l_scr = scr_line()

     before field navega

        if l_operacao = "I" then
           let l_atualizando = true
           next field vstsitdat
        end if

     after field navega

        if fgl_lastkey() = 2014 then # F1
           let l_operacao = "I"
           let l_atualizando = true
        else
           if fgl_lastkey() = fgl_keyval('down') then
              if am_vistoria[l_arr + 1].vstsitdat is null then
                 next field navega
              else
                 continue input
              end if
           end if

           if fgl_lastkey() = 2005 or    # F3
              fgl_lastkey() = 2006 then  # F4
              continue input
           end if

           if fgl_lastkey() = fgl_keyval('up') then
              continue input
           else
              next field navega
           end if

        end if

     before field vstsitdat
        display am_vistoria[l_arr].vstsitdat to s_ctc34m15[l_scr].vstsitdat attribute(reverse)

     after field vstsitdat
        display am_vistoria[l_arr].vstsitdat to s_ctc34m15[l_scr].vstsitdat

        if fgl_lastkey() = fgl_keyval('up') or
           fgl_lastkey() = fgl_keyval('left') or
           fgl_lastkey() = fgl_keyval('down') then
           next field vstsitdat
        end if

        if am_vistoria[l_arr].vstsitdat is null then
           error "Informe a Data da Vistoria"
           next field vstsitdat
        end if

        # ---> VERIFICA SE EXISTE UMA VISTORIA CADASTRADA C/A MESMA SITUACAO
        open cctc34m15018 using am_vistoria[l_arr].vstsitdat, mr_padrao.socvclcod
        whenever error continue
        fetch cctc34m15018
        whenever error stop

        if sqlca.sqlcode = 0 then
           error "Ja existe uma vistoria cadast. p/este veic. na data informada, favor verificar"
           close cctc34m15018
           next field vstsitdat
        end if

        close cctc34m15018

     before field vstsitcod
        display am_vistoria[l_arr].vstsitcod to s_ctc34m15[l_scr].vstsitcod attribute(reverse)

     after field vstsitcod
        display am_vistoria[l_arr].vstsitcod to s_ctc34m15[l_scr].vstsitcod

        if fgl_lastkey() = fgl_keyval('up') or
           fgl_lastkey() = fgl_keyval('left') then
           next field vstsitdat
        end if

        if fgl_lastkey() = fgl_keyval('down') or
           fgl_lastkey() = fgl_keyval('right') then
           next field vstsitcod
        end if

        # ---> BUSCA A DESCRICAO DA SITUACAO DA VISTORIA
        let am_vistoria[l_arr].vstsitdes = ctc34m15_pesq_vstsitdes(am_vistoria[l_arr].vstsitcod)

        if am_vistoria[l_arr].vstsitdes is null then

           let l_sql = " select vstsitcod, vstsitdes from dpaksitvst order by 1 "

           call ofgrc001_popup(3,
                               3,
                               "SITUACAO DA VISTORIA",
                               "CODIGO",
                               "DESCRICAO",
                               "N",
                               l_sql,
                               "",
                               "X")

                returning l_retorno,
                          am_vistoria[l_arr].vstsitcod,
                          am_vistoria[l_arr].vstsitdes

           if am_vistoria[l_arr].vstsitdes is null or
              am_vistoria[l_arr].vstsitdes = " " then
              error "Informe o Codigo da Situacao da Vistoria"
              next field vstsitcod
           end if

        end if

        display am_vistoria[l_arr].vstsitcod to s_ctc34m15[l_scr].vstsitcod
        display am_vistoria[l_arr].vstsitdes to s_ctc34m15[l_scr].vstsitdes

     before field vstpbmcod
        display am_vistoria[l_arr].vstpbmcod to s_ctc34m15[l_scr].vstpbmcod attribute(reverse)

     after field vstpbmcod
        display am_vistoria[l_arr].vstpbmcod to s_ctc34m15[l_scr].vstpbmcod

        if fgl_lastkey() = fgl_keyval('up') or
           fgl_lastkey() = fgl_keyval('left') then
           if l_operacao = "I" then
              next field vstsitcod
           else
              next field vstpbmcod
           end if
        end if

        if fgl_lastkey() = fgl_keyval('down') or
           fgl_lastkey() = fgl_keyval('right') then
           next field vstpbmcod
        end if

        # ---> BUSCA A DESCRICAO DO PROBLEMA DA VISTORIA
        let am_vistoria[l_arr].vstpbmdes = ctc34m15_pesq_vstpbmdes(am_vistoria[l_arr].vstpbmcod)

        if am_vistoria[l_arr].vstpbmdes is null then

           let l_sql = " select vstpbmcod, vstpbmdes from dpakpbmvst order by 1 "

           call ofgrc001_popup(3,
                               3,
                               "PROBLEMA DA VISTORIA",
                               "CODIGO",
                               "DESCRICAO",
                               "N",
                               l_sql,
                               "",
                               "X")

                returning l_retorno,
                          am_vistoria[l_arr].vstpbmcod,
                          am_vistoria[l_arr].vstpbmdes

           if am_vistoria[l_arr].vstpbmdes is null or
              am_vistoria[l_arr].vstpbmdes = " " then
              error "Informe o Codigo do Problema da Vistoria"
              next field vstsitcod
           end if

        end if

        display am_vistoria[l_arr].vstpbmcod to s_ctc34m15[l_scr].vstpbmcod
        display am_vistoria[l_arr].vstpbmdes to s_ctc34m15[l_scr].vstpbmdes

     before field revdat
        display am_vistoria[l_arr].revdat to s_ctc34m15[l_scr].revdat attribute(reverse)

     after field revdat
        display am_vistoria[l_arr].revdat to s_ctc34m15[l_scr].revdat

        if fgl_lastkey() = fgl_keyval('down') or
           fgl_lastkey() = fgl_keyval('right') then
           next field revdat
        end if

        if fgl_lastkey() = fgl_keyval('up') or
           fgl_lastkey() = fgl_keyval('left') then
           next field vstpbmcod
        end if

        if am_vistoria[l_arr].revdat is not null then
           if am_vistoria[l_arr].revdat < am_vistoria[l_arr].vstsitdat then
              error "A Data de Revistoria deve ser maior ou igual a Data de Vistoria"
              next field revdat
           end if
        end if

        # ---> BUSCA O FLAG DA SITUACAO DA VISTORIA
        open cctc34m15015 using am_vistoria[l_arr].vstsitcod
        whenever error continue
        fetch cctc34m15015 into l_blqvclflg
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro SELECT cctc34m15015 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m15_entra_dados_array() / ", am_vistoria[l_arr].vstsitcod sleep 3
           close cctc34m15015
           next field revdat
        end if

        close cctc34m15015

        # ---> VERIFICA SE A SITUACAO BLOQUEIA O VEICULO
        if l_blqvclflg = "S" then

           let l_socoprsitcod = null

           # ---> VERIFICA SE O VEICULO JA ESTA BLOQUEADO
           open cctc34m15017 using mr_padrao.socvclcod
           whenever error continue
           fetch cctc34m15017 into l_socoprsitcod
           whenever error stop

           if sqlca.sqlcode <> 0 then
              error "Erro SELECT cctc34m15017 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m15_entra_dados_array() / ", mr_padrao.socvclcod sleep 3
              close cctc34m15017
              next field revdat
           end if

           close cctc34m15017

           if l_socoprsitcod <> 2 then # --> VEICULO NAO ESTA BLOQUEADO

              let l_resposta = "E"

              while l_resposta <> "S" and l_resposta <> "N"
                 prompt "Deseja bloquear o veiculo ? " for l_resposta

                 let l_resposta = upshift(l_resposta)

                 if l_resposta is null or
                    int_flag = true or
                    l_resposta = " " then
                    let int_flag   = false
                    let l_resposta = "E"
                 end if

              end while

              if l_resposta = "S" then

                 # ---> BLOQUEIA O VEICULO
                 whenever error continue
                 execute pctc34m15016 using mr_padrao.socvclcod

                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    error "Erro UPDATE pctc34m15016 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                    error "ctc34m15_entra_dados_array() / ", mr_padrao.socvclcod sleep 3
                    next field revdat
                 else
                    error "Veiculo bloqueado com sucesso" sleep 2
                 end if

                 whenever error continue
                 execute pctc34m15019 using am_vistoria[l_arr].vstpbmdes,
                                            mr_padrao.socvclcod
                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    error "Erro UPDATE pctc34m15019 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                    error "ctc34m15_entra_dados_array() / ", mr_padrao.socvclcod sleep 3
                    next field revdat
                 end if

              end if

           end if

        end if

        if l_operacao = "I" then
           call ctc34m15_operacao_array("I", # INCLUSAO
                                        am_vistoria[l_arr].vstsitcod,
                                        am_vistoria[l_arr].vstsitdat,
                                        mr_padrao.socvclcod,
                                        am_vistoria[l_arr].revdat,
                                        am_vistoria[l_arr].vstpbmcod,
                                        "",
                                        g_issk.funmat,
                                        g_issk.empcod,
                                        "",
                                        g_issk.usrtip,
                                        "",
                                        "")
        else

           let l_cademp    = null
           let l_cadusrtip = null

           # --> BUSCA A EMPRESA E TIPO DO USUARIO QUE CADASTROU A VISTORIA
           open cctc34m15014 using am_vistoria[l_arr].vstsitcod,
                                   am_vistoria[l_arr].vstsitdat,
                                   mr_padrao.socvclcod
           whenever error continue
           fetch cctc34m15014 into l_cademp,
                                   l_cadusrtip
           whenever error stop

           if sqlca.sqlcode <> 0 then
              error "Erro SELECT cctc34m15014 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m15_entra_dados_array() / ", am_vistoria[l_arr].vstsitcod, "/",
                                                       am_vistoria[l_arr].vstsitdat, "/",
                                                       mr_padrao.socvclcod sleep 3
           end if

           close cctc34m15014

           call ctc34m15_operacao_array("A", # ALTERACAO
                                        am_vistoria[l_arr].vstsitcod,
                                        am_vistoria[l_arr].vstsitdat,
                                        mr_padrao.socvclcod,
                                        am_vistoria[l_arr].revdat,
                                        am_vistoria[l_arr].vstpbmcod,
                                        am_vistoria[l_arr].caddat,
                                        am_vistoria[l_arr].cadmat,
                                        l_cademp,
                                        g_issk.empcod,
                                        l_cadusrtip,
                                        g_issk.usrtip,
                                        g_issk.funmat)

        end if
        let l_atualizando = false
        exit input

        #let l_operacao = " "
        #
        #next field navega

     on key(f2)

       if am_vistoria[l_arr].vstsitdat is null then
          error "Operacao de exclusao nao permitida, pois nao existe vistoria selecionada !"
          exit input
       end if

       let l_resposta = "E"

       while l_resposta <> "S" and l_resposta <> "N"

          prompt "Confirma a exclusao da vistoria ? (S ou N):" for l_resposta

          let l_resposta = upshift(l_resposta)

          if l_resposta is null or
             int_flag = true or
             l_resposta = " " then
             let int_flag   = false
             let l_resposta = "E"
          end if

       end while

       if l_resposta = "S" then
          call ctc34m15_operacao_array("E", # EXCLUSAO
                                       am_vistoria[l_arr].vstsitcod,
                                       am_vistoria[l_arr].vstsitdat,
                                       mr_padrao.socvclcod,
                                       "", "", "", "", "",
                                       "", "", "", "")

          call ctc34m15_deleta_linha(l_arr,l_scr)
       end if

    on key(f6)

       if am_vistoria[l_arr].vstsitdat is null then
          error "Operacao de modificacao nao permitida, pois nao existe vistoria selecionada !"
          exit input
       end if

       if l_operacao = "I" or
          l_operacao = "A" then
          error "F6 nao pode ser teclada neste momento "
       else
          let l_operacao = "A"
          next field vstpbmcod
       end if

    on key (control-c, f17, interrupt)

       initialize am_vistoria[l_arr].* to null
       exit input

  end input

  if int_flag and
     l_atualizando = false then
     let int_flag = false
     exit while
  end if

  end while

end function

#--------------------------------------------#
function ctc34m15_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01),
         l_sql           char(60),
         l_retorno       smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null
        let     l_retorno  =  null

  let l_sql     = null
  let l_retorno = null

  input mr_padrao.socvclcod,
        mr_padrao.bckcod,
        mr_padrao.dpycod without defaults from socvclcod, bckcod, dpycod

     before field socvclcod

        if l_tipo_operacao = "M" then
           next field bckcod
        end if

        display by name mr_padrao.socvclcod attribute(reverse)

     after field socvclcod
        display by name mr_padrao.socvclcod

        if mr_padrao.socvclcod is null then
           error "Informe o codigo do veiculo"
           next field socvclcod
        end if

        if l_tipo_operacao = "S" then
           exit input
        end if

     before field bckcod
        display by name mr_padrao.bckcod attribute(reverse)

     after field bckcod
        display by name mr_padrao.bckcod

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field bckcod
        end if

        let mr_padrao.bckdes = ctc34m15_pesq_bckdes(mr_padrao.bckcod)

        if mr_padrao.bckdes is null then

           let l_sql = " select bckcod, bckdes from dpakbck order by 1 "

           call ofgrc001_popup(10,
                               21,
                               "BACKLIGHT",
                               "CODIGO",
                               "DESCRICAO",
                               "N",
                               l_sql,
                               "",
                               "X")

                returning l_retorno,
                          mr_padrao.bckcod,
                          mr_padrao.bckdes

        end if

        if mr_padrao.bckdes is null or
           mr_padrao.bckdes = " " then
           let mr_padrao.bckcod = null
           let mr_padrao.bckdes = null
        end if

        display by name mr_padrao.bckcod, mr_padrao.bckdes

     before field dpycod
        display by name mr_padrao.dpycod attribute(reverse)

     after field dpycod
        display by name mr_padrao.dpycod

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field bckcod
        end if

        let mr_padrao.dpydes = ctc34m15_pesq_dpydes(mr_padrao.dpycod)

        if mr_padrao.dpydes is null then

           let l_sql = " select dpycod, dpydes from dpakdpy order by 1 "

           call ofgrc001_popup(10,
                               21,
                               "DISPLAY",
                               "CODIGO",
                               "DESCRICAO",
                               "N",
                               l_sql,
                               "",
                               "X")

                returning l_retorno,
                          mr_padrao.dpycod,
                          mr_padrao.dpydes
        end if

        if mr_padrao.dpydes is null or
           mr_padrao.dpydes = " " then
           let mr_padrao.dpycod = null
           let mr_padrao.dpydes = null
        end if

        display by name mr_padrao.dpycod, mr_padrao.dpydes

     on key(f17, control-c, interrupt)
        initialize mr_padrao to null
        exit input

  end input

end function

#-------------------------#
function ctc34m15_display()
#-------------------------#

  display by name mr_padrao.socvclcod,
                  mr_padrao.pstcoddig,
                  mr_padrao.nomgrr,
                  mr_padrao.bckcod,
                  mr_padrao.bckdes,
                  mr_padrao.dpycod,
                  mr_padrao.dpydes

  display am_vistoria[1].vstsitdat      to s_ctc34m15[1].vstsitdat
  display am_vistoria[1].vstsitcod      to s_ctc34m15[1].vstsitcod
  display am_vistoria[1].vstsitdes      to s_ctc34m15[1].vstsitdes
  display am_vistoria[1].vstpbmcod      to s_ctc34m15[1].vstpbmcod
  display am_vistoria[1].vstpbmdes      to s_ctc34m15[1].vstpbmdes
  display am_vistoria[1].revdat         to s_ctc34m15[1].revdat
  display am_vistoria[1].caddat         to s_ctc34m15[1].caddat
  display am_vistoria[1].cadmat         to s_ctc34m15[1].cadmat
  display am_vistoria[1].nome_inclusao  to s_ctc34m15[1].nome_inclusao
  display am_vistoria[1].atldat         to s_ctc34m15[1].atldat
  display am_vistoria[1].atlmat         to s_ctc34m15[1].atlmat
  display am_vistoria[1].nome_alteracao to s_ctc34m15[1].nome_alteracao

end function

#--------------------------------------------#
function ctc34m15_operacao_array(lr_parametro)
#--------------------------------------------#

  define lr_parametro  record
         tipo_operacao char(01),
         vstsitcod     like dpakvst.vstsitcod,
         vstsitdat     like dpakvst.vstsitdat,
         socvclcod     like dpakvst.socvclcod,
         revdat        like dpakvst.revdat,
         vstpbmcod     like dpakvst.vstpbmcod,
         caddat        like dpakvst.caddat,
         cadmat        like dpakvst.cadmat,
         cademp        like dpakvst.cademp,
         atlemp        like dpakvst.atlemp,
         cadusrtip     like dpakvst.cadusrtip,
         atlusrtip     like dpakvst.atlusrtip,
         atlmat        like dpakvst.atlmat
  end record
  
  define l_mensagem    char(300),
         l_mensagem2   char(100),
         l_stt         smallint
         
  case lr_parametro.tipo_operacao

     when("I") # -> INCLUSAO

        whenever error continue
        execute pctc34m15011 using lr_parametro.vstsitcod,
                                   lr_parametro.vstsitdat,
                                   lr_parametro.socvclcod,
                                   lr_parametro.revdat,
                                   lr_parametro.vstpbmcod,
                                   lr_parametro.cadmat,
                                   lr_parametro.cademp,
                                   lr_parametro.cadusrtip
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro INSERT cctc34m15003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m15_operacao_array() / ", lr_parametro.vstsitcod, "/",
                                                 lr_parametro.vstsitdat, "/",
                                                 lr_parametro.socvclcod sleep 3
        else
           error "Inclusao realizada com sucesso"
        end if
              
       let l_mensagem  = "Padrao  do veiculo [",lr_parametro.socvclcod,"] Incluida "
       let l_mensagem2 = 'Incluido Padrao do Veiculo. Codigo : ',lr_parametro.socvclcod

       let l_stt = ctc34m01_grava_hist(lr_parametro.socvclcod
                                       ,l_mensagem
                                       ,today
                                       ,l_mensagem2,"I")

     when("A") # -> ALTERACAO

        whenever error continue
        execute pctc34m15012 using lr_parametro.revdat,
                                   lr_parametro.vstpbmcod,
                                   lr_parametro.atlmat,
                                   lr_parametro.caddat,
                                   lr_parametro.cadmat,
                                   lr_parametro.cademp,
                                   lr_parametro.atlemp,
                                   lr_parametro.cadusrtip,
                                   lr_parametro.atlusrtip,
                                   lr_parametro.vstsitcod,
                                   lr_parametro.vstsitdat,
                                   lr_parametro.socvclcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m15012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m15_operacao_array() / ", lr_parametro.vstsitcod, "/",
                                                 lr_parametro.vstsitdat, "/",
                                                 lr_parametro.socvclcod sleep 3
        else
           error "Atualizacao realizada com sucesso"
        end if

       let l_mensagem  = "Padrao [",lr_parametro.vstsitcod,"-", lr_parametro.vstsitdat,"] Alterado "
       let l_mensagem2 = 'Alterado Padrao do Veiculo. Codigo do Veiculo : ' clipped,lr_parametro.socvclcod

       let l_stt = ctc34m01_grava_hist(lr_parametro.socvclcod
                                       ,l_mensagem
                                       ,today
                                       ,l_mensagem2,"I")
     when("E") # -> EXCLUSAO

        whenever error continue
        execute pctc34m15013 using lr_parametro.vstsitcod,
                                   lr_parametro.vstsitdat,
                                   lr_parametro.socvclcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc34m15013 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m15_operacao_array() / ", lr_parametro.vstsitcod, "/",
                                                 lr_parametro.vstsitdat, "/",
                                                 lr_parametro.socvclcod sleep 3
        else
           error "Exclusao realizada com sucesso"
        end if
        
        let l_mensagem  = "Padrao  do veiculo [",lr_parametro.vstsitcod,"-",lr_parametro.vstsitdat,"] Excluido "
        let l_mensagem2 = 'Excluido Padrao do Veiculo. Codigo : ',lr_parametro.socvclcod

        let l_stt = ctc34m01_grava_hist(lr_parametro.socvclcod
                                       ,l_mensagem
                                       ,today
                                       ,l_mensagem2,"I")
  end case

end function

#-----------------------------------------#
function ctc34m15_operacao(l_tipo_operacao)
#-----------------------------------------#

  define l_tipo_operacao char(01)

  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "M" MODIFICAR}

  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m15003 using mr_padrao.socvclcod
        whenever error continue
        fetch cctc34m15003 into mr_padrao.socvclcod,
                                mr_padrao.pstcoddig,
                                mr_padrao.bckcod,
                                mr_padrao.dpycod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhum veiculo encontrado para o codigo informado"
              initialize mr_padrao to null
           else
              error "Erro SELECT cctc34m15003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m15_operacao() / ", mr_padrao.socvclcod sleep 3
           end if
        else

           call ctc34m15_carga_array()

           # --> BUSCA O NOME DE GUERRA DO PRESTADOR
           let mr_padrao.nomgrr = ctc34m15_pesq_nomgrr(mr_padrao.pstcoddig)

           # --> BUSCA A DESCRICAO DO BACKLIGHT DO VEICULO
           let mr_padrao.bckdes = ctc34m15_pesq_bckdes(mr_padrao.bckcod)

           # --> BUSCA A DESCRICAO DO DISPLAY DO VEICULO
           let mr_padrao.dpydes = ctc34m15_pesq_dpydes(mr_padrao.dpycod)

        end if

        close cctc34m15003

        call ctc34m15_display()

     when("M") # ---> MODIFICAR

        whenever error continue
        execute pctc34m15007 using mr_padrao.bckcod,
                                   mr_padrao.dpycod,
                                   mr_padrao.socvclcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m15007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m15_operacao() / ", mr_padrao.bckcod, "/",
                                           mr_padrao.dpycod, "/",
                                           mr_padrao.socvclcod sleep 3
        end if

  end case

end function
