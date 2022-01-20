#############################################################################
# Nome do Modulo: cts19m06                                         Marcelo  #
#                                                                  Gilberto #
# Solicitacao de reparos para danos nos vidros do veiculo          Mar/1998 #
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
# 03/03/1999  PSI 7913-8   Wagner       Alteracao na chamada deste modulo   #
#                                       (chamada por parametro)             #
#---------------------------------------------------------------------------#
# 30/07/1999  PSI 7243-5   Gilberto     Utilizacao de funcao para retornar  #
#                                       valor da franquia.                  #
#---------------------------------------------------------------------------#
# 30/07/1999  PSI 8611-8   Gilberto     Gravacao dos dados para interface   #
#                                       com a Nucleus CarGlass.             #
#---------------------------------------------------------------------------#
# 20/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de DDD e tele-  #
#                                       fone do segurado do cabecalho.      #
#---------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clau- #
#                                       sulas (ramo 31).                    #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 27/10/1999  PSI 9604-0   Gilberto     Incluir CGC/CPF do segurado no fax. #
#---------------------------------------------------------------------------#
# 30/11/1999  PSI 9838-8   Gilberto     Alterar mensagem de alerta quando   #
#                                       ja' existir solicitacao de reparo.  #
#---------------------------------------------------------------------------#
# 06/12/1999  PSI 9838-8   Wagner       Incluir acesso janela p/informar    #
#                                       ddd/telefone de contato.            #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 26/05/2000  PSI 10860-0  Akio         Exibir as franquias de vidros       #
#                                       clausulas 071 e X71                 #
#                                       Envio das franquias separadamente   #
#---------------------------------------------------------------------------#
# 19/06/2000  Telefone     Akio         Utilizar data de calculo(ABBMCASCO) #
#                                       para buscar valor de franquia para  #
#                                       clausula 071 e X71                  #
#---------------------------------------------------------------------------#
# 29/06/2000  PSI 10865-0  Ruiz         Inclusao da Funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 16/02/2001  Psi 11254-2  Ruiz         Consulta o Condutor do Veiculo      #
#---------------------------------------------------------------------------#
# 24/04/2001  psi 13042-7  Ruiz         Gerar numero de servico para laudo  #
#                                       de vidros.                          #
#---------------------------------------------------------------------------#
# 06/02/2002  CT 6823      Ruiz         Alerta para tipo de veiculos.       #
#---------------------------------------------------------------------------#
# Alterado : 23/07/2002 - Celso                                             #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 25/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 12/06/2003  Ronaldo Marques     OSF 21580      Inclusao da chamada da     #
#             Fabrica Software                   funcao ctx20g00a - vidros  #
#---------------------------------------------------------------------------#
# 20/04/2004  CT19080  Leandro(FSW)  Gravar a tabela  "ssamlauemserr"       #
#---------------------------------------------------------------------------#
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 14/05/2003  ivone ,meta    PSI184560 passa a emitir laudo de vidros inde- #
#                            OSF35106  pendente se a loja estiver relacio - #
#                                      nada com a oficina,a  chamada a      #
#                                     funcao será executada somente se      #
#                                     o atendimento for  um B14             #
#                                     aberto pela Central24hs.              #
#---------------------------------------------------------------------------#
# 25/10/2004  Meta, James   PSI 188514 Acrescentar tipo de solicitacao = 8  #
#---------------------------------------------------------------------------#
# 22/11/2004  CT 261661  Katiucia    Chamar funcao grava sinistro para B14  #
#---------------------------------------------------------------------------#
# 19/05/2005  Adriano, Meta  PSI191108  Criado campo emeviacod              #
#---------------------------------------------------------------------------#
# 03/02/2006  Priscila    Zeladoria   Buscar data e hora do banco de dados  #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
# 25/04/2007 Ligia Mattge  PSI208175 - envio p/email da loja, impressao do  #
#                                      nr do sinistro e vistoria            #
# 09/05/2007 Roberto Melo  CT 7051656 - Inclusao das funcoes                #
#                                            faemc603_apolice e             #
#                                            faemc603_item                  #
# 01/10/2008 Amilton, Meta Psi223689 Incluir tratamento de erro com a       #
#                                    global                                 #
# 13/08/2009 Sergio Burini PSI244236 Inclusão do Sub-Dairro                 #
# ---------- ------------- --------- ---------------------------------------#
# 10/09/2009 Amilton, Meta Psi247006 Incluir envio de email para sinistro   #
#                                    com os limites de vidros excedido      #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                   Projeto sucursal smallint            #
#---------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues         Correcao de ^M                       #
#---------------------------------------------------------------------------#
# 22/10/2010 Patricia W. PSI 260479  Espelho da Proposta (select para pegar #
#                                    clausulas das propostas)               #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#---------------------------------------------------------------------------#
# 14/02/2014  Interax    Procurar: RightFax             Projeto RightFax    #
#---------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
 globals "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 define m_status        integer
 define m_email_sinis   smallint
 define m_empcod        like isskfunc.empcod
 define m_funmat        like isskfunc.funmat
 define l_docHandle  integer                    #RightFax

 define d_cts19m06  record
    servico         char (13),
    c24solnom       like datmligacao.c24solnom,
    nom             like datmservico.nom,
    doctxt          char (32),
    corsus          like datmservico.corsus,
    cornom          like datmservico.cornom,
    cvnnom          char (19),
    vclcoddig       like datmservico.vclcoddig,
    vcldes          like datmservico.vcldes,
    vclanomdl       like datmservico.vclanomdl,
    vcllicnum       like datmservico.vcllicnum,
    vclcordes       char (11),
    tipvidro        like aackcls.clscod,
    vdrpbsavrfrqvlr like aacmclscnd.frqvlr,
    vdrvgaavrfrqvlr like aacmclscnd.frqvlr,
    vdrlattxt       char(15),
    vdrlatavrfrqvlr like aacmclscnd.frqvlr,
    vdrocutxt       char(15),
    vdrocuavrfrqvlr like aacmclscnd.frqvlr,
    vdrqbvavrfrqvlr like aacmclscnd.frqvlr,
    vdrrtrtxt       char(15),
    vdrrtravrfrqvlr like aacmclscnd.frqvlr,
    obstxt          char (100),
    obstxt_1        char (51),
    atdlibflg       char (01) ,
    atdtxt          char (58)                    ,
    atdlibdat       like datmservico.atdlibdat   ,
    atdlibhor       like datmservico.atdlibhor
 end record

 define m_mensagem  char(15),
        m_ja_chamou smallint

 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 define d_aux19m06  record
    vdrdiravrfrqvlr like aacmclscnd.frqvlr,
    vdresqavrfrqvlr like aacmclscnd.frqvlr,
    ocuesqavrfrqvlr like aacmclscnd.frqvlr,
    ocudiravrfrqvlr like aacmclscnd.frqvlr,
    esqrtravrfrqvlr like aacmclscnd.frqvlr,
    dirrtravrfrqvlr like aacmclscnd.frqvlr
 ## esqrtrfrqvlr    like aacmclscnd.frqvlr,
 ## dirrtrfrqvlr    like aacmclscnd.frqvlr
 end record

  define mr_vlrfrq76  record
         drtfrlvlr    integer,
         esqfrlvlr    integer,
         drtmlhfrlvlr integer,
         esqmlhfrlvlr integer,
         drtnblfrlvlr integer,
         esqnblfrlvlr integer,
         drtpscvlr    integer,
         esqpscvlr    integer,
         drtlntvlr    integer,
         esqlntvlr    integer,
         frqvlrfarois like aacmclscnd.frqvlr
  end record

 define w_cts19m06  record
    vigfnl          like abamapol.vigfnl,
    cnldat          like datmservico.cnldat,
    atdfnlhor       like datmservico.atdfnlhor,
    segnumdig       like gsakseg.segnumdig,
    cgccpfnum       like gsakseg.cgccpfnum,
    cgcord          like gsakseg.cgcord,
    cgccpfdig       like gsakseg.cgccpfdig,
    vclcorcod       like datmservico.vclcorcod,
    vclcordes       char (11),
    vclchsnum       char (20),
    edsviginc       like abbmdoc.viginc,
    solantcab       char (21),
    solantdes       char (19),
    clscndvlr       like aacmclscnd.clscndvlr,
    clscndreivlr    like aacmclscnd.clscndreivlr,
    tabnum          like itatvig.tabnum,
    msgtxt          char (40),
    telupdflg       dec(1,0),
    vidtrxflg       dec(1,0),
    cdtnom          like aeikcdt.cdtnom      ,
    cdtseq          like aeikcdt.cdtseq ,
    vstnumdig       like avlmlaudo.vstnumdig ,
    ligcvntip       like iddkdominio.cpocod,
    atddat          like datmservico.atddat,
    atdhor          like datmservico.atdhor,
    data            like datmservico.atddat,
    hora            like datmservico.atdhor,
    funmat          like datmservico.funmat,
    c24opemat       like datmservico.c24opemat,
    atdlibflg       like datmservico.atdlibflg,
    atdfnlflg       like datmservico.atdfnlflg,
    atdhorpvt       like datmservico.atdhorpvt,
    atdpvtretflg    like datmservico.atdpvtretflg,
    atddatprg       like datmservico.atddatprg,
    atdhorprg       like datmservico.atdhorprg,
    atdetpcod       like datmsrvacp.atdetpcod ,
    vdrpbsfrqvlr    like aacmclscnd.frqvlr,
    vdrvgafrqvlr    like aacmclscnd.frqvlr,
    vdresqfrqvlr    like aacmclscnd.frqvlr,
    vdrdirfrqvlr    like aacmclscnd.frqvlr,
    ocuesqfrqvlr    like aacmclscnd.frqvlr,
    ocudirfrqvlr    like aacmclscnd.frqvlr,
    vdrqbvfrqvlr    like aacmclscnd.frqvlr,
    dirrtrfrqvlr    like aacmclscnd.frqvlr,
    esqrtrfrqvlr    like aacmclscnd.frqvlr,
    atdprscod       like datmservico.atdprscod,
    srrcoddig       like datmservico.srrcoddig,
    vcltip          dec (01,0),
    vclchsinc       like abbmveic.vclchsinc,
    vclchsfnl       like abbmveic.vclchsfnl,
    flagf8          char (01),
    segdddcod       like gsakend.dddcod,
    segteltxt       like gsakend.teltxt ,
    lignum          like datmligacao.lignum,
    c24astcod       like datmligacao.c24astcod,
    c24astdes       char (55),
    atntip          smallint ,
    ocrendlgd       char (40),
    ocrendbrr       like datmlcl.lclbrrnom,
    ocrendcid       like datmlcl.cidnom,
    ocrufdcod       like datmlcl.ufdcod,
    ocrcttnom       like datmlcl.lclcttnom     ,
    alerta          char (01)                  ,
    clscod          like aackcls.clscod        ,
    atdrsdflg       like datmservico.atdrsdflg
 end record

 define a_cts19m06  record
    operacao        char (01)                    ,
    lclidttxt       like datmlcl.lclidttxt       ,
    lgdtxt          char (65)                    ,
    lgdtip          like datmlcl.lgdtip          ,
    lgdnom          like datmlcl.lgdnom          ,
    lgdnum          like datmlcl.lgdnum          ,
    brrnom          like datmlcl.brrnom          ,
    lclbrrnom       like datmlcl.lclbrrnom       ,
    endzon          like datmlcl.endzon          ,
    cidnom          like datmlcl.cidnom          ,
    ufdcod          like datmlcl.ufdcod          ,
    lgdcep          like datmlcl.lgdcep          ,
    lgdcepcmp       like datmlcl.lgdcepcmp       ,
    lclltt          like datmlcl.lclltt          ,
    lcllgt          like datmlcl.lcllgt          ,
    dddcod          like datmlcl.dddcod          ,
    lcltelnum       like datmlcl.lcltelnum       ,
    lclcttnom       like datmlcl.lclcttnom       ,
    lclrefptotxt    like datmlcl.lclrefptotxt    ,
    c24lclpdrcod    like datmlcl.c24lclpdrcod    ,
    ofnnumdig       like sgokofi.ofnnumdig       ,
    emeviacod       like datmlcl.emeviacod       ,
    celteldddcod    like datmlcl.celteldddcod    ,
    celtelnum       like datmlcl.celtelnum       ,
    endcmp          like datmlcl.endcmp
 end record

 define msg record
    linha1            char(40),
    linha2            char(40),
    linha3            char(40),
    linha4            char(40),
    linha5            char(40),
    linha6            char(40),
    linha7            char(40),
    linha8            char(40)
 end record

 define aux_atdsrvnum like datmservico.atdsrvnum
 define aux_atdsrvano like datmservico.atdsrvano
 define aux_today     char (10)
 define aux_hora      char (05)
 define aux_libhor    char (05)
 define aux_ano       char (02)
 define aux_libant    like datmservico.atdlibflg
 define prompt_key    char (01)
 define m_qtdvidro    smallint,
        m_qtdretro    smallint

 define m_cts19m06_prep smallint

 define mr_datmsrvext1 record like datmsrvext1.*

 define ml_cts19m06  record
        atdprscod    like datmservico.atdprscod,  # codigo do prestador
        nomprest     char(20),
        srrcoddig    like datmservico.srrcoddig,  # codigo da loja
        nomloja      char(30),
        cidnom       char(48),
        ufdcod       char(02),
        dddcod       like dpaksocor.dddcod,
        teltxt       like dpaksocor.teltxt,
        contato      char(20),
        horloja      char(52),
        atddatprg    like datmservico.atddatprg,
        atdhorprg    like datmservico.atdhorprg,
        atdhorpvt    like datmservico.atdhorpvt,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        atntip       char (12),         # ruiz
        alt_vidros   char (1),
        alt_loja     char (1),
        alt_lcloco   char (1),
        lignum       like datmligacao.lignum
 end record

  define mr_laudo     char (60)

  define m_sin   record
        sinvstnum  like datrligsinvst.sinvstnum,
        sinvstano  like datrligsinvst.sinvstano,
        ramcod  like ssamsin.ramcod,
        sinano  like ssamsin.sinano,
        sinnum  like ssamsin.sinnum
        end record

  define ml_abrir char(01)  # PSI 239.399 Clausula 077
  define m_lclbrrnom char(65)
#-------------------------#
function cts19m06_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select max(lauemserrseq) ",
                " from ssamlauemserr ",
               " where sinvstano = ? ",
                 " and sinvstnum = ? "

  prepare p_cts19m06_001 from l_sql
  declare c_cts19m06_001 cursor for p_cts19m06_001

  let l_sql = " insert into ssamlauemserr(sinvstano, ",
                                        " sinvstnum, ",
                                        " sinlauemserrtxt, ",
                                        " atldat, ",
                                        " atlmat, ",
                                        " atlemp, ",
                                        " lauemserrseq, ",
                                        " prdtipcod) ",
                                ##" values (?,?,?,today,?,?,?,2) "
                                " values (?,?,?,?,?,?,?,2) "

  prepare p_cts19m06_002 from l_sql
  ## Conta utilizacao por apolice
  let l_sql = " select count(*) " ,
                " from datrligapol a, ",
                     " datmligacao b ",
               " where a.succod = ? ",
                 " and a.ramcod = ? ",
                 " and a.aplnumdig = ? ",
                 " and a.itmnumdig = ? ",
                 " and b.lignum = a.lignum ",
                 " and b.c24astcod = ? "

  prepare p_cts19m06_003 from l_sql
  declare c_cts19m06_002 cursor for p_cts19m06_003

  let l_sql = " select atdetpcod ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) ",
                                    " from datmsrvacp ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ?) "
  prepare p_cts19m06_004 from l_sql
  declare c_cts19m06_003 cursor for p_cts19m06_004

  let l_sql = " select b.ligdat, ",
                     " b.lighorinc, ",
                     " b.c24astcod, ",
                     " b.atdsrvnum, ",
                     " b.atdsrvano ",
                " from datrligapol a, ",
                     " datmligacao b ",
               " where a.succod = ? and ",
                     " a.ramcod = ? and ",
                     " a.aplnumdig = ? and ",
                     " a.itmnumdig = ? and ",
                     " b.lignum = a.lignum ",
               " order by 1 desc, 3 "
  prepare p_cts19m06_005 from l_sql
  declare c_cts19m06_004 cursor for p_cts19m06_005

## Alberto
  let l_sql = "select grlinf[5,7] ", -- into l_perimetro
              "from igbkgeral ",
              "where mducod = 'VDR' ",
              "and grlchv = 'PARAMVIDRO' "
  prepare p_cts19m06_006 from l_sql
  declare c_cts19m06_005 cursor for p_cts19m06_006
## Alberto

  ## Conta utilizacao por proposta
  let l_sql = " select count(*) " ,
                " from datrligprp  a, ",
                     " datmligacao b ",
               " where a.prporg     = ? ",
                 " and a.prpnumdig  = ? ",
                 " and b.lignum     = a.lignum ",
                 " and b.c24astcod  = ? "

  prepare p_cts19m06_007 from l_sql
  declare c_cts19m06_006 cursor for p_cts19m06_007

  let l_sql = "select sinvstnum, sinvstano ",
              " from   datrligsinvst " ,
              " where  lignum = ? "
  prepare p_cts19m06_008 from l_sql
  declare c_cts19m06_007 cursor for p_cts19m06_008

  let l_sql = "select c24astcod  ",
              " from   datmligacao " ,
              " where  lignum = ? "
  prepare pcts19m06011 from l_sql
  declare ccts19m06011 cursor for pcts19m06011


  let l_sql = "select count(*) ",
              " from datmvstsin ",
              " where sinvstnum = ?",
              " and sinvstano = ? "
  prepare pcts19m06012 from l_sql
  declare ccts19m06012 cursor for pcts19m06012

  let l_sql = "select max(sinvstnum) ",
              " from datmvstsin ",
              " where sinvstano = ? "
  prepare pcts19m06013 from l_sql
  declare ccts19m06013 cursor for pcts19m06013

  let m_cts19m06_prep = true

end function

#------------------------------------------------------------
function cts19m06()
#------------------------------------------------------------

 define ws     record
    confirma   char(01),
    argval     char(200),
    comando    char(500),
    grvflg     smallint,
    atdetpcod  like datmsrvacp.atdetpcod,
    vclchsinc  like abbmveic.vclchsinc,
    vclchsfnl  like abbmveic.vclchsfnl,
    ret        integer,
    param      char(14),
    grlchv     like datkgeral.grlchv,
    hora       datetime hour to second,
    conta      integer,
    monta_sql  char(300),
    ligdat     like datmligacao.ligdat,
    lighorinc  like datmligacao.lighorinc,
    c24astcod  like datmligacao.c24astcod,
    c24astdes  char (55),
    atdsrvnum  like datmligacao.atdsrvnum,
    atdsrvano  like datmligacao.atdsrvano,
    servico    char (13),
    clalclcod  like abbmdoc.clalclcod,
    vclmrccod  like agbkveic.vclmrccod,
    vcltipcod  like agbkveic.vcltipcod,
    vclcoddig  like agbkveic.vclcoddig,
    senhaok    char (01),
    funnom     like isskfunc.funnom,
    ofnnumdig  like adikvdrrpremp.ofnnumdig,
    sinpricod  like adikvdrrpremp.sinpricod
 end record
 define erros         record
    x1                smallint,
    x2                smallint,
    x3                smallint,
    x4                smallint,
    x5                smallint,
    x6                smallint,
    x7                smallint,
    x8                smallint,
    x9                smallint,
    x10               smallint,
    x11               smallint,
    x12               smallint,
    qtd               smallint,
    clscod            like abbmclaus.clscod
 end record

 define b14_crit      record
        vencido       char (01),
        clausula      char (01),
        libera        char (01)
 end record

 ## Alberto 193690
 define b14_util      record
        qtde_apol     integer ,
        qtde_prp      integer ,
        can           smallint,
        limite        integer
 end record


 define l_c24astcod   like datmligacao.c24astcod

 define l_data      date,
        l_hora2     datetime hour to minute
 define l_sql char(500)

 let l_c24astcod  =  null
 let l_data       =  null
 let l_hora2      =  null

 let l_sql = ""
 initialize  b14_util.*  to  null

 #--------------------------------#
  let g_documento.atdsrvorg = 14
 #--------------------------------#

 initialize ws.*          to null
 initialize msg.*         to null
 initialize erros.*       to null
 initialize w_cts19m06.*  to null
 initialize d_cts19m06.*  to null
 initialize d_aux19m06.*  to null
 initialize aux_libant    to null
 initialize b14_crit.*    to null
 initialize a_cts19m06.*  to null
 initialize m_sin.*       to null
 initialize ml_cts19m06.* to  null
 initialize mr_datmsrvext1.*  to  null

 let l_c24astcod           = null
 let ml_cts19m06.lignum    = null
 let m_lclbrrnom           = null

 let ml_cts19m06.alt_loja   = "N"
 let ml_cts19m06.alt_vidros = "N"
 let ml_cts19m06.alt_lcloco = "N"

 let b14_crit.vencido  = "N"   ---> Docto. vencido?
 let b14_crit.clausula = "N"   ---> Docto. tem Clausula de Vidro?
 let b14_crit.libera   = "N"   ---> Libera Docto mesmo sem Clausula de Vidro?
 let ml_abrir          = "N"  # PSI 239.399 Clausula 077

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2

 let int_flag      = false
 let aux_today     = l_data
 let aux_hora      = l_hora2
 let aux_ano       = aux_today[9,10]

 if m_cts19m06_prep is null or
    m_cts19m06_prep <> true then
    call cts19m06_prepare()
 end if

 if g_documento.atdsrvnum is not null then
    #--------------------------------------------------------------------
    # Obtem documento do servico
    #--------------------------------------------------------------------

    ## Obtem a ultima ligacao com alteracao efetuada para o Servico
    let ml_cts19m06.lignum = null

    select a.lignum
    into   ml_cts19m06.lignum
    from   datmligacao a  , datmsrvext1 b
    where  a.atdsrvnum = b.atdsrvnum
    and    a.atdsrvano = b.atdsrvano
    and    a.lignum    = b.lignum
    and    a.atdsrvnum = g_documento.atdsrvnum
    and    a.atdsrvano = g_documento.atdsrvano
    and    a.c24astcod = "ALT"
    and    a.lignum    = (select max(c.lignum) from datmsrvext1 c
                      where  c.atdsrvnum = g_documento.atdsrvnum
                       and   c.atdsrvano = g_documento.atdsrvano )

    if ml_cts19m06.lignum is not null then
       let w_cts19m06.lignum = ml_cts19m06.lignum
    else    ##  se nao houver alteracao, localiza a ligacao do servico
       let w_cts19m06.lignum  = cts20g00_servico( g_documento.atdsrvnum,
                                                  g_documento.atdsrvano )
       let ml_cts19m06.lignum = w_cts19m06.lignum
    end if


    call cts20g01_docto(w_cts19m06.lignum)    # alterar incluir vistoria
         returning g_documento.succod,
                   g_documento.ramcod,
                   g_documento.aplnumdig,
                   g_documento.itmnumdig,
                   g_documento.edsnumref,
                   g_documento.prporg,
                   g_documento.prpnumdig,
                   g_documento.fcapacorg,
                   g_documento.fcapacnum,
                   g_documento.itaciacod

    # Busca Assunto original
    open ccts19m06011 using w_cts19m06.lignum
    whenever error continue
    fetch ccts19m06011 into g_documento.c24astcod
    whenever error stop

    if sqlca.sqlcode <> 0 then
       error "Erro ao localizar assunto original, Avise a informatica !"
    end if
 end if

 if g_documento.succod    is not null and
    g_documento.aplnumdig is not null and
    g_documento.itmnumdig is not null then
    call f_funapol_ultima_situacao
         (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
          returning g_funapol.*

    if g_documento.c24astcod = "B14" and
       g_documento.acao <> 'CON'     then
        #---------------------------------------------------------------------
        # Chama tela de verificacao de inconsistencias
        #---------------------------------------------------------------------
        call cts01g00 (g_documento.ramcod   ,
                       g_documento.succod   ,
                       g_documento.aplnumdig,
                       g_documento.itmnumdig,
                       g_documento.c24astcod,
                       "", "", "", "", "", "", l_data, "T")
             returning erros.*

        if erros.x1  = 02  or  erros.x2 = 02  or  erros.x3 = 02  or
           erros.x4  = 02  or  erros.x5 = 02  or  erros.x6 = 02  or
           erros.x7  = 02  or  erros.x8 = 02  or  erros.x9 = 02  or
           erros.x10 = 02                                        then
           let b14_crit.vencido = "S"
        end if
    end if
 end if
   # Alteracoes para o PSI 260479
   # Este IF externo garante que os procedimentos que estao dentro dele
   # sejam executados somente para atendimento com documento (apolice/proposta)
   if (g_documento.aplnumdig is not null or g_documento.prpnumdig is not null) then
      if g_documento.aplnumdig is null or g_documento.aplnumdig = 0 then
         if g_documento.prpnumdig is not null and g_documento.prpnumdig <> 0 then
            # PSI 260479 - Select especifico para clausulas da proposta
            let l_sql = "select clscod ",
                        "  from apbmclaus ",
                        " where prporgpcp = ? and  ",
                              " prpnumpcp = ? and ",
                              " clscod    in ('071','075','75R','076','76R','077')"
         end if
      else
         let l_sql = " select clscod ",
                      "  from abbmclaus ",
                      " where succod   = ? and ",
                           " aplnumdig = ? and ",
                           " itmnumdig = ? and ",
                           " dctnumseq = ? and ",
                           " clscod    in ('071','075','75R','076','76R','077')"
      end if

      prepare p_clausulas from l_sql
      declare ccts19m06_clausulas cursor for p_clausulas

      if g_documento.aplnumdig is null or g_documento.aplnumdig = 0 then
         if g_documento.prpnumdig is not null and g_documento.prpnumdig <> 0 then
            open ccts19m06_clausulas using g_documento.prporg,
                                           g_documento.prpnumdig
         end if
      else
         open ccts19m06_clausulas using g_documento.succod,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig,
                                g_funapol.dctnumseq
      end if

      #    foreach c_abbmclaus into w_cts19m06.clscod #patricia
      foreach ccts19m06_clausulas into w_cts19m06.clscod

        if w_cts19m06.clscod  = "077" then  # PSI 239.399 Clausula 077
           let ml_abrir = "S"
           let g_vdr_blindado = "S"         # Aqui é atribuido o valor para "S"
                                            # e no modulo cts19m04 PSI 239.399 Clausula 077
        end if

      ---> Docto. tem Clausula de Vidro
        let b14_crit.clausula = "S"

        if cta13m00_verifica_clausula(g_documento.succod       ,
                                      g_documento.aplnumdig    ,
                                      g_documento.itmnumdig    ,
                                      g_funapol.dctnumseq ,
                                      w_cts19m06.clscod ) then

           continue foreach
        end if
      end foreach
   end if

    ---> Docto. nao possui Clausula de Vidro
    if b14_crit.clausula = "N" then

       if g_documento.c24astcod = "B14" then
          let b14_crit.libera = "N"   ---> Nao Libera
       end if

       if g_documento.c24astcod = "B90" then

          if g_issk.acsnivcod >=7 then
             let b14_crit.libera = "S" ---> Libera direto p/ Laudo
          else
             let b14_crit.libera = "A" ---> Libera so com Autorizacao
          end if
       end if
    end if

    initialize msg.* to null

    if b14_crit.vencido  = "S" or
       b14_crit.clausula = "N" then

       let msg.linha1 = "NAO E' POSSIVEL SOLICITAR"
       let msg.linha2 = "REPARO DE VIDROS!"

       if b14_crit.vencido  = "S" and
          b14_crit.clausula = "N" then
          let msg.linha3 = "DOCUMENTO VENCIDO E NAO POSSUI CLAUSULAS"
          let msg.linha4 = "071, 075 OU 75R, 076, 76R ou 77 CONTRATADA!"
       else
          if b14_crit.vencido = "S" then
             let msg.linha4 = "DOCUMENTO VENCIDO!"
          else
             let msg.linha3 = "DOCUMENTO INFORMADO NAO POSSUI CLAUSULAS"
             let msg.linha4 = "071, 075 OU 75R, 076, 76R ou 77 CONTRATADA!"
          end if
       end if

       ---> Permite liberar o atendimento so com autorizacao
       if b14_crit.libera = "A" then
          let msg.linha6 = "DESEJA LIBERAR ATENDIMENTO?"

          call cts08g01_6l("A","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4,
                           msg.linha5,msg.linha6) returning ws.confirma

          if ws.confirma = "S" then

             call cta02m10(g_documento.c24astcod,"")
                  returning ws.senhaok, ws.funnom

             if ws.senhaok = "s" then

                call cta02m00_cria_tmp()
                call cta02m00_atz_just("N","S",ws.funnom)
             else
                return
             end if
          else
             return
          end if
       else
          if b14_crit.libera = "N" then  ---> Nao permite atendimento
             let msg.linha6 = " "

             call cts08g01_6l("A","N",msg.linha1,msg.linha2
                                     ,msg.linha3,msg.linha4,
                                      msg.linha5,msg.linha6)
                  returning ws.confirma
             return

          end if
       end if
       initialize w_cts19m06.alerta to null
    end if

 if g_documento.aplnumdig  is null  and
    g_documento.prporg     is null  and
    g_documento.prpnumdig  is null  and
    g_documento.vstnumdig  is null  then
    select aplnumdig,prpnumdig,vstnumdig
           into g_documento.aplnumdig,
                g_documento.prpnumdig,
                g_documento.vstnumdig
           from datmsrvext1
          where atdsrvnum = g_documento.atdsrvnum
            and atdsrvano = g_documento.atdsrvano
            and lignum    = w_cts19m06.lignum

    if g_documento.aplnumdig  is null  and
       g_documento.prporg     is null  and
       g_documento.prpnumdig  is null  and
       g_documento.vstnumdig  is null  then
       if sqlca.sqlcode = notfound then
          let msg.linha1 = "NAO E POSSIVEL ABRIR LAUDO DE VIDROS!"
          let msg.linha2 = "NENHUM DOCTO FOI INFORMADO!"
          let msg.linha4 = "DESEJA LIBERAR ATENDIMENTO?"

          call cts08g01("A","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4)
                        returning ws.confirma

          if ws.confirma = "S" then
             call cta02m10(g_documento.c24astcod,"")
                  returning ws.senhaok, ws.funnom
             if ws.senhaok = "s" then
                call cta02m00_cria_tmp()
                call cta02m00_atz_just("N","S",ws.funnom)
             else
                return
             end if
          else
             return
          end if
       end if
    end if
 end if


 open window w_cts19m06 at 04,02 with form "cts19m06"
                      attribute(form line 1)

 # Psi 247006 Retirado a tecla de função F3 Trocas a pedido da Anapaula
 if g_documento.atdsrvnum is null then
    display "(F1)Help,(F4)Condutor,(F5)Esp,(F6)Hist,(F8)Dest" to msgfun
 else
    display "(F1)Help,(F4)Condutor,(F5)Esp,(F6)Hist,(F8)Dest,(F9)Conclui" to msgfun
 end if

 #--------------------------------------------------------------------
 # Identificacao do CONVENIO
 #--------------------------------------------------------------------

 let w_cts19m06.ligcvntip = g_documento.ligcvntip

 select cpodes into d_cts19m06.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts19m06.ligcvntip

 if g_documento.atdsrvnum is not null then
    call consulta_cts19m06() returning ws.grvflg
    display by name d_cts19m06.*
    display by name d_cts19m06.c24solnom attribute (reverse)
    display by name d_cts19m06.cvnnom    attribute (reverse)

    if w_cts19m06.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
    end if
    call modifica_cts19m06() returning ws.grvflg
    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today  ,aux_hora)
       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then
       let d_cts19m06.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<& &"

       if not cts19m06_trocas("CRI") then
          clear form
          close window w_cts19m06
          return
       end if

    end if
    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       call figrc072_setTratarIsolamento()        --> 223689

       call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts19m06.nom      ,
                      d_cts19m06.corsus   ,
                      d_cts19m06.cornom   ,
                      d_cts19m06.cvnnom   ,
                      d_cts19m06.vclcoddig,
                      d_cts19m06.vcldes   ,
                      d_cts19m06.vclanomdl,
                      d_cts19m06.vcllicnum,
                      d_cts19m06.vclcordes

        if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
            return
         end if    --> 223689



       let d_cts19m06.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                 " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if
    if g_documento.vstnumdig is not null then
       let d_cts19m06.doctxt = "Vistoria: ", g_documento.vstnumdig
       call cts05g03(g_documento.vstnumdig)
           returning d_cts19m06.nom      ,
                     d_cts19m06.corsus   ,
                     d_cts19m06.cornom   ,
                     d_cts19m06.cvnnom   ,
                     d_cts19m06.vclcoddig,
                     d_cts19m06.vcldes   ,
                     d_cts19m06.vclanomdl,
                     d_cts19m06.vcllicnum,
                     ws.vclchsinc        ,
                     ws.vclchsfnl        ,
                     d_cts19m06.vclcordes,
                     w_cts19m06.cgccpfnum,
                     w_cts19m06.cgcord   ,
                     w_cts19m06.cgccpfdig
       let w_cts19m06.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl
    end if

    let w_cts19m06.c24astcod   = g_documento.c24astcod
    let d_cts19m06.c24solnom   = g_documento.solnom

    display by name d_cts19m06.*
    display by name d_cts19m06.c24solnom attribute (reverse)
    display by name d_cts19m06.cvnnom    attribute (reverse)

    call inclui_cts19m06() returning ws.grvflg
    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum,aux_atdsrvano,w_cts19m06.funmat,
                     w_cts19m06.data,w_cts19m06.hora)
       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = aux_atdsrvnum
          and atdsrvano = aux_atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = aux_atdsrvnum
                              and atdsrvano = aux_atdsrvano)
       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico
          set    c24opemat = null
          where  atdsrvnum = aux_atdsrvnum
          and    atdsrvano = aux_atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          end if
       end if
    end if
 end if
 clear form
 let int_flag = false                #psi184560  ivone

 close window w_cts19m06
