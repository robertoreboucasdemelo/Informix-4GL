###############################################################################
# Nome do Modulo: bdbsr086                                         Raji       #
# Gera relatorio acompanhamento da performace dos prestadores GPS  Set/2000   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 01/06/2001  Correio      Marcus       Incllusao Lendro Silva -PSocorro      #
###############################################################################
#-----------------------------------------------------------------------------#
# Alteracoes : Amaury em 13/02/2004 - CT 174530 - Inclusao with no log        #
#-----------------------------------------------------------------------------#
#                                                                             #
# Alteracoes : Adriana  26/03/2004 - CT 195170 - Subst.mailx por send_mail    #
#-----------------------------------------------------------------------------#
#                                                                             #
# Alteracoes : Cesar    14/05/2004 - CT 209325 - Alteracao dos e-mails p/ o   #
#                                                relatorio.                   #
#-----------------------------------------------------------------------------#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica      PSI    Alteracoes                             #
# ---------- ------------------ ------ ---------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

database porto

define m_path       char(100)

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr086.log"
    call startlog(m_path)
    # PSI 185035 - Final


    call bdbsr086()
    #set explain off
 end main

#-------------------------------------------------------------------------------
 function bdbsr086()
#-------------------------------------------------------------------------------

 define v_bdbsr086_bot record
        mdtcod       like datmmdtmvt.mdtcod,
        caddat       like datmmdtmvt.caddat,
        cadhor       like datmmdtmvt.cadhor,
        mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
        mdtmvtseq    like datmmdtmvt.mdtmvtseq,
        lclltt       like datmmdtmvt.lclltt,   # latitude  do veiculo QRU REC
        lcllgt       like datmmdtmvt.lcllgt    # longitude do veiculo QRU REC
 end record

 define v_bdbsr086_vcl record
        mdtcod       like datmmdtmvt.mdtcod,
        qradat       like datmmdtmvt.caddat,
        qrahor       like datmmdtmvt.cadhor,
        socvclcod    like datkveiculo.socvclcod,
        atdvclsgl    like datkveiculo.atdvclsgl,
        pstcoddig    like datkveiculo.pstcoddig,
        nomgrr       like dpaksocor.nomgrr
 end record

 define v_bdbsr086_out record
        # Informacoes QRA
        mdtcod       like datmmdtmvt.mdtcod,
        qradat       like datmmdtmvt.caddat,
        qrahor       like datmmdtmvt.cadhor,
        socvclcod    like datkveiculo.socvclcod,
        atdvclsgl    like datkveiculo.atdvclsgl,
        nomgrr       like dpaksocor.nomgrr,
        pstcoddig    like datkveiculo.pstcoddig,
        # Informacoes SERVICO
        atdhorpvt    like datmservico.atdhorpvt,
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        atdsrvorg    like datmservico.atdsrvorg,
        srrcoddig    like datmservico.srrcoddig,
        srrnom       like datksrr.srrnom,
        atdetpdat    like datmsrvacp.atdetpdat,
        atdetphor    like datmsrvacp.atdetphor,
        atdbrrnom    like datmlcl.brrnom,
        exclusao     char(30),
        distancia    dec (8,4),
        # Informacoes QRU REC
        qrurectmp    interval hour(06) to minute,
        qrurecdis    dec (8,4),
        # Informacoes QRU INI
        qruinitmp    interval hour(06) to minute,
        qruinidis    dec (8,4),
        # Informacoes QRU FIM
        qrufimtmp    interval hour(06) to minute,
        qrufimdis    dec (8,4)
 end record

 define bdbsr086_tmp record
        mdtmsgnum    like datmmdtmsg.mdtmsgnum,
        mdtcod       like datmmdtmsg.mdtcod
 end record

 define ws record
      g_traco     char(80),
      comando     char(500),
      data        date ,
      dirfisnom   like ibpkdirlog.dirfisnom,
      mdtmsgnum   like datmmdtmsg.mdtmsgnum,
      lclltt      like datmmdtmvt.lclltt,    # latitude  do servico
      lcllgt      like datmmdtmvt.lcllgt,    # longitude do servico
      srrltt      like datmservico.srrltt,   # latitude  do socorrista
      srrlgt      like datmservico.srrlgt,   # longitude do socorrista
      srrlttacn   like datmservico.srrltt,   # latitude  do socorrista acn
      srrlgtacn   like datmservico.srrlgt,   # longitude do socorrista acn
      mdtcod      like datmmdtmvt.mdtcod,
      pstcoddig   like dpaksocor.pstcoddig,
      dirfispst   like ibpkdirlog.dirfisnom,
      tmpespera   interval hour(06) to minute,
      disbot      dec (8,4),
      tod         date,
      len         smallint
 end record

 initialize v_bdbsr086_out.* to null

 let ws.g_traco = "--------------------------------------------------------------------------------"

 #--------------------------------------------------------------------
 # Define data parametro
 #--------------------------------------------------------------------
 let ws.data = arg_val(1)

 if ws.data is null       or
    ws.data =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.data = today
    else
       let ws.data = today - 1
    end if
 else
    if ws.data > today  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")
      returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare cur_botao cursor for
    select mdtcod,
           caddat,
           cadhor,
           mdtbotprgseq,
           mdtmvtseq,
           lclltt,
           lcllgt
    from  datmmdtmvt
    where caddat >= ws.data and
          mdtbotprgseq in (1,2,3,8) and mdtmvtstt = 2
    order by mdtcod, caddat, cadhor

    #---------------------------------------------------------------------------
    # Gera  tabela temporaria
    #---------------------------------------------------------------------------
      create temp table bdbsr086_tab( mdtmsgnum  integer,
                                      mdtcod     smallint ) with no log #CT174530
      #CT 7058966: Otimização do9 Programa.
      declare cur_temp cursor for
       select datmmdtmsg.mdtmsgnum,
              datmmdtmsg.mdtcod
         from datmmdtmsg, datmmdtsrv, datmmdtlog
        where mdtlogseq  = 1
          and atldat    >= ws.data
          and datmmdtsrv.atdsrvnum is not null
          and datmmdtsrv.atdsrvnum is not null
          and datmmdtmsg.mdtmsgnum = datmmdtsrv.mdtmsgnum
          and datmmdtlog.mdtmsgnum = datmmdtmsg.mdtmsgnum

      #----------------------------------------------------------------------
      # FOREACH principal tabela dtammdtmvt
      #----------------------------------------------------------------------
      foreach cur_temp into bdbsr086_tmp.*
       	insert into bdbsr086_tab
               values(bdbsr086_tmp.mdtmsgnum, bdbsr086_tmp.mdtcod)
      end foreach
      create index mdtcod_ix on bdbsr086_tab (mdtcod, mdtmsgnum)

    #---------------------------------------------------------------------------
    # Gera  tabela temporaria OUTPUT
    #---------------------------------------------------------------------------
      create temp table bdbsr086_tabout(
        # Informacoes QRA
        mdtcod       smallint,
        qradat       date,
        qrahor       datetime hour to minute,
        socvclcod    decimal(6,0),
        atdvclsgl    char(3),
        nomgrr       char(20),
        pstcoddig    decimal(6,0),
        # Informacoes SERVICO
        atdhorpvt    datetime hour to minute,
        atdsrvnum    decimal(10),
        atdsrvano    decimal(2),
        atdsrvorg    smallint,
        srrcoddig    decimal(8,0),
        srrnom       char(50),
        atdetpdat    date,
        atdetphor    datetime hour to minute,
        atdbrrnom    char(40),
        exclusao     char(30),
        distancia    dec (8,4),
        # Informacoes QRU REC
        qrurectmp    interval hour(06) to minute,
        qrurecdis    dec (8,4),
        # Informacoes QRU INI
        qruinitmp    interval hour(06) to minute,
        qruinidis    dec (8,4),
        # Informacoes QRU FIM
        qrufimtmp    interval hour(06) to minute,
        qrufimdis    dec (8,4)
        ) with no log #CT174530


 #---------------------------------------------------------------------------
 # FOREACH principal tabela datmmdtmvt
 #---------------------------------------------------------------------------
 let v_bdbsr086_vcl.mdtcod = ""
 foreach cur_botao into v_bdbsr086_bot.*
   if (v_bdbsr086_bot.caddat > ws.data and
       v_bdbsr086_bot.mdtbotprgseq = 1) or
      ws.mdtcod = v_bdbsr086_bot.mdtcod then
           let ws.mdtcod = v_bdbsr086_bot.mdtcod
           continue foreach
   end if
   if v_bdbsr086_vcl.mdtcod <> v_bdbsr086_bot.mdtcod or
      v_bdbsr086_vcl.mdtcod is null or
      v_bdbsr086_bot.mdtbotprgseq = 8 then
        if v_bdbsr086_bot.mdtbotprgseq <> 8 and
           v_bdbsr086_bot.mdtbotprgseq <> 1 then
           continue foreach
        end if

        #---------------------------------------------------------------
        # Busca veiculo pelo mdtcod
        #---------------------------------------------------------------
        select datkveiculo.socvclcod,
            datkveiculo.atdvclsgl,
            datkveiculo.pstcoddig into
            v_bdbsr086_vcl.socvclcod,
            v_bdbsr086_vcl.atdvclsgl,
            v_bdbsr086_vcl.pstcoddig
        from datkveiculo
        where datkveiculo.mdtcod = v_bdbsr086_bot.mdtcod
        select nomgrr
               into v_bdbsr086_vcl.nomgrr
          from dpaksocor
         where pstcoddig = v_bdbsr086_vcl.pstcoddig

        let v_bdbsr086_vcl.mdtcod    = v_bdbsr086_bot.mdtcod
        let v_bdbsr086_vcl.qradat    = v_bdbsr086_bot.caddat
        let v_bdbsr086_vcl.qrahor    = v_bdbsr086_bot.cadhor
   end if

   if v_bdbsr086_bot.mdtbotprgseq = 8 then
        continue foreach
   end if

   if v_bdbsr086_out.mdtcod = 0 or v_bdbsr086_out.mdtcod is null then
	let v_bdbsr086_out.mdtcod    = v_bdbsr086_vcl.mdtcod
	let v_bdbsr086_out.qradat    = v_bdbsr086_vcl.qradat
	let v_bdbsr086_out.qrahor    = v_bdbsr086_vcl.qrahor
	let v_bdbsr086_out.socvclcod = v_bdbsr086_vcl.socvclcod
	let v_bdbsr086_out.atdvclsgl = v_bdbsr086_vcl.atdvclsgl
        let v_bdbsr086_out.nomgrr    = v_bdbsr086_vcl.nomgrr
        let v_bdbsr086_out.pstcoddig = v_bdbsr086_vcl.pstcoddig

        #---------------------------------------------------------------
        # Busca mensagem
        #---------------------------------------------------------------
	select	max(bdbsr086_tab.mdtmsgnum) into ws.mdtmsgnum
        from    bdbsr086_tab, datmmdtlog
        where   bdbsr086_tab.mdtcod = v_bdbsr086_vcl.mdtcod and
                bdbsr086_tab.mdtmsgnum = datmmdtlog.mdtmsgnum and
                (datmmdtlog.atldat < v_bdbsr086_bot.caddat or
                 (datmmdtlog.atldat = v_bdbsr086_bot.caddat and
                  datmmdtlog.atlhor < v_bdbsr086_bot.cadhor))

        #---------------------------------------------------------------
        # Busca servico -> acionamento
        #---------------------------------------------------------------
	select	datmservico.atdsrvnum,
                datmservico.atdsrvano,
                datmservico.atdsrvorg,
                datmservico.atdhorpvt,
                datmservico.srrcoddig,
                datmsrvacp.atdetpdat,
                datmsrvacp.atdetphor,
                datmservico.srrltt,
                datmservico.srrlgt into
                v_bdbsr086_out.atdsrvnum,
		v_bdbsr086_out.atdsrvano,
		v_bdbsr086_out.atdsrvorg,
                v_bdbsr086_out.atdhorpvt,
		v_bdbsr086_out.srrcoddig,
		v_bdbsr086_out.atdetpdat,
		v_bdbsr086_out.atdetphor,
                ws.srrlttacn,
                ws.srrlgtacn
	from	datmmdtsrv, datmservico, datmsrvacp
	where	datmmdtsrv.mdtmsgnum = ws.mdtmsgnum and
		datmmdtsrv.atdsrvnum = datmservico.atdsrvnum and
		datmmdtsrv.atdsrvano = datmservico.atdsrvano and
		datmsrvacp.atdsrvnum = datmservico.atdsrvnum and
		datmsrvacp.atdsrvano = datmservico.atdsrvano and
		datmsrvacp.atdetpcod in (4, 3) and
		datmsrvacp.atdsrvseq = (select	max(a.atdsrvseq)
				from	datmsrvacp a
				where	a.atdsrvnum = datmsrvacp.atdsrvnum
					and a.atdsrvano = datmsrvacp.atdsrvano
		                        and a.atdetpcod in (4,3) )
        #---------------------------------------------------------------
        # Busca servico -> Local
        #---------------------------------------------------------------
	select	lclltt,
                lcllgt,
                brrnom  into
                ws.srrltt,
                ws.srrlgt,
                v_bdbsr086_out.atdbrrnom
	from	datmlcl
	where
		atdsrvnum = v_bdbsr086_out.atdsrvnum and
		atdsrvano = v_bdbsr086_out.atdsrvano and
                c24endtip = 1

        #---------------------------------------------------------------
        # Busca Nome do Socorrista
        #---------------------------------------------------------------
	select	srrnom into v_bdbsr086_out.srrnom
	from	datksrr
	where
		srrcoddig = v_bdbsr086_out.srrcoddig

        #---------------------------------------------------------------
        # Calcula distancia entre prestador no acionamento e segurado
        #---------------------------------------------------------------
        if (ws.srrltt = 0        and ws.srrlgt = 0)     or
           (ws.srrltt is NULL    and ws.srrlgt is NULL) or
           (ws.srrlttacn = 0     and ws.srrlgtacn = 0)     or
           (ws.srrlttacn is NULL and ws.srrlgtacn is NULL) then
           let v_bdbsr086_out.distancia = 0
        else
           let v_bdbsr086_out.distancia = cts18g00(ws.srrltt,    ws.srrlgt,
                                                   ws.srrlttacn, ws.srrlgtacn)
        end if
        #
   end if

   #---------------------------------------------------------------
   # Calcula Tempo de Espera BOTAO x ACIONAMENTO
   #---------------------------------------------------------------
   call bdbsr086_espera( v_bdbsr086_out.atdetpdat,
                         v_bdbsr086_out.atdetphor,
                         v_bdbsr086_bot.caddat,
                         v_bdbsr086_bot.cadhor)
        returning        ws.tmpespera
   #---------------------------------------------------------------
   # Calcula distancia entre prestador e segurado
   #---------------------------------------------------------------
   let ws.lclltt = v_bdbsr086_bot.lclltt
   let ws.lcllgt = v_bdbsr086_bot.lcllgt
   if (ws.srrltt = 0     and ws.srrlgt = 0)     or
      (ws.srrltt is NULL and ws.srrlgt is NULL) or
      (ws.lclltt = 0     and ws.lcllgt = 0)     or
      (ws.lclltt is NULL and ws.lcllgt is NULL) then
      let ws.disbot = 0
   else
      let ws.disbot = cts18g00(ws.srrltt, ws.srrlgt,
                               ws.lclltt, ws.lcllgt)
   end if

  if v_bdbsr086_bot.mdtbotprgseq = 1 then
      let v_bdbsr086_out.qrurectmp = ws.tmpespera
      let v_bdbsr086_out.qrurecdis = ws.disbot
  end if
  if v_bdbsr086_bot.mdtbotprgseq = 2 then
      let v_bdbsr086_out.qruinitmp = ws.tmpespera
      let v_bdbsr086_out.qruinidis = ws.disbot
  end if
  if v_bdbsr086_bot.mdtbotprgseq = 3 then
      let v_bdbsr086_out.qrufimtmp = ws.tmpespera
      let v_bdbsr086_out.qrufimdis = ws.disbot

      #---------------------------------------------------------------
      # Despresa servico re-acionados
      #---------------------------------------------------------------
      #if v_bdbsr086_out.qrurectmp < '00:00' then
      #   initialize v_bdbsr086_out.* to null
      #   initialize ws.srrltt,
      #              ws.srrlgt,
      #              ws.lclltt,
      #              ws.lcllgt   to null
      #   continue foreach
      #end if

      #---------------------------------------------------------------
      # Busca Exclusao do Servico
      #---------------------------------------------------------------
      select atdsrvnum
        from datmsrvanlhst
       where atdsrvnum = v_bdbsr086_out.atdsrvnum and
             atdsrvano = v_bdbsr086_out.atdsrvano and
             srvanlhstseq = 1 and
             c24evtcod = 1
      if sqlca.sqlcode = notfound then
             let v_bdbsr086_out.exclusao = "Nao"
      else
             let v_bdbsr086_out.exclusao = "Sim"
      end if

      insert into bdbsr086_tabout values(v_bdbsr086_out.*)

      initialize v_bdbsr086_out.* to null
      initialize ws.srrltt,
                 ws.srrlgt,
                 ws.lclltt,
                 ws.lcllgt   to null
  end if

 end foreach

 close cur_botao
 free cur_botao

 #---------------------------------------------------------------
 # Cria indice pela ordem de prestador
 #---------------------------------------------------------------
 create index prest_ix on bdbsr086_tabout (pstcoddig, mdtcod, qradat, qrahor)

 declare c_tabout cursor for
  select *
    from bdbsr086_tabout
  order by pstcoddig, mdtcod, qradat, qrahor

 # Relatorio por prestador
 let ws.pstcoddig = 0
 foreach c_tabout into v_bdbsr086_out.*

      if ws.pstcoddig <> v_bdbsr086_out.pstcoddig and
         ws.pstcoddig <> 0 then
          finish report bdbsr086_rpt
          call bdbsr086_mail(ws.dirfispst,
                             ws.pstcoddig)
          let ws.pstcoddig = 0
      end if

      if ws.pstcoddig = 0 then
         let ws.dirfispst = ws.dirfisnom clipped,
                            "/RDBS08601",
                            "_",
                            v_bdbsr086_out.pstcoddig using "&&&&&&"
         start report bdbsr086_rpt to ws.dirfispst
      end if

      output to report bdbsr086_rpt( v_bdbsr086_out.* )

      let ws.pstcoddig = v_bdbsr086_out.pstcoddig

 end foreach

 if ws.pstcoddig <> 0 then
     finish report bdbsr086_rpt
     call bdbsr086_mail(ws.dirfispst,
                        ws.pstcoddig)
 end if


 # Relatorio somarizado
 let ws.dirfispst = ws.dirfisnom clipped, "/RDBS08601"
 start report bdbsr086_rpt to ws.dirfispst
 foreach c_tabout into v_bdbsr086_out.*
      output to report bdbsr086_rpt( v_bdbsr086_out.* )
 end foreach
 finish report bdbsr086_rpt
 call bdbsr086_mail(ws.dirfispst,
                    0)

 end function



