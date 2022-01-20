################################################################################
# Nome do Modulo: cts28m00                                              Ruiz   #
# Laudo - Sinistro de Transportes                                    Ago/2002  #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#----------------------------------------------------------------------------- #
# 22/04/2003  Aguinaldo Costa  PSI.168920     Resolucao 86                     #
#----------------------------------------------------------------------------- #
################################################################################
#                                                                              #
#                       * *       * Alteracoes * * *                           #
#                                                                              #
# Data        Autor Fabrica        Origem    Alteracao                         #
# ----------  -----------------------------------------------------------------#
# 18/09/2003  Meta,Bruno           PSI175552 Inibir linhas 1379 - 1431.        #
#                                  OSF26077                                    #
# -----------------------------------------------------------------------------#
# 18/05/2005  Meta,Tiago Solda     PSI191108 Implementar o codigo da           #
#                                             via(emeviacod)                   #
# ---------------------------------------------------------------------------- #
# 07/02/2006  Priscila          Zeladoria  Buscar data e hora do banco de dados#
#------------------------------------------------------------------------------#
# 19/07/2006 Andrei, Meta                  Migracao de versao do 4gl           #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a     #
#                                         global                               #
# 13/08/2009 Sergio Burini     PSI 244236 Inclusão do Sub-Dairro               #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

  define m_dtresol86  date
  define d_cts28m00   record
         servico      char (13)                    ,
         c24solnom    like datmligacao.c24solnom   ,
         nom          like datmservico.nom         ,
         doctxt       char (30)                    ,
         corsus       like gcaksusep.corsus        ,
         cornom       like gcakcorr.cornom         ,
         cvnnom       char (19)                    ,
         c24astcod    like datkassunto.c24astcod   ,
         c24astdes    char (45)                    ,
         sinrclddd    like sstmstpavs.sinrclddd    ,
         sinrcltel    like sstmstpavs.sinrcltel    ,
         sinavsnum    like sstmstpavs.sinavsnum    ,
         tiposinis    smallint                     ,
         sinntzcod    like sstmstpavs.sinntzcod    ,
         sinntzdes    char (26)                    ,
         dscacidente  char (01)                    ,
         sinocrpainom like sstmstpavs.sinocrpainom ,
         sinocrdat    like sstmstpavs.sinocrdat    ,
         sinocrhor    like sstmstpavs.sinocrhor    ,
         tipotransp   char (01)                    ,
         flgorigdes   char (01)                    ,
         flgbensatg   char (01)                    ,
         flgbenster   char (01)                    ,
         histatd      char (01)                    ,
         atdtxt       char (48)                    ,
         atdlibdat    like datmservico.atdlibdat   ,
         atdlibhor    like datmservico.atdlibhor
  end record

  define a_cts28m00   array[3] of record
         operacao     char (01)
        ,lclidttxt    like datmlcl.lclidttxt
        ,lgdtxt       char (65)
        ,lgdtip       like datmlcl.lgdtip
        ,lgdnom       like datmlcl.lgdnom
        ,lgdnum       like datmlcl.lgdnum
        ,brrnom       like datmlcl.brrnom
        ,lclbrrnom    like datmlcl.lclbrrnom
        ,endzon       like datmlcl.endzon
        ,cidnom       like datmlcl.cidnom
        ,ufdcod       like datmlcl.ufdcod
        ,lgdcep       like datmlcl.lgdcep
        ,lgdcepcmp    like datmlcl.lgdcepcmp
        ,lclltt       like datmlcl.lclltt
        ,lcllgt       like datmlcl.lcllgt
        ,dddcod       like datmlcl.dddcod
        ,lcltelnum    like datmlcl.lcltelnum
        ,lclcttnom    like datmlcl.lclcttnom
        ,lclrefptotxt like datmlcl.lclrefptotxt
        ,c24lclpdrcod like datmlcl.c24lclpdrcod
        ,ofnnumdig    like sgokofi.ofnnumdig
        ,emeviacod    like datmemeviadpt.emeviacod
        ,celteldddcod like datmlcl.celteldddcod
        ,celtelnum    like datmlcl.celtelnum
        ,endcmp       like datmlcl.endcmp
  end record

  define w_cts28m00   record
         lignum       like datrligsrv.lignum       ,
         atdlibflg    like datmservico.atdlibflg   ,
         atdhorpvt    like datmservico.atdhorpvt   ,
         atddatprg    like datmservico.atddatprg   ,
         atdhorprg    like datmservico.atdhorprg   ,
         atdfnlflg    like datmservico.atdfnlflg   ,
         ligcvntip    like datmligacao.ligcvntip   ,
         data         like datmservico.atddat      ,
         hora         like datmservico.atdhor      ,
         funmat       like datmservico.funmat      ,
         c24opemat    like datmservico.c24opemat   ,
         atddat       like datmservico.atddat      ,
         atdhor       like datmservico.atdhor      ,
         atdetpcod    like datmsrvacp.atdetpcod    ,
         trptipflg    like sstmstpavs.trptipflg    ,
         sinavsnum    like sstmstpavs.sinavsnum    ,
         sinavsano    like sstmstpavs.sinavsano    ,
         sgrorg       like sstmstpavs.sgrorg        ,
         sgrnumdig    like sstmstpavs.sgrnumdig     ,
         dctnumseq    like sstmstpavs.dctnumseq     ,
         segnumdig    like sstmstpavs.segnumdig       ,
         atdprinvlcod like datmservico.atdprinvlcod,
         descacidente like sstmstpavs.stpavshsttxt,  # char(264),
         descbensatg  like sstmbnsatg.bnsatgcrgobs, # char(245),
         descbensterc char(206),
         histatd      like sstmprsprctxt.prsprctxt, #char(250),
         sinavsramcod like sstmstpavs.sinavsramcod,
         codpais      char(11),
         despais      char(40),
         --------[ retorno da funcao fsstc010 - tipo transporte ]--------
         vclmrccod      like agbkmarca.vclmrccod,
         vcltipcod      like agbktip.vcltipcod,
         vclcoddig      like agbkveic.vclcoddig,
         cor1           char(10),
         placa1         char(07),
         vclmrccod2     like agbkmarca.vclmrccod,
         vcltipcod2     like agbktip.vcltipcod,
         vclcoddig2     like agbkveic.vclcoddig,
         cor2           char(10),
         placa2         char(07),
         vclmrccod3     like agbkmarca.vclmrccod,
         vcltipcod3     like agbktip.vcltipcod,
         vclcoddig3     like agbkveic.vclcoddig,
         cor3           char(10),
         placa3         char(07),
         motorista      char(40),
         descr1         char(41),
         descr2         char(41),
         descr3         char(41),
         nom_marin      char(40),
         embarcacao     char(50),
         ating_pess     char(01),
         qtd_pess       decimal(3,0),
         aeronave       char(50),
         --------[ retorno da funcao fsstc011 - bens atingidos ]--------
         val_carga      decimal(15,5),
         pct_danos      decimal(7,4),
         prov_soc       char(01),
         ies_guincho    char(01),
         sit_carga      decimal(2,0),
         g_carga        char(255),
         --------[ retorno da funcao fsstc015 - historico atendente]-----
         histatd1       char(255),
         histatd2       char(255),
         histatd3       char(255),
         histatd4       char(255),
         histatd5       char(255),
         --------[ retorno da funcao fsstc016 - dados da viagem    ]-----
         datini         date,
         transp         char(40),
         orguf          char(02),
         orgcid         char(45),
         dstuf          char(02),
         dstcid         char(45),
         orgpais        char(45),
         dstpais        char(45),
         atdrsdflg     like datmservico.atdrsdflg
  end record

  define w_cts28m00h array[5] of record
         histatd       char(255)
  end record

  define arr_aux       smallint

  define aux_libant    like datmservico.atdlibflg,
         aux_atdsrvnum like datmservico.atdsrvnum,
         aux_atdsrvano like datmservico.atdsrvano,
         aux_libhor    char (05)                 ,
         aux_today     char (10)                 ,
         aux_hora      char (05)                 ,
         aux_ano       char (02)

  define m_subbairro array[03] of record
         lclbrrnom   like datmlcl.lclbrrnom
  end record

  define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint

#--------------------------------------------------------------------
 function cts28m00()
#--------------------------------------------------------------------
   define ws           record
          atdetpcod    like datmsrvacp.atdetpcod,
          confirma     char (01),
          grvflg       smallint,
          vclcoddig    like datmservico.vclcoddig,
          vcldes       like datmservico.vcldes,
          vclanomdl    like datmservico.vclanomdl,
          vcllicnum    like datmservico.vcllicnum,
          vclcordes    char (11),
          vclchsinc    like abbmveic.vclchsinc,
          vclchsfnl    like abbmveic.vclchsfnl
   end record

  #--------------------------------#

   define l_data       date,
          l_hora2      datetime hour to minute

	initialize  ws.*  to  null

   let g_documento.atdsrvorg = 16
  #--------------------------------#
   initialize m_subbairro  to null

   for arr_aux = 1 to 3
       initialize a_cts28m00[arr_aux].* to null
   end for
   for arr_aux = 1 to 5
       initialize w_cts28m00h[arr_aux].* to null
   end for

   initialize ws.*         to null
   initialize w_cts28m00.* to null
   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let arr_aux       = null
   let int_flag      = false
   let aux_today     = l_data
   let aux_hora      = l_hora2
   let aux_ano       = aux_today[9,10]

   if g_issk.funmat = 601566 then
      display "============== cts28m00 ========================"
      display "g_documento.succod     = ", g_documento.succod
      display "g_documento.ramcod     = ", g_documento.ramcod
      display "g_documento.aplnumdig  = ", g_documento.aplnumdig
      display "g_documento.itmnumdig  = ", g_documento.itmnumdig
      display "g_issk.maqsgl          = ", g_issk.maqsgl
      display "g_hostname             = ", g_hostname
   end if
   open window cts28m00 at 04,02 with form "cts28m00"
                        attribute(form line 1)

   select grlinf[01,10] into m_dtresol86
      from datkgeral
      where grlchv='ct24resolucao86'

   if g_documento.atdsrvnum is null then
      display "(F1)Help,(F3)Ref,(F5)Espelho,(F6)Hist,(F7)Funcoes" to msgfun
   else
    display "(F1)Help,(F3)Ref,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F9)Conclui" to msgfun
   end if
   initialize d_cts28m00.*,
              w_cts28m00.*,
              aux_libant  to null
   initialize a_cts28m00 to null

   --------------------[ IDENTIFICACAO DO CONVENIO ]-------------------
   let w_cts28m00.ligcvntip = g_documento.ligcvntip

   select cpodes into d_cts28m00.cvnnom
     from datkdominio
    where cponom = "ligcvntip"   and
          cpocod = w_cts28m00.ligcvntip

   if g_documento.atdsrvnum is not null then
      call consulta_cts28m00()

      display by name d_cts28m00.*
      display by name d_cts28m00.c24solnom attribute (reverse)
      display by name d_cts28m00.cvnnom    attribute (reverse)
      display by name a_cts28m00[1].lgdtxt,
                      a_cts28m00[1].lclbrrnom,
                      a_cts28m00[1].cidnom,
                      a_cts28m00[1].ufdcod,
                      a_cts28m00[1].lclrefptotxt,
                      a_cts28m00[1].endzon,
                      a_cts28m00[1].lclcttnom,
                      a_cts28m00[1].endcmp
      if w_cts28m00.atdlibflg = "N"   then
         display by name d_cts28m00.atdlibdat attribute (invisible)
         display by name d_cts28m00.atdlibhor attribute (invisible)
      end if
      if w_cts28m00.atdfnlflg = "S"  then
         error " Atencao! Servico ja' acionado!"
      else
         if g_documento.aplnumdig  is not null   then
            call cts03g00 (5, g_documento.ramcod    ,
                              g_documento.succod    ,
                              g_documento.aplnumdig ,
                              g_documento.itmnumdig ,
                              ""                    ,
                              g_documento.atdsrvnum ,
                              g_documento.atdsrvano )
         end if
      end if

      let ws.grvflg = modifica_cts28m00()

      if ws.grvflg = false  then
         initialize g_documento.acao to null
      end if
      if g_documento.acao is not null and
         g_documento.acao <> "INC"    then
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat        , aux_today  ,aux_hora)
         let g_rec_his = true
      end if
   else
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         let d_cts28m00.doctxt = "Apolice.: ", g_documento.succod  using "&&",
                                          " ", g_documento.ramcod  using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"
         call cts05g00 (g_documento.succod   ,
                        g_documento.ramcod   ,
                        g_documento.aplnumdig,
                        g_documento.itmnumdig)
              returning d_cts28m00.nom      ,
                        d_cts28m00.corsus   ,
                        d_cts28m00.cornom   ,
                        d_cts28m00.cvnnom   ,
                        ws.vclcoddig        ,
                        ws.vcldes           ,
                        ws.vclanomdl        ,
                        ws.vcllicnum        ,
                        ws.vclchsinc        ,
                        ws.vclchsfnl        ,
                        ws.vclcordes
      end if
      if g_documento.prporg    is not null  and
         g_documento.prpnumdig is not null  then


         call figrc072_setTratarIsolamento() --> 223689

         call cts05g04 (g_documento.prporg   ,
                        g_documento.prpnumdig)
              returning d_cts28m00.nom      ,
                        d_cts28m00.corsus   ,
                        d_cts28m00.cornom   ,
                        d_cts28m00.cvnnom   ,
                        ws.vclcoddig,
                        ws.vcldes   ,
                        ws.vclanomdl,
                        ws.vcllicnum,
                        ws.vclcordes
         if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
            return
         end if                           --> 223689

         let d_cts28m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                   " ", g_documento.prpnumdig using "<<<<<<<& &"
      end if
      let d_cts28m00.c24astcod   = g_documento.c24astcod
      let d_cts28m00.c24solnom   = g_documento.solnom

      let d_cts28m00.c24astdes = c24geral8(d_cts28m00.c24astcod)

      display by name d_cts28m00.*
      display by name d_cts28m00.c24solnom attribute (reverse)
      display by name d_cts28m00.cvnnom    attribute (reverse)
     #-------------------------------------------------------------------
     #  Verifica se ja' houve solicitacao de servico para apolice
     #-------------------------------------------------------------------
      if  g_documento.succod    is not null   and
          g_documento.ramcod    is not null   and
          g_documento.aplnumdig is not null   then
          call cts03g00 (5, g_documento.ramcod    ,
                            g_documento.succod    ,
                            g_documento.aplnumdig ,
                            g_documento.itmnumdig ,
                            ""                    ,
                            g_documento.atdsrvnum ,
                            g_documento.atdsrvano )
      end if

      let ws.grvflg = inclui_cts28m00()

      if ws.grvflg = true  then
    ###  call cts10n00(aux_atdsrvnum, aux_atdsrvano, w_cts28m00.funmat,
    ###                w_cts28m00.data      , w_cts28m00.hora)
         ----------[ VERIFICA ACIONAMENTO SERVICO PELO ATENDENTE ]----------
       # if d_cts28m00.imdsrvflg =  "S"     and        # servico imediato
       #    d_cts28m00.atdlibflg =  "S"     and        # servico liberado
       #    d_cts28m00.prslocflg =  "N"     and        # prestador no local
       #    d_cts28m00.frmflg    =  "N"     then       # formulario
       #    if g_issk.dptsgl <> "ct24hs"    and        # usuario
       #       g_issk.dptsgl <> "psocor"    and        # nao e'  P.Soc.,
       #       g_issk.dptsgl <> "desenv"    then       # Central ou Desenv.
       #    else
       #       call cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?",
       #                     "")
       #           returning ws.confirma
       #       if ws.confirma  =  "S"   then
       #          call cts00m02(aux_atdsrvnum, aux_atdsrvano, 1 )
       #       end if
       #    end if
       # end if
         ----------[ VERIFICA ETAPA PARA DESBLOQUEIO DO SERVICO ]-------
         select atdetpcod
           into ws.atdetpcod
           from datmsrvacp
          where atdsrvnum = aux_atdsrvnum
            and atdsrvano = aux_atdsrvano
            and atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp
                              where atdsrvnum = aux_atdsrvnum
                                and atdsrvano = aux_atdsrvano)
         if ws.atdetpcod    <> 4   and    # servico etapa concluida
            ws.atdetpcod    <> 5   then   # servico etapa cancelado
            --------------[ DESBLOQUEIO DO SERVICO ]-------------
            update datmservico set c24opemat = null
                             where atdsrvnum = aux_atdsrvnum
                               and atdsrvano = aux_atdsrvano
            if sqlca.sqlcode <> 0  then
               error " Erro (", sqlca.sqlcode, ") no desbloqueio do",
                     " servico. AVISE A INFORMATICA!"
               prompt "" for char ws.confirma
            else
               call cts00g07_apos_servdesbloqueia(aux_atdsrvnum,aux_atdsrvano)
            end if
         end if
      end if
   end if
   clear form
   close window cts28m00
 end function   ### cts28m00

