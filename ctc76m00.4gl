###############################################################################
# Nome do Modulo: ctc76m00                                     Cristiane Silva#
#                                                                             #
# Servicos de RE realizados pelo prestador                           Nov/2005 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql  smallint,
       m_nomrazsoc like dpaksocor.nomrazsoc

define am_ctc76m00  array[50] of record
         navega    char(01),
         socntzgrpcod   smallint,
         socntzgrpdes   like datksocntzgrp.socntzgrpdes
 end record

define m_contador smallint

define m_sair smallint

define socntzgrpcod_ant like datksocntzgrp.socntzgrpcod

#--------------#
function ctc76m00(param)
#--------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc        like dpaksocor.nomrazsoc
end record

define ws record
        soccntdes like datksocntz.socntzdes,
        codigo    like datksocntz.socntzgrpcod,
        erro      smallint
end record

define l_sucesso     smallint

let l_sucesso   = true
let m_nomrazsoc = param.nomrazsoc

options
    prompt line last,
    insert key f1,
    delete key control-y


open window w_ctc76m00 at 05,02 with form "ctc76m00"
display by name param.pstcoddig
display by name param.nomrazsoc


call ctc76m00_prepare()

while true
        call ctc76m00_carrega_array(param.pstcoddig, param.nomrazsoc)
        call ctc76m00_entra_dados(param.pstcoddig, param.nomrazsoc)
        if m_sair = true then
                exit while
        end if
end while

options
delete key f2

close window w_ctc76m00

let int_flag = false

end function

#----------------------#
function ctc76m00_prepare()
#----------------------#

  define l_sql char(600)

#Seleção principal
let l_sql = 'select ntz.socntzgrpcod, grp.socntzgrpdes',
            ' from dparpstgrpntz ntz, datksocntzgrp grp' ,
            ' where ntz.pstcoddig = ?',
            ' and ntz.socntzgrpcod = grp.socntzgrpcod',
            ' order by 1'
prepare pctc76m00001 from l_sql
declare cctc76m00001 cursor for pctc76m00001


#Inserção do registro
  let l_sql = " insert into dparpstgrpntz (pstcoddig, socntzgrpcod, atldat, atlemp, atlmat) values (?,?,today,?,? ) "
  prepare pctc76m00002 from l_sql

#Deleção de registro
  let l_sql = ' delete from  dparpstgrpntz where pstcoddig = ? and socntzgrpcod = ?'
  prepare pctc76m00003 from l_sql

#Busca a descricao do codigo
let l_sql = 'select socntzgrpdes from datksocntzgrp where socntzgrpcod = ?'
prepare pctc76m00005 from l_sql
declare cctc76m00005 cursor for pctc76m00005

#Verificação se registro já existe
let l_sql = ' select socntzgrpcod from dparpstgrpntz where pstcoddig = ? and socntzgrpcod = ?'
prepare pctc76m00006 from l_sql
declare cctc76m00006 cursor for pctc76m00006


end function

#----------------------------#
function ctc76m00_carrega_array(param)
#----------------------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc       like dpaksocor.nomrazsoc
end record

initialize am_ctc76m00 to null

let m_contador = 1

open cctc76m00001 using param.pstcoddig

        foreach cctc76m00001 into  am_ctc76m00[m_contador].socntzgrpcod,
                         am_ctc76m00[m_contador].socntzgrpdes
     let m_contador = m_contador + 1

     if m_contador = 51 then
        error "O limite de 50 registros foi ultrapassado" sleep 2
        exit foreach
     end if

  end foreach

  let m_contador = m_contador - 1

end function

#--------------------------#
function ctc76m00_entra_dados(param)
#--------------------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc       like dpaksocor.nomrazsoc
end record

define ws record
        socntzgrpcod like datksocntzgrp.socntzgrpcod,
        clscod    like datrsocntzsrvre.clscod,
        sta       smallint,
        mensagem  char(100),
        socntzgrpdes like datksocntzgrp.socntzgrpdes,
        codigo    like datksocntzgrp.socntzgrpcod,
        erro      smallint,
        funnom    char(100),
        cod       smallint