#----------------------------------------------------------------------------#
report bdbsr086_rpt(out)
#----------------------------------------------------------------------------#
 define out record
        # Informacoes QRA
        mdtcod       like datmmdtmvt.mdtcod,
        qradat       like datmmdtmvt.caddat,
        qrahor       like datmmdtmvt.cadhor,
        socvclcod    like datkveiculo.socvclcod,
        atdvclsgl    like datkveiculo.atdvclsgl,
        nomgrr       like dpaksocor.nomgrr,
        pstcoddig    like datkveiculo.pstcoddig,
        # Informacoes SERVICO
        atdhorpvt    like datmservico.atdhorpvt,
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        atdsrvorg    like datmservico.atdsrvorg,
        srrcoddig    like datmservico.srrcoddig,
        srrnom       like datksrr.srrnom,
        atdetpdat    like datmsrvacp.atdetpdat,
        atdetphor    like datmsrvacp.atdetphor,
        atdbrrnom    like datmlcl.brrnom,
        exclusao     char(30),
        distancia    dec (8,4),
        # Informacoes QRU REC
        qrurectmp    interval hour(06) to minute,
        qrurecdis    dec (8,4),
        # Informacoes QRU INI
        qruinitmp    interval hour(06) to minute,
        qruinidis    dec (8,4),
        # Informacoes QRU FIM
        qrufimtmp    interval hour(06) to minute,
        qrufimdis    dec (8,4)
 end record

  output
      left   margin  000
      top    margin  000
      bottom margin  000

  order external by out.pstcoddig,out.mdtcod,out.qradat,out.qrahor

  format
      first page header
           print "MDT","	",
                 "SIGLA","	",
                 "BASE","	",
                 "PROPRIETARIO","	",
                 "CODIGO SOCORISTA","	",
                 "SOCORRISTA","	",
                 "TMP.PREV.","	",
                 "SERVICO","	",
                 "ACN HORA","	",
                 "ACN DATA","	",
                 "ACN BAIRRO","	",
                 "ACN DISTANCIA","	",
                 "QRU REC TEMPO","	",
                 "QRU REC DISTANCIA","	",
                 "QRU INI TEMPO","	",
                 "QRU INI DISTANCIA","	",
                 "QRU FIM TEMPO","	",
                 "QRU FIM DISTANCIA","	",
                 "EXCLUSAO"
      on every row
           print out.mdtcod using "&&&&&","	",
                 out.atdvclsgl,"	",
                 out.pstcoddig using "&&&&&&","	",
                 out.nomgrr clipped,"	",
                 out.srrcoddig using "&&&&&&&&","	",
                 out.srrnom clipped,"	",
                 out.atdhorpvt clipped,"	",
                 out.atdsrvorg using "&&","/",
                               out.atdsrvnum using "&&&&&&&","-",
                               out.atdsrvano using "&&","	",
                 out.atdetphor,"	",
                 out.atdetpdat,"	",
                 out.atdbrrnom,"	",
                 out.distancia,"	",
                 bdbsr086_ltrim(out.qrurectmp) ,"	",
                 out.qrurecdis,"	",
                 bdbsr086_ltrim(out.qruinitmp) ,"	",
                 out.qruinidis,"	",
                 bdbsr086_ltrim(out.qrufimtmp) ,"	",
                 out.qrufimdis,"	",
                 out.exclusao
