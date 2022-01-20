#############################################################################
# Nome do Modulo: cts19m07                                         Marcelo  #
#                                                                  Gilberto #
# Direcionamento de solicitacao de reparo nos vidros               Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 23/10/1998  PSI  6966-3  Marcelo      Incluir configuracoes para envio de #
#                                       fax atraves do servidor VSI-Fax.    #
#---------------------------------------------------------------------------#
# 26/01/1999  PSI  7264-8  Wagner       Incluir texto de mensagens no envio #
#                                       de FAX.                             #
#---------------------------------------------------------------------------#
# 27/10/1999  PSI  9604-0  Gilberto     Incluir CGC/CPF do segurado no fax. #
#---------------------------------------------------------------------------#
# 26/05/2000  PSI 10860-0  Akio         Exibir as franquias de vidros       #
#                                       clausulas 071 e X71                 #
#---------------------------------------------------------------------------#
# 06/09/2000  Arnaldo      Ruiz         Alterar o telefone do fax           #
#                                       011-3611.0650.                      #
#---------------------------------------------------------------------------#
# 29/05/2001  Arnaldo      Ruiz         Alterar o telefone do fax           #
#                                       011-4152.8128.                      #
#---------------------------------------------------------------------------#
# 05/06/2001  PSI 13042-7  Ruiz         Alterar para mais de um prestador.  #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 20/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria    Priscila    Buscar data e hora do banco de dados #
# 25/04/2007 Ligia Mattge  PSI208175 - envio p/email da loja, impressao do  #
#                                      nr do sinistro e vistoria            #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
# 13/08/2009 Sergio Burini PSI244236   Inclusão do Sub-Dairro               #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                   projeto sucursal smallint            #
#---------------------------------------------------------------------------#
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone          #
#---------------------------------------------------------------------------#
# 20/01/2014 Intera2,joao                   -    Projeto RightFax           #
#---------------------------------------------------------------------------#
## database porto
globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

 define l_itens   array[50] of record
        nom_cond        char(30)
       ,vlr_franq       dec (14,2)
       ,vlr_avari       dec (14,2)
 end record

 define ws_pipe      char (80)
 define ws_fax       char (03)
 define ws_laudo     char (60)
 define l_docHandle  integer                    #RightFax
#--------------------------------------------------------------
 function cts19m07(param)
#--------------------------------------------------------------
 define param     record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     lignum       like datmligacao.lignum,
     frqvlrfarois decimal(15,5),
     sinvstnum    like ssamsin.sinvstnum,
     sinvstano    like ssamsin.sinvstano,
     sinano       like ssamsin.sinano,
     sinnum       like ssamsin.sinnum
 end record

 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 define out record
     lignum           dec (10,0),
     ligdat           date      ,
     lighorinc        datetime hour to minute,
     c24solnom        char(15),
     succod           smallint, # Projeto succod
     ramcod           dec (4,0),
     aplnumdig        dec (9,0),
     itmnumdig        dec (7,0),
     viginc           date      ,
     vigfnl           date      ,
     segnom           char(50),
     segdddcod        char(04),
     segteltxt        char(20),
     corsus           char(06),
     cornom           char(40),
     cordddcod        char(04),
     corteltxt        char(20),
     vcldes           char(40),
     vcllicnum        char(07),
     vclchsnum        char(20),
     vclanofbc        datetime year to year,
     vclanomdl        datetime year to year,
     clscod           char(03),
     clsdes           char(40),
     frqvlr           dec(15,5),
     atldat           date,
     atlhor           datetime hour to second,
     cgccpfnum        dec(12,0),
     cgcord           dec(04,0),
     cgccpfdig        dec(02,0),
     adcmsgtxt        char(100),
     vdrpbsfrqvlr     dec(15,5),
     vdrvgafrqvlr     dec(15,5),
     vdresqfrqvlr     dec(15,5),
     vdrdirfrqvlr     dec(15,5),
     atdsrvnum        dec(10,0),
     atdsrvano        dec(02,0),
     vstnumdig        dec(09,0),
     prporg           dec(02,0),
     prpnumdig        dec(09,0),
     vclcoddig        dec(05,0),
     vdrrprgrpcod     dec(05,0),
     vdrrprempcod     dec(05,0),
     vcltip           char (01),
     vdrpbsavrfrqvlr  dec (15,5),
     vdrvgaavrfrqvlr  dec (15,5),
     vdrdiravrfrqvlr  dec (15,5),
     vdresqavrfrqvlr  dec (15,5),
     atdhorpvt        datetime hour to minute,
     atdhorprg        datetime hour to minute,
     atddatprg        date ,
     atdetpcod        smallint,
     atmstt           smallint,
     atldat1          date,
     atldat2          date,
     atlhor1          datetime hour to second,
     atlhor2          datetime hour to second,
     ocuesqfrqvlr     dec (15,5),
     ocudirfrqvlr     dec (15,5),
     ocuesqavrfrqvlr  dec (15,5),
     ocudiravrfrqvlr  dec (15,5),
     vdrqbvfrqvlr     dec (14,2),
     vdrqbvavrfrqvlr  dec (14,2),
     atntip           smallint ,
     esqrtrfrqvlr     decimal(15,5),
     dirrtrfrqvlr     decimal(15,5),
     esqrtravrvlr     decimal(15,5),
     dirrtravrvlr     decimal(15,5),
     drtfrlvlr        decimal(15,5),
     esqfrlvlr        decimal(15,5),
     esqmlhfrlvlr     decimal(15,5),
     drtmlhfrlvlr     decimal(15,5),
     drtnblfrlvlr     decimal(15,5),
     esqnblfrlvlr     decimal(15,5),
     esqpscvlr        decimal(15,5),
     drtpscvlr        decimal(15,5),
     drtlntvlr        decimal(15,5),
     esqlntvlr        decimal(15,5)
 end record

 define d_cts19m07    record
     empresa          char (10),
     enviar           char (01),
     envdes           char (10),
     dddcod           like datmreclam.dddcod,
    #faxnum           like datmreclam.faxnum,
     faxnum           char (09)             ,
     email            like adikvdrrpremp.maicod
 end record

 define ws           record
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    faxtxt           char (12),
    impnom           char (08),
    imp_ok           smallint,
    envflg           dec (1,0),
    confirma         char (01),
    codgrupo         like adikvdrrpremp.vdrrprgrpcod,
    codloja          like adikvdrrpremp.vdrrprempcod,
    nomgrupo         char (16),
    nomeloja         like adikvdrrpremp.vdrrprempnom,
    vstnumdig        like datmvistoria.vstnumdig,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    atntip           char (09),
    endereco         char (65),
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    brrnom           like datmlcl.brrnom,
    lclbrrnom        like datmlcl.lclbrrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclcttnom        like datmlcl.lclcttnom,
    c24astcod        like datmligacao.c24astcod,
    comando          char (2000),
    tit              char (300)
 end record

 define ls_laudo     char (60)
 define l_lignum_ori  like datmligacao.lignum
 
  define l_mail          record
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

 #RightFax - inicio
 define lr_param         record
        service            char(10)
       ,serviceType        char(10)
       ,typeOfConnection   char(3)
       ,fileSystem         char(100)
       ,jasperFileName     char(50)
       ,outFileName        char(100)
       ,outFileType        char(3)
       ,recordPath         char(100)
       ,aplicacao          char(30)
       ,outbox             char(100)
       ,generatorTIFF      smallint
 end record

 define l_hora            datetime hour to second
 define l_nomexml         char(200)
 define w_conta           smallint

 define lr_param_out      record
          codigo            smallint
        , mensagem          char(200)
 end    record

 define lr_fax             record
          ddd                char(3)
         ,telefone           char(16)
         ,destinatario 	     char(30)
         ,notas              char(30)
         ,caminhoarq         char(100)
         ,sistema            char(100)
         ,geratif            smallint
 end record
 
 initialize lr_param.* ,lr_param_out.*, l_hora to null
 #RightFax - Fim


 initialize  out.*  to  null
 initialize  d_cts19m07.*  to  null
 initialize  ws.*  to  null

 initialize d_cts19m07.*  to null
 initialize ws.*          to null
 let int_flag   =  false
 let ws.envflg  =  true
 let ls_laudo = null
 let  l_lignum_ori = null

 if param.sinvstnum is null and
    param.sinvstano is null then
        call cts19m07_rec_vistoria(param.lignum)
        returning param.sinvstnum ,
                  param.sinvstano

        if param.sinvstnum is null and
           param.sinvstano is null then

                   ## Busca Ligacao Original do Servico B14
                   let l_lignum_ori = cts20g00_servico(param.atdsrvnum,
                                                           param.atdsrvano)

                   call cts19m06_busca_lig_ori(l_lignum_ori)
                       returning param.sinvstnum,param.sinvstano

        end if


 end if

 if param.sinano is null and
    param.sinnum is null then
         call cts19m07_rec_sinistro(param.sinvstnum,
                                    param.sinvstano,
                                    param.lignum   ,
                                    param.atdsrvnum,
                                    param.atdsrvano)
         returning param.sinano,
                   param.sinnum
 end if


 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 declare c_cts19m07_001 cursor for
     select lignum          ,ligdat          ,lighorinc
           ,c24solnom       ,succod          ,ramcod
           ,aplnumdig       ,itmnumdig       ,viginc
           ,vigfnl          ,segnom          ,segdddcod
           ,segteltxt       ,corsus          ,cornom
           ,cordddcod       ,corteltxt       ,vcldes
           ,vcllicnum       ,vclchsnum       ,vclanofbc
           ,vclanomdl       ,clscod          ,clsdes
           ,frqvlr          ,atldat          ,atlhor
           ,cgccpfnum       ,cgcord          ,cgccpfdig
           ,adcmsgtxt       ,vdrpbsfrqvlr    ,vdrvgafrqvlr
           ,vdresqfrqvlr    ,vdrdirfrqvlr    ,atdsrvnum
           ,atdsrvano       ,vstnumdig       ,prporg
           ,prpnumdig       ,vclcoddig       ,vdrrprgrpcod
           ,vdrrprempcod    ,vcltip          ,vdrpbsavrfrqvlr
           ,vdrvgaavrfrqvlr ,vdrdiravrfrqvlr ,vdresqavrfrqvlr
           ,atdhorpvt       ,atdhorprg       ,atddatprg
           ,atdetpcod       ,atmstt          ,atldat1
           ,atldat2         ,atlhor1         ,atlhor2
           ,ocuesqfrqvlr    ,ocudirfrqvlr    ,ocuesqavrfrqvlr
           ,ocudiravrfrqvlr ,vdrqbvfrqvlr    ,vdrqbvavrfrqvlr
           ,atntip          ,esqrtrfrgvlr    ,dirrtrfrgvlr
           ,esqrtravrvlr    ,dirrtravrvlr    ,drtfrlvlr
           ,esqfrlvlr       ,esqmlhfrlvlr    ,drtmlhfrlvlr
           ,drtnblfrlvlr    ,esqnblfrlvlr    ,esqpscvlr
           ,drtpscvlr       ,drtlntvlr       ,esqlntvlr
       from datmsrvext1
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano
        and lignum    = param.lignum

 foreach c_cts19m07_001 into out.lignum          ,out.ligdat          ,out.lighorinc
                      ,out.c24solnom       ,out.succod          ,out.ramcod
                      ,out.aplnumdig       ,out.itmnumdig       ,out.viginc
                      ,out.vigfnl          ,out.segnom          ,out.segdddcod
                      ,out.segteltxt       ,out.corsus          ,out.cornom
                      ,out.cordddcod       ,out.corteltxt       ,out.vcldes
                      ,out.vcllicnum       ,out.vclchsnum       ,out.vclanofbc
                      ,out.vclanomdl       ,out.clscod          ,out.clsdes
                      ,out.frqvlr          ,out.atldat          ,out.atlhor
                      ,out.cgccpfnum       ,out.cgcord          ,out.cgccpfdig
                      ,out.adcmsgtxt       ,out.vdrpbsfrqvlr
                      ,out.vdrvgafrqvlr    ,out.vdresqfrqvlr
                      ,out.vdrdirfrqvlr    ,out.atdsrvnum
                      ,out.atdsrvano       ,out.vstnumdig       ,out.prporg
                      ,out.prpnumdig       ,out.vclcoddig
                      ,out.vdrrprgrpcod    ,out.vdrrprempcod    ,out.vcltip
                      ,out.vdrpbsavrfrqvlr ,out.vdrvgaavrfrqvlr
                      ,out.vdrdiravrfrqvlr ,out.vdresqavrfrqvlr
                      ,out.atdhorpvt       ,out.atdhorprg       ,out.atddatprg
                      ,out.atdetpcod       ,out.atmstt          ,out.atldat1
                      ,out.atldat2         ,out.atlhor1         ,out.atlhor2
                      ,out.ocuesqfrqvlr    ,out.ocudirfrqvlr
                      ,out.ocuesqavrfrqvlr ,out.ocudiravrfrqvlr
                      ,out.vdrqbvfrqvlr    ,out.vdrqbvavrfrqvlr
                      ,out.atntip          ,out.esqrtrfrqvlr
                      ,out.dirrtrfrqvlr    ,out.esqrtravrvlr
                      ,out.dirrtravrvlr    ,out.drtfrlvlr
                      ,out.esqfrlvlr       ,out.esqmlhfrlvlr
                      ,out.drtmlhfrlvlr    ,out.drtnblfrlvlr
                      ,out.esqnblfrlvlr    ,out.esqpscvlr
                      ,out.drtpscvlr       ,out.drtlntvlr
                      ,out.esqlntvlr

