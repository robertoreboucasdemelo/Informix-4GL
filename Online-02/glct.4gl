#---------------------------------------------------------------------------#
# Nome do Modulo: GLCT                                                Pedro #
#                                                                   Marcelo #
# Definicao das variaveis globais do sistema CENTRAL 24 HORAS      Set/1994 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/12/2001  PSI 140996   Ruiz         Inclusao campo flgIS096.            #
# 25/09/2002  PSI 158607   Mariana      Inclusao dos array's 'g_ppt' e      #
#                                       'g_a_pptcls' p/ atendimento do PPT  #
#---------------------------------------------------------------------------#
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# 28/10/03    Eduardo-meta   psi172413 Incluir na global documento as       #
#                            osf27987  variaveis corsus,dddcod,ctttel,      #
#                                      funmat,cgccpfnum,cgcord,cgccpfdig    #
#---------------------------------------------------------------------------#
# 18/11/2003  Meta, Jefferson 179345    Adicionar novos campos ao record    #
#                              28851    g_documento de acordo com psi179345 #
#---------------------------------------------------------------------------#
# 19/11/2003  Meta, Bruno    PSI172057  Adicionar novas variaves globais,   #
#                            OSF28991   g_corretor.*                        #
#---------------------------------------------------------------------------#
# 23/12/2003  Meta, James    PSI180475  Adicionar novas variaves globais,   #
#                            OSF 30228  g_documento.rcuccsmtvcod            #
#---------------------------------------------------------------------------#
# 30/05/2005  Meta, Junior   PSI192007  Adicionar novas variaves globais,   #
#                                       g_documento.lclocodesres            #
#---------------------------------------------------------------------------#
# 15/09/2005  Andrei, Meta   AS87408   Criar variavel g_setexplain          #
#---------------------------------------------------------------------------#
# 05/09/2007  Saulo, Meta   AS149675   Criar variaveis globais do laudo do  #
#                                      funeral (escolha dos beneficiarios)  #
#---------------------------------------------------------------------------#
# 06/05/2008  Carla Rampazzo           Criar variavel g_origem              #
#                                      Identificar quem chama as funcoes    #
#                                      "IFX" ou null  = Informix            #
#                                      "WEB"          = Portal Segurado     #
#---------------------------------------------------------------------------#
# 07/10/2008  Carla Rampazzo PSI230650 .Criar variavel g_documento.atdnum   #
#                                      Mostrar no Espelho o Nro.Atendimento #
#                                      .Criar variavel g_gera_atd para deci-#
#                                      dir se gera Atendimento na tela de   #
#                                      Assunto                              #
#---------------------------------------------------------------------------#
# 17/11/2008  Nilo Costa               Criar variavel g_cob_fun_saf         #
#                                      Verifica se tem Cobertura p/ Funeral #
#---------------------------------------------------------------------------#
# 30/12/2008  Priscila       PSI234915 Cria��o da flag semdocto em          #
#                                      g_documento                          #
#---------------------------------------------------------------------------#
# 18/03/2010  Carla Rampazzo PSI219444 .Criar variavel g_documento.rmerscseq#
#                                      p/identificar Bloco do Condominio    #
#                                      .Criar record g_rsc_re para guardar  #
#                                      endereco do Local de Risco           #
#---------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo    PSI242853 Implementacao do PSS                 #
#---------------------------------------------------------------------------#
# 06/05/2010  Carla Rampazzo PSI       Criar record g_rs_re para totalizar  #
#                                      qtd.atendimentos por Assunto/Natureza#
#                                      e Seq.Local de Risco / Bloco         #
#---------------------------------------------------------------------------#
# 14/06/2010 Danilo PSI 257664         Cria��o de variaveis auxiliares para #
#                                      registro de atendimento da central de#
#                                      opera��es                            #
#---------------------------------------------------------------------------#
# 17/09/2010 Patricia W.  PSI 260479 Inclusao de Global para ser utilizada  #
#                                    no retorno das clausulas da proposta   #
#                                    no Espelho da Proposta (retorno da     #
#                                    funcao faemc916_clausulas_proposta)    #
#---------------------------------------------------------------------------#
# 25/10/2010 Carla Rampazzo  PSI       Criar record g_hdk para controles    #
#                                      de atendimentos de Help Desk         #
#                                      (atendimento / presencial)           #
#---------------------------------------------------------------------------#
# 08/09/2011 Marcos Goes              Inclus�o de campos novos na global    #
#                                     de documentos Itau devido a alteracao #
#                                     no layout do arquivo de carga.        #
#---------------------------------------------------------------------------#
# 15/05/2012 Alberto   PSI-2012-22101  SAPS Declaracao de variaveis         #
#---------------------------------------------------------------------------#
# 16/06/2014 Alberto   PSI-2014-       Recompilacao para LI1060             #
#---------------------------------------------------------------------------#
# 03/08/2015 Norton    SPR-2015-15533 Inclusao de campos record g_documentos#
#---------------------------------------------------------------------------#
# 27/10/2015 Alberto/Roberto ST-2015-00075 Auto Premium                     #
#############################################################################


