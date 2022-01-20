##############################################################################
# Nome do Modulo: BDBSA017                                         Marcelo   #
#                                                                  Gilberto  #
# Atualizacao/interface de ordens de pagamento - Porto Socorro     Abr/1997  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 02/02/1999  ** ERRO **   Gilberto     Quando documento nao for Nota Fiscal #
#                                       passar ZERO ao inves de nulo.        #
#----------------------------------------------------------------------------#
# 18/03/1999  PSI 7885-9   Gilberto     Inclusao do valor do INSS na inter-  #
#                                       face com Contas a Pagar e Tributos.  #
#----------------------------------------------------------------------------#
# 07/06/1999  ** ERRO **   Gilberto     So' chamar funcao de verificacao de  #
#                                       sinistro (osauc040) quando tipo do   #
#                                       servico for (1)Sinistro, (7)RPT ou   #
#                                       (8)Replace.                          #
#----------------------------------------------------------------------------#
# 15/06/1999  PSI 8631-2   Gilberto     Alteracao do retorno da funcao de    #
#                                      tributacao quando for simulacao.      #
#----------------------------------------------------------------------------#
# 28/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-   #
#                                       coes, com a utilizacao de funcoes.   #
#----------------------------------------------------------------------------#
# 01/03/2000  PSI 9958-9   Wagner       Incluir mais 2 campos no retorno da  #
#                                       funcao CALCTRIBN: trbrenvlr,irfretvlr#
#----------------------------------------------------------------------------#
# 14/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo        #
#                                       atdsrvnum de 6 p/ 10.                #
#                                       Troca do campo atdtip p/ atdsrvorg.  #
#----------------------------------------------------------------------------#
# 11/12/2000  CORREIO      Wagner       Correio Suely Kian alteracao na      #
#                                       funcao g_bfpga017 (inclusao campos)  #
#----------------------------------------------------------------------------#
# 14/02/2001  PSI 10631-3  Wagner       Alteracao p/desviar da interface qdo.#
#                                       se tratar de registro carro_extra.   #
#                                       OBS: VERIFICAR COMENTARIOS --> #WWW  #
#----------------------------------------------------------------------------#
# 03/04/2001  AS  23850    Wagner       Inclusao interface carro-extra com   #
#                                       ctas a pagar e contabilidade.        #
#----------------------------------------------------------------------------#
# 02/05/2001  PSI  13094-0 Ruiz         Inclusao de novo convenios           #
#                                       19-caixa seguros 86-porto uruguai    #
#----------------------------------------------------------------------------#
# 10/05/2001  correio      Ruiz         Inclusao do convenio 88 panamericano.#
#----------------------------------------------------------------------------#
# 07/08/2001  PSI 13448-1  Wagner       Inclusao pagto.mesmo servico mais de #
#                                       uma vez.                             #
#----------------------------------------------------------------------------#
# 13/12/2001  PSI 14295-6  Wagner       Inclusao interface RE com Ctas pagar #
#                                       Contabilidade e Tributos.            #
#----------------------------------------------------------------------------#
# 25/07/2002  CORREIO      Wagner       Conforme correio Denise Santana,     #
#                                       direcionar servicos cls 34A e 35A    #
#                                       para cod.desp.contabil 22.           #
#----------------------------------------------------------------------------#
# 18/12/2002  PSI 163929   Wagner       Incluir tipo de pessoa na tabela     #
#                                       ctimsocor, ctimextcrrprv.            #
#------------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                           #
#............................................................................  #
#                  * * *  ALTERACOES  * * *                                    #
#                                                                              #
# Data     Fabrica Autor   PSI/OSF Alteracao                                   #
# -------- --------------- ------- --------------------------------------------#
# 23/01/04 Meta, Jefferson 182133  Atualizacao/interface de ordens de          #
#                          30449   pagamento                                   #
#----------------------------------------------------------------------------  #
# 07/05/2004 OSF 35050     JUNIOR(FSW)  Projeto D+1 (MDS)                      #
# ---------------------------------------------------------------------------  #
#                                                                              #
#                           * * * Alteracoes * * *                             #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 06/07/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch     #
#                              OSF036870  do Porto Socorro.                    #
#............................................................................  #
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ ------------------------------------ #
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco.  #
#----------------------------------------------------------------------------- #
# 16/03/2006 Priscila           PSI191329 inclusao do campo cctdptcod          #
#----------------------------------------------------------------------------- #
# 16/10/2006 Priscila           PSI202720 implantacao saude + casa             #
#----------------------------------------------------------------------------- #
# 04/06/2007 Cristiane Silva    PSI207373 Atendimento clausulas 33,34,94       #
#----------------------------------------------------------------------------- #
# 20/03/2008 Sergio Burini      PSI221074 Fases da OP - Registro Responsavel   #
#----------------------------------------------------------------------------- #
# 30/06/2008 Ligia Mattge       PSI198404 Reestruturacao do programa interface #
#                               People - Contas a Pagar                        #
#----------------------------------------------------------------------------- #
# 14/04/2009 Fabio Costa        PSI198404 Merge People com a versao anterior,  #
#                                         implantacao People                   #
# 10/11/2009 Fabio Costa        PSI198404 Adequacao reembolso Azul             #
# 19/04/2010 Fabio Costa        PSI198404 Revisao initialize, retirar processos#
#                                         nao utilizados empresa 35            #
# 02/06/2010 Fabio Costa        PSI198404 Incluir codigo de despesa 904 servico#
#                                         PSS Leva e Traz                      #
# 30/06/2010 Fabio Costa        100621803 Buscar ramo da apolice ISAR (FAEMC070)
#                                         somente para apolice emitida         #
# 04/10/2010 Beatriz Araujo PSI-2010-00003 Verificar o ramo de contabilizacao  #
#                                          das clausulas - Circular 395        #
# 25/05/2012 Jose Kurihara  PSI-11-19199PR Incluir flag Optante Simples e      #
#                                          aliquota ISS informada na OP        #
################################################################################
# 12/03/2013 Gregorio, Biz PSI-2012-23608 Substituir o endereco do prestador.  #
#------------------------------------------------------------------------------#
# 02/07/2013 Celso Yamahaki 13071551      Substituir a matricula do Orlando    #
#------------------------------------------------------------------------------#
# 01/08/2013 Beatriz Araujo 13071551      Substituir a matricula do emissor    #
#                                         para parametro                       #
# 12/11/2014 Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada  #
#                                          Camada Contabil" e para o PGP       # 
#                                          P14070117                           #
# 02/05/2016 Ligia Mattge    SPR-2016-02269 Projeto Controle de Descontos
#------------------------------------------------------------------------------#
database porto

globals '/homedsa/projetos/geral/globals/ffpgc309.4gl'
globals '/homedsa/projetos/geral/globals/I4GLParams.4gl' 
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl" #Fornax-Quantum 
globals "/homedsa/projetos/geral/globals/ffpgc369.4gl"  #Fornax-Quantum 

define m_path     char(100)
     , m_path2    char(100)
     , m_path3    char(100)
     , m_path4    char(100)
     , m_dir1     char(030) 
     , m_err_rel  char(080)
     , m_traco    char(080)
     , dthr       datetime year to minute
     , sdthr      char(20)
     , m_assunto  char(300)
     , m_ret      smallint
     , m_dsp      char(200)
     , m_flagcctcod char(1)

define m_time datetime year to second

define m_bdbsa017       record
       socopgnum        like dbsmopg.socopgnum      ,
       socopgitmnum     like dbsmopgitm.socopgitmnum,
       socfatpgtdat     like dbsmopg.socfatpgtdat   ,
       socfattotvlr     like dbsmopg.socfattotvlr   ,
       socfatliqvlr     like dbsmopg.socfattotvlr   ,
       socopgdscvlr     like dbsmopg.socopgdscvlr   ,
       funmat           like dbsmopgfas.funmat      ,
       atdsrvnum        like dbsmopgitm.atdsrvnum   ,
       atdsrvano        like dbsmopgitm.atdsrvano   ,
       socopgitmvlr     like dbsmopgitm.socopgitmvlr,
       empcod           like dbsmopg.empcod         , # empresa da OP
       succod           like dbsmopg.succod         ,
       cctcod           like dbsmopg.cctcod         ,
       cctdptcod        integer                     ,
       cctlclcod        integer                     ,
       pgtdstcod        like dbsmopg.pgtdstcod      ,
       pstcoddig        like dbsmopg.pstcoddig      ,
       segnumdig        like dbsmopg.segnumdig      ,
       corsus           like dbsmopg.corsus         ,
       pestip           like dbsmopgfav.pestip      ,
       cgccpfnum        like dbsmopgfav.cgccpfnum   ,
       cgcord           like dbsmopgfav.cgcord      ,
       cgccpfdig        like dbsmopgfav.cgccpfdig   ,
       socopgfavnom     like dbsmopgfav.socopgfavnom,
       bcocod           like dbsmopgfav.bcocod      ,
       bcoagndig        like dbsmopgfav.bcoagndig   ,
       bcoagnnum        like dbsmopgfav.bcoagnnum   ,
       bcoctanum        like dbsmopgfav.bcoctanum   ,
       bcoctadig        like dbsmopgfav.bcoctadig   ,
       socpgtdoctip     like dbsmopg.socpgtdoctip   ,
       socpgtopccod     like dbsmopgfav.socpgtopccod,
       socemsnfsdat     like dbsmopg.socemsnfsdat   ,
       nfsnum           like dbsmopgitm.nfsnum      ,
       opgnfsnum        like dbsmopgitm.nfsnum      ,
       socopgfasdat     like dbsmopgfas.socopgfasdat,
       socopgfashor     like dbsmopgfas.socopgfashor,
       socopgitmcst     like dbsmopgcst.socopgitmcst,
       socitmdspcod     like dbsmopgitm.socitmdspcod,
       soctip           like dbsmopg.soctip         ,
       socpgtdsctip     like dbsmopg.socpgtdsctip   ,
       lcvcod           like dbsmopg.lcvcod         ,
       aviestcod        like dbsmopg.aviestcod      ,
       c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
       c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd,
       rsrincdat        like dbsmopgitm.rsrincdat   ,
       rsrfnldat        like dbsmopgitm.rsrfnldat   ,
       nomrazsoc        like dpaksocor.nomrazsoc    ,
       nomgrr           like dpaksocor.nomgrr       ,
       ufdsgl           like dpakpstend.ufdsgl      ,#PSI-2012-23608, Biz
       endcid           like dpakpstend.endcid      ,#PSI-2012-23608, Biz
       endlgd           like dpakpstend.endlgd      ,#PSI-2012-23608, Biz
       endcep           like dpakpstend.endcep      ,#PSI-2012-23608, Biz
       endcepcmp        like dpakpstend.endcepcmp   ,#PSI-2012-23608, Biz
       endbrr           like dpakpstend.endbrr      ,#PSI-2012-23608, Biz
       maides           like dpaksocor.maides       ,
       lgdtip           like dpakpstend.lgdtip      ,#PSI-2012-23608, Biz
       lgdnum           like dpakpstend.lgdnum      ,#PSI-2012-23608, Biz
       lgdcmp           like dpakpstend.lgdcmp      ,#PSI-2012-23608, Biz
       mpacidcod        like dpaksocor.mpacidcod    ,
       dddcod           like dpaksocor.dddcod       ,
       teltxt           like dpaksocor.teltxt       ,
       prscootipcod     like dpaksocor.prscootipcod ,
       vlr_rateio       like dbsmcctrat.cctratvlr   ,
       muninsnum        like dpaksocor.muninsnum    ,
       pisnum           like dpaksocor.pisnum       ,
       nitnum           like dpaksocor.nitnum       ,
       modal_pgto       char(2)                     ,
       oper_interna     decimal(2,0)                , # flag divide as OPs em lote
       tipdoc           char(09)                    , # tipo documento fiscal
       datacontabil     date                        ,
       cod_fornec       char(15)                    , # codigo forn. unificado
       coddesp          integer                     ,
       pstsuccod        like dbsmopg.succod         , # Sucursal do Prestador
       favtip           smallint                    , # tipo do favorecido (conforme online)
       pcpatvcod        like dpaksocor.pcpatvcod    ,
       prvssrvflg       smallint                    , # flag ajusta provisionamento de servico
       infissalqvlr     like dbsmopg.infissalqvlr   ,
       simoptpstflg     like dpaksocor.simoptpstflg , # PSI-11-19199 Simples 
       endtipcod        like dpakpstend.endtipcod   , #PSI-2012-23608, Biz 
       fisnotsrenum     like dbsmopg.fisnotsrenum   , # Serie da nota fiscal
       codretecao       char(16)   
end record

define m_cty10g00_out record
       res     smallint,
       msg     char(40),
       endufd  like gabksuc.endufd,
       endcid  like gabksuc.endcid,
       cidcod  like gabksuc.cidcod
end record

define m_ffpgc340_out record
       ctbctanum    like fpgmdspcct.ctbctanum,
       empflg       like fpgmdspcct.empflg   ,
       sucflg       like fpgmdspcct.sucflg   ,
       ramflg       like fpgmdspcct.ramflg   ,
       mdlflg       like fpgmdspcct.mdlflg   ,
       lclflg       like fpgmdspcct.lclflg   ,
       dptflg       like fpgmdspcct.dptflg   ,
       errcod       smallint                 ,
       errdes       char(100)
end record

define m_inftrb record
       errcod        smallint     ,
       errdes        char(80)     ,
       tpfornec      char(3)      ,
       cbo           char(7)      ,
       retencod      like fpgkplprtcinf.ppsretcod ,
       socitmtrbflg  char(1)      ,
       retendes      char(50)
end record

define m_empptcqtd   smallint
define ma_empptc     array[50] of record
       empcod        like dbsmopg.empcod,
       optflg        char(01)
end record

#Fornax-Quantum  - Inicio 
define m_retsap record 
       stt         smallint
      ,msg         char(100)
end record  

define m_arr_sap       integer                       


define mr_chave         like datkgeral.grlchv   

define m_tempo_chamada  datetime year to fraction
define m_tempo_retorno  datetime year to fraction  

#Fornax-Quantum  - Fim 



#---------------------------------------------------------------
main
#---------------------------------------------------------------

   initialize m_ffpgc340_out.* to null
   initialize m_inftrb.* to null
   initialize m_cty10g00_out.* to null
   initialize m_bdbsa017.* to null
   initialize ma_empptc to null

   initialize m_path   , m_path2  , m_path3  , m_path4  ,
              m_dir1   , m_err_rel, m_traco  , dthr     ,
              sdthr    , m_assunto, m_ret    , m_dsp    ,
              m_time to null

   let m_empptcqtd = 0

   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   let m_path2 = f_path("DBS","LOG")
   if m_path2 is null then
      let m_path2 = "."
   end if

   let m_path2 = m_path2 clipped, "/bdbsa017.log"
   call startlog(m_path2)

   let m_dir1 = f_path("DBS", "RELATO")
   if m_dir1 is null then
       let m_dir1 = "."
   end if

   let m_path  = m_dir1 clipped, "/BDBSA017.xls"
   let m_path3 = m_dir1 clipped, "/bdbsa017res.txt"
   let m_path4 = m_dir1 clipped, "/bdbsa017envio.csv"

   call bdbsa017()
   
   # enviar e-mail do resumo da emissao do dia
   let m_assunto = 'Resumo da emissao de O.P. Porto Socorro - '
                  , today using "dd/mm/yyyy"

   let m_ret = ctx22g00_envia_email("BDBSA017", m_assunto, m_path3)

   if m_ret != 0 then
      if m_ret != 99 then
         display "Erro ao enviar email(ctx22g00) - ", m_path3
      else
         display "Nao ha email cadastrado para o modulo "
      end if
   end if
   
   # enviar e-mail do resumo da emissao do dia
   let m_assunto = 'Erro Contabilizacao da emissao de O.P. Porto Socorro - '
                  , today using "dd/mm/yyyy"

   let m_ret = ctx22g00_envia_email("BDBSA017", m_assunto, m_path)

   if m_ret != 0 then
      if m_ret != 99 then
         display "Erro ao enviar email(ctx22g00) - ", m_path
      else
         display "Nao ha email cadastrado para o modulo "
      end if
   end if

end main

#---------------------------------------------------------------
function bdbsa017()
#---------------------------------------------------------------

  define ws               record
         opgtrbflg        smallint,
         trbretcod        char (01),
         brutotvlr        like cglmdocton.trbrenvlr   ,
         irftotvlr        like cglmdocton.irfretvlr   ,
         isstotvlr        like cglmdocton.issretvlr   ,
         instotvlr        like cglmdocton.insretvlr   ,
         trbdctnum        like cglmdocton.trbdctnum   ,
         trbrenvlr        like cglmdocton.trbrenvlr   ,
         irfretvlr        like cglmdocton.irfretvlr   ,
         atdsrvorg        like datmservico.atdsrvorg  ,
         asitipcod        like datmservico.asitipcod  ,
         atddat           like datmservico.atddat     ,
         sindat           like datmservicocmp.sindat  ,
         lignum           like datmligacao.lignum     ,
         ligcvntip        like datmligacao.ligcvntip  ,
         c24astcod        like datmligacao.c24astcod  ,
         dptsgl           like isskfunc.dptsgl        ,
         pgtcmpopccod     like fpgmpgtcmp.pgtcmpopccod,
         pgtfrnorgcod     like fpgkfrnorg.pgtfrnorgcod,
         pgtfrntipcod     like fpgkfrnorg.pgtfrntipcod,
         nfschr           char (09),
         errcod           integer,
         errflg           smallint,
         errmsg           char (150),
         errdsc           char (50),
         privez           char (01),
         avialgmtv        like datmavisrent.avialgmtv,
         avioccdat        like datmavisrent.avioccdat,
         opgmvttip        like ctimextcrrprv.opgmvttip,
         slcsuccod        like datmavisrent.slcsuccod,
         slccctcod        like datmavisrent.slccctcod,
         aviprvent        like datmavisrent.aviprvent,
         aviprodiaqtd     like datmprorrog.aviprodiaqtd,
         aviprodiaqtd_tot like datmprorrog.aviprodiaqtd,
         socopgitmvlr_pro like dbsmopgitm.socopgitmvlr,
         saldo            integer,
         ctt              integer,
         sqlcode          integer,
         edsnumref        like datrservapol.edsnumref,
         ciaempcod        like datmservico.ciaempcod,
         socopgsitcod     like dbsmopg.socopgsitcod
  end record

  define d_bfpga017   record
         pgtcmpnum    like fpgmpgtcmp.pgtcmpnum
  end record

  define a_bfpga_pgt  array[05] of record
         pgtautnum    like fpgmpgtaut.pgtautnum
  end record

  define a_bfpga_adc  array[10] of record
         paradccod    like fpgmparadc.pgtvlrtipcod,
         paradcvlr    like fpgmparadc.paradcvlr,
         paradtnum    like fpgmadnbax.pgtadncmpnum
  end record

  define a_bfpga_err  array[10] of record
         errcod       smallint
  end record

  define l_arr        smallint  ,
         l_lin        smallint  ,
         l_sql        char(1000),
         l_grlinf     char(10)  ,
         l_tpdocto    char(15)  ,
         l_retorno    smallint  ,
         l_mensagem   char(80)  ,
         l_ramgrpcod  like gtakram.ramgrpcod,
         l_cpocod     like iddkdominio.cpocod

  define arr_aux      smallint

  define l_cornom      like datksegsau.cornom

  define lr_par  record
         evento           char(06),
         empresa          char(50),
         dt_movto         date    ,
         chave_primaria   char(50),
         op               char(50),
         apolice          char(50),
         sucursal         char(50),
         projeto          char(50),
         dt_chamado       date    ,
         fvrcod           char(50),
         fvrnom           char(50),
         nfnum            char(50),
         corsus           char(50),
         cctnum           char(50),
         modalidade       char(50),
         ramo             char(50),
         opgvlr           char(50),
         dt_vencto        date    ,
         dt_ocorrencia    date
  end record

  define lr_par2  record
         evento           char(06),
         empresa          char(50),
         dt_movto         date    ,
         chave_primaria   char(50),
         op               char(50),
         apolice          char(50),
         sucursal         char(50),
         projeto          char(50),
         dt_chamado       date    ,
         fvrcod           char(50),
         fvrnom           char(50),
         nfnum            char(50),
         corsus           char(50),
         cctnum           char(50),
         modalidade       char(50),
         ramo             char(50),
         opgvlr           char(50),
         dt_vencto        date    ,
         dt_ocorrencia    date
  end record

  define lr_mail record
         rem char(50) ,   # remetente
         des char(250),   # para
         ccp char(250),   # cc
         cco char(250),   # cco
         ass char(150),   # assunto
         msg char(32000), # mensagem
         idr char(20) ,   # id_remetente
         tip char(4)      # tipo
  end record

  define l_resumo record
         totopg    integer ,
         totopgems integer ,
         totopgerr integer ,
         totopgazl integer ,
         totopgitl integer ,
         totopgpss integer ,
         totopgsau integer
  end record

  define l_apolice record
         succod      like datrservapol.succod    ,
         ramcod      like datrservapol.ramcod    ,
         modalidade  like rsamseguro.rmemdlcod   ,
         aplnumdig   like datrservapol.aplnumdig ,
         itmnumdig   like datrservapol.itmnumdig ,
         corsus      like abamcor.corsus         ,
         emsdat      char(10)                    ,
         edsnumref   like datrservapol.edsnumref ,
         prporg      like datrligprp.prporg      ,
         prpnumdig   like datrligprp.prpnumdig   
         
  end record

  define l_sin record
         ramcod  like ssamsin.ramcod ,
         sinnum  like ssamsin.sinnum ,
         sinano  like ssamsin.sinano
  end record

  define l_rateio record
         empcod     like datrservapol.succod ,
         succod     like datrservapol.succod ,
         cctcod     like dbsmopg.cctcod      ,
         cctratvlr  like dbsmcctrat.cctratvlr
  end record

  define l_res      integer  ,
         l_msg      char(70) ,
         l_sqlcode  integer  ,
         l_sqlerrd  integer

  define l_cod_erro integer ,
         l_msg_erro char(20)

  #PSI-2012-23608, Biz
  define l_mail     integer

  define lr_aviso   record
         assunto    char(150)
        ,texto      char(32000)
  end record

 define lr_erro record         
        err          smallint,          
        msgerr       char(2000),
        srvvlr       like dbsmopgitm.socopgitmvlr,
        vlrapgt      like dbsmopgitm.socopgitmvlr,
        vlraprv      like dbsmopgitm.socopgitmvlr,
        srvajsevncod like dbskctbevnpam.srvajsevncod,
        srvpgtevncod like dbskctbevnpam.srvpgtevncod,
        srvpovevncod like dbskctbevnpam.srvpovevncod,
        srvatdctecod like dbskctbevnpam.srvatdctecod
 end record

  # Inicializacao das variaveis - 4GC
  define w_pf1 integer


#----- Contabilizacao
define l_ramcontabil record
    ctbramcod    like rsatdifctbramcvs.ctbramcod,
    ctbmdlcod    like rsatdifctbramcvs.ctbmdlcod,
    clscod       like rsatdifctbramcvs.clscod   ,# codigo da clausula
    pgoclsflg    like dbskctbevnpam.pgoclsflg 
end record

   define lr_saida_801 record      #PSI-2012-23608, Biz
  	  coderr       smallint
  	 ,msgerr       char(050)
  	 ,ppssucnum    like cglktrbetb.ppssucnum
  	 ,etbnom       like cglktrbetb.etbnom
  	 ,etbcpjnum    like cglktrbetb.etbcpjnum
  	 ,etblgddes    like cglktrbetb.etblgddes
  	 ,etblgdnum    like cglktrbetb.etblgdnum
  	 ,etbcpldes    like cglktrbetb.etbcpldes
  	 ,etbbrrnom    like cglktrbetb.etbbrrnom
  	 ,etbcepnum    like cglktrbetb.etbcepnum
  	 ,etbcidnom    like cglktrbetb.etbcidnom
  	 ,etbufdsgl    like cglktrbetb.etbufdsgl
  	 ,etbiesnum    like cglktrbetb.etbiesnum
  	 ,etbmuninsnum like cglktrbetb.etbmuninsnum
   end record  
                                                           
#Fornax-Quantum                                            
define lr_ret record                                       
        stt    integer                                     
       ,msg    char(100)                                   
end record                                                 
#Fornax-Quantum  

