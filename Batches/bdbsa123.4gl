#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : bdbsa123                                                       #
# Programa   : bdbsa123 - Bonificacao por desempenho                          #
#-----------------------------------------------------------------------------#
# Analista Resp. : Jorge Modena                                               #
# PSI            : 229784                                                     #
#                                                                             #
# Desenvolvedor  : Jorge Modena                                               #
# DATA           : 10/2013                                                    #
#.............................................................................#
# Data        Autor            Alteracao                                      #
# ----------  ---------------  -----------------------------------------------#
# 26/05/2014  Rodolfo Massini  Alteracao na forma de envio de e-mail          #
#                             (SENDMAIL para FIGRC009)                        #
# 03/02/2016  ElianeK,Fornax  Retirada da var global g_ismqconn               #
###############################################################################

database porto

globals
  define   w_hostname        char(03)
end globals

define m_valor         decimal(12,2),
       m_comando       char(1500),
       m_pathlog       char(200),
       m_pathrel       char(200),
       m_patharq       char(200),
       m_nomearq1      char(200),
       m_nomearq2      char(200),
       m_remetente     char(200),
       m_destinatario  char(200),
       m_assunto       char(200),
       m_retorno       smallint,
       m_erro          char(200),
       m_arq1          char(100),
       m_arq2          char(100),
       m_auto_re       char(004),
       m_ultpstbon     like datmservico.atdprscod,
       m_prepare       smallint,
       m_vlrmxmbnf     decimal(5,2),
       m_mensagem      char(32000)

define m_curr          datetime year to second
define m_sttbnf        char(10)

main

  call bdbsa123_envia_sms(1)

  call fun_dba_abre_banco("CT24HS")

  # -> CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read

  let m_pathlog = f_path("DBS", "LOG")

  if m_pathlog is null then
     let m_pathlog = "."
  end if

  let m_patharq = m_pathlog clipped, "/bdbsa123.log"
  call startlog(m_patharq)

  let m_pathrel = f_path("DBS", "RELATO")

  if m_pathrel is null then
     let m_pathrel = "."
  end if

  let m_pathrel = m_pathrel clipped, "/RDBS11001"

  let m_patharq = f_path("DBS", "ARQUIVO")

  if m_patharq is null then
     let m_patharq = "."
  end if

  let m_curr = current

  let m_prepare = false

  ## verifica se bonificacao esta ativa para execucao
  whenever error continue
     select grlinf
       into m_sttbnf
       from datkgeral
      where grlchv = 'PSOBONIFICACAO2'
  whenever error stop
  display "SITUACAO BONIFICACAO ", m_sttbnf
  let m_sttbnf = m_sttbnf clipped

  if m_sttbnf = "ATIVO" then

     call bdbsa123_avaliacao_seguro()

     call bdbsa123()

  else
     let m_curr = current
     display "[", m_curr , "] BONIFICACAO NAO ESTA ATIVA - PROGRAMA BDBSA123.4GC NAO SERA EXECUTADO"
     call bdbsa123_envia_sms(2)
  end if


end main

#---------------------------#
 function bdbsa123_prepare()
#---------------------------#

define l_sql      char(3000),
       l_condicao char(100)

let l_condicao = " and datmservico.atdsrvorg in (1,2,4,5,6,7,9,17) "


###  CURSOR PRINCIPAL ###
let l_sql = " select distinct datmsrvacp.pstcoddig, "
            ,"                dpaksocor.nomgrr ,     "
            ,"                dpaksocor.maides ,     "
            ,"                datmsrvacp.srrcoddig,  "
            ,"                datksrr.srrnom,     "
            ,"                datkveiculo.socvclcod, "
            ,"                datkveiculo.socvcltip, "
            ,"                datkveiculo.atdvclsgl, "
            ,"                datkveiculo.mdtcod     "
	    ,"  from datmservico, dpaksocor, "
	    ,"       datmsrvacp, datksrr, datkveiculo "
	    ," where datmsrvacp.atdsrvseq = datmservico.atdsrvseq "
	    ,"   and datmsrvacp.atdetpdat >= ? "
	    ,"   and datmsrvacp.atdetpdat <= ? "
	    ,"   and datmservico.atdsrvnum = datmsrvacp.atdsrvnum "
	    ,"   and datmservico.atdsrvano = datmsrvacp.atdsrvano "
	    ,    l_condicao clipped
	    ,"   and dpaksocor.pstcoddig   = datmservico.atdprscod "
	    ,"   and dpaksocor.pstcoddig  >= ", m_ultpstbon
	    ,"   and dpaksocor.qldgracod   = 1 "                              # SOMENTE PADRAO PORTO
	    ,"   and datksrr.srrcoddig     = datmsrvacp.srrcoddig "
	    ,"   and datkveiculo.socvclcod = datmsrvacp.socvclcod "
	    ,"   and datkveiculo.mdtcod    > 0 "                              # MDT CADASTRADO
	    ,"   order by datmsrvacp.pstcoddig, datmsrvacp.srrcoddig, "
            ,"            datkveiculo.atdvclsgl                       "

prepare pbdbsa123001  from l_sql
declare cbdbsa123001  cursor with hold for pbdbsa123001

let m_curr = current
#display "[", m_curr, "] SQl = ", l_sql

###  Recupera o email do remetente (Porto Socorro) ###
let l_sql = " select relpamtxt "
	    ,"  from igbmparam "
	    ," where relsgl = 'BDBSR110' "
	    ,"   and relpamseq = 1 "
	    ,"   and relpamtip = 1 "

prepare pbdbsa123002  from l_sql
declare cbdbsa123002  cursor for pbdbsa123002

##Insere desempenho Socorrista
let l_sql = " insert into datmsrrdsn (dsnrefdat, prscod, srrcoddig,  "
           ,"                         cittipcod, srrdsnper, srratdqtd) "
           ,"                 values (?,?,?,?,?,?) "

prepare pbdbsa123003  from l_sql

##Insere seguro Socorrista
let l_sql = " insert into datmsrrsgrhst (sgrrefdat, prscod, srrcoddig, atosgrflg)"
           ,"                    values (?,?,?,?) "

prepare pbdbsa123004  from l_sql


##Insere desempenho Veiculo
let l_sql = " insert into datmvcldsn (dsnrefdat, prscod, socvclcod,  "
           ,"                         cittipcod, vcldsnper, vclatdqtd) "
           ,"                 values (?,?,?,?,?,?) "

prepare pbdbsa123005  from l_sql


##Insere Seguro Viatura
let l_sql = " insert into datmvclsgrhst (vclsgrrefdat, prscod, socvclcod, atosgrflg)"
           ,"                 values (?,?,?,?) "

prepare pbdbsa123006  from l_sql


##Insere Desempenho Consolidado Prestador
let l_sql = " insert into dpampstdsn (dsnrefdat, pstcoddig, cittipcod, pstdsnper)"
           ,"                 values (?,?,?,?) "

prepare pbdbsa123007  from l_sql

##Insere Premio Prestador por Grupo de Servi�o
let l_sql = " insert into dpampstprm (vlrrefdat, pstcoddig, prtbnfgrpcod, pstprmvlr, pstapuobstxt, efucmuflg)"
           ,"                 values (?,?,?,?,?,?) "

prepare pbdbsa123008  from l_sql

#Consulta se ja existe registro inserido para veiculo e criterio pesquisado
let l_sql = " select 1 ",
              "   from datmvcldsn",
              "  where dsnrefdat = ? ",
              "    and prscod = ? ",
              "    and socvclcod = ?",
              "    and cittipcod = ?"

prepare pbdbsa123009  from l_sql
declare cbdbsa123009  cursor for pbdbsa123009

#Consulta se ja existe registro inserido para socorrista e criterio pesquisado
let l_sql = " select 1 ",
              "   from datmsrrdsn",
              "  where dsnrefdat = ? ",
              "    and prscod = ? ",
              "    and srrcoddig = ?",
              "    and cittipcod = ?"

prepare pbdbsa123010  from l_sql
declare cbdbsa123010  cursor for pbdbsa123010

#Consulta se ja existe inf de seguro inserido para socorrista no periodo avaliado
let l_sql = " select 1 ",
              "   from datmsrrsgrhst",
              "  where sgrrefdat = ? ",
              "    and prscod = ? ",
              "    and srrcoddig = ?"

prepare pbdbsa123011  from l_sql
declare cbdbsa123011  cursor for pbdbsa123011


#Consulta se ja existe inf de seguro inserido para veiculo no periodo avaliado
let l_sql = " select 1 ",
              "   from datmvclsgrhst",
              "  where vclsgrrefdat = ? ",
              "    and prscod = ? ",
              "    and socvclcod = ?"

prepare pbdbsa123012  from l_sql
declare cbdbsa123012  cursor for pbdbsa123012

#Consulta quantidade de servi�os atendidos por veiculo no periodo e entre as horas a ser pesquisadas
let l_sql = "select count(*)",
	    "  from datmservico,",
	    "       datmsrvacp",
	    "  where datmsrvacp.atdsrvseq = datmservico.atdsrvseq ",
	    "    and datmsrvacp.atdetpdat >= ?",
	    "    and datmsrvacp.atdetpdat <= ? ",
	    "    and datmservico.atdsrvnum = datmsrvacp.atdsrvnum ",
	    "    and datmservico.atdsrvano = datmsrvacp.atdsrvano ",
	         l_condicao clipped,
            #"    and datmsrvacp.atdetphor between ? and ?",
            "    and datmsrvacp.pstcoddig = ? ",
            "    and datmsrvacp.socvclcod = ? "

prepare pbdbsa123013  from l_sql
declare cbdbsa123013  cursor for pbdbsa123013

#Consulta Parametro
let l_sql =  "select grlinf",
             "  from datkgeral",
             " where grlchv = ?"

prepare pbdbsa123014 from l_sql
declare cbdbsa123014 cursor for pbdbsa123014

# seleciona criterios avaliados para socorrista
let l_sql =  "select distinct bnfcrtcod, bnfcrtdes",
             " from dpakprtbnfcrt,",
             "      datmsrrdsn",
             "  where dpakprtbnfcrt.bnfcrtcod = datmsrrdsn.cittipcod",
             "  order by bnfcrtcod"

prepare pbdbsa123015 from l_sql
declare cbdbsa123015 cursor for pbdbsa123015

# seleciona prestadores que ainda n�o tiveram o criterio avaliado
let l_sql  = "select prscod,",
             "srrcoddig,",
             "cittipcod,",
             "srrdsnper,",
             "srratdqtd ",
             " from datmsrrdsn",
             "  where dsnrefdat = ?",
             "   and prscod > ?",
             "   and cittipcod = ?",
             "   order by prscod,",
             "            srrcoddig"

prepare pbdbsa123016 from l_sql
declare cbdbsa123016 cursor for pbdbsa123016

#Consulta se ja existe registro inserido para veiculo e criterio pesquisado
let l_sql = " select 1 ",
              "   from dpampstdsn",
              "  where dsnrefdat = ? ",
              "    and pstcoddig = ? ",
              "    and cittipcod = ?"

prepare pbdbsa123017 from l_sql
declare cbdbsa123017 cursor for pbdbsa123017

## seleciona criterios existentes para viatura
let l_sql  = "select distinct bnfcrtcod, bnfcrtdes",
             " from dpakprtbnfcrt,",
             "      datmvcldsn",
             "  where dpakprtbnfcrt.bnfcrtcod = datmvcldsn.cittipcod",
             "  order by bnfcrtcod"

prepare pbdbsa123018 from l_sql
declare cbdbsa123018 cursor for pbdbsa123018

##seleciona veiculos que nao tiveram criterios avaliados
let l_sql  = "select prscod,",
             "socvclcod,",
             "cittipcod,",
             "vcldsnper,",
             "vclatdqtd ",
             " from datmvcldsn",
             "  where dsnrefdat = ?",
             "   and prscod > ?",
             "   and cittipcod = ?",
             "   order by prscod,",
             "         socvclcod"

prepare pbdbsa123019 from l_sql
declare cbdbsa123019 cursor for pbdbsa123019

