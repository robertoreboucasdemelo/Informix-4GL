#############################################################################
# Nome do Modulo: CTA01M00                                         Marcelo  #
#                                                                  Gilberto #
# Espelho da apolice - ramo AUTOMOVEL                              Jul/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 07/10/1999  ** ERRO **   Gilberto     Tentar localizar endosso quando for #
#                                       uma apolice coletiva com itens can- #
#                                       celados e FUNAPOL retornar nulos.   #
#---------------------------------------------------------------------------#
# 09/12/1999  PSI 7263-0   Gilberto     Nao exibir solicitante quando nao   #
#                                       estiver em atendimento.             #
#---------------------------------------------------------------------------#
# 23/05/2000  PSI 10861-2  Akio         Exibir o perfil adotado             #
#---------------------------------------------------------------------------#
# 26/05/2000  PSI 10860-0  Akio         Exibir as franquias de vidros       #
#                                       clausulas 071 e X71                 #
#---------------------------------------------------------------------------#
# 28/11/2000  PSI 11831-1  Ruiz         Informar no espelho se e AUTO+VIDA  #
#---------------------------------------------------------------------------#
# 26/03/2001  PSI 124354   Ruiz         Informar no espelho se tem Beneficio#
#                                       ref. a revenda onde comprou o veic. #
#---------------------------------------------------------------------------#
# 28/03/2002  PSI          Ruiz         Informar no espelho se tem direito  #
#                                       a instalacao do ITURAN.             #
#---------------------------------------------------------------------------#
# 23/05/2003  PSI.174050  Aguinaldo C.  Informar no espelho se tem direito  #
#                                       a instalacao do TRACKER.            #
#############################################################################
#===========================================================================#
# Alterado : 23/07/2002 - Celso                                             #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores #
#===========================================================================#
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 07/11/2003  Meta, Robson   PSI172081 Implementar as operacoes verifica a- #
#                            OSF028240 tendimento e inclui atendimento do   #
#                                      novo modulo cta02m20.                #
# ----------  -------------- --------- -------------------------------------#
# 19/11/2003  Meta, Paulo    PSI172057 1) Comparar o Susep informado e o da #
#                            OSF 28991 apolice.                             #
#---------------------------------------------------------------------------#
# 15/10/2004  Katiucia       CT 252794 Trocar global g_corretor.corsussol   #
#                                      pela g_documento.corsus/buscar cornom#
# ----------  -------------- --------- -------------------------------------#
# 25/10/2004  Meta, James    PSI188514 Acrescentar tipo de solicitacao = 8  #
# ----------  -------------- --------- -------------------------------------#
# 22/03/2007         Roberto           Acrescentar novos tipos de categorias#
#                                      Tarifarias                           #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta  Psi 223689 Incluir tratamento de erro com a     #
#                                      global                               #
#---------------------------------------------------------------------------#
# 18/10/2008 Carla Rampazzo Psi 230650 Incluir Nro.de Atendimento na tela   #
#---------------------------------------------------------------------------#
# 08/11/2010 Helder, Meta   PSI-2010-01746-EV Duplicado parte do codigo     #
#                                             que contempla codifica�ao 8001#
#                                             adicionando o let ituran = X3 #
#---------------------------------------------------------------------------#
# 11/06/2013 AS-2013-10854  Humberto Santos  Projeto Tapete Azul-benef�cios #
#---------------------------------------------------------------------------#
# 10/122014  Alice-Fornax   CT-89109 - RDM 46951                            #
#---------------------------------------------------------------------------#
# 01/07/2015 Alberto   Tarifa 04/2015                                       #
#---------------------------------------------------------------------------#
# 30/09/2015 Alberto-Fornax ST-2015-00089 Tarifa 09/2015                    #
#---------------------------------------------------------------------------#
# 07/12/2015 Alberto   Solicitacao 715257 Cibele                            #
#---------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"

 define m_prep_sql   smallint   # PSI172057 - Paulo
 define m_host       like ibpkdbspace.srvnom
#----------------------------#
 function cta01m00_prepara()
#----------------------------#
 define l_sql      char(500)

 let l_sql = ' select corsus, solnom, atlult, cortrftip '
            ,'   from apbmcortrans '
            ,'  where succod = ?    '
            ,'    and aplnumdig = ? '
            ,'    and itmnumdig = ? '

 prepare pcta01m00001 from l_sql
 declare ccta01m00001 cursor for pcta01m00001
#---------------------------
--> Tapete Azul
#--------------------------
  let l_sql = " select segnumdig "
             ," from abbmdoc "
             ," where succod = ? "
             ," and aplnumdig = ? "
             ," and dctnumseq in( select max(dctnumseq) from abbmdoc "
                               ," where succod = ? "
                               ," and aplnumdig = ? ) "
  prepare pcta01m00002 from l_sql
  declare ccta01m00002 cursor with hold for pcta01m00002
  let l_sql = " select cgccpfnum "
             ,"       ,cgcord "
             ,"       ,cgccpfdig "
             ," from gsakseg "
             ," where segnumdig = ? "
  prepare pcta01m00003 from l_sql
  declare ccta01m00003 cursor with hold for pcta01m00003
  let l_sql = " select cpodes "
             ," from datkdominio "  #879765
             ," where cponom = ? "
  prepare pcta01m00004 from l_sql
  declare ccta01m00004 cursor with hold for pcta01m00004
