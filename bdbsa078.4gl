###############################################################################
# Nome do Modulo: bdbsa078                                        Marcelo     #
#                                                                 Gilberto    #
# Limpeza das mensagens do MDT e alertas p/ operadores do radio   Dez/1999    #
# ########################################################################### #
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
# -------------------------------------------------------------------------   #
# 31/08/2000  AS-21709     Marcus       Aumentar o dias de 7>15 da limpeza    #
# ########################################################################### #
#                        * * * A L T E R A C A O * * *                        #
#  Analista Resp. : Raji Jahchan                                              #
#  PSI            : 166480 - OSF: 19372                                       #
# .........................................................................   #
#  Data        Autor Fabrica  Alteracao                                       #
#  ----------  -------------  ---------------------------------------------   #
#  27/05/2003  Gustavo(FSW)   Limpeza  das  mensagens  do MDT e alertas p/    #
#                             operadores do radio.                            #
# ########################################################################### #
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ---------------------------------   #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#---------------------------------------------------------------------------  #
# 05/04/2005 META, Marcos M.P. PSI.188603 Alteracao no processo de Limpeza    #
#   Analista Carlos Zyon                  de Transmissoes dos servicos GPS.   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#                                                                             #
# 21/06/2006 Ligia Mattge       201501    Limpeza das tabelas:                #
#                                         dammtrx, dammtrxtxt, dammtrxdst e   #
#                                         datmtltmsglog                       #
#                                                                             #
# 31/07/2007 Sergio Burini      ------    Inclusão da limpeza das tabelas:    #
#                                         dbsmsrvacr, dbsmsrvcst              #
# 16/04/2008 Norton Nery        ------    Inclusão da limpeza da  tabela :    #
#                                         datmmdtinc                          #
# 29/10/2008 Fabio Costa        214566    Nao apagar sinais GPS c/ atdsrvnum  #
#                                         REC e FIM (gestao de frota)         # 
# 26/05/2014 Rodolfo Massini    ------    Alteracao na forma de envio de      #
#                                         e-mail (SENDMAIL para FIGRC009)     # 
###############################################################################

 database porto

 define m_path        char(100)

 define ma_bdbsa078   array[10] of record
    tabnom            char (20),
    qtdexc            integer
 end record

 define m_arr_aux     smallint
       ,m_sql         char(250)
       ,m_grlchv      char(15)
       ,m_diamax      smallint

 main
    call fun_dba_abre_banco("GUINCHOGPS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa078.log"

    call startlog(m_path)
    # PSI 185035 - Final

   call bdbsa078()
 end main

#------------------------------------------------------------
 function bdbsa078()
#------------------------------------------------------------

 define d_bdbsa078    record
    mdtmsgnum         like datmmdtmsg.mdtmsgnum,
    mdtmvtseq         like datmmdtmvt.mdtmvtseq,
    socvclaleseq      like datmfrtale.socvclaleseq,
    c24trxnum         like dammtrx.c24trxnum,
    mstnum            like datmtltmsglog.mstnum,
    mstnumseq         like datmtltmsglog.mstnumseq
 end record

 define ws            record
    atldat            like datmmdtlog.atldat,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdetpseq         like datmsrvint.atdetpseq
 end record

 define l_cmd   char(700),
        l_erro  smallint,
        l_msg   char(50),
	l_rowid integer

 define l_mens  record
        msg     char(300)
       ,de      char(700)
       ,subject char(100)
       ,para    char(100)
       ,cc      char(100)
       end record

 define l_today       date,
        l_time        datetime hour to minute,
        l_contados    smallint,
        l_conta       smallint,
        l_conta_txt   smallint,
        l_conta_dst   smallint,
        l_conta_trs   smallint,
        l_conta_log   smallint,
        l_conta_cst   smallint,
        l_conta_acr   smallint,
        l_conta_inc   integer
 
 ### RODOLFO MASSINI - INICIO 
 #---> Variaves para:
 #     remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em maio/2014
 
 define lr_mail record       
        rem char(50),        
        des char(250),       
        ccp char(250),       
        cco char(250),       
        ass char(500),       
        msg char(32000),     
        idr char(20),        
        tip char(4)          
 end record 
 
 define l_anexo   char (300)
       ,l_retorno smallint

 initialize lr_mail
           ,l_anexo
           ,l_retorno
 to null
 
 ### RODOLFO MASSINI - FIM        

 #-------------------------------------------------------------------------
 # Inicializacao das variaveis
 #-------------------------------------------------------------------------
 initialize ma_bdbsa078   to null
 initialize d_bdbsa078.*  to null
 initialize ws.*          to null

 let ma_bdbsa078[01].tabnom = "datmmdtmsg"
 let ma_bdbsa078[02].tabnom = "datmmdtmsgtxt"
 let ma_bdbsa078[03].tabnom = "datmmdtsrv"
 let ma_bdbsa078[04].tabnom = "datmmdtlog"
 let ma_bdbsa078[05].tabnom = "datmmdtmvt"
 let ma_bdbsa078[06].tabnom = "datmmdterr"
 let ma_bdbsa078[07].tabnom = "datmfrtale"
 let ma_bdbsa078[08].tabnom = "datmmdtinc"
 let ma_bdbsa078[09].tabnom = "datmsrvint"
 let ma_bdbsa078[10].tabnom = "datmsrvintseqult"

 for m_arr_aux = 1 to 10
    let ma_bdbsa078[m_arr_aux].qtdexc = 0
 end for

 #-------------------------------------------------------------------------
 # Prepara comandos SQL
 #-------------------------------------------------------------------------
 let m_sql = "delete from datmmdtmsg",
             " where mdtmsgnum = ?  "
 prepare pbdbsa078005 from m_sql

 let m_sql = "delete from datmmdtmsgtxt",
             " where mdtmsgnum = ?     "
 prepare pbdbsa078006 from m_sql

 let m_sql = "delete from datmmdtsrv",
             " where mdtmsgnum = ?  "
 prepare pbdbsa078007 from m_sql

 let m_sql = "delete from datmmdtlog",
             " where mdtmsgnum = ?  "
 prepare pbdbsa078008 from m_sql

 let m_sql = "delete from datmmdtmvt",
             " where mdtmvtseq = ?  "
 prepare pbdbsa078009 from m_sql

 let m_sql = "delete from datmmdterr",
             " where mdtmvtseq = ?  "
 prepare pbdbsa078010 from m_sql

 let m_sql = "delete from datmfrtale ",
             " where socvclaleseq = ?"
 prepare pbdbsa078011 from m_sql

 let m_sql = "delete from dammtrxtxt ",
             " where c24trxnum = ? "
 prepare pbdbsa078012 from m_sql

 let m_sql = "delete from dammtrxdst ",
             " where c24trxnum = ? "
 prepare pbdbsa078013 from m_sql

 let m_sql = "delete from dammtrx ",
             " where c24trxnum = ? "
 prepare pbdbsa078014 from m_sql

 let m_sql = "delete from datmtltmsglog ",
             " where mstnum = ? ",
             "   and mstnumseq = ? "
 prepare pbdbsa078015 from m_sql

 let m_sql = "delete from datmmdtinc ",
             " where rowid = ? "
 prepare pbdbsa078016 from m_sql

 let m_sql = "select rowid           ",
             "from datmservico       ",
             "where atdsrvnum = ?    ",
             "  and atdsrvano = ?    "
 prepare pbdbsa078001 from m_sql
 declare cbdbsa078001 cursor for pbdbsa078001

 let m_sql = "select grlinf       ",
             "from datkgeral      ",
             "where grlchv = ?    "
 prepare pbdbsa078018 from m_sql
 declare cbdbsa078018 cursor for pbdbsa078018

 let m_sql = "delete from datmsrvint ",
             "where atdsrvnum = ? ",
              " and atdsrvano = ? ",
              " and atdetpseq = ? "
 prepare pbdbsa078019 from m_sql

 let m_sql = "delete from datmsrvintseqult ",
             "where atdsrvnum = ? ",
              " and atdsrvano = ? "
 prepare pbdbsa078020 from m_sql

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo mensagens sem servico - Inicio: ", l_time

 declare cbdbsa078002 cursor with hold for
    # Mensagem de acionamento com servico apagado
    select a.mdtmsgnum
      from datmmdtsrv a
     where not exists (select b.atdsrvnum, b.atdsrvano
                         from datmservico b
                        where b.atdsrvnum = a.atdsrvnum
                          and b.atdsrvano = a.atdsrvano)
    union                          
    # Mensagem pendente de tratamento
    select msg.mdtmsgnum
      from datmmdtmsg msg,
           datmmdtlog msglog
     where msg.mdtmsgstt in (1,2,3,4)
       and msglog.mdtmsgnum = msg.mdtmsgnum 
       and msglog.mdtlogseq = 1 
       and msglog.atldat < (TODAY - 2 units DAY)

 foreach cbdbsa078002 into d_bdbsa078.mdtmsgnum

    let m_arr_aux = 1

    begin work

    execute pbdbsa078005 using d_bdbsa078.mdtmsgnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTMSG!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

    execute pbdbsa078006 using d_bdbsa078.mdtmsgnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTMSGTXT!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

    execute pbdbsa078007 using d_bdbsa078.mdtmsgnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTSRV!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

    execute pbdbsa078008 using d_bdbsa078.mdtmsgnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTLOG!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

     commit work   

 end foreach


 #-------------------------------------------------------------------------
 # Remover movimento MDT
 #-------------------------------------------------------------------------
 
 #######################
 ### Grupo de sinais ###
 #######################

 #Obtem a quantidade de dias que os sinais ficam armazenados no banco
 let m_grlchv = "PSODELDIASINGPS"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 15
 end if
 close cbdbsa078018

 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo sinais GPS anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 let m_sql = null
 let m_sql = "select mdtmvtseq, atdsrvnum, atdsrvano, mdtmvttipcod   "
            ,"from datmmdtmvt "
            ,"where caddat      <=                       '",ws.atldat,"'"
            ,"  and mdtmvttipcod in (1,3) "

 call del_mdt_bdbsa078('S')


 ####################################
 ### Grupo de botoes de atividade ###
 ####################################

 #Obtem a quantidade de dias que os botoes de atividade ficam armazenados no banco
 let m_grlchv = "PSODELDIABOTATV"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 60
 end if
 close cbdbsa078018

 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo botoes de atividade anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 let m_sql = null
 let m_sql = "select mdtmvtseq                            "
            ,"from datmmdtmvt                             "
            ,"where caddat      <=                       '",ws.atldat,"'"
            ,"  and mdtmvttipcod = 2                      "
            ,"  and mdtbotprgseq in(4,5,6,7,8,9,10,11,12,16,18) "

 call del_mdt_bdbsa078('T')


 ##################################
 ### Grupo de botoes de servico ###
 ##################################

 #Obtem a quantidade de dias que os botoes de servico ficam armazenados no banco
 let m_grlchv = "PSODELDIABOTSRV"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 365
 end if
 close cbdbsa078018

 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo botoes de servico anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 let m_sql = null
 let m_sql = "select mdtmvtseq, atdsrvnum, atdsrvano      "
            ,"from datmmdtmvt                             "
            ,"where caddat      <=                       '",ws.atldat,"'"
            ,"  and mdtmvttipcod = 2                      "
            ,"  and mdtbotprgseq in(1,2,3,14,15,20)       "

 call del_mdt_bdbsa078('V')

 ####################################
 ###  Remover alertas para frota  ###
 ####################################
 
 #Obtem a quantidade de dias que os sinais ficam armazenados no banco
 let m_grlchv = "PSODELDIAALEGPS"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 2
 end if
 close cbdbsa078018
 
 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo alertas para frota anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 declare cbdbsa078003 cursor with hold  for
    select socvclaleseq
      from datmfrtale
     where socvclalesit = 2
       and atldat <= ws.atldat

 foreach cbdbsa078003 into d_bdbsa078.socvclaleseq
    let m_arr_aux = 7

    execute pbdbsa078011 using d_bdbsa078.socvclaleseq

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMFRTALE!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

 end foreach


 #########################################
 ###  Remover Inconsistencia da Frota  ###
 #########################################

 #Obtem a quantidade de dias que os sinais ficam armazenados no banco
 let m_grlchv = "PSODELDIAINCGPS"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 180
 end if
 close cbdbsa078018

 let ws.atldat = null
 let ws.atldat   = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo inconsistencias da frota anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 let l_conta_inc = 0
 let l_conta     = 1
 let l_contados  = 1000

 declare cbdbsa078017  cursor with hold  for
   select rowid 
    from datmmdtinc 
   where caddat   < ws.atldat

 foreach cbdbsa078017 into l_rowid     
    
    if l_conta = 1 then
       begin work
    end if   

    let m_arr_aux = 8
    execute pbdbsa078016 using l_rowid

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTINC!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = 
        ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]

    let l_conta_inc = l_conta_inc + sqlca.sqlerrd[3]

    if l_conta = l_contados then
       commit work
       let l_conta = 1
     else
       let l_conta = l_conta + 1
    end if

 end foreach

 if l_conta > 1 and l_conta <> l_contados then
    commit work
 end if


 ######################################################
 ###  Remover as transmissoes de mensagens (email)  ###
 ######################################################

 #Obtem a quantidade de dias que os sinais ficam armazenados no banco
 let m_grlchv = "PSODELDIAMSGMAI"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 15
 end if
 close cbdbsa078018
 
 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo transmissoes via email anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 declare cbdbsa078005 cursor with hold  for
    select c24trxnum from dammtrx
     where c24msgtrxdat <= ws.atldat

 let l_contados = 1000
 let l_conta = 1
 let l_conta_txt = 0
 let l_conta_dst = 0
 let l_conta_trs = 0
 let l_conta_log = 0

 foreach cbdbsa078005 into d_bdbsa078.c24trxnum

    if l_conta = 1 then
       begin work
    end if

    ## Removendo textos
    execute pbdbsa078012 using d_bdbsa078.c24trxnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DAMMTRXTXT!"
       rollback work
       exit program (1)
    end if

    let l_conta_txt = l_conta_txt + sqlca.sqlerrd[3]

    ## Removendo destinatarios
    execute pbdbsa078013 using d_bdbsa078.c24trxnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DAMMTRXDST!"
       rollback work
       exit program (1)
    end if

    let l_conta_dst = l_conta_dst + sqlca.sqlerrd[3]

    ## Removendo transmissao
    execute pbdbsa078014 using d_bdbsa078.c24trxnum

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DAMMTRX!"
       rollback work
       exit program (1)
    end if

    let l_conta_trs = l_conta_trs + sqlca.sqlerrd[3]

    if l_conta = l_contados then
       commit work  
       let l_conta = 1
    else
       let l_conta = l_conta + 1
    end if

 end foreach

 if l_conta > 1 and l_conta <> l_contados then
    commit work  
 end if


 #############################################
 ###  Remover acerto de valores do portal  ###
 #############################################

 #Obtem a quantidade de dias que os sinais ficam armazenados no banco
 let m_grlchv = "PSODELDIAACRWEB"
 open  cbdbsa078018 using m_grlchv
 whenever error continue
 fetch cbdbsa078018 into m_diamax
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_diamax = 1825 # 5 anos
 end if
 close cbdbsa078018
 
 let ws.atldat = null
 let ws.atldat = l_today - m_diamax units day

 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo acerto de valores WEB anteriores a ", m_diamax using "<<<<&", " dias  - Inicio: ", l_time

 declare c_dbsmsrvacr cursor for
    select dbsmsrvacr.atdsrvnum,
           dbsmsrvacr.atdsrvano
      from dbsmsrvacr
     where caddat < ws.atldat

 let l_conta     = 1
 let l_conta_cst = 0
 let l_conta_acr = 0
 
 #begin work

 foreach c_dbsmsrvacr into ws.atdsrvnum,
                           ws.atdsrvano

    #if  l_conta = 1 then
    #    begin work
    #end if

    delete from dbsmsrvcst where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVCST!"
       #rollback work
       exit program (1)
    end if

    let l_conta_cst = l_conta_cst + sqlca.sqlerrd[3]

    delete from dbsmsrvacr where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVACR!"
       #rollback work
       exit program (1)
    end if

    let l_conta_acr = l_conta_acr + sqlca.sqlerrd[3]

    #if l_conta = l_contados then
    #   commit work  
    #   let l_conta = 1
    #else
    #   let l_conta = l_conta + 1
    #end if

 end foreach

 #if l_conta > 1 and l_conta <> l_contados then
    #commit work  
 #end if



 ############################################
 ###  Remover acerto ja pagos sem acerto  ###
 ############################################
 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo acerto WEB pendente SRV ja pago - Inicio: ", l_time

 declare c_dbsmsrvacrpag cursor for
    select dbsmsrvacr.atdsrvnum,
           dbsmsrvacr.atdsrvano
      from dbsmsrvacr, dbsmopgitm, dbsmopg
     where anlokaflg in ( "N", "P")
       and dbsmsrvacr.atdsrvnum = dbsmopgitm.atdsrvnum
       and dbsmsrvacr.atdsrvano = dbsmopgitm.atdsrvano
       and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
       and socopgsitcod <> 8

 let l_conta     = 1
 let l_conta_cst = 0
 let l_conta_acr = 0
 #begin work
 
 foreach c_dbsmsrvacrpag into ws.atdsrvnum,
                              ws.atdsrvano

    #if  l_conta = 1 then
    #    begin work
    #end if

    delete from dbsmsrvcst where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVCST!"
       #rollback work
       exit program (1)
    end if

    let l_conta_cst = l_conta_cst + sqlca.sqlerrd[3]

    delete from dbsmsrvacr where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVACR!"
       #rollback work
       exit program (1)
    end if

    let l_conta_acr = l_conta_acr + sqlca.sqlerrd[3]

    #if l_conta = l_contados then
    #   commit work  
    #   let l_conta = 1
    #else
    #   let l_conta = l_conta + 1
    #end if

 end foreach

 #if l_conta > 1 and l_conta <> l_contados then
    #commit work  
 #end if

 #################################################
 ###  Remover acerto com prestador divergente  ###
 #################################################
 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo acerto WEB com prestador divergente - Inicio: ", l_time

 declare c_dbsmsrvacrpst cursor for
       select acr.atdsrvnum,
              acr.atdsrvano
         from dbsmsrvacr acr, datmservico srv
        where acr.pstcoddig <> srv.atdprscod
          and acr.atdsrvnum = srv.atdsrvnum
          and acr.atdsrvano = srv.atdsrvano
          and acr.caddat > (today - 10 units day)

 let l_conta     = 1
 let l_conta_cst = 0
 let l_conta_acr = 0
 #begin work         
 
 foreach c_dbsmsrvacrpst into ws.atdsrvnum,
                              ws.atdsrvano

    #if  l_conta = 1 then
    #    begin work
    #end if

    delete from dbsmsrvcst where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVCST!"
       #rollback work
       exit program (1)
    end if

    let l_conta_cst = l_conta_cst + sqlca.sqlerrd[3]

    delete from dbsmsrvacr where atdsrvnum = ws.atdsrvnum and
                                 atdsrvano = ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DBSMSRVACR!"
       #rollback work
       exit program (1)
    end if

    let l_conta_acr = l_conta_acr + sqlca.sqlerrd[3]

    #if l_conta = l_contados then
    #   commit work  
    #   let l_conta = 1
    #else
    #   let l_conta = l_conta + 1
    #end if

 end foreach

 #if l_conta > 1 and l_conta <> l_contados then
    #commit work  
 #end if