exit foreach
 end foreach

#if out.vdrrprgrpcod = 1 then
#   let ws.nomgrupo = "NUCLEUS CARGLASS"
#else
#   if out.vdrrprgrpcod = 2  then
#      let ws.nomgrupo = "ABRAVAUTO"
#   else
#      let ws.nomgrupo = "NAO LOCALIZADO"
#   end if
#end if

 select vdrrprgrpnom
       into ws.nomgrupo
       from adikvdrrprgrp
       where vdrrprgrpcod = out.vdrrprgrpcod   # cod. empresa

 if out.atntip   =   1  then
    let ws.atntip = "REDE     "
 else
    if out.atntip  =  2  then
       let ws.atntip = "FORA DA REDE"
    else
       if out.atntip = 3 then
          let ws.atntip = "AMBOS    "
       end if
    end if
 end if
 select lgdtip,      lgdnom,
        lgdnum,      brrnom,    lclbrrnom,
        cidnom,      ufdcod,    lclcttnom
   into ws.lgdtip,   ws.lgdnom,
        ws.lgdnum,   ws.brrnom, ws.lclbrrnom,
        ws.cidnom,   ws.ufdcod, ws.lclcttnom
   from datmlcl
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and c24endtip = 1

 let ws.endereco = ws.lgdtip clipped, " ",
                   ws.lgdnom clipped, " ",
                   ws.lgdnum using "<<<<#"

 call ctx14g00_limpa(ws.endereco,"'") returning ws.endereco
 call ctx14g00_limpa(ws.brrnom,"'") returning ws.brrnom
 call ctx14g00_limpa(ws.lclbrrnom,"'") returning ws.lclbrrnom
 call ctx14g00_limpa(out.cornom,"'") returning out.cornom

 select vdrrprgrpnom
       into d_cts19m07.empresa
       from adikvdrrprgrp
       where vdrrprgrpcod = out.vdrrprgrpcod   # cod. empresa

 select dddcod,faxnum,maicod,vdrrprempnom
       into d_cts19m07.dddcod,
            d_cts19m07.faxnum,
            d_cts19m07.email,
            ws.nomeloja
       from adikvdrrpremp
       where vdrrprempcod = out.vdrrprempcod    # cod. da loja

 if out.cgccpfnum is null then
    let out.cgccpfnum  =  "            "
    let out.cgcord     =  "    "
    let out.cgccpfdig  =  "  "
 end if
 if out.atdetpcod   =  6  then  # servico cancelado
    let out.atdetpcod = 5
 end if

#---------------------------------------------------------------------------
# Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
#---------------------------------------------------------------------------
 let ws_fax = "VSI"