## verifica se ja existe valor bonificacao para grupo de servico no periodo corrente
let l_sql  = "select 1",
             " from dpampstprm",
             "  where vlrrefdat = ?",
             "   and pstcoddig = ?",
             "   and prtbnfgrpcod = ?"
prepare pbdbsa123020 from l_sql
declare cbdbsa123020 cursor for pbdbsa123020


## verificar quais grupos de servico prestador atendeu no periodo avaliado
let l_sql  = "select  distinct prtbnfgrpcod",
             " from datmservico, datmsrvacp, dpakbnfgrppar",
             " where datmsrvacp.atdsrvseq = datmservico.atdsrvseq",
             "   and datmsrvacp.atdetpdat >= ? ",
             "   and datmsrvacp.atdetpdat <= ? ",
             "   and datmservico.atdsrvnum = datmsrvacp.atdsrvnum",
             "   and datmservico.atdsrvano = datmsrvacp.atdsrvano",
             "   and datmsrvacp.pstcoddig  = ? ",
             "   and datmservico.atdsrvorg not in (9, 13)",
             "   and datmservico.atdsrvorg = dpakbnfgrppar.atdsrvorg",
             "   and datmservico.asitipcod = dpakbnfgrppar.asitipcod",
             " union",
             "   select distinct prtbnfgrpcod",
             " from datmservico, datmsrvacp, datmsrvre, dpakbnfgrppar",
             " where datmsrvacp.atdsrvseq = datmservico.atdsrvseq",
             "   and datmsrvacp.atdetpdat >= ? ",
             "   and datmsrvacp.atdetpdat <= ? ",
             "   and datmservico.atdsrvnum = datmsrvacp.atdsrvnum",
             "   and datmservico.atdsrvano = datmsrvacp.atdsrvano",
             "   and datmsrvacp.pstcoddig  = ?",
             "   and datmservico.atdsrvnum = datmsrvre.atdsrvnum",
             "   and datmservico.atdsrvano = datmsrvre.atdsrvano",
             "   and datmservico.atdsrvorg = dpakbnfgrppar.atdsrvorg",
             "   and datmsrvre.socntzcod = dpakbnfgrppar.socntzcod"

 prepare pbdbsa123021 from l_sql
 declare cbdbsa123021 cursor for pbdbsa123021

# seleciona prestadores que ainda n�o tiveram bonifica��o apurada
let l_sql  = "select distinct pstcoddig",
             " from dpampstdsn",
             "  where dsnrefdat = ?",
             "   and pstcoddig >= ?",
             "   order by pstcoddig"

prepare pbdbsa123022 from l_sql
declare cbdbsa123022 cursor for pbdbsa123022

# seleciona valor consolidado para cada criterio prestador
let l_sql  = "select pstdsnper",
             " from dpampstdsn",
             "  where dsnrefdat = ?",
             "   and pstcoddig = ?",
             "   and cittipcod = ?"


prepare pbdbsa123023 from l_sql
declare cbdbsa123023 cursor for pbdbsa123023


# consulta prestadores que ainda n�o tiveram comunica��o da bonificacao realizada
let l_sql  = "select pstcoddig,",
             "       prtbnfgrpcod,",
             "       pstprmvlr",
             " from dpampstprm",
             "  where vlrrefdat = ? ",
             "   and efucmuflg = 'N'",
             " order by pstcoddig, prtbnfgrpcod"


prepare pbdbsa123024 from l_sql
declare cbdbsa123024 cursor for pbdbsa123024

# seleciona faixa otima de premiacao
let l_sql = "select first 1 minper,",
            "               maxper,",
            "               fxavlr ",
            " from dpakbnfvlrfxa",
            "  where  prtbnfgrpcod = ?",
            "    and  bnfcrtcod = ? ",
            "  order by  fxavlr desc"


prepare pbdbsa123025 from l_sql
declare cbdbsa123025 cursor for pbdbsa123025

# consultar seguro de socorrista do prestador
let l_sql = "select datmsrrsgrhst.srrcoddig,",
            "       datksrr.srrnom,",
            "       datmsrrsgrhst.atosgrflg",
            " from datmsrrsgrhst, datksrr ",
            " where datmsrrsgrhst.srrcoddig = datksrr.srrcoddig",
            "   and datmsrrsgrhst.sgrrefdat = ?",
            "   and datmsrrsgrhst.prscod = ?" ,
            " order by datmsrrsgrhst.srrcoddig"

prepare pbdbsa123026 from l_sql
declare cbdbsa123026 cursor for pbdbsa123026


# consultar seguro de veiculo do socorrista
let l_sql = "select datmvclsgrhst.socvclcod,",
            "       datkveiculo.socvcltip,",
            "       datkveiculo.atdvclsgl,",
            "       datmvclsgrhst.atosgrflg",
            " from datmvclsgrhst, datkveiculo",
            " where datmvclsgrhst.socvclcod =  datkveiculo.socvclcod",
            "   and datmvclsgrhst.vclsgrrefdat = ? ",
            "   and datmvclsgrhst.prscod = ? ",
            " order by datmvclsgrhst.socvclcod"

prepare pbdbsa123027 from l_sql
declare cbdbsa123027 cursor for pbdbsa123027

## recupera informacoes criterio viatura
let l_sql = "select datmvcldsn.socvclcod,",
            "       datkveiculo.socvcltip,",
            "       datkveiculo.atdvclsgl,",
            "       datmvcldsn.vcldsnper,",
            "       datmvcldsn.vclatdqtd",
            " from datmvcldsn, datkveiculo",
            " where datmvcldsn.socvclcod =  datkveiculo.socvclcod",
            "   and datmvcldsn.dsnrefdat = ?",
            "   and datmvcldsn.prscod = ?",
            "   and datmvcldsn.cittipcod = ?",
            " order by datmvcldsn.socvclcod,datmvcldsn.cittipcod"

prepare pbdbsa123028 from l_sql
declare cbdbsa123028 cursor for pbdbsa123028

## recupera informacoes criterio socorrista
let l_sql = "select datksrr.srrcoddig,",
            "       datksrr.srrnom,",
            "       datmsrrdsn.srrdsnper,",
            "       datmsrrdsn.srratdqtd",
            " from datmsrrdsn, datksrr",
            " where datmsrrdsn.srrcoddig =  datksrr.srrcoddig",
            "   and datmsrrdsn.dsnrefdat = ? ",
            "   and datmsrrdsn.prscod = ?   ",
            "   and datmsrrdsn.cittipcod = ?",
            " order by datksrr.srrcoddig,datmsrrdsn.cittipcod"

prepare pbdbsa123029 from l_sql
declare cbdbsa123029 cursor for pbdbsa123029

## recupera qtd total atendimentos prestador por criterio da viatura
let l_sql = "select sum(vclatdqtd)",
            " from datmvcldsn",
            " where dsnrefdat = ?",
            "   and prscod = ?",
            "   and cittipcod = ?"

prepare pbdbsa123030 from l_sql
declare cbdbsa123030 cursor for pbdbsa123030

## recupera qtd total atendimentos prestador por criterio do socorrista
let l_sql = "select sum(srratdqtd)",
            " from datmsrrdsn",
            " where dsnrefdat = ?",
            "   and prscod = ? ",
            "   and cittipcod = ?"

prepare pbdbsa123031 from l_sql
declare cbdbsa123031 cursor for pbdbsa123031


###  Recupera o email do remetente (Porto Socorro) ###
let l_sql = " select relpamtxt "
	    ,"  from igbmparam "
	    ," where relsgl = 'BDBSR110' "
	    ,"   and relpamseq = 1 "
	    ,"   and relpamtip = 1 "

prepare pbdbsa123032 from l_sql
declare cbdbsa123032 cursor for pbdbsa123032


let l_sql = "select bnfcrtcod",
            " from dpakprtbnfgrpcrt",
            " where prtbnfgrpcod = ?",
            " order by bnfcrtcod asc "

prepare pbdbsa123033 from l_sql
declare cbdbsa123033 cursor for pbdbsa123033


let l_sql = " select maides ",
            "  from dpaksocor",
            "   where pstcoddig = ?"

prepare pbdbsa123037 from l_sql
declare cbdbsa123037 cursor for pbdbsa123037

##Atualiza envio de msg para prestador
let l_sql = " update dpampstprm ",
            "  set efucmuflg = 'S'",
            "  where vlrrefdat = ?",
            "    and pstcoddig = ?"

prepare cbdbsa123038  from l_sql



let m_prepare = true


end function

#-----------------------------------------------------------------------------#
function bdbsa123()
#-----------------------------------------------------------------------------#
define lr_trab         record
       bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
end record

define lr_qualifsatisf record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista
      ,pstcoddig       like dpaksocor.pstcoddig        ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome do Prestador
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
end record

define lr_qualifdisp   record
       mdtcod          like datkveiculo.mdtcod         ## Codigo do Socorrista
      ,pstcoddig       like dpaksocor.pstcoddig        ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome do Prestador
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,pertip          char(01)                        ## M=Manha T=Tarde
end record

define lr_retorno      record
       coderro         integer                         ## Cod.erro ret.0=OK/<>0 Error
      ,msgerro         char(100)                      ## Mensagem erro retorno
      ,qualificado     char(01)                       ## SIM ou NAO
end record

define lr_ctb00g07     record
       coderro         integer                         ## Cod.erro ret.0=OK/<>0 Error
      ,msgerro         char(100)                        ## Mensagem erro retorno
      ,numsrv         integer                  #=> Numero de servicos
      ,numrec         integer                  #=> Numero de reclamacoes
      ,percsatisf     dec(8,4)                 #=> Percentual de satisfacao
end record

