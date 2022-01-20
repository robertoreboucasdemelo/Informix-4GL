#############################################################################
# Nome do Modulo: CTS05M00                                            Pedro #
#                                                                   Marcelo #
# Aviso de Sinistro ROUBO/FURTO Total                              Jan/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   #
#---------------------------------------------------------------------------#
# 18/11/1998  PSI 6467-0   Gilberto     Gravar codigo do veiculo atendido.  #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 24/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 13/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03#
#                                       e padroniza gravacao do historico.  #
#---------------------------------------------------------------------------#
# 24/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do   #
#                                       historico.(Inclusao)                #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 04/02/2000  PSI 10206-7  Wagner       Incluir no INSERT datmservico o     #
#                                       nivel prioridade atend. = 2-NORMAL. #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/04/2000  PSI 1042408  Wagner       Inclusao input campo regiao e grava-#
#                                       cao da tabela DATMAVSSIN.           #
#---------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO      #
#                                       via funcao                          #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 108650   Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da    #
#                                       oficina destino para laudos         #
#---------------------------------------------------------------------------#
# 16/01/2001  PSI 120375   Raji         Critica para data de sinistro infe- #
#                                       rior a data do laudo.               #
#---------------------------------------------------------------------------#
# 14/02/2001  PSI 125547   Raji         Atalho p/ visualizacao Pto Referecia#
#---------------------------------------------------------------------------#
# 16/02/2001  Psi 11254-2  Ruiz         Consulta o Condutor do Veiculo      #
#---------------------------------------------------------------------------#
# 03/04/2001               Raji         Chamada a funcao do disp. Grilo     #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Renato Zattar                    OSF : 4774             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 16/08/2002       #
#  Objetivo       : Alterar programa para comportar Endereco Eletronico     #
#---------------------------------------------------------------------------#
# 10/10/2002  PSI 16258-2  Wagner       Incluir acesso a funcao informativo #
#                                       convenio ctx17g00.                  #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 23/05/2003  Aguinaldo Costa     PSI.174050    Verifica contato de TRACKER #
#############################################################################
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Inibir funcao ctx17g00.              #
#                            OSF26077                                       #
# ------------------------------------------------------------------------- #
#############################################################################
#= Raphael  05/12/2003 - Alteracao em telefones da Central                  #
#= OSF 29386                                                                #
#===========================================================================#
# 25/10/2004  Meta, James    PSI188514 Acrescentar tipo de solicitacao = 8  #
#---------------------------------------------------------------------------#
# 14/03/2005  Helio (Meta)   AS 69205  Criar funcao cts05m00_msg_siniven    #
#---------------------------------------------------------------------------#
# 29/03/2005  Nicolau        AS 69205 Envio de e-mail sinivem para          #
#                                     recuperados                           #
#---------------------------------------------------------------------------#
# 19/05/2005 Robson,Meta   PSI191108  Implementacao do Codigo da Via        #
#                                     (emeviacod)                           #
#---------------------------------------------------------------------------#
# 13/09/2005  Priscila     AS87602       Resolucao para DAF IV              #
#---------------------------------------------------------------------------#
# 22/12/2005  Julianna,Meta PSI195693    Inclusao da chamada da funcao      #
#                                        cts14m00_monta_xml                 #
#---------------------------------------------------------------------------#
# 13/02/2006  Miguel/Alberto  PSI 198080 Resolucao para DAF V               #
#---------------------------------------------------------------------------#
# 07/03/2006  Priscila     Zeladoria    Buscar data e hora no banco de dados#
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 20/11/2008 Amilton, Meta Psi230669 incluir relacionamento de ligacao      #
#                                         com atedimento                    #
#---------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada#
#                                          por ctd25g00                     #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                 Projeto sucursal smallint              #
#---------------------------------------------------------------------------#
# 27/09/2012  Raul Biztalking         Retirar empresa 1 fixa p/ funcionario #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################
 globals '/homedsa/projetos/geral/globals/glct.4gl'

 define d_cts05m00    record
    servico           char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (19)                    ,
    vclcoddig         like datmservico.vclcoddig   ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcordes         char (11)                    ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    atddfttxt         like datmservico.atddfttxt   ,
    atdlclflg         like datmservico.atdlclflg   ,
    atddoctxt         like datmservico.atddoctxt   ,
    c24sintip         like datmservicocmp.c24sintip,
    sintipdes         char (05)                    ,
    eqprgides         like ssakeqprgi.eqprgides    ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    c24sinhor         like datmservicocmp.c24sinhor,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atdtxt            char (55)
 end record

 define d_cts05m00a   record
    nome              char (20)
 end record

 define m_cts05m00_prep smallint

 define w_cts05m00    record
    vicsnh            like datmservicocmp.vicsnh   ,
    vclcorcod         like datmservico.vclcorcod   ,
    vclchsinc         like abbmveic.vclchsinc      ,
    vclchsfnl         like abbmveic.vclchsfnl      ,
    ligcvntip         like datmligacao.ligcvntip   ,
    bocflg            like datmservicocmp.bocflg   ,
    sinntzcod         like datmavssin.sinntzcod    ,
    eqprgicod         like datmavssin.eqprgicod    ,
    data              char (10)                    ,
    hora              char (05)                    ,
    ano2              char (02)                    ,
    ano4              char (04)                    ,
    cdtnom            like aeikcdt.cdtnom,   ## Ruiz
    atdfnlflg         like datmservico.atdfnlflg
 end record

 define a_cts05m00    array[1] of record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig       ,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record

 define arr_aux       smallint

 define k_apolice     record
    succod            like datrligapol.succod   ,
    ramcod            like datrligapol.ramcod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    edsnumref         like datrligapol.edsnumref
 end record

 define s_cts05m00    record
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    vclcoddig         like datmservico.vclcoddig   ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    atddfttxt         like datmservico.atddfttxt   ,
    atdlclflg         like datmservico.atdlclflg   ,
    atddoctxt         like datmservico.atddoctxt   ,
    c24sintip         like datmservicocmp.c24sintip,
    lgdtxt            char (65)                    ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    endzon            like datmlcl.endzon          ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    c24sinhor         like datmservicocmp.c24sinhor,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi
 end record

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 define vm_cts09g01   record
    dddcod            like gcakfilial.dddcod
   ,factxt            like gcakfilial.factxt
   ,maides            like gcakfilial.maides
 end record

 define wg_smata030   record
    segnom            like gsakseg.segnom,
    segdddcod         like gsakend.dddcod,
    segtelnum         like gsakend.teltxt,
    endlgd            like gsakend.endlgd,
    endnum            like gsakend.endnum,
    endbrr            like gsakend.endbrr,
    endcid            like gsakend.endcid,
    endufd            like gsakend.endufd,
    cgccpfnum         like gsakseg.cgccpfnum,
    cgcord            like gsakseg.cgcord,
    cgccpfdig         like gsakseg.cgccpfdig,
    vclchsnum         char (20),
    vclanofbc         like abbmveic.vclanofbc,
    vigfnl            like abbmdoc.vigfnl,
    viginc            like abbmdoc.viginc,
    sinbocflg         char(01),
    nscdat            like gsakseg.nscdat,
    flgcondutor       char(1),
    ano               char(2)
 end record

 define aux_today     char (10),
        aux_hora      char (05),
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        ws_cgccpfnum  like aeikcdt.cgccpfnum,
        ws_cgccpfdig  like aeikcdt.cgccpfdig

 define avsrcprd smallint
 define m_ituran, m_tracker, m_daf4 smallint, m_daf5 smallint
 define m_atddat      like datmservico.atddat,
        m_atdhor      like datmservico.atdhor

 define m_acesso_ind smallint
 define m_atdsrvorg like datmservico.atdsrvorg

#-------------------------#
function cts05m00_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select cpodes ",
                " from iddkdominio ",
               " where cponom = 'daf5' "

  prepare p_cts05m00_001 from l_sql
  declare c_cts05m00_001 cursor for p_cts05m00_001

  let l_sql = " insert into igbmparam ",
                         " (relsgl, ",
                          " relpamseq, ",
                          " relpamtip, ",
                          " relpamtxt) ",
                   " values(?,?,?,?) "

  prepare p_cts05m00_002 from l_sql

  let l_sql = " select max(relpamseq) ",
                " from igbmparam ",
               " where relsgl = ? "

  prepare p_cts05m00_003 from l_sql
  declare c_cts05m00_002 cursor for p_cts05m00_003

  let m_cts05m00_prep = true

end function

#------------------------------------#
function cts05m00_buscaRemetenteDaf5()
#------------------------------------#

  #-------------------------------------------------------------
  # FUNCAO PARA BUSCAR OS REMETENTES QUE RECEBEM E-MAIL DO DAF 5
  #-------------------------------------------------------------

  define l_cpodes      like iddkdominio.cpodes,
         l_remetentes  char(1000)

  if m_cts05m00_prep is null or
     m_cts05m00_prep <> true then
     call cts05m00_prepare()
  end if

  let l_cpodes     = null
  let l_remetentes = null

  #-------------------------------------------------------
  # BUSCA OS DESTINATARIOS DA iddkdominio COM CHAVE "daf5"
  #-------------------------------------------------------
  open c_cts05m00_001
  foreach c_cts05m00_001 into l_cpodes

     if l_remetentes is null then
        let l_remetentes = l_cpodes
     else
        let l_remetentes = l_remetentes clipped, ",", l_cpodes
     end if

  end foreach
  close c_cts05m00_001

  return l_remetentes

end function

#-----------------------------------------------------------
 function cts05m00()
#-----------------------------------------------------------

 define ws            record
    confirma          char (01),
    mensagem          char (40),
    grvflg            smallint ,
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    segnumdig         like gsakseg.segnumdig,
    ligdat            like datmservhist.ligdat,
    lighorinc         like datmservhist.lighorinc,
    c24txtseq         like datmservhist.c24txtseq,
    c24srvdsc         like datmservhist.c24srvdsc,
    historico         like dafmintavs.sinres
 end record

 define l_ret         smallint
 define l_data_banco  date,
        l_hora2       datetime hour to minute


 if m_cts05m00_prep is null or
    m_cts05m00_prep <> true then
    call cts05m00_prepare()
 end if

 let l_ret = 0

#--------------------------------#


        initialize  ws.*  to  null

  let m_ituran = 0
  let m_tracker = 0
  let m_daf4 = 0
  let m_daf5 = 0
  let m_atddat = null
  let m_atdhor = null

  let g_documento.atdsrvorg = 11
#--------------------------------#

 initialize d_cts05m00.*    to null
 initialize w_cts05m00.*    to null
 initialize k_apolice.*     to null
 initialize ws.*            to null
 initialize vm_cts09g01.*   to null

 initialize a_cts05m00      to null

 call cts40g03_data_hora_banco(2)
      returning l_data_banco, l_hora2
 let w_cts05m00.data = l_data_banco
 let w_cts05m00.hora = l_hora2
 let w_cts05m00.ano2 = w_cts05m00.data[9,10]
 let w_cts05m00.ano4 = w_cts05m00.data[7,10]
 let aux_today       = l_data_banco
 let aux_hora        = l_hora2

 let m_atddat = w_cts05m00.data
 let m_atdhor = w_cts05m00.hora

 let int_flag = false

 open window cts05m00 at 04,02 with form "cts05m00"
                          attribute (form line 1)

 -------------------[ Dados para funcao do Sinistro ]-------------------
     --------------------[ dados do segurado ]--------------------------
       select segnumdig
         into ws.segnumdig
         from abbmdoc
        where succod    = g_documento.succod    and
              aplnumdig = g_documento.aplnumdig and
              itmnumdig = g_documento.itmnumdig and
              dctnumseq = g_funapol.dctnumseq

       select segnom,cgccpfnum,
              cgcord,cgccpfdig,nscdat
         into wg_smata030.segnom   ,
              wg_smata030.cgccpfnum,
              wg_smata030.cgcord   ,
              wg_smata030.cgccpfdig,
              wg_smata030.nscdat
         from gsakseg
        where segnumdig  =  ws.segnumdig

       select dddcod, teltxt, endlgd,
              endbrr, endcid, endufd
         into wg_smata030.segdddcod,
              wg_smata030.segtelnum,
              wg_smata030.endlgd,
              wg_smata030.endbrr,
              wg_smata030.endcid,
              wg_smata030.endufd
         from gsakend
        where segnumdig  =  ws.segnumdig    and
              endfld     =  "1"
     ---------------------[ dados do veiculo ]------------------------
       select vclanofbc,
              vclchsinc,
              vclchsfnl
         into wg_smata030.vclanofbc,
              ws.vclchsinc,
              ws.vclchsfnl
         from abbmveic
        where succod    = g_documento.succod      and
              aplnumdig = g_documento.aplnumdig   and
              itmnumdig = g_documento.itmnumdig   and
              dctnumseq = (select max(dctnumseq)
                             from abbmveic
                            where succod    = g_documento.succod      and
                                  aplnumdig = g_documento.aplnumdig   and
                                  itmnumdig = g_documento.itmnumdig)
       let wg_smata030.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl clipped
     -------------------[ vigencia da apolice ]------------------------
       select viginc, vigfnl
         into wg_smata030.viginc   ,
              wg_smata030.vigfnl
         from abamapol
        where succod    = g_documento.succod    and
              aplnumdig = g_documento.aplnumdig
 ------------------------------------------------------------

 let w_cts05m00.ligcvntip = g_documento.ligcvntip

 select cpodes
   into d_cts05m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts05m00()

    display by name d_cts05m00.*
    display by name d_cts05m00.c24solnom attribute (reverse)
    display by name d_cts05m00.cvnnom    attribute (reverse)
    display by name a_cts05m00[1].lgdtxt,
                    a_cts05m00[1].lclbrrnom,
                    a_cts05m00[1].cidnom,
                    a_cts05m00[1].ufdcod,
                    a_cts05m00[1].lclrefptotxt,
                    a_cts05m00[1].endzon,
                    a_cts05m00[1].endcmp