define l_rateioflag char(01)                                          

  let l_mail = 0  #PSI-2012-23608, Biz
  let l_arr        = null
  let l_lin        = null
  let l_sql        = null
  let l_grlinf     = null
  let l_tpdocto    = null
  let l_retorno    = null
  let l_mensagem   = null
  let l_ramgrpcod  = null
  let arr_aux      = null
  let l_cornom     = null
  let l_res        = null
  let l_msg        = null
  let l_sqlcode    = null
  let l_sqlerrd    = null
  let l_cod_erro   = null
  let l_msg_erro   = null
  let m_time       = null
  let w_pf1        = null
  let m_flagcctcod = 'N'

  for w_pf1  =  1  to  5
     initialize  a_bfpga_pgt[w_pf1].*  to  null
  end for

  for w_pf1  =  1  to  10
     initialize  a_bfpga_adc[w_pf1].*  to  null
  end for

  for w_pf1  =  1  to  10
     initialize  a_bfpga_err[w_pf1].*  to  null
  end for

  initialize ws.*          to null
  initialize d_bfpga017.*  to null
  initialize lr_par.*      to null
  initialize lr_par2.*     to null
  initialize lr_mail.*     to null
  initialize l_resumo.*    to null
  initialize l_apolice.*   to null
  initialize l_sin.*       to null
  initialize l_rateio.*    to null
  initialize m_bdbsa017.*  to null
  initialize l_resumo.*    to null
  initialize l_ramcontabil.* to null
  initialize lr_saida_801.* to null    #PSI-2012-23608, Biz

  let l_res = null
  let l_msg = null
  let m_err_rel = null
  let ws.privez = "S"

  start report bdbsa017_resumo to m_path3

  let m_traco = '--------------------------------------------------------------------------------'
  display m_traco
  output to report bdbsa017_resumo(m_traco)
  let m_err_rel = 'Resumo da emissao de O.P. Porto Socorro - Interface People'
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)
  let m_err_rel = 'Data/hora Inicio do processo: ', current
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)
  display m_traco
  output to report bdbsa017_resumo(m_traco)
  let m_err_rel = 'Erros na emissao:'
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  call cts40g03_data_hora_banco(2)
       returning m_bdbsa017.socopgfasdat, m_bdbsa017.socopgfashor

  if not g_isMqConn then

     call MQ4GL_Init() returning l_cod_erro, l_msg_erro

     if l_cod_erro <> 0 then
         let m_err_rel = "Erro no MQ4GL_Init: ", l_cod_erro, "Mensagem: ",
                         l_msg_erro clipped
         display m_err_rel
         output to report bdbsa017_resumo(m_err_rel)
         exit program(1)
     end if

  end if

  let g_isMqConn = true

  # Cria tabela temporaria para ratear os valores por sucursal, ramo e
  # modalidade para o people
  create temp table tmp_pagtos(sucursal dec(2), ramo smallint,
                               modalidade dec(5), valor dec(15,5)) with no log

  if sqlca.sqlcode != 0
     then
     let m_err_rel = "Erro na criacao da temporaria de acumulacao do rateio"
     display m_err_rel
     output to report bdbsa017_resumo(m_err_rel)
     exit program(1)
  end if

  # Acesso a tabela datkgeral para obter o campo GRLINF[1,10]
  # Retirado People PSI 198404
  # call cts40g23_busca_chv('ct24resolucao86') returning l_grlinf

  # prepares
  let l_sql = " select atdsrvnum   , atdsrvano   , ",
              "        socopgitmnum, socopgitmvlr, ",
              "        nfsnum      , c24utidiaqtd, ",
              "        c24pagdiaqtd, rsrincdat   , ",
              "        rsrfnldat                   ",
              " from dbsmopgitm ",
              " where socopgnum = ? ",
              " order by socopgitmnum "
  prepare p_opgitm_sel from l_sql
  declare c_opgitm_sel cursor with hold for p_opgitm_sel

  let l_sql = " select aviprodiaqtd, cctsuccod, cctcod ",
              "   from datmprorrog ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? ",
              "    and cctcod is not null ",
              "    and aviprostt = 'A' "
  prepare p_prorog_sel from l_sql
  declare c_prorog_sel cursor with hold for p_prorog_sel

  # Seleciona os registros de rateio
  let l_sql = " select empcod, succod, cctcod, cctratvlr ",
              "   from dbsmcctrat ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? "
  prepare p_cctrat_sel from l_sql
  declare c_cctrat_sel cursor with hold for p_cctrat_sel

  let l_sql = " select ufdsgl       "
             ,"       ,endcid       "
             ,"       ,endlgd       "
             ,"       ,endcep       "
             ,"       ,endcepcmp    "
             ,"       ,endbrr       "
             ,"       ,lgdtip       "
             ,"       ,lgdnum       "
             ,"       ,lgdcmp       "
             ,"  from dpakpstend    "
             ," where pstcoddig = ? "
             ,"   and endtipcod = ? "
  prepare p_ccende_sel from l_sql
  declare c_ccende_sel cursor with hold for p_ccende_sel

  let l_sql = " select cpocod                "
             ,"   from iddkdominio           "
             ,"  where cponom = 'endtipcod'  "
             ,"    and cpodes like '%FISCAL%'"
  prepare p_domend_sel from l_sql
  declare c_domend_sel cursor with hold for p_domend_sel
  
   #Matricula Responsavel pela Requisitante - Fornax-Quantum   
   let l_sql =  "select grlinf     "                           
               ,"  from datkgeral  "                           
               ," where grlchv = ? "                           
   prepare p_matresp_sel from l_sql                            
   declare c_matresp_sel cursor with hold for p_matresp_sel    
   #Matricula Responsavel pela Requisitante - Fornax-Quantum   
  
  
  #Serie nota fiscal - Fornax-Quantum  
  let l_sql =  "select fisnotsrenum "     
              ,"  from dbsmopg  "     
              ," where socopgnum = ? "
  prepare p_serienota_sel from l_sql                       
  declare c_serienota_sel cursor with hold for p_serienota_sel
  #Serie Nota fiscal - Fornax-Quantum 
  
  #Codigo Retencao - Fornax-Quantum 
  let l_sql = "select ipsdnccod        " 
             ," from dbsmprsatvipsdnc  "
             ,"where pcpatvcod = ?     "
             ,"  and pestipcod = ?     "
  prepare p_codretecao_sel from l_sql                          
  declare c_codretecao_sel cursor with hold for p_codretecao_sel
  #Codigo Retencao - Fornax-Quantum 
  
  
  # Seleciona os registros de rateio                        
  let l_sql = " select a.empcod, a.succod, a.cctcod, a.cctratvlr ", 
              "   from dbsmcctrat a, dbsmopgitm b ",                        
              "  where a.atdsrvnum = b.atdsrvnum ",                     
              "    and a.atdsrvano = b.atdsrvano ",
              "    and b.socopgnum = ?"                     
  prepare p_cctrat_sap from l_sql                           
  declare c_cctrat_sap cursor with hold for p_cctrat_sap  
  
  
  # Verifica se o serviço passui rateio de centro de custo                        
  let l_sql = " select a.succod ", 
              "   from dbsmcctrat a, dbsmopgitm b ",                        
              "  where a.atdsrvnum = b.atdsrvnum ",                     
              "    and a.atdsrvano = b.atdsrvano ",
              "    and a.atdsrvnum = ?",
              "    and a.atdsrvano = ?"                    
  prepare p_cctrat_srv from l_sql                           
  declare c_cctrat_srv cursor with hold for p_cctrat_srv   

  ## fornax mar/2016 SPR-2016-02269 Projeto Controle de Desconto
  let l_sql = " select dsctipcod, dscvlr from  dbsropgdsc ",
              "  where socopgnum = ? ",
              "  and   dscvlr > 0 "
  prepare pbdbsa01701 from l_sql                           
  declare cbdbsa01701 cursor with hold for pbdbsa01701   

  let l_sql = "select cpodes[1,4], cpodes[6,13]  from datkdominio ",
       	      " where cponom = 'CTC81M00' ",
       	      "   and cpocod = ? "
   prepare pbdbsa01702 from l_sql
   declare cbdbsa01702 cursor for pbdbsa01702
  
  let l_resumo.totopg    = 0
  let l_resumo.totopgems = 0
  let l_resumo.totopgerr = 0
  let l_resumo.totopgazl = 0
  let l_resumo.totopgitl = 0
  let l_resumo.totopgpss = 0
  let l_resumo.totopgsau = 0
  let ws.errflg = false
  let ws.errmsg = null

  # start report bdbsr017_carga_azul to l_path2
  start report bdbsr017_relat to m_path
  # start report bdbsr017_hml   to m_path4

  #---------------------------------------------------------------
  # Ler todas as ordens de pagto. com situacao OK PARA EMISSAO
  #---------------------------------------------------------------
    
  declare c_opg_sel cursor with hold for
  select socopgnum,
         socfatpgtdat,
         socfattotvlr,
         pstcoddig,
         segnumdig,
         corsus,
         succod,
         cctcod,
         pgtdstcod,
         socemsnfsdat,    
         socpgtdoctip,    
         soctip,          
         socpgtdsctip,
         lcvcod,
         aviestcod,
         infissalqvlr                # PSI-11-19199PR Optante Simple
  from dbsmopg
  where socopgsitcod = 6
  order by empcod desc
    

  foreach c_opg_sel into m_bdbsa017.socopgnum   ,
                         m_bdbsa017.socfatpgtdat,
                         m_bdbsa017.socfattotvlr,
                         m_bdbsa017.pstcoddig   ,
                         m_bdbsa017.segnumdig   ,
                         m_bdbsa017.corsus      ,
                         m_bdbsa017.succod      ,
                         m_bdbsa017.cctcod      ,
                         m_bdbsa017.pgtdstcod   ,
                         m_bdbsa017.socemsnfsdat,
                         m_bdbsa017.socpgtdoctip,
                         m_bdbsa017.soctip      ,
                         m_bdbsa017.socpgtdsctip,
                         m_bdbsa017.lcvcod      ,
                         m_bdbsa017.aviestcod   ,
                         m_bdbsa017.infissalqvlr   # PSI-11-19199 Simples

     initialize m_inftrb.* to null

     call inicializa_m_bdbsa017()

     # cria temporaria de agrupamento dos pagamentos, uma por OP
     whenever error continue
     delete from tmp_pagtos where 1 = 1
     whenever error stop

     if sqlca.sqlcode != 0
        then
        whenever error continue
        drop table tmp_pagtos
        create temp table tmp_pagtos(sucursal dec(2), ramo smallint,
                                     modalidade dec(5), valor dec(15,5))
                                     with no log
        whenever error stop

        if sqlca.sqlcode != 0
           then
           let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - Erro na criacao da temporaria de acumulacao do rateio"
           display m_err_rel
           output to report bdbsa017_resumo(m_err_rel)
           exit program(1)
        end if
     end if

     # tratar erro do registro anterior
     if ws.errflg = true
        then
        let l_resumo.totopgerr = l_resumo.totopgerr + 1
        display "", ws.errmsg clipped
        display '------------------------------------------------------------'
        output to report bdbsa017_resumo(ws.errmsg)
     end if

     let ws.errflg = false
     let ws.errmsg = null

     let l_resumo.totopg = l_resumo.totopg + 1

     let m_time = current

     display 'OP..: ', m_bdbsa017.socopgnum using "&&&&&&&&"
     display 'Hora: ', m_time

     #----------------------------------------------------------------
     # Consistir dados que podem ser nulos
     if m_bdbsa017.soctip is null
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000 - tipo do socorro nao identificado"
        let ws.errflg = true
        continue foreach
     end if

     #----------------------------------------------------------------
     # Obter empresa real da OP
     initialize l_res, l_msg,
                m_bdbsa017.atdsrvnum   , m_bdbsa017.atdsrvano   ,
                m_bdbsa017.socopgitmnum, m_bdbsa017.socopgitmvlr,
                m_bdbsa017.opgnfsnum   , m_bdbsa017.c24utidiaqtd,
                m_bdbsa017.c24pagdiaqtd, m_bdbsa017.rsrincdat   ,
                m_bdbsa017.rsrfnldat to null

     whenever error continue
     open c_opgitm_sel using m_bdbsa017.socopgnum
     fetch c_opgitm_sel into m_bdbsa017.atdsrvnum   ,
                             m_bdbsa017.atdsrvano   ,
                             m_bdbsa017.socopgitmnum,
                             m_bdbsa017.socopgitmvlr,
                             m_bdbsa017.opgnfsnum   ,
                             m_bdbsa017.c24utidiaqtd,
                             m_bdbsa017.c24pagdiaqtd,
                             m_bdbsa017.rsrincdat   ,
                             m_bdbsa017.rsrfnldat
     close c_opgitm_sel
     whenever error stop

     if m_bdbsa017.opgnfsnum is null
        then
        let m_bdbsa017.opgnfsnum = 0
     end if

     call cts10g06_dados_servicos(10, m_bdbsa017.atdsrvnum,
                                      m_bdbsa017.atdsrvano)
          returning l_res, l_msg, m_bdbsa017.empcod

     if l_res != 1 or
        m_bdbsa017.empcod is null
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000",
                        " - Empresa do servico nao identificada:", l_msg clipped
        let ws.errflg = true
        continue foreach 
     end if




     # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
     # Empresas que provisionam servicos
     case m_bdbsa017.empcod
          
          when 1
             let m_bdbsa017.prvssrvflg = 0
          when 43
             let m_bdbsa017.prvssrvflg = 0
          otherwise
             let m_bdbsa017.prvssrvflg = 1
          
          # Rodolfo Massini - Display - Inicio   
          display "###########################################"
          display "EMPRESA: ", m_bdbsa017.empcod, " PRVSSRVFLG: ",  m_bdbsa017.prvssrvflg     
          display "###########################################"
          # Rodolfo Massini - Display - Fim
          
     end case
     # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil

     display 'EMPRESA........: ', m_bdbsa017.empcod

     #----------------------------------------------------------------
     # definir tipo do fornecedor que sera pago
     let m_bdbsa017.favtip = 0

     if m_bdbsa017.pstcoddig is not null and
        m_bdbsa017.segnumdig is null
        then
        let m_bdbsa017.favtip = 1    # Prestador
     else
        if m_bdbsa017.lcvcod is not null and
           m_bdbsa017.segnumdig is null
           then
           let m_bdbsa017.favtip = 4   # Locadora
        else
           if m_bdbsa017.segnumdig is not null or m_bdbsa017.pstcoddig = 3
              then
              let m_bdbsa017.favtip = 3    # Reembolso(segurado, prest, loja)
           end if
        end if
     end if

     if (m_bdbsa017.pstcoddig is null and
         m_bdbsa017.segnumdig is null and
         m_bdbsa017.lcvcod is null )   or
         m_bdbsa017.favtip = 0
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000",
                        " - Nao e possivel identificar o tipo do fornecedor"
        let ws.errflg = true
        continue foreach
     end if

     display 'TIPO FAVORECIDO: ', m_bdbsa017.favtip

     #----------------------------------------------------------------
     # busca dados do prestador/segurado/corretor no informix, somente quando
     # OP com interface People
     initialize l_res, l_msg to null

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        case m_bdbsa017.favtip

           when 1   # OP de servico Auto/ RE

              let m_bdbsa017.cod_fornec = m_bdbsa017.pstcoddig

              call ctd12g00_dados_pst2(2, m_bdbsa017.pstcoddig)
                   returning l_res,                l_msg,
                             m_bdbsa017.nomrazsoc, m_bdbsa017.nomgrr,
                             m_bdbsa017.ufdsgl   , m_bdbsa017.endcid,
                             m_bdbsa017.endlgd   , m_bdbsa017.endcep,
                             m_bdbsa017.endcepcmp, m_bdbsa017.endbrr,
                             m_bdbsa017.maides   , m_bdbsa017.lgdtip,
                             m_bdbsa017.lgdnum   , m_bdbsa017.mpacidcod,
                             m_bdbsa017.muninsnum, m_bdbsa017.pisnum,
                             m_bdbsa017.nitnum   , m_bdbsa017.dddcod,
                             m_bdbsa017.teltxt   , m_bdbsa017.prscootipcod,
                             m_bdbsa017.pstsuccod, m_bdbsa017.pcpatvcod,
                             m_bdbsa017.simoptpstflg

              #Correção do endereço - Robert Lima
              whenever error continue
              open c_domend_sel
              fetch c_domend_sel into l_cpocod
              close c_domend_sel

              display "ANTES DO ENDEREÇO TRIBUTOS -LIMA"
              display "m_bdbsa017.pstcoddig = ", m_bdbsa017.pstcoddig
              display "l_cpocod             = ", l_cpocod

              open c_ccende_sel using m_bdbsa017.pstcoddig, l_cpocod
              fetch c_ccende_sel into  m_bdbsa017.ufdsgl
                                      ,m_bdbsa017.endcid
                                      ,m_bdbsa017.endlgd
                                      ,m_bdbsa017.endcep
                                      ,m_bdbsa017.endcepcmp
                                      ,m_bdbsa017.endbrr
                                      ,m_bdbsa017.lgdtip
                                      ,m_bdbsa017.lgdnum
                                      ,m_bdbsa017.lgdcmp

              display "RETORNO DO ENDEREÇO FISCAL"
              display "m_bdbsa017.ufdsgl    = ", m_bdbsa017.ufdsgl clipped
              display "m_bdbsa017.endcid    = ", m_bdbsa017.endcid clipped
              display "m_bdbsa017.endlgd    = ", m_bdbsa017.endlgd clipped
              display "m_bdbsa017.endcep    = ", m_bdbsa017.endcep
              display "m_bdbsa017.endcepcmp = ", m_bdbsa017.endcepcmp
              display "m_bdbsa017.endbrr    = ", m_bdbsa017.endbrr clipped
              display "m_bdbsa017.lgdtip    = ", m_bdbsa017.lgdtip
              display "m_bdbsa017.lgdnum    = ", m_bdbsa017.lgdnum
              display "m_bdbsa017.lgdcmp    = ", m_bdbsa017.lgdcmp

              if sqlca.sqlcode = notfound then

                 #PSI-2012-23608, Biz
                 let lr_aviso.assunto = "PRESTADOR ",m_bdbsa017.nomgrr clipped, " - OP ", m_bdbsa017.socopgnum
                                        ," ",m_bdbsa017.pstcoddig clipped
                                        ," SEM ENDEREÇO FISCAL CADASTRADO"
                 let lr_aviso.texto   = " - SEM ENDEREÇO FISCAL CADASTRADO"


                 display lr_aviso.assunto
                 let l_mail = ctx22g00_envia_email("ANLPGTPS"
                                                  ,lr_aviso.assunto
                                                  ,lr_aviso.texto)
                 close c_ccende_sel
                 continue foreach
              end if

              close c_ccende_sel
              whenever error stop

               display "BUSCA CIDADE"
               display "m_bdbsa017.endcid = ", m_bdbsa017.endcid clipped
               display "m_bdbsa017.ufdsgl = ", m_bdbsa017.ufdsgl

               call cty10g00_obter_cidcod(m_bdbsa017.endcid, m_bdbsa017.ufdsgl)
               returning l_res,
                         l_msg,
                         m_bdbsa017.mpacidcod

               display "l_res                = ", l_res
               display "l_msg                = ", l_msg clipped
               display "m_bdbsa017.mpacidcod = ", m_bdbsa017.mpacidcod

               if l_res = 0 then
               	 initialize lr_saida_801.*  to null
                  call fcgtc801(m_bdbsa017.empcod, m_bdbsa017.mpacidcod)
                  returning lr_saida_801.coderr
                           ,lr_saida_801.msgerr
                           ,lr_saida_801.ppssucnum
                           ,lr_saida_801.etbnom
                           ,lr_saida_801.etbcpjnum
                           ,lr_saida_801.etblgddes
                           ,lr_saida_801.etblgdnum
                           ,lr_saida_801.etbcpldes
                           ,lr_saida_801.etbbrrnom
                           ,lr_saida_801.etbcepnum
                           ,lr_saida_801.etbcidnom
                           ,lr_saida_801.etbufdsgl
                           ,lr_saida_801.etbiesnum
                           ,lr_saida_801.etbmuninsnum

                    display "lr_saida_801.coderr       = ", lr_saida_801.coderr
                    display "lr_saida_801.msgerr       = ", lr_saida_801.msgerr clipped
                    display "lr_saida_801.ppssucnum    = ", lr_saida_801.ppssucnum
                    display "lr_saida_801.etbnom       = ", lr_saida_801.etbnom
                    display "lr_saida_801.etbcpjnum    = ", lr_saida_801.etbcpjnum
                    display "lr_saida_801.etblgddes    = ", lr_saida_801.etblgddes clipped
                    display "lr_saida_801.etblgdnum    = ", lr_saida_801.etblgdnum
                    display "lr_saida_801.etbcpldes    = ", lr_saida_801.etbcpldes clipped
                    display "lr_saida_801.etbbrrnom    = ", lr_saida_801.etbbrrnom clipped
                    display "lr_saida_801.etbcepnum    = ", lr_saida_801.etbcepnum
                    display "lr_saida_801.etbcidnom    = ", lr_saida_801.etbcidnom clipped
                    display "lr_saida_801.etbufdsgl    = ", lr_saida_801.etbufdsgl
                    display "lr_saida_801.etbiesnum    = ", lr_saida_801.etbiesnum
                    display "lr_saida_801.etbmuninsnum = ", lr_saida_801.etbmuninsnum

                  #Grava a sucursal na op
                  whenever error continue
                    update dbsmopg set succod = lr_saida_801.ppssucnum
                    where socopgnum = m_bdbsa017.socopgnum
                  whenever error stop

                  if lr_saida_801.coderr = 0 then
                     let m_cty10g00_out.endcid = lr_saida_801.etbcidnom
                     let m_cty10g00_out.cidcod = m_bdbsa017.mpacidcod

                     if m_bdbsa017.empcod <> 1 then
                        call fcgtc801(1, m_bdbsa017.mpacidcod)
                          returning lr_saida_801.coderr
                                   ,lr_saida_801.msgerr
                                   ,lr_saida_801.ppssucnum
                                   ,lr_saida_801.etbnom
                                   ,lr_saida_801.etbcpjnum
                                   ,lr_saida_801.etblgddes
                                   ,lr_saida_801.etblgdnum
                                   ,lr_saida_801.etbcpldes
                                   ,lr_saida_801.etbbrrnom
                                   ,lr_saida_801.etbcepnum
                                   ,lr_saida_801.etbcidnom
                                   ,lr_saida_801.etbufdsgl
                                   ,lr_saida_801.etbiesnum
                                   ,lr_saida_801.etbmuninsnum
                     end if

                  else
                     display lr_saida_801.msgerr
                  end if

                  #Grava Sucursal no cadastro de prestador
                  if lr_saida_801.ppssucnum is null or lr_saida_801.ppssucnum = ' ' then
                     display "Sucursal retornada por Tributos nula"
                  end if

                  whenever error continue
                    update dpaksocor set succod = lr_saida_801.ppssucnum
                    where pstcoddig = m_bdbsa017.pstcoddig
                  whenever error stop

               else
                  #PSI-2012-23608, BURINI
                  let lr_aviso.assunto = "PRESTADOR ",m_bdbsa017.nomgrr clipped
                                         ," - ",m_bdbsa017.pstcoddig clipped
                                         ," ENDEREÇO FISCAL INVALIDO (CIDADE NAO ENCONTRADA)"
                  let lr_aviso.texto   = " - CIDADE CADASTRADA : ", m_bdbsa017.endcid clipped, " - ", m_bdbsa017.ufdsgl

                  let l_mail = ctx22g00_envia_email("ANLPGTPS"
                                                   ,lr_aviso.assunto
                                                   ,lr_aviso.texto)
                  continue foreach
               end if

           when 4   # OP carro extra soctip = 2

              let m_bdbsa017.cod_fornec = m_bdbsa017.lcvcod

              call ctd19g00_ender_fav_loja(m_bdbsa017.lcvcod,
                                           m_bdbsa017.aviestcod)  # sempre PJ
                   returning l_res,
                             m_bdbsa017.nomrazsoc, m_bdbsa017.endlgd   ,
                             m_bdbsa017.endbrr   , m_bdbsa017.endcep   ,
                             m_bdbsa017.endcepcmp, m_bdbsa017.endcid   ,
                             m_bdbsa017.ufdsgl   , m_bdbsa017.dddcod   ,
                             m_bdbsa017.teltxt   , m_bdbsa017.maides   ,
                             m_bdbsa017.muninsnum, m_bdbsa017.pstsuccod

              call cty10g00_obter_cidcod(m_bdbsa017.endcid, m_bdbsa017.ufdsgl)
                   returning l_res, l_msg, m_bdbsa017.mpacidcod

           when 3  # OP de reembolso segurado, prestador ou loja

              let m_bdbsa017.cod_fornec = m_bdbsa017.segnumdig

              if m_bdbsa017.segnumdig is not null and
                 m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84 # reembolso segurado Azul, sem cadastro na cia
                 then
                 call ctd20g07_ender_cli(m_bdbsa017.segnumdig)
                      returning l_res, l_msg,
                                m_bdbsa017.nomrazsoc, m_bdbsa017.dddcod,
                                m_bdbsa017.teltxt   , m_bdbsa017.lgdtip,
                                m_bdbsa017.endlgd   , m_bdbsa017.lgdnum,
                                m_bdbsa017.lgdcmp   , m_bdbsa017.endcep,
                                m_bdbsa017.endcepcmp, m_bdbsa017.endbrr,
                                m_bdbsa017.endcid   , m_bdbsa017.ufdsgl
              end if

              call cty10g00_obter_cidcod(m_bdbsa017.endcid, m_bdbsa017.ufdsgl)
                   returning l_res, l_msg, m_bdbsa017.mpacidcod

              # segurado pago pela sucursal da OP
              let m_bdbsa017.pstsuccod = m_bdbsa017.succod

        end case

     end if

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84 and
        (m_bdbsa017.cod_fornec is null or m_bdbsa017.nomrazsoc is null)
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000",
                        " - Erro ao obter dados pst/seg/cor: ", l_res ,
                        " | ", l_msg clipped
        let ws.errflg = true
        continue foreach
     end if

     #----------------------------------------------------------------
     # formatar cep para 00000 000
     if m_bdbsa017.endcep is not null and
        m_bdbsa017.endcep > 0
        then
        let m_bdbsa017.endcep = m_bdbsa017.endcep using "&&&&&"
     end if

     if m_bdbsa017.endcepcmp is not null and
        m_bdbsa017.endcepcmp > 0
        then
        let m_bdbsa017.endcepcmp = m_bdbsa017.endcepcmp using "&&&"
     else
        let m_bdbsa017.endcepcmp = "000"
     end if

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84 and
        (length(m_bdbsa017.endcep) < 5 or length(m_bdbsa017.endcepcmp) < 3)
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000",
                        " - Erro ao obter CEP: ", m_bdbsa017.endcep,
                        "-", m_bdbsa017.endcepcmp
        let ws.errflg = true
        continue foreach
     end if

     #----------------------------------------------------------------
     # OP People tem que ter sucursal
     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        if m_bdbsa017.pstsuccod is null or
           m_bdbsa017.pstsuccod <= 0
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - Sucursal da OP nao informada:", m_bdbsa017.pstsuccod
           let ws.errflg = true
           continue foreach
        end if
     end if
     #----------------------------------------------------------------
     # validar paridade empresa X sucursal, empresas diferentes de 01 não tem
     # sucursais em todas as cidades
     initialize l_res, l_msg to null

     if m_bdbsa017.empcod = 14 or
        m_bdbsa017.empcod = 27 or
        m_bdbsa017.empcod = 43 or
        m_bdbsa017.empcod = 50
        then
        call cty16g00_existe_sucursal(m_bdbsa017.empcod, m_bdbsa017.pstsuccod)
             returning l_res, l_msg

        if l_res is null or
           l_res != 0
           then
           if l_res = 100  # sucursal nao existe para a empresa, agrega na matriz
              then
              let m_bdbsa017.pstsuccod = 1
           else
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/000",
                              " - Erro ao validar a sucursal: ", l_msg clipped
              let ws.errflg = true
              continue foreach
           end if
        end if
     end if

     #---------------------------------------------------------------
     # obter cidade ligada a sucursal do fornecedor (tributacao)
     initialize m_cty10g00_out.* to null

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        # buscar sucursal da OP ligada ao prestador
        call cty10g00_dados_sucursal(1, m_bdbsa017.pstsuccod)
             returning m_cty10g00_out.*

        if m_cty10g00_out.cidcod is null or
           m_cty10g00_out.cidcod <= 0
           then
           call cty10g00_obter_cidcod(m_cty10g00_out.endcid, m_cty10g00_out.endufd)
                returning m_cty10g00_out.res,
                          m_cty10g00_out.msg,
                          m_cty10g00_out.cidcod
        end if

        display 'VARIAVEIS do local EF:'
        display 'endcid   : ', m_cty10g00_out.endcid clipped
        display 'endufd   : ', m_cty10g00_out.endufd
        display 'pstsuccod: ', m_bdbsa017.pstsuccod
        display 'erro     : ', m_cty10g00_out.res
        display 'msg      : ', m_cty10g00_out.msg clipped
        display 'cidcod   : ', m_cty10g00_out.cidcod
        display 'mpacidcod: ', m_bdbsa017.mpacidcod

        if m_cty10g00_out.cidcod is null or
           m_cty10g00_out.cidcod <= 0
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - Erro ao obter cidade da OP: ",
                           m_cty10g00_out.msg clipped
           let ws.errflg = true
           continue foreach
        end if
     end if

     #----------------------------------------------------------------
     # obter o total de desconto da OP
     let m_bdbsa017.socfatliqvlr = 0.00

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        call ctd20g06_tot_desc(m_bdbsa017.socopgnum)
             returning l_res, l_msg, m_bdbsa017.socopgdscvlr

        if m_bdbsa017.socopgdscvlr is null
           then
           let m_bdbsa017.socopgdscvlr = 0.00
        end if

        # Valor liquido da OP
        if m_bdbsa017.socfattotvlr is null
           then
           let m_bdbsa017.socfattotvlr = 0.00
        end if

        let m_bdbsa017.socfatliqvlr = m_bdbsa017.socfattotvlr - m_bdbsa017.socopgdscvlr
     end if

     #---------------------------------------------------------------
     # obter o funcionario responsavel pela emissao da OP
     initialize m_bdbsa017.funmat, ws.dptsgl to null

     if m_bdbsa017.empcod != 35  and m_bdbsa017.empcod != 84
        then
        #let m_bdbsa017.funmat = 5903  # Orlando Sangali
        
        #--------------------------------------------------------#
        # Verifica qual a matricula do emissor da OP           
        #--------------------------------------------------------#
        let mr_chave  = "PSOMATRICULASAP"                 
        open c_matresp_sel using  mr_chave              
        fetch c_matresp_sel into  m_bdbsa017.funmat           
        close c_matresp_sel                            
        
        display "m_bdbsa017.funmat: ",m_bdbsa017.funmat
                                                      
        # Obtem o departamento do funcionario
        call cty08g00_depto_func(1, m_bdbsa017.funmat , "F")
             returning l_res, l_msg, ws.dptsgl

        if l_res != 1
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - Erro ao obter depto Func: ", ws.dptsgl
           let ws.errflg = true
           continue foreach
        end if
     end if

     #---------------------------------------------------------------
     # obter dados do favorecido da ordem de pagamento
     initialize m_bdbsa017.socopgfavnom, m_bdbsa017.bcocod    ,
                m_bdbsa017.bcoagnnum   , m_bdbsa017.bcoagndig ,
                m_bdbsa017.bcoctanum   ,
                m_bdbsa017.bcoctadig   , m_bdbsa017.socpgtopccod to null

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        call ctd20g04_dados_favop(1, m_bdbsa017.socopgnum)
             returning l_res, l_msg,
                       m_bdbsa017.socopgfavnom, m_bdbsa017.cgccpfnum,
                       m_bdbsa017.cgcord,       m_bdbsa017.cgccpfdig,
                       m_bdbsa017.pestip,       m_bdbsa017.bcocod,
                       m_bdbsa017.bcoagnnum,    m_bdbsa017.bcoagndig,
                       m_bdbsa017.bcoctanum,    m_bdbsa017.bcoctadig,
                       m_bdbsa017.socpgtopccod
                       

        if m_bdbsa017.cgcord is null  then
           let m_bdbsa017.cgcord = 0
        end if

        if m_bdbsa017.pestip is null
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - pestip nao identificado: ", m_bdbsa017.pestip
           let ws.errflg = true
           continue foreach
        end if

        # pessoa fisica obrigatorio PIS ou NIT, juridica obrigatorio inscr. municipal
        if m_bdbsa017.pestip = 'F'
           then
           if m_bdbsa017.pisnum is null and
              m_bdbsa017.nitnum is null and
              m_bdbsa017.segnumdig is null and   # OP de reembolso nao precisa
              (m_bdbsa017.favtip = 1 or (m_bdbsa017.favtip = 4 and m_bdbsa017.lcvcod != 33))
              then
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/000",
                              " - favorecido PF sem cadastro de PIS/NIT "
              let ws.errflg = true
              continue foreach
           end if
        else
           if m_bdbsa017.segnumdig is null and  # OP de reembolso nao precisa
              (m_bdbsa017.favtip = 1 or (m_bdbsa017.favtip = 4  and m_bdbsa017.lcvcod != 33))
              then
              if m_bdbsa017.muninsnum is null or m_bdbsa017.muninsnum = ' '
                 then
                 let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                 "/000",
                                 " - favorecido PJ sem cadastro de inscricao municipal"
                 let ws.errflg = true
                 continue foreach
              end if

              # revisar cadastro invalido
              if upshift(m_bdbsa017.muninsnum) matches '*ISE*' or
                 upshift(m_bdbsa017.muninsnum) matches '*CONF*'
                 then
                 let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                 "/000",
                                 " - cadastro de inscricao municipal invalido: ",
                                 m_bdbsa017.muninsnum clipped
                 let ws.errflg = true
                 continue foreach
              end if
           end if
        end if

        # opcao de pagto deposito precisa de cadastro de bco/conta/agencia
        if m_bdbsa017.socpgtopccod = 1 and    # dep. conta
           (m_bdbsa017.bcocod    is null and
            m_bdbsa017.bcoagnnum is null and
            m_bdbsa017.bcoagndig is null and
            m_bdbsa017.bcoctanum is null and
            m_bdbsa017.bcoctadig is null )
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - tipo de pagto ", m_bdbsa017.socpgtopccod,
                           " exige cadastro de conta/banco"
           let ws.errflg = true
           continue foreach
        end if
     end if  # empcod != 35

     #----------------------------------------------------------------
     # definir informacoes de tributacao

     if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
        then
        display 'CTS54G00_INFTRB'
        display 'm_bdbsa017.pstcoddig   : ', m_bdbsa017.pstcoddig
        display 'm_bdbsa017.soctip      : ', m_bdbsa017.soctip
        display 'm_bdbsa017.segnumdig   : ', m_bdbsa017.segnumdig
        display 'm_bdbsa017.corsus      : ', m_bdbsa017.corsus
        display 'm_bdbsa017.pestip      : ', m_bdbsa017.pestip
        display 'm_bdbsa017.prscootipcod: ', m_bdbsa017.prscootipcod

        call cts54g00_inftrb(m_bdbsa017.empcod   , m_bdbsa017.pstcoddig,
                             m_bdbsa017.soctip,
                             m_bdbsa017.segnumdig, m_bdbsa017.corsus,
                             m_bdbsa017.pestip   , m_bdbsa017.prscootipcod,
                             m_bdbsa017.pcpatvcod)
                   returning m_inftrb.errcod   ,
                             m_inftrb.errdes   ,
                             m_inftrb.tpfornec ,
                             -- m_inftrb.cbo      ,
                             m_inftrb.retencod ,
                             m_inftrb.socitmtrbflg,
                             m_inftrb.retendes

        if m_inftrb.errcod != 0
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                           " - cts54g00_inftrb | Erro: ",
                           m_inftrb.errcod using "<<<<<<",
                           " ", m_inftrb.errdes
           let ws.errflg = true
           continue foreach
        end if

        let ws.errmsg = "Fornecedor identificado como: ",
                        m_inftrb.tpfornec clipped,
                        " | DESCR: ", m_inftrb.retendes clipped,
                        " | CODRET: ", m_inftrb.retencod using "<<<<<<<<",
                        " | PST: ", m_bdbsa017.pstcoddig using "<<<<<<",
                        " | TIP: ", m_bdbsa017.soctip using "&&",
                        " | SEG: ", m_bdbsa017.segnumdig using "<<<<<<<<",
                        " | COR: ", m_bdbsa017.corsus clipped,
                        " | LCV: ", m_bdbsa017.lcvcod using "<<<<<"
        display ws.errmsg
        let ws.errmsg = null
     end if  # empcod != 35

     #----------------------------------------------------------------
     # data contabil, data da nota ou hoje, nao pode ser data futura
     if m_bdbsa017.socemsnfsdat is null
        then
        let m_bdbsa017.datacontabil = today
     else
        let m_bdbsa017.datacontabil = m_bdbsa017.socemsnfsdat
     end if

     #----------------------------------------------------------------
     # definir codigo de despesa e tipo da operacao interna (ligado a OP)
     let m_bdbsa017.coddesp = null

     if m_bdbsa017.empcod = 35  or m_bdbsa017.empcod = 84
        then
        let m_bdbsa017.oper_interna = 4
     else
        let m_bdbsa017.oper_interna = m_bdbsa017.soctip
     end if

     # Para a Itau não terá nada no informix por isso não precisa de código de despesa
     if m_bdbsa017.empcod != 84 then
        if m_bdbsa017.empcod != 01 and
           m_bdbsa017.empcod != 35
           then
           let m_bdbsa017.coddesp = 317    # Cod.despesa outras empresas

           # Servico Leva e Traz PSS, provisorio
           if m_bdbsa017.empcod = 43 then
	       let m_bdbsa017.coddesp = 979 #Novo codigo para a Porto Faz email Contabilidade Igor dia 05/02/2015
	   end if
        
        else
           if m_bdbsa017.soctip = 1   # PORTO SOCORRO
              then
              if m_bdbsa017.empcod = 35    # Azul seguros
                 then
                 let m_bdbsa017.coddesp = 707    # Cod.despesa OP.P.SOCORRO AZUL
              else
                 let m_bdbsa017.coddesp = 148    # Cod.despesa OP.P.SOCORRO
              end if
           else
              if m_bdbsa017.soctip = 2   # CARRO EXTRA
                 then
                 if m_bdbsa017.empcod = 35    # Azul seguros
                    then
                    let m_bdbsa017.coddesp = 709   # Cod.despesa OP.CARRO-EXTRA AZUL
                 else
                    let m_bdbsa017.coddesp = 163   # Cod.despesa Carro Extra
                 end if
              else  # R.E.
                 let m_bdbsa017.coddesp = 317      # Cod.despesa OP.RE
              end if
           end if
        end if
     end if

     # display "CODIGO DE DESPESA: "
     # display "m_bdbsa017.empcod  : ", m_bdbsa017.empcod using "&&&"
     # display "origem pagto       : 11"
     # display "m_bdbsa017.coddesp : ", m_bdbsa017.coddesp

     #----------------------------------------------------------------
     # definir codigo do local e departamento ligado à matricula
     initialize m_bdbsa017.cctlclcod, m_bdbsa017.cctdptcod to null

     # People busca depto atraves da matricula, sendo enviada a matricula
     # do Orlando, busca depto 2266 (16/07/09)
     let m_bdbsa017.cctlclcod = 1
     let m_bdbsa017.cctdptcod = 2266

     #----------------------------------------------------------------
     # Tipo de documento gerado para a OP
     if m_bdbsa017.socpgtdoctip is null or
        m_bdbsa017.socpgtdoctip = 0
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/000",
                        " - Tipo do documento nao identificado: ",
                        m_bdbsa017.socpgtdoctip
        let ws.errflg = true
        continue foreach
     end if

     case m_bdbsa017.socpgtdoctip
        when 1
           let m_bdbsa017.tipdoc = 'NFS'

        when 2
           let m_bdbsa017.tipdoc = 'R'

        when 3
           let m_bdbsa017.tipdoc = 'RPA'

        when 4
           let m_bdbsa017.tipdoc = 'NE'

        otherwise
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/000",
                              " - Tipo do documento nao identificado: ",
                              m_bdbsa017.socpgtdoctip
           let ws.errflg = true
           continue foreach
     end case

     if m_bdbsa017.socpgtdsctip is null or
        m_bdbsa017.socpgtdsctip < 0
        then
        let m_bdbsa017.socpgtdsctip = 0
     end if

     begin work

     #------------------------------------------------------------
     # Le todos os itens da ordem de pagamento
     #------------------------------------------------------------
     initialize m_bdbsa017.atdsrvnum   , m_bdbsa017.atdsrvano   ,
                m_bdbsa017.socopgitmnum, m_bdbsa017.socopgitmvlr,
                m_bdbsa017.nfsnum      , m_bdbsa017.c24utidiaqtd,
                m_bdbsa017.c24pagdiaqtd, m_bdbsa017.rsrincdat   ,
                m_bdbsa017.rsrfnldat to null

     open    c_opgitm_sel using m_bdbsa017.socopgnum
     foreach c_opgitm_sel into  m_bdbsa017.atdsrvnum   ,
                                m_bdbsa017.atdsrvano   ,
                                m_bdbsa017.socopgitmnum,
                                m_bdbsa017.socopgitmvlr,
                                m_bdbsa017.nfsnum      ,
                                m_bdbsa017.c24utidiaqtd,
                                m_bdbsa017.c24pagdiaqtd,
                                m_bdbsa017.rsrincdat   ,
                                m_bdbsa017.rsrfnldat

        initialize  lr_par.*  to null
        initialize  lr_par2.* to null
        
        let m_flagcctcod = 'N'
        
        #BURINI - mandar e-mail sobre OPs tipo NF, emitidas sem nota fiscal
        if m_bdbsa017.socpgtdoctip = 1 and
           (m_bdbsa017.nfsnum is null or
            m_bdbsa017.nfsnum = " " )
           then
           let lr_mail.msg = "<<html><body><font face='Arial' size=2>",
                             " Erro na emissao da ordem de pagamento!<br>",
                             " Nota Fiscal Nula.<br><br>",
                             " Ordem Pagto: ", m_bdbsa017.socopgnum
                                               using "&&&&&&&&", " / ",
                               m_bdbsa017.socopgitmnum using "&&&", "<br>",
                             " m_bdbsa017.atdsrvnum           = ",
                               m_bdbsa017.atdsrvnum    clipped, "<br>",
                             " m_bdbsa017.atdsrvano           = ",
                               m_bdbsa017.atdsrvano    clipped, "<br>",
                             " m_bdbsa017.socopgitmnum        = ",
                               m_bdbsa017.socopgitmnum clipped, "<br>",
                             " m_bdbsa017.socopgitmvlr        = ",
                               m_bdbsa017.socopgitmvlr clipped, "<br>",
                             " m_bdbsa017.nfsnum              = ",
                               m_bdbsa017.nfsnum       clipped, "<br>",
                             " m_bdbsa017.c24utidiaqtd        = ",
                               m_bdbsa017.c24utidiaqtd clipped, "<br>",
                             " m_bdbsa017.c24pagdiaqtddisplay = ",
                               m_bdbsa017.c24pagdiaqtd clipped, "<br>",
                             " m_bdbsa017.rsrincdat,          = ",
                               m_bdbsa017.rsrincdat    clipped, "<br>",
                             " m_bdbsa017.rsrfnldat           = ",
                               m_bdbsa017.rsrfnldat    clipped, "<br>",
                             "</body></html>"

           let lr_mail.rem = ""#"sergio.burini@correioporto"
           let lr_mail.des = ""#"sergio.burini@correioporto"
           let lr_mail.ccp = ""
           let lr_mail.cco = ""
           let lr_mail.ass = "ERRO NA EMISSÃO DE OP SEM NOTA FISCAL"
           let lr_mail.idr = "F0104577"
           let lr_mail.tip = "html"

           call figrc009_mail_send1(lr_mail.*)
                returning l_cod_erro, l_msg_erro

           if l_cod_erro != 0 then
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/",  m_bdbsa017.socopgitmnum using "&&&",
                              " - Erro no envio do email: ",
                              l_cod_erro using "<<<<<<&", " - ",
                              l_msg_erro clipped
           else
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/",  m_bdbsa017.socopgitmnum using "&&&",
                              " - Numero Nota Fiscal nulo ou zero"
           end if

           let ws.errflg = true
           display "Rollback da nota fiscal"
           rollback work
           exit foreach
        end if

        if m_bdbsa017.nfsnum is null
           then
           let m_bdbsa017.nfsnum = 0
        end if

        # consistir item com numero de NFS diferente
        if m_bdbsa017.nfsnum != m_bdbsa017.opgnfsnum
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Divergencia entre numero de NF: NF_item: ",
                           m_bdbsa017.nfsnum using "<<<<<<<<",
                           " | NF_opg: ", m_bdbsa017.opgnfsnum using "<<<<<<<<"
           let ws.errflg = true
           display "rollback(1)"
           rollback work
           exit foreach
        end if

        # se for recibo, mandar o numero da OP no lugar do numero NF, pois tem
        # muitos prestadores pagamento recibo com Nros NF igual
        # Luis Fernando 29/07/2009
        if m_bdbsa017.tipdoc = 'R'
           then
           let m_bdbsa017.nfsnum = m_bdbsa017.socopgnum
        end if

        #---------------------------------------------------------------
        # Obtem dados do servico do item OP
        initialize ws.atdsrvorg, ws.atddat, ws.sindat, ws.ciaempcod to null

        call cts10g06_dados_servicos(20, m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano)
             returning l_res, l_msg, ws.atdsrvorg, ws.atddat, ws.ciaempcod

        if l_res != 1
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro ao obter dados do servico: ", l_msg clipped
           let ws.errflg = true
           display "rollback(2)"
           rollback work
           exit foreach
        end if

        # consistir OP nao possui servicos de empresas diferentes
        if ws.ciaempcod is null
           then
           let ws.ciaempcod = m_bdbsa017.empcod
        else
           if ws.ciaempcod != m_bdbsa017.empcod
              then
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/",  m_bdbsa017.socopgitmnum using "&&&",
                              " - Empresa da OP diferente da empresa do item: ",
                              " op: ", m_bdbsa017.empcod,
                              " | item: ", ws.ciaempcod
              let ws.errflg = true
              display "rollback(3)"
              rollback work
              exit foreach
           end if
        end if

        # buscar data do sinistro (pode ser nula)
        call ctd07g08_compl_srv(1, m_bdbsa017.atdsrvnum, m_bdbsa017.atdsrvano)
             returning l_res, l_msg, ws.sindat

        #----------------------------------------------------------------
        # Obtem documento (apolice) do item da ordem de pagamento
        initialize l_apolice.* to null

        call cts00g09_apolice(m_bdbsa017.atdsrvnum,
                              m_bdbsa017.atdsrvano,
                              2,# para retornar as variaveis necessarias para o pagamento
                              m_bdbsa017.empcod,
                              m_bdbsa017.soctip)
                    returning l_apolice.succod,                                 
                              l_apolice.ramcod,    
                              l_apolice.modalidade,
                              l_apolice.aplnumdig, 
                              l_apolice.itmnumdig, 
                              l_apolice.corsus, 
                              l_apolice.emsdat,     
                              l_apolice.edsnumref,      
                              l_apolice.prporg,          
                              l_apolice.prpnumdig       
                              
                              
                              

        # Ramo nao pode ser nulo para a emissao da OP
        if l_apolice.ramcod is null or
           l_apolice.ramcod <= 0
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro ramo da apolice nao encontrado, ramcod: ",
                           l_apolice.ramcod using "<<<<<<"
           let ws.errflg = true
           display "rollback(4)"
           rollback work
           exit foreach
        end if

        display "DADOS DA APOLICE:"
        let m_dsp = "Item: "  , m_bdbsa017.socopgitmnum using "#####"  , '| ',
                    "succod: ", l_apolice.succod     using "####&"     , '| ',
                    "ramcod: ", l_apolice.ramcod     using "####&"     , '| ',
                    "modcod: ", l_apolice.modalidade using "##&"       , '| ',
                    "aplcod: ", l_apolice.aplnumdig  using "########&" , '| ',
                    "itmcod: ", l_apolice.itmnumdig  using "######&"   , '| ',
                    "emsdat: ", l_apolice.emsdat                       , '| ',
                    "srvnum: ", m_bdbsa017.atdsrvnum using "#########&", '| ',
                    "srvano: ", m_bdbsa017.atdsrvano using "#&"        , '| ',
                    "sindat: ", ws.sindat                              , '|'

        display m_dsp clipped

        # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
        call cts00g09_ramocontabil(m_bdbsa017.atdsrvnum,
                                   m_bdbsa017.atdsrvano,
                                   l_apolice.modalidade,
                                   l_apolice.ramcod)
                                   
             returning l_ramcontabil.ctbramcod,
                       l_ramcontabil.ctbmdlcod,
                       l_ramcontabil.clscod,
                       l_ramcontabil.pgoclsflg
        
        # Rodolfo Massini - Display - Inicio
        display "#################################################################"
        display "Chamei funcao cts00g09_ramocontabil com os parametros: "
        display " "
        display " numero do servico: ", m_bdbsa017.atdsrvnum
        display " ano do servico ..: ", m_bdbsa017.atdsrvano
        display " modalidade ......: ", l_apolice.modalidade
        display " ramo ............: ", l_apolice.ramcod
        display " "
        display "A funcao cts00g09_ramocontabil retornou os valores: "
        display " "
        display " ramo contabil .....: ", l_ramcontabil.ctbramcod
        display " modalidade contabil: ", l_ramcontabil.ctbmdlcod
        display " "
        display "OBS.: estes valores retornados serao utilizados em todas as  "
        display "      as chamadas do ctb00g16_envio_contabil."
        display "#################################################################"
        # Rodolfo Massini - Display - Fim
                
        # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
        
        # tratar item de OP conforme tipo do Socorro
        case m_bdbsa017.soctip

           when 1   # Interface contabilidade P.Socorro

              let m_bdbsa017.socopgitmcst = null
              call ctd20g03_custo_item(m_bdbsa017.socopgnum,
                                       m_bdbsa017.socopgitmnum)
                   returning l_res, l_msg, m_bdbsa017.socopgitmcst

              if m_bdbsa017.socopgitmcst is not null
                 then
                 let m_bdbsa017.socopgitmvlr = m_bdbsa017.socopgitmvlr +
                                               m_bdbsa017.socopgitmcst
              end if

              if m_bdbsa017.prvssrvflg = 0
                 then

                 display "Ajusta o provisionamento"
                 call ctb00g03_altprvdsp(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgnum,
                                         m_bdbsa017.socopgitmnum,
                                         m_bdbsa017.socopgitmvlr,
                                         m_bdbsa017.socemsnfsdat,
                                         m_bdbsa017.socopgfasdat,
                                         m_bdbsa017.socfatpgtdat)
                      returning ws.sqlcode, lr_par.*, lr_par2.*

                 if ws.sqlcode <> 0  then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro no Ajuste do Provisionamento(1): ",
                                    ws.sqlcode
                    let ws.errflg = true
                    display "rollback(5)"
                    rollback work
                    exit foreach
                 end if


                 display "ajusta novo provisionamento 1"
                 call ctb00g16_ajusteprv(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgitmvlr)
                    returning lr_erro.err,   
                              lr_erro.msgerr,
                              lr_erro.srvvlr,
                              lr_erro.vlrapgt,  
                              lr_erro.vlraprv,   
                              lr_erro.srvajsevncod,
                              lr_erro.srvpgtevncod,
                              lr_erro.srvpovevncod,
                              lr_erro.srvatdctecod
                 if lr_erro.err = 2 then
                    call ctb00g16_envio_contabil(lr_erro.srvpovevncod,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,   
                                                 l_apolice.prporg       ,   
                                                 l_apolice.prpnumdig    ,   
                                                 l_apolice.corsus       ,   
                                                 lr_erro.vlraprv        ,   
                                                 m_bdbsa017.atdsrvnum   ,   
                                                 m_bdbsa017.atdsrvano   ,   
                                                 0,
                                                 lr_erro.srvatdctecod   ,
                                                 ws.atddat)
                    let lr_erro.err = 0
                 end if 
                 display "Ajuste"  
                 
                 if lr_erro.err = 0 then
                    if lr_erro.srvvlr = 0 then
                    else
                       call ctb00g16_envio_contabil(lr_erro.srvajsevncod,   
                                                    m_bdbsa017.empcod      ,   
                                                    l_apolice.succod       ,   
                                                    l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_apolice.aplnumdig    ,   
                                                    l_apolice.itmnumdig    ,   
                                                    l_apolice.edsnumref    ,   
                                                    l_apolice.prporg       ,   
                                                    l_apolice.prpnumdig    ,   
                                                    l_apolice.corsus       ,   
                                                    lr_erro.srvvlr         ,   
                                                    m_bdbsa017.atdsrvnum   ,   
                                                    m_bdbsa017.atdsrvano   ,   
                                                    0,
                                                    lr_erro.srvatdctecod,
                                                    m_bdbsa017.socfatpgtdat)
                    end if   
                    if lr_erro.vlrapgt < 0 then
                       #Alterar o valor para positivo, pois este movimento
                       # nao pode receber valor menores que 0
                       let lr_erro.vlrapgt = lr_erro.vlrapgt*(-1)
                    end if 
                    display "lr_erro.vlrapgt: ",lr_erro.vlrapgt  
                    call ctb00g16_envio_contabil(lr_erro.srvpgtevncod,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,   
                                                 l_apolice.prporg       ,    
                                                 l_apolice.prpnumdig    ,   
                                                 l_apolice.corsus       ,   
                                                 lr_erro.vlrapgt        ,   
                                                 m_bdbsa017.atdsrvnum   ,   
                                                 m_bdbsa017.atdsrvano   ,   
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat)
                 end if       
                 
                 output to report bdbsr017_relat(lr_erro.srvpgtevncod   ,  
                                                 m_bdbsa017.empcod      ,
                                                 l_apolice.succod       ,
                                                 l_ramcontabil.ctbramcod,
                                                 l_ramcontabil.ctbmdlcod,
                                                 l_apolice.aplnumdig    ,
                                                 l_apolice.itmnumdig    ,
                                                 l_apolice.edsnumref    ,
                                                 l_apolice.prporg       ,
                                                 l_apolice.prpnumdig    ,
                                                 l_apolice.corsus       ,
                                                 lr_erro.vlrapgt        ,
                                                 m_bdbsa017.atdsrvnum   ,
                                                 m_bdbsa017.atdsrvano   ,
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat,
                                                 lr_erro.msgerr         )
              end if

              #-------------------------------------------------------------
              # Verifica a existencia de sinistro para documento
              #-------------------------------------------------------------
              # busca dados da ligacao
              initialize ws.ligcvntip  to null
              initialize ws.c24astcod  to null

              let ws.lignum = cts20g00_servico(m_bdbsa017.atdsrvnum,
                                               m_bdbsa017.atdsrvano)

              call ctd06g00_ligacao_emp(3, ws.lignum)
                   returning l_res, l_msg, ws.ligcvntip, ws.c24astcod

              # busca dados do sinistro
              initialize l_sin.* to null

              if ws.atdsrvorg =  4   or    # Remocao por Sinistro
                 ws.atdsrvorg =  5   or    # R.P.T.
                 ws.atdsrvorg =  7   or    # Replace
                 ws.atdsrvorg = 17   then  # Replace congenere

                 # ramo 53 trocado por 553, solic. contabilidade
                 if ws.c24astcod = "G13"
                    then
                    let l_apolice.ramcod = 553
                 end if

                 if ws.sindat is null  then
                    let ws.atddat = ws.sindat
                 end if

                 if l_apolice.succod    is not null  and
                    l_apolice.aplnumdig is not null  and
                    l_apolice.itmnumdig is not null  then

                    call osauc040_sinistro(l_apolice.ramcod,
                                           l_apolice.succod,
                                           l_apolice.aplnumdig,
                                           l_apolice.itmnumdig,
                                           ws.sindat,
                                           ws.atddat,
                                           ws.privez)
                                returning  l_sin.ramcod,
                                           l_sin.sinano,
                                           l_sin.sinnum

                    let ws.privez = "N"
                 end if
              end if

              #-------------------------------------------------------------
              # Realiza interface com Contabilidade
              #-------------------------------------------------------------
              ########################################################
              ###  // Seleciona o código da despesa contábil //     ##
              ###  --------------------------------------------     ##
              ###  -  01 Sinistros a regularizar                    ##
              ###  -  02 Sinistros a regularizar - Replace          ##
              ###  -  03 Contas a pagar                             ##
              ###  -  04 Outras despesas operacionais               ##
              ###  -  05 Porto Socorro - Assistencia a locadoras    ##
              ###  -  06 Porto Socorro - Porto Card                 ##
              ###  -  07 Corporate                                  ##
              ###  -  08 Porto Socorro - AZUL SEGUROS               ##
              ###  -  09 Porto Socorro - Auxílio funeral            ##
              ###  -  10 PS - Auxílio funeral Migracao Interp.      ##
              ########################################################


	           call ctb00g03_selprvdsp(m_bdbsa017.atdsrvnum, m_bdbsa017.atdsrvano)
                      returning sqlca.sqlcode


             call ctb00g03_trsrvauto(m_bdbsa017.atdsrvnum,
                                     m_bdbsa017.atdsrvano,
                                     ws.atdsrvorg,2)
                  returning m_bdbsa017.socitmdspcod

              if m_bdbsa017.socitmdspcod is null or m_bdbsa017.socitmdspcod = ' ' then
                      let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                      "/",  m_bdbsa017.socopgitmnum using "&&&",
                                      " - Erro ao buscar codigo de despesa do AUTO(ctb00g03_trsrvauto)"
                      let ws.errflg = true
                      display "rollback(6 - teste)"
                      rollback work
                      exit foreach
	            end if


              #-------------------------------------------------------
              # call ctb00g03_grvprvdsp(5,
              # PSI 198404 retirado provisionamento de caixa
              # Codigo antigo na versao anterior do PVCS
              #-------------------------------------------------------

              let l_lin = 1
              let l_rateio.cctcod = 0

              open c_cctrat_sel using m_bdbsa017.atdsrvnum,
                                      m_bdbsa017.atdsrvano

              foreach c_cctrat_sel into l_rateio.empcod,
                                        l_rateio.succod,
                                        l_rateio.cctcod,
                                        l_rateio.cctratvlr

                 call ctb00g03_grvratdsp(l_rateio.empcod,
                                         m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgnum,
                                         m_bdbsa017.socopgitmnum,
                                         m_bdbsa017.socitmdspcod,
                                         l_rateio.succod,
                                         l_rateio.cctcod,
                                         l_rateio.cctratvlr)
                               returning ws.sqlcode

                 if ws.sqlcode <> 0 then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro na interface ctb00g03_grvratdsp(1): ",
                                    ws.sqlcode
                    let ws.errflg = true
                    display "rollback(7)"
                    rollback work
                    exit foreach
                 end if
                 
                 let m_flagcctcod = 'S'
                 
              end foreach

              if ws.errflg = true then
                 exit foreach
              end if

           when 2  # Interface contabilidade Carro-extra

              if m_bdbsa017.prvssrvflg = 0
                 then

                 # Ajusta o provisionamento
                 call ctb00g03_altprvdsp(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgnum,
                                         m_bdbsa017.socopgitmnum,
                                         m_bdbsa017.socopgitmvlr,
                                         m_bdbsa017.socemsnfsdat,
                                         m_bdbsa017.socopgfasdat,
                                         m_bdbsa017.socfatpgtdat)
                      returning ws.sqlcode, lr_par.*, lr_par2.*

                 if ws.sqlcode <> 0 then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro no Ajuste do Provisionamento(2): ",
                                    ws.sqlcode
                    let ws.errflg = true
                    display "rollback(8)"
                    rollback work
                    exit foreach
                 end if
                 
                 display "ajusta novo provisionamento 2"
                 call ctb00g16_ajusteprv(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgitmvlr)
                    returning lr_erro.err,   
                              lr_erro.msgerr,
                              lr_erro.srvvlr,
                              lr_erro.vlrapgt,  
                              lr_erro.vlraprv,   
                              lr_erro.srvajsevncod,
                              lr_erro.srvpgtevncod,
                              lr_erro.srvpovevncod,
                              lr_erro.srvatdctecod
                 if lr_erro.err = 2 then
                    call ctb00g16_envio_contabil(lr_erro.srvpovevncod,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,   
                                                 l_apolice.prporg       ,   
                                                 l_apolice.prpnumdig    ,   
                                                 l_apolice.corsus       ,   
                                                 lr_erro.vlraprv        ,   
                                                 m_bdbsa017.atdsrvnum   ,   
                                                 m_bdbsa017.atdsrvano   ,   
                                                 0,
                                                 lr_erro.srvatdctecod,
                                                 ws.atddat)
                    let lr_erro.err = 0
                 end if 
                 display "Ajuste"  
                 
                 if lr_erro.err = 0 then
                    if lr_erro.srvvlr = 0 then
                    else
                       call ctb00g16_envio_contabil(lr_erro.srvajsevncod   ,   
                                                    m_bdbsa017.empcod      ,   
                                                    l_apolice.succod       ,   
                                                    l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_apolice.aplnumdig    ,   
                                                    l_apolice.itmnumdig    ,   
                                                    l_apolice.edsnumref    ,   
                                                    l_apolice.prporg       ,   
                                                    l_apolice.prpnumdig    ,   
                                                    l_apolice.corsus       ,   
                                                    lr_erro.srvvlr         ,   
                                                    m_bdbsa017.atdsrvnum   ,   
                                                    m_bdbsa017.atdsrvano   ,   
                                                    0,
                                                    lr_erro.srvatdctecod,
                                                    m_bdbsa017.socfatpgtdat)
                   end if
                    display "Pagamento"  
                    
                    if lr_erro.vlrapgt < 0 then
                       #Alterar o valor para positivo, pois este movimento
                       # nao pode receber valor menores que 0
                       let lr_erro.vlrapgt = lr_erro.vlrapgt*(-1)
                    end if  
                    display "lr_erro.vlrapgt: ",lr_erro.vlrapgt  
                     
                    call ctb00g16_envio_contabil(lr_erro.srvpgtevncod,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,   
                                                 l_apolice.prporg       ,    
                                                 l_apolice.prpnumdig    ,   
                                                 l_apolice.corsus       ,   
                                                 lr_erro.vlrapgt        ,   
                                                 m_bdbsa017.atdsrvnum   ,   
                                                 m_bdbsa017.atdsrvano   ,   
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat)
                 end if      
                 output to report bdbsr017_relat(lr_erro.srvpgtevncod   ,  
                                                 m_bdbsa017.empcod      ,
                                                 l_apolice.succod       ,
                                                 l_ramcontabil.ctbramcod,
                                                 l_ramcontabil.ctbmdlcod,
                                                 l_apolice.aplnumdig    ,
                                                 l_apolice.itmnumdig    ,
                                                 l_apolice.edsnumref    ,
                                                 l_apolice.prporg       ,
                                                 l_apolice.prpnumdig    ,
                                                 l_apolice.corsus       ,
                                                 lr_erro.vlrapgt        ,
                                                 m_bdbsa017.atdsrvnum   ,
                                                 m_bdbsa017.atdsrvano   ,
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat,
                                                 lr_erro.msgerr         )

              end if

              if m_bdbsa017.empcod != 35  and m_bdbsa017.empcod != 84
                 then
                 #----------------------------------------------------------
                 # VERIFICA E GRAVA CONTABILIDADE CARRO-EXTRA
                 #----------------------------------------------------------
                 #
                 #---------------------------------------------------------#
                 # Cod. Tipo de movimento p/contabilidade                  #
                 #---------------------------------------------------------#
                 #  1   Carro-Extra pagto                      (op c/pagto)#
                 #  2   Carro-Extra Sinistros pagto            (op c/pagto)#
                 #  3   Locacao Veic.para Cia pagto            (op c/pagto)#
                 #  4   Carro-Extra pagto                      (op s/pagto)#
                 #  5   Carro-Extra Sinistros pagto            (op s/pagto)#
                 #  6   Locacao Veic.para Cia pagto            (op s/pagto)#
                 #---------------------------------------------------------#

                 #----------------------------------------------------------
                 # Verifica a existencia de sinistro para documento
                 #----------------------------------------------------------
                 initialize ws.avialgmtv, ws.avioccdat,
                            ws.slcsuccod, ws.slccctcod,
                            ws.aviprvent  to null

                 initialize l_sin.* to null

                 call ctd19g03_dados_rent(1, m_bdbsa017.atdsrvnum,
                                          m_bdbsa017.atdsrvano)
                      returning l_res, l_msg, ws.avialgmtv,
                                ws.avioccdat, ws.slcsuccod,
                                ws.slccctcod, ws.aviprvent

                 if ws.avialgmtv is null
                    then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro na selecao dados da locacao/srv:",
                                    m_bdbsa017.atdsrvnum, " | ano:",
                                    m_bdbsa017.atdsrvano
                    let ws.errflg = true
                    display "rollback(9)"
                    rollback work
                    exit foreach
                 end if

                 if ws.avialgmtv = 0  or
                    ws.avialgmtv = 1  or
                    ws.avialgmtv = 6  or -- OSF 33367
                    ws.avialgmtv = 3  or  # PSI 215457
                    ws.avialgmtv = 9
                    then
                    if l_apolice.succod    is not null  and
                       l_apolice.aplnumdig is not null  and
                       l_apolice.itmnumdig is not null
                       then
                       call cty01g00_sinistro_apl(l_apolice.succod,
                                                  l_apolice.aplnumdig,
                                                  l_apolice.itmnumdig,
                                                  ws.avioccdat)
                            returning l_res, l_msg, l_sin.ramcod,
                                      l_sin.sinnum, l_sin.sinano
                    end if
                 end if

                 if l_sin.ramcod is null
                    then
                    let l_sin.ramcod = l_apolice.ramcod
                 end if

                 #-------------------------------------------------------------
                 # Realiza interface com Contabilidade
                 #-------------------------------------------------------------

                 if ws.avialgmtv <> 4   # DEPTOS
                    then

                   # validacao do opgmvttip
                    call ctb00g03_selprvdsp(m_bdbsa017.atdsrvnum,m_bdbsa017.atdsrvano)
                        returning sqlca.sqlcode


                    call ctb00g03_trsrvce(m_bdbsa017.atdsrvnum,
                                            m_bdbsa017.atdsrvano,
                                            ws.atdsrvorg,2)
                         returning ws.opgmvttip

                    if m_bdbsa017.socpgtdsctip = 4
                       then
                       let ws.opgmvttip = ws.opgmvttip + 3   # (op s/pagto)
                    end if

                    #----------------------------
                    # Verifica se tem prorrogacao
                    #----------------------------
                    call cts36g01_diaqtd(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano)
                         returning l_res, l_msg, ws.aviprodiaqtd_tot

                    if ws.aviprodiaqtd_tot is not null and
                       ws.aviprodiaqtd_tot  <>  0      then
                       let ws.saldo = ws.aviprvent

                       if m_bdbsa017.c24pagdiaqtd <  ws.aviprvent then
                          let ws.saldo = m_bdbsa017.c24pagdiaqtd
                       end if

                       let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr /
                                                 m_bdbsa017.c24pagdiaqtd *
                                                 ws.saldo

                       if m_bdbsa017.pestip is null then
                          let m_bdbsa017.pestip = "J"
                       end if

                       let ws.opgmvttip = 3     # FORCAR DEPARTAMENTO

                       if m_bdbsa017.socpgtdsctip = 4
                          then
                          let ws.opgmvttip = 6                # (op s/pagto)
                       end if

                       let ws.saldo = m_bdbsa017.c24pagdiaqtd - ws.aviprvent

                       if ws.saldo > 0 then
                          let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr /
                                                    m_bdbsa017.c24pagdiaqtd *
                                                    ws.saldo

                          if m_bdbsa017.pestip is null then
                             let m_bdbsa017.pestip = "J"
                          end if

                       end if

                       #-------------------------
                       # RATEIO
                       #-------------------------
                       let ws.saldo = m_bdbsa017.c24pagdiaqtd - ws.aviprvent

                       open c_prorog_sel using m_bdbsa017.atdsrvnum,
                                               m_bdbsa017.atdsrvano

                       foreach c_prorog_sel into ws.aviprodiaqtd,
                                                 ws.slcsuccod,
                                                 ws.slccctcod

                          if ws.saldo < ws.aviprodiaqtd then
                             let ws.aviprodiaqtd = ws.saldo
                          end if

                          let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr /
                                                    m_bdbsa017.c24pagdiaqtd *
                                                    ws.aviprodiaqtd

                          call ctb00g03_grvratdsp(m_bdbsa017.empcod,
                                                  m_bdbsa017.atdsrvnum,
                                                  m_bdbsa017.atdsrvano,
                                                  m_bdbsa017.socopgnum,
                                                  m_bdbsa017.socopgitmnum,
                                                  ws.opgmvttip,
                                                  ws.slcsuccod,
                                                  ws.slccctcod,
                                                  ws.socopgitmvlr_pro)
                                        returning ws.sqlcode

                          if ws.sqlcode <> 0  then
                             let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                             "/",  m_bdbsa017.socopgitmnum using "&&&",
                                             " - Erro na interface ctb00g03_grvratdsp(2): ",
                                             ws.sqlcode
                             let ws.errflg = true
                             display "rollback(10)"
                             rollback work
                             exit foreach
                          end if

                          let ws.saldo = ws.saldo - ws.aviprodiaqtd
                          let m_flagcctcod = 'S'
                       end foreach

                       if ws.errflg = true
                          then
                          exit foreach
                       end if

                    else

                       if m_bdbsa017.pestip is null then
                          let m_bdbsa017.pestip = "J"
                       end if

                    end if

                 else

                    let ws.opgmvttip = 3     # DEPARTAMENTO

                    if m_bdbsa017.socpgtdsctip = 4
                       then
                       let ws.opgmvttip = 6                # (op s/pagto)
                    end if

                    if m_bdbsa017.pestip is null then
                       let m_bdbsa017.pestip = "J"
                    end if

                    #-------------------------------------------------------
                    # Verifica se tem prorrogacao
                    #-------------------------------------------------------
                    call cts36g01_diaqtd(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano)
                         returning l_res, l_msg, ws.aviprodiaqtd_tot

                    #--------------------------------------------------------
                    # Servico pago mais de uma vez, nao fazer rateio
                    #--------------------------------------------------------
                    if m_bdbsa017.rsrincdat is not null  then
                       let ws.aviprodiaqtd_tot  =  0
                    end if

                    if ws.aviprodiaqtd_tot is not null and
                       ws.aviprodiaqtd_tot  <>  0      then

                       let ws.saldo = ws.aviprvent

                       if m_bdbsa017.c24pagdiaqtd <  ws.aviprvent then
                          let ws.saldo = m_bdbsa017.c24pagdiaqtd
                       end if

                       let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr /
                                                 m_bdbsa017.c24pagdiaqtd *
                                                 ws.saldo
                    else
                       let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr
                    end if

                    # display 'VARIAVEIS ctb00g03_grvratdsp'
                    # display 'empcod          : ', m_bdbsa017.empcod
                    # display 'atdsrvnum       : ', m_bdbsa017.atdsrvnum
                    # display 'atdsrvano       : ', m_bdbsa017.atdsrvano
                    # display 'socopgnum       : ', m_bdbsa017.socopgnum
                    # display 'socopgitmnum    : ', m_bdbsa017.socopgitmnum
                    # display 'opgmvttip       : ', ws.opgmvttip
                    # display 'slcsuccod       : ', ws.slcsuccod
                    # display 'slccctcod       : ', ws.slccctcod
                    # display 'socopgitmvlr_pro: ', ws.socopgitmvlr_pro

                    call ctb00g03_grvratdsp(m_bdbsa017.empcod,
                                            m_bdbsa017.atdsrvnum,
                                            m_bdbsa017.atdsrvano,
                                            m_bdbsa017.socopgnum,
                                            m_bdbsa017.socopgitmnum,
                                            ws.opgmvttip,
                                            ws.slcsuccod,
                                            ws.slccctcod,
                                            ws.socopgitmvlr_pro)
                         returning ws.sqlcode

                    if ws.sqlcode <> 0  then
                       let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                       "/",  m_bdbsa017.socopgitmnum using "&&&",
                                       " - Erro na interface ctb00g03_grvratdsp(3): ",
                                       ws.sqlcode
                       let ws.errflg = true
                       display "rollback(11)"
                       rollback work
                       exit foreach
                    end if

                    #------------
                    # RATEIO
                    #------------
                    if ws.aviprodiaqtd_tot is not null and
                       ws.aviprodiaqtd_tot  <>  0
                       then

                       let ws.saldo = m_bdbsa017.c24pagdiaqtd - ws.aviprvent

                       open c_prorog_sel using m_bdbsa017.atdsrvnum,
                                               m_bdbsa017.atdsrvano

                       foreach c_prorog_sel into ws.aviprodiaqtd, ws.slcsuccod,
                                                 ws.slccctcod

                          if ws.saldo < ws.aviprodiaqtd then
                             let ws.aviprodiaqtd = ws.saldo
                          end if

                          let ws.socopgitmvlr_pro = m_bdbsa017.socopgitmvlr /
                                                    m_bdbsa017.c24pagdiaqtd *
                                                    ws.aviprodiaqtd

                          call ctb00g03_grvratdsp(m_bdbsa017.empcod,
                                                  m_bdbsa017.atdsrvnum,
                                                  m_bdbsa017.atdsrvano,
                                                  m_bdbsa017.socopgnum,
                                                  m_bdbsa017.socopgitmnum,
                                                  ws.opgmvttip,
                                                  ws.slcsuccod,
                                                  ws.slccctcod,
                                                  ws.socopgitmvlr_pro)
                               returning ws.sqlcode

                          if ws.sqlcode <> 0  then
                             let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                             "/",  m_bdbsa017.socopgitmnum using "&&&",
                                             " - Erro na interface ctb00g03_grvratdsp(4): ",
                                             ws.sqlcode
                             let ws.errflg = true
                             display "rollback(12)"
                             rollback work
                             exit foreach
                          end if

                          let ws.saldo = ws.saldo - ws.aviprodiaqtd

                       end foreach

                       if ws.errflg = true
                          then
                          exit foreach
                       end if

                    end if
                 end if

              end if  # m_bdbsa017.empcod != 35


           when 3  # Interface contabilidade RE

              let m_bdbsa017.socopgitmcst = null
              call ctd20g03_custo_item(m_bdbsa017.socopgnum,
                                       m_bdbsa017.socopgitmnum)
                   returning l_res, l_msg, m_bdbsa017.socopgitmcst

              if m_bdbsa017.socopgitmcst is not null  then
                 let m_bdbsa017.socopgitmvlr = m_bdbsa017.socopgitmvlr +
                                               m_bdbsa017.socopgitmcst
              end if

              if m_bdbsa017.prvssrvflg = 0
                 then

                 # Ajusta o provisionamento
                 call ctb00g03_altprvdsp(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgnum,
                                         m_bdbsa017.socopgitmnum,
                                         m_bdbsa017.socopgitmvlr,
                                         m_bdbsa017.socemsnfsdat,
                                         m_bdbsa017.socopgfasdat,
                                         m_bdbsa017.socfatpgtdat)
                               returning ws.sqlcode, lr_par.*, lr_par2.*

                 if ws.sqlcode <> 0  then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro no Ajuste do Provisionamento(3): ",
                                    ws.sqlcode
                    let ws.errflg = true
                    display "rollback(13)"
                    rollback work
                    exit foreach
                 end if
                 
                 display "ajusta novo provisionamento 3"
                 call ctb00g16_ajusteprv(m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgitmvlr)
                    returning lr_erro.err,   
                              lr_erro.msgerr,
                              lr_erro.srvvlr,
                              lr_erro.vlrapgt,  
                              lr_erro.vlraprv,   
                              lr_erro.srvajsevncod,
                              lr_erro.srvpgtevncod,
                              lr_erro.srvpovevncod,
                              lr_erro.srvatdctecod
                 if lr_erro.err = 2 then
                    call ctb00g16_envio_contabil(lr_erro.srvpovevncod   ,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,    
                                                 l_apolice.prporg       ,   
                                                 l_apolice.prpnumdig    ,     
                                                 l_apolice.corsus       ,    
                                                 lr_erro.vlraprv        ,   
                                                 m_bdbsa017.atdsrvnum   ,    
                                                 m_bdbsa017.atdsrvano   ,    
                                                 0,
                                                 lr_erro.srvatdctecod   ,
                                                 ws.atddat)
                    let lr_erro.err = 0
                 end if 
                 display "Ajuste"  
                 
                 if lr_erro.err = 0 then
                    if lr_erro.srvvlr = 0 then
                    else
                       call ctb00g16_envio_contabil(lr_erro.srvajsevncod,   
                                                    m_bdbsa017.empcod      ,   
                                                    l_apolice.succod       ,   
                                                    l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                    l_apolice.aplnumdig    ,   
                                                    l_apolice.itmnumdig    ,   
                                                    l_apolice.edsnumref    ,   
                                                    l_apolice.prporg       ,   
                                                    l_apolice.prpnumdig    ,   
                                                    l_apolice.corsus       ,   
                                                    lr_erro.srvvlr         ,   
                                                    m_bdbsa017.atdsrvnum   ,   
                                                    m_bdbsa017.atdsrvano   ,   
                                                    0,
                                                    lr_erro.srvatdctecod   ,
                                                    m_bdbsa017.socfatpgtdat)
                    end if
                    display "Pagamento"  
                    
                    if lr_erro.vlrapgt < 0 then
                       #Alterar o valor para positivo, pois este movimento
                       # nao pode receber valor menores que 0
                       let lr_erro.vlrapgt = lr_erro.vlrapgt*(-1)
                    end if 
                    display "lr_erro.vlrapgt: ",lr_erro.vlrapgt  
                      
                    call ctb00g16_envio_contabil(lr_erro.srvpgtevncod   ,   
                                                 m_bdbsa017.empcod      ,   
                                                 l_apolice.succod       ,   
                                                 l_ramcontabil.ctbramcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_ramcontabil.ctbmdlcod, # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
                                                 l_apolice.aplnumdig    ,   
                                                 l_apolice.itmnumdig    ,   
                                                 l_apolice.edsnumref    ,   
                                                 l_apolice.prporg       ,   
                                                 l_apolice.prpnumdig    ,   
                                                 l_apolice.corsus       ,   
                                                 lr_erro.vlrapgt        ,   
                                                 m_bdbsa017.atdsrvnum   ,   
                                                 m_bdbsa017.atdsrvano   ,    
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat)
                 end if
                 output to report bdbsr017_relat(lr_erro.srvpgtevncod   ,  
                                                 m_bdbsa017.empcod      ,
                                                 l_apolice.succod       ,
                                                 l_ramcontabil.ctbramcod,
                                                 l_ramcontabil.ctbmdlcod,
                                                 l_apolice.aplnumdig    ,
                                                 l_apolice.itmnumdig    ,
                                                 l_apolice.edsnumref    ,
                                                 l_apolice.prporg       ,
                                                 l_apolice.prpnumdig    ,
                                                 l_apolice.corsus       ,
                                                 lr_erro.vlrapgt        ,
                                                 m_bdbsa017.atdsrvnum   ,
                                                 m_bdbsa017.atdsrvano   ,
                                                 m_bdbsa017.socopgnum   ,
                                                 lr_erro.srvatdctecod   ,
                                                 m_bdbsa017.socfatpgtdat,
                                                 lr_erro.msgerr         )
              end if

              #-------------------------------------------------------------
              # Verifica a existencia de sinistro para documento
              #-------------------------------------------------------------
              # busca dados da ligacao
              initialize ws.ligcvntip, ws.c24astcod  to null

              let ws.lignum = cts20g00_servico(m_bdbsa017.atdsrvnum,
                                               m_bdbsa017.atdsrvano)

              call ctd06g00_ligacao_emp(3, ws.lignum)
                   returning l_res, l_msg, ws.ligcvntip, ws.c24astcod

              # busca dados do sinistro
              initialize l_sin.* to null

              if ws.atdsrvorg = 13   then  ###  Sinistro RE

                 if ws.sindat is null then
                    let ws.atddat = ws.sindat
                 end if

                 if l_apolice.succod    is not null  and
                    l_apolice.aplnumdig is not null  and
                    l_apolice.itmnumdig is not null  then

                    call osauc040_sinistro(l_apolice.ramcod,
                                           l_apolice.succod,
                                           l_apolice.aplnumdig,
                                           l_apolice.itmnumdig,
                                           ws.sindat,
                                           ws.atddat,
                                           ws.privez)
                                returning  l_sin.ramcod,
                                           l_sin.sinano,
                                           l_sin.sinnum

                    let ws.privez = "N"
                 end if
              end if

              #-----------------------------------------------------------#
              # Cod.  Despesa Contabil                                    #
              #-----------------------------------------------------------#
              #  21   Atend.RE (clausulas 34A,35A,35R,30,31,32,10,11 e 12)#
              #  22   Porto Socorro - clausula 095                        #
              #  23   Sinistros a regularizar - Atendimento RE            #
              #  24   Residencia - Reparos sem cobertura                  #
              #  25   Atend resid apol seg Vida+Mulher                    #
              #  26   Atend resid apol seg Educacional Coletivo           #
              #  27   Atend garantia estendida                            #
              #  30   Atend resid cartao saude (grupo ramo = 5)           #
              #-----------------------------------------------------------#

              # validacao do opgmvttip
              call ctb00g03_selprvdsp(m_bdbsa017.atdsrvnum,
                                      m_bdbsa017.atdsrvano)
                  returning sqlca.sqlcode


              call ctb00g03_trsrvre(m_bdbsa017.atdsrvnum,
                                      m_bdbsa017.atdsrvano,
                                      ws.atdsrvorg,2)
                   returning m_bdbsa017.socitmdspcod

              if m_bdbsa017.socitmdspcod is null or m_bdbsa017.socitmdspcod = ' ' then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Divergencia na origem, cod. desp. contabil nao identificado"
                    let ws.errflg = true
                    display "rollback(14)"
                    rollback work
                    exit foreach
              end if

              #-------------------------------------------------------
              # call ctb00g03_grvprvdsp(5,
              # PSI 198404 retirado provisionamento de caixa
              # Codigo antigo na versao anterior do PVCS
              #-------------------------------------------------------
              let l_rateio.cctcod = 0

              open c_cctrat_sel using m_bdbsa017.atdsrvnum,
                                      m_bdbsa017.atdsrvano

              foreach c_cctrat_sel into l_rateio.empcod,
                                        l_rateio.succod,
                                        l_rateio.cctcod,
                                        l_rateio.cctratvlr

                 call ctb00g03_grvratdsp(l_rateio.empcod,
                                         m_bdbsa017.atdsrvnum,
                                         m_bdbsa017.atdsrvano,
                                         m_bdbsa017.socopgnum,
                                         m_bdbsa017.socopgitmnum,
                                         m_bdbsa017.socitmdspcod,
                                         l_rateio.succod,
                                         l_rateio.cctcod,
                                         l_rateio.cctratvlr)
                               returning ws.sqlcode

                 if ws.sqlcode <> 0 then
                    let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                    "/",  m_bdbsa017.socopgitmnum using "&&&",
                                    " - Erro na interface ctb00g03_grvratdsp(5): ",
                                    ws.sqlcode
                    let ws.errflg = true
                    display "rollback(15)"
                    rollback work
                    exit foreach
                 end if
                 let m_flagcctcod = 'S'
              end foreach

        end case

        if ws.errflg = true  then
           exit foreach
        end if

        #--------------------------------------------------
        # Gravacao dos dados referentes ao sinistro
        #--------------------------------------------------
        if l_sin.sinnum is not null and
           l_sin.sinano is not null
           then

           # display "DADOS DE SINISTRO:"
           # display "m_bdbsa017.socopgnum   : ", m_bdbsa017.socopgnum
           # display "m_bdbsa017.socopgitmnum: ", m_bdbsa017.socopgitmnum
           # display "l_sin.ramcod           : ", l_sin.ramcod
           # display "l_sin.sinnum           : ", l_sin.sinnum
           # display "l_sin.sinano           : ", l_sin.sinano

           call ctd20g05_ins_opgsin(m_bdbsa017.socopgnum,
                                    m_bdbsa017.socopgitmnum,
                                    l_sin.ramcod, l_sin.sinnum, l_sin.sinano)
                returning l_res, l_msg

           # tratar 2a tentativa de emissao apos insucesso People
           if l_res != 0 and
              l_res != -268 and l_res != 268 and  # Unique constraint constraint-name violated
              l_res != -100 and l_res != 100 and  # duplicate value for a record with unique key
              l_res != -239 and l_res != 239      # duplicate value in a UNIQUE INDEX
              then
              let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                              "/",  m_bdbsa017.socopgitmnum using "&&&",
                              " - Erro na insercao dados SINISTROxITEM, sqlcode: ",
                              l_res
              let ws.errflg = true
              display "rollback(16)"
              rollback work
              exit foreach
           end if

        end if

        # RETIRADO PELO PSI-2010-00003 Beatriz Araujo - BUSCA O RAMO CONTABIL DO SERVICO PARA PAGAMENTO
        ##----------------------------------------------------------------
        ## Inserir item da OP para agrupar por sucursal/ramo/modalidade
        ##----------------------------------------------------------------
        ## AUTO modalidade sempre 0, ramo sempre 531, a pedido da Contabilidade
        #if m_bdbsa017.soctip = 1
        #   then
        #   ## MANTER A MODALIDADE DA APOLICE   PSI 249050 IS+ar
        #   ## let l_apolice.modalidade = 0
        #   let l_apolice.ramcod = 531
        #end if

        # sucursal 1 forcada no agrupamento a pedido da Contabilidade
        let l_apolice.succod = 1

        #----------------------------------------------------------------------------------|
        # PSI-2010-00003 Beatriz Araujo - BUSCA O RAMO CONTABIL DO SERVICO PARA PAGAMENTO  |
        #----------------------------------------------------------------------------------|

         # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
         initialize l_ramcontabil.ctbramcod
                   ,l_ramcontabil.ctbmdlcod
                   ,l_ramcontabil.clscod
                   ,l_ramcontabil.pgoclsflg
         to null
         # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
         
         call cts00g09_ramocontabil(m_bdbsa017.atdsrvnum,
                                    m_bdbsa017.atdsrvano,
                                    l_apolice.modalidade,
                                    l_apolice.ramcod)
              returning l_ramcontabil.ctbramcod,
                        l_ramcontabil.ctbmdlcod,
                        l_ramcontabil.clscod,
                        l_ramcontabil.pgoclsflg
         
        whenever error continue
        insert into tmp_pagtos values(l_apolice.succod,
                                      l_ramcontabil.ctbramcod, #l_apolice.ramcod retirado pela circular395
                                      l_ramcontabil.ctbmdlcod, #l_apolice.modalidade retirado pela circular395
                                      m_bdbsa017.socopgitmvlr)

        if sqlca.sqlcode <> 0  then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro na acumulacao ramo/modalidade, sqlcode: ",
                           sqlca.sqlcode
           let ws.errflg = true
           display "rollback(17)"
           rollback work
           exit foreach
        end if
        whenever error stop

        #-----------------------------------------------------
        # Atualiza servico com dados do pagamento
        #-----------------------------------------------------
        call ctd07g00_upd_srv_opg(m_bdbsa017.socfatpgtdat,
                                  m_bdbsa017.socopgitmvlr,
                                  m_bdbsa017.atdsrvnum   ,
                                  m_bdbsa017.atdsrvano)
             returning l_sqlcode, l_sqlerrd

        if l_sqlerrd != 1 then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro na atualizacao data pagto do servico, sqlcode: ",
                           l_sqlcode, "|Sqlerrd: ", l_sqlerrd
           let ws.errflg = true
           display "rollback(18)"
           rollback work
           exit foreach
        end if

        #-----------------------------------------------------
        # Atualiza tributacao no item da OP
        #-----------------------------------------------------
        call ctd20g01_upd_trb_opgitm(m_bdbsa017.socopgnum   ,
                                     m_bdbsa017.socopgitmnum,
                                     m_inftrb.socitmtrbflg  ,
                                     m_bdbsa017.socitmdspcod)
             returning l_sqlcode, l_sqlerrd

        if l_sqlerrd != 1 then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro na atualizacao tributacao item de OP, sqlcode: ",
                           l_sqlcode, "|Sqlerrd: ", l_sqlerrd
           let ws.errflg = true
           display "rollback(19)"
           rollback work
           exit foreach
        end if

        whenever error stop

     end foreach

     # erros no processo, print mensagem e partir para a proxima OP
     if ws.errflg = true
        then
        continue foreach
     end if

     let ws.nfschr = m_bdbsa017.nfsnum using "&&&&&&&&&"

     #----------------------------------------------------------------
     # Prepara valores conforme soctip / empresa

     if m_bdbsa017.empcod != 35  and m_bdbsa017.empcod != 84 # Azul Seguros e ITau Seguros nao emitem OP
        then

        let ws.socopgsitcod = 10   # Aguardando retorno People

        initialize ws.pgtcmpopccod, ws.pgtfrnorgcod, ws.pgtfrntipcod to null

        if m_bdbsa017.soctip = 1 or     # OP.P.SOCORRO
           m_bdbsa017.soctip = 3 then   # OP.RE

           case m_bdbsa017.socpgtopccod
                when 1  let ws.pgtcmpopccod = "D"   # deposito em conta
                        let m_bdbsa017.pgtdstcod = 98

                # opcao de pagamento cheque, o destino sera o mesmo digitado na capa da OP
                when 2  let ws.pgtcmpopccod = "C"   # cheque
                        -- let m_bdbsa017.pgtdstcod = 901
                        -- let m_bdbsa017.pgtdstcod = 923

                when 3  let ws.pgtcmpopccod = "D"   # boleto
                        let m_bdbsa017.pgtdstcod = 900
                        let m_bdbsa017.modal_pgto = 'TI'
           end case

           if m_bdbsa017.pstcoddig is not null
              then
              let ws.pgtfrnorgcod = f_fundigit_inttostr(m_bdbsa017.cgccpfnum,11)
              let ws.pgtfrntipcod = 4
           else
              if m_bdbsa017.corsus is not null
                 then
                 call cty00g00_org_cor(m_bdbsa017.corsus)
                      returning l_res, l_msg, ws.pgtfrnorgcod
                 let ws.pgtfrntipcod = 1
              else
                 if m_bdbsa017.segnumdig is not null
                    then
                    let ws.pgtfrnorgcod = m_bdbsa017.segnumdig
                    let ws.pgtfrntipcod = 2
                 end if
              end if
           end if

        else  # soctip = 2, Carro Extra

           if m_bdbsa017.socpgtdsctip = 4  and
              m_bdbsa017.socfatliqvlr = m_bdbsa017.socopgdscvlr
              then
              # ---> OP ZERADA ACERTO CONTABIL
           else

              case m_bdbsa017.socpgtopccod
                 when 1
                    let ws.pgtcmpopccod = "D"  # deposito em conta

                 when 2
                    let ws.pgtcmpopccod = "C"  # cheque

                 when 3
                    let ws.pgtcmpopccod = "D"  # boleto
                    let m_bdbsa017.pgtdstcod = 900
              end case

              if m_bdbsa017.lcvcod is not null  then
                 let ws.pgtfrnorgcod = f_fundigit_inttostr(m_bdbsa017.cgccpfnum
                                                         , 11)
                 let ws.pgtfrntipcod = 4
              else
                 if m_bdbsa017.corsus is not null
                    then
                    call cty00g00_org_cor(m_bdbsa017.corsus)
                         returning l_res, l_msg, ws.pgtfrnorgcod
                    let ws.pgtfrntipcod = 1
                 else
                    if m_bdbsa017.segnumdig is not null  then
                       let ws.pgtfrnorgcod = m_bdbsa017.segnumdig
                       let ws.pgtfrntipcod = 2
                    end if
                 end if
              end if

           end if ## OP ZERADA

        end if  ## soctip

     end if  # m_bdbsa017.empcod != 35

     #----------------------------------------------------------------
     # Interface com o People

     # Empresa 35 Azul nao faz pagamento na Porto, considera emitida e emite
     # relatorio para a Azul fazer o pagto
     # Empresa 84 Itau nao faz pagamento na Porto, considera emitida e emite
     # relatorio para a Itau fazer o pagto
     if m_bdbsa017.empcod = 35 or m_bdbsa017.empcod = 84
        then
        let ws.socopgsitcod = 7   # Emitida

     else

        # OP ZERADA ACERTO CONTABIL, nao realiza interface e considera emitida
        if m_bdbsa017.socpgtdsctip = 4  and
           (m_bdbsa017.socfatliqvlr * (-1)) = m_bdbsa017.socopgdscvlr
           then
        else
           initialize d_bfpga017.* to null
           initialize a_bfpga_err  to null
           initialize a_bfpga_pgt  to null
           initialize a_bfpga_adc  to null

           if m_bdbsa017.socopgdscvlr is not null  and
              m_bdbsa017.socopgdscvlr  >  0.00     then
              let a_bfpga_adc[1].paradccod = 8
              let a_bfpga_adc[1].paradcvlr = m_bdbsa017.socopgdscvlr * (-1)
           end if

           let ws.errmsg = null 
    
          #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
          call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("038PTSOCTRIB",today,m_bdbsa017.empcod, 0)  
               returning  lr_ret.stt                                                                 
                         ,lr_ret.msg     
                 
          display "lr_ret.stt ", lr_ret.stt
          display "lr_ret.msg ", lr_ret.msg                                                             
          
          #Verifica se a OP e People ou SAP  Fim     #Fornax-Quantum  
          if lr_ret.stt = 0 then 
              
             display "Entrei para o PEOPLE" 
                                                 
            call bdbsa017_carrega_ffpgc309() returning ws.errcod, ws.errmsg
            
            if ws.errcod != 0
               then
               let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/000",
                               " - ", ws.errmsg clipped
               let ws.errflg = true
               display "rollback(20)"
               rollback work
               continue foreach
            end if
            
            let l_arr = 1             
            
            while true
                  let m_tempo_chamada = current
                  display "TEmpoCPEOPLE:",m_tempo_chamada,m_bdbsa017.socopgnum,'|',
                         m_bdbsa017.empcod,'|', m_bdbsa017.pstcoddig
                  
                  call g_bfpga017(# Parametro 1 - Compromisso de Pagamento
                                  11,                       # Codigo da Interface
                                  m_bdbsa017.empcod,        # Codigo da Empresa
                                  ws.dptsgl,                # Sigla do Departamento emitente
                                  1,                        # Sucursal do Porto Socorro
                                  m_bdbsa017.cctlclcod,     # Codigo do Local do emitente
                                  m_bdbsa017.cctdptcod,     # Codigo do Departamento do emitente
                                  m_bdbsa017.socopgnum,     # Nr Documento de Referencia
                                  m_bdbsa017.corsus,        # Codigo da Susep
                                  m_bdbsa017.pgtdstcod,     # Destino de Pagamento
                                  14,                       # Tp Apropriacao Despesa (AD)
                                  ws.pgtcmpopccod,          # Opcao de Pagamento
                                  m_bdbsa017.coddesp,               # Tipo de Despesa
                                  "N",                      # Flag de Adiantamento
                                  "N",                      # Flag Sinistro Ressarcimento
                                  01,                       # Empcod do Funcionario
                                  m_bdbsa017.funmat,        # Matricula do Funcionario
                  
                                  # Parcelas - array de 5
                                  # 1a. Parcela de Pagamento
                                  1,                        # Numero da Parcela
                                  m_bdbsa017.socfatpgtdat,  # Dt Vencimento da Parcela
                                  m_bdbsa017.socfattotvlr,  # Valor bruto
                  
                                  # Adicionais da Parcela - array de 10
                                  a_bfpga_adc[01].*,
                                  a_bfpga_adc[02].*,
                                  a_bfpga_adc[03].*,
                                  a_bfpga_adc[04].*,
                                  a_bfpga_adc[05].*,
                                  a_bfpga_adc[06].*,
                                  a_bfpga_adc[07].*,
                                  a_bfpga_adc[08].*,
                                  a_bfpga_adc[09].*,
                                  a_bfpga_adc[10].*,
                  
                                  # 2a. Parcela de Pagamento
                                  "",
                                  "",
                                  "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                  
                                  # 3a. Parcela de Pagamento
                                  "",
                                  "",
                                  "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                  
                                  # 4a. Parcela de Pagamento
                                  "",
                                  "",
                                  "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                  
                                  # 5a. Parcela de Pagamento
                                  "",
                                  "",
                                  "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                                  "", "", "",
                  
                                  # Parametro 2 - Favorecido
                                  ws.pgtfrnorgcod,         # Codigo do Favorecido
                                  m_bdbsa017.cgccpfnum,    # Nr do CGC/CPF do Favorecido
                                  m_bdbsa017.cgcord,       # Ordem CGC/CPF do Favorecido
                                  m_bdbsa017.cgccpfdig,    # Digito do CGC/CPF
                                  ws.pgtfrntipcod,         # Tipo de Favorecido
                                  m_bdbsa017.socopgfavnom, # Nome do Favorecido
                                  m_bdbsa017.pestip,       # Tipo de Pessoa
                                  m_bdbsa017.dddcod,       # Codigo DDD
                                  m_bdbsa017.teltxt,       # Fone de Contato
                                  m_bdbsa017.bcocod,       # Nr Banco para Deposito
                                  m_bdbsa017.bcoagnnum,    # Nr Agencia para Deposito
                                  m_bdbsa017.bcoctanum,    # Nr Conta Corrente deposito
                                  m_bdbsa017.bcoctadig,    # Digito da Conta Corrente
                  
                                  # Parametro 3 - Contabilizacao
                                  m_bdbsa017.socfatpgtdat, # Data da Competencia
                                  m_bdbsa017.socemsnfsdat, # Data de Emissao
                                  4,                       # Tp doc: 4 - Nota Fiscal
                                  m_bdbsa017.socopgnum,    # Nr Documento Contabil
                                  m_bdbsa017.nfsnum,       # Historico Contabil
                                  1,                       # Sucursal do PS
                                  531,                     # Ramo
                                  0,                       # Modalidade
                                  "",                      # Numero da Apolice
                                  "",                      # Numero do Endosso
                                  ws.nfschr,               # Complemento
                  
                                  # Dados do Rateio array de 11
                                  # Codigo da Empresa, Codigo da Sucursal, Codigo do Local,
                                  # Codigo do Departamento, Tipo de Valor, Codigo de Despesa/Valor,
                                  # Percentual
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "" )
                  
                       returning #Retorno 1 : Ocorrencia
                                 d_bfpga017.pgtcmpnum, #Nr Apropriacao Despesa (AD)
                  
                                 #Numero da AP array de 5
                                 a_bfpga_pgt[01].pgtautnum,           #Numero da AP
                                 a_bfpga_pgt[02].pgtautnum,           #Numero da AP
                                 a_bfpga_pgt[03].pgtautnum,           #Numero da AP
                                 a_bfpga_pgt[04].pgtautnum,           #Numero da AP
                                 a_bfpga_pgt[05].pgtautnum,           #Numero da AP
                  
                                 #Codigo de Erros array de 10
                                 a_bfpga_err[01].errcod,              #Codigo de Erro
                                 a_bfpga_err[02].errcod,              #Codigo de Erro
                                 a_bfpga_err[03].errcod,              #Codigo de Erro
                                 a_bfpga_err[04].errcod,              #Codigo de Erro
                                 a_bfpga_err[05].errcod,              #Codigo de Erro
                                 a_bfpga_err[06].errcod,              #Codigo de Erro
                                 a_bfpga_err[07].errcod,              #Codigo de Erro
                                 a_bfpga_err[08].errcod,              #Codigo de Erro
                                 a_bfpga_err[09].errcod,              #Codigo de Erro
                                 a_bfpga_err[10].errcod               #Codigo de Erro
                  
                       let m_tempo_retorno  = current
                       display "TEmpoRPEOPLE:",m_tempo_chamada,m_bdbsa017.socopgnum,'|',
                               m_bdbsa017.empcod,'|', m_bdbsa017.pstcoddig 
                  
                  if d_bfpga017.pgtcmpnum is null or
                     d_bfpga017.pgtcmpnum =  0
                     then
                  
                     let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                                     "/",  m_bdbsa017.socopgitmnum using "&&&",
                                     " - Erro na interface BFPGA017"
                  
                     for l_arr = 1 to 10
                        if a_bfpga_err[l_arr].errcod is null
                           then
                           exit for
                        else
                           call g_erro_bfpga017(a_bfpga_err[l_arr].errcod)
                                returning ws.errdsc
                  
                           let ws.errmsg = ws.errmsg clipped, ' | '
                                         , a_bfpga_err[l_arr].errcod using "<<<<<<<<<<"
                                         , " - ", ws.errdsc clipped
                           
                           if a_bfpga_err[l_arr].errcod = 2009 then
                             
                              call MQ4GL_Init() returning l_cod_erro, l_msg_erro
                  
                              if l_cod_erro <> 0 then
                                  let m_err_rel = "Erro no MQ4GL_Init: ", l_cod_erro, "Mensagem: ",
                                                  l_msg_erro clipped
                                  display m_err_rel
                                  output to report bdbsa017_resumo(m_err_rel)
                                  exit program(1)
                              end if
                             
                              let g_isMqConn = true
                              continue while
                           end if 
                           -- display " Cod.Retorno: ", a_bfpga_err[l_arr].errcod
                                     -- using "<<<<<<<<<<", " - ", ws.errdsc clipped
                        end if
                     end for
                  
                     let ws.errflg = true
                     display "rollback(21)"
                     rollback work
                     continue foreach
                  else
                     display "AD provisoria: ", d_bfpga017.pgtcmpnum
                  end if
               exit while
            end while  
          else #Carrega as informacoes no SAP Incio  #Fornax-Quantum   
           if m_bdbsa017.socpgtopccod <> 2 then
            display "Entrei para o SAP"
            call bdsa017_carrega_global_sap()
            
            display "m_retsap.stt: ",m_retsap.stt
            if m_retsap.stt = 0 then
               let ws.socopgsitcod = 11
            else 
               let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",     
                               "/",  m_bdbsa017.socopgitmnum using "&&&",         
                               " - Erro na chamada SAP: ",    
                               m_retsap.stt, "-", m_retsap.msg
               let ws.errflg = true                                               
               display "rollback(SAP)"                                             
               rollback work                                                      
               continue foreach                                                   
            end if 
           else
             let ws.socopgsitcod = 7
           end if 
          end if #Carrega as informacoes no SAP Fim  #Fornax-Quantum
        end if
     end if

     #---------------------------------------------------------------
     # Finaliza processo de emissao da ordem de pagamento
     #---------------------------------------------------------------
     -- display "Finalizando processamento OP: ", m_bdbsa017.socopgnum

     # gravar fase 4 (emissao) para OPs Azul/Itau que nao fazem a interface
     if m_bdbsa017.empcod = 35  or m_bdbsa017.empcod = 84
        then
        call ctd20g02_insere_faseop(m_bdbsa017.socopgnum, 4,
                                    m_bdbsa017.socopgfasdat,
                                    m_bdbsa017.socopgfashor,
                                    999999)
                          returning l_sqlcode

        if l_sqlcode != 0
           then
           let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                           "/",  m_bdbsa017.socopgitmnum using "&&&",
                           " - Erro na insercao da fase da OP, sqlcode: ",
                           l_sqlcode
           let ws.errflg = true
           display "rollback(22)"
           rollback work
           continue foreach
        end if
     end if

     # gravar status da OP
     call ctd20g00_upd_opg(m_bdbsa017.socopgnum, ws.socopgsitcod)
                 returning l_sqlcode, l_sqlerrd

     if l_sqlerrd != 1
        then
        let ws.errmsg = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                        "/",  m_bdbsa017.socopgitmnum using "&&&",
                        " - Erro na atualizacao da OP, sqlcode: ", l_sqlcode,
                        " | sqlerrd[3]: ", l_sqlerrd
        let ws.errflg = true
        display "rollback(23)"
        rollback work
        continue foreach
     end if

     commit work

     case m_bdbsa017.empcod

        when 35
               let l_resumo.totopgazl = l_resumo.totopgazl + 1

               let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/",  m_bdbsa017.socopgitmnum using "&&&",
                               " - Azul Seguros, emitida Informix"
        when 84
               let l_resumo.totopgitl = l_resumo.totopgitl + 1

               let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/",  m_bdbsa017.socopgitmnum using "&&&",
                               " - Seguro Auto e Residência Itaú, emitida Informix"
        when 43
               let l_resumo.totopgpss = l_resumo.totopgpss + 1

               let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/"  , m_bdbsa017.socopgitmnum using "&&&",
                               " | ", m_bdbsa017.soctip using "&&",
                               " | ", m_bdbsa017.socfatpgtdat,
                               " - Porto Serviços, Interface OK"
        
        when 50
               let l_resumo.totopgsau = l_resumo.totopgsau + 1

               let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/"  , m_bdbsa017.socopgitmnum using "&&&",
                               " | ", m_bdbsa017.soctip using "&&",
                               " | ", m_bdbsa017.socfatpgtdat,
                               " - Porto Saúde, Interface OK"
       otherwise
               let l_resumo.totopgems = l_resumo.totopgems + 1

               let m_err_rel = "OP: ", m_bdbsa017.socopgnum using "&&&&&&&&",
                               "/"  , m_bdbsa017.socopgitmnum using "&&&",
                               " | ", m_bdbsa017.soctip using "&&",
                               " | ", m_bdbsa017.socfatpgtdat,
                               " | Interface OK"
     end case


     display m_err_rel
     output to report bdbsa017_resumo(m_err_rel)

     display '------------------------------------------------------------'

  end foreach

  if ws.errflg = true
     then
     let l_resumo.totopgerr = l_resumo.totopgerr + 1
     display "", ws.errmsg clipped
     output to report bdbsa017_resumo(ws.errmsg)
  end if

  -- display ""
  display m_traco
  output to report bdbsa017_resumo(m_traco)

  let m_err_rel = 'Total de OPs para o dia referido......: '
                 , l_resumo.totopg using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  let m_err_rel = 'Total de OPs emitidas Azul Seguros....: '
                 , l_resumo.totopgazl using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  let m_err_rel = 'Total de OPs emitidas Seguro Auto e Residência Itau....: '
                 , l_resumo.totopgitl using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)
  
  let m_err_rel = 'Total de OPs emitidas Porto Serviços..: '
                 , l_resumo.totopgpss using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)
  
  let m_err_rel = 'Total de OPs emitidas Porto Saude.....: '
                 , l_resumo.totopgsau using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  let m_err_rel = 'Total de OPs emitidas Porto Seguro....: '
                 , l_resumo.totopgems using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  let m_err_rel = 'Total de OPs com erros na interface...: '
                 , l_resumo.totopgerr using "&&&&&"
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  display m_traco
  output to report bdbsa017_resumo(m_traco)

  let m_err_rel = 'Data/hora Fim do processo: ', current
  display m_err_rel
  output to report bdbsa017_resumo(m_err_rel)

  finish report bdbsr017_relat
  #finish report bdbsr017_carga_azul
  finish report bdbsa017_resumo
  # finish report bdbsr017_hml

  whenever error continue
  drop table tmp_pagtos
  whenever error stop