database porto

globals

#----------------------------------------------------------------------------
# Registro de seguranca do sistema (nao alterar)
#----------------------------------------------------------------------------
 define g_issk          record
    succod          like isskfunc.succod,         # Sucursal
    funmat          like isskfunc.funmat,         # Matricula Funcionario
    funnom          like isskfunc.funnom,         # Nome Funcionario
    dptsgl          like isskfunc.dptsgl,         # Departamento - Sigla
    dpttip          like isskdepto.dpttip,        # Departamento - Tipo
    dptcod          like isskdepto.dptcod,        # Departamento - Codigo
    sissgl          like ibpksist.sissgl,         # Nome do Programa
    acsnivcod       like issmnivel.acsnivcod,     # Nivel Funcionario no Sistema
    prgsgl          like ibpkprog.prgsgl,         # Nivel Consulta no Modulo
    acsnivcns       like ibpmprogmod.acsnivcns,   # Nome do Sistema
    acsnivatl       like ibpmprogmod.acsnivatl,   # Nivel Atualizacao no Modulo
    usrtip          like isskusuario.usrtip,      # Tipo do Usuario
    empcod          like isskusuario.empcod,      # Codigo da Empresa
    iptcod          like isskdepto.iptcod,        # Codigo da Inspetoria
    usrcod          like isskusuario.usrcod,      # Codigo do Usuario
    maqsgl          like ismkmaq.maqsgl           # Codigo da Maquina
 end record