#--------------------------------------------------------------------
 function consulta_cts28m00()
#--------------------------------------------------------------------
   define ws            record
          atdsrvnum     like datmservico.atdsrvnum ,
          atdsrvano     like datmservico.atdsrvano ,
          funmat        like datmservico.funmat   ,
          funnom        like isskfunc.funnom       ,
          dptsgl        like isskfunc.dptsgl       ,
          sqlerro       integer                    ,
          c24soltipcod  like datmligacao.c24soltipcod,
          proced        char(09),
	  succod            like datrservapol.succod   ,
	  ramcod            like datrservapol.ramcod   ,
	  aplnumdig         like datrservapol.aplnumdig,
	  itmnumdig         like datrservapol.itmnumdig,
	  edsnumref         like datrservapol.edsnumref,
	  prporg            like datrligprp.prporg,
	  prpnumdig         like datrligprp.prpnumdig,
	  fcapcorg          like datrligpac.fcapacorg,
	  fcapacnum         like datrligpac.fcapacnum
   end record


	initialize  ws.*  to  null

   initialize ws.*  to null

   -------------------------[ DADOS DO AVISO - SSTMSTPAVS ]---------------
   select sinavsnum
      into w_cts28m00.sinavsnum
      from datrligtrp
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano

   select sinavsramcod,
          sinavsano,
          sinrclddd,
          sinrcltel,
          sinntzcod,
          stpavshsttxt,
          trptipflg,
          sinocrpainom,
          stpavstip
     into w_cts28m00.sinavsramcod,
          w_cts28m00.sinavsano,
          d_cts28m00.sinrclddd,
          d_cts28m00.sinrcltel,
          d_cts28m00.sinntzcod,
          w_cts28m00.descacidente,
          d_cts28m00.tipotransp,
          d_cts28m00.sinocrpainom,
          ws.c24soltipcod
     from sstmstpavs
    where sinavsnum = w_cts28m00.sinavsnum
   if sqlca.sqlcode = notfound  then
      error " Aviso nao encontrado - sstmstpavs. AVISE A INFORMATICA!"
      return
   end if
   if w_cts28m00.descacidente is not null then
      let d_cts28m00.dscacidente = "S"
   end if
   let d_cts28m00.sinavsnum = w_cts28m00.sinavsnum

   select sinntzdes
      into d_cts28m00.sinntzdes
      from sgaknatur
     where sinramgrp = 2
       and sinntzcod = d_cts28m00.sinntzcod

   if w_cts28m00.sinavsramcod = 54 or
      w_cts28m00.sinavsramcod = 654 then
      let d_cts28m00.tiposinis = 1    # acidente
   else
      if w_cts28m00.sinavsramcod = 55 or
         w_cts28m00.sinavsramcod = 655 then
         let d_cts28m00.tiposinis = 2 # roubo
      else
         let d_cts28m00.tiposinis = 3 # outros
      end if
   end if
   case ws.c24soltipcod
        when 1 let ws.proced = "MOTORISTA"
        when 2 let ws.proced = "POLICIARD"
        when 3 let ws.proced = "PONTOAPOI"
        when 4 let ws.proced = "SEG.CORRE"
   end case
   call fsstc018(w_cts28m00.sinavsramcod,ws.proced,20)

   -------------------------[ DESCRICAO DOS BENS ATINGIDOS ]--------------
   select bnsatgcrgobs
       into w_cts28m00.descbensatg
       from sstmbnsatg
      where sinavsramcod = w_cts28m00.sinavsramcod
        and sinavsano    = w_cts28m00.sinavsano
        and sinavsnum    = w_cts28m00.sinavsnum
        and stpmcdgrpcod = 0
   if w_cts28m00.descbensatg is not null then
      let d_cts28m00.flgbensatg = "S"
   end if
   -------------------------[ HISTORICO DO ATENDENTE ]---------------------
   select prsprctxt
       into w_cts28m00.histatd
       from sstmprsprctxt
      where sinavsnum    = w_cts28m00.sinavsnum
        and prsprctip    = "FIN"
        and sintraprstip = "T"
        and prsprcseq    = 1
   if w_cts28m00.histatd is not null then
      let d_cts28m00.histatd = "S"
   end if
   -------------------------[ DADOS DO SERVICO ]---------------------------
   select nom      ,
          corsus   ,
          cornom   ,
          funmat   ,
          atddat   ,
          atdhor   ,
          atdlibflg,
          atdlibhor,
          atdlibdat,
          atdhorpvt,
          atddatprg,
          atdhorprg,
          atdfnlflg,
          atdprinvlcod,
          ciaempcod
     into d_cts28m00.nom      ,
          d_cts28m00.corsus   ,
          d_cts28m00.cornom   ,
          ws.funmat           ,
          w_cts28m00.atddat   ,
          w_cts28m00.atdhor   ,
          w_cts28m00.atdlibflg,
          d_cts28m00.atdlibhor,
          d_cts28m00.atdlibdat,
          w_cts28m00.atdhorpvt,
          w_cts28m00.atddatprg,
          w_cts28m00.atdhorprg,
          w_cts28m00.atdfnlflg,
          w_cts28m00.atdprinvlcod,
          g_documento.ciaempcod
     from datmservico
    where atdsrvnum = g_documento.atdsrvnum and
          atdsrvano = g_documento.atdsrvano

   if sqlca.sqlcode = notfound  then
      error " Servico nao encontrado. AVISE A INFORMATICA!"
      return
   end if
   -----------------[ DADOS COMPLEMENTARES DO SERVICO ]--------------
   select sindat   ,
          sinhor
     into d_cts28m00.sinocrdat,
          d_cts28m00.sinocrhor
     from datmservicocmp
    where atdsrvnum = g_documento.atdsrvnum and
          atdsrvano = g_documento.atdsrvano

   -----------------[ INFORMACOES DO LOCAL DA OCORRENCIA ]-----------
   call ctx04g00_local_gps(g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           1)
                 returning a_cts28m00[1].lclidttxt
                          ,a_cts28m00[1].lgdtip
                          ,a_cts28m00[1].lgdnom
                          ,a_cts28m00[1].lgdnum
                          ,a_cts28m00[1].lclbrrnom
                          ,a_cts28m00[1].brrnom
                          ,a_cts28m00[1].cidnom
                          ,a_cts28m00[1].ufdcod
                          ,a_cts28m00[1].lclrefptotxt
                          ,a_cts28m00[1].endzon
                          ,a_cts28m00[1].lgdcep
                          ,a_cts28m00[1].lgdcepcmp
                          ,a_cts28m00[1].lclltt
                          ,a_cts28m00[1].lcllgt
                          ,a_cts28m00[1].dddcod
                          ,a_cts28m00[1].lcltelnum
                          ,a_cts28m00[1].lclcttnom
                          ,a_cts28m00[1].c24lclpdrcod
                          ,a_cts28m00[1].celteldddcod
                          ,a_cts28m00[1].celtelnum
                          ,a_cts28m00[1].endcmp
                          ,ws.sqlerro
                          ,a_cts28m00[1].emeviacod
   # PSI 244589 - Inclusão de Sub-Bairro - Burini
   let m_subbairro[1].lclbrrnom = a_cts28m00[1].lclbrrnom
   call cts06g10_monta_brr_subbrr(a_cts28m00[1].brrnom,
                                  a_cts28m00[1].lclbrrnom)
        returning a_cts28m00[1].lclbrrnom
   if ws.sqlerro = notfound   then
      error " Erro (", ws.sqlerro using "<<<<<&", ") na leitura do ",
            " local da ocorrencia. AVISE A INFORMATICA!"
      return
   end if

   let a_cts28m00[1].lgdtxt = a_cts28m00[1].lgdtip clipped, " ",
                              a_cts28m00[1].lgdnom clipped, " ",
                              a_cts28m00[1].lgdnum using "<<<<#"
   -------------------[ OBTEM DOCUMENTO DO SERVICO ]-----------------
   let w_cts28m00.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                            g_documento.atdsrvano)
   call cts20g01_docto(w_cts28m00.lignum)
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
      let d_cts28m00.doctxt = "Apolice.: ", g_documento.succod    using "&&",
                                       " ", g_documento.ramcod    using "&&&&",
                                    " ", g_documento.aplnumdig using "<<<<<<<&&"
   end if

   if g_documento.prporg    is not null  and
      g_documento.prpnumdig is not null  then
      let d_cts28m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                    " ", g_documento.prpnumdig using "<<<<<<<&&"
   end if
   ---------------------[ DADOS DA LIGACAO ]-------------------------
   select c24astcod, ligcvntip,
          c24solnom
     into d_cts28m00.c24astcod,
          w_cts28m00.ligcvntip,
          d_cts28m00.c24solnom
     from datmligacao
    where lignum  =  w_cts28m00.lignum
   let g_documento.c24astcod = d_cts28m00.c24astcod
   ---------------------[ DESCRICAO DO CONVENIO ]---------------------
   select cpodes
     into d_cts28m00.cvnnom
     from datkdominio
    where cponom = "ligcvntip"  and
          cpocod = w_cts28m00.ligcvntip
   --------------------[ DESCRICAO DO ASSUNTO ]-----------------------
   let d_cts28m00.c24astdes = c24geral8(d_cts28m00.c24astcod)
   --------------------[ OBTEM NOME DO FUNCIONARIO ]------------------
   let ws.funnom = "** NAO CADASTRADO **"
   select funnom, dptsgl
     into ws.funnom, ws.dptsgl
     from isskfunc
    where empcod = 1
      and funmat = ws.funmat
   let d_cts28m00.atdtxt = w_cts28m00.atddat        clipped, " ",
                           w_cts28m00.atdhor        clipped, " ",
                           upshift(ws.dptsgl)       clipped, " ",
                           ws.funmat using "&&&&&&" clipped, " ",
                           upshift(ws.funnom)
   let aux_libant = w_cts28m00.atdlibflg
   if w_cts28m00.atdlibflg = "N"  then
      let d_cts28m00.atdlibdat = w_cts28m00.atddat
      let d_cts28m00.atdlibhor = w_cts28m00.atdhor
   end if
   let d_cts28m00.servico = g_documento.atdsrvorg using "&&",
                       "/", g_documento.atdsrvnum using "&&&&&&&",
                       "-", g_documento.atdsrvano using "&&"
 end function   ###  consulta_cts28m00

