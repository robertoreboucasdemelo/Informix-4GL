#_----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTA01M13                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  LOCALIZACAO DE DOCUMETO - APOLICES RAMO SAUDE.             #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 15/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 16/11/2006 Ligia Mattge    PSI 205206 parametro 1 em ctc56m03               #
# ---------- --------------  ---------- ------------------------------------- #
# 29/12/2009 Patricia W.                Projeto SUCCOD - Smallint             #
#-----------------------------------------------------------------------------#

database porto

#-----------------------------#
function cta01m13(lr_parametro)
#-----------------------------#

  define lr_parametro record
         crtsaunum    like datksegsau.crtsaunum,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgccpfdig    like datksegsau.cgccpfdig,
         segnom       like datksegsau.segnom
  end record

  define lr_dados     record
         bnfnum       like datksegsau.bnfnum,
         crtsaunum    like datksegsau.crtsaunum,
         succod       like datksegsau.succod,
         ramcod       like datksegsau.ramcod,
         aplnumdig    like datksegsau.aplnumdig,
         crtstt       like datksegsau.crtstt,
         plncod       like datksegsau.plncod,
         segnom       like datksegsau.segnom,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgcord       like datksegsau.cgcord,
         cgccpfdig    like datksegsau.cgccpfdig,
         empnom       like datksegsau.empnom,
         corsus       like datksegsau.corsus,
         cornom       like datksegsau.cornom,
         cntanvdat    like datksegsau.cntanvdat,
         lgdtip       like datksegsau.lgdtip,
         lgdnom       like datksegsau.lgdnom,
         lgdnum       like datksegsau.lgdnum,
         lclbrrnom    like datksegsau.lclbrrnom,
         cidnom       like datksegsau.cidnom,
         ufdcod       like datksegsau.ufdcod,
         lclrefptotxt like datksegsau.lclrefptotxt,
         endzon       like datksegsau.endzon,
         lgdcep       like datksegsau.lgdcep,
         lgdcepcmp    like datksegsau.lgdcepcmp,
         dddcod       like datksegsau.dddcod,
         lcltelnum    like datksegsau.lcltelnum,
         lclcttnom    like datksegsau.lclcttnom,
         lclltt       like datksegsau.lclltt,
         lcllgt       like datksegsau.lcllgt,
         incdat       like datksegsau.incdat,
         excdat       like datksegsau.excdat,
         brrnom       like datksegsau.brrnom,
         c24lclpdrcod like datksegsau.c24lclpdrcod,
         plndes       like datkplnsau.plndes,
         plnatnlimnum like datkplnsau.plnatnlimnum
  end record

  define lr_corretor  record
         endlgd       like gcakfilial.endlgd,
         endnum       integer,
         endcmp       like gcakfilial.endcmp,
         endbrr       like gcakfilial.endbrr,
         endcid       like gcakfilial.endcid,
         endcep       like gcakfilial.endcep,
         endcepcmp    like gcakfilial.endcepcmp,
         endufd       like gcakfilial.endufd,
         dddcod       like gcakfilial.dddcod,
         teltxt       like gcakfilial.teltxt,
         dddfax       like gcakfilial.dddfax,
         factxt       like gcakfilial.factxt,
         maides       like gcakfilial.maides,
         crrdstcod    like gcaksusep.crrdstcod,
         crrdstnum    like gcaksusep.crrdstnum,
         crrdstsuc    like gcaksusep.crrdstsuc,
         retorno      smallint  # 0 OK / 1 SUSEP INEXIST / 2 END.NAO LOCALIZ
  end record

  define l_status     smallint,
         l_msg        char(80)

  initialize lr_dados.* to null
  initialize lr_corretor.* to null

  let l_status = null
  let l_msg    = null

  open window w_cta01m13 at 4,2 with form "cta01m13"
     attribute(border, form line 1)

  #---------------------------------------------------------
  # SE NAO EXISTIR PARAMETROS ABRE A OPCAO DE INFORMAR DADOS
  #---------------------------------------------------------
  if lr_parametro.crtsaunum is null and
     lr_parametro.cgccpfnum is null and
     lr_parametro.cgccpfdig is null and
     lr_parametro.segnom    is null then

     #---------------------------------------------
     # CHAMA A FUNCAO PARA ENTRADA DOS DADOS(INPUT)
     #---------------------------------------------
     call cta01m13_input()
          returning lr_dados.crtsaunum,
                    lr_dados.segnom,
                    lr_dados.cgccpfnum,
                    lr_dados.cgccpfdig
  else
     #------------------------------------------------------------------
     # A FUNCAO JA RECEBEU OS DADOS COMO PARAMETRO, APENAS EXIBE EM TELA
     #------------------------------------------------------------------
     let lr_dados.crtsaunum = lr_parametro.crtsaunum
     let lr_dados.segnom    = lr_parametro.segnom
     let lr_dados.cgccpfnum = lr_parametro.cgccpfnum
     let lr_dados.cgccpfdig = lr_parametro.cgccpfdig
  end if

  if lr_dados.crtsaunum is not null or
     lr_dados.segnom    is not null or
     lr_dados.cgccpfnum is not null or
     lr_dados.cgccpfdig is not null then

     #---------------------------------------------------
     # CHAMA A FUNCAO PARA CARREGAR OS DADOS DO DOCUMENTO
     #---------------------------------------------------
     call cta01m15_sel_datksegsau(1,  # -> NIVEL RETORNO
                                  lr_dados.crtsaunum,
                                  lr_dados.segnom,
                                  lr_dados.cgccpfnum,
                                  lr_dados.cgccpfdig)

          returning l_status,
                    l_msg,
                    lr_dados.bnfnum,
                    lr_dados.crtsaunum,
                    lr_dados.succod,
                    lr_dados.ramcod,
                    lr_dados.aplnumdig,
                    lr_dados.crtstt,
                    lr_dados.plncod,
                    lr_dados.segnom,
                    lr_dados.cgccpfnum,
                    lr_dados.cgcord,
                    lr_dados.cgccpfdig,
                    lr_dados.empnom,
                    lr_dados.corsus,
                    lr_dados.cornom,
                    lr_dados.cntanvdat,
                    lr_dados.lgdtip,
                    lr_dados.lgdnom,
                    lr_dados.lgdnum,
                    lr_dados.lclbrrnom,
                    lr_dados.cidnom,
                    lr_dados.ufdcod,
                    lr_dados.lclrefptotxt,
                    lr_dados.endzon,
                    lr_dados.lgdcep,
                    lr_dados.lgdcepcmp,
                    lr_dados.dddcod,
                    lr_dados.lcltelnum,
                    lr_dados.lclcttnom,
                    lr_dados.lclltt,
                    lr_dados.lcllgt,
                    lr_dados.incdat,
                    lr_dados.excdat,
                    lr_dados.brrnom,
                    lr_dados.c24lclpdrcod

     if l_status <> 3 then # ERRO DE ACESSO AO BANCO
        #---------------------------
        # BUSCA A DESCRICAO DO PLANO
        #---------------------------
        call cta01m16_sel_datkplnsau(lr_dados.plncod)
             returning l_status,
                       l_msg,
                       lr_dados.plndes,
                       lr_dados.plnatnlimnum

        if l_status <> 3 then # ERRO DE ACESSO AO BANCO

           #---------------------------
           # BUSCA OS DADOS DO CORRETOR
           #---------------------------
           call fgckc811(lr_dados.corsus)
                returning lr_corretor.endlgd,
                          lr_corretor.endnum,
                          lr_corretor.endcmp,
                          lr_corretor.endbrr,
                          lr_corretor.endcid,
                          lr_corretor.endcep,
                          lr_corretor.endcepcmp,
                          lr_corretor.endufd,
                          lr_corretor.dddcod,
                          lr_corretor.teltxt,
                          lr_corretor.dddfax,
                          lr_corretor.factxt,
                          lr_corretor.maides,
                          lr_corretor.crrdstcod,
                          lr_corretor.crrdstnum,
                          lr_corretor.crrdstsuc,
                          lr_corretor.retorno

           #-----------------------
           # EXIBE OS DADOS NA TELA
           #-----------------------
           call cta01m13_exibe(lr_dados.crtsaunum,
                               lr_dados.succod,
                               lr_dados.ramcod,
                               lr_dados.aplnumdig,
                               lr_dados.segnom,
                               lr_dados.cgccpfnum,
                               lr_dados.cgccpfdig,
                               lr_dados.crtstt,
                               lr_dados.empnom,
                               lr_dados.corsus,
                               lr_dados.cornom,
                               lr_dados.dddcod,
                               lr_dados.lcltelnum,
                               lr_dados.plncod,
                               lr_dados.plndes,
                               lr_dados.cntanvdat,
                               lr_corretor.dddcod,
                               lr_corretor.teltxt)

           #-------------------------------------------------------
           # ESPERA ATE O ATENDENTE VISUALIZAR OS DADOS OU CANCELAR
           #-------------------------------------------------------
           call cta01m13_espera(lr_dados.ramcod,
                                lr_dados.plncod,
                                lr_dados.bnfnum,
                                lr_dados.crtsaunum)

        else
           error l_msg sleep 3
        end if
     else
        error l_msg sleep 3
     end if

  end if

  close window w_cta01m13
  let int_flag = false

  return lr_dados.succod,
         lr_dados.ramcod,
         lr_dados.aplnumdig,
         lr_dados.crtsaunum,
         lr_dados.bnfnum