end function  ###  bdbsa017

#----------------------------------------------------------------
function bdbsa017_carrega_ffpgc309()
#----------------------------------------------------------------
# Carregar valores ligados a OP na global

   # Inicializa as globais:
   #  g_ffpgc309_op
   #  g_ffpgc309_op.atributo_contabil
   #  g_ffpgc309_voucher[01]
   #  g_ffpgc309_voucher[01].distribuicao[l_arr]
   #  g_ffpgc309_parcelas
   #  g_ffpgc309_fornec
   #  g_ffpgc309_banco
   #  g_ffpgc309_trib

   define l_count  integer  ,
          l_res    smallint ,
          l_err    smallint ,
          l_msg    char(100),
          l_arr    integer

   define l_ctbcrtcod  like ctgrcrtram_new.ctbcrtcod  # carteira conforme o soctip

   define l_ratgrp record
          succod   dec(2,0) ,
          ramcod   smallint ,
          modal    dec(5,0) ,
          valor    dec(23,3)
   end record

   let l_count  =  null
   let l_ctbcrtcod  =  null

   let l_err = null
   let l_arr = null
   let l_res = null
   let l_msg = null
   let l_err = 0

   initialize l_ratgrp.* to null
   initialize l_ctbcrtcod to null

   call ffpgc309_inicializa_glb()

   # DADOS DA ORDEM DE PAGAMENTO
   let g_ffpgc309_op.empcod    = m_bdbsa017.empcod        # Codigo da Empresa
   let g_ffpgc309_op.vlr_bruto = m_bdbsa017.socfattotvlr  # Valor Bruto da OP
   let g_ffpgc309_op.moeda     = 'R$'                     # Moeda

   # Numero Referencia do Adiantamento
   let g_ffpgc309_op.ref_pagto_ant = ' '

   # Flag de Baixa de Pagamento Antecipado
   let g_ffpgc309_op.flg_baixa_pagto_ant = 'N'

   # ATRIBUTO CONTABIL
   let g_ffpgc309_op.atributo_contabil.corsus = m_bdbsa017.corsus

   if m_bdbsa017.nfsnum is null or   # se nao houver numero NFS, manda 'outros'
      m_bdbsa017.nfsnum <= 0
      then
      let g_ffpgc309_op.atributo_contabil.tp_docto_contabil = '03'
   else
      let g_ffpgc309_op.atributo_contabil.tp_docto_contabil = '01'
   end if

   let g_ffpgc309_op.atributo_contabil.tipo_nf     = m_bdbsa017.tipdoc
   let g_ffpgc309_op.atributo_contabil.nota_fiscal = m_bdbsa017.nfsnum
   let g_ffpgc309_op.atributo_contabil.serie_nf    = ''

   display "m_bdbsa017.socpgtdoctip  : ", m_bdbsa017.socpgtdoctip
   display "atributo_contabil.tipo_nf: ", g_ffpgc309_op.atributo_contabil.tipo_nf

   let g_ffpgc309_op.atributo_contabil.op_num    = m_bdbsa017.socopgnum
   let g_ffpgc309_op.atributo_contabil.op_ano    = year(m_bdbsa017.socfatpgtdat)

   let g_ffpgc309_op.atributo_contabil.sinnum    = 0     # Numero do Sinistro
   let g_ffpgc309_op.atributo_contabil.sinano    = 0     # Ano do Sinistro
   let g_ffpgc309_op.atributo_contabil.nro_pev   = 0     # Numero do PEV
   let g_ffpgc309_op.atributo_contabil.prporg    = 0     # Origem da Proposta
   let g_ffpgc309_op.atributo_contabil.prpnum    = 0     # Numero da Proposta
   let g_ffpgc309_op.atributo_contabil.aplnum    = 0     # Numero da Apolice
   let g_ffpgc309_op.atributo_contabil.edsnum    = 0     # Numero do Endosso
   let g_ffpgc309_op.atributo_contabil.placa     = null  # Placa do Veiculo

   let g_ffpgc309_op.atributo_contabil.dt_inicio = m_bdbsa017.datacontabil
   let g_ffpgc309_op.atributo_contabil.dt_fim    = m_bdbsa017.datacontabil

   # Matricula fixa, Orlando Sangali 5903
   let g_ffpgc309_op.atributo_contabil.matricula = "F01",m_bdbsa017.funmat using '&&&&&'
   
   display "Contabil.matricula: ",g_ffpgc309_op.atributo_contabil.matricula
   
   # OP -- Sucursal operacional
   # Flag de Identificacao para Pagamento Extra Caixa
   let g_ffpgc309_op.flag_extra_caixa = 'N'

   let g_ffpgc309_op.uf_prest_serv        = m_cty10g00_out.endufd  # UF do Prestador
   let g_ffpgc309_op.cidcod_prest_serv    = m_cty10g00_out.cidcod  # Cidade do Prestador
   let g_ffpgc309_op.suc_prestacao_serv   = m_bdbsa017.pstsuccod   # Sucursal do Prestador

   let g_ffpgc309_op.fornectip            = m_inftrb.tpfornec  # Tipo de Fornecedor
   let g_ffpgc309_op.consistir_vlr_minimo = 'N'                # Consistir Valor Minimo
   let g_ffpgc309_op.tp_docto_trib        = 'RPS'              # Tipo de Documento de Tributos

   # Origem do Sistema Legado em Tributos
   let g_ffpgc309_op.org_sist_legado_trib = 'R'
   let g_ffpgc309_op.operacao_interna = m_bdbsa017.oper_interna  # Divide as OPs em lote para aprovacao do gerente

   # DADOS DA LINHA DO VOUCHER - ARRAY DE 15
   let g_ffpgc309_voucher[01].descr_linha         = ''  # Descricao da Linha
   let g_ffpgc309_voucher[01].valor               = m_bdbsa017.socfattotvlr
   let g_ffpgc309_voucher[01].cod_retencao        = m_inftrb.retencod
   let g_ffpgc309_voucher[01].atividade_prestador = ''
   let g_ffpgc309_voucher[01].nro_parcela_adc     = 0

   # Dados da distribuicao da linha - array de 30
   #----------------------------------------------------------------
   # buscar conta contabil (ligada a OP)
   initialize m_ffpgc340_out.* to null

   if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
      then
      call ffpgc340_info_contabeis(m_bdbsa017.empcod, 11, m_bdbsa017.coddesp,
                                   '', '', '')
           returning m_ffpgc340_out.ctbctanum,
                     m_ffpgc340_out.empflg   ,
                     m_ffpgc340_out.sucflg   ,
                     m_ffpgc340_out.ramflg   ,
                     m_ffpgc340_out.mdlflg   ,
                     m_ffpgc340_out.lclflg   ,
                     m_ffpgc340_out.dptflg   ,
                     m_ffpgc340_out.errcod   ,
                     m_ffpgc340_out.errdes

      if m_ffpgc340_out.errcod != 0
         then
         let l_msg = " Erro na selecao da CCONTABIL: ",
                     m_ffpgc340_out.errdes clipped
         return m_ffpgc340_out.errcod, l_msg
      end if
   end if

   display "DADOS CONTABEIS EMISSOR DA OP: "
   display "m_ffpgc340_out.ctbctanum: ", m_ffpgc340_out.ctbctanum
   display "m_bdbsa017.coddesp      : ", m_bdbsa017.coddesp
   display "m_bdbsa017.oper_interna : ", m_bdbsa017.oper_interna
   display "m_bdbsa017.cctlclcod    : ", m_bdbsa017.cctlclcod
   display "m_bdbsa017.cctdptcod    : ", m_bdbsa017.cctdptcod

   display "BUSCA CCONTAB:"
   display 'm_ffpgc340_out.ctbctanum: ', m_ffpgc340_out.ctbctanum
   display 'm_ffpgc340_out.empflg   : ', m_ffpgc340_out.empflg
   display 'm_ffpgc340_out.sucflg   : ', m_ffpgc340_out.sucflg
   display 'm_ffpgc340_out.ramflg   : ', m_ffpgc340_out.ramflg
   display 'm_ffpgc340_out.mdlflg   : ', m_ffpgc340_out.mdlflg
   display 'm_ffpgc340_out.lclflg   : ', m_ffpgc340_out.lclflg
   display 'm_ffpgc340_out.dptflg   : ', m_ffpgc340_out.dptflg
   display 'm_ffpgc340_out.errcod   : ', m_ffpgc340_out.errcod
   display 'm_ffpgc340_out.errdes   : ', m_ffpgc340_out.errdes

   declare c_itens cursor for
      select sucursal, ramo, modalidade, sum(valor)
      from tmp_pagtos
      group by 1,2,3
      order by 1,2,3

   let l_arr = 1

   display "GRUPO SUCURSAL/RAMO/MODALIDADE"
   display 'su|ram|modal|dpt |class_contabil |valor'

   foreach c_itens into l_ratgrp.*

      #TODO: hardcode, parametrizar
      # forcar ramo 87 para a empresa 50 conforme definido pela contabilidade
      # em 21/07/2009
      if m_bdbsa017.empcod = 50 and
         (l_ratgrp.ramcod != 86 or l_ratgrp.ramcod != 87)
         then
         let l_ratgrp.ramcod = 87
         let l_ratgrp.modal  = 0
      end if

      let g_ffpgc309_voucher[01].distribuicao[l_arr].class_contabil = m_ffpgc340_out.ctbctanum
      let g_ffpgc309_voucher[01].distribuicao[l_arr].vlr_rateio = l_ratgrp.valor

      if m_ffpgc340_out.sucflg = "S" then
         let g_ffpgc309_voucher[01].distribuicao[l_arr].cod_suc_aprop = l_ratgrp.succod
      end if

      if m_ffpgc340_out.ramflg = "S" then
         let g_ffpgc309_voucher[01].distribuicao[l_arr].cod_ramo_aprop = l_ratgrp.ramcod
      end if

      if m_ffpgc340_out.mdlflg = "S" then
         let g_ffpgc309_voucher[01].distribuicao[l_arr].cod_modal_ramo = l_ratgrp.modal
      end if

      call ctb00g03_ccusto2(m_bdbsa017.empcod, l_ratgrp.ramcod,
                            l_ratgrp.modal)
           returning l_ctbcrtcod
      
            display "Buscar a carteira do pagamento"
            display "m_bdbsa017.empcod: ",m_bdbsa017.empcod
            display "l_ratgrp.ramcod  : ",l_ratgrp.ramcod
            display "l_ratgrp.modal   : ",l_ratgrp.modal
            display "l_ctbcrtcod      : ",l_ctbcrtcod
      
      if l_ctbcrtcod is null
         then
         let l_err = sqlca.sqlcode
         let l_msg = 'Erro na selecao da CARTEIRA(pagamento): ', l_err using "<<<<<<",
                     " Empresa: ",m_bdbsa017.empcod," Ramo: ",l_ratgrp.ramcod,
                     " Modalidade: ",l_ratgrp.modal
         return l_err, l_msg
      end if

      #if m_bdbsa017.empcod = 43 then # Caso a OP seja da empresa 43 a Carteira e fixa
      #   let l_ctbcrtcod = 5006
      #end if

      # Local, o mesmo da OP
      if m_ffpgc340_out.lclflg = "S" then
         let g_ffpgc309_voucher[01].distribuicao[l_arr].cctlclcod = m_bdbsa017.cctlclcod
      end if

      # Depto, o mesmo da OP
      if m_ffpgc340_out.dptflg = "S" then
         let g_ffpgc309_voucher[01].distribuicao[l_arr].cctdptcod = l_ctbcrtcod
      end if

      let m_dsp = g_ffpgc309_voucher[01].distribuicao[l_arr].cod_suc_aprop  using "##"   , '|',
                  g_ffpgc309_voucher[01].distribuicao[l_arr].cod_ramo_aprop using "###"  , '|',
                  g_ffpgc309_voucher[01].distribuicao[l_arr].cod_modal_ramo using "###&&", '|',
                  g_ffpgc309_voucher[01].distribuicao[l_arr].cctdptcod      using "####" , '|',
                  g_ffpgc309_voucher[01].distribuicao[l_arr].class_contabil              , '|',
                  g_ffpgc309_voucher[01].distribuicao[l_arr].vlr_rateio     using "######&&&.&&"

      display m_dsp clipped

      if l_arr > 30
         then
         let l_err = 999
         let l_msg = 'Array de distribuicao de itens estourou!'
         return l_err, l_msg
      end if

      let l_arr = l_arr + 1

   end foreach

   # Dados da parcela unica da OP
   let g_ffpgc309_parcelas[01].vlr_parc_adc     = m_bdbsa017.socfattotvlr
   let g_ffpgc309_parcelas[01].data_vcto        = m_bdbsa017.socfatpgtdat
   let g_ffpgc309_parcelas[01].modalidade_pagto = m_bdbsa017.modal_pgto
   let g_ffpgc309_parcelas[01].cod_bco_cred_fav = m_bdbsa017.bcocod
   let g_ffpgc309_parcelas[01].nro_agn_cred_fav = m_bdbsa017.bcoagnnum
   let g_ffpgc309_parcelas[01].dig_agn_cred_fav = m_bdbsa017.bcoagndig
   let g_ffpgc309_parcelas[01].nro_cta_fav      = m_bdbsa017.bcoctanum
   let g_ffpgc309_parcelas[01].dig_cta_fav      = m_bdbsa017.bcoctadig
   let g_ffpgc309_parcelas[01].ident_parc_adc   = 'N'  # se mandar sem desconto

   # mandar desconto da OP como adicional com valor negativo, parametros fixos
   # conforme indicado pela contabilidade (sempre mesma carteira/conta contabil)
   if m_bdbsa017.socopgdscvlr is not null and
      m_bdbsa017.socopgdscvlr > 0.00
      then
      initialize m_ffpgc340_out.* to null

      if m_bdbsa017.empcod != 35 and m_bdbsa017.empcod != 84
         then
         call ffpgc340_info_contabeis(m_bdbsa017.empcod , 11,
                                      m_bdbsa017.coddesp,
                                      '54',  # tipo vlr de pagamento (financeiro)
                                      '', '')
              returning m_ffpgc340_out.ctbctanum,
                        m_ffpgc340_out.empflg   ,
                        m_ffpgc340_out.sucflg   ,
                        m_ffpgc340_out.ramflg   ,
                        m_ffpgc340_out.mdlflg   ,
                        m_ffpgc340_out.lclflg   ,
                        m_ffpgc340_out.dptflg   ,
                        m_ffpgc340_out.errcod   ,
                        m_ffpgc340_out.errdes

         if m_ffpgc340_out.errcod != 0
            then
            let l_msg = " Erro na selecao da CCONTABIL(desconto): ",
                        m_ffpgc340_out.errdes clipped,
                        " Empresa: ",m_bdbsa017.empcod, " Codigo Despesa: ",m_bdbsa017.coddesp
            return m_ffpgc340_out.errcod, l_msg
         end if
      end if

      display "BUSCA CCONTAB DESCONTO:"
      display 'm_ffpgc340_out.ctbctanum: ', m_ffpgc340_out.ctbctanum
      display 'm_ffpgc340_out.empflg   : ', m_ffpgc340_out.empflg
      display 'm_ffpgc340_out.sucflg   : ', m_ffpgc340_out.sucflg
      display 'm_ffpgc340_out.ramflg   : ', m_ffpgc340_out.ramflg
      display 'm_ffpgc340_out.mdlflg   : ', m_ffpgc340_out.mdlflg
      display 'm_ffpgc340_out.lclflg   : ', m_ffpgc340_out.lclflg
      display 'm_ffpgc340_out.dptflg   : ', m_ffpgc340_out.dptflg
      display 'm_ffpgc340_out.errcod   : ', m_ffpgc340_out.errcod
      display 'm_ffpgc340_out.errdes   : ', m_ffpgc340_out.errdes
      display "l_ratgrp.succod: ",l_ratgrp.succod
      display "l_ratgrp.ramcod: ",l_ratgrp.ramcod
      display "l_ratgrp.modal : ",l_ratgrp.modal
      display "m_bdbsa017.cctlclcod: ",m_bdbsa017.cctlclcod
      display "l_ctbcrtcod: ",l_ctbcrtcod
      let g_ffpgc309_parcelas[01].ident_parc_adc = 'Y' # se mandar com desconto
      let g_ffpgc309_parcelas[01].adicional[01].valor_adc = m_bdbsa017.socopgdscvlr * (-1)
      let g_ffpgc309_parcelas[01].adicional[01].class_contabil     = m_ffpgc340_out.ctbctanum
      let g_ffpgc309_parcelas[01].adicional[01].class_contabil_adc = m_ffpgc340_out.ctbctanum
      let g_ffpgc309_parcelas[01].adicional[01].nro_linha          = 1
      let g_ffpgc309_parcelas[01].adicional[01].nro_distribuicao   = 1

      let g_ffpgc309_parcelas[01].adicional[01].cod_suc_aprop = l_ratgrp.succod


      let g_ffpgc309_parcelas[01].adicional[01].cod_ramo_aprop = l_ratgrp.ramcod

      let g_ffpgc309_parcelas[01].adicional[01].cod_modal_ramo = l_ratgrp.modal

      let g_ffpgc309_parcelas[01].adicional[01].cctlclcod = m_bdbsa017.cctlclcod


      # definir local e departamento/carteira conforme soctip e ramo da OP RE
      initialize l_ctbcrtcod to null

      call ctb00g03_ccusto2(m_bdbsa017.empcod,
                            l_ratgrp.ramcod,
                            l_ratgrp.modal)
                  returning l_ctbcrtcod
      
      if l_ctbcrtcod is null
         then
         let l_err = sqlca.sqlcode
         let l_msg = 'Erro na selecao da CARTEIRA(desconto): ', l_err using "<<<<<<",
                     " Empresa: ",m_bdbsa017.empcod,
                     " Ramo: ",g_ffpgc309_parcelas[01].adicional[01].cod_ramo_aprop,
                     " Modalidade: ",g_ffpgc309_parcelas[01].adicional[01].cod_modal_ramo
         return l_err, l_msg
      end if

      if m_ffpgc340_out.dptflg = "S" then
         let g_ffpgc309_parcelas[01].adicional[01].cctdptcod = l_ctbcrtcod
      end if

      display 'DADOS DO DESCONTO:'
      display 'adicional[01].valor_adc         :', g_ffpgc309_parcelas[01].adicional[01].valor_adc
      display 'adicional[01].class_contabil    :', g_ffpgc309_parcelas[01].adicional[01].class_contabil
      display 'adicional[01].class_contabil_adc:', g_ffpgc309_parcelas[01].adicional[01].class_contabil_adc
      display 'adicional[01].nro_linha         :', g_ffpgc309_parcelas[01].adicional[01].nro_linha
      display 'adicional[01].nro_distribuicao  :', g_ffpgc309_parcelas[01].adicional[01].nro_distribuicao
      display 'adicional[01].cod_suc_aprop     :', g_ffpgc309_parcelas[01].adicional[01].cod_suc_aprop
      display 'adicional[01].cod_ramo_aprop    :', g_ffpgc309_parcelas[01].adicional[01].cod_ramo_aprop
      display 'adicional[01].cod_modal_ramo    :', g_ffpgc309_parcelas[01].adicional[01].cod_modal_ramo
      display 'adicional[01].cctlclcod         :', g_ffpgc309_parcelas[01].adicional[01].cctlclcod
      display 'adicional[01].cctdptcod         :', g_ffpgc309_parcelas[01].adicional[01].cctdptcod

   end if

   # DADOS DO FORNECEDOR
   if m_bdbsa017.nomgrr is null then
      let m_bdbsa017.nomgrr = m_bdbsa017.nomrazsoc
   end if
   let g_ffpgc309_fornec.cod_fornec      = m_bdbsa017.cod_fornec
   let g_ffpgc309_fornec.nome_curto      = m_bdbsa017.nomgrr     # Nome Curto
   let g_ffpgc309_fornec.razao_social    = m_bdbsa017.nomrazsoc  # Razao Social
   let g_ffpgc309_fornec.emp_matr_resp   = 1
   let g_ffpgc309_fornec.matricula       = m_bdbsa017.funmat
   let g_ffpgc309_fornec.usrtip          = "F"

   let g_ffpgc309_fornec.flag_trib       = m_inftrb.socitmtrbflg
   let g_ffpgc309_fornec.pestip          = m_bdbsa017.pestip
   let g_ffpgc309_fornec.nro_dependentes = null
   let g_ffpgc309_fornec.nascdt          = null

   if m_bdbsa017.pisnum is not null then
      let g_ffpgc309_fornec.tp_docto_pis  = "PIS"              # Tipo Documento PIS
      let g_ffpgc309_fornec.nro_docto_pis = m_bdbsa017.pisnum  # Nr Doc PIS
   end if

   if m_bdbsa017.nitnum is not null then
      let g_ffpgc309_fornec.tp_docto_nit  = "NIT"              # Tipo Documento NIT
      let g_ffpgc309_fornec.nro_docto_nit = m_bdbsa017.nitnum  # Nr Documento NIT
   end if

   let g_ffpgc309_fornec.cgccpfnum       = m_bdbsa017.cgccpfnum  # Nr CPF/CNPJ
   let g_ffpgc309_fornec.cgcord          = m_bdbsa017.cgcord     # Ordem do CNPJ
   let g_ffpgc309_fornec.cgccpfdig       = m_bdbsa017.cgccpfdig  # Digito CPF/CNPJ
   let g_ffpgc309_fornec.fornectip       = m_inftrb.tpfornec
   let g_ffpgc309_fornec.inscr_estadual  = null
   let g_ffpgc309_fornec.inscr_municipal = m_bdbsa017.muninsnum
   let g_ffpgc309_fornec.cod_br_ocupacao = ''

   let g_ffpgc309_fornec.email           = m_bdbsa017.maides    # Email
   let g_ffpgc309_fornec.endereco        = m_bdbsa017.endlgd    # Endereco
   let g_ffpgc309_fornec.end_compl       = m_bdbsa017.lgdcmp    # Complemento Endereco
   let g_ffpgc309_fornec.cidade          = m_bdbsa017.endcid    # Cidade
   let g_ffpgc309_fornec.numero          = m_bdbsa017.lgdnum    # Numero
   let g_ffpgc309_fornec.bairro          = m_bdbsa017.endbrr    # Bairro
   let g_ffpgc309_fornec.uf              = m_bdbsa017.ufdsgl    # UF
   let g_ffpgc309_fornec.cep             = m_bdbsa017.endcep    # CEP
   let g_ffpgc309_fornec.cep_compl       = m_bdbsa017.endcepcmp # Complemento do CEP
   let g_ffpgc309_fornec.cidcod          = m_bdbsa017.mpacidcod # Codigo Cidade

   if m_bdbsa017.mpacidcod is null or
      m_bdbsa017.mpacidcod <= 0
      then
      let g_ffpgc309_fornec.cidcod = m_cty10g00_out.cidcod
   end if

   # Dados bancarios array de 10
   let g_ffpgc309_banco[01].contades    = null                 # Descricao Conta
   let g_ffpgc309_banco[01].banco       = m_bdbsa017.bcocod    # Codigo do Banco
   let g_ffpgc309_banco[01].agencia     = m_bdbsa017.bcoagnnum # Codigo da Agencia
   let g_ffpgc309_banco[01].cnttip      = "03"                 # Tipo de Conta
   let g_ffpgc309_banco[01].cntnum      = m_bdbsa017.bcoctanum # Numero da Conta
   let g_ffpgc309_banco[01].cntdig      = m_bdbsa017.bcoctadig # Digito da Conta
   let g_ffpgc309_banco[01].agenciadig  = m_bdbsa017.bcoagndig # Digito da Agencia

   let g_ffpgc309_trib[01].cod_retencao = m_inftrb.retencod

   #--> ini PSI-11-19199PR Optante Simples Prestador  25.05.12 Ze
   if m_bdbsa017.soctip = 2 then
      if m_bdbsa017.infissalqvlr is not null and
         m_bdbsa017.infissalqvlr  > 0.0      then
         let gr_tributacao_pps.flgoptsimples = "Y"
         let gr_tributacao_pps.perciss       = m_bdbsa017.infissalqvlr
      end if
   else
      if m_bdbsa017.pestip = 'J' and
         m_bdbsa017.favtip = 1   then     # Prestador

         call bdbsa017_checarEmpSimples( m_bdbsa017.empcod )
              returning l_res, l_msg

         if l_res then
            if m_bdbsa017.simoptpstflg <> "S" then
               let gr_tributacao_pps.flgoptsimples = "N"
               let gr_tributacao_pps.perciss       = null
            else
               let gr_tributacao_pps.flgoptsimples = "Y"
               let gr_tributacao_pps.perciss       = m_bdbsa017.infissalqvlr
            end if
         end if
      end if
   end if

   #--> fim PSI-11-19199PR Optante Simples Prestador

   return l_err, l_msg

