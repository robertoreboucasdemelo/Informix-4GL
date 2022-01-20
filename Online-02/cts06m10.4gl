#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Ct24h                                               #
# Modulo        : cts06m10.4gl                                        #
# Analista Resp.: Natal/Raji                                          #
# PSI           : 174688                                              #
# Nome Programa : Consulta vistorias a serem realizadas               #
#.....................................................................#
# Desenvolvimento: Meta, Alexson A. Pereira                           #
# Liberacao      : 20/06/2003                                         #
#.....................................................................#
#                                                                     #
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 10/03/2004  Marcio,Meta    PSI183644 Mudar a quantidade de linhas   #
#                            OSF 3340  array e do foreach e colocar   #
#                                      contador na tela.              #
# ----------  -------------- --------- ------------------------------ #
# 26/05/2004  Gustavo,Meta   PSI185043 Acrescentar os campos UF e Ci- #
#                            OSF035912 dade na tela. Os campos nao se-#
#                                      rao obrigatorios.              #
#---------------------------------------------------------------------# 
# 04/06/2004  James,Meta     PSI185426 Incluir a informacao de Certi- #
#                            OSF 36390 ficado de Procedencia para     #
#                                      finalidade = 20 da Marcacao de #
#                                      Vistoria Previa.               #
#---------------------------------------------------------------------#
# 04/11/2004  Carlos, Meta   PSI188824 Incluido campo para vistorias  #
#                                      marcadas pela internet.        #
#---------------------------------------------------------------------#
# 19/05/2005 Robson,Meta     PSI191108  Implementacao do Codigo da Via#
#                                       (emeviacod).                  #
# 20/07/2006 Ligia Mattge    PSI202045  Alteracao no layout           #
#---------------------------------------------------------------------#
# 15/09/2006 Zyon,Porto      PSI203637  Incluido flag Palm sem concl  #
#---------------------------------------------------------------------#
# 01/02/2007 Zyon,Porto      CT 484083  Alterado calc dist p/ padrao  #
#---------------------------------------------------------------------#
# 14/02/2007 Saulo,Meta      AS130087   Migracao para a versao 7.32   #
#---------------------------------------------------------------------#
# 03/03/2008 Zyon,Porto      PSI215767  Incluidos prfhor + horobs     #
#---------------------------------------------------------------------#
# 15/09/2008 Zyon,Porto      PSI227315  Incluido filtro prioridade    #
#                                       Incluida msg utiliz coord     #
#                                       Retirado observacao horario   #
#                                       Acertado pesquisa geo ult vp  #
# 13/08/2009 Sergio Burini   PSI 244236 Inclusão do Sub-Bairro        #
# 02/03/2010 Adriano Santos  PSI 252891 Inclusao do padrao idx 4 e 5  #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_verifica   smallint
define m_erro       smallint
define m_msgcoord   char(40)

#------------------------------------------#
function cts06m10_cria_temp()
#------------------------------------------#
    
    let m_erro = false
    
    whenever error continue
    drop table t_cts06m10
    whenever error stop
    
    whenever error continue
    create temp table t_cts06m10
    (vistoriador   char(05),
     atdsrvnum     dec(10,0),
     atdsrvano     dec(02,0),
     atdlibdat     char(05),
     espera        char(06),
     distancia     decimal(12,2),
     local         char(25),
     pontoref      char(30),
     hist          char(1),
     msgpalm       char(1)) with no log;
    whenever error stop
    
    if sqlca.sqlcode <> 0 then 
        error 'Erro CREATE / Tabela: t_cts06m10 / ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 3
        error 'CTS06M10/cts06m10_cria_temp()'  sleep 2
        let m_erro = true
    end if
    
end function