#------------------------------------------------------------
# Host Auto/Central
#------------------------------------------------------------
  let l_sql = " select c18tipcod "
             ,"   from porto@",m_host clipped,":ABBMQUESTIONARIO "
             ,"  where succod = ?  "
             ,"    and aplnumdig = ?  "
             ,"    and itmnumdig = ?  "
             ,"    and dctnumseq = ?  "
  prepare pcta01m00005 from l_sql
  declare ccta01m00005 cursor with hold for pcta01m00005
  let l_sql = " select c18tipcod  "
             ,"   from porto@",m_host clipped,":ABBMQUESTTXT "
             ,"  where succod = ?    "
             ,"    and aplnumdig = ? "
             ,"    and itmnumdig = ? "
             ,"    and dctnumseq = ? "
  prepare pcta01m00006 from l_sql
  declare ccta01m00006 cursor with hold for pcta01m00006

  let l_sql = "  select cbtstt  "
             ,"   from porto@",m_host clipped,":abbmvida2  "
             ,"  where succod = ?     "
             ,"    and aplnumdig = ?  "
             ,"    and itmnumdig = ?  "
             ,"    and  dctnumseq = (select max(dctnumseq)  "
             ,"                        from porto@",m_host clipped,":abbmvida2 "
             ,"                       where succod = ?      "
             ,"                         and aplnumdig = ?   "
             ,"                         and itmnumdig = ? ) "
  prepare pcta01m00007 from l_sql
  declare ccta01m00007 cursor with hold for pcta01m00007
  let l_sql = " select count(cndeslcod)  "
             ,"  from porto@",m_host clipped,":abbmcondesp "
             ," where succod = ?     "
             ,"   and aplnumdig = ?  "
             ,"   and itmnumdig = ?  "
             ,"   and dctnumseq = ?  "
             ,"   and cndeslcod = 50 "
  prepare pcta01m00008 from l_sql
  declare ccta01m00008 cursor with hold for pcta01m00008
 let m_prep_sql = true

end function

#-----------------------------------------------------------
 function cta01m00()
#-----------------------------------------------------------

  define w_log  char(60) ## flexvision

  define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,status          smallint
  end record

 define d_cta01m00     record
    edsnumref          like abamdoc.edsnumref  ,
    edstipdes          like agdktip.edstipdes  ,
    segnumdig          like gsakseg.segnumdig  ,
    segnom             like gsakseg.segnom     ,
    segteltxt          like gsakend.teltxt     ,
    cvnnom             char (25)               ,
    cornom             like gcakcorr.cornom    ,
    corsus             like gcaksusep.corsus   ,
    corteltxt          like gcakfilial.teltxt  ,
    vclmrcnom          like agbkmarca.vclmrcnom,
    vcltipnom          like agbktip.vcltipnom  ,
    vclmdlnom          like agbkveic.vclmdlnom ,
    vclchs             char (20)               ,
    vcllicnum          like abbmveic.vcllicnum ,
    vclanofbc          like abbmveic.vclanofbc ,
    vclanomdl          like abbmveic.vclanomdl ,
    obs                char (13)               ,
    emsdat             like abamapol.emsdat    ,
    viginc             like abamapol.viginc    ,
    vigfnl             like abamapol.vigfnl    ,
    cbtcod             like abbmcasco.cbtcod   ,
    cbtdes             char (19)               ,
    ctgtrfcod          like abbmcasco.ctgtrfcod,
    sitdes             char (15)               ,
    benef              char (09)               ,
    benefx             char (03)               ,
    perfil             char (05)               ,
    ituran             char (09)               ,
    atd                char (20)               ,
    def                char (20)               
 end record

 define ws             record
    segdddcod          like gsakend.dddcod     ,
    cordddcod          like gcakfilial.dddcod  ,
    vclcoddig          like agbkveic.vclcoddig ,
    vclmrccod          like agbkmarca.vclmrccod,
    vcltipcod          like agbktip.vcltipcod  ,
    vclchsinc          like abbmveic.vclchsinc ,
    vclchsfnl          like abbmveic.vclchsfnl ,
    aplstt             like abamapol.aplstt    ,
    itmsttatu          like abbmitem.itmsttatu ,
    cvnnum             like abamapol.cvnnum    ,
    edstip             like abbmdoc.edstip     ,
    edsviginc          like abbmdoc.viginc     ,
    edsvigfnl          like abbmdoc.vigfnl     ,
    clcdat             like abbmcasco.clcdat   ,
    clalclcod          like abbmdoc.clalclcod  ,
    frqclacod          like abbmcasco.frqclacod,
    imsvlr             like abbmcasco.imsvlr   ,
    autrevflg          char (01)               ,
    autrevtxt          char (13)               ,
    plcincflg          smallint                ,
    c18tipcod          like abbmquestionario.c18tipcod,
    cbtstt             like abbmvida2.cbtstt,
    benef              char (01)            ,
    ofnnumdig          like sgokofi.ofnnumdig,
    confirma           char (01),
    vclcircid          like abbmdoc.vclcircid,
    ituran             smallint              ,
    orrdat             like adbmbaixa.orrdat ,
    alerta1            char(75)              ,
    alerta2            char(75)              ,
    qtd_dispo_ativo    integer   # Projeto Instalacao de 2 DAF's em caminhoes
 end record

 define l_prporg    like datmatdlig.prporg,            #PSI172081 - robson
        l_prpnumdig like datmatdlig.prpnumdig          #PSI172081 - robson

 define l_corsus      like apbmcortrans.corsus

 define l_erro        char(60)
       ,l_erro2       char(60)
       ,l_st_erro     smallint
       ,l_msg         char(100)
       ,l_count       smallint

 define l_cty00g00    record
    erro              smallint
   ,mensagem          char(60)
   ,cornomsol         like gcakcorr.cornom
 end record

