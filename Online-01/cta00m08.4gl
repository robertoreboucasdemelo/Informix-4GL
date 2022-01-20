#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: cta00m08                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: Verifica se a contingencia esta ativa ou nao               #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 14/02/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- --------------------------------------#
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------- Devolve contingencia ativa/inativa ----------------------------------#
function cta00m08_ver_contingencia(l_nivel_msg)
#-----------------------------------------------------------------------------#

   define l_nivel_msg    smallint,
          l_grlinf_cont  like datkgeral.grlinf,
          l_grlinf_carga like datkgeral.grlinf,
          l_conf         char(1),
          l_msg          char(40),
          l_res          smallint

   let l_grlinf_cont  = null
   let l_grlinf_carga = null
   let l_conf         = null
   let l_res          = null
   let l_msg          = null

   if g_documento.atdsrvorg = 15 then
      return false
   end if

   call cts40g23_busca_chv("PSOCONTINGENCIA")
        returning l_grlinf_cont
   ########## Para tratar no atendimento e solicitar senha para forcar a entrada
   if l_nivel_msg = 1 then

      if l_grlinf_cont = "INATIVA" then
         let g_senha_cnt = null
         return false
      end if

      if g_senha_cnt is null then

         call cts08g01( "A","S",
                        "Central 24h operando com a contingencia.",
                        "Acesse o sistema CENTRAL30HS!",
                        "Deseja forcar a utilizacao do Informix ?","")
              returning l_conf
          if l_conf = "N" then
             return true
          end if
       else
          return false
       end if

       call cta00m08_senha() returning l_res

       if l_res = false then
          return true
       else
          return false
       end if

   end if

   ######## Para informar que as informacoes nao foram registras na contingencia
   if l_nivel_msg = 2 then

      if l_grlinf_cont = "INATIVA" then
         let g_senha_cnt = null
         return false
      end if

      if g_documento.atdsrvorg = 1 or g_documento.atdsrvorg = 2 or
         g_documento.atdsrvorg = 3 or g_documento.atdsrvorg = 4 or
         g_documento.atdsrvorg = 5 or g_documento.atdsrvorg = 6 or
         g_documento.atdsrvorg = 7 or g_documento.atdsrvorg = 9 or
         g_documento.atdsrvorg = 12 or g_documento.atdsrvorg = 13 or
         g_documento.c24astcod = "V12" or g_documento.c24astcod = "F10" then
         let l_msg =  "Registre este servico no CENTRAL 30HS!"
      else
         let l_msg =  null
      end if

      call cts08g03( "A","N", "", "Contingencia Ativa.", l_msg, "", 5)
           returning l_conf
      return true
   end if

   ########## Para verificar no acionamento manual
   if l_nivel_msg = 3 then

      call cts40g23_busca_chv("PSOCNTCARGA")
           returning l_grlinf_carga

      if l_grlinf_cont = "ATIVA" then
         call cts08g03( "A","N",  "",
                       "Contingencia Ativa.",
                       "Este servico deve ser acionado","no CENTRAL 30HS!",5)
              returning l_conf
         return true
      else
         let g_senha_cnt = null

         if l_grlinf_carga <> "PROCESSADA" then
            call cts08g03( "A","N",  "",
                          "Carga da contingencia nao realizada !",
                          "", "AVISE A COORDENACAO.",5)
                returning l_conf
            return true
         end if
      end if
   end if

   ########## Para verificar a carga no acionamento automatico/batchs
   if l_nivel_msg = 4 then

      if l_grlinf_cont = "INATIVA" then
         let g_senha_cnt = null

         call cts40g23_busca_chv("PSOCNTCARGA")
              returning l_grlinf_carga

         if l_grlinf_carga = "PROCESSADA" then
            return false
         else
            return true
         end if
      else
         return true
      end if

   end if

   return false

end function

#------------ Solicita e valida a senha para forcar Informix -----------------#
function cta00m08_senha()
#-----------------------------------------------------------------------------#

    define l_senha        like datkgeral.grlinf,
           l_grlinf_senha like datkgeral.grlinf

    let l_senha        = null
    let l_grlinf_senha = null
    let int_flag       = false

    call cts40g23_busca_chv("PSOCNTSENHA")
         returning l_grlinf_senha

    open window t_cta00m08 at 10,21
         with form "cta00m08" attribute(form line 1, border)

    input l_senha without defaults from senha

          before field senha
                 display l_senha to senha attribute (reverse)

          after field senha
                 display l_senha to senha

                 if l_senha is null or l_senha <> l_grlinf_senha then
                    error "Senha nao confere"
                    let l_senha = null
                    next field senha
                 else
                    let g_senha_cnt = l_senha
                 end if
    end input

    close window t_cta00m08

    if int_flag or l_senha is null or
       l_senha <> l_grlinf_senha then
       return false
    else
       return true
    end if
end function