end record

define l_operacao      char(01),
        l_arr           smallint,
        l_scr           smallint,
        l_codigo        smallint,
        l_resposta      char(01),
        l_situacao_ant  char(01),
        l_descricao_ant like datksocntzgrp.socntzgrpdes,
        l_cod_ant        smallint,
        l_espcod         smallint,
        l_nulo           char(004),
        l_espdes         char(50),
        l_socntzdes      char(50),
        l_data           date,
        l_resultado      smallint,
        l_mensagem       char(50),
        l_descricao      char(30)

define l_sucesso     smallint

let l_arr           = null
let l_situacao_ant  = null
let l_descricao_ant = null
let l_scr           = null
let l_resposta      = null
let l_nulo          = null
let l_data            = today
let l_sucesso = true
let int_flag = false
let l_operacao = " "
let m_sair = false
let socntzgrpcod_ant = null
let ws.cod = null

call set_count(m_contador)

while true

     input array am_ctc76m00 without defaults from s_ctc76m00.*

         before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field socntzgrpcod
           end if

        after field navega
            if fgl_lastkey() = 2014 then
              let l_operacao = "I"
           else
              if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctc76m00[l_arr + 1].socntzgrpcod is null then
                    next field navega
                 else
                    continue input
                 end if
              end if
              if fgl_lastkey() = 2005 or    ## f3
                 fgl_lastkey() = 2006 then  ## f4
                 continue input
              end if
              if fgl_lastkey() = fgl_keyval('up') then
                 continue input
              else
                 next field navega
              end if
           end if



        before field socntzgrpcod
        display am_ctc76m00[l_arr].socntzgrpcod to s_ctc76m00[l_scr].socntzgrpcod attribute(reverse)

        if l_operacao = "A" then
              display am_ctc76m00[l_arr].socntzgrpcod to s_ctc76m00[l_scr].socntzgrpcod
        end if

        after field socntzgrpcod
        display am_ctc76m00[l_arr].socntzgrpcod to s_ctc76m00[l_scr].socntzgrpcod
        if l_operacao = "I" then
                if am_ctc76m00[l_arr].socntzgrpcod is null then
                        error "Codigo nao pode ser nulo"
                        call ctx24g00_popup_grupo()
                        returning l_resultado, ws.socntzgrpcod
                        if ws.socntzgrpcod is not null then
                                open cctc76m00006 using param.pstcoddig, ws.socntzgrpcod
                                fetch cctc76m00006 into ws.cod
                                if ws.cod is null then
                                        let am_ctc76m00[l_arr].socntzgrpcod = ws.socntzgrpcod
                                        display am_ctc76m00[l_arr].socntzgrpcod to s_ctc76m00[l_scr].socntzgrpcod
                                        open cctc76m00005 using ws.socntzgrpcod
                                        fetch cctc76m00005 into l_descricao
                                        if l_descricao is not null then
                                                let am_ctc76m00[l_arr].socntzgrpdes = l_descricao
                                                display am_ctc76m00[l_arr].socntzgrpdes to s_ctc76m00[l_scr].socntzgrpdes
                                        end if
                                else
                                        error "Código ja existente" sleep 2
                                        let ws.cod = null
                                        let am_ctc76m00[l_arr].socntzgrpcod = null
                                        next field socntzgrpcod
                                end if
                        else
                                continue input
                        end if
                else
                        open cctc76m00006 using param.pstcoddig, am_ctc76m00[l_arr].socntzgrpcod
                        fetch cctc76m00006 into ws.cod
                        if ws.cod is null then
                                open cctc76m00005 using am_ctc76m00[l_arr].socntzgrpcod
                                whenever error continue
                                        fetch cctc76m00005 into l_socntzdes
                                whenever error stop
                                        if sqlca.sqlcode <> 0 then
                                                error " Codigo nao encontrado" sleep 2
                                                next field socntzgrpcod
                                        end if
                                let am_ctc76m00[l_arr].socntzgrpdes = l_socntzdes
                                display am_ctc76m00[l_arr].socntzgrpdes to s_ctc76m00[l_scr].socntzgrpdes
                        else
                                error "Código ja existente" sleep 2
                                let ws.cod = null
                                let am_ctc76m00[l_arr].socntzgrpcod = null
                                next field socntzgrpcod
                        end if
                end if
         else
                if am_ctc76m00[l_arr].socntzgrpcod is not null then
                        open cctc76m00005 using am_ctc76m00[l_arr].socntzgrpcod
                        whenever error continue
                                fetch cctc76m00005 into l_socntzdes
                        whenever error stop
                                if sqlca.sqlcode <> 0 then
                                        error " Codigo nao encontrado" sleep 2
                                        next field socntzgrpcod
                                end if
                        let am_ctc76m00[l_arr].socntzgrpdes = l_socntzdes
                        display am_ctc76m00[l_arr].socntzgrpdes to s_ctc76m00[l_scr].socntzgrpdes
                end if
        end if
        while true

              if l_operacao = "I" then
                 prompt 'Confirma inclusao do registro? (S/N)' for l_resposta
              end if

              if l_operacao = "A" then
                 prompt 'Confirma alteracao do registro? (S/N)' for l_resposta
              end if

              let l_resposta = upshift(l_resposta)

              if l_resposta = 'S' or l_resposta = 'N' or int_flag then
                 exit while
              end if
       end while

       if int_flag then
                let int_flag = true
                let l_resposta = "N"
       end if

       if l_resposta = "S" then
                if l_operacao = "I" then
                        if ctc76m00_executa_operacao("I",
                                           param.pstcoddig,
                                           am_ctc76m00[l_arr].socntzgrpcod,
                                           g_issk.empcod, g_issk.funmat, socntzgrpcod_ant,
                                           l_descricao_ant,
                                           am_ctc76m00[l_arr].socntzgrpdes) then
                                error "Registro incluido com sucesso" sleep 2
                        else
                                let int_flag = true
                                exit input
                        end if
                end if
                if l_operacao = "A" then

                        if ctc76m00_executa_operacao("A",
                                           param.pstcoddig,
                                           am_ctc76m00[l_arr].socntzgrpcod,
                                           g_issk.empcod, g_issk.funmat, socntzgrpcod_ant,
                                           l_descricao_ant,
                                           am_ctc76m00[l_arr].socntzgrpdes) then
                                error "Registro alterado com sucesso" sleep 2
                        else
                                let int_flag = true
                                exit input
                        end if
                end if
        else
                if l_operacao = "I" then
                        let am_ctc76m00[l_arr].socntzgrpcod = socntzgrpcod_ant
                        call ctc76m00_deleta_linha(l_arr, l_scr)
                else
                        let am_ctc76m00[l_arr].socntzgrpcod = socntzgrpcod_ant
                        let am_ctc76m00[l_arr].socntzgrpdes = l_descricao_ant
                        call ctc76m00_deleta_linha(l_arr, l_scr)
                end if
        end if
           let l_operacao = " "
           next field navega


        on key(f2)

          while true
             prompt "Confirma a exclusao? (S/N) " for l_resposta

             let l_resposta = upshift(l_resposta)

            if l_resposta = 'S' or l_resposta = 'N' or int_flag then
               exit while
             else
                error "Digite somente S ou N" sleep 2
             end if
          end while

          if int_flag then
             let l_resposta = "N"
             let int_flag = false
          end if

         if upshift(l_resposta) = "S" then
             if ctc76m00_executa_operacao("E",
                                           param.pstcoddig,
                                           am_ctc76m00[l_arr].socntzgrpcod,
                                           g_issk.empcod,
                                           g_issk.funmat,
                                           socntzgrpcod_ant,
                                           l_descricao_ant,
                                           am_ctc76m00[l_arr].socntzgrpdes) then
                error "Registro excluido com sucesso" sleep 2
                call ctc76m00_deleta_linha(l_arr,l_scr)
                exit input
             end if
             let m_contador = arr_count()
             exit input
          else
             error "Delecao cancelada" sleep 2
          end if


       on key(f6)
          if l_operacao = "I" or
             l_operacao = "A" or
             l_operacao = "E" then
             error "F6 nao pode ser teclada neste momento "
          else
             let l_operacao = "A"
             let socntzgrpcod_ant = am_ctc76m00[l_arr].socntzgrpcod
             let l_descricao_ant = am_ctc76m00[l_arr].socntzgrpdes
             let am_ctc76m00[l_arr].socntzgrpcod = null
             let am_ctc76m00[l_arr].socntzgrpdes = null
             display am_ctc76m00[l_arr].socntzgrpdes to s_ctc76m00[l_scr].socntzgrpcod
             display am_ctc76m00[l_arr].socntzgrpdes to s_ctc76m00[l_scr].socntzgrpdes
             next field socntzgrpcod
          end if

       on key (control-c, f17, interrupt)
          initialize am_ctc76m00[l_arr].* to null
          let int_flag = true
          let m_sair = true
          let m_contador = 0
          exit input

     end input

     if int_flag then
        exit while
     end if

  end while

