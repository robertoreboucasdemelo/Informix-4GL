#############################################################################
# Nome do Modulo: CTS15M00                                         Marcelo  #
#                                                                  Gilberto #
# Laudo - Reserva de locacao de veiculos                           Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   #
#---------------------------------------------------------------------------#
# 09/10/1998  Pdm #52322   Marcelo      Corrigir exibicao da janela de sal- #
#                                       do, colocando rotina apos VEICULO.  #
#---------------------------------------------------------------------------#
# 13/10/1998  Pdm #52322   Gilberto     Retirar chamada a funcao CONDICOES  #
#                                       apos campo MOTIVO, pois nao e' ne-  #
#                                       cessario.                           #
#                                       Alteracao da funcao CONDICOES, pas- #
#                                       sando como data parametro a data do #
#                                       atendimento ao inves da data atual. #
#                                       Alteracao da funcao CONDICOES, pas- #
#                                       sando o numero da reserva para que  #
#                                       a mesma nao seja considerada no     #
#                                       calculo do saldo.                   #
#---------------------------------------------------------------------------#
# 06/10/1998  PSI 7056-4   Gilberto     Alterar situacao da loja de (A)tiva #
#                                       ou (C)ancelada para codificacao nu- #
#                                       merica: (1)Ativa;     (2)Bloqueada; #
#                                               (3)Cancelada; (4)Desativada #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Permitir atendimento para clausula  #
#                                       26D (Carro Extra Deficiente Fisico) #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Permitir atendimento para clausula  #
#                                       80 (Carro Extra Taxi).              #
#---------------------------------------------------------------------------#
# 18/11/1998  PSI 6467-0   Gilberto     Gravar codigo do veiculo atendido.  #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Gravar dados referentes a digitacao #
#                                       via formulario.                     #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 03/02/1999  PSI 7670-8   Wagner       Alteracao para permitir locacao de  #
#                                       veiculos em uma loja bloqueada      #
#                                       desde que o periodo de bloqueio nao #
#                                       esteja vigente.                     #
#---------------------------------------------------------------------------#
# 10/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias  #
#                                       foi alterado de (data atendimento)  #
#                                       para (data do sinistro).            #
#---------------------------------------------------------------------------#
# 11/03/1999  PSI 7954-5   Wagner       Alteracao na mensagem da loja blo-  #
#                                       queada para exibir periodo.         #
#---------------------------------------------------------------------------#
# 22/03/1999  PSI 7671-6   Wagner       Alteracao para mudar a input data   #
#                                       retirada de lugar permitindo assim  #
#                                       a pesquisa das lojas que estarao    #
#                                       abertas nesta data.                 #
#---------------------------------------------------------------------------#
# 06/04/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8644-4   Wagner       Incluir o campo Cheque caucao na    #
#                                       input e pesquisa nas locadoras.     #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 8645-2   Wagner       Incluir o campo Taxa de Seguro na   #
#                                       input e pesquisa nas locadoras.     #
#---------------------------------------------------------------------------#
# 24/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do   #
#                                       historico.(Inclusao)                #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 08/02/2000  PSI 10206-7  Wagner       Incluir no INSERT datmservico o     #
#                                       nivel prioridade atend. = 2-NORMAL. #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO      #
#                                       via funcao                          #
#                                       Exclusao da coluna atdtip           #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 14/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 15/08/2000  PSI 11275-5  Wagner       Subst.acesso cauchqflg para tabela  #
#                                       datkavislocal.                      #
#---------------------------------------------------------------------------#
# 29/11/2000  PSI 11883-4  Wagner       Criar novo motivo de reserva (5)    #
#                                       Particulares e substituir o (9) de  #
#                                       Espontanea para Ind.Integral.       #
#---------------------------------------------------------------------------#
# 26/01/2001  PSI 11559-2  Wagner       Acesso a funcao ossaa009_ultima_opc #
#                                       para verificar situacao segurado.   #
#---------------------------------------------------------------------------#
# 20/01/2001  PSI 10631-3  Wagner       Incluir campos no retorno da funcao #
#                                       cts15m04.                           #
#---------------------------------------------------------------------------#
# 05/03/2001  ADENDO       Wagner       Alteracao para permitir mudanca     #
#                                       para motivo 4-Depto.                #
#---------------------------------------------------------------------------#
# 16/02/2001  PSI 11254-2  Ruiz         Consulta ao Condutor do veiculo     #
#---------------------------------------------------------------------------#
# 23/04/2001  ADENDO       Wagner       Incluir acesso a funcao sinifopc    #
#                                       caso motivo tenha sido alterado de  #
#                                       1 para 3.                           #
#---------------------------------------------------------------------------#
# 23/07/2001  TESTE        Wagner       Inclusao gravar log p/a verificacao #
#                                       da atualizacao das reservas na inter#
#                                       -face com o sinistro.               #
#---------------------------------------------------------------------------#
# 28/09/2001  PSI 13881-9  Wagner       Inclusao do campo CPF do usuario    #
#---------------------------------------------------------------------------#
# 01/12/2001  PSI 13642-5  Wagner       Tratamento Benef.Oficina.           #
#---------------------------------------------------------------------------#
# 01/01/2002  PSI 15021-5  Wagner       Tratamento Benef.Oficina.           #
#---------------------------------------------------------------------------#
# 08/03/2002  AS  6823     Ruiz         Enviar e-mail na abertura do laudo. #
#---------------------------------------------------------------------------#
# 27/05/2002  PSI 15455-5  Wagner       Alteracao tarifa 02 para lojas      #
#                                       tratamento especial.                #
#---------------------------------------------------------------------------#
# 03/07/2002  PSI 15590-0  Wagner       Inclusao msg convenio/assuntos.     #
#---------------------------------------------------------------------------#
# 26/07/2002  PSI 15758-9  Ruiz         pular o campo formulario.           #
#---------------------------------------------------------------------------#
# 31/07/2002  PSI 15625-6  Raji         Enviar e-mail na abertura do laudo  #
#                                       MOTIVO 3                            #
#---------------------------------------------------------------------------#
# 17/10/2002  Correio Arnaldo/Raji      Bloquear envio e-mail laudo MOTIVO 3#
#---------------------------------------------------------------------------#
# 25/03/2003  PSI169277/OSF14966 Paula  Implementa��o de uma nova critica   #
#                                       Verifica critica para emp. Localisa #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 03/07/2003  Amaury              PSI.176087     Obter a Vigencia da Apolice#
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI        Alteracao                             #
# ---------- ------------- ---------  --------------------------------------#
# 18/09/2003 Julianna,Meta PSI175552  Inibir a chamada da funcao ctx17g00   #
#                          OSF26077                                         #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Ligia Matge                      OSF : 30970            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 12/01/2004       #
#  Objetivo       : Alteracao das regras de Negocio da Cia., considerando   #
#                   como base a data de calculo dos orcamentos.             #
#                                                                           #
#  Analista Resp. : Ruiz                             OSF : 32867            #
#  Por            : FABRICA DE SOFTWARE, Paula       Data: 04/03/2004       #
#  Objetivo       :                                                         #
#                                                                           #
#                 : Kiandra                          CT 187747              #
#                 : FABRICA DE SOFTWARE, Mariana                            #
#                 : Chamar funcao 'ogsrc021' p/ retorno da data de calculo  #
#                                                                           #
#  Analista Resp. : Ruiz                             OSF : 32867            #
#  Por            : FABRICA DE SOFTWARE, Paula       Data: 02/04/2004       #
#  Objetivo       :                                                         #
#                                                                           #
#  Analista Resp. : Ligia Mattge                     PAS : 184551           #
#  Por            : FABRICA DE SOFTWARE, Evandro     Data: 14/04/2004       #
#  Objetivo       : Inibir validacao lcvlojtip = 1,2 ou 3 (Ref.Carlos Dias) #
#                   Valor foi unificado (frqvlr = 1500,00)                  #
#---------------------------------------------------------------------------#
#  Analista Resp. : Kiandra                          CT 212857              #
#  Por            : FABRICA DE SOFTWARE, Teresinha   Data: 26/05/2004       #
#  Objetivo       : Acrescentar o endosso no  cursor c_cts15m00_003         #
# --------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
# Analista Resp. : Zyon                              OSF 37184              #
# Por            : FABRICA DE SOFTWARE, Teresinha    Data: 22/06/2004       #
# Objetivo       : Alterar chamada funcao ctn18c00 passando zero como cod do#
#                   motivo da locacao ao inves da flag de oficinas          #
#############################################################################
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 16/08/2004 Meta, James       PSI183431  Passar a retornar parametros na   #
#                                         chamada do cta00m01               #
# 20/08/2004 Daniel, Meta      PSI183431  Alterar a definicao da variavel   #
#                                         averbacao                         #
#                                                                           #
# 22/11/2004 Daniel, Meta      PSI189170  Modificar o texto de orientacao   #
#                                         sobre as exigencias para segundos #
#                                         condutores de carro extra         #
#                                                                           #
# 20/12/2004 Paulo, Meta       PSI187887  Inclusao do campo Avisar Sinistro #
#                                         (lcvsinavsflg) na tela e demais   #
#                                         ajustes referentes a este campo   #
#                                         (insert/update/delete).           #
#                                                                           #
# 28/12/2004 Bruno, Meta       PSI187887  Consistir variavel 'slv_terceiro- #
#                                         .aplnumdig' � nula.               #
#---------------------------------------------------------------------------#
# 10/12/2004  Katiucia      CT 268615 Passar data de devolucao do veiculo ja#
#                                     calculada p/ funcao cts15m04_valloja  #
#---------------------------------------------------------------------------#
# 11/03/2005  Katiucia      CT 290661 alterada o parametro nro servico/ano  #
#                           na chamada da funcao ctx01g05_incluir_apol_ter  #
#---------------------------------------------------------------------------#
# 08/08/2005 Paulo, Meta       PSI194212  Substituicao da funcao ogsrc021   #
#                                         por faemc603_proposta             #
#---------------------------------------------------------------------------#
# 06/02/2006 Lucas Scheid      PSI197750  Criacao da funcao                 #
#                                         cts15m00_ver_ar_cond().           #
#---------------------------------------------------------------------------#
# 21/01/2006 Priscila          PSI 198390 Alteracao chamada funcao ctn18c00 #
#                                         incluir cepcmp como parametro     #
#---------------------------------------------------------------------------#
# 22/01/2006 Priscila          PSI 198390 Alteracao no fluxo da tela -exibir#
#                                         taxa 2 condut e valores franquia  #
#---------------------------------------------------------------------------#
# 02/03/2006 Priscila          Zeladoria  Buscar data e hora do banco       #
#---------------------------------------------------------------------------#
# 15/02/2006 Alinne, Meta      PSI196878  Inclusao da chamada da funcao     #
#                                         cts15m13_ver_ar_cond() e criacao  #
#                                         da funcao Cts15M00_Acionamento()  #
#---------------------------------------------------------------------------#
# 28/11/2006 Priscila          PSI205206  Passar empresa para ctn17c00 e    #
#                                         para ctn18c00                     #
#---------------------------------------------------------------------------#
# 27/03/2007 Roberto                      Criacao das funcoes cts15m00_rec  #
#                                         email(), cts15m00_monta_mens(),   #
#                                         cts15m00_env_email() e            #
#                                         Inclusao da chamada da funcao     #
#                                         cts15m00b()                       #
#                                                                           #
# 10/01/2008 Ligia Mattge      PSI217956  Abrir reserva p/ramos do RE       #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 236195 Prorrogacao Clausula 33           #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton, Meta                Projeto sucursal smallint         #
#---------------------------------------------------------------------------#
# 17/11/2010 Amilton, Meta                Integra��o localiza webservice    #
# 17/05/2011 Ligia, Fornax                Carro extra - fase II             #
#---------------------------------------------------------------------------#
#07-03-2013 Jorge Modena  PSI-2013-04081 Cria��o de dois novos campos no ban#
#                                         co para salvar celular de reservas#
#                                         de locadoras que nao possuem inte-#
#                                         gracao automatica                 #
#                                                                           #
#-----------------------------------------------------------------------------#
# 11/06/2013 AS-2013-10854  Humberto Santos  Projeto Tapete Azul - benef�cios #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Altera��o da utiliza��o do sendmail   #
#                                                                             #
# 27/10/2014                Rodolfo Massini Inclusao do apos_grava laudo para #
#                                           sincornizar informacoes do carro  #
#                                           extra com o AW                    #
###############################################################################
# 25/03/2015 ST-2015-00006  Alberto/Roberto                                   #
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

 define d_cts15m00    record
    servico           char (13)                        ,
    c24solnom         like datmligacao.c24solnom       ,
    nom               like datmservico.nom             ,
    doctxt            char (32)                        ,
    corsus            like datmservico.corsus          ,
    cornom            like datmservico.cornom          ,
    cvnnom            char (19)                        ,
    vclcoddig         like datmservico.vclcoddig       ,
    vcldes            like datmservico.vcldes          ,
    vclanomdl         like datmservico.vclanomdl       ,
    vcllicnum         like datmservico.vcllicnum       ,
    vclloctip         like datmavisrent.vclloctip      ,
    vcllocdes         char (08)                        ,
    c24astcod         like datkassunto.c24astcod       ,
    c24astdes         char (72)                        ,
    avilocnom         like datmavisrent.avilocnom      ,
    cdtoutflg         like datmavisrent.cdtoutflg      ,
    cdtsegtaxvlr      like datklocadora.cdtsegtaxvlr   ,    #PSI 198390
    avialgmtv         like datmavisrent.avialgmtv      ,
    avimtvdes         char (16)                        ,
    lcvsinavsflg      like datmavisrent.lcvsinavsflg   ,
    lcvcod            like datklocadora.lcvcod         ,
    lcvnom            like datklocadora.lcvnom         ,
    lcvextcod         like datkavislocal.lcvextcod     ,
    aviestnom         like datkavislocal.aviestnom     ,
    aviestcod         like datmavisrent.aviestcod      ,
    avivclcod         like datkavisveic.avivclcod      ,
    avivclgrp         like datkavisveic.avivclgrp      ,
    avivcldes         char (65)                        ,
    vcldiavlr         like datmavisrent.avivclvlr      ,
    avivclvlr         like datmavisrent.avivclvlr      ,
    locsegvlr         like datmavisrent.locsegvlr      ,
    frqvlr            like datkavisveic.frqvlr         ,    #PSI 198390
    isnvlr            like datkavisveic.isnvlr         ,    #PSI 198390
    rduvlr            like datkavisveic.rduvlr         ,    #PSI 198390
    cndtxt            char (20)                        ,
    prgtxt            char (11)                        ,
    frmflg            char (01)                        ,
    aviproflg         char (01)                        ,
    cttdddcod         like datmavisrent.cttdddcod      ,
    ctttelnum         like datmavisrent.ctttelnum      ,
    atdlibflg         like datmservico.atdlibflg       ,
    atdlibtxt         char (65)                        ,
    cauchqflg         like datkavislocal.cauchqflg     ,
    locrspcpfnum      like datmavisrent.locrspcpfnum   ,
    locrspcpfdig      like datmavisrent.locrspcpfdig   ,
    atdsrvnum         LIKE datmservico.atdsrvnum       ,
    atdsrvano         LIKE datmservico.atdsrvano       ,
    dtentvcl          date                             ,
    cartao            char(1)                          ,
    smsenvdddnum      like datmrsvvcl.smsenvdddnum     , # Amilton
    smsenvcelnum      like datmrsvvcl.smsenvcelnum     , # Amilton
    garantia          char(20), # Amilton
    flgarantia        char(1),
    acntip            like datklocadora.acntip
 end record
 
 define a_cts15m00    array[3] of record
    operacao          char (01)
   ,lclidttxt         like datmlcl.lclidttxt
   ,lgdtxt            char (65)
   ,lgdtip            like datmlcl.lgdtip
   ,lgdnom            like datmlcl.lgdnom
   ,lgdnum            like datmlcl.lgdnum
   ,brrnom            like datmlcl.brrnom
   ,lclbrrnom         like datmlcl.lclbrrnom
   ,endzon            like datmlcl.endzon
   ,cidnom            like datmlcl.cidnom
   ,ufdcod            like datmlcl.ufdcod
   ,lgdcep            like datmlcl.lgdcep
   ,lgdcepcmp         like datmlcl.lgdcepcmp
   ,lclltt            like datmlcl.lclltt
   ,lcllgt            like datmlcl.lcllgt
   ,dddcod            like datmlcl.dddcod
   ,lcltelnum         like datmlcl.lcltelnum
   ,lclcttnom         like datmlcl.lclcttnom
   ,lclrefptotxt      like datmlcl.lclrefptotxt
   ,c24lclpdrcod      like datmlcl.c24lclpdrcod
   ,ofnnumdig         like sgokofi.ofnnumdig
   ,emeviacod         like datmemeviadpt.emeviacod
   ,celteldddcod      like datmlcl.celteldddcod
   ,celtelnum         like datmlcl.lcltelnum
   ,endcmp            like datmlcl.endcmp
 end record

 define m_cts15ant    record
    servico           char (13)                        ,
    c24solnom         like datmligacao.c24solnom       ,
    nom               like datmservico.nom             ,
    doctxt            char (32)                        ,
    corsus            like datmservico.corsus          ,
    cornom            like datmservico.cornom          ,
    cvnnom            char (19)                        ,
    vclcoddig         like datmservico.vclcoddig       ,
    vcldes            like datmservico.vcldes          ,
    vclanomdl         like datmservico.vclanomdl       ,
    vcllicnum         like datmservico.vcllicnum       ,
    vclloctip         like datmavisrent.vclloctip      ,
    vcllocdes         char (08)                        ,
    c24astcod         like datkassunto.c24astcod       ,
    c24astdes         char (72)                        ,
    avilocnom         like datmavisrent.avilocnom      ,
    cdtoutflg         like datmavisrent.cdtoutflg      ,
    cdtsegtaxvlr      like datklocadora.cdtsegtaxvlr   ,    #PSI 198390
    avialgmtv         like datmavisrent.avialgmtv      ,
    avimtvdes         char (16)                        ,
    lcvsinavsflg      like datmavisrent.lcvsinavsflg   ,
    lcvcod            like datklocadora.lcvcod         ,
    lcvnom            like datklocadora.lcvnom         ,
    lcvextcod         like datkavislocal.lcvextcod     ,
    aviestnom         like datkavislocal.aviestnom     ,
    aviestcod         like datmavisrent.aviestcod      ,
    avivclcod         like datkavisveic.avivclcod      ,
    avivclgrp         like datkavisveic.avivclgrp      ,
    avivcldes         char (65)                        ,
    vcldiavlr         like datmavisrent.avivclvlr      ,
    avivclvlr         like datmavisrent.avivclvlr      ,
    locsegvlr         like datmavisrent.locsegvlr      ,
    frqvlr            like datkavisveic.frqvlr         ,    #PSI 198390
    isnvlr            like datkavisveic.isnvlr         ,    #PSI 198390
    rduvlr            like datkavisveic.rduvlr         ,    #PSI 198390
    cndtxt            char (20)                        ,
    prgtxt            char (11)                        ,
    frmflg            char (01)                        ,
    aviproflg         char (01)                        ,
    cttdddcod         like datmavisrent.cttdddcod      ,
    ctttelnum         like datmavisrent.ctttelnum      ,
    atdlibflg         like datmservico.atdlibflg       ,
    atdlibtxt         char (65)                        ,
    cauchqflg         like datkavislocal.cauchqflg     ,
    locrspcpfnum      like datmavisrent.locrspcpfnum   ,
    locrspcpfdig      like datmavisrent.locrspcpfdig   ,
    atdsrvnum         LIKE datmservico.atdsrvnum       ,
    atdsrvano         LIKE datmservico.atdsrvano       ,
    dtentvcl          date                             ,
    cartao            char(1)                          ,
    smsenvdddnum      like datmrsvvcl.smsenvdddnum     , # Amilton
    smsenvcelnum      like datmrsvvcl.smsenvcelnum     , # Amilton
    garantia          char(20), # Amilton
    flgarantia        char(1),
    acntip            like datklocadora.acntip
 end record

 define m_cts15m04 record
    aviretdat         like datmavisrent.aviretdat  , # Teste
    avirethor         like datmavisrent.avirethor  , # Teste
    aviprvent         like datmavisrent.aviprvent    # Teste
 end record


 define w_cts15m00    record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    avialgmtv         like datmavisrent.avialgmtv,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnldat            like datmservico.cnldat      ,
    c24opemat         like datmservico.c24opemat   ,
    clscod            like abbmclaus.clscod        ,
    clscod26          like abbmclaus.clscod        ,
    clscod33          like abbmclaus.clscod        ,
    clscod46          like abbmclaus.clscod        ,
    clscod44          like abbmclaus.clscod        ,
    clscod47          like abbmclaus.clscod        ,
    clscod48          like abbmclaus.clscod        ,
    clscod34          like abbmclaus.clscod        ,
    clscod35          like abbmclaus.clscod        ,
    clsflg            smallint                     ,
    sldqtd            smallint                     ,
    limite            smallint                     ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    avidiaqtd         like datmavisrent.avidiaqtd  ,
    aviretdat         like datmavisrent.aviretdat  ,
    avirethor         like datmavisrent.avirethor  ,
    aviprvent         like datmavisrent.aviprvent  ,
    avioccdat         like datmavisrent.avioccdat  ,
    ofnnom            like datmavisrent.ofnnom     ,
    ofndddcod         like datmavisrent.dddcod     ,
    ofntelnum         like datmavisrent.telnum     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    datasaldo         date                         ,
    slcemp            like datmavisrent.slcemp     ,
    slcsuccod         like datmavisrent.slcsuccod  ,
    slcmat            like datmavisrent.slcmat     ,
    slccctcod         like datmavisrent.slccctcod  ,
    locrspcpfnum      like datmavisrent.locrspcpfnum,
    locrspcpfdig      like datmavisrent.locrspcpfdig,
    procan            CHAR(01),
    aviprodiaqtd      LIKE datmprorrog.aviprodiaqtd,
    atdrsdflg         like datmservico.atdrsdflg
 END record

 DEFINE w_titulo                 LIKE dammtrx.c24msgtit,
        w_lintexto               LIKE dammtrxtxt.c24trxtxt

 # -- OSF 30970 - Fabrica de Software, Katiucia -- #
 define m_clcdat     like abbmcasco.clcdat
       ,m_cts08g01   char(01)
       
 define m_prep_sql smallint  #psi175552
       ,m_envio    smallint  # psi175552
       ,m_erro     smallint  # psi175552
       ,m_erro_msg char(70)
       ,m_empcod   like isskfunc.empcod
       ,m_funmat   like isskfunc.funmat
       ,m_prep     smallint
       ,m_pgtflg     smallint
       ,m_opcao    smallint
       ,m_reenvio  smallint
       ,m_cidnom   like datmlcl.cidnom
       ,m_ufdcod   like datmlcl.ufdcod
       ,m_cct      integer
       ,m_prorrog  smallint
       ,m_alt_motivo smallint

 #osf32867 - Paula
 define slv_segurado  record
    succod            like datrligapol.succod       ,
    ramcod            like gtakram.ramcod           ,
    aplnumdig         like datrligapol.aplnumdig    ,
    itmnumdig         like datrligapol.itmnumdig    ,
    edsnumref         like datrligapol.edsnumref    ,
    lignum            like datmligacao.lignum       ,
    c24soltipcod      like datmligacao.c24soltipcod ,
    solnom            char (15)                     ,
    c24astcod         like datkassunto.c24astcod    ,
    ligcvntip         like datmligacao.ligcvntip    ,
    prporg            like datrligprp.prporg        ,
    prpnumdig         like datrligprp.prpnumdig     ,
    fcapacorg         like datrligpac.fcapacorg     ,
    fcapacnum         like datrligpac.fcapacnum     ,
    dctnumseq         dec (04,00)                   ,
    vclsitatu         dec (04,00)                   ,
    autsitatu         dec (04,00)                   ,
    dmtsitatu         dec (04,00)                   ,
    dpssitatu         dec (04,00)
 end record

 define slv_terceiro  record
    succod            like datrligapol.succod      ,
    ramcod            like gtakram.ramcod          ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    lignum            like datmligacao.lignum      ,
    c24soltipcod      like datmligacao.c24soltipcod,
    solnom            char (15)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapacorg         like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    dctnumseq         dec (04,00)                  ,
    vclsitatu         dec (04,00)                  ,
    autsitatu         dec (04,00)                  ,
    dmtsitatu         dec (04,00)                  ,
    dpssitatu         dec (04,00)
 end record
 #osf32867 - Paula

 define m_cts15m00b record
         erro          smallint  ,
         mens          char(100) ,
         ver_data      smallint  ,
         para          char(1000),
         de            char(100) ,
         cc            char(1000),
         assunto       char(100) ,
         mens2         char(1000),
         flag          smallint  ,
         corsus_ant    like datmservico.corsus
 end record

 define m_cts15m00b1 array[05] of record
        corsus       like datmservico.corsus
 end record

 define m_idx integer

       ,m_tem_33_26 smallint
       ,m_flag_alt  smallint
       ,m_f7 smallint

 define m_ctd07g05       record
          empcod           like datmsrvacp.empcod
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
         ,pstcoddig        like datmsrvacp.pstcoddig
         ,srrcoddig        like datmsrvacp.srrcoddig
   end record

 define m_reserva record
        erro        integer,
        rsvlclcod   like datmrsvvcl.rsvlclcod ,
        loccntcod   like datmrsvvcl.loccntcod,
        rsvsttcod   like datmrsvvcl.rsvsttcod
 end record

   define m_ctd31 record
          sqlcode smallint,
          mens    char(80),
          rsvlclcod   like datmrsvvcl.rsvlclcod
   end record

   define w_claus2 record
       clscod33          like abbmclaus.clscod        ,
       clscod46          like abbmclaus.clscod        ,
       clscod44          like abbmclaus.clscod        ,
       clscod47          like abbmclaus.clscod        ,
       clscod48          like abbmclaus.clscod        ,
       clscod34          like abbmclaus.clscod        ,
       clscod35          like abbmclaus.clscod        ,
       clscod            like abbmclaus.clscod        ,
       flag              char(01)                     ,
       atende            char(01)                     ,
       motivos           char(500)
   end record
#----------------------------#
 function cts15m00_prepara()   #psi175552
#----------------------------#
   define l_sqlstmt  char(700)

   let l_sqlstmt = ' select cpodes ',
                   '   from iddkdominio ',
                   '  where cponom = "avialgmtv" ',
                   '    and cpocod = ? '

   prepare p_cts15m00_001 from l_sqlstmt
   declare c_cts15m00_001 cursor for p_cts15m00_001

   let l_sqlstmt = " select b.atdsrvnum ,b.atdsrvano     "
                  ,"   from datrservapol a,datmservico b "
                  ,"       ,datmligacao c                "
                  ,"  where a.succod = ?                 "
                  ,"    and a.ramcod in (31,531)         "
                  ,"    and a.aplnumdig = ?              "
                  ,"    and a.itmnumdig = ?              "
                  ,"    and a.edsnumref >= 0             "
                  ,"    and b.atdsrvnum = a.atdsrvnum    "
                  ,"    and b.atdsrvano = a.atdsrvano    "
                  ,"    and b.atddat between ? and ?     "
                  ,"    and b.atdsrvorg   = 8            "
                  ,"    and b.atdsrvnum   = c.atdsrvnum  "
                  ,"    and b.atdsrvano   = c.atdsrvano  "
                  ,"    and c.c24astcod   = 'H10'        "
   prepare p_cts15m00_002 from l_sqlstmt
   declare c_cts15m00_002 cursor
       for p_cts15m00_002


   let l_sqlstmt = " select prporgpcp,prpnumpcp ",
                   "   from abamdoc             ",
                   "  where succod    = ?       ",
                   "    and aplnumdig = ?       ",
                   "    and edsnumdig = ?       " -- CT 212857
   prepare p_cts15m00_003 from l_sqlstmt
   declare c_cts15m00_003 cursor for p_cts15m00_003

   let l_sqlstmt = 'select lcvcod      , avivclcod    , avivclvlr ,   '
                        ,' aviestcod   , avialgmtv    , avilocnom ,   '
                        ,' aviretdat   , avirethor    , aviprvent ,   '
                        ,' locsegvlr   , vclloctip    , avioccdat ,   '
                        ,' ofnnom      , dddcod       , telnum    ,   '
                        ,' cttdddcod   , ctttelnum    , avirsrgrttip, '
                        ,' slcemp      , slcsuccod    , slcmat      , '
                        ,' slccctcod   , cdtoutflg    , locrspcpfnum, '
                        ,' locrspcpfdig, lcvsinavsflg '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                     ,' and atdsrvano = ? '

   prepare p_cts15m00_004 from l_sqlstmt
   declare c_cts15m00_004 cursor for p_cts15m00_004

   let l_sqlstmt = 'update datmavisrent set (lcvcod   , avivclcod, aviestcod   , '
                                          ,' avivclvlr, locsegvlr, avialgmtv   , '
                                          ,' avidiaqtd, avilocnom, aviretdat   , '
                                          ,' avirethor, aviprvent, avioccdat   , '
                                          ,' ofnnom   , dddcod   , telnum      , '
                                          ,' cttdddcod, ctttelnum, avirsrgrttip, '
                                          ,' slcemp   , slcsuccod, slcmat      , '
                                          ,' slccctcod, cdtoutflg, vclloctip   , '
                                          ,' locrspcpfnum, locrspcpfdig, lcvsinavsflg,'
                                          ,' smsenvdddnum, smsenvcelnum ) '
                                       ,' = (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                          ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
                  ,' where atdsrvnum = ? '
                    ,' and atdsrvano = ? '

   prepare p_cts15m00_005 from l_sqlstmt

   let l_sqlstmt = 'insert into datmavisrent (atdsrvnum, atdsrvano, lcvcod   , avivclcod, aviestcod, '
                                           ,' avivclvlr, avialgmtv, avidiaqtd, avilocnom, aviretdat, '
                                           ,' avirethor, aviprvent, locsegvlr, vclloctip, avioccdat, '
                                           ,' ofnnom   , dddcod   , telnum   , cttdddcod, ctttelnum, '
                                           ,' avirsrgrttip, slcemp, slcsuccod, slcmat, slccctcod, '
                                           ,' cdtoutflg, locrspcpfnum, locrspcpfdig, lcvsinavsflg, '
                                           ,' smsenvdddnum,smsenvcelnum ) '
                                   ,' values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '
                                           ,' ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '

   prepare p_cts15m00_006 from l_sqlstmt

   let l_sqlstmt = " select cpodes ",
                   " from iddkdominio ",
                   " where cponom = 'carroextra' "

   prepare p_cts15m00_007 from l_sqlstmt
   declare c_cts15m00_005 cursor for p_cts15m00_007

   ### Alberto
   let l_sqlstmt = " select cpodes ",
                   " from iddkdominio ",
                   " where cponom = 'carroextratmp' "

   prepare p_cts15m00_008 from l_sqlstmt
   declare c_cts15m00_006 cursor for p_cts15m00_008
   ### Alberto

   let l_sqlstmt = " select funnom ",
                   " from isskfunc ",
                   " where funmat = ? "

   prepare p_cts15m00_009 from l_sqlstmt
   declare c_cts15m00_007 cursor for p_cts15m00_009

   let l_sqlstmt = " select c24srvdsc, "   ,
                   " c24txtseq"            ,
                   " from datmservhist "   ,
                   " where atdsrvnum = ?"  ,
                   " and atdsrvano = ? "   ,
                   "order by c24txtseq "  ## removi o desc Alberto - 23/11/2007


   prepare p_cts15m00_010 from l_sqlstmt
   declare c_cts15m00_008 cursor for p_cts15m00_010

   let l_sqlstmt = " select  atdsrvorg " ,
                   " from datmservico "  ,
                   " where atdsrvnum = ?",
                   " and atdsrvano = ? "


   prepare p_cts15m00_011 from l_sqlstmt
   declare c_cts15m00_009 cursor for p_cts15m00_011

   let l_sqlstmt = " select max(dctnumseq) from abbmclaus ",
                   " where succod =  ? ",
                   " and   aplnumdig =  ? ",
                   " and   itmnumdig =  ? ",
                   " and   (clscod[1,2] in ('26','80') or ",
                   "        clscod in ('033','33R','044','44R','046', ",
                   "                   '46R','047','47R','048','48R', '034','035'))"

   prepare p_cts15m00_012 from l_sqlstmt
   declare c_cts15m00_010 cursor for p_cts15m00_012
   let l_sqlstmt = " select max(dctnumseq) from abbmclaus ",
                   " where succod =  ? ",
                   " and   aplnumdig =  ? ",
                   " and   itmnumdig =  ? ",
                   " and   clscod in ('033','33R','044','44R','046', ",
                   " '46R','047','47R','048','48R', '034','035')"
   prepare p_cts15m00_044 from l_sqlstmt
   declare c_cts15m00_044 cursor for p_cts15m00_044

   let l_sqlstmt = " select clscod from abbmclaus ",
                   " where succod = ? ",
                   " and   aplnumdig = ? ",
                   " and   itmnumdig = ? ",
                   " and   dctnumseq = ? "
   let m_prep_sql = true

   prepare p_cts15m00_013 from l_sqlstmt
   declare c_cts15m00_011 cursor for p_cts15m00_013

   let l_sqlstmt = 'select avialgmtv     '
                  ,'  from datmavisrent  '
                  ,' where atdsrvnum = ? '
                  ,'   and atdsrvano = ? '

   prepare p_cts15m00_014 from l_sqlstmt
   declare c_cts15m00_012 cursor for p_cts15m00_014

   let l_sqlstmt = " select b.atdsrvnum ,b.atdsrvano     "
                  ,"   from datrservapol a,datmservico b "
                  ,"       ,datmligacao c                "
                  ,"  where a.succod = ?                 "
                  ,"    and a.ramcod in (31,531)         "
                  ,"    and a.aplnumdig = ?              "
                  ,"    and a.itmnumdig = ?              "
                  ,"    and a.edsnumref >= 0             "
                  ,"    and b.atdsrvnum = a.atdsrvnum    "
                  ,"    and b.atdsrvano = a.atdsrvano    "
                  ,"    and b.atdsrvorg   = 8            "
                  ,"    and b.atdsrvnum   = c.atdsrvnum  "
                  ,"    and b.atdsrvano   = c.atdsrvano  "
                  ,"    and c.c24astcod   = 'H10'        "
   prepare p_cts15m00_015 from l_sqlstmt
   declare c_cts15m00_013 cursor for p_cts15m00_015

   let l_sqlstmt = " select aviprvent "
                  ,"   from datmavisrent  "
                  ,"   where atdsrvnum = ? "
                  ,"    and atdsrvano = ? "
   prepare p_cts15m00_016 from l_sqlstmt
   declare c_cts15m00_014 cursor for p_cts15m00_016

   let l_sqlstmt = ' select clscod from datrastcls ',
                   '  where c24astcod = ? ',
                   '  and ramcod = ? ',
                   '  and clscod = ? '
   prepare pcts15m00031 from l_sqlstmt
   declare ccts15m00031 cursor for pcts15m00031


   let l_sqlstmt = 'select clscod ',
                   ' from abbmclaus ',
                   ' where succod  = ? ',
                   ' and aplnumdig = ? ',
                   ' and itmnumdig = ? ',
                   ' and dctnumseq = ? '
   prepare pcts15m00032 from l_sqlstmt
   declare ccts15m00032 cursor for pcts15m00032

   let l_sqlstmt = ' select clalclcod,viginc',
                   ' from abbmdoc  ',
                   ' where succod    =  ? ',
                   '  and  aplnumdig =  ? ',
                   '  and  itmnumdig =  ? ',
                   '  and  dctnumseq =  ? '
   prepare pcts15m00033 from l_sqlstmt
   declare ccts15m00033 cursor for pcts15m00033

   let l_sqlstmt = 'select edstip,edstxt,viginc,vigfnl ',
                   '  from abbmdoc  ',
                   '  where succod    =  ? ',
                   '  and  aplnumdig =  ? ',
                   '  and  itmnumdig =  ? '
   prepare pcts15m00034 from l_sqlstmt
   declare ccts15m00034 cursor for pcts15m00034

   let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum ',
                   ' from datmrsvvcl ',
                   ' where ',
                   ' atdsrvnum = ? ',
                   ' and atdsrvano = ? '

   prepare pcts15m00035 from l_sqlstmt
   declare ccts15m00035 cursor for pcts15m00035

   let l_sqlstmt = 'select lcvextcod,endufd,endcid ',
                   ' from datkavislocal ',
                   ' where ',
                   ' lcvcod    = ?   and ',
                   ' aviestcod = ? '

   prepare pcts15m00036 from l_sqlstmt
   declare ccts15m00036 cursor for pcts15m00036

   let l_sqlstmt = 'select lcvcod,aviestcod,aviretdat'
                   ,' , avirethor,aviprvent,avirsrgrttip, cdtoutflg,avialgmtv '
                   ,' from datmavisrent '
                   ,' where atdsrvnum = ? '
                   ,' and atdsrvano = ? '

   prepare pcts15m00037 from l_sqlstmt
   declare ccts15m00037 cursor for pcts15m00037

   let l_sqlstmt = ' select sum(diaqtd) from datmrsrsrvrsm ',
                   ' where atdsrvnum = ? ',
                   ' and atdsrvano =  ? ',
                   ' and empcod > 0 ',
                   ' and aviproseq in (select aviproseq from datmprorrog',
                                      ' where atdsrvnum = ? ',
                                      ' and atdsrvano = ? ',
                                      ' and aviprostt = ?) '

   prepare pcts15m00040 from l_sqlstmt
   declare ccts15m00040 cursor for pcts15m00040

   let l_sqlstmt = ' select lcvvcldiavlr, lcvvclsgrvlr ',
                   ' from datklocaldiaria ',
                  ' where lcvcod       = ? ',
                    ' and avivclcod    = ? ',
                    ' and lcvlojtip    = ? ',
                    ' and lcvregprccod = ? ',
                    ' and ? between  datklocaldiaria.viginc ',
                    ' and            datklocaldiaria.vigfnl ',
                    ' and 1          between  datklocaldiaria.fxainc ',
                    ' and            datklocaldiaria.vigfnl '

   prepare pcts15m00039 from l_sqlstmt
   declare ccts15m00039 cursor for pcts15m00039

   let l_sqlstmt = 'select aviretdat,avirethor from datmavisrent ',
                   ' where atdsrvnum = ? ',
                   'and atdsrvano =  ? '
    prepare pcts15m00041 from l_sqlstmt
    declare ccts15m00041 cursor for pcts15m00041

    let l_sqlstmt = 'select smsenvdddnum,smsenvcelnum  from datmavisrent ',
                   ' where atdsrvnum = ? ',
                   'and atdsrvano =  ? '
    prepare pcts15m00042 from l_sqlstmt
    declare ccts15m00042 cursor for pcts15m00042

    let l_sqlstmt = ' select count(*)        ',
                    ' from datmvclrsvitf     ',
                    ' where atdsrvnum = ?    ',
                    ' and atdsrvano =  ?     ',
                    ' and itftipcod = 1      ',
                    ' and itfsttcod in (1,2) '
     prepare pcts15m00043 from l_sqlstmt
     declare ccts15m00043 cursor for pcts15m00043

     let l_sqlstmt = " select b.atdsrvnum ,b.atdsrvano     "
                    ,"   from datrligapol a,datmservico b  "
                    ,"       ,datmligacao c,datmavisrent d "
                    ,"  where a.succod = ?                 "
                    ,"    and a.ramcod = ?                 "
                    ,"    and a.aplnumdig = ?              "
                    ,"    and a.itmnumdig = ?              "
                    ,"    and a.edsnumref >= 0             "
                    ,"    and a.lignum    = c.lignum       "
                    ,"    and b.atdsrvnum   = c.atdsrvnum  "
                    ,"    and b.atdsrvano   = c.atdsrvano  "
                    ,"    and b.atdsrvnum   = d.atdsrvnum  "
                    ,"    and b.atdsrvano   = d.atdsrvano  "
                    ,"    and b.atdsrvorg   = 8            "
                    ,"    and c.c24astcod   = ?            "
                    ,"    and d.avialgmtv   = ?            "
     prepare pcts15m00044 from l_sqlstmt
     declare ccts15m00044 cursor for pcts15m00044


     let l_sqlstmt = " select aviprvent,   "
                    ,"        aviretdat,   "
                    ,"        lcvcod       "
                    ," from datmavisrent   "
                    ," where atdsrvnum = ? "
                    ," and atdsrvano   = ? "
     prepare pcts15m00045 from l_sqlstmt
     declare ccts15m00045 cursor for pcts15m00045


     let l_sqlstmt = " select vcleftretdat, "
                    ,"        vcleftdvldat, "
                    ,"        vcleftretdat, "
                    ,"        vcleftdvldat, "
                    ,"        atzdianum     "
                    ," from datmrsvvcl      "
                    ," where atdsrvnum = ?  "
                    ," and atdsrvano   = ?  "
     prepare pcts15m00046 from l_sqlstmt
     declare ccts15m00046 cursor for pcts15m00046
     	
     let l_sqlstmt = " select lcvextcod, aviestnom  ",              	
                     " from datkavislocal           ",
                     " where lcvcod  = ?            ",
                     " and aviestcod = ?            "
     prepare pcts15m00047 from l_sqlstmt         
     declare ccts15m00047 cursor for pcts15m00047
     	
     
     let m_prep = true

end function  #fim psi175552

#--------------------------------------------------------------------
 function cts15m00()
#--------------------------------------------------------------------

 define ws            record
    hoje              char (10),
    vclcordes         char (12),
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    confirma          char (01),
    grvflg            smallint
 end record

 define w_ctgtrfcod   like abbmcasco. ctgtrfcod
       ,w_histerr     smallint                    #osf32867 - Paula
       ,w_c24srvdsc   like datmservhist.c24srvdsc #osf32867 - Paula

 define l_prporg      like abamdoc.prporgpcp
       ,l_prpnumdig   like abamdoc.prpnumpcp

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_f7        char(10),
        l_fs        char(80),
        l_acao_ant  char(3)


 initialize  ws.*           to null
 initialize  slv_segurado.* to null
 initialize  slv_terceiro.* to null
 initialize  m_cts15m00b.*  to null
 initialize  m_cts15m00b1   to null
 initialize  m_reserva.*    to null
 initialize  m_ctd31.*      to null
 initialize  m_tem_33_26    to null
 initialize  a_cts15m00     to null

 let  m_prorrog       = false
 let m_cts15m00b.flag = 1
 let int_flag         = false
 let l_f7             = null
 let l_fs             = null
 let m_erro_msg       = null
 let m_alt_motivo     = false
 let g_nova.delivery  = false
 let g_nova.reversao  = "N"

 open window cts15m00 at 04,02 with form "cts15m00"
                      attribute(form line 1, message line last -1, comment line last)

 if m_prep_sql is null or m_prep_sql <> true then #psi175552
    call cts15m00_prepara()
 end if #fim psi175552

 if g_documento.acao = 'SIN' then
    message '(F5) Espelho    (F6) Historico'
 else
    message '(F1)Help(F3)Dep(F4)Func(F5)Esp(F6)Hist(F7)Fax(F8)Retira(F9)Conclui(F10)Dest'
 end if

 initialize d_cts15m00.*    to null
 initialize m_cts15ant.*    to null
 initialize w_cts15m00.*    to null
 initialize ws.*            to null
 let l_acao_ant = g_documento.acao

  call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
 let ws.hoje           = l_data
 let w_cts15m00.ano    = ws.hoje[9,10]
 let w_cts15m00.atddat = l_data
 let w_cts15m00.atdhor = l_hora2

 let m_cts15m00b1[1].corsus = "P5005J"
 let m_cts15m00b1[2].corsus = "X5005J"
 let m_cts15m00b1[3].corsus = "M5005J"
 let m_cts15m00b1[4].corsus = "H5005J"
 let m_cts15m00b1[5].corsus = "G5005J"
 let m_reenvio = false

 let m_idx = null
 let g_documento.atdsrvorg = 8
 let m_flag_alt  = false

#--------------------------------------------------------------------
# Nome do convenio
#--------------------------------------------------------------------

 select cpodes
   into d_cts15m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = g_documento.ligcvntip

 let d_cts15m00.frmflg = "N"

 #osf32867 - Paula
 let d_cts15m00.c24astcod = g_documento.c24astcod
 #osf32867 - Paula

 if g_documento.atdsrvnum is not null  then


    if g_documento.acao = "CAN"  then
       let m_reenvio = true
    end if
    call consulta_cts15m00()
    if m_erro then
       let int_flag = false
       close window cts15m00
       return
    end if

    # ligia - Fornax - 01/06/11
    if g_documento.acao  <> 'SIN' then

       let m_f7 = false
       let l_f7 = '(F7)Fax'
       if d_cts15m00.acntip = 3 then
          let l_f7 = '(F7)OnLine'
       end if

       let l_fs = '(F1)Help(F3)Dep/Fun(F4)Func(F5)Esp(F6)Hist', l_f7 clipped, '(F8)Retira(F9)Conclui(F10)Dest'

       message l_fs

    end if

    display by name d_cts15m00. servico    ,
                    d_cts15m00.c24solnom   ,
                    d_cts15m00.nom         ,
                    d_cts15m00.doctxt      ,
                    d_cts15m00.corsus      ,
                    d_cts15m00.cornom      ,
                    d_cts15m00.cvnnom      ,
                    d_cts15m00.vclcoddig   ,
                    d_cts15m00.vcldes      ,
                    d_cts15m00.vclanomdl   ,
                    d_cts15m00.vcllicnum   ,
                    d_cts15m00.vclloctip   ,
                    d_cts15m00.vcllocdes   ,
                    d_cts15m00.c24astcod   ,
                    d_cts15m00.c24astdes   ,
                    d_cts15m00.avilocnom   ,
                    d_cts15m00.avialgmtv   ,
                    d_cts15m00.lcvsinavsflg,
                    d_cts15m00.avimtvdes   ,
                    d_cts15m00.lcvcod      ,
                    d_cts15m00.lcvnom      ,
                    d_cts15m00.lcvextcod   ,
                    d_cts15m00.aviestnom   ,
                    d_cts15m00.cdtoutflg   ,
                    d_cts15m00.cdtsegtaxvlr,
                    d_cts15m00.avivclcod   ,
                    d_cts15m00.avivclgrp   ,
                    d_cts15m00.avivcldes   ,
                    d_cts15m00.vcldiavlr   ,
                    d_cts15m00.frqvlr      ,      #PSI 198390
                    d_cts15m00.isnvlr      ,      #PSI 198390
                    d_cts15m00.rduvlr      ,      #PSI 198390
                    d_cts15m00.cndtxt      ,
                    d_cts15m00.prgtxt      ,
                    d_cts15m00.frmflg      ,
                    d_cts15m00.aviproflg   ,
                    d_cts15m00.cttdddcod   ,
                    d_cts15m00.ctttelnum   ,
                    d_cts15m00.atdlibflg   ,
                    d_cts15m00.atdlibtxt   ,
                    #d_cts15m00.cartao      ,#d_cts15m00.cauchqflg   ,
                    d_cts15m00.locrspcpfnum,
                    d_cts15m00.locrspcpfdig,
                    d_cts15m00.smsenvdddnum,
                    d_cts15m00.smsenvcelnum,
                    d_cts15m00.garantia    ,
                    d_cts15m00.flgarantia



    display by name d_cts15m00.c24solnom attribute (reverse)
    display by name d_cts15m00.cvnnom    attribute (reverse)

    if d_cts15m00.prgtxt is not null  then
       display by name d_cts15m00.prgtxt  attribute (reverse)
    end if

    if w_cts15m00.atdfnlflg = "S"  then
       error " ATENCAO! Servico ja' acionado!"
    end if

    let l_acao_ant = g_documento.acao
    call modifica_cts15m00() returning ws.grvflg

    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2
    if g_documento.acao is not null and
       g_documento.acao <> 'SIN'    then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat, l_data, l_hora2)
       if g_documento.acao is null then
          let g_documento.acao = l_acao_ant
       end if
       let g_rec_his = true
    end if

    if g_documento.atdsrvnum is not null and
       d_cts15m00.lcvcod     is not null and
       d_cts15m00.aviestcod  is not null and
       d_cts15m00.atdlibflg  <> "N"      then
       call cts15m01(g_documento.atdsrvnum
                    ,g_documento.atdsrvano
                    ,d_cts15m00.lcvcod
                    ,d_cts15m00.aviestcod
                    ,d_cts15m00.avialgmtv)
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then
       let d_cts15m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                        " ", g_documento.ramcod    using "##&&",
                                        " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts15m00.nom      ,
                      d_cts15m00.corsus   ,
                      d_cts15m00.cornom   ,
                      d_cts15m00.cvnnom   ,
                      d_cts15m00.vclcoddig,
                      d_cts15m00.vcldes   ,
                      d_cts15m00.vclanomdl,
                      d_cts15m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      ws.vclcordes
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       call figrc072_setTratarIsolamento()        --> 223689
       call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts15m00.nom      ,
                      d_cts15m00.corsus   ,
                      d_cts15m00.cornom   ,
                      d_cts15m00.cvnnom   ,
                      d_cts15m00.vclcoddig,
                      d_cts15m00.vcldes   ,
                      d_cts15m00.vclanomdl,
                      d_cts15m00.vcllicnum,
                      ws.vclcordes
      if g_isoAuto.sqlCodErr <> 0 then --> 223689
         error "Fun��o cts05g04 indisponivel no momento! Avise a Informatica !" sleep 2
         close window cts15m00
         return
      end if    --> 223689

       let d_cts15m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts15m00.doctxt = "Cartao..: ", g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts15m00.nom      ,
                      d_cts15m00.corsus   ,
                      d_cts15m00.cornom   ,
                      d_cts15m00.cvnnom   ,
                      d_cts15m00.vclcoddig,
                      d_cts15m00.vcldes   ,
                      d_cts15m00.vclanomdl,
                      d_cts15m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      ws.vclcordes
    end if

    let d_cts15m00.c24astcod   = g_documento.c24astcod
    let d_cts15m00.c24solnom   = g_documento.solnom
    let   d_cts15m00.garantia = 'Garantia:'

    call c24geral8(d_cts15m00.c24astcod) returning d_cts15m00.c24astdes

    display by name d_cts15m00. servico    ,
                    d_cts15m00.c24solnom   ,
                    d_cts15m00.nom         ,
                    d_cts15m00.doctxt      ,
                    d_cts15m00.corsus      ,
                    d_cts15m00.cornom      ,
                    d_cts15m00.cvnnom      ,
                    d_cts15m00.vclcoddig   ,
                    d_cts15m00.vcldes      ,
                    d_cts15m00.vclanomdl   ,
                    d_cts15m00.vcllicnum   ,
                    d_cts15m00.vclloctip   ,
                    d_cts15m00.vcllocdes   ,
                    d_cts15m00.c24astcod   ,
                    d_cts15m00.c24astdes   ,
                    d_cts15m00.avilocnom   ,
                    d_cts15m00.avialgmtv   ,
                    d_cts15m00.avimtvdes   ,
                    d_cts15m00.lcvcod      ,
                    d_cts15m00.lcvnom      ,
                    d_cts15m00.lcvextcod   ,
                    d_cts15m00.aviestnom   ,
                    d_cts15m00.cdtoutflg   ,
                    d_cts15m00.cdtsegtaxvlr,
                    d_cts15m00.avivclcod   ,
                    d_cts15m00.avivclgrp   ,
                    d_cts15m00.avivcldes   ,
                    d_cts15m00.vcldiavlr   ,
                    d_cts15m00.frqvlr      ,      #PSI 198390
                    d_cts15m00.isnvlr      ,      #PSI 198390
                    d_cts15m00.rduvlr      ,      #PSI 198390
                    d_cts15m00.cndtxt      ,
                    d_cts15m00.prgtxt      ,
                    d_cts15m00.frmflg      ,
                    d_cts15m00.aviproflg   ,
                    d_cts15m00.cttdddcod   ,
                    d_cts15m00.ctttelnum   ,
                    d_cts15m00.atdlibflg   ,
                    d_cts15m00.atdlibtxt   ,
                    #d_cts15m00.cartao      ,#d_cts15m00.cauchqflg   ,
                    d_cts15m00.locrspcpfnum,
                    d_cts15m00.locrspcpfdig,
                    d_cts15m00.smsenvdddnum,
                    d_cts15m00.smsenvcelnum,
                    d_cts15m00.garantia,
                    d_cts15m00.flgarantia

    display by name d_cts15m00.c24solnom attribute (reverse)
    display by name d_cts15m00.cvnnom    attribute (reverse)


    let m_clcdat = null

    ##psi 217956
    if (g_documento.ramcod = 31 or g_documento.ramcod =  531) and
        g_documento.succod is not null and
        g_documento.aplnumdig is not null and
        g_documento.itmnumdig is not null and
        g_documento.edsnumref is not null then

       open c_cts15m00_003 using g_documento.succod
                             , g_documento.aplnumdig
                             , g_documento.edsnumref -- CT 212857
       whenever error continue
       fetch c_cts15m00_003 into l_prporg, l_prpnumdig
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error "Erro ", sqlca.sqlcode using "<<<<<&"
                  ," Proposta nao encontrada na tab. abamdoc "
          else
             error "Erro ", sqlca.sqlcode using "<<<<<&"
                  ," no acesso a tabela abamdoc ."
          end if
          close window cts15m00
          return
       end if

       call figrc072_setTratarIsolamento()        --> 223689
       call faemc603_proposta(l_prporg, l_prpnumdig)
       returning m_clcdat
       if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Fun��o faemc603 indisponivel no momento ! Avise a Informatica !" sleep 2
           close window cts15m00
           return
        end if        -- > 223689

       if m_clcdat is null then
          error "Data nao encontrada na funcao ogsrc021."
          close window cts15m00
          return
       end if
    end if

    # -- OSF 30970 - Fabrica de Software, Katiucia -- #
    if m_clcdat < "01/07/2003" and
       m_clcdat is not null    and
       d_cts15m00.c24astcod = 'H10' then

       let w_ctgtrfcod = ''
       select ctgtrfcod into w_ctgtrfcod from abbmcasco
              where succod    = g_documento.succod     and
                    aplnumdig = g_documento.aplnumdig  and
                    itmnumdig = g_documento.itmnumdig  and
                    dctnumseq = g_funapol.autsitatu

       if sqlca.sqlcode = notfound then

          select ctgtrfcod into w_ctgtrfcod from abbmdm
                 where succod    = g_documento.succod     and
                       aplnumdig = g_documento.aplnumdig  and
                       itmnumdig = g_documento.itmnumdig  and
                       dctnumseq = g_funapol.dmtsitatu

           if sqlca.sqlcode = notfound then

              select ctgtrfcod into w_ctgtrfcod from abbmdp
                     where succod    = g_documento.succod     and
                           aplnumdig = g_documento.aplnumdig  and
                           itmnumdig = g_documento.itmnumdig  and
                           dctnumseq = g_funapol.dmtsitatu
           end if
       end if

       if w_ctgtrfcod = 10 or w_ctgtrfcod = 14 or w_ctgtrfcod = 16 or
          w_ctgtrfcod = 22 or w_ctgtrfcod = 80 then

          let m_cts08g01 = null
          let m_cts08g01 = cts08g01("A"
                                   ,"N"
                                   ,""
                                   ,"DESCONTO NA FRANQUIA OU CARRO EXTRA"
                                   ,"POR TEMPO INDETERMINADO."
                                   ,"")
       end if
    end if
    #---------------------------------> PSI 176087

    call inclui_cts15m00() returning ws.grvflg

    if ws.grvflg = true  then
       #osf32867 - Paula
       if d_cts15m00.c24astcod = 'H11'       and
          d_cts15m00.avialgmtv =  6          and
          slv_terceiro.aplnumdig is not null and
          slv_terceiro.aplnumdig <> 0        then
          let w_c24srvdsc ="Apl.Terc.Seg ", slv_terceiro.succod using "<<<&&", " " #"&&"," " projeto succod
                           ,slv_terceiro.ramcod using "&&&&"," "
                           ,slv_terceiro.aplnumdig using "<<<<<<<&&"

          call cts40g03_data_hora_banco(2)
                returning l_data, l_hora2
          call cts10g02_historico(w_cts15m00.atdsrvnum
                                 ,w_cts15m00.atdsrvano
                                 ,l_data
                                 ,l_hora2
                                 ,g_issk.funmat
                                 ,w_c24srvdsc
                                 ,""
                                 ,""
                                 ,""
                                 ,"")
               returning w_histerr
       end if
       #osf32867 - Paula

       call cts10n00(w_cts15m00.atdsrvnum, w_cts15m00.atdsrvano,
                     w_cts15m00.funmat   , w_cts15m00.atddat   ,
                     w_cts15m00.atdhor)

 #--------------------------------------------------------------#
 #-Roberto- Gravo as informacoes da Liberacao de Carro Extra
 #          por motivo particular e disparo e-mail
 #          para os funcionarios envolvidos no processo
 #--------------------------------------------------------------#

       if d_cts15m00.c24astcod = "H10" and
          d_cts15m00.avialgmtv = 5     then

              if d_cts15m00.lcvsinavsflg = 'S' then
                 call cts15m00_env_email_tmp( w_cts15m00.atdsrvnum
                                             ,w_cts15m00.atdsrvano )
              end if

              if d_cts15m00.doctxt is null then

                  for m_idx = 1 to 5

                   if g_documento.corsus     = m_cts15m00b1[m_idx].corsus or
                      m_cts15m00b.corsus_ant = m_cts15m00b1[m_idx].corsus or
                      d_cts15m00.corsus      = m_cts15m00b1[m_idx].corsus or
                      g_documento.funmat     is not null                  or
                      g_documento.cgccpfnum  is not null                  or
                      g_documento.ctttel     is not null                  then

                        call cts15m00_env_email(w_cts15m00.atdsrvnum
                                               ,w_cts15m00.atdsrvano )

                      exit for
                   end if
                  end for
              else

                   for m_idx = 1 to 5
                       if d_cts15m00.corsus      = m_cts15m00b1[m_idx].corsus or
                          m_cts15m00b.corsus_ant = m_cts15m00b1[m_idx].corsus or
                          d_cts15m00.corsus is null                      then
                          call cts15m00_env_email(w_cts15m00.atdsrvnum
                                                 ,w_cts15m00.atdsrvano)
                          exit for
                       end if
                   end for
              end if
       end if

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       if w_cts15m00.atdfnlflg = "N"  then
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts15m00.atdsrvnum
                             and atdsrvano = w_cts15m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts15m00.atdsrvnum,w_cts15m00.atdsrvano)
          end if
       end if
    end if
 end if

 if w_cts15m00.atdsrvnum is null then
    let w_cts15m00.atdsrvnum = g_documento.atdsrvnum
    let w_cts15m00.atdsrvano = g_documento.atdsrvano
 end if

 if m_flag_alt = true then
    call cts15m00_acionamento(w_cts15m00.atdsrvnum, w_cts15m00.atdsrvano
                             ,d_cts15m00.lcvcod, d_cts15m00.aviestcod,0,'',
                              w_cts15m00.procan)
 end if


 close window cts15m00

end function  ###  cts15m00

#--------------------------------------------------------------------
 function consulta_cts15m00()
#--------------------------------------------------------------------

 define ws           record
    avivclmdl        like datkavisveic.avivclmdl ,
    avivcldes        char (65)                   ,
    funnom           char (15)                   ,
    dptsgl           like isskfunc.dptsgl        ,
    ligcvntip        like datmligacao.ligcvntip  ,
    atddat           like datmservico.atddat     ,
    atdhor           like datmservico.atdhor     ,
    atdlibdat        like datmservico.atdlibdat  ,
    atdlibhor        like datmservico.atdlibhor  ,
    viginc           like abbmclaus.viginc       ,
    vigfnl           like abbmclaus.vigfnl       ,
    atdsrvorg        like datmservico.atdsrvorg  ,
    succod            like datrservapol.succod   ,
    ramcod            like datrservapol.ramcod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    edsnumref         like datrservapol.edsnumref,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig,
    fcapcorg          like datrligpac.fcapacorg,
    fcapacnum         like datrligpac.fcapacnum,
    ciaempcod         like datmservico.ciaempcod,     #PSI 205206
    confirma          char (01)                 ,
    codigosql         integer           
 end record

 define lr_ret        record
        erro          smallint,
        msg           char(80)
 end record

 define ws_avirsrgrttip dec(1,0)
 define l_exibe smallint
 define l_aux_avialgmtv   like datmavisrent.avialgmtv

        let  ws_avirsrgrttip  =  null
        let  l_aux_avialgmtv  =  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom      ,
        vclcoddig, vcldes   ,
        vclanomdl, vcllicnum,
        corsus   , cornom   ,
        funmat   ,
        atddat   , atdhor   ,
        atdfnlflg, atdlibflg,
        atdlibdat, atdlibhor,
        atdsrvorg,
        ciaempcod                 #PSI 205206
   into d_cts15m00.nom      ,
        d_cts15m00.vclcoddig, d_cts15m00.vcldes   ,
        d_cts15m00.vclanomdl, d_cts15m00.vcllicnum,
        d_cts15m00.corsus   , d_cts15m00.cornom   ,
        w_cts15m00.funmat   ,
        ws.atddat           , ws.atdhor           ,
        w_cts15m00.atdfnlflg, d_cts15m00.atdlibflg,
        ws.atdlibdat        , ws.atdlibhor        ,
        ws.atdsrvorg,
        ws.ciaempcod                 #PSI 205206
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao foi encontrado. AVISE A INFORMATICA !"
    return
 end if

 let m_reenvio = true

 #PSI 205206 - caso global de empresa n�o est� setada (entrar no servico pelo r�dio)
 # assumir a empresa lida para a global
 if g_documento.ciaempcod is null then
    let g_documento.ciaempcod = ws.ciaempcod
 end if

 open c_cts15m00_004 using g_documento.atdsrvnum
                        ,g_documento.atdsrvano

 whenever error continue
 fetch c_cts15m00_004 into d_cts15m00.lcvcod      , d_cts15m00.avivclcod, d_cts15m00.avivclvlr
                        ,d_cts15m00.aviestcod   , d_cts15m00.avialgmtv, d_cts15m00.avilocnom
                        ,w_cts15m00.aviretdat   , w_cts15m00.avirethor, w_cts15m00.aviprvent
                        ,d_cts15m00.locsegvlr   , d_cts15m00.vclloctip, w_cts15m00.avioccdat
                        ,w_cts15m00.ofnnom      , w_cts15m00.ofndddcod, w_cts15m00.ofntelnum
                        ,d_cts15m00.cttdddcod   , d_cts15m00.ctttelnum, ws_avirsrgrttip
                        ,w_cts15m00.slcemp      , w_cts15m00.slcsuccod, w_cts15m00.slcmat
                        ,w_cts15m00.slccctcod   , d_cts15m00.cdtoutflg, d_cts15m00.locrspcpfnum
                        ,d_cts15m00.locrspcpfdig, d_cts15m00.lcvsinavsflg
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT c_cts15m00_004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'CTS15M00 / consulta_cts15m00() / ',g_documento.atdsrvnum,' / '
                                                ,g_documento.atdsrvano sleep 1
    end if
    let m_erro = true
    return
 end if

 let m_cts15m04.aviretdat = w_cts15m00.aviretdat
 let m_cts15m04.avirethor = w_cts15m00.avirethor
 let m_cts15m04.aviprvent = w_cts15m00.aviprvent
 if d_cts15m00.cdtoutflg is null then
    let d_cts15m00.cdtoutflg = "N"
 end if



    let m_opcao = ws_avirsrgrttip
    case ws_avirsrgrttip

       when 1

        let d_cts15m00.cauchqflg = "N"
        let d_cts15m00.cartao    = "S"
        let d_cts15m00.flgarantia = "S"
        let d_cts15m00.garantia = 'Cartao de Credito'


       when 2
          let d_cts15m00.cauchqflg = "S"
          let d_cts15m00.cartao    = "N"
          let d_cts15m00.flgarantia = "S"
          let d_cts15m00.garantia = 'Cheque Caucao'

       when 3
          let d_cts15m00.cauchqflg = "N"
          let d_cts15m00.cartao    = "N"
          let d_cts15m00.flgarantia = "S"
          let d_cts15m00.garantia = 'Isencao de Garantia'

    end case


 case d_cts15m00.vclloctip
    when 1    let d_cts15m00.vcllocdes = "SEGURADO"
    when 2    let d_cts15m00.vcllocdes = "CORRETOR"
    when 3    let d_cts15m00.vcllocdes = "DEPTOS. "
    when 4    let d_cts15m00.vcllocdes = "FUNC.   "
    otherwise let d_cts15m00.vcllocdes = "NAO PREV"
 end case

 if d_cts15m00.locsegvlr  is null    then
    let d_cts15m00.locsegvlr = 0.00
 end if
 let d_cts15m00.vcldiavlr = d_cts15m00.avivclvlr + d_cts15m00.locsegvlr

#--------------------------------------------------------------------
# Veiculo / Loja
#--------------------------------------------------------------------

 initialize ws.avivclmdl, ws.avivcldes  to null

 select avivclmdl, avivcldes, avivclgrp,
        frqvlr, isnvlr, rduvlr                  #PSI 198390
   into ws.avivclmdl,
        ws.avivcldes,
        d_cts15m00.avivclgrp,
        d_cts15m00.frqvlr,                      #PSI 198390
        d_cts15m00.isnvlr,                      #PSI 198390
        d_cts15m00.rduvlr                       #PSI 198390
   from datkavisveic
  where lcvcod    = d_cts15m00.lcvcod     and
        avivclcod = d_cts15m00.avivclcod

 if sqlca.sqlcode = NOTFOUND   then
    let d_cts15m00.avivcldes = "VEICULO/DISCRIMINACAO NAO ENCONTRADOS"
 else
    if ws.avivcldes is not null  then
       let ws.avivcldes = "(", ws.avivcldes clipped, ")"
    end if
    let d_cts15m00.avivcldes = ws.avivclmdl clipped, " ",
                               ws.avivcldes clipped
 end if

 select lcvnom, cdtsegtaxvlr, acntip
   into d_cts15m00.lcvnom, d_cts15m00.cdtsegtaxvlr, d_cts15m00.acntip
   from datklocadora
  where lcvcod = d_cts15m00.lcvcod

 if sqlca.sqlcode = NOTFOUND then
    error " Dados da LOCADORA nao encontrados. AVISE A INFORMATICA!"
    return
 else
    if sqlca.sqlcode < 0 then
       error " Erro (", sqlca.sqlcode, ") na localizacao dos dados da LOCADORA. AVISE A INFORMATICA!"
       return
    end if
 end if

 #PSI 198390 - caso nao tenha 2 condutor nao exibir valor da taxa
 if d_cts15m00.cdtoutflg = 'N' then
    let d_cts15m00.cdtsegtaxvlr = null
 end if
        
 call cts15m00_descricao_loja(d_cts15m00.lcvcod    ,   
                              d_cts15m00.aviestcod )   
 returning d_cts15m00.lcvextcod,                          
           d_cts15m00.aviestnom                           
      
        
 if sqlca.sqlcode = NOTFOUND then
    error " Dados da LOJA nao encontrados. AVISE A INFORMATICA!"
    return
 else
    if sqlca.sqlcode < 0 then
       error " Erro (", sqlca.sqlcode, ") na localizacao dos dados da LOJA. AVISE A INFORMATICA!"
       return
    end if
 end if

#--------------------------------------------------------------------
# Dados da ligacao / convenio
#--------------------------------------------------------------------

 let w_cts15m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts15m00.lignum)
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

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts15m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "##&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts15m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 select c24astcod, ligcvntip,
        c24solnom
   into d_cts15m00.c24astcod,
        ws.ligcvntip        ,
        d_cts15m00.c24solnom
   from datmligacao
  where lignum = w_cts15m00.lignum

 let g_documento.ligcvntip = ws.ligcvntip
 let g_documento.c24astcod = d_cts15m00.c24astcod #ligia 25/05/11

 select lignum
   from datmligfrm
  where lignum = w_cts15m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts15m00.frmflg = "N"
 else
    let d_cts15m00.frmflg = "S"
 end if

 select cpodes
   into d_cts15m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = ws.ligcvntip

 call c24geral8(d_cts15m00.c24astcod)
      returning d_cts15m00.c24astdes

 let d_cts15m00.servico = F_FUNDIGIT_INTTOSTR(ws.atdsrvorg         ,2),
                     "/", F_FUNDIGIT_INTTOSTR(g_documento.atdsrvnum,7),
                     "-", F_FUNDIGIT_INTTOSTR(g_documento.atdsrvano,2)

#--------------------------------------------------------------------
# Verifica existencia de prorrogacoes
#--------------------------------------------------------------------

 declare c_cts15m00_015 cursor for
    select atdsrvnum, atdsrvano
      from datmprorrog
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

 open  c_cts15m00_015
 fetch c_cts15m00_015

 if sqlca.sqlcode = 0   then
    let d_cts15m00.prgtxt    = "PRORROGACAO"
    let d_cts15m00.aviproflg = "S"
 else
    initialize d_cts15m00.prgtxt to null
    let d_cts15m00.aviproflg = "N"
 end if
 close c_cts15m00_015

 let ws.funnom = "*** NAO CADASTRADO! ***"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = 1
    and funmat = w_cts15m00.funmat

 let d_cts15m00.atdlibtxt = ws.atddat                         clipped, " " ,
                            ws.atdhor                         clipped, " " ,
                            upshift(ws.dptsgl)                clipped, " " ,
                            w_cts15m00.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)                clipped, "  ",
                            ws.atdlibdat                      clipped, "  ",
                            ws.atdlibhor

 let w_cts15m00.datasaldo = w_cts15m00.atddat

 if d_cts15m00.avialgmtv = 1 then  #psi175552
     let w_cts15m00.datasaldo = w_cts15m00.avioccdat
 end if

 open c_cts15m00_001 using d_cts15m00.avialgmtv

 whenever error continue
 fetch c_cts15m00_001 into d_cts15m00.avimtvdes
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let d_cts15m00.avimtvdes = null
    else
       error 'Erro SELECT iddkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
       let m_erro = true
       return
    end if
 end if  # fim psi175552

 display by name d_cts15m00.avimtvdes

 ##psi 217956
 if (g_documento.ramcod = 31 or g_documento.ramcod = 531) and
    g_documento.succod    is not null   and
    g_documento.aplnumdig is not null   and
    g_documento.itmnumdig is not null   then

    call cts15m00_ver_claus(g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig)
          returning w_cts15m00.clscod26,
                    w_cts15m00.clscod33,
                    w_cts15m00.clscod44,
                    w_cts15m00.clscod46,
                    w_cts15m00.clscod47,
                    w_cts15m00.clscod48,
                    w_cts15m00.clscod34,
                    w_cts15m00.clscod35

    if w_cts15m00.clscod33 is not null then
       let w_cts15m00.clscod = w_cts15m00.clscod33
    else
       if w_cts15m00.clscod46 is not null then
          let w_cts15m00.clscod = w_cts15m00.clscod46
       end if
       if w_cts15m00.clscod47 is not null then
          let w_cts15m00.clscod = w_cts15m00.clscod47
       end if
       if w_cts15m00.clscod26 is not null then
          let w_cts15m00.clscod = w_cts15m00.clscod26
       end  if
       if w_cts15m00.clscod44 is not null then     ### JUNIOR(FORNAX)
          let w_cts15m00.clscod = w_cts15m00.clscod44
       end  if
       if w_cts15m00.clscod48 is not null then     ### JUNIOR(FORNAX)
          let w_cts15m00.clscod = w_cts15m00.clscod48
       end  if
      if w_cts15m00.clscod34 is not null then
         let w_cts15m00.clscod = w_cts15m00.clscod34
      end  if
      if w_cts15m00.clscod35 is not null then
         let w_cts15m00.clscod = w_cts15m00.clscod35
      end  if
    end if
 end if

 call condicoes_cts15m00()

 ## Obter apolice do terceiro
 if (d_cts15m00.c24astcod    = 'H11' or d_cts15m00.c24astcod = 'H13') and
    d_cts15m00.avialgmtv    = 5     and
    d_cts15m00.lcvsinavsflg = 'S'   then
    call ctx01g05_obter_apol_ter(g_documento.atdsrvnum,g_documento.atdsrvano)
         returning  lr_ret.*,
                    slv_terceiro.succod,
                    slv_terceiro.aplnumdig,
                    slv_terceiro.itmnumdig
    if lr_ret.erro <> 1 then
       error lr_ret.msg
    end if
 end if

 #==============================================================
 # Carrega celular da reserva
 #==============================================================
 if d_cts15m00.acntip == 3 then
	 if g_documento.atdsrvnum is not null then
	    whenever error stop
	    open ccts15m00035 using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch ccts15m00035 into d_cts15m00.smsenvdddnum,
	                            d_cts15m00.smsenvcelnum
	    whenever error continue
	 end if
 else
 	 if g_documento.atdsrvnum is not null then
	    whenever error stop
	    open ccts15m00042 using g_documento.atdsrvnum,g_documento.atdsrvano
	    fetch ccts15m00042 into d_cts15m00.smsenvdddnum,
	                            d_cts15m00.smsenvcelnum
	    whenever error continue
	 end if
 end if
 
 if cty31g00_valida_atd_premium()   and          
    g_documento.c24astcod = "H10"   then
 
 
    #--------------------------------------------------------------------
    # Informacoes do Local de Destino
    #--------------------------------------------------------------------
    
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            2)
                  returning a_cts15m00[2].lclidttxt
                           ,a_cts15m00[2].lgdtip
                           ,a_cts15m00[2].lgdnom
                           ,a_cts15m00[2].lgdnum
                           ,a_cts15m00[2].lclbrrnom
                           ,a_cts15m00[2].brrnom
                           ,a_cts15m00[2].cidnom
                           ,a_cts15m00[2].ufdcod
                           ,a_cts15m00[2].lclrefptotxt
                           ,a_cts15m00[2].endzon
                           ,a_cts15m00[2].lgdcep
                           ,a_cts15m00[2].lgdcepcmp
                           ,a_cts15m00[2].lclltt
                           ,a_cts15m00[2].lcllgt
                           ,a_cts15m00[2].dddcod
                           ,a_cts15m00[2].lcltelnum
                           ,a_cts15m00[2].lclcttnom
                           ,a_cts15m00[2].c24lclpdrcod
                           ,a_cts15m00[2].celteldddcod
                           ,a_cts15m00[2].celtelnum
                           ,a_cts15m00[2].endcmp
                           ,ws.codigosql
                           ,a_cts15m00[2].emeviacod
    
    
    select ofnnumdig into a_cts15m00[2].ofnnumdig
      from datmlcl
     where atdsrvano = g_documento.atdsrvano
       and atdsrvnum = g_documento.atdsrvnum
       and c24endtip = 2

    
    let a_cts15m00[2].lgdtxt = a_cts15m00[2].lgdtip clipped, " ",
                               a_cts15m00[2].lgdnom clipped, " ",
                               a_cts15m00[2].lgdnum using "<<<<#"

  end if

end function  ###  consulta_cts15m00

#--------------------------------------------------------------------
 function modifica_cts15m00()
#--------------------------------------------------------------------

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdsrvorg       like datmservico.atdsrvorg ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        segnumdig       like abbmdoc.segnumdig     ,
        funnom          like isskfunc.funnom       ,
        dptsgl          like isskfunc.dptsgl       ,
        c24trxnum       like dammtrx.c24trxnum     ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40),
        confirma        char (1)
 end record

 define prompt_key       char (01)
 define ws_avirsrgrttip  dec (1,0)
 define ws_avialgmtv     like datmavisrent.avialgmtv
 define ws_codigosql     integer
 define ws_msgsin        char (70)
 define ws_msgerr        char (300)
 DEFINE l_funnom         LIKE isskfunc.funnom,
        l_dptsgl         LIKE isskfunc.dptsgl
       ,l_result         smallint
       ,l_msg            char(080)

 define l_data         date,
        l_hora2        datetime hour to minute

 define l_etpmtvcod         like datksrvintmtv.etpmtvcod,
        l_etpmtvdes         like datksrvintmtv.etpmtvdes,
        l_atdetpcod         like datmsrvacp.atdetpcod,
        l_atdfnlflg         like datmservico.atdfnlflg

        let     prompt_key  =  null
        let     ws_avirsrgrttip  =  null
        let     ws_avialgmtv  =  null
        let     ws_codigosql  =  null
        let     ws_msgsin  =  null
        let     ws_msgerr  =  null
        let     l_funnom  =  null
        let     l_dptsgl  =  null
        let l_etpmtvcod = null
        let l_etpmtvdes  = null
        let l_atdetpcod = null
        let l_atdfnlflg = null

        initialize  ws.*  to  null

 let ws_avialgmtv = d_cts15m00.avialgmtv   # SALVA MOTIVO ANTERIOR
 let m_erro_msg = null

 let m_pgtflg = false
 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    select atdsrvnum, atdsrvano
      from dblmpagto
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

    if sqlca.sqlcode = 0  then
       let m_pgtflg = true
    end if
 end if

 if d_cts15m00.acntip = 3 then
    ############ ligia - Fornax - 17/05/11 #################################
    initialize m_ctd31.* to null
    call ctd31g00_ver_solicitacao(g_documento.atdsrvnum,
                                  g_documento.atdsrvano)
         returning m_ctd31.*

    if m_ctd31.sqlcode <> 0 and m_ctd31.sqlcode <> 100 then
       let m_erro_msg = m_ctd31.mens sleep 2
    end if

    initialize  m_reserva.*    to null
    call ctd31g00_ver_reserva(2, g_documento.atdsrvnum,
                                   g_documento.atdsrvano)
    returning m_reserva.erro, m_reserva.rsvsttcod, m_reserva.loccntcod

    if g_documento.acao = "ALT" then #or
       #g_documento.acao is null then


         call cts08g01("C","S","", "DESEJA REALIZAR UMA PRORROGACAO ?", "","")
              returning ws.confirma

         if ws.confirma = "N" then
            if g_documento.atdsrvnum is null then
               error " Consulta as informacoes de retirada somente apos digitacao do servico!"
            else
               call cts15m04("A", d_cts15m00.avialgmtv,
                             d_cts15m00.aviestcod, w_cts15m00.aviretdat,
                             w_cts15m00.avirethor, w_cts15m00.aviprvent,
                             d_cts15m00.lcvcod   , "" #ws.endcep
                           , d_cts15m00.dtentvcl)
                   returning w_cts15m00.aviretdat, w_cts15m00.avirethor,
                             w_cts15m00.aviprvent, m_cct, m_cct, m_cct
            end if
         else

            initialize  m_reserva.*    to null
            call ctd31g00_ver_reserva(2, g_documento.atdsrvnum,
                                      g_documento.atdsrvano)
                 returning m_reserva.erro, m_reserva.rsvsttcod, m_reserva.loccntcod

            if m_erro_msg is null and g_documento.acao = "ALT" and m_pgtflg = false then


               if  m_reserva.loccntcod is null then
                   call cts15m00_verifica_data_retirada()
                        returning ws.confirma

               else
                  let ws.confirma = "S"
               end if

               if ws.confirma = "S" then


                     call cts15m05(g_documento.atdsrvnum,
                                   g_documento.atdsrvano,
                                   d_cts15m00.lcvcod,
                                   d_cts15m00.aviestcod ,
                                   "", ## n�o eh usado no cts15m05
                                   d_cts15m00.avialgmtv ,
                                   d_cts15m00.dtentvcl,
                                   d_cts15m00.avivclgrp,
                                   d_cts15m00.lcvsinavsflg)
                     returning w_cts15m00.procan,
                               w_cts15m00.aviprodiaqtd

                     if w_cts15m00.procan = "P" then
                        if w_cts15m00.aviprodiaqtd is null or
                           w_cts15m00.aviprodiaqtd =  0    then
                           select aviprodiaqtd
                               into w_cts15m00.aviprodiaqtd
                               from datmprorrog
                              where atdsrvnum = g_documento.atdsrvnum
                                and atdsrvano = g_documento.atdsrvano
                                and aviproseq = ( select max(aviproseq) from datmprorrog
                                                  where atdsrvnum = g_documento.atdsrvnum  and
                                                  atdsrvano = g_documento.atdsrvano    )
                        end if
                     end if
               else

                 call cts08g01("A","N","", "VEICULO AINDA N�O FOI RETIRADO.","", "")
                       returning ws.confirma


                 call cts15m04("A", d_cts15m00.avialgmtv,
                               d_cts15m00.aviestcod, w_cts15m00.aviretdat,
                               w_cts15m00.avirethor, w_cts15m00.aviprvent,
                               d_cts15m00.lcvcod   , "" #ws.endcep
                             , d_cts15m00.dtentvcl)
                     returning w_cts15m00.aviretdat, w_cts15m00.avirethor,
                               w_cts15m00.aviprvent, m_cct, m_cct, m_cct

               end if
            end if
         end if
    end if

    if g_documento.acao = "CAN" and m_reserva.loccntcod is not null then
       call cts08g01("A","N","","CANCELAMENTO NAO PERMITIDO.",
                     "VEICULO ENTREGUE AO CLIENTE","")
    else

       if m_erro_msg is null and g_documento.acao = "CAN" and m_pgtflg = false then

          call cts08g01("C","S","", "CONFIRMA O CANCELAMENTO DA RESERVA ?", "","")
                returning ws.confirma

          if ws.confirma = "S" then

             call cts10g04_ultima_etapa(g_documento.atdsrvnum,
                                        g_documento.atdsrvano)
                           returning l_atdetpcod


             if d_cts15m00.acntip <> 3 and l_atdetpcod =  4 then ## reserva acionada
                let l_atdetpcod = 1
                let l_atdfnlflg = "N"
             else
                let l_atdetpcod = 5
                let l_atdfnlflg = "S"
             end if

             initialize m_ctd07g05.* to null
             call ctd07g05_ult_acn (2,g_documento.atdsrvnum,g_documento.atdsrvano)
                   returning m_ctd07g05.*

             call cts10g04_insere_etapa(g_documento.atdsrvnum,
                                        g_documento.atdsrvano,
                                        l_atdetpcod, m_ctd07g05.pstcoddig,
                                        "", "", m_ctd07g05.srrcoddig)
                  returning l_result

                 if  l_result  <>  0  then
                     error " Erro (", l_result, ") na etapa do servi�o.",
                           "AVISE A INFORMATICA!"
                 else

                    call ctd07g00_upd_atdfnlflg(g_documento.atdsrvnum,
                                                g_documento.atdsrvano, l_atdfnlflg)
                         returning l_result

                    if l_result <> 0 then
                       error "Erro (", l_result, ") na atualizacao do servi�o.",
                           "AVISE A INFORMATICA!"
                    else
                      call cts15m00_acionamento(g_documento.atdsrvnum,
                                                g_documento.atdsrvano,
                                                d_cts15m00.lcvcod,
                                                d_cts15m00.aviestcod,0,'',
                                                w_cts15m00.procan)
                       return false
                    end if
                 end if
          else
                error 'Motivo de cancelamento nao selecionado'
          end if
       end if ###########ligia - 17/05/11
    end if
end if
 call input_cts15m00()

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize d_cts15m00.*    to null
    initialize w_cts15m00.*    to null
    clear form
    return false
 end if

let ws_avirsrgrttip = m_opcao






 whenever error continue

 BEGIN WORK

  update datmservico set (nom      , corsus   , cornom   , vclcoddig,
                          vcldes   , vclanomdl, vcllicnum)
                       = (d_cts15m00.nom      , d_cts15m00.corsus   ,
                          d_cts15m00.cornom   , d_cts15m00.vclcoddig,
                          d_cts15m00.vcldes   , d_cts15m00.vclanomdl,
                          d_cts15m00.vcllicnum)
                    where atdsrvnum = g_documento.atdsrvnum and
                          atdsrvano = g_documento.atdsrvano

  if sqlca.sqlcode <> 0 then
     error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA! "
     rollback work
     prompt "" for char prompt_key
     return false
  end if

   if w_cts15m00.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts15m00.avioccdat = l_data
   end if

  whenever error continue
  execute p_cts15m00_005 using d_cts15m00.lcvcod   , d_cts15m00.avivclcod, d_cts15m00.aviestcod
                            ,d_cts15m00.avivclvlr, d_cts15m00.locsegvlr, d_cts15m00.avialgmtv
                            ,w_cts15m00.avidiaqtd, d_cts15m00.avilocnom, w_cts15m00.aviretdat
                            ,w_cts15m00.avirethor, w_cts15m00.aviprvent, w_cts15m00.avioccdat
                            ,w_cts15m00.ofnnom   , w_cts15m00.ofndddcod, w_cts15m00.ofntelnum
                            ,d_cts15m00.cttdddcod, d_cts15m00.ctttelnum, ws_avirsrgrttip
                            ,w_cts15m00.slcemp   , w_cts15m00.slcsuccod, w_cts15m00.slcmat
                            ,w_cts15m00.slccctcod, d_cts15m00.cdtoutflg, d_cts15m00.vclloctip
                            ,d_cts15m00.locrspcpfnum, d_cts15m00.locrspcpfdig
                            ,d_cts15m00.lcvsinavsflg, d_cts15m00.smsenvdddnum, d_cts15m00.smsenvcelnum
                            ,g_documento.atdsrvnum, g_documento.atdsrvano
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro UPDATE p_cts15m00_005 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
     error 'CTS15M00 / modifica_cts15m00() / ',d_cts15m00.lcvcod   ,' / ', d_cts15m00.avivclcod,' / '
                                              ,d_cts15m00.aviestcod,' / ', d_cts15m00.avivclvlr,' / '
                                              ,d_cts15m00.locsegvlr,' / ', d_cts15m00.avialgmtv,' / '
                                              ,w_cts15m00.avidiaqtd,' / ', d_cts15m00.avilocnom,' / '
                                              ,w_cts15m00.aviretdat,' / ', w_cts15m00.avirethor,' / '
                                              ,w_cts15m00.aviprvent,' / ', w_cts15m00.avioccdat,' / '
                                              ,w_cts15m00.ofnnom   ,' / ', w_cts15m00.ofndddcod,' / '
                                              ,w_cts15m00.ofntelnum,' / ', d_cts15m00.cttdddcod,' / '
                                              ,d_cts15m00.ctttelnum,' / ', ws_avirsrgrttip     ,' / '
                                              ,w_cts15m00.slcemp   ,' / ', w_cts15m00.slcsuccod,' / '
                                              ,w_cts15m00.slcmat   ,' / ', w_cts15m00.slccctcod,' / '
                                              ,d_cts15m00.cdtoutflg,' / ', d_cts15m00.vclloctip,' / '
                                              ,d_cts15m00.locrspcpfnum,' / ', d_cts15m00.locrspcpfdig,' / '
                                              ,d_cts15m00.lcvsinavsflg,' / ', d_cts15m00.smsenvdddnum, '/ '
                                              ,d_cts15m00.smsenvcelnum,' / ', g_documento.atdsrvnum,' / '
                                              ,g_documento.atdsrvano  sleep 1
     rollback work
     return false
  end if

  if d_cts15m00.c24astcod    = 'H11' and
     d_cts15m00.avialgmtv    = 5     and
     d_cts15m00.lcvsinavsflg = 'S'   and
     slv_terceiro.aplnumdig is not null then
     call ctx01g05_incluir_apol_ter(g_documento.atdsrvnum,g_documento.atdsrvano
                                   ,slv_terceiro.succod,slv_terceiro.aplnumdig
                                   ,slv_terceiro.itmnumdig)
          returning l_result,l_msg

      if l_result<> 1 then
        error l_msg sleep 1
        error 'Erro na gravacao da locacao. AVISE A INFORMATICA!'
        rollback work
        prompt '' for char ws.prompt_key
        let ws.retorno = false
        return false
     end if
 end if

#--------------------------------------------------------------------
# Interface com SINISTRO para BICIO OFICINA caso avialgmtv tenha sido
#                             mo de ?? para motivo = 03.
# (funcao se encontra no moduloaa009.4gl)
#------------------------------------------------------------------------
if  (ws_avialgmtv         <> 3   and
     d_cts15m00.avialgmtv  = 3)  or
    (ws_avialgmtv         <> 21  and
     d_cts15m00.avialgmtv  = 21) or
    (ws_avialgmtv         <> 24  and
     d_cts15m00.avialgmtv  = 24) then
      call sinitfopc ( "", "",
                       g_documento.succod   ,
                       g_documento.aplnumdig,
                       g_documento.itmnumdig,
                       g_documento.prporg   ,
                       g_documento.prpnumdig,
                       w_cts15m00.avioccdat ,
                       ""                   ,
                       "C"                  ,
                       g_issk.funmat        ,
                       "S"                   )
         returning ws_codigosql, ws_msgsin

      if  ws_codigosql  <>  0  then
          if d_cts15m00.avialgmtv  <> 24 then # Permitir abertura de Carro Extra para Motivo 24
             call errorlog("Erro_sinistro_cts15m00")
             call errorlog(ws_msgsin)
             error " Atencao: ",ws_msgsin
             rollback work
             prompt "" for char prompt_key
             return  false
          end if
      end if
  end if

  whenever error stop
  
  if cty31g00_valida_atd_premium()   and          
      g_documento.c24astcod = "H10"  and
      g_nova.delivery                then   
   
      let ws.codigosql = cts06g07_local( "M"
                                        ,g_documento.atdsrvnum
                                        ,g_documento.atdsrvano
                                        ,2
                                        ,a_cts15m00[2].lclidttxt
                                        ,a_cts15m00[2].lgdtip
                                        ,a_cts15m00[2].lgdnom
                                        ,a_cts15m00[2].lgdnum
                                        ,a_cts15m00[2].lclbrrnom
                                        ,a_cts15m00[2].brrnom
                                        ,a_cts15m00[2].cidnom
                                        ,a_cts15m00[2].ufdcod
                                        ,a_cts15m00[2].lclrefptotxt
                                        ,a_cts15m00[2].endzon
                                        ,a_cts15m00[2].lgdcep
                                        ,a_cts15m00[2].lgdcepcmp
                                        ,a_cts15m00[2].lclltt
                                        ,a_cts15m00[2].lcllgt
                                        ,a_cts15m00[2].dddcod
                                        ,a_cts15m00[2].lcltelnum
                                        ,a_cts15m00[2].lclcttnom
                                        ,a_cts15m00[2].c24lclpdrcod
                                        ,a_cts15m00[2].ofnnumdig
                                        ,a_cts15m00[2].emeviacod
                                        ,a_cts15m00[2].celteldddcod
                                        ,a_cts15m00[2].celtelnum
                                        ,a_cts15m00[2].endcmp)
      
          if  ws.codigosql is null  or
              ws.codigosql <> 0     then
              error " Erro (", ws.codigosql, ") na alteracao do",
                    " local de destino. AVISE A INFORMATICA!"

              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              return false
         end if
   end if

  commit work
  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                              g_documento.atdsrvano)

  return true

end function  ###  modifica_cts15m00()

#-------------------------------------------------------------------------------
 function inclui_cts15m00()
#-------------------------------------------------------------------------------

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        atdsrvorg       like datmservico.atdsrvorg ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        segnumdig       like abbmdoc.segnumdig     ,
        funnom          like isskfunc.funnom       ,
        dptsgl          like isskfunc.dptsgl       ,
        c24trxnum       like dammtrx.c24trxnum     ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40)
 end record

 define ws_avirsrgrttip    dec(1,0)
 define ws_msgerr          char (300)
 define ws_msgsin          char (70)

 define w_retorno          smallint
       ,l_result           smallint
       ,l_msg              char(080)
 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record
 define l_data         date,
        l_hora2        datetime hour to minute

        let     ws_avirsrgrttip  =  null
        let     ws_msgerr  =  null
        let     ws_msgsin  =  null
        let     w_retorno  =  null

        initialize  ws.*  to  null
        initialize  lr_clausula.* to null

 while true
   let d_cts15m00.aviproflg = "N"
   let g_documento.acao = "INC"

   initialize  w_cts15m00.locrspcpfnum, w_cts15m00.locrspcpfdig to null

   ##psi 217956
   if (g_documento.ramcod = 31 or g_documento.ramcod = 531) and
      g_documento.succod    is not null  and
      g_documento.ramcod    is not null  and
      g_documento.aplnumdig is not null  then
      #--------------------------------------------
      # Ultima situacao da apolice
      #--------------------------------------------
      call f_funapol_ultima_situacao (g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig)
                            returning g_funapol.*

      if g_funapol.dctnumseq is null  then
         select min(dctnumseq)
           into g_funapol.dctnumseq
           from abbmdoc
          where succod    = g_documento.succod
            and aplnumdig = g_documento.aplnumdig
            and itmnumdig = g_documento.itmnumdig
      end if

      #--------------------------------------------
      # Numero do segurado e tipo de endosso
      #--------------------------------------------
      select segnumdig
        into ws.segnumdig
        from abbmdoc
       where abbmdoc.succod    =  g_documento.succod
         and abbmdoc.aplnumdig =  g_documento.aplnumdig
         and abbmdoc.itmnumdig =  g_documento.itmnumdig
         and abbmdoc.dctnumseq =  g_funapol.dctnumseq

      if sqlca.sqlcode <> notfound  then
         #--------------------------------------------
         # Dados do segurado
         #--------------------------------------------
         whenever error continue
         select cgccpfnum, cgccpfdig
           into w_cts15m00.locrspcpfnum,
                w_cts15m00.locrspcpfdig
           from gsakseg
          where gsakseg.segnumdig  =  ws.segnumdig
      end if
   end if

   call input_cts15m00()

   if  int_flag  then
       let int_flag  = false
       initialize d_cts15m00.*     to null
       initialize w_cts15m00.*     to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts15m00.atdfnlflg = "N"  then
       let w_cts15m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

   if  w_cts15m00.atddat is null  then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let w_cts15m00.atddat = l_data
       let w_cts15m00.atdhor = l_hora2
   end if

   if  w_cts15m00.funmat is null  then
       let w_cts15m00.funmat = g_issk.funmat
   end if

   if  d_cts15m00.frmflg = "S"  then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       let ws.caddat = l_data
       let ws.cadhor = l_hora2
       let ws.cademp = g_issk.empcod
       let ws.cadmat = g_issk.funmat
   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
   end if

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------
 if g_documento.lclocodesres = "S" then
    let w_cts15m00.atdrsdflg = "S"
 else
    let w_cts15m00.atdrsdflg = "N"
 end if
 #------------------------------------------------------------------------------
 # Busca clausula
 #------------------------------------------------------------------------------
  if g_documento.ramcod = 531 then
     call cts15m00_Verifica_clausula(g_documento.c24astcod,d_cts15m00.avialgmtv)
          returning lr_clausula.*
  end if
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "R" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS15M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum    = ws.lignum
   let w_cts15m00.atdsrvnum  = ws.atdsrvnum
   let w_cts15m00.atdsrvano  = ws.atdsrvano
   let ws.atdsrvorg          = 08 #==> Remocao

 #------------------------------------------------------------------------------
 # Grava dados da ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts15m00.atddat       ,
                           w_cts15m00.atdhor       ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts15m00.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","", "",""            ,
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


   call cts10g02_grava_servico( w_cts15m00.atdsrvnum,
                                w_cts15m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                ""                  ,     # vclcorcod
                                w_cts15m00.funmat   ,
                                d_cts15m00.atdlibflg,
                                w_cts15m00.atdhor   ,     # atdlibhor
                                w_cts15m00.atddat   ,     # atdlibdat
                                w_cts15m00.atddat   ,     # atddat
                                w_cts15m00.atdhor   ,     # atdhor
                                ""                  ,     # atdlclflg
                                ""                  ,     # atdhorpvt
                                ""                  ,     # atddatprg
                                ""                  ,     # atdhorprg
                                "R"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                ""                  ,     # atdprscod
                                ""                  ,     # atdcstvlr
                                w_cts15m00.atdfnlflg,
                                w_cts15m00.atdfnlhor,
                                w_cts15m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts15m00.c24opemat,
                                d_cts15m00.nom      ,
                                d_cts15m00.vcldes   ,
                                d_cts15m00.vclanomdl,
                                d_cts15m00.vcllicnum,
                                d_cts15m00.corsus   ,
                                d_cts15m00.cornom   ,
                                w_cts15m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                ""                  ,     # atdpvtretflg
                                ""                  ,     # atdvcltip
                                ""                  ,     # asitipcod
                                ""                  ,     # socvclcod
                                d_cts15m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                2                   ,     # atdprinvlcod
                                8                       ) # ATDSRVORG
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
 # Grava locacao
 #------------------------------------------------------------------------------

   let ws_avirsrgrttip = m_opcao


   if w_cts15m00.avioccdat is null then
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      let w_cts15m00.avioccdat = l_data
   end if

   whenever error continue
   execute p_cts15m00_006 using ws.atdsrvnum           , ws.atdsrvano        , d_cts15m00.lcvcod
                             ,d_cts15m00.avivclcod   , d_cts15m00.aviestcod, d_cts15m00.avivclvlr
                             ,d_cts15m00.avialgmtv   , w_cts15m00.avidiaqtd, d_cts15m00.avilocnom
                             ,w_cts15m00.aviretdat   , w_cts15m00.avirethor, w_cts15m00.aviprvent
                             ,d_cts15m00.locsegvlr   , d_cts15m00.vclloctip, w_cts15m00.avioccdat
                             ,w_cts15m00.ofnnom      , w_cts15m00.ofndddcod, w_cts15m00.ofntelnum
                             ,d_cts15m00.cttdddcod   , d_cts15m00.ctttelnum, ws_avirsrgrttip
                             ,w_cts15m00.slcemp      , w_cts15m00.slcsuccod, w_cts15m00.slcmat
                             ,w_cts15m00.slccctcod   , d_cts15m00.cdtoutflg, d_cts15m00.locrspcpfnum
                             ,d_cts15m00.locrspcpfdig, d_cts15m00.lcvsinavsflg, d_cts15m00.smsenvdddnum
                             ,d_cts15m00.smsenvcelnum
   whenever error stop
   if  sqlca.sqlcode  <>  0  then
       error 'Erro INSERT p_cts15m00_006 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'CTS15M00 / inclui_cts15m00() / ',ws.atdsrvnum        ,' / ', ws.atdsrvano        ,' / '
                                              ,d_cts15m00.lcvcod   ,' / ', d_cts15m00.avivclcod,' / '
                                              ,d_cts15m00.aviestcod,' / ', d_cts15m00.avivclvlr,' / '
                                              ,d_cts15m00.avialgmtv,' / ', w_cts15m00.avidiaqtd,' / '
                                              ,d_cts15m00.avilocnom,' / ', w_cts15m00.aviretdat,' / '
                                              ,w_cts15m00.avirethor,' / ', w_cts15m00.aviprvent,' / '
                                              ,d_cts15m00.locsegvlr,' / ', d_cts15m00.vclloctip,' / '
                                              ,w_cts15m00.avioccdat,' / ', w_cts15m00.ofnnom   ,' / '
                                              ,w_cts15m00.ofndddcod,' / ', w_cts15m00.ofntelnum,' / '
                                              ,d_cts15m00.cttdddcod,' / ', d_cts15m00.ctttelnum,' / '
                                              ,ws_avirsrgrttip     ,' / ', w_cts15m00.slcemp   ,' / '
                                              ,w_cts15m00.slcsuccod,' / ', w_cts15m00.slcmat   ,' / '
                                              ,w_cts15m00.slccctcod,' / ', d_cts15m00.cdtoutflg,' / '
                                              ,d_cts15m00.locrspcpfnum,' / ',d_cts15m00.locrspcpfdig,' / '
                                              ,d_cts15m00.lcvsinavsflg  sleep 1
       rollback work
       let ws.retorno = false
       exit while
   end if

  ## Incluir a apolice do terceiro
  if d_cts15m00.c24astcod    = 'H11' and
     d_cts15m00.avialgmtv    = 5     and
     d_cts15m00.lcvsinavsflg = 'S'   and
     slv_terceiro.aplnumdig is not null then
     call ctx01g05_incluir_apol_ter(ws.atdsrvnum, ws.atdsrvano, slv_terceiro.succod
                                 ,slv_terceiro.aplnumdig, slv_terceiro.itmnumdig)
          returning l_result, l_msg

     if l_result <> 1 then
        error l_msg sleep 1
        error 'Erro na gravacao da locacao. AVISE A INFORMATICA!'
        rollback work
        prompt '' for char ws.prompt_key
        let ws.retorno = false
        return false
     end if
 end if

 #------------------------------------------------------------------------------
 # Insere Clausula X Servicos
 #------------------------------------------------------------------------------
   if lr_clausula.clscod is not null then
       call cts10g02_grava_servico_clausula(w_cts15m00.atdsrvnum
                                           ,w_cts15m00.atdsrvano
                                           ,g_documento.ramcod
                                           ,lr_clausula.clscod)
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
    end if
 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
  if  w_cts15m00.atdetpcod is null  then
       let w_cts15m00.atdetpcod = 1
       let ws.etpfunmat = w_cts15m00.funmat
       let ws.atdetpdat = w_cts15m00.atddat
       let ws.atdetphor = w_cts15m00.atdhor
  end if

  call cts10g04_insere_etapa( ws.atdsrvnum        ,
                              ws.atdsrvano        ,
                              w_cts15m00.atdetpcod,
                              d_cts15m00.lcvcod   ,
                              " ",
                              " ",
                              d_cts15m00.aviestcod) returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if



 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if  g_documento.aplnumdig is not null  and
       g_documento.aplnumdig <> 0         then
       call cts10g02_grava_servico_apolice(ws.atdsrvnum         ,
                                           ws.atdsrvano         ,
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
             values (ws.atdsrvnum         ,
                     ws.atdsrvano         ,
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
 # Interface com SINISTRO para BENEFICIO OFICINA (motivo = 3)
 # (funcao se encontra no modulo ossaa009.4gl)
 #------------------------------------------------------------------------------
   if  d_cts15m00.avialgmtv = 3  or
   	   d_cts15m00.avialgmtv = 21 or
   	   d_cts15m00.avialgmtv = 24 then

       call sinitfopc ( "", "",
                        g_documento.succod   ,
                        g_documento.aplnumdig,
                        g_documento.itmnumdig,
                        g_documento.prporg   ,
                        g_documento.prpnumdig,
                        w_cts15m00.avioccdat ,
                        ""                   ,
                        "C"                  ,
                        g_issk.funmat        ,
                        "S"                   )
          returning ws.codigosql, ws_msgsin

       if  ws.codigosql  <>  0  then
           if d_cts15m00.avialgmtv  <> 24 then # Permitir abertura de Carro Extra para Motivo 24
              call errorlog("Erro_sinistro_cts15m00")
              call errorlog(ws_msgsin)
              error " Atencao: ",ws_msgsin
              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
           end if
       end if
   end if
   
   if cty31g00_valida_atd_premium()   and          
      g_documento.c24astcod = "H10"   and
      g_nova.delivery                 then   
   
      let ws.codigosql = cts06g07_local( "I"
                                        ,ws.atdsrvnum
                                        ,ws.atdsrvano
                                        ,2
                                        ,a_cts15m00[2].lclidttxt
                                        ,a_cts15m00[2].lgdtip
                                        ,a_cts15m00[2].lgdnom
                                        ,a_cts15m00[2].lgdnum
                                        ,a_cts15m00[2].lclbrrnom
                                        ,a_cts15m00[2].brrnom
                                        ,a_cts15m00[2].cidnom
                                        ,a_cts15m00[2].ufdcod
                                        ,a_cts15m00[2].lclrefptotxt
                                        ,a_cts15m00[2].endzon
                                        ,a_cts15m00[2].lgdcep
                                        ,a_cts15m00[2].lgdcepcmp
                                        ,a_cts15m00[2].lclltt
                                        ,a_cts15m00[2].lcllgt
                                        ,a_cts15m00[2].dddcod
                                        ,a_cts15m00[2].lcltelnum
                                        ,a_cts15m00[2].lclcttnom
                                        ,a_cts15m00[2].c24lclpdrcod
                                        ,a_cts15m00[2].ofnnumdig
                                        ,a_cts15m00[2].emeviacod
                                        ,a_cts15m00[2].celteldddcod
                                        ,a_cts15m00[2].celtelnum
                                        ,a_cts15m00[2].endcmp)
      
          if  ws.codigosql is null  or
              ws.codigosql <> 0     then
              error " Erro (", ws.codigosql, ") na gravacao do",
                    " local de destino. AVISE A INFORMATICA!"

              rollback work
              prompt "" for char ws.prompt_key
              let ws.retorno = false
              exit while
         end if 
         
         
         call cts15m00_grava_historico_premium(ws.atdsrvnum ,
                                               ws.atdsrvano )
         
         
         
   end if

   commit work
   if cty39g00_grava() then
   	  call cty39g00_inclui(ws.atdsrvnum,
   	                       ws.atdsrvano,
   	                       2)
   end if
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(ws.atdsrvnum,
                               ws.atdsrvano)

 #------------------------------------------------------------------------------
 # Exibe o numero do Servico
 #------------------------------------------------------------------------------

   let d_cts15m00.servico =      F_FUNDIGIT_INTTOSTR(ws.atdsrvorg, 2),
                            "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum, 7),
                            "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano, 2)
   display d_cts15m00.servico to servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true
   let m_flag_alt = true

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts15m00

#--------------------------------------------------------------------
 function input_cts15m00()
#--------------------------------------------------------------------

 define ws            record
    prpflg            char (01)                         ,
    vclloctip         like datmavisrent.vclloctip       ,
    endcep            like datkavislocal.endcep         ,
    endcepcmp         like datkavislocal.endcepcmp      ,
    lcvcod            like datkavislocal.lcvcod         ,
    avivclmdl         like datkavisveic.avivclmdl       ,
    avivcldes         like datkavisveic.avivcldes       ,
    vclalglojstt      like datkavislocal.vclalglojstt   ,
    lcvlojtip         like datkavislocal.lcvlojtip      ,
    lcvregprccod      like datkavislocal.lcvregprccod   ,
    c24srvdsc         like datmservhist.c24srvdsc       ,
    vclpsqflg         smallint                          ,
    atdofnflg         smallint                          ,
    pstcoddig         like dpaksocor.pstcoddig          ,
    ok_flg            char (02)                         ,
    cartao            char (01)                         ,
    msgtxt            char (40)                         ,
    confirma          char (01)                         ,
    diasem            smallint                          ,
    lcvstt            like datklocadora.lcvstt          ,
    cauchqflg         like datkavislocal.cauchqflg      ,
    prtaertaxvlr      like datkavislocal.prtaertaxvlr   ,
    adcsgrtaxvlr      like datklocadora.adcsgrtaxvlr    ,
    avivclstt         like datkavisveic.avivclstt       ,
    viginc            like abbmclaus.viginc             ,
    vigfnl            like abbmclaus.vigfnl             ,
    sinitfcod         smallint                          ,
    sinitfdsc         char (70)                         ,
    snhflg            char (01)                         ,
    blqnivcod         like datkblq.blqnivcod            ,
    vcllicant         like datmservico.vcllicnum        ,
    cidnom            like datmlcl.cidnom               ,
    ufdcod            like datmlcl.ufdcod               ,
    frqvlr            dec (6,2)                         ,
    cct               integer                           ,
    cgccpfdig         like datmavisrent.locrspcpfdig    ,
    nomeusu           char (40)                         ,
    retflg            char (01)                         
 end record 

 define ws2           record
    viginc            like datklcvsit.viginc            ,
    vigfnl            like datklcvsit.vigfnl
 end record

 define ws_atdsrvnum  like datmservico.atdsrvnum
 define ws_atdsrvano  like datmservico.atdsrvano
 define ws_atdetpcod  like datmsrvacp.atdetpcod

 #osf32867 - Paula
 define w_ret record
    segnom           like gsakseg.segnom       ,
    corsus           like datmservico.corsus   ,
    cornom           like datmservico.cornom   ,
    cvnnom           char (20)                 ,
    vclcoddig        like datmservico.vclcoddig,
    vcldes           like datmservico.vcldes   ,
    vclanomdl        like datmservico.vclanomdl,
    vcllicnum        like datmservico.vcllicnum,
    vclchsinc        like abbmveic.vclchsinc   ,
    vclchsfnl        like abbmveic.vclchsfnl   ,
    vclcordes        char (12)
 end record
 #osf32867 - Paula
 
 define hist_cts15m00 record                            
   hist1             like datmservhist.c24srvdsc ,     
   hist2             like datmservhist.c24srvdsc ,     
   hist3             like datmservhist.c24srvdsc ,     
   hist4             like datmservhist.c24srvdsc ,     
   hist5             like datmservhist.c24srvdsc       
 end record                                             


  define l_viginc     date
        ,l_cts08g01   char(01)
        ,l_count      smallint
        ,l_today      date
        ,l_vcldevdat  date
        ,l_saldo      smallint
        ,l_bloqueio   char(01)
        ,l_custo      char(01)
        ,l_faxflg     smallint
        ,l_procan     char(01)
        ,l_qtd_fat    integer
        ,l_aviproseq  like datmprorrog.aviproseq
        ,l_total      integer
        ,l_aviretdat1 date
        ,l_empcod     smallint


## PSI 183431 - Inicio

  define lr_documento  record
         succod        like datrligapol.succod,      # Codigo Sucursal
         aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
         itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
         edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
         prporg        like datrligprp.prporg,       # Origem da Proposta
         prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
         fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
         fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
         pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
         pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
         solnom        char (15),                    # Solicitante
         soltip        char (01),                    # Tipo Solicitante
         c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Soliccitante
         ramcod        like datrservapol.ramcod,     # Codigo Ramo
         lignum        like datmligacao.lignum,      # Numero da Ligacao
         c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
         ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
         atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
         atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
         sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
         sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
         sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
         sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/ramo 53
         acao          char (03),                    # ALT, REC ou CAN
         atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
         cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
         lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
         vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
         flgIS096      char (01)                  ,  # flag cobertura claus.096
         flgtransp     char (01)                  ,  # flag averbacao transporte
         apoio         char (01)                  ,  # flag atend. pelo apoio(S/N)
         empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
         funmatatd     like datmligatd.apomat     ,  # matricula do atendente
         usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
         corsus        like gcaksusep.corsus      ,  #  /inicio psi172413 eduardo - meta
         dddcod        like datmreclam.dddcod     ,  # codigo da area de discagem
         ctttel        like datmreclam.ctttel     ,  # numero do telefone
         funmat        like isskfunc.funmat       ,  # matricula do funcionario
         cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
         cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
         cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF /fim psi172413 eduardo - meta
         atdprscod     like datmservico.atdprscod ,
         atdvclsgl     like datkveiculo.atdvclsgl ,
         srrcoddig     like datmservico.srrcoddig ,
         socvclcod     like datkveiculo.socvclcod ,
         dstqtd        dec(8,4)                   ,
         prvcalc       interval hour(2) to minute ,
         lclltt        like datmlcl.lclltt        ,
         lcllgt        like datmlcl.lcllgt        ,
         rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod,    ## Codigo do Motivo
         c24paxnum     like datmligacao.c24paxnum ,           # Numero da P.A.
         averbacao     like datrligtrpavb.trpavbnum,        # PSI183431 Daniel
         crtsaunum     like datksegsau.crtsaunum,
         bnfnum        like datksegsau.bnfnum,
         ramgrpcod     like gtakram.ramgrpcod
  end record

  define lr_ppt        record
         segnumdig     like gsakseg.segnumdig,
         cmnnumdig     like pptmcmn.cmnnumdig,
         endlgdtip     like rlaklocal.endlgdtip,
         endlgdnom     like rlaklocal.endlgdnom,
         endnum        like rlaklocal.endnum,
         ufdcod        like rlaklocal.ufdcod,
         endcmp        like rlaklocal.endcmp,
         endbrr        like rlaklocal.endbrr,
         endcid        like rlaklocal.endcid,
         endcep        like rlaklocal.endcep,
         endcepcmp     like rlaklocal.endcepcmp,
         edsstt        like rsdmdocto.edsstt,
         viginc        like rsdmdocto.viginc,
         vigfnl        like rsdmdocto.vigfnl,
         emsdat        like rsdmdocto.emsdat,
         corsus        like rsampcorre.corsus,
         pgtfrm        like rsdmdadcob.pgtfrm,
         mdacod        like gfakmda.mdacod,
         lclrsccod     like rlaklocal.lclrsccod
  end record

  define la_pptcls    array[05] of record
         clscod       like aackcls.clscod,
         carencia     date
  end record

  define lr_dados     record
         succod       like datrligapol.succod,
         aplnumdig    like datrligapol.aplnumdig,
         autsitatu    like abbmdoc.dctnumseq,
         itmnumdig    like datrligapol.itmnumdig,
         edsnumref    like datrligapol.edsnumref
  end record

  define lr_funapol   record
         resultado    char(01),
         dctnumseq    decimal(4,0),
         vclsitatu    decimal(4,0),
         autsitatu    decimal(4,0),
         dmtsitatu    decimal(4,0),
         dpssitatu    decimal(4,0),
         appsitatu    decimal(4,0),
         vidsitatu    decimal(4,0)
  end record

  define n_lcvcod         smallint,
         l_cod_erro       smallint,
         l_concede_ar     smallint,
         l_tipo_ordenacao char(01)

  define l_cidcod      like glakcid.cidcod,
         l_msg         char(100)

  define l_data        date,
         l_hora2       datetime hour to minute,
         l_linha1      char(40),
         l_linha2      char(40),
         l_linha3      char(40),
         l_linha4      char(40)

  define lr_doc record
     viginc     like abbmdoc.viginc
    ,clalclcod  like abbmdoc.clalclcod
  end record
  define l_endosso smallint
  define lr_retorno record
         coderro smallint
        ,mens    char(400)
  end record

  define l_avialgmtv   like datmavisrent.avialgmtv

  # Psi 236195
  define ws_eds record
       viginc  like abbmdoc.viginc,
       vigfnl  like abbmdoc.vigfnl,
       clscod26 like abbmclaus.clscod,
       clscod33 like abbmclaus.clscod,
       avialgmtv like datmavisrent.avialgmtv
  end record

  define l_erro      char(100)
        ,l_aviprvent like datmavisrent.aviprvent
        ,l_garantia  char(30)

  define l_acao char(1)
  define l_aux_aviproflg char(01)
  define l_aux_avialgmtv   like datmavisrent.avialgmtv
  define l_exibe smallint
## PSI 183431 - Final

        let   l_acao     =  null
        let   ws_atdsrvnum     =  null
        let   ws_atdsrvano     =  null
        let   ws_atdetpcod     =  null
        let   l_tipo_ordenacao = null
        let   l_cod_erro       = null
        let   l_concede_ar     = false
        let   l_avialgmtv      = null
        let   l_linha1         = null
        let   l_linha2         = null
        let   l_linha3         = null
        let   l_linha4         = null
        let   l_endosso        = null
        let   l_garantia       = null
        let   l_faxflg         = null
        let   l_procan         = null
        let   l_aviproseq      = null
        let   l_qtd_fat        = null
        let   l_total          = null


        initialize  ws.*  to  null

        initialize  ws2.*  to  null
        initialize ws_eds.* to null # Psi236195
        initialize l_aux_aviproflg to null

 let ws.vcllicant = d_cts15m00.vcllicnum

 initialize ws.* to null
 initialize w_claus2.* to null
 initialize  hist_cts15m00.*  to  null

 let m_tem_33_26 = 0

 display by name d_cts15m00.lcvnom

 if (g_documento.succod    is null  or
     g_documento.ramcod    is null  or
     g_documento.aplnumdig is null  or
     g_documento.itmnumdig is null) and
    (g_documento.prporg    is null  or
     g_documento.prpnumdig is null) then
 else
    if g_documento.atdsrvnum is null  and
       g_documento.atdsrvano is null  then
       let d_cts15m00.vclloctip = 1
    end if
    case d_cts15m00.vclloctip
       when 1  let d_cts15m00.vcllocdes = "SEGURADO"
       when 2  let d_cts15m00.vcllocdes = "CORRETOR"
       when 3  let d_cts15m00.vcllocdes = "DEPTO."
       when 4  let d_cts15m00.vcllocdes = "FUNC."
    end case
    display by name d_cts15m00.vclloctip
    display by name d_cts15m00.vcllocdes
 end if

 let m_cts15ant.* = d_cts15m00.*
 
 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2  
 

 input by name d_cts15m00.nom      ,
               d_cts15m00.corsus   ,
               d_cts15m00.cornom   ,
               d_cts15m00.vclcoddig,
               d_cts15m00.vclanomdl,
               d_cts15m00.vcllicnum,
               d_cts15m00.avilocnom,
               d_cts15m00.locrspcpfnum,
               d_cts15m00.locrspcpfdig,
               d_cts15m00.avialgmtv,
               d_cts15m00.garantia,
               d_cts15m00.flgarantia,
               d_cts15m00.lcvsinavsflg,
               d_cts15m00.lcvcod   ,
               d_cts15m00.lcvextcod,
               d_cts15m00.cdtoutflg,
               d_cts15m00.avivclcod,
               d_cts15m00.frmflg   ,
               d_cts15m00.aviproflg,
               d_cts15m00.smsenvdddnum,
               d_cts15m00.smsenvcelnum,
               d_cts15m00.cttdddcod,
               d_cts15m00.ctttelnum,
               d_cts15m00.atdlibflg  without defaults

   before field nom
          if m_pgtflg = true  then
             call cts08g01("A","N","","","LOCACAO PAGA NAO DEVE SER ALTERADA!",
                                      "") returning ws.confirma
             next field frmflg
          end if

          if g_documento.atdsrvnum is not null  and
             g_documento.atdsrvano is not null  then
             if d_cts15m00.vclloctip = 2  or
                d_cts15m00.vclloctip = 3  or
                d_cts15m00.vclloctip = 4  then
                display by name d_cts15m00.nom      , d_cts15m00.corsus   ,
                                d_cts15m00.cornom   , d_cts15m00.vclcoddig,
                                d_cts15m00.vclanomdl, d_cts15m00.vcllicnum,
                                d_cts15m00.avilocnom
                if d_cts15m00.vclloctip = 4  then
                   next field locrspcpfnum
                else
                   next field avilocnom
                end if
             end if
          end if

          while true
             if d_cts15m00.vclloctip is not null  then
                exit while
             end if

             call cts15m09(ws.vclloctip,
                           d_cts15m00.corsus,
                           d_cts15m00.cornom,
                           w_cts15m00.slcemp,
                           w_cts15m00.slcsuccod,
                           w_cts15m00.slcmat,
                           w_cts15m00.slccctcod,
                           g_documento.ciaempcod)
                 returning d_cts15m00.vclloctip,
                           d_cts15m00.corsus,
                           d_cts15m00.cornom,
                           w_cts15m00.slcemp,
                           w_cts15m00.slcsuccod,
                           w_cts15m00.slcmat,
                           w_cts15m00.slccctcod,
                           g_documento.ciaempcod

             if d_cts15m00.corsus     is null and
                d_cts15m00.cornom     is null and
                w_cts15m00.slcemp     is null and
                w_cts15m00.slcsuccod  is null and
                w_cts15m00.slcmat     is null and
                w_cts15m00.slccctcod  is null then
                initialize d_cts15m00.vclloctip to null
                call cts08g01("C","S","",
                                      "ABANDONA O PREENCHIMENTO DO LAUDO ?",
                                      "","")
                     returning ws.confirma

                if ws.confirma  =  "S"   then
                   exit while
                end if
             else
                case d_cts15m00.vclloctip
                   when 1  let d_cts15m00.vcllocdes = "SEGURADO"
                   when 2  let d_cts15m00.vcllocdes = "CORRETOR"
                   when 3  let d_cts15m00.vcllocdes = "DEPTO."
                   when 4  let d_cts15m00.vcllocdes = "FUNC."
                end case

                let d_cts15m00.nom       = d_cts15m00.cornom
                let d_cts15m00.avilocnom = d_cts15m00.cornom

                if d_cts15m00.vclloctip <> 2 then
                   initialize d_cts15m00.cornom to null
                end if

                display by name d_cts15m00.vclloctip
                display by name d_cts15m00.vcllocdes
                display by name d_cts15m00.nom
                display by name d_cts15m00.avilocnom
                display by name d_cts15m00.corsus

                if d_cts15m00.vclloctip = 4 then
                   next field locrspcpfnum
                else
                   next field nom
                end if
             end if
          end while
          if ws.confirma  =  "S"   then
             let int_flag = true
             exit input
          end if
          display by name d_cts15m00.nom        attribute (reverse)
          let m_cts15ant.nom = d_cts15m00.nom

   after  field nom
          display by name d_cts15m00.nom

          if m_erro_msg is not null  then
             error m_erro_msg
             next field nom
          end if

          ## Para sinistro, somente consulta o laudo
          if g_documento.acao = 'SIN' or
             g_documento.acao = 'CON' then
             let ws.confirma = cts08g01('A', 'N', '', 'NAO E POSSIVEL ALTERAR O LAUDO'
                                       ,'LIBERADO SOMENTE PARA CONSULTA', '')
             next field nom
          end if

         if m_reserva.loccntcod is not null then
            if d_cts15m00.avialgmtv = 5 then
               call cts08g01("A","S","","VEICULO ENTREGUE AO CLIENTE",
                                        "PERMITIDA ALTERACAO SOMENTE PARA O ",
                                        "MOTIVO DE LOCA��O DESEJA ALTERAR ? ")
                  returning ws.confirma
               if ws.confirma = "S" then
                  let m_alt_motivo = true
                  next field avialgmtv
               else
                  next field nom
               end if
            else
               call cts08g01("A","N","","ALTERACAO NAO PERMITIDA.",
                                        "VEICULO ENTREGUE AO CLIENTE","")
                    returning ws.confirma
               next field nom
            end if
         end if

          if d_cts15m00.nom is null  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if d_cts15m00.vclloctip = 2  or
             d_cts15m00.vclloctip = 3  then
             next field avilocnom
          end if

   before field corsus
          display by name d_cts15m00.corsus     attribute (reverse)
          if m_cts15m00b.flag = 1 then
              let m_cts15m00b.flag = 0
              let m_cts15m00b.corsus_ant = d_cts15m00.corsus
          end if
          let m_cts15ant.corsus = d_cts15m00.corsus

   after  field corsus
          display by name d_cts15m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts15m00.corsus is not null  then
                select cornom
                  into d_cts15m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts15m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts15m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts15m00.cornom     attribute (reverse)
          let m_cts15ant.cornom = d_cts15m00.cornom

   after  field cornom
          display by name d_cts15m00.cornom

   before field vclcoddig

          if g_documento.ramcod <> 31 and  #psi 217956
             g_documento.ramcod <> 531 then
             next field avilocnom
          end if

          display by name d_cts15m00.vclcoddig  attribute (reverse)
          let m_cts15ant.vclcoddig = d_cts15m00.vclcoddig

   after  field vclcoddig
          display by name d_cts15m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts15m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          end if

          if d_cts15m00.vclcoddig is null  or
             d_cts15m00.vclcoddig =  0     then
             call agguvcl() returning d_cts15m00.vclcoddig
             next field vclcoddig
          end if

          select vclcoddig from agbkveic
           where vclcoddig = d_cts15m00.vclcoddig

          if sqlca.sqlcode = notfound  then
             error " Codigo de veiculo nao cadastrado!"
             next field vclcoddig
          end if

          let d_cts15m00.vcldes = cts15g00(d_cts15m00.vclcoddig)

          display by name d_cts15m00.vcldes

   before field vclanomdl
          display by name d_cts15m00.vclanomdl  attribute (reverse)
          let m_cts15ant.vclanomdl = d_cts15m00.vclanomdl

   after  field vclanomdl
          display by name d_cts15m00.vclanomdl

          if d_cts15m00.vclanomdl is null  then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts15m00.vclcoddig, d_cts15m00.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ", d_cts15m00.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts15m00.vcllicnum  attribute (reverse)
          let m_cts15ant.vcllicnum = d_cts15m00.vcllicnum

   after  field vcllicnum
          display by name d_cts15m00.vcllicnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclanomdl
          end if

          if d_cts15m00.vcllicnum  is not null   then
             if not srp1415(d_cts15m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

          #---------------------------------------------------------------------
          # Chama tela de verificacao de bloqueios cadastrados
          #---------------------------------------------------------------------
          if g_documento.aplnumdig   is null       and
             d_cts15m00.vcllicnum    is not null   then

             if d_cts15m00.vcllicnum  = ws.vcllicant   then
             else
                initialize ws.snhflg  to null

                call cts13g00(d_cts15m00.c24astcod,
                              "", "", "", "",
                              d_cts15m00.vcllicnum,
                              "", "", "")
                     returning ws.blqnivcod, ws.snhflg

                if ws.blqnivcod  =  3   then
                   error " Bloqueio cadastrado nao permite atendimento para este assunto/apolice!"
                   next field vcllicnum
                end if

                if ws.blqnivcod  =  2     and
                   ws.snhflg     =  "n"   then
                   error " Bloqueio necessita de permissao para atendimento!"
                   next field vcllicnum
                end if
             end if
          end if

   before field avilocnom #psi 217956
          ## psi 217956
          if (g_documento.ramcod = 31 or g_documento.ramcod = 531) and
             g_documento.succod    is not null   and
             g_documento.aplnumdig is not null   and
             g_documento.itmnumdig is not null   then

             call cts15m00_ver_claus(g_documento.succod,
                                     g_documento.aplnumdig,
                                     g_documento.itmnumdig)
                  returning w_cts15m00.clscod26,
                            w_cts15m00.clscod33,
                            w_cts15m00.clscod44,
                            w_cts15m00.clscod46,
                            w_cts15m00.clscod47,
                            w_cts15m00.clscod48,
                            w_cts15m00.clscod34,
                            w_cts15m00.clscod35
             if w_cts15m00.clscod26 is not null then
               call cts15m00_ver_claus2(g_documento.succod,
                                        g_documento.aplnumdig,
                                        g_documento.itmnumdig)
                    returning w_claus2.clscod33,
                              w_claus2.clscod44,
                              w_claus2.clscod46,
                              w_claus2.clscod47,
                              w_claus2.clscod48,
                              w_claus2.clscod34,
                              w_claus2.clscod35
                if w_claus2.clscod33 is not null then
                   let w_claus2.clscod = w_claus2.clscod33
                end if
                if w_claus2.clscod46 is not null then
                   let w_claus2.clscod = w_claus2.clscod46
                end if
                if w_claus2.clscod47 is not null then
                   let w_claus2.clscod = w_claus2.clscod47
                end if
                if w_claus2.clscod44 is not null then
                   let w_claus2.clscod = w_claus2.clscod44
                end  if
                if w_claus2.clscod48 is not null then
                   let w_claus2.clscod = w_claus2.clscod48
                end  if
                if w_claus2.clscod34 is not null then
                   let w_claus2.clscod = w_claus2.clscod34
                end  if
                if w_claus2.clscod35 is not null then
                   let w_claus2.clscod = w_claus2.clscod35
                end  if
             end if
             
             if w_cts15m00.clscod26 = "26D"  or
             	  cty31g00_valida_fisico_apolice(g_documento.succod   ,   
             	                                 g_documento.aplnumdig,
             	                                 g_documento.itmnumdig) then
                
                call cts08g01("A","N","","SEGURADO PORTADOR DE",
                                      "","DEFICIENCIA FISICA!")
                returning ws.confirma
             end if
            
             if w_cts15m00.clscod33 is not null then

                let w_cts15m00.clscod = w_cts15m00.clscod33
             else
                if w_cts15m00.clscod46 is not null then

                   let w_cts15m00.clscod = w_cts15m00.clscod46
                end if
                if w_cts15m00.clscod47 is not null then

                   let w_cts15m00.clscod = w_cts15m00.clscod47
                end if
                if w_cts15m00.clscod26 is not null then

                   let w_cts15m00.clscod = w_cts15m00.clscod26
                end  if
                if w_cts15m00.clscod44 is not null then   ### JUNIOR (FORNAX)
                   let w_cts15m00.clscod = w_cts15m00.clscod44
                end  if
                if w_cts15m00.clscod48 is not null then   ### JUNIOR (FORNAX)
                   let w_cts15m00.clscod = w_cts15m00.clscod48
                end  if
                if w_cts15m00.clscod34 is not null then
                   let w_cts15m00.clscod = w_cts15m00.clscod34
                end  if
                if w_cts15m00.clscod35 is not null then
                   let w_cts15m00.clscod = w_cts15m00.clscod35
                end  if
             end if
          end if
          #Verifica usuario X segurado
          if g_documento.atdsrvnum    is null       then
             if g_documento.succod    is not null   and
                g_documento.aplnumdig is not null   and
                g_documento.itmnumdig is not null   and
                d_cts15m00.c24astcod  = 'H10'       then

                if (w_cts15m00.clscod  <> '046'  and
                    w_cts15m00.clscod  <> '46R') or
                    w_cts15m00.clscod  is null   then

                   open window w_cts15m00b at 11,26 with 07 rows,33 columns
                        attribute(border,prompt  line last - 1)
                   display "          A T E N C A O          " at 01,01 attribute (reverse)
                   display "---------------------------------" at 02,01
                   display "     SEGURADO SERA' O USUARIO    " at 04,01
                   while true

                      prompt "       (S)im ou (N)ao ? " for ws.confirma
                      if ws.confirma is not null then
                         let ws.confirma = upshift(ws.confirma)
                         if ws.confirma <>  "S"  and
                            ws.confirma <>  "N"  then
                         else
                            exit while
                         end if
                      end if
                   end while
                   close window w_cts15m00b
                end if

                if ws.confirma = "S" then
                   let d_cts15m00.avilocnom =  d_cts15m00.nom
                   if w_cts15m00.locrspcpfnum is not null and
                      w_cts15m00.locrspcpfnum is not null then
                      let d_cts15m00.locrspcpfnum = w_cts15m00.locrspcpfnum
                      let d_cts15m00.locrspcpfdig = w_cts15m00.locrspcpfdig
                   end if
                else
                   initialize d_cts15m00.avilocnom   ,d_cts15m00.locrspcpfnum,
                              d_cts15m00.locrspcpfdig to null
                end if
                display by name d_cts15m00.avilocnom
                display by name d_cts15m00.locrspcpfnum
                display by name d_cts15m00.locrspcpfdig
             end if
          end if

          display by name d_cts15m00.avilocnom  attribute (reverse)

   after  field avilocnom
####      if g_documento.atdsrvnum  is not null  and
####         w_cts15m00.atdfnlflg = "S"          then
####         call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
####                           " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
####                               "")
####             returning ws.confirma
####         let int_flag = true
####         exit input
####      end if

          display by name d_cts15m00.avilocnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m00.vclloctip = 1  then
                next field vcllicnum
             else
                if g_documento.atdsrvnum is not null  and
                   g_documento.atdsrvano is not null  then
                   next field avilocnom
                else
                   initialize d_cts15m00.vclloctip, d_cts15m00.vcllocdes,
                              d_cts15m00.nom      , d_cts15m00.avilocnom,
                              d_cts15m00.corsus   , d_cts15m00.vclloctip to null
                   display by name d_cts15m00.vclloctip
                   display by name d_cts15m00.vcllocdes
                   display by name d_cts15m00.nom
                   display by name d_cts15m00.avilocnom
                   display by name d_cts15m00.corsus
                   next field nom
                end if
             end if
          end if

          if d_cts15m00.avilocnom is null  then
             error " Informe o nome do usuario!"
             next field avilocnom
          end if


   before field locrspcpfnum
          if g_documento.atdsrvnum is null  then
             call cts15m02(w_cts15m00.clscod26)
                 returning ws.ok_flg, ws.cidnom, ws.ufdcod
                 let m_cidnom = ws.cidnom # webservice localiza
                 let m_ufdcod = ws.ufdcod # webservice localiza

             if ws.ok_flg          is null  then
                error " Criterios para locacao nao foram atendidos!"
                next field locrspcpfnum
             end if
          end if
          display by name d_cts15m00.locrspcpfnum  attribute (reverse)
          let m_cts15ant.locrspcpfnum = d_cts15m00.locrspcpfnum

   after  field locrspcpfnum

          display by name d_cts15m00.locrspcpfnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m00.vclloctip = 4 then
                if g_documento.atdsrvnum is not null  and
                   g_documento.atdsrvano is not null  then
                   next field locrspcpfnum
                else
                   initialize d_cts15m00.vclloctip, d_cts15m00.vcllocdes,
                              d_cts15m00.nom      , d_cts15m00.avilocnom,
                              d_cts15m00.corsus   , d_cts15m00.vclloctip to null
                   display by name d_cts15m00.vclloctip
                   display by name d_cts15m00.vcllocdes
                   display by name d_cts15m00.nom
                   display by name d_cts15m00.avilocnom
                   display by name d_cts15m00.corsus
                   next field nom
                end if
             else
                next field avilocnom
             end if
          end if
          if d_cts15m00.locrspcpfnum is null then
             next field avialgmtv
          end if

   before field locrspcpfdig
          display by name d_cts15m00.locrspcpfdig  attribute (reverse)
          let m_cts15ant.locrspcpfdig = d_cts15m00.locrspcpfdig

   after  field locrspcpfdig
          display by name d_cts15m00.locrspcpfdig

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field locrspcpfnum
          end if

          if d_cts15m00.locrspcpfnum is not null and
             d_cts15m00.locrspcpfdig is     null then
             error " Digito do Cpf incorreto!"
             next field locrspcpfdig
          end if

          if d_cts15m00.locrspcpfnum is not null and
             d_cts15m00.locrspcpfdig is not null then
             call F_FUNDIGIT_DIGITOCPF(d_cts15m00.locrspcpfnum)
                             returning ws.cgccpfdig

             if ws.cgccpfdig            is null           or
                d_cts15m00.locrspcpfdig <> ws.cgccpfdig   then
                error " Digito do Cpf incorreto!"
                next field locrspcpfdig
             end if
          end if

   before field avialgmtv
          if d_cts15m00.vclloctip = 3  then
             let d_cts15m00.avialgmtv =  4
          end if
          if d_cts15m00.vclloctip = 4  then
             let d_cts15m00.avialgmtv =  5
          end if

          let l_aux_avialgmtv = d_cts15m00.avialgmtv
          display by name d_cts15m00.avialgmtv  attribute (reverse)
          let m_cts15ant.avialgmtv = d_cts15m00.avialgmtv
         
   
   after  field avialgmtv
          display by name d_cts15m00.avialgmtv

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m00.locrspcpfnum is null then
                next field locrspcpfnum
             else
                next field locrspcpfdig
             end if
          end if

          
          
          
          #======================================================
          # Busca da Ultima Situa��o da Apolice
          #======================================================
             call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                                 g_documento.itmnumdig, g_documento.edsnumref)
                       returning g_funapol.*


          #============================================================
          # Busca de classe de localizacao e vigencia inicial
          #============================================================
           whenever error continue
           open ccts15m00033 using g_documento.succod
                                  ,g_documento.aplnumdig
                                  ,g_documento.itmnumdig
                                  ,g_funapol.dctnumseq
           fetch ccts15m00033 into lr_doc.clalclcod,
                                   lr_doc.viginc

           whenever error stop
           if (g_documento.semdocto = " " or g_documento.semdocto is null) and g_documento.ramcod <> 114 then
              if sqlca.sqlcode <> 0 then
                 let lr_retorno.coderro = sqlca.sqlcode
                 let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped, " > ao buscar a vigencia e classe localizacao, Avise a informatica !"
                 call errorlog(lr_retorno.mens)
                 error lr_retorno.mens
              end if

              call cts15m00_verifica_endosso()
                   returning lr_doc.viginc,l_endosso
           end if

           if g_documento.semdocto = " " or g_documento.semdocto is null then
              if d_cts15m00.avialgmtv is null then

                 if cty31g00_nova_regra_clausula(g_documento.c24astcod) then
                 
                    if w_cts15m00.clscod26[1,2] = '26' then
                       let w_claus2.flag = "S"
                    else
                       let w_claus2.flag = "N"
                    end if

                 	 call cty31g00_popup_motivos(w_cts15m00.clscod    ,
                 	                             w_claus2.clscod      ,
                 	                             w_claus2.flag        ,
                 	                             d_cts15m00.avialgmtv ,
                 	                             g_documento.c24astcod)
                 	 returning d_cts15m00.avialgmtv

                 else

                    if w_cts15m00.clscod26[1,2] = '26' then
                       let w_claus2.flag = "S"
                    else
                       let w_claus2.flag = "N"
                    end if
                   
                   
                    call cts15m00_popup_motivos(w_cts15m00.clscod    ,
                                                w_claus2.clscod      ,
                                                w_claus2.flag        ,
                                                d_cts15m00.avialgmtv ,
                                                g_documento.c24astcod)
                    returning d_cts15m00.avialgmtv

                 end if
                 display by name d_cts15m00.avialgmtv

                 if d_cts15m00.avialgmtv is null then
                    next field avialgmtv
                 end if

              end if
           else

              if w_cts15m00.clscod[1,2]  = "26" or
                 w_claus2.clscod[1,2]    = "26" then
                 let w_claus2.flag       = "S"
              else
              	 let w_claus2.flag       = "N"
              end if
              call cts15m00_popup_motivos(w_cts15m00.clscod    ,
                                          w_claus2.clscod      ,
                                          w_claus2.flag        ,
                                          d_cts15m00.avialgmtv ,
                                          g_documento.c24astcod)
              returning d_cts15m00.avialgmtv

              display by name d_cts15m00.avialgmtv
           end if
           
           #======================================================
           # Processo Auto Premium                 
           #======================================================
           
           if cty31g00_valida_atd_premium()   and          
              g_documento.c24astcod = "H10"   and 
              d_cts15m00.avialgmtv  <> 4      then 
              	
              	let ws.confirma = "S"         
           
               if d_cts15m00.avialgmtv = 5 then            
                 let ws.confirma = cts08g01("C","S","","ATENDIMENTO PREMIUM","POSSIVEL REVERSAO?","")
                 let g_nova.reversao = ws.confirma
               end if
              
               if ws.confirma = "S" then 
               
                  let ws.confirma = cts08g01("C","S","","ATENDIMENTO PREMIUM","DESEJA O SERVICO DE DELIVERY?","") 
                           
                  if ws.confirma = "S" then
                  
                     let g_nova.delivery = true
                     
                     call cts06g03(2
                                  ,g_documento.atdsrvorg
                                  ,g_documento.ligcvntip
                                  ,l_data
                                  ,l_hora2
                                  ,a_cts15m00[2].lclidttxt
                                  ,a_cts15m00[2].cidnom
                                  ,a_cts15m00[2].ufdcod
                                  ,a_cts15m00[2].brrnom
                                  ,a_cts15m00[2].lclbrrnom
                                  ,a_cts15m00[2].endzon
                                  ,a_cts15m00[2].lgdtip
                                  ,a_cts15m00[2].lgdnom
                                  ,a_cts15m00[2].lgdnum
                                  ,a_cts15m00[2].lgdcep
                                  ,a_cts15m00[2].lgdcepcmp
                                  ,a_cts15m00[2].lclltt
                                  ,a_cts15m00[2].lcllgt
                                  ,a_cts15m00[2].lclrefptotxt
                                  ,a_cts15m00[2].lclcttnom
                                  ,a_cts15m00[2].dddcod
                                  ,a_cts15m00[2].lcltelnum
                                  ,a_cts15m00[2].c24lclpdrcod
                                  ,a_cts15m00[2].ofnnumdig
                                  ,a_cts15m00[2].celteldddcod
                                  ,a_cts15m00[2].celtelnum
                                  ,a_cts15m00[2].endcmp
                                  ,hist_cts15m00.*
                                  ,a_cts15m00[2].emeviacod )
                         returning a_cts15m00[2].lclidttxt
                                  ,a_cts15m00[2].cidnom
                                  ,a_cts15m00[2].ufdcod
                                  ,a_cts15m00[2].brrnom
                                  ,a_cts15m00[2].lclbrrnom
                                  ,a_cts15m00[2].endzon
                                  ,a_cts15m00[2].lgdtip
                                  ,a_cts15m00[2].lgdnom
                                  ,a_cts15m00[2].lgdnum
                                  ,a_cts15m00[2].lgdcep
                                  ,a_cts15m00[2].lgdcepcmp
                                  ,a_cts15m00[2].lclltt
                                  ,a_cts15m00[2].lcllgt
                                  ,a_cts15m00[2].lclrefptotxt
                                  ,a_cts15m00[2].lclcttnom
                                  ,a_cts15m00[2].dddcod
                                  ,a_cts15m00[2].lcltelnum
                                  ,a_cts15m00[2].c24lclpdrcod
                                  ,a_cts15m00[2].ofnnumdig
                                  ,a_cts15m00[2].celteldddcod
                                  ,a_cts15m00[2].celtelnum
                                  ,a_cts15m00[2].endcmp
                                  ,ws.retflg
                                  ,hist_cts15m00.*
                                 ,a_cts15m00[2].emeviacod
                        
                      let d_cts15m00.cttdddcod    = a_cts15m00[2].dddcod   
                      let d_cts15m00.ctttelnum    = a_cts15m00[2].lcltelnum
                      let d_cts15m00.smsenvdddnum = a_cts15m00[2].celteldddcod 
                      let d_cts15m00.smsenvcelnum = a_cts15m00[2].celtelnum 
                      
                      display by name d_cts15m00.cttdddcod   
                      display by name d_cts15m00.ctttelnum   
                      display by name d_cts15m00.smsenvdddnum 
                      display by name d_cts15m00.smsenvcelnum  
                                        
                      if ws.retflg = "N" then                     	 
                      	 error "Por Favor Informe um Endereco!"
                         next field avialgmtv                     
                      end if  
                  else
                      let g_nova.delivery = false
                  end if
               else
               	 let g_nova.delivery = false  
               end if            
           
           else
           	 let g_nova.delivery = false  
           end if 


              #------------------------------------------------#
              # Alerta Porte Medio
              #------------------------------------------------#

              if d_cts15m00.avialgmtv = 1 then

                   if w_cts15m00.clscod26 = "26H" or
                      w_cts15m00.clscod26 = "26I" or
                      w_cts15m00.clscod26 = "26J" or
                      w_cts15m00.clscod26 = "26K" or
                      w_cts15m00.clscod26 = "26L" or
                      w_cts15m00.clscod26 = "26M" then


                         call cts08g01("A","N","",
                                        "APOLICE COM CLAUSULA 26 - PORTE MEDIO",
                                        "SELECIONAR A REDE LOCALIZA GRUPO F OU M","")
                         returning ws.confirma


                   end if

              end if


              #------------------------------------------------#
              # Verifica a Reserva
              #------------------------------------------------#

              call cts15m00_recupera_reserva(g_documento.succod   ,
                                             g_documento.ramcod   ,
                                             g_documento.aplnumdig,
                                             g_documento.itmnumdig,
                                             g_documento.c24astcod,
                                             d_cts15m00.avialgmtv ,
                                             l_aux_avialgmtv      ,
                                             w_cts15m00.aviprvent)
              returning l_saldo    ,
                        l_bloqueio ,
                        l_custo    ,
                        l_qtd_fat  ,
                        l_total



              if l_bloqueio = "S" then
                 next field avialgmtv
              end if


              if l_custo = "S" then

                   let d_cts15m00.vclloctip = 3

                   while true


                           #------------------------------------------------#
                           # Abre a Tela de Centro de Custo
                           #------------------------------------------------#


                           call cts15m08(d_cts15m00.vclloctip ,
                                         w_cts15m00.slcemp    ,
                                         w_cts15m00.slcsuccod ,
                                         w_cts15m00.slcmat    ,
                                         w_cts15m00.slccctcod ,
                                         "A" )
                           returning w_cts15m00.slcemp        ,
                                     w_cts15m00.slcsuccod     ,
                                     w_cts15m00.slcmat        ,
                                     w_cts15m00.slccctcod     ,
                                     ws.nomeusu

                          if w_cts15m00.slcemp    is null or
                             w_cts15m00.slcsuccod is null or
                             w_cts15m00.slcmat    is null or
                             w_cts15m00.slcmat    is null then
                                error "Preenchimento obrigatorio"
                          else
                            exit while
                          end if
                   end while


              end if

              if g_flag_msg = 1 or
              	  g_flag_msg = 2 then


              	  if g_flag_msg = 1 then
              	  	 let l_empcod = 0
              	  else
              	   	 let l_empcod = g_documento.ciaempcod
              	  end if

              	  let l_aviretdat1  = w_cts15m00.aviretdat

              	  let l_aviretdat1 = l_aviretdat1 + l_qtd_fat

                 begin work

                 #------------------------------------------------#
                 # Grava Prorrogacao
                 #------------------------------------------------#

                 call cts15m05_prorrog(g_documento.atdsrvnum,
                                       g_documento.atdsrvano,
                                       w_cts15m00.aviretdat ,
                                       w_cts15m00.avirethor ,
                                       l_qtd_fat            ,
                                       g_issk.empcod        ,
                                       g_issk.funmat        ,
                                       w_cts15m00.slcemp    ,
                                       w_cts15m00.slcsuccod ,
                                       w_cts15m00.slccctcod )
                 returning l_faxflg, l_procan, l_aviproseq


                 #------------------------------------------------#
                 # Grava Resumo
                 #------------------------------------------------#

                 call ctd33g00_ins_resumo
                      (g_documento.atdsrvnum,
                       g_documento.atdsrvano,
                       l_aviproseq          ,
                       w_cts15m00.aviretdat ,
                       w_cts15m00.avirethor ,
                       l_aviretdat1         ,
                       l_qtd_fat            ,
                       l_empcod             )
                 returning l_erro

                 commit work

                 next field aviproflg

              end if



             #osf32867 - Paula
             if d_cts15m00.c24astcod = "H10" or
                d_cts15m00.c24astcod = "H12" then
                  if ((d_cts15m00.avialgmtv  is null) or
                      (d_cts15m00.avialgmtv  <> 1     and
                       d_cts15m00.avialgmtv  <> 2     and
                       d_cts15m00.avialgmtv  <> 3     and
                       d_cts15m00.avialgmtv  <> 4     and
                       d_cts15m00.avialgmtv  <> 5     and
                       d_cts15m00.avialgmtv  <> 8     and
                       d_cts15m00.avialgmtv  <> 9     and
                       d_cts15m00.avialgmtv  <> 0     and
                       d_cts15m00.avialgmtv  <> 13    and
                       d_cts15m00.avialgmtv  <> 14    and
                       d_cts15m00.avialgmtv  <> 21    and
                       d_cts15m00.avialgmtv  <> 23    and
                       d_cts15m00.avialgmtv  <> 24    and
                       d_cts15m00.avialgmtv  <> 20))   then

                       error "Motivo n�o relacionado ao assunto "
                       next field avialgmtv


                  end if
             else
                  if ((d_cts15m00.avialgmtv is null) or
                         (d_cts15m00.avialgmtv <> 4   and
                          d_cts15m00.avialgmtv <> 5   and
                          d_cts15m00.avialgmtv <> 6   and
                          d_cts15m00.avialgmtv <> 7)) then
                          error "Motivo n�o relacionado ao assunto "
                          next field avialgmtv

                end if
             end if
             if (d_cts15m00.c24astcod = "H10"  or
             	   d_cts15m00.c24astcod = "H12") and
             	   d_cts15m00.avialgmtv = 21     then
             	   #--------------------------------------------------------
             	   # Seleciona o Sinistro
             	   #--------------------------------------------------------
             	   if not cty39g00_acessa() then
             	      next field avialgmtv
             	   end if
             	   #--------------------------------------------------------
             	   # Valida se Carro Reserva ja Tem um Assunto SDF
             	   #--------------------------------------------------------
             	   if not cty39g00_valida_SDF(g_documento.succod    ,
             	                              g_documento.ramcod    ,
             	                              g_documento.aplnumdig ,
             	   	                          g_documento.itmnumdig ) then
             	   	  next field avialgmtv
             	   end if
             end if


             if w_cts15m00.clscod33 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod33
                end if
             end if


             if w_cts15m00.clscod35 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod35
                end if
             end if

             if w_cts15m00.clscod34 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod34
                end if
             end if


             if w_cts15m00.clscod44 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod44
                end if
             end if

             if w_cts15m00.clscod46 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod46
                end if
             end if


             if w_cts15m00.clscod47 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod47
                end if
             end if


             if w_cts15m00.clscod48 is not null and
                w_cts15m00.clscod26 is not null then
                if d_cts15m00.avialgmtv = 1 then
                      let w_cts15m00.clscod = w_cts15m00.clscod26
                end if

                if d_cts15m00.avialgmtv = 0 then
                   let w_cts15m00.clscod = w_cts15m00.clscod48
                end if
             end if



             ## psi 217956
             if g_documento.ramcod <> 31 and g_documento.ramcod <> 531 then
                if d_cts15m00.avialgmtv <> 4 and d_cts15m00.avialgmtv <> 5 then
                   error "Motivos: (4)Deptos (5)Particular"
                   next field avialgmtv
                end if
             end if


             if m_clcdat >= "01/07/2003" then

                # CT Roberto


                # Mensagens Alteradas Pela Judite Esteves 05/01/2011
                #===================================================
                if d_cts15m00.avialgmtv     = 1    and
                   w_cts15m00.clscod26[1,2] is null then
                     error "Motivo n�o relacionado a clausula contratada !"
                     next field avialgmtv
                end if

                if d_cts15m00.avialgmtv     = 2    then

                  if g_documento.c24astcod <> "H10"  then
                      error "Motivo n�o relacionado ao assunto !"
                     next field avialgmtv
                  end if

                  if (w_cts15m00.clscod33 is null   or
                     (w_cts15m00.clscod33 <> '033' and
                      w_cts15m00.clscod33 <> '33R')) and
                     (w_cts15m00.clscod47 is null or
                     (w_cts15m00.clscod47 <> '047' and
                      w_cts15m00.clscod47 <> '47R')) and
                     (w_cts15m00.clscod46 is null or
                     (w_cts15m00.clscod46 <> '046' and
                      w_cts15m00.clscod46 <> '46R' )) and
                     (w_cts15m00.clscod44 is null or
                     (w_cts15m00.clscod44 <> '044' and
                      w_cts15m00.clscod44 <> '44R' )) and
                     (w_cts15m00.clscod48 is null or
                     (w_cts15m00.clscod48 <> '048' and
                      w_cts15m00.clscod48 <> '48R' ))
                      then
                     error "Motivo n�o relacionado a clausula contratada !"
                     next field avialgmtv
                  end if

                end if

                   if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                      d_cts15m00.avialgmtv = 8 and
                      (w_cts15m00.clscod44 ='44R' or
                       w_cts15m00.clscod48 ='048' or
                       w_cts15m00.clscod48 ='48R') then
                       call cts08g01("A","N",
                                       "MOTIVO 8-Seg Como Terc ",
                                      "SOMENTE CONTRATADA PARA A CLAUSULA",
                                      "044",
                                     "")
                            returning ws.confirma
                       next field avialgmtv
                   end if
                if (d_cts15m00.avialgmtv     = 0  or
                   ##d_cts15m00.avialgmtv    = 2  or
                    d_cts15m00.avialgmtv     = 8  or
                    d_cts15m00.avialgmtv     = 13 or
                    d_cts15m00.avialgmtv     = 14) and
                   (w_cts15m00.clscod33 is null   or
                    w_cts15m00.clscod33 <> '033') and
                    w_cts15m00.clscod44 is null   and
                    w_cts15m00.clscod48 is null   and
                   (w_cts15m00.clscod47 is null   or
                    w_cts15m00.clscod47 <> '047') and
                   (w_cts15m00.clscod46 is null   or
                    w_cts15m00.clscod46 <> '046') then
                    error "Motivo n�o relacionado a clausula contratada !"
                    next field avialgmtv
                end if


                  if d_cts15m00.avialgmtv     = 8    and
                   g_documento.c24astcod = "H12"  then
                     error "Motivo n�o relacionado ao assunto !"
                     next field avialgmtv
                end if



                #ligia - fornax
                if d_cts15m00.avialgmtv  = 9   and
                   (w_cts15m00.clscod33 is null   or
                    w_cts15m00.clscod33 <> '33R') and
                   (w_cts15m00.clscod46 is null or
                    w_cts15m00.clscod46 <> '46R') and
                   (w_cts15m00.clscod47 is null or
                    w_cts15m00.clscod47 <> '47R') and
                    (w_cts15m00.clscod44 is null or
                    w_cts15m00.clscod44 <> '44R') then
                     error "Motivo n�o relacionado a clausula contratada !"
                     next field avialgmtv
                end if

                if cty31g00_nova_regra_clausula(g_documento.c24astcod) then

                   if w_cts15m00.clscod26[1,2] = '26' then
                      let w_claus2.flag = "S"
                   else
                      let w_claus2.flag = "N"
                   end if

                   call cty31g00_valida_motivo_clausula(w_cts15m00.clscod    ,
                                                        w_claus2.clscod      ,
                                                        w_claus2.flag        ,
                                                        d_cts15m00.avialgmtv ,
                                                        g_documento.c24astcod)
                   returning w_claus2.atende,
                             w_claus2.motivos

                   if w_claus2.atende = "N" then
                      error "Motivo nao relacionado a clausula contratada !"
                      next field avialgmtv
                   end if

                else

                	  if w_cts15m00.clscod26[1,2] = '26' then
                      let w_claus2.flag = "S"
                   else
                   	 let w_claus2.flag = "N"
                   end if

                   call cts15m00_valida_motivo_clausula(w_cts15m00.clscod    ,
                                                        w_claus2.clscod      ,
                                                        w_claus2.flag        ,
                                                        d_cts15m00.avialgmtv ,
                                                        g_documento.c24astcod)
                   returning w_claus2.atende,
                             w_claus2.motivos

                   if w_claus2.atende = "N" then
                      error "Motivo nao relacionado a clausula contratada !"
                      next field avialgmtv
                   end if

                end if

                if w_cts15m00.clscod48[1,3] = "048"   and
                	  d_cts15m00.avialgmtv     = 3       and
                	  (g_documento.c24astcod    = "H10"  or
                	   g_documento.c24astcod    = "H12") then
                	     error "Motivo nao relacionado a clausula contratada !"
                	     next field avialgmtv
                end if

                if w_cts15m00.clscod46[1,3] = "046"   and
                	  d_cts15m00.avialgmtv     = 3       and
                	  (g_documento.c24astcod    = "H10"  or
                	   g_documento.c24astcod    = "H12") then
                	     error "Motivo nao relacionado a clausula contratada !"
                	     next field avialgmtv
                end if

                if w_cts15m00.clscod46[1,3] = "046"   and
                	  d_cts15m00.avialgmtv     = 6       and
                	  (g_documento.c24astcod    = "H10"  or
                	   g_documento.c24astcod    = "H12") then
                	     error "Motivo nao relacionado a clausula contratada !"
                	     next field avialgmtv
                end if


                if g_flag_azul <> "S" and
                	  d_cts15m00.avialgmtv = 20 then
                     error "Motivo nao relacionado a clausula contratada !"
                     next field avialgmtv
                end if

                #===================================================

                ## Alberto
                if  w_cts15m00.clscod26[1,2] = '26'   and
                   (w_cts15m00.clscod33[1,3] = '033'  or
                    w_cts15m00.clscod33[1,3] = '33R') then
                   let m_tem_33_26 = 3
                else
                   if w_cts15m00.clscod26[1,2] = '26' then
                      let m_tem_33_26 = 1
                   end if
                   if w_cts15m00.clscod33[1,3] = '033' or
                      w_cts15m00.clscod33[1,3] = '33R' then
                      let m_tem_33_26 = 2
                      if d_cts15m00.avialgmtv     = 1   then
                         let m_cts08g01 = null
                         let m_cts08g01 = cts08g01("A" ,"N" ,"CLAUSULA 33/33R CONTRATADA,"
                                                   ,"SUGERIR RESERVAR POR MOTIVO"
                                                   ,"9-Ind.Integral."
                                                   ,"")
                           next field avialgmtv
                      end if
                   end if
                end if
                if (d_cts15m00.avialgmtv = 1            and
                    (w_cts15m00.clscod26[1,2] <> '26'   and
                     w_cts15m00.clscod26 is null)       and
                     w_cts15m00.clscod33 <> '033')      then

                   let m_cts08g01 = null
                   let m_cts08g01 = cts08g01("A" ,"N" ,""
                                             ,"SUGERIR RESERVAR POR MOTIVO"
                                             ,"3-BENEFICIO OU 5-PARTICULAR"
                                             ,"")
                   next field avialgmtv
                end if

                # CT Roberto

                if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                    d_cts15m00.avialgmtv = 2 and
                      (w_cts15m00.clscod48 ='048' or
                       w_cts15m00.clscod48 ='48R') then
                       call cts08g01("A","N"
                                    ,"NAO SERA PERMITIDO PROSSEGUIR"
                                    ," COM MOTIVO 2-PORTO SOCORRO"
                                    ," SEM CLAUSULA 044/44R"
                                    ,"")
                            returning ws.confirma
                       next field avialgmtv
                end if

                # ligia - fornax - retirado, confirmar - 08/06/11
                if (d_cts15m00.avialgmtv = 2         and
                   (w_cts15m00.clscod26[1,2] <> '26' or
                    w_cts15m00.clscod26 is null))    then

                     if  (w_cts15m00.clscod33 <> "033"       and
                          w_cts15m00.clscod33 <> "33R"       or
                          w_cts15m00.clscod33 is null      ) and
                         (w_cts15m00.clscod47 <> "047"      and
                          w_cts15m00.clscod47  <> "47R"       or
                          w_cts15m00.clscod47  is null      ) and
                         (w_cts15m00.clscod46 <> "046"      and
                          w_cts15m00.clscod46  <> "46R"       or
                          w_cts15m00.clscod46  is null      )  and
                         (w_cts15m00.clscod44 <> "044"      and
                          w_cts15m00.clscod44  <> "44R"       or
                          w_cts15m00.clscod44  is null      )  and
                         (w_cts15m00.clscod48 <> "048"      and
                          w_cts15m00.clscod48  <> "48R"       or
                          w_cts15m00.clscod48  is null      )
                           then

                           let m_cts08g01 = null
                           let m_cts08g01 = cts08g01("A" ,"N" ,""
                                                   ,"NAO SERA PERMITIDO PROSSEGUIR"
                                                   ," COM MOTIVO 2-PORTO SOCORRO"
                                                   ," SEM CLAUSULA 33,33R,047,47R")

                         next field avialgmtv
                     end if
                end if
             end if
             if m_clcdat >= "01/05/2012" and
                d_cts15m00.avialgmtv = 3 and
                w_cts15m00.clscod44 = '044' then
                 error 'Motivo nao permitido para a clausula da apolice'
                 next field avialgmtv
             end if

             if d_cts15m00.vclloctip =  1    and
                d_cts15m00.avialgmtv =  4    then
                call cts08g01("A","S","","TIPO DE RESERVA SERA TROCADA",
                                         "PARA DEPARTAMENTO ?","")
                     returning ws.confirma

                if ws.confirma  =  "S"   then
                   let d_cts15m00.vclloctip = 3
                   let d_cts15m00.vcllocdes = "DEPTO."
                   display by name d_cts15m00.vclloctip
                   display by name d_cts15m00.vcllocdes

                   while true
                           call cts15m08(d_cts15m00.vclloctip,
                                     w_cts15m00.slcemp,
                                     w_cts15m00.slcsuccod,
                                     w_cts15m00.slcmat,
                                     w_cts15m00.slccctcod,
                                     "A" )               #--> (A)tualiza/(C)onsulta
                           returning w_cts15m00.slcemp,
                                     w_cts15m00.slcsuccod,
                                     w_cts15m00.slcmat,
                                     w_cts15m00.slccctcod,
                                     ws.nomeusu    #-> neste caso nome funcionari

                          if w_cts15m00.slcemp    is null or
                             w_cts15m00.slcsuccod is null or
                             w_cts15m00.slcmat    is null or
                             w_cts15m00.slcmat    is null then
                             error "Preenchimento obrigatorio"
                          else
                            exit while
                          end if
                  end while
                else
                   next field avialgmtv
                end if

             end if

             if d_cts15m00.vclloctip =  2    and
                d_cts15m00.avialgmtv <> 5    and
                d_cts15m00.avialgmtv <> 9    then
                error " Corretores so' podem fazer locacoes (5)PARTICULAR (9)Ind.Integral!"
                next field avialgmtv
             end if

             if d_cts15m00.vclloctip =  3    and
                d_cts15m00.avialgmtv <> 4    then
                error " Reserva tipo DEPTO. so' podem fazer locacoes DEPARTAMENTOS!"
                next field avialgmtv
             end if
             if d_cts15m00.vclloctip =  4    and
                d_cts15m00.avialgmtv <> 5    then
                error " Reservas tipo FUNC. so' podem fazer locacoes PARTICULAR!"
                next field avialgmtv
             end if

             if w_cts15m00.clscod26[1,2] = "80"  and
                d_cts15m00.avialgmtv   <> 1    then
                error " Clausula 80 so' permite locacao por motivo SINISTRO!"
                next field avialgmtv
             end if

                 open c_cts15m00_001 using d_cts15m00.avialgmtv

                 whenever error continue
                 fetch c_cts15m00_001 into d_cts15m00.avimtvdes
                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = 100 then
                       let d_cts15m00.avimtvdes = null
                    else
                       error 'Erro SELECT iddkdominio:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                       let m_erro = true
                       return
                    end if
                 end if



             if d_cts15m00.c24astcod = "H11" or
                d_cts15m00.c24astcod = "H13" then
                if d_cts15m00.avialgmtv = 5 then
                   let d_cts15m00.avimtvdes = "PARTICULAR"
                end if

                if d_cts15m00.avialgmtv = 6 then
                   let d_cts15m00.avimtvdes = "TER.SEG PORTO"
                end if
             end if
             #osf32867 - Paula

             display by name d_cts15m00.avimtvdes


#--------------------------------------------------------------#
#-Roberto- Se motivo for locacao de carro extra por particular
#          e feito por funcionario da Porto chamo a funcao
#          para a liberacao do processo
#--------------------------------------------------------------#

             {if ( d_cts15m00.c24astcod = "H10"   or
                  d_cts15m00.c24astcod = "H12" ) and
                  d_cts15m00.avialgmtv = 5       and
                  d_cts15m00.corsus <> "P5005J"  then

                   if d_cts15m00.doctxt is null then

                     for m_idx = 1 to 5

                         if (g_documento.corsus     = m_cts15m00b1[m_idx].corsus or
                             m_cts15m00b.corsus_ant = m_cts15m00b1[m_idx].corsus or
                             d_cts15m00.corsus      = m_cts15m00b1[m_idx].corsus or
                             g_documento.funmat     is not null                  or
                             g_documento.cgccpfnum  is not null                  or
                             g_documento.ctttel     is not null)                 and
                             d_cts15m00.corsus <> "P5005J"  then

                            call cts08g01("I","N", "",
                                                   "O VEICULO SELECIONADO NECESSITA DA LIBE-",
                                                   "RACAO DA COORDENACAO/APOIO DEVIDO AO ",
                                                   "GRUPO E MOTIVO DA RESERVA"
                                                   )
                            returning ws.confirma
                            call cts15m00b()
                            returning m_cts15m00b.erro,
                                      m_cts15m00b.mens,
                                      m_empcod,
                                      m_funmat

                            if m_cts15m00b.erro = 1 then
                               next field avialgmtv
                            else
                               let m_cts15m00b.ver_data = 1
                            end if

                            exit for
                         end if
                    end for
                   else

                    for m_idx = 1 to 5

                        if (d_cts15m00.corsus      = m_cts15m00b1[m_idx].corsus or
                            m_cts15m00b.corsus_ant = m_cts15m00b1[m_idx].corsus or
                            d_cts15m00.corsus is null )                         and
                            d_cts15m00.corsus <> "P5005J" then

                           call cts08g01("I","N", "",
                                                  "O VEICULO SELECIONADO NECESSITA DA LIBE-",
                                                  "RACAO DA COORDENACAO/APOIO DEVIDO AO ",
                                                  "GRUPO E MOTIVO DA RESERVA"
                                                  )
                           returning ws.confirma

                           call cts15m00b()
                           returning m_cts15m00b.erro,
                                     m_cts15m00b.mens,
                                     m_empcod,
                                     m_funmat
                           if m_cts15m00b.erro = 1 then
                                next field avialgmtv
                           else
                              let m_cts15m00b.ver_data = 1
                           end if

                           exit for
                        end if
                    end for
                  end if
             end if}

             if d_cts15m00.avialgmtv = 1  or
                d_cts15m00.avialgmtv = 3  or
                d_cts15m00.avialgmtv = 6  or #osf32867 - Paula
                d_cts15m00.avialgmtv = 7  or
                d_cts15m00.avialgmtv = 8  or
                d_cts15m00.avialgmtv = 9  or
                d_cts15m00.avialgmtv = 0  or
                d_cts15m00.avialgmtv = 13 or
                d_cts15m00.avialgmtv = 21 or
                d_cts15m00.avialgmtv = 23 or
                d_cts15m00.avialgmtv = 24 or
                d_cts15m00.avialgmtv = 14 then  ## Alberto claus 33

                if d_cts15m00.avialgmtv   <> 6 then #osf32867 - Paula

                   #------- Motivo 0 Sinistro Clausula 33 H10 ------------------#
                   if d_cts15m00.avialgmtv = 0 then
                      if ((w_cts15m00.clscod33 <> "033"  and # ???
                           w_cts15m00.clscod33 <> "33R"  or
                           w_cts15m00.clscod33 is null)  and
                           w_cts15m00.clscod46 <> '046'  and
                           w_cts15m00.clscod47 <> '047'  and
                           w_cts15m00.clscod46 <> '46R'  and
                           w_cts15m00.clscod47 <> '47R') then
                        call cts08g01("A","N",
                                         "MOTIVO 0-Sinis.Claus.33.  ",
                                         "SOMENTE CONTRATADA PARA CLAUSULA 33",
                                         "SUGERIR RESERVAR POR MOTIVO 9-Ind.Integral.",
                                         "")
                            returning ws.confirma
                            next field avialgmtv
                     end if
                     if lr_doc.viginc < '01/11/2008' and
                        w_cts15m00.clscod33[1,3] = "033" then
                        call cts08g01("A","N",
                                         "APOLICE ANTERIOR A 01/11/2008 !",
                                         "NAO SERA POSSIVEL EFETUAR RESERVA",
                                         "POR MOTIVO 0-Sinis.Claus.33.",
                                         "UTILIZE O 9-Ind.Integral.")
                            returning ws.confirma
                            next field avialgmtv
                      end if

                      if lr_doc.viginc >= '01/07/2010' and
                           w_cts15m00.clscod33[1,3] = "033" then
                             if lr_doc.viginc >= '01/09/2010' and
                                lr_doc.clalclcod = 29        then
                                call cts08g01_6l("A","N",
                                                 "NAO SERA PERMITIDO PROSSEGUIR COM O ",
                                                 "MOTIVO 0-SINISTRO CLAUS 33. ",
                                                 "VIGENCIA DA APOL/ENDOSSO POSTERIOR ",
                                                 "OU IGUAL 01/09/2010 E CLASSE DE",
                                                 "LOCALIZACAO 29. UTILIZE O ",
                                                 "MOTIVO 13- IND.INTEGRAL 30 DIAS ")

                                returning ws.confirma
                                next field avialgmtv
                              else
                                  call cts08g01_6l("A","N",
                                                   "NAO SERA PERMITIDO PROSSEGUIR COM O ",
                                                   "MOTIVO 0-SINISTRO CLAUS 33. ",
                                                   "VIGENCIA DA APOL/ENDOSSO POSTERIOR ",
                                                   "OU IGUAL 01/07/2010. UTILIZE O ",
                                                   "MOTIVO 13- IND.INTEGRAL 30 DIAS OU ",
                                                   "14-TEMPO INDETERMINADO PP ")
                                  returning ws.confirma
                                  next field avialgmtv

                              end if
                          end if
                   end if

                   if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                      d_cts15m00.avialgmtv = 7 and
                      (w_cts15m00.clscod44 ='44R' or
                       w_cts15m00.clscod48 ='048' or
                       w_cts15m00.clscod48 ='48R') then
                       call cts08g01("A","N",
                                     "MOTIVO 7-Terceiro Qualquer  ",
                                      "SOMENTE CONTRATADA PARA A CLAUSULA",
                                      "044",
                                     "")
                            returning ws.confirma
                       next field avialgmtv
                   end if
                   #---------- Motivo 7 Terceiro Qualquer H11 ------------------ #
                   if d_cts15m00.avialgmtv = 7 then
                      if w_cts15m00.clscod33[1,3] <> "033" and
                         w_cts15m00.clscod33[1,3] <> "33R" and
                         w_cts15m00.clscod46[1,3] <> "046" and
                         w_cts15m00.clscod46[1,3] <> "46R" and
                         w_cts15m00.clscod47[1,3] <> "047" then
                        call cts08g01("A","N",
                                      "MOTIVO 7-Terceiro Qualquer  ",
                                       "SOMENTE CONTRATADA PARA AS CLAUSULAS",
                                       "033/33R/046/047",
                                      "")
                         returning ws.confirma
                         next field avialgmtv
                     end if
                     if lr_doc.viginc < '01/01/2009' and
                        w_cts15m00.clscod33[1,3] = "033" then
                        call cts08g01("A","N",
                                      "APOLICE ANTERIOR A 01/01/2009 !",
                                      "NAO SERA POSSIVEL EFETUAR RESERVA",
                                      "POR MOTIVO 7-Terceiro Qualquer",
                                      "")
                         returning ws.confirma
                         next field avialgmtv
                      end if
                   end if
                   #---------------Motivo 8 Terceiro Segurado Porto H10 ------#
                   if d_cts15m00.avialgmtv = 8 then
                      if ((w_cts15m00.clscod33[1,3] <> "033" or
                           w_cts15m00.clscod33 is null )     and
                           w_cts15m00.clscod46[1,3] <> "046" and
                           w_cts15m00.clscod47[1,3] <> "047") then
                         call cts08g01("A","N",
                                       "MOTIVO 8-Seg Como Terc ",
                                       "SOMENTE CONTRATADA PARA AS CLAUSULAS",
                                       "033/046/047",
                                       "")
                          returning ws.confirma
                          next field avialgmtv
                      else

                          if (w_cts15m00.clscod46[1,3] = "46R"  or
                              w_cts15m00.clscod47[1,3] = "47R") then

                             call cts08g01("A","N",
                                           "MOTIVO 8-Seg Como Terc ",
                                           "SOMENTE CONTRATADA PARA AS CLAUSULAS",
                                           "033/046/047",
                                           "")
                             returning ws.confirma
                             next field avialgmtv
                          end if
                      end if
                      if lr_doc.viginc < '01/11/2008' and
                         w_cts15m00.clscod33[1,3] = "033" then
                         call cts08g01("A","N",
                                       "APOLICE ANTERIOR A 01/11/2008 !",
                                       "NAO SERA POSSIVEL EFETUAR RESERVA",
                                       "POR MOTIVO 8-Seg Como Terc ",
                                       "")
                          returning ws.confirma
                          next field avialgmtv
                      end if
                   end if
                   if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                      d_cts15m00.avialgmtv = 9 and
                      (w_cts15m00.clscod44 <> '44R' or
                       w_cts15m00.clscod48 is not null) then
                       call cts08g01("A","N",
                                          "CLAUSULA 44R NAO CONTRATADA !",
                                          "NAO SERA POSSIVEL EFETUAR RESERVA",
                                          "POR MOTIVO 9-Ind.Integral.",
                                          "SUGERIR RESERVAR POR MOTIVO 1-SINISTRO.")
                            returning ws.confirma
                       next field avialgmtv
                   end if
                   if d_cts15m00.avialgmtv = 9 then
                      if ((w_cts15m00.clscod33[1,3] <> "33R" or
                           w_cts15m00.clscod33[1,3] is null)  and
                          (w_cts15m00.clscod46[1,3] <> "46R" or
                           w_cts15m00.clscod46[1,3] is null)  and
                           w_cts15m00.clscod44[1,3] is null  and
                           w_cts15m00.clscod48[1,3] is null  and
                          (w_cts15m00.clscod47[1,3] <> "47R" or
                           w_cts15m00.clscod47[1,3] is null)) then
                         call cts08g01("A","N",
                                          "CLAUSULA 33R/46R/47R NAO CONTRATADA !",
                                          "NAO SERA POSSIVEL EFETUAR RESERVA",
                                          "POR MOTIVO 9-Ind.Integral.",
                                          "SUGERIR RESERVAR POR MOTIVO 1-SINISTRO.")
                             returning ws.confirma
                         next field avialgmtv
                      else
                        if lr_doc.viginc >= '01/11/2008' and
                           w_cts15m00.clscod33[1,3] = "033" then
                           call cts08g01("A","N",
                                           "APOLICE POSTERIOR OU IGUAL A 01/11/2008 !",
                                           "NAO SERA POSSIVEL EFETUAR RESERVA",
                                           "POR MOTIVO 9-Ind.Integral.",
                                           "UTILIZE 0-SINIS.CLAUS.33.")
                              returning ws.confirma
                              next field avialgmtv
                        end if
                      end if
                   end if
                   if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                      d_cts15m00.avialgmtv = 13 and
                      (w_cts15m00.clscod44 <> '044' or
                       w_cts15m00.clscod48 is not null) then
                       call cts08g01("A","N",
                                          "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                          "MOTIVO 13- IND.INTEGRAL 30 DIAS",
                                          "APOLICE SEM CLAUSULA 044", "")
                            returning ws.confirma
                       next field avialgmtv
                   else
                   if d_cts15m00.avialgmtv = 13 then
                      if w_cts15m00.clscod33[1,3] is null and
                         w_cts15m00.clscod44[1,3] is null and
                         w_cts15m00.clscod46[1,3] is null and
                         w_cts15m00.clscod47[1,3] is null and
                         w_cts15m00.clscod48[1,3] is null then
                         call cts08g01("A","N",
                                          "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                          "MOTIVO 13- IND.INTEGRAL 30 DIAS",
                                          "APOLICE SEM CLAUSULA 33.",
                                          "")
                              returning ws.confirma
                         next field avialgmtv
                      else
                        if lr_doc.viginc < '01/07/2010'     and
                           w_cts15m00.clscod33[1,3] = "033" then
                           if l_endosso = false                then
                              call cts08g01("A","N",
                                              "APOLICE COM VIGENCIA ANTERIOR  ",
                                              "A 01/07/2010 ",
                                              "UTILIZE 0-SINIS.CLAUS.33.",
                                              "")
                                 returning ws.confirma
                                 next field avialgmtv
                           else
                              call cts08g01("A","N",
                                                 "NAO SERA PERMITIDO PROSSEGUIR COM O ",
                                                 "MOTIVO 13-IND.INTEGRAL 30 DIAS, VIGENCIA",
                                                 "DA APOL/ENDOSSO ANTERIOR A 01/07/2010.",
                                                 "UTILIZE O MOTIVO 0-SINISTRO CLAUS 33")
                                    returning ws.confirma
                                    next field avialgmtv
                           end if
                        end if
                      end if
                   end if

                   end if
                   if m_clcdat >= '01/05/2012' and    #ligia fornax set/12
                      d_cts15m00.avialgmtv = 14 and
                      (w_cts15m00.clscod44 <> '044' or
                       w_cts15m00.clscod48 is not null) then
                       call cts08g01("A","N",
                                          "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                          "MOTIVO 14- TEMPO INDETERMINADO PERDA ",
                                          "PARCIAL. APOLICE SEM CLAUSULA 044",
                                          "")
                            returning ws.confirma
                       next field avialgmtv
                   else
	   	             if d_cts15m00.avialgmtv = 14 then
                      if w_cts15m00.clscod33[1,3] is null and
                         w_cts15m00.clscod44[1,3] is null and
                         w_cts15m00.clscod46[1,3] is null and
                         w_cts15m00.clscod47[1,3] is null and
                         w_cts15m00.clscod48[1,3] is null then
                         call cts08g01("A","N",
                                          "NAO SERA PERMITIDO PROSSEGUIR COM O  ",
                                          "MOTIVO 14- TEMPO INDETERMINADO PERDA ",
                                          "PARCIAL. APOLICE SEM CLAUSULA 33",
                                          "")
                             returning ws.confirma
                         next field avialgmtv
                      else
	   	                 if lr_doc.viginc < '01/07/2010' and
                           w_cts15m00.clscod33[1,3] = "033" then
                            if l_endosso = false then
                               call cts08g01("A","N",
                                               "APOLICE COM VIGENCIA ANTERIOR  ",
                                               "A 01/07/2010 ",
                                               "UTILIZE 0-SINIS.CLAUS.33.",
                                               "")
                                  returning ws.confirma
                                  next field avialgmtv
                            else
                              call cts08g01_6l("A","N",
                                               "NAO SERA PERMITIDO PROSSEGUIR COM O ",
                                               "MOTIVO 14-TEMPO INDETERMINADO PERDA ",
                                               "PARCIAL.VIGENCIA DA APOL/ENDOSSO ",
                                               "ANTERIOR A 01/07/2010. UTILIZE O ",
                                               "MOTIVO 0-SINISTRO CLAUS 33. ",
                                               "")
                              returning ws.confirma
                              next field avialgmtv
                            end if
                        else
	   	                   if lr_doc.viginc >= '01/09/2010' and
                             w_cts15m00.clscod33[1,3] = "033" and
                             lr_doc.clalclcod = 29        then
                             if l_endosso = false then
                                call cts08g01("A","N",
                                              "APOLICE COM VIGENCIA A PARTIR DE  ",
                                              "01/09/2010 E CLASSE DE LOCALIZACAO 29.",
                                              "SEM DIREITO A LOCA��O PARA SINISTRO DE ",
                                              " PERDA PARCIAL")
                             else
                                call cts08g01_6l("A","N",
                                              "NAO SERA PERMITIDO SEGUIR COM O MOTIVO",
                                              "14-TEMPO INDETERMINADO PERDA PARCIAL.",
                                              "VIGENCIA APOL/ENDOSSO A PARTIR DE ",
                                              "01/09/2010 E CLASSE DE LOCALIZACAO 29,",
                                              "SEM DIREITO A LOCACAO PARA SINISTRO DE ",
                                              "PERDA PARCIAL")
                                returning ws.confirma
                                next field avialgmtv
                             end if
                          end if
                        end if
                      end if
                   end if
                   end if


                   #-------------------------
                   # Verifica se existe reserva para este motivo no prazo de 04 dias
                   #-------------------------
                   call cts40g03_data_hora_banco(2)
                        returning l_data, l_hora2
                   let l_today = l_data - 4 units day

                   open c_cts15m00_002 using g_documento.succod
                                          ,g_documento.aplnumdig
                                          ,g_documento.itmnumdig
                                          ,l_today, l_data
                   foreach c_cts15m00_002 into ws_atdsrvnum, ws_atdsrvano
                      if g_documento.atdsrvnum is not null    and
                         g_documento.atdsrvnum = ws_atdsrvnum then
                         continue foreach
                      end if
                      select atdetpcod
                        into ws_atdetpcod
                        from datmsrvacp
                       where atdsrvnum = ws_atdsrvnum
                         and atdsrvano = ws_atdsrvano
                         and atdsrvseq = ( select max(atdsrvseq)
                                             from datmsrvacp
                                            where atdsrvnum = ws_atdsrvnum
                                              and atdsrvano = ws_atdsrvano )
                       open c_cts15m00_012 using ws_atdsrvnum
                                                ,ws_atdsrvano
                       fetch c_cts15m00_012 into ws_eds.avialgmtv

                       whenever error stop
                       if sqlca.sqlcode <> 0 then
                          if sqlca.sqlcode = notfound  then
                             error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
                          else
                             error 'Erro SELECT c_cts15m00_012 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
                             error 'CTS15M00 / consulta_cts15m00() / ',ws_atdsrvnum,' / '
                                                                      ,ws_atdsrvano   sleep 1
                          end if
                       end if
                       close c_cts15m00_012
                       if ws_eds.avialgmtv <> 2 and
                          ws_eds.avialgmtv <> 4 and
                          ws_eds.avialgmtv <> 7 and
                          ws_eds.avialgmtv <> 5 then
                            if ws_atdetpcod = 1 or
                               ws_atdetpcod = 4 then
                                if d_cts15m00.avialgmtv <> 7 then


                                         call cts08g01("A","N","",
                                                       "HA' RESERVA(S) COM MOTIVO(S) ",
                                                       "DE SINISTRO, FAVOR VERIFICAR!","")
                                         returning ws.confirma

                                   next field avialgmtv
                                end if
                            end if
                       end if

                   end foreach
                   ##

                   if   m_tem_33_26 = 3           and  ## possui claus.33 e 26
                      ( ws_atdsrvnum is not null  and  ## Alberto verificar
                        ws_atdsrvano is not null) and  ## Alberto verificar
                        d_cts15m00.avialgmtv = 9 then
                        let m_cts08g01 = null
                        let m_cts08g01 = cts08g01("A" ,"N" ,"JA EXISTE RESERVA ANTERIOR MOTIVO 9,"
                                                  ,"SUGERIR RESERVAR POR MOTIVO"
                                                  ,"1-SINISTRO."
                                                  ,"")
                        next field avialgmtv
                   else

                       if d_cts15m00.avialgmtv = 9  and
                          m_tem_33_26 = 2           then ## Somente claus 33
                          if cts15m00_ver_mtv9( g_documento.succod
                                               ,g_documento.aplnumdig
                                               ,g_documento.itmnumdig ) then
                             let m_cts08g01 = null
                             let m_cts08g01 = cts08g01("A" ,"N" ,"JA EXISTE RESERVA ANTERIOR MOTIVO 9,"
                                                       ,""
                                                       ,"FAVOR VERIFICAR!"
                                                       ,"")
                             next field avialgmtv
                          end if
                       end if
                   end if

                end if  #osf32867 - Paula

                   if d_cts15m00.avialgmtv = 6 then
                      call salvaglobal_cts15m00("S")

                      call cta00m01(g_documento.apoio,
                                    g_documento.empcodatd,
                                    g_documento.funmatatd,
                                    g_documento.usrtipatd,
                                    g_documento.c24astcod,
                                    g_documento.solnom,
                                    g_documento.c24soltipcod,
                                    g_c24paxnum)
                          returning lr_documento.*,
                                    lr_ppt.*,
                                    la_pptcls[1].*,
                                    la_pptcls[2].*,
                                    la_pptcls[3].*,
                                    la_pptcls[4].*,
                                    la_pptcls[5].*



                      if(g_documento.succod    is not null and
                         g_documento.ramcod    is not null and
                         g_documento.aplnumdig is not null and
                         g_documento.itmnumdig is not null) or
                        (g_documento.prporg    is not null and
                         g_documento.prpnumdig is not null)then

                         let slv_terceiro.succod    = g_documento.succod
                         let slv_terceiro.ramcod    = g_documento.ramcod
                         let slv_terceiro.aplnumdig = g_documento.aplnumdig
                         let slv_terceiro.itmnumdig = g_documento.itmnumdig
                         let slv_terceiro.prporg    = g_documento.prporg
                         let slv_terceiro.prpnumdig = g_documento.prpnumdig

                         call salvaglobal_cts15m00("N")
                      else
                         error "Apolice do reclamante nao localizada."
                         call salvaglobal_cts15m00("N")
                         next field avialgmtv
                      end if

                      call cts05g00(slv_terceiro.succod
                                   ,slv_terceiro.ramcod
                                   ,slv_terceiro.aplnumdig
                                   ,slv_terceiro.itmnumdig)
                           returning w_ret.*
                   end if
                  #osf32867 - Paula

                 if d_cts15m00.avialgmtv <> 6 then
                    let slv_terceiro.succod    = null
                    let slv_terceiro.aplnumdig = null
                    let slv_terceiro.itmnumdig = null
                    let w_ret.vclchsinc        = null
                    let w_ret.vclchsfnl        = null
                    let w_ret.vcllicnum        = null
                 end if


                 call cts15m07(g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,slv_terceiro.succod
                              ,slv_terceiro.aplnumdig
                              ,slv_terceiro.itmnumdig
                              ,w_ret.vclchsinc
                              ,w_ret.vclchsfnl
                              ,w_ret.vcllicnum
                              ,w_cts15m00.avioccdat
                              ,w_cts15m00.ofnnom
                              ,w_cts15m00.ofndddcod
                              ,w_cts15m00.ofntelnum
                              ,d_cts15m00.avialgmtv
                              ,w_cts15m00.clscod )
                    returning w_cts15m00.avioccdat, w_cts15m00.ofnnom,
                              w_cts15m00.ofndddcod, w_cts15m00.ofntelnum,
                              d_cts15m00.avialgmtv, d_cts15m00.dtentvcl

                 let w_cts15m00.datasaldo = w_cts15m00.avioccdat
                 if w_cts15m00.avioccdat is null  then
                    error " Faltam informacoes para locacao por motivo de sinistro!"
                    next field avialgmtv
                 end if

                case d_cts15m00.avialgmtv
                   when 1  let d_cts15m00.avimtvdes = "SINISTRO"
                   when 3  let d_cts15m00.avimtvdes = "BENEF.OFICINA"
                   when 5  let d_cts15m00.avimtvdes = "PARTICULAR"
                   when 6  let d_cts15m00.avimtvdes = "TERC.SEG PORTO" #osf32867-Paula
                   when 9  let d_cts15m00.avimtvdes = "IND.INTEGRAL"
                   when 0  let d_cts15m00.avimtvdes = "Sinis.Claus33"
                   when 21	let d_cts15m00.avimtvdes = "BENEF. DE SINISTRO PP"
                   when 23	let d_cts15m00.avimtvdes = "SEG C/TERC CONG/PORTO/INTEG"
                   when 24	let d_cts15m00.avimtvdes = "IND.INTEGRAL"

                end case
                display by name d_cts15m00.avialgmtv
                display by name d_cts15m00.avimtvdes
             else
                initialize w_cts15m00.avioccdat, w_cts15m00.ofnnom   ,
                           w_cts15m00.ofndddcod, w_cts15m00.ofntelnum  to null
             end if

             let w_cts15m00.avialgmtv = d_cts15m00.avialgmtv
#-------   -------------------------------------------------------------
# Locaca   o para DEPARTAMENTOS
#-------   -------------------------------------------------------------

             if d_cts15m00.avialgmtv  =  4  or
                d_cts15m00.vclloctip  =  4  then
                if g_documento.atdsrvnum is not null  and
                   g_documento.atdsrvano is not null  then

                   while true
                      call cts15m08(d_cts15m00.vclloctip,
                                    w_cts15m00.slcemp,
                                    w_cts15m00.slcsuccod,
                                    w_cts15m00.slcmat,
                                    w_cts15m00.slccctcod,
                                    "A" )               #--> (A)tualiza/(C)onsulta
                          returning w_cts15m00.slcemp,
                                    w_cts15m00.slcsuccod,
                                    w_cts15m00.slcmat,
                                    w_cts15m00.slccctcod,
                                    ws.nomeusu    #-> neste caso nome funcionari

                          if w_cts15m00.slcemp    is null or
                             w_cts15m00.slcsuccod is null or
                             w_cts15m00.slcmat    is null or
                             w_cts15m00.slcmat    is null then
                             error "Preenchimento obrigatorio"
                          else
                            exit while
                          end if

                   end while
                end if
             end if

             if (g_documento.atdsrvnum is null   or
                 g_documento.atdsrvano is null)  then

                 if m_cts15m00b.ver_data = 1 then
                       let m_cts15m00b.ver_data = -1
                 else
                       let m_cts15m00b.ver_data = ""
                 end if

                 call cts15m04("R"                  , d_cts15m00.avialgmtv,
                               ""                   , w_cts15m00.aviretdat,
                               w_cts15m00.avirethor , w_cts15m00.aviprvent,
                               m_cts15m00b.ver_data , ws.endcep
                                                    , d_cts15m00.dtentvcl)
                     returning w_cts15m00.aviretdat , w_cts15m00.avirethor,
                               w_cts15m00.aviprvent  , ws.cct, ws.cct, ws.cct

                 let ws.diasem = weekday(w_cts15m00.aviretdat)
             end if


   before field garantia
     display by name d_cts15m00.garantia
      let m_cts15ant.garantia = d_cts15m00.garantia

     if m_alt_motivo = true then
        exit input
     else
        next field flgarantia
     end if

   after field garantia
      display by name d_cts15m00.garantia

   before field flgarantia


      if g_documento.acao <> 'ALT' and
         g_documento.acao <> 'CAN' then
         let   m_opcao = null
         call cts15m00_popup_garantia()
      end if

        if d_cts15m00.garantia is null then
           let d_cts15m00.garantia = "Garantia:"
        else
           let d_cts15m00.garantia = d_cts15m00.garantia clipped , ':'
        end if


        display by name d_cts15m00.garantia
        display by name d_cts15m00.flgarantia
        let m_cts15ant.flgarantia = d_cts15m00.flgarantia

   after  field flgarantia
          display by name d_cts15m00.flgarantia

          if d_cts15m00.flgarantia is null or
             d_cts15m00.flgarantia = "N" then

              call cts15m00_popup_garantia()

          end if

          if d_cts15m00.garantia is null then
             let d_cts15m00.garantia = "Garantia"
          else
              let d_cts15m00.garantia = d_cts15m00.garantia clipped, ':'
          end if

          display by name d_cts15m00.garantia
          display by name d_cts15m00.flgarantia

          if m_opcao = 1 then
             let d_cts15m00.cauchqflg = "N"
             if g_documento.ciaempcod <> 35 then
                      # alterado a msg e o valor de 500,00 para 800,00. Carla P.Socorro 02/05/08
                      # Psi Carro extra Medio porte 12/01/2010
                      if (w_cts15m00.clscod26 = "26H" or
                          w_cts15m00.clscod26 = "26I" or
                          w_cts15m00.clscod26 = "26J" or
                          w_cts15m00.clscod26 = "26K" or
                          w_cts15m00.clscod26 = "26L" or
                          w_cts15m00.clscod26 = "26M") and
                          d_cts15m00.avialgmtv = 1 then
                           call cts08g01("I","S",
                                       "CARTAO SUJEITO A PRE-ANALISE. ",
                                       "A GARANTIA DE CREDITO DEVERA SER ",
                                       "CONSULTADA NA LOCADORA. ",
                                       "")
                           returning ws.confirma

                           if ws.confirma = "N" then
                              next field flgarantia
                           end if
                      else

                           call cts08g01("I","S",
                                       "CARTAO SUJEITO A PRE-ANALISE COM GARANTI",
                                       "A DE CREDITO DE R$800,00 PARA LOCACAO DE",
                                       "VEICULOS DOS GRUPOS A e B.PARA OS DEMAIS",
                                       "GRUPOS,CONSULTAR GARANTIA COM A LOCADORA")
                           returning ws.confirma

                           if ws.confirma = "N" then
                              next field flgarantia
                           end if

                     end if
             else
                call cts08g01("I","S","","CARTAO SUJEITO A PRE-ANALISE","",
                              "COM GARANTIA DE CREDITO DE R$800,00.")
                 returning ws.confirma

                 if ws.confirma = "N" then
                    next field flgarantia
                 end if

             end if
          else
              if m_opcao = 2 then
                 call cts08g01("A","S","",
                                         "A OPCAO PARA LOCACAO DEVERA SER FEITA",
                                         "","POR INTERMEDIO DE CHEQUE CAUCAO?")
                       returning ws.confirma
                 if ws.confirma = "S" then
                    let d_cts15m00.cauchqflg = "S"
                 else
                    next field flgarantia
                 end if
              end if

              if m_opcao = 3 then
                 call cts08g01_6l("A","S","",
                               "A OPCAO DE ISENCAO DE GARANTIA ",
                               "DISPENSAR� APRESENTACAO DE CARTAO DE ",
                               "CREDITO OU CHEQUE CAUCAO SOB TOTAL",
                               "RESPONSABILIDADE DA PORTO SEGURO",
                               "")
                       returning ws.confirma

                 if ws.confirma = "N" then
                    next field flgarantia
                 end if
              end if

          end if

          if ((d_cts15m00.c24astcod = 'H10' or d_cts15m00.c24astcod = 'H12') and
             (d_cts15m00.avialgmtv = 1 or d_cts15m00.avialgmtv = 5)) or
             ((d_cts15m00.c24astcod = 'H11' or d_cts15m00.c24astcod = 'H13') and
              d_cts15m00.avialgmtv = 5     and
              slv_terceiro.aplnumdig is not null) then
             let d_cts15m00.lcvsinavsflg = 'N'
             next field lcvsinavsflg
          else
             let d_cts15m00.lcvsinavsflg = 'N'
             display by name d_cts15m00.lcvsinavsflg
             next field lcvcod
          end if

   before field lcvsinavsflg

      ##psi 217956
      if g_documento.ramcod <> 31 and g_documento.ramcod <> 531 then
         next field lcvcod
      end if

      display by name d_cts15m00.lcvsinavsflg     attribute (reverse)

      # ---> CONFORME SOLICITACAO ROSANA/BEATRIZ NO DIA 03/02/2006
      if (d_cts15m00.c24astcod = "H11" or d_cts15m00.c24astcod = 'H13') and
         d_cts15m00.avialgmtv = 5     then
         let d_cts15m00.lcvsinavsflg = "S"
         display by name d_cts15m00.lcvsinavsflg
         next field lcvcod
      end if
      let m_cts15ant.lcvsinavsflg = d_cts15m00.lcvsinavsflg

   after field lcvsinavsflg
      display by name d_cts15m00.lcvsinavsflg

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         next field avialgmtv
      end if

      if d_cts15m00.lcvsinavsflg <> 'S' and
         d_cts15m00.lcvsinavsflg <> 'N' then
         error 'Informe "S" ou "N"'  sleep 1
         next field lcvsinavsflg
      end if

   before field lcvcod
          display by name d_cts15m00.lcvcod     attribute (reverse)
          let m_cts15ant.lcvcod    = d_cts15m00.lcvcod
          let m_cts15ant.lcvextcod = d_cts15m00.lcvextcod
          
          
          if g_nova.delivery then
          	
            #----------------------------------------------     	
            # Recupera o Codigo da Locadora e Loja                  	
            #----------------------------------------------     	
          	
          	call ctn18c00_delivery(g_nova.clisgmcod       ,
          	                       g_nova.dctsgmcod       ,
          	                       a_cts15m00[2].ufdcod   ,
          	                       a_cts15m00[2].cidnom   ,
          	                       a_cts15m00[2].brrnom   ,
          	                       a_cts15m00[2].lgdnom   ,
          	                       a_cts15m00[2].lclltt   ,
          	                       a_cts15m00[2].lcllgt   )
          	returning d_cts15m00.lcvcod    ,
          	          d_cts15m00.aviestcod ,
          	          ws.vclpsqflg
          	
               
          	
          	if d_cts15m00.lcvcod     is not null and 
          		 d_cts15m00.aviestcod  is not null then
          	
          	   call cts15m00_descricao_loja(d_cts15m00.lcvcod    ,   
          	                                d_cts15m00.aviestcod )   
          	   returning  d_cts15m00.lcvextcod,                          
          	              d_cts15m00.aviestnom
          	              
          	              
          	   select lcvnom       , 
          	          lcvstt       , 
          	          adcsgrtaxvlr , 
          	          cdtsegtaxvlr , 
          	          acntip   
               into d_cts15m00.lcvnom       ,
                    ws.lcvstt               ,
                    ws.adcsgrtaxvlr         ,                               
                    d_cts15m00.cdtsegtaxvlr,
                    d_cts15m00.acntip
               from datklocadora
               where lcvcod = d_cts15m00.lcvcod           
                                                  	            	  
          	   let m_cts15ant.lcvcod    = d_cts15m00.lcvcod      
          	   let m_cts15ant.lcvextcod = d_cts15m00.lcvextcod
          	   
          	   display by name d_cts15m00.lcvcod  
          	   display by name d_cts15m00.lcvnom
          	   display by name d_cts15m00.lcvextcod
          	   display by name d_cts15m00.aviestnom
          	    
          	   next field cdtoutflg
          	else
          		 error "Loja do Delivery Inexistente para esse Endereco!" sleep 2
          	end if
          	          	
          end if	

   after  field lcvcod
          display by name d_cts15m00.lcvcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if ((d_cts15m00.c24astcod = 'H10' or d_cts15m00.c24astcod = 'H12') and
                 (d_cts15m00.avialgmtv = 1 or d_cts15m00.avialgmtv = 5)) or
                ((d_cts15m00.c24astcod = 'H11' or d_cts15m00.c24astcod = 'H13') and
                 d_cts15m00.avialgmtv = 5     and
                 slv_terceiro.aplnumdig is not null) then
                 next field lcvsinavsflg
             else
                next field avialgmtv
             end if
          end if

             ##Verifica se trocou locadora
             if g_documento.acao = "ALT" and
                m_cts15ant.lcvcod <> d_cts15m00.lcvcod then
                initialize m_reserva.*  to null

                call ctd31g00_ver_reserva(1, g_documento.atdsrvnum,
                                             g_documento.atdsrvano)
                     returning m_reserva.rsvlclcod, m_reserva.rsvsttcod

                if m_reserva.rsvlclcod is not null and
                   m_reserva.rsvlclcod <> 0 and
                   m_reserva.rsvsttcod = 2 then
                   let l_linha2 = 'RESERVA COM NR LOCALIZADOR: ',
                                  m_reserva.rsvlclcod clipped
                   call cts08g01("A","N",
                                 'ALTERACAO DA LOCADORA NAO PERMITIDA.',
                                 l_linha2,
                                 'NECESSARIO CANCELAR ESTA E REALIZAR',
                                 'OUTRA NA NOVA LOCADORA ESCOLHIDA')
                          returning ws.confirma
                   let d_cts15m00.lcvcod = m_cts15ant.lcvcod
                   next field lcvcod
                end if

             end if
          if d_cts15m00.avialgmtv = 3  or
             d_cts15m00.avialgmtv = 6  or
             d_cts15m00.avialgmtv = 21 or
             d_cts15m00.avialgmtv = 24 then

###############################################################################
# Comentado em 11/05/1998 a pedido do Sr. Marcelo Valeriano para possibilitar #
# atendimento as oficinas em Salvador, conforme correio de solicitacao.       #
#-----------------------------------------------------------------------------#
#            if d_cts15m00.lcvcod = 2  or    ##  Localiza Rent a Car
###############################################################################

             if d_cts15m00.lcvcod = 5  then  ##  Mega Rent a Car
                error " Locadora nao permitida para motivo BENEFICIO OFICINAS!"
                next field lcvcod
             end if
          end if



          if d_cts15m00.lcvcod is null then
             error " Codigo da locadora deve ser informado!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null  or
                ws.endcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field lcvcod
             else
               #carro extra porte medio
               if d_cts15m00.avialgmtv = 5    and
                  d_cts15m00.c24astcod = 'H10' then
                  if w_cts15m00.clscod26 = "26H" or
                     w_cts15m00.clscod26 = "26I" or
                     w_cts15m00.clscod26 = "26J" or
                     w_cts15m00.clscod26 = "26K" or
                     w_cts15m00.clscod26 = "26L" or
                     w_cts15m00.clscod26 = "26M" then
                     let l_linha1 = "APOLICE POSSUI CLAUSULA ",w_cts15m00.clscod26 clipped , ". CASO HAJA"
                     let l_linha2 = " INTEN��O DE REVERSAO PARA MOTIVO"
                     let l_linha3 = "1-SINISTRO, ESCOLHA A REDE LOCALIZA E "
                     let l_linha4 = "GRUPOS DE VEICULOS F OU M."
                     call cts08g01("A","N",l_linha1,l_linha2,
                                           l_linha3,l_linha4)
                          returning ws.confirma
                  end if
                  call ctn18c00 ("", ws.endcep, ws.endcepcmp, "",
                                 ws.diasem, 1, d_cts15m00.avialgmtv,
                                 g_documento.ciaempcod)          #PSI 205206
                       returning d_cts15m00.lcvcod   ,
                                 d_cts15m00.aviestcod,
                                 ws.vclpsqflg
               else
                  call ctn18c00 ("", ws.endcep, ws.endcepcmp,w_cts15m00.clscod,
                                 ws.diasem, 1, d_cts15m00.avialgmtv,
                                 g_documento.ciaempcod)          #PSI 205206
                       returning d_cts15m00.lcvcod   ,
                                 d_cts15m00.aviestcod,
                                 ws.vclpsqflg
               end if
                initialize d_cts15m00.lcvextcod, d_cts15m00.aviestnom to null
               
                   
                call cts15m00_descricao_loja(d_cts15m00.lcvcod    ,   
                                             d_cts15m00.aviestcod )
                returning d_cts15m00.lcvextcod,                             
                          d_cts15m00.aviestnom                      
                                               
                   
             end if
          end if

          select lcvnom, lcvstt, adcsgrtaxvlr, cdtsegtaxvlr, acntip   #PSI198390
            into d_cts15m00.lcvnom,
                 ws.lcvstt,
                 ws.adcsgrtaxvlr,                               #PSI198390
                 d_cts15m00.cdtsegtaxvlr,
                 d_cts15m00.acntip
            from datklocadora
           where lcvcod = d_cts15m00.lcvcod

          if sqlca.sqlcode <> 0  then
             error " Locadora nao cadastrada!"
             next field lcvcod
          else
             if ws.lcvstt <> "A"  then
                error " Locadora cancelada!"
                next field lcvcod
             end if
          end if

          display by name d_cts15m00.lcvnom

   before field lcvextcod
          display by name d_cts15m00.lcvextcod attribute (reverse)
          if m_cts15ant.lcvextcod is null then
             let m_cts15ant.lcvextcod = d_cts15m00.lcvextcod
          end if

   after  field lcvextcod
          display by name d_cts15m00.lcvextcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field lcvcod
          end if

          if d_cts15m00.lcvextcod is null  then
             error " Informe a loja para retirada do veiculo!"

             call ctn00c02 (ws.ufdcod,ws.cidnom," "," ")
                 returning ws.endcep, ws.endcepcmp

             if ws.endcep is null     then
                error " Nenhum criterio foi selecionado!"
             else

                 call ctn18c00 (d_cts15m00.lcvcod, ws.endcep, ws.endcepcmp,
                                w_cts15m00.clscod, ws.diasem, 0, 0,
                                g_documento.ciaempcod)       #PSI 205206
                 returning ws.lcvcod, d_cts15m00.aviestcod, ws.vclpsqflg

                initialize d_cts15m00.lcvextcod, d_cts15m00.aviestnom to null
   
                call cts15m00_descricao_loja(d_cts15m00.lcvcod    ,      
                                             d_cts15m00.aviestcod )      
                returning  d_cts15m00.lcvextcod,                             
                           d_cts15m00.aviestnom                              
                   
           

             end if
             next field lcvextcod
          else
             select aviestcod   ,         aviestnom,
                    vclalglojstt,         lcvlojtip,
                    lcvregprccod,         cauchqflg,
                    prtaertaxvlr
               into d_cts15m00.aviestcod, d_cts15m00.aviestnom,
                    ws.vclalglojstt     , ws.lcvlojtip,
                    ws.lcvregprccod     , ws.cauchqflg,
                    ws.prtaertaxvlr
               from datkavislocal
              where lcvcod    = d_cts15m00.lcvcod
                and lcvextcod = d_cts15m00.lcvextcod

             if sqlca.sqlcode = notfound  then
                error " Loja nao cadastrada ou nao pertencente a esta locadora!"
                next field lcvextcod
             end if

             if ws.vclalglojstt <>  1   then
                if ws.vclalglojstt =  2   then  # <-- verifica periodo bloqueio
                   initialize ws2.*  to null
                   select viginc, vigfnl
                     into ws2.viginc, ws2.vigfnl
                     from datklcvsit
                    where datklcvsit.lcvcod     = d_cts15m00.lcvcod
                      and datklcvsit.aviestcod  = d_cts15m00.aviestcod

                   if sqlca.sqlcode = 0 then
                      if ws2.viginc <= w_cts15m00.aviretdat and
                         ws2.vigfnl >= w_cts15m00.aviretdat then
                         error " Loja bloqueada para esta data! periodo de bloqueio ",ws2.viginc," a ",ws2.vigfnl
                         next field lcvextcod
                        else
                         error " ATENCAO: Loja bloqueada para locacao no periodo de ",ws2.viginc," a ",ws2.vigfnl,"!"
                      end if
                   end if
                  else
                   error " Loja cancelada! Selecione outra loja."
                   next field lcvextcod
                end if
             end if

             if w_cts15m00.clscod is not null and
                 d_cts15m00.avialgmtv <> 5    and
                 d_cts15m00.avialgmtv <> 4    then
                let n_lcvcod = 0
                select count(*)  into n_lcvcod
                  from datrclauslocal
                 where lcvcod    = d_cts15m00.lcvcod     and
                       aviestcod = d_cts15m00.aviestcod  and
                       ramcod    in (31,531)             and
                       clscod    = w_cts15m00.clscod

             -- if sqlca.sqlcode = notfound  then
                if  n_lcvcod = 0 then
                   error " Loja nao disponivel para atendimento a clausula ", w_cts15m00.clscod, "!"
                   next field lcvextcod
                end if
             end if

             if d_cts15m00.cauchqflg = "S" then
                if ws.cauchqflg = "N"    or
                   ws.cauchqflg is null  then
                   call cts08g01("I","N","","LOJA SELECIONADA NAO ACEITA",
                                         "","CHEQUE CAUCAO.")
                        returning ws.confirma
                   next field lcvextcod
                end if
             end if

             display by name d_cts15m00.aviestnom

          end if

          if ws.prtaertaxvlr is not null and
             ws.prtaertaxvlr <> 0        then
             let ws.msgtxt = "SERAO ACRESCIDOS EM ",
                              ws.prtaertaxvlr using "<<&.&&",
                             "% REFERENTE"
             call cts08g01("I","N", "OS VALORES QUE FICAREM SOB",
                                    "RESPONSABILIDADE DO SEGURADO/USUARIO",
                                     ws.msgtxt,
                                    "A TAXA AEROPORTUARIA.")
                 returning ws.confirma
            else  # lojas fora do aeroporto
             # Solicitacao da Carla Alexandra(P.S) e Beatriz, quando for loja
             # Localiza e motivo particular apresenta o alerta. 09/04/2007

               if d_cts15m00.lcvcod    = 2 then # Ajuste conforme Angela Queiroz/Cibele informou em 17/07/2014 as 15:44
               #if d_cts15m00.lcvcod    = 2 and  -- Localiza #
               #   d_cts15m00.avialgmtv = 5 then -- Motivo Particular

               # Solicitado Por Catia/Cibeli, para apresentar a msg independente de Tipo e Motivo.
               # E-Mail da Cibele de confirma��o em :-18/06/2014 09:13
               # Pasta \\pfs01\DOC_MDS\Central 24 Horas\Atendimento Segurado\Documenta��o de Projeto\ST-2014-00013-Tarifa Porto Auto Mar 2014\AlertaCarroExtra

                  call cts08g01 ("A","N",
                                 "Os valores referentes as taxas de servi-",
                                 "cos que ficarem sob responsabilidade  do",
                                 "usuario serao acrescidos de 12% para esta",
                                 "loja.")
                       returning ws.confirma
               end if
          end if

          if (g_documento.atdsrvnum is null   or
              g_documento.atdsrvano is null)  then
              # -- CT 268615 - Katiucia -- #
              ##let l_vcldevdat = w_cts15m00.aviretdat +
              ##                  w_cts15m00.aviprvent units day
              call cts15m04_valloja(d_cts15m00.avialgmtv,
                                    d_cts15m00.aviestcod,
                                    w_cts15m00.aviretdat,
                                 ## l_vcldevdat,
                                    w_cts15m00.avirethor,
                                    w_cts15m00.aviprvent,
                                    d_cts15m00.lcvcod   ,
                                    ws.endcep   )
                  returning ws.confirma
              if ws.confirma = "N" then
                 next field lcvextcod
              end if
          end if



   before field cdtoutflg
          #PSI 198390
          #exibir alerta informando se locadora cobra taxa 2 condutor
          if d_cts15m00.cdtsegtaxvlr is not null and
             d_cts15m00.cdtsegtaxvlr > 0 then
             call cts08g01("I","N", "", "LOCADORA COBRA TAXA DIARIA DE ",
                                        "2� CONDUTOR",
                                         d_cts15m00.cdtsegtaxvlr)
                      returning ws.confirma
          end if
          display by name d_cts15m00.cdtoutflg     attribute (reverse)
          let m_cts15ant.cdtoutflg = d_cts15m00.cdtoutflg

   after  field cdtoutflg
          display by name d_cts15m00.cdtoutflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             
             if g_nova.delivery then
                next field avialgmtv
             else   
                next field lcvextcod
             end if
                
          end if

          if d_cts15m00.cdtoutflg is null  or
            (d_cts15m00.cdtoutflg <> "S"   and
             d_cts15m00.cdtoutflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field cdtoutflg
          end if

          if d_cts15m00.cdtoutflg = "S"  then
             # mensagem alterada, solicitado por Judite da ct24hs. 02/05/08
             let ws.confirma = cts08g01("A","N",
                                        "SEGUNDO(S) CONDUTOR(ES):",
                                        "APRESENTAR NA LOCADORA COPIA RG/CPF E",
                                        "HABILITACAO. INFORMAR NO FAX NOME",
                                        "COMPLETO E VINCULO COM O SEGURADO.")
             #let ws.confirma = cts08g01("A","N","","DEVERA SER FORNECIDO A LOCADORA",
             #                                      "COPIAS DO RG, CIC E HABILITACAO",
             #                                      "DO(S) SEGUNDO(S) CONDUTOR(ES).")
             #exibir valor da taxa de 2 condutor da locadora
             display by name d_cts15m00.cdtsegtaxvlr
          else
             #PSI 198390
             display " " to cdtsegtaxvlr
          end if



   before field avivclcod
          display by name d_cts15m00.avivclcod  attribute (reverse)
          let m_cts15ant.avivclcod = d_cts15m00.avivclcod

   after  field avivclcod
          display by name d_cts15m00.avivclcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field cdtoutflg
          end if

          # ---> ORDENACAO DOS VEICULOS NORMAL
          let l_tipo_ordenacao = "N"

          if d_cts15m00.avialgmtv = 1  or
             d_cts15m00.avialgmtv = 3  or
             d_cts15m00.avialgmtv = 6  or
             d_cts15m00.avialgmtv = 21 or
             d_cts15m00.avialgmtv = 24 then

             initialize lr_dados, lr_funapol to null

             if d_cts15m00.avialgmtv = 6 then
                # ---> BUSCA A ULTIMA SITUACAO DO VEICULO COM OS DADOS DO TERCEIRO
                call f_funapol_ultima_situacao(slv_terceiro.succod,
                                               slv_terceiro.aplnumdig,
                                               slv_terceiro.itmnumdig)
                     returning lr_funapol.*

                # ---> PASSA OS DADOS DA APOLICE DO TERCEIRO
                let lr_dados.succod    = slv_terceiro.succod
                let lr_dados.aplnumdig = slv_terceiro.aplnumdig
                let lr_dados.autsitatu = lr_funapol.autsitatu
                let lr_dados.itmnumdig = slv_terceiro.itmnumdig
                let lr_dados.edsnumref = slv_terceiro.edsnumref
             else
                let lr_dados.succod    = g_documento.succod
                let lr_dados.aplnumdig = g_documento.aplnumdig
                let lr_dados.autsitatu = g_funapol.autsitatu
                let lr_dados.itmnumdig = g_documento.itmnumdig
                let lr_dados.edsnumref = g_documento.edsnumref
             end if

          end if


          let l_concede_ar = true

          if l_concede_ar then
             let l_tipo_ordenacao = "A"  # ---> ORDENA OS VEICULOS POR AR CONDICIONADO
          else
             let l_tipo_ordenacao = "N"  # ---> ORDENACAO DOS VEICULOS NORMAL
          end if

          if d_cts15m00.avivclcod  is null   or
             d_cts15m00.avivclcod  =  "  "   then
             error " Escolha veiculo de preferencia. Se nao disponivel sera reservado outro do grupo!"
            
             if g_nova.dctsgmcod      = 1     and 
             	  g_documento.c24astcod = "H10" then
             	
                if g_nova.reversao = "N"    and
                   d_cts15m00.avialgmtv = 5 then   
                   	
                   call ctn17c00(d_cts15m00.lcvcod    ,   	
                                 d_cts15m00.aviestcod ,   	
                                 l_tipo_ordenacao     ,   	
                                 g_documento.ciaempcod,   	
                                 d_cts15m00.avialgmtv ,   	
                                 w_cts15m00.clscod)       	
                   returning d_cts15m00.avivclcod         	
                   	
                else
                               
                   call ctn17c00_delivery(d_cts15m00.lcvcod    ,         
                                          d_cts15m00.aviestcod ,         
                                          l_tipo_ordenacao     ,         
                                          g_documento.ciaempcod,         
                                          d_cts15m00.avialgmtv ,         
                                          w_cts15m00.clscod)             
                   returning d_cts15m00.avivclcod
               end if
            else                 
                
                call ctn17c00(d_cts15m00.lcvcod    ,
                              d_cts15m00.aviestcod ,
                              l_tipo_ordenacao     ,
                              g_documento.ciaempcod,  
                              d_cts15m00.avialgmtv ,
                              w_cts15m00.clscod)                  
                returning d_cts15m00.avivclcod

             end if 

             next field avivclcod

          end if
          select lcvcod   , avivclmdl,
                 avivcldes, avivclgrp,
                 avivclstt,
                 frqvlr, isnvlr, rduvlr                #PSI 198390
            into ws.lcvcod   , ws.avivclmdl,
                 ws.avivcldes, d_cts15m00.avivclgrp,
                 ws.avivclstt,
                 d_cts15m00.frqvlr,                    #PSI 198390
                 d_cts15m00.isnvlr,                    #PSI 198390
                 d_cts15m00.rduvlr                     #PSI 198390
            from datkavisveic
           where lcvcod    = d_cts15m00.lcvcod
             and avivclcod = d_cts15m00.avivclcod

          if sqlca.sqlcode = notfound  then
             error " Veiculo nao cadastrado !"
             next field avivclcod
          end if

          ## PSI 244.183 Cadastro de veiculos : Carro Extra
          {call cts15m00_exibemsg(d_cts15m00.avialgmtv,
                                 l_aux_avialgmtv,
                                 d_cts15m00.avivclgrp,
                                 d_cts15m00.lcvsinavsflg,
                                 w_cts15m00.aviretdat,
                                 w_cts15m00.avirethor)
               returning l_exibe
           if l_exibe and
              d_cts15m00.corsus <> "P5005J"  then
                  call cts08g01("I","N", "",
                                         "O VEICULO SELECIONADO NECESSITA DA LIBE-",
                                         "RACAO DA COORDENACAO/APOIO DEVIDO AO ",
                                         "GRUPO E MOTIVO DA RESERVA"
                                         )
                  returning ws.confirma
                  call cts15m00b()
                       returning m_cts15m00b.erro,
                                 m_cts15m00b.mens,
                                 m_empcod,
                                 m_funmat
                  if m_cts15m00b.erro = 1 then
                     next field avivclcod
                  end if
           end if}
              ## PSI 244.183 Cadastro de veiculos : Carro Extra

          if d_cts15m00.lcvcod <> ws.lcvcod then
             error " Este veiculo nao esta' disponivel nesta locadora!"
             next field avivclcod
          end if

          if ws.avivclstt <> "A"  then
             error " Veiculo CANCELADO nao pode ser reservado!"
             next field avivclcod
          end if

          let d_cts15m00.avivclvlr = 0
          let d_cts15m00.locsegvlr = 0

          open ccts15m00039 using d_cts15m00.lcvcod, d_cts15m00.avivclcod,
                                  ws.lcvlojtip, ws.lcvregprccod,
                                  w_cts15m00.aviretdat
          fetch ccts15m00039 into d_cts15m00.avivclvlr, d_cts15m00.locsegvlr
          close ccts15m00039

          if d_cts15m00.avivclvlr is null   or
             d_cts15m00.avivclvlr  = 0      then
             error " Valor de diaria nao cadastrado! Selecione outro veiculo ou loja."
             next field lcvextcod
          end if

          let d_cts15m00.avivcldes = ws.avivclmdl clipped," (",
                                     ws.avivcldes clipped,")"
          let d_cts15m00.vcldiavlr = d_cts15m00.avivclvlr + d_cts15m00.locsegvlr

          ##psi 217956
          if (g_documento.ramcod =  31 or g_documento.ramcod = 531) and
             g_documento.succod    is not null   and
             g_documento.aplnumdig is not null   and
             g_documento.itmnumdig is not null   then
             call cts15m00_ver_claus(g_documento.succod,
                                     g_documento.aplnumdig,
                                     g_documento.itmnumdig)
                  returning w_cts15m00.clscod26,
                            w_cts15m00.clscod33,
                            w_cts15m00.clscod44,
                            w_cts15m00.clscod46,
                            w_cts15m00.clscod47,
                            w_cts15m00.clscod48,
                            w_cts15m00.clscod34,
                            w_cts15m00.clscod35
           end if

          call condicoes_cts15m00()

          if d_cts15m00.isnvlr is not null and
             d_cts15m00.isnvlr <> 0 then

              call cts08g01("I",
                            "N",
                            "LOCADORA OFERECE TAXA DIARIA DE ",
                            "ISENCAO NA PARTICIPACAO EM CASO ",
                            "DE SINISTRO. ",
                            d_cts15m00.isnvlr)

                   returning ws.confirma
          end if

          if d_cts15m00.rduvlr is not null and
             d_cts15m00.rduvlr <> 0 then


             call cts08g01("I",
                           "N",
                           "LOCADORA OFERECE TAXA DIARIA DE ",
                           "REDUCAO NA PARTICIPACAO EM CASO ",
                           "DE SINISTRO. ",
                           d_cts15m00.rduvlr)

                  returning ws.confirma
          end if

          display by name d_cts15m00.avivcldes
          display by name d_cts15m00.vcldiavlr
          display by name d_cts15m00.avivclgrp
          display by name d_cts15m00.frqvlr
          display by name d_cts15m00.isnvlr
          display by name d_cts15m00.rduvlr

          if cty31g00_nova_regra_clausula(g_documento.c24astcod) then
             if w_cts15m00.clscod26[1,2] = '26' and
             	d_cts15m00.avialgmtv     =  1   then
             	call ctx01g00_saldo_novo(g_documento.succod   ,
             	                         g_documento.aplnumdig,
                                         g_documento.itmnumdig,
                                         g_documento.atdsrvnum,
                                         g_documento.atdsrvano,
                                         w_cts15m00.datasaldo ,
                                         1                    ,
                                         true                 ,
                                         1                    ,
                                         w_cts15m00.avialgmtv ,
                                         g_documento.c24astcod)
                returning w_cts15m00.limite, w_cts15m00.sldqtd
             	let ws.msgtxt = "SALDO DE DIARIAS DISPONIVEIS: ", w_cts15m00.sldqtd using "<<&"
             	call cts08g01("I","N","CLAUSULA CARRO EXTRA CONTRATADA","", ws.msgtxt,"")
             	returning ws.confirma
             	if d_cts15m00.avialgmtv = 3  or
             	   d_cts15m00.avialgmtv = 6  or
             	   d_cts15m00.avialgmtv = 21 or
             	   d_cts15m00.avialgmtv = 24 then #osf32867 - Paula
             	   call cts08g01("I","N","CASO SEJA NECESSARIO UTILIZAR A",
             	                         "CLAUSULA CARRO EXTRA, ENTRE EM",
             	                         "CONTATO COM A CENTRAL 24 HORAS",
             	                         "PARA MARCACAO DE NOVA RESERVA.")
             	        returning ws.confirma
             	end if
             end if
          else
               ## colocar consistencia se tem claus 33 e 26
               if w_cts15m00.clsflg       =  TRUE   then
                  if w_cts15m00.sldqtd    = 0 and
                     d_cts15m00.avialgmtv = 9 then
                     if m_tem_33_26   = 2 then
                        let ws.msgtxt = "JA EXISTE RESERVA ANTERIOR P/CLAUS.", w_cts15m00.clscod33[1,3] using "<<&"
                     end if
                     if m_tem_33_26 = 3 then

                     end if
                  else
                     let ws.msgtxt = "SALDO DE DIARIAS DISPONIVEIS: ", w_cts15m00.sldqtd using "<<&"
                  end if
                  call cts08g01("I","N","CLAUSULA CARRO EXTRA CONTRATADA","", ws.msgtxt,"")
                      returning ws.confirma

                  if d_cts15m00.avialgmtv = 3  or
                     d_cts15m00.avialgmtv = 6  or
                     d_cts15m00.avialgmtv = 21 or
                     d_cts15m00.avialgmtv = 24 then #osf32867 - Paula
                     call cts08g01("I","N","CASO SEJA NECESSARIO UTILIZAR A",
                                           "CLAUSULA CARRO EXTRA, ENTRE EM",
                                           "CONTATO COM A CENTRAL 24 HORAS",
                                           "PARA MARCACAO DE NOVA RESERVA.")
                     returning ws.confirma
                  end if
               end if

          end if

          initialize ws.msgtxt to null

          if w_cts15m00.clsflg =  FALSE or
             w_cts15m00.clsflg is null  then
             # Retirado a pedido de Felix Bastiani em 10/08/2010 - Amilton Pinto
             #if d_cts15m00.locsegvlr is not null  and
             #   d_cts15m00.locsegvlr > 0          then
             #   let ws.msgtxt = "   VALOR SEGURO AO DIA: R$ ",d_cts15m00.locsegvlr using "<<<<&.&&"
             #
             #
             #   call cts08g01("I","N","TAXA DE PROTECAO NAO INCLUSO NO ",
             #                         "VALOR DA DIARIA. ", "", ws.msgtxt)
             #        returning ws.confirma
             #else
             call cts08g01("I","N","","AS TAXAS EXTRAS OFERECIDAS PELAS ",
                                      "LOCADORAS SAO OPCIONAIS. ","")
                  returning ws.confirma

             #end if
          end if

          if (d_cts15m00.avivclgrp <> "A"  and     #Veiculo nao basico
             (d_cts15m00.frqvlr = 0 or
              d_cts15m00.frqvlr is null)) then

              call cts08g01("I","N","","PARTICIPACAO OBRIGATORIA EM CASO DE ",
                                       "SINISTRO ATE O LIMITE DE 10% DO VALOR ",
                                       "DE MERCADO DO AUTOMOVEL LOCADO ")
              returning ws.confirma

          end if

          #FIM

          # ALTERACAO SOLICITADA POR ROSANA MINCON 09/05/05
          if d_cts15m00.cauchqflg = "S" then
             if d_cts15m00.avivclgrp = "A" or
                d_cts15m00.avivclgrp = "B" then
                # alterado a msg conforme Carla P.Socorro. 02/05/08
                call cts08g01("I","N", "",
                              "CHEQUE CAUCAO DE R$ 800,00","","")
                      returning ws.confirma
                #call cts08g01("I","N", "",
                #              "CHEQUE CAUCAO DE R$ 500.00","","")
                #      returning ws.confirma
             else  # demais grupos
                call cts08g01("I","N","",
                              "VERIFICAR VALORES PARA CHEQUE CAUCAO ",
                              "COM A LOCADORA","")
                      returning ws.confirma
             end if
          end if

          let d_cts15m00.frmflg = "N"
          let w_cts15m00.atdfnlflg = "N"
          display by name d_cts15m00.frmflg
          next field aviproflg

   before field frmflg
          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts15m00.frmflg = "N"
             display by name d_cts15m00.frmflg attribute (reverse)
             let m_cts15ant.frmflg = d_cts15m00.frmflg
          else
             if w_cts15m00.atdfnlflg = "S"  then
                call cts11g00(w_cts15m00.lignum)

                if m_pgtflg = true  then
                   let int_flag = true
                   exit input
                else
                   let m_cts15ant.frmflg = d_cts15m00.frmflg
                   next field aviproflg
                end if
             else
                exit input
             end if
          end if

   after  field frmflg
          display by name d_cts15m00.frmflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field avivclcod
          end if

          if d_cts15m00.frmflg is null  or
            (d_cts15m00.frmflg <> "S"   and
             d_cts15m00.frmflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field frmflg
          end if

          if d_cts15m00.frmflg = "S"  then
             call cts02m05(8) returning w_cts15m00.atddat,
                                        w_cts15m00.atdhor,
                                        w_cts15m00.funmat,
                                        w_cts15m00.cnldat,
                                        w_cts15m00.atdfnlhor,
                                        w_cts15m00.c24opemat,
                                        ws.pstcoddig

             if w_cts15m00.atddat    is null  or
                w_cts15m00.atdhor    is null  or
                w_cts15m00.funmat    is null  or
                w_cts15m00.cnldat    is null  or
                w_cts15m00.atdfnlhor is null  or
                w_cts15m00.c24opemat is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let w_cts15m00.atdfnlflg = "S"
             let w_cts15m00.atdetpcod =  4
          else
             let w_cts15m00.atdfnlflg = "N"
          end if

   before field aviproflg
          display by name d_cts15m00.aviproflg attribute (reverse)
          let m_cts15ant.aviproflg = d_cts15m00.aviproflg

          if m_reserva.loccntcod is null and
             d_cts15m00.acntip = 3  and
             g_documento.acao is not null then
             next field smsenvdddnum
          end if

   after  field aviproflg
          display by name d_cts15m00.aviproflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if g_documento.atdsrvnum is null  then
                next field frmflg
             else
                next field avivclcod
             end if
          end if
          ##PSI 244.183 Cadastro de veiculos : Carro Extra
          if d_cts15m00.aviproflg =  "S" then
             let l_aux_aviproflg = "S"
          end if
          ## PSI 244.183 Cadastro de veiculos : Carro Extra
          if d_cts15m00.aviproflg is null  or
            (d_cts15m00.aviproflg <> "S"   and
             d_cts15m00.aviproflg <> "N")  then
             error " Informe (S)im ou (N)ao!"
             next field aviproflg
          end if

          if d_cts15m00.aviproflg = "S"      and
            (g_documento.atdsrvnum is null   or
             g_documento.atdsrvano is null)  then
             error " Nao e' possivel prorrogar uma reserva nao realizada!"
             next field aviproflg
          end if

          if d_cts15m00.aviproflg = "S"  then
             let m_reenvio = true
             open c_cts15m00_014 using g_documento.atdsrvnum
                                    ,g_documento.atdsrvano
             whenever error continue
             fetch c_cts15m00_014 into l_aviprvent
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error "ERRO < 100 > NAO FOI POSSIVEL LOCALIZAR O SERVICO"
                else
                   let l_erro = "ERRO <",sqlca.sqlcode ,"> AO LOCALIZAR O SERVICO"
                   error l_erro
                end if
             end if
             if d_cts15m00.avialgmtv = 7 then
                 if l_aviprvent >= 7 then
                    let l_erro = "RESERVA TERC QUALQUER - MOTIVO 7 - SEM DIREITO A PRORROGACAO"
                    error l_erro
                    next field aviproflg
                 end if
             end if
             ## PSI 244.183 Cadastro de veiculos : Carro Extra
             ## passagem de parametros de grupo e aviso sinistro Amilton }
             call cts15m05(g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           d_cts15m00.lcvcod,
                           d_cts15m00.aviestcod ,
                           ws.endcep,
                           d_cts15m00.avialgmtv ,
                           d_cts15m00.dtentvcl,
                           d_cts15m00.avivclgrp,
                           d_cts15m00.lcvsinavsflg)
             returning w_cts15m00.procan,
                       w_cts15m00.aviprodiaqtd

             if w_cts15m00.procan = "P" then
                if w_cts15m00.aviprodiaqtd is null or
                   w_cts15m00.aviprodiaqtd =  0    then
                   select aviprodiaqtd
                       into w_cts15m00.aviprodiaqtd
                       from datmprorrog
                      where atdsrvnum = g_documento.atdsrvnum
                        and atdsrvano = g_documento.atdsrvano
                        and aviproseq = ( select max(aviproseq)
                                          from datmprorrog
                                          where atdsrvnum = g_documento.atdsrvnum  and
                                                atdsrvano = g_documento.atdsrvano    )
                end if
             end if
          else
             if d_cts15m00.frmflg = "S"  then
                call cts15m04("F"                 , d_cts15m00.avialgmtv,
                              d_cts15m00.aviestcod, w_cts15m00.aviretdat,
                              w_cts15m00.avirethor, w_cts15m00.aviprvent,
                              d_cts15m00.lcvcod   ,
                              ws.endcep           , d_cts15m00.dtentvcl  )
                    returning w_cts15m00.aviretdat, w_cts15m00.avirethor,
                              w_cts15m00.aviprvent, ws.cct, ws.cct, ws.cct

             end if
          end if

          if w_cts15m00.aviretdat   is null    or
             w_cts15m00.avirethor   is null    or
             w_cts15m00.aviprvent   is null    then
             error " Data/hora da retirada e dias de utilizacao devem ser informados!"
             next field aviproflg
          end if

   before field smsenvdddnum
          display by name d_cts15m00.smsenvdddnum  attribute (reverse)
          let m_cts15ant.smsenvdddnum = d_cts15m00.smsenvdddnum

   after field smsenvdddnum
          display by name d_cts15m00.smsenvdddnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if m_reserva.loccntcod is null and
                d_cts15m00.acntip = 3  and
                g_documento.acao is not null then
                next field frmflg
             else
                next field aviproflg
             end if
          end if

   before field smsenvcelnum
          display by name d_cts15m00.smsenvcelnum  attribute (reverse)
          let m_cts15ant.smsenvcelnum = d_cts15m00.smsenvcelnum

   after field smsenvcelnum
          display by name d_cts15m00.smsenvcelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field smsenvdddnum
          end if

          if (d_cts15m00.smsenvcelnum  is null      or
             d_cts15m00.smsenvcelnum  = "   "    ) and
             d_cts15m00.smsenvcelnum is not null   then
             error " Informe o celular para confirmacao da reserva"
             next field smsenvcelnum
          end if

   before field cttdddcod
          display by name d_cts15m00.cttdddcod  attribute (reverse)
          let m_cts15ant.cttdddcod = d_cts15m00.cttdddcod

   after  field cttdddcod
          display by name d_cts15m00.cttdddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field smsenvcelnum
          end if

          if d_cts15m00.cttdddcod  is null    or
             d_cts15m00.cttdddcod  = "   "    then
             error " Informe o DDD do telefone para confirmacao da reserva"
             next field cttdddcod
          end if

   before field ctttelnum
          display by name d_cts15m00.ctttelnum  attribute (reverse)
          let m_cts15ant.ctttelnum = d_cts15m00.ctttelnum

   after  field ctttelnum
          display by name d_cts15m00.ctttelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left") then
             next field cttdddcod
          end if

          if d_cts15m00.ctttelnum  is null    or
             d_cts15m00.ctttelnum  = "   "    then
             error " Informe o telefone de contato para confirmacao da reserva"
             next field ctttelnum
          end if

   before field atdlibflg
          display by name d_cts15m00.atdlibflg  attribute (reverse)
          let m_cts15ant.atdlibflg = d_cts15m00.atdlibflg

   after  field atdlibflg
          display by name d_cts15m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field ctttelnum
          end if

          if ((d_cts15m00.atdlibflg  is null)  or
              (d_cts15m00.atdlibflg <> "S"     and
               d_cts15m00.atdlibflg <> "N"))   then
             error " Informacao sobre liberacao deve ser (S)im ou (N)ao!"
             next field atdlibflg
          else
             if d_cts15m00.atdlibflg = "N"  then
                error " Nao ha' possibilidade de programacao. Solicite novo contato!"
                next field atdlibflg
             end if
          end if


   on key (interrupt)
      if g_documento.atdsrvnum  is null   then

         call cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
              returning ws.confirma

         if ws.confirma  =  "S"   then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.acao <> 'SIN' or g_documento.acao is null then
         if d_cts15m00.c24astcod is not null then
            call ctc58m00_vis(d_cts15m00.c24astcod)
         end if
      end if

   on key (F3)
      if g_documento.acao <> 'SIN' or g_documento.acao is null then
         if d_cts15m00.vclloctip  =  3  or
            d_cts15m00.vclloctip  =  4  then
            if g_documento.atdsrvnum is not null  and
               g_documento.atdsrvano is not null  then
               call cts15m08(d_cts15m00.vclloctip,
                             w_cts15m00.slcemp,
                             w_cts15m00.slcsuccod,
                             w_cts15m00.slcmat,
                             w_cts15m00.slccctcod,
                             "C" )               #--> (A)tualiza/(C)onsulta
                   returning w_cts15m00.slcemp,
                             w_cts15m00.slcsuccod,
                             w_cts15m00.slcmat,
                             w_cts15m00.slccctcod,
                             ws.nomeusu    #-> neste caso nome funcionari
            end if
         end if
      end if

   on key (F4)


      call cts15m00_opcoes()

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
      if g_documento.atdsrvnum is null then
         error " Acesso ao historico somente com cadastramento do servico!"
      else
         call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, l_data, l_hora2)
      end if

   on key (F7)

      let m_reenvio = true
      if g_documento.acao <> 'SIN' or g_documento.acao is null then
         if g_documento.atdsrvnum is null then
            error " Impressao somente com cadastramento do servico!"
         else
            let m_f7 = true
            call cts15m00_acionamento(g_documento.atdsrvnum,
                                      g_documento.atdsrvano,
                                      d_cts15m00.lcvcod,
                                      d_cts15m00.aviestcod,0,'',
                                      w_cts15m00.procan)

         end if
      end if

   on key (F8)
      if g_documento.acao <> 'SIN' or g_documento.acao is null then
         if g_documento.atdsrvnum is null then
            error " Consulta as informacoes de retirada somente apos digitacao do servico!"
         else
            let l_acao = "C"
            if g_documento.acao ="ALT" then
               let l_acao = "A"
            end if

            call cts15m04(l_acao, d_cts15m00.avialgmtv,
                          d_cts15m00.aviestcod, w_cts15m00.aviretdat,
                          w_cts15m00.avirethor, w_cts15m00.aviprvent,
                          d_cts15m00.lcvcod   , ws.endcep
                        , d_cts15m00.dtentvcl)
                returning w_cts15m00.aviretdat, w_cts15m00.avirethor,
                          w_cts15m00.aviprvent, ws.cct, ws.cct, ws.cct
         end if
      end if

   on key (F9)
      if g_documento.acao <> 'SIN' or g_documento.acao is null then
         if g_documento.atdsrvnum is null then
            error " Servico nao cadastrado!"
         else
           if d_cts15m00.atdlibflg = "N"   then
              error " Servico nao liberado!"
            else
              if d_cts15m00.lcvcod     is null   or
                 d_cts15m00.aviestcod  is null   then
                 error " Locadora/loja para retirada de veiculo nao informada!"
              else
                 call cts15m01(g_documento.atdsrvnum, g_documento.atdsrvano,
                               d_cts15m00.lcvcod    , d_cts15m00.aviestcod ,
                               d_cts15m00.avialgmtv )
              end if
            end if
         end if
      end if
      
      on key (F10)
      	 if g_documento.atdsrvnum is null  or        
      	    g_documento.atdsrvano is null  then      
      	    error " Servico nao cadastrado!"         
      	 else    
      	 	
      	 	  if cty31g00_valida_atd_premium()   and  
      	 	     g_documento.c24astcod = "H10"   then 
      	 	
      	 	     call cts06g03(2
                            ,g_documento.atdsrvorg
                            ,g_documento.ligcvntip
                            ,l_data
                            ,l_hora2
                            ,a_cts15m00[2].lclidttxt
                            ,a_cts15m00[2].cidnom
                            ,a_cts15m00[2].ufdcod
                            ,a_cts15m00[2].brrnom
                            ,a_cts15m00[2].lclbrrnom
                            ,a_cts15m00[2].endzon
                            ,a_cts15m00[2].lgdtip
                            ,a_cts15m00[2].lgdnom
                            ,a_cts15m00[2].lgdnum
                            ,a_cts15m00[2].lgdcep
                            ,a_cts15m00[2].lgdcepcmp
                            ,a_cts15m00[2].lclltt
                            ,a_cts15m00[2].lcllgt
                            ,a_cts15m00[2].lclrefptotxt
                            ,a_cts15m00[2].lclcttnom
                            ,a_cts15m00[2].dddcod
                            ,a_cts15m00[2].lcltelnum
                            ,a_cts15m00[2].c24lclpdrcod
                            ,a_cts15m00[2].ofnnumdig
                            ,a_cts15m00[2].celteldddcod
                            ,a_cts15m00[2].celtelnum
                            ,a_cts15m00[2].endcmp
                            ,hist_cts15m00.*
                            ,a_cts15m00[2].emeviacod )
                   returning a_cts15m00[2].lclidttxt
                            ,a_cts15m00[2].cidnom
                            ,a_cts15m00[2].ufdcod
                            ,a_cts15m00[2].brrnom
                            ,a_cts15m00[2].lclbrrnom
                            ,a_cts15m00[2].endzon
                            ,a_cts15m00[2].lgdtip
                            ,a_cts15m00[2].lgdnom
                            ,a_cts15m00[2].lgdnum
                            ,a_cts15m00[2].lgdcep
                            ,a_cts15m00[2].lgdcepcmp
                            ,a_cts15m00[2].lclltt
                            ,a_cts15m00[2].lcllgt
                            ,a_cts15m00[2].lclrefptotxt
                            ,a_cts15m00[2].lclcttnom
                            ,a_cts15m00[2].dddcod
                            ,a_cts15m00[2].lcltelnum
                            ,a_cts15m00[2].c24lclpdrcod
                            ,a_cts15m00[2].ofnnumdig
                            ,a_cts15m00[2].celteldddcod
                            ,a_cts15m00[2].celtelnum
                            ,a_cts15m00[2].endcmp
                            ,ws.retflg
                           ,hist_cts15m00.*
                           ,a_cts15m00[2].emeviacod
      	 	  
      	 	  else
      	 	     error " Destino somente para o Atendimento Premium"     
      	 	  end if
      	 	     	 
         end if
      	  
 end input

 if int_flag  then
    error " Operacao cancelada!"
 end if

 #ligia - fornax - 01/06/2011
 if g_documento.acao = "ALT" or
    g_documento.acao is null then
    call cts15m00_ver_alt_laudo()
 end if

end function  ###  input_cts15m00

#--------------------------------------------------------------------
 function condicoes_cts15m00()
#--------------------------------------------------------------------

 initialize d_cts15m00.cndtxt  to null
 initialize w_cts15m00.sldqtd  to null

 let w_cts15m00.clsflg    = FALSE
 let w_cts15m00.avidiaqtd = 0

 if ((d_cts15m00.avialgmtv = 1    or
     d_cts15m00.avialgmtv = 9 ))  and
     w_cts15m00.clscod[1,2] = "26"  then
    if w_cts15m00.clscod26[1,2] = "26"  or
       w_cts15m00.clscod26[1,2] = "80"  then
       let d_cts15m00.cndtxt = "CLAUSULA ", w_cts15m00.clscod26
       let w_cts15m00.clsflg = true
    else
       if d_cts15m00.avialgmtv = 9     and
          ( m_tem_33_26          = 2   or
            m_tem_33_26          = 3)  then
          let w_cts15m00.avidiaqtd = 7
          let w_cts15m00.clsflg    = true

       # Roberto - CT  8033699 - Diaria gratuita nao existe mais
       #else
       #   let d_cts15m00.cndtxt = "1 DIARIA GRATUITA"
       #   let w_cts15m00.avidiaqtd = 1
       end if
    end if
    if w_cts15m00.clscod26[1,2] = "26"   or
       w_cts15m00.clscod33[1,3] = "033"  or
       w_cts15m00.clscod33[1,3] = "33R"  or
       w_cts15m00.clscod34[1,3] = "034"  or
       w_cts15m00.clscod35[1,3] = "035"  or
       w_cts15m00.clscod46[1,3] = "046"  or
       w_cts15m00.clscod46[1,3] = "46R"  or
       w_cts15m00.clscod44[1,3] = "044"  or
       w_cts15m00.clscod44[1,3] = "44R"  or
       w_cts15m00.clscod47[1,3] = "047"  or
       w_cts15m00.clscod47[1,3] = "47R"  or
       w_cts15m00.clscod48[1,3] = "048"  or
       w_cts15m00.clscod48[1,3] = "48R"  or
       w_cts15m00.clscod26[1,2] = "80"   then
       call ctx01g00_saldo_novo(g_documento.succod   , g_documento.aplnumdig,
                           g_documento.itmnumdig, g_documento.atdsrvnum,
                           g_documento.atdsrvano, w_cts15m00.datasaldo ,
                           1, true, 1, w_cts15m00.avialgmtv,
                           g_documento.c24astcod) #PSI 205206
                 returning w_cts15m00.limite, w_cts15m00.sldqtd

       if w_cts15m00.sldqtd is null  then
          let w_cts15m00.sldqtd = 0
       end if

    end if
 else
    if d_cts15m00.avialgmtv = 2    and
       d_cts15m00.avivclgrp = "A"  then
       let w_cts15m00.avidiaqtd = 1
       ###let d_cts15m00.cndtxt  = "1 DIARIA GRATUITA"
       let d_cts15m00.cndtxt = "CLAUSULA ", w_cts15m00.clscod33
       let w_cts15m00.clsflg = false
    else
       if (d_cts15m00.avialgmtv = 3    or
           d_cts15m00.avialgmtv = 6    or
           d_cts15m00.avialgmtv = 21   or
           d_cts15m00.avialgmtv = 24)  and  #osf32867 - Paula
           d_cts15m00.avivclgrp = "A"  then
           let w_cts15m00.avidiaqtd = 7
          # let d_cts15m00.cndtxt  = "7 DIARIAS GRATUITAS"
          # inibir conforme Sofia PSI 168785 - Ruiz 21/01/03
       end if
    end if
 end if

 display by name d_cts15m00.cndtxt

end function  ###  condicoes_cts15m00

#--------------------------------------------------------------------
 function historico_cts15m00(param)
#--------------------------------------------------------------------

 define param  record
    atdsrvnum  like datmservico.atdsrvnum ,
    atdsrvano  like datmservico.atdsrvano ,
    c24srvdsc  like datmservhist.c24srvdsc
 end    record

 define ws     record
    c24txtseq  like datmservhist.c24txtseq
 end record

 define l_data       date,
        l_hora2      datetime hour to minute

 define l_ret       smallint,
        l_mensagem  char(60)

        initialize  ws.*  to  null

 initialize ws.c24txtseq to null


 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2


  call ctd07g01_ins_datmservhist(param.atdsrvnum,
                                 param.atdsrvano,
                                 g_issk.funmat,
                                 param.c24srvdsc,
                                 l_data,
                                 l_hora2,
                                 g_issk.empcod,
                                 g_issk.usrtip)

       returning l_ret,
                 l_mensagem

  if l_ret <> 1 then
     error " Erro (", sqlca.sqlcode, ") na inclusao do historico do servico. AVISE A INFORMATICA! "
     return
  end if

end function  ###  historico_cts15m00

#-----------------------------------------------------------------------------
 function salvaglobal_cts15m00(param)
#-----------------------------------------------------------------------------
    define param   record
        segflg     char(01)
    end record


    if param.segflg   =  "S"  then
       let slv_segurado.succod        = g_documento.succod
       let slv_segurado.ramcod        = g_documento.ramcod
       let slv_segurado.aplnumdig     = g_documento.aplnumdig
       let slv_segurado.itmnumdig     = g_documento.itmnumdig
       let slv_segurado.edsnumref     = g_documento.edsnumref
       let slv_segurado.lignum        = g_documento.lignum
       let slv_segurado.c24soltipcod  = g_documento.c24soltipcod
       let slv_segurado.solnom        = g_documento.solnom
       let slv_segurado.c24astcod     = g_documento.c24astcod
       let slv_segurado.ligcvntip     = g_documento.ligcvntip
       let slv_segurado.prporg        = g_documento.prporg
       let slv_segurado.prpnumdig     = g_documento.prpnumdig
       let slv_segurado.fcapacorg     = g_documento.fcapacorg
       let slv_segurado.fcapacnum     = g_documento.fcapacnum
       let slv_segurado.dctnumseq     = g_funapol.dctnumseq
       let slv_segurado.vclsitatu     = g_funapol.vclsitatu
       let slv_segurado.autsitatu     = g_funapol.autsitatu
       let slv_segurado.dmtsitatu     = g_funapol.dmtsitatu
       let slv_segurado.dpssitatu     = g_funapol.dpssitatu
       -------------[ mesma rotina de inicializacao do cta00m01 ]-------------
       initialize g_dctoarray            to null
       initialize g_funapol.*            to null
       initialize g_documento.succod     to null
       initialize g_documento.ramcod     to null
       initialize g_documento.aplnumdig  to null
       initialize g_documento.itmnumdig  to null
       initialize g_documento.edsnumref  to null
       initialize g_documento.fcapacorg  to null
       initialize g_documento.fcapacnum  to null
       initialize g_documento.sinramcod  to null
       initialize g_documento.sinano     to null
       initialize g_documento.sinnum     to null
       initialize g_documento.vstnumdig  to null
    else
       let g_documento.succod         = slv_segurado.succod
       let g_documento.ramcod         = slv_segurado.ramcod
       let g_documento.aplnumdig      = slv_segurado.aplnumdig
       let g_documento.itmnumdig      = slv_segurado.itmnumdig
       let g_documento.edsnumref      = slv_segurado.edsnumref
       let g_documento.lignum         = slv_segurado.lignum
       let g_documento.c24soltipcod   = slv_segurado.c24soltipcod
       let g_documento.solnom         = slv_segurado.solnom
       let g_documento.c24astcod      = slv_segurado.c24astcod
       let g_documento.ligcvntip      = slv_segurado.ligcvntip
       let g_documento.prporg         = slv_segurado.prporg
       let g_documento.prpnumdig      = slv_segurado.prpnumdig
       let g_documento.fcapacorg      = slv_segurado.fcapacorg
       let g_documento.fcapacnum      = slv_segurado.fcapacnum
       let g_funapol.dctnumseq        = slv_segurado.dctnumseq
       let g_funapol.vclsitatu        = slv_segurado.vclsitatu
       let g_funapol.autsitatu        = slv_segurado.autsitatu
       let g_funapol.dmtsitatu        = slv_segurado.dmtsitatu
       let g_funapol.dpssitatu        = slv_segurado.dpssitatu
    end if
 end function

#------------------------------------------------------------------
 function cts15m00_ver_claus(param)
 #------------------------------------------------------------------

  define param record
         succod like abbmitem.succod ,
         aplnumdig like abbmitem.aplnumdig ,
         itmnumdig like abbmitem.itmnumdig
  end record

  define l_ver_claus like abbmclaus.clscod
  define l_clscod26 like abbmclaus.clscod
  define l_clscod33 like abbmclaus.clscod
  define l_clscod34 like abbmclaus.clscod
  define l_clscod35 like abbmclaus.clscod
  define l_clscod44 like abbmclaus.clscod
  define l_clscod46 like abbmclaus.clscod
  define l_clscod47 like abbmclaus.clscod
  define l_clscod48 like abbmclaus.clscod
  define l_ver_dctnumseq like abbmclaus.dctnumseq

  let l_clscod26 = null
  let l_clscod33 = null
  let l_clscod34 = null
  let l_clscod35 = null
  let l_clscod44 = null
  let l_clscod46 = null
  let l_clscod47 = null
  let l_clscod48 = null
  let l_ver_claus = null
  let l_ver_dctnumseq = null

  if param.succod is null or
     param.aplnumdig is null or
     param.itmnumdig is null then
     return l_clscod26, l_clscod33, l_clscod46, l_clscod47, l_clscod44,
            l_clscod48, l_clscod34, l_clscod35
  end if

  open c_cts15m00_010 using g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig
  fetch c_cts15m00_010 into l_ver_dctnumseq
  close c_cts15m00_010

  open c_cts15m00_011 using g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            l_ver_dctnumseq

  foreach c_cts15m00_011 into l_ver_claus

          if l_ver_claus[1,2] = '26' or
             l_ver_claus[1,2] = '80' then
             let l_clscod26 = l_ver_claus
          end if

          if l_ver_claus = '033' or
             l_ver_claus = '33R' then
             let l_clscod33 = l_ver_claus
          end if
          if l_ver_claus = '044' or
             l_ver_claus = '44R' then
             let l_clscod44 = l_ver_claus
          end if
          if l_ver_claus = '046' or
             l_ver_claus = '46R' then
             let l_clscod46 = l_ver_claus
	        end if

          if l_ver_claus = '047' or
	           l_ver_claus = '47R' then
	           let l_clscod47 = l_ver_claus
          end if
          if l_ver_claus = '048' or
             l_ver_claus = '48R' then
             let l_clscod48 = l_ver_claus
          end if
          if l_ver_claus = '034' then
             let l_clscod34 = l_ver_claus
          end if
          if l_ver_claus = '035' then
             let l_clscod35 = l_ver_claus
          end if
  end foreach

  return l_clscod26,
         l_clscod33,
         l_clscod44,
         l_clscod46,
         l_clscod47,
         l_clscod48,
         l_clscod34,
         l_clscod35

end function ### ver_claus26

#-----------------------------------------#
 function cts15m00_acionamento(lr_param)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum  like datmservico.atdsrvnum
                  ,atdsrvano  like datmservico.atdsrvano
                  ,lcvcod     like datklocadora.lcvcod
                  ,aviestcod  like datmavisrent.aviestcod
                  ,atdetpcod  like datmsrvint.atdetpcod
                  ,etpmtvcod  like datksrvintmtv.etpmtvcod
                  ,procan     char(1)
                  end record

   define lr_ctc30g00 record
                      resultado    smallint
                     ,mensagem     char(100)
                     ,acntip       like datklocadora.acntip
                     ,lcvresenvcod like datklocadora.lcvresenvcod
                      end record

   define lr_ctc18g00 record
                      resultado smallint
                     ,mensagem  char(100)
                      end record

   define lr_cts33g00 record
                      resultado smallint
                     ,mensagem  char(100)
                     ,atdetpseq like datmsrvint.atdetpseq
                     ,atdetpcod like datmsrvint.atdetpcod
                      end record

   define lr_retorno record
          resultado      smallint
         ,mensagem       char(60)
         ,atdsrvseq      like datmsrvacp.atdsrvseq
   end record

   define lr_etapa record
          resultado smallint
         ,mensagem  char(60)
         ,atdetpcod like datmsrvacp.atdetpcod
         ,pstcoddig like datmsrvacp.pstcoddig
         ,srrcoddig like datmsrvacp.srrcoddig
         ,socvclcod like datmsrvacp.socvclcod
   end record

   define lr_erro record
          sqlcode smallint,
          mens    char(80)
   end record

   define l_maides like datkavislocal.maides
         ,l_prestador decimal(10,0)
         ,l_retorno   smallint
         ,l_flag      smallint
         ,l_sissgl    char(10)
         ,l_etapa     like datmsrvacp.atdetpcod

   initialize
        lr_ctc30g00
       ,lr_ctc18g00
       ,lr_cts33g00
       ,lr_retorno
       ,lr_etapa
   to null

   let l_maides    = null
   let l_prestador = null
   let l_retorno   = null
   let l_flag      = false
   let l_etapa     = null
   let l_sissgl    = null

   #Obter o tipo de acionamento de acordo com a locadora
   call ctc30g00_dados_loca(1, lr_param.lcvcod)
      returning lr_ctc30g00.resultado
               ,lr_ctc30g00.mensagem
               ,lr_ctc30g00.acntip
               ,lr_ctc30g00.lcvresenvcod
               ,l_maides

   #Verificar se a loja/locadora esta conectada na Internet
   if lr_ctc30g00.lcvresenvcod = 1 then #Enviar para Locadora
      let l_prestador = lr_param.lcvcod
      let l_sissgl = 'LCVONLINE'
   else #enviar para loja
      #Obter o email da loja
      call ctc18g00_dados_loja(2, lr_param.lcvcod, lr_param.aviestcod)
         returning lr_ctc18g00.resultado
                  ,lr_ctc18g00.mensagem
                  ,l_maides
      let l_prestador = lr_param.aviestcod
      let l_sissgl = 'RLCONLINE'
   end if

   if lr_ctc30g00.acntip = 1 then #Internet
      call fissc101_prestador_sessao_ativa(l_prestador, l_sissgl)
           returning l_flag

      if l_flag = true then #Prestador esta conectado na internet
         #Obter sequencia/etapa do servico para internet
         call cts33g00_inf_internet(lr_param.atdsrvnum, lr_param.atdsrvano)
            returning lr_cts33g00.resultado
                     ,lr_cts33g00.mensagem
                     ,lr_cts33g00.atdetpseq
                     ,lr_cts33g00.atdetpcod

         if lr_cts33g00.resultado = 3 then
            error lr_cts33g00.mensagem
            return
         end if

         #Gravar o servico nas tabelas da Internet
         call cts33g00_registrar_para_internet(lr_param.atdsrvano
                                              ,lr_param.atdsrvnum
                                              ,lr_cts33g00.atdetpseq
                                              ,lr_param.atdetpcod
                                              ,l_prestador
                                              ,g_issk.usrtip
                                              ,g_issk.empcod
                                              ,g_issk.funmat
                                              ,lr_param.etpmtvcod)
            returning lr_cts33g00.resultado
                     ,lr_cts33g00.mensagem

         if lr_cts33g00.resultado = 2 then
            error lr_cts33g00.mensagem
            return
         end if

         #Inserir Etapa de Enviado
         if lr_param.atdetpcod = 0 then ##Aguardando
            let l_etapa = 43  #Enviado
            error "Servico enviado ao Portal de Negocios"
         else
            let l_etapa = 5   #Cancelado
            ##Obter a sequencia da etapa anterior
            call cts10g04_max_seq (lr_param.atdsrvnum , lr_param.atdsrvano ,'')
                 returning lr_retorno.*

            ##Obter a etapa anterior
            call cts10g04_ultimo_pst (lr_param.atdsrvnum ,
                                      lr_param.atdsrvano ,lr_retorno.atdsrvseq)
                 returning lr_etapa.*
         end if

         let l_retorno = cts10g04_insere_etapa(lr_param.atdsrvnum
                                              ,lr_param.atdsrvano
                                              ,l_etapa
                                              ,lr_param.lcvcod
                                              ,''
                                              ,''
                                              ,lr_param.aviestcod)

      end if
   end if

   #Se prestador nao esta conectado na Internet ou ele recebe por fax, enviar laudo por fax
   if l_flag = false or lr_ctc30g00.acntip = 2 then #Fax
      if lr_ctc30g00.acntip = 3 and
         m_prorrog = false      then

          call ctx28g00_stt_listener_locadora(lr_param.lcvcod)
               returning lr_erro.sqlcode,lr_erro.mens

          if lr_erro.sqlcode = 1 then
             # Chama webservice Localiza
             call cts15m00_webservice(lr_param.atdsrvnum, lr_param.atdsrvano,
                                      g_documento.acao, lr_param.procan)
                  returning lr_erro.sqlcode,lr_erro.mens

             if lr_erro.sqlcode <> 0 then
                error lr_erro.mens
                call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
             else
               error "Solicitacao enviada com sucesso !" sleep 1
             end if
          else
            call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
          end if
      else
         if lr_ctc30g00.acntip <> 3 or
            m_prorrog = true then

            call cts15m03(lr_param.atdsrvnum, lr_param.atdsrvano, l_maides, 'F')
         end if
      end if
   else

      if (l_etapa = 5 and lr_etapa.atdetpcod > 1) or
          l_etapa = 43 or lr_ctc30g00.acntip is null then
          #Enviar o laudo da reserva para o email da loja/locadora
          call cts15m14_email(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,l_maides ,'T','','') #Para identificar Internet
      end if
   end if

 end function

#------------------------------------#
function cts15m00_rec_email()
#------------------------------------#

#--------------------------------------------------------------#
#-Roberto- Funcao para buscar os remetentes que recebem o e-mail
#          do carro extra
#--------------------------------------------------------------#


  define l_cpodes      like iddkdominio.cpodes

  define email record
         para     char(1000) ,
         de       char(100)  ,
         cc       char(1000) ,
         assunto  char(100)

  end record


  call cts15m00_prepara()


  let l_cpodes     = null

  initialize email.* to null

  let email.assunto = "Carro Extra Particular"
  let email.de = "EmailCorr.ct24hs@correioporto"
  let email.cc = ""


  open c_cts15m00_005
  foreach c_cts15m00_005 into l_cpodes

     if email.para is null then
        let email.para = l_cpodes
     else
        let email.para = email.para clipped, ",", l_cpodes
     end if

  end foreach
  close c_cts15m00_005

  return email.*

end function

#------------------------------------#
function cts15m00_monta_mens(l_monta)
#------------------------------------#

#--------------------------------------------------------------#
#-Roberto- Funcao que monta a mensagem para o envio do e-mail
#--------------------------------------------------------------#

  define l_monta record
         atdsrvnum  like datmservico.atdsrvnum   ,
         atdsrvano  like datmservico.atdsrvano
  end record


  define l_bloco record
         mens1 char(1000) ,
         mens2 char(1000) ,
         mens3 char(1000) ,
         mens4 char(1000)
  end record

  define l_var record
         atdsrvorg  like datmservico.atdsrvorg,
         c24txtseq  like datmservhist.c24txtseq,
         funnom     like isskfunc.funnom      ,
         hist       char(1000)
  end record



  initialize l_bloco.* to null
  initialize l_var.* to null


  open c_cts15m00_009 using l_monta.atdsrvnum, l_monta.atdsrvano

  whenever error continue
  fetch c_cts15m00_009 into l_var.atdsrvorg
  whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," Origem do Servico nao encontrado "
            else
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," no acesso a tabela datmservico ."
            end if
         else

            let l_bloco.mens1 = "Numero do Servi�o : ", l_var.atdsrvorg using '&&', "/",
                                                        l_monta.atdsrvnum using '<<<<&&&&&&',"-",
                                                        l_monta.atdsrvano using '&&'
         end if

  if g_documento.funmat is not null then

         open c_cts15m00_007 using g_documento.funmat

         whenever error continue
         fetch c_cts15m00_007 into l_var.funnom
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," Nome do Funcionario nao encontrado "
            else
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," no acesso a tabela isskfunc ."
            end if
         else
              let l_bloco.mens2 = "Matricula Solicitante : " , g_documento.funmat using '&&&&&&', " - ",
                                                               l_var.funnom
         end if
  end if

  open c_cts15m00_008 using l_monta.atdsrvnum,l_monta.atdsrvano
  foreach c_cts15m00_008 into l_var.hist,
                            l_var.c24txtseq

     if l_bloco.mens3 is null then
        let l_bloco.mens3 = "Historico : <br><br>", l_var.hist
     else
        let l_bloco.mens3 = l_bloco.mens3 clipped, "<br>", l_var.hist
     end if


  end foreach
  close c_cts15m00_008


  let l_bloco.mens4 = l_bloco.mens1 clipped, "<br>", l_bloco.mens2 clipped, "<br>",
                      l_bloco.mens3


  return l_bloco.mens4

end function

#------------------------------------#
function cts15m00_env_email(l_param)
#------------------------------------#

#--------------------------------------------------------------#
#-Roberto- Funcao que envia o e-mail
#--------------------------------------------------------------#

  define l_param record
         atdsrvnum  like datmservico.atdsrvnum   ,
         atdsrvano  like datmservico.atdsrvano
  end record

  define l_param2 record
         data  date                    ,
         hora  datetime hour to minute ,
         cmd   char(1000)              ,
         ret   smallint
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
   define l_coderro  smallint
   define msg_erro char(500)

  initialize l_param2.* to null

   call cts40g03_data_hora_banco(2)
        returning l_param2.data, l_param2.hora

   call cts10g02_historico(l_param.atdsrvnum
                          ,l_param.atdsrvano
                          ,l_param2.data
                          ,l_param2.hora
                          ,g_issk.funmat
                          ,m_cts15m00b.mens
                          ,""
                          ,""
                          ,""
                          ,"")
   returning l_param2.ret

   call cts15m00_rec_email()
        returning m_cts15m00b.para,
                  m_cts15m00b.de  ,
                  m_cts15m00b.cc  ,
                  m_cts15m00b.assunto


   call cts15m00_monta_mens(l_param.atdsrvnum ,
                            l_param.atdsrvano  )
       returning m_cts15m00b.mens2

  #PSI-2013-23297 - Inicio
   let l_mail.de = m_cts15m00b.de
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = m_cts15m00b.para
   let l_mail.cc = ""
   let l_mail.cco = ""
   let l_mail.assunto = m_cts15m00b.assunto
   let l_mail.mensagem = m_cts15m00b.mens2
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "html"
   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro

   #PSI-2013-23297 - Fim

   return

end function

#---------------------------------------------------------
function cts15m00_ver_mtv9(l_param)
#---------------------------------------------------------

 define  l_param record
         succod       like datrligapol.succod    ,
         aplnumdig    like datrligapol.aplnumdig ,
         itmnumdig    like datrligapol.itmnumdig
 end record

 define l_ret_motivo    smallint

 define l_srv record
        atdsrvnum    like datmservico.atdsrvnum ,
        atdsrvano    like datmservico.atdsrvano ,
        atdetpcod    like datmsrvacp.atdetpcod
 end record

 define l_avialgmtv  like datmavisrent.avialgmtv

 initialize l_ret_motivo, l_avialgmtv, l_srv.* to null

 let l_ret_motivo = 0

 open c_cts15m00_013 using l_param.succod
                        ,l_param.aplnumdig
                        ,l_param.itmnumdig
 whenever error continue
 foreach c_cts15m00_013 into l_srv.atdsrvnum, l_srv.atdsrvano

 whenever error stop
 if sqlca.sqlcode <> 0 then
    return l_ret_motivo
 end if
    open c_cts15m00_012 using l_srv.atdsrvnum
                           ,l_srv.atdsrvano
    fetch c_cts15m00_012 into l_avialgmtv

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound  then
          error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
       else
          error 'Erro SELECT c_cts15m00_012 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
          error 'CTS15M00 / consulta_cts15m00() / ',l_srv.atdsrvnum,' / '
                                                   ,l_srv.atdsrvano   sleep 1
       end if
    end if
    close c_cts15m00_012
    if l_avialgmtv <> 9 then
       continue foreach
    else
       select atdetpcod
         into l_srv.atdetpcod
         from datmsrvacp
        where atdsrvnum = l_srv.atdsrvnum
          and atdsrvano = l_srv.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = l_srv.atdsrvnum
                              and atdsrvano = l_srv.atdsrvano)

       if l_srv.atdetpcod <> 1 or
          l_srv.atdetpcod <> 4 then
          let l_ret_motivo = 0
          continue foreach
       else
          if l_srv.atdetpcod  = 1 or
             l_srv.atdetpcod  = 4 then
             let l_ret_motivo = 1
             exit foreach
          end if
       end if
    end if
 end foreach
 close c_cts15m00_013

 return l_ret_motivo

end function



############################ Copia #############################################

#---------------------------------------#
function cts15m00_env_email_tmp(l_param)
#---------------------------------------#

#--------------------------------------------------------------#
#-Alberto - Funcao que envia o e-mail
#--------------------------------------------------------------#

  define l_param record
         atdsrvnum  like datmservico.atdsrvnum   ,
         atdsrvano  like datmservico.atdsrvano
  end record

  define l_param2 record
         data  date                    ,
         hora  datetime hour to minute ,
         cmd   char(1000)              ,
         ret   smallint
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
  define l_coderro  smallint
  define msg_erro char(500)
  initialize l_param2.* to null

  call cts15m00_rec_email_tmp()
       returning m_cts15m00b.para,
                 m_cts15m00b.de  ,
                 m_cts15m00b.cc  ,
                 m_cts15m00b.assunto

  call cts15m00_monta_mens_tmp(l_param.atdsrvnum ,
                           l_param.atdsrvano  )
       returning m_cts15m00b.mens2

 { let l_param2.cmd = ' echo "', m_cts15m00b.mens2  clipped ,
                     '" | send_email.sh '                  ,
                     ' -r  ' , m_cts15m00b.de clipped      ,
                     ' -a  ' ,m_cts15m00b.para clipped     ,
                     ' -s "',m_cts15m00b.assunto clipped, '" '

  run l_param2.cmd}
   #PSI-2013-23297 - Inicio
   let l_mail.de = m_cts15m00b.de
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = m_cts15m00b.para
   let l_mail.cc = ""
   let l_mail.cco = ""
   let l_mail.assunto = m_cts15m00b.assunto
   let l_mail.mensagem = m_cts15m00b.mens2
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "html"
   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro
   #PSI-2013-23297 - Fim

  return

end function

#------------------------------------#
function cts15m00_rec_email_tmp()
#------------------------------------#

#--------------------------------------------------------------#
#-Roberto- Funcao para buscar os remetentes que recebem o e-mail
#          do carro extra
#--------------------------------------------------------------#


  define l_cpodes      like iddkdominio.cpodes

  define email record
         para     char(1000) ,
         de       char(100)  ,
         cc       char(1000) ,
         assunto  char(100)

  end record


  call cts15m00_prepara()

  let l_cpodes     = null

  initialize email.* to null

  let email.assunto = "Carro Extra  MTV-5 AVSSIN = S"
  let email.de = "EmailCorr.ct24hs@correioporto"
  let email.cc = ""

  open c_cts15m00_006
  foreach c_cts15m00_006 into l_cpodes

     if email.para is null then
        let email.para = l_cpodes
     else
        let email.para = email.para clipped, ",", l_cpodes
     end if

  end foreach
  close c_cts15m00_006

  return email.*

end function

#----------------------------------------#
function cts15m00_monta_mens_tmp(l_monta)
#----------------------------------------#

#--------------------------------------------------------------#
#-Roberto- Funcao que monta a mensagem para o envio do e-mail
#--------------------------------------------------------------#

  define l_monta record
         atdsrvnum  like datmservico.atdsrvnum ,
         atdsrvano  like datmservico.atdsrvano
  end record

  define l_bloco record
         mens1 char(1000) ,
         mens2 char(1000) ,
         mens3 char(1000) ,
         mens4 char(1000)
  end record

  define l_var record
         atdsrvorg  like datmservico.atdsrvorg,
         c24txtseq  like datmservhist.c24txtseq,
         funnom     like isskfunc.funnom      ,
         hist       char(1000)
  end record

  initialize l_bloco.* to null
  initialize l_var.* to null

  open c_cts15m00_009 using l_monta.atdsrvnum, l_monta.atdsrvano

  whenever error continue
  fetch c_cts15m00_009 into l_var.atdsrvorg
  whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," Origem do Servico nao encontrado "
            else
               error "Erro ", sqlca.sqlcode using "<<<<<&"
                    ," no acesso a tabela datmservico ."
            end if
         else
            let l_bloco.mens1 = d_cts15m00.doctxt ,
                                "Reserva : ", l_monta.atdsrvnum using '<<<<&&&&&&',"-",
                                              l_monta.atdsrvano using '&&'
         end if

  let l_bloco.mens2 = "Solicitante : " , d_cts15m00.c24solnom


  open c_cts15m00_008 using l_monta.atdsrvnum,l_monta.atdsrvano
  foreach c_cts15m00_008 into l_var.hist,
                            l_var.c24txtseq

     if l_bloco.mens3 is null then
        let l_bloco.mens3 = "Historico : <br><br>", l_var.hist
     else
        let l_bloco.mens3 = l_bloco.mens3 clipped, "<br>", l_var.hist
     end if

  end foreach
  close c_cts15m00_008

  let l_bloco.mens4 = l_bloco.mens1 clipped, "<br>", l_bloco.mens2 clipped, "<br>",
                      l_bloco.mens3

  return l_bloco.mens4

end function

function cts15m00_exibemsg(lr_param)

  define lr_param record
          avialgmtv         like datmavisrent.avialgmtv      ,
          avialgmtv_ant     like datmavisrent.avialgmtv      ,
          avivclgrp         like datkavisveic.avivclgrp      ,
          lcvsinavsflg      like datmavisrent.lcvsinavsflg   ,
          aviretdat         like datmavisrent.aviretdat      ,
          avirethor         like datmavisrent.avirethor
  end record
  define l_flgexb smallint
  define l_data      date,
         l_hora2     datetime hour to minute
   let l_flgexb = false
   let l_data  = null
   let l_hora2 = null
   call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
     if l_data <= lr_param.aviretdat and
        l_hora2 <= lr_param.avirethor then
           if lr_param.avialgmtv = lr_param.avialgmtv_ant then
               if (lr_param.avialgmtv   =   5   and
                  lr_param.avivclgrp   <> "A"   and
                  lr_param.avivclgrp   <> "B"   and
                  lr_param.lcvsinavsflg = 'S')  or
                  (lr_param.avialgmtv   = 4     and
                  lr_param.avivclgrp   <> "A"   and
                  lr_param.avivclgrp   <> "B" ) then
                  if (g_documento.acao <> "ALT"  or
                     g_documento.acao <> "CON")  then
                      let l_flgexb = true
                  else
                      let l_flgexb = false
                  end if
               else
                  let l_flgexb = false
               end if
           else
                if (lr_param.avialgmtv   =   5 and
                    lr_param.avivclgrp   <> "A"    and
                    lr_param.avivclgrp   <> "B"    and
                    lr_param.lcvsinavsflg = 'S')   or
                    (lr_param.avialgmtv   = 4    and
                     lr_param.avivclgrp   <> "A" and
                     lr_param.avivclgrp   <> "B" ) then
                    let l_flgexb = true
                else
                    let l_flgexb = false
                end if
           end if
     else
     if (g_documento.acao <> "ALT"  and
         g_documento.acao <> "CON" ) then
         if (lr_param.avialgmtv   =   5 and
             lr_param.avivclgrp   <> "A"    and
             lr_param.avivclgrp   <> "B"    and
             lr_param.lcvsinavsflg = 'S')   or
             (lr_param.avialgmtv   = 4    and
              lr_param.avivclgrp   <> "A" and
              lr_param.avivclgrp   <> "B" ) then
             let l_flgexb = true
         else
            let l_flgexb = false
         end if
     end if
  end if
return l_flgexb
end function

function cts15m00_verifica_clausula(lr_param)

  define lr_param record
       c24astcod like datkassunto.c24astcod,
       avialgmtv like datmavisrent.avialgmtv
  end record
  define lr_retorno record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
  end record
  define lr_funapol       record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
  end record
  define l_clscod like datrsrvcls.clscod,
         l_existe smallint
  initialize lr_retorno.* to null
  initialize lr_funapol.* to null
  let l_clscod = null
  let l_existe = false
  if m_prep_sql = "" or
     m_prep_sql = false then
    call cts15m00_prepara()
  end if
  call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning lr_funapol.*
  whenever error continue
  open ccts15m00032 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,lr_funapol.dctnumseq
  foreach ccts15m00032 into l_clscod
     let l_existe = true
     if l_clscod = "034" or
        l_clscod = "071" or
        l_clscod = "077" then # PSI 239.399 Clausula 77
       if cta13m00_verifica_clausula(g_documento.succod        ,
                                     g_documento.aplnumdig     ,
                                     g_documento.itmnumdig     ,
                                     lr_funapol.dctnumseq      ,
                                     l_clscod           ) then
        continue foreach
       end if
     end if
     if lr_param.c24astcod = 'H10' or
        lr_param.c24astcod = 'H12' then
        if lr_param.avialgmtv = 0 or
           lr_param.avialgmtv = 8 then
           if l_clscod <> '033' then
              continue foreach
            end if
        end if
        if lr_param.avialgmtv = 1 then
           if l_clscod[1,2] <> '26' then
              continue foreach
            end if
        end if
        if lr_param.avialgmtv = 2 then
           if l_clscod <> '033' and
              l_clscod <> '33R' then
              continue foreach
            end if
        end if
        if lr_param.avialgmtv = 9 then
           if l_clscod <> '33R' then
              continue foreach
            end if
        end if
     end if
     if lr_param.c24astcod = 'H11' or
        lr_param.c24astcod = 'H13' then
        if lr_param.avialgmtv = 7 then
           if l_clscod <> '033' then
              continue foreach
            end if
        end if
     end if
     open ccts15m00031 using lr_param.c24astcod,
                             g_documento.ramcod,
                             l_clscod
     fetch ccts15m00031 into lr_retorno.clscod
     close ccts15m00031
     if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.clscod = null
          let lr_retorno.erro = sqlca.sqlcode
          let lr_retorno.msg = "Clausula <",l_clscod ,"> n�o cadastrada para o assunto < ",lr_param.c24astcod ," > !"
          call errorlog(lr_retorno.msg)
       else
          let lr_retorno.clscod = null
          let lr_retorno.erro = sqlca.sqlcode
          let lr_retorno.msg = "Erro <",lr_retorno.erro ,"> na busca de assunto e clausula !"
          call errorlog(lr_retorno.msg)
       end if
     else
        exit foreach
     end if
     close ccts15m00031
  end foreach
  whenever error stop
  close ccts15m00032
  if l_existe = false then
     let lr_retorno.erro = 100
     let lr_retorno.msg  = " N�o existe clausula para essa apolice "
     call errorlog(lr_retorno.msg)
  end if
  return lr_retorno.*

end function


function cts15m00_verifica_endosso()


   define l_existe smallint,
          l_edstip  like abbmdoc.edstip,
          l_edstxt  like abbmdoc.edstxt,
          l_viginc  like abbmdoc.viginc,
          l_mens    char(300)


   define lr_retorno record
          viginc  like abbmdoc.viginc,
          endosso smallint
   end record


   initialize lr_retorno.* to null
   let l_existe = false
   let l_edstip = null
   let l_edstxt = null
   let l_viginc = null
   let l_mens   = null


   if m_prep is null or
      m_prep = 0 then
      call cts15m00_prepara()
   end if

   whenever error continue
   open ccts15m00034 using g_documento.succod,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig
   whenever error stop


   if sqlca.sqlcode <> 0 then
      let l_mens = "Erro < ",sqlca.sqlcode clipped, " > ao buscar os Endossos"
      call errorlog(l_mens)
   end if

   foreach ccts15m00034 into l_edstip,
                             l_edstxt,
                             l_viginc


       let l_existe = true

       if l_edstip = 0 or
          (l_edstip = 1 and l_edstxt = 1 ) or # 1/1 inclus�o de item
          (l_edstip = 2 and l_edstxt = 2 ) or # 2/2 Substitui��o de Veiculo
          (l_edstip = 3 and l_edstxt = 63 ) then # 3/63 Inclus�o de clausula
          let lr_retorno.viginc = l_viginc
          let lr_retorno.endosso = true
       else
         continue foreach
       end if

   end foreach

   close ccts15m00034

   return lr_retorno.*


end function

#===================================================
function cts15m00_webservice(lr_param)
#===================================================

  define lr_param record
         atdsrvnum like datmservico.atdsrvnum
        ,atdsrvano like datmservico.atdsrvano
        ,acao      char(3)
        ,procan    char(1)
  end record

  define lr_reserva record
         cnfenvcod     like datmrsvvcl.cnfenvcod    ,
         rsvsttcod     like datmrsvvcl.rsvsttcod    ,
         atzdianum     like datmrsvvcl.atzdianum    ,
         loccautip     like datmrsvvcl.loccautip ,
         vclretagncod  like datmrsvvcl.vclretagncod ,
         vclrethordat  like datmrsvvcl.vclrethordat ,
         vclretufdcod  like datmrsvvcl.vclretufdcod ,
         vclretcidnom  like datmrsvvcl.vclretcidnom ,
         vcldvlagncod  like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat  like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod  like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom  like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum  like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum  like datmrsvvcl.smsenvcelnum ,
         envemades     like datmrsvvcl.envemades    ,
         vclloccdrtxt  like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt
  end record

  define lr_datmavisrent record

         lcvcod          like datmavisrent.lcvcod
        ,aviestcod       like datmavisrent.aviestcod
        ,avirsrgrttip    like datmavisrent.avirsrgrttip
        ,aviprvent       like datmavisrent.aviprvent
        ,avirethor       like datmavisrent.avirethor
        ,aviretdat       like datmavisrent.aviretdat
        ,cdtoutflg       like datmavisrent.cdtoutflg

  end record

  define lr_erro record
        sqlcode smallint,
        mens    char(80)
  end record

  define lr_cts15m16   record
    msg1             char (50),
    msg2             char (50)
  end record

  define l_datahs    char(30),
         l_data      datetime year to day,
         l_hor       datetime hour to second,
         l_datadvlhs char(30)

  define lr_funapol   record
         resultado    char(01),
         dctnumseq    decimal(4,0),
         vclsitatu    decimal(4,0),
         autsitatu    decimal(4,0),
         dmtsitatu    decimal(4,0),
         dpssitatu    decimal(4,0),
         appsitatu    decimal(4,0),
         vidsitatu    decimal(4,0)
  end record

  define l_motivo like datmavisrent.avialgmtv
  define l_dias_atz_cia like datmprorrog.aviprodiaqtd
  define l_aviprostt    like datmprorrog.aviprostt


   define l_data2      date,
          l_hora2      datetime hour to minute,
          l_saldo      smallint


  initialize lr_datmavisrent.* to null
  initialize lr_reserva.* to null
  initialize lr_erro.* to null
  initialize lr_cts15m16.* to null
  initialize lr_funapol.* to null
  let l_dias_atz_cia  = 0
  let l_data2 = null
  let l_hora2 = null
  let l_saldo = null





  let l_datahs   = null
  let l_datadvlhs   = null
  let l_data     = null
  let l_hor      = null

  if m_prep is null or
     m_prep = false then
     call cts15m00_prepara()
  end if

  let int_flag= false

  call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning lr_funapol.*

  if m_f7 = true and
     g_documento.acao is null then
     return 1, ''
  end if

  if g_documento.acao is null or
     m_ctd31.rsvlclcod is not null then
     call cts15m16(lr_param.atdsrvnum, lr_param.atdsrvano)
          returning lr_cts15m16.msg1,lr_cts15m16.msg2
  end if

 open ccts15m00037 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch ccts15m00037 into lr_datmavisrent.lcvcod ,lr_datmavisrent.aviestcod   ,lr_datmavisrent.aviretdat
                         ,lr_datmavisrent.avirethor, lr_datmavisrent.aviprvent
                         ,lr_datmavisrent.avirsrgrttip, lr_datmavisrent.cdtoutflg,l_motivo
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error 'Dados da reserva nao foram encontrados. AVISE A INFORMATICA!'  sleep 1
    else
       error 'Erro SELECT ccts15m00037 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 1
       error 'CTS15M00 / cts15m00_webservice() / ',lr_param.atdsrvnum,' / '
                                                  ,lr_param.atdsrvano sleep 1
    end if

 end if

 open ccts15m00036 using lr_datmavisrent.lcvcod,
                         lr_datmavisrent.aviestcod
 whenever error continue
 fetch ccts15m00036 into lr_reserva.vclretagncod,
                         lr_reserva.vclretufdcod,
                         lr_reserva.vclretcidnom

 whenever error stop

 if sqlca.sqlcode <> 0 then
    error 'Erro ao buscar loja '
 end if

 if m_cidnom is not null and
    m_ufdcod is not null then
    let lr_reserva.vclretufdcod = m_ufdcod
    let lr_reserva.vclretcidnom = m_cidnom
 end if


 let l_data = lr_datmavisrent.aviretdat
 let l_hor  = lr_datmavisrent.avirethor
 let l_datahs = l_data,
                " ",
                l_hor

 # Calculo da data de devolu��o de acordo com a atzdianum


 let l_data = lr_datmavisrent.aviretdat + lr_datmavisrent.aviprvent units day
 let l_hor  = lr_datmavisrent.avirethor
 let l_datadvlhs = l_data,
                   " ",
                   l_hor

 let lr_reserva.atzdianum    = lr_datmavisrent.aviprvent
 let lr_reserva.loccautip    = lr_datmavisrent.avirsrgrttip
 let lr_reserva.vclrethordat = l_datahs clipped
 let lr_reserva.vcldvlagncod = lr_reserva.vclretagncod
 let lr_reserva.vcldvlhordat = l_datadvlhs clipped
 let lr_reserva.vcldvlufdcod = lr_reserva.vclretufdcod
 let lr_reserva.vcldvlcidnom = lr_reserva.vclretcidnom
 let lr_reserva.smsenvdddnum = d_cts15m00.smsenvdddnum
 let lr_reserva.smsenvcelnum = d_cts15m00.smsenvcelnum
 let lr_reserva.vclloccdrtxt = lr_datmavisrent.cdtoutflg
 let lr_reserva.vclloccdrtxt = lr_cts15m16.msg1," ",lr_cts15m16.msg2

 if lr_datmavisrent.cdtoutflg = "S" then
    let lr_reserva.vclcdtsgnindtxt = 'PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)'
 end if

 # Regra criada para motivos particular ( zerar diarias autorizadas pela porto)
 if l_motivo = 5 then
    let  lr_reserva.atzdianum   = 0
 end if

 # ligia - 26/05/11

 if lr_param.acao = "ALT" or lr_param.acao = "CAN" or m_f7 = true then

    # Verifica se a reserva foi realizada via online e situacao
    initialize m_ctd31.* to null
    call ctd31g00_ver_solicitacao(lr_param.atdsrvnum, lr_param.atdsrvano)
         returning m_ctd31.*


    if m_ctd31.rsvlclcod is not null then

       if lr_param.acao = "CAN" then
          ## cancelar reserva
          call ctd31g00_canc_rsv(lr_param.atdsrvnum
                                 ,lr_param.atdsrvano, 1
                                 ,lr_reserva.vclloccdrtxt)
               returning lr_erro.sqlcode, lr_erro.mens
       else
          if lr_param.acao = "ALT" then

                let l_aviprostt = "A"
                open ccts15m00040 using lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,l_aviprostt

                whenever error continue
                let l_dias_atz_cia = 0
                fetch ccts15m00040 into l_dias_atz_cia
                close ccts15m00040

                if l_dias_atz_cia is null then
                   let l_dias_atz_cia = 0
                end if

                if l_dias_atz_cia > 0 then ##dias autorizados CIA
                      let lr_reserva.atzdianum = lr_reserva.atzdianum +
                                                 l_dias_atz_cia
                end if


             if m_alt_motivo = true then

                  let g_data_dev = l_datadvlhs
                  call ctx01g00_saldo_novo
                    (g_documento.succod   , g_documento.aplnumdig,
                     g_documento.itmnumdig, g_documento.atdsrvnum,
                     g_documento.atdsrvano, l_data2 ,
                     1, true, g_documento.ciaempcod, l_motivo,
                     g_documento.c24astcod)
                     returning g_lim_diaria, l_saldo

                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2


                   if lr_reserva.atzdianum > g_lim_diaria then
                      let lr_reserva.atzdianum = g_lim_diaria
                   end if

             end if

             if lr_param.procan = "P" or
                m_alt_motivo = true then ##se for prorrogacao
                call ctd31g00_alt_diarias(lr_param.atdsrvnum,
                                          lr_param.atdsrvano,
                                          g_lim_diaria,
                                          lr_reserva.atzdianum,
                                          ###g_data_ret,
                                          g_data_dev,
                                          lr_reserva.vclloccdrtxt)
                     returning lr_erro.sqlcode, lr_erro.mens
             else
                if lr_param.procan = "C" then ##se for cancelamentoprorrogacao

                   let l_aviprostt = "C"

                      call ctd31g00_canc_prorrog(lr_param.atdsrvnum,
                                                 lr_param.atdsrvano,
                                                 g_lim_diaria,
                                                 lr_reserva.atzdianum,
                                                 lr_reserva.vclloccdrtxt)
                            returning lr_erro.sqlcode, lr_erro.mens

                else ##dias autorizados USUARIO

                   if m_f7 = true then ## REENVIO DA RESERVA
                      # Verifica se J� Houve Reserva
                      if  cts15m00_verifica_reenvio(lr_param.atdsrvnum,
                                                    lr_param.atdsrvano) then
                          call ctd31g00_reenvio(lr_param.atdsrvnum,
                                                lr_param.atdsrvano, 1,
                                                lr_reserva.vclloccdrtxt)
                               returning lr_erro.sqlcode, lr_erro.mens
                          if lr_erro.sqlcode <> 0 then
                             error lr_erro.mens
                          end if
                      end if
                   else ### se for alteracao no laudo

                        call ctd31g00_upd_reserva
                                (lr_param.atdsrvnum,      # numero Servico
                                 lr_param.atdsrvano,      # Ano do Servico
                                 1,                       # Codigo status da Reserva
                                 lr_reserva.atzdianum,    # numero de diarias autorizadas
                                 lr_reserva.loccautip,    # Locacao isenta de caucao
                                 lr_reserva.vclretagncod, # Agencia da retirada do veiculo
                                 lr_reserva.vclrethordat, #
                                 lr_reserva.vclretufdcod, # Codigo UF de retirada do veiculo
                                 lr_reserva.vclretcidnom, # Nome Cidade de retirada do veiculo
                                 lr_reserva.vcldvlagncod, # Codigo Agencia da devolucao do veiculo
                                 lr_reserva.vcldvlhordat, # Data hora da devolucao do veiculo
                                 lr_reserva.vcldvlufdcod, # Codigo UF de devolucao do veiculo
                                 lr_reserva.vcldvlcidnom, # Nome Cidade de devolucao do veiculo
                                 d_cts15m00.smsenvdddnum, # DDD para envio de SMS
                                 d_cts15m00.smsenvcelnum, # Numero celular para envio de SMS
                                 lr_reserva.vclloccdrtxt, # Observa��es da loca��o
                                 lr_reserva.vclcdtsgnindtxt)
                        returning lr_erro.sqlcode,lr_erro.mens
                   end if
                end if
             end if
          end if
       end if
    else
       return 1, ''
    end if
 else
       call ctd31g00_ins_reserva(lr_param.atdsrvnum,      # numero Servico
                           lr_param.atdsrvano,      # Ano do Servico
                           "",                      # Tipo de Envio de Confirma��o
                           1,                       # Codigo status da Reserva
                           lr_reserva.atzdianum,    # numero de diarias autorizadas
                           lr_reserva.loccautip,    # Locacao isenta de caucao
                           lr_reserva.vclretagncod, # Agencia da retirada do veiculo
                           lr_reserva.vclrethordat, #
                           lr_reserva.vclretufdcod, # Codigo UF de retirada do veiculo
                           lr_reserva.vclretcidnom, # Nome Cidade de retirada do veiculo
                           lr_reserva.vcldvlagncod, # Codigo Agencia da devolucao do veiculo
                           lr_reserva.vcldvlhordat, # Data hora da devolucao do veiculo
                           lr_reserva.vcldvlufdcod, # Codigo UF de devolucao do veiculo
                           lr_reserva.vcldvlcidnom, # Nome Cidade de devolucao do veiculo
                           d_cts15m00.smsenvdddnum, # DDD para envio de SMS
                           d_cts15m00.smsenvcelnum, # Numero celular para envio de SMS
                           lr_reserva.envemades   , # Email para envio de confirmacao
                           lr_reserva.vclloccdrtxt, # Observa��es da loca��o
                           lr_reserva.vclcdtsgnindtxt,
                           g_documento.succod,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig,
                           lr_funapol.dctnumseq,
                           g_documento.ramcod,
                           g_documento.edsnumref,
                           g_documento.ciaempcod) # Nome do segundo condutor
            returning lr_erro.sqlcode,lr_erro.mens

         if lr_erro.sqlcode <> 0 then
            call errorlog(lr_erro.mens)
            let lr_erro.mens = "Erro <",lr_erro.sqlcode clipped,"> na fun��o ctd31g00_ins_reserva, Avise a Informatica !"
            call errorlog(lr_erro.mens)
            error lr_erro.mens
         end if
  end if

  # Rodolfo Massini - Alteracao Carro Extra - Inicio

  # Ponto de acesso apos a gravacao do laudo
  call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,
                              lr_param.atdsrvano)

  # Rodolfo Massini - Alteracao Carro Extra - Inicio

  return lr_erro.sqlcode, lr_erro.mens

#==================================================
end function
#==================================================

#==================================================
function cts15m00_popup_garantia()
#==================================================


   define lr_popup record
         titulo  char(100),
         opcoes  char(1000)
  end record


  let lr_popup.titulo = 'Garantia'

  if d_cts15m00.avialgmtv = 4      and
     g_documento.c24astcod = 'H10' then

     let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao|Isencao de Garantia"
  else
     let lr_popup.opcoes = "Cartao de Credito|Cheque Caucao"
  end if

  while true

     call ctx14g01(lr_popup.titulo,lr_popup.opcoes)
          returning m_opcao,d_cts15m00.garantia

     if m_opcao is not null and
        m_opcao <> 0 then
        exit while
     end if

  end while

  case m_opcao

    when 1

     let d_cts15m00.cauchqflg = "N"
     let d_cts15m00.cartao    = "S"
     let d_cts15m00.flgarantia = "S"

    when 2
       let d_cts15m00.cauchqflg = "S"
       let d_cts15m00.cartao    = "N"
       let d_cts15m00.flgarantia = "S"

    when 3
       let d_cts15m00.cauchqflg = "N"
       let d_cts15m00.cartao    = "N"
       let d_cts15m00.flgarantia = "S"
   end case

end function

function cts15m00_dados_locacao()

   define lr_retorno record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         rsvlclcod        like datmrsvvcl.rsvlclcod    ,
         loccntcod        like datmrsvvcl.loccntcod    ,
         cnfenvcod        like datmrsvvcl.cnfenvcod    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         intsttcrides     like datmvclrsvitf.intsttcrides ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         envemades        like datmrsvvcl.envemades    ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt,
         apvhordat        like datmrsvvcl.apvhordat ,
         itfsttcod        like datmvclrsvitf.itfsttcod,
         itfgrvhordat     like datmvclrsvitf.itfgrvhordat,
         data             date   ,
         hora             datetime hour to second,
         status_reserva   char(15),
         mens1            char(50),
         mens2            char(50)
   end record

  define prompt_key char (01)

  define l_aux_data       char(30)
  define l_ano char(4)
  define l_mes char(2)
  define l_dia char(2)
  define l_hora char(8)


  define lr_erro record
         sqlcode smallint,
         mens    char(80)
  end record


   initialize lr_retorno.* to null
   initialize lr_erro.* to null


     call ctd31g00_sel_reserva_solic(1
                                    ,g_documento.atdsrvnum
                                    ,g_documento.atdsrvano)
     returning  lr_erro.sqlcode
               ,lr_erro.mens
               ,lr_retorno.atdsrvnum
               ,lr_retorno.atdsrvano
               ,lr_retorno.rsvlclcod
               ,lr_retorno.loccntcod
               ,lr_retorno.cnfenvcod
               ,lr_retorno.rsvsttcod
               ,lr_retorno.atzdianum
               ,lr_retorno.loccautip
               ,lr_retorno.vclretagncod
               ,lr_retorno.vclrethordat
               ,lr_retorno.vclretufdcod
               ,lr_retorno.vclretcidnom
               ,lr_retorno.vcldvlagncod
               ,lr_retorno.vcldvlhordat
               ,lr_retorno.vcldvlufdcod
               ,lr_retorno.vcldvlcidnom
               ,lr_retorno.smsenvdddnum
               ,lr_retorno.smsenvcelnum
               ,lr_retorno.envemades
               ,lr_retorno.vclloccdrtxt
               ,lr_retorno.vclcdtsgnindtxt
               ,lr_retorno.apvhordat
               ,lr_retorno.intsttcrides
               ,lr_retorno.itfsttcod
               ,lr_retorno.itfgrvhordat

     open window cts15m17 at 09,17 with form "cts15m17"
                 attribute (form line 1, border)

     display by name  #lr_retorno.loccntcod              # Contrato
                     lr_retorno.rsvlclcod              # Localizador
                     #,lr_retorno.status_reserva         # Status da Reserva
                     #,lr_retorno.data                   # Data de Confirma��o
                     #,lr_retorno.hora                   # Hora de Confirma��o
                     #,lr_retorno.smsenvdddnum           # DDD
                     #,lr_retorno.smsenvcelnum           # Celular
                     #,lr_retorno.mens1                  # Mensagem 1
                     #,lr_retorno.mens2                  # Mensagem 2



      while true

      prompt "(F17)Abandona" attribute(reverse) for prompt_key


       on key (interrupt)
       close window cts15m17
       exit while

      end prompt
  end while


end function

#--------------------------------------------------------------------
function cts15m00_ver_alt_laudo()
#--------------------------------------------------------------------

 define a_hist     array[28] of char(100),
        l_data     date,
        l_hora     datetime hour to minute,
        l_linha    integer,
        l_erro     integer

 initialize a_hist to null

 for l_linha = 1 to 28
    initialize a_hist[l_linha] to null
 end for


 let l_data     = null
 let l_hora     = null
 let l_linha    = 0
 let l_erro     = null

 if d_cts15m00.nom <> m_cts15ant.nom then
    let a_hist[1] = "Alterado Nome Segurado de ", m_cts15ant.nom clipped,
                                        " para ", d_cts15m00.nom clipped
 end if
 if d_cts15m00.corsus <> m_cts15ant.corsus then
    let a_hist[2] = "Alterado Codigo Corretor  de ", m_cts15ant.corsus clipped,
                                           " para ", d_cts15m00.corsus clipped
 end if
 if d_cts15m00.cornom <> m_cts15ant.cornom then
    let a_hist[3] = "Alterado Nome Corretor  de ", m_cts15ant.cornom clipped,
                                         " para ", d_cts15m00.cornom clipped
 end if
 if d_cts15m00.vclcoddig <> m_cts15ant.vclcoddig then
    let a_hist[4] = "Alterado Cod Veiculo  de ", m_cts15ant.vclcoddig clipped,
                                       " para ", d_cts15m00.vclcoddig clipped
 end if
 if d_cts15m00.vclanomdl <> m_cts15ant.vclanomdl then
    let a_hist[5] = "Alterado Mod Veiculo  de ", m_cts15ant.vclanomdl clipped,
                                       " para ", d_cts15m00.vclanomdl clipped
 end if
 if d_cts15m00.vcllicnum <> m_cts15ant.vcllicnum then
    let a_hist[6] = "Alterado Placa Veiculo  de ", m_cts15ant.vcllicnum clipped,
                                         " para ", d_cts15m00.vcllicnum clipped
 end if
 if d_cts15m00.avilocnom <> m_cts15ant.avilocnom then
    let a_hist[7] = "Alterado Nome Usuario  de ", m_cts15ant.avilocnom clipped,
                                        " para ", d_cts15m00.avilocnom clipped
 end if
 if d_cts15m00.cdtoutflg <> m_cts15ant.cdtoutflg then
    let a_hist[8] = "Alterado Outro Condutor de ", m_cts15ant.cdtoutflg clipped,
                                         " para ", d_cts15m00.cdtoutflg clipped
 end if
 if d_cts15m00.avialgmtv <> m_cts15ant.avialgmtv then
    let a_hist[9] = "Alterado Motivo de ", m_cts15ant.avialgmtv clipped,
                                 " para ", d_cts15m00.avialgmtv clipped
 end if
 if d_cts15m00.lcvsinavsflg <> m_cts15ant.lcvsinavsflg then
    let a_hist[10] = "Alterado Aviso Sinistro de ",
                               m_cts15ant.lcvsinavsflg clipped,
                     " para ", d_cts15m00.lcvsinavsflg clipped
 end if
 if d_cts15m00.lcvcod <> m_cts15ant.lcvcod then
    let a_hist[11] = "Alterado Cod Locadora de ",
                               m_cts15ant.lcvcod clipped,
                     " para ", d_cts15m00.lcvcod clipped
 end if
 if d_cts15m00.lcvextcod <> m_cts15ant.lcvextcod then
    let a_hist[12] = "Alterado Cod da Loja  de ",
                               m_cts15ant.lcvextcod clipped,
                     " para ", d_cts15m00.lcvextcod clipped
 end if
 if d_cts15m00.avivclcod <> m_cts15ant.avivclcod then
    let a_hist[13] = "Alterado Cod Veiculo de ",
                               m_cts15ant.avivclcod clipped,
                     " para ", d_cts15m00.avivclcod clipped
 end if
 if d_cts15m00.frmflg <> m_cts15ant.frmflg then
    let a_hist[14] = "Alterado Entrada Formulario de ",
                               m_cts15ant.frmflg clipped,
                     " para ", d_cts15m00.frmflg clipped
 end if
 if d_cts15m00.aviproflg <> m_cts15ant.aviproflg then
    let a_hist[15] = "Alterado Prorrogacao de ",
                               m_cts15ant.aviproflg clipped,
                     " para ", d_cts15m00.aviproflg clipped
 end if
 if d_cts15m00.cttdddcod <> m_cts15ant.cttdddcod then
    let a_hist[16] = "Alterado DDD fixo de ",
                               m_cts15ant.cttdddcod clipped,
                     " para ", d_cts15m00.cttdddcod clipped
 end if
 if d_cts15m00.ctttelnum <> m_cts15ant.ctttelnum then
    let a_hist[17] = "Alterado Tel fixo de ",
                               m_cts15ant.ctttelnum clipped,
                     " para ", d_cts15m00.ctttelnum clipped
 end if
 if d_cts15m00.atdlibflg <> m_cts15ant.atdlibflg then
    let a_hist[18] = "Alterado Serv. Liberado de ",
                               m_cts15ant.atdlibflg clipped,
                     " para ", d_cts15m00.atdlibflg clipped
 end if
 if d_cts15m00.locrspcpfnum <> m_cts15ant.locrspcpfnum then
    let a_hist[19] = "Alterado CPF de ",
                               m_cts15ant.locrspcpfnum clipped,
                     " para ", d_cts15m00.locrspcpfnum clipped
 end if
 if d_cts15m00.locrspcpfdig <> m_cts15ant.locrspcpfdig then
    let a_hist[20] = "Alterado Digito CPF de ",
                               m_cts15ant.locrspcpfdig clipped,
                     " para ", d_cts15m00.locrspcpfdig clipped
 end if
 if d_cts15m00.smsenvdddnum <> m_cts15ant.smsenvdddnum or
    (d_cts15m00.smsenvdddnum is not null and
     m_cts15ant.smsenvdddnum is null) then
    let a_hist[21] = "Alterado DDD Celular de ",
                               m_cts15ant.smsenvdddnum clipped,
                     " para ", d_cts15m00.smsenvdddnum clipped
 end if
 if d_cts15m00.smsenvcelnum <> m_cts15ant.smsenvcelnum or
    (d_cts15m00.smsenvcelnum is not null and
     m_cts15ant.smsenvcelnum is null) then
    let a_hist[22] = "Alterado Tel Celular de ",
                               m_cts15ant.smsenvcelnum clipped,
                     " para ", d_cts15m00.smsenvcelnum clipped
 end if

 if d_cts15m00.flgarantia <> m_cts15ant.flgarantia then
    let a_hist[24] = "Alterado Indicacao Garantia de ",
                               m_cts15ant.garantia clipped, "=",
                               m_cts15ant.flgarantia clipped,
                     " para ", d_cts15m00.garantia clipped, "=",
                               d_cts15m00.flgarantia clipped
 end if


 if w_cts15m00.aviretdat <> m_cts15m04.aviretdat then
    let a_hist[25] = "Alterado Data de Retirada de ",
                               m_cts15m04.aviretdat clipped,
                     " para ", w_cts15m00.aviretdat clipped
 end if

 if w_cts15m00.avirethor <> m_cts15m04.avirethor then
    let a_hist[26] = "Alterado Hora de Retirada de ",
                               m_cts15m04.avirethor clipped,
                     " para ", w_cts15m00.avirethor clipped
 end if

 if w_cts15m00.aviprvent <> m_cts15m04.aviprvent then
    let a_hist[27] = "Alterado previsao de uso de ",
                               m_cts15m04.aviprvent clipped,
                     " para ", w_cts15m00.aviprvent clipped
 end if

 call cts40g03_data_hora_banco(2) returning l_data, l_hora

 for l_linha = 1 to 28
     if a_hist[l_linha] is not null then
        let m_flag_alt = true

        call cts10g02_historico(g_documento.atdsrvnum
                               ,g_documento.atdsrvano
                               ,l_data
                               ,l_hora
                               ,g_issk.funmat
                               ,a_hist[l_linha]
                               ,"" ,"" ,"" ,"")
             returning l_erro
     end if

 end for

# if m_flag_alt = false then
#    call cts10g02_historico(g_documento.atdsrvnum
#                           ,g_documento.atdsrvano
#                           ,l_data
#                           ,l_hora
#                           ,g_issk.funmat
#                           ,'Laudo nao sofreu Alteracoes'
#                           ,"" ,"" ,"" ,"")
#         returning l_erro
# end if

end function

#---------------------------------#
 function cts15m00_opcoes()
#---------------------------------#

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_zero            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,w_ret             integer


 ###  Montar popup com as opcoes


  let l_popup  = "Localizador|Prorrogacao"


 let l_par1   = "FUNCOES"
 let l_nulo   = null

 while true

    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao

    if l_opcao =  1 then  # Localizador

       if d_cts15m00.acntip = 3 then
         call cts15m00_dados_locacao()
      else
         let m_cts08g01 = cts08g01("A"
                                   ,"N"
                                   ,"ESTA RESERVA FOI ENCAMINHADA VIA FAX."
                                   ,"A FUNCAO LOCALIZADOR E EXCLUSIVA "
                                   ,"PARA RESERVAS ENCAMINHADAS VIA ONLINE"
                                   ,"")
      end if
    end if

    if l_opcao = 2 then # Prorrogacao
        call cts15m05(g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        d_cts15m00.lcvcod,
                        d_cts15m00.aviestcod ,
                        "", ## n�o eh usado no cts15m05
                        d_cts15m00.avialgmtv ,
                        d_cts15m00.dtentvcl,
                        d_cts15m00.avivclgrp,
                        d_cts15m00.lcvsinavsflg)
          returning w_cts15m00.procan,
                    w_cts15m00.aviprodiaqtd
     end if

 end while

end function


function cts15m00_verifica_data_retirada()

define l_retorno char(1)

define l_data      date,
       l_hora2     datetime hour to minute,
       l_aviretdat like datmavisrent.aviretdat,
       l_avirethor like datmavisrent.avirethor

let l_retorno = 'N'

let l_aviretdat = null
let l_avirethor = null
let l_data      = null
let l_hora2     = null

call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2

whenever error continue
open ccts15m00041 using g_documento.atdsrvnum,
                       g_documento.atdsrvano
fetch ccts15m00041 into l_aviretdat,l_avirethor
whenever error stop

if sqlca.sqlcode <> 0 then
   error "Erro ao Buscar dados da reserva, Avise a Informatica !"
end if



if l_data > l_aviretdat then
      let l_retorno = 'S'
      let m_prorrog = true
else
  if l_data = l_aviretdat then
     if l_hora2 > l_avirethor then
        let l_retorno = 'S'
        let m_prorrog = true
     end if
  end if
end if

if g_issk.funmat = 13020 then
   display "8097 m_prorrog = ",m_prorrog
end if

return l_retorno

end function
#===================================================
function cts15m00_verifica_reenvio(lr_param)
#===================================================
define lr_param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
end record
define lr_retorno record
  cont    smallint,
  reenvia smallint
end record
initialize lr_retorno.* to null
 if m_prep_sql is null or
 	  m_prep_sql <> true then
    call cts15m00_prepara()
 end if
 whenever error continue
 open ccts15m00043 using lr_param.atdsrvnum,
                         lr_param.atdsrvano
 fetch ccts15m00043 into lr_retorno.cont
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ao Buscar Dados da Interface da Reserva!"
 end if
 if lr_retorno.cont > 0 then
    let lr_retorno.reenvia = false
 else
 	  let lr_retorno.reenvia = true
 end if
 return lr_retorno.reenvia
end function
#------------------------------------------------------------------
 function cts15m00_ver_claus2(param)
#------------------------------------------------------------------
  define param record
         succod like abbmitem.succod ,
         aplnumdig like abbmitem.aplnumdig ,
         itmnumdig like abbmitem.itmnumdig
  end record
  define l_ver_claus like abbmclaus.clscod
  define l_clscod33 like abbmclaus.clscod
  define l_clscod34 like abbmclaus.clscod
  define l_clscod35 like abbmclaus.clscod
  define l_clscod44 like abbmclaus.clscod
  define l_clscod46 like abbmclaus.clscod
  define l_clscod47 like abbmclaus.clscod
  define l_clscod48 like abbmclaus.clscod
  define l_ver_dctnumseq like abbmclaus.dctnumseq
  let l_clscod33 = null
  let l_clscod34 = null
  let l_clscod35 = null
  let l_clscod44 = null
  let l_clscod46 = null
  let l_clscod47 = null
  let l_clscod48 = null
  let l_ver_claus = null
  let l_ver_dctnumseq = null
  if param.succod is null or
     param.aplnumdig is null or
     param.itmnumdig is null then
     return l_clscod33, l_clscod46, l_clscod47, l_clscod44,
            l_clscod48, l_clscod34, l_clscod35
  end if
  open c_cts15m00_044 using g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig
  fetch c_cts15m00_044 into l_ver_dctnumseq
  close c_cts15m00_044
  open c_cts15m00_011 using g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            l_ver_dctnumseq
  foreach c_cts15m00_011 into l_ver_claus
          if l_ver_claus = '033' or
             l_ver_claus = '33R' then
             let l_clscod33 = l_ver_claus
          end if
          if l_ver_claus = '044' or
             l_ver_claus = '44R' then
             let l_clscod44 = l_ver_claus
          end if
          if l_ver_claus = '046' or
             l_ver_claus = '46R' then
             let l_clscod46 = l_ver_claus
	        end if
          if l_ver_claus = '047' or
	           l_ver_claus = '47R' then
	           let l_clscod47 = l_ver_claus
          end if
          if l_ver_claus = '048' or
             l_ver_claus = '48R' then
             let l_clscod48 = l_ver_claus
          end if
          if l_ver_claus = '034' then
             let l_clscod34 = l_ver_claus
          end if
          if l_ver_claus = '035' then
             let l_clscod35 = l_ver_claus
          end if
  end foreach
  return l_clscod33,
         l_clscod44,
         l_clscod46,
         l_clscod47,
         l_clscod48,
         l_clscod34,
         l_clscod35
end function

#---------------------------------------------------------
function cts15m00_recupera_reserva(lr_param)
#---------------------------------------------------------

 define lr_param record
        succod         like datrligapol.succod    ,
        ramcod         like datrligapol.ramcod    ,
        aplnumdig      like datrligapol.aplnumdig ,
        itmnumdig      like datrligapol.itmnumdig ,
        c24astcod      like datkassunto.c24astcod ,
        avialgmtv      like datmavisrent.avialgmtv,
        avialgmtv_ant  like datmavisrent.avialgmtv,
        aviprvent      like datmavisrent.aviprvent
 end record

 define lr_retorno record
        atdsrvnum    like datmservico.atdsrvnum     ,
        atdsrvano    like datmservico.atdsrvano     ,
        atdetpcod    like datmsrvacp.atdetpcod      ,
        aviprvent    like datmavisrent.aviprvent    ,
        aviretdat    like datmavisrent.aviretdat    ,
        lcvcod       like datmavisrent.lcvcod       ,
        resultado    smallint                       ,
        mensagem     char(100)                      ,
        acntip       like datklocadora.acntip       ,
        lcvresenvcod like datklocadora.lcvresenvcod ,
        maides       like datkavislocal.maides      ,
        vcleftretdat date                           ,
        vcleftdvldat date                           ,
        vcleftrethou datetime hour to minute        ,
        vcleftdvlhou datetime hour to minute        ,
        intervalo    interval hour(04) to minute    ,
        atzdianum    like datmrsvvcl.atzdianum      ,
        saldo        smallint                       ,
        flag         smallint                       ,
        tot_dia      smallint                       ,
        qtd_dia      integer                        ,
        qtd_fat      integer                        ,
        msg1         char(40)                       ,
        msg2         char(40)                       ,
        msg3         char(40)                       ,
        msg4         char(40)                       ,
        confirma     char(01)                       ,
        bloqueio     char(01)                       ,
        flag_custo   char(01)                       ,
        soma         smallint                       ,
        tipo_reserva smallint                       ,
        total        smallint
 end record

 initialize lr_retorno.* to null


 let g_flag_msg              = 0
 let g_saldo                 = null
 let lr_retorno.tipo_reserva = 2
 let lr_retorno.flag         = 0
 let lr_retorno.qtd_dia      = 0
 let lr_retorno.qtd_fat      = 0
 let lr_retorno.tot_dia      = 7
 let lr_retorno.total        = 0
 let lr_retorno.bloqueio     = "N"
 let lr_retorno.flag_custo   = "N"

 if lr_param.avialgmtv = 2 then

 	  let lr_retorno.saldo = lr_retorno.tot_dia

 	  #------------------------------------------------#
 	  # Recupera os Servicos da Apolice
 	  #------------------------------------------------#


    open ccts15m00044 using lr_param.succod
                           ,lr_param.ramcod
                           ,lr_param.aplnumdig
                           ,lr_param.itmnumdig
                           ,lr_param.c24astcod
                           ,lr_param.avialgmtv

       foreach ccts15m00044 into lr_retorno.atdsrvnum,
       	                         lr_retorno.atdsrvano


           #------------------------------------------------#
           # Desconsidera o Proprio Servico do Processo
           #------------------------------------------------#

           if g_documento.atdsrvnum is not null and
              g_documento.atdsrvano is not null then

              if 	g_documento.atdsrvnum = lr_retorno.atdsrvnum and
              	  g_documento.atdsrvano = lr_retorno.atdsrvano and
              	  lr_param.avialgmtv_ant <> 5                  then
              	  	continue foreach
              end if

           end if


           #------------------------------------------------#
           # Obtem a Ultima Etapa do Servico
           #------------------------------------------------#

           let lr_retorno.atdetpcod = cts10g04_ultima_etapa(lr_retorno.atdsrvnum
                                                           ,lr_retorno.atdsrvano)


           if lr_retorno.atdetpcod = 1 or
           	  lr_retorno.atdetpcod = 4 then

           	  #------------------------------------------------#
           	  # Recupera os Dados da Locacao
           	  #------------------------------------------------#

              open ccts15m00045 using  lr_retorno.atdsrvnum,
                                       lr_retorno.atdsrvano

              whenever error continue
              fetch ccts15m00045 into lr_retorno.aviprvent,
                                      lr_retorno.aviretdat,
                                      lr_retorno.lcvcod
              whenever error stop

              if sqlca.sqlcode = notfound  then
                 continue foreach
              end if

              close ccts15m00045

              #-----------------------------------------------------#
              # Obter o Tipo de Acionamento de Acordo com a Locadora
              #-----------------------------------------------------#

              call ctc30g00_dados_loca(1, lr_retorno.lcvcod)
              returning lr_retorno.resultado
                       ,lr_retorno.mensagem
                       ,lr_retorno.acntip
                       ,lr_retorno.lcvresenvcod
                       ,lr_retorno.maides

              if lr_retorno.acntip = 3 then

              	 #------------------------------------------------#
              	 # Recupera os Dados da Locacao da Integracao
              	 #------------------------------------------------#

              	 open ccts15m00046 using  lr_retorno.atdsrvnum,
              	                          lr_retorno.atdsrvano

              	 whenever error continue
              	 fetch ccts15m00046 into lr_retorno.vcleftretdat,
              	                         lr_retorno.vcleftdvldat,
              	                         lr_retorno.vcleftrethou,
              	                         lr_retorno.vcleftdvlhou,
              	                         lr_retorno.atzdianum
              	 whenever error stop

              	 #------------------------------------------------#
              	 # Calcula o Saldo da Locacao com Integracao
              	 #------------------------------------------------#


              	 if lr_retorno.vcleftretdat is not null and
              	 	  lr_retorno.vcleftdvldat is not null then

              	 	  	let lr_retorno.intervalo = (lr_retorno.vcleftdvlhou - lr_retorno.vcleftrethou)

              	 	  	if lr_retorno.intervalo > "01:00" then
              	 	  	    let lr_retorno.soma = 1
              	 	  	else
              	 	  		  let lr_retorno.soma = 0
              	 	    end if

              	      let lr_retorno.qtd_dia = (lr_retorno.vcleftdvldat - lr_retorno.vcleftretdat) + lr_retorno.soma
              	      let lr_retorno.saldo   = lr_retorno.saldo - lr_retorno.qtd_dia
              	      let lr_retorno.flag    = 1

              	 else

              	      let lr_retorno.qtd_dia = lr_retorno.atzdianum
              	      let lr_retorno.saldo   = lr_retorno.saldo - lr_retorno.qtd_dia
              	      let lr_retorno.flag    = 1

              	 end if

              	 close ccts15m00046

              	 let lr_retorno.tipo_reserva = 1
              	 let g_saldo = lr_retorno.saldo

              else

              	 #------------------------------------------------#
              	 # Calcula o Saldo da Locacao sem Integracao
              	 #------------------------------------------------#

              	 let lr_retorno.saldo = lr_retorno.saldo - lr_retorno.aviprvent
              	 let lr_retorno.flag  = 1

              	 let lr_retorno.tipo_reserva = 2
              	 let g_saldo = null

              end if

           end if

       end foreach


       if lr_retorno.flag = 1 then

          if lr_retorno.saldo < 1 then

             #------------------------------------------------#
             # Mostra a Mensagem de Bloqueio
             #------------------------------------------------#

             let lr_retorno.msg2 = "SALDO DE DIARIAS ESGOTADAS!"


             let lr_retorno.confirma =  cts08g01("A","N",
                                                 lr_retorno.msg1,
                                                 lr_retorno.msg2,
                                                 lr_retorno.msg3,
                                                 lr_retorno.msg4)

             if lr_retorno.tipo_reserva = 1 then
                let lr_retorno.bloqueio = "S"
             end if

          else

          	 if g_documento.acao = "ALT"     and
          	    lr_param.avialgmtv_ant = 5   then

          	    #------------------------------------------------#
          	    # Mostra a Mensagem de Reversao por Particular
          	    #------------------------------------------------#

          	    let lr_retorno.msg2 = "DESEJA REVERTER ", lr_retorno.saldo using "<&&" , " DIA(S)"
          	    let lr_retorno.msg3 = "PELO MOTIVO 2? "

          	    let lr_retorno.confirma =  cts08g01("C","S",
          	                                        lr_retorno.msg1,
          	                                        lr_retorno.msg2,
          	                                        lr_retorno.msg3,
          	                                        lr_retorno.msg4)


          	    if lr_retorno.confirma = "S" and
          	    	 lr_param.aviprvent >  lr_retorno.saldo then


          	       let lr_retorno.qtd_fat = lr_param.aviprvent - lr_retorno.saldo

          	       let lr_retorno.msg2 = lr_retorno.qtd_fat using "<&&", " DIARIA(S) DEVERA(O) SER  "
          	       let lr_retorno.msg3 = "FATURADAS PELO USUARIO? "

          	       let lr_retorno.confirma =  cts08g01("C","S",
          	                                           lr_retorno.msg1,
          	                                           lr_retorno.msg2,
          	                                           lr_retorno.msg3,
          	                                           lr_retorno.msg4)

          	       if lr_retorno.confirma = "S" then
          	          let g_flag_msg = 1
          	       else

          	       	  let lr_retorno.msg2 = "DESEJA FATURAR A(S) ", lr_retorno.qtd_fat using "<&&" , " DIARIA(S)"
          	       	  let lr_retorno.msg3 = "PARA O CENTRO DE CUSTO? "

          	       	  let lr_retorno.confirma =  cts08g01("C","S",
          	       	                                      lr_retorno.msg1,
          	       	                                      lr_retorno.msg2,
          	       	                                      lr_retorno.msg3,
          	       	                                      lr_retorno.msg4)

          	       	  if lr_retorno.confirma = "S" then
          	       	     let lr_retorno.flag_custo = "S"
          	       	     let g_flag_msg = 2
          	          else
          	             let lr_retorno.bloqueio = "S"
          	          end if

          	       end if

          	    end if

             else

          	    #------------------------------------------------#
          	    # Mostra a Mensagem de Saldo
          	    #------------------------------------------------#

          	    let lr_retorno.msg2 = "MOTIVO 2 - PANE"
          	    let lr_retorno.msg3 = "SALDO DE DIARIAS DISPONIVEIS ", lr_retorno.saldo using "<&&"

          	    let lr_retorno.confirma =  cts08g01("A","N",
          	                                        lr_retorno.msg1,
          	                                        lr_retorno.msg2,
          	                                        lr_retorno.msg3,
          	                                        lr_retorno.msg4)

             end if
          end if

       else

       	  if g_documento.acao = "ALT"     and
       	     lr_param.avialgmtv_ant = 5   then

       	     #------------------------------------------------#
       	     # Mostra a Mensagem de Reversao por Particular
       	     #------------------------------------------------#

       	     let lr_retorno.msg2 = "DESEJA REVERTER ", lr_retorno.saldo using "<&&" , " DIA(S)"
       	     let lr_retorno.msg3 = "PELO MOTIVO 2? "

       	     let lr_retorno.confirma =  cts08g01("C","S",
       	                                         lr_retorno.msg1,
       	                                         lr_retorno.msg2,
       	                                         lr_retorno.msg3,
       	                                         lr_retorno.msg4)


       	     if lr_retorno.confirma = "S" and
       	     	 lr_param.aviprvent >  lr_retorno.saldo then


       	        let lr_retorno.qtd_fat = lr_param.aviprvent - lr_retorno.saldo

       	        let lr_retorno.msg2 = lr_retorno.qtd_fat using "<&&", " DIARIA(S) DEVERA(O) SER  "
       	        let lr_retorno.msg3 = "FATURADAS PELO USUARIO? "

       	        let lr_retorno.confirma =  cts08g01("C","S",
       	                                            lr_retorno.msg1,
       	                                            lr_retorno.msg2,
       	                                            lr_retorno.msg3,
       	                                            lr_retorno.msg4)

       	        if lr_retorno.confirma = "S" then
       	           let g_flag_msg = 1
       	        else

       	        	  let lr_retorno.msg2 = "DESEJA FATURAR A(S) ", lr_retorno.qtd_fat using "<&&" , " DIARIA(S)"
       	        	  let lr_retorno.msg3 = "PARA O CENTRO DE CUSTO? "

       	        	  let lr_retorno.confirma =  cts08g01("C","S",
       	        	                                      lr_retorno.msg1,
       	        	                                      lr_retorno.msg2,
       	        	                                      lr_retorno.msg3,
       	        	                                      lr_retorno.msg4)

       	        	  if lr_retorno.confirma = "S" then
       	        	     let lr_retorno.flag_custo = "S"
       	        	     let g_flag_msg = 2
       	           else
       	              let lr_retorno.bloqueio = "S"
       	           end if

       	        end if

       	     end if
       	  end if
       end if

 let lr_retorno.total = lr_retorno.saldo + lr_retorno.qtd_fat

 end if

 return lr_retorno.saldo       ,
        lr_retorno.bloqueio    ,
        lr_retorno.flag_custo  ,
        lr_retorno.qtd_fat     ,
        lr_retorno.total

end function

#---------------------------------------------------------
function cts15m00_recupera_msg()
#---------------------------------------------------------

define lr_retorno record
  msg1 char(50),
  msg2 char(50)
end record

initialize lr_retorno.* to null

    case g_flag_msg
       when 1
          let lr_retorno.msg1 = "FATURAR DIARIAS P/ PORTO SEGURO ATE O"
          let lr_retorno.msg2 = "LIMITE DO SALDO, DEMAIS PARA O USUARIO"
       when 2
       	  let lr_retorno.msg1 = "FATURAR DIARIAS P/ PORTO SEGURO ATE O"
       	  let lr_retorno.msg2 = "LIMITE DO SALDO"
    end case

    return lr_retorno.msg1,
           lr_retorno.msg2

end function

#---------------------------------------------------#
 function cts15m00_valida_motivo_clausula(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv  ,
  c24astcod    like datkassunto.c24astcod
end record

define lr_retorno record
  atende  char(01) ,
  motivos char(500)
end record

initialize lr_retorno.* to null

     case lr_param.c24astcod
     when "H10"
           call cts15m00_recupera_motivo_H10(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H11"
           call cts15m00_recupera_motivo_H11(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H12"
           call cts15m00_recupera_motivo_H12(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H13"
           call cts15m00_recupera_motivo_H13(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos


     end case

     return  lr_retorno.atende ,
             lr_retorno.motivos

end function

#---------------------------------------------------#
function cts15m00_popup_motivos(lr_param)
#---------------------------------------------------#

define lr_param record
       clscod1      like abbmclaus.clscod        ,
       clscod2      like abbmclaus.clscod        ,
       flag         char(01)                     ,
       avialgmtv    like datmavisrent.avialgmtv  ,
       c24astcod    like datkassunto.c24astcod
end record


define lr_retorno record
       motivos char(500)
      ,atende  char(01)
      ,opcao   like datmavisrent.avialgmtv
      ,cabec   char(60)
      ,qtd     integer
end record

initialize lr_retorno.* to null

   let lr_retorno.cabec = "Motivos"
   let lr_retorno.qtd   = 0

   call cts15m00_valida_motivo_clausula(lr_param.clscod1   ,
                                        lr_param.clscod2   ,
                                        lr_param.flag      ,
                                        lr_param.avialgmtv ,
                                        lr_param.c24astcod )
   returning lr_retorno.atende ,
             lr_retorno.motivos

   call ctx14g01_carro_extra(lr_retorno.cabec, lr_retorno.motivos)
   returning lr_retorno.opcao

   return lr_retorno.opcao

end function

#---------------------------------------------------#
 function cts15m00_recupera_motivo_H10(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if (g_documento.semdocto = " "    or
      g_documento.semdocto is null  or
      g_documento.semdocto = "N"  ) and
      g_documento.ramcod <> 114     then
     let lr_retorno.atende = "N"

     if lr_param.clscod1[1,2]  = "26" or
        lr_param.clscod2[1,2]  = "26" then
        let lr_retorno.atende  = "S"
        let lr_retorno.motivos = "1 - Sinistro"
        let lr_retorno.motivos = lr_retorno.motivos clipped,"|4 - Departamentos|5 - Particular"
     end if

     if lr_param.flag = "N" then

        if lr_param.clscod1 = "034" then

           if lr_param.avialgmtv = 03 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
              let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if


        if lr_param.clscod1 = "035" then

          if lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 21 or
             lr_param.avialgmtv = 23 or
             lr_param.avialgmtv = 24 then
             let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
             let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias|24 - Indenizacao Integral - 15 dias"

          if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if

        if lr_param.clscod1 = "033" then

          if lr_param.avialgmtv = 02 or
             lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 08 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 14 or
             lr_param.avialgmtv = 23 then
             let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
             let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

          if g_flag_azul = "S" then
             let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if

        if lr_param.clscod1 = "33R" then

          if lr_param.avialgmtv = 02 or
          	  lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 09 then
             let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
               let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

          if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if


        if lr_param.clscod1 = "044" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
              let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "44R" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
              let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "047" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "47R" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "046" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
              let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "46R" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
              let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if


        if lr_param.clscod1 = "048" then

           if lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod1 = "48R" then

           if lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

     else

     	if lr_param.clscod2 = "034" then

           if lr_param.avialgmtv = 01 or
              lr_param.avialgmtv = 03 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if


        if lr_param.clscod2 = "035" then

          if lr_param.avialgmtv = 01 or
          	  lr_param.avialgmtv = 04 or
          	  lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 21 or
             lr_param.avialgmtv = 23 or
             lr_param.avialgmtv = 24 then
             let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
               let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias|24 - Indenizacao Integral - 15 dias"

          if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if

        if lr_param.clscod2 = "033" then

          if lr_param.avialgmtv = 01 or
          	  lr_param.avialgmtv = 02 or
          	  lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 08 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 14 or
             lr_param.avialgmtv = 23 then
             let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
               let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

          if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if


        if lr_param.clscod2 = "33R" then

          if lr_param.avialgmtv = 01 or
          	  lr_param.avialgmtv = 02 or
             lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 09 then
               let lr_retorno.atende = "S"
          end if

          if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
               let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

          if g_flag_azul = "S" then
              let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
          end if

        end if

        if lr_param.clscod2 = "044" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 02 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "44R" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 02 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "047" then

           if lr_param.avialgmtv = 01 or
              lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "47R" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 02 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "046" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 02 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "46R" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 02 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 09 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|9 - Ind.Integral"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if


        if lr_param.clscod2 = "048" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

        if lr_param.clscod2 = "48R" then

           if lr_param.avialgmtv = 01 or
           	 lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

        end if

     end if
  else
     let lr_retorno.atende  = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if
  
 
  if lr_retorno.motivos is null or
     lr_retorno.motivos = " "   then
     
     let lr_retorno.atende = "S"                                   
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"   
  
  end if   
 

  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function

#---------------------------------------------------#
 function cts15m00_recupera_motivo_H12(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if g_documento.semdocto = " "   or
     g_documento.semdocto is null or
     g_documento.semdocto = "N"   then

     let lr_retorno.atende = "N"

     if lr_param.clscod1[1,2]  = "26" or
        lr_param.clscod2[1,2]  = "26" then
        let lr_retorno.atende  = "S"
        let lr_retorno.motivos = "1 - Sinistro"
        let lr_retorno.motivos = lr_retorno.motivos clipped,"|4 - Departamentos|5 - Particular"
     end if


     if lr_param.clscod1 = "034" then

        if lr_param.avialgmtv = 03 or
        	 lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

     end if


     if lr_param.clscod1 = "035" then

       if lr_param.avialgmtv = 04 or
       	  lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "033" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 13 or
          lr_param.avialgmtv = 14 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

     end if


     if lr_param.clscod1 = "33R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "044" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 13 or
          lr_param.avialgmtv = 14 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

     end if

     if lr_param.clscod1 = "44R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "047" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 13 or
          lr_param.avialgmtv = 14 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

     end if

     if lr_param.clscod1 = "47R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "046" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 13 or
          lr_param.avialgmtv = 14 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

     end if

     if lr_param.clscod1 = "46R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "048" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if


        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "48R" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

  else
     let lr_retorno.atende = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if
  
  if lr_retorno.motivos is null or
     lr_retorno.motivos = " "   then
     
     let lr_retorno.atende = "S"                                   
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"   
  
  end if   

  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function

#---------------------------------------------------#
 function cts15m00_recupera_motivo_H11(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if g_documento.semdocto = " "   or
     g_documento.semdocto is null or
  	 g_documento.semdocto = "N"   then

     let lr_retorno.atende = "N"

     if lr_param.clscod1[1,2]  = "26" or
        lr_param.clscod2[1,2]  = "26" then
        let lr_retorno.atende  = "S"
        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
     end if

     if lr_param.clscod1 = "034" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if


     if lr_param.clscod1 = "035" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 06 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|6 - Terceiro Segurado Porto"

     end if

     if lr_param.clscod1 = "033" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if


     if lr_param.clscod1 = "33R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "044" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "44R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "047" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "47R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "046" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "46R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "048" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if


        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "48R" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

  else
     let lr_retorno.atende  = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if
  
 
  if lr_retorno.motivos is null or
     lr_retorno.motivos = " "   then
     
     let lr_retorno.atende = "S"                                   
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"   
  
  end if   
  
 
  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function

#---------------------------------------------------#
 function cts15m00_recupera_motivo_H13(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if g_documento.semdocto = " "   or
     g_documento.semdocto is null or
     g_documento.semdocto = "N"   then

     let lr_retorno.atende = "N"

     if lr_param.clscod1[1,2]  = "26" or
        lr_param.clscod2[1,2]  = "26" then
        let lr_retorno.atende  = "S"
        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
     end if

     if lr_param.clscod1 = "034" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if


     if lr_param.clscod1 = "035" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 06 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|6 - Terceiro Segurado Porto"

     end if

     if lr_param.clscod1 = "033" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if


     if lr_param.clscod1 = "33R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "044" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "44R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "047" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "47R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "046" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

     if lr_param.clscod1 = "46R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "048" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if


        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

     if lr_param.clscod1 = "48R" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

  else
     let lr_retorno.atende  = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if
  
  
  if lr_retorno.motivos is null or
     lr_retorno.motivos = " "   then
     
     let lr_retorno.atende = "S"                                   
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"   
  
  end if   
  
 
  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function


#---------------------------------------------------#              
 function cts15m00_descricao_loja(lr_param)                  
#---------------------------------------------------#             
                                                                  
define lr_param record                                            
   lcvcod    like datklocadora.lcvcod    ,                   
   aviestcod like datmavisrent.aviestcod                                       
end record                                                        
                                                                  
define lr_retorno record                                          
  lcvextcod  like datkavislocal.lcvextcod ,                                              
  aviestnom  like datkavislocal.aviestnom                       
end record                                                        
                                                                  
initialize lr_retorno.* to null 
                                  
    #------------------------------------------------#        
    # Recupera os Dados da Loja              
    #------------------------------------------------#        
                                                              
    open ccts15m00047 using  lr_param.lcvcod   ,            
                             lr_param.aviestcod             
                                                              
    whenever error continue                                   
    fetch ccts15m00047 into lr_retorno.lcvextcod,           
                            lr_retorno.aviestnom           
                                
    whenever error stop  

    return lr_retorno.lcvextcod,
           lr_retorno.aviestnom


end function   

#---------------------------------------------------#    
 function cts15m00_grava_historico_premium(lr_param)              
#---------------------------------------------------# 
    
define lr_param record                          
    atdsrvnum like datmservico.atdsrvnum ,   
    atdsrvano like datmservico.atdsrvano           
end record                                        
    
    
define lr_retorno record                          
    erro    smallint                ,                  
    mens1   char(100)               , 
    mens2   char(100)               ,                  
    data    date                    ,             
    hora    datetime hour to minute ,
    ret     smallint                  
end record


 call cts40g03_data_hora_banco(2)                                            
 returning lr_retorno.data
         , lr_retorno.hora        
                                   


   if g_nova.delivery then
      let lr_retorno.mens1 = "SERVICO DELIVERY.: SIM"    
   else
      let lr_retorno.mens1 = "SERVICO DELIVERY.: NAO"
   end if         

   if g_nova.reversao = "S" then   
      let lr_retorno.mens2 = "POSSIVEL REVERSAO: SIM"  
   else                                      
      let lr_retorno.mens2 = "POSSIVEL REVERSAO: NAO"  
   end if        
                               
   call cts10g02_historico(lr_param.atdsrvnum            
                          ,lr_param.atdsrvano             
                          ,lr_retorno.data                
                          ,lr_retorno.hora                
                          ,g_issk.funmat                
                          ,lr_retorno.mens1             
                          ,lr_retorno.mens2                           
                          ,""                           
                          ,""                           
                          ,"")                          
   returning lr_retorno.ret  



end function 