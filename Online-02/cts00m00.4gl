#############################################################################
#Nome do Modulo: CTS00M00                                         Pedro     #
#                                                                  Marcelo  #
# Controle de Servicos (RADIO)                                     Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Incluir alerta para retorno marcado #
#                                       para servicos de R.E.               #
#---------------------------------------------------------------------------#
# 04/03/1999  PSI 7913-8   Wagner       Incluir acesso a tela de vidros     #
#---------------------------------------------------------------------------#
# 05/04/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 28/09/1999  PSI 9164-2   Wagner       Alteracao na mensagem de aviso para #
#                                       os servicos com "*".                #
#---------------------------------------------------------------------------#
# 06/12/1999  Pdm# 45994   Gilberto     Retirada do contador de servicos    #
#                                       nao liberados.                      #
#---------------------------------------------------------------------------#
# 19/01/2000  PSI 10203-2  Gilberto     Exibir tipo do caminhao para iden-  #
#                                       tificacao durante acionamento.      #
#---------------------------------------------------------------------------#
# 08/02/2000  PSI 10206-7  Wagner       Exibir Nivel prioridade do servico. #
#---------------------------------------------------------------------------#
# 09/06/2000  PSI 10866-9  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 23/10/2000  PSI 118168   Marcus       Incluir funcao INCONSISTENCIAS      #
#---------------------------------------------------------------------------#
# 16/01/2001  PSI 120278   Raji         Troca de ordem de acionamento p/    #
#                                       realizacao.                         #
#---------------------------------------------------------------------------#
# 24/01/2001  PSI 120187   Wagner       Incluir na tecla de funcao (F7) o   #
#                                       acesso ao modulo ENVIO MSG TELETRIM.#
#---------------------------------------------------------------------------#
# 17/07/2001  PSI 130427   Ruiz         Alterar a chamada da tela qdo opcao #
#                                       de vidros.                          #
#---------------------------------------------------------------------------#
# 02/08/2001  PSI 111538   Raji         Laudo de Servico JIT                #
#---------------------------------------------------------------------------#
# 29/08/2001  PSI 136220   Ruiz         Adaptacao de servico enviado via    #
#                                       internet.                           #
#---------------------------------------------------------------------------#
# 18/10/2002  PSI 162884   Paula        Incluir atend. ct24h RADIO RE
#---------------------------------------------------------------------------#
# 29/01/2003  PSI 159204   Wagner       Incluir Cadastros P.Socorro         #
#...........................................................................#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 17/11/2003 Gustavo, Meta     PSI179345  Alterar o form para eliminar a    #
#                              OSF028851  coluna "Prior" e colocar a coluna #
#                                         "Etapa" no lugar. Alterar tambem  #
#                                         o modulo com essa alteracao.      #
#---------------------------------------------------------------------------#
# 21/07/2004 James, Meta       PSI186414  Chamar funcao cts00m29_parametros #
#                              OSF 37940                                    #
#---------------------------------------------------------------------------#
# 28/07/2004 Evandro, Porto    PSI186414  Trocar funcao cts00m29_parametros #
#                              OSF 37940  por    funcao cts00m36_parametros #
# 04/08/2004 Marcio   Meta     PSI186414  Chamar tela parametros enquanto   #
#                                         nao sai com control-c.            #
# 15/02/2005 Vinicius, Meta    PSI190063  Exibir servicos a serem passados  #
#                                         aos prestadores                   #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 27/01/2005 Daniel, Meta      PSI190489  Exibir popup das funcoes do Radio #
#                                         Implementar tipo pesquisa 'tpa' e #
#                                         'grp'                             #
#                                         Chamar a cts00m37 e cts00m01      #
#---------------------------------------------------------------------------#
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 08/04/2005 Adriana, Meta     PSI189790  Com demanda, despreza servicos sem#
#                                         coordenadas.Desprezar laudo       #
#                                         multiplo. Obter codigo da natureza#
#                                         Obter descricao e grupo da naturez#
#---------------------------------------------------------------------------#
# 17/05/2005 Julianna,Meta    PSI191108   Implementar o codigo da via       #
# ---------- ----------------- ---------- ----------------------------------#
# 21/06/2005 Alinne, Meta      PSI191990  Acionamento de servicos por Endere#
#                                         co Indexado                       #
#---------------------------------------------------------------------------#
# 15/09/2005 Andrei, Meta      AS87408    incluir chamada das funcoes       #
#                                         cts01g01_setexplain() e cts01g01_ #
#                                         setetapa()                        #
# 07/11/2005 Ligia Mattge     PSI195138   Exibir motivo n acionamento       #
#---------------------------------------------------------------------------#
# 25/05/2006 Priscila Staingel PSI198714  Receber codigo veiculo como param.#
#                                         e verificar se tipo assistencia   #
#                                         do servico � atebdido pelo socorr #
#---------------------------------------------------------------------------#
# 07/12/2006 Priscila Staingel  PSI205206 Incluir campo empresa na tela     #
# 14/02/2007 Ligia Mattge                  Chamar cta00m08_ver_contingencia #
#---------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- ------    ----------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32             #
# 10/10/2007 Ligia Mattge  PSI211982 Nao exibir srv nao emergenciais da PortoSeg
# 14/11/2008 Ligia Mattge  PSI232700 Exibir os servicos de conveniencia
# 26/01/2009 Sergio Burini   PSI 235790 Tela Radio Cart�o Porto Seguro        #
# 28/01/2009 Adriano Santos  PSI 235849 Considerar tipo de servi�o SINISTRO RE#
#-----------------------------------------------------------------------------#
# 26/05/2009 Kevellin        PSI 241733 Exibi��o srv Auto e RE-Estado Alerta  #
# 13/08/2009 Sergio Burini   PSI 244236 Inclus�o do Sub-Dairro                #
# 02/03/2010 Adriano Santos  PSI 252891 Inclusao do padrao idx 4 e 5          #
# 20/04/2010 Raji Jahchan    Core��o    Inibir servi�os de cart�o fora do     #
#                                              hor�rio comercial              #
#-----------------------------------------------------------------------------#
# 25/07/2010 Danilo Sgrott   PSI257664    #Tratamento da tela de registro de  #
#                                          atendimento central opera��es      #
#                                          ws.pesq="reg"                      #
#-----------------------------------------------------------------------------#
# 07/02/2013 Sergio Burini   PSI-2013-00435/EV Listar servi�os pr�ximos a     #
#                                              endere�o                       #
#-----------------------------------------------------------------------------#
# 09/04/2014 CDS Egeu     PSI-2014-02085   Situa��o Local de Ocorr�ncia       #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_cts00m00_prep    smallint,
        m_hora_inicial     char(005),
        m_hora_final       char(005),
        m_hora_acn         char(005),
        m_filtro_hr        smallint,
        m_filtro_qtdsrv    smallint,
        m_filtro_ciaempcod char(30),
        ws_exbflgcrt       smallint

#-----------------------------#
 function cts00m00_prepare()
#-----------------------------#

define l_sql_stmt  char(1000)



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql_stmt  =  null

 let l_sql_stmt = " select gpsacngrpcod  "
                 ,"   from datkmpacid "
                 ,"  where cidnom = ? "
                 ,"    and ufdcod = ? "

 prepare p_cts00m00_001 from l_sql_stmt
 declare c_cts00m00_001 cursor for p_cts00m00_001

 let l_sql_stmt = " select lclltt,      "
                 ,"        lcllgt,      "
                 ,"        c24lclpdrcod, "
                 ,"        emeviacod "
                 ,"   from datmlcl      "
                 ,"  where atdsrvnum  = ? "
                 ,"    and atdsrvano  = ? "
                 ,"    and c24endtip  = 1 "

 prepare p_cts00m00_002 from l_sql_stmt
 declare c_cts00m00_002 cursor for p_cts00m00_002
 ### Fim

 let l_sql_stmt = " select grlinf  "
                 ,"   from igbkgeral "
                 ,"  where mducod = ? "
                 ,"    and grlchv = ? "

 prepare p_cts00m00_003 from l_sql_stmt
 declare c_cts00m00_003 cursor for p_cts00m00_003

 let l_sql_stmt =  " update igbkgeral  "
                  ,"    set grlinf = ? "
                  ,"  where mducod = ? "
                  ,"    and grlchv = ? "

 prepare p_cts00m00_004 from l_sql_stmt

 let l_sql_stmt = " select grlchv, grlinf from igbkgeral "
                 ,"  where mducod = 'C24'"
                 ,"    and grlchv matches 'RADIO-DEM*'"
                 ,"  order by grlchv"

 prepare p_cts00m00_005 from l_sql_stmt
 declare c_cts00m00_004 cursor for p_cts00m00_005
 ### Fim

 let l_sql_stmt = " select c24pbmcod, c24pbmdes "
                 ,"   from datrsrvpbm "
                 ,"  where atdsrvnum = ? "
                 ,"    and atdsrvano = ? "
                 ,"    and c24pbminforg = 1 "
                 ,"    and c24pbmseq = 1 "

 prepare p_cts00m00_006 from l_sql_stmt
 declare c_cts00m00_005 cursor for p_cts00m00_006

 ### Final PSI179345 - Gustavo

  #--------------------------------------------------------------------
  # Cursor para obter descricao do TIPO DE SERVICO / ASSISTENCIA
  #--------------------------------------------------------------------
  let l_sql_stmt = "select srvtipabvdes",
                    "  from datksrvtip  ",
                    " where atdsrvorg = ?  "
  prepare p_cts00m00_007 from l_sql_stmt
  declare c_cts00m00_006 cursor for p_cts00m00_007

  let l_sql_stmt = "select asitipabvdes ",
                    "  from datkasitip   ",
                    " where asitipcod = ?"
  prepare p_cts00m00_008 from l_sql_stmt
  declare c_cts00m00_007 cursor for p_cts00m00_008

  #--------------------------------------------------------------------
  # Cursor para verificar se veiculo e' caminhao
  #--------------------------------------------------------------------
  #let l_sql_stmt = "select vclcamtip",
  #                  "  from datmservicocmp",
  #                  " where atdsrvnum = ? and ",
  #                  "       atdsrvano = ?     "
  #prepare pcts00m00009 from l_sql_stmt
  #declare c_cts00m00_008 cursor for pcts00m00009

  #--------------------------------------------------------------------
  # Cursor para obter a HORA de algum cancelamento de VISTORIA
  #--------------------------------------------------------------------
  let l_sql_stmt = "select atdhor            ",
                    "  from datmvstcanc       ",
                    " where atdsrvnum = ? and ",
                    "       atdsrvano = ?     "

  prepare p_cts00m00_009 from l_sql_stmt
  declare c_cts00m00_008 cursor for p_cts00m00_009

  #--------------------------------------------------------------------
  # Cursor para obter a SUCURSAL da VISTORIA
  #--------------------------------------------------------------------
  let l_sql_stmt = "select succod            ",
                    "  from datmvistoria      ",
                    " where atdsrvnum = ? and ",
                    "       atdsrvano = ?     "
  prepare p_cts00m00_010 from l_sql_stmt
  declare c_cts00m00_009 cursor for p_cts00m00_010

  #--------------------------------------------------------------------
  # Cursor para obter a HORA de alguma ligacao de ALTERACAO
  #--------------------------------------------------------------------
  let l_sql_stmt = "select lighorinc, c24astcod ",
                    "  from datmligacao          ",
                    " where atdsrvnum = ?        ",
                    "   and atdsrvano = ?        ",
                    "   and c24astcod in ('ALT','CAN','REC','RET','JIT')"

  prepare p_cts00m00_011 from l_sql_stmt
  declare c_cts00m00_010 cursor for p_cts00m00_011

  #--------------------------------------------------------------------
  # Cursor para obter a ultima situacao da flag de EXIBICAO DE VISTORIA
  #--------------------------------------------------------------------
  let l_sql_stmt = "select grlinf from igbkgeral",
                    " where mducod = 'C24'   and ",
                    "       grlchv = ? "
  prepare p_cts00m00_012 from l_sql_stmt
  declare c_cts00m00_011 cursor for p_cts00m00_012

  #--------------------------------------------------------------------
  # Cursores para obter a etapa
  #--------------------------------------------------------------------
  let l_sql_stmt = "select max(atdsrvseq)",
                    "  from datmsrvacp    ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? "
  prepare p_cts00m00_013 from l_sql_stmt
  declare c_cts00m00_012 cursor for p_cts00m00_013

  let l_sql_stmt = "select datketapa.atdetpdes ",
                    "  from datketapa   ",
                    " where datketapa.atdetpcod = ? "
  prepare p_cts00m00_014 from l_sql_stmt
  declare c_cts00m00_013 cursor for p_cts00m00_014

  #--------------------------------------------------------------------
  # Cursor para obter se e retorno
  #--------------------------------------------------------------------
  let l_sql_stmt = "select c24astcod ",
                     " from datmligacao ",
                    " where atdsrvnum  = ? ",
                      " and atdsrvano  = ? "
                      ##" and lignum    <> 0 "
  prepare p_cts00m00_015 from l_sql_stmt
  declare c_cts00m00_014 cursor for p_cts00m00_015

  #--------------------------------------------------------------------
  # Prepare para 'LOCAR' o servico enquanto esta' sendo acionado
  #--------------------------------------------------------------------
  let l_sql_stmt = "update datmservico   ",
                    "   set c24opemat = ? ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? "
  prepare p_cts00m00_016  from l_sql_stmt

  #--------------------------------------------------------------------
  # Prepare para 'LIGAR/DESLIGAR' a exibicao de vistorias na tela
  #--------------------------------------------------------------------
  let l_sql_stmt = "update igbkgeral set ",
                    "(grlinf,atlult)=(?,?)",
                    " where mducod = 'C24'",
                    "   and grlchv =  ?   "
  prepare p_cts00m00_017 from l_sql_stmt

  #--------------------------------------------------------------------
  # Prepare para 'LIBERAR' o servico caso nao tenha sido concluido
  #--------------------------------------------------------------------
  let l_sql_stmt = "update datmservico    ",
                    "   set c24opemat = ?  ",
                    " where atdsrvnum = ?  ",
                    "   and atdsrvano = ?  ",
                    "   and atdfnlflg = 'N'"
  prepare p_cts00m00_018 from l_sql_stmt


  #--------------------------------------------------------------------
  # Cursor para obter a DESCRICAO DA PRIORIDADE DO SERVICO
  #--------------------------------------------------------------------
  let l_sql_stmt = " select cpocod, cpodes[1,5]    ",
                   " from iddkdominio              ",
                   " where cponom = 'atdprinvlcod' "
  prepare p_cts00m00_019 from l_sql_stmt
  declare c_cts00m00_015 cursor for p_cts00m00_019


  let l_sql_stmt = " select refatdsrvnum, refatdsrvano ",
                   " from datmsrvjit ",
                   " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

  prepare p_cts00m00_020 from l_sql_stmt
  declare c_cts00m00_016 cursor for p_cts00m00_020

  let l_sql_stmt = " select sinvstnum  from datmpedvist ",
                   " where sinvstnum = ? ",
                   " and sinvstano = ? "

  prepare p_cts00m00_021 from l_sql_stmt
  declare c_cts00m00_017 cursor for p_cts00m00_021

  let l_sql_stmt = " select max(atdetpcod) ",
                   " from datmsrvintseqult ",
                   " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

  prepare p_cts00m00_022 from l_sql_stmt
  declare c_cts00m00_018 cursor for p_cts00m00_022

  let l_sql_stmt = " select atdfnlflg, ",
                          " c24opemat ",
                     " from datmservico ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "

  prepare p_cts00m00_023 from l_sql_stmt
  declare c_cts00m00_019 cursor for p_cts00m00_023

  let l_sql_stmt = " select ciaempcod ",
                     " from datrvclemp ",
                    " where socvclcod = ? "

  prepare p_cts00m00_024 from l_sql_stmt
  declare c_cts00m00_020 cursor for p_cts00m00_024

  #--------------------------------------------------------------------
  # Cursor para obter o c�digo da cidade do servi�o
  #--------------------------------------------------------------------
  let l_sql_stmt = "select g.cidcod ",
                   "  from glakcid g",
                   " where g.ufdcod = ? ",
                   "   and g.cidnom = ? "
  prepare p_cts00m00_025 from l_sql_stmt
  declare c_cts00m00_021 cursor for p_cts00m00_025

  #--------------------------------------------------------------------
  # Cursor que verifica se cidade est� em Estado de Aten��o
  #--------------------------------------------------------------------
  let l_sql_stmt = "select asitipcod, socntzgrpcod, vcltipcod ",
                   "  from datrcidsedatn ",
                   " where (cidsedcod = ? ",
                   "    or cidcod    = ?) ",
                   "   and (asitipcod != 0 or ",
                   "        socntzgrpcod != 0 or ",
                   "        vcltipcod != 0) "
  prepare p_cts00m00_026 from l_sql_stmt
  declare c_cts00m00_022 cursor for p_cts00m00_026

  #--------------------------------------------------------------------
  # Cursor que verifica se cidade est� em Estado de Aten��o
  #--------------------------------------------------------------------
  let l_sql_stmt = "select atnflg ",
                   "  from datrcidsed ",
                   " where cidcod    = ? "
  prepare p_cts00m00_027 from l_sql_stmt
  declare c_cts00m00_023 cursor for p_cts00m00_027
  let l_sql_stmt = " select 1    ",
                   " from iddkdominio              ",
                   " where cponom = 'VSLSRVLSTATD' ",
                   "   and cpodes = ? "
  prepare pcts00m00036 from l_sql_stmt
  declare ccts00m00036 cursor for pcts00m00036

  # ACESSO A TELA LISTAR SERVICO
  let l_sql_stmt = " select 1    ",
                   " from iddkdominio              ",
                   " where cponom = 'PSOSRVLSTEXB' ",
                   "   and cpodes = ? "
  prepare pcts00m00037 from l_sql_stmt
  declare ccts00m00037 cursor for pcts00m00037

