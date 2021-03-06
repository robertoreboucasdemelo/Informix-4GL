#############################################################################
# Nome do Modulo: CTS06G03                                         Marcelo  #
#                                                                  Gilberto #
# Digitacao padronizada de enderecos para laudos de servicos       Mar/1999 #
# ######################################################################### #
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 10/06/1999  PSI 7547-7   Gilberto     Alteracao da posicao na tela do     #
#                                       campo BAIRRO.                       #
#---------------------------------------------------------------------------#
# 02/09/1999  PSI 9163-4   Wagner       Incluir na input o campo CEP como   #
#                                       mandatorio e nao obrigatorio para   #
#                                       acesso ao endereco.                 #
#---------------------------------------------------------------------------#
# 09/09/1999  PSI 9119-7   Wagner       Incluir acesso/manutencao ao        #
#                                       historico com tecla F6.             #
#---------------------------------------------------------------------------#
# 26/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 25/09/2000  PSI 104752   Marcus       Inclusao de coordenadas Cidades BR  #
#                                       Acionamento Prestadores sem GPS     #
#---------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da    #
#                                       oficina destino para laudos         #
#---------------------------------------------------------------------------#
# 22/01/2001               Raji         Ampliacao do campo Ponto de Referen-#
#                                       cia.                                #
#---------------------------------------------------------------------------#
# 26/03/2001  PSI 124354   Ruiz         Mostrar a oficina beneficio (f7)    #
#---------------------------------------------------------------------------#
# 27/04/2001               Marcus       Inclusao de chamadas de funcoes     #
#                                       genericas de mapas digitais         #
#---------------------------------------------------------------------------#
# 24/10/2001  PSI 140996   Ruiz         Disponibilizar cadastro oficina     #
#                                       garantia-mecanica p/ clscod=96.     #
#---------------------------------------------------------------------------#
# 21/01/2002  AS           Ruiz         Quando nao encontrar cep da rua     #
#                                       considerar o cep da cidade.         #
#---------------------------------------------------------------------------#
# 05/04/2002  PSI 149705   Marcus       Trazer Bairros automaticamente das  #
#                                       telas de MAPA e GUIA POSTAL.        #
#---------------------------------------------------------------------------#
# 19/07/2002  PSI 156558   Ruiz         Mostrar qdo oficina for OBSERVACAO. #
#---------------------------------------------------------------------------#
# 04/06/2003  PSI 170275   Ruiz         Helio - OSF 19968 Informar ao       #
#                                       atendente se a apolice tem direito  #
#                                       ao beneficio ou nao.                #
#---------------------------------------------------------------------------#
# 10/03/2004  Marcio,Meta    PSI183644 Inibir linhas do programa            #
#                            OSF 3340                                       #
#...........................................................................#
#                        * * * A L T E R A C A O * * *                      #
#...........................................................................#
#Data        Autor Fabrica   OSF/PSI      Alteracao                         #
#----------  -------------  ------------- ----------------------------------#
#16/03/2004  Sonia Sasaki   33685         Disponibilizar cadastro de locais #
#                                         fixos no atendimento.Pesquisar lo-#
#                                         cais especiais.Nao executar a par-#
#                                         te de busca de coordenadas em ca -#
#                                         so de local especial.             #
#08/04/2004  Sonia Sasaki   33685-Adendo  Inicializar a variavel flag_local_#
#                                         especial igual a N                #
#                                                                           #
#12/04/2004  Mariana        34437         Carregar coordenadas do bairro    #
#                                         caso nao seja encontrada as coorde#
#                                         nadas do logradouro.              #
#---------------------------------------------------------------------------#
#14/04/2004  Cesar Lucca    CT 200352     Incluir condicao no if            #
#---------------------------------------------------------------------------#
# 22/06/2004  OSF 37184    Teresinha S. Alterar chamada funcao ctn18c00 pas #
#                                       sando zero como cod do motivo da lo #
#                                       cacao ao inves da flag de oficinas  #
#---------------------------------------------------------------------------#
# 30/05/2005  PSI 192007   JUNIOR(META) Inclusao de tela para carregar dados#
#                                       do segurado.                        #
#                                                                           #
#---------------------------------------------------------------------------#
# 19/05/2005  Alinne, Meta  PSI 191108  Inclusao da chamada das funcoes:    #
#                                       ctc17m02_consiste_depto_via()       #
#                                       ctc17m02_obter_via()                #
#                                       ctc17m02_popup_via()                #
#---------------------------------------------------------------------------#
# 23/01/2006 Priscila                   Cadastro vias emergencias           #
#---------------------------------------------------------------------------#
# 22/02/2006 Priscila     PSI 198390    Inclusao do parametro cidcep na cham#
#                                       ada da funcao ctn18c00              #
#---------------------------------------------------------------------------#
# 02/03/2006 Priscila    Zeladoria      Buscar data e hora do banco de dados#
# 20/07/2006 Ligia       PSI 202045     Literal Ponto Ref p/Period ou Ponto #
# 21/11/2006 Ligia       PSI 205206     ciaempcod                           #
#---------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- --------- ----------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32             #
# 09/10/07   Ligia Mattge            acertos na indexacao                    #
# 30/04/08   Norton, Meta  psi221112 Alteracao no nome da tabela gtakram     #
# 13/08/2009 Sergio Burini PSI244236 Inclus�o do Sub-Dairro                  #
# 24/08/2009 Sergio Burini PSI240591 integra��o Porto Socorro x DAF          #
# 29/12/2009 Fabio Costa   PSI198404 Tratar fim de linha windows Ctrl+M      #
# 02/03/2010 Adriano S     PSI 252891    Inclusao do padrao idx 4 e 5        #
# 04/11/2011 Marcos Goes PSI2011-18556 Inclusao de Oficinas Referenc. Itau   #
# 28/03/2012 Sergio Burini  PSI-2010-01968/PB                                #
# 19/02/2014 Fabio, Fornax PSI-2014-03931IN Melhorias indexacao Fase 01      #
#----------------------------------------------------------------------------#
# 09/04/2014 CDS Egeu     PSI-2014-02085   Situa��o Local de Ocorr�ncia      #
#----------------------------------------------------------------------- ----#
# 13/05/2015 Roberto Fornax                Mercosul                          #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_hostname   char(12)
define m_server     char(05)
define m_flagsemidx smallint
define m_prep       smallint
define m_lgdtip     like datmlcl.lgdtip
define m_lgdnom     like datmlcl.lgdnom

define m_subbairro array[03] of record
       brrnom      like datmlcl.lclbrrnom
end record

define m_km      like datmlcl.lgdnum
define m_sentido char(60)
define m_pista   char(60)
define m_sql     char(300)

#--------------------------------------------------------------------------
function cts06g03_prepare()
#--------------------------------------------------------------------------
 define l_sql   char(500)

 whenever error continue
 let l_sql = "select glaklgd.lgdtip   ,",
             "       glaklgd.lgdnom   ,",
             "       glaklgd.cidcod   ,",
             "       glaklgd.brrcod    ",
             "  from glaklgd           ",
             " where glaklgd.lgdcep    = ? ",
             "   and glaklgd.lgdcepcmp = ? "
 prepare p_cts06g03_001 from l_sql
 declare c_cts06g03_001 cursor for p_cts06g03_001
 whenever error stop
 #----------------------------------------------
 whenever error continue
 let l_sql = "select glakcid.cidnom   ,",
             "       glakcid.ufdcod    ",
             "  from glakcid           ",
             " where glakcid.cidcod    = ? "

 prepare p_cts06g03_002 from l_sql
 declare c_cts06g03_002 cursor for p_cts06g03_002
 whenever error stop
 #----------------------------------------------
 whenever error continue
 let l_sql = "select glakbrr.brrnom    ",
             "  from glakbrr           ",
             " where glakbrr.cidcod    = ? ",
             "   and glakbrr.brrcod    = ? "

 prepare p_cts06g03_003 from l_sql
 declare c_cts06g03_003 cursor for p_cts06g03_003
 whenever error stop
 #-----------------------------------------------
 whenever error continue
 let l_sql = " select c24astcod ",
             " from datmligacao ",
             " where atdsrvnum = ? ",
             " and atdsrvano = ? ",
             " and lignum = (select min(lignum) ",
                                 " from datmligacao ",
                                " where atdsrvnum = ? ",
                                  " and atdsrvano = ?) "

 prepare p_cts06g03_004 from l_sql
 declare c_cts06g03_004 cursor for p_cts06g03_004
 whenever error stop


whenever error continue
 let l_sql = " select b.segnumdig ",
             " from rsamseguro a ",
             "  ,rsdmdocto  b ",
             " where a.succod    = ? ",
             " and a.aplnumdig = ? ",
             " and a.ramcod    = ? ",
             " and b.sgrorg    = a.sgrorg ",
             " and b.sgrnumdig = a.sgrnumdig ",
             " and b.prpstt   in (19,65,66,88) ",
             " order by b.dctnumseq desc "

 prepare p_cts06g03_005 from l_sql
 declare c_cts06g03_005 cursor for p_cts06g03_005
 whenever error stop

 whenever error continue
 let l_sql = "select endcmp ",
             "from gsakend ",
             "where gsakend.segnumdig = ? ",
             "and gsakend.endfld = '1' "
 prepare p_cts06g03_006 from l_sql
 declare c_cts06g03_006 cursor for p_cts06g03_006
 whenever error stop
 let l_sql = "select datkmpacid.mpacidcod    ",
              "  from datkmpacid           ",
              " where datkmpacid.cidnom    = ? ",
              "   and datkmpacid.ufdcod    = ? "

 prepare sel_datkmpacid from l_sql
 declare c_datkmpacid cursor for sel_datkmpacid

 let l_sql = "select datkmpabrr.lclltt,        ",
             "       datkmpabrr.lcllgt         ",
             "   from datkmpabrr               ",
             "  where datkmpabrr.brrnom    = ? ",
             "    and datkmpabrr.mpacidcod = ? "

 prepare sel_datkmpabrr from l_sql
 declare c_datkmpabrr cursor for sel_datkmpabrr

 let l_sql = "select datkmpabrrsub.lclltt,        ",
             "       datkmpabrrsub.lcllgt         ",
             "   from datkmpabrrsub               ",
             "  where datkmpabrrsub.mpacidcod = ? ",
             "    and datkmpabrrsub.brrsubnom = ? "

 prepare sel_datkmpabrrsub from l_sql
 declare c_datkmpabrrsub cursor for sel_datkmpabrrsub

 let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco" '
            , '    and cpodes = ?               '
  prepare p_cts06g03_008 from l_sql
  declare c_cts06g03_008 cursor for p_cts06g03_008

  let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco_nav" '
            , '    and cpodes = ?               '
  prepare p_cts06g03_009 from l_sql
  declare c_cts06g03_009 cursor for p_cts06g03_009

#Inicio - Situa��o local de ocorr�ncia
 let l_sql = ' select cpocod                '
            ,'   from iddkdominio           '
            ,'  where cponom = "LOCALRISCO" '
            ,'    and cpodes = ?            '
  prepare p_cts06g03_010 from l_sql
  declare c_cts06g03_010 cursor for p_cts06g03_010

 let l_sql = ' select count(*)                '
            ,'   from iddkdominio           '
            ,'  where cponom = "SRVATDLCLRSC" '
            ,'    and cpocod = ?            '
  prepare p_cts06g03_011 from l_sql
  declare c_cts06g03_011 cursor for p_cts06g03_011
#Fim - Situa��o local de ocorr�ncia

 let m_prep = true


end function

#-----------------------------------------------------------
function cts06g03(param, d_cts06g03, hist_cts06g03,lr_emeviacod)
#-----------------------------------------------------------

 define param      record
        c24endtip  like datmlcl.c24endtip,
        atdsrvorg  like datmservico.atdsrvorg,
        ligcvntip  like datmligacao.ligcvntip,
        hoje       char (10),
        hora       char (05)
 end record

 define d_cts06g03   record
        lclidttxt    like datmlcl.lclidttxt,
        cidnom       like datmlcl.cidnom,
        ufdcod       like datmlcl.ufdcod,
        brrnom       like datmlcl.brrnom,
        lclbrrnom    like datmlcl.lclbrrnom,
        endzon       like datmlcl.endzon,
        lgdtip       like datmlcl.lgdtip,
        lgdnom       like datmlcl.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        lclltt       like datmlcl.lclltt,
        lcllgt       like datmlcl.lcllgt,
        lclrefptotxt like datmlcl.lclrefptotxt,
        lclcttnom    like datmlcl.lclcttnom,
        dddcod       like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum,
        c24lclpdrcod like datmlcl.c24lclpdrcod,
        ofnnumdig    like sgokofi.ofnnumdig,
        celteldddcod like datmlcl.celteldddcod,
        celtelnum    like datmlcl.celtelnum,
        endcmp       like datmlcl.endcmp
 end record
 define d1_cts06g03  record
        obsofic      char(22),
        staofic      char(12),
        des          char(05)
 end record

 define salva      record
        cidnom     like datmlcl.cidnom,
        ufdcod     like datmlcl.ufdcod,
        lgdtip     like datmlcl.lgdtip,
        lgdnom     like datmlcl.lgdnom,
        lgdnum     like datmlcl.lgdnum,
        brrnom     like datmlcl.brrnom,
        lclbrrnom  like datmlcl.lclbrrnom,
        lclltt     like datmlcl.lclltt,
        lcllgt     like datmlcl.lcllgt,
        endcmp     like datmlcl.endcmp
 end record

 define hist_cts06g03 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws         record
    cepflg         char (01),
    retflg         char (01),
    locflg         char (01),
    cidcod         like glakcid.cidcod,
    ufdcod         like glakest.ufdcod,
    brrcod         like glakbrr.brrcod,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    brrnom         like datmlcl.brrnom,
    cpodes         like iddkdominio.cpodes,
    mpacidcod      like datkmpacid.mpacidcod,
    mpacrglgdflg   like datkmpacid.mpacrglgdflg,
    gpsacngrpcod   like datkmpacid.gpsacngrpcod,
    cabtxt         char (68),
    monta_sql      char (300),
    confirma       char (01),
    benef          char (01),
    benefx         char (01),
    ofnnumdig      like datmlcl.ofnnumdig,
    ptoref1        char (50),
    ptoref2        char (50),
    ptoref3        char (50),
    ptoref4        char (50),
    result         dec  (1,0),
    clscod         char (03),
    cidcep         like glakcid.cidcep,
    cidcepcmp      like glakcid.cidcepcmp,
    prompt_key     char(01),
    ofnstt         like sgokofi.ofnstt,
    lclltt_cid     like datmlcl.lclltt,
    lcllgt_cid     like datmlcl.lcllgt,
    ctgtrfcod      like abbmcasco.ctgtrfcod, # osf 19968
    compleme       char(20),
    flgcompl       char(01),
    ramcod         like gtakram.ramcod,
    ok             char(01),
    c24astcod      like datmligacao.c24astcod,
    endres         char(01),
#   decide_via     char(1), - #Situa��o local de ocorr�ncia
    nome           char(60),
    cgccpf         char(20),
    pessoa         char(01),
    email          char(100),
    vclchsfnl      like adbmbaixa.vclchsfnl,
    vcllicnum      like adbmbaixa.vcllicnum,
    msgerr         char(100),
    codpais        char(11),
    despais        char(40),
    erro           smallint,
    ocrlclstt      char(01), #Situa��o local de ocorr�ncia
    txtocrlcl      char(15)  #Situa��o local de ocorr�ncia
 end record

 define l_c24fxolclcod             like datkfxolcl.c24fxolclcod
       ,l_flag_local_especial      char(1)
       ,l_orides                   char(030)
       ,l_count_auto               smallint  #Situa��o local de ocorr�ncia
       ,l_flag_auto                char(01)  #Situa��o local de ocorr�ncia

 define l_lclltt    like datmlcl.lclltt
       ,l_lcllgt    like datmlcl.lcllgt

 ### PSI 192007 - JUNIOR(META)

 define  l_resultado  smallint
        ,l_ret        smallint
        ,l_mensagem   char(60)
        ,l_segnumdig  like abbmdoc.segnumdig
        ,l_erro      smallint

 define  l_gsakend  record
         segnumdig  like gsakend.segnumdig,
         endfld     like gsakend.endfld,
         endlgdtip  like gsakend.endlgdtip,
         endlgd     like gsakend.endlgd,
         endnum     like gsakend.endnum,
         endcmp     like gsakend.endcmp,
         endcepcmp  like gsakend.endcepcmp,
         endbrr     like gsakend.endbrr,
         endcid     like gsakend.endcid,
         endufd     like gsakend.endufd,
         endcep     like gsakend.endcep,
         dddcod     like gsakend.dddcod,
         teltxt     like gsakend.teltxt,
         tlxtxt     like gsakend.tlxtxt,
         factxt     like gsakend.factxt,
         atlult     like gsakend.atlult
 end record

 ### PSI 192007 - JUNIOR(META) - FIM

  define lr_ctc71m01_ret record
         c24fxolclcod   like datkfxolcl.c24fxolclcod,
         lclidttxt      like datmlcl.lclidttxt,
         lgdtip         like datmlcl.lgdtip,
         lgdnom         like datmlcl.lgdnom,
         compleme       char(20),
         lgdnum         like datmlcl.lgdnum,
         lgdcep         like datmlcl.lgdcep,
         lgdcepcmp      like datmlcl.lgdcepcmp,
         brrnom         like datmlcl.brrnom,
         cidnom         like datmlcl.cidnom,
         ufdcod         like datmlcl.ufdcod,
         endzon         like datmlcl.endzon,
         c24lclpdrcod   like datmlcl.c24lclpdrcod,
         lclltt         like datmlcl.lclltt,
         lcllgt         like datmlcl.lcllgt
 end record

 define lr_salva    record
         lgdcep     like datmlcl.lgdcep,
         lgdcepcmp  like datmlcl.lgdcepcmp,
         lclidttxt  like datmlcl.lclidttxt,
         emeviacod  like datkemevia.emeviacod
#        emeviades     like datkemevia.emeviades  #Situa��o local de ocorr�ncia
 end record

 define lr_emeviacod record
        emeviacod    like datkemevia.emeviacod
 end record

 define #l_via_desc   char(013), - #Situa��o local de ocorr�ncia
        l_doc_handle integer,
        l_cep        char(10),
        l_ind        smallint,
        l_ind2       smallint,
        l_status     smallint,
        l_oriprc     smallint
#Inicio - Situa��o local de ocorr�ncia
{
 define lr_ctc17m02 record
        emeviades  like datkemevia.emeviades
       ,emeviapri  char(005)
 end record
}
#Fim - Situa��o local de ocorr�ncia

  define lr_ctx25g05  record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

 define entrou       record ##ligia - retirar - copia do d_cts06g03
        lclidttxt    like datmlcl.lclidttxt,
        cidnom       like datmlcl.cidnom,
        ufdcod       like datmlcl.ufdcod,
        brrnom       like datmlcl.brrnom,
        lclbrrnom    like datmlcl.lclbrrnom,
        endzon       like datmlcl.endzon,
        lgdtip       like datmlcl.lgdtip,
        lgdnom       like datmlcl.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        lclltt       like datmlcl.lclltt,
        lcllgt       like datmlcl.lcllgt,
        lclrefptotxt like datmlcl.lclrefptotxt,
        lclcttnom    like datmlcl.lclcttnom,
        dddcod       like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum,
        c24lclpdrcod like datmlcl.c24lclpdrcod,
        ofnnumdig    like sgokofi.ofnnumdig,
        celteldddcod like datmlcl.celteldddcod,
        celtelnum    like datmlcl.celtelnum,
        endcmp       like datmlcl.endcmp
 end record

 define lr_cts06g03 record
     cidnom like datmlcl.cidnom,
     ufdcod like datmlcl.ufdcod
 end record

 define lr_daf record
     status_ret smallint,
     ufdcod     like datkmpacid.ufdcod,
     cidnom     like datkmpacid.cidnom,
     lgdtip     like datkmpalgd.lgdtip,
     lgdnom     like datkmpalgd.lgdnom,
     lgdnomalt  like datkmpalgd.lgdnom,
     brrnom     like datkmpabrr.brrnom,
     lclltt     like datmlcl.lclltt,
     lcllgt     like datmlcl.lcllgt,
     numero     integer
 end record

 define lr_idx_brr    record
     lclltt       like datmlcl.lclltt,
     lcllgt       like datmlcl.lcllgt,
     c24lclpdrcod like datmlcl.c24lclpdrcod
 end record
 define l_c24lclpdrcod like datmlcl.c24lclpdrcod,
        l_fondafinf    smallint

 define  l_tplougr          char(100)
        ,l_cabec            char(30)
        ,l_pontoreferencia  char(350)
        ,l_tpmarginal       char(100)


 initialize d1_cts06g03.* to null      #OSF 19968