#--------------------------------------------------------------------
 function modifica_cts28m00()
#--------------------------------------------------------------------
   define ws           record
          sqlerro      integer,
          atdsrvseq    like datmsrvacp.atdsrvseq,
          atdetpdat    like datmsrvacp.atdetpdat,
          atdetphor    like datmsrvacp.atdetphor
   end record
   define hist_cts28m00 record
          hist1        like datmservhist.c24srvdsc,
          hist2        like datmservhist.c24srvdsc,
          hist3        like datmservhist.c24srvdsc,
          hist4        like datmservhist.c24srvdsc,
          hist5        like datmservhist.c24srvdsc
   end record
   define prompt_key    char (01)

   define l_data      date,
          l_hora2     datetime hour to minute

	let	prompt_key  =  null

	initialize  ws.*  to  null

	initialize  hist_cts28m00.*  to  null

   initialize ws.*  to null

   call input_cts28m00() returning hist_cts28m00.*

   if int_flag then
      let int_flag = false
      error " Operacao cancelada!"
      initialize d_cts28m00.*    to null
      initialize a_cts28m00      to null
      initialize w_cts28m00.*    to null
      clear form
      return false
   end if

   whenever error continue
   begin work
   update datmservico set ( nom,
                            corsus,
                            cornom,
                            atdlibflg,
                            atdlibhor,
                            atdlibdat,
                            atdhorpvt,
                            atddatprg,
                            atdhorprg,
                            atdprinvlcod)
                        = ( d_cts28m00.nom      ,
                            d_cts28m00.corsus   ,
                            d_cts28m00.cornom   ,
                            w_cts28m00.atdlibflg,
                            d_cts28m00.atdlibhor,
                            d_cts28m00.atdlibdat,
                            w_cts28m00.atdhorpvt,
                            w_cts28m00.atddatprg,
                            w_cts28m00.atdhorprg,
                            w_cts28m00.atdprinvlcod)
                      where atdsrvnum = g_documento.atdsrvnum and
                            atdsrvano = g_documento.atdsrvano
   if sqlca.sqlcode <> 0 then
      error " Erro (", sqlca.sqlcode, ") na alteracao do servico.",
            " AVISE A INFORMATICA!"
      rollback work
      prompt "" for char prompt_key
      return false
   end if
   update datmservicocmp set ( sindat   ,
                               sinhor   )
                           = ( d_cts28m00.sinocrdat,
                               d_cts28m00.sinocrhor)
                         where atdsrvnum = g_documento.atdsrvnum and
                               atdsrvano = g_documento.atdsrvano
   if sqlca.sqlcode <> 0 then
      error " Erro (", sqlca.sqlcode, ") na alteracao do complemento",
            " do servico. AVISE A INFORMATICA!"
      rollback work
      prompt "" for char prompt_key
      return false
   end if
  #for arr_aux = 1 to 2
   for arr_aux = 1 to 1
      if a_cts28m00[arr_aux].operacao is null  then
         let a_cts28m00[arr_aux].operacao = "M"
      end if
      let a_cts28m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
      let ws.sqlerro = cts06g07_local( a_cts28m00[arr_aux].operacao,
                                       g_documento.atdsrvnum,
                                       g_documento.atdsrvano,
                                       arr_aux,
                                       a_cts28m00[arr_aux].lclidttxt,
                                       a_cts28m00[arr_aux].lgdtip,
                                       a_cts28m00[arr_aux].lgdnom,
                                       a_cts28m00[arr_aux].lgdnum,
                                       a_cts28m00[arr_aux].lclbrrnom,
                                       a_cts28m00[arr_aux].brrnom,
                                       a_cts28m00[arr_aux].cidnom,
                                       a_cts28m00[arr_aux].ufdcod,
                                       a_cts28m00[arr_aux].lclrefptotxt,
                                       a_cts28m00[arr_aux].endzon,
                                       a_cts28m00[arr_aux].lgdcep,
                                       a_cts28m00[arr_aux].lgdcepcmp,
                                       a_cts28m00[arr_aux].lclltt,
                                       a_cts28m00[arr_aux].lcllgt,
                                       a_cts28m00[arr_aux].dddcod,
                                       a_cts28m00[arr_aux].lcltelnum,
                                       a_cts28m00[arr_aux].lclcttnom,
                                       a_cts28m00[arr_aux].c24lclpdrcod,
                                       a_cts28m00[arr_aux].ofnnumdig,
                                       a_cts28m00[arr_aux].emeviacod,
                                       a_cts28m00[arr_aux].celteldddcod,
                                       a_cts28m00[arr_aux].celtelnum,
                                       a_cts28m00[arr_aux].endcmp)

      if ws.sqlerro is null   or
         ws.sqlerro <> 0      then
         if arr_aux = 1  then
            error " Erro (", ws.sqlerro, ") na alteracao do local de",
                  " ocorrencia."," AVISE A INFORMATICA!"
         end if
         rollback work
         prompt "" for char prompt_key
         return false
      end if
   end for
   if aux_libant <> w_cts28m00.atdlibflg  then
      if w_cts28m00.atdlibflg = "S"  then
         let w_cts28m00.atdetpcod = 1
         let ws.atdetpdat = d_cts28m00.atdlibdat
         let ws.atdetphor = d_cts28m00.atdlibhor
      else
         call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
         let w_cts28m00.atdetpcod = 2
         let ws.atdetpdat = l_data
         let ws.atdetphor = l_hora2
      end if
      select max(atdsrvseq)
        into ws.atdsrvseq
        from datmsrvacp
       where atdsrvnum = g_documento.atdsrvnum  and
             atdsrvano = g_documento.atdsrvano
      if ws.atdsrvseq is null  then
         let ws.atdsrvseq = 0
      end if
      #let ws.atdsrvseq = ws.atdsrvseq + 1
      #
      #insert into datmsrvacp (atdsrvnum,
      #                        atdsrvano,
      #                        atdsrvseq,
      #                        atdetpcod,
      #                        atdetpdat,
      #                        atdetphor,
      #                        empcod   ,
      #                        funmat   )
      #                values (g_documento.atdsrvnum,
      #                        g_documento.atdsrvano,
      #                        ws.atdsrvseq         ,
      #                        w_cts28m00.atdetpcod ,
      #                        ws.atdetpdat         ,
      #                        ws.atdetphor         ,
      #                        g_issk.empcod        ,
      #                        g_issk.funmat        )

      # 218545 - Burini
      call cts10g04_insere_etapa(aux_atdsrvnum,
                                 aux_atdsrvano,
                                 w_cts28m00.atdetpcod,
                                 "", "", "", "")
           returning ws.sqlerro

      if ws.sqlerro <> 0  then
         error " Erro (", ws.sqlerro, ") na inclusao da etapa de",
               " acompanhamento. AVISE A INFORMATICA!"
         prompt "" for char prompt_key
         rollback work
         return false
      end if
   end if

   whenever error stop

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                               g_documento.atdsrvano)

   return true

 end function  ###  modifica_cts28m00()

#-------------------------------------------------------------------------------
 function inclui_cts28m00()
