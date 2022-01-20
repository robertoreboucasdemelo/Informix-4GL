###############################################################################
#-----------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                              #
#.............................................................................#
#Sistema       : Central 24hs                                                 #
#Modulo        : cts72m00                                                     #
#Analista Resp : Roberto melo                                                 #
#                Laudo para assistencia a passageiros - transporte - PSS      #
#.............................................................................#
#Desenvolvimento: Roberto Melo                                                #
#Liberacao      : 02/11/2011                                                  #
#-----------------------------------------------------------------------------#
#                                                                             #
#                         * * * Alteracoes * * *                              #
#                                                                             #
#Data       Autor Fabrica  Origem     Alteracao                               #
#---------- -------------- ---------- ----------------------------------------#
#29/03/2012 Ivan, BRQ  PSI-2011-22603 Projeto alteracao cadastro de destino   #
#24/09/2013 Marcia, Intera  2013-2115 Chamada a cadastro de clientes SAPS     #
#-----------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW      #
#-----------------------------------------------------------------------------#
#30/dez/2014 - Marcos Souza (Biztalking) PSI SPR-2014-28503                   #
#                           Inclusao de rotina para captura do endereco de    #
#                           correspondencia.                                  #
#-----------------------------------------------------------------------------#
#14/01/2015 BIZTalking,Norton SPR-2014-28503 (Fechamento de Servicos)         #
#                            ->Chamar venda no input:                         #
#                              opsfa006_inclui e opsfa006_altera              #
#                            ->Incluir venda na gravacao:                     #
#                              opsfa006_insert                                #
#-----------------------------------------------------------------------------#
#20/mai/2015 - Marcos Souza (BizTalking)- SPR-2015-10068 - Não permitir  a    #
#                           entrada de nome que não seja composto.            #
#-----------------------------------------------------------------------------#
#27/05/2015 -BIZTalking,Norton SPR-2015-10068 Chamada da funcao de consulta   #
#                              de Justificativa                               #
#-----------------------------------------------------------------------------#
#16/jun/2015 - Norton Nery-BizTalking- SPR-2015-11582                         #
#                         - Ajuste na rotina de inclusao do laudo, da         #
#                           chamada da Funcao Unica para Geracao da Venda     #
#                          (opsfa006_geracao() em substituindo as chamadas:   #
#                             - opsfa014_inscadcli() - clientes               #
#                             - opsfa006_insert() - venda                     #
#                             - opsfa005_insere_etapa() - etapa               #
#                             - opsfa015_inscadped() - pedido                 #
#                         - Retirada da tela os campos:                       #
#                             - Formulário(S/N) (frmflg)                      #
#-----------------------------------------------------------------------------#
#08/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-13708-Melhorias Calculo SKU #
#                         - Capturar a unidade de cobranca do SKU             #
#                         - Alteracao nas chamadas da Venda passando a data do#
#                           servico, o SKU e sua unidade de cobranca.         #
#-----------------------------------------------------------------------------#
#28/jul/2015 - Marcos Souza (BizTalking)-SPR-2015-15533-Fechamento Servs GPS  #
#                         Retirar os campos 'Prestador Local' e 'Bagagem' da  #
#                         tela.                                               #
#-----------------------------------------------------------------------------#
#07/08/2015  - Norton Nery (BizTalking)-SPR-2015-15533-Carga variaveis para   #
#                         envio de email qdo Ocor. probl. de MQ na agenda     #
#-----------------------------------------------------------------------------#
#10/nov/2015 - Marcos Souza (BizTalking)-SPR-2015-22413-Acao Prom Black Friday#
#                         Incluir parametro "1" ("On-Line") nas chamadas das  #
#                         funcoes opsfa006_geracao() e a opsfa015_inscadped() #
#                         para indentificar o canal de venda.                 #
#-----------------------------------------------------------------------------#
#04/04/2016 - Marcos Souza (InforSystem)-SPR-2016-03565 - Vendas e Parcerias. #
#                          Rede Apartada: pagamento direto ao Prestador       #
#                         (Identificacao no SKU)                              #
###############################################################################

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"        ##-- SPR-2015-15533
globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"  # PSI-2013-07115

 define mr_cts72m00 record
                        servico       char (13)                         ,
                        prpnumdsp     char (11)                         , #=> SPR-2014-28503
                        c24solnom     like datmligacao.c24solnom        ,
                        nom           like datmservico.nom              ,
                     #-- doctxt       char (32)                         ,  #--- SPR-2015-03912-Cadastro Clientes ---
                        nscdat        like datksrvcli.nscdat , #--- SPR-2015-03912-Cadastro Clientes ---
                        srvpedcod     like datmsrvped.srvpedcod         ,  #--- SPR-2015-03912-Cadastro Pedidos  ---
                        corsus        char (06)                         ,
                        cornom        like datmservico.cornom           ,
                        cvnnom        char (19)                         ,
                        vclcoddig     like datmservico.vclcoddig        ,
                        vcldes        like datmservico.vcldes           ,
                        vclanomdl     like datmservico.vclanomdl        ,
                        vcllicnum     like datmservico.vcllicnum        ,
                        vclcordes     char (11)                         ,
                        asitipcod     like datmservico.asitipcod        ,
                        asitipabvdes  like datkasitip.asitipabvdes      ,
                        asimtvcod     like datkasimtv.asimtvcod         ,
                        asimtvdes     like datkasimtv.asimtvdes         ,
                        refatdsrvorg  like datmservico.atdsrvorg        ,
                        refatdsrvnum  like datmassistpassag.refatdsrvnum,
                        refatdsrvano  like datmassistpassag.refatdsrvano,
                        dstlcl        like datmlcl.lclidttxt            ,
                        dstlgdtxt     char (65)                         ,
                        dstbrrnom     like datmlcl.lclbrrnom            ,
                        dstcidnom     like datmlcl.cidnom               ,
                        dstufdcod     like datmlcl.ufdcod               ,
                        imdsrvflg     char (01)                         ,
                        atdprinvlcod  like datmservico.atdprinvlcod     ,
                        atdprinvldes  char (06)                         ,
                        atdlibflg     like datmservico.atdlibflg        ,
                        atdtxt        char (48)                         ,
                        atdlibdat     like datmservico.atdlibdat        ,
                        atdlibhor     like datmservico.atdlibhor
                    end record

 define w_cts72m00 record
                      atdsrvnum        like datmservico.atdsrvnum   ,
                      atdsrvano        like datmservico.atdsrvano   ,
                      vclcorcod        like datmservico.vclcorcod   ,
                      lignum           like datrligsrv.lignum       ,
                      atdhorpvt        like datmservico.atdhorpvt   ,
                      atdpvtretflg     like datmservico.atdpvtretflg,
                      atddatprg        like datmservico.atddatprg   ,
                      atdhorprg        like datmservico.atdhorprg   ,
                      atdlibflg        like datmservico.atdlibflg   ,
                      antlibflg        like datmservico.atdlibflg   ,
                      atdlibdat        like datmservico.atdlibdat   ,
                      atdlibhor        like datmservico.atdlibhor   ,
                      atddat           like datmservico.atddat      ,
                      atdhor           like datmservico.atdhor      ,
                      cnldat           like datmservico.cnldat      ,
                      atdfnlhor        like datmservico.atdfnlhor   ,
                      atdfnlflg        like datmservico.atdfnlflg   ,
                      atdetpcod        like datmsrvacp.atdetpcod    ,
                      atdprscod        like datmservico.atdprscod   ,
                      c24opemat        like datmservico.c24opemat   ,
                      c24nomctt        like datmservico.c24nomctt   ,
                      atdcstvlr        like datmservico.atdcstvlr   ,
                      ligcvntip        like datmligacao.ligcvntip   ,
                      data             like datmservico.atddat      ,
                      hora             like datmservico.atdhor      ,
                      funmat           like datmservico.funmat      ,
                      trppfrdat        like datmassistpassag.trppfrdat,
                      trppfrhor        like datmassistpassag.trppfrhor,
                      atddmccidnom     like datmassistpassag.atddmccidnom,
                      atddmcufdcod     like datmassistpassag.atddmcufdcod,
                      atdocrcidnom     like datmlcl.cidnom,
                      atdocrufdcod     like datmlcl.ufdcod,
                      atddstcidnom     like datmassistpassag.atddstcidnom,
                      atddstufdcod     like datmassistpassag.atddstufdcod,
                      operacao         char (01),
                      atdvclsgl        like datmsrvacp.atdvclsgl,
                      srrcoddig        like datmsrvacp.srrcoddig,
                      socvclcod        like datmservico.socvclcod,
                      atdrsdflg        like datmservico.atdrsdflg
                  end record

 define mr_segurado record
                        nome        char(60),
                        cgccpf      char(20),
                        pessoa      char(01),
                        dddfone     char(04),
                        numfone     char(15),
                        email       char(100)
                    end record

 define mr_corretor record
                        susep       char(06),
                        nome        char(50),
                        dddfone     char(04),
                        numfone     char(15),
                        dddfax      char(04),
                        numfax      char(15),
                        email       char(100)
                    end record

 define mr_veiculo  record
                        codigo      char(10),
                        marca       char(30),
                        tipo        char(30),
                        modelo      char(30),
                        chassi      char(20),
                        placa       char(07),
                        anofab      char(04),
                        anomod      char(04),
                        catgtar     char(10),
                        automatico  char(03)
                    end record

 define mr_seg_end record
                       endlgdtip like gsakend.endlgdtip,
                       endlgd    like gsakend.endlgd,
                       endnum    like gsakend.endnum,
                       endcmp    like gsakend.endcmp,
                       endbrr    like gsakend.endbrr,
                       endcep    like gsakend.endcep
                   end record

 define mr_parametro record
                         succod       like datrligapol.succod,
                         ramcod       like datrservapol.ramcod,
                         aplnumdig    like datrligapol.aplnumdig,
                         itmnumdig    like datrligapol.itmnumdig,
                         edsnumref    like datrligapol.edsnumref,
                         prporg       like datrligprp.prporg,
                         prpnumdig    like datrligprp.prpnumdig,
                         ligcvntip    like datmligacao.ligcvntip
                     end record

 define a_passag array[15] of record
                                  pasnom like datmpassageiro.pasnom,
                                  pasidd like datmpassageiro.pasidd
                              end record

 define a_cts72m00   array[3] of record
                                 operacao         char (01)                    ,
                                 lclidttxt        like datmlcl.lclidttxt       ,
                                 lgdtxt           char (65)                    ,
                                 lgdtip           like datmlcl.lgdtip          ,
                                 lgdnom           like datmlcl.lgdnom          ,
                                 lgdnum           like datmlcl.lgdnum          ,
                                 brrnom           like datmlcl.brrnom          ,
                                 lclbrrnom        like datmlcl.lclbrrnom       ,
                                 endzon           like datmlcl.endzon          ,
                                 cidnom           like datmlcl.cidnom          ,
                                 ufdcod           like datmlcl.ufdcod          ,
                                 lgdcep           like datmlcl.lgdcep          ,
                                 lgdcepcmp        like datmlcl.lgdcepcmp       ,
                                 lclltt           like datmlcl.lclltt          ,
                                 lcllgt           like datmlcl.lcllgt          ,
                                 dddcod           like datmlcl.dddcod          ,
                                 lcltelnum        like datmlcl.lcltelnum       ,
                                 lclcttnom        like datmlcl.lclcttnom       ,
                                 lclrefptotxt     like datmlcl.lclrefptotxt    ,
                                 c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
                                 ofnnumdig        like sgokofi.ofnnumdig       ,
                                 emeviacod        like datmlcl.emeviacod       ,
                                 celteldddcod     like datmlcl.celteldddcod    ,
                                 celtelnum        like datmlcl.celtelnum       ,
                                 endcmp           like datmlcl.endcmp
                             end record
define a_cts72m00_bkp   array[3] of record
                                 operacao         char (01)                    ,
                                 lclidttxt        like datmlcl.lclidttxt       ,
                                 lgdtxt           char (65)                    ,
                                 lgdtip           like datmlcl.lgdtip          ,
                                 lgdnom           like datmlcl.lgdnom          ,
                                 lgdnum           like datmlcl.lgdnum          ,
                                 brrnom           like datmlcl.brrnom          ,
                                 lclbrrnom        like datmlcl.lclbrrnom       ,
                                 endzon           like datmlcl.endzon          ,
                                 cidnom           like datmlcl.cidnom          ,
                                 ufdcod           like datmlcl.ufdcod          ,
                                 lgdcep           like datmlcl.lgdcep          ,
                                 lgdcepcmp        like datmlcl.lgdcepcmp       ,
                                 lclltt           like datmlcl.lclltt          ,
                                 lcllgt           like datmlcl.lcllgt          ,
                                 dddcod           like datmlcl.dddcod          ,
                                 lcltelnum        like datmlcl.lcltelnum       ,
                                 lclcttnom        like datmlcl.lclcttnom       ,
                                 lclrefptotxt     like datmlcl.lclrefptotxt    ,
                                 c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
                                 ofnnumdig        like sgokofi.ofnnumdig       ,
                                 emeviacod        like datmlcl.emeviacod       ,
                                 celteldddcod     like datmlcl.celteldddcod    ,
                                 celtelnum        like datmlcl.celtelnum       ,
                                 endcmp           like datmlcl.endcmp
                             end record
  define m_hist_cts72m00_bkp     record
                                 hist1             like datmservhist.c24srvdsc,
                                 hist2             like datmservhist.c24srvdsc,
                                 hist3             like datmservhist.c24srvdsc,
                                 hist4             like datmservhist.c24srvdsc,
                                 hist5             like datmservhist.c24srvdsc
                             end record
 define m_cts72m00_sql     smallint,
        m_srv_acionado smallint,
        aux_today      char (10),
        aux_hora       char (05),
        aux_ano        char (02),
        m_aciona       smallint,
        ws_cgccpfnum   like aeikcdt.cgccpfnum,
        ws_cgccpfdig   like aeikcdt.cgccpfdig,
        arr_aux        smallint,
        w_retorno      smallint,
        l_doc_handle   integer

 define m_mdtcod		like datmmdtmsg.mdtcod
 define m_pstcoddig     like dpaksocor.pstcoddig
 define m_socvclcod     like datkveiculo.socvclcod
 define m_srrcoddig     like datksrr.srrcoddig
 #define l_vclcordes		char(20)
 define l_msgaltend	char(1500)
 define l_texto 		  char(200)
 define l_dtalt			date
 define l_hralt		  datetime hour to minute
 define l_lgdtxtcl	  char(80)
 define l_ciaempnom  char(50)
 define l_codrtgps   smallint
 define l_msgrtgps   char(100)

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint,
        m_grava_hist   smallint

 define mr_retorno record
        erro    smallint
       ,mens    char(100)
 end record

 define m_limites_plano record
   pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
   socqlmqtd     like datkitaasipln.socqlmqtd    ,
   erro          integer                         ,
   mensagem      char(50)
 end record

 define m_sel    smallint # PSI-2013-07115
 define mr_grava_sugest char(01) # PSI-2013-07115

 # PSI-2013-00440PR
 define m_rsrchv       char(25)   # Chave de reserva regulacao
      , m_rsrchvant    char(25)   # Chave de reserva regulacao, anterior a situacao atual(A
      , m_altcidufd    smallint   # Alterou info de cidade/UF (true / false)
      , m_altdathor    smallint   # Alterou data/hora (true / false)
      , m_operacao     smallint
      , m_cidnom       like datmlcl.cidnom        # Nome cidade originalmente informada no servico
      , m_ufdcod       like datmlcl.ufdcod        # Codigo UF originalmente informado no servico
      , m_agncotdat    date                       # Data da cota atual AW (slot)
      , m_agncothor    datetime hour to second    # Hora da cota atual AW (slot)
      , m_agncotdatant date                       # Data da cota atual AW (slot)
      , m_agncothorant datetime hour to second    # Hora da cota atual AW (slot)
      , m_imdsrvflg    char(01)                   # Auxiliar para flag servico imediato
      , m_agendaw      smallint
      , m_mailpfaz     smallint
      , m_ctgtrfcod    decimal(6,0)
      , m_atddatprg_aux date                      #-SPR-2016-01943
      , m_atdhorprg_aux datetime hour to minute   #-SPR-2016-01943

 #=> SPR-2014-28503 - Inicio

 #=> TECLAS DE FUNCAO #--- PSI SPR-2014-28503
 define mr_teclas     record
        func01        char(20),
        func02        char(20),
        func03        char(20),
        func04        char(20),
        func05        char(20),
        func06        char(20),
        func07        char(20),
        func08        char(20),
        func09        char(20),
        func10        char(20),
        func11        char(20),
        func12        char(20),
        func13        char(20),
        func14        char(20)
end record

 #=> NUMERO DA PROPOSTA (FORMA DE PAGAMENTO)
define mr_prop       record
       prpnum        like datmpgtinf.prpnum,
       sqlcode       integer,
       msg           char(80)
end record

define m_vendaflg      smallint
define m_pbmonline     like datksrvcat.catcod   #- PSI SPR-2014-28503 - Venda Online
define m_c24astcodflag like datmligacao.c24astcod
define cty27g00_ret    integer # psi-2012-22101/SPR-2014-28503 - MODULAR

#=> SPR-2014-28503 - Fim

 #--------------------------#
 function cts72m00_prepare()
 #--------------------------#

 define l_sql    char(1000)

 let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts72m00_001 from l_sql
 declare c_cts72m00_001 cursor for p_cts72m00_001

 let l_sql = " select asitipcod      ",
            "   from datmservico    ",
            "   where atdsrvnum = ? ",
            "   and atdsrvano =  ?  "
 prepare p_cts72m00_002 from l_sql
 declare c_cts72m00_002 cursor for p_cts72m00_002

 let l_sql = " select cpodes      ",
             " from iddkdominio   ",
             " where cponom = 'vclcorcod' ",
             " and cpocod = ? "
 prepare p_cts72m00_003 from l_sql
 declare c_cts72m00_003 cursor for p_cts72m00_003

 let l_sql = " select atdetpcod     ",
             " from datmsrvacp      ",
             " where atdsrvnum = ?  ",
             "  and atdsrvano = ?   ",
             "  and atdsrvseq = (select max(atdsrvseq) ",
             "       from datmsrvacp      ",
             "       where atdsrvnum = ?  ",
             "       and atdsrvano = ? )  "


 prepare p_cts72m00_004 from l_sql
 declare c_cts72m00_004 cursor for p_cts72m00_004

 let l_sql =  "select atdetpcod                          "
               ,"  from datmsrvacp                         "
               ," where atdsrvnum = ?                      "
               ,"   and atdsrvano = ?                      "
               ,"   and atdsrvseq = (select max(atdsrvseq) "
               ,"                      from datmsrvacp     "
               ,"                     where atdsrvnum = ?  "
               ,"                       and atdsrvano = ?) "

 prepare p_cts72m00_005 from l_sql
 declare c_cts72m00_005 cursor for p_cts72m00_005

 let l_sql =  "select orgnum, prpnum, pgtfrmcod     "
             ,"from datmpgtinf                      "
             ,"where atdsrvnum = ?                  "
             ,"and atdsrvano = ?                    "

 prepare p_cts72m00_006 from l_sql
 declare c_cts72m00_006 cursor for p_cts72m00_006

 let l_sql =  "select clinom, crtnum, bndcod,      "
             ,"crtvlddat, cbrparqtd                "
             ,"from datmcrdcrtinf                  "
             ,"where orgnum = ?                    "
             ,"and prpnum = ?                      "
             ,"and pgtseqnum = (select             "
             ,"max(pgtseqnum) from                 "
             ,"datmcrdcrtinf a                     "
             ,"where a.orgnum = ?                  "
             ,"and prpnum = ?)                     "

 prepare p_cts72m00_007 from l_sql
 declare c_cts72m00_007 cursor for p_cts72m00_007

 let l_sql =  "select pgtfrmdes      "
             ,"from datkpgtfrm       "
             ,"where pgtfrmcod = ?   "

 prepare p_cts72m00_008 from l_sql
 declare c_cts72m00_008 cursor for p_cts72m00_008

 #let l_sql =  "select bnddes         "
 #            ,"from datkcrtbnd       "
 #            ,"where bndcod = ?      "

 let l_sql =  "select carbndnom       "
             ,"from   fcokcarbnd      "
             ,"where  carbndcod = ?   "

 prepare p_cts72m00_009 from l_sql
 declare c_cts72m00_009 cursor for p_cts72m00_009

 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAPSFAZ' "
 prepare p_cts72m00_010 from l_sql
 declare c_cts72m00_010 cursor for p_cts72m00_010

 let l_sql = " select cornom from gcaksusep, gcakcorr ",
              " where gcaksusep.corsus = ? and ",
              " gcakcorr.corsuspcp = gcaksusep.corsuspcp "
 prepare p_cts72m00_011 from l_sql
 declare c_cts72m00_011 cursor for p_cts72m00_011

 #=> SPR-2014-28503 - REAPROVEITAMENTO DE ACESSO NAO UTILIZADO
 let l_sql = " select c24astcod      ",
             "   from datmligacao    ",
             "  where atdsrvnum = ?  ",
             "    and atdsrvano = ?  ",
             "  order by lignum      "
 prepare p_cts72m00_012 from l_sql
 declare c_cts72m00_012 cursor for p_cts72m00_012

 #=> SPR-2014-28503 - MELHORIA (ACESSO PELO INDICE)
 let l_sql = " select pgtfrmcod   "
            ,"   from datmpgtinf  "
            ,"  where orgnum = 29 "
            ,"    and prpnum = ?  "
 prepare p_cts72m00_013 from l_sql
 declare c_cts72m00_013 cursor for p_cts72m00_013


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql =  "select c24soltipcod         "
             ," from datmligacao lig       "
             ," where lig.atdsrvnum = ?    "
             ,"  and lig.atdsrvano  = ?    "
             ,"  and lig.lignum = (        "
             ,"         select min(lignum) "
             ,"           from datmligacao lim "
             ,"          where lim.atdsrvnum = lig.atdsrvnum  "
             ,"            and lim.atdsrvano = lig.atdsrvano )"
 prepare p_cts72m00_014 from l_sql
 declare c_cts72m00_014 cursor for p_cts72m00_014


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql = "  select 1        "
            ," from iddkdominio "
            ," where cponom = 'altvlrvnd' "
            ,"  and cpocod = ? "
 prepare p_cts72m00_015 from l_sql
 declare c_cts72m00_015 cursor for p_cts72m00_015


 #--- PSI SPR-2014-28503-Venda Online
 let l_sql = "  select 1                  "
            ," from datkdominio           "
            ," where cponom = 'altvlrvnd' "
            ,"  and cpocod = ? "
 prepare p_cts72m00_016 from l_sql
 declare c_cts72m00_016 cursor for p_cts72m00_016


   let l_sql = " select grlinf ",
                  " from datkgeral ",
                  " where grlchv = 'PSOEMAILPFAZ' "
 prepare p_cts72m00_017 from l_sql
 declare c_cts72m00_017 cursor for p_cts72m00_017


 let m_cts72m00_sql = true

 end function

#---------------------------------------------------------------
 function cts72m00()
#---------------------------------------------------------------

 define lr_parametro record
        succod       like datrligapol.succod,
        ramcod       like datrservapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        edsnumref    like datrligapol.edsnumref,
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        ligcvntip    like datmligacao.ligcvntip
 end record

 define ws           record
    atdetpcod        like datmsrvacp.atdetpcod,
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl,
    confirma         char (01),
    grvflg           smallint,
    asitipcod        like datmservico.asitipcod,
    histerr          smallint
 end record

 #--- SPR-2015-03912-Cadastro Clientes ---
 define lr_retcli     record
        coderro        smallint
       ,msgerro        char(80)
       ,clinom         like datksrvcli.clinom
       ,nscdat         like datksrvcli.nscdat
 end record

 define l_resultado    smallint,
        l_mensagem     char(80)

 define x        char (01)
 define l_acesso smallint

 define l_grlinf   like igbkgeral.grlinf
       ,l_anomod   char(4)

 define l_data         date,
        l_hora2        datetime hour to minute

 initialize m_rsrchv
          , m_altcidufd
          , m_altdathor
          , m_operacao
          , m_agncotdat
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant 
          , m_atddatprg_aux            #-SPR-2016-01943
          , m_atdhorprg_aux  to null   #-SPR-2016-01943

        initialize  ws.*  to  null
        initialize l_resultado  to null
        initialize l_mensagem   to null
        #=> SPR-2014-28503 - TECLAS DE FUNCAO
        initialize mr_teclas.* to null

        let l_resultado  =  null
        let l_mensagem   =  null
        let x            =  null
        let l_grlinf     =  null
        let l_data       =  null
        let l_hora2      =  null
        let l_anomod     = null

 let g_documento.atdsrvorg = 2

 let lr_parametro.ligcvntip   = g_documento.ligcvntip

 let mr_parametro.ligcvntip  = lr_parametro.ligcvntip

 let int_flag   = false
 let m_srv_acionado = false
 let m_c24lclpdrcod = null
 initialize m_subbairro to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let aux_today  = l_data
 let aux_hora   = l_hora2
 let aux_ano    = aux_today[9,10]

 if m_cts72m00_sql is null or
    m_cts72m00_sql <> true then
    call cts72m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false

 whenever error continue
 open c_cts72m00_010
 fetch c_cts72m00_010 into m_agendaw

 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR

 open window w_cts72m00 at 03,02 with form "cts72m00"
                      attribute(form line 1)

 display "PSS AUTO" to msg_pss attribute(reverse)

 #=> SPR-2014-28503 - TECLAS DE FUNCAO -- Inicio
 if g_documento.atdsrvnum is not null then

    whenever error continue
    open c_cts72m00_002 using g_documento.atdsrvnum,
                              g_documento.atdsrvano
    fetch c_cts72m00_002 into ws.asitipcod

    whenever error stop
    close c_cts72m00_002

    if ws.asitipcod = 10 then
      ## display "(F3)Refe(F5)FPgt(F6)Hist(F7)Fun(F8)Data(F9)Conc(F10)Passag(Ctr+T)ETP(Ctrl+e)Email" to msgfun
      call cts72m00_atrtcfunc(1)
    else
     ##  display "(F1)Help(F3)Refe(F5)FPgt(F6)Hist(F7)Fun(F9)Conc(F10)Passag(Ctr+T)ETP(Ctrl+e)Email" to msgfun
      call cts72m00_atrtcfunc(2)
    end if
 else
    ## display "(F1)Help(F3)Refe(F5)FPgt(F6)Hist(F7)Fun(F9)Conc(F10)Passag(Ctr+T)ETP(Ctrl+e)Email" to msgfun
    call cts72m00_atrtcfunc(3)
 end if

 display "(F3)Referencia (F6)Historico (F9)Conclui  (CTRL+F)Todas as Funcoes"
            to msgfun
 #=> SPR-2014-28503 - TECLAS DE FUNCAO  -- Fim

 display "/" at 8,15
 display "-" at 8,23

 initialize mr_cts72m00.* to null
 initialize w_cts72m00.* to null
 initialize ws.*         to null

 initialize a_cts72m00   to null
 initialize a_passag     to null

 let w_cts72m00.ligcvntip = g_documento.ligcvntip

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts72m00()

    display by name mr_cts72m00.servico
