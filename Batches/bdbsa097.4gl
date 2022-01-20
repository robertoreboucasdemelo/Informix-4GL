#############################################################################
# Nome do Modulo: bdbsa097                                           Wagner #
#                                                                           #
# Atualiza bloqueio/desbloqueio de prestadores e socorristas       Out/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# 26/02/2007 Ligia Mattge                 Chamar cta00m08_ver_contingencia  #
# 08/11/2007 Sergio Burini     DVP 25240  Monitor de Rotinas Criticas.      #
# 25/08/2008 Sergio Burini     PSI225223  Controle de SinCards              #
# 27/05/2010 Robert Lima       PSI257206  Gravação da Alteracao na Situacao #
#                                         do Socorrista.                    #
# 15/09/2011 Sergio Burini     110816382  Inclusão de alerta de             #
#                                         funcionamento                     #
# 10/01/2012 Celso Yamahaki    2011-22450 Desabilitar funcao que bloqueia os#
#                                         SIMCARD                           #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn #
#...........................................................................#

database porto

 define m_tmpexp       datetime year to second,
        m_curr         datetime year to second,
        m_horultexe    datetime year to fraction,
        m_horexe       datetime year to fraction
 define m_prepare      smallint
main

 define l_data date,
        l_hora datetime hour to second,
        l_path char(100),
        l_contingencia smallint,
        l_prcstt       like dpamcrtpcs.prcstt,
        l_flag         smallint,
        l_grlinf       like datkgeral.grlinf

  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait 60
  set isolation to dirty read

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped,"/bdbsa097.log"
  let l_flag = false

  call startlog(l_path)

  call bdbsa097_prepare()

  let l_data = today
  let l_hora = current

  #DVP 25240
  let  m_tmpexp = current

  while true

     call ctx28g00("bdbsa097", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, l_prcstt

     if  l_prcstt = 'A' then
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
               # ATUALIZA BLOQUEIO/DESBLOQUEIO DE PRESTADORES
               call bdbsa097_atl_blq_pst()
               #display "realizou os bloqueios"
               # VALIDA SINCARDS RECEBIDOS. SOMENTE SE A CHAVE PSOBLOQSIMCARD ESTIVER LIGADA

               #PSI-2011-22450/EV inicio
               whenever error continue
                  select grlinf
                    into l_grlinf
                    from datkgeral
                   where grlchv = 'PSOBLOQSIMCARD'
               whenever error stop

               if l_grlinf = 'S' or l_grlinf = 's' then
                  let l_flag = true
               end if

               if l_flag then
                  display "EXECUTAR BLOQUEIO DE SIM CARD"
                  call bdbsa097_atl_sincard()
               end if
               #PSI-2011-22450/EV fim

            end if
         end if

         if  bdbsa097_verif_exec() then
             display "EMAIL CONTROLE"
             call bdbsa097_email_alerta_proc()
         end if

     end if

     sleep 60

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
function bdbsa097_prepare()
#=========================#

  define l_sql char(900)

  #---------------------------------
  # Prepara comandos SQL
  #---------------------------------

  let l_sql = "select srrstt  ",
                   "  from datksrr ",
                   " where srrcoddig = ? "

  prepare sel_datksrr from       l_sql
  declare c_datksrr   cursor for sel_datksrr

  let l_sql = "update datksrr set srrstt = ? ",
                   " where datksrr.srrcoddig = ? "

  prepare upd_datksrr from  l_sql

  let l_sql = " select datmsrrblq.srrcoddig, datmsrrblq.c24evtcod,  ",
              "       datmsrrblq.blqincdat, datmsrrblq.blqinchor,   ",
              "       datmsrrblq.blqfnldat, datmsrrblq.blqfnlhor,   ",
              "       datmsrrblq.atlmat,datmsrrblq.blqcademp        ",
              "  from datmsrrblq                ",
              " order by datmsrrblq.srrcoddig,  ",
              "          datmsrrblq.blqincdat,  ",
              "          datmsrrblq.blqinchor   "

   prepare p_bdbsa097_srr from l_sql
   declare c_bdbsa097_srr cursor with hold for p_bdbsa097_srr

   let l_sql =  "delete from datmsrrblq          ",
                " where datmsrrblq.srrcoddig = ? ",
                "   and datmsrrblq.c24evtcod = ? ",
                "   and datmsrrblq.blqincdat = ? ",
                "   and datmsrrblq.blqinchor = ? "

   prepare pbdbsa097001_srr from l_sql

   let l_sql = "select grlinf ",
                " from datkgeral ",
               " where grlchv = 'TEMPOPROCSINCAR' "

   prepare p_bdbsa097_01 from l_sql
   declare c_bdbsa097_01 cursor for p_bdbsa097_01

   let l_sql = "select mdtcod, ",
                     " mdtmvtdigcnt, ",
                     " mdtbotprgseq ",
                " from datmmdtmvt ",
               " where mdtbotprgseq = 4 ",
                 " and  mdtmvtstt = 1 ",
                 " and (datmmdtmvt.caddat > ? or ",
                     " (datmmdtmvt.caddat = ? and ",
                      " datmmdtmvt.cadhor > ?)) ",
                 " and (datmmdtmvt.caddat < ? or ",
                     " (datmmdtmvt.caddat = ? and ",
                      " datmmdtmvt.cadhor < ?)) "

   prepare p_bdbsa097_02 from l_sql
   declare c_bdbsa097_02 cursor for p_bdbsa097_02

   let l_sql = "select a.cdssimide, ",
                     " cdssimintcod ",
                " from datksimmdt a, datkcdssim b ",
               " where a.cdssimide = b.cdssimide ",
                 " and mdtcod = ? ",
                 " and recsinflg in (2,3) "

   prepare p_bdbsa097_03 from l_sql
   declare c_bdbsa097_03 cursor for p_bdbsa097_03

   let l_sql = "update datkmdt ",
                 " set mdtstt = 4 ",
               " where mdtcod = ? "

  prepare p_bdbsa097_04 from l_sql

  let l_sql = "update datkcdssim ",
                " set sinutmdat = current ",
              " where cdssimide = ? "

  prepare p_bdbsa097_05 from l_sql

  let l_sql = "update datkgeral ",
                " set grlinf = ? ",
              " where grlchv = 'TEMPOPROCSINCAR' "

  prepare p_bdbsa097_06 from l_sql

  let l_sql = "select cpodes ",
               " from iddkdominio ",
              " where cponom = ? "

  prepare p_bdbsa097_07 from l_sql
  declare c_bdbsa097_07 cursor for p_bdbsa097_07

  let l_sql = "select socvclcod ",
               " from datkveiculo ",
              " where mdtcod = ? "

  prepare p_bdbsa097_08 from l_sql
  declare c_bdbsa097_08 cursor for p_bdbsa097_08

  let l_sql = "insert into datksinblqvcl(socvclcod, ",
                                       " blqdat, ",
                                       " blqsit, ",
                                       " dblusr, ",
                                       " dbqdat, ",
                                       " dbqmtv) ",
                               " values (?, ",
                                       " current, ",
                                       " 'S', ",
                                       " 999999, ",
                                       " current, ",
                                       " '.')"

  prepare p_bdbsa097_09 from l_sql

  let l_sql = "select nomgrr, ",
                    " atdvclsgl ",
               " from datkveiculo vcl, ",
                    " dpaksocor pst ",
              " where mdtcod = ? ",
                " and pst.pstcoddig = vcl.pstcoddig "

  prepare p_bdbsa097_10 from l_sql
  declare c_bdbsa097_10 cursor for p_bdbsa097_10

  let l_sql = "select sim.cdssimide ",
               " from datkcdssim sim, ",
                    " datksimmdt mdt ",
              " where sim.cdssimide = mdt.cdssimide ",
                " and mdt.mdtcod       = ? ",
                " and sim.cdssimintcod = ? "

  prepare p_bdbsa097_11 from l_sql
  declare c_bdbsa097_11 cursor for p_bdbsa097_11

  let l_sql = "insert into datkcdssim (cdssimintcod, ",
                                     " recsinflg, ",
                                     " funmat, ",
                                     " sinutmdat, ",
                                     " atldat) ",
                               "values(?, ",
                                     " 1, ",
                                     " 99999, ",
                                     " current, ",
                                     " current)"

  prepare p_bdbsa097_12 from l_sql

  let l_sql = "insert into datksimmdt values (?,?)"

  prepare p_bdbsa097_13 from l_sql

  let l_sql = "select sim.cdssimide ",
               " from datkcdssim sim, ",
                    " datksimmdt mdt ",
              " where sim.cdssimide   = mdt.cdssimide ",
               " and sim.cdssimintcod = ? ",
               " and mdt.mdtcod       = ? ",
               " and sim.recsinflg    in (4,5) "

  prepare p_bdbsa097_14 from l_sql
  declare c_bdbsa097_14 cursor for p_bdbsa097_14

  let l_sql = "select grlinf ",
               " from datkgeral ",
              " where grlchv = 'PSOEXEBLQPST' "

  prepare p_bdbsa097_15 from l_sql
  declare c_bdbsa097_15 cursor for p_bdbsa097_15

  let l_sql = "insert into datkgeral values ('PSOEXEBLQPST',",
                                     " current,",
                                     " today,",
                                     " current,",
                                     " 1,",
                                     " 999999)"

  prepare p_bdbsa097_16 from l_sql

  let l_sql = "select grlinf ",
               " from datkgeral ",
              " where grlchv = 'PSOEXEBLQVAL' "

  prepare p_bdbsa097_17 from l_sql
  declare c_bdbsa097_17 cursor for p_bdbsa097_17

  let l_sql = "update datkgeral ",
          " set grlinf = ?, ",
             "  atldat = today, ",
             "  atlhor = current, ",
             "  atlmat = 999999 ",
       "  where grlchv = 'PSOEXEBLQPST' "

  prepare p_bdbsa097_18 from l_sql

  let l_sql = "select grlinf ",
               " from datkgeral ",
              " where grlchv = 'PSOEXEBLQMAIL' "

  prepare p_bdbsa097_19 from l_sql
  declare c_bdbsa097_19 cursor for p_bdbsa097_19

  let l_sql = " select relpamtxt ",
                      " from igbmparam ",
                     " where relsgl    = ? ",
                       " and relpamtip = ? "
        prepare p_ctx34g02_026 from l_sql
        declare c_ctx34g02_026 cursor for p_ctx34g02_026

  let m_prepare = true

end function

#-------------------------------#
 function bdbsa097_atl_blq_pst()
#-------------------------------#

 define d_bdbsa097  record
#  pstcoddig        like datmprsblq.pstcoddig,
   srrcoddig        like datmsrrblq.srrcoddig,
   c24evtcod        like datmsrrblq.c24evtcod,
   blqincdat        like datmsrrblq.blqincdat,
   blqinchor        like datmsrrblq.blqinchor,
   blqfnldat        like datmsrrblq.blqfnldat,
   blqfnlhor        like datmsrrblq.blqfnlhor,
   atlmat           like datmsrrblq.atlmat,
   blqcademp        like datmsrrblq.blqcademp
 end record

 define ws          record
#  prssitcod        like dpaksocor.prssitcod,
#  prssitcod_new    like dpaksocor.prssitcod,
   srrstt           like datksrr.srrstt,
   srrstt_new       like datksrr.srrstt,
   erroflg          char (01),
   comando          char (500)
 end record

 define ws_hora        like datmsrrblq.blqinchor,
        l_data         date,
        l_contingencia smallint,
        l_hora         datetime hour to second,
        l_mesg         char(70),
        l_stt          smallint,
        l_count        smallint,
        l_mesg2        char(70),
        l_prshstdes2   char(70)


 let l_data = null
 initialize d_bdbsa097.*  to null
 initialize ws.*          to null

 let l_data = today
 let l_hora = current

 #---------------------------------
 # Le movimento bloqueio socorrista
 #---------------------------------

 open c_bdbsa097_srr

 foreach c_bdbsa097_srr into d_bdbsa097.srrcoddig, d_bdbsa097.c24evtcod,
                             d_bdbsa097.blqincdat, d_bdbsa097.blqinchor,
                             d_bdbsa097.blqfnldat, d_bdbsa097.blqfnlhor,
                             d_bdbsa097.atlmat   , d_bdbsa097.blqcademp

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

    select today, current into l_data, ws_hora from dual

    open  c_datksrr using d_bdbsa097.srrcoddig
    fetch c_datksrr into  ws.srrstt
    close c_datksrr

    # BLOQUEIO AINDA NAO ENTROU EM VIGOR DEVIDO A SUA DATA
    if l_data < d_bdbsa097.blqincdat then
       continue foreach
    end if

    # BLOQUEIO AINDA NAO ENTROU EM VIGOR DEVIDO AO SEU HORARIO
    if l_data = d_bdbsa097.blqincdat then
       if ws_hora < d_bdbsa097.blqinchor then
          continue foreach
       end if
    end if

    let ws.srrstt_new = 2

    # BLOQUEIO VENCIDO, AGUARDANDO 10 DIAS PARA SER EXCLUIDO.
    if l_data > d_bdbsa097.blqfnldat then
       if (l_data - d_bdbsa097.blqfnldat) > 10 then
          execute pbdbsa097001_srr using d_bdbsa097.srrcoddig,
                                         d_bdbsa097.c24evtcod,
                                         d_bdbsa097.blqincdat,
                                         d_bdbsa097.blqinchor
       end if
       continue foreach
    end if

    # VERIFICA FINAL DO BLOQUEIO
    if l_data = d_bdbsa097.blqfnldat then
       if ws_hora >= d_bdbsa097.blqfnlhor then
          let ws.srrstt_new = 1
       end if
    end if

    if ws.srrstt <> ws.srrstt_new then
         whenever error continue
         begin work
            execute upd_datksrr using ws.srrstt_new,
                                      d_bdbsa097.srrcoddig
            if sqlca.sqlcode  <>  0   then
               rollback work
               continue foreach
            end if

	    ####[Alterado Robert Lima]###################

	    let l_mesg  = "Socorrista desbloqueado via tela de Analise:"
	    let l_mesg2 = " de [",d_bdbsa097.blqincdat clipped,"-",
	                    d_bdbsa097.blqinchor,"] para [",
	       	    	    d_bdbsa097.blqfnldat clipped,"-",d_bdbsa097.blqfnlhor,"]!"

	       for l_count = 0 to 1
	           if  l_count = 0 then
	               let l_prshstdes2 = l_mesg
	           else
	               let l_prshstdes2 = l_mesg2
	           end if
		   call ctd18g01_grava_hist(d_bdbsa097.srrcoddig
			           		    ,l_prshstdes2
			           		    ,today
			           		    ,d_bdbsa097.blqcademp
			       		    ,d_bdbsa097.atlmat
			    	            ,'F')
		          returning l_stt
	                           ,l_mesg
	       end for
	    #################################

         commit work
         whenever error stop
    end if
 end foreach

 let l_data = today
 let l_hora = current

 end function   ###--- bdbsa097

#-------------------------------#
 function bdbsa097_atl_sincard()
#-------------------------------#

    define l_ini          datetime year to second,
           l_fim          datetime year to second,
           l_datini       char(10),
           l_horini       char(08),
           l_datfim       char(10),
           l_horfim       char(08),
           l_sttsin       smallint,
           l_stt          smallint,
           l_mdtcod       like datmmdtmvt.mdtcod,
           l_mdtmvtdigcnt like datmmdtmvt.mdtmvtdigcnt,
           l_mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
           l_cdssimide    like datkcdssim.cdssimide,
           l_cdssimintcod like datkcdssim.cdssimintcod,
           l_socvclcod    like datkveiculo.socvclcod


    open c_bdbsa097_01
    fetch c_bdbsa097_01 into l_ini

    let l_datini = extend(l_ini, day to day),"/",
                   extend(l_ini, month to month),"/",
                   extend(l_ini, year to year)

    let l_horini = extend(l_ini, hour to hour),":",
                   extend(l_ini, minute to minute),":",
                   extend(l_ini, second to second)

    let l_fim = current

    let l_datfim = extend(l_fim, day to day),"/",
                   extend(l_fim, month to month),"/",
                   extend(l_fim, year to year)

    let l_horfim = extend(l_fim, hour to hour),":",
                   extend(l_fim, minute to minute),":",
                   extend(l_fim, second to second)

    open c_bdbsa097_02 using l_datini,
                             l_datini,
                             l_horini,
                             l_datfim,
                             l_datfim,
                             l_horfim


    let m_curr  = current
    display "[", m_curr , "] VERIFICANDO SINAIS"

    foreach c_bdbsa097_02 into l_mdtcod,
                               l_mdtmvtdigcnt,
                               l_mdtbotprgseq

        if  l_mdtmvtdigcnt      is null or
            l_mdtmvtdigcnt      = " "   or
            l_mdtmvtdigcnt      = "0"   or
            l_mdtmvtdigcnt[1,2] <> '89'   then
            continue foreach
        end if

        let m_curr  = current
        display "[", m_curr , '] VERIFICANDO MDT: ', l_mdtcod

        if  not bdbsa097_verific_blq(l_mdtcod) then

            if  l_mdtbotprgseq = 4 then

                open c_bdbsa097_11 using l_mdtcod,
                                         l_mdtmvtdigcnt
                fetch c_bdbsa097_11 into l_cdssimide

                if  sqlca.sqlcode = notfound then
                    execute p_bdbsa097_12 using l_mdtmvtdigcnt

                    let l_cdssimide = sqlca.sqlerrd[2]
                    display l_cdssimide
                    execute p_bdbsa097_13 using l_cdssimide, l_mdtcod
                else
                    execute p_bdbsa097_05 using l_cdssimide
                end if

                let l_sttsin = true

                open c_bdbsa097_03 using l_mdtcod
                foreach c_bdbsa097_03 into l_cdssimide,
                                           l_cdssimintcod

                    if  l_mdtmvtdigcnt <> l_cdssimintcod then
                        let l_sttsin = false

                        let m_curr  = current
                        display "[", m_curr , "] SIMCARDS INCONSISTENTES"
                        display "SIMCARD RECEBIDO..: ", l_mdtmvtdigcnt
                        display "SIMCARD CADASTRADO: ", l_cdssimintcod
                    else
                        let l_sttsin = true
                        exit foreach
                    end if

                end foreach

                open c_bdbsa097_14 using l_mdtmvtdigcnt,
                                         l_mdtcod
                fetch c_bdbsa097_14 into l_cdssimide

                if  sqlca.sqlcode = 0 then
                    let l_sttsin = true
                end if


                if  not l_sttsin then

                    display 'BLOQUEANDO O MDT'
                    execute p_bdbsa097_04 using l_mdtcod

                    open c_bdbsa097_08 using l_mdtcod
                    fetch c_bdbsa097_08 into l_socvclcod

                    display 'INCLUINDO NA TABELA DE BLOQUEIO DE SINCARD'
                    execute p_bdbsa097_09 using l_socvclcod

                    call bdbsa097_manda_mail_blq(l_mdtcod)
                    display "BLOQUEIA SIMCARD"
                    call bdbsa07_manda_msg_blq(l_mdtcod)
                else
                    let m_curr  = current
                    display "[", m_curr , "] SIMCARDS EM CONFORMIDADE"
                end if
            end if
        else
            let m_curr  = current
            display "[", m_curr , "] MDT JAH BLOQUEADO: ", l_mdtcod
        end if

    end foreach

    execute p_bdbsa097_06 using l_fim

    sleep 5

 end function

#---------------------------------#
 function bdbsa07_manda_msg_blq (l_mdtcod)
#---------------------------------#

   define l_mdtcod like datkmdt.mdtcod,
          l_mdtmsgnum like datmmdtmsgtxt.mdtmsgnum

   whenever error continue

   insert into datmmdtmsg ( mdtmsgnum,
                            mdtmsgorgcod,
                            mdtcod,
                            mdtmsgstt,
                            mdtmsgavstip )
                 values   ( 0,
                            1,
                            l_mdtcod,
                            1,           #--> Aguardando transmissao
                            3 )          #--> Sinal bip e sirene

   let l_mdtmsgnum  =  sqlca.sqlerrd[2]

   display 'MENSAGEM: ', l_mdtmsgnum

   insert into datmmdtlog ( mdtmsgnum,
                            mdtlogseq,
                            mdtmsgstt,
                            atldat,
                            atlhor,
                            atlemp,
                            atlmat )
                  values  ( l_mdtmsgnum,
                            1,
                            1,
                            current,
                            current,
                            1,
                            999999 )


   insert into datmmdtmsgtxt ( mdtmsgnum,
                               mdtmsgtxtseq,
                               mdtmsgtxt )
                     values  ( l_mdtmsgnum,
                               1,
                               "ATENCAO! SEU MDT FOI BLOQUEADO! ENTRE EM CONTATO COM A PORTO SOCORRO" )

 end function



#------------------------------------#
 function bdbsa097_verific_blq(l_mdt)
#------------------------------------#

     define l_mdt like datkmdt.mdtcod,
            l_mdtstt like datkmdt.mdtstt

     select mdtstt
       into l_mdtstt
       from datkmdt
      where mdtcod = l_mdt

     if  l_mdtstt = 4 then
         return true
     else
         return false
     end if

 end function

#------------------------------------------#
 function bdbsa097_manda_mail_blq(l_mdtcod)
#------------------------------------------#

     define l_mail      char(050),
            l_mailpso   char(2000),
            l_aux       char(100),
            l_cod_erro  integer,
            l_msg_erro  char(20),
            l_mdtcod    like datkmdt.mdtcod,
            l_nomgrr    like dpaksocor.nomgrr,
            l_atdvclsgl like datkveiculo.atdvclsgl

     define lr_mail record
         rem char(50),
         des char(1000),
         ccp char(250),
         cco char(250),
         ass char(150),
         msg char(32000),
         idr char(20),
         tip char(4)
     end record

     initialize l_mail,
                l_mailpso,
                lr_mail.* to null

     open c_bdbsa097_10 using l_mdtcod
     fetch c_bdbsa097_10 into l_nomgrr,
                              l_atdvclsgl

     let l_aux = 'PSOMAILSIMCARD'
     open c_bdbsa097_07 using l_aux
     foreach c_bdbsa097_07 into l_mail
         let lr_mail.des = lr_mail.des clipped, ",", l_mail
     end foreach

     let lr_mail.rem = "porto.socorro@portoseguro.com.br"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "BLOQUEIO DE VIATURA - SINCARD DIVERGENTE"
     let lr_mail.idr = "F0104577"
     let lr_mail.tip = "html"

     let l_aux = 'PSOASSINATURAMAIL'
     open c_bdbsa097_07 using l_aux
     foreach c_bdbsa097_07 into l_mail
         let l_mailpso = l_mailpso clipped, ",", l_mail
     end foreach

     let lr_mail.msg = "<html>",
                          "<body>",
                              "<table width=100% border=0 bgcolor=red cellpadding='0' cellspacing='5'>",
                                  "<tr>",
                                      "<td><font face=arial size=2 color=white><center><b>ATENCAO! DIVERGENCIA ENTRE SINCARDS</b></center></font>",
                                      "</td>",
                                  "</tr>",
                              "</table>",
                              "<br>",
                              "<font face=arial size=2>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; A viatura <b>", l_atdvclsgl clipped,
                              "</b> do prestador <b>", l_nomgrr clipped, "</b> bloqueado devido a nao conformidade do SIMCard cadastrado no Porto Socorro e o utilizado no veiculo no dia <b>",
                              extend(current,day to day),"/",
                              extend(current,month to month),"/",
                              extend(current,year to year),"</b> as <b>",
                              extend(current,hour to hour),":",
                              extend(current,minute to minute),":",
                              extend(current,second to second),"</b>",
                              "<br><br>Porto Seguro - Informatica<br>",
                              "<a href=mailto:", l_mailpso,">Sistemas Araguaia</a>",
                          "</body>",
                       "</html>"

     call figrc009_mail_send1(lr_mail.*)
          returning l_cod_erro, l_msg_erro

     if  l_cod_erro <> 0 then
         display "Erro no envio do email: ",
                 l_cod_erro using "<<<<<<&", " - ",
                 l_msg_erro clipped
     end if

 end function

#----------------------------------#
 function bdbsa097_manda_mail_ctr()
#----------------------------------#

     define l_mail      char(050),
            l_mailpso   char(2000),
            l_aux       char(100),
            l_cod_erro  integer,
            l_msg_erro  char(20),
            l_nomgrr    like dpaksocor.nomgrr,
            l_atdvclsgl like datkveiculo.atdvclsgl

     define lr_mail record
         rem char(50),
         des char(1000),
         ccp char(250),
         cco char(250),
         ass char(150),
         msg char(32000),
         idr char(20),
         tip char(4)
     end record

     initialize l_mail,
                l_mailpso,
                lr_mail.* to null

     let l_aux = 'PSOMAILSIMCARD'
     open c_bdbsa097_07 using l_aux
     foreach c_bdbsa097_07 into l_mail
         let lr_mail.des = lr_mail.des clipped, l_mail clipped, ","
     end foreach

     let lr_mail.rem = "porto.socorro@portoseguro.com.br"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "CONTROLE EXECUÇÃO BLOQUEIO DE VIATURA - SISTEMA OPERANTE"
     let lr_mail.idr = "F0104577"
     let lr_mail.tip = "html"

     let l_aux = 'PSOASSINATURAMAIL'
     open c_bdbsa097_07 using l_aux
     foreach c_bdbsa097_07 into l_mail
         let l_mailpso = l_mailpso clipped, ",", l_mail
     end foreach

     let lr_mail.msg = "<html>",
                          "<body>",
                              "<table width=100% border=0 bgcolor=red cellpadding='0' cellspacing='5'>",
                                  "<tr>",
                                      "<td><font face=arial size=2 color=white><center><b>CONTROLE EXECUCAO BLOQUEIO DE VIATURAS</b></center></font>",
                                      "</td>",
                                  "</tr>",
                              "</table>",
                              "<br>",
                              "<font face=arial size=2>Batch bloqueio de SIMCard / Prestador / Socorrista ativo.",
                              "<br><br>",
                              "<table width=100% border=0  cellpadding='0' cellspacing='1'>",
                                  "<tr bgcolor=darkblue>",
                                      "<td><font face=arial size=2 color=white><center><b>EXECUCAO ATUAL</b></center></font>",
                                      "</td>",
                                  "</tr>",
                                  "<tr>",
                                      "<td><font face=arial size=2><center><b>", extend(m_horexe, day to day),"/",
                                                                                 extend(m_horexe, month to month),"/",
                                                                                 extend(m_horexe, year to year)," ",
                                                                                 extend(m_horexe, hour to hour),":",
                                                                                 extend(m_horexe, minute to minute),":",
                                                                                 extend(m_horexe, second to second),
                                      "</b></center></font>",
                                  "</tr>",
                              "</table>",
                              "<br><font face=arial size=2>Porto Seguro - Informatica<br>",
                              "<a href=mailto:", l_mailpso clipped,">Sistemas Araguaia</a>",
                          "</body>",
                       "</html>"

     display lr_mail.msg clipped

     display "lr_mail.rem = ", lr_mail.rem
     display "lr_mail.des = ", lr_mail.des
     display "lr_mail.ccp = ", lr_mail.ccp
     display "lr_mail.cco = ", lr_mail.cco
     display "lr_mail.ass = ", lr_mail.ass
     display "lr_mail.msg = ", lr_mail.msg clipped
     display "lr_mail.idr = ", lr_mail.idr
     display "lr_mail.tip = ", lr_mail.tip

     call figrc009_mail_send1(lr_mail.*)
          returning l_cod_erro, l_msg_erro

     display "l_cod_erro = ", l_cod_erro
     display "l_msg_erro = ", l_msg_erro

     if  l_cod_erro <> 0 then
         display "Erro no envio do email: ",
                 l_cod_erro using "<<<<<<&", " - ",
                 l_msg_erro clipped
     end if

 end function

#-------------------------------------#
 function bdbsa097_email_alerta_proc()
#-------------------------------------#

    define l_min smallint,
           l_aux datetime year to fraction

    open c_bdbsa097_15
    fetch c_bdbsa097_15 into m_horultexe

    if  sqlca.sqlcode = 100 then

        execute p_bdbsa097_16

        if  sqlca.sqlcode <> 0 then
            display "ERRO NA INCLUSAO DE DATA DE CONTROLE DE EXECUÇÂO: Erro", sqlca.sqlcode
            return
        end if

    end if

    let m_horexe = current

    if  m_horexe > m_horultexe then

        open c_bdbsa097_17
        fetch c_bdbsa097_17 into l_min

        let l_aux = m_horexe + l_min units minute

        execute p_bdbsa097_18 using l_aux

        call bdbsa097_manda_mail_ctr()

    end if

 end function

#------------------------------#
 function bdbsa097_verif_exec()
#------------------------------#

     define l_status char(01)

     initialize l_status to null

     open c_bdbsa097_19
     fetch c_bdbsa097_19 into l_status

     if  l_status = 'S' then
         return true
     end if

     return false

 end function


 #PSI-2011-22450/EV INICIO
 # Foi replicado código do ctx34g02, pois adicionaria inúmeros programas
 # desnecessários à formação desse batch, comprometendo o desempenho.
##----------------------------------------#
#function ctx34g02_email_erro(lr_parametro)
##----------------------------------------#
#
#  define lr_parametro   record
#         xml_request    char(32000),
#         xml_response   char(32000),
#         assunto        char(100),
#         msg_erro       char(100)
#  end record
#
#  define l_destinatario char(300),
#         l_modulo       char(10),
#         l_comando      char(2000),
#         l_arquivo      char(30),
#         l_relsgl       like igbmparam.relsgl,
#         l_relpamtip    like igbmparam.relpamtip,
#         l_relpamtxt    like igbmparam.relpamtxt
#
#  if not m_prepare then
#     call bdbsa097_prepare()
#  end if
#
#  let l_destinatario = null
#  let l_comando      = null
#  let l_modulo       = "ctx34g02"
#  let l_arquivo      = "./mqacnweb.txt"
#  let l_relsgl       = null
#  let l_relpamtip    = null
#  let l_relpamtxt    = null
#
#  start report ctx34g02_rel_erro to l_arquivo
#  output to report ctx34g02_rel_erro(lr_parametro.xml_request,
#                                     lr_parametro.xml_response,
#                                     lr_parametro.msg_erro)
#  finish report ctx34g02_rel_erro
#
#  # CARREGA DESTINATARIOS PARA RECEBER EMAIL
#  let l_relsgl = "CTX34G02"
#  let l_relpamtip = 1  # ERRO GENERICO
#  let l_destinatario = null
#  open c_ctx34g02_026 using l_relsgl,
#                            l_relpamtip
#  foreach c_ctx34g02_026 into l_relpamtxt
#     if l_destinatario is null then
#        let l_destinatario = l_relpamtxt
#     else
#        let l_destinatario = l_destinatario clipped, ",", l_relpamtxt
#     end if
#  end foreach
#  close c_ctx34g02_026
#
#  if l_destinatario is not null and l_destinatario <> " "  then
#     let l_comando = 'send_email.sh',
#                     ' -a ',l_destinatario        clipped,
#                     ' -s "',lr_parametro.assunto clipped, ' `uname -n` ', lr_parametro.msg_erro clipped, '"',
#                     ' -f ',l_arquivo             clipped
#     run l_comando
#  end if
#
#  sleep 1
#  let l_comando = "rm -f ", l_arquivo
#  run l_comando
#
#end function
#
##------------------------------------#
#report ctx34g02_rel_erro(lr_parametro)
##------------------------------------#
#
#  define lr_parametro  record
#         xml_request   char(32000),
#         xml_response  char(32000),
#         msg_erro      char(100)
#  end record
#
#  define l_data        date,
#         l_hora        datetime hour to minute
#
#  output
#
#     left   margin    00
#     right  margin    00
#     top    margin    00
#     bottom margin    00
#     page   length    02
#
#  format
#
#     first page header
#
#        let l_data = today
#        let l_hora = current
#
#     on every row
#
#        print "DATA/HORA...: ", l_data, "/", l_hora
#
#        skip 1 line
#
#        print "SERVICO.....: DPCNVACIONAJAVA01R "
#
#        skip 1 line
#
#        print "ERRO........: ", lr_parametro.msg_erro clipped
#
#        skip 2 lines
#
#        print "XML REQUEST.: ", lr_parametro.xml_request  clipped
#
#        skip 2 lines
#
#        print "XML RESPONSE: ", lr_parametro.xml_response clipped
#
#end report
#
##PSI-2011-22450/EV FIM