# initialize lr_ctc17m02.* to null - #Situa��o local de ocorr�ncia
 initialize lr_ctx25g05.* to null 
 initialize salva.* to null
 initialize l_gsakend.* to null  
 initialize lr_emeviacod.* to null
 initialize m_subbairro to null
 initialize lr_idx_brr.* to null
 
 initialize l_c24lclpdrcod to  null    
 let l_c24lclpdrcod = d_cts06g03.c24lclpdrcod
 initialize l_resultado    to  null
 initialize l_mensagem     to  null
 initialize l_doc_handle   to  null
 initialize l_cep          to  null
 initialize l_status       to  null
 initialize l_oriprc to null
 initialize l_fondafinf    to null
 initialize l_erro         to null
 initialize l_count_auto   to null #Situa��o local de ocorr�ncia
 initialize l_flag_auto    to null #Situa��o local de ocorr�ncia
 initialize l_flag_local_especial to null
 let l_flag_local_especial = "N" #let l_via_desc = null - #Situa��o local de ocorr�ncia
 initialize l_ind  to null
 initialize l_ind2 to null
 initialize m_flagsemidx to null
 let m_flagsemidx = false
 initialize l_pontoreferencia to null
 initialize l_tplougr         to null
 initialize l_cabec           to null
 initialize l_tpmarginal      to null
 initialize m_lgdtip          to null
 initialize m_lgdnom          to null
 
 initialize  ws.*, lr_daf.*, lr_cts06g03.*, entrou.*  to  null
 
 let entrou.*  = d_cts06g03.* ##ligia - retirar

 if m_prep is null or
    m_prep = false or
    m_prep = " " then
    call cts06g03_prepare()
 end if

 {let ws.monta_sql = "select glaklgd.lgdtip   ,",
              "       glaklgd.lgdnom   ,",
              "       glaklgd.cidcod   ,",
              "       glaklgd.brrcod    ",
              "  from glaklgd           ",
              " where glaklgd.lgdcep    = ? ",
              "   and glaklgd.lgdcepcmp = ? "
 prepare p_cts06g03_001 from ws.monta_sql
 declare c_cts06g03_001 cursor for p_cts06g03_001
 #----------------------------------------------
 let ws.monta_sql = "select glakcid.cidnom   ,",
              "       glakcid.ufdcod    ",
              "  from glakcid           ",
              " where glakcid.cidcod    = ? "

 prepare p_cts06g03_002 from ws.monta_sql
 declare c_cts06g03_002 cursor for p_cts06g03_002
 #----------------------------------------------
 let ws.monta_sql = "select glakbrr.brrnom    ",
              "  from glakbrr           ",
              " where glakbrr.cidcod    = ? ",
              "   and glakbrr.brrcod    = ? "

 prepare p_cts06g03_003 from ws.monta_sql
 declare c_cts06g03_003 cursor for p_cts06g03_003
 #-----------------------------------------------
 let ws.monta_sql = " select c24astcod ",
                " from datmligacao ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and lignum = (select min(lignum) ",
                                 " from datmligacao ",
                                " where atdsrvnum = ? ",
                                  " and atdsrvano = ?) "

 prepare p_cts06g03_004 from ws.monta_sql
 declare c_cts06g03_004 cursor for p_cts06g03_004

 whenever error continue
 let ws.monta_sql = " select b.segnumdig ",
                " from rsamseguro a ",
                   "  ,rsdmdocto  b ",
               " where a.succod    = ? ",
                 " and a.aplnumdig = ? ",
                 " and a.ramcod    = ? ",
                 " and b.sgrorg    = a.sgrorg ",
                 " and b.sgrnumdig = a.sgrnumdig ",
                 " and b.prpstt   in (19,65,66,88) ",
                 " order by b.dctnumseq desc "

 prepare p_cts06g03_005 from ws.monta_sql
 declare c_cts06g03_005 cursor for p_cts06g03_005
 whenever error stop}

 if  param.c24endtip = 1 then
     whenever error continue
     create temp table tmp_idx
          (srvhstseq smallint,
           endlgdtip char(10),
           endlgd    char(60),
           endlgdnum smallint,
           endbrrnom char(40),
           ciddes    char(45),
           ufdcod    char(2),
           lclltt    decimal(8,6),
           lcllgt    decimal(8,6)) with no log
     whenever error stop
 end if


#-------------------------------
#Verifica o agrupamento
#-------------------------------
 
  if d_cts06g03.lclidttxt = "BRASIL" then
			 let d1_cts06g03.des  = "Local Fixo"
			 let d_cts06g03.ufdcod = ""
			 let d_cts06g03.lclidttxt = ""
  else
			 
			 if (g_documento.c24astcod = 'M15' or
           g_documento.c24astcod = 'M20' or
           g_documento.c24astcod = 'M23' or
           g_documento.c24astcod = 'M33' or
           g_documento.c24astcod = 'KM1' or    
           g_documento.c24astcod = 'KM2' or    
           g_documento.c24astcod = 'KM3') then 
              
                   
			   if d_cts06g03.ufdcod = "EX" and
			      d_cts06g03.lclidttxt is null then
			      let d_cts06g03.lclidttxt = d_cts06g03.cidnom
			      let d_cts06g03.cidnom = ""
			   else
			     if d_cts06g03.ufdcod <> "EX" or 
			     	  d_cts06g03.ufdcod is null then
			         let m_sql = "select cpocod "
						                      ,",cpodes "
						                ,"from datkdominio "
						               ,"where cponom = 'paises_mercosul' "
						                       ,"order by cpodes "
						      call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",
                                       'N',m_sql,
                                       "",'D')
                            returning ws.erro,
									           ws.codpais,
									           ws.despais

					 let d_cts06g03.ufdcod = "EX"
					 let d_cts06g03.lclidttxt = ws.despais
				end if
			 end if
		 end if
		end if

 #------------------------------------------------------------------------
 # Verifica tipo de local a ser informado
 #------------------------------------------------------------------------
 if param.atdsrvorg    is null  or
    param.ligcvntip is null  then
    error " Parametros nao informados. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
    return d_cts06g03.*, "N", hist_cts06g03.*,lr_emeviacod.emeviacod
 #Inicio - Situa��o local de ocorr�ncia
 else  #Possui origem
    open  c_cts06g03_011 using param.atdsrvorg
    fetch c_cts06g03_011 into l_count_auto
    if l_count_auto = 0 then
       let l_flag_auto = 'N' #Servi�o n�o � auto
    else
       let l_flag_auto = 'S' #Servi�o auto
    end if
 #Fim - Situa��o local de ocorr�ncia
 end if

 if param.ligcvntip  =  89   or      ## Avis Rent a Car
    param.ligcvntip  =  90   or      ## Mega Rent a Car
    param.ligcvntip  =  91   or      ## Seg Car Locadora
    param.ligcvntip  =  92   then    ## Repar Locadora
    let ws.locflg = "S"
 else
    let ws.locflg = "N"
 end if

 let ws.retflg = "N"

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude

    select ctgtrfcod into ws.ctgtrfcod from abbmcasco
     where abbmcasco.succod    = g_documento.succod     and
           abbmcasco.aplnumdig = g_documento.aplnumdig  and
           abbmcasco.itmnumdig = g_documento.itmnumdig  and
           abbmcasco.dctnumseq = g_funapol.autsitatu

    -------[ categorias tarifarias que oferecem desconto ou carro extra ]-----
    let ws.benefx = "N"
    if ws.ctgtrfcod = 10 or
       ws.ctgtrfcod = 14 or
       ws.ctgtrfcod = 16 or
       ws.ctgtrfcod = 22 or
       ws.ctgtrfcod = 80 or
       # inclusao dessas categorais por solicitacao da Bia. 25/04/07
       ws.ctgtrfcod = 11 or
       ws.ctgtrfcod = 15 or
       ws.ctgtrfcod = 17 or
       ws.ctgtrfcod = 20 or
       ws.ctgtrfcod = 21 or
       ws.ctgtrfcod = 23 or
       ws.ctgtrfcod = 81 then
       let ws.benefx = "S"
    end if              # osf 19968

 else
    if g_documento.ciaempcod = 35 then ## Azul Seguros
       call cts42g00_doc_handle(g_documento.succod, g_documento.ramcod,
                                g_documento.aplnumdig, g_documento.itmnumdig,
                                g_documento.edsnumref)
            returning l_resultado, l_mensagem, l_doc_handle
    end if
 end if


 #------------------------------------------------------------------------
 # Verifica tipo de local a ser informado
 #------------------------------------------------------------------------
 if param.c24endtip is null  then
    error " Tipo do local nao informado. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg, ws.mpacidcod, ws.cidcod)
    return d_cts06g03.*, ws.retflg, hist_cts06g03.*,lr_emeviacod.emeviacod
 end if

 if param.atdsrvorg = 18 then
    let param.c24endtip  = param.c24endtip + 3
 end if

 select cpodes
   into ws.cpodes
   from iddkdominio
  where iddkdominio.cponom  =  "c24endtip"
    and iddkdominio.cpocod  =  param.c24endtip

  if param.atdsrvorg = 18 then
     if param.c24endtip = 5 then
        let param.c24endtip  = param.c24endtip - 4
     else
        if param.c24endtip = 6 then
           let param.c24endtip  = param.c24endtip - 5
        else
           let param.c24endtip  = param.c24endtip - 3
        end if
     end if
 end if

 if sqlca.sqlcode  <>  0    then
    error " Tipo do local (", param.c24endtip  using "<<<<&",
          ") nao cadastrado. AVISE A INFORMATICA!"
    call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
    return d_cts06g03.*, ws.retflg, hist_cts06g03.*,lr_emeviacod.emeviacod
 end if

 let ws.cabtxt  =  "                 Informacoes do local de ", downshift(ws.cpodes)

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude

    #------------------------------------------------------------------------
    # Verifica se apolice tem clausula 096
    #------------------------------------------------------------------------
     select clscod into ws.clscod
         from abbmclaus
        where succod    = g_documento.succod
          and aplnumdig = g_documento.aplnumdig
          and itmnumdig = g_documento.itmnumdig
          and dctnumseq = g_funapol.dctnumseq
          and clscod    = "096"
 end if

 #------------------------------------------------------------------------
 # Salva dados sobre o local
 #------------------------------------------------------------------------
 initialize salva.*  to null
 let salva.cidnom     =  d_cts06g03.cidnom  #ligia 09/10/07
 let salva.ufdcod     =  d_cts06g03.ufdcod
 let salva.lgdtip     =  d_cts06g03.lgdtip
 let salva.lgdnom     =  d_cts06g03.lgdnom
 let salva.lgdnum     =  d_cts06g03.lgdnum
 let salva.brrnom     =  d_cts06g03.brrnom
 let salva.lclbrrnom  =  d_cts06g03.lclbrrnom
 let salva.lclltt     =  d_cts06g03.lclltt
 let salva.lcllgt     =  d_cts06g03.lcllgt
 let salva.endcmp     =  d_cts06g03.endcmp

 let d1_cts06g03.des  = "Local"
 if param.atdsrvorg   = 16 and
    d_cts06g03.ufdcod = "EX" then
    let d1_cts06g03.des = "Pais"
 end if
 if (param.atdsrvorg = 1 or
     param.atdsrvorg = 2 or        # Mercosul
     param.atdsrvorg = 4) and
		 d_cts06g03.ufdcod = "EX" then
		 let d1_cts06g03.des = "Pais"
 end if
 call cty22g02_retira_acentos(d_cts06g03.cidnom)
                                returning d_cts06g03.cidnom
 let d_cts06g03.cidnom = upshift(d_cts06g03.cidnom)

 call cty22g02_retira_acentos(d_cts06g03.ufdcod)
                                 returning d_cts06g03.ufdcod
 let d_cts06g03.ufdcod = upshift(d_cts06g03.ufdcod)

 call cty22g02_retira_acentos(d_cts06g03.lgdtip)
                                 returning d_cts06g03.lgdtip
 let d_cts06g03.lgdtip = upshift(d_cts06g03.lgdtip)

 call cty22g02_retira_acentos(d_cts06g03.lgdnom)
                                 returning d_cts06g03.lgdnom
 let d_cts06g03.lgdnom = upshift(d_cts06g03.lgdnom)

 call cty22g02_retira_acentos(d_cts06g03.brrnom )
                                 returning d_cts06g03.brrnom
 let d_cts06g03.brrnom  = upshift(d_cts06g03.brrnom )

 call cty22g02_retira_acentos(d_cts06g03.lclbrrnom)
                                 returning d_cts06g03.lclbrrnom
 let d_cts06g03.lclbrrnom = upshift(d_cts06g03.lclbrrnom)

 open window cts06g03 at 08,03 with form "cts06g03"
      attribute(border, form line 1, message line last, comment line last - 1)

 display by name ws.cabtxt
 display by name d1_cts06g03.des
 #display l_via_desc to via  - #Situa��o local de ocorr�ncia
 initialize ws.endres to null
 initialize ws.confirma to null

 ## PSI 202045
 #if param.atdsrvorg = 0 or param.atdsrvorg = 10 then
 #   display 'Periodo ou  :' to periodo
 #   display 'Ponto Ref... ' to pontoref
 #else
    display 'Ponto Ref...:' to periodo
    display '             ' to pontoref
 #end if

 ### PSI 192007 JUNIOR(META) - Inicio

 if g_documento.lclocodesres <> "S" and
    g_documento.atdsrvnum is null then
    if param.atdsrvorg =  1  or
       param.atdsrvorg =  2  or   # assistencia a passageiros
       param.atdsrvorg =  4  or
       param.atdsrvorg =  6  or
       param.atdsrvorg =  13 or
       param.atdsrvorg =  14 then

       if g_documento.aplnumdig is not null  or
          g_documento.prpnumdig is not null  then
          if param.c24endtip = 1  then
             let l_orides = " OCORRENCIA "
          else
             if param.c24endtip = 2 then
                initialize l_gsakend.* to null
                #initialize d_cts06g03.* to null
             end if
             let l_orides = " DESTINO "
          end if

          let l_orides = " O ENDERECO DE " clipped, l_orides

          if param.atdsrvorg =  9  or
             param.atdsrvorg =  13 then
              let g_documento.lclocodesres = "S"
          else
	            
	            if not cty41g00_valida_assunto(g_documento.c24astcod) then            
	               if cts08g01("A","S",""
	                          ,l_orides
	                          ," E O MESMO DA RESIDENCIA  "
	                          ," DO SEGURADO ? ") = "S" then
	                  let g_documento.lclocodesres = "S"
	               end if  
	            end if
          end if

          if g_documento.lclocodesres = "S" then

             if g_documento.ciaempcod = 1  or   ## Empresa Porto
                g_documento.ciaempcod = 50 then ## Empresa Porto Saude

                call figrc072_setTratarIsolamento()

                ### Pesquisa codigo do segurado atraves da apolice
                call cty05g00_segnumdig(g_documento.succod,
                                        g_documento.aplnumdig,
                                        g_documento.itmnumdig,
                                        g_funapol.dctnumseq,
                                        g_documento.prporg,
                                        g_documento.prpnumdig )
                     returning l_resultado, l_mensagem, l_segnumdig

                if g_isoAuto.sqlCodErr <> 0 then
                   let l_resultado = g_isoAuto.sqlCodErr
                   let l_mensagem  = "Pesquisa do Codigo do Segurado Indisponivel! Erro: "
                         ,g_isoAuto.sqlCodErr
                end if


                if l_resultado <> 1 then

                   whenever error continue
                   open c_cts06g03_005 using g_documento.succod,
                                           g_documento.aplnumdig,
                                           g_documento.ramcod
                   fetch c_cts06g03_005 into l_segnumdig
                   whenever error stop

                   if sqlca.sqlcode = 100 then
                      error l_mensagem
                   end if
                end if

                #call bgcpf620_dados_gsakend(l_segnumdig, "1")
                #     returning l_gsakend.*, l_ret

                ## Obter o endereco do segurado

                call osgtk1001_pesquisarEnderecoPorCodigo(l_segnumdig)
                returning l_ret, l_ind2

                for l_ind = 1 to l_ind2

                 if g_a_gsakend[l_ind].endfld = 1 then

                  let l_gsakend.segnumdig   =  l_segnumdig
                  let l_gsakend.endfld      =  g_a_gsakend[l_ind].endfld
                  let l_gsakend.endlgdtip   =  g_a_gsakend[l_ind].endlgdtip
                  let l_gsakend.endlgd      =  g_a_gsakend[l_ind].endlgd
                  let l_gsakend.endnum      =  g_a_gsakend[l_ind].endnum
                  let l_gsakend.endcmp      =  g_a_gsakend[l_ind].endcmp
                  let l_gsakend.endcepcmp   =  g_a_gsakend[l_ind].endcepcmp
                  let l_gsakend.endbrr      =  g_a_gsakend[l_ind].endbrr
                  let l_gsakend.endcid      =  g_a_gsakend[l_ind].endcid
                  let l_gsakend.endufd      =  g_a_gsakend[l_ind].endufd
                  let l_gsakend.endcep      =  g_a_gsakend[l_ind].endcep
                  let l_gsakend.dddcod      =  g_a_gsakend[l_ind].dddcod
                  let l_gsakend.teltxt      =  g_a_gsakend[l_ind].teltxt
                  let l_gsakend.tlxtxt      =  g_a_gsakend[l_ind].tlxtxt
                  let l_gsakend.factxt      =  g_a_gsakend[l_ind].factxt
                  let l_gsakend.atlult      =  g_a_gsakend[l_ind].atlult


                  exit for

                 end if

                end for

             else
                if g_documento.ciaempcod = 35 then
                   if l_doc_handle is not null then
                      call cts40g02_extraiDoXML(l_doc_handle, "SEGURADO_ENDERECO")
                           returning l_gsakend.endufd,
                                     l_gsakend.endcid,
                                     l_gsakend.endlgdtip,
                                     l_gsakend.endlgd,
                                     l_gsakend.endnum,
                                     d_cts06g03.lclrefptotxt,
                                     l_gsakend.endbrr,
                                     l_cep

                      call cts40g02_extraiDoXML(l_doc_handle, "SEGURADO")
                           returning ws.nome,
                                     ws.cgccpf,
                                     ws.pessoa,
                                     l_gsakend.dddcod,
                                     l_gsakend.teltxt,
                                     ws.email

                      let l_ret = 0
                      let l_gsakend.endcep = l_cep[1,5]
                      let l_gsakend.endcepcmp = l_cep[6,8]
                   end if
                end if
                  if g_documento.ciaempcod = 84 then

                            let l_ret = 0
                            let l_gsakend.endcep     = g_doc_itau[1].segcepnum  clipped
                            let l_gsakend.endcepcmp  = g_doc_itau[1].segcepcmpnum clipped

                            call cts06g11_retira_tipo_lougradouro(g_doc_itau[1].seglgdnom)
                                returning l_gsakend.endlgdtip
                                        , l_gsakend.endlgd



                            #let l_gsakend.endlgdtip  = null
                            let l_gsakend.dddcod     = g_doc_itau[1].segresteldddnum clipped
                            let l_gsakend.teltxt     = g_doc_itau[1].segrestelnum clipped
                            #let l_gsakend.endlgd     = g_doc_itau[1].seglgdnom clipped
                            let l_gsakend.endnum     = g_doc_itau[1].seglgdnum clipped
                            let l_gsakend.endbrr     = g_doc_itau[1].segbrrnom clipped
                            let l_gsakend.endcid     = g_doc_itau[1].segcidnom clipped
                            let l_gsakend.endufd     = g_doc_itau[1].segufdsgl clipped
                            let l_gsakend.endcep     = l_gsakend.endcep  using "&&&&&"
                            let l_gsakend.endcepcmp  = l_gsakend.endcepcmp using "&&&"
                            let l_gsakend.endcmp     = g_doc_itau[1].segendcmpdes clipped

                  end if
             end if

             if l_ret = 0 then
                #let d_cts06g03.lgdtip    = l_gsakend.endlgdtip
                #let d_cts06g03.dddcod    = l_gsakend.dddcod
                #let d_cts06g03.lcltelnum = l_gsakend.teltxt
                #let d_cts06g03.lgdnom    = l_gsakend.endlgd
                #let d_cts06g03.lgdnum    = l_gsakend.endnum
                #let d_cts06g03.brrnom    = l_gsakend.endbrr
                #let d_cts06g03.cidnom    = l_gsakend.endcid
                #let d_cts06g03.ufdcod    = l_gsakend.endufd
                #let d_cts06g03.lgdcep    = l_gsakend.endcep
                #let d_cts06g03.lgdcepcmp = l_gsakend.endcepcmp
                #let d_cts06g03.endcmp    = l_gsakend.endcmp
                # Tipo de Lougradouro
                call cty22g02_retira_acentos(l_gsakend.endlgdtip)
                                                returning d_cts06g03.lgdtip
                let d_cts06g03.lgdtip = upshift(d_cts06g03.lgdtip)
                let d_cts06g03.dddcod    = l_gsakend.dddcod
                let d_cts06g03.lcltelnum = l_gsakend.teltxt
                # Lougradouro
                call cty22g02_retira_acentos(l_gsakend.endlgd)
                     returning d_cts06g03.lgdnom
                let d_cts06g03.lgdnom = upshift(d_cts06g03.lgdnom)
                let d_cts06g03.lgdnum    = l_gsakend.endnum
                # Bairro
                call cty22g02_retira_acentos(l_gsakend.endbrr)
                     returning d_cts06g03.brrnom
                let d_cts06g03.brrnom = upshift(d_cts06g03.brrnom)
                # Cidade
                call cty22g02_retira_acentos(l_gsakend.endcid)
                     returning d_cts06g03.cidnom
                let d_cts06g03.cidnom = upshift(d_cts06g03.cidnom)
                let d_cts06g03.ufdcod    = l_gsakend.endufd
                let d_cts06g03.lgdcep    = l_gsakend.endcep
                let d_cts06g03.lgdcepcmp = l_gsakend.endcepcmp
                let d_cts06g03.endcmp    = l_gsakend.endcmp
             end if

          end if
          # Se possuir verifica sinal valido
          let salva.cidnom     =  d_cts06g03.cidnom #ligia 09/10/07
          let salva.ufdcod     =  d_cts06g03.ufdcod
          let salva.lgdtip     =  d_cts06g03.lgdtip
          let salva.lgdnom     =  d_cts06g03.lgdnom
          let salva.lgdnum     =  d_cts06g03.lgdnum
          let salva.brrnom     =  d_cts06g03.brrnom
          let salva.lclbrrnom  =  d_cts06g03.lclbrrnom
          let salva.lclltt     =  d_cts06g03.lclltt
          let salva.lcllgt     =  d_cts06g03.lcllgt
          let salva.endcmp     =  d_cts06g03.endcmp
       end if
    end if
 end if
 
 # SM-PSI-2014-02085 - Verifica horario de bloqueio de msg - Robson D.(Inexsoft) - Inicio -
 if not cts06g11_verif_bloq() then
    #Inicio - Situa��o local de ocorr�ncia
    if param.c24endtip = 1 and #Verifica tipo do endere�o = ocorr�ncia
       l_flag_auto = 'S' then  #Verifica se o servi�o � auto      
      if g_documento.lclocodesres = "N" OR g_documento.lclocodesres = "" OR
         g_documento.lclocodesres is null then

          let ws.txtocrlcl = 'Local de risco:'
          display ws.txtocrlcl to txtocrlcl

          let ws.ocrlclstt = ''
          let ws.ptoref1   = ''

          #Verifica se � uma INCLUS�O ou ALTERA��O
          if g_documento.atdsrvnum is null OR
             g_documento.atdsrvnum = "" then #Novo laudo
              call cts08g01_respostaobrigatoria("A","S"
                                   ," O VEICULO ESTA EM UM LOCAL SEGURO?"
                                   ,"Ex: Em um estacionamento ou garagem do"
                                   ,"trabalho, shopping, mercado, hotel, "
                                   ,"outra resid�ncia, posto de gasolina, etc.")
                         returning ws.ocrlclstt

              #Verifica retorno
              if ws.ocrlclstt = 'S' then
                  let ws.ocrlclstt = 'N' #Veiculo N�O est� em local de risco
                  ### SM-PSI-2014-02085 - Retirar a atribui��o do valor.
                  ### let ws.ptoref1 = 'EM LOCAL SEGURO'
                  let ws.ptoref1 = ""
              else
                 if ws.ocrlclstt = 'N' then
                    let ws.ocrlclstt = 'S' #Veiculo est� em local de risco
                    #let ws.ptoref1 = 'PRIORIZAR ATENDIMENTO'
                 else
                    error "Situa��o do local de ocorr�ncia n�o foi informada"
                    let ws.ocrlclstt = ''
                    let ws.ptoref1 = ''   
                 end if
              end if

              open  c_cts06g03_010 using ws.ocrlclstt
              fetch c_cts06g03_010  into lr_emeviacod.emeviacod
          else #Altera��o de laudo
            if lr_emeviacod.emeviacod = 1 then #Em local de risco
              let ws.ocrlclstt = 'S'
              #let ws.ptoref1 = 'PRIORIZAR ATENDIMENTO'
            else
              let ws.ocrlclstt = 'N'
              ### SM-PSI-2014-02085 - Retirar a atribui��o do valor.
              ### let ws.ptoref1 = 'EM LOCAL SEGURO'
              let ws.ptoref1 = ''
            end if
          end if
          display by name ws.ocrlclstt
          display by name ws.ptoref1
      end if
    end if
    #Fim - Situa��o local de ocorr�ncia
    ### PSI 192007 JUNIOR(META) - Fim
 end if
 #Fim - SM-PSI-2014-02085 - Robson D.

 let ws.benef = null
 let ws.ofnnumdig = null

 if g_documento.ciaempcod = 1  or   ## Empresa Porto
    g_documento.ciaempcod = 50 then ## Empresa Porto Saude
    call fbenefic(g_documento.succod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig,
                  g_documento.edsnumref)
         returning ws.benef, ws.ofnnumdig

 end if

 if param.atdsrvorg =  3   then
    message " (F17)Abandona (F5)Espelho "
 else
    if param.c24endtip <> 2 or
       g_documento.ciaempcod = 35  then # Azul Seguros - Ruiz
       if param.atdsrvorg = 10 then   # vistoria previa
          message " (F17)Abandona (F6)Historico (F3)Preenc."
       else
          message " (F17)Abandona (F3)Preenc (F4)Patio (F5)Espelho (F6)Historico "
       end if
    else
       if param.atdsrvorg =  4   and
          ws.locflg    = "N"  and
          g_documento.ciaempcod <> 84 then

             if ws.benefx  = "S"  then
                call cts08g01("A","N",""     #OSF 19968
                             ," VEICULO TEM DIREITO AO BENEFICIO."
                             ," CONSULTE O CADASTRO DE OFICINAS"
                             ,"REFERENCIADAS.PRESSIONE(F9).")
                     returning ws.confirma
                message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist,",
                        "(F7)Revendas,(F8)Oficinas,(F9)Ofic.Ref."
                if g_documento.ramcod = 16  or
                   g_documento.ramcod = 524 or
                   ws.clscod          = "096"  then
                   message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist,",
                           "(F7)Revendas,(F8)Ofic_Garantia_Mec,(F9)Ofic.Ref."
                end if
             else
                if g_documento.succod is null    and
                   g_documento.aplnumdig is null then
                   call cts08g01("A","N",""     #OSF 19968
                               ," VERIFIQUE SE O VEICULO TEM DIREITO"
                               ," AO BENEFICIO.","")
                       returning ws.confirma   #by aguinaldo
                   message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                           "(F8)Oficinas,(F9)Ofic.Ref."
                else
                   call cts08g01("A","N",""     #OSF 19968
                               ," VEICULO NAO TEM DIREITO AO BENEFICIO."
                               ," CONSULTE O CADASTRO DE OFICINAS."
                               ,"PRESSIONE(F8).")
                       returning ws.confirma
                   message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                           "(F8)Oficinas,(F9)Ofic. Ref."
                   if g_documento.ramcod = 16  or
                      g_documento.ramcod = 524 or
                      ws.clscod          = "096" then
                      message "(F17)Abandona,(F5)Espelho,(F4)Patio,(F6)Hist.,",
                              "(F8)Ofic_Garantia_Mec,(F9)Referenciadas"
                   end if
                end if
             end if
       else
          message " (F17)Abandona,(F5)Espelho,(F6)Historico,(F8)Oficinas"
          if g_documento.ramcod = 16  or
             g_documento.ramcod = 524 or
             ws.clscod          = "096" then
             message "(F17)Abandona,(F5)Espelho,(F6)Historico,",
                     "(F8)Oficinas_Garantia_Mecanica"
           end if
       end if
    end if
 end if
 let int_flag = false

 let ws.ptoref1 = d_cts06g03.lclrefptotxt[1,50]
 let ws.ptoref2 = d_cts06g03.lclrefptotxt[51,100]
 let ws.ptoref3 = d_cts06g03.lclrefptotxt[101,150]
 let ws.ptoref4 = d_cts06g03.lclrefptotxt[151,200]

 let ws.flgcompl = "S"

 if d_cts06g03.ofnnumdig is not null and
    param.c24endtip  =  2            then  # destino
    if ws.benef = "S"  then
       if ws.ofnnumdig = d_cts06g03.ofnnumdig then
          let d1_cts06g03.obsofic = "* Oficina Beneficio *"
       else
          let d1_cts06g03.obsofic = "* Cadastro Beneficio *"
       end if
    end if
    display by name d1_cts06g03.obsofic
    select ofnstt
      into ws.ofnstt
      from sgokofi
     where ofnnumdig = d_cts06g03.ofnnumdig
     if ws.ofnstt = "C" then
        let d1_cts06g03.staofic  =  "OBSERVACAO"
     end if
     display by name d1_cts06g03.staofic attribute (reverse)
 end if

 initialize lr_salva to null

 let lr_salva.lgdcep     = d_cts06g03.lgdcep
 let lr_salva.lgdcepcmp  = d_cts06g03.lgdcepcmp
 let lr_salva.lclidttxt  = d_cts06g03.lclidttxt
