#############################################################################
# Nome do Modulo: CTS11M10                                         Ruiz     #
#                                                                  Sergio   #
# Laudo para assistencia a passageiros - transporte - Azul Seguros Dez/2006 #
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/12/2006  psi205206    Sergio       laudo de assitencia para Azul.      #
#---------------------------------------------------------------------------#
# 20/08/2008  Carla Rampazzo            Para os casos de Clausula 037 com o #
#                                       Plano Plus II substituir a msg :    #
#                                       "CAPACIDADE OFICIAL DE LOTACAO..."  #
#                                       pelo valor do Limite que consta na  #
#                                       Apolice                             #
#---------------------------------------------------------------------------# 
# 13/08/2009 Sergio Burini  PSI 244236  Inclusão do Sub-Dairro              #
#---------------------------------------------------------------------------#
# 21/11/2009 Carla Rampazzo             Tratar novas Clausulas:             #
#                                       37A : Assist.24h - Rede Referenciada#
#                                       37B : Assist.24h - Livre Escolha    #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                    Projeto sucursal smallint           #
#---------------------------------------------------------------------------#
# 05/02/2010 Carla Rampazzo PSI 253596  Tratar nova Clausula:               #
#                                       37C : Assist.24h - Assit.Gratuita   #
#---------------------------------------------------------------------------#
# 12/09/2012 Fornax-Hamilton PSI-2012-16125/EV - Inclusao da tratativa das  #
#                                                clausulas 37D e 37F        #
#---------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW    #
#---------------------------------------------------------------------------#
# 17/05/2015  RobertoFornax                    Mercosul                     #
#---------------------------------------------------------------------------#
# 10/12/2015  Luiz   Fornax  CT 768820         CoreDump                     #
#---------------------------------------------------------------------------#


database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_cts11m10 record
                        servico       char (13)                         ,
                        c24solnom     like datmligacao.c24solnom        ,
                        nom           like datmservico.nom              ,
                        doctxt        char (32)                         ,
                        corsus        char (06)                         ,
                        cornom        like datmservico.cornom           ,
                        cvnnom        char (19)                         ,
                        vclcoddig     like datmservico.vclcoddig        ,
                        vcldes        like datmservico.vcldes           ,
                        vclanomdl     like datmservico.vclanomdl        ,
                        vcllicnum     like datmservico.vcllicnum        ,
                        vclcordes     char (11)                         ,
                        asitipcod     like datmservico.asitipcod        ,
                        asitipabvdes  like datkasitip.asitipabvdes      ,
                        asimtvcod     like datkasimtv.asimtvcod         ,
                        asimtvdes     like datkasimtv.asimtvdes         ,
                        refatdsrvorg  like datmservico.atdsrvorg        ,
                        refatdsrvnum  like datmassistpassag.refatdsrvnum,
                        refatdsrvano  like datmassistpassag.refatdsrvano,
                        bagflg        like datmassistpassag.bagflg      ,
                        dstlcl        like datmlcl.lclidttxt            ,
                        dstlgdtxt     char (65)                         ,
                        dstbrrnom     like datmlcl.lclbrrnom            ,
                        dstcidnom     like datmlcl.cidnom               ,
                        dstufdcod     like datmlcl.ufdcod               ,
                        imdsrvflg     char (01)                         ,
                        atdprinvlcod  like datmservico.atdprinvlcod     ,
                        atdprinvldes  char (06)                         ,
                        atdlibflg     like datmservico.atdlibflg        ,
                        prslocflg     char (01)                         ,
                        frmflg        char (01)                         ,
                        atdtxt        char (48)                         ,
                        atdlibdat     like datmservico.atdlibdat        ,
                        atdlibhor     like datmservico.atdlibhor        ,
                        prsloccab        char (11)
                    end record

 define w_cts11m10 record
                      atdsrvnum        like datmservico.atdsrvnum   ,
                      atdsrvano        like datmservico.atdsrvano   ,
                      vclcorcod        like datmservico.vclcorcod   ,
                      lignum           like datrligsrv.lignum       ,
                      atdhorpvt        like datmservico.atdhorpvt   ,
                      atdpvtretflg     like datmservico.atdpvtretflg,
                      atddatprg        like datmservico.atddatprg   ,
                      atdhorprg        like datmservico.atdhorprg   ,
                      atdlibflg        like datmservico.atdlibflg   ,
                      antlibflg        like datmservico.atdlibflg   ,
                      atdlibdat        like datmservico.atdlibdat   ,
                      atdlibhor        like datmservico.atdlibhor   ,
                      atddat           like datmservico.atddat      ,
                      atdhor           like datmservico.atdhor      ,
                      cnldat           like datmservico.cnldat      ,
                      atdfnlhor        like datmservico.atdfnlhor   ,
                      atdfnlflg        like datmservico.atdfnlflg   ,
                      atdetpcod        like datmsrvacp.atdetpcod    ,
                      atdprscod        like datmservico.atdprscod   ,
                      c24opemat        like datmservico.c24opemat   ,
                      c24nomctt        like datmservico.c24nomctt   ,
                      atdcstvlr        like datmservico.atdcstvlr   ,
                      ligcvntip        like datmligacao.ligcvntip   ,
                      data             like datmservico.atddat      ,
                      hora             like datmservico.atdhor      ,
                      funmat           like datmservico.funmat      ,
                      trppfrdat        like datmassistpassag.trppfrdat,
                      trppfrhor        like datmassistpassag.trppfrhor,
                      atddmccidnom     like datmassistpassag.atddmccidnom,
                      atddmcufdcod     like datmassistpassag.atddmcufdcod,
                      atdocrcidnom     like datmlcl.cidnom,
                      atdocrufdcod     like datmlcl.ufdcod,
                      atddstcidnom     like datmassistpassag.atddstcidnom,
                      atddstufdcod     like datmassistpassag.atddstufdcod,
                      operacao         char (01),
                      atdvclsgl        like datmsrvacp.atdvclsgl,
                      srrcoddig        like datmsrvacp.srrcoddig,
                      socvclcod        like datmservico.socvclcod,
                      atdrsdflg        like datmservico.atdrsdflg
                  end record

 define mr_segurado record
                        nome        char(60),
                        cgccpf      char(20),
                        pessoa      char(01),
                        dddfone     char(04),
                        numfone     char(15),
                        email       char(100)
                    end record

 define mr_corretor record
                        susep       char(06),
                        nome        char(50),
                        dddfone     char(04),
                        numfone     char(15),
                        dddfax      char(04),
                        numfax      char(15),
                        email       char(100)
                    end record

 define mr_veiculo  record
                        codigo      char(10),
                        marca       char(30),
                        tipo        char(30),
                        modelo      char(30),
                        chassi      char(20),
                        placa       char(07),
                        anofab      char(04),
                        anomod      char(04),
                        catgtar     char(10),
                        automatico  char(03)
                    end record

 define mr_seg_end record
                       endlgdtip like gsakend.endlgdtip,
                       endlgd    like gsakend.endlgd,
                       endnum    like gsakend.endnum,
                       endcmp    like gsakend.endcmp,
                       endbrr    like gsakend.endbrr,
                       endcep    like gsakend.endcep
                   end record

 define mr_parametro record
                         succod       like datrligapol.succod,
                         ramcod       like datrservapol.ramcod,
                         aplnumdig    like datrligapol.aplnumdig,
                         itmnumdig    like datrligapol.itmnumdig,
                         edsnumref    like datrligapol.edsnumref,
                         prporg       like datrligprp.prporg,
                         prpnumdig    like datrligprp.prpnumdig,
                         ligcvntip    like datmligacao.ligcvntip
                     end record

 define a_passag array[15] of record
                                  pasnom like datmpassageiro.pasnom,
                                   pasidd like datmpassageiro.pasidd
                              end record

 define a_cts11m10   array[3] of record
                                 operacao         char (01)                    ,
                                 lclidttxt        like datmlcl.lclidttxt       ,
                                 lgdtxt           char (65)                    ,
                                 lgdtip           like datmlcl.lgdtip          ,
                                 lgdnom           like datmlcl.lgdnom          ,
                                 lgdnum           like datmlcl.lgdnum          ,
                                 brrnom           like datmlcl.brrnom          ,
                                 lclbrrnom        like datmlcl.lclbrrnom       ,
                                 endzon           like datmlcl.endzon          ,
                                 cidnom           like datmlcl.cidnom          ,
                                 ufdcod           like datmlcl.ufdcod          ,
                                 lgdcep           like datmlcl.lgdcep          ,
                                 lgdcepcmp        like datmlcl.lgdcepcmp       ,
                                 lclltt           like datmlcl.lclltt          ,
                                 lcllgt           like datmlcl.lcllgt          ,
                                 dddcod           like datmlcl.dddcod          ,
                                 lcltelnum        like datmlcl.lcltelnum       ,
                                 lclcttnom        like datmlcl.lclcttnom       ,
                                 lclrefptotxt     like datmlcl.lclrefptotxt    ,
                                 c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
                                 ofnnumdig        like sgokofi.ofnnumdig       ,
                                 emeviacod        like datmlcl.emeviacod       ,
                                 celteldddcod     like datmlcl.celteldddcod    ,
                                 celtelnum        like datmlcl.celtelnum       ,
                                 endcmp           like datmlcl.endcmp
                             end record

 define a_cts11m10_bkp  array[1] of record
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
 
 define m_hist_cts11m10_bkp   record
        hist1         like datmservhist.c24srvdsc,
        hist2         like datmservhist.c24srvdsc,
        hist3         like datmservhist.c24srvdsc,
        hist4         like datmservhist.c24srvdsc,
        hist5         like datmservhist.c24srvdsc
 end record
 
 define m_prep_sql     smallint,
        m_srv_acionado smallint,
        aux_today      char (10),
        aux_hora       char (05),
        aux_ano        char (02),
        m_aciona       smallint,
        ws_cgccpfnum   like aeikcdt.cgccpfnum,
        ws_cgccpfdig   like aeikcdt.cgccpfdig,
        arr_aux        smallint,
        w_retorno      smallint,
        l_doc_handle   integer

 define m_mdtcod          like datmmdtmsg.mdtcod
 define m_pstcoddig       like dpaksocor.pstcoddig
 define m_socvclcod       like datkveiculo.socvclcod
 define m_srrcoddig       like datksrr.srrcoddig
 define l_vclcordes			  char(20)
 define l_msgaltend	      char(1500)
 define l_texto 		      char(200)
 define l_dtalt			      date
 define l_hralt		        datetime hour to minute
 define l_lgdtxtcl	      char(80)
 define l_ciaempnom       char(50)
 define l_codrtgps        smallint
 define l_msgrtgps        char(100)

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint,
        m_grava_hist  smallint

 # PSI-2013-00440PR
 define m_rsrchv       char(25)   # Chave de reserva regulacao
      , m_rsrchvant    char(25)   # Chave de reserva regulacao, anterior a situacao atual(A
      , m_altcidufd    smallint   # Alterou info de cidade/UF (true / false)
      , m_altdathor    smallint   # Alterou data/hora (true / false)
      , m_operacao     smallint
      , m_cidnom       like datmlcl.cidnom        # Nome cidade originalmente informada no servico
      , m_ufdcod       like datmlcl.ufdcod        # Codigo UF originalmente informado no servico
      , m_agncotdat    date                       # Data da cota atual AW (slot)
      , m_agncothor    datetime hour to second    # Hora da cota atual AW (slot)
      , m_agncotdatant date                       # Data da cota atual AW (slot)
      , m_agncothorant datetime hour to second    # Hora da cota atual AW (slot)
      , m_imdsrvflg    char(01)                   # Auxiliar para flag servico imediato
      , m_agendaw      smallint 
      , m_ctgtrfcod    decimal(6,0)
      
 #--------------------------#
 function cts11m10_prepare()
 #--------------------------#

 define l_sql    char(500)

 ### Inicio


        let     l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts11m10_001 from l_sql
 declare c_cts11m10_001 cursor for p_cts11m10_001
 ### Fim

 let l_sql =  "select atdetpcod                          "
             ,"  from datmsrvacp                         "
             ," where atdsrvnum = ?                      "
             ,"   and atdsrvano = ?                      "
             ,"   and atdsrvseq = (select max(atdsrvseq) "
             ,"                      from datmsrvacp     "
             ,"                     where atdsrvnum = ?  "
             ,"                       and atdsrvano = ?) "

 prepare p_cts11m10_002 from l_sql
 declare c_cts11m10_002 cursor for p_cts11m10_002

 let l_sql = " select grlinf ",
             " from datkgeral ",
             " where grlchv = 'PSOAGENDAWATIVA' "
 prepare p_cts11m10_003 from l_sql
 declare c_cts11m10_003 cursor for p_cts11m10_003

 let m_prep_sql = true

 end function

#---------------------------------------------------------------
 function cts11m10(lr_parametro)
#---------------------------------------------------------------

 define lr_parametro record
                         succod       like datrligapol.succod,
                         ramcod       like datrservapol.ramcod,
                         aplnumdig    like datrligapol.aplnumdig,
                         itmnumdig    like datrligapol.itmnumdig,
                         edsnumref    like datrligapol.edsnumref,
                         prporg       like datrligprp.prporg,
                         prpnumdig    like datrligprp.prpnumdig,
                         ligcvntip    like datmligacao.ligcvntip
                     end record

 define ws           record
    atdetpcod        like datmsrvacp.atdetpcod,
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl,
    confirma         char (01),
    grvflg           smallint,
    asitipcod        like datmservico.asitipcod,
    histerr          smallint
 end record
 
 define l_azlaplcod    like datkazlapl.azlaplcod,
        l_resultado    smallint,
        l_mensagem     char(80)

 define x        char (01)
 define l_acesso smallint

 define m_mdtcod		like datmmdtmsg.mdtcod
 define m_pstcoddig     like dpaksocor.pstcoddig
 define m_socvclcod     like datkveiculo.socvclcod
 define m_srrcoddig     like datksrr.srrcoddig
 define l_vclcordes		char(20)
 define l_msgaltend	char(1500)
 define l_texto 		  char(200)
 define l_dtalt			date
 define l_hralt		  datetime hour to minute
 define l_lgdtxtcl	  char(80)
 define l_ciaempnom  char(50)
 define l_codrtgps   smallint
 define l_msgrtgps   char(100)

 define l_grlinf            like igbkgeral.grlinf

 define l_data         date,
        l_hora2        datetime hour to minute

 initialize m_rsrchv     
          , m_altcidufd  
          , m_altdathor
          , m_operacao
          , m_agncotdat 
          , m_agncothor
          , m_agncotdatant
          , m_agncothorant
          , m_rsrchvant to null
          
 let     l_azlaplcod  =  null
 let     l_resultado  =  null
 let     l_mensagem  =  null
 let     l_doc_handle  =  null
 let     x  =  null
 let     l_grlinf  =  null
 let     l_data  =  null
 let     l_hora2  =  null
 
 initialize  ws.*  to  null
 
 initialize l_azlaplcod  to null
 initialize l_resultado  to null
 initialize l_mensagem   to null
 initialize l_doc_handle to null
 
 
 let     x  =  null
 let     l_grlinf  =  null
 
 
 initialize  ws.*  to  null
 
 let     x  =  null
 
 initialize  ws.*  to  null
 
 let g_documento.atdsrvorg = 2

 let mr_parametro.succod     = lr_parametro.succod
 let mr_parametro.ramcod     = lr_parametro.ramcod
 let mr_parametro.aplnumdig  = lr_parametro.aplnumdig
 let mr_parametro.itmnumdig  = lr_parametro.itmnumdig
 let mr_parametro.edsnumref  = lr_parametro.edsnumref
 let mr_parametro.prporg     = lr_parametro.prporg
 let mr_parametro.prpnumdig  = lr_parametro.prpnumdig
 let mr_parametro.ligcvntip  = lr_parametro.ligcvntip

 let int_flag   = false
 let m_srv_acionado = false
 let m_c24lclpdrcod = null
 initialize m_subbairro to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let aux_today  = l_data
 let aux_hora   = l_hora2
 let aux_ano    = aux_today[9,10]

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts11m10_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open c_cts11m10_003
 fetch c_cts11m10_003 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 open window w_cts11m10 at 04,02 with form "cts11m10"
                      attribute(form line 1)

 display "Azul Seguros" to msg_azul attribute(reverse)

 if g_documento.atdsrvnum is not null then
    select asitipcod
         into ws.asitipcod
         from datmservico
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
    if ws.asitipcod = 10 then
       display "(F3)Refer(F5)Espel(F6)Hist(F7)Fun(F8)Data(F9)Conclui(F10)Passag" to msgfun
    else
       display "(F1)Help(F3)Refer(F5)Espel(F6)Hist(F7)Fun(F9)Conclui(F10)Passag" to msgfun
    end if
 else
    display "(F1)Help(F3)Refer(F5)Espelho(F6)Hist(F7)Fun(F9)Conclui(F10)Passag" to msgfun
 end if

 display "/" at 8,15
 display "-" at 8,23

 initialize mr_cts11m10.* to null
 initialize w_cts11m10.* to null
 initialize ws.*         to null

 initialize a_cts11m10, a_cts11m10_bkp, m_hist_cts11m10_bkp to null
 initialize a_passag     to null

 let w_cts11m10.ligcvntip = g_documento.ligcvntip

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 select cpodes into mr_cts11m10.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts11m10.ligcvntip



 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts11m10()

    display by name mr_cts11m10.servico
    display by name mr_cts11m10.doctxt
    display by name mr_cts11m10.vcldes
    display by name mr_cts11m10.nom
    display by name mr_cts11m10.corsus
    display by name mr_cts11m10.cornom
    display by name mr_cts11m10.vclcoddig
    display by name mr_cts11m10.vclanomdl
    display by name mr_cts11m10.vcllicnum
    display by name mr_cts11m10.vclcordes
    display by name mr_cts11m10.asitipcod
    display by name mr_cts11m10.asimtvcod
    display by name mr_cts11m10.refatdsrvorg
    display by name mr_cts11m10.refatdsrvnum
    display by name mr_cts11m10.refatdsrvano
    display by name mr_cts11m10.bagflg
    display by name mr_cts11m10.imdsrvflg
    display by name mr_cts11m10.atdprinvlcod
    display by name mr_cts11m10.atdlibflg
    display by name mr_cts11m10.prslocflg
    display by name mr_cts11m10.frmflg
    display by name mr_cts11m10.asimtvdes
    display by name mr_cts11m10.asitipabvdes
    display by name mr_cts11m10.dstlcl
    display by name mr_cts11m10.dstlgdtxt
    display by name mr_cts11m10.dstbrrnom
    display by name mr_cts11m10.dstcidnom
    display by name mr_cts11m10.dstufdcod
    display by name mr_cts11m10.atdtxt

    display by name mr_cts11m10.c24solnom attribute (reverse)
    display by name a_cts11m10[1].lgdtxt,
                    a_cts11m10[1].lclbrrnom,
                    a_cts11m10[1].cidnom,
                    a_cts11m10[1].ufdcod,
                    a_cts11m10[1].lclrefptotxt,
                    a_cts11m10[1].endzon,
                    a_cts11m10[1].dddcod,
                    a_cts11m10[1].lcltelnum,
                    a_cts11m10[1].lclcttnom,
                    a_cts11m10[1].celteldddcod,
                    a_cts11m10[1].celtelnum,
                    a_cts11m10[1].endcmp



    if mr_cts11m10.atdlibflg = "N"   then
       display by name mr_cts11m10.atdlibdat attribute (invisible)
       display by name mr_cts11m10.atdlibhor attribute (invisible)
    end if

    if w_cts11m10.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"

       #Desativado Projeto alteracao cadastro de destino
       #let m_srv_acionado = true
    end if


    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then


               # -> BUSCA O CODIGO DA APOLICE
               call ctd02g01_azlaplcod(g_documento.succod,
                                       g_documento.ramcod,
                                       g_documento.aplnumdig,
                                       g_documento.itmnumdig,
                                       g_documento.edsnumref)
                    returning l_resultado,
                              l_mensagem,
                              l_azlaplcod

               if l_resultado <> 1 then
                  error l_mensagem
                  sleep 4
                  return
               end if
               # -> BUSCA O XML DA APOLICE
               let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

               if l_doc_handle is null then
                  error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
                  return
               end if

    end if


    call cts11m10_modifica() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat        , aux_today, aux_hora )
       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then

       let mr_cts11m10.doctxt = "Apolice.: "
                            , g_documento.succod    using "<<<&&",
                         " ", g_documento.ramcod    using "&&&&",
                         " ", g_documento.aplnumdig using "<<<<<<<&&"

       #-> BUSCA O CODIGO DA APOLICE
       call ctd02g01_azlaplcod(g_documento.succod,
                               g_documento.ramcod,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               g_documento.edsnumref)
            returning l_resultado,
                      l_mensagem,
                      l_azlaplcod

       if l_resultado <> 1 then
          error l_mensagem
          sleep 4
          return
       end if
       # -> BUSCA O XML DA APOLICE
       let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

       if l_doc_handle is null then
          error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
          return
       end if
       # -> BUSCA OS DADOS DO XML DA APOLICE

       # -> DADOS DO SEGURADO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "SEGURADO")
            returning mr_segurado.nome,
                      mr_segurado.cgccpf,
                      mr_segurado.pessoa,
                      mr_segurado.dddfone,
                      mr_segurado.numfone,
                      mr_segurado.email
       # -> DADOS DO CORRETOR
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "CORRETOR")
            returning mr_corretor.susep,
                      mr_corretor.nome,
                      mr_corretor.dddfone,
                      mr_corretor.numfone,
                      mr_corretor.dddfax,
                      mr_corretor.numfax,
                      mr_corretor.email
       # -> DADOS DO VEICULO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "VEICULO")
            returning mr_veiculo.codigo,
                      mr_veiculo.marca,
                      mr_veiculo.tipo,
                      mr_veiculo.modelo,
                      mr_veiculo.chassi,
                      mr_veiculo.placa,
                      mr_veiculo.anofab,
                      mr_veiculo.anomod,
                      mr_veiculo.catgtar,
                      mr_veiculo.automatico

      let mr_cts11m10.nom       = mr_segurado.nome
      let mr_cts11m10.corsus    = mr_corretor.susep
      let mr_cts11m10.cornom    = mr_corretor.nome
      let mr_cts11m10.vclcoddig = mr_veiculo.codigo
      let mr_cts11m10.vclanomdl = mr_veiculo.anomod
      let mr_cts11m10.vcllicnum = mr_veiculo.placa
    end if
    # DESCRICAO DO VEICULO
    if  mr_veiculo.codigo is not null then
        let mr_cts11m10.vcldes = cts15g00(mr_veiculo.codigo)
    end if
    # -> COR DO VEICULO
    select cpodes
      into mr_cts11m10.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = w_cts11m10.vclcorcod

    let mr_cts11m10.prsloccab = "Prs.Local.:"
    let mr_cts11m10.prslocflg = "N"

    let mr_cts11m10.c24solnom   = g_documento.solnom

    display by name mr_cts11m10.doctxt
    display by name mr_cts11m10.vcldes
    display by name mr_cts11m10.nom
    display by name mr_cts11m10.corsus
    display by name mr_cts11m10.cornom
    display by name mr_cts11m10.vclcoddig
    display by name mr_cts11m10.vclanomdl
    display by name mr_cts11m10.vcllicnum
    display by name mr_cts11m10.vclcordes
    display by name mr_cts11m10.asitipcod
    display by name mr_cts11m10.asimtvcod
    display by name mr_cts11m10.refatdsrvorg
    display by name mr_cts11m10.refatdsrvnum
    display by name mr_cts11m10.refatdsrvano
    display by name mr_cts11m10.bagflg
    display by name mr_cts11m10.imdsrvflg
    display by name mr_cts11m10.atdprinvlcod
    display by name mr_cts11m10.atdlibflg
    display by name mr_cts11m10.prslocflg
    display by name mr_cts11m10.frmflg

    display by name mr_cts11m10.c24solnom attribute (reverse)

    ###
    ### Inicio PSI179345 - Paulo
    ###

    open c_cts11m10_001

    whenever error continue
    fetch c_cts11m10_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts11m10001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts11m10() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window w_cts11m10
          return
       end if
    end if
    ###
    ### Final PSI179345 - Paulo
    ###

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call cts11m10_inclui() returning ws.grvflg

    if ws.grvflg = true  then
       ------------------------------------------------------------------
       call cts10n00(w_cts11m10.atdsrvnum, w_cts11m10.atdsrvano,
                     g_issk.funmat       , aux_today, aux_hora )

       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if mr_cts11m10.imdsrvflg =  "S"     and        # servico imediato
          mr_cts11m10.atdlibflg =  "S"     and        # servico liberado
          mr_cts11m10.prslocflg =  "N"     and        # prestador no local
          mr_cts11m10.frmflg    =  "N"     and        # formulario
          m_aciona = 'N'                  then       # servico nao acionado auto
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
          
          if g_documento.c24astcod <> 'KM1' and       
             g_documento.c24astcod <> 'KM2' and       
             g_documento.c24astcod <> 'KM3' then    
             	   
              if l_acesso = true then
                 call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                      returning ws.confirma
              
                 if ws.confirma  =  "S"   then
                    call cts00m02(w_cts11m10.atdsrvnum, w_cts11m10.atdsrvano, 1 )
                 end if
              end if
          end if
       end if

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = w_cts11m10.atdsrvnum
          and atdsrvano = w_cts11m10.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = w_cts11m10.atdsrvnum
                              and atdsrvano = w_cts11m10.atdsrvano)

       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts11m10.atdsrvnum
                             and atdsrvano = w_cts11m10.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts11m10.atdsrvnum,w_cts11m10.atdsrvano)
          end if
       end if
    end if
 end if
 clear form

 close window w_cts11m10