#Inicio - Situa��o local de ocorr�ncia
 let l_sql_stmt = " select count(*)                ",
                  "   from iddkdominio             ",
                  "  where cponom = 'SRVATDLCLRSC' ",
                  "    and cpocod = ?  "
  prepare pcts00m00038 from l_sql_stmt
  declare ccts00m00038 cursor for pcts00m00038
#Fim - Situa��o local de ocorr�ncia


 # Inicio - Carga da contingencia
 let l_sql_stmt = " select cpodes                       "
                 ,"       ,atlult                       "
                 ,"  from datkdominio                   "
                 ," where cponom = 'carga_contingencia' "
 prepare pcts00m00039 from l_sql_stmt
 declare ccts00m00039 cursor for pcts00m00039
 let l_sql_stmt = " select funnom     "
                 ,"   from isskfunc   "
                 ,"  where empcod = ? "
                 ,"    and funmat = ? "
 prepare pcts00m00040 from l_sql_stmt
 declare ccts00m00040 cursor for pcts00m00040
 # Fim - Carga contingencia

 # ACESSO AO MENU RADIO e RADIO_RE
 let l_sql_stmt = " select 1 ",
                  " from datkdominio ",
                  " where cponom in ('ACESSORADIO','ACESSORADIO1','ACESSORADIO2') ",
                  "   and cpodes = ? "
 prepare pcts00m00041 from l_sql_stmt
 declare ccts00m00041 cursor for pcts00m00041

 let m_cts00m00_prep = true

 end function

#-----------------------------------------------------------
 function cts00m00(param)
#-----------------------------------------------------------

 define l_cod_filtro      smallint
 define l_ufdcod          like glakest.ufdcod
 define l_filtro_resumo   char(1)
 define l_cidnom          like glakcid.cidnom
 define l_flag_ac         smallint
 define l_aciona          smallint
 define l_flag_gps        smallint,
        l_sistema         char(04),
        l_aa_parado       smallint,
        l_motivo          char(40),
        l_aa_str          char(10),
        l_aa_data         date,
        l_aa_hora         datetime hour to minute,
        l_aa_interval     interval hour(6) to minute,
        l_aa_espmaxprg    interval hour(6) to minute,
        l_aa_espmaximd    interval hour(6) to minute

 define param        record
    atdsrvorg        like datmservico.atdsrvorg
   ,ciaempcod        like datmservico.ciaempcod # PSI 235970
   ,tipo_demanda     char(15)
   ,lclltt           like datmfrtpos.lclltt
   ,lcllgt           like datmfrtpos.lcllgt
   ,cidnom           like datmfrtpos.cidnom
   ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod
   ,srrcoddig        like dattfrotalocal.srrcoddig
   ,socvclcod        like dattfrotalocal.socvclcod
 end record

 define l_flag       smallint

 define lr_cts00m36    record
        data_inicial   date,
        data_final     date,
        atdprscod      like datmservico.atdprscod,
        atdsrvorg      like datmservico.atdsrvorg,
        nome           like datmservico.nom,
        vcllicnum      like datmservico.vcllicnum,
        in_empresas    char(30)
 end record

## PSI 186414 - Final

 define lr_cts00m01    record
        par_pesq       char(03),
        data_inicial   date,
        data_final     date,
        atdprscod      like datmservico.atdprscod,
        atdsrvorg      like datmservico.atdsrvorg,
        nome           like datmservico.nom,
        vcllicnum      like datmservico.vcllicnum,
        codigo_filtro  smallint,
        ufdcod         like glakest.ufdcod,
        filtro_resumo  char(1),
        cidnom         like glakcid.cidnom,
        flag_ac        smallint,
        in_empresas    char(30)
 end record

 define a_cts00m00   array[600] of record
    servico          char (13),
    atdlibdat        char (05),
    atdlibhor        like datmservico.atdlibhor,
    atddatprg        char (05),
    atdhorprg        like datmservico.atdhorprg,
    atdhorpvt        like datmservico.atdhorpvt,
    espera           char (06),
    asitipabvdes     like datkasitip.asitipabvdes,
    atdetpdes        like datketapa.atdetpdes,
    dstqtd           dec  (8,4),   ### PSI179345
    srvtipabvdes     char(13),
    historico        char (64),
    empresa          char (06),              #PSI 205206
    problema         char (34),
    emeviades        char (23), #na tela deve ter 23 por causa do espaco em branco caso a prioridade seja alta
    sindex           char (7),
    urgente          char(05),
    rsdflg           char(09)
 end record

 define a_motivo    array[600] of  like datmservico.acnnaomtv
 define a_atdfnlflg array[600] of  like datmservico.atdfnlflg

 define al_cts00m00  array[600] of record
    servico          char (13),
    atdlibdat        char (05),
    atdlibhor        like datmservico.atdlibhor,
    atddatprg        char (05),
    atdhorprg        like datmservico.atdhorprg,
    atdhorpvt        like datmservico.atdhorpvt,
    espera           char (06),
    asitipabvdes     like datkasitip.asitipabvdes,
    atdetpdes        like datketapa.atdetpdes,
    dstqtd           dec  (8,4),
    srvtipabvdes     char(13),
    historico        char (64),
    empresa          char (06),              #PSI 205206
    problema         char (34),
    emeviades        char (23), #na tela deve ter 23 por causa do espaco em branco caso a prioridade seja alta
    sindex           char (7),
    urgente          char(05),
    rsdflg           char(09)
 end record
 ### Final PSI179345 - Gustavo

 define w_cts00m00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    lclltt           like datmlcl.lclltt,
    lcllgt           like datmlcl.lcllgt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    celteldddcod     like datmlcl.celteldddcod,
    celtelnum        like datmlcl.celtelnum,
    endcmp           like datmlcl.endcmp,
    sqlcode          integer,
    emeviacod        like datkemevia.emeviacod
 end record

 define ws           record
    atdlibhor        like datmservico.atdlibhor,
    atdhorprg        like datmservico.atdhorprg,
    atdhorpvt        like datmservico.atdhorpvt,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdsrvorg        like datmservico.atdsrvorg,
    asitipcod        like datmservico.asitipcod,
    atdprscod        like datmservico.atdprscod,
    atdvclsgl        like datkveiculo.atdvclsgl,
    srrcoddig        like datmservico.srrcoddig,
    ligastcod        like datmligacao.c24astcod,
    c24opemat        like datmservico.c24opemat,
    c24openom        like isskfunc.funnom,
    atdvcltip        like datmservico.atdvcltip,
    succod           like datmvistoria.succod,
    atdtrxsit        like datmtrxfila.atdtrxsit,
    faxsubcod        like datmfax.faxsubcod,
    faxenvsit        like datmfax.faxenvsit,
    atlult           like igbkgeral.atlult,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atddstcidnom     like datmassistpassag.atddstcidnom,
    atddstufdcod     like datmassistpassag.atddstufdcod,
    relogio          datetime hour to second,
    horaatu          datetime hour to minute,
    horaprg          datetime hour to minute,
    cabec            char (66),
    lockk            char (01),
    confirma         char (01),
    atdlibdat        char (10),
    atddatprg        char (10),
    lighorinc        char (05),
    historico        char (24),
    tempo             char (08),
    pesq             char (03),
    remqtd           smallint,
    assqtd           smallint,
    prgqtd           smallint,
    vstqtd           smallint,
    resqtd           smallint,
    crtqtd           smallint,
    sprqtd           smallint,
    jitqtd           smallint,
    rebasqtd         smallint,
    rebcaqtd         smallint,
    reretqtd         smallint,
    resinqtd         smallint,
    diasem           smallint,
    atdprinvlcod     like datmservico.atdprinvlcod,
    atdprinvldes     char (05),
    socvclcod        like datkveiculo.socvclcod,
    flag_cts00m03    dec  (01,0),
    dataprog         like datmservico.atddatprg,
    horaprog         like datmservico.atdhorprg,
    socntzcod        like datksocntz.socntzcod,
    socntzdes        like datksocntz.socntzdes,
    socntzgrpcod     like datksocntz.socntzgrpcod,
    refatdsrvnum     like datmsrvjit.refatdsrvnum,
    refatdsrvano     like datmsrvjit.refatdsrvano,
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetpcodint     like datmsrvintseqult.atdetpcod,
    ciaempcod        like datmservico.ciaempcod,       #PSI 205206
    srvprsacnhordat  like datmservico.srvprsacnhordat,
    atdrsdflg        like datmservico.atdrsdflg
 end record

 define ws2          array[4] of record
    des              char (05)
 end record

 define msg     record
        linha1  char(1000),
        linha2  char(1000),
        linha3  char(1000),
        linha4  char(2000),
        linha5  char(5000),
        linha6  char(5000)
 end record
 define ws_igbkchave char(20)
 define ws_pricod    smallint
 define ws_exbflg    smallint
 define ws_exbflgjit smallint
 define ws_separa    smallint
 define ws_exbflgaten smallint
 define ws_exbflgre  smallint
 define ws_privez    smallint


 define arr_aux      smallint
 define l_arr1       smallint ### PSI179345
 define l_arr2       smallint ### PSI179345
 define l_arr3       smallint ### PSI179345
 define scr_aux      smallint

 define aux_ano4     char(04)

 define lr_atd       record
    atdlibhor        like datmservico.atdlibhor,
    atdlibdat        like datmservico.atdlibdat,
    acnsttflg        like datmservico.acnsttflg,
    atdfnlflg        like datmservico.atdfnlflg
 end record

 #define lr_cts00m00  record
 #   lclltt           like datmlcl.lclltt
 #  ,lcllgt           like datmlcl.lcllgt
 #  ,c24lclpdrcod     like datmlcl.c24lclpdrcod
 #end record

 define  lr_ctc17m02 record
                     resultado   smallint
                    ,mensagem    char(030)
                    ,emeviades   like datkemevia.emeviades
                    ,emeviapri   like datkemevia.emeviapri
                     end record

 define lr_cts10g06 record
        c24astcod like datmligacao.c24astcod
       ,c24funmat like datmligacao.c24funmat
       ,c24empcod like datmligacao.c24empcod
 end record

 define  l_opcao     smallint
        ,l_descricao char(20)
        ,l_data      datetime year to second
        ,l_aux       char(03)
        ,l_alt       smallint
        ,l_grlinf    like igbkgeral.grlinf
        ,l_grlchv    like igbkgeral.grlchv
        ,l_achou     smallint
        ,l_string    char(80)
        ,l_len       smallint
        ,l_aux2      char(06)
        ,l_resposta  char(01)
        ,l_swap1     char(15)
        ,l_swap2     char(15)
        ,l_auxn      dec (9,0)
        ,l_emp       integer
        ,l_primeiro  smallint
        ,l_hora      datetime hour to second
        ,org         like datmservico.atdsrvorg
        ,tot         integer
        ,l_c24astcod like datrempgrp.c24astcod
        ,l_socntzcod like datmsrvre.socntzcod
        ,l_tmpacn    char(10)
        ,l_atddatprg like datmservico.atddatprg
        ,l_atdhorprg like datmservico.atdhorprg
        ,l_horacn    datetime year to second
        ,l_acntntlmtqtd like datkatmacnprt.acntntlmtqtd
        ,l_netacnflg    like datkatmacnprt.netacnflg
        ,l_atmacnprtcod like datkatmacnprt.atmacnprtcod
        ,l_datstr       char(20)
        ,l_atmacnatchorqtd like datrgrpntz.atmacnatchorqtd
        ,l_fglradre     smallint
        #,l_emeviacod like datkemevia.emeviacod
        ,l_cidcod like glakcid.cidcod
        ,l_atnflg like datrcidsed.atnflg
        ,l_count_auto   smallint  #Situa��o local de ocorr�ncia
        ,l_flag_auto    char(01)  #Situa��o local de ocorr�ncia


 define l_c24pbmcod  like datrsrvpbm.c24pbmcod
       ,l_c24pbmdes  like datrsrvpbm.c24pbmdes
       ,l_espcod     like datmsrvre.espcod
       ,l_sql_stmt   char(2000)
       ,l_stmt       char(200)
       ,l_sql        char(600)
       ,l_atdetpcod  like datmsrvacp.atdetpcod

 define l_resultado  smallint,
        l_mensagem   char(30),
        l_atdsrvnum_original like datmservico.atdsrvnum ,
        l_atdsrvano_original like datmservico.atdsrvano,
        l_contingencia smallint,
        l_exibe_srv    smallint,
        l_flagsrv      smallint,
        l_comando      char(500),
        l_char         char(005),
        l_rodape       char(100)


 define l_msg char(80),
        l_acninihor smallint,
        l_acnfimhor smallint

 define acesso char(5) #PSI257664 - Recebe permissao de usuario

 define  w_pf1   integer
 # Carga contingencia - Humberto Santos
define lr_retorno record
       flag       like datkdominio.cpodes,
       atldat     char (10),
       atlhor     char (05),
       atlfunnom  like isskfunc.funnom
end record
define l_confirma smallint     
define l_naoprocessado integer