define lr_retorno   record
       data_calculo date,
       flag_endosso char(01),
       erro         integer,
       clausula     like abbmclaus.clscod
end record
 define l_confirma char(1)


# Humberto Tapete Azul
 define lr_carrinho record
        segnumdig   like abbmdoc.segnumdig,
        cgccpfnum   like gsakseg.cgccpfnum,
        cgcord      like gsakseg.cgcord,
        cgccpfdig   like gsakseg.cgccpfdig,
        cpodes      like iddkdominio.cpodes,
        param       char (12)
 end record
 define l_sqlcode smallint
        initialize  r_gcakfilial.*  to  null

        initialize  d_cta01m00.*  to  null

        initialize  ws.*  to  null

        initialize w_log to null
# Humberto Tapete Azul
 initialize lr_carrinho.* to null
 let lr_carrinho.param = 'tapete_azul'
 let l_sqlcode = 0
 let l_st_erro = 1

  #Chamado 13127781
  let m_host = fun_dba_servidor("EMISAUTO")

  call cta13m00_verifica_status(m_host)
      returning l_st_erro
               ,l_msg
 if l_st_erro = true then
    let m_host = fun_dba_servidor("CT24HS")
 end if
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cta01m00_prepara()
 end if

 open window cta01m00 at 03,02 with form "cta01m00"
                      attribute(form line 1)

 message " Aguarde, formatando os dados..."  attribute(reverse)
#--------------------------------------------------------------------------
# Inicializa variaveis
#--------------------------------------------------------------------------

 initialize d_cta01m00.*  to null
 initialize ws.*          to null

 let ws.plcincflg = true
 let l_prporg    = null                                   #PSI172081 - robson
 let l_prpnumdig = null                                   #PSI172081 - robson


#--------------------------------------------------------------------------
# Ultima situacao da apolice
#--------------------------------------------------------------------------
#display "<339> cta01m00-> Ultima situacao da apolice..."
 call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning g_funapol.*
 if g_funapol.dctnumseq is null  then
    select min(dctnumseq)
      into g_funapol.dctnumseq
      from abbmdoc
     where succod    = g_documento.succod
       and aplnumdig = g_documento.aplnumdig
       and itmnumdig = g_documento.itmnumdig
 end if
#--------------------------------------------------------------------------
# Numero do endosso
#--------------------------------------------------------------------------
#display "<354> cta01m00-> Numero do endosso..."
 select edsnumdig, emsdat
   into d_cta01m00.edsnumref,
        d_cta01m00.emsdat
   from abamdoc
  where abamdoc.succod    =  g_documento.succod      and
        abamdoc.aplnumdig =  g_documento.aplnumdig   and
        abamdoc.dctnumseq =  g_funapol.dctnumseq

 if sqlca.sqlcode = notfound  then
    let d_cta01m00.edsnumref = 0
 end if

#--------------------------------------------------------------------------
# Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
#--------------------------------------------------------------------------
 #display "<370> cta01m00-> Se a ultima situacao nao for encontrada..."
 if g_funapol.resultado = "O"  then
    call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                        g_documento.itmnumdig, d_cta01m00.edsnumref)
              returning g_funapol.*
 end if

#--------------------------------------------------------------------------
# Numero do segurado e tipo de endosso
#--------------------------------------------------------------------------
#display "<380> cta01m00-> Numero do segurado e tipo de endosso ..."
 select segnumdig, edstip, clalclcod,
        viginc   , vigfnl, vclcircid
   into d_cta01m00.segnumdig,
        ws.edstip           ,
        ws.clalclcod        ,
        ws.edsviginc        ,
        ws.edsvigfnl        ,
        ws.vclcircid
   from abbmdoc
  where abbmdoc.succod    =  g_documento.succod      and
        abbmdoc.aplnumdig =  g_documento.aplnumdig   and
        abbmdoc.itmnumdig =  g_documento.itmnumdig   and
        abbmdoc.dctnumseq =  g_funapol.dctnumseq

 if sqlca.sqlcode <> notfound  then
    select edstipdes
      into d_cta01m00.edstipdes
      from agdktip
     where edstip = ws.edstip

#--------------------------------------------------------------------------
# Dados do segurado
#--------------------------------------------------------------------------
#display "<404> cta01m00-> Dados do segurado ..."
    whenever error continue

    select segnom into d_cta01m00.segnom
      from gsakseg
     where gsakseg.segnumdig  =  d_cta01m00.segnumdig

    if sqlca.sqlcode = notfound  then
       let d_cta01m00.segnom = "Segurado nao cadastrado!"
    else
       if sqlca.sqlcode < 0  then
          error "Dados do SEGURADO nao disponiveis no momento!"
       else
          select dddcod, teltxt
            into ws.segdddcod,
                 d_cta01m00.segteltxt
            from gsakend
           where segnumdig = d_cta01m00.segnumdig   and
                 endfld    = "1"

          let d_cta01m00.segteltxt = "(", ws.segdddcod, ") ",
                                      d_cta01m00.segteltxt
       end if
    end if
 else
    error "Documento nao encontrado!"
 end if

