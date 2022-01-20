#############################################################################
# Nome do Modulo: CTS00M14                                         Marcelo  #
#                                                                  Gilberto #
# Direciona e imprime laudo de servico para prestador              Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Incluir identificacao para servicos #
#                                       atendidos como particular.          #
#---------------------------------------------------------------------------#
# 23/10/1998  PSI 6966-3   Gilberto     Incluir configuracoes para envio de #
#                                       fax atraves do servidor VSI-Fax.    #
#---------------------------------------------------------------------------#
# 17/03/1999  PSI 8009-8   Wagner       Incluir Nro.telefone do segurado na #
#                                       impressao do fax para todos os tipos#
#                                       de servicos.                        #
#---------------------------------------------------------------------------#
# 25/06/1999  PSI 7574-7   Gilberto     Enviar fax para assistencia a pas-  #
#                                       sageiros.                           #
#---------------------------------------------------------------------------#
# 12/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 31/12/1999  Edu Oriente  Gilberto     Confirmar antes de atualizar cadas- #
#                                       tro do prestador.                   #
#---------------------------------------------------------------------------#
# 02/02/2000  PSI 10205-9  Wagner       Nao atualizar prestador qdo. o      #
#                                       for = 5-Prestador no local.         #
#---------------------------------------------------------------------------#
# 14/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 06/02/2001  PSI 11767-6  Wagner       Adaptacao referencia endereco.      #
#---------------------------------------------------------------------------#
# 24/10/2001  PSI 14042-2  Wagner       Mudanca de lay-out.                 #
#---------------------------------------------------------------------------#
# 28/11/2001  PSI 14177-1  Ruiz         Adaptacao para ramo 78 transportes. #
#---------------------------------------------------------------------------#
# 05/12/2001  CORREIO      Wagner       Conforme correio Eduardo Oriente    #
#                                       quando se tratar de residencia impri#
#                                       -mir correio lay-out anterior.      #
#---------------------------------------------------------------------------#
# 23/05/2002  PSI 15419-9  Ruiz         imprimir data/hora da viagem.       #
#---------------------------------------------------------------------------#
# 25/06/2002  PSI 15426-1  Ruiz         informar qdo veiculo Blindado.      #
#---------------------------------------------------------------------------#
# 29/08/2002  CORREIO      Wagner       Conforme correio Eduardo mudar o    #
#                                       texto do fax provisoriamente.       #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Carlos Ruiz                      OSF : 12718            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 27/12/2002       #
#  Objetivo       : Alterar Valor maximo para cobertura                     #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 07/04/2005 Pietro - Meta     PSI189790  Alteracao no relatorio rep_laudo   #
#                                         para obter os servicos multiplos   #
#                                                                            #
#----------------------------------------------------------------------------#
# 27/10/2005 Lucas Scheid      PSI195138  Obter a descricao da especialidade #
#                                         do servico.                        #
# 22/09/06   Ligia Mattge  PSI 202720    Implementacao do grupo/cartao Saude #
# 25/11/06   Ligia Mattge  PSI 205206    ciaempcod                           #
# 30/07/2008 Fabio Costa   PSI 227145  Buscar data/hora do acionamento do    #
#                                      servico, retirar localidades do fax p/#
#                                      servico taxi                          #
# 13/08/2009 Sergio Burini PSI 244236  Inclusão do Sub-Dairro                #
#----------------------------------------------------------------------------#
# 04/01/2010 Amilton, Meta             Projeto Sucursal smallint             #
#----------------------------------------------------------------------------#
# 29/07/2013 Fabio, Fornax PSI-2013-06224/PR                                 #
#                          Identificacao no Acionamento do Laudo empresa SAPS#
#----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define wsgpipe         char(80)
 define wsgfax          char (03),
        m_cts00m14_prep smallint

 define m_mensagem_2 char (135)
 define m_mensagem_3 char (135)
 define m_mensagem_4 char (135)
 define m_mensagem_5 char (135)
 define m_mensagem_6 char (135)

#-------------------------#
function cts00m14_prepare()
#-------------------------#

  define l_sql char(500)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql = null

  let l_sql = " select espcod ",
                " from datmsrvre ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts00m14_001 from l_sql
  declare c_cts00m14_001 cursor for p_cts00m14_001

  let l_sql = " select vclcndlclcod ",
                " from datrcndlclsrv ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts00m14_002 from l_sql
  declare c_cts00m14_002 cursor for p_cts00m14_002

  let l_sql = " select atdsrvorg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts00m14_003 from l_sql
  declare c_cts00m14_003 cursor for p_cts00m14_003

  let l_sql = "select cgccpfnum, "   ,
              " cgcord    , "        ,
              " cgccpfdig   "        ,
              " from datrligcgccpf " ,
              " where lignum = ?   "
  prepare p_cts00m14_004 from l_sql
  declare c_cts00m14_004 cursor for p_cts00m14_004
  
  
  let l_sql = "select a.ramcod,    ",
              "       a.aplnumdig, ",
              "       a.itmnumdig, ",
              "       a.edsnumref, ",
              "       b.itaciacod  ",
              " from datrligapol a,",
              "      datrligitaaplitm b ",
              "where a.lignum = (select MIN(lignum)",
              "                    from datmligacao",
              "                   where atdsrvnum = ?",
              "                     and atdsrvano = ? )",
              "   and a.lignum = b.lignum"
            
  prepare p_cts00m14_005 from l_sql               
  declare c_cts00m14_005 cursor for p_cts00m14_005
   
  let m_cts00m14_prep = true

end function

#--------------------------------------------------------------
 function cts00m14(param)
#--------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    pstcoddig        like dpaksocor.pstcoddig   ,
    enviar           char (01)
 end record

 define d_cts00m14   record
    enviar           char (01)                  ,
    envdes           char (10)                  ,
    nomgrr           like dpaksocor.nomgrr      ,
    dddcod           like dpaksocor.dddcod      ,
    faxnum           like dpaksocor.faxnum      ,
    faxch1           like gfxmfax.faxch1        ,
    faxch2           like gfxmfax.faxch2
 end record

 define ws           record
    dddcod           like dpaksocor.dddcod      ,
    faxnum           like dpaksocor.faxnum      ,
    faxtxt           char (12)                  ,
    dddcodsva        like dpaksocor.dddcod      ,
    faxnumsva        like dpaksocor.faxnum      ,
    impflg           smallint                   ,
    impnom           char (08)                  ,
    envflg           dec (1,0)                  ,
    confirma         char (01)
 end record

 define l_atdsrvorg like datmservico.atdsrvorg


 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   initialize  d_cts00m14.*  to  null

   initialize  ws.*  to  null

 if m_cts00m14_prep is null or
    m_cts00m14_prep <> true then
    call cts00m14_prepare()

 end if

 initialize d_cts00m14.*  to null
 initialize ws.*          to null

 let int_flag             =  false
 let d_cts00m14.enviar    =  param.enviar
 let ws.envflg            =  true