let l_confirma = 0
initialize msg.* to null
initialize l_naoprocessado to null
# Carga contingencia

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_comando     = null
        let     l_cod_filtro  =  null
        let     l_ufdcod  =  null
        let     l_filtro_resumo  =  null
        let     l_cidnom  =  null
        let     l_flag_ac  =  null
        let     l_aciona  =  null
        let     l_flag_gps  =  null
        let     l_sistema  =  null
        let     l_flag  =  null
        let     ws_igbkchave  =  null
        let     ws_pricod  =  null
        let     ws_exbflg  =  null
        let     ws_exbflgjit  =  null
        let     ws_separa = null
        let     ws_exbflgaten  =  null
        let     ws_exbflgre  =  null
        let     ws_exbflgcrt = null
        let     ws_privez  =  null
        let     arr_aux  =  null
        let     l_arr1  =  null
        let     l_arr2  =  null
        let     l_arr3  =  null
        let     scr_aux  =  null
        let     aux_ano4  =  null
        let     l_opcao  =  null
        let     l_descricao  =  null
        let     l_aux  =  null
        let     l_alt  =  null
        let     l_grlinf  =  null
        let     l_grlchv  =  null
        let     l_achou  =  null
        let     l_string  =  null
        let     l_len  =  null
        let     l_aux2  =  null
        let     l_resposta  =  null
        let     l_swap1  =  null
        let     l_swap2  =  null
        let     l_auxn  =  null
        let     l_hora  =  null
        let     org  =  null
        let     tot  =  null
        let     l_c24pbmcod  =  null
        let     l_c24pbmdes  =  null
        let     l_espcod  =  null
        let     l_sql_stmt  =  null
        let     l_stmt  =  null
        let     l_sql  =  null
        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_atdsrvnum_original  =  null
        let     l_atdsrvano_original  =  null
        let     l_msg  =  null
        let     l_atdetpcod = null
        let     l_emp = null
        let     l_primeiro = null
        let     l_contingencia = null
        let     l_exibe_srv    = false
        let     l_cidcod = null
        let     l_atnflg = null
        let     l_count_auto = null #Situa��o local de ocorr�ncia
        let     l_flag_auto    = null #Situa��o local de ocorr�ncia


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  600
                initialize  a_cts00m00[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  600
                initialize  al_cts00m00[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  4
                initialize  ws2[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  600
                initialize  a_motivo[w_pf1]    to  null
        end     for

        for     w_pf1  =  1  to  600
                initialize  a_atdfnlflg[w_pf1]    to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_cts10g06.*  to  null
        initialize  lr_cts00m36.*  to  null

        initialize  lr_cts00m01.*  to  null

        initialize  w_cts00m00.*  to  null

        initialize  ws.*  to  null

        initialize  lr_atd.*  to  null

        initialize  lr_ctc17m02.*  to  null
        initialize lr_retorno.* to null

 call cts01g01_setexplain(g_issk.empcod, g_issk.funmat, 1)

 if g_setexplain = 1 then
    call cts01g01_setetapa("cts00m00 - Tela do Radio")
 end if

 let g_documento.atdsrvorg = param.atdsrvorg
 call cta00m08_ver_contingencia(1)
      returning l_contingencia

 if l_contingencia then
     return
 end if

 call cts14g02("N","cts00m00")


 # TEMPO QUE O SERVICO DEMORA PARA VOLTAR PARA A TELA DO RADIO
 # Obtem espera maxima para servico programados
 select grlinf into l_aa_espmaxprg
   from datkgeral
  where grlchv = "PSOESPMAXPRG"
 if sqlca.sqlcode <> 0 then
    let l_aa_espmaxprg = "000:20"  # SRV PROGRAMADO
 end if

 # Obtem espera maxima para servico imediatos
 select grlinf into l_aa_espmaximd
   from datkgeral
  where grlchv = "PSOESPMAXIMD"
 if sqlca.sqlcode <> 0 then
    let l_aa_espmaximd = "000:05"  # SRV IMEDIATO
 end if

 let ws_privez = true
 let l_sistema = null

 if m_cts00m00_prep is null or
    m_cts00m00_prep <> true then
    call cts00m00_prepare()
 end if

 let int_flag = false

  let ws_igbkchave = 'RADIO-VP'
  open  c_cts00m00_011 using ws_igbkchave
  fetch c_cts00m00_011 into  ws_exbflg

  if sqlca.sqlcode = NOTFOUND  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do parametro de exibicao de V.P. AVISE A INFORMATICA!"
     let ws_exbflg = false
  end if

  close c_cts00m00_011

  let ws_igbkchave = 'RADIO-RE'
  open  c_cts00m00_011 using ws_igbkchave
  fetch c_cts00m00_011 into  ws_exbflgre

  if sqlca.sqlcode = NOTFOUND  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do parametro de exibicao de RADIO RE. AVISE A INFORMATICA!"
     let ws_exbflgre = false
  end if

  close c_cts00m00_011

  let ws_igbkchave = 'RADIO-JIT'
  open  c_cts00m00_011 using ws_igbkchave
  fetch c_cts00m00_011 into  ws_exbflgjit

  if sqlca.sqlcode = NOTFOUND  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do parametro de exibicao de JIT. AVISE A INFORMATICA!"
     let ws_exbflgjit = false
  end if

  close c_cts00m00_011

  #PSI 241733
  #ESTADO DE ATEN��O
  let ws_exbflgaten = false

  # PSI 235970 - Tela Cartao Porto Seguro
  let ws_igbkchave = 'RADIO-CARTAO'
  open  c_cts00m00_011 using ws_igbkchave
  fetch c_cts00m00_011 into  ws_exbflgcrt
  if sqlca.sqlcode = NOTFOUND  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do parametro de exibicao de CARTAO. AVISE A INFORMATICA!"
     let ws_exbflgcrt = false
  end if

  close c_cts00m00_011

  #--------------------------------------------------------------------
  # Cursor para obter a DESCRICAO DA PRIORIDADE DO SERVICO
  #--------------------------------------------------------------------

  #open c_cts00m00_015
  #foreach c_cts00m00_015 into ws.atdprinvlcod, ws.atdprinvldes
  #   if ws.atdprinvlcod = 2 then
  #      let ws.atdprinvldes[5,5] = "."
  #   end if
  #   let ws_pricod = ws.atdprinvlcod
  #   let ws2[ws_pricod].des = ws.atdprinvldes
  #end foreach

  if param.tipo_demanda is not null then
     if param.lclltt is null or
        param.lcllgt is null or
        param.cidnom is null then
        error 'Faltam parametros para o acionamento por demanda' sleep 1
        return
     end if
  end if

  open window cts00m00 at 03,02 with form "cts00m00"
              attribute(form line 1)

   let m_hora_inicial     = null
   let m_hora_final       = null
   let m_filtro_qtdsrv    = null
   let m_filtro_ciaempcod = null

   if param.ciaempcod is null then
      call cts00m00_informa_filtro()
           returning m_hora_inicial, m_hora_final, m_filtro_qtdsrv, m_filtro_ciaempcod
   else
      call cts00m00_todo_dia()
           returning m_hora_inicial,
                     m_hora_final
      let m_filtro_qtdsrv = 500
      let m_filtro_ciaempcod = param.ciaempcod
      let ws_exbflgcrt = true
   end if
 #--------------------------------------------------------------------
 # Exibe servicos a serem passados para os prestadores
 #--------------------------------------------------------------------
 while true

    if g_setexplain = 1 then
       call cts01g01_setetapa("cts00m00 - Pesquisando servicos pendentes")
    end if

   initialize a_motivo, a_cts00m00, ws to null

   let ws.remqtd   =  0
   let ws.assqtd   =  0
   let ws.prgqtd   =  0
   let ws.vstqtd   =  0
   let ws.resqtd   =  0
   let ws.crtqtd   =  0
   let ws.sprqtd   =  0
   let ws.jitqtd   =  0
   let ws.rebasqtd =  0
   let ws.rebcaqtd =  0
   let ws.reretqtd =  0
   let ws.resinqtd =  0
   let ws.reBASQTD =  0
   let int_flag    =  false
   let ws.diasem   =  weekday(today)
   let ws.horaatu  =  current hour to minute
   let ws.relogio  =  current hour to second
   let l_aciona = false
   display ws.relogio to relogio

   #--------------------------------------------------------------------
   # Verifica se as vistorias previas devem ser exibidas
   #--------------------------------------------------------------------
   if ws.diasem >= 1  and  ws.diasem <= 6  then
      if ws.horaatu >= "18:30"  or
         ws.horaatu <= "08:15"  then
         let ws_exbflg = TRUE
      end if
   else
      let ws_exbflg = TRUE
   end if

   #--------------------------------------------------------------------
   # Verifica se RADIO-RE devem ser exibidos
   #--------------------------------------------------------------------
   if ws.horaatu >= "22:00"  or
      ws.horaatu <= "07:00"  then
      let ws_exbflgre = TRUE
   end if

   #--------------------------------------------------------------------
   # Verifica se os JITs devem ser exibidos
   #--------------------------------------------------------------------
   if ws.horaatu >= "22:00"  or
      ws.horaatu <= "07:00"  then
      let ws_exbflgjit = TRUE
   end if

   # PSI 235970 - Tela Cartao Porto Seguro
   ## Inibido por raji jahchan, pedido do Richard
   ##if ws.horaatu >= "22:00"  or
   ##   ws.horaatu <= "07:00"  then
   ##   let ws_exbflgcrt = true
   ##end if

   let l_stmt = null
   case param.tipo_demanda
    when "RADIO-DEMAU"
         let l_stmt = l_stmt clipped,' and atdsrvorg in(1, 2, 4, 5, 6, 7, 17) '
    when "RADIO-DEMRE"
         let l_stmt = l_stmt clipped,' and atdsrvorg in(9,13) '
    when "RADIO-DEMJI"
         let l_stmt = l_stmt clipped,' and atdsrvorg = 15 '
    when "RADIO-DEMVP"
         let l_stmt = l_stmt clipped,' and atdsrvorg = 10 '
    when "RADIO-DEMAF" ## Assistencia Funeral
         let l_stmt = l_stmt clipped,' and atdsrvorg = 18 '
   end case

   let l_fglradre = false

   if l_stmt is null then
      #if  param.ciaempcod = 40 then
      #    let l_stmt = l_stmt clipped,' and ciaempcod = 40 '
      #else
          if param.atdsrvorg = 9 or
             param.atdsrvorg = 13 then    # PSI 235849 Adriano Santos 28/01/2009
             let l_fglradre = true
             let l_stmt = l_stmt clipped,' and atdsrvorg in (9,13) '
          else
             if param.atdsrvorg = 15 then
                let l_stmt = l_stmt clipped,' and atdsrvorg = 15 '
             else
                if param.atdsrvorg = 18 then  ## Funeral
                   let l_stmt = l_stmt clipped,' and atdsrvorg = 18 '
                else
                   if ws_exbflgjit = FALSE and ws_exbflgre = FALSE  then
                      let l_stmt =l_stmt clipped,' and (atdsrvorg not in(8,10,15,9,13)'
                   else
                      if ws_exbflgjit = FALSE then
                         let l_stmt = l_stmt clipped,' and (atdsrvorg not in(8,10,15)'
                      else
                         if ws_exbflgre = FALSE then
                            let l_stmt=l_stmt clipped,' and (atdsrvorg not in(8,10,9,13)'
                         else
                            let l_stmt = l_stmt clipped,' and (atdsrvorg not in(8,10)'
                         end if
                      end if
                   end if

                   if  ws_exbflgcrt = TRUE then
                       let l_stmt = l_stmt clipped,' or ciaempcod = 40) '
                   else
                       let l_stmt = l_stmt clipped,') '
                   end if
                end if    ## Funeral
             end if
          end if
      #end if
   end if

   # Filtra por empresa caso algum veiculo seja recebido como parametro. Burini
   if  param.socvclcod is not null then

       open  c_cts00m00_020 using param.socvclcod
       fetch c_cts00m00_020 into l_emp

       if  sqlca.sqlcode = 0 then

           let l_primeiro = true
           let l_stmt     = l_stmt clipped,' and ciaempcod in('

           foreach c_cts00m00_020 into l_emp
               if  l_primeiro then
                   let l_stmt = l_stmt clipped, l_emp
                   let l_primeiro = false
               else
                   let l_stmt = l_stmt clipped, ',', l_emp
               end if
           end foreach

           let l_stmt = l_stmt clipped,')'

       end if

   end if

   let ws_igbkchave = 'SEP-SRV'
   open  c_cts00m00_011 using ws_igbkchave
   fetch c_cts00m00_011 into  ws_separa

   if sqlca.sqlcode = NOTFOUND  then
     error "Erro (", sqlca.sqlcode, ") na localizacao do parametro de exibicao de EXB SRV - SEPARA. AVISE A INFORMATICA!"
     let ws_separa = false
   end if

   close c_cts00m00_011

   #--------------------------------------------------------------------
   # Cursor PRINCIPAL da tela do Radio
   #--------------------------------------------------------------------

   # Obtem filtro para data/hora inicial de servico
   select grlinf into l_acninihor
     from datkgeral
    where grlchv = "PSOHORARADIOINI"
   if sqlca.sqlcode <> 0 then
      let l_acninihor = 24
   end if

   # Obtem filtro para data/hora final de servico
   select grlinf into l_acnfimhor
     from datkgeral
    where grlchv = "PSOHORARADIO"
   if sqlca.sqlcode <> 0 then
      let l_acnfimhor = 12
   end if

   let l_sql_stmt = "select datmservico.atdsrvnum, ",
                          " datmservico.atdsrvano, ",
                          " datmservico.atdsrvorg, ",
                          " datmservico.asitipcod, ",
                          " datmservico.atdlibdat, ",
                          " datmservico.atdlibhor, ",
                          " datmservico.atddatprg, ",
                          " datmservico.atdhorprg, ",
                          " datmservico.atdhorpvt, ",
                          " datmservico.atdpvtretflg, ",
                          " datmservico.atdvcltip, ",
                          " datmservico.c24opemat, ",
                          " datmservico.atdprinvlcod, ",
                          " datmservico.acnsttflg, ",
                          " datmservico.acnnaomtv, ",
                          " datmservico.atdfnlflg, ",
                          " datmservico.ciaempcod, ",
                          " datmservico.srvprsacnhordat, ",
                          " datmservico.atdetpcod, ",
                          " datmservico.atdrsdflg, ",
                          " datmlcl.lclidttxt, ",
                          " datmlcl.lgdtip, ",
                          " datmlcl.lgdnom, ",
                          " datmlcl.lgdnum, ",
                          " datmlcl.lclbrrnom, ",
                          " datmlcl.brrnom, ",
                          " datmlcl.cidnom, ",
                          " datmlcl.ufdcod, ",
                          " datmlcl.lclrefptotxt, ",
                          " datmlcl.endzon, ",
                          " datmlcl.lgdcep, ",
                          " datmlcl.lgdcepcmp, ",
                          " datmlcl.lclltt, ",
                          " datmlcl.lcllgt, ",
                          " datmlcl.dddcod, ",
                          " datmlcl.lcltelnum, ",
                          " datmlcl.lclcttnom, ",
                          " datmlcl.c24lclpdrcod, ",
                          " datmlcl.emeviacod, ",
                          " datmlcl.celteldddcod, ",
                          " datmlcl.celtelnum, ",
                          " datmlcl.endcmp ",
                     " from datmservico, datmlcl ",
                     " where datmservico.atdsrvnum = datmlcl.atdsrvnum ",
                       " and datmservico.atdsrvano = datmlcl.atdsrvano ",
                       " and datmlcl.c24endtip = 1 ",
                       " and atdfnlflg in ('N','A') ",
                       " and atdlibflg = 'S' ",
                       " and datmservico.ciaempcod in (",m_filtro_ciaempcod clipped,")",
                       " and (srvprsacnhordat > (current - ", l_acninihor using "<<<<" ," units hour) or (ciaempcod = 40 and atdetpcod < 7) )",
                       " and srvprsacnhordat < (current + ", l_acnfimhor using "<<<<" ," units hour)",l_stmt

   let l_sql_stmt = l_sql_stmt clipped," order by datmservico.srvprsacnhordat "

   prepare p_cts00m00_028 from l_sql_stmt
   declare c_cts00m00_024 cursor for p_cts00m00_028

   if param.atdsrvorg = 9 then
      select "Inicio_Pesquisa_RE"
        from dual
   else
      if param.atdsrvorg = 13 then
         select "Inicio_Pesquisa_SINISTRO_RE"
           from dual
      else
         select "Inicio_Pesquisa_AUTO"
           from dual
      end if
   end if

   message " Aguarde, pesquisando..."  attribute(reverse)

   let arr_aux = 1

   set isolation to dirty read

   let m_filtro_hr = false

   if  m_hora_inicial <> '00:00' or m_hora_final <> '23:59' then
       let m_filtro_hr = true
   end if

   foreach c_cts00m00_024 into ws.atdsrvnum     ,
                               ws.atdsrvano     ,
                               ws.atdsrvorg     ,
                               ws.asitipcod     ,
                               ws.atdlibdat     ,
                               ws.atdlibhor     ,
                               ws.atddatprg     ,
                               ws.atdhorprg     ,
                               ws.atdhorpvt     ,
                               ws.atdpvtretflg  ,
                               ws.atdvcltip     ,
                               ws.c24opemat     ,
                               ws.atdprinvlcod  ,
                               lr_atd.acnsttflg ,
                               a_motivo[arr_aux],
                               a_atdfnlflg[arr_aux],
                               ws.ciaempcod,
                               ws.srvprsacnhordat,
                               l_atdetpcod,
                               ws.atdrsdflg,
                               w_cts00m00.lclidttxt,
                               w_cts00m00.lgdtip,
                               w_cts00m00.lgdnom,
                               w_cts00m00.lgdnum,
                               w_cts00m00.lclbrrnom,
                               w_cts00m00.brrnom,
                               w_cts00m00.cidnom,
                               w_cts00m00.ufdcod,
                               w_cts00m00.lclrefptotxt,
                               w_cts00m00.endzon,
                               w_cts00m00.lgdcep,
                               w_cts00m00.lgdcepcmp,
                               w_cts00m00.lclltt,
                               w_cts00m00.lcllgt,
                               w_cts00m00.dddcod,
                               w_cts00m00.lcltelnum,
                               w_cts00m00.lclcttnom,
                               w_cts00m00.c24lclpdrcod,
                               w_cts00m00.emeviacod,
                               w_cts00m00.celteldddcod,
                               w_cts00m00.celtelnum,
                               w_cts00m00.endcmp

         #PSI 232700 - ligia - 14/11/08
         #desprezar srv conveniencia em orcamento
         if ws.ciaempcod = 40 and l_atdetpcod >= 7 then
            continue foreach
         end if

         #desprezar servicos com etapa acionado
         if l_atdetpcod = 3 or    # ACIONADO RE
            l_atdetpcod = 4 then  # ACIONADO AUTO
            continue foreach
         end if

         #####################################################################
         # VERIFICA ACIONAMENTO AUTOMATICO REGRAS DE EXIBICAO
         #####################################################################
         let l_aa_parado = false
         let l_motivo = null

         call cts40g12_ver_aa(ws.atdsrvorg)
              returning l_aa_parado, l_motivo

         if l_aa_parado = true then  ## Se estiver parado

            if a_atdfnlflg[arr_aux] = "A" then ##and a_motivo[arr_aux] is null then
               let a_motivo[arr_aux] = l_motivo
            end if
         else
            #ligia - desprezar os servicos que estao em acionamento automatico
            ## e ainda nao tem motivo para exibir.

            if a_atdfnlflg[arr_aux] = "A" then

               let l_aa_str = extend(ws.srvprsacnhordat, day to day) clipped , "/",
                              extend(ws.srvprsacnhordat, month to month), "/",
                              extend(ws.srvprsacnhordat, year to year)
               let l_aa_data = l_aa_str

               let l_aa_str = extend(ws.srvprsacnhordat, hour to hour) clipped , ":",
                              extend(ws.srvprsacnhordat, minute to minute)
               let l_aa_hora = l_aa_str

               call cts40g03_espera(l_aa_data, l_aa_hora)
                          returning l_aa_interval

               #####DESPREZAR OS SRV QUE ESTAO NO ACIONAMENTO AUTOMATICO ATE O TEMPO LIMITE
               if ws.atddatprg is null then
                  if l_aa_interval < l_aa_espmaximd then
                     continue foreach
                  end if
               else
                  if l_aa_interval < l_aa_espmaxprg then
                     continue foreach
                  end if
               end if

               ### COMENTADO POR RAJI 10/09/2009
               #####DESPREZAR OS SRV QUE ESTAO NO ACIONAMENTO AUTOMATICO
               #####MANTER SOMENTE OS QUE TEM PRESTADOR NAO CONECTADO NO PORTAL
               ###if a_motivo[arr_aux] not matches "*PORTAL" or
               ###   a_motivo[arr_aux] is null then
               ###   continue foreach
               ###end if
            end if
         end if

         #####################################################################
         # VERIFICA SERVICO DEVE SER EXIBIDO
         #####################################################################
         #SE FOR TELA DO CARTAO EXIBE APENAS OS SERVI�OS NAO EMERGENCIAIS CARTAO
         if  param.ciaempcod = 40 then
             let l_exibe_srv = false

             call cts00m00_exibe_srv(ws.atdsrvnum,ws.atdsrvano)
                  returning l_exibe_srv

             if l_exibe_srv then
                continue foreach
             end if
         else
              #SE A FLAG DE EXIBI��O DE SERVI�OS DE CARTAO NAO ESTIVER ACIONADA
              #EXIBE APENAS OS SERVI�OS EMERGENCIAIS
             if  l_fglradre then
                 if  ws.ciaempcod = 40 then
                     let l_exibe_srv = false
                     call cts00m00_exibe_srv(ws.atdsrvnum,ws.atdsrvano)
                          returning l_exibe_srv

                     if l_exibe_srv = false then
                        continue foreach
                     end if
                 end if
             else
                 # QUANDO O SERVI�O FOR DO CARTAO
                 if  ws.ciaempcod = 40 then
                     # SE SOMENTE A FLAG DE EXIBI��O DO RE ESTIVER ACIONADA
                     # MOSTRA APENAS OS SERVICOS EMERGENCIAIS

                     if  ws_exbflgre = true and ws_exbflgcrt = false then

                         let l_exibe_srv = false
                         call cts00m00_exibe_srv(ws.atdsrvnum,ws.atdsrvano)
                              returning l_exibe_srv

                         if l_exibe_srv = false then
                            continue foreach
                         end if
                     else
                         # SE SOMENTE A FLAG DE EXIBI��O DO CARTAO ESTIVER ACIONADA
                         # MOSTRA APENAS OS SERVI�OS NAO EMERGENCIAIS
                         if  ws_exbflgre = false and ws_exbflgcrt = true then
                             let l_exibe_srv = false

                             call cts00m00_exibe_srv(ws.atdsrvnum,ws.atdsrvano)
                                  returning l_exibe_srv

                             if l_exibe_srv = true then
                                continue foreach
                             end if
                         else
                             # SE NENHUMA DAS DUAS FLAGS ESTIVER VERDADEIRA IGNORA OS SERVI�OS DO CARTAO
                             if  ws_exbflgre = false and ws_exbflgcrt = false then
                                 continue foreach
                             end if
                         end if
                     end if
                 end if
             end if
         end if
         let ws.historico = null
         if  ws.atdpvtretflg = "S"   then
             let ws.historico = " RET "
             if param.tipo_demanda = 'RADIO-DEMRE' then
                continue foreach
             end if
         end if

         #####################################################################
         # VERIFICA ACIONAMENTO AUTOMATICO REGRAS DE EXIBICAO
         #####################################################################
         if ws.atdsrvorg = 9 then

            if (ws_exbflgre = FALSE and param.atdsrvorg = 0) and
               (ws_exbflgre = FALSE and ws.ciaempcod <> 40) then
               continue foreach
            end if

            ## Desprezar laudo multiplo
            call cts29g00_consistir_multiplo(ws.atdsrvnum,ws.atdsrvano)
                 returning l_resultado,l_mensagem,
                           l_atdsrvnum_original,
                           l_atdsrvano_original


            ## Se o servico for multiplo de outro servico, despreza
            if l_resultado = 1 then
               continue foreach
            end if

         end if

         #######################
         # Totalizadores
         #######################
         if ws.atdsrvorg = 13 then
            if ws_exbflgre = FALSE   and
               param.atdsrvorg = 0    then
               continue foreach
            end if
            let ws.resinqtd = ws.resinqtd + 1
         end if

         if ws.atddatprg is null  then
            if ws.atdsrvorg = 4   or
               ws.atdsrvorg = 5   or
               ws.atdsrvorg = 7   or
               ws.atdsrvorg =17   then
               let ws.remqtd = ws.remqtd + 1
            else
               if ws.atdsrvorg = 6   or
                  ws.atdsrvorg = 1   or
                  ws.atdsrvorg = 2   then
                  if ws.asitipcod = 1  or    ### Guincho
                     ws.asitipcod = 3  then  ### Guincho/Tecnico
                     let ws.remqtd = ws.remqtd + 1
                  else
                     let ws.assqtd = ws.assqtd + 1
                  end if
               end if
            end if
         else
               let ws.prgqtd = ws.prgqtd + 1
               if ws.atdsrvorg = 4    or
                  ws.atdsrvorg = 5    or
                  ws.atdsrvorg = 7    or
                  ws.atdsrvorg =17    then
                  let ws.remqtd = ws.remqtd + 1
               else
                  if ws.atdsrvorg = 6    or
                     ws.atdsrvorg = 1    or
                     ws.atdsrvorg = 2    then
                     if ws.asitipcod = 1  or    ### Guincho
                        ws.asitipcod = 3  then  ### Guincho/Tecnico
                        let ws.remqtd = ws.remqtd + 1
                     else
                        let ws.assqtd = ws.assqtd + 1
                     end if
                  end if
               end if
         end if

         if ws.atdhorpvt  =  "00:00"   then
               let ws.sprqtd = ws.sprqtd + 1
         end if

         if ws.atdsrvorg = 15 then
            if ws_exbflgjit = FALSE   and
               param.atdsrvorg = 0    then
               continue foreach
            end if
            let ws.jitqtd = ws.jitqtd + 1
         end if

         if  param.ciaempcod = 40 then
             let ws.crtqtd = ws.crtqtd + 1
         end if

         if ws.atdsrvorg = 9 or
            ws.atdsrvorg = 13 then

            ##Obter codigo da natureza
            call cts26g00_obter_natureza(ws.atdsrvnum, ws.atdsrvano)
                  returning l_resultado,l_mensagem,ws.socntzcod, l_espcod

            ##Obter descricao e grupo da natureza.
            call ctc16m03_inf_natureza (ws.socntzcod,"A")
                 returning l_resultado, l_mensagem, ws.socntzdes,
                           ws.socntzgrpcod

            # Verifica se e linha branca
            if ws.socntzgrpcod = 1 then
               let ws.rebcaqtd = ws.rebcaqtd + 1
            end if

            # Verifica se e plano basico
            if ws.socntzgrpcod = 2 or ws.socntzgrpcod = 3 then
               let ws.rebasqtd = ws.rebasqtd + 1
            end if
         end if

         #####################################################################
         # VERIFICA SE O SERVICO EST� DENTRO DO HORARIO INFORMADO PELO FILTRO.
         #####################################################################
         if  m_filtro_hr then
             let l_char = extend(ws.srvprsacnhordat, hour to hour) clipped , ":",
                          extend(ws.srvprsacnhordat, minute to minute)
             let m_hora_acn = l_char
             if  m_hora_acn > m_hora_final or m_hora_acn < m_hora_inicial then
                 continue foreach
             end if
         end if

         #####################################################################
         # Filtro por empresa
         #####################################################################
         #if m_filtro_ciaempcod is not null then
         #   if ws.ciaempcod <> m_filtro_ciaempcod then
         #      continue foreach
         #   end if
         #end if

         #####################################################################
         # Filtro por Quantidade de Servicos
         #####################################################################
         if arr_aux  >  m_filtro_qtdsrv   then
            error " Limite excedido, quantidade de servicos no filtro!"
            continue foreach
         end if

         #PSI 241733 - VERIFICA SE A SEPARA��O DE SERVI�OS EST� ATIVO.
         #             SE O SERVI�O ESTIVER EM UMA CIDADE EM ESTADO
         #             DE ATEN��O N�O APARECE NA TELA
         #             MANUTEN��O = TELA DE CIDADE_SEDE
         if ws_separa = true then

            #CURSOR PARA BUSCAR CIDCOD
            open  c_cts00m00_021 using w_cts00m00.ufdcod,
                                       w_cts00m00.cidnom

            whenever error continue
            fetch c_cts00m00_021 into l_cidcod
            whenever error stop

            if sqlca.sqlcode <> 0 then
                error "Erro ao pesquisar codigo da cidade ", sqlca.sqlcode
            end if
            close c_cts00m00_021

            let l_atnflg = null

            #ATIVADA FUN��O EXIBIR SERVI�OS
            if ws_exbflgaten = true then
                #COM CIDCOD VERIFICA SE A CIDADE EST� EM ESTADO DE ATEN��O
                open c_cts00m00_023 using l_cidcod

                whenever error continue
                fetch c_cts00m00_023 into l_atnflg
                whenever error stop
                close c_cts00m00_023

                #SE O SERVI�O N�O EST� EM UMA CIDADE EM ESTADO DE ATEN��O
                #if sqlca.sqlcode = notfound then
                    #continue foreach
                #end if
                if l_atnflg = 'N' or l_atnflg is null then
                    continue foreach
                end if

            else

                open c_cts00m00_023 using l_cidcod

                whenever error continue
                fetch c_cts00m00_023 into l_atnflg
                whenever error stop
                close c_cts00m00_023

                #SE O SERVI�O EST� EM UMA CIDADE EM ESTADO DE ATEN��O
                #if sqlca.sqlcode != notfound then
                    #continue foreach
                #end if
                if l_atnflg = 'S' then
                    continue foreach
                end if

            end if

         end if

         let lr_atd.atdlibdat = ws.atdlibdat
         let lr_atd.atdlibhor = ws.atdlibhor

         ## Com demanda, despreza o servico se nao tiver coordenada
         if param.tipo_demanda is not null then
            if w_cts00m00.lclltt is null and
               w_cts00m00.lcllgt is null and
               w_cts00m00.c24lclpdrcod is null then
               continue foreach
            end if

            if w_cts00m00.c24lclpdrcod <> 3 and
               w_cts00m00.c24lclpdrcod <> 4 and # PSI 252891
               w_cts00m00.c24lclpdrcod <> 5 then
               continue foreach
            end if

         end if

      if ws.atddatprg  is null then
         let ws.dataprog = ws.atdlibdat
         let ws.horaprog = ws.atdlibhor
      else
         let ws.dataprog = ws.atddatprg
         let ws.horaprog = ws.atdhorprg
      end if

      #if ws.atdsrvorg = 10 then
      #   continue foreach
      #end if

      # Sem demanda: Radio_RE ou Radio_JIT
      if param.atdsrvorg <> 0 and param.tipo_demanda is null then
         if ws.atdsrvorg <> param.atdsrvorg Then
            if (ws.atdsrvorg = 13 and param.atdsrvorg = 9) or
                ws.atdsrvorg = 15 then
            else
               continue foreach
            end if
         end if
      end if

      if ws.c24opemat  is null or ws.c24opemat = 999999 then
         let ws.lockk  = "-"      #--->  Nao esta' sendo acionado
      else
         let ws.lockk  = "*"      #--->  Ja esta' sendo acionado
      end if

      let a_cts00m00[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                              "/"     ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                              ws.lockk ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)


      let a_cts00m00[arr_aux].atdlibhor = ws.atdlibhor
      let a_cts00m00[arr_aux].atdhorprg = ws.atdhorprg

      let a_cts00m00[arr_aux].atdhorpvt = ws.atdhorpvt

      if ws.atdprinvlcod is null then
         let ws.atdprinvlcod = 2         # 2-NORMAL
      end if
      let ws_pricod =  ws.atdprinvlcod

      let l_espcod = null
      ## Para os servicos de RE
      if ws.atdsrvorg = 9 or
         ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009

         call cts10g06_assunto_servico(ws.atdsrvnum ,ws.atdsrvano)
              returning l_resultado, l_mensagem, lr_cts10g06.*

         let g_documento.c24astcod = lr_cts10g06.c24astcod
         let g_documento.ciaempcod = ws.ciaempcod

         let a_cts00m00[arr_aux].srvtipabvdes =
             F_FUNDIGIT_INTTOSTR(ws.socntzcod,3),"-",ws.socntzdes clipped

         #PSI198714
         #despreza o servico se nao tiver mesmo tipo de natureza do socorrista em caso de demanda
         if param.tipo_demanda is not null and
            ws.socntzcod is not null then
               let l_sql= "select socntzcod     "
                              ," from dbsrntzpstesp  "
                              ," where srrcoddig = ", param.srrcoddig
                              ,"   and socntzcod = ", ws.socntzcod
               if l_espcod is not null then
                  #servico tem especialidade verificar se socorrista atende natureza e especialidade
                  let l_sql = l_sql clipped, " and espcod = ", l_espcod
               end if
               prepare pcts00m00031 from l_sql
               declare ccts00m00031  cursor for pcts00m00031
               open ccts00m00031
               fetch ccts00m00031 into ws.socntzcod
               if sqlca.sqlcode = notfound then
                   #busca por demanda e natureza/especialidade do servico nao � atendida
                   # pelo socorrista
                   continue foreach
               end if
         end if
      else
         open  c_cts00m00_006 using ws.atdsrvorg
         fetch c_cts00m00_006 into  a_cts00m00[arr_aux].srvtipabvdes
         close c_cts00m00_006
      end if

      #PSI198714
      #despreza o servico se nao tiver mesmo tipo de assistencia do socorrista em caso de demanda
      if param.tipo_demanda is not null and
          (ws.atdsrvorg = 1 or
           ws.atdsrvorg = 2 or
           ws.atdsrvorg = 3 or
           ws.atdsrvorg = 4 or
           ws.atdsrvorg = 5 or
           ws.atdsrvorg = 6 or
           ws.atdsrvorg = 7 or
           ws.atdsrvorg = 17  ) then
            #origem de servico de veiculo validar se socorrista atende tipo assistencia
            let l_sql = "select 1  ",
                        "   from datrsrrasi a",
                        "  where a.srrcoddig = ",param.srrcoddig
            case ws.asitipcod      #quando tipo de assistencia do servico e:
               when 1              #GUINCHO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUINCHO e GUINCHO/TECNICO
                        " and a.asitipcod in (1, 3)"
               when 2              #TECNICO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #TECNICO - GUINCHO/TECNICO - CHAVEIRO/TECNICO
                        " and a.asitipcod in (2, 3, 9)"
               when 3              #GUI/TEC podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUI/TEC ou GUINCHO e TECNICO juntos
                        " and (a.asitipcod = 3 or "
                       ,"      (a.asitipcod = 1 and    "
                       ,"        exists (select b.asitipcod               "
                       ,"                 from datrsrrasi b               "
                       ,"                 where b.srrcoddig = a.srrcoddig "
                       ,"                 and b.asitipcod = 2) ) )        "
               when 4              #CHAVEIRO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO E CHAVEIRO TECNICO
                        " and a.asitipcod in (4, 9, 40)"
               when 9              #CHAVEIRO TECNICO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO TECNICO OU TECNICO e Chaveiro ou Chavauto juntos
                        " and (a.asitipcod = 9 or   "
                       ,"      (a.asitipcod = 2 and "
                       ,"        exists (select b.asitipcod                "
                       ,"                  from datrsrrasi b               "
                       ,"                  where b.srrcoddig = a.srrcoddig "
                       ,"                  and (b.asitipcod = 4 or         "
                       ,"                        b.asitipcod = 40) ) ) )   "
               when 40               #CHAVAUTO podemos enviar socorrista que atende
                     let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                        " and a.asitipcod in (4, 9, 40)"

               otherwise
                     let l_sql = l_sql clipped, " and asitipcod in (", ws.asitipcod, ")"
            end case
            #OBS.: Hoje estamos fazendo essas conversoes de tipo de assitencia do
            # socorrista porque o cadastro deles n�o est� integro.
            # Os c�digos 3, 9 e 40 nao deveriam mais existir
            # exemplo: os socorristas que atendem assistencia 3 deveriam atender
            # assistencia 1 e 2.
            #Quando o cadastro de assistencia dos socorristas estiver correto,
            # podemos retirar essas conversoes
            prepare pcts00m00032 from l_sql
            declare ccts00m00032  cursor for pcts00m00032
            open ccts00m00032
            fetch ccts00m00032 into l_resultado
            if sqlca.sqlcode = notfound then
                #busca por demanda e assistencia do servico nao � atendida
                # pelo socorrista
                continue foreach
            end if
      end if

      #if ws.atdsrvorg = 10   then
      #   initialize  ws.lighorinc  to null
#
#         open  c_cts00m00_008 using ws.atdsrvnum, ws.atdsrvano
#         fetch c_cts00m00_008 into  ws.lighorinc
#
#         if ws.lighorinc  is not null   then
#            let ws.historico = ws.historico clipped, " ",
#                               ws.lighorinc,"-","CAN"
#         end if
#         close c_cts00m00_008
#      end if

      ## Para servicos JIT
      initialize ws.refatdsrvnum to null
      initialize ws.refatdsrvano to null
      if ws.atdsrvorg = 15   then

         open  c_cts00m00_016 using ws.atdsrvnum, ws.atdsrvano
         fetch c_cts00m00_016 into  ws.refatdsrvnum, ws.refatdsrvano
         close c_cts00m00_016

         let aux_ano4 = "20" clipped , ws.refatdsrvano using "&&"
         open  c_cts00m00_017 using ws.refatdsrvnum , aux_ano4
         fetch c_cts00m00_017 into  ws.refatdsrvnum

         if sqlca.sqlcode <> notfound then
            let a_cts00m00[arr_aux].srvtipabvdes = "JIT-RE"
         end if
         close c_cts00m00_017
      end if

      if ws.asitipcod is not null  then
         let a_cts00m00[arr_aux].asitipabvdes = "NAO PREV"
         open  c_cts00m00_007 using ws.asitipcod
         fetch c_cts00m00_007 into  a_cts00m00[arr_aux].asitipabvdes
         close c_cts00m00_007
      end if

#--------------------------------------------------------------------
# Especifica tipo de guincho a ser enviado dependendo do veiculo
#--------------------------------------------------------------------
      if ws.atdvcltip = 1 and ws.atdsrvorg <> 15 then
         let a_cts00m00[arr_aux].asitipabvdes =
             a_cts00m00[arr_aux].asitipabvdes[1,3], " HID"
      end if

      if ws.atdvcltip = 2 and ws.atdsrvorg <> 15 then
         let a_cts00m00[arr_aux].asitipabvdes =
             a_cts00m00[arr_aux].asitipabvdes[1,3], " PEQ"
      end if

      if ws.atdvcltip = 3 and ws.atdsrvorg <> 15 then
         let a_cts00m00[arr_aux].asitipabvdes =
             a_cts00m00[arr_aux].asitipabvdes[1,3], " CAM"
      end if

      open  c_cts00m00_013 using l_atdetpcod
      fetch c_cts00m00_013 into  a_cts00m00[arr_aux].atdetpdes
      close c_cts00m00_013

      let ws.atdetpcodint = null

      open  c_cts00m00_018 using ws.atdsrvnum, ws.atdsrvano
      fetch c_cts00m00_018 into ws.atdetpcodint
      close c_cts00m00_018

      if ws.atdetpcodint  = 2   then
         let a_cts00m00[arr_aux].atdetpdes = "LIB/RECU"
      end if

      if ws.atdetpcodint  = 4   then
         let a_cts00m00[arr_aux].atdetpdes = "LIB/EXED"
      end if

      let a_cts00m00[arr_aux].atdlibdat = ws.atdlibdat[1,5]
      let a_cts00m00[arr_aux].atddatprg = ws.atddatprg[1,5]

      #--------------------------------------------------------------------
      # Verifica se houve reclamacao, alteracao ou cancelamento do servico
      #--------------------------------------------------------------------
      open    c_cts00m00_010 using ws.atdsrvnum, ws.atdsrvano
      let l_flag = false

      foreach c_cts00m00_010 into  ws.lighorinc, ws.ligastcod

         if param.tipo_demanda = "RADIO-DEMRE" and ws.ligastcod = "RET" then
            let l_flag = true
            exit foreach
         end if

         let ws.historico = ws.historico clipped, " ",
                            ws.lighorinc, "-", ws.ligastcod
      end foreach

      if l_flag = true then
         continue foreach
      end if

      let a_cts00m00[arr_aux].atdlibdat = ws.atdlibdat[1,5]
      let a_cts00m00[arr_aux].atddatprg = ws.atddatprg[1,5]

      #Obter a descricao da via emergencial
      if w_cts00m00.emeviacod is not null and w_cts00m00.emeviacod <> 0 then
              call ctc17m02_obter_via (w_cts00m00.emeviacod,'')
              returning lr_ctc17m02.resultado,lr_ctc17m02.mensagem,
                        lr_ctc17m02.emeviades,lr_ctc17m02.emeviapri

         if lr_ctc17m02.resultado = 3 then
            error lr_ctc17m02.mensagem sleep 1
         end if

         #Inicio - Situa��o local de ocorr�ncia
         open  ccts00m00038 using ws.atdsrvorg
         fetch ccts00m00038 into l_count_auto
         if l_count_auto = 0 then
           let l_flag_auto = 'N' #Servi�o n�o � auto
           #display "N�o � auto!!" #Kelly2 - retirar
         else
           let l_flag_auto = 'S' #Servi�o auto
           #display "� auto!!" #Kelly2 - retirar
           if w_cts00m00.emeviacod = 1 then #Veiculo em local de risco
             let a_cts00m00[arr_aux].emeviades = 'VEICULO SOB RISCO'
           else
             let a_cts00m00[arr_aux].emeviades = ' ',' '
           end if
         end if
         {
         if lr_ctc17m02.emeviapri = 1 then # prioridade alta
            let a_cts00m00[arr_aux].emeviades = ' ',lr_ctc17m02.emeviades
         else
            let a_cts00m00[arr_aux].emeviades = lr_ctc17m02.emeviades
         end if
         }
         #Fim - Situa��o local de ocorr�ncia

      end if

      #ligia
      if lr_atd.acnsttflg = "N" and a_motivo[arr_aux] is not null then
         let a_cts00m00[arr_aux].emeviades ='NAO ACIONADO AUTOMATICO'
      end if

      # PSI 244589 - Inclus�o de Sub-Bairro - Burini
      call cts06g10_monta_brr_subbrr(w_cts00m00.brrnom,
                                     w_cts00m00.lclbrrnom)
           returning w_cts00m00.lclbrrnom

      let a_cts00m00[arr_aux].historico = w_cts00m00.ufdcod    clipped, "/",
                                          w_cts00m00.cidnom    clipped, "/",
                                          w_cts00m00.lclbrrnom

      if ws.historico is not null then
         let a_cts00m00[arr_aux].historico[38,64] = " ", ws.historico
      end if

      let a_cts00m00[arr_aux].sindex = ''

      if ws.atdsrvorg <> 8  and
         ws.atdsrvorg <> 11 and
         ws.atdsrvorg <> 12 and
         ws.atdsrvorg <> 16 then

         call cts00m00_sindex
             (w_cts00m00.ufdcod, w_cts00m00.cidnom, ws.atdsrvorg,
              w_cts00m00.lclltt, w_cts00m00.lcllgt,
              w_cts00m00.c24lclpdrcod)
              returning a_cts00m00[arr_aux].sindex

      end if

      # --> VERIFICA SE O SERVICO E URGENTE

      if ws.atdprinvlcod = 3 then
         # --> SERVICO URGENTE
         let a_cts00m00[arr_aux].urgente = "*URG*"
      else
         let a_cts00m00[arr_aux].urgente = null
      end if

      # --> VERIFICA SE O SERVICO ESTA NA RESIDENCIA
      if ws.atdrsdflg <> "S" then
         let a_cts00m00[arr_aux].rsdflg = "PRIORIZAR"
      else
         let a_cts00m00[arr_aux].rsdflg = null
      end if

      #------------------------------------------------------------------
      # Calcula tempo de espera
      #------------------------------------------------------------------
      if ws.atddatprg  is null     or
         ws.atddatprg  <=  today   then
         if a_cts00m00[arr_aux].atdhorprg  is null   then
            let a_cts00m00[arr_aux].atddatprg = "IMED."
            call cts00m00_espera(ws.atdlibdat, a_cts00m00[arr_aux].atdlibhor)
                 returning a_cts00m00[arr_aux].espera
         else
           if ws.atddatprg  =  today                    or
              a_cts00m00[arr_aux].atdhorprg <> "00:00"  then
              call cts00m00_espera(ws.atddatprg, a_cts00m00[arr_aux].atdhorprg)
                   returning a_cts00m00[arr_aux].espera
           end if
         end if
      end if

      if param.tipo_demanda is not null then
         call cts18g00(w_cts00m00.lclltt, w_cts00m00.lcllgt,
                       param.lclltt, param.lcllgt)
              returning a_cts00m00[arr_aux].dstqtd
      end if

      #PSI 205206
      #Descrever empresa
      if ws.ciaempcod is not null then
         call cty14g00_empresa(1, ws.ciaempcod)
              returning l_resultado,
                        l_mensagem,
                        a_cts00m00[arr_aux].empresa

         case ws.ciaempcod
            when 40
               let a_cts00m00[arr_aux].empresa = 'CARTAO'
            when 43
               let a_cts00m00[arr_aux].empresa = 'PSS'
         end case
      else
         let a_cts00m00[arr_aux].empresa = "S EMP"
      end if

      if ws.atdsrvorg = 1  or ws.atdsrvorg = 6  or
         ws.atdsrvorg = 9  or ws.atdsrvorg = 13 then

         ## Obter a descricao do problema
         open c_cts00m00_005 using ws.atdsrvnum ,ws.atdsrvano

         whenever error continue
         fetch c_cts00m00_005 into l_c24pbmcod ,l_c24pbmdes
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let l_c24pbmcod = null
               let l_c24pbmdes = null
            else
               error 'cts00m00() / ',ws.atdsrvnum,' / ',ws.atdsrvano  sleep 2
               let int_flag = true
               exit foreach
            end if
         end if

         if l_c24pbmcod is not null then
            let a_cts00m00[arr_aux].problema = l_c24pbmdes
         end if
      end if

      let arr_aux = arr_aux + 1

      if arr_aux  >  500   then
         error " Limite excedido, tabela de servicos c/ mais de 500 itens!"
         exit foreach
      end if

   end foreach
   free c_cts00m00_024

   set lock mode to wait

   if int_flag = true then
      exit while
   end if

   if arr_aux = 1   then
      error " Nao existem servicos pendentes!"
   else
      if param.tipo_demanda is not null then
         ##--> Classificar por ordem decrescente de espera e crescente de distancia
         for l_arr1 = 1 to arr_aux - 1
             let l_arr3 = l_arr1
             if  a_cts00m00[l_arr1].dstqtd is null then
                 let l_auxn = 0
             else
                 let l_auxn = (a_cts00m00[l_arr1].dstqtd * 10000)
             end if
             let l_swap1 = l_auxn using "&&&&&&&&&"
             for l_arr2 = (l_arr1 + 1) to (arr_aux - 1)
                 if  a_cts00m00[l_arr2].dstqtd is null then
                     let l_auxn = 0
                 else
                     let l_auxn = (a_cts00m00[l_arr2].dstqtd * 10000)
                 end if
                 let l_swap2 = l_auxn using "&&&&&&&&&"
                 if  l_swap2 < l_swap1 then
                     let l_swap1 = l_swap2
                     let l_arr3  = l_arr2
                 end if
             end for
             let al_cts00m00[l_arr1].* = a_cts00m00[l_arr1].*
             let a_cts00m00[l_arr1].*  = a_cts00m00[l_arr3].*
             let a_cts00m00[l_arr3].*  = al_cts00m00[l_arr1].*
         end for
         let int_flag = true
      end if
   end if

   let ws.cabec = "Rem:", ws.remqtd   using "#&&",
                 " Ass:", ws.assqtd   using "#&&",
                 " Spv:", ws.sprqtd   using "#&&",
                 " Rsv:", ws.resqtd   using "#&&",
                 " Prg:", ws.prgqtd   using "#&&"

   if ws_exbflg  =  TRUE    then
      let ws.cabec =  ws.cabec  clipped, " Vst:", ws.vstqtd   using "#&&"
   end if

   if ws_exbflgjit    =  TRUE  then
      let ws.cabec =  ws.cabec  clipped, " Jit:", ws.jitqtd   using "#&&"
   end if

   if ws_exbflgre     =  TRUE  then
      let ws.cabec =  ws.cabec  clipped,
                      " PBas:", ws.reBASQTD   using "#&&",
                      " LBca:", ws.rebcaqtd   using "#&&",
                      #" S_RE:", ws.resinqtd   using "#&&",
                      " Ret:",  ws.reretqtd   using "#&&"
   end if

   if param.atdsrvorg = 15     then
      let ws.cabec =  "Jit:", ws.jitqtd   using "#&&"
   end if

   if param.atdsrvorg = 9      then
      let ws.cabec =  "PBas:", ws.reBASQTD   using "#&&",
                     " LBca:", ws.rebcaqtd   using "#&&",
                     " S_RE:", ws.resinqtd   using "#&&",
                     " Ret:",  ws.reretqtd   using "#&&",
                     " Prg:", ws.prgqtd   using "#&&"
   end if

   if  param.ciaempcod = 40 then
       let ws.cabec = "Cart�o N�o Emergencial: ", ws.crtqtd using "#&&"
   end if

   display ws.cabec  to  cabec

   #-------------------------------------------------------------------
   # Exibe tela com alertas (se houver)
   #-------------------------------------------------------------------
   if param.atdsrvorg <> 15 then
      call cts00m21()
      call cts00m31()
   end if

   if ws_exbflgjit    =  TRUE  or
      param.atdsrvorg = 15     then
      call cts00m00_alertajit(0,0) ##ligia - tem que preparar os cursores
   end if

   #-------------------------------------------------------------------
   # Exibe tela com os servicos
   #-------------------------------------------------------------------
   call set_count(arr_aux-1)
   let l_rodape = "F1-Ajuda F5-Motivo"

   if param.tipo_demanda is null then
      let l_rodape = l_rodape clipped, " F6-Atualiza"
   end if
   let l_rodape = l_rodape clipped, " F7-Funcoes F8-Laudo F10-Trans."
   if  cts00m00_verifica_acesso_totalizador() then
       let l_rodape = l_rodape clipped, " F9-Totais"
   end if
   message l_rodape
   let int_flag = false

   if ws_exbflgre then
      select "Fim_Pesquisa_RE"
        from dual
   else
     select "Fim_Pesquisa_AUTO"
       from dual
   end if

   display array a_cts00m00 to s_cts00m00.*

      on key (interrupt,control-c)
         let int_flag = true
         exit display

      #-------------------------------------------------------------------
      # Sistema de Ajuda e procedimentos
      #-------------------------------------------------------------------
      on key (F1)
         call cta00m08_ver_contingencia(1)
               returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         if param.tipo_demanda is null then
            call cts14g02("N","cts00m00")
         end if

      on key (F5)
         call cta00m08_ver_contingencia(1)
              returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         let arr_aux = arr_curr()
         call cts00m00_exibe_motivo(a_motivo[arr_aux])

      #-------------------------------------------------------------------
      # Nova consulta
      #-------------------------------------------------------------------
      on key (F6)
         ### PSI179345
         call cta00m08_ver_contingencia(1)
               returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         if param.tipo_demanda is null then
            exit display
         end if
      #-------------------------------------------------------------------
      # Seleciona FUNCOES
      #-------------------------------------------------------------------
      on key (F7)
         ## Exibir popup das funcoes do Radio.

         if g_setexplain = 1 then
            call cts01g01_setetapa("cts00m00 - F7 - Filtros")
         end if

         call cta00m08_ver_contingencia(1)
               returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         let ws.pesq = null

         while true

             if  param.ciaempcod = 40 then
                 let param.atdsrvorg = 9
             end if

             let ws.pesq = cts00m04(param.atdsrvorg)

             if  param.ciaempcod = 40 then
                 let param.atdsrvorg = ""
             end if

             if ws.pesq is null   then
                exit while
             end if

             if ws.pesq = "pnl" then # PRESTADORES NAO LOGADOS NO PORTAL DE NEGOCIOS
                call cts00m39()
             end if

             if ws.pesq = "ctg" then
             	
             	  let l_naoprocessado = 0
             	  
             	  select count(*) into l_naoprocessado
                  from datmcntsrv
                where datmcntsrv.prcflg = 'N'
                
                if l_naoprocessado > 0 then
                   let msg.linha4 = 'ESTA LIGADA. FALTAM PROCESSA ', l_naoprocessado using '<<<<<&', ' SERVICOS.'
                else
                   let msg.linha4 = 'ESTA LIGADA. CARGA FINALIZADA.'
                end if

             	  # Verifica se a carga automatica de contingencia esta ativa
             	  if cty42g00_acessa() then
                   call cts08g01("A","N","NAO E POSSIVEL REALIZAR A CARGA"
                                        ,"MANUALMENTE."
                                        ,"O PROCESSO AUTOMATICO DE CARGA"
                                        ,msg.linha4)
                        returning l_confirma
             	  else
             	
                   call cts00m00_verifica_acionamento_carga()
                      returning lr_retorno.flag,
                                lr_retorno.atldat,
                                lr_retorno.atlhor,
                                lr_retorno.atlfunnom
                   if lr_retorno.flag = 'S' then
                       let msg.linha1 = "CARGA DA CONTINGENCIA JA ACIONADA "
                       let msg.linha2 = "RESPONSAVEL...: ",lr_retorno.atlfunnom clipped
                       let msg.linha3 = "DATA..........: ",lr_retorno.atldat clipped
                       let msg.linha4 = "HORA..........: ",lr_retorno.atlhor clipped
                      call cts08g01_6l ("A","N","",""
                                        ,msg.linha1
                                        ,msg.linha2
                                        ,msg.linha3
                                        ,msg.linha4)
                           returning l_confirma
                       exit while
                   else
                       call cts35m00()
                       exit while
                   end if
             	  end if
             end if

             if ws.pesq = "acd" then
                let  l_string = null
                open c_cts00m00_004
                foreach c_cts00m00_004   into  l_grlchv, l_grlinf
                  case l_grlchv
                       when 'RADIO-DEMAU'
                            let l_string = l_string clipped, 'AUTO'
                       when 'RADIO-DEMJI'
                            let l_string = l_string clipped, 'JIT'
                       when 'RADIO-DEMRE'
                            let l_string = l_string clipped, 'RE'
                       when 'RADIO-DEMVP'
                            let l_string = l_string clipped, 'VP'
                  end case
                  if  l_grlinf = '1' then
                      let l_string = l_string clipped, ' - ATIVO'
                  end if
                  let l_string = l_string clipped, '|'
                end foreach
                let l_len = length(l_string)
                let l_string[l_len]=" "
                call ctx14g00("DEMANDA", l_string)
                     returning l_opcao, l_descricao
                let l_aux = l_descricao[1,2]
                case l_aux
                   when 'AU'
                      let l_grlchv = "RADIO-DEMAU"
                   when 'RE'
                      let l_grlchv = "RADIO-DEMRE"
                   when 'JI'
                      let l_grlchv = "RADIO-DEMJI"
                   when 'VP'
                      let l_grlchv = "RADIO-DEMVP"
                end case
                let l_aux = "C24"
                open c_cts00m00_003 using  l_aux
                                        ,l_grlchv

                whenever error continue
                fetch c_cts00m00_003 into l_grlinf
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = notfound then
                      let l_grlinf = '0'
                   else
                      error ' CTS00M00/ cts00m00()/ ', l_aux,' / ',l_grlchv sleep 1
                      let int_flag = true
                      exit while
                   end if
                end if
                if l_grlinf = '1' then
                   let l_alt = 0
                else
                   let l_alt = 1
                end if
                if l_opcao <> 0 then
                   whenever error continue
                   execute p_cts00m00_004 using  l_alt
                                              ,l_aux
                                              ,l_grlchv

                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      error ' CTS00M00/ cts00m00()/ ', l_aux,' / ',l_grlchv sleep 1
                      let int_flag = true
                      exit display
                   else
                      if l_grlinf = '1' then
                         error 'Demanda Desativada' sleep 1
                      else
                         error 'Demanda Acionada' sleep 1
                         let int_flag = true
                      end if
                      exit display
                   end if
                end if
             end if

             if ws.pesq = "spr"  or
                ws.pesq = "rsv"  or
                ws.pesq = "vst"  or
                ws.pesq = "prg"  or
                ws.pesq = "nli"  or
                ws.pesq = "can"  or
                ws.pesq = "caj"  or
                ws.pesq = "car"  or
                ws.pesq = "ret"  or
                ws.pesq = "tpa"  or
                ws.pesq = "grp"  then

                initialize lr_cts00m36 to null

                if ws.pesq = "prg" then
                   while true
                      call cts00m36_parametros()
                         returning lr_cts00m36.*
                      if int_flag = true then
                         let int_flag = false
                         exit while
                      end if

                      initialize lr_cts00m01 to null
                      let lr_cts00m01.par_pesq     = ws.pesq
                      let lr_cts00m01.data_inicial = lr_cts00m36.data_inicial
                      let lr_cts00m01.data_final   = lr_cts00m36.data_final
                      let lr_cts00m01.atdprscod    = lr_cts00m36.atdprscod
                      let lr_cts00m01.atdsrvorg    = lr_cts00m36.atdsrvorg
                      let lr_cts00m01.nome         = lr_cts00m36.nome
                      let lr_cts00m01.vcllicnum    = lr_cts00m36.vcllicnum
                      let lr_cts00m01.in_empresas  = lr_cts00m36.in_empresas
                      call cts00m01(lr_cts00m01.*)
                   end while
                else
                   if ws.pesq = "tpa" or
                      ws.pesq = "grp" then
                      while true
                         call cts00m37_filtro(ws.pesq)
                            returning l_cod_filtro,l_ufdcod,l_filtro_resumo,
                                      l_cidnom, l_flag_ac
                         if int_flag then
                            let int_flag = false
                            exit while
                         end if
                         initialize lr_cts00m01.* to null
                         let lr_cts00m01.par_pesq      = ws.pesq
                         let lr_cts00m01.codigo_filtro = l_cod_filtro
                         let lr_cts00m01.ufdcod        = l_ufdcod
                         let lr_cts00m01.filtro_resumo = l_filtro_resumo
                         let lr_cts00m01.cidnom        = l_cidnom
                         let lr_cts00m01.flag_ac       = l_flag_ac
                         call cts00m01(lr_cts00m01.*)
                      end while
                   else
                      initialize lr_cts00m01.* to null
                      let lr_cts00m01.par_pesq      = ws.pesq
                      call cts00m01(lr_cts00m01.*)
                   end if
                end if

             else
                case ws.pesq
                   when "inc"  call cts23m00()

                   when "frt"  call cts00m03(2,2,"QRV","","","","","")
                                    returning ws.atdprscod,
                                              ws.atdvclsgl,
                                              ws.srrcoddig,
                                              ws.socvclcod,
                                              ws.flag_cts00m03

                   when "loc"  call cts00m06()
                   when "int"  call cts00m27()
                   when "eam"
                      let  l_achou = false
                      open c_cts00m00_004
                      foreach c_cts00m00_004   into  l_grlchv, l_grlinf
                         if l_grlinf = '1' then
                            let l_achou = true
                            exit foreach
                         end if
                      end foreach
                      if l_achou then
                         call ctx14g00("ACIONADOS", "Viaturas|Servicos")
                              returning l_opcao, l_descricao
                         if l_opcao = 1 then  ##--> Viaturas
                            call cts00m05()
                         else
                            call cts00m07()
                         end if
                      else
                         call cts00m07()
                      end if

                   when "acp"  call cts00m10()
                   when "lst"
                      if  cts00m00_verifica_acesso_lstsrv() then
                          call cts59m00()
                      else
                          call cts08g01("A","N","","ACESSO CONTROLADO PELA COORDENACAO DA",
                                        "CENTRAL DE OPERACOES","")
                               returning l_resposta
                      end if

                   when "vds"  call ctn47c03()
                   when "mdt"  call ctn44c00(2,"","")
                   when "emt"  call cts24m00()
                   when "cps"  call ctc60n00()
                   when "exb"  let ws_igbkchave = 'RADIO-VP'
                               open  c_cts00m00_011 using ws_igbkchave
                               fetch c_cts00m00_011 into  ws_exbflg

                               if sqlca.sqlcode = NOTFOUND  then
                                  error "Erro (", sqlca.sqlcode, ") na ",
                                        "localizacao do parametro de exibicao ",
                                        "de V.P. AVISE A INFORMATICA!"
                                  let ws_exbflg = false
                               end if

                               close c_cts00m00_011

                               if ws_exbflg = TRUE  then
                                  let ws_exbflg = FALSE
                               else
                                  let ws_exbflg = TRUE
                               end if

                               let ws.atlult = today," - ", g_issk.funmat using "&&&&&&"
                               whenever error continue
                                  execute p_cts00m00_017 using ws_exbflgre,
                                                              ws.atlult,
                                                              "RADIO-VP"
                                  if sqlca.sqlcode <> 0  then
                                     error "Erro (",sqlca.sqlcode,") na ",
                                           "alteracao do modo de exibicao. ",
                                           "AVISE A INFORMATICA!"
                                  end if
                               whenever error stop

                               exit display

                   when "exr"  let ws_igbkchave = 'RADIO-RE'
                               open  c_cts00m00_011 using ws_igbkchave
                               fetch c_cts00m00_011 into  ws_exbflgre

                               if sqlca.sqlcode = NOTFOUND  then
                                  error "Erro (", sqlca.sqlcode, ") na ",
                                        "localizacao do parametro de exibicao ",
                                        "do RADIO RE. AVISE A INFORMATICA!"
                                  let ws_exbflgre = false
                               end if

                               close c_cts00m00_011

                               if ws_exbflgre = TRUE  then
                                  let ws_exbflgre = FALSE
                               else
                                  let ws_exbflgre = TRUE
                               end if

                               let ws.atlult = today," - ", g_issk.funmat using "&&&&&&"
                               whenever error continue
                                  execute p_cts00m00_017 using ws_exbflgre,
                                                              ws.atlult, "RADIO-RE"
                                  if sqlca.sqlcode <> 0  then
                                     error "Erro (",sqlca.sqlcode,") na ",
                                           "alteracao do modo de exibicao. ",
                                           "AVISE A INFORMATICA!"
                                  end if
                               whenever error stop

                               exit display

                   when "exj"  let ws_igbkchave = 'RADIO-JIT'
                               open  c_cts00m00_011 using ws_igbkchave
                               fetch c_cts00m00_011 into  ws_exbflgjit

                               if sqlca.sqlcode = NOTFOUND  then
                                  error "Erro (", sqlca.sqlcode, ") na ",
                                        "localizacao do parametro de exibicao ",
                                        "de JIT. AVISE A INFORMATICA!"
                                  let ws_exbflgjit = false
                               end if

                               close c_cts00m00_011

                               if ws_exbflgjit = TRUE  then
                                  let ws_exbflgjit = FALSE
                               else
                                  let ws_exbflgjit = TRUE
                               end if

                               let ws.atlult = today," - ", g_issk.funmat using "&&&&&&"
                               whenever error continue
                                  execute p_cts00m00_017 using ws_exbflgjit,
                                                              ws.atlult, "RADIO-JIT"
                                  if sqlca.sqlcode <> 0  then
                                     error "Erro (",sqlca.sqlcode,") na ",
                                           "alteracao do modo de exibicao. ",
                                           "AVISE A INFORMATICA!"
                                  end if
                               whenever error stop

                               exit display

                   #PSI 241733 - EXIBI��O DE SERVI�OS EM ESTADO DE ATEN��O
                   when "eat"
                               if ws_exbflgaten = TRUE  then
                                  let ws_exbflgaten = FALSE
                               else
                                  let ws_exbflgaten = TRUE
                               end if

                               exit display

                   # PSI 235970 - Tela Cartao Porto Seguro
                   when "exc"  let ws_igbkchave = 'RADIO-CARTAO'
                               open  c_cts00m00_011 using ws_igbkchave
                               fetch c_cts00m00_011 into  ws_exbflgcrt

                               if sqlca.sqlcode = NOTFOUND  then
                                  error "Erro (", sqlca.sqlcode, ") na ",
                                        "localizacao do parametro de exibicao ",
                                        "do RADIO RE. AVISE A INFORMATICA!"
                                  let ws_exbflgcrt = false
                               end if

                               close c_cts00m00_011

                               if ws_exbflgcrt = TRUE  then
                                  let ws_exbflgcrt = FALSE
                               else
                                  let ws_exbflgcrt = TRUE
                               end if

                               let ws.atlult = today," - ", g_issk.funmat using "&&&&&&"
                               whenever error continue
                                  execute p_cts00m00_017 using ws_exbflgcrt,
                                                              ws.atlult, "RADIO-CARTAO"
                                  if sqlca.sqlcode <> 0  then
                                     error "Erro (",sqlca.sqlcode,") na ",
                                           "alteracao do modo de exibicao. ",
                                           "AVISE A INFORMATICA!"
                                  end if
                               whenever error stop

                               exit display

                   #PSI257664 - Abrir tela de registro de atendimento
                   when "reg"
                        #verifica se usuario tem acesso a tela
                        call cta00m09_acesso()
                             returning acesso
                        if acesso = "true" then
                           call cta00m09("","")
                        else
                           error "Usuario sem acesso a tela de Registro de Atendimento da Central de Operacoes."
                        end if

                end case
             end if

             if ws.pesq = "acw" then
                ###  REALIZA SINCRONISMO ACIONAMENTO WEB
                call ctx34g02_sincro_servico()
             end if
         end while

         exit display

      #-------------------------------------------------------------------
      # Aciona servico via radio
      #-------------------------------------------------------------------
      on key (F8)

         call cta00m08_ver_contingencia(1)
               returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         let arr_aux = arr_curr()

         let l_resposta = "S"

         if arr_aux <> 1 and param.tipo_demanda is not null then
            call cts08g01("A", "S", "Servico selecionado nao e o mais" ,
                                    "proximo da viatura disponivel ",
                                    "",
                                    "Confirma a escolha ? ")
                 returning l_resposta
         end if

      if l_resposta = "S" then
         if param.tipo_demanda is not null then
            let g_documento.dstqtd = a_cts00m00[arr_aux].dstqtd
            let ws.atdhorpvt = a_cts00m00[arr_aux].atdhorpvt
            let l_aux2 = a_cts00m00[arr_aux].atdhorpvt
            call cts21g00_calc_prev(a_cts00m00[arr_aux].dstqtd, l_aux2)
                 returning g_documento.prvcalc
         end if

         let g_documento.atdsrvorg = a_cts00m00[arr_aux].servico[1,2]
         let g_documento.atdsrvnum = a_cts00m00[arr_aux].servico[4,10]
         let g_documento.atdsrvano = a_cts00m00[arr_aux].servico[12,13]

         if g_setexplain = 1 then
            let l_msg = 'cts00m00 - F8 Laudos',g_documento.atdsrvorg, ' / '
                                              ,g_documento.atdsrvano, '-'
                                              ,g_documento.atdsrvnum
            call cts01g01_setetapa(l_msg)
         end if

         if a_cts00m00[arr_aux].srvtipabvdes = "JIT-RE" then
            select refatdsrvnum,
                   refatdsrvano
              into ws.refatdsrvnum,
                   ws.refatdsrvano
              from datmsrvjit
             where atdsrvnum = g_documento.atdsrvnum
               and atdsrvano = g_documento.atdsrvano

            if sqlca.sqlcode = 0 then
               let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"

               select sinvstnum from datmpedvist
                where sinvstnum = ws.refatdsrvnum
                  and sinvstano = aux_ano4

               if sqlca.sqlcode = 0 then
                  call cts21m03(ws.refatdsrvnum, aux_ano4)
                  if g_documento.atdsrvnum is not null then
                     call cts10g04_ultima_etapa(g_documento.atdsrvnum,
                                                g_documento.atdsrvano)
                                returning ws.atdetpcod
                     if ws.atdetpcod <>  4 then
                        let g_documento.acao = "AAA"
                        call cts10n00(g_documento.atdsrvnum,
                                      g_documento.atdsrvano,
                                      g_issk.funmat        ,
                                      today ,current hour to minute)
                     end if
                  end if
                  let int_flag = false
                  exit display
               end if
            end if
         else

            # VERIFICA SE O USUARIO PODE ALTERAR O SERVICO
            if not cts00m00_permite_f8(g_documento.atdsrvnum,
                                       g_documento.atdsrvano) then
               call cts08g01("A",
                             "N",
                             "",
                             "SERVICO EM PROCESSO DE " ,
                             "ACIONAMENTO AUTOMATICO ",
                             "")
                    returning l_aciona

               let l_aciona = false
               #exit display
            else

               let l_aciona = false

               call cts40g18_srv_em_uso(g_documento.atdsrvnum,
                                        g_documento.atdsrvano )
                    returning l_aciona, ws.c24opemat

               if a_atdfnlflg[arr_aux] = "A" or ws.c24opemat = 999999 then
                  #call cts08g01("A", "N", "","SERVICO EM PROCESSO DE " ,
                  #                    "ACIONAMENTO AUTOMATICO ", "")
                  #     returning l_aciona
                   let l_aciona = false
               end if

               if ws.c24opemat = 999999 then
                  let l_aciona = true
               end if
            end if

               if cts04g00('cts00m00') = true  then
                  exit display
               end if
         end if

      end if          ## PSI 179345

      #---------------------------------------------------------------
      # Consulta impressao remota/fax pendentes
      #---------------------------------------------------------------
      on key (F10)
         call cta00m08_ver_contingencia(1)
               returning l_contingencia

         if l_contingencia then
            let int_flag = false
            exit display
         end if

         call cts00m08()
         exit display
      on key (F9)
         if  cts00m00_verifica_acesso_totalizador() then
             call cts00m41()
         end if

   end display

   if int_flag or
      param.tipo_demanda is not null  then
      exit while
   end if

 end while

 close window  cts00m00
 let int_flag = false

 if g_setexplain = 1 then
    call cts01g01_setexplain(g_issk.empcod, g_issk.funmat, 2)
 end if

 end function   ###---  cts00m00

#--------------------------------------------------------------------------
 function cts00m00_espera(param)
#--------------------------------------------------------------------------

 define param       record
    data            date,
    hora            datetime hour to minute
 end record

 define hora        record
    atual           datetime hour to second,
    h24             datetime hour to second,
    espera          char (10)
 end record

 define l_data_atual date
 initialize hora.*  to null
 ##let hora.atual = time

 # --BUSCAR A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(2)
      returning l_data_atual,
                hora.atual

 if param.data  =  l_data_atual  then
    let hora.espera = hora.atual - param.hora
 else
    let hora.h24    = "23:59:59"
    let hora.espera = hora.h24 - param.hora
    let hora.h24    = "00:00:00"
    let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
 end if

 return hora.espera

 end function   ###--- cts00m00_espera



#--------------------------------------------------------------------------
 function cts00m00_alertajit(param)
#--------------------------------------------------------------------------
 define param record
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano
 end record

 define ws          record
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    refatdsrvnum    like datmservico.atdsrvnum   ,
    refatdsrvano    like datmservico.atdsrvano   ,
    atdetpcodrem    like datketapa.atdetpcod     ,
    tempo           char (08)                    ,
    horaatu         datetime hour to minute      ,
    canpsqdat       date                         ,
    resp            char (01)                    ,
    ano4            char (04)
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 initialize ws to null

 let ws.tempo     =  time
 let ws.horaatu  =  ws.tempo[1,5]
 message " Aguarde, pesquisando..."  attribute(reverse)

 let ws.canpsqdat = today
 if ws.horaatu  <  "01:00"   then
    let ws.canpsqdat = today - 1
 end if

 if param.atdsrvnum = 0 then
   declare c_cts00m00_025 cursor for
      select datmservico.atdsrvnum,
             datmservico.atdsrvano
        from datmservico, datmsrvacp
       where datmservico.atddat   >= ws.canpsqdat
         and datmservico.atdsrvorg = 15
         and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum
         and datmsrvacp.atdsrvano  = datmservico.atdsrvano
         and datmsrvacp.atdetpcod  < 5
         and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)
                                        from datmsrvacp
                                       where atdsrvnum = datmservico.atdsrvnum
                                         and atdsrvano = datmservico.atdsrvano)

   foreach c_cts00m00_025 into  ws.atdsrvnum,
                                ws.atdsrvano

      select refatdsrvnum,
             refatdsrvano
             into ws.refatdsrvnum,
                  ws.refatdsrvano
        from datmsrvjit
       where atdsrvnum = ws.atdsrvnum
         and atdsrvano = ws.atdsrvano

      if sqlca.sqlcode = 0 then

         let ws.ano4 = "20",ws.refatdsrvano using "&&"

         select *
           from datmpedvist
          where sinvstnum = ws.refatdsrvnum
            and sinvstano = ws.ano4

         if status <> notfound then
            continue foreach
         end if

         select datmsrvacp.atdetpcod
                into ws.atdetpcodrem
           from datmsrvacp
          where atdsrvnum = ws.refatdsrvnum
            and atdsrvano = ws.refatdsrvano
            and atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp
                              where atdsrvnum = ws.refatdsrvnum
                                and atdsrvano = ws.refatdsrvano)

         if ws.atdetpcodrem <> 5 then
            continue foreach
         end if

            call cts08g01("A", "",  "Existe servico JIT com servico" ,
                                    "de remocao CANCELADO ! ",
                                    "Entre na Opcao cancelados JIT e cancele",
                                    "o servico JIT.")
                 returning ws.resp
         exit foreach
      end if
   end foreach

 else
   declare c_cts00m00_026 cursor for
      select datmservico.atdsrvnum,
             datmservico.atdsrvano
        from datmservico, datmsrvacp
       where datmservico.atddat   >= ws.canpsqdat
         and datmservico.atdsrvorg = 15
         and datmservico.atdsrvnum = param.atdsrvnum
         and datmservico.atdsrvano = param.atdsrvano
         and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum
         and datmsrvacp.atdsrvano  = datmservico.atdsrvano
         and datmsrvacp.atdetpcod  < 5
         and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)
                                        from datmsrvacp
                                       where atdsrvnum = datmservico.atdsrvnum
                                         and atdsrvano = datmservico.atdsrvano)

   foreach c_cts00m00_026 into  ws.atdsrvnum,
                                ws.atdsrvano

      select refatdsrvnum,
             refatdsrvano
             into ws.refatdsrvnum,
                  ws.refatdsrvano
        from datmsrvjit
       where atdsrvnum = ws.atdsrvnum
         and atdsrvano = ws.atdsrvano

      if sqlca.sqlcode = 0 then
         let ws.ano4 = "20",ws.refatdsrvano using "&&"

         select *
           from datmpedvist
          where sinvstnum = ws.refatdsrvnum
            and sinvstano = ws.ano4

         if status <> notfound then
            continue foreach
         end if
         select datmsrvacp.atdetpcod
                into ws.atdetpcodrem
           from datmsrvacp
          where atdsrvnum = ws.refatdsrvnum
            and atdsrvano = ws.refatdsrvano
            and atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp
                              where atdsrvnum = ws.refatdsrvnum
                                and atdsrvano = ws.refatdsrvano)

         if ws.atdetpcodrem <> 5 then
            continue foreach
         end if

            call cts08g01("A", "",  "Este servico JIT esta com o servico" ,
                                    "de remocao CANCELADO ! ",
                                    "Cancele o servico JIT.",
                                    "")
                 returning ws.resp

         exit foreach
      end if
   end foreach
 end if