#let d_cts19m07.dddcod = "011"
#let d_cts19m07.faxnum = 41528128

 open window w_cts19m07 at 11,07 with form "cts19m07"
             attribute (form line 1, border)

 message " (F17)Abandona"

 display by name d_cts19m07.*

 input by name d_cts19m07.email,
               d_cts19m07.enviar,
               d_cts19m07.dddcod ,
               d_cts19m07.faxnum without defaults

    before field enviar
       if d_cts19m07.email is not null then
          exit input
       end if

       display by name d_cts19m07.enviar    attribute (reverse)

    after  field enviar
       display by name d_cts19m07.enviar

       if d_cts19m07.enviar is null  then
          error " Enviar solicitacao de reparo para (I)mpressora ou (F)ax!"
          next field enviar
       else
          if d_cts19m07.enviar = "F"  then
             let d_cts19m07.envdes = "FAX"
          else
             if d_cts19m07.enviar = "I"  then
                let d_cts19m07.envdes = "IMPRESSORA"
             else
               error " Enviar solicitacao de reparo para (I)mpressora ou (F)ax!"
               next field enviar
             end if
          end if
       end if

       display by name d_cts19m07.envdes

       initialize  ws_pipe, ws.imp_ok, ws.impnom to null

       if d_cts19m07.enviar = "I"  then

          call fun_print_seleciona (g_issk.dptsgl,"")
               returning  ws.imp_ok, ws.impnom

          if ws.imp_ok = 0  then
             error " Departamento/Impressora nao cadastrada!"
             next field enviar
          end if

          if ws.impnom is null  then
             error " Uma impressora deve ser selecionada!"
             next field enviar
          end if

          exit input

       else
         if g_outFigrc012.Is_Teste then #ambnovo
            if g_issk.funmat <> 7339    and    # Henrique
               g_issk.funmat <> 601566  and    # Ruiz
               g_issk.funmat <> 603399  and    # Alberto
               g_issk.funmat <> 5048   then   # Arnaldo
               error " Fax so' pode ser enviado no ambiente de producao !!!"
               next field enviar
            end if
         end if
       end if

    before field dddcod
       display by name d_cts19m07.dddcod    attribute (reverse)

    after  field dddcod
       display by name d_cts19m07.dddcod

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field enviar
       end if

       if d_cts19m07.dddcod is null  or
          d_cts19m07.dddcod  = "  "  then
          error " Codigo do DDD deve ser informado!"
          next field dddcod
       end if

       if d_cts19m07.dddcod   = "0   "   or
          d_cts19m07.dddcod   = "00  "   or
          d_cts19m07.dddcod   = "000 "   or
          d_cts19m07.dddcod   = "0000"   then
          error " Codigo do DDD invalido!"
          next field dddcod
       end if

    before field faxnum
       display by name d_cts19m07.faxnum    attribute (reverse)

    after  field faxnum
       display by name d_cts19m07.faxnum

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field dddcod
       end if

       if d_cts19m07.faxnum is null  or
          d_cts19m07.faxnum =  000   then
          error " Numero do fax deve ser informado!"
          next field faxnum
       end if

    before field email
       #if out.vdrrprgrpcod   =  1  then  # carglass nao enviar e-mail
       #   next field enviar
       #end if

       display by name d_cts19m07.email     attribute (reverse)

    after  field email
       display by name d_cts19m07.email

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field email
       end if

       #if d_cts19m07.email  is null  or
       #   d_cts19m07.email  =  "    " then
       #   error " e-mail deve ser informado!"
       #   next field email
       #end if

    on key (interrupt)
       exit input
 end input

 if not int_flag  then

    # Comego da Alteracao de envio de fax e e-mail / Roberto

    let ls_laudo = "Laudo_Vidros.txt"

    if d_cts19m07.enviar  =  "F"  then
       call cts10g01_enviofax(param.atdsrvnum,param.atdsrvano,
                              param.lignum,"VD", g_issk.funmat)
                    returning ws.envflg, ws.faxch1, ws.faxch2

    end if

    let ws_laudo = f_path('ONLTEL', 'RELATO')

    if ws_laudo is null or
       ws_laudo = ' ' then
       let ws_laudo = '.'
    end if

    let ls_laudo = ws_laudo clipped, ls_laudo clipped

    if ws.envflg  =  true  then
       #RightFax - Inicio
       start report  rep_reparo1  to ls_laudo
       #####start report  rep_reparo2  to  ws_laudo
       let lr_param.service          = 'cts19m07.4gl'
       let lr_param.serviceType      = 'GENERATOR'
       let lr_param.typeOfConnection = 'xml'
       let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
       let lr_param.jasperFileName   = 'cts_reparo.jasper'
       let l_hora                    =  current
       let lr_param.outFileName      = 'reparo'
       let lr_param.outFileType      = 'pdf'
       let lr_param.recordPath       = '/report/data/file/cts_reparo'
       let lr_param.aplicacao        = 'cts19m07.4gl'
       let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
       let lr_param.generatorTIFF    = false
       let l_nomexml                 = 'cts19m07'
       call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
           returning l_docHandle
       display "@@@l_docHandle = ",l_docHandle       #tirar
       output to report rep_reparo1 (d_cts19m07.enviar,
                                     d_cts19m07.dddcod,
                                     d_cts19m07.faxnum,
                                     ws.faxch1,
                                     ws.faxch2,
                                     ws.nomgrupo,
                                     ws.nomeloja,
                                     ws.atntip  ,
                                     ws.endereco,
                                     ws.brrnom,
                                     ws.lclbrrnom,
                                     ws.cidnom,
                                     ws.ufdcod,
                                     ws.lclcttnom,
                                     out.*,
                                     param.frqvlrfarois,
                                     param.sinvstnum,
                                     param.sinvstano,
                                     param.sinano,
                                     param.sinnum)

       call cts19m07_reparo1(d_cts19m07.enviar,
                             d_cts19m07.dddcod,
                             d_cts19m07.faxnum,
                             ws.faxch1,
                             ws.faxch2,
                             ws.nomgrupo,
                             ws.nomeloja,
                             ws.atntip  ,
                             ws.endereco,
                             ws.brrnom,
                             ws.lclbrrnom,
                             ws.cidnom,
                             ws.ufdcod,
                             ws.lclcttnom,
                             out.*,
                             param.frqvlrfarois,
                             param.sinvstnum,
                             param.sinvstano,
                             param.sinano,
                             param.sinnum,
                             l_docHandle)

       #RightFax - Fim

       #output to report rep_reparo2 (d_cts19m07.enviar,
       #                              d_cts19m07.dddcod,
       #                              d_cts19m07.faxnum,
       #                              ws.faxch1,
       #                              ws.faxch2,
       #                              ws.nomgrupo,
       #                              ws.nomeloja,
       #                              ws.atntip  ,
       #                              ws.endereco,
       #                              ws.lclbrrnom,
       #                              ws.cidnom,
       #                              ws.ufdcod,
       #                              ws.lclcttnom,
       #                              out.*,
       #                              param.frqvlrfarois,
       #                              m_sin.*)

       finish report rep_reparo1
       ##finish report rep_reparo2  # gera laudo para email do sinistro.vidros

       if d_cts19m07.email  is not null then

          #PSI-2013-23297 - Inicio
          let l_mail.de = "ct24hs.email@portoseguro.com.br"
          #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
          let l_mail.para = d_cts19m07.email
          let l_mail.cc = ""
          let l_mail.cco = ""
          let l_mail.assunto = ws.tit
          let l_mail.mensagem = ""
          let l_mail.id_remetente = "CT24H"
          let l_mail.tipo = "text"


          call figrc009_attach_file(ls_laudo)
          display "Arquivo anexado com sucesso"
          call figrc009_mail_send1 (l_mail.*)
           returning l_coderro,msg_erro
          #PSI-2013-23297 - Fim

          let ws.comando = "rm ", ws_laudo
          run ws.comando
       else
          if d_cts19m07.enviar  =  "F"  then
             if ws_fax = "GSF"  then
                if g_outFigrc012.Is_Teste then #ambnovo
                   let ws.impnom = "tstclfax"
                else
                   let ws.impnom = "ptsocfax"
                end if
                let ws_pipe = "lp -sd ", ws.impnom clipped," ", ls_laudo clipped
             else
                #RightFax - Inicio
                #call cts02g01_fax(d_cts19m07.dddcod, d_cts19m07.faxnum)
                #     returning ws.faxtxt
                #let ws_pipe = "cat ",
                #              ls_laudo clipped,
                #              "|",
                #              "vfxCTVD ", ws.faxtxt  clipped, " ", ascii 34,
                #              ws.nomgrupo            clipped, ascii 34,  " ",
                #              ws.faxch1              using "&&&&&&&&&&", " ",
                #              ws.faxch2              using "&&&&&&&&&&"
                let lr_fax.ddd           = d_cts19m07.dddcod
                let lr_fax.telefone      = d_cts19m07.faxnum
                let lr_fax.destinatario  = ''
                let lr_fax.notas         = ''
                let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName clipped, '.pdf'
                let lr_fax.sistema       = 'bqi605'
                let lr_fax.geratif       = false

                call cty35g00_envia_fax(l_docHandle,lr_fax.*)
                returning lr_param_out.codigo, lr_param_out.mensagem

                if lr_param_out.codigo = 0 then
                   display "Fax enviado com sucesso"
                end if
                #RightFax - Fim

             end if
          else
             if d_cts19m07.enviar  =  "I"  then
                let ws_pipe = "lp -sd ", ws.impnom clipped, ' ', ls_laudo
             end if
          end if

          run ws_pipe

          #let ws.tit     = "LAUDO_VIDROS_",out.atdsrvnum using "&&&&&&&"
          #let ws.comando = "mailx -r 'ct24hs.email@portoseguro.com.br'",
          #                 " -s  ",ws.tit clipped,
          #                 " ' vidros_sinistro/spaulo_sinistro_vidros@u23 '",
          #                 " < ", ls_laudo clipped

          #let ws.comando = "rm ", ls_laudo
          #run ws.comando

          let ws_pipe = "rm ", ls_laudo
          run ws_pipe

       end if

       #if out.vdrrprgrpcod = 2  then  # abravauto
       ## Conforme solicitado por Anésio(Sinistro) retirado envio de arquivo, pois,
       ## não estão utilizando as empresa prestadoras (Abravauto e Carglass, PSI193690-vidros

       ##if out.vdrrprgrpcod <> 1 then  # carglass
       ##   call cts19m07_email(out.*,
       ##                       d_cts19m07.email,
       ##                       ws.atntip,
       ##                       ws.endereco,
       ##                       ws.lclbrrnom,
       ##                       ws.cidnom,
       ##                       ws.ufdcod,
       ##                       ws.lclcttnom)
       ##   exit while    # carglass  contingencia
       ##else
       ##   if d_cts19m07.faxnum = "41528128" then
       ##      exit while
       ##   end if
       ##   let d_cts19m07.dddcod = "011"
       ##   let d_cts19m07.faxnum = "41528128"
       ##end if
    else
       call cts08g01 ("A", "S", "OCORREU UM PROBLEMA NO ENVIO",
                                "DO LAUDO PARA A LOJA", "",
                                "*** TENTE NOVAMENTE ***")
         returning ws.confirma
    end if
   ##end while  PSI193690 - Anésio
 else
    error " ATENCAO !!! O LAUDO NAO SERA' ENVIADO!"

    call cts08g01 ("A", "N", "LAUDO COM A SOLICITACAO DE REPARO",
                             "DE VIDROS DO VEICULO",
                             "",
                             "*** NAO SERA' ENVIADO ***")
         returning ws.confirma
 end if
 message ""
 clear form
 let int_flag = false
 close window w_cts19m07

end function  ###  cts19m07
#---------------------------------------------------------------------------
 function cts19m07_email(out)
