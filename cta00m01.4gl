#---------------------------------------------------------------------------#
# Nome do Modulo: CTA00M01                                         Marcelo  #
#---------------------------------------------------------------------------#
# Localizacao de documentos (Auto, R.E, Transportes)               Nov/1994 #
# Alteracoes:                                                               #
#---------------------------------------------------------------------------#
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 01/12/1998  PSI 7263-0   Gilberto     Localizar propostas atraves do      #
#                                       Acompanhamento de Propostas         #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 27/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial        #
#---------------------------------------------------------------------------#
# 05/05/2001  PSI 11251-8  Raji         Consulta RE locais de risco         #
#---------------------------------------------------------------------------#
# 18/06/2001  PSI 13042-7  Ruiz         Atendimento por Vist.previa qdo for #
#                                       laudo de vidros.                    #
#---------------------------------------------------------------------------#
# 06/11/2001  PSI 14177-1  Ruiz         Atendimento transporte P.Socorro.   #
#---------------------------------------------------------------------------#
# 30/01/2002  PSI 13232-2  Ruiz         consulta as vistorias de auto/re.   #
#---------------------------------------------------------------------------#
# 15/02/2002  PSI 14654-4  Ruiz         aproveitar os dados da apolice do   #
#                                       terceiro segurado, p/ assunto N11.  #
#---------------------------------------------------------------------------#
# 21/08/2002  PSI 14179-8  Ruiz         Atend. Aviso Sinistro Transportes.  #
#---------------------------------------------------------------------------#
# 11/11/2002  PSI 159638   Ruiz         Registras ligacoes feitas nas filas #
#                                       de apoio                            #
#---------------------------------------------------------------------------#
# 17/04/2003  PSI 168920   Aguinaldo Costa   Resolucao 86                   #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# 27/10/2003  Eduardo-meta   psi172413 Registrar ligacao sem docto          #
#                            osf27987                                       #
#---------------------------------------------------------------------------#
# 19/11/2003  Meta, Bruno    PSI172057  Apresentar o nome do corretor       #
#                            OSF28991   correspondente ao Susep.            #
#---------------------------------------------------------------------------#
# 16/03/2004  Teresinha S.  OSF 33367   alterar a condicao g_documento.c24as#
#                                       tcod = "N11"                        #
# --------------------------------------------------------------------------#
# 08/04/2004  Adriana S.    Ct: 186937  Alteracao mens. erro                #
# --------------------------------------------------------------------------#
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 23/07/2004 Meta, Robson      PSI183431  Inserir novas funcoes:            #
#                              OSF036439       cta00mm01_trata_proposta(),  #
#                                              cta00mm01_trata_n11_h11(),   #
#                                              cta00mm01_guarda_globais();  #
#                                         Alterar funcoes:                  #
#                                              cta00m01_salva_campos();     #
#                                              cta00m01_trata_transp();     #
#                                              cta00m01()                   #
#                                                                           #
# 20/08/2004 Meta, Daniel      PSI183431 Efetuar correcoes na funcao        #
#                                        cta00m01() e                       #
#                                        cta00m01_guarda_gobais             #
#                              tipo de ligacao para a funcao cto00m00()     #
#---------------------------------------------------------------------------#
# 27/10/2004  Katiucia      CT 256056    Consistir retorno funcao e ramo    #
#---------------------------------------------------------------------------#
# 11/03/2005 Daniel, Meta   PSI191094    Chamar a funcao cta00m06 e tratar  #
#                                        seu retorno                        #
#---------------------------------------------------------------------------#
# 08/08/2005 Paulo, Meta    PSI194212    Na funcao cta00m01_documento, nao  #
#                                        sair, com control-c, caso o item   #
#                                        esteja zerado.                     #
#---------------------------------------------------------------------------#
# 15/09/2005 Andrei, Meta   AS87408     Criar funcao cta00m01_setetapa()    #
#                                       Incluir chamada da funcao cts01g01_ #
#                                       setetapa()                          #
#---------------------------------------------------------------------------#
# 09/08/2006 Priscila       PSI200140   Permitir opcao SemDocumento para um #
#                                       ramo diferente de auto(531)         #
#---------------------------------------------------------------------------#
# 20/09/2006 Ruiz           PSI202720   Atendimento apolice do ramo Saude.  #
#---------------------------------------------------------------------------#
# 19/06/2007 Roberto        PSI207896   Mosaico, alteracao da disposicao da #
#                                       tela                                #
# 20/06/2007 Ligia Mattge   PSI 207420  Garantia estendida, habilitar campo #
#                                       certificado                         #
# 02/07/2008 Amilton, Meta  PSI 223689  Incluir chamada da função cty02g01  #
#                                       para as funções opacc156 e opacc149 #
#---------------------------------------------------------------------------#
# 07/10/2008 Carla Rampazzo PSI 230650  .Incluir campo do Atendimento (deve #
#                                       ser o primeiro campo na navegacao)  #
#                                       .Carregar dados do documento pelo   #
#                                       Nro.Atendimento                     #
#                                       .Gerar Nro.Atendimento a cada liga  #
#                                       cao para casos sem documento        #
#                                       (so apoio tem opcao de nao gerar)   #
#---------------------------------------------------------------------------#
# 30/12/2008 Priscila       PSI 234915  Inclusão da global semdocto         #
#---------------------------------------------------------------------------#
# 22/03/2010 Carla Rampazzo PSI 219444 .chamar funcao framc215 do RE para   #
#                                       selecao de Local de Risco ou Bloco  #
#                                      .Alimentar global c/ endereco Local  #
#---------------------------------------------------------------------------#
# 30/09/2010 Patricia W.    PSI 260479 .Alteracao de fluxo na localizacao   #
#                                       por proposta. Apos localizacao,     #
#                                       vai para o espelho da proposta e nao#
#                                       mais para a tela de consulta da     #
#                                       mesma.                              #
#---------------------------------------------------------------------------#
# 21/07/2011 Humberto Santos PSI 12072 Consulta espelho proposta por Placa  #
#---------------------------------------------------------------------------#
#...........................................................................#
# Objetivo.......: Alerta Bandeira                                          #
# Analista Resp. : Humberto Santos                                          #
# PSI            : PSI-2012-23721/EV                                        #
#...........................................................................#
# Desenvolvimento: Humberto Santos                                          #
# Liberacao      : 31/05/2013                                               #
#...........................................................................#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"



define m_dtresol86   date

define m_prep_sql     smallint

define mr_documento  record
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
       c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
       ramcod        like datrservapol.ramcod,     # Codigo aamo
       lignum        like datmligacao.lignum,      # Numero da Ligacao
       c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
       ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
       atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
       atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
       sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
       sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
       sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
       sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/rm 53
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
       corsus        like gcaksusep.corsus      ,  #
       dddcod        like datmreclam.dddcod     ,  # codigo da area de discagem
       ctttel        like datmreclam.ctttel     ,  # numero do telefone
       funmat        like isskfunc.funmat       ,  # matricula do funcionario
       cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
       cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
       cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF
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
       averbacao     like datrligtrpavb.trpavbnum,          # PSI183431 Daniel
       crtsaunum     like datksegsau.crtsaunum,
       bnfnum        like datksegsau.bnfnum,
       ramgrpcod     like gtakram.ramgrpcod
end record

define mr_ppt        record
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

define mr_pss        record
       ligdctnum     like datrligsemapl.ligdctnum,
       ligdcttip     like datrligsemapl.ligdcttip,
       lgdtip        like datmlcl.lgdtip,
       lgdnom        like datmlcl.lgdnom,
       lgdnum        like datmlcl.lgdnum,
       ufdcod        like datmlcl.ufdcod,
       brrnom        like datmlcl.brrnom,
       cidnom        like datmlcl.cidnom,
       lgdcep        like datmlcl.lgdcep,
       lgdcepcmp     like datmlcl.lgdcepcmp,
       nom           like datmservico.nom,
       relpamtxt     like igbmparam.relpamtxt,
       dctitm        like datrligsemapl.dctitm
end record

-->  Endereco do Local de Risco - RE
 define mr_rsc_re     record
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
       ,rmeblcdes    like rsdmbloco.rmeblcdes
       ,lclltt       like datmlcl.lclltt
       ,lcllgt       like datmlcl.lcllgt
end record


define am_ppt        array[05] of record
       clscod        like aackcls.clscod,
       carencia      date
end record

define m_ramsgl char(15)
define l_msg    char(100)

define mr_resultado smallint
      ,mr_mensagem  char(60)

define m_hostname       char(12) # PSI223689 - Amilton
define m_server         char(05) # PSI223689 - Amilton

define m_retorno smallint
#-----------------------------------------------------------------------------#
function cta00m01_prepare()
#-----------------------------------------------------------------------------#

   define l_sql char(400)

   let l_sql = " select gcakcorr.cornom ",
                 " from gcakcorr, gcaksusep ",
                " where gcaksusep.corsus = ? ",
                  " and gcakcorr.corsuspcp = gcaksusep.corsuspcp "
   prepare p_cta00m01_001 from l_sql
   declare c_cta00m01_001 cursor for p_cta00m01_001


   let l_sql = " select 1 ",
                 " from datmvstsin ",
                " where sinvstnum = ? ",
                  " and sinvstano = ? "
   prepare p_cta00m01_002 from l_sql
   declare c_cta00m01_002 cursor for p_cta00m01_002


   let l_sql = " select 1 ",
                 " from datmavssin ",
                " where sinvstnum = ? ",
                  " and sinvstano = ? "
   prepare p_cta00m01_003 from l_sql
   declare c_cta00m01_003 cursor for p_cta00m01_003


   let l_sql = " select lignum ",
                 " from datrligsinvst ",
                " where sinvstnum = ? ",
                  " and sinvstano = ? ",
             " order by lignum desc  "
   prepare pcta00m01013 from l_sql
   declare ccta00m01013 cursor for pcta00m01013


   let l_sql = " select c24astcod ",
                 " from datmligacao ",
                " where lignum = ? "
   prepare pcta00m01014 from l_sql
   declare ccta00m01014 cursor for pcta00m01014


   let m_prep_sql = true

end function

