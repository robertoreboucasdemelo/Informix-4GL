#------------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                               #
#..............................................................................#
#Sistema       : Central 24hs                                                  #
#Modulo        : cts66m00                                                      #
#Analista Resp : Ligia - Fornax                                                #
#                Laudo para assistencia a passageiros - Residencia Itau        #
#..............................................................................#
#Desenvolvimento: Hamilton - Fornax                                            #
#Liberacao      : 26/07/2012                                                   #
#------------------------------------------------------------------------------#
#                                                                              #
#                         * * * Alteracoes * * *                               #
#                                                                              #
#Data       Autor Fabrica  Origem     Alteracao                                #
#------------------------------------------------------------------------------#
# 27/05/2014  Fabio, Fornax  PSI-2013-00440PR  Inclusao regulacao via AW       #
#------------------------------------------------------------------------------#
 
database porto        

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_cts66m00 record
       servico       char (13)                         ,
       c24solnom     like datmligacao.c24solnom        ,
       nom           like datmservico.nom              ,
       doctxt        char (32)                         ,
       corsus        char (06)                         ,
       cornom        like datmservico.cornom           ,
       cvnnom        char (19)                         ,
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

 define w_cts66m00 record
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

 define a_cts66m00   array[3] of record
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

 define m_cts66m00_sql     smallint,
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

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint

 define mr_retorno record
        erro    smallint
       ,mens    char(100)
 end record
                 
 define m_limites_plano record
   pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
   socqlmqtd     like datkitaasipln.socqlmqtd    ,
   erro          integer                         ,
   mensagem      char(50)
 end record
 
 define m_retctb83m00 smallint

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
      
#------------------------------------------------------------------------------#
function cts66m00_prepare()
#------------------------------------------------------------------------------#
 define l_sql char(1000)

 let l_sql  =  null

 let l_sql = " select grlinf "
            ,"   from igbkgeral "
            ,"  where mducod = 'C24'"
            ,"    and grlchv = 'RADIO-DEMAU'"

 prepare p_cts66m00_001 from l_sql
 declare c_cts66m00_001 cursor for p_cts66m00_001

 let l_sql = " select asitipcod      ",
            "   from datmservico    ",
            "   where atdsrvnum = ? ",
            "   and atdsrvano =  ?  "
prepare p_cts66m00_002 from l_sql
declare c_cts66m00_002 cursor for p_cts66m00_002

let l_sql = " select cpodes      ",
            " from iddkdominio   ",
            " where cponom = 'vclcorcod' ",
            " and cpocod = ? "
prepare p_cts66m00_003 from l_sql
declare c_cts66m00_003 cursor for p_cts66m00_003

let l_sql = " select atdetpcod     ",
            " from datmsrvacp      ",
            " where atdsrvnum = ?  ",
            "  and atdsrvano = ?   ",
            "  and atdsrvseq = (select max(atdsrvseq) ",
            "       from datmsrvacp      ",
            "       where atdsrvnum = ?  ",
            "       and atdsrvano = ? )  "
prepare p_cts66m00_004 from l_sql
declare c_cts66m00_004 cursor for p_cts66m00_004

let l_sql = " select atdsrvnum,atdsrvano "
           ," from datrligapol a ,datmligacao b "
           ," where "
           ," a.lignum = b.lignum "
           ," and a.succod    = ? "
           ," and a.aplnumdig = ? "
           ," and a.ramcod    = ? "
           ," and itmnumdig   = ? "
           ," and b.c24astcod = 'R06' "
prepare p_cts66m00_005 from l_sql
declare c_cts66m00_005 cursor for p_cts66m00_005           

let l_sql = " select grlinf ",
            " from datkgeral ",
            " where grlchv = 'PSOAGENDAWATIVA' "
prepare p_cts66m00_006 from l_sql
declare c_cts66m00_006 cursor for p_cts66m00_006
   
let m_cts66m00_sql = true

end function

#------------------------------------------------------------------------------#
function cts66m00()
#--------------------------------------------------------------------------

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

 define l_resultado    smallint,
        l_mensagem     char(80)

 define x        char (01)
 define l_acesso smallint 

 define l_grlinf   like igbkgeral.grlinf
       ,l_anomod   char(4)

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
          
 initialize  ws.*  to  null
 initialize l_resultado  to null
 initialize l_mensagem   to null
 
 let l_resultado  =  null
 let l_mensagem   =  null
 let x            =  null
 let l_grlinf     =  null
 let l_data       =  null
 let l_hora2      =  null
 let l_anomod     = null

 let g_documento.atdsrvorg = 2

 let lr_parametro.succod      = g_documento.succod
 let lr_parametro.ramcod      = g_documento.ramcod
 let lr_parametro.aplnumdig   = g_documento.aplnumdig
 let lr_parametro.itmnumdig   = g_documento.itmnumdig
 let lr_parametro.edsnumref   = g_documento.edsnumref
 let lr_parametro.prporg      = g_documento.prporg
 let lr_parametro.prpnumdig   = g_documento.prpnumdig
 let lr_parametro.ligcvntip   = g_documento.ligcvntip

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

 if m_cts66m00_sql is null or
    m_cts66m00_sql <> true then
    call cts66m00_prepare()
 end if

 # PSI-2013-00440PR
 let m_agendaw = false
 
 whenever error continue
 open c_cts66m00_006
 fetch c_cts66m00_006 into m_agendaw
 
 if sqlca.sqlcode != 0
    then
    let m_agendaw = false
 end if
 whenever error stop
 # PSI-2013-00440PR
 
 open window w_cts66m00 at 04,02 with form "cts66m00"
                      attribute(form line 1)

 display "ITAU RESIDENCIA" to msg_itau attribute(reverse)

 if g_documento.atdsrvnum is not null then

    whenever error continue
    open c_cts66m00_002 using g_documento.atdsrvnum,
                              g_documento.atdsrvano
    fetch c_cts66m00_002 into ws.asitipcod

    whenever error stop
    close c_cts66m00_002

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

 initialize mr_cts66m00.* to null
 initialize w_cts66m00.*  to null
 initialize ws.*          to null

 initialize a_cts66m00    to null
 initialize a_passag      to null

 let w_cts66m00.ligcvntip = g_documento.ligcvntip

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts66m00()

    display by name mr_cts66m00.servico
    display by name mr_cts66m00.doctxt
    display by name mr_cts66m00.nom
    display by name mr_cts66m00.corsus
    display by name mr_cts66m00.cornom
    display by name mr_cts66m00.asitipcod
    display by name mr_cts66m00.asimtvcod
    display by name mr_cts66m00.refatdsrvorg
    display by name mr_cts66m00.refatdsrvnum
    display by name mr_cts66m00.refatdsrvano
    display by name mr_cts66m00.bagflg
    display by name mr_cts66m00.imdsrvflg
    display by name mr_cts66m00.atdprinvlcod
    display by name mr_cts66m00.atdlibflg
    display by name mr_cts66m00.prslocflg
    display by name mr_cts66m00.frmflg
    display by name mr_cts66m00.asimtvdes
    display by name mr_cts66m00.asitipabvdes
    display by name mr_cts66m00.dstlcl
    display by name mr_cts66m00.dstlgdtxt
    display by name mr_cts66m00.dstbrrnom
    display by name mr_cts66m00.dstcidnom
    display by name mr_cts66m00.dstufdcod
    display by name mr_cts66m00.atdtxt

    display by name mr_cts66m00.c24solnom attribute (reverse)
    display by name a_cts66m00[1].lgdtxt,
                    a_cts66m00[1].lclbrrnom,
                    a_cts66m00[1].cidnom,
                    a_cts66m00[1].ufdcod,
                    a_cts66m00[1].lclrefptotxt,
                    a_cts66m00[1].endzon,
                    a_cts66m00[1].dddcod,
                    a_cts66m00[1].lcltelnum,
                    a_cts66m00[1].lclcttnom,
                    a_cts66m00[1].celteldddcod,
                    a_cts66m00[1].celtelnum,
                    a_cts66m00[1].endcmp



    if mr_cts66m00.atdlibflg = "N"   then
       display by name mr_cts66m00.atdlibdat attribute (invisible)
       display by name mr_cts66m00.atdlibhor attribute (invisible)
    end if

    if w_cts66m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
       let m_srv_acionado = true
    end if


    call cts66m00_modifica() returning ws.grvflg

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

       let mr_cts66m00.doctxt = "Apolice.: "
                            , g_documento.succod    using "<<<&&",
                         " ", g_documento.ramcod    using "&&&&",
                         " ", g_documento.aplnumdig using "<<<<<<<&&"



       call cty25g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
               returning m_limites_plano.pansoclmtqtd,
                         m_limites_plano.socqlmqtd,
                         m_limites_plano.erro,
                         m_limites_plano.mensagem




       let l_anomod = g_doc_itau[1].autmodano

        # Busca do nome do corretor
        call cty25g00_busca_nome_corretor()
             returning mr_cts66m00.cornom

       display g_doc_itau[1].segnom
       let mr_cts66m00.nom       = g_doc_itau[1].segnom clipped
       let mr_cts66m00.corsus    = g_doc_itau[1].corsus clipped

    end if

    

    let mr_cts66m00.prsloccab = "Prs.Local.:"
    let mr_cts66m00.prslocflg = "N"

    let mr_cts66m00.c24solnom   = g_documento.solnom

    display by name mr_cts66m00.doctxt
    display by name mr_cts66m00.nom
    display by name mr_cts66m00.corsus
    display by name mr_cts66m00.cornom
    display by name mr_cts66m00.asitipcod
    display by name mr_cts66m00.asimtvcod
    display by name mr_cts66m00.refatdsrvorg
    display by name mr_cts66m00.refatdsrvnum
    display by name mr_cts66m00.refatdsrvano
    display by name mr_cts66m00.bagflg
    display by name mr_cts66m00.imdsrvflg
    display by name mr_cts66m00.atdprinvlcod
    display by name mr_cts66m00.atdlibflg
    display by name mr_cts66m00.prslocflg
    display by name mr_cts66m00.frmflg

    display by name mr_cts66m00.c24solnom attribute (reverse)

    whenever error continue
    open c_cts66m00_001
    fetch c_cts66m00_001 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts66m00001: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts66m00() / C24 / RADIO-DEMAU ' sleep 2
          let int_flag = false
          clear form
          close window w_cts66m00
          return
       end if
    end if
    close c_cts66m00_001

   
   
      
                       
              
    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call cts66m00_inclui() returning ws.grvflg

    if ws.grvflg = true  then

       call cts10n00(w_cts66m00.atdsrvnum, w_cts66m00.atdsrvano,
                     g_issk.funmat       , aux_today, aux_hora )

       #-----------------------------------------------
       # Verifica Acionamento servico pelo atendente
       #-----------------------------------------------
       if mr_cts66m00.imdsrvflg =  "S"     and        # servico imediato
          mr_cts66m00.atdlibflg =  "S"     and        # servico liberado
          mr_cts66m00.prslocflg =  "N"     and        # prestador no local
          mr_cts66m00.frmflg    =  "N"     and        # formulario
          m_aciona = 'N'                  then       # servico nao acionado auto
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
          if l_acesso = true then
             call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                  returning ws.confirma

             if ws.confirma  =  "S"   then
                call cts00m02(w_cts66m00.atdsrvnum, w_cts66m00.atdsrvano, 1 )
             end if
          end if
       end if

       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       whenever error continue
       open c_cts66m00_004 using w_cts66m00.atdsrvnum,
                                 w_cts66m00.atdsrvano,
                                 w_cts66m00.atdsrvnum,
                                 w_cts66m00.atdsrvano
       fetch  c_cts66m00_004  into ws.atdetpcod
       whenever error stop
       close  c_cts66m00_004


       if ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------

          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts66m00.atdsrvnum
                             and atdsrvano = w_cts66m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico. AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts66m00.atdsrvnum,w_cts66m00.atdsrvano)
          end if
       end if
    end if
 end if
 clear form

 close window w_cts66m00


end function  ###  cts66m00