#-------------------------------------------------------------------------------

   define hist_cts28m00   record
          hist1           like datmservhist.c24srvdsc,
          hist2           like datmservhist.c24srvdsc,
          hist3           like datmservhist.c24srvdsc,
          hist4           like datmservhist.c24srvdsc,
          hist5           like datmservhist.c24srvdsc
   end record
   define ws              record
          comando         char(01)                   ,
          retorno         smallint                   ,
          erro            smallint                   ,
          lignum          like datmligacao.lignum    ,
          atdsrvnum       like datmservico.atdsrvnum ,
          atdsrvano       like datmservico.atdsrvano ,
          sqlerro         integer                    ,
          tabname         like systables.tabname     ,
          msg             char(80)                ,
          caddat          like datmligfrm.caddat     ,
          cadhor          like datmligfrm.cadhor     ,
          cademp          like datmligfrm.cademp     ,
          cadmat          like datmligfrm.cadmat     ,
          atdsrvseq       like datmsrvacp.atdsrvseq  ,
          etpfunmat       like datmsrvacp.funmat     ,
          atdetpdat       like datmsrvacp.atdetpdat  ,
          atdetphor       like datmsrvacp.atdetphor  ,
          histerr         smallint                   ,
          doctxt          char(35)                   ,
          grlchv1         like datkgeral.grlchv      ,
          grlinf          like datkgeral.grlinf      ,
          confirma        char(01)                   ,
          funnom          like isskfunc.funnom       ,
          c24trxnum       like dammtrx.c24trxnum     ,
          lintxt          like dammtrxtxt.c24trxtxt  ,
          titulo          char (40)
   end record
   define retorno1 record
          succod          like gabksuc.succod,
          ramcod          like gtakram.ramcod,
          aplnumdig       like abamdoc.aplnumdig,
          itmnumdig       like abbmveic.itmnumdig,
          prporg          like datrligprp.prporg,
          prpnumdig       like datrligprp.prpnumdig
   end record

   define l_data      date,
          l_hora2     datetime hour to minute


	initialize  hist_cts28m00.*  to  null

	initialize  ws.*  to  null

	initialize  retorno1.*  to  null

   while true

     initialize ws.*  to null

     let g_documento.acao     = "INC"
     let w_cts28m00.atdlibflg = "S"

     call input_cts28m00() returning hist_cts28m00.*

     if  int_flag  then
         let int_flag = false
         initialize d_cts28m00.*    to null
         initialize w_cts28m00.*    to null
         error " Operacao cancelada!"
         clear form
         let ws.retorno = false
         exit while
     end if
     if  w_cts28m00.data is null  then
         let w_cts28m00.data   = aux_today
         let w_cts28m00.hora   = aux_hora
         let w_cts28m00.funmat = g_issk.funmat
     end if
     if  w_cts28m00.atdfnlflg is null  then
         let w_cts28m00.atdfnlflg = "N"
         let w_cts28m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
     end if
     #------------------------------------------------------------------------------
     # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
     #------------------------------------------------------------------------------
     if g_documento.lclocodesres = "S" then
        let w_cts28m00.atdrsdflg = "S"
     else
        let w_cts28m00.atdrsdflg = "N"
     end if
     ---------------------[ BUSCA NUMERACAO LIGACAO / SERVICO ]-----------------
     begin work

     call cts10g03_numeracao( 2, "1" )
          returning ws.lignum   ,
                    ws.atdsrvnum,
                    ws.atdsrvano,
                    ws.sqlerro  ,
                    ws.msg
     if  ws.sqlerro = 0  then
         commit work
     else
         let ws.msg = "CTS28M00 - ",ws.msg
         call ctx13g00(ws.sqlerro,"DATKGERAL",ws.msg)
         rollback work
         prompt "" for char ws.comando
         let ws.retorno = false
       exit while
     end if
     let g_documento.lignum = ws.lignum
     let aux_atdsrvnum      = ws.atdsrvnum
     let aux_atdsrvano      = ws.atdsrvano

     if g_issk.funmat = 601566 then
        display "**** INICIO DAS GRAVACOES - LIGACAO - datmligacao"
     end if
     ----------------------[ GRAVA LIGACAO E SERVICO ]--------------------------
     begin work

     call cts10g00_ligacao ( g_documento.lignum      ,
                             w_cts28m00.data         ,
                             w_cts28m00.hora         ,
                             g_documento.c24soltipcod,
                             g_documento.solnom      ,
                             g_documento.c24astcod   ,
                             w_cts28m00.funmat       ,
                             g_documento.ligcvntip   ,
                             g_c24paxnum             ,
                             aux_atdsrvnum           ,
                             aux_atdsrvano           ,
                             ""                      , # sinvstnum
                             ""                      , # sinvstano
                             ""                      , # sinavsnum
                             ""                      , # sinavsano
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
                             ws.caddat,  ws.cadhor   ,
                             ws.cademp,  ws.cadmat    )
          returning ws.tabname,
                    ws.sqlerro
     if  ws.sqlerro  <>  0  then
         error " Erro (", ws.sqlerro, ") na gravacao da",
               " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
         rollback work
         prompt "" for char ws.comando
         let ws.retorno = false
         exit while
     end if

     if g_issk.funmat = 601566 then
        display "**** SERVICO  - datmservico"
     end if

     call cts10g02_grava_servico( aux_atdsrvnum       ,
                                  aux_atdsrvano       ,
                                  g_documento.soltip  ,     # atdsoltip
                                  g_documento.solnom  ,     # c24solnom
                                  ""                  ,     # vclcorcod
                                  w_cts28m00.funmat   ,
                                  w_cts28m00.atdlibflg,
                                  d_cts28m00.atdlibhor,
                                  d_cts28m00.atdlibdat,
                                  w_cts28m00.data     ,     # atddat
                                  w_cts28m00.hora     ,     # atdhor
                                  ""                  ,     # atdlclflg
                                  w_cts28m00.atdhorpvt,
                                  w_cts28m00.atddatprg,
                                  w_cts28m00.atdhorprg,
                                  "1"                 ,     # atdtip
                                  ""                  ,     # atdmotnom
                                  ""                  ,     # atdvclsgl
                                  ""                  ,     # atdprscod
                                  ""                  ,     # atdcstvlr
                                  w_cts28m00.atdfnlflg,
                                  ""                  ,     # atdfnlhor
                                  w_cts28m00.atdrsdflg,
                                  ""                  ,     # atddfttxt
                                  ""                  ,     # atddoctxt
                                  w_cts28m00.c24opemat,
                                  d_cts28m00.nom      ,
                                  ""                  ,     # vlcdes
                                  ""                  ,     # vclanomdl
                                  ""                  ,     # vcllicnum
                                  d_cts28m00.corsus   ,
                                  d_cts28m00.cornom   ,
                                  ""                  ,     # cnldat
                                  ""                  ,     # pgtdat
                                  ""                  ,     # nomctt
                                  ""                  ,     # atdpvtretflg
                                  ""                  ,     # atdvcltip
                                  ""                  ,     # asitipcod
                                  ""                  ,     # socvclcod
                                  ""                  ,     # vclcoddig
                                  "N"                 ,     # srvprlflg
                                  ""                  ,     # srrcoddig
                                  "1"                 ,     # atdprinvlcod
                                  g_documento.atdsrvorg   ) # atdsrvorg
          returning ws.tabname,
                  ws.sqlerro
     if  ws.sqlerro  <>  0  then
       error " Erro (", ws.sqlerro, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.comando
       let ws.retorno = false
       exit while
     end if

     if g_issk.funmat = 601566 then
        display "**** COMPLEMENTO - datmservicocmp"
     end if

     ------------------[ GRAVA COMPLEMENTO DO SERVICO ]-------------------------

     # INCLUSAO DO CAMPO vicsnh NO INSERT DA TABELA
     # datmservicocmp DEVIDO AO DESAPARECIMENTO
     # DO CAMPO sinntzcod DE UM DETERMINADO
     # LAUDO DE SINISTRO DE TRANSPORTES.
     # ESTAMOS GUARDANDO AQUI P/GARANTIR
     # DATA: 23/05/2006
     # AUTORES: LUCAS SCHEID E CARLOS RUIZ

     insert into datmservicocmp ( atdsrvnum,
                                  atdsrvano,
                                  sindat,
                                  sinhor,
                                  vicsnh)
                         values ( aux_atdsrvnum,
                                  aux_atdsrvano,
                                  d_cts28m00.sinocrdat,
                                  d_cts28m00.sinocrhor,
                                  d_cts28m00.sinntzcod)

     if  sqlca.sqlcode  <>  0  then
         error " Erro (", sqlca.sqlcode, ") na gravacao do",
               " complemento do servico. AVISE A INFORMATICA!"
         rollback work
         prompt "" for char ws.comando
         let ws.retorno = false
         exit while
     end if
     ---------------[GRAVA LOCAIS DE (1) OCORRENCIA  / (2) DESTINO]-----------
    #for arr_aux = 1 to 2
     for arr_aux = 1 to 1
         if  a_cts28m00[arr_aux].operacao is null  then
             let a_cts28m00[arr_aux].operacao = "I"
         end if
         let a_cts28m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

         let ws.sqlerro = cts06g07_local( a_cts28m00[arr_aux].operacao
                                         ,aux_atdsrvnum
                                         ,aux_atdsrvano
                                         ,arr_aux
                                         ,a_cts28m00[arr_aux].lclidttxt
                                         ,a_cts28m00[arr_aux].lgdtip
                                         ,a_cts28m00[arr_aux].lgdnom
                                         ,a_cts28m00[arr_aux].lgdnum
                                         ,a_cts28m00[arr_aux].lclbrrnom
                                         ,a_cts28m00[arr_aux].brrnom
                                         ,a_cts28m00[arr_aux].cidnom
                                         ,a_cts28m00[arr_aux].ufdcod
                                         ,a_cts28m00[arr_aux].lclrefptotxt
                                         ,a_cts28m00[arr_aux].endzon
                                         ,a_cts28m00[arr_aux].lgdcep
                                         ,a_cts28m00[arr_aux].lgdcepcmp
                                         ,a_cts28m00[arr_aux].lclltt
                                         ,a_cts28m00[arr_aux].lcllgt
                                         ,a_cts28m00[arr_aux].dddcod
                                         ,a_cts28m00[arr_aux].lcltelnum
                                         ,a_cts28m00[arr_aux].lclcttnom
                                         ,a_cts28m00[arr_aux].c24lclpdrcod
                                         ,a_cts28m00[arr_aux].ofnnumdig
                                         ,a_cts28m00[arr_aux].emeviacod
                                         ,a_cts28m00[arr_aux].celteldddcod
                                         ,a_cts28m00[arr_aux].celtelnum
                                         ,a_cts28m00[arr_aux].endcmp)

         if  ws.sqlerro is null  or
               ws.sqlerro <> 0     then
             if  arr_aux = 1  then
                 error " Erro (", ws.sqlerro, ") na gravacao do",
                       " local de ocorrencia. AVISE A INFORMATICA!"
  #          else
  #              error " Erro (", ws.sqlerro, ") na gravacao do",
  #                    " local de destino. AVISE A INFORMATICA!"
             end if
                     rollback work
             prompt "" for char ws.comando
             let ws.retorno = false
             exit while
         end if
     end for

     if g_issk.funmat = 601566 then
        display "**** ETAPA - datmsrvacp         "
     end if

     -----------------------[ GRAVA ETAPAS DO ACOMPANHAMENTO ]------------------
     select max(atdsrvseq)
       into ws.atdsrvseq
       from DATMSRVACP
            where atdsrvnum = aux_atdsrvnum
              and atdsrvano = aux_atdsrvano

     if  ws.atdsrvseq is null  then
         let ws.atdsrvseq = 0
     end if
     if  w_cts28m00.atdetpcod is null  then
         if  w_cts28m00.atdlibflg = "S"  then
             let w_cts28m00.atdetpcod = 1
             let ws.etpfunmat = w_cts28m00.funmat
             let ws.atdetpdat = d_cts28m00.atdlibdat
             let ws.atdetphor = d_cts28m00.atdlibhor
         else
             let w_cts28m00.atdetpcod = 2
             let ws.etpfunmat = w_cts28m00.funmat
             let ws.atdetpdat = w_cts28m00.data
             let ws.atdetphor = w_cts28m00.hora
         end if
     else
         #let ws.atdsrvseq = ws.atdsrvseq + 1
         #
         #insert into DATMSRVACP ( atdsrvnum,
         #                         atdsrvano,
         #                         atdsrvseq,
         #                         atdetpcod,
         #                         atdetpdat,
         #                         atdetphor,
         #                         empcod   ,
         #                         funmat    )
         #                values ( aux_atdsrvnum    ,
         #                         aux_atdsrvano    ,
         #                         ws.atdsrvseq     ,
         #                         1                ,
         #                         w_cts28m00.data  ,
         #                         w_cts28m00.hora  ,
         #                         g_issk.empcod    ,
         #                         w_cts28m00.funmat )

         # 218545 - Burini
         call cts10g04_insere_etapa(aux_atdsrvnum,
                                    aux_atdsrvano,
                                    1, "", "", "", "")
              returning ws.sqlerro

         if  ws.sqlerro  <>  0  then
             error " Erro (", ws.sqlerro, ") na gravacao da",
                   " etapa de acompanhamento (1). AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.comando
             let ws.retorno = false
             exit while
         end if
         let ws.atdetpdat = aux_today
         let ws.atdetphor = aux_hora
         let ws.etpfunmat = w_cts28m00.c24opemat
     end if
     #let ws.atdsrvseq = ws.atdsrvseq + 1
     #insert into DATMSRVACP ( atdsrvnum,
     #                         atdsrvano,
     #                         atdsrvseq,
     #                         atdetpcod,
     #                         atdetpdat,
     #                         atdetphor,
     #                         empcod   ,
     #                         funmat   ,
     #                         pstcoddig,
     #                         c24nomctt )
     #                values ( aux_atdsrvnum       ,
     #                         aux_atdsrvano       ,
     #                         ws.atdsrvseq        ,
     #                         w_cts28m00.atdetpcod,
     #                         ws.atdetpdat        ,
     #                         ws.atdetphor        ,
     #                         g_issk.empcod       ,
     #                         ws.etpfunmat        ,
     #                         ""                  ,
     #                         ""                   )

     # 218545 - Burini
     call cts10g04_insere_etapa(aux_atdsrvnum,
                                aux_atdsrvano,
                                w_cts28m00.atdetpcod,
                                "", "", "", "")
          returning ws.sqlerro

     if  ws.sqlerro    <>  0  then
         error " Erro (", ws.sqlerro, ") na gravacao da",
               " etapa de acompanhamento (2). AVISE A INFORMATICA!"
         rollback work
         prompt "" for char ws.comando
         let ws.retorno = false
         exit while
     end if

     if g_issk.funmat = 601566 then
        display "**** RELAC SERV/APOL - datrservapol "
     end if

     ------------------[ GRAVA RELACIONAMENTO SERVICO / APOLICE ]--------------
     if  g_documento.aplnumdig is not null  and
         g_documento.aplnumdig <> 0        then
         call cts10g02_grava_servico_apolice(aux_atdsrvnum         ,
                                             aux_atdsrvano         ,
                                             g_documento.succod   ,
                                             g_documento.ramcod   ,
                                             g_documento.aplnumdig,
                                             g_documento.itmnumdig,
                                             g_documento.edsnumref)
              returning ws.tabname,
                        ws.sqlerro
         if  ws.sqlerro <> 0  then
             error " Erro (", ws.sqlerro, ") na gravacao do",
                   " relacionamento servico x apolice. AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.comando
             let ws.retorno = false
             exit while
         end if
     end if
     ---------------[ OBTER ORIGEM,PROPOSTA E SEGURADO DO DOCTO ]-----------
     if  g_documento.aplnumdig is not null  and
         g_documento.aplnumdig <> 0        then
         select  sgrorg   , sgrnumdig
           into  w_cts28m00.sgrorg, w_cts28m00.sgrnumdig
           from  rsamseguro
          where succod    = g_documento.succod     and
                ramcod    = g_documento.ramcod     and
                aplnumdig = g_documento.aplnumdig

         select  segnumdig, dctnumseq
           into  w_cts28m00.segnumdig,w_cts28m00.dctnumseq
           from  rsdmdocto
          where sgrorg    = w_cts28m00.sgrorg      and
                sgrnumdig = w_cts28m00.sgrnumdig   and
                dctnumseq = (select max(dctnumseq)
                               from  rsdmdocto
                               where sgrorg     = w_cts28m00.sgrorg     and
                                     sgrnumdig  = w_cts28m00.sgrnumdig  and
                                     prpstt     in (19,65,66,88))
     end if
     call cts28m00_grava_aviso_transp()
          returning w_cts28m00.sinavsnum,
                    ws.erro,
                    ws.sqlerro,
                    ws.tabname
     if  ws.erro    <> 0  then
         error " Erro (", ws.sqlerro, ") na gravacao do Sinistro de Transp.",
               " tabela ",ws.tabname, " AVISE A INFORMATICA!"
         rollback work
         prompt "" for char ws.comando
         let ws.retorno = false
         exit while
     end if

     if g_issk.funmat = 601566 then
        display "**** RELAC.SERV/AVISO - datrligtrp"
     end if

     -----------[ GRAVA RELACIONAMENTO LIGACAO / AVISO DE SINISTRO ]------------
     if w_cts28m00.sinavsnum is not null then
        insert into datrligtrp (lignum,
                                sinavsnum,
                                sinavsano,
                                atdsrvnum,
                                atdsrvano)
                      values   (g_documento.lignum,
                                w_cts28m00.sinavsnum  ,
                                aux_ano,
                                aux_atdsrvnum,
                                aux_atdsrvano)
        if sqlca.sqlcode <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 " relacionamento ligacao x aviso de sinis.",
                 " AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.comando
           let ws.retorno = false
           exit while
        end if
     end if
     ------------------[ GRAVA HISTORICO DO ATENDENTE ]--------------------
     if w_cts28m00.histatd1 is not null then
        if g_issk.funmat = 601566 then
           display "**** w_cts28m00.histatd1 = ", w_cts28m00.histatd1
           display "**** HIST ATD1    - datmservhist  "
        end if
        let w_cts28m00h[1].histatd = w_cts28m00.histatd1
        let w_cts28m00h[2].histatd = w_cts28m00.histatd2
        let w_cts28m00h[3].histatd = w_cts28m00.histatd3
        let w_cts28m00h[4].histatd = w_cts28m00.histatd4
        let w_cts28m00h[5].histatd = w_cts28m00.histatd5
        let arr_aux = 1
        while true
          if w_cts28m00h[arr_aux].histatd is null then
             exit while
          end if
          initialize hist_cts28m00.* to null
          let hist_cts28m00.hist1  =  w_cts28m00h[arr_aux].histatd[001,070]
          let hist_cts28m00.hist2  =  w_cts28m00h[arr_aux].histatd[071,140]
          let hist_cts28m00.hist3  =  w_cts28m00h[arr_aux].histatd[141,210]
          let hist_cts28m00.hist4  =  w_cts28m00h[arr_aux].histatd[211,250]
          let hist_cts28m00.hist5  =  w_cts28m00h[arr_aux].histatd[251,255]

          let ws.histerr = cts10g02_historico(aux_atdsrvnum    , aux_atdsrvano  ,
                                              w_cts28m00.data  , w_cts28m00.hora,
                                              w_cts28m00.funmat, hist_cts28m00.* )

          let arr_aux = arr_aux + 1
          if  arr_aux > 5 then
              exit while
          end if
        end while
       #initialize hist_cts28m00.* to null
       #let hist_cts28m00.hist1  =  w_cts28m00.histatd1[001,070]
       #let hist_cts28m00.hist2  =  w_cts28m00.histatd1[071,140]
       #let hist_cts28m00.hist3  =  w_cts28m00.histatd1[141,210]
       #let hist_cts28m00.hist4  =  w_cts28m00.histatd1[211,250]
       #let hist_cts28m00.hist5  =  w_cts28m00.histatd1[251,255]
       #call cts10g02_historico(aux_atdsrvnum    , aux_atdsrvano  ,
       #                        w_cts28m00.data  , w_cts28m00.hora,
       #                        w_cts28m00.funmat, hist_cts28m00.* )
       #     returning ws.histerr
     end if
     ------------------[ GRAVA DESCR.BENS TERCEIRO  ]----------------------
     if w_cts28m00.descbensterc is not null then
        if g_issk.funmat = 601566 then
           display "**** w_cts28m00.descbensterc = ", w_cts28m00.descbensterc
           display "**** DESCR BENS TERC - datmservhist"
        end if

        initialize hist_cts28m00.* to null

        let hist_cts28m00.hist1  =
     "************ DESCRICAO DO BENS ATINGIDOS DO TERCEIRO ***************"
        let hist_cts28m00.hist2  =  w_cts28m00.descbensterc[001,070]
        let hist_cts28m00.hist3  =  w_cts28m00.descbensterc[071,140]
        let hist_cts28m00.hist4  =  w_cts28m00.descbensterc[141,206]
        call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
        let ws.histerr = cts10g02_historico( aux_atdsrvnum    , aux_atdsrvano  ,
                                             w_cts28m00.data  , l_hora2,
                                             w_cts28m00.funmat, hist_cts28m00.* )
     end if
     ------------------[ GRAVA DESCR.BENS ATINGIDOS ]----------------------
     if w_cts28m00.descbensatg is not null then
        if g_issk.funmat = 601566 then
           display "**** DESCR BENS ATG  - sstmbnsatg  "
        end if
        call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
        insert into sstmbnsatg
                   (sinavsramcod,
                    sinavsano,
                    sinavsnum,
                    bnsatgcrgqtd,
                    stpmcdgrpcod,
                    bnsatgembcod,
                    bnsatgcrgtip,
                    bnsatgcrgpso,
                    bnsatgcrgvlr,
                    bnsatgcrgdnsper,
                    bnsatgcrgsosflg,
                    bnsatgcrggchflg,
                    bnsatgcrgcndcod,
                    bnsatgcrgobs,
                    atldat,
                    atlhor,
                    atlmat,
                    atlemp,
                    atlusrtip)
             values(g_documento.ramcod,
                    aux_ano,
                    w_cts28m00.sinavsnum,
                    0                   , # quantidade de carga
                    0                   , # grupo de mercadoria
                    0                   , # tipo de embalagem
                    0                   , # situacao da carga
                    0                   , # peso da carga
                  # d_cts28m00.imsvlr   , # valor da carga
                    0                   , # valor da carga
                    0                   , # percentual de danos a carga
                    "1"                , # empresa providenciou o socorro carga
                    "0"                , # necessita guincho para remover carga
                    0                   , # codigo da situacao da carga
                    w_cts28m00.descbensatg, # descricao da carga
                    l_data              , # data atualizacao
                    aux_hora            , # hora atualizacao
                    g_issk.funmat       , # matricula do atendente
                    g_issk.empcod       , # codigo empresa
                    g_issk.usrtip)        # tipo do funcionario
        if sqlca.sqlcode <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 " Bens Atingidos - sstmbnsatg.",
                 " AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.comando
           let ws.retorno = false
           exit while
        end if
     end if

     commit work
     # Ponto de acesso apos a gravacao do laudo
     call cts00g07_apos_grvlaudo(aux_atdsrvnum,
                                 aux_atdsrvano)

     --------------------[ EXIBE O NUMERO DO SERVICO ]-------------------------
     let d_cts28m00.servico = g_documento.atdsrvorg using "&&",
                              "/", aux_atdsrvnum using "&&&&&&&",
                              "-", aux_atdsrvano using "&&"
     display d_cts28m00.servico to servico attribute (reverse)

     let d_cts28m00.sinavsnum = w_cts28m00.sinavsnum
     display by name d_cts28m00.sinavsnum  attribute (reverse)

     error  " Verifique o numero do Servico/Aviso e tecle ENTER!"
     prompt "" for char ws.comando

