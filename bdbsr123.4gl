#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : bdbsr123                                                       #
# Programa   : bdbsr123 - Relatorio de bonificacao por desempenho             #
#-----------------------------------------------------------------------------#
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 229784                                                     #
#                                                                             #
# Desenvolvedor  : Ligia Mattge - copia do bdbsr110.4gl                       #
# DATA           : 01/2009                                                    #
#.............................................................................#
# Data        Autor       Alteracao                                           #
# ----------  ---------   ----------------------------------------------------#
# 22/04/2009  Burini      Alterações no processo de Bonificação.              #
# 26/07/2010  Fabio Costa Inclusao do critério Telemetria, alteracao criterio #
#                         pontualidade, alteracao consulta SAC, melhoria con- #
#                         sulta seguro VIDA/veiculo                           #
# 22/07/2012  Burini      Ajustes para schedulagem.                           #
# 26/05/2014  Rodolfo -   Alteracao na forma de envio de e-mail (SENDMAIL     #
#             Massini     para FIGRC009)                                      #
#             TESTE NOVO CPVCS                                                #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

database porto

globals
    define
           w_hostname        char(03)
end globals

define m_valor       decimal(12,2),
       m_texto       char(2000),
       m_comando     char(1500),
       m_pathlog     char(200),
       m_pathrel     char(200),
       m_patharq     char(200),
       m_nomearq1    char(200),
       m_nomearq2    char(200),
       m_nomearq3    char(200),
       m_remetente   char(200),
       m_assunto     char(200),
       m_retorno     smallint,
       m_erro        char(200),
       m_arq1        char(100),
       m_arq2        char(100),
       m_auto_re     char(004),
       m_ultpstbon   like datmservico.atdprscod

define mr_relat        record
       bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,tot_bonif       dec(12,2)
      ,tot_max_bonif   dec(12,2)
      ,vlr_crt         dec(12,2)
      ,vlr_crt_max     dec(12,2)
      ,datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          char(100) #like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,cgccpfnum       like datksrr.cgccpfnum          ## CPF do Socorrista
      ,cgccpfdig       like datksrr.cgccpfdig          ## Dig. CPF do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          smallint                        ## SIM / NAO
      ,seg_vida        char(3)                         ## SIM / NAO
      ,bon_vida        char(20)                        ## SIM / NAO
      ,seg_vcl         char(3)                         ## SIM / NAO
      ,bon_vcl         char(3)                         ## SIM / NAO
      ,disp_manha      char(3)                         ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,disp_tarde      char(3)                         ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint                        ## SIM / NAO
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor bonif total
      ,asitipcod       like datmservico.asitipcod      ## Cod assistencia srv
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,segvida_c       char(1)
      ,segvcl_c        char(1)
      ,satisf_c        char(1)
      ,dispm_c         char(1)
      ,dispt_c         char(1)
      ,pontual_c       char(1)
      ,resolub_c       char(1)
end record

define m_curr          datetime year to second

define m_sttbnf        char(10)

main

  call bdbsr123_envia_sms(1)

  let m_curr = current

  call fun_dba_abre_banco("CT24HS")

  # -> CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read

  let m_pathlog = f_path("DBS", "LOG")

  if m_pathlog is null then
     let m_pathlog = "."
  end if

  let m_patharq = m_pathlog clipped, "/bdbsr123.log"
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
  let m_sttbnf = null

  ## verifica se bonificacao esta ativa para execucao
  whenever error continue
         select grlinf
           into m_sttbnf
           from datkgeral
          where grlchv = 'PSOBONIFICACAO1'
  whenever error stop
  display "SITUACAO DA BONIFICACAO", m_sttbnf
  let m_sttbnf = m_sttbnf clipped

  if m_sttbnf = "ATIVO" then

     call bdbsr123_cria_tab()

     let m_auto_re = arg_val(1)

     call bdbsr123_verifica_executado()
     call bdbsr123()

     call bdbsr123_arq_resumos(m_pathlog, m_patharq)

     call bdbsr123_drop_tabela()
  else
     let m_curr = current
     display "[", m_curr , "] BONIFICACAO NAO ESTA ATIVA - PROGRAMA BDBSR123.4GC NAO SERA EXECUTADO"
     call bdbsr123_envia_sms(2)
  end if

end main

#---------------------------#
 function bdbsr123_prepare()
#---------------------------#

define l_sql      char(3000),
       l_condicao char(100)

if m_auto_re = "RE" then
   let l_condicao = " and datmservico.atdsrvorg = 9 "
else
   let l_condicao = " and datmservico.atdsrvorg in (1,2,4,5,6,7,17) "
end if

###  CURSOR PRINCIPAL ###
let l_sql = " select  datmsrvacp.pstcoddig, "
            ,"        dpaksocor.nomgrr ,     "
            ,"        dpaksocor.maides ,     "
            ,"        datmsrvacp.srrcoddig,  "
            ,"        datksrr.srrnom,     "
            ,"        datksrr.cgccpfnum,     "
            ,"        datksrr.cgccpfdig,     "
            ,"        datkveiculo.socvclcod, "
            ,"        datkveiculo.socvcltip, "
            ,"        datkveiculo.atdvclsgl, "
            ,"        datkveiculo.mdtcod,    "
            ,"        datmsrvacp.atdetpdat,  "
            ,"        datmservico.atdsrvorg, "
            ,"        datmservico.atdsrvnum, "
            ,"        datmservico.atdsrvano, "
            ,"        datmservico.asitipcod  "
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
            ,"   and datmservico.ciaempcod = 1 "                              # PORTO SEGURO
	    ,"   order by datmsrvacp.pstcoddig, datmsrvacp.srrcoddig, "
            ,"            datkveiculo.atdvclsgl, datmsrvacp.atdetpdat, "
            ,"            datmservico.atdsrvano, datmservico.atdsrvano,"
            ,"            datmservico.atdsrvnum "

prepare pbdbsr123001  from l_sql
declare cbdbsr123001  cursor for pbdbsr123001

let m_curr = current
display "[", m_curr, "] SQl = ", l_sql

###  Recupera o email do remetente (Porto Socorro) ###
let l_sql = " select relpamtxt "
	    ,"  from igbmparam "
	    ," where relsgl = 'BDBSR110' "
	    ,"   and relpamseq = 1 "
	    ,"   and relpamtip = 1 "

prepare pbdbsr123002  from l_sql
declare cbdbsr123002  cursor for pbdbsr123002

###  Carrega os valores das bonificacoes  ###
let l_sql = " select count(*) "
	    ,"  from work:temp_bonif "
	    ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
	    ,"   and srrcoddig = ? "

prepare pbdbsr123005  from l_sql
declare cbdbsr123005  cursor for pbdbsr123005

let l_sql = " select count(*) "
	    ,"  from work:temp_bonif "
	    ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
	    ,"   and srrcoddig = ? "
	    ,"   and pontual = 1 "

prepare pbdbsr123006  from l_sql
declare cbdbsr123006  cursor for pbdbsr123006

let l_sql = " select sum(vlr_pontual+tot_disp_m+tot_disp_t+vlr_resolub) "
	    ,"  from work:temp_bonif "
	    ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
	    ,"   and seg_vida = ? and seg_vcl = ? "
	    ,"   and (pontual = 1 or "
            ,"        disp_manha = 1 or disp_tarde = 1 or "
            ,"        resolub = 1)"

prepare pbdbsr123013  from l_sql
declare cbdbsr123013  cursor for pbdbsr123013

let l_sql = " select sum(tot_max_pontual+vlr_minper_m+vlr_minper_t+vlr_resolub) "
	    ,"  from work:temp_bonif "
	    ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
            ,"   and (pontual    in(0,1) or disp_manha in(0,1) or "
            ,"        disp_tarde in(0,1) or satisf     in(0,1) or "
            ,"        resolub    in(0,1))"

prepare pbdbsr123014  from l_sql
declare cbdbsr123014  cursor for pbdbsr123014

let l_sql = " select b.bnfcrtcod, b.crttip ",
              "   from dpakprtbnfgrpcrt a, dpakprtbnfcrt b ",
              "  where a.prtbnfgrpcod = ? ",
              "    and a.bnfcrtcod = b.bnfcrtcod ",
              "    order by 1 "

prepare pbdbsr123023  from l_sql
declare cbdbsr123023  cursor for pbdbsr123023

##Obter o total maximo de satisfacao por socorrista
let l_sql = " select srrnom, sum(vlr_max_satisf) "
            ," from work:temp_bonif "
            ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
            ,"   and satisf in(0,1) "
            ," group by 1 "

prepare pbdbsr123024  from l_sql
declare cbdbsr123024  cursor for pbdbsr123024

##Obter o total de satisfacao por socorrista
let l_sql = " select srrnom, sum(vlr_satisf) "
            ," from work:temp_bonif "
            ," where atdprscod = ? "
            ," and prtbnfgrpcod = ? "
            ," and seg_vida = ? and seg_vcl = ? "
            ," and satisf = 1 "
            ," group by 1 "

prepare pbdbsr123025  from l_sql
declare cbdbsr123025  cursor for pbdbsr123025

##Obter o total de satisfacao por socorrista
let l_sql = " select sum(vlr_satisf) "
            ," from work:temp_bonif "
            ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
            ,"   and srrcoddig = ? "
            ,"   and satisf = 1 "

prepare pbdbsr123026  from l_sql
declare cbdbsr123026  cursor for pbdbsr123026

let l_sql = " select socvcltip from work:temp_bonif "
            ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
            ,"   and socvcltip not in (6,8,10,11,12,13,14)"

prepare pbdbsr123027  from l_sql
declare cbdbsr123027  cursor for pbdbsr123027

##Qtd de servicos do prestador
let l_sql = " select count(*) from work:temp_bonif "
            ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "

prepare pbdbsr123028  from l_sql
declare cbdbsr123028  cursor for pbdbsr123028

##Qtd de criterios que foram avaliados
let l_sql = " select count(*) from dpakprtbnfgrpcrt "
            ," where prtbnfgrpcod = ? "

prepare pbdbsr123029  from l_sql
declare cbdbsr123029  cursor for pbdbsr123029

##Obtem ultimo codigo da bonificacao
let l_sql = " select max(prtbnfcod) from dpakprtbnf "

prepare pbdbsr123031  from l_sql
declare cbdbsr123031  cursor for pbdbsr123031

##Obtem ultimo codigo da bonificacao
let l_sql = " insert into dpakprtbnf (prtbnfcod, pstcoddig, srvqtd, "
           ,"                         bnfqtd, actbnfqtd, bnfvlr, bnfdat) "
           ,"                 values (?,?,?,?,?,?,?) "

prepare pbdbsr123032  from l_sql

let l_sql = " select perc_pontual  from work:temp_bonif "
	    ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
	    ,"   and srrcoddig = ? "
	    ,"   and pontual = 1 "

prepare pbdbsr123033  from l_sql
declare cbdbsr123033  cursor for pbdbsr123033

let l_sql = " select seg_vcl, disp_manha, vlr_dispmanha, percindisp_m, "
           ,"        tot_disp_m, minper_m, vlr_minper_m, "
           ,"        disp_tarde, vlr_disptarde, percindisp_t, "
           ,"        tot_disp_t, minper_t, vlr_minper_t, "
           ,"        descricao, segvcl_c, msgseg_veic, "
           ,"        msgdispmanha, msgdisptarde "
           ,"   from work:temp_bonif "
	   ," where atdprscod = ? "
           ,"   and prtbnfgrpcod = ? "
	   ,"   and socvclcod = ? "

prepare pbdbsr123034  from l_sql
declare cbdbsr123034  cursor for pbdbsr123034

##Obter o valor da resolubilidade
let l_sql = " select unique vlr_resolub "
            ," from work:temp_bonif "
            ," where atdprscod = ? "
            ,"   and prtbnfgrpcod = ? "
            ,"   and srrcoddig = ? "

prepare pbdbsr123036  from l_sql
declare cbdbsr123036  cursor for pbdbsr123036

end function

#-----------------------------------------------------------------------------#
function bdbsr123()
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
      ,cgccpfnum       like datksrr.cgccpfnum          ## CPF do Socorrista
      ,cgccpfdig       like datksrr.cgccpfdig          ## Dig. CPF do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          smallint                        ## SIM / NAO
      ,seg_vida        smallint                        ## SIM / NAO
      ,seg_vcl         smallint                        ## SIM / NAO
      ,disp_manha      smallint                        ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_m        like dpakprfind.bnfvlr
      ,vlr_minper_m    like dpakprfind.bnfvlr
      ,disp_tarde      smallint                        ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_t        like dpakprfind.bnfvlr
      ,vlr_minper_t    like dpakprfind.bnfvlr
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor bonif total
      ,asitipcod       like datmservico.asitipcod      ## Cod assistencia srv
      ,socntzcod       like datmsrvre.socntzcod        ## Cod assistencia srv
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,segvida_c       char(1)
      ,segvcl_c        char(1)
      ,satisf_c        char(1)
      ,dispm_c         char(1)
      ,dispt_c         char(1)
      ,pontual_c       char(1)
      ,resolub_c       char(1)
end record

define lr_qualifpont   record
       atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
end record

define lr_qualifsatisf record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista
      ,pstcoddig       like dpaksocor.pstcoddig        ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome do Prestador
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
end record

define lr_qualifseg    record
       srrcoddig       like datksrr.srrcoddig          ## Codigo do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,pstcoddig       like dpaksocor.pstcoddig        ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome do Prestador
      ,datavig         date                            ## Data para vig dos seguros
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

define lr_valores      record
       vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor Bonific disp manha
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor Bonific disp tarde
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor Bonific satisfacao
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor Bonific pontualidade
      ,vlr_resolub     like dpakprfind.bnfvlr
end record

define lr_soma         record
       totsrv          decimal(12,2)
      ,bonifmaxsrv     decimal(12,2)
      ,segatg          decimal(12,2)
      ,manha           decimal(12,2)
      ,manhaatg        decimal(12,2)
      ,tarde           decimal(12,2)
      ,tardeatg        decimal(12,2)
      ,cliente         decimal(12,2)
      ,clienteatg      decimal(12,2)
      ,pontual         decimal(12,2)
      ,pontualatg      decimal(12,2)
      ,bonif           decimal(12,2)
end record

