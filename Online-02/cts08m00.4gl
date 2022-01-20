#############################################################################
# Nome do Modulo: CTS08M00                                            Pedro #
#                                                                   Marcelo #
# Pedido de 2a. via de cartao de protecao total                    Mar/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 02/07/1999  PSI 8247-3   Gilberto     Substituicao da tabela APAM2VIA pe- #
#                                       la tabela ABAM2VIA.                 #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 8247-3   Wagner       Acesso ao modulo apgt2vfnc_ct24h    #
#                                       para verificacao da ABAM2VIA.       #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 06/09/2001  PSI 135070   Raji         Inclusao solicitacao 2a via aplolice#
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 19/11/2003  RSantos - OSF 28983       Abertura de tela para digitacao     #
#                                       do novo endereco                    #
#---------------------------------------------------------------------------#
# 09/01/2004  PSI 172421 OSF.30937   Sonia     Adendo da alteracao efetuada #
#                                              OSF 28983.                   #
#---------------------------------------------------------------------------#
# 16/11/2004  CT 260487   Katiucia      Buscar cidade mesmo incompleta      #
#---------------------------------------------------------------------------#
# 02/02/2006  Zeladoria   Priscila      Buscar data e hora do banco de dados#
#---------------------------------------------------------------------------#
# 21/12/2006  Priscila         CT         Chamar funcao especifica para     #
#                                         insercao em datmlighist           #
#---------------------------------------------------------------------------#
# 14/10/2008  PSI 223689  Roberto         Inclusao da funcao figrc072():    #
#                                         essa funcao evita que o programa  #
#                                         caia devido ha uma queda da       #
#                                         instancia da tabela de origem para#
#                                         a tabela de replica               #
#                                                                           #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica  PSI       Alteracao                             #
# ---------- -------------  --------- --------------------------------------#
#                                                                           #
# 14/02/2007 Saulo,Meta     AS130087  Migracao para a versao 7.32           #
#                                                                           #
#---------------------------------------------------------------------------#
#                                                                           #
# 27/11/2008 Carla Rampazzo PSI230650 Relacionar Ligacao x Atendimento      #
#                                     atraves de ctd25g00_insere_atendimento#
#---------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada#
#                                          por ctd25g00                     #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                       projeto sucursal smallint        #
#---------------------------------------------------------------------------#
# 09/09/2015 Luiz Vieira                   Chamado 579484                   #
#---------------------------------------------------------------------------#
# 15/09/2015 Alberto                       Chamado 596385                   #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

#-----------------------------------------------------------
 function cts08m00()
