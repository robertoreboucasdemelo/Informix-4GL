#############################################################################
# Nome do Modulo: bdbsa077                                         Marcelo  #
#                                                                  Gilberto #
# Realiza consistencias e gera alertas para operadores de radio    Dez/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/02/2000               Gilberto     Habilitada critica para verificar   #
#                                       se servidor esta' gerando movimento #
#                                       no banco Informix.                  #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 07/08/2000  PSI 111384   Marcus       Tratar QRU-REC, QRU-INI e QRU-FIM   #
#---------------------------------------------------------------------------#
# 30/08/2000  PSI 11459-6  Marcus       Conclusao de Servico pelo Atendente #
#---------------------------------------------------------------------------#
# 01/11/2002  PSI 16304-0  Raji         Critica de veiculo no mesmo status a#
#                                       + 3 horas p/ QRU,QRX,REC,INI e FIM  #
#---------------------------------------------------------------------------#
# 14/07/2005  PSI 193755   Cristiane Silva  Incluir funcao Abre_Banco       #
#                                           Otimizacao performance          #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# 26/02/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia    #
# 08/11/2007 Sergio Burini     DVP 25240  Monitor de Rotinas Criticas.      #
#---------------------------------------------------------------------------#
# 17/04/2009  Kevellin       PSI237337 Criação função bdbsa077_ctg_ctr      #
#---------------------------------------------------------------------------#

 database porto

 define m_tmpexp       datetime year to second

 main

   define l_data         date,
          l_hora         datetime hour to second,
          l_path         char(100),
          l_contingencia smallint,
          l_prcstt       like dpamcrtpcs.prcstt

  #PSI 193755 -  ABRE_BANCO
  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait 60
  set isolation to dirty read

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped,"/bdbsa077.log"

  call startlog(l_path)

  call bdbsa077_prepare()

  let l_data = today
  let l_hora = current

  display "BDBSA077 Carga:  ", l_data, " ", l_hora

  #DVP25240 - Monitoramento de Processos Ativos.
  let  m_tmpexp = current

  while true

     call ctx28g00("bdbsa077", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, l_prcstt

     if  l_prcstt = 'A' then

	     let l_data = today
	     let l_hora = current

	     display "BDBSA077 Inicio: ", l_data, " ", l_hora

	     call verifica_se_log_existe(l_path)

	     let l_contingencia = null
	     call cta00m08_ver_contingencia(4)
	          returning l_contingencia

	     if l_contingencia then
	        display "Contingencia Ativa/Carga ainda nao realizada."
	     else
	        if ctx34g00_ver_acionamentoWEB(2) then
            	   display "AcionamentoWeb Ativo."
                else
	           call bdbsa077()
	        end if
	     end if

	     #PSI 237337 - Contingência controladoras
         call bdbsa077_ctg_ctr()

	     let l_data = today
	     let l_hora = current

	     display "BDBSA077 Fim:    ", l_data, " ", l_hora

      end if

      sleep 120

  end while

 end main

#---------------------------------------------#
function verifica_se_log_existe(l_nome_arquivo)
#---------------------------------------------#

  # --FUNCAO PARA VERIFCAR SE O ARQUIVO DE LOG EXISTE
  # --SE O ARQUIVO DE LOG NAO EXISTIR, DERRUBA O PROCESSO ATIVO

  define l_comando      char(120),
         l_nome_arquivo char(100),
         l_erro         integer

  let  l_comando = null
  let  l_erro    = null

  let l_comando = "ls ", l_nome_arquivo clipped, " >/dev/null 2>/dev/null"

  run l_comando returning l_erro

  if l_erro <> 0 then
     display "Nao encontrou o arquivo de log !"
     exit program 1
  end if

end function

#==========================#
function bdbsa077_prepare()
#==========================#

  define l_sql char(900)

 #-------------------------------------------------------------------------
 # Prepara comandos SQL
 #-------------------------------------------------------------------------
 let l_sql = "insert into datmfrtale ( socvclaleseq, ",
                  "                         socvclcod, ",
                  "                         socvclalecod, ",
                  "                         socvclalesit, ",
                  "                         atldat, ",
                  "                         atlhor ) ",
                  "              values   ( '0', ?, ?, ?, today, current ) "
 prepare ins_datmfrtale  from  l_sql

 let l_sql = "select socvclaleseq ",
                  "  from datmfrtale ",
                  " where socvclalesit = ? ",
                  "   and socvclalecod = ? "
 prepare s_datmfrtale_1  from       l_sql
 declare c_datmfrtale_1  cursor for s_datmfrtale_1

 let l_sql = "select socvclaleseq ",
                  "  from datmfrtale ",
                  " where socvclalesit = ? ",
                  "   and socvclalecod = ? ",
                  "   and socvclcod    = ? "
 prepare s_datmfrtale_2  from       l_sql
 declare c_datmfrtale_2  cursor for s_datmfrtale_2

# let l_sql = "select socacsflg from datkveiculo ",
#                  " where socvclcod=? "
#
# prepare s_datkveiculo from l_sql
# declare c_datkveiculo cursor for s_datkveiculo

 #--------------------------------------------------------------------
 # Cursor para obter o ultimo movimento dos MDTs processado
 #--------------------------------------------------------------------
 let l_sql = "select caddat, ",
                  "       cadhor  ",
                  "  from datmmdtmvt ",
                  " where mdtmvtseq = (select min(mdtmvtseq) ",
                                      "  from datmmdtmvt ",
                                      " where mdtmvtstt = '1') "
 prepare s_datmmdtmvt_1  from       l_sql
 declare c_datmmdtmvt_1  cursor for s_datmmdtmvt_1

 #--------------------------------------------------------------------
 # Cursor para obter ultimo movimento dos MDTs gravado no banco
 #--------------------------------------------------------------------
 let l_sql = "select caddat, ",
                  "       cadhor  ",
                  "  from datmmdtmvt ",
                  " where mdtmvtseq = (select max(mdtmvtseq) ",
                                      "  from datmmdtmvt)"
 prepare s_datmmdtmvt_2  from       l_sql
 declare c_datmmdtmvt_2  cursor for s_datmmdtmvt_2

 #--------------------------------------------------------------------
 # Cursor para obter mensagens transmitidas com erro (MDTs)
 #--------------------------------------------------------------------
 let l_sql = "select datmmdtmsg.mdtmsgstt ",
                  "  from datmmdtmsg, datmmdtsrv ",
                  " where datmmdtmsg.mdtmsgstt = '3'",
                  "   and datmmdtsrv.mdtmsgnum = datmmdtmsg.mdtmsgnum"
 prepare sel_datmmdtmsg_1 from l_sql
 declare c_datmmdtmsg_1 cursor for sel_datmmdtmsg_1

 #--------------------------------------------------------------------
 # Cursor para obter mensagens sem QRU-RECEB pressionado (MDTs)
 #--------------------------------------------------------------------
 let l_sql = "select datmmdtmsg.mdtmsgstt ",
                  "  from datmmdtmsg, datmmdtsrv ",
                  " where datmmdtmsg.mdtmsgstt = '4'",
                  "   and datmmdtsrv.mdtmsgnum = datmmdtmsg.mdtmsgnum"
 prepare sel_datmmdtmsg_2 from l_sql
 declare c_datmmdtmsg_2 cursor for sel_datmmdtmsg_2

 #--------------------------------------------------------------------
 # Cursor para obter a situacao da transmissao (Fax)
 #--------------------------------------------------------------------
 let l_sql = "select faxenvsit, faxsubcod ",
                  "  from datmfax          ",
                  " where faxenvdat = ? ",
                  "   and faxenvsit in (1,3)"
 prepare sel_datmfax from l_sql
 declare c_datmfax cursor for sel_datmfax

 #--------------------------------------------------------------------
 # Cursor para verificar cancelamentos feitos pelos atendentes
 #--------------------------------------------------------------------
 let l_sql = "select datmsrvacp.atdetpcod                 ",
                  "  from datmligacao, datmservico, datmsrvacp ",
                  " where datmligacao.ligdat    >=  ?          ",
                  "   and datmligacao.c24astcod  =  'CAN'      ",
                  "   and datmservico.atdsrvnum  =  datmligacao.atdsrvnum ",
                  "   and datmservico.atdsrvano  =  datmligacao.atdsrvano ",
                  "   and datmservico.atdsrvorg in (4,6,1,5,7,9,13,2,3)",
                  "   and datmservico.atdfnlflg  =  'S' ",
                  "   and datmsrvacp.atdsrvnum   =  datmservico.atdsrvnum ",
                  "   and datmsrvacp.atdsrvano   =  datmservico.atdsrvano ",
                  "   and datmsrvacp.atdsrvseq   = ",
                                 " (select max(atdsrvseq) ",
                                   "  from datmsrvacp     ",
                                   " where atdsrvnum = datmservico.atdsrvnum ",
                                   "   and atdsrvano = datmservico.atdsrvano)"
 prepare sel_cancelado from l_sql
 declare c_cancelado cursor with hold for sel_cancelado

 #--------------------------------------------------------------------
 # Cursor para verificar retornos marcados para servicos de R.E.
 #--------------------------------------------------------------------
 let l_sql = "select datmsrvacp.atdetpcod",
                  "  from datmligacao, datmservico, datmsrvre, datmsrvacp",
                  " where datmligacao.ligdat    >= ?",
                  "   and datmligacao.c24astcod  = 'RET'",
                  "   and datmservico.atdsrvnum  = datmligacao.atdsrvnum  ",
                  "   and datmservico.atdsrvano  = datmligacao.atdsrvano  ",
                  "   and datmsrvre.atdsrvnum    = datmservico.atdsrvnum  ",
                  "   and datmsrvre.atdsrvano    = datmservico.atdsrvano  ",
                  "   and datmsrvre.atdsrvretflg = 'S'                    ",
                  "   and datmservico.atdfnlflg  = 'S'                    ",
                  "   and datmsrvacp.atdsrvnum   =  datmservico.atdsrvnum ",
                  "   and datmsrvacp.atdsrvano   =  datmservico.atdsrvano ",
                  "   and datmsrvacp.atdsrvseq   = ",
                                   "(select max(atdsrvseq) ",
                                    "  from datmsrvacp     ",
                                    " where atdsrvnum = datmservico.atdsrvnum ",
                                    "   and atdsrvano = datmservico.atdsrvano)"
 prepare sel_retorno from l_sql
 declare c_retorno cursor with hold for sel_retorno

 #--------------------------------------------------------------------
 # Cursor para verificar inconsistencias na posicao da frota
 #--------------------------------------------------------------------
 let l_sql = "select socvclcod, ",
                  "       c24atvcod, ",
                  "       srrcoddig, ",
                  "       cttdat, ",
                  "       ctthor  ",
                  "  from dattfrotalocal ",
                  " where vcldtbgrpcod not in (3,4,7,9,10) "
 prepare sel_dattfrotalocal from l_sql
 declare c_dattfrotalocal cursor with hold for sel_dattfrotalocal

 #--------------------------------------------------------------------
 let l_sql = "select atldat, ",
             "       atlhor, ",
             "       grlchv  ",
             "  from datkgeral ",
             " where grlchv like 'PSOCTGCTR%' ",
             "   and grlinf = 'S' "
 prepare pbdbsa077_ctg_ctr from l_sql
 declare cbdbsa077_ctg_ctr cursor with hold for pbdbsa077_ctg_ctr

end function

#----------------------------------------------------------------------
 function bdbsa077()
#----------------------------------------------------------------------

 define d_bdbsa077  record
    caddat          like datmmdtmvt.caddat,
    cadhor          like datmmdtmvt.cadhor,
    socvclalesit    like datmfrtale.socvclalesit,
    socvclcod       like datmfrtale.socvclcod,
    socvclalecod    like datmfrtale.socvclalecod,
    faxenvsit       like datmfax.faxenvsit,
    faxsubcod       like datmfax.faxsubcod,
    atdetpcod       like datmsrvacp.atdetpcod,
    cttdat          like dattfrotalocal.cttdat,
    ctthor          like dattfrotalocal.ctthor,
    c24atvcod       like dattfrotalocal.c24atvcod,
    srrcoddig       like dattfrotalocal.srrcoddig
 end record

 define ws          record
    dataatu         date,
    horaatu         datetime hour to second,
    minuto          datetime minute to minute,
    trxpsqtd        smallint,
    trxvdqtd        smallint,
    trxrsqtd        smallint,
    canpsqdat       date,
    comando         char (900),
    difer           interval hour(06) to second,
    socacsflg       like datkveiculo.socacsflg
 end record

 define def record
   tmpprcmvt        interval hour(06) to second,   # processando o movimento
   tmpgrvprc        interval hour(06) to second,   # gravando movimento no banco
   tmpqraesg        interval hour(06) to second,   # apos QRA socorrista
   tmpaciesg        interval hour(06) to second,   # viatura acionada
   tmpsitesg        interval hour(06) to second    # situacao atual esgotada
 end record

 define l_hoje date,
        l_contingencia     smallint

 initialize ws.*          to null
 initialize d_bdbsa077.*  to null

 let l_hoje        = null
 let def.tmpprcmvt = "00:06:00"
 let def.tmpgrvprc = "00:05:00"
 let def.tmpqraesg = "00:15:00"
 let def.tmpprcmvt = "00:05:00"
 let def.tmpsitesg = "03:00:00"

 select today, current, current
   into ws.dataatu, ws.horaatu, ws.minuto
   from dual                            # BUSCA DATA E HORA DO BANCO

 let d_bdbsa077.socvclalesit  =  1     #--> Situacao pendente

 #--------------------------------------------------------------------
 # Ate 01:00 da madrugada verifica cancelados do dia anterior
 #--------------------------------------------------------------------
 let ws.canpsqdat = today
 if ws.horaatu  <  "01:00:00"   then
    let ws.canpsqdat = today - 1
 end if

 #--------------------------------------------------------------------
 # Verifica se o programa batch esta processando o movimento
 #--------------------------------------------------------------------
 open  c_datmmdtmvt_1
 fetch c_datmmdtmvt_1  into  d_bdbsa077.caddat,
                             d_bdbsa077.cadhor
 close c_datmmdtmvt_1

 if d_bdbsa077.caddat  is not null   then
    call bdbsa077_espera(d_bdbsa077.caddat, d_bdbsa077.cadhor)
         returning ws.difer

    if ws.difer > def.tmpprcmvt   then
       initialize d_bdbsa077.socvclcod  to null
       let d_bdbsa077.socvclalecod      =  01
       call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                            d_bdbsa077.socvclcod,
                            d_bdbsa077.socvclalecod)
    end if
 end if

 #--------------------------------------------------------------------
 # Verifica se o servidor MDT esta gravando movimento no banco
 #--------------------------------------------------------------------
 initialize ws.difer           to null
 initialize d_bdbsa077.caddat  to null
 initialize d_bdbsa077.cadhor  to null

 open  c_datmmdtmvt_2
 fetch c_datmmdtmvt_2  into  d_bdbsa077.caddat,
                             d_bdbsa077.cadhor
 close c_datmmdtmvt_2

 if d_bdbsa077.caddat  is not null   then
    call bdbsa077_espera(d_bdbsa077.caddat, d_bdbsa077.cadhor)
         returning ws.difer

    if ws.difer > def.tmpgrvprc   then
       initialize d_bdbsa077.socvclcod  to null
       let d_bdbsa077.socvclalecod      =  02
       call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                            d_bdbsa077.socvclcod,
                            d_bdbsa077.socvclalecod)
    end if
 end if

 #----------------------------------------------------------------------
 # Verifica mensagens transmitidas com erro (MDTs)
 #----------------------------------------------------------------------
 open  c_datmmdtmsg_1
 fetch c_datmmdtmsg_1
 if sqlca.sqlcode  =  0   then
    initialize d_bdbsa077.socvclcod  to null
    let d_bdbsa077.socvclalecod      =  03
    call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                         d_bdbsa077.socvclcod,
                         d_bdbsa077.socvclalecod)
 end if
 close c_datmmdtmsg_1

 #----------------------------------------------------------------------
 # Verifica mensagens com QRU-RECEB nao pressionado (MDTs)
 #----------------------------------------------------------------------
 open  c_datmmdtmsg_2
 fetch c_datmmdtmsg_2
 if sqlca.sqlcode  =  0   then
    initialize d_bdbsa077.socvclcod  to null
    let d_bdbsa077.socvclalecod      =  11
    call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                         d_bdbsa077.socvclcod,
                         d_bdbsa077.socvclalecod)
 end if
 close c_datmmdtmsg_2

 #----------------------------------------------------------------------
 # Verifica situacao das transmissoes (Fax)
 #----------------------------------------------------------------------
 let ws.trxpsqtd = 0
 let ws.trxvdqtd = 0
 let ws.trxrsqtd = 0

 select today into l_hoje from dual

 open    c_datmfax using l_hoje
 foreach c_datmfax into d_bdbsa077.faxenvsit,
                        d_bdbsa077.faxsubcod

    let l_contingencia = null
    call cta00m08_ver_contingencia(4)
         returning l_contingencia

    if l_contingencia then
       display "Contingencia Ativa/Carga ainda nao realizada.."
       exit foreach
    end if

    if ctx34g00_ver_acionamentoWEB(2) then
       display "AcionamentoWeb Ativo."
       exit foreach
    end if

    if d_bdbsa077.faxenvsit  =  1   then          # Aguardando transmissao
       continue foreach
    end if

    if d_bdbsa077.faxenvsit  =  3   then          # Erro no envio
       if d_bdbsa077.faxsubcod  =  "PS"   then
          let ws.trxpsqtd = ws.trxpsqtd + 1       # Qtde erros PS
       else
          if d_bdbsa077.faxsubcod  =  "RS" then
             let ws.trxrsqtd = ws.trxrsqtd + 1       # Qtde erros RS
          else
             let ws.trxvdqtd = ws.trxvdqtd + 1       # Qtde erros VD
          end if
       end if
    end if

 end foreach
 close c_datmfax

 if ws.trxpsqtd  <>  0   then
    initialize d_bdbsa077.socvclcod  to null
    let d_bdbsa077.socvclalecod      =  04
    call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                         d_bdbsa077.socvclcod,
                         d_bdbsa077.socvclalecod)
 end if

 if ws.trxvdqtd  <>  0   then
    initialize d_bdbsa077.socvclcod  to null
    let d_bdbsa077.socvclalecod      =  05
    call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                         d_bdbsa077.socvclcod,
                         d_bdbsa077.socvclalecod)
 end if

 if ws.trxrsqtd  <>  0   then
    initialize d_bdbsa077.socvclcod  to null
    let d_bdbsa077.socvclalecod      =  12
    call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                         d_bdbsa077.socvclcod,
                         d_bdbsa077.socvclalecod)
 end if

 #----------------------------------------------------------------------
 # Verifica servicos cancelados pelos atendentes
 #----------------------------------------------------------------------
 open    c_cancelado  using  ws.canpsqdat
 foreach c_cancelado  into   d_bdbsa077.atdetpcod

    let l_contingencia = null
    call cta00m08_ver_contingencia(4)
         returning l_contingencia

    if l_contingencia then
       display "Contingencia Ativa/Carga ainda nao realizada..."
       exit foreach
    end if

    if ctx34g00_ver_acionamentoWEB(2) then
       display "AcionamentoWeb Ativo."
       exit foreach
    end if

    if d_bdbsa077.atdetpcod  =  3   or
       d_bdbsa077.atdetpcod  =  4   then
       initialize d_bdbsa077.socvclcod  to null
       let d_bdbsa077.socvclalecod      =  06
       call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                            d_bdbsa077.socvclcod,
                            d_bdbsa077.socvclalecod)
       exit foreach
    end if

 end foreach
 close c_cancelado

 #----------------------------------------------------------------------
 # Verifica retornos marcados para servicos de R.E.
 #----------------------------------------------------------------------
 open    c_retorno  using  ws.canpsqdat
 foreach c_retorno  into   d_bdbsa077.atdetpcod

    let l_contingencia = null
    call cta00m08_ver_contingencia(4)
         returning l_contingencia

    if l_contingencia then
       display "Contingencia Ativa/Carga ainda nao realizada...."
       exit foreach
    end if

    if ctx34g00_ver_acionamentoWEB(2) then
       display "AcionamentoWeb Ativo."
       exit foreach
    end if

    if d_bdbsa077.atdetpcod =  3   or
       d_bdbsa077.atdetpcod =  4   or
      (d_bdbsa077.atdetpcod >= 8   and
       d_bdbsa077.atdetpcod <= 12) then
       initialize d_bdbsa077.socvclcod  to null
       let d_bdbsa077.socvclalecod      =  07
       call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                            d_bdbsa077.socvclcod,
                            d_bdbsa077.socvclalecod)
       exit foreach
    end if

 end foreach
 close c_retorno

 #----------------------------------------------------------------------
 # Verifica inconsistencias na posicao da frota
 #----------------------------------------------------------------------
 open    c_dattfrotalocal
 foreach c_dattfrotalocal  into  d_bdbsa077.socvclcod,
                                 d_bdbsa077.c24atvcod,
                                 d_bdbsa077.srrcoddig,
                                 d_bdbsa077.cttdat,
                                 d_bdbsa077.ctthor
    let l_contingencia = null
    call cta00m08_ver_contingencia(4)
         returning l_contingencia

    if l_contingencia then
       display "Contingencia Ativa/Carga ainda nao realizada....."
       exit foreach
    end if

    if ctx34g00_ver_acionamentoWEB(2) then
       display "AcionamentoWeb Ativo."
       exit foreach
    end if

    #-------------------------------------------------------------------
    # Verifica se apos QRA socorrista acionou outra tecla
    #-------------------------------------------------------------------
    if d_bdbsa077.c24atvcod  =  "QRA"   then
       call bdbsa077_espera(d_bdbsa077.cttdat, d_bdbsa077.ctthor)
            returning ws.difer

       if ws.difer > def.tmpqraesg   then
          let d_bdbsa077.socvclalecod      =  08
          call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                               d_bdbsa077.socvclcod,
                               d_bdbsa077.socvclalecod)
       end if
    end if

    #-------------------------------------------------------------------
    # Verifica situacao atual dos veiculos 1 vez por hora
    #-------------------------------------------------------------------
    if d_bdbsa077.c24atvcod  =  "QRU"   or
       d_bdbsa077.c24atvcod  =  "QRX"   or
       d_bdbsa077.c24atvcod  =  "REC"   or
       d_bdbsa077.c24atvcod  =  "INI"   or
       d_bdbsa077.c24atvcod  =  "FIM"   then

       if ws.minuto  =  14   or
          ws.minuto  =  15   or
          ws.minuto  =  16   then

          if d_bdbsa077.srrcoddig  is not null   then
             call bdbsa077_espera(d_bdbsa077.cttdat, d_bdbsa077.ctthor)
                  returning ws.difer

             if ws.difer  > def.tmpsitesg  then
                case d_bdbsa077.c24atvcod
                   when "QRU"
                      let d_bdbsa077.socvclalecod      =  13
                   when "QRX"
                      let d_bdbsa077.socvclalecod      =  14
                   when "REC"
                      let d_bdbsa077.socvclalecod      =  15
                   when "INI"
                      let d_bdbsa077.socvclalecod      =  16
                   when "FIM"
                      let d_bdbsa077.socvclalecod      =  17
                end case
                call bdbsa077_alerta(d_bdbsa077.socvclalesit,
                                     d_bdbsa077.socvclcod,
                                     d_bdbsa077.socvclalecod)
             end if
          end if
       end if
    end if

 end foreach
 close c_dattfrotalocal

 end function  ###  bdbsa077