define lr_linha        record
       prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra do Prestador
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom          like datksrr.srrnom             ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seg_vida        smallint                        ## SIM / NAO
      ,seg_vcl         smallint                        ## SIM / NAO
      ,disp_manha      smallint                        ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_m        like dpakprfind.bnfvlr
      ,vlr_minper_m    like dpakprfind.bnfvlr
      ,disp_tarde      smallint                        ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_t        like dpakprfind.bnfvlr
      ,vlr_minper_t    like dpakprfind.bnfvlr
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint                        ## SIM / NAO
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor Bonif total
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,msgseg_vida     char(100)                      ## Msg Quallificao Seguro
      ,msgseg_veic     char(100)                      ## Msg Quallificao Seguro
      ,msgdispmanha    char(100)                      ## Msg Disponibili Manha
      ,msgdisptarde    char(100)                      ## Msg Disponibili Tarde
      ,msgsatisfacao   char(100)                      ## Msg Quallificao Satif
      ,msgpontualidade char(100)                      ## Msg Quallificao Pont
      ,msgresolub      char(120)                      ## Msg Quallificao Pont
end record

define ws record
   bcoctatip   like dpaksocorfav.bcoctatip,
   bcocod      like dpaksocorfav.bcocod,
   bcoagnnum   like dpaksocorfav.bcoagnnum,
   bcoagndig   like dpaksocorfav.bcoagndig,
   bcoctanum   like dpaksocorfav.bcoctanum,
   bcoctadig   like dpaksocorfav.bcoctadig,
   contatip    char(10)
end record

define l_ant_atdprscod    like datmservico.atdprscod,
       l_ant_srrcoddig    like datmservico.srrcoddig,
       l_ant_socvclcod    like datmservico.socvclcod,
       l_prtbnfgrpcod_ant like dpakbnfgrppar.prtbnfgrpcod,
       l_seg_vida         smallint,
       l_seg_vcl          smallint,
       l_seg_vida_ant     smallint,
       l_seg_vcl_ant      smallint,
       l_flag             smallint,
       l_data             date,
       l_tot_srv          integer,
       l_tot_pon          integer,
       l_perc_pon         dec(8,4),
       l_criterio         integer,
       l_auto_re          integer,
       l_pstant           like datmservico.atdprscod

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

 define l_ret smallint,
        l_msg  char(50),
        l_crttip like dpakprtbnfcrt.crttip

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

 define l_flag_veic smallint,
        l_status smallint,
        l_cc     char(200)

### RODOLFO MASSINI - INICIO
#---> Variaves para:
#     remover (comentar) forma de envio de e-mails anterior e inserir
#     novo componente para envio de e-mails.
#---> feito por Rodolfo Massini (F0113761) em maio/2013

define lr_mail record
       rem char(50),
       des char(250),
       ccp char(250),
       cco char(250),
       ass char(500),
       msg char(32000),
       idr char(20),
       tip char(4)
end record

define lr_anexo record
       anexo1    char (300)
      ,anexo2    char (300)
      ,anexo3    char (300)
end record

define l_anexo   char (300)
      ,l_retorno smallint

initialize lr_mail
          ,l_anexo
          ,l_retorno
          ,lr_anexo
to null

