#------------------------------------------------------------------------------
# Nome do Modulo: cts06m09                                         Marcelo
#                                                                  Gilberto
# Controle de vistorias previas pendentes - RADIO                  Mar/1998
#------------------------------------------------------------------------------
# Alteracoes:
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO
#------------------------------------------------------------------------------
# 06/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados
#                                       atraves do guia postal
#------------------------------------------------------------------------------
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ultima
#                                       etapa do servico
#------------------------------------------------------------------------------
# 26/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo
#                                       atdsrvnum de 6 p/ 10
#                                       Troca do campo atdtip p/ atdsrvorg
#------------------------------------------------------------------------------
# 19/07/2006  Adriano, Meta Migracao    Migracao de versao do 4gl
#------------------------------------------------------------------------------
# 13/08/2009  Sergio Burini 244236      Inclusao do Sub-Bairro
#------------------------------------------------------------------------------
# 07/07/2013  PSI-2013-01385            Refactoring para substituir a tela
#             Carlos Zyon               moto_GPS
#------------------------------------------------------------------------------
# 07/07/2015  SPR-2015-13757           -Inclusao do acionamento para clientes
#             Carlos Zyon               VPOnline
#                                      -Alteracao para exibir prestadores com
#                                       base como funcionarios
#                                      -Alteracao para nao considerar o tipo de
#                                       acionamento automatico para prestadores
#------------------------------------------------------------------------------
# 15/10/2015  SPR-2015-SET             -Inclusao do filtro Auto-Premium [F9]
#             Fornax                   -Inclusao da cons hist regras [F10]
#------------------------------------------------------------------------------
# 04/04/2016  VP-Online-2.0 (Item 1.3) -Incluir filtro "X" na tela.
#             Fornax, RCP              -Incluir teclas de funcao Ctrl+A,Ctrl+P.
#------------------------------------------------------------------------------

globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_mensagem           char(70)
define m_cts06m09_prepare   char(01)
define mr_vponline record
    SiglaVeiculo            like datkveiculo.atdvclsgl
   ,NumeroDias              smallint
end record

define m_strsql_original     char(3000)
define m_strsql_vponline     char(3000)
define m_strsql_pcts06m09002 char(3000)

#--------------------------------------------
# Array com os dados principais das vistorias
# selecionadas para acionamento
#--------------------------------------------
define ma_aciona array[10] of record
    NumeroServico           like datmservico.atdsrvnum
   ,AnoServico              like datmservico.atdsrvano
   ,NumeroVistoria          like datmvistoria.vstnumdig
   ,DataVistoria            like datmvistoria.vstdat
   ,UF                      like datmlcl.ufdcod
   ,NomeCidade              like datmlcl.cidnom
   ,NomeBairro              like datmlcl.brrnom
   ,NomeSubBairro           like datmlcl.lclbrrnom
   ,Endereco                char(50)
end record

#----------------------------------------
# Array com os dados exibidos na tela das
# vistorias selecionadas para acionamento
#----------------------------------------
define ma_telacn array[10] of record
    DiaMesVistoria          char(05)
   ,Prioridade              like datmservico.atdprinvlcod
   ,CodigoEmpresa           like datmservico.ciaempcod
   ,EnderecoExibicao        char(50)
   ,HorarioPref             like datmvistoria.prfhor
end record

#----------------------------------
# Sigla do veiculo para acionamento
#----------------------------------
define mr_veiculo record
    SiglaVeiculo            like datkveiculo.atdvclsgl
   ,SiglaVeiculoAnterior    like datkveiculo.atdvclsgl
end record

function cts06m09_prepare()

    define l_strsql char(3000)

    #-----------------------------
    # Verifica se a empresa existe
    #-----------------------------
    let l_StrSql = ' select 1 '
                  ,'   from gabkemp '
                  ,'  where empcod = ? '
    prepare pcts06m09001 from l_strsql
    declare ccts06m09001 cursor for pcts06m09001

    #-------------------------------------------------------
    # Recupera as marcacoes de vistoria previa nao acionadas
    #-------------------------------------------------------
    let m_strsql_original =
                   ' select s.atdsrvnum '
                  ,'       ,s.atdsrvano '
                  ,'       ,v.vstnumdig '
                  ,'       ,v.vstdat '
                  ,'       ,to_char(extend(v.vstdat),"%d/%m") '
                  ,'        as diamesvst '
                  ,'       ,s.atdprinvlcod '
                  ,'       ,s.ciaempcod '
                  ,'       ,l.ufdcod '
                  ,'       ,l.cidnom '
                  ,'       ,l.brrnom '
                  ,'       ,l.lclbrrnom '
                  ,'       ,trim(l.lgdtip) || " " || '
                  ,'        trim(l.lgdnom) || " " || '
                  ,'        l.lgdnum as endereco '
                  ,'       ,v.prfhor '
                  ,'   from datmservico s '
                  ,'       ,datmvistoria v '
                  ,'       ,datmlcl l '
                  ,'  where s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.c24endtip = 1 '
                  ,'    and s.atdlibflg = "S" '
                  ,'    and s.atdfnlflg = "N" '
                  ,'    and ((v.vstdat >= ? and v.vstdat <= ?) or 1=?) '
                  ,'    and (s.atdprinvlcod = ? or 1=?) '
                  ,'    and (s.ciaempcod = ? or 1=? ) '
                  ,'    and (l.ufdcod = ? or 1=?) '
                  ,'    and (l.cidnom = ? or 1=?) '
                  ,'    and (l.brrnom = ? or 1=?) '
                  ,'    and (v.vstnumdig = ? or 1=?) '
                  ,'    and (v.eslutocliindflg = "S" or 1=?) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = v.atdsrvano '
                  ,'          and c.atdsrvnum = v.atdsrvnum) '
                  ,'  order by v.vstdat '
                  ,'          ,s.atdprinvlcod desc '
                  ,'          ,l.ufdcod '
                  ,'          ,l.cidnom '
                  ,'          ,l.brrnom '

    #---------------------------------------------------------
    # Recupera as marcacoes de VP para FiltroX (VP-Online-2.0)
    #---------------------------------------------------------
    let m_strsql_vponline =
                   ' select s.atdsrvnum '
                  ,'       ,s.atdsrvano '
                  ,'       ,v.vstnumdig '
                  ,'       ,v.vstdat '
                  ,'       ,to_char(extend(v.vstdat),"%d/%m") '
                  ,'        as diamesvst '
                  ,'       ,s.atdprinvlcod '
                  ,'       ,s.ciaempcod '
                  ,'       ,l.ufdcod '
                  ,'       ,l.cidnom '
                  ,'       ,l.brrnom '
                  ,'       ,l.lclbrrnom '
                  ,'       ,trim(l.lgdtip) || " " || '
                  ,'        trim(l.lgdnom) || " " || '
                  ,'        l.lgdnum as endereco '
                  ,'       ,v.prfhor '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'       ,datmlcl l '
                  ,'  where k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.c24endtip = 1 '
                  ,'    and ((v.vstdat >= ? and v.vstdat <= ?) or 1=?) '
                  ,'    and (s.atdprinvlcod = ? or 1=?) '
                  ,'    and (s.ciaempcod = ? or 1=? ) '
                  ,'    and (l.ufdcod = ? or 1=?) '
                  ,'    and (l.cidnom = ? or 1=?) '
                  ,'    and (l.brrnom = ? or 1=?) '
                  ,'    and (v.vstnumdig = ? or 1=?) '
                  ,'    and (v.eslutocliindflg = "S" or 1=?) '
                  ,'    and a.atdsrvseq = '
                  ,'      (select max(u.atdsrvseq) '
                  ,'         from datmsrvacp u '
                  ,'        where u.atdsrvano = s.atdsrvano '
                  ,'          and u.atdsrvnum = s.atdsrvnum '
                  ,'          and u.atdetpcod <> 39  '
                  ,'          and u.atdetpcod <> 42) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '

    #---------------------------
    # Recupera a sigla do estado
    #---------------------------
    let l_strsql = ' select g.ufdcod '
                  ,'   from glakest g '
                  ,'  where g.ufdcod = ? '
    prepare pcts06m09003 from l_strsql
    declare ccts06m09003 cursor for pcts06m09003

    #----------------------------
    # Recupera o codigo da cidade
    #----------------------------
    let l_strsql = ' select c.cidcod '
                  ,'   from glakcid c '
                  ,'  where c.ufdcod = ? '
                  ,'    and c.cidnom = ? '
    prepare pcts06m09004 from l_strsql
    declare ccts06m09004 cursor for pcts06m09004

    #-----------------------------------------------------------------
    # Recupera informacoes complementares da vistoria para info rapida
    #-----------------------------------------------------------------
    let l_strsql = ' select s.atdsrvorg '
                  ,'       ,v.c24solnom '
                  ,'       ,v.c24soltipcod '
                  ,'       ,t.c24soltipdes '
                  ,'       ,d1.cpodes as descpri '
                  ,'       ,s.ciaempcod '
                  ,'       ,g.empnom '
                  ,'       ,v.vstfld '
                  ,'       ,d2.vstcpodomdes as descfin '
                  ,'       ,v.vcllicnum '
                  ,'       ,v.vclchsnum '
                  ,'       ,v.vclrnvnum '
                  ,'       ,s.vclcoddig '
                  ,'       ,trim(v.vclmrcnom) || " " || '
                  ,'        trim(v.vcltipnom) || " " || '
                  ,'        trim(v.vclmdlnom) as descveic '
                  ,'       ,d3.cpodes as descorveic '
                  ,'       ,v.vclanofbc '
                  ,'       ,v.vclanomdl '
                  ,'       ,lpad(trim(l.lgdcep),5,"0") || "-" || '
                  ,'        lpad(l.lgdcepcmp,3,"0") as cep '
                  ,'       ,l.endcmp '
                  ,'       ,trim(l.celteldddcod) || "-" || '
                  ,'        l.celtelnum as numcel '
                  ,'       ,l.lclrefptotxt '
                  ,'       ,trim(l.dddcod) || "-" || '
                  ,'        l.lcltelnum as numtel '
                  ,'       ,v.corsus '
                  ,'       ,(select c3.cornom '
                  ,'           from gcakfilial c1 '
                  ,'               ,gcaksusep c2 '
                  ,'               ,gcakcorr c3 '
                  ,'          where c2.corsus = v.corsus '
                  ,'            and c2.corsuspcp = c1.corsuspcp '
                  ,'            and c1.corfilnum = 1 '
                  ,'            and c3.corsuspcp = c1.corsuspcp) '
                  ,'        as nomecorretor '
                  ,'       ,trim(v.cordddcod) || "-" || '
                  ,'        v.cortelnum as telcorretor '
                  ,'       ,v.segnom '
                  ,'       ,v.pestip '
                  ,'       ,case v.pestip '
                  ,'          when "F" then '
                  ,'            v.cgccpfnum '
                  ,'            || "-" || '
                  ,'            lpad(v.cgccpfdig,2,"0") '
                  ,'          when "J" then '
                  ,'             v.cgccpfnum '
                  ,'             || "/" || '
                  ,'             lpad(v.cgcord,4,"0") '
                  ,'             || "-" || '
                  ,'             lpad(v.cgccpfdig,2,"0") '
                  ,'          else '
                  ,'             v.cgccpfnum '
                  ,'             || v.cgcord '
                  ,'             || v.cgccpfdig '
                  ,'        end cgccpf '
                  ,'       ,l.lclcttnom '
                  ,'       ,v.segematxt '
                  ,'   from datmservico s '
                  ,'       ,datmvistoria v '
                  ,'       ,datmlcl l '
                  ,'       ,outer datksoltip t '
                  ,'       ,outer iddkdominio d1 '
                  ,'       ,outer avlkdomcampovst d2 '
                  ,'       ,outer iddkdominio d3 '
                  ,'       ,outer gabkemp g '
                  ,'  where s.atdsrvnum = ? '
                  ,'    and s.atdsrvano = ? '
                  ,'    and v.atdsrvnum = s.atdsrvnum '
                  ,'    and v.atdsrvano = s.atdsrvano '
                  ,'    and l.atdsrvnum = s.atdsrvnum '
                  ,'    and l.atdsrvano = s.atdsrvano '
                  ,'    and l.c24endtip = 1 '
                  ,'    and t.c24soltipcod = v.c24soltipcod '
                  ,'    and d1.cpocod = s.atdprinvlcod '
                  ,'    and d1.cponom = "atdprinvlcod" '
                  ,'    and d2.vstcpocod = 1 '
                  ,'    and d2.atlult not like "%DEL%" '
                  ,'    and d2.vstcpodomcod = v.vstfld '
                  ,'    and d3.cpocod = s.vclcorcod '
                  ,'    and d3.cponom = "vclcorcod" '
                  ,'    and g.empcod  = s.ciaempcod '
    prepare pcts06m09005 from l_strsql
    declare ccts06m09005 cursor for pcts06m09005

    #-----------------------------------------------------------------------
    # Recupera as coordenadas do local ou do bairro para lista de inspetores
    #-----------------------------------------------------------------------
    let l_strsql = ' select case when (l.lclltt<>0) '
                  ,'        then l.lclltt '
                  ,'        else b.lclltt end latitude '
                  ,'       ,case when (l.lcllgt<>0) '
                  ,'        then l.lcllgt '
                  ,'        else b.lcllgt end longitude '
                  ,'       ,case when (l.lclltt<>0 and l.lcllgt<>0) '
                  ,'        then "L" '
                  ,'        else "B" end origem '
                  ,'   from datmlcl l '
                  ,'       ,datkmpabrr b '
                  ,'       ,glakcid c '
                  ,'  where l.atdsrvnum = ? '
                  ,'    and l.atdsrvano = ? '
                  ,'    and l.c24endtip = 1 '
                  ,'    and c.ufdcod = l.ufdcod '
                  ,'    and c.cidnom = l.cidnom '
                  ,'    and b.brrnom = l.brrnom '
                  ,'    and b.mpacidcod = c.cidcod '
    prepare pcts06m09006 from l_strsql
    declare ccts06m09006 cursor for pcts06m09006

    #-----------------------------------------------------------
    # Recupera informacoes da vistoria para lista de prestadores
    #-----------------------------------------------------------
    let l_strsql = ' select s.ciaempcod '
                  ,'       ,weekday(v.vstdat) '
                  ,'       ,c.cidcod '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmlcl l '
                  ,'       ,glakcid c '
                  ,'  where s.atdsrvnum = ? '
                  ,'    and s.atdsrvano = ? '
                  ,'    and v.atdsrvnum = s.atdsrvnum '
                  ,'    and v.atdsrvano = s.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.c24endtip = 1 '
                  ,'    and c.ufdcod = l.ufdcod '
                  ,'    and c.cidnom = l.cidnom '
    prepare pcts06m09007 from l_strsql
    declare ccts06m09007 cursor for pcts06m09007

    #-----------------------------------------------------------------
    # Recupera as 20 bases palm (inspetores) mais proximas da vistoria
    #-----------------------------------------------------------------
    let l_strsql = ' select first 20 '
                  ,'        p.atdvclsgl '
                  ,'       ,i.vstinpnom '
                  ,'       ,p.plmbasendbrr '
                  ,'       ,round(sqrt(pow(((?*108) '
                  ,'        -(p.plmbaslgt*108)),2) '
                  ,'        + pow(((?*108) '
                  ,'        -(p.plmbasltt*108)),2)),2) '
                  ,'        as distkm '
                  ,'       ,p.klmqtd '
                  ,'       ,p.plmbaslgt '
                  ,'       ,p.plmbasltt '
                  ,'   from avckplmidt p '
                  ,'       ,avckinsp i '
                  ,'  where p.plmbasltt is not null '
                  ,'    and p.plmbaslgt is not null '
                  ,'    and p.plmsit = "A" '
                  ,'    and p.atdtip = "R" '
                  ,'    and p.atdvclsgl like "X%" '
                  ,'    and i.vstinpcod = p.vstinpcod '
                  ,'    and i.vstinpstt = "A" '
              ####,'    and i.vintipcod = "F" '
                  ,'    and exists '
                  ,'       (select 1 '
                  ,'          from datkveiculo v1 '
                  ,'              ,datrvclemp  e1 '
                  ,'         where v1.atdvclsgl = p.atdvclsgl '
                  ,'           and e1.socvclcod = v1.socvclcod '
                  ,'           and e1.ciaempcod = ?) '
                  ,'    and exists '
                  ,'       (select 1 '
                  ,'          from datkveiculo v2 '
                  ,'              ,dparpstemp  e2 '
                  ,'         where v2.atdvclsgl = p.atdvclsgl '
                  ,'           and e2.pstcoddig = v2.pstcoddig '
                  ,'           and e2.ciaempcod = ?) '
                  ,'  order by distkm '
    prepare pcts06m09008 from l_strsql
    declare ccts06m09008 cursor for pcts06m09008

    #--------------------------------------------------------------
    # Recupera as 10 bases de prestadores mais proximas da vistoria
    #--------------------------------------------------------------
    let l_strsql = ' select first 10 '
                  ,'        p.atdvclsgl '
                  ,'       ,p.vstpstnom '
                  ,'       ,b.cidnom '
                  ,'       ,c.ciddcakmsqtd '
                  ,'   from avckpstcid c '
                  ,'       ,avckposto p '
                  ,'       ,glakcid b '
                  ,'  where c.srvorgcod = 10 '
                  ,'    and c.cidcod = ? '
                  ,'    and c.empcod in (?,99) '
                  ,'    and c.smndianum in (?,99) '
              ####,'    and c.atmacntipcod = 1 '
                  ,'    and c.atoregflg = "A" '
                  ,'    and p.vstpstcod = c.pstcod '
                  ,'    and p.vstpststt = "A" '
                  ,'    and b.cidcod = c.bascidcod '
                  ,'    and exists '
                  ,'       (select 1 '
                  ,'          from datkveiculo v1 '
                  ,'              ,datrvclemp  e1 '
                  ,'         where v1.atdvclsgl = p.atdvclsgl '
                  ,'           and e1.socvclcod = v1.socvclcod '
                  ,'           and e1.ciaempcod = ?) '
                  ,'    and exists '
                  ,'       (select 1 '
                  ,'          from datkveiculo v2 '
                  ,'              ,dparpstemp  e2 '
                  ,'         where v2.atdvclsgl = p.atdvclsgl '
                  ,'           and e2.pstcoddig = v2.pstcoddig '
                  ,'           and e2.ciaempcod = ?) '
                  ,'  order by c.ciddcakmsqtd asc '
                  ,'          ,c.pstcod asc '
    prepare pcts06m09009 from l_strsql
    declare ccts06m09009 cursor for pcts06m09009

    #--------------------------------------------------------
    # Recupera o numero de vistorias acionadas para o veiculo
    #--------------------------------------------------------
    let l_strsql = ' select count(*) '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'  where v.vstdat = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
                  ,'    and a.atdsrvseq = '
                  ,'      (select max(u.atdsrvseq) '
                  ,'         from datmsrvacp u '
                  ,'        where u.atdsrvano = s.atdsrvano '
                  ,'          and u.atdsrvnum = s.atdsrvnum '
                  ,'          and u.atdetpcod <> 39  '
                  ,'          and u.atdetpcod <> 42) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '
    prepare pcts06m09010 from l_strsql
    declare ccts06m09010 cursor for pcts06m09010

    #-------------------------------------------------------------------
    # Verifica se a vistoria foi acionada para o veiculo (VP-Online-2.0)
    #-------------------------------------------------------------------
    let l_strsql = ' select count(*) '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'  where v.atdsrvano = ? '
                  ,'    and v.atdsrvnum = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
                  ,'    and a.atdsrvseq = '
                  ,'      (select max(u.atdsrvseq) '
                  ,'         from datmsrvacp u '
                  ,'        where u.atdsrvano = s.atdsrvano '
                  ,'          and u.atdsrvnum = s.atdsrvnum '
                  ,'          and u.atdetpcod <> 39  '
                  ,'          and u.atdetpcod <> 42) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '
    prepare pcts06m09010b from l_strsql
    declare ccts06m09010b cursor for pcts06m09010b

    #--------------------------------------------------------
    # Recupera o numero de vistorias pendentes para o veiculo
    #--------------------------------------------------------
    let l_strsql = ' select count(*) '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'  where v.vstdat = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
                  ,'    and a.atdsrvseq = '
                  ,'      (select max(u.atdsrvseq) '
                  ,'         from datmsrvacp u '
                  ,'        where u.atdsrvano = s.atdsrvano '
                  ,'          and u.atdsrvnum = s.atdsrvnum '
                  ,'          and u.atdetpcod <> 39  '
                  ,'          and u.atdetpcod <> 42) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '
                  ,'    and not exists '
                  ,'      (select 1 from avlmlaudo l '
                  ,'        where l.vstnumdig = v.vstnumdig) '
    prepare pcts06m09011 from l_strsql
    declare ccts06m09011 cursor for pcts06m09011

    #--------------------------------------------------------------------
    # Verifica se a vistoria esta pendente para o veiculo (VP-Online-2.0)
    #--------------------------------------------------------------------
    let l_strsql = ' select count(*) '
                  ,'   from datmvistoria v '
                  ,'       ,datmservico s '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'  where v.atdsrvano = ? '
                  ,'    and v.atdsrvnum = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
                  ,'    and a.atdsrvseq = '
                  ,'      (select max(u.atdsrvseq) '
                  ,'         from datmsrvacp u '
                  ,'        where u.atdsrvano = s.atdsrvano '
                  ,'          and u.atdsrvnum = s.atdsrvnum '
                  ,'          and u.atdetpcod <> 39  '
                  ,'          and u.atdetpcod <> 42) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '
                  ,'    and not exists '
                  ,'      (select 1 from avlmlaudo l '
                  ,'        where l.vstnumdig = v.vstnumdig) '
    prepare pcts06m09011b from l_strsql
    declare ccts06m09011b cursor for pcts06m09011b

    #--------------------------------------------------
    # Recupera as 10 vistorias mais proximas a uma base
    #--------------------------------------------------
    let l_strsql = ' select first 10 '
                  ,'        s.atdsrvnum '
                  ,'       ,s.atdsrvano '
                  ,'       ,v.vstnumdig '
                  ,'       ,v.vstdat '
                  ,'       ,to_char(extend(v.vstdat),"%d/%m") '
                  ,'        as diamesvst '
                  ,'       ,s.atdprinvlcod '
                  ,'       ,s.ciaempcod '
                  ,'       ,l.ufdcod '
                  ,'       ,l.cidnom '
                  ,'       ,l.brrnom '
                  ,'       ,l.lclbrrnom '
                  ,'       ,trim(l.lgdtip) || " " || '
                  ,'        trim(l.lgdnom) || " " || '
                  ,'        l.lgdnum as endereco '
                  ,'       ,v.prfhor '
                  ,'       ,case when (l.lclltt<>0 and l.lcllgt<>0) then '
                  ,'        round(sqrt(pow(((?*108) '
                  ,'        -(l.lcllgt*108)),2) '
                  ,'        + pow(((?*108) '
                  ,'        -(l.lclltt*108)),2)),2) '
                  ,'        else '
                  ,'        round(sqrt(pow(((?*108) '
                  ,'        -(b.lcllgt*108)),2) '
                  ,'        + pow(((?*108) '
                  ,'        -(b.lclltt*108)),2)),2) '
                  ,'        end distkm '
                  ,'   from datmservico s '
                  ,'       ,datmvistoria v '
                  ,'       ,datmlcl l '
                  ,'       ,datkmpabrr b '
                  ,'       ,glakcid c '
                  ,'  where v.vstdat >= ? '
                  ,'    and v.vstdat <= ? '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.c24endtip = 1 '
                  ,'    and c.ufdcod = l.ufdcod '
                  ,'    and c.cidnom = l.cidnom '
                  ,'    and b.brrnom = l.brrnom '
                  ,'    and b.mpacidcod = c.cidcod '
                  ,'    and s.atdlibflg = "S" '
                  ,'    and s.atdfnlflg = "N" '
                  ,'    and (s.atdprinvlcod = ? or 1=?) '
                  ,'    and (s.ciaempcod = ? or 1=?) '
                  ,'    and (l.ufdcod = ? or 1=?) '
                  ,'    and (l.cidnom = ? or 1=?) '
                  ,'    and (l.brrnom = ? or 1=?) '
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc n '
                  ,'        where n.atdsrvano = v.atdsrvano '
                  ,'          and n.atdsrvnum = v.atdsrvnum) '
                  ,'  order by distkm '
    prepare pcts06m09012 from l_strsql
    declare ccts06m09012 cursor for pcts06m09012

    #-----------------------------------
    # Recupera os dados para acionamento
    #-----------------------------------
    let l_strsql = ' select v.vclctfnom '
                  ,'       ,p.pstcoddig '
                  ,'       ,p.nomgrr '
                  ,'       ,s.srrcoddig '
                  ,'       ,s.srrabvnom '
                  ,'   from datkveiculo v '
                  ,'       ,dattfrotalocal f '
                  ,'       ,dpaksocor p '
                  ,'       ,datksrr s '
                  ,'  where v.atdvclsgl = ? '
                  ,'    and f.socvclcod = v.socvclcod '
                  ,'    and p.pstcoddig = v.pstcoddig '
                  ,'    and s.srrcoddig = f.srrcoddig '
                  ,'    and v.socoprsitcod = 1 '
              ####,'    and p.prssitcod = "A" '
              ####,'    and s.srrstt = 1 '
    prepare pcts06m09013 from l_strsql
    declare ccts06m09013 cursor for pcts06m09013

    #-----------------------------------------------
    # Recupera o tipo de vinculo + codigo do posto
    # do inspetor + celular do veiculo via base palm
    #-----------------------------------------------
    let l_strsql = ' select i.vintipcod '
                  ,'       ,v.celdddcod '
                  ,'       ,v.celtelnum '
                  ,'   from avckplmidt b '
                  ,'       ,avckinsp i '
                  ,'       ,datkveiculo v '
                  ,'  where b.atdvclsgl = ? '
                  ,'    and b.plmsit = "A" '
                  ,'    and i.vstinpcod = b.vstinpcod '
                  ,'    and i.vstinpstt = "A" '
                  ,'    and v.atdvclsgl = b.atdvclsgl '
                  ,'    and v.socoprsitcod = 1 '
    prepare pcts06m09014 from l_strsql
    declare ccts06m09014 cursor for pcts06m09014

    #-------------------------------------------
    # Recupera o e-mail de distribuicao do posto
    #-------------------------------------------
    let l_strsql = ' select p.dtbelrcoiendnom '
                  ,'   from avckposto p '
                  ,'  where p.pgtvstpstcod = ? '
                  ,'    and p.vstpststt = "A" '
    prepare pcts06m09015 from l_strsql
    declare ccts06m09015 cursor for pcts06m09015

    #---------------------------------------------------
    # Recupera as marcacoes de vistoria previa acionadas
    # e pendentes de cadastramento de um inspetor
    #---------------------------------------------------
    let l_strsql = ' select s.atdsrvnum '
                  ,'       ,s.atdsrvano '
                  ,'       ,v.vstnumdig '
                  ,'       ,v.vstdat '
                  ,'       ,to_char(extend(v.vstdat),"%d/%m") '
                  ,'        as diamesvst '
                  ,'       ,s.atdprinvlcod '
                  ,'       ,s.ciaempcod '
                  ,'       ,l.ufdcod '
                  ,'       ,l.cidnom '
                  ,'       ,l.brrnom '
                  ,'       ,l.lclbrrnom '
                  ,'       ,trim(l.lgdtip) || " " || '
                  ,'        trim(l.lgdnom) || " " || '
                  ,'        l.lgdnum as endereco '
                  ,'       ,v.prfhor '
                  ,'   from datmservico s '
                  ,'       ,datmvistoria v '
                  ,'       ,datmlcl l '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'       ,dattfrotalocal f '
                  ,'  where v.vstdat = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and k.socoprsitcod = 1 '
                  ,'    and f.socvclcod = k.socvclcod '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdfnlflg = "S" '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.c24endtip = 1 '
                  ,'    and a.atdsrvano = s.atdsrvano '
                  ,'    and a.atdsrvnum = s.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                  ,'    and a.atdetpcod = 4 '
		#--------------------------------> VP-Online-2.0 (inicio)
                # ,'    and a.atdsrvseq = '
                # ,'      (select max(u.atdsrvseq) '
                # ,'         from datmsrvacp u '
                # ,'        where u.atdsrvano = s.atdsrvano '
                # ,'          and u.atdsrvnum = s.atdsrvnum '
                # ,'          and u.atdetpcod <> 39  '
                # ,'          and u.atdetpcod <> 42) '
		#--------------------------------> VP-Online-2.0 (fim)
                  ,'    and not exists '
                  ,'      (select 1 from datmvstcanc c '
                  ,'        where c.atdsrvano = s.atdsrvano '
                  ,'          and c.atdsrvnum = s.atdsrvnum) '
		#--------------------------------> VP-Online-2.0 (inicio)
                # ,'    and not exists '
                # ,'      (select 1 from avlmlaudo l '
                # ,'        where l.vstnumdig = v.vstnumdig) '
		#--------------------------------> VP-Online-2.0 (fim)
    prepare pcts06m09016 from l_strsql
    declare ccts06m09016 cursor for pcts06m09016

    #-----------------------------------
    # Recupera a ultima etapa do servico
    #-----------------------------------
    let l_strsql = ' select a.atdetpcod '
                  ,'       ,a.atdsrvseq '
                  ,'       ,a.pstcoddig '
                  ,'       ,a.srrcoddig '
                  ,'       ,a.socvclcod '
                  ,'   from datmsrvacp a '
                  ,'  where a.atdsrvnum = ? '
                  ,'    and a.atdsrvano = ? '
                  ,'    and a.atdsrvseq = '
                  ,'       (select max(u.atdsrvseq) '
                  ,'          from datmsrvacp u '
                  ,'         where u.atdsrvnum = a.atdsrvnum '
                  ,'           and u.atdsrvano = a.atdsrvano) '
    prepare pcts06m09017 from l_strsql
    declare ccts06m09017 cursor for pcts06m09017

    #-------------------------------------
    # Verifica se a vistoria foi cancelada
    #-------------------------------------
    let l_StrSql = ' select 1 '
                  ,'   from datmvstcanc '
                  ,'  where atdsrvano = ? '
                  ,'    and atdsrvnum = ? '
    prepare pcts06m09018 from l_strsql
    declare ccts06m09018 cursor for pcts06m09018

    #----------------------------------------------
    # Verifica se o posto atende empresa+cidade+dia
    #----------------------------------------------
    let l_StrSql = ' select 1 '
                  ,'   from avckpstcid c '
                  ,'       ,avckposto p '
                  ,'  where c.srvorgcod = 10 '
                  ,'    and c.cidcod = ? '
                  ,'    and c.empcod in (?,99) '
                  ,'    and c.smndianum in (?,99) '
                  ,'    and c.atmacntipcod = 1 '
                  ,'    and c.atoregflg = "A" '
                  ,'    and p.vstpstcod = c.pstcod '
                  ,'    and p.vstpststt = "A" '
                  ,'    and p.atdvclsgl = ? '
    prepare pcts06m09019 from l_strsql
    declare ccts06m09019 cursor for pcts06m09019

    #-------------------------------------
    # Verifica se o veiculo atende empresa
    #-------------------------------------
    let l_StrSql = ' select 1 '
                  ,'   from datkveiculo v1 '
                  ,'       ,datrvclemp  e1 '
                  ,'  where v1.atdvclsgl = ? '
                  ,'    and e1.socvclcod = v1.socvclcod '
                  ,'    and e1.ciaempcod = ? '
    prepare pcts06m09020 from l_strsql
    declare ccts06m09020 cursor for pcts06m09020

    #---------------------------------------
    # Verifica se o prestador atende empresa
    #---------------------------------------
    let l_StrSql = ' select 1 '
                  ,'   from datkveiculo v2 '
                  ,'       ,dparpstemp  e2 '
                  ,'  where v2.atdvclsgl = ? '
                  ,'    and e2.pstcoddig = v2.pstcoddig '
                  ,'    and e2.ciaempcod = ? '
    prepare pcts06m09021 from l_strsql
    declare ccts06m09021 cursor for pcts06m09021

    #------------------------------------------
    # Recupera o veiculo para clientes vponline
    #------------------------------------------
    let l_StrSql = ' select d.vstcpodomdes '
                  ,'  from avlkdomcampovst d '
                  ,' where d.vstcpocod = 250 '
                  ,'   and d.vstcpodomcod = 1 '
                  ,'   and d.atlult not like "%DEL%" '
    prepare pcts06m09022 from l_strsql
    declare ccts06m09022 cursor for pcts06m09022

    #----------------------------------------
    # Recupera o numero de dias para vponline
    #----------------------------------------
    let l_StrSql = ' select d.vstcpodomdes '
                  ,'  from avlkdomcampovst d '
                  ,' where d.vstcpocod = 250 '
                  ,'   and d.vstcpodomcod = 5 '
                  ,'   and d.atlult not like "%DEL%" '
    prepare pcts06m09023 from l_strsql
    declare ccts06m09023 cursor for pcts06m09023

    #--------------------------------------------------------------
    # Recupera informacoes complementares da vistoria para VPOnline
    #--------------------------------------------------------------
    let l_strsql = ' select l.celteldddcod '
                  ,'       ,l.celtelnum '
                  ,'       ,v.segematxt '
                  ,'       ,v.vcllicnum '
                  ,'       ,v.segnom '
                  ,'       ,s.ciaempcod '
                  ,'   from datmvistoria v '
                  ,'       ,datmlcl l '
                  ,'       ,datmservico s'
                  ,'  where v.atdsrvnum = ? '
                  ,'    and v.atdsrvano = ? '
                  ,'    and s.atdsrvnum = v.atdsrvnum '
                  ,'    and s.atdsrvano = v.atdsrvano '
                  ,'    and l.atdsrvnum = v.atdsrvnum '
                  ,'    and l.atdsrvano = v.atdsrvano '
                  ,'    and l.c24endtip = 1 '
    prepare pcts06m09024 from l_strsql
    declare ccts06m09024 cursor for pcts06m09024

    #--------------------------------------------------------------------
    # Verifica se a vistoria ja' foi acionada anteriormente para VPOnline
    #--------------------------------------------------------------------
    let l_strsql = ' select 1 '
                  ,'   from datmvistoria v '
                  ,'       ,datmsrvacp a '
                  ,'       ,datkveiculo k '
                  ,'  where v.vstnumdig = ? '
                  ,'    and k.atdvclsgl = ? '
                  ,'    and a.atdsrvano = v.atdsrvano '
                  ,'    and a.atdsrvnum = v.atdsrvnum '
                  ,'    and a.socvclcod = k.socvclcod '
                # ,'    and a.atdetpcod = 4 ' #--> VP-Online-2.0
    prepare pcts06m09025 from l_strsql
    declare ccts06m09025 cursor for pcts06m09025

    #----------------------
    # Altera o DDD VPOnline
    #----------------------
    let l_strsql = ' update datmlcl '
                  ,'    set celteldddcod = ? '
                  ,'  where atdsrvnum    = ? '
                  ,'    and atdsrvano    = ? '
                  ,'    and c24endtip    = 1 '
    prepare pcts06m09026 from l_strsql

    #--------------------------
    # Altera o Celular VPOnline
    #--------------------------
    let l_strsql = ' update datmlcl '
                  ,'    set celtelnum = ? '
                  ,'  where atdsrvnum = ? '
                  ,'    and atdsrvano = ? '
                  ,'    and c24endtip = 1 '
    prepare pcts06m09027 from l_strsql

    #-------------------------
    # Altera o Email VPOnline
    #------------------------
    let l_strsql = ' update datmvistoria '
                  ,'    set segematxt = ? '
                  ,'  where atdsrvnum = ? '
                  ,'    and atdsrvano = ? '
    prepare pcts06m09028 from l_strsql
    let m_cts06m09_prepare = 'S'