#****

 ################################################################
 ###  Remover envio de servico para internet a mais de 1 ano  ###
 ################################################################
 call cts40g03_data_hora_banco(2) returning l_today, l_time
 display "Removendo envio de servico para internet a mais de 1 ano - Inicio: ", l_time

 declare c_datmsrvint cursor for
    select atdsrvnum,
           atdsrvano,
           atdetpseq
      from datmsrvint
     where caddat < (TODAY - 1 units year)

 foreach c_datmsrvint into ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.atdetpseq

    ## Removendo etapa internet
    execute pbdbsa078019 using ws.atdsrvnum,
                               ws.atdsrvano,
                               ws.atdetpseq

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMSRVINT!"
       exit program (1)
    end if

    let ma_bdbsa078[9].qtdexc = ma_bdbsa078[9].qtdexc + sqlca.sqlerrd[3]

    ## Removendo etapa internet ultima sequencia
    execute pbdbsa078020 using ws.atdsrvnum,
                               ws.atdsrvano

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMSRVINTSEQULT!"
       exit program (1)
    end if

    let ma_bdbsa078[10].qtdexc = ma_bdbsa078[10].qtdexc + sqlca.sqlerrd[3]

 end foreach


 #****
  
 #######################################################
 ###  Exibe total de registros removidos por tabela  ###
 #######################################################
 display "                                 "
 display " <<< RESUMO DE PROCESSAMENTO >>> "
 display "                                 "
 display " TABELA               QUANTIDADE "
 display " ------------------------------- "
 for m_arr_aux = 1 to 10
    display " ", ma_bdbsa078[m_arr_aux].tabnom, " ", ma_bdbsa078[m_arr_aux].qtdexc using "#######&"
 end for

 display " dammtrx       ", l_conta_trs  using "#######&"
 display " dammtrxtxt    ", l_conta_txt  using "#######&"
 display " dammtrxdst    ", l_conta_dst  using "#######&"
 display " datmtltmsglog ", l_conta_log  using "#######&"
 display " dbsmsrvcst    ", l_conta_cst  using "#######&"
 display " dbsmsrvacr    ", l_conta_acr  using "#######&"

 display " -----------------------fim----- "
 display " "

 ## Busca os destinatarios que receberao o resumo acima
 call cty11g00_iddkdominio("bdbsa078", 01)
      returning l_erro, l_msg, l_mens.para

 call cty11g00_iddkdominio("bdbsa078", 02)
      returning l_erro, l_msg, l_mens.cc

 let l_mens.msg = "TOTAL DE REGISTROS REMOVIDOS / ",
                  "dammtrx: ", l_conta_trs  using "<<<<<<<<<&", " / ",
                  "dammtrxtxt: ", l_conta_txt  using "<<<<<<<<<&", " / ",
                  "dammtrxdst: ", l_conta_dst  using "<<<<<<<<<&", " / ",
                  "datmtltmsglog: ", l_conta_log  using "<<<<<<<<<&", " / ",
                  "dbsmsrvcst:    ", l_conta_cst  using "<<<<<<<<<&", " / ",
                  "dbsmsrvacr:    ", l_conta_acr  using "<<<<<<<<<&"

 
 ### RODOLFO MASSINI - INICIO 
 #---> remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em maio/2014
  
 #let l_mens.de  = "CT24H-BDBSA078"
 #let l_mens.subject = "Limpeza Quinzenal das tabelas"
 #let l_cmd = ' echo "', l_mens.msg clipped,
 #               '" | send_email.sh ',
 #               ' -r ' ,l_mens.de clipped,
 #               ' -a ' ,l_mens.para clipped,
 #               ' -cc ',l_mens.cc clipped,
 #               ' -s "',l_mens.subject clipped, '" '
 #run l_cmd returning l_erro
 
 let lr_mail.ass = "Limpeza Quinzenal das tabelas"   
 let lr_mail.msg = l_mens.msg  clipped 
 let lr_mail.rem = l_mens.de   clipped 
 let lr_mail.des = l_mens.para clipped
 let lr_mail.ccp = l_mens.cc   clipped
 let lr_mail.tip = "text"
 let l_anexo = null
 
 call ctx22g00_envia_email_overload(lr_mail.*
                                   ,l_anexo)
 returning l_retorno   
 
 let l_erro = l_retorno                                     
                                                
 ### RODOLFO MASSINI - FIM 

 if l_erro = 0 then
    display 'Email enviado com sucesso'
 else
    display 'Email NAO enviado'
 end if

 end function  ###--  bdbsa078