#---------------------------------------------------------------------------
     define ws      record
         comando      char(3000),
         arquivo      char(3000),
         atdetpdes    like datketapa.atdetpdes,
         c24trxnum    like dammtrxdst.c24trxnum,
         ext          char(04)
     end record
     define out record
        lignum           dec (10,0),
        ligdat           date      ,
        lighorinc        datetime hour to minute,
        c24solnom        char(15),
        succod           smallint, # Projeto succod
        ramcod           dec (4,0),
        aplnumdig        dec (9,0),
        itmnumdig        dec (7,0),
        viginc           date      ,
        vigfnl           date      ,
        segnom           char(50),
        segdddcod        char(04),
        segteltxt        char(20),
        corsus           char(06),
        cornom           char(40),
        cordddcod        char(04),
        corteltxt        char(20),
        vcldes           char(40),
        vcllicnum        char(07),
        vclchsnum        char(20),
        vclanofbc        datetime year to year,
        vclanomdl        datetime year to year,
        clscod           char(03),
        clsdes           char(40),
        frqvlr           dec(15,5),
        atldat           date,
        atlhor           datetime hour to second,
        cgccpfnum        dec(12,0),
        cgcord           dec(04,0),
        cgccpfdig        dec(02,0),
        adcmsgtxt        char(100),
        vdrpbsfrqvlr     dec(15,5),
        vdrvgafrqvlr     dec(15,5),
        vdresqfrqvlr     dec(15,5),
        vdrdirfrqvlr     dec(15,5),
        atdsrvnum        dec(10,0),
        atdsrvano        dec(02,0),
        vstnumdig        dec(09,0),
        prporg           dec(02,0),
        prpnumdig        dec(09,0),
        vclcoddig        dec(05,0),
        vdrrprgrpcod     dec(05,0),
        vdrrprempcod     dec(05,0),
        vcltip           char (01),
        vdrpbsavrfrqvlr  dec (15,5),
        vdrvgaavrfrqvlr  dec (15,5),
        vdrdiravrfrqvlr  dec (15,5),
        vdresqavrfrqvlr  dec (15,5),
        atdhorpvt        datetime hour to minute,
        atdhorprg        datetime hour to minute,
        atddatprg        date ,
        atdetpcod        smallint,
        atmstt           smallint,
        atldat1          date,
        atldat2          date,
        atlhor1          datetime hour to second,
        atlhor2          datetime hour to second,
        ocuesqfrqvlr     dec (15,5),
        ocudirfrqvlr     dec (15,5),
        ocuesqavrfrqvlr  dec (15,5),
        ocudiravrfrqvlr  dec (15,5),
        vdrqbvfrqvlr     dec (14,2),
        vdrqbvavrfrqvlr  dec (14,2),
        atntip1          smallint ,
        esqrtrfrqvlr     decimal(15,5),
        dirrtrfrqvlr     decimal(15,5),
        esqrtravrvlr     decimal(15,5),
        dirrtravrvlr     decimal(15,5),
        email            like adikvdrrpremp.maicod,
        atntip           char(09),
        endereco         char(65),
        brrnom           like datmlcl.lclbrrnom,
        lclbrrnom        like datmlcl.lclbrrnom,
        cidnom           like datmlcl.cidnom,
        ufdcod           like datmlcl.ufdcod,
        lclcttnom        like datmlcl.lclcttnom
     end record



	initialize  ws.*  to  null

     select atdetpdes
         into ws.atdetpdes
         from datketapa
        where atdetpcod = out.atdetpcod
          and atdetpstt = "A"

     # -- OSF 9377 - Fabrica de Software, Katiucia -- #
     let ws.arquivo = "<XML><clscod>"
                     ,  out.clscod    clipped             ,"</clscod>"
                     ,"<srvnum>"
                     ,  out.atdsrvnum using "&&&&&&&&&&"  ,"</srvnum>"
                     ,"<srvano>"
                     ,  out.atdsrvano using "&&"          ,"</srvano>"
                     ,"<lignum>"
                     ,  out.lignum    using "&&&&&&&&&&"  ,"</lignum>"
                     ,"<ligdat>"
                     ,  out.ligdat    using "dd/mm/yyyy"  ,"</ligdat>"
                     ,"<lighor>"
                     ,  out.lighorinc clipped             ,"</lighor>"
                     ,"<solnom>"
                     ,  out.c24solnom clipped             ,"</solnom>"
                     ,"<suc>"
                     ,  out.succod    using "&&&&&"        ,"</suc>" #"&&"          ,"</suc>"
                     ,"<ramo>"
                     ,  out.ramcod    using "&&&&"        ,"</ramo>"
                     ,"<apol>"
                     ,  out.aplnumdig using "&&&&&&&&&"   ,"</apol>"
                     ,"<item>"
                     ,  out.itmnumdig using "&&&&&&&"     ,"</item>"
                     ,"<viginc>"
                     ,  out.viginc    using "dd/mm/yyyy"  ,"</viginc>"
                     ,"<vigfnl>"
                     ,  out.vigfnl    using "dd/mm/yyyy"  ,"</vigfnl>"
                     ,"<segnom>"
                     ,  out.segnom    clipped             ,"</segnom>"
                     ,"<dddseg>"
                     ,  out.segdddcod clipped             ,"</dddseg>"
                     ,"<telseg>"
                     ,  out.segteltxt clipped             ,"</telseg>"
                     ,"<corsus>"
                     ,  out.corsus    clipped             ,"</corsus>"
                     ,"<cornom>"
                     ,  out.cornom    clipped             ,"</cornom>"
                     ,"<dddcor>"
                     ,  out.cordddcod clipped             ,"</dddcor>"
                     ,"<telcor>"
                     ,  out.corteltxt clipped             ,"</telcor>"
                     ,"<vcldes>"
                     ,  out.vcldes    clipped             ,"</vcldes>"
                     ,"<vcllicnum>"
                     ,  out.vcllicnum clipped             ,"</vcllicnum>"
                     ,"<vclchsnum>"
                     ,  out.vclchsnum clipped             ,"</vclchsnum>"
                     ,"<anofab>"
                     ,  out.vclanofbc clipped             ,"</anofab>"
                     ,"<anomod>"
                     ,  out.vclanomdl clipped             ,"</anomod>"
                     ,"<cgccpfnum>"
                     ,  out.cgccpfnum using "&&&&&&&&&&&&","</cgccpfnum>"
                     ,"<cgcord>"
                     ,  out.cgcord    using "&&&&"        ,"</cgcord>"
                     ,"<cgccpfdig>"
                     ,  out.cgccpfdig using "&&"          ,"</cgccpfdig>"
                     ,"<texto>"
                     ,  out.adcmsgtxt[1,50]   clipped
                     ,  out.adcmsgtxt[51,100] clipped     ,"</texto>"

                     ,"<vstnum>"
                     ,  out.vstnumdig       using "&&&&&&&&&"     ,"</vstnum>"
                     ,"<prporg>"
                     ,  out.prporg          using "&&"            ,"</prporg>"
                     ,"<prpnum>"
                     ,  out.prpnumdig       using "&&&&&&&&"      ,"</prpnum>"
                     ,"<vclcod>"
                     ,  out.vclcoddig       using "&&&&&"         ,"</vclcod>"
                     ,"<empcod>"
                     ,  out.vdrrprgrpcod    using "&&&&&"        ,"</empcod>"
                     ,"<lojcod>"
                     ,  out.vdrrprempcod    using "&&&&&"        ,"</lojcod>"

                   if out.vdrpbsavrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<pbsfrq>"
                     ,  out.vdrpbsavrfrqvlr using "&&&&&&&&&&.&&","</pbsfrq>"
                   end if

                   if out.vdrvgaavrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<vgafrq>"
                     ,  out.vdrvgaavrfrqvlr using "&&&&&&&&&&.&&","</vgafrq>"
                   end if

                   if out.vdrdiravrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<latdirfrq>"
                     ,  out.vdrdiravrfrqvlr using "&&&&&&&&&&.&&","</latdirfrq>"
                   end if

                   if out.vdresqavrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<latesqfrq>"
                     ,  out.vdresqavrfrqvlr using "&&&&&&&&&&.&&","</latesqfrq>"
                   end if

                   if out.ocuesqavrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<ocuesqfrq>"
                     ,  out.ocuesqavrfrqvlr using "&&&&&&&&&&.&&","</ocuesqfrq>"
                   end if

                   if out.ocudiravrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<ocudirfrq>"
                     ,  out.ocudiravrfrqvlr using "&&&&&&&&&&.&&","</ocudirfrq>"
                   end if

                   if out.esqrtravrvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                      ,"<espesqfrq>"
                      ,  out.esqrtravrvlr using "&&&&&&&&&&.&&"  ,"</espesqfrq>"
                   end if

                   if out.dirrtravrvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                      ,"<espdirfrq>"
                      ,  out.dirrtravrvlr using "&&&&&&&&&&.&&"  ,"</espdirfrq>"
                   end if

                   if out.vdrqbvavrfrqvlr is not null then
                      let ws.arquivo = ws.arquivo clipped
                     ,"<qbvfrq>"
                     ,  out.vdrqbvavrfrqvlr using "&&&&&&&&&&.&&","</qbvfrq>"
                   end if

     let ws.arquivo = ws.arquivo clipped
                     ,"<datprg>"
                     ,  out.atddatprg       using "dd/mm/yyyy"   ,"</datprg>"
                     ,"<horprg>"
                     ,  out.atdhorprg       clipped              ,"</horprg>"
                     ,"<horprv>"
                     ,  out.atdhorpvt       clipped              ,"</horprv>"
                     ,"<stt>"
                     ,  ws.atdetpdes        clipped              ,"</stt>"
                     ,"<atntip>"
                     ,  out.atntip          clipped              ,"</atntip>"
                     ,"<end>"
                     ,  out.endereco        clipped              ,"</end>"
                     ,"<bairro>"
                     ,  out.brrnom          clipped              ,"</bairro>"
                     ,"<cid>"
                     ,  out.cidnom          clipped              ,"</cid>"
                     ,"<uf>"
                     ,  out.ufdcod          clipped              ,"</uf>"
                     ,"<contt>"
                     ,  out.lclcttnom       clipped              ,"</contt>"
                     ,"</XML>"
     begin work
      call ctx14g00_msg(1         ,    # codigo da msg
                        out.lignum,    # ligacao
                        out.atdsrvnum, # servico
                        out.atdsrvano, # ano do servico
                        "LAUDO_VIDROS")# titulo
           returning ws.c24trxnum
      call ctx14g00_msgdst(ws.c24trxnum,out.email,"cts19m07",1) # 1-email
      if out.vdrrprgrpcod = 2  then  # abravauto
         call ctx14g00_msgdst(ws.c24trxnum,
                              "portoseguro@abravauto.com.br",
                              "cts19m07",
                              1)    # 1-email   2-pager
        #if out.vdrrprempcod = 39 or   # mecanica de vidros #arnaldo 18/02/03
        #   out.vdrrprempcod = 74 then # regional pacaembu
        #   call ctx14g00_msgdst(ws.c24trxnum,
        #                        "georgios@mecanicadevidros.com.br",
        #                        "cts19m07",
        #                        1)    # 1-email   2-pager
        #   call ctx14g00_msgdst(ws.c24trxnum,
        #                        "arnaldo.cardoso@portoseguro.com.br",
        #                        "cts19m07",
        #                        1)    # 1-email   2-pager
        #   call ctx14g00_msgdst(ws.c24trxnum,
        #                        "carlos.ruiz@portoseguro.com.br",
        #                        "cts19m07",
        #                        1)    # 1-email   2-pager
        #end if
      end if
     commit work
     let ws.ext     = ".doc"    # extensao do arquivo
     let ws.comando = "echo '",ws.arquivo  clipped,"' > ",
                      ws.c24trxnum using "&&&&&&&&",ws.ext
     run ws.comando

     update dammtrx
         set c24msgtrxstt = 9   # STATUS DE ENVIO
     where c24trxnum = ws.c24trxnum

 ####call ctx14g00_msgok(ws.c24trxnum)
     call ctx14g00_envia(ws.c24trxnum,ws.ext)

 end function

#---------------------------------------------------------------------------
 function cts19m07_rec_vistoria(lr_param)
#---------------------------------------------------------------------------

define lr_param record
   lignum like datmligacao.lignum
end record

define lr_retorno record
   sinvstnum    like ssamsin.sinvstnum,
   sinvstano    like ssamsin.sinvstano
end record

initialize lr_retorno.* to null

   select sinvstnum, sinvstano
   into   lr_retorno.sinvstnum,
          lr_retorno.sinvstano
   from   datrligsinvst
   where  lignum = lr_param.lignum

   return lr_retorno.*