#-----------------------------------------------------------

 define d_cts08m00  record
        c24solnom   like datmligacao.c24solnom,
        nom         like datmservico.nom,
        doctxt      char (32),
        corsus      like datmservico.corsus,
        cornom      like datmservico.cornom,
        cvnnom      char (19),
        vclcoddig   like datmservico.vclcoddig,
        vcldes      like datmservico.vcldes,
        vclanomdl   like datmservico.vclanomdl,
        vcllicnum   like datmservico.vcllicnum,
        vclcordes   char (11),
        c24astcod   like datkassunto.c24astcod,
        c24astdes   char (55),
        endereco    char (65),
        endbrr      like gsakend.endbrr,
        endcid      like gsakend.endcid,
        endufd      like gsakend.endufd,
        endcep      like gsakend.endcep,
        endnum      like datmsegviaend.endnum, # RSantos - OSF 28983
        endcmp      like datmsegviaend.endcmp, # RSantos - OSF 28983
        endlgdtip   like gsakend.endlgdtip,    # RSantos - OSF 28983
        endcepcmp   like gsakend.endcepcmp,
        confirma    char (01)
 end record

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        cartao          char(1)                    ,
        segapol         char(1)                    ,
        prgcod          smallint                   ,

        vigfnl          like abamapol.vigfnl,
        aplstt          like abamapol.aplstt,
        dddcod          like gsakend.dddcod,
        teltxt          like gsakend.teltxt,
        endlgd          like gsakend.endlgd,
        endnum          like gsakend.endnum,
        endcmp          like gsakend.endcmp,
        endcep          like gsakend.endcep,    # RSantos - OSF 28983
        endcepcmp       like gsakend.endcepcmp, # RSantos - OSF 28983
        cidcod          like glakcid.cidcod   , # RSantos - OSF 28983
        brrcod          like glakbrr.brrcod   , # RSantos - OSF 28983
        cod             integer               , # RSantos - OSF 28983
        lgdnom          like glaklgd.lgdnom   , #
        itmstt          like abbmdoc.itmstt,
        segnumdig       like abbmdoc.segnumdig,
        vclchsinc       like abbmveic.vclchsinc,
        vclchsfnl       like abbmveic.vclchsfnl,
        contador        smallint,
        retflg          smallint,
        msgtxt          char (40),
        confirma        char (01),
        msglog          char(80)
 end record

 define l_historico record
        cep         char(09)
       ,endereco    char(80)
       ,complemento char(50)
       ,bairro      char(30)
       ,cidade      char(40)
 end record

 define
   l_endcid         char(21)
  ,l_endcep         like gsakend.endcep
  ,l_endcepcmp      like gsakend.endcepcmp

 define l_mensagem  char(50)

 define l_data      date,
        l_hora2     datetime hour to minute

	initialize  d_cts08m00.*  to  null

	initialize  ws.*  to  null
	initialize  l_historico.*  to  null

 let l_mensagem = null
 if g_documento.succod     is null   or
    g_documento.aplnumdig  is null   or
    g_documento.itmnumdig  is null   then
    error " Parametro nao informado. AVISE A INFORMATICA!"
    return
 end if

 initialize d_cts08m00.*   to null
 initialize ws.*           to null

 #------------------------------------------------------
 # Busca informacoes sobre o item
 #------------------------------------------------------
 select segnumdig,
        itmstt
   into ws.segnumdig,
        ws.itmstt
   from abbmdoc
  where abbmdoc.succod    = g_documento.succod       and
        abbmdoc.aplnumdig = g_documento.aplnumdig    and
        abbmdoc.itmnumdig = g_documento.itmnumdig    and
        abbmdoc.dctnumseq = g_funapol.dctnumseq

 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode, ") na leitura do documento. AVISE A INFORMATICA!"
    return
 end if

 #------------------------------------------------------
 # Busca informacoes sobre a apolice
 #------------------------------------------------------
 select vigfnl,
        aplstt
   into ws.vigfnl,
        ws.aplstt
   from abamapol
  where abamapol.succod    = g_documento.succod     and
        abamapol.aplnumdig = g_documento.aplnumdig

 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode, ") na leitura da apolice. AVISE A INFORMATICA!"
    return
 end if

 #------------------------------------------------------
 # Busca endereco do sergurado
 #------------------------------------------------------
 select endlgd,
        endnum,
        endcmp,
        endbrr,
        endcid,
        endufd,
        endcep,
        endcepcmp,
        endlgdtip # RSantos - OSF 28983
   into ws.endlgd,
        ws.endnum,
        ws.endcmp,
        d_cts08m00.endbrr,
        d_cts08m00.endcid,
        d_cts08m00.endufd,
        d_cts08m00.endcep,
        d_cts08m00.endcepcmp,
        d_cts08m00.endlgdtip # RSantos - OSF 28983
   from gsakend
  where gsakend.segnumdig = ws.segnumdig    and
        gsakend.endfld    = "1"

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na leitura do endereco. AVISE A INFORMATICA!"
    return
 end if

 let d_cts08m00.endereco = ws.endlgd clipped, " ",
                           ws.endnum clipped, " ",
                           ws.endcmp