### RODOLFO MASSINI - FIM

 let l_cc  = null
 let l_flag_veic = false
 let l_status = 0
 initialize lr_trab.*         to null
 initialize lr_linha.*        to null
 initialize lr_qualifpont.*   to null
 initialize lr_qualifsatisf.* to null
 initialize lr_qualifseg.*    to null
 initialize lr_qualifdisp.*   to null
 initialize lr_retorno.*      to null
 initialize lr_valores.*      to null
 initialize lr_soma.*         to null
 initialize lr_ctd27g00.*     to null
 initialize lr_ctd27g02.*     to null
 initialize lr_ctd27g03.*     to null
 initialize lr_ctd27g04.*     to null
 initialize lr_ctd27g05.*     to null
 initialize lr_ctb00g09.*     to null
 initialize lr_ctd28g00.*     to null
 initialize lr_cty11g00.*     to null
 initialize lr_ctd07g04.*     to null
 initialize mr_relat.*     to null

 let l_crttip = null
 let l_tot_srv = 0
 let l_tot_pon = 0
 let l_perc_pon = 0
 let l_prtbnfgrpcod_ant = null
 let m_arq1 = null
 let m_arq2 = null
 let l_ret = 0
 let l_msg = null

 let l_seg_vida        = 0
 let l_seg_vcl         = 0
 let l_seg_vida_ant    = 0
 let l_seg_vcl_ant     = 0

 ###  Verifica se recebeu a data de processamento como argumento ###
 let lr_trab.datastr = arg_val(2)

 call bdbsr123_prepare()

 if lr_trab.datastr is null or
    lr_trab.datastr = " "  then
    let lr_trab.datastr =  today
 else
    let l_data = null
    let l_data = lr_trab.datastr
    if l_data is null then
        let m_curr  = current
        display"[", m_curr , "] *** ERRO NO PARAMETRO: DATA INVALIDA ! ***"
       exit program(1)
    end if
 end if

 ###  Determina  as datas conforme o parametro ou today  ###
 let lr_trab.datastr = "01", lr_trab.datastr[3,10]
 let lr_trab.dataini = lr_trab.datastr
 let lr_trab.dataini = lr_trab.dataini - 1 units month
 let lr_trab.datafim = lr_trab.dataini + 1 units month - 1 units day

 let lr_trab.datastr = lr_trab.dataini
 let lr_trab.datastr = "15", lr_trab.datastr[3,10]
 let lr_trab.datavig = lr_trab.datastr

 open cbdbsr123002
 whenever error continue
 fetch cbdbsr123002 into m_remetente
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let m_remetente = null
    else
       let m_erro = "Problemas no acesso tabela igbmparam,sql = ", sqlca.sqlcode
       call errorlog(m_erro)
        let m_curr  = current
        display "[", m_curr ,"] bdbsr123/igbmparam/", m_erro clipped
       exit program(1)
    end if
 end if

 if m_remetente is null then
    let m_remetente = "porto.socorro@porto-seguro.com.br"
 end if

 let lr_trab.atdprscod = 0
 let l_ant_srrcoddig   = 0
 let l_ant_atdprscod   = 0
 let l_ant_socvclcod   = 0
 let l_flag            = false
 let lr_soma.totsrv     = 0
 let lr_soma.segatg     = 0
 let lr_soma.manha      = 0
 let lr_soma.manhaatg   = 0
 let lr_soma.tarde      = 0
 let lr_soma.tardeatg   = 0
 let lr_soma.cliente    = 0
 let lr_soma.clienteatg = 0
 let lr_soma.pontual    = 0
 let lr_soma.pontualatg = 0
 let lr_soma.bonif      = 0

 if m_auto_re = "AUTO" then
    let l_auto_re = 1
 else
    let l_auto_re = 2
 end if

 let mr_relat.dataini = lr_trab.dataini
 let mr_relat.datafim = lr_trab.datafim

 call c24geral_mes(lr_trab.dataini)
      returning mr_relat.mes_extenso

 let m_curr  = current
 display "[", m_curr , "] DATA INCIAL: ", mr_relat.dataini
 display "[", m_curr, "] DATA FINAL : ", mr_relat.datafim

 let m_curr = current
 display "[", m_curr, "] ABRINDO CURSOR PRINCIPAL"

 let l_pstant = 0

 open cbdbsr123001 using lr_trab.dataini, lr_trab.datafim

 foreach cbdbsr123001 into  lr_trab.atdprscod,
                            lr_trab.nomgrr,
                            lr_trab.maides,
                            lr_trab.srrcoddig,
                            lr_trab.srrnom,
                            lr_trab.cgccpfnum,
                            lr_trab.cgccpfdig,
                            lr_trab.socvclcod,
                            lr_trab.socvcltip,
                            lr_trab.atdvclsgl,
                            lr_trab.mdtcod,
                            lr_trab.atdetpdat,
                            lr_trab.atdsrvorg,
                            lr_trab.atdsrvnum,
                            lr_trab.atdsrvano,
                            lr_trab.asitipcod



     if  lr_trab.atdprscod <> l_pstant then
         update datkgeral
            set grlinf = l_pstant,
                atldat = today,
                atlhor = current
          where grlchv = 'ULTSRVBONAUTO'

          let l_pstant = lr_trab.atdprscod
     end if

     # VERIFICA PRESTADOR BONIFICAVEL
     if  not ctc20m07_verifica_prtbnf(lr_trab.atdprscod, l_auto_re) then

         let m_curr = current
         display "[", m_curr, "] PRESTADOR NAO BONIFICAVEL: ", lr_trab.atdprscod
         continue foreach
     end if

     # NAO CONSIDERA A BONIFICACAO PARA OS TIPOS DE VEICULOS ABAIXO
     if lr_trab.socvcltip =  6 or lr_trab.socvcltip =  8 or
        lr_trab.socvcltip = 10 or lr_trab.socvcltip = 11 or
        lr_trab.socvcltip = 12 or lr_trab.socvcltip = 13 or
        lr_trab.socvcltip = 14 then

        let m_curr = current
        display "[", m_curr, "] TIPO DE VEICULO NAO BONIFICAVEL : ", lr_trab.socvcltip
        continue foreach
     end if

     let lr_trab.socntzcod = 0

     # BUSCA NATUREZA DO SERVIÇO
     if lr_trab.atdsrvorg = 9 or lr_trab.atdsrvorg = 13 then

        call ctd07g04_sel_re(1,lr_trab.atdsrvnum,lr_trab.atdsrvano)
             returning lr_ctd07g04.*
        let lr_trab.socntzcod = lr_ctd07g04.socntzcod

     end if

     # BUSCA O CODIGO DO GRUPO DO SERVICO PARA AVALIAR CADA CRITERIO
     initialize lr_ctd27g03.* to null
     call ctd27g03_grp_srv(lr_trab.atdsrvorg,
                           lr_trab.asitipcod,
                           lr_trab.socntzcod)
          returning lr_ctd27g03.*

     if lr_ctd27g03.ret <> 1 then
        let lr_ctd27g03.msg = lr_ctd27g03.msg clipped,
                              " SERVICO ", lr_trab.atdsrvnum
        let m_curr = current
        display "[", m_curr, "] ", lr_ctd27g03.msg
        continue foreach
     end if









     ###  Se mudou o codigo do socorrista, qualifica resolubilidade ###
     if l_flag = false or lr_trab.srrcoddig <> l_ant_srrcoddig then

        let lr_trab.resolub = 0

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 7  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        let lr_trab.resolub_c = lr_ctd27g04.credencia

        # PROCESSA CRITERIO DE SATISFACAO PARA O GRUPO
        if lr_ctd27g04.ret = 1 then

           let lr_qualifsatisf.srrcoddig = lr_trab.srrcoddig
           let lr_qualifsatisf.pstcoddig = lr_trab.atdprscod
           let lr_qualifsatisf.nomgrr    = lr_trab.nomgrr
           let lr_qualifsatisf.dataini   = lr_trab.dataini - 5 units month
           let lr_qualifsatisf.datafim   = ((lr_trab.dataini - 2 units month) - 1 units day)




           let m_curr = current
           call ctb00g12_qualifresolub(lr_qualifsatisf.srrcoddig,
                                       lr_qualifsatisf.pstcoddig,
                                       lr_qualifsatisf.nomgrr,
                                       lr_qualifsatisf.dataini,
                                       lr_qualifsatisf.datafim)
                returning lr_ctb00g12.*

           let m_curr = current

           let lr_linha.msgresolub = lr_ctb00g12.msgerro

           if lr_ctb00g12.coderro <> 0 then
              let m_erro = lr_ctb00g12.coderro,"-", lr_ctb00g12.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsr123 / ", m_erro clipped
           end if

           let lr_trab.numsrv_res = lr_ctb00g12.numsrv
           let lr_trab.numret_res = lr_ctb00g12.numret
           let lr_trab.percresolub = lr_ctb00g12.percresolub

           # OBTEM VALOR DA FAIXA DO PERCENTUAL DE RESOLUBILIDADE
           initialize lr_ctd27g02.* to null
           call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,lr_ctd27g03.prtbnfgrpcod,
                                     lr_trab.percresolub)
                returning lr_ctd27g02.*

           let lr_trab.vlr_resolub = lr_ctd27g02.fxavlr
           let lr_trab.tot_resolub = lr_trab.vlr_resolub

           if lr_trab.vlr_resolub > 0 then
              let lr_trab.resolub = 1
           end if
        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if

           let lr_trab.resolub = 99 ## criterio nao avalido, nao considerar
           let lr_trab.numsrv_res = 0
           let lr_trab.numret_res = 0
           let lr_trab.percresolub = 0
           let lr_trab.vlr_resolub = 0
           let lr_trab.tot_resolub = 0
        end if
     else
        let lr_trab.numsrv_res  = 0
        let lr_trab.numret_res  = 0
        let lr_trab.percresolub = 0
     end if

     #Valida o criterio para o grupo de servico
     initialize lr_ctd27g04.* to null
     let lr_trab.bnfcrtcod = 6  ## Codigo do criterio
     call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, lr_trab.bnfcrtcod)
          returning lr_ctd27g04.*

     let lr_trab.pontual_c = lr_ctd27g04.credencia

     ## Processa criterio de pontualidade para o grupo
     if lr_ctd27g04.ret = 1 then

        ###  Qualifica a pontualidade do servico ###
        let lr_qualifpont.atdsrvnum = lr_trab.atdsrvnum
        let lr_qualifpont.atdsrvano = lr_trab.atdsrvano

        call ctb00g06_qualifpont(lr_qualifpont.atdsrvnum,
                                 lr_qualifpont.atdsrvano,
                                 lr_ctd27g03.prtbnfgrpcod)
             returning lr_retorno.*

        let m_curr = current

        let lr_linha.msgpontualidade = lr_retorno.msgerro

        if lr_retorno.coderro <> 0 then
           let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
           call errorlog(m_erro)
                   let m_curr = current
                   display "[", m_curr, "] bdbsr123/ctb00g06_qualifpont / ", m_erro clipped
        end if

        if lr_retorno.qualificado = "S" then
           let lr_trab.pontual = 1
        else
           let lr_trab.pontual = 0
        end if

        let lr_trab.perc_pontual    = 0
        let lr_valores.vlr_pontual  = 0
        let lr_trab.tot_pontual     = 0
        let lr_trab.tot_max_pontual = 0

     else
        if lr_ctd27g04.ret = 3 then
           continue foreach
        end if

        let lr_trab.pontual = 99 ## criterio nao avalido, nao considerar
        let lr_trab.perc_pontual = 0
        let lr_valores.vlr_pontual = 0
        let lr_trab.tot_pontual = 0
        let lr_trab.tot_max_pontual = 0

     end if

     ###  Se mudou o codigo do socorrista, qualifica satisfacao ###
     if l_flag = false or lr_trab.srrcoddig <> l_ant_srrcoddig then

        let lr_trab.satisf = 0

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 5  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        let lr_trab.satisf_c = lr_ctd27g04.credencia

        ## Processa criterio de satisfacao para o grupo
        if lr_ctd27g04.ret = 1 then

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

           let m_curr = current

           let lr_linha.msgsatisfacao = lr_ctb00g07.msgerro

           if lr_ctb00g07.coderro <> 0 then
              let m_erro = lr_ctb00g07.coderro,"-", lr_ctb00g07.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsr123/ctb00g07_qualifsatisf / ", m_erro clipped
           end if

           let lr_trab.numsrv     = lr_ctb00g07.numsrv
           let lr_trab.numrec     = lr_ctb00g07.numrec
           let lr_trab.percsatisf = lr_ctb00g07.percsatisf

           ##Obtem valor da faixa do percentual de satisfacao
           initialize lr_ctd27g02.* to null
           call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,lr_ctd27g03.prtbnfgrpcod,
                                     lr_trab.percsatisf)
                returning lr_ctd27g02.*

           let lr_valores.vlr_satisf = lr_ctd27g02.fxavlr
           let lr_trab.tot_satisf    = lr_valores.vlr_satisf

           if lr_valores.vlr_satisf > 0 then
              let lr_trab.satisf = 1
           end if

           #obter a faixa anterior de satisfacao abaixo do percentual atual
           call ctd27g02_ant_minper(lr_trab.bnfcrtcod,lr_ctd27g03.prtbnfgrpcod,
                                    lr_trab.percsatisf)
                returning lr_ctd27g02.ret, lr_ctd27g02.msg, lr_trab.minper_m

           if lr_ctd27g02.ret = 1 then ## se achou registro
              call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,
                                        lr_ctd27g03.prtbnfgrpcod,
                                        lr_trab.minper_m)
                   returning lr_ctd27g02.*
              let lr_trab.vlr_max_satisf = lr_ctd27g02.fxavlr
           else
              let lr_trab.minper_m       = lr_trab.percsatisf
              let lr_trab.vlr_max_satisf = lr_valores.vlr_satisf
           end if
        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if

           let lr_trab.satisf = 99 ## criterio nao avalido, nao considerar
           let lr_trab.numsrv = 0
           let lr_trab.numrec = 0
           let lr_trab.percsatisf = 0
           let lr_valores.vlr_satisf = 0
           let lr_trab.tot_satisf = 0
           let lr_trab.vlr_max_satisf = 0
        end if

     end if

     ###  Se mudou o codigo do veiculo, qualifica disponibilidade ###
     if l_flag = false or lr_trab.socvclcod <> l_ant_socvclcod then

        ##Verifica se ja fez o seg_vcl e disponibilidade p/o veiculo pq o
        ##veiculo varia de socorrista, mas a apuracao da disp eh a mesma
        let l_flag_veic = false
        open cbdbsr123034 using lr_trab.atdprscod, lr_ctd27g03.prtbnfgrpcod,
                                lr_trab.socvclcod
        fetch cbdbsr123034 into lr_trab.seg_vcl, lr_trab.disp_manha,
                                lr_trab.vlr_dispmanha, lr_trab.percindisp_m,
                                lr_trab.tot_disp_m, lr_trab.minper_m,
                                lr_trab.vlr_minper_m, lr_trab.disp_tarde,
                                lr_trab.vlr_disptarde, lr_trab.percindisp_t,
                                lr_trab.tot_disp_t, lr_trab.minper_t,
                                lr_trab.vlr_minper_t, lr_trab.descricao,
                                lr_trab.segvcl_c, lr_linha.msgseg_veic,
                                lr_linha.msgdispmanha, lr_linha.msgdisptarde
        if sqlca.sqlcode <> notfound then
           let l_flag_veic = true
        end if

        close cbdbsr123034

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 3  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod,lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        let lr_trab.dispm_c = lr_ctd27g04.credencia

        ## Processa criterio de disponibilidade da manha para o grupo
        if lr_ctd27g04.ret = 1 then

           if l_flag_veic = false then
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

              let m_curr = current

              let lr_linha.msgdispmanha = lr_ctb00g09.msgerro

              if lr_ctb00g09.coderro <> 0 then
                 let m_erro = lr_ctb00g09.coderro,"-", lr_ctb00g09.msgerro
                 call errorlog(m_erro)
                         let m_curr = current
                         display "[", m_curr, "] bdbsr123/ctb00g09_qualifdisp / ", m_erro clipped
              end if

              if lr_ctb00g09.percindisp is null then
                 let lr_ctb00g09.percindisp = 0
              end if

              let lr_trab.percindisp_m = lr_ctb00g09.percindisp

              ##Obtem o valor da faixa do perc.de indisponibilidade
              initialize lr_ctd27g02.* to null
              call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,
                                        lr_ctd27g03.prtbnfgrpcod,
                                        lr_trab.percindisp_m)
                   returning lr_ctd27g02.*

              if lr_ctd27g02.fxavlr  = 0 then
                 let lr_trab.disp_manha = 0
              else
                 let lr_trab.disp_manha = 1
              end if

              let lr_valores.vlr_dispmanha = lr_ctd27g02.fxavlr
              let lr_trab.tot_disp_m = lr_ctd27g02.fxavlr

              #obter a proxima faixa de disponibilidade acima do percentual atual
              call ctd27g02_prox_minper(lr_trab.bnfcrtcod,lr_ctd27g03.prtbnfgrpcod,
                                        lr_trab.percindisp_m)
                   returning lr_ctd27g02.ret, lr_ctd27g02.msg, lr_trab.minper_m

              if lr_ctd27g02.ret = 1 then ## se achou registro
                 call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,
                                           lr_ctd27g03.prtbnfgrpcod,
                                           lr_trab.minper_m)
                      returning lr_ctd27g02.*
                 let lr_trab.vlr_minper_m = lr_ctd27g02.fxavlr
              else
                 let lr_trab.minper_m = lr_trab.percindisp_m
                 let lr_trab.vlr_minper_m = lr_valores.vlr_dispmanha
              end if
           end if

        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if

           let lr_trab.disp_manha       = 99 ## CRITERIO NAO AVALIDO, NAO CONSIDERA
           let lr_trab.percindisp_m     = 0
           let lr_valores.vlr_dispmanha = 0
           let lr_trab.tot_disp_m       = 0
           let lr_trab.minper_m         = 0
           let lr_trab.vlr_minper_m     = 0

        end if

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 4  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod,lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        let lr_trab.dispt_c = lr_ctd27g04.credencia

        ## Processa criterio de disponibilidade da tarde do grupo
        if lr_ctd27g04.ret = 1 then

           ## Qualifica a disponibilidade pela tarde
           if l_flag_veic = false then
              let lr_qualifdisp.mdtcod    = lr_trab.mdtcod
              let lr_qualifdisp.pstcoddig = lr_trab.atdprscod
              let lr_qualifdisp.nomgrr    = lr_trab.nomgrr
              let lr_qualifdisp.dataini   = lr_trab.dataini
              let lr_qualifdisp.datafim   = lr_trab.datafim
              let lr_qualifdisp.pertip    = "T"

              initialize lr_ctb00g09.*     to null
              call ctb00g09_qualifdisp(lr_qualifdisp.mdtcod,
                                       lr_qualifdisp.pstcoddig,
                                       lr_qualifdisp.nomgrr,
                                       lr_qualifdisp.dataini,
                                       lr_qualifdisp.datafim,
                                       lr_qualifdisp.pertip)
                   returning lr_ctb00g09.*

              let m_curr = current

              let lr_linha.msgdisptarde = lr_ctb00g09.msgerro

              if lr_ctb00g09.coderro <> 0 then
                 let m_erro = lr_ctb00g09.coderro,"-", lr_ctb00g09.msgerro
                 call errorlog(m_erro)
                         let m_curr = current
                         display "[", m_curr, "] bdbsr123 / ", m_erro clipped
              end if

              if lr_ctb00g09.percindisp is null then
                 let lr_ctb00g09.percindisp = 0
              end if

              let lr_trab.percindisp_t = lr_ctb00g09.percindisp

              ##Obtem o valor da faixa do perc.de indisponibilidade
              initialize lr_ctd27g02.* to null
              call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,
                                        lr_ctd27g03.prtbnfgrpcod,
                                        lr_trab.percindisp_t)
                   returning lr_ctd27g02.*

              if lr_ctd27g02.fxavlr  = 0 then
                 let lr_trab.disp_tarde = 0
              else
                 let lr_trab.disp_tarde = 1
              end if

              let lr_valores.vlr_disptarde = lr_ctd27g02.fxavlr
              let lr_trab.tot_disp_t = lr_ctd27g02.fxavlr

              #obter a proxima faixa de disponibilidade acima do percentual atual
              call ctd27g02_prox_minper(lr_trab.bnfcrtcod,
                                        lr_ctd27g03.prtbnfgrpcod,
                                        lr_trab.percindisp_t)
                   returning lr_ctd27g02.ret, lr_ctd27g02.msg, lr_trab.minper_t

              if lr_ctd27g02.ret = 1 then ## se achou registro
                 call ctd27g02_faixa_bonif(lr_trab.bnfcrtcod,
                                           lr_ctd27g03.prtbnfgrpcod,
                                           lr_trab.minper_t)
                      returning lr_ctd27g02.*

                 let lr_trab.vlr_minper_t = lr_ctd27g02.fxavlr
              else
                 let lr_trab.minper_t = lr_trab.percindisp_t
                 let lr_trab.vlr_minper_t = lr_valores.vlr_disptarde
              end if

           end if

        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if

           let lr_trab.disp_tarde = 99 ## criterio nao avalido, nao considera
           let lr_trab.percindisp_t = 0
           let lr_valores.vlr_disptarde = 0
           let lr_trab.tot_disp_t       = 0
           let lr_trab.minper_t         = 0
           let lr_trab.vlr_minper_t     = 0
        end if

     end if

     ###  Se mudou o socorrista qualifica o seguro de vida      ###
     if l_flag = false or lr_trab.srrcoddig <> l_ant_srrcoddig then

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 1  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        ## Processa criterio de seguro vida socorrista
        if lr_ctd27g04.ret = 1 then

           let lr_trab.segvida_c = lr_ctd27g04.credencia

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

           let lr_linha.msgseg_vida = lr_retorno.msgerro

           if lr_retorno.coderro <> 0 then
              let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsr123/ctb00g08_qualifsrr / ", m_erro clipped
              continue foreach
           end if

           if lr_retorno.qualificado = "S" then
              let lr_trab.seg_vida = 1
           else
              let lr_trab.seg_vida = 0
           end if

        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if
           let lr_trab.segvida_c = "N"
           let lr_trab.seg_vida = 99 ## criterio nao avalido, nao considera
        end if

     end if

     ###  Se mudou o  veiculo, qualifica seguro do veiculo     ###
     if (l_flag = false or lr_trab.socvclcod <> l_ant_socvclcod) and
        l_flag_veic = false then

        ## obtem sigla e tipo de viatura
        initialize lr_ctd28g00.* to null
        call ctd28g00_inf_datkveiculo(1, lr_trab.socvclcod)
             returning lr_ctd28g00.*

        let lr_trab.atdvclsgl = lr_ctd28g00.atdvclsgl

        ## obtem a descricao do tipo da viatura
        initialize lr_retorno.* to null
        initialize lr_cty11g00.* to  null
        call cty11g00_iddkdominio("socvcltip", lr_trab.socvcltip)
             returning lr_cty11g00.*

        let lr_trab.descricao = lr_cty11g00.cpodes

        # VALIDA O CRITERIO PARA O GRUPO DE SERVICO
        initialize lr_ctd27g04.* to null
        let lr_trab.bnfcrtcod = 2  ## Codigo do criterio
        call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, lr_trab.bnfcrtcod)
             returning lr_ctd27g04.*

        ## Processa criterio de seguro da viatura
        if lr_ctd27g04.ret = 1 then
           let lr_trab.segvcl_c = lr_ctd27g04.credencia

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

           let lr_linha.msgseg_veic = lr_retorno.msgerro

           if lr_retorno.coderro <> 0 then
              let m_erro = lr_retorno.coderro,"-", lr_retorno.msgerro
              call errorlog(m_erro)
                      let m_curr = current
                      display "[", m_curr, "] bdbsr123/ctb00g08_qualifvcl / ", m_erro clipped
              #continue foreach
           end if

           if lr_retorno.qualificado = "S" then
              let lr_trab.seg_vcl = 1
           else
              let lr_trab.seg_vcl = 0
           end if

        else
           if lr_ctd27g04.ret = 3 then ##Erro no banco
              continue foreach
           end if
           let lr_trab.segvcl_c = "N"
           let lr_trab.seg_vcl = 99 ## criterio nao avalido, nao considera
        end if

     end if

     let l_ant_srrcoddig = lr_trab.srrcoddig
     let l_ant_socvclcod = lr_trab.socvclcod

     if l_flag = false then
        let l_flag = true
     end if

     let m_curr = current
     display "[", m_curr, "] INCLUI NA TABELA WORK"

     insert into work:temp_bonif values (
                 lr_trab.atdprscod,
                 lr_trab.nomgrr,
                 lr_trab.maides,
                 lr_trab.srrcoddig,
                 lr_trab.srrnom,
                 lr_trab.socvclcod,
                 lr_trab.socvcltip,
                 lr_trab.atdvclsgl,
                 lr_trab.descricao,
                 lr_trab.atdetpdat,
                 lr_trab.atdsrvorg,
                 lr_trab.atdsrvnum,
                 lr_trab.atdsrvano,
                 lr_trab.seg_vida,
                 lr_trab.seg_vcl,
                 lr_trab.disp_manha,
                 lr_valores.vlr_dispmanha,
                 lr_trab.percindisp_m,
                 lr_trab.tot_disp_m,
                 lr_trab.minper_m,
                 lr_trab.vlr_minper_m,
                 lr_trab.disp_tarde,
                 lr_valores.vlr_disptarde,
                 lr_trab.percindisp_t,
                 lr_trab.tot_disp_t,
                 lr_trab.minper_t,
                 lr_trab.vlr_minper_t,
                 lr_trab.satisf,
                 lr_trab.numsrv,
                 lr_trab.numrec,
                 lr_trab.percsatisf,
                 lr_valores.vlr_satisf,
                 lr_trab.tot_satisf,
                 lr_trab.vlr_max_satisf,
                 lr_trab.pontual,
                 lr_trab.perc_pontual,
                 lr_valores.vlr_pontual,
                 lr_trab.tot_pontual,
                 lr_trab.tot_max_pontual,
                 lr_trab.resolub,
                 lr_trab.numsrv_res,
                 lr_trab.numret_res,
                 lr_trab.percresolub,
                 lr_trab.vlr_resolub,
                 lr_trab.tot_resolub,
                 lr_trab.dataini,
                 lr_trab.datafim,
                 lr_linha.msgdispmanha,
                 lr_linha.msgdisptarde,
                 lr_linha.msgsatisfacao,
                 lr_linha.msgseg_vida,
                 lr_linha.msgseg_veic,
                 lr_linha.msgpontualidade,
                 lr_linha.msgresolub,
                 lr_ctd27g03.prtbnfgrpcod,
                 lr_trab.segvida_c,
                 lr_trab.segvcl_c,
                 lr_trab.satisf_c,
                 lr_trab.dispm_c,
                 lr_trab.dispt_c,
                 lr_trab.pontual_c,
                 lr_trab.resolub_c
               )

 end foreach

 let m_curr = current

 initialize lr_trab.* to null

 ## Gera o relatorio analitico por prestador e concatena em um arquivo para
 ## enviar ao Porto Socorro
 let l_flag = false

 declare cbdbsr123004 cursor for
    select * from work:temp_bonif
           order by prtbnfgrpcod,
                    atdprscod, srrcoddig,
	            atdvclsgl, atdetpdat,
	            atdsrvano, atdsrvnum, socvcltip

 foreach cbdbsr123004 into lr_trab.atdprscod,
                           lr_trab.nomgrr,
                           lr_trab.maides,
                           lr_trab.srrcoddig,
                           lr_trab.srrnom,
                           lr_trab.socvclcod,
                           lr_trab.socvcltip,
                           lr_trab.atdvclsgl,
                           lr_trab.descricao,
                           lr_trab.atdetpdat,
                           lr_trab.atdsrvorg,
                           lr_trab.atdsrvnum,
                           lr_trab.atdsrvano,
                           lr_trab.seg_vida,
                           lr_trab.seg_vcl,
                           lr_trab.disp_manha,
                           lr_valores.vlr_dispmanha,
                           lr_trab.percindisp_m,
                           lr_trab.tot_disp_m,
                           lr_trab.minper_m,
                           lr_trab.vlr_minper_m,
                           lr_trab.disp_tarde,
                           lr_valores.vlr_disptarde,
                           lr_trab.percindisp_t,
                           lr_trab.tot_disp_t,
                           lr_trab.minper_t,
                           lr_trab.vlr_minper_t,
                           lr_trab.satisf,
                           lr_trab.numsrv,
                           lr_trab.numrec,
                           lr_trab.percsatisf,
                           lr_valores.vlr_satisf,
                           lr_trab.tot_satisf,
                           lr_trab.vlr_max_satisf,
                           lr_trab.pontual,
                           lr_trab.perc_pontual,
                           lr_valores.vlr_pontual,
                           lr_trab.tot_pontual,
                           lr_trab.tot_max_pontual,
                           lr_trab.resolub,
                           lr_trab.numsrv_res,
                           lr_trab.numret_res,
                           lr_trab.percresolub,
                           lr_valores.vlr_resolub,
                           lr_trab.tot_resolub,
                           lr_trab.dataini,
                           lr_trab.datafim,
                           lr_linha.msgdispmanha,
                           lr_linha.msgdisptarde,
                           lr_linha.msgsatisfacao,
                           lr_linha.msgseg_vida,
                           lr_linha.msgseg_veic,
                           lr_linha.msgpontualidade,
                           lr_linha.msgresolub,
                           lr_trab.prtbnfgrpcod,
                           lr_trab.segvida_c,
                           lr_trab.segvcl_c,
                           lr_trab.satisf_c,
                           lr_trab.dispm_c,
                           lr_trab.dispt_c,
                           lr_trab.pontual_c,
                           lr_trab.resolub_c

     if l_flag = false then
        let m_nomearq3 = m_patharq clipped, "/RDB",
                         lr_trab.prtbnfgrpcod using "&&&","-",
                         lr_trab.atdprscod using "<<<<<<", "_dados.xls"

        let m_curr = current
        display "[", m_curr, "] Gerando relatorio para prestador: ", lr_trab.atdprscod

        start report bdbsr123_rel to m_nomearq3
        let l_ant_atdprscod = lr_trab.atdprscod
        let l_prtbnfgrpcod_ant = lr_trab.prtbnfgrpcod
     end if

     if lr_trab.prtbnfgrpcod <> l_prtbnfgrpcod_ant or
        lr_trab.atdprscod <> l_ant_atdprscod then

        finish report bdbsr123_rel

        call bdbsr110_insere_bnf(l_ant_atdprscod, l_prtbnfgrpcod_ant,
                                 lr_trab.seg_vida, lr_trab.seg_vcl)

        let m_nomearq3 = m_patharq clipped, "/RDB",
                         lr_trab.prtbnfgrpcod using "&&&","-",
                         lr_trab.atdprscod using "<<<<<<", "_dados.xls"

        let m_curr = current
        display "[", m_curr, "] Gerando relatorio para prestador: ", lr_trab.atdprscod

        start report bdbsr123_rel to m_nomearq3

     end if

     let l_ant_atdprscod = lr_trab.atdprscod
     let l_prtbnfgrpcod_ant = lr_trab.prtbnfgrpcod
     let l_seg_vida_ant = lr_trab.seg_vida
     let l_seg_vcl_ant = lr_trab.seg_vcl

     ## O indicador de seguros e classificatorio
     ## e desqualifica os demais, zerando o valor
     let lr_trab.vlr_dispmanha = 0
     let lr_trab.vlr_disptarde = 0
     let lr_trab.vlr_satisf = 0
     let lr_trab.vlr_pontual = 0
     let lr_trab.vlr_resolub = 0

     let lr_trab.tot_satisf = 0
     let lr_trab.tot_pontual = 0
     let lr_trab.tot_max_pontual = 0

     for l_criterio = 1 to 7 ##Avaliar todos os criterios

         call ctd27g01_consis_grp_crt(lr_trab.prtbnfgrpcod, l_criterio)
              returning l_ret, l_msg

         if l_ret = 1 then

            if l_criterio = 3 then
               if lr_trab.disp_manha = 1 then
                  let lr_trab.vlr_dispmanha = lr_valores.vlr_dispmanha
               end if
            end if

            if l_criterio = 4 then
               if lr_trab.disp_tarde = 1 then
                  let lr_trab.vlr_disptarde = lr_valores.vlr_disptarde
               end if
            end if

            if l_criterio = 5 then
               if lr_trab.satisf = 1 then
                  let lr_trab.vlr_satisf = lr_valores.vlr_satisf
               end if
            end if

            if l_criterio = 6 then
               ##Obtem a qtd de servicos total
               let l_tot_srv = 0
               open cbdbsr123005 using lr_trab.atdprscod,
                                       lr_trab.prtbnfgrpcod,
                                       lr_trab.srrcoddig
               fetch cbdbsr123005 into l_tot_srv
               close cbdbsr123005

               let l_tot_pon = 0
               ##Obtem a qtd de servicos pontuais
               open cbdbsr123006 using lr_trab.atdprscod,
                                       lr_trab.prtbnfgrpcod,
                                       lr_trab.srrcoddig
               fetch cbdbsr123006 into l_tot_pon
               close cbdbsr123006

               ##calcula o percentual dos pontuais sobre o total
               let l_perc_pon = (l_tot_pon / l_tot_srv) * 100

               ##Obtem a faixa de valor de acordo com o percentual
               initialize lr_ctd27g02.* to null
               call ctd27g02_faixa_bonif(6, lr_trab.prtbnfgrpcod,
                                            l_perc_pon)
                    returning lr_ctd27g02.*

               let lr_trab.vlr_pontual = lr_ctd27g02.fxavlr

               ##Calcula o valor recebido
               let lr_trab.tot_pontual = l_tot_pon * lr_ctd27g02.fxavlr
               let lr_trab.perc_pontual = l_perc_pon

               update work:temp_bonif set perc_pontual =lr_trab.perc_pontual,
                                    vlr_pontual = lr_trab.vlr_pontual,
                                    tot_pontual = lr_trab.tot_pontual
                      where atdprscod = lr_trab.atdprscod
                        and srrcoddig = lr_trab.srrcoddig
                        and prtbnfgrpcod = lr_trab.prtbnfgrpcod
                        and pontual = 1

               ##Obtem a faixa de valor para 100% de servicos pontuais
               initialize lr_ctd27g02.* to null
               call ctd27g02_faixa_bonif(6, lr_trab.prtbnfgrpcod, 100)
                    returning lr_ctd27g02.*

               let lr_trab.tot_max_pontual = lr_ctd27g02.fxavlr

               update work:temp_bonif set tot_max_pontual = lr_trab.tot_max_pontual
                      where atdprscod = lr_trab.atdprscod
                        and srrcoddig = lr_trab.srrcoddig
                        and prtbnfgrpcod = lr_trab.prtbnfgrpcod
                        and pontual in(0,1)

               if lr_trab.pontual = 0 then
                  let lr_trab.perc_pontual = 0
                  let lr_trab.vlr_pontual = 0
                  let lr_trab.tot_pontual = 0
               end if

               if lr_trab.pontual = 99 then
                  let lr_trab.perc_pontual = 0
                  let lr_trab.vlr_pontual = 0
                  let lr_trab.tot_pontual = 0
                  let lr_trab.tot_max_pontual = 0
               end if

            end if

            if l_criterio = 7 then
               if lr_trab.resolub = 1 then
                  let lr_trab.vlr_resolub = lr_valores.vlr_resolub
               end if
            end if

         end if

     end for

     ## Bonifica total (linha)
     let lr_trab.vlr_bonif = (lr_trab.vlr_dispmanha +
                              lr_trab.vlr_disptarde +
                              lr_trab.vlr_satisf    +
                              lr_trab.vlr_pontual   +
                              lr_trab.vlr_resolub)

     let lr_linha.prtbnfgrpcod  =  lr_trab.prtbnfgrpcod
     let lr_linha.atdprscod     =  lr_trab.atdprscod
     let lr_linha.nomgrr        =  lr_trab.nomgrr
     let lr_linha.maides        =  lr_trab.maides
     let lr_linha.srrcoddig     =  lr_trab.srrcoddig
     let lr_linha.srrnom        =  lr_trab.srrnom
     let lr_linha.socvclcod     =  lr_trab.socvclcod
     let lr_linha.socvcltip     =  lr_trab.socvcltip
     let lr_linha.atdvclsgl     =  lr_trab.atdvclsgl
     let lr_linha.atdetpdat     =  lr_trab.atdetpdat
     let lr_linha.atdsrvorg     =  lr_trab.atdsrvorg
     let lr_linha.atdsrvnum     =  lr_trab.atdsrvnum
     let lr_linha.atdsrvano     =  lr_trab.atdsrvano
     let lr_linha.seg_vida      =  lr_trab.seg_vida
     let lr_linha.seg_vcl       =  lr_trab.seg_vcl
     let lr_linha.disp_manha    =  lr_trab.disp_manha
     let lr_linha.vlr_dispmanha =  lr_trab.vlr_dispmanha
     let lr_linha.percindisp_m  =  lr_trab.percindisp_m
     let lr_linha.tot_disp_m    =  lr_trab.tot_disp_m
     let lr_linha.minper_m      =  lr_trab.minper_m
     let lr_linha.vlr_minper_m  =  lr_trab.vlr_minper_m
     let lr_linha.disp_tarde    =  lr_trab.disp_tarde
     let lr_linha.vlr_disptarde =  lr_trab.vlr_disptarde
     let lr_linha.percindisp_t  =  lr_trab.percindisp_t
     let lr_linha.tot_disp_t    =  lr_trab.tot_disp_t
     let lr_linha.minper_t      =  lr_trab.minper_t
     let lr_linha.vlr_minper_t  =  lr_trab.vlr_minper_t
     let lr_linha.satisf        =  lr_trab.satisf
     let lr_linha.numsrv        =  lr_trab.numsrv
     let lr_linha.numrec        =  lr_trab.numrec
     let lr_linha.percsatisf    =  lr_trab.percsatisf
     let lr_linha.vlr_satisf    =  lr_trab.vlr_satisf
     let lr_linha.tot_satisf    =  lr_trab.tot_satisf
     let lr_linha.vlr_max_satisf=  lr_trab.vlr_max_satisf
     let lr_linha.pontual       =  lr_trab.pontual
     let lr_linha.perc_pontual  =  lr_trab.perc_pontual
     let lr_linha.vlr_pontual   =  lr_trab.vlr_pontual
     let lr_linha.tot_pontual   =  lr_trab.tot_pontual
     let lr_linha.tot_max_pontual   =  lr_trab.tot_max_pontual
     let lr_linha.resolub       =  lr_trab.resolub
     let lr_linha.numsrv_res    =  lr_trab.numsrv_res
     let lr_linha.numret_res    =  lr_trab.numret_res
     let lr_linha.percresolub   =  lr_trab.percresolub
     let lr_linha.vlr_resolub   =  lr_trab.vlr_resolub
     let lr_linha.tot_resolub   =  lr_trab.tot_resolub
     let lr_linha.vlr_bonif     =  lr_trab.vlr_bonif
     let lr_linha.dataini       =  lr_trab.dataini
     let lr_linha.datafim       =  lr_trab.datafim

     output to report bdbsr123_rel(lr_linha.*)

     if l_flag = false then
        let l_flag = true
     end if

 end foreach

 if l_flag = true then
    finish report bdbsr123_rel
    call bdbsr110_insere_bnf(l_ant_atdprscod, l_prtbnfgrpcod_ant,
                             lr_trab.seg_vida, lr_trab.seg_vcl)
 end if

 ######################### GERA EMAIL PARA O PRESTADOR #######################

 declare cbdbsr123007 cursor for
    select unique prtbnfgrpcod, atdprscod, maides,
                   segvida_c, segvcl_c, satisf_c, dispm_c, dispt_c,
                   pontual_c, pontual_c
      from work:temp_bonif
     order by prtbnfgrpcod, atdprscod

 foreach cbdbsr123007 into mr_relat.prtbnfgrpcod, mr_relat.atdprscod,
                           mr_relat.maides,
                           mr_relat.segvida_c,
                           mr_relat.segvcl_c,
                           mr_relat.satisf_c,
                           mr_relat.dispm_c,
                           mr_relat.dispt_c,
                           mr_relat.pontual_c,
                           mr_relat.resolub_c

         if m_auto_re = "AUTO" then
            open cbdbsr123027 using mr_relat.atdprscod, mr_relat.prtbnfgrpcod
            fetch cbdbsr123027 into lr_trab.socvcltip

            if sqlca.sqlcode = notfound then
               let m_curr = current
               display "[", m_curr, "] PRESTADOR SEM NENHUMA VIATURA BONIFICAVEL (socvcltip)", mr_relat.atdprscod
               continue foreach
            end if
            close cbdbsr123027
         end if

         call ctd27g05_obter_desc_grp(1,mr_relat.prtbnfgrpcod)
              returning lr_ctd27g05.*

         let mr_relat.prtbnfgrpdes = lr_ctd27g05.prtbnfgrpdes

         let m_nomearq1 = m_patharq clipped, "/RDB",
                          mr_relat.prtbnfgrpcod using "&&&","-",
                          mr_relat.atdprscod using "<<<<<<", "_resumo.doc"

         let m_curr = current
         display "[", m_curr, "] Gerando email para prestador: ", mr_relat.atdprscod

         let m_arq1 = "RDB", mr_relat.prtbnfgrpcod using "&&&","-",
                              mr_relat.atdprscod using "<<<<<<", "_detalhes.doc"
         let m_nomearq2 = m_patharq clipped, "/",m_arq1

         let m_arq2 = "RDB", mr_relat.prtbnfgrpcod using "&&&","-",
                              mr_relat.atdprscod using "<<<<<<", "_dados.xls"

         let m_nomearq3 = m_patharq clipped, "/",m_arq2

         start report bdbsr123_resumo to m_nomearq1
         start report bdbsr123_detalhes to m_nomearq2

         let mr_relat.tot_bonif = 0
         let mr_relat.tot_max_bonif = 0

         let l_seg_vida = 0
         if mr_relat.segvida_c = "C" then
            let l_seg_vida = 1
         else
            if mr_relat.segvida_c = "N" then
               let l_seg_vida = 99
            end if
         end if

         let l_seg_vcl = 0
         if mr_relat.segvcl_c = "C" then
            let l_seg_vcl = 1
         else
            if mr_relat.segvcl_c = "N" then
               let l_seg_vcl = 99
            end if
         end if

         ##Obtem valores desempenho menos da satisfacao
         open cbdbsr123013 using mr_relat.atdprscod, mr_relat.prtbnfgrpcod,
                                 l_seg_vida,
                                 l_seg_vcl
         fetch cbdbsr123013 into mr_relat.tot_bonif
         close cbdbsr123013

         if mr_relat.tot_bonif is null then
            let mr_relat.tot_bonif = 0
         end if

         open cbdbsr123014 using mr_relat.atdprscod, mr_relat.prtbnfgrpcod
         fetch cbdbsr123014 into mr_relat.tot_max_bonif
         close cbdbsr123014

         if mr_relat.tot_bonif is null then
            let mr_relat.tot_bonif = 0
         end if

         ## Obter valor total da satisfacao
         call bdbsr123_obter_tot_satisf(mr_relat.atdprscod,
                                        mr_relat.prtbnfgrpcod,
                                        l_seg_vida,
                                        l_seg_vcl)
              returning lr_trab.tot_satisf, mr_relat.tot_satisf

         let mr_relat.tot_bonif = mr_relat.tot_bonif + lr_trab.tot_satisf

         let mr_relat.tot_max_bonif = mr_relat.tot_max_bonif +
                                      mr_relat.tot_satisf

         let mr_relat.seg_vida = 99
         let mr_relat.seg_vcl = 99

         open cbdbsr123023 using  mr_relat.prtbnfgrpcod
         foreach cbdbsr123023 into l_criterio, l_crttip

             if l_crttip = "C" then
                let mr_relat.seg_vida = 1
                let mr_relat.seg_vcl = 1
                continue foreach
             end if

             call bdbsr123_criterios(l_criterio, mr_relat.atdprscod,
                                     mr_relat.seg_vida, mr_relat.seg_vcl)
                  returning mr_relat.vlr_crt, mr_relat.vlr_crt_max

             call ctd27g00_obter_criterios(1,l_criterio)
                  returning lr_ctd27g00.*

             let mr_relat.bnfcrtdes = lr_ctd27g00.bnfcrtdes

             let mr_relat.bnfcrtcod = l_criterio
             output to report bdbsr123_resumo(0, mr_relat.*, m_arq1, m_arq2)

         end foreach

         if sqlca.sqlcode = notfound then
            let m_curr = current
            display "[", m_curr, "] Criterios nao cadastrado para o grupo: ",
                    mr_relat.prtbnfgrpcod," Prestador= ", mr_relat.atdprscod
            continue foreach
         end if

         #### Como melhorar a premiacao
         call bdbsr123_melhorar(mr_relat.atdprscod, mr_relat.prtbnfgrpcod)

         ##Obtem dados do criterio de seguro vida
         declare cbdbsr123012 cursor for
            select unique srrnom, seg_vida from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and seg_vida in (0,1)
                 order by srrnom

         foreach cbdbsr123012 into mr_relat.srrnom, lr_trab.seg_vida

                 let mr_relat.seg_vida = "SIM"
                 let mr_relat.bon_vida = "SIM"

                 if lr_trab.seg_vida = 0 then
                    let mr_relat.seg_vida = "NAO LOCALIZADO"
                    let mr_relat.bon_vida = "NAO"
                 end if

                 let mr_relat.bnfcrtcod = 1
                 output to report bdbsr123_detalhes(2, mr_relat.*)

         end foreach

         ##Obtem dados do criterio de seguro veiculo
         declare cbdbsr123008 cursor for
            select unique atdvclsgl, descricao, seg_vcl from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and seg_vcl in (0,1)
                 order by atdvclsgl

         foreach cbdbsr123008 into mr_relat.atdvclsgl,
                                   mr_relat.descricao,
                                   lr_trab.seg_vcl

                 let mr_relat.seg_vcl = "OK"
                 let mr_relat.bon_vcl = "SIM"

                 if lr_trab.seg_vcl = 0 then
                    let mr_relat.seg_vcl = "NAO LOCALIZADO"
                    let mr_relat.bon_vcl = "NAO"
                 end if

                 let mr_relat.bnfcrtcod = 2
                 output to report bdbsr123_detalhes(3, mr_relat.*)

         end foreach

         ##Obtem dados do criterio de disponibilidade manha/tarde
         declare cbdbsr123009 cursor for
            select unique atdvclsgl, descricao,
                          percindisp_m, disp_manha, sum(tot_disp_m),
                          percindisp_t, disp_tarde, sum(tot_disp_t)
                from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and disp_manha in(0,1)
                 and disp_tarde in(0,1)
               group by 1,2,3,4,6,7
               order by atdvclsgl

         foreach cbdbsr123009 into mr_relat.atdvclsgl,
                                   mr_relat.descricao,
                                   mr_relat.percindisp_m,
                                   lr_trab.disp_manha,
                                   mr_relat.tot_disp_m,
                                   mr_relat.percindisp_t,
                                   lr_trab.disp_tarde,
                                   mr_relat.tot_disp_t

                 let mr_relat.disp_manha = "SIM"
                 let mr_relat.disp_tarde = "SIM"

                 if lr_trab.disp_manha = 0 then
                    let mr_relat.disp_manha = "NAO"
                    let mr_relat.tot_disp_m = 0
                 end if

                 if lr_trab.disp_tarde = 0 then
                    let mr_relat.disp_tarde = "NAO"
                    let mr_relat.tot_disp_t = 0
                 end if

                 let mr_relat.bnfcrtcod = 3
                 output to report bdbsr123_detalhes(4, mr_relat.*)

         end foreach

         ##Obtem dados do criterio de satisfacao - SAC
         declare cbdbsr123010 cursor for
            select unique srrnom, numrec, satisf, percsatisf,
                          vlr_satisf, sum(tot_satisf)
                from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and satisf in (0,1)
                 group by 1,2,3,4,5
                 order by srrnom

         foreach cbdbsr123010 into mr_relat.srrnom,
                                   mr_relat.numrec,
                                   mr_relat.satisf,
                                   mr_relat.percsatisf,
                                   mr_relat.vlr_satisf,
                                   mr_relat.tot_satisf

                 let mr_relat.bnfcrtcod = 5
                 output to report bdbsr123_detalhes(5, mr_relat.*)

         end foreach

         ##Obtem dados do criterio de pontualidade
         declare cbdbsr123011 cursor for
            select srrcoddig, srrnom, sum(vlr_pontual)
                from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and pontual in (0,1)
                 group by 1,2
                 order by srrnom

         foreach cbdbsr123011 into mr_relat.srrcoddig,
                                   mr_relat.srrnom,
                                   mr_relat.vlr_pontual

                 let mr_relat.perc_pontual = 0
                 open cbdbsr123033 using mr_relat.atdprscod,
                                         mr_relat.prtbnfgrpcod,
                                         mr_relat.srrcoddig
                 fetch cbdbsr123033 into mr_relat.perc_pontual
                 close cbdbsr123033

                 let mr_relat.bnfcrtcod = 6
                 output to report bdbsr123_detalhes(6, mr_relat.*)

         end foreach

         ##Obtem dados do criterio de resolubilidade - RE
         declare cbdbsr123022 cursor for
            select srrcoddig, srrnom, sum(numret_res), sum(percresolub),
                                      sum(tot_resolub)
                from work:temp_bonif
               where atdprscod = mr_relat.atdprscod
                 and prtbnfgrpcod = mr_relat.prtbnfgrpcod
                 and resolub in (0,1)
                 group by 1,2
                 order by 2

         foreach cbdbsr123022 into mr_relat.srrcoddig,
                                   mr_relat.srrnom,
                                   mr_relat.numret_res,
                                   mr_relat.percresolub,
                                   mr_relat.tot_resolub

                 open cbdbsr123036 using mr_relat.atdprscod,
                                         mr_relat.prtbnfgrpcod,
                                         mr_relat.srrcoddig

                 let mr_relat.vlr_resolub = 0
                 fetch cbdbsr123036 into mr_relat.vlr_resolub
                 close cbdbsr123036

                 let mr_relat.bnfcrtcod = 7
                 output to report bdbsr123_detalhes(7, mr_relat.*)

         end foreach

         finish report bdbsr123_resumo
         finish report bdbsr123_detalhes

         ##finish report bdbsr123_email

         ##
         #let mr_relat.maides = "sergio.burini@portoseguro.com.br"

         #let mr_relat.maides = 'sergio.burini@correioporto,marcilio.braz@correioporto'

         let m_assunto = "Bonificacao Adicional por Desempenho - ",
                         mr_relat.atdprscod using "<<<<<<", " em ",
                         mr_relat.dataini using "mm/yyyy"



         ### RODOLFO MASSINI - INICIO
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013

         #let m_comando = ' cat "', m_nomearq1 clipped, '" | send_email.sh ',
         #                ' -sys  TESTE_INFO',
         #                ' -r  ', m_remetente clipped,
         #                ' -a ', mr_relat.maides clipped,
         #                ' -cc welington.oliveira@correioporto,ronald.santos@correioporto,edi.moreira@correioporto,everton.lima@correioporto,wiliam.garcia@correioporto,sergio.burini@correioporto,marcilio.braz@correioporto,orlando.sangali@correioporto ',
         #                ' -s "', m_assunto clipped, '" ',
         #                ' -f  ', m_nomearq2 clipped,',',m_nomearq3 clipped
         #run m_comando returning m_retorno

         let lr_mail.idr = "TESTE INFO"
         let lr_mail.ass = m_assunto clipped
         let lr_mail.msg = m_nomearq1 clipped
         let lr_mail.rem = m_remetente clipped
         let lr_mail.des = mr_relat.maides clipped
         let lr_mail.ccp = "welington.oliveira@correioporto,ronald.santos@correioporto,edi.moreira@correioporto,everton.lima@correioporto,wiliam.garcia@correioporto,sergio.burini@correioporto,marcilio.braz@correioporto,orlando.sangali@correioporto"
         let lr_mail.tip = "text"

         let lr_anexo.anexo1 = m_nomearq2 clipped
         let lr_anexo.anexo1 = m_nomearq3 clipped

         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,lr_anexo.*)
         returning l_retorno

         let m_retorno = l_retorno

         ### RODOLFO MASSINI - FIM

         if m_retorno <> 0 then
            let m_erro = "Problemas ao enviar relatorio(BDSR123)"
            call errorlog(m_erro)
            let m_curr = current
            display "[", m_curr, "] bdbsr123 / ", m_erro clipped
         end if

 end foreach

 # ENVIO DE RELACAO DETALHADA PARA O PROTO SOCORRO
 let m_comando = 'cat ',m_patharq clipped, '/RDB*_dados.xls >', m_patharq clipped, '/RDBG00000.xls'
 run m_comando returning l_status

 if l_status <> 0 then
    let m_curr = current
    display "[", m_curr, "]Erro em ", m_comando
 end if

 let m_comando = 'gzip ',m_patharq clipped, '/RDBG00000.xls'
 run m_comando returning l_status

 if  l_status <> 0 then
     let m_curr = current
     display "[", m_curr, "] Erro em ", m_comando
 end if

 let m_assunto = "Relatorio de Bonificacao por desempenho no periodo: ",
                  lr_trab.dataini using "dd/mm/yyyy", " a ",
                  lr_trab.datafim using "dd/mm/yyyy" ," geral"

  let m_comando = m_patharq clipped, '/RDBG00000.xls.gz'

  #call ctx22g00_envia_email("BDBSR123", m_assunto, m_comando)
  #     returning m_retorno
  #
  #if m_retorno <> 0 then
  #   let m_erro = "Problemas ao enviar relatorio ", m_retorno, ' ', m_comando
  #   call errorlog(m_erro)
  #   display "bdbsr123 / ", m_erro clipped
  #else
  #   let m_comando = "rm ", m_patharq clipped,"/RDB*.xls"
  #
  #   if l_status <> 0 then
  #      display 'Erro em ', m_comando
  #   end if
  #
  #   let m_comando = "rm ", m_patharq clipped,"/RDB*.doc"
  #
  #   if l_status <> 0 then
  #      display 'Erro em ', m_comando
  #   end if
  #
  #   let m_comando = "rm ", m_patharq clipped,"/RDBG00000.*"
  #
  #   if l_status <> 0 then
  #      display 'Erro em ', m_comando
  #   end if
  #
  #end if


  database porto
  delete from datkgeral where grlchv = 'ULTSRVBONAUTO'

  call bdbsr123_envia_sms(2)