#-------------------------------------
 function del_mdt_bdbsa078(l_tipo)
#-------------------------------------

 define l_tipo      char(01)

 define l_mdtmvtseq     like datmmdtmvt.mdtmvtseq
       ,l_atdsrvnum     like datmmdtmvt.atdsrvnum
       ,l_atdsrvano     like datmmdtmvt.atdsrvano
       ,l_mdtmvttipcod  like datmmdtmvt.mdtmvttipcod
       
 prepare pbdbsa078004 from m_sql
 declare cbdbsa078004 cursor with hold for pbdbsa078004
 
 let l_mdtmvtseq = null
 open    cbdbsa078004
 foreach cbdbsa078004 into l_mdtmvtseq
                          ,l_atdsrvnum
                          ,l_atdsrvano
                          ,l_mdtmvttipcod
                          
    ###if l_tipo = 'V' then
    ###   open  cbdbsa078001 using l_atdsrvnum
    ###                           ,l_atdsrvano
    ###   whenever error continue
    ###   fetch cbdbsa078001
    ###   whenever error stop
    ###
    ###   if sqlca.sqlcode = 0 then
    ###      close cbdbsa078001
    ###      continue foreach
    ###   else
    ###      if sqlca.sqlcode <  0 then
    ###         display "Erro (", sqlca.sqlcode, ") no acesso da "
    ###                ,"tabela DATMSERVICO!"
    ###         close cbdbsa078001
    ###         exit program (1)
    ###      end if
    ###   end if
    ###   close cbdbsa078001
    ###end if

    let m_arr_aux = 5

    execute pbdbsa078009 using l_mdtmvtseq

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTLOG!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

    execute pbdbsa078010 using l_mdtmvtseq

    if sqlca.sqlcode <> 0   then
       display "Erro (", sqlca.sqlcode, ") na limpeza da tabela DATMMDTLOG!"
       rollback work
       exit program (1)
    end if

    let ma_bdbsa078[m_arr_aux].qtdexc = ma_bdbsa078[m_arr_aux].qtdexc + sqlca.sqlerrd[3]
    let m_arr_aux = m_arr_aux + 1

 end foreach

 end function