##    display by name mr_cts72m00.doctxt  #--- SPR-2015-03912-Cadastro Clientes ---
    display by name mr_cts72m00.nscdat
    display by name mr_cts72m00.srvpedcod
    display by name mr_cts72m00.vcldes
    display by name mr_cts72m00.nom
    display by name mr_cts72m00.corsus
    display by name mr_cts72m00.cornom
    display by name mr_cts72m00.vclcoddig
    display by name mr_cts72m00.vclanomdl
    display by name mr_cts72m00.vcllicnum
    display by name mr_cts72m00.vclcordes
    display by name mr_cts72m00.asitipcod
    display by name mr_cts72m00.asimtvcod
    display by name mr_cts72m00.refatdsrvorg
    display by name mr_cts72m00.refatdsrvnum
    display by name mr_cts72m00.refatdsrvano
    display by name mr_cts72m00.imdsrvflg
    display by name mr_cts72m00.atdprinvlcod
    display by name mr_cts72m00.atdlibflg
    display by name mr_cts72m00.asimtvdes
    display by name mr_cts72m00.asitipabvdes
    display by name mr_cts72m00.dstlcl
    display by name mr_cts72m00.dstlgdtxt
    display by name mr_cts72m00.dstbrrnom
    display by name mr_cts72m00.dstcidnom
    display by name mr_cts72m00.dstufdcod
    display by name mr_cts72m00.atdtxt

    display by name mr_cts72m00.c24solnom attribute (reverse)
    display by name a_cts72m00[1].lgdtxt,
                    a_cts72m00[1].lclbrrnom,
                    a_cts72m00[1].cidnom,
                    a_cts72m00[1].ufdcod,
                    a_cts72m00[1].lclrefptotxt,
                    a_cts72m00[1].endzon,
                    a_cts72m00[1].dddcod,
                    a_cts72m00[1].lcltelnum,
                    a_cts72m00[1].lclcttnom,
                    a_cts72m00[1].celteldddcod,
                    a_cts72m00[1].celtelnum,
                    a_cts72m00[1].endcmp

    #=> SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
    display by name mr_cts72m00.prpnumdsp

    if mr_cts72m00.atdlibflg = "N"   then
       display by name mr_cts72m00.atdlibdat attribute (invisible)
       display by name mr_cts72m00.atdlibhor attribute (invisible)
    end if

    if w_cts72m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado projeto cadastro de alteracao de destino
       #let m_srv_acionado = true
    end if

    call cts72m00_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today, aux_hora )
       let g_rec_his = true
    end if
 else
    # -> COR DO VEICULO
    whenever error continue
     open c_cts72m00_003 using w_cts72m00.vclcorcod
     fetch c_cts72m00_003 into mr_cts72m00.vclcordes
    whenever error stop
    close c_cts72m00_003

    let mr_cts72m00.c24solnom   = g_documento.solnom

    display by name mr_cts72m00.nscdat    #--- SPR-2015-03912-Cadastro Clientes
    display by name mr_cts72m00.srvpedcod #--- SPR-2015-03912-Cadastro Clientes
    display by name mr_cts72m00.vcldes
    display by name mr_cts72m00.nom
    display by name mr_cts72m00.corsus
    display by name mr_cts72m00.cornom
    display by name mr_cts72m00.vclcoddig
    display by name mr_cts72m00.vclanomdl
    display by name mr_cts72m00.vcllicnum
    display by name mr_cts72m00.vclcordes
    display by name mr_cts72m00.asitipcod
    display by name mr_cts72m00.asimtvcod
    display by name mr_cts72m00.refatdsrvorg
    display by name mr_cts72m00.refatdsrvnum
    display by name mr_cts72m00.refatdsrvano
    display by name mr_cts72m00.imdsrvflg
    display by name mr_cts72m00.atdprinvlcod
    display by name mr_cts72m00.atdlibflg
    display by name mr_cts72m00.c24solnom attribute (reverse)

    whenever error continue
    open c_cts72m00_001
    fetch c_cts72m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts72m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts72m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window w_cts72m00
          return
       end if
    end if
    close c_cts72m00_001

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call cts72m00_inclui() returning ws.grvflg

    if ws.grvflg = true  then

       call cts10n00(w_cts72m00.atdsrvnum, w_cts72m00.atdsrvano,
                     g_issk.funmat       , aux_today, aux_hora )

       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if mr_cts72m00.imdsrvflg =  "S"     and        # servico imediato
          mr_cts72m00.atdlibflg =  "S"     and        # servico liberado
          m_aciona = 'N'                  then       # servico nao acionado auto
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
          if l_acesso = true then
             call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                  returning ws.confirma

             if ws.confirma  =  "S"   then
                call cts00m02(w_cts72m00.atdsrvnum, w_cts72m00.atdsrvano, 1 )
             end if
          end if
       end if

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       whenever error continue
       open c_cts72m00_004 using w_cts72m00.atdsrvnum,
                                 w_cts72m00.atdsrvano,
                                 w_cts72m00.atdsrvnum,
                                 w_cts72m00.atdsrvano
       fetch  c_cts72m00_004  into ws.atdetpcod
       whenever error stop
       close  c_cts72m00_004


       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------

          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts72m00.atdsrvnum
                             and atdsrvano = w_cts72m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts72m00.atdsrvnum,w_cts72m00.atdsrvano)
          end if
       end if
    end if
 end if
 clear form

 close window w_cts72m00


end function  ###  cts72m00

#-------------------------------------#
 function cts72m00_input()