end function  ###  cts19m06

#----------------------------------------------------------------------
function consulta_cts19m06()
#----------------------------------------------------------------------
 define ws            record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    vclcorcod         like datmservico.vclcorcod,
    funmat            like datmservico.funmat   ,
    funnom            like isskfunc.funnom       ,
    dptsgl            like isskfunc.dptsgl       ,
    codigosql         integer,
    lignum            like datmligacao.lignum    ,
    adcmsgtxt         char(100)                  ,
    clscod            like aackcls.clscod,
    empcod            like datmservico.empcod                         #Raul, Biz    
 end record

 define lr_clau76     record
        drtfrlvlr     integer,
        esqfrlvlr     integer,
        esqmlhfrlvlr  integer,
        drtmlhfrlvlr  integer,
        drtnblfrlvlr  integer,
        esqnblfrlvlr  integer,
        esqpscvlr     integer,
        drtpscvlr     integer,
        drtlntvlr     integer,
        esqlntvlr     integer
 end record

 define l_qtd_farol   smallint
 define l_frqvlrfarois like aacmclscnd.frqvlr



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  lr_clau76.*  to  null

 initialize  ws.*  to  null

 initialize ws.*  to null

 let l_qtd_farol = null

 select nom      ,
        vclcoddig,
        vcldes   ,
        vclanomdl,
        vcllicnum,
        corsus   ,
        cornom   ,
        vclcorcod,
        funmat   ,
        atddat   ,
        atdhor   ,
        atdlibflg,
        atdfnlflg,
        atdhorpvt,
        atddatprg,
        atdhorprg,
        atdlibdat,
        atdlibhor,
        empcod                                                        #Raul, Biz
   into d_cts19m06.nom      ,
        d_cts19m06.vclcoddig,
        d_cts19m06.vcldes   ,
        d_cts19m06.vclanomdl,
        d_cts19m06.vcllicnum,
        d_cts19m06.corsus   ,
        d_cts19m06.cornom   ,
        ws.vclcorcod        ,
        ws.funmat           ,
        w_cts19m06.atddat   ,
        w_cts19m06.atdhor   ,
        w_cts19m06.atdlibflg,
        w_cts19m06.atdfnlflg,
        w_cts19m06.atdhorpvt,
        w_cts19m06.atddatprg,
        w_cts19m06.atdhorprg,
        d_cts19m06.atdlibdat,
        d_cts19m06.atdlibhor,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return false
 end if

 initialize ws.clscod to null
 select vdrpbsavrfrqvlr,
        vdrvgaavrfrqvlr,
        vdrdiravrfrqvlr,
        vdresqavrfrqvlr,
        ocuesqavrfrqvlr,
        ocudiravrfrqvlr,
        vdrqbvavrfrqvlr,
        dirrtravrvlr,
        esqrtravrvlr,
        dirrtrfrgvlr,
        esqrtrfrgvlr,
        adcmsgtxt      ,
        atntip         ,
        segdddcod      ,
        segteltxt      ,
        clscod,
        drtfrlvlr,
        esqfrlvlr,
        esqmlhfrlvlr,
        drtmlhfrlvlr,
        drtnblfrlvlr,
        esqnblfrlvlr,
        esqpscvlr,
        drtpscvlr,
        drtlntvlr,
        esqlntvlr
   into
        d_cts19m06.vdrpbsavrfrqvlr,
        d_cts19m06.vdrvgaavrfrqvlr,
        d_aux19m06.vdrdiravrfrqvlr,
        d_aux19m06.vdresqavrfrqvlr,
        d_aux19m06.ocuesqavrfrqvlr,
        d_aux19m06.ocudiravrfrqvlr,
        d_cts19m06.vdrqbvavrfrqvlr,
        d_aux19m06.dirrtravrfrqvlr,
        d_aux19m06.esqrtravrfrqvlr,
        w_cts19m06.dirrtrfrqvlr,
        w_cts19m06.esqrtrfrqvlr,
        ws.adcmsgtxt,
        w_cts19m06.atntip,
        w_cts19m06.segdddcod,
        w_cts19m06.segteltxt,
        ws.clscod,
        lr_clau76.drtfrlvlr,
        lr_clau76.esqfrlvlr,
        lr_clau76.esqmlhfrlvlr,
        lr_clau76.drtmlhfrlvlr,
        lr_clau76.drtnblfrlvlr,
        lr_clau76.esqnblfrlvlr,
        lr_clau76.esqpscvlr,
        lr_clau76.drtpscvlr,
        lr_clau76.drtlntvlr,
        lr_clau76.esqlntvlr
   from datmsrvext1
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano  and
        lignum    = w_cts19m06.lignum

  if sqlca.sqlcode = notfound  then
     error " Servico nao encontrado na tabela datmsrvext1. AVISE A INFORMATICA!"
     return false
  end if

  if d_aux19m06.vdrdiravrfrqvlr is not null and
     d_aux19m06.vdresqavrfrqvlr is not null then
     let d_cts19m06.vdrlattxt = "Ambos"
     let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
  else
     if d_aux19m06.vdrdiravrfrqvlr is not null then
        let d_cts19m06.vdrlattxt = "Direito"
        let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
     else
        if d_aux19m06.vdresqavrfrqvlr is not null then
           let d_cts19m06.vdrlattxt = "Esquerdo"
           let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdresqavrfrqvlr
        end if
     end if
  end if

  if d_aux19m06.ocudiravrfrqvlr is not null and
     d_aux19m06.ocuesqavrfrqvlr is not null then
     let d_cts19m06.vdrocutxt = "Ambos"
     let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocudiravrfrqvlr
  else
     if d_aux19m06.ocudiravrfrqvlr is not null then
        let d_cts19m06.vdrocutxt = "Direito"
        let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocudiravrfrqvlr
     else
        if d_aux19m06.ocuesqavrfrqvlr is not null then
           let d_cts19m06.vdrocutxt = "Esquerdo"
           let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocuesqavrfrqvlr
        end if
     end if
  end if

  let g_esprtrflg = "N"

  if d_aux19m06.dirrtravrfrqvlr is not null and
     d_aux19m06.esqrtravrfrqvlr is not null then
     let d_cts19m06.vdrrtrtxt       = "Ambos"
     let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.dirrtravrfrqvlr
     let g_esprtrflg                = "S"
  else
     if d_aux19m06.dirrtravrfrqvlr is not null then
        let d_cts19m06.vdrrtrtxt       = "Direito"
        let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.dirrtravrfrqvlr
        let g_esprtrflg         = "S"
     else
        if d_aux19m06.esqrtravrfrqvlr is not null then
           let d_cts19m06.vdrrtrtxt       = "Esquerdo"
           let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.esqrtravrfrqvlr
           let g_esprtrflg                = "S"
        end if
     end if
  end if

  call cts19m06_busca_franq(d_cts19m06.vclcoddig,
                            d_cts19m06.vclanomdl,
                            ws.clscod)
       returning l_frqvlrfarois

  call cts19m06_info_cls76(lr_clau76.drtfrlvlr,
                           lr_clau76.esqfrlvlr,
                           lr_clau76.drtmlhfrlvlr,
                           lr_clau76.esqmlhfrlvlr,
                           lr_clau76.drtnblfrlvlr,
                           lr_clau76.esqnblfrlvlr,
                           lr_clau76.drtpscvlr,
                           lr_clau76.esqpscvlr,
                           lr_clau76.drtlntvlr,
                           lr_clau76.esqlntvlr,
                           l_frqvlrfarois) # VALOR FIXO ATE A CRIACAO DO CAMPO NA TABELA DATMSRVEXT1
                           #mr_vlrfrq76.frqvlrfarois)


  returning l_qtd_farol

  if ws.clscod is not null then
     let m_mensagem = "Clausula: ", ws.clscod
     display m_mensagem to mensagem attribute(reverse)
  end if

  display by name d_cts19m06.*

  let d_cts19m06.obstxt[1,50]   = ws.adcmsgtxt[1,50]
  let d_cts19m06.obstxt_1       = ws.adcmsgtxt[51,100]
 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts19m06.lclidttxt   ,
                         a_cts19m06.lgdtip      ,
                         a_cts19m06.lgdnom      ,
                         a_cts19m06.lgdnum      ,
                         a_cts19m06.lclbrrnom   ,
                         a_cts19m06.brrnom      ,
                         a_cts19m06.cidnom      ,
                         a_cts19m06.ufdcod      ,
                         a_cts19m06.lclrefptotxt,
                         a_cts19m06.endzon      ,
                         a_cts19m06.lgdcep      ,
                         a_cts19m06.lgdcepcmp   ,
                         a_cts19m06.lclltt      ,
                         a_cts19m06.lcllgt      ,
                         a_cts19m06.dddcod      ,
                         a_cts19m06.lcltelnum   ,
                         a_cts19m06.lclcttnom   ,
                         a_cts19m06.c24lclpdrcod,
                         a_cts19m06.celteldddcod,
                         a_cts19m06.celtelnum,
                         a_cts19m06.endcmp,
                         ws.codigosql, a_cts19m06.emeviacod

 let m_lclbrrnom = a_cts19m06.lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts19m06.lclbrrnom,
                                a_cts19m06.lclbrrnom)
      returning a_cts19m06.lclbrrnom

 select ofnnumdig into a_cts19m06.ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 let a_cts19m06.lgdtxt = a_cts19m06.lgdtip clipped, " ",
                         a_cts19m06.lgdnom clipped, " ",
                         a_cts19m06.lgdnum using "<<<<#"
 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts19m06.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<&&"
 end if
 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts19m06.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                  " ", g_documento.prpnumdig using "<<<<<<<&&"
 end if
 if g_documento.vstnumdig is not null then
    let d_cts19m06.doctxt = "Vistoria: ", g_documento.vstnumdig
 end if

 #--------------------------------------------------------------------
 # Dados da ligacao
 #--------------------------------------------------------------------
 select c24astcod, ligcvntip,
        c24solnom
   into w_cts19m06.c24astcod,
        w_cts19m06.ligcvntip,
        d_cts19m06.c24solnom
   from datmligacao
  where lignum  =  w_cts19m06.lignum

  select cpodes
   into d_cts19m06.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts19m06.ligcvntip

 #--------------------------------------------------------------------
 # Descricao do ASSUNTO
 #--------------------------------------------------------------------

 let d_cts19m06.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 #--------------------------------------------------------------------
 # Obtem COR DO VEICULO
 #--------------------------------------------------------------------

 select cpodes
   into d_cts19m06.vclcordes
   from iddkdominio
  where cponom    = "vclcorcod"  and
        cpocod    = ws.vclcorcod

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts19m06.atdtxt = w_cts19m06.atddat        clipped, " ",
                         w_cts19m06.atdhor        clipped, " ",
                         upshift(ws.dptsgl)       clipped, " ",
                         ws.funmat using "&&&&&&" clipped, " ",
                         upshift(ws.funnom)
 let aux_libant = w_cts19m06.atdlibflg

 if w_cts19m06.atdlibflg = "N"  then
    let d_cts19m06.atdlibdat = w_cts19m06.atddat
    let d_cts19m06.atdlibhor = w_cts19m06.atdhor
 end if
 let d_cts19m06.atdlibflg = w_cts19m06.atdlibflg

 return true
end function  ###  consulta_cts19m06

#--------------------------------------------------------------------
 function modifica_cts19m06()
#--------------------------------------------------------------------

 define ws           record
    codigosql        integer,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    prompt_key       char (01),
    retorno          integer
 end record

 define hist_cts19m06 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key    char (01)



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts19m06.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts19m06.*  to  null

 initialize ws.*  to null
 call input_cts19m06() returning hist_cts19m06.*
 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts19m06.*    to null
    initialize w_cts19m06.*    to null
    clear form
    return false
 end if
 return true

end function  ###  modifica_cts19m06()

#-------------------------------------------------------------------------------
 function inclui_cts19m06()
