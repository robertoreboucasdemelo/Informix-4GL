# ----------------------------------------------------------------------------#
# Nome do Modulo: CTS15M03                                         Marcelo    #
#                                                                  Gilberto   #
# Direciona e imprime reserva de veiculo                           Ago/1995   #
# ----------------------------------------------------------------------------#
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 05/10/1998  Via correio  Gilberto     Alterar o numero do telefone de re-   #
#                                       torno de 226-5408 para 226-5155.      #
#                                       (solicitado por Fernando Oliveira)    #
#-----------------------------------------------------------------------------#
# 21/10/1998  Via correio  Gilberto     Alterar o numero do telefone de re-   #
#                                       torno de 226-5155 para 224-6068.      #
#                                       (solicitado por Arnaldo Cardoso)      #
#-----------------------------------------------------------------------------#
# 23/10/1998  PSI 6966-3   Gilberto     Incluir configuracoes para envio de   #
#                                       fax atraves do servidor VSI-Fax.      #
#-----------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Permitir atendimento para clausula    #
#                                       26D (Carro Extra Deficiente Fisico)   #
#-----------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Permitir atendimento para clausula    #
#                                       80 (Carro Extra Taxi).                #
#-----------------------------------------------------------------------------#
# 09/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias    #
#                                       foi alterado de (data atendimento)    #
#                                       para (data do sinistro).              #
#-----------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-   #
#                                       ma etapa do servico.                  #
#-----------------------------------------------------------------------------#
# 06/09/1999  PSI 8644-4   Wagner       Incluir mensagem de aviso no item     #
#                                       CONSIDERACOES IMPORTANTES quanto a    #
#                                       garantia da locacao.                  #
#-----------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-    #
#                                       coes, com a utilizacao de funcoes.    #
#-----------------------------------------------------------------------------#
# 09/11/1999  PSI 9681-4   Wagner       Substituir 02 avisos no item CONSID.  #
#                                       IMPORTANTES.                          #
#                                       - Modificar msg 02 e                  #
#                                       - Modificar msg 04 o nr.Telefone.     #
#-----------------------------------------------------------------------------#
# 10/12/1999               Gilberto     Incluir condicao para faturamento     #
#                                       para locacoes por departamento.       #
#-----------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de        #
#                                       solicitante.                          #
#-----------------------------------------------------------------------------#
# 20/03/2000  Via correio  Akio         Alterar o numero do telefone de re-   #
#                                       torno de 3366-6629 para 3366-3629.    #
#                                       (solicitado por Silmara)              #
#-----------------------------------------------------------------------------#
# 10/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo         #
#                                       atdsrvnum de 6 p/ 10.                 #
#-----------------------------------------------------------------------------#
# 16/08/2000  PSI 11243-7  Wagner       Inclusao mensagem Segundo condutor.   #
#-----------------------------------------------------------------------------#
# 29/11/2000  PSI 11883-4  Wagner       Incluir novo motivo de reserva        #
#                                       (5)Partucular e alterar (9)Esponta-   #
#                                       nea para Reversivel.                  #
#-----------------------------------------------------------------------------#
# 11/06/2001  PSI 13341-8  Wagner       Incluir mensagem TAXA DE ADESAO       #
#                                       OPTATIVA no quadro CONSIDERACOES      #
#                                       IMPORTANTES.                          #
#-----------------------------------------------------------------------------#
# 22/10/2001  PSI 13881-9  Wagner       Incluir CPF do usuario.               #
#-----------------------------------------------------------------------------#
# 06/02/2002  PSI 14296-4  Wagner       Incluir opcao (A)rquivo para FTP      #
#                                       Localiza.                             #
#-----------------------------------------------------------------------------#
# 22/07/2002  PSI 15679-5  Wagner       Incluir campo descriminacao para      #
#                                       veiculo BASICO.                       #
#-----------------------------------------------------------------------------#
# 17/06/2003  PSI 17491-2  Cesar Lucca  Habilitar geracao dos arquivos de     #
#             OSF 21.946   Fabsfw       reservas para transmissao FTP.        #
#-----------------------------------------------------------------------------#
# 16/03/2004  OSF 33367    Teresinha S. Inclusao do motivo 6                  #
# ----------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 12/07/2005 Andrei, Meta    PSI193402  Substituir caminho das globais,       #
#                                       Alterar informativo do campo          #
#                                       condicao substituir mensagem do       #
#                                       cheque caucao                         #
#-----------------------------------------------------------------------------#
# 06/02/2006 Lucas Scheid    PSI 197750 Inibir mensagens geradas na emisao    #
#                                       do laudo do servico.                  #
#-----------------------------------------------------------------------------#
# 15/02/2006 Alinne, Alves   PSI196878  Incluida a chamada das funcoes:       #
#                                       cts15m14_carro_extra() e              #
#                                       cts15m14_email()                      #
#-----------------------------------------------------------------------------#
# 30/10/2009 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#-----------------------------------------------------------------------------#
# 14/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 30 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 30 dias          #
#-----------------------------------------------------------------------------#
# 10/07/2013 Gabriel, Fornax  P13070041 Inclusao da variavel ws.avialgmtv     #
#                                       Na chamada da funcao                  #
#                                       ctx01g01_claus_novo                   #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
globals  "/homedsa/projetos/geral/globals/glct.4gl"     
#globals "/projetos/fornax/D0609511/central/marco/glct.4gl" 

 define wsgpipe     char(80)
  define wsgfax      char(03)

 define ws_clausula char(03)

#-----------------------------------------------------------------------
 function cts15m03(param)
#-----------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    maides           char(080),
    enviar           char (01)
 end record

 define d_cts15m03   record
    enviar           char (01),
    destino          char (24),
    dddcod           like datklocadora.dddcod,
    facnum           like datklocadora.facnum,
    faxch1           like datmfax.faxch1     ,
    faxch2           like datmfax.faxch2     ,
    envdsc           char (15),
    msg1             char (50),
    msg2             char (50)
 end record

 define salva        record
    dddcod           like datklocadora.dddcod,
    facnum           like datklocadora.facnum
 end record

 define ws           record
    lcvcod           like datkavislocal.lcvcod     ,
    aviestnom        like datkavislocal.aviestnom  ,
    lojdddcod        like datkavislocal.dddcod     ,
    lojfacnum        like datkavislocal.facnum     ,
    locdddcod        like datkavislocal.dddcod     ,
    locfacnum        like datkavislocal.facnum     ,
    lcvresenvcod     like datklocadora.lcvresenvcod,
    adcsgrtaxvlr     like datklocadora.adcsgrtaxvlr,
    avialgmtv        like datmavisrent.avialgmtv   ,
    clsdes           char (12)                     ,
    faxtxt           char (12)                     ,
    impflg           smallint                      ,
    branco           smallint                      ,
    confirma         char (01)                     ,
    envflg           dec (1,0)                     ,
    impnom           char (08)
 end record

 define l_lcvcod like datkavislocal.lcvcod



        initialize  d_cts15m03.*  to  null

        initialize  salva.*  to  null

        initialize  ws.*  to  null

 initialize d_cts15m03.*  to null
 initialize ws.*          to null

 let int_flag             =  false
 let ws.envflg            =  true
 let d_cts15m03.enviar    =  param.enviar

#-----------------------------------------------------------------------
# Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
#-----------------------------------------------------------------------

 let wsgfax = "VSI"

#-----------------------------------------------------------------------
# Obtem os dados da reserva, locadora e loja
#-----------------------------------------------------------------------
 select datklocadora.lcvcod      , datklocadora.lcvnom      ,
        datklocadora.dddcod      , datklocadora.facnum      ,
        datklocadora.lcvresenvcod, datkavislocal.aviestnom  ,
        datkavislocal.dddcod     , datkavislocal.facnum     ,
        datmavisrent.avialgmtv   , datklocadora.adcsgrtaxvlr
   into ws.lcvcod                , d_cts15m03.destino       ,
        ws.locdddcod             , ws.locfacnum             ,
        ws.lcvresenvcod          , ws.aviestnom             ,
        ws.lojdddcod             , ws.lojfacnum             ,
        ws.avialgmtv             , ws.adcsgrtaxvlr
   from datmavisrent, datkavislocal, datklocadora
  where datmavisrent.atdsrvnum  = param.atdsrvnum
    and datmavisrent.atdsrvano  = param.atdsrvano
    and datmavisrent.lcvcod     = datklocadora.lcvcod
    and datkavislocal.lcvcod    = datmavisrent.lcvcod
    and datkavislocal.aviestcod = datmavisrent.aviestcod

#-----------------------------------------------------------------------
# Verifica criacao arquivo .res para FTP com Localiza
#-----------------------------------------------------------------------
# if ws.lcvcod  = 2   then                 #comentado - chamado 7046423
#    let param.enviar = "A"
#    let d_cts15m03.enviar  =  param.enviar
# end if