end function

#---------------------------------------------------------------------------
 function cts19m07_rec_sinistro(lr_param)
#---------------------------------------------------------------------------

define lr_param record
  sinvstnum    like ssamsin.sinvstnum    ,
  sinvstano    like ssamsin.sinvstano    ,
  lignum       like datmligacao.lignum   ,
  atdsrvnum    like datmservico.atdsrvnum,
  atdsrvano    like datmservico.atdsrvano
end record

define lr_retorno record
  sinano       like ssamsin.sinano,
  sinnum       like ssamsin.sinnum,
  ramcod       like ssamsin.ramcod
end record


initialize lr_retorno.* to null
   call figrc072_setTratarIsolamento() -- > psi 223689

   call ssata666(lr_param.sinvstnum,
                 lr_param.sinvstano,
                 lr_param.lignum   ,
                 lr_param.atdsrvnum,
                 lr_param.atdsrvano,
                 "A")
   returning lr_retorno.ramcod,lr_retorno.sinano,lr_retorno.sinnum

       if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função ssata666 indisponivel no momento ! Avise a Informatica !" sleep 2
           return lr_retorno.sinano,
                  lr_retorno.sinnum
       end if        -- > 223689


   return lr_retorno.sinano,
          lr_retorno.sinnum

end function

#RightFax - Inicio
##--------------------------------------------#
report rep_reparo1(r_cts19m07, l_frqvlrfarois, l_sin)
##--------------------------------------------#

 define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          like gcakfilial.endnum
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint
 end record

 define l_frqvlrfarois decimal(15,5)

 define r_cts19m07   record
    enviar           char (01),
    dddcod           like datmreclam.dddcod,
    faxnum           like datmreclam.faxnum,
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    destino          char (24)          ,
    nomeloja         like adikvdrrpremp.vdrrprempnom,
    atntip           char (09),
    endereco         char (65),
    brrnom           like datmlcl.brrnom,
    lclbrrnom        like datmlcl.lclbrrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclcttnom        like datmlcl.lclcttnom,

    lignum           dec (10,0),
    ligdat           date      ,
    lighorinc        datetime hour to minute,
    c24solnom        char(15),
    succod           smallint, # projeto succod
    ramcod           dec (4,0),
    aplnumdig        dec (9,0),
    itmnumdig        dec (7,0),
    viginc           date      ,
    vigfnl           date      ,
    segnom           char(50),
    segdddcod        char(04),
    segteltxt        char(20),
    corsus           char(06),
    cornom           char(40),
    cordddcod        char(04),
    corteltxt        char(20),
    vcldes           char(40),
    vcllicnum        char(07),
    vclchsnum        char(20),
    vclanofbc        datetime year to year,
    vclanomdl        datetime year to year,
    clscod           char(03),
    clsdes           char(40),
    frqvlr           dec(15,5),
    atldat           date,
    atlhor           datetime hour to second,
    cgccpfnum        dec(12,0),
    cgcord           dec(04,0),
    cgccpfdig        dec(02,0),
    adcmsgtxt        char(100),
    vdrpbsfrqvlr     dec(15,5),
    vdrvgafrqvlr     dec(15,5),
    vdresqfrqvlr     dec(15,5),
    vdrdirfrqvlr     dec(15,5),
    atdsrvnum        dec(10,0),
    atdsrvano        dec(02,0),
    vstnumdig        dec(09,0),
    prporg           dec(02,0),
    prpnumdig        dec(09,0),
    vclcoddig        dec(05,0),
    vdrrprgrpcod     dec(05,0),
    vdrrprempcod     dec(05,0),
    vcltip           char (01),
    vdrpbsavrfrqvlr  dec (15,5),
    vdrvgaavrfrqvlr  dec (15,5),
    vdrdiravrfrqvlr  dec (15,5),
    vdresqavrfrqvlr  dec (15,5),
    atdhorpvt        datetime hour to minute,
    atdhorprg        datetime hour to minute,
    atddatprg        date ,
    atdetpcod        smallint,
    atmstt           smallint,
    atldat1          date,
    atldat2          date,
    atlhor1          datetime hour to second,
    atlhor2          datetime hour to second,
    ocuesqfrqvlr     dec (15,5),
    ocudirfrqvlr     dec (15,5),
    ocuesqavrfrqvlr  dec (15,5),
    ocudiravrfrqvlr  dec (15,5),
    vdrqbvfrqvlr     dec (14,2),
    vdrqbvavrfrqvlr  dec (14,2),
    atntip1          smallint ,
    esqrtrfrqvlr     decimal(15,5),
    dirrtrfrqvlr     decimal(15,5),
    esqrtravrvlr     decimal(15,5),
    dirrtravrvlr     decimal(15,5),
    drtfrlvlr        decimal(15,5),
    esqfrlvlr        decimal(15,5),
    esqmlhfrlvlr     decimal(15,5),
    drtmlhfrlvlr     decimal(15,5),
    drtnblfrlvlr     decimal(15,5),
    esqnblfrlvlr     decimal(15,5),
    esqpscvlr        decimal(15,5),
    drtpscvlr        decimal(15,5),
    drtlntvlr        decimal(15,5),
    esqlntvlr        decimal(15,5)
 end record

 define ws2          record
    cordddcod        like gcakfilial.dddcod,
    corteltxt        like gcakfilial.teltxt,
    servico          char (13),
    atdetpdes        like datketapa.atdetpdes
 end record

 define l_sin      record
       sinvstnum  like datrligsinvst.sinvstnum,
       sinvstano  like datrligsinvst.sinvstano,
       sinano     like ssamsin.sinano,
       sinnum     like ssamsin.sinnum
       end record

 define l_data       date,
        l_hora2      datetime hour to minute

 output ###report to  pipe ws_pipe
    left   margin  00
    right  margin  80
    top    margin  00
    bottom margin  00
    page   length  70

 format

 on every row

    initialize ws2.*   to null
   #let ws2.destino = "NUCLEUS CARGLASS"

    #-------------------------------------------------------------------
    # Quando 1a. solicitacao conteudo null, Re-envio ja vem c/ conteudo
    #-------------------------------------------------------------------
    if r_cts19m07.ligdat  is null   then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let r_cts19m07.ligdat    = l_data
       let r_cts19m07.lighorinc = l_hora2
    end if
    #---> Utilizacao da nova funcao de comissoes p/ enderecamento
    initialize r_gcakfilial.* to null
    call fgckc811(r_cts19m07.corsus)
         returning r_gcakfilial.*
    let ws2.cordddcod = r_gcakfilial.dddcod
    let ws2.corteltxt = r_gcakfilial.teltxt
    #------------------------------------------------------------

    let ws2.servico = r_cts19m07.atdsrvnum using "&&&&&&&",
                  "-",r_cts19m07.atdsrvano using "&&"

    select atdetpdes
         into ws2.atdetpdes
         from datketapa
        where atdetpcod = r_cts19m07.atdetpcod
          and atdetpstt = "A"

    if r_cts19m07.enviar = "F" then

       if ws_fax  =  "GSF"   then
          if r_cts19m07.dddcod > 0099  then
             print column 001, r_cts19m07.dddcod using "&&&&";
          else
             print column 001, r_cts19m07.dddcod using "&&&";
          end if
          if r_cts19m07.faxnum > 99999999  then  ## Anatel - > 9999999  then
             print r_cts19m07.faxnum using "&&&&&&&&&";  ## Anatel -"&&&&&&&&";
          else
             if r_cts19m07.faxnum > 9999999  then   ## Anatel > 999999  then
                print r_cts19m07.faxnum using "&&&&&&&&";
             else
                print r_cts19m07.faxnum using "&&&&&&&";  ## Anatel "&&&&&&";
             end if
          end if

          print column 001                        ,
          "@"                                     ,  #---> Delimitador
          r_cts19m07.destino                      ,  #---> Destinat. Cx Postal
          "*CTVD"                                 ,  #---> Sistema/Subsistema
          r_cts19m07.faxch1   using "&&&&&&&&&&"  ,  #---> Numero/Ano Servico
          r_cts19m07.faxch2   using "&&&&&&&&&&"  ,  #---> Sequencia
          "@"                                     ,  #---> Delimitador
          r_cts19m07.destino                      ,  #---> Destinat.(Informix)
          "@"                                     ,  #---> Delimitador
          "CENTRAL 24 HORAS"                      ,  #---> Quem esta enviando
          "@"                                     ,  #---> Delimitador
          "PORTO.TIF"                             ,  #---> Arquivo Logotipo
          "@"                                     ,  #---> Delimitador
          "semcapa"                                  #---> Nao tem cover page
       end if

       if ws_fax  =  "VSI"   then
          print column 001, "@+IMAGE[porto.tif]"
          skip 7 lines
       end if

    end if

    if r_cts19m07.enviar  =  "I"   then
       print column 000, ascii(27),"E",ascii(27),"&l#0"
       print column 001, "Enviar para: ", r_cts19m07.destino clipped,
             column 058, "Fax: ", "(", r_cts19m07.dddcod clipped, ")",
                         r_cts19m07.faxnum using "<<<<<<<<&"   ## Anatel
       print column 001, "Loja.......: ", r_cts19m07.vdrrprempcod
                                          using "#####","-",
                                          r_cts19m07.nomeloja
       skip 1 lines
    end if

    print column 001, "_____________________ SOLICITACAO DE REPARO NOS VIDROS _________________________"
    #if r_cts19m07.enviar  =  "F" then
       print column 001, "Empresa....: ", ##r_cts19m07.destino clipped,
                         r_cts19m07.vdrrprempcod using "#####"," ",   # loja
                         r_cts19m07.nomeloja
    #else
    #   skip 1 line
    #end if
    print column 001, "Solicitante: ", r_cts19m07.c24solnom,
          column 059, "Status: ",      ws2.atdetpdes
    print column 001, "No. Servico: ", ws2.servico,"  ",
                      "No. LIGACAO: ", r_cts19m07.lignum using "<<<<<<<<<&"
    print column 001, "Data/Hora..: ", r_cts19m07.ligdat,
                                "   ", r_cts19m07.lighorinc
    print column 001, "Vistoria...: ", l_sin.sinvstnum using "<<<<<<<<<<",
                                       "-", l_sin.sinvstano
    print column 001, "Sinistro...: ", l_sin.sinnum using "<<<<<<<<<<",
                                       "-", l_sin.sinano
    skip 1 line

    print column 005, "Autorizamos o reparo nos vidros do veiculo conforme as seguintes condicoes: "
    skip 1 line

    print column 001, "______________________________ DADOS DO SEGURADO _______________________________"
    skip 1 line
    if r_cts19m07.vstnumdig is not null then
       print column 001, "Vistoria...: ", r_cts19m07.vstnumdig
    else
       if r_cts19m07.prpnumdig is not null then
          print column 001, "Proposta...: ",
                            r_cts19m07.prporg    using "&&","-",
                            r_cts19m07.prpnumdig clipped
       else
          print column 001, "Apolice....: ",
                            r_cts19m07.succod    using "<<<&&", "/",#"&&"        , "/", projeto succod
                            r_cts19m07.aplnumdig using "<<<<<<<& &", "/",
                            r_cts19m07.itmnumdig using "<<<<<& &",
                column 040, "Vigencia...: ", r_cts19m07.viginc,
                                      " a ", r_cts19m07.vigfnl
       end if
    end if
    print column 001, "Atendimento: ",r_cts19m07.atntip
    print column 001, "Endereco...: ",r_cts19m07.endereco  clipped
    if  r_cts19m07.lclbrrnom is not null and
        r_cts19m07.lclbrrnom <> " "      and
        r_cts19m07.lclbrrnom <> "."      then
        let r_cts19m07.brrnom = r_cts19m07.brrnom clipped, " - ",
                                r_cts19m07.lclbrrnom
    end if
    print column 001, "Bairro.....: ",r_cts19m07.brrnom    clipped,
          column 040, "Cidade.....: ",r_cts19m07.cidnom    clipped," - "
                                     ,r_cts19m07.ufdcod
    print column 001, "Contato....: ",r_cts19m07.lclcttnom clipped
   #skip 1 line

    print column 001, "Segurado...: ", r_cts19m07.segnom
    print column 001, "CGC/CPF....: ";
                print r_cts19m07.cgccpfnum using "<<<<<<<<<<<&";
                print "/", r_cts19m07.cgcord using "&&&&";
                print "-", r_cts19m07.cgccpfdig using "&&",
          column 040, "Telefone...: ",
                           r_cts19m07.segdddcod, " ", r_cts19m07.segteltxt
    print column 001, "Dt.Visita..: ", r_cts19m07.atddatprg,"-",
                                       r_cts19m07.atdhorprg,
          column 035, "Prev.Chegada: ",r_cts19m07.atdhorpvt
    skip 1 line

    print column 001, "Corretor...: ", r_cts19m07.corsus, " - ",
                                       r_cts19m07.cornom
    print column 001, "Telefone...: ",
                          ws2.cordddcod, " ", ws2.corteltxt

    skip 1 lines

    print column 001, "______________________________ DADOS DO VEICULO ________________________________"
    skip 1 line

    print column 001, "Veiculo....: ", r_cts19m07.vcldes
    skip 1 line

    print column 001, "Chassi.....: ", r_cts19m07.vclchsnum  clipped
    skip 1 line

    print column 001, "Placa......: ", r_cts19m07.vcllicnum
    skip 1 line

    print column 001, "Fabr/Modelo: ", r_cts19m07.vclanofbc, " / ",
                                       r_cts19m07.vclanomdl
    skip 1 lines

    print column 001, "_________________________________ CONDICOES ____________________________________"
    skip 1 line

    print column 001, "Clausula...: ", r_cts19m07.clscod,    " - ",
                                       r_cts19m07.clsdes
    skip 1 line

    print column 014, "Franquia:",
          column 035, "Avariados:"

    print column 001, "Para-brisa..: ",r_cts19m07.vdrpbsfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrpbsavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Traseiro....: ",r_cts19m07.vdrvgafrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrvgaavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Lat.Esquerdo: ",r_cts19m07.vdresqfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdresqavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Lat.Direito.: ",r_cts19m07.vdrdirfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrdiravrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Oculo Dir...: ",r_cts19m07.ocudirfrqvlr using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.ocudiravrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Oculo Esq...: ",r_cts19m07.ocuesqfrqvlr using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.ocuesqavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Quebra Vento: ",r_cts19m07.vdrqbvfrqvlr using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrqbvavrfrqvlr using "<,<<<,<<<,<<&.&&"

    # -- OSF 9377 - Fabrica de Software, Katiucia -- #
    if r_cts19m07.vdrrprgrpcod <> 1     and
       r_cts19m07.clscod       <> "071" and
       r_cts19m07.clscod       <> "077" then
       print column 001, "Retrov. Dir.: ", r_cts19m07.dirrtrfrqvlr
                                           using "<,<<<,<<<,<<&.&&"
            ,column 035, r_cts19m07.dirrtravrvlr using "<,<<<,<<<,<<&.&&"
       print column 001, "Retrov. Esq.: ", r_cts19m07.esqrtrfrqvlr
                                           using "<,<<<,<<<,<<&.&&"
            ,column 035, r_cts19m07.esqrtravrvlr using "<,<<<,<<<,<<&.&&"
    end if

    if r_cts19m07.clscod = "076" or
       r_cts19m07.clscod = "76R" then

       if l_frqvlrfarois is null then
          let l_frqvlrfarois = 25
       end if

       print column 001, "Farol Dir...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Esq...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Mi Dir: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtmlhfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Mi Esq: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqmlhfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Ne Dir: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtnblfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Ne Esq: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqnblfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Pisca Dir...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtpscvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Pisca Esq...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqpscvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Lanter. Dir.: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtlntvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Lanter. Esq.: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqlntvlr using "<,<<<,<<<,<<&.&&"

    end if

    skip 1 line
    if r_cts19m07.adcmsgtxt is not null  then
      #skip 1 lines
       print column 001, "________________________________ OBSERVACOES ___________________________________"
       skip 1 line
       print column 001, r_cts19m07.adcmsgtxt[1,50]
       print column 001, r_cts19m07.adcmsgtxt[51,100]
       skip 1 line
    end if
    if r_cts19m07.enviar  =  "I"   then
       skip 19 line
    end if

  on last row
    print ascii(12)

 end report  ###  rep_reparo1

