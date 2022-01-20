#############################################################################
# Nome do Modulo: wdatc017                                         Ruiz     #
#                                                                  Wagner   #
#                                                                  Raji     #
#                                                                  Marcus   #
# Direciona e imprime laudo de servico para prestador              Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 16/11/2001  PSI          Marcus       Remocao de campos                   #
# 11/12/2002  PSI 150550   Zyon         Implementação versão de impressão   #
# 27/05/2003  PSI 173436   R. Santos    Inclusao de informacao de retorno.  #
# 03/07/2003  CT   99813   Zyon         Acerto   da informacao de retorno.  #
#                                                                           #
#############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data      Autor Fabrica PSI     Alteracao                                   #
# --------  ------------- ------  --------------------------------------------#
# 11/04/2005 Alinne,Meta  189790   Obter servicos multiplos                   #
#-----------------------------------------------------------------------------#
# 27/10/2005 Lucas Scheid 195138   Obter a descr. da especialidade do servico.#
# 30/07/2008 Fabio Costa  227145   Buscar data/hora do acionamento do servico #
#                                  retirar localidades na tela consulta situacao
# 27/11/2009 Ligia Mattge 232700   Exbir motivo retorno
# 13/08/2009 Burini       244236   Inclusão do Sub-Dairro                     #
#                                                                             #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca               #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


    define param record
        usrtip              char (001),
        webusrcod           char (006),
        sesnum              dec  (010),
        macsissgl           char (010),
        atdsrvnum           like datmservico.atdsrvnum,
        atdsrvano           like datmservico.atdsrvano,
        acao                smallint
    end record

    define ws1 record
        statusprc           dec  (01,0),
        sestblvardes1       char (0256),
        sestblvardes2       char (0256),
        sestblvardes3       char (0256),
        sestblvardes4       char (0256),
        sespcsprcnom        char (0256),
        prgsgl              char (0256),
        acsnivcod           dec  (01,0),
        webprscod           dec  (16,0)
    end record

    define ws record
        atdsrvorg           like datmservico.atdsrvorg,
        asitipcod           like datmservico.asitipcod,
        asimtvcod           like datkasimtv.asimtvcod,
        asimtvdes           like datkasimtv.asimtvdes,
        atdhorpvt           like datmservico.atdhorpvt,
        atddat              like datmservico.atddat,
        atdhor              like datmservico.atdhor,
        nom                 like datmservico.nom,
        ramcod              like datrservapol.ramcod,
        succod              like datrservapol.succod,
        aplnumdig           like datrservapol.aplnumdig,
        itmnumdig           like datrservapol.itmnumdig,
        edsnumref           like datrservapol.edsnumref,
        vcldes              like datmservico.vcldes,
        vclanomdl           like datmservico.vclanomdl,
        vcllicnum           like datmservico.vcllicnum,
        vclcorcod           like datmservico.vclcorcod,
        dddcod              like gsakend.dddcod,
        teltxt              like gsakend.teltxt,
        atdrsdflg           like datmservico.atdrsdflg,
        atddfttxt           like datmservico.atddfttxt,
        roddantxt           like datmservicocmp.roddantxt,
        bocnum              like datmservicocmp.bocnum,
        bocemi              like datmservicocmp.bocemi,
        rmcacpflg           like datmservicocmp.rmcacpflg,
        srvprlflg           like datmservico.srvprlflg,
        atdvclsgl           like datmservico.atdvclsgl,
        socvclcod           like datmservico.socvclcod,
        atdmotnom           like datmservico.atdmotnom,
        srrcoddig           like datmservico.srrcoddig,
        srrabvnom           like datksrr.srrabvnom,
        traco               char (132),
        privez              smallint,
        vclcordes           char (020),
        srvtipabvdes        like datksrvtip.srvtipabvdes,
        asitipabvdes        like datkasitip.asitipabvdes,
        atdrsddes           char (003),
        rmcacpdes           char (003),
        c24srvdsc           like datmservhist.c24srvdsc,
        atddatprg           like datmservico.atddatprg,
        atdhorprg           like datmservico.atdhorprg,
        pasnom              like datmpassageiro.pasnom,
        pasidd              like datmpassageiro.pasidd,
        bagflg              like datmassistpassag.bagflg,
        txivlr              like datmassistpassag.txivlr,
        lclrsccod           like datmsrvre.lclrsccod,
        orrdat              like datmsrvre.orrdat,
        orrhor              like datmsrvre.orrhor,
        sinntzcod           like datmsrvre.sinntzcod,
        socntzcod           like datmsrvre.socntzcod,
        ntzdes              char (040),
        atddmccidnom        like datmassistpassag.atddmccidnom,
        atddmcufdcod        like datmassistpassag.atddmcufdcod,
        atddstcidnom        like datmassistpassag.atddstcidnom,
        atddstufdcod        like datmassistpassag.atddstufdcod,
        trppfrdat           like datmassistpassag.trppfrdat,
        trppfrhor           like datmassistpassag.trppfrhor,
        lclrefptotxt1       char (050),
        lclrefptotxt2       char (050),
        lclrefptotxt3       char (050), # 19690
        lclrefptotxt4       char (050), # 19690
        lclrefptotxt5       char (050), # 19690
        sqlcode             integer,
        sttsess             integer,
        atdetpcod           like datmsrvintseqult.atdetpcod,
        vclcndlclcod        like datrcndlclsrv.vclcndlclcod,
        vclcndlcldes        like datkvclcndlcl.vclcndlcldes,
        ciaempcod           like datmservico.ciaempcod,
        ciaempsgl           char(40),
        srvretmtvcod        like datksrvret.srvretmtvcod,
        srvretmtvdes        like datksrvret.srvretmtvdes ,
        srvcbnhor           like datmservico.srvcbnhor      
    end record

    define a_rrw array[2] of record
        lclidttxt           like datmlcl.lclidttxt,
        lgdtxt              char (065),
        lgdtip              like datmlcl.lgdtip,
        lgdnom              like datmlcl.lgdnom,
        lgdnum              like datmlcl.lgdnum,
        brrnom              like datmlcl.brrnom,
        lclbrrnom           like datmlcl.lclbrrnom,
        endzon              like datmlcl.endzon,
        cidnom              like datmlcl.cidnom,
        ufdcod              like datmlcl.ufdcod,
        lgdcep              like datmlcl.lgdcep,
        lgdcepcmp           like datmlcl.lgdcepcmp,
        dddcod              like datmlcl.dddcod,
        lcltelnum           like datmlcl.lcltelnum,
        lclcttnom           like datmlcl.lclcttnom,
        lclrefptotxt        like datmlcl.lclrefptotxt,
        c24lclpdrcod        like datmlcl.c24lclpdrcod,
        endcmp              like datmlcl.endcmp
    end record

    #-----------------------------------
    # Informações do serviço original
    #-----------------------------------
    define ws_orig record
        atdsrvorg           like datmservico.atdsrvorg,
        atdsrvnum           like datmsrvre.atdorgsrvnum,
        atdsrvano           like datmsrvre.atdorgsrvano,
        orrdat              like datmsrvre.orrdat,
        orrhor              like datmsrvre.orrhor,
        atddfttxt           like datmservico.atddfttxt,
        sinntzcod           like datmsrvre.sinntzcod,
        socntzcod           like datmsrvre.socntzcod,
        ntzdes              char (040),
        inforet             char (010)
    end record

    #---------------------------------
    # Obter os servicos multiplos
    #---------------------------------
    define l_resultado smallint
    define l_mensagem  char(100)
    define l_cont      smallint
    define l_servico   char(200)
    define l_problema  char(200)
    define l_natureza  char(200)
    define l_atdetpcod like datmsrvacp.atdetpcod
    define l_espdes    like dbskesp.espdes # --DESCRICAO DA ESPECIALIDADE
    define l_pasasivcldes like datmtrptaxi.pasasivcldes

    define l_ret        smallint
    define l_azlaplcod  integer
    define l_doc_handle integer
    define l_kmlimite   char(3)
    define l_kmqtde     char(3)
    define l_kmlimiteaux integer
    define l_clscod      like abbmclaus.clscod
    define l_diaria      dec(10,2)
    define l_linha       char(80)
    define l_msg_lim     char(220)

    define al_retorno array[10] of record
                      atdmltsrvnum like datratdmltsrv.atdmltsrvnum
                     ,atdmltsrvano like datratdmltsrv.atdmltsrvano
                     ,socntzdes    like datksocntz.socntzdes
                     ,espdes       like dbskesp.espdes
                     ,atddfttxt    like datmservico.atddfttxt
                    end record

    define lr_hospedagem record
           resultado    smallint
          ,mensagem     char(080)
          ,hsphotnom    like datmhosped.hsphotnom
          ,hsphotend    like datmhosped.hsphotend
          ,hsphotbrr    like datmhosped.hsphotbrr
          ,hsphotuf     like datmhosped.hsphotuf
          ,hsphotcid    like datmhosped.hsphotcid
          ,hsphottelnum like datmhosped.hsphottelnum
          ,hsphotcttnom like datmhosped.hsphotcttnom
          ,hsphotdiavlr like datmhosped.hsphotdiavlr
          ,hsphotacmtip like datmhosped.hsphotacmtip
          ,obsdes       like datmhosped.obsdes
          ,hsphotrefpnt like datmhosped.hsphotrefpnt
          ,hpddiapvsqtd like datmhosped.hpddiapvsqtd
          ,hpdqrtqtd    like datmhosped.hpdqrtqtd
           end record

    define lr_exibe record
           msg_sup          char(600),
           srv_apoio        char(150),
           laudo_srv        char(150),
           tipo_srv         char(150),
           servico          char(150),
           tipo_socorro     char(150),
           tipo_taxi        char(150),
           dt_prg_prv       char(150),
           acionado         char(150),
           viatura          char(150),
           socorrista       char(150),
           veiculo          char(150),
           modelo           char(150),
           ano              char(150),
           placa            char(150),
           cor              char(150),
           local_ocorrencia char(150),
           local            char(150),
           endereco_ocor    char(150),
           bairro_ocor      char(150),
           cidade_ocor      char(150),
           endereco_dest    char(150),
           bairro_dest      char(150),
           cidade_dest      char(150),
           telefone         char(150),
           referencia       char(150),
           referencia1      char(150),
           referencia2      char(150),
           referencia3      char(150),
           referencia4      char(150),
           referencia5      char(150),
           responsavel      char(150),
           residencia       char(150),
           problema         char(150),
           rodas            char(150),
           bo               char(150),
           natureza         char(150),
           data_ocor        char(150),
           hora_ocor        char(150),
           srv_original     char(150),
           ordem_srv        char(500),
           orrdat           char(150),
           orrhor           char(150),
           prb_original     char(150),
           ntz_original     char(150),
           local_destino    char(150),
           lclidttxt        char(150),
           remocao          char(150),
           localidades      char(150),
           domicilio        char(150),
           ocorrencia       char(150),
           destino          char(150),
           bagagem          char(150),
           taxi             char(150),
           motivo           char(150),
           inf_passag       char(150),
           historico        char(150),
           inf_hosped       char(150),
           hotel            char(150),
           estado_htl       char(150),
           cidade_htl       char(150),
           bairro_htl       char(150),
           endereco_htl     char(150),
           referencia_htl   char(150),
           contato          char(150),
           telefone_htl     char(150),
           diaria           char(500),
           acomodacao       char(150),
           obs              char(150),
           dt_pref_viagem   char(150),
           nrdiarias        char(150),
           nrquartos        char(150),
           msg1             char(600),
           mtvret           char(150),
           empresa          char(150),
           empresaDesc      char(150)
           end record

    define l_acihor record
           atddat  like datmsrvacp.atdetpdat ,
           atdhor  like datmsrvacp.atdetphor
    end record
    
    define m_subbairro array[03] of record
           lclbrrnom   like datmlcl.lclbrrnom
    end record  
    
    #------------------------------
    # variaveis de retorno itau
    #------------------------------
    define lr_retorno record                                                           
         itaciacod     like datmitaaplitm.itaciacod    , 
         itaramcod     like datmitaaplitm.itaramcod    , 
         itaaplnum     like datmitaaplitm.itaaplnum    , 
         aplseqnum     like datmitaaplitm.aplseqnum    , 
         itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
         pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,   
         socqlmqtd     like datkitaasipln.socqlmqtd    , 
         erro          integer                         ,     
         mensagem      char(50)                                                                
    end record 
    
    define msg_itau char(1000) 
    
    define m_limpecas      char(500),
           m_mobrefvlr      like dpakpecrefvlr.mobrefvlr,
           m_pecmaxvlr      like dpakpecrefvlr.pecmaxvlr,         
           m_lgdnum_aux     char(06)
            
    define m_psaerrcod integer
            