#### RUIZ
 -------------------[ Dados para funcao do Sinistro ]-------------------
     --------------------[ dados do segurado ]--------------------------
       select segnumdig
         into ws.segnumdig
         from abbmdoc
        where succod    = g_documento.succod    and
              aplnumdig = g_documento.aplnumdig and
              itmnumdig = g_documento.itmnumdig and
              dctnumseq = g_funapol.dctnumseq

       select segnom,cgccpfnum,
              cgcord,cgccpfdig,nscdat
         into wg_smata030.segnom   ,
              wg_smata030.cgccpfnum,
              wg_smata030.cgcord   ,
              wg_smata030.cgccpfdig,
              wg_smata030.nscdat
         from gsakseg
        where segnumdig  =  ws.segnumdig

       select dddcod, teltxt, endlgd,
              endbrr, endcid, endufd
         into wg_smata030.segdddcod,
              wg_smata030.segtelnum,
              wg_smata030.endlgd,
              wg_smata030.endbrr,
              wg_smata030.endcid,
              wg_smata030.endufd
         from gsakend
        where segnumdig  =  ws.segnumdig    and
              endfld     =  "1"
     ---------------------[ dados do veiculo ]------------------------
       select vclanofbc,
              vclchsinc,
              vclchsfnl
         into wg_smata030.vclanofbc,
              ws.vclchsinc,
              ws.vclchsfnl
         from abbmveic
        where succod    = g_documento.succod      and
              aplnumdig = g_documento.aplnumdig   and
              itmnumdig = g_documento.itmnumdig   and
              dctnumseq = (select max(dctnumseq)
                             from abbmveic
                            where succod    = g_documento.succod      and
                                  aplnumdig = g_documento.aplnumdig   and
                                  itmnumdig = g_documento.itmnumdig)
       let wg_smata030.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl clipped

       let w_cts05m00.vclchsfnl = ws.vclchsfnl

     -------------------[ vigencia da apolice ]------------------------
       select viginc, vigfnl
         into wg_smata030.viginc   ,
              wg_smata030.vigfnl
         from abamapol
        where succod    = g_documento.succod    and
              aplnumdig = g_documento.aplnumdig
 ------------------------------------------------------------

#-----------------------------------------------------------
# Salva os dados em caso de eventual alteracao
#-----------------------------------------------------------

    let s_cts05m00.c24solnom    = d_cts05m00.c24solnom
    let s_cts05m00.nom          = d_cts05m00.nom
    let s_cts05m00.corsus       = d_cts05m00.corsus
    let s_cts05m00.cornom       = d_cts05m00.cornom
    let s_cts05m00.vclcoddig    = d_cts05m00.vclcoddig
    let s_cts05m00.vcldes       = d_cts05m00.vcldes
    let s_cts05m00.vclanomdl    = d_cts05m00.vclanomdl
    let s_cts05m00.vcllicnum    = d_cts05m00.vcllicnum
    let s_cts05m00.atdrsdflg    = d_cts05m00.atdrsdflg
    let s_cts05m00.atddfttxt    = d_cts05m00.atddfttxt
    let s_cts05m00.atdlclflg    = d_cts05m00.atdlclflg
    let s_cts05m00.atddoctxt    = d_cts05m00.atddoctxt
    let s_cts05m00.c24sintip    = d_cts05m00.c24sintip
    let s_cts05m00.lgdtxt       = a_cts05m00[1].lgdtxt
    let s_cts05m00.lclbrrnom    = a_cts05m00[1].lclbrrnom
    let s_cts05m00.cidnom       = a_cts05m00[1].cidnom
    let s_cts05m00.ufdcod       = a_cts05m00[1].ufdcod
    let s_cts05m00.lclrefptotxt = a_cts05m00[1].lclrefptotxt
    let s_cts05m00.endzon       = a_cts05m00[1].endzon
    let s_cts05m00.sindat       = d_cts05m00.sindat
    let s_cts05m00.sinhor       = d_cts05m00.sinhor
    let s_cts05m00.c24sinhor    = d_cts05m00.c24sinhor
    let s_cts05m00.bocnum       = d_cts05m00.bocnum
    let s_cts05m00.bocemi     =  d_cts05m00.bocemi

    let wg_smata030.ano = g_documento.atdsrvano using "&&"
    call modifica_cts05m00() returning ws.grvflg
    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today  ,aux_hora)
       let g_rec_his = true
    end if
    if ws.grvflg = false then
       initialize g_documento.acao  to null
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then
       let k_apolice.succod    = g_documento.succod
       let k_apolice.ramcod    = g_documento.ramcod
       let k_apolice.aplnumdig = g_documento.aplnumdig
       let k_apolice.itmnumdig = g_documento.itmnumdig
       let k_apolice.edsnumref = g_documento.edsnumref

       let d_cts05m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                        " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts05m00.nom      ,
                      d_cts05m00.corsus   ,
                      d_cts05m00.cornom   ,
                      d_cts05m00.cvnnom   ,
                      d_cts05m00.vclcoddig,
                      d_cts05m00.vcldes   ,
                      d_cts05m00.vclanomdl,
                      d_cts05m00.vcllicnum,
                      w_cts05m00.vclchsinc,
                      w_cts05m00.vclchsfnl,
                      d_cts05m00.vclcordes
    end if

    let d_cts05m00.c24solnom = g_documento.solnom

    display by name d_cts05m00.*
    display by name d_cts05m00.c24solnom attribute (reverse)
    display by name d_cts05m00.cvnnom    attribute (reverse)

    call cts03g00 (2, g_documento.ramcod    ,
                      g_documento.succod    ,
                      g_documento.aplnumdig ,
                      g_documento.itmnumdig ,
                      d_cts05m00.vcllicnum  ,
                      g_documento.atdsrvnum ,
                      g_documento.atdsrvano )

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call inclui_cts05m00() returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(aux_atdsrvnum, aux_atdsrvano, g_issk.funmat,
                     w_cts05m00.data, w_cts05m00.hora)

       #-----------------------------------------------
       # Envia msg convenio/assunto se houver
       #-----------------------------------------------
# PSI 175552 - Inicio
#       call ctx17g00_assist(g_documento.ligcvntip,
#                            g_documento.c24astcod,
#                            aux_atdsrvnum        ,
#                            aux_atdsrvano        ,
#                            g_documento.lignum   ,
#                            g_documento.succod   ,
#                            g_documento.ramcod   ,
#                            g_documento.aplnumdig,
#                            g_documento.itmnumdig,
#                            g_documento.prporg   ,
#                            g_documento.prpnumdig,
#                            ws_cgccpfnum         ,
#                            ws_cgccpfdig         )
# PSI 175552 - Final

       -------------[ funcao de interface com sistema daf (inclusao) ]--------
       declare c_cts05m00_003 cursor for
           select ligdat,
                  lighorinc,
                  c24txtseq,
                  c24srvdsc
            from datmservhist
           where atdsrvnum = aux_atdsrvnum and
                 atdsrvano = aux_atdsrvano
           order by ligdat, lighorinc, c24txtseq
       foreach c_cts05m00_003 into ws.ligdat,
                                ws.lighorinc,
                                ws.c24txtseq,
                                ws.c24srvdsc
           let ws.historico = ws.historico clipped," ",ws.c24srvdsc
       end foreach

       call cty13g00("",                    # Fim Integração        excfnl
                     "",                    # Codigo Erro           errcod
                     "",                    # Descrição Erro        errdsc
                     "",                    # Codigo Dispositivo    discoddig
                     a_cts05m00[1].lclltt,  # Latitude              sinlclltt
                     a_cts05m00[1].lcllgt,  # Longitude             sinlcllgt
                     aux_atdsrvnum,         # Número Atendimento    atdsrvnum
                     aux_atdsrvano,         # Ano Atendimento       atdsrvano
                     d_cts05m00.vclcoddig,  # Codigo Veículo        vclcoddig
                     d_cts05m00.vcldes,     # Descricao Veículo     vcldes
                     d_cts05m00.vcllicnum,  # Placa Veículo         vcllicnum
                     g_documento.c24astcod, # Tipo Atendimento      c24astcod
                     wg_smata030.vclchsnum, # Número Chassi         vclchscod
                     wg_smata030.segnom,    # Nome Segurado         segnom
                     d_cts05m00.sindat,     # Data Sisnistro        sindat
                     d_cts05m00.sinhor,     # Data Comunicado       cincmudat
                     w_cts05m00.data,       # Data Cadastro         caddat
                     "",                    # Importancia Segurada  imsvlr
                     ws.historico,          # Resumo do Sinistro    sinres
                     "",                    # Ticket de Entrega     enttck
                     g_documento.succod,    # Codigo Sucursal       succod
                     g_documento.aplnumdig, # Número Apólice        aplnumdig
                     g_documento.itmnumdig, # Item Apólice          itmnumdig
                     g_funapol.dctnumseq,   # Seq Número Docto      dctnumseq
                     g_documento.edsnumref, # Número Endosso        edsnumdig
                     g_documento.prporg,    # Origem Proposta       prporgpcp
                     g_documento.prpnumdig, # Número Proposta       prpnumpcp
                     wg_smata030.cgccpfnum, # Número CGC/CPF        cgccpfnum
                     wg_smata030.cgcord,    # Ordem CGC             cgcord
                     wg_smata030.cgccpfdig, # Dígito CGC/CPF        cgccpfdig
                     d_cts05m00.vclcordes,  # Descrição cor Veículo vclcordsc
                     w_cts05m00.cdtnom,     # Nome Condutor         cdtnom
                     "",                    # Número Tentativas     itgttvnum
                     "cts05m00")            # Programa chamador   ---> Ruiz/Camila

       if d_cts05m00.corsus   is not null then
          # -- OSF 4774 - Fabrica de Software, Katiucia -- #
          if g_documento.c24soltipcod  =  2   or
             g_documento.c24soltipcod  =  8   then
             call cts09g01(d_cts05m00.corsus,"S")
                  returning vm_cts09g01.dddcod
                           ,vm_cts09g01.factxt
                           ,vm_cts09g01.maides
          else
             call cts09g01(d_cts05m00.corsus,"N")
                  returning vm_cts09g01.dddcod
                           ,vm_cts09g01.factxt
                           ,vm_cts09g01.maides
          end if
       end if

       # -- OSF 4774 - Fabrica de Software, Katiucia -- #
       call cts05m02(aux_atdsrvnum
                    ,aux_atdsrvano
                    ,"F"
                    ,"N"
                    ,vm_cts09g01.dddcod
                    ,vm_cts09g01.factxt
                    ,vm_cts09g01.maides)

       call cts05m00_ituran_tracker(aux_atdsrvnum, aux_atdsrvano)

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       update datmservico set c24opemat = null
                        where atdsrvnum = aux_atdsrvnum
                          and atdsrvano = aux_atdsrvano

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                " AVISE A INFORMATICA!"
          prompt "" for char ws.confirma
       else
          call cts00g07_apos_servdesbloqueia(aux_atdsrvnum,aux_atdsrvano)
       end if

       #Envia email para siniven
       if g_documento.lignum is not null then
               let avsrcprd = 0
               let l_ret = cts37m00_msg_siniven(d_cts05m00.vcllicnum
                                               ,d_cts05m00.sindat
                                               ,d_cts05m00.sinhor
                                               ,a_cts05m00[1].cidnom
                                               ,a_cts05m00[1].ufdcod
                                               ,d_cts05m00.vclcordes
                                               ,wg_smata030.vclchsnum
                                               ,""
                                               ,""
                                               ,""
                                               ,w_cts05m00.data
                                               ,w_cts05m00.hora
                                               ,g_documento.succod
                                               ,g_documento.aplnumdig
                                               ,g_documento.itmnumdig
                                               ,g_documento.ramcod
                                               ,avsrcprd
                                               ,g_documento.lignum)
               if l_ret <> 0 then
                  error "Problemas no envio de email siniven"
               end if
       end if
    end if
 end if

 close window cts05m00

end function  ###  cts05m00

#-----------------------------------------------------------
 function consulta_cts05m00()
#-----------------------------------------------------------

 define ws            record
    lignum            like datrligsrv.lignum,
    funmat            like datmservico.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    vclcorcod         like datmservico.vclcorcod,
    eqprgicod         like ssakeqprgi.eqprgicod,
    codigosql         integer,
    qtd_dispo_ativo   integer,
    empcod            like datmservico.empcod                         #Raul, Biz
 end record



        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom      ,
        vclcoddig, vcldes   ,
        vclanomdl, vcllicnum,
        corsus   , cornom   ,
        vclcorcod, atdrsdflg,
        atddfttxt, atdlclflg,
        atddoctxt, funmat   ,
        atddat   , atdhor   ,
        ciaempcod, atdfnlflg,
        empcod                                                        #Raul, Biz
   into d_cts05m00.nom      ,
        d_cts05m00.vclcoddig,
        d_cts05m00.vcldes   ,
        d_cts05m00.vclanomdl,
        d_cts05m00.vcllicnum,
        d_cts05m00.corsus   ,
        d_cts05m00.cornom   ,
        ws.vclcorcod        ,
        d_cts05m00.atdrsdflg,
        d_cts05m00.atddfttxt,
        d_cts05m00.atdlclflg,
        d_cts05m00.atddoctxt,
        ws.funmat           ,
        ws.atddat           ,
        ws.atdhor           ,
        g_documento.ciaempcod,
        w_cts05m00.atdfnlflg,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound then
    error " Furto/Roubo nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 let m_atddat = ws.atddat
 let m_atdhor = ws.atdhor

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts05m00[1].lclidttxt   ,
                         a_cts05m00[1].lgdtip      ,
                         a_cts05m00[1].lgdnom      ,
                         a_cts05m00[1].lgdnum      ,
                         a_cts05m00[1].lclbrrnom   ,
                         a_cts05m00[1].brrnom      ,
                         a_cts05m00[1].cidnom      ,
                         a_cts05m00[1].ufdcod      ,
                         a_cts05m00[1].lclrefptotxt,
                         a_cts05m00[1].endzon      ,
                         a_cts05m00[1].lgdcep      ,
                         a_cts05m00[1].lgdcepcmp   ,
                         a_cts05m00[1].lclltt      ,
                         a_cts05m00[1].lcllgt      ,
                         a_cts05m00[1].dddcod      ,
                         a_cts05m00[1].lcltelnum   ,
                         a_cts05m00[1].lclcttnom   ,
                         a_cts05m00[1].c24lclpdrcod,
                         a_cts05m00[1].celteldddcod,
                         a_cts05m00[1].celtelnum   ,
                         a_cts05m00[1].endcmp      ,
                         ws.codigosql              ,
                         a_cts05m00[1].emeviacod

 select ofnnumdig into a_cts05m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts05m00[1].lgdtxt = a_cts05m00[1].lgdtip clipped, " ",
                            a_cts05m00[1].lgdnom clipped, " ",
                            a_cts05m00[1].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Obtem DOCUMENTO (Sucursal, Apolice e Item) do servico