#Inicio - Situa��o local de ocorr�ncia
{
#Consistir o departamento para entrar ou nao com a via emergencial.
if (g_documento.c24astcod = 'M15' or
   g_documento.c24astcod = 'M20' or
   g_documento.c24astcod = 'M23' or
   g_documento.c24astcod = 'M33')then
   		let ws.decide_via = "N"
else
		 call ctc17m02_consiste_depto_via(g_issk.dptsgl)
		    returning l_resultado
		             ,l_mensagem

		 if l_resultado = 1 then
		    if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
		        param.atdsrvorg = 4 or param.atdsrvorg = 6) and param.c24endtip = 1 then

		       let l_via_desc = 'Via Emerg...:'
		       display l_via_desc to via

		       let ws.decide_via = "N"
		       if lr_emeviacod.emeviacod is not null then
		          let ws.decide_via = "S"
		       end if

		       display by name ws.decide_via

		       display '-' to espaco1
		       display by name lr_emeviacod.emeviacod
		    else
		       let l_resultado = 2
		    end if
		 else
		   if l_resultado = 3 then
		      error l_mensagem sleep 2
		      call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
		      return d_cts06g03.*, ws.retflg, hist_cts06g03.*,lr_emeviacod.emeviacod
		   end if
		 end if

		#Obter a descricao da via emergencial
		 if l_resultado = 1 or #tem via para o departamento
		    lr_emeviacod.emeviacod is not null then
		    call ctc17m02_obter_via(lr_emeviacod.emeviacod,g_issk.dptsgl)
		        returning l_resultado
		                 ,l_mensagem
		                 ,lr_ctc17m02.emeviades
		                 ,lr_ctc17m02.emeviapri

		    if l_resultado = 3 then
		       error l_mensagem sleep 2
		       call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)
		       return d_cts06g03.*, ws.retflg, hist_cts06g03.*,lr_emeviacod.emeviacod
		    else
		       if l_resultado = 2 and lr_emeviacod.emeviacod is null then
		          let l_resultado  = 1
		       end if

		       display by name lr_emeviacod.emeviacod
		       display by name lr_ctc17m02.emeviades
		    end if
		 end if
end if  # meu
}
#Fim - Situa��o local de ocorr�ncia

 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[1].brrnom = d_cts06g03.brrnom

 call cts06g10_monta_brr_subbrr(d_cts06g03.brrnom,
                                d_cts06g03.lclbrrnom)
      returning d_cts06g03.brrnom

 let l_oriprc = false

 input by name d_cts06g03.lgdcep,
               d_cts06g03.lgdcepcmp,
               d_cts06g03.lclidttxt,
               d_cts06g03.cidnom,
               d_cts06g03.ufdcod,
               d_cts06g03.lgdtip,
               d_cts06g03.lgdnom,
               d_cts06g03.lgdnum,
               d_cts06g03.endcmp,
               d_cts06g03.brrnom,
               d_cts06g03.endzon,
#              ws.decide_via, #Situa��o local de ocorr�ncia
               ws.ocrlclstt, #Situa��o local de ocorr�ncia
               d_cts06g03.lclcttnom,
               d_cts06g03.dddcod,
               d_cts06g03.lcltelnum,
               d_cts06g03.celteldddcod,
               d_cts06g03.celtelnum,
               ws.ptoref1,
               ws.ptoref2,
               ws.ptoref3,
               ws.ptoref4 without defaults

   before field lgdcep
          let ws.cepflg = "0"
          if param.atdsrvorg   = 16   and  # sinistro transportes
             d_cts06g03.ufdcod = "EX" then # sinistro fora do Brasil
             let d_cts06g03.c24lclpdrcod = 01  # FORA DO PADRAO
             next field cidnom
          end if
          if (param.atdsrvorg = 1 or
				      param.atdsrvorg = 2 or   #Mercosul
					    param.atdsrvorg = 4) and
							d_cts06g03.ufdcod = "EX" then
							let d_cts06g03.c24lclpdrcod = 01
							next field cidnom
					end if
          display by name d_cts06g03.lgdcep attribute (reverse)

   after  field lgdcep
          display by name d_cts06g03.lgdcep

          if d_cts06g03.lgdcep is null then
             if ws.benefx = "S"                and
                param.c24endtip = 2            and
                g_documento.c24astcod <> "H10" then
                call cts08g01("A","S",""     #OSF 19968
                             ,"CONFIRMA O PREENCHIMENTO MANUAL"
                             ,"SEM A CONSULTA DO CADASTRO DE  "
                             ,"OFICINAS?")
                     returning ws.confirma
                if ws.confirma = "N" then
                   next field lgdcep
                end if
             end if

             initialize d_cts06g03.lgdcepcmp  to null
             display by name d_cts06g03.lgdcepcmp
             next field lclidttxt
          end if

   before field lgdcepcmp
          display by name d_cts06g03.lgdcepcmp attribute (reverse)

   after  field lgdcepcmp
          display by name d_cts06g03.lgdcepcmp

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lgdcep
          end if
          if d_cts06g03.lgdcepcmp is null then
             initialize d_cts06g03.lgdcep  to null
             display by name d_cts06g03.lgdcep
          end if
          if d_cts06g03.lgdcep    is not null   and
             d_cts06g03.lgdcepcmp is not null   then
             open  c_cts06g03_001  using  d_cts06g03.lgdcep,
                                          d_cts06g03.lgdcepcmp
             fetch c_cts06g03_001  into   d_cts06g03.lgdtip,
                                          d_cts06g03.lgdnom,
                                          ws.cidcod,
                                          ws.brrcod
             if sqlca.sqlcode  =  100   then
                error " Cep nao cadastrado!"
                next field lgdcep
             end if
             close c_cts06g03_001

             call cts06g06(d_cts06g03.lgdnom)  returning d_cts06g03.lgdnom

             open  c_cts06g03_002  using  ws.cidcod
             fetch c_cts06g03_002  into   d_cts06g03.cidnom,
                                     d_cts06g03.ufdcod
             close c_cts06g03_002
             open  c_cts06g03_003  using  ws.cidcod, ws.brrcod
             fetch c_cts06g03_003  into   d_cts06g03.brrnom
             close c_cts06g03_003

             #if d_cts06g03.lclbrrnom is null then
             #   let d_cts06g03.lclbrrnom = d_cts06g03.brrnom
             #end if

             display by name d_cts06g03.lgdtip, d_cts06g03.lgdnom
             display by name d_cts06g03.cidnom, d_cts06g03.ufdcod
             display by name d_cts06g03.brrnom

             let d_cts06g03.c24lclpdrcod = 02  # PADRAO GUIA POSTAL
             let ws.cepflg = "1"