main

    initialize param.* to null
    initialize l_resultado to null
    initialize l_mensagem  to null
    initialize l_cont      to null
    initialize l_servico   to null
    initialize l_problema  to null
    initialize l_natureza  to null
    initialize l_atdetpcod to null
    initialize l_espdes    to null 
    initialize l_pasasivcldes to null

    initialize l_ret        to null
    initialize l_azlaplcod  to null
    initialize l_doc_handle to null
    initialize l_kmlimite   to null
    initialize l_kmqtde     to null
    initialize l_kmlimiteaux to null
    initialize l_clscod      to null
    initialize l_diaria      to null
    initialize l_linha       to null
    initialize l_msg_lim     to null
    initialize msg_itau      to null

    initialize m_mobrefvlr      to null
    initialize m_pecmaxvlr      to null
    initialize m_lgdnum_aux     to null

    #---------------------------------
    # Le parametros recebidos do PERL
    #---------------------------------
    let param.usrtip       = arg_val(1)
    let param.webusrcod    = arg_val(2)
    let param.sesnum       = arg_val(3)
    let param.macsissgl    = arg_val(4)
    let param.atdsrvnum    = arg_val(5)
    let param.atdsrvano    = arg_val(6)
    let param.acao         = arg_val(7)
  
    initialize  a_rrw      to null
    initialize  ws.*       to null
    initialize  ws1.*      to null
    initialize  ws_orig.*  to null
    initialize  lr_exibe.*  to null
    initialize  lr_hospedagem.*  to null
    initialize  al_retorno to null
    initialize  l_acihor.* to null
    initialize  m_subbairro to null
    initialize  lr_retorno.* to null
    initialize  m_limpecas to null
    initialize m_psaerrcod to null
    
    #-----------------------
    # "" ou " - RETORNO"
    #-----------------------
    let ws_orig.inforet = ""
    let l_clscod = null
    let l_diaria = null
    let l_linha = null
    let l_msg_lim = null
    let msg_itau = null   
    let m_lgdnum_aux = null
                             
    #------------------------------------------
    #  ABRE BANCO   (TESTE ou PRODUCAO)
    #------------------------------------------
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read

    #---------------------------------------------
    #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
    #---------------------------------------------
    call wdatc002(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
                  returning ws1.*

    if ws1.statusprc <> 0 then
        display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu o limite máximo.@@"
        exit program(0)
    end if

    let ws1.prgsgl = "wdatc017"

    let ws.privez = 0

    #--------------------------------------------------------------
    # Busca informacoes do servico
    #--------------------------------------------------------------
    select datmservico.atdsrvorg   , datmservico.asitipcod    ,
           datmservico.atdhorpvt   , datmservico.atddat       ,
           datmservico.atdhor      , datmservico.nom          ,
           datrservapol.ramcod     , datrservapol.succod      ,
           datrservapol.aplnumdig  , datrservapol.itmnumdig   ,
           datmservico.vcldes      , datmservico.vclanomdl    ,
           datmservico.vcllicnum   , datmservico.vclcorcod    ,
           datmservico.atdrsdflg   , datmservico.atddfttxt    ,
           datmservico.atdvclsgl   , datmservico.atdmotnom    ,
           datmservico.atddatprg   , datmservico.atdhorprg    ,
           datmservico.socvclcod   , datmservico.srvprlflg    ,
           datmservico.srrcoddig                              ,
           datmservicocmp.roddantxt, datmservicocmp.bocnum    ,
           datmservicocmp.bocemi   , datmservicocmp.rmcacpflg ,
           datmservico.ciaempcod   , datmservico.srvcbnhor
      into ws.atdsrvorg    , ws.asitipcod    ,
           ws.atdhorpvt    , ws.atddat       ,
           ws.atdhor       , ws.nom          ,
           ws.ramcod       , ws.succod       ,
           ws.aplnumdig    , ws.itmnumdig    ,
           ws.vcldes       , ws.vclanomdl    ,
           ws.vcllicnum    , ws.vclcorcod    ,
           ws.atdrsdflg    , ws.atddfttxt    ,
           ws.atdvclsgl    , ws.atdmotnom    ,
           ws.atddatprg    , ws.atdhorprg    ,
           ws.socvclcod    , ws.srvprlflg    ,
           ws.srrcoddig    ,
           ws.roddantxt    , ws.bocnum       ,
           ws.bocemi       , ws.rmcacpflg    ,
           ws.ciaempcod    , ws.srvcbnhor
      from datmservico, outer datmservicocmp, outer datrservapol
     where datmservico.atdsrvnum    = param.atdsrvnum
       and datmservico.atdsrvano    = param.atdsrvano
       and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
       and datmservicocmp.atdsrvano = datmservico.atdsrvano
       and datrservapol.atdsrvnum   = datmservico.atdsrvnum
       and datrservapol.atdsrvano   = datmservico.atdsrvano
    
    
    # buscar data/hora do acionamento do servico
    whenever error continue
    select atdetpdat, atdetphor
      into l_acihor.atddat, l_acihor.atdhor
    from datmsrvacp 
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
      and atdsrvseq = ( select max(atdsrvseq) 
                        from datmsrvacp
                        where atdsrvnum = param.atdsrvnum
                          and atdsrvano = param.atdsrvano
                          and atdetpcod in (4,3,10) )
    whenever error stop
    
    
    #PSI 208264 - Display para informar qual logo deve ser utilizado
    display "PADRAO@@12@@", ws.ciaempcod, "@@"

    call wdatc017_apoio()
          returning lr_exibe.srv_apoio

    ##Obter a ultima etapa do servico
    let l_atdetpcod = null
    call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
         returning l_atdetpcod

    initialize lr_hospedagem.* to null

    if ws.atdsrvorg = 3 then ## hospedagem
       call cts22m01_selecionar(1,param.atdsrvnum, param.atdsrvano)
            returning lr_hospedagem.*
    end if
    
    let l_pasasivcldes  = ''
    if ws.atdsrvorg = 2 then ## Assist. passageiro
       select pasasivcldes into l_pasasivcldes from datmtrptaxi
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano

       if l_pasasivcldes is not null then
          if l_pasasivcldes = "P" Then
             if param.acao <> 2 then
                let lr_exibe.tipo_taxi =  "PADRAO@@8@@Tipo Taxi@@PASSEIO"
             else
                let lr_exibe.tipo_taxi =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo Taxi@@@@N@@L@@M@@4@@3@@1@@075%@@PASSEIO"
             end if
          else
             if param.acao <> 2 then
                let lr_exibe.tipo_taxi =  "PADRAO@@8@@Tipo Taxi@@VAN"
             else
                let lr_exibe.tipo_taxi =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo Taxi@@@@N@@L@@M@@4@@3@@1@@075%@@VAN"
             end if
          end if
       end if
    end if

    if ws.ciaempcod = 1 and
       (ws.atdsrvorg = 2 or ws.atdsrvorg = 3) then

          if  ws.aplnumdig is not null and
              ws.aplnumdig > 0         then

              call f_funapol_ultima_situacao
                   (ws.succod, ws.aplnumdig, ws.itmnumdig)
                   returning  g_funapol.*

              call cty05g00_assist_passag(1,ws.succod, ws.aplnumdig,
                                          ws.itmnumdig, g_funapol.dctnumseq)
                   returning l_clscod

          end if
    end if

    let l_linha = "_____________________________*******ATENÇÃO******______________________________"


    if ws.atdsrvorg = 3 then ## hospedagem

       case ws.ciaempcod
          when 1
             if l_clscod = "033" or l_clscod = "33R" then
                let l_diaria = 400.00
             else
                let l_diaria = 200.00
             end if
             
             let l_msg_lim = "Em caso de hospedagem devidamente autorizada pela Central de Atendimento, cobrar até o limite de R$ ", l_diaria, " da PORTO SEGURO. Qualquer valor excedente deve ser cobrado do segurado."
          when 84  
             if ws.ramcod = 531 or ws.ramcod = 31 then
                let l_diaria = 200.00
                let l_msg_lim = "Em caso de hospedagem devidamente autorizada pela Central de Atendimento, cobrar até o limite de R$ ", l_diaria, " da ITAÚ AUTO E RESIDÊNCIA. Qualquer valor excedente deve ser cobrado do segurado."
             end if 
       end case
       if ws.ciaempcod = 1 then
          
       else
       end if

       if param.acao <> 2 then

          let lr_exibe.inf_hosped = "PADRAO@@1@@B@@C@@0@@Informações sobre hospedagem@@"
          if (l_atdetpcod = 43 and lr_hospedagem.hsphotnom is not null) or
              param.acao = 0  then

             let lr_exibe.hotel = "PADRAO@@8@@Nome do Hotel@@", lr_hospedagem.hsphotnom, "@@"
             let lr_exibe.estado_htl = "PADRAO@@8@@Estado@@", lr_hospedagem.hsphotuf, "@@"
             let lr_exibe.cidade_htl = "PADRAO@@8@@Cidade@@", lr_hospedagem.hsphotcid, "@@"
             let lr_exibe.endereco_htl = "PADRAO@@8@@Endereço@@", lr_hospedagem.hsphotend, "@@"
             let lr_exibe.bairro_htl = "PADRAO@@8@@Bairro@@", lr_hospedagem.hsphotbrr, "@@"
             let lr_exibe.referencia_htl = "PADRAO@@8@@Referência@@", lr_hospedagem.hsphotrefpnt, "@@"
             let lr_exibe.contato = "PADRAO@@8@@Contato no Hotel@@", lr_hospedagem.hsphotcttnom, "@@"
             let lr_exibe.telefone_htl = "PADRAO@@8@@Telefones no Hotel@@", lr_hospedagem.hsphottelnum, "@@"

             let lr_exibe.nrdiarias = "PADRAO@@8@@Nr. de Diarias@@", lr_hospedagem.hpddiapvsqtd , "@@"

             let lr_exibe.telefone_htl = "PADRAO@@8@@Valor da Diaria@@", lr_hospedagem.hsphotdiavlr, "@@"

             let lr_exibe.nrquartos = "PADRAO@@8@@Nr. de Quartos@@", lr_hospedagem.hpdqrtqtd using " <<", "@@"

             let lr_exibe.acomodacao = "PADRAO@@8@@Tipo de Acomodação@@", lr_hospedagem.hsphotacmtip , "@@"

             let lr_exibe.obs = "PADRAO@@8@@Observações@@", lr_hospedagem.obsdes, "@@"

          else

             let lr_exibe.nrdiarias = "PADRAO@@8@@Nr. de Diarias@@", lr_hospedagem.hpddiapvsqtd , "@@"
             let lr_exibe.nrquartos = "PADRAO@@8@@Nr. de Quartos@@", lr_hospedagem.hpdqrtqtd using " <<", "@@"
          end if

          if l_atdetpcod = 13 then

             let lr_exibe.hotel = "PADRAO@@5@@Nome do Hotel@@0@@@@@@50@@80@@text@@hotel@@", lr_hospedagem.hsphotnom, "@@"
             let lr_exibe.estado_htl = "PADRAO@@5@@Estado@@0@@@@@@2@@2@@text@@estado_htl@@", lr_hospedagem.hsphotuf, "@@"
             let lr_exibe.cidade_htl = "PADRAO@@5@@Cidade@@0@@@@@@25@@40@@text@@cidade_htl@@", lr_hospedagem.hsphotcid, "@@"
             let lr_exibe.endereco_htl = "PADRAO@@5@@Endereço@@0@@@@@@50@@80@@text@@endereco_htl@@", lr_hospedagem.hsphotend, "@@"
             let lr_exibe.bairro_htl = "PADRAO@@5@@Bairro@@0@@@@@@25@@40@@text@@bairro_htl@@", lr_hospedagem.hsphotbrr, "@@"
             let lr_exibe.referencia_htl = "PADRAO@@5@@Referência@@0@@@@@@50@@80@@text@@referencia_htl@@", lr_hospedagem.hsphotrefpnt, "@@"
             let lr_exibe.contato = "PADRAO@@5@@Contato no Hotel@@0@@@@@@50@@80@@text@@contato@@", lr_hospedagem.hsphotcttnom, "@@"
             let lr_exibe.telefone_htl = "PADRAO@@5@@Telefones no Hotel@@0@@@@@@12@@12@@text@@telefone_htl@@", lr_hospedagem.hsphottelnum, "@@"

             let lr_exibe.nrdiarias = "PADRAO@@8@@Nr. de Diarias@@", lr_hospedagem.hpddiapvsqtd , "@@"

             if lr_hospedagem.hsphotdiavlr is null or
                lr_hospedagem.hsphotdiavlr = " " then
                let lr_hospedagem.hsphotdiavlr = 0
             end if

             let lr_exibe.diaria = "PADRAO2@@",
                 '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC"> ',
                 '<font size="1" face="ARIAL,HELVETICA,VERDANA">Valor da diaria</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1"> ',
                 '<input type="text" name="diaria" value="0.00" size="8" maxlength="10" type="text" onBlur="return func_diaria(', ws.ciaempcod,',', l_diaria, ')"> </td> </tr> </table>@@'

             let lr_exibe.nrquartos = "PADRAO@@5@@Nr. de Quartos@@0@@@@@@8@@10@@text@@nrquartos@@", lr_hospedagem.hpdqrtqtd using " <<","@@@@"

             let lr_exibe.acomodacao = "PADRAO@@5@@Tipo de Acomodação@@0@@@@@@25@@40@@text@@acomodacao@@", lr_hospedagem.hsphotacmtip , "@@"
             let lr_exibe.obs = "PADRAO@@5@@Observações@@0@@@@@@50@@80@@text@@obs@@", lr_hospedagem.obsdes, "@@"
          end if

       else
          if l_msg_lim is not null then
             let lr_exibe.msg1 = "PADRAO@@10@@1@@2@@1@@B@@L@@M@@4@@3@@2@@100%@@", l_linha, l_msg_lim clipped, "@@@@"
          end if

          if lr_hospedagem.hsphotnom is not null then
             let lr_exibe.inf_hosped =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Informações sobre hospedagem@@@@"

             let lr_exibe.hotel  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Hotel@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotnom, "@@@@"

             let lr_exibe.estado_htl  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Estado@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotuf, "@@@@"
             let lr_exibe.cidade_htl  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotcid, "@@@@"
             let lr_exibe.endereco_htl  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Endereço@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotend  clipped,' ', lr_hospedagem.hsphotbrr clipped, "@@@@"

             let lr_exibe.referencia_htl  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Referência@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotrefpnt, "@@@@"
             let lr_exibe.contato  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Contato Hotel@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotcttnom, "@@@@"
             let lr_exibe.telefone_htl  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Telefone@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphottelnum, "@@@@"
             let lr_exibe.diaria  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Valor da Diária@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotdiavlr, "@@@@"
             let lr_exibe.acomodacao  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo de Acomodação@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hsphotacmtip, "@@@@"
             let lr_exibe.obs  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Observações@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.obsdes, "@@@@"

          end if

          let lr_exibe.nrdiarias = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Nr. de Diarias@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hpddiapvsqtd , "@@@@"
          let lr_exibe.nrquartos = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Nr. de Quartos@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_hospedagem.hpdqrtqtd using "<<", "@@@@"

       end if
    end if

    #--------------------------------------------------------------
    # Busca informacoes do local da ocorrencia
    #--------------------------------------------------------------
    call ctx04g00_local_completo(param.atdsrvnum,
                                 param.atdsrvano,
                                 1)
                       returning a_rrw[1].lclidttxt   ,
                                 a_rrw[1].lgdtip      ,
                                 a_rrw[1].lgdnom      ,
                                 a_rrw[1].lgdnum      ,
                                 a_rrw[1].lclbrrnom   ,
                                 a_rrw[1].brrnom      ,
                                 a_rrw[1].cidnom      ,
                                 a_rrw[1].ufdcod      ,
                                 a_rrw[1].lclrefptotxt,
                                 a_rrw[1].endzon      ,
                                 a_rrw[1].lgdcep      ,
                                 a_rrw[1].lgdcepcmp   ,
                                 a_rrw[1].dddcod      ,
                                 a_rrw[1].lcltelnum   ,
                                 a_rrw[1].lclcttnom   ,
                                 a_rrw[1].c24lclpdrcod,
                                 ws.sqlcode,
                                 a_rrw[1].endcmp 
                                 
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[1].lclbrrnom = a_rrw[1].lclbrrnom
    
    call cts06g10_monta_brr_subbrr(a_rrw[1].brrnom,
                                   a_rrw[1].lclbrrnom)
         returning a_rrw[1].lclbrrnom                                  

    if ws.sqlcode <> 0  then
        error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
              " local de ocorrencia. AVISE A INFORMATICA!"
        exit program
    end if
    
    let m_lgdnum_aux = a_rrw[1].lgdnum using "<<<<#"   
    
    ##verifica se servico possui mecanismo de seguranca                                                   
    if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum , param.atdsrvano, ws.ciaempcod) then  
       if a_rrw[1].lgdnum is not null then
          #ocultar numero logradouro para seguranca do segurado       
          if not cty28g00_exibe_endereco_senha(param.atdsrvnum, param.atdsrvano) then       
          	  if a_rrw[1].lgdnum >= 1000  then
          	     let m_lgdnum_aux = m_lgdnum_aux[1,2] clipped, "XX"
          	  else 
          	    if a_rrw[1].lgdnum >= 100 then
          	        let m_lgdnum_aux = m_lgdnum_aux[1,1] clipped, "XX"  	  
          	    else  	     
          	       let m_lgdnum_aux = "XX"    	     	
          	    end if
          	  end if    
          end if
       end if          
    end if
        
    let a_rrw[1].lgdtxt = a_rrw[1].lgdtip clipped, " ",
                          a_rrw[1].lgdnom clipped, " ",
                          m_lgdnum_aux clipped, " ",
                          a_rrw[1].endcmp clipped 
                          
    
    #--------------------------------------------------------------
    # Busca informacoes do local de destino
    #--------------------------------------------------------------
    call ctx04g00_local_completo(param.atdsrvnum,
                                 param.atdsrvano,
                                 2)
                       returning a_rrw[2].lclidttxt   ,
                                 a_rrw[2].lgdtip      ,
                                 a_rrw[2].lgdnom      ,
                                 a_rrw[2].lgdnum      ,
                                 a_rrw[2].lclbrrnom   ,
                                 a_rrw[2].brrnom      ,
                                 a_rrw[2].cidnom      ,
                                 a_rrw[2].ufdcod      ,
                                 a_rrw[2].lclrefptotxt,
                                 a_rrw[2].endzon      ,
                                 a_rrw[2].lgdcep      ,
                                 a_rrw[2].lgdcepcmp   ,
                                 a_rrw[2].dddcod      ,
                                 a_rrw[2].lcltelnum   ,
                                 a_rrw[2].lclcttnom   ,
                                 a_rrw[2].c24lclpdrcod,
                                 ws.sqlcode,
                                 a_rrw[2].endcmp
                                 
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[2].lclbrrnom = a_rrw[2].lclbrrnom
    
    call cts06g10_monta_brr_subbrr(a_rrw[2].brrnom,
                                   a_rrw[2].lclbrrnom)
         returning a_rrw[2].lclbrrnom                                 

    if ws.sqlcode <> notfound then
        if ws.sqlcode = 0   then
            let a_rrw[2].lgdtxt = a_rrw[2].lgdtip clipped, " ",
                a_rrw[2].lgdnom clipped, " ",
                a_rrw[2].lgdnum using "<<<<#", " ",
                a_rrw[2].endcmp clipped
        end if
    end if

    #--------------------------------------------------------------
    # Porto Socorro/Sinistro de R.E.
    #--------------------------------------------------------------
    if ws.atdsrvorg = 9  or
       ws.atdsrvorg = 13 then

        select lclrsccod,
               orrdat,
               orrhor,
               sinntzcod,
               socntzcod
          into ws.lclrsccod,
               ws.orrdat,
               ws.orrhor,
               ws.sinntzcod,
               ws.socntzcod
          from datmsrvre
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano

        let ws.ntzdes = "*** NAO CADASTRADO ***"

        if ws.sinntzcod is not null then
            select sinntzdes
              into ws.ntzdes
              from sgaknatur
             where sinramgrp = "4"
               and sinntzcod = ws.sinntzcod
        else
            select socntzdes
              into ws.ntzdes
              from datksocntz
             where socntzcod = ws.socntzcod
        end if

        #---------------------------------
        #Obter os servicos multiplos
        #---------------------------------

        call cts29g00_obter_multiplo(1,param.atdsrvnum,param.atdsrvano)
           returning l_resultado,l_mensagem,al_retorno[1].*,al_retorno[2].*
                    ,al_retorno[3].*,al_retorno[4].*,al_retorno[5].*,al_retorno[6].*
                    ,al_retorno[7].*,al_retorno[8].*,al_retorno[9].*,al_retorno[10].*

        #--------------------------------
        # Informações do serviço original
        #--------------------------------

        select datmsrvre.atdorgsrvnum,
               datmsrvre.atdorgsrvano,
               datmsrvre.srvretmtvcod
          into ws_orig.atdsrvnum,
               ws_orig.atdsrvano,
               ws.srvretmtvcod
          from datmsrvre
         where datmsrvre.atdsrvnum = param.atdsrvnum
           and datmsrvre.atdsrvano = param.atdsrvano

        if ws_orig.atdsrvnum is not null and
           ws_orig.atdsrvano is not null then

            let ws_orig.inforet = " - RETORNO"

            select datmservico.atdsrvorg,
                   datmservico.atddfttxt
              into ws_orig.atdsrvorg,
                   ws_orig.atddfttxt
              from datmservico
             where datmservico.atdsrvnum = ws_orig.atdsrvnum
               and datmservico.atdsrvano = ws_orig.atdsrvano

            select datmsrvre.orrdat,
                   datmsrvre.orrhor,
                   datmsrvre.sinntzcod,
                   datmsrvre.socntzcod
              into ws_orig.orrdat,
                   ws_orig.orrhor,
                   ws_orig.sinntzcod,
                   ws_orig.socntzcod
              from datmsrvre
             where datmsrvre.atdsrvnum = ws_orig.atdsrvnum
               and datmsrvre.atdsrvano = ws_orig.atdsrvano

            let ws_orig.ntzdes = "*** NAO CADASTRADO ***"

            if ws_orig.sinntzcod is not null then
                select sinntzdes into ws_orig.ntzdes from sgaknatur where sinramgrp = "4" and sinntzcod = ws_orig.sinntzcod
            else
                select socntzdes into ws_orig.ntzdes from datksocntz where socntzcod = ws_orig.socntzcod
            end if

            if ws.srvretmtvcod = 999  then
               select srvretexcdes
                 into ws.srvretmtvdes
                 from datmsrvretexc
                where atdsrvnum = param.atdsrvnum
                  and atdsrvano = param.atdsrvano
            else
               select srvretmtvdes
                 into ws.srvretmtvdes
                 from datksrvret
                where srvretmtvcod  = ws.srvretmtvcod
            end if

            if ws.srvretmtvdes is not null then
               let lr_exibe.mtvret =  "PADRAO@@8@@Motivo Retorno@@",
                   ws.srvretmtvdes clipped, "@@"
            end if
        end if

    end if # Fim Porto Socorro/Sinistro de R.E.

    let ws.srvtipabvdes = "NAO CADASTR"

    select srvtipabvdes
      into ws.srvtipabvdes
      from datksrvtip
     where atdsrvorg = ws.atdsrvorg

    let ws.asitipabvdes = "N/CADAST"

    select asitipabvdes
      into ws.asitipabvdes
      from datkasitip
     where asitipcod = ws.asitipcod

    case ws.atdrsdflg
        when "S" let ws.atdrsddes = "SIM"
        when "N" let ws.atdrsddes = "NAO"
    end case

    case ws.rmcacpflg
        when "S" let ws.rmcacpdes = "SIM"
        when "N" let ws.rmcacpdes = "NAO"
    end case

    if ws.vclcorcod   is not null    then
        select cpodes
          into ws.vclcordes
          from iddkdominio
         where cponom = "vclcorcod"
           and cpocod = ws.vclcorcod
    end if

    #----------------------------------------------------
    #    Verifica se o serviço já foi aceito e envia um
    #    flag para mostrar o botão de impressão no laudo
    #----------------------------------------------------
    let ws.atdetpcod  = null

    select atdetpcod
      into ws.atdetpcod
      from datmsrvintseqult
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    display "IMPOK@@0@@"

    initialize ws.ciaempsgl to null

    # Pesquisa a empresa do servico para exibir no cabecalho
    call cty14g00_empresa(1, ws.ciaempcod)
         returning l_ret,
                   l_mensagem,
                   ws.ciaempsgl
                   
    call cts59g00_idt_srv_saps(1, param.atdsrvnum, param.atdsrvano) returning m_psaerrcod
    
    if m_psaerrcod = 0
       then
       let ws.ciaempsgl = 'SERVIÇOS AVULSOS PORTO SEGURO' 
    end if
    
    if l_ret <> 1 then
       let ws.ciaempsgl = ""
    else
       let ws.ciaempsgl = " - ", ws.ciaempsgl
    end if
    
    let lr_exibe.empresaDesc = ws.ciaempcod," - ", ws.ciaempsgl
    
    #PSI 205206
    #Buscar limite de kilometragem para apolice
    #se empresa é da azul, buscar o limite de kilometragem
    # contida no XML na tag: APOLICE/ASSISTENCIA/GUINCHO/KMLIMITE.

    if ws.ciaempcod = 35 then
       # Inicializa msg com km fixo 200km
       let lr_exibe.msg_sup  = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@<h2>AZUL SEGUROS</h2>Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR ** ATÉ 200KM DA AZUL SEGUROS **, qualquer KM excedente deve ser cobrado do segurado.@@@@"

       #descobrir a apolice do servico
       call ctd07g02_busca_apolice_servico(1,
                                           param.atdsrvnum,
                                           param.atdsrvano)
           returning l_ret,
                     l_mensagem,
                     ws.succod,
                     ws.ramcod,
                     ws.aplnumdig,
                     ws.itmnumdig,
                     ws.edsnumref
       if l_ret = 1 then
           #descobrir o código para busca do XML
           call ctd02g01_azlaplcod (ws.succod,
                                    ws.ramcod,
                                    ws.aplnumdig,
                                    ws.itmnumdig,
                                    ws.edsnumref)
                returning l_ret,
                          l_mensagem,
                          l_azlaplcod
           if l_ret = 1 then
              #descobrir o doc_handle para busca do XML
              call ctd02g00_agrupaXML (l_azlaplcod)
                   returning l_doc_handle
              #com o doc_handle conseguimos localizar um item do XML de uma
              # apolice da Azul
	      ---> Busca Limites da Azul
              call cts49g00_clausulas (l_doc_handle)
                   returning l_kmlimite,
                             l_kmqtde

              #calcular ida e volta
              let l_kmlimiteaux = l_kmlimite
              let l_kmlimiteaux = l_kmlimiteaux * 2

              let lr_exibe.msg_sup  = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@<h2>AZUL SEGUROS</h2>Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR ** ATÉ ", l_kmlimiteaux using "<<<#" , "KM DA AZUL SEGUROS **, qualquer KM excedente deve ser cobrado do segurado.@@@@"

           end if

           #se retorno diferente de 1, nao conseguiremos encontrar XML
        end if

        #se diferente de 1, pode ser apolice sem documento
        # entao nao temos como encontrar o XML
    end if
    
    if ws.ciaempcod = 84 then
          
          select a.ramcod,                    
                 a.aplnumdig,                 
                 a.itmnumdig,                 
                 a.edsnumref,                 
                 b.itaciacod
           into  g_documento.ramcod,   
                 g_documento.aplnumdig,
                 g_documento.itmnumdig,
                 g_documento.edsnumref,
                 g_documento.itaciacod
           from datrligapol a,                
                datrligitaaplitm b             
          where a.lignum = (select min(lignum) 
                              from datmligacao 
                             where atdsrvnum = param.atdsrvnum
                               and atdsrvano = param.atdsrvano) 
             and a.lignum = b.lignum            
          
          call cty22g00_rec_dados_itau(g_documento.itaciacod,
	          	               g_documento.ramcod   ,
	             	               g_documento.aplnumdig,
	       	                       g_documento.edsnumref,
	       	                       g_documento.itmnumdig)
	            returning lr_retorno.erro,    
	                      lr_retorno.mensagem
	       
          #let lr_exibe.msg_sup  = "lr_retorno.erro: ",lr_retorno.erro
          #let lr_exibe.msg_sup  = lr_exibe.msg_sup,"g_doc_itau[1].itaasiplncod: ",g_doc_itau[1].itaasiplncod 
          if lr_retorno.erro = 0 then
             
             #let lr_exibe.msg_sup  = lr_exibe.msg_sup, "g_doc_itau[1].itaasiplncod: ",g_doc_itau[1].itaasiplncod
             call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)		
                     returning lr_retorno.pansoclmtqtd,					
                               lr_retorno.socqlmqtd,   					
                               lr_retorno.erro,        					
                               lr_retorno.mensagem
             #let lr_exibe.msg_sup  = lr_exibe.msg_sup, "lr_retorno.erro: ",lr_retorno.erro
             #let lr_exibe.msg_sup  = lr_exibe.msg_sup, "lr_retorno.mensagem: ",lr_retorno.mensagem
          end if 	
               
                      
       # Inicializa msg com km fixo 200km
       if g_documento.ramcod = 531 or g_documento.ramcod = 31 then  
          let msg_itau  = "<h2>ITAÚ AUTO E RESIDÊNCIA </h2>Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR ** ATE 200KM DA ITAÚ AUTO E RESIDÊNCIA **,qualquer KM excedente deve ser cobrado do segurado.@@@@"
          let lr_exibe.msg_sup  = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",msg_itau
       end if 
       #descobrir a apolice do servico
       call ctd07g02_busca_apolice_servico(1,
                                           param.atdsrvnum,
                                           param.atdsrvano)
           returning l_ret,
                     l_mensagem,
                     ws.succod,
                     ws.ramcod,
                     ws.aplnumdig,
                     ws.itmnumdig,
                     ws.edsnumref
       if l_ret = 1 then        
              if g_documento.ramcod = 531 or g_documento.ramcod = 31 then      
                 #calcular ida e volta                    
                 let l_kmlimiteaux = lr_retorno.socqlmqtd        
                 let l_kmlimiteaux = l_kmlimiteaux * 2
                 
                 # Buscar a quilometragem para a Itau 
                 let msg_itau  = "<h2>ITAÚ AUTO E RESIDÊNCIA</h2>Em caso de viagem,devidamente autorizada pela central de atendimento,COBRAR ** ATE ",l_kmlimiteaux using "<<<#"," KM DA ITAÚ AUTO E RESIDÊNCIA  **,"
                 let lr_exibe.msg_sup = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",msg_itau," qualquer KM excedente deve ser cobrado do segurado.@@@@"
              else
                  if al_retorno[1].atdmltsrvnum is not null then
                     let m_limpecas = cts29g00_texto_itau_limite_multiplo( param.atdsrvnum,param.atdsrvano)
                     let msg_itau  = "<h2>ITAÚ AUTO E RESIDÊNCIA</h2>Em caso de fornecimento de pecas, limitado ao valor ",m_limpecas clipped," **."
                     let lr_exibe.msg_sup = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",msg_itau clipped," Em caso de exedente entrar em contato com a C.O.@@@@"
                  else
                      select socntzcod                        
                        into ws.socntzcod                     
                        from datmsrvre                        
                       where atdsrvnum = param.atdsrvnum 
                         and atdsrvano = param.atdsrvano 
                      
                      select mobrefvlr,
                             pecmaxvlr
                        into m_mobrefvlr,
                             m_pecmaxvlr 
                        from dpakpecrefvlr
                       where socntzcod = ws.socntzcod
                         and empcod    = ws.ciaempcod 
                   
	                   if (m_mobrefvlr is not null or m_mobrefvlr <> '') and 
                        (m_pecmaxvlr is not null or m_pecmaxvlr <> '') then
                          let msg_itau  = "<h2>ITAÚ AUTO E RESIDÊNCIA</h2>Em caso de fornecimento de pecas, COBRAR ** ATE ",m_pecmaxvlr using "<<<<<<<<<<.<<"," DA ITAÚ AUTO E RESIDÊNCIA  **."
                          let lr_exibe.msg_sup = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",msg_itau clipped," Em caso de exedente entrar em contato com a C.O.@@@@"
                     else
	                       let msg_itau         = null 
	                       let lr_exibe.msg_sup = null
	                   end if
                  end if
	                    
	               #display "lr_exibe.msg_sup: ",lr_exibe.msg_sup clipped   
	               let ws.socntzcod = null  
              end if 
       end if
    end if 

    if param.acao <> 2 then
        let lr_exibe.laudo_srv =  "PADRAO@@1@@B@@C@@0@@Laudo do serviço", ws.ciaempsgl clipped, "@@"
        let lr_exibe.tipo_srv =  "PADRAO@@8@@Tipo de serviço@@",
                ws.srvtipabvdes,
                ws_orig.inforet,
                "@@"
        #----------------------------------------------------
        #  Montar a linha para exibicao do numero do servico
        #  com os servicos multiplos
        #----------------------------------------------------
        let l_servico = "PADRAO@@8@@Ordem serviço@@"
                       ,ws.atdsrvorg using "&&"
                       ,"/"
                       ,param.atdsrvnum using "&&&&&&&"
                       ,"-"
                       ,param.atdsrvano using "&&"

        for l_cont = 1 to 10
           if al_retorno[l_cont].atdmltsrvnum is not null and
              al_retorno[l_cont].atdmltsrvnum <> 0 then
              let l_servico = l_servico clipped
                             ," "
                             ,ws.atdsrvorg using "&&"
                             ,"/"
                             ,al_retorno[l_cont].atdmltsrvnum using "&&&&&&&"
                             ,"-"
                             ,al_retorno[l_cont].atdmltsrvano using "&&"
           end if
        end for

        let lr_exibe.servico = l_servico, "@@"

        let lr_exibe.tipo_socorro =  "PADRAO@@8@@Tipo socorro@@"
               ,ws.asitipabvdes
               ,"@@"
        #----------------------------------------------------------
        if ws.atddatprg  is not null then
           if ws.atddatprg = today or
              ws.atddatprg > today then
               let lr_exibe.dt_prg_prv = "PADRAO@@8@@Programado@@",
                       ws.atddatprg,
                       " as ",
                       ws.atdhorprg,
                       "@@"
           end if
        else
           let lr_exibe.dt_prg_prv  = "PADRAO@@8@@Previsão@@",
                   ws.atdhorpvt,
                   "@@"
        end if
        
        if l_acihor.atddat is not null and 
           l_acihor.atdhor is not null
           then
           let lr_exibe.acionado =  "PADRAO@@8@@Acionado em@@",
                l_acihor.atddat,
                " as ",
                l_acihor.atdhor,
                "@@"
        else
           let lr_exibe.acionado =  "PADRAO@@8@@Solicitado em@@",
                ws.atddat,
                " as ",
                ws.atdhor,
                "@@"
        end if
        
    else

        let lr_exibe.laudo_srv = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Laudo de Serviço", ws.ciaempsgl clipped, "@@@@"
        let lr_exibe.tipo_srv  = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo de Serviço@@@@N@@L@@M@@4@@3@@1@@075%@@",
                ws.srvtipabvdes,
                ws_orig.inforet,
                "@@@@"
        #----------------------------------------------------
        #  Montar a linha para exibicao do numero do servico
        #  com os servicos multiplos
        #----------------------------------------------------
        let l_servico = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ordem serviço@@@@N@@L@@M@@4@@3@@1@@075%@@"
                       ,ws.atdsrvorg using "&&"
                       ,"/"
                       ,param.atdsrvnum using "&&&&&&&"
                       ,"-"
                       ,param.atdsrvano using "&&"

        for l_cont = 1 to 10
           if al_retorno[l_cont].atdmltsrvnum is not null then
              let l_servico = l_servico clipped
                              ," "
                              ,ws.atdsrvorg using "&&"
                              ,"/"
                              ,al_retorno[l_cont].atdmltsrvnum using "&&&&&&&"
                              ,"-"
                              ,al_retorno[l_cont].atdmltsrvano using "&&"
           end if
        end for

        let lr_exibe.servico = l_servico,"@@@@"

        #---------------------------------------------------
        let lr_exibe.tipo_socorro =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo socorro@@@@N@@L@@M@@4@@3@@1@@075%@@",
                ws.asitipabvdes,
                "@@@@"
        if ws.atddatprg is not null then
            if ws.atddatprg = today or
               ws.atddatprg > today then
                let lr_exibe.dt_prg_prv = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Programado@@@@N@@L@@M@@4@@3@@1@@075%@@",
                        ws.atddatprg,
                        " as ",
                        ws.atdhorprg,
                        "@@@@"
            end if
        else
            let lr_exibe.dt_prg_prv = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Previsão@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.atdhorpvt,
                    "@@@@"
        end if
        
        if l_acihor.atddat is not null and 
           l_acihor.atdhor is not null
           then
           let lr_exibe.acionado = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Acionado em@@@@N@@L@@M@@4@@3@@1@@075%@@",
                                   l_acihor.atddat,
                                   " as ",
                                   l_acihor.atdhor,
                                   "@@@@"
        else
           let lr_exibe.acionado = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Solicitado em@@@@N@@L@@M@@4@@3@@1@@075%@@",
                                   ws.atddat,
                                   " as ",
                                   ws.atdhor,
                                   "@@@@"
        end if
        
    end if

    #-----------------------------------------------------------
    # Se codigo veiculo informado, ler cadastro de veiculos
    #-----------------------------------------------------------
    if ws.socvclcod is not null then
        select atdvclsgl
          into ws.atdvclsgl
          from datkveiculo
         where datkveiculo.socvclcod = ws.socvclcod
    end if

    #-----------------------------------------------------------
    # Se codigo socorrista informado, ler cadastro de socorrista
    #-----------------------------------------------------------
    if ws.srrcoddig  is not null then
        select srrabvnom
          into ws.srrabvnom
          from datksrr
         where datksrr.srrcoddig = ws.srrcoddig
    end if

    if ws.atdvclsgl is not null or
       ws.atdmotnom is not null or
       ws.srrabvnom is not null then

        if ws.atdmotnom is not null and
           ws.atdmotnom <> "  "     then
            if param.acao <> 2 then
                let lr_exibe.viatura =  "PADRAO@@8@@Viatura@@",
                        ws.atdvclsgl,
                        "@@"
                let lr_exibe.socorrista = "PADRAO@@8@@Socorrista@@",
                        ws.atdmotnom,
                        "@@"
            else
                let lr_exibe.viatura = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Viatura@@@@N@@L@@M@@4@@3@@1@@075%@@",
                        ws.atdvclsgl,
                        "@@@@"
                let lr_exibe.socorrista = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Socorrista@@@@N@@L@@M@@4@@3@@1@@075%@@",
                        ws.atdmotnom,
                        "@@@@"
            end if
        else
            if param.acao <> 2 then
               let lr_exibe.viatura = "PADRAO@@8@@Viatura@@",
                        ws.atdvclsgl,
                        "@@"
                let lr_exibe.socorrista = "PADRAO@@8@@Socorrista@@",
                        ws.srrcoddig using "####&&&&",
                        " - ",
                        ws.srrabvnom,
                        "@@"
            else
                let lr_exibe.viatura = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Viatura@@@@N@@L@@M@@4@@3@@1@@075%@@",
                        ws.atdvclsgl,
                        "@@@@"
                let lr_exibe.socorrista = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Socorrista@@@@N@@L@@M@@4@@3@@1@@075%@@",
                         ws.srrcoddig using "####&&&&",
                        " - ",
                        ws.srrabvnom,
                        "@@@@"
            end if

        end if

    end if

    if ws.atdsrvorg <> 9  and
       ws.atdsrvorg <> 13 then
        if param.acao <> 2 then
            let lr_exibe.veiculo = "PADRAO@@1@@B@@C@@0@@Veículo@@"
            let lr_exibe.modelo = "PADRAO@@8@@Modelo@@",
                    ws.vcldes,
                    "@@"
            let lr_exibe.ano = "PADRAO@@8@@Ano@@",
                    ws.vclanomdl,
                    "@@"
            let lr_exibe.placa =  "PADRAO@@8@@Placa@@",
                    ws.vcllicnum,
                    "@@"
            let lr_exibe.cor =  "PADRAO@@8@@Cor@@",
                    ws.vclcordes,
                    "@@"
        else
            let lr_exibe.veiculo =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Veículo@@@@"
            let lr_exibe.modelo =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Modelo@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.vcldes,
                    "@@@@"
            let lr_exibe.ano = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ano@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.vclanomdl,
                    "@@@@"
            let lr_exibe.placa =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Placa@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.vcllicnum,
                    "@@@@"
            let lr_exibe.cor =   "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cor@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.vclcordes,
                    "@@@@"
        end if
    end if

    #-----------------------------------------------------------------
    # Exibe endereco do local da ocorrencia
    #-----------------------------------------------------------------
    # OSF 19690
    initialize ws.lclrefptotxt1,
               ws.lclrefptotxt2,
               ws.lclrefptotxt3,
               ws.lclrefptotxt4,
               ws.lclrefptotxt5  to null

    let ws.lclrefptotxt1 = a_rrw[1].lclrefptotxt[001,050]
    let ws.lclrefptotxt2 = a_rrw[1].lclrefptotxt[051,100]
    let ws.lclrefptotxt3 = a_rrw[1].lclrefptotxt[101,150]
    let ws.lclrefptotxt4 = a_rrw[1].lclrefptotxt[151,200]
    let ws.lclrefptotxt5 = a_rrw[1].lclrefptotxt[201,250]

    if param.acao <> 2 then
        let lr_exibe.local_ocorrencia = "PADRAO@@1@@B@@C@@0@@Local ocorrência@@"
        if ws.atdsrvorg = 3 then
           let lr_exibe.local_ocorrencia = "PADRAO@@1@@B@@C@@0@@Local hospedagem@@"
        end if
    else
        let lr_exibe.local_ocorrencia =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Local ocorrência@@@@"
        if ws.atdsrvorg = 3 then
           let lr_exibe.local_ocorrencia =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Local hospedagem@@@@"
        end if
    end if

    if a_rrw[1].lclidttxt  is not null then
        if param.acao <> 2 then
            let lr_exibe.local = "PADRAO@@8@@Local@@",
                    a_rrw[1].lclidttxt,
                    "@@"
        else
           let lr_exibe.local = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Local@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[1].lclidttxt,
                   "@@@@"
        end if
    end if

    if param.acao <> 2 then
        let lr_exibe.endereco_ocor =  "PADRAO@@8@@Endereço@@",
                a_rrw[1].lgdtxt,
                "@@"
        let lr_exibe.bairro_ocor = "PADRAO@@8@@Bairro@@",
                a_rrw[1].lclbrrnom,
                "@@"
        let lr_exibe.cidade_ocor = "PADRAO@@8@@Cidade@@",
                a_rrw[1].cidnom clipped,
                " - ",
                a_rrw[1].ufdcod,
                "@@"
        let lr_exibe.telefone = "PADRAO@@8@@Telefone@@",
                #"(",
                #a_rrw[1].dddcod,
                #") ",
                #a_rrw[1].lcltelnum,
                "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO",
                "@@"
    else
        let lr_exibe.endereco_ocor =   "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Endereço@@@@N@@L@@M@@4@@3@@1@@075%@@",
                a_rrw[1].lgdtxt,
                "@@@@"
        let lr_exibe.bairro_ocor = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bairro@@@@N@@L@@M@@4@@3@@1@@075%@@",
                a_rrw[1].lclbrrnom,
                "@@@@"
        let lr_exibe.cidade_ocor = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@",
                a_rrw[1].cidnom clipped,
                " - ",
                a_rrw[1].ufdcod,
                "@@@@"
        let lr_exibe.telefone = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Telefone@@@@N@@L@@M@@4@@3@@1@@075%@@",
                #"(",
                #a_rrw[1].dddcod,
                #") ",
                #a_rrw[1].lcltelnum
                ###"@@@@"
                "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO"   
    end if

    let ws.lclrefptotxt1 = ws.lclrefptotxt1 clipped

    if ws.lclrefptotxt1 is not null then
        if param.acao <> 2 then
            let lr_exibe.referencia =  "PADRAO@@8@@Referência@@",
                    ws.lclrefptotxt1 clipped,
                    "@@",
                    ws.lclrefptotxt2 clipped,
                    "@@",
                    ws.lclrefptotxt3 clipped,
                    "@@",
                    ws.lclrefptotxt4 clipped,
                    "@@",
                    ws.lclrefptotxt5 clipped,
                    "@@"
        else
           let lr_exibe.referencia1 = "PADRAO@@10@@2@@2@@0",
                   "@@N@@L@@M@@4@@3@@1@@025%@@Referência@@",
                   "@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.lclrefptotxt1 clipped,
                   "@@@@"
           let lr_exibe.referencia2 =  "PADRAO@@10@@2@@2@@0",
                   "@@N@@L@@M@@4@@3@@1@@025%@@@@",
                   "@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.lclrefptotxt2 clipped,
                   "@@@@"
           let lr_exibe.referencia3 =  "PADRAO@@10@@2@@2@@0",
                   "@@N@@L@@M@@4@@3@@1@@025%@@@@",
                   "@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.lclrefptotxt3 clipped,
                   "@@@@"
           let lr_exibe.referencia4 = "PADRAO@@10@@2@@2@@0",
                   "@@N@@L@@M@@4@@3@@1@@025%@@@@",
                   "@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.lclrefptotxt4 clipped,
                   "@@@@"
           let lr_exibe.referencia5 = "PADRAO@@10@@2@@2@@0",
                   "@@N@@L@@M@@4@@3@@1@@025%@@@@",
                   "@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.lclrefptotxt5 clipped,
                   "@@@@"
        end if
    end if

    if param.acao <> 2 then
        let lr_exibe.responsavel =  "PADRAO@@8@@Responsável@@",
                a_rrw[1].lclcttnom,
                "@@"
    else
        let lr_exibe.responsavel =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Responsável@@@@N@@L@@M@@4@@3@@1@@075%@@",
                a_rrw[1].lclcttnom,
                "@@@@"
    end if

    if ws.atdrsddes is not null  then
        if param.acao <> 2 then
            let lr_exibe.residencia =  "PADRAO@@8@@Residência@@",
                     ws.atdrsddes,
                     "@@"
        else
            let lr_exibe.residencia = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Residência@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.atdrsddes,
                    "@@@@"
        end if
    end if

    if ws.atdsrvorg = 4 or
       ws.atdsrvorg = 6 or
       ws.atdsrvorg = 1 then

        if param.acao <> 2 then
           let lr_exibe.problema =  "PADRAO@@8@@Problema@@",
                   ws.atddfttxt,
                   "@@"
           let lr_exibe.rodas =  "PADRAO@@8@@Rodas danificadas@@",
                   ws.roddantxt,
                   "@@"
           let lr_exibe.bo = "PADRAO@@8@@Número B.O.@@",
                   ws.bocnum using "<<<<#",
                   "  ",
                   ws.bocemi,
                   "@@"
        else
            let lr_exibe.problema =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Problema@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.atddfttxt,
                    "@@@@"
            let lr_exibe.rodas =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Rodas danificadas@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.roddantxt,
                    "@@@@"
             let lr_exibe.bo =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Número B.O.@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.bocnum using "<<<<#",
                    "  ",
                    ws.bocemi,
                    "@@@@"
        end if

    else

        if ws.atdsrvorg = 5 or ws.atdsrvorg = 7 then

          if ws.roddantxt is not null then
              if param.acao <> 2 then
                  let lr_exibe.rodas = "PADRAO@@8@@Rodas danificadas@@",
                          ws.roddantxt,
                          "@@"
              else
                  let lr_exibe.rodas =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Rodas danificadas@@@@N@@L@@M@@4@@3@@1@@075%@@",
                          ws.roddantxt,
                          "@@@@"
              end if
          end if

        else

            if ws.atdsrvorg =  9 or
               ws.atdsrvorg = 13 then

                if param.acao <> 2 then
                #-----------------------------------------
                # Montar linha para exibicao do problema
                #-----------------------------------------

                    let l_problema =  "PADRAO@@8@@Problema@@"
                                     ,ws.atddfttxt

                    for l_cont = 1 to 10
                       if al_retorno[l_cont].atddfttxt is not null then
                          let l_problema = l_problema clipped
                                          ,"/"
                                          ,al_retorno[l_cont].atddfttxt
                       end if
                    end for

                    let lr_exibe.problema = l_problema, "@@"

                 #---------------------------------------------
                 #-----------------------------------------
                 # Montar linha para exibicao da natureza
                 #-----------------------------------------

                 let l_espdes = null

                 # --BUSCA A DESCRICAO DA ESPECIALIDADE
                 let l_espdes = wdatc017_busca_especialidade(param.atdsrvnum,
                                                             param.atdsrvano)

                 if l_espdes is not null and
                    l_espdes <> " " then

                    # --INCLUI A ESPECIALIDADE NO MOMENTO DA EXIBICAO
                    let l_natureza =  "PADRAO@@8@@Natureza@@", ws.ntzdes clipped, " - ", l_espdes

                 else
                    let l_natureza =  "PADRAO@@8@@Natureza@@", ws.ntzdes
                 end if

                 for l_cont = 1 to 10
                    if al_retorno[l_cont].socntzdes is not null then

                       let l_espdes = null

                       # --BUSCA A DESCRICAO DA ESPECIALIDADE
                       let l_espdes = wdatc017_busca_especialidade(al_retorno[l_cont].atdmltsrvnum,
                                                                   al_retorno[l_cont].atdmltsrvano)

                       if l_espdes is not null and
                          l_espdes <> " " then
                          # --INCLUI A ESPECIALIDADE NO MOMENTO DA EXIBICAO
                          let l_natureza = l_natureza clipped ,"/",
                              al_retorno[l_cont].socntzdes clipped, " - ",
                              l_espdes
                       else
                          let l_natureza = l_natureza clipped ,"/", al_retorno[l_cont].socntzdes
                       end if

                    end if
                 end for

                 let lr_exibe.natureza = l_natureza, "@@"
                 #--------------------------------------------
                    let lr_exibe.data_ocor =  "PADRAO@@8@@Data ocorrência@@",
                             ws.orrdat,
                             "@@"
                    let lr_exibe.hora_ocor =  "PADRAO@@8@@Hora ocorrência@@",
                             ws.orrhor,
                             "@@"
                else
                #-----------------------------------------
                # Montar linha para exibicao do problema
                #-----------------------------------------
                    let l_problema = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Problema@@@@N@@L@@M@@4@@3@@1@@075%@@"
                                    ,ws.atddfttxt

                    for l_cont = 1 to 10
                       if al_retorno[l_cont].atddfttxt is not null then
                          let l_problema = l_problema clipped
                                          ,"/"
                                          ,al_retorno[l_cont].atddfttxt

                       end if
                    end for

                    let lr_exibe.problema = l_problema, "@@@@"

                #------------------------------------------
                #-----------------------------------------
                # Montar linha para exibicao da natureza
                #-----------------------------------------
                    let l_espdes = null

                    # --BUSCA A DESCRICAO DA ESPECIALIDADE
                    let l_espdes = wdatc017_busca_especialidade(param.atdsrvnum,
                                                                param.atdsrvano)

                    if l_espdes is not null and
                       l_espdes <> " " then

                       # --INCLUI A ESPECIALIDADE NO MOMENTO DA EXIBICAO
                        let l_natureza = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Natureza@@@@N@@L@@M@@4@@3@@1@@075%@@"
                                      ,ws.ntzdes clipped, " - ", l_espdes

                    else
                        let l_natureza = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Natureza@@@@N@@L@@M@@4@@3@@1@@075%@@" ,ws.ntzdes
                    end if

                    for l_cont = 1 to 10
                       if al_retorno[l_cont].socntzdes is not null then

                          let l_espdes = null

                          # --BUSCA A DESCRICAO DA ESPECIALIDADE
                          let l_espdes = wdatc017_busca_especialidade(al_retorno[l_cont].atdmltsrvnum,
                                                                      al_retorno[l_cont].atdmltsrvano)

                          if l_espdes is not null and
                             l_espdes <> " " then
                             # --INCLUI A ESPECIALIDADE NO MOMENTO DA EXIBICAO
                             let l_natureza = l_natureza clipped ,"/",
                                 al_retorno[l_cont].socntzdes clipped, " - ",
                                 l_espdes
                          else
                             let l_natureza = l_natureza clipped ,"/", al_retorno[l_cont].socntzdes
                          end if

                       end if
                    end for

                    let lr_exibe.natureza = l_natureza, "@@@@"
                #-------------------------------------------
                    let lr_exibe.data_ocor =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data ocorrência@@@@N@@L@@M@@4@@3@@1@@075%@@",
                            ws.orrdat,
                            "@@@@"
                    let lr_exibe.hora_ocor =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Hora ocorrência@@@@N@@L@@M@@4@@3@@1@@075%@@",
                            ws.orrhor,
                            "@@@@"
                end if

            end if

        end if

    end if

    #-------------------------------------------------#
    # Se houver serviço original, apresentar          #
    #-------------------------------------------------#
    if ws_orig.atdsrvnum is not null and
       ws_orig.atdsrvano is not null then

        if param.acao <> 2 then
           let lr_exibe.srv_original = "PADRAO@@1@@B@@C@@0@@Serviço original@@"
           let lr_exibe.ordem_srv =  "PADRAO@@6@@2@@N@@L@@0@@1@@29%@@Ordem serviço@@@@N@@L@@1@@1@@71%@@",
                   ws_orig.atdsrvorg using "&&",
                   "/",
                   ws_orig.atdsrvnum using "&&&&&&&",
                   "-",
                   ws_orig.atdsrvano using "&&",
                   "@@wdatc016.pl",
                   "?usrtip=",
                   param.usrtip clipped,
                   "&webusrcod=",
                   param.webusrcod clipped,
                   "&sesnum=",
                   param.sesnum using "<<<<<<<<<&",
                   "&macsissgl=",
                   param.macsissgl clipped,
                   "&atdsrvnum=",
                   ws_orig.atdsrvnum using "&&&&&&&",
                   "&atdsrvano=",
                   ws_orig.atdsrvano using "&&",
                   "&acao=0@@"
           let lr_exibe.orrdat =  "PADRAO@@8@@Data@@",
                   ws_orig.orrdat,
                   " ",
                   ws_orig.orrhor,
                   "@@"
           let lr_exibe.prb_original =  "PADRAO@@8@@Problema@@",
                   ws_orig.atddfttxt clipped,
                   "@@"
           let lr_exibe.ntz_original =  "PADRAO@@8@@Natureza@@",
                   ws_orig.ntzdes clipped,
                   "@@"
        else
           let lr_exibe.srv_original = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Serviço original@@@@"
           let lr_exibe.ordem_srv =   "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ordem serviço@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws_orig.atdsrvorg using "&&",
                   "/",
                   ws_orig.atdsrvnum using "&&&&&&&",
                   "-",
                   ws_orig.atdsrvano using "&&",
                   "@@@@"
           let lr_exibe.orrdat = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws_orig.orrdat,
                   " ",
                   ws_orig.orrhor,
                   "@@@@"
           let lr_exibe.prb_original =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Problema@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws_orig.atddfttxt clipped,
                   "@@@@"
           let lr_exibe.ntz_original =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Natureza@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws_orig.ntzdes clipped,
                   "@@@@"
        end if

    end if

    #-----------------------------------------------------
    # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (DESTINO)
    #-----------------------------------------------------
    if ws.atdsrvorg  =   4  or
       ws.atdsrvorg  =   6  or
       ws.atdsrvorg  =   1  or
       ws.atdsrvorg  =   5  or
       (ws.atdsrvorg  =   2  and ws.asitipcod <> 10) or   ## Para taxi
       ws.atdsrvorg  =   7  then

        if param.acao <> 2 then
            let lr_exibe.local_destino =  "PADRAO@@1@@B@@C@@0@@Local destino@@"
            let lr_exibe.lclidttxt = "PADRAO@@8@@Local@@",
                    a_rrw[2].lclidttxt,
                    "@@"
            let lr_exibe.endereco_dest =  "PADRAO@@8@@Endereço@@",
                    a_rrw[2].lgdtxt,
                    "@@"
            let lr_exibe.bairro_dest =  "PADRAO@@8@@Bairro@@",
                    a_rrw[2].lclbrrnom,
                    "@@"
            let lr_exibe.cidade_dest =  "PADRAO@@8@@Cidade@@",
                    a_rrw[2].cidnom clipped,
                    " - ",
                    a_rrw[2].ufdcod,
                    "@@"
        else
           let lr_exibe.local_destino =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Local destino@@@@"
           let lr_exibe.lclidttxt = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Local@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[2].lclidttxt,
                   "@@@@"
           let lr_exibe.endereco_dest =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Endereço@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[2].lgdtxt,
                   "@@@@"
           let lr_exibe.bairro_dest =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bairro@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[2].lclbrrnom,
                   "@@@@"
           let lr_exibe.cidade_dest = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[2].cidnom clipped,
                   " - ",
                   a_rrw[2].ufdcod,
                   "@@@@"
        end if

        if ws.rmcacpdes is not null  then
            if param.acao <> 2 then
                let lr_exibe.remocao = "PADRAO@@8@@Acompanha remoção@@",
                        ws.rmcacpdes,
                        "@@"
            else
                let lr_exibe.remocao =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Acompanha remoção@@@@N@@L@@M@@4@@3@@1@@075%@@",
                        ws.rmcacpdes,
                        "@@@@"
            end if
        end if

    end if

    #------------------------------------------------
    # PARA ASSISTENCIA PASSAGEIROS - TAXI  (DESTINO)
    #------------------------------------------------

    if ws.atdsrvorg  = 2 or
       ws.atdsrvorg  = 3 then

        select atddmccidnom,
               atddmcufdcod,
               atddstcidnom,
               atddstufdcod,
               asimtvcod,
               bagflg, trppfrdat, trppfrhor, txivlr
          into ws.atddmccidnom,
               ws.atddmcufdcod,
               ws.atddstcidnom,
               ws.atddstufdcod,
               ws.asimtvcod,
               ws.bagflg, ws.trppfrdat, ws.trppfrhor, ws.txivlr
          from datmassistpassag
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano

        let ws.asimtvdes = "NAO CADASTRADO"

        select asimtvdes
          into ws.asimtvdes
          from datkasimtv
         where asimtvcod = ws.asimtvcod

        if ws.ciaempcod = 1 then
           call cts45g00_limites_cob(1,param.atdsrvnum, param.atdsrvano,
                                       ws.succod, ws.aplnumdig, ws.itmnumdig,
                                       ws.asitipcod , ws.ramcod, ws.asimtvcod,
                                       1,0)
               returning l_diaria

           if ws.asimtvcod = 3 then
              let l_msg_lim = "Limite de cobertura restrito ao valor de uma passagem aérea na classe econômica. Qualquer valor excedente deve ser cobrado do segurado."
           else
              if l_diaria > 0 then

                 if ws.asitipcod = 5 then ## taxi
                    let l_msg_lim = "Em caso de viagem devidamente autorizada pela Central de Atendimento, cobrar até o limite de R$ ", l_diaria, " da PORTO SEGURO. Qualquer valor excedente deve ser cobrado do segurado."

                 end if

                 if ws.asitipcod = 10 then ## aviao
                    let l_msg_lim = "Em caso de viagem aérea devidamente autorizada pela Central de Atendimento, cobrar até o limite de R$ ", l_diaria, " da PORTO SEGURO. Qualquer valor excedente deve ser cobrado do segurado."
                 end if

              end if

           end if

        end if

       if param.acao <> 2 then
       
           { # PSI227145
           let lr_exibe.localidades= "PADRAO@@1@@B@@C@@0@@Localidades@@"
           let lr_exibe.domicilio = "PADRAO@@8@@Domicílio@@",
                   ws.atddmccidnom clipped,
                   " - ",
                   ws.atddmcufdcod,
                   "@@"
           let lr_exibe.ocorrencia =  "PADRAO@@8@@Ocorrência@@",
                   a_rrw[1].cidnom clipped,
                   " - ",
                   a_rrw[1].ufdcod,
                   "@@"
           if ws.atdsrvorg  = 3 then
              let lr_exibe.destino =  "PADRAO@@8@@Local@@",
                                      ws.atddstcidnom clipped,
                                   " - ",
                                   ws.atddstufdcod,
                                   "@@"
           else
              let lr_exibe.destino =  "PADRAO@@8@@Destino@@",
                                      ws.atddstcidnom clipped,
                                   " - ",
                                   ws.atddstufdcod,
                                   "@@"
           end if
           }
           
           if ws.trppfrdat is not null then
              let lr_exibe.dt_pref_viagem = 'PADRAO@@8@@Data/Hora preferência viagem@@', ws.trppfrdat, " - ", ws.trppfrhor, "@@"
           end if
           
       else
        
           if l_msg_lim is not null then
              let lr_exibe.msg1 = "PADRAO@@10@@1@@2@@1@@B@@L@@M@@4@@3@@2@@100%@@", l_linha, l_msg_lim clipped, "@@@@"
           end if
           
           { # PSI227145
           let lr_exibe.localidades =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Localidades@@@@"
           let lr_exibe.domicilio = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Domicílio@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   ws.atddmccidnom clipped,
                   " - ",
                   ws.atddmcufdcod,
                   "@@@@"
           let lr_exibe.ocorrencia ="PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ocorrência@@@@N@@L@@M@@4@@3@@1@@075%@@",
                   a_rrw[1].cidnom clipped,
                   " - ",
                   a_rrw[1].ufdcod
                   ###"@@@@"
           if ws.atdsrvorg  = 3 then
              let lr_exibe.destino =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Local@@@@N@@L@@M@@4@@3@@1@@075%@@", ws.atddstcidnom clipped, " - ", ws.atddstufdcod, "@@@@"
           else
              let lr_exibe.destino =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Destino@@@@N@@L@@M@@4@@3@@1@@075%@@", ws.atddstcidnom clipped, " - ", ws.atddstufdcod, "@@@@"
           end if
           }
           if ws.trppfrdat is not null then
              let lr_exibe.dt_pref_viagem = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data/Hora preferência viagem@@@@N@@L@@M@@4@@3@@1@@075%@@", ws.trppfrdat, " - ", ws.trppfrhor, "@@@@"
           end if
           
       end if

        if ws.txivlr is not null then
           if param.acao <> 2 then
                let lr_exibe.taxi = "PADRAO@@8@@Valor Taxi@@", ws.txivlr, "@@"
            else
                let lr_exibe.taxi = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Valor Taxi@@@@N@@L@@M@@4@@3@@1@@075%@@", ws.txivlr, "@@@@"
            end if
        end if

        if ws.bagflg = "S" then
            if param.acao <> 2 then
                let lr_exibe.bagagem = "PADRAO@@8@@Bagagem@@SIM@@"
            else
                let lr_exibe.bagagem = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bagagem@@@@N@@L@@M@@4@@3@@1@@075%@@SIM@@@@"
            end if
        else
            if ws.bagflg = "N" then
               if param.acao <> 2 then
                   let lr_exibe.bagagem = "PADRAO@@8@@Bagagem@@NÃO@@"
               else
                   let lr_exibe.bagagem = "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bagagem@@@@N@@L@@M@@4@@3@@1@@075%@@NÃO@@@@"
               end if
            end if
        end if

        if param.acao <> 2 then
            let lr_exibe.motivo = "PADRAO@@8@@Motivo@@",
                    ws.asimtvdes clipped,
                    "@@"
        else
             let lr_exibe.motivo =  "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Motivo@@@@N@@L@@M@@4@@3@@1@@075%@@",
                    ws.asimtvdes  ### "@@@@"
        end if

        #----------------------------------------------
        # IMPRIME INFORMACOES SOBRE OS PASSAGEIROS
        #----------------------------------------------
        if param.acao <> 2 then
            let lr_exibe.inf_passag =  "PADRAO@@1@@B@@C@@0@@Informações sobre passageiros@@"
        else
            let lr_exibe.inf_passag =  "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Informações sobre passageiros@@@@"
        end if

    end if

    if ws.atdsrvorg = 9 then

       if param.acao <> 2 then
          let lr_exibe.historico = "PADRAO@@1@@B@@C@@0@@Histórico do serviço@@"
       else
          let lr_exibe.historico = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Histórico do Serviço@@@@"
       end if

    end if

    if param.acao <> 2 then

       display "BOTAO@@Aceitar@@wdatc024.pl@@"

       if ws.atdsrvorg = 3 then ## Hospedagem
          if l_atdetpcod = 43 then ## Enviado - aceitar
             display "BOTAO@@Aceitar@@wdatc024.pl@@"
          end if

          if l_atdetpcod = 13 then ## Em cotacao - cotando
             display "BOTAO@@Enviar@@wdatc026.pl@@"
          end if

          if l_atdetpcod = 45 then ## Efetuar reserva - acionando
             display "BOTAO@@Reservar@@wdatc026.pl@@"
          end if
       end if

       if ws.atdsrvorg = 2 and ws.asitipcod = 10 then ## Aviao
          if l_atdetpcod = 43 then ## Enviado - aceitar
             display "BOTAO@@Aceitar@@wdatc024.pl@@"
          end if

          if l_atdetpcod = 13 then ## Em cotacao - cotando
             display "BOTAO@@Cotar@@wdatc076.pl@@"
          end if

          ## Efetuar emissao/reserva - acionando
          if l_atdetpcod = 44 then
             display "BOTAO@@Emitir@@wdatc026.pl@@"
          end if

          if l_atdetpcod = 45 then
             display "BOTAO@@Reservar@@wdatc026.pl@@"
          end if
       end if

    end if

    call wdatc017_exibe_srv(ws.atdsrvorg)

    #------------------------------------
    # ATUALIZA TEMPO DE SESSAO DO USUARIO
    #------------------------------------

    call wdatc003(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl,
                  ws1.*)
        returning ws.sttsess