#--------------------------------------------------------------------
 select succod   ,
        ramcod   ,
        aplnumdig,
        itmnumdig,
        edsnumref
   into k_apolice.succod   ,
        k_apolice.ramcod   ,
        k_apolice.aplnumdig,
        k_apolice.itmnumdig,
        k_apolice.edsnumref
   from datrservapol
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = 0  then
    let g_documento.succod    = k_apolice.succod
    let g_documento.ramcod    = k_apolice.ramcod
    let g_documento.aplnumdig = k_apolice.aplnumdig
    let g_documento.itmnumdig = k_apolice.itmnumdig
    let g_documento.edsnumref = k_apolice.edsnumref

    let d_cts05m00.doctxt = "APOLICE.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 let ws.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 select ligcvntip,
        c24solnom
   into w_cts05m00.ligcvntip,
        d_cts05m00.c24solnom
   from datmligacao
  where lignum = ws.lignum

 select cpodes
   into d_cts05m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts05m00.ligcvntip

 select bocnum   ,
        bocemi   ,
        sindat   ,
        c24sintip,
        c24sinhor,
        vicsnh   ,
        sinhor
   into d_cts05m00.bocnum   ,
        d_cts05m00.bocemi   ,
        d_cts05m00.sindat   ,
        d_cts05m00.c24sintip,
        d_cts05m00.c24sinhor,
        w_cts05m00.vicsnh           ,
        d_cts05m00.sinhor
   from datmservicocmp
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 let d_cts05m00.servico = g_documento.atdsrvorg using "&&",
                          "/", g_documento.atdsrvnum using "&&&&&&&",
                          "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts05m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 let ws.funnom = "** NAO CADASTRADO **"
 initialize ws.dptsgl to null

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 select sinvstano, eqprgicod
   into w_cts05m00.ano4, ws.eqprgicod
   from datmavssin
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 if ws.eqprgicod is not null then
    select eqprgides
      into d_cts05m00.eqprgides
      from ssakeqprgi
     where eqprgicod = ws.eqprgicod
 end if

 if d_cts05m00.c24sintip is not null then
    if d_cts05m00.c24sintip  = "R" then
       let d_cts05m00.sintipdes = "ROUBO"
    else
       let d_cts05m00.sintipdes = "FURTO"
    end if
 end if

 let d_cts05m00.atdtxt = ws.atddat                 ," ",
                         ws.atdhor                 ," ",
                         upshift(ws.dptsgl) clipped," ",
                         ws.funmat  using "&&&&&&" ," ",
                         upshift(ws.funnom)

end function  ###  consulta_cts05m00

#-----------------------------------------------------------
 function modifica_cts05m00()
#-----------------------------------------------------------

 define hist_cts05m00 record
    hist1    like datmservhist.c24srvdsc ,
    hist2    like datmservhist.c24srvdsc ,
    hist3    like datmservhist.c24srvdsc ,
    hist4    like datmservhist.c24srvdsc ,
    hist5    like datmservhist.c24srvdsc
 end record
 define ws   record
    tabname  like systables.tabname     ,
    codigosql integer
 end record

 define prompt_key    char (01)


        let     prompt_key  =  null

        initialize  hist_cts05m00.*  to  null

        initialize  ws.*  to  null

 call input_cts05m00() returning hist_cts05m00.*

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts05m00      to null
    initialize d_cts05m00.*    to null
    initialize w_cts05m00.*    to null
    initialize k_apolice.*     to null
    clear form
    return false
 end if

 whenever error continue

 BEGIN WORK

   update datmservico set ( nom      , corsus   , cornom   , atdrsdflg,
                            atddfttxt, atdlclflg, atddoctxt, vclcorcod )
                        = ( d_cts05m00.nom      , d_cts05m00.corsus   ,
                            d_cts05m00.cornom   , d_cts05m00.atdrsdflg,
                            d_cts05m00.atddfttxt, d_cts05m00.atdlclflg,
                            d_cts05m00.atddoctxt, w_cts05m00.vclcorcod        )
                     where  atdsrvnum = g_documento.atdsrvnum and
                            atdsrvano = g_documento.atdsrvano

   if sqlca.sqlcode <> 0 then
      error " Erro (", sqlca.sqlcode, ") na alteracao do laudo de servico. AVISE A INFORMATICA!"
      rollback work
      prompt "" for char prompt_key
      return false
   end if

   update datmservicocmp set ( c24sintip, c24sinhor, bocflg   , bocnum   ,
                               bocemi   , vicsnh   , sinhor   )
                         =   ( d_cts05m00.c24sintip, d_cts05m00.c24sinhor,
                               w_cts05m00.bocflg   , d_cts05m00.bocnum   ,
                               d_cts05m00.bocemi   , w_cts05m00.vicsnh   ,
                               d_cts05m00.sinhor)
           where atdsrvnum = g_documento.atdsrvnum and
                 atdsrvano = g_documento.atdsrvano

   if sqlca.sqlcode <> 0 then
      error " Erro (",sqlca.sqlcode,") na alteracao do complemento do servico. AVISE A INFORMATICA!"
      rollback work
      prompt "" for char prompt_key
      return false
   end if

  #--------------------------------------------------------------------
  # Alteracao tabela de Aviso de sinistro
  #--------------------------------------------------------------------
  select sinvstnum
    from datmavssin
   where sinvstnum = g_documento.atdsrvnum
     and sinvstano = w_cts05m00.ano4

  if sqlca.sqlcode = notfound  then
     insert into datmavssin (sinvstnum,
                             sinvstano,
                             atdsrvnum,
                             atdsrvano,
                             sinntzcod,
                             eqprgicod)
                    values  (g_documento.atdsrvnum,
                             w_cts05m00.ano4,
                             g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             w_cts05m00.sinntzcod,
                             w_cts05m00.eqprgicod)

     if sqlca.sqlcode <>  0  then
        error " Erro (", sqlca.sqlcode, ") na gravacao da Aviso Sinistro.",
              " AVISE A INFORMATICA! "
        rollback work
        prompt "" for char prompt_key
        return false
     end if
     ----------------[ atualiza as bases do sinistro ]--------------------
     call smata030_ins (g_documento.atdsrvnum     ,
                        w_cts05m00.ano4           ,
                        g_documento.succod        ,
                        g_documento.aplnumdig     ,
                        g_documento.itmnumdig     ,
                        w_cts05m00.ano4           ,
                        g_documento.atdsrvnum     ,
                        0                         ,
                        d_cts05m00.sindat         ,
                        d_cts05m00.sinhor         ,
                        wg_smata030.segnom        ,
                        wg_smata030.segtelnum     ,
                        wg_smata030.cgccpfnum     ,
                        wg_smata030.cgcord        ,
                        wg_smata030.cgccpfdig     ,
                        d_cts05m00.vclcoddig      ,
                        ""                        ,
                        wg_smata030.vclchsnum      ,
                        d_cts05m00.vcllicnum      ,
                        wg_smata030.vclanofbc      ,
                        d_cts05m00.vclanomdl      ,
                        ""                        ,  # sinrclsgrflg
                        ""                        ,  # sinrclsgdnom
                        ""                        ,  # sinrclcpdflg
                        ""                        ,  # sinvclguiflg
                        ""                        ,  # sinvclguinom
                        g_documento.ramcod        ,
                        ""                        ,  # subcod
                        ""                        ,  # prporgidv
                        ""                        ,  # prpnumidv
                        g_issk.dptsgl             ,
                        g_issk.funmat             ,
                        ""                        , #a_cts05m00[1].lgdtxt
                        ""                        ,
                        ""                        , #a_cts05m00[1].cidnom
                        ""                        , #a_cts05m00[1].ufdcod
                        ""                        ,
                        ""                        ,
                        ""                        ,
                        ""                        , #sinrclapltxt
                        w_cts05m00.sinntzcod      ,
                        1                         , #prdtipcod 2=perda total
                        d_cts05m00.atdrsdflg      , #chsliccnfflg
                        d_cts05m00.atdlclflg      , #docrouflg
                        d_cts05m00.atddoctxt      , #docroutxt
                        d_cts05m00.atddfttxt      , #sinavsobs
                        d_cts05m00.c24sintip      , #sinrbftip
                        ""                        , #sinlclcep
                        ""                        , #sinrclbrrnom
                        wg_smata030.flgcondutor   , #sinrclprimotflg
                        ""                        , #sinmotidd
                        ""                        , #trcaplvigfnl
                        ""                        , #trcaplviginc
                        wg_smata030.nscdat      )   #data nasc. motorista
              returning ws.codigosql
      if ws.codigosql <> 0  then
         error " Erro na func.SMATA030_INS: ", ws.codigosql,
               " na gravacao do aviso de furto/roubo). AVISE A INFORMATICA!"
         rollback work
         prompt "" for char prompt_key
         return false
      end if
  else
     update datmavssin set (sinntzcod, eqprgicod)
                        =  (w_cts05m00.sinntzcod, w_cts05m00.eqprgicod)
        where sinvstnum = g_documento.atdsrvnum
          and sinvstano = w_cts05m00.ano4

     if sqlca.sqlcode <>  0  then
        error " Erro (", sqlca.sqlcode, ") na alteracao da Aviso Sinistro.",
              " AVISE A INFORMATICA! "
        rollback work
        prompt "" for char prompt_key
        return false
     end if
     ----------------[ atualiza as bases do sinistro ]--------------------
     call smata030_upd (g_documento.atdsrvnum     ,
                        wg_smata030.ano           ,
                        wg_smata030.segnom        ,
                        wg_smata030.segtelnum     ,
                        wg_smata030.cgccpfnum     ,
                        wg_smata030.cgcord        ,
                        wg_smata030.cgccpfdig     ,
                        d_cts05m00.vclcoddig      ,
                        ""                        ,
                        wg_smata030.vclchsnum      ,
                        d_cts05m00.vcllicnum      ,
                        wg_smata030.vclanofbc      ,
                        d_cts05m00.vclanomdl      ,
                        "S"                       , # sinrclsgrflg
                        "PORTO SEGURO"            , # sinrclsgdnom
                        ""                        , # sinrclapltxt
                        ""                        , # sinrclcpdflg
                        ""                        , # sinvclguiflg
                        ""                        , # sinvclguinom
                        a_cts05m00[1].lgdtxt      ,
                        ""                        ,
                        a_cts05m00[1].cidnom      ,
                        a_cts05m00[1].ufdcod      ,
                        ""                        , #sinbemdes
                        w_cts05m00.sinntzcod      ,
                        1                         , #prdtipcod 1=perda total
                        d_cts05m00.atdrsdflg      , #chsliccnfflg
                        d_cts05m00.atdlclflg      , #docrouflg
                        d_cts05m00.atddoctxt      , #docroutxt
                        d_cts05m00.atddfttxt      , #sinavsobs
                        d_cts05m00.c24sintip      , #sinrbftip
                        a_cts05m00[1].lgdcep      , #sinlclcep
                        a_cts05m00[1].lclbrrnom   , #sinrclbrrnom
                        wg_smata030.flgcondutor   , #sinrclprimotflg
                        ""                        , #sinmotidd
                        wg_smata030.vigfnl        , #trcaplvigfnl
                        wg_smata030.viginc        , #trcaplviginc
                        wg_smata030.nscdat       )  #data nasc. motorista
              returning ws.tabname,ws.codigosql
     if ws.codigosql <> 0  then
        error " Erro na func.SMATA030_upd: ", ws.codigosql,
              " na gravacao do aviso de furto/roubo). AVISE A INFORMATICA!"
        rollback work
        prompt "" for char prompt_key
        return false
     end if
     call ssmatamot030_upd(g_documento.atdsrvnum     ,
                           wg_smata030.ano           ,
                           "S"                       ,
                           wg_smata030.segnom        ,
                           wg_smata030.cgccpfnum     ,
                           wg_smata030.endlgd        ,
                           wg_smata030.endbrr        ,
                           wg_smata030.endcid        ,
                           wg_smata030.endufd        ,
                           wg_smata030.segdddcod     ,
                           wg_smata030.segtelnum     ,
                           ""                        ,  # cnhnum
                           ""                        ,  # cnhvctdat
                           ""                        ,
                           ""                        ,
                           ""                        ,
                           ""                        ,
                           ""                        ,
                           ""                        ,  # sinmotsex
                           ""                        ,  # sinmotprfcod
                           ""                        ,  # sinsgrvin
                           ""                        ,  # sinmotidd
                           ""                        ,  # sinmotcplflg
                           wg_smata030.cgcord        ,
                           wg_smata030.cgccpfdig     ,
                           ""                        ,
                           ""                        ,  # sinmotprfdes
                           ""                        ,
                           ""                        ,  # cdtestcod
                           wg_smata030.nscdat       )   # data nasc. motorista
                 returning ws.codigosql
     if ws.codigosql <> 0  then
        error " Erro na func.SMATMOT030_upd: ", ws.codigosql,
              " na gravacao do aviso de furto/roubo). AVISE A INFORMATICA!"
        rollback work
        prompt "" for char prompt_key
        return false
     end if
  end if

  commit work
  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                              g_documento.atdsrvano)

 whenever error stop

 call altera_cts05m00()

 return true

end function  ###  modifica_cts05m00()


#-------------------------------------------------------------------------------
 function inclui_cts05m00()