#Inicio - Situa��o local de ocorr�ncia
{
             # Priscila 24/01/2006 - Buscar via emergencial de acordo com o
             # tipo de logradouro retornado pela funcao
             if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
                 param.atdsrvorg = 4 or param.atdsrvorg = 6) and
                 param.c24endtip = 1 then
                 call ctc17m02_obter_emeviacod(d_cts06g03.lgdtip, g_issk.dptsgl)
                      returning l_resultado
                               ,l_mensagem
                               ,lr_emeviacod.emeviacod

                 if l_resultado = 1 then
                    #encontrou esse tipo de logradouro como via emergencial
                    # para o departamento
                    let ws.decide_via = 'S'
                    let lr_ctc17m02.emeviades = d_cts06g03.lgdtip
                    #let lr_salva.emeviacod = lr_emeviacod.emeviacod
                    #let lr_salva.emeviades = lr_ctc17m02.emeviades
                 else
                    let ws.decide_via = 'N'
                    let lr_emeviacod.emeviacod = null
                    let lr_ctc17m02.emeviades = null
                 end if
                 display by name ws.decide_via
                 display by name lr_emeviacod.emeviacod
                 display by name lr_ctc17m02.emeviades
             end if
}
#Fim - Situa��o local de ocorr�ncia

             ## PSI 183644 - Inicio

             #  if param.atdsrvorg = 10 then # Vist. Previa
             #     if salva.ufdcod <> d_cts06g03.ufdcod then
             #       #prompt "Endereco nao confere com a Sucursal Informada.",
             #       #       "<enter>" for char ws.prompt_key
             #        exit input
             #     end if
             #  end if

             ## PSI 183644 - Final

          end if

   before field lclidttxt
          display by name d_cts06g03.lgdcep thru d_cts06g03.lcltelnum

          if param.c24endtip = 1  and
             param.atdsrvorg <>  5   and
             param.atdsrvorg <>  7   and
             param.atdsrvorg <> 17   then
             if ws.cepflg = "1" then
                next field lgdnum
             end if
          end if

          display by name d_cts06g03.lclidttxt   attribute (reverse)

   after  field lclidttxt
          display by name d_cts06g03.lclidttxt

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts06g03.lgdcepcmp is not null then
                next field lgdcepcmp
             else
                next field lgdcep
             end if
          end if

          let l_flag_local_especial = "N"

          # --Inicio CT 322083

          if param.atdsrvorg <> 10 then
             # --Inicio CT 318779

             let ws.c24astcod = g_documento.c24astcod

             if g_documento.atdsrvnum is not null then
                open c_cts06g03_004 using g_documento.atdsrvnum,
                                        g_documento.atdsrvano,
                                        g_documento.atdsrvnum,
                                        g_documento.atdsrvano
                whenever error continue
                fetch c_cts06g03_004 into ws.c24astcod
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = notfound then
                      error "Assunto relacionado a ligacao, nao encontrado !"
                   else
                      error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: ccts06g03002"
                   end if
                   next field lclidttxt
                end if
             end if

             # --Final CT 318779

             if ws.c24astcod <> "RPT" and
                ws.c24astcod <> "T11" then
               #if param.c24endtip = 1 and
               # chamar a funcao ctc71m01 tipo 1(ocorrencia) e
               # tipo 2(destino). psi211893
                if (d_cts06g03.lclidttxt <> ""       or
                    d_cts06g03.lclidttxt is not null) and
                    d_cts06g03.lgdcep    is null      then
                    let l_flag_local_especial = "S"
                end if

              if g_documento.c24astcod <> 'M15' and
			           g_documento.c24astcod <> 'M20' and
			           g_documento.c24astcod <> 'M23' and
			           g_documento.c24astcod <> 'M33' and
			           g_documento.c24astcod <> 'KM1' and	
			           g_documento.c24astcod <> 'KM2' and	
			           g_documento.c24astcod <> 'KM3' then 	
			           	
                if l_flag_local_especial = "S" then

                   initialize lr_ctc71m01_ret to null

                   call ctc71m01(d_cts06g03.lclidttxt,"A","","")
                        returning lr_ctc71m01_ret.c24fxolclcod,
                                   lr_ctc71m01_ret.lclidttxt,
                                   lr_ctc71m01_ret.lgdtip,
                                   lr_ctc71m01_ret.lgdnom,
                                   lr_ctc71m01_ret.compleme,
                                   lr_ctc71m01_ret.lgdnum,
                                   lr_ctc71m01_ret.lgdcep,
                                   lr_ctc71m01_ret.lgdcepcmp,
                                   lr_ctc71m01_ret.brrnom,
                                   lr_ctc71m01_ret.cidnom,
                                   lr_ctc71m01_ret.ufdcod,
                                   lr_ctc71m01_ret.endzon,
                                   lr_ctc71m01_ret.c24lclpdrcod,
                                   lr_ctc71m01_ret.lclltt,
                                   lr_ctc71m01_ret.lcllgt

                   if lr_ctc71m01_ret.lgdnom is not null or
                      lr_ctc71m01_ret.lgdnom <> " " then

                      let l_c24fxolclcod          = lr_ctc71m01_ret.c24fxolclcod
                      let d_cts06g03.lclidttxt    = lr_ctc71m01_ret.lclidttxt
                      let d_cts06g03.lgdtip       = lr_ctc71m01_ret.lgdtip
                      let d_cts06g03.lgdnom       = lr_ctc71m01_ret.lgdnom
                      let d_cts06g03.endcmp       = lr_ctc71m01_ret.compleme
                      let d_cts06g03.lgdnum       = lr_ctc71m01_ret.lgdnum
                      let d_cts06g03.lgdcep       = lr_ctc71m01_ret.lgdcep
                      let d_cts06g03.lgdcepcmp    = lr_ctc71m01_ret.lgdcepcmp
                      let d_cts06g03.brrnom    = lr_ctc71m01_ret.brrnom
                      let d_cts06g03.cidnom       = lr_ctc71m01_ret.cidnom
                      let d_cts06g03.ufdcod       = lr_ctc71m01_ret.ufdcod
                      let d_cts06g03.endzon       = lr_ctc71m01_ret.endzon
                      let d_cts06g03.c24lclpdrcod = lr_ctc71m01_ret.c24lclpdrcod
                      let d_cts06g03.lclltt       = lr_ctc71m01_ret.lclltt
                      let d_cts06g03.lcllgt       = lr_ctc71m01_ret.lcllgt

                      display by name d_cts06g03.lclidttxt
                      display by name d_cts06g03.lgdtip
                      display by name d_cts06g03.lgdnom
                      display by name d_cts06g03.lgdnum
                      display by name d_cts06g03.lgdcep
                      display by name d_cts06g03.lgdcepcmp
                      display by name d_cts06g03.brrnom
                      display by name d_cts06g03.cidnom
                      display by name d_cts06g03.ufdcod
                      display by name d_cts06g03.endzon
                      display by name d_cts06g03.lclltt
                      display by name d_cts06g03.lcllgt
                      display by name d_cts06g03.endcmp
                   else
                      error "Nenhum local selecionado !"

                      let l_flag_local_especial = "N"

                      let d_cts06g03.lclidttxt  = lr_salva.lclidttxt
                      let d_cts06g03.lgdcep     = lr_salva.lgdcep
                      let d_cts06g03.lgdcepcmp  = lr_salva.lgdcepcmp

                      display by name d_cts06g03.lclidttxt
                      display by name d_cts06g03.lgdcep
                      display by name d_cts06g03.lgdcepcmp

                      next field cidnom
                   end if
                end if
             end if
          end if
          let ws.cepflg = "0"
				end if


   before field cidnom
          display by name d_cts06g03.cidnom attribute (reverse)

          if  lr_cts06g03.cidnom is null then
              let lr_cts06g03.cidnom = " "
          else
              let lr_cts06g03.cidnom = d_cts06g03.cidnom
          end if

          if  lr_cts06g03.ufdcod is null then
              let lr_cts06g03.ufdcod = " "
          else
              let lr_cts06g03.ufdcod = d_cts06g03.ufdcod
          end if

   after  field cidnom
          display by name d_cts06g03.cidnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts06g03.lclidttxt is not null then
                next field lclidttxt
             else
                if d_cts06g03.lgdcepcmp is not null then
                   next field lgdcepcmp
                else
                   next field lgdcep
                end if
             end if
          end if
          if d_cts06g03.cidnom is null  then
             error " Cidade deve ser informada!"
             next field cidnom
          end if
          if param.atdsrvorg   = 16   and  # sinistro transportes
             d_cts06g03.ufdcod = "EX" then # sinistro fora do Brasil
             next field lgdtip
          end if
         if (param.atdsrvorg = 1 or
             param.atdsrvorg = 2 or      # Mercosul
             param.atdsrvorg = 4) and
		         d_cts06g03.ufdcod = "EX" then
		         next field lgdtip
		     end if

   before field ufdcod
          display by name d_cts06g03.ufdcod attribute (reverse)

   after  field ufdcod
          display by name d_cts06g03.ufdcod
          if d_cts06g03.ufdcod = "DF"  then
             let d_cts06g03.cidnom = "BRASILIA"
             display by name d_cts06g03.cidnom
          end if
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts06g03.ufdcod = "DF"  then
                let d_cts06g03.lgdtip = ""
                display by name d_cts06g03.lgdtip
                next field lgdnom
             end if
             if d_cts06g03.ufdcod is null  then
                error " Sigla da unidade da federacao deve ser informada!"
                next field ufdcod
             end if
             if param.atdsrvorg   = 16   and  # sinistro transportes
                d_cts06g03.ufdcod = "EX" then # sinistro fora do Brasil
                next field lgdtip
             end if
             if (param.atdsrvorg = 1 or
                 param.atdsrvorg = 2 or     # Mercosul
              	 param.atdsrvorg = 4) and
		             d_cts06g03.ufdcod = "EX" then
                next field lgdtip
             end if



             #--------------------------------------------------------------
             # Verifica se UF esta cadastrada
             #--------------------------------------------------------------
           if d_cts06g03.ufdcod <> "EX" then
             select ufdcod
               from glakest
              where ufdcod = d_cts06g03.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

             if d_cts06g03.ufdcod = d_cts06g03.cidnom  then
                select ufdnom
                  into d_cts06g03.cidnom
                  from glakest
                 where ufdcod = d_cts06g03.cidnom

                if sqlca.sqlcode = 0  then
                   display by name d_cts06g03.cidnom
                else
                   let d_cts06g03.cidnom = d_cts06g03.ufdcod
                end if
             end if

             #--------------------------------------------------------------
             # Verifica se a cidade esta cadastrada
             #--------------------------------------------------------------
             declare c_glakcidade cursor for
                select cidcod,cidcep,cidcepcmp
                  from glakcid
                 where cidnom = d_cts06g03.cidnom
                   and ufdcod = d_cts06g03.ufdcod

             open  c_glakcidade
             fetch c_glakcidade  into  ws.cidcod,ws.cidcep,ws.cidcepcmp

             if sqlca.sqlcode  =  100   then
                call cts06g04(d_cts06g03.cidnom, d_cts06g03.ufdcod)
                     returning ws.cidcod, d_cts06g03.cidnom, d_cts06g03.ufdcod

                if d_cts06g03.cidnom  is null   then
                   error " Cidade deve ser informada!"
                end if
                next field cidnom
             end if
             close c_glakcidade
          end if

## PSI 183644 - Inicio

#             if param.atdsrvorg = 10 then # Vist. Previa
#                if salva.ufdcod <> d_cts06g03.ufdcod then
#                   error "Endereco nao confere com a Sucursal Informada."
#                   exit input
#                end if
#             end if

## PSI 183644 - Final

               #if  (not l_oriprc )then
               if  lr_cts06g03.cidnom <> d_cts06g03.cidnom or
                   lr_cts06g03.ufdcod <> d_cts06g03.ufdcod then
                   call ctc87m00_orientacao_preenchimento(d_cts06g03.cidnom,
                                                          d_cts06g03.ufdcod)
                   let l_oriprc = true
               end if
          end if

   before field lgdtip
          display by name d_cts06g03.lgdtip attribute (reverse)

          if d_cts06g03.lgdtip is null then
             call cta00m06_tipo_logradouro()
                  returning l_tplougr

             if l_tplougr is not null then
                let l_cabec = "Tipo logradouro"

                call ctx14g01_tipo_logradouro(l_cabec, l_tplougr)
                   returning d_cts06g03.lgdtip

                let m_lgdtip = d_cts06g03.lgdtip
             end if
          end if


   after  field lgdtip
          display by name d_cts06g03.lgdtip
          let m_lgdtip = d_cts06g03.lgdtip

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06g03.lgdtip is null  then
                error " Tipo do logradouro deve ser informado!"
                next field lgdtip
             end if
          end if