end main

#-------------------------------------------------#
function wdatc017_busca_especialidade(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvre.atdsrvnum,
         atdsrvano    like datmsrvre.atdsrvano
  end record

  define l_espcod like datmsrvre.espcod,
         l_espdes like dbskesp.espdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize	l_espcod  to  null
	initialize	l_espdes  to  null

  let l_espcod = null
  let l_espdes = null

  # --BUSCA O CODIGO DA ESPECIALIDADE
  select espcod
    into l_espcod
    from datmsrvre
   where atdsrvnum = lr_parametro.atdsrvnum
     and atdsrvano = lr_parametro.atdsrvano

  if sqlca.sqlcode = notfound then
     let l_espcod = null
  end if

  # --SE EXISTIR O CODIGO DA ESPECIALIDADE
  if l_espcod is not null then

     # --BUSCA A DESCRICAO DA ESPECIALIDADE
     let l_espdes = cts31g00_descricao_esp(l_espcod, "")

  end if

  return l_espdes

end function

#--------------------------------------------------
function wdatc017_exibe_srv(l_atdsrvorg)
#---------------------------------------------------

     define l_atdsrvorg like datmservico.atdsrvorg,
            l_passou smallint

     define l_lighorinc  like datmservhist.lighorinc,
            l_ligdat     like datmservhist.ligdat   
  
  
  
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize l_passou  to  null
	initialize l_lighorinc to null
        initialize l_ligdat to null
	

     if l_atdsrvorg = 3 then ##Exibe servicos de Hospedagem

        display lr_exibe.msg1
        display lr_exibe.laudo_srv
        display lr_exibe.tipo_srv
        display lr_exibe.servico
        display lr_exibe.motivo
        display lr_exibe.dt_prg_prv
        display lr_exibe.acionado
        display lr_exibe.veiculo
        display lr_exibe.modelo
        display lr_exibe.ano
        display lr_exibe.placa
        display lr_exibe.cor

        ## nao exibir local hospedagem par segurado hospedado = S
        if lr_hospedagem.hsphotnom is null then
           display lr_exibe.local_ocorrencia
           display lr_exibe.destino
        end if

        display lr_exibe.bagagem
        display lr_exibe.nrdiarias

        if lr_exibe.hotel is null then
           display lr_exibe.nrquartos
        end if

        display lr_exibe.inf_passag
        call wdatc017_exibe_passageiro()

        if lr_exibe.hotel is not null then
           display lr_exibe.inf_hosped
           display lr_exibe.hotel
           display lr_exibe.estado_htl
           display lr_exibe.cidade_htl
           display lr_exibe.bairro_htl
           display lr_exibe.endereco_htl
           display lr_exibe.referencia_htl
           display lr_exibe.contato
           display lr_exibe.telefone_htl
           display lr_exibe.diaria
           display lr_exibe.nrquartos
           display lr_exibe.acomodacao
           display lr_exibe.obs
        end if

     end if

     if l_atdsrvorg = 2 then ## Exibe Assistencia a passageiros

        display lr_exibe.msg1
        display lr_exibe.laudo_srv
        display lr_exibe.tipo_socorro
        display lr_exibe.tipo_taxi
        display lr_exibe.motivo
        display lr_exibe.servico
        display lr_exibe.dt_prg_prv
        display lr_exibe.acionado
        display lr_exibe.bagagem
        display lr_exibe.taxi
        display lr_exibe.dt_pref_viagem

        display lr_exibe.veiculo
        display lr_exibe.modelo
        display lr_exibe.ano
        display lr_exibe.placa
        display lr_exibe.cor
        
        { # PSI227145
        display lr_exibe.localidades
        display lr_exibe.domicilio
        display lr_exibe.ocorrencia
        display lr_exibe.destino
        }
        display lr_exibe.local_ocorrencia
        display lr_exibe.endereco_ocor
        display lr_exibe.bairro_ocor
        display lr_exibe.cidade_ocor
        display lr_exibe.telefone

        if lr_exibe.referencia is not null then
           display lr_exibe.referencia
        else
           if lr_exibe.referencia1 is not null then
              display lr_exibe.referencia1
           end if
           if lr_exibe.referencia2 is not null then
              display lr_exibe.referencia2
           end if
           if lr_exibe.referencia3 is not null then
              display lr_exibe.referencia3
           end if
           if lr_exibe.referencia4 is not null then
              display lr_exibe.referencia4
           end if
           if lr_exibe.referencia5 is not null then
              display lr_exibe.referencia5
           end if
        end if

        display lr_exibe.responsavel

        display lr_exibe.local_destino
        display lr_exibe.endereco_dest
        display lr_exibe.bairro_dest
        display lr_exibe.cidade_dest

        display lr_exibe.inf_passag
        call wdatc017_exibe_passageiro()
        call wdatc017_exibe_passagem_aerea()

     end if

     if l_atdsrvorg = 9 or l_atdsrvorg = 13 then ## Exibe Servico a residencia

        if  g_documento.ramcod = 531 or 
            g_documento.ramcod = 31 then
           display lr_exibe.laudo_srv
        else
           if msg_itau is not null then
              display lr_exibe.msg_sup
           else
              display lr_exibe.laudo_srv 
           end if
        end if 
        display lr_exibe.tipo_srv
        display lr_exibe.servico
        display lr_exibe.tipo_socorro
        display lr_exibe.dt_prg_prv
        display lr_exibe.acionado
        display lr_exibe.mtvret
        display lr_exibe.viatura
        display lr_exibe.socorrista
        display lr_exibe.local_ocorrencia
        display lr_exibe.local
        display lr_exibe.endereco_ocor
        display lr_exibe.bairro_ocor
        display lr_exibe.cidade_ocor
        display lr_exibe.telefone

        if lr_exibe.referencia is not null then
           display lr_exibe.referencia
        else
           if lr_exibe.referencia1 is not null then
              display lr_exibe.referencia1
           end if
           if lr_exibe.referencia2 is not null then
              display lr_exibe.referencia2
           end if
           if lr_exibe.referencia3 is not null then
              display lr_exibe.referencia3
           end if
           if lr_exibe.referencia4 is not null then
              display lr_exibe.referencia4
           end if
           if lr_exibe.referencia5 is not null then
              display lr_exibe.referencia5
           end if
        end if

        display lr_exibe.responsavel
        display lr_exibe.residencia

        display lr_exibe.problema
        display lr_exibe.natureza
        display lr_exibe.data_ocor
        display lr_exibe.hora_ocor
        display lr_exibe.srv_original
        display lr_exibe.ordem_srv
        display lr_exibe.orrdat
        display lr_exibe.orrhor
        display lr_exibe.prb_original
        display lr_exibe.ntz_original
        display lr_exibe.historico

        select lighorinc,ligdat
          into l_lighorinc,l_ligdat
          from datmservhist
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano
           and c24txtseq = (select min(c24txtseq)
                              from datmservhist
                             where atdsrvnum = param.atdsrvnum
                               and atdsrvano = param.atdsrvano)
        declare cwdatc017002 cursor for
                select c24srvdsc, c24txtseq
                  from datmservhist
                 where atdsrvnum = param.atdsrvnum
                   and atdsrvano = param.atdsrvano
                   and lighorinc = l_lighorinc
                   and ligdat = l_ligdat
                   
                   order by 2

        foreach cwdatc017002 into ws.c24srvdsc
                if param.acao <> 2 then
                    display "PADRAO@@1@@N@@L@@1@@", ws.c24srvdsc, "@@"
                else
                    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@", ws.c24srvdsc, "@@@@"
                end if
        end foreach

     end if

     if l_atdsrvorg = 1 or l_atdsrvorg = 4 ## Exibe os servicos de P.S, remocao
        or l_atdsrvorg = 5 or l_atdsrvorg = 6 or l_atdsrvorg = 7
        or l_atdsrvorg = 17 then

        display lr_exibe.msg_sup
        display lr_exibe.srv_apoio
        display lr_exibe.laudo_srv
        display lr_exibe.tipo_srv
        display lr_exibe.servico

        display lr_exibe.tipo_socorro
        display lr_exibe.dt_prg_prv
        display lr_exibe.acionado
        display lr_exibe.viatura
        display lr_exibe.socorrista

        display lr_exibe.veiculo
        display lr_exibe.modelo
        display lr_exibe.ano
        display lr_exibe.placa
        display lr_exibe.cor

        display lr_exibe.local_ocorrencia
        display lr_exibe.local
        display lr_exibe.endereco_ocor
        display lr_exibe.bairro_ocor
        display lr_exibe.cidade_ocor
        display lr_exibe.telefone

        if lr_exibe.referencia is not null then
           display lr_exibe.referencia
        else
           if lr_exibe.referencia1 is not null then
              display lr_exibe.referencia1
           end if
           if lr_exibe.referencia2 is not null then
              display lr_exibe.referencia2
           end if
           if lr_exibe.referencia3 is not null then
              display lr_exibe.referencia3
           end if
           if lr_exibe.referencia4 is not null then
              display lr_exibe.referencia4
           end if
           if lr_exibe.referencia5 is not null then
              display lr_exibe.referencia5
           end if
        end if

        display lr_exibe.responsavel
        display lr_exibe.residencia

        if l_atdsrvorg = 1 or l_atdsrvorg = 4 or l_atdsrvorg = 6 then
           display lr_exibe.problema
           display lr_exibe.rodas
           display lr_exibe.bo
        end if

        if l_atdsrvorg = 5 or l_atdsrvorg = 7 then
           display lr_exibe.rodas
        end if

        if l_atdsrvorg  =   4  or l_atdsrvorg  =   6  or
           l_atdsrvorg  =   1  or l_atdsrvorg  =   5  or
           l_atdsrvorg  =   7  then

           display lr_exibe.local_destino
           display lr_exibe.lclidttxt
           display lr_exibe.endereco_dest
           display lr_exibe.bairro_dest
           display lr_exibe.cidade_dest
           display lr_exibe.remocao

        end if

        declare cwdatc017004 cursor for
         select vclcndlclcod from datrcndlclsrv
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano

        let l_passou = false
        foreach cwdatc017004 into ws.vclcndlclcod

               if l_passou = false then
                  let l_passou = true
                  if param.acao <> 2 then
                     display "PADRAO@@1@@B@@C@@0@@Local/Condições do Veículo@@"
                  else
                     display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Local/Condições do Veículo@@@@"
                  end if
               end if

               call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

               if param.acao <> 2 then
                   display "PADRAO@@1@@N@@L@@1@@", ws.vclcndlcldes, "@@"
               else
                   display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@", ws.vclcndlcldes, "@@@@"
               end if

       end foreach

     end if

end function

function wdatc017_exibe_passageiro()

        declare cwdatc017001 cursor for
         select pasnom,
                pasidd
           from datmpassageiro
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano

        foreach cwdatc017001
           into ws.pasnom,
                ws.pasidd
            if param.acao <> 2 then
                display "PADRAO@@1@@N@@L@@1@@",
                        ws.pasnom,
                        ws.pasidd,
                        "  anos de idade@@"
            else
                display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@",
                        ws.pasnom,
                        ws.pasidd,
                        "  anos de idade@@@@"
            end if
        end foreach

end function

function wdatc017_exibe_passagem_aerea()

   define lr_passagem    record
          voocnxseq      like datmtrppsgaer.voocnxseq,
          arpembcod      like datmtrppsgaer.arpembcod,
          trpaersaidat   like datmtrppsgaer.trpaersaidat,
          trpaersaihor   like datmtrppsgaer.trpaersaihor,
          arpchecod      like datmtrppsgaer.arpchecod,
          trpaerchedat   like datmtrppsgaer.trpaerchedat,
          trpaerchehor   like datmtrppsgaer.trpaerchehor,
          trpaervoonum   like datmtrppsgaer.trpaervoonum,
          trpaerlzdnum   like datmtrppsgaer.trpaerlzdnum,
          trpaerptanum   like datmtrppsgaer.trpaerptanum,
          trpaerempnom   like datmtrppsgaer.trpaerempnom,
          aerciacod      like datmtrppsgaer.aerciacod,
          vooopc         like datmtrppsgaer.vooopc,
          adlpsgvlr      like datmtrppsgaer.adlpsgvlr,
          crnpsgvlr      like datmtrppsgaer.crnpsgvlr,
          totpsgvlr      like datmtrppsgaer.totpsgvlr,
          escvoo         like datmtrppsgaer.escvoo
   end record

   define l_resultado  smallint
   define l_msg        char(70)
   define l_aercianom  like datkciaaer.aercianom
   define l_arpnom_emb like datkaeroporto.arpnom
   define l_cidnom_emb like datkaeroporto.cidnom
   define l_ufdcod_emb like datkaeroporto.ufdcod
   define l_arpnom_che like datkaeroporto.arpnom
   define l_cidnom_che like datkaeroporto.cidnom
   define l_ufdcod_che like datkaeroporto.ufdcod

   define l_vooopc_ant    like datmtrppsgaer.vooopc,
          l_voocnxseq_ant like datmtrppsgaer.voocnxseq,
          l_sql           char(500)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize	l_resultado  to  null
	initialize	l_msg  to  null
	initialize	l_aercianom  to  null
	initialize	l_arpnom_emb  to  null
	initialize	l_cidnom_emb  to  null
	initialize	l_ufdcod_emb  to  null
	initialize	l_arpnom_che  to  null
	initialize	l_cidnom_che  to  null
	initialize	l_ufdcod_che  to  null
	initialize	l_vooopc_ant  to  null
	initialize	l_voocnxseq_ant  to  null
	initialize	l_sql  to  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_passagem.*  to  null

   let l_sql = "select arpnom, cidnom, ufdcod",
             "  from datkaeroporto",
             " where arpcod = ?"

   prepare pdatkaeroporto from l_sql
   declare cdatkaeroporto cursor for pdatkaeroporto

   initialize lr_passagem.* to null
   let l_vooopc_ant = 0
   let l_voocnxseq_ant = 0

   declare cwdatc017003 cursor for
    select voocnxseq, arpembcod, trpaersaidat, trpaersaihor, arpchecod,
           trpaerchedat, trpaerchehor, trpaervoonum, trpaerlzdnum,
           trpaerptanum, trpaerempnom, aerciacod, vooopc, adlpsgvlr,
           crnpsgvlr, totpsgvlr, escvoo
      from datmtrppsgaer
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       order by vooopc, voocnxseq

   foreach cwdatc017003 into lr_passagem.*

      ## Exibir somente o voo escolhido
      if l_atdetpcod = 44 or l_atdetpcod = 45 or   ## Efetuar rsv/ems
         l_atdetpcod = 46 or l_atdetpcod = 47 then
         if lr_passagem.escvoo is null or lr_passagem.escvoo= '' or
            lr_passagem.escvoo = ' ' then
            continue foreach
         end if
      end if

      let l_resultado  = null
      let l_msg = null
      let l_aercianom = null

      call ctc10g00_dados_cia (1, lr_passagem.aerciacod)
           returning l_resultado, l_msg, l_aercianom

      let l_arpnom_emb  = null
      let l_cidnom_emb  = null
      let l_ufdcod_emb  = null

      open cdatkaeroporto using lr_passagem.arpembcod
      fetch cdatkaeroporto into l_arpnom_emb, l_cidnom_emb, l_ufdcod_emb
      close cdatkaeroporto

      let l_arpnom_che  = null
      let l_cidnom_che  = null
      let l_ufdcod_che  = null

      open cdatkaeroporto using lr_passagem.arpchecod
      fetch cdatkaeroporto into l_arpnom_che, l_cidnom_che, l_ufdcod_che
      close cdatkaeroporto

      if l_vooopc_ant <> 0 and
         l_vooopc_ant <> lr_passagem.vooopc  then

         if param.acao <> 2 then
            display "PADRAO@@1@@B@@C@@0@@Opcao@@@@"
         else
            display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Opcao@@@@"
         end if

      end if

      let l_vooopc_ant = lr_passagem.vooopc

      if l_voocnxseq_ant <> 0 and
         l_voocnxseq_ant <> lr_passagem.voocnxseq  and
         lr_passagem.voocnxseq > 1 then

         if param.acao <> 2 then
            display "PADRAO@@1@@B@@C@@0@@Com conexão@@"
         else
            display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Com conexão@@@@"
         end if
      end if

      let l_voocnxseq_ant = lr_passagem.voocnxseq

      if param.acao <> 2 then
         display "PADRAO@@1@@B@@C@@0@@Informações sobre o vôo@@"
      else
         display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Informações sobre o vôo@@@@"
      end if

      if param.acao <> 2 then
         display "PADRAO@@8@@Empresa@@", l_aercianom , "@@"
         display "PADRAO@@8@@No. do Vôo@@", lr_passagem.trpaervoonum , "@@"
         display "PADRAO@@8@@No. do PTA@@", lr_passagem.trpaerptanum , "@@"
         display "PADRAO@@8@@No. do Localizador@@", lr_passagem.trpaerlzdnum , "@@"
         display "PADRAO@@8@@Valor Passagem Adulto@@", lr_passagem.adlpsgvlr , "@@"
         display "PADRAO@@8@@Valor Passagem Criança@@", lr_passagem.crnpsgvlr , "@@"
         display "PADRAO@@8@@Valor Passagem Total@@", lr_passagem.totpsgvlr , "@@"

         display "PADRAO@@1@@B@@C@@0@@Embarque@@"
         display "PADRAO@@8@@Cidade/UF@@", l_cidnom_emb clipped,'/',l_ufdcod_emb , "@@"
         display "PADRAO@@8@@Aeroporto@@", l_arpnom_emb , "@@"
         display "PADRAO@@8@@Data do Embarque@@", lr_passagem.trpaersaidat, "@@"
         display "PADRAO@@8@@Hora do Embarque@@", lr_passagem.trpaersaihor, "@@"

         display "PADRAO@@1@@B@@C@@0@@Chegada@@"
         display "PADRAO@@8@@Cidade/UF@@", l_cidnom_che clipped,'/',l_ufdcod_che , "@@"
         display "PADRAO@@8@@Aeroporto@@", l_arpnom_che , "@@"
         display "PADRAO@@8@@Data da Chegada@@", lr_passagem.trpaerchedat, "@@"
         display "PADRAO@@8@@Hora da Chegada@@", lr_passagem.trpaerchehor, "@@"

      else
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Empresa@@@@N@@L@@M@@4@@3@@1@@075%@@", l_aercianom, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@No. do Vôo@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaervoonum, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@No. do PTA@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaerptanum, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@No. do Localizador@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaerlzdnum, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Valor Passagem Adulto@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.adlpsgvlr, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Valor Passagem Criança@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.crnpsgvlr, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Valor Passagem Total@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.totpsgvlr, "@@@@"

         display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Embarque@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade/UF@@@@N@@L@@M@@4@@3@@1@@075%@@", l_cidnom_emb clipped,'/',l_ufdcod_emb , "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Aeroporto@@@@N@@L@@M@@4@@3@@1@@075%@@", l_arpnom_emb , "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data do Embarque@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaersaidat, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Hora do Embarque@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaersaihor, "@@@@"

         display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Chegada@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade/UF@@@@N@@L@@M@@4@@3@@1@@075%@@", l_cidnom_che clipped,'/',l_ufdcod_che , "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Aeroporto@@@@N@@L@@M@@4@@3@@1@@075%@@", l_arpnom_che , "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data da Chegada@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaerchedat, "@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Hora da Chegada@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_passagem.trpaerchehor, "@@@@"
      end if

   end foreach

end function


#-----------------------------------#
function wdatc017_apoio()           #
#-----------------------------------#

 define l_status    smallint

 define l_srv_apoio char(150)

 initialize l_status to null
 initialize l_srv_apoio to null
   
   ## Verifica se servico e de apoio
    let l_status = cts37g00_existeServicoApoio(param.atdsrvnum,
                                               param.atdsrvano)
    let l_srv_apoio = null

    if l_status = 2 then
       if param.acao <> 2 then
          let l_srv_apoio = "PADRAO@@1@@B@@C@@0@@SERVIÇO TEM APOIO@@"
       else
          let l_srv_apoio = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@SERVIÇO TEM APOIO@@@@"
       end if
    end if

    if l_status = 3 then
       if param.acao <> 2 then
          let l_srv_apoio = "PADRAO@@1@@B@@C@@0@@SERVIÇO DE APOIO@@"
       else
          let l_srv_apoio = "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@SERVIÇO DE APOIO@@@@"
       end if
    end if

  return l_srv_apoio

end function

    