end function  ###  cts11m10

#-------------------------------------#
 function cts11m10_input()
#-------------------------------------#

 define lr_aux  record
                    atddmccidnom  like datmassistpassag.atddmccidnom,
                    atddmcufdcod  like datmassistpassag.atddmcufdcod,
                    atdocrcidnom  like datmlcl.cidnom               ,
                    atdocrufdcod  like datmlcl.ufdcod               ,
                    atddstcidnom  like datmassistpassag.atddstcidnom,
                    atddstufdcod  like datmassistpassag.atddstufdcod
                end record

 define ws record
               succod           like datrservapol.succod,
               aplnumdig        like datrservapol.aplnumdig,
               itmnumdig        like datrservapol.itmnumdig,
               segnumdig        like gsakend.segnumdig,
               refatdsrvorg     like datmservico.atdsrvorg,
               dddcod           like gsakend.dddcod,
               teltxt           like gsakend.teltxt,
               vclcordes        char (11),
               blqnivcod        like datkblq.blqnivcod,
               vcllicant        like datmservico.vcllicnum,
               maxcstvlr        like datmservico.atdcstvlr,
               msgcstvlr        char (40),
               msgcstvlr2       char (40),
               msgcstvlr3       char (40),
               snhflg           char (01),
               retflg           char (01),
               prpflg           char (01),
               confirma         char (01),
               dtparam          char (16),
               sqlcode          integer,
               opcao            dec (1,0),
               opcaodes         char(20) ,
               codpais          char(11),  
               despais          char(40),  
               erro             smallint   
           end record

 define hist_cts11m10 record
                            hist1 like datmservhist.c24srvdsc,
                            hist2 like datmservhist.c24srvdsc,
                            hist3 like datmservhist.c24srvdsc,
                            hist4 like datmservhist.c24srvdsc,
                            hist5 like datmservhist.c24srvdsc
                        end record

 define l_azlaplcod    like datkazlapl.azlaplcod,
        l_resultado    smallint,
        l_flag         smallint,
        l_mensagem     char(80),
        l_confirma     char(01),
        l_vclcordes    char (11),
        l_data         date,
        l_hora2        datetime hour to minute,
        aux_today      char (10),
        aux_hora       char (05),
        aux_ano        char (02),
        #m_srv_acionado smallint,
        arr_aux        smallint,
        l_vclcoddig_contingencia like datmservico.vclcoddig,
        l_desc_1       char(40),
        l_desc_2       char(40),
        l_clscod       like aackcls.clscod,
        l_acesso       smallint,
        l_atdetpcod    like datmsrvacp.atdetpcod,
        l_status       smallint,
        l_atdsrvorg    like datmservico.atdsrvorg,
        l_resposta     char (1)      

 define l_errcod   smallint
       ,l_errmsg   char(80)
       
 define m_sql      char (300)      
       
 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
           ,m_ctgtrfcod 
 to null
 
 initialize l_errcod, l_errmsg to null
 
 let     l_azlaplcod  =  null
 let     l_resultado  =  null
 let     l_flag  =  false
 let     l_mensagem  =  null
 let     l_confirma  =  null
 let     l_vclcordes  =  null
 let     l_data  =  null
 let     l_hora2  =  null
 let     aux_today  =  null
 let     aux_hora  =  null
 let     aux_ano  =  null
 #let     m_srv_acionado  =  null
 let     l_vclcoddig_contingencia  =  null
 let     l_desc_1  =  null
 let     l_desc_2  =  null
 let     l_clscod  =  null
 let     l_atdetpcod  = null
 let     l_status     = null
 let     m_grava_hist = false
 let     l_atdsrvorg = null
 
 initialize  lr_aux.*  to  null
 
 initialize  ws.*  to  null
 
 initialize  hist_cts11m10.*  to  null

 initialize aux_today,
            aux_hora,
            aux_ano,
            l_azlaplcod,
            l_resultado,
            l_mensagem,
            l_confirma,
            hist_cts11m10.*,
            lr_aux.*,
            l_vclcoddig_contingencia to null

 let l_vclcoddig_contingencia = mr_cts11m10.vclcoddig

 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if
 
 # situacao original do servico
 let m_imdsrvflg = mr_cts11m10.imdsrvflg
 let m_cidnom = a_cts11m10[1].cidnom
 let m_ufdcod = a_cts11m10[1].ufdcod
 # PSI-2013-00440PR
 
 
 #display 'entrada do input, var null ou carregada na consulta'
 #display 'mr_cts11m10.imdsrvflg:', mr_cts11m10.imdsrvflg
 #display 'a_cts11m10[1].cidnom :', a_cts11m10[1].cidnom
 #display 'a_cts11m10[1].ufdcod :', a_cts11m10[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant
 
 input by name mr_cts11m10.nom         ,
               mr_cts11m10.corsus      ,
               mr_cts11m10.cornom      ,
               mr_cts11m10.vclcoddig   ,
               mr_cts11m10.vclanomdl   ,
               mr_cts11m10.vcllicnum   ,
               mr_cts11m10.vclcordes   ,
               mr_cts11m10.asitipcod   ,
               mr_cts11m10.asimtvcod   ,
               mr_cts11m10.refatdsrvorg,
               mr_cts11m10.refatdsrvnum,
               mr_cts11m10.refatdsrvano,
               mr_cts11m10.bagflg      ,
               mr_cts11m10.imdsrvflg   ,
               mr_cts11m10.atdprinvlcod,
               mr_cts11m10.atdlibflg   ,
               mr_cts11m10.prslocflg   ,
               mr_cts11m10.frmflg      without defaults

         before field nom
             display by name mr_cts11m10.nom        attribute (reverse)

         after field nom
             display by name mr_cts11m10.nom

             if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                     
                # INICIO PSI-2013-00440PR
                if m_agendaw = false   # regulacao antiga
                   then
                   call cts02m03("S"                  ,
                                 mr_cts11m10.imdsrvflg,
                                 w_cts11m10.atdhorpvt,
                                 w_cts11m10.atddatprg,
                                 w_cts11m10.atdhorprg,
                                 w_cts11m10.atdpvtretflg)
                       returning w_cts11m10.atdhorpvt,
                                 w_cts11m10.atddatprg,
                                 w_cts11m10.atdhorprg,
                                 w_cts11m10.atdpvtretflg
		          else
                  call cts02m08("S"                  ,
                                mr_cts11m10.imdsrvflg,
                                m_altcidufd,
                                mr_cts11m10.prslocflg,
                                w_cts11m10.atdhorpvt,
                                w_cts11m10.atddatprg,
                                w_cts11m10.atdhorprg,
                                w_cts11m10.atdpvtretflg,
                                m_rsrchvant,
                                m_operacao,
                                "",
                                a_cts11m10[1].cidnom,
                                a_cts11m10[1].ufdcod,
                                "",   # codigo de assistencia, nao existe no Ct24h
                                mr_cts11m10.vclcoddig,
                                m_ctgtrfcod,
                                mr_cts11m10.imdsrvflg,
                                a_cts11m10[1].c24lclpdrcod,
                                a_cts11m10[1].lclltt,
                                a_cts11m10[1].lcllgt,
                                g_documento.ciaempcod,
                                g_documento.atdsrvorg,
                                mr_cts11m10.asitipcod,
                                "",   # natureza nao tem, identifica pelo asitipcod  
                                "")   # sub-natureza nao tem, identifica pelo asitipcod 
                      returning w_cts11m10.atdhorpvt,
                                w_cts11m10.atddatprg,
                                w_cts11m10.atdhorprg,
                                w_cts11m10.atdpvtretflg,
                                mr_cts11m10.imdsrvflg,
                                m_rsrchv,
                                m_operacao,
                                m_altdathor
                end if
                # FIM PSI-2013-00440PR
             
                next field nom
             end if
             if  mr_cts11m10.nom is null  then
                 error " Nome deve ser informado!"
                 next field nom
             end if

             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then

                 # BUSCA AS LOCALIDADES PARA ASSISTENCIA AO PASSAGEIRO
                 call cts11m06(w_cts11m10.atddmccidnom,
                               w_cts11m10.atddmcufdcod,
                               w_cts11m10.atdocrcidnom,
                               w_cts11m10.atdocrufdcod,
                               w_cts11m10.atddstcidnom,
                               w_cts11m10.atddstufdcod)
                     returning w_cts11m10.atddmccidnom,
                               w_cts11m10.atddmcufdcod,
                               w_cts11m10.atdocrcidnom,
                               w_cts11m10.atdocrufdcod,
                               w_cts11m10.atddstcidnom,
                               w_cts11m10.atddstufdcod

                 if  w_cts11m10.atddmccidnom is null  or
                     w_cts11m10.atddmcufdcod is null  or
                     w_cts11m10.atdocrcidnom is null  or
                     w_cts11m10.atdocrufdcod is null  or
                     w_cts11m10.atddstcidnom is null  or
                     w_cts11m10.atddstufdcod is null  then
                     error " Localidades devem ser informadas para confirmacao",
                           " do direito de utilizacao!"
                     next field nom
                 end if

                 if  w_cts11m10.atddmccidnom = w_cts11m10.atdocrcidnom  and
                     w_cts11m10.atddmcufdcod = w_cts11m10.atdocrufdcod  then
                     call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                   "A LOCAL DE DOMICILIO!","") returning l_confirma
                     if  l_confirma = "N"  then
                         next field nom
                     end if
                 end if

                 let a_cts11m10[1].cidnom = w_cts11m10.atdocrcidnom
                 let a_cts11m10[1].ufdcod = w_cts11m10.atdocrufdcod

                 # DIFERENTE DE PASSAGEM AEREA
                 if  mr_cts11m10.asitipcod <> 10  then
                     let a_cts11m10[2].cidnom = w_cts11m10.atddstcidnom
                     let a_cts11m10[2].ufdcod = w_cts11m10.atddstufdcod
                 end if
             end if

             if  w_cts11m10.atdfnlflg = "S"  then
                 error " Servico ja' acionado nao pode ser alterado!"
                 let m_srv_acionado = true

                 # CASO O SERVIÇO JÁ ESTEJA ACIONADO
                 call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                               "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma

                 # PREVISAO PARA TERMINO DO SERVIÇO
                 # INICIO PSI-2013-00440PR
                 if m_agendaw = false   # regulacao antiga
                    then
                    call cts02m03(w_cts11m10.atdfnlflg,
                                  mr_cts11m10.imdsrvflg,
                                  w_cts11m10.atdhorpvt,
                                  w_cts11m10.atddatprg,
                                  w_cts11m10.atdhorprg,
                                  w_cts11m10.atdpvtretflg)
                        returning w_cts11m10.atdhorpvt,
                                  w_cts11m10.atddatprg,
                                  w_cts11m10.atdhorprg,
                                  w_cts11m10.atdpvtretflg
		           else
                    call cts02m08(w_cts11m10.atdfnlflg,
                                  mr_cts11m10.imdsrvflg,
                                  m_altcidufd,
                                  mr_cts11m10.prslocflg,
                                  w_cts11m10.atdhorpvt,
                                  w_cts11m10.atddatprg,
                                  w_cts11m10.atdhorprg,
                                  w_cts11m10.atdpvtretflg,
                                  m_rsrchvant,
                                  m_operacao,
                                  "",
                                  a_cts11m10[1].cidnom,
                                  a_cts11m10[1].ufdcod,
                                  "",   # codigo de assistencia, nao existe no Ct24h
                                  mr_cts11m10.vclcoddig,
                                  m_ctgtrfcod,
                                  mr_cts11m10.imdsrvflg,
                                  a_cts11m10[1].c24lclpdrcod,
                                  a_cts11m10[1].lclltt,
                                  a_cts11m10[1].lcllgt,
                                  g_documento.ciaempcod,
                                  g_documento.atdsrvorg,
                                  mr_cts11m10.asitipcod,
                                  "",   # natureza nao tem, identifica pelo asitipcod  
                                  "")   # sub-natureza nao tem, identifica pelo asitipcod 
                        returning w_cts11m10.atdhorpvt,
                                  w_cts11m10.atddatprg,
                                  w_cts11m10.atdhorprg,
                                  w_cts11m10.atdpvtretflg,
                                  mr_cts11m10.imdsrvflg,
                                  m_rsrchv,
                                  m_operacao,
                                  m_altdathor
                 end if
                 # FIM PSI-2013-00440PR
                 
                 next field frmflg
             end if

         before field corsus
             display by name mr_cts11m10.corsus     attribute (reverse)

         after field corsus
             display by name mr_cts11m10.corsus

             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 next field cornom
             else
                 next field nom
             end if

         before field cornom
             display by name mr_cts11m10.cornom     attribute (reverse)

         after field cornom
             display by name mr_cts11m10.cornom

         before field vclcoddig
             display by name mr_cts11m10.vclcoddig  attribute (reverse)

         after field vclcoddig
             display by name mr_cts11m10.vclcoddig

             # se outro processo nao obteve cat. tarifaria, obter
             if m_ctgtrfcod is null
                then
                # laudo auto obter cod categoria tarifaria
                call cts02m08_sel_ctgtrfcod(mr_cts11m10.vclcoddig)
                     returning l_errcod, l_errmsg, m_ctgtrfcod
             end if
             
             if mr_cts11m10.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if  mr_cts11m10.vclcoddig is not null and
                 mr_cts11m10.vclcoddig <> 0 then

                 whenever error continue
                 select vclcoddig
                   from agbkveic
                  where vclcoddig = mr_cts11m10.vclcoddig
                 whenever error stop

                 if sqlca.sqlcode = notfound  then
                    error " Codigo de veiculo nao cadastrado!"
                    next field vclcoddig
                 end if

                 call cts15g00(mr_cts11m10.vclcoddig)
                    returning mr_cts11m10.vcldes

                 display by name mr_cts11m10.vcldes

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field cornom
                 else
                     next field vclanomdl
                 end if
             else
                 # FILTRO PARA CODIGO DO VEICULO
                 call agguvcl() returning mr_cts11m10.vclcoddig
                 next field vclcoddig
             end if

             whenever error continue
               select vclcoddig
                 from agbkveic
                where vclcoddig = mr_cts11m10.vclcoddig
             whenever error stop

             if  sqlca.sqlcode = notfound  then
                 error " Codigo de veiculo nao cadastrado!"
                 next field vclcoddig
             end if

             display by name mr_cts11m10.vcldes

         before field vclanomdl
             display by name mr_cts11m10.vclanomdl  attribute (reverse)

         after field vclanomdl
             display by name mr_cts11m10.vclanomdl

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field vclcoddig
             end if

             if  mr_cts11m10.vclanomdl is null then
                 error " Ano do veiculo deve ser informado!"
                 next field vclanomdl
             else
                 # VALIDAÇÃO PARA ANO DO CARRO
                 if  cts15g01(mr_cts11m10.vclcoddig,mr_cts11m10.vclanomdl) = false  then
                     error " Veiculo nao consta como fabricado em ",
                             mr_cts11m10.vclanomdl, "!"
                     next field vclanomdl
                 end if
             end if

         before field vcllicnum
             display by name mr_cts11m10.vcllicnum  attribute (reverse)

         after field vcllicnum
             display by name mr_cts11m10.vcllicnum

             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if  not srp1415(mr_cts11m10.vcllicnum)  then
                     error " Placa invalida!"
                     next field vcllicnum
                 end if
             end if

         before field vclcordes
             display by name mr_cts11m10.vclcordes attribute (reverse)

         after field vclcordes
             display by name mr_cts11m10.vclcordes

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field vcllicnum
             end if

             if  mr_cts11m10.vclcordes is not null then
                 let l_vclcordes = mr_cts11m10.vclcordes[2,9]

                 whenever error continue
                 select cpocod
                   into w_cts11m10.vclcorcod
                   from iddkdominio
                  where cponom      = "vclcorcod"
                    and cpodes[2,9] = l_vclcordes
                 whenever error stop

                 if  sqlca.sqlcode = notfound  then
                     error " Cor fora do padrao!"

                     # POPUP DE COR PADRAO
                     call c24geral4()
                          returning w_cts11m10.vclcorcod,
                                    mr_cts11m10.vclcordes

                     if  w_cts11m10.vclcorcod  is null   then
                         error " Cor do veiculo deve ser informada!"
                         next field vclcordes
                     else
                         display by name mr_cts11m10.vclcordes
                     end if
                 end if
             else
                 # POPUP DE COR PADRAO
                 call c24geral4()
                      returning w_cts11m10.vclcorcod,
                                mr_cts11m10.vclcordes

                 if  w_cts11m10.vclcorcod  is null   then
                     error " Cor do veiculo deve ser informada!"
                     next field  vclcordes
                 else
                     display by name mr_cts11m10.vclcordes
                 end if
             end if

             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then
                 call cts40g03_data_hora_banco(2)
                      returning l_data,
                                l_hora2

                 # INFORMAÇÕES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04(g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               l_data,
                               g_documento.ramcod)
             else
                 # INFORMAÇÕES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04(g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               w_cts11m10.atddat    ,
                               g_documento.ramcod)

                 next field asimtvcod
             end if

         before field asitipcod
             display by name mr_cts11m10.asitipcod attribute (reverse)

         after  field asitipcod
             display by name mr_cts11m10.asitipcod

             if  fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")  then
                if  mr_cts11m10.asitipcod is null  then

			                if l_doc_handle is not null then     #768820
			                   initialize l_desc_1, l_desc_2, l_clscod  to null
			                   call cts11m10_clausulas(l_doc_handle)   
			                                 returning l_desc_1 ---> Km Taxi
			                                          ,l_desc_2 ---> Limite so p/ Plus II
			                                          ,l_clscod
			                end if                    
			                if l_clscod = '37D' or
							           l_clscod = '37E' or
							           l_clscod = '37F' or
							           l_clscod = '37G' or
							           l_clscod = '37H' then
			                      call cts44g00_assistencia_azul(2)
			                          returning mr_cts11m10.asitipcod
			                    else
			                      #POPUP DE TIPOS DE ASSISTENCIA
			                       call ctn25c00(2)
			                         returning mr_cts11m10.asitipcod
			                    end if

			               if  mr_cts11m10.asitipcod is not null  then

			                      whenever error continue
			                         select asitipabvdes
			                           into mr_cts11m10.asitipabvdes
			                           from datkasitip
			                          where asitipcod = mr_cts11m10.asitipcod
			                            and asitipstt = "A"
			                         whenever error stop

			                         display by name mr_cts11m10.asitipcod
			                         display by name mr_cts11m10.asitipabvdes
			                         next field asimtvcod
			                else
			                         next field asitipcod
			                end if
                else
                     whenever error continue
                     select asitipabvdes
                       into mr_cts11m10.asitipabvdes
                       from datkasitip
                      where asitipcod = mr_cts11m10.asitipcod
                        and asitipstt = "A"
                     whenever error stop

                  if  sqlca.sqlcode = notfound  then
                       error " Tipo de assistencia invalido!"

                    if l_clscod = '37D' or
				               l_clscod = '37E' or
				               l_clscod = '37F' or
				               l_clscod = '37G' or
				               l_clscod = '37H' then
                      call cts44g00_assistencia_azul(2)
                           returning mr_cts11m10.asitipcod
                    else
                         #POPUP DE TIPOS DE ASSISTENCIA
                         call ctn25c00(2)
                             returning mr_cts11m10.asitipcod
                         next field asitipcod
                    end if
                  else
                         display by name mr_cts11m10.asitipcod
                end if

                     whenever error continue
                     select asitipcod
                       from datrasitipsrv
                      where atdsrvorg = g_documento.atdsrvorg
                        and asitipcod = mr_cts11m10.asitipcod
                     whenever error stop

                     if  sqlca.sqlcode = notfound  then
                         error " Tipo de assistencia nao pode ser enviada para",
                               " este servico!"
                         next field asitipcod
                     end if
                 end if
                 display by name mr_cts11m10.asitipabvdes
             end if

         before field asimtvcod
             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if  mr_cts11m10.asitipcod = 11  then  ###  Remocao Hospitalar
                 ## O cara já morreu nao precisa de diagnostico. Bia 28/07/06
                 ## mr_cts11m10.asitipcod = 12  then  ###  Traslado de Corpos
                     call cts08g01("I","N",
                                   "SOLICITE:ENVIO DE FAX C/ DIAGNOSTICO DO ",
                                   " PACIENTE, FAX DA CARTA DO MEDICO COM   ",
                                   "ASSINATURA E CRM E O TIPO DE AMBULANCIA.",
                                   "   REGISTRE TAMBEM MOTIVO DA REMOCAO!   ")
                         returning ws.confirma
                 end if
             end if

             display by name mr_cts11m10.asimtvcod attribute (reverse)

         after  field asimtvcod
             display by name mr_cts11m10.asimtvcod

             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then

                ---> Funcao que retorna o Limite de Km p/ Taxi ou
                ---> Limite do Retorno - Ambos os casos so para
                ---> Clausula 37 ,37A, 37B ou 37C ou 37D ou 37F

                initialize l_desc_1, l_desc_2, l_clscod  to null

                if l_doc_handle is not null then     #768820
                   call cts11m10_clausulas(l_doc_handle)
                                 returning l_desc_1 ---> Km Taxi
                                          ,l_desc_2 ---> Limite so p/ Plus II
                                          ,l_clscod
                end if
                
                if  mr_cts11m10.asimtvcod is null  then
                    if l_clscod = "37D" or
                       l_clscod = "37E" or
                       l_clscod = "37F" or
                       l_clscod = "37G" or
                       l_clscod = "37H" then

                       call cts44g00_motivos_clau_azul(mr_cts11m10.asitipcod,l_clscod)
                            returning mr_cts11m10.asimtvcod

                    else
		                    # POPUP PARA EXIBIR TODOS OS MOTIVOS PARA A
		                    # ASSISTENCIA INFORMADA ANTERIORMENTE
		                    call cts11m03(mr_cts11m10.asitipcod)
		                        returning mr_cts11m10.asimtvcod

                     end if
                    if  mr_cts11m10.asimtvcod is not null  then
                         call cts11m10_compara(mr_cts11m10.asitipcod,
				                                       mr_cts11m10.asimtvcod,
				                                       l_clscod)
                              returning l_flag
                        if l_flag = false then
		                        error 'Clausula nao permite este motivo'
		                        next field asimtvcod
                         end if
                          select asimtvdes into mr_cts11m10.asimtvdes
                            from datkasimtv
                           where asimtvcod = mr_cts11m10.asimtvcod
                             and asimtvsit = "A"


                          display by name mr_cts11m10.asimtvcod
                          display by name mr_cts11m10.asimtvdes

                        if mr_cts11m10.asimtvcod = 3 and
                          (l_clscod <> '37D' and l_clscod <> '37E' and
			                     l_clscod <> '37F' and l_clscod <> '37G' and l_clscod <> '37H' ) then # recuperacao veiculo

                           if l_clscod = "37B" then
                              call cts08g01("A","N","",
                                           "LIMITE TOTAL POR VIGENCIA: "
                                           ,"O VALOR DE UMA PASSAGEM RODOVIARIA"
                                           ,"OU AEREA NA CLASSE ECONOMICA.")
                                   returning ws.confirma
                           else
			                         if mr_cts11m10.asitipcod <> 5  then
                                  
                                  if cty41g00_valida_assunto(g_documento.c24astcod) then                                         
                                                                                                                                 
                                     call cts08g01("A","N",                                                                      
                                                   "SEM LIMITE DE UTILIZACOES, LIMITADO",                                        
                                                   "AO VALOR DE 1(UMA) PASSAGEM AEREA",                                          
                                                   "NACIONAL/INTERNACIONAL (MERCOSUL)",                                          
                                                   "CLASSE ECONOMICA, IDA E VOLTA")                                              
                                     returning ws.confirma                                                                       
                                                                                                                                 
                                  else                                                                                           
                                   
                                     call cts08g01("A","N","",
                                                   "LIMITE DE COBERTURA RESTRITO",
                                                    "AO VALOR DE UMA PASSAGEM",
                                                    "AEREA NA CLASSE ECONOMICA!")
                                     returning ws.confirma
                                  end if
                                  
                               end if
                          end if
                        else

                          case mr_cts11m10.asitipcod
                               when 5   # taxi
                                 let ws.msgcstvlr = l_desc_1

                                    if l_clscod = '37D' or l_clscod = '37E' or
			                                 l_clscod = '37F' or l_clscod = '37G' or
			                                 l_clscod = '37H'                     then
			                                       if (mr_cts11m10.asimtvcod = 1 or
			                                           mr_cts11m10.asimtvcod = 2 or
			                                           mr_cts11m10.asimtvcod = 13) then
                                                    call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1000.00","")
                                                       returning ws.confirma
                                              end if
                                            if mr_cts11m10.asimtvcod = 3 then
                                                   
                                                   if cty41g00_valida_assunto(g_documento.c24astcod) then       
                                                                                                                                                                   
                                                      call cts08g01("A","N",                                                                                       
                                                                    "SEM LIMITE DE UTILIZACOES, LIMITADO",                                                         
                                                                    "AO VALOR DE 1(UMA) PASSAGEM AEREA",                                                           
                                                                    "NACIONAL/INTERNACIONAL (MERCOSUL)",                                                           
                                                                    "CLASSE ECONOMICA, IDA E VOLTA")                                                               
                                                      returning ws.confirma                                                                                        
                                                                                                                                                                   
                                                   else                                                                                                            
                                                      
                                                      call cts08g01("A","N","",
                                                                    "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                    "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                    "NACIONAL NA CLASSE ECONOMICA!")
                                                      returning ws.confirma
                                                   
                                                   end if
                                            end if
                                            if mr_cts11m10.asimtvcod = 9 then
                                                 if l_clscod = '37E' then
                                                     call cts08g01("A","N","",
                                                                   "LIMITE DE DESPESAS:",
                                                                   "R$50,00 POR EVENTO.", "")
                                                      returning ws.confirma
                                                 else
                                                      if l_clscod = '37G' then
                                                         call cts08g01("A","N","",
                                                                       " LIMITE TOTAL POR VIGENCIA: R$ 150,00. ",
                                                                       " LIMITADO A R$ 50,00 POR EVENTO.", "")
                                                          returning ws.confirma
                                                       end if
                                                 end if
                                            end if
                                    else
                                        if mr_cts11m10.asimtvcod <> 4 then ---> Outros
                                           let ws.msgcstvlr = l_desc_1
                                        end if
                                    end if

                                    if l_clscod = "37B" then ---> Livre Escolha

                                        --->Taxi p/ Cidade Domicilio
                                        if mr_cts11m10.asimtvcod = 9 then
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: R$ 150,00. "
                                           let ws.msgcstvlr2 = " LIMITADO A R$ 50,00 POR EVENTO."
                                        end if

                                        if mr_cts11m10.asimtvcod = 1 or
                                           mr_cts11m10.asimtvcod = 2 then
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
                                        end if
                                    end if

                               when 10  # passagem aerea
                                  if l_clscod = '37D' or l_clscod = '37E' or
			                               l_clscod = '37F' or l_clscod = '37G' or
			                               l_clscod = '37H'                     then
                                            if (mr_cts11m10.asimtvcod = 1 or
                                                mr_cts11m10.asimtvcod = 2 or
			                                          mr_cts11m10.asimtvcod = 13) then
                                                    call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1000.00","")
                                                       returning ws.confirma
                                            end if
                                            if mr_cts11m10.asimtvcod = 3 then
                                               
                                               if cty41g00_valida_assunto(g_documento.c24astcod) then   
                                                  
                                                  call cts08g01("A","N",                                
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",     
                                                                "AO VALOR DE 1(UMA) PASSAGEM AEREA",
                                                                "NACIONAL/INTERNACIONAL (MERCOSUL)",   
                                                                "CLASSE ECONOMICA, IDA E VOLTA")           
                                                  returning ws.confirma                                    
                          
                                               else
                                                 
                                                  call cts08g01("A","N","",
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                "NACIONAL NA CLASSE ECONOMICA!")
                                                  returning ws.confirma
                                               
                                               end if 
                                            end if
                                  end if
				                             if l_desc_2 is null or
				                                l_desc_2 =  " "  then
                                         let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                         let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                      else
                                         if l_clscod = "37B" then  ---> Livre Escolha
                                            let ws.msgcstvlr2 = null
                                            let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
                                         else
                                            let ws.msgcstvlr = l_desc_2
                                         end if
                                      end if

                               when 11  # remocao hospitalar
                                  if l_clscod = '37D' or l_clscod = '37E' or
			                               l_clscod = '37F' or l_clscod = '37G' or
			                               l_clscod = '37H'                     then
                                         if (mr_cts11m10.asimtvcod = 4 or
                                             mr_cts11m10.asimtvcod = 6) then
                                                call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 2.500.00","")
                                                      returning ws.confirma
                                         end if
                                  end if
				                              if l_desc_2 is null or
				                                 l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                       else
                                          let ws.msgcstvlr = l_desc_2
                                       end if

                                when 12  # traslado de corpos
                                     if l_clscod = '37D' or l_clscod = '37E' or
			                                  l_clscod = '37F' or l_clscod = '37G' or
			                                  l_clscod = '37H'                     then
                                         if (mr_cts11m10.asimtvcod = 4 or
                                             mr_cts11m10.asimtvcod = 7) then
                                                call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1.500.00","")
                                                      returning ws.confirma
                                         end if
                                      end if
				                               if l_desc_2 is null or
				                                  l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                       else
                                          let ws.msgcstvlr = l_desc_2
                                       end if

                                when 16  # transporte rodoviario
                                    if l_clscod = '37D' or l_clscod = '37E' or
			                                 l_clscod = '37F' or l_clscod = '37G' or
			                                 l_clscod = '37H'                     then
                                          if (mr_cts11m10.asimtvcod = 1 or
                                              mr_cts11m10.asimtvcod = 2 or
			                                        mr_cts11m10.asimtvcod = 13) then
                                                    call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1000.00","")
                                                       returning ws.confirma
                                           end if
                                          if mr_cts11m10.asimtvcod = 3 then
                                               
                                               if cty41g00_valida_assunto(g_documento.c24astcod) then                                                      
                                                                                                                                                           
                                                  call cts08g01("A","N",                                                                                   
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",                                                     
                                                                "AO VALOR DE 1(UMA) PASSAGEM AEREA",                                                       
                                                                "NACIONAL/INTERNACIONAL (MERCOSUL)",                                                       
                                                                "CLASSE ECONOMICA, IDA E VOLTA")                                                           
                                                  returning ws.confirma                                                                                    
                                                                                                                                                           
                                               else                                                                                                        
                                               
                                                  call cts08g01("A","N","",
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                "NACIONAL NA CLASSE ECONOMICA!")
                                                  returning ws.confirma
                                               
                                               end if
                                          end if
                                   end if
				                              if l_desc_2 is null or
				                                 l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                      else
                                         if l_clscod = "37B" then  ---> Livre Escolha
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
				                                 else
                                             let ws.msgcstvlr = l_desc_2
                                         end if
                                      end if
                                 end case

                                 if l_clscod = "37B" then ---> Livre Escolha
                                    let ws.msgcstvlr3 = null
                                 else
                                     let ws.msgcstvlr3 = "LIMITE DE COBERTURA RESTRITO"
                                 end if

                                     if mr_cts11m10.asitipcod <> 5 or   --> Taxi
                                        mr_cts11m10.asimtvcod <> 4 then --> Outros

                                       if ws.msgcstvlr2 is null and
                                              l_clscod <> "37D" and
                                              l_clscod <> "37E" and
                                              l_clscod <> "37F" and
                                              l_clscod <> "37G" and
                                              l_clscod <> "37H" then
                                           call cts08g01("A","N","",
                                                         ws.msgcstvlr3,
                                                         ws.msgcstvlr,"")
                                               returning ws.confirma
                                       else
                                            if l_clscod <> "37D" and
                                               l_clscod <> "37E" and
                                               l_clscod <> "37F" and
                                               l_clscod <> "37G" and
                                               l_clscod <> "37H" then
                                              call cts08g01("A","N","",
                                                            ws.msgcstvlr3,
                                                            ws.msgcstvlr ,ws.msgcstvlr2)
                                                  returning ws.confirma
                                              let ws.msgcstvlr2 = null
                                            end if
                                       end if

                                       let ws.msgcstvlr = null
                                     end if
                               end if
