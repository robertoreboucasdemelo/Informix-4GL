#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTY13G00                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: PSI 202231 - COMUNICACAO ROUBO/FURTO AO SISTEMA DAF.       #
#                  MOD. RESPONSAVEL POR INSERIR DADOS NA TABELA DAFMINTAVS.   #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/07/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 21/03/2007 Ruiz                       gravar a tabela do DAF para todos os  #
#                                       dispositivos(ituran/daf5/lojack.      #
#-----------------------------------------------------------------------------#
# 04/01/2010 Roberto                      Projeto SUCCOD - Smallint           #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail   #
###############################################################################

database porto

  define m_cty13g00_prep smallint

#---------------------------#
function cty13g00_prepare()
#---------------------------#

  define l_sql char(500)

  let l_sql = " insert into dafmintavs (intseq, ",
                                      " excinc, ",
                                      " excfnl, ",
                                      " errcod, ",
                                      " errdsc, ",
                                      " discoddig, ",
                                      " sinlclltt, ",
                                      " sinlcllgt, ",
                                      " atdsrvnum, ",
                                      " atdsrvano, ",
                                      " vclcoddig, ",
                                      " vcldes, ",
                                      " vcllicnum, ",
                                      " c24astcod, ",
                                      " vclchscod, ",
                                      " segnom, ",
                                      " sindat, ",
                                      " cincmudat, ",
                                      " caddat, ",
                                      " imsvlr, ",
                                      " sinres, ",
                                      " enttck, ",
                                      " succod, ",
                                      " aplnumdig, ",
                                      " itmnumdig, ",
                                      " dctnumseq, ",
                                      " edsnumdig, ",
                                      " prporgpcp, ",
                                      " prpnumpcp, ",
                                      " cgccpfnum, ",
                                      " cgcord, ",
                                      " cgccpfdig, ",
                                      " vclcordsc, ",
                                      " cdtnom, ",
                                      " itgttvnum) ",
                              " values (0,current,?,?,?,?,?,?,?,?,?,?,?,?, ",
                                      " ?,?,?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cty13g00_001 from l_sql

  let l_sql = " select vclchsinc, ",
                     " vclchsfnl ",
                " from abbmveic ",
               " where succod = ? and ",
                     " aplnumdig = ? and ",
                     " itmnumdig = ? and ",
                     " dctnumseq = (select max(dctnumseq) ",
                                    " from abbmveic ",
                                   " where succod = ? and ",
                                         " aplnumdig = ? and ",
                                         " itmnumdig = ?) "

  prepare p_cty13g00_002 from l_sql
  declare c_cty13g00_001 cursor for p_cty13g00_002

  let m_cty13g00_prep = true

end function