#-------------------------------------#

 ##define cty27g00_ret integer # psi-2012-22101/SPR-2014-28503 - MODULAR

 define lr_aux  record
                    atddmccidnom  like datmassistpassag.atddmccidnom,
                    atddmcufdcod  like datmassistpassag.atddmcufdcod,
                    atdocrcidnom  like datmlcl.cidnom               ,
                    atdocrufdcod  like datmlcl.ufdcod               ,
                    atddstcidnom  like datmassistpassag.atddstcidnom,
                    atddstufdcod  like datmassistpassag.atddstufdcod
                end record

 define ws record
               succod           like datrservapol.succod,
               aplnumdig        like datrservapol.aplnumdig,
               itmnumdig        like datrservapol.itmnumdig,
               segnumdig        like gsakend.segnumdig,
               refatdsrvorg     like datmservico.atdsrvorg,
               dddcod           like gsakend.dddcod,
               teltxt           like gsakend.teltxt,
               vclcordes        char (11),
               blqnivcod        like datkblq.blqnivcod,
               vcllicant        like datmservico.vcllicnum,
               maxcstvlr        like datmservico.atdcstvlr,
               msgcstvlr        char (40),
               msgcstvlr2       char (40),
               msgcstvlr3       char (40),
               snhflg           char (01),
               retflg           char (01),
               prpflg           char (01),
               confirma         char (01),
               dtparam          char (16),
               sqlcode          integer,
               opcao            dec (1,0),
               opcaodes         char(20)
           end record

 define hist_cts72m00 record
                            hist1 like datmservhist.c24srvdsc,
                            hist2 like datmservhist.c24srvdsc,
                            hist3 like datmservhist.c24srvdsc,
                            hist4 like datmservhist.c24srvdsc,
                            hist5 like datmservhist.c24srvdsc
                        end record

 define l_azlaplcod    like datkazlapl.azlaplcod,
        l_resultado    smallint,
        l_mensagem     char(80),
        l_confirma     char(01),
        l_vclcordes    char (11),
        l_data         date,
        l_hora2        datetime hour to minute,
        aux_today      char (10),
        aux_hora       char (05),
        aux_ano        char (02),
        #m_srv_acionado smallint,
        arr_aux        smallint,
        l_vclcoddig_contingencia like datmservico.vclcoddig,
        l_desc_1       char(40),
        l_desc_2       char(40),
        l_clscod       like aackcls.clscod,
        l_acesso       smallint,
        l_atdetpcod    like datmsrvacp.atdetpcod,
        l_status       smallint,
        l_atdsrvorg    like datmservico.atdsrvorg

 #--- SPR-2015-03912-Cadastro Clientes ---
 define lr_retcli     record
        coderro        smallint
       ,msgerro        char(80)
       ,clinom         like datksrvcli.clinom
       ,nscdat         like datksrvcli.nscdat
 end record
 #--- SPR-2015-03912-Cadastro Pedidos ---
 define lr_retped      record
        coderro        smallint
       ,msgerro        char(80)
       ,srvpedcod      like datmsrvped.srvpedcod
 end record


 define lr_email record
     succod          like datrligapol.succod       # Codigo Sucursal
   ,aplnumdig       like datrligapol.aplnumdig    # Numero Apolice
   ,itmnumdig       like datrligapol.itmnumdig    # Numero do Item
   ,prporg          like datrligprp.prporg        # Origem da Proposta
   ,prpnumdig       like datrligprp.prpnumdig     # Numero da Proposta
   ,solnom          char (15)                     # Solicitante
   ,ramcod          like datrservapol.ramcod      # Codigo Ramo
   ,lignum          like datmligacao.lignum       # Numero da Ligacao
   ,c24astcod       like datkassunto.c24astcod    # Assunto da Ligacao
   ,ligcvntip       like datmligacao.ligcvntip    # Convenio Operacional
   ,atdsrvnum       like datmservico.atdsrvnum    # Numero do Servico
   ,atdsrvano       like datmservico.atdsrvano    # Ano do Servico
 end record

 define r_retorno_sku   record   #- SPR-2015-13708-Melhorias Calculo SKU
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg  #- SPR-2016-03565
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record


 define l_envio smallint
 define l_acaoslv char(03)

 define l_errcod   smallint
       ,l_errmsg   char(80)
 define l_lclltt   like datmlcl.lclltt   #->>> Endereco de correspondencia - PSI SPR-2014-28503
 define l_lcllgt   like datmlcl.lcllgt   #->>> Endereco de correspondencia - PSI SPR-2014-28503
 define l_vendaflg smallint              #=> SPR-2014-28503
 define l_prompt   char(1)               #->>> SPR-2014-28503
 define l_idade    integer               #- SPR-2015-03912-Cadastro Clientes
 define l_srvpedcod like datmsrvped.srvpedcod #-- SPR-2015-03912-Cadastro Pedidos
 define l_flgaux   smallint              #-SPR-2015-11582 - Ret. de campo da tela (formulario)

 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
           ,m_ctgtrfcod  to null

 initialize l_errcod, l_errmsg to null

 let     l_azlaplcod  =  null
 let     l_resultado  =  null
 let     l_mensagem  =  null
 let     l_confirma  =  null
 let     l_vclcordes  =  null
 let     l_data  =  null
 let     l_hora2  =  null
 let     aux_today  =  null
 let     aux_hora  =  null
 let     aux_ano  =  null
 #let     m_srv_acionado  =  null
 let     l_vclcoddig_contingencia  =  null
 let     l_desc_1  =  null
 let     l_desc_2  =  null
 let     l_clscod  =  null
 let     l_atdetpcod  = null
 let     l_status     = null
 let     m_grava_hist = false
 let     l_atdsrvorg  = null
 let     l_acaoslv    = null
 let     l_srvpedcod  = null        #- SPR-2015-03912-Cadastro Pedidos
 let     l_flgaux     = false       #-SPR-2015-11582

 initialize  lr_retcli.* to null    #--- SPR-2015-03912-Cadastro Clientes
 initialize  lr_retped.* to null    #--- SPR-2015-03912-Cadastro Pedidos
  initialize r_retorno_sku to null  #- SPR-2015-13708-Melhorias Calculo SKU

 initialize  lr_aux.*  to  null

 initialize  ws.*  to  null

 initialize  hist_cts72m00.*  to  null

 initialize lr_email.* to null

 initialize aux_today,
            aux_hora,
            aux_ano,
            l_azlaplcod,
            l_resultado,
            l_mensagem,
            l_confirma,
            hist_cts72m00.*,
            lr_aux.*,
            l_vclcoddig_contingencia to null

   let l_vclcoddig_contingencia = mr_cts72m00.vclcoddig

   # display 'cts72m00'
   # display 'dados da global do laudo:'
   # display 'ga_dct               : ', ga_dct
   # display 'g_documento.acao     : ', g_documento.acao
   # display 'g_documento.atdsrvorg: ', g_documento.atdsrvorg
   # display 'g_documento.atdsrvnum: ', g_documento.atdsrvnum
   # display 'g_documento.atdsrvano: ', g_documento.atdsrvano
   # display 'g_documento.cgccpfnum: ', g_documento.cgccpfnum
   # display 'g_documento.cgcord   : ', g_documento.cgcord
   # display 'g_documento.cgccpfdig: ', g_documento.cgccpfdig
   # display 'g_documento.ligcvntip: ', g_documento.ligcvntip
   # display 'g_documento.succod   : ', g_documento.succod
   # display 'g_documento.ramcod   : ', g_documento.ramcod
   # display 'g_documento.aplnumdig: ', g_documento.aplnumdig
   # display 'g_documento.itmnumdig: ', g_documento.itmnumdig
   # display 'g_documento.edsnumref: ', g_documento.edsnumref

   # INICIO PSI-2013-07115
   if upshift(g_documento.acao) = "INC" and  (ga_dct > 0 and ga_dct is not null)
      then
      call cts08g01("A","S","","EXISTEM DADOS DO CLIENTE NA BASE","DESEJA UTILIZAR ?","")
           returning ws.confirma

      let  mr_grava_sugest = 'N'

      if ws.confirma = "S"  then
         call ctc68m00_dados_tela() returning m_sel

         if m_sel is not null and m_sel > 0
            then
            # endereco cliente
            let a_cts72m00[1].lclcttnom    = ga_dados_saps[m_sel].segnom
            let a_cts72m00[1].lgdtip       = ga_dados_saps[m_sel].lgdtip
            let a_cts72m00[1].lgdnom       = ga_dados_saps[m_sel].lgdnom
            let a_cts72m00[1].lgdtxt       = ga_dados_saps[m_sel].lgdtxt
            let a_cts72m00[1].lgdnum       = ga_dados_saps[m_sel].lgdnum
            let a_cts72m00[1].lclbrrnom    = ga_dados_saps[m_sel].brrnom
            let a_cts72m00[1].cidnom       = ga_dados_saps[m_sel].cidnom
            let a_cts72m00[1].ufdcod       = ga_dados_saps[m_sel].ufdcod
            let a_cts72m00[1].endcmp       = ga_dados_saps[m_sel].endcmp
            let a_cts72m00[1].lclrefptotxt = ga_dados_saps[m_sel].lclrefptotxt
            let a_cts72m00[1].lgdcep       = ga_dados_saps[m_sel].lgdcep
            let a_cts72m00[1].lgdcepcmp    = ga_dados_saps[m_sel].lgdcepcmp
            let a_cts72m00[1].celteldddcod = ga_dados_saps[m_sel].celteldddcod
            let a_cts72m00[1].celtelnum    = ga_dados_saps[m_sel].celtelnum
            let a_cts72m00[1].dddcod       = ga_dados_saps[m_sel].dddcod
            let a_cts72m00[1].lcltelnum    = ga_dados_saps[m_sel].lcltelnum

            # endereco destino
            let a_cts72m00[2].lclcttnom    = ga_dados_saps[m_sel].segnom
            let a_cts72m00[2].lgdtip       = ga_dados_saps[m_sel].lgdtip
            let a_cts72m00[2].lgdnom       = ga_dados_saps[m_sel].lgdnom
            let a_cts72m00[2].lgdtxt       = ga_dados_saps[m_sel].lgdtxt
            let a_cts72m00[2].lgdnum       = ga_dados_saps[m_sel].lgdnum
            let a_cts72m00[2].lclbrrnom    = ga_dados_saps[m_sel].brrnom
            let a_cts72m00[2].cidnom       = ga_dados_saps[m_sel].cidnom
            let a_cts72m00[2].ufdcod       = ga_dados_saps[m_sel].ufdcod
            let a_cts72m00[2].endcmp       = ga_dados_saps[m_sel].endcmp
            let a_cts72m00[2].lclrefptotxt = ga_dados_saps[m_sel].lclrefptotxt
            let a_cts72m00[2].lgdcep       = ga_dados_saps[m_sel].lgdcep
            let a_cts72m00[2].lgdcepcmp    = ga_dados_saps[m_sel].lgdcepcmp
            let a_cts72m00[2].celteldddcod = ga_dados_saps[m_sel].celteldddcod
            let a_cts72m00[2].celtelnum    = ga_dados_saps[m_sel].celtelnum
            let a_cts72m00[2].dddcod       = ga_dados_saps[m_sel].dddcod
            let a_cts72m00[2].lcltelnum    = ga_dados_saps[m_sel].lcltelnum

            let mr_cts72m00.nom            = ga_dados_saps[m_sel].segnom
            #let mr_cts72m00.corsus         = ga_dados_saps[m_sel].corsus
            #let mr_cts72m00.cornom         = ga_dados_saps[m_sel].cornom
            let mr_cts72m00.dstlgdtxt      = ga_dados_saps[m_sel].lgdtxt
            let mr_cts72m00.dstbrrnom      = ga_dados_saps[m_sel].brrnom
            let mr_cts72m00.dstcidnom      = ga_dados_saps[m_sel].cidnom
            let mr_cts72m00.dstufdcod      = ga_dados_saps[m_sel].ufdcod
            let w_cts72m00.atddmccidnom    = ga_dados_saps[m_sel].cidnom  # endereco cliente
            let w_cts72m00.atddmcufdcod    = ga_dados_saps[m_sel].ufdcod
            let w_cts72m00.atddstcidnom    = ga_dados_saps[m_sel].cidnom  # endereco destino
            let w_cts72m00.atddstufdcod    = ga_dados_saps[m_sel].ufdcod
            let w_cts72m00.atdocrcidnom    = ga_dados_saps[m_sel].cidnom  # endereco ocorrencia
            let w_cts72m00.atdocrufdcod    = ga_dados_saps[m_sel].ufdcod

            # dados do veiculo recuperados da apolice Auto
            let mr_cts72m00.vcllicnum      = ga_dados_saps[m_sel].vcllicnum
            let mr_cts72m00.vclcoddig      = ga_dados_saps[m_sel].vclcoddig
            let mr_cts72m00.vclanomdl      = ga_dados_saps[m_sel].vclanomdl
            let mr_cts72m00.vclcordes      = ga_dados_saps[m_sel].vclcordes
            let mr_cts72m00.vcldes         = ga_dados_saps[m_sel].vcldes

            display by name a_cts72m00[1].lclcttnom
            display by name a_cts72m00[1].lgdtxt
            display by name a_cts72m00[1].lclbrrnom
            display by name a_cts72m00[1].cidnom
            display by name a_cts72m00[1].ufdcod
            display by name a_cts72m00[1].endcmp
            display by name a_cts72m00[1].lclrefptotxt
            display by name a_cts72m00[1].celteldddcod
            display by name a_cts72m00[1].celtelnum
            display by name a_cts72m00[1].dddcod
            display by name a_cts72m00[1].lcltelnum
            display by name mr_cts72m00.nom
            display by name mr_cts72m00.nom
            #display by name mr_cts72m00.corsus
            #display by name mr_cts72m00.cornom
            display by name mr_cts72m00.dstlgdtxt
            display by name mr_cts72m00.dstbrrnom
            display by name mr_cts72m00.dstcidnom
            display by name mr_cts72m00.dstufdcod
            display by name mr_cts72m00.vcllicnum
            display by name mr_cts72m00.vclcoddig
            display by name mr_cts72m00.vclanomdl
            display by name mr_cts72m00.vclcordes
            display by name mr_cts72m00.vcldes

            let  mr_grava_sugest = 'S'

            # display 'cts72m00: DADOS ENVIADOS PARA O LAUDO'
            # display 'Index: ', m_sel
            # display 'a_cts72m00[1].lclcttnom   ' , a_cts72m00[1].lclcttnom
            # display 'a_cts72m00[1].lgdtip      ' , a_cts72m00[1].lgdtip
            # display 'a_cts72m00[1].lgdnom      ' , a_cts72m00[1].lgdnom
            # display 'a_cts72m00[1].lgdtxt      ' , a_cts72m00[1].lgdtxt
            # display 'a_cts72m00[1].lgdnum      ' , a_cts72m00[1].lgdnum
            # display 'a_cts72m00[1].lclbrrnom   ' , a_cts72m00[1].lclbrrnom
            # display 'a_cts72m00[1].cidnom      ' , a_cts72m00[1].cidnom
            # display 'a_cts72m00[1].ufdcod      ' , a_cts72m00[1].ufdcod
            # display 'a_cts72m00[1].endcmp      ' , a_cts72m00[1].endcmp
            # display 'a_cts72m00[1].lclrefptotxt' , a_cts72m00[1].lclrefptotxt
            # display 'a_cts72m00[1].lgdcep      ' , a_cts72m00[1].lgdcep
            # display 'a_cts72m00[1].lgdcepcmp   ' , a_cts72m00[1].lgdcepcmp
            # display 'a_cts72m00[1].celteldddcod' , a_cts72m00[1].celteldddcod
            # display 'a_cts72m00[1].celtelnum   ' , a_cts72m00[1].celtelnum
            # display 'a_cts72m00[1].dddcod      ' , a_cts72m00[1].dddcod
            # display 'a_cts72m00[1].lcltelnum   ' , a_cts72m00[1].lcltelnum
            # display 'mr_cts72m00.nom           ' , mr_cts72m00.nom
            # display 'mr_cts72m00.corsus        ' , mr_cts72m00.corsus
            # display 'mr_cts72m00.cornom        ' , mr_cts72m00.cornom

         end if
      end if
   end if
   #FIM PSI-2013-01775

   # PSI-2013-00440PR
   if g_documento.acao = "INC"
      then
      let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
   else
      let m_operacao = 5  # na consulta considera liberado para nao regular novamente
      #display 'consulta, considerar cota ja regulada'
   end if

   # situacao original do servico
   let m_imdsrvflg = mr_cts72m00.imdsrvflg
   let m_cidnom = a_cts72m00[1].cidnom
   let m_ufdcod = a_cts72m00[1].ufdcod
   # PSI-2013-00440PR
   let l_vendaflg = m_vendaflg         #=> SPR-2014-28503

   #display 'entrada do input, var null ou carregada na consulta'
   #display 'mr_cts72m00.imdsrvflg :', mr_cts72m00.imdsrvflg
   #display 'a_cts72m00[1].cidnom :', a_cts72m00[1].cidnom
   #display 'a_cts72m00[1].ufdcod :', a_cts72m00[1].ufdcod
   #display 'g_documento.acao     :', g_documento.acao
   #display 'm_operacao           :', m_operacao
   #display 'm_agncotdatant       :', m_agncotdatant
   #display 'm_agncothorant       :', m_agncothorant

   input by name mr_cts72m00.nom         ,
                 mr_cts72m00.nscdat      , #--- SPR-2015-03912-Cadastro Clientes
                 mr_cts72m00.corsus      ,
                 mr_cts72m00.cornom      ,
                 mr_cts72m00.vclcoddig   ,
                 mr_cts72m00.vclanomdl   ,
                 mr_cts72m00.vcllicnum   ,
                 mr_cts72m00.vclcordes   ,
                 mr_cts72m00.asitipcod   ,
                 mr_cts72m00.asimtvcod   ,
                 mr_cts72m00.refatdsrvorg,
                 mr_cts72m00.refatdsrvnum,
                 mr_cts72m00.refatdsrvano,
                 mr_cts72m00.imdsrvflg   ,
                 mr_cts72m00.atdprinvlcod,
                 mr_cts72m00.atdlibflg   without defaults #-SPR-2015-11582

         before field nom
             #--- SPR-2015-03912-Cadastro Clientes ---
             if g_documento.acao = "INC" then
                call opsfa014_conscadcli(g_documento.cgccpfnum,
                                         g_documento.cgcord,
                                         g_documento.cgccpfdig)
                               returning lr_retcli.coderro
                                        ,lr_retcli.msgerro
                                        ,lr_retcli.clinom
                                        ,lr_retcli.nscdat

                if lr_retcli.coderro = false then
                   let lr_retcli.nscdat = null
                   let lr_retcli.clinom = null
                   error lr_retcli.msgerro clipped
                   prompt "Erro ao Consultar Cadastro de Clientes - Avise Informática " for char l_prompt
                end if

                let mr_cts72m00.nom    = lr_retcli.clinom
                let mr_cts72m00.nscdat = lr_retcli.nscdat
             end if

             display by name mr_cts72m00.nscdat
             display by name mr_cts72m00.nom attribute (reverse)
             #--- SPR-2015-03912-Cadastro Clientes ---

         after field nom
             display by name mr_cts72m00.nom

             if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma

                # INICIO PSI-2013-00440PR
                if m_agendaw = false   # regulacao antiga
                   then
                   call cts02m03("S"                  ,
                                 mr_cts72m00.imdsrvflg,
                                 w_cts72m00.atdhorpvt,
                                 w_cts72m00.atddatprg,
                                 w_cts72m00.atdhorprg,
                                 w_cts72m00.atdpvtretflg)
                       returning w_cts72m00.atdhorpvt,
                                 w_cts72m00.atddatprg,
                                 w_cts72m00.atdhorprg,
                                 w_cts72m00.atdpvtretflg
		          else
		          	    ##-- SPR-2015-15533 - Inicio
		          	   call cts72m00_descpbm()
		          	           returning g_documento.atddfttxt

                   let g_documento.c24pbmcod    = 1001
                   let g_documento.asitipcod    = mr_cts72m00.asitipcod
                   let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
                   let g_documento.socntzdes    = null
                   ##-- SPR-2015-15533 - Fim

                   call cts02m08("S"                 ,
                                 mr_cts72m00.imdsrvflg,
                                 m_altcidufd,
                                 "N",  # mr_cts72m00.prslocflg - SPR-2015-15533
                                 w_cts72m00.atdhorpvt,
                                 w_cts72m00.atddatprg,
                                 w_cts72m00.atdhorprg,
                                 w_cts72m00.atdpvtretflg,
                                 m_rsrchvant,
                                 m_operacao,
                                 "",
                                 a_cts72m00[1].cidnom,
                                 a_cts72m00[1].ufdcod,
                                 "",   # codigo de assistencia, nao existe no Ct24h
                                 mr_cts72m00.vclcoddig,
                                 m_ctgtrfcod,
                                 mr_cts72m00.imdsrvflg,
                                 a_cts72m00[1].c24lclpdrcod,
                                 a_cts72m00[1].lclltt,
                                 a_cts72m00[1].lcllgt,
                                 g_documento.ciaempcod,
                                 g_documento.atdsrvorg,
                                 mr_cts72m00.asitipcod,
                                 "",   # natureza nao tem, identifica pelo asitipcod
                                 "")   # sub-natureza nao tem, identifica pelo asitipcod
                       returning w_cts72m00.atdhorpvt,
                                 w_cts72m00.atddatprg,
                                 w_cts72m00.atdhorprg,
                                 w_cts72m00.atdpvtretflg,
                                 mr_cts72m00.imdsrvflg,
                                 m_rsrchv,
                                 m_operacao,
                                 m_altdathor
                end if
                # FIM PSI-2013-00440PR

                next field nom
             end if

             if  mr_cts72m00.nom is null  then
                 error " Nome deve ser informado!"
                 next field nom
             end if

          #--- PSI SPR-2015-10068 - Consistir nome composto
          if cts72m00_consiste_nome() = "N" then
             error " Nome tem que ser Composto " sleep 2
             next field nom
          end if


   #--- SPR-2015-03912-Cadastro Clientes ---
         before field nscdat
             display by name mr_cts72m00.nscdat attribute (reverse)

         after field nscdat
             display by name mr_cts72m00.nscdat

             if (mr_cts72m00.nscdat is null or
                 mr_cts72m00.nscdat = " ") and
                 lr_retcli.nscdat is not null then
                 let mr_cts72m00.nscdat = lr_retcli.nscdat
                 error "Data de Nascimento ja Cadastrada nao pode ser Removida"
                 next field nscdat
             end if
             if mr_cts72m00.nscdat >= today then
                error "Data de Nascimento Nao pode ser > Data Atual"
                next field nscdat
             end if
             let l_idade = year(today) - year(mr_cts72m00.nscdat)

             if l_idade > 110 then
                error "Data de Nascimento Invalida. Maior 110 anos"
                next field nscdat
             end if
             #--- SPR-2015-03912-Cadastro Clientes ---

             #-----
             #--- SPR-2015-03912-Cadastro Clientes --- >>>
             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then

                 # BUSCA AS LOCALIDADES PARA ASSISTENCIA AO PASSAGEIRO
                 call cts11m06(w_cts72m00.atddmccidnom,
                               w_cts72m00.atddmcufdcod,
                               w_cts72m00.atdocrcidnom,
                               w_cts72m00.atdocrufdcod,
                               w_cts72m00.atddstcidnom,
                               w_cts72m00.atddstufdcod)
                     returning w_cts72m00.atddmccidnom,
                               w_cts72m00.atddmcufdcod,
                               w_cts72m00.atdocrcidnom,
                               w_cts72m00.atdocrufdcod,
                               w_cts72m00.atddstcidnom,
                               w_cts72m00.atddstufdcod

                 if  w_cts72m00.atddmccidnom is null  or
                     w_cts72m00.atddmcufdcod is null  or
                     w_cts72m00.atdocrcidnom is null  or
                     w_cts72m00.atdocrufdcod is null  or
                     w_cts72m00.atddstcidnom is null  or
                     w_cts72m00.atddstufdcod is null  then
                     error " Localidades devem ser informadas para confirmacao",
                           " do direito de utilizacao!"
                     next field nom
                 end if

                 if  w_cts72m00.atddmccidnom = w_cts72m00.atdocrcidnom  and
                     w_cts72m00.atddmcufdcod = w_cts72m00.atdocrufdcod  then
                     call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                   "A LOCAL DE DOMICILIO!","") returning l_confirma
                     if  l_confirma = "N"  then
                         next field nom
                     end if
                 end if

                 let a_cts72m00[1].cidnom = w_cts72m00.atdocrcidnom
                 let a_cts72m00[1].ufdcod = w_cts72m00.atdocrufdcod

                 # DIFERENTE DE PASSAGEM AEREA
                 if  mr_cts72m00.asitipcod <> 10  then
                     let a_cts72m00[2].cidnom = w_cts72m00.atddstcidnom
                     let a_cts72m00[2].ufdcod = w_cts72m00.atddstufdcod
                 end if
             end if

             if  w_cts72m00.atdfnlflg = "S"  then
                 error " Servico ja' acionado nao pode ser alterado!"
                 let m_srv_acionado = true

                 # CASO O SERVIÇO JÁ ESTEJA ACIONADO
                 call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                               "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma

                 # PREVISAO PARA TERMINO DO SERVIÇO
                 # INICIO PSI-2013-00440PR
                 if m_agendaw = false   # regulacao antiga
                    then
                    call cts02m03(w_cts72m00.atdfnlflg,
                                  mr_cts72m00.imdsrvflg,
                                  w_cts72m00.atdhorpvt,
                                  w_cts72m00.atddatprg,
                                  w_cts72m00.atdhorprg,
                                  w_cts72m00.atdpvtretflg)
                        returning w_cts72m00.atdhorpvt,
                                  w_cts72m00.atddatprg,
                                  w_cts72m00.atdhorprg,
                                  w_cts72m00.atdpvtretflg
                 else
                 	  ##-- SPR-2015-15533 - Inicio
                 	  call cts72m00_descpbm()
		          	           returning g_documento.atddfttxt

                    let g_documento.c24pbmcod    = 1001
                    let g_documento.asitipcod    = mr_cts72m00.asitipcod
                    let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
                    let g_documento.socntzdes    = null
                    ##-- SPR-2015-15533 - Fim
                    call cts02m08(w_cts72m00.atdfnlflg,
                                  mr_cts72m00.imdsrvflg,
                                  m_altcidufd,
                                  "N", #- mr_cts72m00.prslocflg - SPR-2015-15533
                                  w_cts72m00.atdhorpvt,
                                  w_cts72m00.atddatprg,
                                  w_cts72m00.atdhorprg,
                                  w_cts72m00.atdpvtretflg,
                                  m_rsrchvant,
                                  m_operacao,
                                  "",
                                  a_cts72m00[1].cidnom,
                                  a_cts72m00[1].ufdcod,
                                  "",   # codigo de assistencia, nao existe no Ct24h
                                  mr_cts72m00.vclcoddig,
                                  m_ctgtrfcod,
                                  mr_cts72m00.imdsrvflg,
                                  a_cts72m00[1].c24lclpdrcod,
                                  a_cts72m00[1].lclltt,
                                  a_cts72m00[1].lcllgt,
                                  g_documento.ciaempcod,
                                  g_documento.atdsrvorg,
                                  mr_cts72m00.asitipcod,
                                  "",   # natureza nao tem, identifica pelo asitipcod
                                  "")   # sub-natureza nao tem, identifica pelo asitipcod
                        returning w_cts72m00.atdhorpvt,
                                  w_cts72m00.atddatprg,
                                  w_cts72m00.atdhorprg,
                                  w_cts72m00.atdpvtretflg,
                                  mr_cts72m00.imdsrvflg,
                                  m_rsrchv,
                                  m_operacao,
                                  m_altdathor
                 end if
                 # FIM PSI-2013-00440PR
                  next field atdlibflg  #- SPR-2015-15533-Fechamento Servs GPS
             end if
             #--- SPR-2015-03912-Cadastro Clientes -<<<

         before field corsus
             display by name mr_cts72m00.corsus     attribute (reverse)

         after field corsus
             display by name mr_cts72m00.corsus

             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then

                 if mr_cts72m00.corsus is not null  then
                    whenever error continue

                    open c_cts72m00_011 using mr_cts72m00.corsus
                    fetch c_cts72m00_011 into mr_cts72m00.cornom

                    whenever error stop

                    if sqlca.sqlcode = notfound  then
                       error " Susep do corretor nao cadastrada!"
                       next field corsus
                    else
                       display by name mr_cts72m00.cornom
                       next field vclcoddig
                    end if
                 else
                    let mr_cts72m00.cornom = null
                    display by name mr_cts72m00.cornom
                 end if
             else
                 next field nom
             end if

         before field cornom
             display by name mr_cts72m00.cornom     attribute (reverse)

         after field cornom
             display by name mr_cts72m00.cornom

         before field vclcoddig
             display by name mr_cts72m00.vclcoddig  attribute (reverse)

         after field vclcoddig
             display by name mr_cts72m00.vclcoddig

             # se outro processo nao obteve cat. tarifaria, obter
             if m_ctgtrfcod is null
                then
                # laudo auto obter cod categoria tarifaria
                call cts02m08_sel_ctgtrfcod(mr_cts72m00.vclcoddig)
                     returning l_errcod, l_errmsg, m_ctgtrfcod
             end if

             if mr_cts72m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if  mr_cts72m00.vclcoddig is not null and
                 mr_cts72m00.vclcoddig <> 0 then

                 whenever error continue
                 select vclcoddig
                   from agbkveic
                  where vclcoddig = mr_cts72m00.vclcoddig
                 whenever error stop

                 if sqlca.sqlcode = notfound  then
                    error " Codigo de veiculo nao cadastrado!"
                    next field vclcoddig
                 end if

                 call cts15g00(mr_cts72m00.vclcoddig)
                    returning mr_cts72m00.vcldes

                 display by name mr_cts72m00.vcldes

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field cornom
                 else
                     next field vclanomdl
                 end if
             else
                 # FILTRO PARA CODIGO DO VEICULO
                 call agguvcl() returning mr_cts72m00.vclcoddig
                 next field vclcoddig
             end if

             whenever error continue
               select vclcoddig
                 from agbkveic
                where vclcoddig = mr_cts72m00.vclcoddig
             whenever error stop

             if  sqlca.sqlcode = notfound  then
                 error " Codigo de veiculo nao cadastrado!"
                 next field vclcoddig
             end if

             display by name mr_cts72m00.vcldes

         before field vclanomdl
             display by name mr_cts72m00.vclanomdl  attribute (reverse)

         after field vclanomdl
             display by name mr_cts72m00.vclanomdl

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field vclcoddig
             end if

             if  mr_cts72m00.vclanomdl is null then
                 error " Ano do veiculo deve ser informado!"
                 next field vclanomdl
             else
                 # VALIDAÇÃO PARA ANO DO CARRO
                 if  cts15g01(mr_cts72m00.vclcoddig,mr_cts72m00.vclanomdl) = false  then
                     error " Veiculo nao consta como fabricado em ",
                             mr_cts72m00.vclanomdl, "!"
                     next field vclanomdl
                 end if
             end if

         before field vcllicnum
             display by name mr_cts72m00.vcllicnum  attribute (reverse)

         after field vcllicnum
             display by name mr_cts72m00.vcllicnum

             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if  not srp1415(mr_cts72m00.vcllicnum)  then
                     error " Placa invalida!"
                     next field vcllicnum
                 end if
             end if

         before field vclcordes
             display by name mr_cts72m00.vclcordes attribute (reverse)

         after field vclcordes
             display by name mr_cts72m00.vclcordes

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field vcllicnum
             end if

             if  mr_cts72m00.vclcordes is not null then
                 let l_vclcordes = mr_cts72m00.vclcordes[2,9]

                 whenever error continue
                 select cpocod
                   into w_cts72m00.vclcorcod
                   from iddkdominio
                  where cponom      = "vclcorcod"
                    and cpodes[2,9] = l_vclcordes
                 whenever error stop

                 if  sqlca.sqlcode = notfound  then
                     error " Cor fora do padrao!"

                     # POPUP DE COR PADRAO
                     call c24geral4()
                          returning w_cts72m00.vclcorcod,
                                    mr_cts72m00.vclcordes

                     if  w_cts72m00.vclcorcod  is null   then
                         error " Cor do veiculo deve ser informada!"
                         next field vclcordes
                     else
                         display by name mr_cts72m00.vclcordes
                     end if
                 end if
             else
                 # POPUP DE COR PADRAO
                 call c24geral4()
                      returning w_cts72m00.vclcorcod,
                                mr_cts72m00.vclcordes

                 if  w_cts72m00.vclcorcod  is null   then
                     error " Cor do veiculo deve ser informada!"
                     next field  vclcordes
                 else
                     display by name mr_cts72m00.vclcordes
                 end if
             end if

             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then
                 call cts40g03_data_hora_banco(2)
                      returning l_data,
                                l_hora2

                 # INFORMAÇÕES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04("",
                               "",
                               "",
                               l_data,
                               "")
             else
                 # INFORMAÇÕES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04("",
                               "",
                               "",
                               w_cts72m00.atddat    ,
                               "")

                 next field asimtvcod
             end if

         before field asitipcod
             display by name mr_cts72m00.asitipcod attribute (reverse)

         after  field asitipcod
             display by name mr_cts72m00.asitipcod

             if  fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")  then
                 if  mr_cts72m00.asitipcod is null  then

                     #POPUP DE TIPOS DE ASSISTENCIA
                     call ctn25c00(2)
                         returning mr_cts72m00.asitipcod

                     if  mr_cts72m00.asitipcod is not null  then

                         whenever error continue
                         select asitipabvdes
                           into mr_cts72m00.asitipabvdes
                           from datkasitip
                          where asitipcod = mr_cts72m00.asitipcod
                            and asitipstt = "A"
                         whenever error stop

                         display by name mr_cts72m00.asitipcod
                         display by name mr_cts72m00.asitipabvdes
                         next field asimtvcod
                     else
                         next field asitipcod
                     end if
                 else
                     whenever error continue
                     select asitipabvdes
                       into mr_cts72m00.asitipabvdes
                       from datkasitip
                      where asitipcod = mr_cts72m00.asitipcod
                        and asitipstt = "A"
                     whenever error stop

                     if  sqlca.sqlcode = notfound  then
                         error " Tipo de assistencia invalido!"

                         #POPUP DE TIPOS DE ASSISTENCIA
                         call ctn25c00(2)
                             returning mr_cts72m00.asitipcod
                         next field asitipcod
                     else
                         display by name mr_cts72m00.asitipcod
                     end if

                     whenever error continue
                     select asitipcod
                       from datrasitipsrv
                      where atdsrvorg = g_documento.atdsrvorg
                        and asitipcod = mr_cts72m00.asitipcod
                     whenever error stop

                     if  sqlca.sqlcode = notfound  then
                         error " Tipo de assistencia nao pode ser enviada para",
                               " este servico!"
                         next field asitipcod
                     end if
                 end if
                 display by name mr_cts72m00.asitipabvdes
             end if

         before field asimtvcod
             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if  mr_cts72m00.asitipcod = 11  then  ###  Remocao Hospitalar
                 ## O cara já morreu nao precisa de diagnostico. Bia 28/07/06
                 ## mr_cts72m00.asitipcod = 12  then  ###  Traslado de Corpos
                     call cts08g01("I","N",
                                   "SOLICITE:ENVIO DE FAX C/ DIAGNOSTICO DO ",
                                   " PACIENTE, FAX DA CARTA DO MEDICO COM   ",
                                   "ASSINATURA E CRM E O TIPO DE AMBULANCIA.",
                                   "   REGISTRE TAMBEM MOTIVO DA REMOCAO!   ")
                         returning ws.confirma
                 end if
             end if

             display by name mr_cts72m00.asimtvcod attribute (reverse)

         after  field asimtvcod
             display by name mr_cts72m00.asimtvcod

             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then

                if mr_cts72m00.asimtvcod is null  then
                   call cts11m03(mr_cts72m00.asitipcod)
                        returning mr_cts72m00.asimtvcod

                   if mr_cts72m00.asimtvcod is null then
                      next field asimtvcod
                   end if
                else
                   if mr_cts72m00.asimtvcod is not null  then
                      select asimtvdes --descricao
                        into mr_cts72m00.asimtvdes
                        from datkasimtv
                       where asimtvcod = mr_cts72m00.asimtvcod
                         and asimtvsit = "A"
                   end if

                   if sqlca.sqlcode = notfound  then
                      error " Motivo invalido!"
                      call cts11m03(mr_cts72m00.asitipcod)
                          returning mr_cts72m00.asimtvcod
                      next field asimtvcod
                   else
                      display by name mr_cts72m00.asimtvcod
                   end if

                   select asimtvcod
                     from datrmtvasitip
                   where asitipcod = mr_cts72m00.asitipcod
                      and asimtvcod = mr_cts72m00.asimtvcod

                   if sqlca.sqlcode = notfound  then
                      error " Motivo nao pode ser informado para este tipo",
                            " de assistencia!"
                      next field asimtvcod
                   end if
				        end if

				        display by name mr_cts72m00.asimtvcod
				        display by name mr_cts72m00.asimtvdes

                call cts45g00_limites_cob(1
				                               ,""
                                           ,""
                                           ,""
                                           ,""
				                               ,""
				                               ,mr_cts72m00.asitipcod
                                           ,""
                                           ,mr_cts72m00.asimtvcod
                                           ,w_cts72m00.ligcvntip
                                           ,"")
                     returning ws.maxcstvlr

                let ws.msgcstvlr = "LIMITE DE R$ ",ws.maxcstvlr using "<,<<<.<<"," PARA "

                if ws.maxcstvlr > 0 then
                   if mr_cts72m00.asimtvcod = 3 then
                    call cts08g01("A","N","",
                                  ws.msgcstvlr,
                                  "RECUPERACAO DE VEICULO","")
                        returning ws.confirma
                   else
                          let ws.msgcstvlr = "AO VALOR MAXIMO DE R$ ",
                                    ws.maxcstvlr using "<<<,<<<,<<&.&&"
                          call cts08g01("A","N","","LIMITE DE COBERTURA RESTRITO",
                                     ws.msgcstvlr,"")
                                     returning ws.confirma
                   end if
                else
                     if ws.maxcstvlr = 0 then
                         call cts08g01("A","N","",
                                   "LIMITE DE COBERTURA RESTRITO",
                                   "AO VALOR DE UMA PASSAGEM",
                                   "AEREA NA CLASSE ECONOMICA!")
                            returning ws.confirma
                     end if
                end if

                if ws.maxcstvlr = -1 then --controle de mensagem
                   call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                       returning ws.confirma
                end if
                #=> SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA - Ini
                let m_vendaflg = l_vendaflg
                if g_documento.acao = 'INC'  and
                   m_vendaflg              then

                   #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU

                   call opsfa001_conskupbr(1001   #-- Codigo do problema
                                          ,l_data)
                        returning r_retorno_sku.catcod
                                 ,r_retorno_sku.pgtfrmcod
                                 ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
                                 ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                                 ,r_retorno_sku.msg_erro

                   if r_retorno_sku.codigo_erro = -284 then
                      error "Existe mais de um SKU ativo para este problema!!!"
                      let r_retorno_sku.catcod = null
                      let r_retorno_sku.pgtfrmcod = null
                   else
                      if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
                         error "Nao existe SKU ativo para este problema!!!"
                         let r_retorno_sku.catcod = null
                         let r_retorno_sku.pgtfrmcod = null
                      else
                         if r_retorno_sku.codigo_erro < 0 then
                            error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                                  " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
                      	    let int_flag = true
                            exit input
                         end if
                      end if
                   end if

                   #- SPR-2015-13708-Melhorias Calculo SKU
                   if not opsfa006_inclui(r_retorno_sku.catcod
                   	                     ,0 #- 0=Distancia Ocorr X Destino-SPR-2015-15533
                   	                     ,"N") then  #- Prestador no local-SPR-2015-15533
                      next field asimtvcod
                   end if
                   let m_vendaflg = true
                end if

                if g_documento.acao = "ALT" then
                   #=> SPR-2014-28503 - EFETUA A DIGITACAO DOS DADOS DA VENDA
                   if m_vendaflg       or
                      cty27g00_ret = 1 then #=> PERMITE F.PAGTO (SEM VENDA=CONS)

                      if not opsfa006_altera(g_documento.atdsrvnum
                                            ,g_documento.atdsrvano
                                            ,g_documento.prpnum
                                            ,m_pbmonline       #- SPR-2014-28503
                                            ,0 #- Distancia Ocorr X Destino - SPR-2015-13708
                                            ,w_cts72m00.atddat #- SPR-2015-13708
                                            ,"N" #- Prest.local - SPR-2015-15533
                                            ,mr_cts72m00.nom   #- SPR-2015-11582
                                            ,mr_cts72m00.nscdat) then #- SPR-2015-11582
                          next field asimtvcod
                      end if
                   end if
                end if
                #=> SPR-2014-28503 - Fim
                next field refatdsrvorg
             else
                 if g_documento.atdsrvnum is not null  and
                    g_documento.atdsrvano is not null  then
                    next field vclcordes
                 end if
             end if


        before field refatdsrvorg
             display by name mr_cts72m00.refatdsrvorg attribute (reverse)

        after field refatdsrvorg
             display by name mr_cts72m00.refatdsrvorg

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field asimtvcod
             end if

             if  mr_cts72m00.refatdsrvorg is null  then

                     initialize mr_cts72m00.refatdsrvnum,
                                mr_cts72m00.refatdsrvano to null
                     display by name mr_cts72m00.refatdsrvnum,
                                     mr_cts72m00.refatdsrvano

             end if

             if  mr_cts72m00.refatdsrvorg <> 4   and   # REMOCAO
                 mr_cts72m00.refatdsrvorg <> 6   and   # DAF
                 mr_cts72m00.refatdsrvorg <> 1   and   # SOCORRO
                 mr_cts72m00.refatdsrvorg <> 2   then  # TRANSPORTE
                 error " Origem do servico de referencia deve",
                       " ser um SOCORRO ou REMOCAO!"
                 next field refatdsrvorg
             end if

        before field refatdsrvnum
             display by name mr_cts72m00.refatdsrvnum attribute (reverse)

        after  field refatdsrvnum
             display by name mr_cts72m00.refatdsrvnum

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvorg
             end if

             if mr_cts72m00.refatdsrvorg is not null  and
                mr_cts72m00.refatdsrvnum is null      then
                error " Numero do servico de referencia nao informado!"
                next field refatdsrvnum
             end if

        before field refatdsrvano
             display by name mr_cts72m00.refatdsrvano attribute (reverse)

        after  field refatdsrvano
             display by name mr_cts72m00.refatdsrvano

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvnum
             end if

             if  mr_cts72m00.refatdsrvnum is not null  then
                 if  mr_cts72m00.refatdsrvano is null  then
                     error " Ano do servico original nao informado!"
                     next field refatdsrvano
                 end if
             end if

             if  g_documento.atdsrvnum   is     null  and
                 g_documento.atdsrvano   is     null  and
                 mr_cts72m00.refatdsrvorg is not null  and
                 mr_cts72m00.refatdsrvnum is not null  and
                 mr_cts72m00.refatdsrvano is not null  then

                 select atdsrvorg
                   into ws.refatdsrvorg
                   from DATMSERVICO
                  where atdsrvnum = mr_cts72m00.refatdsrvnum
                    and atdsrvano = mr_cts72m00.refatdsrvano

                 if  ws.refatdsrvorg <> mr_cts72m00.refatdsrvorg  then
                     error " Origem do numero de servico invalido.",
                           " A origem deve ser ", ws.refatdsrvorg using "&&"
                     next field refatdsrvorg
                 end if

                 call ctx04g00_local_gps( mr_cts72m00.refatdsrvnum,
                                          mr_cts72m00.refatdsrvano,
                                          1                       )
                                returning a_cts72m00[1].lclidttxt   ,
                                          a_cts72m00[1].lgdtip      ,
                                          a_cts72m00[1].lgdnom      ,
                                          a_cts72m00[1].lgdnum      ,
                                          a_cts72m00[1].lclbrrnom   ,
                                          a_cts72m00[1].brrnom      ,
                                          a_cts72m00[1].cidnom      ,
                                          a_cts72m00[1].ufdcod      ,
                                          a_cts72m00[1].lclrefptotxt,
                                          a_cts72m00[1].endzon      ,
                                          a_cts72m00[1].lgdcep      ,
                                          a_cts72m00[1].lgdcepcmp   ,
                                          a_cts72m00[1].lclltt      ,
                                          a_cts72m00[1].lcllgt      ,
                                          a_cts72m00[1].dddcod      ,
                                          a_cts72m00[1].lcltelnum   ,
                                          a_cts72m00[1].lclcttnom   ,
                                          a_cts72m00[1].c24lclpdrcod,
                                          a_cts72m00[1].celteldddcod,
                                          a_cts72m00[1].celtelnum   ,
                                          a_cts72m00[1].endcmp,
                                          ws.sqlcode, a_cts72m00[1].emeviacod
                 # PSI 244589 - Inclusão de Sub-Bairro - Burini
                 let m_subbairro[1].lclbrrnom = a_cts72m00[1].lclbrrnom
                 call cts06g10_monta_brr_subbrr(a_cts72m00[1].brrnom,
                                                a_cts72m00[1].lclbrrnom)
                      returning a_cts72m00[1].lclbrrnom

                 select ofnnumdig
                   into a_cts72m00[1].ofnnumdig
                   from datmlcl
                  where atdsrvano = g_documento.atdsrvano
                    and atdsrvnum = g_documento.atdsrvnum
                    and c24endtip = 1

                 if  ws.sqlcode <> 0  then
                     error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
                           " do local de ocorrencia. AVISE A INFORMATICA!"
                     next field refatdsrvorg
                 end if

                 let a_cts72m00[1].lgdtxt = a_cts72m00[1].lgdtip clipped, " ",
                                            a_cts72m00[1].lgdnom clipped, " ",
                                            a_cts72m00[1].lgdnum using "<<<<#"

                 display by name a_cts72m00[1].lgdtxt,
                                 a_cts72m00[1].lclbrrnom,
                                 a_cts72m00[1].cidnom,
                                 a_cts72m00[1].ufdcod,
                                 a_cts72m00[1].lclrefptotxt,
                                 a_cts72m00[1].endzon,
                                 a_cts72m00[1].dddcod,
                                 a_cts72m00[1].lcltelnum,
                                 a_cts72m00[1].lclcttnom,
                                 a_cts72m00[1].celteldddcod,
                                 a_cts72m00[1].celtelnum,
                                 a_cts72m00[1].endcmp
             end if
             let a_cts72m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             #DIGITAÇÃO PADRONIZADA DE ENDEREÇOS
             let m_acesso_ind = false
             let m_atdsrvorg = 2
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind

             if m_acesso_ind = false then
                call cts06g03(1,
                              m_atdsrvorg,
                              w_cts72m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts72m00[1].lclidttxt,
                              a_cts72m00[1].cidnom,
                              a_cts72m00[1].ufdcod,
                              a_cts72m00[1].brrnom,
                              a_cts72m00[1].lclbrrnom,
                              a_cts72m00[1].endzon,
                              a_cts72m00[1].lgdtip,
                              a_cts72m00[1].lgdnom,
                              a_cts72m00[1].lgdnum,
                              a_cts72m00[1].lgdcep,
                              a_cts72m00[1].lgdcepcmp,
                              a_cts72m00[1].lclltt,
                              a_cts72m00[1].lcllgt,
                              a_cts72m00[1].lclrefptotxt,
                              a_cts72m00[1].lclcttnom,
                              a_cts72m00[1].dddcod,
                              a_cts72m00[1].lcltelnum,
                              a_cts72m00[1].c24lclpdrcod,
                              a_cts72m00[1].ofnnumdig,
                              a_cts72m00[1].celteldddcod   ,
                              a_cts72m00[1].celtelnum,
                              a_cts72m00[1].endcmp,
                              hist_cts72m00.*, a_cts72m00[1].emeviacod)
                    returning a_cts72m00[1].lclidttxt,
                              a_cts72m00[1].cidnom,
                              a_cts72m00[1].ufdcod,
                              a_cts72m00[1].brrnom,
                              a_cts72m00[1].lclbrrnom,
                              a_cts72m00[1].endzon,
                              a_cts72m00[1].lgdtip,
                              a_cts72m00[1].lgdnom,
                              a_cts72m00[1].lgdnum,
                              a_cts72m00[1].lgdcep,
                              a_cts72m00[1].lgdcepcmp,
                              a_cts72m00[1].lclltt,
                              a_cts72m00[1].lcllgt,
                              a_cts72m00[1].lclrefptotxt,
                              a_cts72m00[1].lclcttnom,
                              a_cts72m00[1].dddcod,
                              a_cts72m00[1].lcltelnum,
                              a_cts72m00[1].c24lclpdrcod,
                              a_cts72m00[1].ofnnumdig,
                              a_cts72m00[1].celteldddcod   ,
                              a_cts72m00[1].celtelnum,
                              a_cts72m00[1].endcmp,
                              ws.retflg,
                              hist_cts72m00.*, a_cts72m00[1].emeviacod

                if  ws.retflg = "N"  then
                   error " Dados referentes ao local incorretos ou nao preenchidos!"
                   next field refatdsrvorg
                end if

                #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA O",
                             " MESMO DE OCORRENCIA?","", "")
                    returning ws.confirma

                if ws.confirma = "S" then   #--- Endereco correspondencia - PSI SPR-2014-28503
                   let a_cts72m00[3].lclidttxt     = a_cts72m00[1].lclidttxt
                   let a_cts72m00[3].cidnom        = a_cts72m00[1].cidnom
                   let a_cts72m00[3].ufdcod        = a_cts72m00[1].ufdcod
                   let a_cts72m00[3].brrnom        = a_cts72m00[1].brrnom
                   let a_cts72m00[3].lclbrrnom     = a_cts72m00[1].lclbrrnom
                   let a_cts72m00[3].endzon        = a_cts72m00[1].endzon
                   let a_cts72m00[3].lgdtip        = a_cts72m00[1].lgdtip
                   let a_cts72m00[3].lgdnom        = a_cts72m00[1].lgdnom
                   let a_cts72m00[3].lgdnum        = a_cts72m00[1].lgdnum
                   let a_cts72m00[3].lgdcep        = a_cts72m00[1].lgdcep
                   let a_cts72m00[3].lgdcepcmp     = a_cts72m00[1].lgdcepcmp
                   let a_cts72m00[3].lclltt        = a_cts72m00[1].lclltt
                   let a_cts72m00[3].lcllgt        = a_cts72m00[1].lcllgt
                   let a_cts72m00[3].lclrefptotxt  = a_cts72m00[1].lclrefptotxt
                   let a_cts72m00[3].lclcttnom     = a_cts72m00[1].lclcttnom
                   let a_cts72m00[3].dddcod        = a_cts72m00[1].dddcod
                   let a_cts72m00[3].lcltelnum     = a_cts72m00[1].lcltelnum
                   let a_cts72m00[3].c24lclpdrcod  = a_cts72m00[1].c24lclpdrcod
                   let a_cts72m00[3].ofnnumdig     = a_cts72m00[1].ofnnumdig
                   let a_cts72m00[3].celteldddcod  = a_cts72m00[1].celteldddcod
                   let a_cts72m00[3].celtelnum     = a_cts72m00[1].celtelnum
                   let a_cts72m00[3].endcmp        = a_cts72m00[1].endcmp
                else
                   #--->>> Endereco correspondencia - PSI SPR-2014-28503
                   call cts06g03(7,
                                 m_atdsrvorg,
                                 w_cts72m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts72m00[3].lclidttxt,
                                 a_cts72m00[3].cidnom,
                                 a_cts72m00[3].ufdcod,
                                 a_cts72m00[3].brrnom,
                                 a_cts72m00[3].lclbrrnom,
                                 a_cts72m00[3].endzon,
                                 a_cts72m00[3].lgdtip,
                                 a_cts72m00[3].lgdnom,
                                 a_cts72m00[3].lgdnum,
                                 a_cts72m00[3].lgdcep,
                                 a_cts72m00[3].lgdcepcmp,
                                 a_cts72m00[3].lclltt,
                                 a_cts72m00[3].lcllgt,
                                 a_cts72m00[3].lclrefptotxt,
                                 a_cts72m00[3].lclcttnom,
                                 a_cts72m00[3].dddcod,
                                 a_cts72m00[3].lcltelnum,
                                 a_cts72m00[3].c24lclpdrcod,
                                 a_cts72m00[3].ofnnumdig,
                                 a_cts72m00[3].celteldddcod   ,
                                 a_cts72m00[3].celtelnum,
                                 a_cts72m00[3].endcmp,
                                 hist_cts72m00.*, a_cts72m00[3].emeviacod)
                       returning a_cts72m00[3].lclidttxt,
                                 a_cts72m00[3].cidnom,
                                 a_cts72m00[3].ufdcod,
                                 a_cts72m00[3].brrnom,
                                 a_cts72m00[3].lclbrrnom,
                                 a_cts72m00[3].endzon,
                                 a_cts72m00[3].lgdtip,
                                 a_cts72m00[3].lgdnom,
                                 a_cts72m00[3].lgdnum,
                                 a_cts72m00[3].lgdcep,
                                 a_cts72m00[3].lgdcepcmp,
                                 a_cts72m00[3].lclltt,
                                 a_cts72m00[3].lcllgt,
                                 a_cts72m00[3].lclrefptotxt,
                                 a_cts72m00[3].lclcttnom,
                                 a_cts72m00[3].dddcod,
                                 a_cts72m00[3].lcltelnum,
                                 a_cts72m00[3].c24lclpdrcod,
                                 a_cts72m00[3].ofnnumdig,
                                 a_cts72m00[3].celteldddcod   ,
                                 a_cts72m00[3].celtelnum,
                                 a_cts72m00[3].endcmp,
                                 ws.retflg,
                                 hist_cts72m00.*, a_cts72m00[3].emeviacod

                end if    #---<<<  Endereco de correspondencia - PSI SPR-2014-28503
             else
                call cts06g11(1,
                              m_atdsrvorg,
                              w_cts72m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts72m00[1].lclidttxt,
                              a_cts72m00[1].cidnom,
                              a_cts72m00[1].ufdcod,
                              a_cts72m00[1].brrnom,
                              a_cts72m00[1].lclbrrnom,
                              a_cts72m00[1].endzon,
                              a_cts72m00[1].lgdtip,
                              a_cts72m00[1].lgdnom,
                              a_cts72m00[1].lgdnum,
                              a_cts72m00[1].lgdcep,
                              a_cts72m00[1].lgdcepcmp,
                              a_cts72m00[1].lclltt,
                              a_cts72m00[1].lcllgt,
                              a_cts72m00[1].lclrefptotxt,
                              a_cts72m00[1].lclcttnom,
                              a_cts72m00[1].dddcod,
                              a_cts72m00[1].lcltelnum,
                              a_cts72m00[1].c24lclpdrcod,
                              a_cts72m00[1].ofnnumdig,
                              a_cts72m00[1].celteldddcod   ,
                              a_cts72m00[1].celtelnum,
                              a_cts72m00[1].endcmp,
                              hist_cts72m00.*, a_cts72m00[1].emeviacod)
                    returning a_cts72m00[1].lclidttxt,
                              a_cts72m00[1].cidnom,
                              a_cts72m00[1].ufdcod,
                              a_cts72m00[1].brrnom,
                              a_cts72m00[1].lclbrrnom,
                              a_cts72m00[1].endzon,
                              a_cts72m00[1].lgdtip,
                              a_cts72m00[1].lgdnom,
                              a_cts72m00[1].lgdnum,
                              a_cts72m00[1].lgdcep,
                              a_cts72m00[1].lgdcepcmp,
                              a_cts72m00[1].lclltt,
                              a_cts72m00[1].lcllgt,
                              a_cts72m00[1].lclrefptotxt,
                              a_cts72m00[1].lclcttnom,
                              a_cts72m00[1].dddcod,
                              a_cts72m00[1].lcltelnum,
                              a_cts72m00[1].c24lclpdrcod,
                              a_cts72m00[1].ofnnumdig,
                              a_cts72m00[1].celteldddcod   ,
                              a_cts72m00[1].celtelnum,
                              a_cts72m00[1].endcmp,
                              ws.retflg,
                              hist_cts72m00.*, a_cts72m00[1].emeviacod

                 if  ws.retflg = "N"  then
                     error " Dados referentes ao local incorretos ou nao preenchidos!"
                     next field refatdsrvorg
                 end if

                #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                 call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA O",
                             " MESMO DE OCORRENCIA?","", "")
                    returning ws.confirma

                if ws.confirma = "S" then   #--- Endereco correspondencia - PSI SPR-2014-28503
                   let a_cts72m00[3].lclidttxt     = a_cts72m00[1].lclidttxt
                   let a_cts72m00[3].cidnom        = a_cts72m00[1].cidnom
                   let a_cts72m00[3].ufdcod        = a_cts72m00[1].ufdcod
                   let a_cts72m00[3].brrnom        = a_cts72m00[1].brrnom
                   let a_cts72m00[3].lclbrrnom     = a_cts72m00[1].lclbrrnom
                   let a_cts72m00[3].endzon        = a_cts72m00[1].endzon
                   let a_cts72m00[3].lgdtip        = a_cts72m00[1].lgdtip
                   let a_cts72m00[3].lgdnom        = a_cts72m00[1].lgdnom
                   let a_cts72m00[3].lgdnum        = a_cts72m00[1].lgdnum
                   let a_cts72m00[3].lgdcep        = a_cts72m00[1].lgdcep
                   let a_cts72m00[3].lgdcepcmp     = a_cts72m00[1].lgdcepcmp
                   let a_cts72m00[3].lclltt        = a_cts72m00[1].lclltt
                   let a_cts72m00[3].lcllgt        = a_cts72m00[1].lcllgt
                   let a_cts72m00[3].lclrefptotxt  = a_cts72m00[1].lclrefptotxt
                   let a_cts72m00[3].lclcttnom     = a_cts72m00[1].lclcttnom
                   let a_cts72m00[3].dddcod        = a_cts72m00[1].dddcod
                   let a_cts72m00[3].lcltelnum     = a_cts72m00[1].lcltelnum
                   let a_cts72m00[3].c24lclpdrcod  = a_cts72m00[1].c24lclpdrcod
                   let a_cts72m00[3].ofnnumdig     = a_cts72m00[1].ofnnumdig
                   let a_cts72m00[3].celteldddcod  = a_cts72m00[1].celteldddcod
                   let a_cts72m00[3].celtelnum     = a_cts72m00[1].celtelnum
                   let a_cts72m00[3].endcmp        = a_cts72m00[1].endcmp
                else
                   #--->>> Endereco correspondencia - PSI SPR-2014-28503
                   call cts06g11(7,
                                 m_atdsrvorg,
                                 w_cts72m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts72m00[3].lclidttxt,
                                 a_cts72m00[3].cidnom,
                                 a_cts72m00[3].ufdcod,
                                 a_cts72m00[3].brrnom,
                                 a_cts72m00[3].lclbrrnom,
                                 a_cts72m00[3].endzon,
                                 a_cts72m00[3].lgdtip,
                                 a_cts72m00[3].lgdnom,
                                 a_cts72m00[3].lgdnum,
                                 a_cts72m00[3].lgdcep,
                                 a_cts72m00[3].lgdcepcmp,
                                 a_cts72m00[3].lclltt,
                                 a_cts72m00[3].lcllgt,
                                 a_cts72m00[3].lclrefptotxt,
                                 a_cts72m00[3].lclcttnom,
                                 a_cts72m00[3].dddcod,
                                 a_cts72m00[3].lcltelnum,
                                 a_cts72m00[3].c24lclpdrcod,
                                 a_cts72m00[3].ofnnumdig,
                                 a_cts72m00[3].celteldddcod   ,
                                 a_cts72m00[3].celtelnum,
                                 a_cts72m00[3].endcmp,
                                 hist_cts72m00.*, a_cts72m00[3].emeviacod)
                       returning a_cts72m00[3].lclidttxt,
                                 a_cts72m00[3].cidnom,
                                 a_cts72m00[3].ufdcod,
                                 a_cts72m00[3].brrnom,
                                 a_cts72m00[3].lclbrrnom,
                                 a_cts72m00[3].endzon,
                                 a_cts72m00[3].lgdtip,
                                 a_cts72m00[3].lgdnom,
                                 a_cts72m00[3].lgdnum,
                                 a_cts72m00[3].lgdcep,
                                 a_cts72m00[3].lgdcepcmp,
                                 a_cts72m00[3].lclltt,
                                 a_cts72m00[3].lcllgt,
                                 a_cts72m00[3].lclrefptotxt,
                                 a_cts72m00[3].lclcttnom,
                                 a_cts72m00[3].dddcod,
                                 a_cts72m00[3].lcltelnum,
                                 a_cts72m00[3].c24lclpdrcod,
                                 a_cts72m00[3].ofnnumdig,
                                 a_cts72m00[3].celteldddcod   ,
                                 a_cts72m00[3].celtelnum,
                                 a_cts72m00[3].endcmp,
                                 ws.retflg,
                                 hist_cts72m00.*, a_cts72m00[3].emeviacod
                end if    #---<<<  Endereco de correspondencia - PSI SPR-2014-28503
             end if

             #---------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #---------------------------------------------------------------
             if g_documento.lclocodesres = "S" then
                let w_cts72m00.atdrsdflg = "S"
             else
                let w_cts72m00.atdrsdflg = "N"
             end if

             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts72m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts72m00[1].brrnom,
                                            a_cts72m00[1].lclbrrnom)
                  returning a_cts72m00[1].lclbrrnom

             let a_cts72m00[1].lgdtxt = a_cts72m00[1].lgdtip clipped, " ",
                                        a_cts72m00[1].lgdnom clipped, " ",
                                        a_cts72m00[1].lgdnum using "<<<<#"

             if a_cts72m00[1].cidnom is not null and
                a_cts72m00[1].ufdcod is not null then
                call cts14g00 (g_documento.c24astcod,
                               "","","","",
                               a_cts72m00[1].cidnom,
                               a_cts72m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts72m00[1].lgdtxt
             display by name a_cts72m00[1].lclbrrnom
             display by name a_cts72m00[1].endzon
             display by name a_cts72m00[1].cidnom
             display by name a_cts72m00[1].ufdcod
             display by name a_cts72m00[1].lclrefptotxt
             display by name a_cts72m00[1].lclcttnom
             display by name a_cts72m00[1].dddcod
             display by name a_cts72m00[1].lcltelnum
             display by name a_cts72m00[1].celteldddcod
             display by name a_cts72m00[1].celtelnum
             display by name a_cts72m00[1].endcmp

             let w_cts72m00.atdocrcidnom = a_cts72m00[1].cidnom
             let w_cts72m00.atdocrufdcod = a_cts72m00[1].ufdcod

             if  w_cts72m00.atddmccidnom = w_cts72m00.atdocrcidnom  and
                 w_cts72m00.atddmcufdcod = w_cts72m00.atdocrufdcod  then
                 call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                               "A LOCAL DE DOMICILIO!","") returning ws.confirma
                 if  ws.confirma = "N"  then
                     next field refatdsrvorg
                 end if
             end if

             if  ws.retflg = "N"  then
                 error " Dados referentes ao local incorretos ou nao preenchidos!"
                 next field refatdsrvorg
             end if

             if  mr_cts72m00.asitipcod = 10  then  ###  Passagem Aerea
                 display by name mr_cts72m00.dstcidnom
                 display by name mr_cts72m00.dstufdcod
             else
                let l_lclltt = a_cts72m00[2].lclltt   #-- PSI SPR-2014-28503
                let l_lcllgt = a_cts72m00[2].lcllgt   #-- PSI SPR-2014-28503

                let a_cts72m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                #DIGITAÇÃO PADRONIZADA DE ENDEREÇOS
                let m_acesso_ind = false
                let m_atdsrvorg = 2
                call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                     returning m_acesso_ind

                if m_acesso_ind = false then
                   call cts06g03(2,
                                 m_atdsrvorg,
                                 w_cts72m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod   ,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod)
                       returning a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod   ,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod
                else
                   call cts06g11(2,
                                 m_atdsrvorg,
                                 w_cts72m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod   ,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod)
                       returning a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod   ,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod
                end if

                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                let m_subbairro[2].lclbrrnom = a_cts72m00[2].lclbrrnom
                call cts06g10_monta_brr_subbrr(a_cts72m00[2].brrnom,
                                               a_cts72m00[2].lclbrrnom)
                     returning a_cts72m00[2].lclbrrnom

                let a_cts72m00[2].lgdtxt = a_cts72m00[2].lgdtip clipped, " ",
                                           a_cts72m00[2].lgdnom clipped, " ",
                                           a_cts72m00[2].lgdnum using "<<<<#"

                let mr_cts72m00.dstlcl    = a_cts72m00[2].lclidttxt
                let mr_cts72m00.dstlgdtxt = a_cts72m00[2].lgdtxt
                let mr_cts72m00.dstbrrnom = a_cts72m00[2].lclbrrnom
                let mr_cts72m00.dstcidnom = a_cts72m00[2].cidnom
                let mr_cts72m00.dstufdcod = a_cts72m00[2].ufdcod

                if  a_cts72m00[2].lclltt <> l_lclltt or
                    a_cts72m00[2].lcllgt <> l_lcllgt or
                    (l_lclltt is null and a_cts72m00[2].lclltt is not null) or
                    (l_lcllgt is null and a_cts72m00[2].lcllgt is not null) then

                    call cts00m33(1,
                             a_cts72m00[1].lclltt,
                             a_cts72m00[1].lcllgt,
                             a_cts72m00[2].lclltt,
                             a_cts72m00[2].lcllgt)
                end if

                if a_cts72m00[2].cidnom is not null and
                   a_cts72m00[2].ufdcod is not null then
                   call cts14g00 (g_documento.c24astcod,
                                  "","","","",
                                  a_cts72m00[2].cidnom,
                                  a_cts72m00[2].ufdcod,
                                  "S",
                                  ws.dtparam)
                end if
                display by name mr_cts72m00.dstlcl   ,
                                mr_cts72m00.dstlgdtxt,
                                mr_cts72m00.dstbrrnom,
                                mr_cts72m00.dstcidnom,
                                mr_cts72m00.dstufdcod

                if  ws.retflg = "N"  then
                    error " Dados referentes ao local incorretos ou nao",
                          " preenchidos!"
                    next field refatdsrvano #- SPR-2015-15533-Fechamento GPS
                end if
             end if

            error " Informe a relacao de passageiros!"
            call cts11m01 (a_passag[01].*,
                           a_passag[02].*,
                           a_passag[03].*,
                           a_passag[04].*,
                           a_passag[05].*,
                           a_passag[06].*,
                           a_passag[07].*,
                           a_passag[08].*,
                           a_passag[09].*,
                           a_passag[10].*,
                           a_passag[11].*,
                           a_passag[12].*,
                           a_passag[13].*,
                           a_passag[14].*,
                           a_passag[15].*)
                 returning a_passag[01].*,
                           a_passag[02].*,
                           a_passag[03].*,
                           a_passag[04].*,
                           a_passag[05].*,
                           a_passag[06].*,
                           a_passag[07].*,
                           a_passag[08].*,
                           a_passag[09].*,
                           a_passag[10].*,
                           a_passag[11].*,
                           a_passag[12].*,
                           a_passag[13].*,
                           a_passag[14].*,
                           a_passag[15].*

          before field imdsrvflg
                 if  mr_cts72m00.asitipcod <> 5  then

                     let mr_cts72m00.imdsrvflg    = "S"
                     let w_cts72m00.atdpvtretflg = "S"
                     let w_cts72m00.atdhorpvt    = "00:00"
                     let mr_cts72m00.atdprinvlcod = 2

                     select cpodes
                       into mr_cts72m00.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts72m00.atdprinvlcod

                     initialize w_cts72m00.atddatprg to null
                     initialize w_cts72m00.atdhorprg to null

                     display by name mr_cts72m00.imdsrvflg
                     display by name mr_cts72m00.atdprinvlcod
                     display by name mr_cts72m00.atdprinvldes

                     if  fgl_lastkey() = fgl_keyval("up")    or
                         fgl_lastkey() = fgl_keyval("left")  then
                         next field refatdsrvano # SPR-2015-15533-Fechamento GPS
                     else
                         next field atdlibflg
                     end if
                 else
                     display by name mr_cts72m00.imdsrvflg  attribute (reverse)
                 end if

          after  field imdsrvflg
                 display by name mr_cts72m00.imdsrvflg

                 # PSI-2013-00440PR
                 if (m_imdsrvflg is null) or (m_imdsrvflg != mr_cts72m00.imdsrvflg)
                    then
                    let m_rsrchv = null
                    let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
                 end if

                 if (m_cidnom != a_cts72m00[1].cidnom) or
                    (m_ufdcod != a_cts72m00[1].ufdcod) then
                    let m_altcidufd = true
                    let m_operacao = 0  # regular novamente
                    #display 'cts72m00 - Elegivel para regulacao, alterou cidade/uf'
                 else
                    let m_altcidufd = false
                 end if

                 # na inclusao dados nulos, igualar aos digitados
                 if m_imdsrvflg is null then
                    let m_imdsrvflg = mr_cts72m00.imdsrvflg
                 end if

                 if m_cidnom is null then
                    let m_cidnom = a_cts72m00[1].cidnom
                 end if

                 if m_ufdcod is null then
                    let m_ufdcod = a_cts72m00[1].ufdcod
                 end if

                 # Envia a chave antiga no input quando alteracao.
                 # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou
                 # novamente manda a mesma pra ver se ainda e valida
                 if g_documento.acao = "ALT"
                    then
                    let m_rsrchv = m_rsrchvant
                 end if
                 # PSI-2013-00440PR

                 if  fgl_lastkey() <> fgl_keyval("up")    and
                     fgl_lastkey() <> fgl_keyval("left")  then
                     if  mr_cts72m00.imdsrvflg is null   then
                         error " Servico imediato e' item obrigatorio!"
                         next field imdsrvflg
                     else
                         if  mr_cts72m00.imdsrvflg <> "S"  and
                             mr_cts72m00.imdsrvflg <> "N"  then
                             error " Informe (S)im ou (N)ao!"
                             next field imdsrvflg
                         end if
                     end if

                     # PREVISAO PARA TERMINO DO SERVIÇO
                     # Considerado que todas as regras de negocio sobre a questao da regulacao
                     # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
                     if m_agendaw = true
                        then
                        # obter a chave de regulacao no AW
                         ##-- SPR-2015-15533 - Inicio
                        call cts72m00_descpbm()
		          	           returning g_documento.atddfttxt

                        let g_documento.c24pbmcod    = 1001
                        let g_documento.asitipcod    = mr_cts72m00.asitipcod
                        let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
                        let g_documento.socntzdes    = null
                        ##-- SPR-2015-15533 - Fim
                        call cts02m08(w_cts72m00.atdfnlflg,
                                      mr_cts72m00.imdsrvflg,
                                      m_altcidufd,
                                      "N", #- mr_cts72m00.prslocflg - SPR-2015-15533
                                      w_cts72m00.atdhorpvt,
                                      w_cts72m00.atddatprg,
                                      w_cts72m00.atdhorprg,
                                      w_cts72m00.atdpvtretflg,
                                      m_rsrchv,
                                      m_operacao,
                                      "",
                                      a_cts72m00[1].cidnom,
                                      a_cts72m00[1].ufdcod,
                                      "",   # codigo de assistencia, nao existe no Ct24h
                                      mr_cts72m00.vclcoddig,
                                      m_ctgtrfcod,
                                      mr_cts72m00.imdsrvflg,
                                      a_cts72m00[1].c24lclpdrcod,
                                      a_cts72m00[1].lclltt,
                                      a_cts72m00[1].lcllgt,
                                      g_documento.ciaempcod,
                                      g_documento.atdsrvorg,
                                      mr_cts72m00.asitipcod,
                                      "",   # natureza nao tem, identifica pelo asitipcod
                                      "")   # sub-natureza nao tem, identifica pelo asitipcod
                            returning w_cts72m00.atdhorpvt,
                                      w_cts72m00.atddatprg,
                                      w_cts72m00.atdhorprg,
                                      w_cts72m00.atdpvtretflg,
                                      mr_cts72m00.imdsrvflg,
                                      m_rsrchv,
                                      m_operacao,
                                      m_altdathor

                        display by name mr_cts72m00.imdsrvflg

                        if int_flag
                           then
                           let int_flag = false
                           next field imdsrvflg
                        end if

                     else  # regulação antiga

                        call cts02m03(w_cts72m00.atdfnlflg,
                                      mr_cts72m00.imdsrvflg,
                                      w_cts72m00.atdhorpvt,
                                      w_cts72m00.atddatprg,
                                      w_cts72m00.atdhorprg,
                                      w_cts72m00.atdpvtretflg)
                            returning w_cts72m00.atdhorpvt,
                                      w_cts72m00.atddatprg,
                                      w_cts72m00.atdhorprg,
                                      w_cts72m00.atdpvtretflg


                        if  mr_cts72m00.imdsrvflg = "S"  then
                            if  w_cts72m00.atdhorpvt is null  then
                                error " Previsao (em horas) nao informada para servico",
                                      " imediato!"
                                next field imdsrvflg
                            end if
                        else
                            if  w_cts72m00.atddatprg   is null        or
                                w_cts72m00.atdhorprg   is null        then
                                error " Faltam dados para servico programado!"
                                next field imdsrvflg
                            else
                                let mr_cts72m00.atdprinvlcod  = 2

                                select cpodes
                                  into mr_cts72m00.atdprinvldes
                                  from iddkdominio
                                 where cponom = "atdprinvlcod"
                                   and cpocod = mr_cts72m00.atdprinvlcod

                                 display by name mr_cts72m00.atdprinvlcod
                                 display by name mr_cts72m00.atdprinvldes

                                 next field atdlibflg
                            end if
                        end if
                     end if
                 end if

          before field atdprinvlcod
                 let mr_cts72m00.atdprinvlcod = 2
                 display by name mr_cts72m00.atdprinvlcod attribute (reverse)


          after  field atdprinvlcod
                 display by name mr_cts72m00.atdprinvlcod

                 if  fgl_lastkey() <> fgl_keyval("up")   and
                     fgl_lastkey() <> fgl_keyval("left") then
                     if mr_cts72m00.atdprinvlcod is null then
                        error " Nivel de prioridade deve ser informado!"
                        next field atdprinvlcod
                     end if

                     select cpodes
                       into mr_cts72m00.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts72m00.atdprinvlcod

                     if  sqlca.sqlcode = notfound then
                         error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal",
                               " ou (3)-Urgente"
                         next field atdprinvlcod
                     end if

                     display by name mr_cts72m00.atdprinvldes
                 end if

          before field atdlibflg
                 display by name mr_cts72m00.atdlibflg attribute (reverse)

                 if  g_documento.atdsrvnum is not null  and
                     w_cts72m00.atdfnlflg  =  "S"       then
                     exit input
                 end if

          after  field atdlibflg
                 display by name mr_cts72m00.atdlibflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field atdprinvlcod
                 end if

                 if  mr_cts72m00.atdlibflg is null then
                     error " Envio liberado deve ser informado!"
                     next field atdlibflg
                 end if

                 if  mr_cts72m00.atdlibflg <> "S"  and
                     mr_cts72m00.atdlibflg <> "N"  then
                     error " Informe (S)im ou (N)ao!"
                     next field atdlibflg
                 end if

                 let w_cts72m00.atdlibflg = mr_cts72m00.atdlibflg

                 if  w_cts72m00.atdlibflg is null   then
                     next field atdlibflg
                 end if

                 display by name mr_cts72m00.atdlibflg

                 if  mr_cts72m00.asitipcod = 10  then
                     call cts11m08(w_cts72m00.trppfrdat,
                                   w_cts72m00.trppfrhor)
                         returning w_cts72m00.trppfrdat,
                                   w_cts72m00.trppfrhor

                     if  w_cts72m00.trppfrdat is null  then
                         call cts08g01("C","S","","NAO FOI PREENCHIDO NENHUMA",
                                       "PREFERENCIA DE VIAGEM!","")
                              returning ws.confirma
                         if  ws.confirma = "N"  then
                             next field atdlibflg
                         end if
                     end if
                 end if

                 if  w_cts72m00.antlibflg is null  then
                     if  w_cts72m00.atdlibflg = "S"  then
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let mr_cts72m00.atdlibhor = l_hora2
                         let mr_cts72m00.atdlibdat = l_data
                     else
                         let mr_cts72m00.atdlibflg = "N"
                         display by name mr_cts72m00.atdlibflg
                         initialize mr_cts72m00.atdlibhor to null
                         initialize mr_cts72m00.atdlibdat to null
                     end if
                 else
                     select atdfnlflg
                       from datmservico
                      where atdsrvnum = g_documento.atdsrvnum  and
                            atdsrvano = g_documento.atdsrvano  and
                            atdfnlflg in ("N","A")

                     if  sqlca.sqlcode = notfound  then
                         error " Servico ja' acionado nao pode ser alterado!"
                         let m_srv_acionado = true
                         call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                           " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                               "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                              returning ws.confirma
                         next field atdlibflg
                     end if

                     if  w_cts72m00.antlibflg = "S"  then
                         if  w_cts72m00.atdlibflg = "S"  then
                             exit input
                         else
                             error " A liberacao do servico nao pode ser cancelada!"
                             next field atdlibflg
                             let mr_cts72m00.atdlibflg = "N"
                             display by name mr_cts72m00.atdlibflg
                             initialize mr_cts72m00.atdlibhor to null
                             initialize mr_cts72m00.atdlibdat to null
                             error " Liberacao do servico cancelada!"
                             sleep 1
                             exit input
                         end if
                     else
                         if  w_cts72m00.antlibflg = "N"  then
                             if  w_cts72m00.atdlibflg = "N"  then
                                 exit input
                             else
                                 call cts40g03_data_hora_banco(2)
                                      returning l_data, l_hora2
                                 let mr_cts72m00.atdlibhor = l_hora2
                                 let mr_cts72m00.atdlibdat = l_data
                                 exit input
                             end if
                         end if
                     end if
                 end if

                 initialize w_cts72m00.hora     ,
                                    w_cts72m00.data     ,
                                    w_cts72m00.funmat   ,
                                    w_cts72m00.cnldat   ,
                                    w_cts72m00.atdfnlhor,
                                    w_cts72m00.c24opemat,
                                    w_cts72m00.atdfnlflg,
                                    w_cts72m00.atdetpcod,
                                    w_cts72m00.atdcstvlr,
                                    w_cts72m00.atdprscod to null

                 while true
                     if  a_passag[01].pasnom is null  or
                         a_passag[01].pasidd is null  then
                         error " Informe a relacao de passageiros!"
                         call cts11m01 (a_passag[01].*,
                                        a_passag[02].*,
                                        a_passag[03].*,
                                        a_passag[04].*,
                                        a_passag[05].*,
                                        a_passag[06].*,
                                        a_passag[07].*,
                                        a_passag[08].*,
                                        a_passag[09].*,
                                        a_passag[10].*,
                                        a_passag[11].*,
                                        a_passag[12].*,
                                        a_passag[13].*,
                                        a_passag[14].*,
                                        a_passag[15].*)
                            returning   a_passag[01].*,
                                        a_passag[02].*,
                                        a_passag[03].*,
                                        a_passag[04].*,
                                        a_passag[05].*,
                                        a_passag[06].*,
                                        a_passag[07].*,
                                        a_passag[08].*,
                                        a_passag[09].*,
                                        a_passag[10].*,
                                        a_passag[11].*,
                                        a_passag[12].*,
                                        a_passag[13].*,
                                        a_passag[14].*,
                                        a_passag[15].*
                     else
                        exit while
                     end if
                 end while

                 if  mr_cts72m00.asimtvcod = 3  then
                     while true
                         for arr_aux = 1 to 15
                             if  a_passag[arr_aux].pasnom is null  or
                                 a_passag[arr_aux].pasidd is null  then
                                 exit for
                             end if
                         end for
                         if  arr_aux > 1  then
                             call cts08g01("A","S","","PARA RECUPERACAO DE VEICULO, SO'",
                                           "E' PERMITIDO UM UNICO PASSAGEIRO!","")
                                  returning ws.confirma

                             if  ws.confirma = "S"  then
                                 exit while
                             else
                                 call cts11m01 (a_passag[01].*,
                                                a_passag[02].*,
                                                a_passag[03].*,
                                                a_passag[04].*,
                                                a_passag[05].*,
                                                a_passag[06].*,
                                                a_passag[07].*,
                                                a_passag[08].*,
                                                a_passag[09].*,
                                                a_passag[10].*,
                                                a_passag[11].*,
                                                a_passag[12].*,
                                                a_passag[13].*,
                                                a_passag[14].*,
                                                a_passag[15].*)
                                    returning   a_passag[01].*,
                                                a_passag[02].*,
                                                a_passag[03].*,
                                                a_passag[04].*,
                                                a_passag[05].*,
                                                a_passag[06].*,
                                                a_passag[07].*,
                                                a_passag[08].*,
                                                a_passag[09].*,
                                                a_passag[10].*,
                                                a_passag[11].*,
                                                a_passag[12].*,
                                                a_passag[13].*,
                                                a_passag[14].*,
                                                a_passag[15].*
                             end if
                         end if
                     end while
                 end if

          on key (interrupt)
             if  g_documento.atdsrvnum  is null   then
                 if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                              "","") = "S"  then
                    call opsfa006_inicializa() #--- PSI SPR-2014-28503-Incializa variaveis VENDA (OPSFA006) # <<<---
                    let int_flag = true
                    exit input
                 end if
             else
                 exit input
             end if

          on key (control-f) #=> SPR-2014-28503 - DEFINE TECLAS DE FUNCAO
              call opsfa009(mr_teclas.*)

          on key (F1)
             if  g_documento.c24astcod is not null then
                 call ctc58m00_vis(g_documento.c24astcod)
             end if

          on key (F5)
             #=> SPR-2014-28503 - FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
             if g_documento.acao = "INC" then
                error "Funcionalidade Indisponivel no momento da Inclusao!" sleep 3
             else
                if m_vendaflg       or
                   cty27g00_ret = 1 then  #=> PERMITE F.PAGTO (SEM VENDA=CONSULTA)


              #josiane - grava endereço correspondencia

              #--->>> Endereco de correspondencia - PSI SPR-2014-28503
                whenever error continue
                 select 1 from datmlcl
                  where atdsrvnum = g_documento.atdsrvnum
                    and atdsrvano = g_documento.atdsrvano
                    and c24endtip = 7
              whenever error stop
              if sqlca.sqlcode = 100 then

                call cts08g01("A","S","O ENDERECO DE CORRESPONDENCIA SERA ",
                              "O MESMO DE OCORRENCIA?","", "")
                    returning l_resultado

                if l_resultado = "S" then #- Endereco corresp - SPR-2014-28503
                   let a_cts72m00[2].lclidttxt    = a_cts72m00[1].lclidttxt
                   let a_cts72m00[2].cidnom       = a_cts72m00[1].cidnom
                   let a_cts72m00[2].ufdcod       = a_cts72m00[1].ufdcod
                   let a_cts72m00[2].brrnom       = a_cts72m00[1].brrnom
                   let a_cts72m00[2].lclbrrnom    = a_cts72m00[1].lclbrrnom
                   let a_cts72m00[2].endzon       = a_cts72m00[1].endzon
                   let a_cts72m00[2].lgdtip       = a_cts72m00[1].lgdtip
                   let a_cts72m00[2].lgdnom       = a_cts72m00[1].lgdnom
                   let a_cts72m00[2].lgdnum       = a_cts72m00[1].lgdnum
                   let a_cts72m00[2].lgdcep       = a_cts72m00[1].lgdcep
                   let a_cts72m00[2].lgdcepcmp    = a_cts72m00[1].lgdcepcmp
                   let a_cts72m00[2].lclltt       = a_cts72m00[1].lclltt
                   let a_cts72m00[2].lcllgt       = a_cts72m00[1].lcllgt
                   let a_cts72m00[2].lclrefptotxt = a_cts72m00[1].lclrefptotxt
                   let a_cts72m00[2].lclcttnom    = a_cts72m00[1].lclcttnom
                   let a_cts72m00[2].dddcod       = a_cts72m00[1].dddcod
                   let a_cts72m00[2].lcltelnum    = a_cts72m00[1].lcltelnum
                   let a_cts72m00[2].c24lclpdrcod = a_cts72m00[1].c24lclpdrcod
                   let a_cts72m00[2].ofnnumdig    = a_cts72m00[1].ofnnumdig
                   let a_cts72m00[2].celteldddcod = a_cts72m00[1].celteldddcod
                   let a_cts72m00[2].celtelnum    = a_cts72m00[1].celtelnum
                   let a_cts72m00[2].endcmp       = a_cts72m00[1].endcmp
                else
                   call cts06g03(7,
                                 13,
                                 w_cts72m00.ligcvntip,
                                 aux_today,
                                 aux_hora,
                                 a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod)
                       returning a_cts72m00[2].lclidttxt,
                                 a_cts72m00[2].cidnom,
                                 a_cts72m00[2].ufdcod,
                                 a_cts72m00[2].brrnom,
                                 a_cts72m00[2].lclbrrnom,
                                 a_cts72m00[2].endzon,
                                 a_cts72m00[2].lgdtip,
                                 a_cts72m00[2].lgdnom,
                                 a_cts72m00[2].lgdnum,
                                 a_cts72m00[2].lgdcep,
                                 a_cts72m00[2].lgdcepcmp,
                                 a_cts72m00[2].lclltt,
                                 a_cts72m00[2].lcllgt,
                                 a_cts72m00[2].lclrefptotxt,
                                 a_cts72m00[2].lclcttnom,
                                 a_cts72m00[2].dddcod,
                                 a_cts72m00[2].lcltelnum,
                                 a_cts72m00[2].c24lclpdrcod,
                                 a_cts72m00[2].ofnnumdig,
                                 a_cts72m00[2].celteldddcod,
                                 a_cts72m00[2].celtelnum,
                                 a_cts72m00[2].endcmp,
                                 ws.retflg,
                                 hist_cts72m00.*, a_cts72m00[2].emeviacod
                                 #display "ws.retflg = ",ws.retflg
                end if   #---<<<  Endereco de correspondencia - SPR-2014-28503



                #-----------------------------------
                # Grava locais de correspondencia
                #-----------------------------------
               begin work

                  if a_cts72m00[2].operacao is null then
                     let a_cts72m00[2].operacao = "I"
                  end if

                  let a_cts72m00[2].lclbrrnom = m_subbairro[2].lclbrrnom


                  let ws.sqlcode = cts06g07_local( a_cts72m00[2].operacao    ,
                                                   g_documento.atdsrvnum      ,
                                                   g_documento.atdsrvano      ,
                                                   7,    #--- Tp Endereco correspondencia
                                                   a_cts72m00[2].lclidttxt   ,
                                                   a_cts72m00[2].lgdtip      ,
                                                   a_cts72m00[2].lgdnom      ,
                                                   a_cts72m00[2].lgdnum      ,
                                                   a_cts72m00[2].lclbrrnom   ,
                                                   a_cts72m00[2].brrnom      ,
                                                   a_cts72m00[2].cidnom      ,
                                                   a_cts72m00[2].ufdcod      ,
                                                   a_cts72m00[2].lclrefptotxt,
                                                   a_cts72m00[2].endzon      ,
                                                   a_cts72m00[2].lgdcep      ,
                                                   a_cts72m00[2].lgdcepcmp   ,
                                                   a_cts72m00[2].lclltt      ,
                                                   a_cts72m00[2].lcllgt      ,
                                                   a_cts72m00[2].dddcod      ,
                                                   a_cts72m00[2].lcltelnum   ,
                                                   a_cts72m00[2].lclcttnom   ,
                                                   a_cts72m00[2].c24lclpdrcod,
                                                   a_cts72m00[2].ofnnumdig,
                                                   a_cts72m00[2].emeviacod   ,
                                                   a_cts72m00[2].celteldddcod,
                                                   a_cts72m00[2].celtelnum   ,
                                                   a_cts72m00[2].endcmp )


               commit work
            end if
            #fim josiane - grava endereço correspondencia


                   if not opsfa006_altera(g_documento.atdsrvnum
                                         ,g_documento.atdsrvano
                                         ,g_documento.prpnum
                                         ,m_pbmonline       #- SPR-2014-28503
                                         ,0 #- Distancia Ocorr X Destino - SPR-2015-13708
                                         ,w_cts72m00.atddat #- SPR-2015-13708
                                         ,"N" #- Prest.local - SPR-2015-15533
                                         ,mr_cts72m00.nom   #- SPR-2015-11582
                                         ,mr_cts72m00.nscdat) then #- SPR-2015-11582
                      let int_flag = true
                      exit input
                   end if
                else
                   error "Nao possui Venda/F.Pagto associados..."  sleep 3
                end if
             end if


          on key (F6)
             if  g_documento.atdsrvnum is null  or
                 g_documento.atdsrvano is null  then
                 call cts10m02 (hist_cts72m00.*) returning hist_cts72m00.*
             else
                 let l_acaoslv = g_documento.acao #=> SPR-2014-28503
                 call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                               g_issk.funmat, w_cts72m00.data, w_cts72m00.hora)
                 let g_documento.acao = l_acaoslv #=> SPR-2014-28503
             end if

          on key (F7)
             call ctx14g00("Funcoes","Impressao|Distancia|Destino")
                  returning ws.opcao,
                            ws.opcaodes
             case ws.opcao
                when 1  ### Impressao
                     if  g_documento.atdsrvnum is null  or
                         g_documento.atdsrvano is null  then
                         error " Impressao somente com cadastramento do servico!"
                     else
                         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
                     end if

                 when 2   #### Distancia QTH-QTI
                     call cts00m33(1,
                                   a_cts72m00[1].lclltt,
                                   a_cts72m00[1].lcllgt,
                                   a_cts72m00[2].lclltt,
                                   a_cts72m00[2].lcllgt)

                 when 3   #### Destino
                     if g_documento.atdsrvnum is null  or
                        g_documento.atdsrvano is null  then
                        error " Servico nao cadastrado!"
                     else
                        let a_cts72m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                        let m_acesso_ind = false
                        let l_atdsrvorg = 7
                        call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                             returning m_acesso_ind

                        #Projeto alteracao cadastro de destino
                        if g_documento.acao = "ALT" then

                           call cts72m00_bkp_info_dest(1, hist_cts72m00.*)
                              returning hist_cts72m00.*

                        end if

                        if m_acesso_ind = false then
                           call cts06g03(2,
                                         l_atdsrvorg,
                                         w_cts72m00.ligcvntip,
                                         aux_today,
                                         aux_hora,
                                         a_cts72m00[2].lclidttxt,
                                         a_cts72m00[2].cidnom,
                                         a_cts72m00[2].ufdcod,
                                         a_cts72m00[2].brrnom,
                                         a_cts72m00[2].lclbrrnom,
                                         a_cts72m00[2].endzon,
                                         a_cts72m00[2].lgdtip,
                                         a_cts72m00[2].lgdnom,
                                         a_cts72m00[2].lgdnum,
                                         a_cts72m00[2].lgdcep,
                                         a_cts72m00[2].lgdcepcmp,
                                         a_cts72m00[2].lclltt,
                                         a_cts72m00[2].lcllgt,
                                         a_cts72m00[2].lclrefptotxt,
                                         a_cts72m00[2].lclcttnom,
                                         a_cts72m00[2].dddcod,
                                         a_cts72m00[2].lcltelnum,
                                         a_cts72m00[2].c24lclpdrcod,
                                         a_cts72m00[2].ofnnumdig,
                                         a_cts72m00[2].celteldddcod   ,
                                         a_cts72m00[2].celtelnum,
                                         a_cts72m00[2].endcmp,
                                         hist_cts72m00.*,
                                         a_cts72m00[2].emeviacod)
                               returning a_cts72m00[2].lclidttxt,
                                         a_cts72m00[2].cidnom,
                                         a_cts72m00[2].ufdcod,
                                         a_cts72m00[2].brrnom,
                                         a_cts72m00[2].lclbrrnom,
                                         a_cts72m00[2].endzon,
                                         a_cts72m00[2].lgdtip,
                                         a_cts72m00[2].lgdnom,
                                         a_cts72m00[2].lgdnum,
                                         a_cts72m00[2].lgdcep,
                                         a_cts72m00[2].lgdcepcmp,
                                         a_cts72m00[2].lclltt,
                                         a_cts72m00[2].lcllgt,
                                         a_cts72m00[2].lclrefptotxt,
                                         a_cts72m00[2].lclcttnom,
                                         a_cts72m00[2].dddcod,
                                         a_cts72m00[2].lcltelnum,
                                         a_cts72m00[2].c24lclpdrcod,
                                         a_cts72m00[2].ofnnumdig,
                                         a_cts72m00[2].celteldddcod   ,
                                         a_cts72m00[2].celtelnum,
                                         a_cts72m00[2].endcmp,
                                         ws.retflg,
                                         hist_cts72m00.*,
                                         a_cts72m00[2].emeviacod
                        else
                           call cts06g11(2,
                                         l_atdsrvorg,
                                         w_cts72m00.ligcvntip,
                                         aux_today,
                                         aux_hora,
                                         a_cts72m00[2].lclidttxt,
                                         a_cts72m00[2].cidnom,
                                         a_cts72m00[2].ufdcod,
                                         a_cts72m00[2].brrnom,
                                         a_cts72m00[2].lclbrrnom,
                                         a_cts72m00[2].endzon,
                                         a_cts72m00[2].lgdtip,
                                         a_cts72m00[2].lgdnom,
                                         a_cts72m00[2].lgdnum,
                                         a_cts72m00[2].lgdcep,
                                         a_cts72m00[2].lgdcepcmp,
                                         a_cts72m00[2].lclltt,
                                         a_cts72m00[2].lcllgt,
                                         a_cts72m00[2].lclrefptotxt,
                                         a_cts72m00[2].lclcttnom,
                                         a_cts72m00[2].dddcod,
                                         a_cts72m00[2].lcltelnum,
                                         a_cts72m00[2].c24lclpdrcod,
                                         a_cts72m00[2].ofnnumdig,
                                         a_cts72m00[2].celteldddcod   ,
                                         a_cts72m00[2].celtelnum,
                                         a_cts72m00[2].endcmp,
                                         hist_cts72m00.*,
                                         a_cts72m00[2].emeviacod)
                               returning a_cts72m00[2].lclidttxt,
                                         a_cts72m00[2].cidnom,
                                         a_cts72m00[2].ufdcod,
                                         a_cts72m00[2].brrnom,
                                         a_cts72m00[2].lclbrrnom,
                                         a_cts72m00[2].endzon,
                                         a_cts72m00[2].lgdtip,
                                         a_cts72m00[2].lgdnom,
                                         a_cts72m00[2].lgdnum,
                                         a_cts72m00[2].lgdcep,
                                         a_cts72m00[2].lgdcepcmp,
                                         a_cts72m00[2].lclltt,
                                         a_cts72m00[2].lcllgt,
                                         a_cts72m00[2].lclrefptotxt,
                                         a_cts72m00[2].lclcttnom,
                                         a_cts72m00[2].dddcod,
                                         a_cts72m00[2].lcltelnum,
                                         a_cts72m00[2].c24lclpdrcod,
                                         a_cts72m00[2].ofnnumdig,
                                         a_cts72m00[2].celteldddcod   ,
                                         a_cts72m00[2].celtelnum,
                                         a_cts72m00[2].endcmp,
                                         ws.retflg,
                                         hist_cts72m00.*,
                                         a_cts72m00[2].emeviacod
                        end if

                        #Projeto alteracao cadastro de destino
                        let m_grava_hist = false

                        if g_documento.acao = "ALT" then

                           call cts72m00_verifica_tipo_atendim()
                              returning l_status, l_atdetpcod

                           if l_status = 0 then

                              if l_atdetpcod = 4 then

                                 let ws.confirma = null
                                 while ws.confirma = " " or
                                       ws.confirma  is null

                                       call cts08g01("C","S",""
                                                    ,"ALTERAR ENDERECO DE DESTINO? "
                                                    ,"","")
                                          returning ws.confirma
                                 end while

                                 if ws.confirma = "S" then

                                    let l_status = null
                                    call cts72m00_verifica_op_ativa()
                                       returning l_status

                                    if l_status then

                                       error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                                       error " Servico ja' acionado nao pode ser alterado!"
                                       let m_srv_acionado = true

                                       # CASO O SERVIÇO JÁ ESTEJA ACIONADO
                                       call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                     " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                     "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                                           returning ws.confirma

                                       # PREVISAO PARA TERMINO DO SERVIÇO
                                       # INICIO PSI-2013-00440PR
				                           if m_agendaw = false
                                          then
                                          call cts02m03(w_cts72m00.atdfnlflg,
                                                        mr_cts72m00.imdsrvflg,
                                                        w_cts72m00.atdhorpvt,
                                                        w_cts72m00.atddatprg,
                                                        w_cts72m00.atdhorprg,
                                                        w_cts72m00.atdpvtretflg)
                                              returning w_cts72m00.atdhorpvt,
                                                        w_cts72m00.atddatprg,
                                                        w_cts72m00.atdhorprg,
                                                        w_cts72m00.atdpvtretflg
				                           else
				                           	      ##-- SPR-2015-15533 - Inicio
				                           	      call cts72m00_descpbm()
		          	                                   returning g_documento.atddfttxt

                                          let g_documento.c24pbmcod    = 1001
                                          let g_documento.asitipcod    = mr_cts72m00.asitipcod
                                          let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
                                          let g_documento.socntzdes    = null
                                          ##-- SPR-2015-15533 - Fim
                                          call cts02m08(w_cts72m00.atdfnlflg,
                                                        mr_cts72m00.imdsrvflg,
                                                        m_altcidufd,
                                                        "N", #- mr_cts72m00.prslocflg - SPR-2015-15533
                                                        w_cts72m00.atdhorpvt,
                                                        w_cts72m00.atddatprg,
                                                        w_cts72m00.atdhorprg,
                                                        w_cts72m00.atdpvtretflg,
                                                        m_rsrchvant,
                                                        m_operacao,
                                                        "",
                                                        a_cts72m00[1].cidnom,
                                                        a_cts72m00[1].ufdcod,
                                                        "",   # codigo de assistencia, nao existe no Ct24h
                                                        mr_cts72m00.vclcoddig,
                                                        m_ctgtrfcod,
                                                        mr_cts72m00.imdsrvflg,
                                                        a_cts72m00[1].c24lclpdrcod,
                                                        a_cts72m00[1].lclltt,
                                                        a_cts72m00[1].lcllgt,
                                                        g_documento.ciaempcod,
                                                        g_documento.atdsrvorg,
                                                        mr_cts72m00.asitipcod,
                                                        "",   # natureza nao tem, identifica pelo asitipcod
                                                        "")   # sub-natureza nao tem, identifica pelo asitipcod
                                              returning w_cts72m00.atdhorpvt,
                                                        w_cts72m00.atddatprg,
                                                        w_cts72m00.atdhorprg,
                                                        w_cts72m00.atdpvtretflg,
                                                        mr_cts72m00.imdsrvflg,
                                                        m_rsrchv,
                                                        m_operacao,
                                                        m_altdathor
                                       end if
                                       # FIM PSI-2013-00440PR

                                       call cts72m00_bkp_info_dest(2, hist_cts72m00.*)
                                          returning hist_cts72m00.*
                                       display "PASSSEI 7777"
                                       next field atdlibflg  #-SPR-2015-15533
                                    else
                                       let m_grava_hist   = true
                                       let m_srv_acionado = false

                                       let m_subbairro[2].lclbrrnom = a_cts72m00[2].lclbrrnom
                                       call cts06g10_monta_brr_subbrr(a_cts72m00[2].brrnom,
                                                                      a_cts72m00[2].lclbrrnom)
                                          returning a_cts72m00[2].lclbrrnom

                                       let a_cts72m00[2].lgdtxt = a_cts72m00[2].lgdtip clipped, " ",
                                                                  a_cts72m00[2].lgdnom clipped, " ",
                                                                  a_cts72m00[2].lgdnum using "<<<<#"

                                       let mr_cts72m00.dstlcl    = a_cts72m00[2].lclidttxt
                                       let mr_cts72m00.dstlgdtxt = a_cts72m00[2].lgdtxt
                                       let mr_cts72m00.dstbrrnom = a_cts72m00[2].lclbrrnom
                                       let mr_cts72m00.dstcidnom = a_cts72m00[2].cidnom
                                       let mr_cts72m00.dstufdcod = a_cts72m00[2].ufdcod

                                       #--- Endereco de correspondencia - PSI SPR-2014-28503
                                       if  a_cts72m00[2].lclltt <> l_lclltt or
                                           a_cts72m00[2].lcllgt <> l_lcllgt or
                                           (l_lclltt is null and a_cts72m00[2].lclltt is not null) or
                                           (l_lcllgt is null and a_cts72m00[2].lcllgt is not null) then

                                           call cts00m33(1,
                                                         a_cts72m00[1].lclltt,
                                                         a_cts72m00[1].lcllgt,
                                                         a_cts72m00[2].lclltt,
                                                         a_cts72m00[2].lcllgt)
                                       end if


									   					 ###Moreira-Envia-QRU-GPS

                              initialize  m_mdtcod, m_pstcoddig,
                                          m_socvclcod, m_srrcoddig,
                                          l_msgaltend, l_texto,
                                          l_dtalt, l_hralt,
                                          #l_vclcordes,
                                          l_lgdtxtcl,
                                          l_ciaempnom, l_msgrtgps,
                                          l_codrtgps  to  null

                              if m_grava_hist = true then
                                 if ctx34g00_ver_acionamentoWEB(2) then

                               whenever error continue
                               if w_cts72m00.socvclcod is null then
                                  select socvclcod
                                    into w_cts72m00.socvclcod
                                    from datmsrvacp acp
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts72m00.socvclcod

                                    select datkveiculo.pstcoddig,
                                           datkveiculo.socvclcod,
                                           dattfrotalocal.srrcoddig
                                    into m_pstcoddig, m_socvclcod, m_srrcoddig
                                    from datkveiculo, dattfrotalocal
                                    where dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                    and datkveiculo.mdtcod = m_mdtcod

                                    #select cpodes
                                    #into l_vclcordes
                                    #from iddkdominio
                                    #where cponom = "vclcorcod"
                                    #and cpocod = w_cts72m00.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts72m00[2].lgdtip clipped, " ",
                                                     a_cts72m00[2].lgdnom clipped, " ",
                                                     a_cts72m00[2].lgdnum using "<<<<#", " ",
                                                     a_cts72m00[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", m_atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", mr_cts72m00.nom             clipped, " "
                                               , mr_cts72m00.vcldes          clipped, " "
                                               , mr_cts72m00.vclanomdl       clipped, " "
                                      ," QNR: ", mr_cts72m00.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts72m00[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts72m00[2].brrnom          clipped, " - "
                                               , a_cts72m00[2].cidnom          clipped, " - "
                                               , a_cts72m00[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts72m00[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts72m00[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts72m00[2].dddcod          clipped, ") "
                                               , a_cts72m00[2].lcltelnum       clipped, " "
        #                            ," Acomp: ", d_cts72m00.rmcacpflg          clipped, "#"


                                     #display "m_pstcoddig: ", m_pstcoddig
                                     #display "m_socvclcod: ", m_socvclcod
                                     #display "m_srrcoddig: ", m_srrcoddig
                                     #display "l_msgaltend: ", l_msgaltend
                                     #display "l_codrtgps : ", l_codrtgps

                                    call ctx34g02_enviar_msg_gps(m_pstcoddig,
                                                                 m_socvclcod,
                                                                 m_srrcoddig,
                                                                 l_msgaltend)
                                           returning l_msgrtgps, l_codrtgps

                                    if l_codrtgps = 0 then
                                       display "Mensagem Enviada com Sucesso ao GPS do Prestador"
                                    else
                                       display "Mensagem nao enviada. Erro: ", l_codrtgps,
                                               " - ", l_msgrtgps clipped
                                    end if
                                 end if
                              end if
                             ###Moreira-Envia-QRU-GPS

                                       exit input

                                    end if
                                 else

                                    call cts72m00_bkp_info_dest(2, hist_cts72m00.*)
                                       returning hist_cts72m00.*

                                    let m_srv_acionado = true

                                 end if
                              else
                                 let m_srv_acionado = false
                              end if

                           else
                              error 'Erro ao buscar tipo de atendimento'
                              let m_srv_acionado = true
                           end if

                           if a_cts72m00[2].cidnom is not null and
                              a_cts72m00[2].ufdcod is not null then
                              call cts14g00 (g_documento.c24astcod,
                                             "","","","",
                                             a_cts72m00[2].cidnom,
                                             a_cts72m00[2].ufdcod,
                                             "S",
                                             ws.dtparam)
                           end if
                           #Projeto alteracao cadastro de destino

                        end if
                     end if
             end case

          on key (F8)
             if  mr_cts72m00.asitipcod = 10 then
                 call cts11m08(w_cts72m00.trppfrdat,
                               w_cts72m00.trppfrhor)
                     returning w_cts72m00.trppfrdat,
                               w_cts72m00.trppfrhor
             end if

          on key (F9)
             if  g_documento.atdsrvnum is null  or
                 g_documento.atdsrvano is null  then
                 error " Servico nao cadastrado!"
             else
                 if mr_cts72m00.atdlibflg = "N"   then
                    error " Servico nao liberado!"
                 else
                    call cta00m06_acionamento(g_issk.dptsgl)
                    returning l_acesso
                   if l_acesso = true then
                      call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
                   else
                      call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
                   end if
                 end if
             end if

          on key (F10)
             call cts11m01 (a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*,
                            a_passag[06].*,
                            a_passag[07].*,
                            a_passag[08].*,
                            a_passag[09].*,
                            a_passag[10].*,
                            a_passag[11].*,
                            a_passag[12].*,
                            a_passag[13].*,
                            a_passag[14].*,
                            a_passag[15].*)
                returning   a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*,
                            a_passag[06].*,
                            a_passag[07].*,
                            a_passag[08].*,
                            a_passag[09].*,
                            a_passag[10].*,
                            a_passag[11].*,
                            a_passag[12].*,
                            a_passag[13].*,
                            a_passag[14].*,
                            a_passag[15].*

          on key (control-f)     #=> SPR-2014-28503 - TECLAS DE FUNCAO
             call opsfa009(mr_teclas.*)

          #=> SPR-2014-28503 - ACIONA A TELA DE MUDANCA DE ETAPA
          on key (control-T)
             if g_documento.atdsrvnum is null or
                g_documento.acao = "INC"      then
                error "Funcao nao disponivel na inclusao!"
                continue input
             end if
             if not m_vendaflg then
                error "Nao existe VENDA associada a este Laudo..."
                continue input
             end if
             if not opsfa005_etapas(g_documento.atdsrvnum,
                                    g_documento.atdsrvano) then
                error "ERRO AO ALTERAR ETAPA DA VENDA. ACIONE A INFORMATICA!"
                continue input
             end if

          on key(F3)
             call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

          on key (control-e)

            let lr_email.c24astcod = g_documento.c24astcod
            let lr_email.ligcvntip = g_documento.ligcvntip
            let lr_email.lignum    = g_documento.lignum
            let lr_email.atdsrvnum = g_documento.atdsrvnum
            let lr_email.atdsrvano = g_documento.atdsrvano
            let lr_email.solnom    = g_documento.solnom
            let lr_email.ramcod    = g_documento.ramcod
            call figrc072_setTratarIsolamento() -- > psi 223689
            call cts30m00(lr_email.ramcod   , lr_email.c24astcod,
                          lr_email.ligcvntip, lr_email.succod,
                          lr_email.aplnumdig, lr_email.itmnumdig,
                          lr_email.lignum   , lr_email.atdsrvnum,
                          lr_email.atdsrvano, lr_email.prporg,
                          lr_email.prpnumdig, lr_email.solnom)
                 returning l_envio
                 if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
                    error "Função cts30m00 insdisponivel no momento ! Avise a Informatica !" sleep 2
                    return
                 else
                    error "E-mail enviado com sucesso."
                 end if        -- > 223689

          on key (control-u)   #--->>>  Consulta Justificativas-SPR-2015-10068
             if g_documento.atdsrvnum is null or
                g_documento.acao = "INC"      then
                error "Funcao nao disponivel na inclusao!"
                continue input
             end if

             call opsfa003_consulta_justificativa(g_documento.atdsrvnum,
                                                  g_documento.atdsrvano)

          on key (control-o)   #--->>>  Endereco correspondencia - PSI SPR-2014-28503
             if g_documento.atdsrvnum is null or
                g_documento.acao = "INC"      then
                error "Funcao nao disponivel na inclusao!"
                continue input
             end if

             if m_pbmonline is not null then
                error "FUNCAO NAO DISPONIVEL - VENDA ONLINE NAO CONCLUIDA" sleep 2
                continue input
             end if

             # Informacoes do cliente --- SPR-2015-03912-Cadastro Clientes ---
             call opsfa014_conscadcli(g_documento.cgccpfnum,
                                      g_documento.cgcord,
                                      g_documento.cgccpfdig)
                            returning lr_retcli.coderro
                                     ,lr_retcli.msgerro
                                     ,lr_retcli.clinom
                                     ,lr_retcli.nscdat

             if lr_retcli.coderro = true then
                if (lr_retcli.clinom is null or lr_retcli.clinom = " ") and
                   (lr_retcli.nscdat is null or lr_retcli.nscdat = " ") then
                   error "ALTERACAO NAO PERMITIDA - PROCESSO DA VENDA ONLINE NAO FOI CONCLUIDO" sleep 2
                   continue input
                end if
             end if
             # --- SPR-2015-03912-Cadastro Clientes ---

             #--------------------------------------------------------------------
             # Informacoes do local da correspondencia
             #--------------------------------------------------------------------
             call ctx04g00_local_gps(g_documento.atdsrvnum,
                                     g_documento.atdsrvano,
                                     7)
                           returning a_cts72m00[3].lclidttxt
                                    ,a_cts72m00[3].lgdtip
                                    ,a_cts72m00[3].lgdnom
                                    ,a_cts72m00[3].lgdnum
                                    ,a_cts72m00[3].lclbrrnom
                                    ,a_cts72m00[3].brrnom
                                    ,a_cts72m00[3].cidnom
                                    ,a_cts72m00[3].ufdcod
                                    ,a_cts72m00[3].lclrefptotxt
                                    ,a_cts72m00[3].endzon
                                    ,a_cts72m00[3].lgdcep
                                    ,a_cts72m00[3].lgdcepcmp
                                    ,a_cts72m00[3].lclltt
                                    ,a_cts72m00[3].lcllgt
                                    ,a_cts72m00[3].dddcod
                                    ,a_cts72m00[3].lcltelnum
                                    ,a_cts72m00[3].lclcttnom
                                    ,a_cts72m00[3].c24lclpdrcod
                                    ,a_cts72m00[3].celteldddcod
                                    ,a_cts72m00[3].celtelnum
                                    ,a_cts72m00[3].endcmp
                                    ,ws.sqlcode
                                    ,a_cts72m00[3].emeviacod

             let m_subbairro[3].lclbrrnom = a_cts72m00[3].lclbrrnom

             call cts06g10_monta_brr_subbrr(a_cts72m00[3].brrnom,
                                            a_cts72m00[3].lclbrrnom)
                  returning a_cts72m00[3].lclbrrnom

             let a_cts72m00[3].lgdtxt = a_cts72m00[3].lgdtip clipped, " ",
                                        a_cts72m00[3].lgdnom clipped, " ",
                                        a_cts72m00[3].lgdnum using "<<<<#"

             let m_acesso_ind = false
             call cta00m06_acesso_indexacao_aut(g_documento.atdsrvorg)
                  returning m_acesso_ind

             if m_acesso_ind = false then
                call cts06g03(7
                             ,g_documento.atdsrvorg
                             ,w_cts72m00.ligcvntip
                             ,aux_today
                             ,aux_hora
                             ,a_cts72m00[3].lclidttxt
                             ,a_cts72m00[3].cidnom
                             ,a_cts72m00[3].ufdcod
                             ,a_cts72m00[3].brrnom
                             ,a_cts72m00[3].lclbrrnom
                             ,a_cts72m00[3].endzon
                             ,a_cts72m00[3].lgdtip
                             ,a_cts72m00[3].lgdnom
                             ,a_cts72m00[3].lgdnum
                             ,a_cts72m00[3].lgdcep
                             ,a_cts72m00[3].lgdcepcmp
                             ,a_cts72m00[3].lclltt
                             ,a_cts72m00[3].lcllgt
                             ,a_cts72m00[3].lclrefptotxt
                             ,a_cts72m00[3].lclcttnom
                             ,a_cts72m00[3].dddcod
                             ,a_cts72m00[3].lcltelnum
                             ,a_cts72m00[3].c24lclpdrcod
                             ,a_cts72m00[3].ofnnumdig
                             ,a_cts72m00[3].celteldddcod
                             ,a_cts72m00[3].celtelnum
                             ,a_cts72m00[3].endcmp
                             ,hist_cts72m00.*
                             ,a_cts72m00[3].emeviacod )
                   returning  a_cts72m00[3].lclidttxt
                             ,a_cts72m00[3].cidnom
                             ,a_cts72m00[3].ufdcod
                             ,a_cts72m00[3].brrnom
                             ,a_cts72m00[3].lclbrrnom
                             ,a_cts72m00[3].endzon
                             ,a_cts72m00[3].lgdtip
                             ,a_cts72m00[3].lgdnom
                             ,a_cts72m00[3].lgdnum
                             ,a_cts72m00[3].lgdcep
                             ,a_cts72m00[3].lgdcepcmp
                             ,a_cts72m00[3].lclltt
                             ,a_cts72m00[3].lcllgt
                             ,a_cts72m00[3].lclrefptotxt
                             ,a_cts72m00[3].lclcttnom
                             ,a_cts72m00[3].dddcod
                             ,a_cts72m00[3].lcltelnum
                             ,a_cts72m00[3].c24lclpdrcod
                             ,a_cts72m00[3].ofnnumdig
                             ,a_cts72m00[3].celteldddcod
                             ,a_cts72m00[3].celtelnum
                             ,a_cts72m00[3].endcmp
                             ,ws.retflg
                             ,hist_cts72m00.*
                             ,a_cts72m00[3].emeviacod
             else
                call cts06g11(7
                             ,g_documento.atdsrvorg
                             ,w_cts72m00.ligcvntip
                             ,aux_today
                             ,aux_hora
                             ,a_cts72m00[3].lclidttxt
                             ,a_cts72m00[3].cidnom
                             ,a_cts72m00[3].ufdcod
                             ,a_cts72m00[3].brrnom
                             ,a_cts72m00[3].lclbrrnom
                             ,a_cts72m00[3].endzon
                             ,a_cts72m00[3].lgdtip
                             ,a_cts72m00[3].lgdnom
                             ,a_cts72m00[3].lgdnum
                             ,a_cts72m00[3].lgdcep
                             ,a_cts72m00[3].lgdcepcmp
                             ,a_cts72m00[3].lclltt
                             ,a_cts72m00[3].lcllgt
                             ,a_cts72m00[3].lclrefptotxt
                             ,a_cts72m00[3].lclcttnom
                             ,a_cts72m00[3].dddcod
                             ,a_cts72m00[3].lcltelnum
                             ,a_cts72m00[3].c24lclpdrcod
                             ,a_cts72m00[3].ofnnumdig
                             ,a_cts72m00[3].celteldddcod
                             ,a_cts72m00[3].celtelnum
                             ,a_cts72m00[3].endcmp
                             ,hist_cts72m00.*
                             ,a_cts72m00[3].emeviacod )
                    returning a_cts72m00[3].lclidttxt
                             ,a_cts72m00[3].cidnom
                             ,a_cts72m00[3].ufdcod
                             ,a_cts72m00[3].brrnom
                             ,a_cts72m00[3].lclbrrnom
                             ,a_cts72m00[3].endzon
                             ,a_cts72m00[3].lgdtip
                             ,a_cts72m00[3].lgdnom
                             ,a_cts72m00[3].lgdnum
                             ,a_cts72m00[3].lgdcep
                             ,a_cts72m00[3].lgdcepcmp
                             ,a_cts72m00[3].lclltt
                             ,a_cts72m00[3].lcllgt
                             ,a_cts72m00[3].lclrefptotxt
                             ,a_cts72m00[3].lclcttnom
                             ,a_cts72m00[3].dddcod
                             ,a_cts72m00[3].lcltelnum
                             ,a_cts72m00[3].c24lclpdrcod
                             ,a_cts72m00[3].ofnnumdig
                             ,a_cts72m00[3].celteldddcod
                             ,a_cts72m00[3].celtelnum
                             ,a_cts72m00[3].endcmp
                             ,ws.retflg
                             ,hist_cts72m00.*
                             ,a_cts72m00[3].emeviacod
             end if

             if ws.retflg = "N" then
                error " Dados referentes ao local de ocorrencia incorretos ou nao preenchidos..." sleep 3
                continue input
             end if

             let a_cts72m00[3].lclbrrnom = m_subbairro[3].lclbrrnom
             whenever error continue

             select 1
               from datmlcl
              where atdsrvano = g_documento.atdsrvano
                and atdsrvnum = g_documento.atdsrvnum
                and c24endtip = 7

             whenever error stop
             if sqlca.sqlcode = 0  then
                let a_cts72m00[3].operacao = "M"
             else
                if sqlca.sqlcode = 100 then
                   let a_cts72m00[3].operacao = "I"
                else
                   error " Erro (", sqlca.sqlcode using "<<<<<&", ") na leitura local de ocorrencia(ctrl+o). AVISE A INFORMATICA!"
                   sleep 2
                   continue input
                end if
             end if

             begin work

             let ws.sqlcode = cts06g07_local(a_cts72m00[3].operacao
                                            ,g_documento.atdsrvnum
                                            ,g_documento.atdsrvano
                                            ,7   #--- Tp Endereco correspondencia
                                            ,a_cts72m00[3].lclidttxt
                                            ,a_cts72m00[3].lgdtip
                                            ,a_cts72m00[3].lgdnom
                                            ,a_cts72m00[3].lgdnum
                                            ,a_cts72m00[3].lclbrrnom
                                            ,a_cts72m00[3].brrnom
                                            ,a_cts72m00[3].cidnom
                                            ,a_cts72m00[3].ufdcod
                                            ,a_cts72m00[3].lclrefptotxt
                                            ,a_cts72m00[3].endzon
                                            ,a_cts72m00[3].lgdcep
                                            ,a_cts72m00[3].lgdcepcmp
                                            ,a_cts72m00[3].lclltt
                                            ,a_cts72m00[3].lcllgt
                                            ,a_cts72m00[3].dddcod
                                            ,a_cts72m00[3].lcltelnum
                                            ,a_cts72m00[3].lclcttnom
                                            ,a_cts72m00[3].c24lclpdrcod
                                            ,a_cts72m00[3].ofnnumdig
                                            ,a_cts72m00[3].emeviacod
                                            ,a_cts72m00[3].celteldddcod
                                            ,a_cts72m00[3].celtelnum
                                            ,a_cts72m00[3].endcmp)

             if ws.sqlcode is null   or
                ws.sqlcode <> 0      then
                      error " Erro (", ws.sqlcode, ") na alteracao do local de correspondencia. AVISE A INFORMATICA!"
                rollback work
                prompt "" for char l_prompt
                return false
             end if

             #--- SPR-2015-03912-Atualiza Pedido ---
             call opsfa015_inscadped(g_documento.cgccpfnum
                                    ,g_documento.cgcord
                                    ,g_documento.cgccpfdig
                                    ,g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
                                    ,"1") #--- Online - SPR-2015-22413))
                 returning lr_retped.coderro
                          ,lr_retped.msgerro
                          ,lr_retped.srvpedcod


             if lr_retped.coderro = false then
                rollback work
                let int_flag = true
                error lr_retped.msgerro clipped
                prompt "ERRO AO ATUALIZAR O PEDIDO. AVISE INFORMATICA" for char l_prompt
                exit input
             end if

             let mr_cts72m00.srvpedcod = lr_retped.srvpedcod
             display by name mr_cts72m00.srvpedcod
             #--- SPR-2015-03912-Atualiza Pedido ---

             commit work

             error "Endereco de correspondencia alterado com sucesso " sleep 2

             #---<<<  Endereco de correspondencia - PSI SPR-2014-28503

     end input

     if int_flag then
        error " Operacao cancelada!"
     end if

     return hist_cts72m00.*

 end function

#------------------------------------#
 function ccts72m00_carrega_servico()
#------------------------------------#

    select ciaempcod   ,
           nom         ,
           vclcoddig   ,
           vcldes      ,
           vclanomdl   ,
           vcllicnum   ,
           corsus      ,
           cornom      ,
           vclcorcod   ,
           atddat      ,
           atdhor      ,
           atdlibflg   ,
           atdlibhor   ,
           atdlibdat   ,
           atdhorpvt   ,
           atdpvtretflg,
           atddatprg   ,
           atdhorprg   ,
           atdfnlflg   ,
           asitipcod   ,
           atdcstvlr   ,
           atdprinvlcod
      into g_documento.ciaempcod  ,
           mr_cts72m00.nom        ,
           mr_cts72m00.vclcoddig  ,
           mr_cts72m00.vcldes     ,
           mr_cts72m00.vclanomdl  ,
           mr_cts72m00.vcllicnum  ,
           mr_cts72m00.corsus     ,
           mr_cts72m00.cornom     ,
           w_cts72m00.vclcorcod  ,
           w_cts72m00.atddat      ,
           w_cts72m00.atdhor      ,
           mr_cts72m00.atdlibflg  ,
           mr_cts72m00.atdlibhor  ,
           mr_cts72m00.atdlibdat  ,
           w_cts72m00.atdhorpvt   ,
           w_cts72m00.atdpvtretflg,
           w_cts72m00.atddatprg   ,
           w_cts72m00.atdhorprg   ,
           w_cts72m00.atdfnlflg   ,
           mr_cts72m00.asitipcod  ,
           w_cts72m00.atdcstvlr   ,
           mr_cts72m00.atdprinvlcod
      from datmservico
     where atdsrvnum = g_documento.atdsrvnum and
           atdsrvano = g_documento.atdsrvano

     if  sqlca.sqlcode = notfound then
         error " Servico nao encontrado. AVISE A INFORMATICA!"
         sleep 2
         return false
     else
         return true
     end if

 end function

#---------------------------------------------------------------
 function cts72m00_modifica()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    sqlcode          integer
 end record

 define hist_cts72m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define lr_retorno       record
        coderro          smallint,
        msgerro          char(70)
 end record

 define prompt_key   char (01)

 define r_retorno_sku   record   #- SPR-2015-13708-Melhorias Calculo SKU
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg   #- SPR-2016-03565
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record

 #-SPR-2016-01943
 define lr_opsfa023    record
        retorno        smallint
       ,mensagem       char(100)
 end record

 define l_data    date,
        l_hora2   datetime hour to minute
       ,l_errcod   smallint
       ,l_errmsg   char(80)
       ,l_c24endtip like datmlcl.c24endtip  # PSI SPR-2014-28503-Endereco de correspondencia
       ,l_pestipcod char(1)   #--- SPR-2015-03912-Cadastro de Clientes
       ,l_srvpedcod like datmsrvped.srvpedcod # SPR-2015-03912-Cadastro Pedidos

        initialize l_errcod, l_errmsg, l_srvpedcod to null
        initialize l_pestipcod to null    # SPR-2015-03912-Cadastro de Clientes
        initialize lr_retorno  to null    # SPR-2015-03912-Cadastro de Clientes
        initialize r_retorno_sku to null  # SPR-2015-13708-Melhorias Calculo SKU
        initialize lr_opsfa023   to null  #-SPR-2016-01943                      

        let     prompt_key  =  null
        let     m_pbmonline = null #--- PSI SPR-2014-28503 - Venda Online


        initialize  ws.*  to  null

        initialize  hist_cts72m00.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts72m00.*  to  null

 initialize ws.*  to null
 let m_pbmonline  = null #--- PSI SPR-2014-28503 - Venda Online

 #=> SPR-2014-28503 - Inicio
 #=> VER SE POSSUI 'VENDA' ASSOCIADA
 if not opsfa006_ha_venda(g_documento.atdsrvnum,
                          g_documento.atdsrvano) then
    if sqlca.sqlcode < 0 then
       prompt "" for char prompt_key
       return false
    end if

    #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
    call opsfa001_conskupbr(1001   #-- Codigo do problema
                           ,w_cts72m00.atddat)
         returning r_retorno_sku.catcod
                  ,r_retorno_sku.pgtfrmcod
                  ,r_retorno_sku.srvprsflg  #- SPR-2016-03565
                  ,r_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
                  ,r_retorno_sku.msg_erro

    if r_retorno_sku.codigo_erro = -284 then
       error "Existe mais de um SKU ativo para este problema!!!"
       let r_retorno_sku.catcod = null
       let r_retorno_sku.pgtfrmcod = null
    else
       if r_retorno_sku.codigo_erro = 100 then  #--- Verifica NotFound
          error "Nao existe SKU ativo para este problema!!!"
          let r_retorno_sku.catcod = null
          let r_retorno_sku.pgtfrmcod = null
       else
          if r_retorno_sku.codigo_erro < 0 then
             error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                   " AO ACESSAR CADASTRO DE SKU 'datksrvcat'!!!" sleep 5
             prompt "" for char prompt_key
             return false
          end if
       end if
    end if


    if cts72m00_verifica_solicitante() then   #--- PSI SPR-2014-28503-Venda online
       let m_pbmonline = r_retorno_sku.catcod #--- PSI SPR-2014-28503-Venda online
       let m_vendaflg = false
    else
       if sqlca.sqlcode < 0 then
          prompt "" for char prompt_key
          return false
       end if
       let m_vendaflg = false
    end if
 else
    let m_vendaflg = true
 end if

 #=> VERIFICA SE ASSUNTO PERMITE VENDA/F.PAGTO
 whenever error continue
 open c_cts72m00_012 using g_documento.atdsrvnum,
                           g_documento.atdsrvano
 fetch c_cts72m00_012 into m_c24astcodflag
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
          " AO ACESSAR 'datmligacao'!!!"
    prompt "" for char prompt_key
    return false
 end if
 let cty27g00_ret = cty27g00_consiste_ast(m_c24astcodflag)
  #=> SPR-2014-28503 -- Fim

 call cts72m00_input() returning hist_cts72m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts72m00      to null
    initialize a_passag        to null
    initialize mr_cts72m00.*    to null
    initialize w_cts72m00.*    to null
    initialize hist_cts72m00.* to null
    clear form
    return false
 end if

 whenever error continue

 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
                          vclcoddig     ,
                          vcldes        ,
                          vclanomdl     ,
                          vcllicnum     ,
                          vclcorcod     ,
                          atdlibflg     ,
                          atdlibdat     ,
                          atdlibhor     ,
                          atdhorpvt     ,
                          atddatprg     ,
                          atdhorprg     ,
                          atdpvtretflg  ,
                          asitipcod     ,
                          atdprinvlcod  ) #- SPR-2015-15533-Fechamento Servs GPS
                      = ( mr_cts72m00.nom,
                          mr_cts72m00.corsus,
                          mr_cts72m00.cornom,
                          mr_cts72m00.vclcoddig,
                          mr_cts72m00.vcldes,
                          mr_cts72m00.vclanomdl,
                          mr_cts72m00.vcllicnum,
                          w_cts72m00.vclcorcod,
                          mr_cts72m00.atdlibflg,
                          mr_cts72m00.atdlibdat,
                          mr_cts72m00.atdlibhor,
                          w_cts72m00.atdhorpvt,
                          w_cts72m00.atddatprg,
                          w_cts72m00.atdhorprg,
                          w_cts72m00.atdpvtretflg,
                          mr_cts72m00.asitipcod,
                          mr_cts72m00.atdprinvlcod ) #- SPR-2015-15533-Fechamento Servs GPS
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 #--- SPR-2015-03912-Cadastro de Clientes ---
 if g_documento.cgcord is null or
    g_documento.cgcord = " " or
    g_documento.cgcord = 0 then
    let l_pestipcod = "F"
 else
    let l_pestipcod = "J"
 end if

 #--- SPR-2015-03912-Cadastro de Clientes --- #=> SPR-2015-11582 - S/TIP.PESSOA
 call opsfa014_inscadcli(g_documento.cgccpfnum
                        ,g_documento.cgcord
                        ,g_documento.cgccpfdig
                        ,mr_cts72m00.nom
                        ,mr_cts72m00.nscdat
                        ,"")
      returning lr_retorno.coderro
               ,lr_retorno.msgerro

 if lr_retorno.coderro = false then
    rollback work
    error lr_retorno.msgerro clipped
    prompt "ERRO NA INCLUSAO CADASTRO CLIENTE. AVISE INFORMATICA"
         for char prompt_key
    return false
 end if
 #--- SPR-2015-03912-Cadastro de Clientes ---

 #=> SPR-2014-28503 - ATUALIZA OS DADOS DA VENDA
 if m_vendaflg or
    m_pbmonline is not null then     #--- PSI SPR-2014-28503-Venda online

    #--- SPR-2015-03912-Inclui Pedido ---
    call opsfa015_inscadped(g_documento.cgccpfnum
                           ,g_documento.cgcord
                           ,g_documento.cgccpfdig
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,"1") #--- Online - SPR-2015-22413))
         returning lr_retorno.coderro
                  ,lr_retorno.msgerro
                  ,l_srvpedcod

    if lr_retorno.coderro = false then
       rollback work
       error lr_retorno.msgerro  clipped
       prompt "ERRO NA ATUALIZACAO DO PEDIDO. AVISE INFORMATICA" for char prompt_key
       return false
    end if
 end if

 update datmassistpassag set ( refatdsrvnum , #- SPR-2015-15533-Fechamento Servs GPS
                               refatdsrvano ,
                               asimtvcod    ,
                               atddmccidnom ,
                               atddmcufdcod ,
                               atddstcidnom ,
                               atddstufdcod ,
                               trppfrdat    ,
                               trppfrhor    )
                           = ( mr_cts72m00.refatdsrvnum,  #- SPR-2015-15533
                               mr_cts72m00.refatdsrvano,
                               mr_cts72m00.asimtvcod   ,
                               w_cts72m00.atddmccidnom,
                               w_cts72m00.atddmcufdcod,
                               w_cts72m00.atddstcidnom,
                               w_cts72m00.atddstufdcod,
                               w_cts72m00.trppfrdat,
                               w_cts72m00.trppfrhor)
                         where atdsrvnum = g_documento.atdsrvnum  and
                               atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 delete from datmpassageiro
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na substituicao da relacao de",
          " passageiros. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 15
    if a_passag[arr_aux].pasnom is null  or
       a_passag[arr_aux].pasidd is null  then
       exit for
    end if

    initialize ws.passeq to null

    select max(passeq)
      into ws.passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do ultimo passageiro.",
             " AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

    if ws.passeq is null  then
       let ws.passeq = 0
    end if

    let ws.passeq = ws.passeq + 1

    insert into datmpassageiro (atdsrvnum,
                                atdsrvano,
                                passeq,
                                pasnom,
                                pasidd)
                        values (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                ws.passeq,
                                a_passag[arr_aux].pasnom,
                                a_passag[arr_aux].pasidd)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 3   #--- PSI SPR-2014-28503-Endereco de Correspondencia
    if a_cts72m00[arr_aux].operacao is null  then
       let a_cts72m00[arr_aux].operacao = "M"
    end if

    let l_c24endtip = arr_aux #--- PSI SPR-2014-28503-Endereco de correspondencia

    if mr_cts72m00.asitipcod = 10  and  arr_aux = 2   then
       exit for
    end if

    if arr_aux = 3 then  #--- PSI SPR-2014-28503-Endereco correspondencia
       let l_c24endtip = 7

       whenever error continue

       select 1
         from datmlcl
        where atdsrvano = g_documento.atdsrvano
          and atdsrvnum = g_documento.atdsrvnum
          and c24endtip = l_c24endtip

       whenever error stop
       if sqlca.sqlcode = 0  then
          let a_cts72m00[arr_aux].operacao = "M"
       else
          if sqlca.sqlcode = 100 then
             let a_cts72m00[arr_aux].operacao = "I"
          else
             error " Erro (",sqlca.sqlcode using "<<<<<&", ") na leitura local de ocorrencia(upd). AVISE A INFORMATICA!"
             sleep 2
             return false
          end if
       end if
    end if

    let a_cts72m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    call cts06g07_local(a_cts72m00[arr_aux].operacao,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        l_c24endtip,   #--- PSI SPR-2014-28503-Endereco de correspondencia
                        a_cts72m00[arr_aux].lclidttxt,
                        a_cts72m00[arr_aux].lgdtip,
                        a_cts72m00[arr_aux].lgdnom,
                        a_cts72m00[arr_aux].lgdnum,
                        a_cts72m00[arr_aux].lclbrrnom,
                        a_cts72m00[arr_aux].brrnom,
                        a_cts72m00[arr_aux].cidnom,
                        a_cts72m00[arr_aux].ufdcod,
                        a_cts72m00[arr_aux].lclrefptotxt,
                        a_cts72m00[arr_aux].endzon,
                        a_cts72m00[arr_aux].lgdcep,
                        a_cts72m00[arr_aux].lgdcepcmp,
                        a_cts72m00[arr_aux].lclltt,
                        a_cts72m00[arr_aux].lcllgt,
                        a_cts72m00[arr_aux].dddcod,
                        a_cts72m00[arr_aux].lcltelnum,
                        a_cts72m00[arr_aux].lclcttnom,
                        a_cts72m00[arr_aux].c24lclpdrcod,
                        a_cts72m00[arr_aux].ofnnumdig,
                        a_cts72m00[arr_aux].emeviacod,
                        a_cts72m00[arr_aux].celteldddcod,
                        a_cts72m00[arr_aux].celtelnum,
                        a_cts72m00[arr_aux].endcmp)
              returning ws.sqlcode

    if ws.sqlcode is null   or
       ws.sqlcode <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.sqlcode, ") na alteracao do local de",
                " ocorrencia. AVISE A INFORMATICA!"
       else
       	  if arr_aux = 2  then
             error " Erro (", ws.sqlcode, ") na alteracao do local de",
                   " destino. AVISE A INFORMATICA!"
          else    #--- PSI SPR-2014-28503-Endereco correspondencia
             error " Erro (", ws.sqlcode, ") na alteracao do local de",
                   " correspondencia. AVISE A INFORMATICA!"
          end if
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if w_cts72m00.antlibflg <> mr_cts72m00.atdlibflg  then
    if mr_cts72m00.atdlibflg = "S"  then
       let w_cts72m00.atdetpcod = 1
       let ws.atdetpdat = mr_cts72m00.atdlibdat
       let ws.atdetphor = mr_cts72m00.atdlibhor
    else
       let w_cts72m00.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts72m00.atdetpcod,
                               w_cts72m00.atdprscod,
                               " " ,
                               " ",
                               w_cts72m00.srrcoddig) returning w_retorno

    if w_retorno <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de",
             " acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if


  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts72m00.atdfnlflg <> "S" then

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts72m00[1].cidnom,
                             a_cts72m00[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
        if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                            g_documento.c24astcod,
                                            mr_cts72m00.asitipcod,
                                            a_cts72m00[1].lclltt,
                                            a_cts72m00[1].lcllgt,
                                            "N", # mr_cts72m00.prslocflg-SPR-2015-15533
                                            "N", # mr_cts72m00.frmflg-SPR-2015-11582
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            " ",
                                            "",
                                            "") then
        else
           let m_aciona = 'S'
        end if
     else
        error "Problemas com parametros de acionamento: ",
                             g_documento.atdsrvorg, "/",
                             a_cts72m00[1].cidnom, "/",
                             a_cts72m00[1].ufdcod sleep 4
     end if

  end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 #-SPR-2016-01943 - inicio
 if (m_atddatprg_aux <> w_cts72m00.atddatprg  or
     m_atdhorprg_aux <> w_cts72m00.atdhorprg) then
     call opsfa023_emailposvenda(g_documento.atdsrvnum,
                                 g_documento.atdsrvano)
            returning lr_opsfa023.retorno,
                      lr_opsfa023.mensagem

    if lr_opsfa023.retorno = false then
       error lr_opsfa023.mensagem clipped
    end if
 end if
 #-SPR-2016-01943 - Fim

 #---> Data de Fechamento - PSI SPR-2015-03912  ---
 call opsfa006_atualdtfecha(g_documento.atdsrvnum
                           ,g_documento.atdsrvano )
      returning lr_retorno.*

 if lr_retorno.coderro = false then
    error lr_retorno.msgerro clipped
    prompt "ERRO AO ATUALIZAR DATA ATENDIMENTO NA VENDA. AVISE INFORMATICA"
           for prompt_key
    return false
 end if

 #Projeto alteracao cadastro de destino
 if m_grava_hist then
    call cts72m00_grava_historico()
 end if

 whenever error stop

 # PSI-2013-00440PR
 if m_agendaw = true
    then
    ##-- SPR-2015-15533 - Inicio
    call cts72m00_descpbm()
		         returning g_documento.atddfttxt

    let g_documento.c24pbmcod    = 1001
    let g_documento.asitipcod    = mr_cts72m00.asitipcod
    let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
    let g_documento.socntzdes    = null
    ##-- SPR-2015-15533 - Fim
    if m_operacao = 1  # ALT, gerou nova cota, baixa
       then
       #display 'Baixar cota atual na alteracao: ', m_rsrchv clipped
       call ctd41g00_baixar_agenda(m_rsrchv
                                 , g_documento.atdsrvano
                                 , g_documento.atdsrvnum)
            returning l_errcod, l_errmsg
    end if

    # so libera a anterior se baixou a nova
    if l_errcod = 0
       then
       call cts02m08_upd_cota(m_rsrchv, m_rsrchvant, g_documento.atdsrvnum
                            , g_documento.atdsrvano)

       # ALT, gerou nova cota e baixou, libera
       # Liberou sem regulacao e chave anterior existe, libera
       if (m_operacao = 1 or m_operacao = 2)
          then
          #display 'Liberar cota anterior na alteracao'
          call ctd41g00_liberar_agenda(g_documento.atdsrvano
                                      ,g_documento.atdsrvnum
                                      ,m_agncotdatant
                                      ,m_agncothorant)
       end if
    end if
 end if
 # PSI-2013-00440PR

 return true

end function


#-------------------------------------------------------------------------------
 function cts72m00_verifica_solicitante() #--- PSI SPR-2014-28503 - Venda online
#-------------------------------------------------------------------------------
 define l_c24soltipcod  like datmligacao.c24soltipcod

 open c_cts72m00_014 using g_documento.atdsrvnum
                          ,g_documento.atdsrvano

 #--- datmligacao - captura solicitante
 whenever error continue
   fetch c_cts72m00_014 into l_c24soltipcod
 whenever error stop

  if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT c_cts72m00_014: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    end if
    let l_c24soltipcod = null
 end if


 open c_cts72m00_015 using l_c24soltipcod
 #--- iddkdominio - verifica venda online
 whenever error continue
  fetch c_cts72m00_015
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then
       error 'Erro SELECT c_cts72m00_015: ' ,sqlca.sqlcode,' / ',
             sqlca.sqlerrd[2] sleep 2
       return false
    else  #--- notfound iddkdominio
       open c_cts72m00_016 using l_c24soltipcod

       #--- datkdominio - verifica venda online
       whenever error continue
        fetch c_cts72m00_016
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             error 'Erro SELECT c_cts72m00_016: ' ,sqlca.sqlcode,' / ',
                   sqlca.sqlerrd[2] sleep 2
             return false
          end if
       end if
    end if
 end if

 return true

end function

#-------------------------------------------------------------------------------
 function cts72m00_inclui()
#-------------------------------------------------------------------------------

 ##define cty27g00_ret integer # psi-2012-22101

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        passeq          like datmpassageiro.passeq ,
        ano             char (02)                  ,
        todayX          char (10)                  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        c24trxnum       like dammtrx.c24trxnum     ,  # Msg pager/email
        lintxt          like dammtrxtxt.c24trxtxt  ,
        titulo          like dammtrx.c24msgtit
 end record

 define hist_cts72m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define lr_pagamento record
 	orgnum		like datmpgtinf.orgnum,
 	prpnum		like datmpgtinf.prpnum,
 	pgtfrmcod	like datmpgtinf.pgtfrmcod,
 	pgtfrmdes	like datkpgtfrm.pgtfrmdes
 end record

 define lr_cartao record
 	clinom		like datmcrdcrtinf.clinom,
 	crtnum		like datmcrdcrtinf.crtnum,
 	bndcod		like datmcrdcrtinf.bndcod,
 	crtvlddat	like datmcrdcrtinf.crtvlddat,
 	cbrparqtd	like datmcrdcrtinf.cbrparqtd,
 	bnddes		like fcokcarbnd.carbndnom
 end record

 define la_historico       array[7] of record
         descricao         char (70)
 end record

 define lr_retorno       record
        coderro          smallint,
        msgerro          char(70)
 end record

 define l_ind            smallint
 define l_pestipcod char(1)  #--- SPR-2015-03912-Cadastro Clientes ---
 define l_dadosPagamento smallint
 define l_cartaoCripto   dec(4,0)
 define l_count          dec(1,0)

 define l_data       date,
        l_hora2      datetime hour to minute

 define lr_retcrip record
        coderro         smallint
       ,msgerro         char(10000)
       ,pcapticrpcod    like fcomcaraut.pcapticrpcod
 end record

 ###PSI-2012-22101
 define lr_frm_pagamento record
        crtnum                like datmcrdcrtinf.crtnum,
        crtnumPainel          char(4)
 end record
 #define cty27g00_ret integer # psi-2012-22101

 #--- SPR-2015-03912-Cadastro Pedidos ---
 define lr_retped      record
        coderro        smallint
       ,msgerro        char(80)
       ,srvpedcod      like datmsrvped.srvpedcod
 end record

 #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda
 define lr_numped      record
        coderro        smallint
       ,msgerro        char(80)
       ,srvpedcod      like datmsrvped.srvpedcod
 end record

 define lr_ret         record
        retorno        smallint
       ,mensagem       char(100)
       ,atdsrvnum      like datmservico.atdsrvnum
       ,atdsrvano      like datmservico.atdsrvano
 end record
 	 
 #- SPR-2016-03565 - Inicio	
 define lr_retorno_sku  record   
        catcod          like datksrvcat.catcod
       ,pgtfrmcod       like datksrvcat.pgtfrmcod
       ,srvprsflg       like datmsrvcathst.srvprsflg
       ,codigo_erro     smallint
       ,msg_erro        char(80)
 end record	
#- SPR-2016-03565 - Fim 	

#-SPR-2016-01943
 define lr_opsfa023    record
        retorno        smallint
       ,mensagem       char(100)
 end record


 define l_ret            smallint,
        l_mensagem       char(60)
      , l_txtsrv         char (15)
      , l_reserva_ativa  smallint # Flag para idenitficar se reserva esta ativa
      , l_errcod         smallint
      , l_errmsg         char(80)
      , l_c24endtip      like datmlcl.c24endtip  #--- PSI SPR-2014-28503-Endereco de correspondencia


 initialize l_errcod, l_errmsg to null
 initialize l_txtsrv, l_reserva_ativa to null
 initialize l_ret, l_mensagem to null
 initialize  ws.*, cty27g00_ret  to  null
 initialize  hist_cts72m00.*  to  null
 initialize  lr_retorno       to null
 initialize  lr_retped        to null
 initialize lr_numped.*       to null  #--- SPR-2015-11582
 initialize lr_retorno_sku.*  to null  #- SPR-2016-03565
 initialize lr_opsfa023.*     to null  #- SPR-2016-01943

 let l_pestipcod = null  #--- SPR-2015-03912-Cadastro de Clientes ---
 let l_dadosPagamento = true

 #=> SPR-2014-28503 - VERIFICA SE ASSUNTO PERMITE VENDA/F.PAGTO
 let cty27g00_ret = cty27g00_consiste_ast(g_documento.c24astcod)

 if cty27g00_ret = 1 then
    let m_vendaflg = true
 else
    let m_vendaflg = false
 end if

 #display 'cts72m00 - Incluir atendimento'

 while true
   initialize ws.*, cty27g00_ret to null

   let g_documento.acao    = "INC"
   let w_cts72m00.operacao = "i"

   call cts72m00_input() returning hist_cts72m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts72m00      to null
       initialize a_passag        to null
       initialize mr_parametro.*    to null
       initialize w_cts72m00.*    to null
       initialize hist_cts72m00.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts72m00.data is null  then
       let w_cts72m00.data   = aux_today
       let w_cts72m00.hora   = aux_hora
       let w_cts72m00.funmat = g_issk.funmat
   end if

##- SPR-2015-11582
#   if  mr_cts72m00.frmflg = "S"  then
#       call cts40g03_data_hora_banco(2)
#            returning l_data, l_hora2
#       let ws.caddat = l_data
#       let ws.cadhor = l_hora2
#       let ws.cademp = g_issk.empcod
#       let ws.cadmat = g_issk.funmat
#   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
#   end if

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.todayX  = l_data
   let ws.ano    = ws.todayX[9,10]


   if  w_cts72m00.atdfnlflg is null  then
       let w_cts72m00.atdfnlflg = "N"
       let w_cts72m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

   #------------------------------------------------------------------------------
   # Busca numeracao ligacao / servico
   #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "P" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "cts72m00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum   = ws.lignum
   let w_cts72m00.atdsrvnum = ws.atdsrvnum
   let w_cts72m00.atdsrvano = ws.atdsrvano

    #=> SPR-2014-28503 - GERA NUMERO DA PROPOSTA (FORMA DE PAGAMENTO)
   if m_vendaflg then
      begin work
      call cty27g00_numprp()
                 returning mr_prop.*
      if mr_prop.sqlcode <> 0 then
         let ws.msg = "cts72m00(numprp) - ",mr_prop.msg clipped
         call ctx13g00(mr_prop.sqlcode,"DATKGERAL(numprp)",mr_prop.msg)
         rollback work
         prompt "" for char ws.promptX
         let ws.retorno = false
         exit while
      end if
      commit work
   else
      initialize mr_prop.* to null
   end if

   #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda
   begin work
   call opsfa015_geranumped()
        returning lr_numped.coderro
                 ,lr_numped.msgerro
                 ,lr_numped.srvpedcod

   if lr_numped.coderro = false then
      let ws.msg = "cts72m00(geranumped) - ", lr_numped.msgerro clipped
      call ctx13g00("","DATKGERAL(numped)",lr_numped.msgerro)
      rollback work
      prompt "" for ws.promptX
      let ws.retorno = false
      exit while
   end if
   commit work
   #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda

 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts72m00.data         ,
                           w_cts72m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts72m00.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","","",""             ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           ""                      ,
                           "","","",""             ,
                           ws.caddat               ,
                           ws.cadhor               ,
                           ws.cademp               ,
                           ws.cadmat                )
        returning ws.tabname,
                  ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( w_cts72m00.atdsrvnum,
                                w_cts72m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24soltip
                                w_cts72m00.vclcorcod,
                                w_cts72m00.funmat   ,
                                mr_cts72m00.atdlibflg,
                                mr_cts72m00.atdlibhor,
                                mr_cts72m00.atdlibdat,
                                w_cts72m00.data     ,     # atddat
                                w_cts72m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts72m00.atdhorpvt,
                                w_cts72m00.atddatprg,
                                w_cts72m00.atdhorprg,
                                "P"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts72m00.atdprscod,
                                w_cts72m00.atdcstvlr,
                                w_cts72m00.atdfnlflg,
                                w_cts72m00.atdfnlhor,
                                w_cts72m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts72m00.c24opemat,
                                mr_cts72m00.nom      ,
                                mr_cts72m00.vcldes   ,
                                mr_cts72m00.vclanomdl,
                                mr_cts72m00.vcllicnum,
                                mr_cts72m00.corsus   ,
                                mr_cts72m00.cornom   ,
                                w_cts72m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts72m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                mr_cts72m00.asitipcod,
                                ""                  ,     # socvclcod
                                mr_cts72m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                mr_cts72m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
        returning ws.tabname,
                  ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   call opsfa006_geracao(w_cts72m00.atdsrvnum
                        ,w_cts72m00.atdsrvano
                        ,mr_prop.prpnum
                        ,lr_numped.srvpedcod
                        ,mr_cts72m00.nom
                        ,mr_cts72m00.nscdat
                        ,""           #---  Email
                        ,false        #---  Atualiza Data Fechamento
                        ,m_vendaflg   #---  Cria Venda
                        ,"1")         #---  Online - SPR-2015-22413
        returning lr_ret.retorno
                 ,lr_ret.mensagem

   if lr_ret.retorno = false then
      rollback work
      error "ERRO NA GERACAO DA VENDA - ",lr_ret.mensagem clipped
      prompt "" for char ws.promptX
      let ws.retorno = false
      exit while
   end if

   #--- SPR-2015-11582 - Funcao Unica para Geracao da Venda
   let mr_cts72m00.srvpedcod = lr_numped.srvpedcod

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
#- if mr_cts72m00.prslocflg = "S" then  #- SPR-2015-15533-Fechamento Servs GPS
      update datmservico set socvclcod = w_cts72m00.socvclcod,
                             srrcoddig = w_cts72m00.srrcoddig
       where datmservico.atdsrvnum = w_cts72m00.atdsrvnum
         and datmservico.atdsrvano = w_cts72m00.atdsrvano
#- end if  #- SPR-2015-15533-Fechamento Servs GPS

 #------------------------------------------------------------------------------
 # Gravacao dos dados da ASSISTENCIA A PASSAGEIROS
 #------------------------------------------------------------------------------

   insert into DATMASSISTPASSAG ( atdsrvnum    ,
                                  atdsrvano    ,
                                  bagflg       , #- SPR-2015-15533-Fechamento GPS
                                  refatdsrvnum ,
                                  refatdsrvano ,
                                  asimtvcod    ,
                                  atddmccidnom ,
                                  atddmcufdcod ,
                                  atddstcidnom ,
                                  atddstufdcod ,
                                  trppfrdat    ,
                                  trppfrhor     )
                         values ( w_cts72m00.atdsrvnum   ,
                                  w_cts72m00.atdsrvano   ,
                                  "N" , #- mr_cts72m00.bagflg - SPR-2015-15533
                                  mr_cts72m00.refatdsrvnum,
                                  mr_cts72m00.refatdsrvano,
                                  mr_cts72m00.asimtvcod   ,
                                  w_cts72m00.atddmccidnom,
                                  w_cts72m00.atddmcufdcod,
                                  w_cts72m00.atddstcidnom,
                                  w_cts72m00.atddstufdcod,
                                  w_cts72m00.trppfrdat   ,
                                  w_cts72m00.trppfrhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao dos",
             " dados da assistencia. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


   for arr_aux = 1 to 15
       if  a_passag[arr_aux].pasnom is null  or
           a_passag[arr_aux].pasidd is null  then
           exit for
       end if

       initialize ws.passeq to null

       select max(passeq)
         into ws.passeq
         from DATMPASSAGEIRO
              where atdsrvnum = w_cts72m00.atdsrvnum
                and atdsrvano = w_cts72m00.atdsrvano

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na selecao do",
                 " ultimo passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       if  ws.passeq is null  then
           let ws.passeq = 0
       end if

       let ws.passeq = ws.passeq + 1

       insert into DATMPASSAGEIRO( atdsrvnum,
                                   atdsrvano,
                                   passeq   ,
                                   pasnom   ,
                                   pasidd    )
                           values( w_cts72m00.atdsrvnum    ,
                                   w_cts72m00.atdsrvano    ,
                                   ws.passeq               ,
                                   a_passag[arr_aux].pasnom,
                                   a_passag[arr_aux].pasidd )

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino / (3) correspondencia
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 3   #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
       if  a_cts72m00[arr_aux].operacao is null  then
           let a_cts72m00[arr_aux].operacao = "I"
       end if

       let l_c24endtip = arr_aux #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
       if  mr_cts72m00.asitipcod = 10  and  arr_aux = 2   then
           exit for
       end if
       if arr_aux = 3 then  #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
       	  let l_c24endtip = 7
       end if
       let a_cts72m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts72m00[arr_aux].operacao    ,
                            w_cts72m00.atdsrvnum            ,
                            w_cts72m00.atdsrvano            ,
                            l_c24endtip ,  #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
                            a_cts72m00[arr_aux].lclidttxt   ,
                            a_cts72m00[arr_aux].lgdtip      ,
                            a_cts72m00[arr_aux].lgdnom      ,
                            a_cts72m00[arr_aux].lgdnum      ,
                            a_cts72m00[arr_aux].lclbrrnom   ,
                            a_cts72m00[arr_aux].brrnom      ,
                            a_cts72m00[arr_aux].cidnom      ,
                            a_cts72m00[arr_aux].ufdcod      ,
                            a_cts72m00[arr_aux].lclrefptotxt,
                            a_cts72m00[arr_aux].endzon      ,
                            a_cts72m00[arr_aux].lgdcep      ,
                            a_cts72m00[arr_aux].lgdcepcmp   ,
                            a_cts72m00[arr_aux].lclltt      ,
                            a_cts72m00[arr_aux].lcllgt      ,
                            a_cts72m00[arr_aux].dddcod      ,
                            a_cts72m00[arr_aux].lcltelnum   ,
                            a_cts72m00[arr_aux].lclcttnom   ,
                            a_cts72m00[arr_aux].c24lclpdrcod,
                            a_cts72m00[arr_aux].ofnnumdig,
                            a_cts72m00[arr_aux].emeviacod,
                            a_cts72m00[arr_aux].celteldddcod,
                            a_cts72m00[arr_aux].celtelnum,
                            a_cts72m00[arr_aux].endcmp)
            returning ws.sqlcode

       if  ws.sqlcode is null  or
           ws.sqlcode <> 0     then
           if arr_aux = 1  then
              error " Erro (", ws.sqlcode, ") na gravacao do",
                    " local de ocorrencia. AVISE A INFORMATICA!"
           else
              if arr_aux = 2  then
                 error " Erro (", ws.sqlcode, ") na gravacao do",
                       " local de destino. AVISE A INFORMATICA!"
              else     #--->>>  Endereco de correspondencia - PSI SPR-2014-28503
                 error " Erro (", ws.sqlcode, ") na gravacao do",
                       " local de correspondencia. AVISE A INFORMATICA!"
              end if
           end if
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts72m00.atdetpcod is null  then
       if  mr_cts72m00.atdlibflg = "S"  then
           let w_cts72m00.atdetpcod = 1
           let ws.etpfunmat = w_cts72m00.funmat
           let ws.atdetpdat = mr_cts72m00.atdlibdat
           let ws.atdetphor = mr_cts72m00.atdlibhor
       else
           let w_cts72m00.atdetpcod = 2
           let ws.etpfunmat = w_cts72m00.funmat
           let ws.atdetpdat = w_cts72m00.data
           let ws.atdetphor = w_cts72m00.hora
       end if
   else
      call cts10g04_insere_etapa(w_cts72m00.atdsrvnum,
                                 w_cts72m00.atdsrvano,
                                 1,
                                 w_cts72m00.atdprscod,
                                 " ",
                                 " ",
                                 w_cts72m00.srrcoddig )returning w_retorno

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts72m00.cnldat
       let ws.atdetphor = w_cts72m00.atdfnlhor
       let ws.etpfunmat = w_cts72m00.c24opemat
   end if


   call cts10g04_insere_etapa(w_cts72m00.atdsrvnum,
                              w_cts72m00.atdsrvano,
                              w_cts72m00.atdetpcod,
                              w_cts72m00.atdprscod,
                              " ",
                              " ",
                              w_cts72m00.srrcoddig )returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   commit work

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts72m00.atdsrvnum,
                               w_cts72m00.atdsrvano)

   #---> Data de Fechamento - PSI SPR-2015-03912  ---
   call opsfa006_atualdtfecha(w_cts72m00.atdsrvnum
                             ,w_cts72m00.atdsrvano )
           returning lr_retorno.*

   if lr_retorno.coderro = false then
       error lr_retorno.msgerro clipped
       prompt "ERRO AO ATUALIZAR DATA ATENDIMENTO DO SERVICO. AVISE INFORMATICA"
                  for ws.promptX
       return false
   end if
   #---> Data de Fechamento - PSI SPR-2015-03912 ---

let m_mailpfaz = false

 whenever error continue
 open c_cts72m00_017
 fetch c_cts72m00_017 into m_mailpfaz

 if sqlca.sqlcode != 0
    then
    let m_mailpfaz = false
 end if
 whenever error stop
 # PSI-2013-00440PR


 #---> Envio de Email  ---
 if m_mailpfaz = true then
   if g_documento.acao = "INC" then
      call opsfa023_emailposvenda(w_cts72m00.atdsrvnum
                                 ,w_cts72m00.atdsrvano)
           returning lr_retorno.coderro
                    ,lr_retorno.msgerro

      if lr_retorno.coderro = false then
         error lr_retorno.msgerro clipped
      end if
   end if
 end if


 #- SPR-2016-01943
 #-- Consulta SKU por Problema - SPR-2015-13708-Melhorias Calculo SKU
 call opsfa001_conskupbr(1001
                        ,today)
      returning lr_retorno_sku.catcod
               ,lr_retorno_sku.pgtfrmcod
               ,lr_retorno_sku.srvprsflg
               ,lr_retorno_sku.codigo_erro  #--- 0-Ok,  <> 0-sqlca.sqlcode
               ,lr_retorno_sku.msg_erro

 if lr_retorno_sku.srvprsflg = "S" or
    lr_retorno_sku.srvprsflg = "s" then
    call opsfa023_posvnd_prest(w_cts72m00.atdsrvnum
                               ,w_cts72m00.atdsrvano)
          returning lr_opsfa023.retorno,
                    lr_opsfa023.mensagem

    if lr_opsfa023.retorno = false then
       error lr_opsfa023.mensagem clipped
    end if
 end if
 #- SPR-2016-01943

  #=> SPR-2014-28503 - GRAVACAO DA FORMA DE PAGAMENTO JUNTO COM VENDA (OPSFA006)
{
   #---------------------------------------------
   # Grava Formas de Pagamento psi-2012-22101
   #---------------------------------------------
   let cty27g00_ret = 0
   call cty27g00_consiste_ast(g_documento.c24astcod)
        returning cty27g00_ret
   if cty27g00_ret = 1 then
      call cty27g00_entrada_dados(g_documento.prpnum,
                                  w_cts72m00.atdsrvnum,
                                  w_cts72m00.atdsrvano)
      let g_documento.prpnum_flg = ""
   end if
  }
   #--------------------------------------------------------------------------
   # Grava HISTORICO do servico - Informações pagamento
   #--------------------------------------------------------------------------
   let lr_pagamento.orgnum = 29              #=> SPR-2014-28503 - MELHORIA
   let lr_pagamento.prpnum = mr_prop.prpnum  #=> SPR-2014-28503 - MELHORIA
   open c_cts72m00_013 using mr_prop.prpnum  #=> SPR-2014-28503 - MELHORIA
   whenever error continue
     fetch c_cts72m00_013 into lr_pagamento.pgtfrmcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
         error 'Erro SELECT c_cts72m00_067: ' ,sqlca.sqlcode,' / ',
               sqlca.sqlerrd[2]
         sleep 2
      end if
      let l_dadosPagamento= false
   end if

   #------------------------------------------------------------------------------
   # Grava HISTORICO do servico
   #------------------------------------------------------------------------------
     call cts10g02_historico( w_cts72m00.atdsrvnum,
                              w_cts72m00.atdsrvano,
                              w_cts72m00.data     ,
                              w_cts72m00.hora     ,
                              w_cts72m00.funmat   ,
                              hist_cts72m00.*      )
          returning ws.histerr

 #------------------------------------------------------------------------------
 # Grava sugestao de cadastro
 #------------------------------------------------------------------------------

    IF mr_grava_sugest  = 'S' THEN
       CALL ctc68m00_grava_sugest(w_cts72m00.atdsrvnum,
				  w_cts72m00.atdsrvano,
				  mr_cts72m00.asitipcod,
				  g_issk.usrtip,
				  g_issk.empcod,
				  w_cts72m00.funmat)
        LET mr_grava_sugest = 'N'
    END IF

 #FIM PSI-2013-07115
   #------------------------------------------------------------------------------
   # Grava HISTORICO do servico - Informações pagamento
   #------------------------------------------------------------------------------
  {   open c_cts72m00_006 using w_cts72m00.atdsrvnum,
                               w_cts72m00.atdsrvano
     whenever error continue
     fetch c_cts72m00_006 into lr_pagamento.orgnum,
                               lr_pagamento.prpnum,
                               lr_pagamento.pgtfrmcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_cts72m00_006: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
        let l_dadosPagamento= false
     end if     }

     if l_dadosPagamento = true then
	  open c_cts72m00_008 using lr_pagamento.pgtfrmcod

	  whenever error continue
	  fetch c_cts72m00_008 into lr_pagamento.pgtfrmdes

	  whenever error stop
	  if sqlca.sqlcode <> 0 then
	     error 'Erro SELECT c_cts72m00_008: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	     let l_dadosPagamento= false
	  end if

     end if

     if lr_pagamento.pgtfrmcod = 1 and
        l_dadosPagamento = true then
	open c_cts72m00_007 using lr_pagamento.orgnum,
	                          lr_pagamento.prpnum,
	                          lr_pagamento.orgnum,
	                          lr_pagamento.prpnum
	whenever error continue
	fetch c_cts72m00_007 into lr_cartao.clinom,
				  lr_cartao.crtnum,
	                          lr_cartao.bndcod,
	                          lr_cartao.crtvlddat,
	                          lr_cartao.cbrparqtd
	whenever error stop
	if sqlca.sqlcode <> 0 then
	   error 'Erro SELECT c_cts72m00_007: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	   let l_dadosPagamento= false
	end if

        ########Decriptografar cartão e pegar apenas últimos 4 digitos
        # Descriptografa o numero do cartao
        initialize lr_retcrip.* to null
        call ffctc890("D",lr_cartao.crtnum  )
             returning lr_retcrip.*

        let lr_frm_pagamento.crtnumPainel = lr_retcrip.pcapticrpcod[13,16]
        let l_cartaoCripto = lr_frm_pagamento.crtnumPainel
        let lr_frm_pagamento.crtnum = "Numero Cartao: ",lr_frm_pagamento.crtnumPainel

	if l_dadosPagamento = true then
	   open c_cts72m00_009 using lr_cartao.bndcod

	   whenever error continue
	   fetch c_cts72m00_009 into lr_cartao.bnddes

	   whenever error stop
	   if sqlca.sqlcode <> 0 then
	      error 'Erro SELECT c_cts72m00_009: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	      let l_dadosPagamento= false
	   end if
  	end if

     end if

     if l_dadosPagamento = true then
  	   let l_count = 2
  	   let la_historico[1].descricao = 'PROPOSTA: ', lr_pagamento.orgnum using '####',"-",lr_pagamento.prpnum using '########'
  	   let la_historico[2].descricao = 'FORMA PAGAMENTO: ',lr_pagamento.pgtfrmdes clipped

  	   if lr_pagamento.pgtfrmcod = 1 then
	      let l_count = 7
	      let la_historico[3].descricao = 'NOME CLIENTE: ', lr_cartao.clinom clipped
	      let la_historico[4].descricao = 'NUMERO CARTAO: XXXX-XXXX-XXXX-',l_cartaoCripto using '####'
	      let la_historico[5].descricao = 'BANDEIRA CARTÃO: ',lr_cartao.bnddes clipped
	      let la_historico[6].descricao = 'VALIDADE CARTÃO: ', lr_cartao.crtvlddat
	      let la_historico[7].descricao = 'QUANTIDADE PARCELAS: ',lr_cartao.cbrparqtd
  	   end if

  	   for l_ind = 1 to l_count
  		call ctd07g01_ins_datmservhist(w_cts72m00.atdsrvnum,#g_documento.atdsrvnum,
                               		       w_cts72m00.atdsrvano,#g_documento.atdsrvano,
  					       g_issk.funmat,
  					       la_historico[l_ind].descricao,
  					       w_cts72m00.data,
                                               w_cts72m00.hora,
                                               g_issk.empcod,
                                               g_issk.usrtip)
                returning l_ret,
                          l_mensagem
                if l_ret <> 1  then
                   error l_mensagem, " - cts72m00 - AVISE A INFORMATICA!"
                end if
  	   end for

     end if

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts72m00[1].cidnom,
                          a_cts72m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         mr_cts72m00.asitipcod,
                                         a_cts72m00[1].lclltt,
                                         a_cts72m00[1].lcllgt,
                                         "N", #- mr_cts72m00.prslocflg-SPR-2015-15533
                                         "N", #- mr_cts72m00.frmflg-SPR-2015-11582
                                         w_cts72m00.atdsrvnum,
                                         w_cts72m00.atdsrvano,
                                         " ",
                                         "",
                                         "") then
     else
        let m_aciona = 'S'
     end if
  else
     error "Problemas com parametros de acionamento: ",
                          g_documento.atdsrvorg, "/",
                          a_cts72m00[1].cidnom, "/",
                          a_cts72m00[1].ufdcod sleep 4
  end if

  # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao
  #                    ainda ativa e fazer a baixa da chave no AW
  let l_txtsrv = "SRV ", w_cts72m00.atdsrvnum, "-", w_cts72m00.atdsrvano

  if m_agendaw = true
     then
     if m_operacao = 1  # obteve chave de regulacao
        then
        ##-- SPR-2015-15533 - Inicio
        call cts72m00_descpbm()
		          	returning g_documento.atddfttxt

        let g_documento.c24pbmcod    = 1001
        let g_documento.asitipcod    = mr_cts72m00.asitipcod
        let g_documento.asitipabvdes = mr_cts72m00.asitipabvdes
        let g_documento.socntzdes    = null
        ##-- SPR-2015-15533 - Fim
        if ws.sqlcode = 0  # sucesso na gravacao do servico
           then
           call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa

           if l_reserva_ativa = true
              then
              #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
              call ctd41g00_baixar_agenda(m_rsrchv, w_cts72m00.atdsrvano, w_cts72m00.atdsrvnum)
                   returning l_errcod, l_errmsg
           else
              #display "Chave de regulacao inativa, selecione agenda novamente"
              error "Chave de regulacao inativa, selecione agenda novamente"

              let m_operacao = 0

              # obter a chave de regulacao no AW
              call cts02m08(w_cts72m00.atdfnlflg,
                            mr_cts72m00.imdsrvflg,
                            m_altcidufd,
                            "N", #- mr_cts72m00.prslocflg - SPR-2015-15533
                            w_cts72m00.atdhorpvt,
                            w_cts72m00.atddatprg,
                            w_cts72m00.atdhorprg,
                            w_cts72m00.atdpvtretflg,
                            m_rsrchv,
                            m_operacao,
                            "",
                            a_cts72m00[1].cidnom,
                            a_cts72m00[1].ufdcod,
                            "",   # codigo de assistencia, nao existe no Ct24h
                            mr_cts72m00.vclcoddig,
                            m_ctgtrfcod,
                            mr_cts72m00.imdsrvflg,
                            a_cts72m00[1].c24lclpdrcod,
                            a_cts72m00[1].lclltt,
                            a_cts72m00[1].lcllgt,
                            g_documento.ciaempcod,
                            g_documento.atdsrvorg,
                            mr_cts72m00.asitipcod,
                            "",   # natureza nao tem, identifica pelo asitipcod
                            "")   # sub-natureza nao tem, identifica pelo asitipcod
                  returning w_cts72m00.atdhorpvt,
                            w_cts72m00.atddatprg,
                            w_cts72m00.atdhorprg,
                            w_cts72m00.atdpvtretflg,
                            mr_cts72m00.imdsrvflg,
                            m_rsrchv,
                            m_operacao,
                            m_altdathor

              display by name mr_cts72m00.imdsrvflg

              if m_operacao = 1
                 then
                 #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                 call ctd41g00_baixar_agenda(m_rsrchv, w_cts72m00.atdsrvano ,w_cts72m00.atdsrvnum)
                      returning l_errcod, l_errmsg
              end if
           end if

           if l_errcod = 0
              then
              call cts02m08_ins_cota(m_rsrchv, w_cts72m00.atdsrvnum, w_cts72m00.atdsrvano)
                   returning l_errcod, l_errmsg

              #if l_errcod = 0
              #   then
              #   display 'cts02m08_ins_cota gravou com sucesso'
              #else
              #   display 'cts02m08_ins_cota erro ', l_errcod
              #   display l_errmsg clipped
              #end if
           else
              #display 'cts72m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
           end if

        else
           #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'

           call cts02m08_id_datahora_cota(m_rsrchv)
                returning l_errcod, l_errmsg, m_agncotdat, m_agncothor

           #if l_errcod != 0
           #   then
           #   display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
           #   display l_errmsg clipped
           #end if

           call ctd41g00_liberar_agenda(w_cts72m00.atdsrvano, w_cts72m00.atdsrvnum
                                      , m_agncotdat, m_agncothor)
        end if
     end if
  end if
  # PSI-2013-00440PR

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let mr_cts72m00.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts72m00.atdsrvnum using "&&&&&&&",
                            "-", w_cts72m00.atdsrvano using "&&"
   display by name mr_cts72m00.servico attribute (reverse)

   #=> SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
   if mr_prop.prpnum is null then
      let mr_cts72m00.prpnumdsp = " "
   else
      let mr_cts72m00.prpnumdsp = "29/", mr_prop.prpnum using "&&&&&&&&"
   end if

   display by name mr_cts72m00.srvpedcod
   display by name mr_cts72m00.prpnumdsp attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function

#--- PSI SPR-2015-10068 - Consistir nome composto
#--------------------------------------------------------------------
function cts72m00_consiste_nome()
#--------------------------------------------------------------------
 define l_tam     smallint
 define l_ind     smallint
 define l_nome_ok char(1)
 define l_branco  char(1)

 let l_tam = null
 let l_ind = null
 let l_nome_ok = null
 let l_branco = null

 let l_branco = "N"
 let l_nome_ok = "N"
 let l_tam = length(mr_cts72m00.nom)

 for l_ind = 1 to l_tam
    if mr_cts72m00.nom[l_ind,l_ind] = " " or
       mr_cts72m00.nom[l_ind,l_ind] is null then
       if l_ind > 2 then
          let l_branco = "S"
       end if
    else
    	 if l_branco = "S" then
    	    let l_nome_ok = "S"
    	 end if
    end if
 end for

 return l_nome_ok

end function #--- cts72m00_consiste_nome()

#---------------------------------------------------------------
 function consulta_cts72m00()
#---------------------------------------------------------------

 define ws           record
    passeq           like datmpassageiro.passeq,
    funmat           like isskfunc.funmat,
    empcod           like isskfunc.empcod,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl,
    sqlcode          integer,
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapcorg         like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum
 end record

 #--- SPR-2015-03912-Cadastro Clientes ---
 define lr_retcli  record
    coderro        smallint
   ,msgerro        char(80)
   ,clinom         like datksrvcli.clinom
   ,nscdat         like datksrvcli.nscdat
 end record

#--- SPR-2015-03912-Cadastro Pedidos ---
 define lr_retped  record
    coderro        smallint
   ,msgerro        char(80)
   ,srvpedcod      like datmsrvped.srvpedcod
 end record

 define l_errcod   smallint
       ,l_errmsg   char(80)
       ,promptX   char (01)

 initialize l_errcod, l_errmsg to null

        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom         ,
        vclcoddig   ,
        vcldes      ,
        vclanomdl   ,
        vcllicnum   ,
        corsus      ,
        cornom      ,
        vclcorcod   ,
        funmat      ,
        empcod      ,
        atddat      ,
        atdhor      ,
        atdlibflg   ,
        atdlibhor   ,
        atdlibdat   ,
        atdhorpvt   ,
        atdpvtretflg,
        atddatprg   ,
        atdhorprg   ,
        atdfnlflg   ,
        asitipcod   ,
        atdcstvlr   ,
        atdprinvlcod,
        ciaempcod
   into mr_cts72m00.nom      ,
        mr_cts72m00.vclcoddig,
        mr_cts72m00.vcldes   ,
        mr_cts72m00.vclanomdl,
        mr_cts72m00.vcllicnum,
        mr_cts72m00.corsus   ,
        mr_cts72m00.cornom   ,
        w_cts72m00.vclcorcod,
        ws.funmat           ,
        ws.empcod           ,
        w_cts72m00.atddat   ,
        w_cts72m00.atdhor   ,
        mr_cts72m00.atdlibflg,
        mr_cts72m00.atdlibhor,
        mr_cts72m00.atdlibdat,
        w_cts72m00.atdhorpvt,
        w_cts72m00.atdpvtretflg,
        w_cts72m00.atddatprg,
        w_cts72m00.atdhorprg,
        w_cts72m00.atdfnlflg,
        mr_cts72m00.asitipcod,
        w_cts72m00.atdcstvlr,
        mr_cts72m00.atdprinvlcod,
        g_documento.ciaempcod
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = NOTFOUND then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 let m_atddatprg_aux = w_cts72m00.atddatprg  #-SPR-2016-01943
 let m_atdhorprg_aux = w_cts72m00.atdhorprg  #-SPR-2016-01943

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant

 #if l_errcod = 0
 #   then
 #   display 'cts02m08_sel_cota ok'
 #else
 #   display 'cts02m08_sel_cota erro ', l_errcod
 #   display l_errmsg clipped
 #end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant

 #if l_errcod != 0
 #   then
 #   display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
 #   display l_errmsg clipped
 #end if
 # PSI-2013-00440PR

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts72m00[1].lclidttxt   ,
                         a_cts72m00[1].lgdtip      ,
                         a_cts72m00[1].lgdnom      ,
                         a_cts72m00[1].lgdnum      ,
                         a_cts72m00[1].lclbrrnom   ,
                         a_cts72m00[1].brrnom      ,
                         a_cts72m00[1].cidnom      ,
                         a_cts72m00[1].ufdcod      ,
                         a_cts72m00[1].lclrefptotxt,
                         a_cts72m00[1].endzon      ,
                         a_cts72m00[1].lgdcep      ,
                         a_cts72m00[1].lgdcepcmp   ,
                         a_cts72m00[1].lclltt      ,
                         a_cts72m00[1].lcllgt      ,
                         a_cts72m00[1].dddcod      ,
                         a_cts72m00[1].lcltelnum   ,
                         a_cts72m00[1].lclcttnom   ,
                         a_cts72m00[1].c24lclpdrcod,
                         a_cts72m00[1].celteldddcod,
                         a_cts72m00[1].celtelnum   ,
                         a_cts72m00[1].endcmp,
                         ws.sqlcode,a_cts72m00[1].emeviacod
  # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts72m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts72m00[1].brrnom,
                                a_cts72m00[1].lclbrrnom)
      returning a_cts72m00[1].lclbrrnom

 select ofnnumdig into a_cts72m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if


 let a_cts72m00[1].lgdtxt = a_cts72m00[1].lgdtip clipped, " ",
                            a_cts72m00[1].lgdnom clipped, " ",
                            a_cts72m00[1].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Informacoes do local de destino