#-------------------------------------------------------------------------------
function cts06m10_prep()
#-------------------------------------------------------------------------------
    
    define l_sql char(3000)
    
    #----------------------------------------------------
    # Recupera o codigo do socorrista a partir da viatura
    #----------------------------------------------------
    let l_sql = " select datkveiculo.socvclcod      ",
                "   from datkveiculo                ",
                "  where datkveiculo.atdvclsgl  = ? "
    prepare pcts06m10001 from l_sql
    declare ccts06m10001 cursor for pcts06m10001
    
    #----------------------------------------------------
    # Recupera marcacoes de vistoria previa nao acionadas
    #----------------------------------------------------
    let l_sql = " select datmservico.atdsrvnum,  ",
                "        datmservico.atdsrvano,  ",
                "        datmservico.atdlibdat,  ",
                "        datmservico.atdlibhor,  ",
                "        datmservico.atddatprg,  ",
                "        datmservico.atdhorprg,  ",
                "        datmservico.c24opemat,  ",
                "        datmvistoria.prfhor,    ",
                "        datmvistoria.horobs,    ",
                "        datmvistoria.vstdat     ",
                "   from datmservico,            ",
                "        datmvistoria            ",
                "  where datmservico.atdlibflg     = 'S' ",  # Flag de liberado
                "    and datmservico.atdfnlflg     = 'N' ",  # Flag de atendido
                "    and datmservico.atdsrvorg     = 10  ",  # Origem = VP
                "    and datmvistoria.vstdat      >= ?   ",  # Data inicial
                "    and datmvistoria.vstdat      <= ?   ",  # Data final
                "    and datmservico.atdprinvlcod >= ?   ",  # Prioridade inicial
                "    and datmservico.atdprinvlcod <= ?   ",  # Prioridade final
                "    and datmservico.atdsrvnum = datmvistoria.atdsrvnum  ",
                "    and datmservico.atdsrvano = datmvistoria.atdsrvano  ",
                "  order by datmservico.atdlibdat,   ",
                "           datmservico.atdlibhor    "
    prepare pcts06m10002 from l_sql
    declare ccts06m10002 cursor for pcts06m10002
    
    #------------------------------------------------------
    # Recupera o numero da vistoria e a sucursal do servico
    #------------------------------------------------------
    let l_sql = " select datmvistoria.vstnumdig,    ",
                "        datmvistoria.succod        ",
                "   from datmvistoria               ",
                "  where datmvistoria.atdsrvnum = ? ",
                "    and datmvistoria.atdsrvano = ? "
    prepare pcts06m10003 from l_sql
    declare ccts06m10003 cursor for pcts06m10003
    
    #-----------------------------------------------
    # Recupera ultima coordenada enviada pelo pocket
    #-----------------------------------------------
    let l_sql = " select avcmplmexcvst.vstlclltt,       ",
                "        avcmplmexcvst.vstlcllgt        ",
                "   from avcmplmexcvst                  ",
                "  where avcmplmexcvst.plmidtnum = ?    ",
                "    and avcmplmexcvst.vstincdat = ?    ",
                "    and avcmplmexcvst.vstlclltt <> 0   ",
                "    and avcmplmexcvst.vstlcllgt <> 0   ",
                "  order by avcmplmexcvst.vstincdat desc,   ",
                "           avcmplmexcvst.vstinchor desc    "
    prepare pcts06m10004 from l_sql
    declare ccts06m10004 cursor for pcts06m10004
    
    #-----------------------------------
    # Recupera as coordenadas so servico
    #-----------------------------------
    let l_sql = " select datmlcl.lclltt,        ",
                "        datmlcl.lcllgt,        ",
                "        datmlcl.c24lclpdrcod   ",
                "   from datmlcl                ",
                "  where datmlcl.atdsrvnum = ?  ",
                "    and datmlcl.atdsrvano = ?  ",
                "    and datmlcl.c24endtip = 1  "
    prepare pcts06m10005 from l_sql
    declare ccts06m10005 cursor for pcts06m10005
    
    #------------------------------------------
    # Recupera os servicos da tabela temporaria
    #------------------------------------------
    let l_sql = " select t_cts06m10.atdsrvnum,      ",
                "        t_cts06m10.atdsrvano,      ",
                "        t_cts06m10.atdlibdat,      ",
                "        t_cts06m10.espera,         ",
                "        t_cts06m10.distancia,      ",
                "        t_cts06m10.local,          ",
                "        t_cts06m10.pontoref,       ",
                "        t_cts06m10.hist,           ",
                "        t_cts06m10.msgpalm         ",
                "   from t_cts06m10                 ",
                "  order by t_cts06m10.distancia,   ",
                "           t_cts06m10.espera       "
    prepare pcts06m10006 from l_sql
    declare ccts06m10006 cursor for pcts06m10006
    
    #---------------------------------------------
    # Recupera registro de cancelamento do servico
    #---------------------------------------------
    let l_sql = " select datmvstcanc.atdhor         ",
                "   from datmvstcanc                ",
                "  where datmvstcanc.atdsrvnum = ?  ",
                "    and datmvstcanc.atdsrvano = ?  "
    prepare pcts06m10007 from l_sql
    declare ccts06m10007 cursor for pcts06m10007
    
    #-----------------------------------------
    # Exclui os registros da tabela temporaria
    #-----------------------------------------
    let l_sql = "delete from t_cts06m10 "
    prepare pcts06m10008 from l_sql
    
    #---------------------------
    # Recupera a sigla do estado
    #---------------------------
    let l_sql = " select glakest.ufdcod     ",
                "   from glakest            ",
                "  where glakest.ufdcod = ? "
    prepare pcts06m10009 from l_sql
    declare ccts06m10009 cursor for pcts06m10009
    
    #-------------------------------------
    # Inclui registro na tabela temporaria
    #-------------------------------------
    let l_sql = " insert into t_cts06m10 ",
                "  (vistoriador,    ",
                "   atdsrvnum,      ",
                "   atdsrvano,      ",
                "   atdlibdat,      ",
                "   espera,         ",
                "   distancia,      ",
                "   local,          ",
                "   pontoref,       ",
                "   hist,           ",
                "   msgpalm)        ",
                "   values (?,?,?,?,?,?,?,?,?,?) "
    prepare pcts06m10010 from l_sql
    
    #-----------------------------------------------------
    # Recupera o flag de atendimento finalizado do servico
    #-----------------------------------------------------
    let l_sql = " select datmservico.atdfnlflg      ",
                "   from datmservico                ",
                "  where datmservico.atdsrvano = ?  ",
                "    and datmservico.atdsrvnum = ?  "
    prepare pcts06m10011 from l_sql
    declare ccts06m10011 cursor for pcts06m10011
    
    #--------------------------------
    # Recupera o historico do servico
    #--------------------------------
    let l_sql = " select datmservhist.c24txtseq     ",
                "   from datmservhist               ",
                "  where datmservhist.atdsrvnum = ? ",
                "    and datmservhist.atdsrvano = ? "
    prepare pcts06m1012 from l_sql
    declare ccts06m1012 cursor for pcts06m1012
    
    #------------------------------------------------------
    # Verifica se existe conexao Palm pendente de conclusao
    #------------------------------------------------------
    let l_sql = " select avcmplmcnx.plmidtnum        ",
                "   from avcmplmcnx                  ",    
                "  where avcmplmcnx.vstnumdig    = ? ",
                "    and avcmplmcnx.plmcnxincdat = today "
    prepare pcts06m1013 from l_sql
    declare ccts06m1013 cursor for pcts06m1013
    
    #------------------------------------------------
    # Recupera o codigo do pocket a partir da viatura
    #------------------------------------------------
    let l_sql = " select avckplmidt.plmidtnum,      ",
                "        avckplmidt.plmbasltt,      ",
                "        avckplmidt.plmbaslgt       ",
                "   from avckplmidt                 ",
                "  where avckplmidt.atdvclsgl = ?   "
    prepare pcts06m10014 from l_sql
    declare ccts06m10014 cursor for pcts06m10014
    
    
    let l_sql = " select vstnumdig ",
                "   from datmvistoria                ",
                "  where datmvistoria.atdsrvnum  = ? ",
                "    and datmvistoria.atdsrvano  = ? "               
    
    prepare pcts06m10015 from l_sql
    declare ccts06m10015 cursor for pcts06m10015
        
    
    let m_verifica = true
    