#-----------------------------#
function cty13g00(lr_parametro)
#-----------------------------#

  define lr_parametro     record
         excfnl           like dafmintavs.excfnl,
         errcod           like dafmintavs.errcod,
         errdsc           like dafmintavs.errdsc,
         discoddig        like dafmintavs.discoddig,
         sinlclltt        like dafmintavs.sinlclltt,
         sinlcllgt        like dafmintavs.sinlcllgt,
         atdsrvnum        like dafmintavs.atdsrvnum,
         atdsrvano        like dafmintavs.atdsrvano,
         vclcoddig        like dafmintavs.vclcoddig,
         vcldes           like dafmintavs.vcldes,
         vcllicnum        like dafmintavs.vcllicnum,
         c24astcod        like dafmintavs.c24astcod,
         vclchscod        like dafmintavs.vclchscod,
         segnom           like dafmintavs.segnom,
         sindat           like dafmintavs.sindat,
         cincmudat        like dafmintavs.cincmudat,
         caddat           like dafmintavs.caddat,
         imsvlr           like dafmintavs.imsvlr,
         sinres           like dafmintavs.sinres,
         enttck           like dafmintavs.enttck,
         succod           like dafmintavs.succod,
         aplnumdig        like dafmintavs.aplnumdig,
         itmnumdig        like dafmintavs.itmnumdig,
         dctnumseq        like dafmintavs.dctnumseq,
         edsnumdig        like dafmintavs.edsnumdig,
         prporgpcp        like dafmintavs.prporgpcp,
         prpnumpcp        like dafmintavs.prpnumpcp,
         cgccpfnum        like dafmintavs.cgccpfnum,
         cgcord           like dafmintavs.cgcord,
         cgccpfdig        like dafmintavs.cgccpfdig,
         vclcordsc        like dafmintavs.vclcordsc,
         cdtnom           like dafmintavs.cdtnom,
         itgttvnum        like dafmintavs.itgttvnum,
         prg_chamou       char(08)
  end record

  define lr_daf           record
         vclchsinc        like abbmveic.vclchsinc,
         vclchsfnl        like abbmveic.vclchsfnl,
         dispo            smallint               ,
         orrdat           like adbmbaixa.orrdat  ,
         qtd_dispo_ativo  integer
  end record

  define l_msg_erro   char(100)

  if m_cty13g00_prep is null or
     m_cty13g00_prep <> true then
     call cty13g00_prepare()
  end if

  initialize lr_daf.* to null
  let l_msg_erro = null

  #---------------------------------------------------
  # VERIFICA SE APOLICE TEM DAF ou ITURAN ou LOJACK
  #---------------------------------------------------
  if lr_parametro.succod    is not null and
     lr_parametro.aplnumdig is not null and
     lr_parametro.itmnumdig is not null then

     open c_cty13g00_001 using lr_parametro.succod,
                             lr_parametro.aplnumdig,
                             lr_parametro.itmnumdig,
                             lr_parametro.succod,
                             lr_parametro.aplnumdig,
                             lr_parametro.itmnumdig
     whenever error continue
     fetch c_cty13g00_001 into lr_daf.vclchsinc,
                             lr_daf.vclchsfnl
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_daf.vclchsinc = null
           let lr_daf.vclchsfnl = null
        else
           let l_msg_erro="Erro (", sqlca.sqlcode, ") ao selecionar na tabela ABBMVEIC"
           call cty13g00_email_erro(today,
                                    current,
                                    l_msg_erro,
                                    lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano,
                                    lr_parametro.succod,
                                    lr_parametro.aplnumdig,
                                    lr_parametro.vcllicnum,
                                    lr_parametro.prg_chamou)
        end if
     end if

     close c_cty13g00_001
     # alterado de "and" para "or" em 08/06/07 - Ruiz
     if lr_daf.vclchsfnl       is not null or
        lr_parametro.vcllicnum is not null then
        call fadic005_existe_dispo(lr_daf.vclchsinc       ,
                                   lr_daf.vclchsfnl       ,
                                   lr_parametro.vcllicnum ,
                                   lr_parametro.vclcoddig ,
                                   3646)     # DAF V
        returning lr_daf.dispo , lr_daf.orrdat, lr_daf.qtd_dispo_ativo

        if lr_daf.dispo = true then
           let lr_parametro.discoddig = 3646
        else
           call fadic005_existe_dispo(lr_daf.vclchsinc       ,
                                      lr_daf.vclchsfnl       ,
                                      lr_parametro.vcllicnum ,
                                      lr_parametro.vclcoddig ,
                                      1333)     # ITURAN
           returning lr_daf.dispo , lr_daf.orrdat, lr_daf.qtd_dispo_ativo
           if lr_daf.dispo = true then
              let lr_parametro.discoddig = 1333
           else
              call fadic005_existe_dispo(lr_daf.vclchsinc       ,
                                         lr_daf.vclchsfnl       ,
                                         lr_parametro.vcllicnum ,
                                         lr_parametro.vclcoddig ,
                                         1546)     # LOJACK
              returning lr_daf.dispo , lr_daf.orrdat, lr_daf.qtd_dispo_ativo
              if lr_daf.dispo = true then
                 let lr_parametro.discoddig = 1546
              else
                 call fadic005_existe_dispo(lr_daf.vclchsinc       ,
                                            lr_daf.vclchsfnl       ,
                                            lr_parametro.vcllicnum ,
                                            lr_parametro.vclcoddig ,
                                            8230)     # DAF VIII
                  returning lr_daf.dispo , lr_daf.orrdat, lr_daf.qtd_dispo_ativo
                 if lr_daf.dispo = true then
                   let lr_parametro.discoddig = 8230
                 end if
             end if
           end if
        end if
     end if
  end if

  #----------------------------------------
  # INSERE OS OS DADOS NA TABELA dafmintavs
  #----------------------------------------
  whenever error continue
  execute p_cty13g00_001 using lr_parametro.excfnl,
                           lr_parametro.errcod,
                           lr_parametro.errdsc,
                           lr_parametro.discoddig,
                           lr_parametro.sinlclltt,
                           lr_parametro.sinlcllgt,
                           lr_parametro.atdsrvnum,
                           lr_parametro.atdsrvano,
                           lr_parametro.vclcoddig,
                           lr_parametro.vcldes,
                           lr_parametro.vcllicnum,
                           lr_parametro.c24astcod,
                           lr_parametro.vclchscod,
                           lr_parametro.segnom,
                           lr_parametro.sindat,
                           lr_parametro.cincmudat,
                           lr_parametro.caddat,
                           lr_parametro.imsvlr,
                           lr_parametro.sinres,
                           lr_parametro.enttck,
                           lr_parametro.succod,
                           lr_parametro.aplnumdig,
                           lr_parametro.itmnumdig,
                           lr_parametro.dctnumseq,
                           lr_parametro.edsnumdig,
                           lr_parametro.prporgpcp,
                           lr_parametro.prpnumpcp,
                           lr_parametro.cgccpfnum,
                           lr_parametro.cgcord,
                           lr_parametro.cgccpfdig,
                           lr_parametro.vclcordsc,
                           lr_parametro.cdtnom,
                           lr_parametro.itgttvnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     #---------------------------------------------------
     # SE OCORRER ERRO NO INSERT, ENVIA E-MAIL INFORMANDO
     #---------------------------------------------------
     let l_msg_erro="Erro (", sqlca.sqlcode, ") ao inserir na tabela DAFMINTAVS. " ,sqlca.sqlcode
     call cty13g00_email_erro(today,
                              current,
                              l_msg_erro,
                              lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano,
                              lr_parametro.succod,
                              lr_parametro.aplnumdig,
                              lr_parametro.vcllicnum,
                              lr_parametro.prg_chamou)
  else
     #---------------------------------------------------
     # SE INSERIR OK, ENVIA E-MAIL PRA CAMILA INFORMANDO
     #---------------------------------------------------
     let l_msg_erro="Aviso Gerado. Chave de acesso (intseq): " ,sqlca.sqlerrd[2]
     call cty13g00_email_erro(today,
                              current,
                              l_msg_erro,
                              lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano,
                              lr_parametro.succod,
                              lr_parametro.aplnumdig,
                              lr_parametro.vcllicnum,
                              lr_parametro.prg_chamou)
  end if