#Inicio - Situa��o local de ocorr�ncia
{
          # Priscila 20/01/2006 - Busca via emergencial de acordo com
          # tipo de logradouro informado
          if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
              param.atdsrvorg = 4 or param.atdsrvorg = 6) and
              param.c24endtip = 1 then
              call ctc17m02_obter_emeviacod(d_cts06g03.lgdtip, g_issk.dptsgl)
                   returning l_resultado
                            ,l_mensagem
                            ,lr_emeviacod.emeviacod

              if l_resultado = 1 then
                 #encontrou esse tipo de logradouro como via emergencial para o
                 # departamento
                 let ws.decide_via = 'S'
                 let lr_ctc17m02.emeviades = d_cts06g03.lgdtip
                 #let lr_salva.emeviacod = lr_emeviacod.emeviacod
                 #let lr_salva.emeviades = lr_ctc17m02.emeviades
              else
                 let ws.decide_via = 'N'
                 let lr_emeviacod.emeviacod = null
                 let lr_ctc17m02.emeviades = null
              end if
              display by name ws.decide_via
              display by name lr_emeviacod.emeviacod
              display by name lr_ctc17m02.emeviades
          end if
}#Fim - Situa��o local de ocorr�ncia

          # >> ronaldo, meta
          if upshift(d_cts06g03.ufdcod) = 'SP'        and
             upshift(d_cts06g03.cidnom) = 'SAO PAULO' and
             upshift(m_lgdtip)          = 'MARGINAL'  then
                call cta00m06_tipo_marginal()
                returning l_tpmarginal

                if l_tpmarginal is not null then
                   let l_cabec = "Tipo Marginal"

                   call ctx14g01_tipo_marginal(l_cabec, l_tpmarginal)
                      returning d_cts06g03.lgdnom

                      let m_lgdnom = d_cts06g03.lgdnom
                end if
          end if
          # << ronaldo, meta


   before field lgdnom
          display by name d_cts06g03.lgdnom attribute (reverse)

   after  field lgdnom
          display by name d_cts06g03.lgdnom

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06g03.lgdnom is null then
                error " Logradouro deve ser informado!"
                next field lgdnom
             end if
          end if

   before field lgdnum
          display by name d_cts06g03.lgdnum attribute (reverse)

   after  field lgdnum
          display by name d_cts06g03.lgdnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if ws.cepflg = "0" then
                next field lgdnom
             else
                next field lgdcep
             end if
          end if
          if d_cts06g03.lgdnum is null  then
             call cts08g01("C","S","","NUMERO DO LOGRADOURO",
                                   "NAO INFORMADO!","")
                 returning ws.confirma
             if ws.confirma = "N"  then
                next field lgdnum
             end if
          end if

      if param.atdsrvorg   = 10   then  # vistoria previa
        next field endcmp
      end if

	 before field brrnom
        display by name d_cts06g03.brrnom attribute (reverse)
        if  d_cts06g03.brrnom is null then
            let m_subbairro[1].brrnom = null
        end if

   after  field brrnom
          display by name d_cts06g03.brrnom
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts06g03.brrnom is null then
                error " Bairro deve ser informado!"
                next field brrnom
             end if
             if param.atdsrvorg   = 16   and  # sinistro transportes
                d_cts06g03.ufdcod = "EX" then # sinistro fora do Brasil
                next field lclcttnom
             end if
             if (param.atdsrvorg = 1 or
		             param.atdsrvorg = 2 or    # Mercosul
		             param.atdsrvorg = 4) and
				         d_cts06g03.ufdcod = "EX" then
				         next field lclcttnom
				     end if
				     
             #if param.atdsrvorg   = 10  then
             #   next field endcmp
             #end if
          else
             next field cidnom
          end if

          if l_flag_local_especial = "N" then
             #if ws.flgcompl = "N" then
                #--------------------------------------------------------------
                # Verifica se a cidade possui mapa carregado
                #--------------------------------------------------------------
                initialize ws.mpacidcod  to null
                initialize ws.result     to null

                call cts23g00_inf_cidade(2,"",d_cts06g03.cidnom
                                        ,d_cts06g03.ufdcod)
                   returning ws.result,
                             ws.mpacidcod,
                             ws.lclltt_cid,
                             ws.lcllgt_cid,
                             ws.mpacrglgdflg,
                             ws.gpsacngrpcod
                if param.atdsrvorg = 10 and    #OSF 19968
                   v_retorno = 0 then
                   let ws.mpacrglgdflg = null
                end if

                if ws.mpacrglgdflg = "1" then  # existe coordenadas por rua.

                    # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
                    if  ctx25g05_rota_ativa() then

                        let l_fondafinf = false

                        if  param.c24endtip = 1 then

                            if  ctn55c00_verifica_srv_org(g_documento.c24astcod) then

                                call ctn55c00_valida_endereco_daf(g_documento.succod,
                                                                  g_documento.aplnumdig,
                                                                  g_documento.itmnumdig,
                                                                  g_funapol.vclsitatu,
                                                                  "","")
                                     returning lr_daf.status_ret,
                                               lr_daf.lclltt,
                                               lr_daf.lcllgt,
                                               lr_daf.ufdcod,
                                               lr_daf.cidnom,
                                               lr_daf.lgdtip,
                                               lr_daf.lgdnom,
                                               lr_daf.brrnom,
                                               lr_daf.numero

                                if  lr_daf.status_ret = 0 then
                                    call cts06g03_inclui_temp_hstidx(1,
                                                                     lr_daf.lgdtip,
                                                                     lr_daf.lgdnom,
                                                                     lr_daf.numero,
                                                                     lr_daf.brrnom,
                                                                     lr_daf.cidnom,
                                                                     lr_daf.ufdcod,
                                                                     lr_daf.lclltt,
                                                                     lr_daf.lcllgt)

                                    if  ctn55c00_compara_end(lr_daf.lgdnom, d_cts06g03.lgdnom) or
                                        ctn55c00_compara_end(lr_daf.lgdnomalt, d_cts06g03.lgdnom) then
                                        #display "ENDERE�O DO DAF MESMO QUE O DO INFORMADO PELO AGENTE."
                                        let l_fondafinf = true
                                    end if
                                end if
                            else
                                let lr_daf.status_ret = 1
                            end if
                        else
                            let l_fondafinf = false
                            let lr_daf.status_ret = 1
                        end if

                        initialize lr_ctx25g05.* to null

                        if  l_fondafinf then
                            let d_cts06g03.lclltt = lr_daf.lclltt
                            let d_cts06g03.lcllgt = lr_daf.lcllgt
                            let d_cts06g03.c24lclpdrcod = 3
                        else
                            if  lr_daf.status_ret = 0 then
                                if param.c24endtip = 1 then
                                   #display "CHAMADA 2"
                                   call ctx25g05_prox(d_cts06g03.ufdcod,
                                                      d_cts06g03.cidnom,
                                                      d_cts06g03.lgdtip,
                                                      d_cts06g03.lgdnom,
                                                      d_cts06g03.lgdnum,
                                                      d_cts06g03.brrnom,
                                                      d_cts06g03.lclbrrnom,
                                                      d_cts06g03.lgdcep,
                                                      d_cts06g03.lgdcepcmp,
                                                      d_cts06g03.lclltt,
                                                      d_cts06g03.lcllgt,
                                                      d_cts06g03.c24lclpdrcod,
                                                      lr_daf.lclltt,
                                                      lr_daf.lcllgt)
                                            returning d_cts06g03.lgdtip,
                                                      d_cts06g03.lgdnom,
                                                      d_cts06g03.lgdnum,
                                                      d_cts06g03.brrnom,
                                                      d_cts06g03.lclbrrnom,
                                                      d_cts06g03.lgdcep,
                                                      d_cts06g03.lgdcepcmp,
                                                      d_cts06g03.lclltt,
                                                      d_cts06g03.lcllgt,
                                                      d_cts06g03.c24lclpdrcod,
                                                      d_cts06g03.ufdcod,
                                                      d_cts06g03.cidnom,
                                                      m_flagsemidx
                                else
                                    #display "CHAMADA 4"
                                    call ctx25g05("C", # -> INPUT COMPLETO
                                                  "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                                                  d_cts06g03.ufdcod,
                                                  d_cts06g03.cidnom,
                                                  d_cts06g03.lgdtip,
                                                  d_cts06g03.lgdnom,
                                                  d_cts06g03.lgdnum,
                                                  d_cts06g03.brrnom,
                                                  d_cts06g03.lclbrrnom,
                                                  d_cts06g03.lgdcep,
                                                  d_cts06g03.lgdcepcmp,
                                                  d_cts06g03.lclltt,
                                                  d_cts06g03.lcllgt,
                                                  d_cts06g03.c24lclpdrcod)

                                        returning d_cts06g03.lgdtip,
                                                  d_cts06g03.lgdnom,
                                                  d_cts06g03.lgdnum,
                                                  d_cts06g03.brrnom,
                                                  d_cts06g03.lclbrrnom,
                                                  d_cts06g03.lgdcep,
                                                  d_cts06g03.lgdcepcmp,
                                                  d_cts06g03.lclltt,
                                                  d_cts06g03.lcllgt,
                                                  d_cts06g03.c24lclpdrcod,
                                                  d_cts06g03.ufdcod,
                                                  d_cts06g03.cidnom
                                end if

                            else
                                call ctx25g05("C", # -> INPUT COMPLETO
                                              "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                                              d_cts06g03.ufdcod,
                                              d_cts06g03.cidnom,
                                              d_cts06g03.lgdtip,
                                              d_cts06g03.lgdnom,
                                              d_cts06g03.lgdnum,
                                              d_cts06g03.brrnom,
                                              d_cts06g03.lclbrrnom,
                                              d_cts06g03.lgdcep,
                                              d_cts06g03.lgdcepcmp,
                                              d_cts06g03.lclltt,
                                              d_cts06g03.lcllgt,
                                              d_cts06g03.c24lclpdrcod)

                                    returning d_cts06g03.lgdtip,
                                              d_cts06g03.lgdnom,
                                              d_cts06g03.lgdnum,
                                              d_cts06g03.brrnom,
                                              d_cts06g03.lclbrrnom,
                                              d_cts06g03.lgdcep,
                                              d_cts06g03.lgdcepcmp,
                                              d_cts06g03.lclltt,
                                              d_cts06g03.lcllgt,
                                              d_cts06g03.c24lclpdrcod,
                                              d_cts06g03.ufdcod,
                                              d_cts06g03.cidnom
                            end if
                        end if

                        # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                        let m_subbairro[1].brrnom = d_cts06g03.brrnom
                        if d_cts06g03.c24lclpdrcod = 3 then
                        call cts06g10_monta_brr_subbrr(d_cts06g03.brrnom,
                                                       d_cts06g03.lclbrrnom)
                             returning d_cts06g03.brrnom
                        end if
                    else
                        # CASO OS CODIGOS FONETICOS DA ENDERE�O DO DAF E DO
                        # INFORMADO N�O S�O SEJAM IGUAIS ABRE INPUT DE ENDERE�O
                        call cts06g09(d_cts06g03.lgdtip,
                                      d_cts06g03.lgdnom,
                                      d_cts06g03.lgdnum,
                                      d_cts06g03.brrnom,
                                      ws.mpacidcod)
                            returning d_cts06g03.lgdtip,
                                      d_cts06g03.lgdnom,
                                      d_cts06g03.brrnom,
                                      d_cts06g03.lgdcep,
                                      d_cts06g03.lgdcepcmp,
                                      d_cts06g03.lclltt,
                                      d_cts06g03.lcllgt,
                                      d_cts06g03.c24lclpdrcod

                        let m_subbairro[1].brrnom = d_cts06g03.brrnom
                    end if

                    #if d_cts06g03.c24lclpdrcod <> 03 then
                    #   let  d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
                    #   let  d_cts06g03.lcllgt = ws.lcllgt_cid
                    #end if

                    if d_cts06g03.c24lclpdrcod <> 03 or
                       d_cts06g03.lclltt is null     or
                       d_cts06g03.lclltt = 0         or
                       d_cts06g03.lcllgt is null     or
                       d_cts06g03.lcllgt = 0         then

                        let d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
                        let d_cts06g03.lcllgt = ws.lcllgt_cid
                        let d_cts06g03.c24lclpdrcod = 1
                    end if

                  { if d_cts06g03.c24lclpdrcod <> 03 then
                      open c_cts06g03_006 using ws.mpacidcod
                                             ,d_cts06g03.brrnom
                      fetch c_cts06g03_006 into l_lclltt
                                             ,l_lcllgt
                      if sqlca.sqlcode = 0 then
                         let d_cts06g03.c24lclpdrcod = 3
                         let d_cts06g03.lclltt = l_lclltt
                         let d_cts06g03.lcllgt = l_lcllgt
                      end if
                   end if  } # Inibido por Raji 24/06

                else
                   let  d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
                   let  d_cts06g03.lcllgt = ws.lcllgt_cid

                   if ws.cepflg  =  "0" then
                      call cts06g05(d_cts06g03.lgdtip,
                                    d_cts06g03.lgdnom,
                                    d_cts06g03.lgdnum,
                                    d_cts06g03.brrnom,
                                    ws.cidcod,
                                    d_cts06g03.ufdcod)
                          returning d_cts06g03.lgdtip,
                                    d_cts06g03.lgdnom,
                                    d_cts06g03.brrnom,
                                    d_cts06g03.lgdcep,
                                    d_cts06g03.lgdcepcmp,
                                    d_cts06g03.c24lclpdrcod

                       let m_subbairro[1].brrnom = d_cts06g03.brrnom
                   end if
                end if

                if salva.lclltt = d_cts06g03.lclltt and  #ligia 09/10/07
                   salva.lcllgt = d_cts06g03.lcllgt and
                   salva.cidnom <> d_cts06g03.cidnom then
                   let d_cts06g03.cidnom    = salva.cidnom
                   let d_cts06g03.ufdcod    = salva.ufdcod
                   let d_cts06g03.lgdtip    = salva.lgdtip
                   let d_cts06g03.lgdnom    = salva.lgdnom
                   let d_cts06g03.lgdnum    = salva.lgdnum
                   let d_cts06g03.brrnom    = salva.brrnom
                   let d_cts06g03.lclbrrnom = salva.lclbrrnom

                else
                   let salva.cidnom     =  d_cts06g03.cidnom
                   let salva.ufdcod     =  d_cts06g03.ufdcod
                   let salva.lgdtip     =  d_cts06g03.lgdtip
                   let salva.lgdnom     =  d_cts06g03.lgdnom
                   let salva.lgdnum     =  d_cts06g03.lgdnum
                   let salva.brrnom     =  d_cts06g03.brrnom
                   let salva.lclbrrnom  =  d_cts06g03.lclbrrnom
                   let salva.lclltt     =  d_cts06g03.lclltt
                   let salva.lcllgt     =  d_cts06g03.lcllgt
                end if

                if d_cts06g03.c24lclpdrcod is null  then
                   error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                   next field lgdnom
                end if
                if d_cts06g03.c24lclpdrcod <> 01  and   ### Fora de padrao
                   d_cts06g03.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
                   d_cts06g03.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
                   d_cts06g03.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
                   d_cts06g03.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-Bairro
                   error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
                   next field lgdtip
                end if
                if d_cts06g03.c24lclpdrcod = 02  then
                   call cts06g06(d_cts06g03.lgdnom)
                       returning d_cts06g03.lgdnom
                end if

                display by name d_cts06g03.brrnom thru d_cts06g03.lcltelnum
                if d_cts06g03.brrnom is NOT NULL then
                   if upshift(m_lgdtip) = 'MARGINAL' or
                      upshift(m_lgdtip) = 'RODOVIA'  then

                      call cts06g11_sentido(m_lgdnom
                                           ,m_lgdtip)
                      returning l_pontoreferencia

                      let ws.ptoref1 = upshift(l_pontoreferencia[001,050]) clipped
                      let ws.ptoref2 = upshift(l_pontoreferencia[051,100]) clipped
                      let ws.ptoref3 = upshift(l_pontoreferencia[101,150]) clipped
                      let ws.ptoref4 = upshift(l_pontoreferencia[151,200]) clipped

                      let ws.ptoref1 = ws.ptoref1 clipped
                      let ws.ptoref2 = ws.ptoref2 clipped
                      let ws.ptoref3 = ws.ptoref3 clipped
                      let ws.ptoref4 = ws.ptoref4 clipped

                      if ws.ptoref2 is not null then
                        if ws.ptoref3 is null then
                           next field ptoref3
                        else
                          next field ptoref4
                        end if
                      else
                        if ws.ptoref1 is not null then
                           next field ptoref2
                        else
                           next field ptoref1
                        end if
                      end if
                   else
                      next field endzon
                   end if
                end if
             #end if
          end if

          if (upshift(m_lgdtip) = 'MARGINAL'  or
              upshift(m_lgdtip) = 'RODOVIA'  ) and
             l_pontoreferencia is null    then
             if fgl_lastkey() <> fgl_keyval("up")    and
                fgl_lastkey() <> fgl_keyval("left")  then

                call cts06g11_sentido(m_lgdnom
                                     ,m_lgdtip)
                   returning l_pontoreferencia

             else
                next field lgdnom
             end if


             let ws.ptoref1 = upshift(l_pontoreferencia[001,050]) clipped
             let ws.ptoref2 = upshift(l_pontoreferencia[051,100]) clipped
             let ws.ptoref3 = upshift(l_pontoreferencia[101,150]) clipped
             let ws.ptoref4 = upshift(l_pontoreferencia[151,200]) clipped

             let ws.ptoref1 = ws.ptoref1 clipped
             let ws.ptoref2 = ws.ptoref2 clipped
             let ws.ptoref3 = ws.ptoref3 clipped
             let ws.ptoref4 = ws.ptoref4 clipped

             if ws.ptoref2 is not null then
               if ws.ptoref3 is null then
                  next field ptoref3
               else
                  next field ptoref4
               end if
             else
               if ws.ptoref1 is not null then
                  next field ptoref2
               else
                  next field ptoref1
               end if
             end if

          end if



          if  lr_daf.status_ret = 0 then
              if  param.c24endtip = 1 then
                  if  l_fondafinf then
                      call cts06g03_inclui_temp_hstidx(2,
                                                       d_cts06g03.lgdtip,
                                                       d_cts06g03.lgdnom,
                                                       d_cts06g03.lgdnum,
                                                       d_cts06g03.brrnom,
                                                       d_cts06g03.cidnom,
                                                       d_cts06g03.ufdcod,
                                                       lr_daf.lclltt,
                                                       lr_daf.lcllgt)
                  else
                      if  m_flagsemidx then
                          call cts06g03_inclui_temp_hstidx(4,
                                                           d_cts06g03.lgdtip,
                                                           d_cts06g03.lgdnom,
                                                           d_cts06g03.lgdnum,
                                                           d_cts06g03.brrnom,
                                                           d_cts06g03.ufdcod,
                                                           d_cts06g03.cidnom,
                                                           d_cts06g03.lclltt,
                                                           d_cts06g03.lcllgt)
                      end if
                  end if
              end if
          end if

          if m_subbairro[1].brrnom <> d_cts06g03.brrnom then
              let d_cts06g03.lclbrrnom = d_cts06g03.brrnom
          end if
          let m_subbairro[1].brrnom = d_cts06g03.brrnom
   before field endcmp
          display by name d_cts06g03.endcmp attribute (reverse)
   after  field endcmp
          display by name d_cts06g03.endcmp
          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
                next field lgdnum
          end if
          display by name ws.ptoref1
          if param.atdsrvorg   = 16   and  # sinistro transportes
             d_cts06g03.ufdcod = "EX" then # sinistro fora do Brasil
             next field brrnom
          end if
          if (param.atdsrvorg = 1 or
             param.atdsrvorg = 2 or       # Mercosul
             param.atdsrvorg = 4) and
		         d_cts06g03.ufdcod = "EX" then
		         next field brrnom
		      end if
          #if l_flag_local_especial = "N" then
          #   #--------------------------------------------------------------
          #   # Verifica se a cidade possui mapa carregado
          #   #--------------------------------------------------------------
          #   initialize ws.mpacidcod  to null
          #   initialize ws.result     to null
          #
          #   call cts23g00_inf_cidade(2,"",d_cts06g03.cidnom, d_cts06g03.ufdcod)
          #      returning ws.result,
          #                ws.mpacidcod,
          #                ws.lclltt_cid,
          #                ws.lcllgt_cid,
          #                ws.mpacrglgdflg,
          #                ws.gpsacngrpcod
          #
          #   if param.atdsrvorg = 10 and    #OSF 19968
          #      v_retorno = 0 then
          #      let ws.mpacrglgdflg = null
          #   end if
          #   if ws.mpacrglgdflg = "1" then  # existe coordenadas por rua.
          #
          #      # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
          #      if  ctx25g05_rota_ativa() then
          #
          #          initialize lr_daf.*,
          #                     lr_ctx25g05.* to null
          #          let l_fondafinf   = false
          #
          #          if  param.c24endtip = 1 then
          #
          #              if  ctn55c00_verifica_srv_org(g_documento.c24astcod) then
          #
          #                  call ctn55c00_valida_endereco_daf(g_documento.succod,
          #                                                    g_documento.aplnumdig,
          #                                                    g_documento.itmnumdig,
          #                                                    g_funapol.vclsitatu,
          #                                                    "","")
          #                       returning lr_daf.status_ret,
          #                                 lr_daf.lclltt,
          #                                 lr_daf.lcllgt,
          #                                 lr_daf.ufdcod,
          #                                 lr_daf.cidnom,
          #                                 lr_daf.lgdtip,
          #                                 lr_daf.lgdnom,
          #                                 lr_daf.brrnom,
          #                                 lr_daf.numero
          #
          #                  if  lr_daf.status_ret = 0 then
          #                      call cts06g03_inclui_temp_hstidx(1,
          #                                                       lr_daf.lgdtip,
          #                                                       lr_daf.lgdnom,
          #                                                       lr_daf.numero,
          #                                                       lr_daf.brrnom,
          #                                                       lr_daf.cidnom,
          #                                                       lr_daf.ufdcod,
          #                                                       lr_daf.lclltt,
          #                                                       lr_daf.lcllgt)
          #
          #
          #                      if  ctn55c00_compara_end(lr_daf.lgdnom, d_cts06g03.lgdnom) or
          #                          ctn55c00_compara_end(lr_daf.lgdnomalt, d_cts06g03.lgdnom) then
          #                          #display "ENDERE�O DO INDEXACAO 2 MESMO QUE O DO INFORMADO PELO AGENTE."
          #                          let l_fondafinf = true
          #                      end if
          #                  end if
          #              else
          #                  let lr_daf.status_ret = 1
          #              end if
          #          else
          #              let l_fondafinf = false
          #              let lr_daf.status_ret = 1
          #          end if
          #
          #
          #          if  l_fondafinf then
          #              let d_cts06g03.lclltt = lr_daf.lclltt
          #              let d_cts06g03.lcllgt = lr_daf.lcllgt
          #              let d_cts06g03.c24lclpdrcod = 3
          #          else
          #              if  lr_daf.status_ret = 0 then
          #
          #                  call ctx25g05_prox(d_cts06g03.ufdcod,
          #                                     d_cts06g03.cidnom,
          #                                     d_cts06g03.lgdtip,
          #                                     d_cts06g03.lgdnom,
          #                                     d_cts06g03.lgdnum,
          #                                     d_cts06g03.brrnom,
          #                                     d_cts06g03.lclbrrnom,
          #                                     d_cts06g03.lgdcep,
          #                                     d_cts06g03.lgdcepcmp,
          #                                     d_cts06g03.lclltt,
          #                                     d_cts06g03.lcllgt,
          #                                     d_cts06g03.c24lclpdrcod,
          #                                     lr_daf.lclltt,
          #                                     lr_daf.lcllgt)
          #                           returning d_cts06g03.lgdtip,
          #                                     d_cts06g03.lgdnom,
          #                                     d_cts06g03.lgdnum,
          #                                     d_cts06g03.brrnom,
          #                                     d_cts06g03.lclbrrnom,
          #                                     d_cts06g03.lgdcep,
          #                                     d_cts06g03.lgdcepcmp,
          #                                     d_cts06g03.lclltt,
          #                                     d_cts06g03.lcllgt,
          #                                     d_cts06g03.c24lclpdrcod,
          #                                     d_cts06g03.ufdcod,
          #                                     d_cts06g03.cidnom,
          #                                     m_flagsemidx
          #
          #              else
          #                  call ctx25g05("C", # -> INPUT COMPLETO
          #                                "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
          #                                d_cts06g03.ufdcod,
          #                                d_cts06g03.cidnom,
          #                                d_cts06g03.lgdtip,
          #                                d_cts06g03.lgdnom,
          #                                d_cts06g03.lgdnum,
          #                                d_cts06g03.brrnom,
          #                                d_cts06g03.lclbrrnom,
          #                                d_cts06g03.lgdcep,
          #                                d_cts06g03.lgdcepcmp,
          #                                d_cts06g03.lclltt,
          #                                d_cts06g03.lcllgt,
          #                                d_cts06g03.c24lclpdrcod)
          #                      returning d_cts06g03.lgdtip,
          #                                d_cts06g03.lgdnom,
          #                                d_cts06g03.lgdnum,
          #                                d_cts06g03.brrnom,
          #                                d_cts06g03.lclbrrnom,
          #                                d_cts06g03.lgdcep,
          #                                d_cts06g03.lgdcepcmp,
          #                                d_cts06g03.lclltt,
          #                                d_cts06g03.lcllgt,
          #                                d_cts06g03.c24lclpdrcod,
          #                                d_cts06g03.ufdcod,
          #                                d_cts06g03.cidnom
          #              end if
          #          end if
          #
          #          # PSI 244589 - Inclus�o de Sub-Bairro - Burini
          #          let m_subbairro[1].brrnom = d_cts06g03.brrnom
          #
          #          call cts06g10_monta_brr_subbrr(d_cts06g03.brrnom,
          #                                         d_cts06g03.lclbrrnom)
          #               returning d_cts06g03.brrnom
          #      else
          #         call cts06g09(d_cts06g03.lgdtip,  #localiza coordenada da rua
          #                       d_cts06g03.lgdnom,
          #                       d_cts06g03.lgdnum,
          #                       d_cts06g03.brrnom,
          #                       ws.mpacidcod)
          #
          #              returning d_cts06g03.lgdtip,
          #                        d_cts06g03.lgdnom,
          #                        d_cts06g03.brrnom,
          #                        d_cts06g03.lgdcep,
          #                        d_cts06g03.lgdcepcmp,
          #                        d_cts06g03.lclltt,     # coord. da rua
          #                        d_cts06g03.lcllgt,
          #                        d_cts06g03.c24lclpdrcod
          #
          #          let m_subbairro[1].brrnom = d_cts06g03.brrnom
          #      end if
          #
          #      #if d_cts06g03.c24lclpdrcod <> 03 then
          #      #   let  d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
          #      #   let  d_cts06g03.lcllgt = ws.lcllgt_cid
          #      #end if
          #
          #      if d_cts06g03.c24lclpdrcod <> 03 or
          #         d_cts06g03.lclltt is null     or
          #         d_cts06g03.lclltt = 0         or
          #         d_cts06g03.lcllgt is null     or
          #         d_cts06g03.lcllgt = 0         then
          #
          #          let d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
          #          let d_cts06g03.lcllgt = ws.lcllgt_cid
          #          let d_cts06g03.c24lclpdrcod = 1
          #      end if
          #
          #      {
          #      if d_cts06g03.c24lclpdrcod <> 03 then
          #         open c_cts06g03_006 using ws.mpacidcod
          #                                ,d_cts06g03.brrnom
          #         fetch c_cts06g03_006 into l_lclltt
          #                                ,l_lcllgt
          #         if sqlca.sqlcode = 0 then
          #            let d_cts06g03.c24lclpdrcod = 3
          #            let d_cts06g03.lclltt = l_lclltt
          #            let d_cts06g03.lcllgt = l_lcllgt
          #         end if
          #      end if } # Inibido por Raji 24/06
          #   else
          #      let  d_cts06g03.lclltt = ws.lclltt_cid #salva corrd. da cidade
          #      let  d_cts06g03.lcllgt = ws.lcllgt_cid
          #
          #      if ws.cepflg  =  "0"  then
          #         call cts06g05(d_cts06g03.lgdtip,
          #                       d_cts06g03.lgdnom,
          #                       d_cts06g03.lgdnum,
          #                       d_cts06g03.brrnom,
          #                       ws.cidcod,
          #                       d_cts06g03.ufdcod)
          #             returning d_cts06g03.lgdtip,
          #                       d_cts06g03.lgdnom,
          #                       d_cts06g03.brrnom,
          #                       d_cts06g03.lgdcep,
          #                       d_cts06g03.lgdcepcmp,
          #                       d_cts06g03.c24lclpdrcod
          #
          #          let m_subbairro[1].brrnom = d_cts06g03.brrnom
          #      end if
          #   end if
          #
          #   if salva.lclltt = d_cts06g03.lclltt and   #ligia 09/10/07
          #      salva.lcllgt = d_cts06g03.lcllgt and
          #      salva.cidnom <> d_cts06g03.cidnom then
          #      let d_cts06g03.cidnom    = salva.cidnom
          #      let d_cts06g03.ufdcod    = salva.ufdcod
          #      let d_cts06g03.lgdtip    = salva.lgdtip
          #      let d_cts06g03.lgdnom    = salva.lgdnom
          #      let d_cts06g03.lgdnum    = salva.lgdnum
          #      let d_cts06g03.brrnom    = salva.brrnom
          #      let d_cts06g03.lclbrrnom = salva.lclbrrnom
          #
          #   else
          #      let salva.cidnom     =  d_cts06g03.cidnom
          #      let salva.ufdcod     =  d_cts06g03.ufdcod
          #      let salva.lgdtip     =  d_cts06g03.lgdtip
          #      let salva.lgdnom     =  d_cts06g03.lgdnom
          #      let salva.lgdnum     =  d_cts06g03.lgdnum
          #      let salva.brrnom     =  d_cts06g03.brrnom
          #      let salva.lclbrrnom  =  d_cts06g03.lclbrrnom
          #      let salva.lclltt     =  d_cts06g03.lclltt
          #      let salva.lcllgt     =  d_cts06g03.lcllgt
          #   end if
          #
          #   if d_cts06g03.c24lclpdrcod is null  then
          #      error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
          #      next field lgdnom
          #   end if
          #   if d_cts06g03.c24lclpdrcod <> 01  and   ### Fora de padrao
          #      d_cts06g03.c24lclpdrcod <> 02  and   ### Padrao Guia Postal
          #      d_cts06g03.c24lclpdrcod <> 03  and   ### Padrao Mapas Rua
          #      d_cts06g03.c24lclpdrcod <> 04  and   ### Padrao Mapas Bairro
          #      d_cts06g03.c24lclpdrcod <> 05  then  ### Padrao Mapas Sub-bairro
          #      error " Codigo de padronizacao invalido! AVISE A INFORMATICA!"
          #      next field lgdtip
          #   end if
          #   if d_cts06g03.c24lclpdrcod = 02  then
          #      call cts06g06(d_cts06g03.lgdnom)
          #          returning d_cts06g03.lgdnom
          #   end if
          #   display by name d_cts06g03.brrnom thru d_cts06g03.lcltelnum
          #   if d_cts06g03.brrnom is NOT NULL then
          #      next field endzon
          #   end if
          #end if

   before field endzon
          display by name d_cts06g03.endzon attribute (reverse)
          let ws.cepflg = "0"

          # >> ronaldo, meta
          if upshift(m_lgdtip) = 'MARGINAL' or
             upshift(m_lgdtip) = 'RODOVIA'  then
             next field ptoref1
          end if
          # << ronaldo, meta



   after  field endzon
          display by name d_cts06g03.endzon

          if d_cts06g03.endzon is not null  then
             if d_cts06g03.endzon <> "NO"  and
                d_cts06g03.endzon <> "LE"  and
                d_cts06g03.endzon <> "OE"  and
                d_cts06g03.endzon <> "SU"  and
                d_cts06g03.endzon <> "CE"  then
               error "Zona deve ser (NO)rte,(LE)ste,(OE)ste,(SU)l ou (CE)ntral!"
                next field endzon
             end if
          end if