#-----------------------------------------------------------------------------#
function cta00m01(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param     record
          apoio        char(1)
         ,empcodatd    like isskfunc.empcod
         ,funmatatd    like isskfunc.funmat
         ,usrtipcod    char(01)
         ,c24astcod    char(03)
         ,solnom       like datmligacao.c24solnom
         ,c24soltipcod like datmligacao.c24soltipcod
         ,c24paxnum    integer
   end record


   define d_cta00m01        record
          cpocod            like datkdominio.cpocod,
          cpodes            like datkdominio.cpodes,
          atdnum            like datmatd6523.atdnum,
          solnom            like datmligacao.c24solnom,
          flgavstransp      char (01),
          c24soltipcod      like datmligacao.c24soltipcod,
          c24soltipdes      char (40),
          corsus            like gcaksusep.corsus,   # PSI 172057
          cornom            like gcakcorr.cornom,    # PSI 172057
          ramcod            like gtakram.ramcod,
          flgcar            char(01),
          vcllicnum         like abbmveic.vcllicnum,
          succod            like gabksuc.succod,
          sucnom            like gabksuc.sucnom,
          aplnumdig         like abamdoc.aplnumdig,
          itmnumdig         like abbmveic.itmnumdig,
          etpctrnum         like rgemetpsgr.etpctrnum,
          ramnom            like gtakram.ramnom,
          segnom            char (40),
          pestip            char (01),
          cgccpfnum         like gsakseg.cgccpfnum,
          cgcord            like gsakseg.cgcord,
          cgccpfdig         like gsakseg.cgccpfdig,
          prporg            like datrligprp.prporg,
          prpnumdig         like datrligprp.prpnumdig,
          vp                char (01),
          vd                char (01),
          cp                char (01),
          semdocto          char (01),
          ies_ppt           char (01),
          ies_pss           char (01),
          transp            char (01),
          trpavbnum         like datrligtrpavb.trpavbnum,
          vclchsfnl         like abbmveic.vclchsfnl,
          sinramcod         like ssamsin.ramcod,
          sinnum            like ssamsin.sinnum,
          sinano            like ssamsin.sinano,
          sinvstnum         like ssamsin.sinvstnum,
          sinvstano         like ssamsin.sinvstano,
          sinautnum         like ssamsin.sinvstnum,      ##->comeco PSI 132036
          sinautano         like ssamsin.sinvstano,
          flgauto           char (01),
          sinrenum          like ssamsin.sinvstnum,
          sinreano          like ssamsin.sinvstano,
          flgre             char (01),
          sinavsnum         like ssamsin.sinnum,
          sinavsano         like ssamsin.sinano,
          flgavs            char (01),
          obs               char (09)
   end record


   define l_cta00m01   record
          atdsrvorg      like datmservico.atdsrvorg
         ,atdsrvnum      like datmservico.atdsrvnum
         ,atdsrvano      like datmservico.atdsrvano
         ,prg            char(08)
   end record


   define l_mens       record
          msg          char(200)
         ,de           char(50)
         ,subject      char(100)
         ,para         char(100)
         ,cc           char(100)
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

   define l_today date
   define l_hora  datetime hour to second
   define l_cmd   char(500)

   initialize d_cta00m01.* to null
   initialize l_cta00m01.* to null
   initialize mr_ppt.* to null ## Inicializar variavel CRM Alberto

   call cta00m01_documento(lr_param.*,d_cta00m01.*,l_cta00m01.*)
        returning mr_documento.*
                 ,mr_ppt.*
                 ,am_ppt[1].*
                 ,am_ppt[2].*
                 ,am_ppt[3].*
                 ,am_ppt[4].*
                 ,am_ppt[5].*


   if g_documento.aplnumdig <> mr_documento.aplnumdig then
      initialize l_mens.* to null
      initialize l_today to null
      initialize l_hora to null
      initialize l_cmd to null
      let l_today = today
      let l_hora = time
      let l_mens.msg = "Suc/Ram/Apol : ",mr_documento.succod,"/"
                       ,mr_documento.ramcod
                       ,"/",mr_documento.aplnumdig, " Apol.Global: "
                       , g_documento.aplnumdig
                       , "< Data: ", l_today ," : ",l_hora, " > "
                       , " Assunto : ",g_documento.c24astcod
                       ," Matricula : " , g_issk.funmat
      let l_mens.de  = "CT24H-cta00m01 <linha 301 > "
      let l_mens.subject = "Apolices Divergentes"
      let l_mens.para = "sistemas.madeira@portoseguro.com.br"
      let l_mens.cc = " "
      #PSI-2013-23297 - Inicio
      let l_mail.de = "CT24H-cta00m01 <linha 301 > "

      let l_mail.para = l_mens.para
      let l_mail.cc = l_mens.cc
      let l_mail.cco = ""
      let l_mail.assunto = "Apolices Divergentes"
      let l_mail.mensagem = l_mens.msg
      let l_mail.id_remetente = "CT24HS"
      let l_mail.tipo = "text"
      call figrc009_mail_send1 (l_mail.*)
         returning l_erro,msg_erro
      #PSI-2013-23297 - Fim

   end if

   return mr_documento.*
         ,mr_ppt.*
         ,am_ppt[1].*
         ,am_ppt[2].*
         ,am_ppt[3].*
         ,am_ppt[4].*
         ,am_ppt[5].*

end function

#-----------------------------------------------------------------------------#
function cta00m01_documento(lr_param, d_cta00m01, l_cta00m01)
#-----------------------------------------------------------------------------#

   define lr_param     record
          apoio        char(1)
         ,empcodatd    like isskfunc.empcod
         ,funmatatd    like isskfunc.funmat
         ,usrtipcod    char(01)
         ,c24astcod    char(03)
         ,solnom       like datmligacao.c24solnom
         ,c24soltipcod like datmligacao.c24soltipcod
         ,c24paxnum    integer
   end record

   define d_cta00m01        record
          cpocod            like datkdominio.cpocod  ,
          cpodes            like datkdominio.cpodes  ,
          atdnum            like datmatd6523.atdnum,
          solnom            like datmligacao.c24solnom,
          flgavstransp      char (01),
          c24soltipcod      like datmligacao.c24soltipcod,
          c24soltipdes      char (40),
          corsus            like gcaksusep.corsus,   # PSI 172057
          cornom            like gcakcorr.cornom,    # PSI 172057
          ramcod            like gtakram.ramcod,
          flgcar            char(01),
          vcllicnum         like abbmveic.vcllicnum,
          succod            like gabksuc.succod,
          sucnom            like gabksuc.sucnom,
          aplnumdig         like abamdoc.aplnumdig,
          itmnumdig         like abbmveic.itmnumdig,
          etpctrnum         like rgemetpsgr.etpctrnum,
          ramnom            like gtakram.ramnom,
          segnom            char (40),
          pestip            char (01),
          cgccpfnum         like gsakseg.cgccpfnum,
          cgcord            like gsakseg.cgcord,
          cgccpfdig         like gsakseg.cgccpfdig,
          prporg            like datrligprp.prporg,
          prpnumdig         like datrligprp.prpnumdig,
          vp                char (01),
          vd                char (01),
          cp                char (01),
          semdocto          char (01),
          ies_ppt           char (01),
          ies_pss           char (01),
          transp            char (01),
          trpavbnum         like datrligtrpavb.trpavbnum,
          vclchsfnl         like abbmveic.vclchsfnl,
          sinramcod         like ssamsin.ramcod,
          sinnum            like ssamsin.sinnum,
          sinano            like ssamsin.sinano,
          sinvstnum         like ssamsin.sinvstnum,
          sinvstano         like ssamsin.sinvstano,
          sinautnum         like ssamsin.sinvstnum,       ##->comeco PSI 132036
          sinautano         like ssamsin.sinvstano,
          flgauto           char (01),
          sinrenum          like ssamsin.sinvstnum,
          sinreano          like ssamsin.sinvstano,
          flgre             char (01),
          sinavsnum         like ssamsin.sinnum,
          sinavsano         like ssamsin.sinano,
          flgavs            char (01),
          obs               char (09)
   end record

   define l_cta00m01   record
          atdsrvorg    like datmservico.atdsrvorg
         ,atdsrvnum    like datmservico.atdsrvnum
         ,atdsrvano    like datmservico.atdsrvano
         ,prg          char (08)
   end record

   define lr_resultado record
          resultado    smallint
         ,mensagem     char(60)
   end record

   define lr_cty05g00 record
          resultado   smallint
         ,mensagem    char(42)
         ,emsdat      like abamdoc.emsdat
         ,aplstt      like abamapol.aplstt
         ,vigfnl      like abamapol.vigfnl
         ,etpnumdig   like abamapol.etpnumdig
   end record

   define lr_cty06g00    record
          resultado      smallint
         ,mensagem       char(60)
         ,sgrorg         like rsamseguro.sgrorg
         ,sgrnumdig      like rsamseguro.sgrnumdig
         ,vigfnl         like rsdmdocto.vigfnl
         ,aplstt         like rsdmdocto.edsstt
         ,prporg         like rsdmdocto.prporg
         ,prpnumdig      like rsdmdocto.prpnumdig
         ,segnumdig      like rsdmdocto.segnumdig
         ,edsnumref      like rsdmdocto.edsnumdig
   end record

   define lr_ret_sel_datk record
          erro            smallint,
          mensagem        char(60),
          grlinf          like datkgeral.grlinf
   end record

   define ws                record
          ramo              char (04),
          ramcod            like gtakram.ramcod,
          succod            like abamapol.succod,
          aplnumdig         like abamapol.aplnumdig,
          itmnumdig         like abbmitem.itmnumdig,
          tamanho           smallint,
          psqprpflg         dec(1,0),
          c24soltipdes      like datksoltip.c24soltipdes,
          contador          integer,
          segnom            char (60),
          c24paxtxt         char (12),
          cgccpfdig         like gsakseg.cgccpfdig,
          sinramnom         like gtakram.ramnom  ,
          sinramcod         like ssamsin.ramcod,
          sinnum            like ssamsin.sinnum,
          sinano            like ssamsin.sinano,
          sinitmseq         like ssamitem.sinitmseq,
          segnumdig         like gsakseg.segnumdig,
          prporg            like rsdmdocto.prporg,
          prpnumdig         like rsdmdocto.prpnumdig,
          param             char (100),
          grlchv            like datkgeral.grlchv,
          grlinf            like datkgeral.grlinf,
          hora              datetime hour to second,
          count             integer,
          confirma          char (01),
          ret               integer,
          msg               char (100),
          campo             char (10),
          vstdat            like avlmlaudo.vstdat,
          numvp             char (40),
          averbacao         char (1),
          aplstt            like abamapol.aplstt,
          vigfnl            like abamapol.vigfnl,
          flagaplstt        smallint
   end record

   define ws1           record
          segnom        like datksegsau.segnom,
          cgccpfnum     like datksegsau.cgccpfnum,
          cgccpfdig     like datksegsau.cgccpfdig
   end record

   define lr_aux       record
          resultado    smallint
         ,mensagem     char(60)
   end record

   define m_ret       record
          succod      like abamapol.succod
         ,ramcod      like ssamsin.ramcod
         ,aplnumdig   like abamapol.aplnumdig
         ,itmnumdig   like abbmitem.itmnumdig
         ,edsnumref   dec(9,0)
         ,prporg      like rsdmdocto.prporg
         ,prpnumdig   like rsdmdocto.prpnumdig
         ,fcapacorg   like rsdmdocto.prporg
         ,fcapacnum   like rsdmdocto.prpnumdig
         ,itaciacod   like datrligitaaplitm.itaciacod
   end record

   define retorno1        record
          msg             char(100),
          campo           char(10),
          succod          like gabksuc.succod,
          ramcod          like gtakram.ramcod,
          aplnumdig       like abamdoc.aplnumdig,
          itmnumdig       like abbmveic.itmnumdig,
          prporg          like datrligprp.prporg,
          prpnumdig       like datrligprp.prpnumdig,
          ramo            char(04)
   end record

   define msg               record
          linha1            char(40),
          linha2            char(40),
          linha3            char(40),
          linha4            char(40)
   end record

   define l_mens  record
          msg     char(200)
         ,de      char(50)
         ,subject char(100)
         ,para    char(100)
         ,cc      char(100)
   end record

   define l_ffpfc073   record
          cgccpfnumdig char(18) ,
          qtd          integer  ,
          mens         char(50) ,
          erro         smallint
   end record

   ---> Variaveis Auxiliares para Inclusao/Tratamento do Nro.Atendimento
   define atd                record
          vstnumdig          like datmatd6523.vstnumdig
         ,vstdnumdig         like datmatd6523.vstdnumdig
         ,cpbnum             like datmatd6523.cpbnum
         ,semdoctoempcodatd  like datmatd6523.semdoctoempcodatd
         ,semdoctopestip     like datmatd6523.semdoctopestip
         ,semdoctocgccpfnum  like datmatd6523.semdoctocgccpfnum
         ,semdoctocgcord     like datmatd6523.semdoctocgcord
         ,semdoctocgccpfdig  like datmatd6523.semdoctocgccpfdig
         ,semdoctocorsus     like datmatd6523.semdoctocorsus
         ,semdoctofunmat     like datmatd6523.semdoctofunmat
         ,semdoctoempcod     like datmatd6523.semdoctoempcod
         ,semdoctodddcod     like datmatd6523.semdoctodddcod
         ,semdoctoctttel     like datmatd6523.semdoctoctttel
         ,funmat             like datmatd6523.funmat
         ,empcod             like datmatd6523.empcod
         ,usrtip             like datmatd6523.usrtip
         ,caddat             like datmatd6523.caddat
         ,cadhor             like datmatd6523.cadhor
         ,aplnumdig          char(09)
         ,itmnumdig          char(07)
         ,gera               char(01)
         ,novo_nroatd        like datmatd6523.atdnum
         ,semdcto            like datmatd6523.semdcto
   end record


   define ws_emsdat      date
         ,aux_dctnumseq  like rsdmdocto.dctnumseq
         ,aux_prporg     like rsdmdocto.prporg
         ,aux_prpnumdig  like rsdmdocto.prpnumdig
         ,aux_sgrorg     like rsamseguro.sgrorg
         ,aux_sgrnumdig  like rsamseguro.sgrnumdig
         ,aux_segnumdig  like gsakseg.segnumdig
         ,m_lignum       dec(10,0)
         ,arr_aux        integer
         ,ix             integer
         ,l_acsnivcod    like issmnivnovo.acsnivcod
         ,l_flag         smallint
         ,l_msg          char(100)
         ,l_nullo        smallint
         ,l_qtd_segnom   smallint
         ,l_descricao    char(60)
         ,l_edsnumref    decimal(9,0)
         ,l_result       smallint  # PSI 172057
         ,l_erro         smallint  # PSI 172057
         ,l_tipo_ligacao like datksoltip.c24ligtipcod
         ,sql_stmt       CHAR(600) #--- alterado por Fabio psi159638/osf8540
         ,l_flag_acesso  smallint
         ,l_cont         integer
         ,l_asterisco    char(1)
         ,l_cmd          char(500)
         ,l_today        date
         ,l_hora         datetime hour to second
         ,l_c24astcod    like datmligacao.c24astcod
         ,l_lignum       like datmligacao.lignum
         ,l_salva_succod decimal(2,0)
         ,l_continue     smallint
         ,l_st_erro      smallint
         ,l_atdnum       like datmatd6523.atdnum
         ,l_lclnumseq    like datmpedvist.lclnumseq
         ,l_rmerscseq    like datmpedvist.rmerscseq

   if g_setexplain = 1 then
      call cts01g01_setetapa ('cta00m01 - LOCALIZANDO DOCUMENTO')
   end if


   let l_tipo_ligacao = null
   let l_c24astcod    = null
   let l_lignum       = null
   let l_continue     = null

   initialize mr_documento
             ,mr_ppt
             ,mr_pss
             ,am_ppt
             ,lr_ret_sel_datk
             ,lr_resultado
             ,lr_cty05g00
             ,lr_cty06g00
             ,ws
             ,ws1
             ,m_ret
             ,retorno1
             ,atd
             ,l_ffpfc073 to null

   let l_acsnivcod    = null
   let l_flag         = null
   let l_nullo        = null
   let l_qtd_segnom   = null
   let l_descricao    = null
   let l_edsnumref    = null
   let mr_resultado   = null
   let mr_mensagem    = null
   let m_lignum       = null
   let arr_aux        = null
   let ix             = null
   let aux_dctnumseq  = null
   let aux_prporg     = null
   let aux_prpnumdig  = null
   let aux_sgrorg     = null
   let aux_sgrnumdig  = null
   let aux_segnumdig  = null
   let sql_stmt       = null
   let l_erro         = false
   let l_result       = null
   let l_salva_succod = null
   let l_st_erro      = null
   let l_atdnum       = null
   let atd.gera       = "N"   ---> Nao gera atendimento por esta tela
   let g_gera_atd     = "S"   ---> Controla se gera ou nao Atendimento
                              ---> na tela de Assunto

   let m_retorno = 0
   let l_flag_acesso = cta00m06(g_issk.dptsgl)

   if l_cta00m01.atdsrvnum is not null then # tela "semDocto"
      let d_cta00m01.obs = "(F8)Laudo"
   end if

   open window cta00m01 at 04,02 with form "cta00m01"
                        attribute(form line 1)

   #-- Obter data resolucao 86 --#
   call cta12m00_seleciona_datkgeral('ct24resolucao86')
        returning lr_ret_sel_datk.*

   let m_dtresol86 = lr_ret_sel_datk.grlinf


   initialize m_ramsgl to null

   if l_cta00m01.prg = "cts35m02" then
      let ws1.segnom     = d_cta00m01.segnom
      let ws1.cgccpfnum  = d_cta00m01.cgccpfnum
      let ws1.cgccpfdig  = d_cta00m01.cgccpfdig
   end if

   while true

      ## CT 303208

      initialize mr_documento
                ,mr_pss
                ,mr_ppt
                ,g_ppt
                ,g_pss
                ,g_dctoarray
                ,g_funapol
                ,ws to null

      call cta00m01_set_globais()
      let d_cta00m01.aplnumdig  = null
      let d_cta00m01.itmnumdig  = null
      let int_flag              = false
      let arr_aux               = 1
      let l_cont                = 0

      for ix  = 1  to 5
         let g_a_pptcls[ix].clscod   = null
         let g_a_pptcls[ix].carencia = null
      end for

      let d_cta00m01.ies_ppt       = "N"
      display by name d_cta00m01.ies_ppt

      let d_cta00m01.ies_pss       = "N"
      display by name d_cta00m01.ies_pss

      let d_cta00m01.flgcar        = "N"
      display by name d_cta00m01.flgcar


      if m_prep_sql is null or m_prep_sql <> true then # PSI 172057
         call cta00m01_prepare()
      end if

      input by name d_cta00m01.*  without defaults

       #----------Before-Cpocod-------------------------------------------------
      before field cpocod
         display by name d_cta00m01.cpocod attribute (reverse)
         let d_cta00m01.cpocod = 0
         call cta00m00_recupera_convenio(d_cta00m01.cpocod)
         returning d_cta00m01.cpodes
         display by name d_cta00m01.cpodes
       #----------After-Cpocod-------------------------------------------------
      after field cpocod
         display by name d_cta00m01.cpocod
         if d_cta00m01.cpocod is null then
            let d_cta00m01.cpocod = cta00m00_convenios()
            if d_cta00m01.cpocod is null then
               next field cpocod
            end if
         end if
         call cta00m00_recupera_convenio(d_cta00m01.cpocod)
         returning d_cta00m01.cpodes
         if d_cta00m01.cpodes is null then
            error "Convenio Inexistente!" sleep 1
            let d_cta00m01.cpocod = cta00m00_convenios()

            if d_cta00m01.cpocod is null then
               next field cpocod
            end if

            call cta00m00_recupera_convenio(d_cta00m01.cpocod)
            returning d_cta00m01.cpodes

         end if

         let g_documento.ligcvntip = d_cta00m01.cpocod

         display by name d_cta00m01.cpocod
         display by name d_cta00m01.cpodes


      #----------Before-Atdnum-------------------------------------------------
      before field atdnum
         display by name d_cta00m01.atdnum attribute (reverse)

      #-----------After-Atdnum-------------------------------------------------
      after field atdnum

         display by name d_cta00m01.atdnum

         if d_cta00m01.atdnum = 0 then
            error " Nro.Atendimento invalido. "
            let l_cont         = 0
            next field atdnum
         end if

         if l_atdnum is not null then
            let d_cta00m01.atdnum = l_atdnum
         end if

         ---> Se informou Nro.Atendimento
         if d_cta00m01.atdnum is not null and
            d_cta00m01.atdnum <> 0        then

	    ---> Verifica se eh valido e se eh da Porto/Demais  ou da Azul
            call ctd24g00_valida_atd(d_cta00m01.atdnum
                                    ,1   --> ciaempcod
                                    ,1 ) --> tp retorno dos parametros
                 returning lr_aux.resultado
                          ,lr_aux.mensagem

            if lr_aux.resultado <> 1 then
	       error lr_aux.mensagem

               initialize atd.* , d_cta00m01.* to null
               display by name d_cta00m01.*

               let d_cta00m01.ies_ppt       = "N"
               display by name d_cta00m01.ies_ppt

               let d_cta00m01.ies_pss       = "N"
               display by name d_cta00m01.ies_pss

               let d_cta00m01.flgcar        = "N"
               display by name d_cta00m01.flgcar

	       next field atdnum
	    else

               ---> Carrega dados do Atendimento
               call ctd24g00_valida_atd(d_cta00m01.atdnum
                                       ,g_documento.ciaempcod
                                       ,3 ) --> tp retorno dos parametros
                    returning  lr_resultado.resultado
                              ,lr_resultado.mensagem
                              ,g_documento.ciaempcod
                              ,d_cta00m01.solnom
                              ,d_cta00m01.flgavstransp
                              ,d_cta00m01.c24soltipcod
                              ,d_cta00m01.ramcod
                              ,d_cta00m01.flgcar
                              ,d_cta00m01.vcllicnum
                              ,d_cta00m01.corsus
                              ,d_cta00m01.succod
                              ,d_cta00m01.aplnumdig
                              ,d_cta00m01.itmnumdig
                              ,d_cta00m01.etpctrnum
                              ,d_cta00m01.segnom
                              ,d_cta00m01.pestip
                              ,d_cta00m01.cgccpfnum
                              ,d_cta00m01.cgcord
                              ,d_cta00m01.cgccpfdig
                              ,d_cta00m01.prporg
                              ,d_cta00m01.prpnumdig
                              ,d_cta00m01.vp         --> flgvp
                              ,atd.vstnumdig
                              ,atd.vstdnumdig
                              ,d_cta00m01.vd         --> flgvd
                              ,d_cta00m01.cp         --> flgcp
                              ,atd.cpbnum
                              ,d_cta00m01.semdocto
                              ,d_cta00m01.ies_ppt
                              ,d_cta00m01.ies_pss
                              ,d_cta00m01.transp
                              ,d_cta00m01.trpavbnum
                              ,d_cta00m01.vclchsfnl
                              ,d_cta00m01.sinramcod
                              ,d_cta00m01.sinnum
                              ,d_cta00m01.sinano
                              ,d_cta00m01.sinvstnum
                              ,d_cta00m01.sinvstano
                              ,d_cta00m01.flgauto
                              ,d_cta00m01.sinautnum
                              ,d_cta00m01.sinautano
                              ,d_cta00m01.flgre
                              ,d_cta00m01.sinrenum
                              ,d_cta00m01.sinreano
                              ,d_cta00m01.flgavs
                              ,d_cta00m01.sinavsnum
                              ,d_cta00m01.sinavsano
                              ,g_documento.empcodmat --> semdoctoempcodatd
                              ,atd.semdoctopestip
                              ,g_documento.cgccpfnum --> semdoctocgccpfnum
                              ,g_documento.cgcord    --> semdoctocgcord
                              ,g_documento.cgccpfdig --> semdoctocgccpfdig
                              ,g_documento.corsus    --> semdoctocorsus
                              ,g_documento.funmat    --> semdoctofunmat
                              ,atd.semdoctoempcod
                              ,g_documento.dddcod    --> semdoctodddcod
                              ,g_documento.ctttel    --> semdoctoctttel
                              ,atd.funmat
                              ,atd.empcod
                              ,atd.usrtip
                              ,atd.caddat
                              ,atd.cadhor
                              ,mr_documento.ligcvntip


               let atd.aplnumdig        = d_cta00m01.aplnumdig using "&&&&&&&&&"
	       let atd.itmnumdig        = d_cta00m01.itmnumdig using "&&&&&&&"
               let d_cta00m01.itmnumdig = atd.itmnumdig[1,6]
               let d_cta00m01.aplnumdig = atd.aplnumdig[1,8]
               let g_documento.atdnum   = d_cta00m01.atdnum
               let lr_param.solnom      = d_cta00m01.solnom
               let lr_param.c24soltipcod= d_cta00m01.c24soltipcod

               ---> Obter o nome do corretor
               call cty00g00_nome_corretor(d_cta00m01.corsus)
                    returning lr_resultado.resultado
                             ,lr_resultado.mensagem
                             ,d_cta00m01.cornom

               ---> Obter a descricao do ramo
               call cty10g00_descricao_ramo(d_cta00m01.ramcod,1)
                    returning lr_resultado.resultado
                             ,lr_resultado.mensagem
                             ,d_cta00m01.ramnom
                             ,m_ramsgl

               ---> Obter o nome da sucursal --#
               call f_fungeral_sucursal(d_cta00m01.succod)
                    returning d_cta00m01.sucnom

               ---> Descricao do Tipo
               if d_cta00m01.flgavstransp = "S" then
                  call cto00m06_desc(d_cta00m01.c24soltipcod)
		       returning ws.c24soltipdes
               else
                  ---> Obter descricao do tipo de solicitante
                  call cto00m00_nome_solicitante(d_cta00m01.c24soltipcod
                                                ,1) --->  tipo_ligacao
                       returning lr_aux.resultado
                                ,lr_aux.mensagem
                                ,ws.c24soltipdes

               end if

               display by name d_cta00m01.solnom
                              ,d_cta00m01.flgavstransp
                              ,d_cta00m01.c24soltipcod
                              ,ws.c24soltipdes
                              ,d_cta00m01.ramcod
                              ,d_cta00m01.ramnom
                              ,d_cta00m01.flgcar
                              ,d_cta00m01.vcllicnum
                              ,d_cta00m01.corsus
                              ,d_cta00m01.cornom
                              ,d_cta00m01.succod
                              ,d_cta00m01.sucnom
                              ,d_cta00m01.aplnumdig
                              ,d_cta00m01.itmnumdig
                              ,d_cta00m01.etpctrnum
                              ,d_cta00m01.segnom
                              ,d_cta00m01.pestip
                              ,d_cta00m01.cgccpfnum
                              ,d_cta00m01.cgcord
                              ,d_cta00m01.cgccpfdig
                              ,d_cta00m01.prporg
                              ,d_cta00m01.prpnumdig
                              ,d_cta00m01.vp
                              ,d_cta00m01.vd
                              ,d_cta00m01.cp
                              ,d_cta00m01.semdocto
                              ,d_cta00m01.ies_ppt
                              ,d_cta00m01.ies_pss
                              ,d_cta00m01.transp
                              ,d_cta00m01.trpavbnum
                              ,d_cta00m01.vclchsfnl
                              ,d_cta00m01.sinramcod
                              ,d_cta00m01.sinnum
                              ,d_cta00m01.sinano
                              ,d_cta00m01.sinvstnum
                              ,d_cta00m01.sinvstano
                              ,d_cta00m01.flgauto
                              ,d_cta00m01.sinautnum
                              ,d_cta00m01.sinautano
                              ,d_cta00m01.flgre
                              ,d_cta00m01.sinrenum
                              ,d_cta00m01.sinreano
                              ,d_cta00m01.flgavs
                              ,d_cta00m01.sinavsnum
                              ,d_cta00m01.sinavsano

               if d_cta00m01.semdocto is null then
                  let d_cta00m01.semdocto = "N"
               end if
            end if
         end if

         --> carrega global com flag sem docto           #PSI234915
         let g_documento.semdocto = d_cta00m01.semdocto


      #----------Before-Solnom-------------------------------------------------
      before field solnom

         #--> Vida - VEP
         let g_cob_fun_saf = null

         if g_documento.aplnumdig <>  mr_documento.aplnumdig then
            initialize l_mens.* to null
            initialize l_today  to null
            initialize l_hora   to null
            initialize l_cmd    to null
            let l_today    = today
            let l_hora     = time
            let l_mens.msg = "Suc/Ram/Apol : ",mr_documento.succod ,"/"
                                              ,mr_documento.ramcod ,"/"
                                              ,mr_documento.aplnumdig,
                             " Apol.Global: " ,g_documento.aplnumdig
                           , "< Data: "       ,l_today ," : ",l_hora, " > "
                           , " Assunto : "    ,g_documento.c24astcod
                            ," Matricula : "  ,g_issk.funmat

            call cta00m01_email(l_mens.msg)

         end if

         let mr_documento.empcodatd  = lr_param.empcodatd
         let mr_documento.funmatatd  = lr_param.funmatatd
         let mr_documento.usrtipatd  = lr_param.usrtipcod
         let d_cta00m01.solnom       = lr_param.solnom
         let d_cta00m01.c24soltipcod = lr_param.c24soltipcod


         display by name d_cta00m01.solnom
         display by name d_cta00m01.c24soltipcod


         if lr_param.apoio = "S" then

            #-- Obter nome do funcionario do apoio --#
            call cty08g00_nome_func(lr_param.empcodatd
                                   ,lr_param.funmatatd
                                   ,lr_param.usrtipcod)   # PSI183431  Daniel
                 returning lr_resultado.resultado
                          ,lr_resultado.mensagem
                          ,d_cta00m01.solnom

            if lr_resultado.resultado = 3 then
               call errorlog(lr_resultado.mensagem)
               exit input
            else
               if lr_resultado.resultado = 2 then
                  call errorlog(lr_resultado.mensagem)
               end if
            end if

            let d_cta00m01.c24soltipcod = 6
            let d_cta00m01.c24soltipdes = "APOIO"

            display by name d_cta00m01.c24soltipcod
            display by name d_cta00m01.c24soltipdes
            display by name d_cta00m01.solnom

            let mr_documento.solnom        = d_cta00m01.solnom
            let mr_documento.c24soltipcod  = d_cta00m01.c24soltipcod

            next field ramcod
         else

            if lr_param.c24astcod = "N11"  or
               lr_param.c24astcod = "H11"  then -- OSF 33367

               call cta00m01_trata_n11_h11(lr_param.c24soltipcod
                                          ,m_dtresol86)
                    returning d_cta00m01.c24soltipdes
                             ,d_cta00m01.ramcod
                             ,d_cta00m01.transp
                             ,ws.ramo

               let d_cta00m01.c24soltipcod = lr_param.c24soltipcod
               let d_cta00m01.solnom       = lr_param.solnom

               display by name d_cta00m01.solnom
               display by name d_cta00m01.c24soltipcod
               display by name ws.c24soltipdes
               display by name d_cta00m01.ramcod
               display by name d_cta00m01.transp

               let mr_documento.solnom        = d_cta00m01.solnom
               let mr_documento.c24soltipcod  = d_cta00m01.c24soltipcod

               next field succod
            end if
         end if

         display by name d_cta00m01.solnom  attribute (reverse)
         display ws.c24soltipdes to c24soltipdes

         let mr_documento.solnom        = d_cta00m01.solnom
         let mr_documento.c24soltipcod  = d_cta00m01.c24soltipcod


      #------------------After-Solnom------------------------------------------

      after field solnom
         display by name d_cta00m01.solnom

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdnum
         end if


         if d_cta00m01.solnom is null  or
            d_cta00m01.solnom  = "  "  then
            error " Solicitante deve ser informado!"
            next field solnom
         end if

         let mr_documento.solnom  = d_cta00m01.solnom

         next field c24soltipcod


      #------------Before-Flgavstransp-----------------------------------------
      before field flgavstransp
         initialize d_cta00m01.flgavstransp to null
         display by name d_cta00m01.flgavstransp attribute (reverse)


      #-----------After-Flgavstransp-------------------------------------------
      after  field flgavstransp
         display by name d_cta00m01.flgavstransp

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field solnom
         end if

         if d_cta00m01.flgavstransp is not null then
            if d_cta00m01.flgavstransp = "N" then
               next field c24soltipcod
            end if

            if d_cta00m01.flgavstransp <> "S" then
               error " Marque opcao com 'S' "
               next field flgavstransp
            end if
         end if

      #------------Before-C24soltipcod----------------------------------------
      before field c24soltipcod
         display by name d_cta00m01.c24soltipcod  attribute (reverse)

         let l_tipo_ligacao = 1


      #------------After-C24soltipcod-----------------------------------------
      after field c24soltipcod
         display by name d_cta00m01.c24soltipcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then

            if l_flag_acesso = 0 then
               next field solnom
            else
               next field flgavstransp
            end if
         end if

         if d_cta00m01.flgavstransp = "S" then

            #-- Exibe popup dos tipos de solicitante do Transporte --#
            call cto00m06()
                 returning d_cta00m01.c24soltipcod
                          ,ws.c24soltipdes

            if ws.c24soltipdes is null then
               next field c24soltipcod
            end if
         else
            if d_cta00m01.c24soltipcod is null then
               error "Tipo do solicitante deve ser informado!"
               #-- Exibe popup dos tipos de solicitante --#

               let d_cta00m01.c24soltipcod = cto00m00(l_tipo_ligacao)
               display by name d_cta00m01.c24soltipcod
            end if

            #Obter descricao do tipo de solicitante
            call cto00m00_nome_solicitante(d_cta00m01.c24soltipcod
                                         , l_tipo_ligacao)
                 returning lr_aux.resultado
                          ,lr_aux.mensagem
                          ,ws.c24soltipdes

            if lr_aux.resultado <> 1 then
               error lr_aux.mensagem
               next field c24soltipcod
            end if
         end if

         if ws.c24soltipdes is null then

             error " Tipo de solicitante nao cadastrado!"

             if d_cta00m01.flgavstransp = "S" then
                #Exibe popup dos tipos de solicitantes do Transportes

                call cto00m06()
                     returning d_cta00m01.c24soltipcod
                              ,ws.c24soltipdes
             else
                #Exibe popup dos tipos de solicitantes
                let d_cta00m01.c24soltipcod = cto00m00(l_tipo_ligacao)

                call cto00m00_nome_solicitante(d_cta00m01.c24soltipcod
                                              ,l_tipo_ligacao)

                     returning lr_aux.resultado
                              ,lr_aux.mensagem
                              ,ws.c24soltipdes
             end if
         end if

         let mr_documento.c24soltipcod = d_cta00m01.c24soltipcod

         if d_cta00m01.c24soltipcod < 3 then
            let mr_documento.soltip = ws.c24soltipdes[1,1]
         else
            let mr_documento.soltip = "O"
         end if

         #-- Se tipo solicitante eh Corretor --#
         if (d_cta00m01.c24soltipcod = 2   or
             d_cta00m01.c24soltipcod = 8)      and
            (d_cta00m01.flgavstransp = "N" or
             d_cta00m01.flgavstransp is null ) then
            let l_result = true
         else
            let l_result = false
         end if

         display by name ws.c24soltipdes


         # Se nao tem nr. do pax e nivel 6
         if lr_param.c24paxnum is null and g_issk.acsnivcod = 6 then

            #Obter nivel do funcionario
            call cty08g00_nivel_func(g_issk.usrtip
                                    ,g_issk.empcod
                                    ,g_issk.usrcod
                                    ,'pso_ct24h')
                 returning lr_resultado.resultado
                          ,lr_resultado.mensagem
                          ,l_acsnivcod


            if l_acsnivcod is null then
               while lr_param.c24paxnum is null
                  #-- obter nr. do pax --#
                  let lr_param.c24paxnum = cta02m09()
               end while
            end if
         end if

         if lr_param.c24paxnum is not null  and
            lr_param.c24paxnum <> 0 then
            let ws.c24paxtxt = "P.A.: ", lr_param.c24paxnum using "######"
            display by name ws.c24paxtxt  attribute (reverse)
         else
            let lr_param.c24paxnum = 0
         end if

         let mr_documento.c24paxnum = lr_param.c24paxnum


         ---> se carregou dados pelo Nro Atendimento sai do Input
         ---> apos entrar na tela de sem Doctos, pois ja confirmou nela
         if d_cta00m01.semdocto = "S" then

            let g_documento.atdnum = d_cta00m01.atdnum

            call cta10m00_entrada_dados()

            let mr_documento.corsus    = g_documento.corsus
            let mr_documento.dddcod    = g_documento.dddcod
            let mr_documento.ctttel    = g_documento.ctttel
            let mr_documento.funmat    = g_documento.funmat
            let mr_documento.cgccpfnum = g_documento.cgccpfnum
            let mr_documento.cgcord    = g_documento.cgcord
            let mr_documento.cgccpfdig = g_documento.cgccpfdig

            let atd.semdoctocorsus    = g_documento.corsus
            let atd.semdoctodddcod    = g_documento.dddcod
            let atd.semdoctoctttel    = g_documento.ctttel
            let atd.semdoctofunmat    = g_documento.funmat
            let atd.semdoctocgccpfnum = g_documento.cgccpfnum
            let atd.semdoctocgcord    = g_documento.cgcord
            let atd.semdoctocgccpfdig = g_documento.cgccpfdig
            let atd.semdoctofunmat    = g_documento.funmat
            let atd.semdoctoempcod    = g_documento.empcodmat
            let atd.semdoctoempcodatd = g_documento.empcodatd

            if atd.semdoctocgcord is null and
               atd.semdoctocgcord =  0    then
               let atd.semdoctopestip = "F"
            else
               let atd.semdoctopestip = "J"
            end if

            if mr_documento.corsus    is null and
               mr_documento.dddcod    is null and
               mr_documento.ctttel    is null and
               mr_documento.funmat    is null and
               mr_documento.cgccpfnum is null and
               mr_documento.cgcord    is null and
               mr_documento.cgccpfdig is null then
               error 'Faltam informacoes para registrar Ligacao sem Docto.'sleep 2
               next field atdnum
            else
               exit input
            end if
         end if

         if l_result = true then
            next field corsus
         else
	    if d_cta00m01.ies_pss = "S" then
               next field ies_pss
            else
               next field ramcod
            end if
         end if

      #-----------------Before-Ies_ppt-----------------------------------------
      before field ies_ppt
         initialize mr_ppt.* to null
         display by name d_cta00m01.ies_ppt

      #-------------------After-Ies_ppt-----------------------------------------
      after field ies_ppt

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field ies_pss
         end if

         if d_cta00m01.ies_ppt <> "N" and
            d_cta00m01.ies_ppt <> "S" then
            error "Digite S(im) ou N(ao)"
            next field ies_ppt
         end if

         if d_cta00m01.ies_ppt = "S" then
            let d_cta00m01.ramcod = 06
            let mr_documento.ramcod = d_cta00m01.ramcod

            #-- Obter o cliente do protecao patrimonial --#
            call cty04g00_pesq_cliente()
                 returning mr_ppt.*
                          ,am_ppt[1].*
                          ,am_ppt[2].*
                          ,am_ppt[3].*
                          ,am_ppt[4].*
                          ,am_ppt[5].*

            if mr_ppt.corsus = "******" then
               initialize mr_ppt.corsus to null
            end if

            if not int_flag then
               if mr_ppt.cmnnumdig is not null then
                  exit input
               else
                  next field ies_ppt
               end if
            else
               let int_flag = false
               error "Consulta cancelada"
               next field ies_ppt
            end if
         else
            next field ies_pss
         end if

         # PSI 172057 - Inicio

      #------------------Before-Ies_pss-----------------------------------------
      before field ies_pss
         initialize mr_pss.* to null
         display by name d_cta00m01.ies_pss

      #-------------------After-ies_pss-----------------------------------------
      after field ies_pss

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field semdocto
         end if

         if d_cta00m01.ies_pss <> "N" and
            d_cta00m01.ies_pss <> "S" then
            error "Digite S(im) ou N(ao)"
            next field ies_pss
         end if


      #------------------Before-Corsus-----------------------------------------
      before field corsus
         display by name d_cta00m01.corsus

#-------------------------After-Corsus-----------------------------------------

      after field corsus

         if d_cta00m01.corsus is null then
            error "Informe a susep do corretor"      # PSI183431 Daniel
            next field corsus
         end if

         #-- Obter o nome do corretor --#
         call cty00g00_nome_corretor(d_cta00m01.corsus)
              returning lr_resultado.resultado
                       ,lr_resultado.mensagem
                       ,d_cta00m01.cornom


         if lr_resultado.resultado = 2 or d_cta00m01.cornom is null then
            error 'Nao existe Susep cadastrada !!!' sleep 2
            next field corsus
         end if

         let mr_documento.corsus = d_cta00m01.corsus

         display by name d_cta00m01.cornom

#-------------------------Before-Ramcod-----------------------------------------
       before field ramcod
          display by name d_cta00m01.ramcod  attribute (reverse)

#-------------------------After-Ramcod-----------------------------------------

       after  field ramcod
          display by name d_cta00m01.ramcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             let d_cta00m01.c24soltipcod = null
             next field c24soltipcod
          end if

          if d_cta00m01.ramcod is null then
             if m_dtresol86 <= today then
                let d_cta00m01.ramcod = 531
             else
                let d_cta00m01.ramcod = 31
             end if
             display by name d_cta00m01.ramcod

             let d_cta00m01.transp   = "N"
          end if

          if d_cta00m01.ramcod = 80  or
             d_cta00m01.ramcod = 81  or
             d_cta00m01.ramcod = 91  or
             d_cta00m01.ramcod = 981 or
             d_cta00m01.ramcod = 982 then
             error " Consulta nao disponivel para este ramo!"
             next field ramcod
          end if

          if d_cta00m01.ramcod = 31  or
             d_cta00m01.ramcod = 531  then
             let ws.ramo = "AUTO"
          else
              let m_server   = fun_dba_servidor("RE")
              let m_hostname = "porto@",m_server clipped , ":"
              call cta13m00_verifica_status(m_hostname)
              returning l_st_erro,l_msg
              if l_st_erro = false then
                 call cts08g01 ("A","N","RE INDISPONIVEL ",
                                "SOMENTE SERVICOS DE GUINCHO !",
                                "","")
                       returning ws.confirma
              end if
             if d_cta00m01.ramcod = 91   or
                d_cta00m01.ramcod = 991  or
                d_cta00m01.ramcod = 1391 or
                d_cta00m01.ramcod = 1329 then
                let ws.ramo = "VIDA"
             else
                let ws.ramo = "RE  "
             end if
          end if

          #Obter a descricao do ramo
          call cty10g00_descricao_ramo(d_cta00m01.ramcod,1)
          returning lr_resultado.resultado
                   ,lr_resultado.mensagem
                   ,d_cta00m01.ramnom
                   ,m_ramsgl

          if lr_resultado.resultado = 3 then
             call errorlog(lr_resultado.mensagem)
             exit input
          else
             if lr_resultado.resultado = 2 then
                call errorlog(lr_resultado.mensagem)
             end if
          end if
          if d_cta00m01.ramnom is null then
             error " Ramo nao cadastrado!" sleep 2
             #-- Exibir tela popup para escolha do ramo --#
             call c24geral10()
                  returning d_cta00m01.ramcod, d_cta00m01.ramnom
             next field ramcod
          end if

          # psi202720 - saude+casa
          call cty10g00_grupo_ramo(g_issk.empcod
                                  ,d_cta00m01.ramcod)
          returning mr_resultado, mr_mensagem, mr_documento.ramgrpcod
          if mr_documento.ramgrpcod = 5 then

             ---> Passou a assumir Empresa 50 - Saude - PSI 198404
             let g_documento.ciaempcod = 50

             call cta01m13("",ws1.cgccpfnum,ws1.cgccpfdig,ws1.segnom)
                     returning mr_documento.succod,
                               mr_documento.ramcod,
                               mr_documento.aplnumdig,
                               mr_documento.crtsaunum,
                               mr_documento.bnfnum  # espelho saude

             if mr_documento.crtsaunum is null and
                l_cta00m01.prg         is null then
                call cts08g01 ("A","S","",
                               "DESEJA ATENDER SEM DOCTO  ?",
                               "","")
                     returning ws.confirma
                if ws.confirma = "S" then
                   let d_cta00m01.semdocto = "S"
                   next field semdocto
                else
                   next field ramcod
                end if
             end if
             exit input
          end if

          if d_cta00m01.ramcod = 991  or
             d_cta00m01.ramcod = 1391 or
             d_cta00m01.ramcod = 1329 then
             let mr_documento.ramcod = d_cta00m01.ramcod

             call cta01m30( d_cta00m01.solnom
                           ,d_cta00m01.c24soltipcod
                           ,ws.c24soltipdes
                           ,d_cta00m01.ramcod
                           ,d_cta00m01.ramnom
                           ,lr_param.funmatatd
                           ,lr_param.c24astcod
                           ,lr_param.c24paxnum
                           ,d_cta00m01.succod
                           ,d_cta00m01.aplnumdig
                           ,d_cta00m01.segnom
                           ,d_cta00m01.pestip
                           ,d_cta00m01.cgccpfnum
                           ,d_cta00m01.cgcord
                           ,d_cta00m01.cgccpfdig
                           ,d_cta00m01.prporg
                           ,d_cta00m01.prpnumdig
                           ,d_cta00m01.semdocto)
             returning l_continue
                      ,atd.semdcto

             if l_continue = 0 then
                let mr_documento.ramcod       = g_documento.ramcod
                let mr_documento.succod       = g_documento.succod
                let mr_documento.aplnumdig    = g_documento.aplnumdig
                let mr_documento.prporg       = g_documento.prporg
                let mr_documento.prpnumdig    = g_documento.prpnumdig
                let mr_documento.corsus       = g_documento.corsus
                let mr_documento.dddcod       = g_documento.dddcod
                let mr_documento.ctttel       = g_documento.ctttel
                let mr_documento.funmat       = g_documento.funmat
                let mr_documento.cgccpfnum    = g_documento.cgccpfnum
                let mr_documento.cgcord       = g_documento.cgcord
                let mr_documento.cgccpfdig    = g_documento.cgccpfdig

                let d_cta00m01.semdocto   = atd.semdcto
                let atd.semdoctocorsus    = g_documento.corsus
                let atd.semdoctodddcod    = g_documento.dddcod
                let atd.semdoctoctttel    = g_documento.ctttel
                let atd.semdoctofunmat    = g_documento.funmat
                let atd.semdoctocgccpfnum = g_documento.cgccpfnum
                let atd.semdoctocgcord    = g_documento.cgcord
                let atd.semdoctocgccpfdig = g_documento.cgccpfdig
                let atd.semdoctofunmat    = g_documento.funmat
                let atd.semdoctoempcodatd = g_documento.empcodatd

                exit input
             end if
          end if
          display by name d_cta00m01.ramcod
          display by name d_cta00m01.ramnom

          if d_cta00m01.ramcod  <>  31 and
             d_cta00m01.ramcod  <> 531 and
             d_cta00m01.ramcod  <> 16  and
             d_cta00m01.ramcod  <> 524 then
             next field succod
          end if

#-------------------------Before-Flgcar-----------------------------------------
         before field flgcar
            display by name d_cta00m01.flgcar attribute (reverse)

#-------------------------After-Flgcar-----------------------------------------

         after field flgcar
            display by name d_cta00m01.flgcar
            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field ramcod
            end if

            if d_cta00m01.flgcar <> "S" and
               d_cta00m01.flgcar <> "N" then
               error "Digite S(im) ou N(ao)"
               next field flgcar
            end if

            if d_cta00m01.flgcar = "S" then
                  next field pestip
            end if

#-------------------------Before-Transp-----------------------------------------
       before field transp
          display by name d_cta00m01.transp attribute (reverse)
          initialize d_cta00m01.trpavbnum to  null
          display by name d_cta00m01.trpavbnum

#-------------------------After-Transp-----------------------------------------

       after field transp
          display by name d_cta00m01.transp
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ies_ppt
          end if
          if d_cta00m01.transp <> "S" and
             d_cta00m01.transp <> "N" then
             error "Digite S(im) ou N(ao)"
             next field transp
          else
             if d_cta00m01.transp = "S" then
                let mr_documento.flgtransp = "S"
                if d_cta00m01.flgavstransp = "S" then
                   next field succod
                end if
                call cts08g01 ("A","S","",
                               "DESEJA COMUNICAR EMBARQUE ?",
                               "","")
                     returning ws.confirma
                let ws.averbacao = null


                if ws.confirma = "S" then

                   let mr_documento.averbacao = null       # PSI183431 Daniel

                   if g_issk.funmat = 12435 then
                      display "cta00m01 .succod=",mr_documento.succod
                      display "ramcod=",mr_documento.ramcod
                      display "aplnumdig=",mr_documento.aplnumdig
                   end if
                   exit input
                else
                   next field trpavbnum
                end if
             else
                next field vclchsfnl
             end if
          end if

#----------------------Before-Trpavbnum-----------------------------------------
       before field trpavbnum

          display by name d_cta00m01.trpavbnum  attribute (reverse)

#-----------------------After-Trpavbnum-----------------------------------------

       after field trpavbnum
          display by name d_cta00m01.trpavbnum
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize d_cta00m01.trpavbnum to  null
             display by name d_cta00m01.trpavbnum
             next field transp
          end if
          if d_cta00m01.trpavbnum is not null then
              let mr_documento.averbacao = d_cta00m01.trpavbnum # PSI183431 Daniel
             exit input
          else
             next field segnom
          end if

#-------------------------Before-Succod-----------------------------------------
       before field succod
          display by name d_cta00m01.succod  attribute (reverse)

#-------------------------After-Succod-----------------------------------------

       after  field succod

          display by name d_cta00m01.succod
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then

             if d_cta00m01.ramcod  =  31   or
                d_cta00m01.ramcod  =  16   or
                d_cta00m01.ramcod  =  531  or
                d_cta00m01.ramcod  =  524  then
                next field vcllicnum
             end if

                next field ramcod

          end if

          if d_cta00m01.succod is null  then
             let d_cta00m01.succod = 01
             display by name d_cta00m01.succod
          end if

          let l_salva_succod = d_cta00m01.succod

          #-- Obter o nome da sucursal --#
          call f_fungeral_sucursal(d_cta00m01.succod)
          returning d_cta00m01.sucnom


          if d_cta00m01.sucnom is null then
             error " Sucursal nao cadastrada!"
             #-- Exibe tela popup para escolha da sucursal
             call c24geral11()
                  returning d_cta00m01.succod, d_cta00m01.sucnom
             next field succod
          end if
          display by name d_cta00m01.succod
          display by name d_cta00m01.sucnom

#---------------------Before-Aplnumdig-----------------------------------------
       before field aplnumdig
          display by name d_cta00m01.aplnumdig attribute (reverse)

#----------------------After-Aplnumdig-----------------------------------------
       after  field aplnumdig

          display by name d_cta00m01.aplnumdig

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             let d_cta00m01.aplnumdig = null
             let ws.aplnumdig         = null
             display by name d_cta00m01.aplnumdig
             next field succod
          end if

          if d_cta00m01.aplnumdig = 0 then
             let d_cta00m01.aplnumdig = null
             let ws.aplnumdig         = null
             display by name d_cta00m01.aplnumdig
          end if

          let ws.aplnumdig = null

          if d_cta00m01.aplnumdig is not null  then

             call F_FUNDIGIT_DIGAPOL
                  (d_cta00m01.succod, d_cta00m01.ramcod, d_cta00m01.aplnumdig)
                  returning ws.aplnumdig

             if ws.aplnumdig is null  then
                error " Problemas no digito da apolice ! AVISE A INFORMATICA!"
                let ws.aplnumdig = null
                next field aplnumdig
             else
                let g_documento.aplnumdig = ws.aplnumdig
             end if

             if d_cta00m01.ramcod = 31  or
                d_cta00m01.ramcod = 531 then

                #-- Obter dados da apolice de auto --#
                call cty05g00_dados_apolice(d_cta00m01.succod
                                           ,ws.aplnumdig)

                returning lr_cty05g00.*

                if lr_cty05g00.resultado = 3 then
                   call errorlog(lr_cty05g00.mensagem)
                   exit input
                else
                   if lr_cty05g00.resultado = 2 then
                      call errorlog(lr_cty05g00.mensagem)
                   end if
                end if


                if lr_cty05g00.emsdat is null then
                   error ' Apolice do ramo AUTOMOVEL nao cadastrada! ' sleep 2
                   let ws.aplnumdig = null
                   next field aplnumdig
                end if

                if lr_cty05g00.emsdat >= m_dtresol86 then
                   let d_cta00m01.ramcod = 531
                else
                   let d_cta00m01.ramcod = 31
                end if
             end if

             #--------------------------------------------------
             # Apolices do Ramo Automovel
             #--------------------------------------------------
             if d_cta00m01.ramcod = 31  or
                d_cta00m01.ramcod = 531  then


                if lr_cty05g00.vigfnl < today or lr_cty05g00.aplstt = "C" then

                   if lr_cty05g00.aplstt = "C" and
                      lr_cty05g00.vigfnl < today then
                      let msg.linha1 = "Esta apolice esta vencida e cancelada"
                      let msg.linha2 = "Procure uma apolice vigente e ativa"
                   else
                      if lr_cty05g00.aplstt = "C" then
                         let msg.linha1 = "Esta apolice esta cancelada"
                         let msg.linha2 = "Procure uma apolice ativa"
                      else
                         let msg.linha1 = "Esta apolice esta vencida"
                         let msg.linha2 = "Procure uma apolice vigente"
                      end if
                   end if

                   let msg.linha3 = "Ou consulte a supervisao."
                   let msg.linha4 = "Deseja prosseguir?"

                   call cts08g01("C","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4)
                        returning ws.confirma

                   if ws.confirma <> "S" then
                      next field aplnumdig
                   end if

                end if

             end if

             #--------------------------------------------------
             # Apolices de Ramos Elementares/Vida/Transportes
             #--------------------------------------------------
             if ws.ramo  =  "RE"   then
                #-- Obter dados apolice RE --#
                call cty06g00_dados_apolice(d_cta00m01.succod
                                           ,d_cta00m01.ramcod
                                           ,ws.aplnumdig
                                           ,m_ramsgl)
                returning lr_cty06g00.*

                if lr_cty06g00.resultado = 3 then
                   call errorlog(lr_cty06g00.mensagem)
                   exit input
                else
                   if lr_cty06g00.resultado = 2 then
                      call errorlog(lr_cty06g00.mensagem)
                   end if
                end if

                if lr_cty06g00.aplstt is null then
                   error " Apolice de RAMOS ELEMENTARES nao cadastrada!" , ws.aplnumdig sleep 2
                   let ws.aplnumdig = null
                   next field aplnumdig
                end if

                 let mr_documento.edsnumref = lr_cty06g00.edsnumref

                if lr_cty06g00.vigfnl < today or lr_cty06g00.aplstt = "C" then

                   if lr_cty06g00.aplstt = "C" and
                      lr_cty06g00.vigfnl < today then
                      let msg.linha1 = "Esta apolice esta vencida e cancelada"
                      let msg.linha2 = "Procure uma apolice vigente e ativa"
                   else
                      if lr_cty06g00.aplstt = "C" then
                         let msg.linha1 = "Esta apolice esta cancelada"
                         let msg.linha2 = "Procure uma apolice ativa"
                      else
                         let msg.linha1 = "Esta apolice esta vencida"
                         let msg.linha2 = "Procure uma apolice vigente"
                      end if
                   end if

                   let msg.linha3 = "Ou consulte a supervisao."
                   let msg.linha4 = "Deseja prosseguir?"

                   call cts08g01("C","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4)
                        returning ws.confirma

                   if ws.confirma <> "S" then
                      next field aplnumdig
                   end if

                end if


                if mr_ppt.cmnnumdig is not null then
                   let aux_segnumdig = mr_ppt.segnumdig
                   let g_dctoarray[1].segnumdig = aux_segnumdig
                   let g_dctoarray[1].prporg    = aux_prporg
                   let g_dctoarray[1].prpnumdig = aux_prpnumdig
                else
                   let g_dctoarray[1].segnumdig = lr_cty06g00.segnumdig
                   let g_dctoarray[1].prporg    = lr_cty06g00.prporg
                   let g_dctoarray[1].prpnumdig = lr_cty06g00.prpnumdig
                end if

                let g_index   = 1
                let g_dctoarray[1].succod    = d_cta00m01.succod
                let g_dctoarray[1].ramcod    = d_cta00m01.ramcod
                let g_dctoarray[1].aplnumdig = ws.aplnumdig

                exit input
             end if
          end if

          if d_cta00m01.ramcod  <>  31 and
             d_cta00m01.ramcod  <> 531 then
             if d_cta00m01.ramcod  = 171 or
                d_cta00m01.ramcod  = 195 then
                next field etpctrnum
             else
                next field segnom
             end if
          else
             if d_cta00m01.aplnumdig  is null  then
                next field segnom
             end if
          end if

#----------------------Before-Itmnumdig-----------------------------------------
       before field itmnumdig
          display by name d_cta00m01.itmnumdig attribute (reverse)

#----------------------After-Itmnumdig-----------------------------------------

       after  field itmnumdig
          display by name d_cta00m01.itmnumdig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize d_cta00m01.itmnumdig  to null
             display by name d_cta00m01.itmnumdig
             next field aplnumdig
          end if

          if d_cta00m01.itmnumdig  =  0    then
             initialize  d_cta00m01.itmnumdig  to null
             display by name d_cta00m01.itmnumdig
          end if

          initialize  ws.itmnumdig  to null

          if d_cta00m01.aplnumdig  is not null   then
             let g_index                        =  1
             let g_dctoarray[g_index].succod    =  d_cta00m01.succod
             let g_dctoarray[g_index].aplnumdig =  d_cta00m01.aplnumdig

             if d_cta00m01.itmnumdig is null   then
                call cta00m13(d_cta00m01.succod, ws.aplnumdig)
                     returning d_cta00m01.itmnumdig

                if d_cta00m01.itmnumdig   is null   then
                   error " Nenhum item  da apolice foi selecionado!"
                   next field  itmnumdig
                else
                   display by name d_cta00m01.itmnumdig
                end if
             end if

             call F_FUNDIGIT_DIGITO11 (d_cta00m01.itmnumdig)
                  returning ws.itmnumdig

             if ws.itmnumdig  is null   then
                error " Problemas no digito do item. AVISE A INFORMATICA!"
                next field itmnumdig
             end if

             #-- Consistir o item na apolice --#
             let l_flag = cty05g00_consiste_item(d_cta00m01.succod
                                                ,ws.aplnumdig
                                                ,ws.itmnumdig)

             if l_flag = 2 then
                error " Item informado nao existe nesta apolice!"
                let d_cta00m01.itmnumdig = null
                next field itmnumdig
             end if

             #-- Obter ultima situacao da apolice de Auto --#

             call f_funapol_ultima_situacao
                  (d_cta00m01.succod, ws.aplnumdig, ws.itmnumdig)
                   returning  g_funapol.*

             if g_funapol.resultado <> "O"   then
                error " Ultima situacao da apolice nao encontrada.",
                      " AVISE A INFORMATICA!"
                next field succod
             end if
             exit input
          else
             if d_cta00m01.itmnumdig  is not null   then
                error " Numero da apolice deve ser informado!"
                next field aplnumdig
             end if
          end if

       before field etpctrnum
          display by name d_cta00m01.etpctrnum attribute (reverse)

      after  field etpctrnum
         display by name d_cta00m01.etpctrnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            let d_cta00m01.etpctrnum = null
            next field itmnumdig
         end if

         if d_cta00m01.etpctrnum is not null then

            call framc400_retorna_apolice(d_cta00m01.etpctrnum)
                 returning l_result, ws.succod, ws.ramcod, ws.aplnumdig

            if l_result = 1 then ##
               error 'Certificado nao localizado'
               next field etpctrnum
            else
               let d_cta00m01.succod = ws.succod
               let d_cta00m01.ramcod = ws.ramcod
               let d_cta00m01.aplnumdig = ws.aplnumdig
               exit input
            end if

         end if


#---------------Before-Vcllicnum-----------------------------------------
      before field vcllicnum
         display by name d_cta00m01.vcllicnum attribute (reverse)

#-----------------------After-Vcllicnum-----------------------------------
      after field vcllicnum
         display by name d_cta00m01.vcllicnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            let d_cta00m01.vcllicnum = null

            if l_flag_acesso = 0 then
               next field c24soltipcod
            end if

            display by name d_cta00m01.vcllicnum

            if d_cta00m01.ramcod     <>  31   or
               d_cta00m01.ramcod     <> 531   or
               d_cta00m01.itmnumdig  is null  then
               let d_cta00m01.aplnumdig  = null
               let ws.aplnumdig          = null
               let g_documento.aplnumdig = null
               next field flgcar
            end if
            next field itmnumdig
         end if

         if d_cta00m01.vcllicnum  is not null  and
            d_cta00m01.ramcod     <> 16        and
            d_cta00m01.ramcod     <> 31        and
            d_cta00m01.ramcod     <> 524       and
            d_cta00m01.ramcod     <> 531       then
            error " Localizacao por licenca somente ramo",
                  " Automovel/Garantia Estendida!"
            next field vcllicnum
         end if


         if d_cta00m01.vcllicnum is not null and
            d_cta00m01.vcllicnum <> " "      then
            let d_cta00m01.vclchsfnl  = null
            let ws.aplnumdig          = null
            let ws.itmnumdig          = null
            let ws.ramcod             = null

            if d_cta00m01.ramcod = 31   or
               d_cta00m01.ramcod = 531   then

               call cta00m02(d_cta00m01.vcllicnum)
                    returning d_cta00m01.succod,
                              ws.ramcod ,
                              ws.aplnumdig,
                              ws.itmnumdig,
                              d_cta00m01.prporg,
                              d_cta00m01.prpnumdig
            else
               if d_cta00m01.ramcod = 16   or
                  d_cta00m01.ramcod = 524   then

                  call cta01m27(d_cta00m01.vcllicnum)
                       returning d_cta00m01.succod,
                                 ws.aplnumdig,
                                 ws.ramcod
               end if
            end if

            if ws.aplnumdig is null  then
              if d_cta00m01.prporg is null then
                call cts75m00_rec_placa_azul(d_cta00m01.vcllicnum,"")
                     returning m_retorno
                  if m_retorno = 1 then
                     call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA AZUL",
                                    "INFORME O NUMERO 4004-3700 ",
                                    "E TRANSFIRA O CONTATO PARA 20104","")
                       returning ws.confirma
                  else
                     call cts75m00_rec_placa_itau(d_cta00m01.vcllicnum)
                          returning m_retorno
                     if m_retorno = 1 then
	                     call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA ITAU ",
	                                    "INFORME O NUMERO 3003-1010 ",
	                                    " E TRANSFIRA CONTATO PARA 20231","")
	                       returning ws.confirma
                     else
                        error " Nenhuma apolice ou proposta foi selecionada!"
                        let d_cta00m01.succod = l_salva_succod
                     end if
                  end if
               next field vcllicnum
               else
                    display by name d_cta00m01.prporg
                    display by name d_cta00m01.prpnumdig
                    next field prpnumdig
               end if
            end if

            let d_cta00m01.ramcod = ws.ramcod

            exit input
         end if

         next field succod


#-------------------------Before-Segnom-----------------------------------------
       before field segnom
          display by name d_cta00m01.segnom attribute (reverse)

#-------------------------After-Segnom-----------------------------------------

       after  field segnom
         display by name d_cta00m01.segnom

         if d_cta00m01.segnom is not null and
            d_cta00m01.segnom <> " "      then
            let ws.segnom   = d_cta00m01.segnom  clipped ,"*"

            for l_cont  = 1 to length(ws.segnom)
                let l_asterisco = ws.segnom[l_cont ,l_cont ]
                if l_asterisco = " " then
                   continue for
                end if
                if l_asterisco matches "[*]" then
                   Error "Nome do segurado nao pode começar com(*)!" sleep 2
                   next field segnom
                end if
                exit for
            end for
         end if

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.segnom  to null
            initialize d_cta00m01.pestip to null
            display by name d_cta00m01.segnom
            display by name d_cta00m01.pestip

            next field aplnumdig
         end if

#------------------------Before-Pestip-----------------------------------------
       before field pestip
          display by name d_cta00m01.pestip attribute (reverse)

#-------------------------After-Pestip-----------------------------------------
       after  field pestip
          display by name d_cta00m01.pestip

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             let d_cta00m01.flgcar = "N"
             initialize d_cta00m01.cgccpfnum  to null
             initialize d_cta00m01.cgcord     to null
             initialize d_cta00m01.cgccpfdig  to null
             display by name d_cta00m01.flgcar
             display by name d_cta00m01.cgccpfnum
             display by name d_cta00m01.cgcord
             display by name d_cta00m01.cgccpfdig
             next field segnom
          end if

          if d_cta00m01.pestip is not null  and
             d_cta00m01.pestip <>  " "      and
             d_cta00m01.pestip <>  "F"      and
             d_cta00m01.pestip <>  "J"      then
             error " Tipo de pessoa invalido!"
             next field pestip
          end if


          if d_cta00m01.segnom is null or
             d_cta00m01.segnom =  " "  then
             next field cgccpfnum
          end if

          if d_cta00m01.transp  =  "S"  then
             # quando transporte nao criticar limite
          else
             let ws.tamanho = (length (d_cta00m01.segnom))
             if  ws.tamanho < 10  then
                 error " Complemente o nome do segurado (minimo 10 caracteres)!"
                 next field segnom
             end if
          end if

          let ws.segnom   = d_cta00m01.segnom
          let ws.contador = 0

          #-- Obter quantidade de segurados com o mesmo nome --#

          call cty15g00_qtd_segurado(ws.segnom       ,
                                     l_nullo         ,
                                     l_nullo         ,
                                     l_nullo         ,
                                     l_nullo         )
          returning lr_resultado.resultado
                   ,l_qtd_segnom

          if l_qtd_segnom = 0 or
             l_qtd_segnom is null then
             error " Nenhum segurado foi localizado!"
             next field segnom
          else
             if l_qtd_segnom > 150  then
                error " Mais de 150 registros selecionados,",
                      " complemente o nome do segurado!"
                next field segnom
             end if
          end if


          if d_cta00m01.transp = "S"  then
             call cta00m01_trata_transp(d_cta00m01.segnom,
                                        d_cta00m01.pestip,
                                        d_cta00m01.cgccpfnum,
                                        d_cta00m01.cgcord,
                                        d_cta00m01.cgccpfdig)
                  returning ws.msg              ,ws.campo,
                            d_cta00m01.succod   ,d_cta00m01.ramcod,
                            d_cta00m01.aplnumdig,d_cta00m01.itmnumdig,
                            d_cta00m01.prporg   ,d_cta00m01.prpnumdig,
                            ws.ramo
             if ws.msg is not null then
                display by name d_cta00m01.*
                error ws.msg
                case ws.campo
                     when "transp"     next field transp
                     when "prporg"     next field prporg
                     when "aplnumdig"  next field aplnumdig
                     when "itmnumdig"  next field itmnumdig
                end case
             end if
             let ws.aplnumdig = d_cta00m01.aplnumdig
             exit input
          end if

          call cty15g00_pesquisa_auto_re (d_cta00m01.ramcod    ,
                                          d_cta00m01.segnom    ,
                                          d_cta00m01.cgccpfnum ,
                                          d_cta00m01.cgcord    ,
                                          d_cta00m01.cgccpfdig ,
                                          d_cta00m01.pestip)
                                returning mr_documento.ramcod  ,
                                          ws.succod            ,
                                          ws.aplnumdig         ,
                                          ws.itmnumdig

          if ws.succod    is null  or
             ws.aplnumdig is null  then
             error " Nenhuma apolice foi selecionada!!"
             next field segnom
          end if

          let d_cta00m01.succod = ws.succod

          if mr_documento.ramcod is not null then
             let d_cta00m01.ramcod = mr_documento.ramcod
          end if

          exit input

#----------------------Before-Cgccpfnum-----------------------------------------
       before field cgccpfnum
          display by name d_cta00m01.cgccpfnum   attribute(reverse)

#-----------------------After-Cgccpfnum-----------------------------------------

       after  field cgccpfnum
          display by name d_cta00m01.cgccpfnum

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field pestip
          end if

          if d_cta00m01.pestip is not null and
             d_cta00m01.pestip <> " "      then

             if d_cta00m01.cgccpfnum   is null   or
                d_cta00m01.cgccpfnum   =  0      then
                error " Numero do CGC/CPF deve ser informado!"
                next field cgccpfnum
             end if
          else
             if d_cta00m01.cgccpfnum   is not null   then
                error " Tipo de pessoa deve ser informado!"
                next field cgccpfnum
             else
                initialize d_cta00m01.cgcord     to null
                initialize d_cta00m01.cgccpfdig  to null
                display by name d_cta00m01.cgcord
                display by name d_cta00m01.cgccpfdig

                next field prporg

             end if
          end if

          if d_cta00m01.pestip =  "F"   then
             next field cgccpfdig
          end if

#-------------------------Before-Cgcord-----------------------------------------
       before field cgcord
          display by name d_cta00m01.cgcord   attribute(reverse)

#-------------------------After-Cgcord-----------------------------------------
       after  field cgcord
          display by name d_cta00m01.cgcord

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field cgccpfnum
          end if

          if d_cta00m01.cgcord   is null   or
             d_cta00m01.cgcord   =  0      then
             error " Filial do CGC deve ser informada!"
             next field cgcord
          end if

#----------------------Before-Cgccpfdig-----------------------------------------
       before field cgccpfdig
          display by name d_cta00m01.cgccpfdig  attribute(reverse)

#-----------------------After-Cgccpfdig-----------------------------------------

       after  field cgccpfdig
          display by name d_cta00m01.cgccpfdig

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             if d_cta00m01.pestip =  "J"  then
                next field cgcord
             else
                next field cgccpfnum
             end if
          end if

          if d_cta00m01.cgccpfdig   is null   then
             error " Digito do CGC/CPF deve ser informado!"
             next field cgccpfdig
          end if

          if d_cta00m01.pestip =  "J"    then
             call F_FUNDIGIT_DIGITOCGC(d_cta00m01.cgccpfnum,
                                       d_cta00m01.cgcord)
                  returning ws.cgccpfdig
          else
             call F_FUNDIGIT_DIGITOCPF(d_cta00m01.cgccpfnum)
                  returning ws.cgccpfdig
          end if

          if ws.cgccpfdig          is null            or
             d_cta00m01.cgccpfdig  <>  ws.cgccpfdig   then
             error " Digito do CGC/CPF incorreto!"
             next field cgccpfdig
          end if

          if d_cta00m01.flgcar = "S" then


               let l_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(d_cta00m01.cgccpfnum ,
                                                                     d_cta00m01.cgcord    ,
                                                                     d_cta00m01.cgccpfdig )

               call ffpfc073_qtd_prop(l_ffpfc073.cgccpfnumdig ,
                                      d_cta00m01.pestip       )
               returning l_ffpfc073.mens,
                         l_ffpfc073.erro,
                         l_ffpfc073.qtd

               if l_ffpfc073.erro <> 0 or
                  l_ffpfc073.qtd  =  0 then
                  if cts08g01("C","S",'','PROPONENTE NAO LOCALIZADO! ',"DESEJA PROSSEGUIR ATENDIMENTO ?",'') = 'N' then
                     let g_crtdvgflg = "N"
                     next field cgccpfnum
                  else
                     ## colocar global para atendimento sem proponente localizado
                     let g_crtdvgflg = "S"
                  end if
               end if

               if d_cta00m01.cgcord is null then
                  let d_cta00m01.cgcord = 0
               end if

               let mr_documento.cgccpfnum     = d_cta00m01.cgccpfnum
               let mr_documento.cgcord        = d_cta00m01.cgcord
               let mr_documento.cgccpfdig     = d_cta00m01.cgccpfdig
               let g_documento.ciaempcod      = 40

               exit input
          else
                 let g_documento.ciaempcod = 1
          end if



          #//Obter quantidade de segurados com o mesmo cpf/cgc

          call cty15g00_qtd_segurado(l_nullo               ,
                                     d_cta00m01.cgccpfnum  ,
                                     d_cta00m01.cgcord     ,
                                     d_cta00m01.cgccpfdig  ,
                                     d_cta00m01.pestip     )
          returning lr_resultado.resultado
                   ,ws.contador

          if (ws.contador > 0  and
              ws.contador < 150) or
              ws.contador = 0 then
             call cts75m00_rec_cpfcgc_azul (d_cta00m01.pestip,
                                            d_cta00m01.cgccpfnum,
                      									    d_cta00m01.cgcord,
                      									    d_cta00m01.cgccpfdig,
                      									    d_cta00m01.ramcod)
              returning m_retorno
             if m_retorno = 1 then
                call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA AZUL ",
                                "INFORME O NUMERO 4004-3700 ",
                                "E TRANSFIRA O CONTATO PARA 20104","")
                       returning ws.confirma
             else
                call cts75m00_rec_cgccpf_itau (d_cta00m01.pestip,
                                               d_cta00m01.cgccpfnum,
                      									       d_cta00m01.cgcord,
                      									       d_cta00m01.cgccpfdig,
                      									       d_cta00m01.ramcod)
                    returning m_retorno
                if m_retorno = 1 then
		                call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA ITAU ",
	                                 "INFORME O NUMERO 3003-1010 ",
	                                 " E TRANSFIRA CONTATO PARA 20231","")
		                      returning ws.confirma
                end if
             end if
          end if
		        if ws.contador = 0 and
		           m_retorno = 0 then
		            error " Nenhum segurado foi localizado!"
		            next field cgccpfnum
		        else
			          if ws.contador > 150 then
			             error " Limite de consulta excedido, mais de 150 segurados!"
			             next field cgccpfnum
			          end if
			      end if

          if d_cta00m01.transp = "S"  then


             call cta00m01_trata_transp(d_cta00m01.segnom,
                                        d_cta00m01.pestip,
                                        d_cta00m01.cgccpfnum,
                                        d_cta00m01.cgcord,
                                        d_cta00m01.cgccpfdig)
                  returning ws.msg              ,ws.campo,
                            d_cta00m01.succod   ,d_cta00m01.ramcod,
                            d_cta00m01.aplnumdig,d_cta00m01.itmnumdig,
                            d_cta00m01.prporg   ,d_cta00m01.prpnumdig,
                            ws.ramo
             if ws.msg is not null then
                display by name d_cta00m01.*
                error ws.msg
                case ws.campo
                     when "transp"     next field transp
                     when "prporg"     next field prporg
                     when "aplnumdig"  next field aplnumdig
                     when "itmnumdig"  next field itmnumdig
                end case
             end if
             let ws.aplnumdig = d_cta00m01.aplnumdig
             exit input
          end if

          call cty15g00_pesquisa_auto_re (d_cta00m01.ramcod   ,
                                          d_cta00m01.segnom   ,
                                          d_cta00m01.cgccpfnum,
                                          d_cta00m01.cgcord   ,
                                          d_cta00m01.cgccpfdig,
                                          d_cta00m01.pestip)
                                returning mr_documento.ramcod,
                                          ws.succod          ,
                                          ws.aplnumdig       ,
                                          ws.itmnumdig

          if ws.succod    is null  or
             ws.aplnumdig is null  then


             if g_documento.prporg is not null then

                let d_cta00m01.prporg = g_documento.prporg
                let d_cta00m01.prpnumdig = g_documento.prpnumdig

             else
                error " Nenhuma apolice foi selecionada!!!"

                next field cgccpfnum
             end if

          end if
          let d_cta00m01.succod = ws.succod

          if mr_documento.ramcod is not null then
             let d_cta00m01.ramcod = mr_documento.ramcod

          end if
          exit input



