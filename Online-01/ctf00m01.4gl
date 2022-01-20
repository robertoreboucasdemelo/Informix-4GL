#############################################################################
# Nome do Modulo: CTF00M01                                         Nilo     #
#                                                                           #
# Funcao - Clausulas / Consulta / Copia                            Mai/2008 #
#############################################################################
#############################################################################
#...........................................................................#
#                 * * *  ALTERACOES  * * *                                  #
#                                                                           #
#Data       Autor Fabrica PSI       Alteracao                               #
#---------- ------------- --------- ----------------------------------------#
#---------------------------------------------------------------------------#
# 02/04/2009 Carla Rampazzo  PSI 239097 Inclusao da Clausula 76 p/ Ramo 118 #
#---------------------------------------------------------------------------#
# 13/08/2009 Sergio Burini   PSI 244236 Inclusão do Sub-Dairro              #
#---------------------------------------------------------------------------#
# 30/12/2009 Patricia W.     PSI 252247 Projeto SUCCOD - Smallint           #
#---------------------------------------------------------------------------#
# 05/04/2010 Carla Rampazzo  PSI 219444 Substituir funcoes do cts06g01 por  #
#                                       funcoes do framo240 - RE            #
#---------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo    PSI 242853 Implementacao do PSS                #
#---------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define am_param       array[10] of record          #---> Array de retorno
        socntzcod      like datmsrvre.socntzcod
       ,socntzdes      like datksocntz.socntzdes
       ,espcod         like datmsrvre.espcod
       ,espdes         like dbskesp.espdes
       ,c24pbmcod      like datkpbm.c24pbmcod
       ,atddfttxt      like datmservico.atddfttxt
 end record

 define ms             record
        prompt_key     char(01)                   ,
        retorno        smallint                   ,
        lignum         like datmligacao.lignum    ,
        atdsrvnum      like datmservico.atdsrvnum ,
        atdsrvano      like datmservico.atdsrvano ,
        codigosql      integer                    ,
        tabname        like systables.tabname     ,
        msg            char(80)                   ,
        caddat         like datmligfrm.caddat     ,
        cadhor         like datmligfrm.cadhor     ,
        cademp         like datmligfrm.cademp     ,
        cadmat         like datmligfrm.cadmat     ,
        servico        char (08)                  ,
        grlchv         like igbkgeral.grlchv      ,
        grlinf         like igbkgeral.grlinf      ,
        atdsrvseq      like datmsrvacp.atdsrvseq  ,
        atdetpcod      like datmsrvacp.atdetpcod  ,
        etpfunmat      like datmsrvacp.funmat     ,
        atdetpdat      like datmsrvacp.atdetpdat  ,
        atdetphor      like datmsrvacp.atdetphor  ,
        histerr        smallint                   ,
        socvclcod      like datmsrvacp.socvclcod
 end record

 define mr_hist   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 define d_ctf00m01    record
    srvnum            char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (20)                    ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    lclrscflg         char (01)                    ,
    orrdat            like datmsrvre.orrdat        ,
    servicorg         char(13)                     ,
    socntzcod         like datmsrvre.socntzcod     ,
    socntzdes         like datksocntz.socntzdes    ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    imdsrvflg         char (01)                    ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    prslocflg         char (01)                    ,
    frmflg            char (01)                    ,
    atdtxt            char (65)                    ,
    srvretmtvcod      like datksrvret.srvretmtvcod ,
    srvretmtvdes      like datksrvret.srvretmtvdes ,
    espcod            like datmsrvre.espcod        ,
    espdes            like dbskesp.espdes          ,
    retprsmsmflg       like datmsrvre.retprsmsmflg
 end record

 define w_ctf00m01    record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    viginc            like rsdmdocto.viginc        ,
    vigfnl            like rsdmdocto.vigfnl        ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    ligcvntip         like datmligacao.ligcvntip   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    prslocflg         char (01)                    ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    clscod            like datrsocntzsrvre.clscod  ,
    socvclcod         like datmsrvacp.socvclcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    atzendereco       dec(1,0),
    cartao            char(21)
 end record

 define a_ctf00m01    array[2] of record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig       ,
    emeviacod         like datmlcl.emeviacod       ,
    celteldddcod      like datmlcl.celteldddcod    ,
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp
 end record
 --------------------[ psi 202720-saude ruiz ]-------------------
 define lr_dados     record
        bnfnum       like datksegsau.bnfnum,
        crtsaunum    like datksegsau.crtsaunum,
        succod       like datksegsau.succod,
        ramcod       like datksegsau.ramcod,
        aplnumdig    like datksegsau.aplnumdig,
        crtstt       like datksegsau.crtstt,
        plncod       like datksegsau.plncod,
        segnom       like datksegsau.segnom,
        cgccpfnum    like datksegsau.cgccpfnum,
        cgcord       like datksegsau.cgcord,
        cgccpfdig    like datksegsau.cgccpfdig,
        empnom       like datksegsau.empnom,
        corsus       like datksegsau.corsus,
        cornom       like datksegsau.cornom,
        cntanvdat    like datksegsau.cntanvdat,
        lgdtip       like datksegsau.lgdtip,
        lgdnom       like datksegsau.lgdnom,
        lgdnum       like datksegsau.lgdnum,
        lclbrrnom    like datksegsau.lclbrrnom,
        cidnom       like datksegsau.cidnom,
        ufdcod       like datksegsau.ufdcod,
        lclrefptotxt like datksegsau.lclrefptotxt,
        endzon       like datksegsau.endzon,
        lgdcep       like datksegsau.lgdcep,
        lgdcepcmp    like datksegsau.lgdcepcmp,
        dddcod       like datksegsau.dddcod,
        lcltelnum    like datksegsau.lcltelnum,
        lclcttnom    like datksegsau.lclcttnom,
        lclltt       like datksegsau.lclltt,
        lcllgt       like datksegsau.lcllgt,
        incdat       like datksegsau.incdat,
        excdat       like datksegsau.excdat,
        brrnom       like datksegsau.brrnom,
        c24lclpdrcod like datksegsau.c24lclpdrcod
 end record
 -------------------------[ fim ]------------------------------
 define
    aux_today           char (10),
    aux_hora            char (05),
    ws_acao             char (03),
    ws_acaorigem        char (03),
    ws_tela             char (03),
    cpl_atdsrvnum       like datmservico.atdsrvnum,
    cpl_atdsrvano       like datmservico.atdsrvano,
    cpl_atdsrvorg       like datmservico.atdsrvorg,
    ws_refatdsrvnum_ini like datmservico.atdsrvnum,
    ws_refatdsrvano_ini like datmservico.atdsrvano,
    ws_cgccpfnum        like aeikcdt.cgccpfnum    ,
    ws_cgccpfdig        like aeikcdt.cgccpfdig    ,
    flgcpl              smallint,
    m_rmemdlcod         like datrsocntzsrvre.rmemdlcod,
    m_prepara_sql       smallint,
    m_erro              smallint,
    m_clscod            like datrsocntzsrvre.clscod,
    m_atdfnlflg         like datmservico.atdfnlflg,
    m_flg_aciona        char(01),
    m_criou_tabela      smallint,
    m_salva_tab         smallint,
    m_salva_mlt         smallint,
    m_data              date,
    m_hora              datetime hour to minute,
    m_veiculo_aciona    like datkveiculo.socvclcod, #PSI202363
    m_confirma_alt_prog char(1),
    m_tem_outros_srv    char(1)

 define m_wk            record
    prporg              like rsdmdocto.prporg,
    prpnumdig           like rsdmdocto.prpnumdig
 end record

 define mr_salva   record
        lgdnom     like datmlcl.lgdnom
       ,lgdnum     like datmlcl.lgdnum
       ,brrnom     like datmlcl.brrnom
       ,cidnom     like datmlcl.cidnom
       ,ufdcod     like datmlcl.ufdcod
       ,lgdcep     like datmlcl.lgdcep
       ,imdsrvflg  char(01)
       ,atddatprg  like datmservico.atddatprg
       ,atdhorprg  like datmservico.atdhorprg
       ,lclltt     like datmlcl.lclltt
       ,atdlibdat  like datmservico.atdlibdat
       ,atdlibhor  like datmservico.atdlibhor
       ,c24lclpdrcod like datmlcl.c24lclpdrcod
   end record

 define m_socntzcod   like datmsrvre.socntzcod

 define m_obter_mult smallint
     ,  m_acao       char(3)
     ,  m_tela       char(03)
     ,  m_tela2      char(03)
     ,  m_resultado  smallint
     ,  m_mensagem   char(100)
     ,  m_acntntqtd  like datmservico.acntntqtd
     ,  m_srv_acionado smallint
     ,  m_alt_end      char(1)

 define am_cts29g00  array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

 define m_servico_original   like datratdmltsrv.atdsrvnum
       ,m_ano_original       like datratdmltsrv.atdsrvano

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_retctb83m00 smallint #--PSI207233
 define m_c24astcodflag like datmligacao.c24astcod #--PSI207233
 define m_imdsrvflg_ant char(1)

 define ml_srvabrprsinfflg like datrgrpntz.srvabrprsinfflg  ## psi 218.545 PSS