# Inicio - Situa��o local de ocorr�ncia
{
   # Inicio - Priscila 20/01/2006
   # Permite escolher outra via emergencial caso limpe a variavel.
     before field decide_via
#         if l_resultado = 2 then
#        if l_resultado <> 1 then
         if (param.atdsrvorg = 1 or param.atdsrvorg = 2  or
             param.atdsrvorg = 4 or param.atdsrvorg = 6) and
             param.c24endtip = 1 then

              let lr_salva.emeviacod = lr_emeviacod.emeviacod
              let lr_salva.emeviades = lr_ctc17m02.emeviades
         else
            #nao exibe via emergencial
            let ws.decide_via = "S"
            let lr_emeviacod.emeviacod = null
            next field  lclcttnom
         end if

         display by name ws.decide_via attribute (reverse)

    after field decide_via

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endzon
         end if

         if ws.decide_via = "N" then
            if lr_emeviacod.emeviacod is not null then
               error "Limpe o campo para selecionar outra via emergencial!"
               next field decide_via
            end if
         end if

         if ws.decide_via is null or
            (ws.decide_via = 'S' and lr_emeviacod.emeviacod is null) then
            call ctc17m02_popup_via(g_issk.dptsgl)
                  returning l_resultado
                           ,lr_emeviacod.emeviacod
                           ,lr_ctc17m02.emeviades
                           ,lr_ctc17m02.emeviapri
            if lr_emeviacod.emeviacod is null then
               let ws.decide_via = 'N'
            else
               let ws.decide_via = 'S'
            end if
            display by name ws.decide_via
            display by name lr_emeviacod.emeviacod
            display by name lr_ctc17m02.emeviades
         end if
} #Fim - Situa��o local de ocorr�ncia

#        if ws.decide_via = "N" then
#           let lr_emeviacod.emeviacod = null
#           let lr_ctc17m02.emeviades = null
#           display by name lr_emeviacod.emeviacod
#           display by name lr_ctc17m02.emeviades
#           next field lclcttnom
#        else
#            if lr_emeviacod.emeviacod is null then
#               initialize lr_ctc17m02.* to null
#               call ctc17m02_popup_via(g_issk.dptsgl)
#                  returning l_resultado
#                           ,lr_emeviacod.emeviacod
#                           ,lr_ctc17m02.emeviades
#                           ,lr_ctc17m02.emeviapri
#            end if
#            display by name lr_emeviacod.emeviacod
#            display by name lr_ctc17m02.emeviades
#        end if
#
#   before field emeviacod
#
#     if l_via_desc is not null then
#        display by name lr_emeviacod.emeviacod attribute (reverse)
#     else
#        if fgl_lastkey() = fgl_keyval("up")    or
#           fgl_lastkey() = fgl_keyval("left")  then
#           next field endzon
#        else
#           next field lclcttnom
#        end if
#     end if
#
#  after field emeviacod
#     #Se existe via cadastrada para o departamento, entrar com a via.
#     if (param.atdsrvorg = 1  or
#        param.atdsrvorg = 2  or
#        param.atdsrvorg = 4  or
#        param.atdsrvorg = 6) then
#        display by name lr_emeviacod.emeviacod
#
#        initialize lr_ctc17m02.* to null
#        if lr_emeviacod.emeviacod is null then #cadastro
#           call ctc17m02_popup_via(g_issk.dptsgl)
#              returning l_resultado
#                       ,lr_emeviacod.emeviacod
#                       ,lr_ctc17m02.emeviades
#                       ,lr_ctc17m02.emeviapri
#
#            if l_resultado = 2 then
#              let lr_emeviacod.emeviacod = lr_salva.emeviacod
#              let lr_ctc17m02.emeviades = lr_salva.emeviades
#              next field emeviacod
#           end if
#
#        else #atualizacao
#           call ctc17m02_obter_via(lr_emeviacod.emeviacod,g_issk.dptsgl)
#              returning l_resultado
#                       ,l_mensagem
#                       ,lr_ctc17m02.emeviades
#                       ,lr_ctc17m02.emeviapri
#
#           if l_resultado <> 1 then
#              error l_mensagem
#              initialize lr_ctc17m02.* to null
#              initialize lr_emeviacod.* to null
#              display by name lr_emeviacod.*
#              next field emeviacod
#           end if
#        end if
#
#
#           display by name lr_emeviacod.emeviacod
#           display by name lr_ctc17m02.emeviades
#
#     end if
     #Fim Priscila 26/01/2006


   if  lr_daf.status_ret = 0 then
       if  param.c24endtip = 1 then
           #display "FLAG FONETICA: ", l_fondafinf
           if  l_fondafinf then
               #display "5"
               call cts06g03_inclui_temp_hstidx(2,
                                                d_cts06g03.lgdtip,
                                                d_cts06g03.lgdnom,
                                                d_cts06g03.lgdnum,
                                                d_cts06g03.brrnom,
                                                d_cts06g03.cidnom,
                                                d_cts06g03.ufdcod,
                                                d_cts06g03.lclltt,
                                                d_cts06g03.lcllgt)
           else
               if  m_flagsemidx then
                   #display "6"
                   call cts06g03_inclui_temp_hstidx(4,
                                                    d_cts06g03.lgdtip,
                                                    d_cts06g03.lgdnom,
                                                    d_cts06g03.lgdnum,
                                                    d_cts06g03.brrnom,
                                                    d_cts06g03.ufdcod,
                                                    d_cts06g03.cidnom,
                                                    d_cts06g03.lclltt,
                                                    d_cts06g03.lcllgt)
               end if
           end if
       end if
   end if

   before field lclcttnom
          display by name d_cts06g03.lclcttnom attribute (reverse)

   after  field lclcttnom
          display by name d_cts06g03.lclcttnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             
             if l_flag_auto = 'N' OR cts06g11_verif_bloq()  then
                next field endzon
             else   		
                next field ocrlclstt
             end if
             
#Inicio - Situa��o local de ocorr�ncia
{
             if ws.decide_via = "N" then
                next field decide_via
             end if
             if lr_emeviacod.emeviacod is not null then
                next field emeviacod
             else
                next field endzon
             end if
}
#Fim - Situa��o local de ocorr�ncia
          end if

          if (d_cts06g03.lclcttnom is null or
              d_cts06g03.lclcttnom = " " ) and
              param.c24endtip = 1 then
             error "Contato deve ser informado!"
             next field lclcttnom
          end if
          next field celteldddcod

#Inicio - Situa��o local de ocorr�ncia
   before field ocrlclstt

   if l_flag_auto = 'N' OR cts06g11_verif_bloq()  then
        next field lclcttnom
   else   		
        display by name ws.ocrlclstt attribute (reverse)      
   end if

   after  field ocrlclstt
          display by name ws.ocrlclstt
          
        if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endzon
         end if
         
        if ws.ocrlclstt <> 'S' AND ws.ocrlclstt <> 'N' then
             error "Tipo Local de Ocorr�ncia inv�lido! Informe 'S' ou 'N'"
             next field ocrlclstt
        else
             open  c_cts06g03_010 using ws.ocrlclstt
             fetch c_cts06g03_010  into lr_emeviacod.emeviacod
             let lr_salva.emeviacod = lr_emeviacod.emeviacod
        end if

#Fim - Situa��o local de ocorr�ncia

        open  c_cts06g03_010 using ws.ocrlclstt
        fetch c_cts06g03_010  into lr_emeviacod.emeviacod

          
   before field celteldddcod
          display by name d_cts06g03.celteldddcod attribute (reverse)
   after  field celteldddcod
          display by name d_cts06g03.celteldddcod

   before field celtelnum
          display by name d_cts06g03.celtelnum attribute (reverse)

   after  field celtelnum
          display by name d_cts06g03.celtelnum

          if (d_cts06g03.celteldddcod    is not null  and
              d_cts06g03.celtelnum is null   )  or
             (d_cts06g03.celteldddcod    is null      and
              d_cts06g03.celtelnum is not null) then
             error " Numero de telefone celular incompleto! "
             next field celteldddcod
          end if
             next field dddcod
   before field dddcod
          display by name d_cts06g03.dddcod attribute (reverse)

   after  field dddcod
          display by name d_cts06g03.dddcod

   before field lcltelnum
          display by name d_cts06g03.lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name d_cts06g03.lcltelnum

          if (d_cts06g03.dddcod    is not null  and
              d_cts06g03.lcltelnum is null   )  or
             (d_cts06g03.dddcod    is null      and
              d_cts06g03.lcltelnum is not null) then
             error " Numero de telefone incompleto! "
             next field dddcod
          end if
          next field ptoref1

   before field ptoref1
          display by name ws.ptoref1 attribute (reverse)

   after  field ptoref1
          display by name ws.ptoref1

          # >> ronaldo, meta
          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if upshift(m_lgdtip) = 'MARGINAL' or
                upshift(m_lgdtip) = 'RODOVIA'  then

                let m_lgdtip = null
                let m_lgdnom = null

                next field lcltelnum
             end if
          end if
      # << ronaldo, meta

   before field ptoref2
          display by name ws.ptoref2 attribute (reverse)

   after  field ptoref2
          display by name ws.ptoref2

   before field ptoref3
          display by name ws.ptoref3 attribute (reverse)

   after  field ptoref3
          display by name ws.ptoref3

   before field ptoref4
          display by name ws.ptoref4 attribute (reverse)

   after  field ptoref4
          display by name ws.ptoref4

   on key (f3)

      if  (d_cts06g03.cidnom is not null and d_cts06g03.cidnom <> " ") and
          (d_cts06g03.ufdcod is not null and d_cts06g03.ufdcod <> " ") then
              call ctc87m00_orientacao_preenchimento(d_cts06g03.cidnom,
                                                     d_cts06g03.ufdcod)
      else
          error "Para consulta a cidade e o estado devem ser informados."
          next field cidnom
      end if


   on key (interrupt)
      #------------------------------------------------------------------
      # Verifica se os dados foram alterados e nao confirmados
      #------------------------------------------------------------------
      #if salva.cidnom  is not null   then   #ligia 09/10/07
         if d_cts06g03.cidnom  <>  salva.cidnom   then
            let ws.retflg = "N"
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field cidnom
         end if
      #end if
      #if salva.ufdcod  is not null   then
         if d_cts06g03.ufdcod  <>  salva.ufdcod   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field ufdcod
         end if
      #end if
      #if salva.lgdtip  is not null   then
         if d_cts06g03.lgdtip  <>  salva.lgdtip   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdtip
         end if
      #end if
      #if salva.lgdnom  is not null   then
         if d_cts06g03.lgdnom  <>  salva.lgdnom   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdnom
         end if
      #end if
      #if salva.lgdnum  is not null   then
         if d_cts06g03.lgdnum  <>  salva.lgdnum   then
            call cts08g01("A","N", "","NAO E' POSSIVEL ABANDONAR A TELA",
                                   "DADOS SOBRE O LOCAL FORAM ALTERADOS",
                                   "MAS NAO FORAM CONFIRMADOS")
                 returning ws.confirma
            next field lgdnum
         end if
      #end if

      exit input

   on key (F5)
      if param.atdsrvorg <> 10 then # vistoria previa
         ##-- Exibir espelho da apolice --##
         let g_monitor.horaini = current ## Flexvision
         call cta01m12_espelho(g_documento.ramcod
                              ,g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,g_documento.prporg
                              ,g_documento.prpnumdig
                              ,g_documento.fcapacorg
                              ,g_documento.fcapacnum
                              ,g_documento.pcacarnum
                              ,g_documento.pcaprpitm
                              ,g_ppt.cmnnumdig
                              ,g_documento.crtsaunum
                              ,g_documento.bnfnum
                              ,g_documento.ciaempcod)
      end if

   on key (F4)
      if param.atdsrvorg =  4   and   # remocao
         ws.locflg    = "N"  then
         call ctc54m00_patio("","")
              returning d_cts06g03.lclidttxt,
                        d_cts06g03.lgdtip,
                        d_cts06g03.lgdnom,
                        d_cts06g03.lgdnum,
                        d_cts06g03.brrnom,
                        d_cts06g03.cidnom,
                        d_cts06g03.ufdcod,
                        d_cts06g03.lclrefptotxt,
                        d_cts06g03.endzon,
                        d_cts06g03.lgdcep,
                        d_cts06g03.lgdcepcmp,
                        d_cts06g03.dddcod,
                        d_cts06g03.lcltelnum,
                        d_cts06g03.lclcttnom,
                        d_cts06g03.lclltt,
                        d_cts06g03.lcllgt,
                        d_cts06g03.c24lclpdrcod

         display by name d_cts06g03.lclidttxt
         display by name d_cts06g03.lgdtip
         display by name d_cts06g03.lgdnom
         display by name d_cts06g03.lgdnum
         display by name d_cts06g03.brrnom
         display by name d_cts06g03.cidnom
         display by name d_cts06g03.ufdcod
         display by name d_cts06g03.endzon
         display by name d_cts06g03.lgdcep
         display by name d_cts06g03.lgdcepcmp
         display by name d_cts06g03.dddcod
         display by name d_cts06g03.lcltelnum
         display by name d_cts06g03.lclcttnom
      end if

   on key (F6)
      if param.atdsrvorg <>  3   then
         if g_documento.atdsrvnum is null  then
            call cts10m02 (hist_cts06g03.*) returning hist_cts06g03.*
         else
            call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                          g_issk.funmat        , param.hoje  ,param.hora)
         end if
      end if

   on key (F7)
      if ws.benef = "S"  then
         call cts06g03_oficina("B","")
              returning d_cts06g03.ofnnumdig,
                        d_cts06g03.lclidttxt,
                        d_cts06g03.lgdnom,
                        d_cts06g03.brrnom,
                        d_cts06g03.cidnom,
                        d_cts06g03.ufdcod,
                        d_cts06g03.lgdcep,
                        d_cts06g03.lgdcepcmp
         if d_cts06g03.ofnnumdig is not null then
            let d1_cts06g03.obsofic = "* Oficina Beneficio *"
            display by name d1_cts06g03.obsofic
         end if
      end if

   on key (F8)
      if param.c24endtip = 2  then
         if g_documento.ciaempcod = 84 then
            call cts08g01("A","S",""
                         ,"ESTAS OFICINAS ATENDEM APENAS"
                         ,"CARROS DE PASSEIO."
                         ,"DESEJA PROSSEGUIR?")
                 returning ws.confirma
            if ws.confirma = "S" then
               call ctc91m19()
               returning d_cts06g03.ofnnumdig
                        ,d_cts06g03.lclidttxt
                        ,d_cts06g03.lgdtip
                        ,d_cts06g03.lgdnom
                        ,d_cts06g03.lgdnum
                        ,d_cts06g03.endcmp
                        ,d_cts06g03.brrnom
                        ,d_cts06g03.cidnom
                        ,d_cts06g03.ufdcod
                        ,d_cts06g03.lgdcep
                        ,d_cts06g03.lgdcepcmp
                        ,d_cts06g03.lclltt
                        ,d_cts06g03.lcllgt
                        ,d_cts06g03.lclcttnom
                        ,d_cts06g03.dddcod
                        ,d_cts06g03.lcltelnum
                        ,d_cts06g03.endzon
               let d_cts06g03.ofnnumdig = null # Desprezo o que foi retornado
               display by name d_cts06g03.lclidttxt
                              ,d_cts06g03.lgdtip
                              ,d_cts06g03.lgdnom
                              ,d_cts06g03.lgdnum
                              ,d_cts06g03.endcmp
                              ,d_cts06g03.brrnom
                              ,d_cts06g03.cidnom
                              ,d_cts06g03.ufdcod
                              ,d_cts06g03.lgdcep
                              ,d_cts06g03.lgdcepcmp
                              ,d_cts06g03.lclltt
                              ,d_cts06g03.lcllgt
                              ,d_cts06g03.lclcttnom
                              ,d_cts06g03.dddcod
                              ,d_cts06g03.lcltelnum
               if d_cts06g03.lclltt is not null and
                  d_cts06g03.lclltt <> 0 and
                  d_cts06g03.lcllgt is not null and
                  d_cts06g03.lcllgt <> 0 then
                  let d_cts06g03.c24lclpdrcod = 03
