#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: cts55g00                                                        #
# Objetivo.: Processo de inclusao de servicos simplificado, para a chamada   #
#            via smartphone                                                  #
# Analista.: Fabio Costa                                                     #
# PSI      : 246174 - iPhone                                                 #
# Liberacao: 15/01/2010                                                      #
#............................................................................#
# Observacoes                                                                #
# - Valores definidos com regras da Central                                  #
# - Para a roteirizacao pelo dispositivo, os campos de endereco deverao ter  # 
#   a acentuacao retirada no windows para que o Informix possa validar.      #
#   Se o endereco for enviado com acentuação, a roteirizacao será feita pelo #
#   Informix ou pelo Infra.map                                               #
#............................................................................#
# Alteracoes                                                                 #
# PAS 89001  Fabio Costa  31/03/2010  Validacao de dados cidade/UF, dados    #
#                                     enviados, infomix, CRGISJAVA01Rp ;email#
#                                     com dados do servico incluido          # 
# PAS        Fabio Costa  04/11/2010  Acertos msg erro, e-mail, solicitante  #
# 03307/IN   Fabio Costa  08/02/2011  Validacao apolice nao vigente          #
#----------------------------------------------------------------------------#
# CT201201879 Celso Y.    23/01/2012  Se data/hora programada do servico for #
#                                     null, nao gravar previsao de chegada do#
#                                     prestador no servico                   #
#----------------------------------------------------------------------------#
database porto

globals '/homedsa/projetos/geral/globals/glct.4gl'

