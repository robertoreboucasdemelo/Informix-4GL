 #############################################################################
 # Nome do Modulo: bdbsa095                                          Marcus  #
 #                                                                           #
 # Checa se ha servicos de internet pendentes                       Ago/2001 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 24/10/2002  EDU          Raji         Diminuir tempo excedido de 8 p/ 4 m.#
 # 05/06/2003  GUILHERME    Ruiz         Aumentar tempo excedido de 3 p/ 7 m.#
 # 10/07/03    ch- oriente  Zyon         alterado o tempo de 6 para 8 minutos#
 #############################################################################
 #                                                                           #
 #                          * * * Alteracoes * * *                           #
 #                                                                           #
 # Data       Autor Fabrica     Origem     Alteracao                         #
 # ---------- ----------------- ---------- --------------------------------- #
 # 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
 #                              OSF036870  do Porto Socorro.                 #
 # ------------------------------------------------------------------------- #
 # 14/07/2005 Cristiane Silva   PSI193755  Incluir funcao Abre_Banco, filtros#
 #                                         de servicos recentes e otimizacao #
 #                                         de acesso ao banco de dados       #
 #...........................................................................#
 # 22/02/2006 Andrei, Meta      PSI196878  Incluir chamada das funcoes       #
 #                                         cts10g06_dados_servicos,          #
 #                                         cta12m00_seleciona_datkgeral      #
 # 26/02/2007 Ligia Mattge                 Chamar cta00m08_ver_contingencia  #
 # 08/11/2007 Sergio Burini     DVP 25240  Monitor de Rotinas Criticas.      #
 # 06/03/2008 Sergio Burini         218545 Incluir função padrao p/ inclusao #
 #                                         de etapas (cts10g04_insere_etapa()#
 # 27/04/2010 Adriano Santos    PIS242853  Retorno da ctb85g02_envia_msg     #
 # 23/05/2011 Celso Yamahaki               Alteracao para o programa nao al- #
 #                                         terar o status para excedido qndo #
 #                                         o prestador aceitar o servico no  #
 #                                         Portal                            #
 # ------------------------------------------------------------------------- #
 # 26/12/2012 Claudinei, BRQ    PSI201226565/EV                              #
 #                                         Comunicacao estruturada de reserva#
 #                                         a locadoras por e-mail - Verificar#
 #                                         reserva com tempo exedido         #
 #                                                                           #
 # 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca             #
 #---------------------------------------------------------------------------#

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define m_tmpexp       datetime year to second,
        m_prcstt       like dpamcrtpcs.prcstt,
# Inicio da alteração – Fabrica BRQ – Claudinei PSI201226565/EV
        m_locatempdef  like datkgeral.grlinf
