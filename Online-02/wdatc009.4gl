#############################################################################
# Nome do Modulo: wdatc009                                           Marcus #
#                                                                      Raji #
# Posicionamento de frota - Sinais da viatura                      Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 05/12/2002  PSI 150550   Zyon         Implementação versão de impressão   #
# 22/11/2012  12113414     Issamu       Remoção do aviso para os Prestadores#
#---------------------------------------------------------------------------#
database porto

main

   define param        record
      usrtip          char (1),
      webusrcod       char (06),
      sesnum          dec  (10,0),
      macsissgl       char (10),
      atdvclsgl       like datkveiculo.atdvclsgl,
      inicio          char (11),
      acao            char (01)
   end record

   define ws1         record
     statusprc        dec  (1,0),
     sestblvardes1    char (256),
     sestblvardes2    char (256),
     sestblvardes3    char (256),
     sestblvardes4    char (256),
     sespcsprcnom     char (256),
     prgsgl           char (256),
     acsnivcod        dec  (1,0),
     webprscod        dec  (16,0)
   end record

   define ws record
      mdtmvttipcod      like datmmdtmvt.mdtmvttipcod,
      mdtmvtseqsva      like datmmdtmvt.mdtmvtseq,
      mdtmvtstt         like datmmdtmvt.mdtmvtstt,
      mdterrcod         like datmmdterr.mdterrcod,
      mdtbotprgseq      like datmmdtmvt.mdtbotprgseq,
      cponom            like iddkdominio.cponom,
      comando           char (500),
      total             smallint,
      mdtcod            like datmmdtmvt.mdtcod,
      caddatpsq         date
   end record

   define wdatc009      record
      mdtmvtseq         like datmmdtmvt.mdtmvtseq,
      mdttrxnum         like datmmdtmvt.mdttrxnum,
      cadhor            like datmmdtmvt.cadhor,
      mdtcod            like datmmdtmvt.mdtcod,
      mdtmvttipdes      char (15),
      mdtmvtsttdes      char (30),
      mdterrdes         char (45)
   end record

   define sttsess       integer

   #define l_acionamento smallint

   initialize param.* to null
   initialize ws.* to null
   initialize ws1.* to null
   initialize wdatc009.* to null
   initialize sttsess to null

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   call fun_dba_abre_banco("CT24HS")

   call startlog("wdatc009.log")

   set lock mode to wait 10
   set isolation to dirty read

   let param.usrtip    = arg_val(1)
   let param.webusrcod = arg_val(2)
   let param.sesnum    = arg_val(3)
   let param.macsissgl = arg_val(4)
   let param.atdvclsgl = arg_val(5)
   let param.inicio    = arg_val(6)
   let param.acao      = arg_val(7)

   #--------------------------------------------
   #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
   #--------------------------------------------
   call wdatc002(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
        returning ws1.*

   if ws1.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> perman\352ncia nesta p\341gina atingiu o limite m\341ximo.@@"
      exit program(0)
   end if

   select mdtcod
     into ws.mdtcod
     from datkveiculo
    where atdvclsgl = param.atdvclsgl

   let ws.caddatpsq = today

   #-----------------------------------------------------------------------
   # Prepara comandos SQL
   #-----------------------------------------------------------------------
   let ws.comando = "select cpodes ",
                    "  from iddkdominio",
                    " where cponom = ? ",
                    "   and cpocod = ? "
   prepare sel_iddkdominio from ws.comando
   declare c_iddkdominio cursor for sel_iddkdominio

   let ws.comando = "select mdterrcod ",
                    "  from datmmdterr",
                    " where mdtmvtseq = ? "
   prepare sel_datmmdterr from ws.comando
   declare c_datmmdterr cursor for sel_datmmdterr

   let ws.comando = "select mdtbottxt",
                    "  from datkmdt, datrmdtbotprg, datkmdtbot",
                    " where datkmdt.mdtcod = ?",
                    "   and datrmdtbotprg.mdtprgcod    =  datkmdt.mdtprgcod",
                    "   and datrmdtbotprg.mdtbotprgseq = ?",
                    "   and datkmdtbot.mdtbotcod = datrmdtbotprg.mdtbotcod"
   prepare sel_datrmdtbotprg from       ws.comando
   declare c_datrmdtbotprg   cursor for sel_datrmdtbotprg

   let ws.comando = "select mdtmvtseq, mdttrxnum   , cadhor   ,",
                    "       mdtcod   , mdtmvttipcod, mdtmvtstt,",
                    "       mdtbotprgseq",
                    "  from datmmdtmvt  ",
                    " where caddat =  ? ",
                    "   and mdtcod =  ? ",
                    " order by mdtmvtseq desc"
   prepare sql_select from ws.comando
   declare c_wdatc009 cursor for sql_select

  # {initialize l_acionamento to null
  # whenever error continue 
  #    select grlinf
  #      into l_acionamento
  #      from datkgeral
  #     where grlchv ='ACIONAMENTO'
  # whenever error stop
  # 
  # if l_acionamento then
  #    display "PADRAO@@0@@<center>@@"
  #    display 'PADRAO@@0@@<table border = 1 bordercolordark="#000080" cellspacing="0" cellpadding="0" width="550">@@'
  #    display "PADRAO@@0@@<tr>@@"
  #    display "PADRAO@@0@@<td>@@"
  #    display "PADRAO@@0@@<table>@@"
  #    display "PADRAO@@0@@@@"
  #    display 'PADRAO@@0@@<tr><td><font face="ARIAL,HELVETICA,VERDANA" size="1">@@'
  #    display "PADRAO@@0@@<b>Prezado Prestador</b>, esta tela está sendo modificada. Por este motivo, a lista de sinais da viatura está temporariamente indisponível aqui no Portal.</font></td></tr>@@"
  #    display "PADRAO@@0@@   <tr><td></td></tr>@@"
  #    display 'PADRAO@@0@@<tr><td><font face="ARIAL,HELVETICA,VERDANA" size="1"> * <u>A atividade da viatura está sendo atualizada normalmente no sistema</u>(QRA, QRV, QRU, REC, INI, FIM, QRX, QTP).</font></td></tr>@@'
  #    display 'PADRAO@@0@@<tr><td><font face="ARIAL,HELVETICA,VERDANA" size="1"> * <u>A posição da viatura também está sendo atualizada normalmente no sistema </u> (local onde a viatura está). </font></td></tr>@@'
  #    display "PADRAO@@0@@<tr><td></td></tr>@@"
  #    display 'PADRAO@@0@@<tr><td><font face="ARIAL,HELVETICA,VERDANA" size="1"><center><b>Em caso de dúvida, enviando F1 pelo GPS, o sistema responderá a atividade e a localização da viatura.</b></center></font> </td></tr>@@'
  #    display "PADRAO@@0@@<tr><td></td></tr>@@"
  #    display 'PADRAO@@0@@<tr><td><font face="ARIAL,HELVETICA,VERDANA" size="1">Abaixo, você pode consultar os botões / comandos enviados pelo GPS da viatura.</font></td></tr>@@'
  #    display "PADRAO@@0@@@@"
  #    display "PADRAO@@0@@</table>@@"
  #    display "PADRAO@@0@@</td>@@"
  #    display "PADRAO@@0@@</tr>@@"
  #    display "PADRAO@@0@@</table>@@"
  #    display "PADRAO@@0@@</center>@@"
  #    display "PADRAO@@0@@<br/>@@"
  # end if}
   #-----------------------------------------------------------------------
   # Monta display de cabecalho
   #-----------------------------------------------------------------------
   if param.acao <> '2' then

       display "PADRAO@@1@@B@@C@@0@@Identifica&ccedil;&atilde;o@@"
       display "PADRAO@@8@@Data@@",ws.caddatpsq,"@@"
       display "PADRAO@@8@@Ve&iacute;culo@@",param.atdvclsgl,"@@"
      #display "PADRAO@@8@@Tipo de movimento@@@@"
      #display "PADRAO@@8@@Situa&ccedil&atilde;o@@QTP@@"
      #display "PADRAO@@8@@Total@@26@@"

       display "PADRAO@@6@@6",
               "@@B@@C@@0@@2@@15%@@Seq.Movto@@",
               "@@B@@C@@0@@2@@15%@@Transmissão MDT@@",
               "@@B@@C@@0@@2@@15%@@Hora@@",
               "@@B@@C@@0@@2@@10%@@Mdt@@",
               "@@B@@C@@0@@2@@23%@@Botão/Tp.Movto@@",
               "@@B@@C@@0@@2@@22%@@Situação@@@@"
   else
#--> Zyon 06/12/2002
       display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Identifica&ccedil;&atilde;o@@@@"
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data@@@@N@@L@@M@@4@@3@@1@@075%@@", ws.caddatpsq, "@@@@"
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ve&iacute;culo@@@@N@@L@@M@@4@@3@@1@@075%@@", param.atdvclsgl, "@@@@"

       display "PADRAO@@10@@6@@2@@1@@",
               "B@@C@@M@@4@@3@@2@@15%@@Seq.Movto@@@@",
               "B@@C@@M@@4@@3@@2@@15%@@Transmissão MDT@@@@",
               "B@@C@@M@@4@@3@@2@@15%@@Hora@@@@",
               "B@@C@@M@@4@@3@@2@@10%@@MDT@@@@",
               "B@@C@@M@@4@@3@@2@@23%@@Botão/Tp.Movto@@@@",
               "B@@C@@M@@4@@3@@2@@23%@@Situação@@@@"
#<-- Zyon 05/12/2002
   end if

   #-----------------------------------------------------------------------
   # Consulta movimento conforme parametro informado
   #-----------------------------------------------------------------------
   open c_wdatc009 using ws.caddatpsq, ws.mdtcod
   foreach c_wdatc009 into wdatc009.mdtmvtseq,
                            wdatc009.mdttrxnum,
                            wdatc009.cadhor,
                            wdatc009.mdtcod,
                            ws.mdtmvttipcod,
                            ws.mdtmvtstt,
                            ws.mdtbotprgseq

      #--------------------------------------------------------------------
      # Carrega dados na primeira tabela
      #--------------------------------------------------------------------
      initialize wdatc009.mdtmvttipdes  to null
      initialize wdatc009.mdtmvtsttdes  to null

      let ws.cponom  =  "mdtmvttipcod"
      open  c_iddkdominio  using  ws.cponom,
                                  ws.mdtmvttipcod
      fetch c_iddkdominio  into   wdatc009.mdtmvttipdes
      close c_iddkdominio

      if ws.mdtbotprgseq  is not null   then
         open  c_datrmdtbotprg using  ws.mdtcod,
                                      ws.mdtbotprgseq
         fetch c_datrmdtbotprg into   wdatc009.mdtmvttipdes
         close c_datrmdtbotprg
      end if

      let ws.cponom  =  "mdtmvtstt"
      open  c_iddkdominio  using  ws.cponom,
                                  ws.mdtmvtstt
      fetch c_iddkdominio  into   wdatc009.mdtmvtsttdes
      close c_iddkdominio

      #--------------------------------------------------------------------
      # Carrega dados na segunda tabela
      #--------------------------------------------------------------------
      initialize wdatc009.mdterrdes  to null

      if ws.mdtmvtstt  =  3   then
         open  c_datmmdterr  using  wdatc009.mdtmvtseq
         fetch c_datmmdterr  into   ws.mdterrcod
         close c_datmmdterr

         let ws.cponom  =  "mdterrcod"
         open  c_iddkdominio  using  ws.cponom,
                                     ws.mdterrcod
         fetch c_iddkdominio  into   wdatc009.mdterrdes
         close c_iddkdominio
      end if

      if param.acao <> '2' then

          display "PADRAO@@6@@6@@N@@C@@1@@1@@15%@@",wdatc009.mdtmvtseq,
                  "@@wdatc010.pl?usrtip=",param.usrtip,"&webusrcod=",
                  param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
                  "&macsissgl=",param.macsissgl clipped,
                  "&inicio=",param.inicio clipped,"&mdtmvtseq=",
                  wdatc009.mdtmvtseq clipped,
                  "@@N@@C@@1@@1@@15%@@", wdatc009.mdttrxnum,"@@",
                  "@@N@@C@@1@@1@@15%@@",wdatc009.cadhor,
                  "@@@@N@@C@@1@@1@@10%@@",wdatc009.mdtcod,
                  "@@@@N@@C@@1@@1@@23%@@",wdatc009.mdtmvttipdes,
                  "@@@@N@@C@@1@@1@@22%@@",wdatc009.mdtmvtsttdes,"@@@@"
      else
#--> Zyon 05/12/2002
          display "PADRAO@@10@@6@@1@@0@@",
                  "N@@C@@M@@4@@3@@1@@15%@@", wdatc009.mdtmvtseq,    "@@@@",
                  "N@@C@@M@@4@@3@@1@@15%@@", wdatc009.mdttrxnum,    "@@@@",
                  "N@@C@@M@@4@@3@@1@@15%@@", wdatc009.cadhor,       "@@@@",
                  "N@@C@@M@@4@@3@@1@@10%@@", wdatc009.mdtcod,       "@@@@",
                  "N@@C@@M@@4@@3@@1@@23%@@", wdatc009.mdtmvttipdes, "@@@@",
                  "N@@C@@M@@4@@3@@1@@23%@@", wdatc009.mdtmvtsttdes, "@@@@"
#<-- Zyon 05/12/2002
      end if

   end foreach

   #------------------------------------
   # ATUALIZA TEMPO DE SESSAO DO USUARIO
   #------------------------------------

   call wdatc003(param.usrtip,
                 param.webusrcod,
                 param.sesnum,
                 param.macsissgl,
                 ws1.*)
       returning sttsess
end main