#-------------------------------------------------------------------------------
 function ctf00m01_clausulas(param)
#-------------------------------------------------------------------------------

 define param    record
    succod       like datrservapol.succod,
    ramcod       like datrservapol.ramcod,
    aplnumdig    like datrservapol.aplnumdig,
    itmnumdig    like datrservapol.aplnumdig
   ,plncod       like datksegsau.plncod
   ,rmemdlcod    like datrsocntzsrvre.rmemdlcod
   ,erro         smallint
   ,prporg       like rsdmdocto.prporg
   ,prpnumdig    like rsdmdocto.prpnumdig
  ,lgdtxt       char (65)
   ,brrnom       like datmlcl.brrnom
   ,cidnom       like datmlcl.cidnom
   ,ufdcod       like datmlcl.ufdcod
   ,lgdnum       like datksegsau.lgdnum
   ,lgdcep       like datksegsau.lgdcep
   ,lgdcepcmp    like datksegsau.lgdcepcmp
   ,lclrefptotxt like datksegsau.lclrefptotxt
   ,crtsaunum    like datksegsau.crtsaunum
   ,succod_g     like datrligapol.succod
   ,ramcod_g     like datrservapol.ramcod
   ,aplnumdig_g  like datrligapol.aplnumdig
   ,cmnnumdig    like pptmcmn.cmnnumdig
   ,endlgdtip    like rlaklocal.endlgdtip
   ,endlgdnom    like rlaklocal.endlgdnom
   ,endnum       like rlaklocal.endnum
   ,endbrr       like rlaklocal.endbrr
   ,endcid       like rlaklocal.endcid
   ,ufdcod_g     like rlaklocal.ufdcod
   ,endcep       like rlaklocal.endcep
   ,endcepcmp    like rlaklocal.endcepcmp
   ,endcmp       like rlaklocal.endcmp
   ,clscod_g     like aackcls.clscod
 end record

 define ws      record
    clscod      like rsdmclaus.clscod      ,
    clscodant   like rsdmclaus.clscod ,
    rsdclscod   like rsdmclaus.clscod      ,
    datclscod   like datrsocntzsrvre.clscod,
    sgrorg      like rsdmdocto.sgrorg      ,
    sgrnumdig   like rsdmdocto.sgrnumdig   ,
    prporg      like rsdmdocto.prporg      ,
    prpnumdig   like rsdmdocto.prpnumdig
 end record

 define l_sql_stmt char(1000)

 initialize ws.*  to null

 let l_sql_stmt = null

 let l_sql_stmt =  "  select sgrorg,         "
                  ,"         sgrnumdig,      "
                  ,"         rmemdlcod       "
                  ,"    from rsamseguro      "
                  ,"   where succod    = ?   "
                  ,"     and ramcod    = ?   "
                  ,"     and aplnumdig = ?   "

 prepare pctf00m01004 from l_sql_stmt
 declare cctf00m01004 cursor for pctf00m01004

 if param.cmnnumdig is not null then

       --let param.clscod       = g_a_pptcls[1].clscod
       let ws.clscod       = g_a_pptcls[1].clscod
       let param.lgdtxt    = param.endlgdtip clipped, " ",
                                     param.endlgdnom clipped, " ",
                                     param.endnum
       let param.brrnom    = param.endbrr
       let param.cidnom    = param.endcid
       let param.ufdcod    = param.ufdcod
       let param.lgdnum    = param.endnum
       let param.lgdcep    = param.endcep
       let param.lgdcepcmp = param.endcepcmp
       if param.lclrefptotxt is null  then
          let param.lclrefptotxt = param.endcmp
       end if

    return ws.clscod
          ,param.plncod
          ,param.rmemdlcod
          ,param.erro
          ,param.prporg
          ,param.prpnumdig
          ,param.lgdtxt
          ,param.brrnom
          ,param.cidnom
          ,param.ufdcod
          ,param.lgdnum
          ,param.lgdcep
          ,param.lgdcepcmp
          ,param.lclrefptotxt
          ,param.crtsaunum
          ,param.succod_g
          ,param.ramcod_g
          ,param.aplnumdig_g
          ,param.cmnnumdig
          ,param.endlgdtip
          ,param.endlgdnom
          ,param.endnum
          ,param.endbrr
          ,param.endcid
          ,param.ufdcod_g
          ,param.endcep
          ,param.endcepcmp
          ,param.endcmp
          ,param.clscod_g
 end if

 ---------------------[ psi 202720-saude ruiz ]-----------------
 if param.crtsaunum is not null then    # Saude
    --let param.clscod = param.plncod
    let ws.clscod = param.plncod
    return ws.clscod
          ,param.plncod
          ,param.rmemdlcod
          ,param.erro
          ,param.prporg
          ,param.prpnumdig
          ,param.lgdtxt
          ,param.brrnom
          ,param.cidnom
          ,param.ufdcod
          ,param.lgdnum
          ,param.lgdcep
          ,param.lgdcepcmp
          ,param.lclrefptotxt
          ,param.crtsaunum
          ,param.succod_g
          ,param.ramcod_g
          ,param.aplnumdig_g
          ,param.cmnnumdig
          ,param.endlgdtip
          ,param.endlgdnom
          ,param.endnum
          ,param.endbrr
          ,param.endcid
          ,param.ufdcod_g
          ,param.endcep
          ,param.endcepcmp
          ,param.endcmp
          ,param.clscod_g
 end if
 ----------------------------[ fim ]----------------------------

 if param.succod    is not null  and
    param.ramcod    is not null  and
    param.aplnumdig is not null  then
    if param.ramcod = 31     or
       param.ramcod = 531  then

       let param.rmemdlcod = 0

       call f_funapol_ultima_situacao(param.succod,
                                      param.aplnumdig,
                                      param.itmnumdig)
                            returning g_funapol.*

       declare c_abbmclaus cursor for
        select clscod
          from abbmclaus
         where succod    = param.succod
           and aplnumdig = param.aplnumdig
           and itmnumdig = param.itmnumdig
           and dctnumseq = g_funapol.dctnumseq
           and clscod in ("033","33R","034","035","047","047R","044",
                          "34A","35A","35R","095") --varani

       foreach c_abbmclaus into ws.clscod


           if ws.clscod <> "034" and
              ws.clscod <> "071" then
             let ws.clscodant = ws.clscod
           end if

           if ws.clscod = "034" or
              ws.clscod = "071" or
              ws.clscod = "077"  then
             if cta13m00_verifica_clausula(param.succod        ,
                                           param.aplnumdig     ,
                                           param.itmnumdig     ,
                                           g_funapol.dctnumseq ,
                                           ws.clscod           ) then

              let ws.clscod = ws.clscodant
              continue foreach
             end if
           end if
       end foreach

    else
       #---------------------------------------------------------
       # Ramos Elementares
       #---------------------------------------------------------
       open cctf00m01004 using  param.succod
                               ,param.ramcod
                               ,param.aplnumdig
       whenever error continue
       fetch cctf00m01004 into  ws.sgrorg
                               ,ws.sgrnumdig
                               ,param.rmemdlcod
       whenever error stop

       if sqlca.sqlcode = 0   then
          #---------------------------------------------------------
          # Procura situacao da apolice/endosso
          #---------------------------------------------------------
          select prporg    , prpnumdig
            into ws.prporg , ws.prpnumdig
            from rsdmdocto
           where sgrorg    = ws.sgrorg
             and sgrnumdig = ws.sgrnumdig
             and dctnumseq = (select max(dctnumseq)
                                from rsdmdocto
                               where sgrorg     = ws.sgrorg
                                 and sgrnumdig  = ws.sgrnumdig
                                 and prpstt     in (19,65,66,88))

          if sqlca.sqlcode = 0   then
             declare c_rsdmclaus2 cursor for
              select clscod
                from rsdmclaus
               where prporg     = ws.prporg
                 and prpnumdig  = ws.prpnumdig
                 and lclnumseq  = 1
                 and clsstt     = "A"

             let ws.clscod = 0

             foreach c_rsdmclaus2  into  ws.rsdclscod
                let ws.datclscod = ws.rsdclscod
                case
                   when param.ramcod =  11 or
                        param.ramcod = 111
                        if (ws.datclscod = 13 or ws.datclscod = "13R") then
                           let ws.clscod = ws.datclscod
                        end if
                   when param.ramcod =   44 or
                        param.ramcod =  118
                        if (ws.datclscod = 20    or ws.datclscod = "20R")   or
                            ws.datclscod = 21    or
                            ws.datclscod = 22    or
                            ws.datclscod = 23    or
                           (ws.datclscod = 24    or ws.datclscod = "24C"  or ws.datclscod = "24R") or
                            ws.datclscod = 30    or
                           (ws.datclscod = 31    or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                           (ws.datclscod = 32    or ws.datclscod = "32R") or
                           (ws.datclscod = 36    or ws.datclscod = "36R") or
                           (ws.datclscod = 38    or ws.datclscod = "38R") or
 ## Alberto
                           (ws.datclscod = 59    or ws.datclscod = "59R") or
                           (ws.datclscod = 60    or ws.datclscod = "60R") or
                           (ws.datclscod = 61    or ws.datclscod = "61R") or
                            ws.datclscod = "55"  or ws.datclscod = "56"   or
                            ws.datclscod = "56R" or ws.datclscod = "56C"  or
                            ws.datclscod = "57"  or ws.datclscod = "57R"  or
                            ws.datclscod = 76                             then
 ## Nilo - 25/02/08
                           #inclusao da cls 36/36R-a pedido Judite-08/05/07
                           if ws.datclscod > ws.clscod  then
                              let ws.clscod = ws.datclscod
                           end if
                        end if

                   when param.ramcod =   45 or
                        param.ramcod =  114
                        if (ws.datclscod =   08  or ws.datclscod = "08C"  or
                            ws.datclscod = "8C"  or ws.datclscod = "08R"  or
                            ws.datclscod = "8R" ) or
                           (ws.datclscod =   10  or ws.datclscod = "10R") or
                           (ws.datclscod =   11  or ws.datclscod = "11R") or
                           (ws.datclscod =   12  or ws.datclscod = "12C"  or ws.datclscod = "12R") or
                           (ws.datclscod =   13  or ws.datclscod = "13R") or
                            ws.datclscod =   30  or
                           (ws.datclscod =   31  or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                           (ws.datclscod =   32  or ws.datclscod = "32R") or
                           (ws.datclscod =   39  or ws.datclscod = "39R") or
                           (ws.datclscod =   38  or ws.datclscod = "38R") or
                           (ws.datclscod =   40  or ws.datclscod = "40R") or   #  PSI-230.057 Inicio
                            ws.datclscod = "55"  or ws.datclscod = "56"   or
                            ws.datclscod = "56R" or ws.datclscod = "56C"  or
                            ws.datclscod = "57"  or ws.datclscod = "57R"  then #  PSI-230.057 Fim
                           #inclusao da cls 40/40R-a pedido Neia-07/05/07
                           if ws.datclscod > ws.clscod  then
                              let ws.clscod = ws.datclscod
                           end if
                        end if
                   when param.ramcod =   46 or
                        param.ramcod =  746
                        if ws.datclscod = 30      or
                          (ws.datclscod = 31      or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                          (ws.datclscod = 32      or ws.datclscod = "32R") then
                           if ws.datclscod > ws.clscod  then
                              let ws.clscod = ws.datclscod
                           end if
                        end if
                   when param.ramcod = 47
                      if (ws.datclscod = 10 or ws.datclscod = "10R") or
                         (ws.datclscod = 13 or ws.datclscod = "13R") then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                end case
             end foreach


             if ws.clscod = 0  then
                initialize ws.clscod to null
             end if
          end if
       else
          if sqlca.sqlcode < 0 then
             error 'Erro SELECT cctf00m01004: ' ,sqlca.sqlcode
             let param.erro = true
          end if
       end if
    end if
 end if

 let param.prporg    = ws.prporg
 let param.prpnumdig = ws.prpnumdig

 return ws.clscod
       ,param.plncod
       ,param.rmemdlcod
       ,param.erro
       ,param.prporg
       ,param.prpnumdig
       ,param.lgdtxt
       ,param.brrnom
       ,param.cidnom
       ,param.ufdcod
       ,param.lgdnum
       ,param.lgdcep
       ,param.lgdcepcmp
       ,param.lclrefptotxt
       ,param.crtsaunum
       ,param.succod_g
       ,param.ramcod_g
       ,param.aplnumdig_g
       ,param.cmnnumdig
       ,param.endlgdtip
       ,param.endlgdnom
       ,param.endnum
       ,param.endbrr
       ,param.endcid
       ,param.ufdcod_g
       ,param.endcep
       ,param.endcepcmp
       ,param.endcmp
       ,param.clscod_g

end function  ###  ctf00m01_clausulas
#--------------------------------------------------------------------
 function consulta_ctf00m01()
#--------------------------------------------------------------------

 define ws            record
    funmat            like isskfunc.funmat         ,
    funnom            char (15)                    ,
    dptsgl            like isskfunc.dptsgl         ,
    lignum            like datrligsrv.lignum       ,
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp     ,
    succod            like datrligapol.succod      ,
    ramcod            like datrligapol.ramcod      ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    cogidosql         integer                      ,
    atdprscod         like datmservico.atdprscod   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapcorg          like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt
 end record

 define l_espsit      like dbskesp.espsit   #PSI195138
 define l_c24astcod   like datkassunto.c24astcod
 define l_cgccpf      char(12)
 define l_sql_stmt    char(500)
 define l_resultado   smallint
 define l_mensagem    char(60)


 let l_sql_stmt  = null
 let l_resultado = null
 let l_mensagem  = null
 let l_cgccpf    = null

 let d_ctf00m01.espcod = null
 initialize mr_salva, ws  to null

 let l_sql_stmt = "select cgccpfnum,  "  ,
                  "       cgcord   ,  "  ,
                  "       cgccpfdig   "  ,
                  "from datrligcgccpf "  ,
                  "where lignum = ?  "
 prepare pcomando5 from l_sql_stmt
 declare ccomando5 cursor for pcomando5


 select nom      ,
        cornom   ,
        corsus   ,
        atddfttxt,
        funmat   ,
        asitipcod,
        atddat   ,
        atdhor   ,
        atdlibflg,
        atdlibhor,
        atdlibdat,
        atdhorpvt,
        atdpvtretflg,
        atddatprg,
        atdhorprg,
        atdfnlflg,
        atdprinvlcod,
        atdprscod,
        prslocflg,
        acntntqtd,
        ciaempcod
   into d_ctf00m01.nom      ,
        d_ctf00m01.cornom   ,
        d_ctf00m01.corsus   ,
        d_ctf00m01.atddfttxt,
        ws.funmat           ,
        d_ctf00m01.asitipcod,
        w_ctf00m01.atddat   ,
        w_ctf00m01.atdhor   ,
        d_ctf00m01.atdlibflg,
        w_ctf00m01.atdlibhor,
        w_ctf00m01.atdlibdat,
        w_ctf00m01.atdhorpvt,
        w_ctf00m01.atdpvtretflg,
        w_ctf00m01.atddatprg,
        w_ctf00m01.atdhorprg,
        w_ctf00m01.atdfnlflg,
        d_ctf00m01.atdprinvlcod,
        ws.atdprscod,
        d_ctf00m01.prslocflg,
        m_acntntqtd,
        g_documento.ciaempcod
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    #error " Servico nao encontrado. AVISE A INFORMATICA!"
    return 1 ," Servico nao encontrado. AVISE A INFORMATICA!"
 end if

 let m_atdfnlflg = w_ctf00m01.atdfnlflg

 select lclrsccod,
        orrdat   ,
        socntzcod,
        atdorgsrvnum,
        atdorgsrvano,
        srvretmtvcod,
        espcod,
        retprsmsmflg
   into d_ctf00m01.lclrsccod,
        d_ctf00m01.orrdat   ,
        d_ctf00m01.socntzcod,
        cpl_atdsrvnum,
        cpl_atdsrvano,
        d_ctf00m01.srvretmtvcod,
        d_ctf00m01.espcod,
        d_ctf00m01.retprsmsmflg
   from datmsrvre
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    #error " Socorro Ramos Elementares nao encontrado. AVISE A INFORMATICA!"
    return 2 ,"Socorro Ramos Elementares nao encontrado. AVISE A INFORMATICA!"
 end if

 initialize d_ctf00m01.servicorg  to null
 if cpl_atdsrvnum is not null then
    let cpl_atdsrvorg = 09
    let d_ctf00m01.servicorg  = cpl_atdsrvorg using "&&",
                                "/", cpl_atdsrvnum using "&&&&&&&",
                                "-", cpl_atdsrvano using "&&"
 end if

#--------------------------------------------------------------------
# Informacoes do motivo retorno
#--------------------------------------------------------------------
 initialize d_ctf00m01.srvretmtvdes to null
 if d_ctf00m01.srvretmtvcod is not null then

    if d_ctf00m01.srvretmtvcod = 999  then
       select srvretexcdes
         into d_ctf00m01.srvretmtvdes
         from datmsrvretexc
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
    else
       select srvretmtvdes
         into d_ctf00m01.srvretmtvdes
         from datksrvret
        where srvretmtvcod  = d_ctf00m01.srvretmtvcod
    end if

 end if

 if g_documento.ramcod = 06 then
    select cmnnumdig into g_ppt.cmnnumdig
      from datrligppt
     where lignum = w_ctf00m01.lignum
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 if g_ppt.cmnnumdig is null then
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            1)
                  returning a_ctf00m01[1].lclidttxt   ,
                            a_ctf00m01[1].lgdtip      ,
                            a_ctf00m01[1].lgdnom      ,
                            a_ctf00m01[1].lgdnum      ,
                            a_ctf00m01[1].lclbrrnom   ,
                            a_ctf00m01[1].brrnom      ,
                            a_ctf00m01[1].cidnom      ,
                            a_ctf00m01[1].ufdcod      ,
                            a_ctf00m01[1].lclrefptotxt,
                            a_ctf00m01[1].endzon      ,
                            a_ctf00m01[1].lgdcep      ,
                            a_ctf00m01[1].lgdcepcmp   ,
                            a_ctf00m01[1].lclltt      ,
                            a_ctf00m01[1].lcllgt      ,
                            a_ctf00m01[1].dddcod      ,
                            a_ctf00m01[1].lcltelnum   ,
                            a_ctf00m01[1].lclcttnom   ,
                            a_ctf00m01[1].c24lclpdrcod,
                            a_ctf00m01[1].celteldddcod,
                            a_ctf00m01[1].celtelnum,
                            a_ctf00m01[1].endcmp,
                            ws.cogidosql, a_ctf00m01[1].emeviacod

 select ofnnumdig into a_ctf00m01[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.cogidosql <> 0  then
    #error " Erro (", ws.cogidosql using "<<<<<&", ") na leitura local de ocorrencia. AVISE A INFORMATICA!"
    return 3 ,"Erro na leitura local de ocorrencia. AVISE A INFORMATICA!"
 end if

 let a_ctf00m01[1].lgdtxt = a_ctf00m01[1].lgdtip clipped, " ",
                            a_ctf00m01[1].lgdnom clipped, " ",
                            a_ctf00m01[1].lgdnum using "<<<<#"

   if d_ctf00m01.lclrsccod is not null  then

      ---> Buscar Endereco do Local de Risco
      call framo240_dados_local_risco(d_ctf00m01.lclrsccod)
                   returning l_resultado
                            ,l_mensagem
                            ,ws.endlgdtip
                            ,ws.endlgdnom
                            ,ws.endnum
                            ,ws.endcmp
                            ,ws.endbrr
                            ,ws.endcid
                            ,ws.ufdcod
                            ,ws.endcep
                            ,ws.endcepcmp
                            ,ws.lclltt
                            ,ws.lcllgt

      if a_ctf00m01[1].lclrefptotxt is null  then
         let a_ctf00m01[1].lclrefptotxt = ws.endcmp
      end if

      if a_ctf00m01[1].lgdtip    = ws.endlgdtip  and
         a_ctf00m01[1].lgdnom    = ws.endlgdnom  and
         a_ctf00m01[1].lgdnum    = ws.endnum     and
         a_ctf00m01[1].brrnom    = ws.endbrr     and
         a_ctf00m01[1].cidnom    = ws.endcid     and
         a_ctf00m01[1].ufdcod    = ws.ufdcod     then
         let d_ctf00m01.lclrscflg = "S"
      else
         let d_ctf00m01.lclrscflg = "N"
      end if
   else
    let d_ctf00m01.lclrscflg = "N"
   end if
 else
    if g_ppt.cmnnumdig is not null then
       let a_ctf00m01[1].lgdtip    = g_ppt.endlgdtip
       let a_ctf00m01[1].lgdnom    = g_ppt.endlgdnom
       let a_ctf00m01[1].lgdnum    = g_ppt.endnum
       let a_ctf00m01[1].brrnom    = g_ppt.endbrr
       let a_ctf00m01[1].cidnom    = g_ppt.endcid
       let a_ctf00m01[1].ufdcod    = g_ppt.ufdcod
       let a_ctf00m01[1].lgdnum    = g_ppt.endnum
       let a_ctf00m01[1].lgdcep    = g_ppt.endcep
       let a_ctf00m01[1].lgdcepcmp = g_ppt.endcepcmp
       if a_ctf00m01[1].lclrefptotxt is null  then
          let a_ctf00m01[1].lclrefptotxt = g_ppt.endcmp
       end if
    end if
 end if

 let d_ctf00m01.socntzdes = "*** NAO CADASTRADA ***"

 select socntzdes
   into d_ctf00m01.socntzdes
   from datksocntz
  where socntzcod = d_ctf00m01.socntzcod

 #PSI195138 - busca descricao especialidade
 let d_ctf00m01.espdes = null
 if d_ctf00m01.espcod is not null then

    #como so quero buscar a descricao, nao importando a situacao da
    # especialidade (ativo ou nao), passo null para a funcao

    let l_espsit = null
    call cts31g00_descricao_esp(d_ctf00m01.espcod, l_espsit)
         returning d_ctf00m01.espdes

    if d_ctf00m01.espdes is null then
       #error "Descricao nao encontrada para especialidade."
    end if
 end if

 let d_ctf00m01.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_ctf00m01.asitipabvdes
   from datkasitip
  where asitipcod = d_ctf00m01.asitipcod

#--------------------------------------------------------------------
# Identificacao do SOLICITANTE/CONVENIO
#--------------------------------------------------------------------
 let w_ctf00m01.lignum =
     cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_ctf00m01.lignum)
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

 ------[psi 202720-saude pesquisa numero do cartao atraves da ligacao ]------
 call cts20g09_docto(1, w_ctf00m01.lignum)
      returning g_documento.crtsaunum
 -----------------------[ fim ]----------------------------------

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_ctf00m01.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",  #"&&",  #projeto succod
                                     " ", g_documento.ramcod    using "##&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_ctf00m01.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 if g_ppt.cmnnumdig is not null then
    let d_ctf00m01.doctxt = "Contrato.:", g_ppt.cmnnumdig
 end if
 if g_documento.ciaempcod = 43 then # PSI 247936 Empresas 27
    let d_ctf00m01.doctxt = "Contrato.:", g_pss.psscntcod using "&&&&&&&&&&"
 end if

 -----------------------[ psi202720-saude - ruiz ]--------------------
 if g_documento.crtsaunum is not null then
    call cts20g16_formata_cartao(g_documento.crtsaunum)
            returning w_ctf00m01.cartao
    let d_ctf00m01.doctxt = "Cartao: ",w_ctf00m01.cartao
 end if
 --------------------------[ fim ]----------------------------------

 -----------------------[PortoSeg - Roberto ]--------------------

 if g_documento.ciaempcod = 40 then

     open ccomando5  using w_ctf00m01.lignum
        fetch ccomando5 into lr_dados.cgccpfnum ,
                             lr_dados.cgcord    ,
                             lr_dados.cgccpfdig

     close ccomando5


     let l_cgccpf = lr_dados.cgccpfnum using '&&&&&&<<<<<<'
     let l_cgccpf = l_cgccpf[4,6],".",l_cgccpf[7,9],".",l_cgccpf[10,12]


     if lr_dados.cgcord = 0 then
           let d_ctf00m01.doctxt = "CPF: ",  l_cgccpf clipped ,"-", lr_dados.cgccpfdig using '&<', " - PORTOSEG"
     else
           let d_ctf00m01.doctxt = "CGC: ", l_cgccpf clipped ,"/", lr_dados.cgcord using '&&&<' ,"-", lr_dados.cgccpfdig using '&<', " - PORTOSEG"
     end if

 end if

 --------------------------[ fim ]----------------------------------


 #Ler assunto, pois qdo entro pelo radio nao tenho nenhum assunto
 # selecionado
 select c24solnom, ligcvntip, c24astcod
   into d_ctf00m01.c24solnom, w_ctf00m01.ligcvntip, l_c24astcod
   from datmligacao
  where lignum = w_ctf00m01.lignum

 #caso seja RET nao substituo o assunto, pois o cts40g12 tem tratamento
 #especifico para retorno e nao posso enviar o assunto original
 if g_documento.acao <> "RET" then
    let g_documento.c24astcod = l_c24astcod
 end if

 let g_documento.solnom = d_ctf00m01.c24solnom

 select lignum from datmligfrm
  where lignum = w_ctf00m01.lignum

 if sqlca.sqlcode = notfound  then
    let d_ctf00m01.frmflg = "N"
 else
    let d_ctf00m01.frmflg = "S"
 end if

 select cpodes
   into d_ctf00m01.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_ctf00m01.ligcvntip

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = 1
    and funmat = ws.funmat

 let d_ctf00m01.atdtxt = w_ctf00m01.atddat           , " ",
                         w_ctf00m01.atdhor           , " ",
                         upshift(ws.dptsgl)   clipped, " ",
                         ws.funmat  using "&&&&&&"   , " ",
                         upshift(ws.funnom)   clipped, " ",
                         w_ctf00m01.atdlibdat        , " ",
                         w_ctf00m01.atdlibhor

 if w_ctf00m01.atdhorpvt is not null  or
    w_ctf00m01.atdhorpvt  = "00:00"   then
    let d_ctf00m01.imdsrvflg = "S"
 end if

 if w_ctf00m01.atddatprg is not null  then
    let d_ctf00m01.imdsrvflg = "N"
 end if

 let w_ctf00m01.atdlibflg = d_ctf00m01.atdlibflg

 if d_ctf00m01.atdlibflg = "N"  then
    let w_ctf00m01.atdlibdat = w_ctf00m01.atddat
    let w_ctf00m01.atdlibhor = w_ctf00m01.atdhor
 end if

 let d_ctf00m01.srvnum = g_documento.atdsrvorg using "&&",
                    "/", g_documento.atdsrvnum using "&&&&&&&",
                    "-", g_documento.atdsrvano using "&&"
 select cpodes
   into d_ctf00m01.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_ctf00m01.atdprinvlcod

 select c24pbmcod
   into d_ctf00m01.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = g_documento.atdsrvnum
    and atdsrvano    = g_documento.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

 let mr_salva.lgdnom    = a_ctf00m01[1].lgdnom
 let mr_salva.lgdnum    = a_ctf00m01[1].lgdnum
 let mr_salva.brrnom    = a_ctf00m01[1].brrnom
 let mr_salva.cidnom    = a_ctf00m01[1].cidnom
 let mr_salva.ufdcod    = a_ctf00m01[1].ufdcod
 let mr_salva.lgdcep    = a_ctf00m01[1].lgdcep
 let mr_salva.lclltt    = a_ctf00m01[1].lclltt
 let mr_salva.imdsrvflg = d_ctf00m01.imdsrvflg
 let mr_salva.atddatprg = w_ctf00m01.atddatprg
 let mr_salva.atdhorprg = w_ctf00m01.atdhorprg
 let mr_salva.atdlibdat = w_ctf00m01.atdlibdat
 let mr_salva.atdlibhor = w_ctf00m01.atdlibhor
 let mr_salva.c24lclpdrcod = a_ctf00m01[1].c24lclpdrcod

 select max(atdsrvseq) into ms.atdsrvseq from datmsrvacp
    where atdsrvnum = g_documento.atdsrvnum
      and atdsrvano = g_documento.atdsrvano

       select atdetpcod into ms.atdetpcod from datmsrvacp
        where atdsrvnum = g_documento.atdsrvnum
          and atdsrvano = g_documento.atdsrvano
          and atdsrvseq = ms.atdsrvseq

 let m_c24lclpdrcod = a_ctf00m01[1].c24lclpdrcod

 return 0 ,''

end function  ###  consulta_ctf00m01

#-------------------------------------------------------------------------------
 function ctf00m01_copia()
#-------------------------------------------------------------------------------

 define ws            record
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp     ,
    atdorgsrvnum      like datmsrvre.atdorgsrvnum  ,
    atdorgsrvano      like datmsrvre.atdorgsrvano  ,
    confirma          char (01)                    ,
    c24solnom_cp      like datmligacao.c24solnom   ,
    ligcvntip_cp      like datmligacao.ligcvntip   ,
    nom_cp            like datmservico.nom         ,
    corsus_cp         like datmservico.corsus      ,
    cornom_cp         like datmservico.cornom      ,
    cvnnom_cp         char (20)                    ,
    cogidosql         integer                      ,
    atdsrvseq         like datmsrvacp.atdsrvseq    ,
    socvclcod         like datmsrvacp.socvclcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    pstcoddig         like datmservico.atdprscod   ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    funmat            like isskfunc.funmat         ,
    atdprscod         like datmservico.atdprscod

 end record

 define l_espsit   like dbskesp.espsit

 define l_xml_retorno    char(32000)
 define l_erro           smallint
 define l_msg_erro       char(1000)
 define l_resultado      smallint
 define l_mensagem       char(60)

 let l_xml_retorno = null
 let l_erro        = null
 let l_msg_erro    = null
 let l_resultado   = null
 let l_mensagem    = null

 initialize g_ppt.* to null

    let ws_acao       = "RET"
    let ws_acaorigem  = "RET"
    let cpl_atdsrvorg         = 09
    let cpl_atdsrvnum         = g_documento.atdsrvnum
    let cpl_atdsrvano         = g_documento.atdsrvano
    let ws_refatdsrvnum_ini   = g_documento.atdsrvnum
    let ws_refatdsrvano_ini   = g_documento.atdsrvano
    let g_documento.c24astcod = "RET"
    let d_ctf00m01.retprsmsmflg = "S"

 #------------------------------------------------
 # Acessa servico
 #------------------------------------------------
  initialize  ws.*  to  null

  select atddfttxt, asitipcod, nom, corsus, cornom
    into d_ctf00m01.atddfttxt, d_ctf00m01.asitipcod,
         ws.nom_cp, ws.corsus_cp, ws.cornom_cp
    from datmservico
   where atdsrvnum = g_documento.atdsrvnum
     and atdsrvano = g_documento.atdsrvano

  if d_ctf00m01.nom is null then
     let d_ctf00m01.nom  =  ws.nom_cp
  end if
  if d_ctf00m01.corsus is null then
     let d_ctf00m01.corsus  =  ws.corsus_cp
     let d_ctf00m01.cornom  =  ws.cornom_cp
  end if

 #------------------------------------------------
 # Acessa ligacao
 #------------------------------------------------
  declare c_lig cursor for
   select c24solnom, ligcvntip
     from datmligacao
    where atdsrvnum = g_documento.atdsrvnum
      and atdsrvano = g_documento.atdsrvano

  foreach c_lig into ws.c24solnom_cp, ws.ligcvntip_cp
     exit foreach
  end foreach

  if g_documento.ligcvntip is null and
     ws.ligcvntip_cp is not null   then

     let g_documento.ligcvntip = ws.ligcvntip_cp
     let w_ctf00m01.ligcvntip  = g_documento.ligcvntip

     select cpodes into d_ctf00m01.cvnnom from datkdominio
      where cponom = "ligcvntip"   and
            cpocod = w_ctf00m01.ligcvntip
  end if

 #------------------------------------------------
 # Acessa dados do RE
 #------------------------------------------------
  select lclrsccod   , atdorgsrvnum,
         atdorgsrvano, socntzcod   ,orrdat, espcod
    into d_ctf00m01.lclrsccod, ws.atdorgsrvnum,
         ws.atdorgsrvano     , d_ctf00m01.socntzcod,
         d_ctf00m01.orrdat   , d_ctf00m01.espcod
    from datmsrvre
   where datmsrvre.atdsrvnum = cpl_atdsrvnum
     and datmsrvre.atdsrvano = cpl_atdsrvano

  if ws.atdorgsrvnum is null  or
     ws_acaorigem    = "RET"  then
     let ws.atdorgsrvnum = cpl_atdsrvnum
     let ws.atdorgsrvano = cpl_atdsrvano
  end if

  let cpl_atdsrvnum = ws.atdorgsrvnum
  let cpl_atdsrvano = ws.atdorgsrvano

    whenever error continue
    select max(atdsrvseq) into ws.atdsrvseq from datmsrvacp
    where atdsrvnum = ws.atdorgsrvnum and
        atdsrvano = ws.atdorgsrvano and
        atdetpcod = 3               and
        pstcoddig is not null

    whenever error stop

    if sqlca.sqlcode = 0 then

       select pstcoddig,srrcoddig,socvclcod
       into ws.pstcoddig,ws.srrcoddig,ws.socvclcod
       from datmsrvacp
       where atdsrvnum = ws.atdorgsrvnum and
           atdsrvano = ws.atdorgsrvano and
           atdsrvseq = ws.atdsrvseq

       if ws.socvclcod is not null then

          select atdvclsgl into ws.atdvclsgl from datkveiculo
          where socvclcod = ws.socvclcod
       end if
    else
       initialize ws.pstcoddig, ws.srrcoddig, ws.socvclcod to null
       let l_msg_erro    = "Registro nao encontrado no acesso a tabela datmsrvacp."
       let l_xml_retorno = ctf00m06_xmlerro("REGISTRAR_RETORNO_SERVICO",11,l_msg_erro)
       return l_xml_retorno,
              a_ctf00m01[1].lgdtip,
              a_ctf00m01[1].lgdnom,
              a_ctf00m01[1].lgdnum,
              a_ctf00m01[1].brrnom,
              a_ctf00m01[1].cidnom,
              a_ctf00m01[1].ufdcod,
              a_ctf00m01[1].lclrefptotxt,
              a_ctf00m01[1].endzon,
              a_ctf00m01[1].lgdcep,
              a_ctf00m01[1].lgdcepcmp,
              a_ctf00m01[1].lclcttnom,
              a_ctf00m01[1].dddcod,
              a_ctf00m01[1].lcltelnum,
              d_ctf00m01.orrdat,
              d_ctf00m01.socntzcod,
              d_ctf00m01.espcod,
              d_ctf00m01.c24pbmcod
    end if

    let w_ctf00m01.atdprscod = ws.pstcoddig
    let w_ctf00m01.srrcoddig = ws.srrcoddig
    let w_ctf00m01.socvclcod = ws.socvclcod

  call ctx04g00_local_gps(cpl_atdsrvnum, cpl_atdsrvano, 1)
                returning a_ctf00m01[1].lclidttxt   ,
                          a_ctf00m01[1].lgdtip      ,
                          a_ctf00m01[1].lgdnom      ,
                          a_ctf00m01[1].lgdnum      ,
                          a_ctf00m01[1].lclbrrnom   ,
                          a_ctf00m01[1].brrnom      ,
                          a_ctf00m01[1].cidnom      ,
                          a_ctf00m01[1].ufdcod      ,
                          a_ctf00m01[1].lclrefptotxt,
                          a_ctf00m01[1].endzon      ,
                          a_ctf00m01[1].lgdcep      ,
                          a_ctf00m01[1].lgdcepcmp   ,
                          a_ctf00m01[1].lclltt      ,
                          a_ctf00m01[1].lcllgt      ,
                          a_ctf00m01[1].dddcod      ,
                          a_ctf00m01[1].lcltelnum   ,
                          a_ctf00m01[1].lclcttnom   ,
                          a_ctf00m01[1].c24lclpdrcod,
                          a_ctf00m01[1].celteldddcod,
                          a_ctf00m01[1].celtelnum,
                          a_ctf00m01[1].endcmp,
                          ws.cogidosql, a_ctf00m01[1].emeviacod

  if ws.cogidosql <> 0  then
     let l_msg_erro    = "Erro (", ws.cogidosql using "<<<<<&", "). AVISE A INFORMATICA!"
     let l_xml_retorno = ctf00m06_xmlerro("REGISTRAR_RETORNO_SERVICO",10,l_msg_erro)
     return l_xml_retorno,
            a_ctf00m01[1].lgdtip,
            a_ctf00m01[1].lgdnom,
            a_ctf00m01[1].lgdnum,
            a_ctf00m01[1].brrnom,
            a_ctf00m01[1].cidnom,
            a_ctf00m01[1].ufdcod,
            a_ctf00m01[1].lclrefptotxt,
            a_ctf00m01[1].endzon,
            a_ctf00m01[1].lgdcep,
            a_ctf00m01[1].lgdcepcmp,
            a_ctf00m01[1].lclcttnom,
            a_ctf00m01[1].dddcod,
            a_ctf00m01[1].lcltelnum,
            d_ctf00m01.orrdat,
            d_ctf00m01.socntzcod,
            d_ctf00m01.espcod,
            d_ctf00m01.c24pbmcod
  end if

  select ofnnumdig
    into a_ctf00m01[1].ofnnumdig
    from datmlcl
   where atdsrvano = g_documento.atdsrvano
     and atdsrvnum = g_documento.atdsrvnum
     and c24endtip = 1

  let a_ctf00m01[1].lgdtxt = a_ctf00m01[1].lgdtip clipped, " ",
                             a_ctf00m01[1].lgdnom clipped, " ",
                             a_ctf00m01[1].lgdnum using "<<<<#"

  if d_ctf00m01.lclrsccod is not null  then

     ---> Buscar Endereco do Local de Risco
     call framo240_dados_local_risco(d_ctf00m01.lclrsccod)
                  returning l_resultado
                           ,l_mensagem
                           ,ws.endlgdtip
                           ,ws.endlgdnom
                           ,ws.endnum
                           ,ws.endcmp
                           ,ws.endbrr
                           ,ws.endcid
                           ,ws.ufdcod
                           ,ws.endcep
                           ,ws.endcepcmp
                           ,ws.lclltt
                           ,ws.lcllgt

     if a_ctf00m01[1].lclrefptotxt is null  then
        let a_ctf00m01[1].lclrefptotxt = ws.endcmp
     end if

     if a_ctf00m01[1].lgdtip    = ws.endlgdtip  and
        a_ctf00m01[1].lgdnom    = ws.endlgdnom  and
        a_ctf00m01[1].lgdnum    = ws.endnum     and
        a_ctf00m01[1].brrnom    = ws.endbrr     and
        a_ctf00m01[1].cidnom    = ws.endcid     and
        a_ctf00m01[1].ufdcod    = ws.ufdcod     then
        let d_ctf00m01.lclrscflg = "S"
     else
        let d_ctf00m01.lclrscflg = "N"
     end if
  else
     let d_ctf00m01.lclrscflg = "N"
  end if

  initialize d_ctf00m01.servicorg  to null
  if cpl_atdsrvnum is not null then
     let cpl_atdsrvorg         = 09
     let d_ctf00m01.servicorg  = cpl_atdsrvorg using "&&",
                                 "/", cpl_atdsrvnum using "&&&&&&&",
                                 "-", cpl_atdsrvano using "&&"
  end if

  #------------------------------------------
  # Acessa problema servico
  #------------------------------------------
  select c24pbmcod
   into d_ctf00m01.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = g_documento.atdsrvnum
    and atdsrvano    = g_documento.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

  #------------------------------------------
  # Acessa descricao natureza
  #------------------------------------------
  let d_ctf00m01.socntzdes = "*** NAO CADASTRADA ***"
  select socntzdes
    into d_ctf00m01.socntzdes
    from datksocntz
   where socntzcod = d_ctf00m01.socntzcod

  #------------------------------------------
  # Acessa descricao especialidade
  #------------------------------------------
  let d_ctf00m01.espdes = null
  if d_ctf00m01.espcod is not null then

      let d_ctf00m01.espdes = "*** NAO CADASTRADA ***"
      #como nao importa a situacao da especialidade (ativa ou nao) vou buscar
      # apenas a descricao, entao vou passar null
      let l_espsit = null

      call cts31g00_descricao_esp(d_ctf00m01.espcod, l_espsit)
           returning d_ctf00m01.espdes

      if d_ctf00m01.espdes is null then
         #error "Descricao nao encontrada para especialidade."
      end if

  end if

  #------------------------------------------
  # Acessa descricao tipo servico
  #------------------------------------------
  let d_ctf00m01.asitipabvdes = "NAO PREV"
  select asitipabvdes
    into d_ctf00m01.asitipabvdes
    from datkasitip
   where asitipcod = d_ctf00m01.asitipcod

   let l_xml_retorno = null

   call consulta_ctf00m01() returning l_erro, l_msg_erro

   if l_erro <> 0 then
      let l_xml_retorno = ctf00m06_xmlerro("REGISTRAR_RETORNO_SERVICO",l_erro,l_msg_erro)
   end if

   return l_xml_retorno,
          a_ctf00m01[1].lgdtip,
          a_ctf00m01[1].lgdnom,
          a_ctf00m01[1].lgdnum,
          a_ctf00m01[1].brrnom,
          a_ctf00m01[1].cidnom,
          a_ctf00m01[1].ufdcod,
          a_ctf00m01[1].lclrefptotxt,
          a_ctf00m01[1].endzon,
          a_ctf00m01[1].lgdcep,
          a_ctf00m01[1].lgdcepcmp,
          a_ctf00m01[1].lclcttnom,
          a_ctf00m01[1].dddcod,
          a_ctf00m01[1].lcltelnum,
          d_ctf00m01.orrdat,
          d_ctf00m01.socntzcod,
          d_ctf00m01.espcod,
          d_ctf00m01.c24pbmcod

  let flgcpl = 1

end function  ###  ctf00m01_copia