#PSI 175552 - Inicio
#    ---------------------[ envia pager para plantao sinistro ]----------------
#    let ws.funnom = "** NAO CADASTRADO **"
#    select funnom
#      into ws.funnom
#      from isskfunc
#     where empcod = 1
#       and funmat = g_issk.funmat
#     let ws.titulo = "CENTRAL 24 HORAS INFORMA - SINIS.TRANSP"
#     call ctx14g00_msg(9999,
#                       g_documento.lignum,
#                       g_documento.atdsrvnum,
#                       g_documento.atdsrvano,
#                       ws.titulo)
#             returning ws.c24trxnum
#     if g_hostname  <> "u07" then
#        call ctx14g00_msgdst(ws.c24trxnum,"6772","pager",2) # 4376527 vanderlei
#       #call ctx14g00_msgdst(ws.c24trxnum,"6762","pager",2) # 4377093 andreia
#        call ctx14g00_msgdst(ws.c24trxnum,"6766","pager",2) # 4377092 andreia
#        call ctx14g00_msgdst(ws.c24trxnum,"6199","pager",2) # 4362282 andreia
#        call ctx14g00_msgdst(ws.c24trxnum,"5994","pager",2) # 4362331 ct24hs
#        call ctx14g00_msgdst(ws.c24trxnum,"5981","pager",2) # 4362363 ct24hs
#     end if
#   # call ctx14g00_msgdst(ws.c24trxnum,
#   #                      "carlos.ruiz@portoseguro.com.br",
#   #                      "Ruiz",
#   #                      1)
#
#     let ws.lintxt = "SEGURADO: ",d_cts28m00.nom
#     call ctx14g00_msgtxt( ws.c24trxnum,ws.lintxt)
#
#     let ws.lintxt = "CIDADE OCORR.: ",a_cts28m00[1].cidnom
#     call ctx14g00_msgtxt( ws.c24trxnum,ws.lintxt)
#
#     let ws.lintxt = "UF: ",a_cts28m00[1].ufdcod
#     call ctx14g00_msgtxt( ws.c24trxnum,ws.lintxt)
#
#     let ws.lintxt = "SERVICO: ",d_cts28m00.servico
#     call ctx14g00_msgtxt( ws.c24trxnum,ws.lintxt)
#
#     let ws.lintxt = "AVISO: ",d_cts28m00.sinavsnum
#     call ctx14g00_msgtxt( ws.c24trxnum,ws.lintxt)
#
#     let ws.lintxt ="ATENDENTE:",ws.funnom," ",today," ",w_cts28m00.hora
#     call ctx14g00_msgtxt( ws.c24trxnum, ws.lintxt)
#
#     let ws.lintxt ="PARA MAIORES INF. LIGUE 0800110801-3366.3155"
#     call ctx14g00_msgtxt( ws.c24trxnum, ws.lintxt)
#
#     update dammtrx
#         set c24msgtrxstt = 9   # STATUS DE ENVIO
#     where c24trxnum = ws.c24trxnum
#  ## call ctx14g00_msgok(ws.c24trxnum)
#     call ctx14g00_envia(ws.c24trxnum,"")
# PSI 175552 - Final

     ---------------------------------------------------------------------------
     initialize retorno1.*  to null
     initialize ws.doctxt   to null
     ------------[ chave para busca do ramo 78 ]------------
     let ws.grlchv1 = "pstc",g_issk.funmat using "&&&&&&",
                             g_issk.empcod using "&&",
                             g_issk.maqsgl clipped
     select grlinf
          into ws.grlinf
          from datkgeral
         where grlchv = ws.grlchv1    # retorna apolice do ramo 78
     if sqlca.sqlcode <> notfound then
        delete from datkgeral
           where grlchv = ws.grlchv1
     end if

     call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
     if  m_dtresol86 <= l_data then
        let retorno1.succod    = ws.grlinf[01,02]
        let retorno1.ramcod    = ws.grlinf[03,06]
        let retorno1.aplnumdig = ws.grlinf[07,14]
        let retorno1.prporg    = ws.grlinf[16,17]
        let retorno1.prpnumdig = ws.grlinf[18,25]
     else
        let retorno1.succod    = ws.grlinf[01,02]
        let retorno1.ramcod    = ws.grlinf[03,04]
        let retorno1.aplnumdig = ws.grlinf[05,12]
        let retorno1.prporg    = ws.grlinf[14,15]
        let retorno1.prpnumdig = ws.grlinf[16,24]
     end if



     if  g_issk.funmat = 601566 then
         display "*** cts28m00-retorno1.succod    = ", retorno1.succod
         display "             retorno1.ramcod    = ", retorno1.ramcod
         display "             retorno1.aplnumdig = ", retorno1.aplnumdig
         display "             retorno1.prporg    = ", retorno1.prporg
         display "             retorno1.prpnumdig = ", retorno1.prpnumdig
     end if
     if  retorno1.aplnumdig is not null then
         let ws.doctxt = " Suc: " ,retorno1.succod    using "&&",
                         " Ramo: ",retorno1.ramcod    using "&&&&",
                         " Apl: " ,retorno1.aplnumdig using "<<<<<<<&&"
     else
         if  retorno1.prpnumdig is not null then
             let ws.doctxt = " Proposta: ", retorno1.prporg using "&&",
                                    " ", retorno1.prpnumdig using "<<<<<<<&&"
         end if
     end if
     if ws.doctxt is not null then
        while true
          initialize ws.confirma to null

          let ws.confirma = cts08g01("A","S",
                                     "A apolice informada para esse sinistro  ",
                                     "tem direito a remocao do veiculo, anote ",
                                     "a apolice. Duvidas consulte a supervisao",
                                     ws.doctxt)

          if ws.confirma = "S" then
             exit while
          else
             initialize ws.comando to null
             prompt "*** VOCE LEU O ALERTA ? (S)im ou (N)ao "
                    attribute(reverse) for char ws.comando
             display "*** ws.comando = ", ws.comando
             if ws.comando is null or
                ws.comando =  " "  then
                let ws.comando = "N"
             end if
             if ws.comando = "S" or
                ws.comando = "s" then
                exit while
             end if
          end if
        end while
     end if
     error " Inclusao efetuada com sucesso!"
     let ws.retorno = true

     exit while
   end while

   return ws.retorno
 end function

#--------------------------------------------------------------------
 function input_cts28m00()