end report


#-----------------------------------------------------------
 function bdbsr086_espera(param)
#-----------------------------------------------------------
 define param        record
    dataini          date,
    horaini          datetime hour to minute,
    datafim          date,
    horafim          datetime hour to minute
 end record

 define ws           record
    resdat           integer,
    reshor           interval hour(06) to minute,
    chrhor           char (07)
 end record

 let ws.resdat = (param.datafim - param.dataini) * 24
 let ws.reshor = (param.horafim  - param.horaini)

 let ws.chrhor = ws.resdat using "###&" , ":00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

end function  ###  bdbsr086_espera

#-----------------------------------------------------------
function bdbsr086_ltrim(p_bdbsr086_ltrim)
#-----------------------------------------------------------
 define p_bdbsr086_ltrim char(80)
 define bdbsr086_flag smallint
 define bdbsr086_posi smallint

 let bdbsr086_flag = 1
 let bdbsr086_posi = 1
 while bdbsr086_flag = 1
    if p_bdbsr086_ltrim[bdbsr086_posi] = " " then
       let bdbsr086_posi =  bdbsr086_posi + 1
    else
       let bdbsr086_flag = 0
    end if
 end while
 let p_bdbsr086_ltrim = P_bdbsr086_ltrim[bdbsr086_posi,80]

 return p_bdbsr086_ltrim clipped
