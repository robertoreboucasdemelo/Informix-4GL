#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SERVIÇOS AVULSOS                                     #
# MODULO.........: BDBSR018                                                   #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                      #
# PSI/OSF........:                                                            #
#                  RELATÓRIO SEMANAL DOS SERVIÇOS DO SAPS.                    #
# ........................................................................... #
# DESENVOLVIMENTO: JOSIANE APARECIDA DE ALMEIDA                               #
# LIBERACAO......: 13/08/2014                                                 #
#-----------------------------------------------------------------------------#
#                         * * * Alteracoes * * *                              #
#   Data     Autor Fabrica     Origem      Alteracao                          #
# 09/02/2015 Norton-Biztalk SPR-2014-28503 Processamento Diario, inclusao col.#
#                                          referente as vendas no relatorio   #
#-----------------------------------------------------------------------------#
# 26/03/2015 BizTalking - Marcos Souza - SPR-2015-06510-Indicadores Porto Faz #
#                         Adequacao para extração de dados de fechamento de   #
#                         venda e para processamento diario e mensal.         #
#-----------------------------------------------------------------------------#
# 11/05/2015 Biztalking - Norton Nery - SPR-2015-06510-2 - Ajuste do Envio do #
#                         tel. da Ocorrencia, ajuste no Calc. valor  pago  ao #
#                         prestador, ajuste no Calc. do Acresc. da Venda      # 
#-----------------------------------------------------------------------------#
# 06/07/2015 INTERA,MarcosMP SPR-2015-13708 Alteracoes:                       #
#                                        1. Vigencia no Cadastro SKU;         #
#                                        2. Incluir informacoes de desconto:  #
#                                           -Desconto informado (Perc e Valor)#
#                                           -Justificativa do operador        #
#                                           -Info Supervisor (Nome e Matric)  #
#                                           -Justificativa do supervisor.     #
#-----------------------------------------------------------------------------#
# 11/09/2015 Biztalking - Norton Nery SPR-2015-17043- Nova tabela de Voucher, #
#                         formatacao no print Qtde de servicos vendidos       #
#-----------------------------------------------------------------------------#
# 05/11/2015 BizTalking - Marcos Souza-SPR-2015-22413-Ação Promocional Black  #
#                         Friday                                              #
#                         Inclusão no relatorio de fechamento dos campos:     #
#                             - Data de Execucao Serviço                      #
#                             -	Hora de Execucao do Serviço	                  #
#                             - Valor Adicional Noturno/Feriado	              #
#                             - Flag  Pagto Adicional de Louca                #
#                             - Valor pago Adicional de Louca	                #
#                             - Flag  Pagto Adicional de Alvenaria	          #
#                             - Valor pago Adicional de Alvenaria	            #
#                             - Flag  Pagto Adicional hora Parada	            #
#                             - Qtde  Adicional hora Parada	                  #
#                             - Valor pago Adicional hora Parada	            #
#                             - Flag  Pagto Adicional hora Trabalhada	        #
#                             - Qtde  Adicional hora Trabalhada	              #
#                             - Valor pago Adicional hora Trabalhada	        #
#                             - Flag  Pagto Adicional KM	                    #
#                             - Qtde  Adicional KM	                          #
#                             - Valor pago Adicional KM	                      #
#                             - Valor Adicional Informado Fechto              #
#-----------------------------------------------------------------------------#
# 11/03/2016 InforSystem - Marcos Souza-SPR-2016-03565 - Vendas e Parcerias.  #
#                          Inclusão no relatorio de fechamento e vendas dos   #
#                          campos:                                            #
#                             - Codigo e Nome do Grupo de Natureza            #
#                             - Flag Servico Imediato                         #
#                             - Nome do Prestador                             #
#                             - Nome de Guerra do Prestador                   #
#                             - Programa de Pontos                            #
#-----------------------------------------------------------------------------#
# 21/03/2016  Josiane Almeida        Desconsiderar a etapa 8 (intermediaria)  #
#                                    no relatório de fechamento               # 
#-----------------------------------------------------------------------------#
# 08/06/2016  Josiane Almeida        Substituir o bairro lclbrrnom por brrnom #
#                                                                             # 
###############################################################################                                    

database porto

 define mr_servicos record
         c24astcod         like datmligacao.c24astcod
        ,c24astdes         like datkassunto.c24astdes
        ,atdsrvnum         like datmservico.atdsrvnum
        ,atdsrvano         like datmservico.atdsrvano
        ,atddat            like datmservico.atddat
        ,atdhor            like datmservico.atdhor
        ,srvcbnhor         like datmservico.srvcbnhor
        ,orrdat            like datmsrvre.orrdat
        ,sindat            like datmservicocmp.sindat
        ,c24soltipcod      like datmligacao.c24soltipcod
        ,c24soltipdes      like datksoltip.c24soltipdes
        ,atdprscod         like datmservico.atdprscod
        ,socvclcod         like datmsrvacp.socvclcod
        ,atdetpcod         like datmservico.atdetpcod
        ,funmat            like datmsrvacp.funmat
        ,funnom            like isskfunc.funnom       #- SPR-2015-22413
        ,atdetpdat         like datmsrvacp.atdetpdat  #- SPR-2015-22413
        ,atdetphor         like datmsrvacp.atdetphor  #- SPR-2015-22413
        ,acionamentoAut    char(3)
        ,socntzgrpcod      like datksocntz.socntzgrpcod    #- SPR-2016-03565
        ,socntzgrpdes      like datksocntzgrp.socntzgrpdes #- SPR-2016-03565
        ,socntzcod         char(60)
        ,socntzdes         char(60)
        ,c24pbmgrpcod      char(60)
        ,c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes
        ,c24pbmcod         char(60)
        ,c24pbmdes         like datkpbm.c24pbmdes
        ,asitipcod         like datmservico.asitipcod
        ,asitipdes         like datkasitip.asitipdes
        ,lgdtip            like datmlcl.lgdtip
        ,lgdnom            like datmlcl.lgdnom
        ,lgdnum            like datmlcl.lgdnum
        ,brrnom            like datmlcl.brrnom
        ,cidnom            like datmlcl.cidnom
        ,ufdcod            like datmlcl.ufdcod
        ,lgdcep            like datmlcl.lgdcep           #- SPR-2015-22413
        ,lgdcepcmp         like datmlcl.lgdcepcmp        #- SPR-2015-22413
        ,lclltt            like datmlcl.lclltt
        ,lcllgt            like datmlcl.lcllgt  
       ## ,cmlteldddcod      like datmlcl.cmlteldddcod   #- SPR-2015-06510-2
       ## ,cmltelnum         like datmlcl.cmltelnum      #- SPR-2015-06510-2
        ,dddcod            like datmlcl.dddcod           #- SPR-2015-06510-2
        ,lcltelnum         like datmlcl.lcltelnum        #- SPR-2015-06510-2
        ,celteldddcod      like datmlcl.celteldddcod     #- SPR-2015-06510
        ,celtelnum         like datmlcl.celtelnum        #- SPR-2015-06510
        ,pgtfrmcod         like datkpgtfrm.pgtfrmcod
        ,pgtfrmdes         like datkpgtfrm.pgtfrmdes
        ,cgccpfnum         like datrligcgccpf.cgccpfnum
        ,cgccpfdig         like datrligcgccpf.cgccpfdig
        ,cgcord            like datrligcgccpf.cgcord
        ,socopgitmvlr      like dbsmopgitm.socopgitmvlr
        ,endereco          char(1000)
        ,dataocrr          date
        ,atdetpdes         like datketapa.atdetpdes
        ,ultdatcpf         date
        ,atdsrvorg         like datmservico.atdsrvorg
        ,catcod            like datksrvcat.catcod        #- SPR-2014-28503
        ,catnom            like datksrvcat.catnom        #- SPR-2014-28503
        ,catagpcod         like datkcatagp.catagpcod     #- SPR-2015-06510
        ,catagpnom         like datkcatagp.catagpnom     #- SPR-2015-06510
        ,pgtfrmcod_venda   like datmpgtinf.pgtfrmcod     #- SPR-2014-28503
        ,vndsrvqtd         like datmsrvvnd.vndsrvqtd     #- SPR-2014-28503
        ,clitipcod         like datmsrvvnd.clitipcod     #- SPR-2014-28503
        ,dsccupidecod      like datmsrvvnd.dsccupidecod  #- SPR-2014-28503
        ,srvvnddscvlr      like datmsrvvnd.srvvnddscvlr  #- SPR-2014-28503
        ,srvvndacrvlr      like datmsrvvnd.srvvndacrvlr  #- SPR-2014-28503
        ,srvvndtotvlr      like datmsrvvnd.srvvndtotvlr  #- SPR-2014-28503
        ,srvvndparqtd      like datmsrvvnd.srvvndparqtd  #- SPR-2014-28503
        ,infdscper         like datmsrvvnd.infdscper     #=> SPR-2015-13708
        ,infdscvlr         like datmsrvvnd.srvvndtotvlr  #=> SPR-2015-13708
        ,infacrvlr         like datmsrvvnd.infacrvlr     #=> SPR-2015-13708
        ,vl_pgtprest       dec(12,2)                     #--- SPR-2015-06510 
        ,ftmvlr            like datmsrvvnd.ftmvlr        #--- SPR-2015-06510 
        ,prspgovlr         like datmsrvvnd.prspgovlr     #--- SPR-2015-06510 
        ,pgtfrmcod_vnd     like datkpgtfrm.pgtfrmcod     #- SPR-2014-28503
        ,pgtfrmdes_vnd     like datkpgtfrm.pgtfrmdes     #- SPR-2014-28503
        ,email             like datmsrvvnd.eltfisnotenvemanom #- SPR-2014-28503
        ,clitipnom         like datkcliprf.clitipnom     #- SPR-2014-28503
      ##  ,dscnom            like datksrvdsccup.dscnom   #- SPR-2014-28503
        ,dscnom            like datknovsrvdsccup.dscnom  #- SPR-2015-17043 
        ,clinom_band       like datmcrdcrtinf.clinom     #- SPR-2014-28503
        ,lgdtip_corr       like datmlcl.lgdtip           #- SPR-2014-28503
        ,lgdnom_corr       like datmlcl.lgdnom           #- SPR-2014-28503
        ,lgdnum_corr       like datmlcl.lgdnum           #- SPR-2014-28503
        ,brrnom_corr    	 like datmlcl.brrnom        #- SPR-2014-28503
        ,cidnom_corr       like datmlcl.cidnom           #- SPR-2014-28503
        ,ufdcod_corr       like datmlcl.ufdcod           #- SPR-2014-28503
        ,endereco_corr     char(1000)                    #- SPR-2014-28503
        ,orgnum            like datmpgtinf.orgnum        #- SPR-2014-28503
        ,prpnum            like datmpgtinf.prpnum        #- SPR-2014-28503
        ,crtnum            like datmcrdcrtinf.crtnum     #- SPR-2014-28503
        ,srvinccbrvlr      like datksrvcat.srvinccbrvlr  #- SPR-2014-28503
        ,cbrsrvadcvlr      like datksrvcat.cbrsrvadcvlr  #- SPR-2014-28503
        ,flglibsuperv      char(1)                       #- SPR-2014-28503
        ,tecvtaflg         like datksrvcat.tecvtaflg     #- SPR-2014-28503
        ,empcod            like datmservico.empcod       #- SPR-2015-06510
        ,funmat_vnd        like datmservico.funmat       #- SPR-2015-06510
        ,funnom_vnd        like isskfunc.funnom          #- SPR-2015-06510
        ,vndepacod         like datmvndepa.vndepacod     #- SPR-2015-06510
        ,vndepanom         like datkvndepatip.vndepanom  #- Etapa da Venda
        ,jstnom            like datkjsttip.jstnom        #- SPR-2015-06510
        ,cadempcod         like datmvndepa.cadempcod     #- SPR-2015-06510
        ,cadmatnum         like datmvndepa.cadmatnum     #- SPR-2015-06510
        ,funnom_fch        like isskfunc.funnom          #- SPR-2015-06510
        ,caddat            like datmvndepa.caddat        #- SPR-2015-06510
        ,atddatprg         like datmservico.atddatprg    #- SPR-2016-03565
        ,rspnom            like dpaksocor.rspnom         #- SPR-2015-06510
        ,nomgrr            like dpaksocor.nomgrr         #- SPR-2016-03565
        ,srrnom            like datksrr.srrnom           #- SPR-2015-06510
        ,srrcoddig         like datmsrvacp.srrcoddig     #- SPR-2015-06510
        ,clinom            like datksrvcli.clinom        #- SPR-2015-06510
        ,pestipcod         like datksrvcli.pestipcod     #- SPR-2015-06510
        ,prssrvvlr         like datksrvcat.prssrvvlr     #- SPR-2015-06510-2
        ,prsmulsrvvlr      like datksrvcat.prsmulsrvvlr  #- SPR-2015-06510-2
        ,jsttipcod         like datrjstlog.jsttipcod
        ,jsttxt_opr        like datrjstlog.jsttxt        #=> SPR-2015-13708
        ,funnom_sup        like isskfunc.funnom          #=> SPR-2015-13708
        ,funmat_sup        like isskfunc.funmat          #=> SPR-2015-13708
        ,jsttxt_sup        like datrjstlog.jsttxt        #=> SPR-2015-13708
        ,atdhordat         like datkvndfec.atdhordat     #- SPR-2015-22413
        ,nteadcvlr	       like datkvndfec.nteadcvlr	   #- SPR-2015-22413
        ,louadcvlr	       like datkvndfec.louadcvlr	   #- SPR-2015-22413
        ,avnadcvlr	       like datkvndfec.avnadcvlr	   #- SPR-2015-22413
        ,pdahorqtd	       like datkvndfec.pdahorqtd	   #- SPR-2015-22413
        ,pdahoradcvlr	     like datkvndfec.pdahoradcvlr	 #- SPR-2015-22413
        ,tblhoradcvlr	     like datkvndfec.tblhoradcvlr	 #- SPR-2015-22413
        ,tblhorqtd	       like datkvndfec.tblhorqtd	   #- SPR-2015-22413   
        ,pcrkmsqtd	       like datkvndfec.pcrkmsqtd	   #- SPR-2015-22413
        ,qlmadcvlr	       like datkvndfec.qlmadcvlr	   #- SPR-2015-22413
        ,infacrvlrprt      like datkvndfec.infacrvlr     #- SPR-2015-22413 
        ,fdlpgmcod         like datmsrvvnd.fdlpgmcod     #- SPR-2016-03565
        ,fdlpgmnom         like datkfdlpgm.fdlpgmnom     #- SPR-2016-03565
 end record

 define mr_apolice record
        succod             like abbmveic.succod    
       ,aplnumdig          like abbmveic.aplnumdig 
       ,itmnumdig          like abbmveic.itmnumdig 
       ,vcllicnum          like abbmveic.vcllicnum 
	end record

 define m_inicio_proc      datetime year to second
       ,m_fim_proc         datetime year to second
       ,m_data_atual       date
       ,m_hora_atual       datetime hour to minute
       ,m_data_inicio      date
       ,m_data_fim         date
       ,m_data_inicio_fech like datmvndepa.caddat
       ,m_data_fim_fech    like datmvndepa.caddat
       ,m_path             char(300)
       ,m_path_apl         char(300)  #--- SPR-2016-03565
       ,m_msg              char(100)
       ,m_tp_proc          char(06)
       ,m_tp_relat         char(06)  
       ,m_lidos            integer
       ,m_impressos        integer
      