end function

#-------------------------------#
function bdbsr123_valor(l_valor)
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

#-----------------------------------------------------------------------------#
report bdbsr123_rel(lr_linha)
#-----------------------------------------------------------------------------#

define lr_linha        record
       prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra do Prestador
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom       like datksrr.srrnom          ## Nome do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,socvcltip       like datkveiculo.socvcltip      ## Tipo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seg_vida        smallint                        ## SIM / NAO
      ,seg_vcl         smallint                        ## SIM / NAO
      ,disp_manha      smallint                        ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_m        like dpakprfind.bnfvlr
      ,vlr_minper_m    like dpakprfind.bnfvlr
      ,disp_tarde      smallint                        ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,minper_t        like dpakprfind.bnfvlr
      ,vlr_minper_t    like dpakprfind.bnfvlr
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint                        ## SIM / NAO
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor Bonif total
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,msgseg_vida     char(100)                       ## Msg Quallificao Seguro
      ,msgseg_veic     char(100)                       ## Msg Quallificao Seguro
      ,msgdispmanha    char(100)                       ## Msg Disponibili Manha
      ,msgdisptarde    char(100)                       ## Msg Disponibili Tarde
      ,msgsatisfacao   char(100)                       ## Msg Quallificao Satif
      ,msgpontualidade char(100)                       ## Msg Quallificao Pont
      ,msgresolub      char(120)                       ## Msg Quallificao Pont