end function  ### bdbsr086_ltrim


#-----------------------------------------------------------
function bdbsr086_mail(p_bdbsr086_mail)
#-----------------------------------------------------------
 define p_bdbsr086_mail record
        arquivo         char(80),
        prestador       like dpaksocor.pstcoddig
 end record

 define comando        char(600)
 define l_retorno      smallint

 if p_bdbsr086_mail.prestador = 0 then
    # Relatorio somarizado
    # Inibido - CT  195170
    #let comando = "uuencode ",p_bdbsr086_mail.arquivo clipped, " ",
    #                        "Pst_GPS.xls | remsh U07 ",
    #              "mailx -r 'danubio_ct24h/spaulo_info_sistemas@u55'",
    #              " -s 'Relatorio_de_acomp_performance_dos_prestadores_",
    #              "_GPS' ",
    #              "ramos_soraya/spaulo_psocorro_qualidade@u23 ",
    #              "oliveira_milton/spaulo_psocorro_controles@u23 ",
    #              "oriente_eduardo/spaulo_psocorro_controles@u23 ",
    #              "silva_leandro/spaulo_psocorro_pagamentos@u23 ",
    #              "costa_roberto/spaulo_psocorro_qualidade@u23 ",
    #              "ponso_wilson/spaulo_psocorro_controles@u23'"
    #

     #-- CT 209325
     ### let comando = 'send_email.sh ' ,
     ###               ' -a ramos_soraya/spaulo_psocorro_qualidade@u23 ',
     ###               ' -cc oliveira_milton/spaulo_psocorro_controles@u23, ',
     ###               'oriente_eduardo/spaulo_psocorro_controles@u23, ',
     ###               'silva_leandro/spaulo_psocorro_pagamentos@u23,  ',
     ###               'costa_roberto/spaulo_psocorro_qualidade@u23, ',
     ###               'ponso_wilson/spaulo_psocorro_controles@u23',
     ###               ' -r danubio_ct24h/spaulo_info_sistemas@u55',
     ###               ' -s "Relatorio_de_acomp_performance_dos_prestadores_GPS"',
     ###               ' -f ',p_bdbsr086_mail.arquivo clipped,'Pst_GPS.xls '
     ### let comando = '/usr/bin/send_email.sh ' ,
	 ###         ' -a kiandra.antonello@correioporto',
	 ###         ' -cc milton.oliveira@correioporto,wilson.ponso@correioporto',
     ###             ' -r danubio_ct24h/spaulo_info_sistemas@u55',
     ###             ' -s "Relatorio_de_acomp_performance_dos_prestadores_GPS"',
     ###             ' -f ',p_bdbsr086_mail.arquivo clipped

     let comando = "Relatorio_de_acomp_performance_dos_prestadores_GPS"

     let l_retorno = ctx22g00_envia_email("BDBSR086",
                                          comando,
                                          p_bdbsr086_mail.arquivo)
     if l_retorno <> 0 then
        if l_retorno <> 99 then
           display "Erro de envio de email(cx22g00)- ",p_bdbsr086_mail.arquivo
        else
           display "Nao ha email cadastrado para o modulo BDBSR086 "
        end if
     end if

     #--
 else
    ## Relatorio por prestador
    #let comando = "uuencode ",p_bdbsr086_mail.arquivo clipped, " ",
    #                        "Pst_GPS.xls | remsh U07 ",
    #              "mailx -r 'danubio_ct24h/spaulo_info_sistemas@u55'",
    #              " -s 'Relatorio_de_acomp_performance_do_prestador_",
    #              p_bdbsr086_mail.prestador using "&&&&&&" ,"_GPS' ",
    #              "ramos_soraya/spaulo_psocorro_qualidade@u23 ",
    #              "oliveira_milton/spaulo_psocorro_controles@u23 ",
    #              "oriente_eduardo/spaulo_psocorro_controles@u23'"
 end if
 #run comando

end function  ### bdbsr086_mail
