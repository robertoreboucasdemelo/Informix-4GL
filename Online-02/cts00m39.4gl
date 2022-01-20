#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS00M39                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  EXIBE OS PRESTADORES NAO CONECTADOS NO PORTAL DE NEGOCIOS. #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID/PRISCILA STAINGEL                             #
# LIBERACAO......: 25/04/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts00m39_prep smallint,
         m_contador      smallint,
         m_atualiza      smallint

  define am_prestador array[300] of record
         pstcoddig    like dpaksocor.pstcoddig,
         nomgrr       like dpaksocor.nomgrr,
         endcid       like dpaksocor.endcid,
         endufd       like dpaksocor.endufd,
         dddcod       like dpaksocor.dddcod,
         teltxt       like dpaksocor.teltxt
  end record

#-----------------#
function cts00m39()
#-----------------#

  define l_estado  like dpaksocor.endufd,
         l_cidade  like dpaksocor.endcid

  let m_atualiza = true

  open window w_cts00m39 at 4,2 with form "cts00m39"
     attribute(form line 1, message line last)


while true

  #abrir tela para filtro por estado cidade
  call cts00m39_filtro()
       returning l_estado, l_cidade

  if int_flag then
     exit while
  else
     let m_atualiza = true
  end if

  while m_atualiza = true

     #-----------------------------------------------------
     # FUNCAO UTILIZADA PARA CARREGAR OS REGISTROS NO ARRAY
     #-----------------------------------------------------
     call cts00m39_carga_array(l_estado, l_cidade)

     #----------------------
     # EXIBE O ARRAY EM TELA
     #----------------------
     call cts00m39_exibe_array()

  end while

end while

  close window w_cts00m39
  let int_flag = false

end function

#-----------------------------#
function cts00m39_carga_array(param)
#-----------------------------#

  define param record
     estado like dpaksocor.endufd,
     cidade like dpaksocor.endcid
  end record

  define l_sql char (300)

  let l_sql = " select pstcoddig, ",
                     " nomgrr, ",
                     " endcid, ",
                     " endufd, ",
                     " dddcod, ",
                     " teltxt ",
                " from dpaksocor ",
               " where intsrvrcbflg = '1' ",
                 " and prssitcod = 'A' "

  if param.estado is not null then
     let l_sql = l_sql clipped, " and endufd = ? "
  end if

  if param.cidade is not null then
     let l_sql = l_sql clipped, " and endcid = ? "
  end if

  let l_sql = l_sql clipped, " order by endufd, endcid, nomgrr "

  prepare p_cts00m39_001 from l_sql
  declare c_cts00m39_001 cursor for p_cts00m39_001

  initialize am_prestador to null

  let m_contador = 0
  display m_contador to total

  let m_contador  = 1

  message "Favor aguardar, pesquisando prestadores nao conectados..." attribute(reverse)

  set isolation to dirty read;

  if param.estado is not null and param.cidade is null then
     open c_cts00m39_001 using param.estado
  else
     if param.estado is not null and param.cidade is not null then
        open c_cts00m39_001 using param.estado,
                                param.cidade
     else
        open c_cts00m39_001
     end if
  end if

  foreach c_cts00m39_001 into am_prestador[m_contador].pstcoddig,
                            am_prestador[m_contador].nomgrr,
                            am_prestador[m_contador].endcid,
                            am_prestador[m_contador].endufd,
                            am_prestador[m_contador].dddcod,
                            am_prestador[m_contador].teltxt

     #----------------------------------------------------------
     # VERIFICA SE O PRESTADOR ESTA LOGADO NO PORTAL DE NEGOCIOS
     #----------------------------------------------------------
     if fissc101_prestador_sessao_ativa(am_prestador[m_contador].pstcoddig, "PSRONLINE") then
        #-----------------------------------
        # DESPREZA OS PRESTADORES CONECTADOS
        #-----------------------------------
        continue foreach
     else
        if fissc101_prestador_sessao_ativa(am_prestador[m_contador].pstcoddig, "AGTONLINE") then
           #-----------------------------------
           # DESPREZA OS PRESTADORES CONECTADOS
           #-----------------------------------
           continue foreach
        end if
     end if

     let m_contador = (m_contador + 1)

     if m_contador > 300 then
        error "A quantidade de registros superou o limite do array. CTS00M39.4GL " sleep 4
        exit foreach
     end if

  end foreach
  close c_cts00m39_001

  let m_contador = (m_contador - 1)

  message " "

  display m_contador to total

end function

#-----------------------------#
function cts00m39_exibe_array()
#-----------------------------#

  define l_pos_corrente smallint,
         l_pos_tela     smallint

  let m_atualiza     = false
  let l_pos_corrente = null
  let l_pos_tela     = null

  if m_contador = 0 then
     error "Todos os prestadores estao conectados no Portal de Negocios!" sleep 3
  else

     call set_count(m_contador)

     display array am_prestador to s_cts00m39.*

        on key(f6)
           clear form
           let m_atualiza = true
           exit display

        on key(f5)
           call ctc60m01()

        on key(f7)
           let l_pos_corrente = arr_curr()
           let l_pos_tela     = scr_line()
           display am_prestador[l_pos_corrente].* to s_cts00m39[l_pos_tela].* attribute(reverse)
           call cts00m39_exibe_fone(am_prestador[l_pos_corrente].teltxt, l_pos_tela)
           display am_prestador[l_pos_corrente].* to s_cts00m39[l_pos_tela].*

        on key(f17,control-c,interrupt)
           initialize am_prestador to null
           exit display

     end display

  end if

end function

#------------------------------------------------#
function cts00m39_exibe_fone(l_teltxt, l_pos_tela)
#------------------------------------------------#

  define l_teltxt   like dpaksocor.teltxt,
         l_pos_tela smallint,
         l_espera   char(01)

  let l_espera   = null
  let l_pos_tela = (l_pos_tela + 6)

  open window w_cts00m39b at l_pos_tela, 38 with 1 rows, 41 columns
    attribute(border)

  prompt l_teltxt attribute(reverse) for l_espera

  close window w_cts00m39b
  let int_flag = false

end function

#------------------------------------------------#
function cts00m39_filtro()
#------------------------------------------------#
  define d_cts00m39   record
       estado like dpaksocor.endufd,
       cidade like dpaksocor.endcid
  end record

  initialize d_cts00m39.* to null
  let int_flag = false

  open window w_cts00m39a at 11,15 with form "cts00m39a"
     attribute(border)
  input by name d_cts00m39.estado,
                d_cts00m39.cidade
                without defaults

       before field estado
           display by name d_cts00m39.estado attribute (reverse)

       after field estado
           display by name d_cts00m39.estado

       before field cidade
           display by name d_cts00m39.cidade attribute (reverse)

       after field cidade
           display by name d_cts00m39.cidade

       on key (interrupt)
           initialize d_cts00m39.* to null
           let int_flag = true
           exit input

  end input

  close window w_cts00m39a
  return d_cts00m39.estado,
         d_cts00m39.cidade

end function