end function

#--------------------------------------------------------------------------
function cts00m00_sindex(l_ufdcod, l_cidnom, l_atdsrvorg,
                         l_lclltt, l_lcllgt, l_c24lclpdrcod)
#--------------------------------------------------------------------------

   define l_ufdcod        like datkmpacid.ufdcod,
          l_cidnom        like datkmpacid.cidnom,
          l_atdsrvorg     like datmservico.atdsrvorg,
          l_lclltt        like datmlcl.lclltt,
          l_lcllgt        like datmlcl.lcllgt,
          l_c24lclpdrcod  like datmlcl.c24lclpdrcod

   define lr_cts40g00    record
         resultado    smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
         mensagem     char(100),
         acnlmttmp    like datkatmacnprt.acnlmttmp,
         acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
         netacnflg    like datkatmacnprt.netacnflg,
         atmacnprtcod like datkatmacnprt.atmacnprtcod
   end record

   define lr_cts41g03   record
          resultado     smallint,
          mensagem      char(70),
          gpsacngrpcod  like datkmpacid.gpsacngrpcod,
          mpacidcod     like datkmpacid.mpacidcod
   end record

   initialize lr_cts40g00.* to null
   initialize lr_cts41g03.* to null

   # Coordenadas nulas
   if l_lclltt is null or l_lcllgt is null then
      return "S/INDEX"
   end if

   # Coordenada por logradouro
   if l_c24lclpdrcod = 3 then
      return ""
   end if

   # Coordenada por Bairro
   if l_c24lclpdrcod = 4 then
      return ""
   end if

   # Coordenada por Subbairro
   if l_c24lclpdrcod = 5 then
      return ""
   end if

   call cts40g00_obter_parametro(l_atdsrvorg)
       returning lr_cts40g00.*

   call cts41g03_tipo_acion_cidade(l_cidnom, l_ufdcod,
                                   lr_cts40g00.atmacnprtcod,l_atdsrvorg)
        returning lr_cts41g03.*

   if lr_cts41g03.gpsacngrpcod > 0 then  # Acionamento GPS

      ## SOLICITADO PARA APRESENTAR NO RADIO SEM INDEXACAO
      #if cts40g12_gpsacncid(l_cidnom, l_ufdcod) then  # Verifica se o acionamento GPS pode ser realizado pela coordenada da Cidade
      #   return "IDX CID"
      #else
         return "S/INDEX"
      #end if

   end if

   return ""