#---------------------------------------------------------------------------
# Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
#---------------------------------------------------------------------------
 let wsgfax = "VSI"

 select dpaksocor.nomgrr ,
        dpaksocor.dddcod ,
        dpaksocor.faxnum
   into d_cts00m14.nomgrr, d_cts00m14.dddcod, d_cts00m14.faxnum
   from dpaksocor
  where dpaksocor.pstcoddig = param.pstcoddig

 let ws.dddcodsva = d_cts00m14.dddcod
 let ws.faxnumsva = d_cts00m14.faxnum

 open window cts00m14 at 11,13 with form "cts00m14"
             attribute (form line 1, border)

 display by name  d_cts00m14.nomgrr

 input by name d_cts00m14.enviar ,
               d_cts00m14.dddcod ,
               d_cts00m14.faxnum  without defaults

   before field enviar
          display by name d_cts00m14.enviar    attribute (reverse)

   after  field enviar
          display by name d_cts00m14.enviar

          if d_cts00m14.enviar is null  then
             error " Enviar laudo de servico para (I)mpressora ou (F)ax!"
             next field enviar
          else
             if d_cts00m14.enviar = "F"  then
                let d_cts00m14.envdes = "FAX"
             else
                if d_cts00m14.enviar = "I"  then
                   let d_cts00m14.envdes = "IMPRESSORA"
                else
                   error " Enviar laudo de servico para (I)mpressora ou (F)ax!"
                   next field enviar
                end if
             end if
          end if

          display by name d_cts00m14.envdes

          initialize  wsgpipe, ws.impflg, ws.impnom  to null

          if d_cts00m14.enviar = "I"   then

             call fun_print_seleciona (g_issk.dptsgl, "")
                  returning  ws.impflg, ws.impnom

             if ws.impflg = false  then
                error " Departamento/Impressora nao cadastrada!"
                next field enviar
             end if
             if ws.impnom is null  then
                error " Uma impressora deve ser selecionada!"
                next field enviar
             end if
          else
             if g_hostname = "u07"  then
                if  g_issk.dptsgl = "desenv" or
                    g_issk.funmat = 5048    then
                   # OK fax pode ser enviado para esta matricula
                else
                   error " Fax so' pode ser enviado no ambiente de producao!"
                   next field enviar
                end if
             end if
          end if

   before field dddcod
          display by name d_cts00m14.dddcod    attribute (reverse)

   after  field dddcod
          display by name d_cts00m14.dddcod
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field enviar
          end if

          if d_cts00m14.dddcod   is null    or
             d_cts00m14.dddcod   = "  "     then
             error " Codigo do DDD deve ser informado!"
             next field dddcod
          end if

          if d_cts00m14.dddcod   = "0   "   or
             d_cts00m14.dddcod   = "00  "   or
             d_cts00m14.dddcod   = "000 "   or
             d_cts00m14.dddcod   = "0000"   then
             error " Codigo do DDD invalido!"
             next field dddcod
         end if

   before field faxnum
          display by name d_cts00m14.faxnum    attribute (reverse)

   after  field faxnum
          display by name d_cts00m14.faxnum
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field dddcod
          end if

          if d_cts00m14.faxnum   is null    or
             d_cts00m14.faxnum   = 000      then
             error " Numero do fax deve ser informado!"
             next field faxnum
          else
             if d_cts00m14.faxnum > 99999   then
             else
                error " Numero do fax invalido!"
                next field faxnum
             end if
          end if

   on key (interrupt)
      exit input

 end input

 if not int_flag  then
    if ((ws.dddcodsva      is null            or
         ws.faxnumsva      is null)           or
        (d_cts00m14.dddcod <> ws.dddcodsva    or
         d_cts00m14.faxnum <> ws.faxnumsva))  and
         param.pstcoddig   <> 5               then
        if cts08g01("C","S","","ALTERA NUMERO DO FAX",
                    "NO CADASTRO DO PRESTADOR ?","") = "S"  then
           update dpaksocor
              set dddcod = d_cts00m14.dddcod,
                  faxnum = d_cts00m14.faxnum
            where pstcoddig = param.pstcoddig
        end if
    end if

    if d_cts00m14.enviar  =  "F"  then
       call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                              "", "PS", g_issk.funmat)
                    returning ws.envflg, d_cts00m14.faxch1, d_cts00m14.faxch2

       if wsgfax = "GSF"  then
          if g_hostname = "u07"  then
             let ws.impnom = "tstclfax"
          else
             let ws.impnom = "ptsocfax"
          end if
          let wsgpipe = "lp -sd ", ws.impnom
       else
           call cts02g01_fax(d_cts00m14.dddcod, d_cts00m14.faxnum)
                  returning ws.faxtxt

          let wsgpipe = "vfxCTPS ", ws.faxtxt clipped,
                         " ", ascii 34, d_cts00m14.nomgrr clipped,
                         ascii 34, " ", d_cts00m14.faxch1 using "&&&&&&&&&&",
                         " ", d_cts00m14.faxch2 using "&&&&&&&&&&"
       end if
    else
       let wsgpipe = "lp -sd ", ws.impnom
    end if

    if ws.envflg = true  then
       let l_atdsrvorg = 0
       open c_cts00m14_003 using param.atdsrvnum, param.atdsrvano
       fetch c_cts00m14_003 into l_atdsrvorg
       if  sqlca.sqlcode <> 0 then
           let l_atdsrvorg = 0
       end if

       if l_atdsrvorg = 18 then
           call enviafax_cts31m00(l_atdsrvorg,
                                  param.atdsrvnum,
                                  param.atdsrvano,
                                  wsgpipe)
       else
           start report  rep_laudo
           output to report rep_laudo(param.atdsrvnum  , param.atdsrvano  ,
                                      d_cts00m14.dddcod, d_cts00m14.faxnum,
                                      d_cts00m14.enviar, d_cts00m14.nomgrr,
                                      d_cts00m14.faxch1, d_cts00m14.faxch2)
           finish report  rep_laudo
       end if
    else
       call cts08g01("A", "S", "OCORREU UM PROBLEMA NO",
                               "ENVIO DO FAX!",
                               "",
                               "*** TENTE NOVAMENTE ***")
         returning ws.confirma
    end if
 else
    error " ATENCAO !!! FAX NAO SERA' ENVIADO!"

    call cts08g01("A","N","","FAX DE ACIONAMENTO DE PRESTADOR",
                             "*** NAO SERA' ENVIADO ***","")
        returning ws.confirma
 end if
 
 display "comando fax: ", wsgpipe clipped

 let int_flag = false
 close window cts00m14

end function  ###  cts00m14