define l_criterio         integer,
       l_auto_re          integer,
       l_pstant           like datmservico.atdprscod,
       l_dataref          date

 define lr_ctd27g02 record
        ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg         char(100),
        fxavlr      like dpakbnfvlrfxa.fxavlr
 end record

 define lr_ctd27g03  record
        ret          smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg          char(100),
        prtbnfgrpcod like dpakbnfgrppar.prtbnfgrpcod
 end record

 define lr_ctd27g04  record
        ret          smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg          char(100),
        credencia    char(1)
 end record

 define lr_ctb00g09    record
        coderro        integer,   #=> Codigo erro lr_retorno / 0=Ok <>0=Error
        msgerro        char(100),  #=> Mensagem erro lr_retorno
        percindisp     dec(8,2)  #=> Percentual de disponibilidade minima
 end record

 define lr_ctd28g00    record
          erro         smallint
         ,mensagem     char(100)
         ,socvcltip    like datkveiculo.socvcltip
         ,atdvclsgl    like datkveiculo.atdvclsgl
 end record

 define lr_cty11g00 record
        erro        smallint
       ,mensagem    char(100)
       ,cpodes      like iddkdominio.cpodes
 end record

 define lr_ctd27g00  record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100),
         bnfcrtdes   like dpakprtbnfcrt.bnfcrtdes
 end record

 define lr_ctd07g04  record
        resultado    smallint,
        mensagem     char(60),
        socntzcod    like datmsrvre.socntzcod
 end record

 define l_ret    smallint,
        l_msg    char(50),
        l_crttip like dpakprtbnfcrt.crttip,
        l_qtdsrv integer

 define lr_ctb00g12    record
        coderro        integer,  #=> Codigo erro / 0=Ok <>0=Error
        msgerro        char(120), #=> Mensagem erro
        numsrv         integer,                 #=> Numero de servicos
        numret         integer,                 #=> Numero de retornos
        percresolub    dec(8,4)  #=> Percentual de resolubilidade
 end record

 define lr_ctd27g05  record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100),
         prtbnfgrpdes   like dpaksrvgrp.prtbnfgrpdes
  end record

  define lr_ctb00g06     record
          coderro        integer,
          msgerro        char(100),
          qtdsrv         integer,
          percpont       dec(8,4)
  end record

  define l_sql      char(3000)


 initialize lr_trab.*         to null
 initialize lr_qualifsatisf.* to null
 initialize lr_qualifdisp.*   to null
 initialize lr_retorno.*      to null
 initialize lr_ctd27g00.*     to null
 initialize lr_ctd27g02.*     to null
 initialize lr_ctd27g03.*     to null
 initialize lr_ctd27g04.*     to null
 initialize lr_ctd27g05.*     to null
 initialize lr_ctb00g09.*     to null
 initialize lr_ctd28g00.*     to null
 initialize lr_cty11g00.*     to null
 initialize lr_ctd07g04.*     to null
 initialize lr_ctb00g06.*     to null

 let m_arq1 = null
 let m_arq2 = null
 let l_ret = 0
 let l_msg = null
 let l_sql = null

 let l_dataref         = null

 ###  Recebe data corrente para avaliacao dos criterios ###
 let lr_trab.datastr = today

 ###  Determina  as datas para avaliacao  ###
 let lr_trab.datastr = "16", lr_trab.datastr[3,10]
 let lr_trab.dataini = lr_trab.datastr
 let lr_trab.dataini = lr_trab.dataini - 1 units month
 let lr_trab.datafim = lr_trab.dataini + 1 units month - 1 units day

 let lr_trab.datastr = lr_trab.dataini
 let lr_trab.datastr = "15", lr_trab.datastr[3,10]
 let lr_trab.datavig = lr_trab.datastr

 ### Determina data referencia da an�lise de desempenho ###
 let lr_trab.datastr = today
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr
 display "DATA REFERENCIA ",l_dataref

 ##  Verifica ultimo prestador avaliado
 whenever error continue
 select max(prscod) into m_ultpstbon
  from datmsrrdsn
   where dsnrefdat = l_dataref
  whenever error stop

 if m_ultpstbon is null then
    let m_ultpstbon = 0
 end if


 call bdbsa123_prepare()


 display "ULTIMO PRESTADOR", m_ultpstbon

 let lr_trab.atdprscod = 0

 let m_curr = current
 display "[", m_curr, "] INICIO DA AVALIACAO DESEMPENHO INDIVIDUAL SOCORRISTA E VIATURA"
 display "[", m_curr , "] DATA INICIAL: ", lr_trab.dataini, " DATA FINAL : ", lr_trab.datafim

 let m_curr = current
 display "[", m_curr, "] ABRINDO CURSOR PRINCIPAL"

 open cbdbsa123001 using lr_trab.dataini, lr_trab.datafim

 foreach cbdbsa123001 into  lr_trab.atdprscod,
                            lr_trab.nomgrr,
                            lr_trab.maides,
                            lr_trab.srrcoddig,
                            lr_trab.srrnom,
                            lr_trab.socvclcod,
                            lr_trab.socvcltip,
                            lr_trab.atdvclsgl,
                            lr_trab.mdtcod


     if lr_trab.atdprscod <> l_pstant then
        let l_pstant = lr_trab.atdprscod

        let m_curr = current
        display "[", m_curr, "] AVALIANDO PRESTADOR: ", lr_trab.atdprscod

     end if

     # VERIFICA PRESTADOR BONIFICAVEL
     if  not ctc20m07_participa_bonificacao(lr_trab.atdprscod) then

         let m_curr = current
         display "[", m_curr, "] PRESTADOR NAO BONIFICAVEL: ", lr_trab.atdprscod
         continue foreach
     end if


     ## Qualifica criterios Socorrista
     let lr_trab.satisf = 0
     #Satisfacao Cliente Criterio 5
     let l_criterio = 5

     #verifica se socorrista ainda n�o foi avaliado neste crit�rio
     open cbdbsa123010 using l_dataref, lr_trab.atdprscod,
                             lr_trab.srrcoddig, l_criterio

     fetch cbdbsa123010
        if sqlca.sqlcode = notfound then

           #qualifica Satisfacao Socorrista

           let lr_qualifsatisf.srrcoddig = lr_trab.srrcoddig
           let lr_qualifsatisf.pstcoddig = lr_trab.atdprscod
           let lr_qualifsatisf.nomgrr    = lr_trab.nomgrr
           let lr_qualifsatisf.dataini   = lr_trab.dataini - 2 units month
           let lr_qualifsatisf.datafim   = lr_trab.datafim

           call ctb00g07_qualifsatisf(lr_qualifsatisf.srrcoddig,
                                      lr_qualifsatisf.pstcoddig,
                                      lr_qualifsatisf.nomgrr,
                                      lr_qualifsatisf.dataini,
                                      lr_qualifsatisf.datafim)
                returning lr_ctb00g07.*


           let lr_trab.numsrv     = lr_ctb00g07.numsrv
           let lr_trab.numrec     = lr_ctb00g07.numrec
           let lr_trab.percsatisf = lr_ctb00g07.percsatisf

           let m_curr = current
           display "BONIFICACAO | CRITERIO SATISFACACAO | PRESTADOR: ", lr_qualifsatisf.pstcoddig , " |SOCORRISTA: ", lr_qualifsatisf.srrcoddig , " | MENSAGEM: ", lr_ctb00g07.msgerro

           if lr_ctb00g07.coderro <> 0 then
              let m_erro = lr_ctb00g07.coderro,"-", lr_ctb00g07.msgerro
              call errorlog(m_erro)
              let m_curr = current
              display "[", m_curr, "] bdbsa123/ctb00g07_qualifsatisf / ", m_erro clipped
           else
              #insere avaliacao criterio no banco
              execute pbdbsa123003 using l_dataref,
                                         lr_trab.atdprscod,
                                         lr_trab.srrcoddig,
                                         l_criterio,
                                         lr_trab.percsatisf,
                                         lr_trab.numsrv

              if sqlca.sqlcode <> 0 then
                 let m_curr = current
                 display "[", m_curr, "] Erro na inclusao da Satisfacao Socorrista: ", lr_trab.srrcoddig
              end if
           end if
        end if
     close cbdbsa123010


     #verifica se pontualidade j� foi avaliada
     #Criterio Pontualidade - 6
     let l_criterio = 6

     #verifica se socorrista ainda n�o foi avaliado neste crit�rio
     open cbdbsa123010 using l_dataref, lr_trab.atdprscod,
                             lr_trab.srrcoddig, l_criterio

     fetch cbdbsa123010

        if sqlca.sqlcode = notfound then


           #Qualifica Pontualidade Socorrista
           call ctb00g06_qualifpontsrr(lr_trab.srrcoddig,
                                       lr_trab.atdprscod,
                                       lr_trab.dataini,
                                       lr_trab.datafim)
                returning lr_ctb00g06.*

           let m_curr = current


           if lr_retorno.coderro <> 0 then
              let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsa123/ctb00g06_qualifpontsrr / ", m_erro clipped
           else
              #insere avaliacao criterio no banco
              execute pbdbsa123003 using l_dataref,
                                         lr_trab.atdprscod,
                                         lr_trab.srrcoddig,
                                         l_criterio,
                                         lr_ctb00g06.percpont,
                                         lr_ctb00g06.qtdsrv


              if sqlca.sqlcode <> 0 then
                 let m_curr = current
                 display "[", m_curr, "] Erro na inclusao da Pontualidade Socorrista: ", lr_trab.srrcoddig
              end if
           end if
        end if

     close cbdbsa123010

     #verifica se resobilidade j� foi avaliada
     #Criterio Resobilidade - 7
     #let l_criterio = 7

     #verifica se socorrista ainda n�o foi avaliado neste crit�rio
     #open cbdbsa123010 using l_dataref, lr_trab.atdprscod,
     #                        lr_trab.srrcoddig, l_criterio

        #if sqlca.sqlcode = notfound then
           #Qualifica Resubilidade
           #let lr_qualifsatisf.srrcoddig = lr_trab.srrcoddig
           #let lr_qualifsatisf.pstcoddig = lr_trab.atdprscod
           #let lr_qualifsatisf.nomgrr    = lr_trab.nomgrr
           #let lr_qualifsatisf.dataini   = lr_trab.dataini - 5 units month
           #let lr_qualifsatisf.datafim   = ((lr_trab.dataini - 2 units month) - 1 units day)
           #
           #
           #let m_curr = current
           #call ctb00g12_qualifresolub(lr_qualifsatisf.srrcoddig,
           #                            lr_qualifsatisf.pstcoddig,
           #                            lr_qualifsatisf.nomgrr,
           #                            lr_qualifsatisf.dataini,
           #                            lr_qualifsatisf.datafim)
           #     returning lr_ctb00g12.*
           #
           #let m_curr = current
           #
           #
           #if lr_ctb00g12.coderro <> 0 then
           #   let m_erro = lr_ctb00g12.coderro,"-", lr_ctb00g12.msgerro
           #   call errorlog(m_erro)
           #           let m_curr = current
           #           display "[", m_curr, "] bdbsa123 /ctb00g12_qualifresolub ", m_erro clipped
           #end if
           #
           #let lr_trab.numsrv_res = lr_ctb00g12.numsrv
           #let lr_trab.numret_res = lr_ctb00g12.numret
           #let lr_trab.percresolub = lr_ctb00g12.percresolub
        #end if
     #close cbdbsa123010

     ## Avalia criterios VIATURA

     # NAO CONSIDERA A BONIFICACAO PARA OS TIPOS DE VEICULOS ABAIXO
     if lr_trab.socvcltip = 10 or lr_trab.socvcltip = 11 or
        lr_trab.socvcltip = 12 or lr_trab.socvcltip = 13 then

        let m_curr = current
        display "[", m_curr, "] TIPO DE VEICULO NAO BONIFICAVEL : ", lr_trab.socvcltip
        continue foreach
     end if

     #verifica se Disponibilidade Manha j� foi avaliada

     let l_criterio = 3

     open cbdbsa123009 using l_dataref, lr_trab.atdprscod,
                             lr_trab.socvclcod, l_criterio

     fetch cbdbsa123009

        if sqlca.sqlcode = notfound then

           ## Qualifica a disponibilidade pela manha
           ## --------------------------------------
           let lr_qualifdisp.mdtcod    = lr_trab.mdtcod
           let lr_qualifdisp.pstcoddig = lr_trab.atdprscod
           let lr_qualifdisp.nomgrr    = lr_trab.nomgrr
           let lr_qualifdisp.dataini   = lr_trab.dataini
           let lr_qualifdisp.datafim   = lr_trab.datafim
           let lr_qualifdisp.pertip    = "M"

           initialize lr_ctb00g09.*     to null
           call ctb00g09_qualifdisp(lr_qualifdisp.mdtcod,
                                    lr_qualifdisp.pstcoddig,
                                    lr_qualifdisp.nomgrr,
                                    lr_qualifdisp.dataini,
                                    lr_qualifdisp.datafim,
                                    lr_qualifdisp.pertip)
                returning lr_ctb00g09.*

           display "BONIFICACAO | CRITERIO DISP MANHA | PRESTADOR: ", lr_qualifdisp.pstcoddig , " | VIATURA: ", lr_trab.socvclcod , " | MENSAGEM: ", lr_ctb00g09.msgerro


           if lr_ctb00g09.percindisp is null then
              let lr_ctb00g09.percindisp = 0
           end if

           if lr_ctb00g09.coderro <> 0 then
              let m_erro = lr_ctb00g09.coderro,"-", lr_ctb00g09.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsa123/ctb00g09_qualifdisp / ", m_erro clipped
           else

               #valida qtd atd viatura
               call bdbsa123_qtd_atd_veiculo(lr_trab.dataini ,
                                             lr_trab.datafim,
                                             lr_trab.atdprscod,
                                             lr_trab.socvclcod,
                                             lr_qualifdisp.pertip)

                   returning l_ret,l_msg, l_qtdsrv

               if l_ret <> 0 then
                  let m_curr = current
                  display "[", m_curr, "] Erro na consulta da qtd de servicos viatura periodo manha: ", lr_trab.socvclcod
                  display "ERRO ", l_msg
               else
                  #insere avaliacao criterio no banco
                  execute pbdbsa123005 using l_dataref,
                                             lr_trab.atdprscod,
                                             lr_trab.socvclcod,
                                             l_criterio,
                                             lr_ctb00g09.percindisp,
                                             l_qtdsrv

                  if sqlca.sqlcode <> 0 then
                     let m_curr = current
                     display "[", m_curr, "] Erro na inclusao da Disponbilidade Manha Veiculo: ", lr_trab.socvclcod
                  end if
               end if
           end if

        end if

     close cbdbsa123009


     #verifica se Disponibilidade Tarde j� foi avaliada
     #Criterio Pontualidade - 4
     let l_criterio = 4

     open cbdbsa123009 using l_dataref, lr_trab.atdprscod,
                             lr_trab.socvclcod, l_criterio

     fetch cbdbsa123009

        if sqlca.sqlcode = notfound then

           ## Qualifica a disponibilidade pela tarde

           let lr_qualifdisp.pertip    = "T"

           initialize lr_ctb00g09.*     to null
           call ctb00g09_qualifdisp(lr_qualifdisp.mdtcod,
                                    lr_qualifdisp.pstcoddig,
                                    lr_qualifdisp.nomgrr,
                                    lr_qualifdisp.dataini,
                                    lr_qualifdisp.datafim,
                                    lr_qualifdisp.pertip)
                returning lr_ctb00g09.*

           display "BONIFICACAO | CRITERIO DISP TARDE | PRESTADOR: ", lr_qualifdisp.pstcoddig , " | VIATURA: ", lr_trab.socvclcod , " | MENSAGEM: ", lr_ctb00g09.msgerro

           if lr_ctb00g09.percindisp is null then
              let lr_ctb00g09.percindisp = 0
           end if

           if lr_ctb00g09.coderro <> 0 then
              let m_erro = lr_ctb00g09.coderro,"-", lr_ctb00g09.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsa123 / ", m_erro clipped
           else
              #valida qtd atd viatura
               call bdbsa123_qtd_atd_veiculo(lr_trab.dataini ,
                                             lr_trab.datafim,
                                             lr_trab.atdprscod,
                                             lr_trab.socvclcod,
                                             lr_qualifdisp.pertip)

                   returning l_ret,l_msg, l_qtdsrv

               if l_ret <> 0 then
                  let m_curr = current
                  display "[", m_curr, "] Erro na consulta da qtd de servicos viatura periodo tarde: ", lr_trab.socvclcod
                  display "ERRO ", l_msg
               else
                  #insere avaliacao criterio no banco
                  execute pbdbsa123005 using l_dataref,
                                             lr_trab.atdprscod,
                                             lr_trab.socvclcod,
                                             l_criterio,
                                             lr_ctb00g09.percindisp,
                                             l_qtdsrv

                  if sqlca.sqlcode <> 0 then
                     let m_curr = current
                     display "[", m_curr, "] Erro na inclusao da Disponbilidade Manha Veiculo: ", lr_trab.socvclcod
                  end if
               end if
           end if
        end if

     close cbdbsa123009

 end foreach #cbdbsa123001

 let m_curr = current
 display "[", m_curr, "] FIM DA AVALIACAO DESEMPENHO INDIVIDUAL SOCORRISTA E VIATURA"


 ## Consolida todos os criterios do Socorrista
 call bdbsa123_consolida_criterio_srr()

 ## Consolida todos os criterios do Veiculo
 call bdbsa123_consolida_criterio_vcl()

 ## Avalia valor premio do Prestador Consolidando todas as informacoes
 call bdbsa123_avaliacao_premio_pst()

 ## Envia comunicado aos prestadores
 call bdbsa123_comunica_bonificacao()

 ##Limpa desempenho socorrista e viatura com mais de 6 meses
 call bdbsa123_limpa_registros()


 call bdbsa123_envia_sms(2)

