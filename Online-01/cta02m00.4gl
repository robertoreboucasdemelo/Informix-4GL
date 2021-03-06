#---------------------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                                        #
#...........................................................................#
#  Sistema        : Central 24 horas                                        #
#  Modulo         : CTA02M00.4gl                                            #
#                   Recebimento de Ligacoes                                 #
#  Analista Resp. : Pedro / Marcelo                                         #
#  PSI            :                                                         #
#...........................................................................#
#  Desenvolvimento:                                                         #
#  Liberacao      : Dez/1994                                                #
#...........................................................................#
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Incluir chamada para laudo de si-   #
#                                       nistro R.E.                         #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 02/03/1999  PSI 7913-8   Wagner       Alteracao: na chamada do modulo     #
#                                       cts19m00 que passou a ser por para- #
#                                       metro.                              #
#---------------------------------------------------------------------------#
# 14/04/1999  PSI 7547-7   Gilberto     Inclusao da chamada para laudos de  #
#                                       assistencia passageiros hospedagem. #
#---------------------------------------------------------------------------#
# 19/07/1999  PSI 8533-2   Wagner       Modificar parametro de acesso ao    #
#                                       modulo cts14g00 para verif. Cid/UF  #
#---------------------------------------------------------------------------#
# 16/08/1999  Arnaldo      Gilberto     Permitir abertura de RPTs para fun- #
#                                       cionarios da sucursal Rio de Janeiro#
#---------------------------------------------------------------------------#
# 03/09/1999  PSI 9293-8   Gilberto     Inclusao da chamada para pesquisa   #
#                                       receptiva - perfil clausula 18      #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 01/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 02/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#                                       Nova chamada para as telas de atd   #
#                                       perda parcial                       #
#---------------------------------------------------------------------------#
# 27/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial        #
#---------------------------------------------------------------------------#
# 14/04/2000  Correio      Akio         Alteracao na chamada da pesquisa    #
#                                       clausula 18 - pgm oaeia035          #
#---------------------------------------------------------------------------#
# 03/05/2000  Sofia        Akio         Inclusao de identificador de regis- #
#                                       tro de pendencia para assunto U10   #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 30/11/2000  PSI 11149-0  Ruiz         permitir ct24h gravar w02,w04,w06.  #
#             PSI 11250-0  Ruiz         permitir w00 para proposta.         #
#             PSI 12039-1  Ruiz         permitir gravar "X" qdo <> de ct24h #
#---------------------------------------------------------------------------#
# 06/02/2001  PSI 12479-6  Ruiz         Marcacao de vistoria sinistro nos   #
#                                       postos. agendamento                 #
#---------------------------------------------------------------------------#
# 08/02/2001  PSI 11157-0  Raji         Alteracao do convenio porto card.   #
#---------------------------------------------------------------------------#
# 15/02/2001  PSI 11254-2  Ruiz         Obter o condutor do veiculo para    #
#                                       assuntos especificos.               #
#---------------------------------------------------------------------------#
# 04/04/2001  PSI 12768-0  Wagner       Alteracao qtdo assunto = W.. fazer  #
#                                       relacionamento c/servico X Bloq.pgto#
#---------------------------------------------------------------------------#
# 18/07/2001  PSI 11153-8  Raji         Inclusao laudo JIT - cts26m00       #
#---------------------------------------------------------------------------#
# 02/10/2001  PSI 13353-1  Ruiz         Marcacao de vistoria previa.        #
#                                       agendamento.                        #
#---------------------------------------------------------------------------#
# 27/12/2001  PSI 14099-6  Ruiz         Trata clausula 096.                 #
#---------------------------------------------------------------------------#
# 14/01/2002  AS  2639-5   Ruiz         Mostra os servico, sinistro RE, para#
#                                       a apolice.                          #
#---------------------------------------------------------------------------#
# 28/01/2002  AS  2693-0   Ruiz         Eliminar criticas na abertura do    #
#                                       laudo de vidros para matricula com  #
#                                       nivel 8.                            #
#---------------------------------------------------------------------------#
# 16/05/2002  PSI 15242-0  Ruiz         Chamar tela de criterios de servicos#
#                                       gratuitos.                          #
#---------------------------------------------------------------------------#
# 31/05/2002  PSI 14178-0  Ruiz         Chamar tela para averbacao trans-   #
#                                       portes.                             #
#---------------------------------------------------------------------------#
# 21/08/2002  PSI 14179-8  Ruiz         chamar tela para comunicar sinistro #
#                                       de transporte.                      #
#---------------------------------------------------------------------------#
# 10/10/2002  PSI 16258-2  Wagner       Incluir acesso a funcao informativo #
#                                       convenio ctx17g00.                  #
#---------------------------------------------------------------------------#
# 11/11/2002  PSI 159638   Ruiz         Registras ligacoes feitas nas filas #
#                                       de apoio                            #
#---------------------------------------------------------------------------#
# 12/03/2003  PSI 166871   Mariana -FSW Substituicao da funcao cta02m10 (   #
#                                       acesso direto datkgeral, datkfunc)  #
#---------------------------------------------------------------------------#
# 23/05/2003  PSI 174050   Aguinaldo C. Inclusao de Central TRACKER         #
#---------------------------------------------------------------------------#
# 07/07/2003  PSI 176087   Amaury  - FSW Criacao da funcao cta02m00_qtdatd  #
#---------------------------------------------------------------------------#
# 22/08/2003  PSI 178020   JUNIOR  - Alteracao da funcao cta02m00_qtdatd    #
#             OSF  25119          Nao bloquear a continuacao do atendimento #
#---------------------------------------------------------------------------#
# 25/08/2003  PSI 172405   Marcio  - FSW  Alterar o assunto X11 para W00    #
#             OSF  25186                                                    #
#############################################################################
#                       * * * Alteracoes * * *                              #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
# 17/09/2003  Meta,Bruno     PSI175552 Inibir linhas e chamar funcao        #
#                            OSF26077  cts30m00.                            #
#                                                                           #
# 28/10/2003  Marcelo, Meta  psi172413 Acrescentar consistencias dentro na  #
#                            osf27987  chamada e dentro da funcao           #
#                                      cta02m00_lig( )                      #
#                                                                           #
# 07/11/2003  Meta, Robson   PSI172081 Implementar as operacoes verifica a- #
#                            OSF028240 tendimento e inclui atendimento do   #
#                                      novo modulo cta02m20.                #
#                                                                           #
# 19/11/2003  Meta, Ivone    PSI172057 1-Registrar ligacao quando o corretor#
#                            OSF028991 for diferente do atual     e         #
#                                      2-Mostrar na tela as ultimas tres    #
#                                      ligacoes gravadas                    #
#                                                                           #
# 27/11/2003  Meta, Ivone       PSI172111  Incluir parametro ultima ligacao #
#                               OSF 29343  consultada na funcao             #
#                                           cts20g00_ligacao()              #
#                                                                           #
# 17/12/2003  Meta, Robson   PSI180475 Aumentar o tamanho do campo no form  #
#                            OSF030228 cta02m00. Verificar o flag obriga    #
#                                      motivo do assunto informado no momen-#
#                                      to em que o usuario digita o o codigo#
#                                      Incluir o registro na tabela de rela-#
#                                      cionamento.                          #
#                                      Apresentar as ligacoes que possuem   #
#                                      motivos cadastrados, com asterisco na#
#                                      frente do assunto.                   #
#---------------------------------------------------------------------------#
# 05/01/2004  OSF 30554 - Leandro(FSW) Atualizar telefone/email do segurado  #
#                                      conforme o cadastro de assuntos.      #
#--------------------------------------------------------------------------- #
#                     * * * A L T E R A C A O * * *                          #
#  Analista Resp. : Ligia Matge                      OSF : 30970             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 12/01/2004        #
#  Objetivo       : Alteracao das regras de Negocio da Cia., considerando    #
#                   como base a data de calculo dos orcamentos.              #
#----------------------------------------------------------------------------#
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor  Fabrica   Origem     Alteracao                           #
# ---------- ---------------- ---------- ------------------------------------#
# 13/01/2004 ivone, Meta      PSI180475  alterar tratamento de mensagens     #
#                             OSF030228                                      #
# 26/03/2004 Mariana,Fsw      CT 187747  Chamar funcao 'ogsrc021 p/ retorno  #
#                                        da data de calculo                  #
#----------------------------------------------------------------------------#
# 06/04/2004  CT 173991  Adriana(FSW) Alteracao na consistencia da hora final#
#                                     da ligacao.                            #
#--------------------------------------------------------------------------- #
# 25/05/2004  OSF 35998 Teresinha S. Inclusao da flag de email               #
# ---------------------------------------------------------------------------#
# 26/05/2004  CT 212857  Teresinha S. Alterar cursor c_cta02m00006           #
# ---------------------------------------------------------------------------#
#  Analista Resp. : Ligia Matge                      OSF : ?????             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 28/07/2004        #
#  Objetivo       : Alteracao cursor e regra                                 #
#----------------------------------------------------------------------------#
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor  Fabrica   Origem     Alteracao                           #
# ---------- ---------------- ---------- ------------------------------------#
# 16/09/2004 Marcio  Meta     PSI187550  Incluir a chamada da funcao         #
#                                        cts10g07_qtdlig() e a               #
#                                        cts20g14_motivo_con().              #
#----------------------------------------------------------------------------#
# 15/10/2004  Katiucia       CT 252794 Trocar global g_corretor.corsussol    #
#                                      pela g_documento.corsus               #
#----------------------------------------------------------------------------#
# 25/10/2004  Meta, James     PSI188514  Acrescentar tipo de solicitacao = 8 #
#----------------------------------------------------------------------------#
# 28/10/2004  META,MarcosMP   PSI.188425 Substituir trechos do codigo por    #
#   Analista: Ligia Mattge               chamadas a funcoes novas.           #
# 19/11/2004  Katiucia       CT 237981 Chamar funcao verifica assuntos       #
#----------------------------------------------------------------------------#
# 29/11/2004  Mariana, Meta  PSI188239 Obter quantidade de atendimentos para #
#                                      assuntos S10,S60  e S63.              #
#----------------------------------------------------------------------------#
# 31/01/2005 Robson, Meta     PSI190080  Incluir novas funcoes e alterar     #
#                                        funcoes existentes.                 #
#----------------------------------------------------------------------------#
# 28/02/2005 Robson Carmo,Meta PSI190080 Inclusoa de parametro na chamada    #
#                                        do cts25g00_dados_assunto.          #
#                                        Chamada do cta02m02 no F6.          #
#----------------------------------------------------------------------------#
# 11/03/2005 Daniel ,Meta     PSI191094  Chamar a funcao Cta00m06 e tratar o #
#                                        retorno no input.                   #
#                                        Implementar o dptsgl = "c24tpf"     #
#----------------------------------------------------------------------------#
# 29/03/2005 Nicolau - Envio de e-mail siniven para veiculos recuperados nos #
#                      assuntos L10,L11, L12 e L45                           #
#----------------------------------------------------------------------------#
# 30/05/2005 JUNIOR, Meta - PSI 192007 - Inicializacao da variavel:          #
#                                        g_documento.lclocodesres            #
#----------------------------------------------------------------------------#
# 15/09/2005 Andrei, Meta   AS87408     Chamar funcao cts01g01_setetapa()    #
#----------------------------------------------------------------------------#
# 01/02/2006 Priscila      Zeladoria    Buscar data e hora do banco de dados #
#----------------------------------------------------------------------------#
# 06/07/2006 Priscila      PSI 199850   Passar departamento como parametro p/#
#                                       cta02m03 - validar se usuario pode   #
#                                       abrir laudo para assunto informado   #
#----------------------------------------------------------------------------#
# 14/11/2006 Ruiz          psi 205206   Ajustes para atend. Azul Seguros.    #
# 14/02/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia     #
#----------------------------------------------------------------------------#
# 14/02/2007 Fabiano, Meta  AS 130087   Migracao para a versao 7.32          #
#----------------------------------------------------------------------------#
# 20/06/2007 Ligia Mattge   PSI 207420  Garantia estendida, charm cta02m08   #
#----------------------------------------------------------------------------#
# 06/03/2008 Amilton,Meta   PSI 219967  Quando o assunto for U11, chamar o   #
#                                       programa de sinistro via roda_prog   #
#                                       (cta00m16)                           #
#----------------------------------------------------------------------------#
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com       #
#                                       global ( Isolamento U01 )            #
#----------------------------------------------------------------------------#
# 10/11/2008 Carla Rampazzo PSI 230650  Tratar 1a. posigco do Assunto para   #
#                                       carregar pop-up com esta inicial     #
#----------------------------------------------------------------------------#
# 02/11/2008 Carla Rampazzo PSI 230650  .Gerar Nro.Atendimento a cada ligacao#
#                                       (so apoio tem opcao de nao gerar)    #
#                                       .Para caso de atendimento sem docto, #
#                                       ramo 991 ou PSS atendimento sera gera#
#                                       do na tela de localizacao de cada um #
#----------------------------------------------------------------------------#
# 24/11/2008 Carla Rampazzo PSI 230650  Tratar Assunto 423 - que sera utili- #
#                                       zado pela Cobranca p/ Reclamacoes    #
#----------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto   #
#                                      como sendo o agrupamento, buscar cod  #
#                                      agrupamento.                          #
#----------------------------------------------------------------------------#
# 02/12/2008 Carla Rampazzo PSI 230650  Retirar consistencia do depto. que   #
#                                       obriga informar o Assunto se nivel=6 #
#----------------------------------------------------------------------------#
# 09/12/2008 Amilton        PSI 223689  Bloquear as teclas de fungco quando  #
#                                       as instancias nco estiverem no Ar    #
#----------------------------------------------------------------------------#
# 17/12/2008 Carla Rampazzo PSI 230650  Liberar todos os assuntos para       #
#                                       atendentes da Teleperformance        #
#----------------------------------------------------------------------------#
# 22/12/2008 Priscila       PSI 234915  Solicitar periodo de pesquisa para   #
#                                       SUSEP sem docto                      #
#----------------------------------------------------------------------------#
# 10/03/2009 Carla Rampazzo PSI 235580  Auto Jovem-Curso Direcao Defensiva   #
#                                       Mostrar Nro.do Agendamento           #
#----------------------------------------------------------------------------#
# 22/12/2009  ??????????   Patricia W.  Envio de Informacoes SINISTRO,       #
#                                       Integracao EJB / 4GL                 #
#----------------------------------------------------------------------------#
# 29/12/2009 Patricia W.                Projeto SUCCOD - Smallint            #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo PSI 219444  Passar p/ "cta00m16_chama_prog" os   #
#                                       campos lclnumseq / rmerscseq (RE)    #
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853  Implementacao do PSS                 #
#----------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo PSI 260606  Tratar Fluxo de Reclamacao p/PSS(107)#
#----------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo PSI 000762  Tratamentos diversos para atendimento#
#                                       Help Desk Casa (HDK/HDT/S68)         #
#----------------------------------------------------------------------------#
# 25/11/2010 Helder, Meta   SA__260142_1 Quando pgrcod = 1 chamar a tela de  #
#                                        recomendacao para perguntar se o    #
#                                        cliente quer gravar o aviso sinistro#
#                                        Se sim, chama popup com os assuntos #
#                                        F10, N10 e N11. Go to WEB           #
#                                        Fun��o criada :                     #
#                                         > cta02m00_popup_recomenda()       #
#----------------------------------------------------------------------------#
# 10/02/2011 Carla Rampazzo PSI         Fluxo de Reclamacao p/ PortoSeg(518) #
#----------------------------------------------------------------------------#
# 10/09/2012 Fornax-Hamilton PSI-2012-16039/EV  - Tratativa de limite para o #
#                                                 servico S40                #
#----------------------------------------------------------------------------#
# 10/09/2012 Fornax-Hamilton PSI-2012-16125/EV  - Tratativa para as clausulas#
#                                                 37D, 37E, 37F e 37G        #
#----------------------------------------------------------------------------#
# 15/05/2013 Alberto   PSI-2012-22101   SAPS Integracao cobranca             #
#----------------------------------------------------------------------------#
# 11/06/2013 AS-2013-10854  Humberto Santos  Projeto Tapete Azul - benef�cios#
#----------------------------------------------------------------------------#
# 16/06/2013 Humberto Santos                                                 #
#                                             Inclusao dos assuntos KVB/IVB  #
#----------------------------------------------------------------------------#
# 13/11/2013 tarifa Azul 08 e 09/2013                                        #
#----------------------------------------------------------------------------#
# 01/11/2013  PSI-2013-23297            Altera��o da utiliza��o do sendmail  #
#----------------------------------------------------------------------------#
# 16/06/2014  PSI-2014-                 Recompilacao para LI1060             #
##############################################################################
# 25/03/2015 ST-2015-00006  Alberto/Roberto                                  #
#----------------------------------------------------------------------------#
# 15/05/2015 Roberto                    PJ                                   #
#----------------------------------------------------------------------------#
# 07/12/2015 Luiz Vieira                742450                               #
#----------------------------------------------------------------------------# 
# 23/03/2016 Alberto/Roberto SPR-2016-03858 - Carro Reserva Ita�, fase II.   #
#----------------------------------------------------------------------------# 


globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"


 define m_c24usrtip  like datmligacao.c24usrtip,
        m_c24empcod  like datmligacao.c24empcod
 define m_atdsrvano       like datmservico.atdsrvano,
        m_atdsrvnum       like datmservico.atdsrvnum

 define wg_psre         decimal(1,0),
        wg_c24astpgrtxt like datkassunto.c24astpgrtxt,
        wg_c24astcod    like datkassunto.c24astcod,
        wg_c24trxnum    like dammtrx.c24trxnum,
        m_prep_sql      smallint,
        m_erro          smallint,
        avsrcprd        smallint,
        l_ret           smallint
  define m_ituran   smallint
        ,m_orrdat   like adbmbaixa.orrdat
        ,m_qtd_dispo_ativo integer
        ,m_tracker  smallint

 define lr_ret          record
        resultado       smallint,
        mensagem        char(60),
        vcllicnum       like abbmveic.vcllicnum,
        vclchsinc       like abbmveic.vclchsfnl,
        vclchsfnl       like abbmveic.vclchsfnl,
        vclanofbc       like abbmveic.vclanofbc,
        vclcoddig       like abbmveic.vclcoddig

   end record

 define l_cmd           char(500)


 define l_mens          record
        msg             char(200),
        de              char(50),
        subject         char(100),
        para            char(100),
        cc              char(100)
 end record

 define l_today date,
        l_hora  datetime hour to second

 ---> Decreto - 6523
 define lr_atend        record
        atdnum_new      like datmatd6523.atdnum
 end record

---> Psi233498 - Envio de Email e SMS - Denis
define FlgEnvMsg        char(01)
define l_segnumdig      like gsakseg.segnumdig
define l_corsus         like gcaksusep.corsus
----------------------------------------------

 define m_hostname       char(12) # PSI223689 - Amilton
 define m_server         char(05) # PSI223689 - Amilton
 define m_primeira_vez   char(1)
 define flag_hdt_transf  char(03)---> Ligacao nao foi Transferida
 define flag_hdt_hst     char(70)---> Motivo
 define m_rcuccsmtvcod   like datrligrcuccsmtv.rcuccsmtvcod

 -->  Guardar o Valor Original das Viariaveis para quando voltar da opcao F6
 --> pois mostra todas as ligacoes independente do local de Risco ou Bloco
 define mr_rsc_re    record
        lclrsccod    like rlaklocal.lclrsccod
       ,lclnumseq    like datmsrvre.lclnumseq
       ,rmerscseq    like datmsrvre.rmerscseq
 end record

#Marcelo - psi172413 - inicio
#---------------------------#
 function cta02m00_prepare()
#---------------------------#
 define l_sql      char(300)

 let l_sql = ' select a.cornom ',
             '  from gcakcorr a, gcaksusep b ',
             ' where b.corsus = ? ',
             '   and a.corsuspcp = b.corsuspcp '
 prepare p_cta02m00_001 from l_sql
 declare c_cta02m00_001 cursor for p_cta02m00_001

 let l_sql = ' select funnom       ',
             '   from isskfunc     ',
             '  where funmat = ?   ',
             '    and empcod = ?   ',
             '    and usrtip = "F" '
 prepare p_cta02m00_002 from l_sql
 declare c_cta02m00_002 cursor for p_cta02m00_002

 let l_sql = " insert into datrligcor",
                          " (lignum,",
                          "  corsus,",
                          "  dctcomatdflg)",
                          "  values(?, ?, 'N') "
 prepare p_cta02m00_003 from l_sql

 let l_sql = ' select a.corsus   ',
            '   from datrligcor a, datmligacao b ',
            '  where a.lignum = b.lignum ',
            '    and a.dctcomatdflg = "N" ',
            '    and a.lignum = ? '
 prepare p_cta02m00_004 from l_sql
 declare c_cta02m00_003 cursor for p_cta02m00_004

 let l_sql = " select c24astcod   ",
             "   from datmligacao ",
             "  where lignum = ?  "
 prepare p_cta02m00_005   from l_sql
 declare c_cta02m00_004   cursor for p_cta02m00_005

 let l_sql = "select c24astexbflg, telmaiatlflg from datkassunto",
                   " where c24astcod = ?"
 prepare p_cta02m00_006 from l_sql
 declare c_cta02m00_005 cursor for p_cta02m00_006

 let l_sql = "select cpodes from datkdominio  ",
             " where cponom = ? and cpocod = ?"

 prepare p_cta02m00_007 from l_sql
 declare c_cta02m00_006 cursor for p_cta02m00_007

 let l_sql = " select c24astcod",
             "   from datrastfun ",
             "  where c24astcod = ? "

 prepare p_cta02m00_008 from l_sql
 declare c_cta02m00_007 cursor for p_cta02m00_008

 let l_sql = " select * ",
            "   from datkfun ",
            "  where empcod = ? ",
            "    and funmat = ? "

 prepare p_cta02m00_009 from l_sql
 declare c_cta02m00_008 cursor for p_cta02m00_009

 let l_sql = " select grlinf ",
             "   from datkgeral ",
             "  where grlchv = ? "

 prepare p_cta02m00_010 from l_sql
 declare c_cta02m00_009 cursor for p_cta02m00_010

 let l_sql = " delete from datkgeral ",
            "   where grlchv = ? "


 prepare p_cta02m00_011 from l_sql

 let l_sql = " insert into datkgeral",
                   " (grlchv,",
                   "  grlinf,",
                   "  atldat,",
                   "  atlhor,",
                   "  atlemp,",
                   "  atlmat)",
                   "  values(?, ?, ?, ?, ?, ?) "

 prepare p_cta02m00_012 from l_sql

 let l_sql = "select cvnnum "
                 , "  from abamapol "
                 , " where succod    = ? "
                 , "   and aplnumdig = ? "
 prepare p_cta02m00_013 from l_sql
 declare c_cta02m00_010 cursor for p_cta02m00_013

 let l_sql = "select prporgpcp "
                 , "      ,prpnumpcp "
                 , "  from abamdoc "
                 , " where succod    = ? "
                 , "   and aplnumdig = ? "
                 , "   and edsnumdig = 0 "
 prepare p_cta02m00_014 from l_sql
 declare c_cta02m00_011 cursor for p_cta02m00_014

 let l_sql = "select vclanofbc "
                 , "  from abbmveic"
                 , " where succod    = ? "
                 , "   and aplnumdig = ? "
                 , "   and itmnumdig = ? "
                 , "   and dctnumseq = ? "
 prepare p_cta02m00_015 from l_sql
 declare c_cta02m00_012 cursor for p_cta02m00_015

 let l_sql = "select atdsrvnum "
                 , "      ,atdsrvano "
                 , "  from datrservapol "
                 , " where ramcod    = ? "
                 , "   and succod    = ? "
                 , "   and aplnumdig = ? "
                 , "   and itmnumdig = ? "
 prepare p_cta02m00_016 from l_sql
 declare c_cta02m00_013 cursor for p_cta02m00_016

 let l_sql = "select 1 "
                 , "  from datmservico "
                 , " where atdsrvorg = ? "
                 , "   and atdsrvnum = ? "
                 , "   and atdsrvano = ? "
                 , "   and atddat   >= ? "
 prepare p_cta02m00_017 from l_sql
 declare c_cta02m00_014 cursor for p_cta02m00_017

 let l_sql = "select atdsrvnum "
                 , "      ,atdsrvano "
                 , "  from datmligacao a "
                 , "      ,datrligprp  b "
                 , " where b.prporg    = ? "
                 , "   and b.prpnumdig = ? "
                 , "   and a.c24astcod = ? "
                 , "   and a.lignum = b.lignum "
 prepare p_cta02m00_018 from l_sql
 declare c_cta02m00_015 cursor for p_cta02m00_018

 let l_sql = "select lignum, ",
                   "       atdsrvano, ",
                   "       atdsrvnum, ",
                   "       ligdat   , ",
                   "       lighorinc  ",
                   "  from datmligacao ",
                   "  where lignum = ? "
 prepare p_cta02m00_019 from l_sql
 declare c_cta02m00_016 cursor for p_cta02m00_019

 let l_sql = " select c24ligdsc ",
               " from datmlighist ",
              " where lignum = ? "

 prepare p_cta02m00_020 from l_sql
 declare c_cta02m00_017 cursor for p_cta02m00_020

 let l_sql = " select 1 ",
               " from datrligcor ",
              " where lignum = ? "

 prepare p_cta02m00_021 from l_sql
 declare c_cta02m00_018 cursor for p_cta02m00_021

 let l_sql = " select c24usrtip, ",
                    " c24empcod ",
               " from datmligacao ",
              " where lignum = ? "

 prepare p_cta02m00_022 from l_sql
 declare c_cta02m00_019 cursor for p_cta02m00_022


 let l_sql = "select count(*) ",
              " from iddkdominio ",
             " where cponom = 'acessotfp' ",
               " and cpodes = ? "
 prepare p_cta02m00_023 from l_sql
 declare c_cta02m00_020 cursor for p_cta02m00_023

 #PSI 230650
 let l_sql = "select c24astagp",
              " from datkassunto ",
             " where c24astcod = ? "
 prepare p_cta02m00_024 from l_sql
 declare c_cta02m00_021 cursor for p_cta02m00_024


 #-----------------------------------
 -->Verifica se Ligacao ja tem Motivo
 #-----------------------------------
 let l_sql = " select 0 "
            ,"   from datrligrcuccsmtv "
            ,"  where lignum       = ? "
            ,"    and rcuccsmtvcod = ? "
            ,"    and c24astcod    = ? "
 prepare pcta02m00025 from l_sql
 declare ccta02m00025 cursor for pcta02m00025


 #--------------------------------
 -->Relaciona Motivo com a Ligacao
 #--------------------------------
 let l_sql = " insert into datrligrcuccsmtv (lignum "
            ,"                              ,rcuccsmtvcod "
            ,"                              ,c24astcod) "
            ,"                        values(?,?,?) "
 prepare pcta02m00026 from l_sql

 let l_sql = "select cpodes from datkdominio ",              #SA__260142_1
              " where cponom = ? "
 prepare p_cta02m00_043 from l_sql
 declare c_cta02m00_040 cursor with hold for p_cta02m00_043

  let l_sql = "  select c24srvdsc   "
            , "  from datmservhist  "
            , " where atdsrvnum = ? "
            , "   and atdsrvano = ? "
 prepare p_cta02m00_044 from l_sql
 declare c_cta02m00_041 cursor with hold for p_cta02m00_044


#---------------------------
--> Tapete Azul
#--------------------------
  let l_sql = " select segnumdig "
             ," from abbmdoc "
             ," where succod = ? "
             ," and aplnumdig = ? "
             ," and dctnumseq in( select max(dctnumseq) from abbmdoc "
                               ," where succod = ? "
                               ," and aplnumdig = ? ) "
  prepare p_cta02m00_045 from l_sql
  declare c_cta02m00_042 cursor with hold for p_cta02m00_045
  let l_sql = " select cgccpfnum "
             ,"       ,cgcord "
             ,"       ,cgccpfdig "
             ," from gsakseg "
             ," where segnumdig = ? "
  prepare p_cta02m00_046 from l_sql
  declare c_cta02m00_043 cursor with hold for p_cta02m00_046
  let l_sql = " select cpodes "
             ," from datkdominio "   #879765
             ," where cponom = ? "
  prepare p_cta02m00_047 from l_sql
  declare c_cta02m00_044 cursor with hold for p_cta02m00_047
  let l_sql = " select count(a.lignum)  "
           ,"   from datrligapol a "
           ,"       ,datmligacao b "
           ,"  where a.lignum = b.lignum "
           ,"    and b.c24astcod = 'G13' "
           ,"    and a.succod = ?  "
           ,"    and a.ramcod = ?  "
           ,"    and a.aplnumdig = ? "
           ,"    and b.ligdat = today "
  prepare p_cta02m00_048 from l_sql
  declare c_cta02m00_045 cursor with hold for p_cta02m00_048
  let l_sql = " select cpodes      "
             ,"   from iddkdominio "
             ,"  where cponom = ?  "
  prepare p_cta02m00_049 from l_sql
  declare c_cta02m00_046 cursor with hold for p_cta02m00_049
#---------------------------
--> 2� Remocao
#---------------------------
  let l_sql = " select count(a.ligdat)      "
             ,"   from datmligacao a        "
             ,"       ,datrligapol b        "
             ,"  where b.succod = ?         "
             ,"    and b.ramcod = ?         "
             ,"    and b.aplnumdig = ?      "
             ,"    and b.itmnumdig = ?      "
             ,"    and a.c24astcod = ?      "
             ,"    and a.lignum = b.lignum  "
             ,"    and a.ligdat >= ?        "
  prepare p_cta02m00_050 from l_sql
  declare c_cta02m00_047 cursor with hold for p_cta02m00_050
  let l_sql = " select cpodes    "
             ," from datkdominio "
             ," where cponom = 'segunda_remocao' "
  prepare p_cta02m00_051 from l_sql
  declare c_cta02m00_048 cursor with hold for p_cta02m00_051

 let m_prep_sql = true

end function

#--------------------------------------------------------------------------
 function cta02m00_solicitar_assunto(lr_documento,lr_ppt)