#-------------------------------------#
 function cts66m00_input()
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
               opcaodes         char(20)
           end record

 define hist_cts66m00 record
                            hist1 like datmservhist.c24srvdsc,
                            hist2 like datmservhist.c24srvdsc,
                            hist3 like datmservhist.c24srvdsc,
                            hist4 like datmservhist.c24srvdsc,
                            hist5 like datmservhist.c24srvdsc
                        end record

 define l_azlaplcod    like datkazlapl.azlaplcod,
        l_resultado    smallint,
        l_mensagem     char(80),
        l_confirma     char(01),
        l_vclcordes    char (11),
        l_data         date,
        l_hora2        datetime hour to minute,
        aux_today      char (10),
        aux_hora       char (05),
        aux_ano        char (02),
        m_srv_acionado smallint,
        arr_aux        smallint,
       # l_vclcoddig_contingencia like datmservico.vclcoddig,
        l_desc_1       char(40),
        l_desc_2       char(40),
        l_clscod       like aackcls.clscod,
        l_acesso       smallint,
        l_existe       smallint

 initialize m_cidnom
           ,m_ufdcod
           ,m_operacao
           ,m_imdsrvflg
 to null

 let     l_azlaplcod  =  null
 let     l_resultado  =  null
 let     l_mensagem  =  null
 let     l_confirma  =  null
 let     l_vclcordes  =  null
 let     l_data  =  null
 let     l_hora2  =  null
 let     aux_today  =  null
 let     aux_hora  =  null
 let     aux_ano  =  null
 let     m_srv_acionado  =  null
 #    let     l_vclcoddig_contingencia  =  null
 let     l_desc_1  =  null
 let     l_desc_2  =  null
 let     l_clscod  =  null
 
 initialize  lr_aux.*  to  null
 initialize  ws.*  to  null
 initialize  hist_cts66m00.*  to  null

 initialize aux_today,
            aux_hora,
            aux_ano,
            l_azlaplcod,
            l_resultado,
            l_mensagem,
            l_confirma,
            hist_cts66m00.*,
            lr_aux.*  to null

 # PSI-2013-00440PR
 if g_documento.acao = "INC"
    then
    let m_operacao = 0  # sempre regular na inclusao, imediato ou agendado
 else
    let m_operacao = 5  # na consulta considera liberado para nao regular novamente
    #display 'consulta, considerar cota ja regulada'
 end if
 
 # situacao original do servico
 let m_imdsrvflg = mr_cts66m00.imdsrvflg
 let m_cidnom = a_cts66m00[1].cidnom
 let m_ufdcod = a_cts66m00[1].ufdcod
 # PSI-2013-00440PR
 
 
 #display 'entrada do input, var null ou carregada na consulta'
 #display 'mr_cts66m00.imdsrvflg :', mr_cts66m00.imdsrvflg
 #display 'a_cts66m00[1].cidnom :', a_cts66m00[1].cidnom
 #display 'a_cts66m00[1].ufdcod :', a_cts66m00[1].ufdcod
 #display 'g_documento.acao     :', g_documento.acao
 #display 'm_operacao           :', m_operacao
 #display 'm_agncotdatant       :', m_agncotdatant
 #display 'm_agncothorant       :', m_agncothorant
 
 input by name mr_cts66m00.nom         ,
               mr_cts66m00.corsus      ,
               mr_cts66m00.cornom      ,
               mr_cts66m00.asitipcod   ,
               mr_cts66m00.asimtvcod   ,
               mr_cts66m00.refatdsrvorg,
               mr_cts66m00.refatdsrvnum,
               mr_cts66m00.refatdsrvano,
               mr_cts66m00.bagflg      ,
               mr_cts66m00.imdsrvflg   ,
               mr_cts66m00.atdprinvlcod,
               mr_cts66m00.atdlibflg   ,
               mr_cts66m00.prslocflg   ,
               mr_cts66m00.frmflg      without defaults

         before field nom
             display by name mr_cts66m00.nom        attribute (reverse)                                                                     
              
              if g_documento.acao <> 'CON' and
                 g_documento.acao <> 'ALT' then                                
                  call cts08g01("A","S",                             
                               "VERIFIQUE SE O SEGURADO EST� A MAIS",
                               "DE 300KM DE SUA RESIDENCIA !","","") 
                       returning ws.confirma         
              end if                          

         after field nom
             display by name mr_cts66m00.nom

             if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                     
                # INICIO PSI-2013-00440PR
                if m_agendaw = false   # regulacao antiga
                   then
                   call cts02m03("S"                  ,
                                 mr_cts66m00.imdsrvflg,
                                 w_cts66m00.atdhorpvt,
                                 w_cts66m00.atddatprg,
                                 w_cts66m00.atdhorprg,
                                 w_cts66m00.atdpvtretflg)
                       returning w_cts66m00.atdhorpvt,
                                 w_cts66m00.atddatprg,
                                 w_cts66m00.atdhorprg,
                                 w_cts66m00.atdpvtretflg
		          else
                   call cts02m08("S",
                                 mr_cts66m00.imdsrvflg,
                                 m_altcidufd,
                                 mr_cts66m00.prslocflg,
                                 w_cts66m00.atdhorpvt,
                                 w_cts66m00.atddatprg,
                                 w_cts66m00.atdhorprg,
                                 w_cts66m00.atdpvtretflg,
                                 m_rsrchvant,
                                 m_operacao,
                                 "",
                                 a_cts66m00[1].cidnom,
                                 a_cts66m00[1].ufdcod,
                                 "",   # codigo de assistencia, nao existe no Ct24h
                                 "",   # codigo do veiculo, somente Auto
                                 "",   # categoria tarifaria, somente Auto
                                 mr_cts66m00.imdsrvflg,
                                 a_cts66m00[1].c24lclpdrcod,
                                 a_cts66m00[1].lclltt,
                                 a_cts66m00[1].lcllgt,
                                 g_documento.ciaempcod,
                                 g_documento.atdsrvorg,
                                 mr_cts66m00.asitipcod,
                                 "",   # natureza nao tem, identifica pelo asitipcod  
                                 "")   # sub-natureza nao tem, identifica pelo asitipcod
                       returning w_cts66m00.atdhorpvt,
                                 w_cts66m00.atddatprg,
                                 w_cts66m00.atdhorprg,
                                 w_cts66m00.atdpvtretflg,
                                 mr_cts66m00.imdsrvflg,
                                 m_rsrchv,
                                 m_operacao,
                                 m_altdathor
                end if
                # FIM PSI-2013-00440PR
                
                next field nom
             end if
             
             if  mr_cts66m00.nom is null  then
                 error " Nome deve ser informado!"
                 next field nom
             end if

             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then

                  if mr_parametro.succod    is not null  and
                     mr_parametro.aplnumdig is not null  and
                     mr_parametro.itmnumdig is not null  and
                     w_cts66m00.atddmccidnom is null     and
                     w_cts66m00.atddmcufdcod is null     then

                     let w_cts66m00.atddmccidnom = g_doc_itau[1].segcidnom
                     let w_cts66m00.atddmcufdcod = g_doc_itau[1].segufdsgl
                   end if


                 # BUSCA AS LOCALIDADES PARA ASSISTENCIA AO PASSAGEIRO
                 call cts11m06(w_cts66m00.atddmccidnom,
                               w_cts66m00.atddmcufdcod,
                               w_cts66m00.atdocrcidnom,
                               w_cts66m00.atdocrufdcod,
                               w_cts66m00.atddstcidnom,
                               w_cts66m00.atddstufdcod)
                     returning w_cts66m00.atddmccidnom,
                               w_cts66m00.atddmcufdcod,
                               w_cts66m00.atdocrcidnom,
                               w_cts66m00.atdocrufdcod,
                               w_cts66m00.atddstcidnom,
                               w_cts66m00.atddstufdcod

                 if  w_cts66m00.atddmccidnom is null  or
                     w_cts66m00.atddmcufdcod is null  or
                     w_cts66m00.atdocrcidnom is null  or
                     w_cts66m00.atdocrufdcod is null  or
                     w_cts66m00.atddstcidnom is null  or
                     w_cts66m00.atddstufdcod is null  then
                     error " Localidades devem ser informadas para confirmacao",
                           " do direito de utilizacao!"
                     next field nom
                 end if

                 if  w_cts66m00.atddmccidnom = w_cts66m00.atdocrcidnom  and
                     w_cts66m00.atddmcufdcod = w_cts66m00.atdocrufdcod  then
                     call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                   "A LOCAL DE DOMICILIO!","") returning l_confirma
                     if  l_confirma = "N"  then
                         next field nom
                     end if
                 end if

                 let a_cts66m00[1].cidnom = w_cts66m00.atdocrcidnom
                 let a_cts66m00[1].ufdcod = w_cts66m00.atdocrufdcod

                 # DIFERENTE DE PASSAGEM AEREA
                 if  mr_cts66m00.asitipcod <> 10  then
                     let a_cts66m00[2].cidnom = w_cts66m00.atddstcidnom
                     let a_cts66m00[2].ufdcod = w_cts66m00.atddstufdcod
                 end if
             end if

             if  w_cts66m00.atdfnlflg = "S"  then
                 error " Servico ja' acionado nao pode ser alterado!"
                 let m_srv_acionado = true

                 # CASO O SERVI�O J� ESTEJA ACIONADO
                 call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                               "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma

                 # INICIO PSI-2013-00440PR
                 if m_agendaw = false   # regulacao antiga
                    then
                    call cts02m03(w_cts66m00.atdfnlflg,
                                  mr_cts66m00.imdsrvflg,
                                  w_cts66m00.atdhorpvt,
                                  w_cts66m00.atddatprg,
                                  w_cts66m00.atdhorprg,
                                  w_cts66m00.atdpvtretflg)
                        returning w_cts66m00.atdhorpvt,
                                  w_cts66m00.atddatprg,
                                  w_cts66m00.atdhorprg,
                                  w_cts66m00.atdpvtretflg
                 else
                    call cts02m08(w_cts66m00.atdfnlflg,
                                  mr_cts66m00.imdsrvflg,
                                  m_altcidufd,
                                  mr_cts66m00.prslocflg,
                                  w_cts66m00.atdhorpvt,
                                  w_cts66m00.atddatprg,
                                  w_cts66m00.atdhorprg,
                                  w_cts66m00.atdpvtretflg,
                                  m_rsrchvant,
                                  m_operacao,
                                  "",
                                  a_cts66m00[1].cidnom,
                                  a_cts66m00[1].ufdcod,
                                  "",   # codigo de assistencia, nao existe no Ct24h
                                  "",   # codigo do veiculo, somente Auto
                                  "",   # categoria tarifaria, somente Auto
                                  mr_cts66m00.imdsrvflg,
                                  a_cts66m00[1].c24lclpdrcod,
                                  a_cts66m00[1].lclltt,
                                  a_cts66m00[1].lcllgt,
                                  g_documento.ciaempcod,
                                  g_documento.atdsrvorg,
                                  mr_cts66m00.asitipcod,
                                  "",   # natureza nao tem, identifica pelo asitipcod  
                                  "")   # sub-natureza nao tem, identifica pelo asitipcod
                        returning w_cts66m00.atdhorpvt,
                                  w_cts66m00.atddatprg,
                                  w_cts66m00.atdhorprg,
                                  w_cts66m00.atdpvtretflg,
                                  mr_cts66m00.imdsrvflg,
                                  m_rsrchv,
                                  m_operacao,
                                  m_altdathor
                 end if
                 # FIM PSI-2013-00440PR
                 
                 next field frmflg
             end if

         before field corsus
             display by name mr_cts66m00.corsus     attribute (reverse)

         after field corsus
             display by name mr_cts66m00.corsus

             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 next field cornom
             else
                 next field nom
             end if

         before field cornom
             display by name mr_cts66m00.cornom     attribute (reverse)

         after field cornom
             display by name mr_cts66m00.cornom

             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  then
                 call cts40g03_data_hora_banco(2)
                      returning l_data,
                                l_hora2

                 # INFORMA��ES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04(g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               l_data,
                               g_documento.ramcod)
             else
                 # INFORMA��ES ADICIONAIS PARA ASSISTENCIA
                 call cts11m04(g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               w_cts66m00.atddat    ,
                               g_documento.ramcod)

                 next field asimtvcod
             end if

         before field asitipcod
             display by name mr_cts66m00.asitipcod attribute (reverse)

         after  field asitipcod
             display by name mr_cts66m00.asitipcod

             if  fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")  then
                 if  mr_cts66m00.asitipcod is null  then

                     #POPUP DE TIPOS DE ASSISTENCIA
                     call cts66m03(2)
                         returning mr_cts66m00.asitipcod

                     if  mr_cts66m00.asitipcod is not null  then

                         whenever error continue
                         select asitipabvdes
                           into mr_cts66m00.asitipabvdes
                           from datkasitip
                          where asitipcod = mr_cts66m00.asitipcod
                            and asitipstt = "A"
                         whenever error stop

                         display by name mr_cts66m00.asitipcod
                         display by name mr_cts66m00.asitipabvdes
                         next field asimtvcod
                     else
                         next field asitipcod
                     end if
                 else
                     whenever error continue
                     select asitipabvdes
                       into mr_cts66m00.asitipabvdes
                       from datkasitip
                      where asitipcod = mr_cts66m00.asitipcod
                        and asitipstt = "A"
                     whenever error stop

                     if  sqlca.sqlcode = notfound  then
                         error " Tipo de assistencia invalido!"

                         #POPUP DE TIPOS DE ASSISTENCIA
                         call cts66m03(2)
                             returning mr_cts66m00.asitipcod
                         next field asitipcod
                     else
                         display by name mr_cts66m00.asitipcod
                     end if

                     whenever error continue
                     select asitipcod
                       from datrasitipsrv
                      where atdsrvorg = g_documento.atdsrvorg
                        and asitipcod = mr_cts66m00.asitipcod
                     whenever error stop

                     if  sqlca.sqlcode = notfound  then
                         error " Tipo de assistencia nao pode ser enviada para",
                               " este servico!"
                         next field asitipcod
                     end if
                 end if
                 display by name mr_cts66m00.asitipabvdes
             end if

         before field asimtvcod
             if  fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 
             end if

             display by name mr_cts66m00.asimtvcod attribute (reverse)

         after  field asimtvcod
             display by name mr_cts66m00.asimtvcod
             
             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then


                if  mr_cts66m00.asimtvcod is null  then

                    # POPUP PARA EXIBIR TODOS OS MOTIVOS PARA A
                    # ASSISTENCIA INFORMADA ANTERIORMENTE
                    call cts66m02(mr_cts66m00.asitipcod)
                        returning mr_cts66m00.asimtvcod
                        
                     if mr_cts66m00.asimtvcod = 3  then   ##  RECUPERACAO DE VEICULO                         
                        call cts66m00_verifica_servico()                             
                             returning l_existe                                      
                                                                                     
                        if l_existe = false then                                     
                           call cts08g01("A","N","MOTIVO INVALIDO ! ",               
                                         "N�O FOI LOCALIZADO O SERVICO DE",          
                                         "REGRESSO ANTECIPADO","")                   
                                returning ws.confirma                                
                           next field asimtvcod                                      
                                                                                     
                        end if                                                       
                     end if
                                             
                    if  mr_cts66m00.asimtvcod is not null  then
                        select asimtvdes
                          into mr_cts66m00.asimtvdes
                          from datkasimtv
                         where asimtvcod = mr_cts66m00.asimtvcod
                           and asimtvsit = "A"
                        display by name mr_cts66m00.asimtvcod
                        display by name mr_cts66m00.asimtvdes                        

                           case mr_cts66m00.asitipcod
                             when 5   # taxi
                           
                                   let ws.msgcstvlr  = " LIMITADO A CAPACIDADE "
                                   let ws.msgcstvlr2 = " OFICIAL DO TAXI "
                             when 10  # passagem aerea                           
                                   let ws.msgcstvlr  = " LIMITADO A UMA PASSAGEM AEREA"
                                   let ws.msgcstvlr2 = "NA CLASSE ECONOMICA."                             
                           
                             when 16  # transporte rodoviario
                                  let ws.msgcstvlr  = " LIMITADO A UMA PASSAGEM RODOVIARIA"                                  
                           end case

                           if mr_cts66m00.asitipcod <> 5 or   --> Taxi
                              mr_cts66m00.asimtvcod <> 4 then --> Outros

                              if g_documento.aplnumdig is not null then
                                 if ws.msgcstvlr2 is null then
                                     call cts08g01("A","N","",
                                                   ws.msgcstvlr3,
                                                   ws.msgcstvlr,"")
                                         returning ws.confirma
                                 else
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
                        next field refatdsrvorg
                                                                                                                                                                                                                                                        
                else
                    select asimtvdes
                      into mr_cts66m00.asimtvdes
                      from datkasimtv
                     where asimtvcod = mr_cts66m00.asimtvcod
                       and asimtvsit = "A"
                    if  sqlca.sqlcode = notfound  then
                        error " Motivo invalido!"
                        # POPUP PARA EXIBIR TODOS OS MOTIVOS PARA A
                        # ASSISTENCIA INFORMADA ANTERIORMENTE
                        call cts66m02(mr_cts66m00.asitipcod)
                            returning mr_cts66m00.asimtvcod
                        next field asimtvcod
                    else
                     call cta00m06_verifica_mtvassistencia(mr_cts66m00.asimtvcod)
                         returning l_existe 
         
                        if l_existe = false then 
                           error "Motivo Invalido " 
                           next field asimtvcod 
                        else
                           display by name mr_cts66m00.asimtvcod
                        end if    
                    end if

                    select asimtvcod
                      from datrmtvasitip
                     where asitipcod = mr_cts66m00.asitipcod
                       and asimtvcod = mr_cts66m00.asimtvcod

                    if  sqlca.sqlcode = notfound  then
                        error " Motivo nao pode ser informado para este tipo",
                              " de assistencia!"
                        next field asimtvcod
                    end if 
                    
                    case mr_cts66m00.asitipcod                                                                                                   
                        when 5   # taxi                                                                                 
                                                                                                                        
                              let ws.msgcstvlr  = " LIMITADO A CAPACIDADE "                                             
                              let ws.msgcstvlr2 = " OFICIAL DO TAXI "                                                   
                        when 10  # passagem aerea                                                                       
                              let ws.msgcstvlr  = " LIMITADO A UMA PASSAGEM AEREA"                                      
                              let ws.msgcstvlr2 = "NA CLASSE ECONOMICA."                                                
                                                                                                                        
                        when 16  # transporte rodoviario                                                                
                             let ws.msgcstvlr  = " LIMITADO A UMA PASSAGEM RODOVIARIA"                                  
                    end case                                                                                          
                                                                                                                        
                    if mr_cts66m00.asitipcod <> 5 or   --> Taxi                                                       
                       mr_cts66m00.asimtvcod <> 4 then --> Outros                                                     
                                                                                                                        
                       if g_documento.aplnumdig is not null then                                                      
                          if ws.msgcstvlr2 is null then                                                               
                              call cts08g01("A","N","",                                                               
                                            ws.msgcstvlr3,                                                            
                                            ws.msgcstvlr,"")                                                          
                                  returning ws.confirma                                                               
                          else                                                                                        
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

                display by name mr_cts66m00.asimtvdes
                
             else
                 if  g_documento.atdsrvnum is not null  and
                     g_documento.atdsrvano is not null  then
                     next field asitipcod
                 end if
             end if             

        before field refatdsrvorg
             display by name mr_cts66m00.refatdsrvorg attribute (reverse)
                          
             if mr_cts66m00.asimtvcod = 3  then   ##  RECUPERACAO DE VEICULO                
                call cts66m00_verifica_servico()                            
                     returning l_existe                                     
                                                                            
                if l_existe = false then                                    
                   call cts08g01("A","N","MOTIVO INVALIDO ! ",              
                                 "N�O FOI LOCALIZADO O SERVICO DE",         
                                 "REGRESSO ANTECIPADO","")                  
                        returning ws.confirma 
                   next field asimtvcod      
                                                      
                end if                                                      
             end if                                                         

        after field refatdsrvorg
             display by name mr_cts66m00.refatdsrvorg

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field asimtvcod
             end if

             if  mr_cts66m00.refatdsrvorg is null  then
                 if  g_documento.succod    is not null  and
                     g_documento.aplnumdig is not null  then

                     call cts66m01(g_doc_itau[1].itaasiplncod
                                  ,g_doc_itau[1].itaaplvigincdat
                                  ,g_doc_itau[1].itaaplvigfnldat
                                  ,g_doc_itau[1].itaciacod
                                  ,g_doc_itau[1].itaramcod
                                  ,g_doc_itau[1].itaaplnum
                                  ,g_doc_itau[1].itaaplitmnum)
                         returning mr_cts66m00.refatdsrvorg,
                                   mr_cts66m00.refatdsrvnum,
                                   mr_cts66m00.refatdsrvano,
                                   l_acesso

                     if l_acesso = 1 then
                         next field refatdsrvorg
                     end if

                     if  mr_cts66m00.refatdsrvorg is null then
                         error "NAO EXISTEM SERVICOS ANTERIORES PARA ESSA APOLICE"
                     end if

                     display by name mr_cts66m00.refatdsrvorg
                     display by name mr_cts66m00.refatdsrvnum
                     display by name mr_cts66m00.refatdsrvano

                     if  mr_cts66m00.refatdsrvnum is null  and
                         mr_cts66m00.refatdsrvano is null  then

                         let a_cts66m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

                         #DIGITA��O PADRONIZADA DE ENDERE�OS
                         let m_acesso_ind = false

                         let m_atdsrvorg = 2

                         call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                              returning m_acesso_ind

                         if m_acesso_ind = false then

                            call cts06g03(1,
                                          m_atdsrvorg,
                                          w_cts66m00.ligcvntip,
                                          aux_today,
                                          aux_hora,
                                          a_cts66m00[1].lclidttxt,
                                          a_cts66m00[1].cidnom,
                                          a_cts66m00[1].ufdcod,
                                          a_cts66m00[1].brrnom,
                                          a_cts66m00[1].lclbrrnom,
                                          a_cts66m00[1].endzon,
                                          a_cts66m00[1].lgdtip,
                                          a_cts66m00[1].lgdnom,
                                          a_cts66m00[1].lgdnum,
                                          a_cts66m00[1].lgdcep,
                                          a_cts66m00[1].lgdcepcmp,
                                          a_cts66m00[1].lclltt,
                                          a_cts66m00[1].lcllgt,
                                          a_cts66m00[1].lclrefptotxt,
                                          a_cts66m00[1].lclcttnom,
                                          a_cts66m00[1].dddcod,
                                          a_cts66m00[1].lcltelnum,
                                          a_cts66m00[1].c24lclpdrcod,
                                          a_cts66m00[1].ofnnumdig,
                                          a_cts66m00[1].celteldddcod   ,
                                          a_cts66m00[1].celtelnum,
                                          a_cts66m00[1].endcmp,
                                          hist_cts66m00.*, a_cts66m00[1].emeviacod)
                                returning a_cts66m00[1].lclidttxt,
                                          a_cts66m00[1].cidnom,
                                          a_cts66m00[1].ufdcod,
                                          a_cts66m00[1].brrnom,
                                          a_cts66m00[1].lclbrrnom,
                                          a_cts66m00[1].endzon,
                                          a_cts66m00[1].lgdtip,
                                          a_cts66m00[1].lgdnom,
                                          a_cts66m00[1].lgdnum,
                                          a_cts66m00[1].lgdcep,
                                          a_cts66m00[1].lgdcepcmp,
                                          a_cts66m00[1].lclltt,
                                          a_cts66m00[1].lcllgt,
                                          a_cts66m00[1].lclrefptotxt,
                                          a_cts66m00[1].lclcttnom,
                                          a_cts66m00[1].dddcod,
                                          a_cts66m00[1].lcltelnum,
                                          a_cts66m00[1].c24lclpdrcod,
                                          a_cts66m00[1].ofnnumdig,
                                          a_cts66m00[1].celteldddcod   ,
                                          a_cts66m00[1].celtelnum,
                                          a_cts66m00[1].endcmp,
                                          ws.retflg,
                                          hist_cts66m00.*, a_cts66m00[1].emeviacod
                     else
                            call cts06g11(1,
                                          m_atdsrvorg,
                                          w_cts66m00.ligcvntip,
                                          aux_today,
                                          aux_hora,
                                          a_cts66m00[1].lclidttxt,
                                          a_cts66m00[1].cidnom,
                                          a_cts66m00[1].ufdcod,
                                          a_cts66m00[1].brrnom,
                                          a_cts66m00[1].lclbrrnom,
                                          a_cts66m00[1].endzon,
                                          a_cts66m00[1].lgdtip,
                                          a_cts66m00[1].lgdnom,
                                          a_cts66m00[1].lgdnum,
                                          a_cts66m00[1].lgdcep,
                                          a_cts66m00[1].lgdcepcmp,
                                          a_cts66m00[1].lclltt,
                                          a_cts66m00[1].lcllgt,
                                          a_cts66m00[1].lclrefptotxt,
                                          a_cts66m00[1].lclcttnom,
                                          a_cts66m00[1].dddcod,
                                          a_cts66m00[1].lcltelnum,
                                          a_cts66m00[1].c24lclpdrcod,
                                          a_cts66m00[1].ofnnumdig,
                                          a_cts66m00[1].celteldddcod   ,
                                          a_cts66m00[1].celtelnum,
                                          a_cts66m00[1].endcmp,
                                          hist_cts66m00.*, a_cts66m00[1].emeviacod)
                                returning a_cts66m00[1].lclidttxt,
                                          a_cts66m00[1].cidnom,
                                          a_cts66m00[1].ufdcod,
                                          a_cts66m00[1].brrnom,
                                          a_cts66m00[1].lclbrrnom,
                                          a_cts66m00[1].endzon,
                                          a_cts66m00[1].lgdtip,
                                          a_cts66m00[1].lgdnom,
                                          a_cts66m00[1].lgdnum,
                                          a_cts66m00[1].lgdcep,
                                          a_cts66m00[1].lgdcepcmp,
                                          a_cts66m00[1].lclltt,
                                          a_cts66m00[1].lcllgt,
                                          a_cts66m00[1].lclrefptotxt,
                                          a_cts66m00[1].lclcttnom,
                                          a_cts66m00[1].dddcod,
                                          a_cts66m00[1].lcltelnum,
                                          a_cts66m00[1].c24lclpdrcod,
                                          a_cts66m00[1].ofnnumdig,
                                          a_cts66m00[1].celteldddcod   ,
                                          a_cts66m00[1].celtelnum,
                                          a_cts66m00[1].endcmp,
                                          ws.retflg,
                                          hist_cts66m00.*, a_cts66m00[1].emeviacod
                         end if

                         #------------------------------------------------------
                         # Verifica Se o Endereco de Ocorrencia e o Mesmo de
                         # Residencia
                         #------------------------------------------------------

                         if g_documento.lclocodesres = "S" then
                            let w_cts66m00.atdrsdflg = "S"
                         else
                            let w_cts66m00.atdrsdflg = "N"
                         end if


                         # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                         let m_subbairro[1].lclbrrnom = a_cts66m00[1].lclbrrnom
                         call cts06g10_monta_brr_subbrr(a_cts66m00[1].brrnom,
                                                        a_cts66m00[1].lclbrrnom)
                              returning a_cts66m00[1].lclbrrnom

                         let a_cts66m00[1].lgdtxt = a_cts66m00[1].lgdtip clipped, " ",
                                                    a_cts66m00[1].lgdnom clipped, " ",
                                                    a_cts66m00[1].lgdnum using "<<<<#"

                         if a_cts66m00[1].cidnom is not null and
                            a_cts66m00[1].ufdcod is not null then
                            call cts14g00 ( g_documento.c24astcod,
                                            "","","","",
                                            a_cts66m00[1].cidnom,
                                            a_cts66m00[1].ufdcod,
                                            "S",
                                            ws.dtparam )
                         end if

                         display by name a_cts66m00[1].lgdtxt
                         display by name a_cts66m00[1].lclbrrnom
                         display by name a_cts66m00[1].endzon
                         display by name a_cts66m00[1].cidnom
                         display by name a_cts66m00[1].ufdcod
                         display by name a_cts66m00[1].lclrefptotxt
                         display by name a_cts66m00[1].lclcttnom
                         display by name a_cts66m00[1].dddcod
                         display by name a_cts66m00[1].lcltelnum
                         display by name a_cts66m00[1].celteldddcod
                         display by name a_cts66m00[1].celtelnum
                         display by name a_cts66m00[1].endcmp


                         let w_cts66m00.atdocrcidnom = a_cts66m00[1].cidnom
                         let w_cts66m00.atdocrufdcod = a_cts66m00[1].ufdcod

                         if  w_cts66m00.atddmccidnom = w_cts66m00.atdocrcidnom  and
                             w_cts66m00.atddmcufdcod = w_cts66m00.atdocrufdcod  then
                             call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                           "A LOCAL DE DOMICILIO!","")
                                  returning ws.confirma
                             #if  ws.confirma = "N"  then
                             #    next field refatdsrvorg
                             #end if
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
                     initialize mr_cts66m00.refatdsrvnum,
                                mr_cts66m00.refatdsrvano to null
                     display by name mr_cts66m00.refatdsrvnum,
                                     mr_cts66m00.refatdsrvano
                 end if
             end if

             #if  mr_cts66m00.refatdsrvorg <> 4   and   # REMOCAO
             #    mr_cts66m00.refatdsrvorg <> 6   and   # DAF
             #    mr_cts66m00.refatdsrvorg <> 1   and   # SOCORRO
             #    mr_cts66m00.refatdsrvorg <> 2   then  # TRANSPORTE
             #    error " Origem do servico de referencia deve",
             #          " ser um SOCORRO ou REMOCAO!"
             #    next field refatdsrvorg
             #end if

        before field refatdsrvnum
             display by name mr_cts66m00.refatdsrvnum attribute (reverse)

        after  field refatdsrvnum
             display by name mr_cts66m00.refatdsrvnum

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvorg
             end if

             if mr_cts66m00.refatdsrvorg is not null  and
                mr_cts66m00.refatdsrvnum is null      then
                error " Numero do servico de referencia nao informado!"
                next field refatdsrvnum
             end if

        before field refatdsrvano
             display by name mr_cts66m00.refatdsrvano attribute (reverse)

        after  field refatdsrvano
             display by name mr_cts66m00.refatdsrvano

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field refatdsrvnum
             end if

             if  mr_cts66m00.refatdsrvnum is not null  then
                 if  mr_cts66m00.refatdsrvano is not null  then
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
                          where atdsrvnum = mr_cts66m00.refatdsrvnum
                            and atdsrvano = mr_cts66m00.refatdsrvano
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
                 mr_cts66m00.refatdsrvorg is not null  and
                 mr_cts66m00.refatdsrvnum is not null  and
                 mr_cts66m00.refatdsrvano is not null  then

                 select atdsrvorg
                   into ws.refatdsrvorg
                   from DATMSERVICO
                  where atdsrvnum = mr_cts66m00.refatdsrvnum
                    and atdsrvano = mr_cts66m00.refatdsrvano

                 if  ws.refatdsrvorg <> mr_cts66m00.refatdsrvorg  then
                     error " Origem do numero de servico invalido.",
                           " A origem deve ser ", ws.refatdsrvorg using "&&"
                     next field refatdsrvorg
                 end if

                 call ctx04g00_local_gps( mr_cts66m00.refatdsrvnum,
                                          mr_cts66m00.refatdsrvano,
                                          1                       )
                                returning a_cts66m00[1].lclidttxt   ,
                                          a_cts66m00[1].lgdtip      ,
                                          a_cts66m00[1].lgdnom      ,
                                          a_cts66m00[1].lgdnum      ,
                                          a_cts66m00[1].lclbrrnom   ,
                                          a_cts66m00[1].brrnom      ,
                                          a_cts66m00[1].cidnom      ,
                                          a_cts66m00[1].ufdcod      ,
                                          a_cts66m00[1].lclrefptotxt,
                                          a_cts66m00[1].endzon      ,
                                          a_cts66m00[1].lgdcep      ,
                                          a_cts66m00[1].lgdcepcmp   ,
                                          a_cts66m00[1].lclltt      ,
                                          a_cts66m00[1].lcllgt      ,
                                          a_cts66m00[1].dddcod      ,
                                          a_cts66m00[1].lcltelnum   ,
                                          a_cts66m00[1].lclcttnom   ,
                                          a_cts66m00[1].c24lclpdrcod,
                                          a_cts66m00[1].celteldddcod,
                                          a_cts66m00[1].celtelnum   ,
                                          a_cts66m00[1].endcmp,
                                          ws.sqlcode, a_cts66m00[1].emeviacod
                 # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                 let m_subbairro[1].lclbrrnom = a_cts66m00[1].lclbrrnom
                 call cts06g10_monta_brr_subbrr(a_cts66m00[1].brrnom,
                                                a_cts66m00[1].lclbrrnom)
                      returning a_cts66m00[1].lclbrrnom

                 select ofnnumdig
                   into a_cts66m00[1].ofnnumdig
                   from datmlcl
                  where atdsrvano = g_documento.atdsrvano
                    and atdsrvnum = g_documento.atdsrvnum
                    and c24endtip = 1

                 if  ws.sqlcode <> 0  then
                     error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
                           " do local de ocorrencia. AVISE A INFORMATICA!"
                     next field refatdsrvorg
                 end if

                 let a_cts66m00[1].lgdtxt = a_cts66m00[1].lgdtip clipped, " ",
                                            a_cts66m00[1].lgdnom clipped, " ",
                                            a_cts66m00[1].lgdnum using "<<<<#"

                 display by name a_cts66m00[1].lgdtxt,
                                 a_cts66m00[1].lclbrrnom,
                                 a_cts66m00[1].cidnom,
                                 a_cts66m00[1].ufdcod,
                                 a_cts66m00[1].lclrefptotxt,
                                 a_cts66m00[1].endzon,
                                 a_cts66m00[1].dddcod,
                                 a_cts66m00[1].lcltelnum,
                                 a_cts66m00[1].lclcttnom,
                                 a_cts66m00[1].celteldddcod,
                                 a_cts66m00[1].celtelnum,
                                 a_cts66m00[1].endcmp
             end if
             let a_cts66m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             #DIGITA��O PADRONIZADA DE ENDERE�OS
             let m_acesso_ind = false
             let m_atdsrvorg = 2
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind

             if m_acesso_ind = false then

                call cts06g03(1,
                              m_atdsrvorg,
                              w_cts66m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts66m00[1].lclidttxt,
                              a_cts66m00[1].cidnom,
                              a_cts66m00[1].ufdcod,
                              a_cts66m00[1].brrnom,
                              a_cts66m00[1].lclbrrnom,
                              a_cts66m00[1].endzon,
                              a_cts66m00[1].lgdtip,
                              a_cts66m00[1].lgdnom,
                              a_cts66m00[1].lgdnum,
                              a_cts66m00[1].lgdcep,
                              a_cts66m00[1].lgdcepcmp,
                              a_cts66m00[1].lclltt,
                              a_cts66m00[1].lcllgt,
                              a_cts66m00[1].lclrefptotxt,
                              a_cts66m00[1].lclcttnom,
                              a_cts66m00[1].dddcod,
                              a_cts66m00[1].lcltelnum,
                              a_cts66m00[1].c24lclpdrcod,
                              a_cts66m00[1].ofnnumdig,
                              a_cts66m00[1].celteldddcod   ,
                              a_cts66m00[1].celtelnum,
                              a_cts66m00[1].endcmp,
                              hist_cts66m00.*, a_cts66m00[1].emeviacod)
                    returning a_cts66m00[1].lclidttxt,
                              a_cts66m00[1].cidnom,
                              a_cts66m00[1].ufdcod,
                              a_cts66m00[1].brrnom,
                              a_cts66m00[1].lclbrrnom,
                              a_cts66m00[1].endzon,
                              a_cts66m00[1].lgdtip,
                              a_cts66m00[1].lgdnom,
                              a_cts66m00[1].lgdnum,
                              a_cts66m00[1].lgdcep,
                              a_cts66m00[1].lgdcepcmp,
                              a_cts66m00[1].lclltt,
                              a_cts66m00[1].lcllgt,
                              a_cts66m00[1].lclrefptotxt,
                              a_cts66m00[1].lclcttnom,
                              a_cts66m00[1].dddcod,
                              a_cts66m00[1].lcltelnum,
                              a_cts66m00[1].c24lclpdrcod,
                              a_cts66m00[1].ofnnumdig,
                              a_cts66m00[1].celteldddcod   ,
                              a_cts66m00[1].celtelnum,
                              a_cts66m00[1].endcmp,
                              ws.retflg,
                              hist_cts66m00.*, a_cts66m00[1].emeviacod
             else
                call cts06g11(1,
                              m_atdsrvorg,
                              w_cts66m00.ligcvntip,
                              aux_today,
                              aux_hora,
                              a_cts66m00[1].lclidttxt,
                              a_cts66m00[1].cidnom,
                              a_cts66m00[1].ufdcod,
                              a_cts66m00[1].brrnom,
                              a_cts66m00[1].lclbrrnom,
                              a_cts66m00[1].endzon,
                              a_cts66m00[1].lgdtip,
                              a_cts66m00[1].lgdnom,
                              a_cts66m00[1].lgdnum,
                              a_cts66m00[1].lgdcep,
                              a_cts66m00[1].lgdcepcmp,
                              a_cts66m00[1].lclltt,
                              a_cts66m00[1].lcllgt,
                              a_cts66m00[1].lclrefptotxt,
                              a_cts66m00[1].lclcttnom,
                              a_cts66m00[1].dddcod,
                              a_cts66m00[1].lcltelnum,
                              a_cts66m00[1].c24lclpdrcod,
                              a_cts66m00[1].ofnnumdig,
                              a_cts66m00[1].celteldddcod   ,
                              a_cts66m00[1].celtelnum,
                              a_cts66m00[1].endcmp,
                              hist_cts66m00.*, a_cts66m00[1].emeviacod)
                    returning a_cts66m00[1].lclidttxt,
                              a_cts66m00[1].cidnom,
                              a_cts66m00[1].ufdcod,
                              a_cts66m00[1].brrnom,
                              a_cts66m00[1].lclbrrnom,
                              a_cts66m00[1].endzon,
                              a_cts66m00[1].lgdtip,
                              a_cts66m00[1].lgdnom,
                              a_cts66m00[1].lgdnum,
                              a_cts66m00[1].lgdcep,
                              a_cts66m00[1].lgdcepcmp,
                              a_cts66m00[1].lclltt,
                              a_cts66m00[1].lcllgt,
                              a_cts66m00[1].lclrefptotxt,
                              a_cts66m00[1].lclcttnom,
                              a_cts66m00[1].dddcod,
                              a_cts66m00[1].lcltelnum,
                              a_cts66m00[1].c24lclpdrcod,
                              a_cts66m00[1].ofnnumdig,
                              a_cts66m00[1].celteldddcod   ,
                              a_cts66m00[1].celtelnum,
                              a_cts66m00[1].endcmp,
                              ws.retflg,
                              hist_cts66m00.*, a_cts66m00[1].emeviacod
             end if

             #---------------------------------------------------------------
             # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
             #---------------------------------------------------------------

             if g_documento.lclocodesres = "S" then
                let w_cts66m00.atdrsdflg = "S"
             else
                let w_cts66m00.atdrsdflg = "N"
             end if



             # PSI 244589 - Inclus�o de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts66m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts66m00[1].brrnom,
                                            a_cts66m00[1].lclbrrnom)
                  returning a_cts66m00[1].lclbrrnom

             let a_cts66m00[1].lgdtxt = a_cts66m00[1].lgdtip clipped, " ",
                                        a_cts66m00[1].lgdnom clipped, " ",
                                        a_cts66m00[1].lgdnum using "<<<<#"

             if a_cts66m00[1].cidnom is not null and
                a_cts66m00[1].ufdcod is not null then
                call cts14g00 (g_documento.c24astcod,
                               "","","","",
                               a_cts66m00[1].cidnom,
                               a_cts66m00[1].ufdcod,
                               "S",
                               ws.dtparam)
             end if

             display by name a_cts66m00[1].lgdtxt
             display by name a_cts66m00[1].lclbrrnom
             display by name a_cts66m00[1].endzon
             display by name a_cts66m00[1].cidnom
             display by name a_cts66m00[1].ufdcod
             display by name a_cts66m00[1].lclrefptotxt
             display by name a_cts66m00[1].lclcttnom
             display by name a_cts66m00[1].dddcod
             display by name a_cts66m00[1].lcltelnum
             display by name a_cts66m00[1].celteldddcod
             display by name a_cts66m00[1].celtelnum
             display by name a_cts66m00[1].endcmp

             let w_cts66m00.atdocrcidnom = a_cts66m00[1].cidnom
             let w_cts66m00.atdocrufdcod = a_cts66m00[1].ufdcod

             if  w_cts66m00.atddmccidnom = w_cts66m00.atdocrcidnom  and
                 w_cts66m00.atddmcufdcod = w_cts66m00.atdocrufdcod  then
                 call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                               "A LOCAL DE DOMICILIO!","") returning ws.confirma
                 if  ws.confirma = "N"  then
                     next field refatdsrvorg
                 end if
             end if

             if  ws.retflg = "N"  then
                 error " Dados referentes ao local incorretos ou nao preenchidos!"
                 next field refatdsrvorg
             end if

        before field bagflg
             if  g_documento.atdsrvnum is null  and
                 g_documento.atdsrvano is null  and
                 mr_cts66m00.asitipcod  <> 5     then
                 let mr_cts66m00.bagflg = "N"
             end if

             display by name mr_cts66m00.bagflg    attribute (reverse)

        after field bagflg
             display by name mr_cts66m00.bagflg

             if  fgl_lastkey() <> fgl_keyval("up")    and
                 fgl_lastkey() <> fgl_keyval("left")  then
                 if  mr_cts66m00.bagflg is null  then
                     error " Bagagem deve ser informada!"
                     next field bagflg
                 else
                     if  mr_cts66m00.bagflg <> "S"  and
                         mr_cts66m00.bagflg <> "N"  then
                         error " Informe (S)im ou (N)ao!"
                         next field bagflg
                     end if
                 end if

                 if  mr_cts66m00.bagflg = "S"  then
                     call cts08g01("Q","N","QUAL A QUANTIDADE E VOLUME",
                                   "DE BAGAGEM ?","",
                                   "REGISTRE INFORMACAO NO HISTORICO")
                          returning ws.confirma
                 end if
                 if  mr_cts66m00.asitipcod = 10  then  ###  Passagem Aerea
                     display by name mr_cts66m00.dstcidnom
                     display by name mr_cts66m00.dstufdcod
                 else
                    let a_cts66m00[3].* = a_cts66m00[2].*

                    let a_cts66m00[2].lclbrrnom = m_subbairro[2].lclbrrnom
                    #DIGITA��O PADRONIZADA DE ENDERE�OS
                    let m_acesso_ind = false
                    let m_atdsrvorg = 2
                    call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                         returning m_acesso_ind

                    if m_acesso_ind = false then

                       call cts06g03(2,
                                     m_atdsrvorg,
                                     w_cts66m00.ligcvntip,
                                     aux_today,
                                     aux_hora,
                                     a_cts66m00[2].lclidttxt,
                                     a_cts66m00[2].cidnom,
                                     a_cts66m00[2].ufdcod,
                                     a_cts66m00[2].brrnom,
                                     a_cts66m00[2].lclbrrnom,
                                     a_cts66m00[2].endzon,
                                     a_cts66m00[2].lgdtip,
                                     a_cts66m00[2].lgdnom,
                                     a_cts66m00[2].lgdnum,
                                     a_cts66m00[2].lgdcep,
                                     a_cts66m00[2].lgdcepcmp,
                                     a_cts66m00[2].lclltt,
                                     a_cts66m00[2].lcllgt,
                                     a_cts66m00[2].lclrefptotxt,
                                     a_cts66m00[2].lclcttnom,
                                     a_cts66m00[2].dddcod,
                                     a_cts66m00[2].lcltelnum,
                                     a_cts66m00[2].c24lclpdrcod,
                                     a_cts66m00[2].ofnnumdig,
                                     a_cts66m00[2].celteldddcod   ,
                                     a_cts66m00[2].celtelnum,
                                     a_cts66m00[2].endcmp,
                                     hist_cts66m00.*, a_cts66m00[2].emeviacod)
                           returning a_cts66m00[2].lclidttxt,
                                     a_cts66m00[2].cidnom,
                                     a_cts66m00[2].ufdcod,
                                     a_cts66m00[2].brrnom,
                                     a_cts66m00[2].lclbrrnom,
                                     a_cts66m00[2].endzon,
                                     a_cts66m00[2].lgdtip,
                                     a_cts66m00[2].lgdnom,
                                     a_cts66m00[2].lgdnum,
                                     a_cts66m00[2].lgdcep,
                                     a_cts66m00[2].lgdcepcmp,
                                     a_cts66m00[2].lclltt,
                                     a_cts66m00[2].lcllgt,
                                     a_cts66m00[2].lclrefptotxt,
                                     a_cts66m00[2].lclcttnom,
                                     a_cts66m00[2].dddcod,
                                     a_cts66m00[2].lcltelnum,
                                     a_cts66m00[2].c24lclpdrcod,
                                     a_cts66m00[2].ofnnumdig,
                                     a_cts66m00[2].celteldddcod   ,
                                     a_cts66m00[2].celtelnum,
                                     a_cts66m00[2].endcmp,
                                     ws.retflg,
                                     hist_cts66m00.*, a_cts66m00[2].emeviacod
                    else
                       call cts06g11(2,
                                     m_atdsrvorg,
                                     w_cts66m00.ligcvntip,
                                     aux_today,
                                     aux_hora,
                                     a_cts66m00[2].lclidttxt,
                                     a_cts66m00[2].cidnom,
                                     a_cts66m00[2].ufdcod,
                                     a_cts66m00[2].brrnom,
                                     a_cts66m00[2].lclbrrnom,
                                     a_cts66m00[2].endzon,
                                     a_cts66m00[2].lgdtip,
                                     a_cts66m00[2].lgdnom,
                                     a_cts66m00[2].lgdnum,
                                     a_cts66m00[2].lgdcep,
                                     a_cts66m00[2].lgdcepcmp,
                                     a_cts66m00[2].lclltt,
                                     a_cts66m00[2].lcllgt,
                                     a_cts66m00[2].lclrefptotxt,
                                     a_cts66m00[2].lclcttnom,
                                     a_cts66m00[2].dddcod,
                                     a_cts66m00[2].lcltelnum,
                                     a_cts66m00[2].c24lclpdrcod,
                                     a_cts66m00[2].ofnnumdig,
                                     a_cts66m00[2].celteldddcod   ,
                                     a_cts66m00[2].celtelnum,
                                     a_cts66m00[2].endcmp,
                                     hist_cts66m00.*, a_cts66m00[2].emeviacod)
                           returning a_cts66m00[2].lclidttxt,
                                     a_cts66m00[2].cidnom,
                                     a_cts66m00[2].ufdcod,
                                     a_cts66m00[2].brrnom,
                                     a_cts66m00[2].lclbrrnom,
                                     a_cts66m00[2].endzon,
                                     a_cts66m00[2].lgdtip,
                                     a_cts66m00[2].lgdnom,
                                     a_cts66m00[2].lgdnum,
                                     a_cts66m00[2].lgdcep,
                                     a_cts66m00[2].lgdcepcmp,
                                     a_cts66m00[2].lclltt,
                                     a_cts66m00[2].lcllgt,
                                     a_cts66m00[2].lclrefptotxt,
                                     a_cts66m00[2].lclcttnom,
                                     a_cts66m00[2].dddcod,
                                     a_cts66m00[2].lcltelnum,
                                     a_cts66m00[2].c24lclpdrcod,
                                     a_cts66m00[2].ofnnumdig,
                                     a_cts66m00[2].celteldddcod   ,
                                     a_cts66m00[2].celtelnum,
                                     a_cts66m00[2].endcmp,
                                     ws.retflg,
                                     hist_cts66m00.*, a_cts66m00[2].emeviacod
                    end if

                    # PSI 244589 - Inclus�o de Sub-Bairro - Burini
                    let m_subbairro[2].lclbrrnom = a_cts66m00[2].lclbrrnom
                    call cts06g10_monta_brr_subbrr(a_cts66m00[2].brrnom,
                                                   a_cts66m00[2].lclbrrnom)
                         returning a_cts66m00[2].lclbrrnom

                    let a_cts66m00[2].lgdtxt = a_cts66m00[2].lgdtip clipped, " ",
                                               a_cts66m00[2].lgdnom clipped, " ",
                                               a_cts66m00[2].lgdnum using "<<<<#"

                    let mr_cts66m00.dstlcl    = a_cts66m00[2].lclidttxt
                    let mr_cts66m00.dstlgdtxt = a_cts66m00[2].lgdtxt
                    let mr_cts66m00.dstbrrnom = a_cts66m00[2].lclbrrnom
                    let mr_cts66m00.dstcidnom = a_cts66m00[2].cidnom
                    let mr_cts66m00.dstufdcod = a_cts66m00[2].ufdcod

                    if  a_cts66m00[2].lclltt <> a_cts66m00[3].lclltt or
                        a_cts66m00[2].lcllgt <> a_cts66m00[3].lcllgt or
                        (a_cts66m00[3].lclltt is null and a_cts66m00[2].lclltt is not null) or
                        (a_cts66m00[3].lcllgt is null and a_cts66m00[2].lcllgt is not null) then

                        #CALCULA A DISTANCIA ENTRE A ORIGEM E O DESTINO
                        #call cts00m33_calckm("",
                        #                     a_cts66m00[1].lclltt,
                        #                     a_cts66m00[1].lcllgt,
                        #                     a_cts66m00[2].lclltt,
                        #                     a_cts66m00[2].lcllgt,
                        #                     m_limites_plano.socqlmqtd)

                    end if

                    if a_cts66m00[2].cidnom is not null and
                       a_cts66m00[2].ufdcod is not null then
                       call cts14g00 (g_documento.c24astcod,
                                      "","","","",
                                      a_cts66m00[2].cidnom,
                                      a_cts66m00[2].ufdcod,
                                      "S",
                                      ws.dtparam)
                    end if

                    display by name mr_cts66m00.dstlcl   ,
                                    mr_cts66m00.dstlgdtxt,
                                    mr_cts66m00.dstbrrnom,
                                    mr_cts66m00.dstcidnom,
                                    mr_cts66m00.dstufdcod

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
          
                 if  mr_cts66m00.asitipcod <> 5  then

                     let mr_cts66m00.imdsrvflg    = "S"
                     let w_cts66m00.atdpvtretflg = "S"
                     let w_cts66m00.atdhorpvt    = "00:00"
                     let mr_cts66m00.atdprinvlcod = 2

                     select cpodes
                       into mr_cts66m00.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts66m00.atdprinvlcod

                     initialize w_cts66m00.atddatprg to null
                     initialize w_cts66m00.atdhorprg to null

                     display by name mr_cts66m00.imdsrvflg
                     display by name mr_cts66m00.atdprinvlcod
                     display by name mr_cts66m00.atdprinvldes

                     if  fgl_lastkey() = fgl_keyval("up")    or
                         fgl_lastkey() = fgl_keyval("left")  then
                         next field bagflg
                     else
                         next field atdlibflg
                     end if
                 else
                     display by name mr_cts66m00.imdsrvflg  attribute (reverse)
                 end if

          after  field imdsrvflg
                 display by name mr_cts66m00.imdsrvflg

                 # PSI-2013-00440PR
                 if (m_imdsrvflg is null) or (m_imdsrvflg != mr_cts66m00.imdsrvflg)
                    then
                    let m_rsrchv = null
                    let m_operacao = 0  # regular novamente, cota agendada e imediata sempre distintas
                 end if
                 
                 if (m_cidnom != a_cts66m00[1].cidnom) or
                    (m_ufdcod != a_cts66m00[1].ufdcod) then
                    let m_altcidufd = true
                    let m_operacao = 0  # regular novamente
                    #display 'cts66m00 - Elegivel para regulacao, alterou cidade/uf'
                 else
                    let m_altcidufd = false
                 end if
                 
                 # na inclusao dados nulos, igualar aos digitados
                 if m_imdsrvflg is null then
                    let m_imdsrvflg = mr_cts66m00.imdsrvflg
                 end if
                 
                 if m_cidnom is null then
                    let m_cidnom = a_cts66m00[1].cidnom
                 end if
                 
                 if m_ufdcod is null then
                    let m_ufdcod = a_cts66m00[1].ufdcod
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
                     if  mr_cts66m00.imdsrvflg is null   then
                         error " Servico imediato e' item obrigatorio!"
                         next field imdsrvflg
                     else
                         if  mr_cts66m00.imdsrvflg <> "S"  and
                             mr_cts66m00.imdsrvflg <> "N"  then
                             error " Informe (S)im ou (N)ao!"
                             next field imdsrvflg
                         end if
                     end if

                     # PREVISAO PARA TERMINO DO SERVI�O
                    
                     # Considerado que todas as regras de negocio sobre a questao da regulacao
                     # sao tratadas do lado do AW, mantendo no laudo somente a chamada ao servico
                     if m_agendaw = true
                        then
                        # obter a chave de regulacao no AW
                        call cts02m08(w_cts66m00.atdfnlflg,
                                      mr_cts66m00.imdsrvflg,
                                      m_altcidufd,
                                      mr_cts66m00.prslocflg,
                                      w_cts66m00.atdhorpvt,
                                      w_cts66m00.atddatprg,
                                      w_cts66m00.atdhorprg,
                                      w_cts66m00.atdpvtretflg,
                                      m_rsrchv,
                                      m_operacao,
                                      "",
                                      a_cts66m00[1].cidnom,
                                      a_cts66m00[1].ufdcod,
                                      "",   # codigo de assistencia, nao existe no Ct24h
                                      "",   # codigo do veiculo, somente Auto
                                      "",   # categoria tarifaria, somente Auto
                                      mr_cts66m00.imdsrvflg,
                                      a_cts66m00[1].c24lclpdrcod,
                                      a_cts66m00[1].lclltt,
                                      a_cts66m00[1].lcllgt,
                                      g_documento.ciaempcod,
                                      g_documento.atdsrvorg,
                                      mr_cts66m00.asitipcod,
                                      "",   # natureza nao tem, identifica pelo asitipcod  
                                      "")   # sub-natureza nao tem, identifica pelo asitipcod
                            returning w_cts66m00.atdhorpvt,
                                      w_cts66m00.atddatprg,
                                      w_cts66m00.atdhorprg,
                                      w_cts66m00.atdpvtretflg,
                                      mr_cts66m00.imdsrvflg,
                                      m_rsrchv,
                                      m_operacao,
                                      m_altdathor
		     
                        display by name mr_cts66m00.imdsrvflg
                 
                        if int_flag
                           then
                           let int_flag = false
                           next field imdsrvflg
                        end if
                        
                     else  # regula��o antiga
                     
                        call cts02m03(w_cts66m00.atdfnlflg,
                                      mr_cts66m00.imdsrvflg,
                                      w_cts66m00.atdhorpvt,
                                      w_cts66m00.atddatprg,
                                      w_cts66m00.atdhorprg,
                                      w_cts66m00.atdpvtretflg)
                            returning w_cts66m00.atdhorpvt,
                                      w_cts66m00.atddatprg,
                                      w_cts66m00.atdhorprg,
                                      w_cts66m00.atdpvtretflg
              
                        
                        if  mr_cts66m00.imdsrvflg = "S"  then
                            if  w_cts66m00.atdhorpvt is null  then
                                error " Previsao (em horas) nao informada para servico",
                                      " imediato!"
                                next field imdsrvflg
                            end if
                        else
                            if  w_cts66m00.atddatprg   is null        or
                                w_cts66m00.atdhorprg   is null        then
                                error " Faltam dados para servico programado!"
                                next field imdsrvflg
                            else
                                let mr_cts66m00.atdprinvlcod  = 2
   
                                select cpodes
                                  into mr_cts66m00.atdprinvldes
                                  from iddkdominio
                                 where cponom = "atdprinvlcod"
                                   and cpocod = mr_cts66m00.atdprinvlcod
   
                                 display by name mr_cts66m00.atdprinvlcod
                                 display by name mr_cts66m00.atdprinvldes
   
                                 next field atdlibflg
                            end if
                        end if
                     end if
                 end if

          before field atdprinvlcod
                 let mr_cts66m00.atdprinvlcod = 2
                 display by name mr_cts66m00.atdprinvlcod attribute (reverse)


          after  field atdprinvlcod
                 display by name mr_cts66m00.atdprinvlcod

                 if  fgl_lastkey() <> fgl_keyval("up")   and
                     fgl_lastkey() <> fgl_keyval("left") then
                     if mr_cts66m00.atdprinvlcod is null then
                        error " Nivel de prioridade deve ser informado!"
                        next field atdprinvlcod
                     end if

                     select cpodes
                       into mr_cts66m00.atdprinvldes
                       from iddkdominio
                      where cponom = "atdprinvlcod"
                        and cpocod = mr_cts66m00.atdprinvlcod

                     if  sqlca.sqlcode = notfound then
                         error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal",
                               " ou (3)-Urgente"
                         next field atdprinvlcod
                     end if

                     display by name mr_cts66m00.atdprinvldes
                 end if

          before field atdlibflg
                 display by name mr_cts66m00.atdlibflg attribute (reverse)

                 if  g_documento.atdsrvnum is not null  and
                     w_cts66m00.atdfnlflg  =  "S"       then
                     exit input
                 end if

          after  field atdlibflg
                 display by name mr_cts66m00.atdlibflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field atdprinvlcod
                 end if

                 if  mr_cts66m00.atdlibflg is null then
                     error " Envio liberado deve ser informado!"
                     next field atdlibflg
                 end if

                 if  mr_cts66m00.atdlibflg <> "S"  and
                     mr_cts66m00.atdlibflg <> "N"  then
                     error " Informe (S)im ou (N)ao!"
                     next field atdlibflg
                 end if

                 let w_cts66m00.atdlibflg = mr_cts66m00.atdlibflg

                 if  w_cts66m00.atdlibflg is null   then
                     next field atdlibflg
                 end if

                 display by name mr_cts66m00.atdlibflg

                 if  mr_cts66m00.asitipcod = 10  then
                     call cts11m08(w_cts66m00.trppfrdat,
                                   w_cts66m00.trppfrhor)
                         returning w_cts66m00.trppfrdat,
                                   w_cts66m00.trppfrhor

                     if  w_cts66m00.trppfrdat is null  then
                         call cts08g01("C","S","","NAO FOI PREENCHIDO NENHUMA",
                                       "PREFERENCIA DE VIAGEM!","")
                              returning ws.confirma
                         if  ws.confirma = "N"  then
                             next field atdlibflg
                         end if
                     end if
                 end if

                 if  w_cts66m00.antlibflg is null  then
                     if  w_cts66m00.atdlibflg = "S"  then
                         call cts40g03_data_hora_banco(2)
                             returning l_data, l_hora2
                         let mr_cts66m00.atdlibhor = l_hora2
                         let mr_cts66m00.atdlibdat = l_data
                     else
                         let mr_cts66m00.atdlibflg = "N"
                         display by name mr_cts66m00.atdlibflg
                         initialize mr_cts66m00.atdlibhor to null
                         initialize mr_cts66m00.atdlibdat to null
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

                     if  w_cts66m00.antlibflg = "S"  then
                         if  w_cts66m00.atdlibflg = "S"  then
                             exit input
                         else
                             error " A liberacao do servico nao pode ser cancelada!"
                             next field atdlibflg
                             let mr_cts66m00.atdlibflg = "N"
                             display by name mr_cts66m00.atdlibflg
                             initialize mr_cts66m00.atdlibhor to null
                             initialize mr_cts66m00.atdlibdat to null
                             error " Liberacao do servico cancelada!"
                             sleep 1
                             exit input
                         end if
                     else
                         if  w_cts66m00.antlibflg = "N"  then
                             if  w_cts66m00.atdlibflg = "N"  then
                                 exit input
                             else
                                 call cts40g03_data_hora_banco(2)
                                      returning l_data, l_hora2
                                 let mr_cts66m00.atdlibhor = l_hora2
                                 let mr_cts66m00.atdlibdat = l_data
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
                         let mr_cts66m00.prslocflg = "N"
                         next field frmflg
                     end if
                 end if

                 if  mr_cts66m00.asitipcod = 10  then   ###  Passagem Aerea
                     if  fgl_lastkey() = fgl_keyval("up")   or
                         fgl_lastkey() = fgl_keyval("left") then
                         next field atdlibflg
                     else
                         initialize mr_cts66m00.prslocflg  to null
                         next field frmflg
                     end if
                 end if

                 if  mr_cts66m00.imdsrvflg   = "N" then
                     initialize w_cts66m00.c24nomctt  to null
                     let mr_cts66m00.prslocflg = "N"
                     display by name mr_cts66m00.prslocflg
                     next field frmflg
                 end if

                 display by name mr_cts66m00.prslocflg attribute (reverse)

          after  field prslocflg
                 display by name mr_cts66m00.prslocflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field atdlibflg
                 end if

                 if  ((mr_cts66m00.prslocflg  is null)  or
                      (mr_cts66m00.prslocflg  <> "S"    and
                     mr_cts66m00.prslocflg    <> "N"))  then
                     error " Prestador no local: (S)im ou (N)ao!"
                     next field prslocflg
                 end if

                 if  mr_cts66m00.prslocflg = "S"   then
                     call ctn24c01()
                          returning w_cts66m00.atdprscod, w_cts66m00.srrcoddig,
                                    w_cts66m00.atdvclsgl, w_cts66m00.socvclcod

                     if  w_cts66m00.atdprscod  is null then
                         error " Faltam dados para prestador no local!"
                         next field prslocflg
                     end if

                     let mr_cts66m00.atdlibhor = aux_hora
                     let mr_cts66m00.atdlibdat = aux_today
                     let w_cts66m00.atdfnlflg = "S"
                     let w_cts66m00.atdetpcod =  4

                     call cts40g03_data_hora_banco(2)
                         returning l_data, l_hora2

                     let w_cts66m00.cnldat    = l_data
                     let w_cts66m00.atdfnlhor = l_hora2
                     let w_cts66m00.c24opemat = g_issk.funmat

                     let mr_cts66m00.frmflg    = "N"
                     display by name mr_cts66m00.frmflg
                     exit input
                 else
                     initialize w_cts66m00.funmat   ,
                                w_cts66m00.cnldat   ,
                                w_cts66m00.atdfnlhor,
                                w_cts66m00.c24opemat,
                                w_cts66m00.atdfnlflg,
                                w_cts66m00.atdetpcod,
                                w_cts66m00.atdprscod,
                                w_cts66m00.atdcstvlr,
                                w_cts66m00.c24nomctt  to null
                 end if


          before field frmflg
                 if  w_cts66m00.operacao = "i"  then
                     let mr_cts66m00.frmflg = "N"
                     display by name mr_cts66m00.frmflg attribute (reverse)
                 end if

          after  field frmflg
                 display by name mr_cts66m00.frmflg

                 if  fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field prslocflg
                 end if

                 if  mr_cts66m00.frmflg = "S"  then
                     if  mr_cts66m00.atdlibflg = "N"  then
                         error " Nao e' possivel registrar servico nao liberado",
                               " via formulario!"
                         next field atdlibflg
                     end if

                     call cts02m05(2) returning w_cts66m00.data,
                                                w_cts66m00.hora,
                                                w_cts66m00.funmat,
                                                w_cts66m00.cnldat,
                                                w_cts66m00.atdfnlhor,
                                                w_cts66m00.c24opemat,
                                                w_cts66m00.atdprscod

                     if  w_cts66m00.hora      is null or
                         w_cts66m00.data      is null or
                         w_cts66m00.funmat    is null or
                         w_cts66m00.cnldat    is null or
                         w_cts66m00.atdfnlhor is null or
                         w_cts66m00.c24opemat is null or
                         w_cts66m00.atdprscod is null  then
                         error " Faltam dados para entrada via formulario!"
                         next field frmflg
                     end if

                     let mr_cts66m00.atdlibhor = w_cts66m00.hora
                     let mr_cts66m00.atdlibdat = w_cts66m00.data
                     let w_cts66m00.atdfnlflg = "S"
                     let w_cts66m00.atdetpcod =  4
                 else
                     if  mr_cts66m00.prslocflg  = "N" then
                         initialize w_cts66m00.hora     ,
                                    w_cts66m00.data     ,
                                    w_cts66m00.funmat   ,
                                    w_cts66m00.cnldat   ,
                                    w_cts66m00.atdfnlhor,
                                    w_cts66m00.c24opemat,
                                    w_cts66m00.atdfnlflg,
                                    w_cts66m00.atdetpcod,
                                    w_cts66m00.atdcstvlr,
                                    w_cts66m00.atdprscod to null
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

                 if  mr_cts66m00.asimtvcod = 3  then
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
                 call cts10m02 (hist_cts66m00.*) returning hist_cts66m00.*
             else
                 call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                               g_issk.funmat, w_cts66m00.data, w_cts66m00.hora)
             end if

          on key (F7)
             call ctx14g00("Funcoes","Impressao|Distancia|Tipo Pagamento")
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
                     call cts00m33(1,
                                   a_cts66m00[1].lclltt,
                                   a_cts66m00[1].lcllgt,
                                   a_cts66m00[2].lclltt,
                                   a_cts66m00[2].lcllgt)
                                   
                 when 3 
                 
                 if g_documento.atdsrvnum is not null then                  
                   if g_documento.c24astcod = "R07" then
                      call ctb83m00()                                     
                           returning m_retctb83m00                         
                     else                                                    
                     error "Esse assunto nao possui tipo de pagamento"    
                   end if                                                  
                 else 
                    error "Tipo de pagamento somente com servico aberto"             
                 end if                                                                                        
             end case

          on key (F8)
             if  mr_cts66m00.asitipcod = 10 then
                 call cts11m08(w_cts66m00.trppfrdat,
                               w_cts66m00.trppfrhor)
                     returning w_cts66m00.trppfrdat,
                               w_cts66m00.trppfrhor
             end if

          on key (F9)
             if  g_documento.atdsrvnum is null  or
                 g_documento.atdsrvano is null  then
                 error " Servico nao cadastrado!"
             else
                 if mr_cts66m00.atdlibflg = "N"   then
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

     return hist_cts66m00.*

 end function

