#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G23                                                   #
# ANALISTA RESP..: CARLOS A. RUIZ                                             #
# PSI/OSF........: CHAMADO 6084380                                            #
#                  CONTROLE DOS PROBLEMAS RELACIO. AOS ASSUNTOS V10 E V11.    #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 16/08/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail   #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts40g23_prep smallint

#-------------------------#
function cts40g23_prepare()
#-------------------------#

  define l_sql char(300)

  # -> INICIALIZACAO DAS VARIAVEIS

  let l_sql           = null
  let m_cts40g23_prep = null

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "

  prepare p_cts40g23_001 from l_sql
  declare c_cts40g23_001 cursor for p_cts40g23_001

  let l_sql = " delete from datkgeral where grlchv = ? "

  prepare p_cts40g23_002 from l_sql

  let l_sql = " insert into datkgeral ",
                         " (grlchv, ",
                          " grlinf, ",
                          " atldat, ",
                          " atlhor, ",
                          " atlemp, ",
                          " atlmat) ",
                   " values(?,?,today,current,?,?) "

  prepare p_cts40g23_003 from l_sql

  let m_cts40g23_prep = true

end function

#-----------------------------------#
function cts40g23_busca_chv(l_grlchv)
#-----------------------------------#

 define l_grlchv like datkgeral.grlchv,
        l_grlinf like datkgeral.grlinf

  if m_cts40g23_prep is null or
     m_cts40g23_prep <> true then
     call cts40g23_prepare()
  end if

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_grlinf = null

  # -> BUSCA O CAMPO grlinf DA TABELA DATKGERAL

  ## CT512095 - INICIO
  ## Controle de erro removido devido a utilizacao da funcao
  ## em batchs e processos online. Quando nao encontrado
  ## resultado o programa nao deve prosseguir, pois este
  ## retorno e utilizado em verificacoes.

  open c_cts40g23_001 using l_grlchv
  #whenever error continue
  fetch c_cts40g23_001 into l_grlinf
  #whenever error stop

  ## CT512095 - FIM

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_grlinf = null
     else
        error "Erro SELECT c_cts40g23_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "cts40g23_busca_chv() ", l_grlchv sleep 3
     end if
  end if

  close c_cts40g23_001

  return l_grlinf

end function

#-----------------------------------#
function cts40g23_apaga_chv(l_grlchv)
#-----------------------------------#

  define l_grlchv like datkgeral.grlchv

  if m_cts40g23_prep is null or
     m_cts40g23_prep <> true then
     call cts40g23_prepare()
  end if

  whenever error continue
  execute p_cts40g23_002 using l_grlchv
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro DELETE p_cts40g23_002 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "cts40g23_apaga_chv() ", l_grlchv sleep 3
  end if

end function