end function


###---------------------------------------------------------------
##function bdbsa017_apolice(l_atdsrvnum, l_atdsrvano)
###---------------------------------------------------------------
##
##   define l_atdsrvnum        like datmservico.atdsrvnum  ,
##          l_atdsrvano        like datmservico.atdsrvano  ,
##          l_retorno          smallint                    ,
##          l_mensagem         char(70)                    ,
##          l_succod           like datrservapol.succod    ,
##          l_ramcod           like datrservapol.ramcod    ,
##          l_modalidade       like rsamseguro.rmemdlcod   ,
##          l_aplnumdig        like datrservapol.aplnumdig ,
##          l_itmnumdig        like datrservapol.itmnumdig ,
##          l_crtnum           like datrsrvsau.crtnum      ,
##          l_corsus           like abamcor.corsus         ,
##          l_atdsrvorg        like datmservico.atdsrvorg  ,
##          l_tpdocto          char(15)                    ,
##          l_cornom           like datksegsau.cornom      ,
##          l_status           integer                     ,
##          l_ramcod2          like datrservapol.ramcod    ,
##          l_edsnumref        like datrservapol.edsnumref
##
##   define lr_cty05g00     record
##          resultado       smallint
##         ,mensagem        char(42)
##         ,emsdat          like abamdoc.emsdat
##         ,aplstt          like abamapol.aplstt
##         ,vigfnl          like abamapol.vigfnl
##         ,etpnumdig       like abamapol.etpnumdig
##   end record
##
##   let   l_modalidade  =  null
##
##   initialize lr_cty05g00.* to null
##
##   let l_retorno    = null
##   let l_mensagem   = null
##   let l_succod     = null
##   let l_ramcod     = null
##   let l_modalidade = 0
##   let l_aplnumdig  = null
##   let l_itmnumdig  = null
##   let l_crtnum     = null
##   let l_corsus     = null
##   let l_atdsrvorg  = null
##   let l_tpdocto    = null
##   let l_cornom     = null
##   let l_status     = null
##   let l_ramcod2    = null
##   let l_edsnumref  = 0
##
##   # verifica tipo de documento utilizado no servico
##   call cts20g11_identifica_tpdocto(l_atdsrvnum, l_atdsrvano)
##        returning l_tpdocto
##
##   display 'TPDOCTO: ', l_tpdocto clipped
##
##   # busca dados de apolice conforme o ramo
##   if l_tpdocto = "SAUDE"
##      then
##      display "Buscou SAUDE"
##      call cts20g10_cartao(2,
##                           l_atdsrvnum,
##                           l_atdsrvano)
##                 returning l_retorno,
##                           l_mensagem,
##                           l_succod,
##                           l_ramcod ,
##                           l_aplnumdig,
##                           l_crtnum
##
##      if l_retorno = 1 then
##         # Obter corsus da tabela do saúde
##         call cta01m15_sel_datksegsau(2, l_crtnum, "", "", "" )
##              returning l_retorno,
##                        l_mensagem,
##                        l_corsus,
##                        l_cornom
##      end if
##   else
##      display "Buscou APL SERV"
##      call ctd07g02_busca_apolice_servico(1, l_atdsrvnum, l_atdsrvano)
##           returning l_retorno,   l_mensagem,
##                     l_succod,    l_ramcod ,
##                     l_aplnumdig, l_itmnumdig,l_edsnumref
##
##      display 'ctd07g02_busca_apolice_servico:'
##      display 'l_retorno  : ', l_retorno
##      display 'l_mensagem : ', l_mensagem clipped
##      display 'l_succod   : ', l_succod
##      display 'l_aplnumdig: ', l_aplnumdig
##      display 'l_itmnumdig: ', l_itmnumdig
##      display 'l_edsnumref: ',l_edsnumref
##
##      if l_retorno = 1        and   # achou em datrservapol valor valido
##         l_ramcod is not null and
##         l_ramcod > 0
##         then
##         if l_ramcod = 53 or
##            l_ramcod = 531 then
##            display "Buscou ABAMCOR"
##            call cty05g00_abamcor(1,l_succod, l_aplnumdig)
##                 returning l_retorno, l_mensagem, l_corsus
##
##            # MODALIDADE INCLUIDA PELA FUNCAO DA EMISSAO PSI 249050,
##            # buscar modalidade da apolice Isar
##            call faemc070(l_succod,
##                          l_aplnumdig,
##                          "","")
##                returning l_ramcod2,
##                          l_modalidade,
##                          l_status
##
##            display 'FAEMC070:'
##            display "l_modalidade = ", l_modalidade
##            display "l_status     = ", l_status
##
##         else
##            display "Buscou RE"
##            call cty06g00_modal_re(1, l_succod, l_ramcod, l_aplnumdig)
##                 returning l_retorno, l_mensagem, l_modalidade
##         end if
##
##      else  # servico sem apolice, precisa forcar suc/ram/mod para enviar a distribuicao
##            # #TODO: hardcode adicionado, planejar parametrizacao
##
##         let l_succod    = 1
##         let l_aplnumdig = 0
##
##         case m_bdbsa017.empcod
##
##            when 14   # definido pela contabilidade
##               let l_ramcod = 991
##               let l_modalidade = 0
##
##            when 27   # definido pela controladoria
##               let l_ramcod = 10
##               let l_modalidade = 1
##
##            when 43   # definido pela controladoria
##               let l_ramcod = 10
##               let l_modalidade = 1
##
##            when 50   # definido pela contabilidade 21/07/2009
##               let l_ramcod = 87
##               let l_modalidade = 0
##
##            otherwise
##               if m_bdbsa017.soctip = 3
##                  then
##                  let l_ramcod = 114
##                  let l_modalidade = 1
##               else
##                  let l_ramcod = 531
##                  let l_modalidade = 0
##               end if
##         end case
##      end if
##   end if
##
##   if l_ramcod =  31 or l_ramcod = 531 or
##      l_ramcod =  53 or l_ramcod = 553 then
##      display "Buscou CTY05G00"
##      call cty05g00_dados_apolice(l_succod, l_aplnumdig)
##           returning lr_cty05g00.*
##   end if
##
##   return l_succod, l_ramcod, l_modalidade, l_aplnumdig, l_itmnumdig,
##          l_corsus, lr_cty05g00.emsdat
##
##end function
##

