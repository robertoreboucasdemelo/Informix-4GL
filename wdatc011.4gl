#############################################################################
# Nome do Modulo: wdatc011                                           Marcus #
#                                                                      Raji #
# Informacoes adicionais do sinal/botao                            Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#............................................................................# 
#                  * * *  ALTERACOES  * * *                                  # 
#                                                                            # 
# Data       Autor Fabrica PSI       Alteracao                               # 
# --------   ------------- ------    ----------------------------------------# 
# 19/07/2006 Andrei, Meta            Migracao de versao do 4gl               #
#----------------------------------------------------------------------------#

database porto

main
 
   define param        record
      usrtip          char (1),
      webusrcod       char (06),
      sesnum          dec  (10),
      macsissgl       char (10),
      mdtmvtseq       like datmmdtmvt.mdtmvtseq
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


   define wdatc011       record
      mdtmvtseq          like datmmdtmvt.mdtmvtseq,
      caddat             like datmmdtmvt.caddat,
      cadhor             like datmmdtmvt.cadhor,
      mdtcod             like datmmdtmvt.mdtcod,
      atdvclsgl          like datkveiculo.atdvclsgl,
      socvclcod          like datkveiculo.socvclcod,
      vcldes             char (45),
      mdtmvttipcod       like datmmdtmvt.mdtmvttipcod,
      mdtmvttipdes       char (15),
      mdtbotprgseq       like datmmdtmvt.mdtbotprgseq,
      mdtbottxt          like datkmdtbot.mdtbottxt,
      mdtmvtdigcnt       like datmmdtmvt.mdtmvtdigcnt,
      ufdcod             like datmmdtmvt.ufdcod,
      cidnom             like datmmdtmvt.cidnom,
      brrnom             like datmmdtmvt.brrnom,
      endzon             like datmmdtmvt.endzon,
      mdtmvtsnlflg       like datmmdtmvt.mdtmvtsnlflg,
      lclltt             like datmmdtmvt.lclltt,
      lcllgt             like datmmdtmvt.lcllgt,                                  
      mdtmvtdircod       like datmmdtmvt.mdtmvtdircod,
      mdtmvtvlc          like datmmdtmvt.mdtmvtvlc,
      mdtmvtstt          like datmmdtmvt.mdtmvtstt,
      mdtmvtsttdes       char (50),
      mdterrcod          like datmmdterr.mdterrcod,
      mdterrdes          char (50),
      mdttrxnum          like datmmdtmvt.mdttrxnum
   end record

   define ws             record
      confirma           char (01),
      vclcoddig          like datkveiculo.vclcoddig,
      sttsess            dec (1,0)
   end record

   initialize ws.*  to null
   initialize ws1.*  to null
   initialize wdatc011.*  to null
   initialize param.*  to null

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   let param.usrtip    = arg_val(1)
   let param.webusrcod = arg_val(2)
   let param.sesnum    = arg_val(3)
   let param.macsissgl = arg_val(4)
   let param.mdtmvtseq = arg_val(5)

   #---------------------------------------------
   #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
   #---------------------------------------------
   call wdatc002(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
        returning ws1.*

   if ws1.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> perman\52ncia nesta p\341gina atingiu o limite m\341ximo.@@" 
      exit program(0)
   end if 

   #--------------------------------------------------------------------
   #  Le tabela de movimento dos MDTs
   #--------------------------------------------------------------------
   select caddat      , cadhor      ,
          mdtcod      , mdtmvttipcod,
          mdtbotprgseq, mdtmvtdigcnt,
          ufdcod      , cidnom      ,
          brrnom      , endzon      ,
          lclltt      , lcllgt      ,
          mdtmvtdircod, mdtmvtvlc   ,
          mdtmvtstt   , mdterrcod   ,
          mdtmvtsnlflg, mdttrxnum
     into wdatc011.caddat      , wdatc011.cadhor      ,
          wdatc011.mdtcod      , wdatc011.mdtmvttipcod,
          wdatc011.mdtbotprgseq, wdatc011.mdtmvtdigcnt,
          wdatc011.ufdcod      , wdatc011.cidnom      ,
          wdatc011.brrnom      , wdatc011.endzon      ,
          wdatc011.lclltt      , wdatc011.lcllgt      ,
          wdatc011.mdtmvtdircod, wdatc011.mdtmvtvlc   ,
          wdatc011.mdtmvtstt   , wdatc011.mdterrcod   ,
          wdatc011.mdtmvtsnlflg, wdatc011.mdttrxnum
     from datmmdtmvt, outer datmmdterr
    where datmmdtmvt.mdtmvtseq  =  param.mdtmvtseq
      and datmmdterr.mdtmvtseq  =  datmmdtmvt.mdtmvtseq

   select cpodes
     into wdatc011.mdtmvttipdes
     from iddkdominio
    where cponom  =  "mdtmvttipcod"
      and cpocod  =  wdatc011.mdtmvttipcod

   if wdatc011.mdtbotprgseq  is not null   then
      select mdtbottxt
        into wdatc011.mdtbottxt
        from datkmdt, datrmdtbotprg, datkmdtbot
       where datkmdt.mdtcod              =  wdatc011.mdtcod
         and datrmdtbotprg.mdtprgcod     =  datkmdt.mdtprgcod
         and datrmdtbotprg.mdtbotprgseq  =  wdatc011.mdtbotprgseq
         and datkmdtbot.mdtbotcod        =  datrmdtbotprg.mdtbotcod
   end if

   select socvclcod,
          atdvclsgl,
          vclcoddig
     into wdatc011.socvclcod,
          wdatc011.atdvclsgl,
          ws.vclcoddig
     from datkveiculo
    where mdtcod  =  wdatc011.mdtcod

   call cts15g00(ws.vclcoddig)  returning wdatc011.vcldes

   select cpodes
     into wdatc011.mdtmvtsttdes
     from iddkdominio
    where cponom  =  "mdtmvtstt"
      and cpocod  =  wdatc011.mdtmvtstt
  
   if wdatc011.mdterrcod  is not null   then
      select cpodes
        into wdatc011.mdterrdes
        from iddkdominio
       where cponom  =  "mdterrcod"
         and cpocod  =  wdatc011.mdterrcod
   end if

   display "PADRAO@@1@@B@@C@@0@@Mensagem recebida do MDT@@"
   display "PADRAO@@8@@Sequência do movimento@@",param.mdtmvtseq,"@@"
   display "PADRAO@@8@@Data transmissão@@",wdatc011.caddat,"@@"
   display "PADRAO@@8@@Hora transmiss\343o@@",wdatc011.cadhor,"@@"
   display "PADRAO@@8@@MDT@@",wdatc011.mdtcod,"@@"
   display "PADRAO@@8@@Ve&iacute;culo@@",wdatc011.atdvclsgl," ",
            wdatc011.socvclcod," ",
            wdatc011.vcldes,"@@"
   display "PADRAO@@8@@Tipo movimento@@",wdatc011.mdtmvttipdes,"@@"
   display "PADRAO@@8@@Bot&atilde;o@@",wdatc011.mdtbottxt,"@@"
   display "PADRAO@@8@@Digita&ccedil&atilde;o@@",wdatc011.mdtmvtdigcnt,"@@"
   display "PADRAO@@8@@UF@@",wdatc011.ufdcod,"@@"
   display "PADRAO@@8@@Cidade@@",wdatc011.cidnom,"@@"
   display "PADRAO@@8@@Bairro@@",wdatc011.brrnom,"@@"
   display "PADRAO@@8@@Zona@@",wdatc011.endzon,"@@"
   display "PADRAO@@8@@GPS v&aacute;lido@@",wdatc011.mdtmvtsnlflg,"@@"
   display "PADRAO@@8@@Latitude@@",wdatc011.lclltt,"@@"
   display "PADRAO@@8@@Longitude@@",wdatc011.lcllgt,"@@"
   display "PADRAO@@8@@Dire&ccedil&atilde;o@@",wdatc011.mdtmvtdircod,"@@"
   display "PADRAO@@8@@Velocidade@@",wdatc011.mdtmvtvlc,"@@"
   display "PADRAO@@8@@Situa&ccedil&atilde;o@@",wdatc011.mdtmvtsttdes,"@@"
   display "PADRAO@@8@@Erro@@",wdatc011.mdterrdes,"@@"


   #------------------------------------
   # ATUALIZA TEMPO DE SESSAO DO USUARIO
   #------------------------------------
   call wdatc003(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl,
                  ws1.*)
        returning ws.sttsess

end main