#----------------------------------------#
function cts40g23_insere_chv(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         grlchv       like datkgeral.grlchv,
         grlinf       like datkgeral.grlinf,
         atlemp       like datkgeral.atlemp,
         atlmat       like datkgeral.atlmat
  end record

  if m_cts40g23_prep is null or
     m_cts40g23_prep <> true then
     call cts40g23_prepare()
  end if

  whenever error continue
  execute p_cts40g23_003 using lr_parametro.grlchv,
                             lr_parametro.grlinf,
                             lr_parametro.atlemp,
                             lr_parametro.atlmat
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro INSERT p_cts40g23_003 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "cts40g23_insere_chv() ", lr_parametro.grlchv, "/",
                                     lr_parametro.grlinf, "/",
                                     lr_parametro.atlemp, "/",
                                     lr_parametro.atlmat sleep 4
  end if

end function

#--------------------------------------------#
function cts40g23_monta_chv_pesq(lr_parametro)
#--------------------------------------------#

  # -> MONTA A CHAVE DE PESQUISA NA DATKGERAL

  define lr_parametro record
         funmat       like isskfunc.funmat,
         maqsgl       like ismkmaq.maqsgl
  end record

  define l_grlchv     like datkgeral.grlchv

  let l_grlchv = null

  let l_grlchv = "V10V11",
                 lr_parametro.maqsgl clipped,
                 lr_parametro.funmat using "&&&&&&"

  return l_grlchv

end function

#------------------------------------------------#
function cts40g23_monta_chv_insercao(lr_parametro)
#------------------------------------------------#

  # -> MONTA A CHAVE DE INSERCAO NA TABELA DATKGERAL

  define lr_parametro record
         succod       like abamapol.succod,
         ramcod       like rsamseguro.ramcod,
         aplnumdig    like abamapol.aplnumdig,
         itmnumdig    like abbmdoc.itmnumdig
  end record

  define l_grlinf     like datkgeral.grlinf

  let l_grlinf = null

  let l_grlinf = lr_parametro.succod    using "&&",
                 lr_parametro.ramcod    using "&&&&&",
                 lr_parametro.aplnumdig using "&&&&&&&&&",
                 lr_parametro.itmnumdig using "&&&&&&&"

  return l_grlinf

end function

#-----------------------------------=--------#
function cts40g23_dmnta_chv_insercao(l_grlinf)
#--------------------------------------------#

  # -> DESMONTA A CHAVE DE INSERCAO NA TABELA DATKGERAL

  define l_grlinf       like datkgeral.grlinf

  define l_succod       like abamapol.succod,
         l_ramcod       like rsamseguro.ramcod,
         l_aplnumdig    like abamapol.aplnumdig,
         l_itmnumdig    like abbmdoc.itmnumdig

  let l_succod    = null
  let l_ramcod    = null
  let l_aplnumdig = null
  let l_itmnumdig = null

  let l_succod    = l_grlinf[1,2]   # -> SUCURSAL
  let l_ramcod    = l_grlinf[3,7]   # -> RAMO
  let l_aplnumdig = l_grlinf[8,16]  # -> APOLICE
  let l_itmnumdig = l_grlinf[17,23] # -> ITEM

  return l_succod,
         l_ramcod,
         l_aplnumdig,
         l_itmnumdig

end function

#-----------------------------------------#
function cts40g23_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro   record
         assunto        char(100),
         aplnumdig_datk like abamapol.aplnumdig,
         succod_datk    like abamapol.succod,
         ramcod_datk    like rsamseguro.ramcod,
         itmnumdig_datk like abbmdoc.itmnumdig,
         aplnumdig_doc  like abamapol.aplnumdig,
         succod_doc     like abamapol.succod,
         ramcod_doc     like rsamseguro.ramcod,
         itmnumdig_doc  like abbmdoc.itmnumdig,
         c24paxnum      like datmligacao.c24paxnum,
         funmat         like isskfunc.funmat,
         funnom         like isskfunc.funnom,
         c24astcod      like datkassunto.c24astcod
  end record

  define l_comando char(1000),
         l_msg     char(500),
         l_destino char(100),
         l_hora    datetime hour to second,
         l_data    date

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
  let l_comando = null
  let l_msg     = null
  let l_destino = "Scheid_Lucas@correioporto,Ruiz_Carlos@correioporto,Ct24hs_Beatriz@correioporto"
  let l_hora    = current
  let l_data    = today

  let l_msg = "Maquina..........: ", g_issk.maqsgl               clipped, "<br>",
              "Data - Hora......: ", l_data                      using "dd/mm/yyyy", " - ",
                                     l_hora,                                        "<br>",
              "Apolice DATKGERAL: ", lr_parametro.succod_datk    using "&&",        " ",
                                     lr_parametro.ramcod_datk    using "<<<<&",     " ",
                                     lr_parametro.aplnumdig_datk using "<<<<<<<<&", " ",
                                     lr_parametro.itmnumdig_datk using "<<<<<<&",   "<br>",

              "Apolice DOCUMENTO: ", lr_parametro.succod_doc     using "&&",        " ",
                                     lr_parametro.ramcod_doc     using "<<<<&",     " ",
                                     lr_parametro.aplnumdig_doc  using "<<<<<<<<&", " ",
                                     lr_parametro.itmnumdig_doc  using "<<<<<<&",   "<br>",
              "Nro. da PA.......: ", lr_parametro.c24paxnum      using "<<<<<<<<&", "<br>",
              "Atendente........: ", lr_parametro.funmat         using "<<<<<&", " - ",
                                     lr_parametro.funnom         clipped,           "<br>",
              "Assunto..........: ", lr_parametro.c24astcod      clipped

  #PSI-2013-23297 - Inicio
  let l_mail.de = "CT24H"
  #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
  let l_mail.para =  l_destino
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = lr_parametro.assunto
  let l_mail.mensagem = l_msg
  let l_mail.id_remetente = "CT24H"
  let l_mail.tipo = "html"
  call figrc009_mail_send1 (l_mail.*)
   returning l_coderro,msg_erro
  #PSI-2013-23297 - Fim

end function
