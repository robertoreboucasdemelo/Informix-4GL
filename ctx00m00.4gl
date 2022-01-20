#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: CTX00M00                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: ENTRADA DE TEXTO PADRAO                                    #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 05/05/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

#--------------------------------------#
  function ctx00m00_texto_padrao(param)
#--------------------------------------#
     
     define param record
          cab   char(050),
          texto char(200)
     end record
     
     define ws  record
          texto char(200)
     end record
     
     define a_ctx00m00 array[4] of record
          texto      char (50)
     end record
     
     define arr_aux    smallint
     define scr_aux    smallint

     initialize ws.*       to null
     initialize a_ctx00m00 to null

     if param.cab is null then
        let param.cab = "                 INFORME O MOTIVO"
     end if

     let a_ctx00m00[1].texto = param.texto[001,050]
     let a_ctx00m00[2].texto = param.texto[051,100]
     let a_ctx00m00[3].texto = param.texto[101,150]
     let a_ctx00m00[4].texto = param.texto[151,200]

     open window w_ctx00m00 at  11,15 with form "ctx00m00"
                attribute(border,form line first)

     display by name param.cab

     let int_flag = false
     let arr_aux = 5
     call set_count(arr_aux - 1)

     input array a_ctx00m00 without defaults from s_ctx00m00.*

        before row
           let arr_aux = arr_curr()
           let scr_aux = scr_line()

        before field texto
           display a_ctx00m00[arr_aux].texto to
                   s_ctx00m00[scr_aux].texto attribute (reverse)

        after field texto
           display a_ctx00m00[arr_aux].texto to
                   s_ctx00m00[scr_aux].texto

        on key (control-c)
           exit input

        after row
           if arr_aux = 4 then
              if fgl_lastkey() <> fgl_keyval ("up")     and
                 fgl_lastkey() <> fgl_keyval ("left")   then
                 exit input
              end if
           end if
     end input

     let ws.texto = a_ctx00m00[1].texto, a_ctx00m00[2].texto,
                    a_ctx00m00[3].texto, a_ctx00m00[4].texto
                          
     let int_flag = false

     close window w_ctx00m00
     return ws.texto

  end function