#                           end if
                        next field refatdsrvorg
                    else
                       next field asimtvcod
                    end if
                else
                    select asimtvdes
                      into mr_cts11m10.asimtvdes
                      from datkasimtv
                     where asimtvcod = mr_cts11m10.asimtvcod
                       and asimtvsit = "A"
                    if  sqlca.sqlcode = notfound  then
                        error " Motivo invalido!"
                        if l_clscod = "37D" or
                           l_clscod = "37E" or
                           l_clscod = "37F" or
                           l_clscod = "37G" or
                           l_clscod = "37H" then
                           call cts44g00_motivos_clau_azul(mr_cts11m10.asitipcod,l_clscod)
                                returning mr_cts11m10.asimtvcod
                        else
		                        # POPUP PARA EXIBIR TODOS OS MOTIVOS PARA A
		                        # ASSISTENCIA INFORMADA ANTERIORMENTE
		                        call cts11m03(mr_cts11m10.asitipcod)
		                            returning mr_cts11m10.asimtvcod
                         end if
                    else
                        display by name mr_cts11m10.asimtvcod
                    end if

                    select asimtvcod
                      from datrmtvasitip
                     where asitipcod = mr_cts11m10.asitipcod
                       and asimtvcod = mr_cts11m10.asimtvcod

                    if  sqlca.sqlcode = notfound  then
                        error " Motivo nao pode ser informado para este tipo",
                              " de assistencia!"
                        next field asimtvcod
                    end if
                        call cts11m10_compara(mr_cts11m10.asitipcod,
				                                      mr_cts11m10.asimtvcod,
				                                      l_clscod)
                             returning l_flag
                        if l_flag = false then
		                       error 'Clausula nao permite este motivo'
		                       next field asimtvcod
                        end if
                end if

                display by name mr_cts11m10.asimtvdes

                if  mr_cts11m10.asimtvcod = 3  then
                    if  g_documento.ramcod = 78  or    # TRANSPORTE
                        g_documento.ramcod = 171  then  # TRANSPORTE
                        call cts08g01("A","N","",
                                      "LIMITE DE R$ 250,00 PARA",
                                      "RECUPERACAO DE VEICULO","")
                              returning ws.confirma
                    else
                        if l_clscod = "37B" then

                           call cts08g01("A","N","",
                                         "LIMITE TOTAL POR VIGENCIA: "
                                        ,"O VALOR DE UMA PASSAGEM RODOVIARIA"
                                        ,"OU AEREA NA CLASSE ECONOMICA.")
                                returning ws.confirma
                        else
                           
                           if cty41g00_valida_assunto(g_documento.c24astcod) then                                  
                                                                                                                   
                              call cts08g01("A","N",                                                               
                                            "SEM LIMITE DE UTILIZACOES, LIMITADO",                                 
                                            "AO VALOR DE 1(UMA) PASSAGEM AEREA",                                   
                                            "NACIONAL/INTERNACIONAL (MERCOSUL)",                                   
                                            "CLASSE ECONOMICA, IDA E VOLTA")                                       
                              returning ws.confirma                                                                
                                                                                                                   
                           else                                                                                    
                                                     
                              call cts08g01("A","N","",
                                            "LIMITE DE COBERTURA RESTRITO",
                                            "AO VALOR DE UMA PASSAGEM",
                                            "AEREA NA CLASSE ECONOMICA!")
                              returning ws.confirma  
                           
                           end if
                       end if
                    end if
                else

                    # LIMITE DE COBERTURA
                  case mr_cts11m10.asitipcod
                               when 5   # taxi
                                 let ws.msgcstvlr = l_desc_1
                                    if l_clscod = '37D' or l_clscod = '37E' or
			                                 l_clscod = '37F' or l_clscod = '37G' or
			                                 l_clscod = '37H'                     then
			                                          if (mr_cts11m10.asimtvcod = 1 or
			                                              mr_cts11m10.asimtvcod = 2 or
			                                              mr_cts11m10.asimtvcod = 13) then
                                                       call cts08g01("A","N","",
                                                                     "LIMITE DE COBERTURA RESTRITO",
                                                                     "R$ 1000.00",
                                                                     "")
                                                          returning ws.confirma
                                                 end if
                                                 if mr_cts11m10.asimtvcod = 3 then
                                                      
                                                      if cty41g00_valida_assunto(g_documento.c24astcod) then                                                             
                                                                                                                                                                         
                                                         call cts08g01("A","N",                                                                                          
                                                                       "SEM LIMITE DE UTILIZACOES, LIMITADO",                                                            
                                                                       "AO VALOR DE 1(UMA) PASSAGEM AEREA",                                                              
                                                                       "NACIONAL/INTERNACIONAL (MERCOSUL)",                                                              
                                                                       "CLASSE ECONOMICA, IDA E VOLTA")                                                                  
                                                         returning ws.confirma                                                                                           
                                                                                                                                                                         
                                                      else                                                                                                                                                                               
                                                         
                                                         call cts08g01("A","N","",
                                                                       "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                       "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                       "NACIONAL NA CLASSE ECONOMICA!")
                                                         returning ws.confirma
                                                      
                                                      end if
                                                 end if
                                               if mr_cts11m10.asimtvcod = 9 then
                                                    if l_clscod = '37E' then
                                                        call cts08g01("A","N","",
                                                                      "LIMITE DE DESPESAS:",
                                                                      "R$50,00 POR EVENTO.", "")
                                                         returning ws.confirma
                                                    else
                                                         if l_clscod = '37G' then
                                                            call cts08g01("A","N","",
                                                                          " LIMITE TOTAL POR VIGENCIA: R$ 150,00. ",
                                                                          " LIMITADO A R$ 50,00 POR EVENTO.", "")
                                                             returning ws.confirma
                                                          end if
                                                    end if
                                               end if
                                    else
                                           if mr_cts11m10.asimtvcod <> 4 then ---> Outros
                                              let ws.msgcstvlr = l_desc_1
                                           end if
                                    end if

                                    if l_clscod = "37B" then ---> Livre Escolha
                                        --->Taxi p/ Cidade Domicilio
                                        if mr_cts11m10.asimtvcod = 9 then
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: R$ 150,00. "
                                           let ws.msgcstvlr2 = " LIMITADO A R$ 50,00 POR EVENTO."
                                        end if

                                        if mr_cts11m10.asimtvcod = 1 or
                                           mr_cts11m10.asimtvcod = 2 then
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
                                        end if
                                    end if


                               when 10  # passagem aerea
                                  if l_clscod = '37D' or l_clscod = '37E' or
			                               l_clscod = '37F' or l_clscod = '37G' or
			                               l_clscod = '37H'                     then
                                            if (mr_cts11m10.asimtvcod = 1 or
                                                mr_cts11m10.asimtvcod = 2 or
			                                          mr_cts11m10.asimtvcod = 13) then
                                                    call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1000.00","")
                                                       returning ws.confirma
                                            end if
                                            if mr_cts11m10.asimtvcod = 3 then
                                               
                                               if cty41g00_valida_assunto(g_documento.c24astcod) then       
                                                                                                            
                                                  call cts08g01("A","N",                                    
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",      
                                                                "AO VALOR DE 1(UMA) PASSAGEM AEREA",        
                                                                "NACIONAL/INTERNACIONAL (MERCOSUL)",        
                                                                "CLASSE ECONOMICA, IDA E VOLTA")            
                                                  returning ws.confirma                                     
                                                                                                            
                                               else                                                         
                                               
                                                  call cts08g01("A","N","",
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                "NACIONAL NA CLASSE ECONOMICA!")
                                                  returning ws.confirma 
                                                  
                                               end if
                                            end if
                                  end if
				                             if l_desc_2 is null or
				                                l_desc_2 =  " "  then
                                         let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                         let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                      else
                                         if l_clscod = "37B" then  ---> Livre Escolha
                                            let ws.msgcstvlr2 = null
                                            let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
                                         else
                                            let ws.msgcstvlr = l_desc_2
                                         end if
                                      end if

                               when 11  # remocao hospitalar
                                  if l_clscod = '37D' or l_clscod = '37E' or
			                               l_clscod = '37F' or l_clscod = '37G' or
			                               l_clscod = '37H'                     then
                                         if (mr_cts11m10.asimtvcod = 4 or
                                             mr_cts11m10.asimtvcod = 6) then
                                                call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 2.500.00","")
                                                   returning ws.confirma
                                         end if
                                  end if
				                              if l_desc_2 is null or
				                                 l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                       else
                                          let ws.msgcstvlr = l_desc_2
                                       end if

                                when 12  # traslado de corpos
                                     if l_clscod = '37D' or l_clscod = '37E' or
			                                  l_clscod = '37F' or l_clscod = '37G' or
			                                  l_clscod = '37H'                     then
                                         if (mr_cts11m10.asimtvcod = 4 or
                                             mr_cts11m10.asimtvcod = 7) then
                                                call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1.500.00","")
                                                   returning ws.confirma
                                         end if
                                      end if
				                               if l_desc_2 is null or
				                                  l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                       else
                                          let ws.msgcstvlr = l_desc_2
                                       end if

                                when 16  # transporte rodoviario
                                    if l_clscod = '37D' or l_clscod = '37E' or
			                                 l_clscod = '37F' or l_clscod = '37G' or
			                                 l_clscod = '37H'                     then
                                          if (mr_cts11m10.asimtvcod = 1 or
                                              mr_cts11m10.asimtvcod = 2 or
			                                          mr_cts11m10.asimtvcod = 13) then
                                                    call cts08g01("A","N","",
                                                                  "LIMITE DE COBERTURA RESTRITO",
                                                                  "R$ 1000.00",
                                                                  "")
                                                       returning ws.confirma
                                           end if
                                          if mr_cts11m10.asimtvcod = 3 then
                                               
                                               if cty41g00_valida_assunto(g_documento.c24astcod) then       
                                                                                                            
                                                  call cts08g01("A","N",                                    
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",      
                                                                "AO VALOR DE 1(UMA) PASSAGEM AEREA",        
                                                                "NACIONAL/INTERNACIONAL (MERCOSUL)",        
                                                                "CLASSE ECONOMICA, IDA E VOLTA")            
                                                  returning ws.confirma                                     
                                                                                                            
                                               else                                                         
                                               
                                                  call cts08g01("A","N","",
                                                                "SEM LIMITE DE UTILIZACOES, LIMITADO",
                                                                "A 1(UMA) PASSAGEM RODOVIARIA OU AEREA",
                                                                "NACIONAL NA CLASSE ECONOMICA!")
                                                  returning ws.confirma
                                                  
                                               end if 
                                          end if
                                   end if
				                              if l_desc_2 is null or
				                                 l_desc_2 =  " "  then
                                          let ws.msgcstvlr  = " CAPACIDADE OFICIAL DE LOTACAO "
                                          let ws.msgcstvlr2 = "DO VEICULO DO SEGURADO "
                                      else
                                         if l_clscod = "37B" then  ---> Livre Escolha
                                           let ws.msgcstvlr  = " LIMITE TOTAL POR VIGENCIA: ", l_desc_2
				                                 else
                                             let ws.msgcstvlr = l_desc_2
                                         end if
                                      end if
                                 end case

                     if l_clscod = "37B" then ---> Livre Escolha
                        let ws.msgcstvlr3 = null
                     else
                        if l_clscod <> "37D" and
                           l_clscod <> "37E" and
                           l_clscod <> "37F" and
                           l_clscod <> "37G" and
                           l_clscod <> "37H" then
                          let ws.msgcstvlr3 = "LIMITE DE COBERTURA RESTRITO"
                        end if
                     end if

                     if mr_cts11m10.asitipcod <> 5 or   --> Taxi
                        mr_cts11m10.asimtvcod <> 4 then --> Outros
                        if ws.msgcstvlr2 is null and
                               l_clscod <> "37D" and
                               l_clscod <> "37E" and
                               l_clscod <> "37F" and
                               l_clscod <> "37G" and
                               l_clscod <> "37H" then
                            call cts08g01("A","N","",
                                          ws.msgcstvlr3,
                                          ws.msgcstvlr,"")
                                returning ws.confirma

                          else
                             if l_clscod <> "37D" and
                                l_clscod <> "37E" and
                                l_clscod <> "37F" and
                                l_clscod <> "37G" and
                                l_clscod <> "37H" then
                               call cts08g01("A","N","",
                                             ws.msgcstvlr3,
                                             ws.msgcstvlr,ws.msgcstvlr2)
                                   returning ws.confirma

                               let ws.msgcstvlr2 = null
                              end if
                          end if
                     end if

                     let ws.msgcstvlr = null

                end if
             else
                 if  g_documento.atdsrvnum is not null  and
                     g_documento.atdsrvano is not null  then
                     next field vclcordes
                 end if
             end if

             if mr_cts11m10.asimtvcod = 4  then   ##  OUTRAS SITUACOES
                call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                     returning ws.confirma
             end if

        before field refatdsrvorg
             display by name mr_cts11m10.refatdsrvorg attribute (reverse)

        after field refatdsrvorg
             display by name mr_cts11m10.refatdsrvorg

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field asimtvcod
             end if

             if  mr_cts11m10.refatdsrvorg is null  then
                 if  g_documento.succod    is not null  and
                     g_documento.aplnumdig is not null  then

                     # MOSTRA SERVICOS SOLICITADOS PARA APOLICE INFORMADA
if g_issk.funmat = 601566 then
   display "* cts11m10 - g_documento.succod   = ",g_documento.succod
   display "             g_documento.aplnumdig= ",g_documento.aplnumdig
   display "             g_documento.itmnumdig= ",g_documento.itmnumdig
   display "             g_documento.ramcod   = ",g_documento.ramcod
   display "             l_doc_handle         = ",l_doc_handle
