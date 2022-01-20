#-----------------------------------------------------------------------------#
#                      PORTO SEGURO CIA DE SEGUROS GERAIS                     #
#.............................................................................#
#                                                                             #
#  Modulo              : bdbsr104                                             #
#  Analista Responsavel: Raji Jahchan                                         #
#  PSI/OSF             : 166480/19372 - Relatorio  mensal  de  acompanhamento #
#                                       Ponto a Ponto, enviado por email.     #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Fabrica de Software - Gustavo Bayarri                #
#  Data                : 26/05/2003                                           #
#-----------------------------------------------------------------------------#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
# ----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual e   #
#                                         incluida funcao fun_dba_abre_banco. #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################


database porto

  define m_prepare    char(01)
        ,m_hostname   char(03)
        ,m_saida      char(60)
        ,m_dt_proc    char(10)
        ,m_dt_final   date
        ,m_dt_inicial date
        ,m_log        char(1000)
        ,m_comando    char(1500)
        ,m_envia      char(01)
        ,m_ret        smallint
        ,m_cmd        char(500)

main

  call fun_dba_abre_banco("CT24HS")

  set isolation to dirty read

  call bdbsr104()

  let m_log = null

  let m_log = 'FIM PROCESSAMENTO ACOMPANHAMENTO PONTO A PONTO!'

  call errorlog(m_log)

end main

#----------------------------------------------
function bdbsr104_prepare()
#----------------------------------------------

  let m_comando = "select atdsrvnum, atdsrvano, atdsrvorg,      "
                 ,"atddat, atdhor                               "
                 ,"from datmservico                             "
                 ,"where atddat between ? and ?                 "

  prepare pbdbsr104002 from m_comando
  declare cbdbsr104002 cursor for pbdbsr104002

  let m_comando = "select max(atdsrvseq)                        "
                 ,"from datmsrvacp                              "
                 ,"where atdsrvnum = ?                          "
                 ,"  and atdsrvano = ?                          "

  prepare pbdbsr104003 from m_comando
  declare cbdbsr104003 cursor for pbdbsr104003

  let m_comando = "select atdetpcod, pstcoddig, socvclcod,      "
                 ,"srrcoddig                                    "
                 ,"from datmsrvacp                              "
                 ,"where atdsrvnum = ?                          "
                 ,"  and atdsrvano = ?                          "
                 ,"  and atdsrvseq = ?                          "

  prepare pbdbsr104004 from m_comando
  declare cbdbsr104004 cursor for pbdbsr104004

  let m_comando = "select atdvclsgl                             "
                 ,"from datkveiculo                             "
                 ,"where socvclcod = ?                          "

  prepare pbdbsr104005 from m_comando
  declare cbdbsr104005 cursor for pbdbsr104005

  let m_comando = "select srrabvnom                             "
                 ,"from datksrr                                 "
                 ,"where srrcoddig = ?                          "

  prepare pbdbsr104006 from m_comando
  declare cbdbsr104006 cursor for pbdbsr104006

  let m_comando = "select nomgrr                                "
                 ,"from dpaksocor                               "
                 ,"where pstcoddig = ?                          "

  prepare pbdbsr104007 from m_comando
  declare cbdbsr104007 cursor for pbdbsr104007

  let m_comando = "select srvtipabvdes                          "
                 ,"from datksrvtip                              "
                 ,"where atdsrvorg = ?                          "

  prepare pbdbsr104008 from m_comando
  declare cbdbsr104008 cursor for pbdbsr104008

end function