#-------------------------------------------------------------------------------

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
        ,stt             smallint
  end record

 define hist_cts19m06   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record
 define ws              record
        prompt_key          char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                   ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        vclatmflg       like abbmveic.vclatmflg    ,
        vclcoddig       like abbmveic.vclcoddig    ,
        vstnumdig       like abbmveic.vstnumdig    ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        telupdflg       dec  (1,0)                 ,
        cordddcod       like gcakfilial.dddcod,
        corteltxt       like gcakfilial.teltxt,
        vclanofbc       like abbmveic.vclanofbc,
        cdtseq          like aeikcdt.cdtseq        ,
        ok              smallint                   ,
        datatu          date,
        horatu          datetime hour to minute    ,
        txthist         char(70),
        msgtxt          char(40),
        confirma        char(01),
        grava           char(01),
        sinvstnum       like datmvstsin.sinvstnum,
        sinvstano       like datmvstsin.sinvstano
 end record

 define lignum_srv     like datmligacao.lignum

 define l_data     date,
        l_hora2    datetime hour to minute



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     lignum_srv  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  r_gcakfilial.*  to  null

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        initialize  r_gcakfilial.*  to  null

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        let lignum_srv = null

 while true

   initialize ws.*  to null

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.datatu = l_data
   let ws.horatu = l_hora2

   let g_documento.acao = "INC"
   call input_cts19m06() returning hist_cts19m06.*

   if  int_flag  then
       let int_flag = false
       initialize d_cts19m06.*    to null
       initialize w_cts19m06.*    to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts19m06.data is null  then
       let w_cts19m06.data   = aux_today
       let w_cts19m06.hora   = aux_hora
       let w_cts19m06.funmat = g_issk.funmat
   end if
   initialize ws.caddat to null
   initialize ws.cadhor to null
   initialize ws.cademp to null
   initialize ws.cadmat to null

   if  w_cts19m06.atdfnlflg is null  then
       let w_cts19m06.atdfnlflg = "N"
       let w_cts19m06.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------

 if g_documento.lclocodesres = "S" then
    let w_cts19m06.atdrsdflg = "S"
 else
    let w_cts19m06.atdrsdflg = "N"
 end if

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   if d_cts19m06.atdlibflg = "N" then
      exit while
   end if

   begin work

   call cts10g03_numeracao( 2, "1" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS19M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano
   call cts19m06_envia(aux_atdsrvnum,
                       aux_atdsrvano,
                       0,0 )
      call cts19m06_aciona()

   if int_flag  then
      let int_flag = false
      let ws.retorno = false
      exit while
   end if
   if (g_documento.ramcod    is  not  null  and
       g_documento.succod    is  not  null  and
       g_documento.aplnumdig is  not  null  and
       g_documento.itmnumdig is  not  null) or

      (g_documento.vstnumdig  is  not  null) or

      (g_documento.prporg    is  not  null  and
       g_documento.prpnumdig is  not  null) then

      if g_documento.succod    is not null and
         g_documento.aplnumdig is not null and
         g_documento.itmnumdig is not null then
         select vclanofbc
          into ws.vclanofbc
          from abbmveic
         where succod    = g_documento.succod     and
               aplnumdig = g_documento.aplnumdig  and
               itmnumdig = g_documento.itmnumdig  and
               dctnumseq = g_funapol.vclsitatu
          if sqlca.sqlcode = notfound  then
             error " Dados do veiculo nao encontrado! AVISE A INFORMATICA!"
             prompt "" for char prompt_key
             let ws.retorno = false
             exit while
          end if

          select vigfnl
            into w_cts19m06.vigfnl
            from abamapol
           where succod    = g_documento.succod     and
                 aplnumdig = g_documento.aplnumdig

          select segnumdig,
                 viginc
            into w_cts19m06.segnumdig,
                 w_cts19m06.edsviginc
            from abbmdoc
           where succod    = g_documento.succod     and
                 aplnumdig = g_documento.aplnumdig  and
                 itmnumdig = g_documento.itmnumdig  and
                 dctnumseq = g_funapol.dctnumseq

          if w_cts19m06.segnumdig is not null  then
             select cgccpfnum, cgcord, cgccpfdig
               into w_cts19m06.cgccpfnum,
                    w_cts19m06.cgcord,
                    w_cts19m06.cgccpfdig
               from gsakseg
              where segnumdig = w_cts19m06.segnumdig
          end if
      end if
   end if

   #---> Utilizacao da nova funcao de comissoes p/ enderecamento
   initialize r_gcakfilial.* to null
   call fgckc811(d_cts19m06.corsus)
        returning r_gcakfilial.*
   let ws.cordddcod = r_gcakfilial.dddcod
   let ws.corteltxt = r_gcakfilial.teltxt
   #------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Grava ligacao e servico
  #-----------------------------------------------------------------------------
   begin work
   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts19m06.data         ,
                           w_cts19m06.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts19m06.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           aux_atdsrvnum           ,
                           aux_atdsrvano           ,
                           "","","",""             ,
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
                           ws.caddat,  ws.cadhor   ,
                           ws.cademp,  ws.cadmat    )
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if
   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let w_cts19m06.atdfnlflg = "S"
   let w_cts19m06.cnldat    = l_data

   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                g_documento.soltip  ,  # atdsoltip
                                g_documento.solnom  ,  # c24solnom
                                w_cts19m06.vclcorcod,
                                w_cts19m06.funmat   ,
                                d_cts19m06.atdlibflg,
                                d_cts19m06.atdlibhor,
                                d_cts19m06.atdlibdat,
                                w_cts19m06.data     ,  # atddat
                                w_cts19m06.hora     ,  # atdhor
                                ""                  ,  # atdlclflg
                                w_cts19m06.atdhorpvt,
                                w_cts19m06.atddatprg,
                                w_cts19m06.atdhorprg,
                                "V"                 ,  # atdtip
                                ""               ,     # atdmotnom
                                ""               ,     # atdvclsgl
                                w_cts19m06.atdprscod,
                                ""                  ,  # atdcstvlr
                                w_cts19m06.atdfnlflg,
                                w_cts19m06.atdfnlhor,
                                w_cts19m06.atdrsdflg,
                                ""               ,     # atddfttxt
                                ""               ,     # atddoctxt
                                w_cts19m06.c24opemat,
                                d_cts19m06.nom      ,
                                d_cts19m06.vcldes   ,
                                d_cts19m06.vclanomdl,
                                d_cts19m06.vcllicnum,
                                d_cts19m06.corsus   ,
                                d_cts19m06.cornom   ,
                                w_cts19m06.cnldat   ,
                                ""                  ,  # pgtdat
                                ""                  ,  # w_cts19m06.c24nomctt,
                                w_cts19m06.atdpvtretflg,
                                ""                  ,  # w_cts19m06.atdvcltip,
                                ""                  ,  # d_cts19m06.asitipcod,
                                ""                  ,  # socvclcod
                                d_cts19m06.vclcoddig,
                                "N"                 ,  # srvprlflg
                                w_cts19m06.srrcoddig,  # srrcoddig
                                "1"                 ,  # atdprinvlcod
                                g_documento.atdsrvorg )# atdsrvorg
        returning ws.tabname,
                  ws.codigosql
        if  ws.codigosql  <>  0  then
            error " Erro (", ws.codigosql, ") na gravacao da",
                  " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.prompt_key
            let ws.retorno = false
            exit while
        end if

 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia
 #------------------------------------------------------------------------------
   if w_cts19m06.atntip =  1    then    # atd na REDE
      let ws.grava   =  "S"             # carglass/abravauto
   else
      if w_cts19m06.atntip = 2  and     # atd a FORA DA REDE
         w_cts19m06.atdprscod = 2  then # abravauto
         let ws.grava  =  "S"
      end if
   end if

   if ws.grava    =   "S"   then
      if  a_cts19m06.operacao is null  then
          let a_cts19m06.operacao = "I"
      end if

      let a_cts19m06.lclbrrnom = m_lclbrrnom

      call cts06g07_local(a_cts19m06.operacao,
                          aux_atdsrvnum,
                          aux_atdsrvano,
                          1 ,
                          a_cts19m06.lclidttxt,
                          a_cts19m06.lgdtip,
                          a_cts19m06.lgdnom,
                          a_cts19m06.lgdnum,
                          a_cts19m06.lclbrrnom,
                          a_cts19m06.brrnom,
                          a_cts19m06.cidnom,
                          a_cts19m06.ufdcod,
                          a_cts19m06.lclrefptotxt,
                          a_cts19m06.endzon,
                          a_cts19m06.lgdcep,
                          a_cts19m06.lgdcepcmp,
                          a_cts19m06.lclltt,
                          a_cts19m06.lcllgt,
                          a_cts19m06.dddcod,
                          a_cts19m06.lcltelnum,
                          a_cts19m06.lclcttnom,
                          a_cts19m06.c24lclpdrcod,
                          a_cts19m06.ofnnumdig,
                          a_cts19m06.emeviacod,
                          a_cts19m06.celteldddcod,
                          a_cts19m06.celtelnum,
                          a_cts19m06.endcmp)
                returning ws.codigosql

      if  ws.codigosql is null  or
          ws.codigosql <> 0     then
          error " Erro (", ws.codigosql, ") na gravacao do",
                " local de ocorrencia. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.prompt_key
          let ws.retorno = false
          exit while
      end if
   end if
   #----------------------------------------------------------------------------
   # Grava etapas do acompanhamento
   #----------------------------------------------------------------------------
   call cts10g04_insere_etapa ( aux_atdsrvnum    ,
                                aux_atdsrvano    ,
                                w_cts19m06.atdetpcod,
                                w_cts19m06.atdprscod,
                                "",
                                "",
                                w_cts19m06.srrcoddig )
                      returning ws.codigosql
   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " etapa de acompanhamento (1). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let ws.atdetpdat = w_cts19m06.cnldat
   let ws.atdetphor = w_cts19m06.atdfnlhor
   let ws.etpfunmat = w_cts19m06.c24opemat

   #---------------------------------------------------------------------------
   # Grava relacionamento servico / apolice
   #---------------------------------------------------------------------------

   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0        then

       call cts10g02_grava_servico_apolice(aux_atdsrvnum         ,
                                           aux_atdsrvano         ,
                                           g_documento.succod   ,
                                           g_documento.ramcod   ,
                                           g_documento.aplnumdig,
                                           g_documento.itmnumdig,
                                           g_documento.edsnumref)
       returning ws.tabname,
                 ws.codigosql

       if  ws.codigosql <> 0  then
           error "Erro (", ws.codigosql, ") na gravacao do",
                 " relacionamento servico x apolice. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
       if g_documento.cndslcflg = "S"  then
          select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                 into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                 from tmpcondutor
          call grava_condutor(g_documento.succod,g_documento.aplnumdig,
                              g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                              ws.cgccpfdig,"D","CENTRAL24H") returning ws.cdtseq
               # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
          insert into datrsrvcnd
                     (atdsrvnum,
                      atdsrvano,
                      succod   ,
                      aplnumdig,
                      itmnumdig,
                      vclcndseq)
              values (aux_atdsrvnum        ,
                      aux_atdsrvano        ,
                      g_documento.succod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig,
                      ws.cdtseq)
          if  sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na gravacao do",
                    " relacionamento servico x condutor. AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
         end if
       end if
   end if
   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   if g_documento.vstnumdig is not null  then
   end if
   if w_cts19m06.edsviginc is null then
      let w_cts19m06.edsviginc = l_data
   end if
   if w_cts19m06.vigfnl    is null then
      let w_cts19m06.vigfnl    = l_data
   end if
   if w_cts19m06.vclchsnum is null then
      let w_cts19m06.vclchsnum = "99999999999999"
   end if
   if ws.vclanofbc is null then
      let ws.vclanofbc  = "2099"
   end if
   let d_cts19m06.obstxt = d_cts19m06.obstxt clipped
                          ,d_cts19m06.obstxt_1 clipped
   insert into datmsrvext1
               (lignum   ,        ligdat   ,
                lighorinc,        c24solnom,
                succod   ,        ramcod   ,
                aplnumdig,        itmnumdig,
                viginc   ,        vigfnl   ,
                segnom   ,        segdddcod,
                segteltxt,        corsus   ,
                cornom   ,        cordddcod,
                corteltxt,        vcldes   ,
                vcllicnum,        vclchsnum,
                vclanofbc,        vclanomdl,
                clscod   ,        clsdes   ,
                cgccpfnum,        cgcord   ,
                cgccpfdig,        adcmsgtxt,
                frqvlr   ,        vdrpbsfrqvlr,
                vdrvgafrqvlr,     vdresqfrqvlr,
                vdrdirfrqvlr,     atdsrvnum,
                atdsrvano   ,     vstnumdig,
                prporg      ,     prpnumdig,
                vclcoddig   ,     vdrrprgrpcod,
                vdrrprempcod,     vcltip,
                vdrpbsavrfrqvlr , vdrvgaavrfrqvlr,
                vdrdiravrfrqvlr , vdresqavrfrqvlr,
                atdhorpvt   ,     atdhorprg  ,
                atddatprg   ,     atdetpcod  ,
                atmstt      ,     ocuesqfrqvlr,
                ocudirfrqvlr,     ocuesqavrfrqvlr,
                ocudiravrfrqvlr,  vdrqbvfrqvlr,
                vdrqbvavrfrqvlr,  atntip      ,
                ocrendlgd      ,  ocrendbrr   ,
                ocrendcid      ,  ocrufdcod   ,
                ocrcttnom      ,  dirrtravrvlr,
                esqrtravrvlr   ,  dirrtrfrgvlr,
                esqrtrfrgvlr,
                drtfrlvlr,
                esqfrlvlr,
                esqmlhfrlvlr,
                drtmlhfrlvlr,
                drtnblfrlvlr,
                esqnblfrlvlr,
                esqpscvlr,
                drtpscvlr,
                drtlntvlr,
                esqlntvlr)
         values (ws.lignum, ws.datatu, ws.horatu,
                d_cts19m06.c24solnom,
                g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                w_cts19m06.edsviginc,
                w_cts19m06.vigfnl,
                d_cts19m06.nom,
                w_cts19m06.segdddcod,
                w_cts19m06.segteltxt,
                d_cts19m06.corsus,
                d_cts19m06.cornom,
                ws.cordddcod,
                ws.corteltxt,
                d_cts19m06.vcldes,
                d_cts19m06.vcllicnum,
                w_cts19m06.vclchsnum,
                ws.vclanofbc,
                d_cts19m06.vclanomdl,
                w_cts19m06.clscod   , #d_cts19m06.clscod,
                "COBERTURA DE VIDROS",#d_cts19m06.clsdes,
                w_cts19m06.cgccpfnum,
                w_cts19m06.cgcord,
                w_cts19m06.cgccpfdig,
                d_cts19m06.obstxt,
                "0.01"              , # eliminar este campo furamente
                w_cts19m06.vdrpbsfrqvlr,
                w_cts19m06.vdrvgafrqvlr,
                w_cts19m06.vdresqfrqvlr,
                w_cts19m06.vdrdirfrqvlr,
                aux_atdsrvnum, aux_atdsrvano,
                g_documento.vstnumdig,
                g_documento.prporg,
                g_documento.prpnumdig,
                d_cts19m06.vclcoddig,
                w_cts19m06.atdprscod,
                w_cts19m06.srrcoddig,
                w_cts19m06.vcltip,
                d_cts19m06.vdrpbsavrfrqvlr,
                d_cts19m06.vdrvgaavrfrqvlr,
                d_aux19m06.vdrdiravrfrqvlr,
                d_aux19m06.vdresqavrfrqvlr,
                w_cts19m06.atdhorpvt  ,
                w_cts19m06.atdhorprg  ,
                w_cts19m06.atddatprg  ,
                w_cts19m06.atdetpcod  ,
                0   ,
                w_cts19m06.ocuesqfrqvlr,
                w_cts19m06.ocudirfrqvlr,
                d_aux19m06.ocuesqavrfrqvlr,
                d_aux19m06.ocudiravrfrqvlr,
                w_cts19m06.vdrqbvfrqvlr,
                d_cts19m06.vdrqbvavrfrqvlr,
                w_cts19m06.atntip,
                w_cts19m06.ocrendlgd,
                w_cts19m06.ocrendbrr,
                w_cts19m06.ocrendcid,
                w_cts19m06.ocrufdcod,
                w_cts19m06.ocrcttnom,
                d_aux19m06.dirrtravrfrqvlr,
                d_aux19m06.esqrtravrfrqvlr,
                w_cts19m06.dirrtrfrqvlr,
                w_cts19m06.esqrtrfrqvlr,
                mr_vlrfrq76.drtfrlvlr,
                mr_vlrfrq76.esqfrlvlr,
                mr_vlrfrq76.esqmlhfrlvlr,
                mr_vlrfrq76.drtmlhfrlvlr,
                mr_vlrfrq76.drtnblfrlvlr,
                mr_vlrfrq76.esqnblfrlvlr,
                mr_vlrfrq76.esqpscvlr,
                mr_vlrfrq76.drtpscvlr,
                mr_vlrfrq76.drtlntvlr,
                mr_vlrfrq76.esqlntvlr)
   if sqlca.sqlcode <> 0  then
      error " Erro (", sqlca.sqlcode, ") na gravacao da tabela",
            " datmsrvext1. AVISE A INFORMATICA!"
      rollback work
      prompt "" for char ws.prompt_key
      let ws.retorno = false
      exit while
   end if

   # -- CT 261661 - Katiucia -- #
   let ws.ok = 0
   if g_documento.c24astcod = "B14" then
      call cts19m06_grava_sinistro()
             returning ws.ok,
                       ws.sinvstnum,
                       ws.sinvstano
      if ws.ok = 0 then
         rollback work
         let ws.retorno = false
         exit while
      end if
   end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)

    if ws.ok = 1 and
       g_documento.c24astcod = "B14" then
       ## buscar o sinistro do servico original, pela ligacao ( lignum_srv )

       call figrc072_setTratarIsolamento() -- > psi 223689

       call ssata666(ws.sinvstnum,
                     ws.sinvstano,
                     g_documento.lignum,
                     aux_atdsrvnum,
                     aux_atdsrvano,
                     "I")
            returning m_sin.ramcod, m_sin.sinano, m_sin.sinnum

        if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função ssata666 indisponivel no momento ! Avise a Informatica !" sleep 2
           let ws.retorno = false
           exit while
        end if        -- > 223689



       let m_sin.sinvstnum = ws.sinvstnum
       let m_sin.sinvstano = ws.sinvstano

       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.msg = "CTS19M06 - Rotina OK : ",
                     ws.sinvstnum," / ",ws.sinvstano, l_data
       call cts19m06_grava_erro(ws.sinvstano, ws.sinvstnum, ws.msg)
    end if

    let d_cts19m06.servico = g_documento.atdsrvorg using "&&",
                        "/", aux_atdsrvnum using "&&&&&&&",
                        "-", aux_atdsrvano using "&&"
    if w_cts19m06.atdprscod  = 1   and   # carglass
       w_cts19m06.srrcoddig  = 25  then
       let ws.msgtxt = "No.Servico ", ascii(27), "[7m",d_cts19m06.servico , ascii(27), "[0m"
       call cts08g01("A","N","SOLICITACAO ENVIADA PARA CARGLASS!","",
                     "TRANSFIRA LIGACAO INFORMANDO", ws.msgtxt)
            returning ws.confirma
    end if

    # inicio Psi247006
    if m_email_sinis = true then
       call cts19m08_enviaemail(aux_atdsrvnum,
                                aux_atdsrvano,
                                ws.lignum,
                                m_empcod,
                                m_funmat)
       let m_email_sinis = false
    end if
    # fim Psi 247006

    call cts19m07 (aux_atdsrvnum,
                   aux_atdsrvano,
                   ws.lignum,
                   mr_vlrfrq76.frqvlrfarois,
                   m_sin.sinvstnum,
                   m_sin.sinvstano,
                   m_sin.sinano, m_sin.sinnum)
 #----------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #----------------------------------------------------------------------------
   call cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                            w_cts19m06.data  , w_cts19m06.hora,
                            w_cts19m06.funmat, hist_cts19m06.* )
        returning ws.histerr

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   display d_cts19m06.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

  #call cts19m06_grava_sinistro()

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

 end function   ### inclui_cts19m06

#--------------------------------------------------------------------
 function input_cts19m06()