#-----------------------------------------------------------------------
# Verifica se fax deve ser enviado para Central de Reservas ou para loja
#-----------------------------------------------------------------------
 case ws.lcvresenvcod
   when 1
     let d_cts15m03.envdsc  = "CENTRAL RESERVAS"
     let d_cts15m03.destino = d_cts15m03.envdsc, " ", d_cts15m03.destino
     let d_cts15m03.dddcod  = ws.locdddcod
     let d_cts15m03.facnum  = ws.locfacnum
   when 2
     let d_cts15m03.envdsc  = "LOJA"
     let d_cts15m03.destino = ws.aviestnom
     let d_cts15m03.dddcod  = ws.lojdddcod
     let d_cts15m03.facnum  = ws.lojfacnum
 end case

 open window cts15m03 at 11,17 with form "cts15m03"
             attribute (form line 1, border)

 let salva.dddcod = d_cts15m03.dddcod
 let salva.facnum = d_cts15m03.facnum
 display by name d_cts15m03.envdsc

#-----------------------------------------------------------------------
# Verifica se documento foi informado (laudo em branco)
#-----------------------------------------------------------------------

 select atdsrvnum, atdsrvano
   from datrservapol
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  then
    let ws.branco = true
 else
    let ws.branco = false
 end if
 
 call cts15m00_recupera_msg()
 returning d_cts15m03.msg1,  
           d_cts15m03.msg2   
 

 input by name d_cts15m03.enviar ,
               d_cts15m03.dddcod ,
               d_cts15m03.facnum ,
               d_cts15m03.msg1   ,
               d_cts15m03.msg2 without defaults

   before field enviar
          display by name d_cts15m03.enviar    attribute (reverse)

   after  field enviar
          display by name d_cts15m03.enviar

          if ws.lcvcod  = 2   then
             if ((d_cts15m03.enviar  is null)  or
                 (d_cts15m03.enviar <> "A"     and
                  d_cts15m03.enviar <> "F"     and
                  d_cts15m03.enviar <> "I"))   then
                error " Enviar pedido de reserva por (A)rquivo, (F)ax ou (I)mpressora !!"
                next field enviar
             end if
          else
             if ((d_cts15m03.enviar  is null)  or
                 (d_cts15m03.enviar <> "F"     and
                  d_cts15m03.enviar <> "I"))   then
                error " Enviar pedido de reserva por (F)ax ou (I)mpressora !!"
                next field enviar
             end if
          end if

          initialize wsgpipe, ws.impflg, ws.impnom to null

          if d_cts15m03.enviar = "I"   then
             call fun_print_seleciona (g_issk.dptsgl,"")
                  returning ws.impflg, ws.impnom

             if ws.impflg = false  then
                error " Departamento/Impressora nao cadastrada!"
                next field enviar
             end if
             if ws.impnom is null  then
                error " Uma impressora deve ser selecionada!"
                next field enviar
             end if
          else
             if d_cts15m03.enviar = "F"   then
                if g_outFigrc012.Is_Teste then #ambnovo
                   error " Fax so' pode ser enviado no ambiente de producao !!!"
                   next field enviar
                end if
             else
                next field msg1
             end if
          end if

   before field dddcod
          display by name d_cts15m03.dddcod    attribute (reverse)

   after  field dddcod
          display by name d_cts15m03.dddcod
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field enviar
          end if

          if d_cts15m03.dddcod   is null    or
             d_cts15m03.dddcod   = "  "     then
             error " Codigo do DDD deve ser informado !!"
             next field dddcod
          end if

          if d_cts15m03.dddcod   = "0   "   or
             d_cts15m03.dddcod   = "00  "   or
             d_cts15m03.dddcod   = "000 "   or
             d_cts15m03.dddcod   = "0000"   then
             error " Codigo do DDD invalido !!"
             next field dddcod
         end if

   before field facnum
          display by name d_cts15m03.facnum    attribute (reverse)

   after  field facnum
          display by name d_cts15m03.facnum
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field dddcod
          end if

          if d_cts15m03.facnum is null  or
             d_cts15m03.facnum =  000   then
             error " Numero do fax deve ser informado!"
             next field facnum
          else
             if d_cts15m03.facnum > 99999  then
             else
                error " Numero do fax invalido!"
                next field facnum
             end if
          end if

          if salva.dddcod <> d_cts15m03.dddcod  or
             salva.facnum <> d_cts15m03.facnum  then
             initialize d_cts15m03.envdsc to null
             display by name d_cts15m03.envdsc
          else
             if ws.lcvcod = 1  then  ## AVIS Rent a Car
                if time > "19:00:00"  then
                   error " Nao e' possivel enviar fax para a CENTRAL DE RESERVAS AVIS apos as 19:00 !"
                   let d_cts15m03.dddcod = ws.lojdddcod
                   let d_cts15m03.facnum = ws.lojfacnum
                   let d_cts15m03.envdsc = "LOJA"
                   next field dddcod
                end if
             end if
          end if

   before field msg1
          display by name d_cts15m03.msg1      attribute (reverse)

   after  field msg1
          display by name d_cts15m03.msg1
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             if d_cts15m03.enviar = "A"   then
                next field enviar
             else
                next field facnum
             end if
          end if

   before field msg2
          display by name d_cts15m03.msg2      attribute (reverse)

   after  field msg2
          display by name d_cts15m03.msg2
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field msg1
          end if

          if ws.avialgmtv = 1  and
             ws.branco = TRUE  then
             call cts15m06() returning ws_clausula

             if ws_clausula[1,2] = "26"  or
                ws_clausula[1,2] = "80"  or
                ws_clausula[1,2] = "58"  then
                let ws.clsdes = "CLAUSULA ", ws_clausula
             else
                let ws.clsdes = "1a. GRATUITA"
             end if

             call cts15m03_hist(param.atdsrvnum, param.atdsrvano, ws.clsdes, "")
          end if

   on key (interrupt)
      exit input

 end input

 if not int_flag  then
    if d_cts15m03.enviar  =  "A"  then
       #Inibido devido a utilizacao do Portal de Negocios . PSI 196.878 em 15/02/2006
       #call cts15m03_arq(param.atdsrvnum, param.atdsrvano,
       #                  d_cts15m03.msg1, d_cts15m03.msg2)
    else
       if d_cts15m03.enviar  =  "F"  then
          call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                                 "", "RS", g_issk.funmat)
                       returning ws.envflg, d_cts15m03.faxch1, d_cts15m03.faxch2

          if wsgfax = "GSF"  then
             if g_outFigrc012.Is_Teste then #ambnovo
                let ws.impnom = "tstclfax"
             else
                let ws.impnom = "reserfax"
             end if
             let wsgpipe = "lp -sd ", ws.impnom
          else
             call cts02g01_fax(d_cts15m03.dddcod, d_cts15m03.facnum)
                    returning ws.faxtxt

             let wsgpipe = "vfxCTRS ", ws.faxtxt clipped, " ", ascii 34, d_cts15m03.destino clipped, ascii 34, " ", d_cts15m03.faxch1 using "&&&&&&&&&&", " ", d_cts15m03.faxch2 using "&&&&&&&&&&"

             ####let wsgpipe = "vfxCTPS ", ws.faxtxt clipped, " ", ascii 34, d_cts15m03.destino clipped, ascii 34, " ", d_cts15m03.faxch1 using "&&&&&&&&&&", " ", d_cts15m03.faxch2 using "&&&&&&&&&&"
          end if
       else
          let wsgpipe = "lp -sd ", ws.impnom
       end if

       if ws.envflg = true  then
          #start report  rep_reserva
          #output to report rep_reserva (param.atdsrvnum   , param.atdsrvano  ,
          #                              d_cts15m03.dddcod , d_cts15m03.facnum,
          #                              d_cts15m03.faxch1 , d_cts15m03.faxch2,
          #                              d_cts15m03.destino, d_cts15m03.enviar,
          #                              d_cts15m03.msg1   , d_cts15m03.msg2  ,
          #                              ws.adcsgrtaxvlr   )
          #finish report rep_reserva

          call cts15m14_carro_extra(param.atdsrvnum   ,param.atdsrvano
                                   ,d_cts15m03.dddcod ,d_cts15m03.facnum
                                   ,d_cts15m03.faxch1 ,d_cts15m03.faxch2
                                   ,d_cts15m03.destino,d_cts15m03.enviar
                                   ,d_cts15m03.msg1   ,d_cts15m03.msg2
                                   ,wsgpipe           ,ws_clausula,0)

          #Enviar o laudo da reserva para o email da loja/locadora
          whenever error continue
          select lcvcod
            into l_lcvcod
            from datmavisrent
           where atdsrvnum = param.atdsrvnum
             and atdsrvano = param.atdsrvano

          if sqlca.sqlcode = 0 then
             select maides
               into param.maides
               from datklocadora
              where lcvcod = l_lcvcod

              if param.maides is null or
                 param.maides = " " then
                 display "Locadora sem Email Cadastrado!!!"
              end if
          else
             display "Erro ao buscar o codigo da Locadora!"
          end if

          whenever error stop

          call cts15m14_email(param.atdsrvnum, param.atdsrvano, param.maides, 'T',d_cts15m03.msg1   ,d_cts15m03.msg2 )
       else
          call cts08g01 ("A", "S", "OCORREU UM PROBLEMA NO ENVIO",
                                   "DO FAX", "",
                                   "*** TENTE NOVAMENTE ***")
            returning ws.confirma
       end if
    end if

    if d_cts15m03.msg1  is not null    or
       d_cts15m03.msg2  is not null    then
       call cts15m03_hist(param.atdsrvnum, param.atdsrvano,
                          d_cts15m03.msg1, d_cts15m03.msg2)
    end if
 else
    error " ATENCAO !!! FAX NAO SERA' ENVIADO!"

    call cts08g01("A","N","","FAX DA RESERVA DE VEICULO",
                          "*** NAO SERA' ENVIADO ***","")
         returning ws.confirma
 end if

 let int_flag = false
 close window cts15m03