#--------------------------------------------------------------------
 if mr_cts72m00.asitipcod <> 10  then  ###  Passagem Aerea
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            2)
                  returning a_cts72m00[2].lclidttxt   ,
                            a_cts72m00[2].lgdtip      ,
                            a_cts72m00[2].lgdnom      ,
                            a_cts72m00[2].lgdnum      ,
                            a_cts72m00[2].lclbrrnom   ,
                            a_cts72m00[2].brrnom      ,
                            a_cts72m00[2].cidnom      ,
                            a_cts72m00[2].ufdcod      ,
                            a_cts72m00[2].lclrefptotxt,
                            a_cts72m00[2].endzon      ,
                            a_cts72m00[2].lgdcep      ,
                            a_cts72m00[2].lgdcepcmp   ,
                            a_cts72m00[2].lclltt      ,
                            a_cts72m00[2].lcllgt      ,
                            a_cts72m00[2].dddcod      ,
                            a_cts72m00[2].lcltelnum   ,
                            a_cts72m00[2].lclcttnom   ,
                            a_cts72m00[2].c24lclpdrcod,
                            a_cts72m00[2].celteldddcod,
                            a_cts72m00[2].celtelnum   ,
                            a_cts72m00[2].endcmp,
                            ws.sqlcode, a_cts72m00[2].emeviacod
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[2].lclbrrnom = a_cts72m00[2].lclbrrnom
    call cts06g10_monta_brr_subbrr(a_cts72m00[2].brrnom,
                                   a_cts72m00[2].lclbrrnom)
         returning a_cts72m00[2].lclbrrnom

    select ofnnumdig into a_cts72m00[2].ofnnumdig
      from datmlcl
     where atdsrvano = g_documento.atdsrvano
       and atdsrvnum = g_documento.atdsrvnum
       and c24endtip = 2

    if ws.sqlcode = 0  then
       let a_cts72m00[2].lgdtxt = a_cts72m00[2].lgdtip clipped, " ",
                                  a_cts72m00[2].lgdnom clipped, " ",
                                  a_cts72m00[2].lgdnum using "<<<<#"

       let mr_cts72m00.dstlcl    = a_cts72m00[2].lclidttxt
       let mr_cts72m00.dstlgdtxt = a_cts72m00[2].lgdtxt
       let mr_cts72m00.dstbrrnom = a_cts72m00[2].lclbrrnom
       let mr_cts72m00.dstcidnom = a_cts72m00[2].cidnom
       let mr_cts72m00.dstufdcod = a_cts72m00[2].ufdcod
    else
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