#----------------------------------------#
main
#----------------------------------------#
 define l_aux              char(15)
 define l_tempo_tot        interval Hour to second
 define l_tot_desprez      integer
 define v_aux_datetime     char(20)
 
 initialize m_tp_proc      to null
 initialize m_tp_relat     to null
 initialize m_data_atual   to null
 initialize m_path         to null
 initialize m_path_apl     to null  #--- SPR-2016-03565
 initialize l_aux          to null
 initialize l_tempo_tot    to null
 initialize l_tot_desprez  to null
 initialize v_aux_datetime to null

 let m_inicio_proc = current
 let l_tot_desprez = 0
 
 # -> ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
 call fun_dba_abre_banco("CT24HS")
 
 # -> PARAMETROS DE ENTRADA DO PROGRAMA - SPR-2015-06510
 let m_tp_proc      = arg_val(1) #-- TIPO PROCESSAMENTO MENSAL / DIARIO
 let m_tp_relat     = arg_val(2) #-- TIPO RELATORIO VENDAS / FECHAM
 let m_data_atual   = arg_val(3) #-- DATA PARA PROCESSAMENTO  
  
 if m_data_atual is null or m_data_atual = " " then
    # ---> OBTER A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(2)
         returning m_data_atual,
                   m_hora_atual
 end if
 
 if m_tp_proc is not null then
    if m_tp_proc <> "D" and m_tp_proc <> "M" and m_tp_proc <> "S" then #-- 'D'=DIARIO / 'M'=MENSAL
       display "PARAMETRO TIPO PROCESSAMENTO '"
               ,m_tp_proc clipped
               ,"' INVALIDO - PROCESSO ENCERRADO"
       exit program(1)
    end if
 end if
 if m_tp_relat is not null then
    if m_tp_relat <> "V" and m_tp_relat <> "F" and m_tp_relat <> "A" then #-- 'V'=VENDAS / 'F'=FECHAMENTO
       display "PARAMETRO TIPO RELATORIO '"
               ,m_tp_relat clipped
               ,"' INVALIDO - PROCESSO ENCERRADO"
       exit program(1)
    end if
 end if
 
 If m_tp_proc = "S" and m_tp_relat = "A" then
   call fpsfc045()
   exit program(0)
 end if
 
 #---> Periodo de extracao dos dados (Mensal)
 if m_tp_proc = "M" then #-  'M'=Tipo Processamento Mensal
    let m_data_inicio = (m_data_atual - 1 units month)     
    let l_aux = m_data_inicio
    let l_aux[1,2] = "01"
    
    let m_data_inicio = l_aux
    let m_data_fim    = (m_data_inicio + 1 units month)
    let m_data_fim    = (m_data_fim - 1 units day)        
 else
    let m_data_inicio = (m_data_atual - 1 units day)
    let m_data_fim    = (m_data_atual - 1 units day)   
 end if
 
 let m_data_inicio_fech = m_data_inicio 
 let m_data_fim_fech    = m_data_fim
 let v_aux_datetime     = m_data_fim_fech
 let v_aux_datetime[12,19] =  "23:59:59"
 let m_data_fim_fech    = v_aux_datetime       

 display "#--------------------------------------------------# "
 display " "
 display "---  Parametros de Execucao  ---"
 display "Inicio Processamento     : ", m_inicio_proc
 display "Periodo Inicio           : ", m_data_inicio
 display "Periodo Fim              : ", m_data_fim
 display "Periodo Inicio fecha     : ", m_data_inicio_fech
 display "Periodo Fim fecha        : ", m_data_fim_fech 
 display " "
 
 if m_tp_relat = "F" then    #-- 'V'=VENDAS / 'F'=FECHAMENTO
    let l_aux = "'F'=FECHAMENTO" 
 else
    let l_aux = "'V'=VENDAS"
 end if

 display "Tipo Relatorio           : ", l_aux clipped
 
 if m_tp_proc = "M" then #-- 'M'=MENSAL / 'D'=DIARIO
    let l_aux = "'M'=MENSAL" 
 else
    let l_aux = "'D'=DIARIO" 
 end if
 
 display "Tipo Processamento       : ", l_aux clipped
 
 call bdbsr018_busca_path()
  
 display "Nome do Arquivo Gerado   : ", m_path clipped
 
 start report bdbsr018_relatorio to m_path 
 
 if m_tp_proc = "M" then #-- 'M'=MENSAL / 'D'=DIARIO #--- SPR-2016-03565
    display "Nome do Arquivo Apolice Gerado  : ", m_path_apl clipped

 	  start report bdbsr018_relat_apl to m_path_apl
 end if
 
 call bdbsr018_prepare()
 
 set isolation to dirty read
 
 call bdbsr018_gera()
 
 finish report bdbsr018_relatorio

 if m_tp_proc = "M" then #-- 'M'=MENSAL / 'D'=DIARIO #--- SPR-2016-03565
 	  finish report bdbsr018_relat_apl
 end if

 call bdbsr018_envia_email(m_data_inicio, m_data_fim) #-@@@ Para testes na u28 comentar esta linha
 
 let m_fim_proc = current

 let l_tempo_tot = m_fim_proc - m_inicio_proc
 let l_tot_desprez = m_lidos - m_impressos
 
 display "#--------------------------------------------------# "
 display " "
 display "Fim do Processamento       : ", m_fim_proc
 display " "
 display "Tempo Processamento        : ", l_tempo_tot
 display "Total Registros lidos      : ", m_lidos
 display "Total Registros Impressos  : ", m_impressos
 display "Total Registros Desprezados: ", l_tot_desprez

end main