end function

#-------------------------------#
function bdbsa123_valor(l_valor)
#-------------------------------#

  define l_valor     decimal(12,2),
         l_retorno   char(10),
         l_ix1       smallint

  if l_valor is null then
     let l_valor = 0
  end if

  let l_retorno = l_valor using "###,##&.&&"

  for l_ix1 = 1 to 10
      if l_retorno[l_ix1] = "." then
         let l_retorno[l_ix1] = ","
      else
         if l_retorno[l_ix1] = "," then
            let l_retorno[l_ix1] = "."
         end if
      end if
  end for

  return l_retorno

end function




 function fonetica2()

 end function


#------------------------------------#
 function bdbsa123_envia_sms(l_opcao)
#------------------------------------#

 define l_opcao smallint,

        l_txt   char(50),
        l_proc  char(15)



     if  l_opcao = 1 then
         let l_proc = 'BON082011I'
         let l_txt = "BONIFICACAO NOVA INICIADA AS ", current
     else
         let l_proc = 'BON082011F'
         let l_txt = "BONIFICACAO NOVA FINALIZADA AS ", current
     end if

     let m_curr = current
     display "[", m_curr, "] PROC ", l_proc

     whenever error continue
       delete from dbsmenvmsgsms where smsenvcod = l_proc
     whenever error stop


     whenever error continue
       insert into dbsmenvmsgsms values(l_proc,
                                        '99170431',
                                        l_txt,
                                        '',
                                        current,
                                        'A',
                                        '',
                                        '11',
                                        '')
     whenever error stop

     let m_curr = current
     display "[", m_curr, "] SQLCA.sqlcode", sqlca.sqlcode

 end function



#-----------------------------------------------------------------------------#
function bdbsa123_avaliacao_seguro()
#-----------------------------------------------------------------------------#
define lr_trab         record
       datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
end record

define lr_qualifseg    record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,pstcoddig       like dpaksocor.pstcoddig        ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome do Prestador
      ,datavig         date                            ## Data para vig dos seguros
end record

define lr_retorno      record
       coderro         integer                         ## Cod.erro ret.0=OK/<>0 Error
      ,msgerro         char(100)                      ## Mensagem erro retorno
      ,qualificado     char(01)                       ## SIM ou NAO
end record

define l_data             date,
       l_pstant           like datmservico.atdprscod,
       l_dataref          date

 initialize lr_trab.*         to null
 initialize lr_qualifseg.*    to null
 initialize lr_retorno.*      to null

 let l_dataref         = null

 ###  Atribui a data atual para processamento da avaliacao do seguro
 let lr_trab.datastr = today

 ###  Determina  as datas conforme o parametro ou today  ###
 let lr_trab.datastr = "16", lr_trab.datastr[3,10]
 let lr_trab.dataini = lr_trab.datastr
 let lr_trab.dataini = lr_trab.dataini - 1 units month
 let lr_trab.datafim = lr_trab.dataini + 1 units month - 1 units day

 ### Determina data vigencia avaliacao seguros
 let lr_trab.datastr = today
 let lr_trab.datastr = "15", lr_trab.datastr[3,10]
 let lr_trab.datavig = lr_trab.datastr

 ### Determina data referencia da an�lise de desempenho ###
 let lr_trab.datastr = today
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr

 let lr_trab.atdprscod = 0

 ##  Verifica ultimo prestador avaliado
 whenever error continue
 select max(prscod) into m_ultpstbon
  from datmsrrsgrhst
   where sgrrefdat = l_dataref

 whenever error stop

 if m_ultpstbon is null then
    let m_ultpstbon = 0
 end if

  if not m_prepare then
    call bdbsa123_prepare()
 end if

 let m_curr  = current
 display "[", m_curr , "] REALIZANDO ANALISE SEGURO VIATURA E SOCORRISTA: "
 display "[", m_curr , "] DATA INICIAL: ", lr_trab.dataini, " DATA FINAL : ", lr_trab.datafim

 let m_curr = current
 display "[", m_curr, "] ABRINDO CURSOR PRINCIPAL"

 let l_pstant = 0

 open cbdbsa123001 using lr_trab.dataini, lr_trab.datafim

 foreach cbdbsa123001 into  lr_trab.atdprscod,
                            lr_trab.nomgrr,
                            lr_trab.maides,
                            lr_trab.srrcoddig,
                            lr_trab.srrnom,
                            lr_trab.socvclcod,
                            lr_trab.socvcltip,
                            lr_trab.atdvclsgl,
                            lr_trab.mdtcod



     if  lr_trab.atdprscod <> l_pstant then
          let l_pstant = lr_trab.atdprscod
          let m_curr  = current
          display "[", m_curr , "] REALIZANDO ANALISE PRESTADOR: ", lr_trab.atdprscod
     end if

     # VERIFICA PRESTADOR BONIFICAVEL
     if  not ctc20m07_participa_bonificacao(lr_trab.atdprscod) then

         let m_curr = current
         display "[", m_curr, "] PRESTADOR NAO BONIFICAVEL: ", lr_trab.atdprscod
         continue foreach
     end if



     ## Verifica se seguro de socorrista j� n�o foi avaliado para prestador e socorista corrente
     open cbdbsa123011 using l_dataref, lr_trab.atdprscod,
                        lr_trab.srrcoddig

     fetch cbdbsa123011

        if sqlca.sqlcode = notfound then

           ## Qualifica seguro do prestador + veiculo
           let lr_qualifseg.srrcoddig = lr_trab.srrcoddig
           let lr_qualifseg.socvclcod = lr_trab.socvclcod
           let lr_qualifseg.pstcoddig = lr_trab.atdprscod
           let lr_qualifseg.nomgrr    = lr_trab.nomgrr
           let lr_qualifseg.datavig   = lr_trab.datavig

           call ctb00g08_qualifsrr(lr_qualifseg.srrcoddig,
                                   lr_qualifseg.socvclcod,
                                   lr_qualifseg.pstcoddig,
                                   lr_qualifseg.nomgrr,
                                   lr_qualifseg.datavig)
                returning lr_retorno.*

           let m_curr = current

           if lr_retorno.coderro <> 0 then
              let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsa123/ctb00g08_qualifsrr / ", m_erro clipped
              ## em caso de problemas na pesquisa sistema n�o dever� prejudicar socorrista ##
              let lr_retorno.qualificado = 'S'
           end if

           execute pbdbsa123004 using l_dataref, lr_qualifseg.pstcoddig,
                                      lr_qualifseg.srrcoddig, lr_retorno.qualificado

           if sqlca.sqlcode <> 0 then
               let m_curr = current
               display "[", m_curr, "] Erro na inclusao do Seguro Socorrista: ", lr_qualifseg.srrcoddig
           end if
        end if
     close cbdbsa123011


     # NAO CONSIDERA A BONIFICACAO PARA OS TIPOS DE VEICULOS ABAIXO
     if lr_trab.socvcltip =  8 or lr_trab.socvcltip = 10 or
        lr_trab.socvcltip = 11 or lr_trab.socvcltip = 12 or
        lr_trab.socvcltip = 13 then

        let m_curr = current
        display "[", m_curr, "] TIPO DE VEICULO NAO BONIFICAVEL : ", lr_trab.socvcltip
        continue foreach
     end if

     ##Verifica se ja fez a apuracao de Seguro para Viatura
     ##veiculo varia de socorrista, mas a avaliacao do seguro � a mesma
     open cbdbsa123012 using l_dataref, lr_trab.atdprscod,
                             lr_trab.socvclcod

     fetch cbdbsa123012

        if sqlca.sqlcode = notfound then
           ## Qualifica seguro veiculo
           let lr_qualifseg.srrcoddig = lr_trab.srrcoddig
           let lr_qualifseg.socvclcod = lr_trab.socvclcod
           let lr_qualifseg.pstcoddig = lr_trab.atdprscod
           let lr_qualifseg.nomgrr    = lr_trab.nomgrr
           let lr_qualifseg.datavig   = lr_trab.datavig

           call ctb00g08_qualifvcl(lr_qualifseg.srrcoddig,
                                   lr_qualifseg.socvclcod,
                                   lr_qualifseg.pstcoddig,
                                   lr_qualifseg.nomgrr,
                                   lr_trab.dataini,
                                   lr_trab.datafim)
                returning lr_retorno.*, lr_trab.socvcltip

           let m_curr = current

           if lr_retorno.coderro <> 0 then
              let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
              call errorlog(m_erro)
              let m_curr = current
              display "[", m_curr, "] bdbsa123/ctb00g08_qualifvcl / ", m_erro clipped
              ## em caso de problemas na pesquisa sistema n�o dever� prejudicar Viatura ##
              let lr_retorno.qualificado = 'S'

           end if

           execute pbdbsa123006 using l_dataref, lr_qualifseg.pstcoddig,
                                      lr_qualifseg.socvclcod, lr_retorno.qualificado

           if sqlca.sqlcode <> 0 then
               let m_curr = current
               display "[", m_curr, "] Erro na inclusao do Seguro Viatura: ", lr_qualifseg.socvclcod
           end if
        end if

     close cbdbsa123012

 end foreach

