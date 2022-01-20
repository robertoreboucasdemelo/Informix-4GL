#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G25                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: ACIONAMENTO AUTOMATICO DOS SERVICOS RE.                    #
# ........................................................................... #
# DESENVOLVIMENTO: LIGIA MATTGE                                               #
# LIBERACAO......:                                                            #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail   #
###############################################################################

database porto

#-------------------------#
function cts40g25_prepare()
#-------------------------#

  define l_sql char(600)

  ############ ligia em 20/03/2007
  ############ sqls apenas para detectar um problema em producao ##############

   ##obter coordenada do servico
   let l_sql = ' select lclltt,lcllgt, c24lclpdrcod ',
               ' from datmlcl ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and c24endtip = 1 '

  prepare pcts40g25001 from l_sql
  declare ccts40g25001 cursor for pcts40g25001

   ##obter viatura acionado
   let l_sql = ' select pstcoddig, socvclcod, srrcoddig ',
               ' from datmsrvacp ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and atdetpcod = 4 '

  prepare pcts40g25002 from l_sql
  declare ccts40g25002 cursor for pcts40g25002

   ##obter coordenada da viatura no servico
   let l_sql = ' select srrltt, srrlgt ',
                ' from datmservico ',
                ' where atdsrvnum = ? ',
                  ' and atdsrvano = ? '

  prepare pcts40g25003 from l_sql
  declare ccts40g25003 cursor for pcts40g25003

end function

function cts40g25_ac(l_atdsrvnum, l_atdsrvano, l_prog)

   define l_atdsrvnum like datmservico.atdsrvnum,
          l_atdsrvano like datmservico.atdsrvano,
          l_cmd       char(1000),
          l_lclltt1   like datmlcl.lclltt,
          l_lcllgt1   like datmlcl.lcllgt,
          l_c24lclpdrcod  like datmlcl.c24lclpdrcod,
          l_lclltt2   like datmlcl.lclltt,
          l_lcllgt2   like datmlcl.lcllgt,
          l_pstcoddig like datmsrvacp.pstcoddig,
          l_socvclcod like datmsrvacp.socvclcod,
          l_srrcoddig like datmsrvacp.srrcoddig,
          l_dist      decimal(8,4),
          l_status    smallint,
          l_prog      char(30)

   define l_mens       record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(100)
   end record
   define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
   end  record
   define l_coderro  smallint
   define msg_erro char(500)

   return ############# A pedido da Sueli em 01/07/08 - Ligia ############

   initialize l_mens to null
   let l_cmd = null
   let l_lclltt1   = null
   let l_lcllgt1   = null
   let l_c24lclpdrcod  = null
   let l_lclltt2   = null
   let l_lcllgt2   = null
   let l_pstcoddig = null
   let l_socvclcod = null
   let l_srrcoddig = null
   let l_dist      = null
   let l_status    = null

   call cts40g25_prepare()

   ##obter coordenada do servico
   open ccts40g25001 using l_atdsrvnum, l_atdsrvano
   fetch ccts40g25001 into l_lclltt1, l_lcllgt1, l_c24lclpdrcod
   close ccts40g25001

   ##obter viatura acionado
   open ccts40g25002 using l_atdsrvnum, l_atdsrvano
   fetch ccts40g25002 into  l_pstcoddig, l_socvclcod, l_srrcoddig
   close ccts40g25002

   ##obter coordenada da viatura no servico
   open ccts40g25003 using l_atdsrvnum, l_atdsrvano
   fetch ccts40g25003 into  l_lclltt2, l_lcllgt2
   close ccts40g25003

   ## calcular distancia
   let l_dist = 0
   call cts18g00(l_lclltt1, l_lcllgt1, l_lclltt2, l_lcllgt2)
        returning l_dist

   ## ser for > 50, enviar email para mim.
   if l_dist > 50 then

      let l_mens.msg = "Servico : ",l_atdsrvnum,"/" , l_atdsrvano, "/",
                       "Coord: ",   l_lclltt1,"/", l_lcllgt1,"/",
                                    l_c24lclpdrcod,"/",
                       "Prestador: ", l_pstcoddig,"/", l_socvclcod,"/",
                                      l_srrcoddig,"/",
                       "Coord: ",     l_lclltt2, "/",l_lcllgt2, "/",
                       "DIST CALC: ", l_dist

      let l_mens.de  = l_prog
      let l_mens.subject = "Acionamento c/problemas dist.calc."
      let l_mens.para = "Mattge_Ligia@correioporto"
      #PSI-2013-23297 - Inicio
      let l_mail.de = l_mens.de
      #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
      let l_mail.para =  l_mens.para
      let l_mail.cc = ""
      let l_mail.cco = ""
      let l_mail.assunto = l_mens.subject
      let l_mail.mensagem = l_mens.msg
      let l_mail.id_remetente = "CT24H"
      let l_mail.tipo = "text"

      call figrc009_mail_send1 (l_mail.*)
       returning l_coderro,msg_erro
      #PSI-2013-23297 - Fim

   end if