#--------------------------------------------------------------------

 define hist_cts19m06 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    retflg            char (01),
    prpflg            char (01),
    senhaok           char (01),
    blqnivcod         like datkblq.blqnivcod,
    vcllicant         like datmservico.vcllicnum,
    endcep            like glaklgd.lgdcep,
    endcepcmp         like glaklgd.lgdcepcmp,
    confirma          char (01),
    dtparam           char (16),
    codigosql         integer,
    resp              char (01),
    vstnumdig         like datmvistoria.vstnumdig,
    vclvdrtip         char (02),
    telupdflg         dec (01,0),
    alt               char (1),
    atdetpcod         like datmsrvacp.atdetpcod ,
    clscod            like aackcls.clscod
 end record

 ## PSI 193690 Alberto

 define d_cts19m06d  record
        segsexinchor like adikvdrrpremp.segsexinchor,
        segsexfnlhor like adikvdrrpremp.segsexfnlhor,
        sabinchor    like adikvdrrpremp.sabinchor,
        sabfnlhor    like adikvdrrpremp.sabfnlhor,
        atntip       smallint
 end record

 define sin     record
        lignum     like datmligacao.lignum,
        sinvstnum  like datrligsinvst.sinvstnum,
        sinvstano  like datrligsinvst.sinvstano,
        msg        char(80)
 end record

 ## PSI 193690 Alberto

 define lr_limite record
        perimetro decimal(4,0),
        vidro     decimal(3,0),
        retro     decimal(3,0),
        farol     decimal(3,0)
 end record

 define w_vidros      record
        pb            smallint,
        vg            smallint,
        ld            smallint,
        le            smallint
 end record

 define prompt_key    char (01),
        l_qtdretro    smallint,
        l_qtdfarol    smallint,
        l_qtdvidro    smallint,
        l_obser       char(100),
        l_confirma    smallint

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_lignum    like datmligacao.lignum,
        l_permite   smallint,
        l_ret       char(1)

 define l_cts19m06 record
        erro smallint,
        mens char(40)
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null
        let     l_qtdretro  =  null
        let     l_qtdfarol  =  null
        let     l_qtdvidro  =  null
        let     l_confirma  =  null
        let     l_obser     =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        initialize  d_cts19m06d.*  to  null

        initialize  sin.*  to  null

        initialize  w_vidros.*  to  null

        let     prompt_key  =  null

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        initialize  w_vidros.*  to  null

 initialize ws.*  to null
 initialize l_cts19m06.* to null

 let l_qtdfarol = null

 let ws.vcllicant      = d_cts19m06.vcllicnum


 input by name d_cts19m06.nom         ,
               d_cts19m06.corsus      ,
               d_cts19m06.cornom      ,
               d_cts19m06.vclcoddig   ,
               d_cts19m06.vclanomdl   ,
               d_cts19m06.vcllicnum   ,
               d_cts19m06.vclcordes   ,
               d_cts19m06.tipvidro    ,
               d_cts19m06.vdrpbsavrfrqvlr  ,
               d_cts19m06.obstxt,
               d_cts19m06.obstxt_1    ,
               d_cts19m06.atdlibflg     without defaults

   before field nom
          display by name d_cts19m06.nom        attribute (reverse)

   after  field nom
          display by name d_cts19m06.nom

          if d_cts19m06.nom is null or
             d_cts19m06.nom =  "  " then
             error " Nome deve ser informado!"
             next field nom
          end if
          if w_cts19m06.atdfnlflg = "S"  then
             if g_documento.acao  = "CAN"  or
                g_documento.acao  = "REC"  or
                g_documento.acao  = "CON"  or
                g_documento.acao  = "ALT"  then
                if g_documento.acao = "CAN" then
                   call cts08g01("A","N","*** SOLICITACAO DE CANCELAMENTO ***",
                                 " ","DIGITE O MOTIVO DO CANCELAMENTO        ",
                                 "")
                       returning ws.confirma
                   let d_cts19m06.obstxt = null
                   display by name d_cts19m06.obstxt
                   display by name d_cts19m06.obstxt_1
                   next field obstxt
                else
                   if g_documento.acao  = "ALT"  then

                      call cts10g04_ultima_etapa(g_documento.atdsrvnum,
                                                 g_documento.atdsrvano )
                      returning ws.atdetpcod
                      if ws.atdetpcod = 5 then
                         error "Servico esta cancelado, nao pode ser Alterado!"
                         next field nom
                      end if
                      ## PSI 193690 Alberto
                      let ml_cts19m06.alt_loja   = "N"
                      let ml_cts19m06.alt_vidros = "N"
                      let ml_cts19m06.alt_lcloco = "N"

                      select * into mr_datmsrvext1.*
                      from   datmsrvext1
                      where  atdsrvnum = g_documento.atdsrvnum
                      and    atdsrvano = g_documento.atdsrvano
                      and    lignum    = w_cts19m06.lignum

                      ## Se nao for alterar a loja
                      let ml_cts19m06.atdprscod =  mr_datmsrvext1.vdrrprgrpcod
                      let ml_cts19m06.srrcoddig =  mr_datmsrvext1.vdrrprempcod
                      ## PSI 193690 Alberto

                      if g_vdr_blindado = "N" then
                         call cts08g01("A","S","",
                                       "*** DESEJA ALTERAR A LOJA ? ***",
                                       "","")
                         returning ws.confirma
                         ## Atribuir  ws.atdfnlflg = a "N" para poder acionar novamente
                         if ws.confirma = "S" then
                            let ws.alt  = "S"
                            let ml_cts19m06.alt_loja   = "S"
                            let ml_cts19m06.alt_lcloco = "S"
                         end if
                      end if

                      call cts08g01("A","S","",
                                    "*** DESEJA ALTERAR O LAUDO ? ***",
                                    "","")
                      returning ws.confirma

                      select * into mr_datmsrvext1.*
                      from   datmsrvext1
                      where  atdsrvnum = g_documento.atdsrvnum
                      and    atdsrvano = g_documento.atdsrvano
                      and    lignum    = w_cts19m06.lignum

                      if ws.confirma = "S" then
                         let ws.alt  = "S"
                         let ml_cts19m06.alt_vidros = "S"
                         if g_vdr_blindado = "N" then
                           let ml_cts19m06.alt_loja   = "S"
                         end if
                      end if

                      #display "ml_cts19m06.alt_loja  : ", ml_cts19m06.alt_loja
                      #display "ml_cts19m06.alt_vidros: ", ml_cts19m06.alt_vidros

                      let m_ja_chamou = false

                      if ml_cts19m06.alt_loja   = "S" and
                         ml_cts19m06.alt_vidros = "N" then
                         let m_ja_chamou = true
                         #display "Chamei cts19m06_aciona() - ponto 2431"
                         call cts19m06_aciona()
                         ## Atualizar Loja e horario na datmservico e incluir etapas de cancelamento
                         ## incluir datmsrvext1 com loja nova e acionar (Reenviar)
                      end if

                      if ml_cts19m06.alt_vidros = "N" then
                         exit input
                      else
                         next field tipvidro
                      end if
                   else
                       exit input     # acao CON/REC
                   end if
                end if
             else
                if g_documento.atdsrvnum is null   and
                   g_documento.atdsrvano is null   then
                else
                   exit input      # consulta pela tela do radio
                end if
             end if
          end if

   before field corsus
          display by name d_cts19m06.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts19m06.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts19m06.corsus is not null  then
                select cornom
                  into d_cts19m06.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts19m06.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts19m06.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts19m06.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts19m06.cornom

   before field vclcoddig
          display by name d_cts19m06.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts19m06.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts19m06.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else
             if d_cts19m06.vclcoddig is null  or
                d_cts19m06.vclcoddig =  0     then
                call agguvcl() returning d_cts19m06.vclcoddig
                next field vclcoddig
             end if
             select vclcoddig
                    from agbkveic
                    where vclcoddig = d_cts19m06.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if
             call cts15g00(d_cts19m06.vclcoddig)
                 returning d_cts19m06.vcldes
             display by name d_cts19m06.vcldes
          end if

   before field vclanomdl
          display by name d_cts19m06.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts19m06.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts19m06.vclanomdl is null or
                d_cts19m06.vclanomdl =  0    then
                error " Ano do veiculo deve ser informado!"
                next field vclanomdl
             else
                if cts15g01(d_cts19m06.vclcoddig,
                            d_cts19m06.vclanomdl) = false then
                   error " Veiculo nao consta como fabricado em ",
                           d_cts19m06.vclanomdl, "!"
                   next field vclanomdl
                end if
             end if
          end if

   before field vcllicnum
          display by name d_cts19m06.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts19m06.vcllicnum

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vclanomdl
        end if

        if not srp1415(d_cts19m06.vcllicnum)  then
           error " Placa invalida!"
           next field vcllicnum
        end if
        #---------------------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if g_documento.aplnumdig   is null       and
           d_cts19m06.vcllicnum    is not null   then

           if d_cts19m06.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.senhaok  to null

              call cts13g00(w_cts19m06.c24astcod,
                            "", "", "", "",
                            d_cts19m06.vcllicnum,
                            "", "", "")
                            returning ws.blqnivcod, ws.senhaok
              if ws.blqnivcod  =  3   then
                 error " Bloqueio cadastrado nao permite atendimento",
                       " para este assunto/apolice!"
                 next field vcllicnum
              end if
              if ws.blqnivcod  =  2     and
                 ws.senhaok    =  "n"   then
                 error " Bloqueio necessita de permissao para atendimento!"
                 next field vcllicnum
              end if
           end if
           #-----------------------------------------------------------------
           # Verifica se ja' houve solicitacao de servico para apolice
           #-----------------------------------------------------------------
           call cts03g00 (4, g_documento.ramcod    ,
                             g_documento.succod    ,
                             g_documento.aplnumdig ,
                             g_documento.itmnumdig ,
                             d_cts19m06.vcllicnum  ,
                             g_documento.atdsrvnum ,
                             g_documento.atdsrvano )
        end if

   before field vclcordes
          display by name d_cts19m06.vclcordes  attribute (reverse)

   after  field vclcordes
          display by name d_cts19m06.vclcordes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts19m06.vclcordes  is not null then
                let w_cts19m06.vclcordes = d_cts19m06.vclcordes[2,9]

                select cpocod into w_cts19m06.vclcorcod
                  from iddkdominio
                 where cponom      = "vclcorcod"  and
                       cpodes[2,9] = w_cts19m06.vclcordes

                if sqlca.sqlcode = notfound    then
                   error " Cor fora do padrao!"
                   call c24geral4()
                        returning w_cts19m06.vclcorcod, d_cts19m06.vclcordes
                   if w_cts19m06.vclcorcod  is null   then
                      error " Cor do veiculo deve ser informado!"
                      next field vclcordes
                   else
                      display by name d_cts19m06.vclcordes
                   end if
                end if
             else
                call c24geral4()
                     returning w_cts19m06.vclcorcod, d_cts19m06.vclcordes

                if w_cts19m06.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts19m06.vclcordes
                end if
             end if
          end if

    before field tipvidro
       display by name d_cts19m06.tipvidro attribute (reverse)

    after field tipvidro
       display by name d_cts19m06.tipvidro

       ## Para o PSI 193690 bucar as alteracoes efetuadas, deverá ser passado a ligacao

       let d_cts19m06.vdrpbsavrfrqvlr = null
       let d_cts19m06.vdrvgaavrfrqvlr = null
       let d_aux19m06.vdrdiravrfrqvlr = null
       let d_aux19m06.vdresqavrfrqvlr = null
       let d_aux19m06.ocudiravrfrqvlr = null
       let d_aux19m06.ocuesqavrfrqvlr = null
       let d_cts19m06.vdrqbvavrfrqvlr = null
       let d_aux19m06.dirrtravrfrqvlr = null
       let d_aux19m06.esqrtravrfrqvlr = null

       initialize mr_vlrfrq76 to null

       if g_documento.acao = "ALT" and
          ml_cts19m06.alt_vidros = "S" then

          ## Farol Esquerdo
          let mr_datmsrvext1.esqfrlvlr    = null

          ## Farol Direito
          let mr_datmsrvext1.drtfrlvlr    = null

          ## Farol Milha Direito
          let mr_datmsrvext1.drtmlhfrlvlr = null

          ## Farol Milha Esquerdo
          let mr_datmsrvext1.esqmlhfrlvlr = null

          ## Farol Neblina Direito
          let mr_datmsrvext1.drtnblfrlvlr = null

          ## Farol Neblina Esquerdo
          let mr_datmsrvext1.esqnblfrlvlr = null

          ## Pisca Direito
          let mr_datmsrvext1.drtpscvlr    = null

          ## Pisca Esquerdo
          let mr_datmsrvext1.esqpscvlr    = null

          ## Lanterna Direita
          let mr_datmsrvext1.drtlntvlr    = null

          ## Lanterna Esquerda
          let mr_datmsrvext1.esqlntvlr    = null

       end if

       call cts19m04(d_cts19m06.vclcoddig,
                     d_cts19m06.vclanomdl)

               returning w_cts19m06.vdrpbsfrqvlr,
                         w_cts19m06.vdrvgafrqvlr,
                         w_cts19m06.vdrdirfrqvlr,
                         w_cts19m06.vdresqfrqvlr,
                         w_cts19m06.ocudirfrqvlr,
                         w_cts19m06.ocuesqfrqvlr,
                         w_cts19m06.vdrqbvfrqvlr,
                         w_cts19m06.dirrtrfrqvlr,
                         w_cts19m06.esqrtrfrqvlr,
                         d_cts19m06.vdrpbsavrfrqvlr, # PARA-BRISA
                         d_cts19m06.vdrvgaavrfrqvlr, # TRASEIRO
                         d_aux19m06.vdrdiravrfrqvlr, # LAT. DIR.
                         d_aux19m06.vdresqavrfrqvlr, # LAT. ESQ.
                         d_aux19m06.ocudiravrfrqvlr, # OCU. DIR.
                         d_aux19m06.ocuesqavrfrqvlr, # OCU. ESQ.
                         d_cts19m06.vdrqbvavrfrqvlr, # QUEBRA VENTO
                         d_aux19m06.dirrtravrfrqvlr, # RETRO. DIR.
                         d_aux19m06.esqrtravrfrqvlr, # RETRO. ESQ.
                         mr_vlrfrq76.drtfrlvlr,
                         mr_vlrfrq76.esqfrlvlr,
                         mr_vlrfrq76.drtmlhfrlvlr,
                         mr_vlrfrq76.esqmlhfrlvlr,
                         mr_vlrfrq76.drtnblfrlvlr,
                         mr_vlrfrq76.esqnblfrlvlr,
                         mr_vlrfrq76.drtpscvlr,
                         mr_vlrfrq76.esqpscvlr,
                         mr_vlrfrq76.drtlntvlr,
                         mr_vlrfrq76.esqlntvlr,
                         mr_vlrfrq76.frqvlrfarois,
                         ws.clscod

       # -- OSF 9377 - Fabrica de Software, Katiucia -- #
       if d_cts19m06.vdrpbsavrfrqvlr is null and
          d_cts19m06.vdrvgaavrfrqvlr is null and
          d_aux19m06.vdrdiravrfrqvlr is null and
          d_aux19m06.vdresqavrfrqvlr is null and
          d_aux19m06.ocudiravrfrqvlr is null and
          d_aux19m06.ocuesqavrfrqvlr is null and
          d_cts19m06.vdrqbvavrfrqvlr is null and
          d_aux19m06.dirrtravrfrqvlr is null and
          d_aux19m06.esqrtravrfrqvlr is null and
          mr_vlrfrq76.drtfrlvlr      is null and
          mr_vlrfrq76.esqfrlvlr      is null and
          mr_vlrfrq76.drtmlhfrlvlr   is null and
          mr_vlrfrq76.esqmlhfrlvlr   is null and
          mr_vlrfrq76.drtnblfrlvlr   is null and
          mr_vlrfrq76.esqnblfrlvlr   is null and
          mr_vlrfrq76.drtpscvlr      is null and
          mr_vlrfrq76.esqpscvlr      is null and
          mr_vlrfrq76.drtlntvlr      is null and
          mr_vlrfrq76.esqlntvlr      is null then
          error "Escolha o tipo de vidro !"
          next field tipvidro
       end if
       # -- OSF 9377 - Fabrica de Software, Katiucia -- #

       if d_aux19m06.vdrdiravrfrqvlr is not null and
          d_aux19m06.vdresqavrfrqvlr is not null then
          let d_cts19m06.vdrlattxt = "Ambos"
          let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
       else
          if d_aux19m06.vdrdiravrfrqvlr is not null then
             let d_cts19m06.vdrlattxt = "Direito"
             let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
          else
             ## Alberto
             let d_cts19m06.vdrlatavrfrqvlr = null
             if d_aux19m06.vdresqavrfrqvlr is not null then
                let d_cts19m06.vdrlattxt = "Esquerdo"
                let d_cts19m06.vdrlatavrfrqvlr = d_aux19m06.vdresqavrfrqvlr
             else ## Alberto
                let d_cts19m06.vdrlatavrfrqvlr = null
             end if
          end if
       end if

       if d_aux19m06.ocudiravrfrqvlr is not null and
          d_aux19m06.ocuesqavrfrqvlr is not null then
          let d_cts19m06.vdrocutxt = "Ambos"
          let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocudiravrfrqvlr
       else
          if d_aux19m06.ocudiravrfrqvlr is not null then
             let d_cts19m06.vdrocutxt = "Direito"
             let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocudiravrfrqvlr
          else
             let d_aux19m06.ocudiravrfrqvlr = null
             let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocudiravrfrqvlr
             if d_aux19m06.ocuesqavrfrqvlr is not null then
                let d_cts19m06.vdrocutxt = "Esquerdo"
                let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocuesqavrfrqvlr
             else
                let d_cts19m06.vdrocuavrfrqvlr = d_aux19m06.ocuesqavrfrqvlr
                let d_aux19m06.ocudiravrfrqvlr = null
             end if
          end if
       end if

       let g_esprtrflg = "N"

       ## retrovisor
       if d_aux19m06.dirrtravrfrqvlr is not null and
          d_aux19m06.esqrtravrfrqvlr is not null then
          let d_cts19m06.vdrrtrtxt       = "Ambos"
          let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.dirrtravrfrqvlr

          let g_esprtrflg                = "S"
       else
          if d_aux19m06.dirrtravrfrqvlr is not null then
             let d_cts19m06.vdrrtrtxt       = "Direito"
             let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.dirrtravrfrqvlr
             let g_esprtrflg                = "S"
          else
             ## Alberto
             let d_aux19m06.dirrtravrfrqvlr = null
             let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.esqrtravrfrqvlr
             if d_aux19m06.esqrtravrfrqvlr is not null then
                let d_cts19m06.vdrrtrtxt       = "Esquerdo"
                let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.esqrtravrfrqvlr
                let g_esprtrflg                = "S"
             else  ## Alberto
                let d_aux19m06.esqrtravrfrqvlr = null
                let d_cts19m06.vdrrtravrfrqvlr = d_aux19m06.dirrtravrfrqvlr
             end if
          end if
       end if

        # FUNCAO PARA OBTER OS LIMITES MAXIMOS DE UTILIZACAO DE CADA ITEM
        # (VIDROS, RETROVISORES E FAROIS) E O PERIMETRO

       if g_documento.c24astcod is null or
          g_documento.c24astcod = " " then
          let g_documento.c24astcod = "B14"
       end if

       if g_documento.succod is not null    and
          g_documento.ramcod is not null    and
          g_documento.aplnumdig is not null and
          g_documento.c24astcod <> "B90"    and
          g_documento.c24astcod <> "S90"    then

          # Inicio Psi247006
          call cts19m08_permissao(d_cts19m06.vdrpbsavrfrqvlr,
                                  d_cts19m06.vdrvgaavrfrqvlr,
                                  d_aux19m06.vdrdiravrfrqvlr,
                                  d_aux19m06.vdresqavrfrqvlr,
                                  d_aux19m06.ocudiravrfrqvlr,
                                  d_aux19m06.ocuesqavrfrqvlr,
                                  d_aux19m06.dirrtravrfrqvlr, # RETRO. DIR.
                                  d_aux19m06.esqrtravrfrqvlr, # RETRO. ESQ.
                                  mr_vlrfrq76.drtfrlvlr,
                                  mr_vlrfrq76.esqfrlvlr,
                                  mr_vlrfrq76.drtmlhfrlvlr,
                                  mr_vlrfrq76.esqmlhfrlvlr,
                                  mr_vlrfrq76.drtnblfrlvlr,
                                  mr_vlrfrq76.esqnblfrlvlr,
                                  mr_vlrfrq76.drtpscvlr,
                                  mr_vlrfrq76.esqpscvlr,
                                  mr_vlrfrq76.drtlntvlr,
                                  mr_vlrfrq76.esqlntvlr,
                                  ws.clscod    )
            returning l_permite


          if l_permite then
             call cts08g01("A",
                           "S",
                           "",
                           "LIMITE DE REPOSICOES/REPAROS DE VIDROS" ,
                           "EXCEDIDO. NECESSITA DE LIBERACAO DA ",
                           "COORDENACAO/APOIO")
                  returning l_ret

                  if l_ret = 'S' then
                     call cts15m00b()
                          returning l_cts19m06.erro,
                                    l_cts19m06.mens,
                                    m_empcod,
                                    m_funmat
                     if l_cts19m06.erro = 1 then
                        next field tipvidro
                     else
                        let m_email_sinis = true
                     end if
                  else
                     next field tipvidro
                  end if
          end if
          # Fim Psi247006


       end if

       display by name d_cts19m06.*

       if ws.clscod is not null then
          let m_mensagem = "Clausula: ", ws.clscod
          display m_mensagem to mensagem attribute(reverse)
       end if

       if mr_datmsrvext1.clscod is null then
          let mr_datmsrvext1.clscod = ws.clscod
       end if

       if w_cts19m06.clscod is null then
          let w_cts19m06.clscod = ws.clscod
       end if

       if g_documento.acao = "ALT" then

          ### Farol Direito
          if mr_vlrfrq76.drtfrlvlr     is not null then
             let mr_datmsrvext1.drtfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Farol Esquerdo
          if mr_vlrfrq76.esqfrlvlr     is not null then
             let mr_datmsrvext1.esqfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Farol Milha Direito
          if mr_vlrfrq76.drtmlhfrlvlr  is not null then
             let mr_datmsrvext1.drtmlhfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Farol Milha Esquerdo
          if mr_vlrfrq76.esqmlhfrlvlr  is not null then
             let mr_datmsrvext1.esqmlhfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

           ### Farol Neblina Direito
          if mr_vlrfrq76.drtnblfrlvlr  is not null then
             let mr_datmsrvext1.drtnblfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Farol Neblina Esquerdo
          if mr_vlrfrq76.esqnblfrlvlr  is not null then
             let mr_datmsrvext1.esqnblfrlvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Pisca Direito
          if mr_vlrfrq76.drtpscvlr     is not null then
             let mr_datmsrvext1.drtpscvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Pisca Esquerdo
          if mr_vlrfrq76.esqpscvlr     is not null then
             let mr_datmsrvext1.esqpscvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Lanterna Direita
          if mr_vlrfrq76.drtlntvlr     is not null then
             let mr_datmsrvext1.drtlntvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### Lanterna Esquerda
          if mr_vlrfrq76.esqlntvlr     is not null then
             let mr_datmsrvext1.esqlntvlr = mr_vlrfrq76.frqvlrfarois
          end if

          ### para-brisa
          if mr_datmsrvext1.vdrpbsavrfrqvlr is null then
             if d_cts19m06.vdrpbsavrfrqvlr  is not null then
                let mr_datmsrvext1.vdrpbsavrfrqvlr =  d_cts19m06.vdrpbsavrfrqvlr
                let ws.alt  = "S"
             end if
          else
              if d_cts19m06.vdrpbsavrfrqvlr is null then
                 let mr_datmsrvext1.vdrpbsavrfrqvlr =  d_cts19m06.vdrpbsavrfrqvlr
                 let ws.alt  = "S"
              end if
          end if

          ## Vigia/Traseiro
          if mr_datmsrvext1.vdrvgaavrfrqvlr is null then
             if d_cts19m06.vdrvgaavrfrqvlr is not null then
                let mr_datmsrvext1.vdrvgaavrfrqvlr = d_cts19m06.vdrvgaavrfrqvlr
                let ws.alt  = "S"
             end if
          else
             if d_cts19m06.vdrvgaavrfrqvlr is null then
                let mr_datmsrvext1.vdrvgaavrfrqvlr = d_cts19m06.vdrvgaavrfrqvlr
                let ws.alt  = "S"
              end if
          end if

          ##  Vidro Direito
          if mr_datmsrvext1.vdrdiravrfrqvlr is null then
             if d_aux19m06.vdrdiravrfrqvlr  is not null then
                let mr_datmsrvext1.vdrdiravrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
                let  ws.alt  = "S"
             end if
          else
             if d_aux19m06.vdrdiravrfrqvlr  is null then
                let mr_datmsrvext1.vdrdiravrfrqvlr = d_aux19m06.vdrdiravrfrqvlr
                let  ws.alt  = "S"
             end if
          end if
          ## Vidro Esquerdo
          if mr_datmsrvext1.vdresqavrfrqvlr is null then
             if d_aux19m06.vdresqavrfrqvlr is not null then
                let mr_datmsrvext1.vdresqavrfrqvlr = d_aux19m06.vdresqavrfrqvlr
                let  ws.alt  = "S"
             end if
          else
             if d_aux19m06.vdresqavrfrqvlr is null then
                let mr_datmsrvext1.vdresqavrfrqvlr = d_aux19m06.vdresqavrfrqvlr
                let  ws.alt  = "S"
             end if
          end if

          ## Oculo Esquerdo
          if mr_datmsrvext1.ocuesqavrfrqvlr is null then
             if d_aux19m06.ocuesqavrfrqvlr is not null then
                let mr_datmsrvext1.ocuesqavrfrqvlr = d_aux19m06.ocuesqavrfrqvlr
                let  ws.alt  = "S"
             end if
          else
             if d_aux19m06.ocuesqavrfrqvlr is null then
                let mr_datmsrvext1.ocuesqavrfrqvlr = d_aux19m06.ocuesqavrfrqvlr
                let  ws.alt  = "S"
             end if
          end if

          ## Oculo Direito
          if mr_datmsrvext1.ocudiravrfrqvlr is null then
             if d_aux19m06.ocudiravrfrqvlr is not null then
                let mr_datmsrvext1.ocudiravrfrqvlr = d_aux19m06.ocudiravrfrqvlr
                let ws.alt  = "S"
             end if
          else
             if d_aux19m06.ocudiravrfrqvlr is null then
                let mr_datmsrvext1.ocudiravrfrqvlr = d_aux19m06.ocudiravrfrqvlr
                let ws.alt  = "S"
             end if
          end if

          ## Quebra-Vento
          if mr_datmsrvext1.vdrqbvavrfrqvlr is null then
             if d_cts19m06.vdrqbvavrfrqvlr is not null then
                let mr_datmsrvext1.vdrqbvavrfrqvlr = d_cts19m06.vdrqbvavrfrqvlr
                let ws.alt  = "S"
             end if
          else
             if d_cts19m06.vdrqbvavrfrqvlr is null then
                let mr_datmsrvext1.vdrqbvavrfrqvlr = d_cts19m06.vdrqbvavrfrqvlr
                let ws.alt  = "S"
             end if
          end if

          ## Retrovisor Esquerdo
          if mr_datmsrvext1.esqrtravrvlr is null then
             if d_aux19m06.esqrtravrfrqvlr is not null then
                let mr_datmsrvext1.esqrtravrvlr = d_aux19m06.esqrtravrfrqvlr ##w_cts19m06.esqrtrfrqvlr
                let ws.alt  = "S"
             end if
          else
             if d_aux19m06.esqrtravrfrqvlr is null then
                let mr_datmsrvext1.esqrtravrvlr = d_aux19m06.esqrtravrfrqvlr
                let ws.alt  = "S"
             end if
          end if

          ## Retrovisor Direito
          if mr_datmsrvext1.dirrtravrvlr is null then
             if d_aux19m06.dirrtravrfrqvlr is not null then
                let mr_datmsrvext1.dirrtravrvlr = d_aux19m06.dirrtravrfrqvlr
                let ws.alt  = "S"
             end if
          else
             if d_aux19m06.dirrtravrfrqvlr is null then
                let mr_datmsrvext1.dirrtravrvlr = d_aux19m06.dirrtravrfrqvlr
                let ws.alt  = "S"
             end if
          end if

       end if

    before field obstxt
       ## PSI 239.399 Clausula 077
       if ws.clscod = "077" then  # PSI 239.399 Clausula 077
          let d_cts19m06.obstxt = "FRANQUIA 5% SOBRE O VLR DO VIDRO. MINIMO R$ 300,00 "
          display by name d_cts19m06.obstxt
          next field obstxt_1
       else
          display by name d_cts19m06.obstxt attribute(reverse)
       end if
       if g_documento.acao = "ALT" then
          if ml_cts19m06.alt_vidros = "S" then
             if ws.clscod = "077" then  # PSI 239.399 Clausula 077
                let d_cts19m06.obstxt = "ALT VIDROS FRANQ 5% S/VL DO VIDRO.MINIMO R$ 300,00"
                display by name d_cts19m06.obstxt
                next field obstxt_1
             else
                let d_cts19m06.obstxt = "ALTERACAO DE VIDROS"
             end if
          end if
       end if

    after field obstxt
       display by name d_cts19m06.obstxt

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then

          initialize mr_vlrfrq76 to null

          let w_cts19m06.vdrpbsfrqvlr    = null
          let w_cts19m06.vdrvgafrqvlr    = null
          let w_cts19m06.vdrdirfrqvlr    = null
          let w_cts19m06.vdresqfrqvlr    = null
          let w_cts19m06.ocudirfrqvlr    = null
          let w_cts19m06.ocuesqfrqvlr    = null
          let w_cts19m06.vdrqbvfrqvlr    = null
          let w_cts19m06.dirrtrfrqvlr    = null
          let w_cts19m06.esqrtrfrqvlr    = null
          let d_cts19m06.vdrpbsavrfrqvlr = null
          let d_cts19m06.vdrvgaavrfrqvlr = null
          let d_aux19m06.vdrdiravrfrqvlr = null
          let d_aux19m06.vdresqavrfrqvlr = null
          let d_aux19m06.ocudiravrfrqvlr = null
          let d_aux19m06.ocuesqavrfrqvlr = null
          let d_cts19m06.vdrqbvavrfrqvlr = null
          let d_aux19m06.dirrtravrfrqvlr = null
          let d_aux19m06.esqrtravrfrqvlr = null

          display by name d_cts19m06.*

          display "" to vdrpbsavrfrqvlr
          display "" to vdrvgaavrfrqvlr
          display "" to vdrlatavrfrqvlr
          display "" to vdrocuavrfrqvlr
          display "" to vdrqbvavrfrqvlr
          display "" to vdrrtravrfrqvlr

          display "" to vdrlattxt
          display "" to vdrocutxt
          display "" to vdrrtrtxt

          # DISPLAY DOS LADOS
          display "" to lfarol
          display "" to lfarolmi
          display "" to lfarolne
          display "" to lpisca
          display "" to llanterna

          # DISPLAY DOS VALORES
          display "" to vlrfaro
          display "" to vlrfami
          display "" to vlrfane
          display "" to vlrpisc
          display "" to vlrlant

          next field tipvidro
       end if

    before field obstxt_1
       display by name d_cts19m06.obstxt_1 attribute (reverse)

       if ws.clscod = "077" then  # PSI 239.399 Clausula 077
          let d_cts19m06.obstxt = "FRANQUIA 5% SOBRE O VLR DO VIDRO. MINIMO R$ 300,00 "
          display by name d_cts19m06.obstxt
       end if
       if g_documento.acao = "ALT" then # PSI 239.399 Clausula 077
          if ml_cts19m06.alt_vidros = "S" then
             if ws.clscod = "077" then
                let d_cts19m06.obstxt = "ALT VIDROS FRANQ 5% S/VL DO VIDRO.MINIMO R$ 300,00"
                display by name d_cts19m06.obstxt
             else
                let d_cts19m06.obstxt = "ALTERACAO DE VIDROS"
             end if
          end if
       end if # PSI 239.399 Clausula 077

    after field obstxt_1
       display by name d_cts19m06.obstxt_1

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field obstxt
       end if

       let l_obser           = null
       let l_obser           = d_cts19m06.obstxt clipped, d_cts19m06.obstxt_1
       let d_cts19m06.obstxt = null
       let d_cts19m06.obstxt = l_obser

       #let d_cts19m06.obstxt = d_cts19m06.obstxt clipped
       #                       ,d_cts19m06.obstxt_1 clipped

       if d_cts19m06.obstxt is null and
          g_documento.acao  = "CAN"  then
          error "Informe o motivo do cancelamento"
          next field obstxt
       end if

       if g_documento.acao = "ALT" then

          if ml_cts19m06.alt_loja = "S"  and
             m_ja_chamou = false then
             let m_ja_chamou = true
             call cts19m06_aciona()
             ## Atualizar Loja e horario na datmservico e incluir etapas de cancelamento
             ## incluir datmsrvext1 com loja nova e acionar (Reenviar)
          end if
       end if

       if g_documento.acao  = "CAN" or    # vem da tela cts16m01
          g_documento.acao  = "ALT" then    # vem da tela cts16m01

          ## Seleciona o nº sinistro
          call cts20g00_servico( g_documento.atdsrvnum,
                                 g_documento.atdsrvano )
                        returning l_lignum

          select sinvstnum, sinvstano
          into   m_sin.sinvstnum, m_sin.sinvstano
          from   datrligsinvst
          where  lignum = l_lignum
          call figrc072_setTratarIsolamento() -- > psi 223689


          call ssata666(m_sin.sinvstnum,
                        m_sin.sinvstano,
                        w_cts19m06.lignum,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        "A")
          returning m_sin.ramcod, m_sin.sinano, m_sin.sinnum

          if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
             error "Função ssata666 indisponivel no momento ! Avise a Informatica !" sleep 2
             let int_flag = true
             exit input
          end if        -- > 223689

       end if

       if g_documento.acao  = "CAN" then   # vem da tela cts16m01
          select * into mr_datmsrvext1.*    # salva dados ligacao anterior
              from datmsrvext1
             where atdsrvnum = g_documento.atdsrvnum
               and atdsrvano = g_documento.atdsrvano
               and lignum    = w_cts19m06.lignum
          if sqlca.sqlcode <> 0 then
             error " Erro (", sqlca.sqlcode, ") na leitura  da tabela",
                   " datmsrvext1(alt). AVISE A INFORMATICA!"
             prompt "" for char prompt_key
             exit input
          end if
          call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
          let mr_datmsrvext1.lignum    = g_documento.lignum   # cts16m01
          let mr_datmsrvext1.ligdat    = l_data
          let mr_datmsrvext1.lighorinc = l_hora2
          let mr_datmsrvext1.atdetpcod = 5  # gera nova ligacao c/status canc.
          let mr_datmsrvext1.atmstt    = 0
          let mr_datmsrvext1.adcmsgtxt = d_cts19m06.obstxt

          call cts19m06_envia(g_documento.atdsrvnum,
                              g_documento.atdsrvano,
                              mr_datmsrvext1.vdrrprgrpcod,
                              mr_datmsrvext1.vdrrprempcod)
          let mr_datmsrvext1.segdddcod = w_cts19m06.segdddcod
          let mr_datmsrvext1.segteltxt = w_cts19m06.segteltxt

          whenever error continue
          begin work
           update datmsrvext1
                set atdetpcod = 6         # cancela ligacao anterior
              where atdsrvnum = g_documento.atdsrvnum
                and atdsrvano = g_documento.atdsrvano
                and lignum    = w_cts19m06.lignum
           insert into datmsrvext1    # grava o cancelamento
                values (mr_datmsrvext1.*)
           if sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na gravacao da tabela",
                    " datmsrvext1(can). AVISE A INFORMATICA!"
              rollback work
              prompt "" for char prompt_key
              exit input
           end if
           call cts10g04_insere_etapa ( g_documento.atdsrvnum    ,
                                        g_documento.atdsrvano    ,
                                        5                    ,
                                        w_cts19m06.atdprscod,
                                        "",
                                        "",
                                        w_cts19m06.srrcoddig )
                             returning ws.codigosql
           if  ws.codigosql  <>  0  then
               error " Erro (", ws.codigosql, ") na gravacao da",
                     " etapa de acompanhamento (5). AVISE A INFORMATICA!"
               rollback work
               prompt "" for char prompt_key
               exit input
           end if
           whenever error stop
          commit work
          call cts19m07 (g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         mr_datmsrvext1.lignum,
                         mr_vlrfrq76.frqvlrfarois,
                         m_sin.sinvstnum,
                         m_sin.sinvstano,
                         m_sin.sinano, m_sin.sinnum)
          exit input
       else

          if d_cts19m06.obstxt is null then
             let d_cts19m06.obstxt = " "
          end if

          if mr_datmsrvext1.adcmsgtxt is null then
             let mr_datmsrvext1.adcmsgtxt = " "
          end if

          if g_documento.acao = "ALT"  then

             if mr_datmsrvext1.vdrrprempcod is null  then
                 select vdrrprempcod into mr_datmsrvext1.vdrrprempcod
                  from datmsrvext1
                 where atdsrvnum = g_documento.atdsrvnum
                   and atdsrvano = g_documento.atdsrvano
                   and lignum    = w_cts19m06.lignum
                 if sqlca.sqlcode <> 0 then
                    error " Erro (", sqlca.sqlcode, ") na leitura  da tabela",
                       " datmsrvext1(alt). AVISE A INFORMATICA!"
                    prompt "" for char prompt_key
                    exit input
                 end if
              end if
             if mr_datmsrvext1.atdetpcod  <> 4 then  ## Alberto Verificar
                let mr_datmsrvext1.atdetpcod = 4
             end if
             if d_cts19m06.obstxt = mr_datmsrvext1.adcmsgtxt then
                error "Informe um novo texto na alteracao !!"
                next field obstxt
             end if
             call cts19m06_envia(g_documento.atdsrvnum,
                                 g_documento.atdsrvano,
                                 mr_datmsrvext1.vdrrprgrpcod,
                                 mr_datmsrvext1.vdrrprempcod)

             if mr_datmsrvext1.segdddcod <> w_cts19m06.segdddcod or
                mr_datmsrvext1.segteltxt <> w_cts19m06.segteltxt then
                let ws.alt   =  "S"
             end if

             if ws.alt  =  "S"  then
                begin work
                ## Inserir as etapas 193690
                call cts10g04_insere_etapa ( g_documento.atdsrvnum,
                                             g_documento.atdsrvano,
                                             5                    ,
                                             ml_cts19m06.atdprscod ,
                                             "",
                                             "",
                                             ml_cts19m06.srrcoddig )
                returning ws.codigosql
                if  ws.codigosql  <>  0  then
                   error " Erro (", ws.codigosql, ") na gravacao da",
                         " etapa de acompanhamento (1). AVISE A INFORMATICA!"
                   rollback work
                   prompt "" for char prompt_key
                end if

                whenever error continue
                update datmsrvext1
                     set atdetpcod = 5         # cancela ligacao anterior
                   where atdsrvnum = g_documento.atdsrvnum
                     and atdsrvano = g_documento.atdsrvano
                     and lignum    = w_cts19m06.lignum
                whenever error stop
                if  sqlca.sqlcode  <>  0  then
                    error " Erro (", sqlca.sqlcode, ") na gravacao da",
                         " etapa de acompanhamento (1). AVISE A INFORMATICA!"
                    rollback work
                    prompt "" for char prompt_key
                end if
                call cts40g03_data_hora_banco(2)
                    returning l_data, l_hora2
                let mr_datmsrvext1.lignum    = g_documento.lignum   # cts16m01
                let mr_datmsrvext1.ligdat    = l_data
                let mr_datmsrvext1.lighorinc = l_hora2
                let mr_datmsrvext1.segdddcod = w_cts19m06.segdddcod
                let mr_datmsrvext1.segteltxt = w_cts19m06.segteltxt
                let mr_datmsrvext1.adcmsgtxt = d_cts19m06.obstxt
                whenever error continue

                 ## begin work  - Seria o 5º begin, porem ainda esta dentro do 4º
                whenever error continue
                   insert into datmsrvext1    # grava alteracao
                        values (mr_datmsrvext1.*)
                   if sqlca.sqlcode <> 0  then
                      error " Erro (", sqlca.sqlcode, ") na gravacao da tabela",
                            " datmsrvext1(alt). AVISE A INFORMATICA!"
                      rollback work
                      prompt "" for char prompt_key
                      exit input
                   end if
                   ## atualiza data e horario de atendimento da datmservico

                   update datmservico
                   set    srrcoddig   = mr_datmsrvext1.vdrrprempcod,
                          atdprscod   = mr_datmsrvext1.vdrrprgrpcod,
                          atdhorpvt   = mr_datmsrvext1.atdhorpvt,
                          atddatprg   = mr_datmsrvext1.atddatprg,
                          atdhorprg   = mr_datmsrvext1.atdhorprg
                   where  atdsrvnum   = g_documento.atdsrvnum
                   and    atdsrvano   = g_documento.atdsrvano
                   whenever error stop

                   if sqlca.sqlcode <> 0  then
                      error " Erro (", sqlca.sqlcode, ") na atualizacao do servico.",
                            " AVISE A INFORMATICA!"
                      rollback work
                      prompt "" for char ws.confirma
                      exit input
                   end if
                   ## Inserir a etapa da nova loja, ou para a ligacao dos vidros alterados
                   if w_cts19m06.atdprscod is null and
                      w_cts19m06.srrcoddig is null then ## alterou os vidros
                      let w_cts19m06.atdprscod = ml_cts19m06.atdprscod
                      let w_cts19m06.srrcoddig = ml_cts19m06.srrcoddig
                   end if
                   whenever error continue
                   call cts10g04_insere_etapa ( g_documento.atdsrvnum,
                                                g_documento.atdsrvano,
                                                4                    ,
                                                w_cts19m06.atdprscod ,
                                                "",
                                                "",
                                                w_cts19m06.srrcoddig )
                   returning ws.codigosql
                   if  ws.codigosql  <>  0  then
                       error " Erro (", ws.codigosql, ") na gravacao da",
                             " etapa de acompanhamento (1). AVISE A INFORMATICA!"
                       rollback work
                       sleep 3
                       exit input
                   end if
                whenever error stop

                commit work
                # Ponto de acesso apos a gravacao do laudo
                call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                                            g_documento.atdsrvano)

                if m_email_sinis = true then
                   call cts19m08_enviaemail(g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            mr_datmsrvext1.lignum,
                                            m_empcod,
                                            m_funmat)
                   let m_email_sinis = false
                end if

                call cts19m07 (g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               mr_datmsrvext1.lignum,
                               mr_vlrfrq76.frqvlrfarois,
                               m_sin.sinvstnum,
                               m_sin.sinvstano,
                               m_sin.sinano, m_sin.sinnum)

                if g_documento.acao = "ALT" and
                  (w_cts19m06.c24astcod = "ALT" or
                   w_cts19m06.c24astcod = "B14" ) then
                   ## localiza a ligacao do servico original
                   let sin.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                                     g_documento.atdsrvano)
                   ## Seleciona o nº sinistro
                   select sinvstnum, sinvstano
                   into   m_sin.sinvstnum, m_sin.sinvstano
                   from   datrligsinvst
                   where  lignum = sin.lignum

                   ## Envia fax, e-mail para loja anterior cancelando o servico -> etapa 5
                   if ml_cts19m06.alt_loja   = "S" then
                      if ml_cts19m06.alt_vidros = "S"  then
                         call cts19m06_fax_loja_ant( g_documento.atdsrvnum,
                                                     g_documento.atdsrvano,
                                                     w_cts19m06.lignum )
                      end if
                   end if

                   call figrc072_setTratarIsolamento() -- > psi 223689


                   call ssata666(m_sin.sinvstnum,
                                 m_sin.sinvstano,
                                 g_documento.lignum,
                                 g_documento.atdsrvnum,
                                 g_documento.atdsrvano,
                                 "A")
                        returning m_sin.ramcod, m_sin.sinano, m_sin.sinnum

                   if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
                      error "Função ssata666  indisponivel no momento! Avise a Informatica !" sleep 2
                      let int_flag = true
                      exit input
                   end if        -- > 223689



                   call cts40g03_data_hora_banco(2)
                       returning l_data, l_hora2
                   let sin.msg = "CTS19M06 - Rotina OK : ",
                                 sin.sinvstnum,"/",sin.sinvstano, l_data
                   call cts19m06_grava_erro(sin.sinvstano, sin.sinvstnum, sin.msg)
                end if
                exit input
             end if
          end if
       end if

    before field atdlibflg
       display by name d_cts19m06.atdlibflg attribute (reverse)

    after  field atdlibflg     # confirma
       display by name d_cts19m06.atdlibflg
       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          initialize d_cts19m06.atdlibflg to null
          display by name d_cts19m06.atdlibflg
          next field obstxt
       end if

       if ((d_cts19m06.atdlibflg  is null)  or
            d_cts19m06.atdlibflg  <> "S"    and
            d_cts19m06.atdlibflg  <> "N")   then
          error " Confirme a liberacao: (S)im ou (N)ao!"
          next field atdlibflg
       end if
       if d_cts19m06.atdlibflg  is null   then
          next field atdlibflg
       end if

       display by name d_cts19m06.atdlibflg

       if d_cts19m06.atdlibflg  =  "S"  then
          call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
          let aux_libhor           = l_hora2
          let d_cts19m06.atdlibhor = aux_libhor
          let d_cts19m06.atdlibdat = l_data
       else
          let d_cts19m06.atdlibflg = "N"
          display by name d_cts19m06.atdlibflg
          initialize d_cts19m06.atdlibhor to null
          initialize d_cts19m06.atdlibdat to null
       end if
       if d_cts19m06.atdlibflg = "N" then
          exit input
       end if

    on key (interrupt)
       if g_documento.atdsrvnum is null or
          g_documento.atdsrvano is null then
          call cts08g01("C","S","","ABANDONA PREENCHIMENTO DA SOLICITACAO?",
                        "","")
               returning ws.confirma
          if ws.confirma = "S" then
             let int_flag = true
             exit input
          end if
       else
          exit input
       end if

    on key (F1)
       if w_cts19m06.c24astcod is not null then
          call ctc58m00_vis(w_cts19m06.c24astcod)
       end if

    # Retirado a pedido da AnaPaula PSI247006
    {on key (F3)
       if not cts19m06_trocas("CON") then
          # aqui nao faz nada, o retorno boolean eh usado em outro lugar
          # usei o if para nao ter q gastar uma variavel de bobeira. Roni
       end if}

    on key (F4)
       if g_documento.succod    is not null  and
          g_documento.ramcod    is not null  and
          g_documento.aplnumdig is not null  then
          select clscod
              from abbmclaus
             where succod    = g_documento.succod  and
                   aplnumdig = g_documento.aplnumdig and
                   itmnumdig = g_documento.itmnumdig and
                   dctnumseq = g_funapol.dctnumseq and
                   clscod    = "018"
           if sqlca.sqlcode  = 0  then
              if g_documento.lignum    is null  and
                 g_documento.cndslcflg = "S"    then
                 call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                               g_documento.itmnumdig, "I")
              else
                 call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                               g_documento.itmnumdig, "C")
              end if
          else
              error "Docto nao possui clausula 18 !"
          end if
       else
           error "Condutor so' com Documento localizado!"
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

    on key (F6)
      if g_documento.atdsrvnum is null  then
         call cts10m02 (hist_cts19m06.*) returning hist_cts19m06.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
      end if


    on key (F8)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
          while true
                let w_cts19m06.atntip = 1

                let a_cts19m06.lclbrrnom = m_lclbrrnom

                call cts06g03(1, 14,
                             w_cts19m06.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts19m06.lclidttxt,
                             a_cts19m06.cidnom,
                             a_cts19m06.ufdcod,
                             a_cts19m06.brrnom,
                             a_cts19m06.lclbrrnom,
                             a_cts19m06.endzon,
                             a_cts19m06.lgdtip,
                             a_cts19m06.lgdnom,
                             a_cts19m06.lgdnum,
                             a_cts19m06.lgdcep,
                             a_cts19m06.lgdcepcmp,
                             a_cts19m06.lclltt,
                             a_cts19m06.lcllgt,
                             a_cts19m06.lclrefptotxt,
                             a_cts19m06.lclcttnom,
                             a_cts19m06.dddcod,
                             a_cts19m06.lcltelnum,
                             a_cts19m06.c24lclpdrcod,
                             a_cts19m06.ofnnumdig,
                             a_cts19m06.celteldddcod    ,
                             a_cts19m06.celtelnum ,
                             a_cts19m06.endcmp,
                             hist_cts19m06.*, a_cts19m06.emeviacod)
                   returning a_cts19m06.lclidttxt,
                             a_cts19m06.cidnom,
                             a_cts19m06.ufdcod,
                             a_cts19m06.brrnom,
                             a_cts19m06.lclbrrnom,
                             a_cts19m06.endzon,
                             a_cts19m06.lgdtip,
                             a_cts19m06.lgdnom,
                             a_cts19m06.lgdnum,
                             a_cts19m06.lgdcep,
                             a_cts19m06.lgdcepcmp,
                             a_cts19m06.lclltt,
                             a_cts19m06.lcllgt,
                             a_cts19m06.lclrefptotxt,
                             a_cts19m06.lclcttnom,
                             a_cts19m06.dddcod,
                             a_cts19m06.lcltelnum,
                             a_cts19m06.c24lclpdrcod,
                             a_cts19m06.ofnnumdig,
                             a_cts19m06.celteldddcod    ,
                             a_cts19m06.celtelnum ,
                             a_cts19m06.endcmp,
                             ws.retflg,
                             hist_cts19m06.*, a_cts19m06.emeviacod

             let m_lclbrrnom = a_cts19m06.lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts19m06.lclbrrnom,
                                            a_cts19m06.lclbrrnom)
             returning a_cts19m06.lclbrrnom

             let a_cts19m06.lgdtxt = a_cts19m06.lgdtip clipped, " ",
                                     a_cts19m06.lgdnom clipped, " ",
                                     a_cts19m06.lgdnum using "<<<<#"

             if a_cts19m06.lclltt is null then
                error "Digite endereco para selecionar uma Loja, tecle F7"
                continue while
             end if
             if a_cts19m06.lgdnom is null then
                let a_cts19m06.lgdnom    = "NAO EXISTEM MAPA POR RUA"
                let a_cts19m06.lclbrrnom = " "
                let a_cts19m06.c24lclpdrcod = 03
                continue while
             end if
             let w_cts19m06.ocrendlgd  =  a_cts19m06.lgdtxt
             let w_cts19m06.ocrendbrr  =  a_cts19m06.lclbrrnom
             let w_cts19m06.ocrendcid  =  a_cts19m06.cidnom
             let w_cts19m06.ocrufdcod  =  a_cts19m06.ufdcod
             let w_cts19m06.ocrcttnom  =  a_cts19m06.lclcttnom

             let ml_cts19m06.alt_lcloco  = "S"  ## devera alterar a loja

             ## Altera o Loal de Ocorencia
             if ml_cts19m06.alt_lcloco = "S" then
                let mr_datmsrvext1.ocrendlgd = w_cts19m06.ocrendlgd
                let mr_datmsrvext1.ocrendbrr = w_cts19m06.ocrendbrr
                let mr_datmsrvext1.ocrendcid = w_cts19m06.ocrendcid
                let mr_datmsrvext1.ocrufdcod = w_cts19m06.ocrufdcod
                let mr_datmsrvext1.ocrcttnom = w_cts19m06.ocrcttnom
             end if

             let a_cts19m06.lclbrrnom = m_lclbrrnom

             let m_status = cts06g07_local("M",
                                           g_documento.atdsrvnum,
                                           g_documento.atdsrvano,
                                           1,
                                           a_cts19m06.lclidttxt,
                                           a_cts19m06.lgdtip,
                                           a_cts19m06.lgdnom,
                                           a_cts19m06.lgdnum,
                                           a_cts19m06.lclbrrnom,
                                           a_cts19m06.brrnom,
                                           a_cts19m06.cidnom,
                                           a_cts19m06.ufdcod,
                                           a_cts19m06.lclrefptotxt,
                                           a_cts19m06.endzon,
                                           a_cts19m06.lgdcep,
                                           a_cts19m06.lgdcepcmp,
                                           a_cts19m06.lclltt,
                                           a_cts19m06.lcllgt,
                                           a_cts19m06.dddcod,
                                           a_cts19m06.lcltelnum,
                                           a_cts19m06.lclcttnom,
                                           a_cts19m06.c24lclpdrcod,
                                           a_cts19m06.ofnnumdig,
                                           a_cts19m06.emeviacod,
                                           a_cts19m06.celteldddcod,
                                           a_cts19m06.celtelnum,
                                           a_cts19m06.endcmp)
             if m_status <> 0 then
                error "ERRO NA ATUALIZACAO DO ENDERECO DO SERVICO. CTS19m06" sleep 5
             end if

             exit while
          end while
      end if

    on key (F9)
     if d_cts19m06.atdlibflg = "N"   then
        error " Servico nao liberado!"
     else
        #display "Chamei cts19m06_aciona() - ponto 3785"
        call cts19m06_aciona()
     end if

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts19m06.* to null
 end if

 return hist_cts19m06.*

 end function   ### input_cts19m06