#-----------------------------------------#
function bdbsr018_prepare()
#-----------------------------------------#
 define l_sql char(9000)

 if m_tp_relat = "F" then #-- Tipo Relatorio 'Fechamento' - SPR-2015-06510
    let l_sql = "select                   "
               ,"      srv.atdsrvnum      "   #- Numero Servico
               ,"     ,srv.atdsrvano      "   #- Ano Servico
               ,"     ,srv.atddat         "   #- Data Atendimento
               ,"     ,srv.atdhor         "   #- Hora Atendimento
               ,"     ,srv.srvcbnhor      "   #- Data/Hora Agendada
               ,"     ,srv.atdetpcod      "   #- Codigo etapa de atendimento
               ,"     ,srv.asitipcod      "   #- Codigo tipo de assistencia
               ,"     ,srv.atdsrvorg      "   #- Origem do servico
               ,"     ,srv.empcod         "   #- Codigo empresa - SPR-2015-06510
               ,"     ,srv.funmat         "   #- Operador Venda - SPR-2015-06510
               ,"     ,srv.atdprscod      "   #- Cod Prestador -  SPR-2015-06510
               ,"     ,lig.c24soltipcod   "   #- Codigo tipo solicitante
               ,"     ,lig.c24astcod      "   #- Codigo do Assunto
               ,"     ,acp.srrcoddig      "   #- Codigo do socorrista
               ,"     ,acp.funmat         "   #- Matricula do operador
               ,"     ,acp.atdetpdat      "   #- Data do acionamento
               ,"     ,acp.atdetphor      "   #- Hora do acionamento
               ,"     ,etv.cadempcod      "   #- Cod da empresa - SPR-2015-06510
               ,"     ,etv.cadmatnum      "   #- Operador Fech - SPR-2015-06510
               ,"     ,etv.caddat         "   #- Data/Hora Fech - SPR-2015-06510
               ,"     ,etv.vndepacod      "   #- Etapa da venda - SPR-2015-06510
               ,"     ,srv.atddatprg      "   #- Dt Programada Atend - SPR-2016-03565
               ,"     ,vnd.fdlpgmcod      "   #- Cod Programa Pontos - SPR-2016-03565
              # ,"     ,pgm.fdlpgmnom      "   #- Nome Programa Pontos - SPR-2016-03565
               ," from datmservico srv    "   #- Servicos das chamadas c24 horas
               ,"     ,datmligacao lig    "   #- Ligacoes da central 24 horas 
               ,"     ,datmsrvacp acp     "   #- Acompanhamento do servico 
               ,"     ,datmvndepa etv     "   #- Movto etapa venda
               ,"     ,datmsrvvnd vnd     "   #- Vendas servicos - SPR-2016-03565
             #  ,"     ,outer datkfdlpgm pgm " #- Programa pontos - SPR-2016-03565
               ,"where srv.ciaempcod = 43 "   
               ,"  and etv.caddat between ? and ?    "
               ,"  and etv.vndepacod > 2  "   # 3-Fechado
                                              # 4-Visita Técnica
                                              # 5-Visita Prestador
                                              # 7-Cancelado
               ,"  and etv.vndepacod <> 6 "   # 6-EMITIDO COBRANCA
               ,"  and etv.vndepacod <> 8 "   # 8-Intermediaria
               ,"  and etv.atdsrvnum = srv.atdsrvnum "
               ,"  and etv.atdsrvano = srv.atdsrvano "
               ,"  and srv.atdsrvnum = acp.atdsrvnum "
               ,"  and srv.atdsrvano = acp.atdsrvano "
               ,"  and srv.atdsrvseq = acp.atdsrvseq "
               ,"  and vnd.atdsrvnum = srv.atdsrvnum " #- SPR-2016-03565
               ,"  and vnd.atdsrvano = srv.atdsrvano " #- SPR-2016-03565
             #  ,"  and vnd.fdlpgmcod = pgm.fdlpgmcod " #- SPR-2016-03565
               ,"  and lig.atdsrvnum = srv.atdsrvnum "
               ,"  and lig.atdsrvano = srv.atdsrvano "
               ,"  and lig.lignum = (select min(lgc.lignum) "
               ,"                      from datmligacao lgc "
               ,"                     where lgc.atdsrvnum = srv.atdsrvnum "
               ,"                       and lgc.atdsrvano = srv.atdsrvano)"
 else   #-- Tp Relatorio Venda - SPR-2015-06510
    let l_sql = "select                   "
               ,"      srv.atdsrvnum      "   #- Numero Servico
               ,"     ,srv.atdsrvano      "   #- Ano Servico
               ,"     ,srv.atddat         "   #- Data Atendimento
               ,"     ,srv.atdhor         "   #- Hora Atendimento
               ,"     ,srv.srvcbnhor      "   #- Data/Hora Agendada
               ,"     ,srv.atdetpcod      "   #- Codigo etapa de atendimento
               ,"     ,srv.asitipcod      "   #- Codigo tipo de assistencia
               ,"     ,srv.atdsrvorg      "   #- Origem do servico
               ,"     ,srv.empcod         "   #- Codigo empresa - SPR-2015-06510
               ,"     ,srv.funmat         "   #- Operador Venda - SPR-2015-06510
               ,"     ,srv.atdprscod      "   #- Cod Prestador -  SPR-2015-06510
               ,"     ,lig.c24soltipcod   "   #- Codigo tipo solicitante
               ,"     ,lig.c24astcod      "   #- Codigo do Assunto
               ,"     ,acp.srrcoddig      "   #- Codigo do socorrista
               ,"     ,acp.funmat         "   #- Matricula do operador
               ,"     ,acp.atdetpdat      "   #- Data do acionamento
               ,"     ,acp.atdetphor      "   #- Hora do acionamento
               ,"     ,' '                "   #- Cod da empresa - SPR-2015-06510
               ,"     ,' '                "   #- Operador Fech - SPR-2015-06510
               ,"     ,' '                "   #- Data/Hora Fech - SPR-2015-06510
               ,"     ,' '                "   #- Etapa da venda - SPR-2015-06510
               ,"     ,srv.atddatprg      "   #- Dt Programada Atend - SPR-2016-03565
               ,"     ,vnd.fdlpgmcod      "   #- Cod Programa Pontos - SPR-2016-03565
             #  ,"     ,pgm.fdlpgmnom      "   #- Nome Programa Pontos - SPR-2016-03565
               ," from datmservico srv    "   #- Servicos das chamadas c24 horas
               ,"     ,datmligacao lig    "   #- Ligacoes da central 24 horas 
               ,"     ,datmsrvacp acp     "   #- Acompanhamento do servico 
               ,"     ,outer datmsrvvnd vnd     "   #- Vendas servicos - SPR-2016-03565
              # ,"     ,outer datkfdlpgm pgm " #- Programa pontos - SPR-2016-03565
               ,"where srv.ciaempcod = 43 "
               ,"  and srv.atddat between ? and ?    "
               ,"  and srv.atdsrvnum = acp.atdsrvnum "
               ,"  and srv.atdsrvano = acp.atdsrvano "
               ,"  and srv.atdsrvseq = acp.atdsrvseq "
               ,"  and vnd.atdsrvnum = srv.atdsrvnum " #- SPR-2016-03565
               ,"  and vnd.atdsrvano = srv.atdsrvano " #- SPR-2016-03565
              # ,"  and vnd.fdlpgmcod = pgm.fdlpgmcod " #- SPR-2016-03565
               ,"  and lig.atdsrvnum = srv.atdsrvnum "
               ,"  and lig.atdsrvano = srv.atdsrvano "
               ,"  and lig.lignum = (select min(lgc.lignum) "
               ,"                      from datmligacao lgc "
               ,"                     where lgc.atdsrvnum = srv.atdsrvnum "
               ,"                       and lgc.atdsrvano = srv.atdsrvano)"
 end if
 prepare pbdbsr018001 from l_sql
 declare cbdbsr018001 cursor for pbdbsr018001
                         
 let l_sql = 'select                       '
            ,'      c24astdes                '
            ,' from datkassunto              '
            ,'where c24astcod = ?            '
 prepare pbdbsr018002 from l_sql
 declare cbdbsr018002 cursor for pbdbsr018002

 let l_sql = 'select                         '
            ,'      k.socntzcod              '
            ,'     ,k.socntzdes              '
            ,'     ,m.orrdat                 '
            ,'     ,k.socntzgrpcod           '  #- SPR-2016-03565
            ,'     ,g.socntzgrpdes           '  #- SPR-2016-03565
            ,' from datmsrvre m              '
            ,'     ,datksocntz k             '
            ,'     ,datksocntzgrp g          '  #- SPR-2016-03565
            ,'where m.atdsrvnum = ?          '
            ,'  and m.atdsrvano = ?          '
            ,'  and m.socntzcod = k.socntzcod'
            ,'  and k.socntzgrpcod = g.socntzgrpcod ' #- SPR-2016-03565
 prepare pbdbsr018003 from l_sql
 declare cbdbsr018003 cursor for pbdbsr018003


 let l_sql = 'select                             '
            ,'      pbm.c24pbmcod,               '
            ,'      pbm.c24pbmdes,               '
            ,'      pbm.c24pbmgrpcod             '
            ,' from                              '
            ,'      datkpbm pbm,                 '
            ,'      datrsrvpbm svp               '
            ,'where svp.atdsrvnum = ?            '
            ,'  and svp.atdsrvano = ?            '
            ,'  and svp.c24pbmcod = pbm.c24pbmcod'
 prepare pbdbsr018004 from l_sql
 declare cbdbsr018004 cursor for pbdbsr018004


 let l_sql = 'select                 '
            ,'       lgdtip          '
            ,'      ,lgdnom          '
            ,'      ,lgdnum          '
            ,'      ,trim(brrnom) '
            ,'      ,cidnom          '
            ,'      ,ufdcod          '
            ,'      ,lclltt          '
            ,'      ,lcllgt          '
           ## ,'      ,cmlteldddcod    '    #--- SPR-2015-06510       
           ## ,'      ,cmltelnum       '    #--- SPR-2015-06510
            ,'      ,dddcod          '    #-- SPR-2015-06510-2
            ,'      ,lcltelnum       '    #-- SPR-2015-06510-2   
            ,'      ,celteldddcod    '    #--- SPR-2015-06510       
            ,'      ,celtelnum       '    #--- SPR-2015-06510       
            ,'      ,lgdcep          '
            ,'      ,lgdcepcmp       '
            ,'  from datmlcl         '
            ,' where atdsrvnum = ?   '
            ,'   and atdsrvano = ?   '
            ,'   and c24endtip = ?   '    ##-- SPR-2014-28503
 prepare pbdbsr018005 from l_sql
 declare cbdbsr018005 cursor for pbdbsr018005


 let l_sql = 'select                             '
            ,'      frm.pgtfrmcod,               '
            ,'      frm.pgtfrmdes                '
            ,' from datmpgtinf inf,              '
            ,'      datkpgtfrm frm               '
            ,'where inf.atdsrvnum = ?            '
            ,'  and inf.atdsrvano = ?            '
            ,'  and inf.pgtfrmcod = frm.pgtfrmcod'
 prepare pbdbsr018006 from l_sql
 declare cbdbsr018006 cursor for pbdbsr018006


 let l_sql = 'select                          '
            ,'        cpf.cgccpfnum,          '
            ,'        cpf.cgccpfdig,          '
            ,'        cpf.cgcord              '
            ,'   from datmligacao lig,        '
            ,'        datrligcgccpf cpf       '
            ,'  where lig.atdsrvnum = ?       '
            ,'    and lig.atdsrvano = ?       '
            ,'    and lig.lignum    = (select min(lignum)                    '
            ,'                           from datmligacao lig2               '
            ,'                          where lig2.atdsrvnum = lig.atdsrvnum '
            ,'                            and lig2.atdsrvano = lig.atdsrvano)'
            ,'    and lig.lignum = cpf.lignum                                '
 prepare pbdbsr018007 from l_sql
 declare cbdbsr018007 cursor for pbdbsr018007


 let l_sql =  'select               '
            ,'      itm.socopgitmvlr'
            ,' from dbsmopg opg,    '
            ,'      dbsmopgitm itm  '
            ,'where atdsrvnum = ?   '
            ,'  and atdsrvano = ?   '
            ,'  and opg.socopgnum = itm.socopgnum '
 prepare pbdbsr018008 from l_sql
 declare cbdbsr018008 cursor for pbdbsr018008


 let l_sql = 'select                '
            ,'      sindat          '
            ,' from datmservicocmp  '
            ,'where atdsrvnum = ?   '
            ,'  and atdsrvano = ?   '
 prepare pbdbsr018009 from l_sql
 declare cbdbsr018009 cursor for pbdbsr018009


 let l_sql = 'select                '
            ,'      atdetpdes       '
            ,' from datketapa       '
            ,'where atdetpcod = ?   '
 prepare pbdbsr018010 from l_sql
 declare cbdbsr018010 cursor for pbdbsr018010


 let l_sql = 'select                  '
            ,'       asi.asitipdes    '
            ,' from datkasitip asi    '
            ,'where asi.asitipcod = ? '
 prepare pbdbsr018011 from l_sql
 declare cbdbsr018011 cursor for pbdbsr018011


 let l_sql = 'select                     '
            ,'       grp.c24pbmgrpdes    '
            ,' from datkpbmgrp grp       '
            ,'where grp.c24pbmgrpcod = ? '
 prepare pbdbsr018012 from l_sql
 declare cbdbsr018012 cursor for pbdbsr018012


 let l_sql = 'select max(srv.atddat)		'
            ,'  from datmservico srv,  '
            ,'       datmligacao lig,  '
            ,'       datrligcgccpf cpf '
            ,'where cpf.cgccpfnum = ?  '
            ,'   and cpf.cgcord = ?    '
            ,'   and cpf.cgccpfdig = ? '
            ,'   and cpf.lignum = lig.lignum       '
            ,'   and lig.atdsrvnum = srv.atdsrvnum '
            ,'   and lig.atdsrvano = srv.atdsrvano '
            ,'   and lig.lignum    = (select min(lignum)      '
            ,'                           from datmligacao lig2'
            ,'                          where lig2.atdsrvnum = srv.atdsrvnum '
            ,'                            and lig2.atdsrvano = srv.atdsrvano)'
 prepare pbdbsr018013 from l_sql
 declare cbdbsr018013 cursor for pbdbsr018013


 let l_sql = 'select c24soltipdes from datksoltip '
            ,' where c24soltipcod = ?             '
 prepare pbdbsr018014 from l_sql
 declare cbdbsr018014 cursor for pbdbsr018014


 ##-- SPR-2014-28503 - Inicio - Busca informacoes da venda
 let l_sql = 'select vnd.catcod      , sku.catnom      , vnd.pgtfrmcod      '
            ,'      ,vnd.vndsrvqtd   , vnd.clitipcod   , vnd.dsccupidecod   '
            ,'      ,vnd.srvvnddscvlr, vnd.srvvndacrvlr, vnd.srvvndtotvlr   '
            ,'      ,vnd.srvvndparqtd, vnd.eltfisnotenvemanom, prf.clitipnom'
            ,'      ,vch.dscnom      , sku.srvinccbrvlr, sku.cbrsrvadcvlr   '
            ,'      ,sku.tecvtaflg   , gsk.catagpcod   , gsk.catagpnom      '
            ,'      ,vnd.ftmvlr      , vnd.prspgovlr   , vnd.infdscper      '
            ,'      ,vnd.infacrvlr   , sku.prsmulsrvvlr, sku.prssrvvlr      '
            ,'  from datmsrvvnd vnd       '      
            ,'      ,datmsrvcathst sku    '                 #=> SPR-2015-13708
            ,'      ,outer datkcatagp gsk ' #- SPR-2015-06510 (13708: OUTER)
            ,'      ,outer datkcliprf prf '
          #  ,'      ,outer datksrvdsccup vch  '
            ,'      ,outer datknovsrvdsccup vch  ' #- SPR-2015-17043 
            ,' where vnd.atdsrvnum    = ?     '
            ,'   and vnd.atdsrvano    = ?     '
            ,'   and vnd.catcod       = sku.catcod    '
            ,'   and          ? between sku.althordat '     #=> SPR-2015-13708
                                 ,' and sku.atldat    '     #=> SPR-2015-13708
            ,'   and vnd.clitipcod    = prf.clitipcod '
            ,'   and vnd.dsccupidecod = vch.dsccupidecod '
            ,'   and gsk.catagpcod    = sku.catagpcod    '  #--- SPR-2015-06510
 prepare pbdbsr018015 from l_sql
 declare cbdbsr018015 cursor for pbdbsr018015


 ##-- Busca proposta do servico -- SPR-2014-28503 - Fim
 let l_sql      = ' select a.prpnum              '
                 ,'   from datmpgtinf a,          '
                 ,'        outer datmcrdcrtinf b  '
                 ,'  where a.orgnum    = b.orgnum '
                 ,'    and a.prpnum    = b.prpnum '
                 ,'    and a.atdsrvnum = ?        '
                 ,'    and a.atdsrvano = ?        '
                 ,'    and b.pgtseqnum = (select max(d.pgtseqnum)     '
                 ,'                        from datmcrdcrtinf d       '
                 ,'                       where d.prpnum = b.prpnum ) '
 prepare pbdbsr018019 from l_sql
 declare cbdbsr018019 cursor for pbdbsr018019


 ##-- Busca numero do cartao de crédito -- SPR-2014-28503 - Fim
 let l_sql      = ' select crtnum                '
                 ,'   from datmcrdcrtinf         '
                 ,'  where orgnum  = ?           '
                 ,'    and prpnum  = ?           '
                 ,'    and pgtseqnum = (select max(pgtseqnum)  '
                 ,'                       from datmcrdcrtinf a '
                 ,'                      where a.orgnum = ?    '
                 ,'                        and a.prpnum = ?)   '
 prepare pbdbsr018020 from l_sql
 declare cbdbsr018020 cursor for pbdbsr018020

 let l_sql      = ' select cpodes                  '
                 ,'   from iddkdominio             '
                 ,' where cponom = "vnd.pgtfrmcod" '
                 ,'   and cpocod = ?               '
 prepare pbdbsr018021 from l_sql
 declare cbdbsr018021 cursor for pbdbsr018021

 #=> SPR-2015-13708: BUSCA JUSTIFICATIVAS DO DESCONTO INFORMADO
 let l_sql =  ' select j1.jsttxt, j1.cadmatnum, j1.cadempcod '
             ,'   from datrjstlog j1  '
             ,'  where j1.atdsrvnum  = ? '
             ,'    and j1.atdsrvano  = ? '
             ,'    and j1.jsttipcod  = ? '
             ,'    and j1.jstseqnum = (select max(jstseqnum)               '
                                     ,'  from datrjstlog j3                '
                                     ,' where j3.atdsrvnum = j1.atdsrvnum  '
                                     ,'   and j3.atdsrvano = j1.atdsrvano  '
                                     ,'   and j3.jsttipcod = j1.jsttipcod) '
             ,'    and j1.seqsubnum  = 1 '
 prepare pbdbsr018022 from l_sql
 declare cbdbsr018022 cursor for pbdbsr018022

 #--- Captura o nome do prestador - SPR-2015-06510
 let l_sql = ' select rspnom        '
            ,'       ,nomgrr        '   #- SPR-2016-03565
            ,'   from dpaksocor     '
            ,'  where pstcoddig = ? '
 prepare pbdbsr018023 from l_sql
 declare cbdbsr018023 cursor for pbdbsr018023

#--- Captura o nome do socorrista - SPR-2015-06510
 let l_sql = ' select srrnom        '
            ,'   from datksrr       '
            ,'  where srrcoddig = ? '
 prepare pbdbsr018024 from l_sql
 declare cbdbsr018024 cursor for pbdbsr018024

#--- Captura o nome do socorrista - SPR-2015-06510
 let l_sql = ' select clinom '    
            ,'       ,pestipcod  '
            ,'   from datksrvcli '
            ,'  where cpjcpfnum    = ? '
            ,'    and cpjordnum    = ? '
            ,'    and cpjcpfdignum = ? '
 prepare pbdbsr018025 from l_sql
 declare cbdbsr018025 cursor for pbdbsr018025

#--- Captura o nome do funcionario - SPR-2015-06510
let l_sql =  "select funnom    "
            ,"  from isskfunc  "
            ," where empcod =  ? "
            ,"   and funmat =  ? "
            ,"   and usrtip = 'F'"
 prepare pbdbsr018026 from l_sql
 declare cbdbsr018026 cursor for pbdbsr018026
         

 #--- Captura a justificativa - SPR-2015-06510
 let l_sql =  "select jstnom    "
             ,"  from datkjsttip  "
          ##  ," where vndepacod =  ? "
             ," where jsttipcod =  ? "
 prepare pbdbsr018027 from l_sql
 declare cbdbsr018027 cursor for pbdbsr018027
 
 #--- Busca Descricao da Etapa do Fechamento - SPR-2015-06510
 let l_sql = 'select vndepanom       '
            ,' from datkvndepatip       '
            ,'where vndepacod = ?   '
 prepare pbdbsr018028 from l_sql
 declare cbdbsr018028 cursor for pbdbsr018028
 
 #--- Busca ultimo codigo da justificativa do Motivo do Fechamento
 let l_sql =  " select a.jsttipcod      "
             ,"   from datrjstlog a     "
             ," where a.atdsrvnum = ?   "
             ,"   and a.atdsrvano = ?   "
             ,"   and a.jstseqnum = (select max(jstseqnum)             "
             ,"                        from datrjstlog b               "
             ,"                       where b.atdsrvnum = a.atdsrvnum  "
             ,"                         and b.atdsrvano = a.atdsrvano) " 
 prepare pbdbsr018029 from l_sql
 declare cbdbsr018029 cursor for pbdbsr018029

 #--- Busca Valores de Pagamentos Adicionais ao Prestador - SPR-2015-22413
 let l_sql =  " select atdhordat      "
             ,"       ,nteadcvlr	    "
             ,"       ,louadcvlr	    "
             ,"       ,avnadcvlr	    "
             ,"       ,pdahorqtd	    "
             ,"       ,pdahoradcvlr	  "
             ,"       ,tblhoradcvlr	  "
             ,"       ,tblhorqtd	    "
             ,"       ,tblhoradcvlr	  "
             ,"       ,pcrkmsqtd	    "
             ,"       ,qlmadcvlr	    "
             ,"       ,infacrvlr      "
             ,"   from datkvndfec     "
             ," where atdsrvnum = ?   "
             ,"   and atdsrvano = ?   "
 prepare pbdbsr018030 from l_sql
 declare cbdbsr018030 cursor for pbdbsr018030