#----------------------------------------------------------------
function inicializa_globais_SAP()
#----------------------------------------------------------------

  #Inicializa as Variaveis Globais
  initialize     gr_038_cab_v1.*      
                ,gr_038_dad_trib_v1.* 
                ,gr_038_cta_crt_v1.*  
                ,gr_038_obj_seg_v1.*  
                ,gr_038_chv_pcr_v1.*  
                ,gr_038_dad_pcr_v1.*  
                ,gr_038_dad_pgt_v1.*  
                ,gr_038_end_pcr_v1.*  
                ,gr_038_dad_nf_v1.*
                ,ga_038_subest_mt_v1
                ,ga_038_srv_v1
                ,ga_038_cad_mat_v1
                ,gr_038_chv_ben_v1.*  
                ,gr_038_dad_ben_v1.*  
                ,gr_038_end_ben_v1.*  
                ,gr_038_response_v1.*
                ,gr_aci_req_head.* to null 

end function

#----------------------------------------------------------------
function inicializa_m_bdbsa017()
#----------------------------------------------------------------

   initialize m_bdbsa017.funmat      ,
              m_bdbsa017.atdsrvnum   ,
              m_bdbsa017.atdsrvano   ,
              m_bdbsa017.pestip      ,
              m_bdbsa017.cgccpfnum   ,
              m_bdbsa017.cgcord      ,
              m_bdbsa017.cgccpfdig   ,
              m_bdbsa017.socopgfavnom,
              m_bdbsa017.bcocod      ,
              m_bdbsa017.bcoagndig   ,
              m_bdbsa017.bcoagnnum   ,
              m_bdbsa017.bcoctanum   ,
              m_bdbsa017.bcoctadig   ,
              m_bdbsa017.socpgtopccod,
              m_bdbsa017.socopgitmcst,
              m_bdbsa017.socitmdspcod,
              m_bdbsa017.nomrazsoc   ,
              m_bdbsa017.nomgrr      ,
              m_bdbsa017.ufdsgl      ,
              m_bdbsa017.endcid      ,
              m_bdbsa017.endlgd      ,
              m_bdbsa017.lgdcmp      ,
              m_bdbsa017.endcep      ,
              m_bdbsa017.endcepcmp   ,
              m_bdbsa017.endbrr      ,
              m_bdbsa017.maides      ,
              m_bdbsa017.lgdtip      ,
              m_bdbsa017.lgdnum      ,
              m_bdbsa017.mpacidcod   ,
              m_bdbsa017.dddcod      ,
              m_bdbsa017.teltxt      ,
              m_bdbsa017.prscootipcod,
              m_bdbsa017.vlr_rateio  ,
              m_bdbsa017.muninsnum   ,
              m_bdbsa017.pisnum      ,
              m_bdbsa017.nitnum      ,
              m_bdbsa017.modal_pgto  ,
              m_bdbsa017.oper_interna,
              m_bdbsa017.datacontabil,
              m_bdbsa017.cod_fornec  ,
              m_bdbsa017.pstsuccod   ,
              m_bdbsa017.favtip        to null