#--------------------------------------------------------------------
   define hist_cts28m00 record
          hist1         like datmservhist.c24srvdsc,
          hist2         like datmservhist.c24srvdsc,
          hist3         like datmservhist.c24srvdsc,
          hist4         like datmservhist.c24srvdsc,
          hist5         like datmservhist.c24srvdsc
   end record
   define ws            record
          retflg        char (01),
          prpflg        char (01),
          confirma      char (01),
          sqlerro       integer,
          opcao         smallint,
          opcaodes      char(20),
          ofnstt        like sgokofi.ofnstt,
          ok_ins        dec(01,0),
          erro          dec(01,0),
          proced        char(09)
   end record
   define prompt_key     char (01)
   define erros_chk      char (01)
   define l_acesso       smallint

   define l_data      date,
          l_hora2     datetime hour to minute

	let	prompt_key  =  null
	let	erros_chk  =  null

	initialize  hist_cts28m00.*  to  null

	initialize  ws.*  to  null

   initialize ws.*  to null

   input by name d_cts28m00.nom        ,
                 d_cts28m00.corsus     ,
                 d_cts28m00.cornom     ,
                 d_cts28m00.sinrclddd  ,
                 d_cts28m00.sinrcltel  ,
                 d_cts28m00.tiposinis  ,
                 d_cts28m00.sinntzcod  ,
                 d_cts28m00.dscacidente,
                 a_cts28m00[1].lgdtxt   ,
                 a_cts28m00[1].lclbrrnom,
                 a_cts28m00[1].cidnom   ,
                 a_cts28m00[1].ufdcod   ,
                 a_cts28m00[1].lclrefptotxt,
                 a_cts28m00[1].endzon   ,
                 a_cts28m00[1].lclcttnom,
                 d_cts28m00.sinocrdat  ,
                 d_cts28m00.sinocrhor  ,
                 d_cts28m00.tipotransp ,
                 d_cts28m00.flgorigdes ,
                 d_cts28m00.flgbensatg ,
              #  d_cts28m00.imsvlr     ,
                 d_cts28m00.flgbenster ,
                 d_cts28m00.histatd    without defaults

     before field nom
       display by name d_cts28m00.nom        attribute (reverse)

     after  field nom
       display by name d_cts28m00.nom

       if g_documento.acao = "CON" then
             error " Servico sendo consultado, nao pode ser alterado!"
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                  returning ws.confirma
             next field nom
       end if
       if d_cts28m00.nom is null or
          d_cts28m00.nom =  "  " then
          error " Nome deve ser informado!"
          next field nom
       end if
       if w_cts28m00.atdfnlflg = "S"  then
          error " Servico ja' acionado nao pode ser alterado!"
          let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***","","","")

          exit input
       end if

     before field corsus
       display by name d_cts28m00.corsus     attribute (reverse)

     after  field corsus
       display by name d_cts28m00.corsus

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if d_cts28m00.corsus is not null  then
             select cornom
               into d_cts28m00.cornom
               from gcaksusep, gcakcorr
              where gcaksusep.corsus   = d_cts28m00.corsus    and
                    gcakcorr.corsuspcp = gcaksusep.corsuspcp
             if sqlca.sqlcode = notfound  then
                error " Susep do corretor nao cadastrada!"
                next field corsus
             else
                display by name d_cts28m00.cornom
                next field sinrclddd
             end if
          end if
       end if

     before field cornom
       display by name d_cts28m00.cornom     attribute (reverse)

     after  field cornom
       display by name d_cts28m00.cornom

     before field sinrclddd
       display by name d_cts28m00.sinrclddd  attribute (reverse)

     after  field sinrclddd
       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          if d_cts28m00.corsus is not null  then
             next field corsus
          else
             next field cornom
          end if
       else
          if d_cts28m00.sinrclddd is null or
             d_cts28m00.sinrclddd =  0    then
             error "DDD do reclamante do sinistro e obrigatorio"
             next field sinrclddd
          end if
       end if

     before field sinrcltel
       display by name d_cts28m00.sinrcltel  attribute (reverse)

     after  field sinrcltel
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field sinrclddd
       else
          if d_cts28m00.sinrcltel is null or
             d_cts28m00.sinrcltel  = 0    then
             error "Telefone do reclamante do sinistro e obrigatorio"
             next field sinrcltel
          end if
       end if

    before field tiposinis
       display by name d_cts28m00.tiposinis  attribute (reverse)

    after field tiposinis
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field sinrcltel
       else
          if d_cts28m00.tiposinis is null then
             error "Tipo de Sinistro invalido, escolha 1,2 ou 3"
             next field tiposinis
          end if
          if d_cts28m00.tiposinis < "1"       and
             d_cts28m00.tiposinis > "3"       then
             error "Tipo de sinistro invalido, escolha 1,2 ou 3"
             next field tiposinis
          end if
          ----------------[ para laudos em branco - sem docto ]-----------
          select grlinf[01,10] into m_dtresol86
             from datkgeral
             where grlchv='ct24resolucao86'

          call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
          if g_documento.aplnumdig is null then
             if d_cts28m00.tiposinis  =  "1" or
                d_cts28m00.tiposinis  =  "3" then   # acidente/outros
                if m_dtresol86 <= l_data then
                   let g_documento.ramcod = 654
                else
                   let g_documento.ramcod = 54
                end if
             end if
             if d_cts28m00.tiposinis  =  "2"  then   # roubo
                if m_dtresol86 <= l_data then
                   let g_documento.ramcod = 655
                else
                   let g_documento.ramcod = 55
                end if
             end if
          end if
       end if

    before field sinntzcod
       display by name d_cts28m00.sinntzcod  attribute (reverse)

    after field sinntzcod
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field tiposinis
       else
          call fsstc009(d_cts28m00.tiposinis)
                   returning ws.erro,
                             d_cts28m00.sinntzcod,
                             d_cts28m00.sinntzdes
          if ws.erro <> 0 then
             error "Natureza do sinistro e obrigatorio"
             next field sinntzcod
          end if
          display by name d_cts28m00.sinntzdes
       end if

    before field dscacidente
       display by name d_cts28m00.dscacidente attribute (reverse)

    after  field dscacidente
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field sinntzcod
       else
          let w_cts28m00.descacidente = cts28m03(w_cts28m00.descacidente)

       end if
       ----------[ verifica se o sinistro foi fora do pais ]-----------------
      #initialize a_cts28m00 to null
       let ws.confirma = cts08g01_inverte( "C","S","",
                                           "SINISTRO OCORREU NO BRASIL ?",
                                           "","")
       if ws.confirma = "S" then
          let w_cts28m00.despais = "BRASIL"
          let d_cts28m00.sinocrpainom = w_cts28m00.despais
       else
          -----[ laudo em branco e sinistro fora do Brasil, ramo = 24 ]------
          if g_documento.aplnumdig is null then
             call cts40g03_data_hora_banco(2)
                returning l_data, l_hora2
             if m_dtresol86 <= l_data then
                let g_documento.ramcod = 632   # RCTR-VI Mercosul
             else
                let g_documento.ramcod = 24   # RCTR-VI Mercosul
             end if
          end if
          -------------------------------------------------------------------
          call fsstc012() returning ws.erro,
                                    w_cts28m00.codpais,
                                    w_cts28m00.despais
          if w_cts28m00.codpais is not null then
             let a_cts28m00[1].ufdcod    = "EX"
             let a_cts28m00[1].lclidttxt = w_cts28m00.despais
          else
             let ws.confirma = cts08g01 ( "A","N",
                                          "SE O PAIS ONDE  OCORREU O  SINISTRO  NAO",
                                          "ESTIVER RELACIONADO  NA  TABELA  EXIBIDA",
                                          "ANTERIORMENTE, PREENCHA O  LAUDO  MANUAL",
                                          "E COMUNIQUE A COORDENACAO.              ")
             if g_documento.atdsrvnum is null  or
                g_documento.atdsrvano is null  then
                let ws.confirma = cts08g01( "C","S","",
                                            "ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
                if ws.confirma  =  "S"   then
                   let int_flag = true
                   exit input
                else
                   next field dscacidente
                end if
             else
                exit input
             end if
          end if
          display by name d_cts28m00.sinocrpainom
       end if
       -----------------[ obter o endereco da ocorrencia ]-------------------
       let a_cts28m00[1].dddcod    = d_cts28m00.sinrclddd
       let a_cts28m00[1].lcltelnum = d_cts28m00.sinrcltel
       let a_cts28m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
       let m_acesso_ind = false
       let m_atdsrvorg = 16
       call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
            returning m_acesso_ind
       if m_acesso_ind = false then
          call cts06g03(1
                       ,m_atdsrvorg
                       ,w_cts28m00.ligcvntip
                       ,aux_today
                       ,aux_hora
                       ,a_cts28m00[1].lclidttxt
                       ,a_cts28m00[1].cidnom
                       ,a_cts28m00[1].ufdcod
                       ,a_cts28m00[1].brrnom
                       ,a_cts28m00[1].lclbrrnom
                       ,a_cts28m00[1].endzon
                       ,a_cts28m00[1].lgdtip
                       ,a_cts28m00[1].lgdnom
                       ,a_cts28m00[1].lgdnum
                       ,a_cts28m00[1].lgdcep
                       ,a_cts28m00[1].lgdcepcmp
                       ,a_cts28m00[1].lclltt
                       ,a_cts28m00[1].lcllgt
                       ,a_cts28m00[1].lclrefptotxt
                       ,a_cts28m00[1].lclcttnom
                       ,a_cts28m00[1].dddcod
                       ,a_cts28m00[1].lcltelnum
                       ,a_cts28m00[1].c24lclpdrcod
                       ,a_cts28m00[1].ofnnumdig
                       ,a_cts28m00[1].celteldddcod
                       ,a_cts28m00[1].celtelnum
                       ,a_cts28m00[1].endcmp
                       ,hist_cts28m00.*
                       ,a_cts28m00[1].emeviacod )
             returning a_cts28m00[1].lclidttxt
                      ,a_cts28m00[1].cidnom
                      ,a_cts28m00[1].ufdcod
                      ,a_cts28m00[1].brrnom
                      ,a_cts28m00[1].lclbrrnom
                      ,a_cts28m00[1].endzon
                      ,a_cts28m00[1].lgdtip
                      ,a_cts28m00[1].lgdnom
                      ,a_cts28m00[1].lgdnum
                      ,a_cts28m00[1].lgdcep
                      ,a_cts28m00[1].lgdcepcmp
                      ,a_cts28m00[1].lclltt
                      ,a_cts28m00[1].lcllgt
                      ,a_cts28m00[1].lclrefptotxt
                      ,a_cts28m00[1].lclcttnom
                      ,a_cts28m00[1].dddcod
                      ,a_cts28m00[1].lcltelnum
                      ,a_cts28m00[1].c24lclpdrcod
                      ,a_cts28m00[1].ofnnumdig
                      ,a_cts28m00[1].celteldddcod
                      ,a_cts28m00[1].celtelnum
                      ,a_cts28m00[1].endcmp
                      ,ws.retflg
                      ,hist_cts28m00.*
                      ,a_cts28m00[1].emeviacod
       else
          call cts06g11(1
                       ,m_atdsrvorg
                       ,w_cts28m00.ligcvntip
                       ,aux_today
                       ,aux_hora
                       ,a_cts28m00[1].lclidttxt
                       ,a_cts28m00[1].cidnom
                       ,a_cts28m00[1].ufdcod
                       ,a_cts28m00[1].brrnom
                       ,a_cts28m00[1].lclbrrnom
                       ,a_cts28m00[1].endzon
                       ,a_cts28m00[1].lgdtip
                       ,a_cts28m00[1].lgdnom
                       ,a_cts28m00[1].lgdnum
                       ,a_cts28m00[1].lgdcep
                       ,a_cts28m00[1].lgdcepcmp
                       ,a_cts28m00[1].lclltt
                       ,a_cts28m00[1].lcllgt
                       ,a_cts28m00[1].lclrefptotxt
                       ,a_cts28m00[1].lclcttnom
                       ,a_cts28m00[1].dddcod
                       ,a_cts28m00[1].lcltelnum
                       ,a_cts28m00[1].c24lclpdrcod
                       ,a_cts28m00[1].ofnnumdig
                       ,a_cts28m00[1].celteldddcod
                       ,a_cts28m00[1].celtelnum
                       ,a_cts28m00[1].endcmp
                       ,hist_cts28m00.*
                       ,a_cts28m00[1].emeviacod )
             returning a_cts28m00[1].lclidttxt
                      ,a_cts28m00[1].cidnom
                      ,a_cts28m00[1].ufdcod
                      ,a_cts28m00[1].brrnom
                      ,a_cts28m00[1].lclbrrnom
                      ,a_cts28m00[1].endzon
                      ,a_cts28m00[1].lgdtip
                      ,a_cts28m00[1].lgdnom
                      ,a_cts28m00[1].lgdnum
                      ,a_cts28m00[1].lgdcep
                      ,a_cts28m00[1].lgdcepcmp
                      ,a_cts28m00[1].lclltt
                      ,a_cts28m00[1].lcllgt
                      ,a_cts28m00[1].lclrefptotxt
                      ,a_cts28m00[1].lclcttnom
                      ,a_cts28m00[1].dddcod
                      ,a_cts28m00[1].lcltelnum
                      ,a_cts28m00[1].c24lclpdrcod
                      ,a_cts28m00[1].ofnnumdig
                      ,a_cts28m00[1].celteldddcod
                      ,a_cts28m00[1].celtelnum
                      ,a_cts28m00[1].endcmp
                      ,ws.retflg
                      ,hist_cts28m00.*
                      ,a_cts28m00[1].emeviacod
       end if
          # PSI 244589 - Inclusão de Sub-Bairro - Burini
          let m_subbairro[1].lclbrrnom = a_cts28m00[1].lclbrrnom
          call cts06g10_monta_brr_subbrr(a_cts28m00[1].brrnom,
                                         a_cts28m00[1].lclbrrnom)
               returning a_cts28m00[1].lclbrrnom

          let a_cts28m00[1].lgdtxt = a_cts28m00[1].lgdtip clipped, " ",
                                     a_cts28m00[1].lgdnom clipped, " ",
                                     a_cts28m00[1].lgdnum using "<<<<#"
          display by name a_cts28m00[1].lgdtxt
         #display by name a_cts28m00[1].lgdcep
         #display by name a_cts28m00[1].lgdcepcmp
          display by name a_cts28m00[1].lclbrrnom
          display by name a_cts28m00[1].cidnom
          display by name a_cts28m00[1].ufdcod
          display by name a_cts28m00[1].lclrefptotxt
          display by name a_cts28m00[1].endzon
          display by name a_cts28m00[1].lclcttnom
         #display by name a_cts28m00[1].dddcod
         #display by name a_cts28m00[1].lcltelnum
          let d_cts28m00.sinrclddd = a_cts28m00[1].dddcod
          let d_cts28m00.sinrcltel = a_cts28m00[1].lcltelnum
          display by name d_cts28m00.sinrclddd
          display by name d_cts28m00.sinrcltel
          display by name a_cts28m00[1].endcmp
          if a_cts28m00[1].ufdcod    = "EX" then  # sinistro fora do Brasil.
             let ws.retflg = "S"
          end if
          if ws.retflg = "N"  then
             error " Dados referentes ao local incorretos ou",
                   " nao preenchidos!"
             next field sinntzcod
          else
             next field sinocrdat
          end if

    before field sinocrdat
       display by name d_cts28m00.sinocrdat  attribute (reverse)

    after field sinocrdat
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field dscacidente
       else
          if d_cts28m00.sinocrdat is null then
             error " Data do sinistro deve ser informada"
             next field sinocrdat
          end if
          call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
          if d_cts28m00.sinocrdat < l_data - 366 units day  then
             let ws.confirma = cts08g01( "A","N","","DATA DO SINISTRO INFORMADA E'",
                                         "ANTERIOR A  1 (UM) ANO !","")

             next field sinocrdat
          end if
          if d_cts28m00.sinocrdat > l_data   then
             error " Data do sinistro nao deve ser maior que hoje!"
             next field sinocrdat
          end if
       end if

    before field sinocrhor
       display by name d_cts28m00.sinocrhor attribute (reverse)

    after  field sinocrhor
       display by name d_cts28m00.sinocrhor

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts28m00.sinocrhor is null  then
             error " Hora do sinistro deve ser informada!"
             next field sinocrhor
          end if
          call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
          if d_cts28m00.sinocrdat =  l_data     and
             d_cts28m00.sinocrhor <> "00:00"   and
             d_cts28m00.sinocrhor >  aux_hora  then
             error " Hora do sinistro nao deve ser maior que hora atual!"
             next field sinocrhor
          end if
       end if

    before field tipotransp
       display by name d_cts28m00.tipotransp attribute (reverse)

    after field tipotransp
       display by name d_cts28m00.tipotransp
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field sinocrhor
       else
          if d_cts28m00.tipotransp is null then
             error "Tipo de transporte invalido, escolha 1,2 ou 4"
             next field tipotransp
          end if
          if d_cts28m00.tipotransp is not null then
             if d_cts28m00.tipotransp < "1"    or
                d_cts28m00.tipotransp > "4"    then
                error "Tipo de transporte invalido, escolha 1,2 ou 4"
                next field tipotransp
             end if
          end if
          if d_cts28m00.tipotransp = "3"  then
             error "Tipo de transporte invalido, escolha 1,2 ou 4"
             next field tipotransp
          end if
          if d_cts28m00.tipotransp = "1"  then
             if g_documento.ramcod <> 21 and  g_documento.ramcod <> 621 and
                g_documento.ramcod <> 22 and  g_documento.ramcod <> 622 and
                g_documento.ramcod <> 35 and  g_documento.ramcod <> 435 and
                g_documento.ramcod <> 52 and  g_documento.ramcod <> 652 then
                #error "Tipo transp. Aereo somente para ramos 21,22,35,52"
                error "Ramo Invalido para Tipo de Transporte Aereo."
                next field tipotransp
             end if
             let w_cts28m00.trptipflg = 1
             call fsstc010("","","",w_cts28m00.trptipflg)
                       returning ws.erro,
                                 w_cts28m00.motorista,
                                 w_cts28m00.vclmrccod,
                                 w_cts28m00.vcltipcod,
                                 w_cts28m00.vclcoddig,
                                 w_cts28m00.cor1,
                                 w_cts28m00.placa1,
                                 w_cts28m00.vclmrccod2,
                                 w_cts28m00.vcltipcod2,
                                 w_cts28m00.vclcoddig2,
                                 w_cts28m00.cor2,
                                 w_cts28m00.placa2,
                                 w_cts28m00.vclmrccod3,
                                 w_cts28m00.vcltipcod3,
                                 w_cts28m00.vclcoddig3,
                                 w_cts28m00.cor3,
                                 w_cts28m00.placa3,
                                 w_cts28m00.nom_marin ,
                                 w_cts28m00.embarcacao,
                                 w_cts28m00.ating_pess,
                                 w_cts28m00.qtd_pess ,
                                 w_cts28m00.aeronave
             if w_cts28m00.qtd_pess is null or
                w_cts28m00.aeronave is null then
                error "Qtd pessoas atingidas/Descr.Aeronave Invalida"
                next field tipotransp
             end if
             next field flgorigdes
          end if
          if d_cts28m00.tipotransp = "2"   then
             if g_documento.ramcod <> 22 and g_documento.ramcod <> 622 and
                g_documento.ramcod <> 33 and g_documento.ramcod <> 433 and
                g_documento.ramcod <> 54 and g_documento.ramcod <> 654 and
                g_documento.ramcod <> 55 and g_documento.ramcod <> 655 and
                g_documento.ramcod <> 56 and g_documento.ramcod <> 656 then
                #error "Tipo transp. Maritima somente para",
                #     " ramos 622,433,654,655,656"
                error "Ramo Invalido para Tipo de Transporte Maritima."
                next field tipotransp
             end if
             let w_cts28m00.trptipflg = 2
             call fsstc010("","","",w_cts28m00.trptipflg)
                       returning ws.erro,
                                 w_cts28m00.motorista,
                                 w_cts28m00.vclmrccod,
                                 w_cts28m00.vcltipcod,
                                 w_cts28m00.vclcoddig,
                                 w_cts28m00.cor1,
                                 w_cts28m00.placa1,
                                 w_cts28m00.vclmrccod2,
                                 w_cts28m00.vcltipcod2,
                                 w_cts28m00.vclcoddig2,
                                 w_cts28m00.cor2,
                                 w_cts28m00.placa2,
                                 w_cts28m00.vclmrccod3,
                                 w_cts28m00.vcltipcod3,
                                 w_cts28m00.vclcoddig3,
                                 w_cts28m00.cor3,
                                 w_cts28m00.placa3,
                                 w_cts28m00.nom_marin ,
                                 w_cts28m00.embarcacao,
                                 w_cts28m00.ating_pess,
                                 w_cts28m00.qtd_pess ,
                                 w_cts28m00.aeronave
             if w_cts28m00.nom_marin  is null or
                w_cts28m00.embarcacao is null then
                error "Dados da Embarcacao Invalido"
                next field tipotransp
             end if
             next field flgorigdes
          end if
          if d_cts28m00.tipotransp  = "4"  then
             if g_documento.ramcod <> 21 and g_documento.ramcod <> 621 and
                g_documento.ramcod <> 22 and g_documento.ramcod <> 622 and
                g_documento.ramcod <> 24 and g_documento.ramcod <> 632 and
                g_documento.ramcod <> 54 and g_documento.ramcod <> 654 and
                g_documento.ramcod <> 55 and g_documento.ramcod <> 655 then
                #error "Tipo transp. Terrestre somente para ",
                #     " ramos 621,622,632,654,655"
                error "Ramo Invalido para Tipo de Transporte Terrestre."
                next field tipotransp
             end if
             let w_cts28m00.trptipflg = 4
             call fsstc010("","","",w_cts28m00.trptipflg)
                          returning ws.erro,
                                    w_cts28m00.motorista,
                                    w_cts28m00.vclmrccod,
                                    w_cts28m00.vcltipcod,
                                    w_cts28m00.vclcoddig,
                                    w_cts28m00.cor1,
                                    w_cts28m00.placa1,
                                    w_cts28m00.vclmrccod2,
                                    w_cts28m00.vcltipcod2,
                                    w_cts28m00.vclcoddig2,
                                    w_cts28m00.cor2,
                                    w_cts28m00.placa2,
                                    w_cts28m00.vclmrccod3,
                                    w_cts28m00.vcltipcod3,
                                    w_cts28m00.vclcoddig3,
                                    w_cts28m00.cor3,
                                    w_cts28m00.placa3,
                                    w_cts28m00.nom_marin ,
                                    w_cts28m00.embarcacao,
                                    w_cts28m00.ating_pess,
                                    w_cts28m00.qtd_pess ,
                                    w_cts28m00.aeronave
             next field flgorigdes
          end if
       end if

    before field flgorigdes
       display by name d_cts28m00.flgorigdes  attribute (reverse)

    after  field flgorigdes
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field tipotransp
       else
          call fsstc016("","","") returning ws.erro,
                                            w_cts28m00.datini   ,
                                            w_cts28m00.transp   ,
                                            w_cts28m00.orguf    ,
                                            w_cts28m00.orgcid   ,
                                            w_cts28m00.dstuf    ,
                                            w_cts28m00.dstcid   ,
                                            w_cts28m00.orgpais  ,
                                            w_cts28m00.dstpais
       end if

    before field flgbensatg
       display by name d_cts28m00.flgbensatg  attribute (reverse)

    after  field flgbensatg
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field flgorigdes
       else
          call fsstc011("","","") returning ws.erro,
                                            w_cts28m00.val_carga,
                                            w_cts28m00.pct_danos,
                                            w_cts28m00.prov_soc,
                                            w_cts28m00.ies_guincho,
                                            w_cts28m00.sit_carga,
                                            w_cts28m00.g_carga
          if w_cts28m00.val_carga   is null or
             w_cts28m00.pct_danos   is null or
             w_cts28m00.prov_soc    is null or
             w_cts28m00.ies_guincho is null or
             w_cts28m00.sit_carga   is null or
             w_cts28m00.g_carga     is null then
             error "Dados dos Bens Atingidos Invalido"
             next field flgbensatg
          end if
       end if

 #  before field imsvlr
 #     display by name d_cts28m00.imsvlr     attribute (reverse)
 #
 #  after  field imsvlr
 #     display by name d_cts28m00.imsvlr     attribute (reverse)
 #     if fgl_lastkey() =  fgl_keyval("up")   or
 #        fgl_lastkey() =  fgl_keyval("left") then
 #        next field flgbensatg
 #     else
 #        if d_cts28m00.imsvlr is null then
 #           let d_cts28m00.imsvlr = 0
 #           display by name d_cts28m00.imsvlr
 #        end if
 #     end if

    before field flgbenster
       display by name d_cts28m00.flgbenster  attribute (reverse)

    after  field flgbenster
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
        # next field imsvlr
          next field flgbensatg
       else
          let w_cts28m00.descbensterc = cts28m01(w_cts28m00.descbensterc)

         #case g_documento.c24soltipcod
         #  when 1 let ws.proced = "MOTORISTA"
         #  when 2 let ws.proced = "POLICIARD"
         #  when 3 let ws.proced = "PONTOAPOI"
         #  when 4 let ws.proced = "SEG.CORRE"
         #end case
         #call fsstc018(g_documento.ramcod,ws.proced,20)
       end if

    before field histatd
       display by name d_cts28m00.histatd     attribute (reverse)

    after  field histatd
       if fgl_lastkey() =  fgl_keyval("up")   or
          fgl_lastkey() =  fgl_keyval("left") then
          next field flgbenster
       else
          call fsstc015("") returning ws.erro,
                                      w_cts28m00.histatd1
                                    # w_cts28m00.histatd2,
                                    # w_cts28m00.histatd3,
                                    # w_cts28m00.histatd4,
                                    # w_cts28m00.histatd5
          if g_issk.funmat = 601566 then
             display "histatd1 = ", w_cts28m00.histatd1
             display "histatd2 = ", w_cts28m00.histatd2
             display "histatd3 = ", w_cts28m00.histatd3
             display "histatd4 = ", w_cts28m00.histatd4
             display "histatd5 = ", w_cts28m00.histatd5
          end if
       end if
       -------------------[ ROTINA atdlibflg ]--------------------
       if g_documento.atdsrvnum is not null  and
          w_cts28m00.atdfnlflg   = "S"       then
          exit input
       end if
       if aux_libant is null  then
          if w_cts28m00.atdlibflg  =  "S"  then
             call cts40g03_data_hora_banco(2)
                returning l_data, l_hora2
             let aux_libhor           = l_hora2
             let d_cts28m00.atdlibhor = aux_libhor
             let d_cts28m00.atdlibdat = l_data
          end if
       end if

    on key (interrupt)
        if g_documento.atdsrvnum is null  or
           g_documento.atdsrvano is null  then
           let ws.confirma = cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
           if ws.confirma  =  "S"   then
              let int_flag = true
              exit input
           end if
        else
           exit input
        end if

    on key (F1)
        if d_cts28m00.c24astcod is not null then
           call ctc58m00_vis(d_cts28m00.c24astcod)
        end if

    on key (F3)
        call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

    on key (F5)
{
        if g_documento.succod    is not null  and
           g_documento.ramcod    is not null  and
           g_documento.aplnumdig is not null  then
           if g_documento.ramcod = 31  or
              g_documento.ramcod = 531  then
              call cta01m00()
           else
              call cta01m20()
           end if
        else
           if g_documento.prporg    is not null  and
              g_documento.prpnumdig is not null  then
              let ws.prpflg = opacc149(g_documento.prporg,g_documento.prpnumdig)
           else
              error " Espelho so' com documento localizado!"
           end if
        end if
}
         let g_monitor.horaini = current ## Flexvision
         call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

    on key (F6)
        if g_documento.atdsrvnum is null  then
           call cts10m02 (hist_cts28m00.*) returning hist_cts28m00.*
        else
           call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                         g_issk.funmat        , aux_today  ,aux_hora)
        end if

    on key (F7)
        call ctx14g00("Funcoes","DescrAcidente|DescrBensAtingidos|DescrBensAtingTerc|DescrTipoTransporte|Origem/Destino")
             returning ws.opcao,
                       ws.opcaodes
        case ws.opcao
             when 1 let w_cts28m00.descacidente = cts28m03( w_cts28m00.descacidente )

             when 2 call fsstc011(w_cts28m00.sinavsramcod,
                                  w_cts28m00.sinavsano   ,
                                  w_cts28m00.sinavsnum)
                        returning ws.erro,
                                  w_cts28m00.val_carga,
                                  w_cts28m00.pct_danos,
                                  w_cts28m00.prov_soc,
                                  w_cts28m00.ies_guincho,
                                  w_cts28m00.sit_carga,
                                  w_cts28m00.g_carga

             when 3 call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                                  g_issk.funmat        , aux_today  ,aux_hora)

             when 4 call fsstc010(w_cts28m00.sinavsramcod,
                                  w_cts28m00.sinavsano   ,
                                  w_cts28m00.sinavsnum   ,
                                  d_cts28m00.tipotransp)
                        returning ws.erro,
                                  w_cts28m00.motorista,
                                  w_cts28m00.vclmrccod,
                                  w_cts28m00.vcltipcod,
                                  w_cts28m00.vclcoddig,
                                  w_cts28m00.cor1,
                                  w_cts28m00.placa1,
                                  w_cts28m00.vclmrccod2,
                                  w_cts28m00.vcltipcod2,
                                  w_cts28m00.vclcoddig2,
                                  w_cts28m00.cor2,
                                  w_cts28m00.placa2,
                                  w_cts28m00.vclmrccod3,
                                  w_cts28m00.vcltipcod3,
                                  w_cts28m00.vclcoddig3,
                                  w_cts28m00.cor3,
                                  w_cts28m00.placa3,
                                  w_cts28m00.nom_marin ,
                                  w_cts28m00.embarcacao,
                                  w_cts28m00.ating_pess,
                                  w_cts28m00.qtd_pess ,
                                  w_cts28m00.aeronave

             when 5 call fsstc016(w_cts28m00.sinavsramcod,
                                  w_cts28m00.sinavsano   ,
                                  w_cts28m00.sinavsnum)
                        returning ws.erro,
                                  w_cts28m00.datini   ,
                                  w_cts28m00.transp   ,
                                  w_cts28m00.orguf    ,
                                  w_cts28m00.orgcid   ,
                                  w_cts28m00.dstuf    ,
                                  w_cts28m00.dstcid   ,
                                  w_cts28m00.orgpais  ,
                                  w_cts28m00.dstpais
        end case

    on key(F9)
        if g_documento.atdsrvnum is null and
           g_documento.atdsrvano is null then
        else
           if w_cts28m00.atdlibflg = "N"   then
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
   end input

   if int_flag  then
      error " Operacao cancelada!"
      initialize hist_cts28m00.* to null
   end if

   return hist_cts28m00.*

 end function