#------------------------------------------------------
# Array para utilizacao na localizacao de documentos
#------------------------------------------------------
 define g_dctoarray     array [60] of record
    succod          like abamapol.succod    ,
    ramcod          like rsamseguro.ramcod  ,
    aplnumdig       like abamapol.aplnumdig ,
    itmnumdig       like abbmdoc.itmnumdig  ,
    dctnumseq       like abbmdoc.dctnumseq  ,
    aplqtditm       smallint                ,
    segnumdig       like gsakseg.segnumdig  ,
    prporg          like rsdmdocto.prporg   ,
    prpnumdig       like rsdmdocto.prpnumdig
 end record

 define g_ppt        record
    segnumdig    like gsakseg.segnumdig,
    cmnnumdig    like pptmcmn.cmnnumdig,
    endlgdtip    like rlaklocal.endlgdtip,
    endlgdnom    like rlaklocal.endlgdnom,
    endnum       like rlaklocal.endnum,
    ufdcod       like rlaklocal.ufdcod,
    endcmp       like rlaklocal.endcmp,
    endbrr       like rlaklocal.endbrr,
    endcid       like rlaklocal.endcid,
    endcep       like rlaklocal.endcep,
    endcepcmp    like rlaklocal.endcepcmp,
    edsstt       like rsdmdocto.edsstt,
    viginc       like rsdmdocto.viginc,
    vigfnl       like rsdmdocto.vigfnl,
    emsdat       like rsdmdocto.emsdat,
    corsus       like rsampcorre.corsus,
    pgtfrm       like rsdmdadcob.pgtfrm,
    mdacod       like gfakmda.mdacod,
    lclrsccod    like rlaklocal.lclrsccod
 end record

 # Retirar as 4 Ultimas Variaveis Apos Implanta��o

 define g_pss        record
    psscntcod    like kspmcntrsm.psscntcod   ,
    nom          like datmservico.nom        ,
    situacao     char(30)                    ,
    viginc       date                        ,
    vigfnl       date                        ,
    ligdctnum    like datrligsemapl.ligdctnum,
    ligdcttip    like datrligsemapl.ligdcttip,
    relpamtxt    like igbmparam.relpamtxt    ,
    dctitm       like datrligsemapl.dctitm
 end record

 define g_pss_endereco record
  lgdtip       like datmlcl.lgdtip       ,
  lgdnom       like datmlcl.lgdnom       ,
  lgdnum       like datmlcl.lgdnum       ,
  ufdcod       like datmlcl.ufdcod       ,
  endcmp       like datmlcl.endcmp       ,
  brrnom       like datmlcl.brrnom       ,
  cidnom       like datmlcl.cidnom       ,
  lgdcep       like datmlcl.lgdcep       ,
  lgdcepcmp    like datmlcl.lgdcepcmp
 end record

 define g_pss_natureza array[500] of record
    socntzcod like datksocntz.socntzcod ,
    socntzdes like datksocntz.socntzdes
 end record

 define g_pss_servico array[2000] of record
    atdsrvano like datmservico.atdsrvano ,
    atdsrvnum like datmservico.atdsrvnum
 end record

 define g_a_pptcls   array[05] of record
    clscod       like aackcls.clscod,
    carencia     date
 end record

 define i           integer
 define g_hostname  char (20)
 define g_issparam  char (30)                     # Utilizada em PSEGSEGU2
 define v_retorno   smallint
 define g_esprtrflg char(01)  # Variavel utilizada para identificar
                              # Se existe informacao de espelho retrovisor
