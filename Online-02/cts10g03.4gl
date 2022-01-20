##############################################################################
# Nome do Modulo: CTS10G03                                         Akio      #
#                                                                  Ruiz      #
#                                                                  Wagner    #
# Funcoes genericas para "pegar" numeracao de ligacao e/ou servico Jun/2000  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 18/07/00    PSI 10865-0  Ruiz         Nova sequencia da numeracao do       #
#                                       servico.                             #
#----------------------------------------------------------------------------#
# 01/12/00                 Ruiz         Alteracao na rotina numero do servico#
#                                       tratar a quebra do ano p/ sinistro.  #
#----------------------------------------------------------------------------#
# 04/01/02                 Ruiz         Tratamento dos erros 243/245/246.    #
#----------------------------------------------------------------------------#
# 22/08/2005  PSI194654   Julianna,Meta Inclusao da funcao cts10g03_consiste #
#----------------------------------------------------------------------------#
# 22/08/2005  PSI194654   Julianna,Meta Inclusao da  chamada da funcao       #
#                                       cts25g00_dados_assunto               #
#----------------------------------------------------------------------------#
# 22/03/2006  Melhorias   Lucas Scheid  Ajustes gerais referentes a quebra   #
#                                       da numeracao do servico.             #
#----------------------------------------------------------------------------#
# 11/02/2005  Melhorias   Ruiz          Aceitar o parametro(tipo) "0" para   #
#                                       gerar somente o servico.             #
#----------------------------------------------------------------------------#
# 06/06/2008  Carla Rampazzo   Nao enviar email qdo for chamado pelo Portal  #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################


globals '/homedsa/projetos/geral/globals/glct.4gl'

  define m_prep  smallint

#-------------------------#
function cts10g03_prepare()
#-------------------------#

  define l_sql  char(300)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql  =  null

  let l_sql = ' select max(atdsrvnum) '
               ,' from datmservico '
              ,' where atddat = ? '

  prepare p_cts10g03_001 from l_sql
  declare c_cts10g03_001 cursor for p_cts10g03_001

  let l_sql = ' select max(sinvstnum) '
               ,' from datmavssin '
              ,' where sinvstano = ? '

  prepare p_cts10g03_002 from l_sql
  declare c_cts10g03_002 cursor for p_cts10g03_002

  let l_sql = ' select max(sinvstnum) '
               ,' from datmvstsin '
              ,' where sinvstano = ? '

  prepare p_cts10g03_003 from l_sql
  declare c_cts10g03_003 cursor for p_cts10g03_003

  let l_sql = ' select grlinf[01,06], ',
                     ' grlinf[07,08] ',
                ' from datkgeral ',
               ' where grlchv = "SINISTRO" ',
                 ' for update of grlinf '

  prepare p_cts10g03_004 from l_sql
  declare c_cts10g03_004 cursor with hold for p_cts10g03_004

  let l_sql = ' update ',
                     ' datkgeral ',
                ' set (grlinf[01,06], ',
                     ' grlinf[07,08], ',
                     ' atldat, ',
                     ' atlhor) = (?, ?, ?, ?) ',
               ' where grlchv = "SINISTRO" '

  prepare p_cts10g03_005 from l_sql

  let l_sql = ' select grlinf[01,10], ',
                     ' grlinf[11,12] ',
                ' from datkgeral ',
               ' where grlchv = "NUMSERVICO" ',
                 ' for update of grlinf '

  prepare p_cts10g03_006 from l_sql
  declare c_cts10g03_005 cursor with hold for p_cts10g03_006

  let l_sql = ' update ',
                     ' datkgeral ',
                ' set (grlinf[01,10], ',
                     ' grlinf[11,12], ',
                     ' atldat, ',
                     ' atlhor) = (?, ?, ?, ?) ',
               ' where grlchv = "NUMSERVICO" '

  prepare p_cts10g03_007 from l_sql

  let l_sql = ' select grlinf[01,10] ',
                ' from datkgeral ',
               ' where grlchv = "NUMULTLIG" ',
                 ' for update of grlinf '

  prepare p_cts10g03_008 from l_sql
  declare c_cts10g03_006 cursor with hold for p_cts10g03_008

  let l_sql = ' update ',
                     ' datkgeral ',
                ' set (grlinf, ',
                     ' atldat, ',
                     ' atlhor) = (?, ?, ?) ',
               ' where grlchv = "NUMULTLIG" '

  prepare p_cts10g03_009 from l_sql

  let m_prep = true