-------------------------[ INSERT TABELA SSTMSTPAVS ]---------------------------
 function cts28m00_grava_aviso_transp()
--------------------------------------------------------------------------------
   define ws  record
          sqlerro   integer,
          erro      dec(01,0),
          tabname   like systables.tabname
   end record

   define l_data       date,
          l_hora2      datetime hour to minute,
          l_hora1      datetime hour to second

	initialize  ws.*  to  null

   if g_issk.funmat = 601566 then
      display "**** TAB.AVS TRANSP - sstmstpavs "
   end if
   if w_cts28m00.sgrorg  is null then
      let w_cts28m00.sgrorg = 0
   end if
   if w_cts28m00.sgrnumdig  is null then
      let w_cts28m00.sgrnumdig = 0
   end if
   if w_cts28m00.dctnumseq  is null then
      let w_cts28m00.dctnumseq = 0
   end if
   if w_cts28m00.segnumdig  is null then
      let w_cts28m00.segnumdig = 0
   end if

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
   call cts40g03_data_hora_banco(1)
        returning l_data, l_hora1
   insert into  sstmstpavs
               (sinavsramcod, # ramo do aviso
                sinavsano   , # ano do aviso
                SINAVSNUM   , # numero do aviso de sinistro
                ramcod      , # ramo do sinistro
                sinano      , # ano do sinistro
                sinnum      , # numero do sinistro
                sgrorg      , # origem de proposta de seguro
                sgrnumdig   , # numero/digito de proposta de seguro
                dctnumseq   , # numero da sequencia do documento
                segnumdig   , # numero/digito do segurado
                sinavsdat   , # data do registro do aviso de sinistro
                sinavshor   , # hora do registro do aviso de sinistro
                stpavstip   , # tipo do reclamante do sinistro
                sinrclnom   , # nome do reclamante do sinistro
                sinrcltel   , # telefone do reclamante do sinistro
                sinrclrml   , # ramal do telefone do reclamante do sinistro
                sinrclddd   , # ddd do telefone do reclamante do sinistro
                sinntzcod   , # codigo da natureza do sinistro
                stpavshsttxt, # breve historico do ocorrido
                sinocrdat   , # data da ocorrencia
                sinocrhor   , # hora da ocorrencia
                sinocrlgdnom, # logradouro da ocorrencia
                sinocrcidnom, # nome da cidade da ocorrencia
                sinocrufd   , # UF da cidade da ocorrencia
                sinocrpainom, # Pais da ocorrencia
                sinocrptoref, # ponto de referencia
                stpocrroddes, # sigla da rodovia que ocorreu o sinistro
                stpocrklmdes, # KM da rodovia que ocorreu o sinistro
                prdtipcod   , # tipo de perda
                trptipflg   , # tipo de transporte
                trpembtipflg, # fluxo embarque
                lbrpgtflg   , # flag do processo
                atldat      , # data do atendimento
                atlhor      , # hora do atendimento
                atlmat      , # matricula do atendente
                atlemp      , # empresa do atendente
                atlusrtip   , # tipo de pessoa do atendente
                imsvlr      , # importancia segurada
                stprsplimvlr, # limite de responsabilidade
                stpprjetmvlr, # estimativa de prejuizo
                sincncflg   , # flag de conclusao pelo coordenador
                segpsvnom   , # nome do possivel segurado
                vgmincdat   ,
                trpnom      ,
                emborgufd   ,
                emborglgdcidnom,
                emborgpaides)

        values (g_documento.ramcod,      # ramo do aviso de sinistro
                aux_ano           ,      # ano do aviso de sinistro
                0                 ,      # numero do aviso de sinistro
                g_documento.ramcod,      # ramo do sinistro
                ""                ,      # ano do sinistro
                0                 ,      # numero do sinistro
                w_cts28m00.sgrorg ,      # origem de proposta de seguro
                w_cts28m00.sgrnumdig,    # numero/digito de proposta de seguro
                w_cts28m00.dctnumseq,    # numero da sequencia do documento
                w_cts28m00.segnumdig,    # numero/digito do segurado
                l_data              ,    # data do registro do aviso de sinistro
                l_hora2             ,    # hora do registro do aviso de sinistro
                g_documento.c24soltipcod,# tipo do reclamante do sinistro
                g_documento.solnom   ,   # nome do reclamante do sinistro
                d_cts28m00.sinrcltel ,   # telefone do reclamante do sinistro
                ""                   ,   # ramal do tel.do reclamante do sinis.
                d_cts28m00.sinrclddd ,   # ddd do tel.do reclamante do sinistro
                d_cts28m00.sinntzcod ,   # codigo da natureza do sinistro
                w_cts28m00.descacidente, # breve historico do ocorrido
                d_cts28m00.sinocrdat ,   # data da ocorrencia
                d_cts28m00.sinocrhor ,   # hora da ocorrencia
                a_cts28m00[1].lgdtxt,    # logradouro da ocorrencia
                a_cts28m00[1].cidnom,    # nome da cidade da ocorrencia
                a_cts28m00[1].ufdcod,    # UF da cidade da ocorrencia
                w_cts28m00.despais  ,    # Pais da ocorrencia
                a_cts28m00[1].lclrefptotxt,# ponto de referencia
                "",                      # sigla da rodovia que ocorreu o sinis.
                "",                      # KM da rodovia que ocorreu o sinistro
                2,                       # tipo de perda
                w_cts28m00.trptipflg ,   # tipo de transporte
                " ",                     # fluxo embarque
                "N",                     # flag do processo
                l_data               ,   # data do atendimento
                l_hora1               ,  # hora do atendimento
                g_issk.funmat        ,   # matricula do atendente
                g_issk.empcod        ,   # empresa do atendente
                g_issk.usrtip        ,   # tipo de pessoa do atendente
              # d_cts28m00.imsvlr    ,   # importancia segurada
                0                    ,   # importancia segurada
                0                    ,   # limite de responsabilidade
                0                    ,   # estimativa de prejuizo
                "N"                  ,   # flag de conclusao pelo coordenador
                d_cts28m00.nom       ,   # nome do possivel segurado
                w_cts28m00.datini    ,   # data do embarque
                w_cts28m00.transp    ,   # nome da transportadora
                w_cts28m00.orguf     ,   # uf origem
                w_cts28m00.orgcid    ,   # cidade origem
                w_cts28m00.orgpais   )   # pais origem
   if sqlca.sqlcode <> 0 then
      let ws.sqlerro = sqlca.sqlcode
      let ws.tabname = "sstmstpavs"
      initialize w_cts28m00.sinavsnum to null
      return w_cts28m00.sinavsnum,
             ws.erro,
             ws.sqlerro,
             ws.tabname
   else
      let w_cts28m00.sinavsnum = sqlca.sqlerrd[2]
   end if
   if g_issk.funmat = 601566 then
      display "**** TAB.AVS TRANSP - fsstc020 "
      display "g_documento.ramcod = ", g_documento.ramcod
      display "sinavsanp          = ", aux_ano
      display "sinavsnum          = ", w_cts28m00.sinavsnum
   end if
   call fsstc020(g_documento.ramcod,
                 aux_ano,
                 w_cts28m00.sinavsnum,
                 g_issk.funmat,
                 g_issk.empcod,
                 g_issk.usrtip,
                 w_cts28m00.histatd1,
                #w_cts28m00.histatd2,
                #w_cts28m00.histatd3,
                #w_cts28m00.histatd4,
                #w_cts28m00.histatd5,
                 w_cts28m00.val_carga,
                 w_cts28m00.pct_danos,
                 w_cts28m00.prov_soc,
                 w_cts28m00.ies_guincho,
                 w_cts28m00.sit_carga,
                 w_cts28m00.g_carga,
                 w_cts28m00.trptipflg,
                 w_cts28m00.vclmrccod,
                 w_cts28m00.vcltipcod,
                 w_cts28m00.vclcoddig,
                 w_cts28m00.cor1,
                 w_cts28m00.placa1,
                 w_cts28m00.vclmrccod2,
                 w_cts28m00.vcltipcod2,
                 w_cts28m00.vclcoddig2,
                 w_cts28m00.cor2,
                 w_cts28m00.placa2,
                 w_cts28m00.vclmrccod3,
                 w_cts28m00.vcltipcod3,
                 w_cts28m00.vclcoddig3,
                 w_cts28m00.cor3,
                 w_cts28m00.placa3,
                 w_cts28m00.embarcacao,
                 w_cts28m00.nom_marin,
                 w_cts28m00.qtd_pess,
                 w_cts28m00.aeronave,
                 w_cts28m00.motorista,
                 w_cts28m00.dstuf,
                 w_cts28m00.dstpais,
                 w_cts28m00.dstcid)   returning ws.erro,
                                                ws.sqlerro,
                                                ws.tabname
   if g_issk.funmat = 601566 then
      display "retorno fsstc020, ws.erro    = ", ws.erro
      display "                  ws.sqlerro = ", ws.sqlerro
      display "                  ws.tabname = ", ws.tabname
   end if
   return w_cts28m00.sinavsnum,
          ws.erro,
          ws.sqlerro,
          ws.tabname
 end function
-----------------------[ fim do grava_aviso_transp ]------------------