#--------------------------------------------------------------------------
 define lr_documento record
    succod          like datrligapol.succod       # Codigo Sucursal
   ,aplnumdig       like datrligapol.aplnumdig    # Numero Apolice
   ,itmnumdig       like datrligapol.itmnumdig    # Numero do Item
   ,edsnumref       like datrligapol.edsnumref    # Numero do Endosso
   ,prporg          like datrligprp.prporg        # Origem da Proposta
   ,prpnumdig       like datrligprp.prpnumdig     # Numero da Proposta
   ,fcapacorg       like datrligpac.fcapacorg     # Origem PAC
   ,fcapacnum       like datrligpac.fcapacnum     # Numero PAC
   ,pcacarnum       like eccmpti.pcapticod        # No. Cartao PortoCard
   ,pcaprpitm       like epcmitem.pcaprpitm       # Item (Veiculo) PortoCard
   ,solnom          char (15)                     # Solicitante
   ,soltip          char (01)                     # Tipo Solicitante
   ,c24soltipcod    like datmligacao.c24soltipcod # Tipo do Solicitante
   ,ramcod          like datrservapol.ramcod      # Codigo Ramo
   ,lignum          like datmligacao.lignum       # Numero da Ligacao
   ,c24astcod       like datkassunto.c24astcod    # Assunto da Ligacao
   ,ligcvntip       like datmligacao.ligcvntip    # Convenio Operacional
   ,atdsrvnum       like datmservico.atdsrvnum    # Numero do Servico
   ,atdsrvano       like datmservico.atdsrvano    # Ano do Servico
   ,sinramcod       like ssamsin.ramcod           # Prd Parcial - Ramo sinistro
   ,sinano          like ssamsin.sinano           # Prd Parcial - Ano sinistro
   ,sinnum          like ssamsin.sinnum           # Prd Parcial - Num sinistro
   ,sinitmseq       like ssamitem.sinitmseq       # Prd Parcial - Item p/ramo 53
   ,acao            char (03)                     # ALT, REC ou CAN
   ,atdsrvorg       like datksrvtip.atdsrvorg     # Origem do tipo de Servico
   ,cndslcflg       like datkassunto.cndslcflg    # Flag solicita condutor
   ,lclnumseq       like rsdmlocal.lclnumseq      # Local de Risco
   ,vstnumdig       like datmvistoria.vstnumdig   # numero da vistoria
   ,flgIS096        char (01)                     # flag cobertura claus.096
   ,flgtransp       char (01)                     # flag averbacao transporte
   ,apoio           char (01)                     # flag atend. pelo apoio(S/N)
   ,empcodatd       like datmligatd.apoemp        # empresa do atendente
   ,funmatatd       like datmligatd.apomat        # matricula do atendente
   ,usrtipatd       like datmligatd.apotip        # tipo do atendente
   ,corsus          like gcaksusep.corsus         #
   ,dddcod          like datmreclam.dddcod        # codigo da area de discagem
   ,ctttel          like datmreclam.ctttel        # numero do telefone
   ,funmat          like isskfunc.funmat          # matricula do funcionario
   ,cgccpfnum       like gsakseg.cgccpfnum        # numero do CGC(CNPJ)
   ,cgcord          like gsakseg.cgcord           # filial do CGC(CNPJ)
   ,cgccpfdig       like gsakseg.cgccpfdig        # digito do CGC(CNPJ) ou CPF
   ,atdprscod       like datmservico.atdprscod
   ,atdvclsgl       like datkveiculo.atdvclsgl
   ,srrcoddig       like datmservico.srrcoddig
   ,socvclcod       like datkveiculo.socvclcod
   ,dstqtd          decimal(8,4)
   ,prvcalc         interval hour(2) to minute
   ,lclltt          like datmlcl.lclltt
   ,lcllgt          like datmlcl.lcllgt
   ,rcuccsmtvcod    like datrligrcuccsmtv.rcuccsmtvcod    ## PSI 180475 - Codigo do Motivo
   ,c24paxnum       like datmligacao.c24paxnum           # Numero da P.A.
   ,averbacao       like datrligtrpavb.trpavbnum           # PSI183431 Daniel
   ,crtsaunum       like datksegsau.crtsaunum
   ,bnfnum          like datksegsau.bnfnum
   ,ramgrpcod       like gtakram.ramgrpcod
 end record

 define lr_ppt record
    segnumdig    like gsakseg.segnumdig
   ,cmnnumdig    like pptmcmn.cmnnumdig
   ,endlgdtip    like rlaklocal.endlgdtip
   ,endlgdnom    like rlaklocal.endlgdnom
   ,endnum       like rlaklocal.endnum
   ,ufdcod       like rlaklocal.ufdcod
   ,endcmp       like rlaklocal.endcmp
   ,endbrr       like rlaklocal.endbrr
   ,endcid       like rlaklocal.endcid
   ,endcep       like rlaklocal.endcep
   ,endcepcmp    like rlaklocal.endcepcmp
   ,edsstt       like rsdmdocto.edsstt
   ,viginc       like rsdmdocto.viginc
   ,vigfnl       like rsdmdocto.vigfnl
   ,emsdat       like rsdmdocto.emsdat
   ,corsus       like rsampcorre.corsus
   ,pgtfrm       like rsdmdadcob.pgtfrm
   ,mdacod       like gfakmda.mdacod
   ,lclrsccod    like rlaklocal.lclrsccod
 end record

 define lr_cty05g01 record
    resultado char(01)
   ,dctnumseg decimal(04)
   ,vclsitatu decimal(04)
   ,autsitatu decimal(04)
   ,dmtsitatu decimal(04)
   ,dpssitatu decimal(04)
   ,appsitatu decimal(04)
   ,vidsitatu decimal(04)
 end record

 define d_cta02m00    record
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         char (72),
    obs               char (75),
    obs1              char (75)
 end record

 define ws            record
    conf              smallint                     ,
    confirma          char (01)                    ,
    ramook            char (01)                    ,
    senhaok           char (01)                    ,
    aplflg            char (01)                    ,
    docflg            char (01)                    ,
    prpflg            char (01)                    ,
    funmat            like datmligacao.c24funmat   ,
    c24aststt         like datkassunto.c24aststt   ,
    c24asttltflg      like datkassunto.c24asttltflg,
    cponom            like iddkdominio.cponom      ,
    cvnnom            char (25)                    ,
    prgcod            like datkassunto.prgcod      ,
    data              char (10)                    ,
    hora              char (05)                    ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    blqnivcod         like datkblq.blqnivcod       ,
    sinramcod         like ssamsin.ramcod          ,
    sinano            like ssamsin.sinano          ,
    sinnum            like ssamsin.sinnum          ,
    sinitmseq         like ssamitem.sinitmseq      ,
    ctcdtnom          like aeikcdt.cdtnom          ,
    ctcgccpfnum       like aeikcdt.cgccpfnum       ,
    ctcgccpfdig       like aeikcdt.cgccpfdig       ,
    cndslcflg         like datkassunto.cndslcflg   ,
    vcllicnum         like abbmveic.vcllicnum      ,
    vclchsfnl         like abbmveic.vclchsfnl      ,
    msg               char (300)                   ,
    grlchv            like datkgeral.grlchv        ,
    c24ligdsc         like datmlighist.c24ligdsc   ,
    c24txtseq         like datmlighist.c24txtseq   ,
    atdsrvnum_rcl     like datmservico.atdsrvnum   ,
    atdsrvano_rcl     like datmservico.atdsrvano   ,
    atdsrvorg_rcl     like datmservico.atdsrvorg   ,
    ituran            smallint                     ,
    ligtransp         integer                      ,
    c24atrflg         like datkassunto.c24atrflg   ,
    c24jstflg         like datkassunto.c24jstflg   ,
    contador          integer                      ,
    funnom            like isskfunc.funnom         ,
    lintxt            like dammtrxtxt.c24trxtxt    ,
    titulo            char (40)                    ,
    ret               integer                      ,
    lintxt1           like dammtrxtxt.c24trxtxt    ,
    lintxt2           char (92)                    ,
    segnumdig         like gsakseg.segnumdig       ,
    segnom            like gsakseg.segnom          ,
    ext               char (04)                    ,
    nomearq           char (100)                   ,
    linha             smallint                     ,
    c24astcod         like datrastfun.c24astcod    ,
    prepara           char(01)                     ,
    maqsgl            like ismkmaq.maqsgl          ,
    atdsrvnum         like datmligacao.atdsrvnum   ,
    atdsrvano         like datmligacao.atdsrvano   ,
    emsdat            like abamdoc.emsdat          ,
    email             char(500)                    ,
    ramcod            like gtakram.ramcod          ,
    dtresol86         date                         ,
    txt               char(100)                    ,
    vstagnnum         like avgmagn.agncod          ,
    ciaempcod         like datkastagp.ciaempcod    ,
    temsinistro       char(01)                     ,
    maides            like gsakendmai.maides
 end record

 define lr            record
        sgrorg        like rsamseguro.sgrorg    ,
        sgrnumdig     like rsamseguro.sgrnumdig ,
        rmemdlcod     like rsamseguro.rmemdlcod
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

 define msg record
    linha1            char(40),
    linha2            char(40),
    linha3            char(40),
    linha4            char(40)
 end record

 define w_totligant       integer,
        w_totligdep       integer,
        w_sinnull         smallint,
        w_ct24            char(04),
        w_grlchv          like datkgeral.grlchv,
        w_grlchvX         like datkgeral.grlchv,
        w_grlinf          like datkgeral.grlinf,
        w_empcod          char(02),
        w_funmat          char(06),
        w_empapoio        like datkfun.empcod,
        w_funapoio        like datkfun.funmat,
        w_snhapoio        like datkfun.funsnh,
        w_flag            char(01),
        w_today           date,
        w_current         datetime hour to second,
        w_prepare         char(01),
        r_datkfun         record like datkfun.*,
        l_flag_qtdatd     smallint,
        w_c24astexbflg    like datkassunto.c24astexbflg,
        w_telmaiatlflg    like datkassunto.telmaiatlflg,
        l_maimsgenvflg    char(01),
        l_webrlzflg       like datkassunto.webrlzflg,
        l_flagemail       char(01),
        l_rcuccsmtvobrflg like datkassunto.rcuccsmtvobrflg,
        l_erro            smallint,
        l_qtd_atendimento integer ,
        l_qtd_limite      integer

 define l_envio       smallint
 define l_count       smallint

 define l_passou      smallint,
        w_horafinal   char(05),
        w_lighorinc   char(05),
        w_ligdat      date,
        l_param       smallint,
        l_pestip      like gsakseg.pestip,
        l_permite     smallint,
        l_existe      smallint
 define lr_retorno    record
        resultado     smallint
       ,mensagem      char(60)
       ,cvnnum        like abamapol.cvnnum
 end record

 define lr_cts10g07   record
    resultado         smallint,
    mensagem          char(60)
 end record

 define lr_result     record
        stt           smallint,
        msg           char(80)
 end record

 define l_ret_msg char(100)

 define l_resultado    smallint
       ,l_mensagem     char(60)
       ,l_gera         char(01) ---> Controla se usuario >=7 quer gerar Atendimento
       ,l_atdnum       like datmatd6523.atdnum
       ,l_confirma     char(01)
       ,l_cabec        char(60)
       ,l_cod_erro     smallint
       ,l_data_calculo date
       ,l_clscod       char(03)
       ,l_flag_endosso char(01)
       ,l_crtstt       like datksegsau.crtstt
       ,l_qtd_serv     integer
       ,l_vlr_serv     integer



 define al_cta02m02 array[03] of record
    linha        char(01) 			---> Decreto - 6523
   ,atdnum       like datmatd6523.atdnum	---> Decreto - 6523
   ,ligdat       like datmligacao.ligdat
   ,lighorinc    like datmligacao.lighorinc
   ,funnom       like isskfunc.funnom
   ,c24solnom    like datmligacao.c24solnom
   ,c24soltipdes like datksoltip.c24soltipdes
   ,srvtxt       char (14)
   ,prpmrc       char (1)
   ,c24astcod    char (04)
   ,c24astdes    char (72)
   ,c24paxnum    like datmligacao.c24paxnum
   ,msgenv       char (01)
   ,atdetpdes    like datketapa.atdetpdes
   ,atdsrvnum    like datrligsrv.atdsrvnum
   ,atdsrvano    like datrligsrv.atdsrvano
   ,sinvstnum    like datrligsinvst.sinvstnum
   ,sinvstano    like datrligsinvst.sinvstano
   ,ramcod       like datrligsinvst.ramcod
   ,sinavsnum    like datrligsinavs.sinavsnum
   ,sinavsano    like datrligsinavs.sinavsano
   ,sinnum       like datrligsin.sinnum
   ,sinano       like datrligsin.sinano
   ,vstagnnum    like datrligagn.vstagnnum
   ,prporg       like datrligprp.prporg
   ,prpnumdig    like datrligprp.prpnumdig
 end record

 define al_cta02m02_disp array[03] of record
    linha          char(01), 			---> Decreto - 6523
    atdnum         like datmatd6523.atdnum,	---> Decreto - 6523
    ligdat         like datmligacao.ligdat,
    lighorinc      like datmligacao.lighorinc,
    funnom         like isskfunc.funnom,
    c24solnom      like datmligacao.c24solnom,
    c24soltipdes   like datksoltip.c24soltipdes,
    srvtxt         char (14),
    astcod         char(04),
    astdes         char (50),
    c24paxnum      like datmligacao.c24paxnum,
    msgenv         char (01),
    atdetpdes      like datketapa.atdetpdes,
    atdsrvnum      like datrligsrv.atdsrvnum,
    atdsrvano      like datrligsrv.atdsrvano,
    sinvstnum      like datrligsinvst.sinvstnum,
    sinvstano      like datrligsinvst.sinvstano,
    ramcod         like datrligsinvst.ramcod,
    sinavsnum      like datrligsinavs.sinavsnum,
    sinavsano      like datrligsinavs.sinavsano,
    sinnum         like datrligsin.sinnum,
    sinano         like datrligsin.sinano,
    vstagnnum      like datrligagn.vstagnnum,
    trpavbnum      like datrligtrpavb.trpavbnum
 end record

 define lr_cts05g00 record
        segnom      like gsakseg.segnom,
        corsus      like datmservico.corsus,
        cornom      like datmservico.cornom,
        cvnnom      char (20),
        vclcoddig   like datmservico.vclcoddig,
        vcldes      like datmservico.vcldes,
        vclanomdl   like datmservico.vclanomdl,
        vcllicnum   like datmservico.vcllicnum,
        vclchsinc   like abbmveic.vclchsinc,
        vclchsfnl   like abbmveic.vclchsfnl,
        vclcordes   char (12),
        vclchsnum   char(20)
  end record

 define l_i              smallint,
        l_temDaf5        smallint,
        l_temDispositivo smallint,
        l_contingencia   smallint,
        l_cortesia       smallint

 define l_flag_acesso    smallint

 define l_msg char(60)
 define l_status smallint # PSI219967 Amilton
 define l_st_erro smallint

 define l_msg_log char(100)

 define l_grlchv like datkgeral.grlchv,
        l_grlinf like datkgeral.grlinf

 define l_hora2  datetime hour to minute,
        l_hora1  datetime hour to second,
        l_data   date

 define l_dptsgl smallint,
        l_aux    smallint,
        l_aux2   char(003),
        l_atdsrvorg like datmservico.atdsrvorg,
        l_permissao integer,
        l_aux_emp14 char(01),  ---> Funeral - 2008
        l_erro_b16  smallint,
        l_c24astagp like datkassunto.c24astagp,    ##psi230650
        l_tipo_assunto like datkassunto.itaasstipcod

 define l_WEB_OK char(01)         # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes
 define l_aux_c24astcod char(04)  # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes

 define lr_hist record
      mens   like datmlighist.c24ligdsc,
      data   like datmlighist.ligdat,
      hora2  like datmlighist.lighorinc
 end record

 define lr_rethist record
       ret  smallint,
       mens char(50)
 end record

 define lr_pss record
    saldo     integer   ,
    resultado integer   ,
    mensagem  char(200) ,
    erro      smallint
 end record

 define cts37m00_reg record
        vclpdrseg    char (01),
        lcldat       like datmservico.atddat,
        delegacia    char (07)
 end record

  define lr_ramo record
        resultado  integer,
        mensagem   char(500),
        ramgrpcod  like gtakram.ramgrpcod
 end record

 define lr_retorno_re record
        coderro   smallint,
        msg       char(120)
 end record

 define l_conta_corrente  smallint
 define l_existe_clausula smallint
 define l_clausula        smallint
 define l_assunto         char(100)
 define l_limite          char(01)
 #define l_existe          smallint
 define cty27g00_ret      integer # psi-2012-22101
 # Humberto Tapete Azul
 define lr_carrinho record
        segnumdig   like abbmdoc.segnumdig,
        cgccpfnum   like gsakseg.cgccpfnum,
        cgcord      like gsakseg.cgcord,
        cgccpfdig   like gsakseg.cgccpfdig,
        cpodes      like iddkdominio.cpodes,
        param       char (12)
 end record
 define l_sqlcode smallint
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
 define l_cpodes like iddkdominio.cpodes
 define l_valor_data  date
 define l_qtde_clausulas integer
 initialize lr_retorno to null
 let m_ituran   = 0
 let m_tracker  = 0
 let m_orrdat   = null
 let m_qtd_dispo_ativo = null

 #--------------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------------
 initialize al_cta02m02 to null
 initialize al_cta02m02_disp to null
 initialize lr_cts05g00 to null
 initialize lr_atend.* to null
 initialize lr_pss.* to null
 initialize lr_ramo.* to null
 initialize lr_retorno_re.* to null
 initialize  cty27g00_ret to null # psi-2012-22101
 let l_conta_corrente = false
 let m_primeira_vez = "S"
 let l_permite = false
 let l_tipo_assunto = false
 let l_existe = false
 # Humberto Tapete Azul
 initialize lr_carrinho.* to null
 let lr_carrinho.param = 'tapete azul'
 let l_sqlcode = 0
 initialize l_msg_log to null

 let l_WEB_OK = "S"             # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes
 let l_aux_c24astcod = null     # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes
 let l_grlchv    = null
 let l_grlinf    = null
 let l_aux       = null
 let l_aux2      = null
 let l_atdsrvorg = null
 let l_permissao = null
 let l_aux_emp14 = null     ---> Funeral - 2008
 let l_erro_b16  = null
 let l_c24astagp = null     ##psi230650
 let l_qtd_serv  = null
 let l_vlr_serv  = null
 let l_count = 0
 let l_cpodes    = null
 let g_remocao.flag_tem = 0
 let g_remocao.rcuccsmtvcod = 0
 let l_valor_data     = null
 let l_qtde_clausulas = 0

 if g_setexplain = 1 then
     call cts01g01_setetapa("cta02m00 - Solicitando o assunto")
 end if

 let l_i = null
 let l_contingencia = null
 let l_passou = false
 let l_erro = false
 let lr_documento.rcuccsmtvcod = null
 let l_param  = 0
 let l_mensagem = null
 let g_documento.lclocodesres = 'N'   ### PSI 192007 - JUNIOR(META)

 let     w_totligant      = null
 let     w_totligdep      = null
 let     w_sinnull        = null
 let     w_horafinal      = null
 let     l_temDaf5        = null
 let     l_temDispositivo = null
 let     w_lighorinc      = null
 let     w_ligdat         = null
 let     l_maimsgenvflg   = null
 let     l_webrlzflg      = null
 let     l_cod_erro       = null
 let     l_data_calculo   = null
 let     l_clscod         = null
 let     l_flag_endosso   = null

 initialize  d_cta02m00, ws, erros, msg, lr,
             lr_retorno, lr_cts10g07, lr_cty05g01 to null

 let l_flag_acesso = cta00m06(g_issk.dptsgl)

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let ws.data  =  l_data
 let ws.hora  =  l_hora2
 let l_flag_qtdatd = null

 #--------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #--------------------------------------------------------------------------
 if m_prep_sql <> true or
    m_prep_sql is null then
    call cta02m00_prepare()
 end if
 
 call cty31g00_recupera_perfil(lr_documento.succod
                              ,lr_documento.aplnumdig
                              ,lr_documento.itmnumdig)
 returning g_nova.perfil    ,
           g_nova.clscod    ,
           g_nova.dt_cal    ,
           g_nova.vcl0kmflg ,
           g_nova.imsvlr    ,
           g_nova.ctgtrfcod ,
           g_nova.clalclcod ,
           g_nova.dctsgmcod ,
           g_nova.clisgmcod            
 

 if g_documento.prporg    is not null and
 	  g_documento.prpnumdig is not null then

      call faemc916_prepare()

      call faemc916_clausulas_proposta(g_documento.prporg, g_documento.prpnumdig)
      returning l_qtde_clausulas
      
      
      #--------------------------------------------           
      # Recupera o Segmento                                   
      #--------------------------------------------           
                                                              
      call cty31g00_recupera_segmento_proposta(g_documento.prporg   ,   
                                               g_documento.prpnumdig)   
                                                              
      returning g_nova.perfil    ,                            
                g_nova.dctsgmcod 
                
      let g_nova.perfil = null 
      
      #--------------------------------------------    
      # Recupera o Tipo de Atendimento                 
      #--------------------------------------------    
      
      call cty31g00_recupera_dados_proposta(g_documento.prporg   ,             
                                            g_documento.prpnumdig)   
      returning g_nova.clisgmcod                           
                                              

 end if





 call cta02m00_recupera_tapete_azul()

 ##-- Obter a ultima situacao da apolice --##
 if (lr_documento.ramcod = 31 or
     lr_documento.ramcod = 531) and
    lr_documento.aplnumdig is not null then
    call cty05g01_ultsit_apolice(lr_documento.succod
                                ,lr_documento.aplnumdig
                                ,lr_documento.itmnumdig)
    returning lr_cty05g01.*
 end if

 #------------------------
 --> Carrega grupo do ramo
 #------------------------
 if lr_documento.ramgrpcod is null or
    lr_documento.ramgrpcod =  0    then

    call cty10g00_grupo_ramo(g_documento.ciaempcod
                            ,lr_documento.ramcod)
                   returning lr_ramo.*

    let lr_documento.ramgrpcod = lr_ramo.ramgrpcod
 end if

 if g_documento.ciaempcod = 1  or
    g_documento.ciaempcod = 50 then ---> Saude
    ##-- Acertar o ramo do Auto --##
    let ws.ramcod = cta02m00_acertar_ramo(lr_documento.ramcod
                                         ,lr_documento.succod
                                         ,lr_documento.aplnumdig)

    if ws.ramcod <> lr_documento.ramcod then
       let lr_documento.ramcod = ws.ramcod
    end if
 end if

 ##-- Manter g_documento.ramcod --##
 ---> Funeral - 170408
 if lr_documento.ramcod <> 991  and
    lr_documento.ramcod <> 1391 and
    lr_documento.ramcod <> 1329 then
    let g_documento.ramcod = lr_documento.ramcod
 end if

 if g_documento.ramcod = 981  or
    g_documento.ramcod = 982  or
    g_documento.ramcod = 980  or
    g_documento.ramcod = 993  or
    g_documento.ramcod = 1329 or
    g_documento.ramcod = 980 then
    let lr_documento.ramcod = g_documento.ramcod
 end if

 if lr_documento.ramcod <> g_documento.ramcod then
    let lr_documento.ramcod = g_documento.ramcod
 end if


 #--------------------------------------------------------------------------
 # Gera Numero de Atendimento  - Inicio
 #--------------------------------------------------------------------------
 if g_gera_atd = "S" then


    ---> Sempre gera Atendimento para nivel <= 6
    let l_gera = "S"

    ---> Valida nivel para gerar ou nao o Atendimento
    #Retirado a pedido do cliente
    {if g_issk.acsnivcod >= 7 then

       initialize ws.confirma to null

       call cts08g01 ("A","S",""
                     ,"DESEJA GERAR UM NOVO ATENDIMENTO ? ","","")
            returning ws.confirma

       if ws.confirma = "N" then
          let l_gera     = "N" ---> Nao gera novo Atendimento
          let g_gera_atd = "N"
          initialize g_documento.atdnum to null
       end if
    end if}


    ---> Gera Numero de Atendimento
    if l_gera = "S" then

       begin work
       call ctd24g00_ins_atd(""                       --->atdnum
                            ,g_documento.ciaempcod
                            ,lr_documento.solnom
                            ,""                       --->flgavstransp
                            ,lr_documento.c24soltipcod
                            ,lr_documento.ramcod
                            ,""                       --->flgcar
                            ,""                       --->vcllicnum
                            ,lr_documento.corsus
                            ,lr_documento.succod
                            ,lr_documento.aplnumdig
                            ,lr_documento.itmnumdig
                            ,g_documento.itaciacod
                            ,""                       --->segnom
                            ,""                       --->pestip
                            ,lr_documento.cgccpfnum
                            ,lr_documento.cgcord
                            ,lr_documento.cgccpfdig
                            ,lr_documento.prporg
                            ,lr_documento.prpnumdig
                            ,""                       --->flgvp
                            ,lr_documento.vstnumdig
                            ,""                       --->vstdnumdig
                            ,""                       --->flgvd
                            ,""                       --->flgcp
                            ,""                       --->cpbnum
                            ,"N"                      --->semdcto
                            ,"N"                      --->ies_ppt
                            ,"N"                      --->ies_pss
                            ,lr_documento.flgtransp   --->transp
                            ,lr_documento.averbacao   --->trpavbnum
                            ,""                       --->vclchsfnl
                            ,lr_documento.sinramcod   --->sinramcod
                            ,lr_documento.sinnum      --->sinnum
                            ,lr_documento.sinano      --->sinano
                            ,""                       --->sinvstnum
                            ,""                       --->sinvstano
                            ,""                       --->flgauto
                            ,""                       --->sinautnum
                            ,""                       --->sinautano
                            ,""                       --->flgre
                            ,""                       --->sinrenum
                            ,""                       --->sinreano
                            ,""                       --->flgavs
                            ,""                       --->sinavsnum
                            ,""                       --->sinavsano
                            ,""                       --->semdoctoempcodatd
                            ,""                       --->semdoctopestip
                            ,""                       --->semdoctocgccpfnum
                            ,""                       --->semdoctocgcord
                            ,""                       --->semdoctocgccpfdig
                            ,""                       --->semdoctocorsus
                            ,""                       --->semdoctofunmat
                            ,""                       --->semdoctoempcod
                            ,""                       --->semdoctodddcod
                            ,""                       --->semdoctoctttel
                            ,g_issk.funmat
                            ,g_issk.empcod
                            ,g_issk.usrtip
                            ,lr_documento.ligcvntip)
            returning l_atdnum
                     ,l_resultado
                     ,l_mensagem

       if l_resultado <> 0 then
          error l_mensagem sleep 3

          rollback work
       else

          initialize ws.confirma
                    ,msg.linha1
                    ,msg.linha2
                    ,msg.linha3 to null

          commit work

          while ws.confirma is null or
                ws.confirma = "N"

             let msg.linha1 = "INFORME AO CLIENTE O"
             let msg.linha2 = "NUMERO DE ATENDIMENTO : "
             let msg.linha3 = "< " ,l_atdnum using "<<<<<<<&&&"," >"

             call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                  returning ws.confirma

             initialize msg.linha1
                       ,msg.linha2
                       ,msg.linha3 to null

             let msg.linha1 = "NUMERO DE ATENDIMENTO < "
                             ,l_atdnum using "<<<<<<<&&&" ," >"

             let msg.linha2 = "FOI INFORMADO AO CLIENTE?"

             call cts08g01 ("A","S","",msg.linha1,msg.linha2,"")
                  returning ws.confirma
          end while

          let g_gera_atd         = "N"  ---> para nao gerar outro Atendimento
          let g_documento.atdnum = l_atdnum

       end if
    end if
 end if
 #--------------------------------------------------------------------------
 # Gera Numero de Atendimento  - Fim
 #--------------------------------------------------------------------------

 #--------------------------------------------------------------------------
 # Verifica total de ligacoes ja cadastradas para apolice/PAC
 #--------------------------------------------------------------------------
  if g_issk.acsnivcod = 6         then

    ##-- OBTER QUANTIDADE DE LIGACOES DA APOLICE --##
    call cts10g07_qtdlig(lr_documento.succod
                        ,lr_documento.ramcod
                        ,lr_documento.aplnumdig
                        ,lr_documento.itmnumdig
                        ,lr_documento.prporg
                        ,lr_documento.prpnumdig
                        ,lr_documento.sinano
                        ,lr_documento.sinnum
                        ,lr_documento.sinitmseq
                        ,lr_ppt.cmnnumdig
                        ,lr_documento.corsus          ## CT 308846
                        ,lr_documento.cgccpfnum
                        ,lr_documento.cgcord
                        ,lr_documento.cgccpfdig
                        ,lr_documento.funmat
                        ,lr_documento.ctttel
                        ,lr_documento.crtsaunum)
    returning lr_cts10g07.resultado
             ,lr_cts10g07.mensagem
             ,w_totligant
 end if

 #---> Decreto - 6523
 call cta02m00_cria_tmp_ligacao()

 ----------------------------------------------------------------------------
 open window cta02m00 at 03,02 with form "cta02m00"
             attribute (form line first)

 #--------------------------------------------------------------------------
 # Entra com codigo do assunto referente a ligacao
 #--------------------------------------------------------------------------
 while TRUE

    let int_flag = false
    let wg_psre  = 0
    initialize ws.*          to null
    initialize lr.*          to null  ## PSI 212296-Clausula 36-Envio de Guincho
    initialize erros.*       to null
    initialize d_cta02m00.*  to null
    initialize wg_c24astcod  to null

    initialize al_cta02m02   to null   #PSI 234915
    initialize al_cta02m02_disp to null  #PSI 234915

    initialize g_vdr_blindado to null
    let g_vdr_blindado = "N" ## Aqui e inicializado como "N", sera atribuido "S" nos modulos
                             ## cts19m04 e cts19m06 PSI 239399 Clausula 77(Ctg2)
                             ## cta01m05 - ctg18

    call cts40g03_data_hora_banco(1)
         returning l_data, l_hora1
    let w_today = l_data
    let w_current = l_hora1

    display lr_documento.solnom  to  solnom  attribute(reverse)

    if lr_documento.succod    is not null  and
      (lr_documento.ramcod    =  31        or
       lr_documento.ramcod    =  531)      and
       lr_documento.aplnumdig is not null  and
       lr_documento.itmnumdig is null      then
       error " Item nao selecionado para apolice !"
       #error " Item nao selecionado para apolice. AVISE A INFORMATICA!"

       call cta02m00_anula_cgccpf()
       close window cta02m00
       return
    end if

    if lr_documento.succod    is not null  and
       lr_documento.ramcod    is not null  and
       lr_documento.aplnumdig is not null  then
       let ws.aplflg = "S"
    else
       let ws.aplflg = "N"
    end if

    if (lr_documento.succod    is not null  and
        lr_documento.ramcod    is not null  and
        lr_documento.aplnumdig is not null) or
       (lr_documento.prporg    is not null  and
        lr_documento.prpnumdig is not null) or
       (lr_documento.fcapacorg is not null  and
        lr_documento.fcapacnum is not null) or
       (lr_documento.pcacarnum is not null) or
       (lr_documento.vstnumdig is not null) or
       (lr_ppt.cmnnumdig is not null      ) or
       (lr_documento.corsus    is not null) or
       (lr_documento.ctttel    is not null) or
       (lr_documento.funmat    is not null) or
       (lr_documento.cgccpfnum is not null) or
       (lr_documento.cgcord    is not null) or
       (lr_documento.cgccpfdig is not null) or
        lr_documento.apoio     is not null  or
        g_pss.psscntcod        is not null  or
       (g_cgccpf.ligdctnum     is not null  and
	g_cgccpf.ligdctnum     <> 0       ) then
       let ws.docflg = "S"

       let m_erro = 0

        if g_setexplain = 1 then
           call cts01g01_setetapa("cta02m00 - Pesquisando 3 ultimas ligacoes")
        end if

       ##-- Obter as 3 ultimas ligacoes do segurado
       ##-- Pesquisar as ligacoes

       let g_filtro.inicial = null
       let g_filtro.final   = null

       if lr_documento.succod    is not null and
          lr_documento.ramcod    is not null and
          lr_documento.aplnumdig is not null then
          let lr_documento.prporg    = null
          let lr_documento.prpnumdig = null
       end if


       call cta02m02_pesquisar_ligacoes(2
                                       ,lr_documento.succod
                                       ,lr_documento.ramcod
                                       ,lr_documento.aplnumdig
                                       ,lr_documento.itmnumdig
                                       ,lr_documento.prporg
                                       ,lr_documento.prpnumdig
                                       ,lr_documento.fcapacorg
                                       ,lr_documento.fcapacnum
                                       ,lr_documento.apoio
                                       ,lr_documento.corsus
                                       ,lr_documento.cgccpfnum
                                       ,lr_documento.cgcord
                                       ,lr_documento.cgccpfdig
                                       ,lr_documento.funmat
                                       ,lr_documento.ctttel
                                       ,lr_ppt.cmnnumdig
                                       ,lr_documento.empcodatd
                                       ,lr_documento.funmatatd
                                       ,lr_documento.crtsaunum
                                       ,lr_documento.bnfnum
                                       ,lr_documento.ramgrpcod)
       returning m_erro
                ,l_mensagem
                ,l_cabec
                ,al_cta02m02[1].*
                ,al_cta02m02[2].*
                ,al_cta02m02[3].*
                ,l_qtd_serv
                ,l_vlr_serv

       if m_erro = 3 then
          error l_mensagem sleep 2
          let m_erro = 1
          exit while
       end if

       display l_cabec to cabec

       ## Envio de alerta despesa com servi�os acessada
       ## removido devido a inclusao de alerta ap�s a gravacao do servico
       #if g_documento.aplnumdig is not null and
       #   m_primeira_vez = 'S' then
       #   call cta02m00_enviaemail_serv_pago(l_vlr_serv,l_qtd_serv)
       #end if

       ---> Decreto - 6523
       let lr_atend.atdnum_new = null
       let lr_atend.atdnum_new = g_documento.atdnum using "##########"
       display by name lr_atend.atdnum_new attribute(reverse)

       let m_erro = 0

       for l_i = 1 to 3
           if al_cta02m02[l_i].ligdat is not null and	---> Decreto - 6523
              al_cta02m02[l_i].ligdat <> 0        then	---> Decreto - 6523
              let al_cta02m02_disp[l_i].atdnum       =  al_cta02m02[l_i].atdnum
              let al_cta02m02_disp[l_i].ligdat       =  al_cta02m02[l_i].ligdat
              let al_cta02m02_disp[l_i].lighorinc    =  al_cta02m02[l_i].lighorinc
              let al_cta02m02_disp[l_i].funnom       =  al_cta02m02[l_i].funnom
              let al_cta02m02_disp[l_i].c24solnom    =  al_cta02m02[l_i].c24solnom
              let al_cta02m02_disp[l_i].c24soltipdes =  al_cta02m02[l_i].c24soltipdes
              let al_cta02m02_disp[l_i].srvtxt       =  al_cta02m02[l_i].srvtxt
              let al_cta02m02_disp[l_i].astcod       =  al_cta02m02[l_i].c24astcod
              let al_cta02m02_disp[l_i].astdes       =  al_cta02m02[l_i].c24astdes
              let al_cta02m02_disp[l_i].c24paxnum    =  al_cta02m02[l_i].c24paxnum
              let al_cta02m02_disp[l_i].msgenv       =  al_cta02m02[l_i].msgenv
              let al_cta02m02_disp[l_i].atdetpdes    =  al_cta02m02[l_i].atdetpdes
              let al_cta02m02_disp[l_i].atdsrvnum    =  al_cta02m02[l_i].atdsrvnum
              let al_cta02m02_disp[l_i].atdsrvano    =  al_cta02m02[l_i].atdsrvano
              let al_cta02m02_disp[l_i].sinvstnum    =  al_cta02m02[l_i].sinvstnum
              let al_cta02m02_disp[l_i].sinvstano    =  al_cta02m02[l_i].sinvstano
              let al_cta02m02_disp[l_i].ramcod       =  al_cta02m02[l_i].ramcod
              let al_cta02m02_disp[l_i].sinavsnum    =  al_cta02m02[l_i].sinavsnum
              let al_cta02m02_disp[l_i].sinavsano    =  al_cta02m02[l_i].sinavsano
              let al_cta02m02_disp[l_i].sinnum       =  al_cta02m02[l_i].sinnum
              let al_cta02m02_disp[l_i].sinano       =  al_cta02m02[l_i].sinano
              let al_cta02m02_disp[l_i].vstagnnum    =  al_cta02m02[l_i].vstagnnum
              let al_cta02m02_disp[l_i].trpavbnum    =  null
              display al_cta02m02_disp[l_i].* to s_cta02m00[l_i].*
           end if
       end for

    else
       let ws.docflg = "N"
       display "Atendimento sem documento localizado!"  to  cabec
       if lr_documento.ramcod = 31 then
          let lr_documento.ramcod = 531
          ##-- Manter o g_documento.ramcod = 531 --##
          let g_documento.ramcod = 531
       end if
    end if

    if l_flag_acesso = 0 then
       let d_cta02m00.obs = "(F17)Abandona, (F6)Ligacoes"
    else
       let d_cta02m00.obs = "(F17)Abandona, (F5)Espelho,",
                            "(F6)Ligacoes"
       if lr_documento.apoio = "S" then
          let d_cta02m00.obs = "(F17)Abandona(F3)AutoCT",
                               "(F4)ConCT(F5)Esp.(F6)Ligacoes"
          if g_documento.ciaempcod = 35 then  # Azul
             let d_cta02m00.obs = "(F17)Abandona, (F5)Espelho,",
                                  "(F6)Ligacoes"
          end if
       end if
       if wg_psre = 1  then
          let d_cta02m00.obs = "(F17)Abandona,(F5)Espelho,",
                               "(F6)Todas ligacoes,(F7)P.S.RE"
          if lr_documento.apoio = "S" then
             let d_cta02m00.obs = "(F17)Abandona,(F3)AutoCT",
                                  "(F4)ConCT(F5)Esp.(F6)Ligacoes,",
                                  "(F7)P.S.RE"
          end if
       end if
       if g_documento.ciaempcod = 35 then  # Azul
          let d_cta02m00.obs = d_cta02m00.obs clipped,",(F9)Senhas"
       else
          let d_cta02m00.obs = "(F1)Funcoes,",d_cta02m00.obs clipped,",(F9)Senhas"
       end if
    end if

    call cty10g00_grupo_ramo(g_documento.ciaempcod
                            ,g_documento.ramcod)
    returning lr_ramo.*

    call cta00m06_re_contacorrente()
         returning l_conta_corrente

    if lr_ramo.ramgrpcod = 4 and
       l_conta_corrente = true then
       let d_cta02m00.obs = d_cta02m00.obs clipped,",(F10)Extrato"
    end if

    if g_documento.aplnumdig is not null and
       g_documento.ramcod = 531          then
       let d_cta02m00.obs1 = "(F8)ServPagos"
    end if

    display by name d_cta02m00.obs
    display by name d_cta02m00.obs1

    initialize lr_documento.lignum to null

    ##-- Manter o g_documento.lignum --##
    let g_documento.lignum = lr_documento.lignum

    let ws.maqsgl    = g_issk.maqsgl
    if g_issk.maqsgl = "APL" then
       let ws.maqsgl = "apl"
    end if
    let w_ct24   = "ct24"
    let w_empcod = g_issk.empcod
    let w_funmat = g_issk.funmat
    let w_grlchv = w_ct24 clipped, w_empcod clipped,
                   w_funmat clipped, ws.maqsgl
    let w_grlchvX = w_grlchv clipped, "X"

    ##-- Tratar insert/delete na datkgeral --##
    call cta02m00_trata_datkgeral (w_grlchv
                                  ,w_grlchvX)
    returning l_resultado, l_mensagem

    if l_resultado = 3 then
        error l_mensagem
    end if

    input by name d_cta02m00.c24astcod without defaults

      before field c24astcod
         initialize d_cta02m00.c24astdes    to null
         if g_atd_siebel = 1 then
            let d_cta02m00.c24astcod = g_documento.c24astcod
         end if
         let g_documento.prpnum = null
         display by name d_cta02m00.c24astdes
         display by name d_cta02m00.c24astcod attribute (reverse)

      after  field c24astcod
         display by name d_cta02m00.c24astcod
         let g_documento.prpnum = null

         let g_documento.solnom = lr_documento.solnom

        if d_cta02m00.c24astcod is not null then
           call cta00m08_ver_contingencia(1)
                returning l_contingencia

           if l_contingencia then
              next field c24astcod
           end if
        end if

        if d_cta02m00.c24astcod is null or
           length(d_cta02m00.c24astcod) <  2    then

           call cta02m03(g_issk.dptsgl
                        ,d_cta02m00.c24astcod)          #PSI 199850
               returning d_cta02m00.c24astcod,
                         d_cta02m00.c24astdes
           next field c24astcod
        end if


        call cta02m01_nivel_assunto(g_issk.acsnivcod,
                                    g_issk.succod,
                                    g_issk.dptsgl,
                                    d_cta02m00.c24astcod)
             returning lr_result.*

        if lr_result.stt = 2 then
           error lr_result.msg
           next field c24astcod
        end if

# PSI-2014-13517/IN
#------------------------------
# Verifica 2� remo��o
#------------------------------
   if d_cta02m00.c24astcod = 'GOF' or d_cta02m00.c24astcod = 'G10' or
      d_cta02m00.c24astcod = 'G11' or d_cta02m00.c24astcod = 'G12' or
      d_cta02m00.c24astcod = 'G13' or d_cta02m00.c24astcod = 'G15' or
      d_cta02m00.c24astcod = 'G21' then
       open c_cta02m00_048
       whenever error continue
       fetch c_cta02m00_048 into l_cpodes
       whenever error stop
       close c_cta02m00_048
      let l_valor_data = today - l_cpodes units day
      open c_cta02m00_047 using g_documento.succod,
                                g_documento.ramcod,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig,
                                d_cta02m00.c24astcod,
                                l_valor_data
      whenever error continue
      fetch c_cta02m00_047 into g_remocao.flag_tem
      whenever error stop
  if g_remocao.flag_tem > 0 then
      let msg.linha1 = "J� EXISTE UMA SOLICITACAO"
      let msg.linha2 = "COM MENOS DE ",l_cpodes clipped," DIAS"
      let msg.linha3 = "DESEJA CONTINUAR? "
      call cts08g01 ("A","S",""
                     ,msg.linha1 ,msg.linha2 ,msg.linha3)
          returning ws.confirma
      if ws.confirma = 'S' then
          let g_documento.c24astcod = d_cta02m00.c24astcod
          call ctc26m01()
            returning g_remocao.rcuccsmtvcod
          if g_remocao.rcuccsmtvcod is null then
             let g_documento.c24astcod = null
             next field c24astcod
          end if
      else
        let g_documento.c24astcod = null
        next field c24astcod
      end if
  end if
 end if