#------------------------------------------------------------------
# Registro para navegacao nas telas de atendimento CENTRAL 24 HORAS
#------------------------------------------------------------------
 define g_documento     record
    succod          like datrligapol.succod,       # Codigo Sucursal
    aplnumdig       like datrligapol.aplnumdig,    # Numero Apolice
    itmnumdig       like datrligapol.itmnumdig,    # Numero do Item
    edsnumref       like datrligapol.edsnumref,    # Numero do Endosso
    prporg          like datrligprp.prporg,        # Origem da Proposta
    prpnumdig       like datrligprp.prpnumdig,     # Numero da Proposta
    fcapacorg       like datrligpac.fcapacorg,     # Origem PAC
    fcapacnum       like datrligpac.fcapacnum,     # Numero PAC
    pcacarnum       like eccmpti.pcapticod,        # No. Cartao PortoCard
    pcaprpitm       like epcmitem.pcaprpitm,       # Item (Veiculo) PortoCard
    solnom          char (15),                     # Solicitante
    soltip          char (01),                     # Tipo Solicitante
    c24soltipcod    like datmligacao.c24soltipcod, # Tipo do Solicitante
    ramcod          like datrservapol.ramcod,      # Codigo Ramo
    lignum          like datmligacao.lignum,       # Numero da Ligacao
    c24astcod       like datkassunto.c24astcod,    # Assunto da Ligacao
    ligcvntip       like datmligacao.ligcvntip,    # Convenio Operacional
    atdsrvnum       like datmservico.atdsrvnum,    # Numero do Servico
    atdsrvano       like datmservico.atdsrvano,    # Ano do Servico
    sinramcod       like ssamsin.ramcod,           # Prd Parcial - Ramo sinistro
    sinano          like ssamsin.sinano,           # Prd Parcial - Ano sinistro
    sinnum          like ssamsin.sinnum,           # Prd Parcial - Num sinistro
    sinitmseq       like ssamitem.sinitmseq,       # Prd Parcial - Item p/rm 53
    acao            char (03),                     # ALT, REC ou CAN
    atdsrvorg       like datksrvtip.atdsrvorg,     # Origem do tipo de Servico
    cndslcflg       like datkassunto.cndslcflg,    # Flag solicita condutor
    lclnumseq       like rsdmlocal.lclnumseq,      # Local de Risco
    vstnumdig       like datmvistoria.vstnumdig ,  # numero da vistoria
    flgIS096        char (01)                   ,  # flag cobertura claus.096
    flgtransp       char (01)                   ,  # flag averbacao transporte
    apoio           char (01)                   ,  # flag atend. pelo apoio(S/N)
    empcodatd       like datmligatd.apoemp      ,  # empresa do atendente
    funmatatd       like datmligatd.apomat      ,  # matricula do atendente
    usrtipatd       like datmligatd.apotip      ,  # tipo do atendente
    corsus          like gcaksusep.corsus       ,  #
    dddcod          like datmreclam.dddcod      ,  # codigo da area de discagem
    ctttel          like datmreclam.ctttel      ,  # numero do telefone
    funmat          like isskfunc.funmat        ,  # matricula do funcionario
    cgccpfnum       like gsakseg.cgccpfnum      ,  # numero do CGC(CNPJ)
    cgcord          like gsakseg.cgcord         ,  # filial do CGC(CNPJ)
    cgccpfdig       like gsakseg.cgccpfdig      ,  # digito do CGC(CNPJ) ou CPF
    atdprscod       like datmservico.atdprscod ,
    atdvclsgl       like datkveiculo.atdvclsgl ,
    srrcoddig       like datmservico.srrcoddig ,
    socvclcod       like datkveiculo.socvclcod ,
    dstqtd          dec(8,4)                   ,
    prvcalc         interval hour(2) to minute ,
    lclltt          like datmlcl.lclltt        ,
    lcllgt          like datmlcl.lcllgt        ,
    rcuccsmtvcod    like datrligrcuccsmtv.rcuccsmtvcod, ## PSI 180475-Cod.Motivo
    lclocodesres    char(01),   ## PSI 192007
    crtsaunum       like datksegsau.crtsaunum,    # psi 202720 Saude
    bnfnum          like datksegsau.bnfnum,       # psi 202720 Saude
    ramgrpcod       like gtakram.ramgrpcod,       # psi 202720 Saude
    ciaempcod       like datmligacao.ciaempcod,   # psi 205206 Azul
    empcodmat	     like isskfunc.empcod,	  # psi 207233 Ccusto
						  # (matricula de quem ligou)
    atdnum          like datmatd6523.atdnum,      # Nro.Atendimento
    lignum_b16      like datmligacao.lignum,      # Nro.Ligacao Origem B16
    assuntob16      smallint,                     # flag assunto B16
    semdocto        char (01),                    # flag sem docto         #PSI234915
    sinvstnum       like datmpedvist.sinvstnum,   # Dn.Eletr-Gera P10 automatico
    sinvstano       like datmpedvist.sinvstano,   # Dn.Eletr-Gera P10 automatico
    rmerscseq       like datmsrvre.rmerscseq,     # Cod.Bloco Condominio - RE
    reg_acionamento smallint,                     # Acionamento Registro de atendimento
    itaciacod       like datkitacia.itaciacod,    # Codigo da Companhia Itau
    prpnum          like datmpgtinf.prpnum,       # numero proposta para forma Pagamento
    prpnum_flg      char(03),                     # Flag de INC. ALT OU CON
    socntzcod      like datmsrvre.socntzcod,      # Natureza        ##-SPR-2015-15533
    socntzdes      like datksocntz.socntzdes,     # Descr Natureza  ##-SPR-2015-15533
    c24pbmcod      like datkpbm.c24pbmcod,        # Problema        ##-SPR-2015-15533
    atddfttxt      like datmservico.atddfttxt,    # Descr Problema  ##-SPR-2015-15533 
    asitipcod      like datkasitip.asitipcod,     # Tipo de Assist. ##-SPR-2015-15533
    asitipabvdes   like datkasitip.asitipabvdes   # Descr Tipo de Assist ##-SPR-2015-15533
 end record

 define g_c24paxnum like datmligacao.c24paxnum    # Numero da P.A.
 define g_horario   record
        lighorinc   like datmservhist.lighorinc   # Horario do historico
 end record

 # CRM
 define g_atd_siebel smallint,    # Integracao com Siebel
        g_atd_siebel_num char(30) # Numero Servico Gerado org/servico-ano
 define g_funapol       record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

 define g_index     smallint

 # PSI 172057 - Inicio

 define g_corretor  record
    corsussol       like gcakcorr.corsuspcp,
    cornomsol       like gcakcorr.cornom,
    corsusapl       like gcakcorr.corsuspcp,
    cornomapl       like gcakcorr.cornom
 end record

 # PSI 172057

 define g_setexplain  decimal(1,0)

 define g_r1    integer,
        g_r2    integer,
        g_r3    integer,
        g_r4    integer,
        g_r5    integer,
        g_r6    integer,
        g_r7    integer,
        g_r8    integer,
        g_total integer,
        g_motivo char(40),
        g_senha_cnt char(40)

