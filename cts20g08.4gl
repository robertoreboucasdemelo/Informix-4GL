#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIEMNTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS20G08                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  ENVIA E-MAIL SOBRE ALTERACOES NO CADASTRO DO PORTO SOCORRO.#
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 06/04/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 26/05/2014 Rodolfo Massini ---------- Alteracao na forma de envio de        #
#                                       e-mail (SENDMAIL para FIGRC009)       # 
###############################################################################

database porto

  define m_cts20g08_prep smallint

#-------------------------#
function cts20g08_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select relpamtxt ",
                " from igbmparam ",
               " where relsgl = ? "

  prepare pcts20g08001 from l_sql
  declare ccts20g08001 cursor for pcts20g08001

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where funmat = ? ",
                 " and empcod = ? ",
                 " and usrtip = ? "

  prepare pcts20g08002 from l_sql
  declare ccts20g08002 cursor for pcts20g08002

  let m_cts20g08_prep = true

end function

#-----------------------------#
function cts20g08(lr_parametro)
#-----------------------------#

  define lr_parametro    record
         nome_cad        char(50),  # NOME DO CADASTRO QUE FOI ALTERADO
         tipo_oper       char(50),  # TIPO DE OPERACAO:INCLUSAO, ALTERACAO, EXCLUSAO
         nome_4gl        char(08),  # NOME DO 4GL ONDE ESTA O CADASTRO
         empcod          like isskfunc.empcod,
         usrtip          like isskfunc.usrtip,
         funmat          like isskfunc.funmat,
         msg_alteracao   char(1000) # MENSAGEM DIZENDO O QUE FOI ALTERADO
  end record

  define l_msg           char(2000),
         l_assunto       char(100),
         l_funnom        like isskfunc.funnom,
         l_data          date,
         l_hora          datetime hour to second,
         l_status        smallint

  if m_cts20g08_prep is null or
     m_cts20g08_prep <> true then
     call cts20g08_prepare()
  end if

  #-----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #-----------------------------
  let l_assunto = null
  let l_msg     = null
  let l_funnom  = null
  let l_data    = null
  let l_hora    = null

  #-----------------------------
  # BUSCA A DATA E HORA DO BANCO
  #-----------------------------
  call cts40g03_data_hora_banco(1)
       returning l_data,
                 l_hora

  #----------------------------
  # BUSCA O NOME DO FUNCIONARIO
  #----------------------------
  open ccts20g08002 using lr_parametro.funmat,
                          lr_parametro.empcod,
                          lr_parametro.usrtip
  whenever error continue
  fetch ccts20g08002 into l_funnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_funnom = null
     else
        error "Erro SELECT ccts20g08002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "cts20g08() / ", lr_parametro.funmat, "/",
                               lr_parametro.empcod, "/",
                               lr_parametro.usrtip sleep 3
        close ccts20g08002
        return
     end if
  end if

  close ccts20g08002

  #-----------------------------
  # MONTANDO O ASSUNTO DO E-MAIL
  #-----------------------------
  let l_assunto = lr_parametro.tipo_oper clipped,
                  " no Cadastro de ", lr_parametro.nome_cad clipped

  #------------------------------
  # MONTANDO A MENSAGEM DO E-MAIL
  #------------------------------
  let l_msg = "Data da ", lr_parametro.tipo_oper clipped, ": ",
              l_data using "dd/mm/yyyy",                         ascii(13), # ascii(13) = <ENTER>
              "Hora da ", lr_parametro.tipo_oper clipped, ": ",
              l_hora,                                            ascii(13),
                                                                 ascii(13),
              "Dados do Funcionario que realizou a ",
              lr_parametro.tipo_oper clipped, ": ",              ascii(13),
              "------------------------------------------------",ascii(13),
                                                                 ascii(13),
              "Empresa..: ", lr_parametro.empcod using "<&",     ascii(13),
              "Tipo.....: ", lr_parametro.usrtip clipped,        ascii(13),
              "Matricula: ", lr_parametro.funmat using "<<<<<&", ascii(13),
              "Nome.....: ", l_funnom            clipped,        ascii(13),
                                                                 ascii(13),
              lr_parametro.tipo_oper clipped, " realizada:",     ascii(13),
              "----------------------", ascii(13),
                                        ascii(13),
              lr_parametro.msg_alteracao clipped

  #---------------------------------
  # CHAMA A FUNCAO P/ENVIAR O E-MAIL
  #---------------------------------
  let l_status = cts20g08_envia_email(l_assunto,
                                      l_msg,
                                      lr_parametro.nome_4gl)

  if l_status <> 0 then
     if l_status <> 99 then
        error "Erro ao enviar email(cts20g08) sobre alteracao de cadastro" sleep 4
     else
        error "Nao existe email cadastrado para o modulo - CTS20G08" sleep 4
     end if
  end if

end function

#-----------------------------------------#
function cts20g08_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         assunto      char(100),
         msg          char(2000),
         nome_4gl     char(08)
  end record

  define l_status     smallint,
         l_comando    char(3000),
         l_email      like igbmparam.relpamtxt,
         l_remetentes char(800)
         
  ### RODOLFO MASSINI - INICIO 
  #---> Variaves para:
  #     remover (comentar) forma de envio de e-mails anterior e inserir
  #     novo componente para envio de e-mails.
  #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
  define lr_mail record       
         rem char(50),        
         des char(250),       
         ccp char(250),       
         cco char(250),       
         ass char(500),       
         msg char(32000),     
         idr char(20),        
         tip char(4)          
  end record 
 
  define l_anexo   char (300)
        ,l_retorno smallint

  initialize lr_mail
            ,l_anexo
            ,l_retorno
  to null
 
  ### RODOLFO MASSINI - FIM 

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_remetentes = null
  let l_comando    = null
  let l_email      = null
  let l_status     = 0

  #--------------------------------------
  # BUSCA OS REMETENTES P/ENVIO DE E-MAIL
  #--------------------------------------
  open ccts20g08001 using lr_parametro.nome_4gl
  foreach ccts20g08001 into l_email

     if l_remetentes is null then
        let l_remetentes = l_email
     else
        let l_remetentes = l_remetentes clipped, ",", l_email
     end if

  end foreach

  close ccts20g08001

  if l_remetentes is not null then
        
     ### RODOLFO MASSINI - INICIO 
     #---> remover (comentar) forma de envio de e-mails anterior e inserir
     #     novo componente para envio de e-mails.
     #---> feito por Rodolfo Massini (F0113761) em maio/2013

     #let l_comando = ' echo "', lr_parametro.msg     clipped, '" | send_email.sh ',
     #                ' -a    ', l_remetentes         clipped,
     #                ' -s   "', lr_parametro.assunto clipped, '" '
     #run l_comando
     #    returning l_status
  
     let lr_mail.ass = lr_parametro.assunto clipped
     let lr_mail.msg = lr_parametro.msg clipped
     let lr_mail.des = l_remetentes clipped
     let lr_mail.tip = "text"
 
     call ctx22g00_envia_email_overload(lr_mail.*
                                       ,l_anexo)
     returning l_retorno  
     
     let l_status = l_retorno                                      
     
     ### RODOLFO MASSINI - FIM         
         
  else
     let l_status = 99
  end if

  return l_status

end function