#---------------------------------------------------------------------------
report rep_laudo(r_cts00m14)
#---------------------------------------------------------------------------

 define r_cts00m14    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    dddcod            like dpaksocor.dddcod        ,
    faxnum            dec(8,0)                     ,
    enviar            char (01)                    ,
    nomgrr            char (24)                    ,
    faxch1            like gfxmfax.faxch1          ,
    faxch2            like gfxmfax.faxch2
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    asimtvcod         like datkasimtv.asimtvcod    ,
    asimtvdes         like datkasimtv.asimtvdes    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    nom               like datmservico.nom         ,
    ramcod            like datrservapol.ramcod     ,
    ramnom            like gtakram.ramnom     ,
    ramsgl            like gtakram.ramsgl     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcorcod         like datmservico.vclcorcod   ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    srvprlflg         like datmservico.srvprlflg   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    srrabvnom         like datksrr.srrabvnom       ,
    traco             char (132)                   ,
    privez            smallint                     ,
    vclcordes         char (20)                    ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atdrsddes         char (03)                    ,
    rmcacpdes         char (03)                    ,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    pasnom            like datmpassageiro.pasnom   ,
    pasidd            like datmpassageiro.pasidd   ,
    bagflg            like datmassistpassag.bagflg ,
    trppfrdat         like datmassistpassag.trppfrdat,
    trppfrhor         like datmassistpassag.trppfrhor,
    lclrsccod         like datmsrvre.lclrsccod     ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    ntzdes            char (40)                    ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    atddstcidnom      like datmassistpassag.atddstcidnom,
    atddstufdcod      like datmassistpassag.atddstufdcod,
    lclrefptotxt1     char (100),
    lclrefptotxt2     char (100),
    sqlcode           integer,
    imsvlr            like abbmcasco.imsvlr,
    imsvlrdes         char (08),
    vclcndlclcod      like datrcndlclsrv.vclcndlclcod,
    vclcndlcldes      like datkvclcndlcl.vclcndlcldes ,
    grupo             like gtakram.ramgrpcod,
    ciaempcod         like datmservico.ciaempcod,
    qtddia            like datmhosped.hpddiapvsqtd,
    qtdqrt            like datmhosped.hpdqrtqtd   ,
    lignum            like datrligsrv.lignum
 end record

 define a_cts00m14    array[2] of record
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (80)                    ,
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
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    endcmp            like datmlcl.endcmp
 end record

 define al_saida array[10] of record
    atdmltsrvnum like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano like datratdmltsrv.atdmltsrvano
   ,socntzdes    like datksocntz.socntzdes
   ,espdes       like dbskesp.espdes
   ,atddfttxt    like datmservico.atddfttxt
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record
 
 define l_acihor record
        atddat  like datmsrvacp.atdetpdat ,
        atdhor  like datmsrvacp.atdetphor ,
        acistr  char(70)
 end record
 
 define lr_retorno record 
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,                          
     erro          integer, 
     mensagem      char(50)                          
 end record   
 
 define l_resultado smallint,
        l_mensagem  char(30),
        l_doc_handle integer,
        l_cont      smallint,
        l_passou    smallint,
        l_cartao    char(30),
        l_kmazul    char(3),
        l_qtdeazul  char(3),
        l_kmazulint integer

 define arr_aux       smallint
       ,vl_ligcvntip  like datmligacao.ligcvntip

 define l_espdes     like dbskesp.espdes,
        l_docto      char(100),
        l_segnom     like gsakseg.segnom,
        l_crtsaunum  like datrligsau.crtnum
       
 define l_limpecas char(50),
        l_mobrefvlr like dpakpecrefvlr.mobrefvlr,
        l_pecmaxvlr like dpakpecrefvlr.pecmaxvlr

 --varani

 define l_psaerrcod integer
 
 output report to pipe  wsgpipe
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58

 format
   on every row

      initialize al_saida to null
      initialize lr_ffpfc073.* to null
      initialize l_limpecas to null
      let l_resultado = null
      let l_mensagem  = null
      let l_cont      = 1
      initialize  a_cts00m14  to null
      initialize  ws.*        to null
      let ws.traco = "------------------------------------------------------------------------------------------------------------------------------------"
      let ws.privez = 0

      # -- OSF 12718 - Fabrica de Software, Katiucia -- #
      declare ccts00m14001 cursor
          for select b.ligcvntip, b.ciaempcod
                from datrligsrv a, datmligacao b
               where a.atdsrvnum = r_cts00m14.atdsrvnum
                 and a.atdsrvano = r_cts00m14.atdsrvano
                 and a.lignum    = b.lignum

      open ccts00m14001
         fetch ccts00m14001 into vl_ligcvntip, ws.ciaempcod

         if sqlca.sqlcode = notfound then
            initialize vl_ligcvntip to null
         end if
      close ccts00m14001

      if r_cts00m14.enviar = "F"  then
         if wsgfax = "GSF"  then
            #----------------------------------------
            # Checa caracteres invalidos para o GSFAX
            #----------------------------------------
            call cts02g00(r_cts00m14.nomgrr)  returning r_cts00m14.nomgrr

            if r_cts00m14.dddcod     >  0099  then
               print column 001, r_cts00m14.dddcod using "&&&&"; #
            else                                                 # Codigo DDD
               print column 001, r_cts00m14.dddcod using "&&&";  #
            end if

            if r_cts00m14.faxnum > 99999999  then
               print column 001, r_cts00m14.faxnum using "&&&&&&&&&";  #
            else                                                      #
               if r_cts00m14.faxnum > 9999999  then                    # Numero
                  print column 001, r_cts00m14.faxnum using "&&&&&&&&";#  Fax
               else                                                   #
                  print column 001, r_cts00m14.faxnum using "&&&&&&&"; #
               end if
            end if

            print column 001                        ,
            "@"                                     ,  #--> Delimitador
            r_cts00m14.nomgrr                       ,  #--> Destinatario Cx pos
            "*CTPS"                                 ,  #--> Sistema/Subsistema
            r_cts00m14.faxch1    using "&&&&&&&&&&" ,  #--> No./Ano Servico
            r_cts00m14.faxch2    using "&&&&&&&&&&" ,  #--> Sequencia
            "@"                                     ,  #--> Delimitador
            r_cts00m14.nomgrr                       ,  #--> Destinat.(Informix)
            "@"                                     ,  #--> Delimitador
            "CENTRAL 24 HORAS"                      ,  #--> Quem esta enviando
            "@"                                     ,  #--> Delimitador
            "132PORTO.TIF"                          ,  #--> Arquivo Logotipo
            "@"                                     ,  #--> Delimitador
            "semcapa"                                  #--> Nao tem cover page
         end if

         if wsgfax = "VSI" then
            case ws.ciaempcod
              when 1
                print column 001, ascii 27, "&k2S";        #--> Caracteres
                print             ascii 27, "(s7b";        #--> de controle
                print             ascii 27, "(s4102T";     #--> para 132
                print             ascii 27, "&l08D";       #--> colunas
                print             ascii 27, "&l00E";       #--> Logo no topo
                print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                skip 8 lines

              when 35
                print column 001, ascii 27, "&k2S";        #--> Caracteres
                print             ascii 27, "(s7b";        #--> de controle
                print             ascii 27, "(s4102T";     #--> para 132
                print             ascii 27, "&l08D";       #--> colunas
                print             ascii 27, "&l00E";       #--> Logo no topo
                print column 001, "@+IMAGE[azul.tif;x=0cm;y=0cm]"
                skip 7 lines
                
              when 43   #--> PSI-2013-06224/PR
                initialize l_psaerrcod to null
                call cts59g00_idt_srv_saps(1, r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano) returning l_psaerrcod
                
                if l_psaerrcod = 0  # serviço SAPS
                   then
                   print column 001, ascii 27, "&k2S";        #--> Caracteres
                   print             ascii 27, "(s7b";        #--> de controle
                   print             ascii 27, "(s4102T";     #--> para 132
                   print             ascii 27, "&l08D";       #--> colunas
                   print             ascii 27, "&l00E";       #--> Logo no topo
                   # compilacao do TIF para fax nao disponivel, sera disponibilizado projeto substituição do VSIfax
                   # print column 001, "@+IMAGE[saps.tif;x=0cm;y=0cm]"
                   print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                   skip 8 lines
                end if
                
              when 84
                print column 001, ascii 27, "&k2S";        #--> Caracteres
                print             ascii 27, "(s7b";        #--> de controle
                print             ascii 27, "(s4102T";     #--> para 132
                print             ascii 27, "&l08D";       #--> colunas
                print             ascii 27, "&l00E";       #--> Logo no topo
                #print column 001, "@+IMAGE[itau.tif;x=0cm;y=0cm]"
                skip 7 lines

              otherwise
                print column 001, ascii 27, "&k2S";        #--> Caracteres
                print             ascii 27, "(s7b";        #--> de controle
                print             ascii 27, "(s4102T";     #--> para 132
                print             ascii 27, "&l08D";       #--> colunas
                
            end case

         end if
      end if

      #--------------------------------------------------------------
      # Busca informacoes do servico
      #--------------------------------------------------------------
      select datmservico.atdsrvorg   , datmservico.asitipcod   ,
             datmservico.atdhorpvt   , datmservico.atddat      ,
             datmservico.atdhor      , datmservico.nom         ,
             datrservapol.ramcod     , datrservapol.succod     ,
             datrservapol.aplnumdig  , datrservapol.itmnumdig  ,
             datmservico.vcldes      , datmservico.vclanomdl   ,
             datmservico.vcllicnum   , datmservico.vclcorcod   ,
             datmservico.atdrsdflg   , datmservico.atddfttxt   ,
             datmservico.atdvclsgl   , datmservico.atdmotnom   ,
             datmservico.atddatprg   , datmservico.atdhorprg   ,
             datmservico.socvclcod   , datmservico.srvprlflg   ,
             datmservico.srrcoddig   ,
             datmservicocmp.roddantxt, datmservicocmp.bocnum   ,
             datmservicocmp.bocemi   , datmservicocmp.rmcacpflg,
             datmservico.ciaempcod
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
             ws.ciaempcod
        from datmservico, outer datmservicocmp, outer datrservapol
       where datmservico.atdsrvnum    = r_cts00m14.atdsrvnum
         and datmservico.atdsrvano    = r_cts00m14.atdsrvano

         and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
         and datmservicocmp.atdsrvano = datmservico.atdsrvano

         and datrservapol.atdsrvnum   = datmservico.atdsrvnum
         and datrservapol.atdsrvano   = datmservico.atdsrvano

      #--------------------------------------------------------------
      # Busca descricao do ramo
      #--------------------------------------------------------------
      #select ramnom
      #     into ws.ramnom
      #     from gtakram
      #     where ramcod = ws.ramcod
      #       and empcod = 1
      #if sqlca.sqlcode <> 0 then
      #   let ws.ramcod = "N/CADASTR"
      #end if

      ### PSI 202720

      if ws.atdsrvorg  =   2    or
         ws.atdsrvorg  =   3    then  --varani
         select asimtvcod
         into ws.asimtvcod
         from datmassistpassag
         where atdsrvnum = r_cts00m14.atdsrvnum   and
               atdsrvano = r_cts00m14.atdsrvano
   
         if ws.atdsrvorg =  03  then
            select hpddiapvsqtd
            into ws.qtddia
            from datmhosped
            where atdsrvnum = r_cts00m14.atdsrvnum
            and atdsrvano = r_cts00m14.atdsrvano
         end if
      end if
   
      ## Obter os servicos multiplos
      call cts29g00_obter_multiplo(1,
                                   r_cts00m14.atdsrvnum,
                                   r_cts00m14.atdsrvano)
           returning l_resultado
                    ,l_mensagem
                    ,al_saida[1].*
                    ,al_saida[2].*
                    ,al_saida[3].*
                    ,al_saida[4].*
                    ,al_saida[5].*
                    ,al_saida[6].*
                    ,al_saida[7].*
                    ,al_saida[8].*
                    ,al_saida[9].*
                    ,al_saida[10].*
   
      if l_resultado = 3 then
         error l_mensagem sleep 2
      else
          if (ws.atdsrvorg = 2 or ws.atdsrvorg = 3) and ws.ciaempcod <> 84 then
             call ctr03m02_busca_limite_cob( r_cts00m14.atdsrvnum
                                           ,r_cts00m14.atdsrvano
                                           ,ws.succod
                                           ,ws.aplnumdig  --varani --> passando os parametros recuperados
                                           ,ws.itmnumdig
                                           ,ws.asitipcod
                                           ,ws.ramcod
                                           ,ws.asimtvcod
                                           ,vl_ligcvntip
                                           ,ws.qtddia
                                           ,ws.atdsrvorg  )
                 returning m_mensagem_2,
                           m_mensagem_3,
                           m_mensagem_4,
                           m_mensagem_5,
                           m_mensagem_6
          end if
      end if
   
      call cty10g00_descricao_ramo(ws.ramcod, g_issk.empcod)
                returning l_resultado, l_mensagem, ws.ramnom, ws.ramsgl
   
      call cty10g00_grupo_ramo(g_issk.empcod, ws.ramcod)
                returning l_resultado, l_mensagem, ws.grupo
   
           #--------------------------------------------------------------
           # Busca informacoes do local da ocorrencia
           #--------------------------------------------------------------
      call ctx04g00_local_completo(r_cts00m14.atdsrvnum,
                                   r_cts00m14.atdsrvano,
                                   1)
                         returning a_cts00m14[1].lclidttxt   ,
                                   a_cts00m14[1].lgdtip      ,
                                   a_cts00m14[1].lgdnom      ,
                                   a_cts00m14[1].lgdnum      ,
                                   a_cts00m14[1].lclbrrnom   ,
                                   a_cts00m14[1].brrnom      ,
                                   a_cts00m14[1].cidnom      ,
                                   a_cts00m14[1].ufdcod      ,
                                   a_cts00m14[1].lclrefptotxt,
                                   a_cts00m14[1].endzon      ,
                                   a_cts00m14[1].lgdcep      ,
                                   a_cts00m14[1].lgdcepcmp   ,
                                   a_cts00m14[1].dddcod      ,
                                   a_cts00m14[1].lcltelnum   ,
                                   a_cts00m14[1].lclcttnom   ,
                                   a_cts00m14[1].c24lclpdrcod,
                                   ws.sqlcode,
                                   a_cts00m14[1].endcmp
                                        
      # PSI 244589 - Inclusão de Sub-Bairro - Burini
      call cts06g10_monta_brr_subbrr(a_cts00m14[1].brrnom,
                                     a_cts00m14[1].lclbrrnom)
           returning a_cts00m14[1].lclbrrnom
  
      if ws.sqlcode <> 0  then
          error " Erro (", ws.sqlcode, ") na leitura local de ocorrencia.",
                   " AVISE A INFORMATICA!"
          #  return
      end if
      
      let a_cts00m14[1].lgdtxt = a_cts00m14[1].lgdtip clipped, " ",
                                 a_cts00m14[1].lgdnom clipped, " ",
                                 a_cts00m14[1].lgdnum using "<<<<#", " ",
                                 a_cts00m14[1].endcmp clipped
  
      #--------------------------------------------------------------
      # Busca informacoes do local de destino
      #--------------------------------------------------------------
      call ctx04g00_local_completo(r_cts00m14.atdsrvnum,
                                       r_cts00m14.atdsrvano,
                                       2)
                             returning a_cts00m14[2].lclidttxt   ,
                                       a_cts00m14[2].lgdtip      ,
                                       a_cts00m14[2].lgdnom      ,
                                       a_cts00m14[2].lgdnum      ,
                                       a_cts00m14[2].lclbrrnom   ,
                                       a_cts00m14[2].brrnom      ,
                                       a_cts00m14[2].cidnom      ,
                                       a_cts00m14[2].ufdcod      ,
                                       a_cts00m14[2].lclrefptotxt,
                                       a_cts00m14[2].endzon      ,
                                       a_cts00m14[2].lgdcep      ,
                                       a_cts00m14[2].lgdcepcmp   ,
                                       a_cts00m14[2].dddcod      ,
                                       a_cts00m14[2].lcltelnum   ,
                                       a_cts00m14[2].lclcttnom   ,
                                       a_cts00m14[2].c24lclpdrcod,
                                       ws.sqlcode,
                                       a_cts00m14[2].endcmp
                                       
      # PSI 244589 - Inclusão de Sub-Bairro - Burini
      call cts06g10_monta_brr_subbrr(a_cts00m14[2].brrnom,
                                     a_cts00m14[2].lclbrrnom)
           returning a_cts00m14[2].lclbrrnom

      if ws.sqlcode = notfound   then
      else
         if ws.sqlcode = 0   then
            let a_cts00m14[2].lgdtxt = a_cts00m14[2].lgdtip clipped, " ",
                                       a_cts00m14[2].lgdnom clipped, " ",
                                       a_cts00m14[2].lgdnum using "<<<<#", " ",
                                       a_cts00m14[2].endcmp clipped
         else
            error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
                  " local de destino. AVISE A INFORMATICA!"
            # return
         end if
      end if

      ### PSI 202720
      if ws.grupo = 5 then ## Saude
         call cts20g10_cartao(1, r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano)
              returning l_resultado, l_mensagem, l_crtsaunum

         call cta01m15_sel_datksegsau(3, l_crtsaunum, "","")
              returning l_resultado, l_mensagem, l_segnom,
                        ws.dddcod, ws.teltxt

      else
         case ws.ciaempcod
              when 1
                call cts09g00(ws.ramcod, ws.succod, ws.aplnumdig,
                          ws.itmnumdig,false)
                 returning ws.dddcod, ws.teltxt

              when 35
                if ws.aplnumdig is not null then
                   call cts42g00_doc_handle(ws.succod, ws.ramcod,
                                           ws.aplnumdig, ws.itmnumdig,
                                           g_documento.edsnumref)
                       returning l_resultado, l_mensagem, l_doc_handle
                   
                   call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                       returning ws.dddcod, ws.teltxt
                   
                   ---> Busca Limites da Azul
                   call cts49g00_clausulas(l_doc_handle)
                       returning l_kmazul, l_qtdeazul
                end if
                
              when 40
                 #---------------------------------------------------------------
                 # Dados da ligacao
                 #---------------------------------------------------------------
                 let ws.lignum = cts20g00_servico(r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano)
                 
                 
                 whenever error continue
                 open c_cts00m14_004 using ws.lignum
                 
                 fetch c_cts00m14_004 into lr_ffpfc073.cgccpfnum ,
                                         lr_ffpfc073.cgcord    ,
                                         lr_ffpfc073.cgccpfdig
                 
                 whenever error stop
                 
                 let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                        lr_ffpfc073.cgcord    ,
                                                                        lr_ffpfc073.cgccpfdig )
                 
                    call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                          returning ws.dddcod         ,
                                    ws.teltxt         ,
                                    lr_ffpfc073.mens  ,
                                    lr_ffpfc073.erro
                 
                    if lr_ffpfc073.erro <> 0 then
                        error lr_ffpfc073.mens
                    end if   
                       
              when 84
                open c_cts00m14_005 using r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano  
                whenever error continue                                                   
                fetch c_cts00m14_005 into g_documento.ramcod,   
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig,
                                          g_documento.edsnumref,
                                          g_documento.itaciacod                                            
                                                                                  
                whenever error stop                                                       

                if g_documento.ramcod = 531 or g_documento.ramcod = 31 then   
                   call cty22g00_rec_dados_itau(g_documento.itaciacod,
                               g_documento.ramcod   ,
                               g_documento.aplnumdig,
                               g_documento.edsnumref,
                               g_documento.itmnumdig)
                    returning lr_retorno.erro,    
                              lr_retorno.mensagem
                         
                    if lr_retorno.erro = 0 then  
                       
                       call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)     
                                 returning lr_retorno.pansoclmtqtd,               
                                           lr_retorno.socqlmqtd,                  
                                           lr_retorno.erro,                       
                                           lr_retorno.mensagem
                       
                                        
                       let ws.dddcod = g_doc_itau[1].segresteldddnum
                       let ws.teltxt = g_doc_itau[1].segrestelnum 
                    else
                       let ws.dddcod = 0
                       let ws.teltxt = 0      
                    end if 
                 else
                    call cty25g01_rec_dados_itau (g_documento.itaciacod,   
                                                  g_documento.ramcod   ,   
                                                  g_documento.aplnumdig,   
                                                  g_documento.edsnumref,   
                                                  g_documento.itmnumdig)   
                                                                           
                         returning lr_retorno.erro,                        
                                   lr_retorno.mensagem 
                    if lr_retorno.erro = 0 then 
                       let ws.dddcod = g_doc_itau[1].segresteldddnum
                       let ws.teltxt = g_doc_itau[1].segrestelnum 
                    else
                       let ws.dddcod = 0
                       let ws.teltxt = 0      
                    end if
                 end if
         end case
      end if

      #--------------------------------------------------------------
      # Verifica se veiculo e BLINDADO.
      #--------------------------------------------------------------
      call f_funapol_ultima_situacao
           (ws.succod, ws.aplnumdig, ws.itmnumdig) returning g_funapol.*
      let ws.imsvlr = 0
      select imsvlr
           into ws.imsvlr
           from abbmbli
          where succod    = g_documento.succod    and
                aplnumdig = g_documento.aplnumdig and
                itmnumdig = g_documento.itmnumdig and
                dctnumseq = g_funapol.autsitatu

      #--------------------------------------------------------------
      # Busca natureza Porto Socorro/Sinistro de R.E.
      #--------------------------------------------------------------
      if ws.atdsrvorg = 9    or
         ws.atdsrvorg = 13   then
         select lclrsccod, orrdat   ,
                orrhor   , sinntzcod,
                socntzcod
           into ws.lclrsccod        ,
                ws.orrdat           ,
                ws.orrhor           ,
                ws.sinntzcod        ,
                ws.socntzcod
           from datmsrvre
          where atdsrvnum = r_cts00m14.atdsrvnum  and
                atdsrvano = r_cts00m14.atdsrvano

         let ws.ntzdes = "*** NAO CADASTRADO ***"

         if ws.sinntzcod is not null  then
            select sinntzdes
              into ws.ntzdes
              from sgaknatur
             where sinramgrp = "4"      and
                   sinntzcod = ws.sinntzcod
         else
            select socntzdes
              into ws.ntzdes
              from datksocntz
             where socntzcod = ws.socntzcod
         end if
      end if

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
         when "S"  let ws.atdrsddes = "SIM"
         when "N"  let ws.atdrsddes = "NAO"
      end case

      case ws.rmcacpflg
         when "S"  let ws.rmcacpdes = "SIM"
         when "N"  let ws.rmcacpdes = "NAO"
      end case

      if ws.vclcorcod   is not null    then
         select cpodes
           into ws.vclcordes
           from iddkdominio
          where cponom = "vclcorcod"    and
                cpocod = ws.vclcorcod
      end if

      if r_cts00m14.enviar  =  "I"   then
         print column 001, "Enviar para: ", r_cts00m14.nomgrr,
           "    Fax: ", "(",r_cts00m14.dddcod, ")", r_cts00m14.faxnum
      end if

      skip 1 line

      print column 001,
      "*** EM CASO DE DUVIDA, ENTRAR EM CONTATO PELO TELEFONE DE APOIO (011)3366-3055 ***"
      skip 1 line

      if ws.ciaempcod <> 35 and ws.ciaempcod <> 84  then
          if m_mensagem_2 is not null then
              skip 1 line
              print column 001, m_mensagem_2 clipped
              print column 001, m_mensagem_3 clipped, m_mensagem_4 clipped
              print column 001, m_mensagem_5 clipped
              print column 001, m_mensagem_6 clipped
              skip 1 line
          end if
      end if

      #TROCA DE FONTE
      ##print ascii(27),"(s0p17h0s3b40999T"

      if ws.ciaempcod = 84 and ws.atdsrvorg <> 3 and ws.atdsrvorg <> 2 then  
         if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
            let l_kmazulint = lr_retorno.socqlmqtd        
            let l_kmazulint = l_kmazulint * 2 
            
            print column 001,
            "+---------------------------------  *** ITAU AUTO E RESIDENCIA  ***  --------------------------------+"
            print column 001,
            "|Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR ** ATE ",l_kmazulint using "<<<#"," KM DA   |"
            
            
            print column 001,
            "|ITAU Auto e RESIDENCIA  **, qualquer KM excedente deve ser cobrado do segurado.                      |"
            print column 001,
            "+-----------------------------------------------------------------------------------------------------+"
            skip 1 line
         else
            
            select socntzcod 
               into ws.socntzcod 
               from datmsrvre
              where atdsrvnum = r_cts00m14.atdsrvnum
                and atdsrvano = r_cts00m14.atdsrvano
               
               select mobrefvlr,
                     pecmaxvlr
                into l_mobrefvlr,
                     l_pecmaxvlr 
                from dpakpecrefvlr
               where socntzcod = ws.socntzcod
                 and empcod    = ws.ciaempcod
               
             if (l_mobrefvlr is not null or l_mobrefvlr <> '') and 
               (l_pecmaxvlr is not null or l_pecmaxvlr <> '') then  
                
                print column 001,
             "+---------------------------------  *** ITAU AUTO E RESIDENCIA  ***  ---------------------------------+"
                    print column 001,
             "|Em caso de fornecimento de pecas, LIMITAR AO VALOR ",l_pecmaxvlr using "<<<<<<<.<<" ," Itau Auto e Residencia  **.   |"
             
                    
                    print column 001,
             "| Em caso de excedente entrar em contato com a central de operacoes.                                  |"
                    print column 001,
             "+-----------------------------------------------------------------------------------------------------+"
                    skip 1 line
            end if 
            
         end if 
      else
         if ws.atdsrvorg = 3 and ws.ciaempcod = 84 then
            let l_kmazulint = 200
            print column 001,
            "+---------------------------------  *** ITAU AUTO E RESIDENCIA  ***  --------------------------------+"
            print column 001,
            "|Em caso de hospedagem, devidamente autorizada pela central de atendimento, COBRAR ** ATE R$:",l_kmazulint using "<<<",",00 DA   |"
            
            
            print column 001,
            "|ITAU Auto e RESIDENCIA  **, qualquer valor excedente deve ser cobrado do segurado.                      |"
            print column 001,
            "+-----------------------------------------------------------------------------------------------------+"
            skip 1 line   
         end if    
      end if
      
      if ws.ciaempcod = 35 then  ## psi 205206 
         print column 001,
         "+----------------------------  *** AZUL SEGUROS ***  --------------------------------+"
         print column 001,
         "|Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR       |"
         
         let l_kmazulint = l_kmazul
         let l_kmazulint = l_kmazulint * 2
         
         print column 001,
         "|** ATE ", l_kmazulint using "<<<#", "KM DA AZUL SEGUROS **, qualquer KM excedente deve ser cobrado do segurado.|"
         print column 001,
         "+------------------------------------------------------------------------------------+"
         skip 1 line
      end if
      
      if ws.ciaempcod = 43 and l_psaerrcod = 0   #--> PSI-2013-06224/PR
         then
         print column 001,  "+-----------------------------  *** SERVICOS AVULSOS PORTO SEGURO ***  -------------------------------------------------------------+"
         skip 1 line
      end if
        
      if ws.atddatprg  is not null   then
         if ws.atddatprg = today     or
            ws.atddatprg > today     then
            print column 001, "*** SERVICO PROGRAMADO PARA: ", ws.atddatprg, " AS ", ws.atdhorprg, " ***"
         end if
      end if

      initialize l_acihor.* to null
      whenever error continue
      select atdetpdat, atdetphor into l_acihor.atddat, l_acihor.atdhor
      from datmsrvacp
      where atdsrvnum = r_cts00m14.atdsrvnum
        and atdsrvano = r_cts00m14.atdsrvano
        and atdsrvseq = ( select max(atdsrvseq)
                          from datmsrvacp
                          where atdsrvnum = r_cts00m14.atdsrvnum
                            and atdsrvano = r_cts00m14.atdsrvano
                            and atdetpcod in (4,3,10) )
      whenever error stop
      
      if l_acihor.atddat is not null and
         l_acihor.atdhor is not null then
         let l_acihor.acistr = "Acionado em: ", l_acihor.atddat, " as ",
                               l_acihor.atdhor
      else
         let l_acihor.acistr = "Solicitado em: ", ws.atddat, " as ", ws.atdhor
      end if
      
      print column 001, ws.traco
      print column 001, "Tipo Servico.: "     , ws.srvtipabvdes,
            column 027, "Tipo Socorro: "      , ws.asitipabvdes,
            column 046, "Previsao: "          , ws.atdhorpvt,
            column 076, l_acihor.acistr clipped

      print column 001, "Ordem Servico: "     ,
                        ws.atdsrvorg         using "&&"      , "/",
                        r_cts00m14.atdsrvnum using "&&&&&&&" , "-",
                        r_cts00m14.atdsrvano using "&&",
            column 031, "Nat: ", ws.ntzdes,
            column 076, "Problema: ", ws.atddfttxt

      let l_espdes = null

      # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
      let l_espdes = cts00m14_busca_especialidade(r_cts00m14.atdsrvnum,
                                                  r_cts00m14.atdsrvano)

      # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
      if l_espdes is not null and
         l_espdes <> " " then
         print column 031, "Esp: ", l_espdes
      end if

      for l_cont = 1 to 10
          if al_saida[l_cont].atdmltsrvnum is not null and
             al_saida[l_cont].atdmltsrvano is not null then
             print column 016,ws.atdsrvorg using '&&','/',
                              al_saida[l_cont].atdmltsrvnum using '&&&&&&&','-',
                              al_saida[l_cont].atdmltsrvano using '&&',
                   column 031, 'Nat: ',al_saida[l_cont].socntzdes,
                   column 076, 'Problema: ',al_saida[l_cont].atddfttxt

             let l_espdes = null

             # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
             let l_espdes = cts00m14_busca_especialidade(al_saida[l_cont].atdmltsrvnum,
                                                         al_saida[l_cont].atdmltsrvano)

             # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
             if l_espdes is not null and
                l_espdes <> " " then
                print column 031, "Esp: ", l_espdes
             end if

          end if
      end for

      #-----------------------------------------------------------
      # Se codigo veiculo informado, ler cadastro de veiculos
      #-----------------------------------------------------------
      if ws.socvclcod  is not null   then
         select atdvclsgl
           into ws.atdvclsgl
           from datkveiculo
          where datkveiculo.socvclcod  =  ws.socvclcod
      end if

      #-----------------------------------------------------------
      # Se codigo socorrista informado, ler cadastro de socorrista
      #-----------------------------------------------------------
      if ws.srrcoddig  is not null   then
         select srrabvnom
           into ws.srrabvnom
           from datksrr
          where datksrr.srrcoddig  =  ws.srrcoddig
      end if

      if ws.atdvclsgl  is not null   or
         ws.atdmotnom  is not null   or
         ws.srrabvnom  is not null   then
         if ws.atdmotnom  is not null   and
            ws.atdmotnom  <>  "  "      then
            print column 001, "Viatura......: "  , ws.atdvclsgl,
                  column 027, "Socorrista...: "  , ws.atdmotnom
         else
            print column 001, "Viatura......: "  , ws.atdvclsgl,
                  column 027, "Socorrista...: "  ,
                         ws.srrcoddig using "####&&&&", " - ", ws.srrabvnom
         end if
      end if

      print column 001, ws.traco
      
      if ws.atdsrvorg = 9    or
         ws.atdsrvorg = 13   then

         ### PSI 202720
         if ws.grupo = 5 then ## Saude
            let l_cartao = null
            call cts20g16_formata_cartao(l_crtsaunum)
                 returning l_cartao
            let l_docto = "Cartao Saude : ", l_cartao
         else
            let l_docto = "Ramo/Suc/Apol: ",
                           ws.ramcod    using "&&&&"      , " ",
                           ws.succod    using "&&&&&"     , " ", #"&&&&"      , " ", #projeto succod
                           ws.aplnumdig using "&&&&&&&& &", " "
         end if

         print column 001, "Segurado.....: ", ws.nom,
               column 061, l_docto,

               #column 061, "Ramo/Suc/Apol: "            ,
               #            ws.ramcod    using "&&&&"      , " ",
               #            ws.succod    using "&&&&"      , " ",
               #            ws.aplnumdig using "&&&&&&&& &", " ",

               column 100, "Telef.: "                          ,
                           "(", ws.dddcod ,") ",ws.teltxt[1,16]
      else
         print column 001, "Ramo.........: ", ws.ramcod,"  ",ws.ramnom
      end if
      
      print column 001, "Responsavel..: "  , a_cts00m14[1].lclcttnom,
            column 061, "Telef. Local.: (",a_cts00m14[1].dddcod ,") ",
                        a_cts00m14[1].lcltelnum;
                        
      if ws.atdrsddes is null  then
         print column 112, " "
      else
         print column 112, "Residencia: "  , ws.atdrsddes
      end if

      if ws.atdsrvorg = 9    or
         ws.atdsrvorg = 13   then
         #  Livre
      else
         initialize ws.imsvlrdes to null
         if ws.imsvlr > 0 then
            let ws.imsvlrdes = "BLINDADO"
         end if
         print column 001, "Veiculo......: "     , ws.vcldes   ,
               column 061, "Ano: "               , ws.vclanomdl,
               column 081, "Placa: "             , ws.vcllicnum,
               column 097, "Cor...: "            , ws.vclcordes,
               column 124, ws.imsvlrdes
      end if

      #skip 1 line

      #-----------------------------------------------------------------
      # Exibe endereco do local da ocorrencia
      #-----------------------------------------------------------------
      initialize ws.lclrefptotxt1, ws.lclrefptotxt2 to null
      let ws.lclrefptotxt1 = a_cts00m14[1].lclrefptotxt[001,100]
      let ws.lclrefptotxt2 = a_cts00m14[1].lclrefptotxt[101,200]

      if a_cts00m14[1].lclidttxt  is not null   then
         print column 001, "Local........: "  , a_cts00m14[1].lclidttxt
      end if

      print column 001, "Endereco.....: ", a_cts00m14[1].lgdtxt   ,
            column 081, "Bairro.....: "  , a_cts00m14[1].lclbrrnom
      print column 001, "Cidade.......: ", a_cts00m14[1].cidnom
                        clipped, " - "   , a_cts00m14[1].ufdcod

      if ws.lclrefptotxt1 is not null then
         print column 001, "Referencia...: ", ws.lclrefptotxt1
      end if
      if ws.lclrefptotxt2 is not null then
         print column 001, "               ", ws.lclrefptotxt2
      end if

      if ws.atdsrvorg  =   4     or
         ws.atdsrvorg  =   6     or
         ws.atdsrvorg  =   1     then
         print column 001, "Rodas Danific: ", ws.roddantxt,
               column 061, "B.O........: "  , ws.bocnum using  "<<<<#", "  ", ws.bocemi
      else
         if ws.atdsrvorg =  5   or
            ws.atdsrvorg =  7   or   # Replace - RPT
            ws.atdsrvorg = 17   then # Replace sem docto
            if ws.roddantxt is not null  then
               print column 001, "Rodas Danific: " , ws.roddantxt
            end if
         else
            if ws.atdsrvorg =  9   or
               ws.atdsrvorg = 13   then
               skip 1 line
               print column 001, "Data Ocorr...: "     , ws.orrdat   ,
                     column 061, "Hora Ocorr: "        , ws.orrhor
            end if
         end if
      end if

      skip 1 line

      #-----------------------------------------------------
      # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (DESTINO)
      #-----------------------------------------------------
      if ws.atdsrvorg  =   4    or
         ws.atdsrvorg  =   6    or
         ws.atdsrvorg  =   1    or
         ws.atdsrvorg  =   5    or
         ws.atdsrvorg  =   7    or
         ws.atdsrvorg  =  17    then
         print column 001, "Local Destino: ", a_cts00m14[2].lclidttxt
         print column 001, "Endereco.....: ", a_cts00m14[2].lgdtxt,
               column 081, "Bairro.....: "  , a_cts00m14[2].lclbrrnom
         print column 001, "Cidade.......: ", a_cts00m14[2].cidnom
                           clipped, " - "   , a_cts00m14[2].ufdcod

         if ws.rmcacpdes is not null  then
            print column 001, "Acompanha Remocao: " , ws.rmcacpdes
         end if
         skip 1 line
      end if

      #------------------------------------------------
      # PARA ASSISTENCIA PASSAGEIROS - TAXI  (DESTINO)
      #------------------------------------------------
      if ws.atdsrvorg  =   2    or
         ws.atdsrvorg  =   3    then
         select atddmccidnom, atddmcufdcod,
                atddstcidnom, atddstufdcod,
                asimtvcod   , bagflg      ,
                trppfrdat   , trppfrhor
           into ws.atddmccidnom,
                ws.atddmcufdcod,
                ws.atddstcidnom,
                ws.atddstufdcod,
                ws.asimtvcod   ,
                ws.bagflg      ,
                ws.trppfrdat   ,
                ws.trppfrhor
           from datmassistpassag
          where atdsrvnum = r_cts00m14.atdsrvnum   and
                atdsrvano = r_cts00m14.atdsrvano

         if ws.atdsrvorg    =  2 and
            ws.asitipcod    = 10 then
            print column 001, "Pref. Viagem.: ",
                  column 016, "Data: ", ws.trppfrdat,
                  column 035, "Hora: ", ws.trppfrhor
         end if
         let ws.asimtvdes = "NAO CADASTRADO"

         select asimtvdes
           into ws.asimtvdes
           from datkasimtv
          where asimtvcod = ws.asimtvcod
         # PSI 227145 - retirado
         if (ws.atdsrvorg =  2 and ws.asitipcod = 10) or
             (ws.atdsrvorg = 3 and ws.asitipcod = 13) then
            print column 001, "Domicilio....: "  , ws.atddmccidnom clipped,
                                          " - "  , ws.atddmcufdcod
            print column 001, "Ocorrencia...: "  , a_cts00m14[1].cidnom clipped,
                                          " - "  , a_cts00m14[1].ufdcod
            print column 001, "Destino......: "  , ws.atddstcidnom clipped,
                                          " - "  , ws.atddstufdcod
         end if
         if (ws.atdsrvorg    =  3 )  or
            (ws.atdsrvorg    =  2    and
             ws.asitipcod = 10 )  then
         else
            print column 001, "Local Destino: "  , a_cts00m14[2].lgdtxt,
                  column 076, "Bairro: "         , a_cts00m14[2].lclbrrnom
            print column 001, "Cidade.......: "  , a_cts00m14[2].cidnom
                              clipped, " - "     , a_cts00m14[2].ufdcod
         end if

         if ws.bagflg  =  "S"   then
            print column 001, "Bagagem......: ", "SIM";
         else
            print column 001, "Bagagem......: ", "NAO";
         end if

         print column 061, "Motivo.....: ", ws.asimtvdes
         skip 1 line

         #----------------------------------------------
         # IMPRIME INFORMACOES SOBRE OS PASSAGEIROS
         #----------------------------------------------
         print column 001, "_________________________________________________ Informacoes sobre os Passageiros _________________________________________________"
         declare ccts00m14003  cursor for
            select pasnom, pasidd
              from datmpassageiro
             where atdsrvnum = r_cts00m14.atdsrvnum  and
                   atdsrvano = r_cts00m14.atdsrvano

         foreach ccts00m14003  into  ws.pasnom, ws.pasidd
            print column 026, ws.pasnom,
                  column 075, ws.pasidd, "  anos de idade"
         end foreach
      end if

      let l_passou = false
      
      open c_cts00m14_002 using r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano
      foreach c_cts00m14_002 into ws.vclcndlclcod

              if l_passou = false then
                 let l_passou = true
                 print column 001,"LOCAL/CONDICOES DO VEICULO"
              end if

              call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

              print column 007, ws.vclcndlcldes clipped

      end foreach

      if l_passou = true then
         skip 1 line
      end if

      if ws.atdsrvorg =  9   or
         ws.atdsrvorg = 13   then
         #----------------------------------------------
         # IMPRIME 5 PRIMEIRAS LINHAS DO HISTORICO
         #----------------------------------------------
         declare ccts00m14004  cursor for
            select c24srvdsc
              from datmservhist
             where atdsrvnum = r_cts00m14.atdsrvnum  and
                   atdsrvano = r_cts00m14.atdsrvano

         foreach ccts00m14004  into  ws.c24srvdsc
            if ws.privez  = 0   then
               print column 001, "_______________________________________________________ Outras Informacoes _________________________________________________________"
            end if
            print column 030, ws.c24srvdsc
            let ws.privez = ws.privez + 1
            if ws.privez > 4   then
               exit foreach
            end if
         end foreach

         if ws.privez > 0   then
            skip 1 line
         end if
      end if

      #--------------------------------------------------
      # PARA ASSISTENCIA PASSAGEIRO - TAXI  (ASSINATURA)
      #--------------------------------------------------
      if ws.atdsrvorg =  2   and
         ws.asitipcod =  5   then
         skip 1 line
         print column 001, "____________________________________________________________________________________________________________________________________"
         print column 025, "DECLARO TER UTILIZADO O SERVICO DE REMOCAO DE PASSAGEIROS NO TRAJETO ACIMA DESCRITO"
         skip 2 line

         print column 001, "         _________________________        ____________________________            ________________________________________                 "
         print column 001, "                   R. G.                            DATA/HORA                              ASSINATURA DO SEGURADO                          "
         skip 2 lines
      end if

      #-----------------------------------------------------------------
      # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (VISTORIA/ASSINATURA)
      #-----------------------------------------------------------------
      if ws.atdsrvorg  =   4    or
         ws.atdsrvorg  =   6    or
         ws.atdsrvorg  =   1    or
         ws.atdsrvorg  =   5    or
         ws.atdsrvorg  =   7    or
         ws.atdsrvorg  =  17    then

         print column 001, "AVARIAS/DANOS: "
         skip 1 line

         print column 001, "____________________________ Acessorios e Ferramentas Existentes no Veiculo _____________________________   _______ Estado _________"

         print column 001, "Bancos Dian.: S  N"      ,
               column 023, "Console.....: S  N"      ,
               column 046, "Rodas Espec.: S  N"      ,
               column 067, "Bagageiro...: S  N"      ,
               column 088, "Triangulo..: S  N"       ,
               column 109, "Pneus Dian.: N/T B  R  P"

         print column 001, "Bancos Tras.: S  N"      ,
               column 023, "Tapetes.....: S  N"      ,
               column 046, "Farois......: S  N"      ,
               column 067, "Obj. P-Malas: S  N"      ,
               column 088, "Ferramentas: S  N"       ,
               column 109, "Pneus Tras.: N/T B  R  P"

         print column 001, "Chaves Veic.: S  N"      ,
               column 023, "Obj. P-Luvas: S  N"      ,
               column 046, "F. de Milha.: S  N"      ,
               column 067, "Estepe......: S  N"      ,
               column 109, "Estepe.....: N/T B  R  P"

         print column 001, "Extintor....: S  N"      ,
               column 023, "Ant Eletrica: S  N"      ,
               column 046, "Lanternas...: S  N"      ,
               column 067, "Macaco......: S  N"      ,
               column 109, "Banco Dian.: N/T B  R  P"


         print column 109, "Banco Tras.: N/T B  R  P"

         print column 001, "Combustivel..: 4/4 3/4 1/2 1/4  Res.",
               column 046, "Toca Fitas..: S  N"      ,
               column 067, "Marca:"                  ,
               column 088, "Radio......: S  N"       ,
               column 109, "Marca:"

         print column 001, "Quilometragem:"
         skip 1 line

         print column 001, "____________________________________________________________________________________________________________________________________"

         print column 008, "DECLARO ESTAR DE ACORDO COM AS INFORMACOES PREENCHIDAS NESTE FORMULARIO, BEM COMO COM O DESTINO DO MEU VEICULO."
         skip 1 line

         print column 008, "DECLARO TER RETIRADO DO INTERIOR DO VEICULO TODOS OS BENS E VALORES PESSOAIS NAO INTEGRADOS AO AUTOMOVEL. "

         if ws.ciaempcod is null or ws.ciaempcod = 1 then  ## psi 205206
            print column 008, "FICA A  PORTO SEGURO  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
         else
            if ws.ciaempcod = 35 then
               print column 008, "FICA A  AZUL SEGUROS  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
            else
               if ws.ciaempcod = 84 then
                  print column 008, "FICA A  ITAU AUTO E RESIDENCIA  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
               else  #--> PSI-2013-06224/PR
                  if ws.ciaempcod = 43 and l_psaerrcod = 0
                     then
                     print column 008, "FICA O SERVICOS AVULSOS PORTO SEGURO ISENTO DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
                  end if
               end if
            end if 
         end if

         skip 1 line

         print column 017, "(SENHOR CLIENTE, EM CASO DE REMOCAO DO VEICULO, SOMENTE ASSINAR COM A PARTE SUPERIOR PREENCHIDA)"
         skip 2 line

         print column 001, "         _________________________        ____________________________            ________________________________________                 "
         print column 001, "                   R. G.                            DATA/HORA                            ASSINATURA DO RESPONSAVEL                       "
         skip 2 line

         print column 001, "____________________________________________________________________________________________________________________________________"

         print column 027, "DECLARO TER RECEBIDO O VEICULO DESCRITO E ESTAR CIENTE DAS ANOTACOES ACIMA"
         skip 2 lines

         print column 001, "         _________________________        ____________________________            ________________________________________                 "
         print column 001, "                   R. G.                            DATA/HORA                                   ASSINATURA                                 "
         skip 2 lines
      end if

      #------------------------------------------------------------------
      # SINISTRO/PORTO SOCORRO (RAMOS ELEMENTARES)
      #------------------------------------------------------------------
      if ws.atdsrvorg  =   9   or
         ws.atdsrvorg  =   13  then
         print column 001, "___________________________________________________ Servicos Realizados ____________________________________________________________"
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "...................................................................................................................................."
         skip 1 line
         print column 001, "____________________________________________________________________________________________________________________________________"

         print column 003, "DECLARO ESTAR DE ACORDO COM AS INFORMACOES PREENCHIDAS NESTE FORMULARIO, BEM COMO COM OS SERVICOS REALIZADOS DISCRIMINADOS ACIMA."
         skip 1 line

         print column 032, "(SENHOR CLIENTE, SOMENTE ASSINAR COM A PARTE SUPERIOR PREENCHIDA)"
         skip 2 line

         print column 001, "         _________________________        ____________________________            ________________________________________                 "
         print column 001, "                   R. G.                            DATA/HORA                            ASSINATURA DO RESPONSAVEL                       "
         skip 2 line

      end if

      #------------------------------------------------------------------
      # ULTIMA LINHA (GENERICA)
      #------------------------------------------------------------------
      print column 001, "______________________________________________ Para uso exclusivo do Porto Socorro _________________________________________________"

      skip 1 line

      if ws.srvprlflg = "N"  then
         if ws.atdsrvorg =  9   or
            ws.atdsrvorg = 13   then
         else
            print column 001, "TOTAL DE QUILOMETROS PERCORRIDOS....: "
            skip 1 line
         end if

         #  print column 001, "SERAO AGILIZADOS OS PAGAMENTOS CUJAS NOT";
         #  print             "AS FISCAIS SEJAM ENCAMINHADAS JUNTAMENTE";
         #  print             " COM ESTE IMPRESSO TOTALMENTE PREENCHIDO"
      else
         print column 001, "SERVICO PARTICULAR: PAGAMENTO POR CONTA ";
         print             "DO CLIENTE."
      end if

      skip 1 line

      if ws.atdsrvorg =  9   or
         ws.atdsrvorg = 13   then
         #  Residencia nao imprime mensagens
      else
         print column 001, "_____________________________________________________ Informacoes Importantes ______________________________________________________ "
         skip 1 line

         print column 001, "- IMPORTANTE: O PAGAMENTO A PRESTADORES PESSOA ",
                           "FISICA SOMENTE SERAO EFETUADOS COM A ",
                           "INFORMACAO DO NUMERO DO PIS/PASEP OU INSS NO"
         print column 001, "              CORPO DO DOCUMENTO, PERTENCENTE ",
                           "AO EMISSOR DAS NOTAS FISCAIS OU RECIBOS."
         
         case ws.ciaempcod
              
            when 35
              print column 001,
              "- Este serviços  será prestado a   um segurado da Azul Seguros, com pagamento garantido pela Porto   Seguro;"
              print column 001,
              "- Serviços como  este, da Azul Seguros, devem ser fechados/acertados separadamente dos serviços da Porto   Seguro;"
              print column 001,
              "- Serão geradas  automaticamente   ordens de pagamento diferentes para Porto e para a Azul  Seguros;"
              print column 001,
              "- *** ATENÇÃO *** As notas fiscais de serviços da Azul Seguros devem ser separadas das notas fiscais de "
              print column 010,
              "serviços da Porto Seguro;"
              
              skip 1 line
              
              print column 001,
              "+--Dados da Azul Seguros para emissão da nota fiscal-----------------------------------+"
              print column 001,
              "|Razão Social: Azul Cia. de Seguros Gerais            CNPJ: 33.448.150/0002-00|"
              print column 001,
              "|Endereço: Av Paulista,   453 - 16º andar   - Bairro: Centro - São Paulo/SP  - CEP 01311-907|"
              print column 001,
              "|Inscrição Municipal: 11.73.29.0-3 (se houver campo na nota fiscal)                    |"
              print column 001,
              "|Inscrição Estadual: Deixar em branco ou Isento (se houver campo na nota fiscal)       |"
              print column 001,
              "+--------------------------------------------------------------------------------------+"
              
              skip 1 line
              
              print column 001,
              "- As notas fiscais da Azul Seguros devem ser entregues/enviadas ao Porto Socorro (mesmo local que você já envia as NF da Porto Seguro)."
              print column 001,
              "- Em caso de dúvidas sobre a operação: (11) 3366-5571/72 ou porto.socorro@portoseguro.com.br."
              print column 001,
              "- Em caso de dúvidas sobre pagamento: (11) 3366-6068 ou porto.socorro@portoseguro.com.br."
              print column 001,
              "OBS: Se forem cobrados serviços da Porto Seguro   e da Azul Seguros na mesma nota  fiscal,  a área pagadora   devolverá a nota."
              
            when 43   #--> PSI-2013-06224/PR
              if l_psaerrcod = 0
                 then
                 print column 001, "- Este servico sera prestado a um cliente Servicos Avulsos, com pagamento garantido pela Porto Seguro;"
                 print column 001, "- Servicos como este, do Servicos Avulsos Porto Seguro devem ser fechados/acertados separadamente dos servicos da Porto Seguro;"
                 print column 001, "- Serao geradas automaticamente ordens de pagamento diferentes para Porto e para o Servicos Avulsos;"
                 print column 001, "- *** ATENCAO *** As notas fiscais de servicos do Servicos Avulsos devem ser separadas das notas fiscais de servicos da Porto Seguro;"
                 
                 skip 4 lines
                 
                 print column 001, "+--Dados do Servicos Avulsos Porto Seguro para emissao da nota fiscal--------------------+"
                 print column 001, "|Razao Social: Porto Seguro Servicos e Comercio S/A 	CNPJ: 33.448.150/0002-00           |"
                 print column 001, "|Endereco: Rua Guaianases, 1238 - Bairro: Campos Eliseos - Sao Paulo/SP - CEP 01204-001  |"
                 print column 001, "|Inscricao Municipal: 3.742.959-0 (se houver campo na nota fiscal)                       |"
                 print column 001, "|Inscricao Estadual.: 147.785.014.115(se houver campo na nota fiscal)                     |"
                 print column 001, "+----------------------------------------------------------------------------------------+"
                 
                 skip 1 line
                 
                 print column 001, "- As notas fiscais do Servicos Avulsos Porto Seguro devem ser entregues/enviadas ao Porto Socorro (mesmo local que você ja envia as NF da Porto Seguro)."
                 print column 001, "- Em caso de duvidas sobre a operacao: (11) 3366-3055 ou porto.socorro@portoseguro.com.br."
                 print column 001, "- Em caso de duvidas sobre pagamento: (11) 3366-3667 ou 3366-3668 ou porto.socorro@portoseguro.com.br."
                 print column 001, "  OBS: Se forem cobrados servicos da Porto Seguro e do Servicos Avulsos Porto Seguro na mesma nota fiscal, a area pagadora devolvera a nota."
              end if
                    
            when 84
              print column 001,
              "- Este serviços  será prestado a   um segurado da ITAU Auto e RESIDENCIA , com pagamento garantido pela Porto Seguro;"
              print column 001,
              "- Serviços como  este, da ITAU Auto e RESIDENCIA , devem ser fechados/acertados separadamente dos serviços da Porto Seguro;"
              print column 001,
              "- Serão geradas  automaticamente   ordens de pagamento diferentes para Porto e para a ITAU Auto e RESIDENCIA ;"
              print column 001,
              "- *** ATENÇÃO *** As notas fiscais de serviços da ITAU Auto e RESIDENCIA  devem ser separadas das notas fiscais de"
              print column 010,
              "serviços da Porto Seguro;"
              
              skip 1 line
              
              print column 001,
              "+---------------Dados da ITAU Auto e RESIDENCIA  para emissão da nota fiscal-----------+"
              print column 001,
              "|Razão Social: ITAU Seguros de Auto e RESIDENCIA S.A.   CNPJ: 08.816.067/0001-00   |"
              print column 001,
              "|Endereço: Av. Eusébio Matoso,  1375  - Bairro: Butantã  - São Paulo/SP   - CEP 05423-905|"
              print column 001,
              "|Inscrição Municipal: 11.73.29.0-3 (se houver campo na nota fiscal)                |"
              print column 001,
              "|Inscrição Estadual: Deixar em branco ou Isento (se houver campo na nota fiscal)       |"
              print column 001,
              "+--------------------------------------------------------------------------------------+"
              
              skip 1 line
              
              print column 001,
              "- As notas fiscais da ITAU Auto e RESIDENCIA  devem ser entregues/enviadas ao Porto Socorro "
              print column 010,
              "(mesmo local que você já envia as NF da Porto Seguro)."
              print column 001,
              "- Em caso de dúvidas sobre a operação: (11) 3366-5571/72 ou porto.socorro@portoseguro.com.br."
              print column 001,
              "- Em caso de dúvidas sobre pagamento: (11) 3366-6068 ou porto.socorro@portoseguro.com.br."
              print column 001,
              "OBS: Se forem cobrados serviços da Porto Seguro e da ITAU Auto e RESIDENCIA  na mesma nota fiscal, " 
              print column 010,
              "a área pagadora devolverá a nota."
              
         end case 
          
         {### NAO EXCLUI POIS MENSAGENS IRAO RETORNAR CONF.EDUARDO ORI. 29/08/2002 ###

           print column 001, "- RECEBA MAIS RAPIDO O SEU SERVICO, ACERTE O ",
                             "VALOR COM NOSSA CENTRAL DE ATENDIMENTO ",
                             "011 3366-6068, ANTES DE ENVIAR A SUA NOTA FISCAL."
           print column 001, "- EMITIR NF PARA: PORTO SEGURO CIA DE SEGUROS ",
                             "GERAIS CNPJ 61.198.164/0001-60 I.E. ",
                             "108.377.122.112 END.: AV.RIO BRANCO 1489 12.AND."
           print column 001, "  BAIRRO: CAMPOS ELISEOS CIDADE: SAO PAULO - SP."
           print column 001, "- ENVIAR NF PARA: PORTO SEGURO CIA DE SEGUROS ",
                             "GERAIS A/C DEPTO.PORTO SOCORRO CAIXA POSTAL ",
                             "13818 CEP: 01216-970 SAO PAULO-SP."
           print column 001, "- POR DETERMINACAO LEGAL, A PORTO SEGURO NAO ",
                             "PODERA EFETUAR O PAGAMENTO DE NOTAS FISCAIS COM ",
                             "VALORES ILEGIVEIS OU COM RASURAS, AS "
           print column 001, "  QUAIS SERAO DEVOLVIDAS."

           # -- OSF 12718 - Fabrica de Software, Katiucia -- #
           if vl_ligcvntip = 64 then
              print column 001, "- O PAGAMENTO DE SERVICOS DE TAXI ESTA "
                              , "LIMITADO A R$ 500,00 (QUINHENTOS REAIS), "
                              , "MAIS O VALOR DO "
                              , "PEDAGIO. VALORES SUPERIORES DEVEM "
           else
              print column 001, "- O PAGAMENTO DE SERVICOS DE TAXI ESTA "
                              , "LIMITADO A R$ 800,00 (QUINHENTOS REAIS), "
                              , "MAIS O VALOR DO "
                              , "PEDAGIO. VALORES SUPERIORES DEVEM "
           end if
           print column 001, "  SER INFORMADOS DE IMEDIATO AO TELEFONE DE APOIO."
           print column 001, "- CASO NAO CONSIGA CUMPRIR O TEMPO DE PREVISAO ",
                             "SOLICITADO, NOS AVISE DE IMEDIATO ATRAVES DO ",
                             "TELEFONE DE APOIO."

           if ws.asitipcod = 12 then # translado
              print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                "DE R$ 1.500,00 (HUM MIL E QUINHENTOS REAIS)."
           end if
           if ws.asitipcod = 13 then # hospedagem
              if ws.ramcod    = 78    or # transportes
                 ws.ramcod    = 171 then # transportes
                 print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 50,00 ",
                                   "(CINQUENTA REAIS) POR DIA."
              else
                 # -- OSF 12718 - Fabrica de Software, Katiucia -- #
                 if vl_ligcvntip = 64 then
                    print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 100,00 ",
                                      "(CEM REAIS) POR DIA."
                 else
                    print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 150,00 ",
                                      "(CENTO E CINQUENTA REAIS) POR DIA."
                 end if
              end if
           end if
           if ws.asitipcod  =  5   or   # taxi
              ws.asitipcod  = 10   then # aviao
              if ws.ramcod  = 78     or # transportes
                 ws.ramcod  = 171  then # transportes
                 if ws.asimtvcod = 3 then # recup. de veiculos
                    print column 001, "- LIMITE DE R$ 250,00 (DUZENTOS E ",
                                      "CINQUENTA REAIS) PARA RECUPERACAO ",
                                      "DE VEICULOS."
                 else
                    if ws.asimtvcod = 4 then # outras situacoes
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS)."
                    else
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS) PARA ",ws.asimtvdes
                    end if
                 end if
              else
                 if ws.asimtvcod = 3 then # recup. de veiculos
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "DE UMA PASSAGEM AEREA NA CLASSE ECONOMICA."
                 else
                    if ws.asimtvcod = 4 then # outras situacoes
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS)."
                    else
                       # -- OSF 12718 - Fabrica de Software, Katiucia -- #
                       if vl_ligcvntip = 64 then
                          print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS "
                                          , "REAIS) PARA ", ws.asimtvdes,"."
                       else
                          print column 001, "- LIMITE DE R$ 800,00 (OITOCENTOS "
                                          , "REAIS) PARA ", ws.asimtvdes,"."
                       end if
                    end if
                 end if
              end if
           else
              if ws.asitipcod = 11 then # ambulancia
                 if ws.ramcod = 78   or
                    ws.ramcod = 171 then
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "MAXIMO DE R$ 1.000,00 (HUM MIL REAIS)."
                 else
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "MAXIMO DE R$ 2.500,00 (DOIS MIL E ",
                                      "QUINHENTOS REAIS)."
                 end if
              end if
           end if

         ### NAO EXCLUI POIS MENSAGENS IRAO RETORNAR CONF.EDUARDO ORI. 29/08/2002 ###}

      end if

end report  ###  rep_laudo

#-------------------------------------------------#
function cts00m14_busca_especialidade(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvre.atdsrvnum,
         atdsrvano    like datmsrvre.atdsrvano
  end record

  define l_espcod like datmsrvre.espcod,
         l_espdes like dbskesp.espdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   let   l_espcod  =  null
   let   l_espdes  =  null

  let l_espcod = null
  let l_espdes = null

  # --BUSCA O CODIGO DA ESPECIALIDADE
  open c_cts00m14_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts00m14_001 into l_espcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_espcod = null
     else
        error "Erro SELECT c_cts00m14_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "CTS00M14/cts00m14_busca_especialidade() ", lr_parametro.atdsrvnum, "/",
                                                          lr_parametro.atdsrvano sleep 3
     end if
  end if

  # --SE EXISTIR O CODIGO DA ESPECIALIDADE
  if l_espcod is not null then

     # --BUSCA A DESCRICAO DA ESPECIALIDADE
     let l_espdes = cts31g00_descricao_esp(l_espcod, "")

  end if

  return l_espdes

end function