end function  ###  cts15m03

#-----------------------------------------------------------------------
 function cts15m03_arq(param)
#-----------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    msg1             char (50)                 ,
    msg2             char (50)
 end record

 define ar_cts15m03  record
    nom              like datmservico.nom        ,
    avilocnom        like datmavisrent.avilocnom ,
    c24solnom        like datmligacao.c24solnom  ,
    lcvextcod        like datkavislocal.lcvextcod,
    avivclgrp        like datkavisveic.avivclgrp ,
    aviretdat        like datmavisrent.aviretdat ,
    avirethor        like datmavisrent.avirethor ,
    aviprvent        like datmavisrent.aviprvent ,
    fatporto         integer                     ,
    fatsegurado      integer                     ,
    observacoes      char (100)                  ,
    condicao         char (1000)                 ,
    prorrogacao      integer                     ,
    cpf              char (14)
 end record

 define ws           record
    lcvcod           like datkavislocal.lcvcod    ,
    aviestcod        like datkavislocal.aviestcod ,
    avivclcod        like datmavisrent.avivclcod  ,
    avialgmtv        like datmavisrent.avialgmtv  ,
    succod           like datrservapol.succod     ,
    aplnumdig        like datrservapol.aplnumdig  ,
    itmnumdig        like datrservapol.itmnumdig  ,
    edsnumref        like datrservapol.edsnumref  ,
    avioccdat        like datmavisrent.avioccdat  ,
    avidiaqtd        like datmavisrent.avidiaqtd  ,
    limite           like datmavisrent.avidiaqtd  ,
    atdfnlflg        like datmservico.atdfnlflg   ,
    lignum           like datrligsrv.lignum       ,
    clscod           like abbmclaus.clscod        ,
    viginc           like abbmclaus.viginc        ,
    vigfnl           like abbmclaus.vigfnl        ,
    locrspcpfnum     like datmavisrent.locrspcpfnum,
    locrspcpfdig     like datmavisrent.locrspcpfdig,
    vclretdat        like datmprorrog.vclretdat   ,
    vclrethor        like datmprorrog.vclrethor   ,
    aviprodiaqtd     like datmprorrog.aviprodiaqtd,
    aviprosoldat     like datmprorrog.aviprosoldat,
    aviprosolhor     like datmprorrog.aviprosolhor,
    aviprostt        like datmprorrog.aviprostt   ,
    hora             char (05)                    ,
    arquivo          char (20)                    ,
    comando          char (100)                   ,
    ciaempcod        like datmservico.ciaempcod   ,
    temcls           smallint,
    c24astcod        like datmligacao.c24astcod
 end record




        initialize  ar_cts15m03.*  to  null

        initialize  ws.*  to  null

 declare c_cts15m03_001   cursor for
  select datmservico.nom          , datmavisrent.avilocnom,
         datmavisrent.lcvcod      , datmavisrent.aviestcod,
         datmavisrent.avivclcod   , datmavisrent.aviretdat,
         datmavisrent.avirethor   , datmavisrent.aviprvent,
         datmavisrent.avialgmtv   , datmavisrent.avioccdat,
         datmavisrent.avidiaqtd   , datmservico.atdfnlflg ,
         datmavisrent.locrspcpfnum, datmavisrent.locrspcpfdig,
         datmservico.ciaempcod, datmligacao.c24astcod
    from datmservico, datmavisrent, datmligacao
   where datmservico.atdsrvnum  = param.atdsrvnum
     and datmservico.atdsrvano  = param.atdsrvano
     and datmservico.atdsrvnum  = datmavisrent.atdsrvnum
     and datmservico.atdsrvano  = datmavisrent.atdsrvano
     and datmavisrent.atdsrvnum  = datmligacao.atdsrvnum
     and datmavisrent.atdsrvano  = datmligacao.atdsrvano
     and datmligacao.c24astcod not in ("ALT","CON","CAN","RET")

  foreach c_cts15m03_001  into ar_cts15m03.nom      ,
                            ar_cts15m03.avilocnom,
                            ws.lcvcod            ,
                            ws.aviestcod         ,
                            ws.avivclcod         ,
                            ar_cts15m03.aviretdat,
                            ar_cts15m03.avirethor,
                            ar_cts15m03.aviprvent,
                            ws.avialgmtv         ,
                            ws.avioccdat         ,
                            ws.avidiaqtd         ,
                            ws.atdfnlflg         ,
                            ws.locrspcpfnum      ,
                            ws.locrspcpfdig      ,
                            ws.ciaempcod,
                            ws.c24astcod

     #-----------------------
     # Obtem nome solicitante
     #-----------------------
     let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)
     select c24solnom
       into ar_cts15m03.c24solnom
       from datmligacao
      where lignum = ws.lignum

     #-----------------------
     # Obtem sigla da loja
     #-----------------------
     select lcvextcod
       into ar_cts15m03.lcvextcod
       from datkavislocal
      where lcvcod    = ws.lcvcod
        and aviestcod = ws.aviestcod

     #-----------------------
     # Obtem grupo veiculo
     #-----------------------
     select avivclgrp
       into ar_cts15m03.avivclgrp
       from datkavisveic
      where lcvcod    = ws.lcvcod
        and avivclcod = ws.avivclcod

     #-----------------------
     # Obtem qtde para faturamento
     #-----------------------
     let ar_cts15m03.fatporto    = 0
     let ar_cts15m03.fatsegurado = 0

     if ar_cts15m03.avivclgrp = "A"  then
           case ws.avialgmtv

                 when 1
                       #---------------------------------------
                       # Motivo SINISTRO - Veiculo Basico
                       #---------------------------------------
                       select succod   , aplnumdig   , itmnumdig   , edsnumref
                         into ws.succod,ws.aplnumdig, ws.itmnumdig, ws.edsnumref
                         from datrservapol
                        where atdsrvnum = param.atdsrvnum
                          and atdsrvano = param.atdsrvano

                       if sqlca.sqlcode = notfound  then
                          initialize ws.succod, ws.aplnumdig, ws.itmnumdig to null
                          if ws.ciaempcod = 35 then
                             case ws_clausula

                                when "58A"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 05 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 05 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 05
                                   end if

                                when "58B"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 10 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 10 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 10
                                   end if

                                when "58C"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 15 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 15
                                   end if

                                when "58D"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 30 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 30
                                   end if

                                when "58E"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 05 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 05 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 05
                                   end if

                                when "58F"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 10 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 10 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 10
                                   end if

                                when "58G"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 15 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 15
                                   end if

                                when "58H"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 30 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 30
                                   end if

                                when "58I"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 07 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 07 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 07
                                   end if

                                when "58J"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 15 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 15
                                   end if

                                when "58K"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 30 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 30
                                   end if

                                when "58L"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 07 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 07 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 07
                                   end if

                                when "58M"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 15 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 15
                                   end if

                                when "58N"
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                                   if ar_cts15m03.aviprvent <= 30 then
                                      let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                   else
                                      let ar_cts15m03.fatporto = 30
                                   end if

                                otherwise

                             end case
                             if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                                let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                                              ar_cts15m03.fatporto
                             end if
                          else
                           case ws_clausula
                             when "26A"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                                if ar_cts15m03.aviprvent <= 15 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 15
                                end if
                             when "26B"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                                if ar_cts15m03.aviprvent <= 30 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 30
                                end if
                             when "26C"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                                if ar_cts15m03.aviprvent <= 7 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 7
                                end if
                             when "26D"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                                if ar_cts15m03.aviprvent <= 7 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 7
                                end if
                             ## psi201154
                             when "26E"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                                if ar_cts15m03.aviprvent <= 7 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 7
                                end if
                             when "26F"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                                if ar_cts15m03.aviprvent <= 30 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 30
                                end if
                             when "26G"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                                if ar_cts15m03.aviprvent <= 7 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 7
                                end if
                             ## psi201154
                             when "80A"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                                if ar_cts15m03.aviprvent <= 15 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 15
                                end if
                             when "80B"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                                if ar_cts15m03.aviprvent <= 30 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 30
                                end if
                             when "80C"
                                let ar_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                                if ar_cts15m03.aviprvent <= 7 then
                                   let ar_cts15m03.fatporto = ar_cts15m03.aviprvent
                                else
                                   let ar_cts15m03.fatporto = 7
                                end if
                             otherwise

                           end case
                           if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                                            ar_cts15m03.fatporto
                           end if
                          end if
                       else
                          #---------------------------------------------
                          # Verifica existencia da clausula Carro Extra
                          #---------------------------------------------
                          if ws.ciaempcod = 35 then
                             call cts44g01_claus_azul(ws.succod,
                                                      531,
                                                      ws.aplnumdig,
                                                      ws.itmnumdig)
                                  returning ws.temcls,ws.clscod
                          else
                             call ctx01g01_claus_novo (ws.succod   ,
                                                       ws.aplnumdig,
                                                       ws.itmnumdig,
                                                       ws.avioccdat,
                                                       true        ,
                                                       ws.avialgmtv)
                                      returning  ws.clscod, ws.viginc, ws.vigfnl
                          end if
                          if ws.clscod is not null    and
                             (ws.clscod[1,2] = "26"   or
                              ws.clscod[1,2] = "80"   or
                              ws.clscod[1,2] = "44"   or
                              ws.clscod[1,2] = "48"   or
                              ws.clscod[1,2] = "58")  then
                             if ws.atdfnlflg = "N"    then
                                call ctx01g00_saldo_novo (ws.succod   ,
                                                     ws.aplnumdig,
                                                     ws.itmnumdig,
                                                     "", "",
                                                     ws.avioccdat,
                                                     1, true     ,
                                                     ws.ciaempcod,
                                                     ws.avialgmtv,
                                                     ws.c24astcod )
                                           returning ws.limite, ws.avidiaqtd
                             else
                                call ctx01g00_saldo_novo (ws.succod      ,
                                                     ws.aplnumdig   ,
                                                     ws.itmnumdig   ,
                                                     param.atdsrvnum,
                                                     param.atdsrvano,
                                                     ws.avioccdat,
                                                     1, true     ,
                                                     ws.ciaempcod,
                                                     ws.avialgmtv,
                                                     ws.c24astcod )
                                           returning ws.limite, ws.avidiaqtd
                             end if

                             if ws.avidiaqtd > 0  then
                                if ws.ciaempcod = 35 then
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws.clscod, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO DE ", ws.avidiaqtd using "&&"
                                else
                                   let ar_cts15m03.condicao = "CLAUSULA ", ws.clscod, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO DE ", ws.avidiaqtd using "&&"
                                end if
                                let ar_cts15m03.fatporto = ws.avidiaqtd
                                if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                                   let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                                                 ar_cts15m03.fatporto
                                end if
                             else
                                #let ar_cts15m03.condicao = "SINISTRO - FATURAR 1a. DIARIA PARA PORTO E DEMAIS PARA O USUARIO"
                                let ar_cts15m03.condicao = null
                                let ar_cts15m03.fatporto = 1
                                if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                                   let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                                                 ar_cts15m03.fatporto
                                end if
                             end if
                          else
                             #let ar_cts15m03.condicao = "SINISTRO - FATURAR 1a. DIARIA PARA PORTO E DEMAIS PARA O USUARIO"
                             let ar_cts15m03.condicao = null
                             let ar_cts15m03.fatporto = 1
                             if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                                let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                                              ar_cts15m03.fatporto
                             end if
                          end if
                       end if

           when 2 -- motivo
              #---------------------------------------------
              # Motivo PORTO SOCORRO - Veiculo Basico
              #---------------------------------------------
              let ar_cts15m03.condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO"
              --let ar_cts15m03.condicao = null
              let ar_cts15m03.fatporto = 1
              if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                 let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                               ar_cts15m03.fatporto
              end if

           when 3
              #---------------------------------------------
              # Motivo BENEFICIO OFICINA - Veiculo Basico
              #---------------------------------------------
              if ws.ciaempcod = 35 then
                 let ar_cts15m03.condicao = "BENEFICIO - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO DE 08"
                 let ar_cts15m03.fatporto = 8
              else
                  let ar_cts15m03.condicao = "BENEF.OFICINA - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO DE 07"
                  let ar_cts15m03.fatporto = 7
              end if

              if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                 let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                               ar_cts15m03.fatporto
              end if


           when 4
              #---------------------------------------------
              # Motivo DEPARTAMENTO - Veiculo Basico
              #---------------------------------------------
              if ws.ciaempcod = 35 then
                 let ar_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
              else
                 let ar_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
              end if
              let ar_cts15m03.fatporto = ar_cts15m03.aviprvent

           when 5
              #---------------------------------------------
              # Motivo PARTICULAR   - Veiculo Basico
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar PARTICULAR para LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 let ar_cts15m03.condicao = "PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent

           -- Fabrica de Software - Teresinha Silva - OSF 33367
           when 6
              #---------------------------------------------
              # Motivo BENEFICIO OFICINA - Veiculo Basico
              #---------------------------------------------
              let ar_cts15m03.condicao = "TERC.SEGPORTO - FATURAR DIARIAS P/ PORTOSEGURO ATE O LIMITE DO SALDO DE 07"
              let ar_cts15m03.fatporto = 7
              if ar_cts15m03.aviprvent > ar_cts15m03.fatporto then
                 let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent -
                                               ar_cts15m03.fatporto
              end if
           -- OSF 33367

           when 9
              #---------------------------------------------
              # Motivo Ind.Integral  - Veiculo Basico
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar RESERSIVEL para LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 #let ar_cts15m03.condicao = "RESERSIVEL - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                 let ar_cts15m03.condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE 7 DIAS DE SALDO DA CLAUSULA'
                 let ar_cts15m03.condicao = null
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent
           when 0
              #---------------------------------------------
              # Sinistro Clasula 33  - Veiculo Basico
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar RESERSIVEL para LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 let ar_cts15m03.condicao = 'TOTAL DE DIARIAS FATURADAS PARA A PORTO SEGURO'
                 let ar_cts15m03.condicao = null
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent
        end case

     else
        case ws.avialgmtv
           when 1
               if ws.ciaempcod = 1 then # PORTO SEGURO
                  #---------------------------------------------
                  # Motivo SINISTRO - Demais veiculos
                  #---------------------------------------------
                  #let ar_cts15m03.condicao = "SINISTRO - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  let ar_cts15m03.condicao = null
                  let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent
               end if

           when 2
              #---------------------------------------------
              # Motivo PORTO SOCORRO - Demais veiculos
              #---------------------------------------------
              let ar_cts15m03.condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO"
              --let ar_cts15m03.condicao = null
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent

           when 3
              #---------------------------------------------
              # Motivo BENEFICIO OFICINA - Demais veiculos
              #---------------------------------------------
              #let ar_cts15m03.condicao = "BENEF.OFICINA - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              let ar_cts15m03.condicao = null
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent

           when 4
              #---------------------------------------------
              # Motivo DEPARTAMENTOS - Demais veiculos
              #---------------------------------------------
              if ws.ciaempcod = 35 then
                 let ar_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
              else
                 let ar_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
              end if
              let ar_cts15m03.fatporto = ar_cts15m03.aviprvent

           when 5
              #---------------------------------------------
              # Motivo PARTICULAR   - Demais Veiculo
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar PARTICULAR para LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 let ar_cts15m03.condicao = "PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent

           -- Fabrica de Software - Teresinha Silva - OSF 33367
           when 6
              #---------------------------------------------
              # Motivo BENEFICIO OFICINA - Demais veiculos
              #---------------------------------------------
              #let ar_cts15m03.condicao = "TERC.SEGPORTO - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              let ar_cts15m03.condicao = null
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent
           -- OSF 33367

           when 9
              #---------------------------------------------
              # Motivo Ind.Integral  - Demais veiculos
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar Ind.Integral p/ LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 let ar_cts15m03.condicao = "IND.INTEGRAL - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent

           when 0
              #---------------------------------------------
              # Sinistro Clasula 33  - Veiculo Basico
              #---------------------------------------------
              if ws.lcvcod = 2 then ## Tirar RESERSIVEL para LOCALIZA
                 let ar_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
              else
                 let ar_cts15m03.condicao = 'TOTAL DE DIARIAS FATURADAS PARA A PORTO SEGURO'
                 let ar_cts15m03.condicao = null
              end if
              let ar_cts15m03.fatsegurado = ar_cts15m03.aviprvent
        end case
     end if


     #-----------------------
     # Obtem qtde prorrogacao
     #-----------------------
     let ar_cts15m03.prorrogacao = 0
     declare c_prorroga cursor for
      select vclretdat   , vclrethor   , aviprodiaqtd,
             aviprosoldat, aviprosolhor, aviprostt
        from datmprorrog
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano
       order by vclretdat, vclrethor

        initialize ws.vclretdat   , ws.vclrethor   , ws.aviprodiaqtd,
                   ws.aviprosoldat, ws.aviprosolhor, ws.aviprostt to null

     foreach c_prorroga into ws.vclretdat   , ws.vclrethor   ,
                             ws.aviprodiaqtd, ws.aviprosoldat,
                             ws.aviprosolhor, ws.aviprostt

        if ws.aviprostt = "C"  then
           continue foreach
        end if

        let ar_cts15m03.condicao = ar_cts15m03.condicao clipped,
                                   " PRORROGACAO: ",
                                   ws.vclretdat," ", ws.vclrethor,
                                   " PREVISAO DE USO: ",
                                   ws.aviprodiaqtd

        let ar_cts15m03.prorrogacao = ws.aviprodiaqtd
     end foreach

     exit foreach

  end foreach

  #-----------------------
  # Obtem CPF
  #-----------------------
  let ar_cts15m03.cpf = ws.locrspcpfnum using "<<<<<<<<<<&",
                        ws.locrspcpfdig using "<&"

  let ar_cts15m03.observacoes = param.msg1 clipped," ",param.msg2 clipped

  let ws.arquivo = "res",
                   param.atdsrvnum using "&&&&&&&",
                   param.atdsrvano using "&&",
                   ".res"

  whenever error continue
  
  start report  rel_res  to  ws.arquivo

    output to report rel_res(param.atdsrvnum, param.atdsrvano, ar_cts15m03.*)
  finish report rel_res

  let ws.comando = "chmod 777 ", ws.arquivo
  run ws.comando