#--- Busca Dados da Apolice - SPR-2016-03565 - Vendas e Parcerias.
 let l_sql =  " select abbmveic.succod            "
             ,"       ,abbmveic.aplnumdig         "
             ,"       ,abbmveic.itmnumdig         "
             ,"       ,abbmveic.vcllicnum         "
             ,"       ,max(abbmveic.dctnumseq)    "
             ,"   from abbmveic                   "
             ,"  where aplnumdig = ? "
             ,"    and itmnumdig = ? "
             ," group by abbmveic.succod, abbmveic.aplnumdig, abbmveic.itmnumdig, abbmveic.vcllicnum"
            
 prepare pbdbsr018031 from l_sql
 declare cbdbsr018031 cursor for pbdbsr018031
 
 
 
 #--- Busca Apolice por CPF - SPR-2016-03565 - Vendas e Parcerias.
 let l_sql =  " select aplnumdig         "
             ,"       ,itmnumdig         "
             ,"       ,max(dctnumseq)    "
             ,"   from abbmapldctsgm     "
             ,"  where segcpjcpfnum = ? "
             ,"    and segcpjordnum = ? "
             ,"    and segcpjcpfdig = ? "
             ," group by aplnumdig, itmnumdig"
            
 prepare pbdbsr018032 from l_sql
 declare cbdbsr018032 cursor for pbdbsr018032
 
 
 
 
  #--- Busca Programa de Pontos
 let l_sql =  " select fdlpgmnom     "
             ,"   from datkfdlpgm    "
             ,"  where fdlpgmcod = ? "
            
 prepare pbdbsr018033 from l_sql
 declare cbdbsr018033 cursor for pbdbsr018033

         
end function

#-----------------------------------------#
function bdbsr018_gera()
#-----------------------------------------#
##-- SPR-2014-28503 - Inicio
 define l_c24endtip     like datmlcl.c24endtip
 define l_sql           char(9000)
 define l_lixo          char(100)  #--- SPR-2015-06510

 ##-- SPR-2014-28503 - Inicio
 initialize mr_servicos to null
 initialize mr_apolice to null   #--- SPR-2016-03565
 initialize l_c24endtip to null

 let m_lidos      = 0    #--- SPR-2015-06510
 let m_impressos  = 0    #--- SPR-2015-06510
 ##-- SPR-2014-28503 - Fim

 if m_tp_relat = "F" then #-- Tipo Relatorio 'Fechamento' - SPR-2015-06510
    open cbdbsr018001 using m_data_inicio_fech, m_data_fim_fech
 else #--- Tipo Relatorio 'Vendas'
    open cbdbsr018001 using m_data_inicio, m_data_fim
 end if

 whenever error continue 
 foreach cbdbsr018001 into mr_servicos.atdsrvnum    #- Numero Servico  
                          ,mr_servicos.atdsrvano    #- Ano Servico
                          ,mr_servicos.atddat       #- Data Atendimento
                          ,mr_servicos.atdhor       #- Hora Atendimento
                          ,mr_servicos.srvcbnhor    #- Data/Hora Agendada
                          ,mr_servicos.atdetpcod    #- Etapa de atendimento
                          ,mr_servicos.asitipcod    #- Tipo de assistencia
                          ,mr_servicos.atdsrvorg    #- Origem do servico
                          ,mr_servicos.empcod       #- Empresa - SPR-2015-06510
                          ,mr_servicos.funmat_vnd   #- Oper Vnd - SPR-2015-06510
                          ,mr_servicos.atdprscod    #- Prestad -  SPR-2015-06510
                          ,mr_servicos.c24soltipcod #- Codigo tipo solicitante
                          ,mr_servicos.c24astcod    #- Codigo do Assunto
                          ,mr_servicos.srrcoddig    #- Socorris - SPR-2015-06510
                          ,mr_servicos.funmat       #- Operador - SPR-2015-06510
                          ,mr_servicos.atdetpdat    #- Data do acionamento - SPR-2015-22413
                          ,mr_servicos.atdetphor    #- Hora do acionamento - SPR-2015-22413
                          ,mr_servicos.cadempcod    #- Empresa  - SPR-2015-06510
                          ,mr_servicos.cadmatnum    #- Oper Fch - SPR-2015-06510
                          ,mr_servicos.caddat       #- Dt/Hr Fch -SPR-2015-06510
                          ,mr_servicos.vndepacod    #- Etapa vnd -SPR-2015-06510
                          ,mr_servicos.atddatprg    #- Dt Programada Atendim - SPR-2016-03565
                          ,mr_servicos.fdlpgmcod    #- Cod Programa Pontos - SPR-2016-03565
                        #  ,mr_servicos.fdlpgmnom    #- Nome Programa Pontos - SPR-2016-03565

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          display "Erro SELECT cbdbsr018001 / ",
                  sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          exit program(1)
       end if
    end if

    let m_lidos = m_lidos + 1 #--- SPR-2015-06510    

    call bdbsr018_busca_acionamento() #- Verifica se eh acionamento automatico

    call bdbsr018_func(mr_servicos.empcod #- Nome Oper Acionamento-SPR-2015-22413
                      ,mr_servicos.funmat)
         returning mr_servicos.funnom

    call bdbsr018_descr_assunto() #- Pesq cadastro de assuntos central 24hs

    call bdbsr018_descr_solicitante() #- Captura descricao tipo solicitante

    call bdbsr018_busca_ocorrencia() #- Verifica se o Servico eh RE ou AUTO

    call bdbsr018_busca_problema() #- Captura problema e grupo 

    call bdbsr018_descr_assistencia() #- Captura Descricao do Tipo Assistencia 

    let l_c24endtip = 1  #-- Tp Endereco - '1'= Ocorrencia ##-- SPR-2014-28503
     
    call bdbsr018_busca_endereco(l_c24endtip)  #- Busca endereco
         returning  mr_servicos.lgdtip       
                   ,mr_servicos.lgdnom       
                   ,mr_servicos.lgdnum       
                   ,mr_servicos.brrnom    
                   ,mr_servicos.cidnom       
                   ,mr_servicos.ufdcod       
                   ,mr_servicos.endereco
                   ,mr_servicos.lclltt       
                   ,mr_servicos.lcllgt       
                 ##  ,mr_servicos.cmlteldddcod 
                 ##  ,mr_servicos.cmltelnum  
                   ,mr_servicos.dddcod              ##-- SPR-2015-06510-2
                   ,mr_servicos.lcltelnum           ##-- SPR-2015-06510-2
                   ,mr_servicos.celteldddcod 
                   ,mr_servicos.celtelnum
                   ,mr_servicos.lgdcep       #- SPR-2015-22413
                   ,mr_servicos.lgdcepcmp    #- SPR-2015-22413 
                   
    call bdbsr018_descr_pagto() #- Captura cod e descricao forma pagto   

    call bdbsr018_busca_ligacao() #- Captura ligacao por cgc/cpf

    call bdbsr018_func(mr_servicos.empcod  #--- Nome Oper Venda - SPR-2015-06510
                      ,mr_servicos.funmat_vnd)
         returning mr_servicos.funnom_vnd

    call bdbsr018_nome_prestador() #- Captura nome do prestador - SPR-2015-06510

    call bdbsr018_nome_socorrista() #- Captura nome socorrista - SPR-2015-06510

    call bdbsr018_busca_cliente() #- Captura o nome do cliente - SPR-2015-06510

    call bdbsr018_busca_op() #- Captura valor OP Porto Socorro

    call bdbsr018_descr_etapa_atd() #- Captura descricao da etapa de atendimento

    call bdbsr018_dados_venda()  #- Busca dados da venda  ##-- SPR-2014-28503 

    #--- Flag Visita Tecnica
    if mr_servicos.tecvtaflg is null then  #-- SPR-2014-28503
       let mr_servicos.tecvtaflg = "N"
    end if

    #- SPR-2015-06510
    #- Vlr Pago Prestador = Valor Inicial + (Quantidade -1)* Valor Adicional
    let mr_servicos.vl_pgtprest = mr_servicos.prssrvvlr 
                              + ((mr_servicos.vndsrvqtd -1 )
                              *   mr_servicos.prsmulsrvvlr )
    
    call bdbsr018_busca_propostasrv()  #- Captura Proposta do Servico

    if mr_servicos.pgtfrmcod_vnd  = 1 then #-- '1'= Pagto Cartao Credito
       call bdbsr018_dados_cartao() #- Busca dados do cartao credito
    end if

    let l_c24endtip = 7 #-- Tp Endereco - '7'= Endereco Correspondencia
    
    call bdbsr018_busca_endereco(l_c24endtip)  #- Busca endereco
         returning mr_servicos.lgdtip_corr
                  ,mr_servicos.lgdnom_corr       
                  ,mr_servicos.lgdnum_corr       
                  ,mr_servicos.brrnom_corr    
                  ,mr_servicos.cidnom_corr       
                  ,mr_servicos.ufdcod_corr       
                  ,mr_servicos.endereco_corr
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #-- SPR-2015-06510  
                  ,l_lixo    #- SPR-2015-22413
                  ,l_lixo    #- SPR-2015-22413 


    call bdbsr018_busca_pontos()

    call bdbsr018_descr_pagtovnd()   #- Descricao da Forma de Pagto da Venda

    #=> SPR-2015-13708: BUSCA JUSTIFICATIVAS DO DESCONTO INFORMADO
    call bdbsr018_justif_desc()

    if mr_servicos.cgccpfnum is not null then
       call bdbsr018_ultima_compra() #- Captura Data Ultima Compra
    end if

    call bdbsr018_descr_etapa_fech() #- Captura Descricao da Etapa Fechamento

    if m_tp_relat = "F" then #-- Tipo Relatorio 'Fechamento' - SPR-2015-22413
       call bdbsr018_adc_prestador() #- Captura Pagamentos adcionais Prestador 
    end if
    
    output to report bdbsr018_relatorio()

    if m_tp_proc = "M" then  
       if bdbsr018_busca_apolice() then  #-- Tipo Proc 'Mensal' - SPR-2016-03565
         output to report bdbsr018_relat_apl()
       end if
    end if
    
    let m_impressos = m_impressos + 1

    initialize mr_servicos.* to null
 end foreach

 return
 
end function   #--- bdbsr018_gera()

#-----------------------------------------#
function bdbsr018_busca_acionamento()
#-----------------------------------------#
 #VERIFICANDO SE É ACIONAMENTO AUTOMATICO
 if mr_servicos.funmat = "999999" then
    let mr_servicos.acionamentoAut = "Sim"
 else
    let mr_servicos.acionamentoAut = "Não"
 end if

 return
 
end function   #--- bdbsr018_busca_acionamento()

#-----------------------------------------#
function bdbsr018_descr_assunto()
#-----------------------------------------#
 if mr_servicos.c24astcod <> 'PSP' then
    #--- Tab datkassunto - Pesq cadastro de assuntos central 24hs
    open cbdbsr018002 using mr_servicos.c24astcod
    fetch cbdbsr018002 into mr_servicos.c24astdes

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          display "Erro SELECT cbdbsr018002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          exit program(1)
       end if
    end if
 else
     let mr_servicos.c24astdes = 'ASSUNTO NÃO CADASTRADO'
 end if

 return
 
end function   #--- bdbsr018_descr_assunto()

#-----------------------------------------#
function bdbsr018_descr_solicitante()
#-----------------------------------------#
 #-- Tab datksoltip - Captura descricao tipo solicitante
 open cbdbsr018014 using mr_servicos.c24soltipcod
 fetch cbdbsr018014 into mr_servicos.c24soltipdes

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018014 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return
 
end function   #--- bdbsr018_descr_solicitante()

#-----------------------------------------#
function bdbsr018_busca_ocorrencia()
#-----------------------------------------#
 #VERIFICANDO SE O SERVIÇO É RE OU AUTO
 if mr_servicos.atdsrvorg = 9 or mr_servicos.atdsrvorg = 13 then
    #-- Tabs datmsrvre e datksocntz - Captura natureza RE
    open cbdbsr018003 using mr_servicos.atdsrvnum
                           ,mr_servicos.atdsrvano
    whenever error continue
    fetch cbdbsr018003 into mr_servicos.socntzcod
                           ,mr_servicos.socntzdes
                           ,mr_servicos.dataocrr
                           ,mr_servicos.socntzgrpcod   #- SPR-2016-03565
                           ,mr_servicos.socntzgrpdes   #- SPR-2016-03565
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          display "Erro SELECT cbdbsr018003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          exit program(1)
       end if
    end if
 else
    #-- Tab datmservicocmp - Captura Data da ocorrencia
    open cbdbsr018009 using mr_servicos.atdsrvnum,
                            mr_servicos.atdsrvano
    whenever error continue
    fetch cbdbsr018009 into mr_servicos.dataocrr

    whenever error stop
    if sqlca.sqlcode <> 0 then
 		  if sqlca.sqlcode <> notfound then
 		     display "Erro SELECT cbdbsr018002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
 		     exit program(1)
 		  end if
    end if
 end if

 return
 
end function   #--- bdbsr018_busca_ocorrencia()