#--------------------------------------------------------------------------
# Dados do corretor
#--------------------------------------------------------------------------

 select corsus into d_cta01m00.corsus
   from abamcor
  where succod    = g_documento.succod         and
        aplnumdig = g_documento.aplnumdig      and
        corlidflg = "S"

 if sqlca.sqlcode = notfound   then
    let d_cta01m00.cornom = "Corretor nao cadastrado!"
 else
    if sqlca.sqlcode < 0  then
       error "Dados do CORRETOR nao disponiveis no momento!"
    else
       select cornom
         into d_cta01m00.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     =  d_cta01m00.corsus   and
              gcakcorr.corsuspcp   = gcaksusep.corsuspcp

       if sqlca.sqlcode = notfound   then
          let d_cta01m00.cornom = "Corretor nao cadastrado!"
       end if

       #---> Utilizacao da nova funcao de comissoes p/ enderecamento
       initialize r_gcakfilial.* to null
       call fgckc811(d_cta01m00.corsus)
            returning r_gcakfilial.*
       let ws.cordddcod         = r_gcakfilial.dddcod
       let d_cta01m00.corteltxt = r_gcakfilial.teltxt
       #------------------------------------------------------------

       let d_cta01m00.corteltxt = "(", ws.cordddcod, ") ", d_cta01m00.corteltxt
    end if
 end if

 whenever error stop

#--------------------------------------------------------------------------
# Dados do veiculo
#--------------------------------------------------------------------------
#display "<475> cta01m00-> Dados do veiculo ..."
 select vclcoddig, vclanofbc, vclanomdl,
        vcllicnum, vclchsinc, vclchsfnl
   into ws.vclcoddig        , d_cta01m00.vclanofbc,
        d_cta01m00.vclanomdl, d_cta01m00.vcllicnum,
        ws.vclchsinc        , ws.vclchsfnl
   from abbmveic
  where abbmveic.succod     = g_documento.succod     and
        abbmveic.aplnumdig  = g_documento.aplnumdig  and
        abbmveic.itmnumdig  = g_documento.itmnumdig  and
        abbmveic.dctnumseq  = g_funapol.vclsitatu

 if sqlca.sqlcode = notfound  then
    select vclcoddig, vclanofbc, vclanomdl,
           vcllicnum, vclchsinc, vclchsfnl
      into ws.vclcoddig        , d_cta01m00.vclanofbc,
           d_cta01m00.vclanomdl, d_cta01m00.vcllicnum,
           ws.vclchsinc        , ws.vclchsfnl
      from abbmveic
     where succod    = g_documento.succod       and
           aplnumdig = g_documento.aplnumdig    and
           itmnumdig = g_documento.itmnumdig    and
           dctnumseq = (select max(dctnumseq)
                          from abbmveic
                         where succod    = g_documento.succod     and
                               aplnumdig = g_documento.aplnumdig  and
                               itmnumdig = g_documento.itmnumdig)
 end if

 if sqlca.sqlcode <> notfound  then
    select vclmrccod, vcltipcod, vclmdlnom
      into ws.vclmrccod, ws.vcltipcod, d_cta01m00.vclmdlnom
      from agbkveic
     where agbkveic.vclcoddig = ws.vclcoddig

    select vclmrcnom
      into d_cta01m00.vclmrcnom
      from agbkmarca
     where vclmrccod = ws.vclmrccod

    select vcltipnom
      into d_cta01m00.vcltipnom
      from agbktip
     where vclmrccod = ws.vclmrccod    and
           vcltipcod = ws.vcltipcod

    let d_cta01m00.vclchs  =  ws.vclchsinc clipped, ws.vclchsfnl clipped
 else
    error "Dados do veiculo nao encontrado!"
 end if
 #display "<525> cta01m00-> Dados do Item ..."
#--------------------------------------------------------------------------
# Dados do item
#--------------------------------------------------------------------------

 select itmsttatu
   into ws.itmsttatu
   from abbmitem
  where succod    = g_documento.succod     and
        aplnumdig = g_documento.aplnumdig  and
        itmnumdig = g_documento.itmnumdig

 if sqlca.sqlcode <> notfound  then
    if ws.itmsttatu  = "A"  then
       let d_cta01m00.sitdes = "ATIVA"
    else
       if ws.itmsttatu  = "C"  then
          let d_cta01m00.sitdes = "CANCELADA"
       else
          let d_cta01m00.sitdes = "N/PREVISTO"
       end if
       let ws.plcincflg = false
    end if
 else
    error "Dados do item nao encontrado!"
 end if
 
 #-------------------------------------------- 
 # Recupera o Segmento   
 #-------------------------------------------- 

 call cty31g00_recupera_perfil(g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig)
 returning g_nova.perfil    ,
           g_nova.clscod    ,
           g_nova.dt_cal    ,
           g_nova.vcl0kmflg ,
           g_nova.imsvlr    ,
           g_nova.ctgtrfcod ,    
           g_nova.clalclcod ,
           g_nova.dctsgmcod ,
           g_nova.clisgmcod

#--------------------------------------------------------------------------
# Verifica se apolice tem Beneficio(revenda)
#--------------------------------------------------------------------------
 call fbenefic(g_documento.succod,
               g_documento.aplnumdig,
               g_documento.itmnumdig,
               g_documento.edsnumref) returning ws.benef, ws.ofnnumdig
               
 if g_issk.funmat = 3627 or                          
    g_issk.funmat = 9857 or                         
    g_issk.funmat = 1464 then                       
    #display "<580> cta01m11-> ws.benef >", ws.benef 
 end if                                             
                
 if ws.benef = "S"  then
    call cta01m11(ws.ofnnumdig)
 end if
 #display "<586> cta01m00-> Verificando dispositivos ..."
 let ws.ituran = false
 call fadic005_existe_dispo(ws.vclchsinc        ,
                            ws.vclchsfnl        ,
                            d_cta01m00.vcllicnum,
                            ws.vclcoddig        ,
                            9099)
 returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
