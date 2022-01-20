#############################################################################
# Nome do Modulo: BDATR082                                         Gilberto #
#                                                                  Wagner   #
# Envia por e-mail controle de servicos Porto Residencia           Fev/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 04/12/2001  PSI 13552-6  Wagner       Relatorio de diario para mensal.    #
#---------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/ #
#                                       Roberto Costa.                      #
#---------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 define ws_datade     date
 define ws_dataate    date
 define ws_auxdat     char (10)

 define ml_tpdocto  char(15)

 main
    call bdatr082_cria_log()
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    call bdatr082()
 end main

#---------------------------------------------------------------
 function bdatr082()
#---------------------------------------------------------------

 define d_bdatr082    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    clscod            char (04),
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    lgdnom            like datmlcl.lgdnom,
    brrnom            like datmlcl.brrnom,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    lclltt            like datmlcl.lclltt,
    lcllgt            like datmlcl.lcllgt,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    atddfttxt         like datmservico.atddfttxt,
    asitipabvdes      like datkasitip.asitipabvdes,
    atdetpdat_aci     like datmsrvacp.atdetpdat,
    atdetphor_aci     like datmsrvacp.atdetphor,
    pstcoddig_aci     like datmsrvacp.pstcoddig,
    nomrazsoc_aci     like dpaksocor.nomrazsoc,
    atdetpdat_ret     like datmsrvacp.atdetpdat,
    atdetphor_ret     like datmsrvacp.atdetphor,
    pstcoddig_ret     like datmsrvacp.pstcoddig,
    nomrazsoc_ret     like dpaksocor.nomrazsoc,
    reclama           char (08) ,
    crtnum            like datrsrvsau.crtnum
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    asitipcod         like datmservico.asitipcod,
    atdetpcod         like datmsrvacp.atdetpcod,
    atdetpdat         like datmsrvacp.atdetpdat,
    atdetphor         like datmsrvacp.atdetphor,
    pstcoddig         like datmsrvacp.pstcoddig,
    c24astcod         like datmligacao.c24astcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    comando           char (400),
    etpflg            smallint,
    sqlcode           integer
 end record

 define l_assunto     char(100),
        l_erro_envio  smallint

 initialize d_bdatr082.*  to null
 initialize ws.*          to null


 #---------------------------------------------------------------
 # Preparando SQL  LOCAL
 #---------------------------------------------------------------
 let ws.comando  = "select lgdnom,  brrnom,  cidnom, ",
                   "       ufdcod,  lclltt,  lcllgt  ",
                   "  from datmlcl       ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and c24endtip = 1 "
 prepare sel_datmlcl from ws.comando
 declare c_datmlcl cursor for sel_datmlcl

 #--------------------------------------------------------------------
 # Preparando SQL PRESTADOR
 #--------------------------------------------------------------------
 let ws.comando  = "select nomrazsoc     ",
                   "  from dpaksocor     ",
                   " where pstcoddig = ? "
 prepare sel_dpaksocor from ws.comando
 declare c_dpaksocor cursor for sel_dpaksocor

 #--------------------------------------------------------------------
 # Preparando SQL DESCRICAO TIPO SERVICO
 #--------------------------------------------------------------------
 let ws.comando  = "select srvtipabvdes ",
                   "  from datksrvtip   ",
                   " where atdsrvorg = ? "
 prepare sel_datksrvtip from ws.comando
 declare c_datksrvtip cursor for sel_datksrvtip

 #--------------------------------------------------------------------
 # Preparando SQL DESCRICAO TIPO ASSISTENCIA
 #--------------------------------------------------------------------
 let ws.comando  = "select asitipabvdes ",
                   "  from datkasitip   ",
                   " where asitipcod = ? "
 prepare sel_datkasitip from ws.comando
 declare c_datkasitip cursor for sel_datkasitip

 #--------------------------------------------------------------------
 # Preparando SQL Reclamacao
 #--------------------------------------------------------------------
 let ws.comando  = "select c24astcod ,    atdsrvnum,    atdsrvano," ,
                   "       succod,        ramcod",
                   "  from datrligsau, datmligacao",
                   " where datrligsau.crtnum   = ? ",
                   "   and datmligacao.lignum  = datrligsau.lignum "
 prepare sel_reclama from ws.comando
 declare c_reclama cursor for sel_reclama


 #--------------------------------------------------------------------
 # Preparando SQL Reclamacao do Saude
 #--------------------------------------------------------------------
 let ws.comando  = "select c24astcod ,  atdsrvnum, atdsrvano          ",
                   "  from datrligapol, datmligacao                   ",
                   " where datrligapol.succod    = ?                  ",
                   "   and datrligapol.ramcod    = ?                  ",
                   "   and datrligapol.aplnumdig = ?                  ",
                   "   and datrligapol.itmnumdig = 0                  ",
                   "   and datmligacao.lignum    = datrligapol.lignum "
 prepare sel_reclama1 from ws.comando
 declare c_reclama1 cursor for sel_reclama1

 #--------------------------------------------------------------------
 # Define data parametro
 #--------------------------------------------------------------------
 let ws_auxdat = arg_val(1)

 if ws_auxdat is null  or
    ws_auxdat =  "  "  then
    let ws_auxdat = today
 else
    if length(ws_auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]
 let ws_dataate = ws_auxdat
 let ws_dataate = ws_dataate - 1 units day

 let ws_auxdat   = ws_dataate
 let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]
 let ws_datade  = ws_auxdat


 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01  = ws.dirfisnom clipped, "/RDAT08201.rtf"

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdatr082 cursor for
  select datmservico.atdsrvnum ,
         datmservico.atdsrvano ,
         datmservico.atddat    ,
         datmservico.atdhor    ,
         datmservico.atdsrvorg ,
         datmservico.atddfttxt ,
         datmservico.asitipcod ,
         datrservapol.succod   ,
         datrservapol.ramcod   ,
         datrservapol.aplnumdig,
         datrservapol.itmnumdig,
         datrsrvsau.crtnum
    from datmservico, outer datrservapol,
         outer datrsrvsau
   where datmservico.atddat between ws_datade and ws_dataate
     and datmservico.atdsrvorg    in (9,13)
     and datrservapol.atdsrvnum   = datmservico.atdsrvnum
     and datrservapol.atdsrvano   = datmservico.atdsrvano
     and datrsrvsau.atdsrvnum     = datmservico.atdsrvnum
     and datrsrvsau.atdsrvano     = datmservico.atdsrvano

 start report rel_temp to ws.pathrel01

 foreach c_bdatr082  into  d_bdatr082.atdsrvnum, d_bdatr082.atdsrvano,
                           d_bdatr082.atddat   , d_bdatr082.atdhor,
                           ws.atdsrvorg        , d_bdatr082.atddfttxt,
                           ws.asitipcod        , d_bdatr082.succod,
                           d_bdatr082.ramcod   , d_bdatr082.aplnumdig,
                           d_bdatr082.itmnumdig, d_bdatr082.crtnum

    ##if d_bdatr082.succod    is null  and
    ##   d_bdatr082.aplnumdig is null  and
    ##   d_bdatr082.itmnumdig is null  then
    ##   continue foreach
    ##end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    let ws.etpflg = 0
    declare c_datmsrvacp cursor for
     select atdetpcod, atdetpdat,
            atdetphor, pstcoddig
       from datmsrvacp
      where atdsrvnum  =  d_bdatr082.atdsrvnum
        and atdsrvano  =  d_bdatr082.atdsrvano

    foreach c_datmsrvacp into ws.atdetpcod, ws.atdetpdat,
                              ws.atdetphor, ws.pstcoddig

       if ws.atdetpcod  =  3     or     # servicos etapa acionado
          ws.atdetpcod  =  4     then   # servicos etapa concluida
          let ws.etpflg = 1
          let d_bdatr082.atdetpdat_aci = ws.atdetpdat
          let d_bdatr082.atdetphor_aci = ws.atdetphor
          let d_bdatr082.pstcoddig_aci = ws.pstcoddig
          #------------------------------------------
          # Busca nome prestador
          #------------------------------------------
          open  c_dpaksocor using d_bdatr082.pstcoddig_aci
          fetch c_dpaksocor into  d_bdatr082.nomrazsoc_aci
          close c_dpaksocor
       else
          if ws.atdetpcod = 10   then   # servicos etapa retorno
             let ws.etpflg = 1
             let d_bdatr082.atdetpdat_ret = ws.atdetpdat
             let d_bdatr082.atdetphor_ret = ws.atdetphor
             let d_bdatr082.pstcoddig_ret = ws.pstcoddig
             #------------------------------------------
             # Busca nome prestador
             #------------------------------------------
             open  c_dpaksocor using d_bdatr082.pstcoddig_ret
             fetch c_dpaksocor into  d_bdatr082.nomrazsoc_ret
             close c_dpaksocor
          end if
       end if

    end foreach

    #---------------------------------------------------------------
    # Busca LOCAL
    #---------------------------------------------------------------
    open  c_datmlcl using  d_bdatr082.atdsrvnum, d_bdatr082.atdsrvano
    fetch c_datmlcl into   d_bdatr082.lgdnom, d_bdatr082.brrnom ,
                           d_bdatr082.cidnom, d_bdatr082.ufdcod ,
                           d_bdatr082.lclltt, d_bdatr082.lcllgt
    close c_datmlcl

    #---------------------------------------------------------------
    # Busca Descricao tipo servico
    #---------------------------------------------------------------
    open  c_datksrvtip using ws.atdsrvorg
    fetch c_datksrvtip into  d_bdatr082.srvtipabvdes
    close c_datksrvtip

    #---------------------------------------------------------------
    # Busca descricao tipo assistencia
    #---------------------------------------------------------------
    open  c_datkasitip using ws.asitipcod
    fetch c_datkasitip into  d_bdatr082.asitipabvdes
    close c_datkasitip

    #---------------------------------------------------------------
    # Busca reclamacoes
    #---------------------------------------------------------------

    ## psi202720
    ## Verifica se serviço de Saude
    ## Verifica Tipo de Documento ("APOLICE", "SAUDE", "PROPOSTA", "CONTRATO", "SEMDOCTO" )
    let ml_tpdocto = null
    let ml_tpdocto = cts20g11_identifica_tpdocto(d_bdatr082.atdsrvnum, d_bdatr082.atdsrvano)
    ## psi202720

    if ml_tpdocto = "SAUDE" then

       ## declare c_reclama cursor for
       ##  select c24astcod ,    atdsrvnum,    atdsrvano,
       ##         succod,        ramcod
       ##    from datrligsau, datmligacao
       ##   where datrligsau.crtnum   = d_bdatr082.crtnum
       ##     and datmligacao.lignum  = datrligsau.lignum
       open c_reclama using d_bdatr082.crtnum
       foreach c_reclama into ws.c24astcod,      ws.atdsrvnum,     ws.atdsrvano,
                              d_bdatr082.succod, d_bdatr082.ramcod

       ##let d_bdatr082.reclama  = bdatr082_reclama( ws.c24astcod,
       ##                                            ws.atdsrvnum,
       ##                                            ws.atdsrvano,
       ##                                            d_bdatr082.atdsrvnum,
       ##                                            d_bdatr082.atdsrvano )
       if ws.c24astcod = "REC" then
          if ws.atdsrvnum = d_bdatr082.atdsrvnum and
             ws.atdsrvano = d_bdatr082.atdsrvano then
             let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
                                       ws.c24astcod
          end if
       else

          if ws.c24astcod = "W00" then
             let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
                                       ws.c24astcod
          end if
       end if
       end foreach
    else
       ##declare c_reclama1 cursor for
       ## select c24astcod , atdsrvnum, atdsrvano
       ##   from datrligapol, datmligacao
       ##  where datrligapol.succod    = d_bdatr082.succod
       ##    and datrligapol.ramcod    = d_bdatr082.ramcod
       ##    and datrligapol.aplnumdig = d_bdatr082.aplnumdig
       ##    and datrligapol.itmnumdig = 0
       ##    and datmligacao.lignum    = datrligapol.lignum

       open c_reclama1 using d_bdatr082.succod, d_bdatr082.ramcod, d_bdatr082.aplnumdig
       foreach c_reclama1 into ws.c24astcod, ws.atdsrvnum, ws.atdsrvano

       if ws.c24astcod = "REC" then
          if ws.atdsrvnum = d_bdatr082.atdsrvnum and
             ws.atdsrvano = d_bdatr082.atdsrvano then
             let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
                                       ws.c24astcod
          end if
       else
          if ws.c24astcod = "W00" then
             let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
                                       ws.c24astcod
          end if
       end if
       end foreach
    end if

    ##      if ws.c24astcod = "REC" then
    ##         if ws.atdsrvnum = d_bdatr082.atdsrvnum and
    ##            ws.atdsrvano = d_bdatr082.atdsrvano then
    ##            let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
    ##                                      ws.c24astcod
    ##         end if
    ##      else
    ##         if ws.c24astcod = "W00" then
    ##            let d_bdatr082.reclama  = d_bdatr082.reclama clipped," ",
    ##                                      ws.c24astcod
    ##         end if
    ##      end if
    ##   end foreach

    #---------------------------------------------------------------
    # Busca clausula
    #---------------------------------------------------------------
    let d_bdatr082.clscod = bdatr082_clausulas(d_bdatr082.succod,
                                               d_bdatr082.ramcod,
                                               d_bdatr082.aplnumdig,
                                               d_bdatr082.itmnumdig,
                                               d_bdatr082.crtnum,
                                               ml_tpdocto )

    output to report rel_temp(d_bdatr082.*)

    initialize d_bdatr082.* to null

 end foreach

 finish report rel_temp

 #------------------------------------------------------------------
 # E-MAIL
 #------------------------------------------------------------------
 let l_assunto    = null
 let l_erro_envio = null

 let l_assunto    = "Servicos Porto Residencia Mensal: ", ws_auxdat[4,5], "/",
                                                          ws_auxdat[7,10]
 let l_erro_envio = ctx22g00_envia_email("BDATR082",
                                         l_assunto,
                                         ws.pathrel01)
 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01
    else
       display "Nao existe email cadastrado para o modulo - BDATR082"
    end if
 end if