#-------------------------------------------------------------------------------

 define hist_cts05m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define ws              record
        prompt_key          char(01)               ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        orrdat          like adbmbaixa.orrdat      ,
        vstnumdig       like abbmveic.vstnumdig    ,
        c24opemat       like datmservico.c24opemat ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        vclcoddig       like abbmveic.vclcoddig    ,
        vcllicnum       like abbmveic.vcllicnum    ,
        vclchsfnl       like abbmveic.vclchsfnl    ,
        vclchsinc       like abbmveic.vclchsinc    ,
        ituran          smallint,
        tracker         smallint,
        daf4            smallint,
        daf5            smallint,
        qtd_dispo_ativo integer
 end record
 ## PSI 195693
 define lr_figrc006     record
        coderro            integer
       ,menserro   char(30)
       ,msgid              char(24)
       ,correlid   char(24)
        end record

 define l_xml       char(32766)
       ,l_online    smallint
       ,l_msg_erro  char(100)

 define l_data_banco     date,
        l_hora2          datetime hour to minute

 define l_hora_unix datetime hour to second
 define l_msg_pri   char(100)

 initialize  hist_cts05m00.*  to  null
 initialize  ws.*  to  null

 initialize lr_figrc006.* to null
 let l_msg_erro= null
 let l_xml     = null
 let l_online  = 0

 while true
   initialize ws.*  to null

   let g_documento.acao = "INC"

   call input_cts05m00() returning hist_cts05m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts05m00      to null
       initialize d_cts05m00.*    to null
       initialize w_cts05m00.*    to null
       initialize k_apolice.*     to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   let ws.c24opemat = g_issk.funmat    #   Bloqueio do servico

   call cts40g03_data_hora_banco(2)
        returning l_data_banco, l_hora2
   if  l_data_banco > "31/12/1998"  and
       l_data_banco < "16/01/1999"  then
       if  d_cts05m00.sindat < "01/01/1999"  then
           let w_cts05m00.ano2 = 98
           let w_cts05m00.ano4 = "1998"
       end if
   end if


 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "5" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql  ,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS05M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum = ws.lignum
   let aux_atdsrvnum      = ws.atdsrvnum
   let aux_atdsrvano      = ws.atdsrvano
   let w_cts05m00.ano4 =  '20', ws.atdsrvano using "&&"


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts05m00.data         ,
                           w_cts05m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           g_issk.funmat           ,
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
                           "", "", "", "" )
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


   call cts10g02_grava_servico( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                w_cts05m00.vclcorcod,
                                g_issk.funmat       ,
                                ""                  ,     # atdlibflg
                                ""                  ,     # atdlibhor
                                ""                  ,     # atdlibdat
                                w_cts05m00.data     ,
                                w_cts05m00.hora     ,
                                d_cts05m00.atdlclflg,
                                ""                  ,     # atdhorpvt
                                ""                  ,     # atddatprg
                                ""                  ,     # atdhorprg
                                "5"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                ""                  ,     # atdprscod
                                ""                  ,     # atdcstvlr
                                "S"                 ,     # atdfnlflg
                                ""                  ,     # atdfnlhor
                                d_cts05m00.atdrsdflg,
                                d_cts05m00.atddfttxt,
                                d_cts05m00.atddoctxt,
                                ws.c24opemat        ,
                                d_cts05m00.nom      ,
                                d_cts05m00.vcldes   ,
                                d_cts05m00.vclanomdl,
                                d_cts05m00.vcllicnum,
                                d_cts05m00.corsus   ,
                                d_cts05m00.cornom   ,
                                w_cts05m00.data     ,     # cnldat
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                ""                  ,     # atdpvtretflg
                                ""                  ,     # atdvcltip
                                ""                  ,     # asitipcod
                                ""                  ,     # socvclcod
                                d_cts05m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                2                   ,   # atdprinvlcod 2-normal
                                g_documento.atdsrvorg   ) # ATDSRVORG
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
 # Grava complemento do servico
 #------------------------------------------------------------------------------
   insert into DATMSERVICOCMP ( atdsrvnum,
                                atdsrvano,
                                c24sintip,
                                c24sinhor,
                                sindat   ,
                                bocflg   ,
                                bocnum   ,
                                bocemi   ,
                                vicsnh   ,
                                sinhor    )
                       values ( aux_atdsrvnum       ,
                                aux_atdsrvano       ,
                                d_cts05m00.c24sintip,
                                d_cts05m00.c24sinhor,
                                d_cts05m00.sindat   ,
                                w_cts05m00.bocflg   ,
                                d_cts05m00.bocnum   ,
                                d_cts05m00.bocemi   ,
                                w_cts05m00.vicsnh   ,
                                d_cts05m00.sinhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " complemento do servico. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
   #insert into DATMSRVACP( atdsrvnum,
   #                        atdsrvano,
   #                        atdsrvseq,
   #                        atdetpcod,
   #                        atdetpdat,
   #                        atdetphor,
   #                        empcod   ,
   #                        funmat    )
   #                values( aux_atdsrvnum  ,
   #                        aux_atdsrvano  ,
   #                        1              ,
   #                        4              ,
   #                        w_cts05m00.data,
   #                        w_cts05m00.hora,
   #                        g_issk.empcod  ,
   #                        g_issk.funmat   )

   call cts10g04_insere_etapa(aux_atdsrvnum,
                              aux_atdsrvano,
                              1, "", "", "", "")
        returning ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " etapa de acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 1
       if  a_cts05m00[arr_aux].operacao is null  then
           let a_cts05m00[arr_aux].operacao = "I"
       end if

       let ws.codigosql = cts06g07_local( a_cts05m00[arr_aux].operacao,
                                        aux_atdsrvnum,
                                        aux_atdsrvano,
                                        arr_aux,
                                        a_cts05m00[arr_aux].lclidttxt,
                                        a_cts05m00[arr_aux].lgdtip,
                                        a_cts05m00[arr_aux].lgdnom,
                                        a_cts05m00[arr_aux].lgdnum,
                                        a_cts05m00[arr_aux].lclbrrnom,
                                        a_cts05m00[arr_aux].brrnom,
                                        a_cts05m00[arr_aux].cidnom,
                                        a_cts05m00[arr_aux].ufdcod,
                                        a_cts05m00[arr_aux].lclrefptotxt,
                                        a_cts05m00[arr_aux].endzon,
                                        a_cts05m00[arr_aux].lgdcep,
                                        a_cts05m00[arr_aux].lgdcepcmp,
                                        a_cts05m00[arr_aux].lclltt,
                                        a_cts05m00[arr_aux].lcllgt,
                                        a_cts05m00[arr_aux].dddcod,
                                        a_cts05m00[arr_aux].lcltelnum,
                                        a_cts05m00[arr_aux].lclcttnom,
                                        a_cts05m00[arr_aux].c24lclpdrcod,
                                        a_cts05m00[arr_aux].ofnnumdig,
                                        a_cts05m00[arr_aux].emeviacod,
                                        a_cts05m00[arr_aux].celteldddcod,
                                        a_cts05m00[arr_aux].celtelnum,
                                        a_cts05m00[arr_aux].endcmp)

       if  ws.codigosql is null  or
           ws.codigosql <> 0     then
           if  arr_aux = 1  then
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de ocorrencia. AVISE A INFORMATICA!"
           else
               error " Erro (", ws.codigosql, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!"
           end if
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if  g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then
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
           error " Erro (", ws.codigosql, ") na gravacao do",
                 " relacionamento servico x apolice. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
       if g_documento.cndslcflg = "S"  then
          select flgcondutor,ctcdtnom,ctcgccpfnum,ctcgccpfdig
            into wg_smata030.flgcondutor,w_cts05m00.cdtnom,
                 ws.cgccpfnum,ws.cgccpfdig
            from tmpcondutor
          call grava_condutor(g_documento.succod,g_documento.aplnumdig,
                              g_documento.itmnumdig,w_cts05m00.cdtnom,
                              ws.cgccpfnum,ws.cgccpfdig,"D","CENTRAL24H")
                    returning ws.cdtseq
          let ws_cgccpfnum = ws.cgccpfnum
          let ws_cgccpfdig = ws.cgccpfdig
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
                     ws.cdtseq             )
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


 #------------------------------------------------------------------------------
 # Grava tabela de relacionamento Servico x Vistoria Sinistro
 #------------------------------------------------------------------------------
   insert into DATRSRVVSTSIN( atdsrvnum      ,
                              atdsrvano      ,
                              sinvstnum      ,
                              sinvstano      ,
                              sinvstlauemsstt )
                      values( aux_atdsrvnum  ,
                              aux_atdsrvano  ,
                              aux_atdsrvnum  ,
                              w_cts05m00.ano4,
                              1               )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " relacionamento servico x vst sin. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava tabela de Aviso de sinistro
 #------------------------------------------------------------------------------
   insert into DATMAVSSIN( sinvstnum,
                           sinvstano,
                           atdsrvnum,
                           atdsrvano,
                           sinntzcod,
                           eqprgicod )
                   values( aux_atdsrvnum       ,
                           w_cts05m00.ano4     ,
                           aux_atdsrvnum       ,
                           aux_atdsrvano       ,
                           w_cts05m00.sinntzcod,
                           w_cts05m00.eqprgicod )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " aviso de sinistro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   # Psi 230669 inicio
     if (g_documento.atdnum is not null and
         g_documento.atdnum <> 0 ) then
         let l_msg_pri = "PRI - cts05m00 - chamando ctd25g00"
         call errorlog(l_msg_pri)

         call ctd25g00_insere_atendimento(g_documento.atdnum,g_documento.lignum)
              returning ws.codigosql,
                        ws.tabname
          if  ws.codigosql  <>  0  then
              error ws.tabname sleep 3
              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
          end if
     end if
   # Psi 230669 Fim

   if  g_documento.succod   = 1     and     ## Sucursal Sao Paulo
       a_cts05m00[1].ufdcod = "SP"  then    ## Sinistro em Sao Paulo

     #--------------------------------------------------------------------------
     # Verifica se veiculo realizou vistoria previa
     #--------------------------------------------------------------------------
       select vstnumdig
         into ws.vstnumdig
         from ABBMVEIC
              where succod    = g_documento.succod
                and aplnumdig = g_documento.aplnumdig
                and itmnumdig = g_documento.itmnumdig
                and dctnumseq = g_funapol.vclsitatu
                and vsttip    = 'V'

     #--------------------------------------------------------------------------
     # Veiculo COM VP - Solicitacao de cotacao
     #--------------------------------------------------------------------------
       if  ws.vstnumdig <> 0        and
           ws.vstnumdig is not null then
           call cts40g03_data_hora_banco(2)
                returning l_data_banco, l_hora2
           call sxcka011( g_documento.ramcod,
                          w_cts05m00.ano4   ,
                          aux_atdsrvnum     ,
                          0                 ,
                          l_data_banco      ,
                          g_issk.funmat     ,
                          g_issk.succod     ,
                          g_documento.aplnumdig,
                          g_documento.itmnumdig,
                          g_documento.edsnumref )
                returning ws.codigosql

           if  ws.codigosql = 0  then
               error " Solicitacao do laudo de cotacao concluida com sucesso!"
               ## sleep 2
           else
               error " Erro (", ws.codigosql,") durante a",
                     " solicitacao do laudo de cotacao! AVISE A INFORMATICA!"
               ## sleep 2

               call cts10g02_historico( aux_atdsrvnum  ,
                                        aux_atdsrvano  ,
                                        w_cts05m00.data,
                                        w_cts05m00.hora,
                                        g_issk.funmat  ,
               "**** NAO FOI POSSIVEL REALIZAR A SOLICITACAO AUTOMATICA ! ****",
               "**** PROVIDENCIAR COTACAO ! ****","","","")
                    returning ws.histerr
           end if
       else
         #----------------------------------------------------------------------
         # Veiculo SEM VP - Mensagem no historico
         #----------------------------------------------------------------------
           call cts10g02_historico( aux_atdsrvnum  ,
                                    aux_atdsrvano  ,
                                    w_cts05m00.data,
                                    w_cts05m00.hora,
                                    g_issk.funmat  ,
            "** VEICULO SEM DADOS DE VISTORIA PREVIA - PROVIDENCIAR COTACAO **",
                                    "","","","")
                returning ws.histerr
       end if
   end if
   ----------------[ atualiza base de dados do sinistro ]--------------------
   call smata030_ins (aux_atdsrvnum             ,
                      w_cts05m00.ano4           ,
                      g_documento.succod        ,
                      g_documento.aplnumdig     ,
                      g_documento.itmnumdig     ,
                      w_cts05m00.ano4           ,
                      aux_atdsrvnum             ,
                      0                         ,
                      d_cts05m00.sindat         ,
                      d_cts05m00.sinhor         ,
                      wg_smata030.segnom        ,
                      wg_smata030.segtelnum     ,
                      wg_smata030.cgccpfnum     ,
                      wg_smata030.cgcord        ,
                      wg_smata030.cgccpfdig     ,
                      d_cts05m00.vclcoddig      ,
                      ""                        ,
                      wg_smata030.vclchsnum      ,
                      d_cts05m00.vcllicnum      ,
                      wg_smata030.vclanofbc      ,
                      d_cts05m00.vclanomdl      ,
                      ""                        ,  # sinrclsgrflg
                      ""                        ,  # sinrclsgdnom
                      ""                        ,  # sinrclcpdflg
                      ""                        ,  # sinvclguiflg
                      ""                        ,  # sinvclguinom
                      g_documento.ramcod        ,
                      ""                        ,  # subcod
                      ""                        ,  # prporgidv
                      ""                        ,  # prpnumidv
                      g_issk.dptsgl             ,
                      g_issk.funmat             ,
                      ""                        , #a_cts05m00[1].lgdtxt
                      ""                        ,
                      ""                        , #a_cts05m00[1].cidnom
                      ""                        , #a_cts05m00[1].ufdcod
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      g_documento.aplnumdig      , #sinrclapltxt
                      w_cts05m00.sinntzcod      ,
                      1                         , #prdtipcod 2=perda total
                      d_cts05m00.atdrsdflg      , #chsliccnfflg
                      d_cts05m00.atdlclflg      , #docrouflg
                      d_cts05m00.atddoctxt      , #docroutxt
                      d_cts05m00.atddfttxt      , #sinavsobs
                      d_cts05m00.c24sintip      , #sinrbftip
                      ""                        , #sinlclcep
                      ""                        , #sinrclbrrnom
                      wg_smata030.flgcondutor   , #sinrclprimotflg
                      ""                        , #sinmotidd
                      ""                        , #trcaplvigfnl
                      ""                        , #trcaplviginc
                      wg_smata030.nscdat       )  #data nasc. motorista
            returning ws.codigosql
    if ws.codigosql <> 0  then
       error " Erro na func.SMATA030: ", ws.codigosql,
             " na gravacao do aviso de furto/roubo). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
    end if
     if g_issk.funmat = 601566 then
        display "*** chamei a funcao ssmatmot030_ins "
        display " wg_smata030.segnom    = ", wg_smata030.segnom
        display " wg_smata030.cgccpfnum = ", wg_smata030.cgccpfnum
        display " wg_smata030.cgcord    = ", wg_smata030.cgcord
        display " wg_smata030.cgccpfdig = ", wg_smata030.cgccpfdig
        display " wg_smata030.nscdat    = ", wg_smata030.nscdat
     end if
    call ssmatmot030_ins (aux_atdsrvnum             ,
                          w_cts05m00.ano4           ,
                          "S"                       ,
                          ""                        ,
                          ""                        ,
                          ""                        ,
                          wg_smata030.segnom        ,
                          wg_smata030.cgccpfnum     ,
                          wg_smata030.endlgd        ,
                          wg_smata030.endbrr        ,
                          wg_smata030.endcid        ,
                          wg_smata030.endufd        ,
                          wg_smata030.segdddcod     ,
                          wg_smata030.segtelnum     ,
                          ""                        ,  # cnhnum
                          ""                        ,  # cnhvctdat
                          a_cts05m00[1].lgdtxt      ,
                          a_cts05m00[1].ufdcod      ,
                          a_cts05m00[1].cidnom      ,
                          wg_smata030.sinbocflg     ,
                          ""                        ,  # sinvcllcldes
                          ""                        ,  # sinmotsex
                          ""                        ,  # sinmotprfcod
                          ""                        ,  # sinsgrvin
                          ""                        ,  # sinmotidd
                          ""                        ,  # sinmotcplflg
                          wg_smata030.cgcord        ,
                          wg_smata030.cgccpfdig     ,
                          ""                        ,  # vclatulgd
                          ""                        ,  # sinmotprfdes
                          d_cts05m00.bocnum         ,
                          ""                        ,  # cdtestcod
                          wg_smata030.nscdat       )   #data nasc. motorista
                returning ws.codigosql
    if ws.codigosql <> 0  then
       error " Erro na func.SSMATMOT030_ins: ", ws.codigosql,
             " na gravacao do aviso de furto/roubo). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
    end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                               aux_atdsrvano)

 #------------------------------------------------------------------------------
 # Aciona dispositivo grilo
 #------------------------------------------------------------------------------
   if  g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then

       select vcllicnum,
              vclchsinc,
              vclchsfnl,
              vclcoddig
         into ws.vcllicnum,
              ws.vclchsinc,
              ws.vclchsfnl,
              ws.vclcoddig
         from abbmveic
        where abbmveic.succod     = g_documento.succod     and
              abbmveic.aplnumdig  = g_documento.aplnumdig  and
              abbmveic.itmnumdig  = g_documento.itmnumdig  and
              abbmveic.dctnumseq  = g_funapol.vclsitatu

       call fadia010_grilo(ws.vcllicnum,
                           ws.vclchsfnl,
                           "R")

       #============== ITURAN ======================
       call fadic005_existe_dispo(ws.vclchsinc ,
                                  ws.vclchsfnl ,
                                  ws.vcllicnum ,
                                  ws.vclcoddig ,
                                  1333)    # ITURAN
         returning ws.ituran
                  ,ws.orrdat
                  ,ws.qtd_dispo_ativo
         if ws.ituran = false then
            call fadic005_existe_dispo(ws.vclchsinc ,
                                       ws.vclchsfnl ,
                                       ws.vcllicnum ,
                                       ws.vclcoddig ,
                                       9099)    # ITURAN
              returning ws.ituran
                       ,ws.orrdat
                       ,ws.qtd_dispo_ativo
         end if

       let m_ituran = ws.ituran

       if ws.ituran = true then
          open window cts05m00a at 10,15 with form "cts05m00a"
                        attribute(border, form line 1)
          let int_flag = false
          initialize d_cts05m00a.nome to null

          input by name d_cts05m00a.nome
                 without defaults

             before field nome
                 display by name d_cts05m00a.nome attribute (reverse)
             after field nome
                 display by name d_cts05m00a.nome
                 if d_cts05m00a.nome is null then
                    error "Digite o nome "
                    next field nome
                 end if
             on key (interrupt)
                 if d_cts05m00a.nome is not null then
                    exit input
                 else
                    error "Digite o nome "
                    next field nome
                 end if
          end input
          if int_flag then
             let int_flag = false
          end if
          close window cts05m00a
          if d_cts05m00a.nome is not null then
             let hist_cts05m00.hist1 = d_cts05m00a.nome clipped, " AVISADO A ",
                                       "CONTATAR ITURAN 0800153600/(11)36169999"

             call cts10g02_historico( aux_atdsrvnum  ,
                                      aux_atdsrvano  ,
                                      w_cts05m00.data,
                                      w_cts05m00.hora,
                                      g_issk.funmat  ,
                                      hist_cts05m00.*  )
                  returning ws.histerr
             initialize hist_cts05m00.hist1 to null
          end if
       else
       #============== TRACKER DO BRASIL ======================
         call fadic005_existe_dispo(ws.vclchsinc ,
                                    ws.vclchsfnl ,
                                    ws.vcllicnum ,
                                    ws.vclcoddig ,
                                    1546)     # TRACKER
         returning ws.tracker  , ws.orrdat, ws.qtd_dispo_ativo

          let m_tracker = ws.tracker

          if ws.tracker = true then
             open window cts05m00b at 10,15 with form "cts05m00b"
                                   attribute(border, form line 1)
             let int_flag = false
             initialize d_cts05m00a.nome to null

             input by name d_cts05m00a.nome without defaults

                before field nome
                  display by name d_cts05m00a.nome attribute (reverse)
                after field nome
                  display by name d_cts05m00a.nome
                  if d_cts05m00a.nome is null then
                     error "Digite o nome "
                     next field nome
                  end if

                on key (interrupt)
                   if d_cts05m00a.nome is not null then
                      exit input
                   else
                      error "Digite o nome "
                      next field nome
                   end if
             end input

             if int_flag then
                let int_flag = false
             end if

             close window cts05m00b
             if d_cts05m00a.nome is not null then
                let hist_cts05m00.hist1 = d_cts05m00a.nome clipped
                                         ," ORIENTADO A CONTATAR A CENTRAL"
                                         ," TRACKER DO BRASIL 0800-7728476."
                call cts10g02_historico(aux_atdsrvnum,
                                        aux_atdsrvano,
                                        w_cts05m00.data,
                                        w_cts05m00.hora,
                                        g_issk.funmat,
                                        hist_cts05m00.*)
                returning ws.histerr
                initialize hist_cts05m00.hist1 to null
             end if
          else
              #============== DAF IV ======================
             call fadic005_existe_dispo(ws.vclchsinc ,
                                        ws.vclchsfnl ,
                                        ws.vcllicnum ,
                                        ws.vclcoddig ,
                                        3298)     # DAF IV
             returning ws.daf4  , ws.orrdat, ws.qtd_dispo_ativo

              let m_daf4 = ws.daf4

              if ws.daf4 = false then
                  #============== DAF V ======================
                  call fadic005_existe_dispo(ws.vclchsinc ,
                                             ws.vclchsfnl ,
                                             ws.vcllicnum ,
                                             ws.vclcoddig ,
                                             3646)     # DAF V
                  returning ws.daf5  , ws.orrdat, ws.qtd_dispo_ativo

                  let m_daf5 = ws.daf5
              end if

          end if
       end if
   end if
   {---- PSI  195050 ----terezinha --------
   ##----------[ preencher questionario para sinistro - claus. 018 ]-----------
   ##select clscod
       ##from abbmclaus
      ##where succod    = g_documento.succod    and
            ##aplnumdig = g_documento.aplnumdig and
            ##itmnumdig = g_documento.itmnumdig and
            ##dctnumseq = g_funapol.dctnumseq   and
            ##clscod    = "018"
   ##if sqlca.sqlcode  = 0  then     # inibir para teste 601566 ruiz
      ##call fiavsrbf(aux_atdsrvnum  ,
                    ##w_cts05m00.ano4,
                    ##""             ,
                    ##"I"            ,
                    ##g_issk.empcod  ,
                    ##g_issk.funmat)
   ##end if
   -------------PSI 195050 ----------------}

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( aux_atdsrvnum  ,
                            aux_atdsrvano  ,
                            w_cts05m00.data,
                            w_cts05m00.hora,
                            g_issk.funmat  ,
                            hist_cts05m00.*  )
        returning ws.histerr

 ###  if ws.histerr  = 0  then
 ### initialize g_documento.acao  to null
 ### end if

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts05m00.servico = g_documento.atdsrvorg using "&&",
                            "/", aux_atdsrvnum using "&&&&&&&",
                            "-", aux_atdsrvano using "&&"
   display d_cts05m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error  " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   #chama funcao para montar o xml
   #--> Conforme falado com Luiz do Sinistro, os 4 ultimos parametros podem
   #--> ser enviados nulo para o Assunto F10.
   let l_xml=cts14m00_monta_xml(aux_atdsrvnum,w_cts05m00.ano4, "I","","","","")

   # chama funcao de envio para mq
   let l_msg_erro = null
   let l_online = online()
   ## Inclui passagem pela rotina de envio de mensagem pelo MQ
   let l_hora_unix = current
   let l_msg_erro  = "<cts05m00 ",l_hora_unix,"> CT24H enviando a msg de Servico F10/R10"
   call ssata603_grava_erro(w_cts05m00.ano4
                     ,aux_atdsrvnum
                     ,2
                     ,l_msg_erro
                     ,g_issk.funmat
                     ,1 )
   ## Fica registrado que a central 24 Horas chamou a rotina do MQ

   call figrc006_enviar_datagrama_mq_rq ("SIAUTOANALISE4GLD",l_xml,"CORRELID",l_online)
        returning lr_figrc006.*

   if lr_figrc006.coderro <> 0 then
      let l_msg_erro = lr_figrc006.coderro,' - ',lr_figrc006.menserro clipped
      call ssata603_grava_erro (aux_atdsrvano
                               ,aux_atdsrvnum
                               ,2
                               ,l_msg_erro
                               ,g_issk.funmat
                               ,1 )
   end if

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts05m00