#------------------------------------------------------------------------------
 function cts19m06_aciona()
#------------------------------------------------------------------------------
   define d_cts19m06b  record
      cnldat       like datmservico.cnldat,
      atdfnlhor    char(05),
      operador     like isskfunc.funnom,
      atdetpcod    like datmsrvacp.atdetpcod,
      atdetpdes    like datketapa.atdetpdes,
      retorno      char(20),
      atdprscod    like datmservico.atdprscod,  # codigo do prestador
      nomprest     char(20),
      imdsrvflg    char(1),
      srrcoddig    like datmservico.srrcoddig,  # codigo da loja
      nomloja      char(30),
      cidnom       char(48),
      ufdcod       char(02),
      dddcod       like dpaksocor.dddcod,
      teltxt       like dpaksocor.teltxt,
      contato      char(20),
      horloja      char(52),
      atddatprg    like datmservico.atddatprg,
      atdhorprg    like datmservico.atdhorprg,
      atdhorpvt    like datmservico.atdhorpvt,
      vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
      atntip       char (12)         # ruiz
   end record

   define salva        record
      atdetpcod        like datmsrvacp.atdetpcod,
      atdetpdes        like datketapa.atdetpdes,
      atdetptipcod     like datketapa.atdetptipcod,
      atdprscod        like dpaksocor.pstcoddig,
      srrcoddig        like datmservico.srrcoddig,
      atdvclsgl        like datmservico.atdvclsgl,
      cnldat           like datmservico.cnldat,
      socvclcod        like datkveiculo.socvclcod
   end record

   define hist_cts19m06 record
      hist1             like datmservhist.c24srvdsc,
      hist2             like datmservhist.c24srvdsc,
      hist3             like datmservhist.c24srvdsc,
      hist4             like datmservhist.c24srvdsc,
      hist5             like datmservhist.c24srvdsc
   end record

   define ws  record
      faxnum           like dpaksocor.faxnum,
      lignum           like datmligacao.lignum,
      c24opemat        like datmservico.c24opemat,
      atdfnlhor        like datmservico.atdfnlhor,
      atdfnlflg        like datmservico.atdfnlflg,
      atdlibflg        like datmservico.atdlibflg,
      atdsrvorg        like datmservico.atdsrvorg,
      asitipcod        like datmservico.asitipcod,
      atdhorpvt        like datmservico.atdhorpvt,
      atdpvtretflg     like datmservico.atdpvtretflg,
      atdsrvretflg     like datmsrvre.atdsrvretflg,
      atdsrvnum        like datmservico.atdsrvnum,
      atdsrvano        like datmservico.atdsrvano,
      atddat           like datmservico.atddat,
      atddatprg        like datmservico.atddatprg,
      atdhorprg        like datmservico.atdhorprg,
      sindat           like datmservicocmp.sindat,
      sinhor           like datmservicocmp.sinhor,
      ufdcod           like datmfrtpos.ufdcod,
      cidnom           like datmfrtpos.cidnom,
      brrnom           like datmfrtpos.brrnom,
      endzon           like datmfrtpos.endzon,
      atdsrvseq        like datmsrvacp.atdsrvseq,
      atdetptipcod     like datketapa.atdetptipcod,
      atdetppndflg     like datketapa.atdetppndflg,
      srrcoddig        like datksrr.srrcoddig,
      codigosql        integer,
      confirma         char (01),
      retflg           char (01),
      operacao         char (01),
      horaatu          char (05),
      flagf7           char (01),
      segsexinchor     like adikvdrrpremp.segsexinchor,
      segsexfnlhor     like adikvdrrpremp.segsexfnlhor,
      sabinchor        like adikvdrrpremp.sabinchor,
      sabfnlhor        like adikvdrrpremp.sabfnlhor ,
      data_util        date,
      retorno          smallint,
      servico          char (13),
      telupdflg        dec (01,0),
      msgtxt           char (40),
      atntip           smallint,
      msg1             char(14)
   end record
   define motivo record
     cncmtvtxt         char (100)
   end record
   define w_serv like datmservico.atdsrvnum
   define w_ano  like datmservico.atdsrvano

   define l_data     date,
          l_hora2    datetime hour to minute

   ## define w_datmsrvext1 record like datmsrvext1.*



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     w_serv  =  null
        let     w_ano  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts19m06b.*  to  null

        initialize  salva.*  to  null

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        initialize  motivo.*  to  null

        let     w_serv  =  null
        let     w_ano   =  null

        initialize  d_cts19m06b.*  to  null

        initialize  salva.*  to  null

        initialize  hist_cts19m06.*  to  null

        initialize  ws.*  to  null

        initialize  motivo.*  to  null

    ##    initialize  w_datmsrvext1.*  to  null

   open window w_cts19m06b at 10,02 with form "cts19m06b"
                       attribute(form line 1, border, comment line last -1)

   initialize d_cts19m06b.* to null
   initialize ws.atdsrvseq to null

   if g_documento.atdsrvnum is not null then

      #--------------------------------------------------------------------
      # Verifica se servico ja' foi concluido
      #--------------------------------------------------------------------
      select atdprscod   , atdfnlflg   , funmat   ,
             c24opemat   , cnldat      , atdfnlhor,
             atdpvtretflg, atdsrvorg   , asitipcod,
             atddat      , atddatprg,
             srrcoddig   , atdhorpvt   , atdhorprg
        into d_cts19m06b.atdprscod   , w_cts19m06.atdfnlflg,w_cts19m06.funmat,
             ws.c24opemat            , d_cts19m06b.cnldat      ,
             d_cts19m06b.atdfnlhor   , w_cts19m06.atdpvtretflg ,
             ws.atdsrvorg            , ws.asitipcod           ,
             ws.atddat               ,
             w_cts19m06.atddatprg    , d_cts19m06b.srrcoddig  ,
             w_cts19m06.atdhorpvt    , w_cts19m06.atdhorprg
        from datmservico, outer datmservicocmp
       where datmservico.atdsrvnum    =  g_documento.atdsrvnum
         and datmservico.atdsrvano    =  g_documento.atdsrvano
         and datmservicocmp.atdsrvnum =  datmservico.atdsrvnum
         and datmservicocmp.atdsrvano =  datmservico.atdsrvano

      if w_cts19m06.atddatprg is not null then
         let d_cts19m06b.imdsrvflg = "N"
      else
         if w_cts19m06.atdhorpvt is not null then
            let d_cts19m06b.imdsrvflg = "S"
         end if
      end if
      let d_cts19m06b.atddatprg = w_cts19m06.atddatprg
      let d_cts19m06b.atdhorprg = w_cts19m06.atdhorprg
      let d_cts19m06b.atdhorpvt = w_cts19m06.atdhorpvt
      select max(atdsrvseq)
         into ws.atdsrvseq
         from datmsrvacp
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano

      select atdetpcod
         into d_cts19m06b.atdetpcod
         from datmsrvacp
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
          and atdsrvseq = ws.atdsrvseq

      if sqlca.sqlcode = 0 then
         let d_cts19m06b.atdetpdes = "NAO CADASTRADA"

         select atdetpdes,
                atdetptipcod,
                atdetppndflg
           into d_cts19m06b.atdetpdes,
                ws.atdetptipcod,
                ws.atdetppndflg
           from datketapa
          where atdetpcod = d_cts19m06b.atdetpcod

         if ws.atdetppndflg = "S"  then
            let w_cts19m06.atdfnlflg = "N"
         else
            let w_cts19m06.atdfnlflg = "S"
         end if
         #-------------------------------------------------------------------
         # Salva conteudo dos campos
         #-------------------------------------------------------------------

         let salva.atdetpcod      =  d_cts19m06b.atdetpcod
         let salva.atdetpdes      =  d_cts19m06b.atdetpdes
         let salva.atdprscod      =  d_cts19m06b.atdprscod
         let salva.srrcoddig      =  d_cts19m06b.srrcoddig
         let ml_cts19m06.atdprscod =  d_cts19m06b.atdprscod
         let ml_cts19m06.srrcoddig =  d_cts19m06b.srrcoddig

         ##display ""
         ##display "w_cts19m06.c24astcod: ", w_cts19m06.c24astcod
         ##display "w_cts19m06.c24astcod: ", w_cts19m06.c24astcod
         ##display "g_documento.acao    : ", g_documento.acao
         ##display "ml_cts19m06.alt_loja: ", ml_cts19m06.alt_loja
         ##display ""

         if (w_cts19m06.c24astcod = "B14"   or
             w_cts19m06.c24astcod = "ALT" ) and
             g_documento.acao     = "ALT"   and
             ml_cts19m06.alt_loja  = "S"    then
             ## Implementar o Local de Ocorrencia
             ##***************************************************************
             while true
                   let w_cts19m06.atntip = 1

                   let a_cts19m06.lclbrrnom = m_lclbrrnom
                   call cts06g03(1, 14,
                                w_cts19m06.ligcvntip,
                                aux_today,
                                aux_hora,
                                a_cts19m06.lclidttxt,
                                a_cts19m06.cidnom,
                                a_cts19m06.ufdcod,
                                a_cts19m06.brrnom,
                                a_cts19m06.lclbrrnom,
                                a_cts19m06.endzon,
                                a_cts19m06.lgdtip,
                                a_cts19m06.lgdnom,
                                a_cts19m06.lgdnum,
                                a_cts19m06.lgdcep,
                                a_cts19m06.lgdcepcmp,
                                a_cts19m06.lclltt,
                                a_cts19m06.lcllgt,
                                a_cts19m06.lclrefptotxt,
                                a_cts19m06.lclcttnom,
                                a_cts19m06.dddcod,
                                a_cts19m06.lcltelnum,
                                a_cts19m06.c24lclpdrcod,
                                a_cts19m06.ofnnumdig,
                                a_cts19m06.celteldddcod    ,
                                a_cts19m06.celtelnum ,
                                a_cts19m06.endcmp,
                                hist_cts19m06.*, a_cts19m06.emeviacod)
                      returning a_cts19m06.lclidttxt,
                                a_cts19m06.cidnom,
                                a_cts19m06.ufdcod,
                                a_cts19m06.brrnom,
                                a_cts19m06.lclbrrnom,
                                a_cts19m06.endzon,
                                a_cts19m06.lgdtip,
                                a_cts19m06.lgdnom,
                                a_cts19m06.lgdnum,
                                a_cts19m06.lgdcep,
                                a_cts19m06.lgdcepcmp,
                                a_cts19m06.lclltt,
                                a_cts19m06.lcllgt,
                                a_cts19m06.lclrefptotxt,
                                a_cts19m06.lclcttnom,
                                a_cts19m06.dddcod,
                                a_cts19m06.lcltelnum,
                                a_cts19m06.c24lclpdrcod,
                                a_cts19m06.ofnnumdig,
                                a_cts19m06.celteldddcod    ,
                                a_cts19m06.celtelnum ,
                                a_cts19m06.endcmp,
                                ws.retflg,
                                hist_cts19m06.*, a_cts19m06.emeviacod
                let m_lclbrrnom = a_cts19m06.lclbrrnom
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_lclbrrnom = a_cts19m06.lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts19m06.brrnom,
                                               a_cts19m06.lclbrrnom)
                     returning a_cts19m06.lclbrrnom

                let a_cts19m06.lgdtxt = a_cts19m06.lgdtip clipped, " ",
                                        a_cts19m06.lgdnom clipped, " ",
                                        a_cts19m06.lgdnum using "<<<<#"

                if a_cts19m06.lclltt is null then
                   error "Digite endereco para selecionar uma Loja, tecle F7"
                   continue while
                end if
                if a_cts19m06.lgdnom is null then
                   let a_cts19m06.lgdnom    = "NAO EXISTEM MAPA POR RUA"
                   let a_cts19m06.lclbrrnom = " "
                   let a_cts19m06.c24lclpdrcod = 03
                   continue while
                end if
                let w_cts19m06.ocrendlgd  =  a_cts19m06.lgdtxt
                let w_cts19m06.ocrendbrr  =  a_cts19m06.lclbrrnom
                let w_cts19m06.ocrendcid  =  a_cts19m06.cidnom
                let w_cts19m06.ocrufdcod  =  a_cts19m06.ufdcod
                let w_cts19m06.ocrcttnom  =  a_cts19m06.lclcttnom
                let ml_cts19m06.alt_lcloco  = "S"  ## devera alterar a loja

                ## Altera o Loal de Ocorencia
                let mr_datmsrvext1.ocrendlgd = w_cts19m06.ocrendlgd
                let mr_datmsrvext1.ocrendbrr = w_cts19m06.ocrendbrr
                let mr_datmsrvext1.ocrendcid = w_cts19m06.ocrendcid
                let mr_datmsrvext1.ocrufdcod = w_cts19m06.ocrufdcod
                let mr_datmsrvext1.ocrcttnom = w_cts19m06.ocrcttnom


              let a_cts19m06.lclbrrnom = m_lclbrrnom

              let m_status = cts06g07_local("M",
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            1,
                                            a_cts19m06.lclidttxt,
                                            a_cts19m06.lgdtip,
                                            a_cts19m06.lgdnom,
                                            a_cts19m06.lgdnum,
                                            a_cts19m06.lclbrrnom,
                                            a_cts19m06.brrnom,
                                            a_cts19m06.cidnom,
                                            a_cts19m06.ufdcod,
                                            a_cts19m06.lclrefptotxt,
                                            a_cts19m06.endzon,
                                            a_cts19m06.lgdcep,
                                            a_cts19m06.lgdcepcmp,
                                            a_cts19m06.lclltt,
                                            a_cts19m06.lcllgt,
                                            a_cts19m06.dddcod,
                                            a_cts19m06.lcltelnum,
                                            a_cts19m06.lclcttnom,
                                            a_cts19m06.c24lclpdrcod,
                                            a_cts19m06.ofnnumdig,
                                            a_cts19m06.emeviacod,
                                            a_cts19m06.celteldddcod,
                                            a_cts19m06.celtelnum,
                                            a_cts19m06.endcmp)

              if m_status <> 0 then
                 error "ERRO NA ATUALIZACAO DO ENDERECO DO SERVICO. CTS19m06" sleep 5
              end if

                exit while
             end while
             ##
             while true

                   call cts19m05(0,
                                 "",
                                 a_cts19m06.lclltt,
                                 a_cts19m06.lcllgt,
                                 "ctg2",
                                 w_cts19m06.alerta,
                                 "",
                                 "",
                                 "",
                                 d_cts19m06.vdrpbsavrfrqvlr,
                                 d_cts19m06.vdrvgaavrfrqvlr,
                                 d_aux19m06.vdresqavrfrqvlr,
                                 d_aux19m06.vdrdiravrfrqvlr,
                                 d_aux19m06.ocudiravrfrqvlr,
                                 d_aux19m06.ocuesqavrfrqvlr,
                                 d_cts19m06.vdrqbvavrfrqvlr,
                                 d_aux19m06.dirrtravrfrqvlr,
                                 d_aux19m06.esqrtravrfrqvlr,
                                 mr_vlrfrq76.drtfrlvlr,
                                 mr_vlrfrq76.esqfrlvlr,
                                 mr_vlrfrq76.esqmlhfrlvlr,
                                 mr_vlrfrq76.drtmlhfrlvlr,
                                 mr_vlrfrq76.drtnblfrlvlr,
                                 mr_vlrfrq76.esqnblfrlvlr,
                                 mr_vlrfrq76.esqpscvlr,
                                 mr_vlrfrq76.drtpscvlr,
                                 mr_vlrfrq76.drtlntvlr,
                                 mr_vlrfrq76.esqlntvlr)

                   returning d_cts19m06b.srrcoddig ,
                             d_cts19m06b.nomloja   ,
                             d_cts19m06b.cidnom    ,
                             d_cts19m06b.ufdcod    ,
                             d_cts19m06b.dddcod    ,
                             d_cts19m06b.teltxt    ,
                             d_cts19m06b.atdprscod ,
                             d_cts19m06b.nomprest  ,
                             d_cts19m06b.horloja   ,
                             d_cts19m06b.contato   ,
                             ws.segsexinchor       ,
                             ws.segsexfnlhor       ,
                             ws.sabinchor          ,
                             ws.sabfnlhor          ,
                             ws.atntip

                    if  mr_datmsrvext1.vdrrprgrpcod = d_cts19m06b.atdprscod  and
                        mr_datmsrvext1.vdrrprempcod = d_cts19m06b.srrcoddig then
                        if ml_cts19m06.alt_vidros = "N" then
                           call cts08g01("A","N","LOJA SELECIONADA, ",d_cts19m06b.nomloja,
                                         " E A MESMA QUE A ATUAL.", "SELECIONE OUTRA LOJA!")
                           returning ws.confirma
                        else
                           exit while
                        end if

                    else
                       let mr_datmsrvext1.vdrrprgrpcod = d_cts19m06b.atdprscod
                       let mr_datmsrvext1.vdrrprempcod = d_cts19m06b.srrcoddig
                       exit while
                    end if
             end while
         else

            call cts19m05(d_cts19m06b.atdprscod,
                          d_cts19m06b.srrcoddig,
                          "",
                          "",
                          "ctg2",
                          w_cts19m06.alerta,
                          g_documento.atdsrvnum,
                          g_documento.atdsrvano,
                          ml_cts19m06.lignum,
                          mr_datmsrvext1.vdrpbsavrfrqvlr,
                          mr_datmsrvext1.vdrvgaavrfrqvlr,
                          mr_datmsrvext1.vdresqavrfrqvlr,
                          mr_datmsrvext1.vdrdiravrfrqvlr,
                          mr_datmsrvext1.ocudiravrfrqvlr,
                          mr_datmsrvext1.ocuesqavrfrqvlr,
                          mr_datmsrvext1.vdrqbvavrfrqvlr,
                          mr_datmsrvext1.dirrtravrvlr,
                          mr_datmsrvext1.esqrtravrvlr,
                          mr_datmsrvext1.drtfrlvlr,
                          mr_datmsrvext1.esqfrlvlr,
                          mr_datmsrvext1.esqmlhfrlvlr,
                          mr_datmsrvext1.drtmlhfrlvlr,
                          mr_datmsrvext1.drtnblfrlvlr,
                          mr_datmsrvext1.esqnblfrlvlr,
                          mr_datmsrvext1.esqpscvlr,
                          mr_datmsrvext1.drtpscvlr,
                          mr_datmsrvext1.drtlntvlr,
                          mr_datmsrvext1.esqlntvlr)

                 returning d_cts19m06b.srrcoddig ,
                           d_cts19m06b.nomloja   ,
                           d_cts19m06b.cidnom    ,
                           d_cts19m06b.ufdcod    ,
                           d_cts19m06b.dddcod    ,
                           d_cts19m06b.teltxt    ,
                           d_cts19m06b.atdprscod ,
                           d_cts19m06b.nomprest  ,
                           d_cts19m06b.horloja   ,
                           d_cts19m06b.contato   ,
                           ws.segsexinchor       ,
                           ws.segsexfnlhor       ,
                           ws.sabinchor          ,
                           ws.sabfnlhor          ,
                           ws.atntip
         end if
         let d_cts19m06b.atntip = "REDE"
         if  w_cts19m06.atntip  =  2  then   # carregado na consulta
             let d_cts19m06b.atntip = "FORA DA REDE"
         end if
         display by name d_cts19m06b.atdprscod attribute (reverse)
         display by name d_cts19m06b.atdetpdes
         display by name d_cts19m06b.nomprest
         display by name d_cts19m06b.srrcoddig
         display by name d_cts19m06b.nomloja
         display by name d_cts19m06b.cidnom
         display by name d_cts19m06b.ufdcod
         display by name d_cts19m06b.dddcod
         display by name d_cts19m06b.teltxt
         display by name d_cts19m06b.nomprest
         display by name d_cts19m06b.horloja
         display by name d_cts19m06b.contato
         display by name d_cts19m06b.atntip
      end if
   else
      #--------------------------------------------------------------------
      # Salva conteudo dos campos
      #--------------------------------------------------------------------
      let ws.atdsrvorg          =  g_documento.atdsrvorg
      let d_cts19m06b.atdetpcod =  4
      let d_cts19m06b.cnldat    =  w_cts19m06.cnldat
      let d_cts19m06b.atdfnlhor =  w_cts19m06.atdfnlhor

      while true
       let w_cts19m06.atntip = 1
         # PSI 239.399 Clausula 77

          if g_vdr_blindado = "S" then
             let w_cts19m06.atntip = 2
             let d_cts19m06b.atntip = "FORA DA REDE"
             let ws.atntip = 2
          else
             let w_cts19m06.atntip = 1

             let d_cts19m06b.atntip = "REDE"    # ruiz
             if w_cts19m06.atntip = 2  then
                let d_cts19m06b.atntip = "FORA DA REDE"
             end if

             if aux_atdsrvnum is not null  and
                aux_atdsrvano is not null  then

                let a_cts19m06.lclbrrnom = m_lclbrrnom

                call cts06g03(1, 14,
                             w_cts19m06.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts19m06.lclidttxt,
                             a_cts19m06.cidnom,
                             a_cts19m06.ufdcod,
                             a_cts19m06.brrnom,
                             a_cts19m06.lclbrrnom,
                             a_cts19m06.endzon,
                             a_cts19m06.lgdtip,
                             a_cts19m06.lgdnom,
                             a_cts19m06.lgdnum,
                             a_cts19m06.lgdcep,
                             a_cts19m06.lgdcepcmp,
                             a_cts19m06.lclltt,
                             a_cts19m06.lcllgt,
                             a_cts19m06.lclrefptotxt,
                             a_cts19m06.lclcttnom,
                             a_cts19m06.dddcod,
                             a_cts19m06.lcltelnum,
                             a_cts19m06.c24lclpdrcod,
                             a_cts19m06.ofnnumdig,
                             a_cts19m06.celteldddcod    ,
                             a_cts19m06.celtelnum ,
                             a_cts19m06.endcmp,
                             hist_cts19m06.*, a_cts19m06.emeviacod)
                   returning a_cts19m06.lclidttxt,
                             a_cts19m06.cidnom,
                             a_cts19m06.ufdcod,
                             a_cts19m06.brrnom,
                             a_cts19m06.lclbrrnom,
                             a_cts19m06.endzon,
                             a_cts19m06.lgdtip,
                             a_cts19m06.lgdnom,
                             a_cts19m06.lgdnum,
                             a_cts19m06.lgdcep,
                             a_cts19m06.lgdcepcmp,
                             a_cts19m06.lclltt,
                             a_cts19m06.lcllgt,
                             a_cts19m06.lclrefptotxt,
                             a_cts19m06.lclcttnom,
                             a_cts19m06.dddcod,
                             a_cts19m06.lcltelnum,
                             a_cts19m06.c24lclpdrcod,
                             a_cts19m06.ofnnumdig,
                             a_cts19m06.celteldddcod    ,
                             a_cts19m06.celtelnum ,
                             a_cts19m06.endcmp,
                             ws.retflg,
                             hist_cts19m06.*,
                             a_cts19m06.emeviacod
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_lclbrrnom = a_cts19m06.lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts19m06.brrnom,
                                               a_cts19m06.lclbrrnom)
                     returning a_cts19m06.lclbrrnom

                let a_cts19m06.lgdtxt = a_cts19m06.lgdtip clipped, " ",
                                        a_cts19m06.lgdnom clipped, " ",
                                        a_cts19m06.lgdnum using "<<<<#"
             end if
             if a_cts19m06.lclltt is null then
                error "Digite endereco para selecionar uma Loja, tecle F7"
                continue while
             end if
             if a_cts19m06.lgdnom is null then
                let a_cts19m06.lgdnom    = "NAO EXISTEM MAPA POR RUA"
                let a_cts19m06.lclbrrnom = " "
                let a_cts19m06.c24lclpdrcod = 03
             end if
             let w_cts19m06.ocrendlgd  =  a_cts19m06.lgdtxt
             let w_cts19m06.ocrendbrr  =  a_cts19m06.lclbrrnom
             let w_cts19m06.ocrendcid  =  a_cts19m06.cidnom
             let w_cts19m06.ocrufdcod  =  a_cts19m06.ufdcod
             let w_cts19m06.ocrcttnom  =  a_cts19m06.lclcttnom
          end if
          let ws.flagf7  =  "S"
          while true

             call cts19m05(0,  #4,    ## PSI 239.399 Clausula 077  # w_cts19m06.atdprscod
                           "", #591,                               # w_cts19m06.srrcoddig
                           a_cts19m06.lclltt,
                           a_cts19m06.lcllgt,
                           "ctg2",
                           w_cts19m06.alerta,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ml_cts19m06.lignum,
                           d_cts19m06.vdrpbsavrfrqvlr,
                           d_cts19m06.vdrvgaavrfrqvlr,
                           d_aux19m06.vdresqavrfrqvlr,
                           d_aux19m06.vdrdiravrfrqvlr,
                           d_aux19m06.ocudiravrfrqvlr,
                           d_aux19m06.ocuesqavrfrqvlr,
                           d_cts19m06.vdrqbvavrfrqvlr,
                           d_aux19m06.dirrtravrfrqvlr,
                           d_aux19m06.esqrtravrfrqvlr,
                           mr_vlrfrq76.drtfrlvlr,
                           mr_vlrfrq76.esqfrlvlr,
                           mr_vlrfrq76.esqmlhfrlvlr,
                           mr_vlrfrq76.drtmlhfrlvlr,
                           mr_vlrfrq76.drtnblfrlvlr,
                           mr_vlrfrq76.esqnblfrlvlr,
                           mr_vlrfrq76.esqpscvlr,
                           mr_vlrfrq76.drtpscvlr,
                           mr_vlrfrq76.drtlntvlr,
                           mr_vlrfrq76.esqlntvlr)

                 returning d_cts19m06b.srrcoddig ,
                           d_cts19m06b.nomloja   ,
                           d_cts19m06b.cidnom    ,
                           d_cts19m06b.ufdcod    ,
                           d_cts19m06b.dddcod    ,
                           d_cts19m06b.teltxt    ,
                           d_cts19m06b.atdprscod ,
                           d_cts19m06b.nomprest  ,
                           d_cts19m06b.horloja   ,
                           d_cts19m06b.contato   ,
                           ws.segsexinchor       ,
                           ws.segsexfnlhor       ,
                           ws.sabinchor          ,
                           ws.sabfnlhor          ,
                           ws.atntip

             let w_cts19m06.atdetpcod = d_cts19m06b.atdetpcod
             let w_cts19m06.atdprscod = d_cts19m06b.atdprscod
             let w_cts19m06.srrcoddig = d_cts19m06b.srrcoddig
             display by name d_cts19m06b.atdprscod attribute (reverse)
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.srrcoddig
             display by name d_cts19m06b.nomloja
             display by name d_cts19m06b.cidnom
             display by name d_cts19m06b.ufdcod
             display by name d_cts19m06b.dddcod
             display by name d_cts19m06b.teltxt
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.horloja
             display by name d_cts19m06b.contato
             display by name d_cts19m06b.atntip

             if w_cts19m06.atdprscod is null then
                initialize ws.flagf7         to null
                initialize w_cts19m06.flagf8 to null
                exit while
             end if
             if ws.atntip         = 3  or # ambos
                w_cts19m06.atntip = ws.atntip then
                let ws.servico = g_documento.atdsrvorg using "&&",
                            "/", aux_atdsrvnum         using "&&&&&&&",
                            "-", aux_atdsrvano         using "&&"

                if d_cts19m06b.srrcoddig = 74 then #posto pacaembu
                   call cts08g01 ("A","N",
                                  "POSTO PACAEMBU-SERVICO ",ws.servico,
                                  "TRANSFIRA A LIGACAO PARA  FONE:3872-4771",
                                  "PARA ENTREVISTA E AGENDAMENTO.")
                       returning ws.confirma
                end if
                if d_cts19m06b.srrcoddig = 172 then #posto morumbi
                   let ws.msgtxt = "POSTO MORUMBI-SERVICO ", ws.servico
                   call cts08g01 ("A","N",
                                  ws.msgtxt,
                                  "TRANSFIRA  A  LIGACAO  PARA OS TELEFONES",
                                  "3771-7206  ou  3771-7067 ",
                                  "PARA ENTREVISTA E AGENDAMENTO.")
                       returning ws.confirma
                end if
                exit while
             end if
             if ws.atntip = 2 or ml_abrir = "S" then # PSI 239.399 Clausula 077
                exit while
             end if
          end while
          exit while
      end while
   end if

   select funnom
       into d_cts19m06b.operador
       from isskfunc
      where empcod = g_issk.empcod
        and funmat = w_cts19m06.funmat

   let d_cts19m06b.operador  = upshift(d_cts19m06b.operador)
   if w_cts19m06.atdfnlhor  is null then
      call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2
      let w_cts19m06.atdfnlhor      = l_hora2
   end if
   display by name d_cts19m06b.cnldat thru d_cts19m06b.operador
   display by name d_cts19m06b.atddatprg
   display by name d_cts19m06b.atdhorprg
   display by name d_cts19m06b.atdhorpvt
   if g_documento.atdsrvnum is null then
      message " (F7)Lojas "
   else
      message " (F6)Etapas, (F7)Dados da Loja, (F8)Tel.Segurado, (F9)Reenviar "
   end if
 #--------------------------------------------------------------------
 # Digita dados para conclusao
 #--------------------------------------------------------------------
   input by name d_cts19m06b.atdetpcod,
                 d_cts19m06b.atdprscod,
                 d_cts19m06b.imdsrvflg     without defaults

     before field atdetpcod
        if g_documento.atdsrvnum is null then
           if d_cts19m06b.srrcoddig = 25  or    # FORA DA REDE - carglass
              d_cts19m06b.srrcoddig = 74  or    # loja pacaembu - abravauto
              d_cts19m06b.srrcoddig = 172 then  # loja morumbi - carglass
              if int_flag  then
                 let int_flag = false
                 close window w_cts19m06b
              end if
              exit input
           end if
        end if
        display by name d_cts19m06b.atdetpcod attribute (reverse)

     after field atdetpcod
        display by name d_cts19m06b.atdetpcod
        if d_cts19m06b.atdetpcod is null   then
           error " Etapa deve ser informada!"
           call ctn26c00(ws.atdsrvorg) returning d_cts19m06b.atdetpcod
           next field atdetpcod
        else


           if g_documento.acao <> "ALT" and
              w_cts19m06.c24astcod <> "B14" then
              if d_cts19m06b.atdetpcod = 4  then
                 if salva.atdetpcod =  4  then
                    error "Servico Ja Acionado"
                    next field atdetpcod
                 end if
                 if ws.flagf7         is  null  and
                    w_cts19m06.flagf8 is  null  then
                    error "Selecione uma Loja prescionando F7 "
                    next field atdetpcod
                 end if
              else
                 if d_cts19m06b.atdetpcod = 5 and
                    salva.atdetpcod     <>  4 then
                    error "Servico ainda nao foi Acionado"
                    next field atdetpcod
                 end if
              end if
           end if
           select atdetpdes,
                  atdetptipcod,
                  atdetppndflg
             into d_cts19m06b.atdetpdes,
                  ws.atdetptipcod,
                  ws.atdetppndflg
             from datketapa
            where atdetpcod = d_cts19m06b.atdetpcod
              and atdetpstt = "A"

            if sqlca.sqlcode = notfound  then
               error " Etapa nao cadastrada! Informe novamente."
               call ctn26c00(ws.atdsrvorg) returning d_cts19m06b.atdetpcod
               next field atdetpcod
            end if
            display by name d_cts19m06b.atdetpdes

            if ws.atdetppndflg = "S"  then
               let ws.atdfnlflg = "N"
            else
               let ws.atdfnlflg = "S"
            end if
            select atdetpcod
              from datrsrvetp
             where atdsrvorg    = ws.atdsrvorg
               and atdetpcod    = d_cts19m06b.atdetpcod
               and atdsrvetpstt = "A"

            if sqlca.sqlcode = notfound  then
               error " Etapa nao pertence a este tipo de servico!"
               call ctn26c00(ws.atdsrvorg) returning d_cts19m06b.atdetpcod
               next field atdetpcod
            end if
            if d_cts19m06b.atdetpcod = 5  and
               salva.atdetpcod       = 4  then
               call cts08g01("C","N", "",
                             "CANCELAMENTO SO E PERMITIDO ",
                             "PELA TELA DA LIGACAO !!!    ","")
                  returning ws.confirma
               let d_cts19m06b.atdetpcod = salva.atdetpcod
               let d_cts19m06b.atdetpdes = salva.atdetpdes
               display by name d_cts19m06b.atdetpcod
               display by name d_cts19m06b.atdetpdes
               next field atdetpcod
            end if
        end if
        let w_cts19m06.atdetpcod = d_cts19m06b.atdetpcod
        let w_cts19m06.atdprscod = d_cts19m06b.atdprscod
        let w_cts19m06.srrcoddig = d_cts19m06b.srrcoddig

     before field atdprscod
        display by name d_cts19m06b.atdprscod attribute (reverse)
        if w_cts19m06.atdprscod is not null then
           next field imdsrvflg
        else
           error "Selecionar Prestador prescionando F7 "
           initialize ws.flagf7 to null
           next field atdetpcod
        end if

     after field atdprscod
        display by name d_cts19m06b.atdprscod

     before field imdsrvflg
        display by name d_cts19m06b.imdsrvflg attribute (reverse)

     after  field imdsrvflg
        display by name d_cts19m06b.imdsrvflg
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field atdetpcod
        end if
        if fgl_lastkey() <> fgl_keyval("up")   and
           fgl_lastkey() <> fgl_keyval("left") then
           if d_cts19m06b.imdsrvflg is null   or
              d_cts19m06b.imdsrvflg =  " "    then
              error " Informacoes sobre ida ate a Loja deve ser informado!"
              next field imdsrvflg
           end if
           if d_cts19m06b.imdsrvflg <> "S"    and
              d_cts19m06b.imdsrvflg <> "N"    then
              error " Ida ate a Loja e imediato?: (S)im ou (N)ao!"
              next field imdsrvflg
           end if
           let ws.atdfnlflg     =  w_cts19m06.atdfnlflg
           if d_cts19m06b.atdetpcod = 4 and
              salva.atdetpcod       = 5 then
              let ws.atdfnlflg  = "N"     # permite acionar novamente
           end if

           if g_documento.acao = "ALT"   and
              ml_cts19m06.alt_loja = "S" then  ## and
           ##    w_cts19m06.c24astcod = "B14" then
              let ws.atdfnlflg = "N"
           end if

           call cts02m04(ws.atdfnlflg,
                         d_cts19m06b.imdsrvflg,
                         w_cts19m06.atdhorpvt,
                         w_cts19m06.atddatprg,
                         w_cts19m06.atdhorprg)
               returning w_cts19m06.atdhorpvt,
                         w_cts19m06.atddatprg,
                         w_cts19m06.atdhorprg
           if d_cts19m06b.imdsrvflg  =  "S"  then
              if w_cts19m06.atdhorpvt is null  then
                 error "Horas previstas nao informada para servico imediato!"
                 next field imdsrvflg
              end if
           else
              if w_cts19m06.atddatprg is null  or
                 w_cts19m06.atddatprg  = " "   or
                 w_cts19m06.atdhorprg is null  then
                 error " Faltam dados para servico programado!"
                 next field imdsrvflg
              end if
           end if
           call c24geral9(w_cts19m06.atddatprg,0,"01000","S","S")
                returning ws.data_util
           if ws.data_util is not null  and   ## Feriado
              ws.data_util <> w_cts19m06.atddatprg then
              error "Loja nao atende nos Feriados"
              next field imdsrvflg
           end if
           if weekday(w_cts19m06.atddatprg) = 0 then # domingo
              error "Lojas nao atende aos Domingos"
              next field imdsrvflg
           end if
           if weekday(w_cts19m06.atddatprg) > 0 and  # de seg. a sexta
              weekday(w_cts19m06.atddatprg) < 6 then
              if w_cts19m06.atdhorprg < ws.segsexinchor or
                 w_cts19m06.atdhorprg > ws.segsexfnlhor then
                 error "Loja nao atende neste horario de seg. a sexta"
                 next field imdsrvflg
              end if
           else
             if w_cts19m06.atdhorprg <  ws.sabinchor  or
                w_cts19m06.atdhorprg >  ws.sabfnlhor  then
                error "Loja nao atende neste horario aos sabados"
                next field imdsrvflg
             end if
           end if

           let d_cts19m06b.atddatprg = w_cts19m06.atddatprg
           let d_cts19m06b.atdhorprg = w_cts19m06.atdhorprg
           let d_cts19m06b.atdhorpvt = w_cts19m06.atdhorpvt

           if g_documento.acao      = "ALT"   and
              (w_cts19m06.c24astcod = "ALT"   or
               w_cts19m06.c24astcod = "B14" ) then
              let mr_datmsrvext1.atddatprg = w_cts19m06.atddatprg
              let mr_datmsrvext1.atdhorprg = w_cts19m06.atdhorprg
              let mr_datmsrvext1.atdhorpvt = w_cts19m06.atdhorpvt

              if ( ml_cts19m06.alt_loja   = "S"   and
                   ml_cts19m06.alt_vidros = "N" ) then

                   ## Implementar Local de Ocorrencia
                   let mr_datmsrvext1.ocrendlgd = w_cts19m06.ocrendlgd
                   let mr_datmsrvext1.ocrendbrr = w_cts19m06.ocrendbrr
                   let mr_datmsrvext1.ocrendcid = w_cts19m06.ocrendcid
                   let mr_datmsrvext1.ocrufdcod = w_cts19m06.ocrufdcod
                   let mr_datmsrvext1.ocrcttnom = w_cts19m06.ocrcttnom
                   ##

                   call cts19m06_busca_franq(d_cts19m06.vclcoddig,
                                             d_cts19m06.vclanomdl,
                                             w_cts19m06.clscod)

                    returning mr_vlrfrq76.frqvlrfarois

                   call cts19m06_alt_loja(g_documento.atdsrvnum,
                                          g_documento.atdsrvano,
                                          g_documento.lignum,
                                          w_cts19m06.lignum,
                                          ml_cts19m06.lignum,
                                          w_cts19m06.srrcoddig,
                                          w_cts19m06.atdprscod,
                                          mr_datmsrvext1.atdhorpvt,
                                          mr_datmsrvext1.atddatprg,
                                          mr_datmsrvext1.atdhorprg )
              end if
           end if
        end if
        display by name d_cts19m06b.atddatprg
        display by name d_cts19m06b.atdhorprg
        display by name d_cts19m06b.atdhorpvt

     on key (interrupt)
        call cts08g01("C","S","","ABANDONA PREENCHIMENTO DA SOLICITACAO?","","")
             returning ws.confirma
        if ws.confirma = "S"   then
           let int_flag = true
           exit input
        else
           let int_flag = false
           continue input
        end if

     #--------------------------------------------------------------------
     # Exibe Etapas
     #--------------------------------------------------------------------
     on key (F6)
          open window w_branco at 04,02 with 04 rows,78 columns
          call cts00m11(g_documento.atdsrvnum, g_documento.atdsrvano)
          close window w_branco
     #--------------------------------------------------------------------
     # Pesquisa Lojas
     #--------------------------------------------------------------------
     on key (F7)
          initialize ws.flagf7,w_cts19m06.flagf8  to null

          if g_vdr_blindado = "S" and salva.atdetpcod is null then
             let salva.atdetpcod = d_cts19m06b.atdetpcod
             let d_cts19m06b.srrcoddig = null
          end if
          if salva.atdetpcod = 4 then
             error "Servico ja acionado"
            #next field atdetpcod
             call cts19m05(d_cts19m06b.atdprscod,
                           d_cts19m06b.srrcoddig,
                           "",
                           "",
                           "",
                           w_cts19m06.alerta,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ml_cts19m06.lignum,
                           mr_datmsrvext1.vdrpbsavrfrqvlr,
                           mr_datmsrvext1.vdrvgaavrfrqvlr,
                           mr_datmsrvext1.vdresqavrfrqvlr,
                           mr_datmsrvext1.vdrdiravrfrqvlr,
                           mr_datmsrvext1.ocudiravrfrqvlr,
                           mr_datmsrvext1.ocuesqavrfrqvlr,
                           mr_datmsrvext1.vdrqbvavrfrqvlr,
                           mr_datmsrvext1.dirrtravrvlr,
                           mr_datmsrvext1.esqrtravrvlr,
                           mr_datmsrvext1.drtfrlvlr,
                           mr_datmsrvext1.esqfrlvlr,
                           mr_datmsrvext1.esqmlhfrlvlr,
                           mr_datmsrvext1.drtmlhfrlvlr,
                           mr_datmsrvext1.drtnblfrlvlr,
                           mr_datmsrvext1.esqnblfrlvlr,
                           mr_datmsrvext1.esqpscvlr,
                           mr_datmsrvext1.drtpscvlr,
                           mr_datmsrvext1.drtlntvlr,
                           mr_datmsrvext1.esqlntvlr)

                  returning d_cts19m06b.srrcoddig ,
                            d_cts19m06b.nomloja   ,
                            d_cts19m06b.cidnom    ,
                            d_cts19m06b.ufdcod    ,
                            d_cts19m06b.dddcod    ,
                            d_cts19m06b.teltxt    ,
                            d_cts19m06b.atdprscod ,
                            d_cts19m06b.nomprest  ,
                            d_cts19m06b.horloja   ,
                            d_cts19m06b.contato   ,
                            ws.segsexinchor       ,
                            ws.segsexfnlhor       ,
                            ws.sabinchor          ,
                            ws.sabfnlhor          ,
                            ws.atntip
             next field atdetpcod
          end if
          let w_cts19m06.atntip = null
          ## call cts19m06_tipatd() returning w_cts19m06.atntip PSI193690
          let w_cts19m06.atntip = 1
          if w_cts19m06.atntip is null then
             error "escolha o tipo de atendimento "
             next field atdetpcod
          end if
          let d_cts19m06b.atntip = "REDE"    # ruiz
          if w_cts19m06.atntip = 2  then
             let d_cts19m06b.atntip = "FORA DA REDE"
          end if

          ## Verificar ???

          if w_cts19m06.atntip  =  2 then   # FORA DA REDE
             let d_cts19m06b.atdprscod = 1      # carglass
             let d_cts19m06b.srrcoddig = 25     # REDE da carglass

             call cts19m05(d_cts19m06b.atdprscod,
                           d_cts19m06b.srrcoddig,
                           "",
                           "",
                           "ctg2",
                           w_cts19m06.alerta,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ml_cts19m06.lignum,
                           mr_datmsrvext1.vdrpbsavrfrqvlr,
                           mr_datmsrvext1.vdrvgaavrfrqvlr,
                           mr_datmsrvext1.vdresqavrfrqvlr,
                           mr_datmsrvext1.vdrdiravrfrqvlr,
                           mr_datmsrvext1.ocudiravrfrqvlr,
                           mr_datmsrvext1.ocuesqavrfrqvlr,
                           mr_datmsrvext1.vdrqbvavrfrqvlr,
                           mr_datmsrvext1.dirrtravrvlr,
                           mr_datmsrvext1.esqrtravrvlr,
                           mr_datmsrvext1.drtfrlvlr,
                           mr_datmsrvext1.esqfrlvlr,
                           mr_datmsrvext1.esqmlhfrlvlr,
                           mr_datmsrvext1.drtmlhfrlvlr,
                           mr_datmsrvext1.drtnblfrlvlr,
                           mr_datmsrvext1.esqnblfrlvlr,
                           mr_datmsrvext1.esqpscvlr,
                           mr_datmsrvext1.drtpscvlr,
                           mr_datmsrvext1.drtlntvlr,
                           mr_datmsrvext1.esqlntvlr)

                 returning d_cts19m06b.srrcoddig ,
                           d_cts19m06b.nomloja   ,
                           d_cts19m06b.cidnom    ,
                           d_cts19m06b.ufdcod    ,
                           d_cts19m06b.dddcod    ,
                           d_cts19m06b.teltxt    ,
                           d_cts19m06b.atdprscod ,
                           d_cts19m06b.nomprest  ,
                           d_cts19m06b.horloja   ,
                           d_cts19m06b.contato   ,
                           ws.segsexinchor       ,
                           ws.segsexfnlhor       ,
                           ws.sabinchor          ,
                           ws.sabfnlhor          ,
                           ws.atntip
             let w_cts19m06.flagf8    =  "S"
             let w_cts19m06.atdetpcod = d_cts19m06b.atdetpcod
             let w_cts19m06.atdprscod = d_cts19m06b.atdprscod
             let w_cts19m06.srrcoddig = d_cts19m06b.srrcoddig
             display by name d_cts19m06b.atdprscod attribute (reverse)
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.srrcoddig
             display by name d_cts19m06b.nomloja
             display by name d_cts19m06b.cidnom
             display by name d_cts19m06b.ufdcod
             display by name d_cts19m06b.dddcod
             display by name d_cts19m06b.teltxt
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.horloja
             display by name d_cts19m06b.contato
             display by name d_cts19m06b.atntip

             exit input
          end if

          if aux_atdsrvnum is not null  and
             aux_atdsrvano is not null  then

             let a_cts19m06.lclbrrnom = m_lclbrrnom

             call cts06g03(1, 14,
                          w_cts19m06.ligcvntip,
                          aux_today,
                          aux_hora,
                          a_cts19m06.lclidttxt,
                          a_cts19m06.cidnom,
                          a_cts19m06.ufdcod,
                          a_cts19m06.brrnom,
                          a_cts19m06.lclbrrnom,
                          a_cts19m06.endzon,
                          a_cts19m06.lgdtip,
                          a_cts19m06.lgdnom,
                          a_cts19m06.lgdnum,
                          a_cts19m06.lgdcep,
                          a_cts19m06.lgdcepcmp,
                          a_cts19m06.lclltt,
                          a_cts19m06.lcllgt,
                          a_cts19m06.lclrefptotxt,
                          a_cts19m06.lclcttnom,
                          a_cts19m06.dddcod,
                          a_cts19m06.lcltelnum,
                          a_cts19m06.c24lclpdrcod,
                          a_cts19m06.ofnnumdig,
                          a_cts19m06.celteldddcod    ,
                          a_cts19m06.celtelnum ,
                          a_cts19m06.endcmp,
                          hist_cts19m06.*, a_cts19m06.emeviacod)
                returning a_cts19m06.lclidttxt,
                          a_cts19m06.cidnom,
                          a_cts19m06.ufdcod,
                          a_cts19m06.brrnom,
                          a_cts19m06.lclbrrnom,
                          a_cts19m06.endzon,
                          a_cts19m06.lgdtip,
                          a_cts19m06.lgdnom,
                          a_cts19m06.lgdnum,
                          a_cts19m06.lgdcep,
                          a_cts19m06.lgdcepcmp,
                          a_cts19m06.lclltt,
                          a_cts19m06.lcllgt,
                          a_cts19m06.lclrefptotxt,
                          a_cts19m06.lclcttnom,
                          a_cts19m06.dddcod,
                          a_cts19m06.lcltelnum,
                          a_cts19m06.c24lclpdrcod,
                          a_cts19m06.ofnnumdig,
                          a_cts19m06.celteldddcod    ,
                          a_cts19m06.celtelnum ,
                          a_cts19m06.endcmp,
                          ws.retflg,
                          hist_cts19m06.*, a_cts19m06.emeviacod
             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_lclbrrnom = a_cts19m06.lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts19m06.brrnom,
                                            a_cts19m06.lclbrrnom)
                  returning a_cts19m06.lclbrrnom
             let a_cts19m06.lgdtxt = a_cts19m06.lgdtip clipped, " ",
                                     a_cts19m06.lgdnom clipped, " ",
                                     a_cts19m06.lgdnum using "<<<<#"
          end if
          if a_cts19m06.lclltt is null then
             error "Digite endereco para selecionar uma Loja, tecle F7"
             next field atdetpcod
          end if
          if a_cts19m06.lgdnom is null then
             let a_cts19m06.lgdnom    = "NAO EXISTEM MAPA POR RUA"
             let a_cts19m06.lclbrrnom = " "
             let a_cts19m06.c24lclpdrcod = 03
          end if
          let w_cts19m06.ocrendlgd  =  a_cts19m06.lgdtxt
          let w_cts19m06.ocrendbrr  =  a_cts19m06.lclbrrnom
          let w_cts19m06.ocrendcid  =  a_cts19m06.cidnom
          let w_cts19m06.ocrufdcod  =  a_cts19m06.ufdcod
          let w_cts19m06.ocrcttnom  =  a_cts19m06.lclcttnom

          let ws.flagf7  =  "S"

          while true

             call cts19m05(0,
                           "",
                           a_cts19m06.lclltt,
                           a_cts19m06.lcllgt,
                           "ctg2",
                           w_cts19m06.alerta,
                           g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           ml_cts19m06.lignum,
                           mr_datmsrvext1.vdrpbsavrfrqvlr,
                           mr_datmsrvext1.vdrvgaavrfrqvlr,
                           mr_datmsrvext1.vdresqavrfrqvlr,
                           mr_datmsrvext1.vdrdiravrfrqvlr,
                           mr_datmsrvext1.ocudiravrfrqvlr,
                           mr_datmsrvext1.ocuesqavrfrqvlr,
                           mr_datmsrvext1.vdrqbvavrfrqvlr,
                           mr_datmsrvext1.dirrtravrvlr,
                           mr_datmsrvext1.esqrtravrvlr,
                           mr_datmsrvext1.drtfrlvlr,
                           mr_datmsrvext1.esqfrlvlr,
                           mr_datmsrvext1.esqmlhfrlvlr,
                           mr_datmsrvext1.drtmlhfrlvlr,
                           mr_datmsrvext1.drtnblfrlvlr,
                           mr_datmsrvext1.esqnblfrlvlr,
                           mr_datmsrvext1.esqpscvlr,
                           mr_datmsrvext1.drtpscvlr,
                           mr_datmsrvext1.drtlntvlr,
                           mr_datmsrvext1.esqlntvlr)

                 returning d_cts19m06b.srrcoddig ,
                           d_cts19m06b.nomloja   ,
                           d_cts19m06b.cidnom    ,
                           d_cts19m06b.ufdcod    ,
                           d_cts19m06b.dddcod    ,
                           d_cts19m06b.teltxt    ,
                           d_cts19m06b.atdprscod ,
                           d_cts19m06b.nomprest  ,
                           d_cts19m06b.horloja   ,
                           d_cts19m06b.contato   ,
                           ws.segsexinchor       ,
                           ws.segsexfnlhor       ,
                           ws.sabinchor          ,
                           ws.sabfnlhor          ,
                           ws.atntip
             let w_cts19m06.atdetpcod = d_cts19m06b.atdetpcod
             let w_cts19m06.atdprscod = d_cts19m06b.atdprscod
             let w_cts19m06.srrcoddig = d_cts19m06b.srrcoddig
             display by name d_cts19m06b.atdprscod attribute (reverse)
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.srrcoddig
             display by name d_cts19m06b.nomloja
             display by name d_cts19m06b.cidnom
             display by name d_cts19m06b.ufdcod
             display by name d_cts19m06b.dddcod
             display by name d_cts19m06b.teltxt
             display by name d_cts19m06b.nomprest
             display by name d_cts19m06b.horloja
             display by name d_cts19m06b.contato
             display by name d_cts19m06b.atntip

             if w_cts19m06.atdprscod is null then
                initialize ws.flagf7         to null
                initialize w_cts19m06.flagf8 to null
                exit while
             end if
             if ws.atntip         = 3  or # ambos
                w_cts19m06.atntip = ws.atntip then
                exit while
             end if
          end while

      on key (F8)
         select segdddcod,segteltxt
              into w_cts19m06.segdddcod,
                   w_cts19m06.segteltxt
              from datmsrvext1
             where atdsrvnum = g_documento.atdsrvnum
               and atdsrvano = g_documento.atdsrvano
               and lignum    = w_cts19m06.lignum
         call cts19m02(w_cts19m06.segdddcod,w_cts19m06.segteltxt,"C")
               returning w_cts19m06.segdddcod,
                         w_cts19m06.segteltxt  # ddd/tel segurado

      on key (F9)   # reenviar
         if g_documento.atdsrvnum is not null then

            whenever error continue
            begin work
              update datmsrvext1
                   set (segdddcod,segteltxt)
                     = (w_cts19m06.segdddcod,w_cts19m06.segteltxt)
                 where atdsrvnum = g_documento.atdsrvnum
                   and atdsrvano = g_documento.atdsrvano
                   and lignum    = w_cts19m06.lignum
              if sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") na gravacao da tabela",
                       " datmsrvext1(reenvia). AVISE A INFORMATICA!"
                 rollback work
                 prompt "" for char prompt_key
                 next field atdetpcod
              end if
            whenever error stop
            commit work

            if d_cts19m06b.atdprscod  = 1   and     # carglass
               d_cts19m06b.srrcoddig  = 25  then
               let ws.servico = g_documento.atdsrvorg using "&&",
                           "/", g_documento.atdsrvnum using "&&&&&&&",
                           "-", g_documento.atdsrvano using "&&"
               let ws.msgtxt = "No.Servico ", ascii(27),
                               "[7m",ws.servico , ascii(27),"[0m"
               call cts08g01("A","N","SOLICITACAO REENVIADA PARA CARGLASS!",
                             "","TRANSFIRA LIGACAO INFORMANDO", ws.msgtxt)
                    returning ws.confirma
            end if
            call cts19m07 (g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           w_cts19m06.lignum,
                           mr_vlrfrq76.frqvlrfarois,
                           m_sin.sinvstnum,
                           m_sin.sinvstano,
                           m_sin.sinano, m_sin.sinnum)

         end if
   end input
   close window w_cts19m06b
 end function    # aciona