#--->>> Endereco de correspondencia - PSI SPR-2014-28503
 #--------------------------------------------------------------------
 # Informacoes do local da correspondencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         7)
               returning a_cts72m00[3].lclidttxt   ,
                         a_cts72m00[3].lgdtip      ,
                         a_cts72m00[3].lgdnom      ,
                         a_cts72m00[3].lgdnum      ,
                         a_cts72m00[3].lclbrrnom   ,
                         a_cts72m00[3].brrnom      ,
                         a_cts72m00[3].cidnom      ,
                         a_cts72m00[3].ufdcod      ,
                         a_cts72m00[3].lclrefptotxt,
                         a_cts72m00[3].endzon      ,
                         a_cts72m00[3].lgdcep      ,
                         a_cts72m00[3].lgdcepcmp   ,
                         a_cts72m00[3].lclltt      ,
                         a_cts72m00[3].lcllgt      ,
                         a_cts72m00[3].dddcod      ,
                         a_cts72m00[3].lcltelnum   ,
                         a_cts72m00[3].lclcttnom   ,
                         a_cts72m00[3].c24lclpdrcod,
                         a_cts72m00[3].celteldddcod,
                         a_cts72m00[3].celtelnum   ,
                         a_cts72m00[3].endcmp,
                         ws.sqlcode,a_cts72m00[3].emeviacod
  # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[3].lclbrrnom = a_cts72m00[3].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts72m00[3].brrnom,
                                a_cts72m00[3].lclbrrnom)
      returning a_cts72m00[3].lclbrrnom

 let a_cts72m00[3].lgdtxt = a_cts72m00[3].lgdtip clipped, " ",
                            a_cts72m00[3].lgdnom clipped, " ",
                            a_cts72m00[3].lgdnum using "<<<<#"