#------------------------------------#
 function ccts66m00_carrega_servico()
#------------------------------------#

    select ciaempcod   ,
           nom         ,
#           vclcoddig   ,
#           vcldes      ,
#           vclanomdl   ,
#           vcllicnum   ,
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
           mr_cts66m00.nom        ,
#           mr_cts66m00.vclcoddig  ,
#           mr_cts66m00.vcldes     ,
#           mr_cts66m00.vclanomdl  ,
#           mr_cts66m00.vcllicnum  ,
           mr_cts66m00.corsus     ,
           mr_cts66m00.cornom     ,
           w_cts66m00.vclcorcod  ,
           w_cts66m00.atddat      ,
           w_cts66m00.atdhor      ,
           mr_cts66m00.atdlibflg  ,
           mr_cts66m00.atdlibhor  ,
           mr_cts66m00.atdlibdat  ,
           w_cts66m00.atdhorpvt   ,
           w_cts66m00.atdpvtretflg,
           w_cts66m00.atddatprg   ,
           w_cts66m00.atdhorprg   ,
           w_cts66m00.atdfnlflg   ,
           mr_cts66m00.asitipcod  ,
           w_cts66m00.atdcstvlr   ,
           mr_cts66m00.atdprinvlcod
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
 function cts66m00_modifica()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    sqlcode          integer
 end record

 define hist_cts66m00 record
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
 initialize  hist_cts66m00.*  to  null
        let     prompt_key  =  null

        initialize  ws.*  to  null

        initialize  hist_cts66m00.*  to  null

 initialize ws.*  to null

 call cts66m00_input() returning hist_cts66m00.*

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts66m00      to null
    initialize a_passag        to null
    initialize mr_cts66m00.*    to null
    initialize w_cts66m00.*    to null
    initialize hist_cts66m00.* to null
    clear form
    return false
 end if

 #display 'cts66m00 - Modificar atendimento'
 
 whenever error continue

 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