#------------------------------------------------------------------------------
 function cts19m06_tipatd()
#------------------------------------------------------------------------------

   define d_cts19m06a record
       atdloja      char(1),
       atddomic     char(1)
   end record
   define ws  record
       atntip       dec (1,0)
   end record






#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts19m06a.*  to  null

        initialize  ws.*  to  null

        initialize  d_cts19m06a.*  to  null

        initialize  ws.*  to  null

   initialize d_cts19m06a.*  to null
   initialize ws.*           to null

   open window cts19m06a at 10,40 with form "cts19m06a"
                attribute(border,form line 1)

   let int_flag  =  false
   input by name d_cts19m06a.atdloja,
                 d_cts19m06a.atddomic
           without defaults

       before field atdloja
          display by name d_cts19m06a.atdloja  attribute (reverse)

       after field atdloja
          display by name d_cts19m06a.atdloja
          if d_cts19m06a.atdloja is not null then
             if d_cts19m06a.atdloja <> "X" then
                error "escolha opcao com  X "
                next field atdloja
             else
                let ws.atntip  =  1         # loja
                exit input
             end if
          end if

       before field atddomic
          display by name d_cts19m06a.atddomic  attribute (reverse)

       after field atddomic
          display by name d_cts19m06a.atddomic
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdloja
          end if
          if d_cts19m06a.atddomic is not null then
             if d_cts19m06a.atddomic <> "X" then
                error "escolha opcao com  X "
                next field atddomic
             else
                #-- Henrique - cl 075
                if d_aux19m06.dirrtravrfrqvlr is not null or
                   d_aux19m06.esqrtravrfrqvlr is not null then
                   error "Espelhos Retrovisores diretamente nas lojas!"
                next field atddomic
                else
                   let ws.atntip  =  2       # FORA DA REDE
                   exit input
                end if
             end if
          end if

      on key (interrupt)
         exit input

    end input

    if int_flag then
       let int_flag = false
    end if

    close window cts19m06a

    return ws.atntip

 end function  # cts19m06_tipatd