if ws.ituran = false then
    call fadic005_existe_dispo (ws.vclchsinc        ,
                                ws.vclchsfnl        ,
                                d_cta01m00.vcllicnum,
                                ws.vclcoddig        ,
                                1333)
      returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo

   if ws.ituran = true then
      let d_cta01m00.ituran = "ITURAN  "
   else
      call fadic005_existe_dispo(ws.vclchsinc        ,
                                 ws.vclchsfnl        ,
                                 d_cta01m00.vcllicnum,
                                 ws.vclcoddig        ,
                                 1546)
      returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo

      if ws.ituran = true then
         let d_cta01m00.ituran = "TRACKER"
      else

         call fadic005_existe_dispo(ws.vclchsinc        ,
                                    ws.vclchsfnl        ,
                                    d_cta01m00.vcllicnum,
                                    ws.vclcoddig        ,
                                    3646)
         returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo  # DAF V

         if ws.ituran = true then
            let d_cta01m00.ituran = "DAF V"
         else
            ##PSI-2010-01746-EV
            call fadic005_existe_dispo(ws.vclchsinc        ,
                                    ws.vclchsfnl        ,
                                    d_cta01m00.vcllicnum,
                                    ws.vclcoddig        ,
                                    8001)
            returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo

            if ws.ituran = true then
               let d_cta01m00.ituran = "RASTR X3"

            else
              call fadic005_existe_dispo(ws.vclchsinc        ,
                                    ws.vclchsfnl        ,
                                    d_cta01m00.vcllicnum,
                                    ws.vclcoddig        ,
                                    8230)
               returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
              if ws.ituran = true then
                 let d_cta01m00.ituran = "DAF VIII"
              end if
            end if
            ##PSI-2010-01746-EV
         end if
      end if
   end if
end if
#--------------------------------------------------------------------------
# Dados do casco
#--------------------------------------------------------------------------
 #display "<656> cta01m00->  Dados do casco ..."
 select cbtcod, ctgtrfcod,
        clcdat, frqclacod,
        imsvlr
   into d_cta01m00.cbtcod,
        d_cta01m00.ctgtrfcod,
        ws.clcdat,
        ws.frqclacod,
        ws.imsvlr
   from abbmcasco
  where abbmcasco.succod    = g_documento.succod     and
        abbmcasco.aplnumdig = g_documento.aplnumdig  and
        abbmcasco.itmnumdig = g_documento.itmnumdig  and
        abbmcasco.dctnumseq = g_funapol.autsitatu
#display "<670> cta01m00-> Sem cobertura CASCO, obter franquia e categoria tarifaria"
#--------------------------------------------------------------------------
# Sem cobertura CASCO, obter franquia e categoria tarifaria a partir de DM
#--------------------------------------------------------------------------

 if sqlca.sqlcode = notfound  then
    select ctgtrfcod, frqclacod, clcdat
      into d_cta01m00.ctgtrfcod,
           ws.frqclacod,
           ws.clcdat
      from abbmdm
     where abbmdm.succod    = g_documento.succod     and
           abbmdm.aplnumdig = g_documento.aplnumdig  and
           abbmdm.itmnumdig = g_documento.itmnumdig  and
           abbmdm.dctnumseq = g_funapol.dmtsitatu
 end if
 if d_cta01m00.cbtcod is null  then
    initialize d_cta01m00.cbtdes to null
 else
    if d_cta01m00.cbtcod = 1  then
       let d_cta01m00.cbtdes = "COMPREENSIVA"
       if ws.imsvlr      is null or
          ws.imsvlr      =  0    then
          initialize d_cta01m00.cbtcod to null
          initialize d_cta01m00.cbtdes to null
       end if
    else
       if d_cta01m00.cbtcod = 2  then
          let d_cta01m00.cbtdes = "INCENDIO/ROUBO"
       else
          if d_cta01m00.cbtcod = 6  then
             let d_cta01m00.cbtdes = "COLISAO"
          else
             if d_cta01m00.cbtcod = 0  then
                let d_cta01m00.cbtdes = "SEM COB. CASCO"
             else
                let d_cta01m00.cbtdes = "** NAO PREVISTA **"
             end if
          end if
       end if
    end if
 end if
 -------[ categorias tarifarias que oferecem desconto ou carro extra ]-----
 let d_cta01m00.benefx = "NAO"
 if d_cta01m00.ctgtrfcod = 10 or
    d_cta01m00.ctgtrfcod = 11 or
    d_cta01m00.ctgtrfcod = 14 or
    d_cta01m00.ctgtrfcod = 15 or
    d_cta01m00.ctgtrfcod = 16 or
    d_cta01m00.ctgtrfcod = 17 or
    d_cta01m00.ctgtrfcod = 18 or
    d_cta01m00.ctgtrfcod = 19 or
    d_cta01m00.ctgtrfcod = 20 or
    d_cta01m00.ctgtrfcod = 21 or
    d_cta01m00.ctgtrfcod = 22 or
    d_cta01m00.ctgtrfcod = 23 or
    d_cta01m00.ctgtrfcod = 30 or
    d_cta01m00.ctgtrfcod = 31 or
    d_cta01m00.ctgtrfcod = 72 or
    d_cta01m00.ctgtrfcod = 73 or
    d_cta01m00.ctgtrfcod = 80 or
    d_cta01m00.ctgtrfcod = 81 or
    d_cta01m00.ctgtrfcod = 82 or
    d_cta01m00.ctgtrfcod = 83 or
    d_cta01m00.ctgtrfcod = 84 or
    d_cta01m00.ctgtrfcod = 85 then
    let d_cta01m00.benefx = "SIM"
 end if
 if (d_cta01m00.ctgtrfcod = 30  or   # moto
     d_cta01m00.ctgtrfcod = 31) and
    (d_cta01m00.cbtcod    = 01  and  # cobertura compreensiva
     ws.clalclcod         = 11) then # classe de localizacao sao paulo
     let d_cta01m00.benefx = "SIM"
 end if