end function




#-----------------------------------------------------------------------------#
function bdbsa123_qtd_atd_veiculo(lr_param)
#-----------------------------------------------------------------------------#
 define lr_param        record
        dataini         date                            ## Data Inicial
       ,datafim         date                            ## Data Final
       ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
       ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
       ,pertip          char(01)                        #=> M=Manha T=Tarde
 end record

 define lr_retorno      record
        coderro         integer                         ## Cod.erro ret.0=OK/<>0 Error
       ,msgerro         char(100)                       ## Mensagem erro retorno
       ,qtdsrv          integer
 end record

 define lr_aux         record
          horaini        datetime hour to minute,   #=> Primeira hora cheia
          horafim        datetime hour to minute,   #=> Ultima hora cheia
          grlchv         like datkgeral.grlchv,
          hrinifim       char(10),
          horario        char(05)
   end record

 initialize lr_retorno.*      to null


  if not m_prepare then
    call bdbsa123_prepare()
 end if

 let m_curr  = current
 display "[", m_curr , "] ANALISE QUANTIDADE ATENDIMENTO REALIZADO POR VEICULO "
 display "[", m_curr , "] DATA INICIAL: ", lr_param.dataini, " DATA FINAL : ", lr_param.datafim


 whenever error continue
 open cbdbsa123013 using lr_param.dataini,
                         lr_param.datafim,
                         lr_param.atdprscod,
                         lr_param.socvclcod


 fetch cbdbsa123013 into lr_retorno.qtdsrv
 whenever error stop

 if sqlca.sqlcode <> 0 then

    let lr_retorno.coderro = sqlca.sqlcode
    let lr_retorno.msgerro = "Erro ao selecionar quantidade de servicos do veiculo(ctb00g09):",
                             sqlca.sqlerrd[2]

    return lr_retorno.*
 end if
 close  cbdbsa123013

 let lr_retorno.coderro = 0


 return lr_retorno.*


end function


#-----------------------------------------------------------------------------#
function bdbsa123_consolida_criterio_srr()
#-----------------------------------------------------------------------------#
define lr_trab         record
       datastr         char(10)                        ## Data
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,cittipcod       like datmsrrdsn.cittipcod       ## Codigo Tipo Criterio
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes    ## Descricao Tipo Criterio
      ,srrdsnper       like datmsrrdsn.srrdsnper       ## Percentual Atingido por Socorrista
      ,srratdqtd       like datmsrrdsn.srratdqtd       ## Quantidade Atendimento por Socorrista
end record


define l_ant_atdprscod    like datmservico.atdprscod,
       l_pstant           like datmservico.atdprscod,
       l_dataref          date,
       l_flag             smallint,
       l_somaproduto      decimal(8,2),
       l_somaqtdsrv       integer,
       l_pstdsnper        like dpampstdsn.pstdsnper


 let l_flag     = false
 let l_dataref  = null

 initialize lr_trab.*  to null


 ###  Atribui a data atual para consolidacao dos criterios de socorrista
 let lr_trab.datastr = today

 ### Determina data referencia da an�lise de avaliacao ###
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr


 let lr_trab.atdprscod = 0
 let l_pstant = 0
 let l_pstdsnper = 0
 let l_somaproduto = 0
 let l_somaqtdsrv = 0

  if not m_prepare then
    call bdbsa123_prepare()
 end if

 let m_curr  = current
 display "[", m_curr , "] INICIO CONSOLIDACAO CRITERIOS SOCORRISTA PARA PRESTADOR"

 ## verifica criterios que dever�o ser consolidados para prestador

 open cbdbsa123015

 foreach cbdbsa123015 into lr_trab.cittipcod,lr_trab.bnfcrtdes

    let l_flag = false
    let l_pstant = 0

    let m_curr  = current
    display "[", m_curr , "] INICIO CONSOLIDACAO CRITERIO ",lr_trab.bnfcrtdes


    whenever error continue
    ## verificando ultimo prestador analisado para criterio
    select max(pstcoddig) into lr_trab.atdprscod
     from dpampstdsn
      where dsnrefdat = l_dataref
       and cittipcod  = lr_trab.cittipcod

    whenever error stop

    if lr_trab.atdprscod is null then
       let lr_trab.atdprscod = 0
    end if

    open cbdbsa123016 using l_dataref, lr_trab.atdprscod, lr_trab.cittipcod

    foreach cbdbsa123016 into  lr_trab.atdprscod,
                               lr_trab.srrcoddig,
                               lr_trab.cittipcod,
                               lr_trab.srrdsnper,
                               lr_trab.srratdqtd

        if  l_flag = true and lr_trab.atdprscod <> l_pstant then

             ##calcula media ponderada e inclui registro na tabela dpampstdsn
             if l_somaqtdsrv <> 0 then
                let l_pstdsnper = l_somaproduto/l_somaqtdsrv
             else
                let l_pstdsnper = 0
             end if

             whenever error continue
             execute pbdbsa123007 using l_dataref, l_pstant,
                                        lr_trab.cittipcod, l_pstdsnper

             if sqlca.sqlcode <> 0 then
                 let m_curr = current
                 display "[", m_curr, "] Erro na inclusao do Valor Consolidado Criterio ",lr_trab.bnfcrtdes ," Prestador: ", l_pstant
             end if
             whenever error stop

             let l_somaproduto = 0
             let l_somaqtdsrv = 0
             let l_pstdsnper = 0
        end if

        let l_somaproduto = l_somaproduto + (lr_trab.srrdsnper * lr_trab.srratdqtd)
        let l_somaqtdsrv = l_somaqtdsrv + lr_trab.srratdqtd
        let l_pstant = lr_trab.atdprscod

        if l_flag = false then
           let l_flag = true
        end if


    end foreach

    let m_curr  = current
    display "[", m_curr , "] FIM CONSOLIDACAO CRITERIO ",lr_trab.bnfcrtdes

 end foreach

 let m_curr  = current
 display "[", m_curr , "] FIM CONSOLIDACAO CRITERIOS SOCORRISTA PARA PRESTADOR"

end function

#-----------------------------------------------------------------------------#
function bdbsa123_consolida_criterio_vcl()
#-----------------------------------------------------------------------------#
define lr_trab         record
       datastr         char(10)                        ## Data
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,socvclcod       like datmsrvacp.socvclcod       ## Codigo da Viatura
      ,cittipcod       like datmsrrdsn.cittipcod       ## Codigo Tipo Criterio
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes    ## Descricao Tipo Criterio
      ,vcldsnper       like datmvcldsn.vcldsnper       ## Percentual Atingido por Viatura
      ,vclatdqtd       like datmvcldsn.vclatdqtd       ## Quantidade Atendimento por Viatura
end record


define l_ant_atdprscod    like datmservico.atdprscod,
       l_pstant           like datmservico.atdprscod,
       l_dataref          date,
       l_flag             smallint,
       l_somaproduto      decimal(8,2),
       l_somaqtdsrv       integer,
       l_pstdsnper        like dpampstdsn.pstdsnper


 initialize lr_trab.*         to null

 let l_dataref         = null

 ###  Atribui a data atual para consolidacao dos criterios de socorrista
 let lr_trab.datastr = today

 ### Determina data referencia da an�lise de avaliacao ###
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr


 let lr_trab.atdprscod = 0
 let l_ant_atdprscod   = 0

  if not m_prepare then
    call bdbsa123_prepare()
 end if

 let m_curr  = current
 display "[", m_curr , "] INICIO CONSOLIDACAO CRITERIOS VIATURA PARA PRESTADOR"


 let l_pstant = 0

 ## verifica criterios que dever�o ser consolidados para prestador

 open cbdbsa123018

 foreach cbdbsa123018 into lr_trab.cittipcod,lr_trab.bnfcrtdes

    let l_flag = false

    let m_curr  = current
    display "[", m_curr , "] INICIO CONSOLIDACAO CRITERIO ",lr_trab.bnfcrtdes

    whenever error continue
    ## verificando ultimo prestador analisado para criterio
    select max(pstcoddig) into lr_trab.atdprscod
     from dpampstdsn
      where dsnrefdat = l_dataref
       and cittipcod  = lr_trab.cittipcod
    whenever error stop

    if  lr_trab.atdprscod   is null then
       let lr_trab.atdprscod = 0
    end if

    open cbdbsa123019 using l_dataref, lr_trab.atdprscod, lr_trab.cittipcod

    foreach cbdbsa123019 into  lr_trab.atdprscod,
                               lr_trab.socvclcod,
                               lr_trab.cittipcod,
                               lr_trab.vcldsnper,
                               lr_trab.vclatdqtd


        if  l_flag = true and lr_trab.atdprscod <> l_pstant then

             ##calcula media ponderada e inclui registro na tabela dpampstdsn

             ## nunca se divide nada por zero
             if l_somaqtdsrv = 0 then
                let l_pstdsnper = 0
             else
                let l_pstdsnper = l_somaproduto/l_somaqtdsrv
             end if


             whenever error continue


             execute pbdbsa123007 using l_dataref, l_pstant,
                                        lr_trab.cittipcod, l_pstdsnper


             if sqlca.sqlcode <> 0 then
                 let m_curr = current
                 display "[", m_curr, "] Erro na inclusao do Valor Consolidado Criterio ",lr_trab.bnfcrtdes ," Prestador: ", l_pstant
             end if

             whenever error stop

             let l_somaproduto = 0
             let l_somaqtdsrv = 0
             let l_pstdsnper = 0

        end if


        let l_somaproduto = l_somaproduto + (lr_trab.vcldsnper * lr_trab.vclatdqtd)
        let l_somaqtdsrv = l_somaqtdsrv + lr_trab.vclatdqtd
        let l_pstant = lr_trab.atdprscod

        if l_flag = false then
           let l_flag = true
        end if


    end foreach

    let m_curr  = current
    display "[", m_curr , "] FIM CONSOLIDACAO CRITERIO ",lr_trab.bnfcrtdes

 end foreach

 let m_curr  = current
 display "[", m_curr , "] FIM CONSOLIDACAO CRITERIOS VIATURA PARA PRESTADOR"

end function


#-----------------------------------------------------------------------------#
function bdbsa123_avaliacao_premio_pst()
#-----------------------------------------------------------------------------#
define lr_trab         record
       datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,prtbnfgrpcod    like dpampstprm.prtbnfgrpcod    ## Codigo Grupo Bonifica��o
      ,pstapuobstxt    like dpampstprm.pstapuobstxt    ## Observacao
      ,efucmuflg       like dpampstprm.efucmuflg       ## Flag Comunicado Realizado
      ,pstprmvlr       like dpampstprm.pstprmvlr       ## Valor Premio
end record

define lr_ctd27g02 record
        ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg         char(100),
        fxavlr      like dpakbnfvlrfxa.fxavlr
 end record

 define lr_ctd27g04  record
        ret          smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg          char(100),
        credencia    char(1)
 end record