end function

#-----------------------#
function cta01m13_input()
#-----------------------#

  define lr_input   record
         crtsaunum  like datksegsau.crtsaunum,
         segnom     like datksegsau.segnom,
         cgccpfnum  like datksegsau.cgccpfnum,
         cgccpfdig  like datksegsau.cgccpfdig
  end record

  define l_qtd_reg  smallint,
         l_status   smallint,
         l_msg      char(80),
         l_info1    char(18),
         l_info2    char(50),
         l_dig_ret  like datksegsau.cgccpfdig

  let l_qtd_reg = null
  let l_info1   = null
  let l_info2   = null
  let l_status  = null
  let l_msg     = null
  let l_dig_ret = null

  initialize lr_input.* to null

  input lr_input.crtsaunum,
        lr_input.segnom,
        lr_input.cgccpfnum,
        lr_input.cgccpfdig without defaults from crtsaunum,
                                                 segnom,
                                                 cgccpfnum,
                                                 cgccpfdig
     #-----------------
     # NUMERO DO CARTAO
     #-----------------
     before field crtsaunum
        display by name lr_input.crtsaunum attribute(reverse)

     after field crtsaunum
        display by name lr_input.crtsaunum

        if lr_input.crtsaunum is not null then
           #----------------------------------------------------------
           # VERIFICA SE EXISTE DOCUMENTO COM O Nº DO CARTAO INFORMADO
           #----------------------------------------------------------
           call cta01m15_sel_datksegsau(5,
                                        lr_input.crtsaunum,
                                        "",
                                        "",
                                        "")
                returning l_status,
                          l_msg,
                          lr_input.segnom

           if l_status <> 1 then
              if l_status = 2 then
                 error "Nenhum documento encontrado com o nº do cartao informado."
                 next field crtsaunum
              else
                 error "Erro ao chamar cta01m15_sel_datksegsau() " sleep 2
                 error l_msg sleep 3
              end if
           else
              exit input
           end if

        end if

     #-----------------
     # NOME DO SEGURADO
     #-----------------
     before field segnom
        display by name lr_input.segnom attribute(reverse)

     after field segnom
        display by name lr_input.segnom

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field crtsaunum
        end if

        if lr_input.segnom is not null then

           #-------------------------------------------------------
           # VERIFICA A QUANTIDADE DE DOCUMENTOS C/O NOME INFORMADO
           #-------------------------------------------------------
           let l_qtd_reg = cta01m15_psq_nome(lr_input.segnom)

           if l_qtd_reg <> 0 then
              if l_qtd_reg >= 1 then

                 #----------------------
                 # CHAMA A TELA DE POPUP
                 #----------------------
                 call cta01m14("", # -> CGCCPFNUM
                               "", # -> CGCCPFDIG
                               lr_input.segnom)

                      returning l_info1, # -> NUMERO DO CARTAO
                                l_info2  # -> NOME DO SEGURADO

                 if l_info1 is null or
                    l_info2 is null then
                    error "Nenhum nome selecionado."
                    next field segnom
                 else
                    let lr_input.crtsaunum = l_info1 # -> NUMERO DO CARTAO
                    let lr_input.segnom    = l_info2 # -> NOME DO SEGURADO
                    exit input
                 end if
              else
                 exit input
              end if
           else
              error "Nenhum documento encontrado com o nome informado."
              next field segnom
           end if
        end if

     #------------------
     # NUMERO DO CGC/CPF
     #------------------
     before field cgccpfnum
        display by name lr_input.cgccpfnum attribute(reverse)

     after field cgccpfnum
        display by name lr_input.cgccpfnum

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field segnom
        end if

     #---------------
     # DIGITO CGC/CPF
     #---------------
     before field cgccpfdig
        display by name lr_input.cgccpfdig attribute(reverse)

     after field cgccpfdig
        display by name lr_input.cgccpfdig

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field cgccpfnum
        end if

        if lr_input.cgccpfnum is not null then
           if lr_input.cgccpfdig is null then
              error "Informe o digito do cpf."
              next field cgccpfdig
           end if
        end if

        #-----------------------
        # VALIDA O DIGITO DO CPF
        #-----------------------
        if lr_input.cgccpfnum is not null then
           let l_dig_ret = f_fundigit_digitocpf(lr_input.cgccpfnum)

           if l_dig_ret is null or
              lr_input.cgccpfdig <> l_dig_ret then
              error "Digito do CPF incorreto."
              next field cgccpfdig
           end if
        end if

        if lr_input.cgccpfnum is not null and
           lr_input.cgccpfdig is not null then

           #------------------------------------------------------
           # VERIFICA A QUANTIDADE DE DOCUMENTOS C/O CPF INFORMADO
           #------------------------------------------------------
           let l_qtd_reg = cta01m15_psq_cpf(lr_input.cgccpfnum,
                                            lr_input.cgccpfdig)
           if l_qtd_reg <> 0 then
              if l_qtd_reg > 1 then
                 #----------------------
                 # CHAMA A TELA DE POPUP
                 #----------------------
                 call cta01m14(lr_input.cgccpfnum,
                               lr_input.cgccpfdig,
                               "") # -> SEGNOM

                      returning l_info1, # -> CPF + DIG
                                l_info2  # -> NOME DO SEGURADO

                 if l_info1 is null or
                    l_info2 is null then
                    error "Nenhum cpf selecionado."
                    next field segnom
                 else
                    let lr_input.cgccpfnum = l_info1[1,9]   # -> Nº CPF
                    let lr_input.cgccpfdig = l_info1[11,12] # -> DIGITO CPF
                    let lr_input.segnom    = l_info2        # -> NOME DO SEGURADO
                    exit input
                 end if

              else
                 exit input
              end if
           else
              error "Nenhum documento encontrado com o cpf informado."
              next field cgccpfnum
           end if
        end if

        next field crtsaunum # VOLTA PARA O PRIMEIRO CAMPO(NUMERO DO CARTAO)

     on key(f17, control-c, interrupt)
        initialize lr_input.* to null
        exit input

  end input

  return lr_input.crtsaunum,
         lr_input.segnom,
         lr_input.cgccpfnum,
         lr_input.cgccpfdig