#--------------------------------------------------------------------
 function input_cts05m00()
#--------------------------------------------------------------------

 define hist_cts05m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    endcep            like glaklgd.lgdcep,
    endcepcmp         like glaklgd.lgdcepcmp,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    cidcod            like glakcid.cidcod,
    vclcordes         char (11),
    situacao          char (01),
    retflg            char (01),
    mensagem          char (40),
    confirma          char (01),
    ituran            smallint ,
    tracker           smallint ,
    daf4              smallint ,
    daf5              smallint ,
    ano               char (02),
    orrdat            like adbmbaixa.orrdat,
    qtd_dispo_ativo integer
 end record



        initialize  hist_cts05m00.*  to  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 input by name d_cts05m00.vclcordes ,
               d_cts05m00.atdrsdflg ,
               d_cts05m00.atddfttxt ,
               d_cts05m00.atdlclflg ,
               d_cts05m00.atddoctxt ,
               d_cts05m00.c24sintip ,
               d_cts05m00.sindat    ,
               d_cts05m00.sinhor    ,
               d_cts05m00.c24sinhor ,
               d_cts05m00.bocnum    ,
               d_cts05m00.bocemi
       without defaults

   before field vclcordes
          display by name d_cts05m00.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts05m00.vclcordes

          if w_cts05m00.atdfnlflg = "S" then
             call cts08g01( "A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                            " ","TRANSFIRA A LIGACAO PARA O SINISTRO,   ",
                            "OU RETORNE NO HORARIO COMERCIAL.     **")
             returning ws.confirma
             next field vclcordes
          end if

          if d_cts05m00.vclcordes is not null or
             d_cts05m00.vclcordes <> "  "     then
             let ws.vclcordes = d_cts05m00.vclcordes[2,9]

             select cpocod
               into w_cts05m00.vclcorcod
               from iddkdominio
              where cponom      = "vclcorcod"  and
                    cpodes[2,9] = ws.vclcordes

             if sqlca.sqlcode = notfound    then
                error " Cor fora do padrao!"
                call c24geral4()
                     returning w_cts05m00.vclcorcod, d_cts05m00.vclcordes

                if w_cts05m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informado!"
                   next field vclcordes
                else
                   display by name d_cts05m00.vclcordes
                end if
             end if
          else
             call c24geral4()
                  returning w_cts05m00.vclcorcod, d_cts05m00.vclcordes

             if w_cts05m00.vclcorcod  is null   then
                error " Cor do veiculo deve ser informado!"
                next field vclcordes
             else
                display by name d_cts05m00.vclcordes
             end if
          end if

   before field atdrsdflg
          display by name d_cts05m00.atdrsdflg   attribute (reverse)

   after  field atdrsdflg
          display by name d_cts05m00.atdrsdflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts05m00.atdrsdflg is null then
                error " Confirmacao do CHASSI/PLACA deve ser informada!"
                next field atdrsdflg
             end if

             if d_cts05m00.atdrsdflg  <> "S"  and
                d_cts05m00.atdrsdflg  <> "N"  then
                error " Confirmacao do CHASSI/PLACA invalida!"
                next field atdrsdflg
             end if
          end if

   before field atddfttxt
          display by name d_cts05m00.atddfttxt attribute (reverse)

   after  field atddfttxt
          display by name d_cts05m00.atddfttxt

          if d_cts05m00.atdrsdflg = "N"   and
             d_cts05m00.atddfttxt is null then
             error "Se CHASSI ou PLACA nao conferem, informe os dados corretos!"
             next field atddfttxt
          end if

   before field atdlclflg
          display by name d_cts05m00.atdlclflg attribute (reverse)

   after  field atdlclflg
          display by name d_cts05m00.atdlclflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atddfttxt
          else
             if d_cts05m00.atdlclflg is null then
                error " DOCTOS foram roubados deve ser informado!"
                next field atdlclflg
             end if

             if d_cts05m00.atdlclflg  <> "S"  and
                d_cts05m00.atdlclflg  <> "N"  then
                error " Informacao de DOCTOS invalida!"
                next field atdlclflg
             end if
          end if

          if d_cts05m00.atdlclflg = "N"  then
             initialize d_cts05m00.atddoctxt to null
             display by name d_cts05m00.atddoctxt
             next field c24sintip
          end if

   before field atddoctxt
          display by name d_cts05m00.atddoctxt attribute (reverse)

   after  field atddoctxt
          display by name d_cts05m00.atddoctxt

   before field c24sintip
          display by name d_cts05m00.c24sintip attribute (reverse)

   after  field c24sintip
          display by name d_cts05m00.c24sintip

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts05m00.atdlclflg = "N"  then
                next field atdlclflg
             else
                next field atddoctxt
             end if
          else
             if d_cts05m00.c24sintip is null     or
                d_cts05m00.c24sintip =  "  "     then
                error " Tipo de sinistro deve ser informado!"
                next field c24sintip
             end if

             if d_cts05m00.c24sintip <> "R"     and
                d_cts05m00.c24sintip <> "F"     then
                error " Tipo de sinistro invalido!"
                next field c24sintip
             end if

             if d_cts05m00.c24sintip = "R"      then
                let d_cts05m00.sintipdes = "ROUBO"
                let w_cts05m00.sinntzcod = 30
             else
                let d_cts05m00.sintipdes = "FURTO"
                let w_cts05m00.sinntzcod = 36
             end if

             display by name d_cts05m00.sintipdes

             if d_cts05m00.vcllicnum  is not null   or
                w_cts05m00.vclchsfnl  is not null   then
                 call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                            w_cts05m00.vclchsfnl ,
                                            d_cts05m00.vcllicnum ,
                                            d_cts05m00.vclcoddig ,
                                            1333)    # ITURAN
                   returning ws.ituran
                            ,ws.orrdat
                            ,ws.qtd_dispo_ativo
                 if ws.ituran = false then
                    call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                            w_cts05m00.vclchsfnl ,
                                            d_cts05m00.vcllicnum ,
                                            d_cts05m00.vclcoddig ,
                                            9099)    # ITURAN
                      returning ws.ituran
                               ,ws.orrdat
                               ,ws.qtd_dispo_ativo
                 end if

                let m_ituran = ws.ituran

                if ws.ituran =  true then
                else
                   call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                              w_cts05m00.vclchsfnl ,
                                              d_cts05m00.vcllicnum ,
                                              d_cts05m00.vclcoddig ,
                                              1546)     # TRACKER
                   returning ws.tracker , ws.orrdat, ws.qtd_dispo_ativo
                   let m_tracker = ws.tracker

                   if ws.tracker =  true then
                   else
                      call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                                 w_cts05m00.vclchsfnl ,
                                                 d_cts05m00.vcllicnum ,
                                                 d_cts05m00.vclcoddig ,
                                                 3298)     # DAF IV
                      returning ws.daf4  , ws.orrdat, ws.qtd_dispo_ativo
                      if ws.daf4 =  true then
                      else
                         call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                                    w_cts05m00.vclchsfnl ,
                                                    d_cts05m00.vcllicnum ,
                                                    d_cts05m00.vclcoddig ,
                                                    3646)     # DAF V
                         returning ws.daf5  , ws.orrdat, ws.qtd_dispo_ativo
                         let m_daf5 = ws.daf5

                         if ws.daf5 =  true then
                         else
                            call cts05m01(d_cts05m00.vcllicnum,
                                        w_cts05m00.vclchsfnl,
                                        w_cts05m00.vicsnh   )
                            returning w_cts05m00.vicsnh
                         end if
                      end if
                      # psi express 198080  - fim
                   end if
                end if
             end if

             let m_acesso_ind = false
             let m_atdsrvorg = 11
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                call cts06g03(1,
                              m_atdsrvorg,
                              w_cts05m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts05m00[1].lclidttxt,
                              a_cts05m00[1].cidnom,
                              a_cts05m00[1].ufdcod,
                              a_cts05m00[1].brrnom,
                              a_cts05m00[1].lclbrrnom,
                              a_cts05m00[1].endzon,
                              a_cts05m00[1].lgdtip,
                              a_cts05m00[1].lgdnom,
                              a_cts05m00[1].lgdnum,
                              a_cts05m00[1].lgdcep,
                              a_cts05m00[1].lgdcepcmp,
                              a_cts05m00[1].lclltt,
                              a_cts05m00[1].lcllgt,
                              a_cts05m00[1].lclrefptotxt,
                              a_cts05m00[1].lclcttnom,
                              a_cts05m00[1].dddcod,
                              a_cts05m00[1].lcltelnum,
                              a_cts05m00[1].c24lclpdrcod,
                              a_cts05m00[1].ofnnumdig,
                              a_cts05m00[1].celteldddcod,
                              a_cts05m00[1].celtelnum,
                              a_cts05m00[1].endcmp,
                              hist_cts05m00.*,
                              a_cts05m00[1].emeviacod)
                    returning a_cts05m00[1].lclidttxt,
                              a_cts05m00[1].cidnom,
                              a_cts05m00[1].ufdcod,
                              a_cts05m00[1].brrnom,
                              a_cts05m00[1].lclbrrnom,
                              a_cts05m00[1].endzon,
                              a_cts05m00[1].lgdtip,
                              a_cts05m00[1].lgdnom,
                              a_cts05m00[1].lgdnum,
                              a_cts05m00[1].lgdcep,
                              a_cts05m00[1].lgdcepcmp,
                              a_cts05m00[1].lclltt,
                              a_cts05m00[1].lcllgt,
                              a_cts05m00[1].lclrefptotxt,
                              a_cts05m00[1].lclcttnom,
                              a_cts05m00[1].dddcod,
                              a_cts05m00[1].lcltelnum,
                              a_cts05m00[1].c24lclpdrcod,
                              a_cts05m00[1].ofnnumdig,
                              a_cts05m00[1].celteldddcod,
                              a_cts05m00[1].celtelnum,
                              a_cts05m00[1].endcmp,
                              ws.retflg,
                              hist_cts05m00.*,
                              a_cts05m00[1].emeviacod
              else
                call cts06g11(1,
                              m_atdsrvorg,
                              w_cts05m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts05m00[1].lclidttxt,
                              a_cts05m00[1].cidnom,
                              a_cts05m00[1].ufdcod,
                              a_cts05m00[1].brrnom,
                              a_cts05m00[1].lclbrrnom,
                              a_cts05m00[1].endzon,
                              a_cts05m00[1].lgdtip,
                              a_cts05m00[1].lgdnom,
                              a_cts05m00[1].lgdnum,
                              a_cts05m00[1].lgdcep,
                              a_cts05m00[1].lgdcepcmp,
                              a_cts05m00[1].lclltt,
                              a_cts05m00[1].lcllgt,
                              a_cts05m00[1].lclrefptotxt,
                              a_cts05m00[1].lclcttnom,
                              a_cts05m00[1].dddcod,
                              a_cts05m00[1].lcltelnum,
                              a_cts05m00[1].c24lclpdrcod,
                              a_cts05m00[1].ofnnumdig,
                              a_cts05m00[1].celteldddcod,
                              a_cts05m00[1].celtelnum,
                              a_cts05m00[1].endcmp,
                              hist_cts05m00.*,
                              a_cts05m00[1].emeviacod)
                    returning a_cts05m00[1].lclidttxt,
                              a_cts05m00[1].cidnom,
                              a_cts05m00[1].ufdcod,
                              a_cts05m00[1].brrnom,
                              a_cts05m00[1].lclbrrnom,
                              a_cts05m00[1].endzon,
                              a_cts05m00[1].lgdtip,
                              a_cts05m00[1].lgdnom,
                              a_cts05m00[1].lgdnum,
                              a_cts05m00[1].lgdcep,
                              a_cts05m00[1].lgdcepcmp,
                              a_cts05m00[1].lclltt,
                              a_cts05m00[1].lcllgt,
                              a_cts05m00[1].lclrefptotxt,
                              a_cts05m00[1].lclcttnom,
                              a_cts05m00[1].dddcod,
                              a_cts05m00[1].lcltelnum,
                              a_cts05m00[1].c24lclpdrcod,
                              a_cts05m00[1].ofnnumdig,
                              a_cts05m00[1].celteldddcod,
                              a_cts05m00[1].celtelnum,
                              a_cts05m00[1].endcmp,
                              ws.retflg,
                              hist_cts05m00.*,
                              a_cts05m00[1].emeviacod
              end if

             let a_cts05m00[1].lgdtxt = a_cts05m00[1].lgdtip clipped, " ",
                                        a_cts05m00[1].lgdnom clipped, " ",
                                        a_cts05m00[1].lgdnum using "<<<<#"

             display by name a_cts05m00[1].lgdtxt
             display by name a_cts05m00[1].lclbrrnom
             display by name a_cts05m00[1].endzon
             display by name a_cts05m00[1].cidnom
             display by name a_cts05m00[1].ufdcod
             display by name a_cts05m00[1].lclrefptotxt
             display by name a_cts05m00[1].endcmp

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field c24sintip
             end if

          end if

          #------------------------------------
          # Obtem codigo da regiao
          #------------------------------------
          if a_cts05m00[1].cidnom = "SANTOS"  and
             a_cts05m00[1].ufdcod = "SP"      then
             let w_cts05m00.eqprgicod  = 3    # SUCURSAL
          else
             initialize ws.cidcod to null
             declare c_cid cursor for
              select cidcod
                from glakcid
               where cidnom = a_cts05m00[1].cidnom
                 and cidcep is not null

             foreach c_cid into ws.cidcod
                exit foreach
             end foreach

             declare c_reg cursor for
              select eqprgicod
                from ssakeqprgicid
               where eqprgicidcod = ws.cidcod

             foreach c_reg into w_cts05m00.eqprgicod
                exit foreach
             end foreach
          end if

          if w_cts05m00.eqprgicod is null    then
             if a_cts05m00[1].ufdcod = "SP"  then
                let w_cts05m00.eqprgicod  = 2    # SP - INTERIOR
             else
                let w_cts05m00.eqprgicod  = 3    # SUCURSAIS
             end if
          end if

          let d_cts05m00.eqprgides = " Regiao nao encontrada,  verificar!"
          select eqprgides
            into d_cts05m00.eqprgides
            from ssakeqprgi
           where eqprgicod = w_cts05m00.eqprgicod

          display by name d_cts05m00.eqprgides


   before field sindat
          display by name d_cts05m00.sindat    attribute (reverse)

   after  field sindat
          display by name d_cts05m00.sindat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts05m00.sindat     is null or
                d_cts05m00.sindat     =  " "  then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if
             if d_cts05m00.sindat < w_cts05m00.data then
                let ws.mensagem = "Data informada = ",d_cts05m00.sindat
                call cts08g01("A",
                              "S",
                              "Data do sinistro anterior a data atual",
                              ws.mensagem,
                              "Confirma?",
                              "") returning ws.confirma
                if ws.confirma <> "S" then
                   next field sindat
                end if
             end if

             ------[ critica quebrada para testes R86 ericisson-ruizR86 ]----
           # if d_cts05m00.sindat < today - 366 units day  then
           #    call cts08g01("A",
           #                  "N",
           #                  " ",
           #                  "DATA DO SINISTRO INFORMADA E'",
           #                  "ANTERIOR A  1 (UM) ANO !",
           #                  "") returning ws.confirma
           #    next field sindat
           # end if

           # if d_cts05m00.sindat > today then
           #    error " Data do sinistro maior que data atual!"
           #    next field sindat
           # end if
             --------------------------------------------------------------
          else
             initialize w_cts05m00.eqprgicod to null
          end if

   before field sinhor
          display by name d_cts05m00.sinhor    attribute (reverse)

   after  field sinhor
          display by name d_cts05m00.sinhor

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts05m00.sinhor   is not null and
                d_cts05m00.sinhor   <> "00:00"  then

             ------[ critica quebrada para testes R86 ericisson-ruizR86 ]----
              # if d_cts05m00.sindat  = today     and
              #    d_cts05m00.sinhor  > w_cts05m00.hora  then
              #    error " Hora do furto/roubo e' maior que a hora atual!"
              #    next field sinhor
              # end if

                initialize d_cts05m00.c24sinhor  to null
                display by name d_cts05m00.c24sinhor
                next field bocnum
             end if
          end if

          if d_cts05m00.sinhor  is null then
             let d_cts05m00.sinhor = "00:00"
          end if

   before field c24sinhor
          display by name d_cts05m00.c24sinhor attribute (reverse)

   after  field c24sinhor
          display by name d_cts05m00.c24sinhor

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts05m00.c24sinhor is null     or
                d_cts05m00.c24sinhor =  "  "     then
                if d_cts05m00.sinhor = "00:00" or
                   d_cts05m00.sinhor is null   then
                   error " Deve ser informado o periodo ou hora do sinistro!"
                   next field c24sinhor
                else
                   next field bocnum
                end if
             end if

             if d_cts05m00.c24sinhor <> "D"      and
                d_cts05m00.c24sinhor <> "N"      then
                error " Periodo invalido! Informe (D)ia ou (N)oite"
                next field c24sinhor
             end if
          end if

          if d_cts05m00.c24sinhor is null then
             let d_cts05m00.c24sinhor = " "
          end if

   before field bocnum
          display by name d_cts05m00.bocnum attribute (reverse)

   after  field bocnum
          display by name d_cts05m00.bocnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts05m00.bocnum is null then
                error " Pesquisa Distrito Policial/Batalhoes via CEP!"

                call ctn00c02 ("SP","SAO PAULO"," "," ")
                     returning ws.endcep, ws.endcepcmp
                let int_flag = false

                if ws.endcep is null  then
                   error " Nenhum cep foi selecionado!"
                else
                   call ctn03c01(ws.endcep)
                end if
                let d_cts05m00.bocnum = 0
                let w_cts05m00.bocflg = "N"
             else
                let w_cts05m00.bocflg = "S"
             end if
          end if
          if d_cts05m00.bocnum is not null then
             let wg_smata030.sinbocflg = "S"
          end if

   before field bocemi
          display by name d_cts05m00.bocemi attribute (reverse)

   after  field bocemi
          display by name d_cts05m00.bocemi

          if d_cts05m00.bocemi is null then
             let d_cts05m00.bocemi = "   "
          end if

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if g_documento.atdsrvnum is null then
                if g_documento.c24soltipcod  =  1  then  # Tipo Sol. = Segurado
                  #call cts09g00(g_documento.ramcod   ,  # psi 141003
                  #              g_documento.succod   ,
                  #              g_documento.aplnumdig,
                  #              g_documento.itmnumdig,
                  #              true)
                  #    returning ws.dddcod, ws.teltxt
               #else
               #   if g_documento.c24soltipcod  =  2   and  # Tip.Sol.=Corretor
               #      d_cts05m00.corsus   is not null  then
               #      call cts09g01(d_cts05m00.corsus,"S")
               #   end if
                end if
             end if
          end if

   on key (interrupt)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
             returning ws.confirma

         if ws.confirma = "S"  then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F4)
      select clscod
          from abbmclaus
          where succod    = g_documento.succod  and
                aplnumdig = g_documento.aplnumdig and
                itmnumdig = g_documento.itmnumdig and
                dctnumseq = g_funapol.dctnumseq and
                clscod    = "018"
      if sqlca.sqlcode  = 0  then
         if g_documento.atdsrvnum is null  or
            g_documento.atdsrvano is null  then
            if g_documento.cndslcflg  =  "S"  then
               call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                             g_documento.itmnumdig, "I")
            else
               call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                             g_documento.itmnumdig, "C")
            end if
         else
            call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                          g_documento.itmnumdig, "C")
         end if
      else
         error "Docto nao possui clausula 18 !"
      end if

   on key (F5)
{
      if k_apolice.succod    is not null  and
         k_apolice.ramcod    is not null  and
         k_apolice.aplnumdig is not null  then
         let g_documento.succod    = k_apolice.succod
         let g_documento.ramcod    = k_apolice.ramcod
         let g_documento.aplnumdig = k_apolice.aplnumdig
         let g_documento.itmnumdig = k_apolice.itmnumdig
         let g_documento.edsnumref = k_apolice.edsnumref
         if g_documento.ramcod = 31    or
            g_documento.ramcod = 531  then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         error " Espelho so' com documento localizado!"
      end if
}
      let g_monitor.horaini = current ## Flexvision
      if k_apolice.succod    is not null  and
         k_apolice.ramcod    is not null  and
         k_apolice.aplnumdig is not null  then

         let g_documento.succod    = k_apolice.succod
         let g_documento.ramcod    = k_apolice.ramcod
         let g_documento.aplnumdig = k_apolice.aplnumdig
         let g_documento.itmnumdig = k_apolice.itmnumdig
         let g_documento.edsnumref = k_apolice.edsnumref

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
      else
         error " Espelho so' com documento localizado!"
      end if

   on key (F6)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts10m02 (hist_cts05m00.*) returning hist_cts05m00.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today,  aux_hora)
      end if

   on key (F7)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Impressao somente com cadastramento do servico!"
      else
         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Impressao somente com cadastramento do servico!"
      else
         if d_cts05m00.corsus   is not null then
            # -- OSF 4774 - Fabrica de Software, Katiucia -- #
            if g_documento.c24soltipcod  =  2   or
               g_documento.c24soltipcod  =  8   then
               call cts09g01(d_cts05m00.corsus,"S")
                    returning vm_cts09g01.dddcod
                             ,vm_cts09g01.factxt
                             ,vm_cts09g01.maides
            else
               call cts09g01(d_cts05m00.corsus,"N")
                    returning vm_cts09g01.dddcod
                             ,vm_cts09g01.factxt
                             ,vm_cts09g01.maides
            end if
         end if


             if d_cts05m00.vcllicnum  is not null   or
                w_cts05m00.vclchsfnl  is not null   then
                call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                           w_cts05m00.vclchsfnl ,
                                           d_cts05m00.vcllicnum ,
                                           d_cts05m00.vclcoddig ,
                                           1333)    # ITURAN
                   returning ws.ituran
                            ,ws.orrdat
                            ,ws.qtd_dispo_ativo
                 if ws.ituran = false then
                    call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                           w_cts05m00.vclchsfnl ,
                                           d_cts05m00.vcllicnum ,
                                           d_cts05m00.vclcoddig ,
                                           9099)    # ITURAN
                   returning ws.ituran
                            ,ws.orrdat
                            ,ws.qtd_dispo_ativo
                 end if

                let m_ituran = ws.ituran

                if ws.ituran =  true then
                else
                   call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                              w_cts05m00.vclchsfnl ,
                                              d_cts05m00.vcllicnum ,
                                              d_cts05m00.vclcoddig ,
                                              1546)     # TRACKER
                   returning ws.tracker  , ws.orrdat, ws.qtd_dispo_ativo
                   let m_tracker = ws.tracker
                   if ws.tracker =  true then
                   else
                      call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                                 w_cts05m00.vclchsfnl ,
                                                 d_cts05m00.vcllicnum ,
                                                 d_cts05m00.vclcoddig ,
                                                 3298)     # DAF IV
                      returning ws.daf4  , ws.orrdat, ws.qtd_dispo_ativo

                      if ws.daf4 = false then
                        call fadic005_existe_dispo(w_cts05m00.vclchsinc ,
                                                   w_cts05m00.vclchsfnl ,
                                                   d_cts05m00.vcllicnum ,
                                                   d_cts05m00.vclcoddig ,
                                                   3646)     # DAF V
                        returning ws.daf5  , ws.orrdat, ws.qtd_dispo_ativo
                        let m_daf5 = ws.daf5
                      end if

                   end if
                end if
             end if

         # -- OSF 4774 - Fabrica de Software, Katiucia -- #
         call cts05m02(g_documento.atdsrvnum
                      ,g_documento.atdsrvano
                      ,"F"
                      ,"N"
                      ,vm_cts09g01.dddcod
                      ,vm_cts09g01.factxt
                      ,vm_cts09g01.maides)

         call cts05m00_ituran_tracker(g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

   {------PSI  195050 ----------
   ##on key (F10)
      ##if g_documento.atdsrvnum is null  or
         ##g_documento.atdsrvano is null  then
         ##error " Consulta ao Questionario somente com o numero da Vistoria!"
      ##else
         ##let ws.ano  =  g_documento.atdsrvano
         ##call fiavsrbf(g_documento.atdsrvnum  ,
                       ##ws.ano         ,
                       ##""             ,
                       ##"C"            ,
                       ##g_issk.empcod  ,
                       ##g_issk.funmat)
      ##end if
    -------------PSI 195050 -------Terezinha------}

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts05m00.* to null
 end if

 return hist_cts05m00.*

end function  ###  input_cts05m00

#-----------------------------------------------------------
 function altera_cts05m00()
#-----------------------------------------------------------

 define hist_cts05m00 record
    hist1             like datmservhist.c24srvdsc ,
    hist2             like datmservhist.c24srvdsc ,
    hist3             like datmservhist.c24srvdsc ,
    hist4             like datmservhist.c24srvdsc ,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    histerr           smallint,
    altflg            char (01),
    c24soltipdes      like datksoltip.c24soltipdes,
    historico         like dafmintavs.sinres,
    ligdat            like datmservhist.ligdat,
    lighorinc         like datmservhist.lighorinc,
    c24txtseq         like datmservhist.c24txtseq,
    c24srvdsc         like datmservhist.c24srvdsc
 end record



        initialize  hist_cts05m00.*  to  null

        initialize  ws.*  to  null

 initialize hist_cts05m00.* to null
 let ws.altflg = "N"

 if d_cts05m00.atdrsdflg  <>  s_cts05m00.atdrsdflg  or
    d_cts05m00.atddfttxt  <>  s_cts05m00.atddfttxt  or
    d_cts05m00.atdlclflg  <>  s_cts05m00.atdlclflg  or
    d_cts05m00.atddoctxt  <>  s_cts05m00.atddoctxt  or
    d_cts05m00.bocnum     <>  s_cts05m00.bocnum     or
    d_cts05m00.bocemi     <>  s_cts05m00.bocemi     or
    d_cts05m00.c24sintip  <>  s_cts05m00.c24sintip  or
    d_cts05m00.c24sinhor  <>  s_cts05m00.c24sinhor  or
    d_cts05m00.nom        <>  s_cts05m00.nom        or
    d_cts05m00.corsus     <>  s_cts05m00.corsus     or
    d_cts05m00.cornom     <>  s_cts05m00.cornom     then

    let ws.altflg = "S"

    if g_documento.solnom is null  then
       initialize hist_cts05m00.hist1 to null
    else
       select c24soltipdes
         into ws.c24soltipdes
         from datksoltip
              where c24soltipcod = g_documento.c24soltipcod

       let hist_cts05m00.hist1 = "Solicitado por: ", g_documento.solnom,
                                 " Tipo: ", ws.c24soltipdes clipped
    end if

    let hist_cts05m00.hist2 = "------ INFORMACOES ANTERIORES ------"
    call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                            w_cts05m00.data      , w_cts05m00.hora,
                            g_issk.funmat        , hist_cts05m00.*)
                  returning ws.histerr

    initialize hist_cts05m00.* to null

    if d_cts05m00.c24sintip <>  s_cts05m00.c24sintip  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Tipo Sinistro...: ",s_cts05m00.c24sintip
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.atdrsdflg <>  s_cts05m00.atdrsdflg  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Chassi/Placa....: ",s_cts05m00.atdrsdflg
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.atddfttxt <>  s_cts05m00.atddfttxt  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Observacoes.....: ",s_cts05m00.atddfttxt
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.atdlclflg <>  s_cts05m00.atdlclflg  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Doctos. Roubados: ",s_cts05m00.atdlclflg
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.atddoctxt <>  s_cts05m00.atddoctxt  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Quais Documentos: ",s_cts05m00.atddoctxt
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.bocnum     <>  s_cts05m00.bocnum     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Numero B.O. ....: ",s_cts05m00.bocnum
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.bocemi     <>  s_cts05m00.bocemi     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Emissor.........: ",s_cts05m00.bocemi
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.c24sinhor  <>  s_cts05m00.c24sinhor  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Periodo.........: ",s_cts05m00.c24sinhor
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.nom        <>  s_cts05m00.nom        then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Nome............: ",s_cts05m00.nom
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.corsus     <>  s_cts05m00.corsus     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Susep...........: ",s_cts05m00.corsus
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.cornom     <>  s_cts05m00.cornom     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Corretor........: ",s_cts05m00.cornom
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if
 end if

 if a_cts05m00[1].lgdtxt       <>  s_cts05m00.lgdtxt     or
    a_cts05m00[1].lclbrrnom    <>  s_cts05m00.lclbrrnom  or
    a_cts05m00[1].cidnom       <>  s_cts05m00.cidnom     or
    a_cts05m00[1].ufdcod       <>  s_cts05m00.ufdcod     or
    a_cts05m00[1].lclrefptotxt <>  s_cts05m00.lclrefptotxt  or
    a_cts05m00[1].endzon       <>  s_cts05m00.endzon     or
    d_cts05m00.sindat          <>  s_cts05m00.sindat     or
    d_cts05m00.sinhor          <>  s_cts05m00.sinhor     or
    d_cts05m00.vclcoddig       <>  s_cts05m00.vclcoddig  or
    d_cts05m00.vcldes          <>  s_cts05m00.vcldes     or
    d_cts05m00.vclanomdl       <>  s_cts05m00.vclanomdl  or
    d_cts05m00.vcllicnum       <>  s_cts05m00.vcllicnum  then
    error " As alteracoes foram gravadas no historico! "


    if ws.altflg = "N" then
       initialize hist_cts05m00.hist1 to null

       if g_documento.solnom is null  then
          initialize hist_cts05m00.hist1 to null
       else
          select c24soltipdes
            into ws.c24soltipdes
            from datksoltip
                 where c24soltipcod = g_documento.c24soltipcod

          let hist_cts05m00.hist1 = "Solicitado por: ",
                                    g_documento.solnom," Tipo: (",
                                    ws.c24soltipdes clipped,")"
       end if
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    initialize hist_cts05m00.hist1 to null
    let hist_cts05m00.hist1 = "------- ALTERACOES EFETUADAS -------"
    call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                            w_cts05m00.data      , w_cts05m00.hora,
                            g_issk.funmat        , hist_cts05m00.*)
                  returning ws.histerr

    if a_cts05m00[1].lgdtxt     <>  s_cts05m00.lgdtxt  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Endereco........: ",a_cts05m00[1].lgdtxt
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if a_cts05m00[1].lclbrrnom  <>  s_cts05m00.lclbrrnom  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Bairro..........: ",a_cts05m00[1].lclbrrnom
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if a_cts05m00[1].cidnom     <>  s_cts05m00.cidnom  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Cidade..........: ",a_cts05m00[1].cidnom
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if a_cts05m00[1].ufdcod     <>  s_cts05m00.ufdcod  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Sigla UF........: ",a_cts05m00[1].ufdcod
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if a_cts05m00[1].lclrefptotxt <> s_cts05m00.lclrefptotxt  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Ponto Referencia: ",a_cts05m00[1].lclrefptotxt
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.sindat     <>  s_cts05m00.sindat     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Data Ocorrencia.: ",d_cts05m00.sindat
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.sinhor  <>  s_cts05m00.sinhor  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Hora Ocorrencia.: ",d_cts05m00.sinhor
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.vclcoddig  <>  s_cts05m00.vclcoddig  or
       d_cts05m00.vcldes     <>  s_cts05m00.vcldes     then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Veiculo.........: ", d_cts05m00.vclcoddig using "&&&&&&", " - ", d_cts05m00.vcldes
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.vclanomdl  <>  s_cts05m00.vclanomdl  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Ano Veiculo.....: ",d_cts05m00.vclanomdl
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if

    if d_cts05m00.vcllicnum  <>  s_cts05m00.vcllicnum  then
       initialize hist_cts05m00.hist1 to null
       let hist_cts05m00.hist1 = "Placa Veiculo...: ",d_cts05m00.vcllicnum
       call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                               w_cts05m00.data      , w_cts05m00.hora,
                               g_issk.funmat        , hist_cts05m00.*)
                     returning ws.histerr
    end if
    -------------[ funcao de interface com sistema daf (alteracao) ]----------
    declare c_cts05m00_004 cursor for
        select ligdat,
               lighorinc,
               c24txtseq,
               c24srvdsc
         from datmservhist
        where atdsrvnum = g_documento.atdsrvnum and
              atdsrvano = g_documento.atdsrvano
        order by ligdat, lighorinc, c24txtseq
    foreach c_cts05m00_004 into ws.ligdat,
                            ws.lighorinc,
                            ws.c24txtseq,
                            ws.c24srvdsc
        let ws.historico = ws.historico clipped," ",ws.c24srvdsc
    end foreach
    call cty13g00("",                    # Fim Integração        excfnl
                  "",                    # Codigo Erro           errcod
                  "",                    # Descrição Erro        errdsc
                  "",                    # Codigo Dispositivo    discoddig
                  a_cts05m00[1].lclltt,  # Latitude              sinlclltt
                  a_cts05m00[1].lcllgt,  # Longitude             sinlcllgt
                  g_documento.atdsrvnum, # Número Atendimento    atdsrvnum
                  g_documento.atdsrvano, # Ano Atendimento       atdsrvano
                  d_cts05m00.vclcoddig,  # Codigo Veículo        vclcoddig
                  d_cts05m00.vcldes,     # Descricao Veículo     vcldes
                  d_cts05m00.vcllicnum,  # Placa Veículo         vcllicnum
                  "ALT"                , # Tipo Atendimento      c24astcod
                  wg_smata030.vclchsnum, # Número Chassi         vclchscod
                  wg_smata030.segnom,    # Nome Segurado         segnom
                  d_cts05m00.sindat,     # Data Sisnistro        sindat
                  d_cts05m00.sinhor,     # Data Comunicado       cincmudat
                  w_cts05m00.data,       # Data Cadastro         caddat
                  "",                    # Importancia Segurada  imsvlr
                  ws.historico,          # Resumo do Sinistro    sinres
                  "",                    # Ticket de Entrega     enttck
                  g_documento.succod,    # Codigo Sucursal       succod
                  g_documento.aplnumdig, # Número Apól ce        aplnumdig
                  g_documento.itmnumdig, # Item Apólic           itmnumdig
                  g_funapol.dctnumseq,   # Seq Número Docto      dctnumseq
                  g_documento.edsnumref, # Número Endosso        edsnumdig
                  g_documento.prporg,    # Origem Prop sta       prporgpcp
                  g_documento.prpnumdig, # Número Proposta       prpnumpcp
                  wg_smata030.cgccpfnum, # Número CGC/ PF        cgccpfnum
                  wg_smata030.cgcord,    # Ordem CGC             cgcord
                  wg_smata030.cgccpfdig, # Dígito CGC/ PF        cgccpfdig
                  d_cts05m00.vclcordes,  # Descrição cor Veículo vclcordsc
                  w_cts05m00.cdtnom,     # Nome Condutor         cdtnom
                  "",                    # Número Tent tivas     itgttvnum
                  "cts05m00")            # Programa chamador   ---> Ruiz/Camila
 end if