define l_dataref          date,
       l_flag             smallint,
       l_somaproduto      decimal(8,2),
       l_somaqtdsrv       integer,
       l_pstdsnper        like dpampstdsn.pstdsnper,
       l_ultpstbon        like datmservico.atdprscod,
       l_prtbnfgrpcod     like dpakbnfgrppar.prtbnfgrpcod,
       l_criterio         integer,
       l_vlrprmctr        like dpampstprm.pstprmvlr


 initialize lr_trab.*         to null
 initialize lr_ctd27g02.*     to null
 initialize lr_ctd27g04.*     to null

 let l_dataref         = null

 ###  Recebe data corrente para avaliacao dos criterios ###
 let lr_trab.datastr = today

 ###  Determina  as datas para avaliacao  ###
 let lr_trab.datastr = "16", lr_trab.datastr[3,10]
 let lr_trab.dataini = lr_trab.datastr
 let lr_trab.dataini = lr_trab.dataini - 1 units month
 let lr_trab.datafim = lr_trab.dataini + 1 units month - 1 units day

 ### Determina data referencia da an�lise de avaliacao ###
 let lr_trab.datastr = today
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr

  if not m_prepare then
    call bdbsa123_prepare()
 end if

 let m_curr  = current
 display "[", m_curr , "] INICIO AVALIACAO VALOR BONIFICACAO PRESTADOR"


 ## verifica ultimo prestador com valor apurado
 whenever error continue

 select max(pstcoddig) into l_ultpstbon
  from dpampstprm
   where vlrrefdat = l_dataref

 if l_ultpstbon is null then
    let l_ultpstbon = 0
 end if

 whenever error stop

 open cbdbsa123022 using l_dataref,
                         l_ultpstbon


 ## verifica prestadores que ainda n�o foram avaliados
 foreach cbdbsa123022 into lr_trab.atdprscod

    ## verifica Grupos De Servi�o que prestador dever� ser premiado
    open cbdbsa123021 using lr_trab.dataini,
                            lr_trab.datafim,
                            lr_trab.atdprscod,
                            lr_trab.dataini,
                            lr_trab.datafim,
                            lr_trab.atdprscod

    foreach cbdbsa123021 into l_prtbnfgrpcod

       let m_curr  = current
       display "[", m_curr , "] INICIO AVALIACAO VALOR BONIFICACAO PRESTADOR" , lr_trab.atdprscod

       let l_flag = false

       let m_curr  = current
       display "[", m_curr , "] INICIO AVALIACAO PREMIO BONIFICACAO GRUPO SERVICO ",l_prtbnfgrpcod

       # verifica se Grupo de Servi�o j� foi avaliado para Prestador
       open cbdbsa123020 using l_dataref, lr_trab.atdprscod, l_prtbnfgrpcod

       fetch cbdbsa123020

          if sqlca.sqlcode = notfound then

             let l_vlrprmctr = 0
             let lr_trab.pstprmvlr = 0

             ##identifica valor bonificacao
             for l_criterio = 1 to 7 ##Avaliar todos os criterios
                #Seguro socorrista e Seguro Viatura � consultado apenas na hora de atribuir valor ao servico
                if (l_criterio <> 1 and l_criterio <> 2) then

                   ## verifica se criterio existe para grupo de bonificacao analisado
                   call ctd27g04_val_crit_grp(l_prtbnfgrpcod, l_criterio)
                      returning lr_ctd27g04.*

                   ## Processa criterio de satisfacao para o grupo
                   if lr_ctd27g04.ret = 1 then

                      ## consulta valor consolidado criterio
                      open cbdbsa123023 using l_dataref, lr_trab.atdprscod, l_criterio

                      fetch cbdbsa123023 into l_pstdsnper
                         ## se existe criterio avaliado para prestador verifica valor
                         if sqlca.sqlcode = 0 then
                            ##Obtem valor da faixa do percentual de criterio
                            call ctd27g02_faixa_bonif(l_criterio,l_prtbnfgrpcod,l_pstdsnper)
                              returning lr_ctd27g02.*

                            let l_vlrprmctr =  lr_ctd27g02.fxavlr
                            let lr_trab.pstprmvlr  =  lr_trab.pstprmvlr + l_vlrprmctr

                         end if

                      close cbdbsa123023

                   end if
                end if
             end for


             let lr_trab.pstapuobstxt = 'PREMIO CALCULADO AUTOMATICAMENTE'
             let lr_trab.efucmuflg = 'N'

             #insere valor bonificacao para grupo de servi�o analisado
             execute pbdbsa123008 using l_dataref,
                                        lr_trab.atdprscod,
                                        l_prtbnfgrpcod,
                                        lr_trab.pstprmvlr,
                                        lr_trab.pstapuobstxt,
                                        lr_trab.efucmuflg

             if sqlca.sqlcode <> 0 then
                let m_curr = current
                display "[", m_curr, "] Erro na inclusao do Premio para Prestador: ", lr_trab.atdprscod
             end if
             continue foreach
          else
            let m_curr  = current
            display "[", m_curr , "] GRUPO SERVICO ",l_prtbnfgrpcod   , " JA AVALIADO PARA PRESTADOR ", lr_trab.atdprscod
            continue foreach
          end if

       close cbdbsa123020

    end foreach

 end foreach

 let m_curr  = current
 display "[", m_curr , "] FIM APURACAO VALOR BONIFICACAO PRESTADOR"

end function

function bdbsa123_comunica_bonificacao()

 define lr_trab         record
        bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod    ## Criterio
       ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod ## Grupo Bonificacao Servicos
       ,datastr         char(10)                        ## Data
       ,dataini         date                            ## Data Inicial
       ,datafim         date                            ## Data Final
       ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
       ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
       ,maides          like dpaksocor.maides           ## E_mail do prestador
       ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
       ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
       ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
       ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
       ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
       ,descricao       char(30)                        ## Descricao tipo veic
 end record

 define lr_relat        record
       bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,datafim         date                            ## Data Final
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,seguro          char(3)                         ## SIM / NAO
      ,ctrper          dec(5,2)                        ## Percentual Atingido para Criterio
      ,pesper          dec(5,2)                        ## Peso do percentual geral
      ,qtdrec          integer
      ,qtdsrv          integer
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,tot_bonif       dec(5,2)
      ,tot_max_bonif   dec(5,2)
      ,vlr_crt         dec(5,2)
      ,vlr_crt_max     dec(5,2)
      ,totqtdsrv       integer
      ,totqtdrec       integer
      ,medctrper       dec(5,2)                        ## Media Ponderada Percentual Atingido para Criterio
      ,totpesper       dec(8,2)                        ## Total Peso do percentual geral
 end record

 define lr_cty11g00 record
        erro        smallint
       ,mensagem    char(100)
       ,cpodes      like iddkdominio.cpodes
 end record

  define lr_ctd27g00  record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100),
         bnfcrtdes   like dpakprtbnfcrt.bnfcrtdes
 end record

 define lr_ctd27g02 record
        ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg         char(100),
        fxavlr      like dpakbnfvlrfxa.fxavlr
 end record

  define lr_ctd27g05  record
         ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
         msg         char(100),
         prtbnfgrpdes   like dpaksrvgrp.prtbnfgrpdes
  end record

 define l_dataref       date,
        l_pstprmvlr     like dpampstprm.pstprmvlr,
        l_fxavlr        dec(5,2), ## valor maximo criterio
        l_minper        like dpakbnfvlrfxa.minper,
        l_maxper        like dpakbnfvlrfxa.maxper,
        l_bnfcrtcod_ant like dpakprtbnfcrt.bnfcrtcod,
        l_socvcltip     like datkveiculo.socvcltip,
        l_totqtdrec     integer,
        l_vlrmxmbnf     dec(5,2),
        l_vlraux        char(10),
        l_chave         char(15),
        l_email         char(50),
        l_destinatarios char(500)

 ### RODOLFO MASSINI - INICIO
 #---> Variaves para:
 #     remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em maio/2013

 define lr_mail record
         rem     char(50)
        ,des     char(10000)
        ,ccp     char(10000)
        ,cco     char(10000)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
 end record

 define l_anexo   char (300)
       ,l_retorno smallint
       ,l_comando     char(200)

define lr_anexo_email record
       anexo1    char(300)
      ,anexo2    char(300)
      ,anexo3    char(300)