#                          vclcoddig     ,
#                          vcldes        ,
#                          vclanomdl     ,
#                          vcllicnum     ,
#                          vclcorcod     ,
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
                      = ( mr_cts66m00.nom,
                          mr_cts66m00.corsus,
                          mr_cts66m00.cornom,
#                          mr_cts66m00.vclcoddig,
#                          mr_cts66m00.vcldes,
#                          mr_cts66m00.vclanomdl,
#                          mr_cts66m00.vcllicnum,
#                          w_cts66m00.vclcorcod,
                          mr_cts66m00.atdlibflg,
                          mr_cts66m00.atdlibdat,
                          mr_cts66m00.atdlibhor,
                          w_cts66m00.atdhorpvt,
                          w_cts66m00.atddatprg,
                          w_cts66m00.atdhorprg,
                          w_cts66m00.atdpvtretflg,
                          mr_cts66m00.asitipcod,
                          mr_cts66m00.atdprinvlcod,
                          mr_cts66m00.prslocflg)
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
                           = ( mr_cts66m00.bagflg      ,
                               mr_cts66m00.refatdsrvnum,
                               mr_cts66m00.refatdsrvano,
                               mr_cts66m00.asimtvcod   ,
                               w_cts66m00.atddmccidnom,
                               w_cts66m00.atddmcufdcod,
                               w_cts66m00.atddstcidnom,
                               w_cts66m00.atddstufdcod,
                               w_cts66m00.trppfrdat,
                               w_cts66m00.trppfrhor)
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
    if a_cts66m00[arr_aux].operacao is null  then
       let a_cts66m00[arr_aux].operacao = "M"
    end if

    if mr_cts66m00.asitipcod = 10  and  arr_aux = 2   then
       exit for
    end if
    let a_cts66m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
    call cts06g07_local(a_cts66m00[arr_aux].operacao,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        arr_aux,
                        a_cts66m00[arr_aux].lclidttxt,
                        a_cts66m00[arr_aux].lgdtip,
                        a_cts66m00[arr_aux].lgdnom,
                        a_cts66m00[arr_aux].lgdnum,
                        a_cts66m00[arr_aux].lclbrrnom,
                        a_cts66m00[arr_aux].brrnom,
                        a_cts66m00[arr_aux].cidnom,
                        a_cts66m00[arr_aux].ufdcod,
                        a_cts66m00[arr_aux].lclrefptotxt,
                        a_cts66m00[arr_aux].endzon,
                        a_cts66m00[arr_aux].lgdcep,
                        a_cts66m00[arr_aux].lgdcepcmp,
                        a_cts66m00[arr_aux].lclltt,
                        a_cts66m00[arr_aux].lcllgt,
                        a_cts66m00[arr_aux].dddcod,
                        a_cts66m00[arr_aux].lcltelnum,
                        a_cts66m00[arr_aux].lclcttnom,
                        a_cts66m00[arr_aux].c24lclpdrcod,
                        a_cts66m00[arr_aux].ofnnumdig,
                        a_cts66m00[arr_aux].emeviacod,
                        a_cts66m00[arr_aux].celteldddcod,
                        a_cts66m00[arr_aux].celtelnum,
                        a_cts66m00[arr_aux].endcmp)
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

 if w_cts66m00.antlibflg <> mr_cts66m00.atdlibflg  then
    if mr_cts66m00.atdlibflg = "S"  then
       let w_cts66m00.atdetpcod = 1
       let ws.atdetpdat = mr_cts66m00.atdlibdat
       let ws.atdetphor = mr_cts66m00.atdlibhor
    else
       let w_cts66m00.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts66m00.atdetpcod,
                               w_cts66m00.atdprscod,
                               " " ,
                               " ",
                               w_cts66m00.srrcoddig) returning w_retorno

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
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts66m00[1].cidnom,
                          a_cts66m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         mr_cts66m00.asitipcod,
                                         a_cts66m00[1].lclltt,
                                         a_cts66m00[1].lcllgt,
                                         mr_cts66m00.prslocflg,
                                         mr_cts66m00.frmflg,
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
                          a_cts66m00[1].cidnom, "/",
                          a_cts66m00[1].ufdcod sleep 4
  end if

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

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