let d_cts08m00.endnum = ws.endnum
let d_cts08m00.endcmp = ws.endcmp
 #------------------------------------------------------
 # Exibe dados na tela
 #------------------------------------------------------
 open window cts08m00 at 04,02 with form "cts08m00"
                      attribute(form line 1)

 let d_cts08m00.c24solnom    = g_documento.solnom
 let d_cts08m00.c24astcod    = g_documento.c24astcod

 let d_cts08m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                  " ", g_documento.ramcod    using "&&&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<& &"

 call c24geral8(d_cts08m00.c24astcod) returning d_cts08m00.c24astdes

 call cts05g00 (g_documento.succod,
                g_documento.ramcod   ,
                g_documento.aplnumdig,
                g_documento.itmnumdig)
      returning d_cts08m00.nom,
                d_cts08m00.corsus,
                d_cts08m00.cornom,
                d_cts08m00.cvnnom,
                d_cts08m00.vclcoddig,
                d_cts08m00.vcldes,
                d_cts08m00.vclanomdl,
                d_cts08m00.vcllicnum,
                ws.vclchsinc,
                ws.vclchsfnl,
                d_cts08m00.vclcordes

 display by name d_cts08m00.*
 display by name d_cts08m00.c24solnom attribute (reverse)
 display by name d_cts08m00.cvnnom    attribute (reverse)

 select prgcod
   into ws.prgcod
   from datkassunto
  where c24astcod = d_cts08m00.c24astcod

 let ws.cartao  = "N"
 let ws.segapol = "N"
 if ws.prgcod = 21 then
    let ws.segapol = "S"
    let ws.cartao  = "S"
 else
    let ws.cartao  = "S"
 end if

 input by name d_cts08m00.endcep     # RSantos - OSF 28983
              ,d_cts08m00.endcepcmp  #
              ,d_cts08m00.endlgdtip  #
              ,d_cts08m00.endereco   #
              ,d_cts08m00.endnum     #
              ,d_cts08m00.endcmp     #
              ,d_cts08m00.endbrr     #
              ,d_cts08m00.endcid     #
              ,d_cts08m00.endufd     #
              ,d_cts08m00.confirma
               without defaults

   before field endcep
          display by name d_cts08m00.endcep attribute (reverse)
          let ws.endcep    = d_cts08m00.endcep
          let ws.endcepcmp = d_cts08m00.endcepcmp
	  let ws.lgdnom    = d_cts08m00.endereco

    let d_cts08m00.confirma = 'N'
    next field confirma
   after field endcep
         display by name d_cts08m00.endcep

   before field endcepcmp
          display by name d_cts08m00.endcepcmp attribute (reverse)

   after field endcepcmp
         display by name d_cts08m00.endcepcmp

         if d_cts08m00.endcep is not null    and
            d_cts08m00.endcep <> " "         and
            d_cts08m00.endcepcmp is not null and
            d_cts08m00.endcepcmp <> " "      then

            if d_cts08m00.endcep <> ws.endcep       or
               d_cts08m00.endcepcmp <> ws.endcepcmp then

               whenever error continue
                 select lgdtip
                       ,lgdnom
                       ,cidcod
                       ,brrcod
                   into d_cts08m00.endlgdtip
                       ,d_cts08m00.endereco
                       ,ws.cidcod
                       ,ws.brrcod
                   from glaklgd
                  where lgdcep    = d_cts08m00.endcep
                    and lgdcepcmp = d_cts08m00.endcepcmp
               whenever error stop

               if sqlca.sqlcode = 100 then
                  error "Cep nao cadastrado"
                  next field endcep
               end if

               # Acessos sem controle de erros conforme solicitacao
               # da analista Ligia Mattge
               select cidnom
                     ,ufdcod
                 into d_cts08m00.endcid
                     ,d_cts08m00.endufd
                 from glakcid
                where cidcod = ws.cidcod

               select brrnom
                 into d_cts08m00.endbrr
                 from glakbrr
                where cidcod = ws.cidcod
                  and brrcod = ws.brrcod

               call cts06g06(d_cts08m00.endereco)
                    returning d_cts08m00.endereco

               display by name d_cts08m00.*

            end if

         end if

   before field endlgdtip
          display by name d_cts08m00.endlgdtip attribute (reverse)

   after field endlgdtip
         display by name d_cts08m00.endlgdtip

         if d_cts08m00.endlgdtip is null or
            d_cts08m00.endlgdtip = " "   then
            error "Campo deve ser preenchido"
            next field endlgdtip
         end if

   before field endereco
          display by name d_cts08m00.endereco attribute (reverse)

   after field endereco
         display by name d_cts08m00.endereco

         if d_cts08m00.endereco is null or
            d_cts08m00.endereco = " "   then
            error "Campo deve ser preenchido"
            next field endereco
         end if

   before field endnum
          display by name d_cts08m00.endnum attribute (reverse)

   after field endnum
         display by name d_cts08m00.endnum

         if d_cts08m00.endnum is null or
            d_cts08m00.endnum = " "   then
            error "Campo deve ser preenchido"
            next field endnum
         end if

   before field endcmp
          display by name d_cts08m00.endcmp attribute (reverse)

   after field endcmp
         display by name d_cts08m00.endcmp

   before field endbrr
          display by name d_cts08m00.endbrr attribute (reverse)

   after field endbrr
         display by name d_cts08m00.endbrr

         if d_cts08m00.endbrr is null or
            d_cts08m00.endbrr = " "   then
            error "Campo deve ser preenchido"
            next field endbrr
         end if

   before field endcid
          display by name d_cts08m00.endcid attribute (reverse)

   after field endcid
         display by name d_cts08m00.endcid

         if d_cts08m00.endcid is null or
            d_cts08m00.endcid = " "   then
            error "Campo deve ser preenchido"
            next field endcid
         end if

   before field endufd
          display by name d_cts08m00.endufd attribute (reverse)

   after field endufd
         display by name d_cts08m00.endufd

         if d_cts08m00.endufd is null or
            d_cts08m00.endufd = " "   then
            error "Campo deve ser preenchido"
            next field endufd
         end if

   before field confirma
          display by name d_cts08m00.confirma attribute (reverse)

          # -- CT 260487 - Katiucia -- #
          let l_endcid = d_cts08m00.endcid clipped, "%"

          whenever error continue
            select cidcod
              into ws.cidcod
              from glakcid
             where cidnom like l_endcid
               and ufdcod = d_cts08m00.endufd
          whenever error stop

          if sqlca.sqlcode = 100 then
             call cts06g04(d_cts08m00.endcid
                          ,d_cts08m00.endufd)
                  returning ws.cidcod
                           ,d_cts08m00.endcid
                           ,d_cts08m00.endufd

             display by name d_cts08m00.endcid
             display by name d_cts08m00.endufd
          end if