#                  next field decide_via - #Situa��o Local de ocorr�ncia
               end if
            end if
         else
         if ws.locflg = "S"  then
            call cts06g03_locadora(param.ligcvntip,
                                   d_cts06g03.cidnom,
                                   d_cts06g03.ufdcod)
                returning d_cts06g03.lclidttxt,
                          d_cts06g03.lgdnom,
                          d_cts06g03.brrnom,
                          d_cts06g03.cidnom,
                          d_cts06g03.ufdcod,
                          d_cts06g03.lgdcep,
                          d_cts06g03.lgdcepcmp
         else
            let ws.ramcod = g_documento.ramcod
            if ws.clscod = "096" then
               let ws.ramcod = 16
            end if
            let ws.ok  =  "S"
            if ws.benefx = "S" then     #OSF 19968
               call cts08g01("A","S",""     #OSF 19968
                            ," ESTAS OFICINAS NAO OFERECEM O"
                            ," BENEFICIO DE SINISTRO."
                            ," DESEJA PROSSEGUIR A CONSULTA?")
                    returning ws.confirma
               if ws.confirma = "N" then
                  let ws.ok = "N"
               end if
            end if
            if ws.ok = "S" then
            call ctn06n00(ws.ramcod,"")
                returning d_cts06g03.ofnnumdig,
                          d_cts06g03.lclidttxt,
                          d_cts06g03.lgdnom,
                          d_cts06g03.brrnom,
                          d_cts06g03.cidnom,
                          d_cts06g03.ufdcod
            if ws.benef = "S"  then
               if ws.ofnnumdig = d_cts06g03.ofnnumdig then
                  let d1_cts06g03.obsofic = "* Oficina Beneficio *"
               else
                  initialize d1_cts06g03.obsofic to null
               end if
               display by name d1_cts06g03.obsofic
            end if
            initialize d1_cts06g03.staofic to null
            if d_cts06g03.ofnnumdig is not null then
               select ofnstt
                   into ws.ofnstt
                   from sgokofi
                  where ofnnumdig = d_cts06g03.ofnnumdig
               if ws.ofnstt = "C" then
                  let d1_cts06g03.staofic  = "OBSERVACAO"
                  display by name d1_cts06g03.staofic attribute (reverse)
               end if
            end if
            end if
         end if
      end if
      end if

   on key (F9)
      if param.atdsrvorg =  4   and   # remocao
         ws.locflg       = "N"  and
         g_documento.ciaempcod <> 84 then
         call cts06g03_oficina("C","")
              returning d_cts06g03.ofnnumdig,
                        d_cts06g03.lclidttxt,
                        d_cts06g03.lgdnom,
                        d_cts06g03.brrnom,
                        d_cts06g03.cidnom,
                        d_cts06g03.ufdcod,
                        d_cts06g03.lgdcep,
                        d_cts06g03.lgdcepcmp
         if d_cts06g03.ofnnumdig is not null then
            if ws.benef = "S"  then
              if ws.ofnnumdig = d_cts06g03.ofnnumdig then
                 let d1_cts06g03.obsofic = "* Oficina Beneficio *"
              else
                 let d1_cts06g03.obsofic = "* Cadastro Beneficio *"
              end if
            end if
         end if
         display by name d1_cts06g03.obsofic
      end if
 end input

 #let d_cts06g03.lclbrrnom = d_cts06g03.brrnom

 if int_flag  then
    let int_flag = false
 end if
 #if param.atdsrvorg = 10 then # Vist. Previa
 #   if salva.ufdcod <> d_cts06g03.ufdcod then
 #      close window cts06g03
 #      let ws.retflg = "S"
 #      return d_cts06g03.*, ws.retflg, hist_cts06g03.*
 #   end if
 #end if
 let d_cts06g03.lclrefptotxt = ws.ptoref1 ,
                               ws.ptoref2 ,
                               ws.ptoref3 ,
                               ws.ptoref4

 if d_cts06g03.cidnom        is not null  and
    d_cts06g03.ufdcod        is not null  and
    d_cts06g03.brrnom     is not null  and
  # d_cts06g03.brrnom        is not null  and

  # Inibido por Lucas Scheid - 30/10/06 - Conforme chamado 6107715
  # Nao e necessario validar o tipo de logradouro
  # d_cts06g03.lgdtip        is not null  and

    d_cts06g03.lgdnom        is not null  and
    d_cts06g03.c24lclpdrcod  is not null  then
   
    let ws.retflg = "S"
 end if
 #------------------------------------------------------------------
 # Verifica se UF foi alterada e nao foi feita pesquisa no cadastro
 #------------------------------------------------------------------
 select ufdcod
   from glakest
  where ufdcod = d_cts06g03.ufdcod

 if sqlca.sqlcode = notfound then
    let ws.retflg = "N"
 end if
 #------------------------------------------------------------------------
 # Verifica se cidade foi alterada e nao foi feita pesquisa no cadastro
 #------------------------------------------------------------------------
 declare c_glakcid2 cursor for
    select cidcod
      from glakcid
     where cidnom = d_cts06g03.cidnom
       and ufdcod = d_cts06g03.ufdcod

 open  c_glakcid2
 fetch c_glakcid2

 if sqlca.sqlcode = notfound   then
    open  c_datkmpacid using d_cts06g03.cidnom,
                             d_cts06g03.ufdcod
    fetch c_datkmpacid

    let ws.retflg = "S"
    if sqlca.sqlcode = notfound   then
       let ws.retflg = "N"
    end if
 end if
 #------------------------------------------------------------------------
 # Verifica se cidade foi alterada (mapas)
 #------------------------------------------------------------------------
 if d_cts06g03.c24lclpdrcod = 03   then
    #declare c_datkmpacid  cursor for
    #   select mpacidcod
    #     from datkmpacid
    #    where cidnom = d_cts06g03.cidnom
    #      and ufdcod = d_cts06g03.ufdcod
    #open  c_datkmpacid
    #fetch c_datkmpacid
    #declare c_datkmpacid  cursor for
    #   select mpacidcod
    #     from datkmpacid
    #    where cidnom = d_cts06g03.cidnom
    #      and ufdcod = d_cts06g03.ufdcod
    open  c_datkmpacid using d_cts06g03.cidnom,
                             d_cts06g03.ufdcod
    fetch c_datkmpacid

    if sqlca.sqlcode = notfound   then
       let ws.retflg = "N"
    end if
 end if
 #------------------------------------------------------------------------
 # Verifica padrao guia postal
 #------------------------------------------------------------------------
 if d_cts06g03.c24lclpdrcod = 02   then
    if d_cts06g03.lgdcep    is not null   and
       d_cts06g03.lgdcepcmp is not null   then
       open  c_cts06g03_001  using  d_cts06g03.lgdcep,
                               d_cts06g03.lgdcepcmp
       fetch c_cts06g03_001  into   ws.lgdtip,
                               ws.lgdnom,
                               ws.cidcod,
                               ws.brrcod
       if sqlca.sqlcode  =  notfound   then
          let ws.retflg = "N"
       else
          # Inibido por Lucas Scheid - 30/10/06 - Conforme chamado 6107715
          # Nao e necessario validar o tipo de logradouro
          ##if d_cts06g03.lgdtip <> ws.lgdtip then
          ##   let ws.retflg = "N"
          ##end if
       end if
    end if
 end if
 close window cts06g03

 if  d_cts06g03.lgdcep is null  and
     param.atdsrvorg   =  10    then         #vistoria previa
     let d_cts06g03.lgdcep    = ws.cidcep    #se nao encontrar cep da rua
     let d_cts06g03.lgdcepcmp = ws.cidcepcmp #pegar da cidade. VP roterizada.
 end if

 ######## REMOVIDO POR SOLICITACAO DO CESAR EM 01/10/2009
 ###if d_cts06g03.c24lclpdrcod = 3 and
 ###   d_cts06g03.lclltt is null and
 ###   d_cts06g03.lgdnom is not null then
 ###
 ###   display "******** ERRO ERRO  ERRO ****************"
 ###   display "SERVICO ", g_documento.atdsrvnum
 ###   display 'ENTROU ', entrou.*
 ###   display '-------'
 ###   display 'SAIU   ', d_cts06g03.*
 ###   display "******** ERRO ERRO  ERRO ****************"
 ###   display "AVISAR O CESAR/RADIO SOBRE ESTA INDEXACAO"
 ###   prompt "Tecle <enter> p/continuar " for l_ret
 ###end if

  if d_cts06g03.c24lclpdrcod = 1 or # PSI 252891
    d_cts06g03.c24lclpdrcod = 2 then
     call cts06g03_idx_brr(d_cts06g03.ufdcod,
                           d_cts06g03.cidnom,
                           m_subbairro[1].brrnom,
                           d_cts06g03.lclbrrnom,
                           d_cts06g03.lclltt,
                           d_cts06g03.lcllgt,
                           d_cts06g03.c24lclpdrcod)
         returning l_erro,
                   lr_idx_brr.lclltt,
                   lr_idx_brr.lcllgt,
                   lr_idx_brr.c24lclpdrcod

     if l_erro = 0 then
         let d_cts06g03.lclltt       = lr_idx_brr.lclltt
         let d_cts06g03.lcllgt       = lr_idx_brr.lcllgt
         let d_cts06g03.c24lclpdrcod = lr_idx_brr.c24lclpdrcod
     else
         if l_erro = 2 then
             error "Erro na indexacao por bairro e sub-bairro. AVISE A INFORMATICA"
             sleep 2
         end if
     end if
 end if
 #ligia 27/12/2006
 if g_documento.atdsrvnum is not null and
    param.atdsrvorg <> 10 then
    call cts06g03_valida_indexacao(l_c24lclpdrcod, d_cts06g03.c24lclpdrcod)
 end if

 #CHAMADO 91015273
 if m_subbairro[1].brrnom is not null and m_subbairro[1].brrnom <> " " then
    let d_cts06g03.brrnom = m_subbairro[1].brrnom
 end if

 if  d_cts06g03.lclbrrnom is null or d_cts06g03.lclbrrnom = " " and
     d_cts06g03.brrnom is not null and d_cts06g03.brrnom <> " " then
     let d_cts06g03.lclbrrnom = d_cts06g03.brrnom
 end if

 if  d_cts06g03.brrnom is null or d_cts06g03.brrnom = " " and
     d_cts06g03.lclbrrnom is not null and d_cts06g03.lclbrrnom <> " " then
     let d_cts06g03.brrnom = d_cts06g03.lclbrrnom
 end if

 if  lr_daf.status_ret = 0 then
     let d_cts06g03.ufdcod = lr_daf.ufdcod
     let d_cts06g03.cidnom = lr_daf.cidnom
 end if

 call cts06g03_carrega_glo(param.c24endtip,param.atdsrvorg,ws.mpacidcod, ws.cidcod)

 return d_cts06g03.*, ws.retflg, hist_cts06g03.*,lr_emeviacod.emeviacod

end function  ###  cts06g03

#-----------------------------------------------------------
 function cts06g03_locadora(param)
#-----------------------------------------------------------

 define param      record
    ligcvntip      like datmligacao.ligcvntip,
    cidnom         like glakcid.cidnom,
    ufdcod         like glakest.ufdcod
 end record
 define ws         record
    diasem         smallint,
    lcvcod         like datkavislocal.lcvcod,
    aviestcod      like datkavislocal.aviestcod,
    vclpsqflg      smallint,
    lclidttxt      like datmlcl.lclidttxt,
    lgdnom         like datmlcl.lgdnom,
    brrnom      like datmlcl.brrnom,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp
 end record

 define l_cidcod   like glakcid.cidcod      #PSI 198390
 define l_ret      smallint,
        l_msg      char(100)

 define l_data    date,
        l_hora2   datetime hour to minute

 initialize ws.*  to null

 if param.cidnom is not null  or
    param.ufdcod is not null  then
    let param.cidnom = "SAO PAULO"
    let param.ufdcod = "SP"
 end if
 call ctn00c02 (param.ufdcod,param.cidnom,"","")
      returning ws.lgdcep, ws.lgdcepcmp

 if ws.lgdcep is null then
    error " Nenhum cep foi selecionado!"
 else
    case param.ligcvntip
       when 89  let ws.lcvcod = 1   ###  AVIS ASSISTANCE
       when 90  let ws.lcvcod = 5   ###  MEGA ASSISTANCE
       when 91  let ws.lcvcod = 6   ###  SEG CAR LOCADORA
       when 92  let ws.lcvcod = 3   ###  REPAR RENT A CAR
    end case
    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2
    let ws.diasem = weekday(l_data)
   #call ctn18c00 (ws.lcvcod, ws.lgdcep, "", ws.diasem, 0, false) -- OSF 37184
   #call ctn18c00 (ws.lcvcod, ws.lgdcep, "", ws.diasem, 0, 0)     -- OSF 37184
    call ctn18c00 (ws.lcvcod, ws.lgdcep, ws.lgdcepcmp, "", ws.diasem, 0, 0)#PSI198390
         returning ws.lcvcod, ws.aviestcod, ws.vclpsqflg
    if ws.lcvcod    is null  or
       ws.aviestcod is null  then
       error " Nenhuma loja foi selecionada!"
    else
       select aviestnom, endlgd   ,
              endbrr   , endcid   ,
              endufd   , endcep   ,
              endcepcmp
         into ws.lclidttxt,
              ws.lgdnom,
              ws.brrnom,
              ws.cidnom,
              ws.ufdcod,
              ws.lgdcep,
              ws.lgdcepcmp
         from datkavislocal
        where lcvcod    = ws.lcvcod
          and aviestcod = ws.aviestcod
       if sqlca.sqlcode = notfound  then
          error " Nao foi possivel localizar a loja. AVISE A INFORMATICA!"
       end if
    end if
 end if
 return ws.lclidttxt,
        ws.lgdnom,
        ws.brrnom,
        ws.cidnom,
        ws.ufdcod,
        ws.lgdcep,
        ws.lgdcepcmp
end function  ###  cts06g03_locadora

#-----------------------------------------------------------
 function cts06g03_oficina(param)
#-----------------------------------------------------------
 define param      record
    tipo           char (01),
    tela           char (08)
 end record

 define ws         record
    ofnnumdig      like sgokofi.ofnnumdig,
    lclidttxt      like datmlcl.lclidttxt,
    lgdnom         like datmlcl.lgdnom,
    brrnom      like datmlcl.brrnom,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp
 end record

 define l_msg    char(200)
 define l_status smallint

 initialize ws.*  to null
 if param.tela <> "cta01m02" then
    message " Aguarde, pesquisando..." attribute (reverse)
 end if

 let l_msg = null
 let l_status = null
 let m_server   = fun_dba_servidor("SINIS")
 let m_hostname = "porto@",m_server clipped , ":"

 call cta13m00_verifica_status(m_hostname)
      returning l_status,l_msg

 if param.tipo  =  "B"  then   # consulta Oficina do Beneficio
   if l_status = true then
      call fsgoa007_credenciada(g_documento.succod,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig,
                                g_documento.edsnumref,"")
           returning ws.ofnnumdig
   else
     error "Oficinas n�o disponiveis no momento ! ",l_msg
     sleep 2
   end if

 else
    if l_status = true then
       call fsgoa007_credenciada("","","","","")
            returning ws.ofnnumdig
    else
     error "Oficinas n�o disponiveis no momento ! ",l_msg
     sleep 2
    end if
 end if



 if param.tela <> "cta01m02" then
    if param.tipo = "B" then
        message " (F17)Abandona,<E>spelho,(F7)Revendas,(F8)Oficinas,(F9)Ofic.Ref."
    else
        message " (F17)Abandona,<E>spelho,(F8)Oficinas,(F9)Ofic.Ref."
    end if
 end if

 if ws.ofnnumdig is null  then
    error " Nenhuma oficina foi selecionada!"
 else
    select nomrazsoc, endlgd,
           endbrr   , endcid,
           endufd   , endcep,
           endcepcmp
      into ws.lclidttxt,
           ws.lgdnom,
           ws.brrnom,
           ws.cidnom,
           ws.ufdcod,
           ws.lgdcep,
           ws.lgdcepcmp
      from gkpkpos
     where pstcoddig = ws.ofnnumdig
    if sqlca.sqlcode = notfound  then
       error " Nao foi possivel localizar dados da oficina selecionada!"
    end if
 end if
 return ws.*

end function  ###  cts06g03_oficina

function cts06g03_valida_indexacao(l_c24lclpdrcod_ant, l_c24lclpdrcod_atu)

   define l_c24lclpdrcod_ant like datmlcl.c24lclpdrcod,
          l_c24lclpdrcod_atu like datmlcl.c24lclpdrcod,
          l_descricao        char(70),
          l_resultado        integer,
          l_data             date,
          l_hora             datetime hour to minute

   let l_resultado = null
   let l_descricao = null
   let l_data = null
   let l_hora = null
   # Anterior S/ Index
   if l_c24lclpdrcod_ant = 1 and l_c24lclpdrcod_atu = 1 then
      let l_descricao = "SRV CONTINUA S/INDEX"
   end if

   if l_c24lclpdrcod_ant = 1 and l_c24lclpdrcod_atu = 2 then
      let l_descricao = "SRV S/INDEX FOI AGORA INDEX PELO GUIA POSTAL"
   end if

   if l_c24lclpdrcod_ant = 1 and l_c24lclpdrcod_atu = 3 then
      let l_descricao = "SRV S/INDEX FOI AGORA INDEX PELA COORD DA RUA"
   end if
   if l_c24lclpdrcod_ant = 1 and l_c24lclpdrcod_atu = 4 then
      let l_descricao = "SRV S/INDEX FOI AGORA INDEX PELA COORD DO BRR"
   end if
   if l_c24lclpdrcod_ant = 1 and l_c24lclpdrcod_atu = 5 then
      let l_descricao = "SRV S/INDEX FOI AGORA INDEX PELA COORD DO SUB-BRR"
   end if

   # Anterior Indexado pelo Guia Postal
   if l_c24lclpdrcod_ant = 2 and l_c24lclpdrcod_atu = 1 then
      let l_descricao = "SRV INDEX PELO GUIA POSTAL FICOU AGORA S/INDEX"
   end if

   if l_c24lclpdrcod_ant = 2 and l_c24lclpdrcod_atu = 2 then
      let l_descricao = "SRV CONTINUA INDEX PELO GUIA POSTAL"
   end if

   if l_c24lclpdrcod_ant = 2 and l_c24lclpdrcod_atu = 3 then
      let l_descricao = "SRV INDEX PELO GUIA POSTAL FOI AGORA INDEX PELA COORD DA RUA"
   end if
   if l_c24lclpdrcod_ant = 2 and l_c24lclpdrcod_atu = 4 then
      let l_descricao = "SRV INDEX PELO GUIA POSTAL FOI AGORA INDEX PELA COORD DO BRR"
   end if
   if l_c24lclpdrcod_ant = 2 and l_c24lclpdrcod_atu = 5 then
      let l_descricao = "SRV INDEX PELO GUIA POSTAL FOI AGORA INDEX PELA COORD DO SUB-BRR"
   end if

   # Anterior Indexado pela coordenada da rua
   if l_c24lclpdrcod_ant = 3 and l_c24lclpdrcod_atu = 1 then
      let l_descricao = "SRV INDEX PELA COORD DA RUA FICOU AGORA S/INDEX"
   end if

   if l_c24lclpdrcod_ant = 3 and l_c24lclpdrcod_atu = 2 then
      let l_descricao = "SRV INDEX PELA COORD DA RUA FOI AGORA INDEX PELO GUIA POSTAL"
   end if

   if l_c24lclpdrcod_ant = 3 and l_c24lclpdrcod_atu = 3 then
      let l_descricao = "SRV CONTINUA INDEX PELA COORD DA RUA"
   end if
   if l_c24lclpdrcod_ant = 3 and l_c24lclpdrcod_atu = 4 then
      let l_descricao = "SRV INDEX PELA COORD DA RUA FOI AGORA INDEX PELA COORD DO BRR"
   end if
   if l_c24lclpdrcod_ant = 3 and l_c24lclpdrcod_atu = 5 then
      let l_descricao = "SRV INDEX PELA COORD DA RUA FOI AGORA INDEX PELA COORD DO SUB-BRR"
   end if
   # Anterior Indexado pela coordenada do bairro
   if l_c24lclpdrcod_ant = 4 and l_c24lclpdrcod_atu = 1 then
      let l_descricao = "SRV INDEX PELA COORD DO BRR FICOU AGORA S/INDEX"
   end if

   if l_c24lclpdrcod_ant = 4 and l_c24lclpdrcod_atu = 2 then
      let l_descricao = "SRV INDEX PELA COORD DO BRR FOI AGORA INDEX PELO GUIA POSTAL"
   end if

   if l_c24lclpdrcod_ant = 4 and l_c24lclpdrcod_atu = 3 then
      let l_descricao = "SRV INDEX PELA COORD DO BRR FOI AGORA INDEX PELA COORD DA RUA"
   end if
   if l_c24lclpdrcod_ant = 4 and l_c24lclpdrcod_atu = 4 then
      let l_descricao = "SRV CONTINUA INDEX PELA COORD DO BRR"
   end if
   if l_c24lclpdrcod_ant = 4 and l_c24lclpdrcod_atu = 5 then
      let l_descricao = "SRV INDEX PELA COORD DO BRR FOI AGORA INDEX PELA COORD DO SUB-BRR"
   end if
   # Anterior Indexado pela coordenada do sub-bairro
   if l_c24lclpdrcod_ant = 5 and l_c24lclpdrcod_atu = 1 then
      let l_descricao = "SRV INDEX PELA COORD DO SUB-BRR FICOU AGORA S/INDEX"
   end if

   if l_c24lclpdrcod_ant = 5 and l_c24lclpdrcod_atu = 2 then
      let l_descricao = "SRV INDEX PELA COORD DO SUB-BRR FOI AGORA INDEX PELO GUIA POSTAL"
   end if

   if l_c24lclpdrcod_ant = 5 and l_c24lclpdrcod_atu = 3 then
      let l_descricao = "SRV INDEX PELA COORD DO SUB-BRR FOI AGORA INDEX PELA COORD DA RUA"
   end if
   if l_c24lclpdrcod_ant = 5 and l_c24lclpdrcod_atu = 4 then
      let l_descricao = "SRV INDEX PELA COORD DO SUB-BRR FOI AGORA INDEX PELA COORD DO BRR"
   end if
   if l_c24lclpdrcod_ant = 5 and l_c24lclpdrcod_atu = 5 then
      let l_descricao = "SRV CONTINUA INDEX PELA COORD DO SUB-BRR"
   end if

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora

   call cts10g02_historico(g_documento.atdsrvnum, g_documento.atdsrvano,
                           l_data, l_hora, g_issk.funmat, l_descricao,
                           "","","","")
        returning l_resultado

   if l_resultado <> 0 then
      error "Erro ", l_resultado, " na atualizado do historico (cts06g03)"
   end if