end if
                     call cts11m12 ( g_documento.succod,
                                     g_documento.aplnumdig,
                                     g_documento.itmnumdig,
                                     ""                   ,
                                     g_documento.ramcod   ,
                                     l_doc_handle)
                           returning mr_cts11m10.refatdsrvorg,
                                     mr_cts11m10.refatdsrvnum,
                                     mr_cts11m10.refatdsrvano
                     display by name mr_cts11m10.refatdsrvorg
                     display by name mr_cts11m10.refatdsrvnum
                     display by name mr_cts11m10.refatdsrvano

                     if  mr_cts11m10.refatdsrvnum is null  and
                         mr_cts11m10.refatdsrvano is null  then

                         let a_cts11m10[1].lclbrrnom = m_subbairro[1].lclbrrnom

                         #DIGITAÇÃO PADRONIZADA DE ENDEREÇOS
                         let m_acesso_ind = false

                         let m_atdsrvorg = 2

                         call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                              returning m_acesso_ind

                         if m_acesso_ind = false then

                            call cts06g03(1,
                                          m_atdsrvorg,
                                          w_cts11m10.ligcvntip,
                                          aux_today,
                                          aux_hora,
                                          a_cts11m10[1].lclidttxt,
                                          a_cts11m10[1].cidnom,
                                          a_cts11m10[1].ufdcod,
                                          a_cts11m10[1].brrnom,
                                          a_cts11m10[1].lclbrrnom,
                                          a_cts11m10[1].endzon,
                                          a_cts11m10[1].lgdtip,
                                          a_cts11m10[1].lgdnom,
                                          a_cts11m10[1].lgdnum,
                                          a_cts11m10[1].lgdcep,
                                          a_cts11m10[1].lgdcepcmp,
                                          a_cts11m10[1].lclltt,
                                          a_cts11m10[1].lcllgt,
                                          a_cts11m10[1].lclrefptotxt,
                                          a_cts11m10[1].lclcttnom,
                                          a_cts11m10[1].dddcod,
                                          a_cts11m10[1].lcltelnum,
                                          a_cts11m10[1].c24lclpdrcod,
                                          a_cts11m10[1].ofnnumdig,
                                          a_cts11m10[1].celteldddcod   ,
                                          a_cts11m10[1].celtelnum,
                                          a_cts11m10[1].endcmp,
                                          hist_cts11m10.*, a_cts11m10[1].emeviacod)
                                returning a_cts11m10[1].lclidttxt,
                                          a_cts11m10[1].cidnom,
                                          a_cts11m10[1].ufdcod,
                                          a_cts11m10[1].brrnom,
                                          a_cts11m10[1].lclbrrnom,
                                          a_cts11m10[1].endzon,
                                          a_cts11m10[1].lgdtip,
                                          a_cts11m10[1].lgdnom,
                                          a_cts11m10[1].lgdnum,
                                          a_cts11m10[1].lgdcep,
                                          a_cts11m10[1].lgdcepcmp,
                                          a_cts11m10[1].lclltt,
                                          a_cts11m10[1].lcllgt,
                                          a_cts11m10[1].lclrefptotxt,
                                          a_cts11m10[1].lclcttnom,
                                          a_cts11m10[1].dddcod,
                                          a_cts11m10[1].lcltelnum,
                                          a_cts11m10[1].c24lclpdrcod,
                                          a_cts11m10[1].ofnnumdig,
                                          a_cts11m10[1].celteldddcod   ,
                                          a_cts11m10[1].celtelnum,
                                          a_cts11m10[1].endcmp,
                                          ws.retflg,
                                          hist_cts11m10.*, a_cts11m10[1].emeviacod
                         else
                            call cts06g11(1,
                                          m_atdsrvorg,
                                          w_cts11m10.ligcvntip,
                                          aux_today,
                                          aux_hora,
                                          a_cts11m10[1].lclidttxt,
                                          a_cts11m10[1].cidnom,
                                          a_cts11m10[1].ufdcod,
                                          a_cts11m10[1].brrnom,
                                          a_cts11m10[1].lclbrrnom,
                                          a_cts11m10[1].endzon,
                                          a_cts11m10[1].lgdtip,
                                          a_cts11m10[1].lgdnom,
                                          a_cts11m10[1].lgdnum,
                                          a_cts11m10[1].lgdcep,
                                          a_cts11m10[1].lgdcepcmp,
                                          a_cts11m10[1].lclltt,
                                          a_cts11m10[1].lcllgt,
                                          a_cts11m10[1].lclrefptotxt,
                                          a_cts11m10[1].lclcttnom,
                                          a_cts11m10[1].dddcod,
                                          a_cts11m10[1].lcltelnum,
                                          a_cts11m10[1].c24lclpdrcod,
                                          a_cts11m10[1].ofnnumdig,
                                          a_cts11m10[1].celteldddcod   ,
                                          a_cts11m10[1].celtelnum,
                                          a_cts11m10[1].endcmp,
                                          hist_cts11m10.*, a_cts11m10[1].emeviacod)
                                returning a_cts11m10[1].lclidttxt,
                                          a_cts11m10[1].cidnom,
                                          a_cts11m10[1].ufdcod,
                                          a_cts11m10[1].brrnom,
                                          a_cts11m10[1].lclbrrnom,
                                          a_cts11m10[1].endzon,
                                          a_cts11m10[1].lgdtip,
                                          a_cts11m10[1].lgdnom,
                                          a_cts11m10[1].lgdnum,
                                          a_cts11m10[1].lgdcep,
                                          a_cts11m10[1].lgdcepcmp,
                                          a_cts11m10[1].lclltt,
                                          a_cts11m10[1].lcllgt,
                                          a_cts11m10[1].lclrefptotxt,
                                          a_cts11m10[1].lclcttnom,
                                          a_cts11m10[1].dddcod,
                                          a_cts11m10[1].lcltelnum,
                                          a_cts11m10[1].c24lclpdrcod,
                                          a_cts11m10[1].ofnnumdig,
                                          a_cts11m10[1].celteldddcod   ,
                                          a_cts11m10[1].celtelnum,
                                          a_cts11m10[1].endcmp,
                                          ws.retflg,
                                          hist_cts11m10.*, a_cts11m10[1].emeviacod
                         end if

                         #------------------------------------------------------
                         # Verifica Se o Endereco de Ocorrencia e o Mesmo de
                         # Residencia
                         #------------------------------------------------------

                         if g_documento.lclocodesres = "S" then
                            let w_cts11m10.atdrsdflg = "S"
                         else
                            let w_cts11m10.atdrsdflg = "N"
                         end if


                         # PSI 244589 - Inclusão de Sub-Bairro - Burini
                         let m_subbairro[1].lclbrrnom = a_cts11m10[1].lclbrrnom
                         call cts06g10_monta_brr_subbrr(a_cts11m10[1].brrnom,
                                                        a_cts11m10[1].lclbrrnom)
                              returning a_cts11m10[1].lclbrrnom

                         let a_cts11m10[1].lgdtxt = a_cts11m10[1].lgdtip clipped, " ",
                                                    a_cts11m10[1].lgdnom clipped, " ",
                                                    a_cts11m10[1].lgdnum using "<<<<#"

                         if a_cts11m10[1].cidnom is not null and
                            a_cts11m10[1].ufdcod is not null then
                            call cts14g00 ( g_documento.c24astcod,
                                            "","","","",
                                            a_cts11m10[1].cidnom,
                                            a_cts11m10[1].ufdcod,
                                            "S",
                                            ws.dtparam )
                         end if

                         display by name a_cts11m10[1].lgdtxt
                         display by name a_cts11m10[1].lclbrrnom
                         display by name a_cts11m10[1].endzon
                         display by name a_cts11m10[1].cidnom
                         display by name a_cts11m10[1].ufdcod
                         display by name a_cts11m10[1].lclrefptotxt
                         display by name a_cts11m10[1].lclcttnom
                         display by name a_cts11m10[1].dddcod
                         display by name a_cts11m10[1].lcltelnum
                         display by name a_cts11m10[1].celteldddcod
                         display by name a_cts11m10[1].celtelnum
                         display by name a_cts11m10[1].endcmp


                         let w_cts11m10.atdocrcidnom = a_cts11m10[1].cidnom
                         let w_cts11m10.atdocrufdcod = a_cts11m10[1].ufdcod

                         if  w_cts11m10.atddmccidnom = w_cts11m10.atdocrcidnom  and
                             w_cts11m10.atddmcufdcod = w_cts11m10.atdocrufdcod  then
                             call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                           "A LOCAL DE DOMICILIO!","")
                                  returning ws.confirma
                             if  ws.confirma = "N"  then
                                 next field refatdsrvorg
                             end if
                         end if

                         if a_cts11m10[1].ufdcod = 'EX' then    
                            let ws.retflg = "S"                 
                         end if                                 
                         
                         
                         if  ws.retflg = "N"  then
                             error " Dados referentes ao local incorretos",
                                   " ou nao preenchidos!"
                             next field refatdsrvorg
                         else
                             next field bagflg
                         end if
                     end if
                 else
                     initialize mr_cts11m10.refatdsrvnum,
                                mr_cts11m10.refatdsrvano to null
                     display by name mr_cts11m10.refatdsrvnum,
                                     mr_cts11m10.refatdsrvano
                 end if
             end if

             if  mr_cts11m10.refatdsrvorg <> 4   and   # REMOCAO
                 mr_cts11m10.refatdsrvorg <> 6   and   # DAF
                 mr_cts11m10.refatdsrvorg <> 1   and   # SOCORRO
                 mr_cts11m10.refatdsrvorg <> 2   then  # TRANSPORTE
                 error " Origem do servico de referencia deve",
                       " ser um SOCORRO ou REMOCAO!"
                 next field refatdsrvorg
             end if

        before field refatdsrvnum
             display by name mr_cts11m10.refatdsrvnum attribute (reverse)

        after  field refatdsrvnum
             display by name mr_cts11m10.refatdsrvnum

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvorg
             end if

             if mr_cts11m10.refatdsrvorg is not null  and
                mr_cts11m10.refatdsrvnum is null      then
                error " Numero do servico de referencia nao informado!"
                next field refatdsrvnum
             end if

        before field refatdsrvano
             display by name mr_cts11m10.refatdsrvano attribute (reverse)

        after  field refatdsrvano
             display by name mr_cts11m10.refatdsrvano

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvnum
             end if

             if  mr_cts11m10.refatdsrvnum is not null  then
                 if  mr_cts11m10.refatdsrvano is not null  then
                     if  g_documento.succod    is not null and
                         g_documento.ramcod    is not null and
                         g_documento.aplnumdig is not null then

                         whenever error continue
                         select succod,
                                aplnumdig,
                                itmnumdig
                           into ws.succod,
                                ws.aplnumdig,
                                ws.itmnumdig
                           from DATRSERVAPOL
                          where atdsrvnum = mr_cts11m10.refatdsrvnum
                            and atdsrvano = mr_cts11m10.refatdsrvano
                         whenever error continue

                         if  sqlca.sqlcode <> notfound  then
                             if  ws.succod    <> g_documento.succod     or
                                 ws.aplnumdig <> g_documento.aplnumdig  or
                                 ws.itmnumdig <> g_documento.itmnumdig  then
                                 error " Servico original nao pertence a esta apolice! "
                                 next field refatdsrvorg
                             end if
                         end if
                     end if
                 else
                     error " Ano do servico original nao informado!"
                     next field refatdsrvano
                 end if
             end if

             if  g_documento.atdsrvnum   is     null  and
                 g_documento.atdsrvano   is     null  and
                 mr_cts11m10.refatdsrvorg is not null  and
                 mr_cts11m10.refatdsrvnum is not null  and
                 mr_cts11m10.refatdsrvano is not null  then

                 select atdsrvorg
                   into ws.refatdsrvorg
                   from DATMSERVICO
                  where atdsrvnum = mr_cts11m10.refatdsrvnum
                    and atdsrvano = mr_cts11m10.refatdsrvano

                 if  ws.refatdsrvorg <> mr_cts11m10.refatdsrvorg  then
                     error " Origem do numero de servico invalido.",
                           " A origem deve ser ", ws.refatdsrvorg using "&&"
                     next field refatdsrvorg
                 end if

                 call ctx04g00_local_gps( mr_cts11m10.refatdsrvnum,
                                          mr_cts11m10.refatdsrvano,
                                          1                       )
                                returning a_cts11m10[1].lclidttxt   ,
                                          a_cts11m10[1].lgdtip      ,
                                          a_cts11m10[1].lgdnom      ,
                                          a_cts11m10[1].lgdnum      ,
                                          a_cts11m10[1].lclbrrnom   ,
                                          a_cts11m10[1].brrnom      ,
                                          a_cts11m10[1].cidnom      ,
                                          a_cts11m10[1].ufdcod      ,
                                          a_cts11m10[1].lclrefptotxt,
                                          a_cts11m10[1].endzon      ,
                                          a_cts11m10[1].lgdcep      ,
                                          a_cts11m10[1].lgdcepcmp   ,
                                          a_cts11m10[1].lclltt      ,
                                          a_cts11m10[1].lcllgt      ,
                                          a_cts11m10[1].dddcod      ,
                                          a_cts11m10[1].lcltelnum   ,
                                          a_cts11m10[1].lclcttnom   ,
                                          a_cts11m10[1].c24lclpdrcod,
                                          a_cts11m10[1].celteldddcod,
                                          a_cts11m10[1].celtelnum   ,
                                          a_cts11m10[1].endcmp,
                                          ws.sqlcode, a_cts11m10[1].emeviacod
                 # PSI 244589 - Inclusão de Sub-Bairro - Burini
                 let m_subbairro[1].lclbrrnom = a_cts11m10[1].lclbrrnom
                 call cts06g10_monta_brr_subbrr(a_cts11m10[1].brrnom,
                                                a_cts11m10[1].lclbrrnom)
                      returning a_cts11m10[1].lclbrrnom

                 select ofnnumdig
                   into a_cts11m10[1].ofnnumdig
                   from datmlcl
                  where atdsrvano = g_documento.atdsrvano
                    and atdsrvnum = g_documento.atdsrvnum
                    and c24endtip = 1

                 if  ws.sqlcode <> 0  then
                     error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
                           " do local de ocorrencia. AVISE A INFORMATICA!"
                     next field refatdsrvorg
                 end if

                 let a_cts11m10[1].lgdtxt = a_cts11m10[1].lgdtip clipped, " ",
                                            a_cts11m10[1].lgdnom clipped, " ",
                                            a_cts11m10[1].lgdnum using "<<<<#"

                 display by name a_cts11m10[1].lgdtxt,
                                 a_cts11m10[1].lclbrrnom,
                                 a_cts11m10[1].cidnom,
                                 a_cts11m10[1].ufdcod,
                                 a_cts11m10[1].lclrefptotxt,
                                 a_cts11m10[1].endzon,
                                 a_cts11m10[1].dddcod,
                                 a_cts11m10[1].lcltelnum,
                                 a_cts11m10[1].lclcttnom,
                                 a_cts11m10[1].celteldddcod,
                                 a_cts11m10[1].celtelnum,
                                 a_cts11m10[1].endcmp
             end if
             let a_cts11m10[1].lclbrrnom = m_subbairro[1].lclbrrnom
             #DIGITAÇÃO PADRONIZADA DE ENDEREÇOS
             let m_acesso_ind = false
             let m_atdsrvorg = 2
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind

             if m_acesso_ind = false then

                call cts06g03(1,
                              m_atdsrvorg,
                              w_cts11m10.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts11m10[1].lclidttxt,
                              a_cts11m10[1].cidnom,
                              a_cts11m10[1].ufdcod,
                              a_cts11m10[1].brrnom,
                              a_cts11m10[1].lclbrrnom,
                              a_cts11m10[1].endzon,
                              a_cts11m10[1].lgdtip,
                              a_cts11m10[1].lgdnom,
                              a_cts11m10[1].lgdnum,
                              a_cts11m10[1].lgdcep,
                              a_cts11m10[1].lgdcepcmp,
                              a_cts11m10[1].lclltt,
                              a_cts11m10[1].lcllgt,
                              a_cts11m10[1].lclrefptotxt,
                              a_cts11m10[1].lclcttnom,
                              a_cts11m10[1].dddcod,
                              a_cts11m10[1].lcltelnum,
                              a_cts11m10[1].c24lclpdrcod,
                              a_cts11m10[1].ofnnumdig,
                              a_cts11m10[1].celteldddcod   ,
                              a_cts11m10[1].celtelnum,
                              a_cts11m10[1].endcmp,
                              hist_cts11m10.*, a_cts11m10[1].emeviacod)
                    returning a_cts11m10[1].lclidttxt,
                              a_cts11m10[1].cidnom,
                              a_cts11m10[1].ufdcod,
                              a_cts11m10[1].brrnom,
                              a_cts11m10[1].lclbrrnom,
                              a_cts11m10[1].endzon,
                              a_cts11m10[1].lgdtip,
                              a_cts11m10[1].lgdnom,
                              a_cts11m10[1].lgdnum,
                              a_cts11m10[1].lgdcep,
                              a_cts11m10[1].lgdcepcmp,
                              a_cts11m10[1].lclltt,
                              a_cts11m10[1].lcllgt,
                              a_cts11m10[1].lclrefptotxt,
                              a_cts11m10[1].lclcttnom,
                              a_cts11m10[1].dddcod,
                              a_cts11m10[1].lcltelnum,
                              a_cts11m10[1].c24lclpdrcod,
                              a_cts11m10[1].ofnnumdig,
                              a_cts11m10[1].celteldddcod   ,
                              a_cts11m10[1].celtelnum,
                              a_cts11m10[1].endcmp,
                              ws.retflg,
                              hist_cts11m10.*, a_cts11m10[1].emeviacod
             else
                call cts06g11(1,
                              m_atdsrvorg,
                              w_cts11m10.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts11m10[1].lclidttxt,
                              a_cts11m10[1].cidnom,
                              a_cts11m10[1].ufdcod,
                              a_cts11m10[1].brrnom,
                              a_cts11m10[1].lclbrrnom,
                              a_cts11m10[1].endzon,
                              a_cts11m10[1].lgdtip,
                              a_cts11m10[1].lgdnom,
                              a_cts11m10[1].lgdnum,
                              a_cts11m10[1].lgdcep,
                              a_cts11m10[1].lgdcepcmp,
                              a_cts11m10[1].lclltt,
                              a_cts11m10[1].lcllgt,
                              a_cts11m10[1].lclrefptotxt,
                              a_cts11m10[1].lclcttnom,
                              a_cts11m10[1].dddcod,
                              a_cts11m10[1].lcltelnum,
                              a_cts11m10[1].c24lclpdrcod,
                              a_cts11m10[1].ofnnumdig,
                              a_cts11m10[1].celteldddcod   ,
                              a_cts11m10[1].celtelnum,
                              a_cts11m10[1].endcmp,
                              hist_cts11m10.*, a_cts11m10[1].emeviacod)
                    returning a_cts11m10[1].lclidttxt,
                              a_cts11m10[1].cidnom,
                              a_cts11m10[1].ufdcod,
                              a_cts11m10[1].brrnom,
                              a_cts11m10[1].lclbrrnom,
                              a_cts11m10[1].endzon,
                              a_cts11m10[1].lgdtip,
                              a_cts11m10[1].lgdnom,
                              a_cts11m10[1].lgdnum,
                              a_cts11m10[1].lgdcep,
                              a_cts11m10[1].lgdcepcmp,
                              a_cts11m10[1].lclltt,
                              a_cts11m10[1].lcllgt,
                              a_cts11m10[1].lclrefptotxt,
                              a_cts11m10[1].lclcttnom,
                              a_cts11m10[1].dddcod,
                              a_cts11m10[1].lcltelnum,
                              a_cts11m10[1].c24lclpdrcod,
                              a_cts11m10[1].ofnnumdig,
                              a_cts11m10[1].celteldddcod   ,
                              a_cts11m10[1].celtelnum,
                              a_cts11m10[1].endcmp,
                              ws.retflg,
                              hist_cts11m10.*, a_cts11m10[1].emeviacod
             end if

             #---------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #---------------------------------------------------------------

             if g_documento.lclocodesres = "S" then
                let w_cts11m10.atdrsdflg = "S"
             else
                let w_cts11m10.atdrsdflg = "N"
             end if



             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts11m10[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts11m10[1].brrnom,
                                            a_cts11m10[1].lclbrrnom)
                  returning a_cts11m10[1].lclbrrnom

             let a_cts11m10[1].lgdtxt = a_cts11m10[1].lgdtip clipped, " ",
                                        a_cts11m10[1].lgdnom clipped, " ",
                                        a_cts11m10[1].lgdnum using "<<<<#"

             if a_cts11m10[1].cidnom is not null and
                a_cts11m10[1].ufdcod is not null then
                call cts14g00 (g_documento.c24astcod,
                               "","","","",
                               a_cts11m10[1].cidnom,
                               a_cts11m10[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts11m10[1].lgdtxt
             display by name a_cts11m10[1].lclbrrnom
             display by name a_cts11m10[1].endzon
             display by name a_cts11m10[1].cidnom
             display by name a_cts11m10[1].ufdcod
             display by name a_cts11m10[1].lclrefptotxt
             display by name a_cts11m10[1].lclcttnom
             display by name a_cts11m10[1].dddcod
             display by name a_cts11m10[1].lcltelnum
             display by name a_cts11m10[1].celteldddcod
             display by name a_cts11m10[1].celtelnum
             display by name a_cts11m10[1].endcmp

             let w_cts11m10.atdocrcidnom = a_cts11m10[1].cidnom
             let w_cts11m10.atdocrufdcod = a_cts11m10[1].ufdcod

             if  w_cts11m10.atddmccidnom = w_cts11m10.atdocrcidnom  and
                 w_cts11m10.atddmcufdcod = w_cts11m10.atdocrufdcod  then
                 call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                               "A LOCAL DE DOMICILIO!","") returning ws.confirma
                 if  ws.confirma = "N"  then
                     next field refatdsrvorg
                 end if
             end if

             if a_cts11m10[1].ufdcod = "EX" then 
                let  ws.retflg = "S"             
             end if                              
             
             
             if  ws.retflg = "N"  then
                 error " Dados referentes ao local incorretos ou nao preenchidos!"
                 next field refatdsrvorg
             end if

        before field bagflg
             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  and
                 mr_cts11m10.asitipcod  <> 5     then
                 let mr_cts11m10.bagflg = "N"
             end if

             display by name mr_cts11m10.bagflg    attribute (reverse)

        after field bagflg
             display by name mr_cts11m10.bagflg

             if  fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")  then
                 if  mr_cts11m10.bagflg is null  then
                     error " Bagagem deve ser informada!"
                     next field bagflg
                 else
                     if  mr_cts11m10.bagflg <> "S"  and
                         mr_cts11m10.bagflg <> "N"  then
                         error " Informe (S)im ou (N)ao!"
                         next field bagflg
                     end if
                 end if

                 if  mr_cts11m10.bagflg = "S"  then
                     call cts08g01("Q","N","QUAL A QUANTIDADE E VOLUME",
                                   "DE BAGAGEM ?","",
                                   "REGISTRE INFORMACAO NO HISTORICO")
                          returning ws.confirma
                 end if
                 if  mr_cts11m10.asitipcod = 10  then  ###  Passagem Aerea
                     display by name mr_cts11m10.dstcidnom
                     display by name mr_cts11m10.dstufdcod
                 else
                    let a_cts11m10[3].* = a_cts11m10[2].*

                    let a_cts11m10[2].lclbrrnom = m_subbairro[2].lclbrrnom
                    #DIGITAÇÃO PADRONIZADA DE ENDEREÇOS
                    let m_acesso_ind = false
                    let m_atdsrvorg = 2
                    call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                         returning m_acesso_ind

                    if mr_cts11m10.asitipcod <> 10 then                                               
                      if (g_documento.c24astcod = 'KM1'   or                                           
                          g_documento.c24astcod = 'KM2'   or                                          
                          g_documento.c24astcod = 'KM3' ) then                                       
                    				
                    			call cts08g01("C","S",""," DESTINO SERA O BRASIL ? ","", "")             
                    			returning l_resposta                                                  
                                                                                                     
                    		  if l_resposta = "S" then                                                   
                    			  let a_cts11m10[2].ufdcod = ""                                            
                    			  let a_cts11m10[2].lclidttxt = "BRASIL"                                   
                          	else                                                                     
                          	    let m_sql = "select cpocod "                                         
                                           ,",cpodes "                                          
                                           ,"from datkdominio "                                     
                                           ,"where cponom = 'paises_mercosul' "                      
                                           ,"order by cpodes "                                          
                    		      
                    		      call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",    
                                                  'N',m_sql,"",'D')                                          
                              returning ws.erro,                                          
                    					          ws.codpais,                                                 
                    					          ws.despais                                                  
                                                                                                          					                               
                    						let a_cts11m10[2].cidnom = ws.despais                                
                    						let a_cts11m10[2].ufdcod = "EX"                                      
                           end if                                                                    
                       end if                                                                        
                    end if                                                                           
      
                    if m_acesso_ind = false then

                       call cts06g03(2,
                                     m_atdsrvorg,
                                     w_cts11m10.ligcvntip,
                                     aux_today,
                                     aux_hora,
                                     a_cts11m10[2].lclidttxt,
                                     a_cts11m10[2].cidnom,
                                     a_cts11m10[2].ufdcod,
                                     a_cts11m10[2].brrnom,
                                     a_cts11m10[2].lclbrrnom,
                                     a_cts11m10[2].endzon,
                                     a_cts11m10[2].lgdtip,
                                     a_cts11m10[2].lgdnom,
                                     a_cts11m10[2].lgdnum,
                                     a_cts11m10[2].lgdcep,
                                     a_cts11m10[2].lgdcepcmp,
                                     a_cts11m10[2].lclltt,
                                     a_cts11m10[2].lcllgt,
                                     a_cts11m10[2].lclrefptotxt,
                                     a_cts11m10[2].lclcttnom,
                                     a_cts11m10[2].dddcod,
                                     a_cts11m10[2].lcltelnum,
                                     a_cts11m10[2].c24lclpdrcod,
                                     a_cts11m10[2].ofnnumdig,
                                     a_cts11m10[2].celteldddcod   ,
                                     a_cts11m10[2].celtelnum,
                                     a_cts11m10[2].endcmp,
                                     hist_cts11m10.*, a_cts11m10[2].emeviacod)
                           returning a_cts11m10[2].lclidttxt,
                                     a_cts11m10[2].cidnom,
                                     a_cts11m10[2].ufdcod,
                                     a_cts11m10[2].brrnom,
                                     a_cts11m10[2].lclbrrnom,
                                     a_cts11m10[2].endzon,
                                     a_cts11m10[2].lgdtip,
                                     a_cts11m10[2].lgdnom,
                                     a_cts11m10[2].lgdnum,
                                     a_cts11m10[2].lgdcep,
                                     a_cts11m10[2].lgdcepcmp,
                                     a_cts11m10[2].lclltt,
                                     a_cts11m10[2].lcllgt,
                                     a_cts11m10[2].lclrefptotxt,
                                     a_cts11m10[2].lclcttnom,
                                     a_cts11m10[2].dddcod,
                                     a_cts11m10[2].lcltelnum,
                                     a_cts11m10[2].c24lclpdrcod,
                                     a_cts11m10[2].ofnnumdig,
                                     a_cts11m10[2].celteldddcod   ,
                                     a_cts11m10[2].celtelnum,
                                     a_cts11m10[2].endcmp,
                                     ws.retflg,
                                     hist_cts11m10.*, a_cts11m10[2].emeviacod
                    else
                       call cts06g11(2,
                                     m_atdsrvorg,
                                     w_cts11m10.ligcvntip,
                                     aux_today,
                                     aux_hora,
                                     a_cts11m10[2].lclidttxt,
                                     a_cts11m10[2].cidnom,
                                     a_cts11m10[2].ufdcod,
                                     a_cts11m10[2].brrnom,
                                     a_cts11m10[2].lclbrrnom,
                                     a_cts11m10[2].endzon,
                                     a_cts11m10[2].lgdtip,
                                     a_cts11m10[2].lgdnom,
                                     a_cts11m10[2].lgdnum,
                                     a_cts11m10[2].lgdcep,
                                     a_cts11m10[2].lgdcepcmp,
                                     a_cts11m10[2].lclltt,
                                     a_cts11m10[2].lcllgt,
                                     a_cts11m10[2].lclrefptotxt,
                                     a_cts11m10[2].lclcttnom,
                                     a_cts11m10[2].dddcod,
                                     a_cts11m10[2].lcltelnum,
                                     a_cts11m10[2].c24lclpdrcod,
                                     a_cts11m10[2].ofnnumdig,
                                     a_cts11m10[2].celteldddcod   ,
                                     a_cts11m10[2].celtelnum,
                                     a_cts11m10[2].endcmp,
                                     hist_cts11m10.*, a_cts11m10[2].emeviacod)
                           returning a_cts11m10[2].lclidttxt,
                                     a_cts11m10[2].cidnom,
                                     a_cts11m10[2].ufdcod,
                                     a_cts11m10[2].brrnom,
                                     a_cts11m10[2].lclbrrnom,
                                     a_cts11m10[2].endzon,
                                     a_cts11m10[2].lgdtip,
                                     a_cts11m10[2].lgdnom,
                                     a_cts11m10[2].lgdnum,
                                     a_cts11m10[2].lgdcep,
                                     a_cts11m10[2].lgdcepcmp,
                                     a_cts11m10[2].lclltt,
                                     a_cts11m10[2].lcllgt,
                                     a_cts11m10[2].lclrefptotxt,
                                     a_cts11m10[2].lclcttnom,
                                     a_cts11m10[2].dddcod,
                                     a_cts11m10[2].lcltelnum,
                                     a_cts11m10[2].c24lclpdrcod,
                                     a_cts11m10[2].ofnnumdig,
                                     a_cts11m10[2].celteldddcod   ,
                                     a_cts11m10[2].celtelnum,
                                     a_cts11m10[2].endcmp,
                                     ws.retflg,
                                     hist_cts11m10.*, a_cts11m10[2].emeviacod
                    end if

                    # PSI 244589 - Inclusão de Sub-Bairro - Burini
                    let m_subbairro[2].lclbrrnom = a_cts11m10[2].lclbrrnom
                    call cts06g10_monta_brr_subbrr(a_cts11m10[2].brrnom,
                                                   a_cts11m10[2].lclbrrnom)
                         returning a_cts11m10[2].lclbrrnom

                    let a_cts11m10[2].lgdtxt = a_cts11m10[2].lgdtip clipped, " ",
                                               a_cts11m10[2].lgdnom clipped, " ",
                                               a_cts11m10[2].lgdnum using "<<<<#"

                    let mr_cts11m10.dstlcl    = a_cts11m10[2].lclidttxt
                    let mr_cts11m10.dstlgdtxt = a_cts11m10[2].lgdtxt
                    let mr_cts11m10.dstbrrnom = a_cts11m10[2].lclbrrnom
                    let mr_cts11m10.dstcidnom = a_cts11m10[2].cidnom
                    let mr_cts11m10.dstufdcod = a_cts11m10[2].ufdcod

                    if  a_cts11m10[2].lclltt <> a_cts11m10[3].lclltt or
                        a_cts11m10[2].lcllgt <> a_cts11m10[3].lcllgt or
                        (a_cts11m10[3].lclltt is null and a_cts11m10[2].lclltt is not null) or
                        (a_cts11m10[3].lcllgt is null and a_cts11m10[2].lcllgt is not null) then

                        if g_documento.c24astcod <> 'KM1' and
				                   g_documento.c24astcod <> 'KM2' and
				                   g_documento.c24astcod <> 'KM3' then
                                              
                           #CALCULA A DISTANCIA ENTRE A ORIGEM E O DESTINO
                           call cts00m33(1,
                                         a_cts11m10[1].lclltt,
                                         a_cts11m10[1].lcllgt,
                                         a_cts11m10[2].lclltt,
                                         a_cts11m10[2].lcllgt) 
                        end if 
                                         
                    end if

                    if a_cts11m10[2].cidnom is not null and
                       a_cts11m10[2].ufdcod is not null then
                       call cts14g00 (g_documento.c24astcod,
                                      "","","","",
                                      a_cts11m10[2].cidnom,
                                      a_cts11m10[2].ufdcod,
                                      "S",
                                      ws.dtparam)
                    end if

                    display by name mr_cts11m10.dstlcl   ,
                                    mr_cts11m10.dstlgdtxt,
                                    mr_cts11m10.dstbrrnom,
                                    mr_cts11m10.dstcidnom,
                                    mr_cts11m10.dstufdcod

                    if a_cts11m10[2].ufdcod = "EX" then 
                       let  ws.retflg = "S"             
                    end if                              
                    
                    
                    if  ws.retflg = "N"  then
                        error " Dados referentes ao local incorretos ou nao",
                              " preenchidos!"
                        next field bagflg
                    end if
                 end if
             end if

             # CADASTRO DE PASSAGEIROS
             error " Informe a relacao de passageiros!"
             call cts11m11 (a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*)
                  returning a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*

          before field imdsrvflg
                 if  mr_cts11m10.asitipcod <> 5  then

                     let mr_cts11m10.imdsrvflg    = "S"
                     let w_cts11m10.atdpvtretflg = "S"
                     let w_cts11m10.atdhorpvt    = "00:00"
                     let mr_cts11m10.atdprinvlcod = 2

                     select cpodes
                       into mr_cts11m10.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts11m10.atdprinvlcod

                     initialize w_cts11m10.atddatprg to null
                     initialize w_cts11m10.atdhorprg to null

                     display by name mr_cts11m10.imdsrvflg
                     display by name mr_cts11m10.atdprinvlcod
                     display by name mr_cts11m10.atdprinvldes

                     if  fgl_lastkey() = fgl_keyval("up")    or
                         fgl_lastkey() = fgl_keyval("left")  then
                         next field bagflg
                     else
                         next field atdlibflg
                     end if
                 else
                     display by name mr_cts11m10.imdsrvflg  attribute (reverse)
                 end if

          after  field imdsrvflg
                 display by name mr_cts11m10.imdsrvflg

                 # PSI-2013-00440PR
                 if (m_imdsrvflg is null) or (m_imdsrvflg != mr_cts11m10.imdsrvflg)
                    then
                    let m_rsrchv = null
                    let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
                 end if
                 
                 if (m_cidnom != a_cts11m10[1].cidnom) or
                    (m_ufdcod != a_cts11m10[1].ufdcod) then
                    let m_altcidufd = true
                    let m_operacao = 0  # regular novamente
                    #display 'cts11m10 - Elegivel para regulacao, alterou cidade/uf'
                 else
                    let m_altcidufd = false
                 end if
                 
                 # na inclusao dados nulos, igualar aos digitados
                 if m_imdsrvflg is null then
                    let m_imdsrvflg = mr_cts11m10.imdsrvflg
                 end if
                 
                 if m_cidnom is null then
                    let m_cidnom = a_cts11m10[1].cidnom
                 end if
                 
                 if m_ufdcod is null then
                    let m_ufdcod = a_cts11m10[1].ufdcod
                 end if
                 
                 # Envia a chave antiga no input quando alteracao. 
                 # Se for a situacao INC, regulou, voltou para o laudo (CTRL+C) e regulou  
                 # novamente manda a mesma pra ver se ainda e valida
                 if g_documento.acao = "ALT"
                    then
                    let m_rsrchv = m_rsrchvant
                 end if
                 # PSI-2013-00440PR
                 
                 if  fgl_lastkey() <> fgl_keyval("up")    and
                     fgl_lastkey() <> fgl_keyval("left")  then
                     if  mr_cts11m10.imdsrvflg is null   then
                         error " Servico imediato e' item obrigatorio!"
                         next field imdsrvflg
                     else
                         if  mr_cts11m10.imdsrvflg <> "S"  and
                             mr_cts11m10.imdsrvflg <> "N"  then
                             error " Informe (S)im ou (N)ao!"
                             next field imdsrvflg
                         end if
                     end if

                     # INICIO PSI-2013-00440PR
                     # Considerado que todas as regras de negocio sobre a questao da regulacao
                     # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
                     if m_agendaw = true
                        then
                        # obter a chave de regulacao no AW
                        call cts02m08(w_cts11m10.atdfnlflg,
                                      mr_cts11m10.imdsrvflg,
                                      m_altcidufd,
                                      mr_cts11m10.prslocflg,
                                      w_cts11m10.atdhorpvt,
                                      w_cts11m10.atddatprg,
                                      w_cts11m10.atdhorprg,
                                      w_cts11m10.atdpvtretflg,
                                      m_rsrchv,
                                      m_operacao,
                                      "",
                                      a_cts11m10[1].cidnom,
                                      a_cts11m10[1].ufdcod,
                                      "",   # codigo de assistencia, nao existe no Ct24h
                                      mr_cts11m10.vclcoddig,
                                      m_ctgtrfcod,
                                      mr_cts11m10.imdsrvflg,
                                      a_cts11m10[1].c24lclpdrcod,
                                      a_cts11m10[1].lclltt,
                                      a_cts11m10[1].lcllgt,
                                      g_documento.ciaempcod,
                                      g_documento.atdsrvorg,
                                      mr_cts11m10.asitipcod,
                                      "",   # natureza nao tem, identifica pelo asitipcod  
                                      "")   # sub-natureza nao tem, identifica pelo asitipcod 
                            returning w_cts11m10.atdhorpvt,
                                      w_cts11m10.atddatprg,
                                      w_cts11m10.atdhorprg,
                                      w_cts11m10.atdpvtretflg,
                                      mr_cts11m10.imdsrvflg,
                                      m_rsrchv,
                                      m_operacao,
                                      m_altdathor
                                   
                        display by name mr_cts11m10.imdsrvflg
                 
                        if int_flag
                           then
                           let int_flag = false
                           next field imdsrvflg
                        end if
                        
                     else  # regulação antiga
		     
                        call cts02m03(w_cts11m10.atdfnlflg,
                                      mr_cts11m10.imdsrvflg,
                                      w_cts11m10.atdhorpvt,
                                      w_cts11m10.atddatprg,
                                      w_cts11m10.atdhorprg,
                                      w_cts11m10.atdpvtretflg)
                            returning w_cts11m10.atdhorpvt,
                                      w_cts11m10.atddatprg,
                                      w_cts11m10.atdhorprg,
                                      w_cts11m10.atdpvtretflg
              
                        
                        if  mr_cts11m10.imdsrvflg = "S"  then
                            if  w_cts11m10.atdhorpvt is null  then
                                error " Previsao (em horas) nao informada para servico",
                                      " imediato!"
                                next field imdsrvflg
                            end if
                        else
                            if  w_cts11m10.atddatprg   is null        or
                                w_cts11m10.atdhorprg   is null        then
                                error " Faltam dados para servico programado!"
                                next field imdsrvflg
                            else
                                let mr_cts11m10.atdprinvlcod  = 2
   
                                select cpodes
                                  into mr_cts11m10.atdprinvldes
                                  from iddkdominio
                                 where cponom = "atdprinvlcod"
                                   and cpocod = mr_cts11m10.atdprinvlcod
   
                                 display by name mr_cts11m10.atdprinvlcod
                                 display by name mr_cts11m10.atdprinvldes
   
                                 next field atdlibflg
                            end if
                        end if
                     end if
                 end if

          before field atdprinvlcod
                 display by name mr_cts11m10.atdprinvlcod attribute (reverse)

          after  field atdprinvlcod
                 display by name mr_cts11m10.atdprinvlcod

                 if  fgl_lastkey() <> fgl_keyval("up")   and
                     fgl_lastkey() <> fgl_keyval("left") then
                     if mr_cts11m10.atdprinvlcod is null then
                        error " Nivel de prioridade deve ser informado!"
                        next field atdprinvlcod
                     end if

                     select cpodes
                       into mr_cts11m10.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts11m10.atdprinvlcod

                     if  sqlca.sqlcode = notfound then
                         error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal",
                               " ou (3)-Urgente"
                         next field atdprinvlcod
                     end if

                     display by name mr_cts11m10.atdprinvldes
                 end if

          before field atdlibflg
                 display by name mr_cts11m10.atdlibflg attribute (reverse)

                 if  g_documento.atdsrvnum is not null  and
                     w_cts11m10.atdfnlflg  =  "S"       then
                     exit input
                 end if

          after  field atdlibflg
                 display by name mr_cts11m10.atdlibflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field atdprinvlcod
                 end if

                 if  mr_cts11m10.atdlibflg is null then
                     error " Envio liberado deve ser informado!"
                     next field atdlibflg
                 end if

                 if  mr_cts11m10.atdlibflg <> "S"  and
                     mr_cts11m10.atdlibflg <> "N"  then
                     error " Informe (S)im ou (N)ao!"
                     next field atdlibflg
                 end if

                 let w_cts11m10.atdlibflg = mr_cts11m10.atdlibflg

                 if  w_cts11m10.atdlibflg is null   then
                     next field atdlibflg
                 end if

                 display by name mr_cts11m10.atdlibflg

                 if  mr_cts11m10.asitipcod = 10  then
                     call cts11m08(w_cts11m10.trppfrdat,
                                   w_cts11m10.trppfrhor)
                         returning w_cts11m10.trppfrdat,
                                   w_cts11m10.trppfrhor

                     if  w_cts11m10.trppfrdat is null  then
                         call cts08g01("C","S","","NAO FOI PREENCHIDO NENHUMA",
                                       "PREFERENCIA DE VIAGEM!","")
                              returning ws.confirma
                         if  ws.confirma = "N"  then
                             next field atdlibflg
                         end if
                     end if
                 end if

                 if  w_cts11m10.antlibflg is null  then
                     if  w_cts11m10.atdlibflg = "S"  then
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let mr_cts11m10.atdlibhor = l_hora2
                         let mr_cts11m10.atdlibdat = l_data
                     else
                         let mr_cts11m10.atdlibflg = "N"
                         display by name mr_cts11m10.atdlibflg
                         initialize mr_cts11m10.atdlibhor to null
                         initialize mr_cts11m10.atdlibdat to null
                     end if
                 else
                     select atdfnlflg
                       from datmservico
                      where atdsrvnum = g_documento.atdsrvnum  and
                            atdsrvano = g_documento.atdsrvano  and
                            atdfnlflg in ("N","A")

                     if  sqlca.sqlcode = notfound  then
                         error " Servico ja' acionado nao pode ser alterado!"
                         let m_srv_acionado = true
                         call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                           " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                               "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                              returning ws.confirma
                         next field atdlibflg
                     end if

                     if  w_cts11m10.antlibflg = "S"  then
                         if  w_cts11m10.atdlibflg = "S"  then
                             exit input
                         else
                             error " A liberacao do servico nao pode ser cancelada!"
                             next field atdlibflg
                             let mr_cts11m10.atdlibflg = "N"
                             display by name mr_cts11m10.atdlibflg
                             initialize mr_cts11m10.atdlibhor to null
                             initialize mr_cts11m10.atdlibdat to null
                             error " Liberacao do servico cancelada!"
                             sleep 1
                             exit input
                         end if
                     else
                         if  w_cts11m10.antlibflg = "N"  then
                             if  w_cts11m10.atdlibflg = "N"  then
                                 exit input
                             else
                                 call cts40g03_data_hora_banco(2)
                                      returning l_data, l_hora2
                                 let mr_cts11m10.atdlibhor = l_hora2
                                 let mr_cts11m10.atdlibdat = l_data
                                 exit input
                             end if
                         end if
                     end if
                 end if

          before field prslocflg
                 if  g_documento.atdsrvnum  is not null   or
                     g_documento.atdsrvano  is not null   then
                     if  fgl_lastkey() = fgl_keyval("up")   or
                         fgl_lastkey() = fgl_keyval("left") then
                         next field atdlibflg
                     else
                         let mr_cts11m10.prslocflg = "N"
                         next field frmflg
                     end if
                 end if

                 if  mr_cts11m10.asitipcod = 10  then   ###  Passagem Aerea
                     if  fgl_lastkey() = fgl_keyval("up")   or
                         fgl_lastkey() = fgl_keyval("left") then
                         next field atdlibflg
                     else
                         initialize mr_cts11m10.prslocflg  to null
                         next field frmflg
                     end if
                 end if

                 if  mr_cts11m10.imdsrvflg   = "N" then
                     initialize w_cts11m10.c24nomctt  to null
                     let mr_cts11m10.prslocflg = "N"
                     display by name mr_cts11m10.prslocflg
                     next field frmflg
                 end if

                 display by name mr_cts11m10.prslocflg attribute (reverse)

          after  field prslocflg
                 display by name mr_cts11m10.prslocflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field atdlibflg
                 end if

                 if  ((mr_cts11m10.prslocflg  is null)  or
                      (mr_cts11m10.prslocflg  <> "S"    and
                     mr_cts11m10.prslocflg    <> "N"))  then
                     error " Prestador no local: (S)im ou (N)ao!"
                     next field prslocflg
                 end if

                 if  mr_cts11m10.prslocflg = "S"   then
                     call ctn24c01()
                          returning w_cts11m10.atdprscod, w_cts11m10.srrcoddig,
                                    w_cts11m10.atdvclsgl, w_cts11m10.socvclcod

                     if  w_cts11m10.atdprscod  is null then
                         error " Faltam dados para prestador no local!"
                         next field prslocflg
                     end if

                     let mr_cts11m10.atdlibhor = aux_hora
                     let mr_cts11m10.atdlibdat = aux_today
                     let w_cts11m10.atdfnlflg = "S"
                     let w_cts11m10.atdetpcod =  4

                     call cts40g03_data_hora_banco(2)
                         returning l_data, l_hora2

                     let w_cts11m10.cnldat    = l_data
                     let w_cts11m10.atdfnlhor = l_hora2
                     let w_cts11m10.c24opemat = g_issk.funmat

                     let mr_cts11m10.frmflg    = "N"
                     display by name mr_cts11m10.frmflg
                     exit input
                 else
                     initialize w_cts11m10.funmat   ,
                                w_cts11m10.cnldat   ,
                                w_cts11m10.atdfnlhor,
                                w_cts11m10.c24opemat,
                                w_cts11m10.atdfnlflg,
                                w_cts11m10.atdetpcod,
                                w_cts11m10.atdprscod,
                                w_cts11m10.atdcstvlr,
                                w_cts11m10.c24nomctt  to null
                 end if


          before field frmflg
                 if  w_cts11m10.operacao = "i"  then
                     let mr_cts11m10.frmflg = "N"
                     display by name mr_cts11m10.frmflg attribute (reverse)
                 end if

          after  field frmflg
                 display by name mr_cts11m10.frmflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field prslocflg
                 end if

                 if  mr_cts11m10.frmflg = "S"  then
                     if  mr_cts11m10.atdlibflg = "N"  then
                         error " Nao e' possivel registrar servico nao liberado",
                               " via formulario!"
                         next field atdlibflg
                     end if

                     call cts02m05(2) returning w_cts11m10.data,
                                                w_cts11m10.hora,
                                                w_cts11m10.funmat,
                                                w_cts11m10.cnldat,
                                                w_cts11m10.atdfnlhor,
                                                w_cts11m10.c24opemat,
                                                w_cts11m10.atdprscod

                     if  w_cts11m10.hora      is null or
                         w_cts11m10.data      is null or
                         w_cts11m10.funmat    is null or
                         w_cts11m10.cnldat    is null or
                         w_cts11m10.atdfnlhor is null or
                         w_cts11m10.c24opemat is null or
                         w_cts11m10.atdprscod is null  then
                         error " Faltam dados para entrada via formulario!"
                         next field frmflg
                     end if

                     let mr_cts11m10.atdlibhor = w_cts11m10.hora
                     let mr_cts11m10.atdlibdat = w_cts11m10.data
                     let w_cts11m10.atdfnlflg = "S"
                     let w_cts11m10.atdetpcod =  4
                 else
                     if  mr_cts11m10.prslocflg  = "N" then
                         initialize w_cts11m10.hora     ,
                                    w_cts11m10.data     ,
                                    w_cts11m10.funmat   ,
                                    w_cts11m10.cnldat   ,
                                    w_cts11m10.atdfnlhor,
                                    w_cts11m10.c24opemat,
                                    w_cts11m10.atdfnlflg,
                                    w_cts11m10.atdetpcod,
                                    w_cts11m10.atdcstvlr,
                                    w_cts11m10.atdprscod to null
                     end if
                 end if

                 while true
                     if  a_passag[01].pasnom is null  or
                         a_passag[01].pasidd is null  then
                         error " Informe a relacao de passageiros!"
                         call cts11m11 (a_passag[01].*,
                                        a_passag[02].*,
                                        a_passag[03].*,
                                        a_passag[04].*,
                                        a_passag[05].*)
                              returning a_passag[01].*,
                                        a_passag[02].*,
                                        a_passag[03].*,
                                        a_passag[04].*,
                                        a_passag[05].*
                     else
                         exit while
                     end if
                 end while

                 if  mr_cts11m10.asimtvcod = 3  then
                     while true
                         for arr_aux = 1 to 15
                             if  a_passag[arr_aux].pasnom is null  or
                                 a_passag[arr_aux].pasidd is null  then
                                 exit for
                             end if
                         end for

                         if  arr_aux > 1  then

                             call cts08g01("A","S","","PARA RECUPERACAO DE VEICULO, SO'",
                                           "E' PERMITIDO UM UNICO PASSAGEIRO!","")
                                  returning ws.confirma

                             if  ws.confirma = "S"  then
                                 exit while
                             else
                                 call cts11m11 (a_passag[01].*,
                                                a_passag[02].*,
                                                a_passag[03].*,
                                                a_passag[04].*,
                                                a_passag[05].*)
                                      returning a_passag[01].*,
                                                a_passag[02].*,
                                                a_passag[03].*,
                                                a_passag[04].*,
                                                a_passag[05].*
                             end if
                         end if
                     end while
                 end if

          on key (interrupt)
             if  g_documento.atdsrvnum  is null   then
                 if  cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                              "","") = "S"  then
                     let int_flag = true
                     exit input
                 end if
             else
                 exit input
             end if

          on key (F1)
             if  g_documento.c24astcod is not null then
                 call ctc58m00_vis(g_documento.c24astcod)
             end if

          on key (F5)

             let g_monitor.horaini = current ## Flexvision
             call cta01m12_espelho(g_documento.ramcod,
                                   g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig,
                                   "",  # mr_geral.prporg,
                                   "",  # mr_geral.prpnumdig,
                                   "",  # mr_geral.fcapacorg,
                                   "",  # mr_geral.fcapacnum,
                                   "",  # pcacarnum
                                   "",  # pcaprpitm
                                   "",  # cmnnumdig,
                                   "",  # crtsaunum
                                   "",  # bnfnum
                                   g_documento.ciaempcod)

          on key (F6)
             if  g_documento.atdsrvnum is null  or
                 g_documento.atdsrvano is null  then
                 call cts10m02 (hist_cts11m10.*) returning hist_cts11m10.*
             else
                 call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                               g_issk.funmat, w_cts11m10.data, w_cts11m10.hora)
             end if

          on key (F7)
             call ctx14g00("Funcoes","Impressao|Distancia|Destino")
                  returning ws.opcao,
                            ws.opcaodes
             case ws.opcao
                when 1  ### Impressao
                     if  g_documento.atdsrvnum is null  or
                         g_documento.atdsrvano is null  then
                         error " Impressao somente com cadastramento do servico!"
                     else
                         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
                     end if

                 when 2   #### Distancia QTH-QTI
                     
                      if g_documento.c24astcod <> 'KM1' and                       
                         g_documento.c24astcod <> 'KM2' and                       
                         g_documento.c24astcod <> 'KM3' then                      
                     
                         call cts00m33(1,
                                       a_cts11m10[1].lclltt,
                                       a_cts11m10[1].lcllgt,
                                       a_cts11m10[2].lclltt,
                                       a_cts11m10[2].lcllgt)
                      end if

                 when 3   #### Cadastro de destino

                     if g_documento.atdsrvnum is null  or
                        g_documento.atdsrvano is null  then
                        error " Servico nao cadastrado!"
                     else
                        let a_cts11m10[2].lclbrrnom = m_subbairro[2].lclbrrnom
                        let m_acesso_ind = false
                        let l_atdsrvorg = 7
                        call cta00m06_acesso_indexacao_aut(l_atdsrvorg)
                             returning m_acesso_ind

                        #Projeto alteracao cadastro de destino
                        if g_documento.acao = "ALT" then

                           call cts11m10_bkp_info_dest(1, hist_cts11m10.*)
                              returning hist_cts11m10.*

                        end if

                        if m_acesso_ind = false then
                           call cts06g03(2,
                                         l_atdsrvorg,
                                         w_cts11m10.ligcvntip,
                                         aux_today,
                                         aux_hora,
                                         a_cts11m10[2].lclidttxt,
                                         a_cts11m10[2].cidnom,
                                         a_cts11m10[2].ufdcod,
                                         a_cts11m10[2].brrnom,
                                         a_cts11m10[2].lclbrrnom,
                                         a_cts11m10[2].endzon,
                                         a_cts11m10[2].lgdtip,
                                         a_cts11m10[2].lgdnom,
                                         a_cts11m10[2].lgdnum,
                                         a_cts11m10[2].lgdcep,
                                         a_cts11m10[2].lgdcepcmp,
                                         a_cts11m10[2].lclltt,
                                         a_cts11m10[2].lcllgt,
                                         a_cts11m10[2].lclrefptotxt,
                                         a_cts11m10[2].lclcttnom,
                                         a_cts11m10[2].dddcod,
                                         a_cts11m10[2].lcltelnum,
                                         a_cts11m10[2].c24lclpdrcod,
                                         a_cts11m10[2].ofnnumdig,
                                         a_cts11m10[2].celteldddcod   ,
                                         a_cts11m10[2].celtelnum,
                                         a_cts11m10[2].endcmp,
                                         hist_cts11m10.*,
                                         a_cts11m10[2].emeviacod)
                               returning a_cts11m10[2].lclidttxt,
                                         a_cts11m10[2].cidnom,
                                         a_cts11m10[2].ufdcod,
                                         a_cts11m10[2].brrnom,
                                         a_cts11m10[2].lclbrrnom,
                                         a_cts11m10[2].endzon,
                                         a_cts11m10[2].lgdtip,
                                         a_cts11m10[2].lgdnom,
                                         a_cts11m10[2].lgdnum,
                                         a_cts11m10[2].lgdcep,
                                         a_cts11m10[2].lgdcepcmp,
                                         a_cts11m10[2].lclltt,
                                         a_cts11m10[2].lcllgt,
                                         a_cts11m10[2].lclrefptotxt,
                                         a_cts11m10[2].lclcttnom,
                                         a_cts11m10[2].dddcod,
                                         a_cts11m10[2].lcltelnum,
                                         a_cts11m10[2].c24lclpdrcod,
                                         a_cts11m10[2].ofnnumdig,
                                         a_cts11m10[2].celteldddcod   ,
                                         a_cts11m10[2].celtelnum,
                                         a_cts11m10[2].endcmp,
                                         ws.retflg,
                                         hist_cts11m10.*,
                                         a_cts11m10[2].emeviacod
                        else
                           call cts06g11(2,
                                         l_atdsrvorg,
                                         w_cts11m10.ligcvntip,
                                         aux_today,
                                         aux_hora,
                                         a_cts11m10[2].lclidttxt,
                                         a_cts11m10[2].cidnom,
                                         a_cts11m10[2].ufdcod,
                                         a_cts11m10[2].brrnom,
                                         a_cts11m10[2].lclbrrnom,
                                         a_cts11m10[2].endzon,
                                         a_cts11m10[2].lgdtip,
                                         a_cts11m10[2].lgdnom,
                                         a_cts11m10[2].lgdnum,
                                         a_cts11m10[2].lgdcep,
                                         a_cts11m10[2].lgdcepcmp,
                                         a_cts11m10[2].lclltt,
                                         a_cts11m10[2].lcllgt,
                                         a_cts11m10[2].lclrefptotxt,
                                         a_cts11m10[2].lclcttnom,
                                         a_cts11m10[2].dddcod,
                                         a_cts11m10[2].lcltelnum,
                                         a_cts11m10[2].c24lclpdrcod,
                                         a_cts11m10[2].ofnnumdig,
                                         a_cts11m10[2].celteldddcod   ,
                                         a_cts11m10[2].celtelnum,
                                         a_cts11m10[2].endcmp,
                                         hist_cts11m10.*,
                                         a_cts11m10[2].emeviacod)
                               returning a_cts11m10[2].lclidttxt,
                                         a_cts11m10[2].cidnom,
                                         a_cts11m10[2].ufdcod,
                                         a_cts11m10[2].brrnom,
                                         a_cts11m10[2].lclbrrnom,
                                         a_cts11m10[2].endzon,
                                         a_cts11m10[2].lgdtip,
                                         a_cts11m10[2].lgdnom,
                                         a_cts11m10[2].lgdnum,
                                         a_cts11m10[2].lgdcep,
                                         a_cts11m10[2].lgdcepcmp,
                                         a_cts11m10[2].lclltt,
                                         a_cts11m10[2].lcllgt,
                                         a_cts11m10[2].lclrefptotxt,
                                         a_cts11m10[2].lclcttnom,
                                         a_cts11m10[2].dddcod,
                                         a_cts11m10[2].lcltelnum,
                                         a_cts11m10[2].c24lclpdrcod,
                                         a_cts11m10[2].ofnnumdig,
                                         a_cts11m10[2].celteldddcod   ,
                                         a_cts11m10[2].celtelnum,
                                         a_cts11m10[2].endcmp,
                                         ws.retflg,
                                         hist_cts11m10.*,
                                         a_cts11m10[2].emeviacod
                        end if

                        #Projeto alteracao cadastro de destino
                        let m_grava_hist = false

                        if g_documento.acao = "ALT" then

                           call cts11m10_verifica_tipo_atendim()
                              returning l_status, l_atdetpcod

                           if l_status = 0 then

                              if l_atdetpcod = 4 then

                                 let ws.confirma = null
                                 while ws.confirma = " " or
                                       ws.confirma  is null

                                       call cts08g01("C","S",""
                                                    ,"ALTERAR ENDERECO DE DESTINO? "
                                                    ,"","")
                                          returning ws.confirma
                                 end while

                                 if ws.confirma = "S" then

                                    let l_status = null
                                    call cts11m10_verifica_op_ativa()
                                       returning l_status

                                    if l_status then

                                       error "Endereco de Destino nao pode ser alterado. Servico Acionado e com OP " attribute (reverse) sleep 3

                                       error " Servico ja' acionado nao pode ser alterado!"
                                       let m_srv_acionado = true

                                       # CASO O SERVIÇO JÁ ESTEJA ACIONADO
                                       call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                     " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                     "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                                           returning ws.confirma

                                       # PREVISAO PARA TERMINO DO SERVIÇO
                                       # INICIO PSI-2013-00440PR
                                       if m_agendaw = false   # regulacao antiga
                                          then
                                          call cts02m03(w_cts11m10.atdfnlflg,
                                                        mr_cts11m10.imdsrvflg,
                                                        w_cts11m10.atdhorpvt,
                                                        w_cts11m10.atddatprg,
                                                        w_cts11m10.atdhorprg,
                                                        w_cts11m10.atdpvtretflg)
                                              returning w_cts11m10.atdhorpvt,
                                                        w_cts11m10.atddatprg,
                                                        w_cts11m10.atdhorprg,
                                                        w_cts11m10.atdpvtretflg
                                       else
                                          call cts02m08(w_cts11m10.atdfnlflg,
                                                        mr_cts11m10.imdsrvflg,
                                                        m_altcidufd,
                                                        mr_cts11m10.prslocflg,
                                                        w_cts11m10.atdhorpvt,
                                                        w_cts11m10.atddatprg,
                                                        w_cts11m10.atdhorprg,
                                                        w_cts11m10.atdpvtretflg,
                                                        m_rsrchvant,
                                                        m_operacao,
                                                        "",
                                                        a_cts11m10[1].cidnom,
                                                        a_cts11m10[1].ufdcod,
                                                        "",   # codigo de assistencia, nao existe no Ct24h
                                                        mr_cts11m10.vclcoddig,
                                                        m_ctgtrfcod,
                                                        mr_cts11m10.imdsrvflg,
                                                        a_cts11m10[1].c24lclpdrcod,
                                                        a_cts11m10[1].lclltt,
                                                        a_cts11m10[1].lcllgt,
                                                        g_documento.ciaempcod,
                                                        g_documento.atdsrvorg,
                                                        mr_cts11m10.asitipcod,
                                                        "",   # natureza nao tem, identifica pelo asitipcod  
                                                        "")   # sub-natureza nao tem, identifica pelo asitipcod  
                                              returning w_cts11m10.atdhorpvt,
                                                        w_cts11m10.atddatprg,
                                                        w_cts11m10.atdhorprg,
                                                        w_cts11m10.atdpvtretflg,
                                                        mr_cts11m10.imdsrvflg,
                                                        m_rsrchv,
                                                        m_operacao,
                                                        m_altdathor
                                       end if
                                       # FIM PSI-2013-00440PR
                                       
                                       call cts11m10_bkp_info_dest(2, hist_cts11m10.*)
                                          returning hist_cts11m10.*

                                       next field frmflg

                                    else

                                       let m_grava_hist   = true
                                       let m_srv_acionado = false

                                       let m_subbairro[2].lclbrrnom = a_cts11m10[2].lclbrrnom
                                       call cts06g10_monta_brr_subbrr(a_cts11m10[2].brrnom,
                                                                      a_cts11m10[2].lclbrrnom)
                                            returning a_cts11m10[2].lclbrrnom

                                       let a_cts11m10[2].lgdtxt = a_cts11m10[2].lgdtip clipped, " ",
                                                                  a_cts11m10[2].lgdnom clipped, " ",
                                                                  a_cts11m10[2].lgdnum using "<<<<#"

                                       let mr_cts11m10.dstlcl    = a_cts11m10[2].lclidttxt
                                       let mr_cts11m10.dstlgdtxt = a_cts11m10[2].lgdtxt
                                       let mr_cts11m10.dstbrrnom = a_cts11m10[2].lclbrrnom
                                       let mr_cts11m10.dstcidnom = a_cts11m10[2].cidnom
                                       let mr_cts11m10.dstufdcod = a_cts11m10[2].ufdcod

                                       if  a_cts11m10[2].lclltt <> a_cts11m10[3].lclltt or
                                           a_cts11m10[2].lcllgt <> a_cts11m10[3].lcllgt or
                                           (a_cts11m10[3].lclltt is null and a_cts11m10[2].lclltt is not null) or
                                           (a_cts11m10[3].lcllgt is null and a_cts11m10[2].lcllgt is not null) then

                                           
                                          if g_documento.c24astcod <> 'KM1' and                                              
                                             g_documento.c24astcod <> 'KM2' and                                              
                                             g_documento.c24astcod <> 'KM3' then                                             
                                           
                                             #CALCULA A DISTANCIA ENTRE A ORIGEM E O DESTINO
                                             call cts00m33(1,
                                                           a_cts11m10[1].lclltt,
                                                           a_cts11m10[1].lcllgt,
                                                           a_cts11m10[2].lclltt,
                                                           a_cts11m10[2].lcllgt)
                                          end if
                                       end if




									            ###Moreira-Envia-QRU-GPS

                              initialize  m_mdtcod, m_pstcoddig,
                                          m_socvclcod, m_srrcoddig,
                                          l_msgaltend, l_texto,
                                          l_dtalt, l_hralt,
                                          #l_vclcordes,
                                          l_lgdtxtcl,
                                          l_ciaempnom, l_msgrtgps,
                                          l_codrtgps  to  null

                              if m_grava_hist = true then
                                 if ctx34g00_ver_acionamentoWEB(2) then

                               whenever error continue
                               if w_cts11m10.socvclcod is null then
                                  select socvclcod
                                    into w_cts11m10.socvclcod
                                    from datmsrvacp acp
                                   where acp.atdsrvnum = g_documento.atdsrvnum
                                     and acp.atdsrvano = g_documento.atdsrvano
                                     and acp.atdsrvseq = (select max(atdsrvseq)
                                                            from datmsrvacp acp1
                                                           where acp1.atdsrvnum = acp.atdsrvnum
                                                             and acp1.atdsrvano = acp.atdsrvano)
                               end if

                               #display 'w_cts11m10.socvclcod ', w_cts11m10.socvclcod

                                    select mdtcod
                                    into m_mdtcod
                                    from datkveiculo
                                    where socvclcod = w_cts11m10.socvclcod

                                    select datkveiculo.pstcoddig,
                                           datkveiculo.socvclcod,
                                           dattfrotalocal.srrcoddig
                                    into m_pstcoddig, m_socvclcod, m_srrcoddig
                                    from datkveiculo, dattfrotalocal
                                    where dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                    and datkveiculo.mdtcod = m_mdtcod

                                   #select cpodes
                                   #into l_vclcordes
                                   #from iddkdominio
                                   #where cponom = "vclcorcod"
                                   #and cpocod = w_cts11m10.vclcorcod

                                    select empnom
                                    into l_ciaempnom
                                    from gabkemp
                                    where empcod  = g_documento.ciaempcod


                                    whenever error stop

                                    let l_dtalt = today
                                    let l_hralt = current
                                    let l_lgdtxtcl = a_cts11m10[2].lgdtip clipped, " ",
                                                     a_cts11m10[2].lgdnom clipped, " ",
                                                     a_cts11m10[2].lgdnum using "<<<<#", " ",
                                                     a_cts11m10[2].endcmp clipped


                                    let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                                                  l_ciaempnom clipped,
                                                  '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   					             		  	    let l_msgaltend = l_texto clipped
                                      ," QRU: ", m_atdsrvorg using "&&"
                                           ,"/", g_documento.atdsrvnum using "&&&&&&&"
                                           ,"-", g_documento.atdsrvano using "&&"
                                      ," QTR: ", l_dtalt, " ", l_hralt
                                      ," QNC: ", a_passag[arr_aux].pasnom      clipped, " "
                                               , mr_cts11m10.vcldes          clipped, " "
                                               , mr_cts11m10.vclanomdl       clipped, " "
                                      ," QNR: ", mr_cts11m10.vcllicnum       clipped, " "
                                               , l_vclcordes       clipped, " "
                                      ," QTI: ", a_cts11m10[2].lclidttxt       clipped, " - "
                                               , l_lgdtxtcl                 clipped, " - "
                                               , a_cts11m10[2].brrnom          clipped, " - "
                                               , a_cts11m10[2].cidnom          clipped, " - "
                                               , a_cts11m10[2].ufdcod          clipped, " "
                                      ," Ref: ", a_cts11m10[2].lclrefptotxt    clipped, " "
                                     ," Resp: ", a_cts11m10[2].lclcttnom       clipped, " "
                                     ," Tel: (", a_cts11m10[2].dddcod          clipped, ") "
                                               , a_cts11m10[2].lcltelnum       clipped, " "
          #                          ," Acomp: ", mr_cts11m10.rmcacpflg          clipped, "#"


                                     #display "m_pstcoddig: ", m_pstcoddig
                                     #display "m_socvclcod: ", m_socvclcod
                                     #display "m_srrcoddig: ", m_srrcoddig
                                     #display "l_msgaltend: ", l_msgaltend
                                     #display "l_codrtgps : ", l_codrtgps

                                    call ctx34g02_enviar_msg_gps(m_pstcoddig,
                                                                 m_socvclcod,
                                                                 m_srrcoddig,
                                                                 l_msgaltend)
                                           returning l_msgrtgps, l_codrtgps

                                     if l_codrtgps = 0 then
                                        display "Mensagem Enviada com Sucesso ao GPS do Prestador"
                                     else
                                        display "Mensagem nao enviada. Erro: ", l_codrtgps,
                                                " - ", l_msgrtgps clipped
                                     end if
                                 end if
                              end if
                             ###Moreira-Envia-QRU-GPS





                                       exit input

                                    end if
                                 else

                                    call cts11m10_bkp_info_dest(2, hist_cts11m10.*)
                                       returning hist_cts11m10.*

                                    let m_srv_acionado = true

                                 end if
                              else
                                 let m_srv_acionado = false
                              end if

                           else
                              error 'Erro ao buscar tipo de atendimento'
                              let m_srv_acionado = true
                           end if

                           if a_cts11m10[2].cidnom is not null and
                              a_cts11m10[2].ufdcod is not null then
                              call cts14g00 (g_documento.c24astcod,
                                             "","","","",
                                             a_cts11m10[2].cidnom,
                                             a_cts11m10[2].ufdcod,
                                             "S",
                                             ws.dtparam)
                           end if

                           #Fim Projeto alteracao cadastro de destino

                        end if
                     end if

             end case

          on key (F8)
             if  mr_cts11m10.asitipcod = 10 then
                 call cts11m08(w_cts11m10.trppfrdat,
                               w_cts11m10.trppfrhor)
                     returning w_cts11m10.trppfrdat,
                               w_cts11m10.trppfrhor
             end if

          on key (F9)
             if  g_documento.atdsrvnum is null  or
                 g_documento.atdsrvano is null  then
                 error " Servico nao cadastrado!"
             else
                 if mr_cts11m10.atdlibflg = "N"   then
                    error " Servico nao liberado!"
                 else
                    call cta00m06_acionamento(g_issk.dptsgl)
                    returning l_acesso
                   if l_acesso = true then
                      call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
                   else
                      call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
                   end if
                 end if
             end if

          on key (F10)
             call cts11m11 (a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*)
                  returning a_passag[01].*,
                            a_passag[02].*,
                            a_passag[03].*,
                            a_passag[04].*,
                            a_passag[05].*

          on key(F3)
             call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

     end input

     if int_flag then
        error " Operacao cancelada!"
     end if

     return hist_cts11m10.*

 end function