end function  ###  altera_cts05m00

## #------------------------------------------------------------------------------
## function cts05m00_msg_siniven(lr_param)
## #------------------------------------------------------------------------------
##
## define lr_param       record
##        vcllicnum      like datmservico.vcllicnum
##       ,sindat         like datmservicocmp.sindat
##       ,sinhor         like datmservicocmp.sinhor
##       ,cidnom         like datmlcl.cidnom
##       ,ufdcod         like datmlcl.ufdcod
##       ,vclcordes      char (40)
##       ,vclchsnum      char (40)
##       ,vclmrc         char (30)
##       ,vcltp          char (30)
##       ,vclmdl         char (30)
##       ,data           char (10)
##       ,hora           char (05)
##       ,succod         like datrligapol.succod
##       ,aplnumdig      like datrligapol.aplnumdig
##       ,itmnumdig      like datrligapol.itmnumdig
##       ,ramcod         like datrligapol.ramcod
##       ,avsrcprd       smallint
##       ,lignum         like datmligacao.lignum
##
## end record
##
## define lr_retorno     record
##        msg_sinivem    smallint
## end record
##
## define lr_mens        record
##        sistema        char(10)
##       ,remet          char(50)
##       ,para           char(1000)
##       ,msg            char(300)
##       ,subject        char(300)
## end record
##
## define l_rep          char(100),
##        l_cmd          char(500),
##        l_ret          smallint,
##        l_rel          char(100),
##        l_hora1        datetime year to second,
##        l_data_banco   date,
##        l_aux          char(20)
##
##    let l_rep = ""
##    let l_cmd = ""
##    let l_ret = 0
##    let l_rel = ""
##
##    initialize lr_mens.*    to null
##    initialize lr_retorno.* to null
##
##    call cts40g03_data_hora_banco(1)
##        returning l_data_banco, l_hora1
##    let l_aux = l_hora1
##
##    if lr_param.avsrcprd = 0 then
##       let l_rel = "AVISO_RF_5886_" clipped,
##                   l_aux[9,10], l_aux[6,7], l_aux[1,4], "_",
##                   l_aux[12,13], l_aux[15,16], l_aux[18,19], ".xml"
##    else
##       let l_rel = "AVISO_RECUPERADO_5886_" clipped,
##                   l_aux[9,10], l_aux[6,7], l_aux[1,4], "_",
##                   l_aux[12,13], l_aux[15,16], l_aux[18,19], ".xml"
##    end if
##
##    let l_rep = "./", l_rel clipped
##
##    #-- Obtem marca e modelo do veiculo
##   select vclmrcnom,
##          vcltipnom,
##          vclmdlnom
##   into lr_param.vclmrc, lr_param.vcltp, lr_param.vclmdl
##   from agbkveic, outer agbkmarca, outer agbktip
##  where agbkveic.vclcoddig  = d_cts05m00.vclcoddig
##    and agbkmarca.vclmrccod = agbkveic.vclmrccod
##    and agbktip.vclmrccod   = agbkveic.vclmrccod
##    and agbktip.vcltipcod   = agbkveic.vcltipcod
##
##    start report rcts05m0001 to l_rep
##    output to report rcts05m0001(lr_param.*)
##    finish report rcts05m0001
##
##    if lr_param.vcllicnum is null or
##       lr_param.vcllicnum = ""    then
##       let lr_mens.para = "gerson.tierno@correioporto,",
##                          "joel.francisco@correioporto,",
##                          "teotonio.carlos@correioporto"
##       if lr_param.avsrcprd = 0 then ## -mensagem sem placa Para furto e roubo
##          ##let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ", Retirar
##          let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ",
##                                    " ", g_documento.succod    using "&&",
##                                    " ", g_documento.ramcod    using "&&&&",
##                                    " ", g_documento.aplnumdig using "<<<<<<<& &",
##                           "   Item.: ",g_documento.itmnumdig  using "&&"
##       else ##- mensagem se placa Para veiculos recuperados
##          ##let lr_mens.msg = "Comunicado de Localização de veículo para Apolice.: ",
##          let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ",
##                                    " ", g_documento.succod    using "&&",
##                                    " ", g_documento.ramcod    using "&&&&",
##                                    " ", g_documento.aplnumdig using "<<<<<<<& &",
##                           "   Item.: ",g_documento.itmnumdig  using "&&"
##       end if
##
##    else
##       if lr_param.avsrcprd = 0 then ##- Com placa Para Furto e Roubo
##          let lr_mens.para =  "alertavermelho@sinivem.com.br"
##       else ## - Com placa Para veículos recuperados
##          let lr_mens.para =  "recuperacao@sinivem.com.br"
##       end if
##    end if
##
##    let lr_mens.subject = l_rel
##    let lr_mens.sistema = "CT24HS"
##
##    ###let lr_mens.remet = "ct24hs.email@portoseguro.com.br"
##    let lr_mens.remet = "emailcorr.ct24hs@correioporto"
##
##    let l_cmd = ' echo "',lr_mens.msg clipped
##               ,'" | send_email.sh '
##               ,' -sys ',lr_mens.sistema clipped
##               ,' -r   ',lr_mens.remet clipped
##               ,' -a   ',lr_mens.para clipped
##               ,' -s  "',lr_mens.subject clipped, '"'
##               ,' -f   ',l_rep clipped
##
##    run l_cmd returning l_ret
##
##    if l_ret = 0  then
##       let l_cmd = "rm ", l_rep clipped
##       run l_cmd
##       let lr_retorno.msg_sinivem = 0
##    else
##       let lr_retorno.msg_sinivem = 1
##    end if
##
##    return lr_retorno.*
##
## end function