end record

output

   left   margin    00
   right  margin    00
   top    margin    00
   bottom margin    00
   page   length    02

order external by lr_linha.prtbnfgrpcod, lr_linha.atdprscod, lr_linha.srrcoddig,
                  lr_linha.atdvclsgl,    lr_linha.atdetpdat,
                  lr_linha.atdsrvano,    lr_linha.atdsrvnum,
                  lr_linha.socvcltip

format

  first page header
      print "Grupo", "	"
           ,"Prestador", "	"
           ,"Socorrista", "	"
           ,"Veiculo", "	"
           ,"Tipo.Veic", "	"
           ,"Data", "	"
           ,"Servico", "	";

      if lr_linha.seg_vida <> 99 then
         print "Seguro.Vida(1=Sim ou 0=Nao)", "	";
      end if

      if lr_linha.seg_vcl <> 99 then
         print "Seguro.Veic(1=Sim ou 0=Nao)", "	";
      end if

      if lr_linha.disp_manha <> 99 then
         print "Disp.Manha(1=Sim ou 0=Nao)", "	"
              ,"Total.Disp.Manha", "	";
      end if

      if lr_linha.disp_tarde <> 99 then
         print "Disp.Tarde(1=Sim ou 0=Nao)", "	"
              ,"Total.Disp.Tarde", "	";
      end if

      if lr_linha.satisf <> 99 then
         print "Satisf.Cliente(1=Sim ou 0=Nao)", "	"
              ,"Valor.Satisf.Cliente", "	";
      end if

      if lr_linha.pontual <> 99 then
         print "Pontualidade(1=Sim ou 0=Nao)", "	"
               ,"Valor.Pontualidade", "	";
      end if

      if lr_linha.resolub <> 99 then
         print "Resolub.Cliente(1=Sim ou 0=Nao)", "	"
              ,"Valor.Resolub.Socorr", "	";
      end if

      if lr_linha.seg_vida <> 99 or lr_linha.seg_vcl <> 99 then
         print "Situacao Seguro Socorrista/AUTO", "	";
      end if

      if lr_linha.disp_manha <> 99 then
         print "QRV Manha 6h as 10h (85% Exigidos)", "	";
      end if

      if lr_linha.disp_tarde <> 99 then
         print "QRV Tarde 17h as 20h (75% Exigidos)", "	";
      end if

      if lr_linha.satisf <> 99 then
         print "Reclamacao aceitavel 5 em mil (90 dias)", "	";
      end if

      if lr_linha.pontual <> 99 then
         print "QTR previsto X QTR Cumprido / Posicao QRU INI", "	";
      end if
      if lr_linha.resolub <> 99 then
         print "Msg.Resolubilidade","	";
      end if

      print column 01, " "

  on every row
      print lr_linha.prtbnfgrpcod,"	"
           ,lr_linha.atdprscod using "<<<<<<", " - ", lr_linha.nomgrr clipped, "	"
          ,lr_linha.srrcoddig using "<<<<<<", " - ", lr_linha.srrnom, "	"
          ,lr_linha.atdvclsgl, "	"
          ,lr_linha.socvcltip, "	"
          ,lr_linha.atdetpdat using "dd/mm/yyyy", "	"
          ,lr_linha.atdsrvorg using "&&","/",
           lr_linha.atdsrvnum using "&&&&&&&","-",
           lr_linha.atdsrvano using "&&", "	";

      if lr_linha.seg_vida <> 99 then
         print lr_linha.seg_vida, "	";
      end if

      if lr_linha.seg_vcl <> 99 then
	 print lr_linha.seg_vcl,  "	";
      end if

      if lr_linha.disp_manha <> 99 then
	 print lr_linha.disp_manha, "	"
	      ,lr_linha.tot_disp_m, "	";
      end if

      if lr_linha.disp_tarde <> 99 then
	 print lr_linha.disp_tarde, "	"
	      ,lr_linha.tot_disp_t, "	";
      end if

      if lr_linha.satisf <> 99 then
	 print lr_linha.satisf, "	"
	      ,lr_linha.vlr_satisf, "	";
      end if

      if lr_linha.pontual <> 99 then
	 print lr_linha.pontual,"	"
	       ,lr_linha.vlr_pontual, "	";
      end if

      if lr_linha.resolub <> 99 then
	 print lr_linha.resolub,"	"
	      ,lr_linha.vlr_resolub, "	";
      end if

      if lr_linha.seg_vida <> 99 then
         print lr_linha.msgseg_vida clipped,"/",lr_linha.msgseg_veic,"	";
      end if

      if lr_linha.disp_manha <> 99 then
         print lr_linha.msgdispmanha,"	";
      end if

      if lr_linha.disp_tarde <> 99 then
         print lr_linha.msgdisptarde,"	";
      end if

      if lr_linha.satisf <> 99 then
         print lr_linha.msgsatisfacao,"	";
      end if

      if lr_linha.pontual <> 99 then
         print lr_linha.msgpontualidade,"	";
      end if

      if lr_linha.resolub <> 99 then
         print lr_linha.msgresolub,"	";
      end if

      print column 01, " "