function cts19m07_reparo1(r_cts19m07, l_frqvlrfarois, l_sin, l_docHandle)

 define l_docHandle    integer
 define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          like gcakfilial.endnum
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint
 end record

 define l_frqvlrfarois decimal(15,5)

 define r_cts19m07   record
    enviar           char (01),
    dddcod           like datmreclam.dddcod,
    faxnum           like datmreclam.faxnum,
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    destino          char (24)          ,
    nomeloja         like adikvdrrpremp.vdrrprempnom,
    atntip           char (09),
    endereco         char (65),
    brrnom           like datmlcl.brrnom,
    lclbrrnom        like datmlcl.lclbrrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclcttnom        like datmlcl.lclcttnom,

    lignum           dec (10,0),
    ligdat           date      ,
    lighorinc        datetime hour to minute,
    c24solnom        char(15),
    succod           smallint, # projeto succod
    ramcod           dec (4,0),
    aplnumdig        dec (9,0),
    itmnumdig        dec (7,0),
    viginc           date      ,
    vigfnl           date      ,
    segnom           char(50),
    segdddcod        char(04),
    segteltxt        char(20),
    corsus           char(06),
    cornom           char(40),
    cordddcod        char(04),
    corteltxt        char(20),
    vcldes           char(40),
    vcllicnum        char(07),
    vclchsnum        char(20),
    vclanofbc        datetime year to year,
    vclanomdl        datetime year to year,
    clscod           char(03),
    clsdes           char(40),
    frqvlr           dec(15,5),
    atldat           date,
    atlhor           datetime hour to second,
    cgccpfnum        dec(12,0),
    cgcord           dec(04,0),
    cgccpfdig        dec(02,0),
    adcmsgtxt        char(100),
    vdrpbsfrqvlr     dec(15,5),
    vdrvgafrqvlr     dec(15,5),
    vdresqfrqvlr     dec(15,5),
    vdrdirfrqvlr     dec(15,5),
    atdsrvnum        dec(10,0),
    atdsrvano        dec(02,0),
    vstnumdig        dec(09,0),
    prporg           dec(02,0),
    prpnumdig        dec(09,0),
    vclcoddig        dec(05,0),
    vdrrprgrpcod     dec(05,0),
    vdrrprempcod     dec(05,0),
    vcltip           char (01),
    vdrpbsavrfrqvlr  dec (15,5),
    vdrvgaavrfrqvlr  dec (15,5),
    vdrdiravrfrqvlr  dec (15,5),
    vdresqavrfrqvlr  dec (15,5),
    atdhorpvt        datetime hour to minute,
    atdhorprg        datetime hour to minute,
    atddatprg        date ,
    atdetpcod        smallint,
    atmstt           smallint,
    atldat1          date,
    atldat2          date,
    atlhor1          datetime hour to second,
    atlhor2          datetime hour to second,
    ocuesqfrqvlr     dec (15,5),
    ocudirfrqvlr     dec (15,5),
    ocuesqavrfrqvlr  dec (15,5),
    ocudiravrfrqvlr  dec (15,5),
    vdrqbvfrqvlr     dec (14,2),
    vdrqbvavrfrqvlr  dec (14,2),
    atntip1          smallint ,
    esqrtrfrqvlr     decimal(15,5),
    dirrtrfrqvlr     decimal(15,5),
    esqrtravrvlr     decimal(15,5),
    dirrtravrvlr     decimal(15,5),
    drtfrlvlr        decimal(15,5),
    esqfrlvlr        decimal(15,5),
    esqmlhfrlvlr     decimal(15,5),
    drtmlhfrlvlr     decimal(15,5),
    drtnblfrlvlr     decimal(15,5),
    esqnblfrlvlr     decimal(15,5),
    esqpscvlr        decimal(15,5),
    drtpscvlr        decimal(15,5),
    drtlntvlr        decimal(15,5),
    esqlntvlr        decimal(15,5)
 end record

 define ws2          record
    cordddcod        like gcakfilial.dddcod,
    corteltxt        like gcakfilial.teltxt,
    servico          char (13),
    atdetpdes        like datketapa.atdetpdes
 end record

 define l_sin      record
       sinvstnum  like datrligsinvst.sinvstnum,
       sinvstano  like datrligsinvst.sinvstano,
       sinano     like ssamsin.sinano,
       sinnum     like ssamsin.sinnum
       end record

 define l_data       date,
        l_hora2      datetime hour to minute

 define l_path         char(500)
       ,l_path2        char(500)
       ,l_path_item    char(500)
       ,l_caminho      char(500)
       ,l_i            smallint
       ,l_ind          smallint

 let l_path = "/report/data/file/cts_reparo"

 let l_caminho = l_path clipped ,"/ddd_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.dddcod clipped)

 let l_caminho = l_path clipped ,"/numero_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.faxnum clipped)

 let l_caminho = l_path clipped ,"/nome_empresa" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.destino clipped)

 let l_caminho = l_path clipped ,"/numero_servico_cabecalho" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.faxch1 clipped)

 let l_caminho = l_path clipped ,"/ano_servico_cabecalho" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.faxch2 clipped)

 let l_caminho = l_path clipped ,"/endereco_imagem_logo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,"\\\\nt112\\jasper3\\atendimento_rightfax\\logo.jpg" clipped)

 let l_caminho = l_path clipped ,"/codigo_empresa_reparo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vdrrprempcod clipped)

 let l_caminho = l_path clipped ,"/nome_empresa_reparo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.nomeloja clipped)

 let l_caminho = l_path clipped ,"/nome_solicitante" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.c24solnom clipped)

 initialize r_gcakfilial.* to null
 call fgckc811(r_cts19m07.corsus)
      returning r_gcakfilial.*
 let ws2.cordddcod = r_gcakfilial.dddcod
 let ws2.corteltxt = r_gcakfilial.teltxt

 let ws2.servico = r_cts19m07.atdsrvnum using "&&&&&&&",
               "-",r_cts19m07.atdsrvano using "&&"

 select atdetpdes
      into ws2.atdetpdes
   from datketapa
  where atdetpcod = r_cts19m07.atdetpcod
    and atdetpstt = "A"

 let l_caminho = l_path clipped ,"/etapa_atendimento" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws2.atdetpdes clipped)

 let l_caminho = l_path clipped ,"/numero_servico" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws2.servico clipped)

 let l_caminho = l_path clipped ,"/numero_ligacao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.lignum clipped)

 let l_caminho = l_path clipped ,"/data_solicitacao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.ligdat clipped)

 let l_caminho = l_path clipped ,"/hora_solicitacao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.lighorinc clipped)

 let l_caminho = l_path clipped ,"/numero_vistoria" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_sin.sinvstnum clipped)

 let l_caminho = l_path clipped ,"/ano_vistoria" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_sin.sinvstano clipped)

 let l_caminho = l_path clipped ,"/numero_sinistro" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_sin.sinnum clipped)

 let l_caminho = l_path clipped ,"/ano_sinistro" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_sin.sinano clipped)

 let l_path2 = "/segurado"

 let l_caminho = l_path clipped, l_path2 clipped,"/sucursal" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.succod clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.aplnumdig clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/item_apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.itmnumdig clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/vigencia_inicial" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.viginc clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/vigencia_final" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vigfnl clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/atendimento" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.atntip clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/endereco" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.endereco clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/bairro" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.brrnom clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/cidade" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.cidnom clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/uf" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.ufdcod clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/nome_contato" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.lclcttnom clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/nome_segurado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.segnom clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/numero_cpf" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.cgccpfnum clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/ordem_cnpj" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.cgcord clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/digito_cpf" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.cgccpfdig clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/ddd" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.segdddcod clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/telefone" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.segteltxt clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/data_atendimento" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.atddatprg clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/hora_atendimento" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.atdhorprg clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/hora_previsao_chegada" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.atdhorpvt clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/susep_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.corsus clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/nome_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.cornom clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/ddd_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws2.cordddcod clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/telefone_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws2.corteltxt clipped)

 let l_path2 = "/veiculo"

 let l_caminho = l_path clipped, l_path2 clipped,"/descricao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vcldes clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/chassi" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vclchsnum clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/placa" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vcllicnum clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/ano_fabricacao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vclanofbc clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/ano_modelo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.vclanomdl clipped)

 let l_path2 = "/condicoes"

 let l_caminho = l_path clipped, l_path2 clipped,"/codigo_clausula" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.clscod clipped)

 let l_caminho = l_path clipped, l_path2 clipped,"/descricao_clausula" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts19m07.clsdes clipped)

 let l_i   = 0
 let l_ind = 0
 for l_i = 1 to 20
    let l_ind = l_i - 1
    let l_path_item = l_path clipped ,"/condicoes/item_condicoes[",l_ind using"<<<<","]"

    case l_i
      when 1
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Para-brisa"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.vdrpbsfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.vdrpbsavrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 2
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Traseiro"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.vdrvgafrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.vdrvgaavrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 3
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Lat.Esquerdo"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.vdresqfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.vdresqavrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 4
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Lat.Direito"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.vdrdirfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.vdrdiravrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 5
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Oculo Dir"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.ocudirfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.ocudiravrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 6
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Oculo Esq"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.ocuesqfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.ocuesqavrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 7
         let l_caminho = l_path_item clipped ,"/label" clipped
         let l_itens[l_i].nom_cond = "Quebra Vento"
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

         let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
         let l_itens[l_i].vlr_franq = r_cts19m07.vdrqbvfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

         let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
         let l_itens[l_i].vlr_avari = r_cts19m07.vdrqbvavrfrqvlr
         call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
     when 8
         if r_cts19m07.vdrrprgrpcod <> 1     and
            r_cts19m07.clscod       <> "071" and
            r_cts19m07.clscod       <> "077" then
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Retrov. Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = r_cts19m07.dirrtrfrqvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.dirrtravrvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if
     when 9
         if r_cts19m07.vdrrprgrpcod <> 1     and
            r_cts19m07.clscod       <> "071" and
            r_cts19m07.clscod       <> "077" then
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Retrov. Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = r_cts19m07.esqrtrfrqvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqrtravrvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if
     when 10
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.drtfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 11
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 12
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Mi Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.drtmlhfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 13
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Mi Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqmlhfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 14
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Ne Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.drtnblfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 15
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Farol Ne Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqnblfrlvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 16
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Pisca Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.drtpscvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 17
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Pisca Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqpscvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 18
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Lanter. Dir"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.drtlntvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

     when 19
         if r_cts19m07.clscod = "076" or
            r_cts19m07.clscod = "76R" then

            if l_frqvlrfarois is null then
               let l_frqvlrfarois = 25
            end if
            let l_caminho = l_path_item clipped ,"/label" clipped
            let l_itens[l_i].nom_cond = "Lanter. Esq"
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].nom_cond clipped)

            let l_caminho = l_path_item clipped ,"/valor_franquia" clipped
            let l_itens[l_i].vlr_franq = l_frqvlrfarois
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_franq clipped)

            let l_caminho = l_path_item clipped ,"/valor_avariados" clipped
            let l_itens[l_i].vlr_avari = r_cts19m07.esqlntvlr
            call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].vlr_avari clipped)
         end if

    end case




 end for