#----------------------------------------------------------------
function cts55g00(l_servico, l_ocorrencia, l_destino, l_servicocmp)
#----------------------------------------------------------------

  define l_servico record
         srvnumtip     smallint                     ,  # NN
         solicdat      date                         ,  # NN
         solichor      datetime hour to second      ,  # NN
         c24soltipcod  like datksoltip.c24soltipcod ,  # NN
         c24solnom     like datmservico.c24solnom   ,  # NN
         c24astcod     like datkassunto.c24astcod   ,  # NN
         c24pbmcod     like datkpbm.c24pbmcod       ,  # NN
         c24pbmdes     like datkpbm.c24pbmdes       ,  # NN
         webpbmdes     like datkpbm.webpbmdes       ,
         sphpbmdes     like datkpbm.sphpbmdes       ,
         funmat        integer                      ,  # NN
         funemp        smallint                     ,  # NN
         c24paxnum     integer                      ,
         atdlibflg     like datmservico.atdlibflg   ,  # NN
         atdtip        like datmservico.atdtip      ,  # NN
         atdfnlflg     like datmservico.atdfnlflg   ,  # NN
         atdrsdflg     like datmservico.atdrsdflg   ,  # NN
         atdpvtretflg  like datmservico.atdpvtretflg,  # NN
         asitipcod     like datmservico.asitipcod   ,  # NN
         srvprlflg     like datmservico.srvprlflg   ,
         atdprinvlcod  like datmservico.atdprinvlcod,
         atdsrvorg     like datmservico.atdsrvorg   ,  # NN
         c24pbminforg  like datrsrvpbm.c24pbminforg ,  # NN
         pstcoddig     like dpaksocor.pstcoddig     ,
         atdetpcod     like datmservico.atdetpcod   ,  # NN
         ligcvntip     like datmligacao.ligcvntip   ,  # NN
         prslocflg     like datmservico.prslocflg   ,  # NN
         vclcamtip     like datmservicocmp.vclcamtip,  # NN
         vclcrgflg     like datmservicocmp.vclcrgflg,  # NN
         rmcacpflg     like datmservicocmp.rmcacpflg,  # NN
         frmflg        char(1)                      ,  # NN
         remrquflg     like datkpbm.remrquflg       ,
         vclcorcod     decimal(2,0)                 ,
         vcldes        like datmservico.vcldes      ,
         vclanomdl     like datmservico.vclanomdl   ,  # NN
         vcllicnum     like datmservico.vcllicnum   ,  # NN
         camflg        char(1)                      ,  # NN
         vclcoddig     like datmservico.vclcoddig   ,
         segnom        like gsaksegger.segnom       ,
         succod        like datrligapol.succod      ,  # NN - Codigo Sucursal
         ramcod        like datrservapol.ramcod     ,  # NN - Codigo Ramo
         aplnumdig     like datrligapol.aplnumdig   ,  # NN - Numero Apolice
         itmnumdig     like datrligapol.itmnumdig   ,  # NN - Numero do Item
         edsnumref     like datrligapol.edsnumref   ,  #      Numero do Endosso
         corsus        like datmservico.corsus      ,  # NN
         cornom        like datmservico.cornom,
         atddatprg     like datmservico.atddatprg,
         atdhorprg     like datmservico.atdhorprg
  end record
  
  define l_ocorrencia record
         lclidttxt     like datmlcl.lclidttxt      ,
         lgdtip        like datmlcl.lgdtip         ,
         lgdnom        like datmlcl.lgdnom         ,
         lgdnum        like datmlcl.lgdnum         ,
         lclbrrnom     like datmlcl.lclbrrnom      , # sub-bairro, vem da roteirizacao
         brrnom        like datmlcl.brrnom         ,
         cidnom        like datmlcl.cidnom         ,
         ufdcod        like datmlcl.ufdcod         ,
         lclrefptotxt  like datmlcl.lclrefptotxt   ,
         endzon        like datmlcl.endzon         ,
         lgdcep        like datmlcl.lgdcep         ,
         lgdcepcmp     like datmlcl.lgdcepcmp      ,   
         lclltt        like datmlcl.lclltt         ,   # NN
         lcllgt        like datmlcl.lcllgt         ,   # NN
         dddcod        like datmlcl.dddcod         ,
         lcltelnum     like datmlcl.lcltelnum      ,
         lclcttnom     like datmlcl.lclcttnom      ,
         c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
         ofnnumdig     decimal(6,0)                ,
         emeviacod     like datmemeviadpt.emeviacod
  end record
     
  define l_destino record
         lclidttxt     like datmlcl.lclidttxt      ,
         lgdtip        like datmlcl.lgdtip         ,
         lgdnom        like datmlcl.lgdnom         ,
         lgdnum        like datmlcl.lgdnum         ,
         lclbrrnom     like datmlcl.lclbrrnom      ,  # sub-bairro, vem da roteirizacao
         brrnom        like datmlcl.brrnom         ,
         cidnom        like datmlcl.cidnom         ,
         ufdcod        like datmlcl.ufdcod         ,
         lclrefptotxt  like datmlcl.lclrefptotxt   ,
         endzon        like datmlcl.endzon         ,
         lgdcep        like datmlcl.lgdcep         ,
         lgdcepcmp     like datmlcl.lgdcepcmp      ,
         lclltt        like datmlcl.lclltt         ,   # NN
         lcllgt        like datmlcl.lcllgt         ,   # NN
         dddcod        like datmlcl.dddcod         ,
         lcltelnum     like datmlcl.lcltelnum      ,
         lclcttnom     like datmlcl.lclcttnom      ,
         c24lclpdrcod  like datmlcl.c24lclpdrcod   ,
         ofnnumdig     decimal(6,0)                ,
         emeviacod     like datmemeviadpt.emeviacod
  end record

  define l_servicocmp record
        vclcamtip    like datmservicocmp.vclcamtip, #TipoCaminhao
        vclcrcdsc    like datmservicocmp.vclcrcdsc, #DescricaoCarroceria
        vclcrgflg    like datmservicocmp.vclcrgflg, #FlagCaminhaoCarregtado
        vclcrgpso    like datmservicocmp.vclcrgpso, #PesoCaminhaoCarregtado
        sinvitflg    like datmservicocmp.sinvitflg, #FlagVitimasSinistro
        bocflg       like datmservicocmp.bocflg,    #FlagBoletimOcorrencia
        bocnum       like datmservicocmp.bocnum,    #NumeroBoletimOcorrencia
        bocemi       like datmservicocmp.bocemi,    #OrgaoEmissorBO
        vcllibflg    like datmservicocmp.vcllibflg, #FlagLiberacaoVeiculo
        roddantxt    like datmservicocmp.roddantxt, #RodasDanificadas
        rmcacpflg    like datmservicocmp.rmcacpflg, #FlagSeguradoAcompanhaRem
        sindat       like datmservicocmp.sindat,    #DataSinistro
        c24sintip    like datmservicocmp.c24sintip, #TipoSinistro
        c24sinhor    like datmservicocmp.c24sinhor, #HoraSinistro
        vicsnh       like datmservicocmp.vicsnh,    #SenhaAlarme
        sinhor       like datmservicocmp.sinhor,    #HoraOcorrenciaSinistro
        sgdirbcod    like datmservicocmp.sgdirbcod, #CodigoIRBSeguradorahaRem
        smsenvflg    like datmservicocmp.smsenvflg  #FlagEnvioSMS
 end record
  
  define l_cts55g00 record
         lignum      like datmligacao.lignum    ,
         atdsrvnum   like datmservico.atdsrvnum ,
         atdsrvano   like datmservico.atdsrvano ,
         atdvcltip   like datmservico.atdvcltip ,
         atdhorpvt   like datmservico.atdhorpvt ,
         cidcod      like gcakfilial.cidcod     ,
         cidsedcod   like datrcidsed.cidsedcod  ,
         atdprvtmp   like datracncid.atdprvtmp  ,
         sqlcode     integer                    ,
         errmsg      char(80)                   ,
         lclbrrnom   like datmlcl.lclbrrnom
  end record
  
  define l_cts40g00 record
         resultado     smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
         mensagem      char(100),
         acnlmttmp     like datkatmacnprt.acnlmttmp,
         acntntlmtqtd  like datkatmacnprt.acntntlmtqtd,
         netacnflg     like datkatmacnprt.netacnflg,
         atmacnprtcod  like datkatmacnprt.atmacnprtcod
  end record
  
  define l_aux record
         tabname    char(20),
         sqlerrd    integer
  end record
  
  define l_ctx25g01  record
         ufdcod       like datkmpacid.ufdcod ,
         cidnom       like datkmpacid.cidnom ,
         brrnom       like datkmpabrr.brrnom ,
         lgdnom       like datkmpalgd.lgdnom ,
         lgdtip       like datkmpalgd.lgdtip ,
         numero       integer                ,
         status_ret   smallint
  end record
  
  define l_errmsg  char(120),
         l_rota    char(80) ,
         l_tmp     char(80),
         l_campo   char(25),
         l_hora    datetime year to second
         
  define l_srvprsacnhordat like datmservico.srvprsacnhordat
  
  define l_path     char(100)
       , l_msg      char(120)
       , l_assunto  char(300)
       , l_ret      smallint
       , l_srv      char(30)
       
  initialize l_errmsg, l_tmp, l_campo, l_hora, l_srvprsacnhordat, l_rota to null
  initialize l_cts55g00.* to null
  initialize l_aux.* to null
  initialize l_cts40g00.* to null
  initialize l_ctx25g01.* to null
  initialize l_path, l_msg, l_assunto, l_srv to null
  
  let l_ret    = 0
  let l_errmsg = ''
  
  let l_hora = current
  
  display 'CTS55G00: Dados enviados pelo front-end'
  display l_hora
  display '--------------------------------------------------------------------'
  display 'Tipo numeracao           : ', l_servico.srvnumtip   
  display 'Data solicitacao         : ', l_servico.solicdat    
  display 'Hora solicitacao         : ', l_servico.solichor    
  display 'Tipo solicitante         : ', l_servico.c24soltipcod
  display 'Nome solicitante         : ', l_servico.c24solnom   
  display 'Codigo do assunto        : ', l_servico.c24astcod   
  display 'Codigo do problema       : ', l_servico.c24pbmcod   
  display 'Descricao do problema    : ', l_servico.c24pbmdes   
  display 'Matricula operador       : ', l_servico.funmat      
  display 'Empresa operador         : ', l_servico.funemp      
  display 'Numero da PA             : ', l_servico.c24paxnum   
  display 'Flag serv. liberado      : ', l_servico.atdlibflg   
  display 'Tipo atendimento         : ', l_servico.atdtip      
  display 'Flag final atendimento   : ', l_servico.atdfnlflg   
  display 'Flag atd. residencial    : ', l_servico.atdrsdflg   
  display 'Flag retorno previsto    : ', l_servico.atdpvtretflg
  display 'Codigo tipo assistencia  : ', l_servico.asitipcod   
  display 'Flag servico particular  : ', l_servico.srvprlflg   
  display 'Nivel prioridade atd.    : ', l_servico.atdprinvlcod
  display 'Origem servico           : ', l_servico.atdsrvorg   
  display 'Origem informacao prob.  : ', l_servico.c24pbminforg
  display 'Codigo do prestador      : ', l_servico.pstcoddig   
  display 'Codigo da etapa          : ', l_servico.atdetpcod   
  display 'Tipo convenio ligacao    : ', l_servico.ligcvntip   
  display 'Flag prestador no local  : ', l_servico.prslocflg   
  display 'Tipo do caminhao         : ', l_servico.vclcamtip   
  display 'Flag caminhao carregado  : ', l_servico.vclcrgflg   
  display 'Flag segurado acomp. rem : ', l_servico.rmcacpflg   
  display 'Flag atd. via formulario : ', l_servico.frmflg
  display 'Flag remocao requerida   : ', l_servico.remrquflg
  display 'Codigo cor do veiculo    : ', l_servico.vclcorcod   
  display 'Descricao do veiculo     : ', l_servico.vcldes      
  display 'Ano modelo do veiculo    : ', l_servico.vclanomdl   
  display 'Numero da placa          : ', l_servico.vcllicnum   
  display 'Flag caminhao ou util.   : ', l_servico.camflg      
  display 'Codigo modelo veiculo    : ', l_servico.vclcoddig   
  display 'Nome do segurado         : ', l_servico.segnom      
  display 'Codigo da sucursal       : ', l_servico.succod      
  display 'Codigo do ramo           : ', l_servico.ramcod      
  display 'Numero da apolice        : ', l_servico.aplnumdig   
  display 'Numero do item           : ', l_servico.itmnumdig   
  display 'Numero endosso           : ', l_servico.edsnumref   
  display 'SUSEP                    : ', l_servico.corsus      
  display 'Corretor                 : ', l_servico.cornom      
  display 'DataProgramada           : ', l_servico.atddatprg      
  display 'HoraProgramada           : ', l_servico.atdhorprg      
  display '-----LOCAL DA OCORRENCIA--------------------------------------------'
  display 'Identificacao do local   : ', l_ocorrencia.lclidttxt    
  display 'Tipo logradouro          : ', l_ocorrencia.lgdtip       
  display 'Nome do logradouro       : ', l_ocorrencia.lgdnom clipped
  display 'Numero do logradouro     : ', l_ocorrencia.lgdnum       
  display 'Nome do bairro do local  : ', l_ocorrencia.lclbrrnom    
  display 'Nome do bairro           : ', l_ocorrencia.brrnom       
  display 'Nome da cidade           : ', l_ocorrencia.cidnom       
  display 'Nome do estado           : ', l_ocorrencia.ufdcod       
  display 'Ponto de referencia      : ', l_ocorrencia.lclrefptotxt 
  display 'Zona                     : ', l_ocorrencia.endzon       
  display 'CEP                      : ', l_ocorrencia.lgdcep       
  display 'Complemento de CEP       : ', l_ocorrencia.lgdcepcmp    
  display 'Latitude                 : ', l_ocorrencia.lclltt       
  display 'Longitude                : ', l_ocorrencia.lcllgt       
  display 'Codigo DDD               : ', l_ocorrencia.dddcod       
  display 'Numero do telefone       : ', l_ocorrencia.lcltelnum    
  display 'Nome da pessoa de contato: ', l_ocorrencia.lclcttnom    
  display 'Codigo padronizacao      : ', l_ocorrencia.c24lclpdrcod 
  display 'Codigo da oficina        : ', l_ocorrencia.ofnnumdig    
  display 'Cod. via emergencial     : ', l_ocorrencia.emeviacod 
  display '-----LOCAL DE DESTINO-----------------------------------------------'
  display 'Identificacao do local   : ', l_destino.lclidttxt   
  display 'Tipo logradouro          : ', l_destino.lgdtip      
  display 'Nome do logradouro       : ', l_destino.lgdnom clipped
  display 'Numero do logradouro     : ', l_destino.lgdnum      
  display 'Nome do bairro do local  : ', l_destino.lclbrrnom   
  display 'Nome do bairro           : ', l_destino.brrnom      
  display 'Nome da cidade           : ', l_destino.cidnom      
  display 'Nome do estado           : ', l_destino.ufdcod      
  display 'Ponto de referencia      : ', l_destino.lclrefptotxt
  display 'Zona                     : ', l_destino.endzon      
  display 'CEP                      : ', l_destino.lgdcep      
  display 'Complemento de CEP       : ', l_destino.lgdcepcmp   
  display 'Latitude                 : ', l_destino.lclltt      
  display 'Longitude                : ', l_destino.lcllgt      
  display 'Codigo DDD               : ', l_destino.dddcod      
  display 'Numero do telefone       : ', l_destino.lcltelnum   
  display 'Nome da pessoa de contato: ', l_destino.lclcttnom   
  display 'Codigo padronizacao      : ', l_destino.c24lclpdrcod
  display 'Codigo da oficina        : ', l_destino.ofnnumdig   
  display 'Cod. via emergencial     : ', l_destino.emeviacod   
  display '--------------------------------------------------------------------'
  display '-----SERVICO COMPLEMENTO -------------------------------------------'
  display 'TipoCaminhao ', l_servicocmp.vclcamtip   
  display 'DescricaoCarroceria ', l_servicocmp.vclcrcdsc    
  display 'FlagCaminhaoCarregado ', l_servicocmp.vclcrgflg   
  display 'PesoCaminhaoCarregado ', l_servicocmp.vclcrgpso  
  display 'FlagVitimasSinistro ', l_servicocmp.sinvitflg 
  display 'FlagBoletimOcorrencia ', l_servicocmp.bocflg   
  display 'NumeroBoletimOcorrencia ', l_servicocmp.bocnum  
  display 'OrgaoEmissorBO ', l_servicocmp.bocemi 
  display 'FlagLiberacaoVeiculo ', l_servicocmp.vcllibflg    
  display 'RodasDanificadas ', l_servicocmp.roddantxt   
  display 'FlagSeguradoAcompanhaRemocao ', l_servicocmp.rmcacpflg  
  display 'DataSinistro ', l_servicocmp.sindat    
  display 'TipoSinistro ', l_servicocmp.c24sintip
  display 'HoraSinistro ', l_servicocmp.c24sinhor 
  display 'SenhaAlarme ', l_servicocmp.vicsnh       
  display 'HoraOcorrenciaSinistro ', l_servicocmp.sinhor      
  display 'CodigoIRBSeguradorahaRemocao ', l_servicocmp.sgdirbcod  
  display 'FlagEnvioSMS ', l_servicocmp.smsenvflg
  display '--------------------------------------------------------------------'
  
  let l_cts55g00.sqlcode = 0
  
  # insercao automatica, usuario identificado como sistema
  let g_issk.funmat      = 999999
  let g_issk.empcod      = 1
  let g_issk.usrtip      = "F"
  let g_documento.funmat = 999999
  let l_servico.funemp   = 1
  
  #----------------------------------------------------------------
  # validacao de parametros
  
  while true
  
     if l_servico.srvnumtip    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'srvnumtip   '  exit while  end if  # TipoNumeracao
     if l_servico.solicdat     is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'solicdat    '  exit while  end if  # DataSolicitacao
     if l_servico.solichor     is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'solichor    '  exit while  end if  # HoraSolicitacao
     if l_servico.c24soltipcod is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24soltipcod'  exit while  end if  # TipoSolicitante
     if l_servico.c24solnom    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24solnom   '  exit while  end if  # NomeSolicitante
     if l_servico.c24astcod    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24astcod   '  exit while  end if  # CodigoAssunto

     if l_servico.atdsrvorg <> 4 then
        if l_servico.c24pbmcod    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24pbmcod   '  exit while  end if  # CodigoProblema
        if l_servico.c24pbmdes is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24pbmdes'  exit while  end if  # DescricaoProblema
     end if
     
     if l_servico.funmat       is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'funmat      '  exit while  end if  # matriculaOperador
     if l_servico.funemp       is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'funemp      '  exit while  end if  # empresaOperador
     if l_servico.atdlibflg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdlibflg   '  exit while  end if  # FlagLiberacaoServico
     if l_servico.atdtip       is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdtip      '  exit while  end if  # TipoAtendimento
     if l_servico.atdfnlflg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdfnlflg   '  exit while  end if  # FlagFinalAtendimento
     if l_servico.atdrsdflg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdrsdflg   '  exit while  end if  # FlagAtendimentoResidencial
     if l_servico.atdpvtretflg is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdpvtretflg'  exit while  end if  # FlagRetornoPrevisto
     if l_servico.asitipcod    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'asitipcod   '  exit while  end if  # CodigoTipoAssistencia       
     
     if l_servico.atdprinvlcod is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdprinvlcod'  exit while  end if  # NivelPrioridadeAtendimento
     if l_servico.atdsrvorg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdsrvorg   '  exit while  end if  # OrigemServico
     if l_servico.c24pbminforg is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'c24pbminforg'  exit while  end if  # OrigemInformacaoProblema
     
     if l_servico.atdetpcod is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'atdetpcod'  exit while  end if  # CodigoEtapa
     if l_servico.ligcvntip is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'ligcvntip'  exit while  end if  # TipoConvenioLigacao
     if l_servico.prslocflg is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'prslocflg'  exit while  end if  # FlagPrestadorNoLocal
     if l_servico.rmcacpflg is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'rmcacpflg'  exit while  end if  # FlagSeguradoAcompanhaRemocao
     if l_servico.frmflg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'frmflg   '  exit while  end if  # FlagAtendimentoViaFormulario
     if l_servico.camflg    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'camflg   '  exit while  end if  # FlagCaminhaoOuUtilitario
     
     if l_servico.succod    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'succod   '  exit while  end if  # CodigoSucursal
     if l_servico.ramcod    is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'ramcod   '  exit while  end if  # CodigoRamo
     if l_servico.aplnumdig is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'aplnumdig'  exit while  end if  # NumeroApolice
     if l_servico.itmnumdig is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'itmnumdig'  exit while  end if  # NumeroItem
     if l_servico.edsnumref is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'edsnumref'  exit while  end if  # NumeroEndossoReferencia
     
     if l_ocorrencia.lclltt       is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'ocorrencia.lclltt'  exit while  end if  # ocrLatitudeLocal
     if l_ocorrencia.lcllgt       is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'ocorrencia.lcllgt'  exit while  end if  # ocrLongitudeLocal
     if l_ocorrencia.c24lclpdrcod is null then  let l_cts55g00.sqlcode = 999  let l_campo = 'ocorrencia.c24lclpdrcod'  exit while  end if  #  ocrCodigoPadraoLocal

     # requerido para local de destino 
     if l_servico.remrquflg is not null and
        l_servico.remrquflg = 'S'
        then
        if l_destino.lclltt       is null then let l_cts55g00.sqlcode = 999  let l_campo = 'destino.lclltt'       exit while  end if
        if l_destino.lcllgt       is null then let l_cts55g00.sqlcode = 999  let l_campo = 'destino.lcllgt'       exit while  end if
        if l_destino.c24lclpdrcod is null then let l_cts55g00.sqlcode = 999  let l_campo = 'destino.c24lclpdrcod' exit while  end if
     end if
     
     exit while
     
  end while
  
  if l_cts55g00.sqlcode != 0
     then
     let l_errmsg = 'Erro 01: parametro: ', l_campo clipped, ' = null'
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if
  
  #----------------------------------------------------------------
  # validacao de apolice vigente
  if l_servico.ramcod != 531 and l_servico.ramcod != 31
     then
     let l_errmsg = 'Servico SmartPhone liberado somente para apolices AUTO'
     display l_errmsg clipped
     return 991, l_errmsg, '', '', ''
  end if
  
  call cts55g00_valida_apolice_auto(l_servico.succod, l_servico.aplnumdig)
       returning l_ret, l_errmsg
       
  if l_ret != 0
     then
     return l_ret, l_errmsg, '', '', ''
  end if
  
  let l_ret = 0
  
  begin work
  
  #----------------------------------------------------------------
  # define numeracao ligacao / servico
  whenever error continue
  call cts10g03_numeracao(l_servico.srvnumtip, l_servico.atdtip)
       returning l_cts55g00.lignum   ,
                 l_cts55g00.atdsrvnum,
                 l_cts55g00.atdsrvano,
                 l_cts55g00.sqlcode  ,
                 l_cts55g00.errmsg 
  whenever error stop
  
  display 'cts10g03_numeracao: ', l_cts55g00.lignum   ,  '|',
                                  l_cts55g00.atdsrvnum,  '|',
                                  l_cts55g00.atdsrvano,  '|',
                                  l_cts55g00.sqlcode  ,  '|',
                                  l_cts55g00.errmsg
  
  let l_errmsg = 'Erro 02: SQL ', l_cts55g00.sqlcode
  
  if l_cts55g00.sqlcode != 0 or
     l_cts55g00.atdsrvnum is null or
     l_cts55g00.atdsrvano is null
     then
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  else
     commit work  
  end if
  
  begin work
  #----------------------------------------------------------------
  # tipo veiculo de atendimento
  whenever error continue
  call cts57g00_tipo_veiculo_atend(l_servico.succod   ,
                                   l_servico.ramcod   ,
                                   l_servico.aplnumdig,
                                   l_servico.itmnumdig,
                                   l_servico.edsnumref,
                                   l_servico.asitipcod,
                                   l_servico.camflg)
       returning l_cts55g00.atdvcltip
  whenever error stop
  
  display 'cts55g00_tipo_veiculo_atend: ', l_cts55g00.atdvcltip
  
  #----------------------------------------------------------------
  # grava ligacao (nao mandar os ultimos 4, senao grava formulario)
  whenever error continue
  call cts10g00_ligacao(l_cts55g00.lignum     ,
                        l_servico.solicdat    ,
                        l_servico.solichor    ,
                        l_servico.c24soltipcod,
                        l_servico.c24solnom   ,
                        l_servico.c24astcod   ,
                        l_servico.funmat      ,
                        l_servico.ligcvntip   ,
                        l_servico.c24paxnum   ,
                        l_cts55g00.atdsrvnum  ,
                        l_cts55g00.atdsrvano  ,
                        "","","",""           ,
                        l_servico.succod      ,
                        l_servico.ramcod      ,
                        l_servico.aplnumdig   ,
                        l_servico.itmnumdig   ,
                        l_servico.edsnumref   ,
                        "","","","" ,
                        "","","","" ,
                        "","","","" ) # solicdat, solichor, funemp, funmat
              returning l_aux.tabname, l_cts55g00.sqlcode
  whenever error stop
  
  display 'cts10g00_ligacao: ', l_aux.tabname, l_cts55g00.sqlcode
  
  if l_cts55g00.sqlcode != 0
     then
     let l_errmsg = 'Erro 03: SQL ', l_cts55g00.sqlcode,
                    ' | Tabela ', l_aux.tabname clipped
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if
  
  #----------------------------------------------------------------
  # revisa enderecos ocorrencia e destino, faz geocode reverso quando nao houver,
  # grava locais de ocorrencia e destino
  
  initialize l_errmsg to null
  
  let l_ocorrencia.lgdtip = upshift(l_ocorrencia.lgdtip)
  let l_ocorrencia.lgdnom = upshift(l_ocorrencia.lgdnom)
  let l_ocorrencia.brrnom = upshift(l_ocorrencia.brrnom)
  let l_ocorrencia.cidnom = upshift(l_ocorrencia.cidnom)
  let l_ocorrencia.ufdcod = upshift(l_ocorrencia.ufdcod)
  
  let l_rota = 'Ocorrencia roteirizada pelo FRONT-END'
  
  # verifica existencia da cidade/UF enviado pelo front-end
  if l_ocorrencia.lgdnom is not null and
     l_ocorrencia.lgdnum is not null and
     l_ocorrencia.cidnom is not null and
     l_ocorrencia.ufdcod is not null
     then
     call cts55g00_ver_cidufd(l_ocorrencia.cidnom, l_ocorrencia.ufdcod)
          returning l_ocorrencia.cidnom, l_ocorrencia.ufdcod
          
     display 'cts55g00_ver_cidufd: ', l_ocorrencia.cidnom clipped, ' / ', l_ocorrencia.ufdcod
  end if
  
  # se nao houver endereco, busca no Informix
  if l_ocorrencia.lgdnom is null or
     l_ocorrencia.lgdnum is null or
     l_ocorrencia.cidnom is null or
     l_ocorrencia.ufdcod is null
     then
     whenever error continue
     call ctn44c02_endereco(l_ocorrencia.lclltt, l_ocorrencia.lcllgt)
          returning l_ocorrencia.ufdcod,
                    l_ocorrencia.cidnom,
                    l_ocorrencia.lgdtip,
                    l_ocorrencia.lgdnom,
                    l_ocorrencia.brrnom,
                    l_ocorrencia.lgdnum
     whenever error stop
     let l_rota = 'Ocorrencia roteirizada pelo INFORMIX'
  end if
  
  # se nao houver endereco, busca no CRGISJAVA01R
  if l_ocorrencia.lgdnom is null or
     l_ocorrencia.lgdnum is null or
     l_ocorrencia.cidnom is null or
     l_ocorrencia.ufdcod is null
     then
     whenever error continue
     if ctx25g05_rota_ativa()
        then
        call ctx25g01_endereco(l_ocorrencia.lclltt, l_ocorrencia.lcllgt, '1')
             returning l_ctx25g01.status_ret,
                       l_ocorrencia.ufdcod,
                       l_ocorrencia.cidnom,
                       l_ocorrencia.lgdtip,
                       l_ocorrencia.lgdnom,
                       l_ocorrencia.brrnom,
                       l_ocorrencia.lgdnum
     end if
     whenever error stop
     let l_rota = 'Ocorrencia roteirizada pelo CRGISJAVA01R'
  end if
  
  display l_rota clipped
  
  # se nao houver dados suficientes para o local de ocorrencia, aborta
  if l_ocorrencia.lgdnom is null or
     l_ocorrencia.lgdnum is null or
     l_ocorrencia.cidnom is null or
     l_ocorrencia.ufdcod is null
     then
     let l_errmsg = 'Erro 04: Dados para gravacao do local ocorrencia nao localizados'
     
     rollback work
     
     let l_cts55g00.sqlcode = 999
     
     display l_errmsg clipped
     display 'l_ocorrencia.lgdtip: ', l_ocorrencia.lgdtip
     display 'l_ocorrencia.lgdnom: ', l_ocorrencia.lgdnom clipped
     display 'l_ocorrencia.lgdnum: ', l_ocorrencia.lgdnum
     display 'l_ocorrencia.brrnom: ', l_ocorrencia.brrnom
     display 'l_ocorrencia.cidnom: ', l_ocorrencia.cidnom
     display 'l_ocorrencia.ufdcod: ', l_ocorrencia.ufdcod
     
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  else
     # local sem bairro definido, nao achou no front-end nem no CRGISJAVA01R
     if l_ocorrencia.brrnom is null
        then
        let l_ocorrencia.brrnom = 'NAO LOCALIZADO'
     end if
  end if
  
  # grava local de ocorrencia
  whenever error continue
  call cts06g07_local("I"                      ,
                      l_cts55g00.atdsrvnum     ,
                      l_cts55g00.atdsrvano     ,
                      1                        ,
                      l_ocorrencia.lclidttxt   ,
                      l_ocorrencia.lgdtip      ,
                      l_ocorrencia.lgdnom      ,
                      l_ocorrencia.lgdnum      ,
                      l_cts55g00.lclbrrnom     ,
                      l_ocorrencia.brrnom      ,
                      l_ocorrencia.cidnom      ,
                      l_ocorrencia.ufdcod      ,
                      l_ocorrencia.lclrefptotxt,
                      l_ocorrencia.endzon      ,
                      l_ocorrencia.lgdcep      ,
                      l_ocorrencia.lgdcepcmp   ,
                      l_ocorrencia.lclltt      ,
                      l_ocorrencia.lcllgt      ,
                      l_ocorrencia.dddcod      ,
                      l_ocorrencia.lcltelnum   ,
                      l_ocorrencia.lclcttnom   ,
                      l_ocorrencia.c24lclpdrcod,
                      l_ocorrencia.ofnnumdig   ,
                      l_ocorrencia.emeviacod   ,
                      '', '', '')
            returning l_cts55g00.sqlcode
  whenever error stop
  
  display 'cts06g07_local(1): ', l_cts55g00.sqlcode
  
  if l_cts55g00.sqlcode != 0
     then
     let l_errmsg = 'Erro 05: SQL ', l_cts55g00.sqlcode, ' | Tabela datmlcl(1)'
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if
  
  # grava local de destino somente se servico com remocao 
  if l_servico.remrquflg is not null and
     l_servico.remrquflg = 'S'
     then
     
     let l_destino.lgdtip = upshift(l_destino.lgdtip)
     let l_destino.lgdnom = upshift(l_destino.lgdnom)
     let l_destino.brrnom = upshift(l_destino.brrnom)
     let l_destino.cidnom = upshift(l_destino.cidnom)
     let l_destino.ufdcod = upshift(l_destino.ufdcod)
     
     if l_destino.lgdnom is not null and
        l_destino.lgdnum is not null and
        l_destino.cidnom is not null and
        l_destino.ufdcod is not null
        then
        call cts55g00_ver_cidufd(l_destino.cidnom, l_destino.ufdcod)
             returning l_destino.cidnom, l_destino.ufdcod
          
        let l_errmsg = 'Destino roteirizado pelo FRONT-END'
     end if
     
     if l_destino.lgdnom is null or
        l_destino.lgdnum is null or
        l_destino.cidnom is null or
        l_destino.ufdcod is null   
        then
        whenever error continue
        call ctn44c02_endereco(l_destino.lclltt, l_destino.lcllgt)
             returning l_destino.ufdcod,
                       l_destino.cidnom,
                       l_destino.lgdtip,
                       l_destino.lgdnom,
                       l_destino.brrnom,
                       l_destino.lgdnum
        whenever error stop
        let l_errmsg = 'Destino roteirizado pelo INFORMIX'
     end if
     
     if l_destino.lgdnom is null or
        l_destino.lgdnum is null or
        l_destino.cidnom is null or
        l_destino.ufdcod is null   
        then
        whenever error continue
        if ctx25g05_rota_ativa()
           then
           call ctx25g01_endereco(l_destino.lclltt, l_destino.lcllgt, '1')
                returning l_ctx25g01.status_ret,
                          l_destino.ufdcod,
                          l_destino.cidnom,
                          l_destino.lgdtip,
                          l_destino.lgdnom,
                          l_destino.brrnom,
                          l_destino.lgdnum
       
        end if
        whenever error stop
        let l_errmsg = 'Destino roteirizado pelo CRGISJAVA01R'
     end if
     
     display l_errmsg clipped
     
     # se nao houver dados suficientes para o local de destino, aborta
     if l_destino.lgdnom is null or
        l_destino.lgdnum is null or
        l_destino.cidnom is null or
        l_destino.ufdcod is null
        then
        let l_errmsg = 'Erro 06: Dados para gravacao do local destino nao localizados'
        rollback work
        
        let l_cts55g00.sqlcode = 999
        
        display l_errmsg clipped
        display 'l_destino.lgdtip: ', l_destino.lgdtip
        display 'l_destino.lgdnom: ', l_destino.lgdnom
        display 'l_destino.lgdnum: ', l_destino.lgdnum
        display 'l_destino.brrnom: ', l_destino.brrnom
        display 'l_destino.cidnom: ', l_destino.cidnom
        display 'l_destino.ufdcod: ', l_destino.ufdcod
        
        return l_cts55g00.sqlcode, l_errmsg, '', '', ''
     else
        # local sem bairro definido, nao achou no front-end nem no CRGISJAVA01R
        if l_destino.brrnom is null
           then
           let l_destino.brrnom = 'NAO LOCALIZADO'
        end if
     end if
     
     # grava local de destino
     whenever error continue
     call cts06g07_local("I"                   ,
                         l_cts55g00.atdsrvnum  ,
                         l_cts55g00.atdsrvano  ,
                         2                     ,
                         l_destino.lclidttxt   ,
                         l_destino.lgdtip      ,
                         l_destino.lgdnom      ,
                         l_destino.lgdnum      ,
                         l_destino.lclbrrnom   ,
                         l_destino.brrnom      ,
                         l_destino.cidnom      ,
                         l_destino.ufdcod      ,
                         l_destino.lclrefptotxt,
                         l_destino.endzon      ,
                         l_destino.lgdcep      ,
                         l_destino.lgdcepcmp   ,
                         l_destino.lclltt      ,
                         l_destino.lcllgt      ,
                         l_destino.dddcod      ,
                         l_destino.lcltelnum   ,
                         l_destino.lclcttnom   ,
                         l_destino.c24lclpdrcod,
                         l_destino.ofnnumdig   ,
                         l_destino.emeviacod   ,
                         '', '', '')
               returning l_cts55g00.sqlcode
     whenever error stop
     
     display 'cts06g07_local(2): ', l_cts55g00.sqlcode
     
     if l_cts55g00.sqlcode != 0
        then
        let l_errmsg = 'Erro 07: SQL ', l_cts55g00.sqlcode, ' | Tabela datmlcl(2)'
        rollback work
        display l_errmsg clipped
        return l_cts55g00.sqlcode, l_errmsg, '', '', ''
     end if
  end if
  
  #----------------------------------------------------------------
  # verifica se servico e internet ou gps e se esta ativo
  let l_servico.atdfnlflg = 'N'

  whenever error continue
  if cts34g00_acion_auto(l_servico.atdsrvorg , l_ocorrencia.cidnom ,
                         l_ocorrencia.ufdcod )
     then
     # funcao cts34g00_acion_auto verificou que parametrizacao para origem
     # do servico esta ok
     # chamar funcao para validar regras gerais se um servico sera acionado
     # automaticamente ou nao e atualizar datmservico
     
     if cts40g12_regras_aciona_auto(l_servico.atdsrvorg ,
                                    l_servico.c24astcod ,
                                    l_servico.asitipcod ,
                                    l_ocorrencia.lclltt ,
                                    l_ocorrencia.lcllgt ,
                                    l_servico.prslocflg ,
                                    l_servico.frmflg    ,
                                    l_cts55g00.atdsrvnum,
                                    l_cts55g00.atdsrvano,
                                    " "                 ,
                                    l_servico.vclcoddig ,
                                    l_servico.camflg)
        then
        let l_servico.atdfnlflg = 'A'
     else
        let l_servico.atdfnlflg = 'N'
     end if
  end if
  whenever error stop
  
  display 'cts40g12_regras_aciona_auto: ', l_servico.atdfnlflg
  
  #----------------------------------------------------------------
  # buscar nome do corretor quando nao houver
  whenever error continue
  call cty00g00_nome_corretor(l_servico.corsus)
       returning l_cts55g00.sqlcode, l_cts55g00.errmsg, l_servico.cornom
  whenever error stop
  
  if l_cts55g00.sqlcode != 1
     then
     let l_errmsg = 'Erro nome corretor: ', l_cts55g00.errmsg clipped
     display l_errmsg clipped
  end if
  
  #----------------------------------------------------------------
  # previsao de atendimento
  whenever error continue
  call cts40g00_obter_parametro(l_servico.atdsrvorg)
       returning l_cts40g00.resultado,
                 l_cts40g00.mensagem,
                 l_cts40g00.acnlmttmp,
                 l_cts40g00.acntntlmtqtd,
                 l_cts40g00.netacnflg,
                 l_cts40g00.atmacnprtcod
  whenever error stop
  
  display 'cts40g00_obter_parametro: ', l_cts40g00.atmacnprtcod
  
  whenever error continue
  call cty10g00_obter_cidcod(l_ocorrencia.cidnom,
                             l_ocorrencia.ufdcod)
       returning l_cts55g00.sqlcode, 
                 l_cts55g00.errmsg,
                 l_cts55g00.cidcod
  whenever error stop
  
  display 'cty10g00_obter_cidcod: ', l_cts55g00.sqlcode, ' ', l_cts55g00.cidcod
  
  whenever error continue
  if l_cts40g00.atmacnprtcod is not null and 
     l_cts40g00.atmacnprtcod != 0 and
     l_cts55g00.cidcod is not null and
     l_cts55g00.cidcod != 0
     then
     call ctd01g00_obter_cidsedcod(1, l_cts55g00.cidcod)
          returning l_cts55g00.sqlcode,
                    l_cts55g00.errmsg,
                    l_cts55g00.cidsedcod

     display 'ctd01g00_obter_cidsedcod: ', l_cts55g00.sqlcode, " | ",
             l_cts55g00.errmsg clipped, l_cts55g00.cidsedcod
     
     if l_cts55g00.cidsedcod is not null
        then
        call cts32g00_dados_cid_ac(1, l_cts40g00.atmacnprtcod,
                                   l_cts55g00.cidsedcod)
             returning l_cts55g00.sqlcode,
                       l_cts55g00.errmsg,
                       l_cts55g00.atdprvtmp
                       
        display 'cts32g00_dados_cid_ac: ', l_cts55g00.sqlcode, " | ",
                l_cts55g00.errmsg clipped, l_cts55g00.atdprvtmp
        
        if l_cts55g00.atdprvtmp is not null
           then
           let l_tmp = l_cts55g00.atdprvtmp
           let l_cts55g00.atdhorpvt = l_tmp
           initialize l_tmp to null
           let l_tmp = 'Regra previsao: buscou do cadastro ', l_cts55g00.atdhorpvt
           display l_tmp
        else
           # definido com o cliente 18/01/10, 30 min para cidades grande  
           # Sao Paulo e 60 min para as demais cidades
           if l_cts55g00.cidsedcod = 9668
              then
              let l_cts55g00.atdhorpvt = '00:30'
              let l_tmp = 'Regra previsao: cidade sede SP 30 min'
              display l_tmp
           else
              let l_cts55g00.atdhorpvt = '00:60'
              let l_tmp = 'Regra previsao: cidade sede fora SP 60 min'
              display l_tmp
           end if
        end if
     else
        let l_cts55g00.atdhorpvt = '00:60'
        let l_tmp = 'Regra previsao: sem cidade sede 60 min'
        display l_tmp
     end if
  else
     let l_cts55g00.atdhorpvt = '00:60'
     let l_tmp = 'Regra previsao: sem cidade sede e sem cadastro 60 min'
     display l_tmp
  end if
  
  display 'l_cts55g00.atdhorpvt: ', l_cts55g00.atdhorpvt
  #CT201201879 Inicio
  if l_servico.atddatprg is not null and
     l_servico.atdhorprg is not null then
     initialize l_cts55g00.atdhorpvt to null
     display 'Data e Hora Programada do servico nulos.'
     display 'l_cts55g00.atdhorpvt gravara nulo'
  end if
  #CT201201879 Fim
  whenever error stop
  
  #----------------------------------------------------------------
  # grava servico
  whenever error continue
  call cts10g02_grava_servico(l_cts55g00.atdsrvnum  ,
                              l_cts55g00.atdsrvano  ,
                              l_servico.c24soltipcod,
                              l_servico.c24solnom   ,
                              l_servico.vclcorcod   ,
                              l_servico.funmat      ,
                              l_servico.atdlibflg   ,
                              l_servico.solichor    ,
                              l_servico.solicdat    ,
                              l_servico.solicdat    ,
                              l_servico.solichor    ,
                              ""                    ,  # atdlclflg
                              l_cts55g00.atdhorpvt  , 
                              l_servico.atddatprg   ,  # atddatprg
                              l_servico.atdhorprg   ,  # atdhorprg
                              l_servico.atdtip      , 
                              ""                    ,  # atdmotnom
                              ""                    ,  # atdvclsgl
                              ""                    ,  # atdprscod
                              ""                    ,  # atdcstvlr
                              l_servico.atdfnlflg   ,  # flag aciona automatico
                              ""                    ,  # atdfnlhor
                              l_servico.atdrsdflg   , 
                              l_servico.c24pbmdes   ,  # atddfttxt
                              ""                    ,  # atddoctxt
                              ""                    ,  # c24opemat
                              l_servico.segnom      ,
                              l_servico.vcldes      ,
                              l_servico.vclanomdl   ,
                              l_servico.vcllicnum   ,
                              l_servico.corsus      ,
                              l_servico.cornom      ,
                              ""                    ,  # cnldat
                              ""                    ,  # pgtdat
                              ""                    ,  # c24nomctt
                              l_servico.atdpvtretflg, 
                              l_cts55g00.atdvcltip  , 
                              l_servico.asitipcod   , 
                              ""                    ,  # socvclcod
                              l_servico.vclcoddig   , 
                              l_servico.srvprlflg   , 
                              ""                    ,  # srrcoddig
                              l_servico.atdprinvlcod,
                              l_servico.atdsrvorg   )
                    returning l_aux.tabname, l_cts55g00.sqlcode
                              
  whenever error stop
  
  display 'cts10g02_grava_servico: ', l_aux.tabname, l_cts55g00.sqlcode
  
  if l_cts55g00.sqlcode != 0
     then
     let l_errmsg = 'Erro 08: SQL ', l_cts55g00.sqlcode,
                    ' | Tabela ', l_aux.tabname clipped
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if
  
  #----------------------------------------------------------------
  # atualiza data/hora acionamento para o acionamento automatico
  let l_srvprsacnhordat = current
  
  whenever error continue
  call ctd07g00_upd_acndat(l_srvprsacnhordat, l_cts55g00.atdsrvnum,
                           l_cts55g00.atdsrvano)
                 returning l_cts55g00.sqlcode, l_aux.sqlerrd 
  whenever error stop
  
  display 'ctd07g00_upd_acndat: ', l_cts55g00.sqlcode, l_aux.sqlerrd
  
  if l_cts55g00.sqlcode != 0 or l_aux.sqlerrd <= 0
     then
     let l_errmsg = 'Erro 09: SQL ', l_cts55g00.sqlcode,
                    ' | update data/hora acionamento'
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if

  if l_servico.atdsrvorg <> 4 then 
     #----------------------------------------------------------------
     # grava problema do servico
     # obs: se c24pbminforg for = 1, pstcoddig podera ser nulo
     whenever error continue
     call ctx09g02_inclui(l_cts55g00.atdsrvnum  ,
                          l_cts55g00.atdsrvano  ,
                          l_servico.c24pbminforg, # Org. informacao 1-Segurado 2-Pst
                          l_servico.c24pbmcod   ,
                          l_servico.c24pbmdes   , # atddfttxt
                          l_servico.pstcoddig )   # Codigo prestador
                returning l_cts55g00.sqlcode,
                          l_aux.tabname
     whenever error stop
     
     display 'ctx09g02_inclui: ', l_cts55g00.sqlcode, '     ', l_aux.tabname
     
     if l_cts55g00.sqlcode != 0
        then
        let l_errmsg = 'Erro 10: SQL ', l_cts55g00.sqlcode,
                       ' | Tabela ', l_aux.tabname clipped
        rollback work
        display l_errmsg clipped
        return l_cts55g00.sqlcode, l_errmsg, '', '', ''
     end if
  
  end if

  #----------------------------------------------------------------
  # grava complemento do servico

  if l_servicocmp.vclcamtip is not null or
     l_servicocmp.vclcrcdsc is not null or
     l_servicocmp.vclcrgflg is not null or
     l_servicocmp.vclcrgpso is not null or
     l_servicocmp.sinvitflg is not null or
     l_servicocmp.bocflg is not null or
     l_servicocmp.bocnum is not null or
     l_servicocmp.bocemi is not null or
     l_servicocmp.vcllibflg is not null or
     l_servicocmp.roddantxt is not null or
     l_servicocmp.rmcacpflg is not null or
     l_servicocmp.sindat is not null or
     l_servicocmp.c24sintip is not null or
     l_servicocmp.c24sinhor is not null or
     l_servicocmp.vicsnh is not null or
     l_servicocmp.sinhor is not null or
     l_servicocmp.sgdirbcod is not null then

     whenever error continue
     call ctd07g08_srvcmp_ins(l_cts55g00.atdsrvnum,
                              l_cts55g00.atdsrvano,
                              l_servicocmp.vclcamtip ,
                              l_servicocmp.vclcrcdsc,
                              l_servicocmp.vclcrgflg,
                              l_servicocmp.vclcrgpso,
                              l_servicocmp.sinvitflg,
                              l_servicocmp.bocflg,
                              l_servicocmp.bocnum,
                              l_servicocmp.bocemi,
                              l_servicocmp.vcllibflg,
                              l_servicocmp.roddantxt,
                              l_servico.rmcacpflg,
                              l_servicocmp.sindat,
                              l_servicocmp.c24sintip,
                              l_servicocmp.c24sinhor,
                              l_servicocmp.vicsnh,
                              l_servicocmp.sinhor,
                              l_servicocmp.sgdirbcod,
                              l_servicocmp.smsenvflg)
                    returning l_cts55g00.sqlcode
     whenever error stop
     
     display 'ctd07g08_srvcmp_ins: ', l_cts55g00.sqlcode
     
     if l_cts55g00.sqlcode != 0
        then
        let l_errmsg = 'Erro 11: SQL ', l_cts55g00.sqlcode,
                       ' | Tabela datmservicocmp'
        rollback work
        display l_errmsg clipped
        return l_cts55g00.sqlcode, l_errmsg, '', '', ''
     end if

  end if 
  
  #----------------------------------------------------------------
  # grava relacionamento srv x apl
  whenever error continue
  if  l_servico.aplnumdig is not null and
      l_servico.aplnumdig != 0 
      then
      call ctd20g08_servapol_ins(l_servico.succod    ,
                                 l_servico.ramcod    ,
                                 l_servico.aplnumdig ,
                                 l_servico.itmnumdig ,
                                 l_servico.edsnumref ,
                                 l_cts55g00.atdsrvnum,
                                 l_cts55g00.atdsrvano)
                       returning l_cts55g00.sqlcode
                       
      display 'ctd20g08_servapol_ins: ', l_cts55g00.sqlcode
      
      if l_cts55g00.sqlcode != 0
         then
         let l_errmsg = 'Erro 12: SQL ', l_cts55g00.sqlcode,
                        ' | Tabela datrservapol'
         rollback work
         display l_errmsg clipped
         return l_cts55g00.sqlcode, l_errmsg, '', '', ''
      end if
  end if
  whenever error stop
  
  #----------------------------------------------------------------
  # insere etapa 1 (liberado para o serviço)
  whenever error continue
  call cts10g04_insere_etapa(l_cts55g00.atdsrvnum,
                             l_cts55g00.atdsrvano,
                             l_servico.atdetpcod ,
                             "", "", "", "")
                   returning l_cts55g00.sqlcode
  whenever error stop
  
  display 'cts10g04_insere_etapa: ', l_cts55g00.sqlcode
  
  if l_cts55g00.sqlcode != 0
     then
     let l_errmsg = 'Erro 13: SQL ', l_cts55g00.sqlcode, ' | Tabela datmlcl(2)'
     rollback work
     display l_errmsg clipped
     return l_cts55g00.sqlcode, l_errmsg, '', '', ''
  end if
  
  commit work
  
  display 'SERVICO INCLUIDO COM SUCESSO CTS55G00'
  
  #----------------------------------------------------------------
  # monta email de verificacao
  
  whenever error continue
  
  let l_path = "./ins_srv_iphone.txt"

  start report cts55g00_resumo to l_path

  let l_msg = l_hora
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = '--------------------------------------------------------------------------------'
  output to report cts55g00_resumo(l_msg clipped)

  let l_srv = l_cts55g00.atdsrvnum using "<<<<<<<<<<", '/',
              l_cts55g00.atdsrvano using "<<"
  let l_msg = 'Servico..: ', l_srv clipped
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = l_tmp clipped
  output to report cts55g00_resumo(l_tmp clipped)

  let l_msg = '--------------------------------------------------------------------------------'
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Data da solicitacao    : ', l_servico.solicdat
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Hora da solicitacao    : ', l_servico.solichor
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Codigo do assunto      : ', l_servico.c24astcod
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Codigo do problema     : ', l_servico.c24pbmcod using "<<<<<"
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Descricao do problema  : ', l_servico.c24pbmdes
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Flag servico liberado  : ', l_servico.atdlibflg
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Flag aciona automatico : ', l_servico.atdfnlflg
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Tipo assistencia       : ', l_servico.asitipcod using "<<<<<"
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Nivel Prioridade       : ', l_servico.atdprinvlcod using "<<<<<"
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Origem Servico         : ', l_servico.atdsrvorg using "<<<<<"
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Flag requer remocao    : ', l_servico.remrquflg
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Veiculo                : ', l_servico.vcldes
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Placa                  : ', l_servico.vcllicnum
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Segurado               : ', l_servico.segnom
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'Apolice                : ', l_servico.succod using "<<<<<",
              '  ', l_servico.aplnumdig using "<<<<<<<<<<",
              ' - ', l_servico.itmnumdig using "<<<<<<<"
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = '--------------------------------------------------------------------------------'
  output to report cts55g00_resumo(l_msg clipped)

  let l_msg = 'LOCAL DA OCORRENCIA'
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Endereco    : ', l_ocorrencia.lgdtip clipped, ' ',
              l_ocorrencia.lgdnom clipped, ', ', l_ocorrencia.lgdnum using "<<<<<"
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Bairro      : ', l_ocorrencia.brrnom
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Cidade      : ', l_ocorrencia.cidnom
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'UF          : ', l_ocorrencia.ufdcod
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'CEP         : ', l_ocorrencia.lgdcep, '-', l_ocorrencia.lgdcepcmp using "<<<"
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Latitude    : ', l_ocorrencia.lclltt
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Longitude   : ', l_ocorrencia.lcllgt
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Contato     : ', l_ocorrencia.lclcttnom
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = 'Fone contato: ', '(', l_ocorrencia.dddcod clipped, ')', l_ocorrencia.lcltelnum using "<<<<<<<<<<"
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = '--------------------------------------------------------------------------------'
  output to report cts55g00_resumo(l_msg clipped)

  if l_servico.remrquflg is not null and
     l_servico.remrquflg = 'S'
     then
     let l_msg = 'LOCAL DE DESTINO'
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Endereco    : ', l_destino.lgdtip clipped, ' ',
                 l_destino.lgdnom clipped, ', ', l_destino.lgdnum using "<<<<<"
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Bairro      : ', l_destino.brrnom
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Cidade      : ', l_destino.cidnom
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'UF          : ', l_destino.ufdcod
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'CEP         : ', l_destino.lgdcep, '-', l_destino.lgdcepcmp using "<<<"
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Latitude    : ', l_destino.lclltt
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Longitude   : ', l_destino.lcllgt
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Contato     : ', l_destino.lclcttnom
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = 'Fone contato: ', '(', l_destino.dddcod clipped, ')', l_destino.lcltelnum using "<<<<<<<<<<"
     output to report cts55g00_resumo(l_msg clipped)
     
     let l_msg = '--------------------------------------------------------------------------------'
     output to report cts55g00_resumo(l_msg clipped)
  end if
  
  let l_msg = 'OBSERVACOES:'
  output to report cts55g00_resumo(l_msg clipped)
  
  let l_msg = l_rota clipped
  output to report cts55g00_resumo(l_msg clipped)
  
  finish report cts55g00_resumo

  # enviar e-mail com dados do servico inserido
  let l_assunto = 'Inclusao de servico ', l_servico.c24solnom, ': ', l_srv clipped

      
  if l_servico.c24astcod <> "G16" and 
     l_servico.c24astcod <> "G17" then     
     let l_ret = ctx22g00_mail_anexo_corpo("CTS55G00", l_assunto, l_path)
  

     if l_ret != 0 then
        if l_ret != 99 then
           display "Erro ao enviar email(ctx22g00) - ", l_path
        else
           display "Nao ha email cadastrado para o modulo "
        end if
     else
        display 'E-MAIL INFORMATIVO ENVIADO'
     end if
  end if    

  whenever error stop
  
  
  ###########  ATENCAO  ###########
  # retirar, colocado em 01/04 pois o front-end nao trata adequadamente
  initialize l_cts55g00.atdhorpvt to null
  
  
  # procedimentos OK
  return 0, l_errmsg, 
         l_cts55g00.atdsrvnum, l_cts55g00.atdsrvano, l_cts55g00.atdhorpvt