end function

function cts40g25_srv_preso(lr_param)

   define lr_param      record
          atdsrvnum     like datmservico.atdsrvnum,
          atdsrvano     like datmservico.atdsrvano,
          c24opemat     like datmservico.c24opemat,
          atdfnlflg     like datmservico.atdfnlflg,
          acnnaomtv     like datmservico.acnnaomtv,
          atdsrvorg     like datmservico.atdsrvorg,
          prog          char(30)
          end record

   define l_atdlibhor     like datmservico.atdlibhor,
          l_atdlibdat     like datmservico.atdlibdat,
          l_atddatprg     like datmservico.atddatprg,
          l_atdhorprg     like datmservico.atdhorprg,
          l_acnnaomtv     like datmservico.acnnaomtv,
          l_espera        interval hour(6) to minute,
          l_calc1         interval hour(6) to minute,
          l_calc2         interval hour(6) to minute,
          l_tempoc        char(5),
          l_limite_espera interval hour(6) to minute,
          l_atdfnlflg     like datmservico.atdfnlflg,
          l_c24funmat     like datmligacao.c24funmat,
          l_resultado     integer,
          l_msg           char(40),
          l_nome          char(60),
          l_cmd           char(1000),
          l_data_atual    date,
          l_hora_atual    datetime hour to minute

   define mr_cts40g00_pa record
         cidacndst      like datracncid.cidacndst,
         acnlmttmp      like datkatmacnprt.acnlmttmp,
         acntntlmtqtd   like datkatmacnprt.acntntlmtqtd,
         netacnflg      like datkatmacnprt.netacnflg,
         atmacnprtcod   like datkatmacnprt.atmacnprtcod
         end record

   define l_mens     record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(500)
   end record
   define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
   end  record
   define l_coderro  smallint
   define msg_erro char(500)

   let l_atdlibhor     = null
   let l_atdlibdat     = null
   let l_atddatprg     = null
   let l_atdhorprg     = null
   let l_acnnaomtv     = null
   let l_espera        = null
   let l_calc1         = null
   let l_calc2         = null
   let l_tempoc        = null
   let l_limite_espera = null
   let l_atdfnlflg     = null
   let l_resultado     = null
   let l_msg           = null
   let l_nome          = null
   let l_cmd           = null
   let l_c24funmat     = null
   let l_data_atual    = null
   let l_hora_atual    = null

   initialize l_mens.* to null
   initialize mr_cts40g00_pa.* to null

   #########################################################################
   ## COM ATDFNLFLG =N ESTA NO RADIO.
   ## COM ATDFNLFLG =S ESTA NO PROCESSSO DE ACIONAMENTO AUTOMATICO E PRECISA
   ## VERIFICAR SE ESTA PRESO
   #########################################################################

      ## presos no acionamento automatico, calcula o tempo que esta preso
      call cts10g06_dados_servicos(9, lr_param.atdsrvnum, lr_param.atdsrvano)
           returning l_resultado,
                     l_msg,
                     l_atdlibhor,
                     l_atdlibdat,
                     l_atddatprg,
                     l_atdhorprg,
                     l_acnnaomtv,
                     l_atdfnlflg

      if l_atddatprg is null then

         ####### SERVICO IMEDIATO TEM 05 MIN P/ACIONAR. ACIMA DISSO ESTA PRESO
         ## tolerancia de 2 minutos
         let l_limite_espera = "0:07"
         let l_espera = cts40g03_espera(l_atdlibdat, l_atdlibhor)
      else

         ####### SERVICO PROGRAMADO TEM 20 MIN P/ACIONAR. ACIMA DISSO ESTA PRESO
         ## tolerancia de 2 minutos
         let l_limite_espera = "0:22"

         call cts40g00_obter_parametro(lr_param.atdsrvorg)
              returning l_resultado, l_msg,
                        mr_cts40g00_pa.acnlmttmp,
                        mr_cts40g00_pa.acntntlmtqtd,
                        mr_cts40g00_pa.netacnflg,
                        mr_cts40g00_pa.atmacnprtcod

         let l_tempoc = mr_cts40g00_pa.acnlmttmp
         let l_calc2 = l_tempoc

         ## para servicos programados com menos tempo do que o tempo p/acionar
         if l_atdlibdat = l_atddatprg then
            let l_calc1 = l_atdhorprg - l_atdlibhor
         else
            let l_calc1 = "24:00"  ## 28/11/07
         end if

         if l_calc1 > "00:00" and l_calc1 <  l_calc2 then
            let l_calc1 = cts40g03_espera(l_atdlibdat, l_atdlibhor)
         else
            let l_calc1 = cts40g03_espera(l_atddatprg, l_atdhorprg)
         end if

         if l_calc1 > l_calc2 then
            let l_espera = l_calc1 - l_calc2
         else
            let l_espera = l_calc2 + l_calc1
         end if

      end if

      if l_espera >= l_limite_espera then

         let l_nome = null

         if lr_param.c24opemat <> 999999 then

            call ctd06g00_pri_ligacao(2,lr_param.atdsrvnum,
                                        lr_param.atdsrvano)
                 returning l_resultado, l_msg, l_c24funmat

            ## se for operador do radio, esta acionando o srv.
            if lr_param.c24opemat <> l_c24funmat then
               return
            end if

            call cty08g00_nome_func(1,lr_param.c24opemat, "F")
                 returning l_resultado, l_msg, l_nome
         else
            let l_nome = "PROCESSO AUTOMATICO"
         end if

         call cts40g03_data_hora_banco(2)
              returning l_data_atual,
                        l_hora_atual

         ## desbloqueia servico e envia ao radio
         update datmservico
            set (acnsttflg, c24opemat) = ('N','')
          where atdsrvnum = lr_param.atdsrvnum
            and atdsrvano = lr_param.atdsrvano

         ## Substituido por update direto para manter o servico no acionamento automatico
         ##let l_resultado = cts40g06_env_radio(lr_param.atdsrvnum,
         ##                                     lr_param.atdsrvano)

         if sqlca.sqlcode <> 0 then
            let l_mens.msg = "Erro no desbloqueio do ",
                             "servico : ",lr_param.atdsrvnum,"/" ,
                                         lr_param.atdsrvano using "&&", "  ",
                             "Tempo preso : ", l_espera,"  " ,
                             "com : ",lr_param.c24opemat,"-" ,
                                      l_nome clipped,
                             " as ", l_hora_atual

            let l_mens.subject = "Servicos Presos"
            let l_mens.de  = lr_param.prog
            let l_mens.para = 'Castro_Cesar@correioporto,Alves_Sueli@correioporto,Ct24hs_Genivaldo@correioporto,Ct24hs_Isabel@correioporto,'
            let l_mens.para = l_mens.para clipped, 'Ct24hs_CarlosRoberto@correioporto,Ct24hs_Roberto@correioporto,Ct24hs_Doroti@correioporto,Ct24hs_Jorge@correioporto,Ct24hs_Valdir@correioporto'
            #PSI-2013-23297 - Inicio
            let l_mail.de = l_mens.de
            #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
            let l_mail.para =  l_mens.para
            let l_mail.cc = ""
            let l_mail.cco = ""
            let l_mail.assunto = l_mens.subject
            let l_mail.mensagem = l_mens.msg
            let l_mail.id_remetente = "CT24H"
            let l_mail.tipo = "text"
            call figrc009_mail_send1 (l_mail.*)
             returning l_coderro,msg_erro
            #PSI-2013-23297 - Fim

         else
           call cts00g07_apos_servdesbloqueia(lr_param.atdsrvnum,lr_param.atdsrvano)
         end if
      end if

end function
