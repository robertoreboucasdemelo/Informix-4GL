#############################################################################
# Nome do Modulo: bdbsa096                                         Marcus   #
#                                                                           #
# Realiza consistencias e gera alertas para operadores de radio    Set/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/09/2001  PSI 13622-0  Marcus       Acionamento via Internet            #
#---------------------------------------------------------------------------#
# 22/04/2003  CT           Raji/Ruiz    Recusado apenas um alerta no radio  #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
# 31/08/2004 Robson, Meta      PSI186406  Acrescentadas chamadas a cts10g04 #
# ------------------------------------------------------------------------- #
# 14/07/2005 Cristiane Silva   PSI193755  Incluir a funcao Abre_Banco,      #
#                                         verificacao dos filtros de servi- #
#                                         cos recentes, otimizacao de acesso#
#                                         ao banco de dados                 #
# 26/02/2007 Ligia Mattge                 Chamar cta00m08_ver_contingencia  #
# 08/11/2007 Sergio Burini     DVP 25240  Monitor de Rotinas Criticas.      #
#...........................................................................#

 database porto

 define m_tmpexp       datetime year to second

 main

  define l_data date,
         l_hora datetime hour to second,
         l_path char(100),
         l_contingencia smallint,
         l_prcstt       like dpamcrtpcs.prcstt

  #PSI 193755 -  ABRE_BANCO
  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait
  set isolation to dirty read

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped,"/bdbsa096.log"

  call startlog(l_path)

  call bdbsa096_prepare()

  let l_data = today
  let l_hora = current

  display "BDBSA096 Carga:  ", l_data, " ", l_hora

  #DVP 25240
  let  m_tmpexp = current

  while true

     call ctx28g00("bdbsa096", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, l_prcstt

     if  l_prcstt = 'A' then

         let l_data = today
         let l_hora = current

         display "BDBSA096 Inicio: ", l_data, " ", l_hora

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
               call bdbsa096()
            end if
         end if

         let l_data = today
         let l_hora = current

         display "BDBSA096 Fim:    ", l_data, " ", l_hora

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

#=========================#
function bdbsa096_prepare()
#=========================#

  define l_sql char(900)

  #-------------------------------------------------------------------------
  # Prepara comandos SQL
  #-------------------------------------------------------------------------
  let l_sql = "insert into datmsrvintale ( srvintaleseq, ",
                   "                            atdsrvnum, ",
                   "                            atdsrvano, ",
                   "                            srvintalecod, ",
                   "                            srvintalesit, ",
                   "                            caddat, ",
                   "                            cadhor ) ",
                   "                 values   ( '0', ?, ?, ?, ?, ?, ? ) "

  prepare ins_datmsrvintale  from  l_sql

  let l_sql = "select srvintaleseq ",
                   "  from datmsrvintale ",
                   " where srvintalesit = ? ",
                   "   and srvintalecod = ? "

  prepare s_datmsrvintale_1  from       l_sql
  declare c_datmsrvintale_1  cursor for s_datmsrvintale_1

  let l_sql = "select srvintaleseq ",
                   "  from datmsrvintale ",
                   " where srvintalesit = ? ",
                   "   and srvintalecod = ? ",
                   "   and atdsrvnum    = ? ",
                   "   and atdsrvano    = ? "

  prepare s_datmsrvintale_2  from       l_sql
  declare c_datmsrvintale_2  cursor for s_datmsrvintale_2

  let l_sql =  "select count(*)         ",
               "  from datmsrvintale    ",
               " where atdsrvnum    = ? ",
               "   and atdsrvano    = ? ",
               "   and srvintalecod = ? ",
               "   and srvintalesit in (1,2) "

  prepare p_countale  from  l_sql
  declare c_countale  cursor for p_countale

end function

#----------------------------------------------------------------------
 function bdbsa096()
#----------------------------------------------------------------------

 define d_bdbsa096  record
   atdsrvnum        like datmsrvintale.atdsrvnum,
   atdsrvano        like datmsrvintale.atdsrvano,
   pstcoddig        like datmsrvint.pstcoddig,
#  srvintalesit     like datmsrvintale.srvintalesit,
   srvintalecod     like datmsrvintale.srvintalecod
 end record

 define ws          record
    dataatu         date,
    horaatu         char (08),
    minuto          char (02),
    comando         char (900),
    canpsqdat       date,
    difer           char (09),
    srvintalesit    like datmsrvintale.srvintalesit,
    qtdale          smallint
 end record
 #PSI186406 -Robson -Inicio
 define lr_aux record
    resultado smallint
   ,mensagem  char(60)
   ,atdsrvseq like datmsrvacp.atdsrvseq
   ,srrcoddig like datmsrvacp.srrcoddig
   ,socvclcod like datmsrvacp.socvclcod
 end record
 define l_nullo smallint,
        l_contingencia smallint

 #PSI186406 -Robson -Fim
 define tmp_atdetpcod  like datmsrvacp.atdetpcod
 define tmp_pstcoddig  like datmsrvacp.pstcoddig

 let tmp_atdetpcod = 0
 let tmp_pstcoddig = 0
 initialize ws.*          to null
 initialize d_bdbsa096.*  to null

 let ws.dataatu               =  today
 let ws.horaatu               =  current hour to second
 let ws.minuto                =  ws.horaatu[04,05]
 let ws.srvintalesit  =  1     #--> Situacao pendente

 #--------------------------------------------------------------------
  # Cursor para obter os servicos com tempo excedido
  #--------------------------------------------------------------------
  let ws.comando = "select datmsrvint.atdsrvano, ",
                   "      datmsrvint.atdsrvnum  ",
                   "  from datmsrvintseqult, datmsrvint ",
                   " where datmsrvint.atdetpcod = '4' ",
                  " and datmsrvint.caddat >= today - 1 units day",
                  " and datmsrvintseqult.atdsrvano = datmsrvint.atdsrvano ",
                  " and datmsrvintseqult.atdsrvnum = datmsrvint.atdsrvnum ",
                  " and datmsrvintseqult.atdetpseq = datmsrvint.atdetpseq "

  prepare s_excedidos from ws.comando
  declare c_excedidos cursor for s_excedidos

 #--------------------------------------------------------------------
 # Ate 01:00 da madrugada verifica cancelados do dia anterior
 #--------------------------------------------------------------------
 let ws.canpsqdat = today
 if ws.horaatu  <  "01:00"   then
    let ws.canpsqdat = today - 1
 end if

 let d_bdbsa096.srvintalecod = 1

 open c_excedidos
 foreach c_excedidos into d_bdbsa096.atdsrvano,
                          d_bdbsa096.atdsrvnum

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

    #PSI186406 -Robson -Inicio
    call cts10g04_max_seq(d_bdbsa096.atdsrvnum
                         ,d_bdbsa096.atdsrvano
                         ,l_nullo)
       returning lr_aux.resultado
                ,lr_aux.mensagem
                ,lr_aux.atdsrvseq

    call cts10g04_ultimo_pst(d_bdbsa096.atdsrvnum
                            ,d_bdbsa096.atdsrvano
                            ,lr_aux.atdsrvseq)
         returning lr_aux.resultado
                  ,lr_aux.mensagem
                  ,tmp_atdetpcod
                  ,tmp_pstcoddig
                  ,lr_aux.srrcoddig
                  ,lr_aux.socvclcod
    #PSI186406 -Robson -Fim
    if d_bdbsa096.pstcoddig = tmp_pstcoddig then

       call bdbsa096_alerta(ws.dataatu,
                            ws.horaatu,
                            ws.srvintalesit,
                            d_bdbsa096.atdsrvnum,
                            d_bdbsa096.atdsrvano,
                            d_bdbsa096.srvintalecod )
    end if

 end foreach

 #--------------------------------------------------------------------
 # Cursor para obter os servicos recusados
 #--------------------------------------------------------------------

 initialize d_bdbsa096.* to NULL
 let d_bdbsa096.srvintalecod = 2

 declare c_recusados cursor for
 select datmsrvint.atdsrvano,
        datmsrvint.atdsrvnum,
        datmsrvint.pstcoddig
   from datmsrvintseqult, datmsrvint
  where datmsrvint.atdetpcod = '2' and
        datmsrvint.caddat >= today - 1 units day and
        datmsrvintseqult.atdetpseq = datmsrvint.atdetpseq and
        datmsrvintseqult.atdsrvano = datmsrvint.atdsrvano and
        datmsrvintseqult.atdsrvnum = datmsrvint.atdsrvnum

 foreach c_recusados into d_bdbsa096.atdsrvano,
                          d_bdbsa096.atdsrvnum,
                          d_bdbsa096.pstcoddig

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

  #PSI186406 -Robson -Inicio
  call cts10g04_ultimo_pst(d_bdbsa096.atdsrvnum
                          ,d_bdbsa096.atdsrvano
                          ,lr_aux.atdsrvseq)
       returning lr_aux.resultado
                ,lr_aux.mensagem
                ,tmp_atdetpcod
                ,tmp_pstcoddig
                ,lr_aux.srrcoddig
                ,lr_aux.socvclcod
  #PSI186406 -Robson -Fim

  if d_bdbsa096.pstcoddig = tmp_pstcoddig then

     let ws.qtdale = 0

     open c_countale using d_bdbsa096.atdsrvnum,
                           d_bdbsa096.atdsrvano,
                           d_bdbsa096.srvintalecod

     fetch c_countale into ws.qtdale

     if ws.qtdale < 1 then
        call bdbsa096_alerta(ws.dataatu,
                             ws.horaatu,
                             ws.srvintalesit,
                             d_bdbsa096.atdsrvnum,
                             d_bdbsa096.atdsrvano,
                             d_bdbsa096.srvintalecod )
     end if
  end if

 end foreach

end function  #---bdbsa096

#--------------------------------------------------------------------------
 function bdbsa096_alerta(param)
#--------------------------------------------------------------------------

 define param       record
    dataatu         date,
    horaatu         char (08),
    srvintalesit    like datmsrvintale.srvintalesit,
    atdsrvnum       like datmsrvintale.atdsrvnum,
    atdsrvano       like datmsrvintale.atdsrvano,
    srvintalecod    like datmsrvintale.srvintalecod
 end record


 #--------------------------------------------------------------------
 # Verifica se o alerta ja' esta gravado e nao foi verificado
 #--------------------------------------------------------------------
 if param.atdsrvnum  is null   then
    open  c_datmsrvintale_1  using  param.srvintalesit,
                                    param.srvintalecod
    fetch c_datmsrvintale_1
    if sqlca.sqlcode  =  0   then
       close c_datmsrvintale_1
       return
    end if
    close c_datmsrvintale_1
 else
    open  c_datmsrvintale_2  using  param.srvintalesit,
                                    param.srvintalecod,
                                    param.atdsrvnum,
                                    param.atdsrvano
    fetch c_datmsrvintale_2
    if sqlca.sqlcode  =  0   then
       close c_datmsrvintale_2
       return
    end if
    close c_datmsrvintale_2
 end if

 #--------------------------------------------------------------------
 # Grava alerta para operador de radio
 #--------------------------------------------------------------------
 whenever error continue

 execute ins_datmsrvintale  using  param.atdsrvnum,
                                   param.atdsrvano,
                                   param.srvintalecod,
                                   param.srvintalesit,
                                   param.dataatu,
                                   param.horaatu

 if sqlca.sqlcode  <>  0   then
    display param.dataatu," ",param.horaatu," ===> Alerta ",
            param.srvintalecod using "<<<<<<<<<&",
            " : Erro (", sqlca.sqlcode using "<<<<<&",
            ") na inclusao tabela datmsrvintale"
    rollback work
    exit program (1)
 end if

#commit work
 whenever error stop

 end function   ###--- bdbsa096_alerta