###  let ws.comando = "rcp ", ws.arquivo," u19:/adat/", ws.arquivo
###  run ws.comando
###
###  let ws.comando = "rcp ", ws.arquivo," u19:/adat/salva/", ws.arquivo
### #WWW  run ws.comando  # salva do arquivo
###

  let ws.comando = "rcp ", ws.arquivo," u03:/home1/produc/geral/", ws.arquivo
  run ws.comando

  let ws.comando = "rcp ", ws.arquivo," u03:/home1/produc/geral/SLV", ws.arquivo
  run ws.comando  # salva do arquivo

  let ws.comando = "rm ", ws.arquivo
  run ws.comando

  whenever error stop

end function  ###  cts15m03_arq

#---------------------------------------------------------------------------
 report rel_res(rr_cts15m03)
#---------------------------------------------------------------------------

 define rr_cts15m03  record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    nom              like datmservico.nom        ,
    avilocnom        like datmavisrent.avilocnom ,
    c24solnom        like datmligacao.c24solnom  ,
    lcvextcod        like datkavislocal.lcvextcod,
    avivclgrp        like datkavisveic.avivclgrp ,
    aviretdat        like datmavisrent.aviretdat ,
    avirethor        like datmavisrent.avirethor ,
    aviprvent        like datmavisrent.aviprvent ,
    fatporto         integer                     ,
    fatsegurado      integer                     ,
    observacoes      char (100)                  ,
    condicao         char (1000)                 ,
    prorrogacao      integer                     ,
    cpf              char (14)
 end record

 define ws_hora      char(05)

 output
    left   margin  000
    right  margin  000
    top    margin  000
    bottom margin  000
    page   length  001

 format
    on every row
       let ws_hora = rr_cts15m03.avirethor
       print column 001, rr_cts15m03.atdsrvnum using "&&&&&&&",
                         rr_cts15m03.atdsrvano using "&&"        ,"|",
                         rr_cts15m03.nom         clipped         ,"|",
                         rr_cts15m03.avilocnom   clipped         ,"|",
                         rr_cts15m03.c24solnom   clipped         ,"|",
                         rr_cts15m03.lcvextcod   clipped         ,"|",
                         rr_cts15m03.avivclgrp   clipped         ,"|",
                         rr_cts15m03.aviretdat   using "ddmmyyyy","|",
                         ws_hora[1,2],ws_hora[4,5]               ,"|",
                         rr_cts15m03.aviprvent   using "<<&"     ,"|",
                         rr_cts15m03.fatporto    using "<<&"     ,"|",
                         rr_cts15m03.fatsegurado using "<<&"     ,"|",
                         rr_cts15m03.observacoes clipped         ,"|",
                         rr_cts15m03.condicao    clipped         ,"|",
                         rr_cts15m03.prorrogacao using "<<&"     ,"|",
                         rr_cts15m03.cpf         clipped         ,"||",
                         ascii(13)