end function

function cts06m09()

    #-----------------------------------
    # Array com os dados principais das
    # vistorias pendentes de acionamento
    #-----------------------------------
    define la_rdados array[7000] of record
        NumeroServico           like datmservico.atdsrvnum
       ,AnoServico              like datmservico.atdsrvano
       ,NumeroVistoria          like datmvistoria.vstnumdig
       ,DataVistoria            like datmvistoria.vstdat
       ,UF                      like datmlcl.ufdcod
       ,NomeCidade              like datmlcl.cidnom
       ,NomeBairro              like datmlcl.brrnom
       ,NomeSubBairro           like datmlcl.lclbrrnom
       ,Endereco                char(50)
    end record

    #----------------------------------------
    # Array com os dados exibidos na tela das
    # vistorias pendentes de acionamento
    #----------------------------------------
    define la_rftela array[7000] of record
        RegSelecionado          char(01)
       ,DiaMesVistoria          char(05)
       ,Prioridade              like datmservico.atdprinvlcod
       ,CodigoEmpresa           like datmservico.ciaempcod
       ,EnderecoExibicao        char(50)
       ,HorarioPref             like datmvistoria.prfhor
    end record

    #-------------------------------------------------
    # Record com os dados complementares das vistorias
    #-------------------------------------------------
    define lr_infocp record
        CodigoEmpresa           like datmservico.ciaempcod
       ,Latitude                like datmlcl.lclltt
       ,Longitude               like datmlcl.lcllgt
       ,OrigemCoordenadas       char(01)
       ,CodigoCidade            like glakcid.cidcod
       ,DiaSemanaVistoria       smallint
    end record

    #------------------------------------------------------
    # Record com os dados de filtro informados pelo usuario
    #------------------------------------------------------
    define lr_filtro record
        UF                      like datmlcl.ufdcod
       ,NomeCidade              like datmlcl.cidnom
       ,CodigoCidade            like glakcid.cidcod
       ,NomeBairro              like datmlcl.brrnom
       ,DataInicial             like datmvistoria.vstdat
       ,DataFinal               like datmvistoria.vstdat
       ,FiltroPrioridade        like datmservico.atdprinvlcod
       ,FiltroEmpresa           like datmservico.ciaempcod
       ,FiltroVistoria          char(09)
       ,FiltroX                 like datkveiculo.atdvclsgl #--> VP-Online-2.0
       ,FiltraData              smallint # 0=Sim / 1=Nao
       ,FiltraPrioridade        smallint # 0=Sim / 1=Nao
       ,FiltraEmpresa           smallint # 0=Sim / 1=Nao
       ,FiltraUF                smallint # 0=Sim / 1=Nao
       ,FiltraCidade            smallint # 0=Sim / 1=Nao
       ,FiltraBairro            smallint # 0=Sim / 1=Nao
       ,FiltraVistoria          smallint # 0=Sim / 1=Nao
       ,FiltraPremium           smallint # 0=Sim / 1=Nao
    end record

    #----------------------------------------------------
    # Array com as 20 bases mais proximas de uma vistoria
    #----------------------------------------------------
    define la_rbases array[20] of record
        SiglaVeiculo            like avckplmidt.atdvclsgl
       ,NomeInspetor            like avckinsp.vstinpnom
       ,BairroBase              like avckplmidt.plmbasendbrr
       ,Distancia               decimal(6,2)
       ,QtdVistoriasAcn         smallint
       ,QtdVistoriasPend        smallint
    end record

    #---------------------------------------------
    # Array com as 20 bases mais proximas (extras)
    #---------------------------------------------
    define la_xbases array[20] of record
        LongitudeBase           like avckplmidt.plmbaslgt
       ,LatitudeBase            like avckplmidt.plmbasltt
       ,LimiteKM                like avckplmidt.klmqtd
    end record

    #--------------------------------------------------
    # Array com os dados principais das 10 vistorias
    # pendentes de acionamento mais proximas a uma base
    #--------------------------------------------------
    define la_cdados array[10] of record
        NumeroServico           like datmservico.atdsrvnum
       ,AnoServico              like datmservico.atdsrvano
       ,NumeroVistoria          like datmvistoria.vstnumdig
       ,DataVistoria            like datmvistoria.vstdat
       ,UF                      like datmlcl.ufdcod
       ,NomeCidade              like datmlcl.cidnom
       ,NomeBairro              like datmlcl.brrnom
       ,NomeSubBairro           like datmlcl.lclbrrnom
       ,Endereco                char(50)
    end record

    #-----------------------------------------------------
    # Array com os dados exibidos na tela das 10 vistorias
    # pendentes de acionamento mais proximas a uma base
    #-----------------------------------------------------
    define la_cftela array[10] of record
        RegSelecionado          char(01)
       ,DiaMesVistoria          char(05)
       ,Prioridade              like datmservico.atdprinvlcod
       ,CodigoEmpresa           like datmservico.ciaempcod
       ,EnderecoExibicao        char(50)
       ,HorarioPref             like datmvistoria.prfhor
       ,Distancia               decimal(6,2)
    end record

    #-------------------------------------
    # Array com os dados principais das
    # vistorias pendentes de cadastramento
    #-------------------------------------
    define la_pdados array[200] of record
        NumeroServico           like datmservico.atdsrvnum
       ,AnoServico              like datmservico.atdsrvano
       ,NumeroVistoria          like datmvistoria.vstnumdig
       ,DataVistoria            like datmvistoria.vstdat
       ,UF                      like datmlcl.ufdcod
       ,NomeCidade              like datmlcl.cidnom
       ,NomeBairro              like datmlcl.brrnom
       ,NomeSubBairro           like datmlcl.lclbrrnom
       ,Endereco                char(50)
    end record

    #----------------------------------------
    # Array com os dados exibidos na tela das
    # vistorias pendentes de cadastramento
    #----------------------------------------
    define la_pftela array[200] of record
        RegSelecionado          char(01)
       ,DiaMesVistoria          char(05)
       ,Prioridade              like datmservico.atdprinvlcod
       ,CodigoEmpresa           like datmservico.ciaempcod
       ,EnderecoExibicao        char(50)
       ,HorarioPref             like datmvistoria.prfhor
       ,Distancia               decimal(6,2)
    end record

    #---------------------------------
    # Retorno da funcao de acionamento
    #---------------------------------
    define lr_ret_AcionaVP record
        Codigo                  smallint
       ,Mensagem                char(78)
    end record

    #-------------------------------------------------
    # Variaveis de controle do FiltroX (VP-Online-2.0)
    #-------------------------------------------------
    define lr_FiltroX      record
        QtdAcn                  integer 
       ,QtdPnd                  integer 
       ,Ctrl                    char(1) 
       ,SolicitaNovoFiltro      char(1)
       ,QtdAcnPendX             char(25)
    end record

    define l_saida              smallint
    define l_pos                smallint
    define l_scr                smallint
    define l_sel                char(01)
    define l_tecla              char(01)

    define l_cpos               smallint
    define l_vpos               smallint
    define l_cscr               smallint

    define l_cont               smallint
    define l_tpos               smallint

    define l_numvisto           like datmvistoria.vstnumdig
    define l_premium            smallint

    #--------------------------
    # Inicializa tudo com nulos
    #--------------------------
    initialize m_mensagem         to null
    initialize m_cts06m09_prepare to null
    initialize ma_aciona          to null
    initialize ma_telacn          to null
    initialize mr_veiculo         to null
    initialize mr_vponline        to null
    initialize la_rdados          to null
    initialize la_rftela          to null
    initialize lr_infocp          to null
    initialize lr_filtro          to null
    initialize la_rbases          to null
    initialize la_xbases          to null
    initialize la_cdados          to null
    initialize la_cftela          to null
    initialize la_pdados          to null
    initialize la_pftela          to null
    initialize lr_ret_AcionaVP    to null
    initialize l_saida            to null
    initialize l_pos              to null
    initialize l_scr              to null
    initialize l_sel              to null
    initialize l_tecla            to null
    initialize l_cpos             to null
    initialize l_vpos             to null
    initialize l_cscr             to null
    initialize l_cont             to null
    initialize l_tpos             to null
    initialize l_numvisto         to null
    initialize l_premium          to null
    initialize lr_FiltroX         to null

    #------------------------
    # Prepara os comandos sql
    #------------------------
    if m_cts06m09_prepare is null or
       m_cts06m09_prepare <> 'S' then
        call cts06m09_prepare()
    end if

    #------------------------------------------
    # Recupera o veiculo para clientes vponline
    #------------------------------------------
    whenever error continue
    open  ccts06m09022
    fetch ccts06m09022
    into  mr_vponline.SiglaVeiculo
    whenever error stop
    if sqlca.sqlcode <> 0 then
        let mr_vponline.SiglaVeiculo = 'X000'
    end if
    #----------------------------------------
    # Recupera o numero de dias para vponline
    #----------------------------------------
    whenever error continue
    open  ccts06m09023
    fetch ccts06m09023
    into  mr_vponline.NumeroDias
    whenever error stop
    if sqlca.sqlcode <> 0 then
        let mr_vponline.NumeroDias = 5
    end if

    let l_saida   = false
    let l_premium = false

    open window cts06m09 at 03,02
    with form 'cts06m09'
    attribute(form line 1)

    if l_saida = true then
        let l_saida = false
        let int_flag = false
        close window cts06m09
        return
    end if

    while true

        let int_flag                = false
        initialize lr_filtro        to null
        initialize la_rdados        to null
        initialize la_rftela        to null
        initialize lr_ret_AcionaVP  to null

        clear form

        if l_premium = false then
            let lr_filtro.DataInicial   = today
            let lr_filtro.DataFinal     = today
            let lr_filtro.FiltraPremium = 1
        else
            let lr_filtro.DataInicial    = today
            let lr_filtro.DataFinal      = today + 15 units day
            let lr_filtro.FiltroVistoria = ' PREMIUM '
            let lr_filtro.FiltraPremium  = 0
            display lr_filtro.DataInicial    to f_DataInicial
            display lr_filtro.DataFinal      to f_DataFinal
            display lr_filtro.FiltroVistoria to f_FiltroVistoria attribute(reverse)
        end if

        input lr_filtro.UF
             ,lr_filtro.NomeCidade
             ,lr_filtro.CodigoCidade
             ,lr_filtro.NomeBairro
             ,lr_filtro.DataInicial
             ,lr_filtro.DataFinal
             ,lr_filtro.FiltroPrioridade
             ,lr_filtro.FiltroEmpresa
             ,lr_filtro.FiltroVistoria
             ,lr_filtro.FiltroX 
              without defaults
         from f_UF
             ,f_NomeCidade
             ,f_CodigoCidade
             ,f_NomeBairro
             ,f_DataInicial
             ,f_DataFinal
             ,f_FiltroPrioridade
             ,f_FiltroEmpresa
             ,f_FiltroVistoria
             ,f_FiltroX

            before field f_UF

                if l_premium = true then
                    let l_premium = false
                    exit input
                end if

                display lr_filtro.UF
                             to f_UF attribute(reverse)

            after field f_UF
                display lr_filtro.UF
                             to f_UF

                if lr_filtro.UF is null or
                   lr_filtro.UF = ' ' then

                    initialize lr_filtro.NomeCidade to null
                    display lr_filtro.NomeCidade
                                 to f_NomeCidade

                    initialize lr_filtro.CodigoCidade to null
                    display lr_filtro.CodigoCidade
                                 to f_CodigoCidade

                    initialize lr_filtro.NomeBairro to null
                    display lr_filtro.NomeBairro
                                 to f_NomeBairro

                    next field f_DataInicial

                end if

                #---------------------------
                # Recupera a sigla do estado
                #---------------------------
                open  ccts06m09003
                using lr_filtro.UF
                whenever error continue
                fetch ccts06m09003
                whenever error stop

                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        error ' UF invalida, tente novamente '
                        initialize lr_filtro.UF to null
                        next field f_UF
                    else
                        error ' CTS06M09/ccts06m09003/ '
                             ,lr_filtro.UF sleep 2
                        let l_saida = true
                        exit input
                    end if
                end if

            before field f_NomeCidade
                display lr_filtro.NomeCidade
                             to f_NomeCidade attribute(reverse)

            after field f_NomeCidade
                display lr_filtro.NomeCidade
                             to f_NomeCidade

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_UF
                end if

                if lr_filtro.NomeCidade is null or
                   lr_filtro.NomeCidade = ' ' then

                    initialize lr_filtro.CodigoCidade to null
                    display lr_filtro.CodigoCidade
                                 to f_CodigoCidade

                    initialize lr_filtro.NomeBairro to null
                    display lr_filtro.NomeBairro
                                 to f_NomeBairro

                    next field f_DataInicial

                end if

                #----------------------------
                # Recupera o codigo da cidade
                #----------------------------
                open  ccts06m09004
                using lr_filtro.UF
                     ,lr_filtro.NomeCidade
                whenever error continue
                fetch ccts06m09004
                into  lr_filtro.CodigoCidade
                whenever error stop

                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        call cts06g04(
                                  lr_filtro.NomeCidade
                                 ,lr_filtro.UF)
                        returning lr_filtro.CodigoCidade
                                 ,lr_filtro.NomeCidade
                                 ,lr_filtro.UF
                        if lr_filtro.CodigoCidade is null or
                           lr_filtro.NomeCidade   is null or
                           lr_filtro.UF           is null then
                            error ' Cidade invalida, tente novamente '
                            initialize lr_filtro.NomeCidade to null
                            next field f_NomeCidade
                        else
                            display lr_filtro.CodigoCidade
                                         to f_CodigoCidade
                            display lr_filtro.NomeCidade
                                         to f_NomeCidade
                            display lr_filtro.UF
                                         to f_UF
                        end if
                    else
                        error ' CTS06M09/ccts06m09004/ '
                             ,lr_filtro.NomeCidade sleep 2
                        let l_saida = true
                        exit input
                    end if
                end if

                display lr_filtro.CodigoCidade
                             to f_CodigoCidade
     
	    #--> VP-Online-2.0 (inicio)

            before field f_FiltroX
                display lr_filtro.FiltroX
                             to f_FiltroX attribute(reverse)

            after field f_FiltroX
                display lr_filtro.FiltroX
                             to f_FiltroX

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_CodigoCidade
                end if

	    #--> VP-Online-2.0 (finaliza)

            before field f_NomeBairro
                display lr_filtro.NomeBairro
                             to f_NomeBairro attribute(reverse)

            after field f_NomeBairro
                display lr_filtro.NomeBairro
                             to f_NomeBairro

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                   #next field f_CodigoCidade #--> VP-Online-2.0
                    next field f_FiltroX      #--> VP-Online-2.0
                end if

            before field f_DataInicial
                display lr_filtro.DataInicial
                             to f_DataInicial attribute(reverse)

            after field f_DataInicial
                display lr_filtro.DataInicial
                             to f_DataInicial

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    if lr_filtro.CodigoCidade is not null then
                        next field f_NomeBairro
                    else
                        if lr_filtro.UF is not null then
                            next field f_NomeCidade
                        else
                            next field f_UF
                        end if
                    end if
                end if

                if lr_filtro.DataInicial is null then
                    let lr_filtro.DataInicial = today
                    next field f_DataInicial
                end if

                let lr_filtro.DataFinal = lr_filtro.DataInicial

            before field f_DataFinal
                display lr_filtro.DataFinal
                             to f_DataFinal attribute(reverse)

            after field f_DataFinal
                display lr_filtro.DataFinal
                             to f_DataFinal

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_DataInicial
                end if

                if lr_filtro.DataFinal is null then
                    let lr_filtro.DataFinal = lr_filtro.DataInicial
                    next field f_DataFinal
                end if

            before field f_FiltroPrioridade
                display lr_filtro.FiltroPrioridade
                             to f_FiltroPrioridade attribute(reverse)

            after field f_FiltroPrioridade
                display lr_filtro.FiltroPrioridade
                             to f_FiltroPrioridade

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_DataFinal
                end if

            before field f_FiltroEmpresa
                display lr_filtro.FiltroEmpresa
                             to f_FiltroEmpresa attribute(reverse)

            after field f_FiltroEmpresa
                display lr_filtro.FiltroEmpresa
                             to f_FiltroEmpresa

                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_FiltroPrioridade
                end if

                if lr_filtro.FiltroEmpresa is not null then
                    whenever error continue
                    open  ccts06m09001
                    using lr_filtro.FiltroEmpresa
                    fetch ccts06m09001
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                        if sqlca.sqlcode = notfound then
                            error 'Codigo de empresa invalido!'
                            initialize lr_filtro.FiltroEmpresa to null
                            next field f_FiltroEmpresa
                        else
                            error ' CTS06M09/ccts06m09001/ ' sleep 2
                            let int_flag = true
                            exit input
                        end if
                    end if
                end if

            before field f_FiltroVistoria
                display lr_filtro.FiltroVistoria
                             to f_FiltroVistoria attribute(reverse)

            after field f_FiltroVistoria

                whenever error continue
                let l_numvisto = lr_filtro.FiltroVistoria
                whenever error stop
                if l_numvisto = 0 then
                    initialize lr_filtro.FiltroVistoria to null
                end if

                display lr_filtro.FiltroVistoria
                             to f_FiltroVistoria
                if fgl_lastkey() = fgl_keyval('left') or
                   fgl_lastkey() = fgl_keyval('up') then
                    next field f_FiltroEmpresa
                end if

        end input

        if int_flag then
            exit while
        end if

	let lr_FiltroX.Ctrl = "P" #--> VP-Online-2.0

        while true

            let int_flag            = false
            let l_pos               = 1
            initialize la_rftela    to null

            let lr_ret_AcionaVP.Codigo   = 0
            let lr_ret_AcionaVP.Mensagem = ''

            message 'Aguarde, pesquisando...'  attribute(reverse)

            #--------------------------------------
            # Sempre filtra por data, exceto quando
            # informada uma vistoria especifica
            #--------------------------------------
            let lr_filtro.FiltraData = 0
            if lr_filtro.UF is null or
               lr_filtro.UF = ' ' then
                let lr_filtro.FiltraUF = 1
            else
                let lr_filtro.FiltraUF = 0
            end if

            if lr_filtro.NomeCidade is null or
               lr_filtro.NomeCidade = ' ' then
                let lr_filtro.FiltraCidade = 1
            else
                let lr_filtro.FiltraCidade = 0
            end if

            if lr_filtro.NomeBairro is null or
               lr_filtro.NomeBairro = ' ' then
                let lr_filtro.FiltraBairro = 1
            else
                let lr_filtro.FiltraBairro = 0
            end if

            if lr_filtro.FiltroPrioridade is null or
               lr_filtro.FiltroPrioridade = ' ' then
                let lr_filtro.FiltraPrioridade = 1
            else
                let lr_filtro.FiltraPrioridade = 0
            end if

            if lr_filtro.FiltroEmpresa is null or
               lr_filtro.FiltroEmpresa = ' ' then
                let lr_filtro.FiltraEmpresa = 1
            else
                let lr_filtro.FiltraEmpresa = 0
            end if

            #------------------------------------
            # Se informou uma vistoria especifica
            # desliga os outros filtros
            #------------------------------------
            if lr_filtro.FiltroVistoria is null or
               lr_filtro.FiltroVistoria = ' '   or
               lr_filtro.FiltroVistoria = ' PREMIUM ' then
                let lr_filtro.FiltroVistoria   = null
                let lr_filtro.FiltraVistoria   = 1
            else
                let lr_filtro.FiltraVistoria   = 0
                let lr_filtro.FiltraData       = 1
                let lr_filtro.FiltraUF         = 1
                let lr_filtro.FiltraCidade     = 1
                let lr_filtro.FiltraBairro     = 1
                let lr_filtro.FiltraPrioridade = 1
                let lr_filtro.FiltraEmpresa    = 1
            end if

	    #--> VP-Online-2.0 (inicio)

            if lr_filtro.FiltroX is not null and 
               lr_filtro.FiltroX <> " " then 
	       case lr_FiltroX.Ctrl
		    when "A"  
		         message 'Aguarde, pesquisando vistorias ACIONADAS ...' 
				 attribute(reverse)
	                 sleep 2
			 message ''
	                 error 'Filtro X : exibindo vistorias ACIONADAS ',
			       '( Ctrl+P=Pendentes / Ctrl+F=Acionadas )'
		    when "P"
		         message 'Aguarde, pesquisando vistorias PENDENTES ...' 
				 attribute(reverse)
	                 sleep 2
			 message ''
	                 error 'Filtro X : exibindo vistorias PENDENTES ',
			       '( Ctrl+P=Pendentes / Ctrl+F=Acionadas )'
	       end case
	       let m_strsql_pcts06m09002 = m_strsql_vponline
            else
	       let m_strsql_pcts06m09002 = m_strsql_original
	    end if 

	    prepare pcts06m09002 from m_strsql_pcts06m09002
	    declare ccts06m09002 cursor for pcts06m09002

            if lr_filtro.FiltroX is not null and 
               lr_filtro.FiltroX <> " " then 
               open  ccts06m09002
               using lr_filtro.FiltroX
                    ,lr_filtro.DataInicial
                    ,lr_filtro.DataFinal
                    ,lr_filtro.FiltraData
                    ,lr_filtro.FiltroPrioridade
                    ,lr_filtro.FiltraPrioridade
                    ,lr_filtro.FiltroEmpresa
                    ,lr_filtro.FiltraEmpresa
                    ,lr_filtro.UF
                    ,lr_filtro.FiltraUF
                    ,lr_filtro.NomeCidade
                    ,lr_filtro.FiltraCidade
                    ,lr_filtro.NomeBairro
                    ,lr_filtro.FiltraBairro
                    ,lr_filtro.FiltroVistoria
                    ,lr_filtro.FiltraVistoria
                    ,lr_filtro.FiltraPremium
            else
               open  ccts06m09002
               using lr_filtro.DataInicial
                    ,lr_filtro.DataFinal
                    ,lr_filtro.FiltraData
                    ,lr_filtro.FiltroPrioridade
                    ,lr_filtro.FiltraPrioridade
                    ,lr_filtro.FiltroEmpresa
                    ,lr_filtro.FiltraEmpresa
                    ,lr_filtro.UF
                    ,lr_filtro.FiltraUF
                    ,lr_filtro.NomeCidade
                    ,lr_filtro.FiltraCidade
                    ,lr_filtro.NomeBairro
                    ,lr_filtro.FiltraBairro
                    ,lr_filtro.FiltroVistoria
                    ,lr_filtro.FiltraVistoria
                    ,lr_filtro.FiltraPremium
            end if 

            let lr_FiltroX.QtdAcn = 0
            let lr_FiltroX.QtdPnd = 0

	    #--> VP-Online-2.0 (fim)

            #-------------------------------------------------------
            # Recupera as marcacoes de vistoria previa nao acionadas
            #-------------------------------------------------------
            let l_pos = 1

            foreach ccts06m09002
               into la_rdados[l_pos].NumeroServico
                   ,la_rdados[l_pos].AnoServico
                   ,la_rdados[l_pos].NumeroVistoria
                   ,la_rdados[l_pos].DataVistoria
                   ,la_rftela[l_pos].DiaMesVistoria
                   ,la_rftela[l_pos].Prioridade
                   ,la_rftela[l_pos].CodigoEmpresa
                   ,la_rdados[l_pos].UF
                   ,la_rdados[l_pos].NomeCidade
                   ,la_rdados[l_pos].NomeBairro
                   ,la_rdados[l_pos].NomeSubBairro
                   ,la_rdados[l_pos].Endereco
                   ,la_rftela[l_pos].HorarioPref

		#--> VP-Online-2.0 (inicio)

                #-------------------------------------------------
                # Quantidade de Acionadas e Pendentes para FiltroX
                #-------------------------------------------------
		if lr_filtro.FiltroX is not null and 
		   lr_filtro.FiltroX <> " " then 

		   let lr_FiltroX.QtdAcn = lr_FiltroX.QtdAcn + 1 

                   #--------------------------------------
                   # Verificar se a vistoria esta pendente
                   #--------------------------------------
		   let l_cont = 0 
                   open  ccts06m09011b using la_rdados[l_pos].AnoServico
                                            ,la_rdados[l_pos].NumeroServico
		                            ,lr_filtro.FiltroX
                   fetch ccts06m09011b into  l_cont 
                   close ccts06m09011b
                   if l_cont is not null and l_cont > 0 then
		      let lr_FiltroX.QtdPnd = lr_FiltroX.QtdPnd + 1 
                   else
		      if lr_FiltroX.Ctrl = "P" then 
			 continue foreach
		      end if 
		   end if 
                end if 

		#--> VP-Online-2.0 (fim)

                #----------------------------------------------------
                # Monta o endereco de exibicao do final para o inicio
                #----------------------------------------------------
                let la_rftela[l_pos].EnderecoExibicao =
                    la_rdados[l_pos].Endereco clipped

                #-------------------------------------
                # Inclui o SubBairro antes do Endereco
                #-------------------------------------
                if la_rdados[l_pos].NomeSubBairro <>
                   la_rdados[l_pos].NomeBairro then
                    let la_rftela[l_pos].EnderecoExibicao =
                        la_rdados[l_pos].NomeSubBairro[1,20] clipped
                       ,'/'
                       ,la_rftela[l_pos].EnderecoExibicao
                end if

                #-----------------------------------------------
                # Inclui o Bairro antes do Endereco ou SubBairro
                #-----------------------------------------------
                if lr_filtro.FiltraBairro = 1 then
                    let la_rftela[l_pos].EnderecoExibicao =
                        la_rdados[l_pos].NomeBairro[1,20] clipped
                       ,'/'
                       ,la_rftela[l_pos].EnderecoExibicao
                end if

                #--------------------------------
                # Inclui a Cidade antes do Bairro
                #--------------------------------
                if lr_filtro.FiltraCidade = 1 then
                    let la_rftela[l_pos].EnderecoExibicao =
                        la_rdados[l_pos].NomeCidade[1,20] clipped
                       ,'/'
                       ,la_rftela[l_pos].EnderecoExibicao clipped
                end if

                #----------------------------
                # Inclui a UF antes da Cidade
                #----------------------------
                if lr_filtro.FiltraUF = 1 then
                    let la_rftela[l_pos].EnderecoExibicao =
                        la_rdados[l_pos].UF clipped
                       ,'/'
                       ,la_rftela[l_pos].EnderecoExibicao clipped
                end if

                let l_pos = (l_pos + 1)

                #-----------------------------------
                # Limita a consulta a 7000 vistorias
                #-----------------------------------
                if l_pos > 7000 then
                    error ' Limite de 7000 vistorias atingido!'
                         ,' Verifique o filtro!'
                    exit foreach
                end if

            end foreach

            let l_pos = (l_pos - 1)

            #--------------------------------------------------
            # Se nao houver dados para exibicao volta ao filtro
            #--------------------------------------------------
            if l_pos = 0 then
                error ' Vistorias nao encontradas! Verifique o filtro! '
                exit while
            end if

            call set_count(l_pos)
            let int_flag = false

            #--> VP-Online-2.0 (inicio)

            #--------------------------------------------------
            # Se nao houver dados para exibicao volta ao filtro
            #--------------------------------------------------
	    let lr_FiltroX.QtdAcnPendX = " " 

            if lr_filtro.FiltroX is not null and 
               lr_filtro.FiltroX <> ' '      then
	       let lr_FiltroX.QtdAcnPendX = "| QAcn:", lr_FiltroX.QtdAcn using "####&"
					  ,  " QPnd:", lr_FiltroX.QtdPnd using "####&"
					  , " | "
            end if 

            display lr_FiltroX.QtdAcnPendX to f_QtdAcnPendX

            let lr_FiltroX.SolicitaNovoFiltro = "N"

            #--> VP-Online-2.0 (fim)

            message 'F1-Inf|F2-Sel|F3-PgDn|F4-PgUp|F5-Hist|F6-Func|F7-Pst|'
                   ,'F8-Acn|F9-AutoP|Tot:'
                   ,l_pos using '&&&&'

            display array la_rftela to s_cts06m09.*
                    attribute (current row display = 'reverse')

                on key (interrupt,control-c)
                    let int_flag = true
                    exit display

	        #-------------------------------------------------------------------------
                # Solicita alteracao da visao das vistorias para o FiltroX (VP-Online-2.0)
	        #-------------------------------------------------------------------------
                on key (control-f)
                   if lr_filtro.FiltroX is not null and 
                      lr_filtro.FiltroX <> ' '      then
		      let lr_FiltroX.Ctrl = "A" #--> Vistorias Acionadas
		      let lr_FiltroX.SolicitaNovoFiltro = "S"
		      exit display
                   end if 

                on key (control-p)
                   if lr_filtro.FiltroX is not null and 
                      lr_filtro.FiltroX <> ' '      then
		      let lr_FiltroX.Ctrl = "P" #--> Vistorias Pendentes
		      let lr_FiltroX.SolicitaNovoFiltro = "S"
		      exit display
                   end if 

                on key (F1)
                    #-----------------------------------------------------
                    # Recupera os dados auxiliares da vistoria selecionada
                    #-----------------------------------------------------
                    let lr_ret_AcionaVP.Codigo   = 0
                    let lr_ret_AcionaVP.Mensagem = ''
                    let l_pos = arr_curr()
                    call cts06m09_ExibeInfo(
                         la_rdados[l_pos].NumeroServico
                        ,la_rdados[l_pos].AnoServico
                        ,la_rdados[l_pos].NomeBairro
                        ,la_rdados[l_pos].NomeSubBairro
                        ,la_rdados[l_pos].NumeroVistoria
                        ,la_rdados[l_pos].DataVistoria
                        ,la_rftela[l_pos].HorarioPref
                        ,la_rftela[l_pos].Prioridade
                        ,la_rdados[l_pos].Endereco
                        ,la_rdados[l_pos].NomeCidade
                        ,la_rdados[l_pos].UF)
                    returning lr_ret_AcionaVP.Codigo
                             ,lr_ret_AcionaVP.Mensagem
                    if lr_ret_AcionaVP.Codigo is not null and
                       lr_ret_AcionaVP.Codigo <> 0 then
                        error lr_ret_AcionaVP.Mensagem
                        if lr_ret_AcionaVP.Codigo = 22 then
                            exit display
                        end if
                    end if

                on key (F2)
                    #-----------------------------------------------
                    # Seleciona o registro corrente para acionamento
                    #-----------------------------------------------
                    let l_pos = arr_curr()
                    let l_scr = scr_line()

                    let l_sel = la_rftela[l_pos].RegSelecionado

                    if l_sel = '*' then
                        let la_rftela[l_pos].RegSelecionado = ' '
                    else
                        #--------------------------------------------
                        # Permite no maximo 10 registros selecionados
                        #--------------------------------------------
                        let l_cont = 0
                        for l_tpos = 1 to 7000
                            if la_rftela[l_tpos].DiaMesVistoria is null then
                                exit for
                            end if
                            if la_rftela[l_tpos].RegSelecionado = '*' then
                                let l_cont = (l_cont + 1)
                            end if
                        end for
                        if l_cont > 9 then
                            error ' Selecione no maximo 10 vistorias! '
                        else
                            let la_rftela[l_pos].RegSelecionado = '*'
                        end if
                    end if

                    display la_rftela[l_pos].RegSelecionado
                      to s_cts06m09[l_scr].f_RegSelecionado

                on key (F5)
                    #---------------------------------------------
                    # Seleciona o registro corrente para historico
                    #---------------------------------------------
                    let l_pos = arr_curr()
                    call cts06n01(la_rdados[l_pos].NumeroServico
                                 ,la_rdados[l_pos].AnoServico
                                 ,la_rdados[l_pos].NumeroVistoria
                                 ,g_issk.funmat
                                 ,today
                                 ,current hour to minute)

                on key (F6)

                    #-----------------------------------
                    # Recupera as 20 bases mais proximas
                    #-----------------------------------
                    initialize la_rbases to null
                    initialize la_xbases to null
                    initialize lr_infocp to null
                    let l_pos = arr_curr()
                    open  ccts06m09006
                    using la_rdados[l_pos].NumeroServico
                         ,la_rdados[l_pos].AnoServico
                    fetch ccts06m09006
                    into  lr_infocp.Latitude
                         ,lr_infocp.Longitude
                         ,lr_infocp.OrigemCoordenadas
                    close ccts06m09006

                    if lr_infocp.Latitude  <> 0 and
                       lr_infocp.Longitude <> 0 then
                        open  ccts06m09008
                        using lr_infocp.Longitude
                             ,lr_infocp.Latitude
                             ,la_rftela[l_pos].CodigoEmpresa
                             ,la_rftela[l_pos].CodigoEmpresa
                        let l_scr = 1
                        foreach ccts06m09008
                           into la_rbases[l_scr].SiglaVeiculo
                               ,la_rbases[l_scr].NomeInspetor
                               ,la_rbases[l_scr].BairroBase
                               ,la_rbases[l_scr].Distancia
                               ,la_xbases[l_scr].LimiteKM
                               ,la_xbases[l_scr].LongitudeBase
                               ,la_xbases[l_scr].LatitudeBase
                            #----------------------------------
                            # Quantidade de vistorias acionadas
                            #----------------------------------
                            open  ccts06m09010
                            using la_rdados[l_pos].DataVistoria
                                 ,la_rbases[l_scr].SiglaVeiculo
                            fetch ccts06m09010
                            into  la_rbases[l_scr].QtdVistoriasAcn
                            close ccts06m09010
                            #----------------------------------
                            # Quantidade de vistorias pendentes
                            #----------------------------------
                            open  ccts06m09011
                            using la_rdados[l_pos].DataVistoria
                                 ,la_rbases[l_scr].SiglaVeiculo
                            fetch ccts06m09011
                            into  la_rbases[l_scr].QtdVistoriasPend
                            close ccts06m09011
                            #----------------------------------
                            let l_scr = (l_scr + 1)
                            #----------------------------------
                        end foreach
                        close ccts06m09008

                        let l_scr = (l_scr - 1)

                    end if

                    open window cts06m09b at 07,02
                    with form 'cts06m09b'
                    attribute(form line 1)

                    display la_rdados[l_pos].NumeroVistoria
                         to f_NumeroVistoria
                    display 'Bairro:'
                         to f_TipoLocal
                    display la_rdados[l_pos].NomeBairro
                         to f_BairroVistoria

                    if lr_infocp.OrigemCoordenadas is null or
                       lr_infocp.OrigemCoordenadas = ' ' then
                        let lr_infocp.OrigemCoordenadas = 'X'
                    end if

                    let m_mensagem = '['
                                    ,lr_infocp.OrigemCoordenadas clipped
                                    ,']'
                    display m_mensagem
                         to f_Origem

                    display la_rftela[l_pos].DiaMesVistoria
                         to f_DiaMesVistoria
                    display 'Funcionario'
                         to f_TipoInspetor

                    message 'F3-PgDn|F4-PgUp|F6-VP+Prox|F8-Acn|CtrP-Pnd|CtrY-Acn|CtrC-Sai'

                    call set_count(l_scr)

                    display array la_rbases to s_cts06m09b.*
                            attribute (current row display = 'reverse')

                        on key (F6)
                            #---------------------------------------
                            # Recupera as 10 vistorias mais proximas
                            #---------------------------------------
                            initialize la_cdados    to null
                            initialize la_cftela    to null

                            let l_cpos = arr_curr()

                            #-------------------------------------------
                            # Ao recuperar as 10 marcacoes mais proximas
                            # da base nao utiliza o filtro por bairro
                            #-------------------------------------------
                            let lr_filtro.FiltraBairro = 1

                            #----------------------------------
                            # Recupera as marcacoes de vistoria
                            # previa nao acionadas
                            #----------------------------------
                            open  ccts06m09012
                            using la_xbases[l_cpos].LongitudeBase
                                 ,la_xbases[l_cpos].LatitudeBase
                                 ,la_xbases[l_cpos].LongitudeBase
                                 ,la_xbases[l_cpos].LatitudeBase
                                 ,lr_filtro.DataInicial
                                 ,lr_filtro.DataFinal
                                 ,lr_filtro.FiltroPrioridade
                                 ,lr_filtro.FiltraPrioridade
                                 ,lr_filtro.FiltroEmpresa
                                 ,lr_filtro.FiltraEmpresa
                                 ,lr_filtro.UF
                                 ,lr_filtro.FiltraUF
                                 ,lr_filtro.NomeCidade
                                 ,lr_filtro.FiltraCidade
                                 ,lr_filtro.NomeBairro
                                 ,lr_filtro.FiltraBairro

                            let l_vpos = 1

                            foreach ccts06m09012
                               into la_cdados[l_vpos].NumeroServico
                                   ,la_cdados[l_vpos].AnoServico
                                   ,la_cdados[l_vpos].NumeroVistoria
                                   ,la_cdados[l_vpos].DataVistoria
                                   ,la_cftela[l_vpos].DiaMesVistoria
                                   ,la_cftela[l_vpos].Prioridade
                                   ,la_cftela[l_vpos].CodigoEmpresa
                                   ,la_cdados[l_vpos].UF
                                   ,la_cdados[l_vpos].NomeCidade
                                   ,la_cdados[l_vpos].NomeBairro
                                   ,la_cdados[l_vpos].NomeSubBairro
                                   ,la_cdados[l_vpos].Endereco
                                   ,la_cftela[l_vpos].HorarioPref
                                   ,la_cftela[l_vpos].Distancia

                                #-------------------------------------------
                                # Exibe apenas as vistorias dentro do limite
                                #-------------------------------------------
                                if la_cftela[l_vpos].Distancia >
                                   la_xbases[l_cpos].LimiteKM  then
                                    initialize la_cdados[l_vpos].* to null
                                    initialize la_cftela[l_vpos].* to null
                                    continue foreach
                                end if

                                #-----------------------------
                                # Monta o endereco de exibicao
                                # do final para o inicio
                                #-----------------------------
                                let la_cftela[l_vpos].EnderecoExibicao =
                                    la_cdados[l_vpos].Endereco clipped

                                #-------------------------------------
                                # Inclui o SubBairro antes do Endereco
                                #-------------------------------------
                                if la_cdados[l_vpos].NomeSubBairro <>
                                   la_cdados[l_vpos].NomeBairro then
                                    let la_cftela[l_vpos].EnderecoExibicao =
                                        la_cdados[l_vpos].NomeSubBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_cftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------------------
                                # Inclui o Bairro antes do Endereco/SubBairro
                                #--------------------------------------------
                                if lr_filtro.FiltraBairro = 1 then
                                    let la_cftela[l_vpos].EnderecoExibicao =
                                        la_cdados[l_vpos].NomeBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_cftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------
                                # Inclui a Cidade antes do Bairro
                                #--------------------------------
                                if lr_filtro.FiltraCidade = 1 then
                                    let la_cftela[l_vpos].EnderecoExibicao =
                                        la_cdados[l_vpos].NomeCidade[1,20]
                                        clipped
                                       ,'/'
                                       ,la_cftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                #----------------------------
                                # Inclui a UF antes da Cidade
                                #----------------------------
                                if lr_filtro.FiltraUF = 1 then
                                    let la_cftela[l_vpos].EnderecoExibicao =
                                        la_cdados[l_vpos].UF clipped
                                       ,'/'
                                       ,la_cftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                let l_vpos = (l_vpos + 1)

                            end foreach

                            let l_vpos = (l_vpos - 1)
                            call set_count(l_vpos)
                            let int_flag = false

                            open window cts06m09c at 07,02
                            with form 'cts06m09c'
                            attribute(form line 1)

                            #--------------------------------------------
                            # Guarda a sigla do veiculo caso acione daqui
                            #--------------------------------------------
                            let mr_veiculo.SiglaVeiculo =
                                la_rbases[l_cpos].SiglaVeiculo

                            display la_rbases[l_cpos].SiglaVeiculo
                                 to f_SiglaVeiculo
                            display la_rbases[l_cpos].NomeInspetor
                                 to f_NomeInspetor
                            display la_xbases[l_cpos].LimiteKM
                                 to f_LimiteKM
                            display la_rbases[l_cpos].QtdVistoriasAcn
                                 to f_QtdVistoriasAcn
                            display la_rbases[l_cpos].QtdVistoriasPend
                                 to f_QtdVistoriasPend
                            display '(Nao Acionadas)'
                                 to f_TipoVistoria

                            message 'F1-Info|F2-Sel|F3-PgDn|F4-PgUp|F5-Hist|'
                                   ,'F8-Acn|Ct+C-Sai'

                            display array la_cftela to s_cts06m09c.*
                                    attribute (current row display = 'reverse')

                                on key (interrupt,control-c)
                                    let int_flag = false
                                    exit display

                                on key (F1)
                                    #-----------------------------
                                    # Recupera os dados auxiliares
                                    # da vistoria selecionada
                                    #-----------------------------
                                    if la_cdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if
                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''
                                    let l_cpos = arr_curr()
                                    call cts06m09_ExibeInfo(
                                         la_cdados[l_cpos].NumeroServico
                                        ,la_cdados[l_cpos].AnoServico
                                        ,la_cdados[l_cpos].NomeBairro
                                        ,la_cdados[l_cpos].NomeSubBairro
                                        ,la_cdados[l_cpos].NumeroVistoria
                                        ,la_cdados[l_cpos].DataVistoria
                                        ,la_cftela[l_cpos].HorarioPref
                                        ,la_cftela[l_cpos].Prioridade
                                        ,la_cdados[l_cpos].Endereco
                                        ,la_cdados[l_cpos].NomeCidade
                                        ,la_cdados[l_cpos].UF)
                                    returning lr_ret_AcionaVP.Codigo
                                             ,lr_ret_AcionaVP.Mensagem
                                    if lr_ret_AcionaVP.Codigo is not null and
                                       lr_ret_AcionaVP.Codigo <> 0 then
                                        error lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo = 22 then
                                            exit display
                                        end if
                                    end if

                                on key (F2)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para acionamento
                                    #------------------------------
                                    if la_cdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()
                                    let l_cscr = scr_line()

                                    let l_sel =
                                        la_cftela[l_cpos].RegSelecionado
                                    if l_sel = '*' then
                                        let la_cftela[l_cpos].RegSelecionado
                                        = ' '
                                    else
                                        let la_cftela[l_cpos].RegSelecionado
                                        = '*'
                                    end if

                                    display la_cftela[l_cpos].RegSelecionado
                                     to s_cts06m09c[l_cscr].f_RegSelecionado

                                on key (F5)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para historico
                                    #------------------------------
                                    if la_cdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()

                                    call cts06n01(
                                        la_cdados[l_cpos].NumeroServico
                                       ,la_cdados[l_cpos].AnoServico
                                       ,la_cdados[l_cpos].NumeroVistoria
                                       ,g_issk.funmat
                                       ,today
                                       ,current hour to minute)

                                on key (F8)
                                    #------------------------------
                                    # Verifica se existem multiplos
                                    # registros selecionados
                                    #------------------------------
                                    initialize ma_aciona to null
                                    initialize ma_telacn to null

                                    if la_cdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cont = 0
                                    for l_tpos = 1 to 10
                                        if la_cftela[l_tpos].DiaMesVistoria
                                           is null then
                                            exit for
                                        end if
                                        if la_cftela[l_tpos].RegSelecionado
                                           = '*' then
                                            let l_cont = (l_cont + 1)
                                        end if
                                    end for

                                    #---------------------------------------
                                    # Inicializa para verificar cancelamento
                                    #---------------------------------------
                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''

                                    #---------------------------------------
                                    # Se nao houver multipla selecao utiliza
                                    # apenas o registro atual
                                    #---------------------------------------
                                    if l_cont = 0 then

                                        let l_tpos = arr_curr()
                                        let l_vpos = 1

                                        #-----------------------------------------
                                        # Verifica se a vistoria nao foi cancelada
                                        #-----------------------------------------
                                        whenever error continue
                                        open  ccts06m09018
                                        using la_cdados[l_tpos].AnoServico
                                             ,la_cdados[l_tpos].NumeroServico
                                        fetch ccts06m09018
                                        whenever error stop
                                        if sqlca.sqlcode = 0 then
                                            let lr_ret_AcionaVP.Codigo   = 33
                                            let lr_ret_AcionaVP.Mensagem =
                                                ' Atencao! Esta vistoria foi cancelada! '
                                        else

                                            let ma_aciona[l_vpos].NumeroServico =
                                                la_cdados[l_tpos].NumeroServico
                                            let ma_aciona[l_vpos].AnoServico =
                                                la_cdados[l_tpos].AnoServico
                                            let ma_aciona[l_vpos].NumeroVistoria =
                                                la_cdados[l_tpos].NumeroVistoria
                                            let ma_aciona[l_vpos].DataVistoria =
                                                la_cdados[l_tpos].DataVistoria
                                            let ma_aciona[l_vpos].UF =
                                                la_cdados[l_tpos].UF
                                            let ma_aciona[l_vpos].NomeCidade =
                                                la_cdados[l_tpos].NomeCidade
                                            let ma_aciona[l_vpos].NomeBairro =
                                                la_cdados[l_tpos].NomeBairro
                                            let ma_aciona[l_vpos].NomeSubBairro =
                                                la_cdados[l_tpos].NomeSubBairro
                                            let ma_aciona[l_vpos].Endereco =
                                                la_cdados[l_tpos].Endereco

                                            let ma_telacn[l_vpos].DiaMesVistoria =
                                                la_cftela[l_tpos].DiaMesVistoria
                                            let ma_telacn[l_vpos].Prioridade =
                                                la_cftela[l_tpos].Prioridade
                                            let ma_telacn[l_vpos].CodigoEmpresa =
                                                la_cftela[l_tpos].CodigoEmpresa
                                            let ma_telacn[l_vpos].EnderecoExibicao =
                                                la_cftela[l_tpos].EnderecoExibicao
                                            let ma_telacn[l_vpos].HorarioPref =
                                                la_cftela[l_tpos].HorarioPref

                                            let l_vpos = (l_vpos + 1)

                                        end if

                                    else

                                        #-------------------------------------
                                        # Se houver multipla selecao transfere
                                        # os registros selecionados
                                        #-------------------------------------
                                        let l_vpos = 1
                                        for l_tpos = 1 to 10

                                            if la_cftela[l_tpos].DiaMesVistoria
                                               is null then
                                                exit for
                                            end if

                                            if la_cftela[l_tpos].RegSelecionado
                                                = '*' then

                                                #-----------------------------------------
                                                # Verifica se a vistoria nao foi cancelada
                                                #-----------------------------------------
                                                whenever error continue
                                                open  ccts06m09018
                                                using la_cdados[l_tpos].AnoServico
                                                     ,la_cdados[l_tpos].NumeroServico
                                                fetch ccts06m09018
                                                whenever error stop
                                                if sqlca.sqlcode = 0 then
                                                    let lr_ret_AcionaVP.Codigo   = 33
                                                    let lr_ret_AcionaVP.Mensagem =
                                                        ' Atencao! Uma ou mais vistorias '
                                                       ,' foram canceladas! Consulte novamente!'
                                                else

                                                    let ma_aciona[l_vpos].NumeroServico =
                                                        la_cdados[l_tpos].NumeroServico
                                                    let ma_aciona[l_vpos].AnoServico =
                                                        la_cdados[l_tpos].AnoServico
                                                    let ma_aciona[l_vpos].NumeroVistoria =
                                                        la_cdados[l_tpos].NumeroVistoria
                                                    let ma_aciona[l_vpos].DataVistoria =
                                                        la_cdados[l_tpos].DataVistoria
                                                    let ma_aciona[l_vpos].UF =
                                                        la_cdados[l_tpos].UF
                                                    let ma_aciona[l_vpos].NomeCidade =
                                                        la_cdados[l_tpos].NomeCidade
                                                    let ma_aciona[l_vpos].NomeBairro =
                                                        la_cdados[l_tpos].NomeBairro
                                                    let ma_aciona[l_vpos].NomeSubBairro =
                                                        la_cdados[l_tpos].NomeSubBairro
                                                    let ma_aciona[l_vpos].Endereco =
                                                        la_cdados[l_tpos].Endereco

                                                    let ma_telacn[l_vpos].DiaMesVistoria =
                                                        la_cftela[l_tpos].DiaMesVistoria
                                                    let ma_telacn[l_vpos].Prioridade =
                                                        la_cftela[l_tpos].Prioridade
                                                    let ma_telacn[l_vpos].CodigoEmpresa =
                                                        la_cftela[l_tpos].CodigoEmpresa
                                                    let ma_telacn[l_vpos].EnderecoExibicao =
                                                        la_cftela[l_tpos].EnderecoExibicao
                                                    let ma_telacn[l_vpos].HorarioPref =
                                                        la_cftela[l_tpos].HorarioPref

                                                    let l_vpos = (l_vpos + 1)

                                                end if

                                            end if

                                        end for

                                    end if

                                    if lr_ret_AcionaVP.Codigo = 0 then
                                        let lr_ret_AcionaVP.Codigo   = 0
                                        let lr_ret_AcionaVP.Mensagem = ''
                                        call cts06m09_AcionaVP()
                                        returning lr_ret_AcionaVP.Codigo
                                                 ,lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo is not null and
                                           lr_ret_AcionaVP.Codigo <> 0 then
                                            error lr_ret_AcionaVP.Mensagem
                                            if lr_ret_AcionaVP.Codigo = 22 then
                                                exit display
                                            end if
                                        end if
                                    else
                                        error lr_ret_AcionaVP.Mensagem
                                    end if

                            end display

                            let int_flag = false
                            close window cts06m09c

                            if lr_ret_AcionaVP.Codigo = 22 then
                                exit display
                            end if

                        on key (control-p,control-f)

                            #-------------------------------
                            # Recupera vistorias acionadas e
                            # pendentes de cadastramento
                            #-------------------------------
                            initialize la_pdados    to null
                            initialize la_pftela    to null

                            let l_cpos = arr_curr()

                            #----------------------------------
                            # Recupera as marcacoes de vistoria
                            # previa nao acionadas
                            #----------------------------------
                            open  ccts06m09016
                            using la_rdados[l_pos].DataVistoria
                                 ,la_rbases[l_cpos].SiglaVeiculo

                            let l_vpos = 1

                            foreach ccts06m09016
                               into la_pdados[l_vpos].NumeroServico
                                   ,la_pdados[l_vpos].AnoServico
                                   ,la_pdados[l_vpos].NumeroVistoria
                                   ,la_pdados[l_vpos].DataVistoria
                                   ,la_pftela[l_vpos].DiaMesVistoria
                                   ,la_pftela[l_vpos].Prioridade
                                   ,la_pftela[l_vpos].CodigoEmpresa
                                   ,la_pdados[l_vpos].UF
                                   ,la_pdados[l_vpos].NomeCidade
                                   ,la_pdados[l_vpos].NomeBairro
                                   ,la_pdados[l_vpos].NomeSubBairro
                                   ,la_pdados[l_vpos].Endereco
                                   ,la_pftela[l_vpos].HorarioPref

		                #--> VP-Online-2.0 (inicio)

                                #--------------------------------------
                                # Verificar se a vistoria esta pendente
                                #--------------------------------------
		                if fgl_lastkey() = fgl_keyval("control-p") then 
		                   let l_cont = 0 
                                   open  ccts06m09011b using la_pdados[l_vpos].AnoServico
                                                            ,la_pdados[l_vpos].NumeroServico
		                                            ,la_rbases[l_cpos].SiglaVeiculo
                                   fetch ccts06m09011b into  l_cont 
                                   close ccts06m09011b
                                   if l_cont is null or l_cont <= 0 then
		                      continue foreach
		                   end if
		                end if 

                                #-------------------------------------
                                # Verificar se a vistoria foi acionada 
                                #-------------------------------------
		                if fgl_lastkey() = fgl_keyval("control-f") then 
		                   let l_cont = 0 
                                   open  ccts06m09010b using la_pdados[l_vpos].AnoServico
                                                            ,la_pdados[l_vpos].NumeroServico
		                                            ,la_rbases[l_cpos].SiglaVeiculo
                                   fetch ccts06m09010b into  l_cont 
                                   close ccts06m09010b
                                   if l_cont is null or l_cont <= 0 then
		                      continue foreach
		                   end if
		                end if

		                #--> VP-Online-2.0 (fim)

                                #-----------------------------
                                # Monta o endereco de exibicao
                                # do final para o inicio
                                #-----------------------------
                                let la_pftela[l_vpos].EnderecoExibicao =
                                    la_pdados[l_vpos].Endereco clipped

                                #-------------------------------------
                                # Inclui o SubBairro antes do Endereco
                                #-------------------------------------
                                if la_pdados[l_vpos].NomeSubBairro <>
                                   la_pdados[l_vpos].NomeBairro then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeSubBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------------------
                                # Inclui o Bairro antes do Endereco/SubBairro
                                #--------------------------------------------
                                if lr_filtro.FiltraBairro = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------
                                # Inclui a Cidade antes do Bairro
                                #--------------------------------
                                if lr_filtro.FiltraCidade = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeCidade[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                #----------------------------
                                # Inclui a UF antes da Cidade
                                #----------------------------
                                if lr_filtro.FiltraUF = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].UF clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                let l_vpos = (l_vpos + 1)

                            end foreach

                            let l_vpos = (l_vpos - 1)

                         #------------------------------------------------------------------
                         # Se nao houver dados para exibicao volta ao filtro (VP-Online-2.0)
                         #------------------------------------------------------------------
                         if l_vpos = 0 then
                             error ' Nao existem registros para serem exibidos! '
                         else  

                            call set_count(l_vpos)
                            let int_flag = false

                            open window cts06m09c at 07,02
                            with form 'cts06m09c'
                            attribute(form line 1)

                            #-------------------------------------------
                            # Limpa a sigla do veiculo caso acione daqui
                            #-------------------------------------------
                            initialize mr_veiculo to null
                            let mr_veiculo.SiglaVeiculoAnterior =
                                la_rbases[l_cpos].SiglaVeiculo

                            display la_rbases[l_cpos].SiglaVeiculo
                                 to f_SiglaVeiculo
                            display la_rbases[l_cpos].NomeInspetor
                                 to f_NomeInspetor
                            display la_xbases[l_cpos].LimiteKM
                                 to f_LimiteKM
                            display la_rbases[l_cpos].QtdVistoriasAcn
                                 to f_QtdVistoriasAcn
                            display la_rbases[l_cpos].QtdVistoriasPend
                                 to f_QtdVistoriasPend
                            display '(Acionadas Pend)'
                                 to f_TipoVistoria

                            message 'F1-Info|F2-Sel|F3-PgDn|F4-PgUp|F5-Hist|'
                                   ,'F8-Alt.Acn|Ct+C-Sai'

                            display array la_pftela to s_cts06m09c.*
                                    attribute (current row display = 'reverse')

                                on key (interrupt,control-c)
                                    let int_flag = false
                                    exit display

                                on key (F1)
                                    #-----------------------------
                                    # Recupera os dados auxiliares
                                    # da vistoria selecionada
                                    #-----------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''
                                    let l_cpos = arr_curr()

                                    call cts06m09_ExibeInfo(
                                         la_pdados[l_cpos].NumeroServico
                                        ,la_pdados[l_cpos].AnoServico
                                        ,la_pdados[l_cpos].NomeBairro
                                        ,la_pdados[l_cpos].NomeSubBairro
                                        ,la_pdados[l_cpos].NumeroVistoria
                                        ,la_pdados[l_cpos].DataVistoria
                                        ,la_pftela[l_cpos].HorarioPref
                                        ,la_pftela[l_cpos].Prioridade
                                        ,la_pdados[l_cpos].Endereco
                                        ,la_pdados[l_cpos].NomeCidade
                                        ,la_pdados[l_cpos].UF)
                                    returning lr_ret_AcionaVP.Codigo
                                             ,lr_ret_AcionaVP.Mensagem
                                    if lr_ret_AcionaVP.Codigo is not null and
                                       lr_ret_AcionaVP.Codigo <> 0 then
                                        error lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo = 22 then
                                            exit display
                                        end if
                                    end if

                                on key (F2)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para acionamento
                                    #------------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()
                                    let l_cscr = scr_line()

                                    let l_sel =
                                        la_pftela[l_cpos].RegSelecionado
                                    if l_sel = '*' then
                                        let la_pftela[l_cpos].RegSelecionado
                                        = ' '
                                    else
                                        let la_pftela[l_cpos].RegSelecionado
                                        = '*'
                                    end if

                                    display la_pftela[l_cpos].RegSelecionado
                                     to s_cts06m09c[l_cscr].f_RegSelecionado

                                on key (F5)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para historico
                                    #------------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()

                                    call cts06n01(
                                        la_pdados[l_cpos].NumeroServico
                                       ,la_pdados[l_cpos].AnoServico
                                       ,la_pdados[l_cpos].NumeroVistoria
                                       ,g_issk.funmat
                                       ,today
                                       ,current hour to minute)

                                on key (F8)
                                    #------------------------------
                                    # Verifica se existem multiplos
                                    # registros selecionados
                                    #------------------------------
                                    initialize ma_aciona to null
                                    initialize ma_telacn to null

                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cont = 0
                                    for l_tpos = 1 to 10
                                        if la_pftela[l_tpos].DiaMesVistoria
                                           is null then
                                            exit for
                                        end if
                                        if la_pftela[l_tpos].RegSelecionado
                                           = '*' then
                                            let l_cont = (l_cont + 1)
                                        end if
                                    end for

                                    #----------------------------------------
                                    # Inicializa para utilizar na verificacao
                                    # do cancelamento
                                    #----------------------------------------
                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''

                                    #---------------------------------------
                                    # Se nao houver multipla selecao utiliza
                                    # apenas o registro atual
                                    #---------------------------------------
                                    if l_cont = 0 then

                                        let l_tpos = arr_curr()
                                        let l_vpos = 1

                                        #-----------------------------------------
                                        # Verifica se a vistoria nao foi cancelada
                                        #-----------------------------------------
                                        whenever error continue
                                        open  ccts06m09018
                                        using la_pdados[l_tpos].AnoServico
                                             ,la_pdados[l_tpos].NumeroServico
                                        fetch ccts06m09018
                                        whenever error stop
                                        if sqlca.sqlcode = 0 then
                                            let lr_ret_AcionaVP.Codigo   = 33
                                            let lr_ret_AcionaVP.Mensagem =
                                                ' Atencao! Esta vistoria foi cancelada! '
                                        else

                                            let ma_aciona[l_vpos].NumeroServico =
                                                la_pdados[l_tpos].NumeroServico
                                            let ma_aciona[l_vpos].AnoServico =
                                                la_pdados[l_tpos].AnoServico
                                            let ma_aciona[l_vpos].NumeroVistoria =
                                                la_pdados[l_tpos].NumeroVistoria
                                            let ma_aciona[l_vpos].DataVistoria =
                                                la_pdados[l_tpos].DataVistoria
                                            let ma_aciona[l_vpos].UF =
                                                la_pdados[l_tpos].UF
                                            let ma_aciona[l_vpos].NomeCidade =
                                                la_pdados[l_tpos].NomeCidade
                                            let ma_aciona[l_vpos].NomeBairro =
                                                la_pdados[l_tpos].NomeBairro
                                            let ma_aciona[l_vpos].NomeSubBairro =
                                                la_pdados[l_tpos].NomeSubBairro
                                            let ma_aciona[l_vpos].Endereco =
                                                la_pdados[l_tpos].Endereco

                                            let ma_telacn[l_vpos].DiaMesVistoria =
                                                la_pftela[l_tpos].DiaMesVistoria
                                            let ma_telacn[l_vpos].Prioridade =
                                                la_pftela[l_tpos].Prioridade
                                            let ma_telacn[l_vpos].CodigoEmpresa =
                                                la_pftela[l_tpos].CodigoEmpresa
                                            let ma_telacn[l_vpos].EnderecoExibicao =
                                                la_pftela[l_tpos].EnderecoExibicao
                                            let ma_telacn[l_vpos].HorarioPref =
                                                la_pftela[l_tpos].HorarioPref

                                            let l_vpos = (l_vpos + 1)

                                        end if

                                    else

                                        #-------------------------------------
                                        # Se houver multipla selecao transfere
                                        # os registros selecionados
                                        #-------------------------------------
                                        let l_vpos = 1
                                        for l_tpos = 1 to 10

                                            if la_pftela[l_tpos].DiaMesVistoria
                                               is null then
                                                exit for
                                            end if

                                            if la_pftela[l_tpos].RegSelecionado
                                               = '*' then

                                                #-----------------------------------------
                                                # Verifica se a vistoria nao foi cancelada
                                                #-----------------------------------------
                                                whenever error continue
                                                open  ccts06m09018
                                                using la_pdados[l_tpos].AnoServico
                                                     ,la_pdados[l_tpos].NumeroServico
                                                fetch ccts06m09018
                                                whenever error stop
                                                if sqlca.sqlcode = 0 then
                                                    let lr_ret_AcionaVP.Codigo   = 33
                                                    let lr_ret_AcionaVP.Mensagem =
                                                        ' Atencao! Uma ou mais vistorias '
                                                       ,' foram canceladas! Consulte novamente!'
                                                else

                                                    let ma_aciona[l_vpos].NumeroServico =
                                                        la_pdados[l_tpos].NumeroServico
                                                    let ma_aciona[l_vpos].AnoServico =
                                                        la_pdados[l_tpos].AnoServico
                                                    let ma_aciona[l_vpos].NumeroVistoria =
                                                        la_pdados[l_tpos].NumeroVistoria
                                                    let ma_aciona[l_vpos].DataVistoria =
                                                        la_pdados[l_tpos].DataVistoria
                                                    let ma_aciona[l_vpos].UF =
                                                        la_pdados[l_tpos].UF
                                                    let ma_aciona[l_vpos].NomeCidade =
                                                        la_pdados[l_tpos].NomeCidade
                                                    let ma_aciona[l_vpos].NomeBairro =
                                                        la_pdados[l_tpos].NomeBairro
                                                    let ma_aciona[l_vpos].NomeSubBairro =
                                                        la_pdados[l_tpos].NomeSubBairro
                                                    let ma_aciona[l_vpos].Endereco =
                                                        la_pdados[l_tpos].Endereco

                                                    let ma_telacn[l_vpos].DiaMesVistoria =
                                                        la_pftela[l_tpos].DiaMesVistoria
                                                    let ma_telacn[l_vpos].Prioridade =
                                                        la_pftela[l_tpos].Prioridade
                                                    let ma_telacn[l_vpos].CodigoEmpresa =
                                                        la_pftela[l_tpos].CodigoEmpresa
                                                    let ma_telacn[l_vpos].EnderecoExibicao =
                                                        la_pftela[l_tpos].EnderecoExibicao
                                                    let ma_telacn[l_vpos].HorarioPref =
                                                        la_pftela[l_tpos].HorarioPref

                                                    let l_vpos = (l_vpos + 1)

                                                end if

                                            end if

                                        end for

                                    end if

                                    if lr_ret_AcionaVP.Codigo = 0 then
                                        let lr_ret_AcionaVP.Codigo   = 0
                                        let lr_ret_AcionaVP.Mensagem = ''
                                        call cts06m09_AcionaVP()
                                        returning lr_ret_AcionaVP.Codigo
                                                 ,lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo is not null and
                                           lr_ret_AcionaVP.Codigo <> 0 then
                                            error lr_ret_AcionaVP.Mensagem
                                            if lr_ret_AcionaVP.Codigo = 22 then
                                                exit display
                                            end if
                                        end if
                                    else
                                        error lr_ret_AcionaVP.Mensagem
                                    end if

                            end display

                            let int_flag = false
                            close window cts06m09c

                            if lr_ret_AcionaVP.Codigo = 22 then
                                exit display
                            end if

                         end if

                        on key (F8)

                            #-------------------------------
                            # Aciona apenas a vistoria atual
                            # para o prestador selecionado
                            #-------------------------------
                            initialize ma_aciona to null
                            initialize ma_telacn to null

                            if la_rbases[1].SiglaVeiculo is null then
                                error ' Prestadores nao encontrados! '
                                exit display
                            end if

                            #-------------------------------
                            # Prestador selecionado do array
                            #-------------------------------
                            let l_tpos = arr_curr()
                            initialize mr_veiculo to null
                            let mr_veiculo.SiglaVeiculo =
                                la_rbases[l_tpos].SiglaVeiculo

                            #-----------------------------------
                            # Vistoria selecionada anteriormente
                            #-----------------------------------
                            let l_vpos = 1
                            let l_tpos = l_pos

                            #-----------------------------------------
                            # Verifica se a vistoria nao foi cancelada
                            #-----------------------------------------
                            whenever error continue
                            open  ccts06m09018
                            using la_rdados[l_tpos].AnoServico
                                 ,la_rdados[l_tpos].NumeroServico
                            fetch ccts06m09018
                            whenever error stop
                            if sqlca.sqlcode = 0 then
                                error ' Atencao! Esta vistoria foi cancelada! '
                            else

                                let ma_aciona[l_vpos].NumeroServico =
                                    la_rdados[l_tpos].NumeroServico
                                let ma_aciona[l_vpos].AnoServico =
                                    la_rdados[l_tpos].AnoServico
                                let ma_aciona[l_vpos].NumeroVistoria =
                                    la_rdados[l_tpos].NumeroVistoria
                                let ma_aciona[l_vpos].DataVistoria =
                                    la_rdados[l_tpos].DataVistoria
                                let ma_aciona[l_vpos].UF =
                                    la_rdados[l_tpos].UF
                                let ma_aciona[l_vpos].NomeCidade =
                                    la_rdados[l_tpos].NomeCidade
                                let ma_aciona[l_vpos].NomeBairro =
                                    la_rdados[l_tpos].NomeBairro
                                let ma_aciona[l_vpos].NomeSubBairro =
                                    la_rdados[l_tpos].NomeSubBairro
                                let ma_aciona[l_vpos].Endereco =
                                    la_rdados[l_tpos].Endereco

                                let ma_telacn[l_vpos].DiaMesVistoria =
                                    la_rftela[l_tpos].DiaMesVistoria
                                let ma_telacn[l_vpos].Prioridade =
                                    la_rftela[l_tpos].Prioridade
                                let ma_telacn[l_vpos].CodigoEmpresa =
                                    la_rftela[l_tpos].CodigoEmpresa
                                let ma_telacn[l_vpos].EnderecoExibicao =
                                    la_rftela[l_tpos].EnderecoExibicao
                                let ma_telacn[l_vpos].HorarioPref =
                                    la_rftela[l_tpos].HorarioPref

                                let lr_ret_AcionaVP.Codigo   = 0
                                let lr_ret_AcionaVP.Mensagem = ''
                                call cts06m09_AcionaVP()
                                returning lr_ret_AcionaVP.Codigo
                                         ,lr_ret_AcionaVP.Mensagem
                                if lr_ret_AcionaVP.Codigo is not null and
                                   lr_ret_AcionaVP.Codigo <> 0 then
                                    error lr_ret_AcionaVP.Mensagem
                                    if lr_ret_AcionaVP.Codigo = 22 then
                                        exit display
                                    end if
                                end if

                            end if

                    end display

                    let int_flag = false
                    close window cts06m09b

                    if lr_ret_AcionaVP.Codigo = 22 then
                        exit display
                    end if

                on key (F7)
                    #-----------------------------------------
                    # Recupera os 10 prestadores mais proximos
                    #-----------------------------------------
                    initialize la_rbases to null
                    initialize la_xbases to null
                    initialize lr_infocp to null

                    let l_pos = arr_curr()

                    open  ccts06m09007
                    using la_rdados[l_pos].NumeroServico
                         ,la_rdados[l_pos].AnoServico
                    fetch ccts06m09007
                    into  lr_infocp.CodigoEmpresa
                         ,lr_infocp.DiaSemanaVistoria
                         ,lr_infocp.CodigoCidade
                    close ccts06m09007

                    open  ccts06m09009
                    using lr_infocp.CodigoCidade
                         ,lr_infocp.CodigoEmpresa
                         ,lr_infocp.DiaSemanaVistoria
                         ,lr_infocp.CodigoEmpresa
                         ,lr_infocp.CodigoEmpresa

                    let l_scr = 1

                    foreach ccts06m09009
                       into la_rbases[l_scr].SiglaVeiculo
                           ,la_rbases[l_scr].NomeInspetor
                           ,la_rbases[l_scr].BairroBase
                           ,la_rbases[l_scr].Distancia
                        #----------------------------------
                        # Quantidade de vistorias acionadas
                        #----------------------------------
                        open  ccts06m09010
                        using la_rdados[l_pos].DataVistoria
                             ,la_rbases[l_scr].SiglaVeiculo
                        fetch ccts06m09010
                        into  la_rbases[l_scr].QtdVistoriasAcn
                        close ccts06m09010
                        #----------------------------------
                        # Quantidade de vistorias pendentes
                        #----------------------------------
                        open  ccts06m09011
                        using la_rdados[l_pos].DataVistoria
                             ,la_rbases[l_scr].SiglaVeiculo
                        fetch ccts06m09011
                        into  la_rbases[l_scr].QtdVistoriasPend
                        close ccts06m09011
                        #----------------------------------
                        let l_scr = (l_scr + 1)
                        #----------------------------------
                    end foreach
                    close ccts06m09009

                    open window cts06m09b at 07,02
                    with form 'cts06m09b'
                    attribute(form line 1)

                    display la_rdados[l_pos].NumeroVistoria
                         to f_NumeroVistoria
                    display 'Cidade:'
                         to f_TipoLocal
                    display la_rdados[l_pos].NomeCidade
                         to f_BairroVistoria
                    display la_rftela[l_pos].DiaMesVistoria
                         to f_DiaMesVistoria
                    display 'Posto'
                         to f_TipoInspetor

                    message 'F3-PgDn | F4-PgUp | F8-Acn | CtrP-Pnd | CtrY-Acn | CtrC-Sai'

                    let l_scr = (l_scr - 1)
                    call set_count(l_scr)

                    display array la_rbases to s_cts06m09b.*
                            attribute (current row display = 'reverse')

                        on key (control-p,control-f)

                            #-------------------------------
                            # Recupera vistorias acionadas e
                            # pendentes de cadastramento
                            #-------------------------------
                            initialize la_pdados    to null
                            initialize la_pftela    to null

                            if la_rbases[1].SiglaVeiculo is null then
                                error ' Bases nao encontradas! '
                                exit display
                            end if

                            let l_cpos = arr_curr()

                            #----------------------------------
                            # Recupera as marcacoes de vistoria
                            # previa nao acionadas
                            #----------------------------------
                            open  ccts06m09016
                            using la_rdados[l_pos].DataVistoria
                                 ,la_rbases[l_cpos].SiglaVeiculo

                            let l_vpos = 1

                            foreach ccts06m09016
                               into la_pdados[l_vpos].NumeroServico
                                   ,la_pdados[l_vpos].AnoServico
                                   ,la_pdados[l_vpos].NumeroVistoria
                                   ,la_pdados[l_vpos].DataVistoria
                                   ,la_pftela[l_vpos].DiaMesVistoria
                                   ,la_pftela[l_vpos].Prioridade
                                   ,la_pftela[l_vpos].CodigoEmpresa
                                   ,la_pdados[l_vpos].UF
                                   ,la_pdados[l_vpos].NomeCidade
                                   ,la_pdados[l_vpos].NomeBairro
                                   ,la_pdados[l_vpos].NomeSubBairro
                                   ,la_pdados[l_vpos].Endereco
                                   ,la_pftela[l_vpos].HorarioPref

		                #--> VP-Online-2.0 (inicio)

                                #--------------------------------------
                                # Verificar se a vistoria esta pendente
                                #--------------------------------------
		                if fgl_lastkey() = fgl_keyval("control-p") then 
		                   let l_cont = 0 
                                   open  ccts06m09011b using la_pdados[l_vpos].AnoServico
                                                            ,la_pdados[l_vpos].NumeroServico
		                                            ,la_rbases[l_cpos].SiglaVeiculo
                                   fetch ccts06m09011b into  l_cont 
                                   close ccts06m09011b
                                   if l_cont is null or l_cont <= 0 then
		                      continue foreach
		                   end if
		                end if 

                                #-------------------------------------
                                # Verificar se a vistoria foi acionada 
                                #-------------------------------------
		                if fgl_lastkey() = fgl_keyval("control-f") then 
		                   let l_cont = 0 
                                   open  ccts06m09010b using la_pdados[l_vpos].AnoServico
                                                            ,la_pdados[l_vpos].NumeroServico
		                                            ,la_rbases[l_cpos].SiglaVeiculo
                                   fetch ccts06m09010b into  l_cont 
                                   close ccts06m09010b
                                   if l_cont is null or l_cont <= 0 then
		                      continue foreach
		                   end if
		                end if

		                #--> VP-Online-2.0 (fim)

                                #-----------------------------
                                # Monta o endereco de exibicao
                                # do final para o inicio
                                #-----------------------------
                                let la_pftela[l_vpos].EnderecoExibicao =
                                    la_pdados[l_vpos].Endereco clipped

                                #-------------------------------------
                                # Inclui o SubBairro antes do Endereco
                                #-------------------------------------
                                if la_pdados[l_vpos].NomeSubBairro <>
                                   la_pdados[l_vpos].NomeBairro then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeSubBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------------------
                                # Inclui o Bairro antes do Endereco/SubBairro
                                #--------------------------------------------
                                if lr_filtro.FiltraBairro = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeBairro[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                end if

                                #--------------------------------
                                # Inclui a Cidade antes do Bairro
                                #--------------------------------
                                if lr_filtro.FiltraCidade = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].NomeCidade[1,20]
                                        clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                #----------------------------
                                # Inclui a UF antes da Cidade
                                #----------------------------
                                if lr_filtro.FiltraUF = 1 then
                                    let la_pftela[l_vpos].EnderecoExibicao =
                                        la_pdados[l_vpos].UF clipped
                                       ,'/'
                                       ,la_pftela[l_vpos].EnderecoExibicao
                                       clipped
                                end if

                                let l_vpos = (l_vpos + 1)

                            end foreach

                            let l_vpos = (l_vpos - 1)

                         #------------------------------------------------------------------
                         # Se nao houver dados para exibicao volta ao filtro (VP-Online-2.0)
                         #------------------------------------------------------------------
                         if l_vpos = 0 then
                             error ' Nao existem registros para serem exibidos! '
                         else  

                            call set_count(l_vpos)
                            let int_flag = false

                            open window cts06m09c at 07,02
                            with form 'cts06m09c'
                            attribute(form line 1)

                            #-------------------------------------------
                            # Limpa a sigla do veiculo caso acione daqui
                            #-------------------------------------------
                            initialize mr_veiculo to null
                            let mr_veiculo.SiglaVeiculoAnterior =
                                la_rbases[l_cpos].SiglaVeiculo

                            display la_rbases[l_cpos].SiglaVeiculo
                                 to f_SiglaVeiculo
                            display la_rbases[l_cpos].NomeInspetor
                                 to f_NomeInspetor
                            display la_xbases[l_cpos].LimiteKM
                                 to f_LimiteKM
                            display la_rbases[l_cpos].QtdVistoriasAcn
                                 to f_QtdVistoriasAcn
                            display la_rbases[l_cpos].QtdVistoriasPend
                                 to f_QtdVistoriasPend
                            display '(Acionadas Pend)'
                                 to f_TipoVistoria

                            message 'F1-Info|F2-Sel|F3-PgDn|F4-PgUp|F5-Hist|'
                                   ,'F8-Alt.Acn|Ct+C-Sai'

                            display array la_pftela to s_cts06m09c.*
                                    attribute (current row display = 'reverse')

                                on key (interrupt,control-c)
                                    let int_flag = false
                                    exit display

                                on key (F1)
                                    #-----------------------------
                                    # Recupera os dados auxiliares
                                    # da vistoria selecionada
                                    #-----------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if
                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''
                                    let l_cpos = arr_curr()
                                    call cts06m09_ExibeInfo(
                                         la_pdados[l_cpos].NumeroServico
                                        ,la_pdados[l_cpos].AnoServico
                                        ,la_pdados[l_cpos].NomeBairro
                                        ,la_pdados[l_cpos].NomeSubBairro
                                        ,la_pdados[l_cpos].NumeroVistoria
                                        ,la_pdados[l_cpos].DataVistoria
                                        ,la_pftela[l_cpos].HorarioPref
                                        ,la_pftela[l_cpos].Prioridade
                                        ,la_pdados[l_cpos].Endereco
                                        ,la_pdados[l_cpos].NomeCidade
                                        ,la_pdados[l_cpos].UF)
                                    returning lr_ret_AcionaVP.Codigo
                                             ,lr_ret_AcionaVP.Mensagem
                                    if lr_ret_AcionaVP.Codigo is not null and
                                       lr_ret_AcionaVP.Codigo <> 0 then
                                        error lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo = 22 then
                                            exit display
                                        end if
                                    end if

                                on key (F2)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para acionamento
                                    #------------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()
                                    let l_cscr = scr_line()

                                    let l_sel =
                                        la_pftela[l_cpos].RegSelecionado
                                    if l_sel = '*' then
                                        let la_pftela[l_cpos].RegSelecionado
                                        = ' '
                                    else
                                        let la_pftela[l_cpos].RegSelecionado
                                        = '*'
                                    end if

                                    display la_pftela[l_cpos].RegSelecionado
                                     to s_cts06m09c[l_cscr].f_RegSelecionado

                                on key (F5)
                                    #------------------------------
                                    # Seleciona o registro corrente
                                    # para historico
                                    #------------------------------
                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cpos = arr_curr()
                                    call cts06n01(
                                        la_pdados[l_cpos].NumeroServico
                                       ,la_pdados[l_cpos].AnoServico
                                       ,la_pdados[l_cpos].NumeroVistoria
                                       ,g_issk.funmat
                                       ,today
                                       ,current hour to minute)

                                on key (F8)
                                    #------------------------------
                                    # Verifica se existem multiplos
                                    # registros selecionados
                                    #------------------------------
                                    initialize ma_aciona to null
                                    initialize ma_telacn to null

                                    if la_pdados[1].NumeroServico is null then
                                        error ' Vistorias nao encontradas! '
                                        exit display
                                    end if

                                    let l_cont = 0
                                    for l_tpos = 1 to 10
                                        if la_pftela[l_tpos].DiaMesVistoria
                                           is null then
                                            exit for
                                        end if
                                        if la_pftela[l_tpos].RegSelecionado
                                            = '*' then
                                            let l_cont = (l_cont + 1)
                                        end if
                                    end for

                                    #----------------------------
                                    # Inicializa para utilizar na
                                    # verificacao do cancelamento
                                    #----------------------------
                                    let lr_ret_AcionaVP.Codigo   = 0
                                    let lr_ret_AcionaVP.Mensagem = ''

                                    #---------------------------------------
                                    # Se nao houver multipla selecao utiliza
                                    # apenas o registro atual
                                    #---------------------------------------
                                    if l_cont = 0 then

                                        let l_tpos = arr_curr()
                                        let l_vpos = 1

                                        #-----------------------------------------
                                        # Verifica se a vistoria nao foi cancelada
                                        #-----------------------------------------
                                        whenever error continue
                                        open  ccts06m09018
                                        using la_pdados[l_tpos].AnoServico
                                             ,la_pdados[l_tpos].NumeroServico
                                        fetch ccts06m09018
                                        whenever error stop
                                        if sqlca.sqlcode = 0 then
                                            let lr_ret_AcionaVP.Codigo   = 33
                                            let lr_ret_AcionaVP.Mensagem =
                                                ' Atencao! Esta vistoria foi cancelada! '
                                        else

                                            let ma_aciona[l_vpos].NumeroServico =
                                                la_pdados[l_tpos].NumeroServico
                                            let ma_aciona[l_vpos].AnoServico =
                                                la_pdados[l_tpos].AnoServico
                                            let ma_aciona[l_vpos].NumeroVistoria =
                                                la_pdados[l_tpos].NumeroVistoria
                                            let ma_aciona[l_vpos].DataVistoria =
                                                la_pdados[l_tpos].DataVistoria
                                            let ma_aciona[l_vpos].UF =
                                                la_pdados[l_tpos].UF
                                            let ma_aciona[l_vpos].NomeCidade =
                                                la_pdados[l_tpos].NomeCidade
                                            let ma_aciona[l_vpos].NomeBairro =
                                                la_pdados[l_tpos].NomeBairro
                                            let ma_aciona[l_vpos].NomeSubBairro =
                                                la_pdados[l_tpos].NomeSubBairro
                                            let ma_aciona[l_vpos].Endereco =
                                                la_pdados[l_tpos].Endereco

                                            let ma_telacn[l_vpos].DiaMesVistoria =
                                                la_pftela[l_tpos].DiaMesVistoria
                                            let ma_telacn[l_vpos].Prioridade =
                                                la_pftela[l_tpos].Prioridade
                                            let ma_telacn[l_vpos].CodigoEmpresa =
                                                la_pftela[l_tpos].CodigoEmpresa
                                            let ma_telacn[l_vpos].EnderecoExibicao =
                                                la_pftela[l_tpos].EnderecoExibicao
                                            let ma_telacn[l_vpos].HorarioPref =
                                                la_pftela[l_tpos].HorarioPref

                                            let l_vpos = (l_vpos + 1)

                                        end if

                                    else

                                        #-------------------------------------
                                        # Se houver multipla selecao transfere
                                        # os registros selecionados
                                        #-------------------------------------
                                        let l_vpos = 1
                                        for l_tpos = 1 to 10

                                            if la_pftela[l_tpos].DiaMesVistoria
                                               is null then
                                                exit for
                                            end if

                                            if la_pftela[l_tpos].RegSelecionado
                                               = '*' then

                                                #-----------------------------------------
                                                # Verifica se a vistoria nao foi cancelada
                                                #-----------------------------------------
                                                whenever error continue
                                                open  ccts06m09018
                                                using la_pdados[l_tpos].AnoServico
                                                     ,la_pdados[l_tpos].NumeroServico
                                                fetch ccts06m09018
                                                whenever error stop
                                                if sqlca.sqlcode = 0 then
                                                    let lr_ret_AcionaVP.Codigo   = 33
                                                    let lr_ret_AcionaVP.Mensagem =
                                                        ' Atencao! Uma ou mais vistorias '
                                                       ,' foram canceladas! Consulte novamente!'
                                                else

                                                    let ma_aciona[l_vpos].NumeroServico =
                                                        la_pdados[l_tpos].NumeroServico
                                                    let ma_aciona[l_vpos].AnoServico =
                                                        la_pdados[l_tpos].AnoServico
                                                    let ma_aciona[l_vpos].NumeroVistoria =
                                                        la_pdados[l_tpos].NumeroVistoria
                                                    let ma_aciona[l_vpos].DataVistoria =
                                                        la_pdados[l_tpos].DataVistoria
                                                    let ma_aciona[l_vpos].UF =
                                                        la_pdados[l_tpos].UF
                                                    let ma_aciona[l_vpos].NomeCidade =
                                                        la_pdados[l_tpos].NomeCidade
                                                    let ma_aciona[l_vpos].NomeBairro =
                                                        la_pdados[l_tpos].NomeBairro
                                                    let ma_aciona[l_vpos].NomeSubBairro =
                                                        la_pdados[l_tpos].NomeSubBairro
                                                    let ma_aciona[l_vpos].Endereco =
                                                        la_pdados[l_tpos].Endereco

                                                    let ma_telacn[l_vpos].DiaMesVistoria =
                                                        la_pftela[l_tpos].DiaMesVistoria
                                                    let ma_telacn[l_vpos].Prioridade =
                                                        la_pftela[l_tpos].Prioridade
                                                    let ma_telacn[l_vpos].CodigoEmpresa =
                                                        la_pftela[l_tpos].CodigoEmpresa
                                                    let ma_telacn[l_vpos].EnderecoExibicao =
                                                        la_pftela[l_tpos].EnderecoExibicao
                                                    let ma_telacn[l_vpos].HorarioPref =
                                                        la_pftela[l_tpos].HorarioPref

                                                    let l_vpos = (l_vpos + 1)

                                                end if

                                            end if

                                        end for

                                    end if

                                    if lr_ret_AcionaVP.Codigo = 0 then
                                        let lr_ret_AcionaVP.Codigo   = 0
                                        let lr_ret_AcionaVP.Mensagem = ''
                                        call cts06m09_AcionaVP()
                                        returning lr_ret_AcionaVP.Codigo
                                                 ,lr_ret_AcionaVP.Mensagem
                                        if lr_ret_AcionaVP.Codigo is not null and
                                           lr_ret_AcionaVP.Codigo <> 0 then
                                            error lr_ret_AcionaVP.Mensagem
                                            if lr_ret_AcionaVP.Codigo = 22 then
                                                exit display
                                            end if
                                        end if
                                    else
                                        error lr_ret_AcionaVP.Mensagem
                                    end if

                            end display

                            let int_flag = false
                            close window cts06m09c

                            if lr_ret_AcionaVP.Codigo = 22 then
                                exit display
                            end if

                         end if

                        on key (F8)

                            #-------------------------------
                            # Aciona apenas a vistoria atual
                            # para o prestador selecionado
                            #-------------------------------
                            initialize ma_aciona to null
                            initialize ma_telacn to null

                            if la_rbases[1].SiglaVeiculo is null then
                                error ' Bases nao encontradas! '
                                exit display
                            end if

                            #-------------------------------
                            # Prestador selecionado do array
                            #-------------------------------
                            let l_tpos = arr_curr()
                            initialize mr_veiculo to null
                            let mr_veiculo.SiglaVeiculo =
                                la_rbases[l_tpos].SiglaVeiculo

                            #-----------------------------------
                            # Vistoria selecionada anteriormente
                            #-----------------------------------
                            let l_vpos = 1
                            let l_tpos = l_pos

                            #-----------------------------------------
                            # Verifica se a vistoria nao foi cancelada
                            #-----------------------------------------
                            whenever error continue
                            open  ccts06m09018
                            using la_rdados[l_tpos].AnoServico
                                 ,la_rdados[l_tpos].NumeroServico
                            fetch ccts06m09018
                            whenever error stop
                            if sqlca.sqlcode = 0 then
                                error ' Atencao! Esta vistoria foi cancelada! '
                            else

                                let ma_aciona[l_vpos].NumeroServico =
                                    la_rdados[l_tpos].NumeroServico
                                let ma_aciona[l_vpos].AnoServico =
                                    la_rdados[l_tpos].AnoServico
                                let ma_aciona[l_vpos].NumeroVistoria =
                                    la_rdados[l_tpos].NumeroVistoria
                                let ma_aciona[l_vpos].DataVistoria =
                                    la_rdados[l_tpos].DataVistoria
                                let ma_aciona[l_vpos].UF =
                                    la_rdados[l_tpos].UF
                                let ma_aciona[l_vpos].NomeCidade =
                                    la_rdados[l_tpos].NomeCidade
                                let ma_aciona[l_vpos].NomeBairro =
                                    la_rdados[l_tpos].NomeBairro
                                let ma_aciona[l_vpos].NomeSubBairro =
                                    la_rdados[l_tpos].NomeSubBairro
                                let ma_aciona[l_vpos].Endereco =
                                    la_rdados[l_tpos].Endereco

                                let ma_telacn[l_vpos].DiaMesVistoria =
                                    la_rftela[l_tpos].DiaMesVistoria
                                let ma_telacn[l_vpos].Prioridade =
                                    la_rftela[l_tpos].Prioridade
                                let ma_telacn[l_vpos].CodigoEmpresa =
                                    la_rftela[l_tpos].CodigoEmpresa
                                let ma_telacn[l_vpos].EnderecoExibicao =
                                    la_rftela[l_tpos].EnderecoExibicao
                                let ma_telacn[l_vpos].HorarioPref =
                                    la_rftela[l_tpos].HorarioPref

                                let lr_ret_AcionaVP.Codigo   = 0
                                let lr_ret_AcionaVP.Mensagem = ''
                                call cts06m09_AcionaVP()
                                returning lr_ret_AcionaVP.Codigo
                                         ,lr_ret_AcionaVP.Mensagem
                                if lr_ret_AcionaVP.Codigo is not null and
                                   lr_ret_AcionaVP.Codigo <> 0 then
                                    error lr_ret_AcionaVP.Mensagem
                                    if lr_ret_AcionaVP.Codigo = 22 then
                                        exit display
                                    end if
                                end if

                            end if

                    end display

                    let int_flag = false
                    close window cts06m09b

                    if lr_ret_AcionaVP.Codigo = 22 then
                        exit display
                    end if

                on key (F8)
                    #-----------------------------------------------------
                    # Verifica se existem multiplos registros selecionados
                    #-----------------------------------------------------
                    initialize ma_aciona  to null
                    initialize ma_telacn  to null
                    initialize mr_veiculo to null

                    if la_rdados[1].NumeroServico is null then
                        error ' Vistorias nao encontradas! '
                        exit display
                    end if

                    let l_cont = 0
                    for l_tpos = 1 to 7000
                        if la_rftela[l_tpos].DiaMesVistoria is null then
                            exit for
                        end if
                        if la_rftela[l_tpos].RegSelecionado = '*' then
                            let l_cont = (l_cont + 1)
                        end if
                    end for

                    #--------------------------------------------------------
                    # Inicializa para utilizar na verificacao do cancelamento
                    #--------------------------------------------------------
                    let lr_ret_AcionaVP.Codigo   = 0
                    let lr_ret_AcionaVP.Mensagem = ''

                    #---------------------------------------
                    # Se nao houver multipla selecao utiliza
                    # apenas o registro atual
                    #---------------------------------------
                    if l_cont = 0 then

                        let l_tpos = arr_curr()
                        let l_vpos = 1

                        #-----------------------------------------
                        # Verifica se a vistoria nao foi cancelada
                        #-----------------------------------------
                        whenever error continue
                        open  ccts06m09018
                        using la_rdados[l_tpos].AnoServico
                             ,la_rdados[l_tpos].NumeroServico
                        fetch ccts06m09018
                        whenever error stop
                        if sqlca.sqlcode = 0 then
                            let lr_ret_AcionaVP.Codigo   = 33
                            let lr_ret_AcionaVP.Mensagem =
                                ' Atencao! Esta vistoria foi cancelada! '
                        else

                            let ma_aciona[l_vpos].NumeroServico =
                                la_rdados[l_tpos].NumeroServico
                            let ma_aciona[l_vpos].AnoServico =
                                la_rdados[l_tpos].AnoServico
                            let ma_aciona[l_vpos].NumeroVistoria =
                                la_rdados[l_tpos].NumeroVistoria
                            let ma_aciona[l_vpos].DataVistoria =
                                la_rdados[l_tpos].DataVistoria
                            let ma_aciona[l_vpos].UF =
                                la_rdados[l_tpos].UF
                            let ma_aciona[l_vpos].NomeCidade =
                                la_rdados[l_tpos].NomeCidade
                            let ma_aciona[l_vpos].NomeBairro =
                                la_rdados[l_tpos].NomeBairro
                            let ma_aciona[l_vpos].NomeSubBairro =
                                la_rdados[l_tpos].NomeSubBairro
                            let ma_aciona[l_vpos].Endereco =
                                la_rdados[l_tpos].Endereco

                            let ma_telacn[l_vpos].DiaMesVistoria =
                                la_rftela[l_tpos].DiaMesVistoria
                            let ma_telacn[l_vpos].Prioridade =
                                la_rftela[l_tpos].Prioridade
                            let ma_telacn[l_vpos].CodigoEmpresa =
                                la_rftela[l_tpos].CodigoEmpresa
                            let ma_telacn[l_vpos].EnderecoExibicao =
                                la_rftela[l_tpos].EnderecoExibicao
                            let ma_telacn[l_vpos].HorarioPref =
                                la_rftela[l_tpos].HorarioPref

                            let l_vpos = (l_vpos + 1)

                        end if

                    else

                        #-------------------------------------
                        # Se houver multipla selecao transfere
                        # os registros selecionados
                        #-------------------------------------
                        let l_vpos = 1
                        for l_tpos = 1 to 7000

                            if la_rftela[l_tpos].DiaMesVistoria is null then
                                exit for
                            end if

                            if la_rftela[l_tpos].RegSelecionado = '*' then

                                #-----------------------------------------
                                # Verifica se a vistoria nao foi cancelada
                                #-----------------------------------------
                                whenever error continue
                                open  ccts06m09018
                                using la_rdados[l_tpos].AnoServico
                                     ,la_rdados[l_tpos].NumeroServico
                                fetch ccts06m09018
                                whenever error stop
                                if sqlca.sqlcode = 0 then
                                    let lr_ret_AcionaVP.Codigo   = 33
                                    let lr_ret_AcionaVP.Mensagem =
                                        ' Atencao! Uma ou mais vistorias '
                                       ,' foram canceladas! Consulte novamente!'
                                else

                                    let ma_aciona[l_vpos].NumeroServico =
                                        la_rdados[l_tpos].NumeroServico
                                    let ma_aciona[l_vpos].AnoServico =
                                        la_rdados[l_tpos].AnoServico
                                    let ma_aciona[l_vpos].NumeroVistoria =
                                        la_rdados[l_tpos].NumeroVistoria
                                    let ma_aciona[l_vpos].DataVistoria =
                                        la_rdados[l_tpos].DataVistoria
                                    let ma_aciona[l_vpos].UF =
                                        la_rdados[l_tpos].UF
                                    let ma_aciona[l_vpos].NomeCidade =
                                        la_rdados[l_tpos].NomeCidade
                                    let ma_aciona[l_vpos].NomeBairro =
                                        la_rdados[l_tpos].NomeBairro
                                    let ma_aciona[l_vpos].NomeSubBairro =
                                        la_rdados[l_tpos].NomeSubBairro
                                    let ma_aciona[l_vpos].Endereco =
                                        la_rdados[l_tpos].Endereco

                                    let ma_telacn[l_vpos].DiaMesVistoria =
                                        la_rftela[l_tpos].DiaMesVistoria
                                    let ma_telacn[l_vpos].Prioridade =
                                        la_rftela[l_tpos].Prioridade
                                    let ma_telacn[l_vpos].CodigoEmpresa =
                                        la_rftela[l_tpos].CodigoEmpresa
                                    let ma_telacn[l_vpos].EnderecoExibicao =
                                        la_rftela[l_tpos].EnderecoExibicao
                                    let ma_telacn[l_vpos].HorarioPref =
                                        la_rftela[l_tpos].HorarioPref

                                    let l_vpos = (l_vpos + 1)

                                end if

                            end if

                        end for

                    end if

                    if lr_ret_AcionaVP.Codigo = 0 then
                        let lr_ret_AcionaVP.Codigo   = 0
                        let lr_ret_AcionaVP.Mensagem = ''
                        call cts06m09_AcionaVP()
                        returning lr_ret_AcionaVP.Codigo
                                 ,lr_ret_AcionaVP.Mensagem
                        if lr_ret_AcionaVP.Codigo is not null and
                           lr_ret_AcionaVP.Codigo <> 0 then
                            error lr_ret_AcionaVP.Mensagem
                            if lr_ret_AcionaVP.Codigo = 22 then
                                exit display
                            end if
                        end if
                    else
                        error lr_ret_AcionaVP.Mensagem
                    end if

                on key (F9)
                    #-----------------------------
                    # Exibe vistorias auto premium
                    #-----------------------------
                    let l_premium = true
                    let int_flag  = true
                    exit display

                on key (F10)
                    #--------------------------
                    # Exibe historico de regras
                    #--------------------------
                    let lr_ret_AcionaVP.Codigo   = 0
                    let lr_ret_AcionaVP.Mensagem = ''
                    let l_pos = arr_curr()
                    call avltc180_laudo_eletronico(
                         la_rdados[l_pos].NumeroVistoria)

            end display

	    #-------------------------------------------------------------------------
            # Solicita alteracao da visao das vistorias para o FiltroX (VP-Online-2.0)
	    #-------------------------------------------------------------------------
	    if lr_FiltroX.SolicitaNovoFiltro = "S" then 
	       continue while
            end if 

            if int_flag then
                exit while
            end if

        end while

    end while

    if l_saida = true then
        let l_saida = false
        close window cts06m09
        return
    end if

    initialize g_documento.* to null
    let int_flag = false
    close window cts06m09

