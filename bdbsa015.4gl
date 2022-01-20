#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSA015                                                   #
# ANALISTA RESP..: CELSO YAMAHAKI                                             #
# PSI/OSF........: DESBLOQUEIO DE VIATURAS/SERVICO PRESOS                     #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: CELSO YAMAHAKI                                             #
# LIBERACAO......: 29/09/2011                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 04/04/2013 Raji Jahchan    PSI-2013-07348 Bloqueio automatico servico       #                                                                      #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_data         date,
       m_tmpexp       datetime year to second,
       m_hora         datetime hour to minute,
       m_prepare      smallint,
       m_server       char(30),
       m_data_atual   date,
       m_hora_atual   datetime hour to second

main

   define l_path        char(100),
          l_crioutabela smallint,
          l_prcstt      like dpamcrtpcs.prcstt

   let  m_tmpexp = current

   call fun_dba_abre_banco("CT24HS")

   # Cria tabela temporaria para armazenar veiculo bloqueados para contagem de tempo
   call bdbsa015_cria_temp_veiculos()

   set lock mode to wait 60
   set isolation to dirty read

   let l_path = f_path("DBS","LOG")
   if l_path is null then
      let l_path = "."
   end if
   let l_path = l_path clipped,"/bdbsa015.log"
   call startlog(l_path)

   # BUSCAR A DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual
   display "BDBSA015 Carga:  ", m_data_atual, " ", m_hora_atual

   while true

      let m_server = fgl_getenv("SERVIDOR")
      call ctx28g00("bdbsa015", m_server, m_tmpexp)
             returning m_tmpexp, l_prcstt
      if  l_prcstt = 'A' then
          # BUSCAR A DATA E HORA DO BANCO
          call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

          display "BDBSA015 ativo inicio: ", m_data_atual, " ", m_hora_atual

          #########################################################
          # Processo para desbloqueio automatico de veiculo
          #########################################################
          call bdbsa015_carrega_temp_veiculos()
          call bdbsa015_desbloqueia_veiculos()

          #########################################################
          # Processo para desbloqueio automatico de servico
          #########################################################
          call bdbsa015_desbloqueia_servicos()

          # BUSCAR A DATA E HORA DO BANCO
          call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual
          display "BDBSA015 ativo fim:    ", m_data_atual, " ", m_hora_atual
      else
          # BUSCAR A DATA E HORA DO BANCO
          call cts40g03_data_hora_banco(1) returning m_data_atual, m_hora_atual

          display "BDBSA015 standBy ", m_data_atual, " ", m_hora_atual

      end if

      # Aguarda 60 segundos para proxima execucao
      sleep 60

   end while

end main