#-----------------------------------------#
function bdbsr018_busca_problema()
#-----------------------------------------#
 #-- Tabs datkpbm e datrsrvpbm - Captura problema e grupo 
 open cbdbsr018004 using mr_servicos.atdsrvnum,
                         mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018004 into mr_servicos.c24pbmcod,
                         mr_servicos.c24pbmdes,
                         mr_servicos.c24pbmgrpcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if
    
 #-- Tab datkpbmgrp - Captura Descricao Grupo de Problema
 open cbdbsr018012 using mr_servicos.c24pbmgrpcod
 whenever error continue
 fetch cbdbsr018012 into mr_servicos.c24pbmgrpdes

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return
 
end function   #--- bdbsr018_busca_problema()

#-----------------------------------------#
function bdbsr018_descr_assistencia()
#-----------------------------------------#
 #-- Tab datkasitip - Captura Descricao do Tipo de Assistencia
 open cbdbsr018011 using mr_servicos.asitipcod
 whenever error continue
 fetch cbdbsr018011 into mr_servicos.asitipdes

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return
 
end function   #--- bdbsr018_descr_assistencia()

#-----------------------------------------#
function bdbsr018_descr_pagto()
#-----------------------------------------#
 #-- Tabs datmpgtinf e datkpgtfrm - Captura cod e descricao forma pagto
 open cbdbsr018006 using mr_servicos.atdsrvnum
    								     ,mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018006 into mr_servicos.pgtfrmcod
                        ,mr_servicos.pgtfrmdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return

end function  #--- bdbsr018_descr_pagto()

#-----------------------------------------#
function bdbsr018_busca_ligacao()
#-----------------------------------------#
 #-- Tabs datmligacao e datrligcgccpf - Captura ligacao por cgc/cpf
 open cbdbsr018007 using mr_servicos.atdsrvnum
                        ,mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018007 into mr_servicos.cgccpfnum
                        ,mr_servicos.cgccpfdig
                        ,mr_servicos.cgcord
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return

end function   #--- bdbsr018_busca_ligacao()


#-----------------------------------------#
function bdbsr018_busca_pontos()
#-----------------------------------------#
 #-- Tab datkfdlpgm  - Captura Nome do Programa de Fidelidade
 open cbdbsr018033 using mr_servicos.fdlpgmcod

 whenever error continue
 fetch cbdbsr018033 into mr_servicos.fdlpgmnom

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018033 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return

end function   #--- bdbsr018_busca_pontos()


#-----------------------------------------#
function bdbsr018_nome_prestador()
#-----------------------------------------#
 #--- Tab dpaksocor - Captura o nome do prestador - SPR-2015-06510
 open cbdbsr018023 using mr_servicos.atdprscod
 whenever error continue
 fetch cbdbsr018023 into mr_servicos.rspnom
                        ,mr_servicos.nomgrr  #- SPR-2016-03565

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       display "Nome do prestador nao encontrado - atdprscod = ",mr_servicos.atdprscod 
       let mr_servicos.rspnom = null
    else
      display "Erro SELECT cbdbsr018023 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
	      exit program(1)
    end if
 end if

 return
 
end function   #--- bdbsr018_nome_prestador()

#-----------------------------------------#
function bdbsr018_nome_socorrista()
#-----------------------------------------#
 #--- Tab datksrr - Captura o nome do socorrista - SPR-2015-06510
 open cbdbsr018024 using mr_servicos.srrcoddig
 whenever error continue
 fetch cbdbsr018024 into mr_servicos.srrnom

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       display "Nome do socorrista nao encontrado - srrcoddig = ",mr_servicos.srrcoddig 
       let mr_servicos.srrnom = null
    else
      display "Erro SELECT cbdbsr018024 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
	      exit program(1)
    end if
 end if

 return
 
end function   #--- bdbsr018_nome_socorrista

#-----------------------------------------#
function bdbsr018_busca_cliente()
#-----------------------------------------#
 #--- Tab datksrvcli - Captura o nome do cliente - SPR-2015-06510
 open cbdbsr018025 using mr_servicos.cgccpfnum
                        ,mr_servicos.cgcord
                        ,mr_servicos.cgccpfdig
 whenever error continue 
 fetch cbdbsr018025 into mr_servicos.clinom
                        ,mr_servicos.pestipcod
 
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       display "Nome do cliente nao encontrado - cgccpfnum = "
               ,mr_servicos.cgccpfnum ,mr_servicos.cgccpfdig ,mr_servicos.cgcord
       let mr_servicos.clinom = null
    else
      display "Erro SELECT cbdbsr018025 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
	      exit program(1)
    end if
 end if

 return

end function   #--- bdbsr018_busca_cliente()

#-----------------------------------------#
function bdbsr018_busca_op()
#-----------------------------------------#
 #-- Tabs dbsmopg e dbsmopgitm - Captura valor OP Porto Socorro
 open cbdbsr018008 using mr_servicos.atdsrvnum,
                         mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018008 into mr_servicos.socopgitmvlr

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if
 
 if mr_servicos.socopgitmvlr is null then
 	  let mr_servicos.socopgitmvlr = 0
 end if
 
 return

end function   #--- bdbsr018_busca_op()

#-----------------------------------------#
function bdbsr018_descr_etapa_atd()
#-----------------------------------------#
 #-- Tab datketapa - Captura descricao da etapa de atendimento
 open cbdbsr018010 using mr_servicos.atdetpcod
 whenever error continue
 fetch cbdbsr018010 into mr_servicos.atdetpdes

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return

end function   #--- bdbsr018_descr_etapa_atd()

#-----------------------------------------#
function bdbsr018_dados_venda()
#-----------------------------------------#
 #-- Tab datmsrvvnd, datksrvcat, datkcliprf e datknovsrvdsccup - Dados da venda #- SPR-2015-17043 
 open cbdbsr018015 using mr_servicos.atdsrvnum
                        ,mr_servicos.atdsrvano
                        ,mr_servicos.atddat          #=> SPR-2015-13708
 whenever error continue
 fetch cbdbsr018015 into mr_servicos.catcod
                        ,mr_servicos.catnom
                        ,mr_servicos.pgtfrmcod_vnd
                        ,mr_servicos.vndsrvqtd
                        ,mr_servicos.clitipcod
                        ,mr_servicos.dsccupidecod
                        ,mr_servicos.srvvnddscvlr
                        ,mr_servicos.srvvndacrvlr
                        ,mr_servicos.srvvndtotvlr
                        ,mr_servicos.srvvndparqtd
                        ,mr_servicos.email
                        ,mr_servicos.clitipnom
                        ,mr_servicos.dscnom
                        ,mr_servicos.srvinccbrvlr
                        ,mr_servicos.cbrsrvadcvlr
                        ,mr_servicos.tecvtaflg 
                        ,mr_servicos.catagpcod   #-- SPR-2015-06510  
                        ,mr_servicos.catagpnom   #-- SPR-2015-06510  
                        ,mr_servicos.ftmvlr      #-- SPR-2015-06510  
                        ,mr_servicos.prspgovlr   #-- SPR-2015-06510 
                        ,mr_servicos.infdscper       #=> SPR-2015-13708
                        ,mr_servicos.infacrvlr       #=> SPR-2015-13708
                        ,mr_servicos.prsmulsrvvlr #- SPR-2015-06510-2
                        ,mr_servicos.prssrvvlr    #- SPR-2015-06510-2
                        
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       display "Erro SELECT cbdbsr018015 / ", sqlca.sqlcode,
               "/", sqlca.sqlerrd[2]
       exit program(1)
    else  #--- notfound
       initialize mr_servicos.catcod   #-- SPR-2015-06510    
                 ,mr_servicos.catnom       
                 ,mr_servicos.pgtfrmcod_vnd
                 ,mr_servicos.vndsrvqtd    
                 ,mr_servicos.clitipcod    
                 ,mr_servicos.dsccupidecod 
                 ,mr_servicos.srvvnddscvlr 
                 ,mr_servicos.srvvndacrvlr 
                 ,mr_servicos.srvvndtotvlr 
                 ,mr_servicos.srvvndparqtd 
                 ,mr_servicos.email        
                 ,mr_servicos.clitipnom    
                 ,mr_servicos.dscnom       
                 ,mr_servicos.srvinccbrvlr 
                 ,mr_servicos.cbrsrvadcvlr 
                 ,mr_servicos.tecvtaflg    
                 ,mr_servicos.catagpcod 
                 ,mr_servicos.catagpnom 
                 ,mr_servicos.ftmvlr
                 ,mr_servicos.prspgovlr
                 ,mr_servicos.infdscper       #=> SPR-2015-13708
                 ,mr_servicos.infdscvlr       #=> SPR-2015-13708
                 ,mr_servicos.infacrvlr       #=> SPR-2015-13708
                 ,mr_servicos.prsmulsrvvlr #-- SPR-2015-06510-2
                 ,mr_servicos.prssrvvlr    to null
    end if
 else
    let mr_servicos.infdscvlr = mr_servicos.srvinccbrvlr * mr_servicos.infdscper
                                                        / 100
 end if

 if m_tp_relat = "F" then #-- Tipo Relatorio 'Fechamento'  #-- SPR-2015-06510
    #--- Tab isskfunc - Captura Matricula do Operador do fechamento
    let mr_servicos.funnom_fch = bdbsr018_func(mr_servicos.cadempcod
                                              ,mr_servicos.cadmatnum)

    #--- Tab datkjsttip - Captura Codigo do Tipo do motivo justificativa
    open cbdbsr018029 using  mr_servicos.atdsrvnum
                            ,mr_servicos.atdsrvano
    whenever error continue
    fetch cbdbsr018029 into mr_servicos.jsttipcod 
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          display "Cod. do Tipo Motivo da Justif. nao encontrada - Servico = ",
                  mr_servicos.atdsrvnum, "-", mr_servicos.atdsrvano
          let mr_servicos.jsttipcod = null
       else
	     display "Erro SELECT cbdbsr018029 / ", sqlca.sqlcode, 
                  "/", sqlca.sqlerrd[2]
	     exit program(1)
       end if
    end if 

    if mr_servicos.jsttipcod     = 4              and
       date(mr_servicos.caddat)  <= "20/05/2015"  then
       let mr_servicos.jstnom = null 
    else
       #--- Tab datkjsttip - Captura motivo justificativa
       open cbdbsr018027 using  mr_servicos.jsttipcod       
       whenever error continue
       fetch cbdbsr018027 into mr_servicos.jstnom 
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             display "Motivo Justificativa nao encontrada - vndepacod = ",
                     mr_servicos.vndepacod," Servico = ",mr_servicos.atdsrvnum, 
                     "-", mr_servicos.atdsrvano 
             let mr_servicos.jstnom = null
          else
	           display "Erro SELECT cbdbsr018027 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
	            exit program(1)
          end if
       end if
     end if
 else    #-- Tipo Relatorio 'Venda'  #-- SPR-2015-06510
    let mr_servicos.ftmvlr     = null  #-- Valor Faturado
    let mr_servicos.prspgovlr  = null  #-- #Total Pago Prestador
    let mr_servicos.cadmatnum  = null  #-- Matricula operador fechamento
    let mr_servicos.funnom_fch = null  #-- Nome operador fechamento
    let mr_servicos.caddat     = null  #-- Data Fechamento
    let mr_servicos.vndepacod  = null  #-- Etapa do fechamento
    let mr_servicos.vndepanom  = null  #-- Descr Etapa do Fechamento
    let mr_servicos.jstnom     = null  #-- Motivo justificativa
 end if

 return
 
end function   #--- bdbsr018_dados_venda()

#-----------------------------------------#
function bdbsr018_busca_propostasrv()
#-----------------------------------------#
 #-- Tabs datmpgtinf e datmcrdcrtinf - Captura Proposta do Servico
 open   cbdbsr018019 using mr_servicos.atdsrvnum
                          ,mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018019 into mr_servicos.prpnum

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       display "Erro SELECT cbdbsr018019 / ", sqlca.sqlcode,
               "/", sqlca.sqlerrd[2]
       exit program(1)
    else
       let mr_servicos.prpnum = null
    end if
 end if

 return
 
end function   #--- bdbsr018_busca_propostasrv()

#-----------------------------------------#
function bdbsr018_dados_cartao()
#-----------------------------------------#
 define lr_retcrip      record
         coderro        smallint
        ,msgerro        char(10000)
        ,pcapticrpcod   like fcomcaraut.pcapticrpcod
 end record
 define l_crtnumband    char(1)

 initialize lr_retcrip to null
 initialize l_crtnumband to null

 let mr_servicos.orgnum     = 29
 
 #-- Tab datmcrdcrtinf - Captura numero do cartao de crédito 
 open   cbdbsr018020 using mr_servicos.orgnum
                          ,mr_servicos.prpnum
                          ,mr_servicos.orgnum
                          ,mr_servicos.prpnum
 whenever error continue
 fetch cbdbsr018020 into mr_servicos.crtnum

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       display "Erro SELECT cbdbsr018020 / ", sqlca.sqlcode,
               "/", sqlca.sqlerrd[2]
       exit program(1)
    else
       let  mr_servicos.clinom = null
    end if
 end if

 if mr_servicos.crtnum is not null or
    mr_servicos.crtnum <> 0        then

    #- Descriptografa o numero do cartao  e
    #- Busca Bandeira  do cartao

    call ffctc890("D",mr_servicos.crtnum )
              returning lr_retcrip.*

    let l_crtnumband = lr_retcrip.pcapticrpcod[01,01]

    if l_crtnumband = "5" then
       let mr_servicos.clinom_band  = "Master"
    end if
    if l_crtnumband = "4" then
       let mr_servicos.clinom_band = "Visa"
    end if
 end if
 
 return

end function   #--- bdbsr018_dados_cartao()