#---------------------Before-Vclchsfnl-----------------------------------------
      before field vclchsfnl
         display by name d_cta00m01.vclchsfnl attribute (reverse)

#-----------------------After-Vclchsfnl-----------------------------------------

      after  field vclchsfnl
         display by name d_cta00m01.vclchsfnl
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.vclchsfnl  to null
            display by name d_cta00m01.vclchsfnl
            next field transp
         end if
         if d_cta00m01.vclchsfnl  is not null  and
            d_cta00m01.ramcod  <> 31  and
            d_cta00m01.ramcod  <> 531 then
            error " Localizacao por chassi somente para ramo Automovel!"
            next field vclchsfnl
         end if
         if d_cta00m01.vclchsfnl  is not null  then
            initialize d_cta00m01.vcllicnum to null
            call cta00m04(d_cta00m01.vclchsfnl)
                 returning d_cta00m01.succod,
                           ws.ramcod        ,
                           ws.aplnumdig     ,
                           ws.itmnumdig
            if d_cta00m01.succod is null then
               error " Nenhuma apolice foi selecionada!!!!"
               next field vclchsfnl
            end if
            let d_cta00m01.ramcod = ws.ramcod
            exit input
         else
               next field sinramcod
         end if


#----------------------------Before-Vp-----------------------------------------
      before field vp
         display by name d_cta00m01.vp        attribute (reverse)