# Fim da alteração – Fabrica BRQ – Claudinei PSI201226565/EV

 main

  define l_data date,
         l_hora datetime hour to second,
         l_path char(100),
         l_contingencia smallint,
         l_srv like dpamcrtpcs.prcstt

  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait 60
  set isolation to dirty read

  let l_path = f_path("DBS","LOG")

  if l_path is null then
     let l_path = "."
  end if

  let l_path = l_path clipped,"/bdbsa095.log"

  call startlog(l_path)

  call bdbsa095_prepare()

  let l_data = today
  let l_hora = current

  display "BDBSA095 Carga:  ", l_data, " ", l_hora

  #DVP 25240
  let  m_tmpexp = current

  while true

     call ctx28g00("bdbsa095", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, m_prcstt

     if  m_prcstt = 'A' then
         let l_data = today
         let l_hora = current

         display "BDBSA095 Inicio: ", l_data, " ", l_hora

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
               call bdbsa095()
            end if
            
            # Inicio da alteração – Fabrica BRQ – Claudinei PSI201226565/EV

            let l_data = today
            let l_hora = current
            display " "
            display "Inicio Processo Excedido: ", l_data, " ", l_hora
            
            call bdbsa095_execverifexec()
            
            let l_data = today
            let l_hora = current
            
            display "Fim Processo Excedido: ", l_data, " ", l_hora
            
            # Fim da alteração – Fabrica BRQ – Claudinei PSI201226565/EV
            
         end if

         let l_data = today
         let l_hora = current

         display "BDBSA095 Fim:    ", l_data, " ", l_hora
     end if



  sleep 30

  end while

end main

#-----------------------------------------------#
function verifica_se_log_existe(l_nome_arquivo)
#-----------------------------------------------#

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
function bdbsa095_prepare()
#=========================#

  define l_sql char(4000)

  #-------------------------------------------------------------------------
  # Prepara comandos SQL
  #-------------------------------------------------------------------------

  let l_sql = "update datmsrvintseqult set ",
                   "(atdetpseq, atdetpcod) ",
                   " = (?, '4') ",
                   " where atdsrvano = ? and ",
                   "       atdsrvnum = ? and ",
                   "       atdetpseq = ? "
  prepare upd_datmsrvintseqult from  l_sql

  let l_sql = "insert into datmsrvint ",
                   "        (atdsrvano, atdsrvnum, atdetpseq, atdetpcod, ",
                   "         cadorg, pstcoddig, cadusrtip, cademp, ",
                   "         cadmat, caddat, cadhor) ",
                   " values (?, ?, ?, '4', '0', ?, 'B', '0', '0', ",
                   "         today, current)"

  prepare ins_datmsrvint from l_sql

  let l_sql = "select 1 ",
               " from dbsmenvmsgsms ",
              " where smsenvcod = ? "

 prepare pbdbsa095_03 from l_sql
 declare cbdbsa095_03 cursor for pbdbsa095_03

# Inicio da alteração – Fabrica BRQ – Claudinei PSI201226565/EV

   let l_sql = "select atddat ",
               "  from datmservico ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? "
   prepare pbdbsa095_01 from l_sql
   declare cbdbsa095_01 cursor for pbdbsa095_01

   let l_sql = "select grlinf                   ",
               " from  datkgeral                ",
               " where grlchv  = 'PSOLOCTMPEXP' "
   prepare pbdbsa095_04 from l_sql
   declare cbdbsa095_04 cursor for pbdbsa095_04

   let l_sql = "SELECT  reg.atdsrvnum, reg.atdsrvano, reg.atdsrvseq,          ",
               "	t3.atdetpcod, t3.atdetpdat, t3.atdetphor, t5.lcvcod,        ",
               "  t5.acntip                                                   ",
               "FROM TABLE(                                                   ",
               "     MULTISET(                                                ",
               "       SELECT t1.atdsrvnum, t1.atdsrvano,                     ",
               "              MAX(t1.atdsrvseq) AS atdsrvseq                  ",
               "	 FROM datmsrvacp AS t1                                      ",
               "	INNER JOIN datmservico AS t2                                ",
               "	   ON t2.atdsrvnum = t1.atdsrvnum                           ",
               "          AND t2.atdsrvano = t1.atdsrvano                     ",
               "	WHERE t2.atddat       >= (current -1 units day)             ",
               "	GROUP BY t1.atdsrvnum, t1.atdsrvano                         ",
               "             )                                                ",
               "          ) AS reg                                            ",
               "     INNER JOIN datmsrvacp AS t3                              ",
               "	ON t3.atdsrvnum    = reg.atdsrvnum                          ",
               "       AND t3.atdsrvano    = reg.atdsrvano                    ",
               "       AND t3.atdsrvseq    = reg.atdsrvseq                    ",
               "     INNER JOIN datmavisrent AS t4                            ",
               "	ON t4.atdsrvnum    = reg.atdsrvnum                          ",
               "       AND t4.atdsrvano    = reg.atdsrvano                    ",
               "     INNER JOIN datklocadora AS t5                            ",
               "        ON t5.lcvcod       = t4.lcvcod                        ",
               "     WHERE t3.atdetpcod    = 1                                ",
               "       AND t5.acntip       = 1                                ",
               "       AND NOT EXISTS (                                       ",
               "	   SELECT  t6.atdsrvano, t6.atdsrvnum                       ",
               "	     FROM  datmrsvvcl AS t6                                 ",
               "            WHERE  t6.atdsrvano   = reg.atdsrvano             ",
               "	      AND  t6.atdsrvnum   = reg.atdsrvnum )                 "
   prepare pbdbsa095_05 from l_sql
   declare cbdbsa095_05 cursor for pbdbsa095_05

   let l_sql = "insert into datmsrvacp                                        ",
               " (atdsrvnum, atdsrvano, atdsrvseq, atdetpcod, atdetpdat,      ",
               "  atdetphor, empcod, funmat, pstcoddig, atdmotnom, atdvclsgl, ",
               "   c24nomctt, socvclcod, srrcoddig,  envtipcod, srvrcumtvcod, ",
               "  acntmpqtd, dstqtd)                                          ",
               "values                                                        ",
               " (?, ?, ?, 39, current, current, 1, 999999, null, null, null, ",
               "  null, null, null, null, null, null, null)                   "
   prepare pbdbsa095_06 from l_sql

   let l_sql = "insert into datmservhist                                      ",
               " (atdsrvnum, c24txtseq, atdsrvano, c24funmat, c24srvdsc,      ",
               "  ligdat, lighorinc, c24empcod, c24usrtip)                    ",
               "values                                                        ",
               " (?, ?, ?, 999999,                                            ",
               "  'NAO HOUVE RESPOSTA EM TEMPO HABIL DA LOCADORA', current,   ",
               "  current, 1, 'S')                                            "
   prepare pbdbsa095_07 from l_sql

   let l_sql = "select max(c24txtseq)+ 1 as c24txtseq ",
               "  from datmservhist                   ",
               " where atdsrvnum = ? and              ",
               "       atdsrvano = ?                  "
   prepare pbdbsa095_08 from l_sql
   declare cbdbsa095_08 cursor for pbdbsa095_08

# Fim da alteração – Fabrica BRQ – Claudinei PSI201226565/EV


end function


#----------------------------------------------------------------------
 function bdbsa095()
#----------------------------------------------------------------------

 define l_sql char(800)

# let l_sql = "select c24solnom, ",
#                   " ciaempcod, ",
#                   " atdsrvorg ",
#             "  from datmservico ",
#             " where atdsrvnum = ? ",
#               " and atdsrvano = ? "
#
# prepare pbdbsa095_01 from l_sql
# declare cbdbsa095_01 cursor for pbdbsa095_01

 let l_sql = " select datmsrvint.atdsrvano, ",
             " datmsrvint.atdsrvnum, ",
             " datmsrvint.atdetpseq, ",
             " datmsrvint.pstcoddig, ",
             " datmsrvint.caddat, ",
             " datmsrvint.cadhor, ",
             " datmsrvint.atdetpcod ",
        " from datmsrvintseqult, datmsrvint ",
       " where datmsrvint.atdetpcod =0 ",
        " and datmsrvint.caddat >= TODAY - 1 units day ",
         " and datmsrvintseqult.atdsrvano  = datmsrvint.atdsrvano ",
         " and datmsrvintseqult.atdsrvnum  = datmsrvint.atdsrvnum ",
         " and datmsrvintseqult.atdetpseq  = datmsrvint.atdetpseq "

 call bdbsa095_sel(l_sql)

 let l_sql = " select datmsrvint.atdsrvano, ",
             " datmsrvint.atdsrvnum, ",
             " datmsrvint.atdetpseq, ",
             " datmsrvint.pstcoddig, ",
             " datmsrvint.caddat, ",
             " datmsrvint.cadhor, ",
             " datmsrvint.atdetpcod ",
        " from datmsrvintseqult, datmsrvint ",
       " where datmsrvint.atdetpcod =1 ",
        " and datmsrvint.caddat >= TODAY - 1 units day ",
         " and datmsrvintseqult.atdsrvano  = datmsrvint.atdsrvano ",
         " and datmsrvintseqult.atdsrvnum  = datmsrvint.atdsrvnum ",
         " and datmsrvintseqult.atdetpseq  = datmsrvint.atdetpseq "

 call bdbsa095_sel(l_sql)

end function

function bdbsa095_sel(l_sql)

 define l_sql char(800)

 define d_bdbsa095    record
    atdsrvano         like datmsrvintseqult.atdsrvano,
    atdsrvnum         like datmsrvintseqult.atdsrvnum,
    atdetpseq         like datmsrvintseqult.atdetpseq,
    pstcoddig         like datmsrvint.pstcoddig,
    caddat            like datmsrvint.caddat,
    cadhor            like datmsrvint.cadhor,
    atdetpcod         like datmsrvint.atdetpcod
 end record

 define ws          record
   espera           char (09),
   erroflg          char (01),
   atdetpseq        like datmsrvintseqult.atdetpseq,
   comando          char (700),
   sqlcode          smallint,
   atdsrvseq        like datmsrvacp.atdsrvseq,
   difer            interval hour(06) to second,
   totmin           interval hour(06) to second
 end record

  define lr_ctb85g02 record
     codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
     mensagem  char(100)
  end record

 define l_qtdmin    dec(10,0) # PSI 185035
 define l_atdprvdat like datmservico.atdprvdat,
        l_atdprvdat_c char(5),
        l_ult_atdetpcod like datmsrvacp.atdetpcod,
        l_contingencia smallint,
        tmpacn like datrgrpntz.atmacnatchorqtd,
        tmpacnchar char(7),
        erro     integer,
        msg      char(20)

 define lr_retorno record
                   resultado smallint
                  ,mensagem  char(080)
                  ,atdsrvorg like datmservico.atdsrvorg
                  ,atddat    like datmservico.atddat
 end record


 let tmpacn = null

 let g_issk.empcod = null
 let g_issk.funmat = null

 initialize d_bdbsa095.*  to null
 initialize ws.*          to null

 prepare cmd from l_sql
 declare sel_excedidos cursor with hold for cmd

 foreach sel_excedidos into d_bdbsa095.atdsrvano,
                            d_bdbsa095.atdsrvnum,
                            d_bdbsa095.atdetpseq,
                            d_bdbsa095.pstcoddig,
                            d_bdbsa095.caddat,
                            d_bdbsa095.cadhor,
                            d_bdbsa095.atdetpcod





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

   let ws.totmin = "00:00:00"
   initialize lr_retorno.*,
              lr_ctb85g02.* to null
   call cts10g06_dados_servicos(1, d_bdbsa095.atdsrvnum, d_bdbsa095.atdsrvano)
      returning lr_retorno.resultado
               ,lr_retorno.mensagem
               ,lr_retorno.atdsrvorg
               ,lr_retorno.atddat

   if d_bdbsa095.atdetpcod = 0 then ## aguardando para ser aceito

      let l_qtdmin = null

      if lr_retorno.atdsrvorg = 8 then
         initialize lr_retorno.* to null
         call cta12m00_seleciona_datkgeral("PSOTMPCEXTRA")
            returning  lr_retorno.resultado
                      ,lr_retorno.mensagem
                      ,l_qtdmin

      else
         initialize lr_retorno.* to null

         call cts47g00_verif_tmp(d_bdbsa095.atdsrvnum, d_bdbsa095.atdsrvano,"ACEITE")
         returning tmpacn, erro, msg

         if tmpacn is not null then
             let tmpacnchar = tmpacn

             let l_qtdmin = tmpacnchar[6,7] clipped
         else
             if  tmpacn is null or tmpacn = " " then
                 call cta12m00_seleciona_datkgeral("PSOSRVTMPEXCMIN")
                    returning  lr_retorno.resultado
                              ,lr_retorno.mensagem
                              ,l_qtdmin
             end if
         end if
      end if


   end if

   if d_bdbsa095.atdetpcod = 1 then ## aceito mas nao acionado

      let l_qtdmin = null
      call cts10g06_dados_servicos(7,d_bdbsa095.atdsrvnum, d_bdbsa095.atdsrvano)
           returning lr_retorno.resultado
                    ,lr_retorno.mensagem
                    ,l_atdprvdat

     let l_atdprvdat_c = l_atdprvdat

     let l_qtdmin = l_atdprvdat_c[4,5]

     call cts10g04_ultima_etapa(d_bdbsa095.atdsrvnum, d_bdbsa095.atdsrvano)
          returning l_ult_atdetpcod

     #call ctb85g02_envia_msg(2, d_bdbsa095.atdsrvnum, d_bdbsa095.atdsrvano)
     #    returning lr_ctb85g02.codigo,
     #              lr_ctb85g02.mensagem

   end if

   let ws.totmin = ws.totmin + l_qtdmin units minute


   call bdbsa095_espera(d_bdbsa095.caddat, d_bdbsa095.cadhor)
            returning ws.difer

   if (d_bdbsa095.atdetpcod = 1 and l_ult_atdetpcod <> 4 and
       l_ult_atdetpcod <> 7 and l_ult_atdetpcod <> 3 and l_ult_atdetpcod <> 10) or
       d_bdbsa095.atdetpcod = 0 then

       if ws.difer < ws.totmin then
          continue foreach
       end if

       let ws.atdetpseq = d_bdbsa095.atdetpseq + 1

       whenever error continue

       begin work

       execute ins_datmsrvint using d_bdbsa095.atdsrvano,
                                    d_bdbsa095.atdsrvnum,
                                    ws.atdetpseq,
                                    d_bdbsa095.pstcoddig

       if sqlca.sqlcode <> 0 then
          display "Erro ", sqlca.sqlcode, "em datmsrvint ", d_bdbsa095.atdsrvnum, " ", ws.atdetpseq
          rollback work
          continue foreach
       end if

       execute upd_datmsrvintseqult using ws.atdetpseq,
                                          d_bdbsa095.atdsrvano,
                                          d_bdbsa095.atdsrvnum,
                                          d_bdbsa095.atdetpseq
       if sqlca.sqlcode <> 0 then
          display "Erro ", sqlca.sqlcode, "em datmsrvintseqult ", d_bdbsa095.atdsrvnum, " ", ws.atdetpseq, " ", d_bdbsa095.atdetpseq
          rollback work
          continue foreach
       end if

       # 218545 - Burini
       call cts10g04_insere_etapa(d_bdbsa095.atdsrvnum,
                                  d_bdbsa095.atdsrvano,
                                  39,
                                  "","","","")
            returning ws.sqlcode

       if ws.sqlcode <> 0 then
          display "Erro1 ", ws.sqlcode, "em datmsrvacp ", d_bdbsa095.atdsrvnum, " ", ws.atdetpseq
          rollback work
          continue foreach
       end if

       # 218545 - Burini
       call cts10g04_insere_etapa(d_bdbsa095.atdsrvnum,
                                  d_bdbsa095.atdsrvano,
                                  1,
                                  "","","","")
            returning ws.sqlcode

       if ws.sqlcode <> 0 then
          display "Erro2 ", ws.sqlcode, "em datmsrvacp ", d_bdbsa095.atdsrvnum, " ", ws.atdetpseq
          rollback work
          continue foreach
       end if

       update datmservico
              set atdprscod = ""          ,
                  atdvclsgl = ""          ,
                  socvclcod = ""          ,
                  srrcoddig = ""          ,
                  c24nomctt = ""          ,
                  c24opemat = ""          ,
                  atdfnlhor = ""          ,
                  cnldat    = ""          ,
                  atdcstvlr = ""          ,
                  atdprvdat = null        ,
                  atdfnlflg = "N"
            where atdsrvnum = d_bdbsa095.atdsrvnum
              and atdsrvano = d_bdbsa095.atdsrvano

       if sqlca.sqlcode <> 0 then
          display "Erro ", sqlca.sqlcode, "em datmservico ", d_bdbsa095.atdsrvnum
          rollback work
          continue foreach
       else
          commit work
          call cts00g07_apos_grvlaudo(d_bdbsa095.atdsrvnum,d_bdbsa095.atdsrvano)
       end if
   end if

   call ctx28g00("bdbsa095", fgl_getenv("SERVIDOR"), m_tmpexp)
         returning m_tmpexp, m_prcstt

 end foreach

end function   #bdbsa095

#--------------------------------------#
 function bdbsa095_espera(param)
#--------------------------------------#

   define param        record
     dataini           date,
     horaini           datetime hour to second
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

 end function   ###--- bdbsa095_espera

# Inicio da alteração – Fabrica BRQ – Claudinei PSI201226565/EV

#--------------------------------------#
function bdbsa095_execverifexec()
#--------------------------------------#

   call bdbsa095_locatempdef() 
   
   call bdbsa095_servetaploca()

end function

#--------------------------------------#
function bdbsa095_locatempdef()
#--------------------------------------#

   whenever error continue
   open  cbdbsa095_04 
   fetch cbdbsa095_04 into m_locatempdef
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let m_locatempdef = 20
      else
         display "Erro ao localizar intervalo de resposta do servico. sqlcode: " 
                 ,sqlca.sqlcode sleep 2
         exit program
      end if
   end if
   
   close cbdbsa095_04
   whenever error stop

end function

#--------------------------------------#
function bdbsa095_servetaploca()
#--------------------------------------#

   define l_regs record
          l_atdsrvnum   like datmsrvacp.atdsrvnum
         ,l_atdsrvano   like datmsrvacp.atdsrvano
         ,l_atdsrvseq   like datmsrvacp.atdsrvseq
         ,l_atdetpcod   like datmsrvacp.atdetpcod
         ,l_atdetpdat   like datmsrvacp.atdetpdat
         ,l_atdetphor   like datmsrvacp.atdetphor
         ,l_lcvcod      like datklocadora.lcvcod
         ,l_acntip      like datklocadora.acntip
   end record
   
   define l_atuhora     datetime hour to minute
         ,l_atuhoradif  interval hour to minute
         ,l_resptemp    char(05)
         ,l_excedido    integer
         ,l_tot_registro integer
         ,l_atudata     date
         ,l_atddat      like datmservico.atddat
         ,l_c24txtseq   like datmservhist.c24txtseq
   
   let l_excedido = 0
   let l_tot_registro = 0
   let l_c24txtseq = 0
   initialize l_regs.* to null
   
   call bdbsa095_restempcalc() returning l_resptemp
   
   let l_atuhora = current
   let l_atudata = current

   whenever error continue
   open  cbdbsa095_05 
   
   foreach cbdbsa095_05 into l_regs.*
      if sqlca.sqlcode != 0 or 
         sqlca.sqlcode  = 100 then
         exit foreach
      end if

      let l_tot_registro = l_tot_registro + 1
      
      let l_atuhoradif = l_atuhora - l_regs.l_atdetphor
      
      
      open cbdbsa095_01 using  l_regs.l_atdsrvnum
                              ,l_regs.l_atdsrvano
      
      fetch cbdbsa095_01 into l_atddat
       
      if l_atuhoradif > l_resptemp or
         l_atddat     < l_atudata  then
         
         let l_regs.l_atdsrvseq = l_regs.l_atdsrvseq + 1
         
         whenever error continue
         execute pbdbsa095_06 using l_regs.l_atdsrvnum
                                   ,l_regs.l_atdsrvano
                                   ,l_regs.l_atdsrvseq
         whenever error stop     
         if sqlca.sqlcode <> 0 then
            display "Erro ao gravar etapa exedido. sqlcode: ", 
                    sqlca.sqlcode sleep 2
            exit program
         end if
         
         open cbdbsa095_08 using  l_regs.l_atdsrvnum
                                 ,l_regs.l_atdsrvano
         
         fetch cbdbsa095_08 into l_c24txtseq
         
         if sqlca.sqlcode = 100 then
            let l_c24txtseq = 1
         end if   
         
         whenever error continue
         execute pbdbsa095_07 using l_regs.l_atdsrvnum
                                   ,l_c24txtseq
                                   ,l_regs.l_atdsrvano
         
         whenever error stop     
         if sqlca.sqlcode <> 0 then
            display "Erro ao gravar historico do servico. sqlcode: ", 
                    sqlca.sqlcode sleep 2
            exit program
         end if
         let l_excedido = l_excedido + 1
      end if 
      
   end foreach
   
   if sqlca.sqlcode <> 0 then
      display "Erro ao localizar etapas dos servicos. sqlcode: ", 
              sqlca.sqlcode sleep 2
      exit program
   end if
   
   close cbdbsa095_05
   whenever error stop

   display "Total de Registros Lidos    = ", l_tot_registro 
   display "Total de Registros Excedido = ", l_excedido

end function

#--------------------------------------#
function bdbsa095_restempcalc()
#--------------------------------------#
   
   define l_locatempdef       int
         ,l_locatempdef_aux   int
         ,l_locatempdef_out   char(5)
   
   let l_locatempdef = m_locatempdef
   
   if l_locatempdef > 59 then
      let l_locatempdef_aux = l_locatempdef / 60
      
      if l_locatempdef_aux > 9 then
         let l_locatempdef_out = l_locatempdef_aux
      else
         let l_locatempdef_out = l_locatempdef_aux
         let l_locatempdef_out = "0", l_locatempdef_out clipped
      end if
      
      let l_locatempdef_aux = l_locatempdef - (l_locatempdef_aux * 60)
      
      if l_locatempdef_aux > 9 then
         let l_locatempdef_out = l_locatempdef_out clipped, ":", 
                                 l_locatempdef_aux
      else
         let l_locatempdef_out = l_locatempdef_out clipped, ":0", 
                                 l_locatempdef_aux
      end if
      
      display "l_aux2 = ", l_locatempdef_aux
   else
      if l_locatempdef > 9 then
         let l_locatempdef_out = "00:", l_locatempdef
      else
         let l_locatempdef_out = "00:0", l_locatempdef
      end if
   
   end if
   
   return l_locatempdef_out
   
end function

# Fim da alteração – Fabrica BRQ – Claudinei PSI201226565/EV