#-----------------------------------------#
function bdbsr018_busca_endereco(l_c24endtip)
#-----------------------------------------#
 define l_c24endtip   like datmlcl.c24endtip

 define l_datmlcl     record
     lgdtip           like datmlcl.lgdtip
    ,lgdnom           like datmlcl.lgdnom
    ,lgdnum           like datmlcl.lgdnum
    ,brrnom        like datmlcl.brrnom
    ,cidnom           like datmlcl.cidnom
    ,ufdcod           like datmlcl.ufdcod
    ,lclltt           like datmlcl.lclltt
    ,lcllgt           like datmlcl.lcllgt  
   ## ,cmlteldddcod     like datmlcl.cmlteldddcod     #- SPR-2015-06510
   ## ,cmltelnum        like datmlcl.cmltelnum        #- SPR-2015-06510
    ,dddcod           like datmlcl.dddcod           #- SPR-2015-06510-2
    ,lcltelnum        like datmlcl.lcltelnum        #- SPR-2015-06510-2
    ,celteldddcod     like datmlcl.celteldddcod     #- SPR-2015-06510
    ,celtelnum        like datmlcl.celtelnum        #- SPR-2015-06510
    ,endereco         char(1000)                    #- SPR-2015-06510
    ,lgdcep           like datmlcl.lgdcep           #- SPR-2015-22413
    ,lgdcepcmp        like datmlcl.lgdcepcmp         #- SPR-2015-22413
 end record

 initialize l_datmlcl to null
 
 #-- Tab datmlcl - Localizacao de atendimento 
 open cbdbsr018005 using mr_servicos.atdsrvnum
                        ,mr_servicos.atdsrvano
                        ,l_c24endtip #-- Tp Endereco / 1=Ocorrencia  7 = Correspondencia
 
 whenever error continue
 fetch cbdbsr018005 into l_datmlcl.lgdtip
                        ,l_datmlcl.lgdnom
                        ,l_datmlcl.lgdnum
                        ,l_datmlcl.brrnom
                        ,l_datmlcl.cidnom
                        ,l_datmlcl.ufdcod
                        ,l_datmlcl.lclltt
                        ,l_datmlcl.lcllgt
                      ##  ,l_datmlcl.cmlteldddcod   #-- SPR-2015-06510
                      ##  ,l_datmlcl.cmltelnum      #-- SPR-2015-06510
                        ,l_datmlcl.dddcod           #-- SPR-2015-06510-2
                        ,l_datmlcl.lcltelnum        #-- SPR-2015-06510-2
                        ,l_datmlcl.celteldddcod     #-- SPR-2015-06510
                        ,l_datmlcl.celtelnum        #-- SPR-2015-06510
                        ,l_datmlcl.lgdcep           #- SPR-2015-22413 
                        ,l_datmlcl.lgdcepcmp        #- SPR-2015-22413

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 let l_datmlcl.endereco = l_datmlcl.lgdtip clipped, " "
                         ,l_datmlcl.lgdnom clipped, ", "
                         ,l_datmlcl.lgdnum clipped

 return l_datmlcl.lgdtip       
       ,l_datmlcl.lgdnom       
       ,l_datmlcl.lgdnum       
       ,l_datmlcl.brrnom    
       ,l_datmlcl.cidnom       
       ,l_datmlcl.ufdcod       
       ,l_datmlcl.endereco
       ,l_datmlcl.lclltt       
       ,l_datmlcl.lcllgt       
      ## ,l_datmlcl.cmlteldddcod 
      ## ,l_datmlcl.cmltelnum  
       ,l_datmlcl.dddcod              ##-- SPR-2015-06510-2
       ,l_datmlcl.lcltelnum           ##-- SPR-2015-06510-2 
       ,l_datmlcl.celteldddcod 
       ,l_datmlcl.celtelnum
       ,l_datmlcl.lgdcep      #- SPR-2015-22413 
       ,l_datmlcl.lgdcepcmp   #- SPR-2015-22413

end function   #--- bdbsr018_busca_endereco()

#-----------------------------------------#
function bdbsr018_descr_pagtovnd()
#-----------------------------------------#
 define l_cpodes        like iddkdominio.cpodes

 let l_cpodes   = null

 
 #-- Tab iddkdominio - Captura Descricao da Forma de Pagto de Venda
 open cbdbsr018021 using mr_servicos.pgtfrmcod_vnd
 whenever error continue
 fetch cbdbsr018021 into l_cpodes

 whenever error stop
 if sqlca.sqlcode <> 0  then
    if sqlca.sqlcode <> 100 then
       display "Erro SELECT cbdbsr018021 / ", sqlca.sqlcode,
               "/", sqlca.sqlerrd[2]
       exit program(1)
    else
       let mr_servicos.pgtfrmdes = null
    end if
 end if
 
 if mr_servicos.pgtfrmcod_vnd  =  4 then 
    let mr_servicos.pgtfrmdes_vnd = "VOUCHER 100%"
 else 
   let mr_servicos.pgtfrmdes_vnd = l_cpodes[01,20]
 end if
 
 ##let mr_servicos.pgtfrmdes_vnd = l_cpodes[01,20]

 return
 
end function   #--- bdbsr018_descr_pagtovnd()


#=> SPR-2015-13708: BUSCA JUSTIFICATIVAS DO DESCONTO INFORMADO
#-----------------------------------------#
function bdbsr018_justif_desc()
#-----------------------------------------#
   define lr_reg         record
          jsttxt         like datrjstlog.jsttxt,
          cadmatnum      like datrjstlog.cadmatnum,
          cadempcod      like datrjstlog.cadempcod
   end record
   define l_jsttipcod    smallint

   for l_jsttipcod = 1 to 2 #=> 1=DESC.OPERADOR / 2=DESC.SUPERVISOR

      ##-- Tab datrjstlog - BUSCA JUSTIFICATIVA
      open cbdbsr018022 using mr_servicos.atdsrvnum
                             ,mr_servicos.atdsrvano
                             ,l_jsttipcod
      fetch cbdbsr018022 into lr_reg.*

      if l_jsttipcod = 1    then
         if sqlca.sqlcode <> 0 then
            let mr_servicos.jsttxt_opr = null
         else
            let mr_servicos.jsttxt_opr = lr_reg.jsttxt
         end if
      else
         if sqlca.sqlcode <> 0 then
            let mr_servicos.flglibsuperv = null
            let mr_servicos.funnom_sup = null
            let mr_servicos.funmat_sup = null
            let mr_servicos.jsttxt_sup = null
         else
            let mr_servicos.flglibsuperv = "S"
            let mr_servicos.funmat_sup = lr_reg.cadmatnum
            let mr_servicos.jsttxt_sup = lr_reg.jsttxt
            open  cbdbsr018026 using lr_reg.cadempcod
                                    ,lr_reg.cadmatnum
            fetch cbdbsr018026  into mr_servicos.funnom_sup
            if sqlca.sqlcode = notfound then
               let mr_servicos.funnom_sup = "NAO CADASTRADO"
            end if
         end if
      end if
   end for

   return

end function   #--- bdbsr018_justif_desc()


#-----------------------------------------#
function bdbsr018_ultima_compra()
#-----------------------------------------#
 #-- Tabs datmservico, datmligacao e datrligcgccpf - Captura Data Ultima Compra
 open cbdbsr018013 using mr_servicos.cgccpfnum
                        ,mr_servicos.cgcord
                        ,mr_servicos.cgccpfdig
 whenever error continue
 fetch cbdbsr018013 into mr_servicos.ultdatcpf
  
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018013 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if
 close cbdbsr018013

 return

end function   #--- bdbsr018_ultima_compra()

#-----------------------------------------#
function bdbsr018_descr_etapa_fech()
#-----------------------------------------#
 #-- Tab datkvndepatip - Captura descricao da etapa de fechamento
 open cbdbsr018028 using mr_servicos.vndepacod
 whenever error continue
 fetch cbdbsr018028 into mr_servicos.vndepanom

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       display "Erro SELECT cbdbsr018028 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
       exit program(1)
    end if
 end if

 return

end function   #--- bdbsr018_descr_etapa_fech()

#-----------------------------------------#
function bdbsr018_adc_prestador()
#-----------------------------------------#
 let mr_servicos.atdhordat    = null
 let mr_servicos.nteadcvlr	  = 0
 let mr_servicos.louadcvlr	  = 0
 let mr_servicos.avnadcvlr	  = 0
 let mr_servicos.pdahorqtd	  = 0
 let mr_servicos.pdahoradcvlr	= 0
 let mr_servicos.tblhoradcvlr	= 0
 let mr_servicos.tblhorqtd	  = 0
 let mr_servicos.tblhoradcvlr	= 0
 let mr_servicos.pcrkmsqtd	  = 0
 let mr_servicos.qlmadcvlr	  = 0
 let mr_servicos.infacrvlrprt = 0

 #--- Tab datkvndfec - Captura valores adcionais pagos ao prestador
 open cbdbsr018030 using mr_servicos.atdsrvnum
                        ,mr_servicos.atdsrvano
 whenever error continue
 fetch cbdbsr018030 into mr_servicos.atdhordat    
                        ,mr_servicos.nteadcvlr	  
                        ,mr_servicos.louadcvlr	  
                        ,mr_servicos.avnadcvlr	  
                        ,mr_servicos.pdahorqtd	  
                        ,mr_servicos.pdahoradcvlr	
                        ,mr_servicos.tblhoradcvlr	
                        ,mr_servicos.tblhorqtd	      
                        ,mr_servicos.tblhoradcvlr	
                        ,mr_servicos.pcrkmsqtd	  
                        ,mr_servicos.qlmadcvlr	  
                        ,mr_servicos.infacrvlrprt

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       display "Erro SELECT cbdbsr018030 / ", sqlca.sqlcode,
               "/", sqlca.sqlerrd[2]
       exit program(1)
    else
       let mr_servicos.atdhordat    = null
       let mr_servicos.nteadcvlr	  = 0
       let mr_servicos.louadcvlr	  = 0
       let mr_servicos.avnadcvlr	  = 0
       let mr_servicos.pdahorqtd	  = 0
       let mr_servicos.pdahoradcvlr	= 0
       let mr_servicos.tblhoradcvlr	= 0
       let mr_servicos.tblhorqtd	  = 0
       let mr_servicos.tblhoradcvlr	= 0
       let mr_servicos.pcrkmsqtd	  = 0
       let mr_servicos.qlmadcvlr	  = 0
       let mr_servicos.infacrvlrprt = 0
    end if
 end if

 return
 
end function   #--- bdbsr018_adc_prestador()


#-----------------------------------------#
function bdbsr018_busca_apolice()
#-----------------------------------------#
#--- SPR-2016-03565 - Vendas e Parcerias 
 define l_coderro   smallint
 
 initialize l_coderro to null
 
 let l_coderro = true
 
 
#--- Tab abbmapldctsgm - Pesq dados da apolice
 open cbdbsr018032 using mr_servicos.cgccpfnum
                        ,mr_servicos.cgcord
                        ,mr_servicos.cgccpfdig
                        
                        
 whenever error continue
 fetch cbdbsr018032 into mr_apolice.aplnumdig    
                        ,mr_apolice.itmnumdig 


 whenever error stop
 if sqlca.sqlcode <> 0 then
 	  if sqlca.sqlcode = 100 then
 			 let l_coderro = false
 	  	 return l_coderro
 	  end if 	 
    display "Erro cursor cbdbsr018032 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
    exit program(1)
 end if
 
 
 #--- Tabs datrservapol e abbmveic - Pesq dados da apolice
 open cbdbsr018031 using mr_apolice.aplnumdig
                        ,mr_apolice.itmnumdig
 
 whenever error continue
 fetch cbdbsr018031 into mr_apolice.succod    
                        ,mr_apolice.aplnumdig 
                        ,mr_apolice.itmnumdig 
                        ,mr_apolice.vcllicnum 

 whenever error stop
 if sqlca.sqlcode <> 0 then
 	  if sqlca.sqlcode = 100 then
 			 let l_coderro = false
 	  	 return l_coderro
 	  end if 	 
    display "Erro cursor cbdbsr018031 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
    exit program(1)
 end if

 return l_coderro

end function   #--- bdbsr018_busca_apolice()

#-----------------------------------------#
function bdbsr018_busca_path()
#-----------------------------------------#
 define l_dia       char(02)
       ,l_mes       char(02)
       ,l_ano       char(04)
       ,l_arquivo   char(50)
       ,l_tp_relat  char(06)
       ,l_tp_proc   char(06)

 # ---> INICIALIZACAO DAS VARIAVEIS
 let m_path = null
 let l_dia  = null
 let l_mes  = null
 let l_ano  = null

 # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
 let m_path = f_path("SAPS","LOG")
 
 if m_path is null then
    let m_path = "."
 end if

 let m_path = m_path clipped,"/bdbsr018.log"

 #--- Gera Log de Execucao
 call startlog(m_path)

 # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
 let m_path = f_path("SAPS", "RELATO")  
 let m_path_apl = f_path("SAPS", "RELATO")  

 if m_path is null then
    let m_path = "."
    let m_path_apl = "."
 end if

 if m_tp_proc = "M" then  #--- Tipo de Processamento 'Mensal'
    let l_tp_proc = "MENSAL"
 else
    let l_tp_proc = "DIARIO"
 end if
 if m_tp_relat = "F" then #--- Tipo de Relatorio 'Fechamento'
    let l_tp_relat = "FCH"
 else
    let l_tp_relat = "VND" 
 end if
 
 let l_dia = day(m_data_inicio)
 let l_mes = month(m_data_inicio)clipped
 let l_ano = year(m_data_inicio)

 if l_mes < 10 then
     let l_mes = "0", l_mes
 end if

 let m_path = m_path clipped , "/"

 let l_arquivo = l_dia using "&&" clipped
                ,l_mes using "&&" clipped
                ,l_ano clipped
                ,"BDBSR018_"
                ,l_tp_relat clipped
                ,"_"
                ,l_tp_proc clipped 
                ,".xls"

 let m_path = m_path clipped, l_arquivo clipped

#let m_path = l_arquivo clipped  #-@@@ Tirar o comentario para testes na u28     

 if m_tp_proc = "M" then  #-- Tipo Processamento 'Mensal' - SPR-2016-03565
    let m_path_apl = m_path_apl clipped , "/"
    let l_tp_proc = "APOLICES"
    
    let l_arquivo = l_dia using "&&" clipped
                   ,l_mes using "&&" clipped
                   ,l_ano clipped
                   ,"BDBSR018_"
                   ,l_tp_relat clipped
                   ,"_"
                   ,l_tp_proc clipped 
                   ,".xls"

   let m_path_apl =  m_path_apl clipped, l_arquivo clipped  #-@@@ Tirar o comentario para testes na u28
 end if

 return
 