#----------------------------After-Vp-----------------------------------------

      after  field vp
         display by name d_cta00m01.vp
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.vp        to null
            display by name d_cta00m01.vp
            next field prporg
         end if

         if d_cta00m01.vp <> "S" and
            d_cta00m01.vp <> "N" and
            d_cta00m01.vp <> " " then
            error "Vist.Previa S ou N"
            next field vp
         end if
         if d_cta00m01.vp  =  "S"  then
            let ws.grlchv = g_issk.funmat using "&&&&&&",g_issk.maqsgl clipped
            let ws.param  = "ct24h",ws.grlchv

            #Obter quantidade de registro com grlchv
            call cta12m00_seleciona_datkgeral(ws.param)
               returning lr_resultado.resultado
                        ,lr_resultado.mensagem
                        ,ws.count
            if ws.count > 0  then
               #Remover de datkgeral
               call cta12m00_remove_datkgeral(ws.param)
                  returning lr_resultado.resultado
                           ,lr_resultado.mensagem
               if lr_resultado.resultado <> 1 then
                  next field vp
               end if
            end if

            call chama_prog("Con_Aceit","av_previa",ws.param) returning ws.ret
            if ws.ret = -1 then
               error " Sistema nao disponivel no momento!"
               next field vp
            end if

            let d_cta00m01.vp = null
            next field vp

         end if