end function

#---------------------------------------#
function ctc76m00_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint
  for l_cont = l_arr to 49
     if am_ctc76m00[l_arr].socntzgrpcod is not null then
        let am_ctc76m00[l_cont].* = am_ctc76m00[l_cont + 1].*
     else
        initialize am_ctc76m00[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 8
     display am_ctc76m00[l_arr].socntzgrpcod    to s_ctc76m00[l_cont].socntzgrpcod
     display am_ctc76m00[l_arr].socntzgrpdes    to s_ctc76m00[l_cont].socntzgrpdes
     let l_arr = l_arr + 1
  end for

end function

#----------------------------------------------#
function ctc76m00_executa_operacao(lr_parametro)
#----------------------------------------------#

  define lr_parametro  record
         tipo_operacao char(01),
         pstcoddig      smallint,
         socntzgrpcod   smallint,
         empcod        smallint,
         funmat        smallint,
         socntzgrpcod_ant smallint,
         socntzgrpdes_ant  like datksocntzgrp.socntzgrpdes,
         socntzgrpdes      like datksocntzgrp.socntzgrpdes
    end record

  define l_sucesso     smallint
  define l_socntzgrpcod      smallint
  define l_msg         char(500)

  define l_prshstdes   char(500)

  let l_sucesso = true
  let l_msg     = null

  case lr_parametro.tipo_operacao

     when "A" # --ALTERACAO

        whenever error continue

        execute pctc76m00003 using  lr_parametro.pstcoddig,
                                lr_parametro.socntzgrpcod_ant
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Delete pctc76m00003 " sleep 3
           let l_sucesso = false
        else
           if g_issk.dptsgl = "ct24hs" or
              g_issk.dptsgl = "tlprod" or
              g_issk.dptsgl = "dsvatd" then

              let l_msg = "Prestador........: ",
                           lr_parametro.pstcoddig using "<<<<&", " - ",
                           m_nomrazsoc clipped, ascii(13),
                           "Grupo de Natureza: ",
                           lr_parametro.socntzgrpcod_ant using "<<<<&", " - ",
                           lr_parametro.socntzgrpdes_ant

              call cts20g08("PRESTADOR RE", # NOME DO CADASTRO
                            "Exclusao",     # TIPO DA OPERACAO
                            "CTC76M00",     # NOME DO 4GL
                            g_issk.empcod,
                            g_issk.usrtip,
                            g_issk.funmat,
                            l_msg)


           end if
        end if

        whenever error continue

        execute pctc76m00002 using  lr_parametro.pstcoddig,
                                lr_parametro.socntzgrpcod,
                                g_issk.empcod, g_issk.funmat
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Insert pctc76m00002 " sleep 3
           let l_sucesso = false
        else
            if g_issk.dptsgl = "ct24hs" or
               g_issk.dptsgl = "tlprod" or
               g_issk.dptsgl = "dsvatd" then

               let l_msg = "Prestador........: ",
                            lr_parametro.pstcoddig using "<<<<&", " - ",
                            m_nomrazsoc clipped, ascii(13),
                            "Grupo de Natureza: ",
                            lr_parametro.socntzgrpcod using "<<<<&", " - ",
                            lr_parametro.socntzgrpdes

               call cts20g08("PRESTADOR RE", # NOME DO CADASTRO
                             "Inclusao",     # TIPO DA OPERACAO
                             "CTC76M00",     # NOME DO 4GL
                             g_issk.empcod,
                             g_issk.usrtip,
                             g_issk.funmat,
                             l_msg)
           end if
        end if

        let l_prshstdes = "Grupo de Natureza [",
            lr_parametro.socntzgrpcod_ant using "<<<<&", " - ",
            lr_parametro.socntzgrpdes_ant clipped, "] alterado para [",
            lr_parametro.socntzgrpcod using "<<<<&", " - ",
            lr_parametro.socntzgrpdes clipped, "]."

     when "I" # --INCLUSAO

        whenever error continue
                execute pctc76m00002 using lr_parametro.pstcoddig,
                                lr_parametro.socntzgrpcod,
                                g_issk.empcod, g_issk.funmat
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro INSERT pctc76m00002 " sleep 3
           let l_sucesso = false
        else
           if g_issk.dptsgl = "ct24hs" or
              g_issk.dptsgl = "tlprod" or
              g_issk.dptsgl = "dsvatd" then
              let l_msg = "Prestador........: ",
                           lr_parametro.pstcoddig using "<<<<&", " - ",
                           m_nomrazsoc clipped, ascii(13),
                           "Grupo de Natureza: ",
                           lr_parametro.socntzgrpcod using "<<<<&", " - ",
                           lr_parametro.socntzgrpdes

              call cts20g08("PRESTADOR RE", # NOME DO CADASTRO
                            "Inclusao",     # TIPO DA OPERACAO
                            "CTC76M00",     # NOME DO 4GL
                            g_issk.empcod,
                            g_issk.usrtip,
                            g_issk.funmat,
                            l_msg)
           end if

        end if

        let l_prshstdes = "Grupo de Natureza [",
            lr_parametro.socntzgrpcod using "<<<<&", " - ",
            lr_parametro.socntzgrpdes clipped, "] incluido!"

     when "E" # --EXCLUSAO

        whenever error continue
                execute pctc76m00003 using lr_parametro.pstcoddig,
                                lr_parametro.socntzgrpcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Delete pctc76m00003 " sleep 3
           let l_sucesso = false
        else

           if g_issk.dptsgl = "ct24hs" or
              g_issk.dptsgl = "tlprod" or
              g_issk.dptsgl = "dsvatd" then
              let l_msg = "Prestador........: ",
                           lr_parametro.pstcoddig using "<<<<&", " - ",
                           m_nomrazsoc clipped, ascii(13),
                           "Grupo de Natureza: ",
                           lr_parametro.socntzgrpcod using "<<<<&", " - ",
                           lr_parametro.socntzgrpdes

              call cts20g08("PRESTADOR RE", # NOME DO CADASTRO
                            "Exclusao",     # TIPO DA OPERACAO
                            "CTC76M00",     # NOME DO 4GL
                            g_issk.empcod,
                            g_issk.usrtip,
                            g_issk.funmat,
                            l_msg)
           end if

        end if

        let l_prshstdes = "Grupo de Natureza [",
            lr_parametro.socntzgrpcod using "<<<<&", " - ",
            lr_parametro.socntzgrpdes clipped, "] excluido!"

  end case

  call ctc00m02_grava_hist(lr_parametro.pstcoddig,
                           l_prshstdes,lr_parametro.tipo_operacao)

  return l_sucesso

end function