end function

function cts06m09_ExibeInfo(lr_param)

    #--------------------------------------------
    # Record com os dados que ja estao em memoria
    #--------------------------------------------
    define lr_param record
        NumeroServico           like datmservico.atdsrvnum
       ,AnoServico              like datmservico.atdsrvano
       ,NomeBairro              like datmlcl.brrnom
       ,NomeSubBairro           like datmlcl.lclbrrnom
       ,NumeroVistoria          like datmvistoria.vstnumdig
       ,DataVistoria            like datmvistoria.vstdat
       ,HorarioPref             like datmvistoria.prfhor
       ,Prioridade              like datmservico.atdprinvlcod
       ,Endereco                char(50)
       ,NomeCidade              like datmlcl.cidnom
       ,UF                      like datmlcl.ufdcod
    end record

    #-------------------------------------------------
    # Record com os dados complementares das vistorias
    #-------------------------------------------------
    define lr_infocp record
        OrigemServico           like datmservico.atdsrvorg
       ,NomeSolicitante         like datmvistoria.c24solnom
       ,CodigoTipoSolicitante   like datmvistoria.c24soltipcod
       ,DescTipoSolicitante     like datksoltip.c24soltipdes
       ,DescPrioridade          like iddkdominio.cpodes
       ,CodigoEmpresa           like datmservico.ciaempcod
       ,NomeEmpresa             like gabkemp.empnom
       ,CodigoFinalidade        like datmvistoria.vstfld
       ,DescFinalidade          like avlkdomcampovst.vstcpodomdes
       ,PlacaVeiculo            like datmvistoria.vcllicnum
       ,ChassiVeiculo           like datmvistoria.vclchsnum
       ,RenavamVeiculo          like datmvistoria.vclrnvnum
       ,CodigoVeiculo           like datmservico.vclcoddig
       ,DescVeiculo             char(100)
       ,DescCorVeiculo          like iddkdominio.cpodes
       ,AnoFabricacaoVeiculo    like datmvistoria.vclanofbc
       ,AnoModeloVeiculo        like datmvistoria.vclanomdl
       ,CEP                     char(10)
       ,ComplementoEndereco     like datmlcl.endcmp
       ,NumeroCelular           char(20)
       ,PontoReferencia         like datmlcl.lclrefptotxt
       ,NumeroTelefone          char(20)
       ,Susep                   like datmvistoria.corsus
       ,NomeCorretor            like gcakcorr.cornom
       ,TelefoneCorretor        char(20)
       ,NomeSegurado            like datmvistoria.segnom
       ,TipoPessoa              like datmvistoria.pestip
       ,CPF_CNPJ                char(30)
       ,NomeContato             like datmlcl.lclcttnom
       ,BairroExibicao          char(50)
       ,Latitude                like datmlcl.lclltt
       ,Longitude               like datmlcl.lcllgt
       ,OrigemCoordenadas       char(01)
       ,CodigoCidade            like glakcid.cidcod
       ,DiaSemanaVistoria       smallint
       ,EmailSegurado           like datmvistoria.segematxt
    end record

    #--------------------------------------------
    # Record com dados da etapa ao entrar na tela
    #--------------------------------------------
    define lr_etapa_ent record
        CodigoEtapa             like datmsrvacp.atdetpcod
       ,SequenciaEtapa          like datmsrvacp.atdsrvseq
       ,CodigoPrestador         like datmservico.atdprscod
       ,CodigoSocorrista        like datmservico.srrcoddig
       ,CodigoVeiculo           like datmservico.socvclcod
    end record

    #------------------------------------------
    # Record com dados da etapa ao sair da tela
    #------------------------------------------
    define lr_etapa_sai record
        CodigoEtapa             like datmsrvacp.atdetpcod
       ,SequenciaEtapa          like datmsrvacp.atdsrvseq
       ,CodigoPrestador         like datmservico.atdprscod
       ,CodigoSocorrista        like datmservico.srrcoddig
       ,CodigoVeiculo           like datmservico.socvclcod
    end record

    #---------------------
    # Retorno desta funcao
    #---------------------
    define lr_ret_AcionaVP record
        Codigo                  smallint
       ,Mensagem                char(78)
    end record

    define l_tecla              char(01)

    let l_tecla = ' '
    let lr_ret_AcionaVP.Codigo   = 0
    let lr_ret_AcionaVP.Mensagem = 0
    initialize lr_infocp to null

    #-----------------------------------------------------
    # Recupera os dados auxiliares da vistoria selecionada
    #-----------------------------------------------------
    open  ccts06m09005
    using lr_param.NumeroServico
         ,lr_param.AnoServico
    fetch ccts06m09005
    into  lr_infocp.OrigemServico
         ,lr_infocp.NomeSolicitante
         ,lr_infocp.CodigoTipoSolicitante
         ,lr_infocp.DescTipoSolicitante
         ,lr_infocp.DescPrioridade
         ,lr_infocp.CodigoEmpresa
         ,lr_infocp.NomeEmpresa
         ,lr_infocp.CodigoFinalidade
         ,lr_infocp.DescFinalidade
         ,lr_infocp.PlacaVeiculo
         ,lr_infocp.ChassiVeiculo
         ,lr_infocp.RenavamVeiculo
         ,lr_infocp.CodigoVeiculo
         ,lr_infocp.DescVeiculo
         ,lr_infocp.DescCorVeiculo
         ,lr_infocp.AnoFabricacaoVeiculo
         ,lr_infocp.AnoModeloVeiculo
         ,lr_infocp.CEP
         ,lr_infocp.ComplementoEndereco
         ,lr_infocp.NumeroCelular
         ,lr_infocp.PontoReferencia
         ,lr_infocp.NumeroTelefone
         ,lr_infocp.Susep
         ,lr_infocp.NomeCorretor
         ,lr_infocp.TelefoneCorretor
         ,lr_infocp.NomeSegurado
         ,lr_infocp.TipoPessoa
         ,lr_infocp.CPF_CNPJ
         ,lr_infocp.NomeContato
         ,lr_infocp.EmailSegurado

    if sqlca.sqlcode = notfound then
        close ccts06m09005
        let lr_ret_AcionaVP.Codigo   = 99
        let lr_ret_AcionaVP.Mensagem =
            'Vistoria nao encontrada! '
           ,lr_param.NumeroServico clipped
           ,'/'
           ,lr_param.AnoServico clipped
        return lr_ret_AcionaVP.Codigo
              ,lr_ret_AcionaVP.Mensagem
    end if
    close ccts06m09005

    if lr_param.NomeBairro =
       lr_param.NomeSubBairro then
        let lr_infocp.BairroExibicao =
            lr_param.NomeBairro clipped
        else
        let lr_infocp.BairroExibicao =
            lr_param.NomeBairro clipped
           ,'/'
           ,lr_param.NomeSubBairro clipped
    end if

    open window cts06m09a at 07,02
    with form 'cts06m09a'
    attribute(form line 1)

    clear form

    display lr_param.NumeroVistoria         to f_NumeroVistoria
    display lr_infocp.OrigemServico         to f_OrigemServico
    display lr_param.NumeroServico          to f_NumeroServico
    display lr_param.AnoServico             to f_AnoServico
    display lr_infocp.NomeSolicitante       to f_NomeSolicitante
    display lr_infocp.CodigoTipoSolicitante to f_CodigoTipoSolicitante
    display lr_infocp.DescTipoSolicitante   to f_DescTipoSolicitante
    display lr_param.DataVistoria           to f_DataVistoria
    display lr_param.HorarioPref            to f_HorarioPreferencial
    display lr_param.Prioridade             to f_CodigoPrioridade
    display lr_infocp.DescPrioridade        to f_DescPrioridade
    display lr_infocp.CodigoEmpresa         to f_CodigoEmpresa
    display lr_infocp.NomeEmpresa           to f_NomeEmpresa
    display lr_infocp.CodigoFinalidade      to f_CodigoFinalidade
    display lr_infocp.DescFinalidade        to f_DescFinalidade
    display lr_infocp.PlacaVeiculo          to f_PlacaVeiculo
    display lr_infocp.ChassiVeiculo         to f_ChassiVeiculo
    display lr_infocp.RenavamVeiculo        to f_RenavamVeiculo
    display lr_infocp.CodigoVeiculo         to f_CodigoVeiculo
    display lr_infocp.DescVeiculo           to f_DescVeiculo
    display lr_infocp.DescCorVeiculo        to f_DescCorVeiculo
    display lr_infocp.AnoFabricacaoVeiculo  to f_AnoFabricacaoVeiculo
    display lr_infocp.AnoModeloVeiculo      to f_AnoModeloVeiculo
    display lr_param.Endereco               to f_Endereco
    display lr_infocp.CEP                   to f_CEP
    display lr_infocp.BairroExibicao        to f_Bairro
    display lr_param.NomeCidade             to f_Cidade
    display lr_param.UF                     to f_UF
    display lr_infocp.ComplementoEndereco   to f_ComplementoEndereco
    display lr_infocp.NumeroCelular         to f_NumeroCelular
    display lr_infocp.PontoReferencia       to f_PontoReferencia
    display lr_infocp.NumeroTelefone        to f_NumeroTelefone
    display lr_infocp.Susep                 to f_Susep
    display lr_infocp.NomeCorretor          to f_NomeCorretor
    display lr_infocp.TelefoneCorretor      to f_TelefoneCorretor
    display lr_infocp.NomeSegurado          to f_NomeSegurado
    display lr_infocp.TipoPessoa            to f_TipoPessoa
    display lr_infocp.CPF_CNPJ              to f_CPF_CNPJ
    display lr_infocp.NomeContato           to f_NomeContato
    display lr_infocp.EmailSegurado         to f_EmailSegurado

    input l_tecla without defaults from f_qqTecla

        after field f_qqTecla
            exit input

        on key (F5)
            #---------------------------------------------
            # Seleciona o registro corrente para historico
            #---------------------------------------------
            call cts06n01(lr_param.NumeroServico
                         ,lr_param.AnoServico
                         ,lr_param.NumeroVistoria
                         ,g_issk.funmat
                         ,today
                         ,current hour to minute)

        on key (F8)

            initialize lr_etapa_ent to null
            initialize lr_etapa_sai to null

            #---------------------------------------------
            # Recupera os dados da etapa ao entrar na tela
            #---------------------------------------------
            whenever error continue
            open  ccts06m09017
            using lr_param.NumeroServico
                 ,lr_param.AnoServico
            fetch ccts06m09017
            into  lr_etapa_ent.CodigoEtapa
                 ,lr_etapa_ent.SequenciaEtapa
                 ,lr_etapa_ent.CodigoPrestador
                 ,lr_etapa_ent.CodigoSocorrista
                 ,lr_etapa_ent.CodigoVeiculo
            whenever error stop

            #---------------------------------------------
            # Seleciona o registro corrente para alteracao
            #---------------------------------------------
            let g_documento.atdsrvorg = 10
            let g_documento.atdsrvnum = lr_param.NumeroServico
            let g_documento.atdsrvano = lr_param.AnoServico
            let g_documento.solnom    = mr_veiculo.SiglaVeiculo
            error ' Selecione e tecle ENTER! '
            call cts06m00('N'
                         ,lr_param.NumeroVistoria
                         ,''
                         ,'')
            error ''

            #-------------------------------------------
            # Recupera os dados da etapa ao sair da tela
            #-------------------------------------------
            whenever error continue
            open  ccts06m09017
            using lr_param.NumeroServico
                 ,lr_param.AnoServico
            fetch ccts06m09017
            into  lr_etapa_sai.CodigoEtapa
                 ,lr_etapa_sai.SequenciaEtapa
                 ,lr_etapa_sai.CodigoPrestador
                 ,lr_etapa_sai.CodigoSocorrista
                 ,lr_etapa_sai.CodigoVeiculo
            whenever error stop

            if lr_etapa_sai.CodigoEtapa      <> lr_etapa_ent.CodigoEtapa      or
               lr_etapa_sai.SequenciaEtapa   <> lr_etapa_ent.SequenciaEtapa   or
               lr_etapa_sai.CodigoPrestador  <> lr_etapa_ent.CodigoPrestador  or
               lr_etapa_sai.CodigoSocorrista <> lr_etapa_ent.CodigoSocorrista or
               lr_etapa_sai.CodigoVeiculo    <> lr_etapa_ent.CodigoVeiculo    then

                let lr_ret_AcionaVP.Codigo   = 22
                let lr_ret_AcionaVP.Mensagem =  ' Vistoria alterada! '

            end if

            exit input

    end input

    let int_flag = false
    close window cts06m09a

    return lr_ret_AcionaVP.Codigo
          ,lr_ret_AcionaVP.Mensagem