end function # modifica

#-------------------------------------------------------------------------------
 function cts66m00_inclui()
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

 define hist_cts66m00   record
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
 initialize  hist_cts66m00.*  to  null
 initialize  ws.*  to  null
 initialize  hist_cts66m00.*  to  null
	
 #display 'cts66m00 - Incluir atendimento'
 
 while true
   initialize ws.*  to null

   let g_documento.acao    = "INC"
   let w_cts66m00.operacao = "i"

   call cts66m00_input() returning hist_cts66m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts66m00      to null
       initialize a_passag        to null
       initialize mr_parametro.*    to null
       initialize w_cts66m00.*    to null
       initialize hist_cts66m00.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   if  w_cts66m00.data is null  then
       let w_cts66m00.data   = aux_today
       let w_cts66m00.hora   = aux_hora
       let w_cts66m00.funmat = g_issk.funmat
   end if

   if  mr_cts66m00.frmflg = "S"  then
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


   if  w_cts66m00.atdfnlflg is null  then
       let w_cts66m00.atdfnlflg = "N"
       let w_cts66m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
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
   let w_cts66m00.atdsrvnum = ws.atdsrvnum
   let w_cts66m00.atdsrvano = ws.atdsrvano


 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           w_cts66m00.data         ,
                           w_cts66m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           w_cts66m00.funmat       ,
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


   call cts10g02_grava_servico( w_cts66m00.atdsrvnum,
                                w_cts66m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24soltip
                                w_cts66m00.vclcorcod,
                                w_cts66m00.funmat   ,
                                mr_cts66m00.atdlibflg,
                                mr_cts66m00.atdlibhor,
                                mr_cts66m00.atdlibdat,
                                w_cts66m00.data     ,     # atddat
                                w_cts66m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts66m00.atdhorpvt,
                                w_cts66m00.atddatprg,
                                w_cts66m00.atdhorprg,
                                "P"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts66m00.atdprscod,
                                w_cts66m00.atdcstvlr,
                                w_cts66m00.atdfnlflg,
                                w_cts66m00.atdfnlhor,
                                w_cts66m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts66m00.c24opemat,
                                mr_cts66m00.nom      ,
                                "",
                                "",
                                "",
                                mr_cts66m00.corsus   ,
                                mr_cts66m00.cornom   ,
                                w_cts66m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts66m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                mr_cts66m00.asitipcod,
                                ""                  ,     # socvclcod
                                ""                  ,     # vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                mr_cts66m00.atdprinvlcod,
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
   if mr_cts66m00.prslocflg = "S" then
      update datmservico set prslocflg = mr_cts66m00.prslocflg,
                             socvclcod = w_cts66m00.socvclcod,
                             srrcoddig = w_cts66m00.srrcoddig
       where datmservico.atdsrvnum = w_cts66m00.atdsrvnum
         and datmservico.atdsrvano = w_cts66m00.atdsrvano
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
                         values ( w_cts66m00.atdsrvnum   ,
                                  w_cts66m00.atdsrvano   ,
                                  mr_cts66m00.bagflg      ,
                                  mr_cts66m00.refatdsrvnum,
                                  mr_cts66m00.refatdsrvano,
                                  mr_cts66m00.asimtvcod   ,
                                  w_cts66m00.atddmccidnom,
                                  w_cts66m00.atddmcufdcod,
                                  w_cts66m00.atddstcidnom,
                                  w_cts66m00.atddstufdcod,
                                  w_cts66m00.trppfrdat   ,
                                  w_cts66m00.trppfrhor    )

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
              where atdsrvnum = w_cts66m00.atdsrvnum
                and atdsrvano = w_cts66m00.atdsrvano

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
                           values( w_cts66m00.atdsrvnum    ,
                                   w_cts66m00.atdsrvano    ,
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
       if  a_cts66m00[arr_aux].operacao is null  then
           let a_cts66m00[arr_aux].operacao = "I"
       end if

       if  mr_cts66m00.asitipcod = 10  and  arr_aux = 2   then
           exit for
       end if
       let a_cts66m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

       call cts06g07_local( a_cts66m00[arr_aux].operacao    ,
                            w_cts66m00.atdsrvnum            ,
                            w_cts66m00.atdsrvano            ,
                            arr_aux                         ,
                            a_cts66m00[arr_aux].lclidttxt   ,
                            a_cts66m00[arr_aux].lgdtip      ,
                            a_cts66m00[arr_aux].lgdnom      ,
                            a_cts66m00[arr_aux].lgdnum      ,
                            a_cts66m00[arr_aux].lclbrrnom   ,
                            a_cts66m00[arr_aux].brrnom      ,
                            a_cts66m00[arr_aux].cidnom      ,
                            a_cts66m00[arr_aux].ufdcod      ,
                            a_cts66m00[arr_aux].lclrefptotxt,
                            a_cts66m00[arr_aux].endzon      ,
                            a_cts66m00[arr_aux].lgdcep      ,
                            a_cts66m00[arr_aux].lgdcepcmp   ,
                            a_cts66m00[arr_aux].lclltt      ,
                            a_cts66m00[arr_aux].lcllgt      ,
                            a_cts66m00[arr_aux].dddcod      ,
                            a_cts66m00[arr_aux].lcltelnum   ,
                            a_cts66m00[arr_aux].lclcttnom   ,
                            a_cts66m00[arr_aux].c24lclpdrcod,
                            a_cts66m00[arr_aux].ofnnumdig,
                            a_cts66m00[arr_aux].emeviacod,
                            a_cts66m00[arr_aux].celteldddcod,
                            a_cts66m00[arr_aux].celtelnum,
                            a_cts66m00[arr_aux].endcmp)
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

   if  w_cts66m00.atdetpcod is null  then
       if  mr_cts66m00.atdlibflg = "S"  then
           let w_cts66m00.atdetpcod = 1
           let ws.etpfunmat = w_cts66m00.funmat
           let ws.atdetpdat = mr_cts66m00.atdlibdat
           let ws.atdetphor = mr_cts66m00.atdlibhor
       else
           let w_cts66m00.atdetpcod = 2
           let ws.etpfunmat = w_cts66m00.funmat
           let ws.atdetpdat = w_cts66m00.data
           let ws.atdetphor = w_cts66m00.hora
       end if
   else
      call cts10g04_insere_etapa(w_cts66m00.atdsrvnum,
                                 w_cts66m00.atdsrvano,
                                 1,
                                 w_cts66m00.atdprscod,
                                 " ",
                                 " ",
                                 w_cts66m00.srrcoddig )returning w_retorno

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptX
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts66m00.cnldat
       let ws.atdetphor = w_cts66m00.atdfnlhor
       let ws.etpfunmat = w_cts66m00.c24opemat
   end if


   call cts10g04_insere_etapa(w_cts66m00.atdsrvnum,
                              w_cts66m00.atdsrvano,
                              w_cts66m00.atdetpcod,
                              w_cts66m00.atdprscod,
                              " ",
                              " ",
                              w_cts66m00.srrcoddig )returning w_retorno

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


      call cts10g02_grava_servico_apolice(w_cts66m00.atdsrvnum ,
                                          w_cts66m00.atdsrvano ,
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
            values (w_cts66m00.atdsrvnum ,
                    w_cts66m00.atdsrvano ,
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

         call cts10g02_grava_servico_apolice(w_cts66m00.atdsrvnum         ,
                                             w_cts66m00.atdsrvano         ,
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
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts66m00.atdsrvnum,
                               w_cts66m00.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts66m00.atdsrvnum,
                            w_cts66m00.atdsrvano,
                            w_cts66m00.data     ,
                            w_cts66m00.hora     ,
                            w_cts66m00.funmat   ,
                            hist_cts66m00.*      )
        returning ws.histerr



  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  let m_aciona = 'N'
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts66m00[1].cidnom,
                          a_cts66m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         mr_cts66m00.asitipcod,
                                         a_cts66m00[1].lclltt,
                                         a_cts66m00[1].lcllgt,
                                         mr_cts66m00.prslocflg,
                                         mr_cts66m00.frmflg,
                                         w_cts66m00.atdsrvnum,
                                         w_cts66m00.atdsrvano,
                                         " ",
                                         "",
                                         "") then
     else
        let m_aciona = 'S'
     end if
  else
     error "Problemas com parametros de acionamento: ",
                          g_documento.atdsrvorg, "/",
                          a_cts66m00[1].cidnom, "/",
                          a_cts66m00[1].ufdcod sleep 4
  end if

  #------------------------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt PSI207233
 #------------------------------------------------------------------------------
    if g_documento.c24astcod = "R07"  then       

         let g_cc.anosrv = w_cts66m00.atdsrvano
         let g_cc.nrosrv = w_cts66m00.atdsrvnum


         insert into dbscadtippgt (anosrv,
                                   nrosrv,
                                   pgttipcodps,
                                   pgtmat,
                                   corsus,
                                   cadmat,
                                   cademp,
                                   caddat,
                                   atlmat,
                                   atlemp,
                                   atldat,
                                   cctcod,
                                   succod,
                                   empcod,
                                   pgtempcod)

                 values           (g_cc.anosrv,
                                   g_cc.nrosrv,
                                   g_cc.pgttipcodps,
                                   g_cc.pgtmat,
                                   g_cc.corsus,
                                   g_cc.cadmat,
                                   g_cc.cademp,
                                   g_cc.caddat,
                                   g_cc.atlmat,
                                   g_cc.atlemp,
                                   g_cc.atldat,
                                   g_cc.cctcod,
                                   g_cc.succod,
                                   g_cc.cademp,
                                   g_cc.pgtempcod)

    end if
 
    # PSI-2013-00440PR - Regulacao na inclusao, confirmar se chave de regulacao 
    #                    ainda ativa e fazer a baixa da chave no AW
    let l_txtsrv = "SRV ", w_cts66m00.atdsrvnum, "-", w_cts66m00.atdsrvano 
    
    if m_agendaw = true 
       then
       if m_operacao = 1  # obteve chave de regulacao 
          then
          call ctd41g00_checar_reserva(m_rsrchv) returning l_reserva_ativa
       
          if l_reserva_ativa = true 
             then
             #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW'
             call ctd41g00_baixar_agenda(m_rsrchv, w_cts66m00.atdsrvano, w_cts66m00.atdsrvnum)
                  returning l_errcod, l_errmsg
          else
             #display "Chave de regulacao inativa, selecione agenda novamente"
             error "Chave de regulacao inativa, selecione agenda novamente"
             
             let m_operacao = 0 
             
             # obter a chave de regulacao no AW
             call cts02m08(w_cts66m00.atdfnlflg,
                           mr_cts66m00.imdsrvflg,
                           m_altcidufd,
                           mr_cts66m00.prslocflg,
                           w_cts66m00.atdhorpvt,
                           w_cts66m00.atddatprg,
                           w_cts66m00.atdhorprg,
                           w_cts66m00.atdpvtretflg,
                           m_rsrchv,
                           m_operacao,
                           "",
                           a_cts66m00[1].cidnom,
                           a_cts66m00[1].ufdcod,
                           "",   # codigo de assistencia, nao existe no Ct24h
                           "",   # codigo do veiculo, somente Auto
                           "",   # categoria tarifaria, somente Auto
                           mr_cts66m00.imdsrvflg,
                           a_cts66m00[1].c24lclpdrcod,
                           a_cts66m00[1].lclltt,
                           a_cts66m00[1].lcllgt,
                           g_documento.ciaempcod,
                           g_documento.atdsrvorg,
                           mr_cts66m00.asitipcod,
                           "",   # natureza nao tem, identifica pelo asitipcod  
                           "")   # sub-natureza nao tem, identifica pelo asitipcod
                 returning w_cts66m00.atdhorpvt,
                           w_cts66m00.atddatprg,
                           w_cts66m00.atdhorprg,
                           w_cts66m00.atdpvtretflg,
                           mr_cts66m00.imdsrvflg,
                           m_rsrchv,
                           m_operacao,
                           m_altdathor
                           
             display by name mr_cts66m00.imdsrvflg
             
             if m_operacao = 1
                then
                #display l_txtsrv clipped, ' inclusao ok, chave ok, baixando no AW - apos nova chave'
                call ctd41g00_baixar_agenda(m_rsrchv, w_cts66m00.atdsrvano, w_cts66m00.atdsrvnum)
                     returning l_errcod, l_errmsg
             end if
          end if
          
          if l_errcod = 0
             then
             call cts02m08_ins_cota(m_rsrchv, w_cts66m00.atdsrvnum, w_cts66m00.atdsrvano)
                  returning l_errcod, l_errmsg
                  
             #if l_errcod = 0
             #   then
             #   display 'cts02m08_ins_cota gravou com sucesso'
             #else
             #   display 'cts02m08_ins_cota erro ', l_errcod
             #   display l_errmsg clipped
             #end if
          else
             #display 'cts66m00 nao gravou cota no IFX, baixa de cota nao realizada na inclusao: ', l_errcod
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
          
          call ctd41g00_liberar_agenda(w_cts66m00.atdsrvano, w_cts66m00.atdsrvnum
                                     , m_agncotdat, m_agncothor)
       end if
    end if
    # PSI-2013-00440PR
    
    #------------------------------------------------------------------------------
    # Exibe o numero do servico
    #------------------------------------------------------------------------------
    let mr_cts66m00.servico = g_documento.atdsrvorg using "&&",
                             "/", w_cts66m00.atdsrvnum using "&&&&&&&",
                             "-", w_cts66m00.atdsrvano using "&&"
    display by name mr_cts66m00.servico attribute (reverse)
 
    error  " Verifique o numero do servico e tecle ENTER!"
    prompt "" for char ws.promptX
 
    error " Inclusao efetuada com sucesso!"
    let ws.retorno = true
 
    exit while
 end while

 return ws.retorno

end function  # inclui

#---------------------------------------------------------------
 function consulta_cts66m00()
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

 initialize ws.*  to null
 initialize l_errcod, l_errmsg to null

 select nom         ,
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
   into mr_cts66m00.nom      ,
        mr_cts66m00.corsus   ,
        mr_cts66m00.cornom   ,
        w_cts66m00.vclcorcod,
        ws.funmat           ,
        ws.empcod           ,
        w_cts66m00.atddat   ,
        w_cts66m00.atdhor   ,
        mr_cts66m00.atdlibflg,
        mr_cts66m00.atdlibhor,
        mr_cts66m00.atdlibdat,
        w_cts66m00.atdhorpvt,
        w_cts66m00.atdpvtretflg,
        w_cts66m00.atddatprg,
        w_cts66m00.atdhorprg,
        w_cts66m00.atdfnlflg,
        mr_cts66m00.asitipcod,
        w_cts66m00.atdcstvlr,
        mr_cts66m00.atdprinvlcod,
        g_documento.ciaempcod,
        mr_cts66m00.prslocflg
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
               returning a_cts66m00[1].lclidttxt   ,
                         a_cts66m00[1].lgdtip      ,
                         a_cts66m00[1].lgdnom      ,
                         a_cts66m00[1].lgdnum      ,
                         a_cts66m00[1].lclbrrnom   ,
                         a_cts66m00[1].brrnom      ,
                         a_cts66m00[1].cidnom      ,
                         a_cts66m00[1].ufdcod      ,
                         a_cts66m00[1].lclrefptotxt,
                         a_cts66m00[1].endzon      ,
                         a_cts66m00[1].lgdcep      ,
                         a_cts66m00[1].lgdcepcmp   ,
                         a_cts66m00[1].lclltt      ,
                         a_cts66m00[1].lcllgt      ,
                         a_cts66m00[1].dddcod      ,
                         a_cts66m00[1].lcltelnum   ,
                         a_cts66m00[1].lclcttnom   ,
                         a_cts66m00[1].c24lclpdrcod,
                         a_cts66m00[1].celteldddcod,
                         a_cts66m00[1].celtelnum   ,
                         a_cts66m00[1].endcmp,
                         ws.sqlcode,a_cts66m00[1].emeviacod
  # PSI 244589 - Inclus�o de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts66m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts66m00[1].brrnom,
                                a_cts66m00[1].lclbrrnom)
      returning a_cts66m00[1].lclbrrnom

 select ofnnumdig into a_cts66m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if


 let a_cts66m00[1].lgdtxt = a_cts66m00[1].lgdtip clipped, " ",
                            a_cts66m00[1].lgdnom clipped, " ",
                            a_cts66m00[1].lgdnum using "<<<<#"

#--------------------------------------------------------------------
# Informacoes do local de destino
#--------------------------------------------------------------------
 if mr_cts66m00.asitipcod <> 10  then  ###  Passagem Aerea
    call ctx04g00_local_gps(g_documento.atdsrvnum,
                            g_documento.atdsrvano,
                            2)
                  returning a_cts66m00[2].lclidttxt   ,
                            a_cts66m00[2].lgdtip      ,
                            a_cts66m00[2].lgdnom      ,
                            a_cts66m00[2].lgdnum      ,
                            a_cts66m00[2].lclbrrnom   ,
                            a_cts66m00[2].brrnom      ,
                            a_cts66m00[2].cidnom      ,
                            a_cts66m00[2].ufdcod      ,
                            a_cts66m00[2].lclrefptotxt,
                            a_cts66m00[2].endzon      ,
                            a_cts66m00[2].lgdcep      ,
                            a_cts66m00[2].lgdcepcmp   ,
                            a_cts66m00[2].lclltt      ,
                            a_cts66m00[2].lcllgt      ,
                            a_cts66m00[2].dddcod      ,
                            a_cts66m00[2].lcltelnum   ,
                            a_cts66m00[2].lclcttnom   ,
                            a_cts66m00[2].c24lclpdrcod,
                            a_cts66m00[2].celteldddcod,
                            a_cts66m00[2].celtelnum   ,
                            a_cts66m00[2].endcmp,
                            ws.sqlcode, a_cts66m00[2].emeviacod
    # PSI 244589 - Inclus�o de Sub-Bairro - Burini
    let m_subbairro[2].lclbrrnom = a_cts66m00[2].lclbrrnom
    call cts06g10_monta_brr_subbrr(a_cts66m00[2].brrnom,
                                   a_cts66m00[2].lclbrrnom)
         returning a_cts66m00[2].lclbrrnom
    select ofnnumdig into a_cts66m00[2].ofnnumdig
      from datmlcl
     where atdsrvano = g_documento.atdsrvano
       and atdsrvnum = g_documento.atdsrvnum
       and c24endtip = 2

    if ws.sqlcode = 0  then
       let a_cts66m00[2].lgdtxt = a_cts66m00[2].lgdtip clipped, " ",
                                  a_cts66m00[2].lgdnom clipped, " ",
                                  a_cts66m00[2].lgdnum using "<<<<#"

       let mr_cts66m00.dstlcl    = a_cts66m00[2].lclidttxt
       let mr_cts66m00.dstlgdtxt = a_cts66m00[2].lgdtxt
       let mr_cts66m00.dstbrrnom = a_cts66m00[2].lclbrrnom
       let mr_cts66m00.dstcidnom = a_cts66m00[2].cidnom
       let mr_cts66m00.dstufdcod = a_cts66m00[2].ufdcod
    else
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de destino. AVISE A INFORMATICA!"
       return
    end if
 end if

 let mr_cts66m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts66m00.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts66m00.asitipcod

#---------------------------------------------------------------
# Obtencao dos dados da assistencia a passageiros
#---------------------------------------------------------------

 select refatdsrvnum, refatdsrvano,
        bagflg      , asimtvcod   ,
        atddmccidnom, atddmcufdcod,
        atddstcidnom, atddstufdcod,
        trppfrdat   , trppfrhor   ,
        atdsrvorg
   into mr_cts66m00.refatdsrvnum   ,
        mr_cts66m00.refatdsrvano   ,
        mr_cts66m00.bagflg         ,
        mr_cts66m00.asimtvcod      ,
        w_cts66m00.atddmccidnom   ,
        w_cts66m00.atddmcufdcod   ,
        w_cts66m00.atddstcidnom   ,
        w_cts66m00.atddstufdcod   ,
        w_cts66m00.trppfrdat      ,
        w_cts66m00.trppfrhor      ,
        mr_cts66m00.refatdsrvorg
   from datmassistpassag, outer datmservico
  where datmassistpassag.atdsrvnum = g_documento.atdsrvnum  and
        datmassistpassag.atdsrvano = g_documento.atdsrvano  and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum  and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if mr_cts66m00.asitipcod = 10  then  ###  Passagem Aerea
    let mr_cts66m00.dstcidnom = w_cts66m00.atddstcidnom
    let mr_cts66m00.dstufdcod = w_cts66m00.atddstufdcod
 end if

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------

 let mr_cts66m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts66m00.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts66m00.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare ccts66m00002 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach ccts66m00002 into a_passag[arr_aux].pasnom,
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

 let w_cts66m00.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

 call cts20g01_docto(w_cts66m00.lignum)
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
    let mr_cts66m00.doctxt = "Apolice.: "
                         , g_documento.succod    using "<<<&&",
                      " ", g_documento.ramcod    using "&&&&",
                      " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts66m00.ligcvntip,
        mr_cts66m00.c24solnom, g_documento.c24astcod
   from datmligacao
  where lignum = w_cts66m00.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts66m00.lignum

 if sqlca.sqlcode = notfound  then
    let mr_cts66m00.frmflg = "N"
 else
    let mr_cts66m00.frmflg = "S"
 end if

 select cpodes into mr_cts66m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts66m00.ligcvntip

 let mr_cts66m00.servico = g_documento.atdsrvorg using "&&",
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

 let mr_cts66m00.atdtxt = w_cts66m00.atddat         clipped, " ",
                         w_cts66m00.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

 if w_cts66m00.atdhorpvt is not null  or
    w_cts66m00.atdhorpvt =  "00:00"   then
    let mr_cts66m00.imdsrvflg = "S"
 end if

 if w_cts66m00.atddatprg is not null   then
    let mr_cts66m00.imdsrvflg = "N"
 end if

 if mr_cts66m00.atdlibflg = "N"  then
    let mr_cts66m00.atdlibdat = w_cts66m00.atddat
    let mr_cts66m00.atdlibhor = w_cts66m00.atdhor
 end if

 let w_cts66m00.antlibflg = mr_cts66m00.atdlibflg

 let mr_cts66m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 select cpodes
   into mr_cts66m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = mr_cts66m00.atdprinvlcod

# let mr_cts66m00.vcldes = cts15g00(mr_cts66m00.vclcoddig)

 let mr_cts66m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into mr_cts66m00.asimtvdes
   from datkasimtv
  where asimtvcod = mr_cts66m00.asimtvcod

 let mr_cts66m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into mr_cts66m00.asitipabvdes
   from datkasitip
  where asitipcod = mr_cts66m00.asitipcod

 let m_c24lclpdrcod = a_cts66m00[1].c24lclpdrcod

end function
#-----------------------------------------#
function cts66m00_verifica_servico()
#-----------------------------------------#

define l_existe smallint
define l_asitipcod like datmservico.asitipcod

define lr_servico record 
       atdsrvnum like datmservico.atdsrvnum, 
       atdsrvano like datmservico.atdsrvano
end record 



initialize lr_servico.* to null 

       

if m_cts66m00_sql is null or
    m_cts66m00_sql <> true then
    call cts66m00_prepare()
end if


    let l_existe = false
    whenever error continue
    open c_cts66m00_005 using g_documento.succod,
                              g_documento.aplnumdig,
                              g_documento.ramcod,
                              g_documento.itmnumdig                    
    
    whenever error stop
    foreach c_cts66m00_005 into lr_servico.atdsrvnum,
                                lr_servico.atdsrvano
     
        
        whenever error continue                         
        open c_cts66m00_002 using lr_servico.atdsrvnum,
                                  lr_servico.atdsrvano
        fetch c_cts66m00_002 into l_asitipcod          
                                                        
        whenever error stop                             
        close c_cts66m00_002                            
        
        if l_asitipcod = 1 then            
           let l_existe = true
           exit foreach
        end if 
                    
    end foreach 
       
    return l_existe

end function 



