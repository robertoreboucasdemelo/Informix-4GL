#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G03                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  CALCULA DISTANCIA ENTRE DOIS LOGRADOUROS - ROTERIZADO.     #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 23/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/03/2010 Adriano Santos  PSI252891  Inclusao do padrao idx 4 e 5          #
#-----------------------------------------------------------------------------#

database porto

#-----------------------------#
function ctx25g03(lr_parametro)
#-----------------------------#

  define lr_parametro record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom
  end record

  define lr_origem    record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lclbrrnom    like datmlcl.lclbrrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define lr_destino   record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lclbrrnom    like datmlcl.lclbrrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define l_rota_final   char(32000),
         l_dist_total   decimal(8,3),
         l_temp_total   decimal(6,1),
         l_espera       char(01),
         l_tipo_rota    char(07)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let  l_rota_final  = null
  let  l_dist_total  = null
  let  l_temp_total  = null
  let  l_espera      = null
  let  l_tipo_rota   = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_origem.*  to  null

  initialize  lr_destino.*  to  null

  # -> BUSCA O TIPO DE ROTA
  let l_tipo_rota = null
  let l_tipo_rota = ctx25g05_tipo_rota()

  # -> BUSCA O LOCAL DE ORIGEM
  call ctx25g05("C",
                "          INFORME O LOGRADOURO DE ORIGEM PARA CALCULO DE DISTANCIA          ",
                lr_parametro.ufdcod,
                lr_parametro.cidnom,
                lr_parametro.lgdtip,
                lr_parametro.lgdnom,
                lr_parametro.lgdnum,
                lr_parametro.brrnom,
                "",
                "",
                "",
                "",
                "",
                "")

       returning lr_origem.lgdtip,
                 lr_origem.lgdnom,
                 lr_origem.lgdnum,
                 lr_origem.brrnom,
                 lr_origem.lclbrrnom,
                 lr_origem.lgdcep,
                 lr_origem.lgdcepcmp,
                 lr_origem.lclltt,
                 lr_origem.lcllgt,
                 lr_origem.c24lclpdrcod,
                 lr_origem.ufdcod,
                 lr_origem.cidnom

  if lr_origem.lclltt is not null and
     lr_origem.lcllgt is not null then

     # -> BUSCA O LOCAL DE DESTINO
     call ctx25g05("C",
                   "          INFORME O LOGRADOURO DE DESTINO PARA CALCULO DE DISTANCIA         ",
                   lr_parametro.ufdcod,
                   lr_parametro.cidnom,
                   lr_parametro.lgdtip,
                   lr_parametro.lgdnom,
                   lr_parametro.lgdnum,
                   lr_parametro.brrnom,
                   "",
                   "",
                   "",
                   "",
                   "",
                   "")

          returning lr_destino.lgdtip,
                    lr_destino.lgdnom,
                    lr_destino.lgdnum,
                    lr_destino.brrnom,
                    lr_destino.lclbrrnom,
                    lr_destino.lgdcep,
                    lr_destino.lgdcepcmp,
                    lr_destino.lclltt,
                    lr_destino.lcllgt,
                    lr_destino.c24lclpdrcod,
                    lr_destino.ufdcod,
                    lr_destino.cidnom
  end if

  if lr_origem.lclltt  is not null and
     lr_origem.lcllgt  is not null and
     lr_destino.lclltt is not null and
     lr_destino.lcllgt is not null then
     # -> EXIBE OS VALORES NA TELA
     open window w_ctx25g03 at  08,04 with form "ctx25g03"
        attribute(form line first, border)

     message " Favor aguardar, calculando distancia..." attribute(reverse)

     if (lr_destino.c24lclpdrcod = 3 or
         lr_destino.c24lclpdrcod = 4 or  # PSI 252891
         lr_destino.c24lclpdrcod = 5) and
        (lr_origem.c24lclpdrcod  = 3 or
         lr_origem.c24lclpdrcod  = 4 or  # PSI 252891
         lr_origem.c24lclpdrcod  = 5)  and
         (lr_origem.ufdcod = "SP" or
          lr_origem.ufdcod = "RJ" or
          lr_origem.ufdcod = "PR") and
         (lr_destino.ufdcod = "SP" or
          lr_destino.ufdcod = "RJ" or
          lr_destino.ufdcod = "PR") then

        # -> CHAMA A FUNCAO PARA ROTERIZAR OS DOIS LOGRADOUROS(ORIGEM E DESTINO)
        call ctx25g02(lr_origem.lclltt,
                      lr_origem.lcllgt,
                      lr_destino.lclltt,
                      lr_destino.lcllgt,
                      l_tipo_rota,
                      1)

             returning l_dist_total,
                       l_temp_total,
                       l_rota_final

        if l_temp_total < 30 then
           let l_temp_total = l_temp_total * 2

           if l_temp_total > 60 then
              let l_temp_total = 60
           end if
        end if
        let l_temp_total = l_temp_total + 3

     else
        # -> CHAMA A FUNCAO PARA CALCULO DE DISTANCIA EM LINHA RETA
        call cts18g00(lr_origem.lclltt,
                      lr_origem.lcllgt,
                      lr_destino.lclltt,
                      lr_destino.lcllgt)
             returning l_dist_total
        let l_temp_total = 0
        let l_rota_final = "SEM ROTA"
     end if

     call cts06g10_monta_brr_subbrr(lr_origem.brrnom,
                                    lr_origem.lclbrrnom)
          returning lr_origem.brrnom

     call cts06g10_monta_brr_subbrr(lr_destino.brrnom,
                                    lr_destino.lclbrrnom)
          returning lr_destino.brrnom

     # -> EXIBE DADOS DO ENDERECO DE ORIGEM
     display lr_origem.ufdcod to ufdcod_origem
     display lr_origem.cidnom to cidnom_origem
     display lr_origem.lgdnom to lgdnom_origem
     display lr_origem.brrnom to brrnom_origem
     display lr_origem.lgdnum to lgdnum_origem

     # -> EXIBE DADOS DO ENDERECO DE DESTINO
     display lr_destino.ufdcod to ufdcod_destino
     display lr_destino.cidnom to cidnom_destino
     display lr_destino.lgdnom to lgdnom_destino
     display lr_destino.brrnom to brrnom_destino
     display lr_destino.lgdnum to lgdnum_destino

     # -> EXIBE DISTANCIA E TEMPO
     display l_dist_total to distancia
     display l_temp_total to tempo

     input l_espera without defaults from espera

        after field espera
           next field espera

        on key (f8)
           call ctx25g03_percurso(l_rota_final)

        on key (f17, control-c, interrupt)
           exit input

     end input

     close window w_ctx25g03
     let int_flag = false

  end if