end function


#----------------------------------------------------------------
function bdbsa017_data(l_data)
#----------------------------------------------------------------

   define l_data date,
          l_return char(08)

   let l_return = null
   let l_return = " "

   if l_data is not null and l_data <> " "
      then
      let l_return = extend(l_data, year to year) clipped,
                     extend(l_data, month to month) clipped,
                     extend(l_data, day to day)
   end if

   return l_return

end function

#----------------------------------------------------------------
function bdbsa017_valor(l_param)
#----------------------------------------------------------------

   define l_param  decimal(15,5),
          l_valor  char(018),
          l_return char(018),
          l_ind    smallint

   let   l_valor  = null
   let   l_return = null
   let   l_ind    = null

   let l_valor = l_param using "<<<<<<<<<<<<<<&.&&"
   let l_return = " "

   for l_ind = 1 to length(l_valor)
       if l_valor[l_ind] <> ',' and
          l_valor[l_ind] <> '.'
          then
          let l_return = l_return clipped, l_valor[l_ind]
       end if
   end for

   let l_return = l_return using "&&&&&&&&&&&&&&&&&&"

   return l_return

end function

#----------------------------------------------------------------
function bdbsa017_pontuacao(l_valor)
#----------------------------------------------------------------

   define l_valor  char(018),
          l_return char(011),
          l_ind    smallint

   let   l_return  =  null
   let   l_ind  =  null

   let l_return = " "

   for l_ind = 1 to length(l_valor)
       if l_valor[l_ind] <> '.' and
          l_valor[l_ind] <> ',' and
          l_valor[l_ind] <> '-'
          then
          let l_return = l_return clipped, l_valor[l_ind]
       end if
   end for

   let l_return = l_return using "&&&&&&&&&&&"

   return l_return