end report  ###  rel_res

{
#-----------------------------------------------------------------------
 report rep_reserva(param)
#-----------------------------------------------------------------------

 define param          record
    atdsrvnum          like datmservico.atdsrvnum ,
    atdsrvano          like datmservico.atdsrvano ,
    dddcod             like datkavislocal.dddcod  ,
    facnum             like datkavislocal.facnum  ,
    faxch1             like datmfax.faxch1        ,
    faxch2             like datmfax.faxch2        ,
    destino            char (24)                  ,
    enviar             char (01)                  ,
    msg1               char (50)                  ,
    msg2               char (50)                  ,
    adcsgrtaxvlr       like datklocadora.adcsgrtaxvlr
 end record

 define r_cts15m03    record
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    ciaempcod         like datmservico.ciaempcod  ,
    atddat            like datmservico.atddat     ,
    atdhor            like datmservico.atdhor     ,
    nom               like datmservico.nom        ,
    avilocnom         like datmavisrent.avilocnom ,
    c24solnom         like datmligacao.c24solnom  ,
    c24soldes         char (15)                   ,
    avivclgrp         like datkavisveic.avivclgrp ,
    descricao         char (70)                   ,
    avivclvlr         like datmavisrent.avivclvlr ,
    locsegvlr         like datmavisrent.locsegvlr ,
    condicao          char (100)                  ,
    saldo             char (30)                   ,
    lcvcod            like datkavislocal.lcvcod   ,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom,
    aviretdat         like datmavisrent.aviretdat ,
    avirethor         like datmavisrent.avirethor ,
    aviprvent         like datmavisrent.aviprvent ,
    avioccdat         like datmavisrent.avioccdat ,
    avirsrgrttip      like datmavisrent.avirsrgrttip,
    cdtoutflg         like datmavisrent.cdtoutflg ,
    locrspcpfnum      like datmavisrent.locrspcpfnum,
    locrspcpfdig      like datmavisrent.locrspcpfdig
 end record

 define ws            record
    succod            like datrservapol.succod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    edsnumref         like datrservapol.edsnumref ,
    aviestcod         like datkavislocal.aviestcod,
    avivclcod         like datmavisrent.avivclcod ,
    avivclmdl         like datkavisveic.avivclmdl ,
    avivcldes         like datkavisveic.avivcldes ,
    avidiaqtd         like datmavisrent.avidiaqtd ,
    limite            like datmavisrent.avidiaqtd ,
    avialgmtv         like datmavisrent.avialgmtv ,
    clscod            like abbmclaus.clscod       ,
    viginc            like abbmclaus.viginc       ,
    vigfnl            like abbmclaus.vigfnl       ,
    cbtcod            like abbmcasco.cbtcod       ,
    c24soltipcod      like datmligacao.c24soltipcod,
    atdfnlflg         like datmservico.atdfnlflg  ,
    lignum            like datrligsrv.lignum      ,
    lcvregprccod      like datkavislocal.lcvregprccod,
    linha             char (70)                      ,
    ciaempcod         like datmservico.ciaempcod  ,
    temcls            smallint
 end record

 define r_cts15m03p   record
    vclretdat         like datmprorrog.vclretdat   ,
    vclrethor         like datmprorrog.vclrethor   ,
    aviprodiaqtd      like datmprorrog.aviprodiaqtd,
    aviprosoldat      like datmprorrog.aviprosoldat,
    aviprosolhor      like datmprorrog.aviprosolhor,
    aviprostt         like datmprorrog.aviprostt
 end record

 define lr_funapol record
        resultado  char(01),
        dctnumseq  decimal(4,0),
        vclsitatu  decimal(4,0),
        autsitatu  decimal(4,0),
        dmtsitatu  decimal(4,0),
        dpssitatu  decimal(4,0),
        appsitatu  decimal(4,0),
        vidsitatu  decimal(4,0)
 end record

 define  l_cod_erro       smallint,
         l_concede_ar     smallint

 output report to  pipe wsgpipe
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58

 format
   on every row

      initialize ws.*          to null
      initialize r_cts15m03.* to null
      initialize lr_funapol   to null

      declare c_cts15m03_002   cursor for
        select datmservico.atdsrvnum    , datmservico.atdsrvano ,
               datmservico.atdsrvorg    , datmservico.ciaempcod ,
               datmservico.atddat       , datmservico.atdhor    ,
               datmservico.nom          , datmservico.atdfnlflg ,
               datmavisrent.lcvcod      , datmavisrent.avivclcod,
               datmavisrent.avivclvlr   , datmavisrent.locsegvlr,
               datmavisrent.avilocnom   , datmavisrent.avidiaqtd,
               datmavisrent.aviestcod   , datmavisrent.aviretdat,
               datmavisrent.avirethor   , datmavisrent.aviprvent,
               datmavisrent.avialgmtv   , datmavisrent.avioccdat,
               datmavisrent.avirsrgrttip, datmavisrent.cdtoutflg,
               datmavisrent.locrspcpfnum, datmavisrent.locrspcpfdig
          from datmservico, datmavisrent
         where datmservico.atdsrvnum  = param.atdsrvnum          and
               datmservico.atdsrvano  = param.atdsrvano          and
               datmservico.atdsrvnum  = datmavisrent.atdsrvnum   and
               datmservico.atdsrvano  = datmavisrent.atdsrvano

      foreach c_cts15m03_002  into r_cts15m03.atdsrvnum,
                                r_cts15m03.atdsrvano,
                                r_cts15m03.atdsrvorg,
                                r_cts15m03.ciaempcod,
                                r_cts15m03.atddat   ,
                                r_cts15m03.atdhor   ,
                                r_cts15m03.nom      ,
                                ws.atdfnlflg        ,
                                r_cts15m03.lcvcod   ,
                                ws.avivclcod        ,
                                r_cts15m03.avivclvlr,
                                r_cts15m03.locsegvlr,
                                r_cts15m03.avilocnom,
                                ws.avidiaqtd        ,
                                ws.aviestcod        ,
                                r_cts15m03.aviretdat,
                                r_cts15m03.avirethor,
                                r_cts15m03.aviprvent,
                                ws.avialgmtv,
                                r_cts15m03.avioccdat,
                                r_cts15m03.avirsrgrttip,
                                r_cts15m03.cdtoutflg,
                                r_cts15m03.locrspcpfnum,
                                r_cts15m03.locrspcpfdig

         let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

         select c24soltipcod, c24solnom
           into ws.c24soltipcod     ,
                r_cts15m03.c24solnom
           from datmligacao
          where lignum = ws.lignum

         select c24soltipdes
           into r_cts15m03.c24soldes
           from datksoltip
                where c24soltipcod = ws.c24soltipcod

         let r_cts15m03.descricao = "*** NAO CADASTRADO ***"

         select avivclmdl   , avivcldes   , avivclgrp
           into ws.avivclmdl, ws.avivcldes, r_cts15m03.avivclgrp
           from datkavisveic
          where lcvcod    = r_cts15m03.lcvcod  and
                avivclcod = ws.avivclcod

         let r_cts15m03.descricao = ws.avivclmdl clipped," (",
                                    ws.avivcldes clipped,")"

#-----------------------------------------------------------------------
# Se veiculo for grupo A, substituir a descricao do veiculo por BASICO
#-----------------------------------------------------------------------
         if r_cts15m03.avivclgrp = "A"  then
            let r_cts15m03.descricao =  "BASICO (", ws.avivcldes clipped,")"
         end if

         let r_cts15m03.aviestnom = "*** NAO CADASTRADA ***"

         select lcvextcod, aviestnom, lcvregprccod
           into r_cts15m03.lcvextcod,
                r_cts15m03.aviestnom,
                ws.lcvregprccod
           from datkavislocal
          where lcvcod    = r_cts15m03.lcvcod  and
                aviestcod = ws.aviestcod

         let l_cod_erro = 0
         let l_concede_ar = false


         select succod   , aplnumdig   , itmnumdig   , edsnumref
           into ws.succod, ws.aplnumdig, ws.itmnumdig, ws.edsnumref
           from datrservapol
          where atdsrvnum = r_cts15m03.atdsrvnum  and
                atdsrvano = r_cts15m03.atdsrvano

         if r_cts15m03.ciaempcod = 1 then
            call f_funapol_ultima_situacao (ws.succod,
                                         ws.aplnumdig,
                                         ws.itmnumdig)

              returning lr_funapol.*
         end if

         # --> CONFORME SOLICITACAO DA ROSANA CT24HS, INIBIR A
         # VERIFICACAO DE VIGENCIA P/CONCESSAO DO AR CONDICIONADO
         # DATA SOLICITACAO: 22/03/2006

         #call cts15m14_ver_ar_cond(ws.succod,
         #                          ws.aplnumdig,
         #                          lr_funapol.autsitatu,
         #                          ws.itmnumdig,
         #                          ws.edsnumref)

         #    returning l_cod_erro, l_concede_ar


         let l_concede_ar = true

         if r_cts15m03.avivclgrp = "A" or
            (r_cts15m03.avivclgrp = "B" and l_concede_ar = true) then
            case ws.avialgmtv

#-----------------------------------------------------------------------
# Motivo SINISTRO - Veiculo Basico
#-----------------------------------------------------------------------
               when 1
                     select succod   , aplnumdig   , itmnumdig   , edsnumref
                       into ws.succod, ws.aplnumdig, ws.itmnumdig, ws.edsnumref
                       from datrservapol
                      where atdsrvnum = r_cts15m03.atdsrvnum  and
                            atdsrvano = r_cts15m03.atdsrvano

                     if sqlca.sqlcode = notfound  then
                        initialize ws.succod, ws.aplnumdig, ws.itmnumdig to null
                        if r_cts15m03.ciaempcod = 35 then
                           case ws_clausula

                              when "58A" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 05 DIARIAS"
                              when "58B" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 10 DIARIAS"
                              when "58C" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                              when "58D" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                              when "58E" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 05 DIARIAS"
                              when "58F" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 10 DIARIAS"
                              when "58G" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                              when "58H" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                              when "58I" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 07 DIARIAS"
                              when "58J" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                              when "58K" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                              when "58L" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 07 DIARIAS"
                              when "58M" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 15 DIARIAS"
                              when "58N" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE 30 DIARIAS"
                              otherwise
                                 let r_cts15m03.condicao = null
                           end case
                        else
                         case ws_clausula
                           when "26A" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                           when "26B" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                           when "26C" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                           when "26D" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                           ## psi201154
                           when "26E" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                           when "26F" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                           when "26G" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                           ## psi201154
                           when "80A" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 15 DIARIAS"
                           when "80B" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 30 DIARIAS"
                           when "80C" let r_cts15m03.condicao = "CLAUSULA ", ws_clausula, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE 07 DIARIAS"
                           otherwise
                               #let r_cts15m03.condicao = "SINISTRO - FATURAR 1a. DIARIA PARA PORTO SEGURO"
                               let r_cts15m03.condicao = null
                         end case
                        end if
                     else
                     #-----------------------------------------------------------------------
                     # Verifica existencia da clausula Carro Extra
                     #-----------------------------------------------------------------------
                        if r_cts15m03.ciaempcod = 35 then
                           call cts44g01_claus_azul(ws.succod,
                                                    531,
                                                    ws.aplnumdig,
                                                    ws.itmnumdig)
                                   returning ws.temcls,ws.clscod
                        else
                           call ctx01g01_claus_novo (ws.succod,
                                                ws.aplnumdig,
                                                ws.itmnumdig,
                                                r_cts15m03.avioccdat,
                                                true)
                                  returning  ws.clscod, ws.viginc, ws.vigfnl
                        end if
                        if ws.clscod is not null    and
                           (ws.clscod[1,2] = "26"   or
                            ws.clscod[1,2] = "80"   or
                            ws.clscod[1,2] = "44"   or
                            ws.clscod[1,2] = "48"   or
                            ws.clscod[1,2] = "58")  then
                           if ws.atdfnlflg = "N"    then
                              call ctx01g00_saldo_novo (ws.succod   ,
                                                   ws.aplnumdig,
                                                   ws.itmnumdig,
                                                   "", "",
                                                   r_cts15m03.avioccdat,
                                                   1, true             ,
                                                   r_cts15m03.ciaempcod,
                                                   ws.avialgmtv,
                                                   ws.c24astcod )
                                         returning ws.limite, ws.avidiaqtd
                           else
                              call ctx01g00_saldo_novo (ws.succod      ,
                                                   ws.aplnumdig   ,
                                                   ws.itmnumdig   ,
                                                   param.atdsrvnum,
                                                   param.atdsrvano,
                                                   r_cts15m03.avioccdat,
                                                   1, true             ,
                                                   r_cts15m03.ciaempcod,
                                                   ws.avialgmtv,
                                                   ws.c24astcod )
                                         returning ws.limite, ws.avidiaqtd
                           end if

                           if ws.avidiaqtd > 0  then
                              let r_cts15m03.saldo    = ws.avidiaqtd using "&&"," DIARIA(S) GRATUITA(S)"
                              if r_cts15m03.ciaempcod = 35 then
                                 let r_cts15m03.condicao = "CLAUSULA ", ws.clscod, " - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO"
                              else
                                 let r_cts15m03.condicao = "CLAUSULA ", ws.clscod, " - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO"
                              end if
                           else
                              initialize r_cts15m03.saldo  to null
                              #let r_cts15m03.condicao = "SINISTRO - FATURAR 1a. DIARIA PARA PORTO E DEMAIS PARA O USUARIO"
                              let r_cts15m03.condicao = null
                           end if
                        else
                           #let r_cts15m03.condicao = "SINISTRO - FATURAR 1a. DIARIA PARA PORTO E DEMAIS PARA O USUARIO"
                           let r_cts15m03.condicao = null
                        end if
                     end if

#-----------------------------------------------------------------------
# Motivo PORTO SOCORRO - Veiculo Basico
#-----------------------------------------------------------------------
               when 2
                  let r_cts15m03.condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO"
                  --let r_cts15m03.condicao = null

#-----------------------------------------------------------------------
# Motivo BENEFICIO OFICINA - Veiculo Basico
#-----------------------------------------------------------------------
               when 3
                  if r_cts15m03.ciaempcod = 35 then
                     let r_cts15m03.saldo    = "8 DIARIAS GRATUITAS"
                     let r_cts15m03.condicao = "BENEFICIO - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO"
                  else
                     let r_cts15m03.saldo    = "7 DIARIAS GRATUITAS"
                     let r_cts15m03.condicao = "BENEF.OFICINA - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO"
                  end if
#-----------------------------------------------------------------------
# Motivo DEPARTAMENTO - Veiculo Basico
#-----------------------------------------------------------------------
               when 4
                  if r_cts15m03.ciaempcod = 35 then
                     let r_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
                  else
                     let r_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
                  end if
#-----------------------------------------------------------------------
# Motivo PARTICULAR   - Veiculo Basico
#-----------------------------------------------------------------------
               when 5
                  if r_cts15m03.lcvcod = 2 then ## Tirar PARTICULAR para LOCALIZA
                     let r_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  else
                     let r_cts15m03.condicao = "PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  end if

               -- Fabrica de Software - Teresinha Silva - OSF 33367
               when 6
                  let r_cts15m03.saldo    = "7 DIARIAS GRATUITAS"
                  let r_cts15m03.condicao = "TERC.SEGPORTO -  FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO"
               -- OSF 33367 --

#-----------------------------------------------------------------------
# Motivo Ind.Integral  - Veiculo Basico
#-----------------------------------------------------------------------
               when 9
                  if r_cts15m03.lcvcod = 2 then ## Tirar RESERSIVEL para LOCALIZA
                     let r_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  else
                     #let r_cts15m03.condicao = "RESERSIVEL - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                     let r_cts15m03.condicao = null
                  end if
            end case

         else
#-----------------------------------------------------------------------
# Motivo SINISTRO - Demais veiculos
#-----------------------------------------------------------------------
            case ws.avialgmtv
               when 1
                  #let r_cts15m03.condicao = "SINISTRO - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                   let r_cts15m03.condicao = null
#-----------------------------------------------------------------------
# Motivo PORTO SOCORRO - Demais veiculos
#-----------------------------------------------------------------------
               when 2
                  let r_cts15m03.condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO"
                  --let r_cts15m03.condicao = null
#-----------------------------------------------------------------------
# Motivo BENEFICIO OFICINA - Demais veiculos
#-----------------------------------------------------------------------
               when 3
                  let r_cts15m03.condicao = null
                  #let r_cts15m03.condicao = "BENEF.OFICINA - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
#-----------------------------------------------------------------------
# Motivo DEPARTAMENTOS - Demais veiculos
#-----------------------------------------------------------------------
               when 4
                  if r_cts15m03.ciaempcod = 35 then
                     let r_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
                  else
                     let r_cts15m03.condicao = "DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO (PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)"
                  end if
#-----------------------------------------------------------------------
# Motivo PARTICULAR   - Demais Veiculo
#-----------------------------------------------------------------------
               when 5
                  if r_cts15m03.lcvcod = 2 then ## Tirar PARTICULAR para LOCALIZA
                     let r_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  else
                     let r_cts15m03.condicao = "PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  end if

               -- OSF 33367
               when 6
                  #let r_cts15m03.condicao = "TERC.SEGPORTO - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  #let  r_cts15m03.condicao = null
                  #let r_cts15m03.saldo    = "7 DIARIAS GRATUITAS"
                  let r_cts15m03.condicao = "TERC.SEGPORTO -  FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO"
               -- OSF 33367


#-----------------------------------------------------------------------
# Motivo Ind.Integral  - Demais veiculos
#-----------------------------------------------------------------------
               when 9
                  if r_cts15m03.lcvcod = 2 then ## Tirar Ind.Integral p/ LOCALIZA
                     let r_cts15m03.condicao = "FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  else
                     let r_cts15m03.condicao = "Ind.Integral - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
                  end if
            end case
         end if

      end foreach

      if param.enviar = "F"   then
         if wsgfax = "GSF"  then
#-----------------------------------------------------------------------
# Checa caracteres invalidos para o GSFAX
#-----------------------------------------------------------------------
            call cts02g00(param.destino) returning param.destino

            if param.dddcod     > 0099 then
               print column 001, param.dddcod using "&&&&"; #
            else                                            #---> Codigo do DDD
               print column 001, param.dddcod using "&&&";  #
            end if
            if param.facnum > 9999999  then
               print column 001, param.facnum using "&&&&&&&&";  #
            else                                                 #
               if param.facnum > 999999  then                    #---> Numero
                  print column 001, param.facnum using "&&&&&&&";#     do FAX
               else                                              #
                  print column 001, param.facnum using "&&&&&&"; #
               end if
            end if

            print column 001                        ,
            "@"                                     ,  #---> Delimitador
            param.destino                           ,  #---> Destinat. Cx Postal
            "*CTRS"                                 ,  #---> Sistema/Subsistema
            param.faxch1   using "&&&&&&&&&&"       ,  #---> Numero/Ano Servico
            param.faxch2   using "&&&&&&&&&&"       ,  #---> Sequencia
            "@"                                     ,  #---> Delimitador
            param.destino                           ,  #---> Destinat.(Informix)
            "@"                                     ,  #---> Delimitador
            "CENTRAL 24 HORAS"                      ,  #---> Quem esta enviando
            "@"                                     ,  #---> Delimitador
            "PORTO.TIF"                             ,  #---> Arquivo Logotipo
            "@"                                     ,  #---> Delimitador
            "semcapa"                                  #---> Nao tem cover page
         end if

         if wsgfax = "VSI"  then
            print column 001, "@+IMAGE[porto.tif]"
            skip 7 lines
         end if
      else
         print column 001, "Enviar para: ", param.destino, "    Fax: ", "(", param.dddcod clipped, ")", param.facnum using "<<<<<<<&"
         skip 2 lines
      end if

      if r_cts15m03.ciaempcod = 35 then # AZUL SEGUROS
         print column 006, "RESERVA DE VEICULO - AZUL SEGUROS",
               column 050, "Data: ", r_cts15m03.atddat,
               column 070, "Hora: ", r_cts15m03.atdhor
         print column 006, "================================="
      else
         print column 006, "RESERVA DE VEICULO - PORTO SEGURO",
               column 050, "Data: ", r_cts15m03.atddat,
               column 070, "Hora: ", r_cts15m03.atdhor
         print column 006, "================================="
      end if
      skip 1 line

      print column 006, "No. SERVICO.: ", r_cts15m03.atdsrvorg using "&&"    ,
                                   "/",r_cts15m03.atdsrvnum using "&&&&&&&",
                                   "-",r_cts15m03.atdsrvano using "&&"    ;

      if r_cts15m03.lcvcod = 2  then    ## Locadora LOCALIZA: informar codigo
         print column 050, "NOSSO CODIGO: 634-546"
      else
         if r_cts15m03.lcvcod = 4  then ## Locadora Hertz: informar codigo
            print column 050, "NOSSO CODIGO: B02885"
         else
            print " "
         end if
      end if

      skip 1 lines
      print column 006, "Autorizamos a locacao de veiculo conforme as seguintes condicoes:"
      skip 1 lines
      print column 001, "______________________________ DADOS DO LOCATARIO ______________________________"
      skip 1 line
      print column 001, "Segurado.: ", r_cts15m03.nom
      skip 1 line
      print column 001, "Usuario..: ", r_cts15m03.avilocnom;
      if r_cts15m03.locrspcpfnum is not null then
         print column 048, "CPF....: ", r_cts15m03.locrspcpfnum using "#########",
                                   "-", r_cts15m03.locrspcpfdig using "##"
      else
         print " "
      end if
      skip 1 line
      print column 001, "Solicit..: ", r_cts15m03.c24solnom,
            column 048, "Tipo...: "   , r_cts15m03.c24soldes
      skip 1 line

      print column 001, "________________________ DADOS DO VEICULO PREFERENCIAL _________________________"
      skip 1 line

      let r_cts15m03.avivclvlr = r_cts15m03.avivclvlr + r_cts15m03.locsegvlr

      print column 001, "Grupo....: ", r_cts15m03.avivclgrp
      skip 1 line
      print column 001, "Veiculo..: ", r_cts15m03.descricao
      skip 1 line
      #print column 001, "Diaria...: R$ ", r_cts15m03.avivclvlr
      #                   using "<<<,<<<,<<<.<<"
      #skip 1 line
      let ws.linha = r_cts15m03.condicao[1,66]
      print column 001, "Condicao.: ", ws.linha clipped
      if length(r_cts15m03.condicao)> 66 then
        skip 1 line
        let ws.linha = r_cts15m03.condicao[67,100]
        print column 012, ws.linha
      end if

      if r_cts15m03.saldo is not null then
         skip 1 line
         print column 001, "Saldo....: ", r_cts15m03.saldo
      end if

      skip 1 line
      print column 001, "Loja.....: ", r_cts15m03.lcvextcod,
                                " - ", r_cts15m03.aviestnom
      skip 1 line
      print column 001, "Retirada.: ", r_cts15m03.aviretdat,
            column 028, "Hora..: "   , r_cts15m03.avirethor,
            column 048, "Prev. Uso: ", r_cts15m03.aviprvent using "&&"," Dia(s)"
      skip 1 line
      if param.msg1 is not null  or
         param.msg2 is not null  then
         print column 001, "_________________________________ OBSERVACOES __________________________________"
         skip 1 line
         print column 001, param.msg1
         print column 001, param.msg2
         skip 1 line
      end if
      print column 001, "__________________________ CONSIDERACOES IMPORTANTES ___________________________"
      skip 1 line
      print column 001, "- COMBUSTIVEL, HORAS E TAXAS EXTRAS (PROTECAO OPCIONAL) POR CONTA DO USUARIO."

#     if r_cts15m03.avivclgrp = "A"  then
#        case r_cts15m03.lcvcod
#           when 1      ## Locadora AVIS
#              print column 001, "- FATURAR PARA PORTO SEGURO QUALQUER EXCEDENTE DO VALOR DA DIARIA ($ ", r_cts15m03.avivclvlr using "<<<,<<<,<<<.<<", "), "
#              print column 001, "  SOMENTE NAS LOJAS FRANQUEADAS."
#           when 2      ## Locadora LOCALIZA
#              print column 001, "- FATURAR PARA PORTO SEGURO QUALQUER EXCEDENTE DO VALOR DA DIARIA ($ ", r_cts15m03.avivclvlr using "<<<,<<<,<<<.<<", "), "
#              print column 001, "  E QUILOMETRAGEM (SOMENTE NAS LOJAS FRANQUEADAS)."
#        end case
#     end if

      print column 001, "- APOS O RECEBIMENTO DESTE, A LOCADORA DISPOE DE 0:30MIN. PARA NEGAR A RESERVA"
      print column 001, "  POR FALTA DE VEICULOS."

#     print column 001, "- TELEFONE PARA RETORNO: (011) 226-5408 - PORTO SEGURO"
#     print column 001, "- TELEFONE PARA RETORNO: (011) 226-5155 - PORTO SEGURO"
#     print column 001, "- TELEFONE PARA RETORNO: (011) 224-6068 - PORTO SEGURO"
#     print column 001, "- TELEFONE PARA RETORNO: (011) 3366-6629 - PORTO SEGURO"
      if r_cts15m03.ciaempcod = 35 then # AZUL SEGUROS
         print column 001, "- TELEFONE PARA RETORNO: (011) 3366-3629 "
      else
         print column 001, "- TELEFONE PARA RETORNO: (011) 3366-3629 - PORTO SEGURO"
      end if

      case r_cts15m03.avirsrgrttip
        when 1      ## Locacao por CARTAO CREDITO
           print column 001, "- GARANTIA DISPONIVEL NO CARTAO DE CREDITO DE R$ 800,00."
          #print column 001, "- GARANTIA DISPONIVEL NO CARTAO DE CREDITO DE R$ 500,00."
        when 2      ## Locacao por CHEQUE CAUCAO
            if r_cts15m03.avivclgrp = "A" or
               r_cts15m03.avivclgrp = "B" then
               print column 001, "- APRESENTACAO DE CREDITO COM CHEQUE CAUCAO NO VALOR DE R$ 800,00"
            else
               print column 001, "- APRESENTACAO DE CREDITO COM CHEQUE CAUCAO"
            end if
      end case

      case r_cts15m03.avirsrgrttip
        when 1      ## Locacao por CARTAO CREDITO
           print column 001, "- LOCACAO SERA FEITA ATRAVES DE CARTAO DE CREDITO"
        when 2      ## Locacao por CHEQUE CAUCAO
           print column 001, "- LOCACAO SERA FEITA ATRAVES DE CHEQUE CAUCAO"
      end case

      if r_cts15m03.cdtoutflg is not null and
         r_cts15m03.cdtoutflg =  "S"      then
         print column 001, "- PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)"
      end if

      if param.adcsgrtaxvlr is not null and
         param.adcsgrtaxvlr <> 0        then
         if r_cts15m03.lcvcod = 2  and    # Nao opera taxa isencao
            ws.lcvregprccod   = 2  then   # algumas lojas da Localiza.

            ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
            ### print column 001, "- A LOJA NAO OPERA COM TAXA DE ISENCAO DE FRANQUIA"

            print column 001, "- A LOJA NAO OPERA COM TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"
         else

            ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
            ### print column 001, "- A LOCADORA OFERECERA TAXA DE ISENCAO DE FRANQUIA (COBERTURA DE RISCO),"
            ### print column 001, "  OPTATIVA, AO CUSTO DE R$ ",
            ###                    param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA."

            print column 001, "- A LOCADORA OFERECERA TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"
            print column 001, " (COBERTURA DE RISCO) OPTATIVA, AO CUSTO DE R$ ",
                              param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA."

         end if
      end if

      skip 1 line
      print column 001, "_________________________________ PRORROGACOES _________________________________"
      skip 1 line

      declare c_cts15m03_003 cursor for
           select vclretdat   , vclrethor   , aviprodiaqtd,
                  aviprosoldat, aviprosolhor, aviprostt
             from datmprorrog
            where atdsrvnum = r_cts15m03.atdsrvnum   and
                  atdsrvano = r_cts15m03.atdsrvano
            order by vclretdat, vclrethor

        initialize r_cts15m03p.* to null

        foreach c_cts15m03_003 into r_cts15m03p.vclretdat   ,
                               r_cts15m03p.vclrethor   ,
                               r_cts15m03p.aviprodiaqtd,
                               r_cts15m03p.aviprosoldat,
                               r_cts15m03p.aviprosolhor,
                               r_cts15m03p.aviprostt

            print column 001, "==> EM ", r_cts15m03p.aviprosoldat,
                                 " AS ", r_cts15m03p.aviprosolhor;
            if r_cts15m03p.aviprostt = "C"  then
               print "   *** CANCELADA! ***"
            else
               print " "
            end if
            skip 1 line
            print column 001, "    DATA DE PRORROGACAO: ", r_cts15m03p.vclretdat
            print column 001, "    HORA DE PRORROGACAO: ", r_cts15m03p.vclrethor
            print column 001, "    PREVISAO DE USO....: ", r_cts15m03p.aviprodiaqtd using "<<<<<<", " DIA(S)"
            skip 1 line
        end foreach

        if r_cts15m03p.aviprosoldat is null then
           print column 001, "NENHUMA."
        end if

        if param.enviar <> "F"   then
           print ascii(12)
        end if

end report }