#--------------------------------------------------------------------------
 function bdbsa077_espera(param)
#--------------------------------------------------------------------------
  define param        record
     dataini          date,
     horaini          datetime hour to second
  end record

  define ws           record
    datafim          date,
    horafim          datetime hour to second,
    resdat           integer,
    reshor           interval hour(06) to second,
    chrhor           char (10)
  end record

  select today, current
    into ws.datafim, ws.horafim
    from dual                            # BUSCA DATA E HORA DO BANCO

 let ws.resdat = (ws.datafim - param.dataini) * 24
 let ws.reshor = (ws.horafim  - param.horaini)

 let ws.chrhor = ws.resdat using "###&" , ":00:00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

 end function   ###--- bdbsa077_espera


#--------------------------------------------------------------------------
 function bdbsa077_alerta(param)
#--------------------------------------------------------------------------

 define param       record
    socvclalesit    like datmfrtale.socvclalesit,
    socvclcod       like datmfrtale.socvclcod,
    socvclalecod    like datmfrtale.socvclalecod
 end record


 #--------------------------------------------------------------------
 # Verifica se o alerta ja' esta gravado e nao foi verificado
 #--------------------------------------------------------------------
 if param.socvclcod  is null   then
    open  c_datmfrtale_1  using  param.socvclalesit,
                                 param.socvclalecod
    fetch c_datmfrtale_1
    if sqlca.sqlcode  =  0   then
       close c_datmfrtale_1
       return
    end if
    close c_datmfrtale_1
 else
    open  c_datmfrtale_2  using  param.socvclalesit,
                                 param.socvclalecod,
                                 param.socvclcod
    fetch c_datmfrtale_2
    if sqlca.sqlcode  =  0   then
       close c_datmfrtale_2
       return
    end if
    close c_datmfrtale_2
 end if

 #--------------------------------------------------------------------
 # Grava alerta para operador de radio
 #--------------------------------------------------------------------
 whenever error continue
 begin work

 execute ins_datmfrtale  using  param.socvclcod,
                                param.socvclalecod,
                                param.socvclalesit

 if sqlca.sqlcode  <>  0   then
    display " ===> Alerta ",
            param.socvclalecod using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na inclusao tabela datmfrtale"
    rollback work
    exit program (1)
 end if

 commit work
 whenever error stop

 end function   ###--- bdbsa077_alerta

 #---------------------------------------------------------------------
 #FUNÇÃO RESPONSÁVEL POR DESATIVAR A CONTINGÊNCIA DA CONTROLADORA
 #QUANDO ACIONADA E NÃO DESATIVADA DENTRO DE UMA HORA
 function bdbsa077_ctg_ctr()
 #---------------------------------------------------------------------

    define l_data_atl_ctg like datkgeral.atldat,
           l_data date,
           l_hora datetime hour to second,
           l_hora_atl_ctg datetime hour to second,
           l_grlchv like datkgeral.grlchv,
           l_res interval hour to second

    let l_data = today
    let l_hora = current

    #display "data atual ", l_data, " hora atual " ,l_hora

    #VERIFICA SE EXISTE ALGUMA CONTROLADORA EM CONTINGÊNCIA POR MAIS DE UMA HORA
    open  cbdbsa077_ctg_ctr
    foreach cbdbsa077_ctg_ctr into l_data_atl_ctg, l_hora_atl_ctg, l_grlchv

        #display "data ctg ", l_data_atl_ctg, " hora ctg ", l_hora_atl_ctg, " ctg ", l_grlchv

        if l_data = l_data_atl_ctg then

            if l_hora > l_hora_atl_ctg then

                update datkgeral set grlinf = 'N'
                 where grlchv = l_grlchv

            end if

        end if

    end foreach
    close cbdbsa077_ctg_ctr

 end function


 