#------------------------------------------------------------------------------
 function cts19m06_envia(param)
#------------------------------------------------------------------------------
   define param  record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano,
          atdprscod   like datmservico.atdprscod,
          srrcoddig   like datmservico.srrcoddig
   end record
   define ws   record
          telupdflg   dec (1,0),
          msgtxt      char(40),
          servico     char(13),
          confirma    char(01)
   end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

   initialize  ws.*  to  null

   if g_documento.c24soltipcod = 1  or    # Tipo Solic = Segurado
      g_documento.c24soltipcod = 7  then
   else
      let ws.telupdflg = false
   end if

   if g_documento.aplnumdig is not null then
      call cts09g00(g_documento.ramcod   ,
                    g_documento.succod   ,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    ws.telupdflg)
          returning w_cts19m06.segdddcod,
                    w_cts19m06.segteltxt
   end if

   call cts19m02(w_cts19m06.segdddcod,w_cts19m06.segteltxt,"")
               returning w_cts19m06.segdddcod,
                         w_cts19m06.segteltxt  # ddd/tel segurado

   if param.atdprscod = 1  and
      param.srrcoddig = 25 then   # carglass
      let ws.servico = g_documento.atdsrvorg using "&&",
                  "/", param.atdsrvnum using "&&&&&&&",
                  "-", param.atdsrvano using "&&"
      let ws.msgtxt = "No.Servico ", ascii(27), "[7m",ws.servico , ascii(27), "[0m"
      call cts08g01("A","N","SOLICITACAO REENVIADA PARA CARGLASS!",
                    "","TRANSFIRA LIGACAO INFORMANDO", ws.msgtxt)
           returning ws.confirma
   end if
 end function
#------------------------------------------------------------------------------
 function cts19m06_vidros( w_pb, w_vg, w_ld, w_le )
#------------------------------------------------------------------------------

   define w_pb             smallint
   define w_vg             smallint
   define w_ld             smallint
   define w_le             smallint
   define w_mensagem       char(40)
   define w_retorno        char(02)



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     w_mensagem  =  null
        let     w_retorno  =  null

        let     w_mensagem  =  null
        let     w_retorno  =  null

   open  window w_avltc012 at 10,15 with form "avltc012"
         attribute( border, form line first )

   display "     Selecione o vidro a consultar"  to mensagem

   open  window w_avltc012i at 13,19 with 2 rows, 35 columns

   menu ""
     before menu
            hide option all

            if  w_pb  then
                show option "PARA-BRISA"
            end if
            if  w_vg  then
                show option "VIGIA"
            end if
            if  w_ld or w_le  then
                show option "LATERAIS"
            end if

     command "PARA-BRISA"
             let w_retorno = "PB"
             exit menu
     command "VIGIA"
             let w_retorno = "VG"
             exit menu
     command "LATERAIS"
             let w_retorno = "LT"
             exit menu
     command key( accept )
             continue menu
     command key( interrupt )
             let w_retorno = "  "
             let int_flag = false
             exit menu
   end menu

   close window w_avltc012i
   close window w_avltc012

   return w_retorno
end function
----------------------------------------------------------------------
function cts19m06_trocas(l_tipoAcao)
----------------------------------------------------------------------
 define l_vig           record
        ini             date,
        fnl             date
 end    record

 define l_ret           record
        qtdrep          smallint,
        qtdtroca        smallint,
        qtdretro        smallint
 end    record

 define l_confirma      char(01),
        l_soma          smallint,
        l_desc          char(100),
        l_vclchsinc     like abbmveic.vclchsinc,
        l_vclchsfnl     like abbmveic.vclchsfnl,
        l_tipoAcao      char(03)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_confirma  =  null
        let     l_soma  =  null
        let     l_desc  =  null
        let     l_vclchsinc  =  null
        let     l_vclchsfnl  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  l_vig.*  to  null

        initialize  l_ret.*  to  null

 let m_qtdvidro = 0
 let m_qtdretro = 0

 if g_documento.c24astcod <> "G13"  then
   call cts05g00 (g_documento.succod   ,
                  g_documento.ramcod   ,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig)
        returning d_cts19m06.nom      ,
                  d_cts19m06.corsus   ,
                  d_cts19m06.cornom   ,
                  d_cts19m06.cvnnom   ,
                  d_cts19m06.vclcoddig,
                  d_cts19m06.vcldes   ,
                  d_cts19m06.vclanomdl,
                  d_cts19m06.vcllicnum,
                  l_vclchsinc        ,
                  l_vclchsfnl        ,
                  d_cts19m06.vclcordes
   let w_cts19m06.vclchsnum = l_vclchsinc clipped, l_vclchsfnl
 end if

 if l_tipoAcao            = "CRI" and
    g_documento.c24astcod = "B90" then
    #--> Nao precisa criticar - Roni
    return true
 end if

 whenever error continue
 select viginc, vigfnl into l_vig.*
   from abamapol
  where succod    = g_documento.succod
    and aplnumdig = g_documento.aplnumdig
 whenever error stop

 if sqlca.sqlcode = 0 then
    call ctx20g00("C",
                  l_vig.ini,
                  l_vig.fnl,
                  l_vclchsfnl,
                  d_cts19m06.vcllicnum)
         returning l_ret.*

    let m_qtdvidro = l_ret.qtdtroca
    let m_qtdretro = l_ret.qtdretro

    ##display ""
    ##display "m_qtdvidro: ", m_qtdvidro
    ##display "m_qtdretro: ", m_qtdretro
    ##display ""

    if l_ret.qtdrep > 0 or l_ret.qtdtroca > 0 or l_ret.qtdretro > 0 then

       call ctx20g00a(l_ret.qtdrep,
                      l_ret.qtdtroca,
                      l_ret.qtdretro,
                      l_vig.ini,
                      l_vig.fnl,
                      l_vclchsfnl,
                      d_cts19m06.vcllicnum)

       if g_documento.atdsrvnum is not null then #--> Se vei do f3, nao critica
          return true
       end if

       let l_soma = 0
       let l_desc = ""
       case
           when w_cts19m06.clscod is null
                let l_soma = l_ret.qtdtroca + l_ret.qtdretro

           when w_cts19m06.clscod = 71 and l_ret.qtdtroca >= 3
                let l_soma = l_ret.qtdtroca
                let l_desc = "DE VIDROS"

           when ( w_cts19m06.clscod = 75 or w_cts19m06.clscod = "75R" )
                                       and l_ret.qtdretro >= 2
                                       and l_ret.qtdtroca >= 3
                   let l_soma = 3
                   let l_desc = "DE RETROV. OU DE VIDROS"

           when ( w_cts19m06.clscod = 76 or w_cts19m06.clscod = "76R" )
                                       and l_ret.qtdretro >= 2
                                       and l_ret.qtdtroca >= 3
                   let l_soma = 3
                   let l_desc = "DE RETROV. OU DE VIDROS"
       end case

       if l_soma >= 3 then
          let l_desc = "LIMITE DE TROCAS ", l_desc clipped
          call cts08g01("A",
                        "S",
                        "",
                        l_desc,
                        "EXCEDIDO. CONSULTE A COORDENACAO.",
                        "")
                returning l_confirma

          let int_flag = false

          return false
       end if
    end if
 else
    if sqlca.sqlcode = 100 then
       error "Vigencia nao encontrada."
    else
       error "Erro ", sqlca.sqlcode using "<<<<<<&",
             " no acesso a tabela abamapol."
    end if
 end if

 return true

end function

----------------------------------------------------------------------------
function cts19m06_grava_sinistro()
----------------------------------------------------------------------------
   define ws    record
          lignum       like datmligacao.lignum   ,
          atdsrvnum    like datmservico.atdsrvnum,
          atdsrvano    like datmservico.atdsrvano,
          codigosql    integer                   ,
          sinvstnum    like datmvstsin.sinvstnum ,
          sinvstano    like datmvstsin.sinvstano ,
          msg          char(80)                  ,
          data         char (10)                 ,
          ano2         char (02)                 ,
          ano4         char (04)                 ,
          hora         char (05)                 ,
          prompt_key   char (01)                 ,
          ok           smallint
   end record

   define l_data     date,
          l_hora2    datetime hour to minute,
          l_cont     smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_data  =  null
        let     l_hora2 =  null
        let     l_cont  =  0

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

   initialize ws.* to null

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.data = l_data
   let ws.ano2 = ws.data[9,10]
   let ws.ano4 = ws.data[7,10]
   let ws.hora = l_hora2
   let ws.ok = 1

   ## begin work

   call cts10g03_numeracao(0,"5") #nao gera ligacao, so gera numero do aviso
        returning ws.lignum   ,   #11/02/08.
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if ws.codigosql <> 0 then
      let ws.msg = "CTS19M06 - ",ws.msg
      call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
   ## rollback work
      prompt "" for char ws.prompt_key
      let ws.ok = 0
      return ws.ok,
          ws.sinvstnum,
          ws.sinvstano
   end if
   let ws.sinvstnum = ws.atdsrvnum
   ###let ws.sinvstano = ws.ano4
   let ws.ano4 = '20', ws.atdsrvano using "&&"
   let ws.sinvstano = ws.ano4

   # 01/01/2012 - Roberto - Processo Paliativo

   open ccts19m06012 using  ws.sinvstnum , ws.sinvstano
   whenever error continue
   fetch ccts19m06012 into l_cont
   whenever error stop

   if l_cont > 0 then

    open ccts19m06013 using  ws.sinvstano
    whenever error continue
    fetch ccts19m06013 into  ws.sinvstnum
    whenever error stop

    if sqlca.sqlcode = 0 then
       let ws.sinvstnum = ws.sinvstnum + 1
    end if

   end if


   call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
   let ws.msg = "CTS19M06 - Numero do Aviso : ", ws.sinvstnum,"/",
                                                 ws.sinvstano, l_data
   call cts19m06_grava_erro(ws.sinvstano, ws.sinvstnum, ws.msg)

   insert into datrligsinvst ( lignum   ,
                               ramcod   ,
                               sinvstnum,
                               sinvstano )
                      values ( g_documento.lignum,
                               g_documento.ramcod,
                               ws.sinvstnum,
                               ws.sinvstano    )
   if sqlca.sqlcode <> 0  then
      let ws.msg = "CTS19M06 - Erro ao gravar  DATRLIGSINVST : ",
                    ws.sinvstnum," / ",ws.sinvstano, l_data, sqlca.sqlcode
      call cts19m06_grava_erro(ws.sinvstano, ws.sinvstnum, ws.msg)
   ## rollback work
      let ws.ok = 0
      return ws.ok,
          ws.sinvstnum,
          ws.sinvstano
   end if

   insert into datmvstsin (sinvstnum   ,
                           sinvstano   ,
                           vstsolnom   ,
                           vstsoltip   ,
                           vstsoltipcod,
                           segnom      ,
                           aplnumdig   ,
                           itmnumdig   ,
                           succod      ,
                           ramcod      ,
                           subcod      ,
                           dddcod      ,
                           teltxt      ,
                           cornom      ,
                           corsus      ,
                           vcldes      ,
                           vclanomdl   ,
                           vcllicnum   ,
                           vclchsfnl   ,
                         # sinvstrgi   ,
                           sindat      ,
                           sinavs      ,
                           orcvlr      ,
                           ofnnumdig   ,
                           vstdat      ,
                           vstretdat   ,
                           vstretflg   ,
                           funmat      ,
                           atddat      ,
                           atdhor      ,
                           sinvstorgnum,
                           sinvstorgano,
                           sinvstsolsit,
                           prporg      ,
                           prpnumdig   ,
                           empcod      ,
                           usrtip      )
                  values ( ws.sinvstnum   ,
                           ws.sinvstano   ,
                           g_documento.solnom     ,
                           g_documento.soltip     ,
                           g_documento.c24soltipcod,
                           d_cts19m06.nom         ,
                           g_documento.aplnumdig  ,
                           g_documento.itmnumdig  ,
                           g_documento.succod     ,
                           g_documento.ramcod     ,
                           0                      ,
                           w_cts19m06.segdddcod   ,
                           w_cts19m06.segteltxt   ,
                           d_cts19m06.cornom      ,
                           d_cts19m06.corsus      ,
                           d_cts19m06.vcldes      ,
                           d_cts19m06.vclanomdl   ,
                           d_cts19m06.vcllicnum   ,
                           w_cts19m06.vclchsfnl   ,
                         # d_cts14m00.sinvstrgi   ,
                           l_data                  ,
                           "I"                    ,# com quem esta o aviso
                                                   # I-cia/C-corretor/O-oficina
                           0                      ,
                           0                      ,# ofnnumdig
                           l_data                 ,
                           l_data                 ,
                           "N"                    ,# vstretflg
                           g_issk.funmat          ,
                           l_data                 ,
                           ws.hora                ,
                           ""                     ,# sinvstorgnum
                           ""                     ,# sinvstorgano
                           "N"                    ,
                           g_documento.prporg     ,
                           g_documento.prpnumdig  ,
                           g_issk.empcod          ,
                           g_issk.usrtip          )
   if sqlca.sqlcode  <>  0  then
      let ws.msg = "CTS19M06 - Erro ao gravar  DATMVSTSIN : ",
                    ws.sinvstnum," / ",ws.sinvstano, l_data, sqlca.sqlcode
      call cts19m06_grava_erro(ws.sinvstano, ws.sinvstnum, ws.msg)
   ## rollback work
      let ws.ok = 0
      return ws.ok,
          ws.sinvstnum,
          ws.sinvstano
   end if
   ## commit work
   return ws.ok,
          ws.sinvstnum,
          ws.sinvstano

end function

#-----------------------------------------------------------#
function cts19m06_grava_erro(l_sinvstano, l_sinvstnum, l_msg)
#-----------------------------------------------------------#

  define l_seqerr     dec(2,0),
         l_sinvstano  like datmvstsin.sinvstano,
         l_sinvstnum  like datmvstsin.sinvstnum,
         l_msg        char(80)

  define l_data    date,
         l_hora2   datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_seqerr  =  null
        let     l_data  =  null
        let     l_hora2  =  null

  let l_seqerr = 0

  open c_cts19m06_001 using l_sinvstano, l_sinvstnum
  whenever error continue
  fetch c_cts19m06_001 into l_seqerr

  if l_seqerr is null then
     let l_seqerr = 0
  end if

  let l_seqerr = l_seqerr + 1

  call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
  execute p_cts19m06_002 using l_sinvstano,
                             l_sinvstnum,
                             l_msg,
                             l_data,
                             g_issk.funmat,
                             g_issk.empcod,
                             l_seqerr

  if sqlca.sqlcode <> 0 then
     let l_msg = "Problema na gravacao da tabela de erros, erro = ", sqlca.sqlcode
  end if

end function

#--------------------------------------------------------------
 function cts19m06_fax_loja_ant(param)