end report

#----------------------------#
 function bdbsr123_cria_tab()
#----------------------------#

   database work

   initialize m_ultpstbon to null

    database work

    #whenever error continue
    #drop table temp_bonif
    #whenever error stop

    whenever error continue
    select 1 from temp_bonif
    whenever error stop

    if  sqlca.sqlcode = -206 then

        let m_curr = current
        display "[", m_curr, "] CRIANDO TABELA."

        create table temp_bonif(
            atdprscod       dec(6,0),
            nomgrr          char(20),
            maides          char(100),
            srrcoddig       dec(8,0),
            srrnom          char(30),
            socvclcod       dec(4,0),
            socvcltip       smallint,
            atdvclsgl       char(5),
            descricao       char(30),
            atdetpdat       date,
            atdsrvorg       smallint,
            atdsrvnum       dec(10,0),
            atdsrvano       dec(2,0),
            seg_vida        smallint,
            seg_vcl         smallint,
            disp_manha      smallint,
            vlr_dispmanha   dec(12,2),
            percindisp_m    integer, ##dec(8,4),
            tot_disp_m      dec(12,2),
            minper_m        dec(8,4),
            vlr_minper_m    dec(12,2),
            disp_tarde      smallint,
            vlr_disptarde   dec(12,2),
            percindisp_t    integer, ##dec(8,4),
            tot_disp_t      dec(12,2),
            minper_t        dec(8,4),
            vlr_minper_t    dec(12,2),
            satisf          smallint,
            numsrv          integer,
            numrec          integer,
            percsatisf      dec(8,4),
            vlr_satisf      dec(12,2),
            tot_satisf      dec(12,2),
            vlr_max_satisf  dec(12,2),
            pontual         smallint,
            perc_pontual    integer, ##dec(8,4),
            vlr_pontual     dec(12,2),
            tot_pontual     dec(12,2),
            tot_max_pontual dec(12,2),
            resolub         smallint,
            numsrv_res      integer,
            numret_res      integer,
            percresolub     integer, ##dec(8,4),
            vlr_resolub     dec(12,2),
            tot_resolub     dec(12,2),
            dataini         date,
            datafim         date,
            msgdispmanha    char(100),
            msgdisptarde    char(100),
            msgsatisfacao   char(100),
            msgseg_vida     char(100),
            msgseg_veic     char(100),
            msgpontualidade char(100),
            msgresolub      char(120),
            prtbnfgrpcod    integer,
            segvida_c       char(1),
            segvcl_c        char(1),
            satisf_c        char(1),
            dispm_c         char(1),
            dispt_c         char(1),
            pontual_c       char(1),
            resolub_c       char(1)) extent size 16000 next size 8000 lock mode page

         create index bonif001_temp on temp_bonif (atdprscod, srrcoddig)
         create index bonif002_temp on temp_bonif (atdprscod, srrcoddig,pontual)
         create index bonif003_temp on temp_bonif (atdprscod, seg_vida, seg_vcl,
                                   satisf, pontual, disp_manha,
                                   disp_tarde, resolub)
         create index bonif004_temp on temp_bonif (atdprscod, pontual, disp_manha,
                                   disp_tarde, satisf, resolub)
         create index bonif005_temp on temp_bonif (atdprscod, atdvclsgl, disp_manha)
         create index bonif006_temp on temp_bonif (atdprscod, atdvclsgl, disp_tarde)
         create index bonif007_temp on temp_bonif (atdprscod, satisf)
         create index bonif008_temp on temp_bonif (atdprscod, seg_vida, seg_vcl, satisf)
         create index bonif009_temp on temp_bonif (atdprscod, srrcoddig, satisf)
         create index bonif010_temp on temp_bonif (atdprscod, prtbnfgrpcod, socvcltip)

         database porto

         whenever error continue
          delete from datkgeral
           where grlchv = 'ULTSRVBONRE'
         whenever error stop

         insert into datkgeral values ('ULTSRVBONRE', 0, today, current, 1, 4577)


     else
        database porto

        let m_curr = current
        display "[", m_curr, "] TABLEA JAH CRIADA"

        whenever error continue
         select grlinf
           into m_ultpstbon
           from datkgeral
          where grlchv = 'ULTSRVBONAUTO'
        whenever error stop

        let m_curr = current
        display "[", m_curr, "] ULTIMO PRESTADOR: ", m_ultpstbon

        database work
        delete from temp_bonif where atdprscod > m_ultpstbon

    end if

    if  m_ultpstbon is null or m_ultpstbon = " " then
        let m_ultpstbon = 0
    end if

    database porto
    set isolation to dirty read

end function

#------------------------------------------------#
 report bdbsr123_resumo(lr_relat, l_arq1, l_arq2)
#------------------------------------------------#

define lr_relat        record
       ordem           integer
      ,bnfcrtcod   like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes   like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,tot_bonif       dec(12,2)
      ,tot_max_bonif   dec(12,2)
      ,vlr_crt         dec(12,2)
      ,vlr_crt_max     dec(12,2)
      ,datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom       like datksrr.srrnom          ## Nome do Socorrista
      ,cgccpfnum       like datksrr.cgccpfnum          ## CPF do Socorrista
      ,cgccpfdig       like datksrr.cgccpfdig          ## Dig. CPF do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          smallint                        ## SIM / NAO
      ,seg_vida        char(3)                         ## SIM / NAO
      ,bon_vida        char(20)                        ## SIM / NAO
      ,seg_vcl         char(3)                         ## SIM / NAO
      ,bon_vcl         char(3)                         ## SIM / NAO
      ,disp_manha      char(3)                         ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr
      ,disp_tarde      char(3)                         ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint                        ## SIM / NAO
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor bonif total
      ,asitipcod       like datmservico.asitipcod      ## Cod assistencia srv
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,segvida_c       char(1)
      ,segvcl_c        char(1)
      ,satisf_c        char(1)
      ,dispm_c         char(1)
      ,dispt_c         char(1)
      ,pontual_c       char(1)
      ,resolub_c       char(1)
end record