end function

#--------------------------------------#
function cty13g00_email_erro(lr_parametro)
#--------------------------------------#

  define lr_parametro record
         data         date,                       # DATA DO ERRO
         hora         datetime hour to second,    # HORA DO ERRO
         msg          char(100),                  # MENSAGEM DO ERRO
         atdsrvnum    like dafmintavs.atdsrvnum,  # NUMERO DO SERVICO
         atdsrvano    like dafmintavs.atdsrvano,  # ANO DO SERVICO
         succod       like dafmintavs.succod,     # SUCURSAL
         aplnumdig    like dafmintavs.aplnumdig,  # APOLICE
         vcllicnum    like dafmintavs.vcllicnum,  # PLACA DO VEICULO
         prg_chamou   char(08)
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
  define l_comando    char(1000),
         l_msg_envio  char(600),
         l_destino    char(300),
         l_remetente  char(50),
         l_comcopia   char(50),
         l_assunto    char(80)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

  let l_comando   = null
  let l_comcopia  = null
  let l_remetente = "EmailCorr.ct24hs@correioporto"
  let l_destino   = "Candido_Camila@correioporto"
# Acompanhamos 2 semanas em producao, caso ocorra problema habilitaremos novamente.
#  let l_comcopia  = "Ruiz_Carlos@correioporto,Costa_Nilo@correioporto"

  if lr_parametro.msg[01,04] = "Erro" then
     let l_assunto   = "ERRO DE INSERT NA TABELA dafmintavs"
  else
     let l_assunto   = "Aviso de Sinistro Gerado (dafmintavs)"
  end if

  let l_msg_envio =
      "DATA/HORA: ", lr_parametro.data, " ",
                     lr_parametro.hora,                         ascii(13),
      "MSG......: ", lr_parametro.msg       clipped,            ascii(13),
      "SERVICO..: ", lr_parametro.atdsrvnum clipped, "-",
                     lr_parametro.atdsrvano using "<<<<&",      ascii(13),
      "SUCURSAL.: ", lr_parametro.succod    using "<<<<&",      ascii(13),
      "APOLICE..: ", lr_parametro.aplnumdig using "<<<<<<<<&",  ascii(13),
      "PLACA....: ", lr_parametro.vcllicnum                  ,  ascii(13),
      "PROGRAMA.: ", lr_parametro.prg_chamou

  #PSI-2013-23297 - Inicio
  let l_mail.de = l_remetente
  let l_mail.para =  l_destino
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = l_assunto
  let l_mail.mensagem = l_msg_envio
  let l_mail.id_remetente = "CT24H"
  let l_mail.tipo = "text"

---> Retirado envio por solicitacao da Camila Candido - 15/05/09
  ##run l_comando

  ##call figrc009_mail_send1 (l_mail.*)
  ## returning l_coderro,msg_erro
  #PSI-2013-23297 - Fim
end function