end function

#---------------------------------------------------------
function bdbsr018_func(lr_param) #--- SPR-2015-06510
#---------------------------------------------------------
 
 define lr_param         record
    empcod            like isskfunc.empcod
   ,funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 #--- Tab isskfunc - Captura o nome do funcionario - SPR-2015-06510
 open cbdbsr018026 using lr_param.empcod
                        ,lr_param.funmat
 fetch cbdbsr018026 into ws.funnom

 if sqlca.sqlcode = notfound then
    let ws.funnom = null
 end if
 
 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  bdbsr018_func

#-----------------------------------------#
function bdbsr018_envia_email(lr_parametro)
#-----------------------------------------#
 
 define lr_parametro record
        data_inicial date
       ,data_final   date
 end record

 define l_assunto     char(100)
       ,l_erro_envio  integer
       ,l_comando     char(200)
       ,l_comando2    char(200)

 # ---> INICIALIZACAO DAS VARIAVEIS
 let l_comando    = null
 let l_comando2    = null
 let l_erro_envio = null
 let l_assunto    = "Servicos SAPS do periodo: ",
                    lr_parametro.data_inicial using "dd/mm/yyyy",
                    " a ",
                    lr_parametro.data_final using "dd/mm/yyyy"
 
 # ---> COMPACTA O ARQUIVO DO RELATORIO
 let l_comando = "gzip -f ", m_path
 let l_comando2 = "gzip -f ", m_path_apl  #--- SPR-2016-03565

 run l_comando
 let m_path     = m_path clipped, ".gz"
 
 run l_comando2
 let m_path_apl = m_path_apl clipped, ".gz"  #--- SPR-2016-03565
   
 display "m_path - ", m_path
 display "m_path_apl - ", m_path_apl   #--- SPR-2016-03565

 let l_erro_envio = ctx22g00_envia_email("BDBSR018", l_assunto, m_path)

 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",m_path
    else
       display "Nao existe email cadastrado para o modulo - BDBSR018"
    end if
 end if

 if m_tp_proc <> "M" then #-  'M'=Tipo Proces Mensal - SPR-2016-03565
    return
 end if
 
 let l_assunto = "Servicos por Apolices do periodo: ",
                 lr_parametro.data_inicial using "dd/mm/yyyy",
                 " a ",
                 lr_parametro.data_final using "dd/mm/yyyy"
 
 
 let l_erro_envio = ctx22g00_envia_email("BDBSR018", l_assunto, m_path_apl)
 
 if l_erro_envio <> 0 then   #--- SPR-2016-03565
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) Apl - ",m_path_apl   
    else
       display "Nao existe email cadastrado para o modulo - BDBSR018 Apl"
    end if
 end if

 return

end function

