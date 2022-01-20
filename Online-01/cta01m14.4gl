#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTA01M14                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  POPUP P/EXIBICAO DE INFORMACOES - CPF+NOME OU CARTAO+NOME. #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 18/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cta01m14_prep smallint

#-------------------------#
function cta01m14_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select cgccpfnum, ",
                     " cgccpfdig, ",
                     " segnom, ",
                     " crtstt ",
                " from datksegsau ",
               " where cgccpfnum = ? ",
                 " and cgccpfdig = ? ",
               " order by segnom "

  prepare p_cta01m14_001 from l_sql
  declare c_cta01m14_001 cursor for p_cta01m14_001

  let m_cta01m14_prep = true

end function

#-----------------------------#
function cta01m14(lr_parametro)
#-----------------------------#

  define lr_parametro record
         cgccpfnum    like datksegsau.cgccpfnum,
         cgccpfdig    like datksegsau.cgccpfdig,
         segnom       like datksegsau.segnom
  end record

  define al_dados     array[500] of record
         info1        char(21),
         info2        char(50)
  end record

  define l_segnom     like datksegsau.segnom,
         l_crtsaunum  like datksegsau.crtsaunum,
         l_cgccpfnum  like datksegsau.cgccpfnum,
         l_cgccpfdig  like datksegsau.cgccpfdig,
         l_indice     smallint,
         l_info1      char(18),
         l_info2      char(50),
         l_pesq_nome  smallint,
         l_sql        char(200),
         l_crtstt     like datksegsau.crtstt

  if m_cta01m14_prep is null or
     m_cta01m14_prep <> true then
     call cta01m14_prepare()
  end if

  # -> INICIALIZACAO DO ARRAY
  for l_indice = 1 to 500
     let al_dados[l_indice].info1 = null
     let al_dados[l_indice].info2 = null
  end for

  let l_segnom     = null
  let l_crtsaunum  = null
  let l_cgccpfnum  = null
  let l_cgccpfdig  = null
  let l_sql        = null
  let l_indice     = null
  let l_info1      = null
  let l_info2      = null
  let l_pesq_nome  = false

  open window w_cta01m14 at 7,4 with form "cta01m14"
     attribute(border, form line 1, message line last)

  display "                  RELACAO DOS DOCUMENTOS ENCONTRADOS"
           to titulo_janela attribute(reverse)

  message "Favor aguardar, pesquisando..." attribute(reverse)

  if lr_parametro.segnom is not null then

     # -> PESQUISA POR NOME

     let l_pesq_nome = true # VAI PESQUISAR POR NOME

     display "Nº DO CARTAO"     to titulo_popup1 attribute(reverse)
     display "NOME DO SEGURADO" to titulo_popup2 attribute(reverse)

     let l_sql = " select crtsaunum, ",
                        " segnom, ",
                        " crtstt ",
                   " from datksegsau ",
                  " where segnom like '", lr_parametro.segnom clipped, "%'",
                  " order by segnom "

     prepare p_cta01m14_002 from l_sql
     declare c_cta01m14_002 cursor for p_cta01m14_002

     let l_indice = 1

     open c_cta01m14_002
     foreach c_cta01m14_002 into l_crtsaunum,
                               al_dados[l_indice].info2,
                               l_crtstt

        #-------------------------------
        # DESPREZA OS CARTOES CANCELADOS
        #-------------------------------
        if l_crtstt = "C" then  # CANCELADO
           continue foreach
        end if

        # -> MONTA O NOVO FOMATO DO CARTAO
        let al_dados[l_indice].info1 =
            cts20g16_formata_cartao(l_crtsaunum)

        let l_indice = (l_indice + 1)

        if l_indice > 500 then
           error "Limite do array superado! CTA01M14.4GL" sleep 2
           exit foreach
        end if

     end foreach
     close c_cta01m14_002

     let l_indice = (l_indice - 1)

  else

     # -> PESQUISA POR CPF

     display "CPF"              to titulo_popup1 attribute(reverse)
     display "NOME DO SEGURADO" to titulo_popup2 attribute(reverse)

     let l_indice = 0

     open c_cta01m14_001 using lr_parametro.cgccpfnum,
                             lr_parametro.cgccpfdig

     foreach c_cta01m14_001 into l_cgccpfnum,
                               l_cgccpfdig,
                               l_segnom,
                               l_crtstt

        #-------------------------------
        # DESPREZA OS CARTOES CANCELADOS
        #-------------------------------
        if l_crtstt = "C" then  # CANCELADO
           continue foreach
        end if

        let l_indice = (l_indice + 1)

        let al_dados[l_indice].info1 = l_cgccpfnum using "&&&&&&&&&", "-",
                                       l_cgccpfdig using "&&"
        let al_dados[l_indice].info2 = l_segnom

        if l_indice = 500 then
           error "Limite do array superado! CTA01M14.4GL" sleep 2
           exit foreach
        end if

     end foreach
     close c_cta01m14_001

  end if

  message " "

  call set_count(l_indice)

  # -> EXIBE OS DADOS NA POPUP
  display array al_dados to s_cta01m14.*

     on key(f8)
        let l_indice = arr_curr()

        if l_pesq_nome = true then

           if (length(al_dados[l_indice].info1)) = 19 then
              # -> REMOVE OS "." DOS NUMERO DO CARTAO(18 digitos)
              let l_info1 = al_dados[l_indice].info1[1,4]   clipped,
                            al_dados[l_indice].info1[6,9]   clipped,
                            al_dados[l_indice].info1[11,14] clipped,
                            al_dados[l_indice].info1[16,19] clipped
           else
              if (length(al_dados[l_indice].info1)) = 21 then
                 # -> REMOVE OS "." DOS NUMERO DO CARTAO(21 digitos)
                 let l_info1 = al_dados[l_indice].info1[1,5]   clipped,
                               al_dados[l_indice].info1[7,14]  clipped,
                               al_dados[l_indice].info1[16,18] clipped,
                               al_dados[l_indice].info1[20,21] clipped
              else
                 let l_info1 = al_dados[l_indice].info1
              end if
           end if

           let l_info2 = al_dados[l_indice].info2
        else
           let l_info1 = al_dados[l_indice].info1
           let l_info2 = al_dados[l_indice].info2
        end if

        exit display

     on key(f17, control-c, interrupt)
        let l_info1 = null
        let l_info2 = null
        exit display

  end display

  close window w_cta01m14
  let int_flag = false

  return l_info1,
         l_info2


end function