#----------------------------------------------
function bdbsr104()
#----------------------------------------------

  define l_datmservico         record
         atdsrvnum             like datmservico.atdsrvnum
        ,atdsrvano             like datmservico.atdsrvano
        ,atdsrvorg             like datmservico.atdsrvorg
        ,atddat                like datmservico.atddat
        ,atdhor                like datmservico.atdhor
  end record

  define l_datmsrvacp          record
         atdetpcod             like datmsrvacp.atdetpcod
        ,pstcoddig             like datmsrvacp.pstcoddig
        ,socvclcod             like datmsrvacp.socvclcod
        ,srrcoddig             like datmsrvacp.srrcoddig
  end record

  define l_datkveiculo         record
         atdvclsgl             like datkveiculo.atdvclsgl
  end record

  define l_datksrr             record
         srrabvnom             like datksrr.srrabvnom
  end record

  define l_dpaksocor           record
         nomgrr                like dpaksocor.nomgrr
  end record

  define l_datksrvtip          record
         srvtipabvdes          like datksrvtip.srvtipabvdes
  end record

  define l_max_atdsrvseq       like datmsrvacp.atdsrvseq
  define l_assunto             char(80)

  let m_hostname = null
  whenever error continue
  select sitename into m_hostname
  from dual

  whenever error stop
  if sqlca.sqlcode    <> 0 then
     if sqlca.sqlcode <  0 then
        display  "Nao foi possivel acessar a maquina do sistema, "
                ,"avisar o Analista"
                ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        exit program(1)
     end if
     display "Nao foi encontrado a maquina do sistema, avisar o Analista"
            ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     exit program(1)
  end if

  let m_saida   = null

  #----------------------------------------------#
  # BUSCA CAMINHO P/ GRAVACAO DO LOG - UNICENTER #
  #----------------------------------------------#

  if m_hostname <> 'u07' then
    call f_path("DBS","LOG") returning m_saida
    let m_saida = m_saida clipped, '/log.bdbsr104'
  else
    let m_saida = 'log.bdbsr104'
  end if

  call startlog(m_saida)

  if m_prepare is null then
     let m_prepare = "S"
     call bdbsr104_prepare()
  end if

  let m_envia   = null

  #----------------------------------------------------#
  # BUSCA CAMINHO P/ GRAVACAO DO RELATORIO - UNICENTER #
  #----------------------------------------------------#

  let m_saida   = null

  if m_hostname  = 'u07' then
     let m_saida = 'RDBSR104.DOC'
  else
     call f_path("DBS","ARQUIVO") returning m_saida
     let m_saida = m_saida clipped, '/RDBSR104.DOC'
  end if

  #--------------------------------------------
  # Data para execucao
  #--------------------------------------------

  let m_dt_proc = null
  let m_dt_proc = arg_val(1)

  if m_dt_proc is null or
     m_dt_proc =  "  " then
     let m_dt_proc = today
  else
     if length(m_dt_proc) < 10 then
        let m_log = null
        let m_log = "*** ERRO NO PARAMETRO: DATA INVALIDA! -> ", m_dt_proc
        call errorlog(m_log)
        exit program(1)
     end if
  end if

  let m_dt_proc    = "01","/", m_dt_proc[4,5],"/", m_dt_proc[7,10]
  let m_dt_final   = m_dt_proc
  let m_dt_final   = m_dt_final - 1 units day

  let m_dt_proc    = m_dt_final
  let m_dt_proc    = "01","/", m_dt_proc[4,5],"/", m_dt_proc[7,10]
  let m_dt_inicial = m_dt_proc

  let m_log = null
  let m_log = 'INICIANDO PROCESSAMENTO ACOMPANHAMENTO PONTO A PONTO: '
             ,m_dt_inicial
             ,' A '
             ,m_dt_final
  call errorlog(m_log)

  start report rep_bdbsr104 to m_saida

  let m_envia = "N"
  initialize l_datmservico.* to null
  open    cbdbsr104002 using m_dt_inicial
                            ,m_dt_final

  foreach cbdbsr104002 into  l_datmservico.atdsrvnum
                            ,l_datmservico.atdsrvano
                            ,l_datmservico.atdsrvorg
                            ,l_datmservico.atddat
                            ,l_datmservico.atdhor

     let l_max_atdsrvseq = null
     open  cbdbsr104003 using l_datmservico.atdsrvnum
                             ,l_datmservico.atdsrvano
     whenever error continue
     fetch cbdbsr104003 into  l_max_atdsrvseq
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104003'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104003
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104003, Key: '
                   ,' atdsrvnum    -> ', l_datmservico.atdsrvnum
                   ,' atdsrvano    -> ', l_datmservico.atdsrvano
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close cbdbsr104003
        continue foreach
     end if
     close cbdbsr104003

     initialize l_datmsrvacp.* to null
     open  cbdbsr104004 using l_datmservico.atdsrvnum
                             ,l_datmservico.atdsrvano
                             ,l_max_atdsrvseq
     whenever error continue
     fetch cbdbsr104004 into  l_datmsrvacp.atdetpcod
                             ,l_datmsrvacp.pstcoddig
                             ,l_datmsrvacp.socvclcod
                             ,l_datmsrvacp.srrcoddig
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104004'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104004
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104004, Key: '
                   ,' atdsrvnum    -> ', l_datmservico.atdsrvnum
                   ,' atdsrvano    -> ', l_datmservico.atdsrvano
                   ,' atdsrvseq    -> ', l_max_atdsrvseq
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close cbdbsr104004
        continue foreach
     end if
     close cbdbsr104004

     initialize l_datkveiculo.* to null
     open  cbdbsr104005 using l_datmsrvacp.socvclcod
     whenever error continue
     fetch cbdbsr104005 into  l_datkveiculo.atdvclsgl
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104005'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104005
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104005, Key: '
                   ,' socvclcod    -> ', l_datmsrvacp.socvclcod
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close cbdbsr104005
        continue foreach
     end if
     close cbdbsr104005

     initialize l_datksrr.* to null
     open  cbdbsr104006 using l_datmsrvacp.srrcoddig
     whenever error continue
     fetch cbdbsr104006 into  l_datksrr.srrabvnom
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104006'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104006
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104006, Key: '
                   ,' srrcoddig    -> ', l_datmsrvacp.srrcoddig
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'

        call errorlog(m_log)
        close cbdbsr104006
        continue foreach
     end if
     close cbdbsr104006

     initialize l_dpaksocor.* to null
     open  cbdbsr104007 using l_datmsrvacp.pstcoddig
     whenever error continue
     fetch cbdbsr104007 into  l_dpaksocor.nomgrr
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104007'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104007
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104007, Key: '
                   ,' pstcoddig    -> ', l_datmsrvacp.pstcoddig
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close cbdbsr104007
        continue foreach
     end if
     close cbdbsr104007

     initialize l_datksrvtip.* to null
     open  cbdbsr104008 using l_datmservico.atdsrvorg
     whenever error continue
     fetch cbdbsr104008 into  l_datksrvtip.srvtipabvdes
     whenever error stop

     let m_log = null
     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = '** Programa - bdbsr104 '
                      ,'** Erro no cursor CBDBSR104008'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close cbdbsr104008
           exit program(1)
        end if
        let m_log = 'Erro cursor CBDBSR104008, Key: '
                   ,' atdsrvorg    -> ', l_datmservico.atdsrvorg
                   ,' st.: ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close cbdbsr104008
        continue foreach
     end if
     close cbdbsr104008

     let m_envia = "S"
     output to report rep_bdbsr104(l_datmsrvacp.pstcoddig
                                  ,l_dpaksocor.nomgrr
                                  ,l_datmservico.atddat
                                  ,l_datmservico.atdhor
                                  ,l_datmservico.atdsrvnum
                                  ,l_datmservico.atdsrvano
                                  ,l_datksrvtip.srvtipabvdes
                                  ,l_datkveiculo.atdvclsgl
                                  ,l_datmsrvacp.srrcoddig
                                  ,l_datksrr.srrabvnom)

  end foreach

  finish report rep_bdbsr104

  let l_assunto = "Relatório mensal Ponto a Ponto"

  if m_envia = "S" then
     let m_ret = ctx22g00_envia_email('BDBSR104',              # Marcio Meta - PSI185035
                                      l_assunto,
                                      m_saida)
     if m_ret <> 0 then
        if m_ret <> 99 then
           display " Erro ao enviar email(ctx22g00)-", m_saida
        else
           display " Email nao encontrado para este modulo BDBSR104 "
        end if
     end if
  else
     display " NAO HA RELATORIO MENSAL PONTO A PONTO A SER ENVIADO!"
  end if
                                                               # Marcio Meta - PSI185035