end record

 initialize lr_mail
           ,l_anexo
           ,l_retorno
           ,lr_anexo_email
 to null

 ### RODOLFO MASSINI - FIM


 initialize lr_trab.*  to null
 initialize lr_relat.* to null
 initialize lr_cty11g00.* to null
 initialize lr_ctd27g00.* to null
 initialize lr_ctd27g02.* to null

 let l_dataref = null
 let l_pstprmvlr = 0
 let l_fxavlr = 0
 let l_minper = 0
 let l_maxper = 0
 let l_bnfcrtcod_ant  = 0

 ### Determina data referencia da an�lise de desempenho ###
 let lr_trab.datastr = today
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let l_dataref  = lr_trab.datastr

 if not m_prepare then
    call bdbsa123_prepare()
 end if

 open cbdbsa123032
 whenever error continue
 fetch cbdbsa123032 into m_remetente
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let m_remetente = null
    else
       let m_erro = "Problemas no acesso tabela igbmparam,sql = ", sqlca.sqlcode
       call errorlog(m_erro)
        let m_curr  = current
        display "[", m_curr ,"] bdbsa123/igbmparam/", m_erro clipped
       exit program(1)
    end if
 end if

 if m_remetente is null then
    let m_remetente = "porto.socorro@porto-seguro.com.br"
 end if

 close cbdbsa123032

 #consulta prestadores que ainda n�o foram comunicados
 open cbdbsa123024 using l_dataref

 foreach cbdbsa123024 into lr_trab.atdprscod, lr_trab.prtbnfgrpcod, l_pstprmvlr


    let m_nomearq1 = m_patharq clipped, "/RDB",
                     lr_trab.prtbnfgrpcod using "&&&","-",
                     lr_trab.atdprscod using "<<<<<<", "_resumo.doc"

    let m_curr = current
    display "[", m_curr, "] Gerando email para prestador: ", lr_trab.atdprscod

    let m_arq1 = "RDB", lr_trab.prtbnfgrpcod using "&&&","-",
                         lr_trab.atdprscod using "<<<<<<", "_detalhes.doc"
    let m_nomearq2 = m_patharq clipped, "/",m_arq1


    ##verifica e-mail prestador
    open cbdbsa123037 using lr_trab.atdprscod

    fetch cbdbsa123037 into m_destinatario

    close cbdbsa123037


    start report bdbsa123_resumo to m_nomearq1
    start report bdbsa123_detalhes to m_nomearq2


    let m_vlrmxmbnf = 0

    #consulta todos os criterios avaliados para grupo de servico
    open cbdbsa123033 using lr_trab.prtbnfgrpcod

    foreach cbdbsa123033 into lr_trab.bnfcrtcod

       initialize lr_relat.* to null
       let lr_relat.bnfcrtcod = 0
       let lr_relat.ctrper = 0
       let lr_relat.pesper = 0
       let lr_relat.totpesper = 0
       let lr_relat.qtdsrv   = 0
       let lr_relat.totqtdsrv   = 0
       let lr_relat.totqtdrec = 0
       let lr_relat.qtdrec = 0
       let lr_relat.tot_max_bonif = 0
       let lr_relat.tot_bonif = 0


     #consultando a faixa otima de bonificacao para grupo e criterio
     open cbdbsa123025 using lr_trab.prtbnfgrpcod, lr_trab.bnfcrtcod

       fetch cbdbsa123025 into  l_minper,
                                l_maxper,
                                l_fxavlr

          ## so busca o primeiro registro
          if sqlca.sqlcode <> 0 then
             let l_minper = 0
             let l_maxper = 0
             let l_fxavlr = 0
          end if

       close cbdbsa123025

       ## valor maximo que bonificacao prestador pode atingir
       let m_vlrmxmbnf = m_vlrmxmbnf + l_fxavlr

       ## verifica o valor do percentual atingido pelo Prestador
       open cbdbsa123023 using l_dataref, lr_trab.atdprscod, lr_trab.bnfcrtcod

          fetch cbdbsa123023 into lr_relat.medctrper

       close cbdbsa123023


       ## DATA que premio sera pago"
       let lr_relat.datafim = l_dataref  + 1 units month
       call c24geral_mes(lr_relat.datafim)
       returning lr_relat.mes_extenso

       ## obter descricao criterio
       call ctd27g00_obter_criterios(1,lr_trab.bnfcrtcod)
               returning lr_ctd27g00.*

       let lr_relat.bnfcrtdes = lr_ctd27g00.bnfcrtdes
       let lr_relat.bnfcrtcod = lr_trab.bnfcrtcod

       ## obter descricao grupo bonificacao
       call ctd27g05_obter_desc_grp(1,lr_trab.prtbnfgrpcod)
            returning lr_ctd27g05.*

       let lr_relat.prtbnfgrpcod = lr_trab.prtbnfgrpcod
       let lr_relat.prtbnfgrpdes = lr_ctd27g05.prtbnfgrpdes

       ## Seguro Vida
       if lr_trab.bnfcrtcod = 1 then
          #Seguro Vida
          #consulta seguro socorristas prestador
          open cbdbsa123026 using l_dataref, lr_trab.atdprscod

          foreach cbdbsa123026 into lr_relat.srrcoddig,
                                    lr_relat.srrnom,
                                    lr_relat.seguro

             if lr_relat.seguro = 'S' then
                let lr_relat.seguro = 'SIM'
             else
                let lr_relat.seguro = 'NAO'

                let lr_relat.msg = "- O socorrista ", lr_relat.srrnom clipped,
                           " esta sem seguro. Por esse motivo, servicos",
                           " atendidos pelo Socorrista n�o ser�o bonificados."
                output to report bdbsa123_resumo(1, lr_relat.*, m_arq1)
             end if
             output to report bdbsa123_detalhes(lr_trab.bnfcrtcod, lr_relat.*)
          end foreach
       else
          if lr_trab.bnfcrtcod = 2 then
             #Seguro Viatura
             #consulta seguro socorristas prestador
             open cbdbsa123027 using l_dataref, lr_trab.atdprscod

             foreach cbdbsa123027 into lr_relat.socvclcod, l_socvcltip, lr_relat.atdvclsgl, lr_relat.seguro

                initialize lr_cty11g00.* to  null
                call cty11g00_iddkdominio("socvcltip", l_socvcltip)
                returning lr_cty11g00.*

                let lr_relat.descricao = lr_cty11g00.cpodes

                if lr_relat.seguro = 'S' then
                   let lr_relat.seguro = 'SIM'
                else
                   let lr_relat.seguro = 'NAO'

                   let lr_relat.msg = "- A viatura ", lr_relat.atdvclsgl clipped,
                              " esta sem seguro. Por esse motivo os servicos",
                              " realizados por viatura nao serao bonificados. "
                   output to report bdbsa123_resumo(1, lr_relat.*, m_arq1)
                end if
                output to report bdbsa123_detalhes(lr_trab.bnfcrtcod, lr_relat.*)
             end foreach
          else
            ## Criterios viatura
             if lr_trab.bnfcrtcod = 3 or lr_trab.bnfcrtcod = 4 then

                ## verifica qtd total atendimentos prestador
                open cbdbsa123030 using l_dataref,
                                        lr_trab.atdprscod,
                                        lr_trab.bnfcrtcod

                fetch cbdbsa123030 into lr_relat.totqtdsrv

                close cbdbsa123030

                if lr_relat.totqtdsrv is null then
                   let lr_relat.totqtdsrv = 0
                end if

                ## verifica criterio de cada veiculo do prestador
                open cbdbsa123028 using l_dataref,
                                        lr_trab.atdprscod,
                                        lr_trab.bnfcrtcod

                foreach cbdbsa123028 into lr_relat.socvclcod,
                                          l_socvcltip,
                                          lr_relat.atdvclsgl,
                                          lr_relat.ctrper,
                                          lr_relat.qtdsrv


                   ## verifica descricao veiculo
                   initialize lr_cty11g00.* to  null
                   call cty11g00_iddkdominio("socvcltip", l_socvcltip)
                   returning lr_cty11g00.*

                   let lr_relat.descricao = lr_cty11g00.cpodes

                   ##calcula peso do criterio desta viatura comparado as demais
                   if  lr_relat.qtdsrv = 0 or lr_relat.totqtdsrv  = 0 then
                      let lr_relat.pesper = 0
                   else
                      let lr_relat.pesper = (lr_relat.qtdsrv/lr_relat.totqtdsrv) * 100
                   end if

                   # Porcentagem total do peso
                   if  lr_relat.totqtdsrv then
                      let lr_relat.totpesper = 100
                   else
                      let lr_relat.totpesper = 0
                   end if


                   ##verifica se prestador nao atingiu valor maximo de bonificacao para criterio
                   if lr_relat.medctrper < l_minper or lr_relat.medctrper > l_maxper then
                      ## verifica se criterio esta fora da faixa otima para enviar mensagem de melhoria
                      if lr_relat.ctrper < l_minper or lr_relat.ctrper > l_maxper then

                         let lr_relat.msg = "- Aumente a ", lr_relat.bnfcrtdes clipped ," da viatura ",
                                      lr_relat.atdvclsgl,". Se tivesse atingido ",
                                      l_minper using "<<&.&&",
                                      "% voce teria recebido R$ ",
                                      l_fxavlr using "<<<,<<&.&&", " a mais por servico."

                         output to report bdbsa123_resumo(1, lr_relat.*, m_arq1)
                      end if
                   end if

                   output to report bdbsa123_detalhes(lr_trab.bnfcrtcod, lr_relat.*)
                end foreach

             else
                ## criterios socorrista
                ## criterios relacionados ao socorrista
                #consulta total de servicos avaliados por criterio
                open cbdbsa123031 using l_dataref,
                                        lr_trab.atdprscod,
                                        lr_trab.bnfcrtcod

                fetch cbdbsa123031 into lr_relat.totqtdsrv

                close cbdbsa123031

                open cbdbsa123029 using l_dataref,
                                        lr_trab.atdprscod,
                                        lr_trab.bnfcrtcod

                foreach cbdbsa123029 into lr_relat.srrcoddig,
                                          lr_relat.srrnom,
                                          lr_relat.ctrper,
                                          lr_relat.qtdsrv


                   ## calcula peso do criterio comparado aos demais socorristas
                   if lr_relat.qtdsrv = 0 or lr_relat.totqtdsrv  = 0 then
                      let lr_relat.pesper = 0
                   else
                      let lr_relat.pesper = (lr_relat.qtdsrv/lr_relat.totqtdsrv) * 100
                   end if

                   # Porcentagem total do peso
                   if  lr_relat.totqtdsrv then
                      let lr_relat.totpesper = 100
                   else
                      let lr_relat.totpesper = 0
                   end if

                   ## quando o criterio for Satisfacao cliente calcula a qtd de reclamacoes que socorrista teve
                   if lr_trab.bnfcrtcod = 5 then
                      let lr_relat.qtdrec = (lr_relat.ctrper * lr_relat.qtdsrv)/100 using "&&&"
                      let lr_relat.totqtdrec = lr_relat.totqtdrec + lr_relat.qtdrec using "&&&"
                   end if


                   ##verifica se prestador nao atingiu valor maximo de bonificacao para criterio
                   if lr_relat.medctrper < l_minper or lr_relat.medctrper > l_maxper then
                      ## verifica se criterio esta fora da faixa otima para enviar mensagem de melhoria
                      if lr_relat.ctrper < l_minper or lr_relat.ctrper > l_maxper then
                         let lr_relat.msg = "Melhore o criterio ",lr_relat.bnfcrtdes clipped , " do socorrista ", lr_relat.srrnom clipped, "."

                         output to report bdbsa123_resumo(1, lr_relat.*, m_arq1)
                      end if
                   end if

                   output to report bdbsa123_detalhes(lr_trab.bnfcrtcod, lr_relat.*)

                end foreach
             end if
          end if
       end if

       ## grava valor de cada criterio para prestador
       ##Obtem valor da faixa que criterio consolidado do prestador atingiu
       call ctd27g02_faixa_bonif(lr_relat.bnfcrtcod,lr_trab.prtbnfgrpcod,lr_relat.medctrper)
            returning lr_ctd27g02.*



       let lr_relat.tot_max_bonif = m_vlrmxmbnf #valor maximo que prestador pode ganhar por bonificacao
       let lr_relat.vlr_crt = lr_ctd27g02.fxavlr #valor real atingido por criterio
       let lr_relat.vlr_crt_max = l_fxavlr  #valor maximo que pode ser pago por criterio
       let lr_relat.tot_bonif = l_pstprmvlr # valor real do premio prestador



       #Seguro nao possui Valor ele somente desclassifica
       if lr_trab.bnfcrtcod <> 1 and lr_trab.bnfcrtcod <> 2 then
          if lr_relat.vlr_crt_max <> 0 then
             output to report bdbsa123_resumo(0, lr_relat.*, m_arq1)
          end if
       end if

    end foreach


    ## finaliza relatorio
    finish report bdbsa123_resumo
    finish report bdbsa123_detalhes

    ## envia e-mail para prestador

    let m_assunto = "Bonificacao Adicional por Desempenho - ",
                         lr_trab.atdprscod using "<<<<<<", " em ",
                         l_dataref using "mm/yyyy"


    let l_chave = "PSOPRMBNFEMAIL"
    let l_email = null
    let l_destinatarios = null

    ## verifica destinatarios na area de negocio
    whenever error continue
    declare pbdbsa123036 cursor for
       select cpodes
         from iddkdominio
        where cponom = l_chave
        order by cpocod

    foreach pbdbsa123036 into l_email

            if l_destinatarios is null then
               let l_destinatarios = l_email
            else
               let l_destinatarios = l_destinatarios clipped, ",", l_email
            end if
    end foreach
    whenever error stop

    if l_destinatarios is null then
       let l_destinatarios = "jorge.modena@portoseguro.com.br"
    end if




   ### RODOLFO MASSINI - INICIO
   #---> remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013

   #let m_comando = ' cat "', m_nomearq1 clipped, '" | send_email.sh ',
   #                ' -sys  TESTE_INFO',
   #                ' -r  ', m_remetente clipped,
   #                ' -a  ', m_destinatario clipped,
   #                ' -cc ', l_destinatarios clipped,
   #                ' -s "', m_assunto clipped, '" ',
   #                ' -f  ', m_nomearq2 clipped

   #run m_comando returning m_retorno

	 initialize lr_anexo_email.* to null

   let lr_mail.ass = m_assunto clipped
   let lr_mail.idr = "TESTE_INFO"
   let lr_mail.rem = m_remetente clipped
   let lr_mail.des = m_destinatario clipped
   let lr_mail.ccp = l_destinatarios clipped
   let lr_mail.tip = "text"
   #let l_anexo = m_nomearq2 clipped

   let lr_anexo_email.anexo1 = m_nomearq1 clipped
   let lr_anexo_email.anexo2 = m_nomearq2 clipped

   let m_mensagem = "Prezado Prestador,", ASCII(13), ASCII(13),
                     "Em ", lr_relat.mes_extenso clipped, "/",
                     lr_relat.datafim using "yyyy",
                     ", sua bonificacao adicional por desempenho para cada servico de ",
                     lr_relat.prtbnfgrpdes clipped, " sera de RS ",
                     lr_relat.tot_bonif using "<<<,<<&.&&",
                     ASCII(13), ASCII(13), ASCII(13),
                     "COMO MELHORAR SUA PREMIACAO ?",
                     ASCII(13), ASCII(13), ASCII(13),
                     'Leia o arquivo resumo.doc em anexo;',
                     ASCII(13),
                     'Leia o arquivo detalhes.doc anexo;',
                     ASCII(13), ASCII(13),
                     "EM CASO DE DUVIDAS, ENTRE EM CONTATO COM ",
                     "O ANALISTA DE RELACIONAMENTO DA SUA REGIAO.", ASCII(13), ASCII(13),
                     "Atenciosamente,", ASCII(13), "PORTO SOCORRO - V1.7",
                     ASCII(13), ASCII(13)

   let lr_mail.msg = m_mensagem

    call ctx22g00_envia_email_anexos(lr_mail.*, lr_anexo_email.*)
    returning l_retorno

   ### RODOLFO MASSINI - FIM

    if m_retorno <> 0 then
       let m_erro = "Problemas ao enviar relatorio(BDBSA123)"
       call errorlog(m_erro)
       let m_curr = current
       display "[", m_curr, "] bdbsa123 / ", m_erro clipped
    else
       execute cbdbsa123038 using l_dataref, lr_trab.atdprscod

       if sqlca.sqlcode <> 0 then
          let m_curr = current
          display "[", m_curr, "] Erro na alteracao da flag de envio de e-mail Prestador: ", lr_trab.atdprscod
       end if
    end if

 end foreach

 end function