define g_hist  array[100] of record
       historico like datmhstligrcuccsmt.hstdsc
end record

define g_rec_his smallint


define g_cgccpf record
    acesso    smallint                     ,
    ligdctnum like datrligsemapl.ligdctnum ,
    ligdcttip like datrligsemapl.ligdcttip
end record

define g_crtdvgflg like datrligcgccpf.crtdvgflg  # Flag de proponente n�o localizadio(divergente)

## Variaveis do Flexvision - Alberto
define g_monitor record
       dataini   date,
       horaini   datetime hour to fraction,
       horafnl   datetime hour to fraction,
       intervalo interval hour to fraction,
       txt       char(90)
       end record

#----------------------------------------------------------------------------
# Campos para debito em centro de custo PSI207233
#----------------------------------------------------------------------------
 define g_cc              record
        anosrv            like   dbscadtippgt.anosrv,
        nrosrv            like   dbscadtippgt.nrosrv,
        pgttipcodps       like   dbscadtippgt.pgttipcodps,
        pgtmat            like   dbscadtippgt.pgtmat,
        corsus            like   dbscadtippgt.corsus,
        cadmat            like   dbscadtippgt.cadmat,
        cademp            like   dbscadtippgt.cademp,
        caddat            like   dbscadtippgt.caddat,
        atlmat            like   dbscadtippgt.atlmat,
        atlemp            like   dbscadtippgt.atlemp,
        atldat            like   dbscadtippgt.atldat,
        cctcod            like   dbscadtippgt.cctcod,
        succod            like   dbscadtippgt.succod,
        empcod            like   dbscadtippgt.empcod,
        pgtempcod	  like   dbscadtippgt.pgtempcod
 end record

 define g_saf_diascarencia like vtamsegurocmp.doecrndiaqtd
       ,g_parceira         smallint
       ,g_segnumdig        like gsakseg.segnumdig
       ,g_cgccpfnum        like gsakseg.cgccpfnum
       ,g_cgccpfdig        like gsakseg.cgccpfdig
       ,g_emsdat           like vtamdoc.emsdat
       ,g_prporg           like datrligprp.prporg
       ,g_prpnumdig        like datrligprp.prpnumdig

 -->  Endereco do Local de Risco - RE
 define g_rsc_re     record
        lgdtip       like datmlcl.lgdtip
       ,lgdnom       like datmlcl.lgdnom
       ,lgdnum       like datmlcl.lgdnum
       ,lclbrrnom    like datmlcl.lclbrrnom
       ,cidnom       like datmlcl.cidnom
       ,ufdcod       like datmlcl.ufdcod
       ,lgdcep       like datmlcl.lgdcep
       ,lgdcepcmp    like datmlcl.lgdcepcmp
       ,dddcod       like datmlcl.dddcod
       ,lclrsccod    like rlaklocal.lclrsccod
       ,lclltt       like datmlcl.lclltt
       ,lcllgt       like datmlcl.lcllgt
 end record


 --> Qt.Atendimento p/ RS - RE
 define g_rs_re      array [3000] of record
        lclnumseq    like datmsrvre.lclnumseq
       ,rmerscseq    like datmsrvre.rmerscseq
       ,c24astcod    like datkassunto.c24astcod
       ,socntzcod    like datksocntz.socntzcod
       ,socntzdes    like datksocntz.socntzdes
       ,qtd_atd      smallint
 end record


 #---------------------------------------
 --> Controles de Atendimento - Help Desk
 #---------------------------------------
 define g_hdk       record
        pode_s66    char(01) -- "S"/"N"   --> Se pode ou nao gerar S66
       ,pode_s67    char(01) -- "S"/"N"   --> Se pode ou nao gerar S67
       ,qtd_lmt     smallint              --> Limite Total (Auto/RE)
       ,qtd_utz     smallint              --> Quantidade Utilizada (Auto/RE)
       ,sld_re      char(01) --"S"im/"N"ao--> Se tem saldo (RE c/LMI)
       ,usa_re      char(01) --"S"im/"N"ao--> Se Re Contratou Servico (RE c/LMI)
       ,cancelado   char(01) --"S"im/"N"ao--> Se Docto. esta Cancelado
       ,vencido     char(01) --"S"im/"N"ao--> Se Docto. esta Vencido
       ,sem_docto   char(01) --"S"im/"N"ao--> Se Docto. esta Vencido
 end record



 ---> CallBack
 define g_lignum_abn       like datmligacao.lignum # Numero da Ligacao
 define g_abntel_abn       like datkabn.abntel     # Numero telefone em abandono
 define g_inidat_abn       like datkabn.inidat     # Data do abandono

 define g_origem           char(3)                 # Identificar quem chama as funcoes
                                                   # "IFX" ou null=Informix  ou
                                                   # "WEB"=Portal Segurado
 define g_gera_atd         char(1)                 # Trata se gera ou nao Novo Nro.Atendimento
				                   # na tela de Assunto(cta02m00)

 define g_cob_fun_saf       smallint               # Tem cobertura para Funeral
 define g_cob_fun_eme       smallint               # Tem cobertura para Serv a Residencia
 define g_funeral_segnumdig like gsakseg.segnumdig # Codigo do segurado do Vida

 define g_lignum_dcr       like datmligacao.lignum # Grava ligacao para CON com
                                                   # laudo ou nao e independente
                                                   # do atdsrvorg.
 define g_filtro record
        inicial  date,
        final    date
 end record

 define g_saldo_re record
        saldo     decimal(15,5)
       ,limite    decimal(15,5)
       ,utiliz    decimal(15,5)
       ,qtde      smallint
 end record

 define g_naturezas_re record
       qtd_eve   integer,
       qtd_cls   integer
 end record

 define g_cidcod        like datracncid.cidcod, ##PSI 232700 ligia 12/11/08
        g_atmacnprtcod  like datracncid.atmacnprtcod

 define g_vdr_blindado  char(01) # PSI 239.399 Clausula 77

 define g_rep_lig       smallint # Replicacao das Advertencias

 define g_abre_tela     char(01) # Se abre tela de Inconsistencia ou nao

 define g_flag_azul     char(01)

 define g_flag_msg      smallint

 define g_saldo         smallint

 define g_remocao    record
        flag_tem     smallint
       ,rcuccsmtvcod like datkrcuccsmtv.rcuccsmtvcod
       ,rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes
 end record
 #------------------------------------------------------------------------------
 #Criado Por Danilo Sgrott F0111099 - Responsavel por armazenar dados auxiliares
 #para o registro de atendimento da central de opera��es PSI-257664
 #------------------------------------------------------------------------------
 define g_dadosregatendctop record
        dtinicial  date,                      #Data Inicial
        hrinicial  datetime hour to second    #Hora Inicial
 end record