end function

function cts06g03_carrega_glo(l_param)

   define l_param    record
          c24endtip  like datmlcl.c24endtip,
          atdsrvorg  like datmservico.atdsrvorg,
          mpacidcod  like datracncid.cidcod,
          cidcod     like datracncid.cidcod
   end record

   define lr_retorno record
          res        smallint,
          msg        char(50),
          atdprvtmp  like datracncid.atdprvtmp
          end record

   define l_resultado    smallint,
          l_atmacnprtcod like datkatmacnprt.atmacnprtcod,
          l_netacnflg    like datkatmacnprt.netacnflg

   let l_resultado = null
   let l_atmacnprtcod = null
   let l_netacnflg = null

   initialize lr_retorno.* to null

   if l_param.c24endtip <> 1 then
       return
   end if

   if l_param.atdsrvorg = 13 then
      let l_param.atdsrvorg = 9
   end if

   let g_atmacnprtcod = null
   let g_cidcod = null

   call cts32g00_busca_codigo_acionamento(l_param.atdsrvorg)
        returning l_resultado,
                  l_atmacnprtcod,
                  l_netacnflg

   if l_param.mpacidcod is not null and l_param.mpacidcod <> 0 then
      let g_cidcod = l_param.mpacidcod
   else
      let g_cidcod = l_param.cidcod
   end if

   let g_atmacnprtcod = l_atmacnprtcod

end function

#-------------------------------------------#
 function cts06g03_inclui_temp_hstidx(param)
#-------------------------------------------#

 define param record
     srvhstseq smallint,
     endlgdtip char(10),
     endlgd    char(60),
     endlgdnum smallint,
     endbrrnom char(40),
     ciddes    char(45),
     ufdcod    char(2),
     lclltt    decimal(8,6),
     lcllgt    decimal(8,6)
 end record

 if  param.srvhstseq = 1 then
     delete from tmp_idx
 else
     delete from tmp_idx where srvhstseq <> 1
 end if

 insert into tmp_idx values(param.srvhstseq,
                            param.endlgdtip,
                            param.endlgd,
                            param.endlgdnum,
                            param.endbrrnom,
                            param.ciddes,
                            param.ufdcod,
                            param.lclltt,
                            param.lcllgt)

end function

#--------------------------------------#
 function cts06g03_inclui_hstidx(param)
#--------------------------------------#

 define param record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano
 end record

 define mr_idxdaf record
     srvhstseq smallint,
     endlgdtip char(10),
     endlgd    char(60),
     endlgdnum smallint,
     endbrrnom char(40),
     ciddes    char(45),
     ufdcod    char(2),
     lclltt    decimal(8,6),
     lcllgt    decimal(8,6)
 end record

     select 1
       from tmp_idx
      where srvhstseq = 1

    if  sqlca.sqlcode = 0 then

        declare c_cts06g03_007 cursor for
         select *
           from tmp_idx
          where endlgd is not null

       foreach c_cts06g03_007 into mr_idxdaf.srvhstseq,
                             mr_idxdaf.endlgdtip,
                             mr_idxdaf.endlgd,
                             mr_idxdaf.endlgdnum,
                             mr_idxdaf.endbrrnom,
                             mr_idxdaf.ciddes,
                             mr_idxdaf.ufdcod,
                             mr_idxdaf.lclltt,
                             mr_idxdaf.lcllgt



           if  mr_idxdaf.endlgdtip is null or mr_idxdaf.endlgdtip = " " then
               let mr_idxdaf.endlgdtip = 'NAO CONSTA'
           end if

           if  mr_idxdaf.endlgd is null or mr_idxdaf.endlgd = " " then
               let mr_idxdaf.endlgd = 'NAO CONSTA'
           end if

           if  mr_idxdaf.endlgdnum is null or mr_idxdaf.endlgdnum = " " then
               let mr_idxdaf.endlgdnum = '0'
           end if

           if  mr_idxdaf.endbrrnom is null or mr_idxdaf.endbrrnom = " " then
               let mr_idxdaf.endbrrnom = 'NAO CONSTA'
           end if

           if  mr_idxdaf.ciddes is null or mr_idxdaf.ciddes = " " then
               let mr_idxdaf.ciddes = 'NAO CONSTA'
           end if

           if  mr_idxdaf.ufdcod is null or mr_idxdaf.ufdcod = " " then
               let mr_idxdaf.ufdcod = 'NAO CONSTA'
           end if

           whenever error continue
           insert into dpcmdafidxsrvhst values (param.atdsrvnum,
                                                param.atdsrvano,
                                                mr_idxdaf.srvhstseq,
                                                mr_idxdaf.endlgdtip,
                                                mr_idxdaf.endlgd,
                                                mr_idxdaf.endlgdnum,
                                                mr_idxdaf.endbrrnom,
                                                mr_idxdaf.ciddes,
                                                mr_idxdaf.ufdcod,
                                                mr_idxdaf.lclltt,
                                                mr_idxdaf.lcllgt,
                                                current,
                                                g_issk.funmat)
           whenever error stop

       end foreach
    end if

    drop table tmp_idx

 end function

#---------------------------------------------#
 function cts06g03_busca_complemento_apolice()
#---------------------------------------------#


  define  l_resultado  smallint
         ,l_ret        smallint
         ,l_mensagem   char(60)
         ,l_segnumdig  like abbmdoc.segnumdig

  define lr_ret record
       endcmp like datmlcl.endcmp
  end record

  initialize lr_ret.* to null


  if m_prep is null or
     m_prep = false or
     m_prep = ""    then
     call cts06g03_prepare()
  end if


  if g_documento.ciaempcod = 1  or
     g_documento.ciaempcod = 50 then

     call cty05g00_segnumdig(g_documento.succod,
                             g_documento.aplnumdig,
                             g_documento.itmnumdig,
                             g_funapol.dctnumseq,
                             g_documento.prporg,
                             g_documento.prpnumdig )
          returning l_resultado, l_mensagem, l_segnumdig

     if l_resultado <> 1 then

        whenever error continue
        open c_cts06g03_005 using g_documento.succod,
                                g_documento.aplnumdig,
                                g_documento.ramcod
        fetch c_cts06g03_005 into l_segnumdig
        whenever error stop

        if sqlca.sqlcode = 100 then
           error l_mensagem
        end if
     end if
  end if

  whenever error continue
      open c_cts06g03_006 using l_segnumdig
      fetch c_cts06g03_006 into lr_ret.endcmp
  whenever error stop
  return lr_ret.endcmp

end function

#-----------------------------------------------------------
function cts06g03_idx_brr(lr_param)
#-----------------------------------------------------------

   define lr_param    record
          ufdcod       like datmlcl.ufdcod,
          cidnom       like datmlcl.cidnom,
          brrnom       like datmlcl.brrnom,
          lclbrrnom    like datmlcl.lclbrrnom,
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          c24lclpdrcod like datmlcl.c24lclpdrcod
   end record

   define lr_aux record
       mpacidcod   like datkmpacid.mpacidcod,
       retorno   smallint,  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
       mensagem  char(100),
       cidsedcod like datrcidsed.cidsedcod,
       brrtipflg like datrcidsed.brrtipflg,
       mpabrrcod like datkmpabrr.mpabrrcod,
       lclltt    like datkmpabrr.lclltt,
       lcllgt    like datkmpabrr.lcllgt
   end record

   define l_erro smallint # (0) = Ok   (1) = Not Found   (2) = Erro de acesso

   initialize lr_aux.* to null

   let l_erro = 1

   if m_prep is null or
      m_prep <> true then
      call cts06g03_prepare()
   end if

   #obter codigo da cidade
   open  c_datkmpacid  using lr_param.cidnom,
                             lr_param.ufdcod
   whenever error continue
   fetch c_datkmpacid  into lr_aux.mpacidcod
   whenever error stop
   if sqlca.sqlcode = 0 then
       #obter codigo da cidade sede
       call ctd01g00_obter_cidsedcod(3,lr_aux.mpacidcod)
          returning lr_aux.retorno,
                    lr_aux.mensagem,
                    lr_aux.cidsedcod,
                    lr_aux.brrtipflg
       if lr_aux.retorno = 1 then
           if lr_aux.brrtipflg = 'S' then
               open  c_datkmpabrrsub using lr_aux.mpacidcod, # Indexa o Bairro pela tabela de Sub-Bairro
                                           lr_param.brrnom
               whenever error continue
               fetch c_datkmpabrrsub into lr_aux.lclltt,
                                          lr_aux.lcllgt
               whenever error stop
               if (lr_param.brrnom is not null and lr_param.brrnom <> " ") and
                  sqlca.sqlcode = 0 then
                   let lr_param.lclltt = lr_aux.lclltt
                   let lr_param.lcllgt = lr_aux.lcllgt
                   let lr_param.c24lclpdrcod = 5
                   let l_erro = 0
               else
                   if sqlca.sqlcode = notfound then
                       close c_datkmpabrrsub
                       open  c_datkmpabrrsub using lr_aux.mpacidcod, # Indexa o Sub-Bairro pela tabela de Sub-Bairro
                                                   lr_param.lclbrrnom
                       whenever error continue
                       fetch c_datkmpabrrsub into lr_aux.lclltt,
                                                  lr_aux.lcllgt
                       whenever error stop
                       if (lr_param.lclbrrnom is not null and lr_param.lclbrrnom <> " ") and
                          sqlca.sqlcode = 0 then
                           let lr_param.lclltt = lr_aux.lclltt
                           let lr_param.lcllgt = lr_aux.lcllgt
                           let lr_param.c24lclpdrcod = 5
                           let l_erro = 0
                       else
                           if sqlca.sqlcode = notfound then
                               open  c_datkmpabrr using lr_param.brrnom, # Indexa o Bairro pela tabela de Bairro
                                                        lr_aux.mpacidcod
                               whenever error continue
                               fetch c_datkmpabrr into lr_aux.lclltt,
                                                       lr_aux.lcllgt
                               whenever error stop
                               if (lr_param.brrnom is not null and lr_param.brrnom <> " ") and
                                  sqlca.sqlcode = 0 then
                                   let lr_param.lclltt = lr_aux.lclltt
                                   let lr_param.lcllgt = lr_aux.lcllgt
                                   let lr_param.c24lclpdrcod = 4
                                   let l_erro = 0
                               else
                                   if sqlca.sqlcode = notfound then
                                       close c_datkmpabrr
                                       open  c_datkmpabrr using lr_param.lclbrrnom, # Indexa o Sub-Bairro pela tabela de Bairro
                                                                lr_aux.mpacidcod
                                       whenever error continue
                                       fetch c_datkmpabrr into lr_aux.lclltt,
                                                               lr_aux.lcllgt
                                       whenever error stop
                                       if sqlca.sqlcode = 0 then
                                           let lr_param.lclltt = lr_aux.lclltt
                                           let lr_param.lcllgt = lr_aux.lcllgt
                                           let lr_param.c24lclpdrcod = 4
                                           let l_erro = 0
                                       else
                                           if sqlca.sqlcode <> notfound then
                                               error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: c_datkmpabrr (2)"
                                           end if
                                       end if
                                   else
                                       error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: c_datkmpabrr (1)"
                                   end if
                               end if
                               close c_datkmpabrr
                           end if
                       end if
                   else
                       error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: c_datkmpabrrsub (1)"
                   end if
               end if
               close c_datkmpabrrsub
           end if
       end if
   else
       if sqlca.sqlcode <> notfound then
           error "Erro de acesso ao banco de dados: ", sqlca.sqlcode, " /Cursor: c_datkmpacid"
       end if
   end if
   close c_datkmpacid

   return l_erro
         ,lr_param.lclltt
         ,lr_param.lcllgt
         ,lr_param.c24lclpdrcod

end function ### cts06g03_idx_brr

# -----------------------------------------------------------------------------
 function cts06g03_sentido(l_param)
# -----------------------------------------------------------------------------
# funcao criada para abrir nova janela de local de ocorrencia
#    onde sao informados sentido/pista/km/referencia, dependendo situacao

   define l_param record
      lgdnom            char(100)
     ,lgdtip            char(100)
   end record

   define l_tpsentido        char(100)
         ,l_tpmarginal       char(100)
         ,l_tppista          char(100)
         ,l_tplougr          char(100)
         ,l_cabec            char(30)
         ,l_pontoreferencia  char(350)

  define lr_compl record
      titulo           char(20)
     ,sentido          char(35)
     ,pista            char(35)
     ,campo_km         char(03)
     ,km               char(5)
     ,referencias      char(200)
     ,exemplo          char(200)
   end record

   initialize lr_compl.* to null

   let l_tpsentido  = null
   let l_tppista    = null
   let l_cabec      = null

   if upshift(l_param.lgdtip) = 'RODOVIA' then
      let lr_compl.campo_km = 'KM:'
      let lr_compl.exemplo = "(Origem-Destino)"
   end if

   let l_pontoreferencia = null

   open window w_sentido at 13,10 with form 'cts06g11b'
      attribute (border,form line first)

      input by name lr_compl.* without defaults

         before field titulo
            display '        Dados Complementares ' to titulo attribute (reverse)

         before field sentido
             display by name lr_compl.sentido

             if lr_compl.sentido is null                  and
                upshift(l_param.lgdnom) = 'MARGINAL TIETE' then

                call cta00m06_tipo_sentido2()
                     returning l_tpsentido

                if l_tpsentido is not null then
                   let l_cabec = "SENTIDO"

                   call ctx14g01a(l_cabec, l_tpsentido)
                      returning lr_compl.sentido
                end if
             end if

             if lr_compl.sentido is null                      and
                upshift(l_param.lgdnom) = 'MARGINAL PINHEIROS' then

                call cta00m06_tipo_sentido2()
                     returning l_tpsentido

                if l_tpsentido is not null then
                   let l_cabec = " SENTIDO "

                   call ctx14g01a(l_cabec, l_tpsentido)
                      returning lr_compl.sentido
                end if
             end if

         after field sentido
            if lr_compl.sentido is null or
               lr_compl.sentido = ' ' then
               error ' E PRECISO INFORMAR UM SENTIDO !'
               next field sentido
            end if

         before field pista
            display by name lr_compl.pista

            if lr_compl.pista is null then
               if upshift(l_param.lgdtip) = 'MARGINAL' then
                 call cta00m06_tipo_pista_marginal()
                 returning l_tppista
               else
                 if upshift(l_param.lgdtip) = 'RODOVIA' then
                   call cta00m06_tipo_pista_rodovia()
                   returning l_tppista
                 end if
               end if

               if l_tppista is not null then
                  let l_cabec = "Tipo Pista"

                  call ctx14g01a(l_cabec, l_tppista)
                     returning lr_compl.pista
                  display lr_compl.pista to pista
               end if
            end if

         after field pista
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field sentido
            end if

            if (lr_compl.pista is null or
               lr_compl.pista = " "    ) and
               (upshift(l_param.lgdtip) = 'MARGINAL' or
               upshift(l_param.lgdtip) = 'RODOVIA'  )then
                error ' E preciso informar a Pista !'
                next field pista
            end if

            if upshift(l_param.lgdtip) = 'RODOVIA' then
               display  lr_compl.campo_km to campo_km
               next field km
            else
                next field referencias
            end if

         before field km
            display by name lr_compl.km

         after field km
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field pista
            end if

            #let lr_compl.km = lr_compl.km clipped

            if lr_compl.km is null or
               lr_compl.km = " "   then
               error " E preciso informar KM ! "
            end if

         before field referencias
            display by name lr_compl.referencias
            error ' Informe ponto de referencia !'

         after field referencias
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               if upshift(l_param.lgdtip) = 'RODOVIA' then
                  next field km
               else
                  next field pista
               end if
            end if

            if lr_compl.referencias is null then
               next field referencias
            end if

            let l_pontoreferencia = 'Sentido: ' ,lr_compl.sentido clipped ,' / '
                                  , 'Pista: ' ,lr_compl.pista clipped ,' / '

            if lr_compl.km is not null or
               lr_compl.km <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped , 'KM: ' ,lr_compl.km clipped ,' / '
            end if

            # Retirar termo Referencias - PSI xxxxx
            if lr_compl.referencias is not null or
               lr_compl.referencias <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped, ' ' ,lr_compl.referencias clipped, ' / '
            end if

       on key (interrupt,control-c)

           let l_pontoreferencia = 'Sentido: ' ,lr_compl.sentido clipped ,' / '
                                  , 'Pista: ' ,lr_compl.pista clipped ,' / '

            if lr_compl.km is not null or
               lr_compl.km <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped , 'KM: ' ,lr_compl.km clipped ,' / '
            end if

            # Retirar termo Referencias - PSI xxxxx
            if lr_compl.referencias is not null or
               lr_compl.referencias <> " " then
               let l_pontoreferencia = l_pontoreferencia clipped, ' ' ,lr_compl.referencias clipped, ' / '
            end if

            exit input

      end input

   close window w_sentido

   return l_pontoreferencia clipped
end function