#-----------------------------------------------------------------------------#
function bdbsa123_limpa_registros()
#-----------------------------------------------------------------------------#

 define l_sql      char(3000)
 define l_dataref  date
 define l_datastr  char(10)

 let l_sql = null
 let l_dataref = null
 let l_datastr = null


 ### Determina data referencia da an�lise de desempenho ###
 let l_datastr = today
 let l_datastr = "01", l_datastr[3,10]
 let l_dataref = l_datastr
 let l_dataref = l_dataref - 6 units month

 display "DATA REFERENCIA LIMPEZA REGISTROS ",l_dataref

 whenever error continue

  ##Limpa registros de desempenho Socorrista com mais de 6 meses
  let l_sql = " delete from datmsrrdsn ",
            " where dsnrefdat = ? "

  prepare pbdbsa123034  from l_sql

  execute pbdbsa123034 using l_dataref


  ##Limpa registros de desempenho Veiculo com mais de 6 meses
  let l_sql = " delete from datmvcldsn",
            " where dsnrefdat = ?"

  prepare pbdbsa123035  from l_sql

  execute pbdbsa123035 using l_dataref

  whenever error stop

end function


report bdbsa123_detalhes(l_ordem,lr_relat)

define l_ordem         smallint

define lr_relat        record
       bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,datafim         date                            ## Data Final
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,seguro          char(3)                         ## SIM / NAO
      ,ctrper          dec(5,2)                        ## Percentual Atingido para Criterio
      ,pesper          dec(5,2)                        ## Peso do percentual geral
      ,qtdrec          integer
      ,qtdsrv          integer
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,tot_bonif       dec(5,2)
      ,tot_max_bonif   dec(5,2)
      ,vlr_crt         dec(5,2)
      ,vlr_crt_max     dec(5,2)
      ,totqtdsrv       integer
      ,totqtdrec       integer
      ,medctrper       dec(5,2)                        ## Media Ponderada Percentual Atingido para Criterio
      ,totpesper       dec(8,2)                        ## Total Peso do percentual geral
 end record

   output
      left   margin  000
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  066

   order by l_ordem

   format
      page header
         skip 2 lines

      first page header

            skip 1 lines
            print column 01, "DETALHAMENTO DA BONIFICACAO DE ",
                             lr_relat.mes_extenso clipped, "/",
                             lr_relat.datafim using "yyyy"

      before group of l_ordem

         if l_ordem = 1 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "SEGURO DE VIDA DOS SOCORRISTAS"
            print column 01, "SOCORRISTA",
                  column 50, "SEGURO",
                  column 60, "BONIFICAR"
         end if

         if l_ordem = 2 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "SEGURO DAS VIATURAS"
            print column 01, "VIATURA",
                  column 50, "SEGURO",
                  column 60, "BONIFICAR"
         end if

         if l_ordem = 3 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "DISPONIBILIDADE DAS VIATURAS MANHA"
            print column 01, "VIATURA",
                  column 25, "|| %MANHA",
                  column 35, "|| %PESO",
                  column 43, "|| QTD SRV"

         end if

         if l_ordem = 4 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "DISPONIBILIDADE DAS VIATURAS TARDE"
            print column 01, "VIATURA",
                  column 25, "|| %TARDE",
                  column 35, "|| %PESO",
                  column 43, "|| QTD SRV"

         end if

         if l_ordem = 5 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "SATISFACAO DOS CLIENTES"
            print column 01, "SOCORRISTA",
                  column 18, "|| QTD",
                  column 30, "|| INDICE",
                  column 45, "|| %PESO",
                  column 55, "|| QTD "
            print column 18, "|| RECL",
                  column 30, "|| EM MIL",
                  column 45, "|| ",
                  column 55, "||ATENDIMENTO"
            print column 18, "|| 90 dias",
                  column 30, "|| 90 dias",
                  column 45, "|| ",
                  column 55, "|| "



         end if

         if l_ordem = 6 then
            skip 1 lines
            print column 01, "========================================================================="
            print column 20, "PONTUALIDADE DOS SOCORRISTAS"
            print column 01, "SOCORRISTA",
                  column 21, "|| % PONTUALIDADE",
                  column 46, "|| % PESO",
                  column 61, "|| QTD SRV "
         end if



         #if l_ordem = 7 then
         #   skip 1 lines
         #   print column 01, "========================================================================="
         #   print column 20, "RESOLUBILIDADE DOS SOCORRISTAS"
         #   print column 01, "SOCORRISTA",
         #         column 18, "QTD",
         #         column 30, "INDICE",
         #         column 43, "FAIXA",
         #         column 55, "VLR APURADO"
         #   print column 15, "RETORNOS",
         #         column 40, "BONIFICACAO"
         #end if



      on every row

         if l_ordem = 1 then
            print column 01, lr_relat.srrnom clipped,
                  column 50, lr_relat.seguro,
                  column 60, lr_relat.seguro
         end if

         if l_ordem = 2 then
            print column 01, lr_relat.atdvclsgl clipped,"-",lr_relat.descricao,
                  column 50, lr_relat.seguro,
                  column 60, lr_relat.seguro
         end if

         if l_ordem = 3 then

            print column 01, lr_relat.atdvclsgl clipped, "-",
                             lr_relat.descricao[1,15],
                  column 25, "|| ", lr_relat.ctrper using "##&.&&",
                  column 35, "|| ", lr_relat.pesper using "##&.&&",
                  column 42, "|| ", lr_relat.qtdsrv using "##&.&&"

         end if

         if l_ordem = 4 then

            print column 01, lr_relat.atdvclsgl clipped, "-",
                             lr_relat.descricao[1,15],
                  column 25, "|| ", lr_relat.ctrper using "##&.&&",
                  column 35, "|| ", lr_relat.pesper using "##&.&&",
                  column 42, "|| ", lr_relat.qtdsrv using "##&.&&"


         end if

         if l_ordem = 5 then
            print column 01, lr_relat.srrnom[1,13],
                  column 18, "|| ",lr_relat.qtdrec using "###&",
                  column 30, "|| ",(lr_relat.ctrper*10) using "##&.&&",
                  column 45, "|| ",lr_relat.pesper using "##&.&&",
                  column 55, "|| ",lr_relat.qtdsrv using "##&.&&"
         end if

         if l_ordem = 6 then
            print column 01, lr_relat.srrnom[1,20] clipped,
                  column 21, "|| ",lr_relat.ctrper using "##&.&&",
                  column 46, "|| ", lr_relat.pesper using "##&.&&",
                  column 61, "|| ", lr_relat.qtdsrv using "##&.&&"
         end if

         #if l_ordem = 7 then
         #   print column 01, lr_relat.srrnom[1,13],
         #         column 15, lr_relat.numret_res using "###&",
         #         column 30, lr_relat.percresolub using "##&.&&",
         #         column 40, lr_relat.vlr_resolub using "###,##&.&&",
         #         column 57, lr_relat.tot_resolub using "###,##&.&&"
         #end if

      after group of l_ordem

      if l_ordem = 3 then
            skip 2 lines
            print column 01, "TOTAL APURADO",
                  column 25, "|| ", lr_relat.medctrper using "##&.&&",
                  column 35, "|| ", lr_relat.totpesper using "##&.&&",
                  column 42, "|| ", lr_relat.totqtdsrv using "####&.&&"

         end if

         if l_ordem = 4 then
            skip 2 lines
            print column 01, "TOTAL APURADO",
                  column 25, "|| ", lr_relat.medctrper using "##&.&&",
                  column 35, "|| ", lr_relat.totpesper using "##&.&&",
                  column 42, "|| ", lr_relat.totqtdsrv using "####&.&&"


         end if

         if l_ordem = 5 then
            skip 2 lines
            print column 01, "TOTAL APURADO",
                  column 18, "|| ",lr_relat.totqtdrec using "###&",
                  column 30, "|| ",(lr_relat.medctrper*10) using "##&.&&",
                  column 45, "|| ",lr_relat.totpesper using "##&.&&",
                  column 55, "|| ",lr_relat.totqtdsrv using "####&.&&"
         end if

         if l_ordem = 6 then
            skip 2 lines
            print column 01, "TOTAL APURADO",
                  column 21, "|| ", lr_relat.medctrper using "##&.&&",
                  column 46, "|| ", lr_relat.totpesper using "##&.&&",
                  column 61, "|| ", lr_relat.totqtdsrv using "####&.&&"
         end if





end report

#------------------------------------------------#
 report bdbsa123_resumo(l_ordem, lr_relat, l_arq1)
#------------------------------------------------#

define l_ordem         smallint

define lr_relat        record
       bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,datafim         date                            ## Data Final
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,seguro          char(3)                         ## SIM / NAO
      ,ctrper          dec(5,2)                        ## Percentual Atingido para Criterio
      ,pesper          dec(5,2)                        ## Peso do percentual geral
      ,qtdrec          integer
      ,qtdsrv          integer
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,tot_bonif       dec(5,2)
      ,tot_max_bonif   dec(5,2)
      ,vlr_crt         dec(5,2)
      ,vlr_crt_max     dec(5,2)
      ,totqtdsrv       integer
      ,totqtdrec       integer
      ,medctrper       dec(5,2)                        ## Media Ponderada Percentual Atingido para Criterio
      ,totpesper       dec(8,2)                        ## Total Peso do percentual geral
 end record

define l_arq1 char(100)


   output
      left   margin  000
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  066

   order by l_ordem, lr_relat.bnfcrtcod

   format
      page header
         skip 2 lines

      first page header

            print column 01, "Prezado Prestador"

            if lr_relat.tot_bonif <> m_vlrmxmbnf then
               skip 2 lines
               print column 01,
                     "Em ", lr_relat.mes_extenso clipped, "/",
                      lr_relat.datafim using "yyyy",
                      ", sua bonificacao adicional por desempenho para cada servico de ",
                      lr_relat.prtbnfgrpdes clipped, " sera de R$ ",
                      lr_relat.tot_bonif using "<<<,<<&.&&",
                      ", mas poderia ter sido R$ ",
                      m_vlrmxmbnf using "<<<,<<&.&&" ,"."
            else
               skip 2 lines
               print column 01,
                     "Em ", lr_relat.mes_extenso clipped, "/",
                      lr_relat.datafim using "yyyy",
                      ", sua bonificacao adicional por desempenho de ",
                      lr_relat.prtbnfgrpdes clipped, " sera de R$ ",
                      lr_relat.tot_bonif using "<<<,<<&.&&","."
            end if


      before group of l_ordem

         if l_ordem = 0 then
            skip 2 lines
            print column 15, "TOTAL RECEBIDO POR CRITERIO"
            print column 01, "=============================================================="
            skip 1 lines
            print column 01, "CRITERIO",
                  column 30, "VALOR RECEBIDO",
                  column 50, "VALOR MAXIMO"
            skip 1 lines
         end if

         if l_ordem = 1 then
            print column 01, "=============================================================="
            skip 2 lines
            print column 01, "COMO MELHORAR SUA PREMIACAO ? "
            skip 1 lines
         end if

      on every row
         if l_ordem = 0 then
            print column 01, lr_relat.bnfcrtdes clipped,
                  column 30, lr_relat.vlr_crt using "###,##&.&&",
                  column 50, lr_relat.vlr_crt_max using "###,##&.&&"
         end if

         if l_ordem = 1 then
            print column 01, lr_relat.msg clipped
            skip 1 line
         end if

      on last row

            skip 1 line

            print column 01, "ATENCAO !!!"

            skip 2 line
            print column 01, '- Leia o arquivo "', l_arq1 clipped, '" anexo;'

            skip 2 line

            print column 01, "EM CASO DE DUVIDAS, ENTRE EM CONTATO COM ",
                             "O ANALISTA DE RELACIONAMENTO DA SUA REGIAO."
            skip 2 line
            print column 01, "Atenciosamente"
            print column 01, "PORTO SOCORRO - V1.7"
            skip 2 line

end report