end function

#---------------------------------------------------------------------------
report rep_bdbsr104(l_rep)
#---------------------------------------------------------------------------

  define l_rep         record
         pstcoddig     like datmsrvacp.pstcoddig
        ,nomgrr        like dpaksocor.nomgrr
        ,atddat        like datmservico.atddat
        ,atdhor        like datmservico.atdhor
        ,atdsrvnum     like datmservico.atdsrvnum
        ,atdsrvano     like datmservico.atdsrvano
        ,srvtipabvdes  like datksrvtip.srvtipabvdes
        ,atdvclsgl     like datkveiculo.atdvclsgl
        ,srrcoddig     like datmsrvacp.srrcoddig
        ,srrabvnom     like datksrr.srrabvnom
  end record

  define l_qth         char(01)
        ,l_perc_qth_s  decimal(07,02)
        ,l_tmp_tot     decimal(07,02)
        ,l_qtd_s       smallint
        ,l_qtd_serv    smallint
        ,l_qtd_viatur  smallint
        ,l_perc_tp     decimal(07,02)
        ,l_final       decimal(02,00)

  output left      margin    0
         bottom    margin    0
         top       margin    0
         page      length   66

  order by l_rep.pstcoddig
          ,l_rep.atdvclsgl

  format

        page header

           print column 001, "########################################"
                           , "########################################"

           print column 001, "PORTO SEGURO CIA DE SEGUROS GERAIS"
                ,column 049, "DATA: ", today
                ,column 067, "HORA: ", time

           print column 001, "PONTO A PONTO - RESUMO MENSAL"
                ,column 049, "PERIODO: "
                           , m_dt_inicial
                           , " A "
                           , m_dt_final

           print column 001, "########################################"
                           , "########################################"

        before group of l_rep.pstcoddig
           let l_perc_qth_s = 0
           let l_tmp_tot    = 0
           let l_qtd_s      = 0
           let l_qtd_serv   = 0
           let l_qtd_viatur = 0
           let l_perc_tp    = 0
           let l_final      = 0

           print column 001, "========================================"
                           , "========================================"

           print column 001, "Prestador: ", l_rep.pstcoddig using '&&&&&&'
                           , " - "
                           , l_rep.nomgrr

           skip 1 line

           print column 001, "DATA"
                ,column 012, "HORA"
                ,column 018, "SERVICO"
                ,column 029, "TIPO"
                ,column 040, "VIATURA"
                ,column 048, "SOCORRISTA"
                ,column 071, "QTH"

           print column 001, "----------"
                ,column 012, "-----"
                ,column 018, "----------"
                ,column 029, "----------"
                ,column 040, "-------"
                ,column 048, "----------------------"
                ,column 071, "---"

        after group of l_rep.atdvclsgl
           let l_qtd_viatur = l_qtd_viatur + 1

        after group of l_rep.pstcoddig
           skip 1 line
           let l_perc_qth_s = (100 * l_qtd_s)/l_qtd_serv
           print column 001, "Atingimento QTH: ", l_perc_qth_s using '<<<<&.<<'
                           , "%"

           call cts00g05_pstnoar(l_rep.pstcoddig
                                ,m_dt_inicial
                                ,m_dt_final)
                returning l_tmp_tot

           let l_final      = m_dt_final using 'dd'
           let l_perc_tp    = (l_tmp_tot/(l_qtd_viatur * l_final * 24))*100

           print column 001, "Atingimento tempo de trabalho: "
                           , l_perc_tp using '<<<<&.<<'
                           , "%"
           skip 1 line

        on every row

           let l_qth = null
           call cts00g05_qth(l_rep.atdsrvnum
                            ,l_rep.atdsrvano)
                returning l_qth

           if l_qth       = 'S' then
              let l_qtd_s = l_qtd_s + 1
           end if

           let l_qtd_serv = l_qtd_serv + 1

           print column 001, l_rep.atddat
                ,column 012, l_rep.atdhor
                ,column 018, l_rep.atdsrvnum using '&&&&&&&'
                           , "-"
                           , l_rep.atdsrvano using '&&'
                ,column 029, l_rep.srvtipabvdes
                ,column 040, l_rep.atdvclsgl
                ,column 048, l_rep.srrcoddig using '&&&&&'
                           , " - "
                           , l_rep.srrabvnom
                ,column 071, l_qth

end report