#----------------------------Before-Vd-----------------------------------------
      before field vd
         display by name d_cta00m01.vd        attribute (reverse)

#----------------------------After-Vd-----------------------------------------

      after  field vd
         display by name d_cta00m01.vd
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.vd        to null
            display by name d_cta00m01.vd
            next field vp
         end if
         if d_cta00m01.vd <> "S" and
            d_cta00m01.vd <> "N" and
            d_cta00m01.vd <> " " then
            error "Vistoria Domiciliar S ou N"
            next field vd
         end if

         if d_cta00m01.vd  =  "S"  then

            let ws.grlchv = g_issk.funmat using "&&&&&&",g_issk.maqsgl clipped
            let ws.param  = "ct24h",ws.grlchv


            call chama_prog("Vpr_ct24h","ctg9",ws.param) returning ws.ret
            if ws.ret = -1 then
               error " Sistema nao disponivel no momento!"
               next field vd
            end if

            let d_cta00m01.vd = null
            next field vd
         end if



#----------------------------Before-Cp-----------------------------------------
      before field cp
         display by name d_cta00m01.cp        attribute (reverse)

#----------------------------After-Cp-----------------------------------------

      after  field cp
         display by name d_cta00m01.cp
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.cp        to null
            display by name d_cta00m01.cp
            next field vd
         end if
         if d_cta00m01.cp <> "S" and
            d_cta00m01.cp <> "N" and
            d_cta00m01.cp <> " " then
            error "Cobertura Provisoria S ou N"
            next field cp
         end if

         if d_cta00m01.cp  =  "S"  then

            let ws.grlchv = g_issk.funmat using "&&&&&&",g_issk.maqsgl clipped
            let ws.param  = "ct24h",ws.grlchv


            call chama_prog("Con_Aceit","av_pccob",ws.param) returning ws.ret
            if ws.ret = -1 then
               error " Sistema nao disponivel no momento!"
               next field cp
            end if

            let d_cta00m01.cp = null
            next field cp

         end if


#---------------------Before-Sinramcod-----------------------------------------
      before field sinramcod     # sinistro
         display by name d_cta00m01.sinramcod attribute (reverse)

#-----------------------After-Sinramcod-----------------------------------------

      after  field sinramcod
         display by name d_cta00m01.sinramcod

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize d_cta00m01.sinramcod to null
             initialize d_cta00m01.sinano    to null
             initialize d_cta00m01.sinnum    to null
             display by name d_cta00m01.sinramcod
             display by name d_cta00m01.sinano
             display by name d_cta00m01.sinnum

             if  d_cta00m01.ramcod = 31    or
                 d_cta00m01.ramcod = 531   then
                 next field vclchsfnl
             else

                     next field cgccpfnum

             end if
         end if

         if  d_cta00m01.sinramcod is null  then
             next field sinvstnum
         end if
#PSI183431 -Robson -inicio
         #Obter descricao do ramo
         call cty10g00_descricao_ramo(d_cta00m01.sinramcod, 1)
            returning lr_resultado.resultado
                     ,lr_resultado.mensagem
                     ,l_descricao
                     ,m_ramsgl

         if l_descricao is null then
             error " Ramo nao cadastrado!"
             call c24geral10()
                  returning d_cta00m01.sinramcod, ws.sinramnom
             next field sinramcod
         end if

#------------------------Before-Sinnum-----------------------------------------
      before field sinnum
         display by name d_cta00m01.sinnum    attribute (reverse)

#-------------------------After-Sinnum-----------------------------------------
      after  field sinnum
         display by name d_cta00m01.sinnum

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinramcod
         end if

         if  d_cta00m01.sinnum is null  then
             error " Numero do sinistro deve ser informado !"
             next field sinnum
         end if

#-------------------------Before-Sinano-----------------------------------------
      before field sinano
         display by name d_cta00m01.sinano    attribute (reverse)

#--------------------------After-Sinano-----------------------------------------
      after  field sinano
         display by name d_cta00m01.sinano

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinnum
         end if

         if  d_cta00m01.sinano is null  then
             error " Ano do sinistro deve ser informado ! "
             next field sinano
         end if

         #Consistir o nr do sinistro no sistema de sinistro
         call cty01g01_fsauc530(d_cta00m01.sinramcod
                               ,d_cta00m01.sinano
                               ,d_cta00m01.sinnum
                               ,d_cta00m01.sinvstano
                               ,d_cta00m01.sinvstnum)
            returning lr_resultado.resultado
                     ,lr_resultado.mensagem
                     ,ws.sinramcod
                     ,ws.sinano
                     ,ws.sinnum
                     ,ws.sinitmseq

         if  ws.sinramcod is null  or
             ws.sinano    is null  or
             ws.sinnum    is null  or
             ws.sinramcod is null  then
             error " Sinistro nao cadastrado ! "
             next field sinramcod
         else
             display by name ws.sinramcod
             display by name ws.sinano
             display by name ws.sinnum
             exit input
         end if

#---------------------Before-Sinvstnum-----------------------------------------
      before field sinvstnum    # F10/f10
         display by name d_cta00m01.sinvstnum attribute (reverse)

#-----------------------After-Sinvstnum-----------------------------------------
      after  field sinvstnum
         display by name d_cta00m01.sinvstnum

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if  d_cta00m01.sinano is not null  then
                 next field sinano
             else
                 next field sinramcod
             end if
         end if
         if  d_cta00m01.sinvstnum is null  then
             next field sinautnum
         else
            if d_cta00m01.sinvstnum < 600000 then    ## psi 189685 800000
               error "Este Aviso nao e Furto/Roubo"
               next field sinvstnum
            end if
            next field sinvstano
         end if

#-----------------------Before-Sinvsano-----------------------------------------
      before field sinvstano
         display by name d_cta00m01.sinvstano attribute (reverse)

#------------------------After-Sinvsano-----------------------------------------
      after  field sinvstano
         display by name d_cta00m01.sinvstano

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinvstnum
         end if

         if  d_cta00m01.sinvstano is null  then
             error " Ano da vistoria de sinistro deve ser informado ! "
             next field sinvstano
         end if


          # -> VERIFICA SE A VISTORIA(F10) EXISTE NA TABELA datmavssin
          # -> Data Implement: 21/08/06 - Lucas Scheid - Chamado: 6086640
          open c_cta00m01_003 using d_cta00m01.sinvstnum,
                                    d_cta00m01.sinvstano
          whenever error continue
          fetch c_cta00m01_003
          whenever error stop

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = notfound then
                error "Aviso FURTO/ROUBO nao encontrado !"
             else
                error "Erro SELECT c_cta00m01_003 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
             end if
             close c_cta00m01_003
             next field sinvstnum
          end if

          close c_cta00m01_003

#PSi183431 -Robson -inicio
         #Consistir o nr. do sinistro no sistema de Sinistro
         call cty01g01_fsauc530(d_cta00m01.sinramcod
                               ,d_cta00m01.sinano
                               ,d_cta00m01.sinnum
                               ,d_cta00m01.sinvstano
                               ,d_cta00m01.sinvstnum)
            returning lr_resultado.resultado
                     ,lr_resultado.mensagem
                     ,ws.sinramcod
                     ,ws.sinano
                     ,ws.sinnum
                     ,ws.sinitmseq

#PSI183431 -Robson -Fim
         if  ws.sinramcod is null  or
             ws.sinano    is null  or
             ws.sinnum    is null  or
             ws.sinramcod is null  then
          ## CT :186937   error " Vistoria de sinistro nao cadastrada ! "
             error " Vistoria ou Laudo de Sinistro nao cadastrados! "
             next field sinvstnum
         else
             display by name ws.sinramcod
             display by name ws.sinano
             display by name ws.sinnum
             exit input
         end if

#----------------------After-Sinautnum-----------------------------------------

     #------- Verifica existencia da vistoria sinistro de auto --------
     #------- Numero vistoria sinistro de auto --------
      after  field sinautnum     # V10/V11-v10/v11
         display by name d_cta00m01.sinautnum

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinvstnum
         end if
         if  d_cta00m01.sinautnum is null  then
             next field flgauto
         else
             if d_cta00m01.sinautnum < 600000 then  ## psi 189685 800000
                error "Este Numero nao e vistoria de sinistro"
                next field sinautnum
             end if
             next field sinautano
         end if

#---------------------Before-Sinautano-----------------------------------------

     #------- Ano vistoria sinistro de auto --------
      before field sinautano
         display by name d_cta00m01.sinautano attribute (reverse)

#----------------------After-Sinautano-----------------------------------------

      after  field sinautano
         display by name d_cta00m01.sinautano

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinautnum
         end if

         if  d_cta00m01.sinautano is null  then
             error " Ano da vistoria de sinistro AUTO nao informado !"
             next field sinautano
         end if

         # -> ACESSA A TABELA datrligsinvst BUSCANDO O lignum
         open ccta00m01013 using d_cta00m01.sinautnum,
                                 d_cta00m01.sinautano
         whenever error continue
         fetch ccta00m01013 into l_lignum
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let l_lignum = null
            else
               error "Erro SELECT ccta00m01013 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
               close ccta00m01013
               next field sinautnum
            end if
         end if

         close ccta00m01013

         if l_lignum is not null then
            # -> ACESSA A TABELA datmligacao BUSCANDO O ASSUNTO(c24astcod)
            open ccta00m01014 using l_lignum
            whenever error continue
            fetch ccta00m01014 into l_c24astcod
            whenever error stop

            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = notfound then
                  let l_c24astcod = null
               else
                  error "Erro SELECT ccta00m01014 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
                  close ccta00m01014
                  next field sinautnum
               end if
            end if

            close ccta00m01014

            if l_c24astcod is not null then
               if l_c24astcod = "B14" then # PROCESSO DE VIDROS
                  error "Este numero refere-se a um PROCESSO DE VIDROS(B14) !"
                  next field sinautnum
               end if
            end if

         end if

         # -> VERIFICA SE A VISTORIA EXISTE NA TABELA datmvstsin
         # -> Data Implement: 21/08/06 - Lucas Scheid - Chamado: 6086640
         open c_cta00m01_002 using d_cta00m01.sinautnum,
                                 d_cta00m01.sinautano
         whenever error continue
         fetch c_cta00m01_002
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error "Vistoria nao encontrada !"
            else
               error "Erro SELECT c_cta00m01_002 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
            end if
            close c_cta00m01_002
            next field sinautnum
         end if

         close c_cta00m01_002