#--------------------------------------------------------------------------
# Convenio e vigencia da apolice
#--------------------------------------------------------------------------
#display "<747> cta01m00-> Convenio e vigencia da apolice"
 select cvnnum, aplstt, viginc, vigfnl
   into ws.cvnnum         ,
        ws.aplstt         ,
        d_cta01m00.viginc ,
        d_cta01m00.vigfnl
   from abamapol
  where abamapol.succod    = g_documento.succod     and
        abamapol.aplnumdig = g_documento.aplnumdig

 if ws.aplstt  = "C"  then
    let d_cta01m00.sitdes = "CANCELADA"
    let ws.plcincflg = false
 end if

 if ws.cvnnum is not null  then
    select cpodes into d_cta01m00.cvnnom
      from datkdominio
     where cponom = "cvnnum"  and
           cpocod = ws.cvnnum
 end if

 # Verifica se o Convenio e do Itau

 if ws.cvnnum = 105 then

  #call cts08g01("A","N"," *CONVENIO ITAU* ",
  #                      "Esta e uma ap�lice do conv�nio Ita� .",
  #                      "Observe os procedimentos diferenciados",
  #                      "a seguir e atrav�s do F1.")
  call cts08g01("A","N","* Aten��o ap�lice do Conv�nio Ita� *",
                        "Observe os procedimentos na Base do ",
                        "conhecimento.Comunidade Central 24 ",
                        "horas / Conv�nios / Conv�nio Marcep")                
       returning ws.confirma

  end if

#--------------------------------------------------------------------------
# Confere convenio escolhido pelo atendente
#--------------------------------------------------------------------------
 if g_issk.funmat = 601566 then
    #display "cta01m00 - ws.cvnnum = ", ws.cvnnum
    #display "ANTES    - g_documento.ligcvntip = ", g_documento.ligcvntip
    #display "convenio - ", d_cta01m00.cvnnom
 end if

 if ws.cvnnum <> g_documento.ligcvntip  then
    select cpocod from datkdominio
     where cponom = "ligcvntip"  and
           cpocod = ws.cvnnum

    if sqlca.sqlcode = 0  then
       let g_documento.ligcvntip = ws.cvnnum
    end if
 end if
 if g_issk.funmat = 601566 then
    #display "cta01m00 - ws.cvnnum = ", ws.cvnnum
    #display "         - g_documento.ligcvntip = ", g_documento.ligcvntip
    #display "convenio - ", d_cta01m00.cvnnom
 end if

#--------------------------------------------------------------------------
# Carrega o perfil
#--------------------------------------------------------------------------
#display "<812> cta01m00-> ccta01m00005 <ABBMQUESTIONARIO>"
open ccta01m00005 using g_documento.succod
                       ,g_documento.aplnumdig
                       ,g_documento.itmnumdig
                       ,g_funapol.dctnumseq
  fetch ccta01m00005 into ws.c18tipcod
   if  sqlca.sqlcode = 0  then
       let d_cta01m00.perfil = "PPPPP"
   else
    if  sqlca.sqlcode = 100  then
      #display "<822> cta01m00-> ccta01m00006 <ABBMQUESTTXT>"	
      open ccta01m00006 using  g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,g_funapol.dctnumseq
        fetch ccta01m00006 into ws.c18tipcod
          if  sqlca.sqlcode = 0  then
              let d_cta01m00.perfil = "PPPPP"
          else
           if  sqlca.sqlcode = 100  then
               let d_cta01m00.perfil = "?????"
           else
               let d_cta01m00.perfil = "?????"
           end if
          end if
    else
        let d_cta01m00.perfil = "?????"
    end if
   end if

   if  d_cta01m00.perfil = "PPPPP"  then
       let d_cta01m00.perfil = " SIM "
   else
       let d_cta01m00.perfil = " NAO "
   end if

#--------------------------------------------------------------------------
# Auto Revendas
#--------------------------------------------------------------------------

 let ws.autrevflg = "N"

 whenever error continue

 {select cndeslcod from abbmcondesp
  where abbmcondesp.succod    = g_documento.succod     and
        abbmcondesp.aplnumdig = g_documento.aplnumdig  and
        abbmcondesp.itmnumdig = g_documento.itmnumdig  and
        abbmcondesp.dctnumseq = g_funapol.dctnumseq    and
        abbmcondesp.cndeslcod = 50}
  #display "<862> cta01m00-> ccta01m00006 <abbmcondesp> "
  open ccta01m00008 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,g_funapol.dctnumseq
   fetch ccta01m00008 into l_count

 if l_count > 0  then
    let ws.autrevflg = "S"
    let ws.autrevtxt = "AUTO REVENDAS"
 {else
    if sqlca.sqlcode < 0  then
       error "Informacao sobre AUTO REVENDAS nao disponivel no momento!"
    end if}
 end if
 whenever error stop

 ----------[ alertas para o atendente referente as suseps clara ]-------------
 case d_cta01m00.corsus
    when "P5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um FUNCIONARIO  ",
                      "da PORTO SEGURO.                        ",
                      "")
            returning ws.confirma
    when "X5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um FAMILIAR  de ",
                      "um FUNCIONARIO da PORTO SEGURO.         ",
                      "")
            returning ws.confirma
    when "M5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um FAMILIAR  de ",
                      "um FUNCIONARIO da PORTO SEGURO.         ",
                      "")
            returning ws.confirma
    when "H5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um PRESTADOR de ",
                      "SERVICOS da PORTO SEGURO.               ",
                      "")
            returning ws.confirma
    when "G5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um GERENTE ou   ",
                      "DIRETOR da PORTO SEGURO.                ",
                      "")
            returning ws.confirma
 end case

  # ---> CHAMA TELA DE PROCEDIMENTOS PARA ATENDIMENTO
  message " Aguarde, verificando procedimentos... " attribute (reverse)
  call cts14g00("",
                g_documento.ramcod,
                g_documento.succod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                "",
                "",
                "N",
                "2099-12-31 23:00")
  message "" 
  
 