#------------------------------------#
 function ccts11m10_carrega_servico()
#------------------------------------#

    select ciaempcod   ,
           nom         ,
           vclcoddig   ,
           vcldes      ,
           vclanomdl   ,
           vcllicnum   ,
           corsus      ,
           cornom      ,
           vclcorcod   ,
           atddat      ,
           atdhor      ,
           atdlibflg   ,
           atdlibhor   ,
           atdlibdat   ,
           atdhorpvt   ,
           atdpvtretflg,
           atddatprg   ,
           atdhorprg   ,
           atdfnlflg   ,
           asitipcod   ,
           atdcstvlr   ,
           atdprinvlcod
      into g_documento.ciaempcod  ,
           mr_cts11m10.nom        ,
           mr_cts11m10.vclcoddig  ,
           mr_cts11m10.vcldes     ,
           mr_cts11m10.vclanomdl  ,
           mr_cts11m10.vcllicnum  ,
           mr_cts11m10.corsus     ,
           mr_cts11m10.cornom     ,
           w_cts11m10.vclcorcod  ,
           w_cts11m10.atddat      ,
           w_cts11m10.atdhor      ,
           mr_cts11m10.atdlibflg  ,
           mr_cts11m10.atdlibhor  ,
           mr_cts11m10.atdlibdat  ,
           w_cts11m10.atdhorpvt   ,
           w_cts11m10.atdpvtretflg,
           w_cts11m10.atddatprg   ,
           w_cts11m10.atdhorprg   ,
           w_cts11m10.atdfnlflg   ,
           mr_cts11m10.asitipcod  ,
           w_cts11m10.atdcstvlr   ,
           mr_cts11m10.atdprinvlcod
      from datmservico
     where atdsrvnum = g_documento.atdsrvnum and
           atdsrvano = g_documento.atdsrvano

     if  sqlca.sqlcode = notfound then
         error " Servico nao encontrado. AVISE A INFORMATICA!"
         sleep 2
         return false
     else
         return true
     end if

 end function