#---------------------------------------------------------------------
# Registro para armazenar array de clausulas de propostas (PSI 260479)
#---------------------------------------------------------------------
 define g_clausulas_proposta array [200] of record
        clscod like apbmclaus.clscod,
        clsdes like aackcls.clsdes
 end record

 define g_fatura_usr integer,
        g_fatura_emp integer,
        g_lim_diaria integer,
        g_data_ret   datetime year to second,
        g_data_dev   datetime year to second

#--------------------------------------------------------------
# Global Modelo Itau
#--------------------------------------------------------------
define g_doc_itau array [500] of record
   itaciacod          like datmitaapl.itaciacod             ,
   itaramcod          like datmitaapl.itaramcod             ,
   itaaplnum          like datmitaapl.itaaplnum             ,
   aplseqnum          like datmitaapl.aplseqnum             ,
   itaprpnum          like datmitaapl.itaprpnum             ,
   itaaplvigincdat    like datmitaapl.itaaplvigincdat       ,
   itaaplvigfnldat    like datmitaapl.itaaplvigfnldat       ,
   segnom             like datmitaapl.segnom                ,
   pestipcod          like datmitaapl.pestipcod             ,
   segcgccpfnum       like datmitaapl.segcgccpfnum          ,
   segcgcordnum       like datmitaapl.segcgcordnum          ,
   segcgccpfdig       like datmitaapl.segcgccpfdig          ,
   itaprdcod          like datmitaapl.itaprdcod             ,
   itacliscocod       like datmitaapl.itacliscocod          ,
   corsus             like datmitaapl.corsus                ,
   seglgdnom          like datmitaapl.seglgdnom             ,
   seglgdnum          like datmitaapl.seglgdnum             ,
   segendcmpdes       like datmitaapl.segendcmpdes          ,
   segbrrnom          like datmitaapl.segbrrnom             ,
   segcidnom          like datmitaapl.segcidnom             ,
   segufdsgl          like datmitaapl.segufdsgl             ,
   segcepnum          like datmitaapl.segcepnum             ,
   segcepcmpnum       like datmitaapl.segcepcmpnum          ,
   segresteldddnum    like datmitaapl.segresteldddnum       ,
   segrestelnum       like datmitaapl.segrestelnum          ,
   adniclhordat       like datmitaapl.adniclhordat          ,
   itaasiarqvrsnum    like datmitaapl.itaasiarqvrsnum       ,
   pcsseqnum          like datmitaapl.pcsseqnum             ,
   succod             like datmitaapl.succod                ,
   vipsegflg          like datmitaapl.vipsegflg             ,
   segmaiend          like datmitaapl.segmaiend             ,
   frtmdlcod          like datmitaapl.frtmdlcod             ,
   vndcnlcod          like datmitaapl.vndcnlcod             ,
   itaaplitmnum       like datmitaaplitm.itaaplitmnum       ,
   itaaplitmsttcod    like datmitaaplitm.itaaplitmsttcod    ,
   autchsnum          like datmitaaplitm.autchsnum          ,
   autplcnum          like datmitaaplitm.autplcnum          ,
   autfbrnom          like datmitaaplitm.autfbrnom          ,
   autlnhnom          like datmitaaplitm.autlnhnom          ,
   autmodnom          like datmitaaplitm.autmodnom          ,
   itavclcrgtipcod    like datmitaaplitm.itavclcrgtipcod    ,
   autfbrano          like datmitaaplitm.autfbrano          ,
   autmodano          like datmitaaplitm.autmodano          ,
   autcornom          like datmitaaplitm.autcornom          ,
   autpintipdes       like datmitaaplitm.autpintipdes       ,
   okmflg             like datmitaaplitm.okmflg             ,
   impautflg          like datmitaaplitm.impautflg          ,
   casfrqvlr          like datmitaaplitm.casfrqvlr          ,
   rsclclcepnum       like datmitaaplitm.rsclclcepnum       ,
   rcslclcepcmpnum    like datmitaaplitm.rcslclcepcmpnum    ,
   porvclcod          like datmitaaplitm.porvclcod          ,
   itasgrplncod       like datmitaaplitm.itasgrplncod       ,
   itaempasicod       like datmitaaplitm.itaempasicod       ,
   itaasisrvcod       like datmitaaplitm.itaasisrvcod       ,
   itarsrcaosrvcod    like datmitaaplitm.itarsrcaosrvcod    ,
   itaclisgmcod       like datmitaaplitm.itaclisgmcod       ,
   itaaplcanmtvcod    like datmitaaplitm.itaaplcanmtvcod    ,
   rsrcaogrtcod       like datmitaaplitm.rsrcaogrtcod       ,
   asiincdat          like datmitaaplitm.asiincdat          ,
   ubbcod             like datmitaaplitm.ubbcod             ,
   vcltipcod          like datmitaaplitm.vcltipcod          ,
   bldflg             like datmitaaplitm.bldflg             ,
   itacbtcod          like datkitacbt.itacbtcod             ,
   itaasiplncod       like datkitaasipln.itaasiplncod       ,
   rscsegcbttipcod    like datmresitaaplitm.rscsegcbttipcod ,
   rscsegimvtipcod    like datmresitaaplitm.rscsegimvtipcod ,
   rscsegrestipcod    like datmresitaaplitm.rscsegrestipcod ,
   rsclgdnom          like datmresitaaplitm.rsclgdnom       ,  
   rsclgdnum          like datmresitaaplitm.rsclgdnum       ,
   rsccpldes          like datmresitaaplitm.rsccpldes       ,
   rscbrrnom          like datmresitaaplitm.rscbrrnom       ,
   rsccidnom          like datmresitaaplitm.rsccidnom       ,
   rscestsgl          like datmresitaaplitm.rscestsgl       ,
   rsccepcod          like datmresitaaplitm.rsccepcod       ,
   rsccepcplcod       like datmresitaaplitm.rsccepcplcod