#----------------------------
function bdbsa015_prepare()
#----------------------------
   define l_sql char(1000)

   let l_sql = "select a.socvclcod, ",
               "       a.c24atvcod, ",
               "       a.srrcoddig, ",
               "       b.atdvclsgl  ",
               "  from dattfrotalocal a, datkveiculo b ",
               " where b.socacsflg = 1                 ",
               "   and a.socvclcod = b.socvclcod       ",
               "   and a.atdsrvnum is null             ",
               "   and a.c24atvcod = 'QRV'             "
   prepare pbdbsa015_01 from l_sql
   declare cbdbsa015_01 cursor for pbdbsa015_01

   let l_sql = " update datkveiculo       ",
               "    set socacsflg = 0,    ",
               "        c24opemat = 999997",
               "  where socvclcod = ?    "
   prepare pbdbsa015_02 from l_sql

   let l_sql = "insert into viaturaspresas ",
               "values (?, ?, ?, ?, ?)"
   prepare pbdbsa015_03 from l_sql

   let l_sql = "select bloqhr   , ",
               "       socvclcod, ",
               "       c24atvcod, ",
               "       srrcoddig, ",
               "       atdvclsgl  ",
               "  from viaturaspresas"
   prepare pbdbsa015_04 from l_sql
   declare cbdbsa015_04 cursor for pbdbsa015_04

   let l_sql = "delete from viaturaspresas ",
               "where socvclcod = ? "
   prepare pbdbsa015_05 from l_sql

   let l_sql = "select socacsflg, c24atvcod ",
               "  from dattfrotalocal a, datkveiculo b ",
               " where b.socvclcod = ? ",
               "   and a.socvclcod = b.socvclcod "

   prepare pbdbsa015_06 from l_sql
   declare cbdbsa015_06 cursor for pbdbsa015_06

   let l_sql = "select socvclcod ",
                " from viaturaspresas ",
               " where socvclcod = ? "
   prepare pbdbsa015_07 from l_sql
   declare cbdbsa015_07 cursor for pbdbsa015_07

   let l_sql = "select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "
   prepare pbdbsa015_08 from l_sql
   declare cbdbsa015_08 cursor for pbdbsa015_08

   let l_sql = "select atdsrvnum, ",
                     " atdsrvano, ",
                     " srvacsblqhordat, ",
                     " c24opemat, ",
                     " c24opeempcod ",
                " from datmservico ",
               " where atdlibflg in ('S','N') ",
                 " and atdfnlflg in ('N','A') ",
                 " and c24opemat is not null ",
                 " and srvacsblqhordat is not null ",
                 " and atdsrvorg <> 10 "
   prepare pbdbsa015_09 from l_sql
   declare cbdbsa015_09 cursor for pbdbsa015_09

   let l_sql = "select funnom ",
                " from isskfunc ",
               " where funmat = ?",
                 " and empcod = ?"
   prepare pbdbsa015_10 from l_sql
   declare cbdbsa015_10 cursor for pbdbsa015_10

   let l_sql = "update datmservico ",
                 " set c24opemat = null, ",
                     " socvclcod = null, ",
                     " srrcoddig = null ",
            " where atdsrvnum  =  ? ",
              " and atdsrvano  =  ? "
   prepare pbdbsa015_11 from l_sql

   let m_prepare = true

end function

#----------------------------
function bdbsa015_carrega_temp_veiculos()
#----------------------------
   define mr_viaturas record
      bloqhr     datetime hour to minute,
      socvclcod  like dattfrotalocal.socvclcod,
      c24atvcod  like dattfrotalocal.c24atvcod,
      srrcoddig  like dattfrotalocal.srrcoddig,
      atdvclsgl  like datkveiculo.atdvclsgl
   end record

   if not m_prepare then
      call bdbsa015_prepare()
   end if

   open cbdbsa015_01
   foreach cbdbsa015_01 into mr_viaturas.socvclcod,
                             mr_viaturas.c24atvcod,
                             mr_viaturas.srrcoddig,
                             mr_viaturas.atdvclsgl

      let mr_viaturas.bloqhr = current

      #se nao estiver preso antes
      open cbdbsa015_07 using mr_viaturas.socvclcod
      fetch cbdbsa015_07

      if status = notfound then
         #insere na tabela temporaria
         execute pbdbsa015_03 using mr_viaturas.bloqhr,
                                    mr_viaturas.socvclcod,
                                    mr_viaturas.c24atvcod,
                                    mr_viaturas.srrcoddig,
                                    mr_viaturas.atdvclsgl
      end if
      close cbdbsa015_07

      initialize mr_viaturas.* to null
   end foreach



end function