end function #  bdatr082


#-------------------------------------------------------------------------------
 function bdatr082_clausulas(param)
#-------------------------------------------------------------------------------

 define param    record
    succod       like datrservapol.succod,
    ramcod       like datrservapol.ramcod,
    aplnumdig    like datrservapol.aplnumdig,
    itmnumdig    like datrservapol.aplnumdig,
    crtnum       like datrsrvsau.crtnum,
    saude        char(15)
 end record

 define ws      record
    clscod      like rsdmclaus.clscod      ,
    rsdclscod   like rsdmclaus.clscod      ,
    datclscod   like datrsocntzsrvre.clscod,
    sgrorg      like rsdmdocto.sgrorg      ,
    sgrnumdig   like rsdmdocto.sgrnumdig   ,
    prporg      like rsdmdocto.prporg      ,
    prpnumdig   like rsdmdocto.prpnumdig
 end record

 define w_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

 initialize ws.*  to null

 if param.saude = "SAUDE" then
    select plncod
      into ws.clscod
      from datksegsau
     where crtsaunum = param.crtnum
 else
    if param.succod    is not null  and
       param.ramcod    is not null  and
       param.aplnumdig is not null  then
       if param.ramcod =  31 or
          param.ramcod = 531 then
          call f_funapol_ultima_situacao(param.succod,
                                         param.aplnumdig,
                                         param.itmnumdig)
                               returning w_funapol.*

          declare c_abbmclaus cursor for
           select clscod
             from abbmclaus
            where succod    = param.succod
              and aplnumdig = param.aplnumdig
              and itmnumdig = param.itmnumdig
              and dctnumseq = w_funapol.dctnumseq
              and clscod    in ("033","33R","034", "035","34A","35A","35R","095") ## psi201154

          foreach c_abbmclaus into ws.clscod
             exit foreach
          end foreach

       else
          #---------------------------------------------------------
          # Ramos Elementares
          #---------------------------------------------------------
          select sgrorg    , sgrnumdig
            into ws.sgrorg , ws.sgrnumdig
            from rsamseguro
           where succod    = param.succod
             and ramcod    = param.ramcod
             and aplnumdig = param.aplnumdig

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
                                    and prpstt     in (19,66,88))

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

                   case param.ramcod
                      when 11
                         if (ws.datclscod = 13 or ws.datclscod = "13R") then
                            let ws.clscod = ws.datclscod
                         end if
                      when 111
                         if (ws.datclscod = 13 or ws.datclscod = "13R") then
                            let ws.clscod = ws.datclscod
                         end if
                      when 44
                         if (ws.datclscod = 20  or ws.datclscod = "20R") or
                             ws.datclscod = 21  or
                             ws.datclscod = 22  or
                             ws.datclscod = 23  or
                            (ws.datclscod = 24 or ws.datclscod = "24R") then
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 118
                         if (ws.datclscod = 20    or ws.datclscod = "20R") or
                             ws.datclscod = 21    or
                             ws.datclscod = 22    or
                             ws.datclscod = 23    or
                            (ws.datclscod = 24    or ws.datclscod = "24C"  or ws.datclscod = "24R") or
                             ws.datclscod = 30    or
                            (ws.datclscod = 31    or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                            (ws.datclscod = 32    or ws.datclscod = "32R") or
                            (ws.datclscod = 36    or ws.datclscod = "36R") or
                            (ws.datclscod = 38    or ws.datclscod = "38R") or   #  PSI-230.057 Inicio
                            ws.datclscod = "55"   or ws.datclscod = "56"   or
                            ws.datclscod = "56R"  or ws.datclscod = "56C"  or
                            ws.datclscod = "57"   or ws.datclscod = "57R"  then #  PSI-230.057 Fim
                            #inclusao da cls 36/36R-a pedido Judite-08/05/07
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 45
                         if (ws.datclscod = 10  or ws.datclscod = "10R") or
                            (ws.datclscod = 11  or ws.datclscod = "11R") or
                            (ws.datclscod = 12  or ws.datclscod = "12R") or
                            (ws.datclscod = 13  or ws.datclscod = "13R") then
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 114
                         if (ws.datclscod = 08   or ws.datclscod = "08C"  or ws.datclscod = "08R" or
                             ws.datclscod = "8C" or ws.datclscod = "8R" ) or ## psi211044
                            (ws.datclscod = 10   or ws.datclscod = "10R") or
                            (ws.datclscod = 11   or ws.datclscod = "11R") or
                            (ws.datclscod = 12   or ws.datclscod = "12C"  or ws.datclscod = "12R") or
                            (ws.datclscod = 13   or ws.datclscod = "13R") or
                             ws.datclscod = 30   or
                            (ws.datclscod = 31   or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                            (ws.datclscod = 32   or ws.datclscod = "32R") or
                             ws.datclscod = 39   or
                            (ws.datclscod = 40   or ws.datclscod = "40R") or   #  PSI-230.057 Inicio
                            ws.datclscod = "55"  or ws.datclscod = "56"   or
                            ws.datclscod = "56R" or ws.datclscod = "56C"  or
                            ws.datclscod = "57"  or ws.datclscod = "57R"  then #  PSI-230.057 Fim
                            #inclusao da cls 40/40R-a pedido Neia-07/05/07
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 46
                         if  ws.datclscod = 30  or
                            (ws.datclscod = 31  or ws.datclscod = "31R")  or
                            (ws.datclscod = 32  or ws.datclscod = "32R") then
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 746
                         if  ws.datclscod = 30    or
                            (ws.datclscod = 31    or ws.datclscod = "31C" or ws.datclscod = "31R") or
                            (ws.datclscod = 32    or ws.datclscod = "32R") then
                            if ws.datclscod > ws.clscod  then
                               let ws.clscod = ws.datclscod
                            end if
                         end if
                      when 47
                         if (ws.datclscod = 10  or ws.datclscod = "10R") or
                            (ws.datclscod = 13  or ws.datclscod = "13R") then
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
          end if
       end if
    end if
 end if
 return ws.clscod

end function  ###  bdatr082_clausulas


#---------------------------------------------------------------------------
 report rel_temp(r_temp)
#---------------------------------------------------------------------------

 define r_temp        record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    clscod            char (04),
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    lgdnom            like datmlcl.lgdnom,
    brrnom            like datmlcl.brrnom,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    lclltt            like datmlcl.lclltt,
    lcllgt            like datmlcl.lcllgt,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    atddfttxt         like datmservico.atddfttxt,
    asitipabvdes      like datkasitip.asitipabvdes,
    atdetpdat_aci     like datmsrvacp.atdetpdat,
    atdetphor_aci     like datmsrvacp.atdetphor,
    pstcoddig_aci     like datmsrvacp.pstcoddig,
    nomrazsoc_aci     like dpaksocor.nomrazsoc,
    atdetpdat_ret     like datmsrvacp.atdetpdat,
    atdetphor_ret     like datmsrvacp.atdetphor,
    pstcoddig_ret     like datmsrvacp.pstcoddig,
    nomrazsoc_ret     like dpaksocor.nomrazsoc,
    reclama           char (08),
    crtnum            like datrsrvsau.crtnum
 end record

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
        print column 001, r_temp.atdsrvnum      using "&&&&&&&",  "|",
                          r_temp.atdsrvano      using "&&",       "|",
                          r_temp.atddat         clipped,          "|",
                          r_temp.atdhor         clipped,          "|",
                          r_temp.succod         using "##",       "|",
                          r_temp.ramcod         using "####",     "|",
                          r_temp.clscod         clipped,          "|", #Clausula
                          r_temp.aplnumdig      using "<<<<<<<#", "|",
                          r_temp.itmnumdig      using "<<<<<#",   "|",
                          r_temp.lgdnom         clipped,          "|",
                          r_temp.brrnom         clipped,          "|",
                          r_temp.cidnom         clipped,          "|",
                          r_temp.ufdcod         clipped,          "|",
                          r_temp.lclltt         clipped,          "|",
                          r_temp.lcllgt         clipped,          "|",
                          r_temp.srvtipabvdes   clipped,          "|",
                          r_temp.atddfttxt      clipped,          "|",
                          r_temp.asitipabvdes   clipped,          "|",
                          r_temp.atdetpdat_aci  clipped,          "|",
                          r_temp.atdetphor_aci  clipped,          "|",
                          r_temp.pstcoddig_aci  using "<<<<<#",   "|",
                          r_temp.nomrazsoc_aci  clipped,          "|",
                          r_temp.atdetpdat_ret  clipped,          "|",
                          r_temp.atdetphor_ret  clipped,          "|",
                          r_temp.pstcoddig_ret  using "<<<<<#",   "|",
                          r_temp.nomrazsoc_ret  clipped,          "|",
                          r_temp.reclama        clipped,          "|",
                          r_temp.crtnum         clipped,          "|",
                          ascii(13)

 end report    ### rel_temp

#--------------------------#
function bdatr082_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdatr082.log"

  call startlog(l_path)

end function