#---------------------------------------------------------------
 function cts11m10_modifica()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    sqlcode          integer
 end record

 define hist_cts11m10 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key   char (01)

 define l_data    date,
        l_hora2   datetime hour to minute
       ,l_errcod   smallint
       ,l_errmsg   char(80)
       
 initialize l_errcod, l_errmsg  to null

        let     prompt_key  =  null


        initialize  ws.*  to  null

        initialize  hist_cts11m10.*  to  null

        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts11m10.*  to  null

 initialize ws.*  to null

 call cts11m10_input() returning hist_cts11m10.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts11m10      to null
    initialize a_passag        to null
    initialize mr_cts11m10.*    to null
    initialize w_cts11m10.*    to null
    initialize hist_cts11m10.* to null
    clear form
    return false
 end if

 whenever error continue

 #display 'cts11m10 - Modificar atendimento'
  
 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
                          vclcoddig     ,
                          vcldes        ,
                          vclanomdl     ,
                          vcllicnum     ,
                          vclcorcod     ,
                          atdlibflg     ,
                          atdlibdat     ,
                          atdlibhor     ,
                          atdhorpvt     ,
                          atddatprg     ,
                          atdhorprg     ,
                          atdpvtretflg  ,
                          asitipcod     ,
                          atdprinvlcod  ,
                          prslocflg)
                      = ( mr_cts11m10.nom,
                          mr_cts11m10.corsus,
                          mr_cts11m10.cornom,
                          mr_cts11m10.vclcoddig,
                          mr_cts11m10.vcldes,
                          mr_cts11m10.vclanomdl,
                          mr_cts11m10.vcllicnum,
                          w_cts11m10.vclcorcod,
                          mr_cts11m10.atdlibflg,
                          mr_cts11m10.atdlibdat,
                          mr_cts11m10.atdlibhor,
                          w_cts11m10.atdhorpvt,
                          w_cts11m10.atddatprg,
                          w_cts11m10.atdhorprg,
                          w_cts11m10.atdpvtretflg,
                          mr_cts11m10.asitipcod,
                          mr_cts11m10.atdprinvlcod,
                          mr_cts11m10.prslocflg)
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmassistpassag set ( bagflg       ,
                               refatdsrvnum ,
                               refatdsrvano ,
                               asimtvcod    ,
                               atddmccidnom ,
                               atddmcufdcod ,
                               atddstcidnom ,
                               atddstufdcod ,
                               trppfrdat    ,
                               trppfrhor    )
                           = ( mr_cts11m10.bagflg      ,
                               mr_cts11m10.refatdsrvnum,
                               mr_cts11m10.refatdsrvano,
                               mr_cts11m10.asimtvcod   ,
                               w_cts11m10.atddmccidnom,
                               w_cts11m10.atddmcufdcod,
                               w_cts11m10.atddstcidnom,
                               w_cts11m10.atddstufdcod,
                               w_cts11m10.trppfrdat,
                               w_cts11m10.trppfrhor)
                         where atdsrvnum = g_documento.atdsrvnum  and
                               atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 delete from datmpassageiro
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na substituicao da relacao de",
          " passageiros. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 15
    if a_passag[arr_aux].pasnom is null  or
       a_passag[arr_aux].pasidd is null  then
       exit for
    end if

    initialize ws.passeq to null

    select max(passeq)
      into ws.passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do ultimo passageiro.",
             " AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

    if ws.passeq is null  then
       let ws.passeq = 0
    end if

    let ws.passeq = ws.passeq + 1

    insert into datmpassageiro (atdsrvnum,
                                atdsrvano,
                                passeq,
                                pasnom,
                                pasidd)
                        values (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                ws.passeq,
                                a_passag[arr_aux].pasnom,
                                a_passag[arr_aux].pasidd)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 2
    if a_cts11m10[arr_aux].operacao is null  then
       let a_cts11m10[arr_aux].operacao = "M"
    end if

    if mr_cts11m10.asitipcod = 10  and  arr_aux = 2   then
       exit for
    end if
    let a_cts11m10[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    call cts06g07_local(a_cts11m10[arr_aux].operacao,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        arr_aux,
                        a_cts11m10[arr_aux].lclidttxt,
                        a_cts11m10[arr_aux].lgdtip,
                        a_cts11m10[arr_aux].lgdnom,
                        a_cts11m10[arr_aux].lgdnum,
                        a_cts11m10[arr_aux].lclbrrnom,
                        a_cts11m10[arr_aux].brrnom,
                        a_cts11m10[arr_aux].cidnom,
                        a_cts11m10[arr_aux].ufdcod,
                        a_cts11m10[arr_aux].lclrefptotxt,
                        a_cts11m10[arr_aux].endzon,
                        a_cts11m10[arr_aux].lgdcep,
                        a_cts11m10[arr_aux].lgdcepcmp,
                        a_cts11m10[arr_aux].lclltt,
                        a_cts11m10[arr_aux].lcllgt,
                        a_cts11m10[arr_aux].dddcod,
                        a_cts11m10[arr_aux].lcltelnum,
                        a_cts11m10[arr_aux].lclcttnom,
                        a_cts11m10[arr_aux].c24lclpdrcod,
                        a_cts11m10[arr_aux].ofnnumdig,
                        a_cts11m10[arr_aux].emeviacod,
                        a_cts11m10[arr_aux].celteldddcod,
                        a_cts11m10[arr_aux].celtelnum,
                        a_cts11m10[arr_aux].endcmp)
              returning ws.sqlcode

    if ws.sqlcode is null   or
       ws.sqlcode <> 0      then
       if arr_aux = 1  then
          error " Erro (", ws.sqlcode, ") na alteracao do local de",
                " ocorrencia. AVISE A INFORMATICA!"
       else
          error " Erro (", ws.sqlcode, ") na alteracao do local de",
                " destino. AVISE A INFORMATICA!"
       end if
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if w_cts11m10.antlibflg <> mr_cts11m10.atdlibflg  then
    if mr_cts11m10.atdlibflg = "S"  then
       let w_cts11m10.atdetpcod = 1
       let ws.atdetpdat = mr_cts11m10.atdlibdat
       let ws.atdetphor = mr_cts11m10.atdlibhor
    else
       let w_cts11m10.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts11m10.atdetpcod,
                               w_cts11m10.atdprscod,
                               " " ,
                               " ",
                               w_cts11m10.srrcoddig) returning w_retorno

    if w_retorno <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de",
             " acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if


  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'

  #Alteracao projeto cadastro de destino
  if w_cts11m10.atdfnlflg <> "S" then

     if cts34g00_acion_auto (g_documento.atdsrvorg,
                             a_cts11m10[1].cidnom,
                             a_cts11m10[1].ufdcod) then

        # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
        # --DO SERVICO ESTA OK
        # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
        # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
        if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                            g_documento.c24astcod,
                                            mr_cts11m10.asitipcod,
                                            a_cts11m10[1].lclltt,
                                            a_cts11m10[1].lcllgt,
                                            mr_cts11m10.prslocflg,
                                            mr_cts11m10.frmflg,
                                            g_documento.atdsrvnum,
                                            g_documento.atdsrvano,
                                            " ",
                                            "",
                                            "") then
        else
           let m_aciona = 'S'
        end if
     else
        error "Problemas com parametros de acionamento: ",
                             g_documento.atdsrvorg, "/",
                             a_cts11m10[1].cidnom, "/",
                             a_cts11m10[1].ufdcod sleep 4
     end if

  end if

 commit work

 # War Room
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)
 #Projeto alteracao cadastro de destino
 if m_grava_hist then
    call cts11m10_grava_historico()
 end if

 whenever error stop

 # PSI-2013-00440PR
 if m_agendaw = true 
    then
    if m_operacao = 1  # ALT, gerou nova cota, baixa
       then
       #display 'Baixar cota atual na alteracao: ', m_rsrchv clipped
       call ctd41g00_baixar_agenda(m_rsrchv
                                 , g_documento.atdsrvano
                                 , g_documento.atdsrvnum)
            returning l_errcod, l_errmsg
    end if
    
    # so libera a anterior se baixou a nova
    if l_errcod = 0
       then
       call cts02m08_upd_cota(m_rsrchv, m_rsrchvant, g_documento.atdsrvnum
                            , g_documento.atdsrvano)
       
       # ALT, gerou nova cota e baixou, libera
       # Liberou sem regulacao e chave anterior existe, libera
       if (m_operacao = 1 or m_operacao = 2)
          then
          #display 'Liberar cota anterior na alteracao'
          call ctd41g00_liberar_agenda(g_documento.atdsrvano
                                      ,g_documento.atdsrvnum
                                      ,m_agncotdatant
                                      ,m_agncothorant)
       end if
    end if
 end if
 # PSI-2013-00440PR
 
 return true