#--------------------------------------
function bdbsa015_desbloqueia_veiculos()
#--------------------------------------
   define mr_viaturas record
      bloqhr     datetime hour to minute,
      socvclcod  like dattfrotalocal.socvclcod,
      c24atvcod  like dattfrotalocal.c24atvcod,
      srrcoddig  like dattfrotalocal.srrcoddig,
      atdvclsgl  like datkveiculo.atdvclsgl
   end record

   define mr_desbloqueia record
      socacsflg   like datkveiculo.socacsflg,
      c24atvcod   like dattfrotalocal.c24atvcod
   end record

   define ws record
      grlchv       like datkgeral.grlchv,
      tmpmaxblqvcl integer
   end record

   define l_agora datetime hour to minute
   define l_email_msg char(500)
   define l_erro integer

   initialize mr_viaturas.*, mr_desbloqueia.* to null

   if not m_prepare then
      call bdbsa015_prepare()
   end if

   # obtem parametro de tempo maximo de bloqueio no veiculo
   let ws.grlchv = 'PSOMAXBLQVLC'
   open cbdbsa015_08 using ws.grlchv
   fetch cbdbsa015_08 into ws.tmpmaxblqvcl
   close cbdbsa015_08

    if ws.tmpmaxblqvcl is null or ws.tmpmaxblqvcl = 0 then
       let ws.tmpmaxblqvcl = 10
       display "Parametro de tempo maximo que um veiculo pode ser bloqueado nao encontrado utilizando o tempo padrao de 10 minutos"
    end if


   open cbdbsa015_04
   foreach cbdbsa015_04 into mr_viaturas.bloqhr,
                             mr_viaturas.socvclcod,
                             mr_viaturas.c24atvcod,
                             mr_viaturas.srrcoddig,
                             mr_viaturas.atdvclsgl

      # Verifica se o veiculo ainda esta preso e não está em atendimento
      open cbdbsa015_06 using mr_viaturas.socvclcod
      fetch cbdbsa015_06 into mr_desbloqueia.socacsflg,
                              mr_desbloqueia.c24atvcod
                              
      if mr_desbloqueia.socacsflg <> 1 or mr_desbloqueia.c24atvcod <> 'QRV' then
         # deleta da tabela temporaria
         execute pbdbsa015_05 using mr_viaturas.socvclcod
         initialize mr_viaturas.*, mr_desbloqueia to null
         continue foreach
      end if

      # Verifica se ja atingiu o tempo maximo de bloqueio parametrizado
      let l_agora = current
      if (l_agora - mr_viaturas.bloqhr) > ws.tmpmaxblqvcl units minute then
         #deleta da tabela temporaria
         execute pbdbsa015_02 using mr_viaturas.socvclcod
         #desbloqueia veiculo
         execute pbdbsa015_05 using mr_viaturas.socvclcod
         display "viatura: ",mr_viaturas.socvclcod, " bloqueado em ", mr_viaturas.bloqhr ," desbloqueada às ", l_agora

         # Email de alerta
         let l_email_msg = "\n Prezado(s), \n \n ",
                           "O veiculo ", mr_viaturas.socvclcod,  " estava bloqueado",
                           " desde ", mr_viaturas.bloqhr, " e foi desbloqueado automaticamente pelo sistema."
         let l_erro = ctx22g00_mail_corpo("BDBSA015",
                                          "Desbloqueio automático de veículo",
                                          l_email_msg)
      end if

      initialize mr_viaturas.*, mr_desbloqueia to null
   end foreach


end function

#-------------------------------------
function bdbsa015_cria_temp_veiculos()
#-------------------------------------
   # Cria tabela temporaria para armazenar veiculos bloqueados
   create temp table viaturaspresas
   (
     bloqhr     datetime hour to minute,
     socvclcod  decimal(6,0),
     c24atvcod  char(3),
     srrcoddig  decimal(8,0),
     atdvclsgl  char(5)
   ) with no log

end function