end function


#----------------------------------------------------------------
function cts55g00_ver_cidufd(l_param)
#----------------------------------------------------------------

  define l_param record
         cidnom  like datmlcl.cidnom ,
         ufdcod  like datmlcl.ufdcod
  end record
  
  define l_ret  integer
  
  let l_ret = 0
  
  whenever error continue
  select distinct mpacidcod into l_ret 
  from datkmpacid
  where ufdcod = l_param.ufdcod
    and cidnom = l_param.cidnom
  whenever error stop
  
  if sqlca.sqlcode != 0
     then
     return '', ''
  end if
  
  return l_param.cidnom, l_param.ufdcod

end function

#----------------------------------------------------------------
function cts55g00_valida_apolice_auto(l_param)
#----------------------------------------------------------------

  define l_param  record
         succod     like datrligapol.succod ,
         aplnumdig  like datrligapol.aplnumdig
  end record
  
  define l_cty05g00 record
         resultado  smallint
       , mensagem   char(42)
       , emsdat     like abamdoc.emsdat
       , aplstt     like abamapol.aplstt
       , vigfnl     like abamapol.vigfnl
       , etpnumdig  like abamapol.etpnumdig
  end record
  
  define l_ret     smallint
       , l_errmsg  char(120)
  
  initialize l_ret, l_cty05g00.* to null
   
  let l_ret = 0
  
  display 'Validar apolice:'
  
  whenever error continue
  call cty05g00_dados_apolice(l_param.succod, l_param.aplnumdig) 
       returning l_cty05g00.*
  whenever error stop
  
  if l_cty05g00.resultado = 3 or l_cty05g00.resultado = 2 or
     l_cty05g00.resultado is null
     then
     let l_cty05g00.mensagem = 'Erro ao obter data de emissao da apolice' 
     let l_ret = 992
  end if

  if l_cty05g00.emsdat is null
     then
     let l_cty05g00.mensagem = 'Apolice nao cadastrada'
     let l_ret = 992
  end if

  if l_cty05g00.vigfnl < today 
     then
     let l_cty05g00.mensagem = "Apolice nao vigente"
     let l_ret = 992
  end if
  
  if l_cty05g00.aplstt = "C" then
     let l_cty05g00.mensagem = "Apolice cancelada"
     let l_ret = 992
  end if
  
  if l_ret = 992
     then
     display 'Erro: ', l_cty05g00.mensagem clipped
  else
     display 'Validacao OK'
  end if
  
  return l_ret, l_cty05g00.mensagem
  
end function

#--------------------------------------------------------------------------
report cts55g00_resumo(l_linha)
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