#---<<< Endereco de correspondencia - PSI SPR-2014-28503

 let mr_cts72m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts72m00.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts72m00.asitipcod

#---------------------------------------------------------------
# Obtencao dos dados da assistencia a passageiros
#---------------------------------------------------------------

 select refatdsrvnum, refatdsrvano,
                      asimtvcod   , #- SPR-2015-15533-Fechamento Servs GPS
        atddmccidnom, atddmcufdcod,
        atddstcidnom, atddstufdcod,
        trppfrdat   , trppfrhor   ,
        atdsrvorg
   into mr_cts72m00.refatdsrvnum   ,
        mr_cts72m00.refatdsrvano   ,
        mr_cts72m00.asimtvcod      ,
        w_cts72m00.atddmccidnom   ,
        w_cts72m00.atddmcufdcod   ,
        w_cts72m00.atddstcidnom   ,
        w_cts72m00.atddstufdcod   ,
        w_cts72m00.trppfrdat      ,
        w_cts72m00.trppfrhor      ,
        mr_cts72m00.refatdsrvorg
   from datmassistpassag, outer datmservico
  where datmassistpassag.atdsrvnum = g_documento.atdsrvnum  and
        datmassistpassag.atdsrvano = g_documento.atdsrvano  and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum  and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if mr_cts72m00.asitipcod = 10  then  ###  Passagem Aerea
    let mr_cts72m00.dstcidnom = w_cts72m00.atddstcidnom
    let mr_cts72m00.dstufdcod = w_cts72m00.atddstufdcod
 end if

