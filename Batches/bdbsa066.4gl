################################################################################
# Nome do Modulo: bdbsa066                                          Marcelo    #
#                                                                  Gilberto    #
# Atualiza mensagens enviadas pelos MDTs e GPS                     Ago/1999    #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 29/06/2000  PSI 110264   Marcus       Incluir Tratamento para Botao F1.      #
#                                                                              #
# 31/06/2000  PSI 111384   Marcus       Tratar QRU-REC, QRU-INI e QRU-FIM      #
#                                                                              #
# 03/01/2003  PSI 163775   Raji         Associar REC, INI e FIM ao servico     #
############################################################################   #
#                                                                              #
#                          * * * Alteracoes * * *                              #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch     #
#                              OSF036870  do Porto Socorro.                    #
# ---------- ----------------- ---------- -------------------------------------#
# 17/12/2004 Bruno Gama, Meta  PSI189715  Incluir condicao c24atvcod <> QTP    #
#                                                                              #
# 11/04/2005 Ronaldo,    Meta  PSI189790  Inlcuir Obter servico, replicar o    #
#                                         retorno para os multiplos, Obtem o   #
#                                         servico multiplos, envia mensagem    #
#                                         POLL para MDT,  incluir  mensagem    #
#                                         para  servico  multiplo e  incluir   #
#                                         movimento para servico multiplo.     #
# 12/07/2005 Cristiane Silva   PSI193755  Incluir funcao abre_banco            #
#                                         Remocao de displays.                 #
#                                                                              #
# 30/12/2005 Lucas Scheid      PSI197092  Controle de Tempo e Distancia dos    #
#                                         Socorristas apos QRU-REC.            #
#                                                                              #
# 23/02/2007 Ligia Mattge                 Chamar cta00m08_ver_contingencia     #
#                                                                              #
# 08/06/2007 Eduardo Vieira    PSI208671  Msg para após serv azul trocarem     #
#                                         carro para Porto Seguro              #
#                                                                              #
# 08/11/2007 Sergio Burini     DVP 25240  Monitor de Rotinas Criticas.         #
# 21/11/2007 Ligia Mattge      PSI 214566                                      #
# 04/12/2007 Sergio Burini     PSI214868  Envio de SMS ao segurado.            #
# 29/10/2008 Fabio Costa       PSI 214566 Gravar intervalos entre QRU-INI,     #
#                                         REC e FIM (gestao de frota)          #
# 23/12/2008 Fabio Costa       PSI 214566 Gravar desocupacao FIM-QRV           #
# 13/08/2009 Sergio Burini     PSI 244236 Inclusão do Sub-Dairro               #
# 04/08/2010 Sergio Burini     PSI256323  Processamento Ligue-me               #
# 30/08/2010 Robert Lima       PGP 6505   Foi tratado o campo mdtmvtdigcnt     #
#                                         conversao caracter para decimal      #
# 16/12/2010 Robert Lima       PSI 01689  Inclusão do envio da tag @QRV2 e     #
#                                         tratamento do botão 28.              #
#..............................................................................#
# 01/05/2012 Fornax  PSI03021PR PSI-2012-03021-PR - Resolucao 553 Anatel       #
#------------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define m_path       char(100)

 define am_retorno   array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

 define m_espera        interval hour(06) to second,
        m_tempo_limite  interval hour(06) to second,
        m_dist_minima   decimal(8,4),
        m_tmpexp        datetime year to second,
        m_prcstt        like dpamcrtpcs.prcstt,
        m_data_atual    date,
        m_hora_atual    datetime hour to second,
        m_msg_proc      char(80),
        m_tmpmvt        datetime year to second,
        m_tmptxt        char(20)

 define mr_retcontroladoras record
        erro           smallint ,
        mensagem       char(100)
 end record

 define mr_fones record
     celdddcodvcl like datkveiculo.celdddcod,
     celtelnumvcl like datkveiculo.celtelnum
 end record

 define m_qra    like datmmdtmvt.mdtmvtdigcnt,
        m_mdtcod like datmmdtmvt.mdtcod

 main

  define l_contingencia smallint,
         l_count integer,
         l_datmax date,
         l_hormax datetime hour to second

  call fun_dba_abre_banco("GUINCHOGPS")

  # Seta paramentros de banco depois da abertura
  set lock mode to wait 30
  set isolation to dirty read

  #----------------------#
  select sitename
  into g_hostname
  from dual
  #----------------------#

  let m_path = f_path("DBS","LOG")
  if m_path is null then
     let m_path = "."
  end if
  let m_path = m_path clipped,"/bdbsa066.log"

  call startlog(m_path)

  call bdbsa066_prepare()

  # --> CONSTANTES
  let m_tempo_limite  = "00:05:00"  # --> TEMPO LIMITE PARA VERIFICACAO DE MOVIMNTO APOS QRU-REC
  let m_dist_minima   = 0.300       # --> DISTANCIA MINIMA DE DESLOCAMENTO APOS TEMPO LIMITE
  let m_espera        = null

  # BUSCAR A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

  display "BDBSA066 Carga:  ", m_data_atual, " ", m_hora_atual

  # DVP 25240
  let  m_tmpexp = current

  while true

     # --VERIFICA SE O ARQUIVO DE LOG EXISTE, SE NAO EXISTIR, ENCERRA O PROGRAMA
     if not cts40g03_verifi_log_existe(m_path) then
        display "Nao encontrou o arquivo de log: ", m_path clipped
        exit program(1)
     end if

     call ctx28g00("bdbsa066", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, m_prcstt

     let l_contingencia = null
     call cta00m08_ver_contingencia(4)
          returning l_contingencia

     if l_contingencia then
        display "Contingencia ativa ou carga ainda nao realizada."
        sleep 10
     else
        # Se for o processo ativo
        if  m_prcstt = 'A' then

          if ctx34g00_ver_acionamentoWEB(2) then
            	display "AcionamentoWeb Ativo."
                sleep 10
          else
             # BUSCAR A DATA E HORA DO BANCO
             call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

             display "BDBSA066 ativo inicio: ", m_data_atual, " ", m_hora_atual
             let m_msg_proc = ""
             call bdbsa066()

             # BUSCAR A DATA E HORA DO BANCO
             call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

             display "BDBSA066 ativo fim:    ", m_data_atual, " ", m_hora_atual, m_msg_proc clipped

             # Quando processo ativo: Aguarda 5 segundos para proxima execucao
             sleep 5
          end if
        else

             # BUSCAR A DATA E HORA DO BANCO
             call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

             display "BDBSA066 standBy inicio: ", m_data_atual, " ", m_hora_atual

             let m_msg_proc = ""

             # Forca atualização de sinais e botoes F1 com atraso de processamento (2 minutos)
             let m_tmptxt = m_data_atual using "yyyy-mm-dd", " ", m_hora_atual
             let m_tmpmvt = m_tmptxt
             let m_tmpmvt = m_tmpmvt - 1 units minute
             let m_tmptxt = m_tmpmvt
             let l_hormax = m_tmptxt[12,20]
             let m_tmptxt = m_tmptxt[9,10], "/", m_tmptxt[6,7], "/", m_tmptxt[1,4]
             let l_datmax = m_tmptxt

             update datmmdtmvt set mdtmvtstt = 2
              where mdtmvtstt = 1
                and (mdtmvttipcod = 1 or
                     (mdtmvttipcod = 2 and mdtbotprgseq =4))
                and (caddat  < l_datmax or
                     (caddat = l_datmax and cadhor < l_hormax))

             if sqlca.sqlcode = 0 then
                let l_count = sqlca.sqlerrd[3]
                if l_count > 0 then
                   display "     Atualizacao forcada de ", l_count using "<<<<<<&", " sinais e F1"
                end if
             end if

             # BUSCAR A DATA E HORA DO BANCO
             call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

             display "BDBSA066 standBy fim:    ", m_data_atual, " ", m_hora_atual, m_msg_proc clipped

             # Quando processo inativo: Aguarda 30 segundos para proxima execucao
             sleep 30

        end if
     end if

  end while

 end main

#-------------------------#
function bdbsa066_prepare()
#-------------------------#

  define l_sql char(900)

  let l_sql = ' insert into datmmdtmvt '
                        ,' (mdtmvtseq '
                        ,' ,caddat '
                        ,' ,cadhor '
                        ,' ,mdtcod '
                        ,' ,mdtmvttipcod '
                        ,' ,mdtbotprgseq '
                        ,' ,mdtmvtdigcnt '
                        ,' ,ufdcod '
                        ,' ,cidnom '
                        ,' ,brrnom '
                        ,' ,lclltt '
                        ,' ,lcllgt '
                        ,' ,mdtmvtdircod '
                        ,' ,mdtmvtvlc '
                        ,' ,mdtmvtstt '
                        ,' ,endzon '
                        ,' ,mdtmvtsnlflg '
                        ,' ,mdttrxnum '
                        ,' ,atdsrvnum '
                        ,' ,atdsrvano '
                        ,' ,snsetritv ) '
                        ,' values (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? '
                        ,'        ,?, ?, ?, ?, ?, ?, ? ) '
 prepare pbdbsa066001 from l_sql


 let l_sql = ' select mdtmsgorgcod '
                  ,' ,mdtcod '
                  ,' ,mdtmsgavstip '
                  ,' from datmmdtmsg '
                  ,' where mdtmsgnum = ? '
 prepare pbdbsa066003 from l_sql
 declare cbdbsa066003 cursor for pbdbsa066003


 let l_sql = ' insert into datmmdtmsg '
                       ,' (mdtmsgnum '
                       ,' ,mdtmsgorgcod '
                       ,' ,mdtcod '
                       ,' ,mdtmsgstt '
                       ,' ,mdtmsgavstip) '
                ,' values (0, ?, ?, ?, ?) '
 prepare pbdbsa066004 from l_sql


 let l_sql = ' insert into datmmdtsrv '
                       ,' (mdtmsgnum '
                       ,' ,atdsrvnum '
                       ,' ,atdsrvano) '
                ,' values (?, ?, ?) '
 prepare pbdbsa066005 from l_sql


 let l_sql = ' select mdtmsgtxtseq '
                  ,' ,mdtmsgtxt '
                  ,' from datmmdtmsgtxt '
                  ,' where mdtmsgnum = ? '
 prepare pbdbsa066006 from l_sql
 declare cbdbsa066006 cursor for pbdbsa066006


 let l_sql = ' insert into datmmdtlog '
                       ,' (mdtmsgnum '
                       ,' ,mdtlogseq '
                       ,' ,mdtmsgstt '
                       ,' ,atldat '
                       ,' ,atlhor) '
                ,' values (?, 1, ?, ?, ?) '
 prepare pbdbsa066007 from l_sql


 let l_sql = ' insert into datmmdtmsgtxt '
                       ,' (mdtmsgnum '
                       ,' ,mdtmsgtxtseq '
                       ,' ,mdtmsgtxt) '
                       ,' values (?, ?, ?) '
 prepare pbdbsa066010 from l_sql


 let l_sql = "select max(mdtlogseq) ",
                  "  from datmmdtlog ",
                  " where mdtmsgnum = ? "
 prepare sel_datmmdtlog from       l_sql
 declare c_datmmdtlog   cursor for sel_datmmdtlog


 let l_sql = "select socvclcod,",
             "       socoprsitcod, ",
             "       pstcoddig, ",
             "       atdvclsgl, ",
             "       celdddcod, ",
             "       celtelnum ",
             "  from datkveiculo ",
             " where mdtcod = ? "
 prepare sel_datkveiculo from       l_sql
 declare c_datkveiculo   cursor for sel_datkveiculo


 let l_sql = "select srrstt, ",
                  "  srrnom, ",
                  "  srrabvnom, ",
                  "  celdddcod, ",
                  "  celtelnum ",
              " from datksrr ",
             " where srrcoddig = ? "
 prepare sel_datksrr from       l_sql
 declare c_datksrr   cursor for sel_datksrr


 let l_sql = "select nomgrr ",
             "  from dpaksocor ",
             " where pstcoddig = ? "
 prepare sel_dpaksocor from       l_sql
 declare c_dpaksocor   cursor for sel_dpaksocor


 let l_sql = "select pstcoddig ",
             "  from datrsrrpst ",
             " where srrcoddig = ? "

 prepare sel_datrsrrpst from       l_sql
 declare c_datrsrrpst   cursor for sel_datrsrrpst

 let l_sql = "select pstcoddig ",
             "  from datrsrrpst ",
             " where srrcoddig = ? ",
               " and today between viginc and vigfnl"

 prepare sel_datrsrrpstvig from       l_sql
 declare c_datrsrrpstvig   cursor for sel_datrsrrpstvig

 # BURINI DISCADORA
 let l_sql = "select pstcoddig ",
             "  from datrsrrpst ",
             " where srrcoddig = ? ",
               " and today between viginc and vigfnl",
               " and not exists (select 1 ",
                                 " from iddkdominio dmn ",
                                " where cponom = 'VNCNAOLGN' ", # Deve ter o tipo do veiculo
                                  " and cpocod  = pstvintip)"   # cadastrado no parametro.


 prepare sel_datrsrrpstvnc from       l_sql
 declare c_datrsrrpstvnc   cursor for sel_datrsrrpstvnc

 let l_sql = "select mdtbotprgsisflg,",
                  "       mdtbotprgdigflg",
                  "  from datkmdt, datrmdtbotprg",
                  " where datkmdt.mdtcod = ?",
                  "   and datrmdtbotprg.mdtprgcod    =  datkmdt.mdtprgcod",
                  "   and datrmdtbotprg.mdtbotprgseq = ?"
 prepare sel_datrmdtbotprg from       l_sql
 declare c_datrmdtbotprg   cursor for sel_datrmdtbotprg


 let l_sql = "select datmmdtmsg.mdtmsgnum ",
                  "  from datmmdtsrv, datmmdtmsg ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? ",
                  "   and datmmdtmsg.mdtmsgnum = datmmdtsrv.mdtmsgnum ",
                  "   and datmmdtmsg.mdtmsgstt = '0' "
 prepare sel_datmmdtsrv from       l_sql
 declare c_datmmdtsrv   cursor with hold for sel_datmmdtsrv


 let l_sql = "select cttdat,",
                  "       ctthor,",
                  "       c24atvcod,",
                  "       atdsrvnum,",
                  "       atdsrvano,",
                  "       srrcoddig,",
                  "       atlemp,",
                  "       atlmat ",
                  "  from dattfrotalocal",
                  " where dattfrotalocal.socvclcod = ?"
 prepare sel_dattfrotalocal_1 from       l_sql
 declare c_dattfrotalocal_1  cursor for sel_dattfrotalocal_1


 let l_sql = "select socvclcod",
                  "  from dattfrotalocal",
                  " where dattfrotalocal.srrcoddig = ?",
                  "   and dattfrotalocal.c24atvcod not in ('QTP','NIL') "
 prepare sel_dattfrotalocal_2 from       l_sql
 declare c_dattfrotalocal_2  cursor for sel_dattfrotalocal_2


 let l_sql = "select srrcoddig, atdsrvnum, atdsrvano",
                  "  from dattfrotalocal",
                  " where dattfrotalocal.socvclcod = ?",
                  "   and dattfrotalocal.c24atvcod not in ('QTP','NIL') "
 prepare sel_dattfrotalocal_3 from       l_sql
 declare c_dattfrotalocal_3  cursor for sel_dattfrotalocal_3


 let l_sql = "insert into datmmdtmsg  ",
                        "(mdtmsgnum, ",
                        " mdtmsgorgcod, ",
                        " mdtcod, ",
                        " mdtmsgavstip, ",
                        " mdtmsgstt) ",
                  "values ('0', '1', ?, ?, '1')"
 prepare ins_datmmdtmsg from  l_sql


 let l_sql = "insert into datmmdtlog ",
                        "(mdtmsgnum, ",
                        " mdtlogseq, ",
                        " mdtmsgstt, ",
                        " atldat, ",
                        " atlhor) ",
                  "values (?, ?, ?, ?, ?)"
 prepare ins_datmmdtlog from  l_sql


 let l_sql = "insert into datmmdtmsgtxt ",
                        "(mdtmsgnum, ",
                        " mdtmsgtxtseq, ",
                        " mdtmsgtxt) ",
                  "values (?, '1', ?) "
 prepare ins_datmmdtmsgtxt from  l_sql


 let l_sql = "insert into datmmdterr ",
                        "(mdtmvtseq, ",
                        " mdterrcod) ",
                  "values (?, ?)"
 prepare ins_datmmdterr from  l_sql


 let l_sql = "update datmmdtmsg set mdtmsgstt = ? ",
                  " where mdtmsgnum = ? "
 prepare upd_datmmdtmsg from  l_sql


 let l_sql = "update datmmdtmvt ",
               " set mdtmvtstt = ? ,",
                   " snsetritv = ? ,",
                   " atdsrvnum = ? ,",
                   " atdsrvano = ?  ",
                  " where mdtmvtseq = ? "
 prepare upd_datmmdtmvt from  l_sql


#### let l_sql = "update datmmdtmvt set mdtmvtstt = ? ",
####                  " where mdtmvtseq = ? "
#### prepare upd_datmmdtmvt from  l_sql
####
####
#### let l_sql = " update datmmdtmvt set snsetritv = ? ",
####             " where mdtmvtseq = ? "
#### prepare upd_datmmdtmvt_itv from l_sql
####
####
#### let l_sql = "update datmmdtmvt ",
####                    " set atdsrvnum    = ?,",
####                        " atdsrvano    = ? ",
####                  " where mdtmvtseq    = ? "
#### prepare upd_datmmdtmvt_srv from  l_sql


 let l_sql = "update dattfrotalocal set mdtmvtdircod = ?, mdtmvtvlc = ?",
                  " where socvclcod = ? "
 prepare upd_dattfrotalocal_1 from  l_sql


 let l_sql = "update dattfrotalocal set ",
                  "(cttdat, ctthor, c24atvcod, ",
                  " atdsrvnum, atdsrvano, srrcoddig, atlemp, atlmat) ",
                  " = (?, ?, ?, ?, ?, ?, ?, ?) ",
                  " where socvclcod = ? "
 prepare upd_dattfrotalocal_2 from  l_sql


 let l_sql = "update datmfrtpos set ",
                  "(ufdcod, cidnom, brrnom, endzon, lclltt,",
                  " lcllgt, atldat, atlhor)",
                  " = (?, ?, ?, ?, ?, ?, ?, ?)",
                  " where socvclcod    = ? ",
                  "   and socvcllcltip = ? "
 prepare upd_datmfrtpos_1 from  l_sql


 let l_sql =  "select datmmdtmsg.mdtmsgnum, ",
              "       datmmdtlog.atldat,    ",
              "       datmmdtlog.atlhor,    ",
              "       datmmdtsrv.atdsrvnum, ",
              "       datmmdtsrv.atdsrvano, ",
              "       datmmdtmsg.mdtcod     ",
              "  from datmmdtmsg, datmmdtlog, outer datmmdtsrv       ",
              " where datmmdtmsg.mdtmsgstt  =  0                     ",
              "   and datmmdtlog.mdtmsgnum  =  datmmdtmsg.mdtmsgnum  ",
              "   and datmmdtlog.mdtlogseq  =  1                     ",
              "   and datmmdtsrv.mdtmsgnum  =  datmmdtmsg.mdtmsgnum  ",
              "   and datmmdtmsg.mdtmsgnum  <= ? "
  prepare p_datmmdtmsg from l_sql
  declare c_datmmdtmsg cursor with hold for p_datmmdtmsg


 let l_sql =  "select max(mdtmsgnum) ",
              "  from datmmdtmsg     ",
              " where datmmdtmsg.mdtmsgstt  =  0 "
  prepare p_maxmdtmsg from l_sql
  declare c_maxmdtmsg cursor for p_maxmdtmsg


  let l_sql = " select mdtmvtseq,      ",
                     " caddat,         ",
                     " cadhor,         ",
                     " mdtcod,         ",
                     " mdtmvttipcod,   ",
                     " mdtbotprgseq,   ",
                     " mdtmvtdigcnt,   ",
                     " ufdcod,         ",
                     " cidnom,         ",
                     " brrnom,         ",
                     " endzon,         ",
                     " lclltt,         ",
                     " lcllgt,         ",
                     " mdtmvtdircod,   ",
                     " mdtmvtvlc,      ",
                     " mdtmvtsnlflg,   ",
                     " mdttrxnum       ",
                " from datmmdtmvt      ",
               " where mdtmvtstt  =  1 ",
                 " and mdtmvtseq  <= ? "
  prepare p_datmmdtmvt from l_sql
  declare c_datmmdtmvt cursor with hold for p_datmmdtmvt


  let l_sql = " select max(mdtmvtseq)  ",
                " from datmmdtmvt      ",
               " where mdtmvtstt  =  1 "
  prepare p_maxmdtmvt from l_sql
  declare c_maxmdtmvt cursor for p_maxmdtmvt

  let l_sql = " select mdtctrcod ",
                " from datkmdt ",
               " where mdtcod = ? "
  prepare p_bdbsa066008 from l_sql
  declare c_bdbsa066008 cursor for p_bdbsa066008


  let l_sql = " select segrpdatltmpqtd, ",
                     " fqctrclimvlcqtd, ",
                     " seglntatltmpqtd ",
                " from datkmdtctr ",
               " where mdtctrcod = ? "
  prepare p_bdbsa066009 from l_sql
  declare c_bdbsa066009 cursor for p_bdbsa066009


  let l_sql = " select caddat, ",
                     " cadhor ",
                " from datmmdtinc ",
               " where mdtcod = ? ",
                 " and mdtinctip = ? ",
               " order by caddat desc, ",
                        " cadhor desc "
 prepare p_bdbsa066010 from l_sql
 declare c_bdbsa066010 cursor for p_bdbsa066010


###PSI208671
 let l_sql = " select ciaempcod ",
              "from datmservico ",
              " where atdsrvnum = ? ",
              " and  atdsrvano = ? "
 prepare p_bdbsa066011 from l_sql
 declare c_bdbsa066011 cursor for p_bdbsa066011


 let l_sql = "select ufdcod,",
             " cidnom,",
             " brrnom,",
             " endzon,",
             " lclltt,",
             " lcllgt,",
             " mdtmvtdircod,",
             " mdtmvtvlc,",
             " mdtmvtsnlflg,",
             " caddat,",
             " cadhor",
        " from datmmdtmvt",
       " where mdtcod = ?",
         " and ((caddat = ? and cadhor >= ?)",
              " or caddat > ?)",
         " and mdtmvtsnlflg  =  'S'",
         " order by caddat desc, cadhor desc"
 prepare p_bdbsa066012 from l_sql
 declare c_bdbsa066012 cursor for p_bdbsa066012


 let l_sql = "select b.mdtctrcod, count(*) ",
             "  from datmmdtmvt a, datkmdt b ",
             " where a.mdtmvtstt = 1 ",
             "   and a.caddat = ? ",
             "   and a.mdtcod = b.mdtcod ",
             "   and a.cadhor <= ? ",
             " group by 1 ",
             " order by 1 "
 prepare p_bdbsa066013 from l_sql
 declare c_bdbsa066013 cursor for p_bdbsa066013


 # pegar ultimos tres sinais do mesmo botao
 let l_sql = " select first 3 caddat, cadhor ",
             " from datmmdtmvt " ,
             " where mdtmvttipcod = 2 " ,  # tipo movto botao acionado
             "   and mdtbotprgseq = ? " ,  # botao
             "   and mdtcod       = ? " ,  # MDT
             " order by caddat desc, cadhor desc "
 prepare p_datmmdtmvt_qru from l_sql
 declare c_datmmdtmvt_qru cursor with hold for p_datmmdtmvt_qru

 let l_sql = "select mdtbotprgseq ",
              " from datmmdtmvt ",
             " where mdtmvtseq = ? "
 prepare p_bdbsa066014 from l_sql
 declare c_bdbsa066014 cursor for p_bdbsa066014

 let l_sql = "select dtvdat, dtvfunmat",
             "  from dpmmqrvsgnprt    ",
             " where cidsedcod = ?      ",
             "   and cidsedqrvseq in(select max(cidsedqrvseq)",
             "                          from dpmmqrvsgnprt   ",
             "                         where cidsedcod = ?)    "
 prepare p_bdbsa066015 from l_sql
 declare c_bdbsa066015 cursor for p_bdbsa066015


 let l_sql = "select cidnom,ufdcod",
             "  from datmlcl      ",
             " where atdsrvnum = ?",
             "   and atdsrvano = ?"
 prepare p_bdbsa066016 from l_sql
 declare c_bdbsa066016 cursor for p_bdbsa066016

 let l_sql = "select cidsedcod                   ",
             "  from datrcidsed                  ",
             " where cidcod = (select cidcod     ",
             "                   from glakcid    ",
             "                  where cidnom = ? ",
             "                    and ufdcod = ?)"
 prepare p_bdbsa066017 from l_sql
 declare c_bdbsa066017 cursor for p_bdbsa066017

end function

#-----------------#
function bdbsa066()
#-----------------#

 define d_bdbsa066  record
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,
   atldat           like datmmdtlog.atldat,
   atlhor           like datmmdtlog.atlhor,
   mdtmvtseq        like datmmdtmvt.mdtmvtseq,
   caddat           like datmmdtmvt.caddat,
   cadhor           like datmmdtmvt.cadhor,
   mdtcod           like datmmdtmvt.mdtcod,
   mdtmvttipcod     like datmmdtmvt.mdtmvttipcod,
   mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
   mdtmvtdigcnt     like datmmdtmvt.mdtmvtdigcnt,
   ufdcod           like datmmdtmvt.ufdcod,
   cidnom           like datmmdtmvt.cidnom,
   brrnom           like datmmdtmvt.brrnom,
   endzon           like datmmdtmvt.endzon,
   lclltt           like datmmdtmvt.lclltt,
   lcllgt           like datmmdtmvt.lcllgt,
   mdtmvtdircod     like datmmdtmvt.mdtmvtdircod,
   mdtmvtvlc        like datmmdtmvt.mdtmvtvlc,
   socvclcod        like datkveiculo.socvclcod,
   atdvclsgl        like datkveiculo.atdvclsgl,
   mdtprgcod        like datkmdtprg.mdtprgcod,
   mdtbotprgdigflg  like datrmdtbotprg.mdtbotprgdigflg,
   atdsrvnum        like datmmdtsrv.atdsrvnum,
   atdsrvano        like datmmdtsrv.atdsrvano,
   mdttrxnum        like datmmdtmvt.mdttrxnum
 end record

 define ws          record
   mdtlogseq        like datmmdtlog.mdtlogseq,
   mdtmsgstt        like datmmdtmsg.mdtmsgstt,
   mdterrcod        like datmmdterr.mdterrcod,
   mdtstt           like datkmdt.mdtstt,
   pstcoddig        like datkveiculo.pstcoddig,
   socoprsitcod     like datkveiculo.socoprsitcod,
   mdtbotprgsisflg  like datrmdtbotprg.mdtbotprgsisflg,
   srrcoddig        like dattfrotalocal.srrcoddig,
   mdtmvtsnlflg     like datmmdtmvt.mdtmvtsnlflg,
   cponom           like iddkdominio.cponom,
   mdtmvtstt        like datmmdtmvt.mdtmvtstt,

   dataatu          date,
   horaatu          datetime hour to second,
   espera           interval hour(06) to second,

   erroflg          char (01),
   comando          char (700),
   mensagem         char (80),
   resultado        smallint,

   atdsrvnum        like datmservico.atdsrvnum,
   atdsrvano        like datmservico.atdsrvano,
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,

   maxmdtmsgnum     like datmmdtmsg.mdtmsgnum,
   maxmdtmvtseq     like datmmdtmvt.mdtmvtseq,
   qtdmsggps        integer,
   qtdmvtgps        integer,

   ustcod           like htlrust.ustcod,
   pgrnum           like datkveiculo.pgrnum,
   errcod           integer,
   sqlcode          integer,
   mstnum           integer,
   atlhor           like datmfrtpos.atlhor,
   atldat           like datmfrtpos.atldat,
   lclltt           like datmfrtpos.lclltt,
   lcllgt           like datmfrtpos.lcllgt,
   celdddcodsrr     like datksrr.celdddcod,
   celtelnumsrr     like datksrr.celtelnum
 end record

 define l_ind              smallint,
        l_cod_erro         smallint,
        l_c24atvcod        like dattfrotalocal.c24atvcod,
        l_lclltt           like datmmdtmvt.lclltt,
        l_lcllgt           like datmmdtmvt.lcllgt,
        l_caddat           like datmmdtmvt.caddat,
        l_cadhor           like datmmdtmvt.cadhor,
        l_distancia        decimal(8,4),
        l_segrpdatltmpqtd  like datkmdtctr.segrpdatltmpqtd,
        l_fqctrclimvlcqtd  like datkmdtctr.fqctrclimvlcqtd,
        l_seglntatltmpqtd  like datkmdtctr.seglntatltmpqtd,
        l_mdtctrcod        like datkmdt.mdtctrcod,
        l_mensagem         char(200),
        l_aux_rapida       interval minute to second,
        l_aux_lenta        interval minute to second,
        l_fnl_rapida       datetime minute to second,
        l_fnl_lenta        datetime minute to second,
        l_cad_dat          like datmmdtinc.caddat,
        l_cad_hor          like datmmdtinc.cadhor,
        l_atdlibhor        like datmservico.atdlibhor,
        l_atdhorprg        like datmservico.atdhorprg,
        l_atdprvdat        like datmservico.atdprvdat,
        l_hora_calc        interval hour(06) to second,
        l_hora_atu         datetime hour to second,     #interval hour(06) to second,
        l_hora_dif         interval hour(06) to second,

        l_txttransm        char(20),
        l_transm           datetime year to second,
        l_data_transm      date,
        l_hora_transm      datetime hour to second,
        l_mdtinctip        like datmmdtinc.mdtinctip,
        l_ciaempcod        like datmservico.ciaempcod,   #PSI208671
        l_atdsrvorg        like datmservico.atdsrvorg,
        l_resultado        smallint,
        l_intervalo        interval hour(3) to second ,  # recolocar apos REORG 23/11
        l_botao            smallint

 define def record
        tmpesg       interval hour(06) to second  # tempo maximo esgotado
 end record

 define lr_qti record
    lclidttxt       like datmlcl.lclidttxt,
    lgdtxt          char (65),
    brrnom          like datmlcl.brrnom,
    endzon          like datmlcl.endzon,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    lclrefptotxt    like datmlcl.lclrefptotxt,
    dddcod          like datmlcl.dddcod,
    lcltelnum       like datmlcl.lcltelnum,
    lclcttnom       like datmlcl.lclcttnom
 end record


 initialize d_bdbsa066, ws to null

 let l_ciaempcod       = null
 let l_mdtinctip       = null
 let l_c24atvcod       = null
 let l_cad_dat         = null
 let l_cad_hor         = null
 let l_cod_erro        = null
 let l_lclltt          = null
 let l_lcllgt          = null
 let l_fnl_rapida      = null
 let l_fnl_lenta       = null
 let l_caddat          = null
 let l_cadhor          = null
 let l_aux_rapida      = null
 let l_aux_lenta       = null
 let l_distancia       = null
 let l_segrpdatltmpqtd = null
 let l_fqctrclimvlcqtd = null
 let l_seglntatltmpqtd = null
 let l_mensagem        = null
 let l_mdtctrcod       = null
 let ws.dataatu        = today
 let ws.mdtmsgstt      = 4        #--> Tempo maximo esgotado
 let def.tmpesg        = "00:04:00"
 let l_atdhorprg       = null
 let l_atdlibhor       = null
 let l_atdprvdat       = null
 let l_hora_calc       = null
 let l_hora_atu        = null
 let l_hora_dif        = null

 # BUSCAR A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

 #-------------------------------------------------------------------------
 # Le movimento de mensagens para MDTs com situacao (transmitida OK)
 #-------------------------------------------------------------------------

 # BUSCA DATA E HORA DO BANCO
 select today, current into ws.dataatu, ws.horaatu from dual

 # Busca ultima mensagem nao processada
 open  c_maxmdtmsg
 fetch c_maxmdtmsg into ws.maxmdtmsgnum
 close c_maxmdtmsg

 # Busca mensagens nao processadas
 let ws.qtdmsggps = 0
 open c_datmmdtmsg using ws.maxmdtmsgnum
 foreach c_datmmdtmsg into  d_bdbsa066.mdtmsgnum,
                            d_bdbsa066.atldat,
                            d_bdbsa066.atlhor,
                            d_bdbsa066.atdsrvnum,
                            d_bdbsa066.atdsrvano,
                            d_bdbsa066.mdtcod

    let ws.qtdmsggps = ws.qtdmsggps + 1

    #----------------------------------------------------------------------
    # Atualiza situacao da mensagem para "tempo maximo esgotado"
    #----------------------------------------------------------------------
    call ctx01g07_espera(d_bdbsa066.atldat,
                         d_bdbsa066.atlhor)
         returning ws.espera

    if ws.espera > def.tmpesg  then
       let ws.mdtmsgstt = 4
    else
       let ws.mdtmsgstt = 6
    end if

       let ws.mdtlogseq = null

       open  c_datmmdtlog  using  d_bdbsa066.mdtmsgnum
       fetch c_datmmdtlog  into   ws.mdtlogseq
       close c_datmmdtlog

       if ws.mdtlogseq  is null   then
          display ws.dataatu," ",ws.horaatu," ===> Msg ",
                  d_bdbsa066.mdtmsgnum using "<<<<<<<<<&",
                  " : Erro nao possui registro de log"
          continue foreach
       end if

       let ws.mdtlogseq = ws.mdtlogseq + 1

       ##whenever error continue

          execute upd_datmmdtmsg  using  ws.mdtmsgstt,
                                         d_bdbsa066.mdtmsgnum

          if sqlca.sqlcode  <>  0   then
             display ws.dataatu," ",ws.horaatu," ===> Msg ",
                     d_bdbsa066.mdtmsgnum using "<<<<<<<<<&",
                     " : Erro (", sqlca.sqlcode using "<<<<<&",
                     ") na atualizacao tabela datmmdtmsg (1)"
             continue foreach
          end if

          execute ins_datmmdtlog  using  d_bdbsa066.mdtmsgnum,
                                         ws.mdtlogseq,
                                         ws.mdtmsgstt,
                                         ws.dataatu, ws.horaatu

          if sqlca.sqlcode  <>  0   then
             display ws.dataatu," ",ws.horaatu," ===> Msg ",
                     d_bdbsa066.mdtmsgnum using "<<<<<<<<<&",
                     " : Erro (", sqlca.sqlcode using "<<<<<&",
                     ") na inclusao tabela datmmdtlog"
             continue foreach
          end if

          call bdbsa066_replica_srv_multiplo(d_bdbsa066.atdsrvnum,
                                             d_bdbsa066.atdsrvano,
                                             d_bdbsa066.mdtmsgnum,
                                             ws.mdtmsgstt,
                                             ws.dataatu, ws.horaatu )
               returning ws.resultado,
                         ws.mensagem

          if ws.resultado <> 1 then
             display ws.mensagem
             continue foreach
          end if

 end foreach

 close c_datmmdtmsg
 let m_msg_proc = m_msg_proc clipped, " ", "Mensagens:", ws.qtdmsggps using "#####&"

 # BUSCAR A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

 #-------------------------------------------------------------------------
 # Le movimento de botoes pressionados e sinais de GPS
 #-------------------------------------------------------------------------

 # BUSCA DATA E HORA DO BANCO
 select today, current into ws.dataatu, ws.horaatu from dual

 # Busca ultimo movimento GPS nao processado
 open  c_maxmdtmvt
 fetch c_maxmdtmvt into ws.maxmdtmvtseq
 close c_maxmdtmvt
 # Busca movimentos GPS nao processados
 let ws.qtdmvtgps = 0
 open c_datmmdtmvt using ws.maxmdtmvtseq
 foreach c_datmmdtmvt into  d_bdbsa066.mdtmvtseq,
                            d_bdbsa066.caddat,
                            d_bdbsa066.cadhor,
                            d_bdbsa066.mdtcod,
                            d_bdbsa066.mdtmvttipcod,
                            d_bdbsa066.mdtbotprgseq,
                            d_bdbsa066.mdtmvtdigcnt,
                            d_bdbsa066.ufdcod,
                            d_bdbsa066.cidnom,
                            d_bdbsa066.brrnom,
                            d_bdbsa066.endzon,
                            d_bdbsa066.lclltt,
                            d_bdbsa066.lcllgt,
                            d_bdbsa066.mdtmvtdircod,
                            d_bdbsa066.mdtmvtvlc,
                            ws.mdtmvtsnlflg,
                            d_bdbsa066.mdttrxnum

    let ws.qtdmvtgps = ws.qtdmvtgps + 1
    let l_intervalo = null
    let l_botao     = null
    let m_mdtcod    = d_bdbsa066.mdtcod

    let d_bdbsa066.mdtmvtdigcnt = d_bdbsa066.mdtmvtdigcnt clipped # PGP 6505
    let d_bdbsa066.mdtmvtdigcnt = d_bdbsa066.mdtmvtdigcnt[1,8]    # PGP 6505 Limitar para 8 dig

    #############################################################
    # Caso o Sinal estiver invalido considerar a localizacao do
    # ultimo sinal valido com ate 1 hora
    #############################################################
    if ws.mdtmvtsnlflg   <> "S" or
       d_bdbsa066.lclltt =  0   or
       d_bdbsa066.lcllgt =  0 then

       let l_txttransm = year(d_bdbsa066.caddat)  using "&&&&"  , "-",
                         month(d_bdbsa066.caddat) using "&&"    , "-",
                         day(d_bdbsa066.caddat)   using "&&"    , " ",
                         d_bdbsa066.cadhor

       let l_transm = l_txttransm
       let l_transm = l_transm - 1 units hour

       let l_data_transm = l_transm
       let l_hora_transm = l_transm

       open c_bdbsa066012 using d_bdbsa066.mdtcod,
                                l_data_transm,
                                l_hora_transm,
                                l_data_transm

       fetch c_bdbsa066012 into d_bdbsa066.ufdcod,
                                d_bdbsa066.cidnom,
                                d_bdbsa066.brrnom,
                                d_bdbsa066.endzon,
                                d_bdbsa066.lclltt,
                                d_bdbsa066.lcllgt,
                                d_bdbsa066.mdtmvtdircod,
                                d_bdbsa066.mdtmvtvlc,
                                ws.mdtmvtsnlflg

    end if

    let g_documento.lclltt = d_bdbsa066.lclltt
    let g_documento.lcllgt = d_bdbsa066.lcllgt

    let ws.mdtmvtstt  =  2      #--> Processado OK

    #----------------------------------------------------------------------
    # Verifica MDT/Veiculo
    #----------------------------------------------------------------------
    let ws.pstcoddig         = null
    let ws.socoprsitcod      = null
    let d_bdbsa066.socvclcod = null
    let d_bdbsa066.atdvclsgl = null

    open  c_datkveiculo  using  d_bdbsa066.mdtcod
    fetch c_datkveiculo  into   d_bdbsa066.socvclcod,
                                ws.socoprsitcod,
                                ws.pstcoddig,
                                d_bdbsa066.atdvclsgl,
                                mr_fones.celdddcodvcl,
                                mr_fones.celtelnumvcl
    close c_datkveiculo

    if d_bdbsa066.socvclcod  is null   then

       let ws.mdterrcod  =  08
       call bdbsa066_erro_mvt (ws.dataatu,
                               ws.horaatu,
                               d_bdbsa066.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       continue foreach
    end if

    if ws.socoprsitcod  <>  1   then

       let ws.mdterrcod  =  11
       call bdbsa066_erro_mvt (ws.dataatu,
                               ws.horaatu,
                               d_bdbsa066.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       continue foreach
    end if

    #----------------------------------------------------------------------
    # Verifica se ja' foi realizado o logon
    #----------------------------------------------------------------------
    let ws.srrcoddig = null
    let ws.atdsrvnum = null
    let ws.atdsrvano = null

    open  c_dattfrotalocal_3  using  d_bdbsa066.socvclcod
    fetch c_dattfrotalocal_3  into   ws.srrcoddig,
                                     ws.atdsrvnum,
                                     ws.atdsrvano
    close c_dattfrotalocal_3

    if ws.srrcoddig  is null   then
       if d_bdbsa066.mdtmvttipcod  =  1   then  # Sinal GPS
          # Continua fluxo para gravar posigco da frota
          let ws.srrcoddig = 0
       else
          if d_bdbsa066.mdtbotprgseq  <>  8   then
             let ws.mdterrcod  =  23
             call bdbsa066_erro_mvt (ws.dataatu,
                                     ws.horaatu,
                                     d_bdbsa066.mdtmvtseq,
                                     ws.mdterrcod)
                  returning ws.erroflg
             continue foreach
          end if
       end if
    end if


    #----------------------------------------------------------------------
    # Trata movimento conforme o tipo (Fora de Ordem)
    #----------------------------------------------------------------------
    if d_bdbsa066.mdtmvttipcod  =  3   then
       let ws.mdtmvtstt  =  4      #--> Processado Fora de Ordem
    end if


    #---------------------------------------------------------------------
    # Trata movimento conforme o tipo (BOTAO)
    #---------------------------------------------------------------------
    if d_bdbsa066.mdtmvttipcod  =  2   then

       let d_bdbsa066.mdtbotprgdigflg = null
       let ws.mdtbotprgsisflg         = null

       if d_bdbsa066.mdtbotprgseq  is null   then
          let ws.mdterrcod  =  13
          call bdbsa066_erro_mvt (ws.dataatu,
                                  ws.horaatu,
                                  d_bdbsa066.mdtmvtseq,
                                  ws.mdterrcod)
            returning ws.erroflg
          continue foreach
       end if

       open   c_datrmdtbotprg  using  d_bdbsa066.mdtcod,
                                      d_bdbsa066.mdtbotprgseq
       fetch  c_datrmdtbotprg  into   ws.mdtbotprgsisflg,
                                      d_bdbsa066.mdtbotprgdigflg
       if sqlca.sqlcode  <>  0   then
          if sqlca.sqlcode  =  notfound   then
             let ws.mdterrcod  =  12
             call bdbsa066_erro_mvt (ws.dataatu,
                                     ws.horaatu,
                                     d_bdbsa066.mdtmvtseq,
                                     ws.mdterrcod)
                  returning ws.erroflg
             close  c_datrmdtbotprg
             continue foreach
          end if
       end if
       close  c_datrmdtbotprg

       if ws.mdtbotprgsisflg  =  "S"   then

          if d_bdbsa066.mdtbotprgdigflg  =  "S"    and
             d_bdbsa066.mdtmvtdigcnt     is null   then
             let ws.mdterrcod  =  14
             call bdbsa066_erro_mvt (ws.dataatu,
                                     ws.horaatu,
                                     d_bdbsa066.mdtmvtseq,
                                     ws.mdterrcod)
                  returning ws.erroflg
             continue foreach
          end if

          if d_bdbsa066.mdtbotprgseq  =  08   then      #--> QRA
             call bdbsa066_mdt_logon (ws.dataatu,
                                      ws.horaatu,
                                      d_bdbsa066.*,
                                      ws.pstcoddig)
                  returning ws.erroflg

             if ws.erroflg  =  "S"   then
                continue foreach
             end if

             # --> PESQUISAR O TEMPO DE ATUALIZACAO PADRAO DA CONTROLADORA
             # --> E CONFIGURAR O MDT

             # --> BUSCA CONTROLADORA DO MDT

             open c_bdbsa066008 using d_bdbsa066.mdtcod
             whenever error continue
             fetch c_bdbsa066008 into l_mdtctrcod
             whenever error stop

             if sqlca.sqlcode <> 0 and
                sqlca.sqlcode <> notfound then
                display "Erro SELECT c_bdbsa066008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                display "Codigo da CONTROLADORA: ", d_bdbsa066.mdtcod
                exit program(1)
             end if

             close c_bdbsa066008

             # --> BUSCA: TEMPO DE ATUALIZACAO RAPIDA
                        # VELOCIDADE LIMITE
                        # TEMPO DE ATUALIZACAO LENTA

             open c_bdbsa066009 using l_mdtctrcod
             whenever error continue
             fetch c_bdbsa066009 into l_segrpdatltmpqtd,
                                      l_fqctrclimvlcqtd,
                                      l_seglntatltmpqtd
             whenever error stop

             if sqlca.sqlcode <> 0 and
                sqlca.sqlcode <> notfound then
                display "Erro SELECT c_bdbsa066009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
                display "Codigo da CONTROLADORA: ", l_mdtctrcod
                exit program(1)
             end if

             close c_bdbsa066009

             # --> TRANSFORMA OS VALORES DE SEGUNDOS PARA MINUTOS

             let l_aux_rapida = "00:00"
             let l_aux_lenta  = "00:00"

             let l_fnl_rapida = "00:00"
             let l_fnl_lenta  = "00:00"

             let l_aux_rapida = (l_aux_rapida + l_segrpdatltmpqtd units second)
             let l_aux_lenta  = (l_aux_lenta  + l_seglntatltmpqtd units second)

             let l_fnl_rapida = l_fnl_rapida + l_aux_rapida
             let l_fnl_lenta  = l_fnl_lenta  + l_aux_lenta

             # --> MONTA A MENSAGEM PARA ENVIO

             let l_mensagem = "ATUALIZACAO;", l_fnl_rapida,      ";",
                                              l_fqctrclimvlcqtd, ";",
                                              l_fnl_lenta,       ";"

             let l_cod_erro = ctx01g07_envia_msg("",
                                                 "",
                                                 d_bdbsa066.mdtcod,
                                                 l_mensagem)

             if l_cod_erro <> 0 then
                display "Erro na funcao ctx01g07_envia_msg() ERRO - ", l_cod_erro
                #exit program(1)
             end if

          end if

          call bdbsa066_bot_mvt (ws.dataatu,
                                 ws.horaatu,
                                 d_bdbsa066.*)
               returning ws.erroflg

          if ws.erroflg  =  "S"   then
             continue foreach
          end if

       end if

       # PSI 214566 Gestao de Frota
       # buscar intervalo entre QRU para calculo de tempo medio
       let l_botao = 0
       if d_bdbsa066.mdtbotprgseq = 1 or   # QRU REC
          d_bdbsa066.mdtbotprgseq = 2 or   # QRU inicio
          d_bdbsa066.mdtbotprgseq = 3      # QRU fim
          then

          case d_bdbsa066.mdtbotprgseq
             when 1
                let l_botao = 9
             when 2
                let l_botao = 1
             when 3
                let l_botao = 2
          end case

          let l_intervalo = bdbsa066_intervalo( l_botao           ,
                                                d_bdbsa066.mdtcod ,
                                                d_bdbsa066.caddat ,
                                                d_bdbsa066.cadhor )

       end if

    end if

    #----------------------------------------------------------------------
    # Atualiza situacao do movimento (GPS/Botao)
    #----------------------------------------------------------------------
    execute upd_datmmdtmvt  using  ws.mdtmvtstt,
                                   l_intervalo,
                                   ws.atdsrvnum,
                                   ws.atdsrvano,
                                   d_bdbsa066.mdtmvtseq

    if sqlca.sqlcode  <>  0   then
       let ws.erroflg  =  "S"
       display ws.dataatu," ",ws.horaatu," ===> Mvt ",
               d_bdbsa066.mdtmvtseq using "<<<<<<<<<&",
               " : Erro (", sqlca.sqlcode using "<<<<<&",
               ") na atualizacao tabela datmmdtmvt"

    else
       ## GRAVA SERVICO PARA REC/INI/REM/FIM PROCESSADOS OK
       if ws.mdtmvtstt = 2 then  # PROCESSADOS OK

          if d_bdbsa066.mdtbotprgseq = 1  or    # REC
             d_bdbsa066.mdtbotprgseq = 2  or    # INI
             d_bdbsa066.mdtbotprgseq = 14 or    # REM
             d_bdbsa066.mdtbotprgseq = 3  then  # FIM

             call cts29g00_obter_multiplo(1,
                                          ws.atdsrvnum,
                                          ws.atdsrvano)
             returning ws.resultado,
                       ws.mensagem,
                       am_retorno[1].*,
                       am_retorno[2].*,
                       am_retorno[3].*,
                       am_retorno[4].*,
                       am_retorno[5].*,
                       am_retorno[6].*,
                       am_retorno[7].*,
                       am_retorno[8].*,
                       am_retorno[9].*,
                       am_retorno[10].*

             if ws.resultado = 3 then
                display ws.mensagem
                continue foreach
             end if

             for l_ind = 1 to 10

                if am_retorno[l_ind].atdmltsrvnum is not null then
                   execute pbdbsa066001 using ws.dataatu, ws.horaatu,
                                              d_bdbsa066.mdtcod,
                                              d_bdbsa066.mdtmvttipcod,
                                              d_bdbsa066.mdtbotprgseq,
                                              ws.srrcoddig,
                                              d_bdbsa066.ufdcod,
                                              d_bdbsa066.cidnom,
                                              d_bdbsa066.brrnom,
                                              d_bdbsa066.lclltt,
                                              d_bdbsa066.lcllgt,
                                              d_bdbsa066.mdtmvtdircod,
                                              d_bdbsa066.mdtmvtvlc,
                                              ws.mdtmvtstt,
                                              d_bdbsa066.endzon,
                                              ws.mdtmvtsnlflg,
                                              d_bdbsa066.mdttrxnum,
                                              am_retorno[l_ind].atdmltsrvnum,
                                              am_retorno[l_ind].atdmltsrvano,
                                              l_intervalo
                end if

             end for

             ###PSI208671
             case d_bdbsa066.mdtbotprgseq
               when 1 #REC
                 if  cts47g00_mesma_cidsed_srv(ws.atdsrvnum,          #(-1) nao encontrou
                                               ws.atdsrvano) = 1 then #( 0) cidade diferente
                     let l_atdsrvorg = 0                              #( 1) mesma cidade
                     whenever error continue
                     select atdsrvorg into l_atdsrvorg
                       from datmservico
                      where atdsrvnum = ws.atdsrvnum
                        and atdsrvano = ws.atdsrvano
                     whenever error stop

                     call ctx04g00_local_reduzido(ws.atdsrvnum,
                                                  ws.atdsrvano,
                                                  2) #QTI
                         returning lr_qti.*, l_resultado

                     let l_mensagem = d_bdbsa066.atdvclsgl clipped,
                                      " QRU:", l_atdsrvorg using "&&",
                                           "/", ws.atdsrvnum using "&&&&&&&",
                                           "-", ws.atdsrvano using "&&",
                                      " QTI:", lr_qti.lclidttxt clipped, " ",
                                               lr_qti.lgdtxt    clipped, "-",
                                               lr_qti.brrnom    clipped, "-",
                                               lr_qti.cidnom    clipped, "-",
                                               lr_qti.ufdcod    clipped, "#"

                     call bdbsa066_mdt_msg(ws.dataatu,
                                           ws.horaatu,
                                           d_bdbsa066.mdtmvtseq,
                                           d_bdbsa066.mdtcod,
                                           2,              #--> Sinal de bip initerrupto
                                           l_mensagem)
                          returning ws.erroflg

                 end if

               ### REMOVIDO PELO PSI 253006
               ###when 3 #FIM
               ###  open c_bdbsa066011 using ws.atdsrvnum,
               ###                           ws.atdsrvano
               ###
               ###  fetch c_bdbsa066011 into l_ciaempcod
               ###  if l_ciaempcod = 35 then
               ###      call bdbsa066_mdt_msg(ws.dataatu,
               ###                            ws.horaatu,
               ###                            d_bdbsa066.mdtmvtseq,
               ###                            d_bdbsa066.mdtcod,
               ###                            1,              #--> Sinal sem bip
               ###                            "SR. PRESTADOR, POR FAVOR, VOLTE A VIATURA AO PADRAO PORTO SEGURO")
               ###           returning ws.erroflg
               ###
               ###      let l_cod_erro = ctx01g07_envia_pager(d_bdbsa066.socvclcod,
               ###                            "AVISO DE DESPADRONIZACAO ", "SR. PRESTADOR, POR FAVOR, VOLTE A VIATURA AO PADRAO PORTO SEGURO")
               ###  end if

             end case
             ###PSI208671
          end if
       end if

    end if

    whenever error stop

 end foreach

 close c_datmmdtmvt

 let m_msg_proc = m_msg_proc clipped, " ", "Movimentos:", ws.qtdmvtgps using "#####&"

 # BUSCAR A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

 display "Fim function bdbsa066():  ", m_data_atual, " ", m_hora_atual

end function  ###--- bdbsa066

#----------------------------------------------#
function bdbsa066_replica_srv_multiplo(lr_param)
#----------------------------------------------#
  define lr_param record
         atdsrvnum     like datmservico.atdsrvnum,
         atdsrvano     like datmservico.atdsrvano,
         mdtmsgnum     like datmmdtmsg.mdtmsgnum,
         mdtmsgstt     like datmmdtmsg.mdtmsgstt,
         dataatu       date,
         horaatu       datetime hour to second
  end record

  define lr_ret        record
         resultado     smallint,
         mensagem      char(80)
  end record

  define al_retorno    array[10] of record
         atdmltsrvnum  like datratdmltsrv.atdmltsrvnum,
         atdmltsrvano  like datratdmltsrv.atdmltsrvano,
         socntzdes     like datksocntz.socntzdes,
         espdes        like dbskesp.espdes,
         atddfttxt     like datmservico.atddfttxt
  end record

  define lr_var         record
         mdtmsgorgcod   like datmmdtmsg.mdtmsgorgcod,
         mdtcod         like datmmdtmsg.mdtcod,
         mdtmsgavstip   like datmmdtmsg.mdtmsgavstip,
         mdtmsgnum      like datmmdtmsg.mdtmsgnum,
         mdtmsgtxtseq   like datmmdtmsgtxt.mdtmsgtxtseq,
         mdtmsgtxt      like datmmdtmsgtxt.mdtmsgtxt
  end record

  define l_ind        smallint

  initialize lr_var, lr_ret to null

  call cts29g00_obter_multiplo(1,
                               lr_param.atdsrvnum,
                               lr_param.atdsrvano)
  returning lr_ret.resultado,
            lr_ret.mensagem,
            al_retorno[1].*,
            al_retorno[2].*,
            al_retorno[3].*,
            al_retorno[4].*,
            al_retorno[5].*,
            al_retorno[6].*,
            al_retorno[7].*,
            al_retorno[8].*,
            al_retorno[9].*,
            al_retorno[10].*

  if lr_ret.resultado = 3 then
     return lr_ret.*
  end if

  let lr_ret.resultado = 1
  let lr_ret.mensagem  = null

  for l_ind = 1 to 10
       if al_retorno[l_ind].atdmltsrvnum is not null then
          open cbdbsa066003 using lr_param.mdtmsgnum
          whenever error continue
          fetch cbdbsa066003 into lr_var.mdtmsgorgcod,
                                  lr_var.mdtcod,
                                  lr_var.mdtmsgavstip
          whenever error stop
          if sqlca.sqlcode <> 0 then
             let lr_ret.resultado = 2
             let lr_ret.mensagem  = 'Erro ',sqlca.sqlcode,' em datmmdtmsg ',
                                    lr_param.mdtmsgnum,' / ',
                                    lr_param.atdsrvnum,' / ',
                                    lr_param.atdsrvano
             close cbdbsa066003
             return lr_ret.*
          end if

          close cbdbsa066003

          whenever error continue
          execute pbdbsa066004 using lr_var.mdtmsgorgcod,
                                     lr_var.mdtcod,
                                     lr_param.mdtmsgstt,
                                     lr_var.mdtmsgavstip
          whenever error stop
          if sqlca.sqlcode <> 0 then
             let lr_ret.resultado = 2
             let lr_ret.mensagem  = 'Erro ',sqlca.sqlcode,' em datmmdtmsg ',
                                    lr_param.mdtmsgnum,' / '
                                                                          ,lr_param.atdsrvnum,' / '
                                                                          ,lr_param.atdsrvano
             return lr_ret.*
          end if

          let lr_var.mdtmsgnum = sqlca.sqlerrd[2]

          whenever error continue
          execute pbdbsa066005 using lr_var.mdtmsgnum,
                                     al_retorno[l_ind].atdmltsrvnum,
                                     al_retorno[l_ind].atdmltsrvano
          whenever error stop
          if sqlca.sqlcode <> 0 then
             let lr_ret.resultado = 2
             let lr_ret.mensagem  = 'Erro ',sqlca.sqlcode,' em datmmdtsrv ',lr_param.mdtmsgnum,' / '
                                                                          ,lr_param.atdsrvnum,' / '
                                                                          ,lr_param.atdsrvano
             return lr_ret.*
          end if

          open  cbdbsa066006  using lr_param.mdtmsgnum
          foreach cbdbsa066006 into lr_var.mdtmsgtxtseq,
                                    lr_var.mdtmsgtxt

              whenever error continue
              execute pbdbsa066010 using lr_var.mdtmsgnum,
                                         lr_var.mdtmsgtxtseq,
                                         lr_var.mdtmsgtxt
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 let lr_ret.resultado = 2
                 let lr_ret.mensagem  = 'Erro ',sqlca.sqlcode,' em datmmdtmsgtxt ',
                                        lr_param.mdtmsgnum,' / '
                                       ,lr_param.atdsrvnum,' / '
                                       ,lr_param.atdsrvano
                 return lr_ret.*
              end if
          end foreach

          close cbdbsa066006

          execute pbdbsa066007 using lr_var.mdtmsgnum,
                                     lr_param.mdtmsgstt,
                                     lr_param.dataatu, lr_param.horaatu
          whenever error stop
          if sqlca.sqlcode <> 0 then
             let lr_ret.resultado = 2
             let lr_ret.mensagem  = 'Erro ',sqlca.sqlcode,' em datmmdtlog ',
                                    lr_param.mdtmsgnum,' / '
                                   ,lr_param.atdsrvnum,' / '
                                   ,lr_param.atdsrvano
             return lr_ret.*
          end if
       end if
  end for

  return lr_ret.*

end function


#----------------------------------------------------------------------
 function bdbsa066_bot_mvt(param)
#----------------------------------------------------------------------

 define param       record
   dataatu          date,
   horaatu          char (08),
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,
   atldat           like datmmdtlog.atldat,
   atlhor           like datmmdtlog.atlhor,
   mdtmvtseq        like datmmdtmvt.mdtmvtseq,
   caddat           like datmmdtmvt.caddat,
   cadhor           like datmmdtmvt.cadhor,
   mdtcod           like datmmdtmvt.mdtcod,
   mdtmvttipcod     like datmmdtmvt.mdtmvttipcod,
   mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
   mdtmvtdigcnt     like datmmdtmvt.mdtmvtdigcnt,
   ufdcod           like datmmdtmvt.ufdcod,
   cidnom           like datmmdtmvt.cidnom,
   brrnom           like datmmdtmvt.brrnom,
   endzon           like datmmdtmvt.endzon,
   lclltt           like datmmdtmvt.lclltt,
   lcllgt           like datmmdtmvt.lcllgt,
   mdtmvtdircod     like datmmdtmvt.mdtmvtdircod,
   mdtmvtvlc        like datmmdtmvt.mdtmvtvlc,
   socvclcod        like dattfrotalocal.socvclcod,
   atdvclsgl        like datkveiculo.atdvclsgl,
   mdtprgcod        like datkmdtprg.mdtprgcod,
   mdtbotprgdigflg  like datrmdtbotprg.mdtbotprgdigflg,
   atdsrvnum        like datmmdtsrv.atdsrvnum,
   atdsrvano        like datmmdtsrv.atdsrvano,
   mdttrxnum        like datmmdtmvt.mdttrxnum
 end record

 define ws          record
   socvcllcltip     like datmfrtpos.socvcllcltip,
   cttdat           like dattfrotalocal.cttdat,
   ctthor           like dattfrotalocal.ctthor,
   c24atvcod        like dattfrotalocal.c24atvcod,
   atdsrvnum        like dattfrotalocal.atdsrvnum,
   atdsrvano        like dattfrotalocal.atdsrvano,
   srrcoddig        like dattfrotalocal.srrcoddig,
   atlemp           like dattfrotalocal.atlemp,
   atlmat           like dattfrotalocal.atlmat,
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,
   mdtmsgstt        like datmmdtmsg.mdtmsgstt,
   mdtlogseq        like datmmdtlog.mdtlogseq,
   mdtmsgtxt        like datmmdtmsgtxt.mdtmsgtxt,
   srrstt           like datksrr.srrstt,
   srrnom           like datksrr.srrnom,
   srrabvnom        like datksrr.srrabvnom,
   pstcoddig        like dpaksocor.pstcoddig,
   nomgrr           like dpaksocor.nomgrr,
   hora             char (08),
   erroflg          char (01),
   nulos            char (02),
   resultado        smallint,
   mensagem         char(80),
   celdddcodsrr     like datksrr.celdddcod,
   celtelnumsrr     like datksrr.celtelnum
 end record

 define l_ind        smallint,
        l_cidnom     like datmlcl.cidnom,
        l_ufdcod     like datmlcl.ufdcod,
        l_cidcod     like glakcid.cidcod,
        l_bloqdat    like dpmmqrvsgnprt.dtvdat,
        l_funmatbloq like dpmmqrvsgnprt.dtvfunmat

 initialize ws to null

 let ws.erroflg       =  "N"
 let ws.hora          =  param.horaatu[1,5]

 #-------------------------------------------------------------------------
 # Busca posicao da frota (ATUAL)
 #-------------------------------------------------------------------------
 open  c_dattfrotalocal_1  using  param.socvclcod
 fetch c_dattfrotalocal_1  into   ws.cttdat,
                                ws.ctthor,
                                ws.c24atvcod,
                                ws.atdsrvnum,
                                ws.atdsrvano,
                                ws.srrcoddig,
                                ws.atlemp,
                                ws.atlmat
 close c_dattfrotalocal_1
 #-------------------------------------------------------------------------
 # Trata botoes
 #-------------------------------------------------------------------------
 case param.mdtbotprgseq
      when 01     #--> QRU RECEB
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "REC"

      when 02     #--> QRU INICIO
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "INI"

      when 03     #--> QRU FIM
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           if param.mdtmvtdigcnt=  99 then
             #let ws.c24atvcod  =  "FIM"
           else
              let ws.c24atvcod  =  "FIM"
           end if

      when 04     #--> F1
          # let ws.cttdat     =  param.dataatu
          # let ws.ctthor     =  ws.hora
          # let ws.c24atvcod  =  "F1"

      when 08     #--> QRA
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "QRA"
           let ws.srrcoddig  =  param.mdtmvtdigcnt
           let ws.atdsrvnum  = null
           let ws.atdsrvano  = null
           let ws.atlemp     = null
           let ws.atlmat     = null

           open  c_datksrr    using  ws.srrcoddig
           fetch c_datksrr    into   ws.srrstt,
                                     ws.srrnom,
                                     ws.srrabvnom,
                                     ws.celdddcodsrr,
                                     ws.celtelnumsrr
           close c_datksrr

           open   c_datrsrrpstvig  using  ws.srrcoddig
           fetch  c_datrsrrpstvig  into   ws.pstcoddig
           close  c_datrsrrpstvig

           open  c_dpaksocor  using  ws.pstcoddig
           fetch c_dpaksocor  into   ws.nomgrr
           close c_dpaksocor

           # MONTA FRASE PARA ENVIO DE MENSAGEM CONFIRMANDO OS TELEFONES.
           let ws.mdtmsgtxt = "QRA realizado com sucesso: ", ws.srrabvnom clipped, " base ",
                              ws.nomgrr clipped, ", viatura ", param.atdvclsgl clipped, "."

           if  ((mr_fones.celdddcodvcl is null or mr_fones.celdddcodvcl = " ")  or
                (mr_fones.celtelnumvcl is null or mr_fones.celtelnumvcl = " ")) and
               ((ws.celdddcodsrr is null or ws.celdddcodsrr = " ") or
                (ws.celtelnumsrr is null or ws.celtelnumsrr = " ")) then
               let ws.mdtmsgtxt = ws.mdtmsgtxt clipped, " Nao encontramos nem",
                                 " o celular da viatura nem do QRA no cadastro. Entre em contato com",
                                 " o Porto Socorro e cadastre os seus telefones de contato. Isso e",
                                 " importante para que o Auto Atendimento identifique voce corretamente."
           else

               if  (mr_fones.celdddcodvcl is null or 
                    mr_fones.celdddcodvcl = " ")  or
                   (mr_fones.celtelnumvcl is null or 
                    mr_fones.celtelnumvcl = " ") then
                    let ws.mdtmsgtxt = ws.mdtmsgtxt clipped, 
                                 " O celular da viatura nao esta cadastrado e "
               else
                    let ws.mdtmsgtxt = ws.mdtmsgtxt clipped, 
                            " O telefone que consta no cadastro da viatura e ",
                            "(", mr_fones.celdddcodvcl using "<&&", ") " , 
                                 mr_fones.celtelnumvcl using '<&&&&&&&&', " e "
               end if

               if  (ws.celdddcodsrr is null or ws.celdddcodsrr = " ") or
                   (ws.celtelnumsrr is null or ws.celtelnumsrr = " ") then
                    let ws.mdtmsgtxt = ws.mdtmsgtxt clipped,
                                       " o  celular do QRA nao esta cadastrado "
               else
                    let ws.mdtmsgtxt = ws.mdtmsgtxt clipped,
                                 " o telefone que consta no cadastro do QRA e ",
                                 "(", ws.celdddcodsrr using "<&&", ") " ,
                                      ws.celtelnumsrr using '<&&&&&&&&'
               end if

               let ws.mdtmsgtxt = ws.mdtmsgtxt clipped, ". Em caso de divergencia, entre em contato com o Porto Socorro. ",
                                  "E importante que estes numeros estejam sempre atualizados, ",
                                  "para que o Auto Atendimento identifique voce corretamente."
           end if

           # ENVIA MENSAGEM DE DISCAGEM AO SOCORRISTA
           call ctx01g07_envia_msg_id("","",m_mdtcod,ws.mdtmsgtxt)
                returning ws.erroflg,
                          ws.mensagem

      when 09     #--> QRV
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "QRV"
           initialize ws.atdsrvnum  to null
           initialize ws.atdsrvano  to null

      when 10     #--> QRX
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "QRX"
           initialize ws.atdsrvnum        to null
           initialize ws.atdsrvano        to null

      when 11     #--> QTP
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "QTP"
           initialize ws.atdsrvnum        to null
           initialize ws.atdsrvano        to null

      when 14     #--> QRU REMOCAO
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "REM"

           initialize l_bloqdat to null
           whenever error continue
           #Busca a cidade do serviço
           open c_bdbsa066016 using ws.atdsrvnum,
                                    ws.atdsrvano
           fetch c_bdbsa066016 into l_cidnom,
                                    l_ufdcod
           close c_bdbsa066016

           #Busca a cidade sede do serviço
           open c_bdbsa066017 using l_cidnom,
                                    l_ufdcod
           fetch c_bdbsa066017 into l_cidcod
           close c_bdbsa066017

           #Verifica se o QRV2 esta ativo para a cidade sede
           open c_bdbsa066015 using l_cidcod,l_cidcod
           fetch c_bdbsa066015 into l_bloqdat,
                                    l_funmatbloq

           if sqlca.sqlcode = 0 then
              if (l_bloqdat is null or l_bloqdat = ' ')      and   #caso a data de desbloqueio e o funcionario
                 (l_funmatbloq is null or l_funmatbloq = ' ') then #etiverem em branco ou nulo o qrv2 esta ATIVO
                                            # validação se a chave da porto socorro esta habilitada.
                 let ws.mdtmsgtxt = "@QRV2" #comando no qual ira acionar no gps a pergunta se o
  	          		            #segurado ira acompanhar ou não a remoção
  	      else
  	         let ws.mdtmsgtxt = null
              end if
           else
              let ws.mdtmsgtxt = null
           end if
           close c_bdbsa066015
           whenever error stop

      when 15     #--> QRU RETORNO
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "RET"

      when 18     #--> RODOVIA
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "ROD"

      when 28   # socorrista informou que quer atender uma remoção simultanea. PSI Encerrado o QRU anterior
           let ws.cttdat     =  param.dataatu
           let ws.ctthor     =  ws.hora
           let ws.c24atvcod  =  "QRV"
           initialize ws.atdsrvnum  to null
           initialize ws.atdsrvano  to null
           let ws.mdtmsgtxt = "Lanca/Asa liberada para receber novo servico. Viatura em QRV."

      otherwise   #--> Outros
           return ws.erroflg
 end case

 #-------------------------------------------------------------------------
 # Atualiza tabelas do sistema
 #-------------------------------------------------------------------------
 ##whenever error continue

    #----------------------------------------------------------------------
    # Realiza a baixa do servico(mensagem) recebida no MDT
    #----------------------------------------------------------------------
    if param.mdtbotprgseq  =  01   then   #--> QRU RECEB

       if ws.atdsrvnum  is not null   and
          ws.atdsrvano  is not null   then
          call  bdbsa066_atualiza_botao(ws.atdsrvnum, ws.atdsrvano,param.dataatu
                                       ,param.horaatu,param.mdtmvtseq)
                returning ws.resultado
       end if

   end if

    #----------------------------------------------------------------------
    # Grava mensagem de logon OK
    #----------------------------------------------------------------------
    if param.mdtbotprgseq  =  08   then   #--> QRA
       call bdbsa066_mdt_msg(param.dataatu,
                             param.horaatu,
                             param.mdtmvtseq,
                             param.mdtcod,
                             2,              #--> Sinal de bip initerrupto
                             ws.mdtmsgtxt)
            returning ws.erroflg

       if ws.erroflg  =  "S"   then
#         rollback work
          return ws.erroflg
       end if
    end if

    #Caso o botaão remoção tenha sido acionado e ele gerou uma msg e a envia
    if param.mdtbotprgseq  =  14  then   #--> QRU REMOCAO
       if ws.mdtmsgtxt is not null then
          call bdbsa066_mdt_msg(param.dataatu,
                                param.horaatu,
                                param.mdtmvtseq,
                                param.mdtcod,
                                2,              #--> Sinal de bip initerrupto
                                ws.mdtmsgtxt)
               returning ws.erroflg

          if ws.erroflg  =  "S"   then
             return ws.erroflg
          end if
       end if
    end if

    if param.mdtbotprgseq  =  28  then   #--> SEGUNDO QRV
       if ws.mdtmsgtxt is not null then
          call bdbsa066_mdt_msg(param.dataatu,
                                param.horaatu,
                                param.mdtmvtseq,
                                param.mdtcod,
                                2,              #--> Sinal de bip initerrupto
                                ws.mdtmsgtxt)
               returning ws.erroflg

          if ws.erroflg  =  "S"   then
             return ws.erroflg
          end if
       end if
    end if


    execute upd_dattfrotalocal_2  using  ws.cttdat,
                                         ws.ctthor,
                                         ws.c24atvcod,
                                         ws.atdsrvnum,
                                         ws.atdsrvano,
                                         ws.srrcoddig,
                                         ws.atlemp,
                                         ws.atlmat,

                                         param.socvclcod

    if sqlca.sqlcode  <>  0   then
       display param.dataatu," ",param.horaatu," ===> Mvt ",
               param.mdtmvtseq using "<<<<<<<<<&",
               " : Erro (", sqlca.sqlcode using "<<<<<&",
               ") na atualizacao tabela dattfrotalocal_2"
#      rollback work
       let ws.erroflg  =  "S"
       return ws.erroflg
    end if

    #----------------------------------------------------------------------
    # Atualiza posicao do veiculo (QTH/QTI)
    #----------------------------------------------------------------------
    if param.mdtbotprgseq  =  08   or
       param.mdtbotprgseq  =  09   or
       param.mdtbotprgseq  =  28   or
       param.mdtbotprgseq  =  11   then

       let ws.socvcllcltip  =  02
       execute upd_datmfrtpos_1  using  ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        param.dataatu,
                                        ws.hora,

                                        param.socvclcod,
                                        ws.socvcllcltip

       if sqlca.sqlcode  <>  0   then
          display param.dataatu," ",param.horaatu," ===> Mvt ",
                  param.mdtmvtseq using "<<<<<<<<<&",
                  " : Erro (", sqlca.sqlcode using "<<<<<&",
                  ") atualizacao tabela datmfrtpos_1 QTH"
#         rollback work
          let ws.erroflg  =  "S"
          return ws.erroflg
       end if

       let ws.socvcllcltip  =  03
       execute upd_datmfrtpos_1  using  ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        ws.nulos,
                                        param.dataatu,
                                        ws.hora,

                                        param.socvclcod,
                                        ws.socvcllcltip

       if sqlca.sqlcode  <>  0   then
          display param.dataatu," ",param.horaatu," ===> Mvt ",
                  param.mdtmvtseq using "<<<<<<<<<&",
                  " : Erro (", sqlca.sqlcode using "<<<<<&",
                  ") atualizacao tabela datmfrtpos_1 QTI"
#         rollback work
          let ws.erroflg  =  "S"
          return ws.erroflg
       end if

    end if

#commit work
 whenever error stop

 return ws.erroflg

 end function   ###--- bdbsa066_bot_mvt

#----------------------------------------#
function bdbsa066_atualiza_botao(lr_param)
#----------------------------------------#
 define lr_param record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano,
        dataatu       date,
        horaatu       char (08),
        mdtmvtseq     like datmmdtmvt.mdtmvtseq
 end record

  define lr_aux     record
   socvcllcltip     like datmfrtpos.socvcllcltip,
   cttdat           like dattfrotalocal.cttdat,
   ctthor           like dattfrotalocal.ctthor,
   c24atvcod        like dattfrotalocal.c24atvcod,
   atdsrvnum        like dattfrotalocal.atdsrvnum,
   atdsrvano        like dattfrotalocal.atdsrvano,
   srrcoddig        like dattfrotalocal.srrcoddig,
   atlemp           like dattfrotalocal.atlemp,
   atlmat           like dattfrotalocal.atlmat,
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,
   mdtmsgstt        like datmmdtmsg.mdtmsgstt,
   mdtlogseq        like datmmdtlog.mdtlogseq,
   mdtmsgtxt        like datmmdtmsgtxt.mdtmsgtxt,
   srrstt           like datksrr.srrstt,
   srrnom           like datksrr.srrnom,
   srrabvnom        like datksrr.srrabvnom,
   pstcoddig        like dpaksocor.pstcoddig,
   nomgrr           like dpaksocor.nomgrr,
   hora             char (08),
   erroflg          char (01),
   nulos            char (02),
   resultado        smallint,
   mensagem         char(80)
 end record

 define l_erro smallint

 let l_erro           = false
 let lr_aux.mdtmsgstt = 6 #--> Recebida OK

 open c_datmmdtsrv using lr_param.atdsrvnum,
                         lr_param.atdsrvano

 foreach c_datmmdtsrv into lr_aux.mdtmsgnum

    execute upd_datmmdtmsg using lr_aux.mdtmsgstt,
                                 lr_aux.mdtmsgnum
    if sqlca.sqlcode <> 0 then
       display lr_param.dataatu,"",lr_param.horaatu,"===> Mvt",
       lr_param.mdtmvtseq using "<<<<<<<<<&",
       ":Erro (", sqlca.sqlcode using "<<<<<&",
       ") na atualizacao tabela datmmdtmsg (2)"
       let l_erro = true
       exit foreach
    end if

    initialize lr_aux.mdtlogseq to null

    open c_datmmdtlog using lr_aux.mdtmsgnum
    fetch c_datmmdtlog into lr_aux.mdtlogseq
    close c_datmmdtlog

    if lr_aux.mdtlogseq is null then
      display lr_param.dataatu,"",lr_param.horaatu,"===> Msg",
      lr_aux.mdtmsgnum using "<<<<<<<<<&",
      ":Erro nao possui registro de log (2)"
      let l_erro = true
      exit foreach
    end if

    let lr_aux.mdtlogseq = lr_aux.mdtlogseq + 1

    execute ins_datmmdtlog using lr_aux.mdtmsgnum,
                                 lr_aux.mdtlogseq,
                                 lr_aux.mdtmsgstt,
                                 lr_param.dataatu, lr_param.horaatu
    if sqlca.sqlcode <> 0 then
       display lr_param.dataatu,"",lr_param.horaatu,"===> Msg",
       lr_aux.mdtmsgnum using "<<<<<<<<<&",
       ") na inclusao tabela datmmdtlog (2)"
       let l_erro = true
       exit foreach
    end if

    call bdbsa066_replica_srv_multiplo(lr_param.atdsrvnum,
                                       lr_param.atdsrvano,
                                       lr_aux.mdtmsgnum,
                                       lr_aux.mdtmsgstt,
                                       lr_param.dataatu,
                                       lr_param.horaatu)
         returning lr_aux.resultado, lr_aux.mensagem

    if lr_aux.resultado <> 1 then
       display lr_aux.mensagem
       let l_erro = true
    end if

 end foreach

 close c_datmmdtsrv

 if l_erro then
    return 2
 else
    return 1
 end if

end function

#----------------------------------------------------------------------
 function bdbsa066_mdt_logon(param)
#----------------------------------------------------------------------

 define param       record
   dataatu          date,
   horaatu          char (08),
   mdtmsgnum        like datmmdtmsg.mdtmsgnum,
   atldat           like datmmdtlog.atldat,
   atlhor           like datmmdtlog.atlhor,
   mdtmvtseq        like datmmdtmvt.mdtmvtseq,
   caddat           like datmmdtmvt.caddat,
   cadhor           like datmmdtmvt.cadhor,
   mdtcod           like datmmdtmvt.mdtcod,
   mdtmvttipcod     like datmmdtmvt.mdtmvttipcod,
   mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
   mdtmvtdigcnt     like datmmdtmvt.mdtmvtdigcnt,
   ufdcod           like datmmdtmvt.ufdcod,
   cidnom           like datmmdtmvt.cidnom,
   brrnom           like datmmdtmvt.brrnom,
   endzon           like datmmdtmvt.endzon,
   lclltt           like datmmdtmvt.lclltt,
   lcllgt           like datmmdtmvt.lcllgt,
   mdtmvtdircod     like datmmdtmvt.mdtmvtdircod,
   mdtmvtvlc        like datmmdtmvt.mdtmvtvlc,
   socvclcod        like dattfrotalocal.socvclcod,
   atdvclsgl        like datkveiculo.atdvclsgl,
   mdtprgcod        like datkmdtprg.mdtprgcod,
   mdtbotprgdigflg  like datrmdtbotprg.mdtbotprgdigflg,
   atdsrvnum        like datmmdtsrv.atdsrvnum,
   atdsrvano        like datmmdtsrv.atdsrvano,
   mdttrxnum        like datmmdtmvt.mdttrxnum,
   pstcoddig        like datkveiculo.pstcoddig
 end record

 define ws          record
   socvclcod        like dattfrotalocal.socvclcod,
   pstcoddig        like datrsrrpst.pstcoddig,
   vigfnl           like datrsrrpst.vigfnl,
   mdterrcod        like datmmdterr.mdterrcod,
   srrstt           like datksrr.srrstt,
   erroflg          char (01)
 end record

 initialize ws to null

 let ws.erroflg   =  "N"

 let param.mdtmvtdigcnt = param.mdtmvtdigcnt using "<<<<<<<&"

 let m_qra = param.mdtmvtdigcnt

 open   c_dattfrotalocal_2  using  param.mdtmvtdigcnt
 fetch  c_dattfrotalocal_2  into   ws.socvclcod
 if sqlca.sqlcode  =  0   then
    if param.socvclcod  =  ws.socvclcod   then
       let ws.mdterrcod  =  19
    else
       let ws.mdterrcod  =  20
    end if
    call bdbsa066_erro_mvt (param.dataatu,
                            param.horaatu,
                            param.mdtmvtseq,
                            ws.mdterrcod)
         returning ws.erroflg
    let ws.erroflg  =  "S"
    close  c_dattfrotalocal_2
    return ws.erroflg
 end if
 close  c_dattfrotalocal_2

 open   c_datksrr  using  param.mdtmvtdigcnt
 fetch  c_datksrr  into   ws.srrstt

 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode  =  notfound   then
       let ws.mdterrcod  =  15
       call bdbsa066_erro_mvt (param.dataatu,
                               param.horaatu,
                               param.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       let ws.erroflg  =  "S"
       close c_datksrr
       return ws.erroflg
    end if
 end if
 close  c_datksrr

 if ws.srrstt  <>  1   then
    let ws.mdterrcod  =  16
    call bdbsa066_erro_mvt (param.dataatu,
                            param.horaatu,
                            param.mdtmvtseq,
                            ws.mdterrcod)
         returning ws.erroflg
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 open   c_datrsrrpst  using  param.mdtmvtdigcnt
 fetch  c_datrsrrpst  into   ws.pstcoddig
 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode  =  notfound   then
       let ws.mdterrcod  =  17
       call bdbsa066_erro_mvt (param.dataatu,
                               param.horaatu,
                               param.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       let ws.erroflg  =  "S"
       close c_datrsrrpst
       return ws.erroflg
    end if
 end if
 close  c_datrsrrpst

 # BURINI DISCADORA - QRA NAO OPERACIONAL
 open c_datrsrrpstvnc using  param.mdtmvtdigcnt
 fetch  c_datrsrrpstvnc  into   ws.pstcoddig
 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode  =  notfound   then
       let ws.mdterrcod  =  24
       call bdbsa066_erro_mvt (param.dataatu,
                               param.horaatu,
                               param.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       let ws.erroflg  =  "S"
       close c_datrsrrpstvnc
       return ws.erroflg
    end if
 end if
 close  c_datrsrrpstvnc

 open c_datrsrrpstvig using  param.mdtmvtdigcnt
 fetch  c_datrsrrpstvig  into   ws.pstcoddig
 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode  =  notfound   then
       let ws.mdterrcod  =  25
       call bdbsa066_erro_mvt (param.dataatu,
                               param.horaatu,
                               param.mdtmvtseq,
                               ws.mdterrcod)
            returning ws.erroflg
       let ws.erroflg  =  "S"
       close c_datrsrrpstvig
       return ws.erroflg
    end if
 end if
 close  c_datrsrrpstvig
 ##################

 if ws.pstcoddig  <>  param.pstcoddig   then
    let ws.mdterrcod  =  18
    call bdbsa066_erro_mvt (param.dataatu,
                            param.horaatu,
                            param.mdtmvtseq,
                            ws.mdterrcod)
         returning ws.erroflg
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 return ws.erroflg

 end function   ###--- bdbsa066_mdt_logon


#--------------------------------------------------------------------------
 function bdbsa066_mdt_msg(param)
#--------------------------------------------------------------------------

 define param       record
   dataatu          date,
   horaatu          char (08),
   mdtmvtseq        like datmmdtmvt.mdtmvtseq,
   mdtcod           like datmmdtmsg.mdtcod,
   mdtmsgavstip     like datmmdtmsg.mdtmsgavstip,
   mdtmsgtxt        like datmmdtmsgtxt.mdtmsgtxt
 end record

 define ws          record
    mdtmsgnum       like datmmdtmsg.mdtmsgnum,
    um              smallint,
    erroflg         char (01)
 end record

 initialize ws  to null

 let ws.erroflg = "N"
 let ws.um      = 1

 execute ins_datmmdtmsg  using  param.mdtcod,
                                param.mdtmsgavstip

 if sqlca.sqlcode  <>  0   then
    display param.dataatu," ",param.horaatu," ===> Mvt ",
            param.mdtmvtseq using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na inclusao tabela datmmdtmsg"
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 let ws.mdtmsgnum  =  sqlca.sqlerrd[2]

 execute ins_datmmdtlog  using  ws.mdtmsgnum,
                                ws.um,
                                ws.um,
                                param.dataatu, param.horaatu

 if sqlca.sqlcode  <>  0   then
    display param.dataatu," ",param.horaatu," ===> Mvt ",
            param.mdtmvtseq using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na inclusao tabela datmmdtlog (2)"
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 execute ins_datmmdtmsgtxt  using  ws.mdtmsgnum,
                                   param.mdtmsgtxt

 if sqlca.sqlcode  <>  0   then
    display param.dataatu," ",param.horaatu," ===> Mvt ",
            param.mdtmvtseq using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na inclusao tabela datmmdtmsgtxt"
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 return ws.erroflg

 end function   ###--- bdbsa066_mdt_msg


#--------------------------------------------------------------------------
 function bdbsa066_erro_mvt(param)
#--------------------------------------------------------------------------

 define param       record
   dataatu          date,
   horaatu          datetime hour to second,
   mdtmvtseq        like datmmdtmvt.mdtmvtseq,
   mdterrcod        like datmmdterr.mdterrcod
 end record

 define ws          record
   mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
   mdtmvtstt        like datmmdtmvt.mdtmvtstt,
   erroflg          char (01)
 end record

 define l_msgmdt char(1000),
        l_retmsg char(0080)

 initialize ws.*,
            l_msgmdt to null

 let ws.erroflg    = "N"
 let ws.mdtmvtstt  =  3    #--> Processado com erro

 whenever error continue

 execute ins_datmmdterr  using  param.mdtmvtseq, param.mdterrcod

 execute upd_datmmdtmvt  using  ws.mdtmvtstt,
                                "",
                                "",
                                "",
                                param.mdtmvtseq

 if sqlca.sqlcode  <>  0   then
    display param.dataatu," ",param.horaatu," ===> Mvt ",
            param.mdtmvtseq using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na atualizacao tabela datmmdtmvt"
    let ws.erroflg  =  "S"
    return ws.erroflg
 end if

 whenever error stop

 open c_bdbsa066014 using param.mdtmvtseq
 fetch c_bdbsa066014 into ws.mdtbotprgseq

 if  ws.mdtbotprgseq = 08 then

     case param.mdterrcod
          when 15         #CODIGO DO SOCORRISTA NAO CADASTRADO
               let l_msgmdt = ", PORQUE ESTE QRA NAO ESTA CADASTRADO. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 16
               let l_msgmdt = ", PORQUE ESTE QRA NAO ESTA HABILITADO A RECEBER SERVICOS VIA GPS. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 17
               let l_msgmdt = ", PORQUE ESTE QRA NAO ESTA RELACIONADO A NENHUM PRESTADOR. EM CASO DE DIVERGÊNCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 18
               let l_msgmdt = " NESTA VIATURA, PORQUE ESTE QRA E ESTA VIATURA SAO DE PRESTADORES DIFERENTES. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 19
               let l_msgmdt = ", PORQUE ELE JA ESTA LOGADO. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 20
               let l_msgmdt = ", PORQUE ELE JA ESTA LOGADO EM OUTRA VIATURA. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 24
               let l_msgmdt = ", ESTE QRA NAO TEM AUTORIZACAO PARA RECEBER SERVICOS VIA GPS. EM CASO DE DIVERGENCIA, ENTRE EM CONTATO COM O PORTO SOCORRO."
          when 25
               let l_msgmdt = " EM UMA VIATURA, PORQUE NAO CONSTA UM VINCULO VIGENTE. ENTRE EM CONTATO COM O PORTO SOCORRO PARA ATUALIZAR O SEU CADASTRO."
     end case

     if  l_msgmdt is not null then
         let l_msgmdt = "NAO E POSSIVEL FAZER LOGIN COM O QRA ", m_qra using "<<<<<<&" , l_msgmdt

         # ENVIA MENSAGEM DE DISCAGEM AO SOCORRISTA
         call ctx01g07_envia_msg_id("","",m_mdtcod,l_msgmdt)
              returning ws.erroflg,
                        l_retmsg
     end if
 end if

 return ws.erroflg

 end function   ###--- bdbsa066_erro_mvt


# definir intervalo entre os sinais de QRU (rec, ini, fim)
# nao ha limite de tempo entre os sinais, a media devera conter os tempos reais
# formato "0000:00:00 ddmmyyyy" interval
# formato "yyyy-mm-dd 00:00:00" datetime
#----------------------------------------------------------------
function bdbsa066_intervalo(l_param)
#----------------------------------------------------------------
  define l_param record
         mdtbotprgseq  like datmmdtmvt.mdtbotprgseq ,
         mdtcod        like datmmdtmvt.mdtcod       ,
         caddat        date                         ,
         cadhor        datetime hour to second
  end record

  define l_aux record
         texto     char(19)                   ,
         datant    date                       ,
         horant    datetime hour to second    ,
         hora_ini  datetime year to second    ,
         hora_fim  datetime year to second    ,
         intervalo interval hour(3) to second
  end record

  initialize l_aux.* to null

  # definir datetime do botao
  let l_aux.texto = null
  let l_aux.texto = l_param.caddat using "yyyy-mm-dd", " ", l_param.cadhor
  let l_aux.hora_fim  = l_aux.texto

  # buscar sinal QRU anterior. Testar ultimos 3 para nao pegar sinais de
  # eventos posteriores
  whenever error continue
  open c_datmmdtmvt_qru using l_param.mdtbotprgseq, l_param.mdtcod
  whenever error stop

  foreach c_datmmdtmvt_qru into l_aux.datant, l_aux.horant
     let l_aux.texto    = l_aux.datant using "yyyy-mm-dd", " ", l_aux.horant
     let l_aux.hora_ini = l_aux.texto
     if l_aux.hora_ini < l_aux.hora_fim
        then
        exit foreach
     else
        let l_aux.hora_ini = null
     end if
  end foreach

  if l_aux.hora_ini is null
     then
     display "Erro na consulta ultimo sinal, MDT: ", l_param.mdtcod
     return l_aux.intervalo
  end if

  let l_aux.intervalo = l_aux.hora_fim - l_aux.hora_ini

  if l_aux.intervalo < "00:00:01"
     then
     let l_aux.intervalo = null
  end if

  return l_aux.intervalo

end function