#-------------------------------------------------------------------------------
end function
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
function cts06m10()
#-------------------------------------------------------------------------------
    
    define la_aux array[3000] of record
        atdsrvnum   like datmservico.atdsrvnum,
        atdsrvano   like datmservico.atdsrvano,
        vstnumdig   like datmvistoria.vstnumdig
    end record
    
    define la_cts06m10 array[3000] of record
        atdlibdat   char(05),
        espera      char(06),
        distancia   decimal(12,2),
        local       char(25),
        pontoref    char(30),
        hist        char(01),
        msgpalm     char(01)
    end record
    
    define lr_cts06m10 record
        lclidttxt       like datmlcl.lclidttxt,
        lgdtip          like datmlcl.lgdtip,
        lgdnom          like datmlcl.lgdnom,
        lgdnum          like datmlcl.lgdnum,
        lclbrrnom       like datmlcl.lclbrrnom,
        brrnom          like datmlcl.brrnom,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        lclrefptotxt    like datmlcl.lclrefptotxt,
        endzon          like datmlcl.endzon,
        lgdcep          like datmlcl.lgdcep,
        lgdcepcmp       like datmlcl.lgdcepcmp,
        dddcod          like datmlcl.dddcod,
        lcltelnum       like datmlcl.lcltelnum,
        lclcttnom       like datmlcl.lclcttnom,
        c24lclpdrcod    like datmlcl.c24lclpdrcod,
        codigosql       integer
    end record
    
    define lr_ws record
        h24         datetime hour to minute,
        horaatu     datetime hour to minute,
        atdsrvnum   like datmservico.atdsrvnum,
        atdsrvano   like datmservico.atdsrvano,
        atdlibhor   like datmservico.atdlibhor,
        atddatprg   like datmservico.atddatprg,
        atdhorprg   like datmservico.atdhorprg,
        succod      like datmvistoria.succod,
        atdlibdat   char (10),
        lighorinc   char (05),
        c24opemat   like datmservico.c24opemat,
        lockk       char (01),
        hora        char (05),
        retflg      char (01),
        prfhor      like datmvistoria.prfhor,
        horobs      like datmvistoria.horobs
    end record
    
    define lr_cts06g03 record
        lclidttxt       like datmlcl.lclidttxt,
        lgdtip          like datmlcl.lgdtip,
        lgdnom          like datmlcl.lgdnom,
        lgdnum          like datmlcl.lgdnum,
        brrnom          like datmlcl.brrnom,
        lclbrrnom       like datmlcl.lclbrrnom,
        endzon          like datmlcl.endzon,
        cidnom          like datmlcl.cidnom,
        ufdcod          like datmlcl.ufdcod,
        lgdcep          like datmlcl.lgdcep,
        lgdcepcmp       like datmlcl.lgdcepcmp,
        lclltt          like datmlcl.lclltt,
        lcllgt          like datmlcl.lcllgt,
        dddcod          like datmlcl.dddcod,
        lcltelnum       like datmlcl.lcltelnum,
        lclcttnom       like datmlcl.lclcttnom,
        lclrefptotxt    like datmlcl.lclrefptotxt,
        c24lclpdrcod    like datmlcl.c24lclpdrcod,
        lgstxt          char (65),
        ofnnumdig       like sgokofi.ofnnumdig,
        emeviacod       like datmlcl.emeviacod,
        celteldddcod    like datmlcl.celteldddcod,    
        celtelnum       like datmlcl.celtelnum,    
        endcmp          like datmlcl.endcmp                       
    end record
    
    define lr_hist_cts06g03 record
        hist1   like datmservhist.c24srvdsc,
        hist2   like datmservhist.c24srvdsc,
        hist3   like datmservhist.c24srvdsc,
        hist4   like datmservhist.c24srvdsc,
        hist5   like datmservhist.c24srvdsc
    end record
    
    define lr_param record
        lclltt_1        like datmlcl.lclltt,
        lcllgt_1        like datmlcl.lcllgt,
        lclltt_2        like datmlcl.lclltt,
        lcllgt_2        like datmlcl.lcllgt,
        c24lclpdrcod    like datmlcl.c24lclpdrcod
    end record
    
    define l_ws_qtdekm      decimal(12,2)
    define l_arr_aux        smallint
    
    define l_uf             char(02)
    define l_cidade         char(20)
    define l_lclbrrnom      char(65)
    define l_endereco       char(1)
    define l_saida          smallint
    
    define l_ws_privez      smallint
    define l_novapesq       smallint
    
    define l_data_tst       date
    define l_datai          date
    define l_dataf          date
    
    define l_socvclcod      like datkveiculo.socvclcod      # Codigo do Socorrista
    define l_vistoriador    like datkveiculo.atdvclsgl      # Codigo da Viatura
    define l_plmidtnum      like avckplmidt.plmidtnum       # Codigo do Pocket
    define l_plmbasltt      like avckplmidt.plmbasltt       # Latitude  da Base do Pocket
    define l_plmbaslgt      like avckplmidt.plmbaslgt       # Longitude da Base do Pocket
    
    define l_atdfnlflg      like datmservico.atdfnlflg
    define l_atdetpcod      like datmsrvacp.atdetpcod
    
    define l_priini         like datmservico.atdprinvlcod   # Prioridade inicial
    define l_prifin         like datmservico.atdprinvlcod   # Prioridade final
    define l_vstnumdig      like datmvistoria.vstnumdig
    
    let l_arr_aux           = null
    let l_ws_privez         = null
    let l_novapesq          = false
    
    if m_verifica <> true or m_verifica is null then
        call cts06m10_cria_temp()
        if m_erro = true then
            let int_flag = false
            return
        end if
        call cts06m10_prep()
    end if
    
    initialize la_cts06m10 to  null
    
    initialize lr_cts06m10.*        to null
    initialize lr_ws.*              to null
    initialize lr_cts06g03.*        to null
    initialize lr_hist_cts06g03.*   to null
    
    let lr_ws.hora      = current hour to minute
    let l_ws_privez     = true
    let l_saida         = false
    let l_data_tst      = today
    let l_datai         = today
    let l_dataf         = today
    
    let l_uf            = null
    let l_cidade        = null
    let l_vistoriador   = null
    let l_endereco      = null
    
    initialize lr_param.* to null
    
    open window cts06m10 at 03,02 with form "cts06m10" attribute(form line 1)
    
    if l_saida = true then
        let l_saida = false
        let int_flag = false
        close window cts06m10
        return
    end if
    
    while true
        
        let int_flag = false
        
        initialize lr_cts06g03   to null
        initialize la_cts06m10   to null
        initialize lr_ws.*       to null
        initialize g_documento.* to null
        
        clear form
        
        initialize l_vistoriador    to null
        initialize l_uf             to null
        initialize l_cidade         to null
        initialize l_endereco       to null
        
        let l_priini = '1'  # Prioridade inicial
        let l_prifin = '3'  # Prioridade final
        
        input l_vistoriador,
              l_uf,
              l_cidade,
              l_datai,
              l_dataf,
              l_endereco,
              l_priini,
              l_prifin without defaults
         from vistoriador,
              uf,
              cidade,
              datai,
              dataf,
              endereco,
              priini,
              prifin
            
            before field vistoriador
                display l_vistoriador to vistoriador attribute(reverse)
                
            after field vistoriador
                display l_vistoriador to vistoriador
                if l_vistoriador is null then
                    error "Nao foi digitado informacoes para o vistoriador. "
                    next field vistoriador
                end if
                
                #----------------------------------------------------
                # Recupera o codigo do socorrista a partir da viatura
                #----------------------------------------------------
                open ccts06m10001 using l_vistoriador
                whenever error continue
                fetch ccts06m10001 into l_socvclcod
                whenever error stop
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        error "Vistoriador invalido "
                    else
                        error "ERRO em datkveiculo ", sqlca.sqlcode
                        let l_saida = true
                        exit input
                    end if
                    next field vistoriador
                end if
                close ccts06m10001
                
            before field uf
                display l_uf to uf attribute(reverse)
                
            after field uf
                display l_uf to uf
                
                if fgl_lastkey() = fgl_keyval("left") or
                   fgl_lastkey() = fgl_keyval("up") then
                    next field vistoriador
                end if
                
                if l_uf is null then
                    next field cidade
                end if
                
                #---------------------------
                # Recupera a sigla do estado
                #---------------------------
                open ccts06m10009 using l_uf
                whenever error continue
                fetch ccts06m10009
                whenever error stop
                
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        error ' UF invalida, tente novamente '  sleep 2
                        let l_uf = null 
                        next field uf 
                    else
                        error ' CTS06M10/cts06m10()/ ', l_uf   sleep 2
                        let l_saida = true
                        exit input
                    end if
                end if
                
            before field cidade
                display l_cidade to cidade attribute(reverse)
                
            after field cidade
                display l_cidade to cidade
                if l_uf is null and
                   l_cidade is not null then
                    error ' Para informar uma Cidade voce precisa informar a UF ' sleep 2
                    next field uf
                end if
                
            before field datai
                display l_datai to datai attribute(reverse)
                
            after field datai
                display l_datai to datai
                
                if l_datai is null then
                    let l_datai = today
                    next field datai
                end if
                let l_dataf = l_datai
                
            before field dataf
                display l_dataf to dataf attribute(reverse)
                
            after field dataf
                display l_dataf to dataf
                if l_dataf is null then
                    let l_dataf = l_datai
                    next field dataf
                end if
                
            before field endereco
                display l_endereco to endereco attribute(reverse)
                let m_msgcoord = ' '
                display m_msgcoord to msgcoord
                
            after field endereco
                display l_endereco to endereco
                
                if l_endereco is null then
                    let l_endereco = "N"
                    display l_endereco to endereco
                end if
                
                if l_endereco <> "S" then
                    
                    initialize l_plmidtnum  to null
                    initialize l_plmbasltt  to null
                    initialize l_plmbaslgt  to null
                    
                    #------------------------------------------------
                    # Recupera o codigo do pocket a partir da viatura
                    #------------------------------------------------
                    open ccts06m10014 using l_vistoriador
                    whenever error continue
                    fetch ccts06m10014 into l_plmidtnum,
                                            l_plmbasltt,
                                            l_plmbaslgt
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                        if sqlca.sqlcode = notfound then
                            error " Favor digitar o endereco "
                            let l_endereco = "S"
                            display l_endereco to endereco
                            next field endereco
                        else
                            error "ERRO em avckplmidt ",sqlca.sqlcode
                            let l_saida = true
                            exit input
                        end if
                    end if
                    
                    #---------------------------------
                    # Se a pesquisa DEVE ser pela base
                    #---------------------------------
                    if l_endereco = "B" then
                        
                        if l_plmbasltt is not null and
                           l_plmbaslgt is not null then
                            let lr_param.lclltt_1 = l_plmbasltt
                            let lr_param.lcllgt_1 = l_plmbaslgt
                            let m_msgcoord = '[Utilizando coordenadas da base]'
                            display m_msgcoord to msgcoord
                        else
                            error " Favor digitar o endereco "
                            let l_endereco = "S"
                            display l_endereco to endereco
                        end if
                        
                    else
                        
                        #-----------------------------------------------
                        # Recupera ultima coordenada enviada pelo pocket
                        #-----------------------------------------------
                        open ccts06m10004 using l_plmidtnum,
                                                l_data_tst
                        whenever error continue
                        fetch ccts06m10004 into lr_param.lclltt_1,
                                                lr_param.lcllgt_1
                        whenever error stop
                        if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode = notfound then
                                #---------------------------------------------
                                # Se nao encontrou laudo enviado hoje, utiliza
                                # as coordenadas da base do pocket
                                #---------------------------------------------
                                if l_plmbasltt is not null and
                                   l_plmbaslgt is not null then
                                    let lr_param.lclltt_1 = l_plmbasltt
                                    let lr_param.lcllgt_1 = l_plmbaslgt
                                    let m_msgcoord = '[Utilizando coordenadas da base]'
                                    display m_msgcoord to msgcoord
                                else
                                    error " Favor digitar o endereco "
                                    let l_endereco = "S"
                                    display l_endereco to endereco
                                end if
                            else
                                error "ERRO em avcmplmexcvst ",sqlca.sqlcode
                                let l_saida = true
                                exit input
                            end if
                        else
                            let m_msgcoord = '[Utilizando coordenadas ultima vp realizada]'
                            display m_msgcoord to msgcoord
                        end if
                        
                    end if
                    
                    close ccts06m10004
                    
                else
                    
                    let m_msgcoord = ''
                    display m_msgcoord to msgcoord
                    
                end if
                
            before field priini
                display l_priini to priini attribute(reverse)
                
            after field priini
                display l_priini to priini
                if l_priini is null then
                    let l_dataf = '1'
                    next field priini
                end if
                
            before field prifin
                display l_prifin to prifin attribute(reverse)
                
            after field prifin
                display l_prifin to prifin
                if l_prifin is null then
                    let l_prifin = '3'
                    next field prifin
                end if
                
        end input
        
        if int_flag then
            exit while
        end if
        
        while true
            
            initialize lr_cts06g03   to null
            initialize la_cts06m10   to null
            initialize lr_ws.*       to null
            initialize g_documento.* to null
            
            #-----------------------------------------
            # Exclui os registros da tabela temporaria
            #-----------------------------------------
            whenever error continue
            execute pcts06m10008
            whenever error stop
            if sqlca.sqlcode <> 0 then 
                error 'Erro DELETE t_cts06m10 ',sqlca.sqlcode,"|",sqlca.sqlerrd[2] sleep 1
                exit while
            end if
            
            let int_flag       = false
            let lr_ws.horaatu  = current hour to minute
            let l_arr_aux      = 1
            
            message " Aguarde, pesquisando..."  attribute(reverse)
            
            if l_endereco = "S" or l_endereco = "s" then
                
                call cts06g03(1,
                              0,
                              1,
                              today,
                              lr_ws.hora,
                              lr_cts06g03.lclidttxt,
                              lr_cts06g03.cidnom,
                              lr_cts06g03.ufdcod,
                              lr_cts06g03.brrnom,
                              lr_cts06g03.lclbrrnom,
                              lr_cts06g03.endzon,
                              lr_cts06g03.lgdtip,
                              lr_cts06g03.lgdnom,
                              lr_cts06g03.lgdnum,
                              lr_cts06g03.lgdcep,
                              lr_cts06g03.lgdcepcmp,
                              lr_cts06g03.lclltt,
                              lr_cts06g03.lcllgt,
                              lr_cts06g03.lclrefptotxt,
                              lr_cts06g03.lclcttnom,
                              lr_cts06g03.dddcod,
                              lr_cts06g03.lcltelnum,
                              lr_cts06g03.c24lclpdrcod,
                              lr_cts06g03.ofnnumdig,
                              lr_cts06g03.celteldddcod,    
                              lr_cts06g03.celtelnum,    
                              lr_cts06g03.endcmp,           
                              lr_hist_cts06g03.hist1,
                              lr_hist_cts06g03.hist2,
                              lr_hist_cts06g03.hist3,
                              lr_hist_cts06g03.hist4,
                              lr_hist_cts06g03.hist5,
                              lr_cts06g03.emeviacod)
                    returning lr_cts06g03.lclidttxt,
                              lr_cts06g03.cidnom,
                              lr_cts06g03.ufdcod,
                              lr_cts06g03.brrnom,
                              lr_cts06g03.lclbrrnom,
                              lr_cts06g03.endzon,
                              lr_cts06g03.lgdtip,
                              lr_cts06g03.lgdnom,
                              lr_cts06g03.lgdnum,
                              lr_cts06g03.lgdcep,
                              lr_cts06g03.lgdcepcmp,
                              lr_cts06g03.lclltt,
                              lr_cts06g03.lcllgt,
                              lr_cts06g03.lclrefptotxt,
                              lr_cts06g03.lclcttnom,
                              lr_cts06g03.dddcod,
                              lr_cts06g03.lcltelnum,
                              lr_cts06g03.c24lclpdrcod,
                              lr_cts06g03.ofnnumdig,
                              lr_cts06g03.celteldddcod,    
                              lr_cts06g03.celtelnum,    
                              lr_cts06g03.endcmp,                                        
                              lr_ws.retflg,
                              lr_hist_cts06g03.hist1,
                              lr_hist_cts06g03.hist2,
                              lr_hist_cts06g03.hist3,
                              lr_hist_cts06g03.hist4,
                              lr_hist_cts06g03.hist5,
                              lr_cts06g03.emeviacod
                              
                let lr_param.lclltt_1 = lr_cts06g03.lclltt
                let lr_param.lcllgt_1 = lr_cts06g03.lcllgt
                
                let m_msgcoord = '[Utilizando coordenadas end informado]'
                display m_msgcoord to msgcoord
                
            end if
            
            if int_flag then
                exit while
            end if
            
            #----------------------------------------------------
            # Recupera marcacoes de vistoria previa nao acionadas
            #----------------------------------------------------
            open ccts06m10002 using l_datai,    # Data inicial
                                    l_dataf,    # Data final
                                    l_priini,   # Prioridade inicial
                                    l_prifin    # Prioridade final
            
            foreach ccts06m10002 into lr_ws.atdsrvnum,
                                      lr_ws.atdsrvano,
                                      lr_ws.atdlibdat,
                                      lr_ws.atdlibhor,
                                      lr_ws.atddatprg,
                                      lr_ws.atdhorprg,
                                      lr_ws.c24opemat,
                                      lr_ws.prfhor,
                                      lr_ws.horobs
                
                if lr_ws.c24opemat is null then
                    let lr_ws.lockk  = "-"  # Nao esta sendo acionado
                else
                    let lr_ws.lockk  = "*"  # Ja esta sendo acionado
                end if
                
                #-----------------------------------
                # Recupera as coordenadas so servico
                #-----------------------------------
                whenever error continue
                open ccts06m10005 using lr_ws.atdsrvnum,
                                        lr_ws.atdsrvano
                fetch ccts06m10005 into lr_param.lclltt_2,
                                        lr_param.lcllgt_2,
                                        lr_param.c24lclpdrcod
                
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        let lr_param.lclltt_2     = null
                        let lr_param.lcllgt_2     = null
                        let lr_param.c24lclpdrcod = null
                    else
                        error "ERRO NO ACESSO A TABELA datmlcl ", sqlca.sqlcode
                        let l_saida = true
                        exit foreach
                    end if
                end if
                
                whenever error stop
                close ccts06m10005
                
                #----------------------------------------------------
                # Calcula a distancia entre o vistoriador e o servico
                #----------------------------------------------------
                if lr_param.lclltt_1  <> 0       and
                   lr_param.lclltt_1 is not null and
                   lr_param.lclltt_2  <> 0       and
                   lr_param.lclltt_2 is not null and
                   (lr_param.c24lclpdrcod = 03   or
                    lr_param.c24lclpdrcod = 04   or   # PSI 252891
                    lr_param.c24lclpdrcod = 05)  then # CT 484083
                    
                    call cts18g00(lr_param.lclltt_1,
                                  lr_param.lcllgt_1,
                                  lr_param.lclltt_2,
                                  lr_param.lcllgt_2)
                        returning l_ws_qtdekm
                else
                    let l_ws_qtdekm = 0
                end if
                
                let la_cts06m10[l_arr_aux].distancia = l_ws_qtdekm
                
                #------------------------------------------------------
                # Recupera o numero da vistoria e a sucursal do servico
                #------------------------------------------------------
                whenever error continue
                open ccts06m10003 using lr_ws.atdsrvnum,
                                        lr_ws.atdsrvano
                fetch ccts06m10003 into la_aux[l_arr_aux].vstnumdig,
                                        lr_ws.succod
                
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        let la_aux[l_arr_aux].vstnumdig = null
                        let lr_ws.succod    = null
                    else
                        error "ERRO NO ACESSO A TABELA datmvistoria ", sqlca.sqlcode
                        let l_saida = true
                        exit foreach
                    end if
                end if
                
                whenever error stop
                close ccts06m10003
                
                let lr_ws.lighorinc = null
                
                #---------------------------------------------
                # Recupera registro de cancelamento do servico
                #---------------------------------------------
                whenever error continue
                open ccts06m10007 using lr_ws.atdsrvnum,
                                        lr_ws.atdsrvano
                fetch ccts06m10007 into lr_ws.lighorinc
                
                if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = notfound then
                        let lr_ws.lighorinc = null
                    else
                        error "ERRO NO ACESSO A TABELA datmvstcanc ", sqlca.sqlcode
                        let l_saida = true
                        exit foreach
                    end if
                else
                    continue foreach
                end if
                
                whenever error stop
                close ccts06m10007
                
                let la_cts06m10[l_arr_aux].atdlibdat = lr_ws.atdlibdat[1,5]
                
                call ctx04g00_local_prepare(lr_ws.atdsrvnum,
                                            lr_ws.atdsrvano,
                                            1,
                                            l_ws_privez)
                                  returning lr_cts06m10.lclidttxt,
                                            lr_cts06m10.lgdtip,
                                            lr_cts06m10.lgdnom,
                                            lr_cts06m10.lgdnum,
                                            lr_cts06m10.lclbrrnom,
                                            lr_cts06m10.brrnom,
                                            lr_cts06m10.cidnom,
                                            lr_cts06m10.ufdcod,
                                            lr_cts06m10.lclrefptotxt,
                                            lr_cts06m10.endzon,
                                            lr_cts06m10.lgdcep,
                                            lr_cts06m10.lgdcepcmp,
                                            lr_cts06m10.dddcod,
                                            lr_cts06m10.lcltelnum,
                                            lr_cts06m10.lclcttnom,
                                            lr_cts06m10.c24lclpdrcod,
                                            lr_cts06m10.codigosql
                
                if lr_cts06m10.codigosql < 0  then
                    error " Erro (", lr_cts06m10.codigosql using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
                    let l_saida = true
                    exit while
                end if
                
                if l_ws_privez = true  then
                    let l_ws_privez = false
                end if
                
                if l_uf is not null and
                   l_uf <> ' '      then
                    if l_uf <> lr_cts06m10.ufdcod then
                        continue foreach
                    end if
                    if l_cidade is not null and
                       l_cidade <> ' '      then
                        if l_cidade <> lr_cts06m10.cidnom then
                            continue foreach
                        end if
                    end if
                end if
                
                let l_lclbrrnom = lr_cts06m10.lclbrrnom
                
                # PSI 244589 - Inclusão de Sub-Bairro - Burini
                call cts06g10_monta_brr_subbrr(lr_cts06m10.brrnom,
                                               lr_cts06m10.lclbrrnom)
                     returning lr_cts06m10.lclbrrnom 

                let la_cts06m10[l_arr_aux].local = lr_cts06m10.lclbrrnom clipped, " ",
                                                   lr_cts06m10.cidnom    clipped, " ",
                                                   lr_cts06m10.ufdcod    clipped
                                                   
                let lr_cts06m10.lclbrrnom = l_lclbrrnom 

                let la_cts06m10[l_arr_aux].pontoref = lr_ws.prfhor clipped
                
                #------------------------
                # Calcula Tempo de Espera
                #------------------------
                if lr_ws.atddatprg is null  or
                   lr_ws.atddatprg <= today then
                    if lr_ws.atdhorprg is null then
                        if lr_ws.atdlibdat = today then
                            let la_cts06m10[l_arr_aux].espera = lr_ws.horaatu - lr_ws.atdlibhor
                        else
                            let lr_ws.h24                     =  "23:59"
                            let la_cts06m10[l_arr_aux].espera = lr_ws.h24 - lr_ws.atdlibhor
                            let lr_ws.h24                     =  "00:00"
                            let la_cts06m10[l_arr_aux].espera =
                            la_cts06m10[l_arr_aux].espera + (lr_ws.horaatu - lr_ws.h24) + "00:01"
                        end if
                    else
                        if lr_ws.atddatprg = today    and
                           lr_ws.atdhorprg <> "00:00" then
                            let la_cts06m10[l_arr_aux].espera = lr_ws.horaatu - lr_ws.atdhorprg
                        end if
                    end if
                end if
                
                #--------------------------------------------
                # Sinaliza vistoria ja enviada para um pocket
                #--------------------------------------------
                let la_cts06m10[l_arr_aux].msgpalm = " "
                #call cts10g04_ultima_etapa(lr_ws.atdsrvnum,
                #                           lr_ws.atdsrvano)
                #                 returning l_atdetpcod
                #if l_atdetpcod is null or
                #   l_atdetpcod <> 4 then
                    whenever error continue 
                    open ccts06m10015 using lr_ws.atdsrvnum,
                                           lr_ws.atdsrvano
                    fetch ccts06m10015 into l_vstnumdig
                    
                    if sqlca.sqlcode = 0 then 
                    
                       open ccts06m1013 using l_vstnumdig                     
                       fetch ccts06m1013 into l_plmidtnum                                        
                       if sqlca.sqlcode = 0 then
                           let la_cts06m10[l_arr_aux].msgpalm = "P"
                       end if
                    end if 
                    whenever error stop
                #end if
                
                #-------------------------------------
                # Inclui registro na tabela temporaria
                #-------------------------------------
                whenever error continue
                execute pcts06m10010 using l_vistoriador,
                                           lr_ws.atdsrvnum,
                                           lr_ws.atdsrvano,
                                           la_cts06m10[l_arr_aux].atdlibdat,
                                           la_cts06m10[l_arr_aux].espera,
                                           la_cts06m10[l_arr_aux].distancia,
                                           la_cts06m10[l_arr_aux].local,
                                           la_cts06m10[l_arr_aux].pontoref,
                                           la_cts06m10[l_arr_aux].hist,
                                           la_cts06m10[l_arr_aux].msgpalm
                whenever error stop
                if sqlca.sqlcode <> 0 then
                    error 'Erro INSERT pcts06m10010: ' , sqlca.sqlcode sleep 3
                    let l_saida = true
                    exit foreach
                end if
                
                let l_arr_aux = l_arr_aux + 1
                
                if l_arr_aux > 3000 then
                    error " Limite excedido, tabela de servicos com mais de 3000 itens ! "
                    exit foreach
                end if
                
            end foreach
            
            if l_saida = true then
                exit while
            end if
            
            while true
                
                initialize la_cts06m10  to null
                let l_arr_aux = 1
                
                #------------------------------------------
                # Recupera os servicos da tabela temporaria
                #------------------------------------------
                open ccts06m10006
                foreach ccts06m10006 into la_aux[l_arr_aux].atdsrvnum,
                                          la_aux[l_arr_aux].atdsrvano,
                                          la_cts06m10[l_arr_aux].atdlibdat,
                                          la_cts06m10[l_arr_aux].espera,
                                          la_cts06m10[l_arr_aux].distancia,
                                          la_cts06m10[l_arr_aux].local,
                                          la_cts06m10[l_arr_aux].pontoref,
                                          la_cts06m10[l_arr_aux].hist,
                                          la_cts06m10[l_arr_aux].msgpalm
                    
                    #-----------------------------------------------------
                    # Recupera o flag de atendimento finalizado do servico
                    #-----------------------------------------------------
                    initialize l_atdfnlflg to null
                    whenever error continue
                    open ccts06m10011 using la_aux[l_arr_aux].atdsrvano,
                                            la_aux[l_arr_aux].atdsrvnum
                    fetch ccts06m10011 into l_atdfnlflg
                    whenever error stop
                    if l_atdfnlflg = "S" then
                        continue foreach
                    end if
                    
                    let la_cts06m10[l_arr_aux].hist = "N"
                    
                    #--------------------------------
                    # Recupera o historico do servico
                    #--------------------------------
                    open ccts06m1012 using la_aux[l_arr_aux].atdsrvnum,
                                           la_aux[l_arr_aux].atdsrvano
                    fetch ccts06m1012
                    if sqlca.sqlcode = 0 then
                        let la_cts06m10[l_arr_aux].hist = "S"
                    end if
                    
                    let l_arr_aux = l_arr_aux + 1
                    
                    if l_arr_aux > 3000 then
                        error " Limite excedido, tabela de servicos com mais de 3000 itens ! "
                        exit foreach
                    end if
                    
                end foreach
                
                if l_arr_aux = 1 then
                    error " Nao existem vistorias pendentes!"
                end if
                
                display l_vistoriador to vistoriador
                call set_count(l_arr_aux-1)
                let l_arr_aux = l_arr_aux - 1
                
                message "(F17)Abandona (F5)Historico (F6)Nova consulta (F8)Laudo Total Vistorias: ", l_arr_aux using "&&&&"
                
                display array la_cts06m10 to s_cts06m10.*
                    
                    on key (interrupt,control-c)
                        let int_flag = true
                        exit display
                    
                    on key (F5)
                        let l_arr_aux = arr_curr()
                        call cts06n01(la_aux[l_arr_aux].atdsrvnum,
                                      la_aux[l_arr_aux].atdsrvano,
                                      la_aux[l_arr_aux].vstnumdig,
                                      g_issk.funmat,
                                      l_data_tst,
                                      lr_ws.hora)
                    
                    #--------------
                    # Nova Consulta
                    #--------------
                    on key (F6)
                        let l_novapesq = true
                        exit display
                    
                    #------------------
                    # Laudos de Servico
                    #------------------
                    on key (F8)
                        let l_arr_aux = arr_curr()
                        let g_documento.atdsrvorg = 10
                        let g_documento.atdsrvnum = la_aux[l_arr_aux].atdsrvnum
                        let g_documento.atdsrvano = la_aux[l_arr_aux].atdsrvano
                        let g_documento.solnom    = l_vistoriador
                        
                        #------------------------------------------------------
                        # Recupera o numero da vistoria e a sucursal do servico
                        #------------------------------------------------------
                        open ccts06m10003 using g_documento.atdsrvnum,
                                                g_documento.atdsrvano
                        fetch ccts06m10003 into la_aux[l_arr_aux].vstnumdig,
                                                lr_ws.succod
                        if sqlca.sqlcode = notfound  then
                            error " Vistoria nao encontrada. AVISE A INFORMATICA!"
                        else
                            error " Selecione e tecle ENTER!"
                            call cts06m00("N",la_aux[l_arr_aux].vstnumdig,"","")
                        end if
                        close ccts06m10003
                        error ""
                        exit display
                        
                end display
                
                if int_flag then
                    exit while
                end if
                
                if l_novapesq then
                    exit while
                end if
                
            end while
            
            if int_flag then
                exit while
            end if
            
        end while
        
    end while
    
    let g_documento.solnom = l_vistoriador
    
    if l_saida = true then
        let l_saida = false
        close window cts06m10
        return
    end if
    
    initialize g_documento.* to null
    let int_flag = false
    close window cts06m10
    
#-------------------------------------------------------------------------------
end function
#-------------------------------------------------------------------------------