#display "mr_cts72m00.refatdsrvnum = ",mr_cts72m00.refatdsrvnum
#display "mr_cts72m00.refatdsrvano = ",mr_cts72m00.refatdsrvano
#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------

 let mr_cts72m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts72m00.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts72m00.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare ccts72m00002 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach ccts72m00002 into a_passag[arr_aux].pasnom,
                               a_passag[arr_aux].pasidd,
                               ws.passeq
    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       exit foreach
    end if
 end foreach

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts72m00.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

 call cts20g01_docto(w_cts72m00.lignum)
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

 call cts20g01_docto_tot(w_cts72m00.lignum)
      returning g_documento.ligcvntip,
                g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.bnfnum,
                g_documento.crtsaunum,
                g_ppt.cmnnumdig,
                g_documento.corsus,
                g_documento.dddcod,
                g_documento.ctttel,
                g_documento.funmat,
                g_documento.cgccpfnum,
                g_documento.cgcord,
                g_documento.cgccpfdig,
                g_crtdvgflg,
                g_pss.ligdcttip,
                g_pss.ligdctnum,
                g_pss.dctitm,
                g_pss.psscntcod,
                g_cgccpf.ligdcttip,
                g_cgccpf.ligdctnum,
                g_documento.itaciacod

 --------------------------------------------------------------------
 # Informacoes do cliente #--- SPR-2015-03912-Cadastro Clientes ---
 #--------------------------------------------------------------------
 call opsfa014_conscadcli(g_documento.cgccpfnum,
                          g_documento.cgcord,
                          g_documento.cgccpfdig)
                returning lr_retcli.coderro
                         ,lr_retcli.msgerro
                         ,lr_retcli.clinom
                         ,lr_retcli.nscdat

 if lr_retcli.coderro = false then
    let lr_retcli.nscdat = null
    error lr_retcli.msgerro clipped
    prompt "Erro ao Carregar Cadastro de Clientes  - Avise Informática " for char promptX
 end if

 let mr_cts72m00.nscdat = lr_retcli.nscdat
 #--- SPR-2015-03912-Cadastro Clientes ---


 #--------------------------------------------------------------------
 # Informacoes do pedido #--- SPR-2015-03912-Cadastro Pedidos ---
 #--------------------------------------------------------------------

 call opsfa015_conscadped(g_documento.atdsrvnum,
                          g_documento.atdsrvano)
      returning lr_retped.coderro
               ,lr_retped.msgerro
               ,lr_retped.srvpedcod

 if lr_retped.coderro = false then
     if lr_retped.msgerro is null or
     	  lr_retped.msgerro = " " then
        error "NAO HA PEDIDO CADASTRADO PARA ESTE SERVICO"  #---
     else
        let lr_retped.srvpedcod = null
        error lr_retped.msgerro clipped
        prompt "Erro ao Consultar Pedido  - Avise Informática " for char promptX
     end if
 end if

 let mr_cts72m00.srvpedcod = lr_retped.srvpedcod
 #--- SPR-2015-03912-Cadastro Pedidos ---