#-----------------------------------------#
report bdbsr018_relatorio()
#-----------------------------------------#
 define l_vlrparc   like datmsrvvnd.srvvndtotvlr     ##-- SPR-2014-28503

 #- SPR-2015-22413 - Ação Promocional Black Friday
 define l_dt_exec      date
 define l_hr_exec      datetime hour to minute

 define l_dt_agenda    date
 define l_hr_agenda    datetime hour to minute
 define l_dt_fecha     date
 define l_hr_fecha     datetime hour to minute

 define l_louadcflg    char(1)
 define l_avnadcflg    char(1)
 define l_pdahoradcflg char(1)
 define l_tblhoradcflg char(1)
 define l_qlmadcflg    char(1)
 define l_cep_cmp      char(9)  
 define l_srv_imed_flg char(3)  #- SPR-2016-03565
 define l_pgm_pontos   char(35) #- SPR-2016-03565

 output
    left   margin    00
    right  margin    00
    top    margin    00
    bottom margin    00
    page   length    02

 format
    first page header

    print "Assunto"                                ,ascii(09)
         ,"Descrição Assunto"                      ,ascii(09)
         ,"Número do Serviço"                      ,ascii(09)
         ,"Ano do Serviço"                         ,ascii(09)
         ,"Matricula Operador da Venda"		         ,ascii(09)  #- SPR-2014-06510
         ,"Operador da Venda"                      ,ascii(09)  #- SPR-2014-06510
         ,"Data do Atendimento"                    ,ascii(09)
         ,"Hora do Atendimento"                    ,ascii(09)
         ,"Data Agendada"                          ,ascii(09)
         ,"Hora Agendada"                          ,ascii(09)
         ,"Data da Ocorrência"                     ,ascii(09)
         ,"Matricula Operador do Fechamento"       ,ascii(09)  #- SPR-2014-06510
         ,"Operador do Fechamento"      	         ,ascii(09)  #- SPR-2014-06510
         ,"Data de Fechamento"          	         ,ascii(09)  #- SPR-2014-06510
         ,"Hora de Fechamento"     	               ,ascii(09)  #- SPR-2014-06510
         ,"Código do Tipo de Solicitante"          ,ascii(09)
         ,"Descrição do Tipo de Solicitante"       ,ascii(09)
         ,"Código do Prestador"                    ,ascii(09)
         ,"Nome do Prestador"           	         ,ascii(09)  #- SPR-2014-06510
         ,"Codigo do Socorrista"                   ,ascii(09)  #- SPR-2014-06510
         ,"Nome do Socorrista"          	         ,ascii(09)  #- SPR-2014-06510
         ,"Código da Etapa"                        ,ascii(09)
         ,"Descrição da Etapa"                     ,ascii(09)
         ,"Data Acionamento"	                     ,ascii(09)  #- SPR-2015-22413
         ,"Hora Acionamento"                       ,ascii(09)	 #- SPR-2015-22413
         ,"Matricula do Operador da etapa de acionamento"      
                                                   ,ascii(09)	 #- SPR-2015-22413
         ,"Operador do acionamento"                ,ascii(09)  #- SPR-2015-22413
         ,"Acionamento Automático"                 ,ascii(09)
         ,"Código da Natureza"                     ,ascii(09)
         ,"Descrição da Natureza"                  ,ascii(09)
         ,"Código do Grupo de Problema"            ,ascii(09)
         ,"Descrição do Grupo de Problema"         ,ascii(09)
         ,"Código do Problema"                     ,ascii(09)
         ,"Descrição do Problema"                  ,ascii(09)
         ,"Código do Tipo de Assistência"          ,ascii(09)
         ,"Descrição do Tipo de Assistência"       ,ascii(09)
         ,"Endereço de Ocorrencia"                 ,ascii(09)  #- SPR-2014-28503
         ,"Bairro de Ocorrencia"                   ,ascii(09)  #- SPR-2014-28503
         ,"Cidade de Ocorrencia"                   ,ascii(09)  #- SPR-2014-28503
         ,"UFD de Ocorrencia"                      ,ascii(09)  #- SPR-2014-28503
         ,"CEP de Ocorrencia"                      ,ascii(09)  #- SPR-2015-22413
         ,"Latitude"                               ,ascii(09)
         ,"Longitude"                              ,ascii(09)
         ,"Endereço correspondência"               ,ascii(09)  #- SPR-2014-28503
         ,"Bairro   correspondência"               ,ascii(09)  #- SPR-2014-28503
         ,"Cidade   correspondência"               ,ascii(09)  #- SPR-2014-28503
         ,"UF       correspondência"               ,ascii(09)  #- SPR-2014-28503
         ,"Nome do Cliente"    	                   ,ascii(09)  #- SPR-2015-06510
         ,"Tipo Pessoa"                  	         ,ascii(09)  #- SPR-2015-06510
         ,"Número CGC/CPF"                         ,ascii(09)
         ,"Número da Ordem do CGC"                 ,ascii(09)
         ,"Dígito CGC/CPF"                         ,ascii(09)
         ,"Data Última Compra CGC/CPF"             ,ascii(09)
         ,"Valor do Item da OP"                    ,ascii(09)
         ,"Perfil do cliente"                      ,ascii(09)  #- SPR-2014-28503
         ,"Descrição do perfil"                    ,ascii(09)  #- SPR-2014-28503
         ,"Código de Grupo SKU"    	               ,ascii(09)  #- SPR-2015-06510
         ,"Descrição do Grupo do SKU"    	         ,ascii(09)  #- SPR-2015-06510
         ,"Código de SKU"                          ,ascii(09)  #- SPR-2014-28503
         ,"Descrição do SKU"                       ,ascii(09)  #- SPR-2014-28503
         ,"Flag de visita técnica"                 ,ascii(09)  #- SPR-2014-28503
         ,"Forma de cobrança do SKU"               ,ascii(09)  #- SPR-2014-28503
         ,"Quantidade de serviços vendido"         ,ascii(09)  #- SPR-2014-28503
         ,"Valor inicial"                          ,ascii(09)  #- SPR-2014-28503
         ,"Valor adicional"                        ,ascii(09)  #- SPR-2014-28503
         ,"Voucher"                                ,ascii(09)  #- SPR-2014-28503
         ,"liberação de desconto pelo supervisor " ,ascii(09)  #- SPR-2014-28503
         ,"Descontos"                              ,ascii(09)  #- SPR-2014-28503
         ,"Acréscimos"                             ,ascii(09)  #- SPR-2014-28503
         ,"Total da venda "                        ,ascii(09)  #- SPR-2014-28503
         ,"Valor Faturado"    	                   ,ascii(09)  #- SPR-2015-06510
         ,"Etapa de Fechamento"         	         ,ascii(09)  #- SPR-2015-06510
         ,"Motivos de Fechamento"                  ,ascii(09)  #- SPR-2015-06510
         ,"Parcelas"                               ,ascii(09)  #- SPR-2014-28503
         ,"Valor das parcelas "                    ,ascii(09)  #- SPR-2014-28503
         ,"Código da Forma de Pagamento"           ,ascii(09)  #- SPR-2014-28503
         ,"Descrição da Forma de Pagamento"        ,ascii(09)  #- SPR-2014-28503
         ,"Descrição bandeira do cartão"           ,ascii(09)  #- SPR-2014-28503
         ,"Telefone de Contato"   	               ,ascii(09)  #- SPR-2014-28503
         ,"Celular de Contato"          	         ,ascii(09)  #- SPR-2014-28503
         ,"Email "                                 ,ascii(09)  #- SPR-2014-28503
         ,"Calculo de Pagamento do Prestador"      ,ascii(09)  #- SPR-2015-06510
         ,"Total Pago Prestador"                   ,ascii(09)  #- SPR-2015-06510
         ,"Percentual Informado Desconto"          ,ascii(09) #=> SPR-2015-13708
         ,"Valor Informado Desconto"               ,ascii(09) #=> SPR-2015-13708
         ,"Justificativa do Operador"              ,ascii(09) #=> SPR-2015-13708
         ,"Nome do Supervisor"                     ,ascii(09) #=> SPR-2015-13708
         ,"Matricula do Supervisor"                ,ascii(09) #=> SPR-2015-13708
         ,"Justificativa do Supervisor"            ,ascii(09) #=> SPR-2015-13708
         ,"Data de Execucao do Serviço"            ,ascii(09) #=> SPR-2015-22413
         ,"Hora de Execucao do Serviço"            ,ascii(09) #=> SPR-2015-22413
         ,"Valor Adicional Noturno/Feriado"        ,ascii(09) #=> SPR-2015-22413
         ,"Pagamento Adicional de Louca"           ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional de Louca"          ,ascii(09) #=> SPR-2015-22413
         ,"Pagamento Adicional de Alvenaria"       ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional de Alvenaria"      ,ascii(09) #=> SPR-2015-22413
         ,"Pagamento Adicional hora Parada"        ,ascii(09) #=> SPR-2015-22413
         ,"Quantidade Adicional hora Parada"       ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional hora Parada"       ,ascii(09) #=> SPR-2015-22413
         ,"Pagamento Adicional hora Trabalhada"    ,ascii(09) #=> SPR-2015-22413
         ,"Quantidade Adicional hora Trabalhada"   ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional hora Trabalhada"   ,ascii(09) #=> SPR-2015-22413
         ,"Pagamento Adicional KM"                 ,ascii(09) #=> SPR-2015-22413
         ,"Quantidade Adicional KM"                ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional KM"                ,ascii(09) #=> SPR-2015-22413
         ,"Valor pago Adicional Informado"         ,ascii(09) #=> SPR-2015-22413
         ,"Codigo Grupo Natureza"                  ,ascii(09) #=> SPR-2016-03565
         ,"Descricao Grupo Natureza"               ,ascii(09) #=> SPR-2016-03565
         ,"Servico Imediato"                       ,ascii(09) #=> SPR-2016-03565
         ,"Nome Guerra Prestador"                  ,ascii(09) #=> SPR-2016-03565
         ,"Programa Pontos"                        ,ascii(09) #=> SPR-2016-03565


 on every row
    ##-- SPR-2014-28503 - Inicio
    let l_vlrparc   = 0 
    let l_cep_cmp   = null
    let l_srv_imed_flg = null #- SPR-2016-03565
    let l_pgm_pontos = null #- SPR-2016-03565

    #- SPR-2015-22413 - Ação Promocional Black Friday
    let l_dt_exec   = mr_servicos.atdhordat
    let l_hr_exec   = mr_servicos.atdhordat
    let l_cep_cmp   = mr_servicos.lgdcep using "&&&&&","-"             
                     ,mr_servicos.lgdcepcmp using "&&&"              

    let l_dt_agenda = mr_servicos.srvcbnhor 
    let l_hr_agenda = mr_servicos.srvcbnhor 
    let l_dt_fecha  = mr_servicos.caddat   
    let l_hr_fecha  = mr_servicos.caddat   

    let l_louadcflg = "N"
    if mr_servicos.louadcvlr is not null and
    	 mr_servicos.louadcvlr <> 0 then
       let l_louadcflg = "S"
    end if

    let l_avnadcflg = "N"
    if mr_servicos.avnadcvlr is not null and
    	 mr_servicos.avnadcvlr <> 0 then
    	 let l_avnadcflg = "S"
    end if

    let l_pdahoradcflg = "N"
    if mr_servicos.pdahoradcvlr is not null and
    	 mr_servicos.pdahoradcvlr <> 0 then
    	 let l_pdahoradcflg = "S"
    end if

    let l_tblhoradcflg = "N"
    if mr_servicos.tblhoradcvlr is not null and
    	 mr_servicos.tblhoradcvlr <> 0 then
    	 let l_tblhoradcflg = "S"
    end if
    
    let l_qlmadcflg = "N"
    if mr_servicos.qlmadcvlr is not null and
    	 mr_servicos.qlmadcvlr <> 0 then
    	 let l_qlmadcflg = "S"
    end if
    
    if mr_servicos.srvvndparqtd > 0 then
       let l_vlrparc = mr_servicos.srvvndtotvlr / mr_servicos.srvvndparqtd
    else
       if mr_servicos.srvvndparqtd is null then
          let l_vlrparc = null
       end if
    end if
    ##-- SPR-2014-28503 - Fim    
    
    let l_srv_imed_flg = "Nao"  #- SPR-2016-03565
    if mr_servicos.atddatprg is null or
       mr_servicos.atddatprg = " " then
       let l_srv_imed_flg = "Sim"  #- SPR-2016-03565
    end if
 
    let l_pgm_pontos = mr_servicos.fdlpgmcod, "-"
                      ,mr_servicos.fdlpgmnom clipped
    
    print mr_servicos.c24astcod      ,ascii(09); #Assunto
    print mr_servicos.c24astdes       clipped                
                                     ,ascii(09); #Descrição Assunto
    print mr_servicos.atdsrvnum      ,ascii(09); #Número do Serviço
    print mr_servicos.atdsrvano      ,ascii(09); #Ano do Serviço
    print mr_servicos.funmat_vnd     ,ascii(09); #Matr Venda - SPR-2015-06510
    print mr_servicos.funnom_vnd     ,ascii(09); #Nome Venda - SPR-2015-06510
    print mr_servicos.atddat         ,ascii(09); #Data do Atendimento
    print mr_servicos.atdhor         ,ascii(09); #Hora do Atendimento
    print l_dt_agenda                ,ascii(09); #Data Agendada
    print l_hr_agenda                ,ascii(09); #Hora Agendada
    print mr_servicos.dataocrr       ,ascii(09); #Data da Ocorrência
    print mr_servicos.cadmatnum      ,ascii(09); #Matr Fecham - SPR-2015-06510	
    print mr_servicos.funnom_fch     ,ascii(09); #Nome Fecham - SPR-2015-06510
    print l_dt_fecha                 ,ascii(09); #Data Fechto - SPR-2015-06510
    print l_hr_fecha                 ,ascii(09); #Hora Fechto - SPR-2015-06510
    print mr_servicos.c24soltipcod   ,ascii(09); #Tipo de Solicitante
    print mr_servicos.c24soltipdes    clipped    #Descrição Tipo de Solicitante
                                     ,ascii(09); 
    print mr_servicos.atdprscod      ,ascii(09); #Código do Prestador
    print mr_servicos.rspnom         ,ascii(09); #Nome Prestad - SPR-2015-06510
    print mr_servicos.srrcoddig      ,ascii(09); #Cod Socorrista-SPR-2015-06510
    print mr_servicos.srrnom         ,ascii(09); #Nom Socorrista-SPR-2015-06510
    print mr_servicos.atdetpcod      ,ascii(09); #Código da Etapa
    print mr_servicos.atdetpdes       clipped    #Descrição da Etapa
                                     ,ascii(09);
    print mr_servicos.atdetpdat      ,ascii(09); #Data acionamento-SPR-2015-22413
    print mr_servicos.atdetphor      ,ascii(09); #Hora acionamento-SPR-2015-22413  
    print mr_servicos.funmat         ,ascii(09); #Matricula operador-SPR-2015-22413 
    print mr_servicos.funnom         ,ascii(09); #Operador acionamento-SPR-2015-22413
    print mr_servicos.acionamentoAut ,ascii(09); #Acionamento Automático
    print mr_servicos.socntzcod      ,ascii(09); #Código da Natureza
    print mr_servicos.socntzdes       clipped    #Descrição da Natureza
                                     ,ascii(09);
    print mr_servicos.c24pbmgrpcod   ,ascii(09); #Código do Grupo de Problema
    print mr_servicos.c24pbmgrpdes    clipped    #Descrição Grupo de Problema
                                     ,ascii(09);
    print mr_servicos.c24pbmcod      ,ascii(09); #Código do Problema
    print mr_servicos.c24pbmdes       clipped    #Descrição do Problema
                                     ,ascii(09);
    print mr_servicos.asitipcod      ,ascii(09); #Código do Tipo de Assistência
    print mr_servicos.asitipdes       clipped    #Descrição Tipo de Assistência
                                     ,ascii(09);
    print mr_servicos.endereco        clipped    #Endereço de Ocorrencia
                                     ,ascii(09);
    print mr_servicos.brrnom       clipped    #Bairro de Ocorrencia
                                     ,ascii(09);
    print mr_servicos.cidnom          clipped    #Cidade de Ocorrencia
                                     ,ascii(09);
    print mr_servicos.ufdcod         ,ascii(09); #UFD de Ocorrencia
    print l_cep_cmp                  ,ascii(09); #CEP Ocorrencia # SPR-2015-22413
    print mr_servicos.lclltt         ,ascii(09); #Latitude
    print mr_servicos.lcllgt         ,ascii(09); #Longitude
    print mr_servicos.endereco_corr   clipped    #Endereço correspondência
                                     ,ascii(09);
    print mr_servicos.brrnom_corr ,ascii(09); #Bairro   correspondência
    print mr_servicos.cidnom_corr    ,ascii(09); #Cidade   correspondência
    print mr_servicos.ufdcod_corr    ,ascii(09); #UF       correspondência
    print mr_servicos.clinom         ,ascii(09); #Nome Cliente - SPR-2015-06510
    print mr_servicos.pestipcod      ,ascii(09); #Tipo Pessoa - SPR-2015-06510
    print mr_servicos.cgccpfnum      ,ascii(09); #Número CGC/CPF
    print mr_servicos.cgcord         ,ascii(09); #Número da Ordem do CGC
    print mr_servicos.cgccpfdig      ,ascii(09); #Dígito CGC/CPF
    print mr_servicos.ultdatcpf      ,ascii(09); #Data Última Compra CGC/CPF
    print mr_servicos.socopgitmvlr    using "<<<<<<&.&&" 
                                     ,ascii(09); #Valor do Item da OP 
    print mr_servicos.clitipcod      ,ascii(09); #Perfil do cliente
    print mr_servicos.clitipnom      ,ascii(09); #Descrição do perfil
    print mr_servicos.catagpcod      ,ascii(09); #Cód Grupo SKU -SPR-2015-06510
    print mr_servicos.catagpnom      ,ascii(09); #Des Grupo SKU -SPR-2015-06510
    print mr_servicos.catcod         ,ascii(09); #Código de SKU
    print mr_servicos.catnom         ,ascii(09); #Descrição do SKU
    print mr_servicos.tecvtaflg      ,ascii(09); #Flag de visita técnica
    print mr_servicos.pgtfrmcod      ,ascii(09); #Forma de cobrança do SKU
    print mr_servicos.vndsrvqtd       using "<<&" #Quantidade serviços vendidos
                                     ,ascii(09); #- SPR-2015-17043
    print mr_servicos.srvinccbrvlr   ,ascii(09); #Valor inicial
    print mr_servicos.cbrsrvadcvlr   ,ascii(09); #Valor adicional
    print mr_servicos.dscnom         ,ascii(09); #Voucher
    print mr_servicos.flglibsuperv   ,ascii(09); #Liberação desc supervisor 
    print mr_servicos.srvvnddscvlr    using "<<<<<<<&.&&"
                                     ,ascii(09); #Descontos
    print mr_servicos.infacrvlr       using "<<<<<<<&.&&" 
                                     ,ascii(09); #SPR-2015-13708 Acr Info
    print mr_servicos.srvvndtotvlr    using "<<<<<<<&.&&" 
                                     ,ascii(09); #Total da venda
    print mr_servicos.ftmvlr          using "<<<<<<<&.&&" 
                                     ,ascii(09); #Valor Faturado
    print mr_servicos.vndepanom      ,ascii(09); #Descricao Etapa do Fechamento
    print mr_servicos.jstnom          clipped    
                                     ,ascii(09); #Justificativa Fechamento
    print mr_servicos.srvvndparqtd   ,ascii(09); #Parcelas
    print l_vlrparc                   using "<<<<<<<&.&&" 
                                     ,ascii(09); #Valor das parcelas
    print mr_servicos.pgtfrmcod_vnd   using "<<<<<<<&"    
                                     ,ascii(09); #Código da Forma de Pagamento
    print mr_servicos.pgtfrmdes_vnd   clipped            
                                     ,ascii(09); #Descrição Forma de Pagamento
    print mr_servicos.clinom_band     clipped              
                                     ,ascii(09); #Descrição bandeira do cartão
    print mr_servicos.dddcod          using "&&&" # SPR-2015-06510-2
         ,mr_servicos.lcltelnum       using "<<<<<<<<&"    
                                     ,ascii(09); #Telefone de Contato
    print mr_servicos.celteldddcod    using "&&&"          
         ,mr_servicos.celtelnum       using "<<<<<<<<&"    
                                     ,ascii(09); #Celular de Contato       
    print mr_servicos.email          ,ascii(09); #Email 
    print mr_servicos.vl_pgtprest     using "<<<<<<<&.&&"
                                     ,ascii(09); #Valor Calc Prestador
    print mr_servicos.prspgovlr       using "<<<<<<<&.&&" 
                                     ,ascii(09); #Valor Pago Prestador
    #=> SPR-13708 - NOVOS VALORES (DESCONTO INFORMADO)
    print mr_servicos.infdscper       using "<<<<<<<&.&&"
                                     ,ascii(09); #Perc Inform Desconto 
    print mr_servicos.infdscvlr       using "<<<<<<<&.&&" 
                                     ,ascii(09); #Valor Inform Desconto
    print mr_servicos.jsttxt_opr      clipped     
                                     ,ascii(09); #Justif Oper Desc Info
    print mr_servicos.funnom_sup      clipped     
                                     ,ascii(09); #Nome Superv Desc Info
    print mr_servicos.funmat_sup      using "&&&&&&"
                                     ,ascii(09); #Matr Superv Desc Info 
    print mr_servicos.jsttxt_sup      clipped    
                                     ,ascii(09); #Justif Superv Dsc Inf

    #- SPR-2015-22413 - Ação Promocional Black Friday
    print l_dt_exec                  ,ascii(09); #Data de Execucao do Serviço          
    print l_hr_exec                  ,ascii(09); #Hora de Execucao do Serviço
    print mr_servicos.nteadcvlr	      using "<<<<<<<&.&&" 
                                     ,ascii(09); #Pagto Adicional Noturno/Feriado

    print l_louadcflg                ,ascii(09); #Flag Pagto Adicional Louca
    print mr_servicos.louadcvlr	      using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Valor pago Adicional Louca  
                                     
    print l_avnadcflg                ,ascii(09); #Flag Pagto Adicional Alvenaria
    print mr_servicos.avnadcvlr	      using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Valor Pagto Adicional Alvenaria

    print l_pdahoradcflg             ,ascii(09); #Flag Pagto Adicional hora Parada
    print mr_servicos.pdahorqtd	     ,ascii(09); #Qtde Adicional hora Parada
    print mr_servicos.pdahoradcvlr    using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Valor pago Adicional hora Parada 	
 
    print l_tblhoradcflg	           ,ascii(09); #Flag Adicional hora Trabalhada
    print mr_servicos.tblhorqtd	     ,ascii(09); #Qtde Adicional hora Trabalhada
    print mr_servicos.tblhoradcvlr    using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Valor Adicional hora Trabalhada

    print l_qlmadcflg                ,ascii(09); #Flg pago Adicional KM
    print mr_servicos.pcrkmsqtd	     ,ascii(09); #Qtde pago Adicional KM
    print mr_servicos.qlmadcvlr       using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Valor pago Adicional KM

    print mr_servicos.infacrvlrprt    using "<<<<<<<<<<&.&&" 
                                     ,ascii(09); #Vlr Adc Informado Pago Prestador

    print mr_servicos.socntzgrpcod   ,ascii(09); #Codigo Grupo Natureza    # SPR-2016-03565
    print mr_servicos.socntzgrpdes   ,ascii(09); #Descricao Grupo Natureza # SPR-2016-03565
    print l_srv_imed_flg             ,ascii(09); #Servico Imediato         # SPR-2016-03565
    print mr_servicos.nomgrr         ,ascii(09); #Nome Guerra Prestador    # SPR-2016-03565
    print l_pgm_pontos clipped       ,ascii(09)  #Cod Programa Pontos      # SPR-2016-03565

end report

#-----------------------------------------#  
report bdbsr018_relat_apl()
#-----------------------------------------#
#- SPR-2016-03565 - Vendas e Parcerias.

 output
    left   margin    00
    right  margin    00
    top    margin    00
    bottom margin    00
    page   length    02

 format
    first page header

    print "Numero do Servico"                      ,ascii(09)
         ,"Ano do Servico"                         ,ascii(09)
         ,"Sucursal"                               ,ascii(09)
         ,"Apolice"                                ,ascii(09)
         ,"Item"                                   ,ascii(09)
         ,"Placa"                                  ,ascii(09)
         ,"Numero CGC/CPF"                         ,ascii(09)
         ,"Numero da Ordem do CGC"                 ,ascii(09)
         ,"Digito CGC/CPF"                         ,ascii(09)

 on every row
    
    print mr_servicos.atdsrvnum      ,ascii(09); #Número do Serviço
    print mr_servicos.atdsrvano      ,ascii(09); #Ano do Serviço

    print mr_apolice.succod         ,ascii(09); #Sucursal Apl 
    print mr_apolice.aplnumdig      ,ascii(09); #Num Apolice
    print mr_apolice.itmnumdig      ,ascii(09); #Item Apolice
    print mr_apolice.vcllicnum      ,ascii(09); #Placa Veiculo Segurado

    print mr_servicos.cgccpfnum      ,ascii(09); #Número CGC/CPF
    print mr_servicos.cgcord         ,ascii(09); #Número da Ordem do CGC
    print mr_servicos.cgccpfdig      ,ascii(09)  #Dígito CGC/CPF

end report