#--------------------------------------------------------------

 define param  record
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano,
     lignum     like datmligacao.lignum
 end record

 define out record
     lignum           dec (10,0),
     ligdat           date      ,
     lighorinc        datetime hour to minute,
     c24solnom        char(15),
     succod           smallint, #dec (2,0), Projeto succod
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
     drtfrlvlr        integer,
     esqfrlvlr        integer,
     esqmlhfrlvlr     integer,
     drtmlhfrlvlr     integer,
     drtnblfrlvlr     integer,
     esqnblfrlvlr     integer,
     esqpscvlr        integer,
     drtpscvlr        integer,
     drtlntvlr        integer,
     esqlntvlr        integer
 end record

 define l_cts19m07    record
     empresa          char (10),
     enviar           char (01),
     envdes           char (10),
     dddcod           like datmreclam.dddcod,
     faxnum           char (09)             ,
     email            like adikvdrrpremp.maicod
 end record

 define ls           record
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
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.lclbrrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclcttnom        like datmlcl.lclcttnom,
    c24astcod        like datmligacao.c24astcod,
    comando          char (2000),
    tit              char (300)
 end record

 define ls_pipe      char (80)
 define ls_fax       char (03)
 define ls_laudo     char (60)
 
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

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let ls_pipe  =  null
 let ls_fax  =  null
 let ls_laudo  =  null
 let mr_laudo  = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  out.*  to  null

        initialize  l_cts19m07.*  to  null

        initialize  ls.*  to  null

 initialize ls_pipe  to  null
 initialize ls_fax   to  null
 initialize ls_laudo to  null

 initialize  out.*  to  null

 initialize  l_cts19m07.*  to  null

 initialize  ls.*  to  null

 ###let int_flag   =  false
 let ls.envflg  =  true

 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 declare c_cts19m06_008 cursor for
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
           ,esqrtravrvlr    ,dirrtravrvlr,
            drtfrlvlr,
            esqfrlvlr,
            esqmlhfrlvlr,
            drtmlhfrlvlr,
            drtnblfrlvlr,
            esqnblfrlvlr,
            esqpscvlr,
            drtpscvlr,
            drtlntvlr,
            esqlntvlr
       from datmsrvext1
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano
        and lignum    = param.lignum

 foreach c_cts19m06_008 into out.lignum          ,out.ligdat          ,out.lighorinc
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
                      ,out.dirrtravrvlr,
                       out.drtfrlvlr,
                       out.esqfrlvlr,
                       out.esqmlhfrlvlr,
                       out.drtmlhfrlvlr,
                       out.drtnblfrlvlr,
                       out.esqnblfrlvlr,
                       out.esqpscvlr,
                       out.drtpscvlr,
                       out.drtlntvlr,
                       out.esqlntvlr

 end foreach

 ## atribuir status de cancelado para emissao do fax para loja alterada

 if out.atdetpcod <> 5 then
    let out.atdetpcod = 5
 end if

 select vdrrprgrpnom
       into ls.nomgrupo
       from adikvdrrprgrp
       where vdrrprgrpcod = out.vdrrprgrpcod   # cod. empresa

 if out.atntip   =   1  then
    let ls.atntip = "REDE     "
 else
    if out.atntip  =  2  then
       let ls.atntip = "FORA DA REDE"
    else
       if out.atntip = 3 then
          let ls.atntip = "AMBOS    "
       end if
    end if
 end if
 select lgdtip,      lgdnom,
        lgdnum,      lclbrrnom, brrnom,
        cidnom,      ufdcod,    lclcttnom
   into ls.lgdtip,   ls.lgdnom,
        ls.lgdnum,   ls.lclbrrnom, ls.brrnom,
        ls.cidnom,   ls.ufdcod, ls.lclcttnom
   from datmlcl
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and c24endtip = 1

 let ls.endereco = ls.lgdtip clipped, " ",
                   ls.lgdnom clipped, " ",
                   ls.lgdnum using "<<<<#"

 call ctx14g00_limpa(ls.endereco,"'") returning ls.endereco
 call ctx14g00_limpa(ls.lclbrrnom,"'") returning ls.lclbrrnom
 call ctx14g00_limpa(out.cornom,"'") returning out.cornom

 select vdrrprgrpnom
       into l_cts19m07.empresa
       from adikvdrrprgrp
       where vdrrprgrpcod = out.vdrrprgrpcod   # cod. empresa

 select dddcod,faxnum,maicod,vdrrprempnom
       into l_cts19m07.dddcod,
            l_cts19m07.faxnum,
            l_cts19m07.email,
            ls.nomeloja
       from adikvdrrpremp
      where vdrrprgrpcod = out.vdrrprgrpcod
       and  vdrrprempcod = out.vdrrprempcod    # cod. da loja

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
 let ls_fax = "VSI"

 let l_cts19m07.enviar = "X"
 let l_cts19m07.envdes = "FAX"

 initialize  ls_pipe, ls.imp_ok, ls.impnom to null

 #if g_hostname = "u07"  then
 #   if g_issk.funmat <> 7339    and    # Henrique
 #      g_issk.funmat <> 601566  and    # Ruiz
 #      g_issk.funmat <> 603399  and    # Alberto
 #      g_issk.funmat <> 5048   then    # Arnaldo
 #      error " Fax so' pode ser enviado no ambiente de producao !!!"
 #   end if
 #end if

 if not int_flag  then

    # Começo da Alteracao de envio de fax e e-mail / Roberto
    let ls_laudo = "Laudo_Vidros.txt"

    if l_cts19m07.email is null then
       let l_cts19m07.enviar = "F"
    end if

    if l_cts19m07.enviar  =  "F"  then
       call cts10g01_enviofax(param.atdsrvnum,param.atdsrvano,
                              param.lignum,"VD", g_issk.funmat)
                    returning ls.envflg, ls.faxch1, ls.faxch2
    end if

    let mr_laudo = f_path('ONLTEL', 'RELATO')

    if mr_laudo is null or
       mr_laudo = ' ' then
       let mr_laudo = './'
    end if

    let ls_laudo = mr_laudo clipped, ls_laudo clipped

    if ls.envflg  =  true  then

       call cts19m06_busca_franq(d_cts19m06.vclcoddig,
                                 d_cts19m06.vclanomdl,
                                 out.clscod)

            returning mr_vlrfrq76.frqvlrfarois

        #RightFax - Inicio
        start report  rep_reparo1  to  ls_laudo
        let lr_param.service          = 'cts19m06.4gl'
        let lr_param.sErviceType      = 'GENERATOR'
        let lr_param.typeOfConnection = 'xml'
        let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
        let lr_param.jasperFileName   = 'cts_reparo.jasper'
        let l_hora                    =  current
        let lr_param.outFileName      = 'reparo'
        let lr_param.outFileType      = 'pdf'
        let lr_param.recordPath       = '/report/data/file/cts_reparo'
        let lr_param.aplicacao        = 'cts19m06.4gl'
        let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
        let lr_param.generatorTIFF    = false
        let l_nomexml                 = 'cts19m06'
        call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
            returning l_docHandle
        #RightFax - Fim

#       start report  rep_reparo2  to  ls_laudo

       #RightFax - Inicio
       output to report rep_reparo1 (l_cts19m07.enviar,
                                     l_cts19m07.dddcod,
                                     l_cts19m07.faxnum,
                                     ls.faxch1,
                                     ls.faxch2,
                                     ls.nomgrupo,
                                     ls.nomeloja,
                                     ls.atntip  ,
                                     ls.endereco,
                                     ls.brrnom,
                                     ls.lclbrrnom,
                                     ls.cidnom,
                                     ls.ufdcod,
                                     ls.lclcttnom,
                                     out.*,
                                     mr_vlrfrq76.frqvlrfarois,
                                     m_sin.sinvstnum,
                                     m_sin.sinvstano,
                                     m_sin.sinano, m_sin.sinnum)

       call cts19m07_reparo1(l_cts19m07.enviar,
                             l_cts19m07.dddcod,
                             l_cts19m07.faxnum,
                             ls.faxch1,
                             ls.faxch2,
                             ls.nomgrupo,
                             ls.nomeloja,
                             ls.atntip  ,
                             ls.endereco,
                             ls.brrnom,
                             ls.lclbrrnom,
                             ls.cidnom,
                             ls.ufdcod,
                             ls.lclcttnom,
                             out.*,
                             mr_vlrfrq76.frqvlrfarois,
                             m_sin.sinvstnum,
                             m_sin.sinvstano,
                             m_sin.sinano,
                             m_sin.sinnum,
                             l_docHandle)

       #RightFax - Fim

       finish report rep_reparo1
#       finish report rep_reparo2  # gera laudo para email do sinistro.vidros


    if l_cts19m07.enviar  =  "F"  then
       if ls_fax = "GSF"  then
          if g_outFigrc012.Is_Teste then #ambnovo
             let ls.impnom = "tstclfax"
          else
             let ls.impnom = "ptsocfax"
          end if
          let ls.comando = "lp -sd ", ls.impnom clipped, " ", ls_laudo clipped
       else
          #RightFax - Inicio
          #call cts02g01_fax(l_cts19m07.dddcod, l_cts19m07.faxnum)
          #       returning ls.faxtxt
          #let ls.comando = "cat ",
          #              ls_laudo clipped,
          #              "|",
          #              "vfxCTVD ", ls.faxtxt  clipped, " ", ascii 34,
          #              ls.nomgrupo            clipped, ascii 34,  " ",
          #              ls.faxch1              using "&&&&&&&&&&", " ",
          #              ls.faxch2              using "&&&&&&&&&&"
          let lr_fax.ddd           = l_cts19m07.dddcod
          let lr_fax.telefone      = l_cts19m07.faxnum
          let lr_fax.destinatario  = ''
          let lr_fax.notas         = ''
          let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName clipped, '.pdf'
          let lr_fax.sistema       = '237jhg'
          let lr_fax.geratif       = false

          call cty35g00_envia_fax(l_docHandle,lr_fax.*)
          returning lr_param_out.codigo, lr_param_out.mensagem

          if lr_param_out.codigo = 0 then
             display "Fax enviado com sucesso"
          end if
          #RightFax - Fim
       end if
   else
      if l_cts19m07.enviar  =  "I" then
         let ls.comando = "lp -sd ", ls.impnom clipped, " ", ls_laudo clipped
      end if
   end if
  # Fim da Alteracao de envio de fax e e-mail / Roberto

    if l_cts19m07.email is not null then
       let ls.tit     = "LAUDO_VIDROS_",out.atdsrvnum using "&&&&&&&"
       #PSI-2013-23297 - Inicio
       let l_mail.de = "ct24hs.email@portoseguro.com.br"
       #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
       let l_mail.para = l_cts19m07.email
       let l_mail.cc = ""
       let l_mail.cco = ""
       let l_mail.assunto = ls.tit
       let l_mail.mensagem = ""
       let l_mail.id_remetente = "CT24H"
       let l_mail.tipo = "text"

       call figrc009_attach_file(ls_laudo)

       call figrc009_mail_send1 (l_mail.*)
        returning l_coderro,msg_erro
       #PSI-2013-23297 - Fim
    end if

    run ls.comando
    let ls.comando = "rm ", ls_laudo
    run ls.comando


    end if
 end if

 let int_flag = false

end function  ###  cts19m06_fax_loja_ant

#----------------------------------------#
function cts19m06_info_cls76(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         drtfrlvlr    integer,
         esqfrlvlr    integer,
         drtmlhfrlvlr integer,
         esqmlhfrlvlr integer,
         drtnblfrlvlr integer,
         esqnblfrlvlr integer,
         drtpscvlr    integer,
         esqpscvlr    integer,
         drtlntvlr    integer,
         esqlntvlr    integer,
         frqvlrfarois like aacmclscnd.frqvlr
  end record

  define lr_lado      record
         farol        char(08),
         farolmilha   char(08),
         farolneblina char(08),
         pisca        char(08),
         lanterna     char(08)
  end record

  define lr_valor     record
         farol        decimal(15,5),
         farolmilha   decimal(15,5),
         farolneblina decimal(15,5),
         pisca        decimal(15,5),
         lanterna     decimal(15,5)
  end record

  define l_qtd_farois smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_qtd_farois  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_lado.*  to  null

        initialize  lr_valor.*  to  null

  initialize lr_lado, lr_valor to null

  let l_qtd_farois = 0

  # FAROL
  if lr_parametro.drtfrlvlr is not null and
     lr_parametro.esqfrlvlr is not null then
     let lr_lado.farol  = "Ambos"
     let lr_valor.farol = lr_parametro.frqvlrfarois
     let l_qtd_farois = l_qtd_farois + 2
  else
     if lr_parametro.drtfrlvlr is not null then
        let lr_lado.farol = "Direito"
        let lr_valor.farol = lr_parametro.frqvlrfarois
        let l_qtd_farois   = l_qtd_farois + 1
     else
        if lr_parametro.esqfrlvlr is not null then
           let lr_lado.farol = "Esquerdo"
           let lr_valor.farol = lr_parametro.frqvlrfarois
           let l_qtd_farois   = l_qtd_farois + 1
        else
           let lr_valor.farol = null
        end if
     end if
  end if

  # FAROL MILHA
  if lr_parametro.drtmlhfrlvlr is not null and
     lr_parametro.esqmlhfrlvlr is not null then
     let lr_lado.farolmilha  = "Ambos"
     let lr_valor.farolmilha = lr_parametro.frqvlrfarois
     let l_qtd_farois        = l_qtd_farois + 2
  else
     if lr_parametro.drtmlhfrlvlr is not null then
        let lr_lado.farolmilha  = "Direito"
        let lr_valor.farolmilha = lr_parametro.frqvlrfarois
        let l_qtd_farois        = l_qtd_farois + 1
     else
        if lr_parametro.esqmlhfrlvlr is not null then
           let lr_lado.farolmilha = "Esquerdo"
           let lr_valor.farolmilha = lr_parametro.frqvlrfarois
           let l_qtd_farois        = l_qtd_farois + 1
        else
           let lr_valor.farolmilha = null
        end if
     end if
  end if

  # FAROL NEBLINA
  if lr_parametro.drtnblfrlvlr is not null and
     lr_parametro.esqnblfrlvlr is not null then
     let lr_lado.farolneblina  = "Ambos"
     let lr_valor.farolneblina = lr_parametro.frqvlrfarois
     let l_qtd_farois          = l_qtd_farois + 2
  else
     if lr_parametro.drtnblfrlvlr is not null then
        let lr_lado.farolneblina  = "Direito"
        let lr_valor.farolneblina = lr_parametro.frqvlrfarois
        let l_qtd_farois          = l_qtd_farois + 1
     else
        if lr_parametro.esqnblfrlvlr is not null then
           let lr_lado.farolneblina  = "Esquerdo"
           let lr_valor.farolneblina = lr_parametro.frqvlrfarois
           let l_qtd_farois          = l_qtd_farois + 1
        else
           let lr_valor.farolneblina = null
        end if
     end if
  end if

  # PISCA
  if lr_parametro.drtpscvlr is not null and
     lr_parametro.esqpscvlr is not null then
     let lr_lado.pisca  = "Ambos"
     let lr_valor.pisca = lr_parametro.frqvlrfarois
     let l_qtd_farois   = l_qtd_farois + 2
  else
     if lr_parametro.drtpscvlr is not null then
        let lr_lado.pisca  = "Direito"
        let lr_valor.pisca = lr_parametro.frqvlrfarois
        let l_qtd_farois   = l_qtd_farois + 1
     else
        if lr_parametro.esqpscvlr is not null then
           let lr_lado.pisca  = "Esquerdo"
           let lr_valor.pisca = lr_parametro.frqvlrfarois
           let l_qtd_farois   = l_qtd_farois + 1
        else
           let lr_valor.pisca = null
        end if
     end if
  end if

  # LANTERNA
  if lr_parametro.drtlntvlr is not null and
     lr_parametro.esqlntvlr is not null then
     let lr_lado.lanterna  = "Ambas"
     let lr_valor.lanterna = lr_parametro.frqvlrfarois
     let l_qtd_farois      = l_qtd_farois + 2
  else
     if lr_parametro.drtlntvlr is not null then
        let lr_lado.lanterna  = "Direita"
        let lr_valor.lanterna = lr_parametro.frqvlrfarois
        let l_qtd_farois = l_qtd_farois + 1
     else
        if lr_parametro.esqlntvlr is not null then
           let lr_lado.lanterna  = "Esquerda"
           let lr_valor.lanterna = lr_parametro.frqvlrfarois
           let l_qtd_farois = l_qtd_farois + 1
        else
           let lr_valor.lanterna = null
        end if
     end if
  end if

  # DISPLAY DOS LADOS
  display lr_lado.farol          to lfarol
  display lr_lado.farolmilha     to lfarolmi
  display lr_lado.farolneblina   to lfarolne
  display lr_lado.pisca          to lpisca
  display lr_lado.lanterna       to llanterna

  # DISPLAY DOS VALORES
  display lr_valor.farol         to vlrfaro
  display lr_valor.farolmilha    to vlrfami
  display lr_valor.farolneblina  to vlrfane
  display lr_valor.pisca         to vlrpisc
  display lr_valor.lanterna      to vlrlant

  return l_qtd_farois

end function

#--------------------------------------------------------------
 function cts19m06_alt_loja(param)
#--------------------------------------------------------------

 define param  record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano,
        lignum        like datmligacao.lignum,     ## ligacao nova
        lignum_ori    like datmligacao.lignum,     ## ligacao original= assunto
        lignum_alt    like datmligacao.lignum,     ## ligacao da ultima alteracao
        vdrrprempcod  like datmsrvext1.vdrrprempcod,
        vdrrprgrpcod  like datmsrvext1.vdrrprgrpcod,
        atdhorpvt     like datmsrvext1.atdhorpvt,
        atddatprg     like datmsrvext1.atddatprg,
        atdhorprg     like datmsrvext1.atdhorprg
 end record

 define l_srrcoddig  like datmsrvext1.vdrrprempcod,
        l_pstcoddig  like datmsrvext1.vdrrprgrpcod
 define l_alt_loja_datmsrvext1 record like datmsrvext1.*

 define l_erro  integer

 define l_sin     record
        sinvstnum  like datrligsinvst.sinvstnum,
        sinvstano  like datrligsinvst.sinvstano,
        msg        char(80)
 end record

 define   l_data      date,
          l_hora2     datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_srrcoddig  =  null
        let     l_pstcoddig  =  null
        let     l_erro  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  l_alt_loja_datmsrvext1.*  to  null

        initialize  l_sin.*  to  null


 select  *
 into    l_alt_loja_datmsrvext1.*    # salva dados ligacao anterior
 from    datmsrvext1
 where   atdsrvnum = param.atdsrvnum
 and     atdsrvano = param.atdsrvano
 and     lignum    = param.lignum_alt

 ## Implementar alteracao de Local de Ocorrencia
 let l_alt_loja_datmsrvext1.ocrendlgd = w_cts19m06.ocrendlgd
 let l_alt_loja_datmsrvext1.ocrendbrr = w_cts19m06.ocrendbrr
 let l_alt_loja_datmsrvext1.ocrendcid = w_cts19m06.ocrendcid
 let l_alt_loja_datmsrvext1.ocrufdcod = w_cts19m06.ocrufdcod
 let l_alt_loja_datmsrvext1.ocrcttnom = w_cts19m06.ocrcttnom

 let l_srrcoddig  = l_alt_loja_datmsrvext1.vdrrprempcod
 let l_pstcoddig  = l_alt_loja_datmsrvext1.vdrrprgrpcod

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let l_alt_loja_datmsrvext1.lignum    = param.lignum
 let l_alt_loja_datmsrvext1.ligdat    = l_data
 let l_alt_loja_datmsrvext1.lighorinc = l_hora2
 let l_alt_loja_datmsrvext1.atdetpcod = 4  # gera nova ligacao c/status canc.
 let l_alt_loja_datmsrvext1.atmstt    = 0
 let l_alt_loja_datmsrvext1.adcmsgtxt = "ALTERACAO "

 whenever error continue
 update datmsrvext1
 set    atdetpcod   = 5     # cancela ligacao anterior
 where  atdsrvnum   = param.atdsrvnum
 and    atdsrvano   = param.atdsrvano
 and    lignum      = param.lignum_alt

 ## atualizacao da loja e horario do atendimento
 let l_alt_loja_datmsrvext1.vdrrprgrpcod   = param.vdrrprgrpcod
 let l_alt_loja_datmsrvext1.vdrrprempcod   = param.vdrrprempcod

 let l_alt_loja_datmsrvext1.atdhorpvt  = param.atdhorpvt
 let l_alt_loja_datmsrvext1.atddatprg  = param.atddatprg
 let l_alt_loja_datmsrvext1.atdhorprg  = param.atdhorprg

 insert into datmsrvext1
 values (l_alt_loja_datmsrvext1.*)

 update datmservico
 set    srrcoddig   = param.vdrrprempcod,
        atdprscod   = param.vdrrprgrpcod,
        atdhorpvt   = param.atdhorpvt,
        atddatprg   = param.atddatprg,
        atdhorprg   = param.atdhorprg
 where  atdsrvnum   = param.atdsrvnum
 and    atdsrvano   = param.atdsrvano

 call cts10g04_insere_etapa ( param.atdsrvnum    ,
                              param.atdsrvano    ,
                              5                  ,
                              l_pstcoddig        ,
                              ""                 ,
                              ""                 ,
                              l_srrcoddig )
 returning l_erro
 if  l_erro  <>  0  then
     error " Erro (", l_erro, ") na gravacao da",
           " etapa de acompanhamento (5). AVISE A INFORMATICA!"
     rollback work
 end if
 call cts10g04_insere_etapa ( param.atdsrvnum    ,
                              param.atdsrvano    ,
                              4                  ,
                              param.vdrrprgrpcod ,
                              "",
                              "",
                              param.vdrrprempcod )
 returning l_erro
 if  l_erro  <>  0  then
     error " Erro (", l_erro, ") na gravacao da",
           " etapa de acompanhamento (4). AVISE A INFORMATICA!"
     rollback work
 end if

 call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)

 ## Busca Ligacao Original do Servico B14
 let param.lignum_ori = cts20g00_servico(param.atdsrvnum,
                                         param.atdsrvano)

 ## Envia fax, e-mail para loja anterior cancelando o servico -> etapa 5
 ## Aqui deu problema


 ## Seleciona o nº sinistro
 select sinvstnum, sinvstano
 into   m_sin.sinvstnum, m_sin.sinvstano
 from   datrligsinvst
 where  lignum = param.lignum_ori

 call figrc072_setTratarIsolamento() -- > psi 223689

 call ssata666(m_sin.sinvstnum,
               m_sin.sinvstano,
               param.lignum,
               param.atdsrvnum,
               param.atdsrvano,
               "A")
 returning m_sin.ramcod, m_sin.sinano, m_sin.sinnum

 if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
    error "Função ssata666 indisponivel no momento ! Avise a Informatica !" sleep 2
    return
 end if        -- > 223689

 call cts19m07 ( param.atdsrvnum,
                 param.atdsrvano,
                 param.lignum,
                 mr_vlrfrq76.frqvlrfarois,
                 m_sin.sinvstnum,
                 m_sin.sinvstano,
                 m_sin.sinano, m_sin.sinnum)

 call cts19m06_fax_loja_ant( param.atdsrvnum,
                             param.atdsrvano,
                             param.lignum_alt )


 let l_sin.msg = "CTS19M06 - Rotina OK : ",
               l_sin.sinvstnum,"/",l_sin.sinvstano, l_data
 call cts19m06_grava_erro(l_sin.sinvstano, l_sin.sinvstnum, l_sin.msg)

end function ## cts19m06_alt_loja

#-----------------------------------------#
function cts19m06_busca_franq(lr_parametro)
#-----------------------------------------#

  define lr_parametro    record
         vclcoddig       like datmservico.vclcoddig,
         vclanomdl       like datmservico.vclanomdl,
         clscod          like datmsrvext1.clscod
  end record

  define l_zero      smallint,
         l_um        smallint,
         l_onze      smallint,
         l_sem_uso   like aacmclscnd.frqvlr,
         l_hoje      date,
         l_vclmrccod like agbkveic.vclmrccod,
         l_vcltipcod like agbkveic.vcltipcod,
         l_ctgtrfcod like agetdecateg.autctgatu,
         l_clcdat like abbmcasco.clcdat,
         l_nulo char(40) ##(01)

  let l_zero      = 0
  let l_um        = 1
  let l_onze      = 11
  let l_hoje      = today
  let l_vclmrccod = null
  let l_sem_uso   = null
  let l_vcltipcod = null
  let l_ctgtrfcod = null
  let l_clcdat = null
  let l_nulo = null

   select autctgatu
   into l_ctgtrfcod
   from agetdecateg
  where vclcoddig = lr_parametro.vclcoddig
    and viginc <= l_hoje
    and vigfnl >= l_hoje

 select vclmrccod, vcltipcod
   into l_vclmrccod,
        l_vcltipcod
   from agbkveic
  where vclcoddig = lr_parametro.vclcoddig

  if g_documento.succod    is not null and
     g_documento.aplnumdig is not null then

     # - Roberto CT 7051656 - Recupera a data de calculo da apolice

        call figrc072_setTratarIsolamento()        --> 223689

        call faemc603_apolice(g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_funapol.dctnumseq  ,
                              g_documento.itmnumdig)
        returning l_clcdat

        if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função faemc603 indisponivel no momento ! Avise a Informatica !" sleep 2
           return mr_vlrfrq76.frqvlrfarois
        end if        -- > 223689


  end if

  if g_documento.succod    is null or
     g_documento.aplnumdig is null or
     lr_parametro.clscod   is null then

     # - Roberto CT 7051656 -  Recupera a data de calculo da Proposta


     call figrc072_setTratarIsolamento()        --> 223689

     call faemc603_proposta(g_documento.prporg
                           ,g_documento.prpnumdig)
     returning l_clcdat

     if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função faemc603 indisponivel no momento ! Avise a Informatica !" sleep 2
           return mr_vlrfrq76.frqvlrfarois
        end if        -- > 223689



  end if

 if (l_clcdat < "01/05/2007")   then --varani

    call apgffger_valor_cfc_cls_novo(lr_parametro.clscod,
                                  l_hoje,
                                  l_um,
                                  l_um,
                                  l_ctgtrfcod,
                                  l_onze,
                                  l_vclmrccod,
                                  l_vcltipcod,
                                  lr_parametro.vclcoddig,
                                  lr_parametro.vclanomdl,
                                  l_zero,
                                  l_zero)

      returning l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,l_sem_uso
               ,mr_vlrfrq76.frqvlrfarois
  else

     call figrc072_setTratarIsolamento()        --> 223689

      ## PSI 239.399 Clausula 77
      if g_vdr_blindado = "S" then
         select clsdes into l_nulo
           from aackcls
          where tabnum =( select max(a.tabnum) from aackcls a
                           where a.ramcod = g_documento.ramcod
                             and a.clscod = lr_parametro.clscod )
            and ramcod = g_documento.ramcod
            and clscod = lr_parametro.clscod
      end if

     call faemc464(g_documento.prporg --varani
                      ,g_documento.prpnumdig
                      ,g_documento.prporg
                      ,g_documento.prpnumdig
                      ,g_documento.succod
                      ,g_documento.aplnumdig
                      ,g_documento.itmnumdig
                      ,g_funapol.dctnumseq
                      ,w_cts19m06.clscod
                      ,l_nulo
                      ,ml_abrir ) ##'N')
        returning  l_sem_uso
                  ,l_sem_uso
                  ,mr_vlrfrq76.frqvlrfarois

          if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função faemc464 indisponivel no momento ! Avise a Informatica !" sleep 2
             return mr_vlrfrq76.frqvlrfarois
          end if    --> 223689

  end if
 return mr_vlrfrq76.frqvlrfarois

end function
#-----------------------------------------#
function cts19m06_busca_lig_ori(l_lignum_ori)
#-----------------------------------------#

   define l_lignum_ori  like datmligacao.lignum
   define l_sinvstnum   like ssamsin.sinvstnum
   define l_sinvstano   like ssamsin.sinvstano

   initialize  l_sinvstnum to null
   initialize  l_sinvstano to null


   if m_cts19m06_prep is null or
      m_cts19m06_prep <> true then
      call cts19m06_prepare()
   end if

     open c_cts19m06_007 using  l_lignum_ori
     fetch c_cts19m06_007 into l_sinvstnum,l_sinvstano
     close c_cts19m06_007

      return l_sinvstnum,l_sinvstano
end function