end function

#--------------------------------#
function cts10g03_numeracao(param)
#--------------------------------#

 define param     record    # GERA:
        tipo      smallint, # 0= numero de servico (11/02/2008)
                            # 1= numero da ligacao
                            # 2= numero ligacao + numero servico
        atdtip    like datmservico.atdtip
 end record

 define retorno   record
        lignum    like datmligacao.lignum   ,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        sqlcode   integer,
        msg       char(80)
 end record

 define ws        record
        cont      integer,
        hoje      char(10),
        anochv    char(02),
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        sqlcode   integer,
        msg       char(80)
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  retorno.*  to  null

 initialize  ws.*  to  null

 if m_prep is null or m_prep <> true then
   call cts10g03_prepare()
 end if

 initialize retorno, ws to null

 whenever error continue

 set lock mode to not wait

 while true
 #--------------------------#
 # Busca o numero da ligacao
 #--------------------------#
   if  param.tipo >= 1  then
       let ws.cont   = 0
       while true
         let ws.cont = ws.cont + 1
#        --------------------------
         call cts10g03_numligacao()
#        --------------------------
              returning ws.lignum ,
                        ws.sqlcode,
                        ws.msg
         if  ws.sqlcode <> 0  then
             if  ws.sqlcode = -243 or
                 ws.sqlcode = -244 or
                 ws.sqlcode = -245 or
                 ws.sqlcode = -246 then
                 if  ws.cont < 11  then
                     sleep 1
                     continue while
                 else
                     let retorno.msg = " Numero da ligacao travado!"
                 end if
             else
                 let retorno.msg = ws.msg
             end if
             let retorno.sqlcode = ws.sqlcode
         else
             let retorno.sqlcode = 0
             let retorno.lignum  = ws.lignum
         end if
         exit while
       end while
   end if

   if  retorno.sqlcode <> 0  then
       exit while
   end if

 #--------------------------#
 # Busca o numero do servico
 #--------------------------#
   if  param.tipo >= 2  or
       param.tipo  = 0  then

       # --BUSCA A DATA DO BANCO-- #
       select today into ws.hoje from dual

       let ws.anochv = ws.hoje[9,10]
       let ws.cont   = 0
       while true
          let ws.cont = ws.cont + 1
#         --------------------------------------
          call cts10g03_numservico(param.atdtip)
#         --------------------------------------
               returning ws.atdsrvnum,
                         ws.atdsrvano,
                         ws.sqlcode  ,
                         ws.msg
          if  ws.sqlcode <> 0  then
              if  ws.sqlcode = -243 or
                  ws.sqlcode = -244 or
                  ws.sqlcode = -245 or
                  ws.sqlcode = -246 then
                  if  ws.cont < 11  then
                      sleep 1
                      continue while
                  else
                      let retorno.sqlcode = ws.sqlcode
                      let retorno.msg     = " Numero do servico travado!"
                  end if
              else
                  let retorno.msg = ws.msg
              end if
              let retorno.sqlcode = ws.sqlcode
          else
              let retorno.sqlcode   = 0
              let retorno.atdsrvnum = ws.atdsrvnum
              let retorno.atdsrvano = ws.atdsrvano
          end if
          exit while
       end while
   end if
   exit while
 end while

 set lock mode to wait
 whenever error stop

 return retorno.*

end function