end function

#-----------------------------------#
function cta01m13_exibe(lr_parametro)
#-----------------------------------#

  define lr_parametro   record
         crtsaunum      like datksegsau.crtsaunum,
         succod         like datksegsau.succod,
         ramcod         like datksegsau.ramcod,
         aplnumdig      like datksegsau.aplnumdig,
         segnom         like datksegsau.segnom,
         cgccpfnum      like datksegsau.cgccpfnum,
         cgccpfdig      like datksegsau.cgccpfdig,
         crtstt         like datksegsau.crtstt,
         empnom         like datksegsau.empnom,
         corsus         like datksegsau.corsus,
         cornom         like datksegsau.cornom,
         dddcod         like datksegsau.dddcod,
         lcltelnum      like datksegsau.lcltelnum,
         plncod         like datkplnsau.plncod,
         plndes         like datkplnsau.plndes,
         cntanvdat      like datksegsau.cntanvdat,
         ddd_cor        like gcakfilial.dddcod,
         fone_cor       like gcakfilial.teltxt
  end record

  define l_novo_formato char(21),
         l_fone_seg     char(13),
         l_fone_cor     char(45),
         l_documento    char(21),
         l_situacao     char(10)

  let l_novo_formato = null
  let l_documento    = null
  let l_fone_seg     = null
  let l_fone_cor     = null
  let l_situacao     = null

  # -> FORMATA O Nº DO CARTAO xxxx.xxxx.xxxx.xxxx(p/16 posicoes) ou
  # -> xxxxx.xxxxxxxx.xxx.xx (p/18 posicoes)
  let l_novo_formato = cts20g16_formata_cartao(lr_parametro.crtsaunum)

  # -> FORMATA O DOCUMENTO: SUCURSAL + RAMO + APOLICE
  let l_documento = lr_parametro.succod    using "<<<&&",       " ",  #"&&",       " ",  #projeto succod
                    lr_parametro.ramcod    using "&&&&",     " ",
                    lr_parametro.aplnumdig using "<<<<<<<<&"

  # -> FORMATA O TELEFONE DO SEGURADO DDD + Nº
  let l_fone_seg  = lr_parametro.dddcod    clipped, " ",
                    lr_parametro.lcltelnum

  # -> FORMATA O TELEFONE DO CORRETOR DDD + Nº
  let l_fone_cor  = lr_parametro.ddd_cor   clipped, " ",
                    lr_parametro.fone_cor

  # -> FORMATA SITUACAO DO CARTAO
  case lr_parametro.crtstt

     when "A"
        let l_situacao = "ATIVO"
     when "C"
        let l_situacao = "CANCELADO"
     when "R"
        let l_situacao = "REMIDO"
     otherwise
        let l_situacao = "NInformado"

  end case

  display l_novo_formato to crtsaunum
  display l_documento    to documento
  display l_fone_seg     to fone_seg
  display l_fone_cor     to fone_cor
  display l_situacao     to situacao

  display by name lr_parametro.segnom,
                  lr_parametro.cgccpfnum,
                  lr_parametro.cgccpfdig,
                  lr_parametro.empnom,
                  lr_parametro.corsus,
                  lr_parametro.cornom,
                  lr_parametro.plncod,
                  lr_parametro.plndes,
                  lr_parametro.cntanvdat

end function

#------------------------------------#
function cta01m13_espera(lr_parametro)
#------------------------------------#

  define lr_parametro record
         ramcod       like datksegsau.ramcod,
         plncod       like datksegsau.plncod,
         bnfnum       like datksegsau.bnfnum,
         crtsaunum    like datksegsau.crtsaunum
  end record

  # -> FUNCAO PARA AGUARDAR UMA ACAO DO USUARIO

  define l_espera char(01)

  let l_espera = null

  input l_espera without defaults from espera

     after field espera
        let l_espera = null
        call ctc56m03(1, ##Porto
                      lr_parametro.ramcod,
                      0,
                      lr_parametro.plncod)
        next field espera

     on key(f4)
        call ctn13c00(0) # -> CONVENIO

     on key(f17, control-c, interrupt)
        exit input

  end input

end function