define l_arq1, l_arq2 char(100)

   output
      left   margin  000
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  066

   order by lr_relat.ordem, lr_relat.bnfcrtcod

   format
      page header
         skip 2 lines

      first page header

            print column 01, "Prezado Colaborador"
            skip 2 lines
            #print column 01, "ATENÇÃO: ESTA BONIFICAÇÃO FOI GERADA AINDA NO MODELO ANTIGO, EM RAZÃO DO NOVO MODELO NÃO TER SIDO FINALIZADO A TEMPO."
            #skip 2 lines
            print column 01,
                  "Em ", mr_relat.mes_extenso clipped, "/",
                  lr_relat.datafim using "yyyy",
                  ", sua bonificacao adicional por desempenho de ",
                  lr_relat.prtbnfgrpdes clipped, " sera de R$ ",
                  lr_relat.tot_bonif using "<<<,<<&.&&",
                  ", mas poderia ter sido R$ ",
                  lr_relat.tot_max_bonif using "<<<,<<&.&&","."



      before group of lr_relat.ordem

         if lr_relat.ordem = 0 then
            skip 2 lines
            print column 15, "TOTAL RECEBIDO POR CRITERIO"
            print column 01, "=============================================================="
            skip 1 lines
            print column 01, "CRITERIO",
                  column 30, "VALOR RECEBIDO",
                  column 50, "VALOR MAXIMO"
            skip 1 lines
         end if

         if lr_relat.ordem = 1 then
            print column 01, "=============================================================="
            skip 2 lines
            print column 15, "COMO MELHORAR SUA PREMIACAO ? "
            skip 1 lines
         end if

      on every row
         if lr_relat.ordem = 0 then
            print column 01, lr_relat.bnfcrtdes clipped,
                  column 30, lr_relat.vlr_crt using "###,##&.&&",
                  column 50, lr_relat.vlr_crt_max using "###,##&.&&"
         end if

         if lr_relat.ordem = 1 then
            print column 01, lr_relat.msg clipped
            skip 1 line
         end if

      on last row

            skip 1 line

            print column 15, "ATENCAO !!!"

            skip 2 line

            print column 01, "- Encaminhe uma copia desta mensagem ",
                             "com a nota fiscal;"
            skip 1 line
            print column 01, '- Leia o arquivo "', l_arq1 clipped, '" anexo;'
            skip 1 line
            print column 01, '- A base de dados da bonificacao ',
                             'esta no arquivo "', l_arq2 clipped, '" anexo;'
            skip 2 line

            print column 01, "EM CASO DE DUVIDAS, ENTRE EM CONTATO COM ",
                             "WILIAM GARCIA (11 3803-2437)."
            skip 2 line
            print column 01, "Atentamente"
            print column 01, "PORTO SOCORRO - V1.7"
            skip 2 line

end report

report bdbsr123_detalhes(lr_relat)

define lr_relat        record
       ordem           integer
      ,bnfcrtcod       like dpakprtbnfcrt.bnfcrtcod
      ,bnfcrtdes       like dpakprtbnfcrt.bnfcrtdes
      ,mes_extenso     char(20)
      ,tot_bonif       dec(12,2)
      ,tot_max_bonif   dec(12,2)
      ,vlr_crt         dec(12,2)
      ,vlr_crt_max     dec(12,2)
      ,datastr         char(10)                        ## Data
      ,dataini         date                            ## Data Inicial
      ,datafim         date                            ## Data Final
      ,datavig         date                            ## Data Vigencia Seguros
      ,atdprscod       like datmservico.atdprscod      ## Codigo do Prestador
      ,nomgrr          like dpaksocor.nomgrr           ## Nome de Guerra
      ,maides          like dpaksocor.maides           ## E_mail do prestador
      ,srrcoddig       like datmsrvacp.srrcoddig       ## Codigo do Socorrista
      ,srrnom       like datksrr.srrnom          ## Nome do Socorrista
      ,cgccpfnum       like datksrr.cgccpfnum          ## CPF do Socorrista
      ,cgccpfdig       like datksrr.cgccpfdig          ## Dig. CPF do Socorrista
      ,socvclcod       like datkveiculo.socvclcod      ## Codigo do Veiculo
      ,atdvclsgl       like datkveiculo.atdvclsgl      ## Sigla do Veiculo
      ,descricao       char(30)                        ## Descricao tipo veic
      ,mdtcod          like datkveiculo.mdtcod         ## Codigo MDT do veiculo
      ,atdetpdat       like datmsrvacp.atdetpdat       ## Data ult etapa do servico
      ,atdsrvorg       like datmservico.atdsrvorg      ## Origem do Servico
      ,atdsrvnum       like datmservico.atdsrvnum      ## Numero do Servico
      ,atdsrvano       like datmservico.atdsrvano      ## Ano do Servico
      ,seguro          smallint                        ## SIM / NAO
      ,seg_vida        char(3)                         ## SIM / NAO
      ,bon_vida        char(20)                        ## SIM / NAO
      ,seg_vcl         char(3)                         ## SIM / NAO
      ,bon_vcl         char(3)                         ## SIM / NAO
      ,disp_manha      char(3)                         ## SIM / NAO
      ,percindisp_m    dec(8,2)
      ,vlr_dispmanha   like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,tot_disp_m      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,disp_tarde      char(3)                         ## SIM / NAO
      ,percindisp_t    dec(8,2)
      ,vlr_disptarde   like dpakprfind.bnfvlr          ## Valor bonif disp tarde
      ,tot_disp_t      like dpakprfind.bnfvlr          ## Valor bonif disp manha
      ,satisf          smallint                        ## SIM / NAO
      ,numsrv          integer
      ,numrec          integer
      ,percsatisf      dec(8,4)
      ,vlr_satisf      like dpakprfind.bnfvlr          ## Valor bonif satisfacao
      ,tot_satisf      like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,vlr_max_satisf  like dpakprfind.bnfvlr          ## total bonif satisfacao
      ,pontual         smallint                        ## SIM / NAO
      ,perc_pontual    like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,vlr_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_pontual     like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,tot_max_pontual like dpakprfind.bnfvlr          ## Valor bonif pontual
      ,resolub         smallint                        ## SIM / NAO
      ,numsrv_res      integer
      ,numret_res      integer
      ,percresolub     dec(8,4)
      ,vlr_resolub     dec(12,2)
      ,tot_resolub     dec(12,2)
      ,vlr_bonif       like dpakprfind.bnfvlr          ## Valor bonif total
      ,asitipcod       like datmservico.asitipcod      ## Cod assistencia srv
      ,msg             char(300)                       ## msg de como melhorar
      ,prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod
      ,prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes
      ,segvida_c       char(1)
      ,segvcl_c        char(1)
      ,satisf_c        char(1)
      ,dispm_c         char(1)
      ,dispt_c         char(1)
      ,pontual_c       char(1)
      ,resolub_c       char(1)
end record

   output
      left   margin  000
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  066

   order by lr_relat.ordem

   format
      page header
         skip 2 lines

      first page header

            skip 1 lines
            print column 01, "DETALHAMENTO DA BONIFICACAO DE ",
                             lr_relat.mes_extenso clipped, "/",
                             lr_relat.datafim using "yyyy"

      before group of lr_relat.ordem

         if lr_relat.ordem = 2 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "SEGURO DE VIDA DOS SOCORRISTAS"
            print column 01, "SOCORRISTA",
                  column 50, "SEGURO",
                  column 60, "BONIFICOU"
         end if

         if lr_relat.ordem = 3 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "SEGURO DAS VIATURAS"
            print column 01, "VIATURA",
                  column 50, "SEGURO",
                  column 60, "BONIFICOU"
         end if

         if lr_relat.ordem = 4 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "DISPONIBILIDADE DAS VIATURAS"
            print column 01, "VIATURA",
                  column 25, "|| %MANHA",
                  column 35, "BON?",
                  column 43, "VLR REC",
                  column 53, "||   %TARDE",
                  column 65, "BON?",
                  column 72, "VLR REC"
         end if

         if lr_relat.ordem = 5 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "SATISFACAO DOS CLIENTES"
            print column 01, "SOCORRISTA",
                  column 18, "QTD",
                  column 30, "INDICE",
                  column 45, "FAIXA",
                  column 55, "VLR APURADO"
            print column 18, "RECL",
                  column 30, "EM MIL",
                  column 43, "ALCANCADA"
         end if

         if lr_relat.ordem = 6 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "PONTUALIDADE DOS SOCORRISTAS"
            print column 01, "SOCORRISTA",
                  column 46, "% PONTUALIDADE",
                  column 61, "VALOR APURADO"
         end if

         if lr_relat.ordem = 7 then
            skip 1 lines
            print column 01, "================================================================================"
            print column 20, "RESOLUBILIDADE DOS SOCORRISTAS"
            print column 01, "SOCORRISTA",
                  column 18, "QTD",
                  column 30, "INDICE",
                  column 43, "FAIXA",
                  column 55, "VLR APURADO"
            print column 15, "RETORNOS",
                  column 40, "BONIFICACAO"
         end if

      on every row

         if lr_relat.ordem = 2 then
            print column 01, lr_relat.srrnom clipped,
                  column 50, lr_relat.seg_vida,
                  column 60, lr_relat.bon_vida
         end if

         if lr_relat.ordem = 3 then
            print column 01, lr_relat.atdvclsgl clipped,"-",lr_relat.descricao,
                  column 50, lr_relat.seg_vcl,
                  column 60, lr_relat.bon_vcl
         end if

         if lr_relat.ordem = 4 then

            print column 01, lr_relat.atdvclsgl clipped, "-",
                             lr_relat.descricao[1,15],
                  column 25, "|| ", lr_relat.percindisp_m using "##&.&&",
                  column 35, lr_relat.disp_manha,
                  column 40, lr_relat.tot_disp_m using "###,##&.&&",
                  column 53, "||   ", lr_relat.percindisp_t using "##&.&&",
                  column 65, lr_relat.disp_tarde,
                  column 69, lr_relat.tot_disp_t using "###,##&.&&"

         end if

         if lr_relat.ordem = 5 then
            print column 01, lr_relat.srrnom[1,13],
                  column 15, lr_relat.numrec using "###&",
                  column 30, (lr_relat.percsatisf*10) using "##&.&&",
                  column 40, lr_relat.vlr_satisf using "###,##&.&&",
                  column 57, lr_relat.tot_satisf using "###,##&.&&"
         end if

         if lr_relat.ordem = 6 then
            print column 01, lr_relat.srrnom clipped,
                  column 52, lr_relat.perc_pontual using "##&.&&",
                  column 65, lr_relat.vlr_pontual using "###,##&.&&"
         end if

         if lr_relat.ordem = 7 then
            print column 01, lr_relat.srrnom[1,13],
                  column 15, lr_relat.numret_res using "###&",
                  column 30, lr_relat.percresolub using "##&.&&",
                  column 40, lr_relat.vlr_resolub using "###,##&.&&",
                  column 57, lr_relat.tot_resolub using "###,##&.&&"
         end if

end report

function bdbsr123_criterios(l_criterio, l_atdprscod,
                            l_seg_vida, l_seg_vcl)

   define l_criterio  like dpakprtbnfgrpcrt.bnfcrtcod,
          l_atdprscod like datmservico.atdprscod,
          l_seg_vida  smallint,
          l_seg_vcl   smallint,
          l_total     dec(12,2),
          l_total_max dec(12,2),
          l_sql       char(200),
          l_select1   char(200),
          l_select2   char(200),
          l_campo1    char(20),
          l_campo2    char(20),
          l_condicao1 char(20),
          l_condicao2 char(20)

   let l_total = 0
   let l_total_max = 0
   let l_sql = null
   let l_select1 = null
   let l_select2 = null
   let l_campo1 = null
   let l_campo2 = null
   let l_condicao1 = null
   let l_condicao2 = null

   case l_criterio
      when 1
      when 2
      when 3
         let l_campo1 ='tot_disp_m'
         let l_condicao1 ='disp_manha = 1'

         let l_campo2 ='vlr_minper_m'
         let l_condicao2 ='disp_manha <> 99 '
      when 4
         let l_campo1 ='tot_disp_t'
         let l_condicao1 ='disp_tarde = 1'

         let l_campo2 ='vlr_minper_t'
         let l_condicao2 ='disp_tarde <> 99'
      when 5
         call bdbsr123_obter_tot_satisf(l_atdprscod,
                                        mr_relat.prtbnfgrpcod,
                                        l_seg_vida,
                                        l_seg_vcl)
              returning l_total, l_total_max
         return l_total, l_total_max
      when 6
         let l_campo1 ='vlr_pontual'
         let l_condicao1 ='pontual = 1 '

         let l_campo2 ='tot_max_pontual'
         let l_condicao2 ='pontual <> 99 '
      when 7
         let l_campo1 ='tot_resolub'
         let l_condicao1 ='resolub = 1 '

         let l_campo2 ='tot_resolub'
         let l_condicao2 ='resolub <> 99 '
      otherwise
         return l_total, l_total_max
   end case

   let l_select1 = " select  sum(", l_campo1 clipped, ")"
   let l_select2 = " select  sum(", l_campo2 clipped, ")"

   let l_sql = l_select1 clipped
	       ,"  from work:temp_bonif "
	       ," where atdprscod = ? "
               ," and seg_vida = ", l_seg_vida
               ," and seg_vcl = ", l_seg_vcl
               ," and ", l_condicao1

   prepare pbdbsr123015  from l_sql
   declare cbdbsr123015  cursor for pbdbsr123015
   open cbdbsr123015 using l_atdprscod
   fetch cbdbsr123015 into l_total
   close cbdbsr123015

   let l_sql = l_select2 clipped
        ,"  from work:temp_bonif "
        ," where atdprscod = ? "
               ," and ", l_condicao2

   prepare pbdbsr123016  from l_sql
   declare cbdbsr123016  cursor for pbdbsr123016
   open cbdbsr123016 using l_atdprscod
   fetch cbdbsr123016 into l_total_max
   close cbdbsr123016

   if l_total is null then
      let l_total = 0
   end if

   if l_total_max is null then
      let l_total_max = 0
   end if

   return l_total, l_total_max

end function