#---------------------------------#
function cts10g03_numservico(param)
#---------------------------------#

  define param     record
         atdtip    like datmservico.atdtip
  end record

  define retorno   record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         sqlcode   integer,
         msg       char(80)
  end record

  define ws        record
         atdsrvnum like datmservico.atdsrvnum,
         hoje      date,
         hora      datetime hour to minute,
         anodatk   char(02),
         anosist   char(10)
  end record

  define l_hora       datetime hour to second,
         l_data       date,
         l_de         char(30),
         l_para       char(30),
         l_cc         char(30),
         l_assunto    char(60),
         l_comando    char(700),
         l_msg        char(400)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  retorno.*  to  null

  initialize  ws.*  to  null

  if m_prep is null or m_prep <> true then
    call cts10g03_prepare()
  end if

  # ---> INICIALIZACAO DAS VARIAVEIS
  initialize retorno, ws to null

  # ---> OBTENCAO DO NUMERO DO SERVICO
  if param.atdtip = "5" then

     # ---> AVISO DE SINISTRO FURTO/ROUBO - CTS05M00
     # ---> MARCACAO VISTORIA SINISTRO    - CTS14M00

     open c_cts10g03_004
     whenever error continue
     fetch c_cts10g03_004 into ws.atdsrvnum, ws.anodatk
     whenever error stop

     if sqlca.sqlcode = 100 then
        let ws.atdsrvnum    = null
        let ws.anodatk      = null
        let retorno.sqlcode = sqlca.sqlcode
        let retorno.msg     = "Erro na busca do numero servico/Nao encontrou na datkgeral"
        close c_cts10g03_004
        return retorno.*
     end if

     if ws.atdsrvnum is null or
        ws.anodatk   is null then
        let ws.atdsrvnum    = null
        let ws.anodatk      = null
        let retorno.sqlcode = -243
        let retorno.msg     = "Erro na busca do numero servico/Parametros nulos"
        close c_cts10g03_004
        return retorno.*
     end if

     # ---> CHECA QUEBRA DO ANO

     # ---> BUSCA A DATA E HORA DO BANCO
     call cts40g03_data_hora_banco(2)
          returning ws.hoje, ws.hora

     let ws.anosist = ws.hoje

     if  ws.anosist[9,10] <> ws.anodatk then

         call cts10g03_consiste(param.atdtip,ws.hoje,ws.atdsrvnum,
                                ws.anodatk,ws.anosist[9,10])
              returning ws.atdsrvnum, ws.anodatk
         if ws.atdsrvnum = 0 or ws.atdsrvnum is null then
            let ws.atdsrvnum = 599999      --   PSI 189685 799999
            let ws.anodatk   = ws.anosist[9,10]
         end if
     end if

     let ws.atdsrvnum = ws.atdsrvnum + 1

     if  ws.atdsrvnum > 999999 then
         let ws.atdsrvnum    = null
         let ws.anodatk      = null
         let retorno.sqlcode = 999
         let retorno.msg     = " Faixa de numeracao de servico esgotada!"
         close c_cts10g03_004
         return retorno.*
     end if

     whenever error continue
     execute p_cts10g03_005 using ws.atdsrvnum, ws.anodatk, ws.hoje, ws.hora
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let retorno.sqlcode = sqlca.sqlcode
        let retorno.msg     = "Erro na atualizacao do numero do servico! "
        let ws.atdsrvnum    = null
        let ws.anodatk      = null
     end if

     close c_cts10g03_004

  else

     open c_cts10g03_005
     whenever error continue
     fetch c_cts10g03_005 into ws.atdsrvnum, ws.anodatk
     whenever error stop

     if sqlca.sqlcode = 100 then
        let ws.atdsrvnum    = null
        let ws.anodatk      = null
        let retorno.sqlcode = sqlca.sqlcode
        let retorno.msg     = " Erro na busca do numero servico !"
        close c_cts10g03_005
        return retorno.*
     end if

     if ws.atdsrvnum is null or
        ws.anodatk   is null then
        let ws.atdsrvnum    = null
        let ws.anodatk      = null
        let retorno.sqlcode = -243
        let retorno.msg     = "Erro na busca do numero servico/Parametros nulos"
        close c_cts10g03_005
        return retorno.*
     end if

     # ---> CHECA QUEBRA DO ANO

     # ---> BUSCA A DATA E HORA DO BANCO
     call cts40g03_data_hora_banco(2)
          returning ws.hoje, ws.hora

     let ws.anosist = ws.hoje

     if ws.anosist[9,10] <> ws.anodatk then

        call cts10g03_consiste(param.atdtip,ws.hoje,ws.atdsrvnum,
                               ws.anodatk,ws.anosist[9,10])
             returning ws.atdsrvnum, ws.anodatk

        if ws.atdsrvnum = 0 or ws.atdsrvnum is null then
           let ws.atdsrvnum = 0999999
           let ws.anodatk   = ws.anosist[9,10]
        end if
     end if

     let ws.atdsrvnum = ws.atdsrvnum + 1
     if  ws.atdsrvnum > 9999999 then
         let ws.atdsrvnum    = null
         let ws.anodatk      = null
         let retorno.sqlcode = 999
         let retorno.msg     = "*Faixa de numeracao de servico esgotada!"
         close c_cts10g03_005
         return retorno.*
     end if

     whenever error continue
     execute p_cts10g03_007 using ws.atdsrvnum, ws.anodatk, ws.hoje, ws.hora
     whenever error stop

     if  sqlca.sqlcode <> 0  then
         let ws.atdsrvnum    = null
         let ws.anodatk      = null
         let retorno.sqlcode = sqlca.sqlcode
         let retorno.msg     = " Erro na atualizacao do numero do servico!"
     end if

     close c_cts10g03_005

  end if

  let retorno.atdsrvnum = ws.atdsrvnum
  let retorno.atdsrvano = ws.anodatk

  return retorno.*