end function

#---------------------------------#
function ctx25g03_percurso(l_texto)
#---------------------------------#

  define l_texto char(32000)

  define al_array array[500] of char(80)

  define l_i         smallint,
         l_ult       smallint,
         l_aux_array smallint

  let l_ult       = 1
  let l_aux_array = 0
  let l_i         = null

  message "Favor aguardar, montando o percurso..." attribute(reverse)

  for l_i = 1 to length(l_texto)
     if l_texto[l_i] = ";" then
        let l_aux_array = l_aux_array + 1

        if l_aux_array > 500 then
           error "A quantiade de registros superou o limite do array. Modulo CTX25G03.4GL" sleep 4
           exit for
        end if

        let al_array[l_aux_array] = ctx25g03_rem_acento(l_texto[l_ult, l_i -1])
        let l_ult                 = l_i + 1
     end if
  end for

  message " "

  open window w_ctx25g03a at  07,02 with form "ctx25g03a"
       attribute(form line first, border)

  call set_count(l_aux_array)

  display array al_array to s_ctx25g03a.*

     on key (f17,control-c,interrupt)
        exit display

  end display

  close window w_ctx25g03a
  let int_flag = false

end function

#-----------------------------------#
function ctx25g03_rem_acento(l_frase)
#-----------------------------------#

  define l_frase char(80),
         l_i     smallint

  let l_i = null

  for l_i = 1 to length(l_frase)

     case l_frase[l_i]

        when("à") let l_frase[l_i] = "a"
        when("é") let l_frase[l_i] = "e"
        when("ç") let l_frase[l_i] = "c"
        when("Ã") let l_frase[l_i] = "a"
        when("á") let l_frase[l_i] = "a"
        when("¡") let l_frase[l_i] = ""

     end case

  end for

  return l_frase

end function