end function

#========================================#
function cts00m00_permite_f8(lr_parametro)
#========================================#

  define lr_parametro    record
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano
  end record

  define l_status        smallint,
         l_atdsrvnum_org like datmservico.atdsrvnum,
         l_atdsrvano_org like datmservico.atdsrvano,
         l_atdfnlflg     like datmservico.atdfnlflg,
         l_c24opemat     like datmservico.c24opemat,
         l_permite_f8    smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_status  =  null
        let     l_atdsrvnum_org  =  null
        let     l_atdsrvano_org  =  null
        let     l_atdfnlflg  =  null
        let     l_c24opemat  =  null
        let     l_permite_f8  =  null

  if m_cts00m00_prep is null or
     m_cts00m00_prep <> true then
     call cts00m00_prepare()
  end if

  let l_permite_f8 = true
  ##------------------------------
  # VERIFICA SE O SERVICO E APOIO
  #------------------------------
  let l_status = cts37g00_existeServicoApoio(lr_parametro.atdsrvnum,
                                             lr_parametro.atdsrvano)

  if l_status = 3 then # SERVICO DE APOIO
     #-------------------------
     # BUSCA O SERVICO ORIGINAL
     #-------------------------
     call cts37g00_buscaServicoOriginal(lr_parametro.atdsrvnum,
                                        lr_parametro.atdsrvano)

          returning l_status,
                    l_atdsrvnum_org, # NUMERO SERVICO ORIGINAL
                    l_atdsrvano_org  # ANO SERVICO ORIGINAL

     if l_status <> 0 then
        error "Erro ao chamar a funcao cts37g00_buscaServicoOriginal()" sleep 5
     else

        # BUSCA atdfnlflg e c24opemat DO SERVICO ORIGINAL
        open c_cts00m00_019 using l_atdsrvnum_org, l_atdsrvano_org
        fetch c_cts00m00_019 into l_atdfnlflg, l_c24opemat
        close c_cts00m00_019

        if l_atdfnlflg = "A" or
           l_c24opemat = 999999 then
           let l_permite_f8 = false
        end if
     end if
  end if

  return l_permite_f8