## #---------------------------#
## report rcts05m0001(lr_param)
## #---------------------------#
##
## define lr_param        record
##        vcllicnum       like datmservico.vcllicnum
##       ,sindat          like datmservicocmp.sindat
##       ,sinhor          like datmservicocmp.sinhor
##       ,cidnom          like datmlcl.cidnom
##       ,ufcod           like datmlcl.ufdcod
##       ,vclcordes       char (40)
##       ,vclchsnum       char (40)
##       ,vclmrc          char (30)
##       ,vcltp           char (10)
##       ,vclmdl          char (40)
##       ,data            char (10)
##       ,hora            char (05)
##       ,succod          like datrligapol.succod
##       ,aplnumdig       like datrligapol.aplnumdig
##       ,itmnumdig       like datrligapol.itmnumdig
##       ,ramcod          like datrligapol.ramcod
##       ,avsrcprd        smallint
##       ,lignum          like datmligacao.lignum
## end record
##
## define w_vclchsnum  char (21)
## define w_lignum     char (10)
## define i smallint
## define j smallint
##
##
##    output top    margin 0
##           left   margin 0
##           bottom margin 0
##           page   length 1
##
##
##    format
##       on every row
##       let w_lignum = lr_param.lignum
##
##       if lr_param.avsrcprd <> 0 then
##          print column 001,"<?xml version=""1.0"" encoding=""ISO-8859-1""?>"
##          print column 001,"<ROOT>"
##          print column 001,"<COD_INFORMANTE>5886</COD_INFORMANTE>"
##          print column 001,"<PLACA>",lr_param.vcllicnum clipped,"</PLACA>"
##          print column 001,"<OBS>",w_lignum clipped,"</OBS>"
##          print column 001,"</ROOT>"
##      else
##          let i = null
##          for i = 1 to length(lr_param.vclchsnum)
##             case lr_param.vclchsnum[i]
##                when " "
##                otherwise
##                let w_vclchsnum = w_vclchsnum clipped, lr_param.vclchsnum[i]
##             end case
##          end for
##          print column 001,"<?xml version=""1.0"" encoding=""ISO-8859-1""?>"
##          print column 001,"<ROOT>"
##          print column 001,"<COD_INFORMANTE>5886</COD_INFORMANTE>"
##          print column 001,"<PLACA>",lr_param.vcllicnum clipped,"</PLACA>"
##          print column 001,"<DATA_OCORRENCIA>",lr_param.sindat,"</DATA_OCORRENCIA>"
##          print column 001,"<HORA_OCORRENCIA>",lr_param.sinhor,"</HORA_OCORRENCIA>"
##          print column 001,"<CIDADE>",lr_param.cidnom clipped,"</CIDADE>"
##          print column 001,"<ESTADO>",lr_param.ufcod clipped,"</ESTADO>"
##          print column 001,"<MARCA>",lr_param.vclmrc clipped,"</MARCA>"
##          print column 001,"<MODELO>", lr_param.vcltp clipped, "-" clipped, lr_param.vclmdl clipped,"</MODELO>"
##          print column 001,"<COR>",lr_param.vclcordes clipped,"</COR>"
##          print column 001,"<CHASSI>",w_vclchsnum clipped,"</CHASSI>"
##          print column 001,"<RENAVAM></RENAVAM>"
##          print column 001,"<DATA_INFO_SEGURADORA>",lr_param.data clipped,"</DATA_INFO_SEGURADORA>"
##          print column 001,"<HORA_INFO_SEGURADORA>",lr_param.hora clipped,"</HORA_INFO_SEGURADORA>"
##          print column 001,"<OBS>",w_lignum clipped,"</OBS>"
##          print column 001,"</ROOT>"
##      end if
## end report