end record

define g_terceiro   record
       terceiro     char(1),
       vclcoddig    like datmservico.vclcoddig,
       vcldes       like datmservico.vcldes,
       vclanomdl    like datmservico.vclanomdl,
       vcllicnum    like datmservico.vcllicnum,
       nom          like datmservico.nom
end record
	
define g_nova   record
       clscod       like abbmclaus.clscod        ,
       perfil       smallint                     ,
       dt_cal       date                         ,
       vcl0kmflg    like abbmveic.vcl0kmflg      ,
       imsvlr       like abbmcasco.imsvlr        ,
       ctgtrfcod    like abbmcasco.ctgtrfcod     ,
       clalclcod    like abbmdoc.clalclcod       ,
       dctsgmcod    like abbmapldctsgm.dctsgmcod ,
       clisgmcod    like apamconclisgm.clisgmcod ,
       delivery     integer                      ,
       reversao     char(01)
end record

define g_novapss   record
       dctsgmcod    like abbmapldctsgm.dctsgmcod ,
       clisgmcod    like apamconclisgm.clisgmcod 
end record

	
define g_indexado record
	azlaplcod  like datkazlaplcmp.azlaplcod ,
  endnum1    like gsakend.endnum          ,
  endcid1    like gsakend.endcid          ,
  endnum2    like gsakend.endnum          ,
  endcid2    like gsakend.endcid          ,
  batch      smallint
end record
	
define g_contigencia record
	flag       smallint                     ,
  tipo       smallint                     ,
  aut        smallint                     ,
  vcllicnum  like datmcntsrv.vcllicnum    ,
  succod     like datmcntsrv.succod       ,
  ramcod     like datmcntsrv.ramcod       ,
  aplnumdig  like datmcntsrv.aplnumdig    ,
  itmnumdig  like datmcntsrv.itmnumdig    ,
  cgccpfnum  like datmcntsrv.cpfnum       ,
  cgcord     like datmcntsrv.cgcord       ,
  cpfdig     like datmcntsrv.cpfdig
end record
	
end globals