#--- SPR-2015-03912-Cadastro Clientes ---
# if g_pss.psscntcod    is not null  then
#    let mr_cts72m00.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
# end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts72m00.ligcvntip,
        mr_cts72m00.c24solnom, g_documento.c24astcod
   from datmligacao
  where lignum = w_cts72m00.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts72m00.lignum

 ##- SPR-2015-11582 - Inicio
## if sqlca.sqlcode = notfound  then
##    let mr_cts72m00.frmflg = "N"
## else
##    let mr_cts72m00.frmflg = "S"
## end if
 ##- SPR-2015-11582 - Fim

 select cpodes into mr_cts72m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts72m00.ligcvntip

 let mr_cts72m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod
    and funmat = ws.funmat

 let mr_cts72m00.atdtxt = w_cts72m00.atddat         clipped, " ",
                         w_cts72m00.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 select cpodes
   into mr_cts72m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = w_cts72m00.vclcorcod

 if w_cts72m00.atdhorpvt is not null  or
    w_cts72m00.atdhorpvt =  "00:00"   then
    let mr_cts72m00.imdsrvflg = "S"
 end if

 if w_cts72m00.atddatprg is not null   then
    let mr_cts72m00.imdsrvflg = "N"
 end if

 if mr_cts72m00.atdlibflg = "N"  then
    let mr_cts72m00.atdlibdat = w_cts72m00.atddat
    let mr_cts72m00.atdlibhor = w_cts72m00.atdhor
 end if

 let w_cts72m00.antlibflg = mr_cts72m00.atdlibflg

 let mr_cts72m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 #=> SPR-2014-28503 - EXIBE PROPOSTA (FORMA DE PAGAMENTO)
 if g_documento.prpnum is null then
    let mr_cts72m00.prpnumdsp = " "
 else
    let mr_cts72m00.prpnumdsp = "29/", g_documento.prpnum using "&&&&&&&&"
 end if

 select cpodes
   into mr_cts72m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = mr_cts72m00.atdprinvlcod

 let mr_cts72m00.vcldes = cts15g00(mr_cts72m00.vclcoddig)

 let mr_cts72m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts72m00.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts72m00.asimtvcod

 let mr_cts72m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts72m00.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts72m00.asitipcod

 let m_c24lclpdrcod = a_cts72m00[1].c24lclpdrcod

end function

#--------------------------------------------------------#
 function cts72m00_bkp_info_dest(l_tipo, hist_cts72m00)
#--------------------------------------------------------#
  define hist_cts72m00 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts72m00_bkp      to null
     initialize m_hist_cts72m00_bkp to null

     let a_cts72m00_bkp[1].lclidttxt    = a_cts72m00[2].lclidttxt
     let a_cts72m00_bkp[1].cidnom       = a_cts72m00[2].cidnom
     let a_cts72m00_bkp[1].ufdcod       = a_cts72m00[2].ufdcod
     let a_cts72m00_bkp[1].brrnom       = a_cts72m00[2].brrnom
     let a_cts72m00_bkp[1].lclbrrnom    = a_cts72m00[2].lclbrrnom
     let a_cts72m00_bkp[1].endzon       = a_cts72m00[2].endzon
     let a_cts72m00_bkp[1].lgdtip       = a_cts72m00[2].lgdtip
     let a_cts72m00_bkp[1].lgdnom       = a_cts72m00[2].lgdnom
     let a_cts72m00_bkp[1].lgdnum       = a_cts72m00[2].lgdnum
     let a_cts72m00_bkp[1].lgdcep       = a_cts72m00[2].lgdcep
     let a_cts72m00_bkp[1].lgdcepcmp    = a_cts72m00[2].lgdcepcmp
     let a_cts72m00_bkp[1].lclltt       = a_cts72m00[2].lclltt
     let a_cts72m00_bkp[1].lcllgt       = a_cts72m00[2].lcllgt
     let a_cts72m00_bkp[1].lclrefptotxt = a_cts72m00[2].lclrefptotxt
     let a_cts72m00_bkp[1].lclcttnom    = a_cts72m00[2].lclcttnom
     let a_cts72m00_bkp[1].dddcod       = a_cts72m00[2].dddcod
     let a_cts72m00_bkp[1].lcltelnum    = a_cts72m00[2].lcltelnum
     let a_cts72m00_bkp[1].c24lclpdrcod = a_cts72m00[2].c24lclpdrcod
     let a_cts72m00_bkp[1].ofnnumdig    = a_cts72m00[2].ofnnumdig
     let a_cts72m00_bkp[1].celteldddcod = a_cts72m00[2].celteldddcod
     let a_cts72m00_bkp[1].celtelnum    = a_cts72m00[2].celtelnum
     let a_cts72m00_bkp[1].endcmp       = a_cts72m00[2].endcmp
     let m_hist_cts72m00_bkp.hist1      = hist_cts72m00.hist1
     let m_hist_cts72m00_bkp.hist2      = hist_cts72m00.hist2
     let m_hist_cts72m00_bkp.hist3      = hist_cts72m00.hist3
     let m_hist_cts72m00_bkp.hist4      = hist_cts72m00.hist4
     let m_hist_cts72m00_bkp.hist5      = hist_cts72m00.hist5
     let a_cts72m00_bkp[1].emeviacod    = a_cts72m00[2].emeviacod

     return hist_cts72m00.*

  else

     let a_cts72m00[2].lclidttxt    = a_cts72m00_bkp[1].lclidttxt
     let a_cts72m00[2].cidnom       = a_cts72m00_bkp[1].cidnom
     let a_cts72m00[2].ufdcod       = a_cts72m00_bkp[1].ufdcod
     let a_cts72m00[2].brrnom       = a_cts72m00_bkp[1].brrnom
     let a_cts72m00[2].lclbrrnom    = a_cts72m00_bkp[1].lclbrrnom
     let a_cts72m00[2].endzon       = a_cts72m00_bkp[1].endzon
     let a_cts72m00[2].lgdtip       = a_cts72m00_bkp[1].lgdtip
     let a_cts72m00[2].lgdnom       = a_cts72m00_bkp[1].lgdnom
     let a_cts72m00[2].lgdnum       = a_cts72m00_bkp[1].lgdnum
     let a_cts72m00[2].lgdcep       = a_cts72m00_bkp[1].lgdcep
     let a_cts72m00[2].lgdcepcmp    = a_cts72m00_bkp[1].lgdcepcmp
     let a_cts72m00[2].lclltt       = a_cts72m00_bkp[1].lclltt
     let a_cts72m00[2].lcllgt       = a_cts72m00_bkp[1].lcllgt
     let a_cts72m00[2].lclrefptotxt = a_cts72m00_bkp[1].lclrefptotxt
     let a_cts72m00[2].lclcttnom    = a_cts72m00_bkp[1].lclcttnom
     let a_cts72m00[2].dddcod       = a_cts72m00_bkp[1].dddcod
     let a_cts72m00[2].lcltelnum    = a_cts72m00_bkp[1].lcltelnum
     let a_cts72m00[2].c24lclpdrcod = a_cts72m00_bkp[1].c24lclpdrcod
     let a_cts72m00[2].ofnnumdig    = a_cts72m00_bkp[1].ofnnumdig
     let a_cts72m00[2].celteldddcod = a_cts72m00_bkp[1].celteldddcod
     let a_cts72m00[2].celtelnum    = a_cts72m00_bkp[1].celtelnum
     let a_cts72m00[2].endcmp       = a_cts72m00_bkp[1].endcmp
     let hist_cts72m00.hist1        = m_hist_cts72m00_bkp.hist1
     let hist_cts72m00.hist2        = m_hist_cts72m00_bkp.hist2
     let hist_cts72m00.hist3        = m_hist_cts72m00_bkp.hist3
     let hist_cts72m00.hist4        = m_hist_cts72m00_bkp.hist4
     let hist_cts72m00.hist5        = m_hist_cts72m00_bkp.hist5
     let a_cts72m00[2].emeviacod    = a_cts72m00_bkp[1].emeviacod

     return hist_cts72m00.*

  end if

end function

#-----------------------------------------#
 function cts72m00_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open c_cts72m00_005 using g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano

  whenever error continue
  fetch c_cts72m00_005 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT c_cts72m00_005: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts72m00() / C24 / cts72m00_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts72m00_verifica_op_ativa()
#-----------------------------------------#
  define lr_ret        record
         sttop         smallint
        ,errcod        smallint
        ,errdes        char(150)
  end record

  initialize lr_ret to null

  call ctb30m00_permite_alt_end_dst(g_documento.atdsrvano
                                   ,g_documento.atdsrvnum)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
     return true
  end if

  if lr_ret.sttop then
     return true
  end if

  return false

end function

#-----------------------------------------#
 function cts72m00_grava_historico()
#-----------------------------------------#
  define la_cts72m00       array[12] of record
         descricao         char (70)
  end record

  define lr_de             record
         atdsrvnum         like datmlcl.atdsrvnum
        ,atdsrvano         like datmlcl.atdsrvano
        ,lgdcep            char(9)
        ,cidnom            like datmlcl.cidnom
        ,ufdcod            like datmlcl.ufdcod
        ,lgdtip            like datmlcl.lgdtip
        ,lgdnom            like datmlcl.lgdnom
        ,lgdnum            like datmlcl.lgdnum
        ,brrnom            like datmlcl.brrnom
   end record

  define lr_para          record
         atdsrvnum        like datmlcl.atdsrvnum
        ,atdsrvano        like datmlcl.atdsrvano
        ,lgdcep           char(9)
        ,cidnom           like datmlcl.cidnom
        ,ufdcod           like datmlcl.ufdcod
        ,lgdtip           like datmlcl.lgdtip
        ,lgdnom           like datmlcl.lgdnom
        ,lgdnum           like datmlcl.lgdnum
        ,brrnom           like datmlcl.brrnom
  end record

  define lr_ret           record
         errcod           smallint   #Cod. Erro
        ,errdes           char(150)  #Descricao Erro
  end record

  define l_ind            smallint
        ,l_data           date
        ,l_hora           datetime hour to minute
        ,l_dstqtd         decimal(8,4)
        ,l_status         smallint

  initialize la_cts72m00  to null
  initialize lr_de        to null
  initialize lr_para      to null
  initialize lr_ret       to null

  let l_ind    = null
  let l_data   = null
  let l_hora   = null
  let l_dstqtd = null
  let l_status = null

  #busca a distancia entre os pontos
  whenever error continue
  select dstqtd
    into l_dstqtd
    from tmp_distancia
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_dstqtd = 0
  end if

  let la_cts72m00[01].descricao = "Informacoes do local de destino alterado"
  let la_cts72m00[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts72m00[03].descricao = "."
  let la_cts72m00[04].descricao = "DE:"
  let la_cts72m00[05].descricao = "CEP: ", a_cts72m00_bkp[1].lgdcep clipped," - ",a_cts72m00_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts72m00_bkp[1].cidnom clipped," UF: ",a_cts72m00_bkp[1].ufdcod clipped
  let la_cts72m00[06].descricao = "Logradouro: ",a_cts72m00_bkp[1].lgdtip clipped," ",a_cts72m00_bkp[1].lgdnom clipped," "
                                                ,a_cts72m00_bkp[1].lgdnum clipped," ",a_cts72m00_bkp[1].brrnom
  let la_cts72m00[07].descricao = "."
  let la_cts72m00[08].descricao = "PARA:"
  let la_cts72m00[09].descricao = "CEP: ", a_cts72m00[2].lgdcep clipped," - ", a_cts72m00[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts72m00[2].cidnom clipped," UF: ",a_cts72m00[2].ufdcod  clipped
  let la_cts72m00[10].descricao = "Logradouro: ",a_cts72m00[2].lgdtip clipped," ",a_cts72m00[2].lgdnom clipped," "
                                                ,a_cts72m00[2].lgdnum clipped," ",a_cts72m00[2].brrnom
  let la_cts72m00[11].descricao = "."
  let la_cts72m00[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts72m00[l_ind].descricao
                            ,"","","","")
        returning l_status

     if l_status <> 0  then
        error "Erro (" , l_status, ") na inclusao do historico De/Para. " sleep 3
        error "Historico podera ser gravado com problemas." sleep 3
     end if

  end for

  #Chama funcao porto socorro que envia email do comunicado de alteracao
  let lr_de.atdsrvnum = g_documento.atdsrvnum
  let lr_de.atdsrvano = g_documento.atdsrvano
  let lr_de.lgdcep    = a_cts72m00_bkp[1].lgdcep clipped,"-",a_cts72m00_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts72m00_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts72m00_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts72m00_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts72m00_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts72m00_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts72m00_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts72m00[2].lgdcep clipped,"-", a_cts72m00[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts72m00[2].cidnom clipped
  let lr_para.ufdcod    = a_cts72m00[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts72m00[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts72m00[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts72m00[2].lgdnum clipped
  let lr_para.brrnom    = a_cts72m00[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function

#=> SPR-2014-28503 - VER SE POSSUI 'VENDA' ASSOCIADA
#-------------------------------------------------------------------------------
function cts72m00_datmsrvvnd()
#-------------------------------------------------------------------------------

   whenever error continue
   select 1
     from datmsrvvnd
    where atdsrvnum = g_documento.atdsrvnum
      and atdsrvano = g_documento.atdsrvano
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   return true

end function

#=> SPR-2014-28503 - TECLAS DE FUNCAO
#-------------------------------------------------------------------------------
function cts72m00_atrtcfunc(l_param)
#-------------------------------------------------------------------------------

  define l_param     integer

  if l_param = 1   then
     let mr_teclas.func01 = "<F3> Referencia "
     let mr_teclas.func02 = "<F5> F.Pag      "
     let mr_teclas.func03 = "<F6> Historico  "
     let mr_teclas.func04 = "<F7> Impressao  "
     let mr_teclas.func05 = "<F8> Data       "
     let mr_teclas.func06 = "<F9> Conclui    "
     let mr_teclas.func07 = "<F10> Passag    "
     let mr_teclas.func08 = "<CTRL+T> Etapa  "
     let mr_teclas.func09 = "<CTRL+E> E-mail "
     let mr_teclas.func10 = "<CTRL+O> Correspond"
     let mr_teclas.func11 = "<CTRL+U> Justificat"
  end if

  if l_param = 2   then
     let mr_teclas.func01 = "<F1> Help       "
     let mr_teclas.func02 = "<F3> Referencia "
     let mr_teclas.func03 = "<F5> Venda/F.Pag"
     let mr_teclas.func04 = "<F6> Historico  "
     let mr_teclas.func05 = "<F7> Fun        "
     let mr_teclas.func06 = "<F9> Conclui    "
     let mr_teclas.func07 = "<F10> Passag    "
     let mr_teclas.func08 = "<CTRL+T> Etapa  "
     let mr_teclas.func09 = "<CTRL+E> E-mail "
     let mr_teclas.func10 = "<CTRL+O> Correspond"
     let mr_teclas.func11 = "<CTRL+U> Justificat"
  end if

  if l_param = 3   then
     let mr_teclas.func01 = "<F1> Help       "
     let mr_teclas.func02 = "<F3> Referencia "
     let mr_teclas.func03 = "<F5> F.Pagto    "
     let mr_teclas.func04 = "<F6> Historico  "
     let mr_teclas.func05 = "<F7> Fun        "
     let mr_teclas.func06 = "<F9> Conclui    "
     let mr_teclas.func07 = "<F10> Passag    "
     let mr_teclas.func08 = "<CTRL+T> Etapa  "
     let mr_teclas.func09 = "<CTRL+E> E-mail "
     let mr_teclas.func10 = "<CTRL+O> Correspond"
     let mr_teclas.func11 = "<CTRL+U> Justificat"
  end if

end function


#=> ##-- SPR-2015-15533 - Busca Descricao do Problema
#-------------------------------------------------------------------------------
function cts72m00_descpbm()
#-------------------------------------------------------------------------------

 define l_c24pbmdes like datkpbm.c24pbmdes

 let l_c24pbmdes = null

 whenever error continue
   select c24pbmdes into l_c24pbmdes
   from datkpbm
   where c24pbmcod = 1001
 whenever error stop

 if sqlca.sqlcode <> 0 then
 	 if sqlca.sqlcode <> 100 then
       error "Erro ", sqlca.sqlcode,
        " ", sqlca.sqlerrd[2],
        " AO ACESSAR 'datkpbm'!!!"
    else
    	   let l_c24pbmdes = null
    end if
 end if

 return l_c24pbmdes

end function