end function

#================================#
function cts00m00_informa_filtro()
#================================#

  define lr_hora       record
         qtdsrv        smallint,
         ciaempcod     like datmservico.ciaempcod,
         empnom        char(20),
         inicioH       smallint,
         inicioM       smallint,
         fimH          smallint,
         fimM          smallint,
         empauxpor     char(1),
         empauxazu     char(1),
         empauxita     char(1),
         empauxvid     char(1),
         empauxpro     char(1),
         empauxsau     char(1),
         empauxcar     char(1),
         empauxpss     char(1)
  end record

  define lr_formatacao record
         inicioN       char(05),
         fimN          char(05),
         inicioH       datetime hour to minute,
         fimH          datetime hour to minute
  end record

  define l_resposta     char(01),
         l_resultado    smallint,
         l_mensagem     char(50)

  # empresas atendidas pelo socorrista
  define lr_empatdsrr  record
     empaux     char(30)
  end record


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resposta  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_hora.*  to  null

        initialize  lr_formatacao.*  to  null


  initialize lr_hora, lr_formatacao to null

  let lr_hora.empauxpor = 'X'
  let lr_hora.empauxazu = 'X'
  let lr_hora.empauxita = 'X'
  let lr_hora.empauxvid = 'X'
  let lr_hora.empauxpro = 'X'
  let lr_hora.empauxsau = 'X'
  let lr_hora.empauxcar = 'X'
  let lr_hora.empauxpss = ' '

  open window w_cts00m00a at 6,13 with form "cts00m00a"
     attribute(border, form line 1)

  let lr_hora.empnom = 'TODAS'

  whenever error continue
     select grlinf into lr_hora.qtdsrv
       from datkgeral
      where grlchv = "RADIO-QTDSRV"

     if sqlca.sqlcode <> 0 then
        let lr_hora.qtdsrv = 100
     end if
  whenever error stop

  #display by name lr_hora.empnom

  input by name lr_hora.qtdsrv,
                lr_hora.empauxpor,
                lr_hora.empauxazu,
                lr_hora.empauxita,
                lr_hora.empauxvid,
                lr_hora.empauxpro,
                lr_hora.empauxsau,
                lr_hora.empauxcar,
                lr_hora.empauxpss,
                lr_hora.inicioH,
                lr_hora.inicioM,
                lr_hora.fimH,
                lr_hora.fimM
                without defaults

     before input
        next field inicioH

     before field qtdsrv
        display by name lr_hora.qtdsrv attribute(reverse)

     after field qtdsrv
        display by name lr_hora.qtdsrv

     before field empauxpor
        display by name lr_hora.empauxpor attribute(reverse)

     after field empauxpor

        if  lr_hora.empauxpor is not null and
            lr_hora.empauxpor <> " "      and
            lr_hora.empauxpor <> "X"      then
            let lr_hora.empauxpor = " "
            error "Op��o invalida, Marque com X ou desmarque a op��o desejada."
            next field empauxpor
        end if

        display by name lr_hora.empauxpor

     before field empauxazu
        display by name lr_hora.empauxazu attribute(reverse)

     after field empauxazu

        if  lr_hora.empauxazu is not null and
            lr_hora.empauxazu <> " "      and
            lr_hora.empauxazu <> "X"      then
            let lr_hora.empauxazu = " "
            error "Op��o invalida, Marque com X ou desmarque a op��o desejada."
            next field empauxazu
        end if

        display by name lr_hora.empauxazu

     before field empauxita
        display by name lr_hora.empauxita attribute(reverse)

     after field empauxita

        if  lr_hora.empauxita is not null and
            lr_hora.empauxita <> " "      and
            lr_hora.empauxita <> "X"      then
            let lr_hora.empauxita = " "
            error "Op��o invalida, Marque com X ou desmarque a op��o desejada."
            next field empauxita
        end if

        display by name lr_hora.empauxazu

      before field empauxvid
        display by name lr_hora.empauxvid attribute(reverse)

     after field empauxvid

        if  lr_hora.empauxvid is not null and
            lr_hora.empauxvid <> " "      and
            lr_hora.empauxvid <> "X"      then
            let lr_hora.empauxvid = " "
            error "Op��o invalida, Marque com X ou desmarque a op��o desejada."
            next field empauxvid
        end if

        display by name lr_hora.empauxvid

     before field empauxpro
        display by name lr_hora.empauxpro attribute(reverse)

     after field empauxpro

        if  lr_hora.empauxpro is not null and
            lr_hora.empauxpro <> " "      and
            lr_hora.empauxpro <> "X"      then
            let lr_hora.empauxpro = " "
            error "Op��o invalida, Marque com X ou desmarque a op��o desejada."
            next field empauxpro
        end if

        display by name lr_hora.empauxpro

     #BURINI
     before field empauxsau
        display by name lr_hora.empauxsau attribute(reverse)

     after field empauxsau
        display by name lr_hora.empauxsau

     before field empauxcar
        display by name lr_hora.empauxcar attribute(reverse)

     after field empauxcar
        display by name lr_hora.empauxcar

     before field empauxpss
        display by name lr_hora.empauxpss attribute(reverse)

     after field empauxpss
        display by name lr_hora.empauxpss

        if  (lr_hora.empauxpor is null or lr_hora.empauxpor = " ") and
            (lr_hora.empauxazu is null or lr_hora.empauxazu = " ") and
            (lr_hora.empauxita is null or lr_hora.empauxita = " ") and
            (lr_hora.empauxvid is null or lr_hora.empauxvid = " ") and
            (lr_hora.empauxpro is null or lr_hora.empauxpro = " ") and
            (lr_hora.empauxsau is null or lr_hora.empauxsau = " ") and
            (lr_hora.empauxcar is null or lr_hora.empauxcar = " ") and
            (lr_hora.empauxpss is null or lr_hora.empauxpss = " ") then
            error "� obrigat�rio informar no m�nimo uma empresa para filtro."
            next field empauxpor
        end if

     #BURINI

     before field inicioH
        display by name lr_hora.inicioH attribute(reverse)

     after field inicioH
        display by name lr_hora.inicioH

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field empauxpss
        end if

        if lr_hora.inicioH is null then
           let lr_hora.inicioH = 00
           let lr_hora.inicioM = 00
           display by name lr_hora.inicioH, lr_hora.inicioM
           next field fimH
        end if

        if lr_hora.inicioH > 23 or
           lr_hora.inicioH < 0 then
           let lr_hora.inicioH = null
           next field inicioH
        end if

     before field inicioM
        display by name lr_hora.inicioM attribute(reverse)

     after field inicioM
        display by name lr_hora.inicioM

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field inicioH
        end if

        if lr_hora.inicioM is null then
           next field inicioM
        end if

        if lr_hora.inicioM > 59 or
           lr_hora.inicioM < 0 then
           let lr_hora.inicioM = null
           next field inicioM
        end if

     before field fimH
        display by name lr_hora.fimH attribute(reverse)

     after field fimH
        display by name lr_hora.fimH

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field inicioM
        end if

        if lr_hora.fimH is null then

           let lr_hora.fimH = 23
           let lr_hora.fimM = 59

           display by name lr_hora.fimH, lr_hora.fimM

           let l_resposta = cts00m00_confirma()

           if l_resposta = "N" then
              next field inicioH
           else

              let lr_formatacao.inicioN = lr_hora.inicioH using "&&",
                                          ":",
                                          lr_hora.inicioM using "&&"

              let lr_formatacao.fimN    = lr_hora.fimH using "&&",
                                          ":",
                                          lr_hora.fimM using "&&"

              let lr_formatacao.inicioH = lr_formatacao.inicioN
              let lr_formatacao.fimH    = lr_formatacao.fimN

              exit input
           end if
        end if

        if lr_hora.fimH > 59 or
           lr_hora.fimH < 0 then
           let lr_hora.fimH = null
           next field fimH
        end if

     before field fimM
        display by name lr_hora.fimM attribute(reverse)

     after field fimM
        display by name lr_hora.fimM

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field fimH
        end if

        if lr_hora.fimM is null then
           next field fimM
        end if

        if lr_hora.fimM > 59 or
           lr_hora.fimM < 0 then
           let lr_hora.fimM = null
           next field fim
        end if

        let lr_formatacao.inicioN = lr_hora.inicioH using "&&",
                                    ":",
                                    lr_hora.inicioM using "&&"

        let lr_formatacao.fimN    = lr_hora.fimH using "&&",
                                    ":",
                                    lr_hora.fimM using "&&"

        let lr_formatacao.inicioH = lr_formatacao.inicioN
        let lr_formatacao.fimH    = lr_formatacao.fimN

        if lr_formatacao.fimH < lr_formatacao.inicioH then
            error "Hora final menor que a hora inicial !"
            let lr_hora.fimH = null
            let lr_hora.fimM = null
            display by name lr_hora.fimM
            next field fimH
        end if

        let l_resposta = cts00m00_confirma()

        if l_resposta = "N" then
           next field inicioH
        end if

     on key(control-c, interrupt, accept)

        call cts00m00_todo_dia()
             returning lr_formatacao.inicioH, lr_formatacao.fimH
             exit input

  end input

  close window w_cts00m00a

  let lr_empatdsrr.empaux = null

  if lr_hora.empauxpor = 'X' then
     let lr_empatdsrr.empaux = '1'
  end if

  if lr_hora.empauxazu = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',35'
     else
        let lr_empatdsrr.empaux = '35'
     end if
  end if

  if lr_hora.empauxita = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',84'
     else
        let lr_empatdsrr.empaux = '84'
     end if
  end if

  if lr_hora.empauxvid = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',14'
     else
        let lr_empatdsrr.empaux = '14'
     end if
  end if

  if lr_hora.empauxpro = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',27'
     else
        let lr_empatdsrr.empaux = '27'
     end if
  end if

  if lr_hora.empauxsau = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',50'
     else
        let lr_empatdsrr.empaux = '50'
     end if
  end if

  if lr_hora.empauxcar = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',40'
     else
        let lr_empatdsrr.empaux = '40'
     end if
  end if

  if lr_hora.empauxpss = 'X' then
     if lr_empatdsrr.empaux is not null then
        let lr_empatdsrr.empaux = lr_empatdsrr.empaux clipped,',43'
     else
        let lr_empatdsrr.empaux = '43'
     end if
  end if

  let int_flag = false

  return lr_formatacao.inicioH, lr_formatacao.fimH, lr_hora.qtdsrv, lr_empatdsrr.empaux