#--------- Alteracao da consistencia de mudanca dos dados do endereco
#          Solicitado por Ligia Mattge p/ PSI: 172421
#
         if   d_cts08m00.endcep    is null
	         or d_cts08m00.endcep    <> ws.endcep
           or d_cts08m00.endcepcmp is null
	         or d_cts08m00.endcepcmp <> ws.endcepcmp
	         or d_cts08m00.endereco  <> ws.lgdnom then
              # -- Katiucia -- #
              let l_endcep    = null
              let l_endcepcmp = null
              call cts06g05(d_cts08m00.endlgdtip
                           ,d_cts08m00.endereco
                           ,d_cts08m00.endnum
                           ,d_cts08m00.endbrr
                           ,ws.cidcod
                           ,d_cts08m00.endufd)
                   returning d_cts08m00.endlgdtip
                            ,d_cts08m00.endereco
                            ,d_cts08m00.endbrr
                            ,l_endcep
                            ,l_endcepcmp
                            ,ws.cod

              if l_endcep    is not null and
                 l_endcep    <> " "      and
                 l_endcepcmp is not null and
                 l_endcepcmp <> " "      then
                 let d_cts08m00.endcep    = l_endcep
                 let d_cts08m00.endcepcmp = l_endcepcmp
              end if
              display by name d_cts08m00.*
          end if

   after  field confirma
          display by name d_cts08m00.confirma

          if ((d_cts08m00.confirma  is null)  or
               d_cts08m00.confirma  <> "S"    and
               d_cts08m00.confirma  <> "N")   then
             error " Confirma solicitacao: (S)im ou (N)ao!"
             next field confirma
          end if

          {if d_cts08m00.confirma = "N" then

             next field endcep
          else
             call cts08g01("A","N","O ENDERECO INFORMADO NAO IRA ALTERAR",
                                "A BASE DE DADOS DO SEGURADO, FAVOR",
                                "SOLICITAR CONTATO COM O CORRETOR PARA",
                                "ALTERACAO DEFINITIVA")
                  returning ws.confirma
          end if}

          if ws.aplstt = "C"   then
             error " Apolice cancelada!"
             next field confirma
          end if

          if ws.itmstt = "C"   then
             error " Item da apolice cancelado!"
             next field confirma
          end if

          call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
          if ws.vigfnl  <  l_data   then
             error " Apolice vencida!"
             next field confirma
          end if

          {if d_cts08m00.vcllicnum   is null    then
             error " Veiculo sem placa cadastrada - utilize codigo de assunto B13!"
             next field confirma
          end if}

          #------------------------------------------------------
          # Verifica se houve solicitacao nos ultimos 5 dias
          #------------------------------------------------------
          let ws.contador  =  0
          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          select count(*)
            into ws.contador
            from abam2via
           where succod     =  g_documento.succod      and
                 aplnumdig  =  g_documento.aplnumdig   and
                 edsnumdig  =  g_documento.edsnumref   and
                 itmnumdig  =  g_documento.itmnumdig   and
                 soldat     >  l_data - 6 units day     and
                 chaflg     =  "S"
          if ws.contador  >  0   then
             let ws.cartao = "N"
          end if


          let ws.contador  =  0
          select count(*)
            into ws.contador
            from abam2via
           where succod     =  g_documento.succod      and
                 aplnumdig  =  g_documento.aplnumdig   and
                 edsnumdig  =  g_documento.edsnumref   and
                 itmnumdig  =  g_documento.itmnumdig   and
                 soldat     >  l_data - 6 units day     and
                 fotsegflg  =  "S"
          if ws.contador  >  0   then
             let ws.segapol = "N"
          end if

          if ws.prgcod = 21 then
             if ws.cartao = "N" and ws.segapol = "N"   then
                error " Ja' existe uma solicitacao com menos de 5 dias!"
                next field confirma
             end if
          else
             if ws.cartao = "N"  then
                if ws.contador > 0  then
                   error " Cartao do segurado ja' solicitado na ligacao B12/B19"
                else
                   error " Ja' existe uma solicitacao com menos de 5 dias!"
                end if
                next field confirma
             end if
          end if

          exit input

   on key (interrupt)
      if cts08g01("C","S","","ABANDONA O PREENCHIMENTO ?","","") = "S"   then
         let int_flag = true
         exit input
      end if

   on key (F1)
      if d_cts08m00.c24astcod is not null then
         call ctc58m00_vis(d_cts08m00.c24astcod)
      end if

   on key (F5)

       let g_monitor.horaini = current ## Flexvision
       call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

 end input

 if  int_flag  then
     error " Operacao cancelada!"
 else
     if  d_cts08m00.confirma = "S"  then

         #---------------------------------------------------------------------
         # Solicita 2a via
         #---------------------------------------------------------------------
         begin work

         #-- Verifica se existe na tabela datmsegviaend o codigo segnumdig
         whenever error continue
            select * from datmsegviaend
             where segnumdig = ws.segnumdig
         whenever error stop

         if   sqlca.sqlcode < 0 then
              error " Erro (", sqlca.sqlcode
                   ,") na selecao da tab.datmsegviaend. AVISE A INFORMATICA!"
              sleep    03
              rollback work

              prompt "" for char ws.prompt_key
              return
         end  if
         # Chamado 579484   
         if d_cts08m00.endnum is null or
            d_cts08m00.endnum = ' ' then
            let d_cts08m00.endnum = 0
         end if

         #-- Se nao encontrou, incluir dados
         if sqlca.sqlcode = 100 then
            whenever error continue
              insert into datmsegviaend (segnumdig
                                        ,endlgdtip
                                        ,endlgd
                                        ,endnum
                                        ,endcmp
                                        ,endcep
                                        ,endcepcmp
                                        ,endcid
                                        ,endufd
                                        ,endbrr)
                              values (ws.segnumdig
                                        ,d_cts08m00.endlgdtip
                                        ,d_cts08m00.endereco
                                        ,d_cts08m00.endnum
                                        ,d_cts08m00.endcmp
                                        ,d_cts08m00.endcep
                                        ,d_cts08m00.endcepcmp
                                        ,d_cts08m00.endcid
                                        ,d_cts08m00.endufd
                                        ,d_cts08m00.endbrr)
            whenever error stop

            if sqlca.sqlcode <> 0 then
               call ctx13g00(sqlca.sqlcode,"DATMSEGVIAEND",ws.msg)
               rollback work
               prompt "" for char ws.prompt_key
               close window cts08m00
               return
            end if
         #-- Se encontrou, alterar os dados
         else
            whenever error continue
               update datmsegviaend set
                      endlgdtip = d_cts08m00.endlgdtip
                     ,endlgd    = d_cts08m00.endereco
                     ,endnum    = d_cts08m00.endnum
                     ,endcmp    = d_cts08m00.endcmp
                     ,endcep    = d_cts08m00.endcep
                     ,endcepcmp = d_cts08m00.endcepcmp
                     ,endcid    = d_cts08m00.endcid
                     ,endufd    = d_cts08m00.endufd
                     ,endbrr    = d_cts08m00.endbrr
                where segnumdig = ws.segnumdig
            whenever error stop

            if sqlca.sqlcode <> 0 then
               call ctx13g00(sqlca.sqlcode,"DATMSEGVIAEND",ws.msg)
               rollback work
               prompt "" for char ws.prompt_key
               close window cts08m00
               return
            end if
         end if

         let ws.msglog = "apgt2vfnc_ct24h(", g_documento.succod    ,",",
                                             g_documento.aplnumdig ,",",
                                             g_documento.edsnumref ,",",
                                             g_documento.itmnumdig ,",",
                                             ws.cartao             ,",",
                                             ws.segapol            ,")"

         call errorlog(ws.msglog)
         call figrc072_setTratarIsolamento()
         call apgt2vfnc_ct24h( g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.edsnumref,
                               g_documento.itmnumdig,
                               ws.cartao            ,
                               ws.segapol            )
              returning ws.retflg,
                        ws.msgtxt

         let ws.msglog = "apgt2vfnc_ct24h_ret ", ws.retflg, ws.msgtxt
         call errorlog(ws.msglog)
         if g_isoAuto.sqlCodErr <> 0 then
            let ws.msgtxt = "2 via Indisponivel"
            let ws.retflg = g_isoAuto.sqlCodErr
         end if
         if  ws.retflg <> 0  then
             rollback work
             let ws.msgtxt = upshift(ws.msgtxt)
             call cts08g01("I","N","",ws.msgtxt,"","")
                  returning ws.confirma
         else
           #--------------------------------------------------------------------
           # Busca numeracao ligacao
           #--------------------------------------------------------------------
            call cts10g03_numeracao( 1, "" )
                 returning ws.lignum   ,
                           ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.codigosql,
                           ws.msg

            if  ws.codigosql <> 0  then
                let ws.msg = "CTS08M00 - ",ws.msg
                call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
                rollback work
                prompt "" for char ws.prompt_key
                return
            end if

            #-------------------------------------------------------------------
            # Grava ligacao
            #-------------------------------------------------------------------
            call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
            call cts10g00_ligacao ( ws.lignum               ,
                                    l_data                  ,
                                    l_hora2                 ,
                                    g_documento.c24soltipcod,
                                    g_documento.solnom      ,
                                    g_documento.c24astcod   ,
                                    g_issk.funmat           ,
                                    g_documento.ligcvntip   ,
                                    g_c24paxnum             ,
                                    "","", "","", "",""     ,
                                    g_documento.succod      ,
                                    g_documento.ramcod      ,
                                    g_documento.aplnumdig   ,
                                    g_documento.itmnumdig   ,
                                    g_documento.edsnumref   ,
                                    g_documento.prporg      ,
                                    g_documento.prpnumdig   ,
                                    g_documento.fcapacorg   ,
                                    g_documento.fcapacnum   ,
                                    "","","",""             ,
                                    "", "", "", ""           )
                 returning ws.tabname,
                           ws.codigosql

             if  ws.codigosql  <>  0  then
                 error " Erro (", ws.codigosql, ") na gravacao da",
                       " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
                 rollback work
                 prompt "" for char ws.prompt_key
                 close window cts08m00
                 return
             end if
             let l_historico.cep = d_cts08m00.endcep
                                  ,"-"
                                  , d_cts08m00.endcepcmp

             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_historico.cep,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning ws.codigosql,  #retorno
                            l_mensagem   #mensagem
             if ws.codigosql <> 1 then
                error l_mensagem
                rollback work
                close window cts08m00
                return
             end if
             let l_historico.endereco = d_cts08m00.endlgdtip clipped
                                       ," "
                                       ,d_cts08m00.endereco clipped
                                       ," "
                                       ,d_cts08m00.endnum clipped

             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_historico.endereco,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning ws.codigosql,  #retorno
                            l_mensagem   #mensagem
             if ws.codigosql <> 1 then
                error l_mensagem
                rollback work
                close window cts08m00
                return
             end if

             let l_historico.complemento = d_cts08m00.endcmp clipped

             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_historico.complemento,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning ws.codigosql,  #retorno
                            l_mensagem   #mensagem
             if ws.codigosql <> 1 then
                error l_mensagem
                rollback work
                close window cts08m00
                return
             end if


             let l_historico.bairro = d_cts08m00.endbrr clipped

             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_historico.bairro,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning ws.codigosql,  #retorno
                            l_mensagem   #mensagem
             if ws.codigosql <> 1 then
                error l_mensagem
                rollback work
                close window cts08m00
                return
             end if

             let l_historico.cidade = d_cts08m00.endcid clipped
                                     ," - "
                                     ,d_cts08m00.endufd clipped

             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_historico.cidade,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning ws.codigosql,  #retorno
                            l_mensagem   #mensagem
             if ws.codigosql <> 1 then
                error l_mensagem
                rollback work
                close window cts08m00
                return
             end if


             # Psi 230650 - inicio
             if g_documento.atdnum is not null and
                g_documento.atdnum <> 0        and
                ws.lignum          is not null and
                ws.lignum          <> 0        then

                ---> Relaciona Atendimento X Ligacao
                call ctd25g00_insere_atendimento(g_documento.atdnum
                                                ,ws.lignum)
                     returning ws.codigosql,
                               ws.tabname

                if ws.codigosql  <>  0  then
                   error ws.tabname sleep 3
                   rollback work
                   close window cts08m00
                   return
                end if
             end if
             # Psi 230650 - Fim

             commit work

               call cts08g01("A","N","EMISSAO DE 2A. VIA SOLICITADA",
                             "INFORME QUE O PRAZO DE ENTREGA",
                             "SERA DE 10 A 15 DIAS UTEIS","")
                  returning ws.confirma
         end if
     else
         call cts08g01("A","N","NAO FOI CONFIRMADA !",
                       "A EMISSAO DE 2A. VIA","","")
              returning ws.confirma

     end if
 end if

 close window cts08m00
 let int_flag = false

end function  ###  cts08m00