#PSI183431 -Robson -inicio
         call cts14m06_documento(d_cta00m01.sinautnum
                                ,d_cta00m01.sinautano)
            returning lr_resultado.resultado
                     ,lr_resultado.mensagem
                     ,d_cta00m01.succod
                     ,ws.ramcod
                     ,d_cta00m01.aplnumdig
                     ,d_cta00m01.itmnumdig
                     ,d_cta00m01.prporg
                     ,d_cta00m01.prpnumdig

         if lr_resultado.resultado <> 1 then      # PSI183431 Daniel INICIO
            error "Vistoria Sinistro Auto nao cadastrada"
            let  d_cta00m01.sinautano = null
            let  d_cta00m01.sinautnum = null
            display by name d_cta00m01.sinautano
            display by name d_cta00m01.sinautnum
            next field flgauto                    # PSI183431 Daniel FIM
         else
            if d_cta00m01.aplnumdig is not null and
               d_cta00m01.aplnumdig > 0         then
               #Obter dados da apolice de Auto
               call cty05g00_dados_apolice(d_cta00m01.succod
                                          ,d_cta00m01.aplnumdig)
                  returning lr_cty05g00.*

               if lr_cty05g00.emsdat >= m_dtresol86 then
                  let ws.ramcod = 531
               else
                  let ws.ramcod = 31
               end if
               initialize d_cta00m01.prporg     to null
               initialize d_cta00m01.prpnumdig  to null
            end if
            if d_cta00m01.aplnumdig = 0 then
               initialize d_cta00m01.aplnumdig  to null
            end if
            let ws.aplnumdig   =   d_cta00m01.aplnumdig
            let ws.itmnumdig   =   d_cta00m01.itmnumdig
            if d_cta00m01.prporg    is not null and
               d_cta00m01.prpnumdig is not null then
               call cta00m01_trata_proposta(ws.ramo
                                           ,d_cta00m01.prporg
                                           ,d_cta00m01.prpnumdig
                                           ,0)
                  returning lr_resultado.resultado
                           ,lr_resultado.mensagem
                           ,d_cta00m01.succod
                           ,ws.ramcod
                           ,d_cta00m01.aplnumdig
                           ,d_cta00m01.itmnumdig
               if lr_resultado.resultado = 2 then
                  error "Proposta nao digitada para acompanhamento!"
                  next field sinautnum
               end if

                  let ws.aplnumdig = d_cta00m01.aplnumdig
                  let ws.itmnumdig = d_cta00m01.itmnumdig
                  if d_cta00m01.aplnumdig is null then # achou proposta sem
                                                       # apolice
                     let ws.ramcod = 531
                  #end if
               end if
            end if
            let d_cta00m01.ramcod = ws.ramcod
            exit input
         end if

#------------------------Before-Flgauto-----------------------------------------

      #------- FLG vistoria sinistro auto --------
       before field flgauto
          display by name d_cta00m01.flgauto attribute (reverse)

#-------------------------After-Flgauto-----------------------------------------

       after  field flgauto
          display by name d_cta00m01.flgauto

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field sinautano
          end if
          if  d_cta00m01.flgauto  is not null   and
              d_cta00m01.flgauto  <>    "S"     and
              d_cta00m01.flgauto  <>    "N"     then
              error "Consulta por data (S)im ou (N)ao !"
              next field flgauto
          end if
          if  d_cta00m01.flgauto  = "S"    then
              call cts14m02("cta00m01")
                     returning d_cta00m01.sinautnum,
                               d_cta00m01.sinautano
              if  d_cta00m01.sinautano is null or
                  d_cta00m01.sinautnum is null then
                  error "Nao existem vistorias programadas para pesquisa!"
                  exit input
              else
                  display by name d_cta00m01.sinautano
                  display by name d_cta00m01.sinautnum
                  next field sinautnum
              end if
          end if

#-----------------------Before-Sinrenum-----------------------------------------

     #------- Verifica existencia da vistoria sinistro de RE --------
     #------- Numero da vistoria sinistro de RE --------
      before field sinrenum     #V12/v12
         display by name d_cta00m01.sinrenum attribute (reverse)

#------------------------After-Sinrenum-----------------------------------------

      after  field sinrenum
         display by name d_cta00m01.sinrenum

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinautnum
         end if
         if  d_cta00m01.sinrenum  =  0    then
             initialize  d_cta00m01.sinrenum  to null
         end if
         if  d_cta00m01.sinrenum is null  then
             next field flgre
         else
             next field sinreano
         end if

#----------------------Before-Sinreano-----------------------------------------

     #------- Ano vistoria sinistro de RE   --------
      before field sinreano
         display by name d_cta00m01.sinreano attribute (reverse)

#------------------------After-Sinreano-----------------------------------------

      after  field sinreano
         display by name d_cta00m01.sinreano

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinrenum
         end if
         if  d_cta00m01.sinreano is null  then
             error " Ano da vistoria de sinistro RE nao informado !"
             next field sinreano
         end if

         #Consistir nr da vistoria
         call cts21m10_valida_vistoria(d_cta00m01.sinrenum
                                      ,d_cta00m01.sinreano)
            returning lr_resultado.resultado
                     ,lr_resultado.mensagem
         if lr_resultado.resultado = 2 then
             error "Vistoria Sin, RE  nao cadastrada"
             let  d_cta00m01.sinreano = null
             let  d_cta00m01.sinrenum = null
             display by name d_cta00m01.sinreano
             display by name d_cta00m01.sinrenum
             next field flgre
         else
             let m_lignum =  null
             initialize m_ret.* to  null
             call cts20g00_sinvst(d_cta00m01.sinrenum,
                                  d_cta00m01.sinreano,2)
                        returning m_lignum
             if  m_lignum is not null then
                 call cts20g01_docto(m_lignum)
                      returning d_cta00m01.succod,
                                ws.ramcod        ,
                                d_cta00m01.aplnumdig,
                                m_ret.itmnumdig,
                                m_ret.edsnumref,
                                d_cta00m01.prporg,
                                d_cta00m01.prpnumdig,
                                m_ret.fcapacorg,
                                m_ret.fcapacnum,
                                m_ret.itaciacod

             ---> Busca Nro. Seq. Local de Risco / Bloco para que
             ---> Atendente nao tenha que selecionar do Pop-up
	     initialize l_lclnumseq, l_rmerscseq to null

             select lclnumseq
                   ,rmerscseq
               into l_lclnumseq
                   ,l_rmerscseq
               from datmrsclcllig
              where lignum = m_lignum

             else
                error "Nao existe ligacao para Vistoria Sinistro RE"
                next field sinrenum
             end if
             if  d_cta00m01.aplnumdig is not null and
                 d_cta00m01.aplnumdig > 0         then
                 initialize d_cta00m01.prporg     to null
                 initialize d_cta00m01.prpnumdig  to null
             end if
             if  d_cta00m01.aplnumdig = 0 then
                 initialize d_cta00m01.aplnumdig  to null
             end if
             let ws.aplnumdig         = d_cta00m01.aplnumdig
             let ws.ramo              = "RE  "
             #********  ruiz - 29/05/02
             if  ws.ramcod            = 31  or
                 ws.ramcod            = 531  then
                 let ws.ramo          = "AUTO"
                 let ws.itmnumdig     = m_ret.itmnumdig
             end if
             if d_cta00m01.prporg    is not null and
                d_cta00m01.prpnumdig is not null then
#PSI183431 -Robson -inicio
                call cta00m01_trata_proposta(ws.ramo
                                            ,d_cta00m01.prporg
                                            ,d_cta00m01.prpnumdig
                                            ,0)
                   returning lr_resultado.resultado
                            ,lr_resultado.mensagem
                            ,d_cta00m01.succod
                            ,d_cta00m01.ramcod
                            ,d_cta00m01.aplnumdig
                            ,d_cta00m01.itmnumdig
                if lr_resultado.resultado = 2 then
                   error " Proposta nao digitada para acompanhamento!"
                   next field sinrenum
                end if
                   let ws.aplnumdig = d_cta00m01.aplnumdig
                   let ws.itmnumdig = d_cta00m01.itmnumdig
                   if d_cta00m01.aplnumdig is null then
                      let d_cta00m01.ramcod = 531
                   end if
#PSI183431 -Robson -fim
             else
                let d_cta00m01.ramcod = ws.ramcod
             end if
             exit input
         end if

#-------------------------Before-Flgre-----------------------------------------

      #------- FLG vistoria sinistro RE --------
       before field flgre
          display by name d_cta00m01.flgre attribute (reverse)

#---------------------------After-Flgre-----------------------------------------

       after  field flgre
          display by name d_cta00m01.flgre

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field sinrenum
          end if
          if  d_cta00m01.flgre  is not null   and
              d_cta00m01.flgre  <>    "S"     and
              d_cta00m01.flgre  <>    "N"     then
              error "Consulta por data (S)im ou (N)ao !"
              next field flgre
          end if
          if  d_cta00m01.flgre    = "S"    then
              call cts21m05("cta00m01")
                             returning d_cta00m01.sinrenum,
                                       d_cta00m01.sinreano
              if  d_cta00m01.sinreano is null or
                  d_cta00m01.sinrenum is null then
                  error "Nao existem vistorias programadas para pesquisa!"
                  exit input
              else
                  display by name d_cta00m01.sinreano
                  display by name d_cta00m01.sinrenum
                  next field sinrenum
              end if
          end if

#-----------------------After-Sinavsnum-----------------------------------------

     #------- Verifica existencia do aviso de sinistro  --------
     #------- Numero aviso  sinistro de auto --------
      after  field sinavsnum     #N10/N11-n10/n11
         display by name d_cta00m01.sinavsnum

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinrenum
         end if
         if  d_cta00m01.sinavsnum is null  then
             next field flgavs
         else
             next field sinavsano
         end if

#----------------------Before-Sinavsano-----------------------------------------

     #------- Ano vistoria sinistro de auto --------
      before field sinavsano
         display by name d_cta00m01.sinavsano attribute (reverse)

#-----------------------After-Sinavsano-----------------------------------------

      after  field sinavsano
         display by name d_cta00m01.sinavsano

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinavsnum
         end if
         if  d_cta00m01.sinavsano is null  then
             error " Ano da vistoria de sinistro AUTO nao informado !"
             next field sinavsano
         end if
         call cta02m27(d_cta00m01.sinavsnum,
                       d_cta00m01.sinavsano)
            returning d_cta00m01.succod
                     ,d_cta00m01.aplnumdig
                     ,d_cta00m01.itmnumdig
                     ,d_cta00m01.prporg
                     ,d_cta00m01.prpnumdig

          if d_cta00m01.succod is null and
             d_cta00m01.prporg is null then
             error "Aviso de Sin, Auto nao cadastrado"
             let  d_cta00m01.sinavsano = null
             let  d_cta00m01.sinavsnum = null
             display by name d_cta00m01.sinavsano
             display by name d_cta00m01.sinavsnum
             next field flgavs
          end if

          ## Dani
          if d_cta00m01.succod    is not null and
             d_cta00m01.aplnumdig is not null and
             d_cta00m01.itmnumdig is not null then
             let ws.succod    = d_cta00m01.succod
             let ws.aplnumdig = d_cta00m01.aplnumdig
             let ws.itmnumdig = d_cta00m01.itmnumdig
          end if

         if d_cta00m01.prpnumdig is not null then
            call cts20g00_sinavs(d_cta00m01.sinavsnum,
                                 d_cta00m01.sinavsano)
                       returning m_lignum
            #Obter proposta atraves da ligacao
            call cts20g00_proposta(m_lignum)
               returning lr_resultado.resultado
                        ,lr_resultado.mensagem
                        ,d_cta00m01.prporg
                        ,d_cta00m01.prpnumdig
            let ws.aplnumdig         = d_cta00m01.aplnumdig
            let ws.itmnumdig         = d_cta00m01.itmnumdig
            if d_cta00m01.prporg    is not null and
               d_cta00m01.prpnumdig is not null then
               call cta00m01_trata_proposta(ws.ramo
                                      ,d_cta00m01.prporg
                                      ,d_cta00m01.prpnumdig
                                      ,0)
                  returning lr_resultado.resultado
                           ,lr_resultado.mensagem
                           ,d_cta00m01.succod
                           ,d_cta00m01.ramcod
                           ,d_cta00m01.aplnumdig
                           ,d_cta00m01.itmnumdig
               if lr_resultado.resultado = 2 then
                  error " Proposta nao digitada para acompanhamento!"
                  next field sinavsnum
               end if
                  let ws.aplnumdig = d_cta00m01.aplnumdig
                  let ws.itmnumdig = d_cta00m01.itmnumdig
                  if d_cta00m01.aplnumdig is null then
                     let ws.ramcod = 531
                  end if
            else
               #Obter dados da apolice de Auto

               call cty05g00_dados_apolice(d_cta00m01.succod
                                          ,d_cta00m01.aplnumdig)
                  returning lr_cty05g00.*
               if lr_cty05g00.emsdat is null then
                  let ws.ramcod = 531
               else
                  if lr_cty05g00.emsdat >= m_dtresol86 then
                     let ws.ramcod = 531
                  else
                     let ws.ramcod = 31
                  end if
               end if
            end if
         end if

         # -- CT 256056 - Katiucia -- #
         if ws.ramcod is not null then
            let d_cta00m01.ramcod = ws.ramcod
         end if
         exit input

#------------------------Before-Flgavs-----------------------------------------

      #------- FLG aviso de sinistro auto --------
       before field flgavs
          display by name d_cta00m01.flgavs attribute (reverse)

#-------------------------After-Flgavs-----------------------------------------

       after  field flgavs
          display by name d_cta00m01.flgavs

          if  fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field sinavsnum
          end if
          if  d_cta00m01.flgavs  is not null   and
              d_cta00m01.flgavs  <>    "S"     and
              d_cta00m01.flgavs  <>    "N"     then
              error "Consulta por data (S)im ou (N)ao !"
              next field flgavs
          end if
          if  d_cta00m01.flgavs  = "S"    then
              call cts18m02("cta00m01")
                   returning d_cta00m01.sinavsnum,
                             d_cta00m01.sinavsano
              if  d_cta00m01.sinavsano is null or
                  d_cta00m01.sinavsnum is null then
                  error "Nao existem avisos para pesquisas!"
                  exit input
              else
                  display by name d_cta00m01.sinavsano
                  display by name d_cta00m01.sinavsnum
                  next field sinavsnum
              end if
          end if
          if  d_cta00m01.flgavs  is null or
              d_cta00m01.flgavs = 'S'    or
              d_cta00m01.flgavs = 'N'    then
              next field semdocto
          end if

#-----------------------Before-Semdocto-----------------------------------------

     #------------------------------------------------------------------
     #inicio psi172413 eduardo - meta
      before field semdocto
         display by name d_cta00m01.semdocto  attribute (reverse)

#------------------------After-Semdocto-----------------------------------------

      after field semdocto
         display by name d_cta00m01.semdocto

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left")then
            if mr_documento.ramgrpcod = 5 then
               next field ramcod
            else
               next field cp
            end if
         else
            if d_cta00m01.semdocto is null then
               if mr_documento.ramgrpcod = 5 then
                  next field ramcod
               else
                  next field transp
               end if
            else
               if d_cta00m01.semdocto <> "S" then
                  error 'Opcao invalida, digite "S" para ligacao Sem Docto.' sleep 2
                  next field semdocto
               else

                  let g_documento.atdnum = d_cta00m01.atdnum

                  call cta10m00_entrada_dados()

                  let mr_documento.corsus    = g_documento.corsus
                  let mr_documento.dddcod    = g_documento.dddcod
                  let mr_documento.ctttel    = g_documento.ctttel
                  let mr_documento.funmat    = g_documento.funmat
                  let mr_documento.cgccpfnum = g_documento.cgccpfnum
                  let mr_documento.cgcord    = g_documento.cgcord
                  let mr_documento.cgccpfdig = g_documento.cgccpfdig

                  let atd.semdoctocorsus    = g_documento.corsus
                  let atd.semdoctodddcod    = g_documento.dddcod
                  let atd.semdoctoctttel    = g_documento.ctttel
                  let atd.semdoctofunmat    = g_documento.funmat
                  let atd.semdoctocgccpfnum = g_documento.cgccpfnum
                  let atd.semdoctocgcord    = g_documento.cgcord
                  let atd.semdoctocgccpfdig = g_documento.cgccpfdig
                  let atd.semdoctofunmat    = g_documento.funmat
                  let atd.semdoctoempcod    = g_documento.empcodmat
                  let atd.semdoctoempcodatd = g_documento.empcodatd

                  if atd.semdoctocgcord is null and
                     atd.semdoctocgcord =  0    then
                     let atd.semdoctopestip = "F"
                  else
                     let atd.semdoctopestip = "J"
                  end if

                  if mr_documento.corsus    is null and
                     mr_documento.dddcod    is null and
                     mr_documento.ctttel    is null and
                     mr_documento.funmat    is null and
                     mr_documento.cgccpfnum is null and
                     mr_documento.cgcord    is null and
                     mr_documento.cgccpfdig is null then
                     error 'Faltam informacoes para registrar Ligacao sem Docto.' sleep 2
                     next field semdocto
                  else
                       --> carrega global com flag sem docto           #PSI234915
                       let g_documento.semdocto = d_cta00m01.semdocto
                       exit input
                  end if
               end if
            end if
         end if
         --> carrega global com flag sem docto           #PSI234915
         let g_documento.semdocto = d_cta00m01.semdocto


      #fim psi172413 eduardo - meta

#-------------------------Before-Prporg-----------------------------------------
      before field prporg
         display by name d_cta00m01.prporg    attribute (reverse)

#-------------------------After-Prporg-----------------------------------------

      after  field prporg
         display by name d_cta00m01.prporg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cta00m01.prporg    to null
            initialize d_cta00m01.prpnumdig to null
            display by name d_cta00m01.prporg
            display by name d_cta00m01.prpnumdig
            next field cgccpfnum
         end if

         let ws.psqprpflg = false


          if d_cta00m01.prporg = 0  then
            #Chamada do metodo opacc156 do sistema AS
            ## Ini Psi 223689
            call cty02g01_opacc156()
               returning d_cta00m01.prporg
                        ,d_cta00m01.prpnumdig
                       ,l_msg

            display by name d_cta00m01.prporg

            if d_cta00m01.prporg    is null  or
               d_cta00m01.prpnumdig is null  then
               if l_msg is null and
                  l_msg = " " then
                  error " Nenhuma proposta foi selecionada!"
                  next field prporg
               else
                 error l_msg
               end if  ## Fim Psi 223689
            else
               let ws.psqprpflg = true
            end if
         end if


      if d_cta00m01.prporg is null  then
          next field vp
      end if

#----------------------Before-Prpnumdig-----------------------------------------
      before field prpnumdig
         display by name d_cta00m01.prpnumdig attribute (reverse)

#-----------------------After-Prpnumdig-----------------------------------------

      after  field prpnumdig
         display by name d_cta00m01.prpnumdig

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field prporg
         end if

         if d_cta00m01.prpnumdig  =  0    then
            initialize  d_cta00m01.prpnumdig  to null
         end if

         if d_cta00m01.prpnumdig is not null  then
            call cta00m01_trata_proposta(ws.ramo
                                        ,d_cta00m01.prporg
                                        ,d_cta00m01.prpnumdig
                                        ,ws.psqprpflg)
               returning lr_resultado.resultado
                        ,lr_resultado.mensagem
                        ,d_cta00m01.succod
                        ,d_cta00m01.ramcod
                        ,d_cta00m01.aplnumdig
                        ,d_cta00m01.itmnumdig
            if lr_resultado.resultado = 2 then
               error " Proposta nao digitada para acompanhamento!"
               next field prporg
            end if

               let ws.aplnumdig = d_cta00m01.aplnumdig
               let ws.itmnumdig = d_cta00m01.itmnumdig
               if d_cta00m01.aplnumdig is null then
                  let d_cta00m01.ramcod = 531
               end if
         else
            if d_cta00m01.prporg  is not null  then
               error " Origem/numero da proposta deve ser informado!"
               next field prpnumdig
            end if
         end if

         if d_cta00m01.aplnumdig  is null   and
            d_cta00m01.vcllicnum  is null   and
            d_cta00m01.vclchsfnl  is null   and
            d_cta00m01.prpnumdig  is null   and
            d_cta00m01.segnom     is null   then
            error " Informe uma das chaves de localizacao!"
            next field segnom
         end if

         exit input


      on key (interrupt,control-c,f17)
         if d_cta00m01.ramcod =  31 or              ## Nao deixar sair com control-c com item zerado
            d_cta00m01.ramcod = 531 then
            if d_cta00m01.aplnumdig is not null and
               (d_cta00m01.itmnumdig = 0 or d_cta00m01.itmnumdig is null ) then
               let int_flag = false
               error 'Item incorreto'
               next field itmnumdig
            end if
         end if

         if l_cta00m01.prg  =  "cts35m02" then # chamada tela semDocto
            if l_cta00m01.atdsrvnum is not null and
               l_cta00m01.atdsrvnum <> 0 then
               let int_flag = true
               exit input
            end if
         end if



         ##############################
         # VALIDA  PROPOSTA SE DIGITADA
         ##############################
         if d_cta00m01.prporg    is not null  and
            d_cta00m01.prpnumdig is not null  then