end function

#==========================#
function cts00m00_todo_dia()
#==========================#

  define l_inicio datetime hour to minute,
         l_fim    datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_inicio  =  null
        let     l_fim  =  null

  let l_inicio = "00:00"
  let l_fim    = "23:59"

  return l_inicio, l_fim

end function

#==========================#
function cts00m00_confirma()
#==========================#

  define l_resposta char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resposta  =  null

  let l_resposta = "E"

  while l_resposta <> "S" and l_resposta <> "N"

     prompt "Confirma ?:" for l_resposta

     let l_resposta = upshift(l_resposta)

     if l_resposta is null or
        l_resposta = " " then
        let l_resposta = "E"
     end if

  end while

  return l_resposta

end function

function cts00m00_exibe_motivo(l_motivo)

   define l_motivo char(50)



   if l_motivo is not null then

      open window t_motivo at 10,10
           with 3 rows, 55 columns attribute(border, prompt line 2)

      let l_motivo = " Motivo: ", l_motivo clipped
      prompt l_motivo for l_motivo
      close window t_motivo
      let int_flag = false

   end if

end function

 #PSI 232700 - ligia - 14/11/08
function cts00m00_exibe_srv(l_atdsrvnum, l_atdsrvano)

   define l_atdsrvnum   like datmservico.atdsrvnum,
          l_atdsrvano   like datmservico.atdsrvano,
          l_exibe_srv   char(1),
          l_resultado   smallint,
          l_mensagem    char(40),
          l_atmacnflg   like datkassunto.atmacnflg

   define lr_cts10g06 record
          c24astcod like datmligacao.c24astcod
         ,c24funmat like datmligacao.c24funmat
         ,c24empcod like datmligacao.c24empcod
   end record

   initialize lr_cts10g06.* to null
   let l_exibe_srv = null
   let l_atmacnflg = null
   let l_resultado = null
   let l_mensagem = null

   call cts10g06_assunto_servico(l_atdsrvnum
                                ,l_atdsrvano)
        returning l_resultado, l_mensagem, lr_cts10g06.*

   call cts25g00_dados_assunto(4,lr_cts10g06.c24astcod)
         returning l_resultado
                  ,l_mensagem
                  ,l_atmacnflg

   if l_atmacnflg = "S" then
      let l_exibe_srv = true
   else
      let l_exibe_srv = false
   end if

   return l_exibe_srv