end function

#-------------------------------------------------------------------------------
 function cts11m10_inclui()
#-------------------------------------------------------------------------------

 define ws              record
        promptX         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        passeq          like datmpassageiro.passeq ,
        ano             char (02)                  ,
        todayX          char (10)                  ,
        histerr         smallint                   ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        c24trxnum       like dammtrx.c24trxnum     ,  # Msg pager/email
        lintxt          like dammtrxtxt.c24trxtxt  ,
        titulo          like dammtrx.c24msgtit
 end record

 define hist_cts11m10   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define l_data       date,
        l_hora2      datetime hour to minute
      , l_txtsrv         char (15)
      , l_reserva_ativa  smallint # Flag para idenitficar se reserva esta ativa
      , l_errcod         smallint
      , l_errmsg         char(80)
       
 initialize l_errcod, l_errmsg to null
 initialize l_txtsrv, l_reserva_ativa to null
 initialize  ws.*  to  null
 initialize  hist_cts11m10.*  to  null

 #display 'cts11m10 - Incluir atendimento'
 
 while true
   initialize ws.*  to null

   let g_documento.acao    = "INC"
   let w_cts11m10.operacao = "i"

   call cts11m10_input() returning hist_cts11m10.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts11m10      to null
       initialize a_passag        to null
       initialize mr_parametro.*    to null
       initialize w_cts11m10.*    to null
       initialize hist_cts11m10.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts11m10.data is null  then
       let w_cts11m10.data   = aux_today
       let w_cts11m10.hora   = aux_hora
       let w_cts11m10.funmat = g_issk.funmat
   end if

   if  mr_cts11m10.frmflg = "S"  then
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

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.todayX  = l_data
   let ws.ano    = ws.todayX[9,10]


   if  w_cts11m10.atdfnlflg is null  then
       let w_cts11m10.atdfnlflg = "N"
       let w_cts11m10.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if


 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "P" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlcode  ,
                  ws.msg

   if  ws.sqlcode = 0  then
       commit work
   else
       let ws.msg = "CTS11M00 - ",ws.msg
       call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum   = ws.lignum
   let w_cts11m10.atdsrvnum = ws.atdsrvnum
   let w_cts11m10.atdsrvano = ws.atdsrvano


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts11m10.data         ,
                           w_cts11m10.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts11m10.funmat       ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","","",""             ,
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
                           ws.caddat               ,
                           ws.cadhor               ,
                           ws.cademp               ,
                           ws.cadmat                )
        returning ws.tabname,
                  ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( w_cts11m10.atdsrvnum,
                                w_cts11m10.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24soltip
                                w_cts11m10.vclcorcod,
                                w_cts11m10.funmat   ,
                                mr_cts11m10.atdlibflg,
                                mr_cts11m10.atdlibhor,
                                mr_cts11m10.atdlibdat,
                                w_cts11m10.data     ,     # atddat
                                w_cts11m10.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts11m10.atdhorpvt,
                                w_cts11m10.atddatprg,
                                w_cts11m10.atdhorprg,
                                "P"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts11m10.atdprscod,
                                w_cts11m10.atdcstvlr,
                                w_cts11m10.atdfnlflg,
                                w_cts11m10.atdfnlhor,
                                w_cts11m10.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts11m10.c24opemat,
                                mr_cts11m10.nom      ,
                                mr_cts11m10.vcldes   ,
                                mr_cts11m10.vclanomdl,
                                mr_cts11m10.vcllicnum,
                                mr_cts11m10.corsus   ,
                                mr_cts11m10.cornom   ,
                                w_cts11m10.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts11m10.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                mr_cts11m10.asitipcod,
                                ""                  ,     # socvclcod
                                mr_cts11m10.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                mr_cts11m10.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
        returning ws.tabname,
                  ws.sqlcode

   if  ws.sqlcode  <>  0  then
       error " Erro (", ws.sqlcode, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if mr_cts11m10.prslocflg = "S" then
      update datmservico set prslocflg = mr_cts11m10.prslocflg,
                             socvclcod = w_cts11m10.socvclcod,
                             srrcoddig = w_cts11m10.srrcoddig
       where datmservico.atdsrvnum = w_cts11m10.atdsrvnum
         and datmservico.atdsrvano = w_cts11m10.atdsrvano
   end if

 #------------------------------------------------------------------------------
 # Gravacao dos dados da ASSISTENCIA A PASSAGEIROS
 #------------------------------------------------------------------------------
   insert into DATMASSISTPASSAG ( atdsrvnum    ,
                                  atdsrvano    ,
                                  bagflg       ,
                                  refatdsrvnum ,
                                  refatdsrvano ,
                                  asimtvcod    ,
                                  atddmccidnom ,
                                  atddmcufdcod ,
                                  atddstcidnom ,
                                  atddstufdcod ,
                                  trppfrdat    ,
                                  trppfrhor     )
                         values ( w_cts11m10.atdsrvnum   ,
                                  w_cts11m10.atdsrvano   ,
                                  mr_cts11m10.bagflg      ,
                                  mr_cts11m10.refatdsrvnum,
                                  mr_cts11m10.refatdsrvano,
                                  mr_cts11m10.asimtvcod   ,
                                  w_cts11m10.atddmccidnom,
                                  w_cts11m10.atddmcufdcod,
                                  w_cts11m10.atddstcidnom,
                                  w_cts11m10.atddstufdcod,
                                  w_cts11m10.trppfrdat   ,
                                  w_cts11m10.trppfrhor    )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao dos",
             " dados da assistencia. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


   for arr_aux = 1 to 15
       if  a_passag[arr_aux].pasnom is null  or
           a_passag[arr_aux].pasidd is null  then
           exit for
       end if

       initialize ws.passeq to null

       select max(passeq)
         into ws.passeq
         from DATMPASSAGEIRO
              where atdsrvnum = w_cts11m10.atdsrvnum
                and atdsrvano = w_cts11m10.atdsrvano

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na selecao do",
                 " ultimo passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       if  ws.passeq is null  then
           let ws.passeq = 0
       end if

       let ws.passeq = ws.passeq + 1

       insert into DATMPASSAGEIRO( atdsrvnum,
                                   atdsrvano,
                                   passeq   ,
                                   pasnom   ,
                                   pasidd    )
                           values( w_cts11m10.atdsrvnum    ,
                                   w_cts11m10.atdsrvano    ,
                                   ws.passeq               ,
                                   a_passag[arr_aux].pasnom,
                                   a_passag[arr_aux].pasidd )

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava locais de (1) ocorrencia  / (2) destino
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 2
       if  a_cts11m10[arr_aux].operacao is null  then
           let a_cts11m10[arr_aux].operacao = "I"
       end if

       if  mr_cts11m10.asitipcod = 10  and  arr_aux = 2   then
           exit for
       end if
       let a_cts11m10[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts11m10[arr_aux].operacao    ,
                            w_cts11m10.atdsrvnum            ,
                            w_cts11m10.atdsrvano            ,
                            arr_aux                         ,
                            a_cts11m10[arr_aux].lclidttxt   ,
                            a_cts11m10[arr_aux].lgdtip      ,
                            a_cts11m10[arr_aux].lgdnom      ,
                            a_cts11m10[arr_aux].lgdnum      ,
                            a_cts11m10[arr_aux].lclbrrnom   ,
                            a_cts11m10[arr_aux].brrnom      ,
                            a_cts11m10[arr_aux].cidnom      ,
                            a_cts11m10[arr_aux].ufdcod      ,
                            a_cts11m10[arr_aux].lclrefptotxt,
                            a_cts11m10[arr_aux].endzon      ,
                            a_cts11m10[arr_aux].lgdcep      ,
                            a_cts11m10[arr_aux].lgdcepcmp   ,
                            a_cts11m10[arr_aux].lclltt      ,
                            a_cts11m10[arr_aux].lcllgt      ,
                            a_cts11m10[arr_aux].dddcod      ,
                            a_cts11m10[arr_aux].lcltelnum   ,
                            a_cts11m10[arr_aux].lclcttnom   ,
                            a_cts11m10[arr_aux].c24lclpdrcod,
                            a_cts11m10[arr_aux].ofnnumdig,
                            a_cts11m10[arr_aux].emeviacod,
                            a_cts11m10[arr_aux].celteldddcod,
                            a_cts11m10[arr_aux].celtelnum,
                            a_cts11m10[arr_aux].endcmp)
            returning ws.sqlcode

       if  ws.sqlcode is null  or
           ws.sqlcode <> 0     then
           if  arr_aux = 1  then
               error " Erro (", ws.sqlcode, ") na gravacao do",
                     " local de ocorrencia. AVISE A INFORMATICA!"
           else
               error " Erro (", ws.sqlcode, ") na gravacao do",
                     " local de destino. AVISE A INFORMATICA!"
           end if
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  w_cts11m10.atdetpcod is null  then
       if  mr_cts11m10.atdlibflg = "S"  then
           let w_cts11m10.atdetpcod = 1
           let ws.etpfunmat = w_cts11m10.funmat
           let ws.atdetpdat = mr_cts11m10.atdlibdat
           let ws.atdetphor = mr_cts11m10.atdlibhor
       else
           let w_cts11m10.atdetpcod = 2
           let ws.etpfunmat = w_cts11m10.funmat
           let ws.atdetpdat = w_cts11m10.data
           let ws.atdetphor = w_cts11m10.hora
       end if
   else
      call cts10g04_insere_etapa(w_cts11m10.atdsrvnum,
                                 w_cts11m10.atdsrvano,
                                 1,
                                 w_cts11m10.atdprscod,
                                 " ",
                                 " ",
                                 w_cts11m10.srrcoddig )returning w_retorno

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts11m10.cnldat
       let ws.atdetphor = w_cts11m10.atdfnlhor
       let ws.etpfunmat = w_cts11m10.c24opemat
   end if


   call cts10g04_insere_etapa(w_cts11m10.atdsrvnum,
                              w_cts11m10.atdsrvano,
                              w_cts11m10.atdetpcod,
                              w_cts11m10.atdprscod,
                              " ",
                              " ",
                              w_cts11m10.srrcoddig )returning w_retorno

   if  w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.promptX
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if g_documento.succod    is not null  and
      g_documento.ramcod    is not null  and
      g_documento.aplnumdig is not null  then


      call cts10g02_grava_servico_apolice(w_cts11m10.atdsrvnum ,
                                          w_cts11m10.atdsrvano ,
                                          g_documento.succod   ,
                                          g_documento.ramcod   ,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig,
                                          g_documento.edsnumref)
                                returning ws.tabname,
                                          ws.sqlcode


      if  ws.sqlcode <> 0  then
          error " Erro (", ws.sqlcode, ") na gravacao do",
                " relacionamento servico x apolice. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.promptX
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
         let ws_cgccpfnum  = ws.cgccpfnum
         let ws_cgccpfdig  = ws.cgccpfdig
              # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
         insert into datrsrvcnd
                   (atdsrvnum,
                    atdsrvano,
                    succod   ,
                    aplnumdig,
                    itmnumdig,
                    vclcndseq)
            values (w_cts11m10.atdsrvnum ,
                    w_cts11m10.atdsrvano ,
                    g_documento.succod   ,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    ws.cdtseq             )
         if  sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na gravacao do",
                   " relacionamento servico x condutor. AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.promptX
             let ws.retorno = false
             exit while
        end if
      end if
   else
      # este registro indica um atendimento sem documento
      if g_documento.ramcod is not null then

         call cts10g02_grava_servico_apolice(w_cts11m10.atdsrvnum         ,
                                             w_cts11m10.atdsrvano         ,
                                             0,
                                             g_documento.ramcod   ,
                                             0,
                                             0,
                                             0)
                                   returning ws.tabname,
                                             ws.sqlcode

        if  ws.sqlcode <> 0  then
            error " Erro (", ws.sqlcode, ") na gravacao do",
                  " relac. servico x apolice-atd s/docto. AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.promptX
            let ws.retorno = false
            exit while
        end if
      end if
   end if

   commit work

   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts11m10.atdsrvnum,
                               w_cts11m10.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts11m10.atdsrvnum,
                            w_cts11m10.atdsrvano,
                            w_cts11m10.data     ,
                            w_cts11m10.hora     ,
                            w_cts11m10.funmat   ,
                            hist_cts11m10.*      )
        returning ws.histerr

 #------------------------------------------------------------------------------
 # Envia e-mail e pager para assistencia 10 - Aviao
 #------------------------------------------------------------------------------
    {whenever error continue ####psi175552####
    let ws.titulo = "AVISO_S23-",mr_parametro.asitipabvdes clipped
    call ctx14g00_msg( 9999,
                       g_documento.lignum,
                       w_cts11m10.atdsrvnum,
                       w_cts11m10.atdsrvano,
                       ws.titulo ) #"AVISO_S23_AVIAO")
         returning ws.c24trxnum
    -------------------[ solicitacao da miriam - 25/07/03 ]----------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_ivan/spaulo_ct24hs_teleatendimento@u55",
                          "Ivan",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_lilian/spaulo_ct24hs_teleatendimento@u55",
                          "Lilian",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_maiara/spaulo_ct24hs_teleatendimento@u55",
                          "Maiara",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_roseli/spaulo_ct24hs_teleatendimento@u55",
                          "Roseli",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_willian/spaulo_ct24hs_teleatendimento@u55",
                          "Willian",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_henrique/spaulo_ct24hs_teleatendimento@u55",
                          "Henrique",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "macieira_carla/spaulo_ct24hs_teleatendimento@u55",
                          "Carla",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "menzani_murilo/spaulo_ct24hs_teleatendimento@u55",
                          "Murilo",
                          1) # 1-email
    -------------------------------------------------------------------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_michael/spaulo_ct24hs_teleatendimento@u55",
                          "Michael",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "ct24hs_ivens/spaulo_ct24hs_teleatendimento@u55",
                          "Ivens",
                          1) # 1-email
    call ctx14g00_msgdst( ws.c24trxnum,
                          "correia_lucio/spaulo_psocorro_comercial@u23",
                          "Lucio Correia",
                          1) # 1-email

    -------------[ PAGER'S ]------------------
    call ctx14g00_msgdst( ws.c24trxnum,
                          "2048",
                          "pager",
                          2) # 2-pager
    call ctx14g00_msgdst( ws.c24trxnum,
                          "5994",
                          "pager",
                          2) # 2-pager
    call ctx14g00_msgdst( ws.c24trxnum,
                          "5981",
                          "pager",
                          2) # 2-pager
    -------------------------------------------
    let ws.lintxt = "Servico: ", g_documento.atdsrvorg using "&&",
                                 "/", w_cts11m10.atdsrvnum using "&&&&&&&",
                                 "-", w_cts11m10.atdsrvano using "&&"
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    let ws.lintxt = "Segurado: ", mr_parametro.nom
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    let ws.lintxt = "Atendimento: ", w_cts11m10.data,
                    " AS ", w_cts11m10.hora
    call ctx14g00_msgtxt( ws.c24trxnum,
                          ws.lintxt)
    if g_documento.ramcod     is not null  and
       g_documento.succod     is not null  and
       g_documento.aplnumdig  is not null  then
       let ws.lintxt = "Suc: ", g_documento.succod    using "&&",
                    "  Ramo: ", g_documento.ramcod    using "&&&&",
                    "  Apl.: ", g_documento.aplnumdig using "<<<<<<<# #"
       if g_documento.itmnumdig is not null  and
          g_documento.itmnumdig <>  0        then
          let ws.lintxt = ws.lintxt clipped,
                         "  Item: ", g_documento.itmnumdig using "<<<<<# #"
       end if
       let ws.lintxt = ws.lintxt clipped,
                      " End: ", g_documento.edsnumref using "<<<<<<<<&"
       call ctx14g00_msgtxt( ws.c24trxnum,
                             ws.lintxt)
    end if
    update dammtrx
       set c24msgtrxstt = 9   # STATUS DE ENVIO
    where c24trxnum = ws.c24trxnum

 ## call ctx14g00_msgok(ws.c24trxnum )
    call ctx14g00_envia(ws.c24trxnum,"")
    whenever error stop} ####psi175552 fim####
#end if

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts11m10[1].cidnom,
                          a_cts11m10[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         mr_cts11m10.asitipcod,
                                         a_cts11m10[1].lclltt,
                                         a_cts11m10[1].lcllgt,
                                         mr_cts11m10.prslocflg,
                                         mr_cts11m10.frmflg,
                                         w_cts11m10.atdsrvnum,
                                         w_cts11m10.atdsrvano,
                                         " ",
                                         "",
                                         "") then
     else
        let m_aciona = 'S'
     end if
  else
     error "Problemas com parametros de acionamento: ",
                          g_documento.atdsrvorg, "/",
                          a_cts11m10[1].cidnom, "/",
                          a_cts11m10[1].ufdcod sleep 4
  end if

  # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao 
  #                    ainda ativa e fazer a baixa da chave no AW
  let l_txtsrv = "SRV ", w_cts11m10.atdsrvnum, "-", w_cts11m10.atdsrvano
  
  
  #display 'Dados da inclusao do servico:'
  #display 'ws.sqlcode : ', ws.sqlcode 
  #display 'm_agendaw  : ', m_agendaw  
  #display 'm_operacao : ', m_operacao 
  #display 'l_txtsrv   : ', l_txtsrv   clipped
  #display 'm_altcidufd: ', m_altcidufd
  #display 'prslocflg  : ', mr_cts11m10.prslocflg
                            
  if m_agendaw = true 
     then
     if m_operacao = 1  # obteve chave de regulacao 
        then
        if ws.sqlcode = 0  # sucesso na gravacao do servico
           then
           call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa
        
           if l_reserva_ativa = true 
              then
              #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
              call ctd41g00_baixar_agenda(m_rsrchv, w_cts11m10.atdsrvano, w_cts11m10.atdsrvnum)
                   returning l_errcod, l_errmsg
           else
              #display "Chave de regulacao inativa, selecione agenda novamente"
              error "Chave de regulacao inativa, selecione agenda novamente"
              
              let m_operacao = 0 
              
              # obter a chave de regulacao no AW
              call cts02m08(w_cts11m10.atdfnlflg,
                            mr_cts11m10.imdsrvflg,
                            m_altcidufd,
                            mr_cts11m10.prslocflg,
                            w_cts11m10.atdhorpvt,
                            w_cts11m10.atddatprg,
                            w_cts11m10.atdhorprg,
                            w_cts11m10.atdpvtretflg,
                            m_rsrchv,
                            m_operacao,
                            "",
                            a_cts11m10[1].cidnom,
                            a_cts11m10[1].ufdcod,
                            "",   # codigo de assistencia, nao existe no Ct24h
                            mr_cts11m10.vclcoddig,
                            m_ctgtrfcod,
                            mr_cts11m10.imdsrvflg,
                            a_cts11m10[1].c24lclpdrcod,
                            a_cts11m10[1].lclltt,
                            a_cts11m10[1].lcllgt,
                            g_documento.ciaempcod,
                            g_documento.atdsrvorg,
                            mr_cts11m10.asitipcod,
                            "",   # natureza nao tem, identifica pelo asitipcod  
                            "")   # sub-natureza nao tem, identifica pelo asitipcod  
                  returning w_cts11m10.atdhorpvt,
                            w_cts11m10.atddatprg,
                            w_cts11m10.atdhorprg,
                            w_cts11m10.atdpvtretflg,
                            mr_cts11m10.imdsrvflg,
                            m_rsrchv,
                            m_operacao,
                            m_altdathor
                               
              display by name mr_cts11m10.imdsrvflg
              
              if m_operacao = 1
                 then
                 #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                 call ctd41g00_baixar_agenda(m_rsrchv, w_cts11m10.atdsrvano, w_cts11m10.atdsrvnum)
                      returning l_errcod, l_errmsg
              end if
           end if
           
           if l_errcod = 0
              then
              call cts02m08_ins_cota(m_rsrchv, w_cts11m10.atdsrvnum, w_cts11m10.atdsrvano)
                   returning l_errcod, l_errmsg
                   
              #if l_errcod = 0
              #   then
              #   display 'cts02m08_ins_cota gravou com sucesso'
              #else
              #   display 'cts02m08_ins_cota erro ', l_errcod
              #   display l_errmsg clipped
              #end if
           else
              #display 'cts11m10 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
           end if
            
        else
           #display l_txtsrv clipped, ' erro na inclusao, liberar agenda'
           
           call cts02m08_id_datahora_cota(m_rsrchv)
                returning l_errcod, l_errmsg, m_agncotdat, m_agncothor
                
           #if l_errcod != 0
           #   then
           #   display 'ctd41g00_liberar_agenda NAO acionado, erro no ID da cota'
           #   display l_errmsg clipped
           #end if
           
           call ctd41g00_liberar_agenda(w_cts11m10.atdsrvano, w_cts11m10.atdsrvnum
                                      , m_agncotdat, m_agncothor)
        end if
     end if
  end if
  # PSI-2013-00440PR
  
 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let mr_cts11m10.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts11m10.atdsrvnum using "&&&&&&&",
                            "-", w_cts11m10.atdsrvano using "&&"
   display by name mr_cts11m10.servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.promptX

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  # cts11m10_inclui

#---------------------------------------------------------------
 function consulta_cts11m10()