#-------------------------------
# Fim verifica 2� remo��o
#-------------------------------
#--S29 Taxi Terceiro Alerta - Humberto
    if d_cta02m00.c24astcod = 'S29' then
       whenever error continue
         open c_cta02m00_045 using lr_documento.succod
                                  ,lr_documento.ramcod
                                  ,lr_documento.aplnumdig
          fetch c_cta02m00_045 into l_count
        if l_count = 0 then
              let msg.linha1 = "ATENCAO! "
              let msg.linha2 = "NAO HA SOLICITACAO DE GUINCHO PARA "
              let msg.linha3 = "O TERCEIRO, NAO PODEMOS ENVIAR TAXI"
              call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                   returning ws.confirma
          next field c24astcod
        end if
    end if

# -->Clausula 048, 48R Alerta de limite- Humberto
   if d_cta02m00.c24astcod = 'G01' or d_cta02m00.c24astcod = 'G12' or
      d_cta02m00.c24astcod = 'G02' or d_cta02m00.c24astcod = 'G15' or
      d_cta02m00.c24astcod = 'G10' or d_cta02m00.c24astcod = 'G21' or
      d_cta02m00.c24astcod = 'G11' or d_cta02m00.c24astcod = 'S10' then
      call cty26g01_clausula (lr_documento.succod,
			                        lr_documento.aplnumdig,
			                        lr_documento.itmnumdig)
                    returning l_cod_erro,
                              l_clscod,
                              l_data_calculo,
                              l_flag_endosso

        if l_clscod = '048' or l_clscod = '48R' then
          if l_data_calculo >= '01/02/2014' then
             let msg.linha1 = "LIMITE DE UTILIZACAO"
             let msg.linha2 = "DE ATE 1800KM."
             let msg.linha3 = " "
             call cts08g01 ("A","N","",
                            msg.linha1,
                            msg.linha2,
                            msg.linha3)
                returning ws.confirma
          else
             let msg.linha1 = "LIMITE DE UTILIZACAO"
             let msg.linha2 = "DE ATE 1200KM."
             let msg.linha3 = " "

             call cts08g01 ("A","N","",
                            msg.linha1,
                            msg.linha2,
                            msg.linha3)
                returning ws.confirma
          end if
        end if
   end if


	{#--> PSI-2012-16125/EV - Inicio
	#------------------------------
        let l_clscod = null
	if d_cta02m00.c24astcod = 'KA1' or
	   d_cta02m00.c24astcod = 'KA2' then
           for l_i = 1 to 4
              case l_i
                 when 1
                    let l_clscod = '37D'
                 when 2
                    let l_clscod = '37E'
                 when 3
                    let l_clscod = '37F'
                 when 4
                    let l_clscod = '37G'
              end case
              let l_existe_clausula = false
              call cts44g00(g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            "", #  edsnumref,
                            l_clscod)
                 returning l_existe_clausula
              if l_existe_clausula then
                 exit for
              end if
           end for
           if l_existe_clausula then
              let msg.linha1 = "ASSUNTO NAO PERMITIDO"
              let msg.linha2 = "PARA APOLICES COM CLAUSULA ",l_clscod,"."
              let msg.linha3 = " "
              call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                   returning ws.confirma
              next field c24astcod
           end if
        end if
        #--> PSI-2012-16125/EV - Final
        #------------------------------ }
# Humberto
  let l_clscod = null
	if d_cta02m00.c24astcod = 'KMP' then
           for l_i = 1 to 5
              case l_i
                 when 1
                    let l_clscod = '37D'
                 when 2
                    let l_clscod = '37E'
                 when 3
                    let l_clscod = '37F'
                 when 4
                    let l_clscod = '37G'
                 when 5
                    let l_clscod = '37H'
              end case
              let l_existe_clausula = true
              call cts44g00_assunto_kmp(g_documento.succod,
                                        g_documento.ramcod,
                                        g_documento.aplnumdig,
                                        g_documento.itmnumdig,
                                        "",l_clscod)
                 returning l_existe_clausula
              if l_existe_clausula = true then
                 exit for
              end if
           end for
           if l_existe_clausula = false then
              let msg.linha1 = "ASSUNTO NAO PERMITIDO"
              let msg.linha2 = "PARA ESSA CLAUSULA."
              let msg.linha3 = " "
              call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                   returning ws.confirma
              next field c24astcod
           end if
        end if
# Humberto
        #--> PSI-2012-16039/EV - Inicio
        #-------------------------------
        if d_cta02m00.c24astcod = 'S40' or
        	 d_cta02m00.c24astcod = 'S41' or
        	 d_cta02m00.c24astcod = 'S42' then
           if cty31g00_nova_regra_clausula(d_cta02m00.c24astcod) then
               if d_cta02m00.c24astcod = 'S40' then
                    call cty31g00_valida_envio_guincho(g_documento.ramcod   ,
                                                       g_documento.succod   ,
                                                       g_documento.aplnumdig,
                                                       g_documento.itmnumdig,
                                                       d_cta02m00.c24astcod ,
                                                       "")
                    returning lr_ret.resultado
                             ,lr_ret.mensagem
                             ,l_limite
                             ,l_qtd_atendimento
                             ,l_qtd_limite
                    if l_limite = "S" then
                       call cts08g01('A' ,'N' ,
                                     '' ,
                                     'CONSULTE A COORDENACAO, ' ,
                                     'PARA ENVIO DE ATENDIMENTO. ' ,'' )
                       returning ws.confirma
                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    end if
               else
              	    call cty33g00_calcula_residencia(g_documento.ramcod     ,
                                                     g_documento.succod     ,
                                                     g_documento.aplnumdig  ,
                                                     g_documento.itmnumdig  ,
                                                     d_cta02m00.c24astcod   ,
                                                     lr_documento.bnfnum    ,
                                                     lr_documento.crtsaunum ,
                                                     ""                     ,
                                                     1                      )
                    returning l_limite
                    if l_limite = "S" then
                       call cts08g01('A' ,'N' ,
                                     '' ,
                                     'CONSULTE A COORDENACAO, ' ,
                                     'PARA ENVIO DE ATENDIMENTO. ' ,'' )
                       returning ws.confirma
                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    end if
              end if
           else
           	  call faemc144_clausula(g_documento.succod    ,
           	                         g_documento.aplnumdig ,
           	                         g_documento.itmnumdig )
           	  returning l_cod_erro,
           	            l_clscod,
           	            l_data_calculo,
           	            l_flag_endosso
           	  if cty34g00_valida_clausula(l_clscod) then
           	  	 if d_cta02m00.c24astcod = "S41" or
           	  	  	d_cta02m00.c24astcod = "S42" then
           	  	    call cty33g00_calcula_residencia(g_documento.ramcod     ,
           	  	                                     g_documento.succod     ,
           	  	                                     g_documento.aplnumdig  ,
           	  	                                     g_documento.itmnumdig  ,
           	  	                                     d_cta02m00.c24astcod   ,
           	  	                                     lr_documento.bnfnum    ,
           	  	                                     lr_documento.crtsaunum ,
           	  	                                     ""                     ,
           	  	                                     2                      )
                    returning l_limite
                    if l_limite = "S" then
                       call cts08g01('A' ,'N' ,
                                     '' ,
                                     'CONSULTE A COORDENACAO, ' ,
                                     'PARA ENVIO DE ATENDIMENTO. ' ,'' )
                       returning ws.confirma
                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    end if
           	      end if
           	   else
                  call cty26g00_srv_segu(g_documento.ramcod   ,
                                         g_documento.succod   ,
                                         g_documento.aplnumdig,
                                         g_documento.itmnumdig,
                                         d_cta02m00.c24astcod )
                     returning l_limite
                  if l_limite = "S" then
                     call cts08g01('A' ,'N' ,
                                   '' ,
                                   'CONSULTE A COORDENACAO, ' ,
                                   'PARA ENVIO DE ATENDIMENTO. ' ,'' )
                     returning ws.confirma
                     let d_cta02m00.c24astcod = null
                     next field c24astcod
                  end if
               end if
           end if
        end if
        #--> PSI-2012-16039/EV - final
        #------------------------------
	---> Substituir Assunto S66 e S67 por HDK ou HDT
        if d_cta02m00.c24astcod = "S66" or
           d_cta02m00.c24astcod = "S67" then

           initialize msg.linha1
                     ,msg.linha2
                     ,msg.linha3
                     ,ws.confirma to null


           if g_issk.dptsgl = "hdcorr"  then
              let msg.linha2 = "UTILIZAR O ASSUNTO 'HDK'."
           else
              let msg.linha2 = "UTILIZAR O ASSUNTO 'HDT'."
           end if


           call cts08g01 ("A","N","",msg.linha2,"","")
                returning ws.confirma

           next field c24astcod
        end if
        
        if not cty45g00_acessa_help_desk(d_cta02m00.c24astcod         ,
        	                               g_doc_itau[1].itaprdcod      ,
        	                               g_doc_itau[1].itaaplvigincdat) then
                            
           error "Apolice Sem Permissao para a Abertura deste Assunto!" 
           next field c24astcod
        end if	
                
        if not cty45g00_assunto_help_desk_itau(d_cta02m00.c24astcod) then
           next field c24astcod
        end if	
        
        if cty45g00_bloqueia_linha_marrom(d_cta02m00.c24astcod         ,
        	                                g_doc_itau[1].itaprdcod      ,
        	                                g_doc_itau[1].itaasisrvcod   ,
        	                                g_doc_itau[1].itaaplvigincdat) then 
           
           error "Apolice Sem Permissao para a Abertura deste Assunto!"
           next field c24astcod                                           
        end if
        	                                                          
        ---> Verifica se Assunto e permitido para Help Desk
        if g_issk.dptsgl = "hdcorr" then

           select cponom
             from datkdominio
            where cponom = "assuntos_hdcorr"
              and cpodes =  d_cta02m00.c24astcod


           if sqlca.sqlcode = 100  then

              let msg.linha1 = "ASSUNTO NAO  PERMITIDO"
              let msg.linha2 = "PARA SEU DEPARTAMENTO."
              let msg.linha3 = " "

              call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                   returning ws.confirma

              next field c24astcod

           end if
        end if

        ---> Verifica se Assuntos deve mostrar Mensagem do PAS
        select cponom
          from datkdominio
         where cponom = "Assuntos_PAS"
           and cpodes =  d_cta02m00.c24astcod


        if sqlca.sqlcode = 0  then

           while ws.confirma is null or
                 ws.confirma = "N"

              let msg.linha1 = "Verifique  se  este  atendimento tem"
              let msg.linha2 = "direito ao  CAR.  Consulte os postos"
              let msg.linha3 = "e regiao no Con_ct24h/Referenciadas."

              call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                   returning ws.confirma

              initialize msg.linha1
                        ,msg.linha2
                        ,msg.linha3 to null

              initialize ws.confirma to null

              call cts08g01 ("A","S","","CONFIRMA A LEITURA DO ALERTA?" ,"","")
                   returning ws.confirma
           end while
        end if


       if d_cta02m00.c24astcod = "PE1" or
          d_cta02m00.c24astcod = "PE2"  then
           error " Assunto disponivel somente no Portal do Prestador." , g_issk.dptsgl  sleep 2
           next field c24astcod
       end if

       if d_cta02m00.c24astcod = "I16" then
       	  if g_documento.semdocto = "N"    or
       	  	 g_documento.semdocto is null  then
             if not cts60m00_valida_I16(g_doc_itau[1].rsrcaogrtcod,
             	                          g_doc_itau[1].itaclisgmcod) then
                  next field c24astcod
             end if
          end if
       end if
       if g_documento.ciaempcod = 84 and
          g_documento.ramcod = 14 then
          if d_cta02m00.c24astcod = 'R80' and
             g_documento.aplnumdig is not null then
             error "ASSUNTO PERMITIDO APENAS PARA LAUDOS SEM DOCUMENTO"
             next field c24astcod
          else
	       ## ligia inibido em set/2012 deu problema com ass R06 e R15
               call cts12g06_verifica_assunto_servico(d_cta02m00.c24astcod)
                    returning l_tipo_assunto

               if l_tipo_assunto = true then
                  call cts12g06_permissao_assunto(d_cta02m00.c24astcod)
                       returning l_existe
                  if l_existe = false then
                     error "NAO EXISTE NENHUMA NATUREZA VINCULADA A ESTE ASSUNTO PARA ESTE PLANO " sleep 1
                     next field c24astcod
                  end if
               end if
          end if
       end if
       if d_cta02m00.c24astcod = 'S85' then
           call cta00m06_permissao_comodidade(d_cta02m00.c24astcod,
                                              g_documento.ramcod,
                                              g_documento.succod,
                                              g_documento.aplnumdig,
                                              g_documento.itmnumdig)
                returning l_permite
            if l_permite = false then
               let msg.linha1 = "ASSUNTO NAO  PERMITIDO"
               let msg.linha2 = "PARA ESTA CLAUSULA."
               let msg.linha3 = " "
               call cts08g01 ("A","N","" ,msg.linha1 ,msg.linha2 ,msg.linha3)
                    returning ws.confirma
               next field c24astcod
             end if
        end if


       if d_cta02m00.c24astcod = "S51" or # a pedido da AnaPaula em 03/01/08
          d_cta02m00.c24astcod = "S52" or # A pedido da AnaPaula em 09/07/08
          d_cta02m00.c24astcod = "HDT" or --> Desmembra p/ HDK ou S68
          d_cta02m00.c24astcod = "HDK" or --> Desmembra p/ S66 ou S67
          d_cta02m00.c24astcod = "S68" or --> Desmembra p/ S78 ou fica S68
          d_cta02m00.c24astcod = "S69" or
          d_cta02m00.c24astcod = "RET" then  # help desk

              ---[ carrega convenio e endosso ]-----
              open c_cta02m00_010 using g_documento.succod,
                                       g_documento.aplnumdig
              fetch c_cta02m00_010 into g_documento.ligcvntip
              close c_cta02m00_010
       end if
       --> Leva Traz
       if not cts00m42_conta_corrente(d_cta02m00.c24astcod) then
           next field c24astcod
       end if

        ---> Funeral - VEP
        if g_documento.succod    is not null  or
           g_documento.aplnumdig is not null  or
          (g_documento.prporg    is not null  and g_documento.prporg <> 0) or
          (g_documento.prpnumdig is not null  and g_documento.prpnumdig <> 0) then
           if d_cta02m00.c24astcod  = 'SAF' and
             (g_cob_fun_saf     is null     or
              g_cob_fun_saf     = '')       then
              error "Documento informado nao possui cobertura para funeral."
              next field c24astcod
           end if
        end if

        #---> Funeral - Nao existe relacionamento do Assunto SAF
        #---> e do assunto B16(transferencia)
        #---> com a empresa Previdencia (14), apenas empresa Porto (01).
        #---> Por esse motivo faremos esse "desvio".

        let l_aux_emp14 = null     ---> Funeral - 2008

        if g_documento.ciaempcod = 14 and
           (d_cta02m00.c24astcod  = 'SAF' or
            d_cta02m00.c24astcod  = 'B16' ) then
           let l_aux_emp14           = 'S'
           let g_documento.ciaempcod = 1
        end if

        # Verifica Conta Corrente do PSS

        if g_documento.ciaempcod = 43  and
           g_pss.psscntcod is not null then

           call cta00m26_verifica_saldo(d_cta02m00.c24astcod)
           returning lr_pss.saldo     ,
                     lr_pss.resultado ,
                     lr_pss.erro

           if lr_pss.erro = 1 then
              next field c24astcod
           end if
        end if

        # OBTER DADOS DO ASSUNTO
        call cts25g00_dados_assunto(1, d_cta02m00.c24astcod)
           returning lr_cts10g07.resultado,
                     lr_cts10g07.mensagem,
                     l_rcuccsmtvobrflg,
                     w_c24astexbflg,
                     w_telmaiatlflg,
                     ws.prgcod,
                     ws.c24aststt,
                     ws.c24asttltflg,
                     ws.cndslcflg,
                     ws.c24atrflg,
                     ws.c24jstflg,
                     wg_c24astpgrtxt,
                     l_maimsgenvflg,
                     l_webrlzflg,
                     ws.ciaempcod
        # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes

	if g_documento.ciaempcod = 84 then ##ligia set/2012
           if (g_documento.ramcod = 14 and d_cta02m00.c24astcod[1] = "I") or
              (g_documento.ramcod = 31 and d_cta02m00.c24astcod[1] = "R") then
	      error 'Assunto invalido para ramo desta empresa'
	      next field c24astcod
           end if
	end if

        if ws.prgcod            = 15    or
           d_cta02m00.c24astcod = "HDT" then

           call cta00m06_assunto_cort(d_cta02m00.c24astcod)
                            returning l_cortesia

           call cty10g00_grupo_ramo(g_documento.ciaempcod
                                   ,g_documento.ramcod)
                          returning lr_ramo.*

           call cta00m06_re_contacorrente()
                                returning l_conta_corrente
           if lr_ramo.ramgrpcod = 4                    and
              l_cortesia        = false                and
              l_conta_corrente  = true                 and
             (g_documento.aplnumdig is not null  or
              g_documento.crtsaunum is not null      ) then

              --> As Criticas especificas para o Help Desk serao feitas a partir
              --> da chamada da funcao cta02m00_qtdatd e nas funcoes posteriores
              --> chamadas a partir dela

              if d_cta02m00.c24astcod <> "HDK" and
                 d_cta02m00.c24astcod <> "HDT" then

                 call cts12g99_verifica_saldo(g_documento.succod
                                             ,g_documento.ramcod
                                             ,g_documento.aplnumdig
                                             ,g_documento.prporg
                                             ,g_documento.prpnumdig
                                             ,g_documento.lclnumseq
                                             ,g_documento.rmerscseq
                                             ,d_cta02m00.c24astcod)
                                    returning lr_retorno_re.coderro
                                             ,lr_retorno_re.msg

                 if lr_retorno_re.coderro = 0 then

                    if g_saldo_re.saldo <= 0 and
                       g_saldo_re.qtde = false then

                       call cts08g01("A","N"
                                    ,"LIMITE MAXIMO DE INDENIZACAO/QUANTIDADE"
                                    ,"EXCEDIDO "
                                    ," "
                                    ," ")
                           returning ws.confirma

                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    end if
                 else
                    if lr_retorno_re.coderro = 999 then

                       call cts08g01("A","N"
                                    ,"NESTA APOLICE, NAO HA NENHUMA NATUREZA "
                                    ,"ASSOCIADA AO CODIGO DE ASSUNTO ESCOLHIDO"
                                    ," "
                                    ," ")
                           returning ws.confirma

                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    else
                       error lr_retorno_re.msg sleep 2
                       let d_cta02m00.c24astcod = null
                       next field c24astcod
                    end if
                 end if
              else

                 if d_cta02m00.c24astcod = "HDK"    and
                    g_issk.dptsgl        = "ct24hs" then

                    call cts08g01("A","S",""
                                 ,"CONFIRMA ASSUNTO INFORMADO ?","","")
                      returning  ws.confirma

                    if ws.confirma = "N" then
                       initialize d_cta02m00.c24astcod to null
                       next field c24astcod
                    end if
                 end if

                 #-----------------------------------------------
                 --> Chama tela de verificacao de inconsistencias
                 #-----------------------------------------------
                 if g_documento.ciaempcod <> 35 and
                    g_documento.ciaempcod <> 40 and
                    g_documento.ciaempcod <> 43 and
                    g_documento.ciaempcod <> 84 then

                    let g_hdk.vencido   = "N"
                    let g_hdk.cancelado = "N"
                    let g_abre_tela     = "N"  --> Nao abre tela de cts01g00

                    call cts01g00 (lr_documento.ramcod
                                  ,lr_documento.succod
                                  ,lr_documento.aplnumdig
                                  ,lr_documento.itmnumdig
                                  ,lr_documento.c24astcod
                                  ,"", "", "", "", "", "", l_data, "T")
                         returning erros.*

                    if g_hdk.vencido   = "S" or
                       g_hdk.cancelado = "S" then

                       let ws.confirma  = null
                       let msg.linha1   = null

                       if g_hdk.vencido   = "S" and
                          g_hdk.cancelado = "N" then
                          let msg.linha1 = "DOCUMENTO VENCIDO."
                       end if

                       if g_hdk.vencido   = "N" and
                          g_hdk.cancelado = "S" then
                          let msg.linha1 = "DOCUMENTO CANCELADO."
                       end if

                       if g_hdk.vencido   = "S" and
                          g_hdk.cancelado = "S" then
                          let msg.linha1 = "DOCUMENTO VENCIDO E CANCELADO."
                       end if
                       #--------------------------------------------
                       --> Confirmacao para prosseguir o Atendimento
                       #--------------------------------------------
                       call cts08g01('A','S', "" , msg.linha1 , ""
                                    ,"CONFIRMA ASSUNTO INFORMADO ?")
                            returning ws.confirma

                       if ws.confirma = 'N' then
                          next field c24astcod
                       end if

                       if d_cta02m00.c24astcod = "HDK"     and
                         (g_hdk.vencido        = "S"  or
                          g_hdk.cancelado      = "S"     ) then

                          call cts08g01('A','N', ""
                                       ,"ASSUNTO NAO PERMITIDO."
                                       ,"UTILIZAR O CODIGO S68.", "")
                               returning ws.confirma

                          next field c24astcod
                       end if
                    end if
                 end if


                 #---------------------------------------------------
                 --> Verifica Limites de Atendimento p/ Porto Socorro
                 #---------------------------------------------------
                 let l_flag_qtdatd = cta02m00_qtdatd(lr_documento.ramcod
                                                    ,lr_documento.succod
                                                    ,lr_documento.aplnumdig
                                                    ,lr_documento.itmnumdig
                                                    ,d_cta02m00.c24astcod
                                                    ,lr_documento.bnfnum
                                                    ,lr_documento.crtsaunum)


                 #-------------------------------------------------------------
                 --> Para HDT(Central 24h) mesmo que nao tenha mais direito
                 --> permito prosseguir pois o Help Desk pode dar uma Cortesia
                 #-------------------------------------------------------------
                 if d_cta02m00.c24astcod = "HDT" then
                    let l_flag_qtdatd = 1
                 end if

                 if l_flag_qtdatd = 2 then
                    initialize d_cta02m00.c24astcod to null
                    next field c24astcod
                 end if
              end if
           end if
        end if

       #--------------------------------------------------------
       # Envio do Protocolo de Atendimento por SMS
       #--------------------------------------------------------
       call cty40g00(d_cta02m00.c24astcod)

        if ws.prgcod = 33  then
           if g_documento.semdocto = "S"  then
              error " Consulta/Alteracao de Aviso de Sinistro, deve estar vinculado a um Documento." sleep 2
              let d_cta02m00.c24astcod = null
              next field c24astcod
           end if

           if l_webrlzflg = "N" then
              error " Assunto disponivel somente no ambiente WEB. " sleep 2
              let d_cta02m00.c24astcod = null
              next field c24astcod
           end if

           ## Verificar se Ambiente WEB esta OK

           let l_WEB_OK = "S"
           let l_aux_c24astcod = null
           while l_WEB_OK
                 for i=1 to 4
                     if i = 1 then
                        let l_aux_c24astcod = "N10"
                     else
                        if i = 2 then
                           let l_aux_c24astcod = "N11"
                        else
                           if i = 3 then
                              let l_aux_c24astcod = "F10"
                            else
                              let l_aux_c24astcod = "AVS"
                            end if
                        end if
                     end if

                     call cts25g00_dados_assunto(1, l_aux_c24astcod)
                     returning lr_cts10g07.resultado,
                               lr_cts10g07.mensagem,
                               l_rcuccsmtvobrflg,
                               w_c24astexbflg,
                               w_telmaiatlflg,
                               ws.prgcod,
                               ws.c24aststt,
                               ws.c24asttltflg,
                               ws.cndslcflg,
                               ws.c24atrflg,
                               ws.c24jstflg,
                               wg_c24astpgrtxt,
                               l_maimsgenvflg,
                               l_webrlzflg,
                               ws.ciaempcod

                     if l_webrlzflg = "S" then
                        continue for
                     else
                        ##-- Alerta para qdo estiver fora da WEB, F10/N10/N11  --##
                        let l_WEB_OK =
                            cts08g01("A","N","", "SISTEMA WEB INDISPONIVEL PARA CONSULTAR ",
                                     "OU ALTERAR OS CODIGOS N10/N11/F10 " ,"")

                        let d_cta02m00.c24astcod = null
                        next field c24astcod
                        exit for
                     end if
                 end for
                 exit while
           end while
        end if

        # Verifica se o Segurado tem Outros Documentos
        if not cty15g00_verifica_assunto_doc(lr_documento.succod     ,
                                             lr_documento.ramcod     ,
                                             lr_documento.aplnumdig  ,
                                             lr_documento.itmnumdig  ,
                                             lr_documento.cgccpfnum  ,
                                             lr_documento.cgcord     ,
                                             lr_documento.cgccpfdig  ,
                                             d_cta02m00.c24astcod    ) then
           next field c24astcod
        end if
        # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes

        # Pedir confirmacao do assunto para nao travar a Tela PSI-206.938
        if l_webrlzflg = "S" then
           let ws.confirma  = "N"
           ##-- Pedir confirmacao do assunto --##
           let ws.confirma = cts08g01('A','S', '' ,"CONFIRMA ASSUNTO INFORMADO ?", '', '')
           if ws.confirma = 'N' then
              next field c24astcod
           end if
        end if

        if lr_cts10g07.resultado <> 1 then
           error " Assunto invalido" sleep 2
           next field c24astcod
        end if
        
        #--------------------------------------------------------
        # Valida Assunto SDF
        #--------------------------------------------------------
        if not cty39g00(d_cta02m00.c24astcod) then
           next field c24astcod
        end if  
        
        #--------------------------------------------------------
        # Valida Acesso Mercosul Azul                                     
        #--------------------------------------------------------
        
        if g_documento.ciaempcod = 35 then        
          
          if not cty41g00(d_cta02m00.c24astcod  ,
          	              g_documento.succod    , 
          	              g_documento.ramcod    ,
          	              g_documento.aplnumdig ,
          	              g_documento.itmnumdig ,
          	              g_documento.edsnumref ) then
                        
             next field c24astcod                                  
          
          end if 
        end if                               
        

        #--------------------------------------------------------   
        # Valida Assunto Empresarial                                        
        #--------------------------------------------------------   
        
        if cty22g00_verifica_empresarial(g_doc_itau[1].itaasiplncod) then 
               
            #--------------------------------------------------------
            # Valida Limite por Assunto                             
            #--------------------------------------------------------
            
            if not cty22g00_limite_assunto_empresarial(g_doc_itau[1].itaasiplncod,
            	                                         d_cta02m00.c24astcod      ,         
                                                       g_documento.itaciacod     ,
                                                       lr_documento.ramcod       ,
                                                       lr_documento.aplnumdig    ,
                                                       lr_documento.itmnumdig    ) then
               next field c24astcod                                     
            end if
        
        end if
        
        #----------------------------                                       
        # Help Desk Itau                                      
        #----------------------------                                      
        if d_cta02m00.c24astcod = 'RDT' or                               
           d_cta02m00.c24astcod = 'RDK' then                             
                                                                           
                                                                           
           if g_doc_itau[1].itaasisrvcod is not null then
                    
               #-------------------------------------------------------        
               # Conta Corrente Help Desk Itau       
               #-------------------------------------------------------        
               
               if not cty05g11(g_documento.itaciacod                 
                              ,lr_documento.ramcod                        
                              ,lr_documento.aplnumdig                  
                              ,lr_documento.itmnumdig) then
                     
                     next field c24astcod 
               end if                    	                 
            
           end if                                        
                                                  
       
        end if
        
                                                              
	---> Tratar Empresa 50 porque no cadastro de Assunto nao permite
        ---> cadastrar o mesmo assunto para empresas diferentes
        ---> Os assuntos da Empresa 50 estao cadastrados p/ Empresa 01

	if g_documento.ciaempcod = 50 then
           if ws.ciaempcod <> 1 then
              error " Assunto nao cadastrado para Empresa "
              next field c24astcod
           end if
	else
           if g_documento.ciaempcod <> ws.ciaempcod then
              error " Assunto nao cadastrado para Empresa "
              next field c24astcod
           end if
        end if

        #---> Funeral - 2008
        # se variavel empresa 14 esta com S � porque entrou no desvio
        # para os assuntos SAF e B16
        if l_aux_emp14 = 'S' then
           let g_documento.ciaempcod = 14
        end if

        #PSI 199850
        #Verifica se assunto digitado pertence a um grupo do mesmo departamento do usuario
        call cta02m03_assunto_depto(d_cta02m00.c24astcod, g_issk.dptsgl)
             returning l_dptsgl
        if l_dptsgl = false then
           call cts08g01("A","N",
                         "Assunto nao permitido para ",
                         "departamento.","","")
               returning ws.confirma
           next field c24astcod
        end if

        # Chama Conta Corrente Itau
        if g_documento.ciaempcod = 84 and
	   lr_documento.ramcod   = 31 then
             if g_documento.itaciacod  is not null and
                lr_documento.ramcod    is not null and
                lr_documento.aplnumdig is not null and
                lr_documento.itmnumdig is not null then
                call cty22g00_conta_corrente_itau(d_cta02m00.c24astcod          ,
                                                  g_doc_itau[1].itaasiplncod    ,
                                                  g_doc_itau[1].itaaplvigincdat ,
                                                  g_doc_itau[1].itaaplvigfnldat ,
                                                  g_documento.itaciacod         ,
                                                  lr_documento.ramcod           ,
                                                  lr_documento.aplnumdig        ,
                                                  lr_documento.itmnumdig        ,
                                                  1                             )
                returning l_resultado,
                          l_mensagem
                if not l_resultado then
                   error l_mensagem sleep 2
                   next field c24astcod
                end if
             end if
        end if
        #psi230650
        #Busca agrupamento do assunto informado
        open c_cta02m00_021 using d_cta02m00.c24astcod
        fetch c_cta02m00_021 into l_c24astagp
        close c_cta02m00_021

        ## PSI 202720
        ------------[ verifica se segurado e remido ]-------------------
        if l_c24astagp = "S"      and
           lr_documento.crtsaunum is not null then
          call cta01m15_sel_datksegsau(7,
                                       lr_documento.crtsaunum,
                                       "","","")
               returning l_resultado,
                         l_mensagem,
                         l_crtstt

           if l_crtstt  = "R" then # cartao remido
              call cts08g01("A","N",
                            "************ SEGURADO REMIDO **********",
                            " ",
                            "SEM COBERTURA PARA SERVICOS A RESIDENCIA",
                            "tela-cta02m00 ")
                   returning ws.confirma
              next field c24astcod
           end if
        end if
        #---------------------------------------------------------------
        # Alerta Novos Correntistas
        #---------------------------------------------------------------
        if g_doc_itau[1].itaasiplncod = 3  and
        	 g_documento.ciaempcod      = 84 then
          if cts12g08_valida_data_limite(g_doc_itau[1].itaasiplncod   ,
                                         g_doc_itau[1].itaaplvigincdat) then
           	   call cty37g00_valida_alerta_assunto(g_doc_itau[1].itaclisgmcod,
           	                                       d_cta02m00.c24astcod      )
           end if
        end if

        if (d_cta02m00.c24astcod = "S10" or
            d_cta02m00.c24astcod = "S54" or ##fornax set/2012
            d_cta02m00.c24astcod = "S60" or
            d_cta02m00.c24astcod = "HDK" or
            d_cta02m00.c24astcod = "HDT" or
            d_cta02m00.c24astcod = "M20" or
            d_cta02m00.c24astcod = "S85" or
            d_cta02m00.c24astcod = "S80" or
            d_cta02m00.c24astcod = "SLV" or
            d_cta02m00.c24astcod = "SLT" or
            d_cta02m00.c24astcod = "S63"     )   and
            (lr_documento.aplnumdig <> 0 or
             lr_documento.crtsaunum <> 0     )   and
            (lr_documento.ramgrpcod = 1 or
             lr_documento.ramgrpcod = 5      )   then


            if d_cta02m00.c24astcod = "HDK"    and
               g_issk.dptsgl        = "ct24hs" then

               call cts08g01("A","S",""
                            ,"CONFIRMA ASSUNTO INFORMADO ?","","")
                 returning  ws.confirma

               if ws.confirma = "N" then
                  initialize d_cta02m00.c24astcod to null
                  next field c24astcod
               end if
            end if

            #-----------------------------------------------
            --> Chama tela de verificacao de inconsistencias
            #-----------------------------------------------
            if g_documento.ciaempcod <> 35 and
               g_documento.ciaempcod <> 40 and
               g_documento.ciaempcod <> 43 and
               g_documento.ciaempcod <> 84 then

               let g_hdk.vencido   = "N"
               let g_hdk.cancelado = "N"
               let g_abre_tela     = "N"  --> Nao abre tela de cts01g00

               call cts01g00 (lr_documento.ramcod
                             ,lr_documento.succod
                             ,lr_documento.aplnumdig
                             ,lr_documento.itmnumdig
                             ,lr_documento.c24astcod
                             ,"", "", "", "", "", "", l_data, "T")
                    returning erros.*

               if g_hdk.vencido   = "S" or
                  g_hdk.cancelado = "S" then

                  let ws.confirma  = null
                  let msg.linha1   = null

                  if g_hdk.vencido   = "S" and
                     g_hdk.cancelado = "N" then
                     let msg.linha1 = "DOCUMENTO VENCIDO."
                  end if

                  if g_hdk.vencido   = "N" and
                     g_hdk.cancelado = "S" then
                     let msg.linha1 = "DOCUMENTO CANCELADO."
                  end if

                  if g_hdk.vencido   = "S" and
                     g_hdk.cancelado = "S" then
                     let msg.linha1 = "DOCUMENTO VENCIDO E CANCELADO."
                  end if

                  #--------------------------------------------
                  --> Confirmacao para prosseguir o Atendimento
                  #--------------------------------------------
                  call cts08g01('A','S', "" , msg.linha1 , ""
                               ,"CONFIRMA ASSUNTO INFORMADO ?")
                       returning ws.confirma

                  if ws.confirma = 'N' then
                     next field c24astcod
                  end if

                  if d_cta02m00.c24astcod = "HDK"     and
                    (g_hdk.vencido        = "S"  or
                     g_hdk.cancelado      = "S"     ) then

                     call cts08g01('A','N', ""
                                  ,"ASSUNTO NAO PERMITIDO."
                                  ,"UTILIZAR O CODIGO S68.", "")
                          returning ws.confirma

                     next field c24astcod
                  end if
               end if
            end if


            if d_cta02m00.c24astcod = "M20" or
            	 d_cta02m00.c24astcod = "SLV" or
            	 d_cta02m00.c24astcod = "SLT" or
            	 d_cta02m00.c24astcod = "S85" or
            	 d_cta02m00.c24astcod = "S80" then
               let l_flag_qtdatd = cta02m00_nova_qtdatd(lr_documento.ramcod
                                                       ,lr_documento.succod
                                                       ,lr_documento.aplnumdig
                                                       ,lr_documento.itmnumdig
                                                       ,d_cta02m00.c24astcod)
            else
               #---------------------------------------------------
               --> Verifica Limites de Atendimento p/ Porto Socorro
               #---------------------------------------------------
               let l_flag_qtdatd = cta02m00_qtdatd(lr_documento.ramcod
                                                  ,lr_documento.succod
                                                  ,lr_documento.aplnumdig
                                                  ,lr_documento.itmnumdig
                                                  ,d_cta02m00.c24astcod
                                                  ,lr_documento.bnfnum
                                                  ,lr_documento.crtsaunum)

            end if

            #-------------------------------------------------------------
            --> Para HDT(Central 24h) mesmo que nao tenha mais direito
            --> permito prosseguir pois o Help Desk pode dar uma Cortesia
            #-------------------------------------------------------------
            if d_cta02m00.c24astcod = "HDT" then
               let l_flag_qtdatd = 1
            end if


            if l_flag_qtdatd = 2 then
               next field c24astcod
            end if
        end if

        if g_documento.ciaempcod = 35  and
           lr_documento.aplnumdig is not null then
           call cts43g00_limite_azul(lr_documento.ramcod
                                    ,lr_documento.succod
                                    ,lr_documento.aplnumdig
                                    ,lr_documento.itmnumdig
                                    ,lr_documento.edsnumref, ""
                                    ,d_cta02m00.c24astcod)
                returning l_flag_qtdatd

            if l_flag_qtdatd = true then
               next field c24astcod
            end if
        end if

        if d_cta02m00.c24astcod = "S10" then
           call cts03m04_limite(lr_documento.ramcod
                               ,lr_documento.succod
                               ,lr_documento.aplnumdig
                               ,lr_documento.itmnumdig
                               ,lr_documento.edsnumref, ""
                               ,d_cta02m00.c24astcod)
             returning l_flag_qtdatd
             if l_flag_qtdatd = true then
                error "Apolice nao tem mais direito a servicos de assistencia"
                next field c24astcod
             end if
        end if

        let d_cta02m00.c24astcod = cta02m01_reclamacoes(g_issk.dptsgl,
                                                        d_cta02m00.c24astcod)

        initialize lr_documento.cndslcflg   to null

        ##-- Manter o g_documento.cndslcflg --##
        let g_documento.cndslcflg = lr_documento.cndslcflg

        if ws.prgcod is null  then
           error " Acao a ser tomada nao encontrada. AVISE A INFORMATICA!"
           exit input
        end if

        if ws.c24aststt <> "A"  then
           error " Codigo do assunto CANCELADO!"
           next field c24astcod
        end if

        if d_cta02m00.c24astcod = "ALT"  or
           d_cta02m00.c24astcod = "CAN"  or
           d_cta02m00.c24astcod = "REC"  or
           d_cta02m00.c24astcod = "RET"  then
           error " Assunto deve estar vinculado a um servico!"
           next field c24astcod
        end if

       #-------------------------------------------------------------------
       # Verifica se codigo assunto e permitido para o ramo
       #-------------------------------------------------------------------

        initialize ws.ramook  to null
        call cta02m06(lr_documento.ramcod, d_cta02m00.c24astcod)
             returning ws.ramook

        if ws.ramook = "n"  then
           error " Codigo do assunto nao permitido para esse ramo!"
           next field c24astcod
        end if

        call c24geral8(d_cta02m00.c24astcod) returning d_cta02m00.c24astdes

        display by name d_cta02m00.*

        let lr_documento.c24astcod = d_cta02m00.c24astcod

        ##-- Manter o g_documento.c24astcod --##
        let g_documento.c24astcod = lr_documento.c24astcod

        if ws.docflg = "N"  and
           ws.prgcod = 00   then
           if l_c24astagp               <> "W"   and
              l_c24astagp               <> "C"   and
              l_c24astagp               <> "D"   and
              d_cta02m00.c24astcod      <> "X11" and
              d_cta02m00.c24astcod      <> "SUG" and
              d_cta02m00.c24astcod      <> "Z00" and
              d_cta02m00.c24astcod      <> "K00" and    #PSI 205206
              d_cta02m00.c24astcod      <> "K99" and    #PSI 205206
              d_cta02m00.c24astcod      <> "423" and    #PSI 230650
              d_cta02m00.c24astcod      <> "KSU" and    #PSI 205206
              d_cta02m00.c24astcod      <> "107" and    #PSS
              d_cta02m00.c24astcod      <> "I99" and    #Itau
              d_cta02m00.c24astcod      <> "I98" and    #Itau
              d_cta02m00.c24astcod      <> "R99" and    #Itau
              d_cta02m00.c24astcod      <> "R98" and    #Itau
              d_cta02m00.c24astcod      <> "ISU" and    #Itau
              d_cta02m00.c24astcod      <> "PSU" and    #Itau
              d_cta02m00.c24astcod      <> "P24" and
              d_cta02m00.c24astcod      <> "P25" and
              d_cta02m00.c24astcod      <> "518" then   #PortoSeg

              error " Assunto deve estar vinculado a um documento!"
              next field c24astcod
           end if
        end if

        if d_cta02m00.c24astcod <> "S10"  and
           d_cta02m00.c24astcod <> "S23"  and
           d_cta02m00.c24astcod <> "K10"  and  # assuntos da Azul #PSI 205206
           d_cta02m00.c24astcod <> "K23"  then                    #PSI 205206
           let ws.cponom = "cvnnum"
           initialize ws.cvnnom to null

           open  c_cta02m00_006 using ws.cponom, lr_documento.ligcvntip
           fetch c_cta02m00_006 into  ws.cvnnom
           close c_cta02m00_006

           if ws.cvnnom is null  then
              let ws.cponom = "ligcvntip"
              initialize ws.cvnnom to null

              open  c_cta02m00_006 using ws.cponom, lr_documento.ligcvntip
              fetch c_cta02m00_006 into  ws.cvnnom
              close c_cta02m00_006

              if ws.cvnnom is null  then
                 error " Convenio operacional nao cadastrado!",
                       " AVISE A INFORMATICA!"
              else
                 error " Convenio ", ws.cvnnom clipped,
                       " nao permite registrar este assunto!"
                 next field c24astcod
              end if
           end if
        end if

        if lr_ppt.cmnnumdig is not null    then

#=>        PSI.188425 - TRATA ASSUNTO SERV. EMERG. P/ DEPTO. ALARMES MONITORADOS
           call cty04g01_serv_emergencial (lr_ppt.cmnnumdig,
                                           g_a_pptcls[1].carencia,
                                           d_cta02m00.c24astcod,
                                           g_a_pptcls[1].clscod)
                returning lr_result.*

           if lr_result.stt <> 1 then
              error lr_result.msg
              next field c24astcod
           end if

        end if

       #-------------------------------------------------------------------
       # Verifica se � assunto S11" OU "S14" OU "S53" OU "S64" OU "SUC" (PSI207233)
       #-------------------------------------------------------------------
          if d_cta02m00.c24astcod = "S11"  or
             d_cta02m00.c24astcod = "S14"  or
             d_cta02m00.c24astcod = "S53"  or
             d_cta02m00.c24astcod = "S64"  or
             d_cta02m00.c24astcod = "SUC"  or
             d_cta02m00.c24astcod = "I24"  or
             d_cta02m00.c24astcod = "I31"  or   # Assuntos Itau
             d_cta02m00.c24astcod = "I34"  or   # Assuntos Itau
             d_cta02m00.c24astcod = "I64"  or   # Assuntos Itau
             d_cta02m00.c24astcod = "R07"  or   # Assuntos Itau
             d_cta02m00.c24astcod = "R13"  then # Assuntos Itau
	          if ctb83m00() = 0 then
	              error "Tipo de pagamento n�o selecionado"
	              next field c24astcod
	          end if
          end if

       #-------------------------------------------------------------------
       # Assunto = "?PP" - Solicita o numero do sinistro para perda parcial
       #-------------------------------------------------------------------
        if d_cta02m00.c24astcod = "U10" then
           if l_webrlzflg       =  "S"  then
              if lr_documento.succod    is null or
                 lr_documento.ramcod    is null or
                 lr_documento.aplnumdig is null or
                 lr_documento.itmnumdig is null then
                 error "Assunto deve estar vinculado a um documento!!"
                 next field c24astcod
              else
                 ---[ verifica se existe processo para o docto ]---
                 call fssac029_checa_sinistro(lr_documento.succod,
                                              lr_documento.aplnumdig,
                                              lr_documento.itmnumdig)
                      returning ws.temsinistro
                 if ws.temsinistro = "N" then
                    error "Apolice sem processo aberto"
                    next field c24astcod
                 end if
              end if
           end if
           if l_webrlzflg         <> "S"   then
              ##-- Tratar assunto U10 --##
              let lr_documento.sinramcod = null
              let lr_documento.sinano    = null
              let lr_documento.sinnum    = null
              let lr_documento.sinitmseq = null

              call cta02m00_trata_u10(lr_documento.sinramcod
                                     ,lr_documento.sinano
                                     ,lr_documento.sinnum
                                     ,lr_documento.sinitmseq
                                     ,lr_documento.succod
                                     ,lr_documento.ramcod
                                     ,lr_documento.aplnumdig
                                     ,lr_documento.itmnumdig)
              returning l_resultado
                       ,l_mensagem
                       ,ws.sinramcod
                       ,ws.sinano
                       ,ws.sinnum
                       ,ws.sinitmseq
                       ,w_sinnull
              if l_resultado <> 1 then
                 error l_mensagem
                 next field c24astcod
              end if

              let lr_documento.sinramcod = ws.sinramcod
              let lr_documento.sinano    = ws.sinano
              let lr_documento.sinnum    = ws.sinnum
              let lr_documento.sinitmseq = ws.sinitmseq

              ##- Manter o g_documento.sinramcod, sinano, sinnum, sinitmseq --##
              let g_documento.sinramcod = lr_documento.sinramcod
              let g_documento.sinano    = lr_documento.sinano
              let g_documento.sinnum    = lr_documento.sinnum
              let g_documento.sinitmseq = lr_documento.sinitmseq
           end if
        end if


        if ws.c24atrflg = "S" or
           ws.c24jstflg = "S" then
           call cta02m00_cria_tmp()
        end if
        #---------------------------------------------------------------------
        # Chama tela de verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if lr_documento.succod      is not null   and
           lr_documento.aplnumdig   is not null   then
           initialize ws.senhaok  to null
           call cts13g00(d_cta02m00.c24astcod,
                         lr_documento.ramcod,
                         lr_documento.succod,
                         lr_documento.aplnumdig,
                         lr_documento.itmnumdig,
                         "", "", "", "")
                returning ws.blqnivcod, ws.senhaok

           if ws.blqnivcod  =  3   then
              error " Bloqueio cadastrado nao permite atendimento",
                    " para este assunto/apolice!"
              next field c24astcod
           end if

           if ws.blqnivcod  =  2     and
              ws.senhaok    =  "n"   then
              error " Bloqueio necessita de permissao para atendimento!"
              next field c24astcod
           end if
        end if
        #---------------------------------------------------------------------
        # Chama tela de verificacao de permissao para liberacao do codigo
        #---------------------------------------------------------------------
        initialize ws.senhaok  to null
        initialize ws.funnom   to null

        if d_cta02m00.c24astcod <> "B14" then
#=>        PSI.188425 - VERIFICA SE O ASSUNTO PEDE PERMISSAO

           if cta02m11_permissao (d_cta02m00.c24astcod,
                                  g_issk.empcod,
                                  g_issk.funmat,
                                  g_issk.maqsgl,
                                  lr_documento.succod,
                                  lr_documento.ramcod,
                                  lr_documento.aplnumdig,
                                  lr_documento.itmnumdig,
                                  lr_documento.prporg,
                                  lr_documento.prpnumdig,
                                  lr_documento.fcapacorg,
                                  lr_documento.fcapacnum,
                                  lr_ppt.cmnnumdig) <> 1 then
              next field c24astcod
           end if

           if ws.prgcod <> 0 then
              call cta02m00_atz_just(ws.c24atrflg,ws.c24jstflg,ws.funnom)
           end if
        end if
        #---------------------------------------------------------------------
        # Chama tela de verificacao de inconsistencias
        #---------------------------------------------------------------------
        if g_documento.ciaempcod <> 35 and
           g_documento.ciaempcod <> 40 and
           g_documento.ciaempcod <> 43 and
           g_documento.ciaempcod <> 84 then

           let g_abre_tela     = "S" --> Abre tela de cts01g00
           let g_hdk.sem_docto = "N" --> Sem Documento

           call cts01g00 (lr_documento.ramcod   ,
                          lr_documento.succod   ,
                          lr_documento.aplnumdig,
                          lr_documento.itmnumdig,
                          lr_documento.c24astcod,
                          "", "", "", "", "", "", l_data, "T") returning erros.*

           if lr_documento.c24astcod = "HDK" and
              g_hdk.sem_docto        = "S"   then

              call cts08g01('A','N', ""
                           ,"ASSUNTO NAO PERMITIDO."
                           ,"UTILIZAR O CODIGO S68.", "")
                   returning ws.confirma

              next field c24astcod
           end if
        end if

        #---------------------------------------------------------------------
        # Verifica se a apolice tem clausula 096
        #---------------------------------------------------------------------
        if lr_documento.flgIS096 = "P" then
           call fsgmc001(lr_documento.succod,
                         lr_documento.ramcod,
                         lr_documento.aplnumdig)
                returning lr_documento.flgIS096
           if lr_documento.flgIS096 = "S"  then
              call cts08g01("A","N",
                            "O Valor da IS da Clausula 096 Garantia  ",
                            "Mecanica esta esgotado, caso nao se     ",
                            "trate de atendimento pela Clausula      ",
                            "desconsidere esta informacao.")
                  returning ws.confirma
           end if
        end if
        #---------------------------------------------------------------------
        # Impede abertura de S10 para documento sem clausula
        #---------------------------------------------------------------------
        if lr_documento.c24astcod = "S10"  then
           if erros.x1  = 04  or  erros.x2 = 04  or  erros.x3 = 04  or
              erros.x4  = 04  or  erros.x5 = 04  or  erros.x6 = 04  or
              erros.x7  = 04  or  erros.x8 = 04  or  erros.x9 = 04  or
              erros.x10 = 04 then
              if lr_documento.ramcod = 118 then
                 error " Documento sem clausula(36) contratada !" sleep 2
              else
                 error " Documento sem clausula! Solicite cortesia (codigo S90)"  sleep 2
              end if
              next field c24astcod
           end if
        end if

# ruiz  # emite alerta para consultar carro+casa como beneficio. 28/07/06

        if lr_documento.c24astcod = "S60" or
           lr_documento.c24astcod = "S63" then

           if lr_documento.ramcod    = 531    then
              call faemc144_clausula(lr_documento.succod,
                                     lr_documento.aplnumdig,
                                     lr_documento.itmnumdig)
                  returning l_cod_erro,
                            l_clscod,
                            l_data_calculo,
                            l_flag_endosso

              if l_cod_erro = 0 then

                 ## PSI - Help Desk Carro+Casa
                 if l_data_calculo >= "01/07/2006" then # circular 310 Susep

                    if l_clscod = "035" or
                       l_clscod = "35R" then
                       call cts08g01_opcao_funcao("A","N",
                                    "Consulte Beneficio CARRO + CASA COMPLETO",
                                    "atraves da funcao abaixo F5-Vantagens",
                                    "","",1)
                           returning ws.confirma
                    else
                       if  l_clscod = "034" or
                           l_clscod = "033" or
                           l_clscod = "33R" and
                           lr_documento.c24astcod = "S60" then
                           call cts08g01_opcao_funcao("A","N",
                                    "Consulte Beneficio CARRO + CASA BASICO ",
                                    "atraves da funcao abaixo F5-Vantagens",
                                    "","",1)
                              returning ws.confirma
                       else
                            if l_clscod = "047" or
                               l_clscod = "47R" then
                               call cts08g01_opcao_funcao("A","N",
                                           "Consulte Beneficio CARRO + CASA COMPLETO",
                                           "MULHER atraves da funcao abaixo ",
                                           "F5-Vantagens","",1)
                                     returning ws.confirma
                            else
                               if l_clscod = "046" or
                                  l_clscod = "46R" then
                                     call cts08g01_opcao_funcao("A","N",
                                           "Consulte Beneficio CARRO+EMPRESA BASICO ",
                                           "atraves da funcao abaixo F5-Vantagens",
                                           "","",1)
                                     returning ws.confirma
                               end if
                            end if
                       end if
                    end if
                 end if
              end if
           else
              ## PSI 212296 - Clausula 36 - Envio de Guincho
              whenever error continue

              if lr_documento.ramcod = 118 then

                 select sgrorg,
                        sgrnumdig
                        rmemdlcod
                   into lr.sgrorg,
                        lr.sgrnumdig,
                        lr.rmemdlcod  ## -- Modalidade
                   from rsamseguro
                  where succod    =  lr_documento.succod     and
                        ramcod    =  lr_documento.ramcod     and
                        aplnumdig =  lr_documento.aplnumdig

                 if lr_documento.c24astcod = "S10" or
                    lr.rmemdlcod           = 113   then ## PSI 212296

                    select prporg,
                           prpnumdig
                      into lr_documento.prporg,
                           lr_documento.prpnumdig
                      from rsdmdocto
                     where sgrorg    = lr.sgrorg      and
                           sgrnumdig = lr.sgrnumdig   and
                           dctnumseq = (select max(dctnumseq)
                                          from rsdmdocto
                                         where sgrorg     = lr.sgrorg     and
                                               sgrnumdig  = lr.sgrnumdig  and
                                               prpstt    in (19,65,66,88))

                    select clscod
                      from rsdmclaus
                     where prporg    = lr_documento.prporg     and
                           prpnumdig = lr_documento.prpnumdig  and
                           lclnumseq = 1                       and
                          (clscod    = "36"                    or
                           clscod    = "036" )                 and
                           clsstt    = "A"

                    whenever error stop
                     if sqlca.sqlcode = 100 then ## Se nao possuir clausula 36
                        let l_confirma = cts08g01('A','N',"NAO E POSSIVEL REALIZAR ATENDIMENTO,",
                                                  " CLAUSULA 036 NAO ",
                                                  "CONTRATADA PARA ESTA APOLICE!",'')
                        next field c24astcod
                     end if
                 end if
              end if
              ## PSI 212296 - Clausula 36 - Envio de Guincho
           end if
        end if

        if g_issk.acsnivcod <> 8  then
           if lr_documento.c24astcod = "B14" then
                  if erros.x1  = 03  or  erros.x2 = 03  or  erros.x3 = 03  or
                     erros.x4  = 03  or  erros.x5 = 03  or  erros.x6 = 03  or
                     erros.x7  = 03  or  erros.x8 = 03  or  erros.x9 = 03  or
                     erros.x10 = 03                                        then
                     call cts08g01("A","N",
                                   "NAO E' POSSIVEL SOLICITAR",
                                   "REPARO DE VIDROS!","",
                                   "APOLICE CANCELADA")
                         returning ws.confirma
                     next field c24astcod
                  end if
           end if
        end if
        if g_documento.ciaempcod  = 1     and
           lr_documento.c24astcod = "018" then

           ##-- Tratar assunto 018 --##
           call cty05g00_cls018(lr_documento.succod
                               ,lr_documento.aplnumdig
                               ,lr_documento.itmnumdig
                               ,lr_cty05g01.dctnumseg)
           returning l_resultado
                    ,l_mensagem

           if l_resultado = 2 then
              let l_confirma = cts08g01('A','N',"NAO E  POSSIVEL REALIZAR A PESQUISA AO ",
                              "PERFIL DO SEGURADO CLAUSULA 018 NAO FOI ",
                              "CONTRATADA PARA ESTA APOLICE!",'')
              next field c24astcod
           end if

        end if

       #=========================== ITURAN ================================
        if lr_documento.c24astcod = "F10"  then

           ##-- Tratar assunto F10 --##
           call cta02m00_trata_F10(lr_documento.succod
                                  ,g_documento.aplnumdig
                                  ,lr_documento.itmnumdig
                                  ,lr_cty05g01.vclsitatu)
        end if

        ---> Decreto - 6523
        let g_documento.assuntob16 = null

        if lr_documento.c24astcod = "B16" or
           lr_documento.c24astcod = "HDT" or   ---> Help Desk Casa - Transfere  
           lr_documento.c24astcod = "RDT" or
           lr_documento.c24astcod = "K06" then

           let l_erro_b16             = null
           let g_documento.lignum_b16 = null
           let g_documento.assuntob16 = 1
           let ws.confirma            = null
           let msg.linha1             = null
           let msg.linha2             = null
           let msg.linha3             = null
           let msg.linha4             = null

           if lr_documento.c24astcod = "HDT" or  ---> Help Desk Casa
           	  lr_documento.c24astcod = "RDT" then 

              let flag_hdt_transf = null
              let flag_hdt_hst    = null
              let msg.linha1      = " "
              let msg.linha2      = "A LIGACAO SERA TRANSFERIDA ? "
              let msg.linha3      = " "
              let msg.linha4      = " "

              call cts08g01("A", "S"
                            ,msg.linha1
                            ,msg.linha2
                            ,msg.linha3
                            ,msg.linha4 )
                   returning ws.confirma

              if upshift(ws.confirma) = 'S' then

                 let flag_hdt_transf        = "SIM"

                 let msg.linha1 = " "
                 let msg.linha2 = "A LIGACAO DEVERA SER TRANSFERIDA "
                 let msg.linha3 = "PARA O RAMAL 2936. "
                 let msg.linha4 = " "

                 call cts08g01("A", "N"
                               ,msg.linha1
                               ,msg.linha2
                               ,msg.linha3
                               ,msg.linha4 )
                      returning ws.confirma
              else
                 ---> Se nao Transferiu a Ligacao deve informar o Motivo
                 if l_rcuccsmtvobrflg = 'S' then

                    let flag_hdt_transf        = "NAO"
                    let g_documento.assuntob16 = null --> p/ nao gravar

                    while true

                       let lr_documento.rcuccsmtvcod = null

                       call ctc26m01()
                             returning lr_documento.rcuccsmtvcod

                       if lr_documento.rcuccsmtvcod = 0    then
                          error "Assunto nao tem motivos cadastrados. "
			                    continue while
                       end if

                       if lr_documento.rcuccsmtvcod is null then
                          error "O motivo deve ser informado. "
			                    continue while
                       end if


                       ---> Descricao do Motivo
                       select rcuccsmtvdes
                         into flag_hdt_hst
                         from datkrcuccsmtv
                        where rcuccsmtvstt = 'A'
                          and rcuccsmtvcod = lr_documento.rcuccsmtvcod
                          and c24astcod    = lr_documento.c24astcod

                        let m_rcuccsmtvcod = lr_documento.rcuccsmtvcod

                       exit while
                    end while
                 end if
              end if
           else

              let msg.linha1 = " "
              let msg.linha2 = "A TRANSFERENCIA ESTA SENDO NECESSARIA "
              let msg.linha3 = "DEVIDO A UM ASSUNTO NAO RESOLVIDO ?"
              let msg.linha4 = " "

              call cts08g01("A", "S"
                            ,msg.linha1
                            ,msg.linha2
                            ,msg.linha3
                            ,msg.linha4 )
                   returning ws.confirma

              if upshift(ws.confirma) = 'S' then

                 call ctd25g00_num_ligacoes()
                      returning l_erro_b16
                               ,g_documento.lignum_b16
              end if
           end if
        end if

        let lr_documento.rcuccsmtvcod = null



       if d_cta02m00.c24astcod = "W00"   or
          d_cta02m00.c24astcod = "K00"   or
          d_cta02m00.c24astcod = "I99"   or
          d_cta02m00.c24astcod = "R99"   then

          call cts08g01 ("A","N",""
                       ,"INFORME AO CLIENTE QUE ENTRAREMOS ",
                        "EM CONTATO COM A SOLUCAO DA PENDENCIA ",
                        "NO MAXIMO EM 5 DIAS UTEIS.")
            returning ws.confirma
       end if

        if l_rcuccsmtvobrflg = 'S' then
           # PSI 243655 U10-Motivo
           if d_cta02m00.c24astcod = "U10" or
              d_cta02m00.c24astcod = "U11" then
              # Tratamento Implementado no Modulo cta02m13 - Nao deixar sair sem digitar o Motivo
              # da transferencia. Desvio condicional para n�o abrir o popup de Motivo, ANTES de
              # Concluir na WEB.
           else
              if lr_documento.c24astcod <> "HDT" and  ---> Help Desk Casa
              	 lr_documento.c24astcod <> "RDT" then

                 while true
                   let lr_documento.rcuccsmtvcod = null

                   call ctc26m01() returning lr_documento.rcuccsmtvcod

                   if lr_documento.rcuccsmtvcod = 0    then
                      error 'Assunto nao tem motivos cadastrados !'
                      next field c24astcod
                   end if

                   if lr_documento.rcuccsmtvcod is null then
                      error ' O motivo deve ser informado !'
                      next field c24astcod
                   end if
                   exit while
                 end while
              end if
           end if
           # PSI 243655 U10-Motivo

           if d_cta02m00.c24astcod = "W00"   then
              if lr_documento.rcuccsmtvcod = 6 or #SEGUNDA VIA DE APOLICE
                 lr_documento.rcuccsmtvcod = 7 or #SOLICITACAO DE CONTATOS PARA OUTRAS AREAS
                 lr_documento.rcuccsmtvcod = 8 or #CADASTRO INCORRETO DE PLACA
                 lr_documento.rcuccsmtvcod = 9 then #INFORMACAO SOBRE BONUS(CLASSE)
                 let d_cta02m00.c24astcod = "*CQ"
                 next field c24astcod
              else
                 if lr_documento.rcuccsmtvcod = 12 then
                    call cts08g01_6l("A", "N", "FACA RETRATACAO DESTA RECLAMACAO DURANTE",
                                              "O PROPRIO CONTATO. ",
                                              "INFORME QUE PROVIDENCIAS ESTAO SENDO ",
                                              "TOMADAS PARA EVITAR ESTE TIPO DE ",
                                              "SITUACAO. ",
                                              "")
                    returning ws.confirma
                 end if
                 if lr_documento.rcuccsmtvcod = 13 then

                  call cts08g01_6l("A", "N", "FACA RETRATACAO DESTA RECLAMACAO DURANTE",
                                            "O PROPRIO CONTATO. ",
                                            "INFORME QUE FAREMOS A APURACAO INTERNA ",
                                            "DO OCORRIDO, E TOMAREMOS AS PROVIDENCIAS",
                                            "PARA EVITAR QUE ESTE TIPO DE SITUACAO ",
                                            "VOLTE A OCORRER.")
                       returning ws.confirma
                 end if
              end if
           end if
        end if
        
        
        call cty39g00_vai_taxi()


        -------------[ 03/12/07 - limpeza da global ]------------
        ##-- Manter g_documento.rcuccsmtvcod --##
        let g_documento.rcuccsmtvcod = lr_documento.rcuccsmtvcod

      #---------------------------------------------------------------------
      # Chama tela de procedimentos para atendimento
      #---------------------------------------------------------------------

         message " Aguarde, verificando procedimentos... " attribute (reverse)
         call cts14g00(d_cta02m00.c24astcod ,
                       lr_documento.ramcod   ,
                       lr_documento.succod   ,
                       lr_documento.aplnumdig,
                       lr_documento.itmnumdig,
                       "","",
                       "N", "2099-12-31 23:00")
         message ""

      #---------------------------------------------------------------------
      # Verifica se a ligacao foi registrada
      #---------------------------------------------------------------------
      on key (interrupt)

         if g_issk.acsnivcod = 6         then
            ##-- OBTER QUANTIDADE DE LIGACOES DA APOLICE --##
            call cts10g07_qtdlig(lr_documento.succod
                                ,lr_documento.ramcod
                                ,lr_documento.aplnumdig
                                ,lr_documento.itmnumdig
                                ,lr_documento.prporg
                                ,lr_documento.prpnumdig
                                ,lr_documento.sinano
                                ,lr_documento.sinnum
                                ,lr_documento.sinitmseq
                                ,lr_ppt.cmnnumdig
                                ,lr_documento.corsus          ## CT 308846
                                ,lr_documento.cgccpfnum
                                ,lr_documento.cgcord
                                ,lr_documento.cgccpfdig
                                ,lr_documento.funmat
                                ,lr_documento.ctttel
                                ,lr_documento.crtsaunum)
            returning lr_cts10g07.resultado
                     ,lr_cts10g07.mensagem
                     ,w_totligdep

            if lr_documento.apoio <> 'S' or
               lr_documento.apoio is null then
               call cta02m20_remover_atendimento()
            end if
            if ws.docflg   = "S"             and
               w_totligant = w_totligdep     and
               lr_documento.pcacarnum is null then
               let int_flag = false
               if lr_documento.flgtransp = "S" then
                  exit input
               else
                  error " Codigo de assunto deve ser registrado!"
               end if
            else
               exit input
            end if
         else
            ##-- Tratar insert/delete na datkgeral --##
            call cta02m00_trata_datkgeral(w_grlchv
                                         ,w_grlchvX)
            returning l_resultado
                     ,l_mensagem
            if l_resultado = 3 then
               error l_mensagem
            end if
           if lr_documento.apoio <> 'S' or
               lr_documento.apoio is null then
               call cta02m20_remover_atendimento()
            end if
            exit input
         end if

      on key (F1)

        let m_hostname = null
        call cta13m00_verifica_status(m_hostname)
        returning l_st_erro,l_ret_msg

      if l_st_erro = true then
         if l_flag_acesso = 1 then
            ##-- Exibir as funcoes disponiveis por ramo --##
            call cta01m10_funcoes(lr_documento.ramcod
                                 ,lr_documento.succod
                                 ,lr_documento.aplnumdig
                                 ,lr_documento.itmnumdig
                                 ,lr_documento.prporg
                                 ,lr_documento.prpnumdig
                                 ,lr_ppt.cmnnumdig
                                 ,lr_ppt.segnumdig
                                 ,lr_documento.cgccpfnum
                                 ,lr_documento.cgcord
                                 ,lr_documento.cgccpfdig
                                 ,lr_documento.ligcvntip
                                 ,lr_cty05g01.dctnumseg
                                 ,lr_documento.crtsaunum)
         end if
      else

        error "Funcao F1 nao disponivel no momento !",l_ret_msg, " ! Avise a informatica "
      end if

      on key (F3) ###  Auto Ct24h
         let m_hostname = null
         call cta13m00_verifica_status(m_hostname)
         returning l_st_erro,l_ret_msg

         if l_st_erro = true then
         if lr_documento.apoio = "S" then
            call ctn49c00()
         end if
        else
           error "Funcao F3 nao disponivel no momento ! Avise a informatica "
        end if

      on key (F4)  ###  Consultas Genericas (Con_ct24h)
         let m_hostname = null
         call cta13m00_verifica_status(m_hostname)
         returning l_st_erro,l_ret_msg

         if l_st_erro = true then
         if lr_documento.apoio = "S" then
            initialize ws.ret  to null
            call chama_prog("Con_ct24h", "ctg3", "")  returning ws.ret
            if ws.ret  =  -1   then
               error " Modulo Con_ct24h nao disponivel no momento!"
              end if
            end if
         else
           error "Funcao F4 nao disponivel no momento ! Avise a informatica "
          end if

      #---------------------------------------------------------------------
      # Chama espelho da apolice ou cartao
      #---------------------------------------------------------------------
      on key (F5)
         ##-- Exibir espelho da apolice --##
         let g_monitor.horaini = current ## Flexvision
         call cta01m12_espelho(lr_documento.ramcod
                              ,lr_documento.succod
                              ,lr_documento.aplnumdig
                              ,lr_documento.itmnumdig
                              ,lr_documento.prporg
                              ,lr_documento.prpnumdig
                              ,lr_documento.fcapacorg
                              ,lr_documento.fcapacnum
                              ,lr_documento.pcacarnum
                              ,lr_documento.pcaprpitm
                              ,lr_ppt.cmnnumdig
                              ,lr_documento.crtsaunum
                              ,lr_documento.bnfnum
                              ,g_documento.ciaempcod)

      #---------------------------------------------------------------------
      # Mostra todas as ligacoes da apolice
      #---------------------------------------------------------------------
      on key (F6)

         let g_documento.rcuccsmtvcod = null

         ---> Trata Local de Risco ou Bloco pois nas ligacoes mostra de todos
         if g_rsc_re.lclrsccod is not null and
            g_rsc_re.lclrsccod <> 0        then

	    initialize mr_rsc_re.* to null

            let mr_rsc_re.lclrsccod = g_rsc_re.lclrsccod
            let mr_rsc_re.lclnumseq = g_documento.lclnumseq
            let mr_rsc_re.rmerscseq = g_documento.rmerscseq

         end if

         if ws.docflg = "S"  then
            if g_setexplain = 1 then
              call cts01g01_setetapa("cta02m00 - Pesquisando todas as ligacoes")
            end if

            call cta02m02_consultar_ligacoes(lr_documento.succod   ,
                                             lr_documento.ramcod   ,
                                             lr_documento.aplnumdig,
                                             lr_documento.itmnumdig,
                                             lr_documento.prporg   ,
                                             lr_documento.prpnumdig,
                                             lr_documento.fcapacorg,
                                             lr_documento.fcapacnum,
                                             lr_documento.apoio    ,
                                             lr_documento.corsus   ,
                                             lr_documento.cgccpfnum,
                                             lr_documento.cgcord   ,
                                             lr_documento.cgccpfdig,
                                             lr_documento.funmat   ,
                                             lr_documento.ctttel   ,
                                             lr_ppt.cmnnumdig      ,
                                             lr_documento.solnom   ,
                                             lr_documento.c24soltipcod,
                                             lr_documento.empcodatd,
                                             lr_documento.funmatatd,
                                             lr_documento.crtsaunum,
                                             lr_documento.bnfnum   ,
                                             lr_documento.ramgrpcod)

            let lr_documento.lignum = null
            ##-- Manter o g_documento.lignum --##
             let g_documento.lignum = lr_documento.lignum
         else
            error " Consulta a ligacoes so com documento localizado!"
         end if

         ---> Volta valores do documento original selecionado
         if g_rsc_re.lclrsccod is not null and
            g_rsc_re.lclrsccod <> 0        then

            let g_rsc_re.lclrsccod    = mr_rsc_re.lclrsccod
            let g_documento.lclnumseq = mr_rsc_re.lclnumseq
            let g_documento.rmerscseq = mr_rsc_re.rmerscseq
         end if


      on key (F7)
         if wg_psre   =   1  and
            l_flag_acesso = 1 then
            call cts22g00(lr_documento.succod   ,
                          lr_documento.ramcod   ,
                          lr_documento.aplnumdig,
                          lr_documento.itmnumdig,
                          "9","",360,
                          lr_documento.bnfnum,
                          g_documento.cgccpfnum,
                          g_documento.cgcord   ,
                          g_documento.cgccpfdig,
                          "cta02m00")
                returning ws.atdsrvnum_rcl,
                          ws.atdsrvano_rcl,
                          ws.atdsrvorg_rcl
            initialize lr_documento.atdsrvnum to null
            initialize lr_documento.atdsrvano to null

            ##-- Manter o g_documento.atdsrvnum e atdsrvano --##
            let g_documento.atdsrvnum = lr_documento.atdsrvnum
            let g_documento.atdsrvano = lr_documento.atdsrvano

         end if

      on key (F9)

         if l_flag_acesso = 1 then
            call cta02m18()
         end if

      on key (F10)

        call cty10g00_grupo_ramo(g_documento.ciaempcod
                                ,g_documento.ramcod)
             returning lr_ramo.*

        call cta00m06_re_contacorrente()
           returning l_conta_corrente

        if lr_ramo.ramgrpcod = 4 and
           l_conta_corrente = true then

            call  framc216(false,
                           g_documento.succod,
                           g_documento.ramcod,
                           g_documento.aplnumdig,
                           g_documento.prporg,
                           g_documento.prpnumdig,
                           g_documento.lclnumseq,
                           g_documento.rmerscseq)
            returning lr_retorno_re.coderro,lr_retorno_re.msg

            if lr_retorno_re.coderro <> 0 then
               error lr_retorno_re.msg sleep 2
               call errorlog (lr_retorno_re.msg)
            end if
         end if

      on key (F8)

            if g_documento.aplnumdig is not null and
               g_documento.ramcod = 531     then
               call cta02m28(l_qtd_serv,l_vlr_serv)
            end if

    end input

    if l_erro = true then
       exit while
    end if
    if not int_flag  then
       if ws.prgcod is null  then
          if lr_documento.flgtransp is null then
             error " Acao a ser tomada nao encontrada. AVISE A INFORMATICA!"
          end if

          call cta02m00_anula_cgccpf()
          close window cta02m00
          return
       end if

       if ws.cndslcflg  =  "S"  then
#=>       PSI.188425 - MOSTRAR ULTIMO CONDUTOR DO VEICULO
          call cta02m07_condutor (ws.cndslcflg,
                                  lr_documento.succod,
                                  lr_documento.aplnumdig,
                                  lr_documento.itmnumdig,
                                  g_funapol.dctnumseq)
               returning lr_result.*

           if lr_result.stt = 3 then
              error lr_result.msg
              continue while
           end if

           if lr_result.stt = 1 then
              let lr_documento.cndslcflg = ws.cndslcflg

              ##-- Manter o g_documento.cndslcflg --##
              let g_documento.cndslcflg = lr_documento.cndslcflg
           end if
       end if

       let   lr_documento.ligcvntip = g_documento.ligcvntip

       if lr_documento.c24astcod  =  "S60"  or
          lr_documento.c24astcod  =  "S62"  or
          lr_documento.c24astcod  =  "S63"  or
          lr_documento.c24astcod  =  "SCR"  or
          lr_documento.c24astcod  =  "S10"  or
          lr_documento.c24astcod  =  "KMP"  or
          lr_documento.c24astcod  =  "PE3"  or    # PSI 243.647
          lr_documento.c24astcod  =  "K10"  or    # PSI 205206
          lr_documento.c24astcod  =  "KVB"  then  # CRIADO POR YURI P.SOCORRO

          if lr_documento.c24astcod  =  "S10"  or
             lr_documento.c24astcod  =  "KMP"  or
             lr_documento.c24astcod  =  "K10"  or   # PSI 205206
             lr_documento.c24astcod  =  "KVB"  then # CRIADO POR YURI P.SOCORRO
             call cts22g00(lr_documento.succod   ,
                           lr_documento.ramcod   ,
                           lr_documento.aplnumdig,
                           lr_documento.itmnumdig,
                           "1","",360,
                           lr_documento.bnfnum,
                           "","","","cta02m00")
                  returning ws.atdsrvnum_rcl,
                            ws.atdsrvano_rcl,
                            ws.atdsrvorg_rcl
          else
                #psi230650
                #Buscar agrupamento do assunto
                let l_c24astagp = null
                open c_cta02m00_021 using g_documento.c24astcod
                fetch c_cta02m00_021 into l_c24astagp
                close c_cta02m00_021

                if  l_c24astagp = "W" then
                    let l_aux2  = g_documento.c24astcod
                end if
                call cts22g00(lr_documento.succod   ,
                              lr_documento.ramcod   ,
                              lr_documento.aplnumdig,
                              lr_documento.itmnumdig,
                              "9","",360,
                              lr_documento.bnfnum,
                              g_documento.cgccpfnum,
                              g_documento.cgcord   ,
                              g_documento.cgccpfdig,
                              "cta02m00")
                     returning ws.atdsrvnum_rcl,
                               ws.atdsrvano_rcl,
                               ws.atdsrvorg_rcl

                if  l_aux2 is not null then
                    let g_documento.c24astcod = l_aux2
                end if
          end if
          initialize lr_documento.atdsrvnum to null
          initialize lr_documento.atdsrvano to null

          ##-- Manter o g_documento.atdsrvnum e atdsrvano -- ##
          let g_documento.atdsrvnum = lr_documento.atdsrvnum
          let g_documento.atdsrvano = lr_documento.atdsrvano

       end if

       if lr_documento.apoio <> 'S' or
          lr_documento.apoio is null then
          if lr_documento.succod is not null and
             lr_documento.ramcod is not null and
             lr_documento.aplnumdig is not null and
             lr_documento.itmnumdig  is not null then
             call cta02m20_inclui_assunto(lr_documento.succod,
                                          lr_documento.ramcod,
                                          lr_documento.aplnumdig,
                                          lr_documento.itmnumdig)
          end if
          if lr_documento.succod is null and
             lr_documento.aplnumdig is null and
             lr_documento.itmnumdig is null then
             if lr_documento.prporg    is not null and
                lr_documento.prpnumdig is not null then
                call cta02m20(lr_documento.succod,
                              lr_documento.ramcod,
                              lr_documento.aplnumdig,
                              lr_documento.itmnumdig,
                              lr_documento.prporg,
                              lr_documento.prpnumdig)
             end if
          end if
       end if

       if g_setexplain = 1 then
          let l_msg = 'cta02m00 - Solicitando assunto ', d_cta02m00.c24astcod
          call cts01g01_setetapa(l_msg)
       end if

       #---------------------------------------------------------------------
       # Chama telas para registrar os servicos de acordo com assunto
       #---------------------------------------------------------------------
#=>    PSI.188425 - CHAMAR TELAS DOS LAUDOS DE ACORDO COM ASSUNTO

## CT  303208 Alberto

       if g_documento.aplnumdig <> lr_documento.aplnumdig then
          initialize l_mens.* to null
          initialize l_today to null
          initialize l_hora to null
          initialize  l_cmd  to  null
          call cts40g03_data_hora_banco(1)
              returning l_today, l_hora
          let l_mens.msg = "Suc/Ram/Apol : ", lr_documento.succod,"/"
                         ,lr_documento.ramcod
                         ,"/",lr_documento.aplnumdig, " Apol.Global: "
                         , g_documento.aplnumdig
                         , "< Data: ", l_today ," : ",l_hora, " > "
                         , " Assunto : ",g_documento.c24astcod
                         ," Matricula : " , g_issk.funmat
          #PSI-2013-23297 - Inicio
          let l_mail.de = "CT24H-cta02m00"
          let l_mail.para = "sistemas.madeira@portoseguro.com.br"
          #let l_mail.para = "Rodrigues_Alberto@correioporto"
          #let l_mail.cc = "Mattge_Ligia@correioporto"
          let l_mail.cco = ""
          let l_mail.assunto = "Apolices Divergentes"
          let l_mail.mensagem = l_mens.msg
          let l_mail.id_remetente = "CT24HS"
          let l_mail.tipo = "text"

          call figrc009_mail_send1 (l_mail.*)
              returning l_coderro,msg_erro

          #PSI-2013-23297 - Fim
       end if

       let g_documento.lclocodesres = 'N'   ### PSI 192007 - JUNIOR(META)

       let l_grlchv = null
       let l_grlinf = null

       if d_cta02m00.c24astcod = "V10" or   # VISTORIA SINISTRO AUTO - SEGURADO
          d_cta02m00.c24astcod = "V11" then # VISTORIA SINISTRO AUTO - TERCEIRO

          # -> VERIFICA O TIPO DE ATENDIMENTO: COM OU SEM DOCUMENTO
          if lr_documento.succod    is not null and
             lr_documento.ramcod    is not null and
             lr_documento.aplnumdig is not null and
             lr_documento.itmnumdig is not null then

             # -> ATENDIMENTO C/DOCUMENTO

             # -> MONTA A CHAVE(grlchv) P/INSERIR NA DATKGERAL
             let l_grlchv = cts40g23_monta_chv_pesq(g_issk.funmat,
                                                    g_issk.maqsgl)

             # -> MONTA A CHAVE DE INSERCAO
             let l_grlinf = cts40g23_monta_chv_insercao(lr_documento.succod,
                                                        lr_documento.ramcod,
                                                        lr_documento.aplnumdig,
                                                        lr_documento.itmnumdig)

             # -> INSERE O REGISTRO NA TABELA DATKGERAL
             call cts40g23_insere_chv(l_grlchv,
                                      l_grlinf,
                                      g_issk.empcod,
                                      g_issk.funmat)
          else
             let l_grlchv = null
             let l_grlinf = null
          end if

       end if

       call cta02m13(ws.prgcod,
                     ws.aplflg,
                     ws.docflg,
                     d_cta02m00.c24astcod,
                     ws.c24atrflg,
                     ws.c24jstflg,
                     ws.funnom,
                     g_issk.funmat,
                     w_today,
                     w_current,
                     lr_documento.succod,
                     lr_documento.aplnumdig,
                     lr_documento.itmnumdig,
                     g_funapol.vclsitatu,
                     lr_documento.flgIS096,
                     w_sinnull,
                     l_webrlzflg)

       returning lr_result.stt,
                 lr_documento.lignum
       if (d_cta02m00.c24astcod = "W00" and lr_documento.rcuccsmtvcod = 13) or
          (d_cta02m00.c24astcod = "I99" and lr_documento.rcuccsmtvcod = 1) or
          (d_cta02m00.c24astcod = "K00" and lr_documento.rcuccsmtvcod = 7) then
         if lr_documento.lignum is not null then
	          call cta19m00 (lr_documento.ramcod   , lr_documento.c24astcod,
	                         lr_documento.ligcvntip, lr_documento.succod,
	                         lr_documento.aplnumdig, lr_documento.itmnumdig,
	                         lr_documento.lignum   , m_atdsrvnum,
	                         m_atdsrvano           , lr_documento.prporg,
	                         lr_documento.prpnumdig, lr_documento.solnom,
	                         lr_documento.rcuccsmtvcod)
	           returning l_envio
          end if
         if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
            error "Problemas na funcao cta19m00 ! Avise a Informatica !" sleep 2
            #exit while
         end if        -- > 223689
       end if

       # correcao - 018 nao envia email - helder
       if d_cta02m00.c24astcod = '018' then
          let lr_documento.lignum = g_lignum_dcr
       end if
       # ---

       # -> VERIFICA SE INSERIU REGISTRO NA TABELA DATKGERAL
       if l_grlchv is not null and
          l_grlchv <> " " then

          # -> APAGA O REGISTRO INSERIDO NA TABELA DATKGERAL
          call cts40g23_apaga_chv(l_grlchv)

       end if

       call cta00m06_verifica_apolice(lr_documento.succod     ,
                                      lr_documento.ramcod     ,
                                      lr_documento.aplnumdig  ,
                                      lr_documento.itmnumdig  ,
                                      lr_documento.lignum     ,
                                      lr_documento.c24astcod  )
       if d_cta02m00.c24astcod = "W00"   and
          (lr_documento.rcuccsmtvcod = 12 or
           lr_documento.rcuccsmtvcod = 13 ) then


           while true
              call cts08g01_reclamacao("A", "S", "",
                            "EXISTE A NECESSIDADE DE RETORNO ",
                            " AO CLIENTE?",
                            "")
                   returning ws.confirma

              if ws.confirma is not null then
                 exit while
              end if

          end while

              call cts40g03_data_hora_banco(2)
                   returning lr_hist.data, lr_hist.hora2


           if ws.confirma = "S" then
              let lr_hist.mens = '"S" - Cliente aguarda retorno do SAC'

              call ctd06g01_ins_datmlighist(lr_documento.lignum,
                                            g_issk.funmat,
                                            lr_hist.mens,
                                            lr_hist.data,
                                            lr_hist.hora2,
                                            g_issk.usrtip,
                                            g_issk.empcod )
                   returning lr_rethist.ret,
                             lr_rethist.mens
           else
              let lr_hist.mens = '"N" - Cliente n�o aguarda retorno do SAC'

              call ctd06g01_ins_datmlighist(lr_documento.lignum,
                                            g_issk.funmat,
                                            lr_hist.mens,
                                            lr_hist.data,
                                            lr_hist.hora2,
                                            g_issk.usrtip,
                                            g_issk.empcod )
                   returning lr_rethist.ret,
                             lr_rethist.mens
           end if
       end if

       let g_documento.lignum = lr_documento.lignum

       # ATUALIZAR EMAIL E FONE DO SEGURADO DEPOIS DE REGISTRAR A LIGACAO
       # MIRIAM ANSELMO 10/09 .
       if w_telmaiatlflg  =  "S" then
           # Chama a Funcao de Envio de E-mail Itau
           if g_documento.ciaempcod = 84 then
               if (lr_documento.c24soltipcod  = 1    or
                   lr_documento.c24soltipcod  = 7)   and
                   g_documento.itaciacod   is not null and
                   lr_documento.ramcod     is not null and
                   lr_documento.aplnumdig  is not null then
                       call cty22g00_atualiza_email_itau(g_documento.itaciacod  ,
                                                         lr_documento.ramcod    ,
                                                         lr_documento.aplnumdig )
                       returning l_resultado,
                                 l_mensagem
                       error l_mensagem
               end if
           else
           # Chama a Funcao de Envio do Link do Terceiro
           if not cta00m22_terceiro() then
               # Verifica E-mail do Segurado
       if (lr_documento.c24soltipcod  = 1    or
           lr_documento.c24soltipcod  = 7)   and
           lr_documento.ramcod    is not null and
           lr_documento.succod    is not null and
           lr_documento.aplnumdig is not null and
           lr_documento.itmnumdig is not null then



           call cts09g00(lr_documento.ramcod   ,
                         lr_documento.succod   ,
                         lr_documento.aplnumdig,
                         lr_documento.itmnumdig,
                         true)
           returning ws.dddcod, ws.teltxt

                     # Chama a Funcao de Envio do Link Segurado

           call cta00m22(lr_documento.ramcod    ,
                         lr_documento.succod    ,
                         lr_documento.aplnumdig ,
                         lr_documento.itmnumdig )
                       end if
               end if
          end if
       end if
       let g_documento.lignum = lr_documento.lignum

       if ( g_documento.c24astcod = "F45"     or
            g_documento.c24astcod = "L10"     or
            g_documento.c24astcod = "L11"     or
            g_documento.c24astcod = "L12"     or
            g_documento.c24astcod = "L45" )   and
            g_documento.aplnumdig is not null and
            g_documento.aplnumdig <> 0 then

          call cts05g00 (g_documento.succod,
                         g_documento.ramcod,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig)
               returning lr_cts05g00.segnom,
                         lr_cts05g00.corsus,
                         lr_cts05g00.cornom,
                         lr_cts05g00.cvnnom,
                         lr_cts05g00.vclcoddig,
                         lr_cts05g00.vcldes,
                         lr_cts05g00.vclanomdl,
                         lr_cts05g00.vcllicnum,
                         lr_cts05g00.vclchsinc,
                         lr_cts05g00.vclchsfnl,
                         lr_cts05g00.vclcordes

          if ( g_documento.c24astcod = "F45"     or
               g_documento.c24astcod = "L10"     or
               g_documento.c24astcod = "L11"     or
               g_documento.c24astcod = "L12"     or
               g_documento.c24astcod = "L45" )   then
               let l_msg_log = "Placa->", lr_cts05g00.vcllicnum, " Assunto->",g_documento.c24astcod,
                               " Ligacao: ", g_documento.lignum,
                               " Doc ->",lr_documento.succod,"/",lr_documento.aplnumdig

               call errorlog(l_msg_log)
          end if

          ## Regra retirada conforme e-mail de Ronigley Ferreira em 10/09 as 19:13
          #######################################################################################
          ##Galbe e Ruiz,                                                                       #
          ## Enviamos todos os comunicados de roubo/furto para o sistema do Sergio patrimonial  #
          ## verificar se existe registro de DAF em sua base, portanto seguindo a mesma regra   #
          ## entendo que devemos enviar e-mail e comunica��o de todas as localiza��es que s�o   #
          ## informadas na Ct24hs, mesmo que n�o tenhamos informa��o do DAF.                    #
          #######################################################################################

          ## Retorno da Regra conforme e-mail de Edson Souza e Ronigley Ferreira em 25/08/09 as 16:30
          #######################################################################################
          ##Ronigley informa:,                                                                  #
          ## At� porque o e-mail foi implementado na �poca com conting�ncia, pois o sistema     #
          ## de sinistro era novo e havia algumas falhas acontecendo no acionamento do sistema  #
          ## do DAF. Portanto como o sistema esta estavel, se estiver de acordo podemos         #
          ## desativar o envio das mensagens de alerta.                                         #
          #######################################################################################


      if g_documento.c24astcod = 'F45' then
          call fadic005_existe_dispo(lr_cts05g00.vclchsinc,
                                     lr_cts05g00.vclchsfnl,
                                     lr_cts05g00.vcllicnum,
                                     lr_cts05g00.vclcoddig,
                                     1546)
              returning m_tracker,
                        m_orrdat,
                        m_qtd_dispo_ativo
           if m_tracker = 0 then
             call fadic005_existe_dispo(lr_cts05g00.vclchsinc,
                                     lr_cts05g00.vclchsfnl,
                                     lr_cts05g00.vcllicnum,
                                     lr_cts05g00.vclcoddig,
                                     1333)
              returning m_ituran,
                        m_orrdat,
                        m_qtd_dispo_ativo
              if m_ituran = 0 then
                call fadic005_existe_dispo(lr_cts05g00.vclchsinc,
                                           lr_cts05g00.vclchsfnl,
                                           lr_cts05g00.vcllicnum,
                                           lr_cts05g00.vclcoddig,
                                           9099)
                    returning m_ituran,
                              m_orrdat,
                              m_qtd_dispo_ativo
              end if
           end if
           if m_ituran = 1 or m_tracker = 1 then
              call cta02m00_enviaEmail(g_documento.lignum,
                                      lr_cts05g00.vcllicnum,
                                      lr_cts05g00.vcldes,
                                      lr_cts05g00.segnom,
                                      g_documento.c24astcod)
           end if
      end if
        let l_temDaf5 = fadic005(lr_cts05g00.vclchsfnl,
                                 lr_cts05g00.vcllicnum,
                                 3646)
        if l_temDaf5 = false then
           let l_temDaf5 = fadic005(lr_cts05g00.vclchsfnl,
                                    lr_cts05g00.vcllicnum,
                                    8230)
        end if

        if l_temDaf5 = true then
             call cta02m00_enviaEmail(g_documento.lignum,
                                      lr_cts05g00.vcllicnum,
                                      lr_cts05g00.vcldes,
                                      lr_cts05g00.segnom,
                                      g_documento.c24astcod)

          ## chamar cty13g00 para gravar dados para DAF5
          let lr_cts05g00.vclchsnum  = lr_cts05g00.vclchsinc clipped, lr_cts05g00.vclchsfnl clipped

          -------------[ funcao de interface com sistema daf ]------------------
          call cty13g00("",                    # Fim Integra��o                       |excfnl
                        "",                    # Codigo Erro                          |errcod
                        "",                    # Descri��o Erro                       |errdsc
                        "",                    # Codigo Dispositivo                   |discoddig
                        "",                    # ws.lclltt # Latitude                 |sinlclltt
                        "",                    # ws.lcllgt # Longitude                |sinlcllgt
                        "",                    # param.atdsrvnum # N�mero Atendimento |atdsrvnum
                        "",                    # param.atdsrvano # Ano Atendimento    |atdsrvano
                        lr_cts05g00.vclcoddig, # ws.vclcoddig    # Codigo Ve�culo     |vclcoddig
                        lr_cts05g00.vcldes,    # Descricao Ve�culo                    |vcldes
                        lr_cts05g00.vcllicnum, # Placa Ve�culo                        |vcllicnum
                        g_documento.c24astcod, # Assunto
                        lr_cts05g00.vclchsnum, # N�mero Chassi                        |vclchscod
                        lr_cts05g00.segnom,    # Nome Segurado                        |segnom
                        "", #?? ws.sindat,     # Data Sisnistro                       |sindat
                        "", #?? ws.sinhor,     # Data Comunicado                      |cincmudat
                        w_today,               # Data Cadastro                        |caddat
                        "",                    # Importancia Segurada                 |imsvlr
                        "",                    # Resumo do Sinistro                   |sinres
                        "",                    # Ticket de Entrega                    |enttck
                        g_documento.succod,    # Codigo Sucursal                      |succod
                        g_documento.aplnumdig, # N�mero Ap�lice                       |aplnumdig
                        g_documento.itmnumdig, # Item Ap�lice                         |itmnumdig
                        "",                    # Seq N�mero Docto                     |dctnumseq
                        "",                    # ws.edsnumref, # N�mero Endosso       |edsnumdig
                        "",                    # ws.prporg,    # Origem Proposta      |prporgpcp
                        "",                    # ws.prpnumdig, # N�mero Proposta      |prpnumpcp
                        lr_documento.cgccpfnum,# N�mero CGC/CPF                       |cgccpfnum
                        lr_documento.cgcord,   # Ordem CGC                            |cgcord
                        lr_documento.cgccpfdig,# D�gito CGC/CPF                       |cgccpfdig
                        lr_cts05g00.vclcordes, # Descri��o cor Ve�culo                |vclcordsc
                        "",                    # Nome Condutor                        |cdtnom
                        "",                    # N�mero Tentativas                    |itgttvnum
                        "cta02m00")            # Programa chamador   ---> Ruiz/Camila
        end if
       end if
       #PSI-2010-01746-EV
        let l_temDaf5 = fadic005(lr_cts05g00.vclchsfnl,
                                 lr_cts05g00.vcllicnum,
                                 8001)

        if l_temDaf5 = true then
             call cta02m00_enviaEmail(g_documento.lignum,
                                      lr_cts05g00.vcllicnum,
                                      lr_cts05g00.vcldes,
                                      lr_cts05g00.segnom,
                                      g_documento.c24astcod)

       end if
       #PSI-2010-01746-EV

       ## Obter placa de chassi final do veiculo --##
       #====Envia email de recuperados para sinivem quando possui apolice ====#
       if g_documento.aplnumdig is not null and
          g_documento.lignum    is not null then
          if d_cta02m00.c24astcod = "L10" or
             d_cta02m00.c24astcod = "L11" or
             d_cta02m00.c24astcod = "L12" or
             d_cta02m00.c24astcod = "L45" then

             call cty05g00_dados_veic(lr_documento.succod
                                     ,lr_documento.aplnumdig
                                     ,lr_documento.itmnumdig
                                     ,lr_cty05g01.vclsitatu)
             returning lr_ret.resultado
                      ,lr_ret.mensagem
                      ,lr_ret.vcllicnum
                      ,lr_ret.vclchsinc
                      ,lr_ret.vclchsfnl
                      ,lr_ret.vclanofbc
                      ,lr_ret.vclcoddig

             let l_msg_log = "Placa->", lr_ret.vcllicnum,  " Assunto->", d_cta02m00.c24astcod,
                             " Ligacao: ", g_documento.lignum,
                             " Doc ->",lr_documento.succod,"/",lr_documento.aplnumdig

             call errorlog(l_msg_log)

             let avsrcprd = 1

             let l_ret = cts37m00_msg_siniven(lr_ret.vcllicnum
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
                                             ,""
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

       # PATRICIA
       if  (g_documento.c24astcod = "L10"  or
            g_documento.c24astcod = "L45") then
            let l_msg_log = "Placa->", lr_ret.vcllicnum, " Assunto->", g_documento.c24astcod,
                            " Ligacao: ", g_documento.lignum,
                            " Doc ->",lr_documento.succod,"/",lr_documento.aplnumdig

             call errorlog(l_msg_log)

            initialize cts37m00_reg to null

            let lr_cts05g00.vclchsnum  = lr_cts05g00.vclchsinc clipped, lr_cts05g00.vclchsfnl clipped

            if (g_documento.c24astcod = "L10") then
                open c_cta02m00_016 using lr_documento.lignum

                whenever error continue
                fetch c_cta02m00_016 into lr_documento.lignum,
                                         lr_documento.atdsrvano,
                                         lr_documento.atdsrvnum,
                                         w_ligdat,
                                         w_lighorinc
                close c_cta02m00_016
                whenever error stop

                if (g_documento.c24astcod = "L10" and
                   (lr_documento.atdsrvnum is null and
                    lr_documento.atdsrvano is null)) then
                    error "Ligacao sem numero de atendimento!"
                end if
            end if

            if ((g_documento.c24astcod = "L10" and
                (lr_documento.atdsrvnum is not null and
                 lr_documento.atdsrvano is not null)) or
                 g_documento.c24astcod = "L45") then

                call cts37m00_envia_localizacao(
                       g_documento.c24astcod,
                       lr_documento.atdsrvnum,
                       lr_documento.atdsrvano,
                       lr_cts05g00.vcllicnum,
                       lr_cts05g00.vclchsnum,
                       g_issk.funmat,
                       cts37m00_reg.vclpdrseg,
                       cts37m00_reg.lcldat,
                       cts37m00_reg.delegacia)
            end if
       end if


       if lr_result.stt <> 1 then
          exit while
       end if

       if g_setexplain = 1 then
          let l_msg = 'cta02m00 - Gerou ligacao ', lr_documento.lignum
          call cts01g01_setetapa(l_msg)
       end if


       if lr_documento.cndslcflg  =  "S"   then
#=>       PSI.188425 - ELIMINAR TABELA TEMPORARIA DE CONDUTOR
          call cta02m07_eliminar_tmp()
               returning lr_result.*
          if lr_result.stt <> 1 then
             error lr_result.msg
             exit while
          end if
          let lr_documento.cndslcflg = null

          ##-- Manter o g_documento.cndslcflg --##
          let g_documento.cndslcflg = lr_documento.cndslcflg

          let ws.cndslcflg = null

       end if

       initialize ws.c24atrflg to null
       initialize ws.c24jstflg to null
       whenever error continue
       select count(*) from tmp_autorizasrv
       if sqlca.sqlcode = 0 then
          drop table tmp_autorizasrv
       end if
       whenever error stop

       #----------------------------------------------------------------
       # Interface para envio de mensagem via Teletrim
       #----------------------------------------------------------------

       call cts10g13_grava_rastreamento(lr_documento.lignum           ,
                                        '2'                           ,
                                        'cta02m00'                    ,
                                        '1'                           ,
                                        '1- Assunto Sem Permissao'    ,
                                        ' '                            )


       let l_passou = cta02m00_envio_msg_Teletrim(lr_documento.ramcod
                                                 ,lr_documento.succod
                                                 ,lr_documento.aplnumdig
                                                 ,lr_documento.itmnumdig
                                                 ,lr_documento.lignum
                                                 ,ws.c24asttltflg
                                                 ,l_maimsgenvflg)
    else

       if g_issk.acsnivcod = 6         then
           ##-- Obtem qtd ligacoes para verificar se registrou algum atendimento
           call cts10g07_qtdlig(lr_documento.succod
                               ,lr_documento.ramcod
                               ,lr_documento.aplnumdig
                               ,lr_documento.itmnumdig
                               ,lr_documento.prporg
                               ,lr_documento.prpnumdig
                               ,lr_documento.sinano
                               ,lr_documento.sinnum
                               ,lr_documento.sinitmseq
                               ,lr_ppt.cmnnumdig
                               ,lr_documento.corsus          ## CT 308846
                               ,lr_documento.cgccpfnum
                               ,lr_documento.cgcord
                               ,lr_documento.cgccpfdig
                               ,lr_documento.funmat
                               ,lr_documento.ctttel
                               ,lr_documento.crtsaunum)
           returning  lr_cts10g07.resultado
                     ,lr_cts10g07.mensagem
                     ,w_totligdep

           if lr_documento.apoio <> 'S' or
              lr_documento.apoio is null then
              call cta02m20_remover_atendimento()
           end if
           if ws.docflg   = "S"             and
              w_totligant = w_totligdep     and
              lr_documento.pcacarnum is null then
              let int_flag = false
              if lr_documento.flgtransp = "S" then
                 exit while
              else
                 error " Codigo de assunto deve ser registrado!"
                 continue while
              end if
           else
              exit while
           end if
       else
            ##-- Tratar insert/delete na datkgeral --##
            call cta02m00_trata_datkgeral(w_grlchv
                                         ,w_grlchvX)
            returning l_resultado
                     ,l_mensagem

            if l_resultado = 3 then
               error l_mensagem
            end if

           if lr_documento.apoio <> 'S' or
              lr_documento.apoio is null then
              call cta02m20_remover_atendimento()
           end if
       end if
       exit while
    end if
    --------------[ grava hora final a ligacao ]----------------------
    open c_cta02m00_016 using lr_documento.lignum


    whenever error continue
    fetch c_cta02m00_016 into lr_documento.lignum,
                             lr_documento.atdsrvano,
                             lr_documento.atdsrvnum,
                             w_ligdat,
                             w_lighorinc
    whenever error stop
    if sqlca.sqlcode = 0 then
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let w_horafinal  =  l_hora2

       if w_horafinal <  w_lighorinc  and
          l_data      <= w_ligdat     then
          error "Problema na hora final da ligacao, ", lr_documento.lignum
       else
          update datmligacao
          set  lighorfnl = w_horafinal
          where lignum = lr_documento.lignum
       end if
    else
       if sqlca.sqlcode = notfound  then
       else
         error " Problema SELECT na tabela datmligacao", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
         return
       end if
    end if

    # Se for Cortesia PSS gravo na Tabela de Cortesia

    if g_documento.ciaempcod  = 43  and
       lr_pss.resultado       = 3   and
       g_pss.psscntcod        is not null and
       lr_documento.atdsrvnum is not null and
       lr_documento.atdsrvano is not null then

       call cta00m26_grava_cortesia(lr_documento.atdsrvnum ,
                                    lr_documento.atdsrvano )
    end if

       #-------------------------------------------------------------------
       # Verifica os assuntos para emvio de E-mail e SMS (PSI233498) - Denis
       #-------------------------------------------------------------------
          if d_cta02m00.c24astcod = "S60"  or
             d_cta02m00.c24astcod = "S63"  or
             d_cta02m00.c24astcod = "F10"  or
             d_cta02m00.c24astcod = "V10"  or
             d_cta02m00.c24astcod = "B50"  then

             select cpodes into FlgEnvMsg
                 from iddkdominio where cponom = 'ctenvmsg'

               if sqlca.sqlcode = notfound  then
                  let FlgEnvMsg = 'N'
               end if

               if FlgEnvMsg = 'S' then

                    select segnumdig into l_segnumdig
                       from abbmdoc
                       where succod = lr_documento.succod
                         and aplnumdig = lr_documento.aplnumdig
                         and dctnumseq in( select max(dctnumseq) from abbmdoc
                                           where succod = lr_documento.succod
                                             and aplnumdig = lr_documento.aplnumdig)

                    if sqlca.sqlcode = 0 then
                         ## Encontrou o segurado pelo documento

                         select corsusldr into l_corsus
                            from abamapol
                            where succod = lr_documento.succod
                            and aplnumdig = lr_documento.aplnumdig

                         if sqlca.sqlcode = 0 then
                         ## Encontrou o Corretor pelo documento

                            call cta02m00_EnviaEmailSms(d_cta02m00.c24astcod, l_segnumdig, l_corsus,lr_documento.succod,lr_documento.aplnumdig)
                         end if

                    end if
               end if
          end if

   #inicio psi172057  ivone(1)
    if lr_documento.c24soltipcod = 2  or
       lr_documento.c24soltipcod = 8  then
       # -- CT 252794 - Katiucia -- #
       if lr_documento.corsus <> g_corretor.corsusapl then

          # -- Inicio CT 6114026 - Burini -- #

          open c_cta02m00_018 using lr_documento.lignum

          whenever error continue
          fetch c_cta02m00_018 into l_aux
          whenever error stop

          if  sqlca.sqlcode = notfound then

               whenever error continue
               execute p_cta02m00_003 using lr_documento.lignum,
                                     lr_documento.corsus
               whenever error stop
               if sqlca.sqlcode <> 0 then
                 error " Erro INSERT tab. datrligcor", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
                 error "Funcao cta02m00()/",lr_documento.lignum,"/", lr_documento.corsus
                 exit while
               end if
          else
               if  sqlca.sqlcode <> 0 then
                   error " Erro SELECT tab. datrligcor", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
                   error "Funcao cta02m00()/",lr_documento.lignum,"/", lr_documento.corsus
                   exit while
               end if
           end if
           # -- Fim CT 6114026 - Burini -- #
       end if
    end if

    ## Obter a origem do servico para verificar na contingencia
    call cts10g06_dados_servicos(1, lr_documento.atdsrvnum,
                                    lr_documento.atdsrvano)
         returning l_resultado, l_mensagem, l_atdsrvorg, l_data

    let g_documento.atdsrvorg = l_atdsrvorg
    let g_documento.c24astcod = lr_documento.c24astcod

    call cta00m08_ver_contingencia(2)
         returning l_contingencia

    if lr_documento.lignum is not null then
       if l_passou = false then

          call figrc072_setTratarIsolamento() -- > psi 223689



          call cts30m00(lr_documento.ramcod   , lr_documento.c24astcod,
                        lr_documento.ligcvntip, lr_documento.succod,
                        lr_documento.aplnumdig, lr_documento.itmnumdig,
                        lr_documento.lignum   , lr_documento.atdsrvnum,
                        lr_documento.atdsrvano, lr_documento.prporg,
                        lr_documento.prpnumdig, lr_documento.solnom)
                        returning l_envio

         if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
            error "Problemas na funcao cts30m00 ! Avise a Informatica !" sleep 2

            #exit while
         end if        -- > 223689

       end if
    end if

  if g_documento.c24astcod <> 'GOF' then
#SA__260142_1
    if (ws.prgcod = 1  and
       lr_documento.lignum is not null and
       lr_documento.lignum <> " ")
    or
       ( g_documento.c24astcod = "E12" )
    then


         #if l_confirma = "S" then
         #   call cta02m00_popup_recomenda()  #chama popup com os assuntos F10 N10 e N11
         #        returning l_assunto
         let l_assunto = 'SIN'


           let g_documento.c24astcod = l_assunto

           call cts25g00_dados_assunto(1, l_assunto)
           returning lr_cts10g07.resultado,
                     lr_cts10g07.mensagem,
                     l_rcuccsmtvobrflg,
                     w_c24astexbflg,
                     w_telmaiatlflg,
                     ws.prgcod,
                     ws.c24aststt,
                     ws.c24asttltflg,
                     ws.cndslcflg,
                     ws.c24atrflg,
                     ws.c24jstflg,
                     wg_c24astpgrtxt,
                     l_maimsgenvflg,
                     l_webrlzflg,
                     ws.ciaempcod


            if l_assunto = 'SIN' then
               if ws.c24aststt = 'C' then

                   let l_confirma = cts08g01 ("A","N", "",
                                 "AVISO DE SINISTRO INOPERANTE, ",
                                 "REGISTRE O CODIGO AGD ! ",
                                 "")
               else
                   let l_confirma = cts08g01("A","N",
                                            " SERA NECESSARIO O PREENCHIMENTO DO ",
                                            " AVISO DO SINISTRO ",
                                            "",
                                            "")
                 call cta02m13_aviso_sinistro(ws.prgcod
                                             ,ws.atdsrvorg_rcl
                                             ,ws.aplflg
                                             ,ws.docflg
                                             ,l_webrlzflg)
               end if
            end if
            #else
            #   if l_assunto = 'N10' or
            #      l_assunto = 'N11' then
            #
            #      call cta02m13_aviso_sinistro(ws.prgcod
            #                                  ,ws.atdsrvorg_rcl
            #                                  ,ws.aplflg
            #                                  ,ws.docflg
            #                                  ,l_webrlzflg)
            #
            #   else
            #     call cta02m13_furto_roubo(ws.prgcod
            #                              ,ws.atdsrvorg_rcl
            #                              ,ws.aplflg
            #                              ,ws.docflg
            #                              ,l_webrlzflg)
            #   end if
            #end if

         #end if



    end if
#SA__260142_1
  end if
initialize lr_documento.atdsrvnum  to null
initialize lr_documento.atdsrvano  to null

##-- Manter o g_documento.atdsrvnum, atdsrvano e lignum --##
let g_documento.atdsrvnum = lr_documento.atdsrvnum
let g_documento.atdsrvano = lr_documento.atdsrvano
let g_documento.lignum    = lr_documento.lignum

end while

call cta02m00_anula_cgccpf()

#---> Decreto - 6523
whenever error continue
drop table cta02m00_tmp_ligacoes
whenever error stop

#---> Decreto - 6523
let g_documento.atdnum = null

let int_flag = false
close window cta02m00

end function

#-------------------------------------------#
function cta02m00_acertar_ramo(lr_parametro)
#-------------------------------------------#
 define lr_parametro record
    ramcod    like rsamseguro.ramcod
   ,succod    like abamapol.succod
   ,aplnumdig like abamapol.aplnumdig
 end record

 define l_ramcod           like rsamseguro.ramcod
       ,l_resultado        smallint
       ,l_mensagem         char(60)
       ,l_data_resolucao86 date

 define lr_cty05g00 record
    resultado smallint
   ,mensagem  char(42)
   ,emsdat    like abamdoc.emsdat
   ,aplstt    like abamapol.aplstt
   ,vigfnl    like abamapol.vigfnl
   ,etpnumdig like abamapol.etpnumdig
 end record

 let l_ramcod           = null
 let l_resultado        = null
 let l_mensagem         = null
 let l_data_resolucao86 = null

 initialize lr_cty05g00 to null

 if lr_parametro.ramcod <> 31 and
    lr_parametro.ramcod <> 531 then
    return lr_parametro.ramcod
 end if

 if lr_parametro.succod is null or
    lr_parametro.aplnumdig is null then
    return lr_parametro.ramcod
 end if

 ##-- Obter data da resolucao 86 --##
 call cta12m00_seleciona_datkgeral('ct24resolucao86')
 returning l_resultado
          ,l_mensagem
          ,l_data_resolucao86

 if l_resultado <> 1 then
    error l_mensagem
    return lr_parametro.ramcod
 end if

 ##-- Obter data emissao da apolice --##
 call cty05g00_dados_apolice(lr_parametro.succod
                            ,lr_parametro.aplnumdig)
 returning lr_cty05g00.*

 if lr_cty05g00.resultado <> 1 then
    error l_mensagem
    return lr_parametro.ramcod
 end if

 let l_ramcod = 31
 if lr_cty05g00.emsdat >= l_data_resolucao86 then
    let l_ramcod = 531
 end if

 return l_ramcod

end function

#----------------------------------------------#
function cta02m00_trata_datkgeral(lr_parametro)
#----------------------------------------------#
 define lr_parametro record
    grlchv  like datkgeral.grlchv
   ,grlchvx like datkgeral.grlchv
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
 end record

 define l_grlinf like datkgeral.grlinf

 initialize lr_retorno to null

 let l_grlinf = null

 ##-- Selecionar datkgeral --##
 call cta12m00_seleciona_datkgeral(lr_parametro.grlchv)
 returning lr_retorno.resultado
          ,lr_retorno.mensagem
          ,l_grlinf

 if lr_retorno.resultado = 1 then
    ##-- Remove de datkgeral --##
    call cta12m00_remove_datkgeral(lr_parametro.grlchv)
    returning lr_retorno.resultado
             ,lr_retorno.mensagem

    if lr_retorno.resultado <> 1 then
       return
    end if
 end if

 ##-- Selecionar de datkgeral --##
 call cta12m00_seleciona_datkgeral(lr_parametro.grlchvx)
 returning lr_retorno.resultado
          ,lr_retorno.mensagem
          ,l_grlinf

 if lr_retorno.resultado = 1 then
    ##-- Remover de datkgeral --##
    call cta12m00_remove_datkgeral(lr_parametro.grlchvx)
    returning lr_retorno.resultado
             ,lr_retorno.mensagem
 end if

 return lr_retorno.*

end function

#----------------------------------------#
function cta02m00_trata_u10(lr_parametro)
#----------------------------------------#
 define lr_parametro record
    sinramcod like ssamsin.ramcod
   ,sinano    like ssamsin.sinano
   ,sinnum    like ssamsin.sinnum
   ,sinitmseq like ssamitem.sinitmseq
   ,succod    like abamapol.succod
   ,ramcod    like rsamseguro.ramcod
   ,aplnumdig like abamapol.aplnumdig
   ,itmnumdig like abbmdoc.itmnumdig
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,sinramcod like ssamsin.ramcod
   ,sinano    like ssamsin.sinano
   ,sinnum    like ssamsin.sinnum
   ,sinitmseq like ssamitem.sinitmseq
   ,sinnull   smallint
 end record

 define l_confirma char(01)

 initialize lr_retorno to null

 let l_confirma         = null
 let lr_retorno.sinnull = 0

 ##-- Pedir confirmacao do assunto --##
 let l_confirma = cts08g01('A','S', '' ,"CONFIRMA ASSUNTO INFORMADO ?", '', '')
 if l_confirma = 'N' then
    let lr_retorno.resultado = 2
    let lr_retorno.mensagem = 'Assunto nao confirmado '
    return lr_retorno.*
 end if

 ##-- Tratar quando nao tem sinistro --##
 if lr_parametro.sinramcod is null or
    lr_parametro.sinano    is null or
    lr_parametro.sinnum    is null or
    lr_parametro.sinitmseq is null then
    if lr_parametro.succod    is null or
       lr_parametro.ramcod    is null or
       lr_parametro.aplnumdig is null or
       lr_parametro.itmnumdig is null then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = ' Assunto deve estar vinculado a um documento! '
       return lr_retorno.*
    end if

    let lr_retorno.sinnull = 1

    ##-- Obter Pop_up de sinistros informados para o documento --##
    call cty01g02_fsauc540(lr_parametro.succod
                          ,lr_parametro.ramcod
                          ,lr_parametro.aplnumdig
                          ,lr_parametro.itmnumdig)
    returning lr_retorno.sinramcod
             ,lr_retorno.sinano
             ,lr_retorno.sinnum

    if lr_retorno.sinramcod is null or
       lr_retorno.sinano    is null or
       lr_retorno.sinnum    is null then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Nao existem sinistros para a apolice informada! '
    else
       ##-- Obter a Pop_up de terceiros relacionados no processo do sinistro. --##
       call cty01g01_fsauc530 (lr_retorno.sinramcod
                              ,lr_retorno.sinano
                              ,lr_retorno.sinnum
                              ,''
                              ,'')
       returning lr_retorno.resultado
                ,lr_retorno.mensagem
                ,lr_retorno.sinramcod
                ,lr_retorno.sinano
                ,lr_retorno.sinnum
                ,lr_retorno.sinitmseq

       if lr_retorno.sinramcod is null or
          lr_retorno.sinano    is null or
          lr_retorno.sinnum    is null or
          lr_retorno.sinitmseq is null then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Sinistro com problemas! '
       end if
    end if
 end if

 return lr_retorno.*

end function

#----------------------------------------#
function cta02m00_trata_f10(lr_parametro)
#----------------------------------------#
 define lr_parametro record
    succod    like abamapol.succod
   ,aplnumdig like abamapol.aplnumdig
   ,itmnumdig like abbmdoc.itmnumdig
   ,vclsitatu decimal(04,00)
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,vcllicnum like abbmveic.vcllicnum
   ,vclchsinc like abbmveic.vclchsfnl
   ,vclchsfnl like abbmveic.vclchsfnl
   ,vclanofbc like abbmveic.vclanofbc
   ,vclcoddig like abbmveic.vclcoddig
 end record

 define l_ituran   smallint
       ,l_orrdat   like adbmbaixa.orrdat
       ,l_confirma char(01)
       ,l_qtd_dispo_ativo integer

 initialize lr_retorno to null

 let l_ituran   = null
 let l_confirma = null
 let l_orrdat   = null
 let l_qtd_dispo_ativo = null

 ##-- Inserido mais um parametro de retorno (l_qtd_dispo_ativo)  --##
 ##-- Projeto Instalacao de 2 DAF's em caminhoes - Jorge Modena  --##

 if lr_parametro.succod is not null and
    lr_parametro.aplnumdig is not null then
    ##-- Obter placa de chassi final do veiculo --##
    call cty05g00_dados_veic(lr_parametro.succod
                            ,lr_parametro.aplnumdig
                            ,lr_parametro.itmnumdig
                            ,lr_parametro.vclsitatu)
    returning lr_retorno.resultado
             ,lr_retorno.mensagem
             ,lr_retorno.vcllicnum
             ,lr_retorno.vclchsinc
             ,lr_retorno.vclchsfnl
             ,lr_retorno.vclanofbc
             ,lr_retorno.vclcoddig

    ##-- Verifica o veiculo possui dispositivo Ituran --##

    call fadic005_existe_dispo(lr_retorno.vclchsinc,
                               lr_retorno.vclchsfnl,
                               lr_retorno.vcllicnum,
                               lr_retorno.vclcoddig,
                               1333)
       returning l_ituran
                ,l_orrdat
                ,l_qtd_dispo_ativo
    if l_ituran = 0 then
      call fadic005_existe_dispo(lr_retorno.vclchsinc,
                               lr_retorno.vclchsfnl,
                               lr_retorno.vcllicnum,
                               lr_retorno.vclcoddig,
                               9099)
       returning l_ituran
                ,l_orrdat
                ,l_qtd_dispo_ativo
    end if

    if l_ituran = 1 then
       let l_confirma = cts08g01('A'
                                ,'N'
                                ,"Apos o preenchimento do comunicado orien"
                                ,"te o  segurado  a contatar a ct24hrs da"
                                ,"ITURAN  e  fornecer  sua  senha secreta."
                                ,"FONES : 0800-153600 ou (11)3616-9999" )
    else
       ##-- Verifica o veiculo possui dispositivo Tracker --##

       call fadic005_existe_dispo(lr_retorno.vclchsinc,
                                  lr_retorno.vclchsfnl,
                                  lr_retorno.vcllicnum,
                                  lr_retorno.vclcoddig,
                                  1546)
         returning l_ituran
                  ,l_orrdat
                  ,l_qtd_dispo_ativo

       if l_ituran = 1 then
          let l_confirma = cts08g01('A'
                                   ,'N'
                                   ,"Apos o preenchimento do comunicado orien"
                                   ,"te o  segurado  a contatar a ct24hrs da"
                                   ,"TRACKER DO BRASIL e  fornecer  sua  "
                                   ,"senha secreta. FONE : 0800-7728476" )
       end if
    end if
 end if

end function

#----------------------------------------------------------------------------#
function cta02m00_qtdatd(lr_parametro)
#----------------------------------------------------------------------------#

   define lr_parametro record
          ramcod       like rsamseguro.ramcod
         ,succod       like abamapol.succod
         ,aplnumdig    like abamapol.aplnumdig
         ,itmnumdig    like abbmdoc.itmnumdig
         ,c24astcod    like datmligacao.c24astcod
         ,bnfnum       like datksegsau.bnfnum
         ,crtsaunum    like datksegsau.crtsaunum
   end record

   define lr_retorno record
          resultado smallint
         ,mensagem  char(60)
   end record

   define l_flag_limite     char(01)
         ,l_cls4448         char(01)
         ,l_qtd_atendimento integer
         ,l_qtd_limite      integer
         ,l_saldo           integer
         ,l_confirma        char(01)
         ,l_tem_alerta      smallint
         ,l_clscod          char(03)
         ,l_sem_uso         char(01)
         ,l_atende          smallint  -->1- Atende / 2 - Nao atende
	 ,l_cod_erro        char(40)
	 ,l_data_calculo    date
	 ,l_flag_endosso    char(01)

   initialize lr_retorno.* to null
   initialize l_tem_alerta to null

   let l_flag_limite     = null
   let l_qtd_atendimento = null
   let l_qtd_limite      = null
   let l_confirma        = null
   let l_clscod          = null
   let l_sem_uso         = null
   let l_atende          = null


   call faemc144_clausula(lr_parametro.succod
                         ,lr_parametro.aplnumdig
                         ,lr_parametro.itmnumdig)
     returning l_sem_uso
              ,l_clscod -- clausula
              ,l_sem_uso
              ,l_sem_uso

   if cta13m00_verifica_clausula_044(lr_parametro.succod    ,
   	                                 lr_parametro.aplnumdig ,
   	                                 lr_parametro.itmnumdig ,
   	                                 g_funapol.dctnumseq    ,
   	                                 l_clscod               ) then
      let l_clscod = "044"

   end if
   if lr_parametro.c24astcod = 'S10' then
      if cty31g00_nova_regra_clausula(lr_parametro.c24astcod) then
          call cty31g00_valida_envio_socorro(lr_parametro.ramcod    ,
                                             lr_parametro.succod    ,
                                             lr_parametro.aplnumdig ,
                                             lr_parametro.itmnumdig ,
                                             lr_parametro.c24astcod )
          returning lr_retorno.resultado
                   ,lr_retorno.mensagem
                   ,l_flag_limite
          if l_flag_limite = "S" then
              let l_confirma = cts08g01('A'
                               ,'N'
                               ,''
                               ,'CONSULTE A COORDENACAO, '
                               ,'PARA ENVIO DE ATENDIMENTO., '
                               ,'')
              return 2
          end if
      else
          call cty26g01_clausula (lr_parametro.succod   ,   ## JUNIOR (FORNAX)
			          lr_parametro.aplnumdig,
			          lr_parametro.itmnumdig)
                        returning l_cod_erro,
                                  l_clscod  ,
                                  l_data_calculo,
                                  l_flag_endosso
          if (l_clscod <> "044"  and
	            l_clscod <> "44R"  and
	            l_clscod <> "048"  and
	            l_clscod <> "48R" ) or
	            l_clscod is null then

              call cty05g02_envio_socorro(lr_parametro.ramcod
                                         ,lr_parametro.succod
                                         ,lr_parametro.aplnumdig
                                         ,lr_parametro.itmnumdig)
                                returning lr_retorno.resultado
                                         ,lr_retorno.mensagem
                                         ,l_flag_limite

               if (l_flag_limite = "S")                  and
                  (l_clscod = "033" or l_clscod = "33R") and
                  (l_clscod = "46R" or l_clscod = "47R") then

                  let l_confirma = cts08g01('A'
                                   ,'N'
                                   ,''
                                   ,'CONSULTE A COORDENACAO, '
                                   ,'PARA ENVIO DE ATENDIMENTO., '
                                   ,'')
                  return 2
               end if
          end if
      end if
   else

      let l_tem_alerta = 0 ## Nao apresentar alerta de efetuou a leitura

      #----------------------------
      --> Tratamento para Help Desk
      #----------------------------
      if lr_parametro.c24astcod = 'HDT' or
         lr_parametro.c24astcod = 'HDK' then


         #-------------------------------------------------------
         --> Funcao que verifica se pode ou nao dar o Atendimento
         #-------------------------------------------------------
         call cty05g07_s66_s67 ( lr_parametro.ramcod
                                ,lr_parametro.succod
                                ,lr_parametro.aplnumdig
                                ,lr_parametro.itmnumdig
                                ,lr_parametro.c24astcod)
         returning l_atende
         return l_atende

      else
	         if (l_clscod <> "044" and
	             l_clscod <> "44R" and
	             l_clscod <> "048" and
	             l_clscod <> "48R") and
	             l_clscod is not null then

               if lr_parametro.c24astcod = 'S54' then
                   if cty31g00_nova_regra_clausula(lr_parametro.c24astcod) then
                   	   call cty31g00_valida_envio_lei_seca(lr_parametro.ramcod    ,
                   	                                       lr_parametro.succod    ,
                   	                                       lr_parametro.aplnumdig ,
                   	                                       lr_parametro.itmnumdig ,
                   	                                       lr_parametro.c24astcod )
                   	   returning lr_retorno.resultado
                   	            ,lr_retorno.mensagem
                   	            ,l_flag_limite
                   	   if l_flag_limite = "S" then
                   	       let l_confirma = cts08g01('A'
                   	                        ,'N'
                   	                        ,''
                   	                        ,'CONSULTE A COORDENACAO, '
                   	                        ,'PARA ENVIO DE ATENDIMENTO., '
                   	                        ,'')
                   	       return 2
                   	   end if
                   else
                       call cty26g00_srv_lei_seca(lr_parametro.ramcod
		        	              ,lr_parametro.succod
		        		            ,lr_parametro.aplnumdig
		        		            ,lr_parametro.itmnumdig
		        		            ,lr_parametro.c24astcod
		        		            ,lr_parametro.bnfnum
		        		            ,lr_parametro.crtsaunum
		        		            ,"",999)
                             returning l_flag_limite, l_saldo, l_saldo, l_saldo, l_cls4448
                   end if
               else
                  if cty31g00_nova_regra_clausula(lr_parametro.c24astcod) then
                    if lr_parametro.c24astcod = "S60" or
                    	 lr_parametro.c24astcod = "S63" then
                       call cty33g00_calcula_residencia(lr_parametro.ramcod    ,
                                                        lr_parametro.succod    ,
                                                        lr_parametro.aplnumdig ,
                                                        lr_parametro.itmnumdig ,
                                                        lr_parametro.c24astcod ,
                                                        lr_parametro.bnfnum    ,
                                                        lr_parametro.crtsaunum ,
                                                        ""                     ,
                                                        1                      )
                       returning l_flag_limite
                    else
                       call cty31g00_valida_envio_residencia(lr_parametro.ramcod    ,
                                                             lr_parametro.succod    ,
                                                             lr_parametro.aplnumdig ,
                                                             lr_parametro.itmnumdig ,
                                                             lr_parametro.c24astcod ,
                                                             lr_parametro.bnfnum    ,
                                                             lr_parametro.crtsaunum ,
                                                             "")
                       returning lr_retorno.resultado
                                ,lr_retorno.mensagem
                                ,l_flag_limite
                                ,l_qtd_atendimento
                                ,l_qtd_limite
                    end if
                  else
                  	 if cty34g00_valida_clausula(l_clscod) then
                  	 	 if lr_parametro.c24astcod = "S60" or
                  	 	 	  lr_parametro.c24astcod = "S63" then
                  	 	    call cty33g00_calcula_residencia(lr_parametro.ramcod    ,
                  	 	                                     lr_parametro.succod    ,
                  	 	                                     lr_parametro.aplnumdig ,
                  	 	                                     lr_parametro.itmnumdig ,
                  	 	                                     lr_parametro.c24astcod ,
                  	 	                                     lr_parametro.bnfnum    ,
                  	 	                                     lr_parametro.crtsaunum ,
                  	 	                                     ""                     ,
                  	 	                                     2                      )
                  	 	    returning l_flag_limite
                  	   end if
                  	 else
                         call cty05g02_serv_residencia(lr_parametro.ramcod
                                                      ,lr_parametro.succod
                                                      ,lr_parametro.aplnumdig
                                                      ,lr_parametro.itmnumdig
                                                      ,lr_parametro.c24astcod
                                                      ,lr_parametro.bnfnum
                                                      ,lr_parametro.crtsaunum)
                                             returning lr_retorno.resultado
                                                      ,lr_retorno.mensagem
                                                      ,l_flag_limite
                                                      ,l_qtd_atendimento
                                                      ,l_qtd_limite
                     end if
                  end if
              end if
           else
                    call cty26g00_srv_caca(lr_parametro.ramcod
		        	          ,lr_parametro.succod
		        		        ,lr_parametro.aplnumdig
		        		        ,lr_parametro.itmnumdig
		        		        ,lr_parametro.c24astcod
		        		        ,lr_parametro.bnfnum
		        		        ,lr_parametro.crtsaunum
		        		        ,"",999)
                         returning l_flag_limite, l_saldo, l_saldo, l_saldo, l_cls4448
           end if

       if l_flag_limite = "S" then
        ##  (l_clscod = "35"  or l_clscod = "035" or l_clscod = "35R") then

          let l_confirma = cts08g01('A'
                                    ,'N'
                                    ,''
                                    ,'CONSULTE A COORDENACAO, '
                                    ,'PARA ENVIO DE ATENDIMENTO. '
                                    ,'')
          return 2
       end if
      end if
 end if

   if lr_retorno.resultado <> 1 then
      error lr_retorno.mensagem
      return 2     ##-- Bloquear atendimento --##
   end if

   if l_flag_limite = 'S' then
      let l_confirma = cts08g01('A'
                               ,'N'
                               ,''
                               ,'CONSULTE A COORDENACAO, '
                               ,'PARA ENVIO DE ATENDIMENTO., '
                               ,'')

      ##-- Bloquear atendimento quando atingir limite do serv.emergencial --##
      if lr_parametro.c24astcod = 'S60' or
         lr_parametro.c24astcod = 'S63' then
         return 2 ##-- Bloquear atendimento --##
      end if
   end if

   return 1

end function

#------------------------------------------------#
function cta02m00_envio_msg_Teletrim(lr_entrada)
#------------------------------------------------#
 define lr_entrada record
    ramcod       like datrservapol.ramcod      # Codigo Ramo
   ,succod       like datrligapol.succod       # Codigo Sucursal
   ,aplnumdig    like datrligapol.aplnumdig    # Numero Apolice
   ,itmnumdig    like datrligapol.itmnumdig    # Numero do Item
   ,lignum       like datmligacao.lignum       # Numero da Ligacao
   ,c24asttltflg like datkassunto.c24asttltflg
   ,maimsgenvflg char(01)
 end record

 define l_passou smallint
       ,l_flag_mail char(01)
       ,l_st_erro smallint
       ,l_msg     char(300)


 let l_passou    = false
 let l_flag_mail = null
 let l_st_erro   = null
 let l_msg       = null

 ##-- Interface para envio de mensagem via Teletrim --##

 if (lr_entrada.c24asttltflg = "S" or
     lr_entrada.maimsgenvflg  = "S"  ) and
    lr_entrada.lignum is not null then

    if lr_entrada.c24asttltflg = "S" and
       lr_entrada.maimsgenvflg  = "N" then
       ##-- Indica Somente pager --##
       let l_flag_mail =  'S'
    end if

    if lr_entrada.c24asttltflg = 'N' and
       lr_entrada.maimsgenvflg  = 'S' then
       ##-- Indica Somente e-mail --##
       let l_flag_mail =  1
    end if

    if lr_entrada.c24asttltflg = 'S' and
       lr_entrada.maimsgenvflg  = 'S' then
       ##-- Indica  Pager e email --##
       let l_flag_mail =  2
    end if

 end if

 if l_flag_mail is not null and
    lr_entrada.lignum is not null then

    call cts10g13_grava_rastreamento(lr_entrada.lignum     ,
                                     '2'                   ,
                                     'cta02m00'            ,
                                     '1'                   ,
                                     '2- Assunto Email OK' ,
                                     ' '                   )

    let m_server   = fun_dba_servidor("RE")
    let m_hostname = "porto@",m_server clipped , ":"

    call cta13m00_verifica_status(m_hostname)
      returning l_st_erro,l_msg

    if l_st_erro = true then
       let l_passou = cta04m00(lr_entrada.ramcod
                              ,lr_entrada.succod
                              ,lr_entrada.aplnumdig
                              ,lr_entrada.itmnumdig
                              ,lr_entrada.lignum
                              ,l_flag_mail)

    else
      error "Email para Corretor indisponivel no momento !" sleep 2
    end if

 end if

 return l_passou

end function

#--------------------------------------------------------------------------
 function cta02m00_cria_tmp() ####Cria TEMP para justificar.                                            u
#--------------------------------------------------------------------------
   whenever error continue
      create temp table tmp_autorizasrv
         (srvdepto    char(06)  ,
          srvfunmat   dec (06,0),
          srvempcod   dec (02,0),
          srvmaqsgl   char(03)  ,
          srvnome     char(50)  ,
          srvjustif   char(55)) with no log
   whenever error stop
   if sqlca.sqlcode  = 0 then
      create unique index tmp_ind1 on tmp_autorizasrv
              (srvfunmat,srvempcod,srvmaqsgl)
   end if
   if sqlca.sqlcode   != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then  # tabela ja existe
         delete from tmp_autorizasrv
      end if
   end if
end function  ###  cta02m00_cria_tmp

#--------------------------------------------------------------------------
 function cta02m00_lig()
#--------------------------------------------------------------------------
 define l_lignum       like datrligrcuccsmtv.lignum,
        l_rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod,
        l_astcod       char(04)

 define a_cta02m00 array[03] of record
    lignum         like datmligacao.lignum,
    ligdat         like datmligacao.ligdat,
    lighorinc      like datmligacao.lighorinc,
    funnom         like isskfunc.funnom,
    c24solnom      like datmligacao.c24solnom,
    c24soltipdes   like datksoltip.c24soltipdes,
    srvtxt         char (14),
    astcod         char(04),                             #PSI180475 - robson
    astdes         char (50),
    c24paxnum      like datmligacao.c24paxnum,
    msgenv         char (01),
    atdetpdes      like datketapa.atdetpdes,
    atdsrvnum      like datrligsrv.atdsrvnum,
    atdsrvano      like datrligsrv.atdsrvano,
    sinvstnum      like datrligsinvst.sinvstnum,
    sinvstano      like datrligsinvst.sinvstano,
    ramcod         like datrligsinvst.ramcod,
    sinavsnum      like datrligsinavs.sinavsnum,
    sinavsano      like datrligsinavs.sinavsano,
    sinnum         like datrligsin.sinnum,
    sinano         like datrligsin.sinano,
    vstagnnum      like datrligagn.vstagnnum,
    trpavbnum      like datrligtrpavb.trpavbnum
 end record

 define ws         record
    atdsrvnum_rcl  like datmservico.atdsrvnum,
    atdsrvano_rcl  like datmservico.atdsrvano,
    atdsrvorg_rcl  like datmservico.atdsrvorg,
    funmat         like datmligacao.c24funmat,
    atdetpcod      like datketapa.atdetpcod  ,
    c24rclsitcod   like datmsitrecl.c24rclsitcod,
    cartao         char (16)                 ,
    cabec          char (60)                 ,
    c24astexbflg   like datkassunto.c24astexbflg,
    telmaiatlflg   like datkassunto.telmaiatlflg,
    ligsinpndflg   like datrligsin.ligsinpndflg ,
    atdsrvorg      like datmservico.atdsrvorg,
    atdprscod      like datmservico.atdprscod,
    pnd            char(01)                  ,
    vstagnnum      like datrligagn.vstagnnum ,
    vstagnstt      like datrligagn.vstagnstt ,
    etp            char (05),
    contador       dec (05,0),
    refatdsrvnum   like datmsrvjit.refatdsrvnum ,
    refatdsrvano   like datmsrvjit.refatdsrvano ,
    lignumjre      like datmligacao.lignum      ,
    c24astcodjre   like datmligacao.c24astcod   ,
    flag_acesso    smallint
 end record

 define w_c24soltipcod      like datksoltip.c24soltipcod

 define arr_aux             smallint
 define sql_comando         char(900)
 define aux_char            char(04)
 define aux_ano2            dec(2,0)
 define aux_ano4            char(04)
 define aux_lixo            char(01)

 define l_resultado  smallint,
        l_azlaplcod  integer,
        l_doc_handle integer,
        l_mensagem   char(50)

 define l_funnom            char(020),
        l_cornom            char(040),
        l_corsussol         char(06)

 define l_c24astcod  like datmligacao.c24astcod

 define l_param1         char(10),
        l_cnslignum      like datrligcnslig.cnslignum,
        l_drscrsagdcod   like datrdrscrsagdlig.drscrsagdcod,
        l_crtsaunum      like datrligsau.crtnum

 define  w_pf1   integer

 define lr_cts20g14 record
    resultado        smallint,
    mensagem         char(60),
    assunto          like datrligrcuccsmtv.c24astcod
 end record
                                                       # Marcio Meta PSI187550
        let     w_c24soltipcod  =  null
        let     arr_aux  =  null
        let     sql_comando  =  null

        for     w_pf1  =  1  to  3
                initialize  a_cta02m00[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

 let int_flag = false

 initialize a_cta02m00    to null
 initialize ws.*          to null
 initialize lr_cts20g14.* to null                      # Marcio Meta PSI187550

 let ws.flag_acesso = cta00m06(g_issk.dptsgl)

#--- inicio bloco 1 alterado p/ Fabio psi159638/osf8540

 IF g_documento.apoio = "S" AND
    g_documento.aplnumdig IS NULL AND
    g_documento.prpnumdig IS NULL AND
    g_documento.fcapacnum IS NULL THEN

    select funnom into g_documento.solnom
          from isskfunc
         where empcod = g_documento.empcodatd
           and funmat = g_documento.funmatatd

    LET ws.cabec = "ATENDENTE.: ",g_documento.funmatatd," ",g_documento.solnom

    LET sql_comando = 'select lignum from datmligatd',
                      ' where apoemp = ?',
                      '   and apomat = ?',
                      'order by lignum desc '

    DISPLAY  g_documento.solnom TO solnom

 else

#--- fim bloco 1 alterado
    if g_documento.ramcod     is not null  and
       g_documento.succod     is not null  and
       g_documento.aplnumdig  is not null  then
       if g_documento.ciaempcod = 35 then
          -------[ para apol Azul nao separa o digito ]----------
          let ws.cabec = "Suc: ", g_documento.succod    using "<<<&&",  #"&&",  #projeto succod
                         "  Ramo: ", g_documento.ramcod    using "&&&&",
                         "  Apl.: ", g_documento.aplnumdig using "<<<<<<<<#"
       else
          if g_pss.psscntcod is not null  then # PSS
             let ws.cabec = "Contrato: ", g_pss.psscntcod using "&&&&&&&&&&"
          else
             let ws.cabec = "Suc: ", g_documento.succod    using "<<<&&",  #"&&",  #projeto succod
                            "  Ramo: ", g_documento.ramcod    using "&&&&",
                            "  Apl.: ", g_documento.aplnumdig using "<<<<<<<# #"
          end if
       end if
       if g_documento.itmnumdig is not null  and
          g_documento.itmnumdig <>  0        then
          if g_documento.ciaempcod = 35 then
             let ws.cabec = ws.cabec clipped,
                            "  Item: ", g_documento.itmnumdig using "<<<<<<#"
          else
             let ws.cabec = ws.cabec clipped,
                            "  Item: ", g_documento.itmnumdig using "<<<<<# #"
          end if
       end if

       let ws.cabec = ws.cabec clipped,
                      " End: ", g_documento.edsnumref using "<<<<<<<<&"

       let sql_comando = "select lignum              ",
                         "  from datrligapol         ",
                         " where succod     =  ?  and",
                         "       ramcod     =  ?  and",
                         "       aplnumdig  =  ?  and",
                         "       itmnumdig  =  ?  and",
                         "       edsnumref >=  0     ",
                         " order by lignum desc      "
       ## PSI PSS
       let sql_comando = "select lignum              ",
                         "  from datrcntlig          ",
                         " where psscntcod = ?       ",
                         " order by lignum desc      "
    else
       if g_documento.prporg    is not null  and
          g_documento.prpnumdig is not null  then
          LET ws.cabec = "Proposta: ", g_documento.prporg    using "&&", " ",
                                       g_documento.prpnumdig using "<<<<<<<<&"

          let sql_comando = "select lignum            ",
                            "  from datrligprp        ",
                            " where prporg    = ?  and",
                            "       prpnumdig = ?     ",
                            " order by lignum desc    "
       else
          if g_documento.fcapacorg is not null  and
             g_documento.fcapacnum is not null  then
             let ws.cabec = "No.PAC: ", g_documento.fcapacorg using "&&",
                                   " ", g_documento.fcapacnum using "<<<<<<<<&"

             let sql_comando = "select lignum            ",
                               "  from datrligpac        ",
                               " where fcapacorg = ?  and",
                               "       fcapacnum = ?     ",
                               " order by lignum desc    "
          else
             if g_ppt.cmnnumdig is not null then
                let ws.cabec = "Contrato: ", g_ppt.cmnnumdig

                let sql_comando = " select lignum ",
                                  "  from datrligppt ",
                                  " where cmnnumdig = ? ",
                                  " order by lignum desc "
             else
                #Marcelo - psi172413 - inicio

                if g_documento.corsus is not null then

                   open c_cta02m00_001 using g_documento.corsus
                   whenever error continue
                   fetch c_cta02m00_001 into l_cornom
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode = 100 then
                         let l_cornom = 'Corretor nao cadastrado na porto'
                      else
                         error 'Problemas de acesso a tabela gcakcorr, ',
                               sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                         error 'Funcao cta02m00_lig(): chave ',g_documento.corsus
                         sleep 2
                         let m_erro = 1
                         return
                      end if
                   end if

                   let ws.cabec = 'SUSEP.: ',g_documento.corsus,' ',l_cornom

                   let sql_comando = 'select lignum     ',
                                     '  from datrligcor ',
                                     ' where corsus = ? ',
                                     ' order by lignum desc '
                else
                   if g_documento.cgccpfnum is not null then
                      let ws.cabec = 'CGC/CPF.: ',g_documento.cgccpfnum,
                                              ' ',g_documento.cgcord,
                                              ' ',g_documento.cgccpfdig

                      let sql_comando = 'select a.lignum        ',
                                        '  from datrligcgccpf a,',
                                        '       datmligacao b   ',
                                        ' where a.lignum = b.lignum ',
                                        '   and a.cgccpfnum = ? ',
                                        '   and a.cgcord    = ? ',
                                        '   and a.cgccpfdig = ? ',
                                        '   and b.ciaempcod = ', g_documento.ciaempcod ,
                                        ' order by a.lignum desc '
                   else
                      if g_documento.funmat is not null then
                         open c_cta02m00_002 using g_documento.funmat, g_documento.empcodmat
                         whenever error continue
                         fetch c_cta02m00_002 into l_funnom
                         whenever error stop
                         if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode = 100 then
                               let l_funnom = 'Func. nao cadastrado'
                            else
                               error 'Problemas de acesso a tabela isskfunc, ',
                                     sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                               error 'Funcao cta02m00_lig(): chave ',g_documento.funmat
                               sleep 2
                               let m_erro = 1
                               return
                            end if
                         end if
                         let ws.cabec = 'FUNCION.: ',g_documento.funmat,' ',l_funnom

                         let sql_comando = ' select lignum     ',
                                           '   from datrligmat ',
                                           '  where funmat = ? ',
                                           '  order by lignum desc '
                      else
                         if g_documento.ctttel is not null then
                            let ws.cabec = 'TELEFONE.: ',g_documento.dddcod,
                                                     ' ',g_documento.ctttel

                            let sql_comando = ' select lignum     ',
                                              '   from datrligtel ',
                                              '  where teltxt = ? ',
                                              '  order by lignum desc '
                         else
                            return
                         end if
                      end if
                   end if
                end if
                #Marcelo - psi172413 - fim
             end if
          end if
       end if
    end if
 END IF
#---------------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------------

 prepare p_cta02m00_025 from sql_comando
 declare c_cta02m00_022 cursor for p_cta02m00_025

 let sql_comando = "select c24soltipdes ",
                     "from datksoltip "  ,
                          "where c24soltipcod = ?"
 prepare p_cta02m00_026 from   sql_comando
 declare c_cta02m00_023 cursor for p_cta02m00_026

 let sql_comando = " select funnom from isskfunc",
                    " where funmat = ? ",
                      " and empcod = ? ",
                      " and usrtip = ? "

 prepare p_cta02m00_027 from sql_comando
 declare c_cta02m00_024 cursor for p_cta02m00_027

 let sql_comando = "select mstnum     ",
                   "  from datrligmens",
                   " where lignum = ? "
 prepare p_cta02m00_028 from sql_comando
 declare c_cta02m00_025 cursor for p_cta02m00_028

 let sql_comando = "select max(c24rclsitcod)",
                   "  from datmsitrecl      ",
                   " where lignum = ?       "
 prepare p_cta02m00_029 from sql_comando
 declare c_cta02m00_026 cursor for p_cta02m00_029

 let sql_comando = "select atdsrvnum, atdsrvano ",
                   "  from datmreclam      ",
                   " where lignum = ?       "
 prepare p_cta02m00_030 from sql_comando
 declare c_cta02m00_027 cursor for p_cta02m00_030

 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24rclsitcod'",
                   "   and cpocod = ? "
 prepare p_cta02m00_031 from sql_comando
 declare c_cta02m00_028 cursor for p_cta02m00_031

 let sql_comando = "select atdetpcod     ",
                   "  from datmsrvacp    ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare p_cta02m00_032 from sql_comando
 declare c_cta02m00_029 cursor for p_cta02m00_032

 let sql_comando = "select atdetpdes    ",
                   "  from datketapa    ",
                   " where atdetpcod = ?"
 prepare p_cta02m00_033 from sql_comando
 declare c_cta02m00_030 cursor for p_cta02m00_033

 let sql_comando = "select canmtvdes     ",
                   "  from datmvstsincanc",
                   " where sinvstnum = ? ",
                   "   and sinvstano = ? "
 prepare p_cta02m00_034 from sql_comando
 declare c_cta02m00_031 cursor for p_cta02m00_034

 let sql_comando = "select datmligacao.ligdat   ,",
                   "       datmligacao.lighorinc,",
                   "       datmligacao.c24funmat,",
                   "       datmligacao.c24solnom,",
                   "       datmligacao.c24soltipcod,",
                   "       datmligacao.c24astcod,",
                   "       datmligacao.c24paxnum ",
                   "  from datmligacao           ",
                   " where datmligacao.lignum = ?"
 prepare p_cta02m00_035 from sql_comando
 declare c_cta02m00_032 cursor for p_cta02m00_035

 let sql_comando = "select atdsrvorg,atdprscod "          ,
                     "from DATMSERVICO "        ,
                          "where atdsrvnum = ? ",
                            "and atdsrvano = ? "
 prepare p_cta02m00_036 from sql_comando
 declare c_cta02m00_033 cursor for p_cta02m00_036

 let sql_comando = "select vstagnnum,vstagnstt " ,
                   " from DATRLIGAGN " ,
                   " where lignum    = ? "
 prepare p_cta02m00_037 from sql_comando
 declare c_cta02m00_034 cursor for p_cta02m00_037

 let sql_comando = "select drscrsagdcod,agdligrelstt " ,
                   " from datrdrscrsagdlig " ,
                   " where lignum    = ? "
 prepare p_cta02m00_038 from sql_comando
 declare c_cta02m00_035 cursor for p_cta02m00_038

 let sql_comando = "select atdsrvnum ",
                   "  from datmsrvjit ",
                   " where refatdsrvnum = ? ",
                   "   and refatdsrvano = ? "
 prepare p_cta02m00_039 from sql_comando
 declare c_cta02m00_036 cursor for p_cta02m00_039

 let sql_comando = "select refatdsrvnum, refatdsrvano ",
                   "  from datmsrvjit ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
 prepare p_cta02m00_040 from sql_comando
 declare c_cta02m00_037 cursor for p_cta02m00_040

 let sql_comando = "select sinvstnum ",
                   "  from datmpedvist ",
                   " where sinvstnum = ? ",
                   "   and sinvstano = ? "
 prepare p_cta02m00_041 from sql_comando
 declare c_cta02m00_038 cursor for p_cta02m00_041

 let sql_comando = "select lignum ",
                   "  from datrligsinvst ",
                   " where sinvstnum = ? ",
                   "   and sinvstano = ? "
 prepare p_cta02m00_042 from sql_comando
 declare c_cta02m00_039 cursor for p_cta02m00_042

 if g_documento.pcacarnum is not null   then
    let ws.cartao = g_documento.pcacarnum
    let ws.cabec = "Cartao: ", ws.cartao clipped
    display ws.cabec  to  cabec
 else
    display ws.cabec  to  cabec

    let arr_aux = 1
#--- inicio bloco 2 alterado p/ Fabio psi159638/osf8540
    IF g_documento.apoio = "S" AND
       g_documento.aplnumdig IS NULL AND
       g_documento.prpnumdig IS NULL AND
       g_documento.fcapacnum IS NULL THEN

       open c_cta02m00_022 using g_documento.empcodatd,
                             g_documento.funmatatd

    ELSE
#--- fim bloco 2 alterado
       if g_documento.succod    is not null  and
          g_documento.ramcod    is not null  and
          g_documento.aplnumdig is not null  then
          open c_cta02m00_022 using g_documento.succod   ,
                                g_documento.ramcod   ,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig
       else
          if g_documento.prporg    is not null  and
             g_documento.prpnumdig is not null  then
             open c_cta02m00_022 using g_documento.prporg,
                                   g_documento.prpnumdig
          else
             if g_documento.fcapacorg is not null  and
                g_documento.fcapacnum is not null  then
                open c_cta02m00_022 using g_documento.fcapacorg,
                                      g_documento.fcapacnum
             else
                if g_ppt.cmnnumdig is not null then
                   open c_cta02m00_022 using g_ppt.cmnnumdig
                #Marcelo - psi172413 - inico
                else
                   if g_documento.corsus is not null then
                      open c_cta02m00_022 using g_documento.corsus
                   else
                      if g_documento.cgccpfnum is not null then
                         open c_cta02m00_022 using g_documento.cgccpfnum,
                                               g_documento.cgcord,
                                               g_documento.cgccpfdig
                      else
                         if g_documento.funmat is not null then
                            open c_cta02m00_022 using g_documento.funmat
                         else
                            if g_documento.ctttel is not null then
                               open c_cta02m00_022 using g_documento.ctttel
                            end if
                         end if
                      end if
                   end if
                end if
                #Marcelo - psi172413 - fim
             end if
          end if
       end if
    END IF

    foreach  c_cta02m00_022    into  a_cta02m00[arr_aux].lignum
       open  c_cta02m00_032 using a_cta02m00[arr_aux].lignum
       fetch c_cta02m00_032 into  a_cta02m00[arr_aux].ligdat,
                                 a_cta02m00[arr_aux].lighorinc,
                                 ws.funmat,
                                 a_cta02m00[arr_aux].c24solnom,
                                 w_c24soltipcod,
                                 a_cta02m00[arr_aux].astcod,
                                 a_cta02m00[arr_aux].c24paxnum
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if


       close c_cta02m00_032

       #inicio psi172057 ivone (2)
       if  w_c24soltipcod = 2  or
           w_c24soltipcod = 8  then
           open c_cta02m00_003  using a_cta02m00[arr_aux].lignum
           whenever error continue
           fetch c_cta02m00_003 into l_corsussol
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> 100 then
                 error 'Erro no SELECT  datrligcor ',
                          sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                 error 'Funcao cta02m000()/ccta02m000013'  sleep 2
                 let m_erro = true
                 exit foreach
              end if
           else
               open c_cta02m00_001 using l_corsussol
               whenever error continue
               fetch c_cta02m00_001 into l_cornom
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode <> 100 then
                     error 'Erro no Select gcakcorr, ',sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                     error 'Funcao cta02m00_lig()/ccta02m000001, /',l_corsussol sleep 2
                     let m_erro = 1
                     exit foreach
                  end if
               else
                  let a_cta02m00[arr_aux].srvtxt = l_corsussol
                  let a_cta02m00[arr_aux].atdetpdes =  l_cornom
               end if
           end if
       end if
       #fim psi172057 ivone (2)

      #-----------------------------------------------------------------
      # Carrega tipo de solicitante
      #-----------------------------------------------------------------
       IF g_documento.apoio = "S"  then
          let a_cta02m00[arr_aux].c24soltipdes = "Apoio"
       else
          open  c_cta02m00_023  using w_c24soltipcod
          fetch c_cta02m00_023  into  a_cta02m00[arr_aux].c24soltipdes
          close c_cta02m00_023
       end if

# PSI 172111 - Inicio

       let ws.atdsrvorg   = 0
       let l_cnslignum    = null
       let l_drscrsagdcod = null

       call cts20g00_ligacao(a_cta02m00[arr_aux].lignum)
            returning a_cta02m00[arr_aux].atdsrvnum,
                      a_cta02m00[arr_aux].atdsrvano,
                      a_cta02m00[arr_aux].sinvstnum,
                      a_cta02m00[arr_aux].sinvstano,
                      a_cta02m00[arr_aux].ramcod,
                      a_cta02m00[arr_aux].sinavsnum,
                      a_cta02m00[arr_aux].sinavsano,
                      a_cta02m00[arr_aux].sinnum,
                      a_cta02m00[arr_aux].sinano,
                      a_cta02m00[arr_aux].vstagnnum,
                      a_cta02m00[arr_aux].trpavbnum,
                      l_cnslignum,
                      l_crtsaunum,
                      l_drscrsagdcod


# PSI 172111 - Final

      #-----------------------------------------------------------------
      # Verifica se codigo de assunto tem restricao de exibicao
      #-----------------------------------------------------------------
       if g_issk.acsnivcod  <  8     and
          g_documento.apoio is null  then
          initialize ws.c24astexbflg  to null
          initialize ws.telmaiatlflg  to null

          open  c_cta02m00_005  using a_cta02m00[arr_aux].astcod
          fetch c_cta02m00_005  into  ws.c24astexbflg, ws.telmaiatlflg
          close c_cta02m00_005

          if ws.c24astexbflg  =  "N"  and   # mostra a ligacoes com "CON".
             g_documento.flgtransp is null and
             l_cnslignum is null      then    ## PSI 172111
             continue foreach
          end if
       end if
      #------------------------------------------------------------------
      # Exibe situacao da reclamacao
      #------------------------------------------------------------------
       if a_cta02m00[arr_aux].astcod[1,1] = "W"   or
          a_cta02m00[arr_aux].astcod[1,1] = "X"   or
          a_cta02m00[arr_aux].astcod      = "SUG" or
          a_cta02m00[arr_aux].astcod      = "Z00" or
          a_cta02m00[arr_aux].astcod      = "K00" or      #PSI 205206
          a_cta02m00[arr_aux].astcod      = "K99" or      #PSI 205206
          a_cta02m00[arr_aux].astcod      = "KSU" or      #PSI 205206
          a_cta02m00[arr_aux].astcod      = "K96" or  # assunto manipulados
          a_cta02m00[arr_aux].astcod      = "K97" or  # pelo SAC.(96/97/98)
          a_cta02m00[arr_aux].astcod      = "K98" or
          a_cta02m00[arr_aux].astcod      = "423" or --> PSI 230650
          a_cta02m00[arr_aux].astcod      = "107" or --> PSS
          a_cta02m00[arr_aux].astcod      = "518" or --> PortoSeg
          a_cta02m00[arr_aux].astcod      = "I99" or --> Itau
          a_cta02m00[arr_aux].astcod      = "I98" or --> Itau
          a_cta02m00[arr_aux].astcod      = "ISU" or --> Itau
          a_cta02m00[arr_aux].astcod      = "R99" or --> Itau
          a_cta02m00[arr_aux].astcod      = "R98" or --> Itau
          a_cta02m00[arr_aux].astcod      = "I91" or
          a_cta02m00[arr_aux].astcod      = "I92" or
          a_cta02m00[arr_aux].astcod      = "I93" or
          a_cta02m00[arr_aux].astcod      = "I94" or
          a_cta02m00[arr_aux].astcod      = "I95" or
          a_cta02m00[arr_aux].astcod      = "I96" or
          a_cta02m00[arr_aux].astcod      = "I97" or
          a_cta02m00[arr_aux].astcod      = "P24" or
          a_cta02m00[arr_aux].astcod      = "P25" or
          a_cta02m00[arr_aux].astcod      = "PSU" or
          a_cta02m00[arr_aux].astcod      = "O00" then # cartao credito

          open  c_cta02m00_026  using a_cta02m00[arr_aux].lignum
          fetch c_cta02m00_026  into  ws.c24rclsitcod
          if sqlca.sqlcode = 0  then
             let a_cta02m00[arr_aux].atdetpdes = ""

             open  c_cta02m00_028  using ws.c24rclsitcod
             fetch c_cta02m00_028  into  a_cta02m00[arr_aux].atdetpdes
             close c_cta02m00_028
          end if
          close c_cta02m00_026

          open  c_cta02m00_027  using a_cta02m00[arr_aux].lignum
          fetch c_cta02m00_027  into  ws.atdsrvnum_rcl, ws.atdsrvano_rcl
          if ws.atdsrvnum_rcl is not null then
             open  c_cta02m00_033 using ws.atdsrvnum_rcl,
                                       ws.atdsrvano_rcl
             fetch c_cta02m00_033 into  ws.atdsrvorg_rcl,ws.atdprscod
             close c_cta02m00_033
             let a_cta02m00[arr_aux].srvtxt =
                            ws.atdsrvorg_rcl  using "&&", "/",
                            ws.atdsrvnum_rcl  using "&&&&&&&", "-",
                            ws.atdsrvano_rcl  using "&&"
          end if
          close c_cta02m00_027

       end if

      #------------------------------------------------------------------
      # Exibe servico relacionado `a ligacao
      #------------------------------------------------------------------
       let ws.atdsrvorg = 0

       # inicio --- PSI 172111 - Ivone

       if l_cnslignum is not null then
          open  c_cta02m00_004    using l_cnslignum
          whenever error continue
          fetch c_cta02m00_004    into l_c24astcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> notfound then
                error 'Erro SELECT datmligacao ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 3
                error 'cta02m00()/',l_cnslignum  sleep 3
                let m_erro = 1
                exit foreach
             else
                let l_c24astcod = null
             end if
          end if

         let l_param1 = l_cnslignum
         let a_cta02m00[arr_aux].srvtxt = l_param1 clipped, "-", l_c24astcod clipped

       end if

    # fim --- PSI 172111 - Ivone

       if a_cta02m00[arr_aux].atdsrvnum is not null  and
          a_cta02m00[arr_aux].atdsrvano is not null  then
          open  c_cta02m00_033 using a_cta02m00[arr_aux].atdsrvnum,
                                    a_cta02m00[arr_aux].atdsrvano
          fetch c_cta02m00_033 into  ws.atdsrvorg,ws.atdprscod

          let a_cta02m00[arr_aux].srvtxt =
                            ws.atdsrvorg  using "&&", "/",
                            a_cta02m00[arr_aux].atdsrvnum  using "&&&&&&&", "-",
                            a_cta02m00[arr_aux].atdsrvano  using "&&"

          open  c_cta02m00_029  using a_cta02m00[arr_aux].atdsrvnum,
                                    a_cta02m00[arr_aux].atdsrvano,
                                    a_cta02m00[arr_aux].atdsrvnum,
                                    a_cta02m00[arr_aux].atdsrvano
          fetch c_cta02m00_029  into  ws.atdetpcod

          if sqlca.sqlcode = 0  then
             open  c_cta02m00_030 using ws.atdetpcod
             fetch c_cta02m00_030 into  a_cta02m00[arr_aux].atdetpdes
             close c_cta02m00_030
          end if
          close c_cta02m00_029

          if ws.atdsrvorg  =  14 then    # ruiz vidros
             initialize ws.etp to null
             if ws.atdetpcod = 4 then
                let ws.etp   = "Acion"
             else
               if ws.atdetpcod = 5 then
                  let ws.etp = "Canc "
               end if
             end if
             if ws.atdprscod = 1 then   # carglass
                let a_cta02m00[arr_aux].atdetpdes = "Cargl/",ws.etp
             else
                if ws.atdprscod = 2  then  # abravauto
                   let a_cta02m00[arr_aux].atdetpdes = "Abrav/",ws.etp
                end if
             end if
          end if
       end if

       #------------------------------------------------------------------
       # Verifica se JIT de RE e altera assunto para JRE
       #------------------------------------------------------------------
       if a_cta02m00[arr_aux].astcod = "JIT" then
          open c_cta02m00_037 using a_cta02m00[arr_aux].atdsrvnum,
                                     a_cta02m00[arr_aux].atdsrvano
          fetch c_cta02m00_037 into ws.refatdsrvnum, ws.refatdsrvano
          let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"

          if sqlca.sqlcode <> notfound then
             open c_cta02m00_038 using ws.refatdsrvnum, aux_ano4
             fetch c_cta02m00_038

             if sqlca.sqlcode <> notfound then
                open c_cta02m00_039 using ws.refatdsrvnum, aux_ano4
                fetch c_cta02m00_039 into ws.lignumjre
                if sqlca.sqlcode <> notfound then
                   open c_cta02m00_032 using ws.lignumjre
                   fetch c_cta02m00_032 into aux_lixo, aux_lixo, aux_lixo,
                                            aux_lixo, aux_lixo, ws.c24astcodjre
                   if ws.c24astcodjre = "V12" then
                      let a_cta02m00[arr_aux].astcod = "JRE"
                   end if
                end if
             end if
          end if
       end if
       if a_cta02m00[arr_aux].sinvstnum is not null  and
          a_cta02m00[arr_aux].sinvstano is not null  and
          ws.atdsrvorg                  <> 14        then
         #------------------------------------------------------------------
         # Verifica se JIT-RE e despreza
         #------------------------------------------------------------------
          if a_cta02m00[arr_aux].astcod = "V12" then
            let aux_char = a_cta02m00[arr_aux].sinvstano
            let aux_ano2 = aux_char[3,4]
            open c_cta02m00_036 using a_cta02m00[arr_aux].sinvstnum, aux_ano2
            fetch c_cta02m00_036

            if sqlca.sqlcode <> notfound then
               initialize  a_cta02m00[arr_aux].* to null
               continue foreach
            end if
          end if

          let a_cta02m00[arr_aux].srvtxt =
                        a_cta02m00[arr_aux].sinvstnum  using "&&&&&&", "-",
                        a_cta02m00[arr_aux].sinvstano

          open  c_cta02m00_031 using a_cta02m00[arr_aux].sinvstnum,
                                       a_cta02m00[arr_aux].sinvstano
          fetch c_cta02m00_031

          if sqlca.sqlcode = 0  then
             let a_cta02m00[arr_aux].atdetpdes = "CANCELADA"
          end if

          close c_cta02m00_031
       end if

       if a_cta02m00[arr_aux].sinavsnum is not null  and
          a_cta02m00[arr_aux].sinavsano is not null  then
          let a_cta02m00[arr_aux].srvtxt =
                        a_cta02m00[arr_aux].sinavsnum  using "&&&&&&", "-",
                        a_cta02m00[arr_aux].sinavsano
       end if

       if a_cta02m00[arr_aux].sinnum is not null  and
          a_cta02m00[arr_aux].sinano is not null  then
          select ligsinpndflg
            into ws.ligsinpndflg
            from DATRLIGSIN
                 where lignum = a_cta02m00[arr_aux].lignum

          if  sqlca.sqlcode = 0  then
              if  ws.ligsinpndflg = "S"  then
                  let ws.pnd = "P"
              else
                  let ws.pnd = " "
              end if
          else
              let ws.pnd = " "
          end if
          let a_cta02m00[arr_aux].srvtxt =
                  a_cta02m00[arr_aux].sinnum  using "&&&&&&", "-",
                  a_cta02m00[arr_aux].sinano, ws.pnd
       end if
       if a_cta02m00[arr_aux].vstagnnum is not null then
          open c_cta02m00_034 using a_cta02m00[arr_aux].lignum
          foreach c_cta02m00_034 into ws.vstagnnum,
                                    ws.vstagnstt
          end foreach
          let a_cta02m00[arr_aux].srvtxt = ws.vstagnnum using "&&&&&&&"
         #verifica se o agendamento e do sistema novo(web)
          select agncod
             from avgmagn
            where agncod = ws.vstagnnum
          if sqlca.sqlcode = 0 then
             case ws.vstagnstt
                when("A")
                   let a_cta02m00[arr_aux].atdetpdes = "AGEN/CANC"
                when("C")
                   let a_cta02m00[arr_aux].atdetpdes = "CANCELADO"
                when("I")
                   let a_cta02m00[arr_aux].atdetpdes = "AGENDADO"
                otherwise
                   let a_cta02m00[arr_aux].atdetpdes = "INVALIDO"
             end case
          else
             if ws.vstagnstt = "C"   then
                let a_cta02m00[arr_aux].atdetpdes = "CANCELADA"
             else
                let a_cta02m00[arr_aux].atdetpdes = "AGENDADO"
             end if
          end if
       end if


       ---> Mostra Nro./Status Agendamento Curso de Direcao Defensiva
       if l_drscrsagdcod is not null then

          open c_cta02m00_035 using a_cta02m00[arr_aux].lignum
          foreach c_cta02m00_035 into ws.vstagnnum,
                                          ws.vstagnstt

          end foreach


          let a_cta02m00[arr_aux].srvtxt = ws.vstagnnum using "&&&&&&&"

          if ws.vstagnstt = "C"   then
             let a_cta02m00[arr_aux].atdetpdes = "CANCELADO"
          else
             let a_cta02m00[arr_aux].atdetpdes = "AGENDADO"
          end if
       end if

       if a_cta02m00[arr_aux].trpavbnum is not null then
          let a_cta02m00[arr_aux].srvtxt =
                       a_cta02m00[arr_aux].trpavbnum using "&&&&&&"
          let a_cta02m00[arr_aux].atdetpdes = "AVERBACAO"
       end if

      #------------------------------------------------------------------
      # Verifica se houve envio de mensagem para corretor
      #------------------------------------------------------------------
       open  c_cta02m00_025  using a_cta02m00[arr_aux].lignum
       fetch c_cta02m00_025
       if sqlca.sqlcode = 0  then
          let a_cta02m00[arr_aux].msgenv = "S"
       else
          initialize a_cta02m00[arr_aux].msgenv to null
       end if
       close c_cta02m00_025

      #------------------------------------------------------------------
      # Nome do atendente
      #------------------------------------------------------------------
       if ws.funmat = 999999 then
          let a_cta02m00[arr_aux].funnom = "PORTAL"
       else
          let a_cta02m00[arr_aux].funnom = "NAO CADASTR."
          let m_c24usrtip = null
          let m_c24empcod = null

          open c_cta02m00_019 using a_cta02m00[arr_aux].lignum
          fetch c_cta02m00_019 into m_c24usrtip, m_c24empcod
          close c_cta02m00_019

          open  c_cta02m00_024 using ws.funmat,
                                 m_c24empcod,
                                 m_c24usrtip

          fetch c_cta02m00_024  into a_cta02m00[arr_aux].funnom
          close c_cta02m00_024

       end if

       let a_cta02m00[arr_aux].funnom = upshift(a_cta02m00[arr_aux].funnom)

      #------------------------------------------------------------------
      # Monta descricao do assunto
      #------------------------------------------------------------------
       if a_cta02m00[arr_aux].astcod = "JRE" then
          let a_cta02m00[arr_aux].astcod = "JIT"
          call c24geral8(a_cta02m00[arr_aux].astcod)
               returning a_cta02m00[arr_aux].astdes
          let a_cta02m00[arr_aux].astcod = "JRE"
       else
          call c24geral8(a_cta02m00[arr_aux].astcod)
               returning a_cta02m00[arr_aux].astdes
       end if

       #inicio psi172057 ivone (2)
       if  w_c24soltipcod = 2  or
           w_c24soltipcod = 8  then
           open c_cta02m00_003  using a_cta02m00[arr_aux].lignum
           whenever error continue
           fetch c_cta02m00_003 into l_corsussol
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> 100 then
                 error 'Erro no SELECT  datrligcor ',
                          sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                 error 'Funcao cta02m000()/ccta02m000013'  sleep 2
                 let m_erro = true
                 exit foreach
              end if
           else
               open c_cta02m00_001 using l_corsussol
               whenever error continue
               fetch c_cta02m00_001 into l_cornom
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode <> 100 then
                     error 'Erro no Select gcakcorr, ',sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                     error 'Funcao cta02m00_lig()/ccta02m000001, /',l_corsussol sleep 2
                     let m_erro = 1
                     exit foreach
                  end if
               else
                  let a_cta02m00[arr_aux].srvtxt = l_corsussol
                  let a_cta02m00[arr_aux].atdetpdes =  l_cornom
               end if
           end if
       end if

       # OBTER O MOTIVO DA CONCESSAO
       call cts20g14_motivo_con(a_cta02m00[arr_aux].lignum)
                returning lr_cts20g14.resultado,
                          lr_cts20g14.mensagem,
                          l_rcuccsmtvcod,
                          lr_cts20g14.assunto
                                                      # Marcio Meta PSI187550
       if l_rcuccsmtvcod is not null and l_rcuccsmtvcod <> 0 then
          let l_astcod = '*', a_cta02m00[arr_aux].astcod clipped
          let a_cta02m00[arr_aux].astcod = l_astcod
       end if                                         #PSI180475 - robson - fim

       let arr_aux = arr_aux + 1

       if arr_aux > 3   then
          exit foreach
       end if
    end foreach

    #inicio - psi172057  ivone(2)
    if m_erro = true then
       let int_flag = false
       return
    end if
    #fim - psi172057  ivone(2)

     if arr_aux > 1  then
      for arr_aux = 1 to 3
          display a_cta02m00[arr_aux].*  to  s_cta02m00[arr_aux].*
      end for
      let ws.contador  =  0  # verifica se existe ligacao de RE(S60,S63)
        if g_ppt.cmnnumdig is null then #-- Henrique/Mariana
         select count(*)
           into ws.contador
           from datrligapol a, datmligacao b
          where a.succod    =  g_documento.succod
            and a.ramcod    =  g_documento.ramcod
            and a.aplnumdig =  g_documento.aplnumdig
            and a.itmnumdig =  g_documento.itmnumdig
            and a.edsnumref >= 0
            and a.lignum    =  b.lignum
            and b.c24astcod in ("S60","S63")
        else
           select count(*)
             into ws.contador
             from datrligppt a, datmligacao b
            where a.cmnnumdig =  g_ppt.cmnnumdig
              and a.lignum    =  b.lignum
              and b.c24astcod in ("S60","S63")
        end if
        if ws.contador > 0 then
           let wg_psre = 1
        end if
     end if
   end if

 let int_flag = false

end function  ###  cta02m00_lig

#--------------------------------------------------------------------------
 function cta02m00_grava(param)
#--------------------------------------------------------------------------

 define param  record
        c24atrflg       char(01),
        c24jstflg       char(01),
        funnom          like isskfunc.funnom
 end record
 define ws              record
        msgn            char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        ret             smallint,
        msg             char(80)                   ,
        dddcod          like datmreclam.dddcod     ,
        ctttel          like datmreclam.ctttel     ,
        faxnum          like datmreclam.faxnum     ,
        cttnom          like datmreclam.cttnom     ,
        c24evtcod_rcl   like datkevt.c24evtcod     ,
        atdsrvnum_rcl   like datmservico.atdsrvnum ,
        atdsrvano_rcl   like datmservico.atdsrvano ,
        atdsrvorg_rcl   like datmservico.atdsrvorg ,
        c24txtseq       like datmlighist.c24txtseq ,
        confirma        char (01),
        funnom          like isskfunc.funnom       ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        lintxt1         like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40)                  ,
        segnumdig       like gsakseg.segnumdig     ,
        segnom          like gsakseg.segnom        ,
        c24astdes       like datkassunto.c24astdes ,
        c24astcodslv    like datkassunto.c24astcod
 end record

 define l_data       date,
        l_aux        char(03),
        l_hora1      datetime hour to second,
        l_hora2      datetime hour to minute,
        l_telefone   char(150),
        l_etpctrnum  like rgemetpsgr.etpctrnum,
        l_aprlhdesc  like rgekaprlh.aprlhdesc,
        l_c24astagp  like datkassunto.c24astagp,       #psi230650
        l_flag       smallint,  # Psi Assuntos Azul
        l_cont       smallint

        initialize  ws.*  to  null
        let l_telefone  = null
        let l_etpctrnum  = null
        let l_aprlhdesc  = null
        let l_flag = false
        let l_cont = null

 while true

   initialize ws.*  to null

 #------------------------------------------------------------------------------
 # Confirma codigo de assunto informado antes de registrar ligacao sem laudo
 #------------------------------------------------------------------------------
   if g_rep_lig             = true then
      let ws.confirma = "S"
   else

      if g_documento.c24astcod <> "HDT" and
         g_documento.c24astcod <> "HDK" and
         g_documento.c24astcod <> "S68" and
         g_documento.c24astcod <> "RDT" and                  
         g_documento.c24astcod <> "RDK" and          
         g_documento.c24astcod <> "R68" then         
         
         call cts08g01("A","S","","CONFIRMA ASSUNTO INFORMADO ?","","")
              returning  ws.confirma
      else
         let ws.confirma = "S"
      end if
   end if

   if  ws.confirma = "S" then

       ---> Nao chama para o Assunto S68 porque ja chamou antes
       ---> devido ao Fluxo <> para o Help Desk
       if g_documento.c24astcod <> "S68" then

          call cta02m00_atz_just(param.c24atrflg
                                ,param.c24jstflg
                                ,param.funnom)
       end if

       #PSI 230650
       #Buscar agrupamento do assunto
       open c_cta02m00_021 using g_documento.c24astcod
       fetch c_cta02m00_021 into l_c24astagp
       close c_cta02m00_021

       #----------------------------------------------------------------------
       # Em caso de RECLAMACAO, registra dados para contato com reclamante
       #----------------------------------------------------------------------
         call cta00m06_assunto_reclamacao(g_documento.c24astcod,l_c24astagp)
         returning l_flag

         if l_flag  = true then
           initialize ws.faxnum to null

           if l_c24astagp           = "W"   or
              g_documento.c24astcod = "K00" or
              g_documento.c24astcod = "Z00" or
              g_documento.c24astcod = "107" or       ---> PSS
              g_documento.c24astcod = "518" or       ---> PortoSeg
              g_documento.c24astcod = "I99" or       #Itau
              g_documento.c24astcod = "I98" or       #Itau
              g_documento.c24astcod = "R98" or       #Itau
              g_documento.c24astcod = "R99" or       #Itau
              g_documento.c24astcod = "P24" or
              g_documento.c24astcod = "P25" or
              g_documento.c24astcod = "SW0" then     #PSI 205206

              if (g_documento.succod    is not null  and
                  g_documento.ramcod    is not null  and
                  g_documento.aplnumdig is not null  and
                  g_documento.itmnumdig is not null) or
                 (g_ppt.cmnnumdig is not null      ) or
                 (g_pss.psscntcod is not null      ) then

                 initialize ws.confirma     , ws.atdsrvnum_rcl,
                            ws.atdsrvano_rcl, ws.atdsrvorg_rcl,
                            ws.c24evtcod_rcl  to null
                 #-------------------------------------------------------
                 # Pesquisa se reclamacao esta relacionada a algum evento
                 #-------------------------------------------------------
                 select c24evtcod
                   into ws.c24evtcod_rcl
                   from datkevt
                  where c24astcod = g_documento.c24astcod
                 if sqlca.sqlcode = notfound then
                    initialize ws.c24evtcod_rcl  to null
                 end if

                 while true
                    if ws.c24evtcod_rcl is null       and
                       g_documento.c24astcod <> "W00" and
                       g_documento.c24astcod <> "K00" and    #PSI 205206
                       g_documento.c24astcod <> "SW0" and
                       g_documento.c24astcod <> "107" and    ---> PSS
                       g_documento.c24astcod <> "518" and    ---> PortoSeg
                       g_documento.c24astcod <> "I99" and    # Itau
                       g_documento.c24astcod <> "I98" and    # Itau
                       g_documento.c24astcod <> "R99" and    # Itau
                       g_documento.c24astcod <> "R98" and    # Itau
                       g_documento.c24astcod <> "P24" and
                       g_documento.c24astcod <> "P25" and
                       g_documento.c24astcod <> "Z00" then

                       exit while
                    end if

                    let ws.c24astcodslv  = g_documento.c24astcod
                    call cts22g00(g_documento.succod   ,
                                  g_documento.ramcod   ,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  "","",30,
                                  g_documento.bnfnum,
                                  "","","","cta02m00")
                        returning ws.atdsrvnum_rcl,
                                  ws.atdsrvano_rcl,
                                  ws.atdsrvorg_rcl

                    let m_atdsrvnum = ws.atdsrvnum_rcl
                    let m_atdsrvano = ws.atdsrvano_rcl
                    let g_documento.c24astcod = ws.c24astcodslv

                    if ws.atdsrvorg_rcl = 0  then # NAO HA NENHUM SRV
                       initialize ws.atdsrvorg_rcl to null
                       exit while                 # PARA RELACIONAMENTO
                    end if
                    if ws.atdsrvnum_rcl is null or
                       ws.atdsrvano_rcl is null then
                       if g_documento.c24astcod <> "W00" and
                          g_documento.c24astcod <> "Z00" and
                          g_documento.c24astcod <> "SW0" and
                          g_documento.c24astcod <> "I99" and     # Itau
                          g_documento.c24astcod <> "I98" and     # Itau
                          g_documento.c24astcod <> "R99" and     # Itau
                          g_documento.c24astcod <> "R98" and     # Itau
                          g_documento.c24astcod <> "107" and     ---> PSS
                          g_documento.c24astcod <> "518" and     ---> PortoSeg
                          g_documento.c24astcod <> "P24" and
                          g_documento.c24astcod <> "P25" and
                          g_documento.c24astcod <> "K00" then    #PSI 205206

                          call cts08g01("A","S",
                                "PARA ESTE TIPO DE RECLAMACAO E'",
                                "NECESSARIO INFORMAR O NRO.DO SERVICO.",
                                " ","PESQUISA NOVAMENTE?")
                              returning ws.confirma
                          if ws.confirma = "N" then
                             error " Operacao cancelada!"
                             return false,ws.lignum
                          end if
                       else
                          exit while
                       end if
                    else
                       exit while
                    end if
                 end while
              end if
           end if
           call cta02m08 (ws.dddcod thru ws.cttnom)
                returning ws.dddcod thru ws.cttnom

           if  ws.dddcod is null  or
               ws.ctttel is null  or
               ws.cttnom is null  then
               error " Operacao cancelada!"
               return false,ws.lignum
           end if
       end if
     #--------------------------------------------------------------------------
     # Busca numeracao ligacao
     #--------------------------------------------------------------------------
       begin work

       # PSI219967 Amilton Inicio
       if g_documento.c24astcod <> "U11" then
          initialize g_documento.sinramcod to null
          initialize g_documento.sinano    to null
          initialize g_documento.sinnum    to null
          initialize g_documento.sinitmseq to null
       end if
       # PSI219967 Amilton fim

       ---> Gera Nro Ligacao
       call cts10g03_numeracao( 1, "" ) # 1 - gera so ligacao
            returning ws.lignum   ,
                      ws.atdsrvnum,
                      ws.atdsrvano,
                      ws.codigosql,
                      ws.msg

       ---> Decreto - 6523
       let g_lignum_dcr = ws.lignum


       if  ws.codigosql = 0  then
           commit work
       else
           let ws.msg = "CTA02M00 - ",ws.msg
           call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
           rollback work
           prompt "" for char ws.msgn
           let ws.retorno = false
           exit while
       end if

       let g_documento.lignum = ws.lignum

     #--------------------------------------------------------------------------
     # Grava dados da ligacao
     #--------------------------------------------------------------------------
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let ws.hora  =  l_hora2

       begin work
       call cts10g00_ligacao ( g_documento.lignum      ,
                               l_data                  ,
                               ws.hora                 ,
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
                               g_documento.sinramcod   ,# PSI219967 Amilton Inicio
                               g_documento.sinano      ,
                               g_documento.sinnum      ,
                               g_documento.sinitmseq   ,# PSI219967 Amilton Fim
                               "","","",""             )
            returning ws.tabname,
                      ws.codigosql

       if  ws.codigosql <> 0  then
           error " Erro (", ws.codigosql, ") na gravacao da",
                 " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.msgn
           let ws.retorno = false
           exit while
       end if

     #--------------------------------------------------------------------------
     # Grava dados do reclamante para contato futuro
     #--------------------------------------------------------------------------
     call cta00m06_grava_tabela(g_documento.c24astcod,l_c24astagp)
     returning l_flag
       if l_flag = true then
           if ws.dddcod is not null and
              ws.cttnom is not null then
           call cts38g00_ins_datmreclam(ws.lignum,
                                        ws.dddcod,
                                        ws.ctttel,
                                        ws.faxnum,
                                        ws.cttnom,
                                        ws.atdsrvnum_rcl,
                                        ws.atdsrvano_rcl
                                        )
                returning ws.retorno
           if ws.retorno = false then
              error " Erro na gravacao do",
                    " reclamante. AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.msgn
              exit while
           end if

           call cts40g03_data_hora_banco(1)
                returning l_data, l_hora1
           insert into datmsitrecl ( lignum      ,
                                     c24rclsitcod,
                                     funmat      ,
                                     rclrlzdat   ,
                                     rclrlzhor    ,
                                     c24astcod    )
                            values ( ws.lignum    ,
                                     0            ,
                                     g_issk.funmat,
                                     l_data       ,
                                     l_hora1      ,
                                     g_documento.c24astcod)
           if  sqlca.sqlcode <> 0  then
               error " Erro (", sqlca.sqlcode, ") na gravacao da",
                     " pendencia da reclamacao. AVISE A INFORMATICA!"
               rollback work
               prompt "" for char ws.msgn
               let ws.retorno = false
               exit while
           end if
       end if
       end if
       commit work

       ---> Se Ligacao nao foi Transferida grava Motivo no Historico
       ---> Muda assunto de HDT p/ HDA
       if g_documento.c24astcod = "HDT" and
          flag_hdt_transf       = "NAO" then

          update datmligacao set c24astcod = "HDA"
           where lignum = ws.lignum

	        let l_telefone = null

          #-----------------------------------
          -->verifica se Ligacao ja tem Motivo
          #-----------------------------------
          open  ccta02m00025 using ws.lignum
                                  ,m_rcuccsmtvcod
                                  ,g_documento.c24astcod
          fetch ccta02m00025

          #------------------------
          --> Se nao achou registro
          #------------------------
          if sqlca.sqlcode = 100 then

             whenever error continue
             #--------------------------------
             -->Relaciona Motivo com a Ligacao
             #--------------------------------
             execute pcta02m00026 using ws.lignum
                                       ,m_rcuccsmtvcod
                                       ,g_documento.c24astcod

             whenever error stop
             if sqlca.sqlcode <> 0 then
                error " Erro (",sqlca.sqlcode,") na inclusao da ",
                      "tabela datrligrcuccsmtv (2). AVISE A INFORMATICA!"sleep 2
             end if
          end if


          for l_cont = 1 to 2

             if l_cont = 1 then
                let l_telefone = "MOTIVO PELO QUAL A LIGACAO NAO FOI TRANSFERIDA:"
             else
                let l_telefone = flag_hdt_hst
             end if

             call ctd06g01_ins_datmlighist(ws.lignum
                                          ,g_issk.funmat
                                          ,l_telefone
                                          ,l_data
                                          ,l_hora1
                                          ,g_issk.usrtip
                                          ,g_issk.empcod)
                                returning ws.ret, ws.msg

             if ws.ret <> 1 then
                error ws.msg
             end if
          end for
       end if
       
       ---> Se Ligacao nao foi Transferida grava Motivo no Historico
       ---> Muda assunto de RDT p/ RDA
       if g_documento.c24astcod = "RDT" and
          flag_hdt_transf       = "NAO" then

          update datmligacao set c24astcod = "RDA"
           where lignum = ws.lignum

	        let l_telefone = null

          #-----------------------------------
          -->verifica se Ligacao ja tem Motivo
          #-----------------------------------
          open  ccta02m00025 using ws.lignum
                                  ,m_rcuccsmtvcod
                                  ,g_documento.c24astcod
          fetch ccta02m00025

          #------------------------
          --> Se nao achou registro
          #------------------------
          if sqlca.sqlcode = 100 then

             whenever error continue
             #--------------------------------
             -->Relaciona Motivo com a Ligacao
             #--------------------------------
             execute pcta02m00026 using ws.lignum
                                       ,m_rcuccsmtvcod
                                       ,g_documento.c24astcod

             whenever error stop
             if sqlca.sqlcode <> 0 then
                error " Erro (",sqlca.sqlcode,") na inclusao da ",
                      "tabela datrligrcuccsmtv (2). AVISE A INFORMATICA!"sleep 2
             end if
          end if


          for l_cont = 1 to 2

             if l_cont = 1 then
                let l_telefone = "MOTIVO PELO QUAL A LIGACAO NAO FOI TRANSFERIDA:"
             else
                let l_telefone = flag_hdt_hst
             end if

             call ctd06g01_ins_datmlighist(ws.lignum
                                          ,g_issk.funmat
                                          ,l_telefone
                                          ,l_data
                                          ,l_hora1
                                          ,g_issk.usrtip
                                          ,g_issk.empcod)
                                returning ws.ret, ws.msg

             if ws.ret <> 1 then
                error ws.msg
             end if
          end for
       end if

       if g_documento.c24astcod = "S71" or        ##PSI 207420
          g_documento.c24astcod = "*CQ" then
          let l_telefone = " DDD: ", ws.dddcod clipped,
                           " TEL: ", ws.ctttel clipped,
                           " FAX: ", ws.faxnum clipped,
                           " CTT: ", ws.cttnom clipped

          call ctd06g01_ins_datmlighist(ws.lignum , g_issk.funmat,
                                        l_telefone, l_data,  l_hora1,
                                        g_issk.usrtip, g_issk.empcod)
               returning ws.ret, ws.msg

          if ws.ret <> 1 then
             error ws.msg
          end if
          if g_documento.c24astcod = "S71" then
             call framc400_retorna_desc_aparelho(g_documento.succod,
                                                 g_documento.ramcod,
                                                 g_documento.aplnumdig)
                  returning ws.ret, l_etpctrnum, l_aprlhdesc
             if l_aprlhdesc is not null then
                let l_aprlhdesc = " EQP: ", l_aprlhdesc clipped
                call ctd06g01_ins_datmlighist(ws.lignum , g_issk.funmat,
                                              l_aprlhdesc, l_data,  l_hora1,
                                              g_issk.usrtip, g_issk.empcod)
                     returning ws.ret, ws.msg
                if ws.ret <> 1 then
                   error ws.msg
                end if
             end if
          end if
       else

          if ws.c24evtcod_rcl is not null and
             ws.atdsrvnum_rcl is not null then
             call ctb00g01_anlsrv( ws.c24evtcod_rcl,
                                   "",
                                   ws.atdsrvnum_rcl,
                                   ws.atdsrvano_rcl,
                                   g_issk.funmat)
          end if
       end if
       let ws.retorno = true
   else
       error " Assunto nao confirmado!"
       let ws.retorno = false
   end if
   exit while
 end while

 return ws.retorno,ws.lignum

end function  ###  cta02m00_grava

#--------------------------------------------------------------------------
function cta02m00_agenda(param1)
#--------------------------------------------------------------------------
  define param1 record
     c24astcod         like datmligacao.c24astcod
  end record
  define ws  record
     ret               integer ,
     param             char(100),
     data              char(10),
     hora              char(05)
  end record

 define l_data date,
        l_hora2 datetime hour to minute


        initialize  ws.*  to  null

  let ws.param[01,01]    = "C"       # ct24hs
  let ws.param[02,11]    = g_documento.lignum
  if (g_documento.c24soltipcod  = 1    or
      g_documento.c24soltipcod  = 7)   then
      let ws.param[12,12] = "S"       # segurado
  else
     if (g_documento.c24soltipcod = 5      or
         g_documento.c24soltipcod = 11)    and
         g_documento.aplnumdig is not null then
         let ws.param[12,12] = "T"       # terceiro
     else
         let ws.param[12,12] = ""
     end if
  end if

  if g_documento.succod    is not null  and
     g_documento.aplnumdig is not null  and
     g_documento.itmnumdig is not null  then
     let ws.param[13,14]  =  g_documento.succod
     let ws.param[15,23]  =  g_documento.aplnumdig
     let ws.param[24,30]  =  g_documento.itmnumdig
  else
     let ws.param[31,32]  =  g_documento.prporg
     let ws.param[33,41]  =  g_documento.prpnumdig
  end if
  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
  let ws.data         = l_data
  let ws.hora         = l_hora2
  let ws.param[42,51] = ws.data        # o programa de agendamento do sinistro
  let ws.param[52,56] = ws.hora        # estara gravando a 1.0 linha na tabela
  let ws.param[57,62] = g_issk.funmat  # de historico(datmlighist) 02/2001.

  ---------[ alterado para resolucao 86 - ruizR86 ]-----------------
  let ws.param[63,66] = g_documento.ramcod using "&&&&"
  if  param1.c24astcod[1,1] = "C"  then
      let ws.param[67,67] = "1"   # agendamento vistoria sinistro
  else
      let ws.param[67,67] = "2"   # agendamento vistoria previa
  end if
  if  param1.c24astcod = "D15" or    # cancelamento vp
      param1.c24astcod = "C18" then  # cancelamento vist.sinistro
      let ws.param[68,68] = "C"
  else
      let ws.param[68,68] = "A"   # D14 ou C...
  end if
  ------------------------------------------------------------------------------

  call chama_prog("Visto_auto","osvom005",ws.param)
                   returning ws.ret
  if  ws.ret <> 0  then
      error " Erro durante ",
      "a execucao do programa  , osvom005",
      ". AVISE A INFORMATICA!"
  end if
  return ws.data, ws.hora
end function

#--------------------------------------------------------------------------
function cta02m00_atz_just(param)
#--------------------------------------------------------------------------
   define param       record
      c24atrflg       char(01),
      c24jstflg       char(01),
      funnom          like isskfunc.funnom
   end record
   define d_cta02m00a record
      nome            char(50)
   end record
   define d_cta02m00b record
      justif          char(55)
   end record
   define ws   record
      contador           integer
   end record



        initialize  d_cta02m00a.*  to  null

        initialize  d_cta02m00b.*  to  null

        initialize  ws.*  to  null

   if param.c24atrflg   = "S" then
      if param.funnom   is null then
         open window cta02m00a at 10,10 with form "cta02m00a"
                    attribute (border, form line 1)
         input by name d_cta02m00a.nome

            before field nome
               display by name d_cta02m00a.nome attribute (reverse)

            after field nome
               display by name d_cta02m00a.nome
               if d_cta02m00a.nome is  null then
                  error "Nome deve ser informado"
                  next field nome
               end if

            on key (interrupt)
               if d_cta02m00a.nome is null then
                  error "Nome deve ser informado"
                  next field nome
               end if
               exit input
         end input
         close window cta02m00a
      else
         let d_cta02m00a.nome = param.funnom
      end if
   end if
   if param.c24jstflg = "S" then
      open window cta02m00b at 10,10 with form "cta02m00b"
                  attribute (border, form line 1)
      input by name d_cta02m00b.justif

         before field justif
            display by name d_cta02m00b.justif attribute (reverse)

         after field justif
            display by name d_cta02m00b.justif
            if d_cta02m00b.justif is null then
               error "Justificativa deve ser informado"
               next field justif
            end if

         on key (interrupt)
            if d_cta02m00b.justif is null then
               error "Justificativa deve ser informado"
               next field justif
            end if
            exit input
      end input
      close window cta02m00b
   end if
   if param.c24atrflg = "S" or
      param.c24jstflg = "S" then
      select count(*) into ws.contador
            from tmp_autorizasrv
           where srvfunmat = g_issk.funmat
             and srvempcod = g_issk.empcod
             and srvmaqsgl = g_issk.maqsgl
      if ws.contador = 0 then
         insert into tmp_autorizasrv
                   (srvdepto,
                    srvfunmat,
                    srvempcod,
                    srvmaqsgl,
                    srvnome,
                    srvjustif)
           values  (g_issk.dptsgl,
                    g_issk.funmat,
                    g_issk.empcod,
                    g_issk.maqsgl,
                    d_cta02m00a.nome,
                    d_cta02m00b.justif)
         if sqlca.sqlcode <> 0 then
            error " Erro (", sqlca.sqlcode, ") Inclusao tmp_autorizasrv.",
                  " AVISE A INFORMATICA!"
            sleep 2
         end if
      else
         update tmp_autorizasrv
             set srvnome   = d_cta02m00a.nome,
                 srvjustif = d_cta02m00b.justif
           where srvfunmat = g_issk.funmat
             and srvempcod = g_issk.empcod
             and srvmaqsgl = g_issk.maqsgl
      end if
   end if
   let int_flag = false
end function

#-----------------------------------------------#
function cta02m00_buscaHistoricoServico(l_lignum)
#-----------------------------------------------#

  define l_lignum     like datmligacao.lignum,
         l_historico  char(10000),
         l_c24ligdsc  like datmlighist.c24ligdsc

  if m_prep_sql <> true or
    m_prep_sql is null then
    call cta02m00_prepare()
  end if

  let l_historico = null
  let l_c24ligdsc = null

  #-----------------------------
  # BUSCA O HISTORICO DA LIGACAO
  #-----------------------------
  open c_cta02m00_017 using l_lignum
  foreach c_cta02m00_017 into l_c24ligdsc

     if l_historico is null then
        let l_historico = ' ',l_c24ligdsc clipped, '<br>'
     else
        let l_historico = ' ',l_historico clipped,
                          "                      ",
                          l_c24ligdsc, '<br>'
     end if

  end foreach
  close c_cta02m00_017

  return l_historico

end function
#-----------------------------------------------#
function cta02m00_buscaHistServicoL10(l_atdsrvnum, l_atdsrvano)
#-----------------------------------------------#
  define l_atdsrvnum     like datmligacao.lignum,
         l_atdsrvano     like datmservico.atdsrvano,
         l_historico     char(10000),
         l_c24srvdsc     char(45)
  define l_flag          smallint
  if m_prep_sql <> true or
     m_prep_sql is null then
    call cta02m00_prepare()
  end if
  let l_historico = null
  let l_c24srvdsc = null
  let l_flag = 1
  #-----------------------------
  # BUSCA O HISTORICO DO SERVICO L10
  #-----------------------------
  open c_cta02m00_041 using l_atdsrvnum, l_atdsrvano
  foreach c_cta02m00_041 into l_c24srvdsc
     if l_flag = 1 then
        let l_historico = ' ',l_c24srvdsc clipped
        let l_flag = 2
     else
        let l_historico = l_historico clipped, '<br>' ,' ',l_c24srvdsc
     end if
  end foreach
  close c_cta02m00_041
  return l_historico
end function

#----------------------------------------#
function cta02m00_enviaEmail(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         lignum       like datmligacao.lignum,
         vcllicnum    like datkveiculo.vcllicnum,
         vcldes       like datmservico.vcldes,
         segnom       like gsakseg.segnom,
         c24astcod    like datmligacao.c24astcod
  end record

  define l_comando       char(15000),
         l_historico     char(10000),
         l_msg           char(10000),
         l_assunto       char(100),
         l_espera        char(01),
         l_remetente     char(50),
         l_atdsrvnum     like datmservico.atdsrvnum,
         l_atdsrvano     like datmservico.atdsrvano,
         l_para          char(1000),
         l_status        smallint,
         l_ligdat        date,
         l_lighorinc     like datmligacao.lighorinc
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
  define l_erro   smallint
  define msg_erro char(500)
  define emails   array[40] of char(70)
  define l_cont   integer
  define l_param  like iddkdominio.cponom

  let l_cont = 1

  let l_comando   = null
  let l_msg       = null
  let l_assunto   = null
  let l_remetente = null
  let l_ligdat    = null
  let l_atdsrvnum = null
  let l_atdsrvano = null
  let l_espera    = null
  let l_status    = null
  let l_lighorinc = null
  let l_historico = cta02m00_buscaHistoricoServico(lr_parametro.lignum)

  if m_ituran = 1 then
    let l_param = 'ituran'
      open c_cta02m00_046 using l_param
       foreach c_cta02m00_046 into emails[l_cont]
         if l_cont = 1 then
            let l_para = emails[l_cont] clipped
         else
            let l_para = l_para clipped ,"," ,emails[l_cont] clipped
         end if
       end foreach
  else
    if m_tracker = 1 then
      let l_param = 'tracker'

      #open c_cta02m00_046 using l_param          #742450
      #foreach c_cta02m00_046 into emails[l_cont]

      open c_cta02m00_040 using l_param
      foreach c_cta02m00_040 into emails[l_cont]  #742450
         if l_cont = 1 then
            let l_para = emails[l_cont] clipped
         else
            let l_para = l_para clipped ,"," ,emails[l_cont] clipped
         end if
      end foreach
      close c_cta02m00_040
   else
    for i = 1 to 2
        if i = 1 then
           let l_para = "DAF5.RouboFurto@portoseguro.com.br"
        else
           let l_para = cts05m00_buscaRemetenteDaf5()
        end if
    end for
   end if
  end if
  ## DAF5.RouboFurto@portoseguro.com.br
  let l_remetente = "Central-24-Horas"
  ##let l_assunto   = "F45 - INFS. /FURTO/ROUBO"
  if ( lr_parametro.c24astcod = "L10" or
       lr_parametro.c24astcod = "L11" or
       lr_parametro.c24astcod = "L12" or
       lr_parametro.c24astcod = "L45" ) then
       let l_assunto   = lr_parametro.c24astcod clipped , "- LOCALIZACAO DO VEICULO"
  else
       if lr_parametro.c24astcod = "F45" then
          let l_assunto   = "F45 - INFS. /FURTO/ROUBO"
       end if
  end if

  open c_cta02m00_016 using lr_parametro.lignum
  fetch c_cta02m00_016 into lr_parametro.lignum,
                           l_atdsrvano,
                           l_atdsrvnum,
                           l_ligdat,
                           l_lighorinc
  close c_cta02m00_016

  let l_msg       = "Descricao do Veiculo: ", lr_parametro.vcldes    clipped, "<br>",
                    "Placa do Veiculo....: ", lr_parametro.vcllicnum clipped, "<br>",
                    "Nome do Segurado....: ", lr_parametro.segnom    clipped, "<br>",
                    "Data da Ligacao.....: ", l_ligdat using "dd/mm/yyyy", "<br>",
                    "Hora da Ligacao.....: ", l_lighorinc, "<br>",
                    "Historico...........: ", l_historico

  #PSI-2013-23297 - Inicio

  let l_mail.de = l_remetente
  let l_mail.para = l_para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = l_assunto
  let l_mail.mensagem = l_msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"

  call figrc009_mail_send1 (l_mail.*)
      returning l_erro
               ,msg_erro

  #PSI-2013-23297 - Fim
  if l_erro <> 0 then
     error "ERRO NO ENVIO DE E-MAIL DO ASSUNTO F45. AVISE A INFORMATICA !"
     prompt " " for l_espera
  end if

end function

#---------------------------------------------------------------------------
 report cta02m00_rel(ws_linha)
#---------------------------------------------------------------------------

 define ws_linha     char (092)

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format
    on every row
       print column 001, ws_linha, ascii(13)

end report

#--------------------------------------
function cta02m00_anula_cgccpf()
#--------------------------------------

let g_cgccpf.ligdctnum = null
let g_cgccpf.ligdcttip = null

end function

#--------------------------------------------------------------------------
 function cta02m00_cria_tmp_ligacao() ####Cria TEMP para ligacoes.
#--------------------------------------------------------------------------
   whenever error continue
      create temp table cta02m00_tmp_ligacoes
         (lignum      dec(10,0),
          c24astcod   char(4)  ,
          c24astdes   char(40) ,
          ligdat      date     ,
          lighorinc   datetime hour to minute)  with no log
   whenever error stop
   if sqlca.sqlcode  = 0 then
      create unique index tmp_ind2 on cta02m00_tmp_ligacoes
              (lignum,ligdat,lighorinc)
   end if
   if sqlca.sqlcode   != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then  # tabela ja existe
         delete from cta02m00_tmp_ligacoes
      end if
   end if
end function  ###  cta02m00_cria_tmp_ligacao

#-----------------------------------------------------------------------------
Function cta02m00_EnviaEmailSms(l_Assunto,l_segnumdig, l_corsus, l_succod, l_aplnumdig)
#-----------------------------------------------------------------------------

    define l_assunto   like datmligacao.c24astcod
    define l_segnumdig like gsakseg.segnumdig
    define l_corsus    like gcaksusep.corsus
    define l_email     char(500)
    define l_numtel    like gsaktel.telnum
    define l_dddtel    like gsaktel.dddnum
    define l_cod       smallint
    define l_descerro  char(100)
    define l_txtsms    char(200)
    define l_succod    like datrligapol.succod
    define l_aplnumdig like datrligapol.aplnumdig
    define l_segnom    like gsakseg.segnom

    define l_sissgl     like pccmcorsms.sissgl,
           l_prioridade smallint,
           l_expiracao  integer,
           errcod       integer,
           msgerr       char(20)

     define m_mens        record
        msg           char(1000)
       ,de            char(50)
       ,subject       char(200)
       ,para          char(100)
       ,cc            char(100)
       ,cmd           char(2000)
      end record

     define p_envio record
        emitente     char(100)
       ,assunto      char(60)
       ,texto        char(2000)
       ,copia        char(50)
       ,copia_oculta char(50)
       ,anexo        char(100)
     end record

     define lr_gcakfilial    record
             endlgd          like gcakfilial.endlgd
            ,endnum          integer
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
            ,status          smallint  # 0 OK / 1 SUSEP INEXIST / 2 END.NAO LOCALIZ
     end record

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
     define l_erro  smallint
     define msg_erro char(500)
      initialize p_envio.* ,
                 lr_gcakfilial.* to null

      let p_envio.texto = ""

     select segnom into l_segnom
        from gsakseg
        where segnumdig = l_segnumdig

     if sqlca.sqlcode = 0 then


          select telnum,dddnum into l_numtel,l_dddtel
             from gsaktel
             where segnumdig = l_segnumdig
               and teltipcod = 4 #Tipo de telefone 4 - Celular
               and segtelseq in (select max(segtelseq) from gsaktel
                                 where segnumdig = l_segnumdig
                                   and teltipcod = 4)
          if sqlca.sqlcode = 0 then

               ## Envia sms

               let l_sissgl = "PSocorro"
               let l_prioridade = figrc007_prioridade_alta()
               let l_expiracao = figrc007_expiracao_1h()

               if l_assunto = 'S60' or l_assunto = 'S63' then

                  let l_txtsms  = "Porto Seguro Informa: ",
                                    "Para sua comodidade, os servi�os � resid�ncia podem ser solicitados pelo Portal do Cliente: ",
                                    " http://www.333porto.com.br"

               else
                    if l_assunto = 'V10' or l_assunto = 'F10' then

                         let l_txtsms  = "Porto Seguro Informa: ",
                                         "Para sua comodidade, o processo de sinistro pode ser consultado pelo Portal do Cliente: ",
                                         " http://www.333porto.com.br"

                       let p_envio.texto = "Caro Corretor, Acompanhe o processo de sinistro do cliente: ", l_segnom,"/",l_succod,"/531/",l_aplnumdig

                    else
                         if l_assunto = 'B50' then
                              let l_txtsms    = null
                         else
                              let l_txtsms    = null
                         end if

                    end if

               end if

          end if

          select maides into l_email
             from gsakendmai
             where segnumdig = l_segnumdig

          if sqlca.sqlcode = 0 then

               ## Envia e-mail

               let m_mens.de      = "ct24hs.email@portoseguro.com.br"
               let m_mens.para    = l_email
               if l_assunto = 'S60' or l_assunto = 'S63' then

                  let m_mens.subject = "Atendimento Eletr�nico Porto Seguro"

                  let m_mens.msg    = "Caro Cliente, ",ascii(13),ascii(13),
                                    "A partir de agora voc� que tem o Porto Seguro Auto conta com mais uma facilidade. ",
                                    "Acesse http://www.333porto.com.br e solicite servi�os emergenciais � resid�ncia.",
                                    ascii(13),ascii(13),
                                    "Porto Seguro Cia de Seguros Gerais"

               else
                    if l_assunto = 'V10' or l_assunto = 'F10' then

                       let m_mens.subject = "Atendimento Eletr�nico Porto Seguro"

                       let m_mens.msg    = "Caro Cliente, ",ascii(13),ascii(13),
                                         "A partir de agora voc� que tem o Porto Seguro Auto conta com mais uma facilidade. ",
                                         "Acesse http://www.333porto.com.br e acompanhe o seu processo de sinistro.",
                                         ascii(13),ascii(13),
                                         "Porto Seguro Cia de Seguros Gerais"


                       let p_envio.texto = "Caro Corretor, Acompanhe o processo de sinistro do cliente ", l_segnom,"/",l_succod,"/531/",l_aplnumdig,
                           "pelo Col. ",ascii(13),ascii(13),
                           "Porto Seguro Cia de Seguros Gerais"


                    else
                       if l_assunto = 'B50' then

                         let m_mens.subject = "Protocolo de Atendimento"

                         let m_mens.msg    = "Atendendo sua solicita��o, ",ascii(13),ascii(13),
                                         "informamos que registramos seu pedido de cancelamento de seu seguro: ",l_succod, "-531-",l_aplnumdig,ascii(13),
                                         "Para efetiva��o do processo de cancelamento, solicitamos que contate seu corretor de seguros para que seja apresentada proposta de cancelamento de seguro.",
                                         ascii(13),ascii(13),
                                         "Porto Seguro Cia de Seguros Gerais"

                         let m_mens.para = "sac.ct24hs@portoseguro.com.br"

                       else

                         let m_mens.msg  = null

                       end if

                    end if

               end if

               if m_mens.msg is not null then

                    #PSI-2013-23297 - Inicio
                    let l_mail.de = m_mens.de
                    #let l_mail.para = "sistemas.madeira@portoseguro.com.br"
                    let l_mail.para = m_mens.para
                    let l_mail.cc = ""
                    let l_mail.cco = ""
                    let l_mail.assunto = m_mens.subject
                    let l_mail.mensagem = m_mens.msg
                    let l_mail.id_remetente = "CT24HS"
                    let l_mail.tipo = "text"
                    call figrc009_mail_send1 (l_mail.*)
                        returning l_erro,msg_erro
                    #PSI-2013-23297 - Fim

                    if l_assunto = 'B50' then

                         call fgckc811(l_corsus) returning lr_gcakfilial.*

                         if lr_gcakfilial.maides is not null then

                             let m_mens.para = lr_gcakfilial.maides
                             let m_mens.msg = "Caro Corretor \n\n",
                                              "O segurado ", l_segnom clipped, " entrou em contato manifestando interesse em cancelar sua ap�lice de seguro. \n",
                                              "Solicitamos que entre em contato com o cliente para confirma��o da inten��o de cancelamento e formaliza��o do pedido. \n\n",
                                              "Apolice \n\n", l_succod,"/531/",l_aplnumdig," \n\n",
                                              "Porto Seguro Cia de Seguros Gerais"

                             #PSI-2013-23297 - Inicio
                             let l_mail.de = m_mens.de
                             #let l_mail.para = "sistemas.madeira@portoseguro.com.br"
                             let l_mail.para = m_mens.para
                             let l_mail.cc = ""
                             let l_mail.cco = ""
                             let l_mail.assunto = m_mens.subject
                             let l_mail.mensagem = l_mens.msg
                             let l_mail.id_remetente = "CT24HS"
                             let l_mail.tipo = "text"
                             call figrc009_mail_send1 (l_mail.*)
                                 returning l_erro,msg_erro
                             #PSI-2013-23297 - Fim

                         end if


                    else

                         let p_envio.emitente = "ct24h.mail@portoseguro.com.br"
                         let p_envio.assunto = m_mens.subject
                         let p_envio.copia = ""
                         let p_envio.copia_oculta = ""
                         let p_envio.anexo = ""

                         if p_envio.texto is not null then

                              call fcdcc212_enviar_email_corretor(l_corsus, p_envio.*) returning l_cod, l_descerro

                         end if
                    end if

               end if

          end if
     end if

end function

#-----------------------------------------------------------------
function cta02m00_enviaemail_serv_pago(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          vlr    integer,
          qtde   integer
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(1000)
       ,cc           char(1000)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

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
    define l_erro  smallint
    define msg_erro char(500)

    define l_data  date
    define l_hora  datetime hour to second
    define l_cmd   char(1000)
    define l_valor decimal(8,2)
    define l_qtd   integer
    define l_envia integer


    initialize l_email.* to null
    initialize cty08g00_func.* to null

    let l_envia = 0
    let l_data  = today
    let l_hora  = current
    let l_cmd   = null
    let l_valor = 0
    let l_qtd   = 0

    call cta00m06_alerta_despesas()
    returning l_valor , l_qtd


    call cty08g00_nome_func(g_issk.empcod
	                   ,g_issk.funmat,"F")
    returning cty08g00_func.resultado ,
              cty08g00_func.mens,
              cty08g00_func.funnom

    if cty08g00_func.resultado <> 1 then
       error cty08g00_func.mens
    end if


    # Valor
    if lr_param.vlr >= l_valor then
          let l_email.msg =  "Prezado(s), \n \n ",
                             "O operador < ",  g_issk.funmat using '<<<<<<<<&'," - ",cty08g00_func.funnom clipped ," >",
                             " acessou em ", " < ", l_data ,"-",l_hora, " > o documento < " ,
                             g_documento.succod    using '<<<&'   ,"/",
                             g_documento.ramcod    using '<<<<&'  ,"/",
                             g_documento.aplnumdig using '<<<<<<<<&' ,
                             " >,\n que tem R$ " , lr_param.vlr using "<<<<<#.##",
                             " de despesa com servi�os e com ", lr_param.qtde using "&&" clipped, ' servi�os pagos.',
                             " \n \n - Par�metros para alerta: documentos com despesa superior ou igual a ", l_valor using "<<<<<#.##",
                             ' ou quantidade de servi�os pagos superior ou igual a ',l_qtd using "&&",'. '
          let l_email.subject = "Ap�lice com alta despesa com servi�os acessada."
          let l_envia = 1
       #else
       #   let l_email.msg =  " Prezado(s), \n \n ",
       #                        "O operador <",  g_issk.funmat using '<<<<<<<<&'," - ",cty08g00_func.funnom clipped ,">",
       #                        " acessou em ", " < ", l_data ,"-",l_hora, " > o documento < " ,
       #                        g_documento.succod    using '<<<&'   ,"/",
       #                        g_documento.ramcod    using '<<<<&'  ,"/",
       #                        g_documento.aplnumdig using '<<<<<<<<&' ,
       #                        " >,\n que tem R$ " , lr_param.vlr using "<<<<<#.##" clipped, ' de despesa com servi�os.',
       #                        ' \n \n - Par�metros para alerta: documentos com despesa superior ou igual a ', l_valor using "<<<<<#.##" ,'.'
       #   let l_email.subject = "Ap�lice com alta despesa com servi�os acessada."
       #   let l_envia = 1
    else
      if lr_param.qtde >= l_qtd then
         let l_email.msg =  "Prezado(s), \n \n ",
                             "O operador < ",  g_issk.funmat using '<<<<<<<<&'," - ",cty08g00_func.funnom clipped ," >",
                             " acessou em ", " < ", l_data ,"-",l_hora, " > o documento < " ,
                             g_documento.succod    using '<<<&'   ,"/",
                             g_documento.ramcod    using '<<<<&'  ,"/",
                             g_documento.aplnumdig using '<<<<<<<<&' ,
                             " >,\n que tem R$ " , lr_param.vlr using "<<<<<#.##",
                             " de despesa com servi�os e com ", lr_param.qtde using "&&" clipped, ' servi�os pagos.',
                             " \n \n - Par�metros para alerta: documentos com despesa superior ou igual a ", l_valor using "<<<<<#.##",
                             ' ou quantidade de servi�os pagos superior ou igual a ',l_qtd using "&&",'. '
          let l_email.subject = "Ap�lice com alta despesa com servi�os acessada."
          let l_envia = 1
      end if
    end if

    # Se Valor ou Qtd alta, enviar e-mail de Alerta.
    if l_envia = 1 then

       call cta00m06_lista_email_alerta()
       returning l_email.para

       if l_email.para is not null then
          #PSI-2013-23297 - Inicio
          let l_mail.de = "ct24hs.email@portoseguro.com.br"
          #let l_mail.para = "kleiton.nascimento@correioporto"
          let l_mail.para = l_email.para
          let l_mail.cc = ""
          let l_mail.cco = ""
          let l_mail.assunto = l_email.subject
          let l_mail.mensagem = l_email.msg
          let l_mail.id_remetente = "CT24HS"
          let l_mail.tipo = "text"
          call figrc009_mail_send1 (l_mail.*)
              returning l_erro,msg_erro

          #PSI-2013-23297 - Fim
          if l_erro <> 0 then
             error "Erro ao enviar alerta de despesas ! " sleep 3
          else
            let m_primeira_vez = 'N'
          end if
       end if

    end if
end function

#-----------------------------------#
 function cta02m00_popup_recomenda()    #SA__260142_1
#-----------------------------------#
 define la_recomenda array[20] of char(50)

 define l_index      smallint
 define l_chk        smallint
 define l_chave      char(20)
 define l_descricao  char(3)
 define l_mens       char(100)
 define l_i          smallint

{
   define l_popup      char(200)
   define l_par1       char(10)
   define l_opcao      smallint

   let l_popup  = "F10|N10|N11"
   let l_popup  = l_popup clipped
   let l_par1   = "ASSUNTOS DE SINISTRO"
   let l_par1   = l_par1  clipped

    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1 , l_popup clipped)
         returning l_opcao, l_descricao

 return l_descricao

}

  for l_index  =  1  to  20
    initialize  la_recomenda[l_index] to  null
  end  for

  let l_i = 1
  let l_chave = "guincho_aviso"

  whenever error continue
  open c_cta02m00_040 using l_chave
    foreach c_cta02m00_040 into la_recomenda[l_i]
      let l_i = l_i + 1
    end foreach

    if sqlca.sqlcode <> 0 then
      let l_mens = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(l_mens)
      error l_mens
   end if


  open window cta02m00c at 8,20 with form "cta02m00c"
              attribute (border, form line 1)

  call set_count(l_i - 1)

 let l_chk = false
 while l_chk = false

  display array la_recomenda to as_cta02m00c.*

          on key (interrupt)
             error "Escolha uma das op��es"
             let l_chk = false
            exit display

          on key(f8)
             let l_index = arr_curr()
             let l_chk = true
             exit display

  end display
 end while

  close window cta02m00c

  if l_chk = true then
     let l_descricao = la_recomenda[l_index]
     let l_descricao = l_descricao[1,3]
     close c_cta02m00_040
     return l_descricao
  end if
end function

#===============================================================================
function cta02m00_pega_vigencia_apolice()
#===============================================================================
define l_viginc    like abbmdoc.viginc
define l_vigfnl    like abbmdoc.vigfnl

 let l_viginc = today
 let l_vigfnl = today

 select viginc, vigfnl
   into l_viginc, l_vigfnl
   from abamapol
  where abamapol.succod    = g_documento.succod
    and abamapol.aplnumdig = g_documento.aplnumdig

 return l_viginc
      , l_vigfnl

end function
#----------------------------------------------------------------------------#
function cta02m00_nova_qtdatd(lr_param)
#----------------------------------------------------------------------------#
define lr_param record
       ramcod       like rsamseguro.ramcod
      ,succod       like abamapol.succod
      ,aplnumdig    like abamapol.aplnumdig
      ,itmnumdig    like abbmdoc.itmnumdig
      ,c24astcod    like datmligacao.c24astcod
end record
define lr_retorno record
       resultado       smallint
      ,mensagem        char(60)
      ,flag_limite     char(01)
      ,confirma        char(01)
      ,qtd_atendimento integer
      ,qtd_limite      integer
end record
initialize lr_retorno.* to null
    if cty31g00_nova_regra_clausula(lr_param.c24astcod) then
        call cty31g00_valida_envio_guincho(lr_param.ramcod    ,
                                           lr_param.succod    ,
                                           lr_param.aplnumdig ,
                                           lr_param.itmnumdig ,
                                           lr_param.c24astcod ,
                                           "")
        returning lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,lr_retorno.flag_limite
                 ,lr_retorno.qtd_atendimento
                 ,lr_retorno.qtd_limite
        if lr_retorno.flag_limite     = "S" then
            let lr_retorno.confirma = cts08g01('A'
                             ,'N'
                             ,''
                             ,'CONSULTE A COORDENACAO, '
                             ,'PARA ENVIO DE ATENDIMENTO., '
                             ,'')
            return 2
        else
        	  return 1
        end if
    else
        return 1
    end if
end function

#---------------------------------------------
function cta02m00_recupera_tapete_azul()
#---------------------------------------------

define lr_retorno record
       segnumdig   like abbmdoc.segnumdig  ,
       cgccpfnum   like gsakseg.cgccpfnum  ,
       cgcord      like gsakseg.cgcord     ,
       cgccpfdig   like gsakseg.cgccpfdig  ,
       cpodes      like iddkdominio.cpodes ,
       param       char (12)               ,
       erro        smallint
end record

initialize lr_retorno.* to null

    let g_flag_azul = null

    let lr_retorno.param = 'tapete_azul'

   	open c_cta02m00_042 using g_documento.succod,
	                            g_documento.aplnumdig,
	                            g_documento.succod,
	                            g_documento.aplnumdig
	  whenever error continue
	  fetch c_cta02m00_042 into lr_retorno.segnumdig
	  whenever error stop
	  close c_cta02m00_042

    open c_cta02m00_043 using lr_retorno.segnumdig
    whenever error continue
    fetch c_cta02m00_043 into lr_retorno.cgccpfnum,
                              lr_retorno.cgcord   ,
                              lr_retorno.cgccpfdig
    whenever error stop
    close c_cta02m00_043

    open c_cta02m00_044 using lr_retorno.param
    whenever error continue
    fetch c_cta02m00_044 into lr_retorno.cpodes
    whenever error stop
    close c_cta02m00_044
    
    call osgtf550_busca_fator_cliente(lr_retorno.cgccpfnum
                                     ,lr_retorno.cgcord
                                     ,lr_retorno.cgccpfdig
                                     ,1)
    returning lr_retorno.erro

    if lr_retorno.erro = 0  and
    	 ga_gsakhstftr[1].cliprdqtd >= lr_retorno.cpodes then
         let g_flag_azul = "S"
    else
    	   let g_flag_azul = "N"
    end if


end function