end function

#----------------------------------------------------------------
# Objetivo: popular lista de empresas x optante simples
#----------------------------------------------------------------
function bdbsa017_checarEmpSimples( lr_par_in )

   define lr_par_in     record
          empcod        like dbsmopg.empcod
   end record

   define l_codres            smallint,
          l_msgerr            char(100),
          l_idx               smallint,
          l_okk               smallint,
          l_empstt            smallint,
          l_cpodes            like iddkdominio.cpodes,
          l_cponom            like iddkdominio.cponom

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   let l_codres = null
   let l_msgerr = null
   let l_idx    = null
   let l_okk    = null
   let l_empstt = null
   let l_cpodes = null
   let l_cponom = null

   let l_empstt = false
   let l_okk    = false

   for l_idx = 1 to m_empptcqtd
      if ma_empptc[l_idx].empcod = lr_par_in.empcod then
         if ma_empptc[l_idx].optflg = "S" then
            let l_empstt = true
         end if
         let l_okk = true
      end if
   end for

   #--> Verificar se Empresa OP pode optar Simples
   #
   if not l_okk then
      let l_cponom = "empsolopcissptl"
      call ctc00m24_obterDescIddkDominio( l_cponom
                                        , lr_par_in.empcod )
           returning l_codres, l_msgerr, l_cpodes

      if l_codres = 0 then
         let l_empstt    = true
         let m_empptcqtd = m_empptcqtd + 1
         let ma_empptc[m_empptcqtd].empcod = lr_par_in.empcod
         let ma_empptc[m_empptcqtd].optflg = "S"
      else
         if l_codres = 2 then
            let m_empptcqtd = m_empptcqtd + 1
            let ma_empptc[m_empptcqtd].empcod = lr_par_in.empcod
            let ma_empptc[m_empptcqtd].optflg = "N"
         end if
      end if
   end if

   return l_empstt, l_msgerr

end function  #--> bdbsa017_checarEmpSimples()


#----------------------------------------------------------------
report bdbsr017_relat(lr_parametro)
#----------------------------------------------------------------

  define lr_parametro       record                                          
         evento             like dbskctbevnpam.srvpovevncod,                                                
         empcod             like dbskctbevnpam.empcod      ,                                       
         succod             like datrservapol.succod       ,                                    
         ctbramcod          like rsatdifctbramcvs.ctbramcod,    
         ctbmdlcod          like rsatdifctbramcvs.ctbmdlcod,    
         aplnumdig          like datrservapol.aplnumdig    ,                                            
         itmnumdig          like datrservapol.itmnumdig    ,    
         edsnumref          like datrservapol.edsnumref    ,    
         prporg             like datrligprp.prporg         ,    
         prpnumdig          like datrligprp.prpnumdig      ,  
         corsus             like abamcor.corsus            ,
         srvvlr             like dbsmatdpovhst.srvvlr      ,    
         atdsrvnum          like dbsmopgitm.atdsrvnum      ,                                    
         atdsrvano          like dbsmopgitm.atdsrvano      ,                                    
         socopgnum          like dbsmopg.socopgnum         ,                                    
         srvatdctecod       like dbskctbevnpam.srvatdctecod,     
         socfatpgtdat       like dbsmopg.socfatpgtdat      ,
         msgerr             char(1000)    
  end record                                                    
                                                                
  output                                                        
    page length    99                                           
    left margin    00                                           
    right margin   00                                           
    top margin     00                                           
    bottom margin  00                                           
                                                                           
  format                                                                   
                                                                           
     first page header                                                     
                                                                           
       print "EMPRESA             ", ASCII(9),            
             "RAMO                ", ASCII(9),            
             "MODALIDADE          ", ASCII(9),            
             "CARTEIRA            ", ASCII(9),            
             "DATA MOVIMENTO      ", ASCII(9),            
             "EVENTO              ", ASCII(9),            
             "NÚMERO DA OP        ", ASCII(9),            
             "NUMERO DO SERVICO   ", ASCII(9),            
             "ANO DO SERVICO      ", ASCII(9),            
             "SUCURSAL            ", ASCII(9),            
             "APOLICE             ", ASCII(9),
             "ITEM                ", ASCII(9),
             "ENDOSSO             ", ASCII(9),
             "SUSEP               ", ASCII(9),            
             "PROPOSTA            ", ASCII(9),            
             "VALOR               ", ASCII(9),
             "ERRO                ", ASCII(9)            
               
             
  on every row    
       
       print lr_parametro.empcod           , ASCII(9);                                        
       print lr_parametro.ctbramcod        , ASCII(9);                                        
       print lr_parametro.ctbmdlcod        , ASCII(9);                                        
       print lr_parametro.srvatdctecod     , ASCII(9);                                        
       print lr_parametro.socfatpgtdat     , ASCII(9);                                        
       print lr_parametro.evento           , ASCII(9);                                        
       print lr_parametro.socopgnum        , ASCII(9);                                        
       print lr_parametro.atdsrvnum        , ASCII(9);                                        
       print lr_parametro.atdsrvano        , ASCII(9);                                        
       print lr_parametro.succod           , ASCII(9);                                        
       print lr_parametro.aplnumdig        , ASCII(9);
       print lr_parametro.itmnumdig        , ASCII(9);
       print lr_parametro.edsnumref        , ASCII(9);
       print lr_parametro.corsus           , ASCII(9);       
       print lr_parametro.prporg,"/",lr_parametro.prpnumdig  , ASCII(9); 
       print lr_parametro.srvvlr           , ASCII(9);
       print lr_parametro.msgerr clipped   , ASCII(9)
       
      
end report