end function
#RightFax - Fim

#--------------------------------------------#
report rep_reparo2(r_cts19m07, l_frqvlrfarois, l_sin)
#--------------------------------------------#
 define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          like gcakfilial.endnum
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint
 end record

 define r_cts19m07   record
    enviar           char (01),
    dddcod           like datmreclam.dddcod,
    faxnum           like datmreclam.faxnum,
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    destino          char (24)          ,
    nomeloja         like adikvdrrpremp.vdrrprempnom,
    atntip           char (09),
    endereco         char (65),
    brrnom           like datmlcl.brrnom,
    lclbrrnom        like datmlcl.lclbrrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclcttnom        like datmlcl.lclcttnom,

    lignum           dec (10,0),
    ligdat           date      ,
    lighorinc        datetime hour to minute,
    c24solnom        char(15),
    succod           smallint, # projeto succod
    ramcod           dec (4,0),
    aplnumdig        dec (9,0),
    itmnumdig        dec (7,0),
    viginc           date      ,
    vigfnl           date      ,
    segnom           char(50),
    segdddcod        char(04),
    segteltxt        char(20),
    corsus           char(06),
    cornom           char(40),
    cordddcod        char(04),
    corteltxt        char(20),
    vcldes           char(40),
    vcllicnum        char(07),
    vclchsnum        char(20),
    vclanofbc        datetime year to year,
    vclanomdl        datetime year to year,
    clscod           char(03),
    clsdes           char(40),
    frqvlr           dec(15,5),
    atldat           date,
    atlhor           datetime hour to second,
    cgccpfnum        dec(12,0),
    cgcord           dec(04,0),
    cgccpfdig        dec(02,0),
    adcmsgtxt        char(100),
    vdrpbsfrqvlr     dec(15,5),
    vdrvgafrqvlr     dec(15,5),
    vdresqfrqvlr     dec(15,5),
    vdrdirfrqvlr     dec(15,5),
    atdsrvnum        dec(10,0),
    atdsrvano        dec(02,0),
    vstnumdig        dec(09,0),
    prporg           dec(02,0),
    prpnumdig        dec(09,0),
    vclcoddig        dec(05,0),
    vdrrprgrpcod     dec(05,0),
    vdrrprempcod     dec(05,0),
    vcltip           char (01),
    vdrpbsavrfrqvlr  dec (15,5),
    vdrvgaavrfrqvlr  dec (15,5),
    vdrdiravrfrqvlr  dec (15,5),
    vdresqavrfrqvlr  dec (15,5),
    atdhorpvt        datetime hour to minute,
    atdhorprg        datetime hour to minute,
    atddatprg        date ,
    atdetpcod        smallint,
    atmstt           smallint,
    atldat1          date,
    atldat2          date,
    atlhor1          datetime hour to second,
    atlhor2          datetime hour to second,
    ocuesqfrqvlr     dec (15,5),
    ocudirfrqvlr     dec (15,5),
    ocuesqavrfrqvlr  dec (15,5),
    ocudiravrfrqvlr  dec (15,5),
    vdrqbvfrqvlr     dec (14,2),
    vdrqbvavrfrqvlr  dec (14,2),
    atntip1          smallint ,
    esqrtrfrqvlr     decimal(15,5),
    dirrtrfrqvlr     decimal(15,5),
    esqrtravrvlr     decimal(15,5),
    dirrtravrvlr     decimal(15,5),
    drtfrlvlr        decimal(15,5),
    esqfrlvlr        decimal(15,5),
    esqmlhfrlvlr     decimal(15,5),
    drtmlhfrlvlr     decimal(15,5),
    drtnblfrlvlr     decimal(15,5),
    esqnblfrlvlr     decimal(15,5),
    esqpscvlr        decimal(15,5),
    drtpscvlr        decimal(15,5),
    drtlntvlr        decimal(15,5),
    esqlntvlr        decimal(15,5)
 end record

 define ws2          record
    cordddcod        like gcakfilial.dddcod,
    corteltxt        like gcakfilial.teltxt,
    servico          char (13),
    atdetpdes        like datketapa.atdetpdes
 end record

 define l_data        date,
        l_hora2       datetime houR to minute

 define l_frqvlrfarois decimal(15,5)

 define l_sin      record
        sinvstnum  like datrligsinvst.sinvstnum,
        sinvstano  like datrligsinvst.sinvstano,
        ramcod     like ssamsin.ramcod,
        sinano     like ssamsin.sinano,
        sinnum     like ssamsin.sinnum
        end record

 output
    left   margin  00
    right  margin  80
    top    margin  00
    bottom margin  00
    page   length  70

 format

 on every row

    initialize ws2.*   to null
   #let ws2.destino = "NUCLEUS CARGLASS"

    #-------------------------------------------------------------------
    # Quando 1a. solicitacao conteudo null, Re-envio ja vem c/ conteudo
    #-------------------------------------------------------------------
    if r_cts19m07.ligdat  is null   then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let r_cts19m07.ligdat    = l_data
       let r_cts19m07.lighorinc = l_hora2
    end if

    #---> Utilizacao da nova funcao de comissoes p/ enderecamento
    initialize r_gcakfilial.* to null
    call fgckc811(r_cts19m07.corsus)
         returning r_gcakfilial.*
    let ws2.cordddcod = r_gcakfilial.dddcod
    let ws2.corteltxt = r_gcakfilial.teltxt
    #------------------------------------------------------------

    let ws2.servico = r_cts19m07.atdsrvnum using "&&&&&&&",
                  "-",r_cts19m07.atdsrvano using "&&"

    select atdetpdes
         into ws2.atdetpdes
         from datketapa
        where atdetpcod = r_cts19m07.atdetpcod
          and atdetpstt = "A"

    print column 001, "_____________________ SOLICITACAO DE REPARO NOS VIDROS _________________________"
    print column 001, "Empresa....: ", r_cts19m07.destino clipped,
          column 025, r_cts19m07.vdrrprempcod using "#####"," ",   # loja
                      r_cts19m07.nomeloja
    print column 001, "Solicitante: ", r_cts19m07.c24solnom,
          column 059, "Status:",      ws2.atdetpdes
    print column 001, "No. Servico: ", ws2.servico,"  ",
                      "No. LIGACAO: ", r_cts19m07.lignum using "<<<<<<<<<&"
    print column 001, "Data/Hora..: ", r_cts19m07.ligdat,
                                "   ", r_cts19m07.lighorinc
    print column 001, "Vistoria...: ", l_sin.sinvstnum using "<<<<<<<<<<",
                                       "-", l_sin.sinvstano
    print column 001, "Sinistro...: ", l_sin.sinnum using "<<<<<<<<<<",
                                       "-", l_sin.sinano
    skip 1 line

    print column 005, "Autorizamos o reparo nos vidros do veiculo conforme as seguintes condicoes: "
    skip 1 line

    print column 001, "______________________________ DADOS DO SEGURADO _______________________________"
    skip 1 line
    if r_cts19m07.vstnumdig is not null then
       print column 001, "Vistoria...: ", r_cts19m07.vstnumdig
    else
       if r_cts19m07.prpnumdig is not null then
          print column 001, "Proposta...: ",
                            r_cts19m07.prporg    using "&&","-",
                            r_cts19m07.prpnumdig clipped
       else
          print column 001, "Apolice....: ",
                            r_cts19m07.succod    using "<<<&&", "/", #"&&"        , "/", projeto succod
                            r_cts19m07.aplnumdig using "<<<<<<<& &", "/",
                            r_cts19m07.itmnumdig using "<<<<<& &",
                column 040, "Vigencia...: ", r_cts19m07.viginc,
                                      " a ", r_cts19m07.vigfnl
       end if
    end if
    print column 001, "Atendimento: ",r_cts19m07.atntip
    print column 001, "Endereco...: ",r_cts19m07.endereco  clipped
    if  r_cts19m07.lclbrrnom is not null and
        r_cts19m07.lclbrrnom <> " "      and
        r_cts19m07.lclbrrnom <> "."      then
        let r_cts19m07.brrnom = r_cts19m07.brrnom clipped, " - ",
                                r_cts19m07.lclbrrnom
    end if

    print column 001, "Bairro.....: ",r_cts19m07.lclbrrnom clipped,
          column 040, "Cidade.....: ",r_cts19m07.cidnom    clipped," - "
                                     ,r_cts19m07.ufdcod
    print column 001, "Contato....: ",r_cts19m07.lclcttnom clipped

    print column 001, "Segurado...: ", r_cts19m07.segnom
    print column 001, "CGC/CPF....: ";
                print r_cts19m07.cgccpfnum using "<<<<<<<<<<<&";
                print "/", r_cts19m07.cgcord using "&&&&";
                print "-", r_cts19m07.cgccpfdig using "&&",
          column 040, "Telefone...: ",
                           r_cts19m07.segdddcod, " ", r_cts19m07.segteltxt
    print column 001, "Dt.Visita..: ", r_cts19m07.atddatprg,"-",
                                       r_cts19m07.atdhorprg,
          column 035, "Prev.Chegada: ",r_cts19m07.atdhorpvt
    skip 1 line

    print column 001, "Corretor...: ", r_cts19m07.corsus, " - ",
                                       r_cts19m07.cornom
    print column 001, "Telefone...: ",
                          ws2.cordddcod, " ", ws2.corteltxt

    skip 1 lines

    print column 001, "______________________________ DADOS DO VEICULO ________________________________"
    skip 1 line

    print column 001, "Veiculo....: ", r_cts19m07.vcldes
    skip 1 line

    print column 001, "Chassi.....: ", r_cts19m07.vclchsnum  clipped
    skip 1 line

    print column 001, "Placa......: ", r_cts19m07.vcllicnum
    skip 1 line

    print column 001, "Fabr/Modelo: ", r_cts19m07.vclanofbc, " / ",
                                       r_cts19m07.vclanomdl
    skip 1 lines

    print column 001, "_________________________________ CONDICOES ____________________________________"
    skip 1 line

    print column 001, "Clausula...: ", r_cts19m07.clscod,    " - ",
                                       r_cts19m07.clsdes
    skip 1 line

    print column 014, "Franquia:",
          column 035, "Avariados:"

    print column 001, "Para-brisa..: ",r_cts19m07.vdrpbsfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrpbsavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Traseiro....: ",r_cts19m07.vdrvgafrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrvgaavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Lat.Esquerdo: ",r_cts19m07.vdresqfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdresqavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Lat.Direito.: ",r_cts19m07.vdrdirfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrdiravrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Oculo Dir...: ",r_cts19m07.ocudirfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.ocudiravrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Oculo Esq...: ",r_cts19m07.ocuesqfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.ocuesqavrfrqvlr using "<,<<<,<<<,<<&.&&"

    print column 001, "Quebra Vento: ",r_cts19m07.vdrqbvfrqvlr
                                       using "<,<<<,<<<,<<&.&&",
          column 035, r_cts19m07.vdrqbvavrfrqvlr using "<,<<<,<<<,<<&.&&"

    # -- OSF 9377 - Fabrica de Software, Katiucia -- #
    if r_cts19m07.vdrrprgrpcod <> 1     and
       r_cts19m07.clscod       <> "071" and
       r_cts19m07.clscod       <> "077" then
       print column 001, "Retrov. Dir.: ", r_cts19m07.dirrtrfrqvlr
                                           using "<,<<<,<<<,<<&.&&"
            ,column 035, r_cts19m07.dirrtravrvlr using "<,<<<,<<<,<<&.&&"
       print column 001, "Retrov. Esq.: ", r_cts19m07.esqrtrfrqvlr
                                           using "<,<<<,<<<,<<&.&&"
            ,column 035, r_cts19m07.esqrtravrvlr using "<,<<<,<<<,<<&.&&"
    end if

    if r_cts19m07.clscod = "076" or
       r_cts19m07.clscod = "76R" then

       if l_frqvlrfarois is null then
          let l_frqvlrfarois = 25
       end if

       print column 001, "Farol Dir...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Esq...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Mi Dir: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtmlhfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Mi Esq: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqmlhfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Ne Dir: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtnblfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Farol Ne Esq: ", l_frqvlrfarois          using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqnblfrlvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Pisca Dir...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtpscvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Pisca Esq...: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqpscvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Lanter. Dir.: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.drtlntvlr using "<,<<<,<<<,<<&.&&"

       print column 001, "Lanter. Esq.: ", l_frqvlrfarois       using "<,<<<,<<<,<<&.&&"
            ,column 035,                   r_cts19m07.esqlntvlr using "<,<<<,<<<,<<&.&&"

    end if

    skip 1 line
    if r_cts19m07.adcmsgtxt is not null  then
       print column 001, "________________________________ OBSERVACOES ___________________________________"
       skip 1 line
       print column 001, r_cts19m07.adcmsgtxt[1,50]
       print column 001, r_cts19m07.adcmsgtxt[51,100]
       skip 1 line
    end if

  on last row
    print ascii(12)

 end report  ###  rep_reparo2
 #-----------------------------------------------------------------------------------------------------------