end function

#----------------------------#
function cts10g03_numligacao()
#----------------------------#

  define retorno record
         lignum  like datmligacao.lignum,
         sqlcode integer,
         msg     char(80)
  end record

  define ws      record
         lignum  like datmligacao.lignum,
         atldat  like datkgeral.atldat,
         atlhor  like datkgeral.atlhor
  end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  retorno.*  to  null

  initialize  ws.*  to  null

  call cts10g03_prepare()

  initialize retorno, ws to null

  open c_cts10g03_006
  whenever error continue
  fetch c_cts10g03_006 into ws.lignum
  whenever error stop

  if  sqlca.sqlcode <> 0  then
      let retorno.sqlcode = sqlca.sqlcode
      let retorno.msg     = " Erro na busca do numero da ligacao! "
      let retorno.lignum  = null
      return retorno.*
  end if

  let ws.lignum = ws.lignum + 1

  # ---> BUSCA A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning ws.atldat, ws.atlhor

  whenever error continue
  execute p_cts10g03_009 using ws.lignum, ws.atldat, ws.atlhor
  whenever error stop

  if  sqlca.sqlcode <> 0  then
      let retorno.sqlcode = sqlca.sqlcode
      let retorno.msg     = " Erro na atualizacao do numero da ligacao! "
      let ws.lignum       = null
  end if

  let retorno.lignum = ws.lignum

  close c_cts10g03_006

  return retorno.*

end function

#-------------------------------------#
function cts10g03_consiste (lr_param)
#-------------------------------------#

   define lr_param   record
          atdtip     like datmservico.atdtip
         ,data       date
         ,atdsrvnum  like datmservico.atdsrvnum
         ,anodatk    char(10)
         ,anosist    char(10)
   end record

   define lr_cts25g00 record
          resultado   smallint
         ,mensagem    char(60)
         ,prgcod      like datkassunto.prgcod
   end record

   define l_ano             datetime year to year
         ,l_anoc            char(4)
         ,l_atdsrvnum       like datmservico.atdsrvnum
         ,l_atdsrvnum_v10   like datmservico.atdsrvnum
         ,l_atdsrvnum_f10   like datmservico.atdsrvnum
         ,l_quebra_indevida smallint
         ,l_mensagem        char(100)
         ,l_assunto         char(030)
         ,l_cmd             char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_ano              = null
  let l_anoc             = null
  let l_atdsrvnum        = null
  let l_atdsrvnum_v10    = null
  let l_atdsrvnum_f10    = null
  let l_quebra_indevida  = null
  let l_mensagem         = null
  let l_assunto          = null
  let l_cmd              = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_cts25g00.*  to  null

   initialize lr_cts25g00 to null

   let l_atdsrvnum       = null
   let l_atdsrvnum_f10   = null
   let l_atdsrvnum_v10   = null
   let l_mensagem        = null
   let l_assunto         = null
   let l_ano             = lr_param.data
   let l_quebra_indevida = false

   if m_prep is null or m_prep <> true then
     call cts10g03_prepare()
   end if

   if lr_param.atdtip = 5 then

      #Obter o ultimo numero do aviso de sinistro referente ao F10
      open c_cts10g03_002 using l_ano
      fetch c_cts10g03_002 into l_atdsrvnum_f10

      if l_atdsrvnum_f10 is null then
         let l_atdsrvnum_f10  = 0
      end if

      #Obter o ultimo numero do aviso de sinistro referente ao V10 e B14
      open c_cts10g03_003 using l_ano
      fetch c_cts10g03_003 into l_atdsrvnum_v10

      if l_atdsrvnum_v10 is null then
         let l_atdsrvnum_v10  = 0
      end if

      if l_atdsrvnum_f10 > l_atdsrvnum_v10 then
         let l_atdsrvnum = l_atdsrvnum_f10
      else
         let l_atdsrvnum = l_atdsrvnum_v10
      end if

      #Se nao bateu  a ultima numeracao com o ultimo numero do servico
      if lr_param.atdsrvnum <> l_atdsrvnum and
         l_atdsrvnum        <> 0   then
         let l_quebra_indevida = true
      end if

   else
       #Obter o ultimo numero na base da Central
       open c_cts10g03_001 using lr_param.data
       fetch c_cts10g03_001 into l_atdsrvnum

       #Se achou o servico com o ano sistema na base da Central
       if lr_param.atdsrvnum <> l_atdsrvnum and
          l_atdsrvnum        <> 0 then
          let l_quebra_indevida = true
       end if
   end if

   ---> Envia email so se a chamada for pelo Informix
   if g_origem is null or
      g_origem = "IFX" then
      call cts10g03_envia_email(lr_param.anodatk,
                                lr_param.anosist,
                                lr_param.atdtip,
                                lr_param.atdsrvnum, # original
                                l_atdsrvnum,        # apurado
                                l_quebra_indevida)
   end if

   let l_anoc= l_ano
   let l_anoc= l_anoc[3,4]
   return l_atdsrvnum, l_anoc