#--------------------------------------------------------------------------
# Exibe dados na tela
#--------------------------------------------------------------------------

 display by name g_documento.atdnum attribute(reverse)
 display by name g_documento.succod
 display by name g_documento.aplnumdig
 display by name g_documento.itmnumdig
 display by name d_cta01m00.edsnumref

 if g_documento.solnom is not null and g_documento.solnom <> " " then
    display by name g_documento.solnom attribute(reverse)
 end if

 display by name d_cta01m00.*
 display by name d_cta01m00.cbtcod attribute(reverse)
 display by name d_cta01m00.cbtdes attribute(reverse)
 display by name d_cta01m00.benefx attribute(reverse)
 
 if ws.autrevtxt is not null   then
    display by name ws.autrevtxt  attribute(reverse)
 end if

 if d_cta01m00.vigfnl < today   then
    display by name d_cta01m00.viginc thru d_cta01m00.vigfnl attribute(reverse)
    let d_cta01m00.sitdes = " VENCIDA"
    let ws.plcincflg = false
 end if

 if d_cta01m00.benef is not null then
    display by name d_cta01m00.benef attribute(reverse)
 end if
 if d_cta01m00.ituran is not null then
    display by name d_cta01m00.ituran attribute(reverse)
 end if

 display by name d_cta01m00.sitdes  attribute(reverse)

 if d_cta01m00.cvnnom is not null  then
    let d_cta01m00.cvnnom = upshift(d_cta01m00.cvnnom)
    display by name d_cta01m00.cvnnom  attribute(reverse)
 end if

#--------------------------------------------------#
# PSI172081 - Identifica atendimento em duplicidade       #PSI172081 - robson - inicio
#--------------------------------------------------#

 if g_documento.succod    is not null and
    g_documento.ramcod    is not null and
    g_documento.aplnumdig is not null and
    g_documento.itmnumdig is not null then
    if g_documento.apoio <> 'S' or
       g_documento.apoio is null then
       call cta02m20(g_documento.succod,    g_documento.ramcod,
                     g_documento.aplnumdig, g_documento.itmnumdig,
                     l_prporg, l_prpnumdig )
    end if
 end if                                                   #PSI172081 - robson - fim

 if g_documento.c24soltipcod = 2 or
    g_documento.c24soltipcod = 8 then
    let  l_corsus = null
    open ccta01m00001 using g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
    whenever error continue
    fetch ccta01m00001 into l_corsus
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          error 'Erro SELECT ccta01m00001:' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error 'cta01m00() / ', g_documento.succod,' / ', g_documento.aplnumdig,' / ', g_documento.itmnumdig sleep 2
          let int_flag = false
          close window cta01m00
          return
       end if
    end if
    if l_corsus is not null then
       display "CARTA TRANSFERENCIA" at 08,57   attribute(reverse)
    end if

    # -- CT 252794 - Katiucia -- #
    if g_documento.corsus <> d_cta01m00.corsus then
       if l_corsus is null or
         (l_corsus <> g_documento.corsus and
          l_corsus <> d_cta01m00.corsus) then
          initialize l_cty00g00.* to null
          call cty00g00_nome_corretor ( g_documento.corsus )
               returning l_cty00g00.erro
                        ,l_cty00g00.mensagem
                        ,l_cty00g00.cornomsol

          let l_erro  = "INF: ",g_documento.corsus," - ",l_cty00g00.cornomsol
          let l_erro2 = "APL: ",d_cta01m00.corsus," - ",d_cta01m00.cornom
          call cts08g01("A","N","SUSEPs NAO CONFEREM",l_erro,l_erro2,"")
               returning  ws.confirma
       end if
    end if
    let g_corretor.corsusapl = d_cta01m00.corsus
    let g_corretor.cornomapl = d_cta01m00.cornom
 end if