end function

function cts06m09_AcionaVP()

    define l_qtd                smallint
    define l_con                smallint
    define l_dat                smallint
    define l_pos                smallint
    define l_dia                char(05)
    define l_defConf            char(01)

    #---------------------------------------
    # Registro com os dados para acionamento
    #---------------------------------------
    define lr_aciona record
        VeiculoAnterior         char(78)
       ,RecusaAutomatica        char(01)
       ,SiglaVeiculo            like datkveiculo.atdvclsgl
       ,NomeVeiculo             like datkveiculo.vclctfnom
       ,TipoVinculo             like avckinsp.vintipcod
       ,QtdVistoriasAcn         decimal(6,0)
       ,QtdVistoriasPend        decimal(6,0)
       ,CodigoPrestador         like datmservico.atdprscod
       ,NomePrestador           like dpaksocor.nomgrr
       ,CodigoSocorrista        like datmservico.srrcoddig
       ,NomeSocorrista          like datksrr.srrabvnom
       ,TipoEnvio               char(15)
       ,DDD                     like datkveiculo.celdddcod
       ,Celular                 char(10)
       ,Email                   char(50)
       ,EnviaSMS                char(01)
       ,Confirma                char(01)
       ,PlacaVeiculo            like datmvistoria.vcllicnum
       ,segnom                  like datmvistoria.segnom
       ,empresa                 dec(2,0)
    end record

    #--------------------------------------------------------
    # Record com o celular e email do segurado para historico
    #--------------------------------------------------------
    define lr_infosrv record
        DDD                     like datmlcl.celteldddcod
       ,Celular                 like datmlcl.celtelnum
       ,Email                   like datmvistoria.segematxt
    end record
    #-------------------------------------------------
    # Record com os dados complementares das vistorias
    #-------------------------------------------------
    define lr_infocp record
        CodigoEmpresa           like datmservico.ciaempcod
       ,CodigoCidade            like glakcid.cidcod
       ,DiaSemanaVistoria       smallint
    end record

    #---------------------
    # Retorno desta funcao
    #---------------------
    define lr_ret_AcionaVP record
        Codigo                  smallint
       ,Mensagem                char(78)
    end record

    #---------------------------------
    # Retorno da funcao de acionamento
    #---------------------------------
    define lr_ret_fvpia940 record
        Codigo                  smallint
       ,Mensagem                char(78)
    end record

    #------------------------------------
    # Array com o historico de alteracoes
    #------------------------------------
    define la_hist array[5] of record
        histxt                  like datmservhist.c24srvdsc
    end record
    define l_linhist            smallint
    initialize lr_aciona        to null
    initialize lr_infosrv       to null
    initialize lr_infocp        to null
    initialize lr_ret_AcionaVP  to null
    initialize lr_ret_fvpia940  to null
    initialize l_qtd            to null
    initialize l_con            to null
    initialize l_dat            to null
    initialize l_pos            to null
    initialize l_dia            to null
    initialize l_defConf        to null
    initialize la_hist          to null
    initialize l_linhist        to null

    let lr_ret_AcionaVP.Codigo   = 0
    let lr_ret_AcionaVP.Mensagem = ''

    let lr_ret_fvpia940.Codigo   = 0
    let lr_ret_fvpia940.Mensagem = ''

    let l_defConf                = 'S'

    open window cts06m09d at 03,02
    with form 'cts06m09d'
    attribute(form line 1)

    clear form

    let l_con = 0
    let l_dat = 0
    for l_qtd = 1 to 10
        if ma_telacn[l_qtd].DiaMesVistoria is null then
            exit for
        end if
        display ma_telacn[l_qtd].* to s_cts06m09d[l_qtd].*
        if ma_telacn[l_qtd].DiaMesVistoria is not null then
            let l_con = (l_con + 1)
            if l_dia is null then
                let l_dia = ma_telacn[l_qtd].DiaMesVistoria
                let l_dat = 1
            else
                if ma_telacn[l_qtd].DiaMesVistoria <> l_dia then
                    let l_dat = (l_dat + 1)
                end if
            end if
        end if
    end for

    call set_count(l_con)

    if mr_veiculo.SiglaVeiculoAnterior is not null then

        let lr_aciona.VeiculoAnterior  = mr_veiculo.SiglaVeiculoAnterior
        let lr_aciona.RecusaAutomatica = 'S'

        #-----------------------------------
        # Recupera os dados para acionamento
        #-----------------------------------
        open  ccts06m09013
        using lr_aciona.VeiculoAnterior
        fetch ccts06m09013
        into  lr_aciona.NomeVeiculo
             ,lr_aciona.CodigoPrestador
             ,lr_aciona.NomePrestador
             ,lr_aciona.CodigoSocorrista
             ,lr_aciona.NomeSocorrista
        close ccts06m09013

        let lr_aciona.VeiculoAnterior =
            'Vistorias acionadas para '
           ,lr_aciona.VeiculoAnterior clipped
           ,'-'
           ,lr_aciona.NomeVeiculo

        initialize lr_aciona.NomeVeiculo        to null
        initialize lr_aciona.CodigoPrestador    to null
        initialize lr_aciona.NomePrestador      to null
        initialize lr_aciona.CodigoSocorrista   to null
        initialize lr_aciona.NomeSocorrista     to null

    end if

    if mr_veiculo.SiglaVeiculo is not null then

        let lr_aciona.SiglaVeiculo = mr_veiculo.SiglaVeiculo

        #--------------------------------
        # Para desviar para a confirmacao
        #--------------------------------
        let l_qtd = 1

        #-----------------------------------
        # Recupera os dados para acionamento
        #-----------------------------------
        open  ccts06m09013
        using lr_aciona.SiglaVeiculo
        fetch ccts06m09013
        into  lr_aciona.NomeVeiculo
             ,lr_aciona.CodigoPrestador
             ,lr_aciona.NomePrestador
             ,lr_aciona.CodigoSocorrista
             ,lr_aciona.NomeSocorrista
        close ccts06m09013

        #----------------------------------------------
        # Verifica se o veiculo e' de clientes vponline
        #----------------------------------------------
        if lr_aciona.SiglaVeiculo = mr_vponline.SiglaVeiculo then
            #---------------------------------------------
            # Somente nivel >= 5 pode acionar para cliente
            #---------------------------------------------
            if g_issk.acsnivcod < 5 then
                let int_flag = false
                close window cts06m09d
                let lr_ret_AcionaVP.Codigo = 99
                let lr_ret_AcionaVP.Mensagem = 'Nivel de acesso insuficiente!'
                return lr_ret_AcionaVP.Codigo
                      ,lr_ret_AcionaVP.Mensagem
            end if
            #----------------------------------------
            # Verifica se a vistoria ja' foi acionada
            # anteriormente para VPOnline
            #----------------------------------------
            whenever error continue
            open  ccts06m09025
            using ma_aciona[1].NumeroVistoria
                 ,mr_vponline.SiglaVeiculo
            fetch ccts06m09025
            whenever error stop
            if sqlca.sqlcode = 0 then
                error ' Atencao! Esta VP ja foi acionada '
                     ,' para o cliente anteriormente!'sleep 2
            end if
            #--------------------------------------------------
            # Recupera informacoes complementares para VPOnline
            #--------------------------------------------------
            let lr_aciona.DDD          = null
            let lr_aciona.Celular      = null
            let lr_aciona.Email        = null
            let lr_aciona.PlacaVeiculo = null
            let lr_aciona.segnom       = null
            let lr_aciona.empresa      = null
            whenever error continue
            open  ccts06m09024
            using ma_aciona[1].NumeroServico
                 ,ma_aciona[1].AnoServico
            fetch ccts06m09024
            into  lr_aciona.DDD
                 ,lr_aciona.Celular
                 ,lr_aciona.Email
                 ,lr_aciona.PlacaVeiculo
                 ,lr_aciona.segnom
                 ,lr_aciona.empresa
            whenever error stop
            if sqlca.sqlcode <> 0 then
                let int_flag = false
                close window cts06m09d
                let lr_ret_AcionaVP.Codigo   = 99
                let lr_ret_AcionaVP.Mensagem = ' CTS06M09/ccts06m09024/ '
                   ,lr_aciona.SiglaVeiculo
                return lr_ret_AcionaVP.Codigo
                      ,lr_ret_AcionaVP.Mensagem
            else
                #----------------------------------------------------
                # Guarda o celular e email do segurado para historico
                #----------------------------------------------------
                let lr_infosrv.DDD        = lr_aciona.DDD
                let lr_infosrv.Celular    = lr_aciona.Celular
                let lr_infosrv.Email      = lr_aciona.Email
                #----------------------------------------------------
                let lr_aciona.TipoVinculo = 'C'
                let lr_aciona.TipoEnvio   = '   *CLIENTE*   '
                let lr_aciona.EnviaSMS    = 'S'
                let lr_aciona.Confirma    = l_defConf
                #----------------------------------------------------
            end if
        end if
        if lr_aciona.TipoVinculo is null or
           lr_aciona.TipoVinculo <> 'C' then
            #-----------------------------------------------
            # Recupera o tipo de vinculo + codigo do posto
            # do inspetor + celular do veiculo via base palm
            #-----------------------------------------------
            open  ccts06m09014
            using lr_aciona.SiglaVeiculo
            fetch ccts06m09014
            into  lr_aciona.TipoVinculo
                 ,lr_aciona.DDD
                 ,lr_aciona.Celular
            close ccts06m09014

            #-----------------------------------------------------
            # Se o tipo de vinculo do inspetor nao for Funcionario
            # recupera o email de distribuicao do posto
            #-----------------------------------------------------
            if lr_aciona.TipoVinculo = 'F' then
                let lr_aciona.TipoEnvio = ' *FUNCIONARIO* '
                let lr_aciona.EnviaSMS  = 'N'
                let lr_aciona.Confirma  = l_defConf
            else
                initialize lr_aciona.DDD        to null
                initialize lr_aciona.Celular    to null
                let lr_aciona.TipoEnvio = '  *PRESTADOR*  '
                let lr_aciona.EnviaSMS  = 'N'
                let lr_aciona.Confirma  = l_defConf
                #-------------------------------------------
                # Recupera o e-mail de distribuicao do posto
                #-------------------------------------------
                open  ccts06m09015
                using lr_aciona.CodigoPrestador
                fetch ccts06m09015
                into  lr_aciona.Email
                close ccts06m09015
            end if
        end if

        #-----------------------------------------------
        # Somente exibe a quantidade de vistorias no dia
        # se todas as vistorias forem para a mesma data
        #-----------------------------------------------
        if l_dat = 1 then
            #----------------------------------
            # Quantidade de vistorias acionadas
            #----------------------------------
            open  ccts06m09010
            using ma_aciona[l_dat].DataVistoria
                 ,lr_aciona.SiglaVeiculo
            fetch ccts06m09010
            into  lr_aciona.QtdVistoriasAcn
            close ccts06m09010
            #----------------------------------
            # Quantidade de vistorias pendentes
            #----------------------------------
            open  ccts06m09011
            using ma_aciona[l_dat].DataVistoria
                 ,lr_aciona.SiglaVeiculo
            fetch ccts06m09011
            into  lr_aciona.QtdVistoriasPend
            close ccts06m09011
            #----------------------------------
        else
            initialize lr_aciona.QtdVistoriasAcn  to null
            initialize lr_aciona.QtdVistoriasPend to null
        end if
    else
        #------------------------------------
        # Para nao desviar para a confirmacao
        #------------------------------------
        let l_qtd = 0

    end if

    input lr_aciona.VeiculoAnterior
         ,lr_aciona.SiglaVeiculo
         ,lr_aciona.NomeVeiculo
         ,lr_aciona.QtdVistoriasAcn
         ,lr_aciona.QtdVistoriasPend
         ,lr_aciona.CodigoPrestador
         ,lr_aciona.NomePrestador
         ,lr_aciona.CodigoSocorrista
         ,lr_aciona.NomeSocorrista
         ,lr_aciona.DDD
         ,lr_aciona.Celular
         ,lr_aciona.Email
         ,lr_aciona.EnviaSMS
         ,lr_aciona.Confirma
         ,lr_aciona.TipoEnvio
          without defaults
     from f_VeiculoAnterior
         ,f_SiglaVeiculo
         ,f_NomeVeiculo
         ,f_QtdVistoriasAcn
         ,f_QtdVistoriasPend
         ,f_CodigoPrestador
         ,f_NomePrestador
         ,f_CodigoSocorrista
         ,f_NomeSocorrista
         ,f_DDD
         ,f_Celular
         ,f_Email
         ,f_EnviaSMS
         ,f_Confirma
         ,f_TipoEnvio

        on key (interrupt,control-c)
            let int_flag = false
            exit input

        before field f_SiglaVeiculo
            display lr_aciona.SiglaVeiculo
                         to f_SiglaVeiculo attribute(reverse)

            #--------------------------------
            # Para desviar para a confirmacao
            #--------------------------------
            if l_qtd = 1 then
                #---------------------------
                # Para nao desviar novamente
                #---------------------------
                let l_qtd = 0
                display lr_aciona.SiglaVeiculo
                             to f_SiglaVeiculo
                next field f_Confirma
            end if

        after field f_SiglaVeiculo
            display lr_aciona.SiglaVeiculo
                         to f_SiglaVeiculo

            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                next field f_SiglaVeiculo
            end if

            if lr_aciona.SiglaVeiculo is null or
               lr_aciona.SiglaVeiculo = ' ' then
                error ' Selecione o veiculo para acionamento! '
                next field f_SiglaVeiculo
            end if

            #-----------------------------------
            # Recupera os dados para acionamento
            #-----------------------------------
            open  ccts06m09013
            using lr_aciona.SiglaVeiculo
            fetch ccts06m09013
            into  lr_aciona.NomeVeiculo
                 ,lr_aciona.CodigoPrestador
                 ,lr_aciona.NomePrestador
                 ,lr_aciona.CodigoSocorrista
                 ,lr_aciona.NomeSocorrista
            if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = notfound then
                    error ' Veiculo nao encontrado! '
                    next field f_SiglaVeiculo
                else
                    close ccts06m09013
                    let lr_ret_AcionaVP.Codigo   = 99
                    let lr_ret_AcionaVP.Mensagem =
                        sqlca.sqlcode
                       ,'/CTS06M09/ccts06m09013/ '
                       ,lr_aciona.SiglaVeiculo
                    return lr_ret_AcionaVP.Codigo
                          ,lr_ret_AcionaVP.Mensagem
                end if
            end if
            close ccts06m09013

            #--------------------------------------------------
            # Verifica se o veiculo nao e' de clientes vponline
            #--------------------------------------------------
            if lr_aciona.SiglaVeiculo <> mr_vponline.SiglaVeiculo then
                #-----------------------------------------------
                # Recupera o tipo de vinculo + codigo do posto
                # do inspetor + celular do veiculo via base palm
                #-----------------------------------------------
                open  ccts06m09014
                using lr_aciona.SiglaVeiculo
                fetch ccts06m09014
                into  lr_aciona.TipoVinculo
                     ,lr_aciona.DDD
                     ,lr_aciona.Celular
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        error ' Base do inspetor nao encontrada! '
                        next field f_SiglaVeiculo
                    else
                        close ccts06m09014
                        let lr_ret_AcionaVP.Codigo   = 99
                        let lr_ret_AcionaVP.Mensagem =
                            sqlca.sqlcode
                           ,'/CTS06M09/ccts06m09014/ '
                           ,lr_aciona.SiglaVeiculo
                        return lr_ret_AcionaVP.Codigo
                              ,lr_ret_AcionaVP.Mensagem
                    end if
                end if
                close ccts06m09014

                #------------------------------------------------
                # Verifica se o posto atende a empresa+cidade+dia
                # para tipo de vinculo <> Funcionario
                #------------------------------------------------
                for l_pos = 1 to 10

                    if ma_aciona[l_pos].NumeroServico is null then
                        exit for
                    else

                        initialize lr_infocp to null
                        open  ccts06m09007
                        using ma_aciona[l_pos].NumeroServico
                             ,ma_aciona[l_pos].AnoServico
                        fetch ccts06m09007
                        into  lr_infocp.CodigoEmpresa
                             ,lr_infocp.DiaSemanaVistoria
                             ,lr_infocp.CodigoCidade
                        close ccts06m09007

                        #---------------------------------------
                        # Verifica se o veiculo atende a empresa
                        #---------------------------------------
                        whenever error continue
                        open  ccts06m09020
                        using lr_aciona.SiglaVeiculo
                             ,lr_infocp.CodigoEmpresa
                        fetch ccts06m09020
                        whenever error stop
                        if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode = notfound then
                                error 'Atencao! Veiculo nao atende a Empresa'
                                     ,' de uma ou mais VPs!'
                                let l_defConf = 'N'
                                exit for
                            else
                                close ccts06m09020
                                let lr_ret_AcionaVP.Codigo   = 99
                                let lr_ret_AcionaVP.Mensagem =
                                    sqlca.sqlcode
                                   ,'/CTS06M09/ccts06m09020/ '
                                   ,lr_aciona.SiglaVeiculo
                                return lr_ret_AcionaVP.Codigo
                                      ,lr_ret_AcionaVP.Mensagem
                            end if
                        end if
                        close ccts06m09020

                        #-----------------------------------------
                        # Verifica se o prestador atende a empresa
                        #-----------------------------------------
                        whenever error continue
                        open  ccts06m09021
                        using lr_aciona.SiglaVeiculo
                             ,lr_infocp.CodigoEmpresa
                        fetch ccts06m09021
                        whenever error stop
                        if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode = notfound then
                                error 'Atencao! Prestador nao atende a Empresa'
                                     ,' de uma ou mais VPs!'
                                let l_defConf = 'N'
                                exit for
                            else
                                close ccts06m09021
                                let lr_ret_AcionaVP.Codigo   = 99
                                let lr_ret_AcionaVP.Mensagem =
                                    sqlca.sqlcode
                                   ,'/CTS06M09/ccts06m09021/ '
                                   ,lr_aciona.SiglaVeiculo
                                return lr_ret_AcionaVP.Codigo
                                      ,lr_ret_AcionaVP.Mensagem
                            end if
                        end if
                        close ccts06m09021

                        #----------------------------------------------
                        # Verifica se o posto atende empresa+cidade+dia
                        #----------------------------------------------
                        if lr_aciona.TipoVinculo = 'T' then

                            whenever error continue
                            open  ccts06m09019
                            using lr_infocp.CodigoCidade
                                 ,lr_infocp.CodigoEmpresa
                                 ,lr_infocp.DiaSemanaVistoria
                                 ,lr_aciona.SiglaVeiculo
                            fetch ccts06m09019
                            whenever error stop
                            if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode = notfound then
                                    error 'Atencao! Posto nao atende a Empresa ou'
                                         ,' a Cidade ou Dia de uma ou mais VPs!'
                                    let l_defConf = 'N'
                                    exit for
                                else
                                    close ccts06m09019
                                    let lr_ret_AcionaVP.Codigo   = 99
                                    let lr_ret_AcionaVP.Mensagem =
                                        sqlca.sqlcode
                                       ,'/CTS06M09/ccts06m09019/ '
                                       ,lr_aciona.SiglaVeiculo
                                    return lr_ret_AcionaVP.Codigo
                                          ,lr_ret_AcionaVP.Mensagem
                                end if
                            end if
                            close ccts06m09019

                        end if

                    end if

                end for

            end if

            #----------------------------------------------
            # Verifica se o veiculo e' de clientes vponline
            #----------------------------------------------
            if lr_aciona.SiglaVeiculo = mr_vponline.SiglaVeiculo then
                #---------------------------------------------
                # Somente nivel >= 5 pode acionar para cliente
                #---------------------------------------------
                if g_issk.acsnivcod < 5 then
                    error ' Nivel de acesso insuficiente! '
                    next field f_SiglaVeiculo
                end if
                #-----------------------------------------------
                # Para acionar para cliente deve ser uma por vez
                #-----------------------------------------------
                if l_con <> 1 then
                    error ' Para VPOnline selecione apenas uma vistoria! '
                    next field f_SiglaVeiculo
                else
                    #----------------------------------------
                    # Verifica se a vistoria ja' foi acionada
                    # anteriormente para VPOnline
                    #----------------------------------------
                    whenever error continue
                    open  ccts06m09025
                    using ma_aciona[1].NumeroVistoria
                         ,mr_vponline.SiglaVeiculo
                    fetch ccts06m09025
                    whenever error stop
                    if sqlca.sqlcode = 0 then
                        error ' Atencao! Esta VP ja foi acionada'
                             ,' para o cliente anteriormente!'sleep 2
                    end if

                    #--------------------------------------------------
                    # Recupera informacoes complementares para VPOnline
                    #--------------------------------------------------
                    let lr_aciona.DDD          = null
                    let lr_aciona.Celular      = null
                    let lr_aciona.Email        = null
                    let lr_aciona.PlacaVeiculo = null
                    let lr_aciona.segnom       = null
                    let lr_aciona.empresa      = null
                    open  ccts06m09024
                    using ma_aciona[1].NumeroServico
                         ,ma_aciona[1].AnoServico
                    whenever error continue
                    fetch ccts06m09024
                    into  lr_aciona.DDD
                         ,lr_aciona.Celular
                         ,lr_aciona.Email
                         ,lr_aciona.PlacaVeiculo
                         ,lr_aciona.segnom
                         ,lr_aciona.empresa
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                        let lr_ret_AcionaVP.Codigo   = 99
                        error ' CTS06M09/ccts06m09024/ '
                             ,lr_aciona.SiglaVeiculo sleep 2
                        return lr_ret_AcionaVP.Codigo
                              ,lr_ret_AcionaVP.Mensagem
                    else
                        #----------------------------------------------------
                        # Guarda o celular e email do segurado para historico
                        #----------------------------------------------------
                        let lr_infosrv.DDD        = lr_aciona.DDD
                        let lr_infosrv.Celular    = lr_aciona.Celular
                        let lr_infosrv.Email      = lr_aciona.Email
                        #----------------------------------------------------
                        let lr_aciona.TipoVinculo = 'C'
                        let lr_aciona.TipoEnvio   = '   *CLIENTE*   '
                        let lr_aciona.EnviaSMS    = 'S'
                        let lr_aciona.Confirma    = l_defConf
                        #----------------------------------------------------
                    end if
                end if
            end if
            #-----------------------------------------------------
            # Se o tipo de vinculo do inspetor nao for Funcionario
            # recupera o email de distribuicao do posto
            #-----------------------------------------------------
            if lr_aciona.TipoVinculo is null or
               lr_aciona.TipoVinculo <> 'C' then
                if lr_aciona.TipoVinculo = 'F' then
                    let lr_aciona.EnviaSMS  = 'N'
                    let lr_aciona.Confirma  = l_defConf
                    let lr_aciona.TipoEnvio = ' *FUNCIONARIO* '
                else
                    initialize lr_aciona.DDD        to null
                    initialize lr_aciona.Celular    to null
                    initialize lr_aciona.Email      to null
                    let lr_aciona.EnviaSMS  = 'N'
                    let lr_aciona.Confirma  = l_defConf
                    let lr_aciona.TipoEnvio = '  *PRESTADOR*  '
                    #-------------------------------------------
                    # Recupera o e-mail de distribuicao do posto
                    #-------------------------------------------
                    open  ccts06m09015
                    using lr_aciona.CodigoPrestador
                    fetch ccts06m09015
                    into  lr_aciona.Email
                    if sqlca.sqlcode <> 0 then
                        if sqlca.sqlcode = notfound then
                            error ' Posto nao encontrado! '
                            next field f_SiglaVeiculo
                        else
                            close ccts06m09015
                            let lr_ret_AcionaVP.Codigo   = 99
                            let lr_ret_AcionaVP.Mensagem =
                                sqlca.sqlcode
                               ,'/CTS06M09/ccts06m09015/ '
                               ,lr_aciona.CodigoPrestador
                            return lr_ret_AcionaVP.Codigo
                                  ,lr_ret_AcionaVP.Mensagem
                        end if
                    end if
                    close ccts06m09015
                end if
            end if

            #-----------------------------------------------
            # Somente exibe a quantidade de vistorias no dia
            # se todas as vistorias forem para a mesma data
            #-----------------------------------------------
            if l_dat = 1 then
                #----------------------------------
                # Quantidade de vistorias acionadas
                #----------------------------------
                open  ccts06m09010
                using ma_aciona[l_dat].DataVistoria
                     ,lr_aciona.SiglaVeiculo
                fetch ccts06m09010
                into  lr_aciona.QtdVistoriasAcn
                close ccts06m09010
                #----------------------------------
                # Quantidade de vistorias pendentes
                #----------------------------------
                open  ccts06m09011
                using ma_aciona[l_dat].DataVistoria
                     ,lr_aciona.SiglaVeiculo
                fetch ccts06m09011
                into  lr_aciona.QtdVistoriasPend
                close ccts06m09011
                #----------------------------------
            else
                initialize lr_aciona.QtdVistoriasAcn  to null
                initialize lr_aciona.QtdVistoriasPend to null
            end if

            display lr_aciona.SiglaVeiculo
                         to f_SiglaVeiculo
            display lr_aciona.NomeVeiculo
                         to f_NomeVeiculo
            display lr_aciona.QtdVistoriasAcn
                         to f_QtdVistoriasAcn
            display lr_aciona.QtdVistoriasPend
                         to f_QtdVistoriasPend
            display lr_aciona.CodigoPrestador
                         to f_CodigoPrestador
            display lr_aciona.NomePrestador
                         to f_NomePrestador
            display lr_aciona.CodigoSocorrista
                         to f_CodigoSocorrista
            display lr_aciona.NomeSocorrista
                         to f_NomeSocorrista
            display lr_aciona.EnviaSMS
                         to f_EnviaSMS
            display lr_aciona.DDD
                         to f_DDD
            display lr_aciona.Celular
                         to f_Celular
            display lr_aciona.Email
                         to f_Email
            display lr_aciona.Confirma
                         to f_Confirma
            display lr_aciona.TipoEnvio
                         to f_TipoEnvio
                         attribute(reverse)
            #------------------------------------------------------------
            # Sempre desvia para a confirmacao apos informar a sigla
            # Se o usuario quiser alterar algum campo navega com as setas
            #------------------------------------------------------------
            next field f_Confirma

         before field f_DDD
            display lr_aciona.DDD
                         to f_DDD attribute(reverse)

         after field f_DDD
            display lr_aciona.DDD
                         to f_DDD

            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                next field f_SiglaVeiculo
            end if

         before field f_Celular
            display lr_aciona.Celular
                         to f_Celular attribute(reverse)

         after field f_Celular
            display lr_aciona.Celular
                         to f_Celular

            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                if lr_aciona.TipoVinculo = 'C' or
                   lr_aciona.TipoVinculo = 'F' then
                    next field f_DDD
                else
                    next field f_SiglaVeiculo
                end if
            end if

         before field f_Email
            display lr_aciona.Email
                         to f_Email attribute(reverse)
         after field f_Email
            display lr_aciona.Email
                         to f_Email
            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                if lr_aciona.TipoVinculo = 'C' or
                   lr_aciona.TipoVinculo = 'F' then
                    next field f_Celular
                else
                    next field f_SiglaVeiculo
                end if
            end if
         before field f_EnviaSMS
            display lr_aciona.EnviaSMS
                         to f_EnviaSMS attribute(reverse)

         after field f_EnviaSMS
            display lr_aciona.EnviaSMS
                         to f_EnviaSMS

            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                if lr_aciona.TipoVinculo = 'F' then
                    next field f_Celular
                else
                    if lr_aciona.TipoVinculo = 'C' then
                        next field f_Email
                    else
                        next field f_SiglaVeiculo
                    end if
                end if
            end if

         before field f_Confirma
            display lr_aciona.Confirma
                         to f_Confirma attribute(reverse)

         after field f_Confirma
            display lr_aciona.Confirma
                         to f_Confirma

            if fgl_lastkey() = fgl_keyval('left') or
               fgl_lastkey() = fgl_keyval('up') then
                if lr_aciona.TipoVinculo = 'C' or
                   lr_aciona.TipoVinculo = 'F' then
                    next field f_EnviaSMS
                else
                    next field f_Email
                end if
            end if

            #-------------------------------
            # Inicializa o retorno sem erros
            #-------------------------------
            let lr_ret_AcionaVP.Codigo   = 0
            let lr_ret_AcionaVP.Mensagem = ''

            if lr_aciona.Confirma = 'S' then

                for l_con = 1 to 10

                    if ma_aciona[l_con].NumeroServico is null then
                        exit for
                    end if

                    initialize lr_ret_fvpia940 to null

                    call fvpia940_AcionaLaudoVeiculo(
                              ma_aciona[l_con].NumeroServico
                             ,ma_aciona[l_con].AnoServico
                             ,lr_aciona.SiglaVeiculo
                             ,lr_aciona.RecusaAutomatica
                             ,g_issk.usrtip
                             ,g_issk.empcod
                             ,g_issk.funmat)
                    returning lr_ret_fvpia940.Codigo
                             ,lr_ret_fvpia940.Mensagem

                    #---------------------------------------------------
                    # Se ocorreu algum erro de acionamento exibe na tela
                    #---------------------------------------------------
                    if lr_ret_fvpia940.Codigo <> 0 then

                        let ma_telacn[l_con].HorarioPref =
                            lr_ret_fvpia940.Mensagem

                        display ma_telacn[l_con].HorarioPref
                         to s_cts06m09d[l_con].f_HorarioPref
                         attribute(reverse)
                        let lr_ret_AcionaVP.Codigo   = 88
                        let lr_ret_AcionaVP.Mensagem =
                            ' Atencao! Erros no acionamento!'
                           ,' Verifique!'

                        error lr_ret_fvpia940.Mensagem

                    else

                        #------------------------------------------
                        # Se nao ocorreu nenhum erro de acionamento
                        #------------------------------------------
                        let ma_telacn[l_con].HorarioPref = 'Acionado!'

                        display ma_telacn[l_con].HorarioPref
                         to s_cts06m09d[l_con].f_HorarioPref
                         attribute(reverse)
                        #----------------------------
                        # VPOnline: envia email + sms
                        #----------------------------
                        if lr_aciona.TipoVinculo = 'C' then
                            #--------------------------------
                            # Sem alteracoes para o historico
                            #--------------------------------
                            let l_linhist = 0
                            #----------------------------------------------
                            # Verifica se houve alteracao no DDD do celular
                            #----------------------------------------------
                            if (lr_infosrv.DDD is null and
                                lr_aciona.DDD is not null) or
                               (lr_aciona.DDD <> lr_infosrv.DDD) then
                                let l_linhist = l_linhist + 1
                                let la_hist[l_linhist].histxt = 'Alterou o '
                                   ,'DDD do Celular de ['
                                   ,lr_infosrv.DDD
                                   ,'] para ['
                                   ,lr_aciona.DDD
                                   ,']'
                                whenever error continue
                                execute pcts06m09026
                                using   lr_aciona.DDD
                                       ,ma_aciona[l_con].NumeroServico
                                       ,ma_aciona[l_con].AnoServico
                                whenever error stop
                                if sqlca.sqlcode <> 0 then
                                    let la_hist[l_linhist].histxt =
                                        la_hist[l_linhist].histxt clipped
                                       ,' [ERRO]'
                                end if
                            end if
                            #-------------------------------------------------
                            # Verifica se houve alteracao no numero do celular
                            #-------------------------------------------------
                            if (lr_infosrv.Celular is null and
                                lr_aciona.Celular is not null) or
                               (lr_aciona.Celular <> lr_infosrv.Celular) then
                                let l_linhist = l_linhist + 1
                                let la_hist[l_linhist].histxt = 'Alterou o '
                                   ,'Numero do Celular de ['
                                   ,lr_infosrv.Celular
                                   ,'] para ['
                                   ,lr_aciona.Celular
                                   ,']'
                                whenever error continue
                                execute pcts06m09027
                                using   lr_aciona.Celular
                                       ,ma_aciona[l_con].NumeroServico
                                       ,ma_aciona[l_con].AnoServico
                                whenever error stop
                                if sqlca.sqlcode <> 0 then
                                    let la_hist[l_linhist].histxt =
                                        la_hist[l_linhist].histxt clipped
                                       ,' [ERRO]'
                                end if
                            end if
                            #-------------------------------------
                            # Verifica se houve alteracao no email
                            #-------------------------------------
                            if (lr_infosrv.Email is null and
                                lr_aciona.Email is not null) or
                               (lr_aciona.Email <> lr_infosrv.Email) then
                                let l_linhist = l_linhist + 1
                                let la_hist[l_linhist].histxt = 'Alterou o '
                                   ,'Email de ['
                                   ,lr_infosrv.Email clipped
                                   ,'] para ['
                                   ,lr_aciona.Email clipped
                                   ,']'
                                whenever error continue
                                execute pcts06m09028
                                using   lr_aciona.Email
                                       ,ma_aciona[l_con].NumeroServico
                                       ,ma_aciona[l_con].AnoServico
                                whenever error stop
                                if sqlca.sqlcode <> 0 then
                                    let la_hist[l_linhist].histxt =
                                        la_hist[l_linhist].histxt clipped
                                       ,' [ERRO]'
                                end if
                            end if
                            #--------------------------------
                            # Grava o historico de alteracoes
                            #--------------------------------
                            call cts10g02_historico(
                                 ma_aciona[l_con].NumeroServico
                                ,ma_aciona[l_con].AnoServico
                                ,today
                                ,current hour to second
                                ,g_issk.funmat
                                ,la_hist[1].histxt
                                ,la_hist[2].histxt
                                ,la_hist[3].histxt
                                ,la_hist[4].histxt
                                ,la_hist[5].histxt)
                            returning l_linhist
                            call fvpic008_envia_email(
                                      lr_aciona.Email
                                     ,(ma_aciona[l_dat].DataVistoria +
                                       mr_vponline.NumeroDias units day)
                                      ,lr_aciona.PlacaVeiculo
                                      ,lr_aciona.segnom
                                      ,lr_aciona.empresa
                                      ,ma_aciona[l_dat].NumeroServico
                                      ,ma_aciona[l_dat].AnoServico)
                            returning lr_ret_fvpia940.Codigo
                                     ,lr_ret_fvpia940.Mensagem
                            if lr_ret_fvpia940.Codigo <> 0 then
                                let ma_telacn[l_con].HorarioPref =
                                    lr_ret_fvpia940.Mensagem
                                display ma_telacn[l_con].HorarioPref
                                 to s_cts06m09d[l_con].f_HorarioPref
                                 attribute(reverse)
                                let lr_ret_AcionaVP.Codigo   = 66
                                let lr_ret_AcionaVP.Mensagem =
                                    ' Atencao! Erro no envio de e-mail!'
                                   ,' Verifique!'
                                error lr_ret_fvpia940.Mensagem
                            end if
                            if lr_aciona.EnviaSMS = 'S'       and
                               lr_aciona.DDD      is not null and
                               lr_aciona.Celular  is not null then
                                call fvpic008_envia_sms(lr_aciona.DDD
                                                       ,lr_aciona.Celular
                                                       ,lr_aciona.PlacaVeiculo
                                                       ,lr_aciona.empresa)
                                returning lr_ret_fvpia940.Codigo
                                         ,lr_ret_fvpia940.Mensagem
                                if lr_ret_fvpia940.Codigo <> 0 then
                                    let ma_telacn[l_con].HorarioPref =
                                        lr_ret_fvpia940.Mensagem
                                    display ma_telacn[l_con].HorarioPref
                                     to s_cts06m09d[l_con].f_HorarioPref
                                     attribute(reverse)
                                    let lr_ret_AcionaVP.Codigo   = 77
                                    let lr_ret_AcionaVP.Mensagem =
                                        ' Atencao! Erro no envio de SMS!'
                                       ,' Verifique!'
                                    error lr_ret_fvpia940.Mensagem
                                end if
                            end if
                        else
                            #--------------------
                            # Envia e-mail ou SMS
                            #--------------------
                            if lr_aciona.TipoVinculo = 'F' then

                                #-------------------------------
                                # Envia SMS apenas se confirmado
                                #-------------------------------
                                if lr_aciona.EnviaSMS = 'S'       and
                                   lr_aciona.DDD      is not null and
                                   lr_aciona.Celular  is not null then

                                    call fvpic004_envia_sms(
                                              ma_aciona[l_con].NumeroServico
                                             ,ma_aciona[l_con].AnoServico
                                             ,lr_aciona.DDD
                                             ,lr_aciona.Celular)
                                    returning lr_ret_fvpia940.Codigo
                                             ,lr_ret_fvpia940.Mensagem

                                    if lr_ret_fvpia940.Codigo <> 0 then

                                        let ma_telacn[l_con].HorarioPref =
                                            lr_ret_fvpia940.Mensagem

                                        display ma_telacn[l_con].HorarioPref
                                         to s_cts06m09d[l_con].f_HorarioPref
                                         attribute(reverse)
                                        let lr_ret_AcionaVP.Codigo   = 77
                                        let lr_ret_AcionaVP.Mensagem =
                                            ' Atencao! Erro no envio de SMS!'
                                           ,' Verifique!'

                                        error lr_ret_fvpia940.Mensagem

                                    end if

                                end if

                            else

                                #-----------------------------
                                # Se for terceiro envia e-mail
                                #-----------------------------
                                call fvpic004_envia_email(
                                          ma_aciona[l_con].NumeroServico
                                         ,ma_aciona[l_con].AnoServico
                                         ,'S')
                                returning lr_ret_fvpia940.Codigo
                                         ,lr_ret_fvpia940.Mensagem

                                if lr_ret_fvpia940.Codigo <> 0 then

                                    let ma_telacn[l_con].HorarioPref =
                                        lr_ret_fvpia940.Mensagem

                                    display ma_telacn[l_con].HorarioPref
                                     to s_cts06m09d[l_con].f_HorarioPref
                                     attribute(reverse)
                                    let lr_ret_AcionaVP.Codigo   = 66
                                    let lr_ret_AcionaVP.Mensagem =
                                        ' Atencao! Erro no envio de e-mail!'
                                       ,' Verifique!'

                                    error lr_ret_fvpia940.Mensagem

                                end if
                            end if

                        end if

                    end if

                end for

                #------------------------------------------------------
                # Se ocorreu algum erro de acionamento continua na tela
                #------------------------------------------------------
                if lr_ret_AcionaVP.Codigo <> 0 then
                    error lr_ret_AcionaVP.Mensagem
                    next field f_SiglaVeiculo
                end if

                #------------------------------------------------------
                # Se nao ocorreu nenhum erro de acionamento retorna que
                # houve acionamento para refazer as listas
                #------------------------------------------------------
                if lr_ret_AcionaVP.Codigo = 0 then
                    let lr_ret_AcionaVP.Codigo   = 22
                    let lr_ret_AcionaVP.Mensagem =
                        ' Vistoria(s) acionada(s) com sucesso! '
                end if

            end if

    end input

    let int_flag = false
    close window cts06m09d

    return lr_ret_AcionaVP.Codigo
          ,lr_ret_AcionaVP.Mensagem

end function