end function

#-----------------------------------------#
function cts10g03_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         anodatk      char(20),
         anosist      char(20),
         atdtip       smallint,
         srvoriginal  like datmservico.atdsrvnum,
         srvapurado   like datmservico.atdsrvnum,
         tpquebra     smallint
  end record

  define l_hora       datetime hour to second,
         l_data       date,
         l_sitename   char(03),
         l_de         char(30),
         l_para       char(30),
         l_cc         char(30),
         l_assunto    char(60),
         l_comando    char(700),
         l_msg        char(400)

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
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_hora     = null
  let l_data     = null
  let l_de       = null
  let l_para     = null
  let l_cc       = null
  let l_assunto  = null
  let l_comando  = null
  let l_msg      = null
  let l_sitename = null

  let l_hora    = current
  let l_data    = today
  let l_de      = "Central-24-Horas"
  let l_para    = "Ruiz_Carlos@correioporto"

  select sitename
  into l_sitename
  from dual

  let l_assunto = "QUEBRA DA NUMERACAO DO SERVICO "
  if lr_parametro.tpquebra = true then
     let l_assunto = l_assunto clipped, "( indevida )"
  else
     let l_assunto = l_assunto clipped, "( normal )"
  end if

  if l_sitename = "u07" then
     let l_assunto = l_assunto clipped, " BASE DE TESTE"
  else
     let l_assunto = l_assunto clipped, " BASE DE PRODUCAO"
  end if

  let l_cc      = ""

  let l_comando = null

  let l_msg = "<html><body><font face = Calibri>",
              "QUEBRA DA NUMERACAO DO SERVICO. DATA - HORA: ",
               l_data, " - ", l_hora, "    ", "<br>",
              "CHAVE QUE OCASIONOU A QUEBRA...............: ",
              "ANO DATKGERAL: ", lr_parametro.anodatk clipped, " | ",
              "ANO SISTEMA: ",   lr_parametro.anosist clipped, " | ",
              "ATDTIP: ", lr_parametro.atdtip clipped, "<br>",
              "SERV.ORIGINAL: ", lr_parametro.srvoriginal clipped, " | ",
              "SERV.APURADO : ", lr_parametro.srvapurado clipped

   #PSI-2013-23297 - Inicio
   let l_mail.de = l_de
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = l_para
   let l_mail.cc = l_cc
   let l_mail.cco = ""
   let l_mail.assunto = l_assunto
   let l_mail.mensagem = l_msg
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "html"

   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro

   #PSI-2013-23297 - Fim
end function