#-----------------------------------------------------------------------
 function cts15m03_hist(hist)
#-----------------------------------------------------------------------

 define hist     record
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano,
    msg1         char(50)                  ,
    msg2         char(50)
 end record

 define ws       record
    c24txtseq    like datmservhist.c24txtseq,
    time         char(08),
    hora         char(05),
    msg          char(50)
 end record

 define l_ret      smallint,
        l_mensagem char(60)

        initialize  ws.*  to  null

let ws.time = time
let ws.hora = ws.time[1,5]

 #BURINI# select max (c24txtseq)
 #BURINI#   into ws.c24txtseq
 #BURINI#   from datmservhist
 #BURINI#  where atdsrvnum = hist.atdsrvnum   and
 #BURINI#        atdsrvano = hist.atdsrvano
 #BURINI#
 #BURINI# if ws.c24txtseq  is null   then
 #BURINI#    let ws.c24txtseq = 0
 #BURINI# end if
 #BURINI# let ws.c24txtseq = ws.c24txtseq + 1

 #BEGIN WORK
    #BURINI# insert into datmservhist
    #BURINI#             (atdsrvnum, atdsrvano, c24txtseq, c24funmat,
    #BURINI#              ligdat   , lighorinc, c24srvdsc)
    #BURINI#      values (hist.atdsrvnum, hist.atdsrvano, ws.c24txtseq , g_issk.funmat,
    #BURINI#              today         , ws.hora       , hist.msg1)
    #BURINI#

    call ctd07g01_ins_datmservhist(hist.atdsrvnum,
                                   hist.atdsrvano,
                                   g_issk.funmat,
                                   hist.msg1,
                                   today,
                                   ws.hora,
                                   g_issk.empcod,
                                   g_issk.usrtip)

         returning l_ret,
                   l_mensagem

    if l_ret <> 1 then
       error l_mensagem, " - CTS15M03 - AVISE A INFORMATICA!"
       #rollback work
       return
    end if

    #BURINI#
    #BURINI# let ws.c24txtseq = ws.c24txtseq + 1
    #BURINI#
    #BURINI# insert into datmservhist
    #BURINI#             (atdsrvnum, atdsrvano, c24txtseq, c24funmat,
    #BURINI#              ligdat   , lighorinc, c24srvdsc)
    #BURINI#      values (hist.atdsrvnum, hist.atdsrvano, ws.c24txtseq , g_issk.funmat,
    #BURINI#              today         , ws.hora       , hist.msg2)
    #BURINI#

    call ctd07g01_ins_datmservhist(hist.atdsrvnum,
                                   hist.atdsrvano,
                                   g_issk.funmat,
                                   hist.msg2,
                                   today,
                                   ws.hora,
                                   g_issk.empcod,
                                   g_issk.usrtip)

         returning l_ret,
                   l_mensagem

    if l_ret <> 1 then
       error l_mensagem, " - CTS15M03 - AVISE A INFORMATICA!"
       #rollback work
       return
    end if

    if sqlca.sqlcode <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao do historico! AVISE A INFORMATICA!"
       #rollback work
       return
    end if
 #COMMIT WORK

end function  ### cts15m03_hist