#--------------------------------------------------------------------------
# verifica se apolice e de auto + vida
#--------------------------------------------------------------------------
  {select cbtstt
      into ws.cbtstt
      from abbmvida2
      where  succod    = g_documento.succod
        and  aplnumdig = g_documento.aplnumdig
        and  itmnumdig = g_documento.itmnumdig
        and  dctnumseq =
            (select max(dctnumseq)
                from abbmvida2
               where succod     = g_documento.succod
                 and aplnumdig  = g_documento.aplnumdig
                 and  itmnumdig = g_documento.itmnumdig)}
  #display "<1045> cta01m00-> ccta01m00006 <abbmvida2> "               
  open ccta01m00007 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
    fetch ccta01m00007 into ws.cbtstt
  if sqlca.sqlcode    =   0   and
     ws.cbtstt        =  "A"  then
     let d_cta01m00.obs = " AUTO + VIDA "
     display by name d_cta01m00.obs     attribute(reverse)
  end if 
  
  
         
   #--------------------------------------------     
   # Verifica se o Atendimento e Auto Premium        
   #--------------------------------------------     
                                                    
   call cty31g00_recupera_descricao_premium()       
   returning d_cta01m00.atd                         
    
    
   if d_cta01m00.atd is not null then                                                            
      display by name d_cta01m00.atd attribute(reverse)
   end if   
   
   
   #-------------------------------------------------            
   # Verifica se a Apolice e de Deficiente Fisico            
   #-------------------------------------------------         
                                                         
   call cty31g00_recupera_descricao_fisico_apolice(g_documento.succod    ,
                                                   g_documento.aplnumdig ,
                                                   g_documento.itmnumdig )            
   returning d_cta01m00.def                             
                                                         
                                                         
   if d_cta01m00.def is not null then                    
      display by name d_cta01m00.def attribute(reverse)     
   end if                                                   
   
     
 
   #--------------------------------------------   
   # Valida Fabricacao      
   #--------------------------------------------   
  
   if ws.benef <> "S" then   
   
      call cta13m00_valida_fabricacao(g_documento.succod    
                                     ,g_documento.aplnumdig 
                                     ,g_documento.itmnumdig
                                     ,g_funapol.dctnumseq
                                     ,1)                               
      returning ws.alerta1, ws.alerta2  
   
   end if                                 
                                    
#-------------------------------------------------------------
# Humberto Santos
# Tapete Azul
#-------------------------------------------------------------
	   open ccta01m00002 using g_documento.succod,
	                           g_documento.aplnumdig,
	                           g_documento.succod,
	                           g_documento.aplnumdig
	    whenever error continue
	    fetch ccta01m00002 into lr_carrinho.segnumdig
	    whenever error stop
	  close ccta01m00002
    open ccta01m00003 using lr_carrinho.segnumdig
       whenever error continue
         fetch ccta01m00003 into lr_carrinho.cgccpfnum,
                                 lr_carrinho.cgcord,
                                 lr_carrinho.cgccpfdig
       whenever error stop
    close ccta01m00003
    open ccta01m00004 using lr_carrinho.param
     whenever error continue
     fetch ccta01m00004 into lr_carrinho.cpodes
     whenever error stop
    close ccta01m00004
     call osgtf550_busca_fator_cliente(lr_carrinho.cgccpfnum
                                      ,lr_carrinho.cgcord
                                      ,lr_carrinho.cgccpfdig
                                      ,1)
       returning l_sqlcode
 if l_sqlcode = 0  and ga_gsakhstftr[1].cliprdqtd >= lr_carrinho.cpodes then
      call cts08g01("A", "N"," ",
                    "CLIENTE COM DIREITO A CORTESIA ",
                    "DE SERVI�OS/BENEFICIOS"," ")
      returning l_confirma
 end if
#--------------------------------------------------------------------------
# Marcos Goes
# PSI-2011-03410-EV
# Verifica outros documentos (AUTO ou RE) para o segurado
#--------------------------------------------------------------------------

   if cty15g00_verifica_documento(g_documento.succod
                                 ,g_documento.ramcod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,""
                                 ,""
                                 ,"") then

      call cts08g01("A", "N",
                    " ",
                    "CLIENTE COM OUTROS SEGUROS ATIVOS.",
                    "CONSULTE (F1) - CLIENTES!",
                    " ")
      returning l_confirma

   end if

#--------------------------------------------------------------------------
# Exibe tela de clausulas e opcoes disponiveis
#--------------------------------------------------------------------------

 ## Alberto Sem Nome - Pegar hora com segundos 1

 let g_monitor.horafnl   = current
 let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

 if  g_monitor.intervalo is null or
     g_monitor.intervalo = ""    or
     g_monitor.intervalo = " "   or
     g_monitor.intervalo < "0:00:00.000" then
     let g_monitor.intervalo = "0:00:00.999"
 end if

 let  g_monitor.txt = "ESPELHO DO DOCUMENTO|", g_monitor.intervalo,"|",
                      g_issk.funmat clipped ,"|",
                      g_documento.ramcod clipped ,"|",
                      g_documento.succod clipped ,"|",
                      g_documento.aplnumdig clipped ,"|",
                      g_documento.itmnumdig

 call errorlog (g_monitor.txt)

 let w_log = f_path("ONLTEL","LOG")
 if w_log is null then
    let w_log = "."
 end if

 let w_log  = w_log  clipped,"/dat_ctg2.log"

 call startlog(w_log)
 call errorlog (g_monitor.txt)

 let w_log = " "

 let w_log = f_path("ONLTEL","LOG")
 if w_log is null then
    let w_log = "."
 end if
 let w_log  = w_log  clipped,"/dat_ctg18.log"

 call startlog(w_log)

 if d_cta01m00.vcllicnum is not null  and
    d_cta01m00.vcllicnum <> " "       then
    let ws.plcincflg = false
 end if


 call cta01m02(ws.cvnnum   , ws.clcdat   , d_cta01m00.ctgtrfcod,
               ws.clalclcod, ws.frqclacod, ws.edsviginc,
               ws.edsvigfnl, ws.autrevflg, ws.plcincflg,
               d_cta01m00.cbtcod,
               ws.vclmrccod,
               ws.vcltipcod,
               ws.vclcoddig,
               d_cta01m00.vclanomdl,
               ws.vclcircid                              )


 close window cta01m00

 let int_flag = false

end function  ###  cta01m00