#         if d_cta00m01.prpnumdig is not null  then
            call cta00m01_trata_proposta(ws.ramo
                                        ,d_cta00m01.prporg
                                        ,d_cta00m01.prpnumdig
                                        ,ws.psqprpflg)
               returning lr_resultado.resultado
                        ,lr_resultado.mensagem
                        ,d_cta00m01.succod
                        ,d_cta00m01.ramcod
                        ,d_cta00m01.aplnumdig
                        ,d_cta00m01.itmnumdig
            if lr_resultado.resultado = 2 then
               let d_cta00m01.prporg = null
               let d_cta00m01.prpnumdig = null
            end if
               let ws.aplnumdig = d_cta00m01.aplnumdig
               let ws.itmnumdig = d_cta00m01.itmnumdig
               if d_cta00m01.aplnumdig is null then
                  let d_cta00m01.ramcod = 531
               end if
         end if
         let l_erro = true # --> NAO PERMITIR ATENDIMENTO SEM DOCUMENTO AO PRESSIONAR control-c
         exit input

        on key (F8)
           if l_cta00m01.atdsrvnum is not null and
              l_cta00m01.atdsrvnum <> 0 then
              let g_documento.atdsrvorg = l_cta00m01.atdsrvorg
              let g_documento.atdsrvnum = l_cta00m01.atdsrvnum
              let g_documento.atdsrvano = l_cta00m01.atdsrvano

              if not cts04g00("") then
                 error "Nao foi possivel apresentar laudo!"
             end if
           else
             error "Opcao valida para ligação sem documento"
           end if
    end input

    if l_erro then
       exit while
    end if

    ## Alberto Sem Nome
    let g_monitor.horaini = current

    let mr_documento.ramcod = d_cta00m01.ramcod

    if g_documento.ramcod = 991  or
       g_documento.ramcod = 1391 then
       let d_cta00m01.succod    = g_documento.succod
       let ws.aplnumdig         = g_documento.aplnumdig
       let d_cta00m01.prporg    = g_documento.prporg
       let d_cta00m01.prpnumdig = g_documento.prpnumdig
    end if

    if d_cta00m01.transp is null then
       let d_cta00m01.transp = " "
    end if

    initialize g_rsc_re.*
              ,mr_rsc_re.*
              ,g_documento.lclnumseq
              ,g_documento.rmerscseq to null

    if l_lclnumseq is not null and
       l_rmerscseq is not null then
       let g_documento.lclnumseq = l_lclnumseq
       let g_documento.rmerscseq = l_rmerscseq
    end if

    ---> Verifica se Documento e do RE
    if d_cta00m01.ramcod is not null  and
       d_cta00m01.ramcod <> 0         then

       call cty10g00_grupo_ramo(g_documento.ciaempcod
                               ,d_cta00m01.ramcod)
                      returning mr_resultado
                               ,mr_mensagem
                               ,mr_documento.ramgrpcod
    end if


    --> Se for Ramo do RE verifica se ha mais de 1 Local de Risco ou Bloco
    if mr_documento.ramgrpcod = 4     and ---> RE
       d_cta00m01.ramcod is not null  and
       d_cta00m01.ramcod <> 0         and
       ws.aplnumdig      is not null  and
       ws.aplnumdig      <> 0         then



       while g_documento.lclnumseq is null or
             g_documento.rmerscseq is null

          initialize g_rsc_re.*
                    ,mr_rsc_re.*
                    ,lr_resultado.resultado
                    ,lr_resultado.mensagem
                    ,g_documento.lclnumseq
                    ,g_documento.rmerscseq  to null

          call framc215(d_cta00m01.succod
                       ,d_cta00m01.ramcod
                       ,ws.aplnumdig)
              returning lr_resultado.resultado
                       ,lr_resultado.mensagem
                       ,mr_rsc_re.lclrsccod
                       ,mr_rsc_re.lgdtip
                       ,mr_rsc_re.lgdnom
                       ,mr_rsc_re.lgdnum
                       ,mr_rsc_re.lclbrrnom
                       ,mr_rsc_re.cidnom
                       ,mr_rsc_re.ufdcod
                       ,mr_rsc_re.lgdcep
                       ,mr_rsc_re.lgdcepcmp
                       ,g_documento.lclnumseq
                       ,g_documento.rmerscseq
                       ,mr_rsc_re.rmeblcdes
                       ,mr_rsc_re.lclltt
                       ,mr_rsc_re.lcllgt

          if g_documento.lclnumseq is null or
             g_documento.rmerscseq is null then

             call cts08g01 ("A","N",""
                           ,"PARA PROSSEGUIR NO ATENDIMENTO, "
                           ,"SELECIONE UMA DAS OPCOES DA LISTA. ", " " )
                  returning ws.confirma
          end if
       end while
    end if



    if d_cta00m01.succod is not null  and
       ws.aplnumdig      is not null  then
       let mr_documento.succod     = d_cta00m01.succod
       let mr_documento.aplnumdig  = ws.aplnumdig
       let mr_documento.itmnumdig  = ws.itmnumdig

       initialize mr_documento.prporg     to null
       initialize mr_documento.prpnumdig  to null
    else
       if d_cta00m01.prporg    is not null  and
          d_cta00m01.prpnumdig is not null  then
          let mr_documento.prporg     = d_cta00m01.prporg
          let mr_documento.prpnumdig  = d_cta00m01.prpnumdig

          initialize mr_documento.aplnumdig  to null
          initialize mr_documento.itmnumdig  to null
          exit while
       end if
    end if

    if  ws.sinramcod is not null  and
        ws.sinano    is not null  and
        ws.sinnum    is not null  and
        ws.sinitmseq is not null  then
        let mr_documento.sinramcod = ws.sinramcod
        let mr_documento.sinano    = ws.sinano
        let mr_documento.sinnum    = ws.sinnum
        let mr_documento.sinitmseq = ws.sinitmseq

        call cty01g00_apolice_sinistro(ws.sinramcod
                                      ,ws.sinnum
                                      ,ws.sinano)
           returning lr_resultado.resultado
                    ,lr_resultado.mensagem
                    ,mr_documento.succod
                    ,mr_documento.aplnumdig
                    ,mr_documento.itmnumdig
                    ,mr_documento.edsnumref

         if lr_resultado.resultado = 2 then
            error "Apolice nao encontrada na base SSAMSIN" sleep 2
            let mr_documento.succod    = null
            let mr_documento.aplnumdig = null
            let mr_documento.itmnumdig = null
            let mr_documento.edsnumref = null
            exit while
         end if

         #Obter dados da apolice de Auto
         call cty05g00_dados_apolice(d_cta00m01.succod
                                    ,d_cta00m01.aplnumdig)
            returning lr_cty05g00.*

        if lr_cty05g00.emsdat >= m_dtresol86 then
           let d_cta00m01.ramcod = 531
        else
           let d_cta00m01.ramcod = 31
        end if
    end if


    if g_documento.ciaempcod <> 40 then
        if mr_documento.ramcod = 31 or mr_documento.ramcod = 531 then
           call f_funapol_ultima_situacao
               (mr_documento.succod, mr_documento.aplnumdig, mr_documento.itmnumdig)
                returning  g_funapol.*

           call cty05g00_edsnumref(1,mr_documento.succod, mr_documento.aplnumdig,
                                   g_funapol.dctnumseq)
                returning mr_documento.edsnumref
        end if
    end if

    if ws.ramo = "RE" then
       call cty06g00_dados_apolice(mr_documento.succod
                                  ,mr_documento.ramcod
                                  ,mr_documento.aplnumdig
                                  ,m_ramsgl)
            returning lr_cty06g00.*

       let mr_documento.edsnumref = lr_cty06g00.edsnumref

    end if

   #if  (g_documento.ramcod    is null  or
   #     g_documento.succod    is null  or
    if   mr_documento.aplnumdig is null  and             # PSI183431 Daniel INICIAR
         mr_documento.averbacao is null  and
         mr_documento.flgtransp = 'N'    and
         mr_ppt.cmnnumdig is null then
         error " Nenhuma apolice/item foi selecionada!"  # PSI183431 Daniel FIM
         exit while
    end if
    if mr_documento.vstnumdig is not null then
       initialize mr_documento.ramcod to null
    end if

       exit while
 end while

 #carregar a global mr_documento
 call cta00m01_guarda_globais()

   ---> Se nao localizou Apolice entao abre Atendimento por aqui, se nao
   ---> gera o Atendimento na tela do Assunto
   if ((g_documento.aplnumdig is null or g_documento.aplnumdig =  0) and #patricia PSI260479
      (g_documento.prpnumdig is null or  g_documento.prpnumdig = 0) or
       d_cta00m01.ramcod     =  991   or
       d_cta00m01.ramcod     =  1391)  then
      let atd.gera = "S" ---> Gera novo Atendimento
   end if

   if l_erro = false then
       # Gera atendimento para todos os níveis
      {if g_issk.acsnivcod >= 7   and
         atd.gera         = "S"  then

         initialize ws.confirma to null

         call cts08g01 ("A","S","",
                        "DESEJA GERAR UM NOVO ATENDIMENTO ? ","","")
              returning ws.confirma

         if ws.confirma = "N" then
            let atd.gera   = "N" ---> Nao quer gerar novo Atendimento
            let g_gera_atd = "N"

            initialize g_documento.atdnum, d_cta00m01.atdnum  to null
         end if
      end if}

      ---> Gera Numero de Atendimento
      if atd.gera = "S" then

         ---> Se nao ha docto trata variaveis p/ nao gravar em campos indevidos
         if d_cta00m01.semdocto = "S" then
            let g_documento.cgccpfnum = null
            let g_documento.cgcord    = null
            let g_documento.cgccpfdig = null
            let g_documento.corsus    = null
         end if

         begin work
         call ctd24g00_ins_atd(""                      ---> atdnum
                              ,g_documento.ciaempcod
                              ,g_documento.solnom
                              ,d_cta00m01.flgavstransp
                              ,g_documento.c24soltipcod
                              ,g_documento.ramcod
                              ,d_cta00m01.flgcar
                              ,d_cta00m01.vcllicnum
                              ,g_documento.corsus
                              ,g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,d_cta00m01.etpctrnum
                              ,d_cta00m01.segnom
                              ,d_cta00m01.pestip
                              ,g_documento.cgccpfnum
                              ,g_documento.cgcord
                              ,g_documento.cgccpfdig
                              ,g_documento.prporg
                              ,g_documento.prpnumdig
                              ,d_cta00m01.vp            --->flgvp
                              ,g_documento.vstnumdig
                              ,""                       --->vstdnumdig
                              ,d_cta00m01.vd            --->flgvd
                              ,d_cta00m01.cp            --->flgcp
                              ,""                       --->cpbnum
                              ,d_cta00m01.semdocto      --->semdcto
                              ,d_cta00m01.ies_ppt
                              ,d_cta00m01.ies_pss
                              ,d_cta00m01.transp
                              ,d_cta00m01.trpavbnum
                              ,d_cta00m01.vclchsfnl
                              ,g_documento.sinramcod
                              ,g_documento.sinnum
                              ,g_documento.sinano
                              ,d_cta00m01.sinvstnum
                              ,d_cta00m01.sinvstano
                              ,d_cta00m01.flgauto
                              ,d_cta00m01.sinautnum
                              ,d_cta00m01.sinautano
                              ,d_cta00m01.flgre
                              ,d_cta00m01.sinrenum
                              ,d_cta00m01.sinreano
                              ,d_cta00m01.flgavs
                              ,d_cta00m01.sinavsnum
                              ,d_cta00m01.sinavsano
                              ,atd.semdoctoempcodatd
                              ,atd.semdoctopestip
                              ,atd.semdoctocgccpfnum
                              ,atd.semdoctocgcord
                              ,atd.semdoctocgccpfdig
                              ,atd.semdoctocorsus
                              ,atd.semdoctofunmat
                              ,atd.semdoctoempcod
                              ,atd.semdoctodddcod
                              ,atd.semdoctoctttel
                              ,g_issk.funmat
                              ,g_issk.empcod
                              ,g_issk.usrtip
                              ,g_documento.ligcvntip)
              returning atd.novo_nroatd
                       ,lr_aux.resultado
                       ,lr_aux.mensagem

         if lr_aux.resultado <> 0 then
            error  lr_aux.mensagem sleep 3
            let int_flag              = true
            let l_erro                = true
            let g_documento.ligcvntip = null
            let g_documento.atdnum    = null
            let g_documento.succod    = null
            let g_documento.aplnumdig = null
            let g_documento.itmnumdig = null
            let g_documento.aplnumdig = null
            let g_documento.edsnumref = null
            let g_documento.fcapacorg = null
            let g_documento.fcapacnum = null
            let g_documento.sinramcod = null
            let g_documento.sinano    = null
            let g_documento.sinnum    = null
            let g_documento.vstnumdig = null
            let d_cta00m01.aplnumdig  = null
            let d_cta00m01.itmnumdig  = null
            let g_documento.corsus    = null
            let g_documento.dddcod    = null
            let g_documento.ctttel    = null
            let g_documento.funmat    = null
            let g_documento.cgccpfnum = null
            let g_documento.cgcord    = null
            let g_documento.cgccpfdig = null
            let g_cgccpf.ligdctnum    = null
            let g_cgccpf.ligdcttip    = null
            let g_crtdvgflg           = "N"

            initialize mr_documento.*
                      ,mr_ppt.*
                      ,am_ppt[1].*
                      ,am_ppt[2].*
                      ,am_ppt[3].*
                      ,am_ppt[4].*
                      ,am_ppt[5].* to null

            rollback work
         else

            let d_cta00m01.atdnum = atd.novo_nroatd
            display by name d_cta00m01.atdnum  attribute(reverse)

            commit work

            initialize ws.confirma
                      ,msg.linha1
                      ,msg.linha2
                      ,msg.linha3 to null


            while ws.confirma is null or ws.confirma = "N"
               let msg.linha1 = "INFORME AO CLIENTE O"
               let msg.linha2 = "NUMERO DE ATENDIMENTO : "
               let msg.linha3 = "< " , atd.novo_nroatd using "<<<<<<<&&&", " >"

               call cts08g01 ("A","N","",msg.linha1, msg.linha2 , msg.linha3)
                    returning ws.confirma

               initialize msg.linha1
                         ,msg.linha2
                         ,msg.linha3 to null

               let msg.linha1 = "NUMERO DE ATENDIMENTO < "
                                ,atd.novo_nroatd using "<<<<<<<&&&" ," >"


               let msg.linha2 = "FOI INFORMADO AO CLIENTE?"

               call cts08g01 ("A","S","",msg.linha1, msg.linha2, "")
                    returning ws.confirma
            end while


            ---> Atribui O Novo Numero de Atendimento a Global
            let g_documento.atdnum = atd.novo_nroatd

	    ---> Se gerou Atendimento aqui nao gera na tela do Assunto
            let g_gera_atd = "N"

            ---> Se nao ha docto volta valor para variaveis
            if d_cta00m01.semdocto = "S" then
               let g_documento.cgccpfnum = atd.semdoctocgccpfnum
               let g_documento.cgcord    = atd.semdoctocgcord
               let g_documento.cgccpfdig = atd.semdoctocgccpfdig
               let g_documento.corsus    = atd.semdoctocorsus
            end if
         end if
      else
         initialize g_documento.atdnum to null
      end if
   end if


   let int_flag = false

   close window cta00m01

   if g_setexplain = 1 then
      call cta00m01_setetapa()
   end if

   return mr_documento.*
         ,mr_ppt.*
         ,am_ppt[1].*
         ,am_ppt[2].*
         ,am_ppt[3].*
         ,am_ppt[4].*
         ,am_ppt[5].*

end function  ###  cta00m01

#------------------------------------------------------------------------------
function cta00m01_trata_transp(param)
#------------------------------------------------------------------------------

   define param record
          segnom       char(40),
          pestip       char(01),
          cgccpfnum    like gsakseg.cgccpfnum,
          cgcord       like gsakseg.cgcord,
          cgccpfdig    like gsakseg.cgccpfdig
   end record

   define retorno record
          msg          char(100),
          campo        char(10),
          succod       like gabksuc.succod,
          ramcod       like gtakram.ramcod,
          aplnumdig    like abamdoc.aplnumdig,
          itmnumdig    like abbmveic.itmnumdig,
          prporg       like datrligprp.prporg,
          prpnumdig    like datrligprp.prpnumdig,
          ramo         char(04)
   end record

   define retorno1 record
          succod       like gabksuc.succod,
          ramcod       like gtakram.ramcod,
          aplnumdig    like abamdoc.aplnumdig,
          itmnumdig    like abbmveic.itmnumdig,
          prporg       like datrligprp.prporg,
          prpnumdig    like datrligprp.prpnumdig
   end record

   define ws  record
          grlchv       like datkgeral.grlchv,
          grlchv1      like datkgeral.grlchv,
          grlinf       like datkgeral.grlinf,
          hora         datetime hour to second,
          count        integer,
          param        char(100),
          ret          integer,
          sissgl       like ibpmsistprog.sissgl,
          confirma     char(01)
   end record

   define lr_aux    record
          resultado    smallint
         ,mensagem     char(60)
   end record

   define w_comando    char(600)

   let w_comando  =  null

   initialize retorno.*   to  null
   initialize retorno1.*  to  null
   initialize ws.*        to  null
   initialize lr_aux      to null #PSI183431 Robson


   while true
   #------------[ chave para busca do ramo 78 ]------------
   let ws.grlchv1 = "pstc",g_issk.funmat using "&&&&&&",
                     g_issk.empcod using "&&",
                     g_issk.maqsgl clipped

   call cta12m00_seleciona_datkgeral(ws.grlchv1)
        returning lr_aux.resultado
                 ,lr_aux.mensagem
                 ,ws.grlinf

   if lr_aux.resultado = 1 then
       call cta12m00_remove_datkgeral(ws.grlchv1)
            returning lr_aux.resultado
                     ,lr_aux.mensagem
   end if

   #-------------------------------------------------------
   let ws.grlchv = "pstr",g_issk.funmat using "&&&&&&",
                          g_issk.empcod using "&&",
                          g_issk.maqsgl clipped

   call cta12m00_seleciona_datkgeral(ws.grlchv)
        returning lr_aux.resultado
                 ,lr_aux.mensagem
                 ,ws.grlinf

   if lr_aux.resultado = 1 then
      call cta12m00_remove_datkgeral(ws.grlchv)
           returning lr_aux.resultado
                    ,lr_aux.mensagem
   end if

   let ws.param[01,50] = param.segnom
   let ws.param[51,51] = param.pestip
   let ws.param[52,63] = param.cgccpfnum
   let ws.param[64,67] = param.cgcord
   let ws.param[68,69] = param.cgccpfdig
   let ws.param[70,75] = g_issk.funmat
   let ws.param[76,77] = g_issk.empcod
   let ws.param[78,80] = g_issk.maqsgl

   let ws.sissgl =  "Cadas_TR"
   let w_comando = ""
       ,g_issk.succod     , " "    #-> Sucursal
       ,g_issk.funmat     , " "    #-> Matricula do funcionario
   ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
       ,g_issk.dptsgl     , " "    #-> Sigla do departamento
       ,g_issk.dpttip     , " "    #-> Tipo do departamento
       ,g_issk.dptcod     , " "    #-> Codigo do departamento
       ,g_issk.sissgl     , " "    #-> Sigla sistema
       ,1                 , " "    #-> Nivel de acesso
       ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
       ,g_issk.usrtip     , " "    #-> Tipo de usuario
       ,g_issk.empcod     , " "    #-> Codigo da empresa
       ,g_issk.iptcod     , " "
       ,g_issk.usrcod     , " "    #-> Codigo do usuario
       ,g_issk.maqsgl     , " "    #-> Sigla da maquina
       ,"'",ws.param      , "'"

   if g_issk.funmat = 12435 then
      display "w_comando = ", w_comando
   end if

   call roda_prog("tra_ct01" ,w_comando,1) # e necessario estar cadastrado
        returning ws.ret                   # na tabela ibpkprog.

   if ws.ret = -1 then
      let retorno.msg   = " Sistema nao disponivel no momento!"
      let retorno.campo = "transp"
      exit while
   end if

   call cta12m00_seleciona_datkgeral(ws.grlchv)
        returning lr_aux.resultado
                 ,lr_aux.mensagem
                 ,ws.grlinf

   if lr_aux.resultado = 1 then

      call cta12m00_remove_datkgeral(ws.grlchv)
           returning lr_aux.resultado
                    ,lr_aux.mensagem
   end if

   if m_dtresol86 <= today then
      let retorno.succod    = ws.grlinf[01,02]
      let retorno.ramcod    = ws.grlinf[03,06]
      let retorno.aplnumdig = ws.grlinf[07,14]
      let retorno.prporg    = ws.grlinf[16,17]
      let retorno.prpnumdig = ws.grlinf[18,26]
   else
      let retorno.succod    = ws.grlinf[01,02]
      let retorno.ramcod    = ws.grlinf[03,04]
      let retorno.aplnumdig = ws.grlinf[05,12]
      let retorno.prporg    = ws.grlinf[14,15]
      let retorno.prpnumdig = ws.grlinf[16,24]
   end if

   if retorno.ramcod     = 78    or
     (retorno.ramcod     = 171   or
      retorno.ramcod     = 195 ) then

      call cts08g01("A","N",
                    "Para Aviso de Sinistro nao e permitido  ",
                    "apolice do ramo 171/195, selecione outro ",
                    "documento.","")
           returning ws.confirma
      continue while
   end if

   if g_issk.funmat = 12435 then
      display "retorno.succod    = ",retorno.succod
      display "retorno.ramcod    = ",retorno.ramcod
      display "retorno.aplnumdig = ",retorno.aplnumdig
      display "retorno.prporg    = ",retorno.prporg
      display "retorno.prpnumdig = ",retorno.prpnumdig
   end if

   if retorno.aplnumdig is not null and
      retorno.aplnumdig  > 0        then
      initialize  retorno.prporg    to  null
      initialize  retorno.prpnumdig to  null
   end if

   if retorno.aplnumdig = 0  then
      initialize retorno.aplnumdig to null
   end if

   call cta00m01_salva_campos(retorno.succod,
                              retorno.ramcod,
                              retorno.aplnumdig,
                              ""               , # itmnumdig,
                              retorno.prporg,
                              retorno.prpnumdig)
        returning retorno.msg      ,retorno.campo,
                  retorno.succod   ,retorno.ramcod,
                  retorno.aplnumdig,retorno.itmnumdig,
                  retorno.prporg   ,retorno.prpnumdig,
                  retorno.ramo
   exit while
   end while

   return retorno.*