#---------------------------------------
function bdbsa015_desbloqueia_servicos()
#---------------------------------------
 define ws record
    grlchv          like datkgeral.grlchv,
    tmpmaxblqsrv    integer,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    srvacsblqhordat like datmservico.srvacsblqhordat,
    c24opemat       like datmservico.c24opemat,
    c24opeempcod    like datmservico.c24opeempcod,
    funnom          like isskfunc.funnom
 end record

 define l_agora datetime year to second
 define tmpbloq interval minute(08) to minute
 define tmpblogstr char(20)
 define tmpbloqint integer
 define bloq_dat date
 define bloq_hor datetime hour to second

 # Para saber quem desbloqueou o serviço
 define desblo_data      date
 define desblo_hora      datetime hour to minute
 define histerr          smallint
 define msg_desbloqueio1 char(100)
 define msg_desbloqueio2 char(100)

 define l_email_msg      char(500)
 define l_erro           integer

 if not m_prepare then
    call bdbsa015_prepare()
 end if

 # obtem parametro de tempo maximo de bloqueio no servico
 let ws.grlchv = 'PSOMAXBLQSRV'
 open cbdbsa015_08 using ws.grlchv
 fetch cbdbsa015_08 into ws.tmpmaxblqsrv
 close cbdbsa015_08

 if ws.tmpmaxblqsrv is null or ws.tmpmaxblqsrv = 0 then
    let ws.tmpmaxblqsrv = 20
    display "Parametro de tempo maximo que um servico pode ser bloqueado nao encontrado utilizando o tempo padao de 20 minutos"
 end if

 foreach cbdbsa015_09 into ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.srvacsblqhordat,
                           ws.c24opemat,
                           ws.c24opeempcod

      let l_agora = current
      let tmpbloq = (l_agora - ws.srvacsblqhordat)
      if tmpbloq > ws.tmpmaxblqsrv units minute then

         #DESBLOQUEIA VEICULO

         if ws.c24opeempcod is null or
            ws.c24opeempcod = "" then
            let ws.c24opeempcod = 1
         end if

         open  cbdbsa015_10 using ws.c24opemat,
                                  ws.c24opeempcod
         fetch cbdbsa015_10 into  ws.funnom
         close cbdbsa015_10

         let tmpblogstr = tmpbloq
         let tmpbloqint = tmpblogstr
         let bloq_dat   = ws.srvacsblqhordat
         let bloq_hor   = ws.srvacsblqhordat

         let desblo_data = today
         let desblo_hora = current
         let g_issk.funmat = 999999
         let g_issk.empcod = 1
         let g_issk.usrtip = 'F'

         let msg_desbloqueio1 = "ESTE SERVIÇO ESTAVA COM ", ws.funnom
         let msg_desbloqueio2 = "HA ", tmpbloqint using "<<<<<<<#", "MIN E FOI DESBLOQUEADO COM SUCESSO POR PER"

         call cts10g02_historico(ws.atdsrvnum, ws.atdsrvano,
                                 desblo_data , desblo_hora ,
                                 g_issk.funmat             ,
                                 msg_desbloqueio1,msg_desbloqueio2,"","","")
              returning histerr
         if histerr <> 0  then
           display "Erro (",histerr,") na inclusao do historico DO DESBLOQUEIO."
         end if

         ## RETIRAR
         execute pbdbsa015_11 using ws.atdsrvnum,
                                    ws.atdsrvano

         if sqlca.sqlcode <> 0   then
            display "Erro (", sqlca.sqlcode, ") no Desbloqueio do Servico!"
            continue foreach
         end if

         # Ponto de acesso apos a gravacao do laudo
         call cts00g07_apos_servdesbloqueia(ws.atdsrvnum,
                                            ws.atdsrvano)

         display "servico: ",ws.atdsrvnum using "#######", "/", ws.atdsrvano using "##",
                 " bloqueado em ", ws.srvacsblqhordat ," desbloqueado às ", l_agora

         # Email de alerta
         let l_email_msg = "\n Prezado(s), \n \n ",
                           "O serviço ", ws.atdsrvnum using "#######", "/", ws.atdsrvano using "##",  " estava bloqueado pelo operador ", ws.c24opemat using "<<<<<<<<&"," - ",ws.funnom clipped ," ",
                           " desde ", bloq_dat, " ", bloq_hor, " (", tmpbloqint using "<<<<<<<#", " MIN) e foi desbloqueado automaticamente pelo sistema."
         let l_erro = ctx22g00_mail_corpo("BDBSA015",
                                          "Desbloqueio automático de serviço",
                                          l_email_msg)

      end if

 end foreach

end function