function bdbsr123_melhorar(l_atdprscod, l_prtbnfgrpcod)

   define l_atdprscod       like datmservico.atdprscod,
          l_prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod,
          l_valor           dec(12,2),
          l_qtd_srv         integer,
          l_minper_m        like dpakprfind.bnfvlr,
          l_vlr_minper_m    like dpakprfind.bnfvlr,
          l_minper_t        like dpakprfind.bnfvlr,
          l_vlr_minper_t    like dpakprfind.bnfvlr,
          l_perc_pontual    like dpakprfind.bnfvlr,
          l_vlr_pontual     like dpakprfind.bnfvlr,
          l_tot_satisf      like dpakprfind.bnfvlr,
          l_tot_srv         integer

   define lr_ctd27g02 record
        ret         smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg         char(100),
        fxavlr      like dpakbnfvlrfxa.fxavlr
   end record

   initialize lr_ctd27g02.* to null

   let l_valor = 0
   let l_qtd_srv = 0
   let l_minper_m = 0
   let l_minper_t = 0
   let l_vlr_minper_m = 0
   let l_vlr_minper_t = 0
   let l_perc_pontual = 0
   let l_vlr_pontual  = 0
   let l_tot_satisf   = 0
   let l_tot_srv      = 0

   ##Obtem socorrista sem seguro de vida
   declare cbdbsr123017 cursor for
       select srrcoddig, srrnom, sum(tot_max_pontual+vlr_minper_m+vlr_minper_t)
         from work:temp_bonif
        where atdprscod = l_atdprscod
          and prtbnfgrpcod = l_prtbnfgrpcod
          and seg_vida = 0
        group by srrcoddig, srrnom
        order by srrnom

   let mr_relat.srrnom = null
   foreach cbdbsr123017 into mr_relat.srrcoddig, mr_relat.srrnom, l_valor

           let l_tot_satisf = 0
           open cbdbsr123026 using l_atdprscod, l_prtbnfgrpcod,
                                   mr_relat.srrcoddig
           fetch cbdbsr123026 into l_tot_satisf
           let l_valor = l_valor + l_tot_satisf
           close cbdbsr123026

           let mr_relat.msg = "- O socorrista ", mr_relat.srrnom clipped,
                              " esta sem seguro. Por esse motivo, voce",
                              " deixou de ganhar R$ ",
                                l_valor using "<<<,<<&.&&", "."

           let mr_relat.bnfcrtcod = 1
           output to report bdbsr123_resumo(1, mr_relat.*,m_arq1,m_arq2)
   end foreach

   ##Obtem viatura sem seguro
   declare cbdbsr123035 cursor for
       select atdvclsgl, sum(tot_max_pontual+vlr_minper_m+vlr_minper_t)
         from work:temp_bonif
        where atdprscod = l_atdprscod
          and prtbnfgrpcod = l_prtbnfgrpcod
          and seg_vcl = 0
        group by atdvclsgl
        order by atdvclsgl

   foreach cbdbsr123035 into mr_relat.atdvclsgl, l_valor

           let mr_relat.msg = "- A viatura ", mr_relat.atdvclsgl clipped,
                              " esta sem seguro. Por esse motivo os servicos",
                              " realizados com ela nao serao bonificados. "

           let mr_relat.bnfcrtcod = 2
           output to report bdbsr123_resumo(1, mr_relat.*,m_arq1,m_arq2)

   end foreach

   ##Obtem a falta de disponibilidade das viaturas
   declare cbdbsr123018 cursor for
       select unique atdvclsgl, disp_manha, minper_m, sum(vlr_minper_m),
                                disp_tarde, minper_t, sum(vlr_minper_t)
         from work:temp_bonif
        where atdprscod = l_atdprscod
          and prtbnfgrpcod = l_prtbnfgrpcod
          and (disp_manha = 0 or disp_tarde = 0)
        group by 1,2,3,5,6
        order by atdvclsgl

   let mr_relat.atdvclsgl = null
   let mr_relat.disp_manha = null
   let mr_relat.disp_tarde = null

   foreach cbdbsr123018 into mr_relat.atdvclsgl,
                             mr_relat.disp_manha, l_minper_m, l_vlr_minper_m,
                             mr_relat.disp_tarde, l_minper_t, l_vlr_minper_t

           if mr_relat.disp_manha = 0 and l_minper_m > 0 then

              ##obter a qtd de servicos realizados

              let mr_relat.msg = "- Aumente a disponibilidade da viatura ",
                                mr_relat.atdvclsgl clipped, " pela manha.",
                                " Se tivesse atingido ",
                                l_minper_m using "<<&.&&",
                                "% voce teria recebido R$ ",
                                l_vlr_minper_m using "<<<,<<&.&&", " a mais."
              let mr_relat.bnfcrtcod = 3
              output to report bdbsr123_resumo(1, mr_relat.*,m_arq1,m_arq2)
           end if

           if mr_relat.disp_tarde = 0 and l_minper_t > 0 then

              let mr_relat.msg = "- Aumente a disponibilidade da viatura ",
                                mr_relat.atdvclsgl clipped, " pela tarde.",
                                " Se tivesse atingido ",
                                l_minper_t using "<<&.&&",
                                "% voce teria recebido R$ ",
                                l_vlr_minper_t using "<<<,<<&.&&", " a mais."
              let mr_relat.bnfcrtcod = 4
              output to report bdbsr123_resumo(1, mr_relat.*,m_arq1,m_arq2)
           end if

   end foreach

   ##Obtem a falta de pontualidade dos socorristas.
   declare cbdbsr123019 cursor for
       select srrcoddig, srrnom, sum(tot_max_pontual)
         from work:temp_bonif
        where atdprscod = l_atdprscod
          and prtbnfgrpcod = l_prtbnfgrpcod
          and pontual = 0
        group by 1,2
        order by srrnom

   let mr_relat.srrnom = null
   foreach cbdbsr123019 into mr_relat.srrcoddig, mr_relat.srrnom, l_valor

           let l_perc_pontual = 0
           open cbdbsr123033 using l_atdprscod, l_prtbnfgrpcod,
                                   mr_relat.srrcoddig
           fetch cbdbsr123033 into l_perc_pontual
           close cbdbsr123033

           let mr_relat.msg = "- O socorrista ", mr_relat.srrnom clipped,
                              " foi pontual em ",
                              l_perc_pontual using "<<&.&&","% dos servicos.",
                              " Se tivesse cumprido a previsao de todos os",
                              " servicos, voce teria recebido R$ ",
                              l_valor using "<<<,<<&.&&"," a mais."

           let mr_relat.bnfcrtcod = 6
           output to report bdbsr123_resumo(1, mr_relat.*,m_arq1,m_arq2)
   end foreach

end function

function bdbsr123_obter_tot_satisf(l_atdprscod, l_prtbnfgrpcod,
                                   l_seg_vida, l_seg_vcl)

   define l_atdprscod       like datmservico.atdprscod,
          l_prtbnfgrpcod    like dpakbnfgrppar.prtbnfgrpcod,
          l_srrnom          like datksrr.srrnom,
          l_seg_vida        smallint,
          l_seg_vcl         smallint,
          l_tot_satisf      dec(12,2),
          l_tot_max_satisf  dec(12,2),
          l_vlr_satisf      dec(12,2)

   let l_vlr_satisf = 0
   let l_tot_satisf = 0
   let l_tot_max_satisf = 0
   let l_srrnom = null

   ##Obter o total maximo de satisfacao por socorrista
   open cbdbsr123024 using l_atdprscod, l_prtbnfgrpcod
   foreach cbdbsr123024 into l_srrnom, l_vlr_satisf
           let l_tot_max_satisf = l_tot_max_satisf + l_vlr_satisf
   end foreach
   close cbdbsr123024

   ##Obter o total de satisfacao por socorrista
   open cbdbsr123025 using l_atdprscod, l_prtbnfgrpcod, l_seg_vida, l_seg_vcl
   foreach cbdbsr123025 into l_srrnom, l_vlr_satisf
           let l_tot_satisf = l_tot_satisf + l_vlr_satisf
   end foreach
   close cbdbsr123025

   return l_tot_satisf, l_tot_max_satisf

end function

function bdbsr110_insere_bnf(l_atdprscod, l_prtbnfgrpcod,
                             l_seg_vida, l_seg_vcl)

   define l_atdprscod        like datmservico.atdprscod,
          l_prtbnfgrpcod     like dpakbnfgrppar.prtbnfgrpcod,
          l_seg_vida        smallint,
          l_seg_vcl         smallint,
          l_tot_srv_prt     integer,
          l_tot_cri_avl     integer,
          l_tot_srv_avl     integer,
          l_qtd_bnf         integer,
          l_vlr_bonif       dec(12,2),
          l_tot_bonif       dec(12,2),
          l_total           dec(12,2),
          l_total_max       dec(12,2),
          l_prtbnfcod       integer,
          l_data            date,
          l_hora            datetime hour to second,
          l_campo           array[7] of char(10),
          l_ind             smallint,
          l_sql             char(500)

   let l_data = null
   let l_hora = null

   let l_ind = null
   let l_sql = null

   let l_tot_srv_prt = 0
   ##Qtd de servicos do prestador
   open cbdbsr123028 using l_atdprscod, l_prtbnfgrpcod
   fetch cbdbsr123028 into l_tot_srv_prt
   close cbdbsr123028

   let l_tot_cri_avl = 0
   ##Qtd de criterios que foram avaliados
   open cbdbsr123029 using l_prtbnfgrpcod
   fetch cbdbsr123029 into l_tot_cri_avl
   close cbdbsr123029

   ##Qtd de bonificacoes avaliadas
   let l_qtd_bnf = l_tot_srv_prt * l_tot_cri_avl

   let l_tot_srv_avl = 0

   let l_campo[1] = "seg_vida"
   let l_campo[2] = "seg_vcl"
   let l_campo[3] = "satisf"
   let l_campo[4] = "disp_manha"
   let l_campo[5] = "disp_tarde"
   let l_campo[6] = "pontual"
   let l_campo[7] = "resolub"

   for l_ind = 1 to 7

       ##Qtd de servicos bonificados por criterio
       let l_sql = " select count(*) from work:temp_bonif "
                   ," where atdprscod = ", l_atdprscod
                   ,"   and prtbnfgrpcod = ", l_prtbnfgrpcod
	           ,"   and ", l_campo[l_ind] clipped, " = 1"

       let m_curr = current
       display "[", m_curr, "] CORRECAO = ", l_sql

       prepare pbdbsr123030 from l_sql
       declare cbdbsr123030 cursor for pbdbsr123030

       let l_total = 0
       open cbdbsr123030
       fetch cbdbsr123030 into l_total
       close cbdbsr123030

       if l_total is null then
          let l_total = 0
       end if

       let l_tot_srv_avl = l_tot_srv_avl + l_total

   end for

   let l_tot_bonif = 0
   open cbdbsr123013 using l_atdprscod, l_prtbnfgrpcod,
                           l_seg_vida,
                           l_seg_vcl
   fetch cbdbsr123013 into l_tot_bonif
   close cbdbsr123013

   if l_tot_bonif is null then
      let l_tot_bonif = 0
   end if

   let l_total = 0
   let l_total_max = 0

   ## Obter valor total da satisfacao
   call bdbsr123_obter_tot_satisf(l_atdprscod, l_prtbnfgrpcod,
                                  l_seg_vida, l_seg_vcl)
        returning l_total, l_total_max

   if l_total is null then
      let l_total = 0
   end if

   ##Total da bonificacao
   let l_vlr_bonif = l_total + l_tot_bonif

   let l_prtbnfcod = 0
   open cbdbsr123031
   fetch cbdbsr123031 into l_prtbnfcod
   close cbdbsr123031

   if l_prtbnfcod is null then
      let l_prtbnfcod = 0
   end if

   if l_vlr_bonif is null then
      let m_curr = current
      display "[", m_curr, "] Valor bonif nulo, prestador ", l_atdprscod
      return
   end if

   let l_prtbnfcod = l_prtbnfcod + 1

   call cts40g03_data_hora_banco(1) returning l_data, l_hora

   execute pbdbsr123032 using l_prtbnfcod, l_atdprscod, l_tot_srv_prt,
                              l_qtd_bnf, l_tot_srv_avl, l_vlr_bonif, l_data
   if sqlca.sqlcode <> 0 then
       let m_curr = current
       display "[", m_curr, "] Erro na inclusao da bonificacao - prestador: ", l_atdprscod
   end if

end function

function bdbsr123_arq_resumos(l_pathlog, l_patharq)

   define l_arquivo, l_pathlog, l_patharq, l_cmd char(200),
          l_assunto char(100),
          l_status smallint

   let l_assunto = null
   let l_status = null
   let l_pathlog = l_pathlog clipped, "/ldbsr123","_", m_auto_re

   let m_curr = current
   display "[", m_curr, "] Enviando arquivos de resumo"

   #######################  RESUMO PONTUALIDADE ###############################
   let l_assunto = "Bonificacao - Resumo Pontualidade - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_pontualidade.xls"
   let l_cmd = 'grep "Pontual" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
       let m_curr = current
       display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

   #######################  RESUMO DISPONIBILIDADE #############################
   let l_assunto = "Bonificacao - Resumo Disponibilidade - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_disponibilidade.xls"
   let l_cmd = 'grep "Disponibilidade" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
       let m_curr = current
       display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

   #######################  RESUMO SEGURO ######################################
   let l_assunto = "Bonificacao - Resumo Seguro - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_seguro.xls"
   let l_cmd = 'grep "Seguro" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
       let m_curr = current
       display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

   #######################  RESUMO SATISFACAO ##################################
   let l_assunto = "Bonificacao - Resumo Satisfacao - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_satisfacao.xls"
   let l_cmd = 'grep "Satisfacao" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
       let m_curr = current
       display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

   #######################  RESUMO DISP ANALITICA ##############################
   let l_assunto = "Bonificacao - Resumo Disp Analitica - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_dispteste.xls"
   let l_cmd = 'grep "Disp Analitica" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

   #######################  RESUMO RESOLUBILIDADE ##############################
   let l_assunto = "Bonificacao - Resumo Resolubilidade - ", m_auto_re
   let l_arquivo = l_patharq clipped, "/PS_resolubilidade.xls"
   let l_cmd = 'grep "Resolubilidade" ', l_pathlog clipped, ' > ', l_arquivo
   run l_cmd returning l_status

   if l_status <>  0 then
       let m_curr = current
       display "[", m_curr, "] Problemas em ", l_cmd
   end if

  call ctx22g00_envia_email("BDBSR123", l_assunto, l_arquivo)
       returning l_status

  if l_status <>  0 then
      let m_curr = current
      display "[", m_curr, "] Problemas no envio do email da ", l_status, ' ',l_arquivo
  end if

end function


 function fonetica2()

 end function

#--------------------------------------#
 function bdbsr123_verifica_executado()
#--------------------------------------#

     define l_param char(25)

     let l_param = m_auto_re clipped,
                   extend(today, month to month) clipped,
                   extend(today, year to year)

     let m_curr = current
     display "[", m_curr, "] ", l_param

 end function

#------------------------------------#
 function bdbsr123_envia_sms(l_opcao)
#------------------------------------#

 define l_opcao smallint,

        l_txt   char(50),
        l_proc  char(15)



     if  l_opcao = 1 then
         let l_proc = 'BON082011I'
         let l_txt = "BONIFICACAO INICIADA AS ", current
     else
         let l_proc = 'BON082011F'
         let l_txt = "BONIFICACAO FINALIZADA AS ", current
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


function bdbsr123_drop_tabela()

 database work

 whenever error continue
 drop table temp_bonif
 whenever error stop

 let m_curr = current
 display "[", m_curr, "] SQLCA.sqlcode DROP TABLE TEMP ", sqlca.sqlcode

end function