end function

#-----------------------------------------------------------------------------
function cta00m01_salva_campos(param)
#-----------------------------------------------------------------------------

   define param record
          succod     like gabksuc.succod,
          ramcod     like gtakram.ramcod,
          aplnumdig  like abamdoc.aplnumdig,
          itmnumdig  like abbmveic.itmnumdig,
          prporg     like rsdmdocto.prporg,
          prpnumdig  like rsdmdocto.prpnumdig
   end record

   define retorno record
          msg        char (100),
          campo      char (10)
   end record

   define ws   record
          ramo       char (04),
          succod     like gabksuc.succod,
          ramcod     like gtakram.ramcod,
          aplnumdig  like abamdoc.aplnumdig,
          itmnumdig  like abbmveic.itmnumdig,
          contador   integer,
          prporg     like rsdmdocto.prporg,
          prpnumdig  like rsdmdocto.prpnumdig,
          segnumdig  like rsdmdocto.segnumdig
   end record

   define aux_dctnumseq  like rsdmdocto.dctnumseq
   define aux_prporg     like rsdmdocto.prporg
   define aux_prpnumdig  like rsdmdocto.prpnumdig
   define aux_sgrorg     like rsamseguro.sgrorg
   define aux_sgrnumdig  like rsamseguro.sgrnumdig
   define aux_segnumdig  like gsakseg.segnumdig

   define lr_retorno       record
          resultado        smallint
         ,mensagem         char(60)
         ,succod           like abamapol.succod
         ,ramcod           like gtakram.ramcod
         ,aplnumdig        like abamapol.aplnumdig
         ,itmnumdig        like abbmitem.itmnumdig
   end record

   define lr_retorno_06  record
          resultado      smallint
         ,mensagem       char(60)
         ,sgrorg         like rsamseguro.sgrorg
         ,sgrnumdig      like rsamseguro.sgrnumdig
         ,vigfnl         like rsdmdocto.vigfnl
         ,aplstt         like rsdmdocto.edsstt
         ,prporg         like rsdmdocto.prporg
         ,prpnumdig      like rsdmdocto.prpnumdig
         ,segnumdig      like rsdmdocto.segnumdig
         ,edsnumref      like rsdmdocto.edsnumdig
   end record

   initialize lr_retorno to null
   initialize lr_retorno_06 to null

   let aux_dctnumseq  =  null
   let aux_prporg  =  null
   let aux_prpnumdig  =  null
   let aux_sgrorg  =  null
   let aux_sgrnumdig  =  null
   let aux_segnumdig  =  null

   initialize retorno.*  to null
   initialize ws.*       to null

   while true
      let ws.ramo = "RE  "

      if g_issk.funmat = 12435 then
         display "** Entrei no SALVA ***"
         display "param.succod    = ", param.succod
         display "param.ramcod    = ", param.ramcod
         display "param.aplnumdig = ", param.aplnumdig
         display "param.itmnumdig = ", param.itmnumdig
         display "param.prporg    = ", param.prporg
         display "param.prpnumdig = ", param.prpnumdig
         display "ws.ramo         = ", ws.ramo
      end if

      if param.prpnumdig is not null  then
         let ws.prporg     =  param.prporg
         let ws.prpnumdig  =  param.prpnumdig

         call cta00m01_trata_proposta(ws.ramo
                                     ,param.prporg
                                     ,param.prpnumdig
                                     ,0)
         returning lr_retorno.resultado
                  ,lr_retorno.mensagem
                  ,ws.succod
                  ,ws.ramcod
                  ,ws.aplnumdig
                  ,lr_retorno.itmnumdig

         if lr_retorno.resultado = 2 then
            let retorno.msg = lr_retorno.mensagem
            let retorno.campo = 'prpgorg'
         end if

         exit while
      end if

      if param.aplnumdig is not null  then
         initialize ws.aplnumdig to null

         call F_FUNDIGIT_DIGAPOL (param.succod, param.ramcod, param.aplnumdig)
              returning ws.aplnumdig

         if ws.aplnumdig is null  then

            if ws.aplnumdig is null  then
               let retorno.msg =  " Problemas no digito da apolice!!",
                                  " AVISE A INFORMATICA!"
               let retorno.campo = "aplnumdig"
               exit while
            end if
         end if

         #--------------------------------------------------
         # Apolices de Ramos Elementares/Vida/Transportes
         #--------------------------------------------------
         if ws.ramo  =  "RE"   then

            #-- Obter dados da apolice de RE --#
            call cty06g00_dados_apolice(param.succod
                                       ,param.ramcod
                                       ,ws.aplnumdig
                                       ,m_ramsgl)
                 returning lr_retorno_06.*

            if lr_retorno_06.resultado = 2 then
               let retorno.msg = "Apolice de RAMOS ELEMENTARES nao cadastrada! "
               let retorno.campo = "aplnumdig"
               exit while
            end if
         end if

         let mr_documento.edsnumref = lr_retorno_06.edsnumref

         if mr_ppt.cmnnumdig is not null then
            let aux_segnumdig = mr_ppt.segnumdig
         end if


         let g_index   = 1
         let g_dctoarray[1].succod    = param.succod
         let g_dctoarray[1].ramcod    = param.ramcod
         let g_dctoarray[1].aplnumdig = ws.aplnumdig
         let g_dctoarray[1].prporg    = aux_prporg
         let g_dctoarray[1].prpnumdig = aux_prpnumdig
         let g_dctoarray[1].segnumdig = aux_segnumdig

         if mr_ppt.cmnnumdig is not null then         #PSI183431 - robson

            call cta00m14()

            let ws.itmnumdig = g_documento.itmnumdig
            display g_documento.itmnumdig
         end if
         exit while
      end if
      exit while
   end while

   if g_issk.funmat = 12435 then

      display "**** Sai do SALVA ****"
      display "retorno.msg  = ", retorno.msg
      display "retorno.campo= ", retorno.campo
      display "ws.succod    = ", ws.succod
      display "ws.ramcod    = ", ws.ramcod
      display "ws.aplnumdig = ", ws.aplnumdig
      display "ws.itmnumdig = ", ws.itmnumdig
      display "ws.prporg    = ", ws.prporg
      display "ws.prpnumdig = ", ws.prpnumdig
      display "ws.ramo      = ", ws.ramo
   end if

   return retorno.msg,
          retorno.campo,
          param.succod,
          param.ramcod,
          ws.aplnumdig,
          ws.itmnumdig,
          ws.prporg,
          ws.prpnumdig,
          ws.ramo

end function

#-----------------------------------------------------------------------------
function cta00m01_guarda_globais()
#-----------------------------------------------------------------------------

   let g_c24paxnum              = mr_documento.c24paxnum

   let g_documento.pcacarnum    = mr_documento.pcacarnum    # PSI183431 Daniel
   let g_documento.solnom       = mr_documento.solnom
   let g_documento.c24soltipcod = mr_documento.c24soltipcod
   let g_documento.soltip       = mr_documento.soltip
   let g_documento.fcapacorg    = mr_documento.fcapacorg
   let g_documento.fcapacnum    = mr_documento.fcapacnum
   let g_documento.flgtransp    = mr_documento.flgtransp
   let g_documento.succod       = mr_documento.succod
   let g_documento.aplnumdig    = mr_documento.aplnumdig
   let g_documento.empcodatd    = mr_documento.empcodatd
   let g_documento.funmatatd    = mr_documento.funmatatd
   let g_documento.usrtipatd    = mr_documento.usrtipatd
   let g_documento.itmnumdig    = mr_documento.itmnumdig
   let g_documento.vstnumdig    = mr_documento.vstnumdig
   let g_documento.corsus       = mr_documento.corsus
   let g_documento.dddcod       = mr_documento.dddcod
   let g_documento.ctttel       = mr_documento.ctttel
   let g_documento.funmat       = mr_documento.funmat
   let g_documento.cgccpfnum    = mr_documento.cgccpfnum
   let g_documento.cgcord       = mr_documento.cgcord
   let g_documento.cgccpfdig    = mr_documento.cgccpfdig
   let g_documento.prporg       = mr_documento.prporg
   let g_documento.prpnumdig    = mr_documento.prpnumdig
   let g_documento.sinramcod    = mr_documento.sinramcod
   let g_documento.sinano       = mr_documento.sinano
   let g_documento.sinnum       = mr_documento.sinnum
   let g_documento.sinitmseq    = mr_documento.sinitmseq
   let g_documento.edsnumref    = mr_documento.edsnumref
   let g_documento.crtsaunum    = mr_documento.crtsaunum
   let g_documento.bnfnum       = mr_documento.bnfnum
   let g_documento.ramgrpcod    = mr_documento.ramgrpcod

   let g_ppt.segnumdig = mr_ppt.segnumdig
   let g_ppt.cmnnumdig = mr_ppt.cmnnumdig
   let g_ppt.endlgdtip = mr_ppt.endlgdtip
   let g_ppt.endlgdnom = mr_ppt.endlgdnom
   let g_ppt.endnum    = mr_ppt.endnum
   let g_ppt.ufdcod    = mr_ppt.ufdcod
   let g_ppt.endcmp    = mr_ppt.endcmp
   let g_ppt.endbrr    = mr_ppt.endbrr
   let g_ppt.endcid    = mr_ppt.endcid
   let g_ppt.endcep    = mr_ppt.endcep
   let g_ppt.endcepcmp = mr_ppt.endcepcmp
   let g_ppt.edsstt    = mr_ppt.edsstt
   let g_ppt.viginc    = mr_ppt.viginc
   let g_ppt.vigfnl    = mr_ppt.vigfnl
   let g_ppt.emsdat    = mr_ppt.emsdat
   let g_ppt.corsus    = mr_ppt.corsus
   let g_ppt.pgtfrm    = mr_ppt.pgtfrm
   let g_ppt.mdacod    = mr_ppt.mdacod
   let g_ppt.lclrsccod = mr_ppt.lclrsccod

   let g_a_pptcls[1].* = am_ppt[1].*
   let g_a_pptcls[2].* = am_ppt[2].*
   let g_a_pptcls[3].* = am_ppt[3].*
   let g_a_pptcls[4].* = am_ppt[4].*
   let g_a_pptcls[5].* = am_ppt[5].*

   let g_rsc_re.lgdtip     = mr_rsc_re.lgdtip
   let g_rsc_re.lgdnom     = mr_rsc_re.lgdnom
   let g_rsc_re.lgdnum     = mr_rsc_re.lgdnum
   let g_rsc_re.lclbrrnom  = mr_rsc_re.lclbrrnom
   let g_rsc_re.cidnom     = mr_rsc_re.cidnom
   let g_rsc_re.ufdcod     = mr_rsc_re.ufdcod
   let g_rsc_re.lgdcep     = mr_rsc_re.lgdcep
   let g_rsc_re.lgdcepcmp  = mr_rsc_re.lgdcepcmp
   let g_rsc_re.dddcod     = mr_rsc_re.dddcod
   let g_rsc_re.lclrsccod  = mr_rsc_re.lclrsccod
   let g_rsc_re.lclltt     = mr_rsc_re.lclltt
   let g_rsc_re.lcllgt     = mr_rsc_re.lcllgt

 ---> Funeral - 170408
 if mr_documento.ramcod <> 991  and
    mr_documento.ramcod <> 1391 and
    mr_documento.ramcod <> 1329 then
    let g_documento.ramcod       = mr_documento.ramcod
 end if

 if mr_documento.itmnumdig is null then
    let mr_documento.itmnumdig = 0
    let g_documento.itmnumdig  = 0
 else
     let g_documento.itmnumdig = mr_documento.itmnumdig
 end if

end function

#-----------------------------------------------------------------------------
function cta00m01_trata_proposta(lr_param)
#-----------------------------------------------------------------------------

   define lr_param         record
          ramo             char(10)
         ,prporg           like datrligprp.prporg
         ,prpnumdig        like datrligprp.prpnumdig
         ,campo            smallint
   end record

   define lr_retorno       record
          resultado        smallint
         ,mensagem         char(60)
         ,succod           like abamapol.succod
         ,ramcod           like gtakram.ramcod
         ,aplnumdig        like abamapol.aplnumdig
         ,itmnumdig        like abbmitem.itmnumdig
   end record

   define l_flag           char(01)
         ,l_msg            char(60)

   initialize lr_retorno to null
   let l_flag = null

   if lr_param.ramo      is not null and
      lr_param.prporg    is not null and
      lr_param.prpnumdig is not null and
      lr_param.campo     is not null then
      let lr_retorno.resultado = 1

      if lr_param.ramo = "AUTO" then
         call cta00m03(lr_param.prporg, lr_param.prpnumdig)
              returning lr_retorno.succod
                       ,lr_retorno.ramcod
                       ,lr_retorno.aplnumdig
                       ,lr_retorno.itmnumdig

         if lr_retorno.aplnumdig is null then
            let lr_retorno.ramcod = 531
         end if
      else
         if lr_param.ramo = "RE" then
            call cta00m15(lr_param.prporg, lr_param.prpnumdig)
                 returning lr_retorno.succod
                          ,lr_retorno.ramcod
                          ,lr_retorno.aplnumdig
         end if
      end if

      if lr_retorno.aplnumdig is null and
         lr_param.campo = false and
         lr_retorno.ramcod <> 531 then # so segue fluxo para ramo <> 531 -- PSI260479

         call cty02g00_opacc149(lr_param.prporg, lr_param.prpnumdig)
              returning l_flag,l_msg

         if l_flag = "N" then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Proposta nao digitada para acompanhamento!"
            let l_msg = "Proposta nao digitada para acompanhamento!"
            call errorlog(l_msg)
         else
            if l_msg is null or
               l_msg = " " then
               error l_msg
               call errorlog(l_msg)
            end if  # fim Psi 223689
         end if
      end if
   else
      let lr_retorno.resultado = 3
      let l_msg = "Parametros nulos"
      call errorlog(l_msg)
   end if

   return lr_retorno.*

end function

#-----------------------------------------------------------------------------
function cta00m01_trata_n11_h11(lr_param)
#-----------------------------------------------------------------------------

   define lr_param      record
          c24soltipcod  like datmligacao.c24soltipcod
         ,dtresol86     date
   end record

   define lr_aux        record
          resultado     smallint
         ,mensagem      char(60)
   end record

   define lr_retorno record
          c24soltipdes char(40)
         ,ramcod       like datrservapol.ramcod
         ,transp       char (01)
         ,ramnom       like gtakram.ramnom
   end record

   initialize lr_aux     to null
   initialize lr_retorno to null

   if lr_param.dtresol86 <= today then
      let lr_retorno.ramcod = 531
   else
      let lr_retorno.ramcod = 31
   end if

   let lr_retorno.transp = "N"
   let lr_retorno.ramnom = "AUTO"

   call cto00m00_nome_solicitante(lr_param.c24soltipcod, 1)
        returning lr_aux.resultado
                 ,lr_aux.mensagem
                 ,lr_retorno.c24soltipdes

   if lr_aux.resultado = 3 or
      lr_aux.resultado = 2 then
      call errorlog(lr_aux.mensagem)
   end if

   return lr_retorno.*

end function

#-----------------------------------------------------------------------------
function cta00m01_setetapa()
#-----------------------------------------------------------------------------

   define l_mensagem char(140)

   if mr_documento.aplnumdig is not null then
      let l_mensagem = 'Apolice: ',mr_documento.aplnumdig using '&&&'
                                  ,mr_documento.succod    using '&&'
                                  ,mr_documento.aplnumdig using '<<<<<<<<<<'
                                  ,mr_documento.itmnumdig using '<<<<<'
   else
      if mr_documento.prpnumdig is not null then
         let l_mensagem = 'Proposta: ',mr_documento.prporg using '&&'
                                      ,mr_documento.prpnumdig using '<<<<<<<<<<'
      else
         let l_mensagem = 'SemDocto: corsus = ',mr_documento.corsus
                                   ,'telefone ',mr_documento.dddcod
                                               ,mr_documento.ctttel
                                   ,'matric: ' ,mr_documento.funmat
                                   ,'cgc/cpf: ',mr_documento.cgccpfnum
                                               ,mr_documento.cgcord
                                               ,mr_documento.cgccpfdig
      end if
   end if

   call cts01g01_setetapa(l_mensagem)

end function

function cta00m01_email(l_param)
     define l_param char(200)
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
           #PSI-2013-23297 - Inicio
           let l_mail.de = "CT24H-cta00m01 <linha 659> "
           let l_mail.para = "sistemas.madeira@portoseguro.com.br"
           let l_mail.cc = " "
           let l_mail.cco = ""
           let l_mail.assunto = "Apolices Divergentes"
           let l_mail.mensagem = l_param
           let l_mail.id_remetente = "CT24HS"
           let l_mail.tipo = "text"
           call figrc009_mail_send1 (l_mail.*)
              returning l_erro,msg_erro
           #PSI-2013-23297 - Fim
end function
function cta00m01_set_globais()
      let g_documento.atdnum    = null
      let g_documento.succod    = null
      let g_documento.aplnumdig = null
      let g_documento.itmnumdig = null
      let g_documento.edsnumref = null
      let g_documento.fcapacorg = null
      let g_documento.fcapacnum = null
      let g_documento.sinramcod = null
      let g_documento.sinano    = null
      let g_documento.sinnum    = null
      let g_documento.vstnumdig = null
      let g_documento.corsus    = null
      let g_documento.dddcod    = null
      let g_documento.ctttel    = null
      let g_documento.funmat    = null
      let g_documento.cgccpfnum = null
      let g_documento.cgcord    = null
      let g_documento.cgccpfdig = null
      let g_cgccpf.ligdctnum    = null
      let g_cgccpf.ligdcttip    = null
      let g_crtdvgflg           = "N"
      let g_index               = 0
end function