#---------------------------------------------------------------

 define ws           record
    passeq           like datmpassageiro.passeq,
    funmat           like isskfunc.funmat,
    empcod           like isskfunc.empcod,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl,
    sqlcode          integer,
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapcorg         like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum
 end record

 define l_errcod   smallint
       ,l_errmsg   char(80)

 initialize l_errcod, l_errmsg to null
 
        initialize  ws.*  to  null

 initialize ws.*  to null

 select nom         ,
        vclcoddig   ,
        vcldes      ,
        vclanomdl   ,
        vcllicnum   ,
        corsus      ,
        cornom      ,
        vclcorcod   ,
        funmat      ,
        empcod      ,
        atddat      ,
        atdhor      ,
        atdlibflg   ,
        atdlibhor   ,
        atdlibdat   ,
        atdhorpvt   ,
        atdpvtretflg,
        atddatprg   ,
        atdhorprg   ,
        atdfnlflg   ,
        asitipcod   ,
        atdcstvlr   ,
        atdprinvlcod,
        ciaempcod   ,
        prslocflg
   into mr_cts11m10.nom      ,
        mr_cts11m10.vclcoddig,
        mr_cts11m10.vcldes   ,
        mr_cts11m10.vclanomdl,
        mr_cts11m10.vcllicnum,
        mr_cts11m10.corsus   ,
        mr_cts11m10.cornom   ,
        w_cts11m10.vclcorcod,
        ws.funmat           ,
        ws.empcod           ,
        w_cts11m10.atddat   ,
        w_cts11m10.atdhor   ,
        mr_cts11m10.atdlibflg,
        mr_cts11m10.atdlibhor,
        mr_cts11m10.atdlibdat,
        w_cts11m10.atdhorpvt,
        w_cts11m10.atdpvtretflg,
        w_cts11m10.atddatprg,
        w_cts11m10.atdhorprg,
        w_cts11m10.atdfnlflg,
        mr_cts11m10.asitipcod,
        w_cts11m10.atdcstvlr,
        mr_cts11m10.atdprinvlcod,
        g_documento.ciaempcod,
        mr_cts11m10.prslocflg
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = NOTFOUND then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 # PSI-2013-00440PR
 # identificar cota de agendamento ja realizado (ALT)
 call cts02m08_sel_cota(g_documento.atdsrvnum, g_documento.atdsrvano)
      returning l_errcod, l_errmsg, m_rsrchvant
 
 #if l_errcod = 0
 #   then
 #   display 'cts02m08_sel_cota ok'
 #else
 #   display 'cts02m08_sel_cota erro ', l_errcod
 #   display l_errmsg clipped
 #end if

 call cts02m08_id_datahora_cota(m_rsrchvant)
      returning l_errcod, l_errmsg, m_agncotdatant, m_agncothorant
      
 #if l_errcod != 0
 #   then
 #   display 'cts02m08_id_datahora_cota(consulta) erro no ID da cota'
 #   display l_errmsg clipped
 #end if
 # PSI-2013-00440PR
 
 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts11m10[1].lclidttxt   ,
                         a_cts11m10[1].lgdtip      ,
                         a_cts11m10[1].lgdnom      ,
                         a_cts11m10[1].lgdnum      ,
                         a_cts11m10[1].lclbrrnom   ,
                         a_cts11m10[1].brrnom      ,
                         a_cts11m10[1].cidnom      ,
                         a_cts11m10[1].ufdcod      ,
                         a_cts11m10[1].lclrefptotxt,
                         a_cts11m10[1].endzon      ,
                         a_cts11m10[1].lgdcep      ,
                         a_cts11m10[1].lgdcepcmp   ,
                         a_cts11m10[1].lclltt      ,
                         a_cts11m10[1].lcllgt      ,
                         a_cts11m10[1].dddcod      ,
                         a_cts11m10[1].lcltelnum   ,
                         a_cts11m10[1].lclcttnom   ,
                         a_cts11m10[1].c24lclpdrcod,
                         a_cts11m10[1].celteldddcod,
                         a_cts11m10[1].celtelnum   ,
                         a_cts11m10[1].endcmp,
                         ws.sqlcode,a_cts11m10[1].emeviacod
  # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts11m10[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts11m10[1].brrnom,
                                a_cts11m10[1].lclbrrnom)
      returning a_cts11m10[1].lclbrrnom

 select ofnnumdig into a_cts11m10[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if


 let a_cts11m10[1].lgdtxt = a_cts11m10[1].lgdtip clipped, " ",
                            a_cts11m10[1].lgdnom clipped, " ",
                            a_cts11m10[1].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Informacoes do local de destino
#--------------------------------------------------------------------
 if mr_cts11m10.asitipcod <> 10  then  ###  Passagem Aerea
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            2)
                  returning a_cts11m10[2].lclidttxt   ,
                            a_cts11m10[2].lgdtip      ,
                            a_cts11m10[2].lgdnom      ,
                            a_cts11m10[2].lgdnum      ,
                            a_cts11m10[2].lclbrrnom   ,
                            a_cts11m10[2].brrnom      ,
                            a_cts11m10[2].cidnom      ,
                            a_cts11m10[2].ufdcod      ,
                            a_cts11m10[2].lclrefptotxt,
                            a_cts11m10[2].endzon      ,
                            a_cts11m10[2].lgdcep      ,
                            a_cts11m10[2].lgdcepcmp   ,
                            a_cts11m10[2].lclltt      ,
                            a_cts11m10[2].lcllgt      ,
                            a_cts11m10[2].dddcod      ,
                            a_cts11m10[2].lcltelnum   ,
                            a_cts11m10[2].lclcttnom   ,
                            a_cts11m10[2].c24lclpdrcod,
                            a_cts11m10[2].celteldddcod,
                            a_cts11m10[2].celtelnum   ,
                            a_cts11m10[2].endcmp,
                            ws.sqlcode, a_cts11m10[2].emeviacod
    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    let m_subbairro[2].lclbrrnom = a_cts11m10[2].lclbrrnom
    call cts06g10_monta_brr_subbrr(a_cts11m10[2].brrnom,
                                   a_cts11m10[2].lclbrrnom)
         returning a_cts11m10[2].lclbrrnom
    select ofnnumdig into a_cts11m10[2].ofnnumdig
      from datmlcl
     where atdsrvano = g_documento.atdsrvano
       and atdsrvnum = g_documento.atdsrvnum
       and c24endtip = 2

    if ws.sqlcode = 0  then
       let a_cts11m10[2].lgdtxt = a_cts11m10[2].lgdtip clipped, " ",
                                  a_cts11m10[2].lgdnom clipped, " ",
                                  a_cts11m10[2].lgdnum using "<<<<#"

       let mr_cts11m10.dstlcl    = a_cts11m10[2].lclidttxt
       let mr_cts11m10.dstlgdtxt = a_cts11m10[2].lgdtxt
       let mr_cts11m10.dstbrrnom = a_cts11m10[2].lclbrrnom
       let mr_cts11m10.dstcidnom = a_cts11m10[2].cidnom
       let mr_cts11m10.dstufdcod = a_cts11m10[2].ufdcod
    else
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let mr_cts11m10.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts11m10.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts11m10.asitipcod

#---------------------------------------------------------------
# Obtencao dos dados da assistencia a passageiros
#---------------------------------------------------------------

 select refatdsrvnum, refatdsrvano,
        bagflg      , asimtvcod   ,
        atddmccidnom, atddmcufdcod,
        atddstcidnom, atddstufdcod,
        trppfrdat   , trppfrhor   ,
        atdsrvorg
   into mr_cts11m10.refatdsrvnum   ,
        mr_cts11m10.refatdsrvano   ,
        mr_cts11m10.bagflg         ,
        mr_cts11m10.asimtvcod      ,
        w_cts11m10.atddmccidnom   ,
        w_cts11m10.atddmcufdcod   ,
        w_cts11m10.atddstcidnom   ,
        w_cts11m10.atddstufdcod   ,
        w_cts11m10.trppfrdat      ,
        w_cts11m10.trppfrhor      ,
        mr_cts11m10.refatdsrvorg
   from datmassistpassag, outer datmservico
  where datmassistpassag.atdsrvnum = g_documento.atdsrvnum  and
        datmassistpassag.atdsrvano = g_documento.atdsrvano  and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum  and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if mr_cts11m10.asitipcod = 10  then  ###  Passagem Aerea
    let mr_cts11m10.dstcidnom = w_cts11m10.atddstcidnom
    let mr_cts11m10.dstufdcod = w_cts11m10.atddstufdcod
 end if

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------

 let mr_cts11m10.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts11m10.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts11m10.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare ccts11m10002 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach ccts11m10002 into a_passag[arr_aux].pasnom,
                               a_passag[arr_aux].pasidd,
                               ws.passeq
    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       exit foreach
    end if
 end foreach

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts11m10.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

 call cts20g01_docto(w_cts11m10.lignum)
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
    let mr_cts11m10.doctxt = "Apolice.: "
                         , g_documento.succod    using "<<<&&",
                      " ", g_documento.ramcod    using "&&&&",
                      " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts11m10.ligcvntip,
        mr_cts11m10.c24solnom, g_documento.c24astcod
   from datmligacao
  where lignum = w_cts11m10.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts11m10.lignum

 if sqlca.sqlcode = notfound  then
    let mr_cts11m10.frmflg = "N"
 else
    let mr_cts11m10.frmflg = "S"
 end if

 select cpodes into mr_cts11m10.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts11m10.ligcvntip

 let mr_cts11m10.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod
    and funmat = ws.funmat

 let mr_cts11m10.atdtxt = w_cts11m10.atddat         clipped, " ",
                         w_cts11m10.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 select cpodes
   into mr_cts11m10.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = w_cts11m10.vclcorcod

 if w_cts11m10.atdhorpvt is not null  or
    w_cts11m10.atdhorpvt =  "00:00"   then
    let mr_cts11m10.imdsrvflg = "S"
 end if

 if w_cts11m10.atddatprg is not null   then
    let mr_cts11m10.imdsrvflg = "N"
 end if

 if mr_cts11m10.atdlibflg = "N"  then
    let mr_cts11m10.atdlibdat = w_cts11m10.atddat
    let mr_cts11m10.atdlibhor = w_cts11m10.atdhor
 end if

 let w_cts11m10.antlibflg = mr_cts11m10.atdlibflg

 let mr_cts11m10.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 select cpodes
   into mr_cts11m10.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = mr_cts11m10.atdprinvlcod

 let mr_cts11m10.vcldes = cts15g00(mr_cts11m10.vclcoddig)

 let mr_cts11m10.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts11m10.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts11m10.asimtvcod

 let mr_cts11m10.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts11m10.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts11m10.asitipcod

 let m_c24lclpdrcod = a_cts11m10[1].c24lclpdrcod

end function

#------------------------------------------------------------------
function cts11m10_clausulas(l_doc_handle)
#------------------------------------------------------------------

   define l_doc_handle integer

   define la_clausula array[20] of record
          clscod      like aackcls.clscod,
          clsdes      like aackcls.clsdes,
          clsdes_2    like aackcls.clsdes
   end record

   define lr_km record
          kmlimite smallint,
          qtde     integer
   end record

   define l_qtd_end  smallint
   define l_ind      smallint
   define l_aux_char char(100)
   define l_descricao char(50)
   define l_valor     dec(15,5)

   initialize l_qtd_end  ,
              l_ind      ,
              l_valor    ,
              l_descricao,
              l_aux_char to null

   initialize lr_km.* to null

   let l_qtd_end = 0

   for l_ind  =  1  to  20
      initialize  la_clausula[l_ind].*    to  null
   end for

   let l_qtd_end = figrc011_xpath
                  (l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

   for l_ind = 1 to l_qtd_end
      let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"

      let la_clausula[l_ind].clscod = figrc011_xpath(l_doc_handle,l_aux_char)


      if la_clausula[l_ind].clscod = "037" or
         la_clausula[l_ind].clscod = "37A" or
         la_clausula[l_ind].clscod = "37B" or
         la_clausula[l_ind].clscod = "37C" or
         la_clausula[l_ind].clscod = "37D" or   #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37E" or   #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37F" or   #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37G" or   #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37H" then

         call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_GUINCHO')
                                   returning lr_km.kmlimite,
                                             lr_km.qtde

         let la_clausula[l_ind].clsdes = " AO MAXIMO DE ", lr_km.kmlimite
                                       , " KM "

	 ---> Valor Limite de Assistencia
         call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_RETORNO')
              returning l_valor

         let la_clausula[l_ind].clsdes_2 = "R$ ", l_valor using "<<<<<<<&.&&"

         exit for
      end if
   end for

 if la_clausula[l_ind].clscod <> "37D" or
    la_clausula[l_ind].clscod <> "37E" or
    la_clausula[l_ind].clscod <> "37F" or
    la_clausula[l_ind].clscod <> "37G" or
    la_clausula[l_ind].clscod <> "37H" then
   if la_clausula[l_ind].clsdes is null then
      let l_ind = 1
      let la_clausula[l_ind].clsdes = " AO MAXIMO DE 100 KM "
   end if
end if

   return la_clausula[l_ind].clsdes
	       ,la_clausula[l_ind].clsdes_2
	       ,la_clausula[l_ind].clscod

end function

#--------------------------------------------------------#
 function cts11m10_bkp_info_dest(l_tipo, hist_cts11m10)
#--------------------------------------------------------#
  define hist_cts11m10 record
         hist1         like datmservhist.c24srvdsc
        ,hist2         like datmservhist.c24srvdsc
        ,hist3         like datmservhist.c24srvdsc
        ,hist4         like datmservhist.c24srvdsc
        ,hist5         like datmservhist.c24srvdsc
  end record

  define l_tipo        smallint

  if l_tipo = 1 then

     initialize a_cts11m10_bkp      to null
     initialize m_hist_cts11m10_bkp to null

     let a_cts11m10_bkp[1].lclidttxt    = a_cts11m10[2].lclidttxt
     let a_cts11m10_bkp[1].cidnom       = a_cts11m10[2].cidnom
     let a_cts11m10_bkp[1].ufdcod       = a_cts11m10[2].ufdcod
     let a_cts11m10_bkp[1].brrnom       = a_cts11m10[2].brrnom
     let a_cts11m10_bkp[1].lclbrrnom    = a_cts11m10[2].lclbrrnom
     let a_cts11m10_bkp[1].endzon       = a_cts11m10[2].endzon
     let a_cts11m10_bkp[1].lgdtip       = a_cts11m10[2].lgdtip
     let a_cts11m10_bkp[1].lgdnom       = a_cts11m10[2].lgdnom
     let a_cts11m10_bkp[1].lgdnum       = a_cts11m10[2].lgdnum
     let a_cts11m10_bkp[1].lgdcep       = a_cts11m10[2].lgdcep
     let a_cts11m10_bkp[1].lgdcepcmp    = a_cts11m10[2].lgdcepcmp
     let a_cts11m10_bkp[1].lclltt       = a_cts11m10[2].lclltt
     let a_cts11m10_bkp[1].lcllgt       = a_cts11m10[2].lcllgt
     let a_cts11m10_bkp[1].lclrefptotxt = a_cts11m10[2].lclrefptotxt
     let a_cts11m10_bkp[1].lclcttnom    = a_cts11m10[2].lclcttnom
     let a_cts11m10_bkp[1].dddcod       = a_cts11m10[2].dddcod
     let a_cts11m10_bkp[1].lcltelnum    = a_cts11m10[2].lcltelnum
     let a_cts11m10_bkp[1].c24lclpdrcod = a_cts11m10[2].c24lclpdrcod
     let a_cts11m10_bkp[1].ofnnumdig    = a_cts11m10[2].ofnnumdig
     let a_cts11m10_bkp[1].celteldddcod = a_cts11m10[2].celteldddcod
     let a_cts11m10_bkp[1].celtelnum    = a_cts11m10[2].celtelnum
     let a_cts11m10_bkp[1].endcmp       = a_cts11m10[2].endcmp
     let m_hist_cts11m10_bkp.hist1      = hist_cts11m10.hist1
     let m_hist_cts11m10_bkp.hist2      = hist_cts11m10.hist2
     let m_hist_cts11m10_bkp.hist3      = hist_cts11m10.hist3
     let m_hist_cts11m10_bkp.hist4      = hist_cts11m10.hist4
     let m_hist_cts11m10_bkp.hist5      = hist_cts11m10.hist5
     let a_cts11m10_bkp[1].emeviacod    = a_cts11m10[2].emeviacod

     return hist_cts11m10.*

  else

     let a_cts11m10[2].lclidttxt    = a_cts11m10_bkp[1].lclidttxt
     let a_cts11m10[2].cidnom       = a_cts11m10_bkp[1].cidnom
     let a_cts11m10[2].ufdcod       = a_cts11m10_bkp[1].ufdcod
     let a_cts11m10[2].brrnom       = a_cts11m10_bkp[1].brrnom
     let a_cts11m10[2].lclbrrnom    = a_cts11m10_bkp[1].lclbrrnom
     let a_cts11m10[2].endzon       = a_cts11m10_bkp[1].endzon
     let a_cts11m10[2].lgdtip       = a_cts11m10_bkp[1].lgdtip
     let a_cts11m10[2].lgdnom       = a_cts11m10_bkp[1].lgdnom
     let a_cts11m10[2].lgdnum       = a_cts11m10_bkp[1].lgdnum
     let a_cts11m10[2].lgdcep       = a_cts11m10_bkp[1].lgdcep
     let a_cts11m10[2].lgdcepcmp    = a_cts11m10_bkp[1].lgdcepcmp
     let a_cts11m10[2].lclltt       = a_cts11m10_bkp[1].lclltt
     let a_cts11m10[2].lcllgt       = a_cts11m10_bkp[1].lcllgt
     let a_cts11m10[2].lclrefptotxt = a_cts11m10_bkp[1].lclrefptotxt
     let a_cts11m10[2].lclcttnom    = a_cts11m10_bkp[1].lclcttnom
     let a_cts11m10[2].dddcod       = a_cts11m10_bkp[1].dddcod
     let a_cts11m10[2].lcltelnum    = a_cts11m10_bkp[1].lcltelnum
     let a_cts11m10[2].c24lclpdrcod = a_cts11m10_bkp[1].c24lclpdrcod
     let a_cts11m10[2].ofnnumdig    = a_cts11m10_bkp[1].ofnnumdig
     let a_cts11m10[2].celteldddcod = a_cts11m10_bkp[1].celteldddcod
     let a_cts11m10[2].celtelnum    = a_cts11m10_bkp[1].celtelnum
     let a_cts11m10[2].endcmp       = a_cts11m10_bkp[1].endcmp
     let hist_cts11m10.hist1        = m_hist_cts11m10_bkp.hist1
     let hist_cts11m10.hist2        = m_hist_cts11m10_bkp.hist2
     let hist_cts11m10.hist3        = m_hist_cts11m10_bkp.hist3
     let hist_cts11m10.hist4        = m_hist_cts11m10_bkp.hist4
     let hist_cts11m10.hist5        = m_hist_cts11m10_bkp.hist5
     let a_cts11m10[2].emeviacod    = a_cts11m10_bkp[1].emeviacod

     return hist_cts11m10.*

  end if

end function

#-----------------------------------------#
 function cts11m10_verifica_tipo_atendim()
#-----------------------------------------#
  define l_atdetpcod  like datmsrvacp.atdetpcod

  open c_cts11m10_002 using g_documento.atdsrvnum
                           ,g_documento.atdsrvano
                           ,g_documento.atdsrvnum
                           ,g_documento.atdsrvano

  whenever error continue
  fetch c_cts11m10_002 into l_atdetpcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error 'Erro SELECT c_cts11m10_002: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     error ' cts11m10() / C24 / cts11m10_verifica_tipo_atendim ' sleep 2
     return 1, l_atdetpcod
  end if

  return 0, l_atdetpcod

end function

#-----------------------------------------#
 function cts11m10_verifica_op_ativa()
#-----------------------------------------#
  define lr_ret        record
         sttop         smallint
        ,errcod        smallint
        ,errdes        char(150)
  end record

  initialize lr_ret to null

  call ctb30m00_permite_alt_end_dst(g_documento.atdsrvano
                                   ,g_documento.atdsrvnum)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
     return true
  end if

  if lr_ret.sttop then
     return true
  end if

  return false

end function

#-----------------------------------------#
 function cts11m10_grava_historico()
#-----------------------------------------#
  define la_cts11m10       array[12] of record
         descricao         char (70)
  end record

  define lr_de             record
         atdsrvnum         like datmlcl.atdsrvnum
        ,atdsrvano         like datmlcl.atdsrvano
        ,lgdcep            char(9)
        ,cidnom            like datmlcl.cidnom
        ,ufdcod            like datmlcl.ufdcod
        ,lgdtip            like datmlcl.lgdtip
        ,lgdnom            like datmlcl.lgdnom
        ,lgdnum            like datmlcl.lgdnum
        ,brrnom            like datmlcl.brrnom
   end record

  define lr_para          record
         atdsrvnum        like datmlcl.atdsrvnum
        ,atdsrvano        like datmlcl.atdsrvano
        ,lgdcep           char(9)
        ,cidnom           like datmlcl.cidnom
        ,ufdcod           like datmlcl.ufdcod
        ,lgdtip           like datmlcl.lgdtip
        ,lgdnom           like datmlcl.lgdnom
        ,lgdnum           like datmlcl.lgdnum
        ,brrnom           like datmlcl.brrnom
  end record

  define lr_ret           record
         errcod           smallint   #Cod. Erro
        ,errdes           char(150)  #Descricao Erro
  end record

  define l_ind            smallint
        ,l_data           date
        ,l_hora           datetime hour to minute
        ,l_dstqtd         decimal(8,4)
        ,l_status         smallint

  initialize la_cts11m10  to null
  initialize lr_de        to null
  initialize lr_para      to null
  initialize lr_ret       to null

  let l_ind    = null
  let l_data   = null
  let l_hora   = null
  let l_dstqtd = null
  let l_status = null

  #busca a distancia entre os pontos
  whenever error continue
  select dstqtd
    into l_dstqtd
    from tmp_distancia
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_dstqtd = 0
  end if

  let la_cts11m10[01].descricao = "Informacoes do local de destino alterado"
  let la_cts11m10[02].descricao = "Em: ",today," As: ", time," Por: ",g_issk.funnom clipped
  let la_cts11m10[03].descricao = "."
  let la_cts11m10[04].descricao = "DE:"
  let la_cts11m10[05].descricao = "CEP: ", a_cts11m10_bkp[1].lgdcep clipped," - ",a_cts11m10_bkp[1].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts11m10_bkp[1].cidnom clipped," UF: ",a_cts11m10_bkp[1].ufdcod clipped
  let la_cts11m10[06].descricao = "Logradouro: ",a_cts11m10_bkp[1].lgdtip clipped," ",a_cts11m10_bkp[1].lgdnom clipped," "
                                                ,a_cts11m10_bkp[1].lgdnum clipped," ",a_cts11m10_bkp[1].brrnom
  let la_cts11m10[07].descricao = "."
  let la_cts11m10[08].descricao = "PARA:"
  let la_cts11m10[09].descricao = "CEP: ", a_cts11m10[2].lgdcep clipped," - ", a_cts11m10[2].lgdcepcmp using "<<<<<" clipped
                                 ," Cidade: ",a_cts11m10[2].cidnom clipped," UF: ",a_cts11m10[2].ufdcod  clipped
  let la_cts11m10[10].descricao = "Logradouro: ",a_cts11m10[2].lgdtip clipped," ",a_cts11m10[2].lgdnom clipped," "
                                                ,a_cts11m10[2].lgdnum clipped," ",a_cts11m10[2].brrnom
  let la_cts11m10[11].descricao = "."
  let la_cts11m10[12].descricao = "QTH - QTI: ",l_dstqtd," kms"

  call cts40g03_data_hora_banco(2)
     returning l_data, l_hora

  for l_ind = 1 to 12

     call cts10g02_historico(g_documento.atdsrvnum
                            ,g_documento.atdsrvano
                            ,l_data
                            ,l_hora
                            ,g_issk.funmat
                            ,la_cts11m10[l_ind].descricao
                            ,"","","","")
        returning l_status

     if l_status <> 0  then
        error "Erro (" , l_status, ") na inclusao do historico De/Para. " sleep 3
        error "Historico podera ser gravado com problemas." sleep 3
     end if

  end for

  #Chama funcao porto socorro que envia email do comunicado de alteracao
  let lr_de.atdsrvnum = g_documento.atdsrvnum
  let lr_de.atdsrvano = g_documento.atdsrvano
  let lr_de.lgdcep    = a_cts11m10_bkp[1].lgdcep clipped,"-",a_cts11m10_bkp[1].lgdcepcmp clipped
  let lr_de.cidnom    = a_cts11m10_bkp[1].cidnom clipped
  let lr_de.ufdcod    = a_cts11m10_bkp[1].ufdcod clipped
  let lr_de.lgdtip    = a_cts11m10_bkp[1].lgdtip clipped
  let lr_de.lgdnom    = a_cts11m10_bkp[1].lgdnom clipped
  let lr_de.lgdnum    = a_cts11m10_bkp[1].lgdnum clipped
  let lr_de.brrnom    = a_cts11m10_bkp[1].brrnom clipped

  let lr_para.atdsrvnum = g_documento.atdsrvnum
  let lr_para.atdsrvano = g_documento.atdsrvano
  let lr_para.lgdcep    = a_cts11m10[2].lgdcep clipped,"-", a_cts11m10[2].lgdcepcmp clipped
  let lr_para.cidnom    = a_cts11m10[2].cidnom clipped
  let lr_para.ufdcod    = a_cts11m10[2].ufdcod clipped
  let lr_para.lgdtip    = a_cts11m10[2].lgdtip clipped
  let lr_para.lgdnom    = a_cts11m10[2].lgdnom clipped
  let lr_para.lgdnum    = a_cts11m10[2].lgdnum clipped
  let lr_para.brrnom    = a_cts11m10[2].brrnom clipped

  call ctb30m00_apos_alt_end_dst(lr_de.*, lr_para.*, l_dstqtd)
     returning lr_ret.*

  if lr_ret.errcod <> 0 then
     error lr_ret.errdes sleep 3
  end if

end function

#--------------------------------------------------------------------------
function cts11m10_compara(lr_param)
#--------------------------------------------------------------------------
define lr_param  record
       asitipcod like datmservico.asitipcod,
       asimtvcod like datkasimtv.asimtvcod,
       clscod    char(3)
end record
   if lr_param.clscod = '37D' or lr_param.clscod = '37F' or
   	  lr_param.clscod = '37H'                            then
      if lr_param.asitipcod =  5 or
         lr_param.asitipcod = 10 or
         lr_param.asitipcod = 16 then
	       if lr_param.asimtvcod <> 1 and
	          lr_param.asimtvcod <> 2 and
	          lr_param.asimtvcod <> 3 and
	          lr_param.asimtvcod <> 4 and
	          lr_param.asimtvcod <> 13 then
            return 0
         end if
      end if
   end if
   if lr_param.clscod = '37E' or lr_param.clscod = '37G' then
      if lr_param.asitipcod =  5 or
         lr_param.asitipcod = 10 or
         lr_param.asitipcod = 16 then
	       if lr_param.asimtvcod <> 1 and
	          lr_param.asimtvcod <> 2 and
	          lr_param.asimtvcod <> 3 and
	          lr_param.asimtvcod <> 4 and
	          lr_param.asimtvcod <> 9 and
	          lr_param.asimtvcod <> 13 then
            return 0
         end if
      end if
   end if
   return 1
end function 