end function

#-----------------------------------------------#
 function cts00m00_verifica_acesso_totalizador()
#-----------------------------------------------#
  define l_status smallint
  whenever error continue
  open ccts00m00036 using g_issk.funmat
  fetch ccts00m00036 into l_status
  whenever error stop
  if  sqlca.sqlcode = 0 then
      return true
  end if
  return false
 end function

#------------------------------------------#
 function cts00m00_verifica_acesso_lstsrv()
#------------------------------------------#
  define l_status smallint
  whenever error continue
  open ccts00m00037 using g_issk.funmat
  fetch ccts00m00037 into l_status
  whenever error stop
  if  sqlca.sqlcode = 0 then
      return true
  end if
  return false
 end function 
 
#-----------------------------------------------#
 function cts00m00_verifica_acesso_menu()
#-----------------------------------------------#
  define l_status smallint,
         l_chavematricula char(10)

  initialize l_status, l_chavematricula to null

  if m_cts00m00_prep is null or
     m_cts00m00_prep <> true then
     call cts00m00_prepare()
  end if

  # Se o AcionamentoWeb esta desligado libera acesso ao menu RADIO
  if not ctx34g00_ver_acionamentoWEB(2) then
      return true
  end if

  whenever error continue
  let l_chavematricula = g_issk.empcod using "<<&", ",", g_issk.funmat using "<<<<<<<<<&"
  open ccts00m00041 using l_chavematricula
  fetch ccts00m00041 into l_status
  if  sqlca.sqlcode = 0 then
      whenever error stop
      return true
  end if
  whenever error stop
  return false
 end function
 
#===============================================#
 function cts00m00_verifica_acionamento_carga ()
#================================================#
define l_cpodes like datkdominio.cpodes
define l_atlult like datkdominio.atlult
define lr_retorno record
       atldat     char (10),
       atlhor     char (05),
       atlemp     like isskfunc.empcod,
       atlmat     like isskfunc.funmat,
       atlfunnom  like isskfunc.funnom
end record
let l_cpodes = null
let l_atlult = null
initialize lr_retorno.* to null
  open ccts00m00039
  fetch ccts00m00039 into l_cpodes,
                          l_atlult
  close ccts00m00039
 let lr_retorno.atldat = l_atlult[5,6],"/",
                         l_atlult[3,4],"/",
                         l_atlult[1,2]
 let lr_retorno.atlhor = l_atlult[7,8],":",
                         l_atlult[9,10]
 let lr_retorno.atlemp = l_atlult[12,13]
 let lr_retorno.atlmat = l_atlult[14,19]
 open ccts00m00040 using lr_retorno.atlemp,
                         lr_retorno.atlmat
  fetch ccts00m00040 into lr_retorno.atlfunnom
 close ccts00m00040
 let lr_retorno.atlfunnom = upshift(lr_retorno.atlfunnom)
 return l_cpodes,
        lr_retorno.atldat,
        lr_retorno.atlhor,
        lr_retorno.atlfunnom
end function