#--------------------------------------------------------------------------
report bdbsa017_resumo(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(120)

  output
     left margin     0
     bottom margin   0
     top margin      0
     right margin  125
     page length    60

  format
     on every row
        print column 1, l_linha clipped

end report


#----------------------------------------------------------------
report bdbsr017_hml()
#----------------------------------------------------------------

  output
     left margin    00
     top margin     00

  format

     first page header

        print column 01, 'EMPRESA;',
                         'SUCURSAL;',
                         'OP_INFORMIX;',
                         'OP_PEOPLE;',
                         'ANO;',
                         'VLR_BRUTO;',
                         'DOCTIP;',
                         'TIPDOC;',
                         'DT_INICIO;',
                         'DT_FIM;',
                         'ENDUFD;',
                         'CIDCOD;',
                         'OPER_INTERNA;',
                         'VLR_TOTAL;',
                         'COD_RETENCAO;',
                         'CONTACONTABIL;',
                         'VLR_RATEIO;',
                         'SUCURSAL;',
                         'RAMO;',
                         'MODAL;',
                         'COD_LOCAL;',
                         'COD_DEPTO;',
                         'PARC_VLR_TOTAL;',
                         'PARC_DT_VCTO;',
                         'PARC_MOD_PAGTO;',
                         'NOME;',
                         'RAZAO;',
                         'ATIVIDADE;',
                         'COD_FORNEC;',
                         'COD_RETENCAO;',
                         'FLAG_TRIB;',
                         'PESSOA;',
                         'PIS;',
                         'NIT;',
                         'CNPJ;',
                         'CGCORD;',
                         'CGCDIG;',
                         'FORN_TIPO;',
                         'INSCR_MUN;',
                         'ENDERECO;',
                         'CIDADE;',
                         'BAIRRO;',
                         'UF;',
                         'CEP;',
                         'COD_CIDADE;',
                         'BCOCOD;',
                         'AGENCIA;',
                         'AGNDIG;',
                         'CONTA;',
                         'CONTADIG;'


     on every row

        print column 01,

              g_ffpgc309_op.empcod                             ,';',  # EMPRESA
              g_ffpgc309_op.suc_prestacao_serv                 ,';',  # SUCURSAL
              g_ffpgc309_op.atributo_contabil.op_num           ,';',  # OPGNUM
              ''                                               ,';',  # OP PEOPLE
              g_ffpgc309_op.atributo_contabil.op_ano           ,';',  # ANO
              g_ffpgc309_op.vlr_bruto                          ,';',  # VLR_BRUTO
              g_ffpgc309_op.atributo_contabil.tp_docto_contabil,';',  # DOCTIP
              g_ffpgc309_op.atributo_contabil.tipo_nf          ,';',  # TIPDOC
              g_ffpgc309_op.atributo_contabil.dt_inicio        ,';',  # DT_INICIO
              g_ffpgc309_op.atributo_contabil.dt_fim           ,';',  # DT_FIM
              g_ffpgc309_op.uf_prest_serv                      ,';',  # ENDUFD
              g_ffpgc309_op.cidcod_prest_serv                  ,';',  # CIDCOD
              g_ffpgc309_op.operacao_interna                   ,';',  # OPER_INTERNA
              g_ffpgc309_voucher[01].valor                          ,';',  # VLR_TOTAL
              g_ffpgc309_voucher[01].cod_retencao                   ,';',  # COD_RETENCAO
              g_ffpgc309_voucher[01].distribuicao[1].class_contabil ,';',  # CONTACONTABIL
              g_ffpgc309_voucher[01].distribuicao[1].vlr_rateio     ,';',  # VLR_RATEIO
              g_ffpgc309_voucher[01].distribuicao[1].cod_suc_aprop  ,';',  # SUCURSAL
              g_ffpgc309_voucher[01].distribuicao[1].cod_ramo_aprop ,';',  # RAMO
              g_ffpgc309_voucher[01].distribuicao[1].cod_modal_ramo ,';',  # MODAL
              g_ffpgc309_voucher[01].distribuicao[1].cctlclcod      ,';',  # COD_LOCAL
              g_ffpgc309_voucher[01].distribuicao[1].cctdptcod      ,';',  # COD_DEPTO
              g_ffpgc309_parcelas[01].vlr_parc_adc      ,';',  # PARC_VLR_TOTAL
              g_ffpgc309_parcelas[01].data_vcto         ,';',  # PARC_DT_VCTO
              g_ffpgc309_parcelas[01].modalidade_pagto  ,';',  # PARC_MOD_PAGTO
              g_ffpgc309_fornec.nome_curto     ,';',  # NOME
              g_ffpgc309_fornec.razao_social   ,';',  # RAZAO
              m_inftrb.retendes                ,';',  # DESC_ATIV
              g_ffpgc309_fornec.cod_fornec     ,';',  # COD_FORNEC
              g_ffpgc309_trib[01].cod_retencao ,';',   # COD_RETENCAO
              g_ffpgc309_fornec.flag_trib      ,';',  # FLAG_TRIB
              g_ffpgc309_fornec.pestip         ,';',  # PESSOA
              g_ffpgc309_fornec.nro_docto_pis  ,';',  # PIS
              g_ffpgc309_fornec.nro_docto_nit  ,';',  # NIT
              g_ffpgc309_fornec.cgccpfnum      ,';',  # CNPJ
              g_ffpgc309_fornec.cgcord         ,';',
              g_ffpgc309_fornec.cgccpfdig      ,';',
              g_ffpgc309_fornec.fornectip      ,';',  # FORN_TIPO
              g_ffpgc309_fornec.inscr_municipal,';',  # INSCR_MUN
              g_ffpgc309_fornec.end_compl      ,';',  # ENDERECO
              g_ffpgc309_fornec.cidade         ,';',  # CIDADE
              g_ffpgc309_fornec.bairro         ,';',  # BAIRRO
              g_ffpgc309_fornec.uf             ,';',  # UF
              g_ffpgc309_fornec.cep,'-', g_ffpgc309_fornec.cep_compl,';',  # CEP
              g_ffpgc309_fornec.cidcod         ,';',  # COD_CIDADE
              g_ffpgc309_banco[01].banco       ,';',  # BCOCOD
              g_ffpgc309_banco[01].agencia     ,';',
              g_ffpgc309_banco[01].agenciadig  ,';',  # AGENCIA
              g_ffpgc309_banco[01].cntnum      ,';',
              g_ffpgc309_banco[01].cntdig      ,';'   # CONTA

end report



#Fornax-Quantum Inicio
#--------------------------------------------------------------------------#
function bdbsa017_carga_op_sap() 
#--------------------------------------------------------------------------#

   define lr_desc_nf       char(01)
   define lr_vlr_ant       decimal (13,2)
   define lr_num_op_desc   decimal (10,0)
   define lr_in_trib_ant   char(1)
   define lr_cod_org_ant   char(4)
   define lr_erro          integer
   define lr_msgerr        char(200)
   define l_cont integer 
   define l_dsctipcod      like dbsropgdsc.dsctipcod
   define l_dscvlr         like dbsropgdsc.dscvlr
   define l_coddesp        integer
   define l_ccusto         char(08)

   #--------------------------------------------------------#
   #VERIFICA SE A OP EH DE REEEMBOLSO - NAO TRIBUTAVEL      #
   #--------------------------------------------------------#
   if gr_038_cab_v1.ind_tributavel = "N" then 
    
      #--------------------------------------------------------#
      #GRAVA NO LOG AS INFORMACOES QUE FORAM ENVIADAS AO SAP   #
      #--------------------------------------------------------# 
      display "OP Nao Tributada"   
      call log_sap(m_arr_sap)        
      
      
      #--------------------------------------------------------# 
      #CHAMA O SAP COM A INTEGRACAO DE OP NAO TRIBUTAVEL       # 
      #--------------------------------------------------------# 
      let gr_aci_req_head.id_integracao   = "038PTSOCNTRIB"  
      
      
      
      let m_tempo_chamada = current
      display "TEmpoCNT1:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
      
      call ffpgc374_gerarop_naotrib_lote()
      
      whenever error continue
      display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
             ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
      whenever error stop 
      
      let m_tempo_retorno  = current
      display "TEmpoRNT1:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
      
      display "codigo_retorno OP NAO TRIBUTAVEL: ",gr_aci_res_head.codigo_retorno
      
      if gr_aci_res_head.codigo_retorno = -1 then
      
         call MQ4GL_Init() returning lr_erro, lr_msgerr
         
          let m_tempo_chamada = current
          display "TEmpoCNT1:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
                  gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
          
          sleep 10 # Rodolfo Massini - PGP P14070117 - inserir intervalo entre chamada SAP para evitar PI-Remote
          call ffpgc374_gerarop_naotrib_lote()
          
          whenever error continue
          display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
                 ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
          whenever error stop 
          
          let m_tempo_retorno  = current
          display "TEmpoRNT1:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
         
      end if 
      #------------------------------------------------------# 
      #    VERIFICA SE HOUVE ALGUM ERRO NO ENVIO DA OP       #
      #    O RETORNO DA GERACAO FICA NO PROGRAMA WDATN002    # 
      #------------------------------------------------------# 
      
      if gr_aci_res_head.codigo_retorno <> 0 then                                                                                                                                           
        let m_err_rel = "Erro OP SAP: ", gr_aci_res_head.codigo_retorno using '<<<<<<&', 
                        " Msg : ", gr_aci_res_head.mensagem clipped, 
                        " - ", gr_aci_res_head.tipo_erro clipped  
                         
        # Relatorio para enviar os erros ocorridos na OPs                                            
        output to report bdbsa017_resumo(m_err_rel)                                                                                                                                         
        
        
         display "Resultado da operação1:" 
         display "gr_aci_res_head.codigo_retorno: ",gr_aci_res_head.codigo_retorno clipped 
         display "gr_aci_res_head.mensagem      : ",gr_aci_res_head.mensagem clipped
         display "gr_aci_res_head.tipo_erro     : ",gr_aci_res_head.tipo_erro
         display "----------------------------"
   
        return gr_aci_res_head.codigo_retorno, gr_aci_res_head.mensagem                                                                                                                          
      end if  
                                                                                                                                                                                   
   else  # OP TRIBUTAVEL  
     
      #--------------------------------------------------------#  
      #GRAVA NO LOG AS INFORMACOES QUE FORAM ENVIADAS AO SAP   #  
      #--------------------------------------------------------#  
      display "OP Tributavel" 
      call log_sap(m_arr_sap)        
      
      #--------------------------------------------------------# 
      #CHAMA O SAP COM A INTEGRACAO DE OP  TRIBUTAVEL          # 
      #--------------------------------------------------------# 
      let gr_aci_req_head.id_integracao   = "038PTSOCTRIB"
      
      let m_tempo_chamada = current
      display "TEmpoCT1:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
      
      call ffpgc374_gerarop_tribut_serv_lote()   
      
      whenever error continue
      display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
             ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
      whenever error stop 
      
      let m_tempo_retorno  = current
      display "TEmpoRT1:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
                                                                                                                                            
      
      display "Codigo_retorno OP TRIBUTAVEL: ",gr_aci_res_head.codigo_retorno
      
       display "Resultado da operação2:" 
       display "gr_aci_res_head.codigo_retorno: ",gr_aci_res_head.codigo_retorno clipped 
       display "gr_aci_res_head.mensagem      : ",gr_aci_res_head.mensagem clipped
       display "gr_aci_res_head.tipo_erro     : ",gr_aci_res_head.tipo_erro
       display "----------------------------"
      
      if gr_aci_res_head.codigo_retorno = -1 then
      
         call MQ4GL_Init() returning lr_erro, lr_msgerr
         
          let m_tempo_chamada = current
          display "TEmpoCT1:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
                  gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
          
          sleep 10 # Rodolfo Massini - PGP P14070117 - inserir intervalo entre chamada SAP para evitar PI-Remote
          call ffpgc374_gerarop_tribut_serv_lote()
          
          whenever error continue
          display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
                 ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
          whenever error stop 
          
          let m_tempo_retorno  = current
          display "TEmpoRT1:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
         
      end if 
      
      #------------------------------------------------------# 
      #    VERIFICA SE HOUVE ALGUM ERRO NO ENVIO DA OP       #
      #    O RETORNO DA GERACAO FICA NO PROGRAMA WDATN002    # 
      #------------------------------------------------------#
      if gr_aci_res_head.codigo_retorno <> 0 then                                                                                                                                           
        let m_err_rel = "Erro OP SAP: ", gr_aci_res_head.codigo_retorno using '<<<<<<&', 
                        " Msg : ", gr_aci_res_head.mensagem clipped, 
                        " - ", gr_aci_res_head.tipo_erro clipped                              
        
        # Relatorio para enviar os erros ocorridos na OPs
        output to report bdbsa017_resumo(m_err_rel)                                                                                                                                         
         
        #Nao tem return neste ponto, pois o sistema deve verificar se existe desconto para esta OP. 
        #O SAP entende que o valor de desconto é um novo documento 
                                                                                                                                                                                          
      end if                                                                                                                                                                                
   end if   
   
                                                                                                                                                                                           
   #------------------------------------------------------------# 
   # VERIFICA SE EXISTE UM VALOR DE DESCONTO PARA O DOCUMENTO   # 
   #------------------------------------------------------------#
                                                                                                                                                          
   display "m_bdbsa017.socopgdscvlr: ",m_bdbsa017.socopgdscvlr
   if m_bdbsa017.socopgdscvlr <> 0.00000 then

      ## fornax marco/2016 SPR-2016-02269 Projeto Controle de Desconto
      open cbdbsa01701 using  m_bdbsa017.socopgnum 

      foreach cbdbsa01701 into l_dsctipcod, l_dscvlr

      ##if m_bdbsa017.socopgdscvlr is not null then

         let  l_coddesp = null
         let  l_ccusto  = null
	 open cbdbsa01702 using l_dsctipcod
	 fetch cbdbsa01702 into l_coddesp, l_ccusto
	 close cbdbsa01702

	 if l_coddesp is not null then
	    let m_bdbsa017.coddesp = l_coddesp
	 end if 

         let gr_038_dad_trib_v1.codigo_despesa = m_bdbsa017.coddesp #Coddespesa
         
         #------------------------------------------------------------# 
         # MODIFICA OS VALORES QUE DEVEM SER ALTERADOS PARA ENVIAR    # 
         # O DOCUMENTO DE DESCONTO AO SAP, IREMOS SOMAR UM VALOR PARA #
         # GERAR O NOVO DOCUMENTO REFERENCIA JA QUE NAO PODEMOS       #
         # ENVIAR O MESMO PARA GERACAO DE UMA NOVA OP                 #
         #------------------------------------------------------------#
         
         let gr_038_cab_v1.doc_rfr_origem    = m_bdbsa017.socopgnum + 90000000

	 #fornax marco/2016 - juntar o codigo tipo desconto no nr da OP de desc
	 let gr_038_cab_v1.doc_rfr_origem = gr_038_cab_v1.doc_rfr_origem clipped,  l_dsctipcod using "<<<<"

         let gr_038_cab_v1.doc_rfr_origem    = gr_038_cab_v1.doc_rfr_origem using '<<<<<<<<<<<<<<<<'

	 #fornax marco/2016 - manter o nr da OP sem o tip.desc pra fazer o upd
         let lr_num_op_desc = gr_038_cab_v1.doc_rfr_origem using "<<<<<<<<"

         let gr_038_cab_v1.num_sinistro_ano  = gr_038_cab_v1.doc_rfr_origem

         ###let gr_038_dad_nf_v1.montante_bruto = m_bdbsa017.socopgdscvlr
         let gr_038_dad_nf_v1.montante_bruto = l_dscvlr #Montante bruto fatura

         #let gr_038_dad_pgt_v1.vlr_pgt = m_bdbsa017.socopgdscvlr * (-1) #Valor Pagamento
         let gr_038_dad_pgt_v1.vlr_pgt = l_dscvlr * (-1) #Valor Pagamento
         
         #-------------------------------------------------------------# 
         # VALORES FIXOS DE ENVIO PARA SINALIZAR UMA OP NAO TRIBUTAVEL #
         # POIS OP DE DESCONTO EH SEMPRE NAO TRIBUTAVEL, MAS EH ENVIADA#
         # COM A ESTRUTURA ITENS DE UMA FORMA DIFERENTE DA OP "NORMAL" # 
         #-------------------------------------------------------------#
         let gr_038_cab_v1.ind_tributavel   = "N"                                                                                                                                        
         let gr_038_cab_v1.codigo_origem    = "11"                                                                                                                                  
         let gr_aci_req_head.id_integracao  = "038PTSOCNTRIB"
         
         #Atualiza a estrutura itens, pois não pode gerar mais de uma linha
         initialize ga_038_srv_v1 to null
         
      
         
         call bdbsa017_carrega_rateio_SAP_naotibutavel(l_ccusto)
         
         #--------------------------------------------------------#  
         #GRAVA NO LOG AS INFORMACOES QUE FORAM ENVIADAS AO SAP   #  
         #--------------------------------------------------------#  
         display "OP de Desconto" 
         call log_sap(m_arr_sap)                                                                                                                                                                                                                                                                                                                                 
         
         
         #-----------------------------------------------------------# 
         #CHAMA O SAP COM A INTEGRACAO DE OP NAO TRIBUTAVEL DESCONTO # 
         #-----------------------------------------------------------# 
         
   
         
         let m_tempo_chamada = current
         display "TEmpoCNT2:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
                 gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
        
         sleep 10 # Rodolfo Massini - PGP P14070117 - inserir intervalo entre chamada SAP para evitar PI-Remote 
         call ffpgc374_gerarop_naotrib_lote() 
         
         whenever error continue
         display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
                ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
         whenever error stop 
         
         let m_tempo_retorno  = current
         display "TEmpoRNT2:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
         
         display "Codigo_retorno OP DESCONTO: ",gr_aci_res_head.codigo_retorno 
         
          display "Resultado da operação3:" 
          display "gr_aci_res_head.codigo_retorno: ",gr_aci_res_head.codigo_retorno clipped 
          display "gr_aci_res_head.mensagem      : ",gr_aci_res_head.mensagem clipped
          display "gr_aci_res_head.tipo_erro     : ",gr_aci_res_head.tipo_erro
          display "----------------------------"
   
         
         if gr_aci_res_head.codigo_retorno = 2009 then
      
         call MQ4GL_Init() returning lr_erro, lr_msgerr
         
          let m_tempo_chamada = current
          display "TEmpoCNT2:",m_tempo_chamada," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
                  gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
          
          sleep 10 # Rodolfo Massini - PGP P14070117 - inserir intervalo entre chamada SAP para evitar PI-Remote 
          call ffpgc374_gerarop_naotrib_lote()
          
          whenever error continue
          display "TrackNumber OP: ", gr_038_cab_v1.doc_rfr_origem 
                 ," - ", gr_aci_res_head.track_number
      
      display "gr_aci_res_head.codigo_retorno: ", gr_aci_res_head.codigo_retorno
      display "gr_aci_res_head.mensagem: ", gr_aci_res_head.mensagem
      display "gr_aci_res_head.tipo_erro: ", gr_aci_res_head.tipo_erro
      
          whenever error stop 
          
          let m_tempo_retorno  = current
          display "TEmpoRNT2:",m_tempo_retorno," SAP: ",gr_038_cab_v1.doc_rfr_origem,'|',
              gr_038_cab_v1.empresa,'|', m_bdbsa017.pstcoddig
      
         
         end if 
         
         
         #------------------------------------------------------# 
         #    VERIFICA SE HOUVE ALGUM ERRO NO ENVIO DA OP       #
         #    O RETORNO DA GERACAO FICA NO PROGRAMA WDATN002    # 
         #------------------------------------------------------#
         if gr_aci_res_head.codigo_retorno <> 0 then 
           let m_err_rel = "Erro OP Desconto SAP: ", gr_aci_res_head.codigo_retorno using '<<<<<<&',
                           " Msg : ", gr_aci_res_head.mensagem clipped, 
                           " - ", gr_aci_res_head.tipo_erro clipped
                           
           output to report bdbsa017_resumo(m_err_rel)
           
           return gr_aci_res_head.codigo_retorno, gr_aci_res_head.mensagem
         end if 
         
         #-----------------------------------------------------------# 
         #ATUALIZA A OP COM O NUMERO GERADO DA OP DE DESCONTO        # 
         #-----------------------------------------------------------# 
         whenever error continue
            update dbsmopg
               set dscpgtordnum = lr_num_op_desc
             where socopgnum    = m_bdbsa017.socopgnum
            
            if sqlca.sqlcode <> 0 then
               display 'Erro: ',  sqlca.sqlcode, ' ao atualizar o numero de Desconto' 
               let  m_err_rel = 'Erro: ',  sqlca.sqlcode, ' ao atualizar o numero de Desconto' 
               output to report bdbsa017_resumo(m_err_rel)
            end if 
         whenever error stop                                                                
         
      ##end if 

      end foreach #fornax marco/2016 SPR-2016-02269 Projeto Controle de Desconto

   end if

   return gr_aci_res_head.codigo_retorno, gr_aci_res_head.mensagem
                   
end function
#Fornax-Quantum Fim 

#Fornax-Quantum Inicio 
#--------------------------------------------------------------------------#
function log_sap(lr_arr) 
#--------------------------------------------------------------------------#


define lr_arr  integer 
define lr_cont integer 

let lr_cont = 1 
   
   display "gr_038_cab_v1.ind_tributavel    ",gr_038_cab_v1.ind_tributavel                  
   display "gr_038_cab_v1.codigo_origem     ",gr_038_cab_v1.codigo_origem                   
   display "gr_038_cab_v1.empresa           ",gr_038_cab_v1.empresa                         
   display "gr_038_cab_v1.txt_cabecalho     ",gr_038_cab_v1.txt_cabecalho                   
   display "gr_038_cab_v1.doc_rfr_origem    ",gr_038_cab_v1.doc_rfr_origem                  
   display "gr_038_cab_v1.tpo_usr_req       ",gr_038_cab_v1.tpo_usr_req                     
   display "gr_038_cab_v1.cod_emp_req       ",gr_038_cab_v1.cod_emp_req                     
   display "gr_038_cab_v1.mat_requisitante  ",gr_038_cab_v1.mat_requisitante                
   display "gr_038_cab_v1.dat_apc_leg       ",gr_038_cab_v1.dat_apc_leg                     
   display "gr_038_cab_v1.dat_documento     ",gr_038_cab_v1.dat_documento                   
   display "gr_038_cab_v1.dat_hor_envio     ",gr_038_cab_v1.dat_hor_envio                   
                                              
   #Dados tributacao                          
   display "gr_038_dad_trib_v1.codigo_despesa      ",gr_038_dad_trib_v1.codigo_despesa      
   display "gr_038_dad_trib_v1.complemento_despesa ",gr_038_dad_trib_v1.complemento_despesa 
                                              
   #Conta Contrato                            
   display "gr_038_cta_crt_v1.ctg_conta        ",gr_038_cta_crt_v1.ctg_conta       
   display "gr_038_cta_crt_v1.grp_tsr          ",gr_038_cta_crt_v1.grp_tsr         
   display "gr_038_cta_crt_v1.vso_cta_ext      ",gr_038_cta_crt_v1.vso_cta_ext     
   display "gr_038_cta_crt_v1.codigo_sucursal  ",gr_038_cta_crt_v1.codigo_sucursal 
                                              
   #Objeto Seguro                             
   display "gr_038_obj_seg_v1.ctg_seguro      ",gr_038_obj_seg_v1.ctg_seguro                
                                                                                                                                                          
   #Chave Parceiro                                                                                                                                        
   display "gr_038_chv_pcr_v1.tipo_parceiro ",gr_038_chv_pcr_v1.tipo_parceiro                       
   display "gr_038_chv_pcr_v1.tipo_pessoa   ",gr_038_chv_pcr_v1.tipo_pessoa                         
   display "gr_038_chv_pcr_v1.num_cpf_cnpj  ",gr_038_chv_pcr_v1.num_cpf_cnpj                        
   display "gr_038_chv_pcr_v1.ordem_cnpj    ",gr_038_chv_pcr_v1.ordem_cnpj                          
   display "gr_038_chv_pcr_v1.dig_cpf_cnpj  ",gr_038_chv_pcr_v1.dig_cpf_cnpj                         
                                                  
   #Dados Parceiro                                
   display "gr_038_dad_pcr_v1.nom_rzo_social ",gr_038_dad_pcr_v1.nom_rzo_social                     
   display "gr_038_dad_pcr_v1.cpt_nom        ",gr_038_dad_pcr_v1.cpt_nom                            
   display "gr_038_dad_pcr_v1.trm_pqs        ",gr_038_dad_pcr_v1.trm_pqs                            
   display "gr_038_dad_pcr_v1.end_email      ",gr_038_dad_pcr_v1.end_email                          
   display "gr_038_dad_pcr_v1.pfx_telefone   ",gr_038_dad_pcr_v1.pfx_telefone                       
   display "gr_038_dad_pcr_v1.num_telefone   ",gr_038_dad_pcr_v1.num_telefone                       
                                                                                                                                                                 
                                                                                                                                                                 
   #Dados Pagamentos                                                                                                                                             
   display "gr_038_dad_pgt_v1.frm_pgt       ",gr_038_dad_pgt_v1.frm_pgt                                                                            
   display "gr_038_dad_pgt_v1.dst_pgt       ",gr_038_dad_pgt_v1.dst_pgt                                                                               
   display "gr_038_dad_pgt_v1.banco         ",gr_038_dad_pgt_v1.banco                                                                                 
   display "gr_038_dad_pgt_v1.agencia       ",gr_038_dad_pgt_v1.agencia                                                                               
   display "gr_038_dad_pgt_v1.dig_agencia   ",gr_038_dad_pgt_v1.dig_agencia                                                                           
   display "gr_038_dad_pgt_v1.cta_corrente  ",gr_038_dad_pgt_v1.cta_corrente                                                                          
   display "gr_038_dad_pgt_v1.dig_conta     ",gr_038_dad_pgt_v1.dig_conta                                                                             
   display "gr_038_dad_pgt_v1.data_pgt      ",gr_038_dad_pgt_v1.data_pgt                                                                              
   display "gr_038_dad_pgt_v1.vlr_pgt       ",gr_038_dad_pgt_v1.vlr_pgt                                                                               
                                                                           
   #Endereco Parceiro                                                      
   display "gr_038_end_pcr_v1.endereco         ",gr_038_end_pcr_v1.endereco                                                                           
   display "gr_038_end_pcr_v1.complemento      ",gr_038_end_pcr_v1.complemento                                                                        
   display "gr_038_end_pcr_v1.cidade           ",gr_038_end_pcr_v1.cidade                                                                             
   display "gr_038_end_pcr_v1.numero           ",gr_038_end_pcr_v1.numero                                                                             
   display "gr_038_end_pcr_v1.bairro           ",gr_038_end_pcr_v1.bairro                                                                             
   display "gr_038_end_pcr_v1.estado           ",gr_038_end_pcr_v1.estado                                                                             
   display "gr_038_end_pcr_v1.cep              ",gr_038_end_pcr_v1.cep                                                                                
   display "gr_038_end_pcr_v1.complemento_cep  ",gr_038_end_pcr_v1.complemento_cep                                                                    
   display "gr_038_end_pcr_v1.pais             ",gr_038_end_pcr_v1.pais                                                                               
                                                                           
   #Dados Nota Fiscal                                               
   display "gr_038_dad_nf_v1.categoria_nf   ",gr_038_dad_nf_v1.categoria_nf                                           
   display "gr_038_dad_nf_v1.sucursal       ",gr_038_dad_nf_v1.sucursal                                             
   display "gr_038_dad_nf_v1.numero_nf      ",gr_038_dad_nf_v1.numero_nf                                            
   display "gr_038_dad_nf_v1.montante_bruto ",gr_038_dad_nf_v1.montante_bruto                                       
   display "gr_038_dad_nf_v1.categoria_nf   ",gr_038_dad_nf_v1.categoria_nf                                         
   display "gr_038_dad_nf_v1.chave_acesso   ",gr_038_dad_nf_v1.chave_acesso                                         
   display "gr_038_dad_nf_v1.aliquota_iss   ",gr_038_dad_nf_v1.aliquota_iss                                         
   display "gr_038_dad_nf_v1.comentarios    ",gr_038_dad_nf_v1.comentarios                                          

   
   for lr_cont = 1 to lr_arr 
     #Dados Servico 
     display "lr_cont: ",lr_cont                                       
      display "ga_038_srv_v1[m_arr_sap].cod_servico      ",ga_038_srv_v1[lr_cont].cod_servico                    
      display "ga_038_srv_v1[m_arr_sap].uf_servico       ",ga_038_srv_v1[lr_cont].uf_servico                     
      display "ga_038_srv_v1[m_arr_sap].cep_servico      ",ga_038_srv_v1[lr_cont].cep_servico                    
      display "ga_038_srv_v1[m_arr_sap].end_servico      ",ga_038_srv_v1[lr_cont].end_servico                    
      display "ga_038_srv_v1[m_arr_sap].num_endereco     ",ga_038_srv_v1[lr_cont].num_endereco                   
      display "ga_038_srv_v1[m_arr_sap].bairro_servico   ",ga_038_srv_v1[lr_cont].bairro_servico                 
      display "ga_038_srv_v1[m_arr_sap].cidade_servico   ",ga_038_srv_v1[lr_cont].cidade_servico                 
      display "ga_038_srv_v1[m_arr_sap].valor_rateio     ",ga_038_srv_v1 [lr_cont].valor_rateio                  
      display "ga_038_srv_v1[m_arr_sap].cod_produto      ",ga_038_srv_v1[lr_cont].cod_produto                    
      display "ga_038_srv_v1[m_arr_sap].centro_custo     ",ga_038_srv_v1[lr_cont].centro_custo         
      
      #let lr_cont = lr_cont + 1 
                  
   end for 
   
   display ""	                

end function
#Fornax-Quantum Fim  

#Fornax-Quantum Inicio
#--------------------------------------------------------------------------#
function bdsa017_carrega_global_sap()  
#--------------------------------------------------------------------------#
   define lr_mat_req       char(07)                      
   define lr_intcod        char(17) 
   define lr_credat        date    
   
   #--------------------------------------------------------#
   # Incializa variaveis
   #--------------------------------------------------------#
   call inicializa_globais_SAP()
   
   #--------------------------------------------------------#
   # Carrega dados do prestador para o SAP
   #--------------------------------------------------------#
   call bdbsa017_carrega_parceiro_SAP()
   
   
   #--------------------------------------------------------#
   #Documento referncia Porto Socorro e valores
   #--------------------------------------------------------#
   let gr_038_cab_v1.empresa            =   m_bdbsa017.empcod                                 #Codigo Empresa                                                                                                   
   let gr_038_cab_v1.doc_rfr_origem     =   m_bdbsa017.socopgnum using '<<<<<<<<<<<<<<<<'
   let gr_038_cab_v1.num_sinistro_ano   =   m_bdbsa017.socopgnum using '<<<<<<<<<<<<<<<<'  
   let gr_038_dad_nf_v1.montante_bruto  =   m_bdbsa017.socfattotvlr using '<<<<<<<<<<<<<<.&&' #Montante bruto de fatura  
   let gr_038_dad_pgt_v1.vlr_pgt        =   m_bdbsa017.socfattotvlr using '<<<<<<<<<<<<<<.&&' #Valor Pagamento - Montante bruto no SOA
                 
   #---------------------------------------------------------#
   #Pesquisa o codigo de retencao e despesa da OP,           #
   #Quando não tem codigo de retencao a OP eh nao tributavel #
   #---------------------------------------------------------#
   
   if m_bdbsa017.pstcoddig = 3 or m_bdbsa017.lcvcod = 33 then
      let m_bdbsa017.favtip = 3
   end if 
   
   if m_bdbsa017.favtip = 4 then
      let m_bdbsa017.pcpatvcod = 5
   end if 
   
   if m_bdbsa017.favtip = 3 then
      let m_bdbsa017.pcpatvcod = 10
   end if 
   
   if m_bdbsa017.pcpatvcod is null or m_bdbsa017.pcpatvcod = ' ' then
      let m_bdbsa017.pcpatvcod = 1
   end if
             
   open c_codretecao_sel using m_bdbsa017.pcpatvcod      
                              ,m_bdbsa017.pestip  
   fetch c_codretecao_sel into  m_bdbsa017.codretecao
   close c_codretecao_sel                                    
     
   display "m_bdbsa017.codretecao: ",m_bdbsa017.codretecao 
   display "m_bdbsa017.pcpatvcod : ",m_bdbsa017.pcpatvcod
   display "m_bdbsa017.pestip    : ",m_bdbsa017.pestip               
   
   #codigo despesa
   let gr_038_dad_trib_v1.codigo_despesa       = m_bdbsa017.coddesp     #Codigo de despesa
   let gr_038_dad_trib_v1.complemento_despesa  = 0                      #Parametro 1 (SAP)
   
   #--------------------------------------------------------#
   #Verifica se a OP eh tributavel ou nao        
   #--------------------------------------------------------#          
    if m_bdbsa017.codretecao is not null or m_bdbsa017.codretecao <> "0" then
        if m_bdbsa017.pcpatvcod = 10 then
           let gr_038_cab_v1.ind_tributavel = "N"
           let  m_bdbsa017.codretecao = ''
        else   
           let gr_038_cab_v1.ind_tributavel = "S"                                     
        end if 
    else                                                                           
        let gr_038_cab_v1.ind_tributavel = "N"                                     
        let  m_bdbsa017.codretecao = ''
    end if                                                                         
    
   #--------------------------------------------------------#
   # Verifica qual a matricula do emissor da OP           
   #--------------------------------------------------------#
   let mr_chave  = "PSOMATRICULASAP"                 
   open c_matresp_sel using  mr_chave              
   fetch c_matresp_sel into  lr_mat_req           
   close c_matresp_sel                            
                                                  
   let gr_038_cab_v1.tpo_usr_req        =   "F"                                           #Tipo Usuario requisitante                                                                                        
   let gr_038_cab_v1.cod_emp_req        =   "01"                                          #Codigo Empresa Matricula Requisitante                                                                            
   let gr_038_cab_v1.mat_requisitante   =   lr_mat_req using '&&&&&'                      #Matricula Responsavel pela Requisitante                                                                          
    
   #--------------------------------------------------------#
   # Carregar dados da nota fiscal
   #--------------------------------------------------------#
   #whenever error continue
     open c_serienota_sel using  m_bdbsa017.socopgnum
     fetch c_serienota_sel into  m_bdbsa017.fisnotsrenum
     close c_serienota_sel
   #whenever error stop
   
   let gr_038_cab_v1.dat_documento      =   today                       #Data da NF / Lançamento Contábil                                                                                 
   let gr_038_dad_nf_v1.data_nf         =   m_bdbsa017.socemsnfsdat
   let gr_038_cab_v1.dat_hor_envio      =   current                     #Data e Hora do Envio    
   
   if m_bdbsa017.fisnotsrenum is null or m_bdbsa017.fisnotsrenum = " " then
     let gr_038_dad_nf_v1.numero_nf = m_bdbsa017.nfsnum using '<<<<<<<<<&'  #Numero da Nota Fiscal   
   else
     let gr_038_dad_nf_v1.numero_nf = m_bdbsa017.nfsnum using '<<<<<<<<<&',"-",m_bdbsa017.fisnotsrenum clipped #Numero da Nota Fiscal   
   end if 
    
   if m_bdbsa017.socpgtdoctip = 1 then                                                                                                                                                             
      let gr_038_dad_nf_v1.categoria_nf  = "ZN"                                     #Categoria de nota fiscal                                                                                                                         
   end if                                                                                                                                                                                          
                                                                                                                                                                                                   
   if m_bdbsa017.socpgtdoctip = 2 or m_bdbsa017.socpgtdoctip = 3  then                                                                                                                                                             
      if gr_038_chv_pcr_v1.tipo_pessoa = "J" then                                                                                                                                                  
         let gr_038_dad_nf_v1.categoria_nf  = "ZR"                                  #Categoria de nota fiscal                                                                                                                      
      else                                                                                                                                                                                                                         
         let gr_038_dad_nf_v1.categoria_nf  = "ZQ"                                  #Categoria de nota fiscal                                                                                                                      
      end if                                                                                                                                                                                       
   end if                                                                                                                                                                                          
                                                                                                                                                                                                   
   if m_bdbsa017.socpgtdoctip = 4 then                                                                                                                                                             
      let gr_038_dad_nf_v1.categoria_nf  = "ZO"                                     #Categoria de nota fiscal                                                                                                                         
   end if    
   
   
   #-----------------------------------------------------------------#
   #Define a origem do legado Z011 - Tributavel 11 - Nao tributavel
   #-----------------------------------------------------------------#
    if gr_038_cab_v1.ind_tributavel = "S" then                                                                                                                                             
       let gr_038_cab_v1.codigo_origem      = "Z011"   #Codigo Origem Tributavel                                                                                                                     
    else                                                                                                                                                                                         
       let gr_038_cab_v1.codigo_origem      = "11"     #Codigo Origem nao tributavel                                                                                                                     
    end if                                                                                                                                                                                       
    
    
    #--------------------------------------------------------#
    # Dados fixos - Padrao
    #--------------------------------------------------------#
    let gr_aci_req_head.usuario          = "999999"  
    let gr_038_cta_crt_v1.grp_tsr         =  "PG"    #Grupo Tesouraria (SAP)                                                                                           
    let gr_038_cta_crt_v1.vso_cta_ext     =  "E"     #Visão de Conta Externa
    
    
    
    if m_bdbsa017.bcoctadig = 'p' then
    
       let m_bdbsa017.bcoctadig = 'P'
    
    end if 
    
    if m_bdbsa017.bcoctadig = 'x' then
    
       let m_bdbsa017.bcoctadig = 'X'
    
    end if 
    
    
    #--------------------------------------------------------#
    # Dados para pagamento
    #--------------------------------------------------------#
    let gr_038_dad_pgt_v1.banco         = m_bdbsa017.bcocod    using '<&&&'             #Banco                     
    let gr_038_dad_pgt_v1.agencia       = m_bdbsa017.bcoagnnum using '<<&&&'            #Agencia                   
    let gr_038_dad_pgt_v1.dig_agencia   = m_bdbsa017.bcoagndig using '&'                #Digito da agencia         
    let gr_038_dad_pgt_v1.cta_corrente  = m_bdbsa017.bcoctanum using '<<<<<<<<<&&&&&'   #Numero da Conta Corrente  
    let gr_038_dad_pgt_v1.dig_conta     = m_bdbsa017.bcoctadig #using '<&'              #Digito da Conta Corrente  
    let gr_038_dad_pgt_v1.data_pgt      = m_bdbsa017.socfatpgtdat                       #Data de pagamento         
    
    if m_bdbsa017.socpgtopccod = 1 then                                                                                                                                                             
       let gr_038_dad_pgt_v1.frm_pgt           = "C"                       #Codigo Forma de Pagamento  - quer dizer que eh credito em conta                                                                                           
    end if                                                                                                                                                                                       
    if m_bdbsa017.socpgtopccod = 3 then                                                                                                                                                          
       let gr_038_dad_pgt_v1.frm_pgt           = "J"                       #Codigo Forma de Pagamento para boleto bancario                                                                                            
    end if 
    
    #--------------------------------------------------------#
    # Dados da Conta Contrato do SAP
    #--------------------------------------------------------#
    
    case m_bdbsa017.favtip 
       when 3  # reembolso
          let gr_038_cta_crt_v1.ctg_conta  = "SG"                      #Categoria Conta Contrato 
          let gr_038_cab_v1.ind_tributavel = "N"                       #Flag de tributacao
          let gr_038_cab_v1.codigo_origem  = "11"                      #Origem nao tributavel
          let gr_038_obj_seg_v1.ctg_seguro = "PG"                      #Categoria de Objeto de Seguro
          let gr_038_cta_crt_v1.codigo_sucursal = m_bdbsa017.succod using '&&&&'  #Codigo da sucursal
          let gr_038_dad_pcr_v1.trm_pqs         = m_bdbsa017.nomrazsoc     #Termo de Pesquisa (nome abreviado)                                                                                    
          
       otherwise # prestador ou locadora - nao colcoar as flags de tributacao pois pode ser op de reembolso
          let gr_038_cta_crt_v1.ctg_conta       = "PR"
          let gr_038_cta_crt_v1.codigo_sucursal = m_bdbsa017.succod using '&&&&'  #Codigo da sucursal
          let gr_038_obj_seg_v1.ctg_seguro      = "PG"                            #Categoria de Objeto de Seguro
          let gr_038_dad_pcr_v1.trm_pqs         = m_bdbsa017.nomgrr               #Termo de Pesquisa (nome abreviado)                                                                                    
          let gr_038_dad_pcr_v1.end_email       = m_bdbsa017.maides               #Endereço email  
          let gr_038_dad_nf_v1.aliquota_iss     = m_bdbsa017.infissalqvlr         #Complemento CEP  
                                                                                                                                                                                                                                                                                                           
    end case
   
    #--------------------------------------------------------#
    # Carrega os itens para reteio no sistema do SAP
    #--------------------------------------------------------#
    call bdbsa017_carrega_rateio_SAP_tibutavel()                                                                                                                                                                                                        
             
    #--------------------------------------------------------#           
    # Funcao para enviar ao SAP a OP Porto Socorro
    #--------------------------------------------------------#
    call bdbsa017_carga_op_sap()
          returning m_retsap.stt, m_retsap.msg
    
    
end function 
#Fornax-Quantum Fim  


#---------------------------------------------------#
function bdbsa017_carrega_parceiro_SAP()
#---------------------------------------------------#

     #Chave Parceiro 
     let gr_038_chv_pcr_v1.tipo_parceiro =  "0001"                          #Tipo do parceiro de negocio  
     let gr_038_chv_pcr_v1.tipo_pessoa   =  "P",m_bdbsa017.pestip           #Tipo Pessoa                                                                                                         
     let gr_038_chv_pcr_v1.num_cpf_cnpj  =  m_bdbsa017.cgccpfnum  using '<&&&&&&&&'  #Numero CPF/CNPJ                                                                                                     
     let gr_038_chv_pcr_v1.ordem_cnpj    =  m_bdbsa017.cgcord     using '&&&&'      #Ordem CNPJ                                                                                                          
     let gr_038_chv_pcr_v1.dig_cpf_cnpj  =  m_bdbsa017.cgccpfdig  using '&&'        #Digito CPF/CNPJ                                                                                                     
                                                                                                                                                                                                     
     #Dados Parceiro                                                                                                                                                                                 
     let gr_038_dad_pcr_v1.nom_rzo_social =  m_bdbsa017.nomrazsoc           #Nome ou Razao Social                                                                                                  
     let gr_038_dad_pcr_v1.pfx_telefone   =  m_bdbsa017.dddcod using "<&"   #Numero prefixo Telefone (DDD)  
     let gr_038_dad_pcr_v1.num_telefone   =  m_bdbsa017.teltxt              #Numero telefone                
                                                                                                                                                                                                      
     #Endereco Parceiro                                                                                                                                                                              
     let gr_038_end_pcr_v1.endereco            = m_bdbsa017.endlgd                          #Endereco                                                                                                             
     let gr_038_end_pcr_v1.cidade              = m_bdbsa017.endcid                          #Cidade                                                                                                               
     let gr_038_end_pcr_v1.numero              = m_bdbsa017.lgdnum                          #Numero                                                                                                               
     let gr_038_end_pcr_v1.bairro              = m_bdbsa017.endbrr                          #Bairro                                                                                                               
     let gr_038_end_pcr_v1.estado              = m_bdbsa017.ufdsgl                          #Estado (UF)                                                                                                          
     let gr_038_end_pcr_v1.cep                 = m_bdbsa017.endcep  using "<&&&&&"          #CEP                                                                                                                  
     let gr_038_end_pcr_v1.complemento_cep     = m_bdbsa017.endcepcmp  using "&&&"          #Complemento CEP                                                                                                      
     let gr_038_end_pcr_v1.pais                = "BR"                                       #Pais (Sigla)                                                                                                         
     let gr_038_dad_nf_v1.sucursal             = m_bdbsa017.succod using '&&'             #Sucursal do prestador 
             
end function



#---------------------------------------------------#
function bdbsa017_carrega_rateio_SAP_tibutavel()
#---------------------------------------------------#
   
   define lr_ratgrp record                               
          succod   dec(2,0) ,                            
          ramcod   smallint ,                            
          modal    dec(5,0) ,                            
          valor    dec(23,3)                             
   end record                                            
    
   define l_rateio record                        
          empcod     like dbsmcctrat.empcod ,  
          succod     like datrservapol.succod ,  
          cctcod     like dbsmopg.cctcod      ,  
          cctratvlr  like dbsmcctrat.cctratvlr    
   end record   

   #--------------------------------------------------------#
   # Verifica rateio Ramo
   #--------------------------------------------------------#
   declare c_itens_sap cursor for                                                                                                                                                                  
      select sucursal, ramo, modalidade, sum(valor)                                                                                                                                                
      from tmp_pagtos                                                                                                                                                                              
      group by 1,2,3                                                                                                                                                                               
      order by 4 DESC,1,2,3                                                                                                                                                                               
                                                                                                                                                                                                    
    let m_arr_sap = 1                                                                                                                                                                              
    foreach c_itens_sap into lr_ratgrp.*                                                                                                                                                            
       
       # De acordo com a planilha envia pelo flavio pelo Mantis aberto
       # Retirado pelo projeto da Camada ontabil - Porto Faz
       #if m_bdbsa017.empcod = 43 then
       #  let lr_ratgrp.ramcod = 5001
       #  let lr_ratgrp.modal  = 001
       #end if 
       
       if m_bdbsa017.empcod = 50 then
         let lr_ratgrp.ramcod = 87
         let lr_ratgrp.modal  = 001
       end if  
       
       let ga_038_srv_v1[m_arr_sap].cod_servico    = m_bdbsa017.codretecao                       #Numero de Serviço (SAP)                                                                              
       let ga_038_srv_v1[m_arr_sap].cod_municipio  = m_cty10g00_out.cidcod
       let ga_038_srv_v1[m_arr_sap].valor_rateio   = m_bdbsa017.socfattotvlr  using '<<<<<<<<<<<<<<.&&' #Valor bruto para rateio
       let ga_038_srv_v1[m_arr_sap].cod_produto    = lr_ratgrp.ramcod using "&&&&", 
                                                     lr_ratgrp.modal  using "&&&"                #Codigo do Produto (Ramo+Modalidade)
       whenever error continue  
       #Beatriz                                            
       display "valor_rateio: ", ga_038_srv_v1[m_arr_sap].valor_rateio 
       display "cod_produto: ", ga_038_srv_v1[m_arr_sap].cod_produto 
       whenever error stop
       exit foreach
    end foreach 
    

end function





#---------------------------------------------------#
function bdbsa017_carrega_rateio_SAP_naotibutavel(l_ccusto)
#---------------------------------------------------#
   define l_ccusto char(08)
   
   let m_arr_sap = 1                                                                                                                                                                              
       
   let ga_038_srv_v1[m_arr_sap].cod_servico    = m_bdbsa017.codretecao                                #Numero de Serviço (SAP)                                                                              
   let ga_038_srv_v1[m_arr_sap].uf_servico     = m_bdbsa017.ufdsgl                           #Região do Local da prestação do serviço UF                                                           
   let ga_038_srv_v1[m_arr_sap].cep_servico    = m_bdbsa017.endcep using '&&&&&','-',        
                                                 m_bdbsa017.endcepcmp  using '&&&'           #Codigo Postal do local da prestacao do servico                                                       
   let ga_038_srv_v1[m_arr_sap].end_servico    = m_bdbsa017.endlgd                           #Endereco do Local da Prestacao do servico                                                            
   let ga_038_srv_v1[m_arr_sap].num_endereco   = m_bdbsa017.lgdnum                           #Numero do logradouro do local da prestacao do servico                                                
   let ga_038_srv_v1[m_arr_sap].bairro_servico = m_bdbsa017.endbrr                           #Bairro do local da prestacao do servico                                                              
   let ga_038_srv_v1[m_arr_sap].cidade_servico = m_bdbsa017.endcid                           #Cidade do local da prestacao do servico  
   let ga_038_srv_v1[m_arr_sap].cod_municipio  = m_cty10g00_out.cidcod
   let ga_038_srv_v1[m_arr_sap].valor_rateio   = gr_038_dad_pgt_v1.vlr_pgt

   let ga_038_srv_v1[m_arr_sap].centro_custo = l_ccusto
   
   let m_arr_sap = m_arr_sap + 1
  
end function