function cts05m00_ituran_tracker(l_atdsrvnum, l_atdsrvano)

define lr_mens        record
       sistema        char(10)
      ,remet          char(50)
      ,para           char(1000)
      ,cc             char(400)
      ,msg            char(400)
      ,subject        char(400)
end record

define l_atdsrvnum    like datmservico.atdsrvnum,
       l_atdsrvano    like datmservico.atdsrvano

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
define l_email char(35)
define l_rel   char(30)
define l_rep   char(100)
define l_cmd   char(3000)
define l_ret   smallint

    initialize lr_mens.* to null
    let l_email  = null
    let l_rel  = null
    let l_rep  = null

    if m_ituran = true then
       let lr_mens.para = "sinistros@ituran.com.br "
       let l_rel = "ituran", g_issk.funmat using '<<<<<<'
       ##let lr_mens.msg = "Comunicado de Furto/Roubo - ITURAN"
       let lr_mens.msg = "Comunicado de Furto/Roubo - ITURAN"

    else if m_tracker = true then
            let lr_mens.para = "recepcao@trackerdobrasil.com.br "
            let l_rel = "tracker", g_issk.funmat using '<<<<<<'
            ##let lr_mens.msg = "Comunicado de Furto/Roubo - TRACKER"
            let lr_mens.msg = "Comunicado de Furto/Roubo - TRACKER DO BRASIL"

         else if m_daf4 = true then
                 #let lr_mens.para = "ligia.mattge@correioporto,priscila.staingel@correioporto,carlos.ruiz@correioporto,jose.natal@correioporto "
                 let lr_mens.para = "Supervisao_seguranca@correioporto,CtOperacoes_Supervisao@correioporto,wilson.ponso@correioporto,fernando.pascoaloto@correioporto,miguel.fernandes@correioporto,luis.moreira@correioporto "
                 let l_rel = "daf4", g_issk.funmat using '<<<<<<'
                 ##let lr_mens.msg = "Comunicado de Furto/Roubo - DAF IV"
                 let lr_mens.msg = "Comunicado de Furto/Roubo - DAF IV"
              else if m_daf5 = true then

                 let lr_mens.para = cts05m00_buscaRemetenteDaf5()
                 let l_rel        = "daf5", g_issk.funmat using '<<<<<<'
                 let lr_mens.msg  = "Comunicado de Furto/Roubo - DAF V"
                   else
                     ## display "SAIDA ERRADA"
                     ## sleep 2
                     return
                   end if
              end if
         end if
    end if

    ## para testes
    #let lr_mens.para = "ligia.mattge@correioporto"
    #let lr_mens.cc  = " carlos.ruiz@correioporto, "
    #let l_rel = "ituran" , g_issk.funmat using '<<<<<<'

    let l_rep = "./", l_rel
    let lr_mens.cc  = " beatriz.ct24hs@correioporto,sofia.inhasz@correioporto "

    start report rcts05m0002 to  l_rep
    output to report rcts05m0002(l_atdsrvnum, l_atdsrvano)
    finish report rcts05m0002

   let lr_mens.subject = l_rel
   let lr_mens.sistema = "CT24HS"
   let lr_mens.remet = "emailcorr.ct24hs@correioporto"

  #PSI-2013-23297 - Inicio

   let l_mail.de = lr_mens.remet
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = lr_mens.para
   let l_mail.cc = lr_mens.cc
   let l_mail.cco = ""
   let l_mail.assunto = lr_mens.msg
   let l_mail.mensagem = ""
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "html"
   #display "Arquivo: ",lr_mens.subject

   call figrc009_attach_file(lr_mens.subject)
   #display "Arquivo anexado com sucesso"
   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro

   #PSI-2013-23297 - Fim
  if l_coderro = 0  then
     let l_cmd = "rm ", l_rep clipped
     run l_cmd
     error 'Email ituran/tracker/daf IV/daf V - enviado com sucesso'
     ## sleep 3
##else
##   call cts05m00_grava_email(l_atdsrvnum,
##                             l_atdsrvano,
##                             l_ret)
##   error 'Erro no envio do e-mail - AVISAR INFORMATICA'
  end if

end function

#---------------------------#
report rcts05m0002(l_atdsrvnum, l_atdsrvano)
#---------------------------#

define l_atdsrvnum    like datmservico.atdsrvnum,
       l_atdsrvano    like datmservico.atdsrvano,
       l_c24srvdsc    like datmservhist.c24srvdsc

   output top    margin 0
          left   margin 0
          bottom margin 0
          page   length 1

   format
      on every row
         let l_c24srvdsc = null

         print column 001,"**** NAO RESPONDER O E-MAIL AO REMETENTE ****"
         print column 001,"** ENVIAR PARA sofia.inhasz@portoseguro.com.br **"

         skip 1 line

         print column 001,"Numero do Servico: 11/",
                          l_atdsrvnum using "&&&&&&&","-",
                          l_atdsrvano using "&&"

         print column 001,"Veiculo : ",
                          d_cts05m00.vcldes

         if d_cts05m00.vcllicnum is null then
            print column 001,"Placa do Veiculo : SEM PLACA"
         else
            print column 001,"Placa do Veiculo : ",
                             d_cts05m00.vcllicnum clipped
         end if

         print column 001,"Nome do segurado : ",
                          d_cts05m00.nom

         print column 001,"Data/Hora do Sinistro   : ",
                          d_cts05m00.sindat, "  ",
                          d_cts05m00.sinhor

         print column 001,"Data/Hora da Comunicacao: ",m_atddat, "  ",
                          m_atdhor

         print column 001,"Cidade/Estado: ", a_cts05m00[1].cidnom clipped, "/",
                                             a_cts05m00[1].ufdcod

         print column 001,"Resumo: "

         declare c_cts05m00_005 cursor for
                 select c24srvdsc, c24txtseq from datmservhist
                   where atdsrvnum = l_atdsrvnum
                     and atdsrvano = l_atdsrvano
                     order by c24txtseq
         foreach c_cts05m00_005 into l_c24srvdsc
                 print column 03, l_c24srvdsc clipped
         end foreach

end report

####-----------------------------------------#
###function cts05m00_grava_email(lr_parametro)
####-----------------------------------------#
###
###  define lr_parametro record
###         atdsrvnum    like datmservico.atdsrvnum,
###         atdsrvano    like datmservico.atdsrvano,
###         ret_comando  integer
###  end record
###
###  define l_data      date,
###         l_hora      datetime hour to minute,
###         l_relsgl    like igbmparam.relsgl,
###         l_relpamtxt like igbmparam.relpamtxt,
###         l_relpamseq like igbmparam.relpamseq,
###         l_relpamtip like igbmparam.relpamtip
###
###  if m_cts05m00_prep is null or
###     m_cts05m00_prep <> true then
###     call cts05m00_prepare()
###  end if
###
###  let l_relpamseq = null
###  let l_relpamtip = 1
###  let l_data      = today
###  let l_hora      = current
###  let l_relsgl    = "CTS05M00"
###  let l_relpamtxt = l_data                   using "dd/mm/yyyy"  clipped, " ",
###                    l_hora                                       clipped, " ",
###                    lr_parametro.atdsrvnum   using "<<<<<<<<<&"  clipped, "-",
###                    lr_parametro.atdsrvano   using "&&"          clipped, " ",
###                    lr_parametro.ret_comando using "<<<<<<<<&"
###
###  # --> BUSCA A MAIOR SEQUENCIA DA IGBMPARAM
###  open c_cts05m00_002 using l_relsgl
###  fetch c_cts05m00_002 into l_relpamseq
###  close c_cts05m00_002
###
###  if l_relpamseq is null then
###     let l_relpamseq = 0
###  end if
###
###  let l_relpamseq = l_relpamseq + 1
###
###  # VERIFICA SE NAO ESTOUROU A CAPACIDADE DO decimal(5,0)
###  if l_relpamseq <> 99999 then
###     # --> GRAVA NA TABELA igbmparam
###     execute p_cts05m00_002 using l_relsgl, l_relpamseq, l_relpamtip, l_relpamtxt
###  end if
###
###end function
